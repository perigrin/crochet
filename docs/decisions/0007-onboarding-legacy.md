---
title: Onboarding a project that already has a history
state: proposed
author: Chris Prather
date: 2026-09-20
supersedes: []
superseded-by: []
---

# 0007: Onboarding a project that already has a history

**This entry is a placeholder. Its Problem Statement is written; its Proposal
awaits brainstorming.** The problem is recorded now because the evidence was
gathered while reading `crochet:onboard` against the installed binary, and
evidence that lives only in a conversation is evidence that has to be found
again.

## Problem Statement

`crochet:onboard` walks a repository through git-zhi adoption in seven steps.
It assumes, at almost every step, a project shaped like the one it was written
in: a small documentation tree it can scaffold into, a ticket prefix a team
agreed on and kept, and a chain that begins empty.

A legacy project satisfies none of those, and the procedure does not say so.

### The procedure breaks between its own steps

**Step 3 imports history with `git zhi historian`. Step 6 runs
`git zhi sanbao <milestone>`. Nothing connects them.** `historian` has no
`--milestone` flag — confirmed on 0.7.1 — so every issue it creates belongs to
no milestone, and `sanbao` takes a milestone as a required positional argument.
A repository that follows the procedure exactly reaches Step 6 with nothing to
name.

Step 6 says to "skip with a note" when sanbao is not installed. It has nothing
to say about sanbao being installed and inapplicable, which is the case the
procedure actually produces.

### It assumes a ticket prefix existed and survived

Step 3 asks "What ticket prefix does your team use?" and offers `none` as an
answer, then passes it to `--title-match`. A long-lived project has usually had
several prefixes, or changed trackers, or used none for its first years and one
after. The procedure has one question and one pattern where the honest answer is
a list with dates attached.

Step 4 then asks whether coverage is "acceptable" without saying what acceptable
means, or what to do with the commits that mapped to nothing. On a repository
with a decade of history, that is where the work is.

### It scaffolds where a legacy project already has documents

Step 2 runs `git zhi docs init` and then tells the reader to fit the scaffold —
rewrite the contributing docs that arrive describing git-zhi's own Go build, or
delete them, and prune the `CONTRIBUTING.md` links whose directories are empty.

That is the right instruction for a repository with no documentation. A legacy
project has documentation that is merely in the wrong shape: a README carrying
what belongs in three places, architecture notes in a wiki, conventions that
exist only as review comments. Nothing says how to *adopt* those rather than
scaffold beside them, and `git zhi docs check` measures reachability from
`CONTRIBUTING.md`, which such a project may not have.

### It never reaches the pipeline

The seven steps end at `git zhi next`. They do not mention assess, refinement,
review or the postmortem, and they do not mention the rule that makes a legacy
project tractable at all: `docs/decisions/0003-acceptance-by-refinement.md` says
a gate backfills what is missing rather than refusing to start, and that a
finished pull request enters at review with the assessment and the decision
backfilled behind it.

**A legacy project is the case that rule was written for**, and the skill that
meets legacy projects first is the one skill that does not cite it.

## Proposal

Awaiting brainstorming. The likely shape is that onboarding becomes two
procedures rather than one — a greenfield path close to what exists, and a path
for a repository whose history, documents and conventions all predate the tool —
but that is a guess and should be settled rather than assumed.

## Scope of Change

Unknown until the Proposal exists. The procedure is in `skills/onboard/onboard.md`
and `skills/onboard/procedure.md`; the backfill rule it does not cite is in
`docs/decisions/0003-acceptance-by-refinement.md`; and the milestone gap between
`historian` and `sanbao` is git-zhi's, not crochet's, so it belongs in a request
like `docs/requests/git-zhi-verification-integrity.md` rather than in this
repository's own work.
