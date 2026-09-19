---
title: Integrating ponytail, paad and superpowers
state: proposed
author: Chris Prather
date: 2026-09-19
supersedes: []
superseded-by: []
---

# 0005: Integrating ponytail, paad and superpowers

**This entry is a placeholder. Its Problem Statement is written; its Proposal
awaits brainstorming.** The problem is recorded now because the evidence for it
was gathered while assessing 0004, and evidence that lives only in a
conversation is evidence that has to be found again.

## Problem Statement

Crochet builds on three plugins and integrates two of them.

**superpowers and paad are integrated through a declared pattern.**
`crochet:preflight` maintains a capabilities manifest at
`.claude/crochet/capabilities.json`, cross-checks it against the skill list the
runtime provides, and returns a capabilities map. Five skills — `assess`,
`execute`, `postmortem`, `preflight` and `refinement` — consume that map through
one conditional form:

> **If `<skill>` is available** — delegate to it, following that skill rather
> than restating it.
> **Otherwise** — the inline fallback.

The result degrades honestly. A machine without paad runs assess's inline spec
checks instead of `paad:pushback`, and the skill says so in its own text.

**ponytail is not integrated at all.** It is installed at
`~/.claude/plugins/cache/ponytail/`, activated by a SessionStart hook in the
user's `settings.json`, and named nowhere in this repository. Crochet does not
detect it, declare it, or degrade without it.

That is not a cosmetic omission, because it changes crochet's output. Assessing
0004 caught a running tally of past incidents in a design document — prose that
`docs/contributing/coding-conventions.md` forbids as a product rule:

> Names are evergreen [...] Comments describe the code as it stands, not how it
> got there.

Neither gate that reads a spec would have caught it. `assess` Step 0 checks
contradictions, ambiguity, scope red flags, missing error handling and security
surface. `paad:pushback` checks contradictions, feasibility, scope imbalance,
omissions, ambiguity and security. The catch came from ponytail, which is to say
it came from one machine's configuration.

**So a stated product rule of crochet's is enforced by a plugin crochet does not
know about.** The same pipeline, run where ponytail is absent, produces a worse
document and reports the same green.

### Why this is not simply a third manifest entry

The detection mechanism does not reach it. Preflight builds its map by comparing
`superpowers:*` and `paad:*` **skill names** against the manifest, because a
skill is a nameable thing the runtime advertises. Ponytail is not a skill. It is
a hook that installs a standing behavioural instruction, and a hook does not
appear in a skill list.

Two plugins expose capabilities that can be called; the third changes how
everything is written. Integrating the third is therefore a different problem
from the one the conditional pattern was built for, not a wider application of
it.

## Proposal

Pending. To be brainstormed, per the protocol that a decision enters at
`superpowers:brainstorming` rather than at refinement.

What the brainstorm has to settle is recorded under Open Questions rather than
guessed at here, because a placeholder that invents a proposal is worse than one
that admits it has none: the invented version gets read as a decision.

## Open Questions

- **Can a hook-installed behaviour be detected at all?** If preflight cannot see
  ponytail, "integration" may mean declaring a dependency crochet cannot verify
  — which is the shape of failure 0001's enforcement ladder warns about, a claim
  with nothing connecting it to the world.
- **Should crochet depend on it, or absorb the rule?** The evergreen-prose rule
  is crochet's own, stated in its own conventions. A rule crochet owns arguably
  belongs in crochet's gates rather than borrowed from a plugin that happens to
  be installed. That argues for adding the check to `assess` Step 0 and treating
  ponytail as a bonus rather than a dependency.
- **Is any of it mechanically checkable?** Temporal markers have a shape a grep
  can find; a tally written in prose does not. A partial check risks the failure
  it is meant to prevent — a pass on the mechanical subset read as a clean bill.
- **Does `coding-conventions.md` need correcting first?** It currently says the
  archive "carries the history, and that is the only place tense belongs", which
  reads as permission for exactly the prose that was cut from 0004. The
  distinction that holds is between design rationale and incident history, and
  it is not written down anywhere.
- **What is the relationship to 0004?** Both concern what governs the quality of
  a document. Whether this amends anything, or stands alone, is not yet known.

## References

- `0001-documentation-architecture.md`. The enforcement ladder, and the
  requirement that a rule name what connects it to the world.
- `0004-architecture-synthesis.md`. Assessed while this problem was found.
- `skills/preflight/preflight.md`. The capabilities manifest and the detection
  mechanism that does not reach a hook.
- `docs/contributing/coding-conventions.md`. The evergreen rule that nothing
  currently enforces.
