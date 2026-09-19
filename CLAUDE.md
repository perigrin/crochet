<!-- ABOUTME: The agent's door onto crochet's live documentation layer. -->
<!-- ABOUTME: Imports the live documents rather than restating them; holds only what is agent-specific. -->
# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What This Is

Crochet is a Claude Code plugin — an intelligence layer for
[git-zhi](https://github.com/perigrin/git-zhi). It provides skills that drive
an SDLC pipeline: assess a spec against a codebase, decompose it into an
executable chain of issues, review the chain for quality, execute issues via
TDD with review gates, and run retrospectives at milestone completion.

## The live layer

@docs/architecture/plugin-structure.md
@docs/contributing/coding-conventions.md
@docs/contributing/development-workflow.md

Those three are imported rather than pointed at. For an agent an import is
static linking; "see CONTRIBUTING.md" is a dynamic lookup that may not happen.
They are also the three documents `git zhi docs health` watches, so a claim in
any of them that drifts from the code it covers is detectable rather than
merely wrong.

Nothing from `docs/decisions/` or `docs/postmortems/` is imported. Those are
archive — true as of their date, read when a question about *why* arises, and
not worth carrying in every agent's context.

## Working here as an agent

- **Read the live layer above before changing a skill.** It is imported, so it
  is already in context; the conventions and the validation model live there,
  not here.
- **All chain interaction goes through the `git zhi` CLI.** Never read or write
  `refs/zhi/` directly.
- **Probe for a capability rather than testing for a filename.** A stale
  symlink can sit on `$PATH` and no longer dispatch, so `git zhi <sub> --help`
  answers the real question where `test -x` does not.
- **Observation beats inference.** Where a skill asserts how the CLI behaves,
  that assertion should come from running the command in a scratch repository,
  not from another document that says so.
- **Update a live document before the change it describes**, in the same
  commit. The reasoning is in
  `docs/decisions/0001-documentation-architecture.md`.
- **Every commit implementing a numbered decision carries its trailer** —
  `Implements: NNNN` — in the final trailer block, where git parses it as a
  trailer rather than as prose.

## The pipeline

```
superpowers:brainstorming → crochet:assess → crochet:refinement → crochet:chain-review → crochet:execute → crochet:postmortem
```

Each step is a gate. Asking for refinement against a proposed decision is what
accepts it; see `docs/decisions/0003-acceptance-by-refinement.md`.
