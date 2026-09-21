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

Three mechanisms carry it instead, and only one is a check. Each is stated with
the hole it has, because the reason to name three rather than one is that each
covers a different failure and none covers all of them.

**Doc-first**, for decisions that were built. 0001 requires the live document to
be updated in the pull request that changes what it describes, and under this
decision the synthesis *is* what the live document claims — so an unreflected
decision becomes unreachable rather than detectable.

Its hole is the decision accepted but not yet built, which has no implementing
pull request for the rule to attach to. That is the right answer rather than a
gap: 0001 derives implementation status from `Implements:` trailers and names
accepted-but-not-built as its contribution over ADR and RFD. A synthesis states
what the system does, and forcing an unbuilt decision into it as a present-tense
claim reproduces 0001's Problem Statement inside the document `CLAUDE.md`
imports everywhere. The synthesis carries decided-and-built claims; the series
carries the rest.

Both doc-first and the check key on `Implements:` trailers, so both are blind to
the same commit — the one somebody built and forgot to label. That is one
failure mode held twice, not two mechanisms covering each other.

**Assess**, when something schedules it. `docs/ARCHITECTURE.md` is a spec file
under `crochet:assess`'s own criteria, so run with the document as the spec and
the codebase as the subject, assess reports where it asserts something the code
does not do. When it reports an issue, run it again over each decision the
document cites: only the decisions say which of the two is wrong.

Its hole is the trigger. `git zhi docs health` compares commits touching a
document's `covers:` paths against the commit that last touched the document —
both git-derived, so the answer is the same in any clone, and the reporting
machinery works. What does not work is the matching: **a `covers:` entry naming
a directory never matches churn.** Observed on 0.7.2 against this repository,
where `skills/` had been touched by three commits since the documents covering
it were last changed:

| `covers:` entry | churn reported |
|---|---|
| `skills/review/review.md` | 1 |
| `skills/`, `commands/`, the manifest | 0 |

Same tree, same history, opposite answers, and the discriminator is the shape of
the path. Every live document in this repository declares directory paths, so
`docs health` has never reported drift on any of them — and it fails in the
direction of reporting clean, which is the direction that is never noticed.
`docs/contributing/development-workflow.md` already records other ways that
summary reports all-clear over nothing.

That settles the trigger for this decision rather than in general.
`docs/ARCHITECTURE.md` is specified below with `covers: skills/`, `commands/`
and the manifest, so `docs health` would say nothing about the synthesis for as
long as the defect stands. The trigger is therefore the implementing pull
request, the same event doc-first attaches to, plus `crochet:review`, which 0003
makes mandatory. Both are events nobody can skip, which is what 0001's ladder
asks of an enforcement point.

The defect belongs to git-zhi and is recorded in `docs/requests/`. Nothing here
waits on it.

**The citation check**, as backstop. Its subject is every accepted decision with
at least one commit carrying its `Implements:` trailer — the population
doc-first obliges, derived the same way, so rule and check cannot disagree about
scope.

Three things about its strength, so that a pass is never read as more than it
is.

- **It is weaker than "a decision is reflected".** The citation form is `[NNNN]`
  linked to the file, so the real predicate is *the four-digit string appears in
  the file* — satisfied by a link, a code fence, a References entry, or a
  sentence saying the decision is deliberately not synthesised. It cannot tell a
  claim from an explanation of a claim's absence.
- **It must not fail open, and it has two ways to.** Iterating citations rather
  than decisions makes an empty synthesis indistinguishable from a complete one.
  And the trailer population is itself truncatable: a shallow clone is a
  repository top whose history holds one commit, so the check would exempt every
  decision implemented earlier while reporting clean. `actions/checkout` is
  shallow by default. So the check requires a population it can trust — a
  repository whose history reaches the decisions it is asking about — and
  reports that it cannot run when it does not have one. A subject it could not
  see is a finding, never a skip.
- **It is not what judges the synthesis.** No criterion can be, which is this
  section's argument. `crochet:review` judges it, once it gains the step below.

### Review gains the step that makes doc-first enforceable

`crochet:review` is named above and in the acceptance criteria as what judges the
synthesis. It does not do that today, and saying it did would have been this
decision asserting something that was never built — the failure 0001's Problem
Statement is nine instances of.

`skills/review/review.md` contains no step that reads a live document at all:
its coverage lens finds the decision from `Implements:` trailers and checks the
milestone's acceptance criteria, and its quality lenses are code reviewers.
Neither reads a markdown document against an archive.

**This is a gap 0001 already left and nothing has closed.** Doc-first is a rule
in the live layer that no gate enforces: `xt/run.sh` checks that a `covers:`
list is non-empty and that decisions link symmetrically, and `git zhi docs
health` was the nearest thing to an enforcement point until its drift column
turned out to be silent for every document declaring a directory, which is all
of them. So the synthesis is not a special case
needing a bespoke check — it is the first live document whose correctness
someone noticed nothing was checking.

Review's coverage lens gains a step: **for each live document whose `covers:`
paths the diff touches, read the document against the diff.** That is a
judgment, produced by a mandatory gate, at an operation nobody can skip — which
is what 0001's ladder asks and what three prose rules about doc-first have not
delivered.

**Which documents are live has to be decided, because this decision deletes the
only thing that answered it.** `covers:` does not: eleven documents under
`docs/` carry it and eight are archive, including assessments that cover the
very skills this decision changes. The discriminator in force is location —
`xt/run.sh` reads `docs/architecture` and `docs/contributing` — and
`docs/architecture/` is being removed. So the live layer is enumerated by what
`CLAUDE.md` imports: a document is live when `CLAUDE.md` imports it. That is
already the operative definition in 0001's terms, it is one grep, and it makes
the set impossible to grow by accident, since adding a document to the live
layer means editing the file every agent loads.

It is stated as a lens rather than a check on purpose. Whether a synthesis
reflects what was decided is the thing this decision argues cannot be counted,
so the mechanism that judges it must be one that reads.

**The quiet case is the common case, and it is not a finding.** All three live
documents declare `covers: skills/`, so the lens fires on nearly every branch
that touches a skill, and on most of them there will be nothing to record. A
trigger that fires on everything is ignored the same way one that fires on
nothing is, and this decision has already dropped one mechanism for the second
failure — it should not adopt the first by leaving the quiet case undefined.

A finding requires one of two things: the diff falsifies a claim the document
makes, or the diff completes work the document describes as pending. **An
enumeration the change renders incomplete is a falsified claim** — that is what
carries doc-first's own case, where a document lists what exists and the diff
adds one. A diff under a `covers:` path the document never claimed anything
about is not a finding, and the lens says so and moves on.

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
as a live document.

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

**`docs/decisions/0003` and `docs/decisions/0006`.** Three by-path citations to
the absorbed document are retargeted. Nothing detects these: the citation check
rejects a `file:line` reference, not a filename that stopped existing.

Two of the three sit in 0003, which is accepted, and 0001 says an accepted entry
is "immutable in content, append-only in status". **Retargeting a citation into
a file that no longer exists is a repair, not a revision** — it changes where a
reference points, not what the decision holds, and leaving it would make an
accepted decision cite a path the same pull request deletes. The distinction is
worth stating because this decision also removes a criterion from 0001, which is
a content change and gets its own argument above; a reader should not take the
easier case as precedent for the harder one.

**`skills/review/review.md`.** The coverage lens gains the live-document step.
This is the only skill this decision changes, and it is changed because the
decision's answer to "what judges the synthesis" is otherwise a claim about a
step that does not exist.

**`docs/contributing/coding-conventions.md`.** The third constraint on
acceptance criteria, above.

**`docs/contributing/development-workflow.md`.** It sets the cheapest-first
validation order, and this decision changes what validates the one live document
it creates.

**`xt/run.sh` and `xt/fixture/`.** Three checks, and the self-test work that
makes the third honest:

- the `covers:` loop reaches `docs/` itself, not only two named directories
- every decision cited by the synthesis is `accepted`
- every accepted decision with an implementing commit is cited in the synthesis,
  reported rather than skipped when the synthesis or the trailer population is
  missing

The third needs a trailer population the runner can trust, which the fixture
does not have by default and a shallow clone does not have at all. How the
self-test supplies one, and which fixture cases and `expected` entries prove
each check, are implementation: they belong to the issue, not here. What must be
true is that each new check has a case that fails on purpose and that
`xt/fixture/expected` accounts for it, because that ledger is the only thing
that detects a check going quiet.

## Acceptance Criteria

**These check the mechanism, not the synthesis.** Every one is satisfied by a
`docs/ARCHITECTURE.md` containing nothing but its citations, which is the straw
man the Completeness section rejects — so a criteria set claiming otherwise
would reproduce, in this decision's own verification, the failure it argues
against. `crochet:review` judges the synthesis, once it gains the step above.

- [ ] the synthesis is at docs/ARCHITECTURE.md (`test -f docs/ARCHITECTURE.md`)
- [ ] the installed binary lists it as a document (`git zhi docs health --format json | grep -q '"file": "docs/ARCHITECTURE.md"'`)
- [ ] the absorbed document and its directory are gone (`! test -e docs/architecture`)
- [ ] CLAUDE.md imports it (`grep -q '^@docs/ARCHITECTURE.md' CLAUDE.md`)
- [ ] CONTRIBUTING.md links to it (`grep -q 'docs/ARCHITECTURE.md' CONTRIBUTING.md`)
- [ ] CONTRIBUTING.md no longer claims every short link is a directory (`! grep -q 'Every link here points at a directory' CONTRIBUTING.md`)
- [ ] the other decisions no longer cite the absorbed document by path (`ls docs/decisions/0003-*.md docs/decisions/0006-*.md && ! grep -q 'architecture/plugin-structure.md' docs/decisions/0003-*.md docs/decisions/0006-*.md`)
- [ ] review's coverage lens reads live documents (`grep -q 'read the document against the diff' skills/review/review.md`)
- [ ] the fixture proves each new check and the ledger accounts for it (`grep -q 'the synthesis cites' xt/fixture/expected && grep -q 'cited nowhere in the synthesis' xt/fixture/expected && sh xt/run.sh`)
- [ ] the runner reports rather than skips when it cannot see its subject (`grep -q 'the synthesis is missing' xt/fixture/expected && sh xt/run.sh`)

**The fixture criteria are conjunctions on purpose.** `sh xt/run.sh xt/fixture`
resolves `git log` outward to whatever repository encloses it, so a criterion
written that way reports on the wrong history. Pairing a declared `expected`
entry with a passing run works because the self-test reports declared entries
that went unmatched — which makes these three the only criteria resting on the
self-test itself, the one site `xt/fixture/expected` lists as uncovered in its
own ledger. **The implementing issue adds the guard for it**: a sentinel entry
no check emits, asserted to be reported as gone quiet, which catches the matcher
being disabled, deleted, or made always-match.

**Three criteria name prose and will redden when it is reworded.** That is the
decay `coding-conventions.md`'s first constraint describes, in its mildest form,
and the alternative is a criterion that cannot tell a check from its absence.

The review criterion is one of them deliberately. Loosening it to two common
words — `covers` and `live document` — would make it satisfiable by a sentence
explaining that the step was *not* added, which is precisely the weakness this
decision names about its own citation check. A criterion for the one new
mechanism the decision adds is the last one that should be loose.

**This decision does not require a citation of itself.** By the time its
implementing commits exist it is `accepted` with trailers naming it, so the
citation check's own population includes it — and its Sections table sources
0001, 0002 and 0003. The synthesis states what the accepted decisions decided
about the system; a decision about the architecture document's own form is not a
claim the synthesis makes. So the check excludes the decision that introduces
it, the exclusion is written here rather than discovered in the pull request that
lands it, and the same collision this decision resolves for 0003 does not recur
for 0004.

## Open Questions

- **What `covers:` paths the synthesis declares, which decides whether anything
  watches it.** `plugin-structure.md` declares `skills/`, `commands/` and the
  manifest; a synthesis of decisions arguably also covers `t/` and `xt/`. Either
  list is directory-shaped, and a directory-shaped entry reports no churn, so on
  today's binary the choice decides whether `docs health` ever says anything
  about the synthesis at all. A list of file paths would be watched and would be
  brittle, since it goes stale every time a skill is added.

  This question was previously recorded here as editorial on the grounds that
  `covers:` no longer gates anything once the drift trigger is dropped. That was
  wrong: the trigger was dropped *because* of what `covers:` does, so the two are
  the same question rather than independent ones.

- What `stability:` value the synthesis carries. `docs health` reads it and
  nothing here specifies it.

- Nothing is open about whether the git-zhi defect warrants a request document —
  it does, and `docs/requests/` is where this repository writes them. What is
  open is whether crochet should work around it in the meantime by declaring
  file-shaped `covers:` paths, or accept an unwatched synthesis until the
  matching is fixed. The first question above is the same question.

## References

- `0001-documentation-architecture.md`. The layers, the referent split, the
  enforcement ladder and the field test. This amends three of its rules and
  removes one of its acceptance criteria as a defect.
- `0002-worker-identity.md`. The source of the Data Stores and Security
  sections.
- `0003-acceptance-by-refinement.md`. Where `amends`/`amended-by` come from, the
  source of the pipeline section, and the gate that accepts this decision.
- <https://architecture.md>. The section specification adopted here, in part.
- `skills/review/review.md`. The gate that will judge the synthesis, once this
  decision's live-document step lands in it. The acceptance criteria cannot, and
  say so.
- `skills/assess/assess.md`. Run over the synthesis as a spec when review or an
  implementing pull request calls for it.
- `docs/contributing/development-workflow.md`. The cheapest-first validation
  order this follows.
- `docs/assessments/0004.md`. The session that found the defects this revision
  answers.
