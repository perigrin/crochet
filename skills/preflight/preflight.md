---
name: preflight
description: Internal infrastructure skill — runs before every crochet skill to check git-zhi availability, read or create the capabilities manifest, cross-check it against the system-reminder skill list, and return a capabilities map
---
<!-- ABOUTME: Internal infrastructure skill invoked at the start of every crochet skill invocation. -->
<!-- ABOUTME: Checks git-zhi availability and maintains the capabilities manifest at .claude/crochet/capabilities.json. -->

# crochet:preflight

**Internal skill.** This skill is invoked by other crochet skills as their first step. It is not intended to be invoked directly by users. Users who want an explicit environment health check should use `crochet:verify` instead.

## Responsibilities

Preflight runs six checks in order:

1. **Check git-zhi availability** — run `which git-zhi`. If not found, stop and tell the user to run `crochet:install`.
2. **Read or create capabilities manifest** — read `.claude/crochet/capabilities.json`. If the file does not exist, create it by scanning for installed plugin skills (see Manifest Creation below).
3. **Cross-check manifest against system-reminder skill list** — compare the skills listed in the manifest against the skills present in the current system-reminder. Additions and removals both count as discrepancies.
4. **Update manifest on discrepancy** — if the cross-check finds a discrepancy, update the manifest and tell the user what changed (e.g. "Detected superpowers:dispatching-parallel-agents is now available — updated capabilities manifest").
5. **Warn if manifest cannot be written** — if the filesystem is read-only or the write fails for any reason, warn the user: "Cannot write capabilities manifest — using runtime-only detection for this session." Proceed with in-memory detection for the rest of the session.
6. **Return capabilities map** — make the capabilities map available to the calling skill so it can apply the conditional reference pattern (see Usage below).

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

## Fallback Behavior

If the manifest cannot be read or written (read-only filesystem, permission error, disk full), preflight falls back to in-memory detection for the current session:

1. Warn the user: "Cannot write capabilities manifest — using runtime-only detection for this session."
2. Build the capabilities map from the system-reminder skill list without persisting it.
3. Proceed normally — all conditional reference checks in the calling skill work from the in-memory map.

The fallback does not retry the write during the same session.

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
