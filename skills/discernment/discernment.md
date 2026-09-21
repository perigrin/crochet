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

**A dispatch that does not return is the caller's problem to detect, and this
skill previously said so and then gave no way to do it.** "Collect every
participant before drafting" and "never infer a release" are both correct and
both unbounded: with a bound counted in rounds rather than time, a caller
waiting on a participant that will never report waits forever.

So: **if a participant does not return, say so and proceed without it.** Record
in the minute which participants were dispatched, which reported, and that the
round ran short. A round with a missing participant is a weaker round and the
minute says which one was missing — that is a finding about the session, not a
reason to abandon it.

**Reap it in the same breath.** A dispatch that has failed and not been stopped
is indistinguishable, in the caller's task list, from one still working. One sat
for thirty-nine minutes before the human found it.

**A finding outlives its raiser.** Only the raiser may release, which assumes
raisers persist — and they do not. Two of six participants in one session died
of infrastructure and four were stopped, leaving every finding they had raised
held by nobody and the fixed point unreachable by construction.

So a finding whose raiser is gone is neither held nor released. The minute marks
it `raiser absent`, and a present participant may **re-derive it from its
recorded consequence and evidence** — raising it anew if the consequence still
follows, or recording `not reproduced at <revision>` if it does not. Nobody
inherits it as settled and nobody discharges it by assertion. "One held
objection means not yet" means held by someone in the room.

**Stopping a participant that holds an open finding is a destructive act.**
Confirm with the human first, and record it.

**Where a lens can only be administered by the caller, that is a legal
outcome and not a failure**, provided it is labelled. Load its taxonomy, apply
it in a pass of its own, and record that it ran inline rather than dispatched.
The independence is genuinely weaker — a lens primed by the caller's reasoning
stops looking sooner — and naming that is what keeps the record honest.

This is not hypothetical. Three review attempts on one branch dispatched
specialists that never returned; two stalled waiting, and the third produced
findings only after falling back to sequential inline passes. The fallback found
a critical defect the dispatched attempts never reached.

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

**Say how to report, because the channel truncates.** A participant sends its
report to the caller with `SendMessage`, in one message under ten thousand
characters, or writes it to a file and sends the path. A report left as the
participant's final text is cut at roughly four thousand nine hundred
characters. In one session seventeen of twenty-seven reports arrived truncated,
the caller sent thirteen messages asking for tails against ten substantive
round messages — **recovery traffic exceeded review traffic** — and the two
participants that died did so while emitting a long report as final text. The
one participant that used `SendMessage` was never truncated.

A report that arrives truncated is a failed delivery, not a short report.

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

   Six techniques, all of which caught something in the session that produced
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
   and nothing is outstanding. **From round two, every round includes at least
   one participant reading the current subject without the prior findings.** A
   fixed point reached by verifiers alone is not a fixed point: resumed
   participants verify against the bars they set, and a defect introduced after
   their last pass and untouched by the diff is invisible to all of them at
   once. Resumed participants also declare what they did not re-examine.

**The subject holds still for the duration of a round.** Changing it under a
participant invalidates the answer being asked for, and turns findings stale
rather than wrong.

**The author holds still between rounds too**, and this is the harder half. An
edit between rounds answers a recorded finding and names which one; an edit that
answers nothing waits for the next round to ask for it. Before re-dispatching,
the drafter compares the subject's diff against the findings it claims to answer
and refuses a round whose diff grew the subject.

Without that, the loop stops reviewing the subject and starts reviewing the
repairs. One assessment answered twenty-four first-round findings with a diff of
+249/−62 on a two-hundred-line document, and every later round's findings landed
in lines that had not existed the round before.

**When a finding is about a tool's behaviour, the answer is a measurement in a
scratch repository that varies one input**, recorded as the command and its
output — not a rewording of the claim. One claim about `git zhi docs health`
was wrong in four successive revisions across seven rounds. It had been measured
eleven times, always in the live repository where several inputs varied at once,
and each correction edited the prose. A participant settled it in seven minutes
with eight scratch repositories varying one field.

Grepping the document for the old wording is not this check. It was tried, and
the claim it was guarding was still wrong.

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

**The minute is a ledger first and a narrative second.** One row per finding:

| id | raiser | round | section of the subject | consequence if it ships | evidence | status | revision |

Prose may follow, and a round's brief to a resumed participant is the diff plus
the ledger.

The table is what makes the rest work. A finding recorded as a row survives its
raiser, so `raiser absent` is a status rather than a dead end. Rebuttals have
somewhere to live that is not the subject, so the subject stops absorbing its own
review. And two facts become things you read rather than things the drafter
asserts about itself afterwards: where findings came from, and whether they
cluster in one section — which is the signal that part of the subject is
carrying the whole argument.

A minute written as narrative hides all three. One ran to six hundred lines of
prose, was written in arrears, and its findings-by-origin table was composed by
the drafter at the end from memory.

The drafter also records, for the round:

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
