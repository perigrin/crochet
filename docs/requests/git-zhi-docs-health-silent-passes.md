---
stability: 1
covers:
  - skills/preflight/preflight.md
---

# Two ways `docs health` reports health it has not established

Both were found while assessing a decision that proposed to rely on this
command. They are independent, they compound, and both fail toward reporting
clean.

# 1. No churn is reported for a `covers:` entry naming a directory

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

# 2. A document whose date cannot be resolved is reported as current

When `docs health` cannot resolve a commit for a document, `doc_modified` is the
Go zero value, `0001-01-01T00:00:00Z`. A modification date at the dawn of time
should mean maximal drift. It yields `code_churn: 0` and `drift: NONE`, and the
document is counted in the summary while contributing nothing to it.

Four conditions reach it on 0.7.2, measured against a tree whose full clone
reports `10 docs checked, 2 LOW drift`:

| condition | reported |
|---|---|
| `git clone --depth 1` | `10 docs checked, all current` |
| a worktree of a shallow clone | `10 docs checked, all current` |
| a document added but not yet committed | `doc_modified: 0001-01-01T00:00:00Z`, `drift: NONE` |
| no git repository at all | `1 docs checked, all current` |

The first two matter because `actions/checkout` is shallow by default, so the
configuration most likely to run this command is the one that silences it across
every document at once — and reports the silence as health.

The third matters most to whoever is writing a new live document, because the
document that most needs a drift signal is the one that does not have a commit
yet, and it is counted in the total while being invisible to the check.

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
