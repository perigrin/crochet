<!-- ABOUTME: Implementation plan for the crochet:how-to-use-git-zhi command-reference skill. -->
<!-- ABOUTME: Observe-then-document tasks validated by behavioral walkthrough against real git zhi v0.4.0. -->
# crochet:how-to-use-git-zhi Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Create an internal, agent-facing git-zhi command reference skill (`crochet:how-to-use-git-zhi`) and wire its discovery, so an agent mid-task can look up the exact `git zhi` command, its input mode, and its output for a given intent.

**Architecture:** One new single-file skill at `skills/how-to-use-git-zhi/how-to-use-git-zhi.md` (internal — no `commands/` stub, following the `crochet:preflight` precedent), plus discovery pointers added to two shared files (`skills/require-git-zhi.md`, `skills/preflight/preflight.md` step 6) and a README internal-skills note entry. The skill's factual content is grounded in the real binary: state nouns are *observed* by transitioning a throwaway issue, JSON is documented as a field inventory, and a "trust `--help`" principle handles drift.

**Tech Stack:** Markdown skill files with YAML frontmatter; the `git zhi` CLI (verified against v0.4.0). No build step, no test harness — per this repo's CLAUDE.md, validation is structural review + behavioral walkthrough against the real `git zhi` tool.

---

## Validation Note (read first)

No `pytest`, no test suite, no build. The TDD cycle here is **observe → document → verify**:

- The "failing test" is an **empirical observation** — run the real `git zhi`
  command, capture its actual output/input-mode/exit. Until you've observed it,
  the doc claim is unverified (the "red" state).
- The "implementation" is writing the reference to **match what was observed**.
- "Verify" re-reads the doc against the captured output and confirms they agree.

Task 2 (state-noun observation) is the most test-like: it literally transitions
a throwaway issue and records the reported nouns. Commit after each task.

The spec's 16 acceptance criteria are the coverage target; Task 7 walks them.

---

## File Structure

- **Create:** `skills/how-to-use-git-zhi/how-to-use-git-zhi.md` — the entire reference skill (Tasks 1–5 build it section by section).
- **Modify:** `skills/require-git-zhi.md` — append a one-line by-name pointer (Task 6).
- **Modify:** `skills/preflight/preflight.md` — extend step 6 with an explicit write-command pointer (Task 6).
- **Modify:** `README.md:23` — add the skill to the internal-skills note (Task 6).
- **Modify:** `skills/preflight/preflight.md` orientation table — correct `in_progress` (underscore) to the observed `in-progress` (hyphen) in all three rows (Task 2; confirmed needed, not conditional). This is in addition to the step-6 discovery pointer added in Task 6.

No `commands/` file is created. No `.claude-plugin/plugin.json` change (a reference skill does not alter plugin scope; confirm in Task 7).

---

## Task 1: Scaffold the skill file (frontmatter, ABOUTME, prerequisite, stdin convention)

**Files:**
- Create: `skills/how-to-use-git-zhi/how-to-use-git-zhi.md`

- [ ] **Step 1: Confirm the prerequisite pattern**

Run: `cat skills/require-git-zhi.md` and `head -10 skills/onboard/onboard.md`
Expected: `require-git-zhi.md` is a shared block (CLAUDE.md:82 calls it a copy block — there is no include mechanism, and `onboard.md` does NOT reference it; it inlines its own one-line `which git-zhi` prerequisite). Match the **inline** prerequisite pattern onboard uses — write a short prerequisite directly in the new skill, as shown in Step 2.

- [ ] **Step 2: Create the file with frontmatter, ABOUTME, prerequisite, and the stdin lead section**

```markdown
---
name: how-to-use-git-zhi
description: Agent-facing git-zhi command reference — consult before running any `git zhi` command, especially writes that take stdin. Maps intents to commands, input modes, and output.
---
<!-- ABOUTME: Internal agent-facing reference mapping intents to git zhi commands, input modes, and output. -->
<!-- ABOUTME: Consulted before running git zhi commands; not user-invocable and has no commands/ stub. -->

# crochet:how-to-use-git-zhi

**Internal skill.** An agent-facing command reference for day-to-day git-zhi
operation. Consulted by name; no `commands/` stub, no user-facing slash command.
It does not cover adoption (`crochet:onboard`) or binary setup (`crochet:install`)
— it assumes git-zhi is installed and a chain exists.

## Prerequisites

Before proceeding, verify that `git-zhi` is available by running `which git-zhi`.
If not found, run `crochet:install` to set it up.

## The stdin convention

Titles and short metadata are positional args or flag values. **`issue edit`
body/batch/split content arrives via stdin pipe — not as arguments.** Note the
asymmetry: **`issue add` has NO stdin form** — it needs a positional title and
a `--body` flag; only `issue edit --body`/`--batch`/`--split` read stdin.

​```bash
# WRONG: issue add does NOT read a body from stdin (errors: title required / no content)
echo "Long body text..." | git zhi issue add "Fix login"
# RIGHT: issue add takes a positional title and a --body flag
git zhi issue add "Fix login" --body "Long body text..."

# stdin IS the input mode for issue edit body replacement:
echo "New body text..." | git zhi issue edit <ref> --body
​```
```

(Replace the `​```` markers above with real triple backticks — three plain backtick characters — in the file.)

This asymmetry is verified against the binary and matches the repo's own
`skills/refinement/refinement.md:77` ("no working stdin/batch form" of issue add).

- [ ] **Step 3: Verify structure**

Run: `head -20 skills/how-to-use-git-zhi/how-to-use-git-zhi.md`
Confirm: frontmatter has `name` + `description`; two `ABOUTME:` lines present; the description names the job AND signals when to consult (AC: description quality). Confirm no `commands/how-to-use-git-zhi.md` was created: `ls commands/ | grep how-to || echo "no stub (correct)"`.

- [ ] **Step 4: Commit**

```bash
git add skills/how-to-use-git-zhi/how-to-use-git-zhi.md
git commit -m "Scaffold how-to-use-git-zhi skill with stdin convention"
```

---

## Task 2: OBSERVE the state-noun vocabulary (the empirical core)

**Files:**
- Modify: `skills/how-to-use-git-zhi/how-to-use-git-zhi.md` (add the verb-vs-noun section)
- Modify: `skills/preflight/preflight.md` (correct `in_progress` → `in-progress`, confirmed needed)

- [ ] **Step 1: Confirm the transition verbs (the "arg" side)**

Run: `git zhi issue edit --help | grep -A0 'state string'`
Expected: `transition state: start, pause, resume, done, cancel`. These are the verbs.

- [ ] **Step 2 (RED — observe): create a throwaway issue and capture its reported noun at each state**

This is the empirical step. The live chain has only `pending` issues, so the
other nouns are unobservable without creating one. Run:

```bash
# create scratch issue — issue add REQUIRES --body (no stdin form) and returns a JSON ARRAY
REF=$(git zhi issue add "SCRATCH: state observation — delete me" --body "scratch" --format json | python3 -c "import json,sys; print(json.load(sys.stdin)[0]['id'])")
echo "scratch ref: $REF"
# capture reported noun at each transition
git zhi issue show "$REF" --format json | python3 -c "import json,sys; print('after add   ->', json.load(sys.stdin).get('state'))"
git zhi issue edit "$REF" --state start  >/dev/null; git zhi issue show "$REF" --format json | python3 -c "import json,sys; print('after start ->', json.load(sys.stdin).get('state'))"
git zhi issue edit "$REF" --state pause  >/dev/null; git zhi issue show "$REF" --format json | python3 -c "import json,sys; print('after pause ->', json.load(sys.stdin).get('state'))"
git zhi issue edit "$REF" --state resume >/dev/null; git zhi issue show "$REF" --format json | python3 -c "import json,sys; print('after resume->', json.load(sys.stdin).get('state'))"
git zhi issue edit "$REF" --state done --force >/dev/null; git zhi issue show "$REF" --format json | python3 -c "import json,sys; print('after done  ->', json.load(sys.stdin).get('state'))"
```

Note the JSON-shape asymmetry in the commands above: `issue add` returns a JSON
**array** (hence `[0]['id']`), while `issue show` returns a single **object**
(hence `.get('state')`). Different commands, different shapes — both correct.

Record the exact noun printed at each line. Two things verified against the
binary you should expect (confirm, don't assume): the started noun is
**`in-progress`** (hyphen, not underscore), and **`pause`/`resume` both report
`in-progress`** — there is no distinct `paused` noun, so the mapping table
collapses them rather than giving each verb its own row. (`--force` on `done` is
needed because the scratch issue has zero commits — see `issue edit --help`.) If
any transition errors, capture the error and adjust; do not guess the noun.

- [ ] **Step 3 (cleanup): purge the throwaway issue**

```bash
git zhi issue edit "$REF" --purge --yes
git zhi list --all --format json | python3 -c "import json,sys; ids=[i['id'] for i in json.load(sys.stdin).get('issues',[])]; print('scratch still present:' , '$REF' in ids)"
```
Expected: `scratch still present: False`, and `git status --porcelain` empty.

**Safety — do not skip.** The scratch issue lives in the **real v0.1 crochet
chain**. If `--purge` fails or the issue is still present, **STOP and surface it
to the human** — do not proceed leaving an orphaned `SCRATCH` issue in the live
milestone. The clearly-marked title is a safeguard, not a license to leave it.

- [ ] **Step 4 (GREEN — document): write the verb-vs-noun section from the OBSERVED nouns**

Add to the skill file a `## State model: verbs vs nouns` section. Use the
verbs from Step 1 and the nouns OBSERVED in Step 2 (not assumed). Include a
mapping table: for each reported noun, the verb that reaches it and the verb
that advances it. Example skeleton (fill nouns from observation):

```markdown
## State model: verbs vs nouns

`git zhi issue edit <ref> --state` takes a transition **verb**:
`start`, `pause`, `resume`, `done`, `cancel`.
`git zhi status` / `list --format json` **report** a state **noun**.

| Reported noun | Reached by | Advanced by |
|---|---|---|
| <observed> | <verb> | <verb> |
```

- [ ] **Step 5 (reconcile — confirmed needed): correct preflight's `in_progress` to the observed `in-progress`**

Run: `grep -n 'in_progress' skills/preflight/preflight.md`
The preflight orientation table (merged in PR #5) uses `in_progress`
(underscore). Step 2 observes the real noun is `in-progress` (hyphen) — so the
reconcile path **will** trigger; this is a confirmed bug, not a hypothetical.
The grep returns **three** rows (2, 3, and 4). Replace `in_progress` with the
observed `in-progress` in **all three** — do not stop at rows 2/4. An agent
matching `state == "in_progress"` against real output never matches, so this
correction is the point.

```bash
sed -i 's/in_progress/in-progress/g' skills/preflight/preflight.md
grep -c 'in-progress' skills/preflight/preflight.md   # expect 3
grep -c 'in_progress' skills/preflight/preflight.md   # expect 0
```

(Confirm Step 2 actually observed `in-progress` before running the sed — if
observation somehow differs from the verified expectation, STOP and surface to
the human rather than blindly substituting.)

- [ ] **Step 6: Verify and commit**

Re-read the new section; confirm every noun in the table was observed in Step 2, not carried over from the spec's illustrative `in_progress`. Confirm the tree is clean (scratch issue gone).

```bash
git add skills/how-to-use-git-zhi/how-to-use-git-zhi.md skills/preflight/preflight.md
git commit -m "Document observed git-zhi state nouns; reconcile preflight if needed"
```

---

## Task 3: Intent → command table

**Files:**
- Modify: `skills/how-to-use-git-zhi/how-to-use-git-zhi.md`

- [ ] **Step 1 (RED — observe): confirm each command's real input mode and flags**

For each command in the table below, run its `--help` and confirm the input
mode label (`arg` / `flag` / `stdin` / `none`) against reality:

```bash
git zhi next --help
git zhi list --help
git zhi issue show --help
git zhi status --help
git zhi issue add --help
git zhi issue edit --help
git zhi milestone --help
```

Note especially: `issue add` takes a positional title (arg) plus a `--body`
flag — **input mode `arg + flag`, NOT stdin** (it has no stdin form);
`issue edit --body`/`--batch`/`--split` read stdin; `status` takes no input
(`none`).

- [ ] **Step 2 (GREEN — document): write the intent→command table**

Add a `## Intent → command` section with columns **Intent | Command | Input mode | Output**. One row per intent, input mode from Step 1. Cover: find next work (`next`), inspect chain (`list` + filters), view issue (`issue show`), check state (`status`), create issue (`issue add`), transition/edit (`issue edit --state` etc.), replace body (`issue edit --body`, stdin), bulk edits (`--batch`, stdin), split (`--split`, stdin), milestones (`milestone add|edit|list|show`). Each row's input mode is `arg`/`flag`/`stdin`/`none`.

- [ ] **Step 3: Verify**

Re-read the table. Confirm every row has all four columns filled and the input-mode label matches what Step 1 observed. Spot-check one stdin row and one arg row against the actual `--help`.

- [ ] **Step 4: Commit**

```bash
git add skills/how-to-use-git-zhi/how-to-use-git-zhi.md
git commit -m "Add intent-to-command table with verified input modes"
```

---

## Task 4: JSON field inventory

**Files:**
- Modify: `skills/how-to-use-git-zhi/how-to-use-git-zhi.md`

- [ ] **Step 1 (RED — observe): capture the real keys for each parsed command**

```bash
git zhi status --format json | python3 -c "import json,sys; print('status:', sorted(json.load(sys.stdin).keys()))"
git zhi next --format json   | python3 -c "import json,sys; print('next:', sorted(json.load(sys.stdin).keys()))" 2>/dev/null || echo "next: (errors on empty/HEAD — note this)"
git zhi list --format json   | python3 -c "import json,sys; d=json.load(sys.stdin); ks=sorted(d.get('issues',[{}])[0].keys()) if d.get('issues') else sorted(d.keys()); print('list:', ks)"
git zhi issue show --format json 2>/dev/null | python3 -c "import json,sys; print('issue show:', sorted(json.load(sys.stdin).keys()))" 2>/dev/null || echo "issue show: (needs a ref)"
```

- [ ] **Step 2 (GREEN — document): write the field inventory (NOT literal blocks)**

Add a `## JSON output (field inventory)` section. For `status`, `list`, `next`,
`issue show`, list the **keys an agent relies on** (from Step 1) — not pasted
JSON objects. Add the one-line "run `git zhi <cmd> --format json` to see the
live shape" pointer. For `status`/`list`, point to the preflight orientation
section as canonical for the literal shapes rather than duplicating them.

- [ ] **Step 3: Verify**

Confirm the section lists keys, not literal JSON structures, and that the `status`/`list` entries defer to preflight rather than re-pasting shapes (AC: no duplication / no drift).

- [ ] **Step 4: Commit**

```bash
git add skills/how-to-use-git-zhi/how-to-use-git-zhi.md
git commit -m "Add JSON field inventory deferring to preflight for status/list"
```

---

## Task 5: Self-correction section + companion-subcommand one-liner

**Files:**
- Modify: `skills/how-to-use-git-zhi/how-to-use-git-zhi.md`

- [ ] **Step 1: Confirm the version string to record**

Run: `git zhi version | head -1 | awk '{print $2}'`
Expected: `0.4.0`. This is the version actually exercised — record THIS, not the `0.3.9` floor.

- [ ] **Step 2: Write the self-correction section**

Add a `## When this reference and the CLI disagree` section stating:
- "Confirm the current surface with `git zhi <cmd> --help`. This reference is verified against git-zhi 0.4.0 and the CLI evolves."
- **The resolution rule:** when `--help` and this reference disagree, `--help` wins — proceed on `--help`'s surface; do not treat this reference as authoritative for that command.
- **The not-yet-implemented principle:** git-zhi marks unfinished surfaces inline in `--help` ("not yet implemented"); trust `--help` for whether a flag works. Cite `issue add --after/--before` and `list --graph` as illustrations, NOT as a maintained list.

- [ ] **Step 3: Write the companion-subcommand one-liner**

Add exactly one line (not a section per subcommand): "Companion subcommands — `historian`, `jira`, `sanbao`, `docs`, `mermaid`, `project` — exist; run `git zhi <name> --help` for their surface." Enforce the YAGNI cap: one line, no per-subcommand docs.

- [ ] **Step 4: Verify**

Confirm: version reads `0.4.0`; the `--help`-wins rule is present; not-yet-implemented is a principle with the two flags as illustrations only; companion subcommands are exactly one line.

- [ ] **Step 5: Commit**

```bash
git add skills/how-to-use-git-zhi/how-to-use-git-zhi.md
git commit -m "Add self-correction rules and companion-subcommand pointer"
```

---

## Task 6: Wire discovery (require-git-zhi, preflight, README)

**Files:**
- Modify: `skills/require-git-zhi.md`
- Modify: `skills/preflight/preflight.md`
- Modify: `README.md`

- [ ] **Step 1: Append the require-git-zhi pointer**

At the end of `skills/require-git-zhi.md`, append:
```markdown

For command syntax and input modes, consult `crochet:how-to-use-git-zhi`.
```

- [ ] **Step 2: Strengthen preflight step 6 with the write-command pointer**

In `skills/preflight/preflight.md`, in step 6 ("Report pipeline orientation"), add a sentence to its guidance: "Before running any `git zhi` write command (`issue add`, `issue edit`, `milestone add/edit`), consult `crochet:how-to-use-git-zhi` for the exact syntax and input mode." Place it within step 6, not as a new step (do not change the seven-step count).

- [ ] **Step 3: Add the README internal-skills note entry**

In `README.md` line 23, change:
```
The following are internal skills (not directly user-invocable): `crochet:pushback`, `crochet:alignment`
```
to:
```
The following are internal skills (not directly user-invocable): `crochet:pushback`, `crochet:alignment`, `crochet:how-to-use-git-zhi`
```
Confirm the user-facing skills table (lines 9–21) is unchanged.

- [ ] **Step 4: Verify**

Run: `grep -c 'how-to-use-git-zhi' skills/require-git-zhi.md skills/preflight/preflight.md README.md`
Expected: each file reports ≥1. Confirm preflight still says "seven checks" (`grep 'seven checks' skills/preflight/preflight.md`).

- [ ] **Step 5: Commit**

```bash
git add skills/require-git-zhi.md skills/preflight/preflight.md README.md
git commit -m "Wire how-to-use-git-zhi discovery into require-git-zhi, preflight, README"
```

---

## Task 7: Final spec-AC consistency pass

**Files:**
- Read-only: the skill file, the three modified files, the spec.

- [ ] **Step 1: Walk the spec's 16 acceptance criteria**

Open `docs/plans/2026-06-06-how-to-use-git-zhi-skill-design.md` Acceptance Criteria and confirm each against the built files:
- [ ] skill file exists with ABOUTME + name/description frontmatter
- [ ] no `commands/how-to-use-git-zhi.md` stub
- [ ] skill includes require-git-zhi prerequisite
- [ ] description names the job and signals when to consult
- [ ] leads with stdin convention + WRONG/RIGHT example
- [ ] intent table lists intent + command + input mode, input modes verified
- [ ] verb-vs-noun table built from OBSERVED nouns
- [ ] JSON field inventory (not literal blocks), defers to preflight for status/list
- [ ] each section has the `--help` pointer; version recorded is `0.4.0`
- [ ] "trust `--help`" principle + `--help`-wins rule present
- [ ] cross-consistency directive about preflight's `in_progress` honored
- [ ] discovery wired in require-git-zhi + preflight (write-command framing)
- [ ] require-git-zhi points to the skill
- [ ] preflight points to the skill
- [ ] README internal-skills note lists it; user-facing table unchanged
- [ ] companion subcommands are exactly one line

- [ ] **Step 2: Confirm scope — only the intended files changed**

Run: `git diff --stat pu -- ':!docs'`
Expected: `skills/how-to-use-git-zhi/how-to-use-git-zhi.md` (new), `skills/require-git-zhi.md`, `README.md`, and `skills/preflight/preflight.md` (step 6 pointer + possibly the reconciled noun). No `commands/` file. No `.claude-plugin/plugin.json` change unless Step 3 shows it's needed.

- [ ] **Step 3: Confirm plugin.json scope**

Read `.claude-plugin/plugin.json` description. A reference skill should not change plugin scope. If it genuinely does, note it; otherwise leave untouched (AC: no assumed edit).

- [ ] **Step 4: Confirm clean tree**

Run: `git status --porcelain` — expect empty (all committed, scratch issue purged).
