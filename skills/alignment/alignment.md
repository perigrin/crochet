---
name: alignment
description: Internal coverage lens used by chain-review — verifies that refinement output covers the PRD completely without scope creep, checking requirements coverage, scope compliance, and dependency direction
---

<!-- ABOUTME: Internal skill invoked by crochet:chain-review to verify refinement output against its PRD. -->
<!-- ABOUTME: Performs requirements coverage, scope compliance, and dependency direction checks. -->

## Prerequisites

Before proceeding, verify that `git-zhi` is available by running `which git-zhi`. If not found, run `crochet:install` to set it up.

# crochet:alignment

**Internal skill.** This skill is called by `crochet:chain-review` and is not intended to be invoked directly by users.

Verifies that refinement output is aligned with the PRD it was derived from. Checks that requirements are fully covered, that no phantom features were introduced, and that dependency edges reflect actual technical constraints.

## Trigger

This skill is invoked internally by `crochet:chain-review` after refinement produces output:

- `crochet:alignment refinement <spec-file>` — refinement output vs PRD

## Context: Coverage Lens — Refinement vs PRD

Verifies that `crochet:refinement` output covers the PRD completely without scope creep.

### Input

1. **Intent:** The PRD or spec file used as refinement input
2. **Action:** The chain state produced by refinement — `git zhi issue list --format json` filtered to the milestone

### Checks

1. **Requirements coverage:** For every requirement in the PRD, at least one issue addresses it. Flag uncovered requirements.
2. **Scope compliance:** For every issue in the chain, it traces back to a stated requirement. Flag phantom features (scope creep).
3. **Dependency direction:** Do dependency edges reflect actual technical constraints? If issue B depends on issue A, does the codebase confirm that A's work must precede B's?
4. **Acceptance criteria completeness:** Do positive and negative scenarios exist for each issue? (SQE agent should have added negatives.)

### Presentation

Present findings dependency-ordered: missing requirements first (root causes), then orphaned tasks (symptoms). One at a time with options.

## Key Constraints

- **Alignment is structural, not semantic.** Check that things that should correspond do correspond. Don't evaluate whether the plan is good — evaluate whether it matches its inputs.
- **Read the actual data.** Run the commands, inspect JSON output, check file paths. Don't guess from titles.
- **Coverage is quantitative.** Report actual numbers (e.g. 87% coverage, 54 unmapped, 3 outliers). Don't say "most requirements are covered" — say exactly how many.
- **This skill is internal.** It is called by `crochet:chain-review`, not invoked directly by users.
