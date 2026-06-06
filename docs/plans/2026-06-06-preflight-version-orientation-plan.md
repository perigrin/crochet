<!-- ABOUTME: Implementation plan for the preflight version-check and pipeline-orientation spec. -->
<!-- ABOUTME: Task-by-task edits to plugin.json and preflight.md, validated by behavioral walkthrough against real git zhi. -->
# Preflight Version Check and Pipeline Orientation Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add two advisory capabilities to `crochet:preflight` — a warn-don't-block git-zhi minimum-version check and chain-state-inferred pipeline orientation — without adding any new skill, command, or persisted state.

**Architecture:** Both capabilities fold into the existing `skills/preflight/preflight.md`, which already runs first in every crochet skill. Part A extends preflight's existing step 1 (the `which git-zhi` presence check) with a version comparison against a new `git_zhi_min_version` key in `.claude-plugin/plugin.json`. Part B adds a new step that runs `git zhi status --format json` (plus `git zhi list --format json` to resolve soft boundaries) and reports the agent's pipeline position and next gate. Everything is advisory and fails open.

**Tech Stack:** Markdown skill files with YAML frontmatter; JSON plugin manifest; `git zhi` CLI (verified against 0.3.9). No build step, no compiled output, no automated test harness — per this repo's CLAUDE.md, changes are validated by reading the skill for internal consistency and by behavioral walkthrough against the real `git zhi` tool.

---

## Validation Note (read first)

This repo has **no `pytest`, no test suite, no build**. The deliverable is
prose instructions an LLM follows. "Verify it fails / passes" therefore means:

- **Structural validation:** the edited markdown says exactly what the spec
  requires, with correct `git zhi` subcommands and no internal contradiction.
- **Behavioral walkthrough:** manually run the `git zhi` commands the new
  instructions describe, against the real repo, and confirm the JSON/exit
  shapes match what the instructions branch on. The spec's observed shapes were
  captured from git-zhi 0.3.9; re-confirm them before relying on them.

Each task below pairs an edit step with the concrete walkthrough that stands in
for a test. Commit after each task.

---

## File Structure

- **Modify:** `.claude-plugin/plugin.json` — add one top-level key `git_zhi_min_version` (Task 1).
- **Modify:** `skills/preflight/preflight.md` — extend step 1 with the version check (Task 2); insert a new orientation step + supporting "Pipeline Orientation" section (Task 3); update the Key Constraints list (Task 4).

No files are created. No files besides these two are touched.

---

## Task 1: Add `git_zhi_min_version` to plugin.json

**Files:**
- Modify: `.claude-plugin/plugin.json`

- [ ] **Step 1: Confirm current shape**

Run: `cat .claude-plugin/plugin.json`
Expected: a JSON object with `"version": "0.4.0"` and **no** `git_zhi_min_version` key.

- [ ] **Step 2: Add the key**

Insert `git_zhi_min_version` immediately after the existing `version` line so the
two version concepts sit together. Result:

```json
{
  "name": "crochet",
  "description": "Intelligence layer for git-zhi — SDLC pipeline skills (assess, refinement, chain-review, execute, postmortem) with superpowers and PAAD integration",
  "version": "0.4.0",
  "git_zhi_min_version": "0.3.9",
  "author": {
    "name": "Chris Prather"
  },
  "homepage": "https://github.com/perigrin/crochet",
  "repository": "https://github.com/perigrin/crochet",
  "license": "MIT",
  "skills": "./skills/",
  "commands": "./commands/"
}
```

- [ ] **Step 3: Verify the JSON still parses**

Run: `python3 -c "import json,sys; d=json.load(open('.claude-plugin/plugin.json')); print(d['git_zhi_min_version'])"`
Expected: prints `0.3.9` with exit 0. (A parse error here means a stray comma or brace — fix before continuing.)

- [ ] **Step 4: Commit**

```bash
git add .claude-plugin/plugin.json
git commit -m "Pin git_zhi_min_version in plugin manifest"
```

---

## Task 2: Add the version check to preflight step 1 (Part A)

**Files:**
- Modify: `skills/preflight/preflight.md` (the Responsibilities list, step 1)

- [ ] **Step 1: Confirm the installed-version string format**

Run: `git zhi version | head -1`
Expected: a line shaped `git-zhi <semver> (<os>/<arch>)`, e.g. `git-zhi 0.3.9 (linux/amd64)`.
This confirms the parse rule the edit relies on: line 1, second whitespace field, is the semver. If the format differs, stop and revisit the spec's Part A parse rule before editing.

- [ ] **Step 2: Rewrite step 1 of the Responsibilities list**

In `skills/preflight/preflight.md`, replace the existing step 1 bullet:

```markdown
1. **Check git-zhi availability** — run `which git-zhi`. If not found, stop and tell the user to run `crochet:install`.
```

with:

```markdown
1. **Check git-zhi availability and version** — run `which git-zhi`. If not found, stop and tell the user to run `crochet:install`. If found, run `git zhi version`, take the first line (shaped `git-zhi <semver> (<os>/<arch>)`), and read the second whitespace-delimited field as the installed semver. Read `git_zhi_min_version` from `.claude-plugin/plugin.json` and compare as a numeric triplet (major, then minor, then patch). If the installed version is **older** than the minimum, **warn and continue — do not block**:

   > Installed git-zhi `<installed>` is older than the minimum `<minimum>` this Crochet version expects. Some `git zhi` commands may behave unexpectedly. Run `crochet:install` or `git zhi update` to upgrade.

   **Fail open:** if the version line cannot be parsed, or `git_zhi_min_version` is absent from `plugin.json`, skip the version comparison silently. A version-check failure must never block a skill.
```

- [ ] **Step 3: Structural validation**

Re-read the edited step 1. Confirm:
- It still hard-stops on *missing* git-zhi (unchanged behavior).
- The version mismatch path says **warn and continue**, not stop.
- The fail-open clause covers both unparseable version and absent key.
- The subcommand is `git zhi version` (matches what `install.md` already uses).

- [ ] **Step 4: Behavioral walkthrough**

Simulate the comparison with the real binary and the pinned floor:
Run: `git zhi version | head -1 | awk '{print $2}'`
Expected: prints the installed semver (e.g. `0.3.9`).
Confirm by hand: installed `0.3.9` vs minimum `0.3.9` → **not older** → no warning fires today. (This matches the spec's "nothing warns today" intent.)

- [ ] **Step 5: Commit**

```bash
git add skills/preflight/preflight.md
git commit -m "Add git-zhi minimum-version check to preflight step 1"
```

---

## Task 3: Add the pipeline-orientation step (Part B)

**Files:**
- Modify: `skills/preflight/preflight.md` (Responsibilities list + a new section)

- [ ] **Step 1: Confirm the chain-state JSON shapes**

Run: `git zhi status --format json`
Expected (this repo, chain present): an object with `head`, `title`, `state`, `milestone`, `ready_count`.
Run: `git zhi list --format json`
Expected: `{"issues": [ {..., "state": "pending", ...} ]}`.
These are the fields the orientation logic branches on. If the field names differ from the spec's inference table, stop and reconcile the table before editing.

- [ ] **Step 2: Insert a new orientation step into the Responsibilities list**

The list currently ends at step 6 ("Return capabilities map"). Renumber so orientation runs **after** the capabilities map is loaded but is reported as part of preflight's output. Add as the new step 6 and renumber the old step 6 to 7:

```markdown
6. **Report pipeline orientation** — run `git zhi status --format json` (and `git zhi list --format json` to resolve soft boundaries) and report the agent's position in the SDLC pipeline plus the likely next gate, following the inference table in the Pipeline Orientation section below. This is advisory output only — it never blocks, and it skips silently on any `git zhi status` error other than an empty chain.
7. **Return capabilities map** — make the capabilities map available to the calling skill so it can apply the conditional reference pattern (see Usage below).
```

Also update the intro line `Preflight runs six checks in order:` to `Preflight runs seven checks in order:`.

- [ ] **Step 3: Add the "Pipeline Orientation" section**

Add a new `## Pipeline Orientation` section after the `## Fallback Behavior` section (before `## Usage by Downstream Skills`). Body:

````markdown
## Pipeline Orientation

The SDLC pipeline runs in strict order:

```
superpowers:brainstorming → crochet:assess → crochet:refinement → crochet:chain-review → crochet:execute → crochet:postmortem
```

Preflight infers the agent's position from chain state. The **absence** of chain
state is itself meaningful — it means the work is still in the pre-chain stages.

**Primary signal:** `git zhi status --format json` (exit 0 even on an empty
chain). To resolve the soft boundaries, also consult `git zhi list --format json`,
whose `issues[]` carry a per-issue `state`. Do **not** use `git zhi next` as the
primary signal — it errors on an empty chain where `status` degrades gracefully.

Evaluate these rows **in order** and report the first that matches:

| # | Chain state observed | Inferred position | Reported next gate |
|---|---|---|---|
| 1 | `status` has a `message` field / no `milestone`; `list` issues empty | Pre-chain (brainstorming → assess → refinement) | "No chain yet — next gate is `crochet:refinement` to create the milestone and issues" |
| 2 | Milestone exists; an issue is `in_progress` | Mid-execute | "Executing issue `<title>` — continue `crochet:execute`" |
| 3 | Milestone exists; all `list` issues closed; none `pending`/`in_progress` | Chain complete | "All issues closed — next gate is `crochet:postmortem`" |
| 4 | Milestone exists; one or more issues `pending`; none `in_progress` | Chain built / ready to execute | "Chain ready — next gate is `crochet:chain-review`, then `crochet:execute` (`<N>` ready)" |
| 5 | Milestone exists, but JSON matches none of the above | Unknown | Skip orientation silently (fail open) |

Rows 2 and 3 are the unambiguous states. Row 4 deliberately merges "chain just
built" and "ready to execute" — they are indistinguishable from `status` alone
(an all-`pending` chain always has `ready_count > 0`), so the single row keeps
the `chain-review`-then-`execute` phrasing visible rather than forcing a choice.
Row 5 is the explicit fallback for an unrecognized shape: never guess, never block.

**Report facts alongside the inference.** Print the observed state next to the
inferred gate, e.g.:

```
Pipeline: milestone v0.1, 1 ready, 0 in progress, 0 closed
Next gate: crochet:chain-review, then crochet:execute
```

so the agent can see the basis and override a wrong inference.
````

- [ ] **Step 4: Structural validation**

Re-read both edits. Confirm:
- The Responsibilities intro says "seven checks"; steps are numbered 1–7 with no duplicate numbers.
- Orientation is step 6, capabilities-map return is step 7.
- The table is the same first-match, 5-row table as the approved spec (rows 2/3 unambiguous, row 4 merged, row 5 fail-open).
- Every command named is real: `git zhi status --format json`, `git zhi list --format json`.

- [ ] **Step 5: Behavioral walkthrough**

Run each branch's probe against the real repo:
Run: `git zhi status --format json` → confirm it returns `milestone` + `ready_count` (chain present here), so this repo lands on **row 4**.
Run: `git zhi list --format json` → confirm the `issues[]` `state` values are consistent with row 4 (at least one `pending`, none `in_progress`).
Confirm the reported gate for this repo would be "chain-review, then execute" — matching row 4. (No empty-chain repo is required; row 1 is validated by inspection of the documented `{"message": ...}` shape.)

- [ ] **Step 6: Commit**

```bash
git add skills/preflight/preflight.md
git commit -m "Add pipeline-orientation reporting to preflight"
```

---

## Task 4: Document both capabilities in Key Constraints

**Files:**
- Modify: `skills/preflight/preflight.md` (the `## Key Constraints` list)

- [ ] **Step 1: Add two constraint bullets**

In the `## Key Constraints` section, append:

```markdown
- **Version check and orientation are advisory.** Both the git-zhi version warning and pipeline orientation report information and continue. Neither ever blocks a skill, and both fail open — on a parse failure, missing key, or unexpected `git zhi status` shape, skip the affected report silently.
```

- [ ] **Step 2: Structural validation**

Re-read the Key Constraints list. Confirm the new bullet is consistent with the existing "Never block on discrepancy" and "Lightweight and automatic" constraints (no contradiction — orientation is lightweight reporting, not the thorough check that belongs to `crochet:verify`).

- [ ] **Step 3: Commit**

```bash
git add skills/preflight/preflight.md
git commit -m "Document advisory version-check and orientation constraints"
```

---

## Task 5: Final consistency pass against the spec

**Files:**
- Read-only: `skills/preflight/preflight.md`, `.claude-plugin/plugin.json`, `docs/plans/2026-06-06-preflight-version-orientation-design.md`

- [ ] **Step 1: Walk the spec's Acceptance Criteria**

Open the spec's Acceptance Criteria list and confirm each line against the edited files:
- [ ] `git_zhi_min_version` present in `plugin.json` set to `0.3.9`
- [ ] Preflight extracts installed version from `git zhi version` line 1, field 2
- [ ] Preflight warns (does not block) when installed `<` minimum
- [ ] Preflight skips the version check silently when version is unparseable or key absent
- [ ] Preflight infers pre-chain / built / mid-execute / ready / complete from `status`/`list` JSON
- [ ] Preflight reports observed facts alongside the inferred next gate
- [ ] Orientation never blocks; skips silently on unexpected `status` errors
- [ ] No new skill, command stub, or persisted state file introduced

- [ ] **Step 2: Confirm no out-of-scope changes**

Run: `git diff --stat pu`
Expected: exactly two files changed — `.claude-plugin/plugin.json` and `skills/preflight/preflight.md` — plus the two `docs/plans/` files added earlier on this branch. No other file touched. No `commands/` stub added. No new file under `skills/`.

- [ ] **Step 3: Confirm clean tree**

Run: `git status`
Expected: clean working tree, all work committed.
