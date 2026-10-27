---
stability: 1
covers:
  - skills/execute/execute.md
---

# Assessment: issue #26, milestone-scoped worker selection in execute

Threshing session over perigrin/crochet#26 ("execute: bare `git zhi next` is not
milestone-scoped, so workers pick other milestones' issues and collide").
#26 has no decision number, so this file is named for the issue. Three rounds
have run, all against git-zhi 0.7.2 (`7b9287d`). Rounds 1 and 2 ran against
crochet `d2de72f`. Round 3 ran against `bd918b1`, which is `d2de72f` plus the
two commits recording this assessment; `skills/execute/execute.md` is unchanged
from `d2de72f`.

- **Round 1** assessed r1: the issue body as fetched on 2026-10-27.
- **Round 2** assessed r2: a revision written by the orchestrating session to
  answer the round-1 findings.
- **Round 3** assessed r3, titled "milestone-scoped worker lifecycle in
  execute", which answers the round-2 findings.

r2 and r3 are held in the session's scratch directory (`subject-r2.md` and
`subject-r3.md`, with r1 as `subject.md` and the diffs as `r1-r2.diff` and
`r2-r3.diff`), **not in this repository**. #26's body on GitHub is still r1.

**The human's scope ruling at r3.** r3's opening records it: "Round 2 showed
(F1) that #26 cannot be fixed at the first pick alone. Dispatched workers return
after one issue, so 'reassign when a worker finishes' had nothing to reassign.
The human chose to specify the worker's whole lifecycle." So r3's "Where it
goes" covers Step 2, Steps 3.5 and 4, Loop control and Key Constraints, not Step
2 alone. r3 also records two measurements its author made before writing it, on
0.7.2: a reopened issue keeps its assignment (D2), and a worker starting its own
in-progress issue is refused while `next` returns that issue to it (D4).

**Round 1 outcome: another round owed.** All three participants recommended
**modify**.

**Round 2 outcome: another round owed; objections are outstanding.** Each
participant's recommendation, as written:

- `i26-arch`: **modify**. "This is what keeps my recommendation at modify": A9.
- `i26-evidence`: **modify** (narrowly). "Accept once they are folded in": E10,
  E11, E12.
- `i26-pushback`: **modify** (small). "Nothing here needs another structural
  rework."
- `i26-fresh`: **modify**. Names F1, F3, F4 and F8 as what the subject needs.

**Round 3 outcome: another round owed; objections are outstanding.** Two
earlier findings are held (A9, F3) and 31 were raised in round 3. Each
participant's recommendation, as written:

- `i26-arch`: "**Recommendation: modify.** r3 is close." "Two things have to
  change before it can be scoped": A12 and A9. "R7 and R3's integration
  predicate each need one sentence (A13, A14)."
- `i26-evidence`: "**modify** (narrow; accept once E13 and E14 are folded into
  R5 and R6)".
- `i26-pushback`: "**modify**". "Each fix is local. None of them reopens the
  shape."
- `i26-fresh`: "**modify**". "r3 resolves eight of my ten findings, and the
  lifecycle model is the right shape." It names F3, F11, F12 and F13: "All four
  are questions of who owns which step and which shared write, so they belong in
  the subject."
- `i26-cold`: "**modify**". "Keep R2, R3 and the identity points of R7 and R9,
  and amend 0002 explicitly. Settle C1 to C5 before acceptance, because each one
  is a way the run hangs, loops or loses records. Cut R5 down to a single
  read-back after start (C6), and drop the resume branch (C7). Name
  `how-to-use-git-zhi.md` in 'Where it goes'."

No participant declared a block or a standing-aside in any round. (`i26-fresh`
writes of F8(f), "I note this but do not block on it".)

## Participants

| | Role | Rounds | Context |
|---|---|---|---|
| `i26-arch` | participant | 1, 2, 3 | dispatched fresh in round 1, resumed in rounds 2 and 3; codebase and architecture axes, read against decisions 0002 and 0003 |
| `i26-evidence` | participant | 1, 2, 3 | dispatched fresh in round 1, resumed in rounds 2 and 3; re-derived every behavioural claim in scratch repositories on 0.7.2 |
| `i26-pushback` | participant | 1, 2, 3 | dispatched fresh in round 1, resumed in rounds 2 and 3; `paad:pushback` over the subject as a spec |
| `i26-fresh` | participant | 2, 3 | dispatched fresh in round 2, resumed in round 3. In round 2 it declared it did not open this ledger, any other `i26-*` report, r1 or the diff. In round 3 it read r3 and ran its checks first, then this ledger at `bd918b1`, then `r2-r3.diff` |
| `i26-cold` | participant | 3 | dispatched fresh in round 3 with no prior findings or revisions. Declared it did not open this ledger, any `i26-*` file, any diff, `subject.md` or `subject-r2.md`. Read crochet's `CLAUDE.md`, `ARCHITECTURE.md`, decision 0002, `execute.md` and parts of `how-to-use-git-zhi`, git-zhi source, and the body of git-zhi#35 through the GitHub API |
| orchestrating session | drafter, round 1 | 1 | held no view on the subject; was not r1's author |
| round-2 drafter | drafter, round 2 | 2 | a separately dispatched subagent holding no view on the subject. The orchestrating session could not draft round 2, because it became the subject's author at r2 |
| round-3 drafter | drafter, round 3 | 3 | again a separately dispatched subagent holding no view on the subject |

r1's author, an agent running `crochet:execute` on pvm's `m2-incremental`, did
not sit. r2's author, the orchestrating session, wrote the revision and
submitted no report in round 2. r3's author made the D2 and D4 measurements
recorded in r3 and submitted no participant report in round 3. Every participant
reported by writing a file; no report was truncated and no participant died.

## The three axes

As the participants stated them after round 3. Round-2 statements that a
round-3 report did not revisit are kept and marked.

1. **Codebase.**
   - On 0.7.2, R1, R2, R4, R7 and R8 "hold as written" (`i26-evidence`). R5
     works with the settle: immediate both-own 2/80 (r26), settled 0/100 (r25).
     Its pre-push predicate is false after `done` (E13).
   - No transition returns an in-progress issue to the pool, and start-up
     reclamation clears assignments only. Observed separately by `i26-arch`
     (G1), `i26-evidence` (r28), `i26-pushback` (probe 1), `i26-fresh` and
     `i26-cold`. Pause by one actor then resume by another transfers ownership
     (G3, r28, probe 1, `i26-fresh`).
   - `wip_limit` counts every in-progress issue in the repository, whatever its
     milestone or actor (P17, C4).
   - `milestone edit --body` replaces the whole body (F12, C5).
   - Blocker integration is not observable through the CLI, only through git
     (E15).
   - `issue edit` with an empty ref acts on HEAD: an empty `$ID` started an issue
     in another milestone, exit 0 (C6).
   - The default `issue list --milestone` omits reopened issues (E16).
   - `export ZHI_ACTOR` does not reach the next Bash call in this harness: F5 in
     round 2, re-confirmed by `i26-evidence`.
   - Four participants, each a dispatched subagent, report that their own tool
     list has no agent-dispatch tool (`i26-arch`, `i26-pushback`, `i26-fresh`,
     `i26-cold`). Each calls this one harness.
2. **Architecture.**
   - D3: `i26-arch`, `i26-pushback` and `i26-fresh` read R2 as within 0002.
     `i26-cold` reads 0002 as stating the opposite of R2 and R7, needing an
     amendment. See D3.
   - R7 against 0002's "declared once, for the process, not per command" (A13,
     P18, C9). See D6.
   - R1 against 0003's composition rule, as cited in Step 4 (A9, P12, F11, C3).
   - `i26-cold`: 0002 says "Fan-out is not specified here"; R1, R4 and R8
     specify it, which "is allowed, but it is new ground, and it belongs in the
     same amendment".
   - `i26-cold`: R7 falsifies `how-to-use-git-zhi.md`, outside "Where it goes"
     (C9). ARCHITECTURE.md's "reported as stuck" has no counterpart in R6 (C2,
     F14).
3. **Direction.**
   - `i26-arch`: A8 still released. "Autonomy is preserved and nothing is
     misreported as finished."
   - `i26-pushback`: the human's widening "was the right call". P16: a hung run
     is "an unattended session that never reports".
   - `i26-fresh`: "the lifecycle model is the right shape."
   - `i26-cold`: R2 and R3 "serve autonomy well". R1 "is the right instinct for
     autonomy", but as written "it removes the independent reviewer that the
     human relies on (C3), and it adds re-dispatch loops that a human has to
     break by hand (C2, C4). An autonomous run that livelocks or ends silently on
     a stuck issue costs more human attention than the drift it fixed."

## Ledger

Where one row has several raisers, each raiser's declaration is recorded
separately. Only a raiser releases. A raiser that did not re-declare a row in
round 3 is recorded as having made no round-3 declaration; its last
declaration stands.

### Round-1 findings

| id | raiser | round | section of the subject | consequence if it ships | evidence | status | revision |
|---|---|---|---|---|---|---|---|
| A1 / P4 / E4 | i26-arch, i26-pushback, i26-evidence | 1 | What happened, bullet 2 | the collision persists under either option | same-milestone repro: w1 and w2 both get `b1` from `next` | **A1 released** (`i26-arch`): r2 places duplication in one milestone; R1+R2 remove the convergence, "only if A9 is fixed". **P4 released** (`i26-pushback`): problem §2 restated; R3 checks the actor. **E4 released** (`i26-evidence`): R1+R2 give distinct issues, measured. **r3:** A1 "still released", re-attacked: "It holds only if A12 is fixed by re-dispatching under a token rather than by any path that leaves a worker without an assignment." P4 "stay[s] released": R5. E4: no round-3 declaration | d2de72f |
| E4 | i26-evidence | 1 | (absent) | git-zhi's start is not mutually exclusive under concurrency | 20/20 concurrent `--state start` pairs both exit 0, one transition survives; `storage.WriteEntity` writes the ref unconditionally, no CAS. Sequential second start fails (exit 1) from 20 ms apart | **released** (`i26-evidence`): filed as git-zhi#35, with R3 as mitigation; the residue is E10. **r3:** no declaration; r26 re-measured both starts exiting 0 in 80/80 | 7b9287d |
| A2 / P4 | i26-arch, i26-pushback | 1 | Proposed change | a worker that lost the start still does the work, as on pvm | sequential second start: `cannot start: issue is in-progress`; Step 2 says nothing about a refused start | **A2 released** (`i26-arch`): R3 checks post-state, and C3 found no double ownership; residue moved to A10. **P4 released** (`i26-pushback`), as above. **r3:** A2 "still released", re-attacked: R5 "is stronger than r2's R3"; "D1 is still unresolved between participants". P4 stays released | d2de72f |
| E9 | i26-evidence | 1 | Where it goes | execute's start paragraph overstates what start guarantees | given E4, "this records a transition … which is what makes the selection above work" is not true under concurrency | **released** (`i26-evidence`): R5 commits to correcting it; wording is to be checked at review. **r3:** no declaration (r3's R9 cites E9) | d2de72f |
| P2 / E6 | i26-pushback, i26-evidence | 1 | Proposed change, option 1 | only the first pick is scoped; a worker that finishes its issue drifts off the milestone again | Step 4 returns to Step 2; measured drift to another milestone and collision there | **P2 released** (`i26-pushback`): R1 names the finish trigger; residue raised as P8. **E6 released** (`i26-evidence`): R1, R2 and R4 answer it; in the walkthrough a surplus worker stood down. **r3:** P2 stays released, "superseded by R1's lifecycle". E6: `walk.sh` re-run gave an identical result, which "re-proves E1, E2, E5 and E6" | d2de72f |
| A3 / P3 / E7 | i26-arch, i26-pushback, i26-evidence | 1 | Proposed change, option 1 | a hand-built ready set admits in-progress issues and misses cross-milestone blockers | `issue list --ready --milestone <m> --format json` already returns the ready set on 0.7.2 | **A3 released** (`i26-arch`): R1 names the query (C1). **P3 released** (`i26-pushback`): the query excludes in-progress issues, confirmed. **E7 released** (`i26-evidence`), superseded by E11. **r3:** A3 "still released, with A14". P3 stays released: R3 keeps git-zhi's query and adds E11's filter. E7: no declaration | d2de72f |
| A4 / P1 | i26-arch, i26-pushback | 1 | Proposed change, option 1; Where it goes | contradicts accepted 0002 without amending it | 0002 names bare `next`; "Where it goes" lists only execute.md | **A4 released** (`i26-arch`): r2 stays inside 0002 and R2 adds the stop rule; the new orchestrator role relative to `execute.md` is A9. **P1 released** (`i26-pushback`): no frozen text falsified. **r3:** A4 "still released; D3 judged: within 0002, no amendment". P1 "stays released on its subject, which is selection"; the R7 contradiction "is raised as P18 rather than by re-holding P1". See D3, D6 | d2de72f |
| A5 / P5 / E8 | all three | 1 | Proposed change, option 2 | a criterion satisfiable only by another repository; and if modelled on `--label` it loses resume-own and assignment preference | `--label` measured to ignore actor; ~20–40 lines inside `headForActor` | **A5 released** (`i26-arch`): out of scope, routed through `git_zhi_min_version`; git-zhi#35 records the `--label` hazard. **P5 released** (`i26-pushback`), see the P5 row. **E8 released** (`i26-evidence`): git-zhi's to do; nothing waits on it. **r3:** A5 "still released". P5 stays released. E8: no declaration | 7b9287d |
| P5 | i26-pushback | 1 | Proposed change | "either, in order of preference" commits to nothing and has no acceptance conditions | text of the subject | **released** (`i26-pushback`): r2 commits to one shape and has an Acceptance section; its gap is P11. **r3:** stays released, "Acceptance is committed" | d2de72f |
| A6 / P6 | i26-arch, i26-pushback | 1 | "dispatch no more workers than ready issues" | correct at dispatch, but a one-root chain runs serially forever unless the cap is re-evaluated as issues close | composes with `wip_limit` | **A6 released** (`i26-arch`): R4 re-evaluates on close; its wording is raised as A11. **P6 held** (`i26-pushback`) in round 2, on P9. **r3:** A6 "still released" (R4). **P6 released** (`i26-pushback`): "The cap counts live workers, never the ready set." R4's arithmetic against `wip_limit` "has a different defect, P17. It is not P6's" | d2de72f |
| P7 | i26-pushback | 1 | Proposed change | an assigned issue can stop being ready before its worker starts it | largely covered by A2's refused-start rule | **released** (`i26-pushback`): R3 and R2 cover both cases; the leftover assignment is P10. **r3:** stays released: R5 | d2de72f |
| E3 | i26-evidence | 1 | What happened, bullet 1 | none: the subject's "still blocked" claim is refuted | `next` never returned a blocked issue; `blocked_by` keeps listing done blockers, the likely misreading | **released** (`i26-evidence`): r2 withdraws the claim. **r3:** no declaration | 7b9287d |
| A7 | i26-arch | 1 | (absent) | two concurrent runs in one repository can clear each other's assignments | 0002 places concurrent runs out of scope | **released** (`i26-arch`), as record-only. R1's extra assignments grow the exposure; still out of scope. **r3:** "still released, record-only. R6 clears assignments within a run, under this run's own tokens" | d2de72f |

Round 1 also cited E1, E2, E5 and A8 in its axes without giving them rows. In
round 2, `i26-evidence` released E1, E2 and E5, and `i26-arch` released A8. In
round 3, `i26-evidence`'s `walk.sh` re-run "re-proves E1, E2, E5 and E6", and
`i26-arch` declared A8 "still released".

### Round-2 findings

| id | raiser | round | section of the subject | consequence if it ships | evidence | status | revision |
|---|---|---|---|---|---|---|---|
| A9 | i26-arch | 2 | R1, R2, Where it goes | Steps 3.5 to 4 and Loop control assume one self-looping agent. If the worker runs the gate, a second assignment can break per-worker WIP of one. If the orchestrator runs it, its reopen and start strand the issue under the orchestrator's identity. cf. F1, P8, F6 | C4: start without `ZHI_ACTOR` lands under `human:t`; then `next` as r-2 gives `no actionable issues`, and r-2's start is refused. A dispatched subagent has no agent-dispatch tool (weak, harness-specific) | **r3: held, "narrowed to one question"** (`i26-arch`). "The identity half is closed." Open: R1 puts review inside the worker, which may not be able to dispatch Step 4's lenses; "r3 does not say which party dispatches the lenses". cf. P12, F11, C3 | r2 |
| A10 | i26-arch | 2 | R3; Acceptance bullet 2 | "A refused … start means the issue is not its issue" makes a re-dispatched worker stand down from its own resumed in-progress issue. The walkthrough would test only refusal | C2: start on own in-progress A1 refused; `next` as r-1 returns A1; 0002 "Only the abandoned identity gets the issue back" | **r3: released** (`i26-arch`): R5 bullet 1 "meets it by name" | r2 |
| A11 | i26-arch | 2 | R4 | "never more live workers than ready issues" counts the wrong quantity; an implementer may retire live workers. cf. P9, F6 | C1: in-progress issues leave the ready set | **r3: released** (`i26-arch`): "The cap counts live workers, never the ready set" is "the correct quantity" | r2 |
| E10 | i26-evidence | 2 | R3 | an immediate post-start check can pass for both workers. R3 should check after a short settle and re-check before close or push. cf. F4 | immediate check: both passed in 3/80 concurrent pairs (r13 1/20, r15 2/60); after 0.5 s: exactly one owner in 110/110 (r14+r15). Non-owner `--state done --force` succeeds | **r3: released** (`i26-evidence`): R5 adds the settle, the retry and the re-check before done. Red re-confirmed (r26 2/80), green confirmed (r25 0/100). Residue raised as E13 | r2 |
| E11 | i26-evidence | 2 | R1 | R1's query includes assigned and reopened issues; the skill must filter `select(.assigned==null)`, and R1 should name it. A reopened issue would go to any free worker | r18: assigned b2 and reopened b5 returned; `--assigned ""` does not filter; `--assigned none` returns `[]` | **r3: released** (`i26-evidence`): R3 filters to no assignment. **The raiser withdrew E11's reopened half**: "The generalisation was wrong; the measurement was right for its case." r18's b5 had never been assigned (r20). See D2 | r2 |
| E12 | i26-evidence | 2 | R3 | a read racing a write can fail. R3 must treat a failed read as "unknown, retry", neither lost nor won | r15: `issue show` failed 2/15 with `ref file is empty`; controls 0/40, 0/40, 0/30. Inferred, not traced, to the same non-atomic write as git-zhi#35 | **r3: released** (`i26-evidence`): R5 retries a failed read. 0 read failures across r22 to r26; "the failure is intermittent" | r2 |
| P8 | i26-pushback | 2 | R1 triggers, with R2, R3, R4 | a stood-down worker's request matches none of R1's triggers. Loop control's "ready set is empty" stop ends the run early, while work is in flight. cf. A9, F6 | R1's trigger list; execute.md L82 | **r3: released** (`i26-pushback`): R6 settles every returning worker; R8 replaces the stop. "P16 is a new interaction between R8 and R3, not P8's residue" | r2 |
| P9 | i26-pushback | 2 | R4 | live workers and ready issues are disjoint sets; once workers start, the cap is violated and the run under-parallelises. cf. A11, F6 | `issue list --ready` is pending or reopened; in-progress `a1` absent | **r3: released** (`i26-pushback`): "Live workers are no longer compared with the ready set" | r2 |
| P10 | i26-pushback | 2 | R1, with R2, R3 | an assignment held by this run's stood-down or exited worker is never reclaimed; the issue is stranded until a new run. cf. F10 | reclamation clears only other runs' tokens (execute.md L118–121); probe: `a1` in progress under `x-1`, still assigned to `x-3` | **r3: released** (`i26-pushback`): "The *assignment* half of stranding is closed. The *in-progress* half is P13" | r2 |
| P11 | i26-pushback | 2 | Acceptance, bullet 2 | the walkthrough can pass without exercising the finish trigger, widening, stand-down service or run end. cf. F8 | text of the subject; a refused start does not arise under R1 and must be induced | **r3: released** (`i26-pushback`): "It exercises what I asked." It exercises none of R6's death, reopen or integration paths, noted under P13–P15 | r2 |
| F1 | i26-fresh | 2 | R1, R4, Where it goes | dispatched subagents return and end, so "each time a worker finishes" has no mechanism. R4's re-evaluation degrades to once per batch. Step 4's lens dispatch and reopen need an owner. cf. A9 | execute.md l.131-132, l.169, l.298, l.356; dispatching-parallel-agents "When agents return" | **r3: released** (`i26-fresh`): R1 and R4 give "finishes" a mechanism; the leftover is raised as F11 | r2 |
| F2 | i26-fresh | 2 | R4 | an issue that is chain-ready is not code-ready: downstream dispatch can start from a tree without its upstream's commits, or build on work later reopened | execute.md l.154-156, l.256-257, l.367-369; `ReadySet` treats done upstream as satisfied | **r3: released** (`i26-fresh`): R3's integration gate and R6's integrate-on-reviewed "close both halves". cf. A14, E15, P16, C2 | r2 |
| F3 | i26-fresh | 2 | R2, R3 | a stand-down leaves the issue in progress under the wrong actor, absent from the ready set; the milestone cannot complete. cf. A9, P10 | scratch: start without `ZHI_ACTOR` → `human:T`, absent from `issue list --ready`, second start refused; 0002 "Breaking it costs a stranded issue" | **r3: held** (`i26-fresh`): start-up reclamation clears only assignments and no verb returns an in-progress issue to the pool (`reopen` refused; pause then resume leaves it absent from the ready set). "The subject must allow a handover outside the pool and an orchestrator transition on a dead worker's issue." cf. A12, E14, P13, C1; see D8 | r2 |
| F4 | i26-fresh | 2 | R3, Out of scope | R3 does not mitigate git-zhi#35; a single read right after the write cannot detect a lost update. Within a run, R1+R2 already prevent the case. See D1 | `WriteEntity`: parent from the current ref, then ref update, no CAS; interleaving read(A), read(B), write(A), check(A), write(B), check(B) | **r3: released** (`i26-fresh`): R5 claims only to narrow the window, "and that claim has been withdrawn" (the false assurance). "**D1 is resolved for me.**" | r2 |
| F5 | i26-fresh | 2 | R2, R3; Step 2 identity paragraph | `export ZHI_ACTOR` does not survive between Bash calls, so calls resolve to the git author; R2 and R3 trip on every issue and each trip strands one | scratch: exported in one call, empty in the next; the Bash tool's own statement; execute.md l.103-105 | **r3: released** (`i26-fresh`): R7. The piped `echo ... \| git zhi issue edit --body -` in Step 4 is included, as implementation detail | r2 |
| F6 | i26-fresh | 2 | R1, R4, against Loop control | the ready set is empty whenever every ready issue is held, so Loop control ends the run with workers running; R4's cap shrinks below the live count. cf. P8, P9, A11 | execute.md l.80-89; `ReadySet` filter; in-progress A absent from `issue list --ready` | **r3: released** (`i26-fresh`): R8 and R4 | r2 |
| F7 | i26-fresh | 2 | R5; "Every requirement stays inside decision 0002" | if Key Constraints keeps "Each worker selects with bare `git zhi next`", it stays false and hides the shift that the orchestrator now selects. Not an amendment to 0002. See D3 | 0002 "The execute loop", "Assignment is a hint"; execute.md l.439 | **r3: released** (`i26-fresh`): R2 says the orchestrator chooses; R9 must make Key Constraints say so | r2 |
| F8 | i26-fresh | 2 | Acceptance | the conditions can pass while the problem persists: (a) the other milestone must lead the critical chain; (b) cover finish-and-reassign; (c) a sequential walkthrough cannot exercise the race; (d) test the reachable start-under-wrong-actor case, not refusal; (e) the one-worker branch is uncovered; (f) a CLI walkthrough does not show an agent following the skill. cf. P11 | `headForActor` falls back to `CriticalChain()`; scratch: unassigned worker got X1 | **r3: released** (`i26-fresh`): (a), (b), (d), (e) are now conditions; (c) sits with git-zhi#35; (f) noted, "I note this but do not block on it" | r2 |
| F9 | i26-fresh | 2 | R1 | `git zhi list --ready --format json` carries no `assigned`; the subject names the right listing, but the how-to table names the other | scratch: `list --ready` → `{"ready_set":[{id,title}]}`; `issue list --ready` includes `assigned` | **r3: released** (`i26-fresh`): deferred to the implementing issue | r2 |
| F10 | i26-fresh | 2 | R1, R2 | an issue reopened at Step 4 stays assigned to worker *n*; a newly dispatched *m* cannot be assigned it, and R2 makes *m* refuse it. See D2; cf. P10 | execute.md l.122-125, l.335-341; `headForActor` step 3 | **r3: released** (`i26-fresh`): D2 measured; under R1 the reopen stays with the assigned worker, and R6 clears on unsuccessful return | r2 |

Also recorded, not raised as a finding: `i26-arch` noted in round 2 that
`skills/how-to-use-git-zhi/how-to-use-git-zhi.md`'s intent table still says
`next [--label <l>]` with `ZHI_ACTOR` returns "the HEAD issue for this worker",
which round-1 O6 falsified. r3 lists it out of scope as a separate crochet
defect; `i26-arch` in round 3: "which is what I asked for". F9 touches the same
table. `i26-cold`'s C9 concerns a different part of that file, its `ZHI_ACTOR`
export guidance.

### Round-3 findings

| id | raiser | round | section of the subject | consequence if it ships | evidence | status | revision |
|---|---|---|---|---|---|---|---|
| A12 | i26-arch | 3 | R6 bullet 2; R1 | a worker that dies mid-issue leaves it in progress under its token. Clearing the assignment does nothing for it, and start-up reclamation also clears assignments only, so the mechanism R6 cites does not exist. The milestone cannot complete, and R8 reports the issue "held outside this run", although this run holds it. Repair named in 0002: re-dispatch under the dead token, which needs R1 to say "a worker re-dispatched for the same issue reuses that issue's token". cf. E14, P13, F3, C1; see D8 | G1: after `--unassign`, `{"state":"in-progress","assigned":null,"last":"agent:run-1"}`, pool `[]`, `no actionable issues for actor agent:run-2`. G2: `next` under the dead token returns the issue. G3: pause and resume by another actor transfers ownership, "undocumented in 0002", "I would not choose it" | open | r3 |
| A13 | i26-arch | 3 | R7 | R7 contradicts the letter of 0002 ("exports the identity once at dispatch"; "Identity is declared once, for the process, not per command") though not what it decided, so a reader of 0002 finds the skill doing what it rules out "with no record of why". Per-command declaration re-creates "re-exporting is the only way to break it" on every command. The subject or implementing commit should state the premise failure. "No amendment, in my view"; whether the sentence must live in an amending decision "is a fair question for the human". cf. P18, C9; see D6 | 0002 text; F5; the Bash tool's statement that shell state does not persist | open | r3 |
| A14 | i26-arch | 3 | R3, last sentence; R6 bullet 1 | if "integrated" is known only from the orchestrator's memory, a run that dies between a worker's return and integration leaves a blocker done but unmerged, and the next invocation dispatches downstream onto a tree without it: F2 arriving through resume. Requirement: "integrated" is "a fact read from git at dispatch time, e.g. the worker's branch is reachable from the integration target, never a flag the orchestrator remembers". cf. E15; see D5 | Key Constraints "resumes from the current chain state" | open | r3 |
| E13 | i26-evidence | 3 | R5, "re-checks ownership before `done` and before pushing" | R5's ownership predicate (in progress, latest actor is the worker) is false after `done`, so under R1 a push after `done` reads as "lost". Fix: the pre-push check is "the latest transition's actor is me", independent of state; or push before `done` | r27: start true; done false; reopen false; restart true; another actor reopens, false | open | r3 |
| E14 | i26-evidence | 3 | R6, "reclaimed the way start-up reclamation already reclaims stale tokens" | after start-up reclamation a dead token's issue stays in progress, outside the pool, refusing start and resume. Only pause then resume by a fresh token takes it back; cancel discards it. R6 must name the takeover, and the fresh worker's dispatch must expect `next` not to return the issue, "Otherwise R2 makes it stand down, and R8 ends the run with the issue held". cf. A12, P13, F3, C1; see D8 | r28: found via `issue list --state in-progress --milestone m` and `.transitions[-1].actor`. As new-1: `next` returns y; start refused; resume `cannot resume: a measurement session is already open`; pause then resume succeed, actors `[dead-1, new-1, new-1]` | open | r3 |
| E15 | i26-evidence | 3 | R3, "only when every blocker's branch has been integrated" | integration is not observable through the CLI. It is observable through git, using the CLI's `sessions[-1].end_sha` with `merge-base --is-ancestor`, which gives a false "no" for squash and rebase merges. "The subject should not imply a CLI query exists. The orchestrator's own record of what it integrated is the robust source." cf. A14; see D5 | r29: `no` before merge, `yes` after; r30: `no` after `merge --squash` | open | r3 |
| E16 | i26-evidence | 3 | R8, "reported by name" | the default `issue list --milestone` omits reopened issues, so a run-end report built on it could report a milestone as finished. Use `git zhi list --milestone`, or `issue list --all` filtered. `issue list --state` help lists `reopened` but the flag rejects it, a git-zhi help defect for #35 or a separate filing | r33: `list --milestone` `["reopened"]`; `issue list --milestone` `[]`; `--all` `["reopened"]`; `--state reopened` rejected | open; "an implementation detail for R8's report" | r3 |
| P12 | i26-pushback | 3 | R1, "carries that issue through … close, review, and every reopen cycle"; Step 4 | a worker that cannot dispatch either applies the lenses itself, breaking 0003's composition rule, or skips the gate. If instead the orchestrator dispatches review, a reopen falls to the orchestrator, which R1 forbids. The subject has to pick: (1) review in the orchestrator, reopen re-dispatched under the same token; (2) the worker dispatches where it can; (3) inline lenses declared acceptable, "which needs a ruling against 0003's composition rule". "Which one is the human's ruling, not implementation." cf. A9, F11, C3 | probe 3: this participant, a dispatched subagent, has no agent-dispatch tool; execute.md L298 | open; "high, conditional": a harness where subagents can dispatch drops it to a note | r3 |
| P13 | i26-pushback | 3 | R6; R1; R2 | every worker that dies mid-execution ("Context exhaustion is the common case") leaves its issue permanently in progress under a dead token; R8 reports it as "held outside this run", which is wrong. The mechanisms that do move ownership are forbidden by R1 (orchestrator) or by R2 (a fresh worker has already stood down). "The 0002-native fix" is re-dispatch under the dead token, reading R1's token as one per issue. No walkthrough condition kills a worker. cf. A12, E14, F3, C1; see D8 | probe 1: `--assign ""` leaves it in progress; start and reopen refused; `next` for others skips it; pause and resume by another actor make it the owner. execute.md L118–121; 0002 "Only the abandoned identity gets the issue back from `next`" | open; "high", "Unconditional" | r3 |
| P14 | i26-pushback | 3 | R6 bullet 1; R3; R8 | a worker that dies between close and review returns an issue done but unreviewed. R6 clears its assignment; it never re-enters the pool, review never runs, and it is never integrated, so its dependents never dispatch. The milestone "looks nearer completion than it is", and a mandatory gate is skipped without a record. R6 needs a third case. cf. C2, F14 | execute.md L256–258: `--state done` runs before Step 4 | open; "medium–high" | r3 |
| P15 | i26-pushback | 3 | R6 bullet 1; R3 | a merge conflict on integration has no instruction. The orchestrator either resolves it itself, putting unreviewed code it wrote on the integration branch under no worker's identity, or leaves it unintegrated, stranding the issue as in P14. Needs a requirement that a failed integration goes back through a worker and the orchestrator never writes the resolution | execute.md L146–165; reasoned from the text, no conflict reproduced | open; "medium", "Unconditional, given R6" | r3 |
| P16 | i26-pushback | 3 | R3; R4; R8 | the pool is chain readiness, which counts a done blocker as satisfied, so an issue behind a done but unintegrated blocker is in the pool but not dispatchable. R4 says dispatch, R3 says don't, and R8's "pool is empty" never becomes true: the run "spins or hangs". Fix: the pool is the dispatchable set. cf. C2 | the text of R3, R4 and R8 | open; "medium", "Unconditional" | r3 |
| P17 | i26-pushback | 3 | R4, "live workers are below `wip_limit`" | git-zhi enforces `wip_limit` chain-wide, so in-progress issues outside the run (a human's, another milestone's, this run's dead tokens) use it up. R4 dispatches, start is refused, R5 stands down, R6 clears, R4 re-dispatches: "a tight loop of fresh workers". The right quantity is `wip_limit` minus in-progress issues not held by this run's live workers. "R4's count is the third wrong quantity in three revisions." cf. C4 | probe 2: `WIP limit reached: 2 issue(s) already in progress (limit 2) … or pass --force` | open; "medium–high, conditional": inert at the default `wip_limit` 0; drops to low if the human rules crochet runs only without a limit | r3 |
| P18 | i26-pushback | 3 | R7; preamble, "All of this stays inside decision 0002" | the preamble's claim is false, and an implementer who trusts 0002 over the subject keeps the export, so F5 recurs. "Resolution is the human's, not implementation": (1) a defect repair in 0002, since its premise that an export persists is false; or (2) amend 0002. "Either way, the preamble must stop saying nothing in 0002 moves." cf. A13, C9; see D6 | 0002 "The execute loop" and "Mint `ZHI_ACTOR` **at dispatch**"; execute.md L104 | open; "medium" | r3 |
| F11 | i26-fresh | 3 | R1 | a worker cannot run Step 4 as written: it reviews its own commits or skips the gate, every time, so the per-issue review is "structurally unmet in the parallel branch, and only there". The subject should decide who runs Step 4; one option is the orchestrator dispatching reviewers on return, with a reopen re-dispatching the same token, which relaxes R1's "never runs a transition" for reopen. cf. A9, P12, C3 | execute.md l.298-302, l.320-323; this subagent's tool list | open | r3 |
| F12 | i26-fresh | 3 | R1 (Step 4, "Record the tier and the outcome") | the only milestone write replaces the whole body, and a worker's read-compose-write spans minutes, so concurrent workers silently drop each other's checklist entries, the only record distinguishing "reviewed" from "review never ran". Writes to shared milestone state should be the orchestrator's, serially on return. cf. C5 | `milestone edit --help`; execute.md l.354-369 | open | r3 |
| F13 | i26-fresh | 3 | "With one worker … a cap of one" | two readings. If a subagent is still dispatched, it is `wip_limit` 1 with F11's problem. If not, one agent is orchestrator and worker, and R1, R6 and R5 lose their referents. "The acceptance condition 'the one-worker branch is run too' cannot be checked until this is decided." | execute.md l.130, l.167 | open | r3 |
| F14 | i26-fresh | 3 | R6 with R4 and R8 | Step 3's 10-pass valve counts in the worker's head, so a fresh worker re-dispatched for a stalled issue starts again from pass 1 and R8's end may never arrive. ARCHITECTURE.md says an issue is "reported as stuck"; R6 has no stuck outcome. Suggests a third outcome, stuck, which reports the issue and removes it from the pool. cf. C2, P14 | execute.md l.228-236, l.345-346; ARCHITECTURE.md "Execute nests two loops" | open | r3 |
| F15 | i26-fresh | 3 | R2; R5 bullet 1 | a fresh token per issue never has its own in-progress issue on its first `next`, so the bullet "is either dead text or the sign of a missing re-dispatch-same-token path, which F3 and F11 would both want". cf. C7; see D4 | R2 and R5 text | open; "minor" | r3 |
| F16 | i26-fresh | 3 | (Step 6) | Step 6's per-issue report exists only in worker return messages, so the orchestrator has to collect it on return | — | open; "minor, implementation" | r3 |
| C1 | i26-cold | 3 | R6; R1 | an in-progress issue has no transition back to the pool. The exits are `cancel` (terminal) and `done --force` then `reopen` ("which falsifies the record"), both orchestrator transitions that R1 forbids. The issue stays stranded, R8 reports it held and ends, Step 5 never runs, and under a positive `wip_limit` it holds a slot for good. Fix shape: same-token re-dispatch, or an explicit exception to R1. cf. A12, E14, P13, F3; see D8 | `issue/state.go` transitions table; `cannot reopen: issue is in-progress, expected done`; `cannot mark done: session has 0 commits`; 0002 "one issue the scheduler will not surface to anyone but its original worker" | open | r3 |
| C2 | i26-cold | 3 | R6; R8; R3 | R6 and R8 have no stuck outcome. Reopens ≥ 3, the 10-iteration valve, an AC that cannot pass and a permission denial fall into "otherwise": re-dispatched without limit, or, for reopens ≥ 3, done, unreviewed and unintegrated, leaving dependents in the pool but undispatchable, so R8 never fires. Fix shape: a third R6 outcome, and R8 ends on "no dispatchable issue". cf. F14, P14, P16 | execute.md Step 3 valve, Step 4 "reopens >= 3", Loop-control stop list; ARCHITECTURE.md "reported as stuck" | open | r3 |
| C3 | i26-cold | 3 | R1; Step 4 | in Claude Code a dispatched subagent does not get the agent-dispatch tool, so every review is run by the agent that wrote the commits, "the failure the gate exists to catch". Fix shape: the orchestrator dispatches the reviewer on return. "This reopens R1's 'end to end', so it has to be decided, not patched." cf. A9, P12, F11 | execute.md Step 4; 0003 as cited there; its own tool set has no Agent/Task tool | open; "C3 depends on the platform. If a harness does let subagents dispatch, C3 weakens to a cost question" | r3 |
| C4 | i26-cold | 3 | R4 | any in-progress issue outside the run takes a `wip_limit` slot, giving refusal, stand-down, clear and immediate re-dispatch: "a dispatch livelock". The walkthrough never sets `wip_limit` above zero. Fix shape: cap at `wip_limit −` in-progress issues not held by this run, or treat a WIP refusal as "stop dispatching". cf. P17 | `checkWIPLimit` counts `StateInProgress` across `LoadAllIssues`; `WIP limit reached: 1 issue(s) already in progress (limit 1)` | open | r3 |
| C5 | i26-cold | 3 | R1; Step 4 | parallel workers write the milestone body, and `--body` replaces it, over a window that "spans the agent's turn". A dropped entry makes a reviewed issue read as never reviewed, and under R6 its branch is not integrated, feeding C2. Fix shape: the orchestrator writes entries from returned reports, serialised. cf. F12 | `milestone edit` help "replace the body"; execute.md Step 4; git-zhi#35 Cause | open | r3 |
| C6 | i26-cold | 3 | R5 | "R5 is over-specified against a race R2 has already removed": #35 needs two concurrent starts of one issue, and under R2 and R6 "no second starter exists". "This narrows the window of git-zhi#35" will mislead. Keep one part: a single read-back after start, by literal id, because an empty `$ID` makes `issue edit "" --state start` start the HEAD issue in another milestone, exit 0, which R1 to R9 do not otherwise prevent; the skill should say "pass the id literally; never through a variable". See D1, D7 | git-zhi#35 body; empty-ref probe: `Started …: other-ms` while the run's issue sat pending in m1 | open | r3 |
| C7 | i26-cold | 3 | R2; R5 | R1's fresh token per issue makes the resume-own branch unreachable unless the orchestrator re-dispatches with an old token, "which r3 never does (but C1's fix might)". `next` "only cross-checks an assignment the orchestrator just wrote"; keeping it to keep 0002's sentence true "is the wrong trade. Amend 0002 instead". "If it is kept, say what it is for." cf. F15; see D3, D4 | `headForActor` steps 1 and 3; R1 and R2 text | open | r3 |
| C8 | i26-cold | 3 | R1, "its own run token as identity" | in execute.md the run token is `<run-id>` and workers are `agent:<run-id>-<n>`. Read literally, a new run-id per worker means a later invocation's start-up rule cannot tell this run's workers from a dead run's. Fix: "its own worker identity, `agent:<run-id>-<n>`" | execute.md "Worker identity — once per run"; 0002 "worker ids carry the run's own opaque token" | open | r3 |
| C9 | i26-cold | 3 | R7; Where it goes | `how-to-use-git-zhi.md` ("A process declares itself by exporting") stays false, and it is the file agents consult before every `git zhi` call. 0002's "once at dispatch / not per command" is contradicted by a skill revision, "which is prose overriding an accepted decision". "The fact behind R7 is right." cf. A13, P18; see D6 | how-to-use lines on `ZHI_ACTOR`; 0002 "The execute loop"; ARCHITECTURE.md on immutability | open | r3 |
| C10 | i26-cold | 3 | Acceptance | the walkthrough passes with C1, C2, C4 and C5 present. "The run ends with every milestone issue done" cannot hold once R8's blocked or held reporting is exercised. Pinning "on git-zhi 0.7.2" decays; say "on the declared `git_zhi_min_version`". cf. P13, P14 (acceptance gaps) | the Acceptance section; coding-conventions "no criterion should be pinned…" | open | r3 |
| C11 | i26-cold | 3 | Where it goes (parts of execute.md it does not reach) | `--step` has no stated meaning under parallel refill; Loop control's "keep going in the same turn" against an orchestrator waiting on workers; Step 5's "When all issues are closed" against R8 ending with issues held or blocked. "Each leaves the implementer to decide something the subject claims to have specified." | execute.md `--step`, Loop control, Step 5 | open; "small" | r3 |

Also recorded, not raised as findings, from round 3:

- `i26-pushback`'s growth check: "I found no clause that answers nothing." It
  counts R6's integration bullet as answering F2.
- `i26-pushback`: any actor can take ownership of an in-progress issue with
  `pause` or `resume`, so R5 treats a later pause or resume by anyone as a loss.
  "Not a crochet finding."
- `i26-pushback`: if P14 and P15 are answered, the Acceptance end condition
  should be "done and integrated".
- `i26-pushback`: R2's sentence "whether that still counts … is for the
  participants" is "a question in a requirements list. It must be gone before
  refinement."
- `i26-arch`: the Acceptance walkthrough "should include one dead-worker
  re-dispatch so A12 is exercised".
- `i26-arch`, adjacent and out of scope: an in-progress issue left by a
  *previous* run's dead token is unreachable by a new run; whether a new run may
  adopt it is "0002's Open Question territory and its own decision".

### Disagreements

Recorded as each side stated them. A disagreement is marked resolved only where
every party to it says so in its own report; the drafter resolves none.

- **D1. Whether R3's (now R5's) post-start check detects a lost start.**
  **Not resolved.**
  - `i26-fresh` (F4), round 2, reading the source: `WriteEntity` has no
    compare-and-swap; "a single read right after the write cannot detect a lost
    update". Round 3: "**D1 is resolved for me.**" R5 now claims only to narrow
    the window. The source argument still shows an immediate check cannot be
    sufficient; the settled 110 of 110 "is evidence that the narrowing is real
    on local disk, and it is not more than that". It names two remaining
    disagreements, the two immediate-check counts and the minimum safe settle,
    which "belong to the implementing issue".
  - `i26-arch` (A2, C3), round 2: 20 of 20 concurrent trials checking
    immediately, exactly one owner. Round 3: "D1 is still unresolved between
    participants". It did not re-examine R5's settle interval or D1.
  - `i26-evidence` (E10): round 2, immediate both-pass 3 of 80, settled 110 of
    110. Round 3: immediate both-pass 2 of 80 (r26); settled exactly one owner
    in 100 of 100 (r25); its full worker harness (r22 to r24) "did not go red",
    which "shows the race is sensitive to timing, not that it is absent".
    "'Narrows, does not close' is accurate."
  - `i26-pushback`: did not re-run the race in round 3.
  - `i26-cold` (C6) holds a different position on whether the race arises at
    all; see D7.
- **D2. Whether a reopened issue keeps its assignment. Resolved**: every party
  says so in its own report.
  - r3's author measured it before r3: assigned `a` ended
    `["reopened","agent:w1"]`; unassigned `b` ended `["reopened",null]`.
  - `i26-evidence`, the raiser of the opposing side, re-measured (r20) and
    withdrew E11's reopened half: "D2 reproduces: reopen does not touch the
    assignment." "The generalisation was wrong; the measurement was right for
    its case."
  - `i26-arch`: "D2 agrees with my C5."
  - `i26-fresh`: "D2 is measured (an assigned issue keeps its assignment
    through reopen)"; "D2, which I accept as measured".
  - `i26-pushback`: "D2 (a reopen keeps its assignment) is consistent with R1".
  - `i26-cold` did not reproduce D2 and was not a party.
- **D3. Whether "Workers still select with bare `next`" is true, and whether R2
  needs an amendment to 0002. Not resolved.**
  - `i26-arch`: "D3 judged: within 0002, no amendment." "What 0002 decided is
    that identity and the per-worker head come from git-zhi, not that the
    orchestrator may not choose." F7's point stands as text.
  - `i26-pushback`: R2 "sits inside 0002", conditional on R9 making Key
    Constraints say the orchestrator chooses.
  - `i26-fresh`: "my view is unchanged: under R2, 'selects with bare `next`'
    describes the handover, not the choice, and no decision is amended."
  - `i26-cold`, new in round 3: "0002 states the opposite of R2 and R7." "That
    question has a procedural answer: an amending decision, written both ways."
    "They still need an amendment rather than a reading." C7: `next` is now
    "ceremony"; "Amend 0002 instead".
  - Round 2's "All three agree that no decision is amended" no longer describes
    all participants.
- **D4. Whether a refused or resume-own start is reachable within a run. Not
  resolved.**
  - The fact is not contested: r3's author measured that a worker starting its
    own in-progress issue is refused and `next` returns it; `i26-arch` ("D4 is
    the same as my round-2 C2") and `i26-evidence` ("Confirmed") agree.
  - `i26-fresh` (F15): R5 bullet 1 "is unreachable as dispatched"; a fresh token
    per issue never has its own in-progress issue on its first `next`.
  - `i26-pushback`: R5's resume-own bullet "is reachable only when a worker
    re-enters selection under the same token", within one worker's life or
    under P13's same-token replacement. "That is consistent, and worth saying."
  - `i26-cold` (C7): unreachable unless the orchestrator re-dispatches with an
    old token, "which r3 never does (but C1's fix might)".
  - `i26-arch` (A10 released; A12, G2): re-dispatched under the dead token,
    `next` returns the issue and "R5 bullet 1 resumes it without a start".
- **D5. Where "integrated" is read from (new in round 3). Not resolved.**
  - `i26-arch` (A14): "a fact read from git at dispatch time … never a flag the
    orchestrator remembers"; otherwise a dead run loses idempotency. "How it is
    read is the implementing issue's; that it is derivable is the subject's."
  - `i26-evidence` (E15): the git route gives a false "no" for squash and
    rebase merges; "The orchestrator's own record of what it integrated is the
    robust source." "Fine to leave to the implementing issue."
  - `i26-pushback` (P14): where "reviewed" is read from is implementation
    detail.
- **D6. Whether R7 needs an amendment to 0002, or the human's ruling (new in
  round 3). Not resolved.**
  - `i26-arch` (A13): "no amendment, in my view"; "I hold it to be a premise
    failure to record, not a position to reverse." Whether the sentence must
    live in an amending decision "is a fair question for the human".
  - `i26-pushback` (P18): "Resolution is the human's, not implementation":
    defect repair in 0002 or amendment. "Either way, the preamble must stop
    saying nothing in 0002 moves."
  - `i26-cold` (C9, Axis 2): "departs from 0002 without an amendment"; an
    amending decision is needed.
  - `i26-fresh` released F5 on R7 and raised nothing on 0002. `i26-evidence`:
    R7 holds as written on 0.7.2, a behavioural claim only.
- **D7. Whether the race R5 addresses can arise under r3 (new in round 3). Not
  resolved.**
  - `i26-cold` (C6): under R2 and R6 "no second starter exists", so R5's settle,
    retries and re-checks "narrow a window the design never opens". It keeps a
    single read-back after start for the empty-`$ID` case. `i26-fresh` wrote in
    round 2 (F4) that "Within a run, R1+R2 already prevent the case"; its round-3
    report does not restate that.
  - `i26-evidence` measures R5 against two concurrent starts of one issue and
    calls "narrows, does not close" accurate; `i26-arch`: R5's claim "is the
    honest claim". Neither had read C6.
- **D8. How a dead worker's in-progress issue is recovered (new in round 3).
  Not resolved.** All five participants agree R6's cited mechanism does not
  recover it (A12, E14, P13, F3, C1). They differ on the repair:
  - `i26-arch` (A12): re-dispatch under the dead token; the pause-and-resume
    transfer works but "I would not choose it". The path belongs to the
    implementing issue; "that R6 names a real one does not".
  - `i26-pushback` (P13): "The 0002-native fix is to re-dispatch a replacement
    worker under the dead worker's token."
  - `i26-evidence` (E14): R6 must name the takeover by pause then resume under a
    fresh token, run by the fresh worker, because R1 forbids the orchestrator.
  - `i26-fresh` (F3): "The subject must allow a handover outside the pool and an
    orchestrator transition on a dead worker's issue." Specifying the verb is
    the implementing issue's job.
  - `i26-cold` (C1): either same-token re-dispatch, or an orchestrator
    transition stated as an explicit exception to R1.

### Where findings cluster

- **Round 1:** "Proposed change, option 1" and the subject's causal claim about
  the collision.
- **Round 2:**
  - **R3** (start confirmation): A10, E10, E12, F3, F4, F5, and D1, D4.
  - **R1/R2 together with what r2 leaves untouched** (Steps 3.5 to 4, Loop
    control, run end, stand-down service): A9, P8, P10, F1, F3, F6, F10.
    All four participants raised findings here independently; `i26-fresh` had
    not read the other reports.
  - **R4:** A11, P9, F2, F6, and the held P6. Three participants independently
    raised R4's count (A11, P9, F6).
  - **Acceptance:** P11, F8, and `i26-evidence`'s note that a sequential
    walkthrough does not exercise a lost start.
- **Round 3.** No participant read another's round-3 report. `i26-cold` read
  no earlier findings at all. Raised independently in this round:
  - **R6, a dead worker's in-progress issue cannot be recovered by the cited
    mechanism**: A12 (`i26-arch`), E14 (`i26-evidence`), P13 (`i26-pushback`),
    F3 held (`i26-fresh`), C1 (`i26-cold`). All five. See D8.
  - **R1, a worker cannot dispatch Step 4's lenses**: A9 held (`i26-arch`), P12
    (`i26-pushback`), F11 (`i26-fresh`), C3 (`i26-cold`). Four.
  - **R7 against 0002's text**: A13 (`i26-arch`), P18 (`i26-pushback`), C9
    (`i26-cold`). Three. See D6.
  - **R4 against chain-wide `wip_limit`**: P17 (`i26-pushback`), C4
    (`i26-cold`).
  - **Milestone-body writes by parallel workers**: F12 (`i26-fresh`), C5
    (`i26-cold`).
  - **No stuck outcome in R6**: F14 (`i26-fresh`), C2 (`i26-cold`); P14
    (`i26-pushback`) asks for a third R6 case for done-but-unreviewed.
  - **R3's integration gate against R4/R8's pool**: P16 (`i26-pushback`), C2
    (`i26-cold`).
  - **R3's integration condition, where it is read from**: A14 (`i26-arch`),
    E15 (`i26-evidence`). See D5.
  - **R5's resume-own bullet unreachable as dispatched**: F15 (`i26-fresh`), C7
    (`i26-cold`), and `i26-pushback`'s note. See D4.
  - **Acceptance exercises none of the new lifecycle failures**: P13 and P14
    (`i26-pushback`), C10 (`i26-cold`), `i26-arch`'s dead-worker note.
- By section, round 3 concentrates on **R6** (A12, E14, P13, P14, P15, F3, F14,
  C1, C2) and **R1** (A9, P12, F11, F12, C3, C5, C8).
- **`i26-cold`'s view, recorded as its own:** r3 "solves it with one move: R2,
  the orchestrator chooses from the milestone and assigns before dispatch. That
  one move fixes both symptoms", off-milestone drift and duplicate selection.
  "Most of the rest of r3 answers findings about the lifecycle around that
  move." It does not argue with the human's ruling, but "The subject has grown
  in the direction of the findings, not the direction of the problem."

## What the participants converged on, independently (round 1)

Not a revision; the author or their stand-in writes that. Recorded so the
revision answers named findings and does not grow the subject:

- the orchestrator assigns from `issue list --ready --milestone <m>` before
  **every** pick, not only at dispatch (P2, E6, A3);
- workers keep bare `next`, within 0002, and stand down if it returns an issue
  not assigned to them (A4, E5);
- a worker confirms its own start took (the transition's actor is itself)
  before doing any work (A2, E4);
- the worker cap is re-evaluated as issues close (A6, P6);
- option 2 and the start race (E4) are git-zhi's, filed there.

`i26-pushback` (growth check) found no scope in r2 beyond what the round-1
findings asked for. It notes that r2 drops r1's incident narrative, and that
the implementing issue should cite this ledger so the incident is not lost.

## Not checked

**Round 1:** the pvm chain itself; a full multi-worker `crochet:execute` run;
whether `blocked_by` can disagree with the graph's edges.

**Round 2, as each participant declared:**

- **`i26-arch`:**
  - decision 0003 beyond Step 4's composition reference;
  - `how-to-use-git-zhi` beyond the one row noted above;
  - the single-worker path, walked by no one;
  - a full multi-worker `crochet:execute` run;
  - whether subagents can dispatch subagents in other harnesses.
- **`i26-evidence`:**
  - its race counts come from small runs on local disk, not a rate estimate;
  - the minimum safe settle;
  - its walkthrough simulates agents with interleaved shell functions. It
    shows the rules are expressible on 0.7.2, not that an LLM worker follows
    them.
- **`i26-pushback`:**
  - did not re-run the concurrent-start race;
  - re-read only 0002's selection and assignment sections;
  - did not re-check `how-to-use-git-zhi` against r2;
  - did not walk the single-worker path;
  - no full multi-worker run, and no pvm.
- **`i26-fresh`:**
  - did not read this ledger, the other reports, r1 or the diff, so it did not
    check its overlap with round 1;
  - its F8(f) notes that a CLI walkthrough does not show an agent following
    the skill.

**Round 3, as each participant declared:**

- **`i26-arch`:**
  - did not re-run D2 or D4 in the author's scratch repository;
  - the Acceptance walkthrough's coverage, beyond the dead-worker note;
  - R5's settle interval and D1;
  - 0003 beyond Step 4's composition rule;
  - whether subagents can dispatch subagents in other harnesses;
  - the one-worker branch walked end to end.
- **`i26-evidence`:**
  - race counts are small local runs and scheduling-dependent; the r22 to r24
    harness never went red;
  - all repositories are tiny; the R5 window and the takeover read grow with
    chain size;
  - R7's export behaviour is a property of this harness's Bash tool;
  - the squash false negative depends on the target repository's merge
    strategy.
- **`i26-pushback`:**
  - the concurrent-start race and a settle interval (E4, E10, D1);
  - 0003 beyond Step 4's composition rule;
  - `how-to-use-git-zhi`, which r3 places out of scope;
  - whether subagents can dispatch subagents in other harnesses (P12's
    condition);
  - integration mechanics; merge conflict reasoned from the text, not
    reproduced;
  - the one-worker branch, walked by reading only;
  - no full multi-worker run, and no pvm, so pvm's `wip_limit` is unknown.
- **`i26-fresh`:**
  - Sanbao run from a worker worktree with sibling branches unintegrated;
  - the concurrent-start race and the settle interval (accepts E10 and A2 as
    measured);
  - D2 (accepts it as measured);
  - Step 5 and the postmortem beyond reading;
  - whether a blocker in another milestone counts as "integrated" for R3.
- **`i26-cold`:**
  - did not reproduce D2 or D4;
  - did not test nested-agent dispatch beyond inspecting its own tool set, so
    C3 depends on the platform.
- No participant ran a full multi-worker `crochet:execute` run.
