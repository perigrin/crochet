---
stability: 2
covers:
  - skills/
  - commands/
---

<!-- ABOUTME: Conventions for writing crochet's skill and command files. -->
<!-- ABOUTME: Covers skills/ and commands/ — the markdown that is the product. -->

# Coding Conventions

Crochet's deliverables are markdown. A skill file is not documentation about a
program; for an agent it *is* the program, so these conventions govern the
product rather than its description.

## Skill files

Every skill lives at `skills/<name>/<name>.md` and opens with YAML frontmatter
carrying `name` and `description`. Supporting files — agent prompts, templates,
procedures — sit beside it in the same directory.

A skill that users invoke has a matching stub at `commands/<name>.md`. A skill
without a stub is internal and says so in its own text, because the absence of
a file is not a claim anyone can read.

## ABOUTME comments

Files carry two `ABOUTME` lines, as an HTML comment placed immediately after the
YAML frontmatter:

```markdown
---
name: example
description: ...
---

<!-- ABOUTME: One line saying what this file does. -->
<!-- ABOUTME: A second line naming what it covers or depends on. -->
```

The HTML-comment form is the practice ten of the twelve ABOUTME-bearing files
already follow. It is recorded here because it was previously settled by
imitation, which meant every agent that met it decided again.

## Conventions the skills must hold to

- **All chain interaction goes through the `git zhi` CLI.** Never read or write
  `refs/zhi/` directly. The CLI is porcelain over plumbing, and the plumbing is
  not a supported interface.
- **State the git-zhi prerequisite inline.** Each skill checks `which git-zhi`,
  or delegates to `crochet:preflight`, in its own text. There is no include
  mechanism in this format, so there is no shared block to reference.
- **Skills are idempotent.** Re-invoking one on partial state resumes from
  wherever the chain actually is, rather than assuming a clean start.
- **Never reimplement an available skill.** Where superpowers or paad provides
  a capability, delegate to it behind the conditional pattern and keep the
  inline fallback simple.
- **Probe for a capability, do not test for a filename.** A stale symlink can
  exist on `$PATH` and no longer dispatch, so `git zhi <sub> --help` answers the
  real question where `test -x` does not.

## Citing code from a decision

A decision names a symbol, never a line. `Graph.headForActor`, `ReadySet`, the
`no actionable issues for actor` error — each of those survives an edit above it
and can be found with a grep. `graph.go:439-444` decays the moment anything
shifts, and decays *silently*, because nothing reads a decision at build time.

**This matters most across a repository boundary.** A citation into git-zhi's
tree cannot be checked from here at all: `xt/run.sh` and `git zhi docs check`
observe this repository, so a line number pointing into another one has no check
anywhere. Three separate assess passes over `0002-worker-identity.md` found
stale git-zhi citations — one of them naming a call the function no longer
makes — a decision describing a codebase that had moved out from under it.

Where a claim is behavioural rather than structural, name the version it was
observed on, as in "Observed on 0.6.0". That tells a reader what to re-run
rather than what to re-read. `xt/run.sh` rejects a `file:line` citation under
`docs/decisions/`; the version marker stays convention, because nothing here can
verify another repository's behaviour.

## Naming and prose

Names are evergreen: nothing is `new`, `improved` or `enhanced`, because what is
new today is old later. Comments describe the code as it stands, not how it got
there; the archive under `docs/decisions/` and `docs/postmortems/` carries the
history, and that is the only place tense belongs.
