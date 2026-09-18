<!-- ABOUTME: Plan for aligning crochet's plugin surface (skills/, commands/, README, plugin.json) with RFC 0001. -->
<!-- ABOUTME: Inventories misalignments, orders them by what blocks what, and sizes each; contingent on RFC 0001 acceptance. -->
# Skills alignment with RFC 0001 — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Bring crochet's skills into line with `docs/decisions/0001-documentation-architecture.md` — remove every claim a skill makes that the tree or the installed `git zhi` binary contradicts, add the two plugin-side behaviours the RFC's Scope of Change names, and say plainly which of those wait on a git-zhi upgrade and which wait on a decision nobody has made yet.

**Architecture:** Three phases keyed to what unblocks them, not to which file they touch. **Phase A** fixes claims that are false against the installed binary today; nothing gates it. **Phase B** retires the milestone-body/resolution/postmortem workaround and is gated on one observation: `git zhi milestone edit --help` listing `--postmortem`. **Phase C** adds the RFC's new behaviours and is gated on RFC 0001 reaching `accepted`; one of its items (onboard installing guardrails) is its own decision and is scoped here, not designed.

**Tech Stack:** Markdown skill files with YAML frontmatter; the `git zhi` CLI (installed `v0.4.0-3-g9d96021`; source HEAD `04fbcd9` on `pu` at `~/dev/git-zhi`). No build step, no harness — validation is observe → document → verify against the real binary.

---

## Status of the specification

RFC 0001 is `state: proposed`, read here at commit `ef36c64`. Phase A does not
depend on it: those edits delete claims that are false today regardless of
what the RFC decides. Phase B depends on git-zhi, not on the RFC. Phase C
presumes acceptance and must not start before it. Nothing here presumes an
answer to the RFC's Open Questions (who accepts; glossary placement; whether
the postmortem's question is worth its interruption). In particular no task
writes any `state:` value — the RFC maps `accepted` onto "the human says
execute" without settling who the human is, and at `ef36c64` implementation
status is derived from `Implements:` trailers rather than declared, so there is
no `implemented` or `abandoned` to write.

## Validation Note (read first)

Same idiom as `2026-06-06-how-to-use-git-zhi-skill-plan.md`: the "failing
test" is an empirical observation against the real binary, the "implementation"
is writing the skill to match, and "verify" re-reads the skill against the
captured output. Every claim below about `git zhi` behaviour was checked
read-only; the commands and results are in the Evidence section. **No task in
this plan creates, edits or transitions an issue or milestone in this repo's
chain.** Where a task needs to observe a write (the `reopen` verb), it does so
in a throwaway repo under `$CLAUDE_JOB_DIR/tmp`. As of this writing the repo
has no chain at all (`git for-each-ref 'refs/zhi/**' | wc -l` → `0`).

---

## Evidence

Everything the inventory relies on, and what was run to get it.

| Claim | Command / source | Result |
|---|---|---|
| Installed binary lacks `--body`, `--resolution`, `--postmortem` on `milestone edit` | `git zhi milestone edit --help` | flags: `--due --name --resolve --state --tag --untag` only |
| Same flags fail loudly, naming the flag | `git zhi milestone edit x --postmortem - --help` | `git-zhi: unknown flag: --postmortem`, exit 1 |
| Source HEAD has all three, `-` reads stdin, `none` clears | `~/dev/git-zhi/internal/cli/milestone_edit.go:20,242-341` | `knownMilestoneEditFlags` includes `body`, `resolution`, `postmortem`; `readTextArg` treats `-` as stdin |
| Source HEAD `milestone add` also takes `--body` and `--resolution` | `~/dev/git-zhi/internal/cli/milestone_add.go:46-76` | both routed through `readTextArg` |
| At HEAD `--state complete` runs the resolution command as a gate before verify | `milestone_edit.go:343-379` | Gate 2 calls `runMilestoneResolve` when `ms.Resolution != ""` |
| At HEAD, content flags are persisted before `--state` so a failing gate does not lose the postmortem | `milestone_edit.go:56-80` | comment: "`--state complete` with a `--postmortem` is the natural way to close a milestone out" |
| Installed `milestone add` takes only `--due` | `git zhi milestone add --help` | one flag |
| `reopen` is a real transition at HEAD but absent from `--help` at both versions | `internal/issue/state.go:31`; `internal/cli/issue.go:324`; `git zhi issue edit --help` | `"reopen": done → reopened`; help string says `start, pause, resume, done, cancel` |
| `issue add --after/--before` not implemented; `issue edit --after/--block` are | `git zhi issue add --help`; `git zhi issue edit --help` | as the skills say |
| `git-zhi verify --dry-run` exists | `git zhi verify --help` | `--dry-run  list commands without executing them` |
| Unknown subcommand exits non-zero | `git zhi nonexistent --help` | exit 1 |
| `docs init` creates six dirs, writes only two files, both with `covers: []` and Go build text | `~/dev/git-zhi/internal/docs/scaffold.go:13-20,70-91,135-138` | `canonicalDirs` = plans, decisions, contributing, guides, architecture, reference; `livingDocs` = the two contributing files |
| Installed `git-zhi-docs` carries that scaffold verbatim | `strings ~/.local/bin/git-zhi-docs \| grep -c "go build"` | 2 |
| `docs check` fails in this repo: 8 unreachable files, 3 dead links (`architecture`, `guides`, `reference`) | `git zhi docs check` | exit 1, "11 issue(s) found" |
| `docs health` does not flag `covers: []` | `git zhi docs health` | "0 coverage gap(s)" with both live docs at `covers: []` |
| No capabilities manifest exists at either path the skills name | `ls ~/.claude/crochet/`; `ls .claude/crochet/` (main checkout and worktree) | none of the three exist |
| No git hooks installed | `ls ~/dev/crochet/.git/hooks \| grep -v sample` | empty |
| No `t/`, no `xt/` | `ls t xt` | both missing |
| README lists `crochet:preflight` as user-facing; no stub exists | `README.md:17`; `ls commands/` | 10 stubs, none for preflight |
| Refinement Step 0.5 counts four checks, then says three | `grep -n "three checks" skills/refinement/refinement.md` | line 39 |
| Execute Step 5 runs `make install` / `go build` | `grep -n "make install" skills/execute/execute.md` | line 237 |
| `skills/require-git-zhi.md` is referenced by nothing | `grep -rl require-git-zhi skills commands README.md` | only `CLAUDE.md:82` and the how-to plan |
| 16 of 22 skill files carry no ABOUTME lines | `for f in skills/*/*.md skills/*.md; do grep -q ABOUTME "$f" \|\| echo "$f"; done` | 16 files |

---

## Inventory of misalignments

Grouped by the RFC lens that catches them. Each entry names the file, the
claim, the evidence, the smallest fix, the enforcement rung it moves to (if it
moves), and a size: **S** one file, under twenty lines; **M** a section or two
to three files that carry one claim; **L** its own decision.

### Lens 1: documents asserting something never built (the RFC's table shape)

| # | Where | Asserts | Reality | Fix | Size |
|---|---|---|---|---|---|
| 1 | `postmortem.md` "## Feedback Loop" | refinement reads past postmortems via `milestone show` | zero mentions of postmortem/prior/lesson in `refinement.md` or any role prompt | delete the section (RFC Scope of Change; also an RFC AC line) | S |
| 2 | `postmortem.md:100` Output | `git zhi milestone edit <name> --postmortem <<'EOF'` stores the postmortem | installed binary: `unknown flag`; and even at HEAD the flag takes a value — the stdin form is `--postmortem -` | write `docs/postmortems/<milestone>.md` (the v0.4 precedent; RFC Migration allows either); attach only when `--help` lists the flag; fix the heredoc | S now, S again in Phase B |
| 3 | `execute.md:235-243` Step 5 | `make install` rebuilds "the binary" with `go build` ldflags | crochet has no Makefile and no Go; the paragraph is about git-zhi's own repo | delete the paragraph; the verification-before-completion branch already says "run the project test suite and build" | S |
| 4 | `README.md:17` | `crochet:preflight` is a user-facing skill | `preflight.md:10,144`: internal, no stub; `commands/preflight.md` absent | move to the internal-skills line | S |
| 5 | `CLAUDE.md:82` + `skills/require-git-zhi.md` | a shared prerequisite block that skills use | no include mechanism; no skill references it; each inlines its own variant | delete the file, correct the one sentence in `CLAUDE.md` in the same commit (a one-line touch across the scope boundary — RFC: "lands with whatever makes it true") | S — needs perigrin's OK, it removes a file |
| 6 | `install.md:59-97` Step 5 | seeds the capabilities manifest for preflight | writes `~/.claude/crochet/capabilities.json` in a flat schema; preflight reads `.claude/crochet/capabilities.json` in a `{last_updated, plugins:{…}}` schema; neither exists on this machine | delete install Step 5 — preflight already creates the manifest lazily ("Read or create"), and the RFC's discipline table calls the manifest self-maintaining for that reason | S — needs perigrin's OK |
| 7 | `execute.md:203-204`, `:276`; `how-to-use-git-zhi.md:42-51` | execute reopens with `--state reopen`; how-to lists the verbs as `start, pause, resume, done, cancel` and says `--help` wins | `reopen` is real at HEAD (`state.go:31`) but missing from the `--help` string at both versions; an agent obeying the how-to's rule would refuse a verb execute depends on | observe `reopen` on a throwaway issue in a scratch repo; if it works on the installed binary, add the `reopened` noun/`reopen` verb row to the how-to table with an "unlisted in `--help`" note; file a git-zhi issue for the help string | S |
| 8 | `refinement.md:39` | "If all three checks pass" | Step 0.5 enumerates four | "all four" | S |

### Lens 2: the inverse — a document asserting an absence that has since been filled

| # | Where | Asserts | Reality | Fix | Size |
|---|---|---|---|---|---|
| 9 | `architect-prompt.md` "Your Output", steps 5–6; `refinement.md:63-64` Step 2 | "the CLI has no setter for a milestone body or resolution command" — so the architect hands a context block to the orchestrator, the decomposer folds it into issue bodies, and the resolution command is surfaced as the final issue's AC | true of the installed binary, false at HEAD: `milestone add --due --body - --resolution '<cmd>'` is one call; `--state complete` then runs the resolution as Gate 2 | when the binary catches up: one `milestone add` with all three, delete the hand-off and the AC duplication (otherwise the resolution runs twice at completion — once as Gate 2, once inside verify) | M, **blocked** |
| 10 | `decomposer-prompt.md:13`, `sqe-prompt.md:15` | read "milestone context" from `git zhi milestone show` | nothing is on the milestone to read; the orchestrator carries it out of band | no edit — these become true when #9 lands | 0 |
| 11 | `architect-prompt.md:51` | "`milestone edit` only `--due`/`--name`/state flags" | installed help also lists `--resolve`, `--tag`, `--untag`; HEAD lists nine | folded into #9's rewrite; do not touch twice | 0 |
| 12 | `how-to-use-git-zhi.md:68,88` | milestone row `arg + flag`; "verified against git-zhi 0.4.0" | at HEAD three milestone flags read stdin via `-` — the exact asymmetry the skill exists to teach | after upgrade: add the `-` sentinel to the stdin convention, update the milestone row and the version line | S, **blocked** |

**Does #9 earn a row in the RFC's table?** Recommendation: no row, one
sentence. The table's shape is "asserted built, never built" and its remedy is
eviction or a rung-2 check. #9 is "asserted absent, since built", its remedy is
an upgrade that retires a workaround, and its root cause is version skew
between plugin and binary — which is precisely the RFC's first argument under
"Compiler, not runtime". It is the best evidence that section has, and it is
evidence for an argument the RFC already makes rather than a tenth instance of
the problem it diagnoses. Note also that the RFC's `t/` test as written
("every `git zhi` subcommand named in `skills/` answers `--help`") would not
have caught it: `milestone edit --help` exits 0 at both versions. The check
that catches skew is flag-level — `git zhi milestone edit --help | grep -q --
--postmortem` — which is a refinement the repo-layer `t/` plan should take. The
RFC is not edited by this plan.

One more consequence of the skew: the RFC's "What Is Already True" row *Each
milestone carries a resolution command that gates completion* is true at HEAD
and unreachable on the installed binary (nothing can set the field). The
architect's final-issue-AC workaround is what makes it true today, through
verify rather than Gate 2. It is the right workaround for 0.4.0 and the wrong
one after.

### Lens 3: two skills that disagree with each other

| # | Where | Disagreement | Fix | Size |
|---|---|---|---|---|
| 13 | `postmortem.md:12` vs `execute.md:224-247` | postmortem: "invoked before `--state complete`"; execute: runs `--state complete`, then says to verify "before marking the milestone complete", then `make install`, then `/postmortem` | reorder execute Step 5: verification → `/postmortem <milestone>` → `--state complete`. In Phase B the last two collapse into one call (see #16) | S |
| 14 | `execute.md:6-12` Prerequisites | wraps `crochet:preflight` in the "If available / Otherwise" pattern | preflight is a sibling skill in the same plugin; the pattern exists for superpowers/paad (`preflight.md:128-140`) — the conditional can never be false | match `assess.md:8`: run preflight unconditionally | S |
| 15 | `refinement.md:6-8` and `:26-28` | inlines a `which git-zhi` prerequisite *and* invokes preflight, whose check 1 is `which git-zhi` | leave it; harmless duplication, and removing it would contradict `CLAUDE.md`'s convention sentence, which is a repo-layer edit | 0 |

### Lens 4: the enforcement ladder

Rules stated in prose that must hold strictly, and whether they can move down.
Only the ones where it pays.

| # | Rule | Rung today | Move | Size |
|---|---|---|---|---|
| 16 | "The postmortem is mandatory at milestone completion" (`postmortem.md:8`, `execute.md:245`) | 3, in two files | **1** — at HEAD, `milestone edit <name> --postmortem - --state complete` is one operation that writes both sides (source comment, `milestone_edit.go:56-58`). Give postmortem the close: execute Step 5 hands off, postmortem issues the one command. A human can still close by hand; the crochet path cannot skip the retrospective | S, **blocked** for the attach; the reordering (#13) is not |
| 17 | "an accepted decision nobody built is visible" (RFC plugin item) | absent | **2 for the fact, then a question for the residue.** Postmortem already runs at completion. For each `docs/decisions/*.md` with `state: accepted`, `git log --grep='^Implements: NNNN' --oneline \| grep -q .` is deterministic and needs no milestone body. What it cannot do is tell "nobody built it" from "built, trailer forgotten" — so the miss becomes a question to the human (*abandoned, or unlabelled?*), never a written state. Not blocked on the binary | S, **contingent on acceptance** |
| 18 | "the SQE agent never sees implementation code" (`sqe-prompt.md:82`, `refinement.md:140`) | 3 | none available — subagent tool restriction cannot scope by path. Stays prose | 0 |
| 19 | "Max 3 reopen cycles", "max 10 iterations" (`execute.md`) | 3 | none without state the agent keeps; stays prose | 0 |
| 20 | AC-executability contract (four files) | 3 + rung 2 via `verify` | the RFC says the next move is into git-zhi's dry-run output and does not propose it; leave | 0 |
| 21 | "All chain interaction through `git zhi`; never `refs/zhi/` directly" (five skills, `CLAUDE.md`) | 3 and 4 | **2**, repo-layer: an `xt/` grep over `skills/` for `update-ref`, `for-each-ref .*refs/zhi`, `.git/refs/zhi`. It would fire today on `onboard.md:26,51` and `procedure.md:19,77` (see #26) | S, repo layer — handed to the `xt/` plan, not done here |
| 22 | "add a skill: create the stub, update the README table" (`CLAUDE.md` checklist) | 4 | **2**, repo-layer: `xt/` test that every `commands/*.md` names an existing skill and every README table row has a stub. Would have caught #4 | S, repo layer — handed to the `xt/` plan |
| 23 | Skill depends on a flag the installed binary lacks | 3 (preflight's advisory version warning) | already 2 by accident: cobra fails with `unknown flag: --postmortem`, naming the flag — the RFC's "documentation inside the error message". Keep; bump `plugin.json` `git_zhi_min_version` in Phase B so preflight warns up front | S, **blocked** |

**Which of these are actually mechanizable.** The RFC's retraction of the
`commit-msg` hook is the precedent: a hook that fires on the wrong thing is
worse than prose, and the honest move for a rule a machine cannot judge is a
question to a human at the moment they can answer. Sorting the rows by that
test:

- *Mechanizable, and this plan moves them:* #16 (one operation writes both
  sides — the machine does not judge anything, it just cannot do half); #17's
  query half (a grep over commit messages is a fact); #23 (an unknown flag is
  a fact).
- *Mechanizable, handed to the repo layer:* #21 and #22 are greps over
  `skills/` and `README.md` for shapes that are either present or not.
- *Not mechanizable — stays prose, no guardrail proposed:* #18 ("never reads
  implementation code") is a rule about what an agent *looked at*, and no
  check recovers that after the fact; #19 (iteration and reopen caps) needs a
  count the agent keeps in its own context; #17's residue (abandoned versus
  unlabelled) is exactly the RFC's example — only the author knows intent.
  Proposing hooks for any of these would repeat the mistake the RFC just
  corrected. #20 is mechanizable but on git-zhi's side, and not proposed.

### Lens 5: "Compiler, not runtime" — onboard Step 2 and refinement Step 1

Both run `git zhi docs init`. Read against the scaffold source, that command:

1. Creates six directories and writes files into one. Git does not track
   empty directories, so `guides`, `architecture` and `reference` vanish on the
   first clone or worktree, and the three Short Links pointing at them become
   dead. **`docs check` passes immediately after `docs init` and fails after
   the first clone.** This worktree is the proof: 3 dead links, exactly those
   three. `onboard.md:37` ("Verify: `git zhi docs check` passes") is true for
   the minute between init and commit.
2. Writes `docs/contributing/development-workflow.md` with `Install Go 1.24+`
   and `go build -o git-zhi ./cmd/git-zhi/` — git-zhi's own workflow, verbatim,
   into every repo it onboards. That is instance four in the RFC's table, and
   crochet's onboarding will reproduce it on the next repo.
3. Writes both live docs with `covers: []`, which `docs health` does not flag
   (observed: "0 coverage gap(s)"), so the techwriter's covers-driven step never
   fires (RFC, Problem Statement).

Against the RFC's testable form — *a repo crochet onboarded should still pass
its own checks with crochet uninstalled* — an onboarded repo today has exactly
one check, `docs check`, which needs git-zhi rather than crochet and so passes
the letter of the test; and it fails that one check as soon as it is cloned.
The repo owns no test that its guardrails fire, because it has no guardrails:
the AC gate lives in the chain, and the chain is ephemeral.

Two of the three are git-zhi's to fix upstream (the scaffold should not name a
toolchain it cannot see, and should not create directories the index will
drop). Both get a git-zhi issue from this plan. Crochet-side, the smallest
change that stops instance four recurring on the installed binary:

| # | Where | Fix | Size |
|---|---|---|---|
| 24 | `onboard.md` Step 2, `procedure.md` Step 2, `refinement.md` Step 1.1 | after `docs init`: (a) remove Short Links whose target directory is empty — the RFC's own rule, "exist when something lives in them, not before"; `docs init` is idempotent on the heading, so the pruned list survives re-runs; (b) read the two scaffolded contributing docs and replace any build/test text naming a toolchain the repo does not have with the repo's real commands (an agent can see `go.mod`, `cpanfile`, `package.json`; the scaffold cannot); (c) commit, then run `docs check` — verify after the commit, not before it | M, **not blocked, not contingent** — it is fixing a claim that is false on every non-Go repo |
| 25 | `onboard.md` Step 2, `refinement.md` Step 1 | install an `xt/` runner alongside `docs init`, "fitted to the repo's ecosystem" (RFC plugin item; the `commit-msg` hook that used to accompany it was dropped at `ef36c64` and is not planned) | **L — its own decision.** Scoped below; not designed here |

What decision #25 must settle before any skill text is written: how the
ecosystem is detected and what "fitted" means per ecosystem; where the pattern
lives in the plugin and how the instance is copied out (the RFC's copy-drift
trade); what the runner checks at minimum (the RFC lists four for crochet
itself); what the runner prints when a check fails (a guardrail that rejects
silently makes an agent flail — RFC, ladder section — and the hook's death
shows the runner must only check facts, never intent); how "idempotent re-onboarding is the
repair" behaves when a repo's copy has diverged; and how the constraint is
tested — the literal test is running `sh xt/run.sh` from a shell with the
plugin uninstalled. The RFC says this item is "numbered separately when taken
up"; this plan agrees and stops here.

### Lens 6: found on the way, not RFC-driven

| # | Where | What | Disposition |
|---|---|---|---|
| 26 | `onboard.md:26,51`; `procedure.md:19,77` | reads `.git/refs/zhi/` and deletes issue refs with `for-each-ref … update-ref -d` — direct refs access, against the repo's own convention | **not fixed here.** There is no `git zhi` bulk-delete (`issue edit --purge --yes` is per issue). File a git-zhi issue (`historian --reset` or equivalent); the `xt/` grep in #21 keeps it visible |
| 27 | 16 skill files | no ABOUTME lines; global CLAUDE.md requires them on all code files; the RFC records that the placement ruling was never made | **blocked on the ruling** (repo-layer, `coding-conventions.md`). Once ruled: one mechanical commit, two lines per file, in the ruled position | S, blocked on a decision |
| 28 | `techwriter-prompt.md:38,116` | creates "ADRs" in `docs/decisions/` by next sequential number | contingent on the RFC: the series has six required frontmatter fields, required sections, and `state: proposed` on entry; the issue the techwriter creates should carry that shape as its AC. Vocabulary: the RFC dissolves the ADR/RFC/PRD distinction — "decision" | S, **contingent** |
| 29 | `refinement.md:48-49` Step 1.2–1.3 | creates `CLAUDE.md` "pointing to" `CONTRIBUTING.md`; checks the reference on later runs | contingent on the RFC: the door is an `@CONTRIBUTING.md` import, not a bare mention ("static linking" vs "a dynamic lookup that may not happen"). Check becomes `grep -q '^@CONTRIBUTING.md' CLAUDE.md` | S, **contingent** |
| 30 | `refinement.md:20` | example spec path `docs/plans/2026-03-15-parser-design.md` | contingent: `docs/decisions/NNNN-….md` is the ordinary entry in this repo; consumers keep their own layout. Cosmetic; fold into #29's commit | 0 |

---

## Ordering

```
Phase A (now)             Phase B (binary ≥ HEAD 04fbcd9)      Phase C (RFC accepted)
─────────────             ───────────────────────────────      ──────────────────────
A1 #1  feedback loop
A2 #2,#13 postmortem ─────────► B2 #16 one-call close
A3 #3,#14 execute      ─────────► (B2 edits Step 5 again)
A4 #4  README
A5 #8  refinement count
A6 #6  install Step 5   (needs OK)
A7 #5  require-git-zhi  (needs OK)
A8 #24 docs init fit
A9 #7  reopen observe
                          B0 gate + min_version (#23)
                          B1 #9,#10,#11 architect/refinement
                          B3 #12 how-to-use-git-zhi
                                                              C1 #17 unlabelled-or-abandoned question
                                                              C2 #29,#30 @import door
                                                              C3 #28 decision-shaped issues
                                                              C4 #25 ── own decision, not here
                                                              C5 #27 ── after ABOUTME ruling
```

Phase A tasks are independent of each other and of the RFC; do A1 and A2
first because `postmortem.md` is the most-wrong file and A1 is an RFC AC.
Phase B is one gate and three commits; B1 is the one where a single upgrade
retires five documents' worth of workaround (`architect-prompt.md`,
`refinement.md` Step 2, the `decomposer` and `sqe` input lists, and the
how-to's milestone row). Phase C waits on acceptance; C1 is the only Phase C
item that is neither blocked on the binary nor on a further decision.

**Blocked on the git-zhi upgrade:** B0–B3 (#9, #10, #11, #12, #16 attach,
#23). **Blocked on a decision:** C4 (#25), C5 (#27). **Blocked on RFC
acceptance:** C1–C3 (#17, #28, #29, #30). **Nothing else is blocked.**

---

## File Structure

- **Modify:** `skills/postmortem/postmortem.md` (A1, A2, B2, C1)
- **Modify:** `skills/execute/execute.md` (A3, B2)
- **Modify:** `README.md` (A4)
- **Modify:** `skills/refinement/refinement.md` (A5, A8, B1, C2)
- **Modify:** `skills/install/install.md` (A6)
- **Delete:** `skills/require-git-zhi.md`; **modify** one line of `CLAUDE.md` (A7)
- **Modify:** `skills/onboard/onboard.md`, `skills/onboard/procedure.md` (A8)
- **Modify:** `skills/how-to-use-git-zhi/how-to-use-git-zhi.md` (A9, B3)
- **Modify:** `.claude-plugin/plugin.json` (B0)
- **Modify:** `skills/refinement/architect-prompt.md` (B1)
- **Modify:** `skills/refinement/techwriter-prompt.md` (C3)
- **Not touched:** the RFC; every role prompt not named above; `commands/`
  (no stub is added or removed — preflight stays internal).

---

## Phase A — unblocked

### Task A1: Remove the Feedback Loop claim (#1)

**Files:** `skills/postmortem/postmortem.md`

- [ ] **Step 1 (observe):** `grep -rn -i 'postmortem\|prior milestone\|lesson' skills/refinement/` — expect no hits that read a past postmortem. Record the output.
- [ ] **Step 2 (document):** delete lines 121–123 (`## Feedback Loop` through its paragraph). Leave line 93 ("specific enough that a future `crochet:refinement` run can act on it") — it is a quality bar on the recommendation, not a claim that a mechanism exists, and it is not provably false.
- [ ] **Step 3 (verify):** `! grep -q '^## Feedback Loop' skills/postmortem/postmortem.md` (this is RFC 0001's own AC line).
- [ ] **Step 4:** commit: `Remove postmortem Feedback Loop section; nothing implements it`.

### Task A2: Make the postmortem durable on the installed binary (#2, #13)

**Files:** `skills/postmortem/postmortem.md`

- [ ] **Step 1 (observe):** `git zhi milestone edit --help | grep -c -- --postmortem` → `0`. `git zhi milestone edit x --postmortem - --help` → `unknown flag`. Read `~/dev/git-zhi/internal/cli/milestone_edit.go:242-252` and confirm `-` is the stdin sentinel at HEAD.
- [ ] **Step 2 (document):** rewrite "## Output": write the document to `docs/postmortems/<milestone>.md` (name it the way `docs/postmortems/v0.4-superpowers-paad-integration.md` is named); then: *if `git zhi milestone edit --help` lists `--postmortem`, also attach it with `git zhi milestone edit <name> --postmortem - <<'EOF' … EOF`* — the `-` is the stdin form; the flag takes a value. Keep the four-section body. Keep the Trigger's "invoked before `--state complete`" as is; A3 makes execute agree with it.
- [ ] **Step 3 (verify):** re-read the section against the `--help` output from Step 1: the unconditional branch must use no flag the installed binary lacks. `grep -n "postmortem -" skills/postmortem/postmortem.md` shows the stdin sentinel.
- [ ] **Step 4:** commit: `Write the postmortem to docs/postmortems; attach only when the flag exists`.

### Task A3: Fix execute Step 5 ordering, drop the Go rebuild, unwrap preflight (#3, #13, #14)

**Files:** `skills/execute/execute.md`

- [ ] **Step 1 (observe):** `ls Makefile go.mod 2>&1` → both missing. `sed -n 219,248p skills/execute/execute.md` — note the order: `--state complete`, then "verify before marking complete", then `make install`, then `/postmortem`.
- [ ] **Step 2 (document):** Step 5 becomes: verification (the existing If/Otherwise block, unchanged) → `/postmortem <milestone>` → `git zhi milestone edit <milestone> --state complete`. Delete the `make install` paragraph (lines 235–243) entirely; it describes git-zhi's repo. Prerequisites: replace the If/Otherwise block with the one sentence `assess.md:8` uses. Do not touch the Integration list or Key Constraints.
- [ ] **Step 3 (verify):** `! grep -q 'make install' skills/execute/execute.md`; `! grep -q 'If .crochet:preflight. is available' skills/execute/execute.md`; the three Step 5 actions appear in the order verification, postmortem, complete (`grep -n 'verification-before-completion\|/postmortem\|--state complete' skills/execute/execute.md`). Confirm every remaining `**If … is available**` in the file still has its `**Otherwise:**` (`grep -c '^\*\*If' … == grep -c '^\*\*Otherwise' …`).
- [ ] **Step 4:** commit: `Order execute completion as verify, postmortem, complete; drop make install`.

### Task A4: README lists preflight as internal (#4)

**Files:** `README.md`

- [ ] **Step 1 (observe):** `ls commands/ | grep -c preflight` → `0`; `sed -n 10p skills/preflight/preflight.md` says internal.
- [ ] **Step 2 (document):** delete the `crochet:preflight` row from the Skills table; add `crochet:preflight` to the internal-skills sentence on line 23.
- [ ] **Step 3 (verify):** `grep -q 'internal skills.*crochet:preflight' README.md && ! grep -q '^| .crochet:preflight' README.md`. Every remaining table row has a stub: `for s in $(grep -o 'crochet:[a-z-]*' README.md | sed -n '1,/internal/p' | sort -u | cut -d: -f2); do test -f commands/$s.md || echo "no stub: $s"; done` prints nothing (this is the #22 check, run by hand until `xt/` exists).
- [ ] **Step 4:** commit: `List preflight among internal skills; it has no command stub`.

### Task A5: "all four checks" (#8)

**Files:** `skills/refinement/refinement.md`

- [ ] **Step 1 (observe):** `sed -n 32,39p skills/refinement/refinement.md` — four numbered items, then "all three".
- [ ] **Step 2 (document):** "If all four checks pass cleanly".
- [ ] **Step 3 (verify):** `grep -c 'all four checks' skills/refinement/refinement.md` → `1`; `! grep -q 'all three' skills/refinement/refinement.md`.
- [ ] **Step 4:** commit: `Count the four pipeline-readiness checks as four`.

### Task A6: Remove install's manifest seeding (#6) — needs perigrin's OK

**Files:** `skills/install/install.md`

- [ ] **Step 0:** confirm with perigrin. This removes a documented step. The alternative — rewriting install Step 5 to preflight's path and schema — is addition where the RFC prefers eviction, and preflight's "Read or create" already covers first run.
- [ ] **Step 1 (observe):** `ls ~/.claude/crochet/ .claude/crochet/ 2>&1` — neither exists. `diff <(sed -n 79,93p skills/install/install.md) <(sed -n 34,60p skills/preflight/preflight.md)` — different shapes.
- [ ] **Step 2 (document):** delete Step 5 and the ABOUTME clause "and seeding the plugin manifest" (it becomes false; the second ABOUTME line likewise). Leave the 2026-03-28 design doc alone — it is archive.
- [ ] **Step 3 (verify):** `! grep -q 'capabilities' skills/install/install.md`; `grep -c 'Read or create' skills/preflight/preflight.md` → `1` (the creation path still exists).
- [ ] **Step 4:** commit: `Drop install manifest seeding; preflight creates the manifest it reads`.

### Task A7: Delete the unreferenced shared block (#5) — needs perigrin's OK

**Files:** `skills/require-git-zhi.md` (delete), `CLAUDE.md:82` (one line)

- [ ] **Step 0:** confirm with perigrin. Deleting a file, and a one-line touch on `CLAUDE.md`, which is otherwise the repo layer's. The two must land together: deleting the file while `CLAUDE.md` names it is the table's failure shape.
- [ ] **Step 1 (observe):** `grep -rn 'require-git-zhi' --include='*.md' . | grep -v docs/plans` → only `CLAUDE.md:82`.
- [ ] **Step 2 (document):** `git rm skills/require-git-zhi.md`. Replace the `CLAUDE.md` sentence with what is true: each skill inlines its prerequisite, or invokes `crochet:preflight`, whose first check is `which git-zhi`.
- [ ] **Step 3 (verify):** `! test -f skills/require-git-zhi.md`; `! grep -q 'require-git-zhi' CLAUDE.md`.
- [ ] **Step 4:** commit: `Remove require-git-zhi.md; no skill includes it`.

### Task A8: Fit the scaffold to the repo after `docs init` (#24)

**Files:** `skills/onboard/onboard.md`, `skills/onboard/procedure.md`, `skills/refinement/refinement.md`

- [ ] **Step 1 (observe, in a scratch repo):** under `$CLAUDE_JOB_DIR/tmp`: `git init scratch && cd scratch && git commit --allow-empty -m init && git zhi docs init && git zhi docs check; echo "before commit: $?"` → 0. Then `git add -A && git commit -m scaffold && git clone -q . ../clone && (cd ../clone && git zhi docs check; echo "after clone: $?")` → 1, with dead links to `guides`, `architecture`, `reference`. `grep -c 'go build' docs/contributing/development-workflow.md` → 2 in a repo with no Go. Record both.
- [ ] **Step 2 (document):** in all three places, after `docs init` add: (a) delete each Short Links line whose directory has no files; (b) read `docs/contributing/*.md` and replace any setup/build/deploy text naming a toolchain the repo lacks with the repo's own commands, keeping the section headings; (c) `git add docs CONTRIBUTING.md && git commit`, *then* `git zhi docs check`. Onboard's **Verify** line moves after the commit. Keep the Rollback line. In `procedure.md` show the shell for (a) as a one-liner so a human can run it.
- [ ] **Step 3 (verify):** repeat Step 1 following the new text in a fresh scratch repo: `docs check` exits 0 in the clone; `! grep -rq 'go build' docs/contributing`. Re-run the procedure on the same repo: no changes (`git status --porcelain` empty) — idempotent.
- [ ] **Step 4:** file two git-zhi issues: scaffold writes git-zhi's Go workflow into every repo; scaffold creates directories the index drops, so `docs check` fails after clone. Reference this plan.
- [ ] **Step 5:** commit: `Fit docs init scaffold to the repo before verifying it`.

### Task A9: Observe `reopen` (#7)

**Files:** `skills/how-to-use-git-zhi/how-to-use-git-zhi.md`

- [ ] **Step 1 (observe, scratch repo only — never the live chain):** in the scratch repo: `REF=$(git zhi issue add "scratch" --body x --format json | python3 -c 'import json,sys;print(json.load(sys.stdin)[0]["id"])')`; `--state start`; `--state done --force`; then `git zhi issue edit "$REF" --state reopen; echo "exit=$?"`; `git zhi issue show "$REF" --format json | python3 -c 'import json,sys;print(json.load(sys.stdin)["state"])'`. Record the noun. Then `--state start` and confirm `in-progress`.
- [ ] **Step 2 (document):** if reopen worked: add a `reopened` row (reached by `reopen` from `done`; advanced by `start`) and extend the verb list with `reopen`, noting it is absent from `--help` at both versions (`~/dev/git-zhi/internal/cli/issue.go:324`) — the one case where the source, not `--help`, is the reference. If it failed on the installed binary: instead edit `execute.md` Step 4 to say the reopen path needs a binary newer than 0.4.0, and move this item to Phase B.
- [ ] **Step 3 (verify):** the table row matches the observed noun exactly. `rm -rf` the scratch repo.
- [ ] **Step 4:** file a git-zhi issue: `--state` help string omits `reopen`. Commit: `Document the reopen transition observed on the installed binary`.

---

## Phase B — blocked on the installed binary reaching source HEAD

### Task B0: Gate and version floor (#23)

**Files:** `.claude-plugin/plugin.json`

- [ ] **Step 1 (observe):** `git zhi milestone edit --help | grep -q -- --postmortem && git zhi milestone add --help | grep -q -- --resolution` — until this passes, Phase B does not start. Record `git zhi version | head -1`.
- [ ] **Step 2 (document):** set `git_zhi_min_version` to the semver Step 1 printed. Do not guess a number before the release exists.
- [ ] **Step 3 (verify):** `python3 -c 'import json;print(json.load(open(".claude-plugin/plugin.json"))["git_zhi_min_version"])'` equals the installed semver; preflight's warning branch (`preflight.md:16-18`) reads it.
- [ ] **Step 4:** commit: `Require the git-zhi that stores milestone body, resolution and postmortem`.

### Task B1: Store the milestone body and resolution on the milestone (#9, #10, #11)

**Files:** `skills/refinement/architect-prompt.md`, `skills/refinement/refinement.md`

- [ ] **Step 1 (observe, scratch repo):** `printf '## Context\nx\n' | git zhi milestone add m1 --due 2027-01-01 --resolution 'true' --body -` then `git zhi milestone show m1 --format json` — confirm `body` and `resolution` fields are populated and name the keys. Then `git zhi milestone edit m1 --resolve; echo $?` → 0.
- [ ] **Step 2 (document):** `architect-prompt.md`: "Your Output" becomes "a single milestone with body and resolution command"; step 5 drops "the CLI cannot store it … final issue's acceptance criterion"; step 6 becomes the one `milestone add … --resolution '<cmd>' --body -` call with the body on stdin; delete the "only `--due` … no flag, stdin, or `$EDITOR` path" sentence (provably false: `milestone_add.go:46-76`). `refinement.md` Step 2 "Produces": body and resolution stored on the milestone; delete the context-block bullet and its "(only `--due` is accepted)". Step 3's "Reads: the milestone just created" is now true. Do not touch `decomposer-prompt.md` or `sqe-prompt.md` — their inputs become true without edits.
- [ ] **Step 3 (verify):** `! grep -rq 'no setter\|cannot store\|only .--due' skills/refinement/`; the resolution appears once in the architect's output and nowhere as a duplicated final-issue AC (`! grep -q 'final issue' skills/refinement/architect-prompt.md`). Walk the four role prompts in order in the scratch repo and confirm the decomposer can read `milestone show` for context.
- [ ] **Step 4:** commit: `Store milestone body and resolution via milestone add; retire the context-block hand-off`.

### Task B2: One operation closes the milestone with its postmortem (#16)

**Files:** `skills/postmortem/postmortem.md`, `skills/execute/execute.md`

- [ ] **Step 1 (observe, scratch repo):** on a milestone whose issues are all done: `printf '# PM\n' | git zhi milestone edit m1 --postmortem - --state complete`; then `git zhi milestone show m1 --format json` — confirm `state` is `completed` and the postmortem is present. Then observe the failure case the source designs for: on a milestone with an open issue, the same command reports `postmortem attached` and then fails Gate 1 — and `milestone show` still has the postmortem.
- [ ] **Step 2 (document):** `postmortem.md` Output: keep writing `docs/postmortems/<milestone>.md` (archive; survives a lost ref), then the one call `git zhi milestone edit <name> --postmortem - --state complete <<'EOF'`. Trigger: postmortem now performs the completion. `execute.md` Step 5: verification → `/postmortem <milestone>`; delete the separate `--state complete` line and say postmortem closes the milestone.
- [ ] **Step 3 (verify):** `grep -c -- '--state complete' skills/execute/execute.md` → `0` in Step 5 (Key Constraints may still mention it); `grep -c -- '--postmortem - --state complete' skills/postmortem/postmortem.md` → `1`. Idempotency: re-running postmortem on a completed milestone must not fail — observe `milestone edit m1 --postmortem -` on a completed milestone in the scratch repo and document whichever way it goes.
- [ ] **Step 4:** commit: `Close the milestone from the postmortem in one milestone edit`.

### Task B3: Teach the how-to the `-` sentinel (#12)

**Files:** `skills/how-to-use-git-zhi/how-to-use-git-zhi.md`

- [ ] **Step 1 (observe):** `git zhi milestone add --help`, `git zhi milestone edit --help` — capture the three text flags and their `-`/`none` semantics.
- [ ] **Step 2 (document):** stdin convention: add that `milestone add|edit --body -`, `--resolution -`, `--postmortem -` read stdin, that only one of them may per call, and `none` clears `--resolution`. Intent table: split the milestone row so the stdin forms are visible. Update "verified against git-zhi 0.4.0" to the version from B0.
- [ ] **Step 3 (verify):** every flag named in the new rows appears in the captured `--help`; the version string matches `git zhi version`.
- [ ] **Step 4:** commit: `Document milestone stdin flags in how-to-use-git-zhi`.

---

## Phase C — contingent on RFC 0001 being `accepted`

### Task C1: Postmortem asks about accepted decisions with no implementing commit (#17)

**Files:** `skills/postmortem/postmortem.md`

The RFC at `ef36c64`: a query, then a question — never a written state. The
query is a fact; the residue (nobody built it, or somebody built it and forgot
the trailer) is unclosable by machine, so it is asked of the human at the one
moment they can answer. The RFC's Open Questions leaves the interruption
design open. What this plan would do, stated as a recommendation:

- The postmortem is already the milestone's retrospective, so the question
  lives in its text — a *Decisions without implementing commits* list under
  "What puzzles us?", one line per decision: number, title, the `git log`
  command that came back empty, and the two readings.
- Whether it also *stops* follows the switch execute already has
  (`execute.md`, Key Constraints: pause between issues by default, `--auto`
  runs without pauses). Interactive: ask, and if the answer is "unlabelled",
  tell the human which commits to amend or which follow-up commit to make with
  the trailer — the skill does not amend history itself. `--auto`: never block;
  the list in the postmortem text and in execute's completion report is the
  whole output, exit 0. The RFC says the question's worth is only knowable
  after the series has entries; an unattended run producing a list is how
  that evidence gets collected without the run failing on it.
- Nothing is written to any `docs/decisions/*.md` in either mode.

- [ ] **Step 1 (observe, scratch repo):** create `docs/decisions/0001-x.md` with `state: accepted`; commit once with trailer `Implements: 0001`; `git log --grep='^Implements: 0001' --oneline | grep -q . ; echo $?` → 0. Create `0002-y.md` `accepted` with no such commit → 1. Confirm the search is over the current branch only: create the trailer commit on a side branch for `0002` and confirm the query on the main branch still misses (unreachable is "never happened", per the RFC).
- [ ] **Step 2 (document):** add a step between Data Gathering and Output: for every `docs/decisions/*.md` with `state: accepted`, run the grep; every miss goes into the puzzles list as above; then the interactive/`--auto` behaviour as above. State explicitly that the step edits no decision file.
- [ ] **Step 3 (verify):** in the scratch repo, walk the step: `0002-y.md` is named in the postmortem text with the empty query shown; `0001-x.md` is not; `git status --porcelain docs/decisions` is empty afterwards. Walk it again: same list, no drift (idempotent — the query is pure).
- [ ] **Step 4:** commit: `Ask about accepted decisions with no implementing commit at milestone completion`.

### Task C2: The agent's door is an import (#29, #30)

**Files:** `skills/refinement/refinement.md`

- [ ] **Step 1 (observe):** `sed -n 45,49p skills/refinement/refinement.md`; `grep -n '^@' CLAUDE.md` (what the RFC's own AC expects: `@docs/…` lines).
- [ ] **Step 2 (document):** Step 1.2: create `CLAUDE.md` whose first non-comment line is `@CONTRIBUTING.md`. Step 1.3: check `grep -q '^@CONTRIBUTING.md' CLAUDE.md`; propose the line if absent. Input example path → `docs/decisions/0002-parser.md`.
- [ ] **Step 3 (verify):** scratch repo: run Step 1 twice; second run proposes nothing.
- [ ] **Step 4:** commit: `Create CLAUDE.md as an @import of CONTRIBUTING.md`.

### Task C3: Techwriter issues produce decision-shaped entries (#28)

**Files:** `skills/refinement/techwriter-prompt.md`

- [ ] **Step 1 (observe):** `sed -n 1,8p docs/decisions/0001-documentation-architecture.md` — the six fields.
- [ ] **Step 2 (document):** where the prompt says "ADRs", say decisions in `docs/decisions/`; the standalone issue's AC gains one paren-wrapped check per required field, e.g. `` (`grep -q '^state: proposed' docs/decisions/NNNN-*.md`) ``, and `git zhi docs check` stays. Keep the numbering constraint.
- [ ] **Step 3 (verify):** `git-zhi verify <m> --dry-run` in the scratch repo lists each new AC as a runnable command (the chain-review Step 2.5 check).
- [ ] **Step 4:** commit: `Shape techwriter decision issues to the decision-series frontmatter`.

### Task C4: Onboard installs the guardrails (#25) — own decision

- [ ] **Step 1:** write `docs/decisions/000N-onboard-installs-guardrails.md` answering the questions listed under Lens 5. Do not edit `onboard.md` or `refinement.md` for this until that entry is `accepted`.

### Task C5: ABOUTME on the sixteen skill files (#27) — after the ruling

- [ ] **Step 1:** once `docs/contributing/coding-conventions.md` carries the placement ruling, one commit adds two lines per file in the ruled position. Verify: `for f in skills/*/*.md; do grep -q ABOUTME "$f" || echo "$f"; done` prints nothing.

---

## What this plan does not do, and why

- **Build the feedback loop.** Deleting the claim is the fix (RFC: eviction
  over addition; the parked design says the literal contract is the wrong
  shape). What replaces it is a separate decision.
- **Rewrite the architect against HEAD before the binary ships.** That would
  make the skill false against the installed binary — the exact failure this
  plan is removing. Phase B waits for the observation.
- **Make install's manifest match preflight's.** Eviction beats making a second
  writer agree with the first.
- **Add an include mechanism** for the shared prerequisite block, or
  standardize the ten inline variants. The format has no include; the
  variants are harmless; the deterministic check (`which git-zhi`) already
  runs inside preflight for every skill that invokes it.
- **Write `state: accepted` from chain-review or execute.** Who accepts is an
  RFC Open Question.
- **Design the `xt/` runner or the ecosystem fit.** The RFC numbers that
  separately; Lens 5 scopes what the decision must settle.
- **Install any git hook, or propose one for an unmechanizable rule.** The
  RFC withdrew the `commit-msg` hook because a hook cannot recover intent the
  author did not state; the same reasoning rules out hooks for #17's residue,
  #18 and #19. Where the machine cannot judge, the skill asks.
- **Write `state: implemented` or `state: abandoned` anywhere.** At `ef36c64`
  those are queries over trailers, not fields; writing them would give "was
  this built" two sources.
- **Move the AC-executability contract out of the four prompts.** The RFC says
  the next rung is git-zhi's dry-run output and does not propose it.
- **Fix onboard's direct `refs/zhi/` access.** There is no CLI equivalent to
  move it to; it gets a git-zhi issue and an `xt/` grep, not a rewrite.
- **Retrofit `state:` onto `docs/plans/`.** The RFC's Migration section
  grandfathers them.
- **Detect CLI flags in the capabilities manifest.** The manifest records
  plugin skills; `--help` is the source of truth for the binary, and cobra's
  unknown-flag error already fails loudly with the flag's name.
- **Edit the RFC**, including adding the version-skew row argued against above.

## Repo-layer items surfaced here, handed off

For whoever writes the `t/` and `xt/` plan (RFC Scope of Change):

- `t/`: test flags, not only subcommands — `git zhi milestone edit --help |
  grep -q -- --postmortem` is the check that would have caught #9.
- `xt/`: README table ↔ `commands/` symmetry (#22); no `refs/zhi` direct
  access in `skills/` (#21); every user-facing skill has a prerequisite or
  invokes preflight.
- git-zhi issues to file: scaffold writes Go text (A8); scaffold creates
  directories the index drops (A8); `--state` help omits `reopen` (A9); no
  bulk purge for historian rollback (#26).

## Placement of this plan

RFC 0001's Migration section says `docs/plans/` receives no new files and that
`-plan.md` files are the artifact refinement replaces. This is a new
`-plan.md`, and by the RFC's inclusion gate it is interface-shaped (it edits
the README skills table and removes a file from `skills/`), so under the RFC it
would be a decision.

Three options: become `docs/decisions/0002-…`; become a chain via
`crochet:refinement`; stay as written.

**Recommendation: stay as written, and do not promote it later.** The RFC is
not accepted, so the rule that forbids this file is not in force; a plan is
the honest name for pre-acceptance analysis, and the format was asked for.
Numbering it 0002 now would put a second entry in a series whose first entry
may be declined — and the RFC's own Mutability rule at `ef36c64` says
"reaching for a new number while a proposal is still open is the wrong
instrument"; a revision to 0001 in flight is the lifecycle, a new number is not. Making it a chain now would run refinement on a spec that is
still `proposed`. When 0001 is accepted, the right move is not to convert this
file but to run the pipeline on 0001 itself — `crochet:assess` then
`crochet:refinement` — with this plan as the architect's and decomposer's
input; its tasks are sized to lift into issues one to one, and each carries
its verification as a paren-wrapped AC would. The plugin items then get the
decision number the RFC already promises them, and this file stays where it
is: frozen, cited by path, the last of its kind.

---

## Acceptance Criteria (Phase A; the phase that can be judged now)

- [ ] postmortem no longer asserts the unbuilt loop (`! grep -q '^## Feedback Loop' skills/postmortem/postmortem.md`)
- [ ] postmortem's unconditional path uses no flag the installed binary lacks (`grep -q 'docs/postmortems/' skills/postmortem/postmortem.md`)
- [ ] execute no longer rebuilds a Go binary (`! grep -q 'make install' skills/execute/execute.md`)
- [ ] execute runs preflight unconditionally (`! grep -q 'If .crochet:preflight. is available' skills/execute/execute.md`)
- [ ] README lists preflight only as internal (`grep -q 'internal skills.*crochet:preflight' README.md && ! grep -q '^| .crochet:preflight' README.md`)
- [ ] refinement counts its checks correctly (`! grep -q 'all three checks' skills/refinement/refinement.md`)
- [ ] every If has its Otherwise in every skill (`test "$(grep -rh '^\*\*If ' skills | wc -l)" = "$(grep -rh '^\*\*Otherwise' skills | wc -l)"`)
- [ ] onboard Step 2 commits the scaffold before verifying it (`awk '/^### Step 2/,/^### Step 3/' skills/onboard/onboard.md | grep -m1 'git commit\|docs check' | grep -q 'git commit'`)
