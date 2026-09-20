---
name: assess
description: Analyze a PRD against the existing codebase and chain to identify gaps, partial implementations, blocking architecture conflicts, and satisfied requirements
---

## Prerequisites

Run `crochet:preflight` as the first step. It checks git-zhi availability, reads the capabilities manifest, and returns a capabilities map used for conditional skill delegation below.

# crochet:assess

Reads a PRD and analyses it against the existing codebase and chain state to
produce a gap analysis. Output feeds `crochet:refinement` — blocking items become
prerequisite refactoring issues at the front of the chain.

**This gate produces the acceptance.** A decision is accepted when its assessment
reaches a fixed point: a round raising nothing new, from participants that did
not author it. That is why the session is dispatched rather than performed here,
and why it is written to an archive rather than presented and lost.


## Trigger

`crochet:assess` is the required entry point for the SDLC pipeline. Run it when a user provides a PRD file path, invokes it after brainstorming produces a spec, or initiates any structured feature development. No pipeline step should begin before assess has run.

## Inputs

1. **PRD or spec file** — from Jama via MCP, from a file, or from stdin
2. **Codebase** — direct file access (source files, directory structure)
3. **Chain state** — `git zhi issue list --format json`, `git zhi milestone list --format json`
4. **Lineage data** — `git zhi issue show <id> --format json` for upstream context
5. **Git history** — `git log` for recent changes in relevant areas

## Process

### Step 0: Dispatch the session

**Delegate the session to `crochet:discernment`**, passing the spec as the
subject, `docs/assessments/` as where the minute goes, and who drafts. It owns
the rounds, the dispatch, the recommendation contract and the minute.

No capability check: it ships in this plugin, so it is always present. The
conditional pattern is for superpowers and paad, which may not be installed —
guarding a sibling behind it means the guard never passes and the fallback is a
second implementation of the thing built once.

**Delegation is the caller's job, not a participant's.** If you are reading this
as a dispatched participant rather than as the agent invoking assess, the step
above is not yours: do the analysis you were sent to do and report it.

**An agent may not assess its own work.** Asking whether shipped work is the
direction the repository should go, of the agent that shipped it, returns yes —
the document and the code agree because the work made them agree. The bar is
authorship, not species: another agent satisfies it, a human is not required.
At least one participant is neither the author nor the drafter.

**Who names the file.** The archive is keyed by milestone, and in nominal
position no milestone exists yet — the architect names it during refinement. So
assess names the file after the decision it assesses (`docs/assessments/<NNNN>.md`)
and refinement renames it to the milestone when it creates one. A backfilled
assessment, run when a milestone already exists, uses the milestone name
directly. That settles who names the assessment file in the case where the thing
it is keyed to does not exist yet.

### Step 0.5: Spec Quality Validation


**If `paad:pushback` is available** (check preflight capabilities):
  Run `paad:pushback` on the PRD. Follow the skill — do not reimplement it. Resolve or acknowledge all pushback findings before continuing. The user may choose to proceed at any point; this is a quality gate, not a hard blocker.

**Otherwise:**
  Run inline spec checks before proceeding to gap analysis:

  - **Contradictions** — scan for requirements that conflict with each other (e.g., "must be fast" and "must be fully synchronous with no caching"). Call each out explicitly.
  - **Ambiguity** — flag requirements with no measurable acceptance criteria. "Should be responsive" is not testable; "must respond within 200ms at p95" is.
  - **Scope red flags** — identify any requirement that implies rewriting or replacing an existing major subsystem without naming it as a deliberate refactor. Flag scope that looks unbounded or that quietly entails large unstated work.
  - **Missing error handling** — note any flow described with no mention of failure modes. If the spec says "user submits form and sees confirmation" with no error path, flag it.
  - **Security surface** — call out any requirement that expands the security attack surface: authentication, authorization, data storage, external input, or third-party integrations without specifying a threat model or constraints.

  Present findings as a short, labeled list. The user may proceed at any point — these are advisory, not blocking. Note at the end: installing `paad` provides deeper analysis including contradiction trees, requirement traceability, and structured pushback sessions.

### Step 1: Parse Requirements

Read the PRD and extract discrete requirements. Each requirement is a capability, constraint, or behavior the system must exhibit.

### Step 2: Analyze Codebase

For each requirement, search the codebase:

- **Grep for relevant types, functions, packages** that relate to the requirement
- **Read the code** to understand what exists and how it works
- **Check tests** to understand what's verified
- **Check git log** for recent changes in the relevant area

### Step 3: Classify Each Requirement

Assign each requirement to one of four categories:

- **Missing** — the capability does not exist in code. No relevant types, functions, or packages found. This becomes a new issue in the chain.
- **Partial** — code exists that does some of what's needed but requires extension. Identify what exists and what's missing. This becomes an enhancement issue.
- **Blocking** — existing code or architecture conflicts with the requirement. Something must be refactored or removed before the requirement can be met. This becomes a prerequisite refactoring issue at the front of the chain.
- **Ready** — code already satisfies the requirement. Point to the specific files and tests that demonstrate this.

### Step 4: Trace Lineage

For Partial and Blocking items, use chain lineage data to understand:
- Who built the existing code and why (from issue context and transitions)
- What decisions led to the current architecture (from milestone postmortems if available)
- What other code depends on the area that needs changing

### Step 5: Output

**Write the assessment to `docs/assessments/`, then present it.** An assessment
that exists only in conversation is lost at the first compaction or agent
handoff — and this protocol instructs the orchestrator to compact between units
of delivery, so the gate's record cannot live in the context it is told to
discard. `crochet:refinement` copies it into the milestone body; the archive file
stays, because the milestone body lives in one clone.

`docs/assessments/` must be reachable from `CONTRIBUTING.md`, or `git zhi docs
check` reports every file in it unreachable.

#### The three axes

Every assessment answers these, with evidence:

1. **Codebase** — does the spec align with the code as it stands?
2. **Architecture** — does it align with the decisions in force?
3. **Direction** — does it align with where the repository is going? Crochet's
   is maximising the autonomy of agents delivering software in collaboration
   with a human.

#### The cursory form

A **cursory** assessment answers the three axes explicitly, with evidence, and
does nothing else: no `paad:pushback` pass, no decomposition into blocking,
missing and partial, no prerequisite ordering. It is what backfill produces when
a later gate finds no assessment, not a lesser version of the full one.

#### The full form


Present results grouped by category, most critical first:

```
## Assessment: <PRD title>

### Blocking (must resolve first)
1. **<requirement>** — <what conflicts and why>
   Files: <paths>
   Lineage: built by <issue>, decision documented in <postmortem/ADR>
   Action: refactor <component> before proceeding

### Missing (new work)
1. **<requirement>** — <what doesn't exist>
   Suggested paths: <where new code should live>
   Dependencies: requires <blocking items> resolved first

### Partial (extend existing)
1. **<requirement>** — <what exists, what's missing>
   Files: <paths>
   Extension needed: <specific changes>

### Ready (already satisfied)
1. **<requirement>** — satisfied by <files/tests>
```

## Key Constraints

- **Read the actual code.** Don't guess from file names or directory structure. Open files and understand what they do.
- **Every claim must cite evidence.** "This is missing" must be backed by a search that found nothing. "This is partial" must point to the specific file and explain what's missing.
- **Blocking items are prerequisites.** They must be resolved before the missing or partial items can be addressed. The output order reflects this dependency.
- A human can do this manually: read the PRD, grep the codebase, check `git log`, list the gaps. This skill executes the same process faster and more thoroughly.
