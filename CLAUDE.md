# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What This Is

Crochet is a Claude Code plugin — an intelligence layer for
[git-zhi](https://github.com/perigrin/git-zhi). It provides skills that drive
an SDLC pipeline: assess a PRD against a codebase, decompose it into an
executable chain of issues, review the chain for quality, execute issues via TDD
with review gates, and run retrospectives at milestone completion.

Crochet interacts with chain state exclusively through `git zhi` CLI commands.
It never accesses `refs/zhi/` directly.

## Architecture

### Plugin Structure

```
.claude-plugin/plugin.json   — plugin manifest (name, version, skill/command dirs)
skills/<name>/<name>.md      — skill definitions (the LLM instructions)
skills/<name>/*.md           — supporting files (agent prompts, templates, procedures)
commands/<name>.md            — user-invocable command stubs that delegate to skills
```

A **skill** is a markdown file with YAML frontmatter (`name`, `description`)
followed by instructions the LLM follows. A **command** is a thin stub with a
`description` in frontmatter and a one-line delegation: "Use the crochet:<name>
skill to handle this request."

### SDLC Pipeline (strict order)

```
superpowers:brainstorming → crochet:assess → crochet:refinement → crochet:chain-review → crochet:execute → crochet:postmortem
```

Each step is a gate — do not proceed until the current step passes.

### Skill Roles

**Pipeline skills** drive the SDLC sequence. **Infrastructure skills**
(install, preflight, crochet:verify, onboard) set up the environment. **Support skills**
(import, report) serve auxiliary workflows.

### crochet:refinement Agent Roles

Refinement dispatches four sequential agent roles, each with its own system
prompt in `skills/refinement/`:

1. **Architect** (`architect-prompt.md`) — reads spec + codebase, creates milestone
2. **Decomposer** (`decomposer-prompt.md`) — breaks spec into issues with deps, TDD steps, positive ACs
3. **SQE** (`sqe-prompt.md`) — adds negative scenarios (never sees implementation code)
4. **Tech Writer** (`techwriter-prompt.md`) — adds doc update steps and standalone doc issues

### crochet:execute Loop Structure

Execute has two nested loops:
- **Inner loop:** Ralph Loop (iterative TDD cycle per issue) with `/simplify` as inner gate
- **Outer loop:** Sanbao gate analysis determines review tier, then PAAD skills (alignment, architecture, review) validate. Up to 3 reopen cycles per issue.

### Superpowers/PAAD Integration

Crochet builds on top of superpowers and paad when they are installed.
See `docs/plans/2026-03-28-superpowers-paad-integration-design.md` for the
full design. The pattern: detect availability via capabilities manifest
(`.claude/crochet/capabilities.json`), delegate to the skill when present,
fall back to inline behavior when absent.

## Conventions

- Every skill file starts with YAML frontmatter: `name` and `description`
- Every skill's Prerequisites section checks `which git-zhi` and directs to `crochet:install` if missing
- All chain interaction through `git zhi` CLI — never access `refs/zhi/` directly
- Skills are idempotent: re-invoking on partial state resumes from current chain state
- The shared prerequisite block is in `skills/require-git-zhi.md`

## Working in This Repo

There is no build step, test suite, or compiled output. The deliverables are
markdown skill files. Changes are validated by reading the skill, checking its
internal consistency (do the steps reference real `git zhi` subcommands?), and
verifying the command stub delegates correctly.

When adding a new skill:
1. Create `skills/<name>/<name>.md` with frontmatter
2. Create `commands/<name>.md` that delegates to it
3. Update `README.md` skills table
4. Update `.claude-plugin/plugin.json` description if the skill changes the plugin's scope
