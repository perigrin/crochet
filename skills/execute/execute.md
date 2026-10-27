---
name: execute
description: Drive the full SDLC execution loop — pick issues from the DAG, run TDD with review gates, close issues, complete milestone
---

## Prerequisites

Invoke `crochet:preflight` as the first action. It ships in this plugin, so it
is always present — it is not one of the optional integrations below. It checks
git-zhi availability and returns the capabilities map used for every
conditional reference in this skill.

# crochet:execute

Replaces `superpowers:executing-plans` for git-zhi workflows. Drives execution
from the chain itself rather than a markdown plan file.

## Trigger

Chain exists (output of `crochet:refinement`), user says "execute", "build this",
or "start working."

## Input

A milestone name (e.g., `v0.3.4`). If omitted, use `git zhi milestone list --format json`
to find the active milestone (state != completed).

`--step` is the only flag: it asks for confirmation before each issue.
Without it, execution runs straight through — see Loop control in Step 2.

## Process

### Step 1: Load Chain State

```bash
git zhi milestone show <milestone> --format json
git zhi list --milestone <milestone> --format json
```

Count open issues. If zero, skip to Step 5 (completion).

### Step 2: Pick Next Issue

#### Loop control — decide this here, every time

This is where the loop re-enters, so the rule lives here rather than in Key
Constraints where it is too far away to be read at the moment it applies.

**Continuing is the default.** Pick the next ready issue and keep going in the
same turn. Only `--step` changes this, and then you confirm before each issue.

Running through is the default because the pause was never what made this
safe. The gates are the acceptance criteria, the dependency graph and the
review at Step 4. A human approving each issue in turn is not review, and
asking again re-litigates a decision already made: invoking this skill was the
go-ahead, the same way asking for refinement is what accepts a proposal.

**Ending your turn is a pause.** Reporting progress, summarising a finding or
narrating what just happened all end the turn, and that is exactly what the
default forbids. There is no difference between stopping to ask a question and
stopping to talk — the user has to prompt you again either way.

The urge to report is not a reason to stop. Progress is already visible in the
chain: `git zhi list --milestone <name>` and `git zhi milestone show <name>`
show it without you in the loop. Anything worth saying keeps until the end.

**Escalating is also pausing, and it will not feel like it.** The other way
this rule gets broken is not narration but a judgment call that seems to belong
to the user — a design choice, a naming decision, a question about intent. From
the inside that feels like escalating rather than stopping, so a rule about
pausing does not seem to apply, and you can quote this paragraph while doing it.

The test is not how important the question feels. It is: **can I settle this
myself?** Usually yes, and usually faster than writing the paragraph explaining
why you could not. Measure it, read the code, run the command. Escalate when
the answer genuinely is not in the repository — a preference only the user
holds, or an action they have not authorised.

**Default does not mean never stop.** It means no routine pause between
issues. Stop when one of these is true:

- the ready set is empty;
- every remaining issue is blocked by an unfinished one;
- a permission was denied, or a tool refused the action;
- an acceptance criterion fails and you cannot make it pass;
- a decision is genuinely the user's — a deletion they have not approved, or
  work that belongs to another repo or another session.

Then report once, covering everything.

No check enforces this. It is a rule about what an agent chose to do, and
nothing recovers that from the repository afterwards — so it is placed where
the decision is made, which is the honest ceiling for a rule of this kind.


#### Worker identity — once per run, before any dispatch

Every agent in one repository inherits the same git author config, so without
this they all resolve to the same actor: each "resumes" whatever another
started, and mutual exclusion excludes nothing. Mint an opaque id for this
run — `<run-id>`, a few random characters — and set the worker's token as a
prefix on **each `git zhi` command** it runs:

```bash
ZHI_ACTOR=agent:<run-id>-<n> git zhi next
```

Not an `export`. An agent harness runs each shell command as its own process,
so an export does not survive to the next command, and the worker would fall
back to the git author — the collapse above, for exactly that worker. Setting
the same token on every command is still one declaration of identity: the read
side and the write side resolve the same actor, and nothing passes a different
one by flag. Give the token to the worker at each pick, not at worktree
creation; a worktree is only preferred below, and a worker taking
either fallback has no worktree step.

**Every pick gets a fresh `<n>`**, on the parallel and one-worker paths alike,
so a token names exactly one issue. A reused token is ruled out because `next`
resumes that token's earlier issue once it has been reopened, and returns it
instead of the new pick. That is still one identity per worker per issue, the
same on the read and write side. A reopen in Step 4 keeps the issue's own
token, so the reopened issue stays reachable by the worker that holds it.

Do not derive `<run-id>` from the milestone name. Milestones share prefixes
(`rfc-0001` and `rfc-0001-followups`), and the reclamation rule below would
match across them and clear another run's assignments.

Then reclaim what a dead run left behind:

- **Clear assignments bearing an `agent:` token that is not this run's** — one
  without this run's `agent:<run-id>-` prefix, since a run holds a token per
  pick rather than one. An issue still assigned to a worker that no longer
  exists is outside the pool, because the rule below only assigns unassigned
  issues. A `human:` value, or an `agent:` name that is not a run token, is
  never touched.
- **Assign only issues that are currently unassigned**, and never dispatch for
  an issue assigned outside this run's workers. Assigning an issue to yourself
  therefore removes it from the orchestrator's pool, which is what a reader
  would expect.

Assignment is a hint, not a lock: it attracts its own worker and repels nobody.
Ownership is the actor on the in-progress transition.

#### The pick — before every dispatch, on both paths

Workers do not choose their issue; the agent that orchestrates does, by
assigning. Before any worker calls `next`, it takes one issue from the
milestone's ready set and assigns it to the token that worker will use:

```bash
git zhi issue list --ready --milestone <milestone> --format json
git zhi list --critical --format json
git zhi issue edit <id> --assign agent:<run-id>-<n>
```

**Self-resume comes before any pick.** An agent told to continue mid-issue
first resumes the issue it already holds, under that issue's own token, before
picking anything new. When `next` under that token returns its own in-progress
issue, run no transition: `start` is refused on an issue already in progress,
and `--state resume` is refused while its session is open. Skip the stand-down
and the ownership check after start, and go straight back to Step 3. The one
exception is a paused issue, which takes `--state resume` before Step 3, because
its session is closed. A paused issue's `state` stays `in-progress`; only
`sessions[-1].ended_at` in `git zhi issue show <id> --format json` marks the
pause, so run `--state resume` only when the last session has one. A prior run's
in-progress issue is not self-resume: its token belongs to no live worker, which
is the dead-worker case and not this skill's selection.

**The pool.** The ready rule comes from the query, never computed by hand. Keep
only issues with no assignment: the ready JSON leaves the `assigned` field out
when nothing is assigned rather than setting it to null, so a missing
`assigned` field means unassigned, and any value at all — a `human:` one
included — takes the issue out of the pool, so an issue a human has assigned is
never picked. Query with `issue list --ready`, not bare `list --ready`: that
returns only each issue's `id` and `title` under `ready_set`, so the filter has
nothing to read and would dispatch human-assigned issues.

**The order.** Issues on the `critical_chain` key of `list --critical` come
first, in that key's order. Not the `issues` key, which is every issue in
creation order. The rest follow by `created` ascending, with equal values
broken by UUID, so two passes over the same pool never order it differently.
`critical_chain` can be null, or left out of the JSON altogether when no chain
is open; then every ready unassigned issue falls through to creation order.
Re-read the critical chain at every pick and never cache it from the first,
because the chain moves as issues close. No other ordering is used, so
`urgency` plays no part.

This has a recorded cost. `list --critical` reports the one repo-wide chain
and ignores `--milestone`, so when another milestone holds the chain none of
its issues is in the pool, and a milestone-scoped critical order is lost. Bare
`next` never offered one either. The cost goes away if git-zhi ships a
milestone-scoped `next` (perigrin/git-zhi#35). The JSON shapes above were
observed on 0.7.2.

**Who mints `<n>`.** On the parallel path the orchestrator mints a fresh `<n>`
at each pick and gives that token to the worker it dispatches for the issue. On
the one-worker path the agent is both orchestrator and worker: it mints the
`<n>` itself, at the pick that Step 4's return to this step re-enters, not in
the once-per-run identity block above.

`--step` goes through this same pick. Its confirmation is asked about the issue
the pick chose, after the pick, and is never a separate selection.

**If `superpowers:dispatching-parallel-agents` is available** (check preflight capabilities):
  Run the pick before each dispatch, and dispatch one agent per picked issue,
  each with the token its pick assigned. Dispatch no more workers than there
  are unassigned ready issues in the pool, and within `wip_limit`.

  Read the cap with `git zhi config --format json`:

  - **`wip_limit` above zero** — dispatch no more workers than it permits.
  - **`wip_limit` of zero means *no limit*, not *no workers***. It is the
    default in any repo that has not set one, so this is the common case.
    Dispatch by what the work and the machine can take.

  `wip_limit` caps issues in progress across the chain, and git-zhi enforces
  per-worker WIP of one independently, so the two compose into a parallelism
  throttle without anything being added. Follow the dispatching-parallel-agents
  skill for agent coordination and result collection.

  **Give each parallel agent its own git worktree.** Parallel agents that commit
  to the same repo and branch race on git's shared staging index — even with
  fully disjoint file scope. One agent's `git add`/`commit` can sweep another
  agent's staged files into the wrong commit, forcing soft-resets and
  serializing the work that parallelism was supposed to overlap. This directly
  conflicts with the "each agent commits its own changes, never squash"
  discipline (Step 3). To get true concurrency, isolate each agent:

  - **Preferred:** run each agent in its own git worktree (e.g. the Agent tool's
    `isolation: "worktree"`), so each has a private index; collect and integrate
    the branches after the agents finish.
  - **Or partition by repo** — if the ready issues touch different repositories,
    dispatch at most one agent per repo so no two share an index.
  - **If agents must share a branch** (no isolation available): instruct each to
    stage only its own paths (`git add -- <exact files>`, never `git add -A` or
    `git add .`) and to re-check `git status` immediately before committing,
    expecting to soft-reset and re-stage if another agent's files were swept in.

  Disjoint file scope is necessary but NOT sufficient for concurrent commits —
  index isolation is what makes parallel execution actually parallel.

**Otherwise:** one worker, which is its own orchestrator. It runs the pick,
works the picked issue with that pick's token set on each `git zhi` command, and
comes back to the pick when Step 4 returns here.

#### The hand-over — what each worker does with its pick

A worker is dispatched for one issue and handed that issue's full id along
with its token. It does not choose; the pick above already did, by assigning,
and `next` hands the assigned issue over:

```bash
git zhi next --format json
```

Bare, with **no actor flag**. The identity is already in the environment, and
passing it on the read side while the write side reads the environment is the
split-identity failure this exists to prevent. On 0.7.2, `next` returns the
asking worker's own assignment ahead of any other ready issue; with nothing
assigned to the worker, it returns some other ready issue, even one assigned to
someone else. That is why `next` confirms the pick rather than making it.

**The worker starts nothing unless `next` returns exactly that id.** "Assigned
to my token" is not the test: a reused token's earlier reopened issue passes it
too, and `next` returns that one first. If `next` returns any other issue, or
reports `no actionable issues for actor <id>` or the plainer
`no actionable issues`, the worker starts nothing, stands down and returns to
the orchestrator.

Read the id from the JSON `id` field, never from the text output. Text prints
an 8-character short id, and short ids collide for issues created together
(perigrin/git-zhi#37); on 0.7.2 two issues created a second apart printed the
same one.

Start the issue by its literal id:

```bash
git zhi issue edit <id> --state start
```

Never by an empty or unset variable. An empty ref is not an error on 0.7.2: it
resolves to HEAD, the repository's current issue, so a start with an empty id
acts on whatever issue that is.

**The ownership check, after every `--state start`.** Step 4's restart after a
reopen included. The start records a transition under `ZHI_ACTOR`, and the
check reads it back:

1. Wait a few seconds, then re-read the issue. Some agent harnesses block a
   foreground `sleep`, so do not use one: run the wait as a background
   command — in Claude Code, `sleep 5` with `run_in_background`, whose
   completion re-invokes the worker — and read the issue when it returns.

   ```bash
   git zhi issue show <id> --format json
   ```

2. The worker owns the issue when its `state` is `in-progress` **and** the
   latest transition's actor — the last entry of `transitions`, each of which
   carries `state`, `actor` and `timestamp` — is its own token. Both are
   needed. A start refused after Step 4's reopen, for `wip_limit` say, leaves
   the issue `reopened` with the worker as its latest transition's actor, so
   the actor alone would pass a start that never happened.

3. A read that fails, or returns something that is not the issue, is retried,
   and never counts as won or lost: it says nothing about who holds the issue.
   The retry is bounded at three reads. When it is exhausted, the worker stops
   and returns to the orchestrator saying the ownership of `<id>` is unknown.
   That is not a stand-down, and the stand-down's unassign does not run on it,
   because the worker may hold the issue; it is reported by name for a person
   to settle.

**A stand-down** is what a worker does when it does not own the issue it was
dispatched for: `next` returned something else, the start was refused, or the
check found another state or another actor. It runs no further transition on
the issue and returns to the orchestrator, saying which of those happened and
quoting git-zhi's refusal text when there was one. What the orchestrator does
next is the orchestrator's.

The check narrows git-zhi's concurrent-start window and does not close it
(perigrin/git-zhi#35). Two starts close enough together can both be recorded;
the check makes the loser see the winner's transition and back off, rather than
working an issue someone else holds. Within one run the pick already keeps two
workers off one issue, so what reaches the check is a start refused for
`wip_limit`, or an actor outside the run taking the issue.

### Step 3: Inner Loop (Execute Issue)

The inner loop drives TDD iteration per issue. When available, this uses a
Ralph Loop for automated iteration with completion detection.

Read the issue's full context:
```bash
git zhi issue show <id> --format json
```

Extract from the issue:
- Title and acceptance criteria (positive and negative scenarios)
- Context paths (files to read)
- Steps (implementation choreography if present)
- Review findings from prior PAAD passes (if issue was reopened)

**If `superpowers:test-driven-development` is available** (check preflight capabilities):
  Follow the `superpowers:test-driven-development` skill for the implementation cycle.
  Write a failing test first, then implement until it passes (red-green-refactor).
  Pass the issue's acceptance criteria as the definition of done.
  After tests pass, run: `/simplify` (code-simplifier on changed files).
  If simplifier finds issues, fix them and re-run tests.
  Commit frequently with descriptive messages.

**Otherwise:**
  Follow TDD manually: write a failing test for the next AC item, implement
  until it passes, then refactor. Repeat for each acceptance criterion.
  After tests pass, run: `/simplify` (code-simplifier on changed files).
  If simplifier finds issues, fix them and re-run tests.
  Commit frequently with descriptive messages.

**Max iterations safety valve:** If the issue did not converge after 10 passes:

**If `superpowers:systematic-debugging` is available** (check preflight capabilities):
  Invoke `superpowers:systematic-debugging` to diagnose why the issue is stuck
  before continuing.

**Otherwise:**
  Stop and report the blocker. Consider splitting the issue or clarifying the AC
  before retrying.

**Known issue: completion detection may fail** on long conversations where
the JSONL transcript contains unescaped control characters (see
[claude-plugins-official#760](https://github.com/anthropics/claude-plugins-official/issues/760)).
If execution does not terminate despite work being done, cancel manually and
verify completion by checking:
- `git log` for commits covering all AC
- `go test ./...` (or equivalent) for green tests
- The issue state — proceed to Step 3.5 if work is done

**Commit strategy:** Commit frequently with descriptive messages. Every iteration
should leave committed state so the next iteration can build on it. Do not
squash or amend — the commit history is the iteration history.

### Step 3.5: Sanbao Gate Analysis

After execution completes, close the issue and compute a sanbao snapshot
to determine review tier.

```bash
git zhi issue edit <id> --state done
git zhi sanbao <milestone> --format json
```

Sanbao operates at milestone scope. Extract the target issue's metrics from
the per-issue `difficulties[]` array and the `complexity` domain in the JSON
output.

**Run the gate analysis agent** with this prompt:

```
You are the gate analyst for crochet:execute. Given the sanbao metrics
for issue <id> ("<title>"):

Difficulty score: <score>
Hotspot files: <count> (<file list>)
Change coupling pairs: <count> (<pair list>)
MPG (commits/issue): <mpg>

Determine review tier:

TIER_1 (paad:alignment only) when ALL of:
  - Difficulty score < 0.4
  - Hotspot files <= 2
  - No unexpected change coupling
  - MPG <= 3

TIER_2 (full PAAD suite) when ANY of:
  - Difficulty score >= 0.4
  - Hotspot files > 2
  - Unexpected change coupling detected
  - MPG > 3

Output exactly one line: TIER_1 or TIER_2
Followed by: one sentence rationale
```

### Step 4: Issue Gate (PAAD Review)

Run PAAD based on the tier determined by the gate analyst.

**Dispatch the lenses to a fresh subagent. Do not run them yourself.** You wrote
the commits they are judging, and the composition rule in
`docs/decisions/0003-acceptance-by-refinement.md` applies to this gate as much as
to assessment. A reviewer that is the executing agent is the failure the gate
exists to catch.

**A lens that cannot run in-session reports inline, and that is the expected
shape.** `paad:agentic-architecture` and `paad:agentic-review` both refuse a
session that already has substantive history — which an execution session always
has by the time it reaches Step 4 — and both want to write reports into `paad/`.
Apply their taxonomies and evidence discipline to the scoped subject and report
in the message. Say which lenses ran fully and which were applied inline, so the
record does not claim a dispatch that did not happen.

**Tier 1:**
1. **paad:alignment** — check implementation against the issue's AC

**Tier 2:**
1. **paad:alignment** — check implementation against the issue's AC
2. **paad:agentic-architecture** — check structural choices
3. **paad:agentic-review** — check for debt, security, coverage gaps

Tier 2 is expensive: the two multi-agent lenses dispatch roughly a dozen
subagents between them. That cost is why this gate gets skipped, and a gate too
expensive to run is one that gets worked around — so if you are declining it,
decline it in writing rather than silently.

**Evaluate findings:**

- **In-scope findings** (directly related to this issue's AC) AND reopens < 3:
  append findings to the issue body as a `### Review Findings` section, reopen
  the issue via two-step state transition, and return to Step 3 for another
  execution pass.
  ```bash
  # Append findings to issue body via --body on stdin. The dash is the stdin
  # argument: `--body` is a string flag, so a bare one consumes nothing and the
  # binary rejects the command while the transitions below still succeed.
  echo "<current body>

  ### Review Findings

  <findings>" | git zhi issue edit <id> --body -
  git zhi issue edit <id> --state reopen
  git zhi issue edit <id> --state start
  ```
  The next execution pass reads the issue and sees the findings. The reopen
  and restart run under the issue's own token, not a fresh one, so `next`
  still hands the reopened issue to its worker. The restart goes through the
  ownership check in Step 2 like any other start.

- **In-scope findings AND reopens >= 3:** Stop and report: "Issue <id> exceeded
  max review passes (3). Consider splitting the issue or revising the AC."

- **Out-of-scope findings** (new work beyond this issue): create new issues in
  the same milestone.
  ```bash
  git zhi issue add "<finding title>" --milestone <milestone>
  ```

**Record the tier and the outcome, including on a clean pass**, as a checklist
entry in the milestone body: which tier the analyst chose and why, which lenses
ran, and whether the gate was backfilled. Then proceed to the next issue — back
to Step 2, whose Loop control section decides whether that happens now or after
confirmation.

**Write it on a clean pass especially.** Without it, an issue that passed review
and an issue where review never ran are byte-identical in the chain: same state,
same transitions, no derived signal for "reviewed". The gate becomes
unfalsifiable from outside, and a skip is invisible to everything except a person
reading this file. That is not hypothetical — thirteen issues in `rfc-0003` were
closed that way, and `docs/assessments/rfc-0003.md` records it.

**Between Step 3.5 and this entry an issue is closed but not yet reviewed.**
That window is real and `git zhi list` cannot show it, so the entry is what
distinguishes done from done-and-reviewed.

### Step 5: Milestone Completion

When all issues are closed, the order matters: verify, review, then write the
postmortem, then complete. Completing first would gate the postmortem behind
the thing it is meant to explain, and completing the milestone runs the
verify gate over every done issue's acceptance criteria **and over the
milestone body's own**. Both are in scope at completion, which is what makes a
criterion written into the milestone body worth writing.

**Record a checklist entry in the milestone body** carrying **when execute was
satisfied, by whom, and whether it was backfilled**. Execute's derived signal is
the `Implements:` trailer on its commits, which shows that execute ran — it
cannot show that execute backfilled rather than ran in place, and that is what
the entry is for. Where the entry and the trailer disagree, the disagreement is
itself a finding.

**Then run `crochet:review`** over the delivery before the postmortem. Nothing
else looks at the milestone's diff as a whole; the per-issue PAAD passes above
review units of work, not the unit of delivery.

**If `superpowers:verification-before-completion` is available** (check preflight capabilities):
  Invoke it now, before anything is marked complete.

**Otherwise:**
  Run the project's own checks manually and confirm they pass before proceeding.

Then run the postmortem, which writes to `docs/postmortems/` whether or not the
installed binary can attach it to the milestone:

```
/postmortem <milestone>
```

Then complete the milestone:

```bash
git zhi milestone edit <milestone> --state complete
```

If this repository builds an artefact, build and install it here so later
milestones run against current code. Crochet does not: it is markdown, and its
checks are `t/` and `xt/`.

### Step 6: Report

Output summary:
```
Milestone <name> complete.

Issues executed: N
  <id> "<title>" — closed (M iterations, tier T, K review passes)
  ...

Gate analysis:
  Tier 1 issues: A
  Tier 2 escalations: B
  Avg difficulty score: X.XX

PAAD findings:
  In-scope reopens: K
  Out-of-scope issues created: J

Postmortem: see output above
```

## Key Constraints

- All chain interaction through `git zhi` CLI — never access refs directly
- Each worker selects with bare `git zhi next`, identity in `ZHI_ACTOR`
- Reopen requires two state transitions: `--state reopen` then `--state start`
- Sanbao gate analyst determines review depth — measured complexity, not heuristics
- Sanbao runs at milestone scope; gate analyst extracts single-issue metrics
- PAAD is the outer gate — it determines whether an issue is truly done
- code-simplifier is the inner gate — it keeps each commit clean
- Max 3 PAAD-reopen cycles per issue — prevents infinite cycling
- The skill is idempotent: re-invoking it on a partially-executed milestone
  resumes from the current chain state (already-closed issues are skipped)
- Execution runs through by default; `--step` confirms before each issue. The
  rule is stated at the loop boundary in Step 2 and not repeated here, so
  there is one place to read it.
- Commit frequently, never squash — iteration history is valuable

## Integration

- **crochet:preflight** runs first — provides capabilities map for all conditionals
- **crochet:refinement** creates the chain this skill executes
- **crochet:postmortem** runs at milestone completion
- **superpowers:test-driven-development** drives the implementation cycle (if available)
- **superpowers:systematic-debugging** handles stuck issues (if available)
- **superpowers:dispatching-parallel-agents** enables parallel issue execution (if available)
- **superpowers:verification-before-completion** gates milestone completion (if available)
- **sanbao** provides per-issue complexity metrics for gate analysis
- **paad:alignment** always runs at issue gate (tier 1)
- **paad:agentic-architecture, paad:agentic-review** escalation at issue gate (tier 2)
- **superpowers:simplify** (code-simplifier) forms the inner gate
