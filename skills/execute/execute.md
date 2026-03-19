---
name: execute
description: Drive the full SDLC execution loop — pick issues from the DAG, run TDD with review gates, close issues, complete milestone
---

## Prerequisites

Before proceeding, verify that `git-zhi` is available by running `which git-zhi`. If not found, run `crochet:install` to set it up.

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

```bash
git zhi list --milestone <milestone> --ready --format json
```

Select the first ready issue (all dependencies satisfied, state = pending).
If no issues are ready but open issues exist, report the blocker and stop.

Start the issue:
```bash
git zhi issue edit <id> --state start
```

### Step 3: Inner Loop (TDD Cycle)

Read the issue's full context:
```bash
git zhi issue show <id> --format json
```

Extract from the issue:
- Title and acceptance criteria (positive and negative scenarios)
- Context paths (files to read)
- Steps (RED-GREEN-COMMIT choreography if present)
- Review findings from prior PAAD passes (if issue was reopened)

**Launch a Ralph Loop** with this prompt template (filled from issue data):

```
/ralph-loop "Execute issue <id>: <title>

Acceptance criteria:
<AC from issue body>

Context files: <paths>

Review findings to address (if any):
<findings from ### Review Findings section, or 'None'>

Instructions:
1. Read the issue context files
2. Check git log and git diff for work from previous iterations
3. If review findings exist, address those first
4. Follow TDD: write a failing test, implement, verify green
5. After tests pass, run: /simplify (code-simplifier on changed files)
6. If simplifier finds issues, fix them and re-run tests
7. Commit frequently with descriptive messages
8. Repeat for each AC item

When ALL acceptance criteria are met, tests pass, and simplifier is clean:
" --completion-promise "ISSUE_COMPLETE" --max-iterations 10
```

**Max iterations is a safety valve.** 10 is generous enough for well-sized issues.
If the loop hits max without converging, stop and report: "Issue did not converge
in 10 iterations — consider splitting it or clarifying the AC."

**Commit strategy:** Commit frequently with descriptive messages. Every iteration
should leave committed state so the next iteration can build on it. Do not
squash or amend — the commit history is the iteration history.

### Step 3.5: Sanbao Gate Analysis

After the inner loop completes, close the issue and compute a sanbao snapshot
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
  inner-loop pass.
  ```bash
  # Append findings to issue body via --body on stdin
  echo "<current body>

  ### Review Findings

  <findings>" | git zhi issue edit <id> --body
  git zhi issue edit <id> --state reopen
  git zhi issue edit <id> --state start
  ```
  The next Ralph Loop iteration reads the issue and sees the findings.

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

Then run the postmortem:
```
/postmortem <milestone>
```

### Step 6: Report

Output summary:
```
Milestone <name> complete.

Issues executed: N
  <id> "<title>" — closed (M inner iterations, tier T, K review passes)
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
- The inner loop is a Ralph Loop — it handles iteration, context preservation,
  and completion detection
- Sanbao gate analyst determines review depth — measured complexity, not heuristics
- Sanbao runs at milestone scope; gate analyst extracts single-issue metrics
- PAAD is the outer gate — it determines whether an issue is truly done
- code-simplifier is the inner gate — it keeps each commit clean
- Max 3 PAAD-reopen cycles per issue — prevents infinite outer-loop cycling
- The skill is idempotent: re-invoking it on a partially-executed milestone
  resumes from the current chain state (already-closed issues are skipped)
- Human-in-the-loop: by default, pause between issues for confirmation.
  Pass `--auto` to run without pauses.
- Commit frequently, never squash — iteration history is valuable

## Integration

- **crochet:refinement** creates the chain this skill executes
- **crochet:postmortem** runs at milestone completion
- **ralph-loop** drives the inner TDD cycle
- **sanbao** provides per-issue complexity metrics for gate analysis
- **paad:alignment** always runs at issue gate (tier 1)
- **paad:agentic-architecture, paad:agentic-review** escalation at issue gate (tier 2)
- **superpowers:simplify** (code-simplifier) forms the inner gate
