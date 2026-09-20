---
name: discernment
description: Internal convergence mechanism — dispatches independent participants over a subject, collects findings and recommendations, iterates to a fixed point, and drafts the minute
---

<!-- ABOUTME: Internal skill invoked by crochet:assess, crochet:chain-review and crochet:review. -->
<!-- ABOUTME: Runs rounds of independent participants over a subject until nothing new is raised. -->

## Prerequisites

None. This skill dispatches agents and collects what they return; it invokes no
`git zhi` command, so it has no binary to check for. Its callers do, and check
it themselves.

# crochet:discernment

**Internal skill.** Called by `crochet:assess`, `crochet:chain-review` and
`crochet:review`. It has no command stub and is not invoked directly by users.

Each section below says whose job it is. Most of this file is caller-facing;
the participant-facing parts are "What a round produces" and the release rule in
step 3 of the loop. If you were dispatched into a session, read those two and
skim the rest.

Three gates run the same loop: dispatch independent participants over a subject,
collect findings and a recommendation from each, iterate until a round raises
nothing new, and draft the outcome. This is that loop, built once and
parameterised, rather than described three times and drifting.

The policy it implements — who may sit, what blocks, who releases — is settled
in `docs/decisions/0003-acceptance-by-refinement.md`. This skill owns the
procedure.

## Inputs

*Caller-facing.*

| | |
|---|---|
| **subject** | what is being judged — a decision, a chain, a diff |
| **participants** | the lenses or roles to dispatch |
| **prior rounds** | the findings already raised, and who raised them |
| **where the minute goes** | the caller's record — a path, or a milestone body |

**The caller supplies the destination, because each has a different one.**
`crochet:assess` writes to `docs/assessments/<milestone>.md`;
`crochet:chain-review` and `crochet:review` write a checklist entry into the
milestone body. A gate that leaves no trace cannot be a precondition for
anything, so a session with nowhere to put its minute has not finished.

**The caller also says who drafts.** The invoking agent is frequently the
author — for `crochet:assess` it is usually the author's own session — and a
drafter that holds a view has become a participant, which makes the count of
independent judgments wrong. Either dispatch the drafter as its own subagent, or
name an existing participant as drafter and accept that it stops being counted
as independent. Do not leave it implicit.

`crochet:assess` passes a decision. `crochet:chain-review` passes a chain with
its coverage and plan-quality lenses. `crochet:review` passes `pu...HEAD` with
its code-review lenses.

## Who sits

*Caller-facing — this is dispatch policy, not something a participant acts on.*

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

*Participant-facing. If you were dispatched into a session, this section and the release rule in The loop are what is being asked of you; the rest describes the caller's job.*

Each participant ends with a **recommendation — reject, modify or accept** — and
the findings behind it. A recommendation is a positive statement, which is
better evidence than having run out of objections.

A participant may **stand aside** instead of blocking: the concern is recorded
with its grounds and the decision proceeds. **One held objection means not yet.**
Nothing is counted, and a majority is not an outcome.

## The dispatch brief

*Caller-facing — the caller writes it, a participant receives it.*

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

*Caller-facing, except step 3's release rule, which is the participant's.*

1. Dispatch the participants with the brief above.
2. Collect findings and recommendations.
3. The author responds; **only the raiser releases its own finding.** Asking
   whether a resolution is sufficient is a view on the subject in everything but
   name, so the drafter asks and the participant answers.

   **A resumed participant verifies; it does not re-derive.** That is what
   actually happens, observed rather than assumed: it re-reads the file, re-runs
   the commands, and checks them against the bars it set last round — but the
   findings themselves are already in its context and are used as a checklist.
   Three consequences, and a participant should be told all three:

   - **You are biased toward finding your own bar met.** A bar you wrote is one
     you want to have been cleared. Say so when you release against one.
   - **Hunt for what the change broke, not only for what it fixed.** Confirming
     the fix is pattern-matching; a fixture aimed at the revision's *new* failure
     modes is the thing that distinguishes verification from assent.
   - **Re-read what did not change, on its own terms.** A paragraph that is
     byte-identical in the diff looks like nothing to re-read, which is exactly
     where coasting happens — and a finding released because an *earlier* finding
     was fixed is the most common way a live objection disappears unexamined.

   Four techniques, all of which caught something in the session that produced
   this section:

   - **Read the diff last.** A diff tells you where to look, so reading it first
     lets the author choose what you examine. Read the subject, run the checks,
     then read the diff.
   - **Carry definitions forward, never conclusions.** Your notes are for what
     you found and the bar you set. Every claim about the current revision comes
     from this round.
   - **A result you did not bracket is one you have not earned**, and this
     holds in both directions. A check failing today may be failing for the
     reason you think, or because it is malformed. A check passing today may be
     passing for the reason you think, or because what it examined was not
     there. Construct the case that makes it pass and the case that makes it
     fail; without both, a red is just a red and a green is worth less.

     **The input that fools you is the one nobody enumerated.** Three observed
     in a single day, none of them the check's own logic: `grep` case
     sensitivity turned a criterion red over working code; a stale binary on
     `$PATH` kept a test suite green for years over a rule it could not
     enforce; and a `2>&1` in the observer's own command turned clean output
     into a defect report against the tool that produced it. Before trusting a
     result, say what besides the subject could have produced it — the
     redirection, the environment, the version, the empty set.
   - **What landed near your bar is not your bar.** A change sitting where you
     asked for something is not the thing you asked for. Score it against what
     you wrote, then say separately whether what arrived is better.
   - **Before looking at whether a fix landed, say what it would have to *also*
     change.** This is the guard for the one thing that measurably worsens with
     each round: not effort, but the reflex to match a paragraph against a stored
     finding and discharge it. A participant three rounds in reported that
     reflex as "measurably stronger than it was in round two" while doing *more*
     work than the round before. Predicting the blast radius first is what stops
     a correct-looking paragraph from closing a finding whose other half is
     untouched.
   - **Attack the findings you already released.** The other degradation is
     narrowing: a released finding stops being defended, so the round's attention
     scopes to the delta plus what the delta broke. A participant put it exactly —
     "if this revision had quietly regressed [the fixed criterion], I would have
     caught it only by luck." Releasing a finding retires the objection, not the
     fixture. Re-run what proved the fix, every round.
4. Repeat from 1 with the participants resumed, until a round raises nothing new
   and nothing is outstanding.

**The subject holds still for the duration of a round.** Changing it under a
participant invalidates the answer being asked for, and turns findings stale
rather than wrong.

**The loop is bounded, and the bound is not three.** The two sessions on record
that produced this skill took five rounds and four: the assessment of 0003, and
the chain-review of the milestone implementing it. A bound of three would have
declared both non-convergent and 0003 would never have been accepted.

So: **bound at eight rounds**, and report non-convergence rather than spinning.
A loop that will not converge is itself a finding about the subject, and the
bound exists to make that finding arrive rather than to hurry agreement.

Do not copy `crochet:execute`'s number. It bounds two different things — ten
passes for its inner convergence, three reopen cycles for its outer gate — and
neither is this loop. A round here is a full dispatch of every participant,
which is far more expensive than a reopen and far cheaper than being wrong.

## The minute

*Drafter-facing.*

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

*Caller- and drafter-facing.*

- **Judge nothing as the drafter.** The moment the drafting role forms a view on
  the subject it has become a participant, and the count of independent
  judgments is wrong.
- **Never infer a release.** A participant that has not answered has not
  released.
- **Recommendations are not tallied.** Report that objections are outstanding or
  that none are; never that most participants were content.
- **A round is a round.** Collect every participant before drafting; a minute
  written from the first reply is a summary, not a census.
