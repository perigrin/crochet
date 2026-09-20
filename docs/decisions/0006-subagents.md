---
title: Subagent coordination
state: proposed
author: Chris Prather
date: 2026-09-19
supersedes: []
superseded-by: []
amends: [0003]
---

# 0006: Subagent coordination

**This entry is a placeholder.** One question has enough evidence to state
fully; the rest of the area is named and left open. Like 0003, this is expected
to expand past the scope it opens with — the first draft covering subagent
coordination as a whole awaits brainstorming.

What is recorded now is recorded because the evidence was gathered in a session,
and evidence that lives only in a conversation is evidence that has to be found
again.

## Problem Statement

Crochet dispatches subagents in five skills and has no single account of how it
does so. The rules exist, but each was settled where it was first needed:
`crochet:discernment` owns who may sit and how rounds resume, `crochet:review`
owns the difference between delegating and dispatching, `crochet:execute` owns
the review-tier dispatch and the orchestration session. A rule that is right in
one skill and absent from the other four is a convention, not a decision.

### Resumption, which has the evidence

Crochet reuses agents in two places, for the same stated reason: continuity is
cheaper than re-establishing context.

**0003 says discernment participants persist:**

> They persist across rounds and are resumed by name, because only the
> participant that raised a finding may release it; a round that replaced its
> participants would have nobody left to release the last round's findings.

`skills/discernment/discernment.md` implements that rule. **`crochet:execute`
does the same thing at a different scale** — an orchestration session carried
across units of delivery, compacted rather than replaced, so that what was
learned in issue three is available in issue eleven.

**The walkthrough that exercised the discernment rule produced evidence against
it.** Four observations, all recorded in
`docs/assessments/walkthrough-discernment-rounds.md`, and every one of them is a
property of resumption rather than of the participant:

| | what a resumed participant does |
|---|---|
| verification, not derivation | "They and their 'addressed when' bars were already in my context, and I used them as a checklist." |
| bias toward its own bars | "a bar I authored is one I am inclined to find met" |
| the discharge reflex, growing per round | "the reflex to pattern-match a paragraph against a stored finding and discharge it is measurably stronger than it was in round two" |
| narrowing, so released findings stop being defended | "If this revision had quietly regressed AC1, I would have caught it only by luck." |

An agent dispatched fresh has none of these, because it has no stored finding to
match against and no bar of its own to want cleared. `crochet:discernment` guards
all four with technique — read the diff last, carry definitions not conclusions,
bracket the exit code, attack what you already released — but a guard written
into a brief is weaker than a property of the dispatch.

**The same finding arrived independently, from outside this repository.**
`paad:agentic-architecture` and `paad:agentic-review` both refuse a session that
already has substantive history; `skills/execute/execute.md` records the refusal
and works around it by applying their taxonomies inline. That workaround is the
cost of reuse being paid without being named.

**What appears to block the change is the release protocol, and it may not.**
Re-derivation is itself a release test: a finding that recurs is still live, and
one that does not recur was resolved by the subject rather than by its raiser's
opinion. That would remove a mechanism rather than add one. What is genuinely
lost is continuity of reasoning — a fresh participant cannot say "this is the
third round I have raised this", and carries no standing-aside forward. Whether
the minute carries enough of that is the open question, and the equivalent
question for execute is whether the chain carries enough of it between issues.

### The rest of the area

Each of these has an observation behind it and no settled rule. They are listed
so the expansion starts from evidence rather than from a blank page.

**How many is too many, and the tension with respawning.** A session running
eleven concurrent subagents was flagged as too many by the human watching it, and
one of the eleven was a genuine overspawn — a review that should have continued
an existing participant rather than starting beside it. **This pulls against
resumption in the opposite direction from everything above:** respawning rather
than resuming raises the spawn count by construction, so a rule that favours
fresh agents needs a companion rule about how many are live at once, or it
optimises one failure into the other.

**Fresh subagents, never forks.** 0003 settles this for discernment: a fork
inherits the orchestrator's context and so reaches the same conclusions by
another route, which buys independence of actor without independence of context.
Nothing states it for the other four dispatch sites.

**Delegating is not dispatching.** `skills/review/review.md` draws the line —
invoking a lens through the Skill tool loads its instructions into the caller's
context, so the lens becomes the caller wearing its taxonomy, where dispatching
sends the subject to an agent that has not read the caller's reasoning. The
distinction is general and is written down in one skill.

**A silent agent is a failed dispatch, not an abstention.**
`skills/discernment/discernment.md` says so for participants. It is a claim about
dispatch mechanics rather than about discernment.

**The relay is a failure mode of its own.** Several reports in the discernment
walkthrough arrived truncated, twice at the exact point a finding was released;
the participant confirmed its text had left complete and declined to invent a
continuation. Nothing in any skill tells a caller how to recognise a truncated
report or what to do about one, and asking for a remainder that does not exist
costs a round.

## Proposal

Awaiting brainstorming. This is also an amendment to an accepted decision, so
0003's own gates apply: an assessment reaching a fixed point, with at least one
participant who is neither the author nor a role that holds no view.

Note the recursion before starting. **Under the rule as written, that assessment
resumes its participants by name; under the rule proposed, it dispatches fresh
ones each round.** Whichever way it runs, the session is evidence about its own
subject, and the minute should say which rule it ran under.

## Scope of Change

Unknown until the Proposal exists. The dispatch sites are
`skills/discernment/discernment.md`, `skills/review/review.md`,
`skills/chain-review/chain-review.md`, `skills/execute/execute.md` and
`skills/refinement/refinement.md`; the rules being amended are in
`docs/decisions/0003-acceptance-by-refinement.md`.
