---
name: execute
description: Drive the full SDLC execution loop — pick issues from the DAG, run TDD with review gates, close issues, complete milestone
---

## Prerequisites

**If `crochet:preflight` is available** (check preflight capabilities):
  Invoke `crochet:preflight` and use the returned capabilities map for all conditional references below.

**Otherwise:**
  Verify that `git-zhi` is available by running `which git-zhi`. If not found, run `crochet:install` to set it up. Proceed without a capabilities map; treat all conditionals below as "not available."

# crochet:execute

Replaces `superpowers:executing-plans` for git-zhi workflows. Drives execution
from the chain itself rather than a markdown plan file.

## Trigger

Chain exists (output of `crochet:refinement`), user says "execute", "build this",
or "start working."

## Input

A milestone name (e.g., `v0.3.4`). If omitted, use `git zhi milestone list --format json`
to find the active milestone (state != completed).

## Process

### Step 1: Load Chain State

```bash
git zhi milestone show <milestone> --format json
git zhi list --milestone <milestone> --format json
```

Count open issues. If zero, skip to Step 5 (completion).

### Step 2: Pick Next Issue

**If `superpowers:dispatching-parallel-agents` is available** (check preflight capabilities):
  Identify all ready issues (all dependencies satisfied, state = pending) and dispatch
  parallel agents for each, one agent per issue. Follow the dispatching-parallel-agents
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

**Otherwise:**
  ```bash
  git zhi list --milestone <milestone> --ready --format json
  ```

  Select the first ready issue (all dependencies satisfied, state = pending).
  If no issues are ready but open issues exist, report the blocker and stop.

Start each issue before executing:
```bash
git zhi issue edit <id> --state start
```

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
git-zhi-sanbao <milestone> --format json
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

**Tier 1:**
1. **paad:alignment** — check implementation against the issue's AC

**Tier 2:**
1. **paad:alignment** — check implementation against the issue's AC
2. **paad:agentic-architecture** — check structural choices
3. **paad:agentic-review** — check for debt, security, coverage gaps

**Evaluate findings:**

- **In-scope findings** (directly related to this issue's AC) AND reopens < 3:
  append findings to the issue body as a `### Review Findings` section, reopen
  the issue via two-step state transition, and return to Step 3 for another
  execution pass.
  ```bash
  # Append findings to issue body via --body on stdin
  echo "<current body>

  ### Review Findings

  <findings>" | git zhi issue edit <id> --body
  git zhi issue edit <id> --state reopen
  git zhi issue edit <id> --state start
  ```
  The next execution pass reads the issue and sees the findings.

- **In-scope findings AND reopens >= 3:** Stop and report: "Issue <id> exceeded
  max review passes (3). Consider splitting the issue or revising the AC."

- **Out-of-scope findings** (new work beyond this issue): create new issues in
  the same milestone.
  ```bash
  git zhi issue add "<finding title>" --milestone <milestone>
  ```

If no findings, proceed to next issue (back to Step 2).

### Step 5: Milestone Completion

When all issues are closed:

```bash
git zhi milestone edit <milestone> --state complete
```

**If `superpowers:verification-before-completion` is available** (check preflight capabilities):
  Invoke `superpowers:verification-before-completion` before marking the milestone
  complete and before rebuilding.

**Otherwise:**
  Run the project test suite and build manually to confirm everything passes
  before proceeding.

**Rebuild and install the binary** so subsequent milestones use the latest code:
```bash
make install
```

This runs `go build` with correct ldflags, installs to `~/.local/bin`, runs
`git-zhi setup` for companion symlinks, and prints the version string for
verification. Skipping this step causes the stale-binary problem where CLI
behavior and sanbao output do not reflect recent code changes.

Then run the postmortem:
```
/postmortem <milestone>
```

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
- Use `git zhi list --milestone <ms> --ready` for ready-set queries
- Reopen requires two state transitions: `--state reopen` then `--state start`
- Sanbao gate analyst determines review depth — measured complexity, not heuristics
- Sanbao runs at milestone scope; gate analyst extracts single-issue metrics
- PAAD is the outer gate — it determines whether an issue is truly done
- code-simplifier is the inner gate — it keeps each commit clean
- Max 3 PAAD-reopen cycles per issue — prevents infinite cycling
- The skill is idempotent: re-invoking it on a partially-executed milestone
  resumes from the current chain state (already-closed issues are skipped)
- Human-in-the-loop: by default, pause between issues for confirmation.
  Pass `--auto` to run without pauses.
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
