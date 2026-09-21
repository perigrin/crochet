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
`CLAUDE.md` repeats it, and nothing reads a live document at any point in the
pipeline.

## Problem Statement

`grep -n -i 'live doc\|architecture\|synthesis\|doc-first' skills/review/review.md`
returns nothing. Review's coverage lens finds a decision from `Implements:`
trailers and checks the milestone's acceptance criteria; its quality lenses are
code reviewers. Neither reads a markdown document against an archive.

So doc-first sits at rung 3 of `0001`'s own ladder — a rule stated in prose,
kept by whoever remembers it. `0001` says most of the failures in its table
"were rules stated at rung 3 or 4 that needed rung 1 or 2", and doc-first is one
of its own rules in that position.

**The nearest thing to an enforcement point does not work.** `git zhi docs
health` reports drift when commits touch a document's `covers:` paths since the
document last changed. Two things make it unusable as a gate, both measured on
0.7.2 and recorded in `docs/requests/git-zhi-docs-health-silent-passes.md`: a
`covers:` entry written with a trailing slash matches no churn, and a document
whose commit date cannot be resolved is reported as current rather than unknown.

Those are defects and the first has a one-character workaround. **But the
structural reason is the one that would survive both being fixed:** under
doc-first the document and the code land in the same pull request, so a
compliant repository never accumulates drift. A signal that is structurally
silent for compliant work cannot schedule work on it.

## Proposal

### Review's coverage lens reads live documents against the diff

For each live document whose `covers:` paths the diff touches, read the document
against the diff. That is a judgment, produced by a mandatory gate, at an
operation nobody can skip — which is what `0001`'s ladder asks and what three
prose statements of doc-first have not delivered.

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

It is a lens rather than a check on purpose. Whether a document still describes
the code is a judgment, and a mechanism that judges must be one that reads.

### A live document is one `CLAUDE.md` imports

The lens needs to know its subject and nothing currently answers that. `covers:`
does not: eleven documents under `docs/` carry it and eight are archive,
including assessments covering the very skills a change touches. The
discriminator in force is location — `xt/run.sh` reads `docs/architecture` and
`docs/contributing` — which `0004` removes half of.

So: a document is live when `CLAUDE.md` imports it. One grep, already the
operative definition in `0001`'s terms, and the set cannot grow by accident
because adding to it means editing the file every agent loads.

### A mechanical backstop, stated as weak

Review is a judgment and judgments are not run on every commit. A check catches
the coarsest failure — a decision reflected nowhere at all.

**Its subject is every accepted decision with at least one commit carrying its
`Implements:` trailer**, which is the population doc-first obliges, derived the
same way, so rule and check cannot disagree about scope. Both are therefore
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
This is written down as weak so that a pass is never read as evidence that a
live document is complete.

## Scope of Change

**`skills/review/review.md`.** The coverage lens gains the live-document step.

**`xt/run.sh` and `xt/fixture/`.** The backstop check, with a fixture case that
fails on purpose for each way it can fail — reflected nowhere, subject absent,
population untrustworthy. How the fixture supplies an untrustworthy population,
and which `expected` entries account for the new notes, belong to the
implementing issue.

**`docs/contributing/development-workflow.md`.** It sets the cheapest-first
validation order and does not cover live documents; the order gains review.

## Acceptance Criteria

- [ ] review's coverage lens reads live documents against the diff (`grep -q 'read the document against the diff' skills/review/review.md`)
- [ ] the lens knows what a live document is (`grep -q 'CLAUDE.md imports' skills/review/review.md`)
- [ ] the backstop reports a decision reflected nowhere (`grep -q 'cited nowhere' xt/fixture/expected && sh xt/run.sh`)
- [ ] the backstop reports rather than skips when it cannot see its subject (`grep -q 'cannot see' xt/fixture/expected && sh xt/run.sh`)
- [ ] the repository passes with the checks in place (`sh xt/run.sh`)

Two of these name prose and will redden when it is reworded. That is the decay
`docs/contributing/coding-conventions.md`'s first constraint describes, in its
mildest form, and the alternative is a criterion that cannot tell a step from
its absence.

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
