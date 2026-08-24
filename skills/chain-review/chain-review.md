---
name: chain-review
description: Pipeline gate between refinement and execute — orchestrates alignment (coverage) and pushback (plan quality) against the refined issue chain
---
<!-- ABOUTME: Pipeline gate skill invoked between crochet:refinement and crochet:execute. -->
<!-- ABOUTME: Orchestrates alignment (coverage lens) and pushback (plan quality lens) against a refined issue chain. -->

# crochet:chain-review

Pipeline gate that runs after `crochet:refinement` produces a chain and before `crochet:execute` begins work. Verifies that the chain covers the PRD (alignment) and meets plan quality standards (pushback). Both lenses must pass before the chain moves to execution.

## Position in Pipeline

```
crochet:refinement → crochet:chain-review → crochet:execute
```

chain-review receives the milestone and spec file that refinement produced. It runs two internal skills against that output and surfaces their findings to the user before execution begins.

## Invocation

```
crochet:chain-review <milestone> <spec-file>
```

- `<milestone>` — the milestone name or ID produced by refinement
- `<spec-file>` — the PRD or spec file used as refinement input

## Step 1: Preflight

Run `crochet:preflight` as the first step. This checks git-zhi availability and returns the capabilities map used for conditional dispatch in Step 2.

## Step 2: Run the Lenses

chain-review runs two internal skills:

- **crochet:alignment** — coverage lens. Verifies that refinement output covers the PRD completely without scope creep.
- **crochet:pushback** — plan quality lens. Reviews the issue chain for sizing problems, missing QA tasks, dependency cycles, critical chain issues, untestable acceptance criteria, and ACs whose commands git-zhi-verify cannot execute.

**If `dispatching-parallel-agents` is available** (check preflight capabilities):
  Dispatch alignment and pushback as concurrent agents. Collect both result sets before proceeding to Step 2.5.

**Otherwise:**
  Run alignment and pushback sequentially — first alignment, then pushback. Collect both result sets before proceeding to Step 2.5.

## Step 2.5: AC-command executability (mechanical dry-run)

The verify gate that `milestone edit --state complete` runs will execute each
AC's paren-wrapped command. Confirm mechanically — not just by the pushback
lens's judgment — that those commands are extractable and runnable BEFORE the
chain reaches execution, so a completed milestone is not blocked at the finish
by a false "regression" from a non-runnable AC span.

Run the gate's own extractor in list-only mode:

```bash
git-zhi verify <milestone> --dry-run
```

Cross-check the listed commands against the chain:

- **Every done-able issue has ≥1 extracted command.** An issue that produces no
  command from `--dry-run` has no paren-wrapped AC; it will be "unverifiable" at
  completion. Flag it.
- **No extracted command is a non-runnable span** — a placeholder (`t/<name>.t`,
  `<verification command>`), a bare word (`gate`), or a code fragment
  (`sub foo { }`, `if ($c) {...}`). These fail as invalid shell and become false
  "regressions". Flag each, naming the issue and the offending span.

Fold these into the pushback findings (check 6). This is a mechanical
confirmation of what the pushback lens flags by reading — run both; the dry-run
catches what a prose read might miss.

## Step 3: Present Findings

Present findings from both lenses together, grouped by lens. For each finding, show the issue ID, what the problem is with specific evidence, and the suggested action.

When both lenses produce no findings, confirm to the user that the chain is ready for execution and suggest running `crochet:execute`.

When either lens produces findings, present them and stop. Do not proceed to execution until the user decides how to handle the findings. The user may choose to address them first or proceed anyway.

## Key Constraints

- **Delegate, never reimplement.** alignment and pushback contain the check logic. chain-review orchestrates them — it does not duplicate their checks inline.
- **Read the actual chain.** Run `git zhi issue list --format json` and pass real data to each lens. Do not summarize from memory.
- **Both lenses run every time.** One lens producing findings does not skip the other.
- **User decides next steps.** chain-review presents findings and options. It does not impose a path.
