---
stability: 1
covers:
  - skills/execute/execute.md
---

<!-- The subject of docs/assessments/issue-26-selection.md as accepted at revision r8. Earlier revisions are not kept; the ledger records what changed and why. -->

# Subject, revision r8: perigrin/crochet#26, milestone-scoped selection in execute

r1 is the body of perigrin/crochet#26. Revisions r2 to r7 were held in the
assessing session and are not kept here; the record of each round is
`docs/assessments/issue-26-selection.md`.

r8 changes r7 only where a round-7 finding asked for it, and every change names
the finding. Rulings 1 to 4 are unchanged. **Human ruling 5:** if round 8 does
not converge, #26 is accepted with what remains open recorded as residuals.

The nits that round 7's participants marked as the implementing issue's are
collected at the end, under "Binding on the implementing issue".

**The skill states reasons in prose (W9).** The finding ids here are this
record's. The skill text carries each rule's reason in words, not ids.

**W8 is noted rather than changed.** Under R2, `next` hands over and
confirms, rather than choosing. That is recorded as true, and R2 keeps it
because 0002 names bare `next` as the worker's selection.

## Two human rulings since round 3

1. **Scope narrows back to selection.** r3 widened the subject to cover the whole
   worker lifecycle. Round 3 found that model broken in ways that predate #26:
   - a worker cannot dispatch Step 4's review (A9, P12, F11, C3);
   - a dead worker's in-progress issue cannot return to the pool (A12, E14,
     P13, F3, C1);
   - there is no stuck outcome (F14, C2);
   - `wip_limit` is enforced across the chain (P17, C4);
   - review records overwrite each other (F12, C5).

   i26-cold's position is that assigning from the milestone's ready set alone
   fixes both of #26's symptoms. The human ruled to take that core, and to move
   the lifecycle defects to their own issue, **perigrin/crochet#27**, where
   they are recorded with their finding ids. They are out of this subject's
   scope. They are still findings, and only their raisers may release them.
2. **`ZHI_ACTOR` on every command is a harness detail within 0002's intent**
   (D6: A13, P18, C9). 0002 declares identity "once, for the process, not per
   command", so that the read side and the write side resolve the same
   identity and nothing passes a different one by flag. Where each shell
   command is its own process, as in agent harnesses where an `export` does not
   survive between invocations (F5), setting the same token on each `git zhi`
   command is that single declaration. 0002 is not amended. The skill states
   this reason where it gives the rule.

## The problem

- **Off-milestone drift (E1, E2, E6).** `next` cannot be scoped to a milestone.
  It ranks by critical-chain length, then by creation order.
- **Duplicate selection (A1, E4).** Workers that call `next` before any of them
  has started receive the same issue, even within a single milestone.

The concurrent-start lost update is git-zhi's to fix (perigrin/git-zhi#35).
So is an empty ref resolving to HEAD (perigrin/git-zhi#36).

## What must become true

All of this is inside 0002, including how a worker carries its identity
(ruling 2). D3 is answered in R2.

- **R1. Assign before every pick, on every path.** Before any worker calls
  `next`, the agent that orchestrates takes one issue from `issue list --ready
  --milestone <m>`, filtered to issues with no assignment (E7, E11). It assigns
  that issue to the token the worker will use.
  - **With parallel dispatch**, the orchestrator does this before each
    dispatch. It dispatches no more workers than there are such issues, within
    `wip_limit` (A6, A11, P9). `wip_limit`'s chain-wide counting is #27's to
    settle, not R1's (F18).
  - **With one worker** (the `Otherwise` branch), that agent is both. It does
    the assignment at the per-pick step that Step 4's return re-enters, not in
    the once-per-run identity block (F17, P21, C13, K1).
  - **Every pick, on both paths, uses a fresh `<n>`**, so a token is used for
    exactly one issue (C14, K2, P23, K11, C16, Q1). For the single worker that
    means a new token per issue. **Human ruling 3** (D13: W3, E20, F21) keeps
    this: a reused token makes `next` return an earlier reopened issue instead
    of the new pick (E20, measured). What a single token would have given
    instead is self-resume: an agent told to continue mid-issue resumes the
    issue it already holds, under that issue's own token, before it picks
    anything new (F21). Step 4's reopen keeps the issue's token (Q1).
  - **Self-resume runs no transition** (A19, F22, C20, K16, P26, W10, V2).
    When `next`, under the issue's own token, returns that token's own
    in-progress issue, the agent does not start it again. On 0.7.2 both
    `start` and `--state resume` are refused on one's own in-progress issue.
    It skips R2's stand-down and R3, and goes straight back to Step 3 under
    that token.
  - The ready rule comes from that query, never computed by hand (A3, P3).
  - **Order, human ruling 4** (D12: A18, W2, Q9). Issues on the repository's
    critical chain come first, in that chain's order. The chain is read from
    the `critical_chain` key of `list --critical --format json`. Its `issues`
    key is every issue in creation order, so it is the wrong field (C21; the
    author's measurement and i26-pushback's). The rest follow in creation
    order. No other ordering policy is introduced, so `urgency` is not used.
    - `list --critical` reports only the one repo-wide chain and ignores
      `--milestone` (measured on 0.7.2).
    - What is lost is a milestone-scoped critical order, which bare `next`
      never offered either (Q11). execute.md states this as a recorded cost
      (Q3). It goes away if git-zhi ships a milestone-scoped `next`
      (git-zhi#35).
  - 0002 calls the ready-set query wrong for selection, because it "has no
    assignee filter" (C19). On 0.7.2, `issue list --assigned` exists, but it
    cannot select unassigned issues (W7). R1 uses the query only for the
    orchestrator's choice, and filters out assigned issues itself. The worker's
    selection remains `next` (Q8).
- **R1a. Re-dispatch and run end (P20, K4, Q7).** A worker returns after its
  issue, or after standing down. On each return the orchestrator runs R1 again.
  The run ends when no worker is live and the filtered pool is empty, not when
  the ready set is empty. Loop control's stop conditions change to match: its
  "ready set is empty" and "every remaining issue is blocked" stops are
  replaced by this rule and R1c's (P20, K15, W5).
- **R1c. A stand-down that leaves its issue pending does not re-dispatch at once (A17, P22, F19, K12, C15, Q2, W4, V1).**
  When a worker stands down and its issue is still pending, the orchestrator
  dispatches nobody further until a live worker returns. A refused start, such
  as a `wip_limit` refusal, is one way that happens; a `next` that returns the
  wrong issue is another.
  - **If none is live, the run ends.** It reports by name every issue still in
    the pool, with git-zhi's refusal text for the refused one (K14, C18, P25,
    W1, E19).
  - **On the one-worker path**, the agent running the loop does not count as
    live, so a refusal there ends the run rather than waiting on itself (F20,
    C17, P24, Q10).

  This keeps a slot held from outside the run from turning R1a and R1b into a
  loop. When the slot frees inside the run, re-dispatch proceeds, as rounds 5
  and 6 measured (i26-evidence). Loop control's stop on "a tool refused the
  action" changes to match, so it no longer contradicts R3's stand-down (F19).
- **R1b. A stand-down gives its assignment back (P19, C12, K3, A16, Q5).** When a
  worker returns without owning its issue, the orchestrator clears the
  assignment with `--unassign`, **only if it still carries that worker's
  token**. An assignment someone else has set since is never touched, as 0002
  requires. The issue returns to the pool R1 draws from. An issue the worker
  started and then lost stays in progress under the other actor, and cannot be
  re-dispatched from here. That case is #27's (E14, E18).
- **R2. Workers keep bare `next` (A4, P1, D3, F7, E5, Q7).** The worker's `next`
  returns its own assignment. If it returns anything else, including `no
  actionable issues`, the worker starts nothing and returns to the
  orchestrator. The skill says plainly that the orchestrator
  chooses by assigning and that `next` hands the issue over. Decision 0002
  already gives the orchestrator assignment as its way to steer.
- **R3. One ownership check after start (A2, E10, E12, C6, C7).**
  - The worker starts its issue by its literal id and never by an empty or
    unset variable (C6, git-zhi#36).
  - It waits briefly, then re-reads the issue. It owns the issue if the issue
    is in progress and the latest transition's actor is itself. The wait uses
    a mechanism the harness permits, because some agent harnesses block a
    foreground `sleep` (W6). Which mechanism is for the implementing issue.
  - A failed read is retried, and never counts as won or lost.
  - On a lost or refused start, the worker stands down and returns.

  This narrows git-zhi#35's window and does not close it (F4, D1). Resuming
  one's own in-progress issue does not pass through R3 at all; see
  "Self-resume runs no transition" in R1. r3's re-check before done and push
  is gone, because it was wrong after `done` (E13).
- **R4. Identity is set on each `git zhi` command**, with ruling 2's reason
  stated beside the rule (F5, A13, P18, C9).
- **R5. Text that says workers pick their own issue is corrected (E9, K5).** This
  covers every place in execute.md that says so, not only the start paragraph
  and Key Constraints line. It also covers `how-to-use-git-zhi`'s `export
  ZHI_ACTOR` example, which R4 contradicts (C9, K6), and the "exported"
  wording in `postmortem.md` (Q8) and `docs/ARCHITECTURE.md` (V5).
  ARCHITECTURE.md is a live document, so it changes first, in the same pull
  request.

R3 stays, although R1 and R2 already rule out a shared pick within one run
(K10). Its reachable cases are a start refused for `wip_limit`, and an actor
outside the run taking the issue. Round 4's forced races showed it keeping a
worker off a stolen issue in 20 of 20 races (i26-evidence).

## Acceptance

- The execute skill states R1 to R5.
- A walkthrough in a scratch repository, at the `git_zhi_min_version` the
  plugin declares (C10), covers:
  - the other milestone leading the critical chain, so unassigned bare `next`
    would leave the milestone;
  - two workers calling `next` and starting **concurrently**, launched together
    rather than in turn, so the old design's shared pick can occur (K7, K13);
  - more issues than workers, and a second dispatch after the first workers
    return (R1a);
  - a start refused while the issue stays pending, with the worker standing
    down and the issue re-dispatched once a slot frees (R1b, E18);
  - a lost start, where the worker stands down only (E18);
  - `wip_limit` above zero, with a slot held from outside the run, and more
    than one issue in the pool: the run ends and reports the whole remaining
    pool by name rather than looping (R1c, F19, E19);
  - the one-worker branch (R1, F17), including a refusal there, which ends the
    run (R1c, P24);
  - a worker whose token was used before, so that a reopened issue is
    reachable (E20).

  It passes if:
  - no worker starts an issue outside the milestone;
  - no issue carries work from two workers, judged from each worker's own
    record, which names its token, rather than from the chain's transitions or
    commits. A lost concurrent start erases its own transition, and every
    worker commits as one git author (E17, K8, K13);
  - each worker worked the issue assigned to it, not merely an issue `next`
    returned (E20);
  - every milestone issue that was ready and unassigned at some point before
    the run ended was dispatched, or is named in R1c's end-of-run report.
    Issues a human assigned are excluded (K9, Q6, K14, E19).
- Run without R1 to R3, with the concurrent starts launched together, the same
  walkthrough fails, as rounds 4 and 5 measured (Q4).

The walkthrough models the behaviour R1 to R5 require. It does not show that
the skill's wording produces that behaviour in an agent. That judgment is
`crochet:review`'s, at the gate after execute (Q4).

How the walkthrough is scripted, the pause length in R3, and the JSON fields R1
filters on (F9) belong to the implementing issue.

## Out of scope

- The worker lifecycle after selection: review dispatch, dead-worker
  reclamation, stuck issues, `wip_limit` chain-wide counting, review-record
  overwrites, integration ordering and conflicts (F2, A14, E15, P14, P15),
  and the `--step` path. These are **perigrin/crochet#27**. The one-worker
  path's *selection* is in R1 (F17); only its lifecycle questions stay in #27.
- `next --milestone` and safe concurrent starts: perigrin/git-zhi#35.
- Short IDs colliding for issues created together: perigrin/git-zhi#37. Until
  that is fixed, workers read issue IDs from JSON output, never from text.
- Concurrent runs in one repository (A7).
- The `how-to-use-git-zhi` claim about `--label`, and E16's `--state reopened`
  rejection. Each is its own defect.

## Where it goes

- `skills/execute/execute.md`:
  - Step 2: dispatch and assignment, the identity rule, the `next` and start
    paragraphs, and the `Otherwise` branch;
  - the Step 4 return to Step 2;
  - Loop control;
  - Key Constraints;
  - any other line saying workers select their own issue (K5).
- `skills/how-to-use-git-zhi/how-to-use-git-zhi.md`, the `ZHI_ACTOR` example
  (C9, K6).
- `skills/postmortem/postmortem.md`, the "exported" wording (Q8).
- `docs/ARCHITECTURE.md`, the "exported identity" wording (V5).

## Binding on the implementing issue

These are nits that round 7's participants handed to the implementing issue
rather than to this subject. They are recorded here so they are not lost.

- **R3's retry of a failed read is bounded** (V1).
- **R1's "no assignment" filter** treats a missing `assigned` field as
  unassigned. The ready JSON omits the field rather than setting it to null
  (V3).
- **Ordering:**
  - creation order sorts on the `created` field, ascending, with the chain in
    the order `critical_chain` lists it (V4);
  - `critical_chain` can be null (i26-evidence);
  - ties between equal `created` values go by UUID (i26-evidence);
  - the chain can move mid-run, so R1 reads it at each pick (i26-evidence).
- **`--step` goes through R1's pick** like every other path (V6).
- **Walkthrough:**
  - the reused-token case is a negative control, which must fail (P27);
  - the reused-token stand-down is an explicit assertion (i26-cold2);
  - the walkthrough names the `critical_chain` key (i26-pushback).
- **Loop control's single end-of-run report** names blocked issues too
  (i26-arch).
- **Issues the run still holds at a normal end** are not reported here; that
  is #27's (i26-evidence).

A15, E14's in-progress half, E16's reporting half and F18 were carried to #27
as a comment there, after round 4.
