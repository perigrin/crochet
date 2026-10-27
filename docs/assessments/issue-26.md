---
stability: 1
covers:
  - skills/execute/execute.md
---

# Assessment: issue #26, milestone-scoped worker selection in execute

Threshing session over perigrin/crochet#26 ("execute: bare `git zhi next` is not
milestone-scoped, so workers pick other milestones' issues and collide"). The
subject is the issue body as fetched on 2026-10-27, assessed against crochet
`d2de72f` and git-zhi 0.7.2 (`7b9287d`). #26 has no decision number, so this
file is named for the issue.

**Round 1 outcome: another round owed.** All three participants recommend
**modify**. Nothing is released; the subject has not yet been revised.

## Participants

| | Role | Context |
|---|---|---|
| `i26-arch` | participant | dispatched fresh; codebase and architecture axes, read against decisions 0002 and 0003 |
| `i26-evidence` | participant | dispatched fresh; re-derived every behavioural claim in scratch repositories on 0.7.2 |
| `i26-pushback` | participant | dispatched fresh; `paad:pushback` over the subject as a spec |
| this session | drafter | holds no view on the subject; not its author |

The subject's author — an agent running `crochet:execute` on pvm's
`m2-incremental` — did not sit. All three reported by writing a file and
returning its path; no report was truncated and no participant died.

## The three axes

1. **Codebase** — The symptom is real: `next` has only `--actor` and `--label`,
   ranks by critical-chain length then creation order, and ignores milestone
   (E1, E2). The subject's diagnosis of the collision is not: two workers
   calling `next` before either starts receive the same issue inside a *single*
   milestone (A1, E4). Milestone scoping does not touch it.
2. **Architecture** — Option 1 as written ("workers start their assigned issue
   rather than calling bare `next`") contradicts 0002, which names bare `next`
   as the worker's selection (A4, P1). A shape that stays inside 0002 exists:
   the orchestrator assigns, workers keep calling bare `next`, which returns
   their own assignment first (A4, E5). Option 2 is another repository's
   change and can only ever be a `git_zhi_min_version` raise here (A5, P5).
3. **Direction** — A modified option 1 keeps runs unattended; option 2 alone
   does not, and leaves the collision (A8, E8).

## Ledger

| id | raiser | round | section of the subject | consequence if it ships | evidence | status | revision |
|---|---|---|---|---|---|---|---|
| A1 / P4 / E4 | i26-arch, i26-pushback, i26-evidence | 1 | What happened, bullet 2 | the collision persists under either option | same-milestone repro: w1 and w2 both get `b1` from `next` | open | d2de72f |
| E4 | i26-evidence | 1 | (absent) | git-zhi's start is not mutually exclusive under concurrency | 20/20 concurrent `--state start` pairs both exit 0, one transition survives; `storage.WriteEntity` writes the ref unconditionally, no CAS. Sequential second start fails (exit 1) from 20 ms apart | open — **git-zhi defect, outside this subject** | 7b9287d |
| A2 / P4 | i26-arch, i26-pushback | 1 | Proposed change | a worker that lost the start still does the work, as on pvm | sequential second start: `cannot start: issue is in-progress`; Step 2 says nothing about a refused start | open | d2de72f |
| E9 | i26-evidence | 1 | Where it goes | execute's start paragraph overstates what start guarantees | given E4, "this records a transition … which is what makes the selection above work" is not true under concurrency | open | d2de72f |
| P2 / E6 | i26-pushback, i26-evidence | 1 | Proposed change, option 1 | only the first pick is scoped; a worker that finishes its issue drifts off the milestone again | Step 4 returns to Step 2; measured drift to another milestone and collision there | open | d2de72f |
| A3 / P3 / E7 | i26-arch, i26-pushback, i26-evidence | 1 | Proposed change, option 1 | a hand-built ready set admits in-progress issues and misses cross-milestone blockers | `issue list --ready --milestone <m> --format json` already returns the ready set on 0.7.2 | open | d2de72f |
| A4 / P1 | i26-arch, i26-pushback | 1 | Proposed change, option 1; Where it goes | contradicts accepted 0002 without amending it | 0002 names bare `next`; "Where it goes" lists only execute.md | open | d2de72f |
| A5 / P5 / E8 | all three | 1 | Proposed change, option 2 | a criterion satisfiable only by another repository; and if modelled on `--label` it loses resume-own and assignment preference | `--label` measured to ignore actor; ~20–40 lines inside `headForActor` | open | 7b9287d |
| P5 | i26-pushback | 1 | Proposed change | "either, in order of preference" commits to nothing and has no acceptance conditions | text of the subject | open | d2de72f |
| A6 / P6 | i26-arch, i26-pushback | 1 | "dispatch no more workers than ready issues" | correct at dispatch, but a one-root chain runs serially forever unless the cap is re-evaluated as issues close | composes with `wip_limit` | open | d2de72f |
| P7 | i26-pushback | 1 | Proposed change | an assigned issue can stop being ready before its worker starts it | largely covered by A2's refused-start rule | open | d2de72f |
| E3 | i26-evidence | 1 | What happened, bullet 1 | none — the subject's "still blocked" claim is refuted | `next` never returned a blocked issue; `blocked_by` keeps listing done blockers, the likely misreading | refuted — no action | 7b9287d |
| A7 | i26-arch | 1 | (absent) | two concurrent runs in one repository can clear each other's assignments | 0002 places concurrent runs out of scope | recorded, out of scope | d2de72f |

Findings cluster in "Proposed change, option 1" and in the subject's causal
claim about the collision — the part of the subject carrying its argument.

## What the participants converged on, independently

Not a revision; the author or their stand-in writes that. Recorded so the
revision answers named findings and does not grow the subject:

- the orchestrator assigns from `issue list --ready --milestone <m>` before
  **every** pick, not only at dispatch (P2, E6, A3);
- workers keep bare `next`, within 0002, and stand down if it returns an issue
  not assigned to them (A4, E5);
- a worker confirms its own start took — the transition's actor is itself — before
  doing any work (A2, E4);
- the worker cap is re-evaluated as issues close (A6, P6);
- option 2 and the start race (E4) are git-zhi's, filed there.

## Not checked

The pvm chain itself; a full multi-worker `crochet:execute` run; whether
`blocked_by` can disagree with the graph's edges.
