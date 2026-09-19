---
title: The architecture document is a synthesis of accepted decisions
state: proposed
author: Chris Prather
date: 2026-09-19
supersedes: []
superseded-by: []
amends: [0001]
---

# 0004: The architecture document is a synthesis of accepted decisions

Crochet has no document that states its architecture. It has a document that
states its file layout. The two were assumed to be the same thing, and they are
not: the architecture is what the accepted decisions decided, and almost none of
that reaches the live layer.

## Problem Statement

`docs/architecture/plugin-structure.md` is the live document for the codebase.
Measured against the accepted decisions it is meant to describe, ten of twelve
architectural concepts are missing from it:

| decided in an accepted decision | in the architecture document |
|---|---|
| the enforcement ladder | absent |
| live and archive layers | absent |
| doc-first | absent |
| `Implements:` trailers as the citation form | absent |
| the decision series | absent |
| `t/` and `xt/` as separate test kinds | absent |
| compiler, not runtime | absent |
| worker identity and `ZHI_ACTOR` | absent |
| assignment is a hint, not a lock | absent |
| `wip_limit` composing with per-worker WIP | absent |

What it holds instead is a directory tree, three tables of skills, the pipeline
diagram, refinement's four roles, execute's two loops, and the integration
pattern. Useful, and an inventory rather than an architecture. A reader who
wants to know how crochet decides anything has to read `docs/decisions/` and
synthesise it themselves, which is work every reader repeats.

**The gap is structural, not an oversight.** Nothing connected the live layer to
the archive, so there was no point at which an accepted decision was obliged to
show up anywhere but its own file. 0001 established both layers and the rule
that the archive is not imported into agent context; it did not say what the
live layer owes the archive, and this is what fell through.

**And the document is not where a reader looks.** `ARCHITECTURE.md` at the
repository root is a convention with an external specification
(<https://architecture.md>) and, more to the point, is where someone arriving
cold looks before they have read `CLAUDE.md` or `CONTRIBUTING.md`. Crochet's
equivalent is two directories down under a name that describes Claude Code's
plugin format rather than crochet's design.

## Proposal

### The architecture document is a synthesis, with citations

`ARCHITECTURE.md` states, in the present tense, what the accepted decisions
jointly decided. Each claim cites the decision it came from as `[NNNN]`, linked
to the file. A reader who wants the argument opens the decision; a reader who
wants the current state reads only this.

The synthesis is organised by the reader's frame — the sections below — not by
the decisions' own structure. It is not a restatement. One section commonly
draws on two decisions, and one decision commonly informs several sections;
citations sit at the claim so that correspondence is visible where it applies.

**Completeness is a judgment, not a check.** Whether the synthesis reflects what
was decided cannot be established by counting citations: a document listing
every decision's headings at the bottom would satisfy any such count while
reflecting none of them. A check whose subject is nearly empty would report what
it reports when the subject is complete, which is the failure the check exists
to prevent.

Three existing mechanisms carry it instead, and only one of them is a check.

**Doc-first carries completeness, and it is the primary mechanism.** 0001
requires the live document to be updated in the same pull request as the change
it describes. Under this decision the synthesis *is* what the live document
claims, so a decision's implementing pull request updates `ARCHITECTURE.md` too.
That makes an unreflected decision unreachable rather than detectable, which is
0001's own argument for the rule: "every other check in this proposal is
detection after the fact". The ten absences above exist because doc-first never
applied here — synthesis was not the document's contract, so there was nothing
for it to bite on.

**Assess carries correctness.** `ARCHITECTURE.md` is a spec file under
`crochet:assess`'s own criteria: its claims are capabilities, constraints and
behaviours the system must exhibit, which is what assess reads a spec for. Run
with `ARCHITECTURE.md` as the spec and the codebase as the subject, it reports
where the document asserts something the code does not do. That is assess
operating exactly as specified, in its ordinary direction.

**The citation check is the backstop**, and a weak one: it catches a decision
ignored wholesale and nothing finer. It is written down as weak so that a pass
is never read as evidence of a complete synthesis.

### Sections

Nine from the specification, then the decision block. Sections carry synthesis
where a decision governs them and description where none does:

| section | source |
|---|---|
| Project Identification | description |
| Project Structure | `[0001]` — three referents, live and archive |
| High-Level System Diagram | the pipeline |
| Core Components | skills; refinement's roles; execute's loops `[0002]` |
| Data Stores | `[0002]` — the chain is git-zhi's, reached only through the CLI |
| External Integrations | git-zhi, superpowers, paad |
| Deployment and Infrastructure | points to `docs/contributing/development-workflow.md` |
| Security Considerations | `[0002]` — identity coordinates, it never authorises |
| Development and Testing | `[0001]` — `t/` and `xt/`; points to the workflow document |
| Decisions reflected | generated |

Two sections that looked inapplicable are not. Crochet holds no state of its
own, and *why* it holds none — the chain belongs to git-zhi and porcelain does
not touch plumbing — is a decided storage architecture. Crochet has no
authentication, and *that a declared actor is unverified and must never gate a
capability* is a decided security posture. The synthesis rule finds content in
sections that a file-layout framing leaves empty.

**Deployment and Development point rather than contain.** The specification puts
both in the architecture document; 0001 puts *how* in `docs/contributing/`. The
pointer satisfies the shape without moving content across the referent boundary,
because a reader looking for the deployment section finds it and is told where
it lives.

### The decision block is generated

A section listing every decision, its state, and whether it is reflected in the
code. Derived rather than declared, per 0001: state comes from frontmatter,
which is a judgment, and implementation comes from querying `Implements:`
trailers, which is a fact.

It is written between markers by a script, and `xt/run.sh` regenerates and
compares, so the block cannot drift from what the repository says.

### `plugin-structure.md` is absorbed, not moved

All seven of its sections land in the sections above and nothing is left over.
Keeping both would duplicate every one of them, which is what 0001's one-home-
per-referent rule exists to prevent. `docs/architecture/` empties and is
removed, and `CONTRIBUTING.md`'s Short Link — which its own text requires to
point at a directory holding a file — retargets to `ARCHITECTURE.md`.

The one part that does not move is the procedure for adding a skill so Claude
Code loads it. That is a *how*, it is already in
`docs/contributing/development-workflow.md`, and it stays there.

### What this amends in 0001

Supersession would be wrong: 0001 is in force, fifteen commits cite it, and this
decision stands on its referent split, its layers, its citation form and its
field test. Two rules inside it change.

**Where the live architecture document lives.** 0001 places it in
`docs/architecture/`. It moves to the repository root.

**What the live architecture document owes the archive.** 0001 leaves the live
layer a free-standing description. It becomes a synthesis of the accepted
decisions, carrying citations into the archive.

The layer boundary itself is unchanged. 0001 says the archive is not *imported*
into agent context; this document has the live layer *cite* the archive, which
is a pointer for a reader who wants why, not a claim on anyone's context.

## Scope of Change

**git-zhi, first, and it is one change rather than two.** `docs health` walks
`docs/` for documents carrying `covers:`, so a root document is watched by
nothing. Observed on 0.6.0: a root file whose `covers:` is identical to a
watched one is absent from the report entirely. Until that reaches the
repository root, `ARCHITECTURE.md` ships unwatched and this decision loses the
drift detection it depends on.

Not crochet's to write, named here rather than assumed, and the floor in
`.claude-plugin/plugin.json` moves once when it ships.

*A second path-binding exists and does not block this.* `docs health` reports a
coverage gap for code with no corresponding file in `docs/architecture/`, so
removing that directory would make the gap permanent in a repository that has
`internal/` packages. Crochet has none, and its health report today names no
coverage gaps. Worth reporting to git-zhi as a limitation of the same shape;
not a prerequisite here, and listing it as one would inflate a cross-repo ask
for a condition this repository cannot reach.

**`ARCHITECTURE.md`.** The synthesis, at the repository root, carrying `covers:`
and `stability:` as a live document, with the generated decision block.

**`docs/architecture/plugin-structure.md`.** Removed, its content absorbed. The
directory goes with it.

**`CLAUDE.md`.** The import retargets to `@ARCHITECTURE.md`.

**`CONTRIBUTING.md`.** The Architecture short link retargets to the file.

**`xt/rfc-index.sh`.** Generates the decision block from frontmatter and
`Implements:` trailers.

**`xt/architecture-citations.sh`.** Two checks over `ARCHITECTURE.md`: every
decision it cites is accepted, and every accepted decision is cited at least
once. The second is weak by construction — it catches a decision being ignored
wholesale and nothing finer — and is written down as weak so that nobody reads a
pass as evidence of a complete synthesis. It lives in its own script rather than
inside the runner so that a criterion can name it and fail before it exists.

**`xt/run.sh`.** Calls both new scripts, so they run with everything else.

## Acceptance Criteria

- [ ] the architecture document is at the repository root (`test -f ARCHITECTURE.md`)
- [ ] it is watched for drift by the installed binary (`git zhi docs health --format json | python3 -c 'import json,sys;print("ARCHITECTURE.md" in [d["file"] for d in json.load(sys.stdin)["documents"]])' | grep -q True`)
- [ ] the absorbed document is gone (`! test -e docs/architecture/plugin-structure.md`)
- [ ] CLAUDE.md imports the architecture document (`grep -q '^@ARCHITECTURE.md' CLAUDE.md`)
- [ ] CONTRIBUTING.md links to it (`grep -q 'ARCHITECTURE.md' CONTRIBUTING.md`)
- [ ] every accepted decision is cited, and no unaccepted one is (`sh xt/architecture-citations.sh`)
- [ ] the generated block matches its generator (`sh xt/rfc-index.sh --check`)
- [ ] the runner picks both up (`grep -q architecture-citations xt/run.sh && grep -q rfc-index xt/run.sh`)

## Open Questions

- Whether `ARCHITECTURE.md` should carry `covers:` paths distinct from the ones
  `plugin-structure.md` declared. It currently covers `skills/`, `commands/` and
  the manifest; a synthesis of decisions arguably also covers `t/` and `xt/`,
  since it states what they are for. Neither has been run.
- Whether the specification's Project Identification section earns its place in
  a repository whose README already carries that information, or whether
  satisfying the shape is itself the reason to keep it.

## References

- `0001-documentation-architecture.md`. The layers, the referent split and the
  field test this amends two rules of.
- `0002-worker-identity.md`. The source of the Data Stores and Security
  sections, and the precedent for naming a git-zhi dependency rather than
  assuming it.
- <https://architecture.md>. The section specification adopted here.
- `skills/assess/assess.md`. The gate that judges whether the synthesis is
  complete.
