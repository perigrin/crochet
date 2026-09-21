---
stability: 1
covers:
  - skills/review/review.md
---

# Walkthrough: crochet:review

Observed on git-zhi 0.6.0 (`dbc364c`, built 2026-09-19), against a scratch
repository at `7e24e19`. Run by a dispatched agent that read the skill and
followed it literally.

Every step assumed state a repository acquires only after other gates have run.
All five findings below cost a change to `review.md`, and each was observed by
running a command rather than by reading one.

## The skill could not be invoked, only read

`crochet:review` and `crochet:discernment` exist in the worktree and in neither
installed cache (`0.4.0`, `0.5.0`), and neither appears in a runtime skill list.
The walkthrough followed the file rather than the skill.

That is a limitation of the walkthrough and also a finding: the skill justified
removing a capability guard with "it ships in this plugin and is always
present", which is **false against every installed copy**. True within a release,
not across one — the cache-versus-checkout hazard `development-workflow.md`
names, arriving in the wild.

## Preflight said review should not run, and cannot stop it

Orientation reported **row 1: "No chain yet — next gate is `crochet:assess`."**
Correct, and structurally inert: preflight's Key Constraints make orientation
advisory and say it never blocks. **Review's only state check was one that by
construction could not halt review.** Reading that output and stopping is now
the gate's own job.

## Step 1: the empty diff, which is worse than an error

The scratch repository *does* have a `pu` branch — it is the only branch and
`HEAD` is on it.

```
$ git diff pu...HEAD
$ echo $?
0
```

Empty output, exit 0. Not the missing-ref failure predicted: `pu...HEAD` resolves
cleanly and the subject of the review is nothing. Every downstream step then ran
normally over the empty set, and the skill had no way to notice — no guard, no
fallback, no instruction. **A review that examined a branch and found it sound
and a review of nothing produced the same output.**

`paad:agentic-review` guards this explicitly at its own pre-flight. Review now
does too, as Step 0.

## Step 2: an instruction naming a structure git-zhi does not have

The coverage lens said to read the decision named by *the milestone's*
`Implements:` trailers. A milestone has a free-markdown body and no trailers;
`Implements:` is a commit trailer. The instruction described a data model that
does not exist, and the skill's own escape hatch — read the decision directly —
was the only part of Step 2 that survived.

## Step 2: the lenses disagreed completely on identical input

- **`ponytail:ponytail-review`** returned **"Lean already. Ship."** It has no
  empty-diff guard, so its failure is silent and reads as good news.
- **`paad:agentic-review`** refused on three independent grounds: substantive
  session history, no determinable default branch (`origin/HEAD` unresolvable,
  no `main`/`master`/`trunk`, no remote), and a current branch that is itself
  the default.

So the Key Constraint "both lenses run every time" was **unsatisfiable**, and
the skill had no instruction for a lens that declines — written as though refusal
were not a thing a lens does, while the lens it delegates to refuses more readily
than the one it treats as optional.

**And "delegate" and "dispatch" were one word for two operations.** Invoking a
lens through the Skill tool loads its taxonomy into the caller's own context —
the lens becomes the reviewer wearing a hat. Only dispatch sends the subject to
something that has not read the reviewer's reasoning. Reviewer independence
depends entirely on which one happened, and the skill did not distinguish them.

## Steps 3 to 5: untested, and one claim still open

Step 3's delegation to `crochet:discernment` could not be exercised, because
discernment is not installed. So **"could a dispatched agent follow that
delegation" remains open rather than answered.** The walkthrough's argument that
it cannot — the loop requires resuming named participants and routing an author's
response, neither available to a dispatched agent — is from reading discernment's
text, not from running it. Worth testing deliberately once installed.

Steps 4 and 5 assume a milestone. The scratch repository has none, and the
invocation contract `crochet:review <milestone>` is not enforced by
`commands/review.md`, which passes no argument. Both now stop rather than
proceeding without one.
