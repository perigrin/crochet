---
stability: 2
covers:
  - skills
  - commands
  - .claude-plugin/plugin.json
  - t
  - xt
---

<!-- ABOUTME: What the accepted decisions jointly decided about crochet, in the present tense. -->
<!-- ABOUTME: Each claim cites the decision it came from; the argument stays in the archive. -->

# Crochet Architecture

Crochet is a Claude Code plugin — an intelligence layer for
[git-zhi](https://github.com/perigrin/git-zhi). It provides skills that drive an
SDLC pipeline over a chain of issues.

This document is a synthesis of what the accepted decisions decided
[[0004](decisions/0004-architecture-synthesis.md)]. Each claim cites its source.
A reader who wants the current state reads only this; a reader who wants the
argument opens the decision. The citations are the bibliography — there is no
separate list, because a list is somewhere a decision can sit while being cited
nowhere.

## Project Structure

```
.claude-plugin/plugin.json   — plugin manifest (name, version, skill/command dirs)
skills/<name>/<name>.md      — skill definitions (the LLM instructions)
skills/<name>/*.md           — supporting files (agent prompts, templates, procedures)
commands/<name>.md           — user-invocable stubs that delegate to skills
docs/                        — the live layer and the archive
t/, xt/                      — product and project checks
```

**Three documents, three referents**
[[0001](decisions/0001-documentation-architecture.md)]. What this is (the
codebase, present tense, live) is this document. How to work on it (the DevEx
tooling, present tense, live) is `CONTRIBUTING.md` and `docs/contributing/`. Why
it is like this (both, historically, archive) is `docs/decisions/` and
`docs/postmortems/`.

**The live layer must be true now and is rewritten in place; the archive is
append-only and true as of its date**
[[0001](decisions/0001-documentation-architecture.md)]. Every line in the live
layer is a line someone must keep true forever, so the layer is deliberately
stingy and needs eviction as much as addition. `CLAUDE.md` is not a fourth
document: it is the agent's door onto the live layer and imports it rather than
restating it, because for an agent an import is static linking and a pointer is
a lookup that may not happen.

**The decision series is one genus, one number space, one directory**
[[0001](decisions/0001-documentation-architecture.md)]. Files are
`NNNN-kebab-title.md`; the number is the citation and the title is free to
change. `state:` carries only what a human declares — `proposed`, `accepted`,
`declined`, `superseded`. Whether a decision was *built* is not among them: it
is derived from commit trailers, because a declared state is an act of judgment
and a derived one is a fact about the world.

**Compiler, not runtime**
[[0001](decisions/0001-documentation-architecture.md)]. Guardrails live in the
repository being checked, not in this plugin. In-repo checks and in-repo
documents version together, so no commit exists where they disagree about what
is enforced; and the mechanism is ecosystem-shaped, which a plugin cannot know
until it arrives. Crochet ships the pattern and the repository ships the
instance. The testable form: a repository crochet onboarded should still pass
its own checks with crochet uninstalled.

There is no build and no compiled output. The files in the tree are the files
that ship, so the thing that is read and the thing that runs are one file.

## High-Level System Diagram

```
superpowers:brainstorming → crochet:assess → crochet:refinement →
crochet:chain-review → crochet:execute → crochet:review → crochet:postmortem
```

**The pipeline is a loop that can be entered at any point**
[[0003](decisions/0003-acceptance-by-refinement.md)]. A gate is mandatory not
because it must run in its nominal position but because its artifact may not be
permanently absent. So a gate never refuses to start: it backfills what is
missing, at cursory quality, and continues. Work arriving half-built is a legal
entry point; finishing without the artifacts is not.

**Three gates are mandatory — assess, review and postmortem**
[[0003](decisions/0003-acceptance-by-refinement.md)]. Those produce judgments
and nothing else produces them. Brainstorming, refinement and execute are
methods: each produces an artifact, so each is optional whenever that artifact
arrives another way. Chain-review is mandatory only when a chain exists.

**Assessment produces the acceptance**
[[0003](decisions/0003-acceptance-by-refinement.md)]. A decision is accepted when
assessment reaches a fixed point among participants of whom at least one is
neither the author nor a role that holds no view. Refinement records the outcome;
it does not decide it.

A legal skip is one whose property was established another way and recorded. An
unrecorded skip is an omission however reasonable the judgment behind it,
because nothing distinguishes it from having forgotten.

## Core Components

A **skill** is a markdown file with `name` and `description` frontmatter
followed by instructions an agent follows. A **command** is a thin stub
delegating to one. Skills without a stub are internal by construction.

| Skill | Role |
|---|---|
| `assess` | Analyses a spec against the codebase and chain; produces a gap analysis |
| `refinement` | Decomposes a spec into a git-zhi chain of issues |
| `chain-review` | Gate between refinement and execute; runs the coverage and plan-quality lenses |
| `execute` | Drives the execution loop, issue by issue |
| `review` | Gate between execute and postmortem; reviews the delivery against the decision |
| `postmortem` | Milestone retrospective |
| `install`, `preflight`, `verify`, `onboard` | Infrastructure |
| `import`, `report` | Support |
| `alignment`, `pushback`, `discernment`, `how-to-use-git-zhi` | Internal, no command stub |

**Refinement dispatches four roles in sequence** — architect, decomposer, SQE,
technical writer — each with its own prompt. The SQE's isolation from
implementation code is structural: a role that has not seen the code cannot
write a test that merely restates it.

**Execute nests two loops.** The inner loop is an iterative TDD cycle per issue.
The outer loop reads sanbao metrics to choose a review tier, then validates with
PAAD skills, allowing up to three reopen cycles before an issue is reported
stuck.

**Execute reads `wip_limit` and dispatches no more workers than it permits**
[[0002](decisions/0002-worker-identity.md)]. `wip_limit` caps issues in progress
across the chain and git-zhi enforces per-worker WIP of one independently, so
the two compose into a parallelism throttle without anything being added. A
`wip_limit` of zero means no limit rather than no workers.

## Data Stores

**The chain is git-zhi's, and crochet reaches it only through the CLI**
[[0002](decisions/0002-worker-identity.md)]. Nothing here reads or writes
`refs/zhi/` directly, the same way porcelain does not touch plumbing. The chain
sits outside the document triad: it is transient work state, which is why
nothing durable cites it and durable citations point at commits instead
[[0001](decisions/0001-documentation-architecture.md)].

**Assignment is a hint, not a lock**
[[0002](decisions/0002-worker-identity.md)]. It expresses intent; ownership is
the actor on the in-progress transition. An assignment attracts its own worker
and repels nobody, so the orchestrator assigns only issues that are currently
unassigned and never dispatches for an issue assigned outside its own worker
set. A run that dies leaves issues bearing a token no live worker matches, which
is why execute clears assignments carrying a token that is not its own at
start-up.

The capabilities manifest at `.claude/crochet/capabilities.json` is
machine-specific and gitignored. It records what is installed on one machine, so
it is never a claim about the repository.

## External Integrations

**git-zhi** holds the chain and is the only interface to it. The version this
plugin depends on is declared as `git_zhi_min_version` in
`.claude-plugin/plugin.json`; `crochet:preflight` compares the installed binary
against it, and `xt/run.sh` checks the same claim. A dependency on another
repository belongs there rather than in an acceptance criterion, because a
criterion satisfiable only by another repository shipping something cannot go
green by any work done here.

**superpowers** and **paad** are optional. Each integration point reads the
capabilities map preflight returns and takes one form: if the skill is
available, delegate to it; otherwise, an inline fallback. Crochet never
reimplements what either already provides, and the map is re-derived on every
invocation rather than cached, so it cannot drift from what is installed.

A crochet skill is never guarded behind a capability check. Every one ships in
this plugin, so there is nothing to detect and the guarded branch would never
run.

## Security Considerations

**Identity is for coordination, never authorization**
[[0002](decisions/0002-worker-identity.md)]. A declared identity is unverified —
`ZHI_ACTOR=agent:someone-else` is accepted as given, and should be. The field
exists so workers can avoid each other's work, not so anything can be granted or
withheld on the strength of it.

**A transition's actor resolves from the environment**
[[0002](decisions/0002-worker-identity.md)]: an explicit `--actor` flag where one
exists, then `ZHI_ACTOR`, then the git author. No write command takes `--actor`,
so on the write path `ZHI_ACTOR` is the top of that order by commitment rather
than by oversight. Every agent in one repository inherits the same git author,
so without an exported identity they all resolve to the same actor and mutual
exclusion excludes nothing.

The token is opaque and per-run, not derived from the milestone name — milestones
share prefixes, and a derived token would let one run's reclamation clear
another's assignments.

## Development and Testing

**Tests come in two kinds** [[0001](decisions/0001-documentation-architecture.md)],
the Perl convention rather than an invention. `t/` tests the product: does the
code do what this document claims. `xt/` tests the project: does the repository
do what `CONTRIBUTING.md` claims. Neither ships to a consumer.

`xt/run.sh` runs itself against `xt/fixture`, which is broken on purpose. A
runner that can no longer fail has failed open, and nobody would notice.

**The enforcement ladder** [[0001](decisions/0001-documentation-architecture.md)]
governs where a rule goes:

| Rung | Mechanism | Cost | Guarantee |
|---|---|---|---|
| 1 | make the wrong thing impossible | once | total |
| 2 | make it fail loudly: hook, linter, CI, test | once | deterministic |
| 3 | put it in the agent's prompt | every invocation | strong prior |
| 4 | state it for humans to remember | every reader | hope |

Each rung down costs more, forever, and guarantees less. If a rule has to be
strict, it cannot be prose. The placement rule follows: the right home for a
piece of documentation is inside the error message of the guardrail that
enforces it.

**Doc-first** [[0001](decisions/0001-documentation-architecture.md)]: update the
live document first, then build to match, in one pull request. This is TDD at
architecture altitude — the document is briefly false on the branch, and that is
the red state rather than a defect. The honest asymmetry is that a test is
machine-checkable and an architecture statement is not, so this buys the
discipline and not the proof. What it does buy is that a document asserting
something never implemented becomes unreachable rather than detectable.

**`Implements:` trailers are the citation form**
[[0001](decisions/0001-documentation-architecture.md)]. Every commit
implementing a numbered decision carries `Implements: NNNN` in its final trailer
block, where git parses it as a trailer rather than as prose. That is the whole
mechanism; the relation is recovered by searching, and whether a decision was
built is a query rather than a field.

**Review reads the live documents against the delivery's diff**
[[0008](decisions/0008-doc-first-enforcement.md)]. Doc-first is a rule about what
a change must contain, and nothing mechanical can judge whether a document still
says something true after a change — so the enforcement is a judgment at review,
backed by a mechanical check that catches only the coarsest failure: an accepted
decision with an implementing commit that no live document cites. That backstop
is deliberately weak, and a green one is not evidence that any document is
complete.

*How* to validate a change, branch, add a skill or cut a release lives in
`docs/contributing/development-workflow.md`. This document says what the parts
are; that one says how to work on them.
