---
name: assess
description: Analyze a PRD against the existing codebase and chain to identify gaps, partial implementations, blocking architecture conflicts, and satisfied requirements
---

# crochet:assess

Reads a PRD and analyzes it against the existing codebase and chain state to produce a gap analysis. Output feeds `crochet:refinement` — blocking items become prerequisite refactoring issues at the front of the chain.

## Trigger

User provides a PRD file path, or invokes after brainstorming produces a spec.

## Inputs

1. **PRD or spec file** — from Jama via MCP, from a file, or from stdin
2. **Codebase** — direct file access (source files, directory structure)
3. **Chain state** — `git zhi issue list --format json`, `git zhi milestone list --format json`
4. **Lineage data** — `git zhi issue show <id> --format json` for upstream context
5. **Git history** — `git log` for recent changes in relevant areas

## Process

### Step 1: Parse Requirements

Read the PRD and extract discrete requirements. Each requirement is a capability, constraint, or behavior the system must exhibit.

### Step 2: Analyze Codebase

For each requirement, search the codebase:

- **Grep for relevant types, functions, packages** that relate to the requirement
- **Read the code** to understand what exists and how it works
- **Check tests** to understand what's verified
- **Check git log** for recent changes in the relevant area

### Step 3: Classify Each Requirement

Assign each requirement to one of four categories:

- **Missing** — the capability does not exist in code. No relevant types, functions, or packages found. This becomes a new issue in the chain.
- **Partial** — code exists that does some of what's needed but requires extension. Identify what exists and what's missing. This becomes an enhancement issue.
- **Blocking** — existing code or architecture conflicts with the requirement. Something must be refactored or removed before the requirement can be met. This becomes a prerequisite refactoring issue at the front of the chain.
- **Ready** — code already satisfies the requirement. Point to the specific files and tests that demonstrate this.

### Step 4: Trace Lineage

For Partial and Blocking items, use chain lineage data to understand:
- Who built the existing code and why (from issue context and transitions)
- What decisions led to the current architecture (from milestone postmortems if available)
- What other code depends on the area that needs changing

### Step 5: Output

Present results grouped by category, most critical first:

```
## Assessment: <PRD title>

### Blocking (must resolve first)
1. **<requirement>** — <what conflicts and why>
   Files: <paths>
   Lineage: built by <issue>, decision documented in <postmortem/ADR>
   Action: refactor <component> before proceeding

### Missing (new work)
1. **<requirement>** — <what doesn't exist>
   Suggested paths: <where new code should live>
   Dependencies: requires <blocking items> resolved first

### Partial (extend existing)
1. **<requirement>** — <what exists, what's missing>
   Files: <paths>
   Extension needed: <specific changes>

### Ready (already satisfied)
1. **<requirement>** — satisfied by <files/tests>
```

## Key Constraints

- **Read the actual code.** Don't guess from file names or directory structure. Open files and understand what they do.
- **Every claim must cite evidence.** "This is missing" must be backed by a search that found nothing. "This is partial" must point to the specific file and explain what's missing.
- **Blocking items are prerequisites.** They must be resolved before the missing or partial items can be addressed. The output order reflects this dependency.
- A human can do this manually: read the PRD, grep the codebase, check `git log`, list the gaps. This skill executes the same process faster and more thoroughly.
