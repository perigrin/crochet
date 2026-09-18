---
title: Documentation architecture
state: proposed
author: Chris Prather
date: 2026-09-18
supersedes: []
superseded-by: []
---

# 0001: Documentation architecture

This is the first entry in `docs/decisions/` because it is the decision that
creates the series, and it defines the series it is written in. It is numbered
1, not 0, because `git zhi docs health` checks the sequence from 1 upward; a
`0000` file would be one the only tool watching this directory ignores.

The document is written in the format it proposes. If the format cannot carry
its own proposal, the format is wrong.

## Problem Statement

A survey of crochet, git-zhi and their prior art found the same failure nine
times, always one shape: **a document asserts something that was never built.**

| Instance | Asserted | Built |
|---|---|---|
| `skills/postmortem/postmortem.md` "Feedback Loop" — refinement reads past postmortems | yes | never |
| `covers:` + `stability` staleness checking in `git zhi docs health` | mechanism | only two docs carry the field; both `[]` |
| `CONTRIBUTING.md` index to six doc directories | six links | two exist |
| crochet's `docs/contributing/` | correct structure | contents describe git-zhi's Go build |
| `docs/decisions/` for ADRs | linked | absent |
| RFD 0's own state (opendtrace) | three declarations | they disagree |
| `bot-Bender/docs/decisions/` | directory | empty |
| `architecture.md` template's maintenance story | "update as the codebase evolves" | an instruction and a hand-stamped date |
| rainbarf's author tests | three checks | over a manually maintained file list |

Five are in this repo or the tool it drives. It is not carelessness; it is what
happens when a claim and the thing it claims about live in separate files with
nothing connecting them.

Two of the five have consequences inside crochet's own pipeline:

- `covers:` is not only a git-zhi health input. The technical writer agent
  (`skills/refinement/techwriter-prompt.md`, "Assess Documentation Impact")
  reads each existing doc's `covers` field to decide which code issues need a
  doc-update step. With every value `[]`, that step has never fired.
- `docs/contributing/` is the `git zhi docs init` scaffold template verbatim,
  Go build included. `crochet:onboard` Step 2 and `crochet:refinement` Step 1
  both run `docs init`. The onboarding tool crochet ships produced one of the
  failures crochet is diagnosing.

Two more are not in the table because they are not assertions, but they are
the same gap seen from the other side: decisions made without a record.

- The AC-executability contract (paren-wrapped span, run verbatim by
  `git-zhi-verify` at `--state complete`) is a contract with git-zhi that four
  skills now depend on. It landed in PR #9 as prompt text in four files and a
  commit message. There is no document to cite when it is next questioned.
- The v0.4 postmortem's "What to change" item 3 asked for a project ruling on
  ABOUTME placement under YAML frontmatter. No ruling was recorded. Practice
  converged by imitation: ten of twelve ABOUTME-bearing files use an HTML
  comment after the frontmatter, one uses `# ABOUTME:`, and `CLAUDE.md`'s
  Conventions section says nothing. That is a lesson that stayed in the archive
  because there was nowhere for it to go.

## What Is Already True

This proposal is a layer over an implementation that already does most of
what it describes. Recording that is the point of an archive; proposing it as
new would be the failure in the table.

| Practice | Where it already lives |
|---|---|
| A dated, frozen design document precedes each change | `docs/plans/*-design.md`; the how-to-use-git-zhi spec took six edits, all before its merge, none after |
| A retrospective is written at every milestone completion | `skills/postmortem/postmortem.md`, Trigger; `docs/postmortems/` |
| Doc and code are one unit of done | techwriter adds a doc-update step to each code issue whose paths a doc covers |
| A machine check at an operation nobody can skip | `git-zhi-verify` runs every AC command at `milestone edit --state complete`; chain-review Step 2.5 dry-runs the same extractor before execution |
| A document that yields to the tool when they disagree | `crochet:how-to-use-git-zhi`, "When this reference and the CLI disagree": `--help` wins |
| A self-maintaining document | the capabilities manifest, re-derived by preflight on every invocation |
| The agent's door points at the contributor doc | refinement Step 1 creates `CLAUDE.md` pointing at `CONTRIBUTING.md` and checks the reference on later runs |
| The procedure works without the plugin | `skills/onboard/onboard.md`, Key Constraints: "A human can execute this procedure from the terminal without Crochet" |
| Decisions are numbered sequentially in `docs/decisions/` | `techwriter-prompt.md`, Constraints; `git zhi docs health` checks the sequence for gaps |
| Each milestone carries a resolution command that gates completion | `architect-prompt.md` step 5; `docs/plans/v0.4-milestone-body.md`, Resolution |

What is missing is narrower than the source design assumed: a `state` field and
a stable identifier on the design documents, implementation citations, the
live layer fitted to what the health check can see, and any test that the
repo's own guardrails fire.

## Proposal

### Three documents, three referents

| Question | Describes | Tense | Layer | In this repo |
|---|---|---|---|---|
| what is this | the codebase | present | live | `docs/architecture/` |
| how do I work on it | the DevEx tooling | present | live | `CONTRIBUTING.md` + `docs/contributing/` |
| why is it like this | both, historically | past | archive | `docs/decisions/` + `docs/postmortems/` |

**DevEx tooling is to the contributor doc as the codebase is to the
architecture doc.** That parallel makes the contributor doc an architecture
document for the workflow, not a rulebook. An architecture doc does not inline
the source, so the contributor doc says `git zhi docs check`, never the rule
the check enforces; the check is the truth.

The referents are the source design's; the file locations are the scaffold's,
because the scaffold is what the tooling can see. `git zhi docs check` walks
`docs/` and roots reachability at `CONTRIBUTING.md`; `git zhi docs health`
reads `covers:` only from files under `docs/`. A top-level `ARCHITECTURE.md`
would be invisible to both. So `CONTRIBUTING.md` is the index, the
covers-bearing live documents live under `docs/architecture/` and
`docs/contributing/`, and the scaffold's remaining directories (`guides`,
`reference`) exist when something lives in them, not before.

`CLAUDE.md` is not a fourth document. It is the agent's door onto the live
layer and `@import`s it rather than restating it. For an agent an import is
static linking; a bare "see CONTRIBUTING.md", which is what refinement Step 1
creates today, is a dynamic lookup that may not happen.

The git-zhi chain sits outside the triad. It is transient work state, which is
why it is ephemeral and why nothing cites it. Durable citations point at
commits.

### Two layers, four ways of staying true

**Live** must be true now and is rewritten in place. **Archive** is append-only
and true as of its date. The useful question is not which layer a document is
in but what keeps it true:

| Discipline | Kept true by | Can it drift? | Here |
|---|---|---|---|
| Self-maintaining | the tool; every mutation goes through it | no | capabilities manifest, the chain |
| Derived | nothing to sync; current view is a query over an append-only log | no | "what is in force" over `docs/decisions/` |
| Verified | drift detection flags it, a human repairs | yes, visibly | `covers:` docs under `docs/` |
| Immutable | nothing; it claims nothing about now | n/a | `docs/plans/`, `docs/postmortems/` |

Prose is verified at best.

Archive costs one write and no upkeep. Every line in the live layer is a line
someone must keep true forever. So: **stingy with live, generous with
archive.** The postmortem is already written every time; almost nothing is
promoted out of it, and that asymmetry, not a threshold, is what damps the
feedback loop.

Corollary: the live layer needs eviction, not only addition. A live doc whose
`covers:` paths moved and that nobody repaired is a doc nobody needed.

### Doc-first

**Update the live document first, then build to match, in one PR.**

The pipeline is already doc-first at spec altitude: the spec exists before the
chain, the chain before the code, and alignment checks the chain against the
spec. The techwriter makes the doc-update step part of each code issue. This
rule names the practice and extends it one level: a change to what
`docs/architecture/` or `docs/contributing/` claims lands with the code or
tooling that makes the claim true, and the claim is written first.

This is TDD at architecture altitude. The document is temporarily false on the
branch; that is the red state, not a defect. The benefit is design pressure: an
architecture statement you cannot write in two clear sentences is a change you
have not finished thinking about.

Honest asymmetry: a test is machine-checkable and an architecture statement is
not. This buys the discipline, not the proof.

What it does buy is decisive. Every failure in the table is a document
asserting something never implemented, and doc-and-code in one PR makes that
state unreachable rather than detectable. Every other check in this proposal is
detection after the fact.

For agents there is no asymmetry: the live doc is the prompt, so editing it is
deploying. `CLAUDE.md` currently says this repo has no test suite. Under this
proposal that sentence becomes false in the same PR that makes it false.

### The enforcement ladder

For any rule that must hold:

| Rung | Mechanism | Cost | Guarantee |
|---|---|---|---|
| 1 | make the wrong thing impossible: API shape, one operation that writes both sides | once | total |
| 2 | make it fail loudly: hook, linter, CI, test | once | deterministic |
| 3 | put it in the agent's prompt | every invocation | strong prior |
| 4 | state it for humans to remember | every reader | hope |

Each rung down costs more, forever, and guarantees less. If a procedure has to
be strict, it cannot be prose. Most of the failures in the table were rules
stated at rung 3 or 4 that needed rung 1 or 2.

For agents, moving down the ladder improves cost and strength at once: a prompt
line costs context on every run and yields a prior; a hook costs nothing at
rest, fires only when relevant, and is deterministic. Hence the placement rule:

> The right home for a piece of documentation is inside the error message of
> the guardrail that enforces it.

Crochet already has the rung-2 half of this for acceptance criteria:
`git-zhi-verify` fails the milestone. The rung-3 half, the contract explaining
what the extractor runs, is stated in four skill files. The ladder says the
next move is into the extractor's own dry-run output; that is a git-zhi change
and not proposed here.

A guardrail's failure mode is invisibility. A hook that rejects without
explaining makes an agent flail, retry, and burn context.

Values are the exception. *Prefer simple over clever* is not method-of-work and
no hook will check it; it belongs in the identity document, not here.

### The decision series

**One genus.** PRD ⊆ RFD/RFC ⊆ ADR. Each adds content and constraint to the
same base: a dated record of a choice and its rationale under a stable
identifier. They diverge while live and converge once frozen, which is exactly
how `docs/plans/*-design.md` already behaves: edited under review, untouched
after merge. So: one series, one number space, one directory — not one
directory per kind, and no field naming the kind.

**Identity.** The filename is `NNNN-kebab-title.md`, four digits, matching what
`git zhi docs health` already checks. The number is the citation; the title is
free to change. Cite the number.

**No kind field.** An earlier draft carried `type:` — `prd`, `rfc`, `adr` —
doing two jobs. Both are dropped. As a genus label it re-erects the boundary
the containment argument just dissolved, and invites an unanswerable argument
about whether a given document is really a requirement or really a decision.
As a routing key naming which live document the decision projects into, it is
redundant with the implementing commits, which show what changed rather than
what was intended, and wrong in shape besides: one decision can change both the
architecture and the method. Intent is carried by the Scope of Change section,
in prose; fact is carried by the commits.

**What belongs here.** In this repo the ordinary entry is the design spec that
`crochet:assess` takes as input. A postmortem is archive but not a decision; it
stays in `docs/postmortems/`, keyed by milestone, and a lesson in it that earns
a decision gets a number here. That is the promotion path: postmortem (what
happened) → decision (what we chose and why) → live layer (what is in force).

**Frontmatter.** Every entry carries `title`, `state`, `author`, `date`,
`supersedes`, `superseded-by`. Six fields, and every one is a relation or a
status. That is the test for any field proposed later: if it answers "what kind
of thing is this", it does not belong; if it answers "where does this stand and
what does it connect to", it does. `covers:` would pass the test but is a
live-layer field, and git-zhi already exempts this directory from drift
checking, so it stays out along with `stability:`.

**Sections.** Problem Statement, then Proposal, are required. Scope of Change
is required for any entry that calls for work: it names the live
documents and code the decision projects into. Acceptance Criteria is required
in the same case, in the form the pipeline already enforces: one runnable
command per checkbox line in a paren-wrapped backtick span, so that
`git-zhi-verify` can run it. Open Questions and References are optional.

**States.** `state:` carries only the four a human declares:

- `proposed` → `accepted`
- `declined`: proposed, never accepted
- `superseded`: was right, stopped being right

**Implementation status is not among them.** *Implemented* and *abandoned* are
derived from the trailers described below: a decision with a reachable
`Implements:` commit is built, and an accepted one without is abandoned. They
were never declarations. The rule under it:

> A declared state is an act of judgment. A derived one is a fact about the
> world. Judgment goes in frontmatter; facts get queried.

Declaring them would repeat the objection that removes the citation field
below — a second write nobody performs at authoring time — and would give "was
this built" two sources that can disagree. In the discipline table it moves
implementation status out of **Verified** and into **Derived**: one row up, and
it stops being able to drift.

The two declared transitions are the pipeline's existing gates, named:

| Transition | Already happens at |
|---|---|
| written → `proposed` | brainstorming produces the spec; `crochet:assess` reads it |
| `proposed` → `accepted` | chain-review passes and the human says execute |

Today the second is an event with no record in the document.

**Accepted-but-not-built remains the contribution over both prior arts.** ADR
stops at accepted, RFD at published; both assume the decision is the artifact.
For a decision that requires work that state is real and dangerous. It is now a
query rather than a field, which is strictly better: a field can be stale, a
query cannot.

**The citation is a commit trailer.** Every commit implementing a decision
carries `Implements: NNNN` in its message. That is the whole mechanism; there
is no corresponding frontmatter field, and the relation is recovered by
searching:

```bash
git log --grep='^Implements: 0001'
```

Three reasons the citation lives in the commit rather than pointing at it:

1. **It cannot be written anywhere else.** Doc-first puts the document and the
   code in one PR, but a post-merge SHA does not exist until that PR merges. A
   field would need a second write, after the fact, that nothing forces — and
   the table already records what becomes of a field nobody is obliged to fill.
2. **It survives the workflow.** A rebase-and-force-push rewrites every SHA on
   a feature branch while preserving commit messages, so a trailer is immune to
   exactly the operation that makes a recorded SHA dangle.
3. **It leaves one source.** A field mirroring the trailer is a second place
   for "was this built" to be declared, and two declarations can disagree —
   which is RFD 0's failure, three states that contradict each other.

This makes `abandoned` computable rather than noticed: at milestone completion,
an accepted decision with no reachable commit carrying its trailer is abandoned
by definition. Unreachability from `pu` is the correct reading — work on a
branch that never merged is work that never happened.

Net: the only thing written by hand is one trailer line. Citation, state and
abandonment all fall out of it plus an operation already running, which moves
the bookkeeping from rung 4 to rung 2 — the first point in this design where it
stops depending on anyone's diligence.

The cost is real: a decision read with no shell, on a web view or in an agent's
context, no longer shows whether it shipped. That is unavoidable rather than a
tradeoff, because the alternative is not a correct field but a stale one —
`accepted` sitting on something that shipped a year ago, which is worse than
silence. It is also not a breach of the read-alone principle that keeps
supersession bidirectional, because the two cases differ: both halves of a
supersession link are known to one author at one moment and written in one
commit, while the implementing citation is known to nobody at authoring time.
The duplication rule presumes both sides are writable together, so it governs
supersession and not this.

**The remaining soft spot is the trailer itself, and no hook can close it.** An
earlier draft proposed a `commit-msg` hook rejecting a branch that touches
`docs/decisions/` without an `Implements:` trailer. That is backwards twice
over: editing a decision is *authoring*, not implementing, so the rule would
reject exactly the commits that write decisions; and more fundamentally a hook
cannot distinguish a commit implementing decision 7 from unrelated work. Only
the author knows, and no mechanism recovers intent the author did not state.

So enforcement stays where it already is, at milestone completion. That catches
the decision nobody built. It cannot catch the decision somebody built and
forgot to label, which reads as abandoned though the code shipped, and that
residue is unclosable — so the check asks rather than asserts: *this decision
is accepted with no implementing commits; abandoned, or unlabelled?* A question
to a human at the one moment they can answer it is the honest ceiling.

**Supersession is bidirectional.** `supersedes` and `superseded-by`, both
written, in one commit. This duplicates a fact deliberately: derive when a tool
is guaranteed to be in the read path, duplicate when the document may be read
alone. Archive docs are read alone constantly. The consistency obligation is
discharged mechanically (orphan links and cycles are cheap to check), never by
discipline.

**State is declared in one place**, the `state:` field. The directory is not
the state; proposed and accepted entries share it. RFD 0 declares its state in
three places and they disagree, which is the failure this rule makes
impossible.

**Mutability follows state.** A `proposed` entry is under discussion and may
change freely, as the design docs already do under review — the
how-to-use-git-zhi spec took six commits, all before its merge and none after.
Revising a draft in flight is the lifecycle, not a breach of it. At `accepted`
the entry freezes: immutable in content, append-only in status (`state` and
`superseded-by`), and from then on the only way to change what it says is to
supersede it. Supersession discipline governs accepted decisions, not drafts
under review, and reaching for a new number while a proposal is still open is
the wrong instrument.

**Inclusion gate.** The well-attested failure of decision records is
enthusiasm through 012 and then silence, a partial archive that implies
completeness. Two tests, either sufficient:

1. Interface-shaped, checkable from the diff: the change touches the
   user-facing surface (`commands/`, the README skills table, `plugin.json`,
   which `CLAUDE.md`'s add-a-skill checklist already enumerates) or a contract
   with git-zhi that skills depend on. PR #9 would have qualified.
2. Re-litigation: a decision that would otherwise be argued again. The ABOUTME
   ruling qualifies; it has been re-decided by every agent that met it.

Anything that fails both stays in the postmortem, where it costs nothing.

### Tests: `t/` and `xt/`

The Perl convention, not an invention.

- `t/` tests the product: does the code do what `docs/architecture/` claims.
- `xt/` tests the project: does the repo do what `CONTRIBUTING.md` claims.

For crochet the product test is mostly the behavioral walkthrough the plans
already describe, run against the live binary, and it does not automate
cheaply. One piece does: `CLAUDE.md` says changes are validated by checking
that "the steps reference real `git zhi` subcommands". That is a rung-4
statement of a rung-2 check; `git zhi <sub> --help` exits non-zero for a
subcommand that does not exist.

`xt/` is where doc health (`git zhi docs check`, already built), `covers:`
non-emptiness, supersession symmetry across `docs/decisions/`, and
guardrail-fires tests live. None of it ships to a consumer.

**Guardrails need a test whose only assertion is that they fire.** Preflight
fails open by design (`preflight.md`, Key Constraints), which is right for an
advisory sensor and wrong for a gate. The gate is `git-zhi-verify` at
completion, and nothing in this repo checks that it runs.

**Wire the checks into an operation nobody can skip.** The mechanism exists:
every milestone carries a resolution command that gates `--state complete`,
and `docs/plans/v0.4-milestone-body.md` carries one that is an `xt/` run in all
but name. It ran once and was not kept. Crochet's own milestones set the `xt/`
runner as their resolution command.

`xt/` is a Perl convention; a markdown repo does not inherit a runner. The
runner is a shell script, because `git-zhi-verify` runs `sh -c`.

### Compiler, not runtime

Two independent arguments put the guardrails in the repo, not the plugin:

1. In-repo guardrails and in-repo docs version together. You cannot check out a
   commit where the check and `CONTRIBUTING.md` disagree about what is
   enforced. Anything in a plugin or global config can skew.
2. The mechanism is ecosystem-shaped, and a plugin cannot know which ecosystem
   it is in until it arrives.

So crochet ships the pattern; the repo ships the instance. Onboard already
states the principle for its procedure. The testable form:

> A repo crochet onboarded should still pass its own checks with crochet
> uninstalled.

If it cannot, the guardrails belong to the plugin, not the project. Onboard
Step 2 and refinement Step 1 are where the instance is installed today; under
this proposal they install the `xt/` runner too, fitted to the repo's
ecosystem.

Cost, stated plainly: this trades version skew for copy drift, N repos with N
copies that diverge as the pattern improves. Drift is visible (a check exists
and passes, or it does not) where skew is silent. Idempotent re-onboarding is
the repair.

## Migration

The repo already holds seven archive documents: three design specs, two
implementation plans, one milestone body, one postmortem. Three options:
renumber them into the series, grandfather them in place and cite by path, or
leave them alone.

**Grandfather in place.** This is a judgement call; the argument for it:

- The archive's value is that references keep resolving. The three design
  specs are cited by path from `CLAUDE.md`, from `v0.4-milestone-body.md`, and
  from both plan files. Renumbering breaks every one for no information gain.
- Their state is derivable without a field: all three are implemented, and the
  repo is the evidence. Retrofitting `state:` onto frozen documents is a
  hand-stamped claim of the kind the table catalogues.
- The two `-plan.md` files are the artifact refinement replaces (`refinement.md`:
  "rather than a markdown plan file"). They exist because those features were
  built with `superpowers:writing-plans` before the pipeline could run on
  itself. They stay as record; nothing new of that kind is expected.

Rules that follow:

- The series begins at 0001. Pre-series documents keep their paths and are
  cited by path.
- `supersedes:` accepts a path for a pre-series document, so the first decision
  that revises the superpowers/paad design can point at it. Nothing is written
  back into the superseded file; it is frozen.
- New design specs enter the series. `docs/plans/` receives no new files; it is
  not removed.
- `docs/postmortems/` continues as is. `milestone edit --postmortem` exists at
  git-zhi HEAD and not in the installed 0.4.0, so the v0.4 postmortem is a file
  and later ones may be either; both are archive, and neither is cited by the
  live layer.

## Scope of Change

Each item is a live-layer edit and lands with whatever makes it true.

- **`docs/architecture/`**: created, holding the "Architecture" section of
  `CLAUDE.md` (plugin structure, pipeline, skill roles, refinement agents,
  execute loops, integration pattern), with a non-empty `covers:` over
  `skills/`, `commands/` and `.claude-plugin/plugin.json`.
- **`docs/contributing/`**: rewritten to describe crochet. `coding-conventions.md`
  takes `CLAUDE.md`'s Conventions section and the ABOUTME ruling.
  `development-workflow.md` takes "Working in This Repo" and the add-a-skill
  checklist, and states the validation model: reading, behavioral walkthrough,
  `t/`, `xt/`. Both carry non-empty `covers:`. Neither mentions a Go build.
- **`CONTRIBUTING.md`**: describes the workflow the way an architecture doc
  describes code: what the checks are, not the rules they enforce. Links only
  directories that exist: `plans`, `decisions`, `contributing`, `architecture`,
  `postmortems`. The three dangling links go.
- **`CLAUDE.md`**: keeps what is agent-specific and `@import`s the live docs
  instead of restating them. "There is no build step, test suite" is corrected
  in the same PR that adds `xt/`.
- **`skills/postmortem/postmortem.md`**: the "Feedback Loop" section asserts a
  contract nothing implements, and the parked self-driving design in the
  commonplace book argues the literal contract is the wrong shape. The section
  is removed; whether and how refinement reads past postmortems is its own
  decision.
- **`t/` and `xt/`**: created, with `xt/run.sh` as the runner. `t/`: every
  `git zhi` subcommand named in `skills/` answers `--help`. `xt/`: `git zhi
  docs check`; no doc under `docs/architecture/` or `docs/contributing/` has
  `covers: []`; every `supersedes` in `docs/decisions/` has a matching
  `superseded-by` and there are no cycles; the runner itself exits non-zero on
  a deliberately broken fixture, so a runner that stopped running is visible.
  Crochet's next milestone uses `sh xt/run.sh` as its resolution command.
- **Plugin changes, recorded here and numbered separately when taken up**: at
  milestone completion `crochet:postmortem` asks, for each accepted decision
  with no reachable `Implements:` commit, whether it is abandoned or merely
  unlabelled — a question, not a written state; `crochet:onboard` Step 2 and
  `crochet:refinement` Step 1 install an `xt/` runner alongside `docs init`,
  fitted to the repo's ecosystem, so an onboarded repo passes its checks with
  crochet uninstalled; and `crochet:preflight` probes the load-bearing `git
  zhi` flags the skills depend on, recording each in the capabilities map so
  skills branch on binary capability the way they already branch on plugin
  availability.

  The flag probe belongs in preflight rather than `t/` because its consumer is
  an agent about to run a command, and the placement rule puts documentation
  inside the guardrail that fires at that moment. It is a declared set of
  flags, not a scan of `skills/` on every invocation, which would cost more
  than preflight is allowed to cost. It is advisory and fails open, like the
  version check beside it. The trade is explicit: this catches skew for the
  agent that would hit it, and does not catch a skill naming a flag that never
  existed, which `t/` would have caught at authoring time.

**Dependencies on git-zhi.** Two items above need the tool to change first.
They are named here because a decision that silently depends on unshipped
behaviour is the failure this document exists to prevent.

- **Archive directories must inherit the reachability exemption.**
  `git zhi docs check` counts a file unreachable when `CONTRIBUTING.md` does
  not link it, and counts files rather than directories, so linking
  `docs/plans` leaves all seven plan files unreachable. `docs/decisions/` is
  already exempt; `docs/plans/` and `docs/postmortems/` are archive by the
  same taxonomy and are not. Until they are, the first acceptance criterion
  below cannot pass while Migration grandfathers those files in place.
- **`covers: []` must be a finding, and an empty document set must say so.**
  `git zhi docs health` treats an empty `covers:` as absent, so a repo whose
  only two live docs carry `covers: []` reports `0 high drift, 0 low drift, 0
  coverage gap(s)` while observing nothing; only `--format json` discloses
  "no docs with covers frontmatter found". A sensor that reports green while
  watching nothing has failed open, which is the condition this document
  elsewhere requires a test for. `crochet:postmortem` and the technical writer
  agent both consume that reading today.

### Acceptance Criteria

This document reads as implemented — a query, not a field — when all of the
following pass on `pu` and the commits that made them pass carry
`Implements: 0001`.

- [ ] docs check passes (`git zhi docs check`)
- [ ] an architecture doc exists under docs/ (`test -n "$(ls docs/architecture/*.md 2>/dev/null)"`)
- [ ] no live doc has an empty covers list (`! grep -rl '^covers: \[\]' docs/`)
- [ ] contributing docs do not describe a Go build (`! grep -rq 'go build' docs/contributing`)
- [ ] CLAUDE.md imports the live layer (`grep -q '^@docs/' CLAUDE.md`)
- [ ] postmortem no longer asserts the unbuilt loop (`! grep -q '^## Feedback Loop' skills/postmortem/postmortem.md`)
- [ ] this decision's implementing commits are findable by trailer (`git log --grep='^Implements: 0001' --oneline | grep -q .`)
- [ ] the author-test runner exists and passes (`sh xt/run.sh`)

## Open Questions

Carried from the source design, still open:

- Who accepts a proposal. Currently perigrin, the same seat as the value-loop
  setpoint in the parked self-driving design. Mapping `accepted` onto "the
  human says execute" after chain-review records the current answer without
  settling it.
- Whether the glossary is the one hand-maintained section of the architecture
  doc or whether terms get defined in the decisions that introduce them.

Surfaced by writing this document in its own format:

- The check that computes `abandoned` cannot distinguish a decision nobody
  built from one somebody built and forgot to label, so it asks a human at
  milestone completion. That is the honest ceiling, but it puts a question in
  the path of an operation meant to run unattended. Whether the question is
  worth its interruption is answerable only after the series has enough
  entries to see how often it fires.

## References

- Architecture Decision Records, https://adr.github.io. Supersession as an
  append-only archive from which "what is in force" is derived.
- OpenDTrace Requests for Discussion, https://github.com/opendtrace/rfd. The
  `state` field as the live-to-archive transition; number as identity;
  interface-shaped inclusion gate.
- architecture.md template, https://architecture.md. Instance eight.
- Explicitly running author tests,
  https://elliotlovesperl.com/2009/11/24/explicitly-running-author-tests/. The
  `xt/` convention and the release gate.
- `docs/plans/2026-03-28-superpowers-paad-integration-design.md`. The
  conditional-delegation pattern and the pipeline this document maps its
  states onto.
- `docs/postmortems/v0.4-superpowers-paad-integration.md`. The ABOUTME lesson,
  unpromoted.
- `pages/repo-documentation-architecture.md` in perigrin's commonplace book,
  where this design was worked out.
