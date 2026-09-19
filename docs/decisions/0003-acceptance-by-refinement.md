---
title: Acceptance by refinement
state: proposed
author: Chris Prather
date: 2026-09-18
supersedes: []
superseded-by: []
amends: [0001]
---

# 0003: Acceptance by refinement

A proposal is accepted by asking for it to be refined. Not by a separate act,
and not by a go-ahead at the execute gate.

## Problem Statement

Decision 0001's transition table says:

> | `proposed` → `accepted` | chain-review passes and the human says execute |

and beneath it: "Today the second is an event with no record in the document."

Both lines are wrong, and they are wrong in the way 0001 exists to prevent.

**The event is misidentified.** By the time chain-review runs, a milestone and
seventeen issues exist. The decision to build was taken before any of that,
when someone asked for the spec to be decomposed. Placing acceptance at execute
puts it after the work it authorises.

**And the second line concedes a recordless event.** 0001 argues throughout
that a claim with nothing connecting it to the world is the failure mode; it
then records a transition it admits leaves no trace. A go-ahead is spoken and
gone. A refinement request leaves a chain, which either exists or does not.

This was not a disagreement about intent. perigrin believed crochet already
worked this way; 0001 said the opposite; both readings were drawn from the same
pipeline ordering, where refinement sits at step three and chain-review at
step four. Two readers inferring different acceptance points from one ordering
is the argument for stating it outright rather than leaving it to inference.

## Proposal

**`proposed` → `accepted` happens when refinement is requested against the
document.**

The reason is the cost. Refinement dispatches four agent roles over a spec and
a codebase; nobody spends that on a proposal they have not decided to build.
The expenditure *is* the commitment, so acceptance becomes a side effect of an
act someone was going to perform anyway rather than a ceremony they have to
remember.

That generalises, and it now covers every transition this model has:

> Every state transition worth having is a side effect of an act someone was
> going to perform anyway, leaving a mechanical trace.

Writing the document. Asking for refinement. Writing the superseding document.
Writing the `Implements:` trailer. None is bookkeeping performed for its own
sake, which is why none of them gets forgotten.

**`declined` is the exception, and it explains itself.** Deciding not to act
leaves nothing behind, so it is the one state that must be written down.
Without the record, declined is indistinguishable from not yet decided.

**This is new.** Crochet does not behave this way today and no skill says it
does. Refinement's four pipeline-readiness checks do stop and ask, but they ask
about a dirty tree, omissions, scope contradictions and feasibility — readiness
questions, not a decision to build. Recording this as existing practice would
be the failure in 0001's own table.

## Amending rather than superseding

0001 is `accepted` and being implemented. Its own rule freezes an accepted
entry: immutable in content, append-only in status, changed only by
supersession. That rule is right and this document does not edit 0001's body.

But supersession is the wrong instrument here, and discovering that is part of
this decision. Supersession says a document stopped being right. 0001 has not:
one row of one table is wrong, and the rest is in force and half-built, with
implementing commits citing it right now. Marking it `superseded` would tell a
reader that none of it holds.

So this introduces a second relation:

- **`amends:`** — this document revises a rule inside a decision that otherwise
  remains in force.
- **`amended-by:`** — its mirror, written into the amended document.

Both are written in one commit, like `supersedes`/`superseded-by`, and checked
by the same symmetry rule. They pass 0001's field test:
each answers where a document stands and what it connects to, not what kind of
thing it is.

**Presence differs from the pair it mirrors, deliberately.** `supersedes` and
`superseded-by` are required by 0001 and written empty when unused, because
they are the series' core vocabulary and a reader should see the concept on
every entry. `amends` and `amended-by` are written only when the relation
exists; an entry that amends nothing omits the key rather than carrying
`amends: []`.

That is not the `covers: []` mistake in another costume, and the distinction is
worth stating because it is easy to over-apply. An empty `covers:` was a
problem because something *read* it: the drift sensor consumed the list and
went blind on an empty one, so the emptiness was load-bearing and silent. An
empty `supersedes:` is inert — nothing computes from it, and the symmetry check
skips it. The test is not whether a field can be empty. It is whether anything
depends on it being non-empty.

The distinction is observable rather than stylistic. After supersession the old
document is not in force. After amendment it is, minus the amended rule — which
is exactly 0001's situation, and why `amended-by` can be appended to a frozen
document while a content edit cannot.

## Scope of Change

- **`docs/decisions/0001-documentation-architecture.md`**: gains
  `amended-by: [0003]` in its frontmatter. A status append, permitted by its own
  mutability rule. Its body is not touched, including the transition table this
  document corrects — a reader follows the link.
- **`skills/refinement/refinement.md`**: when the spec it is refining is a
  decision under `docs/decisions/` whose `state:` is `proposed`, refinement
  writes `state: accepted` before dispatching the architect. That write is the
  mechanical trace this decision rests on; without it the rule is prose.

## Acceptance Criteria

- [ ] this decision records what it amends (`grep -q '^amends: \[0001\]' docs/decisions/0003-acceptance-by-refinement.md`)
- [ ] the amended decision records it back (`grep -q '^amended-by: \[0003\]' docs/decisions/0001-documentation-architecture.md`)
- [ ] 0001 is not marked superseded, because it is still in force (`grep -q '^state: accepted' docs/decisions/0001-documentation-architecture.md`)
- [ ] refinement records acceptance on the decision it refines (`grep -q 'state: accepted' skills/refinement/refinement.md`)
- [ ] decision numbering stays sequential (`git zhi docs check`)

## Open Questions

- Whether `state:` should shrink further. `proposed`, `accepted` and
  `superseded` all now have mechanical traces — a file, a chain, a superseding
  document — which leaves only `declined` strictly needing declaration. Against
  that is the read-alone principle: a fully derived status shows nothing about
  where a decision stands to someone reading it on a web view with no shell.
  Recorded as open; not proposed here.
- Whether `amends:` earns its place, or whether a second relation is one more
  than this series needs. It was introduced because the alternative was marking
  a half-implemented decision superseded, but a series with one amendment in it
  is not yet evidence that the relation is load-bearing.

## References

- `0001-documentation-architecture.md`. The decision this one amends, and the
  source of the field test, the mutability rule and the transition table.
- `pages/repo-documentation-architecture.md` in perigrin's commonplace book,
  where the ruling was made.
