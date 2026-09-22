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

## Step 0: Refuse to review nothing

**Resolve the base branch; do not assume it.** Crochet is installed into other
repositories, where the default is usually `main`. This skill hardcoded `pu` —
crochet's own default — so everywhere else `git diff pu...HEAD` wrote
`fatal: ambiguous argument 'pu'` to stderr and nothing to stdout, and the rule
below read that as a branch with nothing to review.

```bash
BASE=$(git symbolic-ref --quiet --short refs/remotes/origin/HEAD 2>/dev/null)
BASE=${BASE#origin/}
for b in "$BASE" main master trunk pu; do
    [ -n "$b" ] && git rev-parse --verify --quiet "$b^{commit}" >/dev/null && { BASE=$b; break; }
done
git rev-parse --verify --quiet "$BASE^{commit}" >/dev/null ||
    { echo "cannot resolve a base branch"; exit 1; }
git diff --stat "$BASE...HEAD"
```

**Key the guard on the exit status, never on the output being empty.** An
unresolvable ref and a branch with nothing on it produce the same blank stdout,
and only one of them means "nothing to review". Verify the base resolves first,
then read the diff.

**If the diff is empty, stop and say so.** Do not proceed to the lenses.

This is the one guard the gate cannot do without. A base that resolves to the
current branch gives empty output and exit 0, so without this check every
downstream step runs normally over nothing and reports a clean pass. A review of
the empty set and a review that examined a branch and found it sound are
indistinguishable in the output, and the first is worthless.
`paad:agentic-review` guards this explicitly — including the exit-status half,
which this skill cited and then did not do.

Everywhere below, `pu...HEAD` means `$BASE...HEAD` with the base resolved here.

**If no milestone was named**, resolve the active one the way `crochet:execute`
does — `git zhi milestone list --format json`, taking the milestone whose state
is not completed. Stop only if that is *ambiguous*; reviewing a delivery
requires knowing which delivery, but the name is usually derivable rather than
missing, and an empty result is the finished-pull-request path below rather than
a reason to halt.

This skill used to stop outright here, having observed that `commands/review.md`
passed no argument. The stub now passes `$ARGUMENTS`, as `commands/execute.md`
always did — diagnosing a defect in a sibling file and then halting on it left
the only entry point to a mandatory gate unable to run unattended.

**If preflight reported that there is no chain**, believe it — and then keep
going, because that is the entry path this gate exists for rather than a reason
to refuse.

`docs/decisions/0003-acceptance-by-refinement.md` settles it: code arrives fully
formed, "entry is at review", and "a chain is not backfilled". So the absence of
a chain is the normal state on this path, not a fault. This skill previously
stopped here, and stopping made the one mandatory gate that the finished pull
request enters at the one gate it could never run — the same shape as halting on
a sibling's missing argument, one paragraph up.

The subject is derivable without a chain: `$BASE...HEAD` is the branch diff and
needs no milestone. What a chain would have supplied is the minute's
destination, and `crochet:discernment` requires one, since a gate that leaves no
trace cannot be a precondition for anything. So on this path **write the minute
to `docs/assessments/<branch>.md`** rather than into a milestone body. The
assessment is backfilled on this path anyway, and the two belong in one place.

Stop only when the chain's state is *contradictory* — a milestone named on the
command line that does not exist, or several active ones — because then it is
unclear which delivery is being reviewed. Nothing to review is a different
condition, and Step 0's base-resolution guard above already catches it.

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

Find the decision from the **commits'** `Implements:` trailers — a milestone has
no trailers, only a free-markdown body, and an earlier draft of this skill said
otherwise:

```bash
git log pu..HEAD --format='%(trailers:key=Implements,valueonly)' | tr -d ' ' | sort -u
```

If that yields nothing, the delivery cites no decision and that is itself a
finding. Then read the decision and check its
acceptance criteria against what was built. Criteria live on the milestone once
refinement carries them across; on a milestone refined before that, read them
from the decision document directly.

**Then read the live documents against the diff.** Doc-first is a rule 0001
wrote and no gate has ever enforced. This is where it is enforced.

**A document is live when `CLAUDE.md` imports it, and `CLAUDE.md` is itself in
the set.** Naming the door explicitly matters, because it is excluded on every
other axis: it imports nothing of itself, carries no `covers:`, and sits outside
`docs/` where `docs health` cannot see it. It is also the one live document in
this repository with recorded drift, so a lens that could not read it would miss
the only failure of doc-first on record.

```bash
sed -n 's/^@//p' CLAUDE.md
```

For each of those documents whose `covers:` paths the diff touches,
**read the document against the diff**. Read `CLAUDE.md` on every diff, with no
`covers:` trigger: it is the door to the others rather than a fourth document,
and it gains no frontmatter to trigger on.

**A finding requires one of two things.** Either the diff **falsifies a claim**
the document makes, or it completes work the document **describes as pending**.
An enumeration the change renders incomplete is a falsified claim — a list of
four things in a document, where the branch adds a fifth, is false even though
every word of it still reads true.

**The quiet case is the common case and is not a finding.** Every live document
covers `skills`, so this fires on nearly every branch and will usually find
nothing. A diff under a covered path that the document never claimed anything
about is **not a finding**. Say that in the minute when it happens. A trigger
that fires on everything gets ignored exactly as one that fires on nothing does,
and the way it stops being ignored is that its quiet outcome is recorded rather
than omitted.

**This does not climb the enforcement ladder.** A step in a skill file is
instructions an agent follows, which is the same rung as the prose statements of
doc-first it backs. 0001 concedes that a mechanical check is unavailable for
this rule, and nothing here makes one available. What changes is who holds the
obligation and when: it moves from every author remembering, to one gate asking.

**Quality — is the code sound?**

**Availability is not the only question — a lens can be present and still not
run.** These arms were keyed on availability alone, and the case that actually
happens matched neither: `paad:agentic-review` is installed, refuses a session
carrying substantive history, and Steps 0 and 1 guarantee this session has some.
A gate can then complete having run no quality lens at all while reporting a
pass — the review of the empty set that Step 0 exists to prevent, one level up
in the same file.

So each lens has three outcomes, and the minute names which one occurred.

**If `paad:agentic-review` is available:**
  Dispatch it to a fresh session — not this one, which it will refuse.
**If it is available and declines, or its specialists do not return:**
  Load its taxonomy and run its lenses yourself, **sequentially**, one at a time.
  Record the result as inline rather than dispatched. This is a legal outcome
  and a weaker one; on this repository's own branch it is also the only one that
  ever produced findings.
**If it is absent:**
  Read the diff for debt, security and coverage gaps inline, and say so.

**If `ponytail:ponytail-review` is available:**
  Dispatch it — over-engineering is the lens it exists for.
**If it declines or does not return:**
  Apply it inline and label it inline.
**If it is absent:**
  Skip it and say so in the minute.

**A lens that declined is a gap in the review, not a pass.** Saying which of the
three happened, for each lens, is the difference between one lens looking and
two.

## Step 3: Run to a bounded fixed point

**Delegate the convergence to `crochet:discernment`**, passing the branch diff as
the subject, the lenses above as participants, and the milestone body as where
the minute goes.

No capability check: it ships in this plugin, so within any one release it is
either present with this skill or absent with it. The conditional pattern above
is for `paad:` and `ponytail:`, which vary independently.

**Across releases that is not true**, and a walkthrough hit it: `discernment`
exists in the checkout and in neither installed cache, so an agent running the
installed plugin while this file is newer finds the delegation unresolvable.
That is the cache-versus-checkout hazard `docs/contributing/development-workflow.md`
names, and the fix is the release discipline there — bump the plugin version and
the marketplace's, then confirm what you actually got — not a capability check
that cannot pass.

A single pass reports what one look caught; a fixed point reports that nothing
further is visible. **`crochet:discernment` owns the bound** — do not restate it
here. This skill said three, copying `crochet:execute`'s number, while
discernment argues at length that three is the wrong bound and would have
declared both of the sessions that produced it non-convergent. Restating a
callee's parameter is how it drifts.

## Step 4: Verify the milestone's acceptance criteria

The decision's criteria are the milestone's. Run them and record which pass.

**`git zhi verify <milestone>` runs the milestone body's criteria itself.** They
appear in their own `Milestone Acceptance Criteria:` section above the issue
rows, so run it rather than extracting by hand. `--dry-run` lists what would run,
across every issue regardless of state.

`crochet:preflight` reports the installed version against the declared floor.
It warns rather than blocking, so a reviewer on an older binary is told and is
not stopped — read the warning before trusting what `verify` extracted.

**The body's heading must be exactly `## Acceptance Criteria`.** The extractor
uses the same parser as an issue body, so a milestone headed
`## Milestone Acceptance Criteria` yields nothing — no rows, no warning, and
`verify` reporting that it extracted nothing. The trap is that the *output*
header reads `Milestone Acceptance Criteria:`, so the wrong guess is the natural
one.

**Confirm it ran rather than that it exited 0.** A milestone body carrying no
paren-wrapped command yields nothing to run, and a `verify` that extracted
nothing is not a milestone whose criteria passed. Read the count. `rfc-0003`'s
own body has no such section, so this step finds nothing at the milestone level
on the very milestone that introduced it.

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
- **Both lenses are put every time.** One producing findings does not skip the
  other. But a lens may *decline* — `paad:agentic-review` refuses a session with
  substantive history, a repository with no determinable default branch, and a
  branch that is itself the default. Record which lenses ran, which declined,
  and on what grounds. A declined lens is a gap in the review, not a pass, and
  saying so is the difference between one lens looking and two.
- **Delegating and dispatching are different acts, and the difference is the
  whole point.** Invoking a lens through the Skill tool loads its instructions
  into *this* context — the lens is then you, wearing its taxonomy. Dispatching
  sends the subject to an agent that has not read your reasoning. Independence
  requires the second. Where a lens can only be delegated, say so in the minute;
  a self-administered lens is evidence of a different and weaker kind.
- **The reviewer is not the author.** Where the branch is the reviewer's own
  work, dispatch the lenses to fresh subagents rather than reading the diff
  inline — the composition rule in
  `docs/decisions/0003-acceptance-by-refinement.md` applies to this gate as much
  as to assessment.
