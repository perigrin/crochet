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
`start`, `pause`, `resume`, `done`, `cancel`, `reopen`.
`git zhi status` / `git zhi list --format json` **report** a state **noun**.
The two vocabularies are different — an agent reading a noun must map back to the verb.

| Reported noun | Reached by | Advanced by |
|---|---|---|
| `pending` | (initial state on `issue add`) | `start` → `in-progress` |
| `in-progress` | `start` (also where `pause`/`resume` land — no distinct `paused` noun) | `done` → `done` |
| `done` | `done` | `reopen` → `reopened` |
| `reopened` | `reopen`, and only from `done` | `start` → `in-progress` |

Note: the reported noun is `in-progress` with a **hyphen**, not `in_progress`.

Note: the `--state` flag's own `--help` string lists only `start, pause, resume, done, cancel` — it omits `reopen`, which the state machine accepts. This is the one place the "`--help` wins" rule below is known to be wrong, and it matters because `crochet:execute` depends on `reopen` for its PAAD review cycle. Observed on the installed binary rather than read from the help text.

## Intent → command

| Intent | Command | Input mode | Output |
|---|---|---|---|
| Find next work | `git zhi next [--label <l>]` — bare, with `ZHI_ACTOR` set | env | the HEAD issue for this worker |
| Find next work across repos | `git zhi project next <file.yaml>` — needs an identity | env or flag | cross-repo recommendation |
| Inspect the chain | `git zhi list [--ready] [--milestone <m>] [--label <l>] [--critical]` | flag | open issues |
| Inspect the chain, including done | `git zhi issue list --all` | flag | every issue |
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

## Worker identity: `ZHI_ACTOR`

Every transition records who made it. A process declares itself by exporting:

```bash
export ZHI_ACTOR=agent:worker-3
```

The actor resolves in order: an explicit `--actor` flag where a command has one,
then `ZHI_ACTOR`, then a derivation from git's `user.name` and `user.email`.

**Only `next` and `project next` take `--actor`, and both are read-side.** No
write command has the flag (git-zhi ADR 0004), so on the write path `ZHI_ACTOR`
is the only way to declare an identity. Use bare `git zhi next` with the
variable exported rather than `next --actor`: passing it on the read side while
the write side reads the environment is how one worker ends up with two
identities.

The value must name its type — `agent:` or `human:`. A bare string is refused
at this boundary rather than defaulted, because defaulting would silently record
agents as humans. To override for a single command, prefix the assignment:

```bash
ZHI_ACTOR=human:chris git zhi issue edit <ref> --state done
```

With nothing exported, behaviour is exactly what it was before this existed:
the git-author derivation, one actor, no migration.

**Why this matters.** Every agent in one repository shares the git author
config, so without a declared identity they all resolve to the same actor —
`next` hands each of them whatever another started, and the exclusion that
keeps two workers off one issue excludes nothing. Identity is for coordination,
never authorization: a declared value is unverified and is not a basis for
deciding what a worker may do.

Requires git-zhi 0.6.0. `sh xt/zhi-actor-probe.sh` asserts the installed binary
honours it.

## JSON output (field inventory)

Pass `--format json` (a global flag) to get machine-readable output. For commands
an agent parses, the keys it relies on:

- **`git zhi status`** — `head`, `title`, `state`, `milestone`, `ready_count` (and a `message` field with `ready_count` instead of the chain keys when no chain exists). `crochet:preflight`'s **Pipeline Orientation** section shows how these keys map to pipeline position; run `git zhi status --format json` for the live shape.
- **`git zhi list`** — `{ "issues": [ … ] }`; each issue carries `id`, `title`, `state`, `urgency`, `milestone`, `labels`, `created`, `updated`, `body`. `crochet:preflight` uses these same keys for orientation; run `git zhi list --format json` for the live shape.
- **`git zhi next`** — the same per-issue keys as a `list` issue plus a `description` key (it resolves the HEAD issue). Errors when the chain is empty.
- **`git zhi issue show <ref>`** — the same per-issue keys as `next` (the `list` issue keys plus `description`).

To see the live shape of any of these, run `git zhi <cmd> --format json`.

## When this reference and the CLI disagree

Confirm the current surface with `git zhi <cmd> --help`. This reference is
verified against git-zhi 0.4.0, and the CLI evolves. **When `--help` and this
reference disagree, `--help` wins** — proceed using `--help`'s current surface
and do not treat this reference as authoritative for that command.

git-zhi marks unfinished surfaces inline in its own `--help` output (e.g.
"not yet implemented"), so for whether a specific flag works, trust `--help`.
For example, `git zhi issue add --after`/`--before` and `git zhi list --graph`
are not yet implemented — but treat that as an illustration of the pattern, not
a maintained list; always confirm with `--help`.

**`--help` can also be wrong, and one case is on record.** Through 0.6.0,
`git zhi list --help` advertised `--all  include done and cancelled issues`
while the flag was accepted, exited 0 and changed nothing — output with it was
byte-identical to output without. It was fixed in 0.7.0 and both forms now
return every issue. The habit it earned outlives it: where a flag's effect
matters, check that the output changed rather than that the command succeeded.

## Companion subcommands

Companion subcommands — `historian`, `jira`, `sanbao`, `docs`, `mermaid`, `project` — exist; run `git zhi <name> --help` for their surface.
