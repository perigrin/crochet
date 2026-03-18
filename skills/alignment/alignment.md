---
name: alignment
description: Post-pipeline verification that outputs match inputs — checks refinement vs PRD, historian vs git log, historian vs tracker, and forward chain vs historical chain for coverage gaps and structural drift
---

# crochet:alignment

Verifies that pipeline outputs are aligned with their inputs. Same methodology across four contexts; specific checks are parameterized by what you're comparing.

## Trigger

Invoke after a pipeline produces output to verify structural alignment:

- `crochet:alignment refinement <spec-file>` — refinement output vs PRD
- `crochet:alignment historian` — historian issues vs git log
- `crochet:alignment tracker <milestone>` — historian issues vs external tracker
- `crochet:alignment chain <milestone>` — forward chain vs historical chain

## Context: Refinement vs PRD

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

## Context: Historian vs Git Log

Verifies that the historian's issue output accounts for all commits and produces structurally sensible results.

### Input

1. `git zhi historian status` — coverage report (total, mapped, unmapped commits)
2. `git zhi issue list --format json` — all historian-created issues
3. `git log --oneline` — full commit history

### Checks

1. **Coverage completeness:** What percentage of commits are mapped to issues? `historian status` provides the quantitative answer. Flag if below 60% — significant work is unaccounted for.
2. **Temporal consistency:** For each issue, verify that its session start SHA precedes its session end SHA in git history. A reversed ordering indicates a clustering error.
3. **Orphaned work:** Commits not mapped to any issue — are they genuinely standalone (merge commits, version bumps, CI config) or missed work? Sample the unmapped commits and classify.
4. **Dependency plausibility:** If issue B's file paths overlap with issue A's, and A completed before B started, a dependency edge is sensible. If B started before A, the overlap may be coincidental.
5. **Granularity consistency:** Standard deviation of commits-per-issue. Extreme outliers (issues with 50+ commits next to issues with 1-2 commits) suggest clustering problems.

### Presentation

```
## Alignment: Historian vs Git Log

Coverage: 87% (1190/1367 commits mapped)
Issues created: 69
Temporal violations: 0
Orphaned commits: 177 (123 merge/CI, 54 substantive)
Granularity: mean 17.2 commits/issue, stdev 14.3

### Findings

1. **54 substantive commits unmapped** — mostly single-file changes without
   conventional commit scopes or ticket refs. Consider running
   `historian triage` to review them interactively.

2. **Granularity outlier:** Issue "XS emitter" has 47 commits while the
   median is 12. The cluster may have absorbed adjacent work. Review with
   `git zhi issue show <id>` and check file path overlap with neighbors.
```

## Context: Historian vs External Tracker

Verifies that historian-created issues align with the external tracker's view of work.

### Input

1. `git zhi issue list --format json` — historian issues with `tracker_id` set
2. External tracker data — via `git zhi jira sync --dry-run` or similar

### Checks

1. **Tracker coverage:** For each tracker ticket referenced in commit messages, is there a corresponding historian issue with that `tracker_id`? Flag tickets with commits but no issue.
2. **Disagreements:** When the historian's high-confidence clustering disagrees with the tracker's ticket boundaries — e.g., the historian merged two tracker tickets into one cluster, or split one ticket across two clusters — these are the decomposition insights worth investigating.
3. **State consistency:** Do historian-created issue states match tracker states? A historian issue marked `done` for a tracker ticket still in "In Progress" suggests the tracker is stale or the historian misidentified the done boundary.
4. **Missing enrichment:** Issues with `tracker_id` but no enriched metadata (title, description, assignee from tracker) — suggest running `git zhi jira enrich <milestone>`.

### Presentation

Focus on disagreements — they reveal whether the historian's clustering or the tracker's ticket boundaries more accurately reflect the actual work. Neither is automatically right.

## Context: Forward Chain vs Historical Chain

Verifies that forward-looking issues (from `crochet:refinement`) connect sensibly to retrospective issues (from historian).

### Input

1. Forward issues: issues with `source=planned` or `source=manual`
2. Historical issues: issues with `source=tracker-match`, `source=cluster`, or `source=single-commit`
3. The milestone containing both types

### Checks

1. **Pattern recognition:** Does the forward plan account for what the historical chain reveals about actual work patterns? If the historian shows 14 issues touching the auth module with declining coherence (sign of accumulated complexity), and the forward plan has a single "Refactor auth" issue, flag the mismatch.
2. **Effort calibration:** Compare the forward plan's issue count and estimated scope against the historical chain's observed effort distribution. If historical work on similar modules averaged 8 commits per issue, but the forward plan assumes 2-commit tasks, the plan is likely underestimating.
3. **Dependency bridging:** Are there explicit dependencies between forward and historical issues? If the forward plan depends on historical work being complete (done state), verify it actually is. If historical issues are still in-progress, the forward plan has unmet prerequisites.
4. **Path overlap continuity:** Do forward issues touch the same file paths as recent historical issues? If so, the forward work extends existing code — dependency edges and effort estimates should reflect this.

### Presentation

```
## Alignment: Forward Chain vs Historical Chain

Forward issues: 12 (planned)
Historical issues: 69 (retrospective)
Bridging dependencies: 3

### Findings

1. **Auth module underestimated.** Historical chain shows 14 issues
   (avg 6.2 commits each) touching internal/auth/. Forward plan has
   1 issue "Refactor auth handler." Historical effort suggests 3-5
   forward issues would be more realistic.

2. **Missing bridge dependency.** Forward issue "Add rate limiting"
   touches internal/middleware/ which has 2 active historical issues
   not yet done. The forward plan should depend on their completion.
```

## Key Constraints

- **Alignment is structural, not semantic.** Check that things that should correspond do correspond. Don't evaluate whether the plan is good — evaluate whether it matches its inputs.
- **Read the actual data.** Run the commands, inspect JSON output, check file paths. Don't guess from titles.
- **Disagreements are insights, not errors.** When the historian and the tracker disagree, present both interpretations. The human decides which more accurately reflects reality.
- **Coverage is quantitative.** Report actual numbers (87% coverage, 54 unmapped, 3 outliers). Don't say "most commits are covered" — say exactly how many.
- **Same methodology, different comparisons.** The structure (gather data → compare → present findings → resolve) is identical across all four contexts. Only the specific things being compared differ.
