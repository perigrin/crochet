---
stability: 2
covers:
  - skills/
  - commands/
  - .claude-plugin/plugin.json
---

<!-- ABOUTME: Architecture of the crochet plugin — what the codebase is and how its parts fit. -->
<!-- ABOUTME: Covers the skill and command directories and the plugin manifest. -->

# Crochet Architecture

What crochet is, in the present tense. Why it is this way lives in
`docs/decisions/`; how to work on it lives in `CONTRIBUTING.md`.

## Plugin Structure

```
.claude-plugin/plugin.json   — plugin manifest (name, version, skill/command dirs)
skills/<name>/<name>.md      — skill definitions (the LLM instructions)
skills/<name>/*.md           — supporting files (agent prompts, templates, procedures)
commands/<name>.md           — user-invocable command stubs that delegate to skills
```

A **skill** is a markdown file with YAML frontmatter (`name`, `description`)
followed by instructions the LLM follows. A **command** is a thin stub with a
`description` in frontmatter and a one-line delegation: "Use the crochet:*name*
skill to handle this request."

The deliverables are markdown. There is no compiled output, so the thing that
ships and the thing that is read are the same file.

## SDLC Pipeline

```
superpowers:brainstorming → crochet:assess → crochet:refinement →
crochet:chain-review → crochet:execute → crochet:review → crochet:postmortem
```

Each step is a gate. **Which gates are mandatory, and what happens when the loop
is entered somewhere other than the start, is policy rather than architecture:**
`docs/decisions/0003-acceptance-by-refinement.md` settles it and `CLAUDE.md`
summarises it. This document carries the pipeline's shape and stops there.

It previously said the pipeline runs in strict order and that no step proceeds
until the current one passes, which contradicts the backfill rule one import
away — an agent reviewing a finished pull request was told both to enter at
review and not to proceed past brainstorming.

## Skills

Every skill lives in `skills/<name>/`. Those with a stub in `commands/` are
user-invocable; the rest are invoked by name from another skill.

### Pipeline skills

| Skill | Role |
|---|---|
| `assess` | Analyses a spec against the codebase and chain; produces a gap analysis |
| `refinement` | Decomposes a spec into a git-zhi chain of issues |
| `chain-review` | Gate between refinement and execute; runs the two lenses below |
| `execute` | Drives the execution loop, issue by issue |
| `review` | Gate between execute and postmortem; reviews the delivery's diff against the decision |
| `postmortem` | Milestone retrospective, written to `docs/postmortems/` |

### Infrastructure skills

| Skill | Role |
|---|---|
| `install` | Installs the git-zhi binary and its companion commands |
| `preflight` | Runs first in every skill; checks git-zhi, returns the capabilities map, reports pipeline position |
| `verify` | On-demand environment health check, deeper than preflight |
| `onboard` | Walks a repository through git-zhi adoption |

### Support and internal skills

| Skill | Role |
|---|---|
| `import` | Brings tickets in from an external tracker |
| `report` | Renders narrative reports from templates |
| `alignment` | Coverage lens: does the chain cover its spec? Called by `chain-review` |
| `pushback` | Plan-quality lens: sizing, dependencies, AC executability. Called by `chain-review` |
| `discernment` | Convergence mechanism: rounds of independent participants to a fixed point. Called by `assess`, `chain-review` and `review` |
| `how-to-use-git-zhi` | Agent-facing command reference, consulted before running `git zhi` |

`preflight`, `alignment`, `pushback`, `discernment` and `how-to-use-git-zhi` have no command
stub. They are internal by construction, not by convention.

## Refinement's agent roles

Refinement dispatches four roles in sequence, each with its own system prompt
in `skills/refinement/`:

1. **Architect** (`architect-prompt.md`) — reads the spec and codebase, creates the milestone
2. **Decomposer** (`decomposer-prompt.md`) — breaks the spec into issues with dependencies and positive acceptance criteria
3. **SQE** (`sqe-prompt.md`) — adds negative scenarios, and never reads implementation code
4. **Technical writer** (`techwriter-prompt.md`) — adds documentation steps and standalone doc issues

The SQE's isolation from implementation code is structural: a role that has not
seen the code cannot write a test that merely restates it.

## Execute's loops

Execute nests two loops:

- **Inner** — an iterative TDD cycle per issue, with `/simplify` as its gate.
- **Outer** — sanbao metrics choose a review tier, then PAAD skills validate.
  Up to three reopen cycles per issue before the issue is reported as stuck.

## Integration with superpowers and PAAD

Crochet builds on superpowers and paad when they are installed and degrades
when they are not. Each integration point reads the capabilities map that
`preflight` returns, and takes the form:

> **If `<skill>` is available** — delegate to it, following that skill rather
> than restating it.
> **Otherwise** — the inline fallback.

Crochet never reimplements what superpowers or paad already provides. The
capabilities map is re-derived on every invocation rather than cached, so it
cannot drift from what is installed.

## Chain state

All chain interaction goes through the `git zhi` CLI. Crochet never reads or
writes `refs/zhi/` directly, the same way porcelain does not touch plumbing.
The chain is transient work state: nothing durable cites it, and durable
citations point at commits instead.
