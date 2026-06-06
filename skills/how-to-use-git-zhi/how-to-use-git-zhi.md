---
name: how-to-use-git-zhi
description: Agent-facing git-zhi command reference — consult before running any `git zhi` command, especially writes that take stdin. Maps intents to commands, input modes, and output.
---
<!-- ABOUTME: Internal agent-facing reference mapping intents to git zhi commands, input modes, and output. -->
<!-- ABOUTME: Consulted before running git zhi commands; not user-invocable and has no commands/ stub. -->

# crochet:how-to-use-git-zhi

**Internal skill.** An agent-facing command reference for day-to-day git-zhi
operation. Consulted by name; no `commands/` stub, no user-facing slash command.
It does not cover adoption (`crochet:onboard`) or binary setup (`crochet:install`)
— it assumes git-zhi is installed and a chain exists.

## Prerequisites

Before proceeding, verify that `git-zhi` is available by running `which git-zhi`.
If not found, run `crochet:install` to set it up.

## The stdin convention

Titles and short metadata are positional args or flag values. **`issue edit`
body/batch/split content arrives via stdin pipe — not as arguments.** Note the
asymmetry: **`issue add` has NO stdin form** — it needs a positional title and
a `--body` flag; only `issue edit --body`/`--batch`/`--split` read stdin.

```bash
# WRONG: issue add does NOT read a body from stdin (errors: title required / no content)
echo "Long body text..." | git zhi issue add "Fix login"
# RIGHT: issue add takes a positional title and a --body flag
git zhi issue add "Fix login" --body "Long body text..."

# stdin IS the input mode for issue edit body replacement:
echo "New body text..." | git zhi issue edit <ref> --body
```

This asymmetry is verified against the binary and matches the repo's own
`skills/refinement/refinement.md:77` ("no working stdin/batch form" of issue add).

## State model: verbs vs nouns

`git zhi issue edit <ref> --state` takes a transition **verb**:
`start`, `pause`, `resume`, `done`, `cancel`.
`git zhi status` / `git zhi list --format json` **report** a state **noun**.
The two vocabularies are different — an agent reading a noun must map back to the verb.

| Reported noun | Reached by | Advanced by |
|---|---|---|
| `pending` | (initial state on `issue add`) | `start` → `in-progress` |
| `in-progress` | `start` (also where `pause`/`resume` land — no distinct `paused` noun) | `done` → `done` |
| `done` | `done` | (terminal) |

Note: the reported noun is `in-progress` with a **hyphen**, not `in_progress`.

## Intent → command

| Intent | Command | Input mode | Output |
|---|---|---|---|
| Find next work | `git zhi next [--actor <id>] [--label <l>]` | flag | the HEAD issue |
| Inspect the chain | `git zhi list [--ready] [--milestone <m>] [--label <l>] [--all] [--critical]` | flag | issue list |
| View an issue | `git zhi issue show [<ref>]` | arg | issue detail |
| Check work state | `git zhi status` | none | HEAD + ready_count |
| Create an issue | `git zhi issue add "<title>" --body "<text>" [--milestone <m>]` | arg + flag | new issue (JSON array) |
| Transition / edit an issue | `git zhi issue edit <ref> --state <verb> [--assign <id>] [--label <l>] …` | arg + flag | updated issue |
| Replace an issue body | `git zhi issue edit <ref> --body` | stdin | updated issue |
| Bulk edits | `git zhi issue edit <ref> --batch` | stdin (JSON ops) | results |
| Split an issue | `git zhi issue edit <ref> --split` | stdin | new issues |
| Manage milestones | `git zhi milestone add|edit|list|show <name>` | arg + flag | milestone(s) |

Input mode is one of `arg` (positional), `flag`, `stdin` (piped), or `none`.
Note the asymmetry from the stdin section: `issue add` is `arg + flag` (no stdin);
`issue edit --body`/`--batch`/`--split` are `stdin`.

## JSON output (field inventory)

Pass `--format json` (a global flag) to get machine-readable output. For commands
an agent parses, the keys it relies on:

- **`git zhi status`** — `head`, `title`, `state`, `milestone`, `ready_count` (and a `message` field with `ready_count` instead of the chain keys when no chain exists). The literal shape is documented canonically in the **Pipeline Orientation** section of `crochet:preflight`; consult that rather than duplicating it here.
- **`git zhi list`** — `{ "issues": [ … ] }`; each issue carries `id`, `title`, `state`, `urgency`, `milestone`, `labels`, `created`, `updated`, `body`. Canonical shape: see `crochet:preflight`'s orientation section.
- **`git zhi next`** — the same per-issue keys as a `list` issue plus a `description` key (it resolves the HEAD issue). Errors when the chain is empty.
- **`git zhi issue show <ref>`** — the same per-issue keys as `next` (the `list` issue keys plus `description`).

To see the live shape of any of these, run `git zhi <cmd> --format json`.
