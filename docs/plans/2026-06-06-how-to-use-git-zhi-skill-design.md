<!-- ABOUTME: Design for crochet:how-to-use-git-zhi, an internal agent-facing git-zhi command reference. -->
<!-- ABOUTME: Maps agent intents to git zhi commands with input modes, the verb-vs-noun state model, and JSON shapes. -->
# crochet:how-to-use-git-zhi — Agent-Facing Command Reference

## Summary

Add an internal, agent-facing skill that maps day-to-day agent intents
("find next work", "start/finish an issue", "inspect the chain", "query state
as JSON", "create issues") to the exact `git zhi` subcommands — including each
command's **input mode** (positional arg, flag value, or stdin pipe), the
**verb-vs-noun state model**, and the `--format json` output shapes.

It is a reference an agent consults mid-task, not a procedure. It does **not**
cover first-time adoption (`crochet:onboard` and `skills/onboard/procedure.md`
own that) or binary setup (`crochet:install`). It assumes git-zhi is installed
and a chain exists.

## Motivation

git-zhi command knowledge is currently scattered: the onboard procedure shows
adoption-time commands, the preflight orientation table documents the JSON
shapes it branches on, and individual skills embed the subcommands they happen
to use. There is no single place an agent consults to answer "what command do
I run to do X, and how does its input arrive." Two facts in particular are easy
to get wrong from memory and have no home today:

- **Input mode.** Several write commands read from **stdin**, not arguments
  (`issue edit --body`, `--batch`, `--split`; `issue add` body-via-stdin). An
  agent that passes a multi-line body as a positional argument fails.
- **Verb-vs-noun state.** `issue edit --state` takes transition **verbs**
  (`start`, `pause`, `resume`, `done`, `cancel`), while `status`/`list
  --format json` **report** state **nouns** (`pending`, `in_progress`, …). The
  onboard procedure uses the verbs; the preflight orientation table reads the
  nouns. Nothing documents the mapping between them.

## Identity and Structure

- **Internal skill, no command stub.** Follows the `crochet:preflight`
  precedent: agent-facing, consulted by name, with no file in `commands/` and
  no row in the README user-facing skills table. It is listed in the README
  "internal skills" note alongside `pushback` and `alignment`.
- **Location:** `skills/how-to-use-git-zhi/how-to-use-git-zhi.md` — single file.
- **Conventions:** ABOUTME header (two `ABOUTME:` lines); YAML frontmatter with
  `name` and `description`; includes the shared `require-git-zhi` prerequisite.
- **Description is the discovery surface.** It must be sharp enough that the
  agent's skill selection picks it up when a `git zhi` command is needed —
  e.g. "Agent-facing git-zhi command reference — consult before running any
  `git zhi` command, especially writes that take stdin."

## Content (intent-first ordering)

### 1. The stdin convention (lead section)

State the rule plainly: titles and short metadata are positional args or flag
values; **bodies, batch edits, and splits arrive via stdin pipe.** Include the
canonical failure it prevents:

```bash
# WRONG: body as positional arg
git zhi issue add "Fix login" "Long body text..."
# RIGHT: title as arg, body via stdin
echo "Long body text..." | git zhi issue add "Fix login"
```

### 2. Intent → command table

The core. Columns: **Intent** | **Command** | **Input mode** | **Output**.
Every row marks input mode explicitly as one of `arg` / `flag` / `stdin` /
`none`. Verified surface to cover:

| Intent | Command | Input mode | Output |
|---|---|---|---|
| Find next work | `git zhi next [--actor <id>] [--label <l>]` | flag | issue (HEAD) |
| Inspect the chain | `git zhi list [--ready] [--milestone <m>] [--label <l>] [--all] [--critical]` | flag | issue list |
| View an issue | `git zhi issue show [<ref>]` | arg | issue detail |
| Check work state | `git zhi status` | none | HEAD + ready_count |
| Create an issue | `git zhi issue add "<title>" [--body <text>] [--milestone <m>]` (body also via stdin) | arg + stdin | new issue |
| Transition / edit an issue | `git zhi issue edit <ref> [--state <verb>] [--assign <id>] [--label <l>] …` | arg + flag | updated issue |
| Replace an issue body | `git zhi issue edit <ref> --body` | stdin | updated issue |
| Bulk edits | `git zhi issue edit <ref> --batch` | stdin (JSON ops) | results |
| Split an issue | `git zhi issue edit <ref> --split` | stdin | new issues |
| Manage milestones | `git zhi milestone add\|edit\|list\|show <name>` | arg + flag | milestone(s) |

(Exact flag lists are re-verified against the binary during implementation; the
table above is the intent skeleton, not the final authority.)

### 3. State model: verbs vs nouns

A dedicated subsection. `issue edit --state` takes transition **verbs**:
`start`, `pause`, `resume`, `done`, `cancel`. `status` / `list --format json`
**report** state **nouns** (e.g. `pending`, `in_progress`). A small mapping
table lets an agent that reads `"state": "in_progress"` know the verb that
reached it (`start`) and the verb that advances it (`done`).

> The exact set of reported state nouns is harvested from the live binary
> during implementation — not hand-authored — and must agree with both the
> onboard procedure and the preflight orientation table.
>
> **Observation directive.** The current chain contains only `pending` issues,
> so the other nouns cannot be read from existing state. Implementation must
> create a throwaway issue and transition it through the verbs to observe the
> real reported nouns: `git zhi issue add` a scratch issue, then
> `git zhi issue edit <ref> --state start` and capture the reported `state`,
> `--state done` and capture again (and `pause`/`cancel` as needed), then
> `git zhi issue edit <ref> --purge --yes` to remove it. The mapping table is
> built from what was observed, not inferred.

### 4. JSON output (field inventory, not literal blocks)

Document the `--format json` global flag and, for the commands an agent parses
programmatically (`status`, `list`, `next`, `issue show`), list the **keys an
agent relies on** rather than pasting whole JSON objects — e.g. `status`:
`head`, `title`, `state`, `milestone`, `ready_count`. A field inventory has a
lower drift surface than literal structures (key names change less often than
full shapes) and a stale literal block fails silently — the agent parses
against a wrong schema rather than getting an error.

Each entry carries a one-line "run `git zhi <cmd> --format json` to see the
live shape" pointer. Do **not** duplicate the literal `status`/`list` blocks
already documented in the preflight orientation section; point to preflight as
the canonical source for those two and keep this section to the key inventory,
so the two files cannot drift apart.

### 5. Per-section --help pointer (self-correcting)

Each section carries the drift-handling clause: "If a command errors or behaves
unexpectedly, confirm the current surface with `git zhi <cmd> --help`. This
reference is verified against git-zhi `<version>` and the CLI evolves." Add the
resolution rule explicitly: **when `--help` and this reference disagree,
`--help` wins** — proceed using `--help`'s current surface and do not treat this
reference as authoritative for that command.

Rather than maintaining a list of unfinished flags (which rots in both
directions as flags graduate to implemented), state the **principle**: git-zhi
marks unfinished surfaces inline in its own `--help` output (e.g. "not yet
implemented"), so for whether a specific flag works, **trust `--help` over this
reference**. Cite `issue add --after/--before` and `list --graph` as
illustrations of the pattern, not as a maintained registry.

> **Version anchor directive.** The `<version>` recorded in the self-correction
> clause is the version actually exercised during the behavioral walkthrough —
> i.e. the output of `git zhi version` on the machine where the skill is
> verified (currently `0.4.0`), not the `git_zhi_min_version` floor (`0.3.9`).
> The string records what was tested, so an agent can judge how stale the
> reference may be against its own installed version.

## Discovery Wiring

**Discovery follows the proven pattern in this repo, not description-driven
auto-selection.** Every internal skill here (`preflight`, `pushback`,
`alignment`) is reached by an **explicit by-name reference from another skill's
steps** — "Run `crochet:preflight` as the first step", "use `crochet:pushback`
for the plan-quality lens". No internal skill relies on the agent
spontaneously noticing its `description`. This skill is wired the same way:
two shared files carry an explicit by-name pointer.

- `skills/require-git-zhi.md` — append one line: "For command syntax and input
  modes, consult `crochet:how-to-use-git-zhi`." This propagates to every skill
  that includes the prerequisite block.
- `skills/preflight/preflight.md` — extend the existing step 6 ("Report pipeline
  orientation") output guidance with an **explicit directive** (not a soft
  mention): "Before running any `git zhi` write command (`issue add`,
  `issue edit`, `milestone add/edit`), consult `crochet:how-to-use-git-zhi` for
  the exact syntax and input mode." Placing it on the orientation step keeps it
  where the agent is already being told what to do next, and the write-command
  framing matches where the cost of getting input mode wrong is highest.

The sharp frontmatter `description` remains valuable, but it is a secondary
aid, not the primary discovery mechanism — the two explicit pointers are the
load-bearing path.

> **Note for planning.** The exact `--format json` shapes and final flag lists
> are not pre-specified here by design — they are harvested from the live binary
> during implementation (this repo's verify-against-reality model). The plan must
> budget a live-binary inspection step rather than treating the shapes as given.

## Other Touches

- `README.md` — add to the internal-skills note (not the user-facing table).
- `.claude-plugin/plugin.json` — left untouched unless implementation shows the
  plugin scope description genuinely needs it (a reference skill likely does
  not change scope). Confirm during implementation; do not assume an edit.

## Deliberate YAGNI Cuts

- **No companion-subcommand coverage.** `historian`, `jira`, `sanbao`, `docs`,
  `mermaid`, `project` get one line — "these exist; run `git zhi <name>
  --help`." They are optional, plugin-gated, adoption-time surfaces; documenting
  them here would bloat a day-to-day reference and overlap `onboard`.

## Verification (this repo's model — no test harness)

Per `CLAUDE.md`, deliverables are markdown; validation is reading + behavioral
walkthrough against the real `git zhi` CLI.

- **Structural:** frontmatter present; ABOUTME header; no `commands/` stub
  created; README internal-skills note updated; require-git-zhi and preflight
  pointers added.
- **Behavioral (the substantive gate):** every command in the intent table is
  run against the live binary and its actual input mode confirmed — the
  `arg`/`flag`/`stdin`/`none` labels must match reality. The JSON field
  inventory must list keys that actually appear in `--format json` output (the
  inventory, not literal structures, is what gets verified).
- **Cross-consistency:** the verb/noun state table agrees with the onboard
  procedure's transition verbs (`--state start/done`) and with whatever state
  nouns the preflight orientation table uses — no contradiction across the
  three places state is described. **If the observed nouns differ from the
  `in_progress` the preflight orientation table currently assumes, flag it:
  preflight's table may itself be unverified and need correction too.**

## Acceptance Criteria

- [ ] `skills/how-to-use-git-zhi/how-to-use-git-zhi.md` exists with ABOUTME header and `name`+`description` frontmatter
- [ ] No `commands/how-to-use-git-zhi.md` stub is created
- [ ] Skill includes the shared require-git-zhi prerequisite
- [ ] Leads with the stdin-convention section including a WRONG/RIGHT example
- [ ] Intent→command table marks every row's input mode as `arg`/`flag`/`stdin`/`none`, verified against the binary
- [ ] Documents the verb-vs-noun state model with a mapping table, built from nouns OBSERVED by transitioning a throwaway issue through the states (then purging it), not inferred
- [ ] Documents `--format json` output as a per-command field inventory (keys an agent relies on) rather than literal JSON blocks, and points to preflight as canonical for the `status`/`list` shapes rather than duplicating them; verification checks the inventory keys against real output, not literal structures
- [ ] Cross-consistency check is value-agnostic about the state nouns and directs the implementer to flag preflight's assumed `in_progress` for correction if the observed nouns differ
- [ ] Each section carries the `git zhi <cmd> --help` self-correction pointer and records the version actually exercised during verification (the `git zhi version` output, currently `0.4.0`), not the `0.3.9` floor
- [ ] States the "trust `--help` for whether a flag works" principle (git-zhi self-documents unfinished surfaces) rather than maintaining a list of not-yet-implemented flags, and the rule that `--help` wins when it disagrees with the reference
- [ ] Discovery is wired via explicit by-name pointers in require-git-zhi and preflight (the proven internal-skill pattern), with preflight's pointer framed as "consult before any `git zhi` write command"
- [ ] `skills/require-git-zhi.md` points to the skill
- [ ] `skills/preflight/preflight.md` points to the skill
- [ ] README internal-skills note lists the skill; user-facing skills table is unchanged
- [ ] Companion subcommands are covered only by a one-line pointer, not documented in full
