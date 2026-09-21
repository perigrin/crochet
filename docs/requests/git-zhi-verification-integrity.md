---
stability: 1
covers:
  - skills/how-to-use-git-zhi/how-to-use-git-zhi.md
---

# Verification integrity in git-zhi

A design document for git-zhi, written from crochet. It is the deliverable of
`rfc-0003` issue 12, and it is meant to be taken into git-zhi's own tree and run
through the crochet loop there — this document is the subject of that
assessment, not its outcome.

**Every gap below was observed on git-zhi 0.6.0**, in this repository or in a
scratch repository, with the command and its output recorded. No line numbers
are cited into git-zhi's tree: nothing here can check them, and three separate
passes over `0002-worker-identity.md` found stale cross-repository citations.

## Problem Statement

Six defects, five of them one shape: **a check that reports the result it would
report if clean, when what it actually examined was empty or wrong.**

Crochet's whole protocol rests on gates leaving evidence. A gate whose green and
whose vacuum are indistinguishable is not evidence, and it is worse than an
absent gate, because an absent gate is visibly absent.

### 1. `verify` runs the wrong field entirely

**The most serious of the six, and the one to fix first.**

`git zhi verify <milestone>` has never run an acceptance criterion in `rfc-0003`.
Every block it prints is labelled `Negative:`. `issue show --format json` returns
the negative scenarios in **both** the `acceptance_criteria` and
`negative_scenarios` arrays — identical to each other, and both differing from
the `## Acceptance Criteria` list in the body markdown, which holds the real
criteria.

So `milestone edit --state complete` runs the closing gate over a field that
never contains an acceptance criterion. It reports a count and passes; what it
checked was the negative scenarios, twice.

Observed across three issues in `rfc-0003`. The real criteria were then run by
hand and do pass — so this is a defect in the gate, not in the work, which is the
worse of the two. It means a milestone's own verification is not evidence about
the milestone.

**Fixed means:** the two arrays hold different content, and `verify` reports a
count that matches the `## Acceptance Criteria` list.

### 2. `verify` reads only done issues, so `--dry-run` is inert when it is needed

`skills/chain-review/chain-review.md` runs `verify --dry-run` in list-only mode
to confirm every criterion is extractable and runnable **before** execution
starts. That is the only state chain-review ever runs in, and in it every issue
is pending.

Observed: `git zhi verify rfc-0003 --dry-run` against twelve pending issues
carrying sixty-nine paren-wrapped commands returns empty, exit 0.

The check passes because there was nothing to check. This is the vacuous pass in
its purest form: the gate designed to catch unrunnable criteria before execution
cannot see a single criterion at the moment it runs.

**Fixed means:** `--dry-run` extracts regardless of issue state.

### 3. An empty subject reports success

The general form of 2, and worth fixing separately, because fixing 2 alone still
leaves a `verify` over a milestone whose issues carry no criteria reporting
green.

git-zhi's own proposal — putting it in `ExtractCommands`' caller rather than in
`--dry-run` — is **better than what crochet originally asked for**, and crochet
withdraws its narrower version. A real `verify` that found nothing should say so
on stderr and exit non-zero, not only a `--dry-run` that found nothing.

**Fixed means:** extracting zero commands is reported as such and exits non-zero,
wherever it happens.

### 4. `verify` ignores the milestone body

0003 says a milestone carries the decision's acceptance criteria, and that the
review gate verifies them. `verify` extracts only from issues, so milestone-level
criteria are unverifiable and the review gate would read them by eye.

Additive: keep issue extraction exactly as it is. The negative scenario crochet
would hold this to is that milestone-body extraction does not lose issue-body
extraction — a dry run over `rfc-0001` must still name `xt/run.sh`.

**Fixed means:** criteria in the milestone body are extracted and run alongside
the issues'.

### 5. `docs check` reports reachability it did not examine

`git zhi docs check` prints `✓ All files reachable from CONTRIBUTING.md` in a
repository that has no `CONTRIBUTING.md` at all. Observed in a scratch repository
with `docs/decisions/` and no contributing file: all green, exit 0.

Same shape as the `docs health` behaviour crochet already documents for its own
contributors — "its summary reports three zeros both when nothing has drifted and
when it is observing no documents at all". Here it matters more, because
`crochet:assess` depends on this check to catch an unreachable archive.

A smaller asymmetry surfaced alongside it: `docs/decisions/` gets an implicit
reachability pass and `docs/assessments/` does not. Whatever the rule is, it is
not stated anywhere a skill author would find it.

**Fixed means:** a reachability claim names the root it examined, and the absence
of that root is a distinct outcome from everything being reachable.

### 6. `git zhi list --all` is a silent no-op

New, and not previously reported. git-zhi asked whether anything of crochet's
uses the top-level `list --all`; the answer is that crochet's **documentation**
does, which is worse than a call site, because it ships the wrong claim to every
agent that reads it.

Repro, in this repository, today. Counting `"id"` keys in each JSON output:

| command | issues returned |
|---|---|
| top-level `list --all` | 1 |
| `issue list --all` | 40 |

The two `list` forms, with and without `--all`, are byte-identical. `--all` exits
0 there; an unrecognised flag such as `--bogusflag` exits 1.

**And `--help` advertises it.** `git zhi list --help` prints:

```
      --all                include done and cancelled issues
```

So this is not an unknown flag being tolerated, and not an undocumented one
either. It is a documented, recognised flag that does nothing, which no caller
can detect and which `--help` actively denies. crochet's reference tells agents
that when `--help` and the reference disagree, `--help` wins; this is the first
known case where that rule produces the wrong answer, and the reference now
carries it as a counterexample.

crochet's own defect from this: `skills/how-to-use-git-zhi/how-to-use-git-zhi.md`
lists `--all` in the flag set for the top-level `list`, implying the `issue list`
meaning. Crochet will correct that regardless of what git-zhi decides.

**Fixed means:** either `--all` includes done issues on the top-level `list`, or
it is rejected there. Silently accepting it is the only outcome crochet cannot
work with.

## What crochet also wants, smaller

**`issue edit` has no `--title`.** Retitling an issue means deleting and
recreating it, which loses its id — and the id is what the milestone checklist,
the `blocks` graph and every skipped-gate record refer to. Observed while
correcting two issue titles in `rfc-0003`; both corrections were abandoned rather
than break the references.

## Questions git-zhi asked, answered

**`historian` never sets `Milestone` — is it load-bearing for the postmortem?**
No. `skills/postmortem/postmortem.md` names its data sources as issue list,
milestone telemetry, verify results, docs health and the sanbao report; it never
invokes `historian`. crochet does not import reconstructed history anywhere.
Treat it as theoretical for crochet and decide it on git-zhi's own grounds.

**Does crochet want whole-repo `sanbao`?** Not today — the postmortem is scoped
to a milestone by construction. The case where crochet would want it: a
cross-milestone trend, since 0003's postmortem asks whether a *way of working* is
holding up, and one milestone cannot answer that. That is a real future want and
not a current blocker.

**Does anything use top-level `list --all`?** See gap 6. No call site; one
documentation site, being corrected.

**The seven orphaned `git-zhi-<plugin>` symlinks.** Nothing of crochet's probes
them. Every remaining `git-zhi-<name>` string under `skills/` is prose naming
verify's extraction contract, never a command in command position — checked
across the whole skills tree. This is perigrin's cleanup now, not crochet's
dependency. crochet keeps `t/git-zhi-subcommands.sh`, which exists because one of
those symlinks stopped dispatching in 0.5.0 while its `--help` kept exiting 0.

**The line-number convention.** crochet keeps it either way; it is enforced by
`xt/run.sh` against `docs/decisions/` here. git-zhi should decide it on its own
grounds.

## What crochet is not asking for

No new `--format json` surfaces, no new subcommands, and nothing that changes an
existing default. Five of the six gaps above are a check learning to distinguish
"nothing was wrong" from "nothing was examined", and that distinction is the
entire request.

## Coordination

The mechanism between the two repositories already exists:
`git_zhi_min_version` in `.claude-plugin/plugin.json`, which `crochet:preflight`
enforces. Raise it once these ship, so a crochet depending on them cannot report
a healthy environment to an agent whose skills cannot work in it.

Priority, if it must be ordered: **1, then 2 and 3 together, then 4.** Gap 1
means no milestone in either repository is currently verified by its own gate.
