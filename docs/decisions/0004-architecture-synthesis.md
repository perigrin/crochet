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
| the decision series as a concept | the directory is named; numbering, `state:` and supersession are absent |
| `t/` and `xt/` as separate test kinds | absent |
| compiler, not runtime | absent |
| worker identity and `ZHI_ACTOR` | absent |
| assignment is a hint, not a lock | absent |
| `wip_limit` composing with per-worker WIP | absent |

Every row traces to `0001-documentation-architecture.md` or
`0002-worker-identity.md`, both accepted.

What the document holds instead is a directory tree, three tables of skills, the
pipeline diagram, refinement's four roles, execute's two loops, and the
integration pattern. Useful, and an inventory rather than an architecture. A
reader who wants to know how crochet decides anything has to read
`docs/decisions/` and synthesise it themselves, which is work every reader
repeats.

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
reflecting none of them. A check whose subject is nearly empty reports what it
reports when the subject is complete, which is the failure the check exists to
prevent.

So nothing here claims to check it. `crochet:review` judges it, and
`0008-doc-first-enforcement.md` is what gives review the step to judge it with —
along with the weaker mechanical backstops that catch a decision reflected
nowhere at all. That is a separable piece of work: it governs every live
document, not this one, and it would be owed even if the architecture document
never became a synthesis.

What this decision needs from it is one guarantee: **that something reads the
synthesis against the archive, and that it is a judgment rather than a count.**

### Sections

Seven. Sections carry synthesis where a decision governs them and description
where none does:

| section | source |
|---|---|
| Project Structure | `[0001]` — three referents, live and archive |
| High-Level System Diagram | `[0003]` — the pipeline, which gates are mandatory, and backfill |
| Core Components | skills; refinement's roles; execute's loops `[0002]` |
| Data Stores | `[0002]` — the chain is git-zhi's, reached only through the CLI |
| External Integrations | git-zhi, superpowers, paad |
| Security Considerations | `[0002]` — identity coordinates, it never authorises |
| Development and Testing | `[0001]` — `t/` and `xt/`; and where *how* lives |

Data Stores and Security look like shape-filling and are not. Each carries a
decided negative constraint, and a file-layout framing loses both.

**The pipeline section carries 0003, and `plugin-structure.md` refuses to.** Its
text says which gates are mandatory "is policy rather than architecture...  This
document carries the pipeline's shape and stops there". That refusal is correct
about an inventory of files and wrong about a synthesis of decisions: this
decision changes what the document *is*, so a rule an accepted decision settled
is exactly what belongs in it. The refusal is absorbed as superseded rather than
carried forward, and it is named here because absorbing a paragraph that
contradicts the absorbing decision is how a contradiction arrives unnoticed.

Without this, the check and the section plan disagree on the day they land:
0003 is accepted and built, so the check demands it, and no section had it.

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

The procedure for adding a skill is not part of what is absorbed. It is a *how*
and it lives in `docs/contributing/development-workflow.md`.

Two paragraphs are dropped rather than absorbed, and dropping is the point in
both cases. The pipeline section's refusal to carry 0003 is superseded, as above.
And the paragraph beginning "It previously said the pipeline runs in strict
order" is temporal narration, which `docs/contributing/coding-conventions.md`
forbids in a live document; carrying it into the synthesis would import a
changelog into the file every agent loads.

### What this amends in 0001

0001 is in force and this decision stands on its referent split, its layers, its
citation form and its field test. Three of its rules change and one of its
acceptance criteria is removed; the rest holds, so this amends rather than
supersedes. `amends`/`amended-by` come from 0003, which added them for this
case.

**Where the live architecture document lives.** 0001 places it in
`docs/architecture/`. It moves to `docs/ARCHITECTURE.md` — inside `docs/`, where
`docs check` and `docs health` both reach it, under the name the external
specification uses.

**What the live architecture document owes the archive.** 0001 leaves the live
layer a free-standing description. It becomes a synthesis of the accepted
decisions, carrying citations into the archive.

**How stingy the live layer is.** 0001 says "stingy with live, generous with
archive... almost nothing is promoted out of it, and that asymmetry, not a
threshold, is what damps the feedback loop." This decision institutes systematic
promotion and makes it obligatory, removing the damping 0001 named as its
mechanism.

That trade is deliberate. What 0001 guarded against is a live layer that grows
until nobody keeps it true; the cost of its guard is that ten decided rules
reach no agent, which is the Problem Statement above. The synthesis promotes
claims with citations, not arguments — a decision's reasoning stays in the
archive — so what lands in every agent's context is a fraction of what the
decisions hold. **Length is where this decision is most likely to be wrong**, and
if the synthesis grows past the point where an always-imported document is
cheap, the answer is to shorten claims rather than to drop decisions.

**And one acceptance criterion of 0001 is removed as a defect, not amended.**
0001 carries `an architecture doc exists under docs/`, checked against
`docs/architecture/*.md`. This decision removes that directory, so the criterion
becomes permanently unrunnable and nothing detects it — `xt/run.sh` does not
execute decision criteria. A criterion pinned to a path a later decision can
legitimately move is a defect in how it was written rather than a position 0001
took. The rule it checked survives as `test -f docs/ARCHITECTURE.md`.

That footing does not exist yet and this decision lands it:
`docs/contributing/coding-conventions.md` carries two constraints on what a
criterion may be, and path-pinning is neither, so the third constraint goes in
with this change. Removing a criterion under a rule that arrives in the same
pull request is the honest order.

**The move touches seven sites in 0001**, and a reader who finds seven mentions
of a path said to move needs to know which are deliberate. Two are rules changed
here — where covers-bearing live documents sit, and the doc-first rule's scope.
One is the acceptance criterion, removed. The remaining four — the referent
table's live-layer cell, the definition of what `t/` tests, and the Scope and
`xt/` bullets — are archive prose, left stale by design under 0001's own "true
as of its date".

## Scope of Change

This needs nothing from git-zhi. Observed on 0.7.2 by two participants
independently: a document at `docs/ARCHITECTURE.md` is listed by `docs health`
and its dead links reported by `docs check`, while a document at the repository
root is seen by neither. That is why it lives one level in.

**`docs/ARCHITECTURE.md`.** The synthesis, carrying `covers:` and `stability:`
as a live document. Its `covers:` entries are written without trailing slashes:
on 0.7.2 a trailing slash matches no churn, which is recorded in
`docs/requests/git-zhi-docs-health-silent-passes.md` and costs one character per
entry to avoid.

**`docs/architecture/plugin-structure.md`.** Removed, its content absorbed. The
directory goes with it.

**`CLAUDE.md`.** The import retargets, and the gate-policy paragraph becomes a
pointer. `CLAUDE.md` states "Three gates are mandatory: assess, review and
postmortem" and the synthesis's pipeline section will state it too, with both
files imported everywhere. The synthesis holds it, being the document whose job
is to state what was decided; `skills/assess/assess.md` already records why two
copies is a defect rather than redundancy.

**`CONTRIBUTING.md`.** The Architecture short link retargets to the file, and
the sentence "Every link here points at a directory that holds a file" is
reworded, since it stops being true when the first link points at a file. That
sentence guards a real hazard — git does not track empty directories, so a link
into one survives locally and dies on the first clone — which applies to the six
directory links and not to the file. No check reads prose, so a live document at
the root of the reachability walk would otherwise ship a false invariant
indefinitely.

**`docs/contributing/coding-conventions.md`.** A third constraint on what a
decision's acceptance criterion may be: it may not be pinned to a path a later
decision can legitimately move. This lands here rather than in 0008 because it
is the footing for the criterion this decision removes from 0001, and removing a
criterion under a rule that arrives in the same pull request is the honest
order.

**`docs/decisions/0003` and `docs/decisions/0006`.** Three by-path citations to
the absorbed document are retargeted. Nothing detects these: the runner's
cite-symbols check rejects a `file:line` reference, not a filename that stopped
existing.

Two of the three sit in 0003, which is accepted, and 0001 says an accepted entry
is "immutable in content, append-only in status". **Retargeting a citation into
a file that no longer exists is a repair, not a revision** — it changes where a
reference points, not what the decision holds, and leaving it would make an
accepted decision cite a path the same pull request deletes.

## Acceptance Criteria

**These check placement, not the synthesis.** Every one is satisfied by a
`docs/ARCHITECTURE.md` containing nothing but its citations, which is the straw
man above. What they prove is that the document is where it should be and wired
to the tools that reach it. `crochet:review` judges whether it reflects what was
decided, and `0008-doc-first-enforcement.md` is what gives review the step to do
that with.

- [ ] the synthesis is at docs/ARCHITECTURE.md (`test -f docs/ARCHITECTURE.md`)
- [ ] the installed binary lists it as a document (`git zhi docs health --format json | grep -q '"file": "docs/ARCHITECTURE.md"'`)
- [ ] its covers entries carry no trailing slash (`! sed -n '/^covers:/,/^[a-z]/p' docs/ARCHITECTURE.md | grep -qE '^ *- .*/$'`)
- [ ] the absorbed document and its directory are gone (`! test -e docs/architecture`)
- [ ] CLAUDE.md imports it (`grep -q '^@docs/ARCHITECTURE.md' CLAUDE.md`)
- [ ] CONTRIBUTING.md links to it (`grep -q 'docs/ARCHITECTURE.md' CONTRIBUTING.md`)
- [ ] CONTRIBUTING.md no longer claims every short link is a directory (`! grep -q 'Every link here points at a directory' CONTRIBUTING.md`)
- [ ] the other decisions no longer cite the absorbed document by path (`ls docs/decisions/0003-*.md docs/decisions/0006-*.md && ! grep -q 'architecture/plugin-structure.md' docs/decisions/0003-*.md docs/decisions/0006-*.md`)

## Open Questions

- What `covers:` paths the synthesis declares. `plugin-structure.md` declares
  `skills/`, `commands/` and the manifest; a synthesis of decisions arguably
  also covers `t/` and `xt/`. Editorial, now that the trailing-slash defect is
  understood and avoidable.

- What `stability:` value the synthesis carries. `docs health` reads it and
  nothing here specifies it.

## Minute of exercise

Seven rounds, six participants, recorded in full in `docs/assessments/0004.md`.
Two things are recorded here because they are positions rather than defects.

**This decision was assessed while carrying a second one.** Three participants
reading the document cold, in three separate rounds and without contact, each
concluded that the doc-first enforcement apparatus was a decision of its own
that would be equally true had this one never been written. The first such
finding was overruled; the third stood, and the apparatus moved to
`0008-doc-first-enforcement.md`. Every finding raised after the first round
landed in the half that moved. The sections that remain here drew no finding
after round one.

**Findings raised in rounds one to seven whose raisers were stopped are held by
nobody.** They are recorded in the assessment with `raiser absent`. They were
not released, and the participants of any later round may re-derive them from
their recorded evidence rather than inherit them as settled.

## References

- `0001-documentation-architecture.md`. The layers, the referent split, the
  enforcement ladder and the field test. This amends three of its rules and
  removes one of its acceptance criteria as a defect.
- `0002-worker-identity.md`. The source of the Data Stores and Security
  sections.
- `0003-acceptance-by-refinement.md`. Where `amends`/`amended-by` come from, the
  source of the pipeline section, and the gate that accepts this decision.
- `0008-doc-first-enforcement.md`. What makes `crochet:review` able to judge the
  synthesis, and the checks that back it. Split out of this decision.
- <https://architecture.md>. The section specification adopted here, in part.
- `docs/assessments/0004.md`. The session that assessed this.
