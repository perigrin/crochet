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

**0008 is `proposed`, and that dependency is in prose where no check reaches
it.** `xt/run.sh` verifies `supersedes` and `amends` symmetry; there is no
frontmatter relation for "needs", and inventing one to satisfy a check would be
worse than saying this plainly. So: if 0008 is declined or does not land, this
decision ships with eight placement criteria and nothing that reads the
document — the synthesis would be in the right place, imported everywhere, and
judged by nobody. That is a worse state than `plugin-structure.md` is in today,
because a directory tree that nobody checks makes no claims, and a synthesis
that nobody checks makes one per line.

**0004 should not be accepted before 0008 is.** Not because it depends on 0008's
implementation — the synthesis can be written and land first — but because its
answer to "what keeps this honest" is otherwise a forward reference to a
decision that might not exist.

### Sections

Seven. Sections carry synthesis where a decision governs them and description
where none does:

| section | source |
|---|---|
| Project Structure | `[0001]` — three referents, live and archive; compiler, not runtime |
| High-Level System Diagram | `[0003]` — the pipeline, which gates are mandatory, and backfill |
| Core Components | skills; refinement's roles; execute's loops `[0002]` |
| Data Stores | `[0002]` — the chain is git-zhi's, reached only through the CLI |
| External Integrations | git-zhi, superpowers, paad |
| Security Considerations | `[0002]` — identity coordinates, it never authorises |
| Development and Testing | `[0001]` — `t/` and `xt/`; the enforcement ladder, doc-first, `Implements:` trailers; and where *how* lives |

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

Five of the specification's sections are omitted, and each is named because a
count without names is how three of them went unmentioned through two
revisions. Project Identification is the README's first paragraph. Deployment is
one pointer, folded into Development and Testing. Architecture Overview and
Future Considerations carry neither a decided claim nor a description a reader
needs, which is scaffolding.

**The fifth is the glossary, and dropping it settles an open question in 0001.**
0001 asks "whether the glossary is the one hand-maintained section of the
architecture doc or whether terms get defined in the decisions that introduce
them". This decision answers the second way: a synthesis whose every claim cites
the decision it came from puts each term one link from where it was defined, and
a hand-maintained glossary in the always-imported document is a second place to
keep the same definitions true.

That is recorded here because nothing links an open question to the decision
that closes it — 0001's list will still read as open, and this sentence is the
only thing saying otherwise.

**There is no list of decisions.** The citations are the bibliography. A separate
list is somewhere a decision can sit while being cited nowhere, which is exactly
the state worth surfacing: an accepted decision that appears in no claim was
forgotten when the synthesis was written, and the document needs revising rather
than an entry.

**The section table above discharges every row of the Problem Statement's
table.** Four of the ten needed placing and are placed in it: the ladder,
doc-first and `Implements:` trailers land in Development and Testing, being how
this repository decides and records things rather than how its parts fit;
compiler-not-runtime lands in Project Structure, being the reason there is no
build output and the files in the tree are the files that ship.

That is said once, in the table, because the Problem Statement's table is the
only specification of completeness this decision offers and nothing checks it.
A section plan that leaves four of ten rows unplaced invites a synthesis that
satisfies every criterion while closing 60% of the gap it was written to close.

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
citation form and its field test. Two of its rules change and one of its
acceptance criteria is removed; the rest holds, so this amends rather than
supersedes. A third section below discusses 0001's stinginess principle without
changing a rule of it, and is counted accordingly. `amends`/`amended-by` come from 0003, which added them for this
case.

**Where the live architecture document lives.** 0001 places it in
`docs/architecture/`. It moves to `docs/ARCHITECTURE.md` — inside `docs/`, where
`docs check` and `docs health` both reach it, under the name the external
specification uses.

**What the live architecture document owes the archive.** 0001 leaves the live
layer a free-standing description. It becomes a synthesis of the accepted
decisions, carrying citations into the archive.

**How stingy the live layer is.** 0001 says "stingy with live, generous with
archive. The postmortem is already written every time; almost nothing is
promoted out of it, and that asymmetry, not a threshold, is what damps the
feedback loop." The thing almost nothing is promoted out of, in 0001, is the
postmortem.

So this decision does not remove the damping 0001 named — it opens a promotion
path 0001 never discussed, from the decision series rather than from
postmortems. The principle still bears on it, and the trade still needs
arguing, but the claim that a named mechanism is being taken away was an
artefact of quoting the sentence with its subject cut out.

What the principle costs either way is the same, and the trade is deliberate.
What 0001 guarded against is a live layer that grows
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
with this change.

**The move touches seven sites in 0001**, and a reader who finds seven mentions
of a path said to move needs to know which are deliberate. One is the rule
placing covers-bearing live documents, changed here. One is the acceptance
criterion, removed here. The remaining five — the doc-first rule's statement of
its own scope, the referent table's live-layer cell, the definition of what `t/`
tests, and the Scope and `xt/` bullets — are archive prose, left stale by design
under 0001's own "true as of its date".

**Doc-first's scope site is in that five deliberately.** An earlier revision
assigned it to `0008-doc-first-enforcement.md` on the grounds that 0008 is where
doc-first is touched. 0008 makes doc-first *enforceable*; it does not edit
0001's text and names no decision in its scope, so a site assigned to it would
have belonged to nobody. Staleness by design is the honest disposition, and it
is the same one the other four get.

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

**`xt/run.sh`.** Its empty-`covers:` loop reads `docs/architecture` and
`docs/contributing`, guarded by `[ -d ] || continue`, and this decision deletes
the first. The synthesis would sit in neither, so the loop would skip a deleted
directory in silence and the runner would stay green over a document with no
`covers:` at all.

The loop is retargeted to **the documents `CLAUDE.md` imports**, which is the
live layer by 0001's own account and is one grep. `0008-doc-first-enforcement.md`
adopts the same definition for its lens and argues it at length; this decision
does not depend on that argument landing, because the loop needs a set of paths
and `CLAUDE.md`'s imports are that set whether or not 0008 is accepted.

**This is the one change that must not be left to the implementing issue.** The
same revision that settles `covers:` must be present and non-empty would
otherwise move the document out from under the only thing enforcing it — taking
the rule from a check that fails loudly to no enforcement at all, in a single
edit, in a decision that cites 0001's ladder.

**`docs/decisions/0006`.** Its by-path citation to the absorbed document is
repaired — and the repair is not a retarget to `docs/ARCHITECTURE.md`. 0006
attributes the probe-rather-than-test rule to `plugin-structure.md`, which has
never contained it: the rule lives in `docs/contributing/coding-conventions.md`,
which this decision does not move. So the citation is wrong today, and pointing
it at the synthesis would attribute the rule to a second document that will not
contain it either.

The criterion below cannot tell those two fixes apart, since both remove the
old path. It is recorded here because the citation check catches a `file:line`
reference and not a filename that stopped existing, and nothing at all catches a
filename that was never right.

**The asymmetry is `state:`, not the kind of edit.** 0006 is `proposed` and may
change freely; 0003 is `accepted`, and 0001 holds an accepted entry "immutable
in content, append-only in status". That settles it without needing a
repair-versus-revision distinction — which would not survive scrutiny here
anyway, since correcting 0006's attribution does change what 0006 holds: it held
that the rule lives in `plugin-structure.md` and afterwards holds that it lives
elsewhere.

Even were 0003 mutable, neither of its two sites wants changing. One names the
old path in order to say this decision will absorb it; the other is a dated
claim about where the pipeline ordering appeared when 0003 was written. Both are
true as of their date, which is what an archive entry is for.

## Acceptance Criteria

**These check placement, not the synthesis.** A `docs/ARCHITECTURE.md`
containing nothing but its citations satisfies all but one of them — the
exception being the listing check, which additionally requires a present,
non-empty `covers:`, because a document without one is not emitted among
`documents` at all. What they prove is that the document is where it should be
and wired to the tools that reach it. `crochet:review` judges whether it
reflects what was decided, and `0008-doc-first-enforcement.md` is what gives
review the step to do that with.

**A negation over a stream is guarded; a negation over existence is not.**
`! grep` on a missing file reports what it reports on a clean one, because the
stream is empty either way — so those criteria establish their subject exists
first. `! test -e` asserts absence, which is not vacuous when the subject is
absent; guarding it would add a precondition unrelated to its claim and leave it
reporting nothing the first criterion does not.

- [ ] the synthesis is at docs/ARCHITECTURE.md (`test -f docs/ARCHITECTURE.md`)
- [ ] the installed binary lists it as a document (`git zhi docs health --format json | grep -q '"file": "docs/ARCHITECTURE.md"'`)
- [ ] its covers entries carry no trailing slash (`test -f docs/ARCHITECTURE.md && ! sed -n '/^covers:/,/^---$/p' docs/ARCHITECTURE.md | grep -qE '^ *- .*/$'`)
- [ ] the absorbed document and its directory are gone (`! test -e docs/architecture`)
- [ ] CLAUDE.md imports it (`grep -q '^@docs/ARCHITECTURE.md' CLAUDE.md`)
- [ ] CONTRIBUTING.md links to it (`grep -q 'docs/ARCHITECTURE.md' CONTRIBUTING.md`)
- [ ] CONTRIBUTING.md no longer claims every short link is a directory (`test -f CONTRIBUTING.md && ! grep -q 'Every link here points at a directory' CONTRIBUTING.md`)
- [ ] 0006 no longer cites the absorbed document by path (`ls docs/decisions/0006-*.md && ! grep -q 'architecture/plugin-structure.md' docs/decisions/0006-*.md`)

**0003's two citations are not retargeted, and the criterion does not ask for
it.** One of them reads "`docs/architecture/plugin-structure.md` states the
ordering too, but 0004 proposes absorbing it into `docs/ARCHITECTURE.md`" —
it names the old path deliberately, anticipating this decision, and retargeting
it yields a sentence saying the document is absorbed into itself. The other is a
dated factual claim about where the pipeline ordering appeared when 0003 was
written. Both are true as of their date, which is what an accepted decision is
allowed to be; editing either is a revision rather than a repair, and this
decision's own rule forbids that. Only `0006`'s citation is a repair.

So two by-path references to a deleted file survive in the archive on purpose.
Nothing detects them, and that is recorded here rather than fixed.

## Open Questions

- Whether the synthesis's `covers:` should reach `t/` and `xt/` as well as
  `skills`, `commands` and the manifest. It states what the test kinds are for,
  which is an argument for including them.

  **This is narrower than it was.** That `covers:` is present and non-empty is
  settled here rather than left open, because a document without one is not
  emitted among `documents` by `docs health` at all — so the listing criterion
  above silently depends on it. Which paths it names is editorial; that it names
  some is not.

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
  enforcement ladder and the field test. This amends two of its rules and
  removes one of its acceptance criteria as a defect.
- `0002-worker-identity.md`. The source of the Data Stores and Security
  sections.
- `0003-acceptance-by-refinement.md`. Where `amends`/`amended-by` come from, the
  source of the pipeline section, and the gate that accepts this decision.
- `0008-doc-first-enforcement.md`. What makes `crochet:review` able to judge the
  synthesis, and the checks that back it. Split out of this decision.
- <https://architecture.md>. The section specification adopted here, in part.
- `docs/assessments/0004.md`. The session that assessed this.
