---
stability: 1
covers:
  - skills/discernment/discernment.md
  - skills/assess/assess.md
---

# Postmortem: the 0004 assessment

**A postmortem on a gate rather than on a milestone.** `crochet:postmortem` runs
at milestone completion and there is no milestone here — 0004 is still
`proposed` and nothing implements it. What concluded was six rounds of
`crochet:assess`, which produced findings about the machinery that are worth
more than the findings about the decision, and which nothing else in the
pipeline would record.

Six rounds, three participants, 82 minutes of wall clock. The gate stopped by
choice rather than by convergence. The full minute is in
`docs/assessments/0004.md`.

## What Worked Well

**Adding a participant who had not seen the document found what three rounds of
two participants could not.** The cold read produced a false claim that had
survived since round one, a check that fails open on the default CI checkout, a
lens whose subject could not be identified, and the diagnosis that explains the
whole session — that a decision specifying its own self-test's fixture
arithmetic is written at the wrong resolution.

None of those was reachable by verification. They needed someone to re-derive
from the tree, and `crochet:discernment` correctly says a resumed participant
verifies rather than re-derives. What it does not say is what follows: **a fixed
point reached by verifiers alone is not a fixed point.**

**Participants declared their own degradation without being asked, and the
declaration was more useful than the findings.** Asked whether its finding rate
was real or comfortable, one estimated "roughly half to two-thirds the effort"
against round two and listed what it had stopped checking — the document read
top to bottom, git-zhi re-probed, this repository's own idioms re-verified. It
then stated the consequence exactly: a defect introduced in round three and
untouched by round four's diff would not be caught by anything it ran. Two such
defects were found by the cold read in that same round.

The same participant twice flagged that it was scoring a paragraph written in
answer to itself, and released on the argument rather than on the agreement.
The other retracted a finding of its own that had cost the document its only
regression, and audited which of its releases rested on evidence it had not
verified. `crochet:discernment` predicts a resumed participant coasts; these
did the opposite, and the counter-evidence belongs on the record beside the rule.

**A non-returning participant was detected and worked around.** A dispatch died
on an API error; the rule added during `rfc-0003` — say so and proceed — was
already written and worked. Fourth recorded instance, first where the rule
pre-existed the failure.

**Two real defects in a dependency were found and filed.** `git zhi docs health`
reports health it has not established, in two independent ways, both failing
toward clean. Neither would have surfaced without a participant being forced to
re-derive a claim rather than check it.

## What Didn't Work

**The gate became a loop that reviewed the author's repairs.** Findings by
origin: round one found the document as authored; rounds two, three, five and
six found defects in fixes the author had made minutes earlier. Genuinely new
information from outside the author's own repairs amounts to round one, the
resolution diagnosis, and the two git-zhi defects.

The mechanism is simple and was invisible from inside. The author answered each
finding by editing immediately and re-dispatching, and never attacked the edit
with the rigour the participants applied to the original. Three participants per
cycle then paid full price to catch a defect a minute of self-verification would
have caught. On the shallow-clone fail-open that minute was one `git clone
--depth 1`. On the `docs health` claim it was re-running one command.

**`crochet:discernment` says the subject holds still for the duration of a
round. It says nothing about the author holding still between them**, and that
is the gap this session found.

**One claim accounts for three of the six rounds.** The `docs health` behaviour
was wrong as originally written, wrong in the round-four correction, and wrong
in the round-five correction. Each time the wording was edited and the
measurement was not re-run. It was finally settled by a participant backdating a
file's mtime by a year to see whether anything changed — the falsification
experiment that should have been run the first time, before anything was built
on the inference.

The original observation was correct and the inference from it was not: nine
documents reporting `all current` with identical mtimes, in a worktree created
minutes earlier, where nothing had been committed since. Correct behaviour, read
as a broken tool, on the strength of a coincidence.

**Answering findings in place made the document worse while making it more
correct.** Every round's answer added specification; every addition was right;
the document grew from 223 lines to 550 and by the end was three-to-one about
its own enforcement mechanism rather than about what it decided. The findings
were about implementation detail that should never have been in a decision, so
answering them where they landed compounded the original error.

**A dead subagent sat in the task list for 39 minutes.** It failed, a replacement
was spawned, the failure was reported — and the corpse was never reaped. The
user found it, not the author.

## What Puzzles Us

**Whether six rounds was too many or four was too few.** The rate of new
findings did not fall across six rounds, which normally means stopping early is
wrong. But the character changed: late rounds found the author's repairs rather
than the subject. A loop can be non-convergent because the subject is hard or
because the author keeps feeding it, and nothing in the gate distinguishes those.

**Whether the cold read's value was the fresh context or the forced order.** Its
brief required writing a view down *before* verifying anything, and reading the
minute last. Both incumbents had fresh context once, in round one, and neither
produced anything resembling the resolution diagnosis. That suggests the order
mattered independently, but one trial is not evidence.

## Where A Human Had To Act

Four composition questions were put to the user, three with a recommendation
attached, and the recommendation was taken every time. The user named it: *"why
is it my call whether to run it? you feel it's necessary."*

That is the marker. **What the repository should do is the user's; whether the
gate has converged is the agent's**, and `crochet:discernment` supplies the
bound, the fixed-point test and the rule for a round that raises something new.
Routing arithmetic through the user spends their attention on a decision that is
not theirs.

The user also caught the runtime accounting. The agent reported participants as
idle between rounds, inferring from status plus report timestamps rather than
checking, and did not notice that resuming a participant resets its clock — or
that a fourth entry in the list was a corpse.

## What Will We Change

1. **The author holds still too.** Before re-dispatching, attack the edit as a
   participant would: re-run every command the finding touched, and construct the
   case where the fix is wrong. `crochet:discernment` should say this beside
   "the subject holds still for the duration of a round".

2. **A resumed participant declares what it did not re-examine.** One did this
   unprompted and it was the most useful artefact of the session; the blind spot
   is otherwise invisible to everyone including the participant. Cheap, and it
   tells the caller when a fresh participant is owed.

3. **A fixed point reached by verifiers alone is not a fixed point.** Before a
   gate closes on agreement, one participant must have re-derived from the
   subject rather than verified against prior findings. In practice: add a fresh
   participant before accepting, not after stalling.

4. **A claim measured once is not established.** A behavioural claim about a tool
   should record the falsification attempt, not the observation. "Nine documents
   reported current" is an observation; "backdating the file a year changed
   nothing" is evidence about the mechanism.

5. **Reap a failed dispatch when reporting it.** The rule to say so and proceed
   is written; the cleanup is not, and a corpse in a task list is indistinguishable
   from work in progress to the person reading it.
