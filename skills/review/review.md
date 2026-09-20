---
name: review
description: Pipeline gate between execute and postmortem — runs coverage and code-quality lenses over the unit of delivery's diff, to a bounded fixed point
---

<!-- ABOUTME: Pipeline gate skill invoked between crochet:execute and crochet:postmortem. -->
<!-- ABOUTME: Reviews the milestone's branch diff against the decision that authorised it. -->

## Prerequisites

Run `crochet:preflight` as the first step. It checks git-zhi availability and
returns the capabilities map used for conditional dispatch below.

# crochet:review

Pipeline gate that runs after `crochet:execute` finishes and before
`crochet:postmortem`. It reviews the **unit of delivery** against the decision
that authorised it.

```
crochet:execute → crochet:review → crochet:postmortem
```

Nothing else does this. PAAD review runs inside execute, per issue — the unit of
work. The milestone's diff is never looked at as a whole, and "did the checks
pass" is a different question from "did we build what the decision said, and is
the result sound".

## Invocation

```
crochet:review <milestone>
```

## Step 1: The subject is the branch diff

```bash
git diff pu...HEAD
```

A milestone is a unit of delivery, a unit of delivery is a pull request, and a
pull request's diff is its branch diff. It is what a reviewer looks at, and it
includes every commit on the branch whether or not anything recorded it.

git-zhi carries a narrower signal — each issue's `sessions[]` records
`start_sha`, `end_sha` and a commit count — but that is a range per execution
session rather than a diff per delivery, and it attributes only what ran through
execute's dispatch. Collecting commits by `Implements:` trailer is worse still:
it inherits the trailer's soft spot and misses exactly the untrailered commits
most worth catching.

## Step 2: The lenses

Both are ordinary skills, reached by the usual conditional pattern.

**Coverage — does the diff cover the decision?**

Read the decision named by the milestone's `Implements:` trailers and check its
acceptance criteria against what was built. Criteria live on the milestone once
refinement carries them across; on a milestone refined before that, read them
from the decision document directly.

**Quality — is the code sound?**

**If `paad:agentic-review` is available** (check preflight capabilities):
  Delegate to it over the branch diff.
**Otherwise:**
  Read the diff for debt, security and coverage gaps inline.

**If `ponytail:ponytail-review` is available** (check preflight capabilities):
  Delegate to it — over-engineering is the lens it exists for.
**Otherwise:**
  Skip it and say so in the minute.

## Step 3: Run to a bounded fixed point

**Delegate the convergence to `crochet:discernment`**, passing the branch diff as
the subject, the lenses above as participants, and the milestone body as where
the minute goes.

No capability check: it ships in this plugin and is always present. The
conditional pattern above is for `paad:` and `ponytail:`, which may not be.

A single pass reports what one look caught; a fixed point reports that nothing
further is visible. **Bound it** at three iterations, as `crochet:execute` bounds
its analogous loop, then report non-convergence rather than spinning. A review
that will not converge is itself a finding about the delivery.

## Step 4: Verify the milestone's acceptance criteria

The decision's criteria are the milestone's. Run them and record which pass.

`git zhi verify <milestone> --dry-run` extracts from *done issues*, not from the
milestone body, so it does not see milestone-level criteria. Until it does,
extract and run them here.

## Step 5: Record the outcome

Write a checklist entry into the milestone body carrying **when the gate was
satisfied, by whom, and whether it was backfilled** — the three fields a derived
signal cannot supply. A trailer shows that execute ran; it cannot show that
review backfilled rather than ran in place.

**Write `state: accepted` into the decision when this gate backfilled the
assessment.** On the finished-pull-request path no chain is built and refinement
never runs, so nothing else records the acceptance — and `xt/run.sh` would then
report the decision's `Implements:` commits as a skipped gate, firing on a path
the protocol calls legal.

Where a checklist entry disagrees with its derived signal — ticked but
underivable, or derivable but unticked — that disagreement is itself a finding.

## Key Constraints

- **No command stub is optional here.** Review is user-invocable; it has one.
- **Delegate, never reimplement.** The lenses hold the checking logic; this skill
  orchestrates them.
- **Both lenses run every time.** One producing findings does not skip the other.
- **The reviewer is not the author.** Where the branch is the reviewer's own
  work, dispatch the lenses to fresh subagents rather than reading the diff
  inline — the composition rule in
  `docs/decisions/0003-acceptance-by-refinement.md` applies to this gate as much
  as to assessment.
