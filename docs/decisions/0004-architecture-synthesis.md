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
states its file layout. The architecture is what the accepted decisions decided,
and almost none of it reaches the live layer.

## Problem Statement

`docs/architecture/plugin-structure.md` is the live document for the codebase.
Measured against the accepted decisions it is meant to describe, these are the
architectural concepts missing from it:

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

**The gap is structural.** 0001 establishes both layers and the rule that the
archive is not imported into agent context. It does not say what the live layer
owes the archive, so nothing obliges an accepted decision to appear anywhere but
its own file.

**And the document is not named for what it holds.** `ARCHITECTURE.md` is a
convention with an external specification (<https://architecture.md>) and the
name a reader looks for. Crochet's equivalent sits a directory deeper under a
name describing Claude Code's plugin format rather than crochet's design.

## Proposal

### The architecture document is a synthesis, with citations

`docs/ARCHITECTURE.md` states, in the present tense, what the accepted decisions
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

**Doc-first carries completeness.** 0001 requires the live document to be
updated in the pull request that changes what it describes. Under this decision
the synthesis *is* what the live document claims, so a decision's implementing
pull request updates `docs/ARCHITECTURE.md` too — which makes an unreflected
decision unreachable rather than detectable.

**Assess carries correctness.** `docs/ARCHITECTURE.md` is a spec file under
`crochet:assess`'s own criteria: its claims are capabilities, constraints and
behaviours the system must exhibit. Run with the document as the spec and the
codebase as the subject, assess reports where it asserts something the code does
not do.

Validation is cheapest-first, the order `docs/contributing/development-workflow.md`
already sets. `git zhi docs health` reporting drift on the document is the
trigger to run assess over it, because the code beneath it changes far more often
than the document does. When assess reports an issue, run it again over each
decision the document cites: an issue means the document and the code disagree,
and only the decisions say which of the two is wrong.

**The citation check is the backstop**, and a weak one: it catches a decision
cited nowhere and nothing finer. It is written down as weak so that a pass is
never read as evidence of a complete synthesis.

### Sections

Seven. Sections carry synthesis where a decision governs them and description
where none does:

| section | source |
|---|---|
| Project Structure | `[0001]` — three referents, live and archive |
| High-Level System Diagram | the pipeline |
| Core Components | skills; refinement's roles; execute's loops `[0002]` |
| Data Stores | `[0002]` — the chain is git-zhi's, reached only through the CLI |
| External Integrations | git-zhi, superpowers, paad |
| Security Considerations | `[0002]` — identity coordinates, it never authorises |
| Development and Testing | `[0001]` — `t/` and `xt/`; and where *how* lives |

Data Stores and Security look like shape-filling and are not. Each carries a
decided negative constraint, and a file-layout framing loses both.

Three of the specification's sections are omitted because nothing in this
repository fills them. Project Identification is the README's first paragraph.
Deployment is one pointer, folded into Development and Testing. A section
carrying neither a decided claim nor a description a reader needs is scaffolding.

**There is no list of decisions.** The citations are the bibliography. A separate
list is somewhere a decision can sit while being cited nowhere, which is exactly
the state worth surfacing: an accepted decision that appears in no claim was
forgotten when the synthesis was written, and the document needs revising rather
than an entry.

### `plugin-structure.md` is absorbed, not moved

Every section of it lands in the sections above and nothing is left over, so
keeping both would duplicate all of them. `docs/architecture/` empties and is
removed, and `CONTRIBUTING.md`'s Short Link — which its own text requires to
point at a directory holding a file — retargets to `docs/ARCHITECTURE.md`.

The one part that does not move is the procedure for adding a skill so Claude
Code loads it. That is a *how*, it is already in
`docs/contributing/development-workflow.md`, and it stays there.

### What this amends in 0001

0001 is in force and this decision stands on its referent split, its layers, its
citation form and its field test. Two rules inside it change; the rest holds, so
this amends rather than supersedes.

**Where the live architecture document lives.** 0001 places it in
`docs/architecture/`. It moves to `docs/ARCHITECTURE.md` — inside `docs/`, where
`docs check` and `docs health` both reach it, and under the name the external
specification uses.

**What the live architecture document owes the archive.** 0001 leaves the live
layer a free-standing description. It becomes a synthesis of the accepted
decisions, carrying citations into the archive.

## Scope of Change

This needs nothing from git-zhi. Observed on 0.6.0: a document at
`docs/ARCHITECTURE.md` is watched by `docs health`, its dead links are reported
by `docs check`, and it is reachable from `CONTRIBUTING.md` at the root. A
document at the repository root is seen by neither tool, which is why it lives
one level in.

**`docs/ARCHITECTURE.md`.** The synthesis, carrying `covers:` and `stability:`
as a live document.

**`docs/architecture/plugin-structure.md`.** Removed, its content absorbed. The
directory goes with it.

**`CLAUDE.md`.** The import retargets to `@docs/ARCHITECTURE.md`.

**`CONTRIBUTING.md`.** The Architecture short link retargets to the file. It
stays at the repository root: `docs check` starts its reachability walk from
`<root>/CONTRIBUTING.md` and finds nothing if it is moved.

**`xt/run.sh`.** Three changes, all inside the runner, which already iterates
`$DEC/*.md` and reads `state:` with the same idiom:

- its `covers:` loop reaches `docs/` itself, not only `docs/architecture` and
  `docs/contributing`
- every decision cited by the synthesis is `accepted`
- every accepted decision is cited somewhere in it — weak by construction,
  catching a decision cited nowhere and nothing finer

**`xt/fixture/`.** A synthesis citing an unaccepted decision, and an accepted
decision it cites nowhere, so each new check has a case that fails on purpose.
The fixture is how this runner demonstrates it can still fail.

## Acceptance Criteria

- [ ] the synthesis is at docs/ARCHITECTURE.md (`test -f docs/ARCHITECTURE.md`)
- [ ] the installed binary watches it for drift (`git zhi docs health --format json | python3 -c 'import json,sys;print("docs/ARCHITECTURE.md" in [d["file"] for d in json.load(sys.stdin)["documents"]])' | grep -q True`)
- [ ] the absorbed document and its directory are gone (`! test -e docs/architecture`)
- [ ] CLAUDE.md imports it (`grep -q '^@docs/ARCHITECTURE.md' CLAUDE.md`)
- [ ] CONTRIBUTING.md links to it (`grep -q 'docs/ARCHITECTURE.md' CONTRIBUTING.md`)
- [ ] the runner reports a decision cited but not accepted (`sh xt/run.sh xt/fixture 2>&1 | grep -q 'cites'`)
- [ ] the runner reports an accepted decision cited nowhere (`sh xt/run.sh xt/fixture 2>&1 | grep -q 'cited nowhere'`)
- [ ] the checks are in the runner and the repository passes them (`grep -q 'cited nowhere' xt/run.sh && sh xt/run.sh`)

## Open Questions

- Whether `docs/ARCHITECTURE.md` should carry `covers:` paths distinct from the ones
  `plugin-structure.md` declared. It currently covers `skills/`, `commands/` and
  the manifest; a synthesis of decisions arguably also covers `t/` and `xt/`,
  since it states what they are for. Neither has been run.

## References

- `0001-documentation-architecture.md`. The layers, the referent split and the
  field test this amends two rules of.
- `0002-worker-identity.md`. The source of the Data Stores and Security
  sections.
- <https://architecture.md>. The section specification adopted here, in part.
- `skills/assess/assess.md`. The gate that judges the synthesis against the code.
- `docs/contributing/development-workflow.md`. The cheapest-first validation
  order this follows.
