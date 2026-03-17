---
name: refinement
description: Decompose a brainstorming spec into an executable git-zhi chain with milestone, issues, dependencies, and acceptance criteria
---

# crochet:refinement

Replaces `superpowers:writing-plans`. Transforms a validated design spec into an executable git-zhi chain.

## Trigger

Approved design spec exists (output of `superpowers:brainstorming`), user says "go", "plan this", or "break this down."

## Input

A spec file path (e.g., `docs/plans/2026-03-15-parser-design.md`).

## Process

Four agent roles execute in sequence. Each role reads the spec and the codebase, then creates or modifies chain state through `git zhi` CLI commands.

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

### Step 4: SQE Agent

**System prompt:** `sqe-prompt.md`

**Reads:**
- Each issue's positive acceptance criteria (`git zhi issue show <id> --format json`)
- The spec file (for domain context)
- Does NOT read implementation code

**Produces:**
- Negative scenarios for each issue: boundary conditions, error paths, race conditions, invalid inputs, state corruption
- Updates issues via `git zhi issue edit <id>` with updated body containing `### Negative Scenarios`

### Step 5: Technical Writer Agent

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
- The SQE agent never sees implementation code — only specs and acceptance criteria
- Each agent role runs as a fresh subagent with its own system prompt
- Lazy init is idempotent — safe to run on repos that already have docs structure
