<!-- ABOUTME: Design for adding a git-zhi minimum-version check and pipeline-orientation reporting to crochet:preflight. -->
<!-- ABOUTME: Both capabilities fold into the existing preflight skill; no new skill, no new persisted state. -->
# Preflight: git-zhi Version Check and Pipeline Orientation

## Summary

Add two advisory capabilities to the existing `crochet:preflight` skill, which
already runs as the first step of every crochet skill:

1. **Minimum git-zhi version check** — warn (never block) when the installed
   git-zhi is older than a minimum version pinned in `plugin.json`.
2. **Pipeline orientation** — infer the agent's position in the SDLC pipeline
   from chain state and report the likely next gate.

Neither capability adds a new skill, a new command stub, or new persisted
state. Both are advisory: they emit information and continue. Preflight remains
lightweight and automatic; the thorough on-demand check stays in `crochet:verify`.

## Motivation

- **Version drift is real and currently invisible.** At design time the plugin
  was at `0.4.0` while the installed binary was `0.3.9`. Every skill calls
  `git zhi` subcommands; a behind-baseline binary can behave differently or
  fail confusingly, and nothing warns. `require-git-zhi.md` and preflight step 1
  check only *presence* (`which git-zhi`), never version.
- **Pipeline position is not surfaced.** The strict order
  (`brainstorming → assess → refinement → chain-review → execute → postmortem`)
  lives in `CLAUDE.md`/`README.md` as passive documentation. Preflight already
  runs first everywhere and already shells out, so it is the natural place to
  report "you are here" without a competing new front-door.

## Part A — Minimum git-zhi Version Check

### plugin.json

Add one dedicated top-level key, distinct from crochet's own `version`:

```json
"git_zhi_min_version": "0.3.9"
```

The value is set conservatively to the current baseline (`0.3.9`) so nothing
warns today; the check only catches machines that fall *below* this baseline in
the future. Raising the floor later is a one-line edit.

### Behavior (extends preflight step 1)

After confirming git-zhi is on PATH:

1. Run `git zhi version`. The first line has the form
   `git-zhi <semver> (<os>/<arch>)`. Take line 1, split on whitespace, take the
   second field → installed semver (e.g. `0.3.9`).
2. Read `git_zhi_min_version` from `.claude-plugin/plugin.json`.
3. Compare as semver (numeric triplet compare: major, then minor, then patch).
4. If installed **<** minimum, **warn and continue** — do NOT block:

   > Installed git-zhi `<installed>` is older than the minimum
   > `<minimum>` this Crochet version expects. Some `git zhi` commands may
   > behave unexpectedly. Run `crochet:install` or `git zhi update` to upgrade.

5. **Fail open.** If the version string cannot be parsed, or
   `git_zhi_min_version` is absent from `plugin.json`, skip the check silently.
   A check failure must never block a skill.

### Design notes

- Comparison is plain numeric-triplet logic described in the skill prose, the
  way preflight already describes its other steps. No external tool dependency.
- "Warn, don't block" follows directly from a *minimum* (advisory) rather than
  an *exact* (gating) version policy.

## Part B — Pipeline Orientation

### Primary signal: `git zhi status --format json`

Observed return shapes (verified against git-zhi 0.3.9, all exit 0):

- **No chain:** `{"message": "No issues in chain", "ready_count": 0}` — has a
  `message` field, no `milestone`/`head`. (`git zhi list --format json` →
  `{"issues": []}`.)
- **Chain exists:** `{"head": "...", "title": "...", "state": "...",
  "milestone": "v0.1", "ready_count": 1}` — has `milestone` + `head`.

To resolve the soft boundaries, preflight also consults
`git zhi list --format json`, whose `issues[]` carry a per-issue `state`
(`pending` / `in_progress` / closed states).

> Note: `git zhi next --format json` errors on an empty chain
> (`resolve ref: no issues found`). Use `status`, not `next`, as the primary
> signal — it degrades gracefully where `next` does not.

### Inference table

| Chain state observed | Inferred position | Reported next gate |
|---|---|---|
| `status` has `message` / no `milestone`; `list` issues empty | Pre-chain (brainstorming → assess → refinement) | "No chain yet — next gate is `crochet:refinement` to create the milestone and issues" |
| Milestone exists; `list` issues all `pending`; none `in_progress`; none closed | Chain just built | "Chain built — next gate is `crochet:chain-review`, then `crochet:execute`" |
| Milestone exists; an issue `in_progress` | Mid-execute | "Executing issue `<title>` — continue `crochet:execute`" |
| Milestone exists; `ready_count > 0`; none `in_progress` | Ready to execute | "`<N>` issues ready — next gate is `crochet:execute`" |
| Milestone exists; `list` issues all closed | Chain complete | "All issues closed — next gate is `crochet:postmortem`" |

### Reporting discipline

- **Report facts alongside inference.** Preflight prints the observed state
  (e.g. `milestone v0.1, 1 ready, 0 in progress, 0 closed`) next to the inferred
  next gate, so the agent sees the basis and can override a wrong inference.
- **Honor the one soft boundary.** A freshly built chain and a ready-to-execute
  chain are indistinguishable in `status` alone. Preflight names the likely next
  gate but phrases it as "chain-review, then execute" so both stay visible
  rather than hard-asserting one.
- **Advisory only.** Like the version warning, orientation never blocks. If
  `git zhi status` errors for any reason other than "no chain," skip orientation
  silently.

### Deliberate YAGNI cuts

- No persisted "current stage" state.
- No edits to pipeline skills to pass their stage to preflight.
- No attempt to distinguish brainstorming vs assess vs (pre-write) refinement —
  chain state genuinely cannot tell them apart, so all three collapse into one
  honest "pre-chain → refinement" bucket.

## Scope of Change

- `.claude-plugin/plugin.json` — add `git_zhi_min_version` key.
- `skills/preflight/preflight.md` — extend step 1 (Part A); add an orientation
  step after the capabilities map is loaded (Part B); document both in the
  Responsibilities list and Key Constraints.

No other files change. `crochet:verify` is unaffected (it already delegates its
first step to preflight and will inherit both behaviors for free).

## Acceptance Criteria

- [ ] `git_zhi_min_version` present in `.claude-plugin/plugin.json` set to `0.3.9`
- [ ] Preflight extracts installed version from `git zhi version` line 1, field 2
- [ ] Preflight warns (does not block) when installed `<` minimum
- [ ] Preflight skips the version check silently when the version is unparseable or the key is absent
- [ ] Preflight infers pre-chain vs chain-built vs mid-execute vs ready vs complete from `git zhi status`/`list` JSON
- [ ] Preflight reports observed facts alongside the inferred next gate
- [ ] Orientation never blocks; it skips silently on unexpected `status` errors
- [ ] No new skill, command stub, or persisted state file is introduced
