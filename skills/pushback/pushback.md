---
name: pushback
description: Pre-flight validation for structured inputs before LLM-powered pipelines act on them — catches implausible dependencies, inconsistent granularity, stale data, and spec gaps before they become silent errors
---

## Prerequisites

Before proceeding, verify that `git-zhi` is available by running `which git-zhi`. If not found, run `crochet:install` to set it up.

# crochet:pushback

Critically reviews structured input before an LLM pipeline acts on it. Same methodology across three contexts; specific checks are parameterized by what you're reviewing.

## Trigger

Invoke before any pipeline writes durable output. The context determines which checks apply:

- `crochet:pushback <spec-file>` — PRD/spec review before `crochet:refinement`
- `crochet:pushback historian` — historian dry-run review before writing issues
- `crochet:pushback report <template-name>` — report template review before generation

## Context: PRD Pre-Refinement

Review a PRD or design spec before `crochet:refinement` decomposes it into a chain.

### Input

A spec file path or conversation history containing a design spec.

### Checks

1. **Source control conflicts:** `git log --oneline -50 --since="2 weeks ago"` — does the spec reference code, APIs, or infrastructure that has recently changed?
2. **Feature cohesion:** Do all features serve the same user goal? Flag unrelated features that should be separate specs.
3. **Scope size:** Heuristic assessment — many distinct features, multiple system areas, estimated effort. Suggest splits when pieces deliver independent value.
4. **Contradictions:** Requirements that conflict with each other or with the codebase.
5. **Feasibility:** Requirements that are difficult given the codebase as it exists — missing infrastructure, incompatible architecture, unsupported dependencies.
6. **Scope imbalance:** One bullet point that's a 2-week project next to 2-hour tasks.
7. **Omissions:** Missing requirements implied by context — error handling, migration paths, rollback plans, permissions.
8. **Ambiguity:** Requirements interpretable multiple ways — vague success criteria, undefined terms.
9. **Security concerns:** Auth gaps, data exposure, injection surfaces, privilege escalation.

### Presentation

Rank findings by severity. Present one at a time with concrete options. Wait for response before proceeding. User can say "good enough" at any point.

## Context: Historian Pre-Write

Review `git zhi historian --dry-run` output before writing issues to refs.

### Input

Run `git zhi historian --dry-run` (with whatever flags the user intends to use for the real run) and capture the output.

### Checks

1. **Implausible clustering:** Commits in unrelated codepaths linked only by temporal coincidence. Check by examining the file paths in each cluster — if a cluster contains `payments/charge.go` and `logging/sink.go` with no shared paths, the clustering is suspicious.
2. **Inconsistent granularity:** One 47-commit issue next to five 2-commit issues. Extreme size variance suggests the large cluster absorbed unrelated work via centroid drift, or the small clusters should have been merged.
3. **Temporal ordering violations:** If the dry-run output implies issue B depends on issue A (via path overlap or ticket ref), but A's commits came chronologically after B's, flag the inconsistency.
4. **Low-confidence dominance:** If more than 40% of clusters are `single-commit` (confidence 0.30), the clustering thresholds may need adjustment. Suggest lowering the join threshold or checking for missing ticket ref patterns.
5. **Orphaned ticket refs:** If the repo uses ticket prefixes (detected from commit messages) but the historian was run without `--title-match`, suggest adding the pattern.
6. **Duplicate clusters:** Two clusters with the same ticket ref that weren't merged — likely separated by the inactivity gap when they shouldn't have been.

### Presentation

Present findings grouped by severity. For each:
- What looks wrong (with specific cluster IDs and commit SHAs)
- Why it matters (what downstream effect it has on telemetry)
- Suggested action (adjust thresholds, use `--title-match`, run `historian triage`)

## Context: Report Template Pre-Generation

Review a report template before `crochet:report` executes it.

### Input

The report template file (found via template discovery paths).

### Checks

1. **Stale data commands:** For each command in the template's `data:` block, run it with `--dry-run` or `--format json` and check:
   - Does it exit successfully?
   - Does it return non-empty data?
   - If it references a milestone, does that milestone exist?
2. **Missing milestones or labels:** Does the template reference milestones or labels that don't exist in the chain? Check with `git zhi milestone list` and `git zhi issue list --format json`.
3. **Unreachable plugins:** Does the template reference plugin commands (`sanbao`, `verify`, `docs`) that aren't on `$PATH`?
4. **Structural completeness:** Does the template have both a `## Prompt` section and a `## Structure` section? Are there `data:` commands that produce the data needed by each structure section?

### Presentation

Present findings as a checklist. For each failed check:
- What's wrong
- What command to run or configuration to add to fix it
- Whether the report can still be generated with degraded output

## Key Constraints

- **Every claim must cite evidence.** "This cluster looks wrong" must reference specific commit SHAs and file paths.
- **Read the actual data.** Don't guess from names — run commands and inspect output.
- **Pushback is not blocking.** The user decides whether to proceed. Present findings and options; don't refuse to continue.
- **Same methodology, different inputs.** The structure (gather evidence → analyze → present findings → resolve) is identical across all three contexts. Only the specific checks differ.
