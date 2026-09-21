---
stability: 1
covers:
  - skills/preflight/preflight.md
---

# Three ways `docs health` reports health it has not established

All three were found while assessing a decision that proposed to rely on this
command. They are independent, they compound, and each fails toward reporting
clean.

# 1. A `covers:` entry with a trailing slash matches no churn

**Observed on git-zhi 0.7.2 (darwin/arm64).** A document whose `covers:` list
names a directory reports `code_churn: 0` and `drift: NONE` however much that
directory has changed. A document naming a file reports churn correctly. The
failure is silent and in the direction of reporting clean.

## Reproduction

In crochet at `6485384`, where `skills/` had been touched by three commits since
the documents covering it were last changed:

```
$ git zhi docs health --format json | grep -E '"file"|"code_churn"|"drift"'
  "file": "docs/assessments/walkthrough-review.md",   "code_churn": 1,   "drift": "LOW"
  "file": "docs/architecture/plugin-structure.md",    "code_churn": 0,   "drift": "NONE"
  "file": "docs/contributing/coding-conventions.md",  "code_churn": 0,   "drift": "NONE"
```

**Isolated in a scratch repository**, six documents over one history with three
commits under `src/`, varying only the `covers:` string:

| `covers:` entry | churn | ground truth |
|---|---|---|
| `src` | 3 | 3 |
| `src/` | 0 | 3 |
| `src/*` | 0 | 3 |
| `src/**` | 0 | 3 |
| `./src/` | 0 | 3 |
| `src/foo.txt` | 2 | 2 |

`src` names a directory and matches correctly. `src/` names the same directory
and matches nothing, so the defect is the trailing slash rather than the
directory.

**Confirmed against this repository** by editing one document's frontmatter and
changing nothing else:

```
covers: skills/, commands/, .claude-plugin/plugin.json   →  churn 1
covers: skills,  commands,  .claude-plugin/plugin.json   →  churn 4
```

The churn of 1 in the first line comes entirely from the one file-shaped entry.
Every live document in this repository writes trailing slashes, so the directory
halves of their `covers:` lists have never been watched.

## What this is not

Three explanations were proposed and each was tested and rejected. They are
recorded because each looks right and costs a day.

**Not mtime.** Backdating a document's mtime by one day and then by one year
changed nothing in the report, and `doc_modified` for a freshly committed file
reads its commit date while the worktree's own checkout timestamp differs.

**`doc_modified` follows `--full-history`.** It is not the last commit touching
the file, which is what an earlier version of this document claimed. For
`docs/architecture/plugin-structure.md`:

```
git log -1              -- <doc>   →  46acc60  2026-09-20T23:47:59-04:00
git log -1 --full-history -- <doc> →  6a18943  2026-09-21T14:24:18-04:00   ← reported
```

`6a18943` is a merge commit, so a merge resets the window. Reproduced in a
scratch repository with a month between commits, which no timezone conversion
can bridge: doc commit Feb 1, code commit Feb 2, reported `churn 1, LOW`; then a
`--no-ff` merge dated Mar 1 with no content change, reported
`Doc modified: 2026-03-01, churn 0, NONE`.

The churn count itself we still do not claim to explain — it matches neither
`rev-list --count` nor its `--first-parent` variant over any window tried, and
is recorded as unexplained rather than guessed at.

**Not clone freshness.** Because `doc_modified` is commit metadata, it is
identical in every clone, and a fresh clone computes the same drift as a tree
that has been sitting for a week. There is no CI-specific behaviour here.

**Not an empty document set.** The summary line reports the count, and it
reports ten.

## Why it matters here

`crochet:preflight` and `docs/contributing/development-workflow.md` both point
at `docs health` as the way to notice a live document drifting from the code it
describes. For every document crochet actually has, it cannot: the answer is
always NONE.

`development-workflow.md` already warns that the summary "reports three zeros
both when nothing has drifted and when it is observing no documents at all."
This is a third way to get an all-clear over nothing, and the most specific:
the documents are present, the churn is real, and the report is confident.

## What would resolve it

**A `covers:` entry should match the same commits with or without a trailing
slash.** Today `src` matches and `src/` does not, so the more conventional way
of writing a directory is the one that silences the check.

Failing that, `docs check`'s covers-path validation should reject a trailing
slash rather than accepting a value the health report will silently ignore. An
accepted-and-ignored input is worse than a rejected one, because nothing tells
the author — and `docs check` currently reports `✓ All covers paths valid` for
every entry in this repository, all of which are silent.

**The workaround needs no upstream change**, and is recorded here because this
request should not read as a blocker: dropping the trailing slash from each
entry makes the check work today on 0.7.2.

# 2. A truncated history is reported as health, not as unknown

When `docs health` cannot resolve a commit for a document, `doc_modified` is the
Go zero value, `0001-01-01T00:00:00Z`. Where the repository's history is also
truncated, there is nothing to count against that date and every document
reports current — which is indistinguishable from a repository in good order.

Measured on 0.7.2 against a tree whose full clone reports `10 docs checked,
2 LOW drift`:

| condition | reported |
|---|---|
| `git clone --depth 1` | `10 docs checked, all current` |
| a worktree of a shallow clone | `10 docs checked, all current` |

A third row stood here — a tree that is not a git repository at all, reported as
`1 docs checked, all current`. **It is struck because nobody measured it.** It
was carried from an early draft, and the participant whose reproductions produced
the two rows above said plainly that it was on its untested list. A section
headed "measured on 0.7.2" that carries one unmeasured row is the defect this
report is about, committed by the report.

These matter because `actions/checkout` is shallow by default, so the
configuration most likely to run this command is the one that silences it across
every document at once — and reports the silence as health.

**The zero date is not itself the fault, and an earlier version of this document
said it was.** An uncommitted document in a repository with history opens an
unbounded window, so all of it counts and the report is non-zero in the correct
direction. How much depends on the length of the history rather than on the
defect — `HIGH` in the run below, `LOW` in a two-commit repository. Two
untracked documents in one repository, same zero date, demonstrate that the
shape of the `covers:` entry is what decides:

```
docs/uncommitted-DIR.md    covers: src/          churn 0   NONE
docs/uncommitted-FILE.md   covers: src/foo.txt   churn 6   HIGH
```

The first is silent because of defect 1, not because of its date. Attributing it
to the date is a conflation this report carried through several revisions, and
it is recorded because a reader who fixes the zero date will not fix that row.

**What would resolve it.** An unresolvable date is not zero drift, it is unknown
drift, and the two should not render the same. Reporting the document as
`UNKNOWN` rather than `NONE` — and excluding it from an `all current` summary —
would be enough. A caller can then decide whether unknown is acceptable;
today it cannot, because the report does not distinguish "I checked and it is
fine" from "I could not check".

That distinction is the one crochet's own
`docs/contributing/development-workflow.md` already warns about in this command:
its summary "reports three zeros both when nothing has drifted and when it is
observing no documents at all." This is the same shape a third time.

# 3. A code commit sharing a second with the document's is not counted

Two repositories of identical shape — a document commit, then a commit touching
its covered path — differing only in the spacing of their commit dates:

```
commits all within the same second    →  code_churn 0,  drift NONE
same shape, commits one hour apart    →  code_churn 1,  drift LOW
```

The window comparison appears to be strict, so churn landing in the same second
as `doc_modified` falls outside it. That is not an exotic input: scripted
commits, a fast CI job, and `git commit --amend` followed by another commit all
land inside one second routinely, and the result fails toward reporting clean
like the other two.

**Where the boundary sits is untested** — same second, sub-second, or an
inclusive-versus-exclusive comparison on the exact timestamp — and is not
guessed at here, for the same reason the churn formula above is left
unexplained. What is measured is that two repositories doing the same thing
report differently, and the one whose commits are closer together is the one
that reports health.

This was found by accident, in a probe built to test something else, when a
first run contradicted the claim it was checking and the discrepancy was
chased rather than accepted.
