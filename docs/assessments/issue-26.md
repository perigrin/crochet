---
stability: 1
covers:
  - skills/execute/execute.md
---

# Assessment: issue #26, milestone-scoped worker selection in execute

Threshing session over perigrin/crochet#26 ("execute: bare `git zhi next` is not
milestone-scoped, so workers pick other milestones' issues and collide").
#26 has no decision number, so this file is named for the issue. Two rounds
have run, both against crochet `d2de72f` and git-zhi 0.7.2 (`7b9287d`).

- **Round 1** assessed r1: the issue body as fetched on 2026-10-27.
- **Round 2** assessed r2: a revision written by the orchestrating session to
  answer the round-1 findings. r2 is held in the session's scratch directory
  (`subject-r2.md`, with r1 as `subject.md` and the diff as `r1-r2.diff`), **not
  in this repository**. #26's body on GitHub is still r1.

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

No participant declared a block or a standing-aside in either round. One
round-1 finding is held (P6); twenty new findings were raised in round 2.

## Participants

| | Role | Rounds | Context |
|---|---|---|---|
| `i26-arch` | participant | 1, 2 | dispatched fresh in round 1, resumed in round 2; codebase and architecture axes, read against decisions 0002 and 0003 |
| `i26-evidence` | participant | 1, 2 | dispatched fresh in round 1, resumed in round 2; re-derived every behavioural claim in scratch repositories on 0.7.2 |
| `i26-pushback` | participant | 1, 2 | dispatched fresh in round 1, resumed in round 2; `paad:pushback` over the subject as a spec |
| `i26-fresh` | participant | 2 | dispatched fresh in round 2; read r2, the codebase and git-zhi source, and declared it did not open this ledger, any other `i26-*` report, r1 or the diff |
| orchestrating session | drafter, round 1 | 1 | held no view on the subject; was not r1's author |
| round-2 drafter | drafter, round 2 | 2 | a separately dispatched subagent holding no view on the subject. The orchestrating session could not draft round 2, because it became the subject's author at r2 |

r1's author, an agent running `crochet:execute` on pvm's `m2-incremental`, did
not sit. r2's author, the orchestrating session, wrote the revision and
submitted no report in round 2. Every participant reported by writing a file;
no report was truncated and no participant died.

## The three axes

As the participants stated them after round 2.

1. **Codebase.** Round 1: the drift symptom is real (E1, E2), and duplicate
   selection happens inside a single milestone (A1, E4). Round 2: r2's
   behavioural claims hold on 0.7.2, with qualifications (`i26-evidence`).
   `issue list --ready --milestone <m>` excludes in-progress issues but
   includes assigned ones (E11). Execute's Steps 3 to 4 and Loop control are
   written for one self-looping agent, and r2 does not say who runs them (A9,
   F1, F6, P8). `ZHI_ACTOR` exported in one Bash call does not reach the next
   one in this harness (F5).
2. **Architecture.** `i26-arch` and `i26-pushback` released their 0002 findings.
   Per-pick assignment is 0002's "dispatch bookkeeping" at a finer grain, and
   no decision is needed (A4, P1). `i26-fresh` reads r2 as mostly aligned with
   0002, restoring its "single serialisation point" premise. It says "Workers
   still select with bare `next`" is no longer literally true, since the
   orchestrator selects and `next` confirms (F7). See disagreement D3.
3. **Direction.** `i26-arch`: the r2 shape keeps runs unattended (A8 released).
   `i26-fresh`: R1 and R2 help autonomy, but stand-downs have no recovery and
   leave issues no one can resume, which puts a human back in the loop (F3,
   F5).

## Ledger

Where one row has several raisers, each raiser's round-2 declaration is
recorded separately. Only a raiser releases.

### Round-1 findings

| id | raiser | round | section of the subject | consequence if it ships | evidence | status | revision |
|---|---|---|---|---|---|---|---|
| A1 / P4 / E4 | i26-arch, i26-pushback, i26-evidence | 1 | What happened, bullet 2 | the collision persists under either option | same-milestone repro: w1 and w2 both get `b1` from `next` | **A1 released** (`i26-arch`): r2 places duplication in one milestone; R1+R2 remove the convergence, "only if A9 is fixed". **P4 released** (`i26-pushback`): problem §2 restated; R3 checks the actor. **E4 released** (`i26-evidence`): R1+R2 give distinct issues, measured | d2de72f |
| E4 | i26-evidence | 1 | (absent) | git-zhi's start is not mutually exclusive under concurrency | 20/20 concurrent `--state start` pairs both exit 0, one transition survives; `storage.WriteEntity` writes the ref unconditionally, no CAS. Sequential second start fails (exit 1) from 20 ms apart | **released** (`i26-evidence`): filed as git-zhi#35, with R3 as mitigation; the residue is E10 | 7b9287d |
| A2 / P4 | i26-arch, i26-pushback | 1 | Proposed change | a worker that lost the start still does the work, as on pvm | sequential second start: `cannot start: issue is in-progress`; Step 2 says nothing about a refused start | **A2 released** (`i26-arch`): R3 checks post-state, and C3 found no double ownership; residue moved to A10. **P4 released** (`i26-pushback`), as above | d2de72f |
| E9 | i26-evidence | 1 | Where it goes | execute's start paragraph overstates what start guarantees | given E4, "this records a transition … which is what makes the selection above work" is not true under concurrency | **released** (`i26-evidence`): R5 commits to correcting it; wording is to be checked at review | d2de72f |
| P2 / E6 | i26-pushback, i26-evidence | 1 | Proposed change, option 1 | only the first pick is scoped; a worker that finishes its issue drifts off the milestone again | Step 4 returns to Step 2; measured drift to another milestone and collision there | **P2 released** (`i26-pushback`): R1 names the finish trigger; residue raised as P8. **E6 released** (`i26-evidence`): R1, R2 and R4 answer it; in the walkthrough a surplus worker stood down | d2de72f |
| A3 / P3 / E7 | i26-arch, i26-pushback, i26-evidence | 1 | Proposed change, option 1 | a hand-built ready set admits in-progress issues and misses cross-milestone blockers | `issue list --ready --milestone <m> --format json` already returns the ready set on 0.7.2 | **A3 released** (`i26-arch`): R1 names the query (C1). **P3 released** (`i26-pushback`): the query excludes in-progress issues, confirmed. **E7 released** (`i26-evidence`), superseded by E11 | d2de72f |
| A4 / P1 | i26-arch, i26-pushback | 1 | Proposed change, option 1; Where it goes | contradicts accepted 0002 without amending it | 0002 names bare `next`; "Where it goes" lists only execute.md | **A4 released** (`i26-arch`): r2 stays inside 0002 and R2 adds the stop rule; the new orchestrator role relative to `execute.md` is A9. **P1 released** (`i26-pushback`): no frozen text falsified | d2de72f |
| A5 / P5 / E8 | all three | 1 | Proposed change, option 2 | a criterion satisfiable only by another repository; and if modelled on `--label` it loses resume-own and assignment preference | `--label` measured to ignore actor; ~20–40 lines inside `headForActor` | **A5 released** (`i26-arch`): out of scope, routed through `git_zhi_min_version`; git-zhi#35 records the `--label` hazard. **P5 released** (`i26-pushback`), see the P5 row. **E8 released** (`i26-evidence`): git-zhi's to do; nothing waits on it | 7b9287d |
| P5 | i26-pushback | 1 | Proposed change | "either, in order of preference" commits to nothing and has no acceptance conditions | text of the subject | **released** (`i26-pushback`): r2 commits to one shape and has an Acceptance section; its gap is P11 | d2de72f |
| A6 / P6 | i26-arch, i26-pushback | 1 | "dispatch no more workers than ready issues" | correct at dispatch, but a one-root chain runs serially forever unless the cap is re-evaluated as issues close | composes with `wip_limit` | **A6 released** (`i26-arch`): R4 re-evaluates on close; its wording is raised as A11. **P6 held** (`i26-pushback`): as worded, R4's cap does not produce the property; held until the count is stated over the right set (P9) | d2de72f |
| P7 | i26-pushback | 1 | Proposed change | an assigned issue can stop being ready before its worker starts it | largely covered by A2's refused-start rule | **released** (`i26-pushback`): R3 and R2 cover both cases; the leftover assignment is P10 | d2de72f |
| E3 | i26-evidence | 1 | What happened, bullet 1 | none: the subject's "still blocked" claim is refuted | `next` never returned a blocked issue; `blocked_by` keeps listing done blockers, the likely misreading | **released** (`i26-evidence`): r2 withdraws the claim | 7b9287d |
| A7 | i26-arch | 1 | (absent) | two concurrent runs in one repository can clear each other's assignments | 0002 places concurrent runs out of scope | **released** (`i26-arch`), as record-only. R1's extra assignments grow the exposure; still out of scope | d2de72f |

Round 1 also cited E1, E2, E5 and A8 in its axes without giving them rows. In
round 2, `i26-evidence` released E1, E2 and E5, and `i26-arch` released A8.

### Round-2 findings

| id | raiser | round | section of the subject | consequence if it ships | evidence | status | revision |
|---|---|---|---|---|---|---|---|
| A9 | i26-arch | 2 | R1, R2, Where it goes | Steps 3.5 to 4 and Loop control assume one self-looping agent. If the worker runs the gate, a second assignment can break per-worker WIP of one. If the orchestrator runs it, its reopen and start strand the issue under the orchestrator's identity. cf. F1, P8, F6 | C4: start without `ZHI_ACTOR` lands under `human:t`; then `next` as r-2 gives `no actionable issues`, and r-2's start is refused. A dispatched subagent has no agent-dispatch tool (weak, harness-specific) | open; "keeps my recommendation at modify" | r2 |
| A10 | i26-arch | 2 | R3; Acceptance bullet 2 | "A refused … start means the issue is not its issue" makes a re-dispatched worker stand down from its own resumed in-progress issue. The walkthrough would test only refusal | C2: start on own in-progress A1 refused; `next` as r-1 returns A1; 0002 "Only the abandoned identity gets the issue back" | open | r2 |
| A11 | i26-arch | 2 | R4 | "never more live workers than ready issues" counts the wrong quantity; an implementer may retire live workers. cf. P9, F6 | C1: in-progress issues leave the ready set | open; "minor, close to wording" | r2 |
| E10 | i26-evidence | 2 | R3 | an immediate post-start check can pass for both workers. R3 should check after a short settle and re-check before close or push. cf. F4 | immediate check: both passed in 3/80 concurrent pairs (r13 1/20, r15 2/60); after 0.5 s: exactly one owner in 110/110 (r14+r15). Non-owner `--state done --force` succeeds | open | r2 |
| E11 | i26-evidence | 2 | R1 | R1's query includes assigned and reopened issues; the skill must filter `select(.assigned==null)`, and R1 should name it. A reopened issue would go to any free worker | r18: assigned b2 and reopened b5 returned; `--assigned ""` does not filter; `--assigned none` returns `[]` | open | r2 |
| E12 | i26-evidence | 2 | R3 | a read racing a write can fail. R3 must treat a failed read as "unknown, retry", neither lost nor won | r15: `issue show` failed 2/15 with `ref file is empty`; controls 0/40, 0/40, 0/30. Inferred, not traced, to the same non-atomic write as git-zhi#35 | open | r2 |
| P8 | i26-pushback | 2 | R1 triggers, with R2, R3, R4 | a stood-down worker's request matches none of R1's triggers. Loop control's "ready set is empty" stop ends the run early, while work is in flight. cf. A9, F6 | R1's trigger list; execute.md L82 | open | r2 |
| P9 | i26-pushback | 2 | R4 | live workers and ready issues are disjoint sets; once workers start, the cap is violated and the run under-parallelises. cf. A11, F6 | `issue list --ready` is pending or reopened; in-progress `a1` absent | open; P6 held on it | r2 |
| P10 | i26-pushback | 2 | R1, with R2, R3 | an assignment held by this run's stood-down or exited worker is never reclaimed; the issue is stranded until a new run. cf. F10 | reclamation clears only other runs' tokens (execute.md L118–121); probe: `a1` in progress under `x-1`, still assigned to `x-3` | open; "would drop to low" if issues cannot leave and re-enter the ready set within a run | r2 |
| P11 | i26-pushback | 2 | Acceptance, bullet 2 | the walkthrough can pass without exercising the finish trigger, widening, stand-down service or run end. cf. F8 | text of the subject; a refused start does not arise under R1 and must be induced | open | r2 |
| F1 | i26-fresh | 2 | R1, R4, Where it goes | dispatched subagents return and end, so "each time a worker finishes" has no mechanism. R4's re-evaluation degrades to once per batch. Step 4's lens dispatch and reopen need an owner. cf. A9 | execute.md l.131-132, l.169, l.298, l.356; dispatching-parallel-agents "When agents return" | open | r2 |
| F2 | i26-fresh | 2 | R4 | an issue that is chain-ready is not code-ready: downstream dispatch can start from a tree without its upstream's commits, or build on work later reopened | execute.md l.154-156, l.256-257, l.367-369; `ReadySet` treats done upstream as satisfied | open | r2 |
| F3 | i26-fresh | 2 | R2, R3 | a stand-down leaves the issue in progress under the wrong actor, absent from the ready set; the milestone cannot complete. cf. A9, P10 | scratch: start without `ZHI_ACTOR` → `human:T`, absent from `issue list --ready`, second start refused; 0002 "Breaking it costs a stranded issue" | open | r2 |
| F4 | i26-fresh | 2 | R3, Out of scope | R3 does not mitigate git-zhi#35; a single read right after the write cannot detect a lost update. Within a run, R1+R2 already prevent the case. See D1 | `WriteEntity`: parent from the current ref, then ref update, no CAS; interleaving read(A), read(B), write(A), check(A), write(B), check(B) | open | r2 |
| F5 | i26-fresh | 2 | R2, R3; Step 2 identity paragraph | `export ZHI_ACTOR` does not survive between Bash calls, so calls resolve to the git author; R2 and R3 trip on every issue and each trip strands one | scratch: exported in one call, empty in the next; the Bash tool's own statement; execute.md l.103-105 | open; predates r2, which depends on it | r2 |
| F6 | i26-fresh | 2 | R1, R4, against Loop control | the ready set is empty whenever every ready issue is held, so Loop control ends the run with workers running; R4's cap shrinks below the live count. cf. P8, P9, A11 | execute.md l.80-89; `ReadySet` filter; in-progress A absent from `issue list --ready` | open | r2 |
| F7 | i26-fresh | 2 | R5; "Every requirement stays inside decision 0002" | if Key Constraints keeps "Each worker selects with bare `git zhi next`", it stays false and hides the shift that the orchestrator now selects. Not an amendment to 0002. See D3 | 0002 "The execute loop", "Assignment is a hint"; execute.md l.439 | open | r2 |
| F8 | i26-fresh | 2 | Acceptance | the conditions can pass while the problem persists: (a) the other milestone must lead the critical chain; (b) cover finish-and-reassign; (c) a sequential walkthrough cannot exercise the race; (d) test the reachable start-under-wrong-actor case, not refusal; (e) the one-worker branch is uncovered; (f) a CLI walkthrough does not show an agent following the skill. cf. P11 | `headForActor` falls back to `CriticalChain()`; scratch: unassigned worker got X1 | open | r2 |
| F9 | i26-fresh | 2 | R1 | `git zhi list --ready --format json` carries no `assigned`; the subject names the right listing, but the how-to table names the other | scratch: `list --ready` → `{"ready_set":[{id,title}]}`; `issue list --ready` includes `assigned` | open; "minor, implementation" | r2 |
| F10 | i26-fresh | 2 | R1, R2 | an issue reopened at Step 4 stays assigned to worker *n*; a newly dispatched *m* cannot be assigned it, and R2 makes *m* refuse it. See D2; cf. P10 | execute.md l.122-125, l.335-341; `headForActor` step 3 | open; "minor" | r2 |

Also recorded, not raised as a finding: `i26-arch` notes that
`skills/how-to-use-git-zhi/how-to-use-git-zhi.md`'s intent table still says
`next [--label <l>]` with `ZHI_ACTOR` returns "the HEAD issue for this worker",
which round-1 O6 falsified, and that it deserves its own crochet issue. F9
touches the same table.

### Disagreements

Recorded as each side stated them. None is resolved here.

- **D1. Whether R3's post-start check detects a lost start.**
  - `i26-fresh` (F4), reading the source: `WriteEntity` has no
    compare-and-swap. In the interleaving read(A), read(B), write(A), check(A),
    write(B), check(B), both checks pass, so "a single read right after the
    write cannot detect a lost update". R3 "gives false assurance".
  - `i26-arch` (A2, C3), measuring: in 20 of 20 concurrent trials, each
    checking immediately, exactly one worker saw itself as actor, and none saw
    both.
  - `i26-evidence` (E10), measuring: checking immediately, both workers passed
    in 3 of 80 pairs. After a 0.5 s settle, exactly one owner in 110 of 110.
    It names local-disk timing and small run sizes as alternative explanations,
    and did not search for the minimum safe settle.
  - `i26-pushback`, in its declared not-re-examined list: R3 "cannot detect a
    concurrent winner whose write lands after the check". It raises nothing,
    because r2 calls R3 a mitigation.
  - The two measured immediate-check results also differ from each other
    (0/20 against 3/80).
- **D2. Whether a reopened issue keeps its assignment.**
  - `i26-arch` (C5): a reopened issue reappears in `list --ready` "still
    assigned to its worker".
  - `i26-fresh` (F10): an issue reopened at Step 4 "stays assigned to worker
    *n*", citing execute.md and `headForActor`. `i26-pushback` (P10) reasons
    on the same premise.
  - `i26-evidence` (E11): a reopened issue "comes back with no assignment"; r18
    shows reopened b5 unassigned. Its report does not say whether b5 was
    assigned before the reopen.
- **D3. Whether "Workers still select with bare `next`" is true of r2.**
  - `i26-arch` (A4) and `i26-pushback` (P1) released on the grounds that
    workers keep bare `next` with `ZHI_ACTOR`, and per-pick assignment is
    0002's dispatch bookkeeping.
  - `i26-fresh` (F7): under R1 the orchestrator selects and `next` confirms, so
    the line "is no longer literally true".
  - All three agree that no decision is amended.
- **D4. Whether a refused start is reachable within a run.**
  - `i26-fresh` (F8d) and `i26-pushback` (P11): under R1's disjoint assignment
    a refused start does not arise by itself and must be contrived or induced.
    `i26-evidence`'s walkthrough induced one.
  - `i26-arch` (A10, C2): `--state start` is refused on a worker's own resumed
    in-progress issue, which bare `next` returns first.

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
