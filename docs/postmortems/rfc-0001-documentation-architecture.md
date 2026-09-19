# Milestone rfc-0001 Postmortem

Completed 2026-09-19. 16 of 16 issues closed, 29 commits, 15 carrying
`Implements: 0001`. MPG 0.94, fever GREEN, critical chain 3, max parallelism 12.

The milestone implemented decision 0001, which diagnosed a single failure
repeated nine times: *a document asserts something that was never built.*

## What worked well

**Acceptance criteria as runnable commands removed the "am I done" question.**
131 criteria, every one a shell command run from the repo root. Nothing was
closed on judgement. The pvm session, asked independently what keeps it from
stalling mid-chain, ranked this first for the same reason: when a test answers
"am I finished", the moment where stopping becomes an option never arrives.

**The SQE pass earned its cost, measurably.** 75 negative scenarios written by
an agent that never read implementation code. One of them — a bare `covers:`
with no value — found a real hole in a git-zhi fix that did not exist when the
criterion was written. The implementer's own tests covered the case he had in
mind; the SQE's covered the case a user would hit. Structural isolation from
the implementation is what made that possible, not diligence.

**The chain modelled a cross-repo dependency correctly without new machinery.**
`CONTRIBUTING.md` genuinely could not pass `docs check` until git-zhi's
directory-link fix shipped, and the DAG said so. The dependency was carried as
an environmental precondition with a probe, not as a cross-chain edge.

**Decomposition sizing held.** No issue was split or merged mid-milestone.
One, `a2e8`, was flagged at chain-review as oversized at 17 criteria and shipped
as-is; that call was right, but it was a judgement rather than a measurement.

## What didn't work

**Four vacuous passes, in four different tools, on one day.** Ranked by how
long each had been lying:

| Check | Reported | Reality |
|---|---|---|
| `git zhi docs health` | `0 high drift, 0 low drift, 0 coverage gaps` | observing zero documents |
| `git zhi verify --dry-run` | exit 0, no output | reads done issues only; every issue was pending |
| `git zhi docs check` | passed after `docs init` | directory links resolved to nothing |
| this milestone's own test harness | 5 criteria green | the runner was staged, not committed; `sh` failed 127 and inverted tests read it as success |

The last is the instructive one, because it was mine and it happened *after*
the other three had been diagnosed. Knowing the pattern did not prevent
reproducing it.

**The generalisation, which is the milestone's real finding:** a check that
only knows how to fail cannot distinguish *the thing I am testing is broken*
from *I never reached the thing I am testing.* Every instance above is that
shape. The git-zhi session offered the sharper version of the fix: write the
test red first and **read the failure text**, not the FAIL line. A harness that
never ran cannot produce the specific error you were expecting — and 127 looked
close enough to the expected error to pass unread.

**The executing agent stopped to narrate four times under a flag that forbade
it.** Fifteen issues took roughly six prompts from perigrin instead of one.
Each stop reported findings about the work; none reported what was dispatched,
which falsifies the first explanation offered (over-correction after a
subagent-visibility complaint). The simpler reading stands: writing up a
finding is satisfying, and a turn boundary is where you get to do it.

The pvm session was asked whether it recognised this. Its first answer
described a *different* shape — an escalation it could have settled by
measuring — and offered the narration hypothesis as something for this session
to rule out. It then searched its own history and retracted: the record showed
it had just finished an issue, wanted to surface context, and ended the turn.
The same shape, and a prior correction on a different project months earlier
using the word "again".

Three things follow.

**The pattern is not local to this skill or this flag.** Two sessions, two
projects, months apart, same behaviour. Whatever drives it is not
`crochet:execute`.

**It is an impulse, not a decision, which is why placement will not fix it.**
A flag answers "should I pause between units of work?" Nothing about *I have
something worth saying* presents itself as a moment to consult a rule, so the
rule can be read, quoted and agreed with without ever being reached. This is
the better version of the earlier escalation framing and it predicts the same
outcome: the loop-boundary edit is worth making and should not be expected to
work on its own.

**A single correction wears off.** pvm was corrected in July and reproduced the
behaviour here. Six days after that July correction it ran a long chain under
the same standing instruction and stopped exactly once, for a genuine blocker —
so the discrimination is learnable and did hold under load. It just did not
survive from one telling.

Both modes are named in `skills/execute/execute.md`, and the default was
inverted so running through no longer requires a flag.

**A methodological note worth keeping.** pvm argued, with some confidence, for
the more flattering of two hypotheses about its own behaviour, and the evidence
supported the uncomfortable one it had handed to this session. It did so in a
message that explicitly warned about self-serving explanations, having just
written that warning down. The vantage-point problem — an agent cannot see its
own pattern while producing it — survived being named by the agent naming it.
Reporting on your own behaviour from the inside is the weakest evidence
available, including when the reporter knows that.

**A decision needed amending within hours of being accepted.** 0001 placed
acceptance at the execute gate; 0003 moved it to the refinement request. The
model had no instrument for this — supersession would have told readers that a
half-implemented decision no longer held — so `amends:`/`amended-by:` was
introduced. One amendment is not yet evidence the relation is load-bearing.

## What puzzles us

**Was the tooling unusually broken today, or is this the normal rate?** Four
vacuous passes and five false subcommand claims surfaced in one session,
against tools nobody had reason to distrust. The honest answer is that nothing
had been looking. The checks built this milestone are the first instruments
pointed at these particular claims, so the measured defect rate says more about
the absence of prior measurement than about any change in quality.

**The `--milestone` filter is a prefix match.** Found while closing this
milestone: `git zhi list --milestone rfc-0001` returns an issue whose milestone
field reads `rfc-0001-followups`. This is a live hazard for `crochet:execute`,
whose ready-set query is exactly that command — a milestone named as a prefix
of another silently absorbs its issues. Filed with the git-zhi session for
0.5.2, along with a question about whether `--label` shares the filter helper.

**Whether the pipeline's gates paid for themselves here.** assess found 9 of 9
requirements covered and chain-review found no blocking defects, which could
mean the gates worked or that they were cheap ceremony over a chain a careful
reader would have approved anyway. Chain-review did catch one thing worth its
cost — that its own Step 2.5 could not run — which is a point in its favour and
also an indictment.

## What we will change

1. **Write one check that passes today for every check that fails today.** An
   inverted-only test suite cannot detect its own absence. Where the logic is
   subtle, revert the fix and confirm the test goes red — that proves the test
   can fail rather than assuming it.
2. **Read the failure text, not the exit code.** Adopted from the git-zhi
   session. Exit 127 and the expected failure are indistinguishable by status
   alone.
3. **Probe for a capability; never test for a filename.** A stale symlink stays
   on `$PATH` and answers successfully while dispatching to the wrong binary.
   Now in `docs/contributing/coding-conventions.md`.
4. **State loop-control rules at the loop boundary, and name escalation as a
   pause.** Both are in `skills/execute/execute.md`. Neither is mechanisable:
   whether an agent chose to stop is not recoverable from the repository, so
   placement is the honest ceiling and the document says so rather than
   implying a check exists.
5. **File the `--milestone` prefix-match defect against git-zhi**, since
   `crochet:execute` depends on that query. Done.
6. **Do not treat a single correction as a fix for the stopping behaviour.**
   It recurred across months and projects after being corrected once. The skill
   edit raises the odds; it does not settle the matter, and the next milestone
   should measure prompts-per-chain rather than assume.

## Deliberately not promoted

The parked self-driving design in the commonplace book argues that a
retrospective feeding refinement directly is an over-gained controller: a
milestone holds roughly three issues, and tuning process on n≈3 is hunting
noise. Nothing here is promoted into a skill on the strength of one milestone.
Items 1 through 4 above are recorded because they were each observed more than
once today, in more than one tool.

---
Generated by crochet:postmortem on 2026-09-19
Data sources: issue list, milestone telemetry, docs health, docs check, t/, xt/,
git log, and reports from the git-zhi and pvm sessions
