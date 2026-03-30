---
name: refinement
description: Decompose a brainstorming spec into an executable git-zhi chain with milestone, issues, dependencies, and acceptance criteria
---

## Prerequisites

Before proceeding, verify that `git-zhi` is available by running `which git-zhi`. If not found, run `crochet:install` to set it up.

# crochet:refinement

Replaces `superpowers:writing-plans`. Transforms a validated design spec into an executable git-zhi chain. This skill sits between brainstorming and chain-review in the pipeline.

## Trigger

Approved design spec exists (output of `superpowers:brainstorming`), user says "go", "plan this", or "break this down."

## Input

A spec file path (e.g., `docs/plans/2026-03-15-parser-design.md`).

## Process

Agent roles execute in sequence. Each role reads the spec and the codebase, then creates or modifies chain state through `git zhi` CLI commands.

### Step 0: Preflight

Invoke `crochet:preflight` as the first action. This checks git-zhi availability, reads the capabilities manifest, and returns the capabilities map used for conditional dispatch in later steps.

### Step 0.5: Pipeline-Readiness Pre-Checks

Before decomposition begins, run pipeline-readiness checks against the spec and codebase:

1. **Source control conflicts** — check for source control issues by running `git status` and `git diff --stat`. If there are uncommitted changes or merge conflicts, report them and ask the user to resolve before continuing. A dirty working tree can cause chain issues later.
2. **Omissions check** — scan the spec for referenced files, modules, or dependencies that do not exist in the codebase. List any omissions and ask the user to confirm they are intentional (new work) or unintentional (missing context).
3. **Scope check** — read the codebase structure and compare it against the spec. Flag any areas where the spec appears to contradict existing architecture or naming conventions. Do not block on this — surface findings and continue unless the user asks to stop.
4. **Feasibility assessment** — check whether the spec is feasible given the codebase maturity, existing dependencies, and available infrastructure. Flag any aspects that appear infeasible and ask the user to confirm before proceeding.

If all three checks pass cleanly, proceed to Step 1. If issues are found, surface them as a numbered list and ask the user: "Proceed anyway, or stop to address these first?"

### Step 1: Lazy Initialization

Before any agent runs:

1. Check if `CONTRIBUTING.md` exists. If not, check if `git-zhi-docs` is on `$PATH`:
   - If available: run `git zhi docs init` to scaffold the canonical structure
   - If not: create a minimal CONTRIBUTING.md with tech stack, build/test commands
2. Check if `CLAUDE.md` exists. If not, create one pointing to CONTRIBUTING.md with agent directives.
3. If both exist, check CLAUDE.md references CONTRIBUTING.md. Propose update if not.

### Step 2: Architect Agent

**System prompt:** `architect-prompt.md`

**Reads:**
- The spec file
- CONTRIBUTING.md (project conventions)
- Existing codebase structure (`find . -type f -name '*.go'` or equivalent)
- `git zhi milestone list --format json` (existing milestones)

**Produces:**
- Milestone name, due date, resolution command
- Milestone body: Context, File Structure, Design Rationale sections
- Calls: `git zhi milestone add <name> --due <date>` with body via stdin

### Step 3: Decomposer Agent

**System prompt:** `decomposer-prompt.md`

**Reads:**
- The spec file
- The milestone just created (`git zhi milestone show <name> --format json`)
- CONTRIBUTING.md

**Produces:**
- Issues with titles, dependencies (blocked_by), structured context (paths, commands, entrypoints), Steps (RED-GREEN-COMMIT choreography), and positive acceptance criteria
- Batch creation via stdin: `git zhi issue add` with `---` separators
- Dependencies wired via `git zhi issue edit <id> --block <other-id>`

### Steps 4 and 5: Quality and Documentation (Parallel Dispatch)

After decomposition, two independent agents enrich the issues: one adds negative scenarios, the other adds documentation steps. These agents do not depend on each other's output and may run concurrently.

**If `superpowers:dispatching-parallel-agents` is available** (check preflight capabilities):
  Dispatch both agents in parallel using `dispatching-parallel-agents`. Each agent receives its system prompt and the issue list. Collect results from both before proceeding to Step 6.

**Otherwise:**
  Run Step 4 and Step 5 sequentially — SQE first, then technical writer.

#### Step 4: SQE Agent

**System prompt:** `sqe-prompt.md`

**Reads:**
- Each issue's positive acceptance criteria (`git zhi issue show <id> --format json`)
- The spec file (for domain context)
- Does NOT read implementation code

**Produces:**
- Negative scenarios for each issue: boundary conditions, error paths, race conditions, invalid inputs, state corruption
- Updates issues via `git zhi issue edit <id>` with updated body containing `### Negative Scenarios`

#### Step 5: Technical Writer Agent

**System prompt:** `techwriter-prompt.md`

**Reads:**
- The spec file
- Existing docs (`git zhi docs health --format json` if available, else `ls docs/`)
- Each issue's context paths

**Produces:**
- Doc update steps added to code issues (e.g., "update docs/architecture/parser-design.md")
- Standalone documentation issues for new guides, ADRs, architecture overviews
- Issues created via `git zhi issue add` with appropriate dependencies

### Step 6: Report

Output summary:
```
Created/updated:
  CONTRIBUTING.md
  CLAUDE.md
  docs/ (scaffolded)

Created:
  milestone <name>  (<description>)
  issue <id>  "<title>"  (no deps)
  issue <id>  "<title>"  (blocked by <id>)
  ...

Chain ready. N issues (M code, K docs), critical chain length: L
Max parallelism: W workers (at issue <id>)
Run: git zhi list
```

## Key Constraints

- All chain interaction through `git zhi` CLI commands — never access `refs/zhi/` directly
- The quality agent never sees implementation code — only specs and acceptance criteria
- Each agent role runs as a fresh subagent with its own system prompt
- Lazy init is idempotent — safe to run on repos that already have docs structure
