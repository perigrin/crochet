---
title: Doc-first is enforced by review
state: proposed
author: Chris Prather
date: 2026-09-21
supersedes: []
superseded-by: []
amends: []
---

# 0008: Doc-first is enforced by review

Doc-first is a rule in the live layer that no gate enforces. `0001` requires a
live document to be updated in the pull request that changes what it describes,
`CLAUDE.md` states it more strictly still, and nothing reads a live document at any point in the
pipeline.

## Problem Statement

`grep -n -i 'live doc\|architecture\|synthesis\|doc-first' skills/review/review.md`
returns nothing. Review's coverage lens finds a decision from `Implements:`
trailers and checks the milestone's acceptance criteria; its quality lenses are
code reviewers. The coverage lens does read an archive document — the decision —
but **nothing in the gate reads a live document against the diff.**

**And the live layer does not agree with itself about the rule.** 0001 states
doc-first as "in one PR", `development-workflow.md` as "in the same pull
request", and `CLAUDE.md` as "in the same commit". The distinction is not
cosmetic: the argument below turns on the gap between a pull request and a
commit, and under `CLAUDE.md`'s stricter version `docs health` reports zero
always. A rule stated three times in three strengths, with nothing reconciling
them, is the condition this decision exists to end.

So doc-first sits at rung 3 of `0001`'s own ladder — a rule stated in prose,
kept by whoever remembers it. `0001` says most of the failures in its table
"were rules stated at rung 3 or 4 that needed rung 1 or 2", and doc-first is one
of its own rules in that position.

**The nearest thing to an enforcement point does not work.** `git zhi docs
health` reports drift when commits touch a document's `covers:` paths since the
document last changed. Three things make it unusable as a gate, all measured on
0.7.2 and recorded in `docs/requests/git-zhi-docs-health-silent-passes.md`: a
`covers:` entry written with a trailing slash matches no churn; a repository
whose history is truncated — a shallow clone, which `actions/checkout` produces
by default — reports every document current rather than unknown; and a code
commit sharing a second with the document's is not counted.

An uncommitted document is *not* one of those cases, and an earlier version of
this decision said it was. Its unresolvable date opens an unbounded window, so
it reports drift in the correct direction unless the first defect silences it.
How much depends on how long the history is, not on the defect.

Those are defects and the first has a one-character workaround. **The structural
reason survives both being fixed**, and it is narrower than it first looks.

Under doc-first the document and the code land in the same pull request, which
is not the same as the same commit. `development-workflow.md` states the rule as
"update the document first, then build to match, in the same pull request" — and
measured in a scratch repository with a linear history doing exactly that, the
document reports `churn 1, drift LOW`. Compliant work does accumulate drift when
the document commit precedes the code commit.

The measurement is from a scratch repository on purpose. This repository's
history is not linear and its reported churn does not reproduce from commit
counts — `docs/assessments/walkthrough-review.md` covers one file with one
commit since its `doc_modified` and reports three. A reader who tries to
reproduce these figures here will fail, which is how four earlier versions of
this passage went wrong.

It reports zero in four other cases, every one of them compliant: when document
and code land in one commit, which is what `CLAUDE.md` requires; when a merge
resets the window; when the two commits share a second; and throughout a shallow
clone. The merge case is why every measurement taken in this repository was
unreadable — `doc_modified` for `plugin-structure.md` is the date of merge
`6a18943`, not of `46acc60`, the last commit to touch it, because the lookup
follows `--full-history`.

So the same compliant work reports drift or does not, depending on which of the
three statements of doc-first its author followed and how the branch was merged.
**That is enough to disqualify it as a scheduler** without needing the stronger
claim that compliant work never drifts, which is false.

## Proposal

### Review's coverage lens reads live documents against the diff

For each live document whose `covers:` paths the diff touches, read the document
against the diff. That is a judgment, produced by a mandatory gate, at an
operation nobody can skip.

**This does not climb the ladder, and saying it does would be dishonest.** A
step in a skill file is instructions an agent follows, which is rung 3 — the
same rung as the prose statements of doc-first it replaces.

**A check is unavailable here, and 0001 says so itself.** Introducing the
enforcement ladder it concedes: "Honest asymmetry: a test is machine-checkable
and an architecture statement is not. This buys the discipline, not the proof."
So 0001 does not ask for rung 2 on this rule; it states that rung 2 is not
available for it. What follows is not a decision to settle for less than 0001
wanted, and it should not be argued as one.

**What changes is who holds the obligation and when.** Doc-first today is
addressed to the author, in documents the author reads before writing. It is not
that nobody reads them — `CLAUDE.md` is loaded into every session, which is the
same fact this decision uses two sections below to define the live set, and the
argument cannot have it both ways. It is that nothing at review time acts on the
rule. The lens moves it from a thing an author is asked to remember to a thing a
mandatory gate performs, and that is the whole of the improvement.

The backstop below is what rung 2 can carry, and it is deliberately coarse.

**A finding requires one of two things**: the diff falsifies a claim the
document makes, or the diff completes work the document describes as pending. An
enumeration the change renders incomplete is a falsified claim — that is what
carries doc-first's own case, where a document lists what exists and the diff
adds one.

**The quiet case is the common case and is not a finding.** Every live document
covers `skills/`, so the lens fires on nearly every branch and will usually find
nothing. A trigger that fires on everything is ignored the way one that fires on
nothing is, and a diff under a covered path that the document never claimed
anything about is not a finding.

### A live document is one `CLAUDE.md` imports

The lens needs to know its subject and nothing currently answers that. `covers:`
does not: thirteen documents under `docs/` carry it in frontmatter and ten are
archive, including assessments covering the very skills a change touches. Only
eleven are *listed* by `docs health`, because postmortems carry the field and
are exempt from staleness checks — so counting what the tool prints undercounts
what carries the field, and the field is the thing a lens would key on. The
discriminator in force is location — `xt/run.sh` reads `docs/architecture` and
`docs/contributing` — which `0004` removes half of.

So: a document is live when `CLAUDE.md` imports it, **and `CLAUDE.md` is itself
in the set.** One grep plus one name, already the operative definition in
`0001`'s terms, and the set cannot grow by accident because adding to it means
editing the file every agent loads.

Naming `CLAUDE.md` explicitly matters because it is otherwise excluded on every
axis: it imports nothing of itself, carries no `covers:`, and sits outside
`docs/` where `docs health` cannot see it. It is also the live document with
drift on the record — 0003's Scope of Change documents it asserting a rule the
decision it cited had already replaced, loading every session on the authority
of the decision that removed it. A lens for doc-first that could not read
`CLAUDE.md` would miss the one failure of doc-first this repository has actually
recorded.

**`CLAUDE.md` is read on every diff, without a `covers:` trigger.** It has no
frontmatter and gains none: it is not a fourth live document but the door to the
other three, as 0001 says, and a door does not need a covered set to be worth
reading. Its claims are about the pipeline, the skills and the conventions
alike, so any `covers:` honest enough to trigger the lens would name the whole
repository — at which point the trigger is doing no work and the frontmatter is
bytes in every session's context for nothing.

An earlier revision of this decision asserted that `CLAUDE.md` carries such a
`covers:`. It does not, and nothing here was making it true.

### A mechanical backstop, stated as weak

Review is a judgment and judgments are not run on every commit. A check catches
the coarsest failure — a decision reflected nowhere at all.

**Its subject is every accepted decision with at least one commit carrying its
`Implements:` trailer**, which **overlaps** the population doc-first obliges
without matching it. Doc-first binds a pull request that changes what a live
document describes; the backstop asks after every implemented decision, and the
lens rules explicitly that a covered diff the document never claimed anything
about is not a finding.

So the check is stricter than the rule it backs, and the gap has a bad cure: a
decision implemented where no live document makes a claim can only satisfy the
check by gaining a line in the live layer whose sole purpose is to satisfy it.
0001 is stingy with live precisely because every line there is one someone must
keep true forever. **Where the two disagree, the rule governs and the check is
noise** — and the reviewer, not the check, decides which it is.

Under 0004 the two become nearly coextensive, since a synthesis of accepted
decisions makes a claim from each. Until then the gap is real and is recorded
rather than closed. Both are therefore
blind to the same thing: the commit somebody wrote and forgot to label. That is
one failure mode held twice rather than two mechanisms covering each other.

**It must not fail open, and it has two ways to.** Iterating citations rather
than decisions makes an empty document indistinguishable from a complete one.
And the trailer population is truncatable — a shallow clone is a repository top
holding one commit, and `actions/checkout` is shallow by default — so a check
that trusts whatever history it finds exempts every decision implemented
earlier while reporting clean. **A subject the check could not see is a finding,
never a skip.**

**And it is weaker than "a decision is reflected".** The citation form is a
number linked to a file, so any implementation's real predicate is *the number
appears somewhere in the document* — satisfied by a link, a code fence, a
references entry, or a sentence saying the decision is deliberately not
synthesised. It cannot tell a claim from an explanation of a claim's absence.

**Three ways that is worse than it sounds**, and the check's pattern must
account for the first two.

A bare search for a decision's number matches this repository's milestone names:
`rfc-0001`, `rfc-0003`, `rfc-0004` all contain one, and
`coding-conventions.md` contains the string `rfc-0003` today in a sentence about
an unrelated defect. The check matches a decision *citation*, not a number.

It also cannot tell a claim from a criticism. **On the day this lands the
backstop is green for 0002, and for the wrong reason**: 0002's only two
appearances in the live layer are `coding-conventions.md` faulting it twice —
once for carrying runnable acceptance criteria it should not have, once for
stale cross-repository citations. Worker identity and
`ZHI_ACTOR`, which are what 0002 decided, appear nowhere live — 0004's gap table
says as much. So the first run of this check passes on two hostile citations,
and nobody should read that as compliance.

This is written down so that a pass is never read as evidence that a live
document is complete.

## Scope of Change

**`skills/review/review.md`.** The coverage lens gains the live-document step.

**`xt/run.sh` and `xt/fixture/`.** The backstop check, with a fixture case that
fails on purpose for each way it can fail — reflected nowhere, subject absent,
population untrustworthy.

**Two of those cases need the runner's self-test setup, not fixture files**, and
an implementing issue that reads "add a fixture case" will not reach for it. The
untrustworthy-population arm is cheap: the setup already builds a repository
with `git init` and one commit, and writing `HEAD` into `.git/shallow` makes
`git rev-parse --is-shallow-repository` report true there while it reports false
here — which is the red-in-the-fixture, green-in-the-repository pairing
`docs/contributing/development-workflow.md` asks every check to have.

The reflected-nowhere arm is harder and this decision should not pretend
otherwise. Under the definition above the fixture has **no live documents at
all**, because it has no `CLAUDE.md`; and its only accepted decision is not one
the self-test's commit trailers. So the backstop's population there is empty,
and an empty population is exactly what this check must not read as a pass.
Giving it a subject means a `CLAUDE.md` in the fixture importing a document, and
a trailer in the setup naming an accepted fixture decision whose number that
document does not cite.

**Whatever the check does on an empty population, it does on a shallow one:
report.** If empty reads as clean, the fixture passes with no subject and the
criterion goes green having proved nothing — the same failure as a criterion
that passes before its work, wearing the fixture's clothes.

**`docs/contributing/development-workflow.md`.** It sets the cheapest-first
validation order and does not cover live documents; the order gains review.

**`CLAUDE.md` and `docs/contributing/development-workflow.md`, again: doc-first
is stated once.** Both are brought to 0001's wording — "in one PR". This
decision makes the gap load-bearing, so it closes it rather than only reporting
it: a mandatory gate that judges compliance with doc-first has to know which
rule it judges against, and an agent reading `CLAUDE.md` today holds a stricter
one than 0001 ever took, arrived at by drift rather than by decision.

No new decision is opened for this. There is nothing to decide — 0001 is
accepted and says "in one PR"; the other two are restatements that drifted, and
one clause in each brings them back.

## Acceptance Criteria

- [ ] review's coverage lens reads live documents against the diff (`grep -q 'read the document against the diff' skills/review/review.md`)
- [ ] the lens knows what a live document is (`grep -q 'is live when' skills/review/review.md`)
- [ ] the backstop reports a decision reflected nowhere (`grep -q 'cited nowhere' xt/fixture/expected && sh xt/run.sh`)
- [ ] the backstop reports rather than skips when it cannot see its subject (`grep -q 'cannot see' xt/fixture/expected && sh xt/run.sh`)
- [ ] the checks are in the runner and the repository passes them (`grep -q 'cited nowhere' xt/run.sh && grep -q 'cannot see' xt/run.sh && sh xt/run.sh`)
- [ ] doc-first is stated once, at 0001's strength (`tr -s '[:space:]' ' ' < CLAUDE.md | grep -q 'in one pull request' && ! tr -s '[:space:]' ' ' < CLAUDE.md | grep -q 'in the same commit' && tr -s '[:space:]' ' ' < docs/contributing/development-workflow.md | grep -q 'in one pull request' && ! tr -s '[:space:]' ' ' < docs/contributing/development-workflow.md | grep -q 'in the same pull request'`)

**The doc-first criterion asserts the new wording and the absence of the old**,
per file, because either half alone is satisfiable while the entry it checks is
unmet. Asking only for the replacement passes over a file that gained the new
sentence and kept the old, which leaves doc-first stated twice — the condition
the Scope of Change entry exists to end, with the surviving statement being the
stricter one loaded into every session.

Asking only for the absence was tried first and passed before any work, because
`CLAUDE.md` wraps that phrase across a line break and the search found nothing.
That is a negation over a subject the search could not see, which is this
repository's recurring defect arrived at by line-wrapping. It is fixable rather
than fatal: squeezing whitespace first finds the phrase across the wrap and both
negations are red today. **Unwrapping alone is not enough** — the continuation
lines are indented, so `tr '\n' ' '` leaves a double space and the search still
misses. That near-miss is the same trap one step over, and it is why the
criterion squeezes rather than unwraps.

**It asks for "in one pull request", not 0001's "in one PR".** The abbreviation
appears nowhere in the live layer, while "pull request" appears seven times
across it — six in the imported documents and once in `CLAUDE.md`, in the
doc-first bullet this criterion is about — so a
criterion demanding `PR` would force both documents to adopt a form neither uses
in order to satisfy a grep — the trade this decision declined one criterion
earlier, arriving from the other direction. What the entry reconciles is the
*strength* of the three statements, not their wording, and 0001 is archive and
keeps its own.

**All four conjuncts squeeze, including the two asserting presence.** The
asymmetry that stood here first was not cosmetic: `CLAUDE.md`'s doc-first bullet
is 72 characters and becomes 81 with the corrected phrase, against a file that
wraps in the high seventies. So the implementer writes the right sentence,
reflows to house width, the break lands inside "pull request", and the presence
half fails while the absence half beside it passes — three conjuncts green, the
one that matters red, and nothing saying why. The direction is safe and the
decay was near-certain rather than eventual.

**Two limits no grep escapes, named rather than fixed.** This repository bolds
its rules and the doc-first bullet is already bold, so `in **one** pull request`
would not match while `**in one pull request**` would. And a negated literal
cannot tell removal from rewording: "in a single commit" satisfies the absence
half while leaving a statement stricter than 0001 standing in the file every
agent loads. Enumerating the rewordings is not worth attempting; naming the
class is what the check can honestly carry.

These name five distinct prose strings across six criteria, and each will
redden when its wording changes. That is the decay
`docs/contributing/coding-conventions.md`'s first constraint describes, in its
mildest form, and the alternative is a criterion that cannot tell a step from
its absence.

**Three of them are conjunctions because `sh xt/run.sh` alone is green today.**
A criterion that passes before its work starts cannot report that the work was
done, and this decision's own backstop section is about checks that report what
they would report if clean. Both halves do work: the greps fail until the checks
exist, and the run fails if they exist and the repository does not satisfy them.
The fixture half cannot be satisfied by editing `xt/fixture/expected` alone —
the self-test requires every declared entry to appear in the fixture's output
and the file to declare its own length, so a fixture-only edit reports that the
check has gone quiet.

## Open Questions

- Whether the lens should fire on archive documents that carry `covers:`. It
  would catch a stale assessment; it would also fire on eight documents whose
  staleness is by design under `0001`'s "true as of its date".

- Whether the backstop belongs in `xt/run.sh` at all, or whether review reading
  the document makes a check for the coarsest case redundant. It is cheap and it
  runs on every commit where review runs once per delivery, which is the
  argument for keeping both.

## References

- `0001-documentation-architecture.md`. Doc-first, the enforcement ladder, and
  the live and archive layers.
- `0003-acceptance-by-refinement.md`. What makes review a mandatory gate, and
  what a gate owes in records.
- `0004-architecture-synthesis.md`. Split from this decision; it needs this one
  to make its own claim about what judges the synthesis true.
- `docs/requests/git-zhi-docs-health-silent-passes.md`. Why `docs health` cannot
  be the enforcement point.
