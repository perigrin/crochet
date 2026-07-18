---
name: pushback
description: Plan quality validation for issue chains — catches sizing problems, missing QA tasks, dependency cycles, critical chain issues, untestable acceptance criteria, and ACs whose commands git-zhi-verify cannot execute, before chain-review completes
---

## Prerequisites

Before proceeding, verify that `git-zhi` is available by running `which git-zhi`. If not found, run `crochet:install` to set it up.

# crochet:pushback

This is an internal skill — called by crochet:chain-review. Critically reviews an issue chain plan for quality problems before chain-review completes its analysis.

## Trigger

This skill is invoked by `crochet:chain-review` only. It is not intended for direct user invocation.

## Plan Quality Lens

Apply all five checks to the issue chain. Every claim must cite specific issue IDs, milestone names, or dependency references from the chain.

### 1. Issue Sizing

Each issue should represent a single chunk of work. Flag issues that appear to contain multiple independent deliverables, or issues so small they should be merged with a sibling.

- Look for issues with five or more unrelated acceptance criteria
- Look for issues whose title contains "and" linking two distinct concerns
- Look for groups of issues that each touch a single file or function — suggest merging

### 2. QA Tasks Present

Every code issue should have at least one negative scenario in its acceptance criteria. Flag issues that only describe happy-path behavior.

- "Creates a record successfully" without a corresponding "returns an error when the record already exists" is incomplete
- Infrastructure and documentation issues are exempt from this check

### 3. Dependency Sanity

Check dependency sanity: relationships between issues must form a DAG (no cycles) and no single issue should block an unreasonable number of downstream issues.

- Trace all `blocks` / `blocked-by` references and check for cycles
- Flag any issue that blocks more than four downstream issues — this is a bottleneck and may need decomposition
- Flag dependency edges where the blocker and the dependent appear unrelated by file path or feature area

### 4. Critical Chain Analysis

Identify the longest dependency chain (the critical chain). Flag excessive length and note opportunities for parallelism.

- A critical chain longer than six issues for a single milestone is a warning sign
- Identify issues with no blockers and no dependents — these can be worked in parallel and should be noted
- Flag issues on the critical chain that have low-confidence estimates, as they dominate delivery risk

### 5. AC testability

Acceptance criteria must be concrete enough to write a test against. Vague criteria become invisible bugs.

- Flag criteria using unmeasurable language: "works correctly", "is fast", "looks good", "handles edge cases"
- Each criterion should specify an observable outcome: a return value, an exit code, a rendered element, a logged message
- Flag criteria with no observable output at all

### 6. AC command executability

Testability (check 5) is about whether an AC is *conceptually* checkable. This check is about whether `git-zhi-verify` can *actually execute* the command — because `milestone edit --state complete` runs the verify gate, and an AC whose command is not runnable blocks completion with a false "regression".

`git-zhi-verify` extracts and runs exactly the command inside the FIRST paren-wrapped backtick span — `` - [ ] <desc> (`<command>`) `` — on each checkbox line under `## Acceptance Criteria` (and its `### Positive Scenarios` / `### Negative Scenarios` subsections). **Parenthesization is the only marker**: a bare backtick span with no surrounding parens (`` `code fragment` ``) is treated as prose and ignored; a paren-wrapped span is run verbatim via `sh -c`.

Run the gate's own extractor to see what it WOULD run, without executing:

```bash
git-zhi verify <milestone> --dry-run
```

Flag, per issue:

- **No extractable command** — an issue with zero paren-wrapped AC commands. It cannot be verified; `--state complete` will mark it unverifiable.
- **Non-runnable paren-wrapped span** — a `(`...`)` command that is not a real shell command line: an un-substituted placeholder (`` (`t/<name>.t`) ``, `` (`<verification command>`) ``), a bare word (`` (`gate`) ``), or a language/code fragment (`` (`if ($c) {...}`) ``, `` (`sub foo { }`) ``). These fail as invalid shell and become false "regressions".
- **Code fragment wrongly paren-wrapped** — a Negative Scenario whose *subject* code was written as `` (`<perl fragment>`) `` instead of bare backticks. The subject is a description, not a command; only the SCENARIO's verification command belongs in parens. Bare-backtick the fragment; paren-wrap only the runnable check.
- **Multiple commands on one line** — `git-zhi-verify` runs only the FIRST paren-wrapped span per checkbox and silently drops the rest. Flag AC lines with two or more `(`...`)` spans; split them across lines.

The fix for a flagged AC is: paren-wrap exactly one runnable shell command (a `prove`/`perl`/`go test`/`git` invocation with real paths, runnable from repo root), and demote every code fragment or placeholder to a bare backtick (which the extractor ignores).

## Presentation

Group findings by check. For each finding:
- Issue ID and title
- What the problem is (with specific evidence from the chain)
- Suggested action (split, merge, add criterion, add dependency edge)

Present all findings together. The caller (chain-review) decides how to surface them to the user.

## Key Constraints

- **Every claim must cite evidence.** Reference specific issue IDs, milestone names, and dependency edges — never assert problems without grounding them in the chain data.
- **Read the actual chain.** Run `git zhi issue list --format json` and inspect the output. Do not guess from issue titles alone.
- **Pushback is not blocking.** Present findings and options. The user decides whether to proceed.
- **Scope is plan quality only.** This skill does not review spec correctness, PRD completeness, or report template validity.
