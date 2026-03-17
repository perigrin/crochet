---
name: report
description: Generate narrative reports from user-defined templates by collecting data via git zhi CLI commands and synthesizing with embedded Mermaid charts
---

# crochet:report

Reads a user-defined report template, executes the declared data collection commands, and synthesizes a narrative report with embedded Mermaid charts.

## Trigger

User invokes `crochet:report <template-name>` or `crochet:report <template-name> --milestone <name>`.

## Template Discovery

Search in order:
1. `docs/reports/<name>.md` in the current repo
2. `~/.config/zhi/reports/<name>.md` for personal templates
3. If not found, list available templates and ask

## Template Format

```yaml
---
name: recurring-status
data:
  - git zhi project report auth-overhaul --format json
  - git zhi sanbao report HEAD --format json
  - git zhi verify HEAD --format json
  - git zhi docs health --format json
schedule: recurring
---

## Prompt

Produce a team status report. Professional tone, direct. Lead with
what shipped, then risks, then forecast. Embed mermaid-gantt and
mermaid-dag charts. Keep under 500 words.

## Structure

### Summary
### What Shipped
### Risks & Blockers
### Forecast
### Quality Health
### Charts
```

## Process

1. **Find template** by name in discovery paths
2. **Parse frontmatter** for `data:` commands and `schedule:` metadata
3. **Execute each data command** via shell, collect JSON output
4. **Read the prompt section** for narrative guidance (tone, length, emphasis)
5. **Generate content** following the structure sections exactly, in order
6. **Embed Mermaid charts** by piping JSON data through `git zhi mermaid gantt` and `git zhi mermaid dag`, wrapping output in fenced code blocks
7. **Output** the completed report to stdout or a specified file

## Key Constraints

- **Structure is authoritative.** Produce exactly the sections listed in `## Structure`, in that order. The prompt provides narrative guidance within the structure — it does not override or reorder sections.
- **Data commands are the only data source.** Do not fabricate metrics. If a command fails or returns empty, note it in the report rather than guessing.
- **Charts are generated, not hand-drawn.** Pipe JSON through `git zhi mermaid gantt|dag` for chart content. Wrap in ` ```mermaid ` fenced blocks.
- **If a data command requires a milestone and none was specified via `--milestone`,** use the most recently active milestone from `git zhi milestone list --format json`.
