---
title: Participant continuity across discernment rounds
state: proposed
author: Chris Prather
date: 2026-09-19
supersedes: []
superseded-by: []
amends: [0003]
---

# 0006: Participant continuity across discernment rounds

**This entry is a placeholder. Its Problem Statement is written; its Proposal
awaits the protocol 0003 itself specifies.** The evidence was gathered while
walking `crochet:discernment` across three rounds, and evidence that lives only
in a conversation is evidence that has to be found again.

## Problem Statement

0003 settles who sits in a discernment session, and says participants persist:

> They persist across rounds and are resumed by name, because only the
> participant that raised a finding may release it; a round that replaced its
> participants would have nobody left to release the last round's findings.

`skills/discernment/discernment.md` implements that rule, and the same reasoning
is why `crochet:execute` resumes a session between units of work rather than
starting one.

**The walkthrough that exercised the rule produced evidence against it.** Four
observations, all recorded in `docs/assessments/walkthrough-discernment-rounds.md`,
and every one of them is a property of resumption rather than of the participant:

| | what a resumed participant does |
|---|---|
| verification, not derivation | "They and their 'addressed when' bars were already in my context, and I used them as a checklist." |
| bias toward its own bars | "a bar I authored is one I am inclined to find met" |
| the discharge reflex, growing per round | "the reflex to pattern-match a paragraph against a stored finding and discharge it is measurably stronger than it was in round two" |
| narrowing, so released findings stop being defended | "If this revision had quietly regressed AC1, I would have caught it only by luck." |

A participant dispatched fresh has none of these, because it has no stored
finding to match against and no bar of its own to want cleared. The skill guards
all four with technique — read the diff last, carry definitions not conclusions,
bracket the exit code, attack what you already released — but a guard written
into a brief is weaker than a property of the dispatch.

**What appears to block the change is the release protocol, and it may not.**
Re-derivation is itself a release test: a finding that recurs is still live, and
one that does not recur was resolved by the subject rather than by its raiser's
opinion. That would remove a mechanism rather than add one. What is genuinely
lost is continuity of reasoning — a fresh participant cannot say "this is the
third round I have raised this", and carries no standing-aside forward. Whether
the minute carries enough of that is the open question.

## Proposal

Awaiting the protocol. This is an amendment to an accepted decision, so 0003's
own gates apply to it: an assessment reaching a fixed point, with at least one
participant who is neither the author nor a role that holds no view.

Note the recursion before starting. **Under the rule as written, that assessment
resumes its participants by name; under the rule proposed, it dispatches fresh
ones each round.** Whichever way it runs, the session is evidence about its own
subject, and the minute should say which rule it ran under.

## Scope of Change

Unknown until the Proposal exists. The rule appears in at least
`docs/decisions/0003-acceptance-by-refinement.md`, `skills/discernment/discernment.md`,
and `skills/execute/execute.md`'s session handling.
