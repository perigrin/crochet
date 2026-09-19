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

### What the protocol is for

Crochet exists to maximise the autonomy of agents delivering software
iteratively, in collaboration with a human. That is the standard this protocol
is built against, and it is the direction assess's third axis measures a
document's alignment to.

It decides the questions the rest of this document would otherwise leave open.
A gate backfills rather than refuses, because a refusal needs a human to clear
it and every such gate is a stop in an autonomous run. An assessment requires a
different actor rather than a human one, because the property that matters is
independence and an agent supplies it. The human is a collaborator in the loop,
not a semaphore in it — and where this document does put a person in the path,
that is a cost to be justified rather than a default.

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

The one thing an agent cannot deliver is an assessment of its own work. That is
not a refusal but a handoff: the scene continues, and another player has to say
that line.

This is what separates a legal skip from an omission. A skipped step whose
property was established another way and recorded is legal. An unrecorded skip
is an omission however reasonable the judgment behind it was, because nothing
distinguishes it from having forgotten.

### Methods and judgments

Gates are not alike, and the difference decides which are mandatory.

A gate that **produces an artifact** is a method. Methods are optional: when
the artifact arrives some other way, the method is skipped and nothing is owed
for it. A gate that **produces a judgment** is mandatory, because nothing else
produces it.

| Gate | Kind | Mandatory | What must exist |
|---|---|---|---|
| brainstorming | method | no | the spec |
| assess | judgment | **yes** | the spec aligns to the codebase, to the architecture, and to the intended direction of the repository |
| refinement | method | no | acceptance — the decision that the work should be done |
| chain-review | judgment | when a chain exists | the units of work are ready to be iterated on |
| execute | method | no | the code |
| review | judgment | **yes** | the delivery matches the decision and the code is sound |
| postmortem | judgment | **yes** | autonomy-stealing friction is identified, with proposals for removing it |

Three gates are mandatory outright. The rest are the ordinary way of producing
something that must exist, and a document, an acceptance or a body of code that
arrives another way satisfies them.

**The case that fixes this is a finished pull request.** Code arrives fully
formed and none of the pipeline ran. Execute's artifact exists, so execute is
not owed. Nobody has judged whether the code aligns with anything, so assess is
owed — and the spec is owed with it, because assess needs a subject. Entry is at
review, and what gets backfilled is the assessment and the decision, not the
work.

**A chain is not backfilled.** Chain-review is vacuous when no chain exists, and
creating one for finished work would duplicate git history to no purpose — the
honest chain for a merged pull request is a single issue reading "merged PR",
which records nothing git does not already hold. 0001 already says the chain is
transient work state that nothing durable cites, with durable citations pointing
at commits instead; this is that rule reaching its conclusion.

**Acceptance survives the skip.** 0002 is the precedent already in the series:
accepted with no chain, because acceptance is the decision that the work should
be done, and refinement is how that decision is normally expressed rather than
what makes it true.

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
| assess | `docs/assessments/<milestone>.md`, moved into the milestone body by refinement |
| refinement | `state: accepted` written into the document; the issues |
| chain-review | a checklist entry in the milestone body |
| execute | commits carrying `Implements: NNNN` |
| review | a checklist entry in the milestone body |
| postmortem | `docs/postmortems/<milestone>.md`, attached with `milestone edit --postmortem` |

**Assess writes the assessment to `docs/assessments/`; refinement moves it into
the milestone body.** This mirrors the postmortem exactly — written to the
archive first, attached to the milestone second — and for the same reason. An
assessment that exists only in conversation is lost at the first compaction or
agent handoff, and this protocol instructs the orchestrator to compact between
units of delivery. The gate's record cannot live in the context the protocol
tells you to discard.

The record is the assessment itself rather than an assertion that one was made.
Refinement cannot paste an assessment it does not have, so skipping assess does
not mean answering a question untruthfully; it means fabricating a gap
analysis, which is more work than performing one and is reviewable afterwards.

`docs/assessments/` must be reachable from `CONTRIBUTING.md`, or `git zhi docs
check` reports every file in it unreachable.

**Each milestone gets its own assessment.** A decision spanning several
milestones is not assessed once and cited thereafter. The second assessment
starts from the first plus the changes since, so the cost is a diff rather than
a fresh analysis — and because it measures the codebase as it stands rather
than checking whether a record has aged, it captures the influence of work that
was never recorded at all. A dated reference can only report that it is old. An
assessment reports what is there.

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

**An agent may not assess its own work.** Asking whether shipped work is the
direction the repository should go, of the agent that shipped it, returns yes —
the document and the code agree because the work made them agree. That is this
repository's recorded failure mode.

The constraint is self versus other, not human versus agent. A different agent
satisfies it; a human is not required. This is the rule refinement already
applies structurally to its SQE role, which never reads implementation code
because a role that has not seen the code cannot write a test that merely
restates it. The same isolation, applied to assessment.

**Assess dispatches a subagent, so independence is produced rather than
remembered.** A prohibition requires the agent to notice it is disqualified,
which is the same class of thing as remembering not to skip a gate. Dispatching
the assessment to a separate agent means the actor differs by construction, and
nobody has to check. Refinement already works this way — four roles, with the
SQE's independence coming from never having read the implementation.

**The subagent must be fresh, not a fork.** A fork inherits the orchestrator's
context, so it carries the same reasoning that produced the work and reaches the
same conclusions through a different process. Independence of actor without
independence of context buys nothing.

**And the rule stays checkable as a backstop.** A skill file is an instruction,
not a constraint — an agent can assess inline instead of dispatching, so the
dispatch is rung 3 with better ergonomics rather than rung 1. Worker identity
from 0002 supplies the rung 2: each issue carries `assigned` and each transition
an `actor`, so an assessment records its own actor, and one whose actor appears
among the actors on the work it assesses is self-assessment and invalid.

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

**The diff is the branch — `pu...HEAD`.** A milestone is a unit of delivery, a
unit of delivery is a pull request, and a pull request's diff is its branch
diff. It is what a reviewer looks at, and it includes every commit on the
branch whether or not anything recorded it.

git-zhi does carry a narrower signal: each issue's `sessions[]` records
`start_sha`, `end_sha` and a commit count. That is a range per execution
session, not a diff per delivery, and it attributes only what ran through
execute's dispatch. Collecting commits by `Implements:` trailer is worse still,
because it inherits the trailer's soft spot and would miss exactly the
untrailered commits most worth catching. The branch is chosen for what it
catches, not for want of an alternative.

**A milestone carries acceptance criteria, and review records them.** Criteria
exist today on issues, which are units of work, and nowhere on the milestone,
which is the unit of delivery; the architect's resolution command is pushed down
into the final issue's criteria for want of anywhere else to put it. The
decision's own acceptance criteria are the milestone's, and review verifies them
against the branch and records the result in the milestone body. Without this,
nothing checks a decision's criteria at the boundary where the decision is
delivered.

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

### The postmortem is an autonomy audit

The postmortem evaluates the milestone's development session for
autonomy-stealing friction and proposes how to remove it. Every point where the
loop stopped for a human is a defect to be engineered away, not a fact to be
recorded.

This is what makes the protocol self-improving toward its own goal. Without it
the pipeline runs the same way each milestone and friction persists because
nothing is charged with finding it.

`skills/postmortem/postmortem.md` asks four questions — what worked, what did
not, what puzzles us, what will we change — and none of them asks where a human
had to intervene. Its nearest items, worker struggles and session abandonment,
measure difficulty rather than interruption. A hard issue an agent finished
alone is a success by this standard; an easy one that required a human is not.

**The friction is asked about, not yet measured.** The audit adds one question
to the postmortem — where did a human have to act, and what would have let the
agent proceed — alongside the reopen cycles, stuck issues and readiness checks
that already stop and ask.

Worker identity looks like the right telemetry and is not, yet. Every
transition actor recorded in this repository reads `human:git-zhi` — forty of
them across two milestones that agents executed — because the prefix reflects
whether `ZHI_ACTOR` was exported, not who acted. `ZHI_ACTOR` is minted in
execute's dispatch, so refinement, chain-review and a backfilling review all
write transitions outside it. An audit keyed on that signal today would report
every agent action as a human interruption. The query becomes worth having once
identity discipline reaches every skill that writes a transition, which this
decision does not scope.

Not every interruption is a defect. Collaboration is the point, and a human
making a judgment the protocol reserves for them — the direction of the
repository, a decision to decline — is the system working. The audit
distinguishes friction from collaboration rather than treating every human
touch as waste.

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
- **`skills/refinement/architect-prompt.md`** and
  **`skills/refinement/refinement.md`**: both carry the false claims that a
  milestone cannot hold a body and that the CLI has no resolution setter, and
  both must lose them. On 0.6.0 `milestone add` itself accepts `--body` and
  `--resolution`, so the resolution command is stored at creation rather than
  routed through the final issue's acceptance criterion, and no second command
  is needed.
- **`skills/assess/assess.md`**: dispatch the assessment to a fresh subagent
  rather than performing it inline, so independence is structural; write the
  assessment to `docs/assessments/<milestone>.md` rather than presenting it
  only; define the cursory form and the three axes; refuse to assess work whose
  actors include the assessing actor.
- **`skills/review/review.md`** and **`commands/review.md`**: the new gate —
  two lenses over `pu...HEAD`, run to a bounded fixed point, verifying the
  milestone's acceptance criteria and recording the result.
- **`CONTRIBUTING.md`**: link `docs/assessments/`, or `git zhi docs check`
  reports everything in it unreachable.
- **`skills/chain-review/chain-review.md`**, **`skills/execute/execute.md`**:
  record their checklist entries, and backfill the upstream artifacts their
  position requires.
- **`skills/postmortem/postmortem.md`**: add the autonomy-friction audit —
  gather the `human:`-prefixed actors from the milestone's issue transitions
  alongside the existing telemetry, and ask of each interruption what would have
  let the agent proceed. Its four questions measure difficulty, not
  interruption, and nothing in it currently looks for a human in the loop.
- **`skills/preflight/preflight.md`**: the inference table becomes the
  seven-gate state machine rather than a patched row. Its "all issues closed"
  row currently reports the postmortem as the next gate, which would advise
  skipping review at exactly the point review should run. The table also gains
  the state "milestone exists, zero issues", which is refinement pending and is
  presently merged into the pre-chain row.
- **`skills/refinement/refinement.md`**: move the assessment from
  `docs/assessments/` into the milestone body when creating the milestone, and
  carry the decision's acceptance criteria onto the milestone.
- **`CLAUDE.md`** and **`README.md`**: the pipeline ordering and the skills
  table. `docs/architecture/plugin-structure.md` states the ordering too, but
  0004 proposes absorbing that file into `docs/ARCHITECTURE.md`; whichever
  lands second inherits the edit, so no criterion here names it.
- **`xt/run.sh`**: whatever of this is checkable from the repository.

## Acceptance Criteria

- [ ] this decision records what it amends (`grep -q '^amends: \[0001\]' docs/decisions/0003-acceptance-by-refinement.md`)
- [ ] the amended decision records it back (`grep -qE '^amended-by: \[.*0003' docs/decisions/0001-documentation-architecture.md`)
- [ ] 0001 is not marked superseded, because it is still in force (`grep -q '^state: accepted' docs/decisions/0001-documentation-architecture.md`)
- [ ] the assessment is written into the milestone body (`grep -q 'milestone add .*--body\|milestone edit .*--body' skills/refinement/architect-prompt.md`)
- [ ] the review gate exists as a skill (`test -f skills/review/review.md`)
- [ ] the review gate is user-invocable (`test -f commands/review.md`)
- [ ] the pipeline names seven gates where this decision owns the statement (`test $(grep -rl 'crochet:review' CLAUDE.md skills/preflight/preflight.md | wc -l) -eq 2`)
- [ ] the architect no longer denies that a milestone carries a body (`! grep -q 'no flag, stdin, or' skills/refinement/architect-prompt.md`)
- [ ] refinement no longer denies it either (`! grep -q 'no milestone-body/resolution setter' skills/refinement/refinement.md`)
- [ ] the architect stores the resolution command on the milestone (`grep -q 'milestone add .*--resolution\|milestone edit .*--resolution' skills/refinement/architect-prompt.md`)
- [ ] refinement backfills an assessment when none exists (`grep -q 'cursory assessment' skills/refinement/refinement.md`)
- [ ] assess defines the cursory form (`grep -q 'cursory' skills/assess/assess.md`)
- [ ] assess writes the assessment to the archive (`grep -q 'docs/assessments' skills/assess/assess.md`)
- [ ] assess refuses to assess its own actor's work (`grep -q 'own work' skills/assess/assess.md`)
- [ ] assess dispatches rather than assessing inline (`grep -q 'subagent' skills/assess/assess.md`)
- [ ] the archive is reachable, so docs check can see it (`grep -q 'docs/assessments' CONTRIBUTING.md`)
- [ ] review reads the branch diff (`grep -q 'pu\.\.\.HEAD' skills/review/review.md`)
- [ ] review verifies the milestone's acceptance criteria (`grep -q 'acceptance criteria' skills/review/review.md`)
- [ ] review bounds its fixed-point loop (`grep -q 'fixed point' skills/review/review.md`)
- [ ] the postmortem audits autonomy-stealing friction (`grep -q 'autonomy' skills/postmortem/postmortem.md`)
- [ ] the postmortem locates where a human entered the loop (`grep -q 'human:' skills/postmortem/postmortem.md`)
- [ ] nothing in the repository is unreachable or misnumbered (`git zhi docs check`)

## Open Questions

- Whether `state:` should shrink further. `proposed`, `accepted` and
  `superseded` all now have mechanical traces — a file, the commit that writes
  `state: accepted`, a superseding document — which leaves only `declined` strictly needing declaration. Against
  that is the read-alone principle: a fully derived status shows nothing about
  where a decision stands to someone reading it on a web view with no shell.
  Recorded as open; not proposed here.
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
