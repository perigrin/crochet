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
sixteen issues exist. The decision to build was taken before any of that,
when an independent assessment found the document sound. Placing acceptance at
execute puts it after the work it authorises.

**And the second line concedes a recordless event.** 0001 argues throughout
that a claim with nothing connecting it to the world is the failure mode; it
then records a transition it admits leaves no trace. A go-ahead is spoken and
gone.

**Acceptance is the outcome of the meeting the assessment feeds, and the durable
record is the commit writing `state: accepted` into the document.** Not the
chain: 0001 says the chain "is ephemeral and nothing cites it", and a trace that
evaporates when the milestone is cleaned up is not a trace. The chain is the
occasion for that write, not the evidence of it, and the gate that makes it is
recording a judgment rather than making one.

The ordering alone does not settle where acceptance sits — assess is step two,
refinement step three, chain-review step four, and a reader can infer any of
them. That is the argument for stating it outright.

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
prose, believed or not. Prose does not bind the thing reading it — agents
holding this document in context skip gates it declares, and the skips are
caught by people rather than by checks.

**A skip is visible exactly when the gate wrote something down.** Refinement
writes `state: accepted`, so `xt/run.sh` can report commits implementing a
decision that was never accepted. Assess and chain-review write nothing, so
nothing can report their absence. The difference is not the agent's diligence.

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
it and every such gate is a stop in an autonomous run. An assessment requires
another actor rather than a human one, because the property that matters is
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

The one thing an agent cannot deliver alone is an assessment of its own work.
That is not a refusal but a handoff: the scene continues, and another player has
to be in it.

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

| Gate | Kind | Mandatory | What must exist | Record |
|---|---|---|---|---|
| brainstorming | method | no | the spec | the spec document |
| assess | judgment | **yes** | the spec aligns to the codebase, the architecture, and the intended direction of the repository — and the meeting it feeds produces the acceptance | `docs/assessments/<milestone>.md` |
| refinement | method | no | the chain | `state: accepted` recorded in the document; the issues |
| chain-review | judgment | when a chain exists | the units of work are ready to be iterated on | a checklist entry in the milestone body |
| execute | method | no | the code | commits carrying `Implements: NNNN` |
| review | judgment | **yes** | the delivery matches the decision and the code is sound | a checklist entry in the milestone body |
| postmortem | judgment | **yes** | autonomy-stealing friction is identified, with proposals for removing it | `docs/postmortems/<milestone>.md`, attached with `--postmortem` |

A gate that leaves no trace cannot be a precondition for anything, because
nothing can tell whether it happened. That is why every row has a record.

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

### Assess is a threshing session

0001 leaves who accepts open — "Who accepts a proposal. Currently perigrin" —
and this document cannot, because the mechanism would otherwise decide the
policy by accident.

Assessment airs views; it does not decide. That is the Quaker form it takes:

> This term currently denotes a meeting at which a variety of different, and
> sometimes controversial, opinions can be openly, and sometimes forcefully,
> expressed, often in order to defuse a situation before a later meeting for
> worship for business.
>
> — Britain Yearly Meeting, *Quaker faith & practice*, 12.26, on threshing
> meetings

So a threshing session is free to surface irreconcilable views without pressure
to converge, which is what makes it useful. The decision happens afterwards.

**The session may include the agent that wrote the document, but must not be
exclusively it.** The author has views about their own proposal worth airing,
and excluding them loses what they know. What cannot happen is the author being
the only voice.

So the composition rule, which replaces any head-count: **at least one
participant who is neither the author nor the clerk.** The clerk cannot supply
that independence, because it holds no opinion by construction — a session of
author plus clerk would satisfy a looser rule while containing no assessment at
all. Independence is a property of who is present, not of how many.

**Its output is a minute of the session carrying a recommendation** from each
participant — reject, modify, or accept — with the findings behind it. A
recommendation is a positive statement, which is stronger evidence than running
out of objections.

### The meeting for business decides

The clerk convenes it on the threshing minute, and it produces the acceptance.

- **Nothing is counted.** "Our decisions do not rely on majority rule, but
  rather on a unity found through calm attention to the Light Within."
- **Unity is not unanimity.** "Sense of the meeting is the understanding of
  where the gathered body is led and does not mean that every individual present
  is completely satisfied or in total agreement."
- **A participant may stand aside** — record a concern while agreeing the
  decision should proceed — and asks "that their names and the grounds of their
  objections be recorded in the minutes as the decision goes forward". A known
  cost on the record, not an open objection.
- **A participant may stand in the way**, and the clerk may then "indicate that
  the sense of the meeting is not clear and that no decision can be made nor
  action taken until unity in the Spirit is reached". A held objection means not
  yet. Weighing how serious a concern is would need a judgment the clerk is
  forbidden to have, so an unreleased objection simply blocks.
- **Where perceptions do not reconcile the outcome is a minute of exercise** —
  a record that "states the various perceptions in the meeting on a given
  matter". A legitimate outcome: the decision does not proceed and the reasons
  are on the record rather than in someone's memory.
- **No action is taken in anticipation of approval.** "No action is taken on an
  issue on the meeting's behalf in anticipation of the minute's approval." This
  repository's rule against implementing an unaccepted decision, stated as
  practice rather than as a check.

One rule is not borrowed. **Silence is assent only after consideration** — an
agent that was not asked, or was working on something else, has not agreed,
which is why the census records who did not look.

### The clerk

Someone has to say the meeting reached unity. Without the role the author
resolves findings raised against their own document and then declares them
resolved — self-judgment at the point that decides acceptance.

So assess dispatches a **clerk** alongside its participants, the way refinement
dispatches an architect, a decomposer, an SQE and a technical writer.

**The clerk holds no opinion of its own.** It forms no view on whether the
document is right and raises no finding. Its whole job is to establish when the
meeting has produced an outcome the decision can move forward on.

**It does not decide whether an objection was answered — the participant who
raised it does.** The clerk asks; the participant says whether it still holds.
Judging a resolution sufficient would be a view on the document in everything
but name, and a concern is released by the one holding it rather than resolved
at them.

What the clerk produces: the census of who looked, what each raised and what each
says remains; block or standing-aside as the participant declares it, never
inferred; and the outcome as a draft — unity, another round owed, a decline, or
a minute of exercise.

**The draft is not final; the meeting confirms it.**

> The meeting places upon its clerk a responsibility for spiritual discernment
> so that he or she may watch the growth of the meeting toward unity … the final
> decision about whether the minute represents the sense of the meeting is the
> responsibility of the meeting itself, not of the clerk.
>
> — Britain Yearly Meeting, *Quaker faith & practice*, 3.07

The clerk cannot declare unity at a meeting that does not recognise itself in
the minute. The authorship bar does not bind the clerk, since a role with no
view cannot self-judge one, though a clerk who is not the author is preferable.

**What is borrowed is the governance mechanism, not the faith.** PYM
distinguishes the two explicitly, and the distinction is against us: "Consensus
is a widely used and valuable secular process characterized by a search for
general agreement largely through rational discussion and compromise. A sense of
the meeting is the outcome of a spiritual process." What this protocol runs is
the former. The forms are taken because they are well-designed for holding
disagreement without voting, not because an agent participates in what gives
them their meaning.

**Human contributors may block, and may also override after the fact.** The
first is ordinary — a person holding a finding stops the meeting the same way an
agent does. The second is where this departs from the analogy, since a Quaker
meeting has no authority above it and this does. A human may reopen an accepted
decision, needing no justification and no turn to arrive. That is where the
human sits: not as a gate every acceptance waits on, but as a participant who
can also reverse. An override that declines is written down, because `declined`
is already the one state with no other trace.

**Policy decisions are recorded in a decision document**, this one included.
That is also the entry condition for the pipeline: a policy question is what
makes a decision document owed.

**Whichever gate observes the outcome records it.** Writing `state: accepted`
is the durable trace of a judgment already reached, which is why it needs no
confirmation. Refinement does it in nominal position; review does it when review
is the gate that backfilled the assessment. Tying the write to refinement alone
would leave a decision `proposed` forever on the finished-pull-request path,
where no chain is built and refinement never runs — and `xt/run.sh` would then
report its `Implements:` commits as a skipped gate, firing on a path this
document calls legal.

### Each gate backfills the artifacts before it

Backfill is transitive, not pairwise: each gate confirms that a cursory artifact
exists for every mandatory gate above it in the table, and creates what is
missing.

The consequence is that a late gate backstops every earlier one. Running review
establishes that an assessment exists, and by extension that a spec exists for
the code being reviewed. Review is the last gate that can repair a missing
upstream artifact while the work is still open, which is why it precedes the
postmortem.

### The records

**Assess writes the assessment to `docs/assessments/`; refinement copies it into
the milestone body.** Copies, not moves. The archive file is the durable record
and stays — it holds the census of who looked, what each raised and what each
released, which is the evidence that acceptance happened at all. The milestone
body is a convenience for the gates that read the chain, and the document says
elsewhere that a milestone body exists in one clone; the record of a decision
cannot live only there. Two copies is the accepted cost, and unlike the case
0001 rejects for `Implements:`, they are written together by one actor rather
than declared twice. This mirrors the postmortem exactly — written to the
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

**Assessors persist across rounds and are resumed by name.** Only the agent that
raised a finding may release it, so a round that replaces its assessors cannot
reach a fixed point — the previous round's findings would have nobody left to
release them, and the clerk may not infer a release. Each round therefore
resumes the assessors already sitting and may add new ones; adding is how the
meeting grows, substituting is how it forgets.

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

This amends 0001 rather than superseding it: one row of one table is wrong and
the rest is in force, half-built, with commits citing it now. Supersession would
tell a reader none of it holds.

`amends`/`amended-by` are written in one commit and checked by the same symmetry
rule as `supersedes`/`superseded-by`, and written only when the relation exists
rather than empty. The relation is already in use — 0001 carries
`amended-by: [0003, 0004]` and `xt/run.sh` enforces the pairing.


## Scope of Change

- **`skills/assess/assess.md`**: dispatch assessors to fresh subagents rather
  than assessing inline, so independence is structural; run to a fixed point,
  since the fixed point is the acceptance and a single pass is not; write the
  assessment to `docs/assessments/<milestone>.md` rather than presenting it
  only; define the cursory form and the three axes; refuse to assess work whose
  actors include the assessing actor.
- **`skills/assess/clerk-prompt.md`**: the clerk role — takes the census of who
  looked and what each says remains, records block or standing-aside as the
  assessor declares it, names the outcome, and holds no opinion on the document.
  Sits beside `assess.md` the way the four role prompts sit beside
  `refinement.md`.
- **`skills/refinement/refinement.md`**: record `state: accepted` on a decision
  whose assessment has converged, as a write rather than a decision. Backfill a
  cursory assessment when none exists, move the assessment into the milestone
  body, and carry the decision's acceptance criteria onto the milestone.
- **`skills/refinement/architect-prompt.md`** and
  **`skills/refinement/refinement.md`**: both carry the false claims that a
  milestone cannot hold a body and that the CLI has no resolution setter. On
  0.6.0 `milestone add` accepts `--body` and `--resolution`, so the resolution
  command is stored at creation rather than routed through the final issue's
  acceptance criterion.
- **`skills/review/review.md`** and **`commands/review.md`**: the new gate --
  two lenses over `pu...HEAD`, run to a bounded fixed point, verifying the
  milestone's acceptance criteria and recording the result.
- **`skills/chain-review/chain-review.md`** and **`skills/execute/execute.md`**:
  record their checklist entries, and backfill the upstream artifacts their
  position requires.
- **`skills/postmortem/postmortem.md`**: add the autonomy-friction question --
  where did a human have to act, and what would have let the agent proceed --
  alongside the four it already asks, which measure difficulty rather than
  interruption. Not the actor query: that signal does not work yet.
- **`skills/preflight/preflight.md`**: the inference table becomes the
  seven-gate state machine. Its "all issues closed" row reports the postmortem
  as the next gate, which would advise skipping review at the point review
  should run, and it gains the state "milestone exists, zero issues", presently
  merged into the pre-chain row.
- **`CONTRIBUTING.md`**: link `docs/assessments/`, or the documentation
  structure check reports everything in it unreachable.
- **`CLAUDE.md`** and **`README.md`**: the pipeline ordering and the skills
  table. `docs/architecture/plugin-structure.md` states the ordering too, but
  0004 proposes absorbing it into `docs/ARCHITECTURE.md`; whichever lands second
  inherits the edit, so no criterion here names it.
- **`docs/decisions/0001-documentation-architecture.md`**: its open question
  "Who accepts a proposal" is answered here. Its body is not edited; the
  `amended-by` link it already carries takes a reader across.
- **`xt/run.sh`**: refuse a decision marked `accepted` while anything in its
  `amends:` is still `proposed`. That is the one rule here the repository can
  check unaided, and it is the one this document came close to breaking.

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
- [ ] assess runs to a fixed point, since that is the acceptance (`grep -q 'fixed point' skills/assess/assess.md`)
- [ ] the clerk role exists (`test -f skills/assess/clerk-prompt.md`)
- [ ] the clerk separates a block from a standing-aside (`grep -q 'stand' skills/assess/clerk-prompt.md`)
- [ ] the archive is reachable, so docs check can see it (`grep -q 'docs/assessments' CONTRIBUTING.md`)
- [ ] review reads the branch diff (`grep -q 'pu\.\.\.HEAD' skills/review/review.md`)
- [ ] review verifies the milestone's acceptance criteria (`grep -q 'acceptance criteria' skills/review/review.md`)
- [ ] review bounds its fixed-point loop (`grep -q 'fixed point' skills/review/review.md`)
- [ ] the postmortem audits autonomy-stealing friction (`grep -q 'autonomy' skills/postmortem/postmortem.md`)
- [ ] the postmortem asks what would have let the agent proceed (`grep -q 'let the agent proceed' skills/postmortem/postmortem.md`)
- [ ] nothing in the repository is unreachable or misnumbered (`git zhi docs check`)

## Open Questions

- Whether `state:` should shrink further. `proposed`, `accepted` and
  `superseded` all now have mechanical traces — a file, the commit that writes
  `state: accepted`, a superseding document — which leaves only `declined` strictly needing declaration. Against
  that is the read-alone principle: a fully derived status shows nothing about
  where a decision stands to someone reading it on a web view with no shell.
  Recorded as open; not proposed here.
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
- New England Yearly Meeting, *Faith and Practice*, "Corporate Discernment in
  Meetings for Business" — the source of unity-without-unanimity, standing aside
  against standing in the way, the rule that no individual can prevent the
  meeting acting, and the minute of exercise.
  <https://neym.org/faith-and-practice/decision-making>
- Britain Yearly Meeting, *Quaker faith & practice*, 3.07 "The sense of the
  meeting" and 3.12 "Clerkship" — the clerk's role in discernment, and the rule
  that the outcome belongs to the meeting rather than to the clerk.
  <https://qfp.quaker.org.uk/passage/3-07/> and
  <https://qfp.quaker.org.uk/passage/3-12/>

Both are unprogrammed bodies. Passage numbering and wording vary between yearly
meetings, so each quotation names its source rather than being offered as
Quaker practice in general.
