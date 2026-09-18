---
title: Documentation architecture
type: rfc
state: proposed
author: Chris Prather
date: 2026-09-18
supersedes: []
superseded-by: []
implemented-by: []
---

# 0001: Documentation architecture

This is the first entry in `docs/decisions/` because it is the decision that
creates the series. It is numbered 1, not 0, because `git zhi docs health`
checks the sequence from 1 upward; a `0000` file would be one the only tool
watching this directory ignores. A document defining how to write these is a
separate decision, if it is ever needed.

The document is written in the format it proposes. If the format cannot carry
its own proposal, the format is wrong.

## Problem Statement

A survey of crochet, git-zhi and their prior art found the same failure nine
times, always one shape: **a document asserts something that was never built.**

| Instance | Asserted | Built |
|---|---|---|
| `skills/postmortem/postmortem.md` "Feedback Loop" — refinement reads past postmortems | yes | never |
| `covers:` + `stability` staleness checking in `git zhi docs health` | mechanism | every value is `[]` |
| `CONTRIBUTING.md` index to six doc directories | six links | two exist |
| crochet's `docs/contributing/` | correct structure | contents describe git-zhi's Go build |
| `docs/decisions/` for ADRs | linked | absent |
| RFD 0's own state (opendtrace) | three declarations | they disagree |
| `bot-Bender/docs/decisions/` | directory | empty |
| `architecture.md` template's maintenance story | "update as the codebase evolves" | an instruction and a hand-stamped date |
| rainbarf's author tests | three checks | over a manually maintained file list |

Six are in perigrin's repos, three in the prior art. Five are in this repo or
the tool it drives. It is not carelessness; it is what happens when a claim and
the thing it claims about live in separate files with nothing connecting them.

The fourth instance is worth naming precisely: `docs/contributing/` here is the
`git zhi docs init` scaffold template verbatim, Go build instructions included,
stamped into a repo with no build. The onboarding tool crochet ships produced
one of the failures crochet is diagnosing.

## Proposal

### Three documents, three referents

| Document | Question | Describes | Tense | Layer |
|---|---|---|---|---|
| `ARCHITECTURE.md` | what is this | the codebase | present | live |
| `CONTRIBUTING.md` | how do I work on it | the DevEx tooling | present | live |
| `docs/decisions/` | why is it like this | both, historically | past | archive |

**DevEx tooling is to `CONTRIBUTING.md` as the codebase is to `ARCHITECTURE.md`.**
That parallel makes `CONTRIBUTING.md` an architecture document for the workflow,
not a rulebook. An architecture doc does not inline the source, so
`CONTRIBUTING.md` says `make lint`, never "use two-space indents"; the linter
config is the truth.

`CLAUDE.md` is not a fourth document. It is the agent's door onto the two live
ones and `@import`s them rather than restating them. For an agent an import is
static linking; a bare "see CONTRIBUTING.md" is a dynamic lookup that may not
happen.

The git-zhi chain sits outside the triad. It is transient work state, which is
why it is ephemeral and why nothing cites it. Durable citations point at commits.

### Two layers, four ways of staying true

**Live** must be true now and is rewritten in place. **Archive** is append-only
and true as of its date. The useful question is not which layer a document is
in but what keeps it true:

| Discipline | Kept true by | Can it drift? |
|---|---|---|
| Self-maintaining | the tool; every mutation goes through it | no |
| Derived | nothing to sync; current view is a query over an append-only log | no |
| Verified | drift detection flags it, a human repairs | yes, visibly |
| Immutable | nothing; it claims nothing about now | n/a |

Hooks, linters and the chain are self-maintaining. Prose is verified at best.

Archive costs one write and no upkeep. Every line in the live layer is a line
someone must keep true forever. So: **stingy with live, generous with archive.**
Write the postmortem every time; promote almost nothing out of it. That
asymmetry is what damps the feedback loop, not a threshold anyone has to pick.

Corollary: the live layer needs eviction, not only addition. A live doc whose
`covers:` sources moved and that nobody repaired is a doc nobody needed.

### Doc-first

**Update the live document first, then build to match, in one PR.**

- `ARCHITECTURE.md` changes and the code land together.
- `CONTRIBUTING.md` changes and the DevEx tooling that enforces them land together.

This is TDD at architecture altitude: write the statement that is false, make
it true. The document is temporarily false on the branch; that is the red
state, not a defect. The benefit is design pressure. An architecture statement
you cannot write in two clear sentences is a change you have not finished
thinking about.

Honest asymmetry: a test is machine-checkable and an architecture statement is
not. This buys the discipline, not the proof. A PR can land where the statement
overreaches what was built, and only a reader catches it.

What it does buy is decisive. Every failure in the table is a document
asserting something never implemented, and doc-and-code in one PR makes that
state unreachable rather than detectable. Every other check in this proposal is
detection after the fact. This is the only one that prevents.

For agents there is no asymmetry: the live doc is the prompt, so editing it is
deploying. It needs tests, and a markdown-only repo has no excuse for having
none.

### The enforcement ladder

For any rule that must hold:

| Rung | Mechanism | Cost | Guarantee |
|---|---|---|---|
| 1 | make the wrong thing impossible: API shape, one operation that writes both sides | once | total |
| 2 | make it fail loudly: hook, linter, CI, test | once | deterministic |
| 3 | put it in the agent's prompt | every invocation | strong prior |
| 4 | state it for humans to remember | every reader | hope |

Each rung down costs more, forever, and guarantees less. If a procedure has to
be strict, it cannot be prose. Most of the nine failures were rules stated at
rung 3 or 4 that needed rung 1 or 2.

For agents, moving down the ladder improves cost and strength at once: a prompt
line costs context on every run and yields a prior; a hook costs nothing at
rest, fires only when relevant, and is deterministic. Hence the placement rule:

> The right home for a piece of documentation is inside the error message of
> the guardrail that enforces it.

A guardrail's failure mode is invisibility. A hook that rejects without
explaining makes an agent flail, retry, and burn context. An actuator you
cannot observe is not finished.

Values are the exception. *Prefer simple over clever* is not method-of-work and
no hook will check it; it belongs in the identity document, not here.

### The decision archive

**One genus.** PRD ⊆ RFD/RFC ⊆ ADR. Each adds content and constraint to the
same base: a dated record of a choice and its rationale under a stable
identifier. They diverge while live and converge once frozen. So: one series,
one number space, a `type:` discriminator, not four directories. `type` is a
routing key: it names which live document an accepted decision projects into.

**Number is identity, title is not.** Documents are numbered so titles can
change. Cite the number. `git zhi docs health` already indexes this directory by
number and exempts it from both reachability and staleness checks; the tooling
agrees with the design, and what was missing was the instance.

**States**, distinguishing three ways of not being in force:

- `proposed` → `accepted` → `implemented` (with commit citations)
- `declined`: proposed, never accepted
- `abandoned`: accepted, never implemented
- `superseded`: was right, stopped being right

`implemented` is the contribution over both prior arts. ADR stops at accepted,
RFD at published; both assume the decision is the artifact. For a decision that
requires work, accepted-but-not-built is a real and dangerous state, and an
empty `implemented-by:` field makes it visible instead of silent.

**Cite commits, not chains.** Record post-merge SHAs or PR numbers. A
rebase-and-force-push workflow rewrites every SHA on a feature branch, so a
mid-flight SHA is a reference that quietly stops existing.

**Supersession is bidirectional.** `supersedes` and `superseded-by`, both
written, in one commit. This duplicates a fact deliberately: derive when a tool
is guaranteed to be in the read path, duplicate when the document may be read
alone. Archive docs are read alone constantly. The consistency obligation is
then discharged mechanically (orphan links and cycles are cheap to check),
never by discipline.

**State is declared in one place**, the `state:` field. The directory is not
the state; proposed and accepted documents share it. RFD 0 declares its state
in three places and they disagree, which is the failure this rule exists to
make impossible.

**Mutability follows state.** A `proposed` document is under discussion and may
change. From `accepted` on it is immutable in content and append-only in
status: `state`, `implemented-by`, `superseded-by`.

**Inclusion gate.** Write one for a decision you would otherwise re-litigate.
The well-attested failure of ADRs is enthusiasm through 012 and then silence, a
partial archive that implies completeness. The gate is what keeps the series
honest, and it doubles as damping: most lessons fail it and stay in postmortems.

### Tests: `t/` and `xt/`

The Perl convention, not an invention.

- `t/` tests the product: does the code do what `ARCHITECTURE.md` claims.
- `xt/` tests the project: does the repo do what `CONTRIBUTING.md` claims.

`xt/` is where guardrail-fires tests, doc health, `covers:` staleness and
supersession symmetry live. None of it ships to a consumer.

Guardrails need a test whose only assertion is that they fire. A hook that
silently stopped firing has failed open, which is worse than absent, because
you stopped watching for what it caught.

Wire the checks into an operation nobody can skip. The Perl precedent is
`distdir` depending on the author tests. The git-zhi analogue exists:
`git zhi milestone --state complete`, where `postmortem` already hooks in.

`xt/` is a Perl convention; Go and markdown repos do not inherit a runner. The
runner is a small thing each repo writes.

### Compiler, not runtime

Two independent arguments put all of this in the repo, not the plugin:

1. In-repo guardrails and in-repo docs version together. You cannot check out a
   commit where the hook and `CONTRIBUTING.md` disagree about what is enforced.
   Anything in a plugin or global config can skew.
2. The mechanism is ecosystem-shaped, and a plugin cannot know which ecosystem
   it is in until it arrives.

So crochet ships the pattern; the repo ships the instance. The testable
constraint:

> A repo crochet onboarded should still pass its own checks with crochet
> uninstalled.

If it cannot, the guardrails belong to the plugin, not the project.
`crochet:onboard` is the home for installing them.

Cost, stated plainly: this trades version skew for copy drift, N repos with N
copies that diverge as the pattern improves. Drift is visible (a check exists
and passes, or it does not) where skew is silent. Idempotent re-onboarding is
the repair.

## Scope of Change

What changes in this repository if accepted. Each item is a live-layer edit and
lands with whatever makes it true, per doc-first.

- **`ARCHITECTURE.md`**: create. The "Architecture" and "Conventions" sections
  of `CLAUDE.md` describe the codebase and move here. `CLAUDE.md` `@import`s
  `ARCHITECTURE.md` and `CONTRIBUTING.md` and keeps only what is agent-specific.
- **`CONTRIBUTING.md`**: describes crochet's actual DevEx. There is no build;
  validation is reading a skill for internal consistency and checking that
  every `git zhi` subcommand it names exists. The "Short Links" section lists
  only directories that exist. Four of its six links (`decisions`, `guides`,
  `architecture`, `reference`) dangle today; this document makes `decisions`
  real and the other three are removed, not scaffolded.
- **`docs/contributing/`**: removed. Its two files are the git-zhi scaffold
  template and describe a Go build this repo does not have. What is true of
  crochet's workflow is short enough to live in `CONTRIBUTING.md` itself.
- **`covers:`**: no live doc carries `covers: []`. A live doc declares the paths
  it covers so `git zhi docs health` can see it drift, or it is evicted. Today
  the only two docs with the field have it empty.
- **`skills/postmortem/postmortem.md`**: the "Feedback Loop" section asserts a
  contract nothing implements. It is removed. Whether and how refinement reads
  past postmortems is a separate decision; the parked design in the
  commonplace book argues the literal contract is the wrong shape.
- **`xt/`**: created, with a runner. First checks: `git zhi docs check` (dead
  links, ADR gaps, invalid `covers:` paths, already built), supersession
  symmetry across `docs/decisions/`, and a test that each installed hook fires.
  These depend on `git zhi`, not on the crochet plugin, and pass with it
  uninstalled.
- **`crochet:onboard`**: this is a plugin change, not a repo-doc change, and is
  noted here because the fourth instance in the table was produced by it.
  Onboard stamps the git-zhi scaffold into whatever repo it meets. Under this
  proposal it installs the pattern (the triad, `xt/`, the hooks) fitted to the
  repo's ecosystem. That work is its own decision with its own number.

`implemented` for this document means the first six items above are in `pu`,
cited in `implemented-by:`.

## Open Questions

Carried from the design as open, not resolved here.

- Who accepts a proposal. Currently perigrin, the same seat as the value-loop
  setpoint in the parked self-driving design.
- Whether PR numbers beat merge SHAs as the implementation citation.
- Whether the glossary is the one hand-maintained section of `ARCHITECTURE.md`
  or whether terms get defined in the decisions that introduce them.

Surfaced by writing this document in its own format:

- `type:` is asked to carry two facts: which member of the genus this is (prd,
  rfc, adr) and which live document it projects into. For this document they
  are `rfc` and `CONTRIBUTING.md`, and the field holds one of them. Either the
  genus implies the target, or the target needs its own field.

## References

- Architecture Decision Records, https://adr.github.io. Supersession as an
  append-only archive from which "what is in force" is derived.
- OpenDTrace Requests for Discussion, https://github.com/opendtrace/rfd. The
  `state` field as the live-to-archive transition; number as identity;
  interface-shaped inclusion gate.
- architecture.md template, https://architecture.md. Instance eight.
- Explicitly running author tests,
  https://elliotlovesperl.com/2009/11/24/explicitly-running-author-tests/. The
  `xt/` convention and `distdir` gate.
- `pages/repo-documentation-architecture.md` in perigrin's commonplace book,
  where this design was worked out.
