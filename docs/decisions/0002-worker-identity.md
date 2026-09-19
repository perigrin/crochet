---
title: Worker identity
state: proposed
author: Chris Prather
date: 2026-09-18
supersedes: []
superseded-by: []
---

# 0002: Worker identity

git-zhi implements per-worker scheduling completely. Crochet cannot use any of
it, because every agent working in a repo resolves to the same actor. The fix
is one identity, not a scheduler.

## Problem Statement

`Graph.headForActor` already does the work multi-worker execution needs:

1. If the actor has an in-progress issue, return it — per-worker WIP of one,
   and resumption after a restart.
2. Otherwise exclude issues in progress whose last transition names a
   *different* actor — mutual exclusion.
3. Otherwise return a ready issue assigned to this actor, if there is one.

An earlier draft of this document claimed a third preference — assigned-to-me,
then unassigned, then assigned-to-another. **Only the first tier exists.**
`graph.go:439-444` returns a ready issue whose `Assigned` matches, and then
falls to `headGlobal`, which never reads `Assigned` at all (`graph.go:363-395`).
An issue assigned to a different worker is picked exactly as readily as an
unassigned one.

The error came from `graph.go:398-400`, a doc comment stating the three-tier
order that the function four lines below does not implement. This document
repeated the comment instead of reading the code — a comment asserting
behaviour nobody built, propagated into a decision record, which is the failure
RFC 0001 exists to catch arriving in a code comment. git-zhi's ADR 0003 states
the first tier only and is correct; an earlier version of this paragraph said
otherwise and was wrong to.

Ownership is recorded on every state change: `issue edit --state` appends a
transition whose actor is `actor.DeriveActor(Store.AuthorInfo())`, derived from
git's `user.name` and `user.email`.

That derivation is where it breaks. Every agent working in one repository
inherits the same git author config, so `DeriveActor` returns an identical
actor for all of them. The three rules above then collapse:

- Step 1 makes every agent "resume" whatever any agent started.
- Step 2 excludes nothing, because no other worker is ever *other*.

Worktree isolation does not help, and it is weaker than a worktree anyway.
`crochet:execute` *prefers* a worktree
per agent, for the separate reason that agents sharing a git index sweep each
other's files into the wrong commits. A worktree gives an agent a private
index; it does not give it a private identity, because `user.name` and
`user.email` come from repository or global config.

The visible symptom is elsewhere, which is why this was misread at first.
`crochet:execute` selects work with `git zhi list --milestone <name> --ready`,
which has no assignee filter, rather than `git zhi next --actor <id>`, which
applies all three rules above. That query is wrong and is corrected here, but
correcting it alone changes nothing: with every actor identical, the
actor-aware path returns the same answer as the global one.

## Proposal

### Identity resolves from the environment first

A transition's actor is resolved in order:

1. an explicit `--actor` flag, on the commands that have one
2. the `ZHI_ACTOR` environment variable
3. `DeriveActor(AuthorInfo())`, as today

Note the first entry's scope. ADR 0003 places the flag above the variable but
adds it to no new command, and `git zhi issue edit` has none — so on the write
path, where transitions are recorded, `ZHI_ACTOR` *is* the top of the order.

A worker is a process, and a process already has a per-instance identity
mechanism. `ZHI_ACTOR=agent:k7f2-3` isolates exactly, mutates no repository
state, and needs no git extension — `git config --worktree` would require
enabling `extensions.worktreeConfig`, which makes `core.bare` and
`core.worktree` per-worktree for every consumer of the repo. That is a large
blast radius for an identity string.

The value is `type:id`. `actor.ParseActor` already recognises `agent:` and
`human:`, and defaults a bare string to human — but git-zhi ADR 0003 refuses a
bare string at this boundary rather than defaulting it, and that is the right
call. The leniency is load-bearing for values already stored and for flags; at
the point a *new* identity enters the system it would record agents as humans,
silently. That is the fail-open shape of today's four sensors, arriving at a
trust boundary, which is the one place guessing is expensive. Agents state what
they are rather than being inferred from whether an email address contains
"agent" or "bot".

No config key is added. A `zhi.actor` key would cover a persistent worker
configured once, and every worker this decision describes is minted per run and
dies with its worktree. A third source is a precedence rule to document and a
"which one won?" question in every later debugging session, added before anyone
needs the second one. The `zhi.*` namespace is the natural home if a persistent
worker ever appears.

The fallback preserves current behaviour exactly. With nothing set, single
worker use is unchanged and no existing chain changes meaning.

**Identity is not commit authorship.** The alternative — giving each agent its
own `user.name` and `user.email` — needs no tool change at all, and is
rejected: it attributes the author's work to invented agents permanently, in
blame, `git log` and contributor statistics. Chain identity and commit identity
are different facts, and git already keeps them in separate places.

**Identity is fixed for the life of a worker — by crochet's discipline, not by
git-zhi's guarantee.** An earlier draft claimed the tool enforced this. It does
not, though not for the reason a second draft gave either. That draft said
`--actor` lets any invocation declare a different identity; on the write path
there is no such flag. What the tool actually lacks is any binding between a
process and an identity: `ZHI_ACTOR` is an environment variable, and a worker
can re-export it between commands as easily as it can set it once.

So the constraint moves to this side. `crochet:execute` exports the identity
once **at dispatch**, not at worktree creation. That distinction matters:
`execute.md:109-118` offers two fallbacks when a worktree is unavailable —
partition by repository, or share a branch with narrowly staged paths. A worker
taking either fallback has no worktree-creation step to mint an identity in,
would fall back to `DeriveActor`, and the collapse this decision diagnoses
would recur for exactly that worker. Minting at dispatch covers every path. A
worker
that renames itself mid-run makes the transition log unreliable as a record of
who did what — and nothing in the tool prevents that. The orchestrator does.

**Breaking it costs a stranded issue, not bad data.** Worth stating, because
the failure is survivable and that is not obvious from the rule. A worker that
renames itself mid-run fails `headForActor` step 1 against its own in-progress
issue, since the last transition names the identity it abandoned. Step 2 then
places that issue in the set held by *other* workers, so it is excluded from
the new identity and from everyone else — only the abandoned identity can
resume it. The transitions stay a truthful record of what each declared
identity did. The cost is one issue the *scheduler* will not surface —
`next` skips it for everyone — but not one that is lost: transitions carry no
actor check, so `git zhi issue edit <id> --state resume` by any caller recovers
it. Observed on 0.5.2. Verified against `graph.go:402-418`.

### The execute loop

`crochet:execute` selects work with `git zhi next` — bare, with `ZHI_ACTOR`
exported. Not `next --actor`. ADR 0003 makes the resolved identity the default
for `next --actor`, and warns that passing the flag on `next` while the write
path reads the environment is exactly the split-identity failure this decision
exists to remove. Identity is declared once, for the process, not per command.

The absent assignee filter on `git zhi list` stops mattering rather than being
added.

**But `next` is not yet a correct query, and that is a blocking dependency this
document did not name.** `headForActor` step 2 builds a sub-graph from the
issues not held by other workers (`graph.go:424-434`); the excluded issue's
edges leave with it, and `ReadySet` treats a missing upstream as satisfied
(`graph.go:319-322`). Observed on 0.5.2: with A in progress under one actor and
B depending on A, `git zhi next --actor agent:other` logs `references
nonexistent upstream ... (skipped)` and returns B — printing "Blocked by: A"
as it does so — and `issue edit <B> --state start` then succeeds. Two workers
end up on an issue and its unfinished dependency.

Single-actor use never exercises the filtered sub-graph, so this is only
reachable once the identity work ships. It must be fixed in git-zhi before
crochet selects work this way.

Identity is minted where the worktree is created — `agent:<run-id>-<n>`,
where `<run-id>` is a short opaque token generated per execute invocation.
There is nothing to keep in sync and it dies with the worktree.

**The run id must not be derived from the milestone name.** An earlier draft
used `agent:<milestone>-<n>`, which the reclamation rule below would have
matched as a prefix. This repository holds milestones `rfc-0001` and `rfc-0001-followups`,
so a run for the first would match `agent:rfc-0001-followups-2` and clear
another run's assignments. That is the same defect as `git zhi list
--milestone` ignoring its filter, found and fixed in git-zhi 0.5.2 on the day
this was written — which I first reported as a prefix match and it was not; the
filter was not applied at all. The collision risk in a milestone-derived worker
id is real on its own evidence and does not need the analogy. An opaque token also gives two sequential runs on one
milestone distinct id spaces, so the second clears the first's stale
assignments instead of adopting them.

Fan-out is not specified here. `crochet:execute` already delegates agent
coordination and result collection to `superpowers:dispatching-parallel-agents`,
and that contract is unchanged.

`headForActor` reports `no actionable issues for actor <id>` only when *every*
issue in the chain is in progress under another worker (`graph.go:431`);
otherwise the plainer `no actionable issues` comes back from `headGlobal`. And
per the blocking dependency above, "all remaining work is blocked by others"
does not error at all today — it returns the blocked issue.

Execute should treat either string as *this worker is finished*. It cannot
currently distinguish that from *all remaining work is blocked*, because the
tool does not make the distinction; the blocking dependency above is what would
restore it.

### Assignment is a hint

`Assigned` expresses intent. Ownership is the actor on the in-progress
transition.

**And the hint is weaker than it looks.** Step 3 prefers an issue assigned to
the asking worker; it does nothing about an issue assigned to a *different*
one, because `headGlobal` never reads `Assigned`. So an assignment attracts its
own worker and repels nobody. That is enough for the orchestrator's purposes —
it assigns to steer, not to reserve — but it is not the three-tier ordering an
earlier draft described.

Two things assign. A human assigns durably. The orchestrator assigns as
dispatch bookkeeping. They must not fight, so **the orchestrator assigns only
issues that are currently unassigned**, and never dispatches an agent for an
issue assigned outside its own worker set. Assigning an issue to yourself
therefore removes it from the orchestrator's pool, which is the behaviour a
reader would expect.

A run that dies leaves issues assigned to workers that no longer exist. They
are not blocked, and — contrary to an earlier draft — `headForActor` does not
deprioritise them either. The starvation is crochet's own doing: the
orchestrator assigns only issues that are currently unassigned, so an issue
still bearing a dead run's token is permanently outside the pool it draws from.
A failure that looks like nothing wrong, caused by this decision's own rule
rather than by the scheduler.
The opaque token closes this without a registry, a heartbeat or a lease: worker
ids carry the run's own opaque token, so **execute clears assignments bearing
a token that is not its own at start-up**. A human's `human:perigrin`, or an
`agent:git-zhi`, never matches and is never touched.

### `wip_limit` is already correct

`config.wip_limit` caps issues in progress across the chain. `headForActor`
enforces per-worker WIP of one independently, at step 1. The two compose: N
workers, one issue each, capped globally. Nothing is added; execute reads
`wip_limit` and dispatches no more workers than it permits, which makes the
existing setting a parallelism throttle.

### Non-goals

**Independent workers** — separate `crochet:execute` invocations against one
chain — are out of scope. `next --actor` returns a pending issue and nothing is
recorded until `--state start` writes a transition, so two self-selecting
workers can be handed the same issue in that window. Transitions are a
read-modify-write on a ref with no compare-and-swap, so a correct independent
mode needs a claiming protocol. Nothing today needs one: execute is an
orchestrator, and an orchestrator is a single serialisation point with no race
to solve. If independent execution becomes real, the failure becomes
observable and can be designed against then.

**Identity is for coordination, never authorization.** A declared identity is
unverified: `ZHI_ACTOR=agent:someone-else` is accepted as given, and it should
be — the field exists so workers can avoid each other's work, not so anything
can decide what a worker may do. If a crochet skill ever reads an actor to gate
a capability, that is a bug in crochet.

git-zhi's ADR 0003 records the same rule on its side of the seam. Stating it in
both places is deliberate: a field that looks like identity attracts the
assumption, and two independent statements are what make it a convention rather
than a coincidence.

**Cross-repo assignment** is out of scope, but not for the reason an earlier
draft of this document gave. That draft implied the machinery did not exist. It
does: `git-zhi-project` reads a YAML file describing multiple git-zhi repos and
computes a cross-repo critical chain, CCPM buffers and per-worker
recommendations, and `git zhi project next <file> --actor <worker>` is a
cross-repo next-issue recommendation for a named worker.

So the honest non-goal is narrower: **crochet does not use the project layer,
and this decision does not change that.** Each repository keeps its own chain,
and an issue whose work happens elsewhere is modelled as an environmental
precondition with a probe for an acceptance criterion. Whether crochet should
drive `git zhi project` is a real question and its own decision.

Note what that layer implies for this one. `--actor` is *required* on
`git zhi project next`. The cross-repo layer cannot be used at all without
distinct worker identity, so the gap this decision closes is not only blocking
parallel execution inside one repository — it is blocking the multi-repo layer
from being reachable.

Crochet names `git zhi project` exactly once across thirteen skills, at
`skills/report/report.md:31`, which until recently named a `project report`
subcommand which does not exist; the binary offers `next` and `show`. An
unused layer and a false claim about it are the same finding wearing two faces.

## Scope of Change

Two changes in git-zhi, sequenced, then three here. Locations are given
because a decision that names a symptom without naming where the work lands
decomposes into a plausible chain that fixes the reported half.

**git-zhi, first: the exclusion defect.** `ReadySet` treats a dangling upstream
as satisfied — `internal/graph/graph.go:318-321`, the `if !ok { continue }` —
and `headForActor` feeds it a sub-graph built from filtered input at
`graph.go:424-434`. Filter the ready set rather than the input, so the graph
keeps every issue and blockers outside the filter still constrain readiness.

*The part not visible from the symptom:* `headForActor` ends
`return sub.headGlobal()` (`graph.go:446`). Fixing `ReadySet` leaves that call
resolving over a graph the exclusion must be threaded through separately, or it
returns an issue held by another worker. A fix that addresses only the
reproduction ships half the defect.

git-zhi's own `docs/contributing/coding-conventions.md` already states the rule
this violates: anything derived from the graph comes back unfiltered, and every
display filter has to be re-applied to it.

**git-zhi, second: the identity.** Resolve the transition actor from
`ZHI_ACTOR`, falling back to `DeriveActor(AuthorInfo())`. The two write sites
are `internal/cli/issue_edit.go:300-301` and `:1534-1535`. Refuse a value
carrying no `agent:`/`human:` prefix rather than defaulting it, per git-zhi
ADR 0003. Sequenced second because it is what makes the first defect reachable:
single-actor use never exercises the filtered sub-graph.

Neither is crochet's to write. Both are named here rather than assumed, and
the floor in `.claude-plugin/plugin.json` moves once when they ship.

**`skills/execute/execute.md`.** Select with bare `git zhi next`, identity
supplied by the environment. Mint `ZHI_ACTOR` **at dispatch**, not at worktree
creation — `execute.md:109-118` only *prefers* a worktree and offers two
fallbacks, and a worker taking either would otherwise fall back to
`DeriveActor`. Assign only unassigned issues; at start-up clear assignments
bearing an opaque run token that is not this run's; dispatch no more workers
than `wip_limit` permits, read via `git zhi config --format json`. Treat both
`no actionable issues for actor <id>` and the plainer `no actionable issues` as
completion — the tool does not currently distinguish finished from
all-blocked, and the exclusion fix above is what would restore that.

**`skills/how-to-use-git-zhi/how-to-use-git-zhi.md`.** Document `ZHI_ACTOR` and
the resolution order, and add the actor-aware row to the intent table.

**`xt/zhi-actor-probe.sh`.** A probe asserting the installed binary honours
`ZHI_ACTOR`: initialise a scratch repository, create and start an issue under a
known actor, and assert the recorded transition actor matches. Multi-step setup
belongs in a script rather than an acceptance criterion.

### Acceptance Criteria

- [ ] the installed binary honours ZHI_ACTOR (`sh xt/zhi-actor-probe.sh`)
- [ ] execute selects with bare next, not the flag (`grep -q 'git zhi next' skills/execute/execute.md && ! grep -q 'next --actor' skills/execute/execute.md`)
- [ ] execute no longer selects from the ready set (`! grep -q 'list --milestone .* --ready' skills/execute/execute.md`)
- [ ] execute mints a worker identity (`grep -q 'ZHI_ACTOR' skills/execute/execute.md`)
- [ ] the command reference documents the identity variable (`grep -q 'ZHI_ACTOR' skills/how-to-use-git-zhi/how-to-use-git-zhi.md`)

## Open Questions

- Whether clearing own-pattern assignments at start-up is the right recovery,
  or whether the orchestrator should unassign as each issue completes. The
  first survives a crash and the second does not, which is why it is proposed;
  neither has been run.

## References

- `0001-documentation-architecture.md`. The series, and the pattern of naming a
  tool dependency rather than assuming it.
- `internal/graph/graph.go` in git-zhi, `Graph.headForActor`. The scheduling
  this decision makes reachable.
- `internal/actor/actor.go` and `internal/cli/issue_edit.go` in git-zhi. Where
  a transition's actor is derived today.
- `git-zhi-project` in git-zhi, `next --actor`. The cross-repo layer that
  distinct worker identity is a precondition for.
