---
name: preflight
description: Internal infrastructure skill — runs before every crochet skill to check git-zhi availability and version, read or create the capabilities manifest, cross-check it against the system-reminder skill list, report pipeline orientation, and return a capabilities map
---
<!-- ABOUTME: Internal infrastructure skill invoked at the start of every crochet skill invocation. -->
<!-- ABOUTME: Checks git-zhi availability and maintains the capabilities manifest at .claude/crochet/capabilities.json. -->

# crochet:preflight

**Internal skill.** This skill is invoked by other crochet skills as their first step. It is not intended to be invoked directly by users. Users who want an explicit environment health check should use `crochet:verify` instead.

## Responsibilities

Preflight runs seven checks in order:

1. **Check git-zhi availability and version** — run `which git-zhi`. If not found, stop and tell the user to run `crochet:install`. If found, run `git zhi version`, take the first line (shaped `git-zhi <semver> (<os>/<arch>)`), and read the second whitespace-delimited field as the installed semver. Read `git_zhi_min_version` from `.claude-plugin/plugin.json` and compare as a numeric triplet (major, then minor, then patch). If the installed version is **older** than the minimum, **warn and continue — do not block**:

   > Installed git-zhi `<installed>` is older than the minimum `<minimum>` this Crochet version expects. Some `git zhi` commands may behave unexpectedly. Run `crochet:install` or `git zhi update` to upgrade.

   **Fail open:** if the version line cannot be parsed, or `git_zhi_min_version` is absent from `plugin.json`, skip the version comparison silently. A version-check failure must never block a skill.
2. **Read or create capabilities manifest** — read `.claude/crochet/capabilities.json`. If the file does not exist, create it by scanning for installed plugin skills (see Manifest Creation below).
3. **Cross-check manifest against system-reminder skill list** — compare the skills listed in the manifest against the skills present in the current system-reminder. Additions and removals both count as discrepancies.
4. **Update manifest on discrepancy** — if the cross-check finds a discrepancy, update the manifest and tell the user what changed (e.g. "Detected superpowers:dispatching-parallel-agents is now available — updated capabilities manifest").
5. **Warn if manifest cannot be written** — if the filesystem is read-only or the write fails for any reason, warn the user: "Cannot write capabilities manifest — using runtime-only detection for this session." Proceed with in-memory detection for the rest of the session.
6. **Report pipeline orientation** — run `git zhi status --format json` (and `git zhi issue list --all --format json` to resolve soft boundaries) and report the agent's position in the SDLC pipeline plus the likely next gate, following the inference table in the Pipeline Orientation section below. This is advisory output only — it never blocks, and it skips silently on any `git zhi status` error other than an empty chain. Before running any `git zhi` write command (`issue add`, `issue edit`, `milestone add/edit`), consult `crochet:how-to-use-git-zhi` for the exact syntax and input mode.
7. **Return capabilities map** — make the capabilities map available to the calling skill so it can apply the conditional reference pattern (see Usage below).

## Manifest

The capabilities manifest is stored at `.claude/crochet/capabilities.json`. It is machine-specific — it records what plugins are installed on this user's machine — and must be gitignored. When creating `.claude/crochet/` for the first time, add `.claude/crochet/capabilities.json` to `.gitignore`.

### Schema

```json
{
  "last_updated": "2026-03-28T14:30:00Z",
  "plugins": {
    "superpowers": {
      "installed": true,
      "skills": {
        "dispatching-parallel-agents": true,
        "systematic-debugging": true,
        "test-driven-development": true,
        "verification-before-completion": true,
        "simplify": true,
        "brainstorming": true
      }
    },
    "paad": {
      "installed": true,
      "skills": {
        "pushback": true,
        "alignment": true,
        "agentic-review": true,
        "agentic-architecture": true
      }
    }
  }
}
```

### Manifest Creation

When the manifest does not exist, scan these locations for installed plugin skills:

- **Superpowers:** `~/.claude/skills/` — look for skill directories by name
- **PAAD:** `~/.claude/plugins/marketplaces/paad/plugins/paad/skills/`
- **Superpowers plugin cache:** `~/.claude/plugins/cache/superpowers-marketplace/`

Set `"installed": true` for a plugin if any of its skills are found. Set each skill entry to `true` if the skill file is present on disk.

### Cross-Check Against system-reminder

The system-reminder lists available skills at runtime. After reading the manifest, compare the `superpowers:*` and `paad:*` skill names in the system-reminder against the manifest entries. If a skill appears in system-reminder but not the manifest, or appears in the manifest but not system-reminder, that is a discrepancy — update the manifest and report the change.

**Crochet's own skills are deliberately absent from the manifest, and must not be added.** Each one ships in this plugin, so it is always present — there is nothing to detect. A `crochet:*` skill also cannot be cross-checked here: the runtime list carries only skills with a `commands/` stub, so every internal one (`preflight`, `alignment`, `pushback`, `discernment`, `how-to-use-git-zhi`) is invisible to it by construction.

So never guard a crochet sibling behind a capability check. The check cannot pass, the guarded branch never runs, and the `Otherwise` fallback becomes a silent second implementation of the thing the sibling exists to hold. Invoke it directly. The conditional pattern exists for plugins that may not be installed, which crochet is not to itself.

## Fallback Behavior

If the manifest cannot be read or written (read-only filesystem, permission error, disk full), preflight falls back to in-memory detection for the current session:

1. Warn the user: "Cannot write capabilities manifest — using runtime-only detection for this session."
2. Build the capabilities map from the system-reminder skill list without persisting it.
3. Proceed normally — all conditional reference checks in the calling skill work from the in-memory map.

The fallback does not retry the write during the same session.

## Pipeline Orientation

The SDLC pipeline runs in strict order:

```
superpowers:brainstorming → crochet:assess → crochet:refinement →
crochet:chain-review → crochet:execute → crochet:review → crochet:postmortem
```

Preflight infers the agent's position from chain state. The **absence** of chain
state is itself meaningful — it means the work is still in the pre-chain stages.

**Primary signal:** `git zhi status --format json` (exit 0 even on an empty
chain). To resolve the soft boundaries, also consult `git zhi issue list --all
--format json`, whose entries carry a per-issue `state`. Do **not** use `git zhi
next` as the primary signal — it errors on an empty chain where `status` degrades
gracefully.

**Use `issue list --all`, not `list`.** A completed milestone lists nothing
without `--all`, and with the wrong command row 1 matches first and reports "No
chain yet" for a finished chain, so row 3 is never reached.

Through 0.6.0 the reason was that `--all` was inert on the top-level `list` —
observed against a repository with three completed milestones and twenty closed
issues, where `list --all` returned nothing and `issue list --all` returned the
twenty. **That was fixed in 0.7.0 and both forms now return every issue**, so
the old conclusion — "adding a flag does not fix it; the command has to change"
— is false on every version this plugin supports.

The reason to keep `issue list --all` is now shape, not coverage: it returns a
bare JSON array, where `list` returns `{"issues": [...]}`. An orientation step
written against one and run against the other parses nothing and reports an
empty chain — the same row-1 misdiagnosis by a different route.

Evaluate these rows **in order** and report the first that matches:

| # | Chain state observed | Inferred position | Reported next gate |
|---|---|---|---|
| 1 | No milestone anywhere; `issue list --all` empty | Pre-chain (brainstorming → assess) | "No chain yet — next gate is `crochet:assess`, whose outcome is the acceptance" |
| 2 | Milestone exists; zero issues | Refinement pending | "Milestone exists but is empty — next gate is `crochet:refinement` to decompose it" |
| 3 | Milestone exists; an issue is `in-progress` | Mid-execute | "Executing issue `<title>` — continue `crochet:execute`" |
| 4 | Milestone exists; all issues closed; none `pending`/`in-progress` | Chain complete | "All issues closed — next gate is `crochet:review`, then `crochet:postmortem`" |
| 5 | Milestone exists; one or more issues `pending`; none `in-progress` | Chain built / ready to execute | "Chain ready — next gate is `crochet:chain-review`, then `crochet:execute` (`<N>` ready)" |
| 6 | Milestone exists, but JSON matches none of the above | Unknown | Skip orientation silently (fail open) |

Rows 3 and 4 are the unambiguous states. Row 5 deliberately merges "chain just
built" and "ready to execute" — they are indistinguishable from `status` alone
(an all-`pending` chain always has `ready_count > 0`), so the single row keeps
the `chain-review`-then-`execute` phrasing visible rather than forcing a choice.
Row 6 is the explicit fallback for an unrecognized shape: never guess, never block.

Row 2 is new and is the state refinement leaves behind when a milestone is
created before its issues exist. It was previously swallowed by row 1, which
reported "no chain yet" for a milestone that plainly existed.

**Report facts alongside the inference.** Print the observed state next to the
inferred gate, e.g.:

```
Pipeline: milestone v0.1, 1 ready, 0 in progress, 0 closed
Next gate: crochet:chain-review, then crochet:execute
```

so the agent can see the basis and override a wrong inference.

## Usage by Downstream Skills

Downstream skills check preflight capabilities using this conditional reference pattern:

```markdown
**If `<skill>` is available** (check preflight capabilities):
  <delegate to the skill — follow it, do not reimplement>

**Otherwise:**
  <inline fallback behavior>
```

The skill is named explicitly. The fallback is the simpler or current inline behavior. Downstream skills never reimplement what a plugin skill already provides.

## Key Constraints

- **No command stub.** Preflight has no corresponding file in `commands/`. It is not a user-invokable slash command. Other crochet skills invoke it by name as their first step.
- **Lightweight and automatic.** Preflight is designed to be fast. It is not a thorough environment health check — that is the job of `crochet:verify`.
- **Never block on discrepancy.** When the manifest is updated, tell the user what changed and continue. Do not pause for confirmation.
- **Never reimplement plugin skills.** When a plugin skill is available, delegate to it. Describe what to do, not how to do it.
- **Version check and orientation are advisory.** Both the git-zhi version warning and pipeline orientation report information and continue. Neither ever blocks a skill, and both fail open — on a parse failure, missing key, or unexpected `git zhi status` shape, skip the affected report silently.
