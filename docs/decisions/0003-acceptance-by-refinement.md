---
title: The workflow protocol
state: proposed
author: Chris Prather
date: 2026-09-18
supersedes: []
superseded-by: []
amends: [0001]
---

# 0003: The workflow protocol

Which gates the pipeline has, which are mandatory, what each must leave behind,
and what happens when the loop is entered somewhere other than the start.

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
gone.

A refinement request leaves a trace, but an earlier draft named the wrong one.
It said the trace is the chain, "which either exists or does not" — and 0001
says the chain "is ephemeral and nothing cites it". A trace that evaporates
when the milestone is cleaned up is not a trace. **The durable record is the
commit in which refinement writes `state: accepted` into the document.** The
chain is the occasion for that write, not the evidence of it.

This was not a disagreement about intent. perigrin believed crochet already
worked this way; 0001 said the opposite; both readings were drawn from the same
pipeline ordering, where refinement sits at step three and chain-review at
step four. Two readers inferring different acceptance points from one ordering
is the argument for stating it outright rather than leaving it to inference.

### The larger problem underneath

Correcting one transition leaves the real defect standing: **the pipeline is
declared in five places and enforced in none.**

The ordering appears in `CLAUDE.md`'s pipeline block, in the Pipeline
Orientation section of `skills/preflight/preflight.md`, in the SDLC Pipeline
section of `docs/architecture/plugin-structure.md`, and in the opening
paragraphs of `skills/refinement/refinement.md` and
`skills/chain-review/chain-review.md`. Four of those say the steps are gates
and that the pipeline runs in strict order.

No skill checks that its predecessor ran. Preflight comes closest and is
explicitly advisory — its own Key Constraints say pipeline orientation "never
blocks a skill" and both it and the version check "fail open". Every other
skill begins work on whatever state it finds.

That places the whole protocol on rung 4 of 0001's enforcement ladder: human
prose, believed or not. And prose does not bind the thing reading it. In a
single session an agent holding this document in context skipped refinement and
chain-review on 0002, proposed going straight from a written RFC to refinement
three times, and was about to refine 0004 while the decision it depends on was
still `proposed`. Each was caught by perigrin, none by a check.

**The gates that got skipped are the gates that leave nothing behind.**
Refinement was also skipped on 0002 — and refinement writes `state: accepted`,
so `xt/run.sh` now detects that skip and reports it. The difference between a
skip that is visible and a skip that is invisible is not the agent's diligence.
It is whether the gate wrote something down.

### What is missing entirely

Nothing evaluates the outcome. The postmortem analyses the process — friction,
decisions that could have been smoother — not whether the delivery is any good
or matches what was decided.

The closing checks that do exist are mechanical. Execute's Step 5 runs
verification before completion, then the postmortem, then `milestone edit
--state complete`, which runs the verify gate over every done issue's
acceptance criteria. The milestone's resolution command is a shell command of
the `go test ./...` kind. All of these answer *do the checks pass*. None
answers *did we build what the decision said, and is the result sound*.

PAAD review runs inside execute, per issue — the unit of work. The unit of
delivery is never reviewed as a whole. Nobody looks at the milestone's diff.

## Proposal

### Seven gates

```
superpowers:brainstorming → crochet:assess → crochet:refinement →
crochet:chain-review → crochet:execute → crochet:review → crochet:postmortem
```

`crochet:review` is new. It sits between execute and postmortem and reviews the
unit of delivery against the decision that authorised it.

### Mandatory means backfilled, not ordered

The pipeline is a loop that can be entered at any point. A gate is mandatory
not because it must run in its nominal position, but because **its artifact may
not be permanently absent** — entering the loop at any later gate forces the
missing upstream artifacts into existence.

So a gate never refuses to start. It backfills what is missing, at cursory
quality, and continues. Work that arrives half-built and undocumented is a
legal entry point rather than a violation; what is not legal is finishing
without the artifacts.

**A workflow is improv: you rarely refuse, you "yes, and".** Accept the state
you are handed and add what the requirements need. This is the rule that
decides the ambiguous cases — when it is unclear whether to block or to
backfill, backfill. A protocol that refuses gets worked around, and then there
is neither the gate nor the record of having skipped it, which is the condition
this document exists to end.

The one line an agent cannot deliver is the intent axis of a backfilled
assessment. That is not a refusal but a handoff: the scene continues, and the
other player has to say that line.

This is what separates a legal skip from an omission. A skipped step whose
property was established another way and recorded is legal. An unrecorded skip
is an omission however reasonable the judgment behind it was, because nothing
distinguishes it from having forgotten.

| Gate | Mandatory | The property it establishes |
|---|---|---|
| brainstorming | no | — |
| assess | yes | the spec aligns to the codebase, to the architecture, and to the intended direction of the repository |
| refinement | yes | the spec is decomposed into units of work; the document is now part of the architecture |
| chain-review | yes | the units of work are ready to be iterated on |
| execute | yes | the units of work are built |
| review | yes | the delivery matches the decision and the code is sound |
| postmortem | yes | friction and process decisions are captured |

**Brainstorming is the one optional gate.** Its artifact is the spec, and a
spec can be written without it. What is mandatory is that a spec exists, which
every gate downstream enforces. Decision 0005 is the standing example: written
directly as a placeholder, never brainstormed, and legitimately `proposed`.

A single terminal checkpoint at milestone completion was considered and
rejected. Backfilling at each gate surfaces a gap at the point where repair is
cheapest; a terminal check would let a decision be refined, executed and
reviewed before anything noticed that assess never ran.

### Each gate backfills the artifacts before it

Backfill is transitive, not pairwise. Each gate confirms that a cursory
artifact exists for every mandatory gate before it, and creates what is
missing.

| Gate | Confirms or creates an artifact for |
|---|---|
| assess | the spec |
| refinement | spec, assessment |
| chain-review | spec, assessment, chain |
| execute | spec, assessment, chain, chain-review |
| review | all of the above, and the diff |
| postmortem | all of the above, and the review |

The consequence is that a late gate backstops every earlier one. Running review
establishes that an assessment exists, and by extension that a spec exists for
the code being reviewed. Review is the last gate that can repair a missing
upstream artifact while the work is still open, which is why it precedes the
postmortem.

### What each gate leaves behind

A gate that leaves no trace cannot be backfilled, because nothing can tell
whether it happened.

| Gate | Record |
|---|---|
| brainstorming | the spec document |
| assess | the assessment, in the milestone body |
| refinement | `state: accepted` written into the document; the issues |
| chain-review | a checklist entry in the milestone body |
| execute | commits carrying `Implements: NNNN` |
| review | a checklist entry in the milestone body |
| postmortem | `docs/postmortems/<milestone>.md`, attached with `milestone edit --postmortem` |

**The assessment lives in the milestone body, written when refinement creates
the milestone.** Refinement cannot paste an assessment it does not have, so the
record is the assessment itself rather than an assertion that one was made.
Skipping assess does not mean answering a question untruthfully; it means
fabricating a gap analysis, which is more work than performing one and is
reviewable afterwards.

This is possible because a milestone can carry a body. The architect prompt
currently states the opposite — that there is "no flag, stdin, or `$EDITOR`
path to attach a body or resolution command", and that the CLI cannot store the
resolution command on the milestone. Both claims are false against git-zhi
0.6.0, where `milestone edit` accepts `--body`, `--resolution`, `--postmortem`
and `--tag`. The architect has been routing the milestone's own resolution
command through an issue acceptance criterion to work around a limitation that
no longer exists.

**Most records are cross-checked against a derived signal.** The decision reads
`state: accepted` if refinement ran; commits carry trailers if execute ran; a
postmortem file exists if the postmortem ran. Where a checklist entry and its
derived signal disagree — ticked but underivable, or derivable but unticked —
that disagreement is itself a finding.

**The checklist carries what derivation cannot.** A derived signal shows that a
gate passed. It cannot show that the gate was backfilled rather than run in
place. That distinction is the whole subject of this document, so the checklist
records when each gate was satisfied, by whom, and whether it was backfilled.

### The chain is local

`refs/zhi/` is not pushed: this repository's remote carries no `refs/zhi` refs
and no push refspec configures it. The milestone body, and therefore the
assessment and the checklist, exist in one clone.

This is sufficient for gating, because every gate runs in the clone the chain
lives in. It is not sufficient for review by anyone else, and a lost clone
loses the record. Recorded as a known limit rather than solved here.

### The cursory artifact

Backfill produces a cursory artifact, not a full one. For an assessment that
means answering the three axes explicitly, with evidence, and doing nothing
else: does the document align to the codebase as it stands, to the
architecture, and to the direction the repository is going. No `paad:pushback`
pass, no decomposition into blocking, missing and partial, no prerequisite
ordering. Full assess remains what runs in its nominal position; cursory is
what backfill produces.

This is the migration path, not a hypothetical. No milestone in this repository
records an assessment.

**In a backfilled assessment the intent axis is signed by the human, not by an
agent.** The first two axes can be recovered from artifacts at any time: the
code and the architecture are both present to compare. Intent cannot. Asking
whether shipped work is the direction the repository should go, of the agent
that shipped it, returns yes — the document and the code agree because the work
made them agree. That is this repository's recorded failure mode, and the
signature requirement is the guard against it.

### Units of delivery and units of work

- **A milestone is a unit of delivery** — one pull request or release.
- **A git-zhi issue is a unit of work** — one commit.

Units of work run in subagents with clean context. The orchestration session
compacts or clears between units of delivery, so that context from a completed
delivery does not carry into the next.

### crochet:review

`crochet:review` mirrors `crochet:chain-review` on the far side of execute.
Chain-review runs two lenses over the chain before work starts; review runs two
lenses over the diff after it finishes.

| | before execute | after execute |
|---|---|---|
| coverage | `crochet:alignment` — does the chain cover the spec? | does the diff cover the decision? |
| quality | `paad:pushback` — is the plan sound? | agentic code review and ponytail review |

**Review runs to a fixed point.** Run the lenses, apply what they find, run
again, until the findings stop changing. A single pass reports what one look
caught; a fixed point reports that nothing further is visible.

**The loop is bounded.** Execute already bounds its analogous loop at three
reopen cycles before reporting an issue as stuck. Review takes the same shape:
a bounded number of iterations, then non-convergence is reported rather than
spun on. A review that will not converge is a finding about the delivery.

**The ponytail lens cannot be capability-detected the usual way.** Preflight
builds its capabilities map by matching skill names, and ponytail is a hook.
The conditional pattern every other integration uses — delegate if available,
fall back otherwise — structurally cannot see it. Review either probes
differently or declares the dependency and fails loudly when it is absent.
Decision 0005 covers this ground and should settle the mechanism.

### What this does not claim

This protocol is rung 2 on *an artifact existing* and rung 3 on *that artifact
being truthful*. A fabricated assessment in a milestone body passes every
mechanical check described here. Nothing inside the repository can close that,
and saying so is better than implying the protocol is airtight.

The same limit applies to the `Implements:` trailer, which 0001 already names
as its soft spot. The trailer is self-reported, so an implementation that
claims nothing is invisible to any check keyed on it — including the check that
reports commits implementing a decision before it is accepted.
`skills/refinement/refinement.md` carries this decision's acceptance rule in
its Record Acceptance step while this decision is still `proposed`, and no
commit claims it. The closing review is the only gate positioned to notice,
because it reads the diff rather than the claims made about it.

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
  writes `state: accepted` before dispatching the architect. It backfills a
  cursory assessment when none exists, and writes the assessment into the
  milestone body.
- **`skills/refinement/architect-prompt.md`**: drop the false claims that a
  milestone cannot carry a body and that the CLI cannot store a resolution
  command. Store the resolution command with `milestone edit --resolution`
  rather than routing it through the final issue's acceptance criterion.
- **`skills/assess/assess.md`**: define the cursory assessment and the three
  axes, and state that the intent axis of a backfilled assessment is signed by
  the human.
- **`skills/review/review.md`** and **`commands/review.md`**: the new gate.
- **`skills/chain-review/chain-review.md`**, **`skills/execute/execute.md`**,
  **`skills/postmortem/postmortem.md`**: record their checklist entries, and
  backfill the upstream artifacts their position requires.
- **`skills/preflight/preflight.md`**: the pipeline gains a seventh step, and
  the inference table gains the state "milestone exists, zero issues".
- **`CLAUDE.md`**, **`docs/architecture/plugin-structure.md`**,
  **`README.md`**: the pipeline ordering and the skills table.
- **`xt/run.sh`**: whatever of this is checkable from the repository.

## Acceptance Criteria

- [ ] this decision records what it amends (`grep -q '^amends: \[0001\]' docs/decisions/0003-acceptance-by-refinement.md`)
- [ ] the amended decision records it back (`grep -q '^amended-by: \[0003\]' docs/decisions/0001-documentation-architecture.md`)
- [ ] 0001 is not marked superseded, because it is still in force (`grep -q '^state: accepted' docs/decisions/0001-documentation-architecture.md`)
- [ ] the assessment is written into the milestone body (`grep -q 'milestone edit .*--body' skills/refinement/architect-prompt.md`)
- [ ] the review gate exists as a skill (`test -f skills/review/review.md`)
- [ ] the review gate is user-invocable (`test -f commands/review.md`)
- [ ] the pipeline names seven gates everywhere it is stated (`test $(grep -rl 'crochet:review' CLAUDE.md docs/architecture/plugin-structure.md skills/preflight/preflight.md | wc -l) -eq 3`)
- [ ] the architect no longer denies that a milestone carries a body (`! grep -q 'no flag, stdin, or' skills/refinement/architect-prompt.md`)
- [ ] the architect stores the resolution command on the milestone (`grep -q 'milestone edit .*--resolution' skills/refinement/architect-prompt.md`)
- [ ] refinement backfills an assessment when none exists (`grep -q 'cursory assessment' skills/refinement/refinement.md`)
- [ ] assess defines the cursory form and who signs intent (`grep -q 'cursory' skills/assess/assess.md`)
- [ ] decision numbering stays sequential (`git zhi docs check`)

## Open Questions

- Whether `state:` should shrink further. `proposed`, `accepted` and
  `superseded` all now have mechanical traces — a file, the commit that writes
  `state: accepted`, a superseding document — which leaves only `declined` strictly needing declaration. Against
  that is the read-alone principle: a fully derived status shows nothing about
  where a decision stands to someone reading it on a web view with no shell.
  Recorded as open; not proposed here.
- Whether `amends:` earns its place, or whether a second relation is one more
  than this series needs. It was introduced because the alternative was marking
  a half-implemented decision superseded, but a series with one amendment in it
  is not yet evidence that the relation is load-bearing.
- Whether this document's filename should change. It is titled for the whole
  protocol and named `0003-acceptance-by-refinement.md`, which is the scope it
  had before this expansion. Renaming costs one citation in 0004 and the link
  symmetry check; leaving it costs a filename that misdescribes its contents.
- Whether a decision may be accepted while a decision it amends or depends on
  is still `proposed`. The ordering rule is stated nowhere and was nearly
  violated with 0004 against this document. It is checkable at the moment
  `state: accepted` is written.
- How far backfill can carry a delivery before the result is worthless. Every
  gate backfilled cursorily at the postmortem is legal under this protocol and
  is obviously not the intent. The candidate answer is that no bound is needed
  because none can be a refusal: a delivery built on cursory artifacts gives the
  closing review more to find, so its fixed point takes more iterations or fails
  to converge, and non-convergence is already reported. The cost of skipping is
  paid at review rather than at a gate that says no. Recorded as a candidate
  rather than settled, because it has not been observed.

## References

- `0001-documentation-architecture.md`. The decision this one amends, and the
  source of the field test, the mutability rule and the transition table.
- `0005-plugin-integration.md`. Where the ponytail detection problem is
  recorded, and where the mechanism for review's second lens should be settled.
- `pages/repo-documentation-architecture.md` in perigrin's commonplace book,
  where the ruling was made.
