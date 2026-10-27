---
stability: 1
covers:
  - skills/execute/execute.md
---

# Assessment: issue #26, milestone-scoped worker selection in execute

Threshing session over perigrin/crochet#26 ("execute: bare `git zhi next` is not
milestone-scoped, so workers pick other milestones' issues and collide").
#26 has no decision number, so this file is named for the issue. Eight rounds
have run, all against git-zhi 0.7.2 (`7b9287d`), which is also the plugin's
declared `git_zhi_min_version`. Rounds 1 and 2 ran against crochet `d2de72f`.
Round 3 ran against `bd918b1`, round 4 against `7ef0469`, round 5 against
`8e0d986`, round 6 against `eefe101`, round 7 against `7614e9f`, and round 8
against `b2c0b85`; each is
`d2de72f` plus the commits recording this assessment, and
`skills/execute/execute.md` is unchanged from `d2de72f`.

- **Round 1** assessed r1: the issue body as fetched on 2026-10-27.
- **Round 2** assessed r2: a revision written by the orchestrating session to
  answer the round-1 findings.
- **Round 3** assessed r3, titled "milestone-scoped worker lifecycle in
  execute", which answers the round-2 findings.
- **Round 4** assessed r4, titled "milestone-scoped selection in execute",
  written after the two human rulings below.
- **Round 5** assessed r5, under the same title. r5 "changes r4 only where a
  round-4 finding asked for it. Every change names the finding it answers.
  r4's rulings below are unchanged." It adds R1a (re-dispatch and run end),
  R1b (a stand-down gives its assignment back), R1's one-worker clause and
  fresh `<n>` per dispatch, a widened R5, and a larger Acceptance.
- **Round 6** assessed r6, under the same title. r6 "changes r5 only where a
  round-5 finding asked for it. Every change names the finding it answers.
  r4's rulings below are unchanged." It adds R1c (a refused start does not
  re-dispatch at once), a fresh `<n>` on every pick on both paths, an "Order"
  bullet (by `urgency`, then creation order), the Q8 sentence on 0002, R1b's
  token guard and `--unassign`, R2's `no actionable issues`, `postmortem.md`
  as an R5 site, and new Acceptance cases. It grew from 152 to 187 lines.
- **Round 7** assessed r7, under the same title. r7 "changes r6 only where a
  round-6 finding asked for it, or a human ruling since round 6 settled it.
  Every change names the finding or ruling." It writes rulings 3 and 4 into
  R1; R1c's early end reports the whole remaining pool and K9 exempts what it
  names; the one-worker looping agent is not "live"; R1a's Loop control
  sentence is restored with both stops; R3's wait uses a mechanism the harness
  permits; the 0002 quotation is corrected and `--assigned` described; the
  walkthrough gains a reused-token case and "each worker worked the issue
  assigned to it"; preamble lines on W9 and W8; and git-zhi#37 under Out of
  scope. It grew from 187 to 225 lines.
- **Round 8**, the last under ruling 5, assessed r8, under the same title. r8
  "changes r7 only where a round-7 finding asked for it, and every change names
  the finding. Rulings 1 to 4 are unchanged." It adds "Self-resume runs no
  transition" to R1 and removes R3's "unreachable" clause; reads ruling 4's
  order from the `critical_chain` key; restates the ordering cost (Q11); fires
  R1c on any stand-down that leaves its issue pending; adds
  `docs/ARCHITECTURE.md` to R5; and collects round 7's nits in a new section,
  "Binding on the implementing issue". It is 264 lines.

r2 to r7 are held in the session's scratch directory (`subject-r2.md` to
`subject-r7.md`, with r1 as `subject.md` and the diffs as `r1-r2.diff` to
`r7-r8.diff`), **not in this repository**. r8 is committed beside this record
as `docs/assessments/issue-26-selection-subject.md`. The round-8 brief is `brief-r8.md`;
it asks each participant to say, for anything still held, whether it is "**a
bar**, meaning it should not ship while this is open, and why; or **a
residual** the implementing issue or #27 can carry". #26's body on GitHub is
still r1.

**The human's scope ruling at r3.** r3's opening records it: "Round 2 showed
(F1) that #26 cannot be fixed at the first pick alone. Dispatched workers return
after one issue, so 'reassign when a worker finishes' had nothing to reassign.
The human chose to specify the worker's whole lifecycle." So r3's "Where it
goes" covers Step 2, Steps 3.5 and 4, Loop control and Key Constraints, not Step
2 alone. r3 also records two measurements its author made before writing it, on
0.7.2: a reopened issue keeps its assignment (D2), and a worker starting its own
in-progress issue is refused while `next` returns that issue to it (D4).

**The human's two rulings at r4.** r4's opening records them:

1. "**Scope narrows back to selection.**" Round 3 found the lifecycle model
   "broken in ways that predate #26": review dispatch (A9, P12, F11, C3), a dead
   worker's in-progress issue (A12, E14, P13, F3, C1), no stuck outcome (F14,
   C2), chain-wide `wip_limit` (P17, C4) and overwritten review records (F12,
   C5). "The human ruled to take that core, and to move the lifecycle defects to
   their own issue, **perigrin/crochet#27**, where they are recorded with their
   finding ids. They are out of this subject's scope. They are still findings,
   and only their raisers may release them."
2. "**`ZHI_ACTOR` on every command is a harness detail within 0002's intent**"
   (D6: A13, P18, C9). "Where each shell command is its own process … setting
   the same token on each `git zhi` command is that single declaration. 0002 is
   not amended. The skill states this reason where it gives the rule."

**Filed by the author since round 3:** perigrin/crochet#27 ("execute: parallel
workers have no defined lifecycle after the first pick — review, dead workers,
stuck issues, wip_limit") and perigrin/git-zhi#36 ("`issue edit ""` resolves an
empty ref to HEAD and succeeds, so an unset variable can change the wrong
issue").

**Posted by the author since round 4:** a comment on perigrin/crochet#27
carrying A15, E14's in-progress half, E16's reporting half and F18 by id.
`i26-arch` read it through the REST API. `i26-pushback` and `i26-cold` say they
did not check it; `i26-cold3` did not read #27.

**Measured by the author after round 6.** This is the orchestrating session's
measurement, not a participant's finding; it bears on A18 and W2 (D12). In a
scratch repository on 0.7.2, milestone `mine` had the chain `a1→a2→a3` and
milestone `other` had `o1→o2→o3`, both of length 3. `git zhi list --critical`
and `git zhi list --critical --milestone mine` printed the identical single
chain `o1→o2→o3`, so `--critical` ignores `--milestone` and shows only the
repository-wide critical chain; bare `next` returned `o1`. Separately, the text
output printed every issue's short id as `01a17b5e`: the 8-character prefixes
of time-ordered UUIDs created together collide.

**The human's two rulings since round 6**, as `brief-r7.md` records them and
r7's R1 carries them:

3. "**Ruling 3, D13.** A fresh token on every pick, including for the single
   worker. Self-resume is kept explicitly: an agent told to continue resumes
   the issue it holds under that issue's own token before picking anything new
   (F21). Step 4's reopen keeps the issue's token (Q1). The basis is E20's
   measurement."
4. "**Ruling 4, D12.** Pool order: issues on the repository critical chain
   from `list --critical` come first, in that chain's order, then the rest in
   creation order. No `urgency`." The brief adds: "The author measured that
   `list --critical` reports only the repo-wide chain and ignores
   `--milestone`. So it recovers `next`'s order only when the run's milestone
   holds that chain. Otherwise the loss is a recorded cost, stated in
   execute.md, until git-zhi#35."

**The human's ruling during round 7:**

5. **If round 8 fails to converge, #26 is accepted with what is still open
   recorded as residuals.** The round-7 brief states "This is round 7 of a
   bound of 8."

**Filed by the author after round 6:** perigrin/git-zhi#37, 8-character short
IDs collide.

**Measured by the author, bearing on C21.** This is the author's measurement,
not a participant's finding. On 0.7.2, `git zhi list --critical --format json`
returns an object with keys `critical_chain`, `current_constraint`, `issues`
and `parallel_work`. `.critical_chain` held the chain `o1, o2, o3`; `.issues`
held every issue in creation order. `i26-pushback`'s round-7 report says the
same. C21 stays as its raiser declared it; only `i26-cold` may release it. See
D14. In round 8 `i26-cold` re-measured and released C21.

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

**Round 4 outcome: another round owed; objections are outstanding.** One
earlier finding is held in part (C9, its live-document half). By their
raiser's word, P10's release no longer stands, nor do the run-end half of P8's
and the leftover-assignment half of P7's; they are raised again as P19 and P20.
20 findings were raised in round 4. Each participant's recommendation, as
written:

- `i26-arch`: "**Recommendation: accept.**" "I have one note to carry into #27
  (A15), which does not bar this subject."
- `i26-evidence`: "**accept, with one wording change** (E17)".
- `i26-pushback`: "**modify** (three sentences)". "None of the three needs
  lifecycle machinery. Each needs one sentence." (P19, P20, P21.)
- `i26-fresh`: "**modify**, narrowly". "The single change I ask for is F17 …
  With that change I would **accept**."
- `i26-cold`: "**modify**, narrowly". "Three changes, each one sentence or one
  line: C12, C13, and the live-document half of C9. C14 is optional. With those
  changes I would expect to accept."
- `i26-cold2`: "**modify**". "The core (R1 plus R2) is right, aligned with 0002,
  and verified against the binary. The cut went too far in two places (the
  one-worker path, and what a worker does at either end of its issue). It left
  debris in one (R3's token assumption). The acceptance criteria do not
  discriminate symptom 2."

**Standing-asides declared in round 4**, both by `i26-cold`, with its grounds:

- **C6, on the settle**: "My view stands: within a run, R1 leaves no second
  starter for an issue … But the step is cheap, and D7 is still open between
  participants. I will not block on it."
- **C9, on the 0002 half**: "The ruling answers the 0002 half, and its reading
  is defensible: 0002's reason, no differing identity on the read side,
  survives a per-command prefix." It holds C9's live-document half.

**Round 5 outcome: another round owed; objections are outstanding.** No
earlier finding is held. 21 findings open after round 4 were released by their
raisers in round 5, counting C9's held half; A6 and A11 are "reopened in
substance, raised as A17" by their raiser. 19 findings were raised in round 5.
Each participant's recommendation, as written:

- `i26-arch`: "**Recommendation: modify.** I was wrong on D9 and r5 is right:
  R1b belongs in #26. But R1b, as written, has two consequences r5 does not
  handle, and both are inside #26" (A16, A17). "Both fixes are one sentence
  each. The rest of r5 holds."
- `i26-evidence`: "**accept, with one wording change to one acceptance
  bullet** (E18)".
- `i26-pushback`: "**accept**, with two one-sentence amendments the
  implementing issue can carry" (P22, P23). "If the coordinator prefers to
  settle them before refinement, treat this as **modify**. I would accept on
  the strength of them being stated in the implementing issue."
- `i26-fresh`: "**modify**, on F19 only". "With a 'WIP refusal stops dispatch'
  rule, and the matching rewording of Loop control's stop list, I would
  **accept**."
- `i26-cold`: "**modify**, one clause (C15)". "C16 can be fixed in the same
  edit, or left to the implementing issue's wording. With C15 answered, I would
  accept."
- `i26-cold2`: "**accept, with two one-line changes**". "Before implementation,
  add: 1. **K12:** R1a's stop for a pool that cannot be started. 2. **K13:** the
  worker record names its token, and the concurrent starts launch together.
  K11 is optional. If K12 is not taken, my recommendation becomes **modify**".
- `i26-cold3`: "**modify**". "The core is right and buildable on 0.7.2. The
  clauses added in r5 (the one-worker case, R1a, R1b) each close their own
  finding but interact in two places that are undefined (Q1, Q2), and the
  acceptance criteria check a script more than the skill (Q4)."

**Standing-asides in round 5**, by `i26-cold`: C9's 0002 half, "**still
standing aside**": "Ruling 2 stands, and its reading is defensible". Its
standing-aside on C6's settle ends: C6 is "**released**, standing aside ends".

**Round 6 outcome: another round owed; objections are outstanding.** No
earlier finding is held. Every finding raised in round 5 is released by its
raiser, as are A6 and A11 (reopened in round 5) and C9's 0002 half. 23
findings were raised in round 6, by eight participants, one of them
(`i26-cold4`) new. Each participant's recommendation, as written:

- `i26-arch`: "**Recommendation: modify, by one clause.**" "The one thing I
  would change is new" (A18). "If the human prefers urgency-first ordering as
  a deliberate policy, I will stand aside on A18 rather than block. But then
  the subject has to state that urgency-first is a choice, not a limitation of
  git-zhi."
- `i26-evidence`: "**accept, with two acceptance edits** (E19, E20)".
- `i26-pushback`: "**accept, with three one-line amendments** (modify, if they
  must land before refinement)": P24, P25, and restoring the Loop control
  phrase to R1a (under P20).
- `i26-fresh`: "**accept**". "F20 and F21 are one sentence each and can ride
  with the implementing issue. Neither creates a loop or a hang that the text
  does not already rule out."
- `i26-cold`: "**modify**, small". "Fix C18 in R1c's report clause and K9's
  wording. C17 and C19 are one clause each and can ride in the same edit. With
  C18 answered, I would accept."
- `i26-cold2`: "**accept, with K14's two clauses**". "K15 is one restored
  sentence and is optional."
- `i26-cold3`: "**accept**". "Q9 and Q10 are each one phrase. I hold neither:
  either can be fixed in the edit or carried into the implementing issue's
  wording. Q9 is the one I would fix before implementation rather than after."
- `i26-cold4`: "**modify**". "fix the Acceptance contradiction (W1); correct
  or recover the 'Order' cost (W2); put W3 to the human; name the worker's
  return outcomes (W4)." "Nothing here argues for reject."

**Decisions named as the human's in round 6.** Two participants say in so many
words that a decision is the human's:

- `i26-cold4`, W2: "*Human's decision?* Yes. Whether urgency outranks the
  critical chain is a product choice about CCPM, not a selection fix." W3:
  "put W3 to the human", with three "Options for the human". W8: "*Human's
  decision?* Yes: whether that sentence in 0002 deserves an amendment later."
- `i26-arch`, A18: "Whether urgency then comes before creation order is the
  human's call", and it would "stand aside if the human rules urgency-first is
  deliberate, provided the false sentence about git-zhi is removed".

**Standing-asides in round 6.** `i26-cold`'s standing-aside on C9's 0002 half
ends: "**released** (until now I stood aside)". No participant declared a
new standing-aside; `i26-arch`'s on A18 is conditional on a ruling not yet
made.

**Round 7 outcome: another round owed; objections are outstanding.** Every
open round-6 row is released by its raiser. A10 and A15 are "Reopened in
substance by ruling 3; see A19" by their raiser. Every resumed participant
accepts rulings 3 and 4 (`i26-cold`: ruling 4 "accepted as policy"). 15
findings were raised in round 7, by nine participants, one of them
(`i26-cold5`) new. Six are declared bars by their raisers: A19, P26 ("the one
hold"), F22, C20, C21 and K16. W10 is open and "**Not held**". P27, Q11 and V1
to V6 are declared nits. Under ruling 5, round 8 is the last. Each
participant's recommendation, as written:

- `i26-arch`: "**Recommendation: modify, by one sentence (A19). Otherwise
  accept.**" "This is a bar, not a nit, because it is a direct contradiction
  between two clauses of r7 on a path the subject itself now keeps. The fix is
  the clause r3 already had."
- `i26-evidence`: "**accept**". "I hold nothing and raise nothing that bars
  shipping. Two nits for the implementing issue are listed below."
- `i26-pushback`: "**modify, by one sentence** (P26). Otherwise accept." "That
  is the only point I hold. P27 is a nit the implementing issue can carry."
- `i26-fresh`: "**modify**, by one sentence (F22)". "Otherwise, r7 is
  acceptable to me. If F22's sentence is recorded as binding on the
  implementing issue, I would **accept**."
- `i26-cold`: "**modify**, two sentences (C20, C21)". "Neither needs another
  round of argument. If the author makes both edits as stated, I would accept
  without a further round."
- `i26-cold2`: "**accept once K16's sentence is added**". "Without it, my
  recommendation becomes **modify**. Everything else is fixed point from my
  side."
- `i26-cold3`: "**accept**". "Nothing held. Q11 is a nit for the implementing
  issue."
- `i26-cold4`: "**modify**". "The change is one sentence for W10, plus R3's
  'unreachable' wording. I do not hold W10. If the author chooses to carry it
  to the implementing issue as a stated requirement, my recommendation becomes
  **accept**. Every round-6 row of mine is released."
- `i26-cold5`: "**accept**". "No bars. V1 to V6 are nits for the implementing
  issue. V1 and V2 are the two worth writing into that issue explicitly,
  because each is one sentence and each prevents a real failure."

**Standing-asides in round 7.** None declared. `i26-arch` on A18: "I am
releasing rather than standing aside."

**Round 8 outcome: no participant holds anything as a bar, and the round
raised new findings, every one declared a residual by its raiser.** Every open
round-7 row is released by its raiser. P27 is "**released, as a residual
carried by the binding section**"; V2, V3 and V6 are each "**released**, one
residual". `i26-cold` releases C21, withdrawing its own round-7 measurement
(D14). 15 findings were raised in round 8, by four participants, one of them
(`i26-cold6`) new: E21, P28 to P30, K17 to K19 and Z1 to Z8. `i26-fresh`,
`i26-cold3` and `i26-cold4` also name residuals without ids. No participant
declared a block or a standing-aside. Each participant's recommendation, as
written:

- `i26-arch`: "**Recommendation: accept.** I hold nothing, as either a bar or
  a residual."
- `i26-evidence`: "**accept**". "I hold one **residual** (E21: a paused issue)
  and one **record correction** to my round-7 nit (the tie-break). Neither is
  a bar."
- `i26-pushback`: "**accept**". "I hold nothing as a bar. P26 is answered. P27
  is carried by the binding section. Three residuals are recorded below for
  the implementing issue. None of them should stop #26 shipping."
- `i26-fresh`: "**accept**". "I hold nothing as a bar against #26. The one
  residual is the `--step` carve-out wording, for the implementing issue."
- `i26-cold`: "**accept**". "I hold nothing as a bar or as a residual."
- `i26-cold2`: "**accept**". "No bar remains from me." "K17, K18 and K19 are
  residuals for the implementing issue. K19 could instead be a one-word fix in
  Out of scope." "K17 is the one I would most want fixed in wording before
  implementation starts".
- `i26-cold3`: "**accept**". "Nothing is held as a bar. The two
  binding-section points and the R1c note are residuals for the implementing
  issue."
- `i26-cold4`: "**accept**". "My rows are all released. I name two residuals
  for the implementing issue, and neither is a bar."
- `i26-cold5`: "**accept**". "r8 answers every row I raised. The three
  residuals above are one sentence each, and all belong to the implementing
  issue. Nothing in r8 contradicts 0002, the body, or the binary."
- `i26-cold6`: "**accept**". "I found no bar. Every finding below is a
  residual the implementing issue can carry."

**Standing-asides in round 8.** None declared.

**What follows under ruling 5.** Round 8 is the bound. It did not reach a
strict fixed point, because it raised new findings. No participant holds any
of them, or anything else, as a bar. Under ruling 5, #26 is therefore accepted
at r8 with what remains open recorded as residuals; they are listed under
"Residuals carried to the implementing issue". This is acceptance with
residuals under ruling 5, not a fixed point. The disagreements below are not
marked resolved where their parties did not say so.

No participant declared a block in any round, and none declared a
standing-aside before round 4. (`i26-fresh` writes of F8(f) in round 3, "I note
this but do not block on it".)

## Participants

| | Role | Rounds | Context |
|---|---|---|---|
| `i26-arch` | participant | 1, 2, 3, 4, 5, 6, 7, 8 | dispatched fresh in round 1, resumed in rounds 2 to 8; codebase and architecture axes, read against decisions 0002 and 0003. In round 4 it read r4, then #27 through the REST API, then 0002 again, then ran its checks, and read `r3-r4.diff` last. In round 5 it read r5, then this ledger at `8e0d986` (D9 and the P19, C12, K3 and F3 rows), then #27's comments through the REST API, then ran its checks (J1 to J3), and read `r4-r5.diff` last. In round 6 it read `brief-r6.md`, then r6, then git-zhi's source for `list --critical` (`chain_list.go`) and `sortIssues`, then ran its checks (L1 to L3), and read `r5-r6.diff` last. In round 7 it read `brief-r7.md`, then r7, then `r6-r7.diff` last; it ran no new commands. In round 8 it read `brief-r8.md`, then r8 "with attention to R1 to R3 and the new 'Binding on the implementing issue' section", then `r7-r8.diff` last; it ran no new commands |
| `i26-evidence` | participant | 1, 2, 3, 4, 5, 6, 7, 8 | dispatched fresh in round 1, resumed in rounds 2 to 8; re-derived every behavioural claim in scratch repositories on 0.7.2. In round 4 it read r4, measured, and read the diff and this ledger last. In round 5 the same order; its script is `walk5.sh`, with the `--assign ""` probe in `r36`. In round 6 the same order; its script is `walk6.sh` (adding R1c's hold, the token-guarded `--unassign`, token-naming worker records and an urgency-then-creation order), with micro-tests in `r38` to `r40`. In round 7 it read r7, measured, and read `r6-r7.diff` and its ledger rows last; its script is `walk7.sh` (ruling 4's order, R1c's whole-pool report and exemption, worker records naming the worked and assigned ids, and `SCEN=reuse`), with the ordering probe `order.sh` and runs in `w7*` and `r41` to `r45`. In round 8 it read the subject, measured, and read `r7-r8.diff` and the ledger last; `walk7.sh` is unchanged ("r8's selection rules match it"), and its self-resume micro-tests are in `r46` to `r49` |
| `i26-pushback` | participant | 1, 2, 3, 4, 5, 6, 7, 8 | dispatched fresh in round 1, resumed in rounds 2 to 8; `paad:pushback` over the subject as a spec. In round 4 it read r4, then this ledger at `7ef0469`, then #27 through the REST API, then `r3-r4.diff`; it ran no new probes. In round 5 it read r5, then this ledger at `8e0d986`, then `r4-r5.diff` last; no new probes. In round 6 it read `brief-r6.md`, r6, this ledger at `eefe101` (for the round-5 ids), and `r5-r6.diff` last; probes of `issue edit --help` and `list --critical` in `probe26`. In round 7 it read `brief-r7.md`, r7, this ledger at `7614e9f` (D12, D13, and F21, E20, Q1, A10, F15, C7), and `r6-r7.diff` last; probe of `list --critical` in `probe26r7`. In round 8 it read `brief-r8.md`, r8, this ledger at `b2c0b85`, and `r7-r8.diff` last; probes of self-resume and `--state pause` in `probe26r7` |
| `i26-fresh` | participant | 2, 3, 4, 5, 6, 7, 8 | dispatched fresh in round 2, resumed in rounds 3 to 8. In round 2 it declared it did not open this ledger, any other `i26-*` report, r1 or the diff. In round 3 it read r3 and ran its checks first, then this ledger at `bd918b1`, then `r2-r3.diff`. In round 4 it read r4, execute.md Step 2, the ledger rows on the one-worker path, #27 through the REST API, then `r3-r4.diff`; it re-ran nothing. In round 5 it read r5, then execute.md Step 2, Step 4's return and Loop control, then ran one new probe, then this ledger at `8e0d986` (the P17, C4, C12 and K3 rows), and `r4-r5.diff` last. In round 6 it read r6, ran probes in `scratch-fresh/`, then this ledger at `eefe101` (D10, D11), and `r5-r6.diff` last. In round 7 it read r7, ran a probe in `scratch-fresh/`, then read `r6-r7.diff` last; it did not open the ledger. In round 8 it read r8, then `r7-r8.diff` last; it did not re-run any probes |
| `i26-cold` | participant | 3, 4, 5, 6, 7, 8 | dispatched fresh in round 3 with no prior findings or revisions. Declared it did not open this ledger, any `i26-*` file, any diff, `subject.md` or `subject-r2.md`. Read crochet's `CLAUDE.md`, `ARCHITECTURE.md`, decision 0002, `execute.md` and parts of `how-to-use-git-zhi`, git-zhi source, and the body of git-zhi#35 through the GitHub API. Resumed in round 4: read r4, then this ledger at `7ef0469`, then `r3-r4.diff`; did not read #27's text. In round 5 it read r5, then this ledger at `8e0d986` (round-4 rows, via `git show`), then `r4-r5.diff`; probes in `scratch-cold/r5/`. In round 6 it read r6, then `brief-r6.md`, then `r5-r6.diff` last; probes in `scratch-cold/r6/` and `scratch-cold/r6b/`. In round 7 it read r7, then `brief-r7.md`, then `r6-r7.diff` last; probes in `scratch-cold/r6b/`. In round 8 it read r8, then `brief-r8.md`, then `r7-r8.diff` last; probes in `scratch-cold/r6b/` |
| `i26-cold2` | participant | 4, 5, 6, 7, 8 | dispatched fresh in round 4 with no prior findings; resumed in rounds 5 to 8. Declared it did not open any earlier subject, this assessment record, any `i26-*` file or any diff. Read crochet's `CLAUDE.md`, `ARCHITECTURE.md`, decision 0002, `execute.md` and parts of `how-to-use-git-zhi`; git-zhi's `Graph.headForActor`, `checkWIPLimit` and `checkBlockers`; and git-zhi#35 and #36 through the REST API. In round 5 it read r5, then this ledger at `8e0d986` (its K rows, and rows C4, C12 to C14, E17, F17, P19 to P21), and `r4-r5.diff` last; probes continue round 4's repository in `scratch-cold2/`. In round 6 it read `brief-r6.md`, then r6, then `r5-r6.diff` last, and did not re-read this ledger; observations O11 to O13. In round 7 it read r7, then `r6-r7.diff` last, and did not re-read this ledger; observations O14 to O16. In round 8 it read r8, then `r7-r8.diff` last, and did not re-read this ledger at `b2c0b85` |
| `i26-cold3` | participant | 5, 6, 7, 8 | dispatched fresh in round 5 with no prior findings; resumed in rounds 6 to 8. Declared it read r5 only: no earlier revision, no assessment record, no other participant's file, and not #27. Takes the two human rulings as settled. Read in full crochet's `CLAUDE.md`, `ARCHITECTURE.md`, decision 0002, `execute.md` and `how-to-use-git-zhi.md`, and grepped the live skills for other selection and identity claims. Probes in `scratch-cold3/`. In round 6 it read r6, then `r5-r6.diff` last, and this ledger's rows Q1 to Q8, D10, D11, and A17, P22, F19, C15 and K12; it read git-zhi source on `Urgency`. In round 7 it read r7, then `r6-r7.diff` last, and this ledger's rows Q1 to Q10, A18, W2, W3, E20, F21 and P24; it ran nothing new. In round 8 it read r8, then `r7-r8.diff` last, and this ledger's D15 and its own rows at `b2c0b85`; it re-measured self-resume in `scratch-cold3/` |
| `i26-cold4` | participant | 6, 7, 8 | dispatched fresh in round 6 with no prior findings; resumed in rounds 7 and 8. "I read it without prior findings. The finding ids it cites are labels to me." Read in full crochet's `CLAUDE.md`, `ARCHITECTURE.md`, decision 0002 and `execute.md`, and the relevant parts of `how-to-use-git-zhi.md` and `postmortem.md`; in git-zhi 0.7.2, `Graph.headForActor`, `sortIssues`, `checkWIPLimit` and `runChainList`. Probes in `scratch-cold4/`. In round 7 it read r7, then this ledger at `7614e9f` for its rows and D12 and D13, then `r6-r7.diff`; probes in `scratch-cold4/`. In round 8 it read r8, then `r7-r8.diff` last; it ran nothing new |
| `i26-cold5` | participant | 7, 8 | dispatched fresh in round 7 with no prior findings; resumed in round 8. Declared it read r7 only: "no earlier revision, record, brief, diff or #27". Read in full crochet's `CLAUDE.md`, `ARCHITECTURE.md`, decision 0002 and `execute.md`, the `ZHI_ACTOR` section of `how-to-use-git-zhi.md` and the relevant paragraph of `postmortem.md`; in git-zhi at `7b9287d`, `Graph.headForActor`, `ReadySet`, `sortIssues`, `runChainNext`, `runChainListReady`, `checkWIPLimit` and `checkBlockers`. Probes in `scratch-cold5/`. In round 8 it read r8, then the brief, then its rows V1 to V6 in this ledger at `b2c0b85`, then `r7-r8.diff` last; probes in `scratch-cold5/`, reused. "I did not read other participants' r8 reports." |
| `i26-cold6` | participant | 8 | dispatched fresh in round 8 with no prior findings. Declared it read r8 only: "I did not open the record, any other `i26-*` file, any diff, any brief, any other subject revision, or #27." Read in full crochet's `CLAUDE.md`, `docs/ARCHITECTURE.md`, decision 0002, `execute.md` and `how-to-use-git-zhi.md`; spot reads of `postmortem.md` lines 95-115, git-zhi's `internal/graph/graph.go` (`Head`, `headGlobal`, `headForActor`) and `.claude-plugin/plugin.json`. Probes on 0.7.2 in `scratch-cold6/` |
| orchestrating session | drafter, round 1 | 1 | held no view on the subject; was not r1's author |
| round-2 drafter | drafter, round 2 | 2 | a separately dispatched subagent holding no view on the subject. The orchestrating session could not draft round 2, because it became the subject's author at r2 |
| round-3 drafter | drafter, round 3 | 3 | again a separately dispatched subagent holding no view on the subject |
| round-4 drafter | drafter, round 4 | 4 | again a separately dispatched subagent holding no view on the subject |
| round-5 drafter | drafter, round 5 | 5 | again a separately dispatched subagent holding no view on the subject |
| round-6 drafter | drafter, round 6 | 6 | again a separately dispatched subagent holding no view on the subject |
| round-7 drafter | drafter, round 7 | 7 | again a separately dispatched subagent holding no view on the subject |
| round-8 drafter | drafter, round 8 | 8 | again a separately dispatched subagent holding no view on the subject |

r1's author, an agent running `crochet:execute` on pvm's `m2-incremental`, did
not sit. r2's author, the orchestrating session, wrote the revision and
submitted no report in round 2. r3's author made the D2 and D4 measurements
recorded in r3 and submitted no participant report in round 3. r4's author
submitted no participant report in round 4. r5's author submitted no
participant report in round 5. r6's author submitted no participant report in
round 6; after round 6 it made the measurement recorded above. r7's author
submitted no participant report in round 7; it filed git-zhi#37 after round 6
and made the measurement bearing on C21 recorded above. r8's author submitted
no participant report in round 8. Every participant reported by writing a
file; no report was truncated and no participant died. No participant reports
reading another's round-4, round-5, round-6, round-7 or round-8 report.

## The three axes

As the participants stated them. Round-8 statements come first; the round-7,
round-6, round-5, round-4 and round-3 statements follow as they were recorded,
since r4 removed much of what round 3 concerns.

### After round 8

1. **Codebase.**
   - Self-resume on 0.7.2, under the issue's own token with its session open:
     `next` returns the in-progress issue; `start` is refused, `cannot start:
     issue is in-progress, expected pending or reopened`; `--state resume` is
     refused, `cannot resume: a measurement session is already open`
     (`i26-evidence` r46, `i26-pushback`, `i26-cold3`, `i26-cold6`).
     `i26-evidence`: r8's rule, no transition, then `done`, succeeds with
     "The assignment is kept"; the bracket through R2, R3 and R1b strands the
     issue. `i26-cold5`, from source: "`start` and `resume` both refuse when a
     session is open, with `cannot %s: a measurement session is already
     open`, so not starting again is required, not optional".
   - After `--state pause` by the same actor, `--state resume` succeeds and
     `next` still returns the issue; with no transition, `done` measures only
     the window before the pause, or is refused with `session has 0 commits`
     (`i26-evidence` r47 to r49, E21; `i26-pushback`, P28). Neither finds
     `--state pause` or `--state resume` anywhere under `skills/`.
   - `list --critical --format json` has the keys `critical_chain`,
     `current_constraint`, `issues` and `parallel_work`; `critical_chain` holds
     the chain in order, upstream first (`i26-cold` re-measured, `i26-cold5`,
     `i26-cold6`).
   - `issue list --ready --milestone <m> --format json` carries `assigned`
     and `created`; `assigned` is absent when unset (`i26-cold5`,
     `i26-cold6`; `i26-evidence`: `has("assigned") == false`, and `issue show`
     and `next` omit it too). `git zhi list --ready`'s JSON has no `assigned`
     (`i26-cold5`).
   - `i26-evidence`'s `walk7.sh` re-run: CAP=2 `none`, `steal`, `wipin`,
     `wipout`, `human` PASS 3/3 each; CAP=1 `none`, `wipout`, `reuse` PASS;
     `REUSE=1` FAILs as a negative control; red FAILs at CAP=2 and CAP=1.
   - `i26-cold6` (Z1): under `wip_limit` 1, a reopened issue whose start is
     refused is left `reopened`, assigned and in the ready set. Also: a
     `wip_limit` refusal leaves the issue `pending`; `--assign` adds no
     transition; `--unassign` exists.
2. **Architecture.**
   - `i26-cold6`: "**Inside 0002.**" "R1 restores one of 0002's premises":
     "an orchestrator is a single serialisation point with no race to solve".
     Z8 names one wording risk against "Identity is fixed for the life of a
     worker".
   - `i26-cold5`: "Nothing in r8 contradicts 0002, the body, or the binary."
   - V5's `docs/ARCHITECTURE.md` site is doc-first: `i26-arch` ("as
     `CLAUDE.md` requires"), `i26-pushback`, `i26-fresh`, `i26-cold5`,
     `i26-cold6`.
   - The binding section: every participant that reports the brief's check
     finds nothing in it that must become a body requirement. `i26-evidence`
     names E21's qualifier as "a sentence in R1". The tensions named against
     the body are `--step`, the retry bound and the reused-token lines.
   - `i26-pushback`'s growth check: "I found no clause citing neither a
     round-7 finding nor a ruling."
3. **Direction.**
   - `i26-cold`: "Is r8 still the core? Yes." "The binding section moves
     detail to the implementer, which is where it should go."
   - `i26-cold6`: "No human gate is added." r8 "removes two live defects" and
     a third, "`export` does not survive between shell invocations in agent
     harnesses. It adds nothing that makes the skill worse."
   - On R1c's widening: `i26-arch`, "An unneeded halt costs throughput, never
     termination"; `i26-fresh`, "conservative and bounded"; `i26-cold2`,
     "stricter than it needs to be … But it cannot loop or hang"; `i26-cold4`,
     "it stops and reports rather than looping"; `i26-cold3` names a rare
     early end as a residual.
   - `i26-fresh`: on the one-worker path, under the old token, "`next` resumes
     own work (`headForActor` step 1), so the agent never picks."

### After round 7

1. **Codebase.**
   - Self-resume on 0.7.2, as the issue's own actor: bare `next` returns the
     held in-progress issue; `--state start` is refused, `cannot start: issue
     is in-progress, expected pending or reopened`; `--state resume` is
     refused, `cannot resume: a measurement session is already open`
     (`i26-fresh`; `i26-cold2` O14 to O16; `i26-cold4` for `next` and start).
     See D15.
   - `list --critical`: see D14 for each observation and the author's
     measurement. `i26-evidence`: with `--milestone`, `issues` is filtered and
     `critical_chain` is repo-wide; it is `null` when all are done; ties go to
     the lower UUID; in r42 the chain moved to `other` once `mroot` was done.
     `i26-cold5`: `list --critical --milestone m1` returns m2's chain.
   - `i26-evidence`'s `walk7.sh`: the R1c stop names the whole remaining pool,
     PASS at CAP=2 (5/5) and CAP=1 (3/3, the run ends); `wipin` PASS 5/5; a run
     cut short without an R1c stop FAILs with `never dispatched: [m4]`.
     `REUSE=1` FAILs (`worked an issue other than its assignment: [m1 m2
     m3]`), `REUSE=0` PASSes 3/3. Green suite PASS; red bracket FAIL at CAP=2
     and CAP=1.
   - Ruling 4's order (`i26-evidence`, `order.sh`): recovered when the
     milestone holds the chain (r44), lost otherwise (r41). "Nothing in the
     pass conditions depends on order, so this cost is efficiency, not
     correctness."
   - `i26-cold5`: `--assign` and `--unassign` append no transition; `list
     --ready --format json` carries only `id`, `title`, `paths`, and
     `assigned` is `omitempty` (V3); `issue edit --help` does not list
     `reopen`; a `wip_limit` refusal reads `WIP limit reached: 1 issue(s)
     already in progress (limit 1); ...`; an assignment steers `next`.
   - `i26-cold`: `issue list --help` shows `--assigned string  filter by
     assigned worker`, "with no way to ask for unassigned issues".
2. **Architecture.**
   - Rulings 3 and 4 are accepted by all eight resumed participants;
     `i26-cold` accepts ruling 4 "as policy". `i26-cold5`, which did not read
     the rulings, finds the fresh token per issue within 0002: "Reading
     'worker' as one dispatch matches 0002's own per-dispatch minting."
   - `i26-cold5`: "Inside 0002." R1's use of the ready query is the
     orchestrator's choice, "which 0002 permits"; "Doc-first: the live layer
     is not falsified, apart from the loose word in V5."
   - `i26-arch`: the C19 and W7 changes "support the Q8 reading of 0002
     rather than altering it". `i26-pushback`: P1 stands on W8's note.
   - Self-resume against R3: A19, P26, F22, C20, K16, W10; `i26-cold3`
     disagrees. See D15.
3. **Direction.**
   - `i26-cold`: "Is r7 still the core? Yes." "The growth comes from
     contradictions between clauses, not from new scope."
   - `i26-cold5`: "Positive." r7 "removes both causes, and adds termination
     rules (R1a, R1c) that end in one named report rather than a spin or a
     silent stall." "The one autonomy risk I see is V1."
   - `i26-arch`: on the one-worker path, "Ending on the single agent's own
     refusal is the correct exit".
   - `i26-cold2`: every pass condition can be scripted, and "The control …
     still discriminates both symptoms".
   - `i26-cold3`: dropping `urgency` "costs nothing I care about";
     "Refinement's intent, that doc issues come after code, survives creation
     order."
   - `i26-cold2` on self-resume: the failure is on "the 'continue' path, which
     Loop control makes routine: every pause ends the turn and the user
     re-prompts."

### After round 6

1. **Codebase.**
   - `--unassign` exists in `issue edit --help`: `i26-pushback`, `i26-fresh`,
     `i26-cold`, `i26-cold2` (O11).
   - `i26-evidence`'s `walk6.sh`: R1c on, `wipout`, CAP=2: two refusals, both
     unassigned, then `R1c stop`, 2 dispatches; R1c off, the same setup loops
     to its cap of 20 dispatches. `wipin`: the refused issue is re-dispatched
     once the slot frees, PASS. Green PASS in `none`, `steal`, `wipin`,
     `human` and CAP=1 `none`; red FAIL at CAP=2 and CAP=1.
   - The token guard: a guarded clear left `human:bob`; the unguarded bracket
     dropped it (`i26-evidence`, r38). With `SCEN=human`, m2 stayed
     `pending:human:alice` and was never dispatched.
   - A reused token whose earlier issue was reopened gets that issue from
     `next` in place of the pick (`i26-evidence`, r39). See E20, D13.
   - A `wip_limit` refusal happens at start and never at `next`, and the issue
     stays `pending` (`i26-cold4`).
   - `list --critical`: see D12 for each observation and the author's
     measurement. `urgency` is the strings `high`, `normal`, `low`, read by
     nothing under `internal/graph/` (`i26-cold3`, `i26-cold4`, `i26-arch`);
     it can be set only through frontmatter or a batch edit (`i26-evidence`).
   - `issue list --assigned ""` returns every issue (`i26-cold4`, W7).
   - `postmortem.md` does say "whether `ZHI_ACTOR` was exported" (`i26-arch`
     L3, `i26-pushback`, `i26-cold2` O13).
   - A pool issue blocked from another milestone is absent from the pool, so
     the pool and `next` agree (`i26-cold`).
2. **Architecture.**
   - R1b and start-up reclamation "are consistent and disjoint" (`i26-arch`).
     The guard honours 0002's "never touch another's assignment"
     (`i26-cold2`, `i26-cold`, `i26-pushback`).
   - Ruling 2: `i26-cold` releases C9's 0002 half. `i26-cold4`: ruling 2 does
     not cover one agent switching tokens between issues (W3). See D6, D13.
   - The Q8 sentence: `i26-arch` and `i26-pushback` read it as their D3
     answer; `i26-cold` (C19) and `i26-cold4` (W7) question its wording;
     `i26-cold4` (W8) calls 0002's `next` sentence nominal. See D3.
   - `i26-cold4`: "The orchestrator acts as the single serialisation point,
     which is 0002's own non-goal argument."
3. **Direction.**
   - Composition: `i26-arch`, `i26-pushback`, `i26-fresh`, `i26-cold`,
     `i26-cold2`, `i26-cold3`, `i26-evidence` and `i26-cold4` each find no
     loop or hang from R1a, R1b and R1c on the parallel path; `i26-cold4`
     names one unbounded stand-down path through R2 (W4). On the one-worker
     path, see the self-wait cluster.
   - `i26-cold`: "Is r6 still the core? Yes." "r6 is longer, but no larger in
     scope than r4."
   - `i26-cold4`: "The change removes both symptoms without waiting on
     git-zhi. It keeps running through by default, and it ends with a report
     that names the issue rather than looping." The costs for the human are
     "the change of priority policy (W2) and the loss of self-resume (W3)".
   - `i26-arch`: critical-chain scheduling "is the core of what git-zhi does,
     and r6 gives it up for no reason that survives L1" (A18). `i26-cold3`:
     a "throughput cost, not a correctness one".
   - `i26-cold4` (W9): the rules' reasons live in the archive, so an agent
     "will 'simplify' a rule whose purpose it cannot see".

### After round 5

1. **Codebase.**
   - `--assign ""` clears an assignment and the issue returns to the filtered
     pool: `i26-evidence` (r36: pool `["a","b"]` after the clear), `i26-arch`
     (J2, J3), `i26-fresh` (`[('C', None)]`), `i26-cold3`. `--unassign` is the
     documented equivalent (`i26-evidence`, `i26-arch`, `i26-cold3`).
   - `i26-evidence`'s `walk5.sh` against r5's Acceptance: green PASS 9/9
     (wip), 9/9 (steal), 8/8 (none), 2/2 (one-worker, CAP=1); red FAIL at
     CAP=2 (6 off-milestone, five issues worked by two) and CAP=1 (3
     off-milestone). Refused starts re-dispatched 27 of 27; lost starts 0 of 3,
     the issue left "in progress under `agent:intruder`".
   - A WIP refusal with the slot held outside the run repeats after the clear:
     `i26-cold` (three dispatches, `pool=["r1"]` each time), `i26-cold2` (O10,
     three cycles), `i26-arch` (J1 to J3, one cycle), `i26-fresh` (one cycle),
     `i26-cold3` (the refusal). See the `wip_limit` cluster.
   - `i26-cold3`: bare `next` as an unassigned agent returned m2's X; an
     assignment "steers `next` off the critical chain (R2 holds)";
     `transitions[]` carries `actor`, "so R3's check is readable".
   - `i26-cold3`: `issue list --ready --milestone` returns creation order, and
     `list --critical`'s `critical_chain` ignores `--milestone` (Q3). The same
     actor starting a second issue while one is in progress gets rc 0, "start
     does not enforce per-worker WIP".
   - `i26-cold3`: `issue list --ready` omits `assigned` when empty, as
     `i26-cold2`'s round-4 O3.
   - `i26-pushback` ran no new probes. Its R5 targets exist at this revision:
     execute.md L132 and L169, and `how-to-use-git-zhi.md` L132–135.
2. **Architecture.**
   - R1b against 0002: `i26-arch`: "R1b does not conflict with 0002's
     reclamation rules, provided it is guarded (A16)". It "sits inside the
     question 0002 left open".
   - `i26-cold3`: R1 and R2 "fit 0002 better than the current text does",
     since 0002's Non-goals rest on "an orchestrator is a single serialisation
     point with no race to solve", which R1 makes true. "None of the live-layer
     claims I checked become false, so doc-first asks for no ARCHITECTURE.md
     edit." Tensions: 0002 calls the ready-set query "wrong" (Q8); identity
     fixed for a worker's life against the one-worker branch (Q1).
   - The one-worker token: P23, C16, K11, Q1 against `i26-fresh`. See D10.
   - Ruling 2: `i26-cold` still stands aside on C9's 0002 half; `i26-cold3`
     takes both rulings as settled. See D6.
   - `i26-pushback`: "R1a and R1b do not re-import #27." `i26-cold`: "Nothing
     in r5 reaches the post-selection lifecycle, which #27 holds."
3. **Direction.**
   - `i26-cold`: "Is r5 still the core? Yes." "every addition is either
     selection bookkeeping or a way to falsify the claim."
   - `i26-cold3`: "The direction is good." The orchestrator "becomes the one
     place where choice happens. That place is easier for a human to audit."
     Against autonomy: the `wip_limit` loop (Q2), and dropped critical-chain
     priority inside a milestone (Q3), "Agents finish the work, but slower than
     the chain says they could."
   - `i26-pushback` (P22): "an unattended run that spins fresh workers until
     something external frees a slot or the session is killed". `i26-cold`
     (C15): "burning workers until a person intervenes".
   - `i26-evidence`: the `wip_limit` churn it measured "is a cost, not a
     correctness problem".
   - `i26-fresh`: R1a's re-dispatch at batch end "costs throughput, and no
     requirement depends on it".

### After round 4

1. **Codebase.**
   - R1 and R2 keep workers in the milestone and give them distinct issues
     wherever R1 applies. `i26-arch` (H1): two workers assigned from mA's
     filtered ready set and run concurrently got A1 and A2; unassigned, the same
     `next` returns B1. `i26-cold2` (O2): an assignment "overrides
     critical-chain order". `i26-cold`: assigned, `next` returns `r1`.
   - `i26-evidence`'s r4 walkthrough (`walk4.sh`) "goes green under R1 to R4 and
     red without them, so it can fail": green 26/26; red failed 3/3 (5
     off-milestone starts and 3 doubly worked issues per run). With R3's check
     off (`walk4nc.sh`), w3 worked m3 in 20/20 forced races; with it on, w3
     worked while the intruder was final owner in 0/20. "R3's single settled
     check catches the lost concurrent start without the re-check before
     `done`."
   - Unassigned bare `next` drifts to the milestone leading the critical chain:
     `i26-cold` (`o1`), `i26-cold2` (O1, O9), and `i26-fresh`'s reused round-2
     observation (X1 from m2).
   - An assignment left on an issue removes it from R1's pool: `i26-cold`'s
     probe returned `[]`; `i26-cold2` (O7, O8): under `wip_limit 1`, `next`
     returned m1 ("`next` does not check WIP"), `start` was refused, and "m1 has
     left the pool for the rest of the run". `issue edit <id> --assign ""`
     unassigns (O5).
   - `i26-cold2` (O3): `issue list --ready --milestone` omits the `assigned` key
     when it is empty. (O4): two assignments on one token, `next` returns the
     first in ReadySet order.
   - `issue edit "" --state start` starts the HEAD issue, here off the
     milestone, rc 0 (`i26-evidence`, repo r35): git-zhi#36, confirmed.
   - A lost update erases the duplicate from the chain: in red runs two workers
     worked one issue and the chain records one actor (`i26-evidence`, E17).
     `i26-cold2` (K8) makes the same point from git-zhi#35's body.
   - `checkWIPLimit` reads the limit from chain config and counts chain-wide;
     `<= 0` means no limit (`i26-arch`, H2, from source; `i26-cold2` read the
     same function).
   - `i26-pushback` ran no new probes; `i26-fresh` re-ran nothing.
2. **Architecture.**
   - Ruling 2 (D6): `i26-arch`: "The ruling fits the decision's text, not only
     its intent", and "What 0002 says that the ruling makes less true:
     … 're-exporting is the only way to break it'". `i26-pushback`: answered.
     `i26-fresh`: "no objection". `i26-cold`: standing aside on the 0002 half.
     `i26-cold2`: "Ruling 2 (R4) is settled, and I take it as given." See D6.
   - `i26-cold2`: "R1 is 0002 as written, more literally than today's execute.md
     is." "There is one tension. 0002's recovery story assumes one token per
     *worker* … R3's prose … assumes a token per *issue/dispatch*." (K2; cf.
     C14, A15.)
   - `how-to-use-git-zhi.md` still tells agents to export `ZHI_ACTOR`, and it is
     not in "Where it goes" (C9's held half, `i26-cold`; K6, `i26-cold2`).
   - execute.md text describing the self-selection design remains outside R5
     (K5, `i26-cold2`).
   - Whether r4's deferral to #27 is legitimate: `i26-pushback`: "Yes for the
     *after-selection* lifecycle … No for P19 and P20." `i26-cold` (C12, C13)
     and `i26-cold2` (K1, K3) place the stranded assignment and the one-worker
     drift in #26; `i26-arch` and `i26-fresh` place the stranded assignment in
     #27. See D9.
3. **Direction.**
   - `i26-arch`: A8 still released. "the run is unattended; the lifecycle gaps
     that could stop it are named in #27 rather than hidden."
   - `i26-pushback`: "The narrowing is legitimate for nearly everything it
     moves." "The narrowing removed more than the ruling required: three
     selection-scope clauses went out with the lifecycle material (P19–P21)."
   - `i26-fresh`: "R1 to R5 are coherent without a lifecycle, and F1 does not
     reapply."
   - `i26-cold`: "r4 is now proportionate to #26. I raise nothing against its
     scope."
   - `i26-cold2`: "Standing down and returning to the orchestrator, rather than
     asking a person, serves autonomy." But a stood-down issue stays assigned,
     which "converts a recoverable event into a human interruption, which is
     what Loop control exists to prevent."

### After round 3

Round-2 statements that a round-3 report did not revisit are kept and marked.

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
round 3, 4, 5, 6, 7 or 8 is recorded as having made no declaration in that round; its
last declaration stands. "Released: out of scope, in #27" is a release by the
raiser, in the raiser's words; the raiser's own report says where it still
holds the finding live.

**Round-8 declarations on rows before round 7**, made in a sentence rather than
row by row, and recorded here in the raiser's words. The rows' status cells are
updated only where the raiser named the row (F3, W4).

- `i26-arch`: "**All other rows**, A1 to A18, stay released on their recorded
  grounds."
- `i26-evidence`: E19 and E20 "**released** (round 7; re-run holds)"; "E1 to
  E18 **still released**", "reproduced by this round's red and green runs".
- `i26-fresh`: "F1, F4, F8, F17, F19, F20 and F21 stay released. Nothing in r8
  reopens them. F3, F11 to F14 and F16 remain live in #27, and I hold them
  there."
- `i26-cold2`: "K1 to K15 still hold against r8."
- `i26-cold4`: W4's nit "**released**"; "My rows are all released."
- `i26-pushback`, `i26-cold` and `i26-cold3` make no declaration on rows before
  round 7 in round 8.

### Round-1 findings

| id | raiser | round | section of the subject | consequence if it ships | evidence | status | revision |
|---|---|---|---|---|---|---|---|
| A1 / P4 / E4 | i26-arch, i26-pushback, i26-evidence | 1 | What happened, bullet 2 | the collision persists under either option | same-milestone repro: w1 and w2 both get `b1` from `next` | **A1 released** (`i26-arch`): r2 places duplication in one milestone; R1+R2 remove the convergence, "only if A9 is fixed". **P4 released** (`i26-pushback`): problem §2 restated; R3 checks the actor. **E4 released** (`i26-evidence`): R1+R2 give distinct issues, measured. **r3:** A1 "still released", re-attacked: "It holds only if A12 is fixed by re-dispatching under a token rather than by any path that leaves a worker without an assignment." P4 "stay[s] released": R5. E4: no round-3 declaration. **r4:** A1 "still released, now on observation (H1)": "It never rested on R3/R5"; R3 "is defence in depth against git-zhi#35". P4 "stands": "R3: literal id, a settle, re-read, retry a failed read, stand down when lost." E4: no round-4 declaration. **r5:** A1 "still released": R1's "fresh `<n>`" per dispatch "keeps tokens disjoint", and R1b "only *removes* assignments, so it cannot hand one issue to two tokens". P4 stands, "Unchanged in substance". E4: no round-5 declaration. **r6:** A1 "still released": "Fresh `<n>` on every pick, now on the one-worker path too, keeps tokens disjoint." P4 stands, "Unchanged". E4 "still released" ("E1 to E17"). **r7:** A1 "Unchanged" (`i26-arch`). P4: no round-7 declaration. E4 "still released" ("E1 to E18") | d2de72f |
| E4 | i26-evidence | 1 | (absent) | git-zhi's start is not mutually exclusive under concurrency | 20/20 concurrent `--state start` pairs both exit 0, one transition survives; `storage.WriteEntity` writes the ref unconditionally, no CAS. Sequential second start fails (exit 1) from 20 ms apart | **released** (`i26-evidence`): filed as git-zhi#35, with R3 as mitigation; the residue is E10. **r3:** no declaration; r26 re-measured both starts exiting 0 in 80/80. **r4:** no declaration. Its walkthrough's forced race gave both starts rc 0 in 20/20 (see E17). **r5:** no declaration. **r6:** "still released" ("E1 to E17"); the red re-run reproduces doubled work. **r7:** "still released" ("E1 to E18"); the round-7 red bracket reproduces doubled work | 7b9287d |
| A2 / P4 | i26-arch, i26-pushback | 1 | Proposed change | a worker that lost the start still does the work, as on pvm | sequential second start: `cannot start: issue is in-progress`; Step 2 says nothing about a refused start | **A2 released** (`i26-arch`): R3 checks post-state, and C3 found no double ownership; residue moved to A10. **P4 released** (`i26-pushback`), as above. **r3:** A2 "still released", re-attacked: R5 "is stronger than r2's R3"; "D1 is still unresolved between participants". P4 stays released. **r4:** A2 "still released": "Dropping the re-check before `done` and push loses nothing I asked for." P4 stands, as above. **r5:** A2 "still released" ("A2 / A10"): "R3 is unchanged." P4 stands, as above. **r6:** A2 "unchanged by r6", stays released. P4 stands. **r7:** A2: "All others stay released on the grounds already recorded" (`i26-arch`). P4: no round-7 declaration | d2de72f |
| E9 | i26-evidence | 1 | Where it goes | execute's start paragraph overstates what start guarantees | given E4, "this records a transition … which is what makes the selection above work" is not true under concurrency | **released** (`i26-evidence`): R5 commits to correcting it; wording is to be checked at review. **r3:** no declaration (r3's R9 cites E9). **r4:** no declaration. r4's R5 cites E9. **r5:** no declaration. r5's R5 cites E9 and K5. **r6:** "still released" ("E1 to E17"). r6's R5 cites E9 and K5. **r7:** "still released" ("E1 to E18") | d2de72f |
| P2 / E6 | i26-pushback, i26-evidence | 1 | Proposed change, option 1 | only the first pick is scoped; a worker that finishes its issue drifts off the milestone again | Step 4 returns to Step 2; measured drift to another milestone and collision there | **P2 released** (`i26-pushback`): R1 names the finish trigger; residue raised as P8. **E6 released** (`i26-evidence`): R1, R2 and R4 answer it; in the walkthrough a surplus worker stood down. **r3:** P2 stays released, "superseded by R1's lifecycle". E6: `walk.sh` re-run gave an identical result, which "re-proves E1, E2, E5 and E6". **r4:** P2 "stands": R1 "at every dispatch, including when it dispatches again after workers return". E6: no declaration. **r5:** P2 "**stands**": "R1a: 'On each return the orchestrator runs R1 again'". E6: no declaration. **r6:** P2 stands: "R1a re-runs R1 on each return." E6 "still released" ("E1 to E17"). **r7:** P2 stands (`i26-pushback`). E6 "still released" ("E1 to E18") | d2de72f |
| A3 / P3 / E7 | i26-arch, i26-pushback, i26-evidence | 1 | Proposed change, option 1 | a hand-built ready set admits in-progress issues and misses cross-milestone blockers | `issue list --ready --milestone <m> --format json` already returns the ready set on 0.7.2 | **A3 released** (`i26-arch`): R1 names the query (C1). **P3 released** (`i26-pushback`): the query excludes in-progress issues, confirmed. **E7 released** (`i26-evidence`), superseded by E11. **r3:** A3 "still released, with A14". P3 stays released: R3 keeps git-zhi's query and adds E11's filter. E7: no declaration. **r4:** A3 "still released": R1 "computes no ready rule by hand". P3 "stands". E7: no declaration. **r5:** A3 "still released": "r5 adds no hand-computed rule". P3 stands. E7: no declaration. **r6:** A3 "still released, and see A18": "The ready rule is still git-zhi's. Ordering is a separate matter." P3 stands. E7 "still released" ("E1 to E17"). **r7:** A3 "Unchanged" (`i26-arch`). P3: no round-7 declaration. E7 "still released" ("E1 to E18") | d2de72f |
| A4 / P1 | i26-arch, i26-pushback | 1 | Proposed change, option 1; Where it goes | contradicts accepted 0002 without amending it | 0002 names bare `next`; "Where it goes" lists only execute.md | **A4 released** (`i26-arch`): r2 stays inside 0002 and R2 adds the stop rule; the new orchestrator role relative to `execute.md` is A9. **P1 released** (`i26-pushback`): no frozen text falsified. **r3:** A4 "still released; D3 judged: within 0002, no amendment". P1 "stays released on its subject, which is selection"; the R7 contradiction "is raised as P18 rather than by re-holding P1". See D3, D6. **r4:** A4 "still released" ("A4 / D3"): R2 "is 0002 'Assignment is a hint'". P1 "stands": "R2 answers D3 in so many words", and ruling 2 "covers the identity letter". See D3. **r5:** A4 "still released" ("A4 / D3"): r5 "keeps bare `next`". P1 stands, "Unchanged in substance". **r6:** A4 "still released" ("A4 / D3"): the Q8 sentence "is the reading of 0002 I gave in round 3, now stated in the subject". P1 stands: "Q8's sentence … reinforces P1's D3 answer". **r7:** A4 "Unchanged" ("A1, A3, A4/D3"): "The C19 quotation fix and the W7 note on `--assigned` support the Q8 reading of 0002 rather than altering it." P1 stands: "W8 ('`next` hands over and confirms') is recorded rather than changed, and 0002 keeps naming bare `next`. That is the D3 reading I released on." | d2de72f |
| A5 / P5 / E8 | all three | 1 | Proposed change, option 2 | a criterion satisfiable only by another repository; and if modelled on `--label` it loses resume-own and assignment preference | `--label` measured to ignore actor; ~20–40 lines inside `headForActor` | **A5 released** (`i26-arch`): out of scope, routed through `git_zhi_min_version`; git-zhi#35 records the `--label` hazard. **P5 released** (`i26-pushback`), see the P5 row. **E8 released** (`i26-evidence`): git-zhi's to do; nothing waits on it. **r3:** A5 "still released". P5 stays released. E8: no declaration. **r4:** A5 "still released". P5 "stands": "One shape, in crochet only." E8: no declaration. **r5:** A5 "still released". P5 stands. E8: no declaration. **r6:** A5 unchanged, stays released. P5 stands. E8 "still released" ("E1 to E17"). **r7:** A5: "All others stay released on the grounds already recorded" (`i26-arch`). P5: no round-7 declaration. E8 "still released" ("E1 to E18") | 7b9287d |
| P5 | i26-pushback | 1 | Proposed change | "either, in order of preference" commits to nothing and has no acceptance conditions | text of the subject | **released** (`i26-pushback`): r2 commits to one shape and has an Acceptance section; its gap is P11. **r3:** stays released, "Acceptance is committed". **r4:** "stands". **r5:** stands. **r6:** stands. **r7:** no round-7 declaration | d2de72f |
| A6 / P6 | i26-arch, i26-pushback | 1 | "dispatch no more workers than ready issues" | correct at dispatch, but a one-root chain runs serially forever unless the cap is re-evaluated as issues close | composes with `wip_limit` | **A6 released** (`i26-arch`): R4 re-evaluates on close; its wording is raised as A11. **P6 held** (`i26-pushback`) in round 2, on P9. **r3:** A6 "still released" (R4). **P6 released** (`i26-pushback`): "The cap counts live workers, never the ready set." R4's arithmetic against `wip_limit` "has a different defect, P17. It is not P6's". **r4:** A6 "still released, with a cross-reference": git-zhi counts `wip_limit` chain-wide (H2); a stood-down worker's issue "keeps its assignment, so it leaves the unassigned pool, and the pool drains. It does strand the issue, which is #27's to fix (items 2 and 4)." P6 "stands" ("P6 / P9"): "each dispatch consumes one". See D9. **r5:** A6 "**reopened in substance, raised as A17**" (`i26-arch`, with A11): "With R1b in place, that deferral is no longer safe". P6 stands ("P6/P9"). **r6:** A6 "**released**" ("A6 / A11 (reopened in round 5)", `i26-arch`): "R1c makes that deferral safe: a miscount now costs a refused start and a named report, not a loop or a stranded issue." P6 stands. **r7:** A6 still released ("A16, A17, A6/A11", `i26-arch`): "R1c now covers the one-worker path … Composed with R1a and R1b, that still gives no loop and no hang." P6: no round-7 declaration | d2de72f |
| P7 | i26-pushback | 1 | Proposed change | an assigned issue can stop being ready before its worker starts it | largely covered by A2's refused-start rule | **released** (`i26-pushback`): R3 and R2 cover both cases; the leftover assignment is P10. **r3:** stays released: R5. **r4:** "**stands for the start**: R2 and R3 stop the worker. **The leftover assignment does not:** that was P10's half" (now P19). **r5:** "**stands, now in full**": "R2 stops the worker, and R1b gives the leftover assignment back. In round 4 only the start half stood.". **r6:** stands: R2 "now explicitly treats `no actionable issues` as 'anything else' (Q7), which closes the one case P7's start half had not named". **r7:** stands | d2de72f |
| E3 | i26-evidence | 1 | What happened, bullet 1 | none: the subject's "still blocked" claim is refuted | `next` never returned a blocked issue; `blocked_by` keeps listing done blockers, the likely misreading | **released** (`i26-evidence`): r2 withdraws the claim. **r3:** no declaration. **r4:** no declaration. **r5:** no declaration. **r6:** "still released" ("E1 to E17"). **r7:** "still released" ("E1 to E18") | 7b9287d |
| A7 | i26-arch | 1 | (absent) | two concurrent runs in one repository can clear each other's assignments | 0002 places concurrent runs out of scope | **released** (`i26-arch`), as record-only. R1's extra assignments grow the exposure; still out of scope. **r3:** "still released, record-only. R6 clears assignments within a run, under this run's own tokens". **r4:** "still released", out of scope as before. **r5:** "still released". **r6:** unchanged, stays released. **r7:** "All others stay released on the grounds already recorded" (`i26-arch`) | d2de72f |

Round 1 also cited E1, E2, E5 and A8 in its axes without giving them rows. In
round 2, `i26-evidence` released E1, E2 and E5, and `i26-arch` released A8. In
round 3, `i26-evidence`'s `walk.sh` re-run "re-proves E1, E2, E5 and E6", and
`i26-arch` declared A8 "still released".

### Round-2 findings

| id | raiser | round | section of the subject | consequence if it ships | evidence | status | revision |
|---|---|---|---|---|---|---|---|
| A9 | i26-arch | 2 | R1, R2, Where it goes | Steps 3.5 to 4 and Loop control assume one self-looping agent. If the worker runs the gate, a second assignment can break per-worker WIP of one. If the orchestrator runs it, its reopen and start strand the issue under the orchestrator's identity. cf. F1, P8, F6 | C4: start without `ZHI_ACTOR` lands under `human:t`; then `next` as r-2 gives `no actionable issues`, and r-2's start is refused. A dispatched subagent has no agent-dispatch tool (weak, harness-specific) | **r3: held, "narrowed to one question"** (`i26-arch`). "The identity half is closed." Open: R1 puts review inside the worker, which may not be able to dispatch Step 4's lenses; "r3 does not say which party dispatches the lenses". cf. P12, F11, C3. **r4: released** (`i26-arch`): "out of scope, tracked as #27 item 1, and I accept the ruling." r4 "no longer puts review inside a worker". **r5:** no declaration. **r6:** unchanged, stays released (`i26-arch`). **r7:** "All others stay released on the grounds already recorded" (`i26-arch`) | r2 |
| A10 | i26-arch | 2 | R3; Acceptance bullet 2 | "A refused … start means the issue is not its issue" makes a re-dispatched worker stand down from its own resumed in-progress issue. The walkthrough would test only refusal | C2: start on own in-progress A1 refused; `next` as r-1 returns A1; 0002 "Only the abandoned identity gets the issue back" | **r3: released** (`i26-arch`): R5 bullet 1 "meets it by name". **r4:** "still released, but see A15": the resume branch is unreachable "within r4", since r4 has no reused token. **r5:** "still released" ("A2 / A10"): "Under fresh-token-per-dispatch, resume-own is still unreachable within #26. A15 keeps the #27 side honest.". **r6:** unchanged, stays released (`i26-arch`). **r7:** "**Reopened in substance by ruling 3; see A19**" (`i26-arch`, "A10/A15") | r2 |
| A11 | i26-arch | 2 | R4 | "never more live workers than ready issues" counts the wrong quantity; an implementer may retire live workers. cf. P9, F6 | C1: in-progress issues leave the ready set | **r3: released** (`i26-arch`): "The cap counts live workers, never the ready set" is "the correct quantity". **r4:** "still released" (with A6, above). **r5:** "**reopened in substance, raised as A17**", with A6 (`i26-arch`). **r6:** "**released**", with A6 (`i26-arch`). **r7:** still released, with A6 (`i26-arch`) | r2 |
| E10 | i26-evidence | 2 | R3 | an immediate post-start check can pass for both workers. R3 should check after a short settle and re-check before close or push. cf. F4 | immediate check: both passed in 3/80 concurrent pairs (r13 1/20, r15 2/60); after 0.5 s: exactly one owner in 110/110 (r14+r15). Non-owner `--state done --force` succeeds | **r3: released** (`i26-evidence`): R5 adds the settle, the retry and the re-check before done. Red re-confirmed (r26 2/80), green confirmed (r25 0/100). Residue raised as E13. **r4:** no declaration by row. Its walkthrough: with R3's settled check, w3 worked while the intruder was final owner in 0/20; with the check off, w3 worked in 20/20. **r5:** no declaration. **r6:** "still released" ("E1 to E17"); the green re-run reproduces "the single settled check". **r7:** "still released" ("E1 to E18") | r2 |
| E11 | i26-evidence | 2 | R1 | R1's query includes assigned and reopened issues; the skill must filter `select(.assigned==null)`, and R1 should name it. A reopened issue would go to any free worker | r18: assigned b2 and reopened b5 returned; `--assigned ""` does not filter; `--assigned none` returns `[]` | **r3: released** (`i26-evidence`): R3 filters to no assignment. **The raiser withdrew E11's reopened half**: "The generalisation was wrong; the measurement was right for its case." r18's b5 had never been assigned (r20). See D2. **r4:** no declaration. r4's R1 cites E11. **r5:** no declaration. **r6:** "still released" ("E1 to E17"). **r7:** "still released" ("E1 to E18") | r2 |
| E12 | i26-evidence | 2 | R3 | a read racing a write can fail. R3 must treat a failed read as "unknown, retry", neither lost nor won | r15: `issue show` failed 2/15 with `ref file is empty`; controls 0/40, 0/40, 0/30. Inferred, not traced, to the same non-atomic write as git-zhi#35 | **r3: released** (`i26-evidence`): R5 retries a failed read. 0 read failures across r22 to r26; "the failure is intermittent". **r4:** no declaration. r4's R3 keeps "A failed read is retried". **r5:** no declaration. **r6:** "still released" ("E1 to E17"). **r7:** "still released" ("E1 to E18") | r2 |
| P8 | i26-pushback | 2 | R1 triggers, with R2, R3, R4 | a stood-down worker's request matches none of R1's triggers. Loop control's "ready set is empty" stop ends the run early, while work is in flight. cf. A9, F6 | R1's trigger list; execute.md L82 | **r3: released** (`i26-pushback`): R6 settles every returning worker; R8 replaces the stop. "P16 is a new interaction between R8 and R3, not P8's residue". **r4: "half stands"** (`i26-pushback`). "Stand-down service is covered by R1's re-dispatch after return. The run-end half was released against r3's R8, which r4 deleted … and it is not in #27. Raised again as **P20**.". **r5:** "**stands**": "Both halves are covered, by R1a's re-run and R1a's end condition. See P22 for a case where that condition is never reached. The rule is right; the loop feeding it isn't.". **r6:** stands. "P8's run end is as in P20 above"; see P20. **r7:** stands | r2 |
| P9 | i26-pushback | 2 | R4 | live workers and ready issues are disjoint sets; once workers start, the cap is violated and the run under-parallelises. cf. A11, F6 | `issue list --ready` is pending or reopened; in-progress `a1` absent | **r3: released** (`i26-pushback`): "Live workers are no longer compared with the ready set". **r4:** "stands" ("P6 / P9"). **r5:** stands ("P6/P9"). **r6:** stands. **r7:** no round-7 declaration | r2 |
| P10 | i26-pushback | 2 | R1, with R2, R3 | an assignment held by this run's stood-down or exited worker is never reclaimed; the issue is stranded until a new run. cf. F10 | reclamation clears only other runs' tokens (execute.md L118–121); probe: `a1` in progress under `x-1`, still assigned to `x-3` | **r3: released** (`i26-pushback`): "The *assignment* half of stranding is closed. The *in-progress* half is P13". **r4: "no longer stands"** (`i26-pushback`): "It was released against r3's R6 bullet 2 … which r4 deleted. It is not in #27. Raised again as **P19**.". **r5:** "**stands**": "It is the same defect as P19, released above.". **r6:** "P19 / P10 … **stands, strengthened**": R1b names the agent and the flag, and adds the token guard. **r7:** "P19/P10 … stand" (`i26-pushback`) | r2 |
| P11 | i26-pushback | 2 | Acceptance, bullet 2 | the walkthrough can pass without exercising the finish trigger, widening, stand-down service or run end. cf. F8 | text of the subject; a refused start does not arise under R1 and must be induced | **r3: released** (`i26-pushback`): "It exercises what I asked." It exercises none of R6's death, reopen or integration paths, noted under P13–P15. **r4:** "stands for selection scope, minus one clause: r4 dropped r3's 'its issue is re-dispatched', so the walkthrough no longer tests P19". **r5:** stands. "Acceptance has grown in the direction P11 asked for.". **r6:** stands. **r7:** no round-7 declaration | r2 |
| F1 | i26-fresh | 2 | R1, R4, Where it goes | dispatched subagents return and end, so "each time a worker finishes" has no mechanism. R4's re-evaluation degrades to once per batch. Step 4's lens dispatch and reopen need an owner. cf. A9 | execute.md l.131-132, l.169, l.298, l.356; dispatching-parallel-agents "When agents return" | **r3: released** (`i26-fresh`): R1 and R4 give "finishes" a mechanism; the leftover is raised as F11. **r4:** "F1 does not apply again." R1 now triggers on dispatch, which the batch model has; R2 gives "one issue per worker, then return" as a consequence. **r5:** "**F1 stays released.**" R1a's trigger "is a worker's **return**, which the batch dispatch model provides", not F1's hand-off to a live worker. With foreground batch dispatch it fires at the batch's end: "That costs throughput, and no requirement depends on it.". **r6:** "still released. R1a still triggers on a worker's return.". **r7:** still released: "R1a, R1b, R1c and R3 compose as in round 6" | r2 |
| F2 | i26-fresh | 2 | R4 | an issue that is chain-ready is not code-ready: downstream dispatch can start from a tree without its upstream's commits, or build on work later reopened | execute.md l.154-156, l.256-257, l.367-369; `ReadySet` treats done upstream as satisfied | **r3: released** (`i26-fresh`): R3's integration gate and R6's integrate-on-reviewed "close both halves". cf. A14, E15, P16, C2. **r4:** no declaration. `i26-fresh` lists F2 among the ids it found in #27. **r5:** no declaration. **r6:** no declaration. **r7:** no declaration | r2 |
| F3 | i26-fresh | 2 | R2, R3 | a stand-down leaves the issue in progress under the wrong actor, absent from the ready set; the milestone cannot complete. cf. A9, P10 | scratch: start without `ZHI_ACTOR` → `human:T`, absent from `issue list --ready`, second start refused; 0002 "Breaking it costs a stranded issue" | **r3: held** (`i26-fresh`): start-up reclamation clears only assignments and no verb returns an in-progress issue to the pool (`reopen` refused; pause then resume leaves it absent from the ready set). "The subject must allow a handover outside the pool and an orchestrator transition on a dead worker's issue." cf. A12, E14, P13, C1; see D8. **r4: released** (`i26-fresh`): "out of scope, in #27". "Under r4, a stood-down worker's issue stays assigned to its token … the issue is stranded for the run. That is the defect F3 names, it predates #26 … I still hold it live in #27." See D8, D9. **r5:** no declaration. A party to D9 by its round-4 placement. **r6:** "still in #27. Nothing in r6 reaches back into them. R1b's 'a lost start is not re-dispatched, #27's' is consistent with F3." F21 names "F3's shape on the single path". **r7:** "still in #27" **r8:** "F3, F11 to F14 and F16 remain live in #27, and I hold them there." | r2 |
| F4 | i26-fresh | 2 | R3, Out of scope | R3 does not mitigate git-zhi#35; a single read right after the write cannot detect a lost update. Within a run, R1+R2 already prevent the case. See D1 | `WriteEntity`: parent from the current ref, then ref update, no CAS; interleaving read(A), read(B), write(A), check(A), write(B), check(B) | **r3: released** (`i26-fresh`): R5 claims only to narrow the window, "and that claim has been withdrawn" (the false assurance). "**D1 is resolved for me.**". **r4:** no declaration; "D1, which was resolved for me at r3". **r5:** no declaration. **r6:** "still released. R3 is unchanged.". **r7:** still released | r2 |
| F5 | i26-fresh | 2 | R2, R3; Step 2 identity paragraph | `export ZHI_ACTOR` does not survive between Bash calls, so calls resolve to the git author; R2 and R3 trip on every issue and each trip strands one | scratch: exported in one call, empty in the next; the Bash tool's own statement; execute.md l.103-105 | **r3: released** (`i26-fresh`): R7. The piped `echo ... \| git zhi issue edit --body -` in Step 4 is included, as implementation detail. **r4:** no row declaration. On ruling 2: "I have no objection. R4 matches what I asked for in F5.". **r5:** no declaration. **r6:** no declaration. **r7:** no declaration | r2 |
| F6 | i26-fresh | 2 | R1, R4, against Loop control | the ready set is empty whenever every ready issue is held, so Loop control ends the run with workers running; R4's cap shrinks below the live count. cf. P8, P9, A11 | execute.md l.80-89; `ReadySet` filter; in-progress A absent from `issue list --ready` | **r3: released** (`i26-fresh`): R8 and R4. **r4:** no declaration. P20 cites F6. **r5:** no declaration. **r6:** no declaration. **r7:** no declaration | r2 |
| F7 | i26-fresh | 2 | R5; "Every requirement stays inside decision 0002" | if Key Constraints keeps "Each worker selects with bare `git zhi next`", it stays false and hides the shift that the orchestrator now selects. Not an amendment to 0002. See D3 | 0002 "The execute loop", "Assignment is a hint"; execute.md l.439 | **r3: released** (`i26-fresh`): R2 says the orchestrator chooses; R9 must make Key Constraints say so. **r4:** no declaration. r4's R2 and R5 cite F7. **r5:** no declaration. **r6:** no declaration. **r7:** no declaration | r2 |
| F8 | i26-fresh | 2 | Acceptance | the conditions can pass while the problem persists: (a) the other milestone must lead the critical chain; (b) cover finish-and-reassign; (c) a sequential walkthrough cannot exercise the race; (d) test the reachable start-under-wrong-actor case, not refusal; (e) the one-worker branch is uncovered; (f) a CLI walkthrough does not show an agent following the skill. cf. P11 | `headForActor` falls back to `CriticalChain()`; scratch: unassigned worker got X1 | **r3: released** (`i26-fresh`): (a), (b), (d), (e) are now conditions; (c) sits with git-zhi#35; (f) noted, "I note this but do not block on it". **r4:** no declaration by its raiser. `i26-cold` (C13) and `i26-pushback` (P21) note that r4 deletes the condition that answered F8(e). **r5:** no declaration. r5's Acceptance restores the one-worker branch (F8(e)). **r6:** F8(f) "now answered by the explicit sentence handing the wording judgment to `crochet:review` (Q4). Fully released." (`i26-fresh`). **r7:** still released | r2 |
| F9 | i26-fresh | 2 | R1 | `git zhi list --ready --format json` carries no `assigned`; the subject names the right listing, but the how-to table names the other | scratch: `list --ready` → `{"ready_set":[{id,title}]}`; `issue list --ready` includes `assigned` | **r3: released** (`i26-fresh`): deferred to the implementing issue. **r4:** no declaration. r4 leaves F9 to the implementing issue. **r5:** no declaration. r5 still leaves F9 to the implementing issue. **r6:** no declaration. r6 still leaves F9 to the implementing issue. **r7:** no declaration. r7 still leaves F9 to the implementing issue | r2 |
| F10 | i26-fresh | 2 | R1, R2 | an issue reopened at Step 4 stays assigned to worker *n*; a newly dispatched *m* cannot be assigned it, and R2 makes *m* refuse it. See D2; cf. P10 | execute.md l.122-125, l.335-341; `headForActor` step 3 | **r3: released** (`i26-fresh`): D2 measured; under R1 the reopen stays with the assigned worker, and R6 clears on unsuccessful return. **r4:** no declaration. **r5:** no declaration. **r6:** no declaration. **r7:** no declaration | r2 |

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
| A12 | i26-arch | 3 | R6 bullet 2; R1 | a worker that dies mid-issue leaves it in progress under its token. Clearing the assignment does nothing for it, and start-up reclamation also clears assignments only, so the mechanism R6 cites does not exist. The milestone cannot complete, and R8 reports the issue "held outside this run", although this run holds it. Repair named in 0002: re-dispatch under the dead token, which needs R1 to say "a worker re-dispatched for the same issue reuses that issue's token". cf. E14, P13, F3, C1; see D8 | G1: after `--unassign`, `{"state":"in-progress","assigned":null,"last":"agent:run-1"}`, pool `[]`, `no actionable issues for actor agent:run-2`. G2: `next` under the dead token returns the issue. G3: pause and resume by another actor transfers ownership, "undocumented in 0002", "I would not choose it" | **r3:** open. **r4: released** (`i26-arch`): "out of scope, tracked as #27 item 2, and I accept the ruling." "One thing carries over; see A15". **r5:** no declaration. **r6:** unchanged, stays released (`i26-arch`). **r7:** "All others stay released on the grounds already recorded" (`i26-arch`) | r3 |
| A13 | i26-arch | 3 | R7 | R7 contradicts the letter of 0002 ("exports the identity once at dispatch"; "Identity is declared once, for the process, not per command") though not what it decided, so a reader of 0002 finds the skill doing what it rules out "with no record of why". Per-command declaration re-creates "re-exporting is the only way to break it" on every command. The subject or implementing commit should state the premise failure. "No amendment, in my view"; whether the sentence must live in an amending decision "is a fair question for the human". cf. P18, C9; see D6 | 0002 text; F5; the Bash tool's statement that shell state does not persist | **r3:** open. **r4: released** (`i26-arch`): "I accept ruling 2." "The ruling fits the decision's text, not only its intent." Released "on that understanding" that the orchestrator hands the worker the token as a literal. "I note my bias: the ruling resolves my own finding in a direction I had already said I held to be correct." See D6. **r5:** "still released". "R5 now also corrects `how-to-use-git-zhi`'s `export ZHI_ACTOR` example, which the ruling required for consistency.". **r6:** unchanged, stays released (`i26-arch`). **r7:** "All others stay released on the grounds already recorded" (`i26-arch`) | r3 |
| A14 | i26-arch | 3 | R3, last sentence; R6 bullet 1 | if "integrated" is known only from the orchestrator's memory, a run that dies between a worker's return and integration leaves a blocker done but unmerged, and the next invocation dispatches downstream onto a tree without it: F2 arriving through resume. Requirement: "integrated" is "a fact read from git at dispatch time, e.g. the worker's branch is reachable from the integration target, never a flag the orchestrator remembers". cf. E15; see D5 | Key Constraints "resumes from the current chain state" | **r3:** open. **r4: released** (`i26-arch`): out of scope, tracked in #27, "and I accept the ruling. The disagreement with E15 over which source is safer stays with #27." See D5. **r5:** no declaration. **r6:** unchanged, stays released (`i26-arch`). **r7:** "All others stay released on the grounds already recorded" (`i26-arch`) | r3 |
| E13 | i26-evidence | 3 | R5, "re-checks ownership before `done` and before pushing" | R5's ownership predicate (in progress, latest actor is the worker) is false after `done`, so under R1 a push after `done` reads as "lost". Fix: the pre-push check is "the latest transition's actor is me", independent of state; or push before `done` | r27: start true; done false; reopen false; restart true; another actor reopens, false | **r3:** open. **r4: released** (`i26-evidence`): R3 checks once, right after start, "where the predicate is correct"; "the walkthrough's 20 races show the single check is enough". **r5:** "released in round 4; unchanged". **r6:** "still released" ("E1 to E17"). **r7:** "still released" ("E1 to E18") | r3 |
| E14 | i26-evidence | 3 | R6, "reclaimed the way start-up reclamation already reclaims stale tokens" | after start-up reclamation a dead token's issue stays in progress, outside the pool, refusing start and resume. Only pause then resume by a fresh token takes it back; cancel discards it. R6 must name the takeover, and the fresh worker's dispatch must expect `next` not to return the issue, "Otherwise R2 makes it stand down, and R8 ends the run with the issue held". cf. A12, P13, F3, C1; see D8 | r28: found via `issue list --state in-progress --milestone m` and `.transitions[-1].actor`. As new-1: `next` returns y; start refused; resume `cannot resume: a measurement session is already open`; pause then resume succeed, actors `[dead-1, new-1, new-1]` | **r3:** open. **r4: released** (`i26-evidence`): "out of scope, in perigrin/crochet#27". "in the 8/20 lost races, m3 is left in progress under `agent:intruder`, outside the pool. Selection is correct, but the milestone cannot complete. #27 must carry that". **r5:** "released in round 4; unchanged". r5 records carrying E14's in-progress half into #27 by id. "This round's steal runs reproduce E14's stranded issue again (m2 under `agent:intruder`)". **r6:** "still released" ("E1 to E17"). **r7:** "still released" ("E1 to E18") | r3 |
| E15 | i26-evidence | 3 | R3, "only when every blocker's branch has been integrated" | integration is not observable through the CLI. It is observable through git, using the CLI's `sessions[-1].end_sha` with `merge-base --is-ancestor`, which gives a false "no" for squash and rebase merges. "The subject should not imply a CLI query exists. The orchestrator's own record of what it integrated is the robust source." cf. A14; see D5 | r29: `no` before merge, `yes` after; r30: `no` after `merge --squash` | **r3:** open. **r4: released** (`i26-evidence`): "out of scope, in #27". See D5. **r5:** "released in round 4; unchanged". **r6:** "still released" ("E1 to E17"). **r7:** "still released" ("E1 to E18") | r3 |
| E16 | i26-evidence | 3 | R8, "reported by name" | the default `issue list --milestone` omits reopened issues, so a run-end report built on it could report a milestone as finished. Use `git zhi list --milestone`, or `issue list --all` filtered. `issue list --state` help lists `reopened` but the flag rejects it, a git-zhi help defect for #35 or a separate filing | r33: `list --milestone` `["reopened"]`; `issue list --milestone` `[]`; `--all` `["reopened"]`; `--state reopened` rejected | **r3:** open; "an implementation detail for R8's report". **r4: released** (`i26-evidence`): R8's report is gone; R1's query includes reopened issues. "The run-end reporting half belongs with #27's stuck outcome; I ask that it be carried there by id". **r5:** "released in round 4; unchanged". r5 records carrying E16's reporting half into #27 by id. **r6:** "still released" ("E1 to E17"). **r7:** "still released" ("E1 to E18") | r3 |
| P12 | i26-pushback | 3 | R1, "carries that issue through … close, review, and every reopen cycle"; Step 4 | a worker that cannot dispatch either applies the lenses itself, breaking 0003's composition rule, or skips the gate. If instead the orchestrator dispatches review, a reopen falls to the orchestrator, which R1 forbids. The subject has to pick: (1) review in the orchestrator, reopen re-dispatched under the same token; (2) the worker dispatches where it can; (3) inline lenses declared acceptable, "which needs a ruling against 0003's composition rule". "Which one is the human's ruling, not implementation." cf. A9, F11, C3 | probe 3: this participant, a dispatched subagent, has no agent-dispatch tool; execute.md L298 | **r3:** open; "high, conditional": a harness where subagents can dispatch drops it to a note. **r4: released** (`i26-pushback`): "out of scope, in #27 item 1". **r5:** "stand[s] released". **r6:** stands. **r7:** stands ("P12–P18 stand") | r3 |
| P13 | i26-pushback | 3 | R6; R1; R2 | every worker that dies mid-execution ("Context exhaustion is the common case") leaves its issue permanently in progress under a dead token; R8 reports it as "held outside this run", which is wrong. The mechanisms that do move ownership are forbidden by R1 (orchestrator) or by R2 (a fresh worker has already stood down). "The 0002-native fix" is re-dispatch under the dead token, reading R1's token as one per issue. No walkthrough condition kills a worker. cf. A12, E14, F3, C1; see D8 | probe 1: `--assign ""` leaves it in progress; start and reopen refused; `next` for others skips it; pause and resume by another actor make it the owner. execute.md L118–121; 0002 "Only the abandoned identity gets the issue back from `next`" | **r3:** open; "high", "Unconditional". **r4: released** (`i26-pushback`): "out of scope, in #27 item 2". **r5:** "stand[s] released". **r6:** stands. **r7:** stands | r3 |
| P14 | i26-pushback | 3 | R6 bullet 1; R3; R8 | a worker that dies between close and review returns an issue done but unreviewed. R6 clears its assignment; it never re-enters the pool, review never runs, and it is never integrated, so its dependents never dispatch. The milestone "looks nearer completion than it is", and a mandatory gate is skipped without a record. R6 needs a third case. cf. C2, F14 | execute.md L256–258: `--state done` runs before Step 4 | **r3:** open; "medium–high". **r4: released** (`i26-pushback`): "out of scope, in #27". **r5:** "stand[s] released". **r6:** stands. **r7:** stands | r3 |
| P15 | i26-pushback | 3 | R6 bullet 1; R3 | a merge conflict on integration has no instruction. The orchestrator either resolves it itself, putting unreviewed code it wrote on the integration branch under no worker's identity, or leaves it unintegrated, stranding the issue as in P14. Needs a requirement that a failed integration goes back through a worker and the orchestrator never writes the resolution | execute.md L146–165; reasoned from the text, no conflict reproduced | **r3:** open; "medium", "Unconditional, given R6". **r4: released** (`i26-pushback`): "out of scope, in #27". **r5:** "stand[s] released". **r6:** stands. **r7:** stands | r3 |
| P16 | i26-pushback | 3 | R3; R4; R8 | the pool is chain readiness, which counts a done blocker as satisfied, so an issue behind a done but unintegrated blocker is in the pool but not dispatchable. R4 says dispatch, R3 says don't, and R8's "pool is empty" never becomes true: the run "spins or hangs". Fix: the pool is the dispatchable set. cf. C2 | the text of R3, R4 and R8 | **r3:** open; "medium", "Unconditional". **r4: released** (`i26-pushback`): "dissolved in r4, and filed in #27 item 3". **r5:** "stand[s] released". **r6:** stands. **r7:** stands | r3 |
| P17 | i26-pushback | 3 | R4, "live workers are below `wip_limit`" | git-zhi enforces `wip_limit` chain-wide, so in-progress issues outside the run (a human's, another milestone's, this run's dead tokens) use it up. R4 dispatches, start is refused, R5 stands down, R6 clears, R4 re-dispatches: "a tight loop of fresh workers". The right quantity is `wip_limit` minus in-progress issues not held by this run's live workers. "R4's count is the third wrong quantity in three revisions." cf. C4 | probe 2: `WIP limit reached: 2 issue(s) already in progress (limit 2) … or pass --force` | **r3:** open; "medium–high, conditional": inert at the default `wip_limit` 0; drops to low if the human rules crochet runs only without a limit. **r4: released** (`i26-pushback`): "out of scope, in #27 item 4". "the livelock is still reachable when this ships. But it exists in execute today … r4 does not make it worse". **r5:** "P17 stands as released (chain-wide counting is #27's, F18), but see P22". **r6:** stands. **r7:** stands | r3 |
| P18 | i26-pushback | 3 | R7; preamble, "All of this stays inside decision 0002" | the preamble's claim is false, and an implementer who trusts 0002 over the subject keeps the export, so F5 recurs. "Resolution is the human's, not implementation": (1) a defect repair in 0002, since its premise that an export persists is false; or (2) amend 0002. "Either way, the preamble must stop saying nothing in 0002 moves." cf. A13, C9; see D6 | 0002 "The execute loop" and "Mint `ZHI_ACTOR` **at dispatch**"; execute.md L104 | **r3:** open; "medium". **r4: released** (`i26-pushback`): "answered by ruling 2". See D6. **r5:** "stand[s] released". "Ruling 2 is unchanged.". **r6:** stands. **r7:** stands | r3 |
| F11 | i26-fresh | 3 | R1 | a worker cannot run Step 4 as written: it reviews its own commits or skips the gate, every time, so the per-issue review is "structurally unmet in the parallel branch, and only there". The subject should decide who runs Step 4; one option is the orchestrator dispatching reviewers on return, with a reopen re-dispatching the same token, which relaxes R1's "never runs a transition" for reopen. cf. A9, P12, C3 | execute.md l.298-302, l.320-323; this subagent's tool list | **r3:** open. **r4: released** (`i26-fresh`): "out of scope, in #27". **r5:** no declaration. **r6:** "still in #27. Nothing in r6 reaches back into them.". **r7:** "still in #27" | r3 |
| F12 | i26-fresh | 3 | R1 (Step 4, "Record the tier and the outcome") | the only milestone write replaces the whole body, and a worker's read-compose-write spans minutes, so concurrent workers silently drop each other's checklist entries, the only record distinguishing "reviewed" from "review never ran". Writes to shared milestone state should be the orchestrator's, serially on return. cf. C5 | `milestone edit --help`; execute.md l.354-369 | **r3:** open. **r4: released** (`i26-fresh`): "out of scope, in #27". **r5:** no declaration. **r6:** "still in #27". **r7:** "still in #27" | r3 |
| F13 | i26-fresh | 3 | "With one worker … a cap of one" | two readings. If a subagent is still dispatched, it is `wip_limit` 1 with F11's problem. If not, one agent is orchestrator and worker, and R1, R6 and R5 lose their referents. "The acceptance condition 'the one-worker branch is run too' cannot be checked until this is decided." | execute.md l.130, l.167 | **r3:** open. **r4: released** (`i26-fresh`): "out of scope, in #27, as far as lifecycle goes". "**The selection half is not**, and r4 drops it. See F17". **r5:** no declaration. **r6:** "still in #27". **r7:** "still in #27" | r3 |
| F14 | i26-fresh | 3 | R6 with R4 and R8 | Step 3's 10-pass valve counts in the worker's head, so a fresh worker re-dispatched for a stalled issue starts again from pass 1 and R8's end may never arrive. ARCHITECTURE.md says an issue is "reported as stuck"; R6 has no stuck outcome. Suggests a third outcome, stuck, which reports the issue and removes it from the pool. cf. C2, P14 | execute.md l.228-236, l.345-346; ARCHITECTURE.md "Execute nests two loops" | **r3:** open. **r4: released** (`i26-fresh`): "out of scope, in #27". **r5:** no declaration. **r6:** "still in #27". **r7:** "still in #27" | r3 |
| F15 | i26-fresh | 3 | R2; R5 bullet 1 | a fresh token per issue never has its own in-progress issue on its first `next`, so the bullet "is either dead text or the sign of a missing re-dispatch-same-token path, which F3 and F11 would both want". cf. C7; see D4 | R2 and R5 text | **r3:** open; "minor". **r4: released** (`i26-fresh`): "on merits". "The resume branch is gone from R3." See D4. **r5:** no declaration. **r6:** no declaration. **r7:** no declaration. A19, P26, F22, C20, K16 and W10 name r7's "unreachable" sentence, which cites F15; see D15 | r3 |
| F16 | i26-fresh | 3 | (Step 6) | Step 6's per-issue report exists only in worker return messages, so the orchestrator has to collect it on return | — | **r3:** open; "minor, implementation". **r4: released** (`i26-fresh`): "out of scope, in #27". **r5:** no declaration. **r6:** "still in #27". **r7:** "still in #27" | r3 |
| C1 | i26-cold | 3 | R6; R1 | an in-progress issue has no transition back to the pool. The exits are `cancel` (terminal) and `done --force` then `reopen` ("which falsifies the record"), both orchestrator transitions that R1 forbids. The issue stays stranded, R8 reports it held and ends, Step 5 never runs, and under a positive `wip_limit` it holds a slot for good. Fix shape: same-token re-dispatch, or an explicit exception to R1. cf. A12, E14, P13, F3; see D8 | `issue/state.go` transitions table; `cannot reopen: issue is in-progress, expected done`; `cannot mark done: session has 0 commits`; 0002 "one issue the scheduler will not surface to anyone but its original worker" | **r3:** open. **r4: released** (`i26-cold`): "out of scope, in #27". **r5:** no declaration. **r6:** no declaration. **r7:** no declaration | r3 |
| C2 | i26-cold | 3 | R6; R8; R3 | R6 and R8 have no stuck outcome. Reopens ≥ 3, the 10-iteration valve, an AC that cannot pass and a permission denial fall into "otherwise": re-dispatched without limit, or, for reopens ≥ 3, done, unreviewed and unintegrated, leaving dependents in the pool but undispatchable, so R8 never fires. Fix shape: a third R6 outcome, and R8 ends on "no dispatchable issue". cf. F14, P14, P16 | execute.md Step 3 valve, Step 4 "reopens >= 3", Loop-control stop list; ARCHITECTURE.md "reported as stuck" | **r3:** open. **r4: released** (`i26-cold`): "out of scope, in #27". **r5:** no declaration. **r6:** no declaration. **r7:** no declaration | r3 |
| C3 | i26-cold | 3 | R1; Step 4 | in Claude Code a dispatched subagent does not get the agent-dispatch tool, so every review is run by the agent that wrote the commits, "the failure the gate exists to catch". Fix shape: the orchestrator dispatches the reviewer on return. "This reopens R1's 'end to end', so it has to be decided, not patched." cf. A9, P12, F11 | execute.md Step 4; 0003 as cited there; its own tool set has no Agent/Task tool | **r3:** open; "C3 depends on the platform. If a harness does let subagents dispatch, C3 weakens to a cost question". **r4: released** (`i26-cold`): "out of scope, in #27. The problem predates #26". **r5:** no declaration. **r6:** no declaration. **r7:** no declaration | r3 |
| C4 | i26-cold | 3 | R4 | any in-progress issue outside the run takes a `wip_limit` slot, giving refusal, stand-down, clear and immediate re-dispatch: "a dispatch livelock". The walkthrough never sets `wip_limit` above zero. Fix shape: cap at `wip_limit −` in-progress issues not held by this run, or treat a WIP refusal as "stop dispatching". cf. P17 | `checkWIPLimit` counts `StateInProgress` across `LoadAllIssues`; `WIP limit reached: 1 issue(s) already in progress (limit 1)` | **r3:** open. **r4: released** (`i26-cold`): "out of scope, in #27. Its reach back into selection is raised as C12". **r5:** no declaration. C15, K12 and Q2 cite C4's livelock. **r6:** no declaration. R1c answers the loop C15 traced to C4's refusal. **r7:** no declaration | r3 |
| C5 | i26-cold | 3 | R1; Step 4 | parallel workers write the milestone body, and `--body` replaces it, over a window that "spans the agent's turn". A dropped entry makes a reviewed issue read as never reviewed, and under R6 its branch is not integrated, feeding C2. Fix shape: the orchestrator writes entries from returned reports, serialised. cf. F12 | `milestone edit` help "replace the body"; execute.md Step 4; git-zhi#35 Cause | **r3:** open. **r4: released** (`i26-cold`): "out of scope, in #27". **r5:** no declaration. **r6:** no declaration. **r7:** no declaration | r3 |
| C6 | i26-cold | 3 | R5 | "R5 is over-specified against a race R2 has already removed": #35 needs two concurrent starts of one issue, and under R2 and R6 "no second starter exists". "This narrows the window of git-zhi#35" will mislead. Keep one part: a single read-back after start, by literal id, because an empty `$ID` makes `issue edit "" --state start` start the HEAD issue in another milestone, exit 0, which R1 to R9 do not otherwise prevent; the skill should say "pass the id literally; never through a variable". See D1, D7 | git-zhi#35 body; empty-ref probe: `Started …: other-ms` while the run's issue sat pending in m1 | **r3:** open. **r4: "released** on its core; **standing aside** on the settle" (`i26-cold`). Grounds: "My view stands: within a run, R1 leaves no second starter for an issue … But the step is cheap, and D7 is still open between participants. I will not block on it." See D7. **r5: "released**, standing aside ends" (`i26-cold`): "The K10 paragraph now says what I argued". A wording residue: R3's "This narrows git-zhi#35's window" sits ten lines above "R1 and R2 already rule out a shared pick"; "That is cosmetic, and I do not hold it". See D7. **r6:** "still released. The 'narrows #35's window' wording residue is unchanged and still cosmetic.". **r7:** under "Earlier releases, re-attacked": "C12–C16, C9 and C6 still hold" (`i26-cold`) | r3 |
| C7 | i26-cold | 3 | R2; R5 | R1's fresh token per issue makes the resume-own branch unreachable unless the orchestrator re-dispatches with an old token, "which r3 never does (but C1's fix might)". `next` "only cross-checks an assignment the orchestrator just wrote"; keeping it to keep 0002's sentence true "is the wrong trade. Amend 0002 instead". "If it is kept, say what it is for." cf. F15; see D3, D4 | `headForActor` steps 1 and 3; R1 and R2 text | **r3:** open. **r4: released** (`i26-cold`): "`next` is kept, and its purpose is stated … That is what C7 asked for. One residue is raised as C14". **r5:** no declaration. **r6:** no declaration. **r7:** no declaration. A19, P26, F22, C20, K16 and W10 name r7's "unreachable" sentence, which cites C7; see D15 | r3 |
| C8 | i26-cold | 3 | R1, "its own run token as identity" | in execute.md the run token is `<run-id>` and workers are `agent:<run-id>-<n>`. Read literally, a new run-id per worker means a later invocation's start-up rule cannot tell this run's workers from a dead run's. Fix: "its own worker identity, `agent:<run-id>-<n>`" | execute.md "Worker identity — once per run"; 0002 "worker ids carry the run's own opaque token" | **r3:** open. **r4: released** (`i26-cold`): "R1 says 'the worker's token'". **r5:** no declaration. **r6:** no declaration. **r7:** no declaration | r3 |
| C9 | i26-cold | 3 | R7; Where it goes | `how-to-use-git-zhi.md` ("A process declares itself by exporting") stays false, and it is the file agents consult before every `git zhi` call. 0002's "once at dispatch / not per command" is contradicted by a skill revision, "which is prose overriding an accepted decision". "The fact behind R7 is right." cf. A13, P18; see D6 | how-to-use lines on `ZHI_ACTOR`; 0002 "The execute loop"; ARCHITECTURE.md on immutability | **r3:** open. **r4: "standing aside** on the 0002 half; **held** on the live-document half" (`i26-cold`). Grounds for the standing-aside: "The ruling answers the 0002 half, and its reading is defensible: 0002's reason, no differing identity on the read side, survives a per-command prefix." Held: `how-to-use-git-zhi.md` "still says 'A process declares itself by exporting'", and "'Where it goes' still names only execute.md. Doc-first puts that file in the same pull request. Fix: one line in 'Where it goes'". cf. K6; see D6. **r5:** held half "**released**" (`i26-cold`): "R5 and 'Where it goes' now name `how-to-use-git-zhi`'s `export ZHI_ACTOR` example". 0002 half: "**still standing aside**": "Ruling 2 stands, and its reading is defensible". See D6. **r6:** 0002 half "**released** (until now I stood aside)" (`i26-cold`): "The ruling stands, and R4 puts its reason beside the rule." "I no longer have grounds to keep the question open." Standing aside ends. See D6. **r7:** "C12–C16, C9 and C6 still hold" (`i26-cold`) | r3 |
| C10 | i26-cold | 3 | Acceptance | the walkthrough passes with C1, C2, C4 and C5 present. "The run ends with every milestone issue done" cannot hold once R8's blocked or held reporting is exercised. Pinning "on git-zhi 0.7.2" decays; say "on the declared `git_zhi_min_version`". cf. P13, P14 (acceptance gaps) | the Acceptance section; coding-conventions "no criterion should be pinned…" | **r3:** open. **r4: released** (`i26-cold`): the version is the declared floor, and the lifecycle conditions are out of scope. "But the walkthrough misses C12 and C13". **r5:** no declaration. **r6:** no declaration. **r7:** no declaration | r3 |
| C11 | i26-cold | 3 | Where it goes (parts of execute.md it does not reach) | `--step` has no stated meaning under parallel refill; Loop control's "keep going in the same turn" against an orchestrator waiting on workers; Step 5's "When all issues are closed" against R8 ending with issues held or blocked. "Each leaves the implementer to decide something the subject claims to have specified." | execute.md `--step`, Loop control, Step 5 | **r3:** open; "small". **r4: released** (`i26-cold`): "out of scope, in #27". **r5:** no declaration. **r6:** no declaration. **r7:** no declaration | r3 |

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

### Round-4 findings

Each row is as its raiser wrote it; none is merged with another. Overlaps are
marked "cf.".

| id | raiser | round | section of the subject | consequence if it ships | evidence | status | revision |
|---|---|---|---|---|---|---|---|
| A15 | i26-arch | 4 | R3, "r3's resume branch … is gone: … unreachable with one token per issue"; #27 item 2 | under #27's re-dispatch-under-the-dead-token fix, `next` returns the worker's own in-progress issue, `--state start` is refused, and R3's stand-down "strands that very issue. That is A10 again." "Nothing in #26 breaks, but whoever implements #27 item 2 that way has to restore the resume branch." Ask: add a line to #27 item 2 citing A10 and A15. cf. A10, C14, K2; see D4 | D4 / round-2 C2 (start on own in-progress issue refused) | **r4:** open; "I do not hold #26 on it". **r5: released** (`i26-arch`): carried to #27 as a comment, with the requirement "Whichever recovery this issue chooses has to let a re-dispatched worker resume without a fresh `start`." "This is my own finding and it is met as stated.". **r6:** unchanged, stays released (`i26-arch`). **r7:** "**Reopened in substance by ruling 3; see A19**" (`i26-arch`, "A10/A15") | r4 |
| E17 | i26-evidence | 4 | Acceptance, "no issue is started by two workers", with "one start is refused or lost" | the pass condition contradicts the forced lost start the walkthrough requires, and the chain cannot observe it, so an implementer checking the chain "gets a false green". Reword to "no issue carries work from two workers", r3's wording, observed from worker records or commits. cf. K8 | 20/20 forced races: both starts succeeded. Red w4x2: w4 and w5 both worked m1, chain records only `agent:w5`; w4x1: both worked o3, chain records only `agent:w4` | **r4:** open; "accept, with one wording change (E17)". **r5: released** (`i26-evidence`): r5's wording "is the wording I asked for. `walk5.sh` judges it that way". **r6:** "still released": "E17's record-based judgment is now explicit ('records name the token'), and `walk6.sh` uses it". **r7:** "still released" ("E1 to E18") | r4 |
| P19 | i26-pushback | 4 | R1, "filtered to issues with no assignment"; R2, "starts nothing and returns"; R3, "stands down and returns" | a stood-down worker's issue keeps its assignment to a token that is never dispatched again; R1's filter excludes it, start-up reclamation clears only other runs' tokens, so it is "unreachable for the rest of the run", and "nothing reports it". This is P10 again; its r3 answer was deleted. Fix: "When a worker returns without owning its issue, the orchestrator clears that issue's assignment before the next dispatch", and restore the acceptance clause "its issue is re-dispatched". cf. P10, P7, C12, K3, F3; see D9 | round-2 and round-3 probes and D2; execute.md L118–121. Not re-measured on 0.7.2 this round | **r4:** open; "medium". Would drop to low if R2's case is unreachable within a run and R3's lost start only happens against an outside actor. **r5: released** (`i26-pushback`): R1b, and the walkthrough now requires "its issue re-dispatched (R1b)". Who clears "is implementation detail either way, because clearing is not a transition". cf. A16, Q5; see D9. **r6:** "**stands, strengthened**": R1b "names the agent (the orchestrator) and the flag (`--unassign`, which exists), and adds 'only if it still carries that worker's token'". **r7:** stands ("P19/P10") | r4 |
| P20 | i26-pushback | 4 | "Where it goes" (no longer lists Loop control); r3's R8, deleted | the stopping rule falls back to Loop control's "the ready set is empty" (execute.md L82), empty under R1 whenever every ready issue is assigned and started; an orchestrator checking while workers are in flight "ends the run and 'reports once' with work still running". Not in #27. Fix: state the dispatch model, restore R8's sentence, or move P8 and F6 into #27 explicitly. cf. P8, F6, K4 | execute.md L82; r3-r4 diff | **r4:** open; "low–medium, conditional": "drops to a note" if the orchestrator decides only after every dispatched worker has returned. **r5: released** (`i26-pushback`): R1a's end condition "holds under either dispatch model, so the condition I put on it in round 4 no longer matters". **r6:** "**stands, with a nit**": the diff removes r5's "Loop control's wording changes to match" from R1a, so execute.md L82 "is no longer explicitly marked for change". "I do not hold P20. But restore the phrase". cf. K15, W5. **r7:** "**released**" (`i26-pushback`, "P20 nit"): R1a's restored sentence "restores what I asked, and more". Residue, "a nit, not a bar": "the replaced 'blocked' stop used to report. Under R1a, issues still blocked at run end go unnamed" | r4 |
| P21 | i26-pushback | 4 | Out of scope, "the one-worker and `--step` paths. These are perigrin/crochet#27"; R1, "before each dispatch" | the `Otherwise` branch has no dispatch, so R1 never fires; the single worker's bare `next` follows the critical chain into another milestone, "exactly E1 and E2". Acceptance dispatches two workers, so it passes with the drift intact. #27 holds that branch only as "underspecified under parallel dispatch". Fix: restore r3's one-worker sentence; add the one-worker run to the walkthrough. cf. F17, C13, K1, F8(e) | execute.md L167–173; r3 text | **r4:** open; "medium". **r5: released** (`i26-pushback`): R1's `Otherwise` clause, and the one-worker branch is in the walkthrough. "Residue: P23". **r6:** stands: the assignment at the per-pick step "is better than r5". **r7:** stands | r4 |
| F17 | i26-fresh | 4 | R1 ("assigns before each dispatch"); Out of scope; Acceptance | the `Otherwise` branch (execute.md l.167) has no dispatch, so R1 never fires and bare `next` returns the critical-chain leader from any milestone. "#26 can be closed with it still broken." r4 deletes r3's "the one-worker branch is run too". Fix: R1's trigger as "before each pick, by whichever agent orchestrates", and a one-worker acceptance run. cf. P21, C13, K1, F13 | round-2 observation: an unassigned worker got X1 from m2; r3-r4 diff l.190 | **r4:** open; "The single change I ask for". **r5: released** (`i26-fresh`): R1's second bullet, Out of scope and Acceptance. "an agent's own assignment beats the critical-chain leader from another milestone, so the clause fixes the drift". **r6:** "still released, and better than before. The assignment is now placed at the per-pick step, as I asked.". **r7:** still released | r4 |
| F18 | i26-fresh | 4 | R1, "within `wip_limit`" | the clause carries over the chain-wide-count defect #27 records; "harmless here because R1 only bounds the count from above". Named "so that the implementing issue does not treat R1 as having specified `wip_limit` semantics". cf. P17, C4 | #27 item 4 | **r4:** "minor"; "I am not raising it against #26". **r5: released** (`i26-fresh`): "It is named in R1 as #27's to settle.". **r6:** no declaration. r6 keeps it named in R1 as #27's to settle. **r7:** no declaration. r7 keeps it named in R1 as #27's to settle | r4 |
| C12 | i26-cold | 4 | R1 (the "no assignment" filter) with R3 ("stands down and returns") | nothing clears the assignment when the worker stands down, so R1's filter excludes the issue from every later dispatch; "This defect is introduced by the fix, not inherited from the lifecycle." Reachable inside r4's scope via a `WIP limit reached` refusal or an outside start, and Acceptance requires a stand-down. The run ends with the issue never executed; "The walkthrough still passes." Fix: on stand-down, clear the assignment carrying this worker's token; add "the stood-down issue is dispatched again." "this is not #27". cf. P19, K3, C4; see D9 | probe: with the assignment left, the pool is `[]`; R1 and R3 text | **r4:** open. **r5: released** (`i26-cold`): R1b, and Acceptance asserts re-dispatch and completeness (K9). "The fix exposes a loop, which I raise as C15, not as a held C12". See D9. **r6:** "still released, and tighter": `--unassign`, "only while the assignment still carries the worker's token". **r7:** "C12–C16 … still hold" (`i26-cold`) | r4 |
| C13 | i26-cold | 4 | R1, "before each dispatch"; Out of scope | the `Otherwise` branch has no dispatch, so R1 never fires; r4 deleted "With one worker … the same loop runs with a cap of one", "the only text that carried the fix to this path". Without `superpowers:dispatching-parallel-agents`, every pick drifts, "exactly E1, E2 and E6"; F8(e)'s condition was "quietly removed". Fix: one sentence; holds "under either reading in F13". cf. P21, F17, K1, F8(e) | probe: one worker with no assignment got `o1`; execute.md `Otherwise:`; r3-r4 diff | **r4:** open. **r5: released** (`i26-cold`): R1's one-worker clause; the branch is back in Acceptance. "A wording residue is in C16". **r6:** "still released": the one-worker assignment "now sits 'at the per-pick step that Step 4's return re-enters'". **r7:** "still hold" (`i26-cold`) | r4 |
| C14 | i26-cold | 4 | R3, "unreachable with one token per issue"; R1, "the worker's token" | an implementer may reuse a token; `next` step 1 then returns the worker's own in-progress issue ahead of its assignment, and R2 makes it stand down on its own work. State "one fresh worker identity per dispatch" in R1, or drop the reason. cf. K2, A15; see D4 | `headForActor` step 1 before step 3; R1 and R3 text | **r4:** open; "minor", "optional". **r5: "released** for parallel dispatch" (`i26-cold`): "Each dispatch mints a fresh `<n>`". "The one-worker path has no dispatch, so the rule does not reach it (C16)". **r6:** "still released" (`i26-cold`, "C13 and C14"). **r7:** "still hold" (`i26-cold`) | r4 |
| K1 | i26-cold2 | 4 | Out of scope / R1 | without `superpowers:dispatching-parallel-agents`, execute "still drifts to the milestone that leads the critical chain … on a supported configuration". Fix: the orchestrator assigns to itself before `next`; "Only the one-worker *lifecycle* belongs in #27." cf. P21, F17, C13 | execute.md l.167, l.169–173; O1 | **r4:** open. **r5: released** (`i26-cold2`): R1's one-worker bullet; the walkthrough runs that branch. **r6:** still holds (`i26-cold2`): the one-worker assignment at the per-pick step "is better than r5". **r7:** "K1 to K13 still hold against r7" (`i26-cold2`) | r4 |
| K2 | i26-cold2 | 4 | R1 / R3 | the token scheme is unstated. Per worker slot, reused: a slot whose earlier issue is in progress gets it from `next`, stands down, and strands the fresh assignment. Per slot with two assignments: `next` picks one arbitrarily (O4). Per dispatch: R3 holds, "but nothing says so", and execute.md says per worker. Fix: "One fresh token per dispatch is the simplest choice that is consistent with R3." cf. C14, A15 | R3; execute.md l.100–105; 0002 "Identity is minted…"; O4 | **r4:** open. **r5: released** (`i26-cold2`): "That makes R3's 'unreachable with one token per issue' true. The one-worker residue is K11". **r6:** still holds (`i26-cold2`, "K1 to K8, K10"). **r7:** "K1 to K13 still hold against r7" (`i26-cold2`): "The fresh-token-per-pick rule (K2, K11) survives ruling 3" | r4 |
| K3 | i26-cold2 | 4 | R3 | a stand-down leaves the issue assigned, so it leaves R1's pool for the run; "a refused start (WIP, blockers) strands ready milestone work. The run stops, and a person must re-invoke." Fix: "On stand-down, the orchestrator clears that assignment (`issue edit <id> --assign ""`) before it dispatches again"; "selection bookkeeping, not lifecycle, so it belongs in #26". cf. P19, C12; see D9 | O7, O8, O5; execute.md l.118–121 | **r4:** open. **r5: released** (`i26-cold2`): R1b clears the assignment (O5), and the walkthrough requires re-dispatch. "R1b also exposes K12." See D9. **r6:** still holds: R1b "honours 0002's 'never touch another's assignment'". **r7:** still holds ("K1 to K13") | r4 |
| K4 | i26-cold2 | 4 | R1, "dispatches again after workers return" | "nothing says that a worker returns after finishing an issue, and Step 4 tells it to go 'back to Step 2'"; nothing says what ends the run. A worker looping back is "caught only incidentally by R2 (O9)". Fix: "a worker returns after Step 4"; "the run ends when no unassigned ready issue remains and no worker is out", replacing l.186–187. cf. P20 | execute.md Step 4, l.186–187; O9 | **r4:** open. **r5: released** (`i26-cold2`): R1a. "The end rule has a hole when nothing in the pool can start (K12), but the rule I asked for is there.". **r6:** still holds (`i26-cold2`). **r7:** still holds ("K1 to K13") | r4 |
| K5 | i26-cold2 | 4 | R5 / Where it goes | execute.md would say both that the orchestrator chooses and that workers "select their own work" (l.131–132, l.169), and that a ready-set query "cannot do" what R1 uses one for (l.177–180); "An agent reading top-down meets the old model first." Fix: widen R5 to those lines and l.186–187. cf. F7 | execute.md lines as cited | **r4:** open. **r5: released** (`i26-cold2`): R5 and "Where it goes". "Wording is for review to check.". **r6:** still holds (`i26-cold2`). **r7:** still holds ("K1 to K13") | r4 |
| K6 | i26-cold2 | 4 | R4 / Where it goes | `how-to-use-git-zhi.md`, consulted before running `git zhi`, "still says to export the variable, and frames the per-command prefix as an exception". Fix: add it to "Where it goes", or file it as its own defect. cf. C9 (held half) | the "Worker identity: `ZHI_ACTOR`" section of how-to-use-git-zhi.md | **r4:** open. **r5: released** (`i26-cold2`). The section's "to override for a single command" framing "should change with it. I note this for review and do not hold on it.". **r6:** still holds (`i26-cold2`). **r7:** still holds ("K1 to K13") | r4 |
| K7 | i26-cold2 | 4 | Acceptance | symptom 2 is not discriminated: "the walkthrough passes against the current execute.md whenever its workers do next-then-start in sequence". Fix: "require both workers' `next` calls to complete before either start." cf. F8(c) | the Acceptance text | **r4:** open. **r5: released** (`i26-cold2`): starts "**concurrently**", and the control run. See K13(b). **r6:** still holds (`i26-cold2`). **r7:** still holds ("K1 to K13") | r4 |
| K8 | i26-cold2 | 4 | Acceptance | "no issue is started by two workers" judged from transitions passes "exactly when it should fail", since a lost update leaves one transition. Fix: judge it from worker-side records. cf. E17 | git-zhi#35, "only one transition was recorded" | **r4:** open. **r5: "released**, with K13" (`i26-cold2`): "the right observable"; whether a script can check it depends on K13(a). **r6:** still holds (`i26-cold2`). **r7:** still holds ("K1 to K13") | r4 |
| K9 | i26-cold2 | 4 | Acceptance | no completeness assertion: "a run that strands an issue (K3) or never re-dispatches (K4) passes". Fix: "every ready milestone issue was dispatched, or its absence is reported". cf. C12, P19 | the Acceptance text; O7, O8 | **r4:** open. **r5: "released**, with a note" (`i26-cold2`): "'The ready set' has no time attached"; read it as "every milestone issue was dispatched at least once, or is reported". cf. Q6. **r6:** "I re-attack it as K14" (`i26-cold2`). **r7:** still holds ("K1 to K13") | r4 |
| K10 | i26-cold2 | 4 | R3 | R3 "defends a case R1 and R2 already exclude": two protocol-following workers in one run never start the same issue. "Refused" is its reachable case, so the walkthrough's "lost" branch "will be exercised as 'refused', which is the K3 case." "keep it, but say this, so it is not read as the fix for #35's window." cf. C6; see D7 | R1, R2, R3 text; git-zhi#35 | **r4:** open; "minor". **r5: released** (`i26-cold2`): "R3 is not presented as the fix for #35. That is what I asked for." See D7. **r6:** still holds (`i26-cold2`). **r7:** still holds ("K1 to K13") | r4 |

Also recorded, not raised as findings, from round 4:

- `i26-evidence`: "The walkthrough is a shell simulation, not an agent following
  the skill text"; "Its race uses a scripted intruder, not a second dispatched
  worker"; "A stood-down worker's issue stays stranded (E14, in #27)."
- `i26-pushback`'s growth check: "r4 adds only R3's literal-id rule … and ruling
  2's stated reason (R4). Both are cited. Nothing answers nothing."
- `i26-fresh`: the orchestrator not seeing a close until the batch returns "now
  affects throughput only, not correctness."
- `i26-cold2` (Axis 1): Steps 3 and 4 "do not say who runs them"; line 104
  (`export ZHI_ACTOR=…`) and line 175 contradict R4, which "fixes execute.md".
- `i26-cold2`: the walkthrough "also passes when an issue is stranded and the
  run ends early (O7, O8)."

### Round-5 findings

Each row is as its raiser wrote it; none is merged with another. Overlaps are
marked "cf.".

| id | raiser | round | section of the subject | consequence if it ships | evidence | status | revision |
|---|---|---|---|---|---|---|---|
| A16 | i26-arch | 5 | R1b, "its assignment is cleared (`--assign ""`)" | a worker stands down when `next` returns something other than its assignment, and one way that happens is that someone else changed the assignment after dispatch, "for example a human assigning the issue to themselves". An unconditional clear then wipes `human:<name>`, against 0002's "a `human:` value, or an `agent:` name that is not a run token, is never touched", and defeats the way 0002 says a human removes an issue from the pool. Requirement: "clear only when the issue's current assignment equals the worker's token. Otherwise leave it." cf. Q5, P19 | 0002 text; J2: `--assign ""` and `--unassign` both leave `{"state":"pending","assigned":null}` | **r5:** open; "one sentence". **r6: released** (`i26-arch`): "That is my requirement verbatim. Bias note: it is my own bar, and it is met by name.". **r7:** still released ("A16, A17, A6/A11", `i26-arch`) | r5 |
| A17 | i26-arch | 5 | R1, "within `wip_limit` … chain-wide counting is #27's"; R1a, "On each return the orchestrator runs R1 again"; R1b; Acceptance, "one start refused or lost … its issue re-dispatched" | a refused start stands down, R1b returns the issue to the pool, R1a re-dispatches it, "and the state that caused the refusal is unchanged", so the run never reaches R1a's end condition "until outside work happens to finish". "Under r4 the same refusal stranded the issue, and the run *terminated*." A walkthrough inducing its stand-down with `wip_limit` "will not terminate either". "the loop is created by R1a and R1b, both #26 requirements". Requirement, either: R1's dispatch bound reads git-zhi's own in-progress count ("This pulls a minimal part of F18 into #26"); or a `WIP limit reached` refusal does not trigger re-dispatch of that issue "until a worker returns or the in-progress count falls; if nothing is live, the run ends and reports the issue by name". cf. P22, F19, C15, K12, Q2, A6, F18 | J1: `WIP limit reached: 1 issue(s) already in progress (limit 1)` with `human:someone` holding an mB issue; J2; J3: pool `["A1"]` after the clear, start still refused. "The loop is my inference from one observed cycle with nothing in it that changes; I did not run it repeatedly." | **r5:** open; "one sentence". **r6: released** (`i26-arch`): R1c, with the acceptance case for `wip_limit` above zero. "I took the second of the two shapes I offered, and the composition argument above is my check that it closes the loop. Bias note: my own bar.". **r7:** still released (`i26-arch`): "Ending on the single agent's own refusal is the correct exit, and the acceptance case covers it." | r5 |
| E18 | i26-evidence | 5 | Acceptance, "one start refused or lost, with that worker standing down and its issue re-dispatched (R1b)" | the bullet "can be met only by the *refused* case". A lost start leaves the issue in progress under the other actor, outside the pool, as R1b says itself. "an implementer either cannot pass, or passes only by choosing the `wip_limit` case without being told to." Reword: "one start refused while the issue stays pending (for example by `wip_limit`), with that worker standing down and its issue re-dispatched; and one start lost to another actor, with that worker standing down". cf. R1b, E14 | `walk5.sh`: 3 lost starts in 9 steal runs, re-dispatched 0 of 3; 27 refused starts in 9 wip runs, re-dispatched 27 of 27. A refusal because another actor holds the issue is the lost case (round-2 r7: `cannot start: issue is in-progress`) | **r5:** open; "accept, with one wording change to one acceptance bullet (E18)". **r6: released** (`i26-evidence`): "Measured both ways: 6/6 pending refusals re-dispatched, and 4/4 lost starts dispatched only once". **r7:** "still released" ("E1 to E18"): "E18's split (pending refusals re-dispatched, lost starts dispatched once) held in all runs" | r5 |
| P22 | i26-pushback | 5 | R1a, "On each return the orchestrator runs R1 again"; R1b, "its assignment is cleared … so the issue returns to the pool"; the R3 paragraph, "Its reachable cases are a start refused for `wip_limit`" | with `wip_limit` set and the chain-wide count at the limit, dispatch, refusal, stand-down, give-back and immediate re-dispatch repeat; "The pool never empties, so R1a's end condition is never reached": "an unattended run that spins fresh workers until something external frees a slot or the session is killed". "r4 stranded the assignment (my P19), which prevented this loop by accident." "Execute today does not loop here", so "this is new with r5, not the pre-existing P17 that #27 owns". Fix: "A stand-down caused by a `wip_limit` refusal does not trigger a re-dispatch until another worker returns. If no worker is live, the run ends and reports the refusal." cf. A17, F19, C15, K12, Q2, P17 | round-3 probe: `WIP limit reached: 2 issue(s) already in progress (limit 2)`; the subject's text. "the loop itself was not run" | **r5:** open; "medium, conditional": inert at `wip_limit` 0; "If the human rules execute supported only with `wip_limit` 0 until #27 lands, this becomes a note". **r6: released** (`i26-pushback`): "Each further dispatch now needs a return, so refused dispatches are bounded by returns." "My suggested fix was exactly this." "The one-worker residue is P24.". **r7:** stands | r5 |
| P23 | i26-pushback | 5 | R1, `Otherwise` clause, "assigns to its own token before each `next`", against "Each dispatch mints a fresh `<n>`, so a token is used for exactly one issue"; R3, "unreachable with one token per issue" | the one-worker branch has no dispatch, so "its own token" reads as one token for the session. Under that reading R3's justification is false on the branch: `next` resumes the token's own in-progress issue first and R2 makes the agent "return to itself with its in-progress issue untouched", reachable "whenever the agent re-enters selection with an issue still in progress under its token". Fix: "In the `Otherwise` branch, the agent mints a fresh `<n>` per issue too, and R4's per-command identity makes switching tokens free." cf. C16, K11, Q1, C14, K2; see D4, D10 | 0002's resume-own tier; not re-measured | **r5:** open; "Unconditional, but low". **r6: released** (`i26-pushback`): "This removes the second reading, so R3's 'unreachable with one token per issue' is now true on both paths.". **r7:** stands: "P23 also stands under ruling 3. 'A token is used for exactly one issue' is still true. Self-resume reuses a token only for the same issue." | r5 |
| F19 | i26-fresh | 5 | R1b with R1a and R3; Loop control's stop list | a WIP refusal, which r5 names as R3's reachable case, cycles through stand-down, clear, re-dispatch and refusal, and "The end condition … never holds, so the run spins with no bound". "P17 and C4 were released to #27 in round 4 on the grounds that 'r4 does not make it worse'. **r5 does make it worse.**" Separately, Loop control's "a tool refused the action" (l.84) still says to stop the whole run where R3 says to stand down and re-dispatch, "so the two rules contradict each other". Fix: a WIP-refusal stand-down clears the assignment and "the orchestrator then dispatches nothing more until a worker returns having finished. If no worker is live, the run ends and reports the WIP-blocked issues by name"; reword Loop control's "tool refused" stop; add a walkthrough run with `wip_limit` above zero and one outside in-progress issue that "passes if the run ends in finite steps and reports the blocked issue". cf. A17, P22, C15, K12, Q2, P17, C4 | probe: `wip_limit 2`, A and B in progress, C refused `WIP limit reached`; after `--assign ""`, `issue list --ready --milestone m1` returned `[('C', None)]`; execute.md l.80-89 | **r5:** open; "**modify**, on F19 only". **r6: released** (`i26-fresh`): "R1c is the fix shape I asked for". **r7:** still released: "The early end in R1c now reports the whole pool, which strengthens F19's release." | r5 |
| C15 | i26-cold | 5 | R1b with R1a; the K10 paragraph; Acceptance, "one start refused …, its issue re-dispatched" | "a WIP refusal has a cause outside the run. Re-dispatching does not remove that cause." "In r5 the run spins, burning workers until a person intervenes." "Refused … re-dispatched" plus "every ready issue dispatched before the run ended" "passes only if the walkthrough's refusal cause clears by itself". "this is not C4's chain-wide counting (#27, F18) … C15 is about what selection does after a refusal, which r5 itself introduces." Fix: after a **refused** start, "as distinct from a lost one, the orchestrator dispatches no new worker until a live worker returns. If none is live, the run ends and reports the refusal by name"; Acceptance says "re-dispatched, or reported if the refusal persists". cf. A17, P22, F19, K12, Q2, C4 | `wip_limit 1`, `human:chris` holding an in-progress issue in another milestone: three dispatches in a row each saw `pool=["r1"]`, `next` returned `r1`, start refused `WIP limit reached: 1 issue(s) already in progress (limit 1)`; after `--assign ""` the pool was `["r1"]` again | **r5:** open; "**modify**, one clause (C15)". **r6: released** (`i26-cold`): "There is no unbounded loop. One residue is raised as C18". Bias declared: "C15's fix is in r6 almost in the words I used". **r7:** "still hold" (`i26-cold`) | r5 |
| C16 | i26-cold | 5 | R1, third bullet, against the one-worker bullet; R3, "unreachable with one token per issue" | "on the `Otherwise` branch a reader can keep one token across picks". R3's stated reason is then false on that path, "And K2's reuse case … becomes reachable after any interrupted issue". Fix: "each pick, on both paths, mints a fresh `<n>`". cf. P23, K11, Q1, C14; see D4, D10 | `headForActor` step order, as K2; R1 and R3 text | **r5:** open; "minor"; "can be fixed in the same edit, or left to the implementing issue's wording". **r6: released** (`i26-cold`): "for the single worker that is spelled out as one token per issue". **r7:** "still hold" (`i26-cold`) | r5 |
| K11 | i26-cold2 | 5 | R1, one-worker bullet, with "Each dispatch mints a fresh `<n>`" | "assigns to its own token" reads as one token for the run. With an in-progress issue under that token, `next` step 1 returns it ahead of the new assignment, R2 stands the agent down, R1b clears, R1 assigns again, "and the cycle repeats". Today that state arises only from a stuck issue, which Step 3's valve stops, "So the consequence is latent, not live." Fix: "mints a fresh `<n>` per pick", or "one token per issue on every path". cf. P23, C16, Q1; see D4, D10 | `headForActor` step 1 comes before step 3; R1 text | **r5:** open; "minor", "optional". **r6: released** (`i26-cold2`): "`headForActor` step 1 can then never return a stale in-progress issue ahead of the assignment.". **r7:** still holds ("K1 to K13"): it "survives ruling 3" | r5 |
| K12 | i26-cold2 | 5 | R1a's end condition, with R1b | a start refused for `wip_limit` is cleared back into the pool and picked again at once. While the slot is held by something that never returns to this run (another milestone's in-progress issue, or E14's issue lost to an outside actor), "the pool never empties". If the orchestrator instead dispatches nobody under "within `wip_limit`", "the run neither works nor ends". "this is C4's 'dispatch livelock' … R1b … makes it reachable from inside #26's scope, and #26's own walkthrough requires a refused start." Fix: "If nothing in the pool can be started (a start was refused for `wip_limit` and no worker of this run is live), the run stops and reports"; Loop control's "a tool refused the action" is that stop. cf. A17, P22, F19, C15, Q2, C4 | O10: `wip_limit 1`, one slot held, three cycles of clear, pool check, assign to a fresh token, start: refused each time, pool `['m1','m3']` on every cycle; `checkWIPLimit` | **r5:** open. "If K12 is not taken, my recommendation becomes **modify**". **r6: released** (`i26-cold2`): "That breaks the refuse, clear, re-pick cycle O10 measured.". **r7:** still holds ("K1 to K13") | r5 |
| K13 | i26-cold2 | 5 | Acceptance, the pass condition | (a) "'Commits' cannot attribute work to a worker, because all workers share one git author"; the worker record must name the worker's token. (b) "'Concurrently' must mean launched at once. Otherwise the control run … can pass by luck on the duplicate-work condition, while still going red on drift." "an implementer can write a walkthrough that goes green for symptom 2 without testing it, or one whose duplicate-work check cannot read its own evidence." Fix: "each worker's record names its token", and "the concurrent starts are released together". cf. K7, K8, E17, Q4 | 0002 "Identity is not commit authorship"; git-zhi#35's body; the race window "under 20 ms"; round 4's 20 of 20 races behind a barrier | **r5:** open; one of "two one-line changes". **r6: released**, with K14 (`i26-cold2`): "That is what I asked for.". **r7:** still holds ("K1 to K13") | r5 |
| Q1 | i26-cold3 | 5 | R1, "With one worker" and "Each dispatch mints a fresh `<n>`"; R3's reason for dropping resume | the one-worker bullet reads as one token for the run; the next says a token serves one issue. If the agent keeps one token, resume is reachable: `next` step 1 returns its own in-progress issue first, and "Execute.md's own Step 4 re-start can leave one". If it mints a fresh token per issue, "it renames itself mid-run, which 0002 asks crochet's discipline to prevent". "implementers pick either answer, and the walkthrough's one-worker case passes either way on a clean run." Fix: a fresh `<n>` per issue through R4's per-command prefix, and say why that is not 0002's "rename": "its previous issue is done or released before the token changes". cf. P23, C16, K11; see D4, D10 | observed: the same actor starting a second issue while one is in progress gets rc 0, "start does not enforce per-worker WIP" | **r5:** open. **r6: released** (`i26-cold3`): the 0002 "rename" horn "is answered by structure, though not in words". A note, "not a hold": "the token belongs to the issue through Step 4's in-scope reopen". cf. F21, W3; see D10, D13. **r7:** "Still released" (`i26-cold3`): r7 "now state[s] the token-per-issue rule and the Step 4 reopen explicitly" | r5 |
| Q2 | i26-cold3 | 5 | R1a, R1b, and the R3 note naming the wip refusal as a reachable case | R1b clears the refused issue and R1a takes it again. If the in-progress issue belongs to another milestone or an outside actor, "the refusal repeats without end". If R1 dispatches zero under "within `wip_limit`", "no worker is live and the pool is not empty. R1a's end condition is never met, and no Loop control stop condition matches." "a spinning or hung run, the exact failure Loop control exists to prevent." Fix: "A start refused for `wip_limit` with no live worker of this run is a stop condition, reported once." cf. A17, P22, F19, C15, K12 | observed: `wip_limit 1` with one issue in progress, a new actor's start refused `WIP limit reached ... pass --force`, rc 1 | **r5:** open. **r6: released** (`i26-cold3`): "Every cycle consumes a live worker, and workers are finite, so the run terminates." The one-worker path is Q10. **r7:** "Still released": "each refused re-pick still uses up one return, and the one-worker case now ends directly" | r5 |
| Q3 | i26-cold3 | 5 | R1 | R1 "never says which one" to take, "so the obvious build takes the first and drops CCPM ordering inside the milestone". "with fewer workers than ready issues, the milestone's longest path starts late." Fix: name a ranking computable from `blocks`/`blocked_by` "(for example, most downstream issues first)", or state that creation order is accepted for now and why | observed: `issue list --ready --milestone m3` lists standalone E before C, the head of C→D→F; `list --critical --milestone m3` returned m2's X, Y, Z ("chain-wide") | **r5:** open. **r6: released** (`i26-cold3`): "I accept it as a recorded cost, and it does not block." Two wording conditions: the cost is written into execute.md, and urgency needs a direction (Q9). See D12. **r7:** "Still released": the cost "is now stated in execute.md". "See the nit under Q11" | r5 |
| Q4 | i26-cold3 | 5 | Acceptance | "a shell script that implements R1 to R3 correctly passes while execute.md still says something else"; the only link is "the execute skill states R1 to R5", a reading check. "green acceptance with a wrong skill text". Fix: the walkthrough runs the commands as they appear in execute.md's fenced blocks, "substituting only placeholders". Also: "Run without R1 to R3 … fails" "depends on a race. Say how many trials and what failure rate count". cf. K13, F8(f) | the Acceptance text; "How the walkthrough is scripted belongs to the implementing issue" | **r5:** open. **r6: released** (`i26-cold3`). The fenced-block narrowing "still stands as advice". **r7:** "Still released" ("Q4 to Q8") | r5 |
| Q5 | i26-cold3 | 5 | R1b | "its assignment is cleared" names no agent, and names `--assign ""` where the binary documents `--unassign`. "If the worker clears and the orchestrator also runs reclamation, or both clear on the stolen case while the outside actor is writing that same issue ref, that is one more read-modify-write in git-zhi#35's window." "two implementations that differ, both untested." Fix: "the orchestrator clears, on the worker's return, using `--unassign`." cf. A16, P19; see D11 | observed: `--unassign` exists (`--help`), rc 0; `--assign ""` rc 0 | **r5:** open. **r6: released** (`i26-cold3`): "That is my fix and A16's together." The check-then-act "belongs to #35, not here". **r7:** "Still released" ("Q4 to Q8") | r5 |
| Q6 | i26-cold3 | 5 | Acceptance, the third pass condition | execute.md lines 122–123 forbid dispatching an issue assigned outside the run, "for example to a `human:`. Any milestone with a human-assigned ready issue therefore fails K9 by design." "'Ready set' also changes as issues finish." Fix: "every issue that was ready and unassigned-or-this-run's at any point during the run was dispatched". cf. K9's r5 note | execute.md l.122–123; the Acceptance text | **r5:** open. **r6: released** (`i26-cold3`): "An issue R1c reports by name was dispatched, so it does not fail the condition." cf. E19, P25, C18, K14, W1. **r7:** "Still released" ("Q4 to Q8"): "Q6's human exclusion is kept" | r5 |
| Q7 | i26-cold3 | 5 | R2 | "If it returns anything else" does not clearly cover `next` erroring with `no actionable issues…`, what a worker sees "when an outside actor has started its assigned issue and nothing else is ready". execute.md lines 182–187 give that error another meaning, stop and end the run when all workers stop, so "the old and new end conditions coexist in the edited skill". Fix: either outcome means stand down and return; "The paragraph's run-end sentence moves to R1a." cf. K5, F19 | execute.md l.182–187 | **r5:** open. **r6: released** (`i26-cold3`). **r7:** "Still released" ("Q4 to Q8") | r5 |
| Q8 | i26-cold3 | 5 | R1, "The ready rule comes from that query" | 0002 calls the ready-set query wrong for selection; "The orchestrator is not the asker, and `assigned` is in the JSON." "One sentence of reason prevents a later revert." Also `postmortem.md:108`'s "exported" goes stale under R4; "Add it to R5's sweep." cf. D3 | 0002 "has no assignee filter", "no notion of who is asking"; `skills/postmortem/postmortem.md:108` | **r5:** open; "Low". **r6: released** (`i26-cold3`): "Both are in r6". cf. C19, W7. **r7:** "Still released" ("Q4 to Q8") | r5 |

Also recorded, not raised as findings, from round 5:

- `i26-evidence`: "`wip_limit` churn is visible and belongs to #27". With
  `wip_limit=2` and an outsider holding one slot, CAP=2 "wastes one dispatch per
  round: 3 refusals in a 5-issue run"; "this is a cost, not a correctness
  problem: every issue still got done." See the `wip_limit` cluster below.
- `i26-evidence`, K10 confirmed: in `SCEN=none`, "R1 and R2 alone produce no
  collision and no stand-down in 8/8 runs. R3 is reached only through
  `wip_limit` or an outside actor, as r5 says."
- `i26-pushback`'s growth check: every added clause cites a round-4 finding but
  one, "Run without R1 to R3, the same walkthrough fails", which "answers no
  named finding". "I flag it as unanchored but would keep it."
- `i26-arch`: R1b "sits inside the question 0002 left open, not against an
  answer it gave" (0002's Open Questions on unassigning as each issue
  completes). Not re-examined: whether `checkBlockers` refusals "can recur in
  the same loop".
- `i26-fresh`: the one-worker assignment belongs in the per-pick paragraph
  (l.169), not the identity block headed "once per run, before any dispatch"
  (l.96). "That placement detail belongs to the implementing issue, and I am
  not raising it as a finding."
- `i26-cold`: "My one reservation about size is that the Acceptance section is
  now the largest part of the subject. That is the right place for the growth."
- `i26-cold3`: ARCHITECTURE.md:164's "enforces per-worker WIP of one
  independently" against its observation that the same actor started a second
  issue with rc 0. "This predates r5 and is not r5's to fix." Also: execute.md
  lines 175–180 argue that a ready-set query "cannot do" what R1 now uses one
  for, and R5's catch-all covers these lines "only in intent".

### Round-6 findings

Each row is as its raiser wrote it; none is merged with another. Overlaps are
marked "cf.".

| id | raiser | round | section of the subject | consequence if it ships | evidence | status | revision |
|---|---|---|---|---|---|---|---|
| A18 | i26-arch | 6 | R1, "Order" ("Nothing in git-zhi 0.7.2 exposes that order for a single milestone … the loss is a recorded cost of this change") | "the skill would carry a factual claim about git-zhi that is false (L1, L2), and it would schedule worse than it needs to". In L1 the pool picks `Afree` first, "while `next` would pick `A1`, the head of a three-issue chain". "by `urgency`, then creation order" is "a *new* policy, not a restoration": `headForActor` never reads urgency. Requirement: order the filtered pool by its position on `git zhi list --critical --format json`'s `critical_chain`, then by git-zhi's own order; "when it lies wholly in another milestone the intersection is empty, and the fallback is creation order: no worse than r6". "Whether urgency then comes before creation order is the human's call." cf. W2, Q9, Q3; see D12 | L1: mA holds `Afree` (created first) and A1→A2→A3, mB holds `B1`; `list --critical --milestone mA --format json` gave `["A1","A2","A3"]`, the pool `["Afree","A1"]`, bare `next` → `A1`. L2, source: `runChainList` with `--critical` uses `g.CriticalChain()` over the whole graph, ignoring `--milestone`, "the same chain `headForActor` ranks candidates by"; `sortIssues` orders by UUID | **r6:** open; "modify, by one clause". "I would stand aside if the human rules urgency-first is deliberate, provided the false sentence about git-zhi is removed.". **r7:** "**released**; I accept ruling 4" (`i26-arch`): "Ruling 4 gives exactly that." "Bias note: this is released against my own bar, and the bar is met in full, so I am releasing rather than standing aside." | r6 |
| E19 | i26-evidence | 6 | Acceptance, the third pass condition, against the case "`wip_limit` above zero, with a slot held from outside the run" | R1c "stops correctly after 2 dispatches, but m3 was ready and unassigned and never dispatched, so the run **FAILs** its own condition". R1c's report names only the refused issues; "m3 is never named, though the run ended with it in the pool". "Otherwise the walkthrough can pass the R1c case only by not checking the third condition." Fix: the pass condition reads "… was dispatched, or was in the pool at an R1c stop and named in its report"; R1c reports the refused issue "**and the remaining filtered pool** by name". cf. P25, C18, K14, W1, Q6 | `walk6.sh` `wipout` CAP=2: 2 dispatches, `R1c stop: refused with no live worker`, m3 never dispatched; CAP=1: m2 and m3 left the same way | **r6:** open; one of "two acceptance edits". **r7:** "**released**": "Measured passing for CAP 2 and 1, and failing when a run ends without an R1c stop" | r6 |
| E20 | i26-evidence | 6 | Acceptance, "the one-worker branch (R1, F17)", with R1's "every pick, on both paths, uses a fresh `<n>`" | "a reused token works a reopened earlier issue in place of the pick, and R2's `.assigned` check passes, because the reopened issue is still assigned to the reused token (D2)". The walkthrough has no reopen, so `REUSE=1` and `REUSE=0` both PASS. Fix: add "a reopened earlier issue", or "a pass condition that each worker record's issue equals the issue assigned at that pick". "Either one makes the walkthrough go red when the token is reused." cf. W3, F21, Q1; see D10, D13 | r39: reused `agent:solo`, its earlier issue a done then reopened; c assigned; `next` returned "`a reopened`". Bracket, fresh `agent:run-2`: `c pending`. Control, reused token without a reopen: b, the pick. `walk6.sh` `REUSE=1` and `REUSE=0` both PASS | **r6:** open; one of "two acceptance edits". **r7:** "**released**": the reused-token case "goes red under `REUSE=1` (3 wrong issues, m1 worked twice) and green under fresh tokens" | r6 |
| P24 | i26-pushback | 6 | R1c, "dispatches nobody further until a live worker returns. If none is live, the run ends"; R1, "With one worker … that agent is both" | in the `Otherwise` branch, after a `wip_limit` refusal, "One reading says a live worker exists (itself), so it waits for that worker to return, which is itself waiting. The result is a stall with no report, under Loop control's run-through default. The other reading ends the run. Both readings follow from the text." Fix: "In the one-worker branch, a refusal of this kind ends the run", or define "live" as dispatched and not yet returned, excluding the orchestrator. cf. F20, C17, Q10 | the text of R1 and R1c | **r6:** open; "ambiguity, low–medium". "Would change my mind: if the implementing issue states the one-worker loop as orchestrator code that never counts itself, this is wording only.". **r7:** "**released**": R1c's one-worker bullet, and "Acceptance now runs a refusal on that branch" | r6 |
| P25 | i26-pushback | 6 | R1c, "If none is live, the run ends and reports the refused issue by name"; Acceptance, K9's pass condition, with the `wip_limit` case | with more pool issues than free slots, X is refused, nobody is live, the run ends, and Y, "ready and unassigned throughout, was never dispatched. The walkthrough then fails K9 even though R1c behaved as specified." An implementer bends R1c or shrinks the scenario; "Either way the subject has chosen nothing", and Y is not in the report. Fix: R1a "… or as R1c ends it"; K9 excludes issues still in the pool at an R1c end, and R1c's report names every such issue. cf. E19, C18, K14, W1 | the text of R1a, R1c and Acceptance; "I did not reproduce R1c's termination on 0.7.2" | **r6:** open; "contradiction, low–medium", "Unconditional, given the walkthrough as specified". **r7:** "**released**": R1c, K9 and the `wip_limit` case "All three now agree" | r6 |
| F20 | i26-fresh | 6 | R1a, R1c | on the one-worker path "an implementer could read 'a live worker' as itself and wait for its own return, which never comes. The intended reading, that the stand-down leaves no worker live and so the run ends, follows, but only by inference." Fix: "On the one-worker path, a stand-down is the return, and leaves no worker live." cf. P24, C17, Q10 | the text of R1a and R1c | **r6:** open; "minor, wording"; "can ride with the implementing issue". **r7:** "**released**": R1c's second bullet and the matching acceptance case | r6 |
| F21 | i26-fresh | 6 | R1, "Every pick, on both paths, uses a fresh `<n>` … that costs nothing" | "r6's 'that costs nothing' overstates it." Under one token, a single agent that stopped mid-issue gets its in-progress issue back from bare `next` (resume-own) on "continue". Under a fresh token per pick, re-entry "mints a new token, assigns a new issue, and leaves the first one in progress under the old token. That issue is stranded and holds a WIP slot, which is F3's shape on the single path." Fix: resume the issue in hand under that issue's token rather than picking; "The token belongs to the issue for every command on it, including Step 4's reopen and start." cf. W3, Q1's note, E20; see D10, D13 | `headForActor` step 1; Loop control's stop list | **r6:** open; "minor". "The implementing issue can carry it; it does not block.". **r7:** "**released, with F22 below**": "That is what I asked for. Whether its wording works on the one-worker path is F22." | r6 |
| C17 | i26-cold | 6 | R1c, with R1's "that agent is both" | "After its worker half stands down, an implementer can count the agent as still live and wait for 'a live worker' to return. Then nothing ever returns." "it occurs only through wording." Fix: "On the one-worker path, a refused start ends the run and reports." cf. P24, F20, Q10 | the text of R1 and R1c | **r6:** open; "minor"; "can ride in the same edit". **r7:** "**released**": R1c's one-worker bullet; "Acceptance tests it" | r6 |
| C18 | i26-cold | 6 | R1c ("reports the refused issue by name"); the Acceptance F19 case; the K9 pass criterion | with a slot held from outside and more ready issues than workers, "The remaining pool issues are never dispatched and never named. The run ends and its report hides ready work." K9 fails on the case Acceptance requires, unless the scenario has one ready issue: "In that case the criterion passes because the test was made too small to fail it." Fix: R1c reports "the refused issue **and the pool left undispatched**"; K9 becomes "dispatched, or named in the end-of-run report". cf. E19, P25, K14, W1 | the text of R1c and Acceptance | **r6:** open. "Fix C18 in R1c's report clause and K9's wording." "With C18 answered, I would accept.". **r7:** "**released**": the F19 case requires "more than one issue in the pool", "so the criterion can fail" | r6 |
| C19 | i26-cold | 6 | R1, "0002 calls the ready-set query the wrong tool … because it has no assignee filter and no notion of who is asking" | "0002 says only that the query 'has no assignee filter', and 'That query is wrong'. The phrase 'no notion of who is asking' is execute.md's (Step 2's `next` paragraph), and R5 is about to rewrite that paragraph. The sentence argues against an accepted decision, so its quote should be the decision's own." Fix: quote 0002 exactly. cf. W7, Q8 | 0002 text; execute.md Step 2 | **r6:** open; "minor, attribution". **r7:** "**released**": "0002 is now quoted exactly". "The `--assigned` note is correct" | r6 |
| K14 | i26-cold2 | 6 | Acceptance condition 3, against R1c and the F19 case | "a correct run fails condition 3 whenever the pool held more issues than were dispatched. An implementer can avoid it by building a one-issue scenario, which hides the contradiction rather than resolving it." In the product, a run ending under R1c "reports one refused issue and stays silent about the others it never dispatched". Fix: condition 3 reads "…was dispatched, or named in R1c's report"; R1c's report names every issue left in the filtered pool. K9 re-attacked. cf. E19, P25, C18, W1 | subject lines 78–86 (R1c), 139–140 (the F19 case), 149–150 (condition 3) | **r6:** open; "accept, with K14's two clauses". **r7:** "**released**": "the contradiction is exercised and resolved rather than avoided" | r6 |
| K15 | i26-cold2 | 6 | R1a, which lost r5's "Loop control's wording changes to match" | the sentence moved to R1c, "where it now covers only the 'a tool refused the action' bullet". Loop control's "the ready set is empty" and "every remaining issue is blocked by an unfinished one" (execute.md l.82–83) "contradict R1a's end rule". "an implementer will probably catch it. But the explicit instruction is gone." Fix: restore the sentence to R1a. cf. P20, W5 | r5-r6 diff, the removed R1a line; execute.md l.79–89 | **r6:** open; "minor", "optional". **r7:** "**released**": R1a "names both stops … as replaced" | r6 |
| Q9 | i26-cold3 | 6 | R1, "Order" | "A lexical sort gives `high` < `low` < `normal`, so `low` doc issues go ahead of `normal` code issues. That is the exact inversion of `techwriter-prompt.md:119`." "git-zhi's scheduler does not use urgency, so there is no tool behaviour to copy. This is new policy in crochet, and it must state its order." Fix: "high, then normal, then low (an absent value is normal), then creation order." cf. A18, W2, Q3, and `i26-evidence`'s ordering note; see D12 | `internal/issue/issue.go` defines `Urgency` as `"high"`, `"normal"`, `"low"`; no file under `internal/graph/` reads urgency; `skills/refinement/techwriter-prompt.md:119` | **r6:** open; "Low to medium". "I hold neither" (Q9, Q10). "Q9 is the one I would fix before implementation rather than after.". **r7:** "**released**": "The lexical-sort inversion I raised can no longer occur, so the row is moot rather than fixed. That satisfies it." | r6 |
| Q10 | i26-cold3 | 6 | R1c, "if none is live", on the `Otherwise` branch | "A reader who counts the orchestrating agent as 'live' waits on itself: dispatch is frozen, the only agent is waiting, and the run never ends." "The plain reading ends the run, because the worker has returned." Fix: "the orchestrating agent is not a live worker; on the one-worker path a refusal ends the run." cf. P24, F20, C17 | the text of R1c | **r6:** open; "Low". "I hold neither". **r7:** "**released**": r7 "say[s] what I asked" | r6 |
| W1 | i26-cold4 | 6 | Acceptance, the third "passes if" criterion, against R1c | `wip_limit 1`, the slot held from outside, two ready issues: "One worker is dispatched, it is refused, no worker is live, and the run ends. The second issue was never dispatched, so the walkthrough fails by its own criterion." "the implementer either gets a red walkthrough or builds the scenario with a single issue so that it passes. In the second case the acceptance hides the very behaviour it should show." Fix: count an issue "if it was dispatched **or** named in the end-of-run report". cf. E19, P25, C18, K14 | observed: with the slot held outside, start refused `WIP limit reached …`, exit 1, the issue stays `pending`; the text of R1c and Acceptance | **r6:** open; the first of the "modify" changes. **r7:** "**released**" | r6 |
| W2 | i26-cold4 | 6 | R1, "Order" | `headForActor` takes the first candidate on the **whole-graph** critical chain, otherwise `sortIssues` (UUID, roughly creation order); the graph never reads `Urgency`. The same chain is exposed by `list --critical --format json`. "So 'nothing in git-zhi 0.7.2 exposes that order' is true only in the narrow sense that nothing is milestone-scoped. Bare `next` was not milestone-scoped either." "urgency first" makes `urgency` matter to scheduling "for the first time". "the change gives up a property it could keep, records that as an unavoidable cost, and changes priority policy without anyone deciding to." cf. A18, Q9; see D12 | observed `critical_chain` listing b1, c1, d1, e1 "when the milestone held the longest path"; `headForActor`, `sortIssues`; grep of `internal/graph` for `Urgency` finds nothing | **r6:** open. "*Human's decision?* Yes. Whether urgency outranks the critical chain is a product choice about CCPM, not a selection fix.". **r7:** "**released**": "Settled by ruling 4, which I accept." "the stated cost is now accurate" | r6 |
| W3 | i26-cold4 | 6 | R1, "Every pick, on both paths, uses a fresh `<n>`", read with ruling 2 | 0002 lists "resumption after a restart" among what it wanted, and identity "fixed for the life of a worker". A one-worker agent re-entering Step 2 with its issue still in progress "mints a new token", draws from a pool that excludes in-progress issues, and starts a different issue: "The first issue is stranded under the old token." "This is not #27's dead worker: the worker is alive and has abandoned its own work." "Ruling 2 settles setting the **same** token on every command. It does not settle changing the token between issues inside one agent." "Options for the human": one token for the one-worker path; look for an in-progress issue under this run's tokens before minting; or "Rule explicitly that 'worker' means one dispatch for one issue", "a reading of 0002 that the subject assumes without recording it". cf. F21, Q1's note, E20; see D10, D13 | 0002 text; `headForActor`; the ready pool excludes in-progress issues | **r6:** open; "put W3 to the human". **r7:** "**released**": "Settled by ruling 3, which I accept." "The residual is W10, which is new." | r6 |
| W4 | i26-cold4 | 6 | R1a, R1b, R1c, R2 and R3 together | the orchestrator must know which return happened (done; refused, with git-zhi's text; lost start; `next` mismatch; read failure), and "The subject never says that the worker reports this"; the worker record "is likewise never defined". R2 has no retry clause: a failing `next` gives stand-down, give-back and immediate re-dispatch, "because R1c does not apply", "with no bound". "the termination argument holds only if the agent infers a contract the text does not give." Fix: one line listing the return outcomes; extend R3's retry-don't-count rule to `next`, or treat a repeated stand-down on the same issue the way R1c treats a refusal | the text of R1a to R3 | **r6:** open; "name the worker's return outcomes (W4)". **r7:** "**released**, with a nit the implementing issue can carry": "One unbounded path remains: a stand-down with the issue still pending for a reason other than a refused start". "**Nit:** read R1c's trigger as 'stands down with the issue still pending', whatever the cause." "Not a bar." cf. V1 **r8:** "**released**" (the W4 nit): "R1c now fires on any stand-down that leaves its issue pending … That closes the unbounded re-dispatch path." | r6 |
| W5 | i26-cold4 | 6 | R1a; R1c ("Loop control's stop … changes to match"); Where it goes | Loop control's "the ready set is empty" and "every remaining issue is blocked by an unfinished one" stay, and "tell the orchestrator to end its turn and report while workers are still live, or while the pool is non-empty and the chain-wide ready set is empty". "the same contradiction F19 fixed for the refusal bullet stays in place for two others." Fix: say that Loop control's stop list is restated in terms of R1a and R1c. cf. K15, P20 | execute.md Loop control | **r6:** open. **r7:** "**released**": "R1a now replaces both Loop control stops by name." | r6 |
| W6 | i26-cold4 | 6 | R3, "waits briefly"; "the pause length … belong[s] to the implementing issue" | "In this session's harness the Bash tool states that 'Foreground `sleep` is blocked'." A worker told to wait "either errors or skips the wait. If it skips the wait it re-reads at once, which narrows nothing in git-zhi#35's window, while it believes it waited." Fix: name a wait that works under the harness, or say what to do when sleep is refused. cf. D1 | the harness's Bash tool statement | **r6:** open. **r7:** "**released**": "That was my fix." | r6 |
| W7 | i26-cold4 | 6 | R1, the 0002 paragraph (Q8) | "`issue list --assigned <worker>` exists. What it cannot do is select **unassigned** issues". "A reader checking `--help` finds the flag and doubts the rest of the reasoning." Fix: "cannot filter to unassigned, and has no notion of who is asking". cf. C19, Q8, E11 | observed: `issue list --assigned ""` returned 5 of 5 issues, "an empty value is no filter" | **r6:** open; "minor". **r7:** "**released**" | r6 |
| W8 | i26-cold4 | 6 | R2 | the worker already knows its issue id and starts it by literal id, so "`next` adds only a pre-check that R3's re-read already covers". "that makes 0002's sentence nominal." "In the archive, 0002 now describes a selection mechanism that no longer selects." cf. D3, C7 | 0002 "crochet:execute selects work with `git zhi next`"; R2 and R3 text | **r6:** "a note for the human, not a defect"; "none at run time". "*Human's decision?* Yes: whether that sentence in 0002 deserves an amendment later. It is not needed to ship this.". **r7:** "**released**": "Recorded as true, and kept for 0002's sake. That was all I asked." | r6 |
| W9 | i26-cold4 | 6 | throughout: "about fifty ids pointing into `docs/assessments/issue-26-selection.md`" | the fresh token per pick, the token-guarded unassign, and the wait and re-read "are non-obvious without their reason", which "lives in the assessment record, which is archive". "An agent running the skill later has neither, and will 'simplify' a rule whose purpose it cannot see." Fix: apply ruling 2's reason-beside-the-rule requirement "to R1's token rule and to R1b" | the subject's citations; ruling 2 | **r6:** open. **r7:** "**released**": "The preamble requires the skill to give its reasons in prose." | r6 |

Also recorded, not raised as findings, from round 6:

- The author's measurement after round 6, recorded in the header: `list
  --critical` with and without `--milestone mine` printed the identical
  chain `o1→o2→o3` of milestone `other`, and the text output printed every
  short id as `01a17b5e`. See D12.
- `i26-arch`: R1b and 0002's start-up reclamation "are consistent and
  disjoint": "No assignment can satisfy both conditions." R1a's and R1c's
  ends are "two explicit exits", "provided the implementing text says R1c's
  exit takes precedence over R1a's 'pool empty' test". Growth: "I found no
  unattributed addition. The growth is answers, not new scope."
- `i26-evidence`: the guarded `--unassign` "is read-then-write with no
  atomicity. A reassignment that lands between the read and the `--unassign`
  is lost. It is the same class as git-zhi#35 and much rarer. I did not race
  it." Ordering: `urgency` is a string set only through frontmatter or a batch
  edit, and "'by urgency' needs an explicit rank map, because sorting the
  strings gives `high < low < normal`."
- `i26-pushback`'s growth check: two clauses cite no round-5 finding. The
  one-worker placement bullet cites round-4 ids, "benign". The `urgency` key
  "is an addition Q3 did not ask for, and no reason is given for it"; "Either
  drop it or give its reason." "The growth comes from the volume of round-5
  findings (21 rows), not from scope creep."
- `i26-pushback`'s probe: `list --critical` and `list --critical --milestone
  mB` in `probe26` "return every open issue in creation order … not the
  critical chain". "It does not refute" R1's claim.
- `i26-fresh`: `list --critical --milestone m1` printed m2's chain. "This
  looks like a git-zhi defect worth filing, but it is not a finding against
  #26."
- `i26-cold`: "These are two git-zhi defects. They fall outside this subject,
  and nobody has filed them": text `--critical` ignores `--milestone`, and
  `--format json` ignores `--critical`. `how-to-use-git-zhi`'s `list` row
  "implies the flags combine, which is false on 0.7.2". It looked for a pool
  issue `next` will not return (a blocker in another milestone) and found the
  pool `[]`: "I found no case." "r6 is longer, but no larger in scope than
  r4."
- `i26-cold2`: "R1c overrides R1a's 'on each return, run R1 again' for the
  refusing worker's own return, which is the right precedence. One cosmetic
  point: the order in the text is R1a, R1c, R1b." Each pass condition is
  script-checkable, and the walkthrough still fails while either symptom
  persists.
- `i26-cold3`: "R1b's token-conditional `--unassign` is mechanical, but it is
  the minimum that makes 0002's 'never touched' rule checkable."
- `i26-cold4`, out of scope: `skills/onboard/procedure.md:197` shows `git zhi
  next --actor "agent:claude"`, "the split-identity form 0002 and
  `how-to-use-git-zhi` say never to use"; R5 does not reach it. On altitude:
  "It is a behavioural spec … What is wrong is the form, not the altitude
  (W9)."

### Round-7 findings

Each row is as its raiser wrote it; none is merged with another. Overlaps are
marked "cf.". The bar-or-nit column is the status cell, in the raiser's words.

| id | raiser | round | section of the subject | consequence if it ships | evidence | status | revision |
|---|---|---|---|---|---|---|---|
| A19 | i26-arch | 7 | R1, ruling 3 ("an agent told to continue mid-issue resumes the issue it already holds, under that issue's own token, before it picks anything new (F21)"); R3 ("r3's resume branch … gone: … unreachable with one token per issue (F15, C7)" and "On a lost or refused start, the worker stands down") | an agent resuming under its issue's token runs bare `next`, which returns its own in-progress issue; R3 has it start, which is refused; R3 makes it stand down, and R1b clears the assignment. "The issue stays in progress under the token, out of the pool, and no other token can get it back." On the one-worker path R1c ends the run, "with an issue the agent was told to continue left stranded." "This is the A10 failure, and A15 recorded it for #27's re-dispatch-under-token case. Ruling 3 makes it reachable inside #26." Fix: "restore r3's R5 bullet 1 in R3: 'If `next` returned the worker's own in-progress issue, it does not start it again.' Delete the claim that the branch is unreachable." cf. P26, F22, C20, K16, W10, V2, A10, A15; see D4, D15 | `headForActor` step 1; `cannot start: issue is in-progress` (round-2 C2, D4, observed on 0.7.2). No new commands this round | **r7:** open. "This is a bar, not a nit, because it is a direct contradiction between two clauses of r7 on a path the subject itself now keeps." "I will release it on that sentence." **r8:** "**released**". "That is the requirement I asked for." "Bias note: this is my own bar, met by name." It holds nothing "as either a bar or a residual". | r7 |
| P26 | i26-pushback | 7 | R1, ruling 3; R3's bullets ("It starts its issue … On a lost or refused start, the worker stands down and returns") and note ("r3's resume branch … gone: the first is unreachable with one token per issue (F15, C7)"); R1b | an implementer follows R3's note and writes no resume handling. The resuming agent's `next` returns its own in-progress issue, "0002 tier 1, and it is also 'its own assignment' under R2" (D2); its start is refused (D4); it stands down; R1b clears. "The issue now sits in progress under its token, unassigned and outside the pool. This is F3's stranded shape, the outcome ruling 3 adopted self-resume to prevent." A10's release "has rested since round 4 on the branch being unreachable". Fix: one sentence in R3, and strike "unreachable": "On self-resume, the worker does not start again; it owns the issue if it is in progress with itself as the latest actor." A walkthrough case would make it testable. "Would change my mind: if ruling 3's self-resume is meant to bypass R2 and R3 entirely … The subject then needs to say that instead, which is the same one sentence pointing the other way." cf. A19, F22, C20, K16, W10, V2, A10; see D4, D15 | D4 (`cannot start: issue is in-progress … exit 1`, measured), D2, the text. "No walkthrough run" | **r7:** open; "contradiction, medium; **the one hold**". "Why this is a bar and not a nit: the subject's own text tells the implementer to omit the handling, and the failure is silent stranding, not an error." **r8:** "**released**". "The path I traced is closed: own issue, then `start`, refused, stand-down, `--unassign`, stranded." "One factual qualifier is recorded as residual P28 below. It does not change the rule, only the reason given for it." | r7 |
| P27 | i26-pushback | 7 | Acceptance, "a worker whose token was used before, so that a reopened issue is reachable (E20)", with "each worker worked the issue assigned to it" and R1's "Every pick … uses a fresh `<n>`" | "following R1, no token is ever reused, so the case cannot be constructed without breaking R1." If the walkthrough reuses a token anyway, the worker works the reopened issue and the run fails "each worker worked the issue assigned to it". "That makes it a negative control, and it belongs with 'Run without R1 to R3 … fails', not in the passing set." Fix: move it to the negative-control bullet. cf. E20; see D16 | E20's r39 run, "taken as given"; the text | **r7:** "(nit)". "The implementing issue can carry this. It is not a bar." **r8:** "**released, as a residual carried by the binding section**". "The body's Acceptance still lists that case among what the passing walkthrough 'covers' (L186–187). The binding section overrides it, and the implementing issue must follow the binding line. Editing L186 to match would remove the contradiction. That is a nit and not a bar." cf. K17, Z4; see D16 | r7 |
| F22 | i26-fresh | 7 | R1, ruling 3's self-resume sentence, against R3 (the bullet "On a lost or refused start, the worker stands down" and the line "r3's resume branch ... [is] gone: ... unreachable with one token per issue") | "the subject does not say how an agent 'resumes' an issue it holds. The two literal readings both go wrong": through the pick path, `next` returns the issue, `start` is refused, and R3 stands the agent down from its own issue; by name, `--state resume` is also refused. On the one-worker path the agent then picks a fresh token and a new issue, and "The held issue is stranded under the old token and keeps its WIP slot". R3's "unreachable" sentence "is also now false of the subject". Fix: "Self-resume runs no transition. The agent returns to Step 3 on the held issue under its token, and never calls `start` or `--state resume`"; R3's "gone" line reads "...except self-resume, which skips the start". Optional walkthrough case. cf. A19, P26, C20, K16, W10, V2, F21; see D15 | probe in `scratch-fresh/`: A in progress, latest transition `agent:r-9`; as `agent:r-9`, `--state resume` refused (`cannot resume: a measurement session is already open`), `--state start` refused (`cannot start: issue is in-progress, expected pending or reopened`), bare `next` returned A. 0002; D4 | **r7:** open. "I treat it as a bar to shipping the text unchanged, though it needs one sentence, not a revision of the design. If the coordinator records F22's sentence as binding on the implementing issue, I would accept on that basis instead." **r8:** "**Released.**" "Both halves of F22 are answered." "I hold nothing as a bar against #26." | r7 |
| C20 | i26-cold | 7 | R1, ruling 3 ("resumes the issue it already holds, under that issue's own token, before it picks anything new"); R3 ("The worker starts its issue by its literal id … On a lost or refused start, the worker stands down"); R3's closing line, "unreachable with one token per issue" | under its own token, `next` returns the in-progress issue, still assigned to that token, "so R2 is satisfied". R3's start is refused (D4), and R3 says stand down. "R1b does not apply (the worker owns the issue). R1c does not apply (the issue is not pending). The issue is left in progress and assigned. The run moves on and never finishes it." "The one path ruling 3 adds is the one R3 breaks." Fix: "When `next` returns the worker's own in-progress issue (self-resume), it does not start it; it goes straight to the ownership read." Then delete "unreachable". cf. A19, P26, F22, K16, W10, V2; see D15 | D4: `cannot start: issue is in-progress`; "The diff shows the self-resume clause added and the 'unreachable' sentence kept" | **r7:** open. "A bar, one sentence." **r8:** "**released**". "This closes the self-resume stand-down I raised". | r7 |
| C21 | i26-cold | 7 | R1, Order ("as `list --critical` reports it"); Out of scope ("workers read issue IDs from JSON output, never from text") | "an implementer following r7 literally takes JSON and gets 'the chain' as every issue in creation order. The skill would then claim chain priority it does not deliver, and no check would notice. Taking the text output instead means matching short IDs, which collide, or titles, which are not unique." "the order degrades but correctness does not … Even so, execute.md would state something false about its own behaviour." Fix, either: "the order is read from `list --critical`'s text output, matched to the pool by full ID prefix where unambiguous, else by creation order", or record that on 0.7.2 the JSON form ignores `--critical`, "so ruling 4 falls back to creation order until git-zhi fixes it". File the JSON defect next to git-zhi#37. cf. D12, A18; see D14 | measured on 0.7.2 in `scratch-cold/r6b/` (`other` holds o1→o4): `git zhi list --critical --format json` "ignores `--critical`. It returns all nine issues in creation order (`["a","b","c","d","o1",…,"o5"]`)". The text output shows the chain o1→o4, and "all six shown were `01a17b5d`" | **r7:** open. "A bar for the skill's truthfulness, one sentence." The author's measurement, and `i26-pushback`'s and `i26-evidence`'s probes, report a `critical_chain` key in that JSON; see D14. C21 stands as its raiser declared it, and only `i26-cold` may release it **r8:** "**released**". "The premise was my error". "In round 7 I read only `.issues` and concluded that JSON ignores `--critical`. That was wrong." "The author and i26-pushback were right. There is no git-zhi defect to file for the JSON form." "The `--milestone` being ignored, which I also measured, still holds, and r8 states it." See D14 | r7 |
| K16 | i26-cold2 | 7 | R1's ruling 3 clause ("lines 74-76") against R3 ("lines 137-140") | R3 still says the resume branch is "unreachable with one token per issue"; "Ruling 3 makes that branch reachable on purpose." "the skill gives no verb for resuming, and both of the obvious ones fail": through the pick protocol, `next` returns the held issue, "its own assignment" (O14), and R3's start gets rc 1 (O15); by name, `--state resume` gets rc 1 (O16). If it ships, the agent "stands down on its own work. R1b then clears the assignment. Because the issue is in progress, it is not in R1's pool and R1c does not hold it. The run goes on and ends with that issue in progress and unowned, so the milestone cannot complete." This is on "the 'continue' path, which Loop control makes routine". Fix: "self-resume makes no transition: under the issue's token it confirms with `next` that the issue is its own in-progress one, then continues at Step 3, skipping R3"; strike or reword R3's "unreachable" clause. "this is A15's concern … now inside #26". cf. A19, P26, F22, C20, W10, V2, A15; see D15 | O14 to O16 in `scratch-cold2/`, as `agent:r-1` on m2 (in progress, last transition and assignment `agent:r-1`): `next` returns m2; start `cannot start: issue is in-progress, expected pending or reopened`, rc 1; resume `cannot resume: a measurement session is already open`, rc 1 | **r7:** open. "This is a bar, but a one-sentence fix." **r8:** "**released**". "This is the fix I asked for." | r7 |
| Q11 | i26-cold3 | 7 | R1, "Order", lines 82–86 | r7 says the order "recovers `next`'s order only when the run's milestone holds that chain". By A18's and W2's reading, `next` ranks "first on the whole-graph critical chain, otherwise UUID order", "the same rule r7 applies to the milestone's pool. So among milestone issues, r7's order matches `next`'s whether or not the milestone holds the chain." What is lost "is a *milestone-scoped* critical order, and `next` never had one." "the skill would carry a slightly understated claim about git-zhi, the kind of claim A18 objected to. Scheduling is unaffected." Fix, for the implementing issue: "phrase the recorded cost against a milestone-scoped critical chain, not against `next`." cf. A18, W2, Q3, V4 | A18's and W2's reading of `headForActor`; ran nothing new | **r7:** "A nit the implementing issue can carry. It does not bar shipping, and I do not hold it." **r8:** "**released**". "r8's cost sentence says what I asked". | r7 |
| W10 | i26-cold4 | 7 | R1, ruling 3's sentence "resumes the issue it already holds, under that issue's own token"; R3's bullets; R3's closing paragraph, "unreachable with one token per issue" | under the issue's own token, bare `next` returns the in-progress issue and R2 calls it "its own assignment"; R3's start is refused; R3 says stand down; "R1b then clears the assignment, because it still carries the token. The issue is left in progress, unassigned and held by nobody live." "R1c does not fire, because the issue is not pending. On the one-worker path the agent goes on to pick a new issue." "The walkthrough has no resume case, so nothing would go red." Fix: "Resuming skips R2 and R3: it does not start the issue again, and continues at Step 3 under the issue's token." R3's "unreachable" becomes "replaced by ruling 3's self-resume". "Optional nit, also carriable": "an agent **told to continue**" is narrower than W3's case, an agent "re-entering the per-pick step on its own, after compaction or the max-iteration valve"; state self-resume "as a check at the per-pick step, made before minting a token". cf. A19, P26, F22, C20, K16, V2, W3; see D15 | `scratch-cold4/`, token `agent:r7-1`: `next` returned `b1 in-progress agent:r7-1`; start `cannot start: issue is in-progress, expected pending or reopened`, exit 1 | **r7:** open. "*Severity:* low-medium." "**Not held.** I would rather it went into r7 than be left to the implementing issue, because it reconciles two clauses of the subject rather than adding a rule." **r8:** "**released**". "'Self-resume runs no transition' is the sentence I asked for." | r7 |
| V1 | i26-cold5 | 7 | R1c, R2, and Loop control's "a tool refused the action" stop | R2 sends every non-assignment result back as a stand-down, "including `no actionable issues`. That covers an error exit too. R1c's pause covers only a *refused start*. So a `next` that fails the same way every time makes R1b → R1a → R1 re-dispatch with a fresh token forever." Causes: "a malformed token that `ZHI_ACTOR` refuses, or an unreadable chain." R1c's Loop control stop "changes to match" without saying how; "R3's 'a failed read is retried' has no bound either." Fix in the issue: keep the refusal stop "for any `git zhi` error other than a refused or lost start", or "apply R1c's 'no re-dispatch until a live worker returns' to every stand-down"; bound R3's retry. cf. W4 | R2's text; R1c's stated trigger ("because its start was refused") | **r7:** "(nit)". One of the two "worth writing into that issue explicitly" **r8:** "**released**". "Both of V1's fixes landed." | r7 |
| V2 | i26-cold5 | 7 | R1, the ruling 3 bullet | "What a single token would have given instead is self-resume …" "can be read as the forgone benefit or as a requirement. No acceptance item exercises it." If skipped, a one-worker agent told to "continue" mints a fresh token and picks again while its issue is in progress: under `wip_limit` 1 a refused start ends the run under R1c; "Without a limit, the old issue is stranded." Fix in the issue: "state it as a rule. Before minting, check for an in-progress milestone issue whose last transition's actor carries this run's token, and resume it under that token. Add one walkthrough case for it." cf. A19, P26, F22, C20, K16, W10, F21; see D15 | the text | **r7:** "(nit)". One of the two "worth writing into that issue explicitly" **r8:** "**released**, one residual". "Residual: add a walkthrough case where an agent continues mid-issue under that issue's token and runs no transition." | r7 |
| V3 | i26-cold5 | 7 | R1, together with the F9 deferral | "`list --ready --milestone <m> --format json` has no `assigned` field and no `created` field. Filtering on assignment and ordering by creation both need the full `list --milestone <m> --format json`, joined by id." "`assigned` is omitted when empty, so 'no assignment' means the key is absent." Name the join in the implementing issue. cf. F9, E11 | `readySetIssueJSON` in `chain_list.go`; `Assigned ... json:"assigned,omitempty"` in `issue.go`; observed: `list --ready --format json` carries only `id`, `title`, `paths` | **r7:** "(nit)" **r8:** "**released**, one residual". Its own correction: "My premise was wrong: `issue list --ready` carries `assigned` and `created` (observed above)." "V3's 'needs a join' was true of the wrong command." "Residual: name `issue list`, not `list`, in the issue, because the rule applied to `list --ready` would dispatch human-assigned issues." | r7 |
| V4 | i26-cold5 | 7 | R1, Order | "`ReadySet` sorts by UUID (`sortIssues`). Issue ids are UUIDv7, so that approximates creation order, but the `created` field is the honest key." "'In that chain's order' is unambiguous only because `critical_chain` lists issues upstream first (observed `b1,b2,b3`). Say so, so the implementer does not reverse it." cf. Q11, C21 | `sortIssues`; observed on 0.7.2 | **r7:** "(nit)" **r8:** "**released**". "All stated." | r7 |
| V5 | i26-cold5 | 7 | R5, Where it goes | "`docs/ARCHITECTURE.md:223` says 'without an exported identity they all resolve to the same actor'. The sentence is not falsified … But it is the same wording R5 corrects in `postmortem.md`, in the document CLAUDE.md imports." `how-to-use-git-zhi`'s "with the variable exported" and "With nothing exported" lines "should go with the example". "Either add the ARCHITECTURE line, doc-first, or record that it stays true. `crochet:review` reads CLAUDE.md's imports on every diff and will raise it otherwise." cf. Q8, C9, K6 | `docs/ARCHITECTURE.md:223`; `how-to-use-git-zhi.md`'s `ZHI_ACTOR` section | **r7:** "(nit)" **r8:** "**released**". "ARCHITECTURE.md is in R5 and Where it goes, doc-first." | r7 |
| V6 | i26-cold5 | 7 | Out of scope | "`--step` is listed under #27. But it runs through the same Step 2, so it gets R1's per-pick assignment and fresh token automatically. That is harmless, and probably intended." One line in the issue, "`--step` confirms before R1's pick; selection is unchanged", "prevents an implementer from excluding it." cf. C11 | the text | **r7:** "(nit)" **r8:** "**released**, one residual". "Residual: one clause in Out of scope, '`--step`'s selection is R1's; only its lifecycle is #27's', mirroring the one-worker sentence." cf. P30, K19, Z5 | r7 |

Also recorded, not raised as findings, from round 7:

- **The author's measurement, bearing on C21.** On 0.7.2, `git zhi list
  --critical --format json` returns an object with keys `critical_chain`,
  `current_constraint`, `issues` and `parallel_work`. `.critical_chain` held
  the chain `o1, o2, o3`; `.issues` held every issue in creation order. This is
  the author's, not a participant's finding. See D14.
- **The author's filing:** perigrin/git-zhi#37, 8-character short IDs collide,
  filed after round 6.
- **Human ruling 5**, given during round 7, recorded in the header.
- `i26-arch`, a nit "for the implementing issue": when R1a's end fires "with
  blocked issues remaining, Loop control's existing 'Then report once,
  covering everything' should name them. The current text arguably already
  requires this, so it is not a bar."
- `i26-evidence`'s nits for the implementing issue: on ruling 4,
  "`critical_chain` can be `null`; ties go by UUID; the chain can leave the
  milestone mid-run" (r42 to r45); and at R1a's normal end, "issues held by
  this run's own token, such as a reopened one, are not named. That is the
  reporting half of E16, already in #27." It calls its REUSE=0 run ending with
  m1 reopened "my model's artefact".
- `i26-pushback`: "**I correct my own r6 note here.**" Its round-6 reading of
  `list --critical` "came from reading the JSON's `issues` key. The chain is in
  `critical_chain`". The implementing issue "should therefore name the key",
  since an implementer reading `issues` "silently gets 'creation order only'";
  "a **nit, not a bar**". Its P20 residue is recorded in the P20 row.
- `i26-pushback`'s growth check: every added clause is anchored except "Short
  IDs colliding … Until that is fixed, workers read issue IDs from JSON output,
  never from text", which has "No finding and no ruling" and is "a requirement
  on workers placed under Out of scope". "Either give it a ledger id and move
  the worker rule into R3, or leave it as a nit for the implementing issue. Not
  a bar." `i26-cold4`: "Moving it to R3 is a nit." `i26-fresh`: "I do not
  object to it." `i26-cold2`: it "carries content the skill needs".
- `i26-cold2`, a nit: the reused-token acceptance case "deliberately violates
  R1, to show that R2's guard holds. A correct worker there stands down, which
  passes vacuously. The implementing issue should assert the stand-down
  explicitly." See D16.
- `i26-cold3`, "Observation, no row": R3's "resume branch … is gone" and ruling
  3's self-resume "concern different points: one is the resume branch inside
  R3's post-start check, the other is re-entry on 'continue'. When the skill
  states both, it should keep them visibly separate. This is wording for the
  implementing issue." See D15.
- `i26-cold4`, under W4's release: the orchestrator "can tell [the return
  outcomes] apart from the chain alone: done; in progress under its own token
  (owned); in progress under another actor (lost); still pending (anything
  else)."
- `i26-cold5`: "I found no contradiction that an implementer cannot resolve
  from the text, and no rule that cannot be followed." It records its checks:
  R1a and R1c's ends "are a union, not a conflict"; R2's stand-down cannot
  loop except in V1's case; the single path's fresh token per issue against
  0002's "identity fixed for the life of a worker", "nothing is stranded";
  and R1's use of the ready query against 0002's "that query is wrong".

### Round-8 findings

Each row is as its raiser wrote it; none is merged with another. Overlaps are
marked "cf.". The status cell gives the raiser's bar-or-residual declaration in
its words. Every round-8 row is declared a residual; none is declared a bar.

| id | raiser | round | section of the subject | consequence if it ships | evidence | status | revision |
|---|---|---|---|---|---|---|---|
| E21 | i26-evidence | 8 | R1, "Self-resume runs no transition", and its sentence that on 0.7.2 "both `start` and `--state resume` are refused" on one's own in-progress issue | that sentence "holds only while the session is open". After a pause, `next` under the own token still returns the issue. r8's rule (no transition), then a commit and `done`, "succeeds, but measures **1 commit in 1 window**. w2 is not measured"; with `--state resume` first, "**2 commits in 2 windows**"; with all work after the pause and no transition, `done` gives `cannot mark done: session has 0 commits (use --force to override)`. Fix, "For the implementing issue: when self-resume finds the session closed, run `--state resume`. Equivalently, the subject's sentence should read 'refused while a session is open'." It adds that this qualifier "is a sentence in R1 rather than in the binding section". cf. P28; see D15 | r46: under `agent:run-1`, `next` returned `m1 in-progress assigned=agent:run-1`, start and resume refused, r8's rule then `done` with actors `[run-1, run-1]` and "The assignment is kept"; the bracket (R2, R3, R1b) left m3 `{"state":"in-progress","assigned":null,"actor":"agent:run-3"}`, absent from the pool, "**The issue is stranded.**" r47 to r49 for the paused cases. `grep` finds no `--state pause` or `--state resume` in `skills/` | **r8:** "**held as a residual**". "crochet never pauses an issue … So the state arises only if a human or an outside tool paused it." "a paused own issue needs `--state resume`. crochet never pauses, so it is not a bar" | r8 |
| P28 | i26-pushback | 8 | R1, "Self-resume runs no transition … On 0.7.2 both `start` and `--state resume` are refused on one's own in-progress issue" | "suppose an issue was paused from outside the run (a human's `--state pause`) and the agent then self-resumes. With no transition run, no measurement session is open. Its later Step 3.5 `--state done` is refused (`session has 0 commits`, measured). The agent then either stalls or reaches for `--force`." Fix: "say that self-resume runs `--state resume` when the issue's session is closed, and correct the sentence to 'refused while a session is open'." cf. E21; see D15 | `probe26r7`: with the session open, resume `cannot resume: a measurement session is already open` and start refused; after `--state pause` by the same actor, resume succeeds and `next` still returns the issue; paused, a commit, then `done` refused. "P28's 'outside pause' trigger was reasoned from `grep`. I did not check whether a harness interrupt ever pauses an issue." | **r8:** "(residual)". "no crochet skill pauses an issue, so the case needs an outside actor. The failure is loud (a refused `done`), not silent stranding. Session telemetry is lifecycle, which belongs to #27." | r8 |
| P29 | i26-pushback | 8 | R3, "A failed read is retried, and never counts as won or lost", with the binding line "R3's retry of a failed read is bounded (V1)" | "at the bound, an implementer has to pick an outcome. If the worker stands down and returns, R1b then `--unassign`s an issue the worker may in fact hold. That issue is left in progress, unassigned and outside the pool, which is F3's stranded shape." Fix: "state that exhausting the retries ends the worker's attempt as *unknown*, reported by name, without R1b's unassign. Whatever outcome it picks, it must not count as lost." cf. K18, Z3, V1; see D17 | the text; read failures "2 in 15 under a racing write (E12) and 0 in 110 in controls" | **r8:** "(residual)". "reaching the bound is rare." | r8 |
| P30 | i26-pushback | 8 | Out of scope ("the `--step` path. These are perigrin/crochet#27"), against the binding line "`--step` goes through R1's pick like every other path" | "The one-worker path has an explicit carve-out ('*selection* is in R1; only its lifecycle questions stay in #27'), and `--step` lacks one." Fix: "give `--step` the same carve-out as the one-worker path: '`--step`'s selection is R1's; its confirmation semantics stay in #27.'" cf. K19, Z5, V6 | the text | **r8:** "(residual, wording)" | r8 |
| K17 | i26-cold2 | 8 | Acceptance's "a worker whose token was used before", listed under "It passes if", against the binding lines "is a negative control, which must fail (P27)" and "the reused-token stand-down is an explicit assertion" | "Both are true, of different runs": with R2 in force "the worker stands down. The assertion holds, and the walkthrough passes"; with R2's guard removed, "each worker worked the issue assigned to it" goes red, "That is the negative control." "an implementer reading the lines literally either drops the assertion or makes the main run red." Fix, "which the implementing issue can carry": "under R2 the reused-token worker stands down (asserted); the same case with R2's guard off must fail." cf. P27, Z4; see D16 | the text | **r8:** "(residual)". "K17 is the one I would most want fixed in wording before implementation starts, because it is the only place where the binding section, read literally, tells the implementer to make the walkthrough red." | r8 |
| K18 | i26-cold2 | 8 | the binding line bounding R3's retry, against the body's "never counts as won or lost" | "when the bound is exhausted, something must happen. The safe reading is 'unknown: stand down, and leave the assignment alone'. R1b clears an assignment only for a worker that does not own its issue, and an unknown read does not show that." cf. P29, Z3, V1; see D17 | the text | **r8:** "(residual)". "The implementing issue can carry this, but it should state the outcome." | r8 |
| K19 | i26-cold2 | 8 | the binding line "`--step` goes through R1's pick like every other path", against Out of scope's "the `--step` path" under #27 | "the contradiction is only on paper, because `--step` adds a confirmation and uses whichever branch it runs on." Fix: "extend the Out-of-scope sentence the one-worker path already has to cover `--step`." cf. P30, Z5, V6 | the text | **r8:** "(residual)". "K19 could instead be a one-word fix in Out of scope." | r8 |
| Z1 | i26-cold6 | 8 | R1c, R3 and the Step 4 reopen | "a refused restart leaves the issue `reopened`, not `pending`." "R3 is written for 'the worker starts its issue'. It does not say that it also governs Step 4's `--state start`." "R1c triggers on 'its issue is still pending'. `reopened` is a different state noun." "an implementer may not apply stand-down, R1b's unassign or R1c's hold to this case. The worker would then carry on into Step 3 on an issue it does not hold." Fix: "say that R3 covers every `--state start`, Step 4's included. Read 'pending' in R1b and R1c as 'not in progress, that is pending or reopened'." | measured in `scratch-cold6/` with `wip_limit` 1: B done, an outside actor started X; B's `--state reopen` succeeded and its `--state start` was refused with `WIP limit reached`; "B is left `reopened`, still assigned to the worker's token, and in the ready set" | **r8:** "residual". "This is arguably lifecycle, which is #27's, but the wording is this subject's." | r8 |
| Z2 | i26-cold6 | 8 | R1a ("On each return the orchestrator runs R1 again") against R1c ("does not re-dispatch at once") | "R1c's heading makes it an exception, so the text can be read correctly. execute.md should still say that R1c takes precedence over R1a for that return. Otherwise a literal reading re-dispatches straight into the held slot, which is the loop R1c exists to prevent." | the text | **r8:** "residual" | r8 |
| Z3 | i26-cold6 | 8 | the binding item on R3's bounded retry (V1), against "never counts as won or lost" | "When the bound is reached, the worker therefore needs a third outcome. The natural one is Loop control's tool-failure stop: stop and report without standing down. A failed read says nothing about who owns the issue, so unassigning would be wrong." "The implementing issue should name that outcome, or the bound has no defined end." cf. P29, K18; see D17 | the text | **r8:** "residual" | r8 |
| Z4 | i26-cold6 | 8 | Binding, Walkthrough: "The reused-token case is a negative control, which must fail" (P27) beside "the reused-token stand-down is an explicit assertion" (i26-cold2) | "the two reused-token assertions point in opposite directions." "These can both hold, but only if the implementing issue says which check is which": "the negative control: `next` under a reused token returns the earlier reopened issue, not the assignment. This is expected to 'fail', as E20 shows"; "the passing assertion: under R2 the worker starts nothing and returns." "As written, an implementer could script the whole case to fail." cf. K17, P27; see D16 | the text | **r8:** "residual" | r8 |
| Z5 | i26-cold6 | 8 | Out of scope's "the `--step` path", against Binding's "`--step` goes through R1's pick" (V6) | "These can be reconciled. Out of scope opens with 'the worker lifecycle *after selection*', R1 says 'on every path', and the binding item agrees with R1. But a quick reader sees `--step` both out of scope and in scope." Fix: "Change the out-of-scope entry to '`--step`'s lifecycle after selection'." cf. P30, K19, V6 | the text | **r8:** "residual" | r8 |
| Z6 | i26-cold6 | 8 | R5 ("the `export ZHI_ACTOR` example") and Where it goes ("the `ZHI_ACTOR` example") | how-to-use line 135 holds the example; "Line 144 ('with the variable exported rather than `next --actor`') and line 156 ('With nothing exported') state the same model." "A narrow reading leaves two sentences that contradict R4." Fix: "R5 should name every 'exported' line in how-to-use, not only the example." It finds execute.md line 167 "covered under 'the `Otherwise` branch'". cf. V5, C9, K6 | `how-to-use-git-zhi.md` lines 135, 144 and 156, found by its search for `export`/`exported` | **r8:** "residual" | r8 |
| Z7 | i26-cold6 | 8 | R1's opening sentence ("Before any worker calls `next`, the agent that orchestrates [assigns]") and the self-resume bullet | "Self-resume calls `next` with no new assignment. The bullet carves this out … execute.md should still put the exception beside the rule, not two bullets later." Also "execute.md should also say where the issue's token comes from: the conversation. A fresh invocation mints a new `<run-id>`. Its reclamation then clears the old token's assignment." "Self-resume is therefore within one run only, and a prior run's in-progress issue remains #27's dead-worker case. Today's 'idempotent' Key Constraint should not be read as promising more." cf. V2, W10, F3; see D15 | `headForActor` step 1 in git-zhi's `graph.go`; the text | **r8:** "residual" | r8 |
| Z8 | i26-cold6 | 8 | R1's ruling-3 sentence, against 0002's "Identity is fixed for the life of a worker" | "A reader of execute.md who sees the single worker change token per issue may take that as a breach." "Under R1 the token changes only between issues, never while one is held, and self-resume keeps the token mid-issue. So the rule's reason is respected. The ruling-3 sentence in execute.md should say so, so the per-pick token does not read as a breach of 0002." cf. W3, F21; see D10, D13 | 0002's text: "a worker that renames itself mid-run fails `headForActor` step 1 against its own in-progress issue" | **r8:** "residual" | r8 |

Also recorded, not raised as rows, from round 8:

- **Residuals named without an id.**
  - `i26-fresh`, on `--step`: "One mild tension, which is a residual and not
    a bar." "The implementing issue can carry the same one-line carve-out for
    `--step`." cf. P30, K19, Z5, V6.
  - `i26-cold3`, on R3's bounded retry: "If the implementer treats it as a
    stand-down, R1b clears the assignment on an issue the worker may own,
    which strands the issue the way D15 did. The safe answer is to stop and
    report the issue, which is Loop control's 'a tool refused' stop.
    **Residual** for the implementing issue." cf. P29, K18, Z3; see D17.
  - `i26-cold3`, on `--step`: "consistent only if it is read like the
    one-worker split, with selection here and lifecycle in #27. Wording;
    **residual**."
  - `i26-cold3`, on R1c's widening: "A human can assign the picked issue to
    themselves in the window between R1's assignment and the worker's `next`.
    On the one-worker path that ends the run and reports the pool, rather than
    carrying on with the other issues. That is a safe stop with a report, not
    a hang, and the window is tiny. **Residual**, not raised as a row."
  - `i26-cold4`, on `--step`: "One wording tension, a residual." "Adding
    'only its lifecycle' to the `--step` item in Out of scope would remove the
    tension. The implementing issue can carry this."
  - `i26-cold4`, on R3's bounded retry: "One edge, a residual for the
    implementing issue or #27." "the worker's start succeeded, every re-read
    fails, and it stands down. R1b then sees an assignment that still carries
    the worker's token and clears it, leaving an owned in-progress issue
    unassigned and unworked." "The fix is for the stand-down at the bound to
    report the issue rather than release it." See D17.
- **Nits, not held.**
  - `i26-arch`, on `--step`: "One tension, and I judge it a nit, not a
    contradiction." "The implementing issue can carry the one-word
    clarification." It holds nothing "as either a bar or a residual".
  - `i26-cold`, on `--step`: "A nit, not a bar." It holds nothing "as a bar
    or as a residual".
  - `i26-pushback`, on `i26-cold2`'s explicit-assertion line: "I could not
    tell which stand-down this means. Under R2, a reused token's `next`
    returns a reopened issue that is still assigned to that token (E20, D2),
    so R2 produces no stand-down." "The implementing issue should say which.
    This is a nit, not raised as a row." See D16.
  - `i26-cold2`, on R1c's widening: "That is stricter than it needs to be: a
    fresh-token re-dispatch would usually succeed. But it cannot loop or hang,
    and it reports what is left. I accept it as it stands."
- **Releases of round-7 nits that carried no row.** `i26-arch`: its
  end-of-run report nit "— released": "That is the right home." `i26-cold2`:
  its explicit-assertion nit "**released, as moved**", adding "It does
  conflict with the line above it, though; see K17."
- **`i26-evidence`'s record correction** to its round-7 tie nit, which the
  binding section records as "ties between equal `created` values go by UUID":
  "**misrecorded; please correct**". What it raised (r43): "when two
  milestones hold **equal-length chains**, `list --critical` picks the one
  with the lower UUID root, so a milestone whose equal-length chain was
  created later does not 'hold the chain'. Ties on `created` cannot really
  occur for creation order, because the UUIDs are v7 and sort in creation
  order." Its correction: "an equal-length chain in another milestone wins by
  UUID, so 'holds the chain' is false for the later one". It confirms its
  other binding items as recorded. See D12.
- `i26-pushback`'s growth check: "**I found no clause citing neither a
  round-7 finding nor a ruling.**"
- `i26-evidence`, not measured: "a decline that leaves its issue pending. The
  candidate is an assignment whose blocker was reopened between assignment and
  `next`; that issue is not in the pool, so R1c's report would name only the
  rest of the pool."

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
  - **Round 4.** No party says D1 is resolved in its own round-4 report except
    `i26-fresh`, which repeats "D1, which was resolved for me at r3".
    - `i26-arch`: R3 "is correctly described as narrowing, not closing (D1)".
    - `i26-evidence`: in 20 forced races, R3's settled check left no worker
      working an issue whose final owner was the intruder; with the check off,
      w3 worked in 20/20. "The 8/12 split is not a rate", and "The 0.5 s pause
      may not be enough on a large chain."
    - `i26-pushback` and `i26-cold` did not re-examine the race.
    - `i26-cold2` (K10) relied on git-zhi#35's measurements; see D7.
  - **Round 5. Not resolved.** No party addresses D1 in its round-5 report
    beyond the following.
    - `i26-cold` (C6, wording residue): R3's "This narrows git-zhi#35's window"
      is compatible with "R1 and R2 already rule out a shared pick" "only if
      the reader knows #35 is reachable here solely from outside the run.
      That is cosmetic, and I do not hold it".
    - `i26-evidence`: steal outcomes "depend on scheduling (3 losses in 8
      repeats, plus 1 in the first run)"; "the 0.5 s pause is generous here".
  - **Round 6. Not resolved.** No party addresses D1 beyond the following.
    - `i26-cold` (C6): the "narrows #35's window" residue "is unchanged and
      still cosmetic".
    - `i26-evidence`: "steal outcomes depend on it (lost in 4 of 5 runs)".
    - `i26-cold4` (W6), not a party before round 6: if a worker cannot sleep
      in its harness, an immediate re-read "narrows nothing in git-zhi#35's
      window, while it believes it waited".
  - **Round 7. Not resolved.** r7's R3 adds: "The wait uses a mechanism the
    harness permits … Which mechanism is for the implementing issue." It keeps
    "This narrows git-zhi#35's window and does not close it (F4, D1)". No party
    says D1 is resolved.
    - `i26-cold4` (W6): "**released**": "R3 requires a wait the harness
      permits, and leaves the choice to the implementer. That was my fix."
    - `i26-evidence`: in 10 extra `steal` runs, "The lost start occurred in 6
      … and the intruder lost in 4". "My model uses `sleep` in a subshell."
    - `i26-arch`, `i26-cold`, `i26-cold2`, `i26-cold3` and `i26-fresh` list
      R3's wait mechanism, or the concurrency measurements, as not
      re-examined.
  - **Round 8. Not resolved.** No party says D1 is resolved, and none
    re-ran the concurrent-start race beyond `i26-evidence`'s `walk7.sh`, whose
    CAP=2 `steal` case is "PASS 3/3". `i26-cold`, `i26-cold3`, `i26-cold5` and
    `i26-cold6` say they did not re-run the concurrent starts.
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
  - **Round 4.** r4 states "D3 is answered in R2." Not every party says D3 is
    resolved in its own report.
    - `i26-arch`: "A4 / D3 — still released." R2 "is 0002 'Assignment is a
      hint': 'it assigns to steer'".
    - `i26-pushback`: P1 stands; "R2 answers D3 in so many words".
    - `i26-fresh`: no round-4 statement on D3.
    - `i26-cold`: does not name D3. It releases C7 ("`next` is kept, and its
      purpose is stated … That is what C7 asked for") and stands aside on C9's
      0002 half.
    - `i26-cold2`, not a party before round 4: "R1 is 0002 as written, more
      literally than today's execute.md is."
  - **Round 5. Not resolved.** `i26-arch`: "A3, A4 / D3 … still released",
    r5 "keeps bare `next`". `i26-pushback`: P1 stands, "Unchanged in
    substance". `i26-fresh` and `i26-cold` make no statement on D3.
    - `i26-cold3`, not a party before round 5: R1 and R2 "fit 0002 better than
      the current text does", but "0002 calls the ready-set query 'wrong'",
      and the skill should say why the objection no longer applies (Q8).
  - **Round 6. Not resolved.** r6 adds that R1 "uses it only for the
    orchestrator's choice, and filters assignees itself. The worker's
    selection remains `next` (Q8)".
    - `i26-arch`: "A4 / D3 — still released"; the Q8 sentence "is the reading
      of 0002 I gave in round 3".
    - `i26-pushback`: "Q8's sentence … reinforces P1's D3 answer."
    - `i26-cold3`: Q8 released.
    - `i26-cold` (C19): the sentence "credits 0002 with execute.md's words";
      it asks that the quote be 0002's own.
    - `i26-cold4`, not a party before round 6: W7, "no assignee filter" is
      stale on 0.7.2; W8, R2's `next` "is now a confirmation, not a
      selection", which "makes 0002's sentence nominal", and whether 0002
      deserves an amendment later is the human's decision.
  - **Round 7. Not resolved.** r7 records W8 "rather than changed": "Under R2,
    `next` hands over and confirms, rather than choosing … R2 keeps it because
    0002 names bare `next` as the worker's selection." It quotes 0002 as "has
    no assignee filter" and adds that `issue list --assigned` "cannot select
    unassigned issues". No party says D3 is resolved.
    - `i26-arch`: "A1, A3, A4/D3. Unchanged." The C19 and W7 changes "support
      the Q8 reading of 0002 rather than altering it."
    - `i26-pushback` (P1 stands): "That is the D3 reading I released on."
    - `i26-cold` (C19): "**released**": "0002 is now quoted exactly".
    - `i26-cold4`: W7 and W8 "**released**". W8: "Recorded as true, and kept
      for 0002's sake. That was all I asked."
    - `i26-cold5`, not a party before round 7: "0002 condemns the query as the
      *worker's* selection. R1 uses it only for the orchestrator's choice,
      which 0002 permits ('it assigns to steer'). The worker still selects
      with bare `next`."
  - **Round 8. Not resolved.** No party says D3 is resolved.
    - `i26-arch`: "All other rows, A1 to A18, stay released".
    - `i26-cold6`, not a party before round 8: R1 "uses it only for the
      orchestrator's choice, adds the filter itself, and keeps bare `next` as
      the worker's selection (R2). That follows the letter of 0002's 'select
      with bare `git zhi next`'. It also follows the reason 0002 gives." "R1
      restores one of 0002's premises": "an orchestrator is a single
      serialisation point with no race to solve".
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
  - **Round 4.** r4 removes the resume branch as "unreachable with one token
    per issue (F15, C7)". Not resolved: the parties do not all say so.
    - `i26-fresh`: F15 "released (on merits). The resume branch is gone from
      R3."
    - `i26-cold`: C7 released; C14, "R3's reason assumes one token per issue,
      but R1 to R5 never say so".
    - `i26-arch`: "Within r4 that is true", but #27's same-token fix "has to
      restore the resume branch" (A15).
    - `i26-pushback`: no round-4 statement on D4.
    - `i26-cold2` (K2), not a party before round 4: "the token scheme is
      unstated, and R3 relies on one that r4 does not establish."
  - **Round 5. Not resolved.** r5 adds "Each dispatch mints a fresh `<n>`, so
    a token is used for exactly one issue (C14, K2)".
    - `i26-arch` (A10): "Under fresh-token-per-dispatch, resume-own is still
      unreachable within #26."
    - `i26-cold` (C14 released for parallel dispatch; C16), `i26-cold2` (K2
      released; K11), `i26-pushback` (P23) and `i26-cold3` (Q1): the one-worker
      branch has no dispatch, so the rule does not reach it, and resume-own is
      reachable there under one token. See D10.
    - `i26-fresh`: one token across sequential issues "is also safe. After
      `done` the agent holds nothing in progress". See D10.
  - **Round 6. Not resolved.** r6 extends the fresh `<n>` to every pick on
    both paths. See D10 and D13.
    - `i26-arch`: "Fresh `<n>` on every pick, now on the one-worker path too,
      keeps tokens disjoint."
    - `i26-pushback` (P23 released): R3's "'unreachable with one token per
      issue' is now true on both paths".
    - `i26-evidence` (r39): a reused token whose earlier issue was reopened
      gets that issue from `next` in place of the pick (E20).
    - `i26-fresh` (F21), `i26-cold3` (Q1's note) and `i26-cold4` (W3): resume
      of an issue still in progress is lost, or must be stated, under a fresh
      token per pick.
  - **Round 7. Not resolved.** Ruling 3 keeps self-resume under the issue's
    own token, and r7's R3 keeps "the first is unreachable with one token per
    issue (F15, C7)". The fact is again not contested: an agent starting its
    own in-progress issue is refused, and `next` returns that issue to it
    (`i26-fresh`'s probe, `i26-cold2` O14 and O15, `i26-cold4` under W10;
    `i26-arch`, `i26-pushback` and `i26-cold` cite D4). `i26-fresh` and
    `i26-cold2` (O16) also observe `--state resume` refused on it.
    - `i26-arch`: "**A10/A15.** Reopened in substance by ruling 3; see A19."
    - `i26-pushback` (P26): A10's release "has rested since round 4 on the
      branch being unreachable". P23 "also stands under ruling 3":
      "Self-resume reuses a token only for the same issue."
    - `i26-fresh` (F22), `i26-cold` (C20), `i26-cold2` (K16) and `i26-cold4`
      (W10): R3's "unreachable" is now false of the subject.
    - `i26-cold3`: the two "concern different points". See D15.
    - `i26-cold2`: "The fresh-token-per-pick rule (K2, K11) survives ruling 3.
      Its exceptions, the Step 4 reopen and self-resume, keep one token per
      issue".
  - **Round 8. Not resolved.** r8 replaces R3's "unreachable" clause with
    R1's "Self-resume runs no transition", and R3 now reads "Resuming one's own
    in-progress issue does not pass through R3 at all" (quoted by
    `i26-fresh`). Each raiser of the six round-7 rows releases it (A19, P26,
    F22, C20, K16, W10). No party says D4 is resolved.
    - The fact is reconfirmed on 0.7.2 by `i26-evidence` (r46), `i26-pushback`
      (`probe26r7`), `i26-cold3` and `i26-cold6`: `start` refused, `--state
      resume` refused while the session is open, `next` returns the issue.
    - `i26-evidence` (E21) and `i26-pushback` (P28): after `--state pause`,
      `--state resume` succeeds. See D15.
    - `i26-cold3`: "A pick always uses a fresh token, which has nothing in
      progress, so self-resume cannot fire at a pick."
- **D5. Where "integrated" is read from (new in round 3). Not resolved.**
  - `i26-arch` (A14): "a fact read from git at dispatch time … never a flag the
    orchestrator remembers"; otherwise a dead run loses idempotency. "How it is
    read is the implementing issue's; that it is derivable is the subject's."
  - `i26-evidence` (E15): the git route gives a false "no" for squash and
    rebase merges; "The orchestrator's own record of what it integrated is the
    robust source." "Fine to leave to the implementing issue."
  - `i26-pushback` (P14): where "reviewed" is read from is implementation
    detail.
  - **Round 4.** Each party has released its finding as out of scope, in #27:
    A14, E15 and P14. No party says D5 is resolved. `i26-arch`: "The
    disagreement with E15 over which source is safer stays with #27."
  - **Round 5.** No party addresses D5. `i26-evidence`: E15 "released in
    round 4; unchanged".
  - **Round 6.** No party addresses D5.
  - **Round 7.** No party addresses D5. `i26-evidence`: E15 "still released"
    ("E1 to E18").
  - **Round 8.** No party addresses D5. `i26-evidence`: "E1 to E18 **still
    released**".
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
  - **Round 4: the human ruled** (ruling 2): "`ZHI_ACTOR` on every command is a
    harness detail within 0002's intent … 0002 is not amended. The skill states
    this reason where it gives the rule." Each participant's response:
    - `i26-arch` (A13 released): "I accept ruling 2." "The ruling fits the
      decision's text, not only its intent." It names what the ruling "makes
      less true": "re-exporting is the only way to break it, and the
      orchestrator owns the environment it dispatches into". "This does not
      falsify any commitment in 0002." It releases "on that understanding"
      that the orchestrator hands the worker the token as a literal, and notes
      its bias.
    - `i26-pushback` (P18 released): "answered by ruling 2". R4's stated reason
      "removes the reader-of-0002 hazard I raised."
    - `i26-cold` (C9): "**standing aside** on the 0002 half; **held** on the
      live-document half". Grounds: "its reading is defensible: 0002's reason,
      no differing identity on the read side, survives a per-command prefix."
      "The ruling on C9 went against me, so on that one my bias runs the other
      way."
    - `i26-fresh`: "Ruling 2 (D6). I have no objection. R4 matches what I asked
      for in F5."
    - `i26-evidence`: no statement on the ruling; its walkthrough sets
      `ZHI_ACTOR` on every `git zhi` command (R4).
    - `i26-cold2`: "Ruling 2 (R4) is settled, and I take it as given."
    - **Round 5.** `i26-cold`: C9's held half released; on the 0002 half,
      "**still standing aside**": "Ruling 2 stands, and its reading is
      defensible". `i26-arch`: A13 "still released". `i26-pushback`: "Ruling 2
      is unchanged." `i26-cold2`: K6 released. `i26-cold3` takes "the two
      human rulings as settled".
  - Not marked resolved: `i26-arch` and `i26-pushback` released on the ruling;
    `i26-cold` declared a standing-aside on the 0002 half, not a resolution.
    C9's live-document half is held (cf. K6).
  - **Round 6.** `i26-cold` releases C9's 0002 half: "**released** (until now
    I stood aside)". "The ruling stands, and R4 puts its reason beside the
    rule." "I no longer have grounds to keep the question open." `i26-arch`:
    A13 unchanged, released. `i26-pushback`: P18 stands.
    - `i26-cold4`, not a party before round 6: "Ruling 2 covers setting the
      same token on every command. It does not cover one agent switching to a
      new token for each issue on the one-worker path" (W3). See D13.
  - Not marked resolved: every raiser of A13, P18 and C9 has now released on
    the ruling, and none says in its own report that D6 is resolved.
  - **Round 7. Not resolved.** No party says D6 is resolved. `i26-arch`: A13
    among "All others stay released". `i26-pushback`: P18 stands ("P12–P18
    stand"). `i26-cold`: C9 "still hold[s]". `i26-cold4` releases W3 on ruling
    3; see D13.
    - `i26-cold5`, not a party before round 7: "Ruling 2's per-command identity
      is the environment mechanism 0002 names. Its rationale, same identity on
      the read and write sides, is preserved." V5 names
      `docs/ARCHITECTURE.md:223`'s "exported", which it says is "not
      falsified".
  - **Round 8. Not resolved.** No party says D6 is resolved.
    - `i26-arch`: V5's site "is consistent with ruling 2 and with my A13
      release".
    - `i26-cold5`: V5 "**released**".
    - `i26-cold6`, not a party before round 8: "Identity per command (ruling
      2) and a fresh token per pick (ruling 3). These are settled." It finds
      it removes a defect: "`export` does not survive between shell
      invocations in agent harnesses". Z6 asks that R5 name two further
      "exported" lines in `how-to-use-git-zhi.md`.
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
  - **Round 4. Not resolved.** `i26-cold` (C6): "My view stands: within a run,
    R1 leaves no second starter for an issue, so #35 can only come from outside
    the run … D7 is still open between participants." It stands aside on the
    settle.
    - `i26-cold2` (K10), new: R3 "defends a case R1 and R2 already exclude";
      "The remaining same-issue racers are concurrent runs and humans, both out
      of scope." "keep it, but say this".
    - `i26-evidence`: its forced race "uses a scripted intruder, not a second
      dispatched worker."
    - `i26-arch`: "R3 is defence in depth against git-zhi#35"; "The only route
      back to a shared issue is the one R2 already closes".
  - **Round 5. Not resolved.** r5 adds the paragraph "R3 stays, although R1
    and R2 already rule out a shared pick within one run (K10)".
    - `i26-cold` (C6): "**released**, standing aside ends". "The K10
      paragraph now says what I argued."
    - `i26-cold2` (K10): released. "R3 is not presented as the fix for #35."
    - `i26-evidence`: "K10 confirmed": no collision and no stand-down from R1
      and R2 alone in 8/8 runs; "R3 is reached only through `wip_limit` or an
      outside actor, as r5 says."
    - `i26-arch` makes no round-5 statement on D7, and no party says D7 is
      resolved.
  - **Round 6. Not resolved.** No party says D7 is resolved.
    - `i26-cold` (C6): "still released"; the wording residue "is unchanged
      and still cosmetic".
    - `i26-cold2` (K10): still holds.
    - `i26-evidence`: the lost start "stood down in 4 of 5 runs" of `steal`;
      r6's R3 paragraph cites its round-4 races.
  - **Round 7. Not resolved.** r7's K10 paragraph is unchanged. No party says
    D7 is resolved.
    - `i26-cold`: "C12–C16, C9 and C6 still hold."
    - `i26-cold2`: "K1 to K13 still hold against r7."
    - `i26-evidence`: in 10 extra `steal` runs the lost start "occurred in 6
      (`standdown rc=0 state=in-progress`, then `--unassign`, dispatched
      once), and the intruder lost in 4".
  - **Round 8. Not resolved.** No party addresses D7 or says it is resolved.
    `i26-cold2`: "K1 to K15 still hold against r8." `i26-cold` makes no
    declaration on C6.
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
  - **Round 4.** Ruling 1 moves the question to #27. Each of the five parties
    released its finding as out of scope, in #27 (A12, E14, P13, F3, C1). None
    says D8 is resolved; the disagreement on the repair is carried to #27.
    - `i26-arch` (A15): one of #27's two exits, re-dispatch under the dead
      token, needs the resume branch r4 removed.
    - `i26-evidence` (E14): "#27 must carry that".
    - `i26-fresh` (F3): "I still hold it live in #27."
  - **Round 5.** `i26-arch` releases A15: it is carried to #27 with the
    requirement that "a re-dispatched worker resume without a fresh `start`".
    No party says D8 is resolved.
  - **Round 6.** No party says D8 is resolved. `i26-fresh` (F3): "still in
    #27". Two new statements place a one-worker stranding outside #27's dead
    worker: `i26-fresh` (F21), "F3's shape on the single path"; `i26-cold4`
    (W3), "This is not #27's dead worker: the worker is alive and has
    abandoned its own work."
  - **Round 7.** No party says D8 is resolved. `i26-fresh`: F3 "still in #27".
    Six round-7 findings describe a live agent's own issue stranded through
    self-resume against R3 (A19, P26, F22, C20, K16, W10); `i26-pushback` calls
    it "F3's stranded shape", and `i26-arch` "the A10 failure, … A15 recorded
    it for #27's re-dispatch-under-token case". See D15.
  - **Round 8.** No party says D8 is resolved. `i26-fresh`: "F3, F11 to F14
    and F16 remain live in #27, and I hold them there." The six raisers of the
    self-resume stranding release their rows on r8's rule; see D15.
    - `i26-cold6` (Z7), not a party before round 8: "Self-resume is therefore
      within one run only, and a prior run's in-progress issue remains #27's
      dead-worker case."
    - `i26-pushback` (P29), `i26-cold2` (K18), `i26-cold3`, `i26-cold4` and
      `i26-cold6` (Z3) name a stranding reached through an exhausted retry;
      `i26-cold4` calls it "#27's stranded shape, reached through a persistent
      read failure". See D17.
- **D9. Whether a stood-down worker's leftover assignment belongs to #26 or to
  #27 (new in round 4). Not resolved.** The fact is not contested: after a
  stand-down the issue keeps its assignment and leaves R1's unassigned pool
  (P19, C12, K3; `i26-arch` under A6; `i26-fresh` under F3).
  - `i26-pushback` (P19): "this is P10 again", "selection bookkeeping"; "#27
    does not hold P19".
  - `i26-cold` (C12): "introduced by the fix, not inherited from the
    lifecycle"; "this is not #27".
  - `i26-cold2` (K3): "selection bookkeeping, not lifecycle, so it belongs in
    #26".
  - `i26-arch` (A6): "It does strand the issue, which is #27's to fix (items 2
    and 4)."
  - `i26-fresh` (F3): "That is the defect F3 names, it predates #26"; released
    to #27.
  - `i26-evidence`: "A stood-down worker's issue stays stranded (E14, in #27)."
  - **Round 5. Not resolved.** r5 places the give-back in #26 as R1b, and the
    started-and-lost case in #27 (E14).
    - `i26-arch` changes sides: "**R1b is right inside #26. I withdraw my
      round-4 placement in #27.**" "I conflated the two cases. Bias note: I am
      reversing my own position, not defending it."
    - `i26-pushback` (P19), `i26-cold` (C12) and `i26-cold2` (K3) release their
      findings on R1b.
    - `i26-fresh` makes no round-5 statement on F3's placement. Of the loop
      R1b closes it writes: "this reach belongs to #26, not #27" (F19).
    - `i26-evidence` makes no statement on D9. It measured that the lost case
      stays out of the pool, re-dispatched 0 of 3, and that "#27 owns" its
      re-dispatch (E18).
  - **Round 6. Not resolved.** r6 keeps R1b in #26 and adds the token guard.
    - `i26-pushback` (P19): "**stands, strengthened**". `i26-cold` (C12):
      "still released, and tighter". `i26-cold2` (K3): still holds.
    - `i26-arch`: R1b and start-up reclamation "are consistent and
      disjoint".
    - `i26-fresh`: R1b's lost case being #27's "is consistent with F3".
    - `i26-evidence`: lost starts were "dispatched only once", 4 of 4, as E18
      asked.
  - **Round 7. Not resolved.** No party says D9 is resolved.
    - `i26-pushback`: "P19/P10 … stand". `i26-cold`: "C12–C16 … still hold".
      `i26-cold2`: "K1 to K13 still hold".
    - `i26-arch`: "All others stay released on the grounds already recorded."
    - `i26-evidence`: "E18's split … held in all runs".
    - `i26-cold5`, not a party before round 7: R1b's stand-down unassign does
      not contradict 0002's Open Question, which "is not settled".
    - A19, P26, K16 and W10 say R1b clears a self-resuming agent's assignment;
      C20 says "R1b does not apply". See D15.
  - **Round 8. Not resolved.** No party says D9 is resolved.
    - `i26-cold6`, not a party before round 8: "R1b never touches an
      assignment someone else has since set".
    - `i26-evidence` (r46's bracket): R2, then R3's refused start, then R1b's
      `--unassign` on the worker's own issue left it
      `{"state":"in-progress","assigned":null,...}`, "**The issue is
      stranded.**"
    - P29, K18, `i26-cold3`, `i26-cold4` and Z3 say R1b's unassign must not run
      at an exhausted retry. See D17.
- **D10. Whether the one-worker branch may keep one token across issues (new
  in round 5). Not resolved.** No party read another's round-5 report.
  - `i26-pushback` (P23), `i26-cold` (C16), `i26-cold2` (K11) and `i26-cold3`
    (Q1): a single token makes resume-own reachable on that branch, so R3's
    stated reason is false there; each asks for a fresh `<n>` per issue or per
    pick. `i26-cold2` calls the consequence "latent, not live".
  - `i26-cold3` (Q1) adds the other horn: a fresh token per issue "renames
    itself mid-run", and the skill should say why that is not 0002's rename.
  - `i26-fresh`: "A token is used across issues in the one-worker case. That is
    consistent with r5: R1's 'each dispatch mints a fresh `<n>`' does not reach
    a path that has no dispatch. One token across sequential issues is also
    safe."
  - **Round 6. Not resolved.** r6 takes the fresh-token side: "Every pick, on
    both paths, uses a fresh `<n>` … For the single worker that means a new
    token per issue. Since identity is set on each command (R4), that costs
    nothing."
    - Released on it: P23 (`i26-pushback`), C16 (`i26-cold`), K11
      (`i26-cold2`), Q1 (`i26-cold3`, "answered by structure, though not in
      words").
    - `i26-fresh` changes sides: "**A little, and r6's 'that costs nothing'
      overstates it.** I move to r6's side." It raises the cost as F21.
    - `i26-evidence` (r39): "measured support for the fresh-token side of
      D10".
    - `i26-cold4` (W3), not a party before round 6, argues against the
      movement. See D13.
  - **Round 7. Not resolved.** Human ruling 3 takes the fresh-token side for
    every pick, with self-resume and the reopen keeping the issue's token.
    Every party accepts ruling 3; none says in its own report that D10 is
    resolved.
    - `i26-fresh`: "I accept ruling 3. E20's measurement is a better ground
      than my round-5 'safe' claim, which did not consider a reused token
      reaching an earlier reopened issue."
    - `i26-pushback` (P23 stands), `i26-cold` (C16 "still hold[s]"),
      `i26-cold2` (K11 "survives ruling 3"), `i26-cold3` (Q1 "Still
      released").
    - `i26-evidence`: ruling 3 "rests on my E20 measurement, which reproduces
      here".
  - **Round 8. Not resolved.** No party says D10 is resolved.
    `i26-cold2`: "K1 to K15 still hold against r8." `i26-cold6` (Z8), not a
    party before round 8: "Under R1 the token changes only between issues,
    never while one is held, and self-resume keeps the token mid-issue. So the
    rule's reason is respected." It asks that execute.md say so.
- **D11. Who clears a stood-down worker's assignment, and how (new in round
  5). Not resolved.** No party read another's round-5 report.
  - `i26-pushback` (P19): R1b "doesn't say whether the worker or the
    orchestrator clears the assignment; that is implementation detail either
    way, because clearing is not a transition."
  - `i26-cold3` (Q5): the subject should say "the orchestrator clears, on the
    worker's return, using `--unassign`", or two implementations differ.
  - `i26-arch` (A16): whoever clears does so "only when the issue's current
    assignment equals the worker's token"; "The mechanism belongs to the
    implementing issue."
  - **Round 6. Not resolved.** r6: "the orchestrator clears the assignment
    with `--unassign`, **only if it still carries that worker's token**".
    - `i26-arch` (A16): "**released**": "my requirement verbatim".
    - `i26-cold3` (Q5): "**released**": "That is my fix and A16's together."
      The check-then-act "belongs to #35, not here".
    - `i26-pushback` (P19): "stands, strengthened".
    - `i26-evidence`: the guard "is read-then-write with no atomicity … I did
      not race it". `i26-cold` and `i26-fresh` judged that window negligible
      and did not test it.
    - Every party's finding is released or stands on R1b; none says in its
      own report that D11 is resolved.
  - **Round 7. Not resolved.** R1b is unchanged. `i26-arch`: A16 still
    released. `i26-cold3`: Q5 "Still released". `i26-pushback`: P19 stands.
    `i26-cold5`, not a party before round 7: "`--assign` and `--unassign`
    append no transition. So the orchestrator's writes in R1/R1b do not affect
    ownership, whatever identity it runs under." No party says D11 is
    resolved.
  - **Round 8. Not resolved.** R1b is unchanged. No party says D11 is
    resolved. `i26-cold6`: "`--assign` adds no transition"; R1b "never touches
    an assignment someone else has since set". What R1b does at an exhausted
    retry is D17.
- **D12. Whether git-zhi 0.7.2 exposes the critical-chain order, and whether
  urgency-first is a choice (new in round 6). Not resolved.** r6's R1: "take
  the pool by `urgency`, then by creation order. … Nothing in git-zhi 0.7.2
  exposes that order for a single milestone. … the loss is a recorded cost of
  this change."
  - `i26-arch` (A18): the claim is false. `list --critical --format json`
    exposes the chain `next` uses (L1, L2); order the pool by position on it,
    then git-zhi's order. Urgency-first "is a *new* policy, not a
    restoration". It would stand aside if the human rules urgency-first is
    deliberate, "provided the false sentence about git-zhi is removed".
  - `i26-cold4` (W2): "true only in the narrow sense that nothing is
    milestone-scoped. Bare `next` was not milestone-scoped either." Whether
    urgency outranks the critical chain is the human's decision.
  - Observed as supporting r6's claim:
    - `i26-fresh`: `list --critical --milestone m1` printed m2's chain; "That
      confirms r6's claim".
    - `i26-cold2` (O12): `list --critical --milestone mine` printed `o1`,
      which "bears out" the claim.
    - `i26-cold`: "**Confirmed, and the reason is worse than stated**": text
      `--critical` ignores `--milestone`, and `--format json` ignores
      `--critical`.
    - `i26-pushback`: `list --critical` returned every open issue in creation
      order; "consistent with" the claim, and "It does not refute it".
    - `i26-cold3` (Q3 released): "Nothing in 0.7.2 gives a milestone-scoped
      critical order without computing it by hand".
  - The observations of `list --critical` differ. `i26-arch` (L1) and
    `i26-cold4` saw `critical_chain` in JSON list the milestone's chain when
    it held the longest path; `i26-cold` saw `--format json` ignore
    `--critical`; `i26-pushback` saw every open issue in creation order.
  - **The author's measurement after round 6**, recorded in the header: with
    two chains of equal length 3, `list --critical` and `list --critical
    --milestone mine` printed the identical chain `o1→o2→o3` of milestone
    `other`, and bare `next` returned `o1`. The text output printed every
    short id as `01a17b5e`, because the 8-character prefixes of time-ordered
    UUIDs created together collide.
  - On urgency: `i26-cold3` (Q9) and `i26-evidence` note that the stored
    strings sort `high < low < normal`; `i26-pushback`'s growth check calls
    the `urgency` key "an unanchored choice"; `i26-cold3` finds urgency-first
    "defensible", lining up with refinement's `low` doc issues; `i26-fresh`
    accepts it "as a recorded cost".
  - **Round 7. Not resolved.** Human ruling 4: issues on the repository
    critical chain from `list --critical` come first, in that chain's order,
    then the rest in creation order, with no `urgency`. Every party accepts
    it; none says in its own report that D12 is resolved, and C21 is raised
    against how the order is read. See D14.
    - `i26-arch` (A18 "**released**"): "Ruling 4 gives exactly that." The
      caveat "matches my round-6 L2 reading of `chain_list.go`".
    - `i26-cold4` (W2 "**released**"): "It is the order I argued for in W2."
      "The cost r7 records is the true residual one, so the earlier false
      claim about git-zhi is gone."
    - `i26-cold3` (Q9 "**released**", "moot rather than fixed"): ruling 4 "is
      better than r6's order and better than what I asked for in Q3". Q11: the
      cost is understated against `next`; what is lost is "a
      *milestone-scoped* critical order, and `next` never had one".
    - `i26-pushback` corrects its round-6 note: "That came from reading the
      JSON's `issues` key. The chain is in `critical_chain`, which ignores
      `--milestone`, as r7 says."
    - `i26-evidence`: "Ruling 4 behaves as stated": recovered in case A, lost
      in case B, with three nits (`null`, UUID ties, the chain moving).
    - `i26-cold`: "**accepted as policy**", "But it cannot be carried out as
      r7 elsewhere directs (C21)."
    - `i26-cold2`: "accepted"; `i26-fresh`: "I accept ruling 4."
    - `i26-cold5`, not a party before round 7: `list --critical --milestone m1`
      returns m2's chain; "The author's measurement holds." V4: say that
      `critical_chain` lists issues upstream first.
  - **Round 8. Not resolved.** r8 reads the order from the `critical_chain`
    key and restates the cost: "What is lost is a milestone-scoped critical
    order, which bare `next` never offered either." No party says D12 is
    resolved.
    - `i26-cold3` (Q11 "**released**"): "r8's cost sentence says what I asked".
    - `i26-arch`: the restated cost "is true. `headForActor` ranks by the
      whole-graph chain, my round-6 L2. It sharpens A18 rather than reopening
      it."
    - `i26-cold5` (V4 "**released**"): `critical_chain` "lists upstream first
      (`b1,b2,b3`)".
    - `i26-cold6`, not a party before round 8: "Confirmed in source." "R1's
      order (chain, then creation) reproduces this order, applied to the
      milestone's pool." It did not verify that `list --critical` ignores
      `--milestone`.
    - `i26-evidence` corrects how the binding section records its round-7
      tie nit: "an equal-length chain in another milestone wins by UUID, so
      'holds the chain' is false for the later one". It calls the recorded
      "ties between equal `created` values go by UUID" "**not what I
      raised**".
- **D13. Whether a fresh token per issue on the one-worker path is within
  0002 and costs nothing (new in round 6). Not resolved.** It contests D10's
  movement.
  - `i26-cold4` (W3): it drops self-resume, which 0002 names, and "is the
    re-export 0002 forbids"; ruling 2 "does not settle changing the token
    between issues inside one agent". It puts three options to the human,
    one of them a ruling that "'worker' means one dispatch for one issue".
  - `i26-fresh` (F21): on r6's side, but resume-own is lost on a mid-issue
    continue, and the agent should resume the issue in hand under that
    issue's token. "A worker whose life is one issue is a coherent reading of
    0002's 'fixed for the life of a worker'".
  - `i26-cold3` (Q1, released): 0002's harm is a stranded in-progress issue,
    and "the agent reaches a pick only after its issue is done or released";
    the token belongs to the issue through Step 4's reopen.
  - `i26-evidence` (E20, r39): with one token reused and an earlier issue
    reopened, `next` returned the reopened issue in place of the pick, and
    R2's check accepted it; with a fresh token, the pick. The walkthrough as
    specified passes either way.
  - `i26-pushback` (P23), `i26-cold` (C16) and `i26-cold2` (K11) released on
    the fresh token.
  - **Round 7. Not resolved.** Human ruling 3 settles D13's question as the
    rulings record it: a fresh token on every pick, self-resume kept, the
    reopen keeping the issue's token, "The basis is E20's measurement." Every
    party accepts ruling 3; none says in its own report that D13 is resolved.
    - `i26-cold4` (W3 "**released**"): "Settled by ruling 3, which I accept."
      "My W3 asked for exactly the second of the options it listed." "The
      residual is W10, which is new."
    - `i26-fresh` (F21 "**released, with F22**"): "That is what I asked for."
    - `i26-evidence` (E20 "**released**").
    - `i26-cold3`: ruling 3 together closes "Q1's note and F21's stranding".
    - `i26-cold5`, not a party before round 7: "A rename happens here only
      between issues, after `done`, and Step 4's reopen keeps the issue's
      token. So nothing is stranded. Reading 'worker' as one dispatch matches
      0002's own per-dispatch minting."
    - What ruling 3's self-resume does against R3 is D15.
  - **Round 8. Not resolved.** No party says D13 is resolved. `i26-cold6`
    (Z8), not a party before round 8, asks that the ruling-3 sentence say why
    a per-pick token is not a breach of 0002's "Identity is fixed for the life
    of a worker". `i26-cold3`: E20's reused-token case "lands on a *reopened*
    issue, not an in-progress one, so it still goes to R2's stand-down."
- **D14. Whether `list --critical --format json` exposes the critical chain
  (new in round 7). Not resolved.** C21 is declared against the author's
  measurement and two participants' probes.
  - `i26-cold` (C21), measured on 0.7.2 in `scratch-cold/r6b/`: "`git zhi list
    --critical --format json` ignores `--critical`. It returns all nine issues
    in creation order", including issues on no chain. "Only the text output
    shows the chain (o1→o4)", labelled with short IDs that collide. In round 6
    it wrote that "`--format json` ignores `--critical`".
  - **The author's measurement:** on 0.7.2 the same command "returns an
    object with keys `critical_chain`, `current_constraint`, `issues` and
    `parallel_work`. `.critical_chain` held the chain `o1, o2, o3`; `.issues`
    held every issue in creation order."
  - `i26-pushback` (`probe26r7`): the same four keys; "`critical_chain` is A,
    B, C both with and without `--milestone m2`"; "`issues` *is* filtered by
    `--milestone` … and is in creation order. It is not chain order." It
    corrects its round-6 note, which "came from reading the JSON's `issues`
    key". "An implementer who reads `issues` silently gets 'creation order
    only'."
  - `i26-evidence` (r41 to r45): "`{issues, critical_chain,
    current_constraint, parallel_work}`"; with `--milestone`, "`issues` is
    filtered, but **`critical_chain` is still repo-wide**"; `critical_chain`
    is `null` when all are done.
  - `i26-cold5` (V4): "`critical_chain` lists issues upstream first (observed
    `b1,b2,b3`)".
  - `i26-arch` (round 6, L1) read `critical_chain` from the JSON.
  - C21 stays as its raiser declared it. Only `i26-cold` may release it.
  - **Round 8.** `i26-cold`, the only party holding the contrary position,
    withdraws it as its own act: "**C21: my measurement was wrong**". "I
    re-measured it." The keys are
    `["critical_chain","current_constraint","issues","parallel_work"]`, and
    "`.critical_chain` gives `["o1","o2","o3","o4"]`, which is the chain, in
    order." "In round 7 I read only `.issues` and concluded that JSON ignores
    `--critical`. That was wrong." "The author and i26-pushback were right.
    There is no git-zhi defect to file for the JSON form." It releases C21.
    - `i26-cold5` observes the key again (`b1,b2,b3`); `i26-cold6`, not a party
      before round 8, finds the same four keys, with `critical_chain` "an array
      of issue objects".
    - No party says in its own report that D14 is resolved, so it is not
      marked resolved. No party now holds the position that the JSON lacks the
      chain.
- **D15. Whether ruling 3's self-resume contradicts R3, and how resume enters
  the loop (new in round 7). Not resolved.**
  - Six participants say the two clauses conflict and the resumed issue is
    stranded: A19 (`i26-arch`), P26 (`i26-pushback`), F22 (`i26-fresh`), C20
    (`i26-cold`), K16 (`i26-cold2`), W10 (`i26-cold4`). Each asks for one
    sentence and for R3's "unreachable" to go. They differ on these points:
    - **The route.** A19 and C20: resume passes through `next` and does not
      start, going "straight to the ownership read" (C20). F22, K16 and W10:
      resume "runs no transition" and continues at Step 3, skipping R3 (W10:
      "skips R2 and R3"; K16 confirms with `next` first). P26 gives the
      ownership-read form and says the bypass form "is the same one sentence
      pointing the other way".
    - **What R1b does.** A19, P26, K16 and W10: R1b clears the assignment,
      leaving the issue in progress and unassigned. C20: "R1b does not apply
      (the worker owns the issue)", and "The issue is left in progress and
      assigned."
    - **Bar or not.** A19 "a bar, not a nit"; P26 "the one hold"; F22 "a bar
      to shipping the text unchanged", accepting if the sentence is recorded
      as binding on the implementing issue; C20 "A bar, one sentence"; K16 "a
      bar, but a one-sentence fix"; W10 "low-medium", "**Not held**".
  - `i26-cold3`, "Observation, no row": the two "concern different points: one
    is the resume branch inside R3's post-start check, the other is re-entry
    on 'continue'". "The only near-contradiction is the resume wording above,
    which is not a real conflict."
  - `i26-cold5` (V2, a nit): self-resume "can be read as the forgone benefit
    or as a requirement"; state it as a rule, checked "Before minting". It
    found "no contradiction that an implementer cannot resolve from the
    text".
  - `i26-evidence` did not examine "Whether any clause contradicts another,
    beyond the conditions I executed"; its model "reopens and returns,
    whereas under ruling 3 the issue's own token resumes it".
  - **Round 8.** r8: "Self-resume runs no transition". "It skips R2's
    stand-down and R3, and goes straight back to Step 3 under that token." The
    route r8 takes is the one F22, K16 and W10 gave. Each of the six raisers
    releases its row: A19, P26, F22, C20, K16 and W10. `i26-cold5` releases
    V2 with a residual, a walkthrough case for it.
    - `i26-cold3` withdraws its round-7 observation, as its own act: "my
      round-7 observation was wrong". "That was a reading of the words, and I
      had not run the path." "The six raisers were right that this strands the
      issue. I withdraw the observation."
    - `i26-evidence` (r46) measures the rule and the bracket: the rule keeps
      the assignment and `done` succeeds; the bracket strands the issue. It
      raises E21, and `i26-pushback` P28: the stated reason holds "only while
      the session is open", and a paused issue needs `--state resume`.
    - `i26-cold6`, not a party before round 8, raises Z7: put the exception
      beside R1's opening rule, and say the token comes from the conversation,
      so self-resume is "within one run only".
    - No party says in its own report that D15 is resolved, so it is not
      marked resolved. No party now holds that the round-7 clauses did not
      conflict.
- **D16. What the reused-token acceptance case shows (new in round 7). Not
  resolved.** r7's walkthrough covers "a worker whose token was used before,
  so that a reopened issue is reachable (E20)", and passes if "each worker
  worked the issue assigned to it".
  - `i26-pushback` (P27): the case "cannot be constructed without breaking R1";
    if built, the worker works the reopened issue and the run fails, so it "is
    a negative control" and belongs with the "Run without R1 to R3" bullet.
  - `i26-evidence` (E20 released): measured `REUSE=1` as "**FAIL**", the
    worker working m1 in place of its assignment, and `REUSE=0` as PASS. "The
    new pass condition makes the token rule observable".
  - `i26-cold2`, a nit: the case "deliberately violates R1, to show that R2's
    guard holds. A correct worker there stands down, which passes vacuously.
    The implementing issue should assert the stand-down explicitly."
  - `i26-cold3`: the case, with "each worker worked the issue assigned to it",
    "turns red when the token is reused".

  - **Round 8. Not resolved.** r8's binding section: "the reused-token case
    is a negative control, which must fail (P27)" and "the reused-token
    stand-down is an explicit assertion (i26-cold2)". The Acceptance body
    still lists the case under "It passes if".
    - `i26-pushback` (P27 "**released, as a residual carried by the binding
      section**"): "Editing L186 to match would remove the contradiction." On
      the assertion line: "I could not tell which stand-down this means.
      Under R2, a reused token's `next` returns a reopened issue that is still
      assigned to that token (E20, D2), so R2 produces no stand-down."
    - `i26-cold2` (K17): "Both are true, of different runs": under R2 the
      worker stands down and the walkthrough passes; with R2's guard removed,
      the case goes red.
    - `i26-cold6` (Z4), not a party before round 8: the negative control is
      "`next` under a reused token returns the earlier reopened issue, not the
      assignment"; the passing assertion is "under R2 the worker starts
      nothing and returns."
    - `i26-evidence`: "reused-token **negative control** (`REUSE=1`) **FAIL**,
      as P27 requires: `worked an issue other than its assignment: [m1 m2
      m3]`."
    - `i26-cold3`: E20's case "lands on a *reopened* issue … so it still goes
      to R2's stand-down."
    - The parties describe what the passing half asserts differently
      (`i26-pushback`: R2 "produces no stand-down"; K17, Z4 and `i26-cold3`: the
      worker stands down under R2). No party says D16 is resolved.
- **D17. What happens when R3's bounded retry is exhausted (new in round 8).
  Not resolved.** r8's binding section: "R3's retry of a failed read is bounded
  (V1)"; R3: a failed read "never counts as won or lost". Every party says the
  outcome is unstated and that R1b's unassign there would strand an issue the
  worker may hold. They state the outcome differently:
  - `i26-pushback` (P29): "ends the worker's attempt as *unknown*, reported by
    name, without R1b's unassign. Whatever outcome it picks, it must not count
    as lost."
  - `i26-cold2` (K18): "unknown: stand down, and leave the assignment alone".
  - `i26-cold6` (Z3): "Loop control's tool-failure stop: stop and report
    without standing down."
  - `i26-cold3`: "stop and report the issue, which is Loop control's 'a tool
    refused' stop".
  - `i26-cold4`: "the stand-down at the bound to report the issue rather than
    release it"; "a residual for the implementing issue or #27".
  - Each declares it a residual. No party says D17 is resolved.
- **Self-corrections made in round 8**, each the participant's own act:
  - `i26-cold`, C21: "my measurement was wrong"; C21 released. See D14.
  - `i26-cold3`, its round-7 observation on D15: "my round-7 observation was
    wrong"; "I withdraw the observation." See D15.
  - `i26-cold5`, V3: "A correction to my own round-7 premise (V3)". "R1 names
    a different command, `issue list --ready --milestone <m>`, and that
    command's JSON is the full issue object." "So R1's query already carries
    `assigned` and `created`, and no join is needed. V3's 'needs a join' was
    true of the wrong command." V3 released, with a residual.
  - `i26-evidence`, its round-7 tie nit as the binding section records it:
    "**misrecorded; please correct**". See D12. It also notes that its earlier
    tables "printed `null` because jq yields `null` for a missing key"; V3's
    "omits the field" is "**correct**".

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
- **Round 4.** No participant reports reading another's round-4 report.
  `i26-cold2` read no earlier findings at all. Raised independently in this
  round:
  - **The one-worker (`Otherwise`) path still drifts off the milestone, because
    R1 fires only on dispatch**: P21 (`i26-pushback`), F17 (`i26-fresh`), C13
    (`i26-cold`), K1 (`i26-cold2`). Four. `i26-arch` lists the one-worker path
    as "now in #27" under what it did not re-examine.
  - **A stood-down worker's assignment is left on the issue, which then leaves
    R1's pool for the run**: P19 (`i26-pushback`), C12 (`i26-cold`), K3
    (`i26-cold2`). Three raised it as a finding against #26; `i26-arch` (under
    A6), `i26-fresh` (under F3) and `i26-evidence` (a note) observed the
    stranding and place it in #27. See D9.
  - **Re-dispatch after return and the run's end are unspecified**: P20
    (`i26-pushback`), K4 (`i26-cold2`). `i26-fresh` writes the opposite of K4's
    first half: under R2, a worker's second `next` gives "one issue per worker,
    then return".
  - **"No issue is started by two workers" cannot be observed from the chain**:
    E17 (`i26-evidence`), K8 (`i26-cold2`).
  - **The token scheme behind R3's "one token per issue" is unstated**: C14
    (`i26-cold`), K2 (`i26-cold2`), and A15 (`i26-arch`) on #27's same-token
    fix.
  - **`how-to-use-git-zhi.md` contradicts the per-command identity rule and is
    not in "Where it goes"**: C9's held half (`i26-cold`), K6 (`i26-cold2`).
  - **R3 defends a race R1 and R2 exclude within a run**: C6's standing-aside
    (`i26-cold`), K10 (`i26-cold2`). See D7.
  - **Acceptance passes with a stood-down issue never re-dispatched**: P19's
    restored clause (`i26-pushback`), C12 (`i26-cold`), K9 (`i26-cold2`).
- By section, round 4 concentrates on **R1 with Out of scope** (P19, P21, F17,
  F18, C12, C13, K1, K2, K3, K4) and **Acceptance** (E17, K7, K8, K9).
- **Round 5.** No participant reports reading another's round-5 report.
  `i26-cold3` read no earlier revision, no assessment record, no other
  participant's file and not #27. Raised independently in this round:
  - **R1b with R1a turns a `wip_limit` refusal into a re-dispatch loop with no
    end**: A17 (`i26-arch`), P22 (`i26-pushback`), F19 (`i26-fresh`), C15
    (`i26-cold`), K12 (`i26-cold2`), Q2 (`i26-cold3`). Six, every participant
    but `i26-evidence`. Each places it in #26 rather than #27's chain-wide
    count, and each asks for a stop or hold after a WIP refusal. What each
    observed:
    - C15 measured three dispatches in a row, K12 (O10) three cycles, each with
      an unchanged pool and a refused start;
    - A17 (J1 to J3) and F19 each observed one cycle; A17: "The loop is my
      inference from one observed cycle";
    - P22 ran no probe; "the loop itself was not run";
    - Q2 observed the refusal and reasons the rest from the text.
    - F19 and K12 also name Loop control's "a tool refused the action" stop:
      F19 as contradicting R3's stand-down, K12 as the stop R1a should invoke.
    - **`i26-evidence`'s measurement bears on this cluster.** In its `SCEN=wip`
      runs a WIP refusal was re-dispatched successfully 27 of 27 times, every
      run passed and ended `live=0 pool=[]`, and it calls the churn "a cost,
      not a correctness problem". In that setup the second slot was held by
      the run's own concurrent worker, which freed it inside the run, while an
      outsider held the first. The loop the six describe is the case where
      nothing of this run is live to free a slot: a human's issue, another
      milestone's, or E14's lost issue. `i26-evidence` did not run that case.
  - **The one-worker branch's token is unstated, so R3's "one token per issue"
    does not reach it**: P23 (`i26-pushback`), C16 (`i26-cold`), K11
    (`i26-cold2`), Q1 (`i26-cold3`). Four. `i26-fresh` states the opposite;
    see D10. Q1's observation that the same actor can start a second issue
    with rc 0 bears on it.
  - **Clearing on stand-down: who, with which flag, and under what guard**:
    A16 (`i26-arch`), Q5 (`i26-cold3`); `i26-pushback` calls it implementation
    detail. `--assign ""` and `--unassign` were each observed to clear (J2,
    r36, `i26-cold3`). See D11.
  - **Acceptance's refused-or-lost and completeness bullets cannot be met as
    written**: E18 (`i26-evidence`, the lost case is never re-dispatched), Q6
    (`i26-cold3`, a human-assigned ready issue), K9's note (`i26-cold2`, no
    time reference), C15 (`i26-cold`, "passes only if the walkthrough's
    refusal cause clears by itself").
  - **Acceptance tests a script, not the skill's observable**: K13
    (`i26-cold2`), Q4 (`i26-cold3`).
  - **execute.md text r5 must reconcile with R1a**: F19 (`i26-fresh`, Loop
    control l.84), Q7 (`i26-cold3`, l.182–187), and `i26-cold3`'s list under
    Axis 1.
- By section, round 5 concentrates on **R1a and R1b** (A16, A17, P22, F19,
  C15, K12, Q2, Q5) and **R1's one-worker bullet** (P23, C16, K11, Q1), then
  **Acceptance** (E18, K13, Q4, Q6).
- **Round 6.** No participant reports reading another's round-6 report.
  `i26-cold4` read no earlier findings at all. Raised independently in this
  round:
  - **R1c's early end against Acceptance's "every ready issue dispatched"
    condition, and R1c's report naming only the refused issue**: K14
    (`i26-cold2`), C18 (`i26-cold`), P25 (`i26-pushback`), W1 (`i26-cold4`),
    E19 (`i26-evidence`). Five. Each says a correct run fails the condition
    whenever the pool holds more issues than were dispatched. K14, C18, W1
    and P25 name a one-issue scenario as the way an implementer gets it to
    pass; E19: the case passes "only by not checking the third condition".
    Each asks that the condition admit issues named in the
    end-of-run report; K14, C18, P25 and E19 also ask that R1c's report name
    the remaining pool. E19 measured it (`walk6.sh` `wipout`: m3 never
    dispatched, never named); the other four reason from the text.
    `i26-cold3` (Q6 released) writes that "An issue R1c reports by name was
    dispatched, so it does not fail the condition".
  - **On the one-worker path, R1c's "until a live worker returns" can be read
    so that the agent waits on itself**: F20 (`i26-fresh`), C17 (`i26-cold`),
    P24 (`i26-pushback`), Q10 (`i26-cold3`). Four, each asking for one clause
    that ends the run there. Each calls the intended reading the plain one,
    or one of two. `i26-evidence` ("R1c stops at once"), `i26-cold2` ("no
    worker is live and the run ends. It does not hang") read the text as
    ending the run; `i26-evidence` ran the one-worker `wipout`
    case and it stopped after one dispatch.
  - **The Loop control sentence r6 dropped from R1a**: K15 (`i26-cold2`), P20's
    nit (`i26-pushback`). Both ask for "Loop control's wording changes to
    match" to be restored. W5 (`i26-cold4`), which did not read r5, names the
    same two execute.md stops ("the ready set is empty", "every remaining
    issue is blocked") as still contradicting R1a.
  - **The ordering and urgency questions in R1's "Order"**: A18 (`i26-arch`)
    and W2 (`i26-cold4`), that the critical-chain order is exposed and
    urgency-first is a new policy; Q9 (`i26-cold3`), that urgency has no
    stated direction and sorts wrong as strings, as `i26-evidence`'s ordering
    note also says; and `i26-pushback`'s growth note, that the `urgency` key
    answers no finding. `i26-fresh`, `i26-cold` and `i26-cold2`
    observed `--critical` ignoring `--milestone`, and `i26-arch` read the same
    in source (L2); `i26-pushback` observed a different output (D12); the author's
    measurement after round 6 is recorded under D12.
  - **A token per issue on the one-worker path and resume of an issue in
    hand**: F21 (`i26-fresh`), W3 (`i26-cold4`), Q1's note (`i26-cold3`), E20
    (`i26-evidence`, the walkthrough cannot tell them apart). See D13.
  - **The Q8 sentence's wording about 0002**: C19 (`i26-cold`, the words are
    execute.md's), W7 (`i26-cold4`, "no assignee filter" is stale).
  - **The token-guarded `--unassign` is a read then a write**: noted, not
    raised, by `i26-evidence`, `i26-cold`, `i26-fresh` and `i26-cold3`. See
    D11.
- By section, round 6 concentrates on **R1c with Acceptance** (E19, P24, P25,
  F20, C17, C18, K14, Q10, W1) and **R1's "Order" and token bullets** (A18,
  F21, Q9, W2, W3, E20).
- **Round 7.** No participant reports reading another's round-7 report.
  `i26-cold5` read no earlier revision, record, brief, diff or #27. The brief
  to the resumed participants asked each to "Check whether any clause answers
  nothing, or now contradicts another clause." Raised independently in this
  round:
  - **Ruling 3's self-resume against R3, whose "unreachable" sentence and
    start-then-stand-down bullets r7 kept**: A19 (`i26-arch`), P26
    (`i26-pushback`), F22 (`i26-fresh`), C20 (`i26-cold`), K16 (`i26-cold2`),
    W10 (`i26-cold4`). Six. Each traces the same path, `next` returning the
    held issue and its start refused, and each asks for one sentence plus
    removal of "unreachable". What each observed:
    - F22, K16 (O14 to O16) and W10 ran the path on 0.7.2; F22 and K16 also
      observed `--state resume` refused;
    - A19, P26 and C20 cite D4's measurement and ran nothing new for it.
    - `i26-cold5` (V2) reaches self-resume from a different side: it "reads as
      a description, not a rule", and an agent that skips it strands the old
      issue. V2 does not name R3.
    - `i26-cold3` names the same two clauses and reads them as "different
      points", "not a real conflict". `i26-evidence` did not check clause
      contradictions. See D15.
  - **`list --critical`'s output, and what an implementer reads ruling 4's
    order from**: C21 (`i26-cold`, JSON ignores `--critical`), `i26-pushback`'s
    nit (name the `critical_chain` key, since `issues` is creation order),
    `i26-evidence`'s nits (`null`, ties, the chain moving), V4 (`i26-cold5`,
    upstream-first order). Q11 (`i26-cold3`) concerns how the cost is
    phrased. The author's measurement bears on C21; see D14.
  - **A stand-down that is not a refused start can re-dispatch without
    bound**: V1 (`i26-cold5`), and `i26-cold4`'s nit under W4's release ("read
    R1c's trigger as 'stands down with the issue still pending', whatever the
    cause"). W4 was raised in round 6.
  - **At R1a's end, issues left blocked or held go unnamed**: `i26-arch`'s
    nit, `i26-pushback`'s P20 residue, `i26-evidence`'s second nit. All three
    are nits; `i26-cold` writes that "'blocked' now ends the run through R1a's
    empty filtered pool".
  - **The "read issue IDs from JSON" line sits under Out of scope**:
    `i26-pushback` (no finding and no ruling; move it into R3 or leave it as a
    nit) and `i26-cold4` ("Moving it to R3 is a nit"). C21 reads the same line
    against ruling 4.
  - **The reused-token acceptance case**: P27 (`i26-pushback`) and
    `i26-cold2`'s nit. See D16.
  - **Growth.** `i26-arch`, `i26-pushback`, `i26-fresh`, `i26-cold`,
    `i26-cold2`, `i26-cold3` and `i26-cold4` each found no clause that answers
    nothing; `i26-pushback` names the short-ID line as the one clause citing
    no finding or ruling.
- By section, round 7 concentrates on **R1's ruling 3 bullet with R3** (A19,
  P26, F22, C20, K16, W10, V2) and **R1's "Order"** (C21, Q11, V4). Every
  round-7 row other than the self-resume six and C21 is marked a nit by its
  raiser.
- **Round 8.** No participant reports reading another's round-8 report.
  `i26-cold6` read no record, other report, diff, brief, earlier revision or
  #27. The brief asked resumed participants to check that nothing in the
  binding section "should really be a requirement in the body" and that
  nothing in it "contradicts the body". Raised independently in this round:
  - **`--step`, in R1's pick by the binding section and in #27 by Out of
    scope**: P30 (`i26-pushback`), K19 (`i26-cold2`), Z5 (`i26-cold6`), V6's
    residual (`i26-cold5`), and unnumbered residuals from `i26-fresh`,
    `i26-cold3` and `i26-cold4`. `i26-arch` and `i26-cold` name the same
    tension as a nit and hold nothing. Nine participants name it; the seven
    that hold it as a residual ask for the one-worker path's carve-out, or a
    clause like it, to cover `--step`.
  - **R3's bounded retry with no stated outcome**: P29, K18, Z3, and
    unnumbered residuals from `i26-cold3` and `i26-cold4`. See D17.
  - **The reused-token case's two binding lines and the Acceptance body**:
    K17, Z4, P27's residual and `i26-pushback`'s unraised nit. See D16.
  - **Self-resume's stated reason on a paused issue**: E21 and P28, each
    measured. See D15.
  - **Single-raiser residuals**: Z1 (a refused restart leaves `reopened`), Z2
    (R1a and R1c), Z6 (two more "exported" lines), Z7 (self-resume beside R1's
    opening rule, and where the token comes from), Z8 (the per-pick token and
    0002), V2's and V3's residuals, and `i26-cold3`'s R1c window.
  - **Whether anything in the binding section belongs in the body**: every
    participant that reports the check finds nothing that must move.
    `i26-evidence` names "E21's one-word qualifier", "a sentence in R1 rather
    than in the binding section".
- By section, round 8 concentrates on **"Binding on the implementing issue"
  read against Out of scope, R3 and Acceptance** (P29, P30, K17 to K19, Z3 to
  Z5) and on **R1's self-resume bullet** (E21, P28, Z7, Z8, V2's residual).

## Residuals carried to the implementing issue

Under ruling 5, #26 is accepted at r8 with these open. Each is listed by
theme, with its raisers and ids, as its raiser declared it. Every one is
declared a residual, not a bar. Where a raiser placed one in #27 rather than
the implementing issue, that is said.

1. **What R3's retry bound does when it is exhausted.** P29 (`i26-pushback`),
   K18 (`i26-cold2`), Z3 (`i26-cold6`), and unnumbered residuals from
   `i26-cold3` and `i26-cold4`. Each says R1b's unassign must not run there,
   since the worker may hold the issue; they state the outcome differently
   (D17). `i26-cold4` places it with "the implementing issue or #27". The
   others place it with the implementing issue.
2. **The `--step` selection carve-out.** P30 (`i26-pushback`), K19
   (`i26-cold2`), Z5 (`i26-cold6`), V6's residual (`i26-cold5`), and
   unnumbered residuals from `i26-fresh`, `i26-cold3` and `i26-cold4`. The
   fix each names is Out of scope's one-worker carve-out extended to
   `--step`: selection is R1's, lifecycle stays in #27. `i26-arch` and
   `i26-cold` call it a nit and hold nothing.
3. **The reused-token control wording.** K17 (`i26-cold2`), Z4 (`i26-cold6`),
   P27's residual (`i26-pushback`: the binding line governs, and "Editing L186
   to match would remove the contradiction"), and `i26-pushback`'s nit on
   which stand-down the assertion means. See D16. `i26-cold2`: K17 is "the one
   I would most want fixed in wording before implementation starts".
4. **The paused-issue exception to self-resume.** E21 (`i26-evidence`) and
   P28 (`i26-pushback`): "refused while a session is open", and self-resume
   runs `--state resume` when the session is closed. `i26-evidence` says the
   qualifier "is a sentence in R1". `i26-pushback` gives "Session telemetry is
   lifecycle, which belongs to #27" as a ground for its not being a bar, and
   places the fix with the implementing issue.
5. **Z1's reopened state.** Z1 (`i26-cold6`): R3 covers every `--state
   start`, Step 4's included, and "pending" in R1b and R1c reads "not in
   progress, that is pending or reopened". "This is arguably lifecycle, which
   is #27's, but the wording is this subject's."
6. **The `assigned` field.** V3's residual (`i26-cold5`), after its own
   correction: "name `issue list`, not `list`, in the issue, because the rule
   applied to `list --ready` would dispatch human-assigned issues."
   `i26-evidence` re-measured the binding line as "**correct**".
7. **Other single-raiser residuals.**
   - V2's residual (`i26-cold5`): a walkthrough case for self-resume.
   - Z2 (`i26-cold6`): say that R1c takes precedence over R1a for that return.
   - Z6 (`i26-cold6`): R5 names `how-to-use-git-zhi.md`'s other "exported"
     lines.
   - Z7 (`i26-cold6`): self-resume stated beside R1's opening rule, and the
     token's source named; a prior run's in-progress issue "remains #27's
     dead-worker case".
   - Z8 (`i26-cold6`): the ruling-3 sentence says why a per-pick token
     respects 0002's reason.
   - `i26-cold3`'s R1c window, "not raised as a row".
8. **The binding section's own record.** `i26-evidence` asks that its tie nit
   be corrected to "an equal-length chain in another milestone wins by UUID,
   so 'holds the chain' is false for the later one".

**Placed in #27 by their raisers.** No round-8 residual is placed in #27
alone. `i26-cold4` places its retry-bound residual with "the implementing
issue or #27". `i26-fresh` holds F3, F11 to F14 and F16 "live in #27". The
#27 carry-over of A15, E14's in-progress half, E16's reporting half and F18
stands as recorded.

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

**Round 4, as each participant declared:**

- **`i26-arch`:**
  - did not re-run the round-3 C-series or the P, E and F measurements r4
    cites; relied on its own H1 and H2;
  - git-zhi#36, beyond noting that R3's literal-id rule is the crochet-side
    guard;
  - the Acceptance walkthrough's sufficiency beyond what H1 demonstrates;
  - `how-to-use-git-zhi` and E16;
  - the one-worker and `--step` paths, "now in #27".
- **`i26-evidence`:**
  - the walkthrough is a shell simulation, not an agent following the skill
    text, and its race uses a scripted intruder;
  - race outcomes depend on local scheduling; "The 8/12 split is not a rate";
  - the red run's duplicates come from concurrent `next` calls, "which an
    agent harness may or may not do";
  - small repositories; the 0.5 s pause may not be enough on a large chain.
- **`i26-pushback`:**
  - no new probes; P19 rests on round-2 and round-3 probes and D2, P21 on the
    execute.md text, neither re-measured on 0.7.2;
  - the truth of #27's items, read only to confirm its ids are recorded;
  - `--step`, accepted as #27's;
  - the concurrent-start race (E4, E10, D1), 0003, `how-to-use-git-zhi`;
  - no full multi-worker run, and no pvm.
- **`i26-fresh`:**
  - re-ran nothing; its evidence is round-2 `scratch-fresh/` observations;
  - R3's settle interval and the race (D1);
  - E16 and git-zhi#36 (accepts C6's empty-ref probe as measured);
  - whether #27's wording of each finding is faithful, beyond its ids;
  - `--step`.
- **`i26-cold`:**
  - did not re-run the concurrent-start race (D1, D7);
  - did not walk the multi-worker dispatch with real agents;
  - did not read #27's text, so cannot confirm it records C1 to C5 as raised.
- **`i26-cold2`:**
  - the concurrent lost update itself, relying on git-zhi#35's measurements;
  - dispatch-and-return behaviour inside
    `superpowers:dispatching-parallel-agents`.
- No participant ran a full multi-worker `crochet:execute` run in round 4, and
  none walked the one-worker branch with an agent.

**Round 5, as each participant declared:**

- **`i26-arch`:**
  - the other participants' round-4 measurements, beyond the ledger text for
    D9;
  - whether `checkBlockers` refusals can recur in the same loop; "Under R1 the
    pool is drawn from the ready set, so it should not, but I did not test it";
  - the one-worker clause end to end, and Step 4's return wording;
  - the concurrent walkthrough, beyond round-4 H1;
  - A17's loop was observed for one cycle and not run repeatedly.
- **`i26-evidence`:**
  - steal outcomes depend on scheduling; the wip refusals are deterministic;
  - "the walkthrough is a shell simulation with scripted workers, not agents
    following the skill text";
  - small repositories, "so the 0.5 s pause is generous here".
- **`i26-pushback`:**
  - no new probes; P22 rests on round 3's `wip_limit` probe and the text, and
    "the loop itself was not run"; P23 is not re-measured;
  - round 4's forced-race and walkthrough measurements, taken as given;
  - whether #27's comment carrying A15, E14 and E16 was posted;
  - `--step`, 0003, the concurrent-start race, any full multi-worker run, and
    pvm.
- **`i26-fresh`:**
  - R3's settle interval and the concurrency measurements (K7, E17, the 20 of
    20 races);
  - the `how-to-use` `export` example change (K6);
  - whether K9's ready set is measured at run start or run end;
  - the other K-series rows beyond what F19 touches.
- **`i26-cold`:**
  - did not re-run the concurrent-`next` condition (K7) or the negative
    "without R1 to R3" run;
  - did not check whether #27's comment carries A15 and E14 as stated;
  - did not walk an LLM agent through the one-worker branch.
- **`i26-cold2`:** declares no "not checked" list in round 5.
- **`i26-cold3`:** declares no "not checked" list. It states it read no
  earlier revision, no assessment record, no other participant's file, and not
  #27.
- No participant ran a full multi-worker `crochet:execute` run in round 5, and
  none walked the one-worker branch with an agent. `i26-evidence` ran the
  one-worker branch as a shell simulation (CAP=1).

**Round 6, as each participant declared:**

- **`i26-arch`:**
  - the other participants' round-5 measurements, and D10 and D11, beyond
    what r6 quotes;
  - the walkthrough's scripting;
  - whether `urgency` values are set in practice on real chains;
  - the `--step` path and Step 4's wording, "which are #27's";
  - concurrent behaviour beyond rounds 4 and 5.
- **`i26-evidence`:**
  - R5's text sites and the Q8 argument about 0002;
  - whether every added clause answers a named round-5 finding, beyond its
    own rows;
  - the atomicity of the guarded `--unassign`, not raced;
  - agent behaviour: "the walkthrough is a shell model";
  - steal outcomes depend on scheduling; the dispatch cap of 20 is its own
    bound.
- **`i26-pushback`:**
  - no full walkthrough; R1c's termination "is reasoned from the text and
    round-3's `wip_limit` probe";
  - whether `next` uses `urgency`, not checked in git-zhi's source;
  - `i26-evidence`'s round-5 measurement that R1c cites;
  - the #27 comment carrying A15, E14, E16 and F18;
  - `--step`, 0003, the concurrent-start race, and pvm.
- **`i26-fresh`:**
  - the concurrency measurements and the settle interval;
  - K8 and K13's record format; K9 and Q6's exclusion;
  - D11's read-then-unassign window, judged negligible and not probed;
  - the `postmortem.md` text;
  - whether urgency-then-creation is a sound substitute order, "I accept it
    as a recorded cost".
- **`i26-cold`:**
  - the concurrent-start condition (K7, K13) and the negative run;
  - the token-guard race in R1b, judged negligible and not tested;
  - whether the #27 comment carries A15, E14, E16 and F18;
  - `urgency` values other than `normal`;
  - whether the two `list --critical` defects are known to git-zhi.
- **`i26-cold2`:**
  - the ledger at `eefe101` and the Q rows' wording;
  - the round-5 refusal-and-free re-dispatch measurement R1c cites;
  - the concurrent race itself, taken from rounds 4 and 5;
  - whether `urgency` ordering is a good priority.
- **`i26-cold3`:**
  - did not re-run concurrent starts or the R1c sequence; walked R1c's
    termination from the text;
  - did not re-read execute.md in full against r6;
  - the #27 carry-over comment, and other participants' rows beyond those
    that cluster with its own.
- **`i26-cold4`:** declares no "not checked" list. It states it read r6
  "without prior findings".
- No participant ran a full multi-worker `crochet:execute` run in round 6, and
  none walked either branch with an agent. `i26-evidence` ran both branches as
  a shell simulation.

**Round 7, as each participant declared:**

- **`i26-arch`:**
  - D12 and D13 beyond what r7 quotes;
  - git-zhi#37, "beyond accepting 'read IDs from JSON'";
  - R3's wait mechanism (W6);
  - the other participants' round-6 measurements. It ran no new commands.
- **`i26-evidence`:**
  - r7's prose additions: W8, W9, the corrected 0002 quotation and the
    git-zhi#37 note;
  - "Whether any clause contradicts another, beyond the conditions I
    executed";
  - agent behaviour against the skill wording (Q4);
  - R3's harness-permitted wait; "My model uses `sleep` in a subshell."
- **`i26-pushback`:**
  - no walkthrough run; P26 "rests on D4 …, D2 …, and the text";
  - how the harness signals "told to continue";
  - `i26-evidence`'s rounds 5 and 6 and E20's r39 run, taken as given;
  - W4;
  - `--step`, 0003, the start race, and pvm.
- **`i26-fresh`:**
  - the ledger rows behind D12 and D13 (it did not open the ledger);
  - W6's wait mechanism; C19 and W7's `--assigned` claim; git-zhi#37;
  - the concurrency measurements; E20's measurement, accepted as stated.
- **`i26-cold`:**
  - the concurrent-start and "without R1 to R3" runs;
  - the E20 reused-token case as scripted;
  - whether git-zhi knows of the `list --critical` JSON and `--milestone`
    defects;
  - R3's wait mechanism (W6).
- **`i26-cold2`:**
  - the ledger and the wording of the W, E19 and E20 rows;
  - E20's reused-token measurement;
  - R3's harness-permitted wait mechanism;
  - `list --critical --format json` field names.
- **`i26-cold3`:**
  - re-ran nothing: not ruling 4's `list --critical` behaviour, not E20's
    reuse case, not R3's wait mechanism;
  - did not re-read execute.md in full against r7.
- **`i26-cold4`:** declares no "not checked" list. It states it read r7, the
  ledger at `7614e9f` for its rows and D12 and D13, then the diff.
- **`i26-cold5`:**
  - did not run the full acceptance walkthrough, the concurrent-start races,
    or the "fails without R1–R3" contrast;
  - did not inspect `superpowers:dispatching-parallel-agents`, so "cannot say
    whether its result collection carries a worker's stand-down reason …
    back to the orchestrator, as R1b and R1c need. That is implied by r7
    rather than stated."
- No participant ran a full multi-worker `crochet:execute` run in round 7, and
  none walked either branch, or self-resume, with an agent. `i26-evidence` ran
  both branches as a shell simulation (`walk7.sh`), with no self-resume case.

**Round 8, as each participant declared:**

- **`i26-arch`:**
  - D14 to D16 beyond what r8 quotes;
  - C21, "which only its raiser may release";
  - the other participants' round-7 measurements;
  - whether `assigned` is omitted rather than null in the ready JSON: "either
    form reads as null, so the binding rule is safe either way". It ran no new
    commands.
- **`i26-evidence`:**
  - R5's added `docs/ARCHITECTURE.md` site and the other prose sites;
  - the C21 release, "which is i26-pushback's";
  - `--step` (V6);
  - the R1c-on-decline path, "not constructed";
  - agent behaviour against the skill wording.
- **`i26-pushback`:**
  - no walkthrough run;
  - P28's "outside pause" trigger, "reasoned from `grep`"; whether a harness
    interrupt ever pauses an issue;
  - C21, "not mine";
  - D14 to D16, "not re-read in full";
  - the binding section's `i26-evidence` items (null chain, UUID tie, moving
    chain), not re-measured;
  - `--step`, 0003, the start race, and pvm.
- **`i26-fresh`:**
  - C21 and the `critical_chain` key;
  - Q11's restated cost;
  - V5's `docs/ARCHITECTURE.md` edit, "beyond noting that it is doc-first";
  - the ledger rows for D14 to D16. It re-ran no probes.
- **`i26-cold`:**
  - the concurrent-start run, the run without R1 to R3, and the E20 case;
  - the `docs/ARCHITECTURE.md` "exported" site (V5);
  - `--state resume` being refused on one's own issue: "I relied on 0002's
    observation from 0.6.0 and r8's statement for 0.7.2."
- **`i26-cold2`:**
  - the ledger;
  - the `critical_chain` JSON key;
  - the E20 measurement;
  - `docs/ARCHITECTURE.md`'s "exported identity" line, "beyond confirming it
    exists".
- **`i26-cold3`:** did not re-run concurrent starts or the R1c sequence.
- **`i26-cold4`:** declares no "not checked" list. It ran nothing new: "r8's
  claims about the tool match what I observed in rounds 6 and 7".
- **`i26-cold5`:**
  - the concurrent-start races and the full walkthrough;
  - other participants' r8 reports;
  - D14 to D16 "beyond what r8 states".
- **`i26-cold6`:**
  - the full concurrent walkthrough; "The measurements of rounds 4 and 5 are
    taken as given";
  - that `list --critical` ignores `--milestone`;
  - how `ReadySet`'s sort key relates to `created` for the tie-break.
- No participant ran a full multi-worker `crochet:execute` run in round 8, and
  none walked either branch, or self-resume, with an agent. `i26-evidence`
  measured self-resume and its bracket with shell micro-tests (r46 to r49),
  outside `walk7.sh`.
