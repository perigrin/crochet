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
3. Otherwise pick from the ready set, preferring issues assigned to this actor
   over unassigned ones over issues assigned to somebody else.

Ownership is recorded on every state change: `issue edit --state` appends a
transition whose actor is `actor.DeriveActor(Store.AuthorInfo())`, derived from
git's `user.name` and `user.email`.

That derivation is where it breaks. Every agent working in one repository
inherits the same git author config, so `DeriveActor` returns an identical
actor for all of them. The three rules above then collapse:

- Step 1 makes every agent "resume" whatever any agent started.
- Step 2 excludes nothing, because no other worker is ever *other*.

Worktree isolation does not help. `crochet:execute` already requires a worktree
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

1. the `ZHI_ACTOR` environment variable
2. the `zhi.actor` git config key
3. `DeriveActor(AuthorInfo())`, as today

A worker is a process, and a process already has a per-instance identity
mechanism. `ZHI_ACTOR=agent:rfc-0001-3` isolates exactly, mutates no repository
state, and needs no git extension — `git config --worktree` would require
enabling `extensions.worktreeConfig`, which makes `core.bare` and
`core.worktree` per-worktree for every consumer of the repo. That is a large
blast radius for an identity string.

The value is `type:id`, which `actor.ParseActor` already accepts: `agent:` and
`human:` are recognised, and a bare string defaults to human. Agents therefore
state what they are, rather than being inferred from whether an email address
contains "agent" or "bot".

The `zhi.actor` key covers what an environment variable serves badly: a
persistent worker configured once. It sits in the `zhi.*` namespace already
established by `zhi.sync.jira.actor.<name>`.

The fallback preserves current behaviour exactly. With nothing set, single
worker use is unchanged and no existing chain changes meaning.

**Identity is not commit authorship.** The alternative — giving each agent its
own `user.name` and `user.email` — needs no tool change at all, and is
rejected: it attributes the author's work to invented agents permanently, in
blame, `git log` and contributor statistics. Chain identity and commit identity
are different facts, and git already keeps them in separate places.

**Identity is fixed for the life of a process.** `AuthorInfo()` returns values
captured when the Store is created, and `ZHI_ACTOR` is read the same way. A
worker cannot change who it is mid-run. This is a constraint worth choosing: a
worker that can rename itself makes the transition log unreliable as a record
of who did what.

### The execute loop

`crochet:execute` selects work with `git zhi next --actor <id>`. The absent
assignee filter on `git zhi list` stops mattering rather than being added;
`next --actor` was always the correct query.

Identity is minted where the worktree is created — `agent:<milestone>-<n>`,
exported into that agent's environment. The id is derived, so there is nothing
to keep in sync and it dies with the worktree.

Fan-out is not specified here. `crochet:execute` already delegates agent
coordination and result collection to `superpowers:dispatching-parallel-agents`,
and that contract is unchanged.

`headForActor` reports `no actionable issues for actor <id>` rather than an
empty set. Execute treats this as *this worker is finished*, which is distinct
from the existing case of open issues that are all blocked.

### Assignment is a hint

`Assigned` expresses intent. Ownership is the actor on the in-progress
transition. Step 3 above deprioritises another actor's issues; it does not
exclude them.

Two things assign. A human assigns durably. The orchestrator assigns as
dispatch bookkeeping. They must not fight, so **the orchestrator assigns only
issues that are currently unassigned**, and never dispatches an agent for an
issue assigned outside its own worker set. Assigning an issue to yourself
therefore removes it from the orchestrator's pool, which is the behaviour a
reader would expect.

A run that dies leaves issues assigned to workers that no longer exist. They
are not blocked, but every later run deprioritises them, so other available
work can starve them indefinitely — a failure that looks like nothing wrong.
The derived id closes this without a registry, a heartbeat or a lease: worker
ids match `agent:<milestone>-<n>`, so **execute clears assignments matching its
own id pattern at start-up**. A human's `human:perigrin`, or an
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

**Cross-repo assignment** is out of scope. An issue whose work happens in
another repository is modelled as an environmental precondition with a probe
for an acceptance criterion, not as an assignment or a cross-chain dependency
edge. Each repository keeps its own chain.

## Scope of Change

**git-zhi.** Resolve the transition actor from `ZHI_ACTOR`, then `zhi.actor`,
then `DeriveActor(AuthorInfo())`. This is the dependency this decision cannot
satisfy alone, named here rather than assumed.

**`skills/execute/execute.md`.** Select with `git zhi next --actor <id>`; mint
`ZHI_ACTOR` when creating each agent's worktree; assign only unassigned issues;
clear assignments matching the run's own id pattern at start-up; dispatch no
more workers than `wip_limit` permits; treat `no actionable issues for actor`
as completion.

**`skills/how-to-use-git-zhi/how-to-use-git-zhi.md`.** Document `ZHI_ACTOR` and
the resolution order, and add the actor-aware row to the intent table.

**`xt/zhi-actor-probe.sh`.** A probe asserting the installed binary honours
`ZHI_ACTOR`: initialise a scratch repository, create and start an issue under a
known actor, and assert the recorded transition actor matches. Multi-step setup
belongs in a script rather than an acceptance criterion.

### Acceptance Criteria

- [ ] the installed binary honours ZHI_ACTOR (`sh xt/zhi-actor-probe.sh`)
- [ ] execute selects with the actor-aware query (`grep -q 'next --actor' skills/execute/execute.md`)
- [ ] execute no longer selects from the ready set (`! grep -q 'list --milestone .* --ready' skills/execute/execute.md`)
- [ ] execute mints a worker identity (`grep -q 'ZHI_ACTOR' skills/execute/execute.md`)
- [ ] the command reference documents the identity variable (`grep -q 'ZHI_ACTOR' skills/how-to-use-git-zhi/how-to-use-git-zhi.md`)

## Open Questions

- Whether `zhi.actor` earns its place. `ZHI_ACTOR` alone covers every worker
  this decision describes, and the config key exists for a persistent worker
  nobody has asked for yet. It is the part of this proposal most likely to be
  unnecessary.
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
