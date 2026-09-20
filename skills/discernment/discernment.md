---
name: discernment
description: Internal convergence mechanism — dispatches independent participants over a subject, collects findings and recommendations, iterates to a fixed point, and drafts the minute
---

<!-- ABOUTME: Internal skill invoked by crochet:assess, crochet:chain-review and crochet:review. -->
<!-- ABOUTME: Runs rounds of independent participants over a subject until nothing new is raised. -->

## Prerequisites

Before proceeding, verify that `git-zhi` is available by running `which git-zhi`.
If not found, run `crochet:install` to set it up.

# crochet:discernment

**Internal skill.** Called by `crochet:assess`, `crochet:chain-review` and
`crochet:review`. It has no command stub and is not invoked directly by users.

Three gates run the same loop: dispatch independent participants over a subject,
collect findings and a recommendation from each, iterate until a round raises
nothing new, and draft the outcome. This is that loop, built once and
parameterised, rather than described three times and drifting.

The policy it implements — who may sit, what blocks, who releases — is settled
in `docs/decisions/0003-acceptance-by-refinement.md`. This skill owns the
procedure.

## Inputs

| | |
|---|---|
| **subject** | what is being judged — a decision, a chain, a diff |
| **participants** | the lenses or roles to dispatch |
| **prior rounds** | the findings already raised, and who raised them |

`crochet:assess` passes a decision. `crochet:chain-review` passes a chain with
its coverage and plan-quality lenses. `crochet:review` passes `pu...HEAD` with
its code-review lenses.

## Who sits

**Participants are dispatched to fresh subagents, never forks.** A fork inherits
the orchestrator's context, so it carries the reasoning that produced the work
and reaches the same conclusions by a different route. Independence of actor
without independence of context buys nothing.

**Participants persist across rounds and are resumed by name.** Only the
participant that raised a finding may release it, so a round that replaced its
participants would have nobody left to release the previous round's findings —
the fixed point becomes unreachable by construction. New participants are added,
never substituted.

**The author may sit and may not be the only voice.** At least one participant
is neither the author nor a role that holds no view: a session of the author
plus a note-taker satisfies a looser rule while containing no assessment at all.

Nothing tracks who failed to participate. Participants are dispatched, so one
that does not report is a failed dispatch rather than a silent abstention.

## What a round produces

Each participant ends with a **recommendation — reject, modify or accept** — and
the findings behind it. A recommendation is a positive statement, which is
better evidence than having run out of objections.

A participant may **stand aside** instead of blocking: the concern is recorded
with its grounds and the decision proceeds. **One held objection means not yet.**
Nothing is counted, and a majority is not an outcome.

## The dispatch brief

**Name the author's likely blind spot.** A participant told only what to review
finds what is wrong; a participant told where the author is likely blind finds
what the author cannot see. Say who wrote the subject and what failure to look
for — that one sentence is what makes a first-round finding available in a first
round.

**Say what changed since the participant last looked**, as a diff rather than a
description. A summary written from memory reports edits that did not land.

**Tell participants to re-derive from the live subject, never from the message
describing it.** This is the rule that still works when the other two fail,
because it asks nothing of the party with the most context and the least reason
to doubt themselves. A participant names the revision it read.

**Tell them a round airs views rather than deciding.** The first round is a
threshing session: views put openly, including views that do not reconcile, with
no pressure to converge.

## The loop

1. Dispatch the participants with the brief above.
2. Collect findings and recommendations.
3. The author responds; **only the raiser releases its own finding.** Asking
   whether a resolution is sufficient is a view on the subject in everything but
   name, so the drafter asks and the participant answers.
4. Repeat from 1 with the participants resumed, until a round raises nothing new
   and nothing is outstanding.

**The subject holds still for the duration of a round.** Changing it under a
participant invalidates the answer being asked for, and turns findings stale
rather than wrong.

**The loop is bounded.** Take the shape `crochet:execute` already uses — three
iterations, then report non-convergence rather than spinning. A loop that will
not converge is itself a finding about the subject.

## The minute

The drafter records, for the round:

- each participant, what it raised, and what it says remains;
- **block or standing-aside as the participant declared it**, never inferred,
  with the grounds of a standing-aside written down;
- the outcome: unity, another round owed, a decline, or irreconcilable views.

**The drafter does not decide the outcome — the participants confirm the
minute.** It holds no opinion on the subject, raises no finding, and never
becomes another participant.

Where views did not reconcile, the minute records them rather than forcing
agreement or leaving a silent deadlock. That is a legitimate outcome: the
subject does not proceed and the reasons are on the record instead of in
someone's memory.

## Constraints

- **Judge nothing as the drafter.** The moment the drafting role forms a view on
  the subject it has become a participant, and the count of independent
  judgments is wrong.
- **Never infer a release.** A participant that has not answered has not
  released.
- **Recommendations are not tallied.** Report that objections are outstanding or
  that none are; never that most participants were content.
- **A round is a round.** Collect every participant before drafting; a minute
  written from the first reply is a summary, not a census.
