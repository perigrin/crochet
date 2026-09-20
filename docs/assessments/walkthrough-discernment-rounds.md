---
stability: 1
covers:
  - skills/discernment/discernment.md
---

# Walkthrough: crochet:discernment across rounds

Two participants, three rounds, a subject that changed between each. Run
against a scratch repository, revisions `01782d3`, `b7d65d0` and `39d8f85`.
Observed on git-zhi 0.6.0.

This is the walkthrough the first one could not be. That session had a single
participant, one round, and a brief that announced a defect had been seeded — a
stronger instrument than the skill relies on, which guaranteed a first-round
finding by a route the skill does not use. Here the brief was the one the skill
specifies: who wrote the subject, and where they are likely blind. Neither
participant was told a defect existed.

## The brief works

Both participants were told the author's likely blind spot was "treating a
rule's uniformity as evidence that the rule is right". Both went straight to the
acceptance criteria and broke them **by construction**, in round one, without
being told any defect existed:

- `grep -lq Prerequisites skills/*.md` is an **any-check wearing an
  every-check's prose**. It looked correct only because the tree held one skill,
  where "any" and "every" coincide — it goes blind at the moment the second skill
  lands, which is the first moment the rule matters.
- The second criterion **failed a skill that complied** with the proposal's own
  instruction, and **passed a self-exemption on case alone**. It was also
  fail-open: `grep -r` on a missing directory exits 2, and negated that is a
  pass, so deleting `skills/` turned it green.

One participant also observed why the first defect was invisible: *"with one
file, a broken 'every' check and a working one produce identical output… the
proposal's own scope hid its own criterion's defect."*

And a sharper form of a rule this repository already holds: a red/green pair
where the green is unconditional **satisfies "one check that passes today for
every check that fails today" while defeating it.** The rule exists to catch a
harness that never ran; a green that cannot fail passes the rule and proves
nothing.

Neither manufactured a disagreement with the proposal's core argument. One said
so explicitly: being told where to look hardest is not being told what to find.

## What a resumed participant actually does

This is what the session existed to answer, and the answer is neither of the two
that were expected.

> **I re-read the file and re-ran everything. I did not re-derive the findings.**
> They and their "addressed when" bars were already in my context, and I used
> them as a checklist. So this was verification, not independent re-derivation.

The other, independently, drew the same line in different words: it carried
forward the *definitions* of its findings — "which is what notes are for" — and
carried forward **no conclusion about the file**.

Both volunteered their own bias without being asked.

> two of my four releases are against bars I wrote myself, and a bar I authored
> is one I am inclined to find met.

> I nearly accepted a green-for-the-wrong-reason about my own finding… exit 1 is
> also what a malformed `test` returns. If I had stopped at the live-tree run I
> would have released on an exit code I had not earned.

And one caught itself mid-coast, which is the single most useful observation of
the session:

> My round-one text said "fixing F1 makes F4 go away." Arriving here, finding F1
> fixed, the pull to release F4 unexamined was strong — and the uniformity
> paragraph is byte-identical in the diff, so there was nothing to re-read that
> looked new. I re-read it on its own terms anyway, and that turned up something
> I had missed. I would have missed that by trusting my previous self.

So neither participant re-derived its findings from a blank slate, and both said
so when asked plainly. **That makes "only the raiser releases its own finding"
necessary and not sufficient.** A raiser verifying against its own bars, biased toward finding them
met, with nothing in the diff to prompt a second look at what did not change, is
a raiser that can release a live objection without examining it.

The four techniques that caught it — read the diff last, carry definitions not
conclusions, bracket an exit code before trusting it, and score against your bar
rather than what landed near it — are now in the skill, because each of them
caught something here.

## Does it get worse with each round?

Yes, and not where it was expected. Round three was asked this directly, and the
answer separates two things that look alike.

**Effort did not fall.** The third round cost *more* than the second: seven new
fixtures built from scratch for a new criterion. A participant also volunteered
that re-running the earlier battery had been a control rather than a discovery,
since the diff showed those criteria byte-identical — "I would be overstating my
diligence if I let 'I re-ran the whole battery' stand without that."

**The reflex did worsen.**

> Reading the new Problem Statement, I thought "that's F3, released" before I
> had checked whether the rest of the document was consistent with the new
> framing. I did then go check. But three rounds in, the reflex to pattern-match
> a paragraph against a stored finding and discharge it is measurably stronger
> than it was in round two.

Nothing was released on that reflex. The participant declined to promise the
same of a fourth round, and proposed the guard now in the skill: **before looking
at whether a fix landed, say what it would have to also change.** Predicting the
blast radius first is what stops a correct-looking paragraph from closing a
finding whose other half is untouched.

It also reported a methodology drift rather than papering over it — bundling one
live check into the same tool call as the diff, breaking its own file-first,
diff-last ordering, in a way that contaminated nothing and was still not what it
had claimed to be doing.

## What this still did not test

The bound of eight was not approached; three rounds is well inside it. The minute
was drafted by the caller rather than a dispatched drafter, so
drafter-does-not-decide remains unexercised. And whether the reflex keeps
worsening past round three is unknown — the participant was explicit that it
would not vouch for a fourth.
