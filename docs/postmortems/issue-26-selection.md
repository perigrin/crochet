# Milestone issue-26-selection Postmortem

Subject: perigrin/crochet#26. Execute's workers chose their own issues with a
bare `git zhi next`, so they drifted off the milestone and duplicated each
other's picks. The delivery makes the orchestrator assign every pick under a
fresh per-pick token. It also adds `t/execute-selection-walkthrough.sh`, which
drives the protocol against a real scratch chain.

Pipeline as run: assess (8 rounds), refinement (9 issues), chain-review
(3 rounds), execute (9 issues, 14:18 to 18:33 on 2026-10-27), review
(3 rounds), then this document. Observed on git-zhi 0.7.2.

## What Worked Well

- **Three issues ran clean**, each in one session and one commit with no
  reopen: 5bad (per-command `ZHI_ACTOR`), 5bf3 (how-to-use-git-zhi) and 5c05
  (the postmortem wording). 5bf3 and 5c05 ran in parallel with 5bad and merged
  without friction, because refinement had predicted their paths as disjoint.
- **Decomposition held.** No issue was split, merged or cancelled. The
  doc-first ordering, with the ARCHITECTURE.md issue blocking the skill issues,
  was followed without anyone having to enforce it.
- **The fresh-reviewer gates caught real defects before merge.** Issue 4's
  first wait was a backgrounded `sleep` that waited 0.05 s. Issue 8 judged
  progress per worker, so a git-zhi read race turned about 1 run in 6 red.
  Issue 9's control passed vacuously twice.
- **The cold reader earned its seat.** In review round 2 it found the bar that
  three lenses had held only as a residual. Step 4's restart without a token
  fails its own ownership check and strands the issue. It found this by running
  the step in a scratch repo, not by reading.

## What Didn't Work

- **Two issues took most of the time.** Of about 4h15 of execute, 5c13 (the
  walkthrough) took about an hour over 3 commits and 5c21 (refusal cases and
  control) about 2h30 over 4 commits with 2 reopens. Both were test
  infrastructure for a concurrent protocol. The issue cards sized them like the
  prose issues.
- **Control mode passed vacuously, twice.** It passed first on a verdict that
  fails by construction, then on "nothing started". Both times the defect was a
  check that could not tell a protocol-less run from a broken one. The repo's
  own rule ("Write one check that passes today for every check that fails
  today") names this failure, and it still happened twice in one issue.
- **The review's fix commit introduced the next round's bar.** 50e80d1 restored
  a stop rule that exempted only `start`. Three of four round-2 participants
  found that `next` exiting 1 now ended the run. Folding many residuals into one
  commit invited this.
- **The verify gate, not the review, caught the last two regressions.** The
  final verify run failed 2 of 107 criteria. 2e2e8bc had reused the stop-rule
  phrase a criterion forbids. 9ab793f's longer header comment had pushed
  `set -u` past the 20 lines a criterion reads. An earlier "verify passed" had
  read the exit status of a wrapper script rather than verify's own.
- **Assessment needed 8 rounds and 5 human rulings.** Scope widened past
  selection in r3 and had to be narrowed back.

## What Puzzles Us

- **git-zhi 0.7.2's concurrent reads fail intermittently** with
  `ref file is empty` or `no issue found matching` for an issue that exists.
  The protocol absorbs it, but nobody has a reproducer narrower than the
  walkthrough. It is a sibling of perigrin/git-zhi#35.
- **A Monitor wait ends a subagent's turn, and the agent then resumes.** One
  observation underlies execute's "only its final report is a return" rule.
- **`git zhi docs health` reports 9 HIGH-drift documents.** It reads the
  archive as well as the live layer, so the number says little about this
  branch. Review read the live documents directly instead.

## Where A Human Had To Act

| Interruption | Kind | What would have let the agent proceed |
|---|---|---|
| Installed git-zhi was 0.5.2, below the 0.7.2 floor | friction | `crochet:install` building or fetching the pinned version unprompted |
| Five rulings during assess | collaboration | Mostly none: scope and urgency are the user's. Ruling 2, that `ZHI_ACTOR` set per command is a harness detail, could have been settled by 0002's text |
| "Fix the grep" and "file a ticket" in chain-review | partly friction | pushback flagging grep patterns that begin with `--` mechanically |
| `rm -rf "$d"` inside `sh -c` refused | friction | criteria that clean up through a named, checked path |
| Probe push of `refs/zhi` denied | friction, deliberately unresolved | none needed: the chain stays local |

The actor telemetry was not used as the source, as this skill directs. Every
worker transition here carries an `agent:` token, but refinement's and
chain-review's writes do not.

## What Will We Change

- **Size test-infrastructure issues for concurrency.** An issue that must make
  concurrent processes deterministic should be cut thinner. Here that means one
  issue for the harness and one per case family, because 5c13 and 5c21 took 80%
  of execute's time.
- **Require a vacuity check before any inverted verdict.** A check that passes
  on the absence of something must first prove that something ran. Make it an
  explicit acceptance case the SQE role writes, not a lesson relearned per
  issue.
- **Review fixes go one finding per commit.** That way a bar introduced by a fix
  traces to the one finding it was fixing.
- **Keep the cold reader in every review round from 2 on, and let it run
  commands.** Its bar came from execution, not reading.
- **Follow-ups:** perigrin/crochet#27 (worker lifecycle), perigrin/crochet#28
  (the milestone has no runnable criteria), and perigrin/git-zhi#35, #36 and
  #37 (concurrent-start race, empty ref resolving to HEAD, short-ID collision).

---
Generated by crochet:postmortem on 2026-10-27
Data sources: issue list, milestone telemetry, verify results at the final
commit, docs health, sanbao report (no speed or MPG
figures for this milestone), commit log `origin/pu..HEAD`
