---
title: Worker identity
state: accepted
author: Chris Prather
date: 2026-09-18
supersedes: []
superseded-by: []
---

# 0002: Worker identity

git-zhi implements per-worker scheduling completely. Crochet cannot use any of
it, because every agent working in a repo resolves to the same actor. The fix
is one identity, not a scheduler.

**Accepted without a chain.** Refinement normally writes this field while
decomposing the decision into issues, and that is the path this repository
should take. It was not taken here: the work was implemented directly, and the
commits carrying `Implements: 0002` are the evidence that it was decided on.
Acceptance is the decision that the work should be done; the chain is how that
decision is normally expressed and executed, not what makes it true.

What was lost by skipping it is the execution record rather than the decision —
no milestone, so no verify gate over these criteria, no sanbao metrics, and no
postmortem. Recorded here because a repository that shows only the outcome
makes the bypass look like the ordinary path.

## Problem Statement

`Graph.headForActor` already does the work multi-worker execution needs:

1. If the actor has an in-progress issue, return it — per-worker WIP of one,
   and resumption after a restart.
2. Otherwise exclude issues in progress whose last transition names a
   *different* actor — mutual exclusion.
3. Otherwise return a ready issue assigned to this actor, if there is one.

An earlier draft of this document claimed a third preference — assigned-to-me,
then unassigned, then assigned-to-another. **Only the first tier exists.**
`headForActor` prefers a candidate whose `Assigned` matches the asking actor,
and otherwise takes the first candidate on the critical chain — an ordering
that never reads `Assigned`. An issue assigned to a different worker is picked
exactly as readily as an unassigned one. Observed on 0.6.0: with one ready
issue assigned to `agent:someone-else`, bare `next` as `agent:me` returns it.

The error came from a doc comment above `headForActor` stating a three-tier
order the function below did not implement. This document repeated the comment
instead of reading the code — a comment asserting behaviour nobody built,
propagated into a decision record, which is the failure RFC 0001 exists to
catch arriving in a code comment. git-zhi's ADR 0003 states the first tier only
and is correct; an earlier version of this paragraph said otherwise and was
wrong to. git-zhi rewrote that comment in 0.6.0; it now states what the code
does, including that assignment is "a preference for its own actor, not an
exclusion.

Ownership is recorded on every state change: `issue edit --state` appends a
transition naming whoever the process resolved itself to be. Through 0.5.2 that
was `actor.DeriveActor(Store.AuthorInfo())` and nothing else — derived from
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

Note the first entry's scope. ADR 0003 places the flag above the variable
without saying which commands should have one; git-zhi's **ADR 0004 settles it**
— no write command takes `--actor`, and the flag stays on `next` and
`project next`, both read-side. So on the write path, where transitions are
recorded, `ZHI_ACTOR` *is* the top of the order, and by commitment rather than
by oversight.

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
`--actor` lets any invocation declare a different identity; ADR 0004 has since
settled that no write command will ever take that flag, so a worker cannot
rename itself by passing one. What the tool lacks is any binding between a
process and an identity: `ZHI_ACTOR` is an environment variable, and a worker
can re-export it between commands as easily as it can set it once.

So the constraint moves to this side, and it is a narrow one — re-exporting is
the only way to break it, and the orchestrator owns the environment it
dispatches into. `crochet:execute` exports the identity once **at dispatch**,
not at worktree creation. That distinction matters: the execute loop only
*prefers* a worktree, and offers two fallbacks when one is unavailable —
partition by repository, or share a branch with narrowly staged paths. A worker
taking either fallback has no worktree-creation step to mint an identity in,
would fall back to the git-author derivation, and the collapse this decision
diagnoses would recur for exactly that worker. Minting at dispatch covers every
path.

**Breaking it costs a stranded issue, not bad data.** Worth stating, because
the failure is survivable and that is not obvious from the rule. A worker that
renames itself mid-run fails `headForActor` step 1 against its own in-progress
issue, since the last transition names the identity it abandoned. The issue
then lands in the set held by *other* workers, excluded from the new identity
and from everyone else. The transitions stay a truthful record of what each
declared identity did.

Recovery splits in two, and an earlier draft of this paragraph collapsed them.
**Selection is identity-gated; transitions are not.**

Only the abandoned identity gets the issue back from `next` — it matches step 1,
and every other worker is told `no actionable issues for actor`. Since the
orchestrator minted that token, it is the one party that can re-surface the
issue to the scheduler.

Any caller can transition it, though, because transitions carry no actor check.
Observed on 0.6.0, with work committed: `--state done` succeeds from a foreign
identity, as does `--state cancel`, and `--state done --force` covers the case
where the session recorded no commits. What does *not* work for anyone is
`--state resume`, refused with `a measurement session is already open` — an
in-progress issue has an open session by definition, so this was never the
recovery verb, on this version or any earlier one.

Note what the commit guard is not. `cannot mark done: session has 0 commits`
looks like a stranding symptom and is not: a healthy worker completing its own
issue with nothing committed gets the same refusal. It measures work, not
identity, and reading it as an identity failure is a confound worth naming
because this document already made the opposite error once.

So the cost is one issue the *scheduler* will not surface to anyone but its
original worker — not one that is stuck, since any caller can still close or
cancel it.

### The execute loop

`crochet:execute` selects work with `git zhi next` — bare, with `ZHI_ACTOR`
exported. Not `next --actor`. ADR 0003 makes the resolved identity the default
for `next --actor`, and warns that passing the flag on `next` while the write
path reads the environment is exactly the split-identity failure this decision
exists to remove. Identity is declared once, for the process, not per command.

The absent assignee filter on `git zhi list` stops mattering rather than being
added.

**`next` was not a correct query when this was written, and that was a blocking
dependency this document did not name at first.** `headForActor` built a
sub-graph from the issues not held by other workers; the excluded issue's edges
left with it, and `ReadySet` treats a missing upstream as satisfied. Observed
on 0.5.2: with A in progress under one actor and B depending on A,
`git zhi next --actor agent:other` logged `references nonexistent upstream ...
(skipped)` and returned B — printing "Blocked by: A" as it did so — and
`issue edit <B> --state start` then succeeded. Two workers on an issue and its
unfinished dependency.

**Fixed in git-zhi 0.6.0**, which is why the floor moves there. Readiness is
now computed against the whole graph and the exclusion applied to the result,
so a held issue still blocks its downstream. Observed on 0.6.0: the same
reproduction returns `no actionable issues for actor agent:other` instead of
handing B over.

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

`headForActor` reports `no actionable issues for actor <id>` whenever it has no
candidate — whether the chain is finished, held entirely by other workers, or
blocked behind work they hold. An earlier draft said the plainer
`no actionable issues` came back from `headGlobal` in some of those cases; on
0.6.0 `headForActor` never falls through to `headGlobal`, so the actor-specific
string is the one execute sees.

Execute treats it as *this worker has nothing to do*, which is not the same as
*the chain is finished* — and the tool still does not distinguish them. Matching
both strings costs nothing and survives either behaviour, so execute matches
both.

### Assignment is a hint

`Assigned` expresses intent. Ownership is the actor on the in-progress
transition.

**And the hint is weaker than it looks.** `headForActor` prefers a candidate
assigned to the asking worker; it does nothing about one assigned to a
*different* worker, because the fallback ordering — position on the critical
chain — never reads `Assigned`. So an assignment attracts its own worker and
repels nobody. That is enough for the orchestrator's purposes —
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
deprioritise them either; git-zhi's own doc comment now says so, calling
assignment "a preference for its own actor, not an exclusion". The starvation is crochet's own doing: the
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

Note what that layer implies for this one. `git zhi project next` cannot run
without a worker identity — through 0.5.2 it required `--actor`, and on 0.6.0
it accepts `ZHI_ACTOR` in the flag's place but still refuses to run with
neither. The cross-repo layer was therefore unreachable for the same reason
parallel execution inside one repository was, and the identity work unblocks
both.

Crochet names `git zhi project` exactly once across thirteen skills, in
`skills/report/report.md`, which until recently named a `project report`
subcommand that does not exist; the binary offers `next` and `show`. An unused
layer and a false claim about it are the same finding wearing two faces.

## Scope of Change

Two changes in git-zhi, which have shipped, then three here, which have not.

**The git-zhi half, done in 0.6.0.** Both were named here rather than assumed,
and both landed: `headForActor` now computes readiness against the whole graph
and applies the exclusion to the result, so a held issue still blocks its
downstream; and the transition actor now resolves from `ZHI_ACTOR` before
falling back to the git-author derivation, refusing a value that carries no
`agent:`/`human:` prefix. The second was the one that made the first reachable —
single-actor use never exercises the exclusion at all.

Two consequences for this document. The floor in `.claude-plugin/plugin.json`
moves to **0.6.0**, which is the version every claim above was re-observed
against. And git-zhi's **ADR 0004** settled the question this decision was
written around: no write command takes `--actor`, so identity on the write path
is the environment and nothing else.

`xt/run.sh` holds that floor honest from this side, by comparing the declared
`git_zhi_min_version` against the version the installed binary reports.

**`skills/execute/execute.md`.** Select with bare `git zhi next`, identity
supplied by the environment. Mint `ZHI_ACTOR` **at dispatch**, not at worktree
creation — the loop only *prefers* a worktree and offers two fallbacks, and a
worker taking either would otherwise fall back to the git-author derivation.
Assign only unassigned issues; at start-up clear assignments bearing an opaque
run token that is not this run's; dispatch no more workers than `wip_limit`
permits, read via `git zhi config --format json`. Treat both
`no actionable issues for actor <id>` and the plainer `no actionable issues` as
this worker having nothing to do — the tool does not distinguish finished from
all-blocked, and matching both strings survives either behaviour.

**`skills/how-to-use-git-zhi/how-to-use-git-zhi.md`.** Document `ZHI_ACTOR` and
the resolution order, and add the actor-aware row to the intent table.

**A probe of the installed binary's `ZHI_ACTOR` handling** was written for this
decision and has since been removed. It initialised a scratch repository,
created and started an issue under a known actor, and asserted the recorded
transition actor matched.

It was deleted because its subject was git-zhi's behaviour rather than this
repository's, which is git-zhi's own test suite's job, and because the floor
comparison in `xt/run.sh` covers the version-skew case it was written for. What
this repository can hold honest is the floor it declares; what the binary does
above that floor is held honest where the binary lives.

### Acceptance Criteria

**Removed, 2026-09-21.** This section carried five runnable commands, and a
decision does not carry those. It states what must be true; the milestone
refinement creates from it holds the commands that check it, which is the
division `docs/decisions/0003-acceptance-by-refinement.md` settles and
`docs/contributing/coding-conventions.md` records.

One of the five showed why. Its subject was git-zhi's handling of `ZHI_ACTOR` —
another repository's behaviour — so no work here could ever have turned it green
or red, and when the probe it named was deleted it became permanently
unrunnable with nothing detecting it. A cross-repository dependency belongs in
`git_zhi_min_version`, which `crochet:preflight` enforces and `xt/run.sh` now
compares against the installed binary: a claim this repository can check.

The other four asserted that `skills/execute/execute.md` and
`skills/how-to-use-git-zhi/how-to-use-git-zhi.md` say what the Scope of Change
above says they should. That is still required. It is simply not this document's
job to hold the command that checks it.

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
