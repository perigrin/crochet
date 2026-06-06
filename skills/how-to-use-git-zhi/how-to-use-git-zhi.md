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
