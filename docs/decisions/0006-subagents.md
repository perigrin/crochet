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

Crochet dispatches subagents in five skills, exchanges messages with peer
sessions it does not dispatch, and has no single account of either. The rules
that exist were each settled where they were first needed:
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

**A peer session is not a subagent, and coordinating with one is unowned.**
Crochet dispatches subagents it briefs and collects from. It also exchanges
messages with long-running peer sessions it does not dispatch, does not brief,
and whose lifecycle it does not control — the `git-zhi` session is the standing
example. Nothing in any skill says how that works.

**The rule to start from: assume a peer has crochet loaded, and verify it.**
Where it does, the two sessions can work through documents rather than through
messages — a design document handed over and walked through the loop in the
peer's own repository, which is what `docs/requests/git-zhi-verification-integrity.md`
attempts. Where it does not, the same content has to arrive as a message that
stands on its own, because there is no shared protocol to carry it.

This is `docs/contributing/coding-conventions.md`'s probe-rather-than-test rule
pointed at an agent instead of a binary, and **it degrades when it gets there.**
`git zhi <sub> --help` is an observation; asking a peer whether it has a skill
loaded returns a claim, and a peer that has been restarted may answer about a
configuration it no longer has. What a verification of this kind can actually
rest on is an open question, and the cheap answer — ask, and treat the reply as
provisional until something it produces shows the skill ran — should be written
down rather than assumed.

Two things observed on the day this was written, both cheap to repeat:

- **A peer restart is invisible until it costs something.** The `git-zhi`
  session was replaced between exchanges. It returned carrying none of five
  prior exchanges and had to ask cold what it was still owed. The only notice
  was a line in a delivery result saying the name had been used by an earlier
  session.
- **A peer's report of another session's state can be wrong.** This session was
  described to perigrin as complete while a milestone gate had not run and
  seventy-seven commits were unpushed.

Both are the same finding as the resumption evidence above, arrived at from the
outside: **what survives an agent ending is what was written down.** That is an
argument for the minute and the archive rather than against fresh dispatch, and
it is the reason peer coordination belongs in this decision instead of its own.

**The counter-evidence belongs here too.** Respawning has a cost, and the
`git-zhi` restart is the clearest measurement of it available: the session spent
a full exchange reconstructing what it already knew. That cost was survivable
only because the gaps had been recorded in an issue body. A rule favouring fresh
agents therefore carries an obligation to record, and the decision should say so
in the same breath rather than in a different section.

**Nothing drives the pipeline, and whatever does becomes the orchestration
session.** 0003 defines seven gates and leaves invocation to a human typing
seven commands in order. This is tangential to subagent coordination and lands
here because the driver *is* the long-lived context that gates dispatch out of:
deciding what persists across gates and what is spawned fresh into them is the
same question this decision opens with, asked at the scale of the whole
pipeline.

`crochet:preflight` already computes the hard part. Its six-row table maps
observed chain state to the next gate, and the skill calls the result "advisory
output only — it never blocks". A driver is thin: run preflight, invoke the gate
it names, repeat. What is not thin is where it stops.

**Stop on a finding, not on a gate.** `skills/chain-review/chain-review.md`
already has this shape — it confirms and suggests the next gate when both lenses
produce nothing, and presents and halts when either produces something. A gate
still runs, still reaches its fixed point, still writes its minute; it does not
interrupt a human to report that nothing was wrong. Halting on every gate
regardless of its verdict is the friction 0003 exists to remove.

**Three conditions stop the driver, and the third is the one that needs
building:**

- a finding;
- a discernment session that reports non-convergence rather than unity;
- **a gate that cannot show what it examined.**

The third is the vacuous pass, and it is the reason a driver that advances on
green is dangerous in a way a human typing seven commands is not. On the day this
was written, three separate checks in this repository reported success over
nothing: `verify --dry-run` returned empty and exit 0 against a pending chain
carrying sixty-nine commands, `verify <milestone>` reported 54/54 while running
the negative scenarios twice, and `docs check` confirmed reachability from a
`CONTRIBUTING.md` that did not exist. All three were green. None was caught by
reading the output; each came out of attacking the check on purpose.

A human advancing by hand re-reads the subject between gates and has a chance of
noticing. A driver reading exit codes has none, and would run the whole pipeline
on vacuum and report a clean delivery. So a gate must be able to say what its
subject was, and **what "cannot show what it examined" means in a form a driver
can act on is unsettled.** Part of it depends on work requested in
`docs/requests/git-zhi-verification-integrity.md` landing, since several of the
gates cannot currently answer the question at all.

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
