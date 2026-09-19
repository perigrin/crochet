---
stability: 2
covers:
  - skills/
  - .claude-plugin/plugin.json
---

<!-- ABOUTME: How work gets done on crochet — validating changes, branching, adding a skill. -->
<!-- ABOUTME: Describes the DevEx tooling, not the rules that tooling enforces. -->

# Development Workflow

This describes the tooling, the way the architecture doc describes the
codebase. It names the checks; it does not restate the rules they enforce,
because the checks are the truth and prose about them can only drift.

## Setup

Clone the repository and put [git-zhi](https://github.com/perigrin/git-zhi) on
`$PATH`. There is nothing to compile: crochet is markdown, and the files in the
tree are the files that ship.

## Validating a change

Crochet has no compiler to catch a mistake, so validation is three things in
order, cheapest first:

1. **Read the skill for internal consistency.** Do its steps reference `git zhi`
   subcommands that exist? Does a claim it makes about another skill still hold?
2. **Behavioural walkthrough against the live binary.** Run the commands the
   skill tells an agent to run, in a scratch repository, and observe what
   actually happens. This is the step that catches version skew: a skill can be
   internally consistent and still describe a flag the installed binary does not
   have, or an input mode it no longer accepts.
3. **Run the product check.**

   ```bash
   sh t/git-zhi-subcommands.sh
   ```

   Every `git zhi` subcommand named in a fenced block or backtick span under
   `skills/` must really exist. This is the check that catches version skew at
   the level it actually happens: a subcommand's `--help` exits 0 long after
   the flags beneath it have moved, and a companion invoked by hyphenated name
   stopped dispatching in v0.5.0 while the stale symlink kept answering.

4. **Run the project checks.**

   ```bash
   sh xt/run.sh
   ```

   These ask whether the repo does what this document claims of it: the
   product check above, `git zhi docs check`, no live document declaring a
   `covers:` list and naming nothing, and symmetric links between decisions.
   It ends by running itself against `xt/fixture`, which is broken on purpose
   — a runner that can no longer fail has failed open, and you would stop
   watching for what it caught.

5. **Check the documentation structure directly** when you want the detail.

   ```bash
   git zhi docs check     # reachability, dead links, decision numbering, covers paths
   git zhi docs health    # drift between a doc's covers: paths and their churn
   ```

   Read `docs health` carefully: its summary reports three zeros both when
   nothing has drifted and when it is observing no documents at all.

### Writing a check that can be trusted

Two rules, both learned by getting them wrong more than once:

**Write one check that passes today for every check that fails today.** A suite
that only knows how to fail cannot detect its own absence. If every assertion is
of the form "this should error", then a harness that never ran, a binary that is
missing, and a genuine defect are indistinguishable — they all produce a
non-zero exit. Pair every red assertion with one that must be green, so a
silently broken harness shows up as the green one failing.

**Read the failure text, not the exit code.** A check that exits non-zero for
the wrong reason has told you nothing. `127` from a missing file and the
specific error you were expecting both satisfy `! command`. Where the logic is
subtle, revert the fix and confirm the test goes red for the reason you
intended — that proves the test can fail, rather than assuming it.

Both exist because the same defect appeared four times in one day, in four
different tools, including in the checks written to catch it.

Observation beats inference throughout. Where a skill asserts how the CLI
behaves, that assertion should have been produced by running the command, not
by reading another document that says so.

## Branching

Feature branches come off `pu` and return to it by pull request. `pu` is
protected: never push to it directly, and never merge or force-push it.

## Adding a skill

1. Create `skills/<name>/<name>.md` with `name` and `description` frontmatter.
2. Create `commands/<name>.md` delegating to it — unless the skill is internal,
   in which case say so in the skill's own text and add no stub.
3. Add a row to the README's skills table, or to its internal-skills line.
4. Update the description in `.claude-plugin/plugin.json` if the skill changes
   what the plugin is for.

The README and `commands/` are checked against each other, in both directions,
so a skill added to one and not the other is caught rather than noticed.

## Changing a live document

Update the document first, then build to match, in the same pull request. The
document is briefly false on the branch; that is the red state, not a defect.
The reasoning is recorded in `docs/decisions/0001-documentation-architecture.md`.
