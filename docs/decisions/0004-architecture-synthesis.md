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

The table's header is a claim about each row's provenance, and every row carries
it: each traces to `0001-documentation-architecture.md` or
`0002-worker-identity.md`, both accepted. "Compiler, not runtime" is a section
heading in 0001.

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
reflecting none of them. A check whose subject is nearly empty would report what
it reports when the subject is complete, which is the failure the check exists
to prevent.

Three mechanisms carry it instead, and only one of them is a check. Each is
stated here with the hole it has, because the reason to write down three rather
than one is that each covers a different failure and none covers all of them.

**Doc-first carries completeness, for decisions that were built.** 0001 requires
the live document to be updated in the pull request that changes what it
describes. Under this decision the synthesis *is* what the live document claims,
so a decision's implementing pull request updates `docs/ARCHITECTURE.md` too —
which makes an unreflected decision unreachable rather than detectable.

Its hole is the decision that is accepted and not yet built. Doc-first attaches
to an implementing pull request, and an unbuilt decision has none, so nothing
obliges the synthesis to mention it. That is the right answer rather than a gap
to close: 0001 makes implementation status derived from `Implements:` trailers
and names accepted-but-not-built as its own contribution over ADR and RFD. A
synthesis states what the system *does*. Forcing an unbuilt decision into it as
a present-tense claim would reproduce 0001's Problem Statement — nine instances
of a document asserting something that was never built — in the one document
`CLAUDE.md` imports into every agent invocation.

So the synthesis carries decided-and-built claims, and the series carries the
rest. 0005 and 0007 sit in the archive today for exactly this reason.

**What this relocates rather than closes.** Keying both doc-first and the check
to `Implements:` trailers makes them agree about who is in scope, which is the
point. It also makes both blind to the same thing: the decision somebody built
and forgot to label. 0001 names that as the residue no mechanism reaches, and
this decision does not reach it either — a commit with no trailer is invisible
to the check the same way it is invisible to doc-first. That is one failure mode
held by two mechanisms rather than two mechanisms covering each other, and it is
worth saying plainly, because "the check and the rule agree" reads like
redundancy and is not.

The mechanical trailer check the `rfc-0003` postmortem recommends would narrow
it. Nothing here waits on that.

**Assess carries correctness**, when something schedules it.
`docs/ARCHITECTURE.md` is a spec file under `crochet:assess`'s own criteria: its
claims are capabilities, constraints and behaviours the system must exhibit. Run
with the document as the spec and the codebase as the subject, assess reports
where it asserts something the code does not do. When it reports an issue, run
it again over each decision the document cites: an issue means the document and
the code disagree, and only the decisions say which of the two is wrong.

Its hole was the trigger. This decision previously nominated `git zhi docs
health` reporting drift, and that trigger is dead where it matters. Drift is
computed from the document's mtime, and in a fresh clone or a worktree every
mtime is the checkout timestamp — so churn reads 0 and drift reads NONE for
every document, permanently, which is where CI runs and where every dispatched
agent works. Observed on 0.7.2: nine documents, all reporting `all current`,
with identical mtimes. `docs/contributing/development-workflow.md` already
records two other ways that summary reports all-clear over nothing; this is a
third, and it is a defect in git-zhi rather than in this decision.

The trigger is therefore the implementing pull request itself — the same event
doc-first already attaches to — plus `crochet:review`, which 0003 makes
mandatory and which reads the branch diff. Both are events nobody can skip,
which is what 0001's ladder asks of an enforcement point. Nothing here waits on
git-zhi fixing `docs health`.

**The citation check is the backstop.** Its subject is every accepted decision
that has at least one commit carrying its `Implements:` trailer — which is the
same population doc-first obliges, derived the same way, so the check and the
rule cannot disagree about who is in scope. `xt/run.sh` already reads those
trailers.

Three things about its strength, stated so that a pass is never read as more
than it is:

- **It is weaker than "a decision is reflected".** The citation form is `[NNNN]`
  linked to the file, so any implementation greps for the number, and the number
  appears in a link, a code fence, a References entry, or a sentence saying the
  decision is deliberately *not* synthesised. The check's real predicate is *the
  four-digit string appears in the file*. It cannot tell a claim from an
  explanation of a claim's absence.
- **It must not fail open.** Iterating citations found in the synthesis makes
  zero citations yield zero findings, indistinguishable from a perfect document.
  So it iterates *decisions* and asks whether each appears, reads
  `$ROOT/docs/ARCHITECTURE.md` rather than a path relative to the caller, and
  treats a missing or empty synthesis as a finding rather than a skip. The
  runner's existing per-file loops open `[ -f "$f" ] || continue` and it carries
  a comment recording what that cost.
- **It is not the thing that judges the synthesis.** No criterion can be, which
  is this section's whole argument. `crochet:review` judges it — once it can,
  which is the next section.

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
turned out to read NONE in every clone. So the synthesis is not a special case
needing a bespoke check — it is the first live document whose correctness
someone noticed nothing was checking.

Review's coverage lens gains a step: **for each live document whose `covers:`
paths the diff touches, read the document against the diff.** A claim the change
falsified is a finding. A change the document should have recorded and did not
is a finding. That is a judgment, produced by a mandatory gate, at an operation
nobody can skip — which is what 0001's ladder asks and what three prose rules
about doc-first have not delivered.

It is stated as a lens rather than a check on purpose. Whether a synthesis
reflects what was decided is the thing this decision argues cannot be counted,
so the mechanism that judges it must be one that reads.

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

The procedure for adding a skill is not part of what is absorbed. It is a *how*,
it lives in `docs/contributing/development-workflow.md`, and it stays there —
naming it here as something that "does not move" would send an implementer
looking for a section `plugin-structure.md` has never held.

Two paragraphs are dropped rather than absorbed, and dropping is the point in
both cases. The pipeline section's refusal to carry 0003 is superseded, as above.
And the paragraph beginning "It previously said the pipeline runs in strict
order" is temporal narration, which `docs/contributing/coding-conventions.md`
forbids in a live document; carrying it into the synthesis would import a
changelog into the file every agent loads.

### What this amends in 0001

0001 is in force and this decision stands on its referent split, its layers, its
citation form and its field test. Three rules inside it change and one of its
acceptance criteria is removed as a defect; the rest holds, so this amends
rather than supersedes.

`amends`/`amended-by` are not among the six fields 0001 requires. They come from
0003, which added them for exactly this case — a decision revising one rule
inside another that otherwise stays in force.

**Where the live architecture document lives.** 0001 places it in
`docs/architecture/`. It moves to `docs/ARCHITECTURE.md` — inside `docs/`, where
`docs check` and `docs health` both reach it, and under the name the external
specification uses.

**What the live architecture document owes the archive.** 0001 leaves the live
layer a free-standing description. It becomes a synthesis of the accepted
decisions, carrying citations into the archive.

**How stingy the live layer is.** 0001 says "stingy with live, generous with
archive... almost nothing is promoted out of it, and that asymmetry, not a
threshold, is what damps the feedback loop." This decision institutes systematic
promotion and makes it obligatory, which removes the damping 0001 named as its
mechanism. That is a deliberate trade and it is argued rather than left for a
later reader to find as a contradiction between two documents both in force.

The trade: what 0001 was protecting against is a live layer that grows until
nobody keeps it true, and the damping it chose was to promote almost nothing.
The cost is that ten decided rules reach no agent, which is the Problem
Statement above. The synthesis promotes *claims, with citations*, not arguments —
a decision's reasoning stays in the archive and only its conclusion is carried,
so the line count promoted is a fraction of the decision's. The three accepted
decisions are 1,694 lines; the document that replaces them in an agent's context
is expected to stay nearer `plugin-structure.md`'s 130 than their total.

**That expectation is not a check, and length is where this decision is most
likely to be wrong.** If the synthesis grows past the point where an always-
imported document is cheap, the answer is to shorten claims rather than to drop
decisions, because the check is what makes the promotion obligatory and the
brevity is what makes it affordable. A future decision that finds this trade
mispriced should say so and amend here.

**And one acceptance criterion of 0001 is removed as a defect, not amended.**
`0001` carries `an architecture doc exists under docs/`, checked by
`test -n "$(ls docs/architecture/*.md 2>/dev/null)"`. This decision removes that
directory, so the criterion becomes permanently unrunnable — the same shape that
`docs/contributing/coding-conventions.md` records biting `0002-worker-identity.md`,
and nothing would detect it, because `xt/run.sh` does not execute decision
criteria. A criterion pinned to a path that a later decision legitimately moves
is a defect in how it was written rather than a position 0001 took, so it is
removed on the footing 0002's were. The rule it was checking survives as
`test -f docs/ARCHITECTURE.md`.

**That footing does not exist yet, and this decision lands it.**
`docs/contributing/coding-conventions.md` carries two constraints on what a
criterion may be — no naming a specific test, nothing satisfiable only by
another repository — and path-pinning is neither. So the third constraint goes
in with this change, as Scope of Change records. Removing a criterion under a
rule that arrives in the same pull request is the honest order; removing it
under a rule that does not exist is what would need the argument.

**Seven sites, not two.** `docs/architecture` appears in 0001 seven times, and a
reader told "two rules change" who then finds seven mentions has no way to sort
deliberate staleness from oversight. Named by what they are, because a decision
names a symbol and never a line — a line number decays the moment anything above
it shifts, and decays silently, since nothing reads a decision at build time:

- the rule placing covers-bearing live documents, and the reasoning about which
  documents the tools can see — **changed here**
- the doc-first rule's statement of its own scope — **changed here**
- the acceptance criterion listing `docs/architecture/*.md` — **removed here**,
  as above
- the referent table's live-layer cell, the definition of what `t/` tests, and
  the Scope of Change and `xt/` bullets — **archive prose, left stale by
  design** under 0001's own "true as of its date"

## Scope of Change

This needs nothing from git-zhi. Observed on 0.7.2, in a scratch repository, by
two participants independently: a document at `docs/ARCHITECTURE.md` is listed
by `docs health`, its dead links are reported by `docs check`, and it is
reachable from `CONTRIBUTING.md` at the root. A document at the repository root
is seen by neither tool, which is why it lives one level in.

Being *listed* by `docs health` is all that is claimed. Its drift column is not
load-bearing here, for the reason given above.

**`docs/ARCHITECTURE.md`.** The synthesis, carrying `covers:` and `stability:`
as a live document.

**`docs/architecture/plugin-structure.md`.** Removed, its content absorbed. The
directory goes with it.

**`CLAUDE.md`.** The import retargets to `@docs/ARCHITECTURE.md`.

**`CONTRIBUTING.md`.** The Architecture short link retargets to the file. It
stays at the repository root: `docs check` starts its reachability walk from
`<root>/CONTRIBUTING.md` and finds nothing if it is moved.

Its sentence "Every link here points at a directory that holds a file" stops
being true when the first link points at a file, and is reworded in the same
pass. The sentence exists because git does not track empty directories, so a
link into one survives locally and dies on the first clone — that hazard applies
to the six directory links and not to the file, and the reworded sentence says
so. No check reads prose, so a live document at the root of the reachability
walk would otherwise ship a false invariant indefinitely.

**`docs/decisions/0003` and `docs/decisions/0006`.** Three by-path citations to
`docs/architecture/plugin-structure.md` — `0003` twice, `0006` once — are
retargeted. Nothing detects these: `coding-conventions.md` records that the
citation check rejects a `file:line` reference, not a filename that stopped
existing, and two of the three are inside an accepted decision.

**`skills/review/review.md`.** The coverage lens gains the live-document step
above. This is the only skill this decision changes, and it is changed because
the decision's own answer to "what judges the synthesis" is otherwise a claim
about a step that does not exist.

**`docs/contributing/coding-conventions.md`.** A third constraint on what a
decision's acceptance criterion may be: **it may not be pinned to a path that a
later decision can legitimately move.** The two constraints there now — no
naming a specific test, nothing satisfiable only by another repository — do not
cover 0001's `ls docs/architecture/*.md`, and this decision removes that
criterion claiming "the same footing 0002's were". Without the third constraint
that footing is not there, so the constraint lands in the same pull request or
the removal is unjustified.

**`docs/contributing/development-workflow.md`.** It is the live document that
sets the cheapest-first validation order, and this decision changes what
validates the one live document it creates. The order it states does not cover
the synthesis; it gains the implementing pull request and review.

**`CLAUDE.md`.** The import retargets, and its gate-policy paragraph is reduced
to a pointer. `CLAUDE.md` states "Three gates are mandatory: assess, review and
postmortem" and the synthesis's pipeline section will state it too, with both
files imported into every agent invocation. `skills/assess/assess.md` already
records why that is a defect rather than redundancy: "a rule worth stating twice
is a rule that will eventually be two rules." **The synthesis holds it**, being
the document whose job is to state what was decided, and `CLAUDE.md` points at
it.

**`xt/run.sh`.** Four changes. Three are checks, in the file that already
iterates `$DEC/*.md`, reads `state:` and reads `Implements:` trailers with the
same idioms:

- its `covers:` loop reaches `docs/` itself, not only `docs/architecture` and
  `docs/contributing`
- every decision cited by the synthesis is `accepted`
- every accepted decision with an implementing commit is cited in the synthesis,
  read from `$ROOT/docs/ARCHITECTURE.md`, with a missing or citation-less
  synthesis reported rather than skipped

**The fourth is the self-test block, and it is the one that makes the third
check honest.** The trailer population must come from the repository at `$ROOT`
and from nowhere else. Run directly against `xt/fixture`, `git log` resolves to
the *enclosing* repository, so the check reads crochet's own trailers and
reports on a subject that is not the one named — the defect class this
repository has found nine times, reintroduced by the fix for it. Squashing
crochet's history would change what a check about the fixture reports.

So: **where `$ROOT` is not itself the top of a git repository, the population is
undetermined and the check says so** rather than borrowing one. And the
self-test, whose copy *is* a repository, gains what the checks need to fire —
a second `Implements:` trailer naming the fixture's accepted decision, and a
second pass over the copy with `docs/ARCHITECTURE.md` removed, with `expected`
matched against both passes' output.

The second pass is what resolves a contradiction the criteria would otherwise
carry: a synthesis cannot be simultaneously present-and-citing-an-unaccepted-
decision and missing. Two passes over one fixture tree, rather than a second
fixture root, because the tree is the subject and its absence is a state of it.

**`xt/fixture/`.** A `docs/ARCHITECTURE.md` citing an unaccepted decision, and
an accepted decision with an implementing commit that it cites nowhere, so each
new check has a case that fails on purpose.

**`xt/fixture/expected`.** Three entries — one per new check — and a recount.
The file declares its own length as `# count:`, that count is checked against
its entries, and its ledger of covered sites says "Recount when a site is
added". That ledger currently reads 9 of 27, so this lands 12 of 30. It is the
only thing that detects a check going quiet, so a fixture case landing without
its `expected` entry leaves the self-test passing while proving nothing about
the new checks.

## Acceptance Criteria

**These check the mechanism, not the synthesis.** Every criterion below is
satisfied by a `docs/ARCHITECTURE.md` whose entire content is its citations,
which is the straw man this decision's Completeness section constructs and
rejects — so a criteria set that claimed otherwise would reproduce, in its own
verification, the failure it argues against. `git-zhi-verify` runs these at
`milestone edit --state complete`, an operation nobody can skip, and what they
prove is that the document is in the right place, wired to the right tools, and
guarded by checks that can still fail.

**What judges the synthesis is `crochet:review`**, which 0003 makes mandatory,
reading the branch diff against the decisions the document cites. That is a
judgment, and nothing else produces one.

- [ ] the synthesis is at docs/ARCHITECTURE.md (`test -f docs/ARCHITECTURE.md`)
- [ ] the installed binary lists it as a document (`git zhi docs health --format json | grep -q '"file": "docs/ARCHITECTURE.md"'`)
- [ ] the absorbed document and its directory are gone (`! test -e docs/architecture`)
- [ ] CLAUDE.md imports it (`grep -q '^@docs/ARCHITECTURE.md' CLAUDE.md`)
- [ ] CONTRIBUTING.md links to it (`grep -q 'docs/ARCHITECTURE.md' CONTRIBUTING.md`)
- [ ] CONTRIBUTING.md no longer claims every short link is a directory (`! grep -q 'Every link here points at a directory' CONTRIBUTING.md`)
- [ ] the other decisions no longer cite the absorbed document by path (`! grep -q 'architecture/plugin-structure.md' docs/decisions/0003-*.md docs/decisions/0006-*.md`)
- [ ] review reads live documents against the diff (`grep -q 'read the document against the diff' skills/review/review.md`)
- [ ] the fixture proves the unaccepted-citation check (`grep -q 'the synthesis cites' xt/fixture/expected && sh xt/run.sh`)
- [ ] the fixture proves the cited-nowhere check (`grep -q 'cited nowhere in the synthesis' xt/fixture/expected && sh xt/run.sh`)
- [ ] the fixture proves a missing synthesis is a finding, not a skip (`grep -q 'the synthesis is missing' xt/fixture/expected && sh xt/run.sh`)

**The last three go through `expected` rather than through a direct fixture
run,** and the reason is the whole of this decision's subject. `sh xt/run.sh
xt/fixture` resolves `git log` to the enclosing repository, so a criterion
written that way passes on crochet's trailers rather than the fixture's. The
`expected` ledger is matched against the self-test's run of its own copy, and
the self-test reports any declared entry that went unmatched — so "the entry is
declared and `sh xt/run.sh` passes" means the note fired, in the repository it
was supposed to fire in.

That also lets a synthesis be present in one pass and absent in another, which
three criteria against one fixture tree otherwise cannot express.

**Each runner criterion names a substring no existing check emits**, and that is
a known cost rather than an oversight: a criterion asserting a check fires must
name something about it, and wording is what there is to name. One of these
already decayed once — `'cited nowhere'` became `'cited nowhere in the
synthesis'` between revisions of this decision — which is the decay
`coding-conventions.md`'s first constraint describes, in the mildest form it
takes. The alternative is a criterion that cannot tell a check from its absence,
and this decision has already shipped one of those.

## Open Questions

- Whether `docs/ARCHITECTURE.md` should carry `covers:` paths distinct from the ones
  `plugin-structure.md` declared. It currently covers `skills/`, `commands/` and
  the manifest; a synthesis of decisions arguably also covers `t/` and `xt/`,
  since it states what they are for.

  This question no longer gates anything, and that is a change from how it stood
  when it was written. `covers:` fed the `docs health` drift trigger, and this
  decision no longer relies on that trigger, so widening or narrowing the list
  changes what a report lists and not what gets run. It stays open as an
  editorial question rather than a mechanical one.

- What `stability:` value the synthesis carries. `docs health` reads it and
  nothing here specifies it.

- Whether the git-zhi defect behind the dropped trigger is worth a request
  document. `docs health`'s drift column is computed from mtime and reads NONE
  in every fresh clone and worktree; `docs/requests/` is where this repository
  writes such things for another repository, and nothing has been written.

## References

- `0001-documentation-architecture.md`. The layers, the referent split, the
  enforcement ladder and the field test. This amends three of its rules and
  removes one of its acceptance criteria as a defect.
- `0002-worker-identity.md`. The source of the Data Stores and Security
  sections.
- `0003-acceptance-by-refinement.md`. Where `amends`/`amended-by` come from, the
  source of the pipeline section, and the gate that accepts this decision.
- <https://architecture.md>. The section specification adopted here, in part.
- `skills/review/review.md`. The gate that judges the synthesis. The acceptance
  criteria cannot, and say so.
- `skills/assess/assess.md`. Run over the synthesis as a spec when review or an
  implementing pull request calls for it.
- `docs/contributing/development-workflow.md`. The cheapest-first validation
  order this follows.
- `docs/assessments/0004.md`. The session that found the defects this revision
  answers.
