---
stability: 1
covers:
  - skills/preflight/preflight.md
---

# `docs health` reports no churn for a `covers:` entry naming a directory

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

| document | `covers:` | shape | churn |
|---|---|---|---|
| `walkthrough-review.md` | `skills/review/review.md` | file | 1 |
| `plugin-structure.md` | `skills/`, `commands/`, `.claude-plugin/plugin.json` | directory | 0 |
| `coding-conventions.md` | `skills/`, `commands/` | directory | 0 |

Same tree, same history, opposite answers. The discriminator is the shape of the
path, not the amount of churn: `b35b00f` and `cd10098` both touch files under
`skills/`, and `walkthrough-review.md` sees one of them because it names a file
directly.

Every live document in this repository declares directory paths, so `docs
health` has never reported drift on any of them since they were written.

## What this is not

Three explanations were proposed and each was tested and rejected. They are
recorded because each looks right and costs a day.

**Not mtime.** `doc_modified` is the committer date of the last commit touching
the document, not a filesystem timestamp. Backdating a document's mtime by one
day and then by one year changed nothing in the report. And for a file committed
at `2026-09-21T15:45:37-04:00`, `doc_modified` reads exactly that, while the
worktree's own checkout timestamp was `14:25:57`.

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

A `covers:` entry naming a directory matches commits touching anything beneath
it. A trailing slash is the obvious signal and `plugin-structure.md` already
writes one, so the entries in this repository would need no edit.

If directory entries are intentionally unsupported, then `docs check`'s
covers-path validation should reject them rather than accepting a value the
health report will silently ignore — an accepted-and-ignored input is worse than
a rejected one, because nothing tells the author.
