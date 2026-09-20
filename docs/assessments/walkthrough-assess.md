---
stability: 1
covers:
  - skills/assess/assess.md
---

# Walkthrough: crochet:assess

Observed on git-zhi 0.6.0 (`dbc364c`), against a scratch repository at revision
`7e24e19` holding one skill file and one decision with a planted defect. Run by
a dispatched participant that had not seen crochet before.

This records what the skill **did**, not what it says. Every finding below cost
a change to `assess.md`.

## What the participant could not do as written

**Step 0 told a participant to dispatch a session.** The delegation instruction
sits inside assess's Process section with nothing marking it as the caller's
job, so a dispatched participant reading the skill to learn what is expected of
it finds an instruction to spawn its own round. It declined, correctly.

**The capability guard could never pass.** `If crochet:discernment is available`
was checked against a manifest with exactly two plugin keys, `superpowers` and
`paad`, and a cross-check covering only those two. Every caller silently took
the fallback branch, so the parameterised loop never ran. Fixed by removing the
guard: a sibling in the same plugin cannot be absent.

**`docs/assessments/` did not exist and assess never said to create it.** The
path was also bare and relative, so a participant pinned to another checkout
resolved it into the wrong repository.

**Writing the assessment turned a green repository red.** `docs check` reported
one unreachable file, because nothing had linked the archive from
`CONTRIBUTING.md`. Assess predicted this and stated it as a fact about the
checker rather than as a step — so following the skill literally breaks the
repository, and the first assessment a repo ever writes is the one that does it.

**Neither form carried a recommendation.** `crochet:discernment` requires every
participant to end with reject, modify or accept. The full template had
Blocking/Missing/Partial/Ready and no verdict field; the cursory form had the
three axes and no verdict either. The participant added one because discernment
demanded it, not because assess had a slot — two skills written in the same
milestone disagreeing about what an assessment is.

**The naming had three readings.** The prose said "after the decision it
assesses", the template said `<NNNN>.md`, and this repository's own only
assessment is `rfc-0003.md`, which matches neither.

## What the checker reported that it had not examined

`git zhi docs check` printed `✓ All files reachable from CONTRIBUTING.md` in a
repository with no `CONTRIBUTING.md` at all. Same shape as the `docs health`
defect this repository already documents: a summary that reads identically
whether everything passed or nothing was examined.

`docs/decisions/` also gets an implicit reachability pass where
`docs/assessments/` does not, and the rule is stated nowhere a skill author
would find it.

## The assessment it produced

**assess wrote `docs/assessments/0001.md` in the scratch repository**, after
creating the directory itself, and recorded revision `7e24e19` at the top of it.
That file is the gate's record: the participant presented its findings as well,
but the presentation would have been lost at the next compaction and the file
would not.

Recommendation **reject**, on a planted subject claiming `git zhi frobnicate`
exists. It found that, and then found something better.

The subject's own criterion `grep -rq frobnicate skills/` was **green** — because
the only skill in the repository read "a skill that does not call frobnicate".
A substring check cannot distinguish a call from its negation.

That is the concrete demonstration two chain-review lenses stood aside on when
they raised the grep ratio, and it recurred three times in this milestone's own
work within the hour: a prohibition matching a grep for the pattern it forbids,
twice, and a criterion matching a rule's own retraction.

## What this walkthrough did not test

Only assess's nominal path, once. The delegation to discernment was never
exercised because the guard prevented it, so what assess does with a real
session remains unobserved.
