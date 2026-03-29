# Crochet: Superpowers and PAAD Integration

Crochet should build on superpowers and paad rather than reimplement their
patterns. This document defines how crochet detects, leverages, and falls back
from these dependencies.

## Principle

Crochet detects whether superpowers and paad are installed. When present, it
delegates to their skills. When absent, it falls back to simpler inline
behavior. Crochet never reimplements what superpowers or paad already provides.

## Capability Detection

### Manifest

`.claude/crochet/capabilities.json` records which superpowers and paad skills
are available. This file is machine-specific (records what plugins are installed
on *this* user's machine) and must be gitignored. Add
`.claude/crochet/capabilities.json` to `.gitignore` when creating the directory.

Example manifest:

```json
{
  "last_updated": "2026-03-28T14:30:00Z",
  "plugins": {
    "superpowers": {
      "installed": true,
      "skills": {
        "dispatching-parallel-agents": true,
        "systematic-debugging": true,
        "test-driven-development": true,
        "verification-before-completion": true,
        "simplify": true,
        "brainstorming": true
      }
    },
    "paad": {
      "installed": true,
      "skills": {
        "pushback": true,
        "alignment": true,
        "agentic-review": true,
        "agentic-architecture": true
      }
    }
  }
}
```

### Lifecycle

- **Seeded by** `crochet:install` — scans these directories for plugin skills:
  - Superpowers: `~/.claude/skills/` (look for skill directories by name)
  - PAAD: `~/.claude/plugins/marketplaces/paad/plugins/paad/skills/`
  - Also check the superpowers plugin cache: `~/.claude/plugins/cache/superpowers-marketplace/`
- **Self-healing** — `crochet:preflight` runs before every crochet skill,
  cross-checks the manifest against the system-reminder skill list, and updates
  the manifest if it finds discrepancies.
- **Fallback** — if the manifest cannot be written (read-only filesystem, etc.),
  preflight warns the user ("Cannot write capabilities manifest — using
  runtime-only detection for this session") and proceeds with in-memory
  detection.

### Conditional Reference Pattern

Each integration point follows this pattern in skill markdown:

```markdown
**If `<skill>` is available** (check preflight capabilities):
  <delegate to the skill — follow it, do not reimplement>

**Otherwise:**
  <inline fallback behavior>
```

The skill is named explicitly. The fallback is the simpler or current behavior.

## SDLC Pipeline

```
superpowers:brainstorming
  -> crochet:assess (+ paad:pushback if available)
    -> crochet:refinement
      -> crochet:chain-review
        -> crochet:execute
          -> crochet:postmortem
```

Each step is a gate. You do not proceed until the current step passes.

## Skill Inventory

### Infrastructure

| Skill | Purpose | When | User-invokable |
|-------|---------|------|----------------|
| crochet:install | Install git-zhi, seed capabilities manifest | Once per project | yes |
| crochet:preflight | Check git-zhi, detect/update capabilities manifest | Every skill invocation | no (internal) |
| crochet:verify | Full environment health check (templates, plugins, milestones, labels) | On-demand | yes |
| crochet:onboard | Bootstrap git-zhi in an existing repo | Once per project | yes |

### Pipeline (user-facing, strict order)

| Skill | Leverages | Fallback |
|-------|-----------|----------|
| crochet:assess | paad:pushback for spec quality | Inline spec quality checks |
| crochet:refinement | dispatching-parallel-agents for SQE + techwriter | Sequential agents |
| crochet:chain-review | dispatching-parallel-agents for parallel alignment + pushback | Sequential checks |
| crochet:execute | test-driven-development in Ralph prompt; systematic-debugging on convergence failure; verification-before-completion at milestone; dispatching-parallel-agents for parallel ready issues | Inline TDD instructions; give up after max iterations; manual verify; sequential issues |
| crochet:postmortem | verification-before-completion for data gathering | Note missing sources |

### Internal (not user-invokable)

Internal skills have a skill file (`skills/<name>/<name>.md`) but no
corresponding command file (`commands/<name>.md`). Without a command stub,
Claude Code does not expose them as user-invokable slash commands. Other
crochet skills invoke them by name in their instructions.

| Skill | Purpose | Called by |
|-------|---------|----------|
| crochet:alignment | Coverage check: chain vs PRD, dependency direction, scope compliance | crochet:chain-review |
| crochet:pushback | Plan quality: single-sized chunks, QA tasks, dependency sanity, AC testability, critical chain analysis | crochet:chain-review |

### Other User-Facing

| Skill | Purpose |
|-------|---------|
| crochet:import | Import external tickets into chain |
| crochet:report | Generate reports from templates |

## Integration Details

### crochet:preflight (new, infrastructure-only)

Not user-invokable — no command stub. Other crochet skills invoke it as their
first step. Users who want to check environment health explicitly should use
`crochet:verify` instead.

Runs before every crochet skill. Responsibilities:

1. Check `git-zhi` is available (existing prerequisite behavior).
2. Read `.claude/crochet/capabilities.json` (or create if missing).
3. Cross-check manifest against system-reminder skill list.
4. If discrepancy: update manifest, tell user what changed ("Detected
   superpowers:dispatching-parallel-agents is now available — updated
   capabilities manifest").
5. If manifest cannot be written: warn user, proceed with in-memory detection.
6. Return capabilities map.

### crochet:assess

Becomes the required entry point for the SDLC pipeline. Takes a PRD, validates
spec quality (via paad:pushback when available), then analyzes the PRD against
the existing codebase to produce a gap analysis.

**If paad:pushback is available:** run it first for spec quality. Wait for user
to resolve findings before proceeding to gap analysis.

**Otherwise:** run a lightweight inline spec quality check before gap analysis.
This is not as thorough as paad:pushback but catches obvious problems:

- **Contradictions:** requirements that conflict with each other
- **Ambiguity:** requirements interpretable multiple ways, vague success criteria
- **Scope red flags:** single bullet points that are clearly larger than others
- **Missing error handling:** requirements that describe success but not failure
- **Security surface:** authentication, authorization, or data exposure implied
  but not addressed

Present findings one at a time. The user can say "good enough" to proceed.
This is a safety net, not a substitute for paad:pushback — warn the user that
installing paad provides deeper spec quality analysis.

The gap analysis (missing, partial, blocking, ready classifications) stays
unchanged. Its output feeds crochet:refinement.

### crochet:refinement

Absorbs pipeline-readiness pre-checks from the old crochet:pushback (source
control conflicts, omissions, feasibility against codebase). These run before
decomposition begins.

**If dispatching-parallel-agents is available:** after decomposer completes,
dispatch SQE and techwriter agents in parallel.

**Otherwise:** run SQE then techwriter sequentially.

### crochet:chain-review (new)

Orchestrates two internal skills against the chain produced by refinement.

**If dispatching-parallel-agents is available:** dispatch alignment and pushback
concurrently.

**Otherwise:** run alignment then pushback sequentially.

#### crochet:alignment (internal)

Coverage lens:
- Requirements coverage: every PRD requirement has at least one issue.
- Scope compliance: every issue traces to a stated requirement (no phantom features).
- Dependency direction: edges reflect actual technical constraints.

#### crochet:pushback (internal)

Plan quality lens:
- Issue sizing: each issue is a single chunk of work, not multi-concern.
- QA tasks present: SQE agent added negative scenarios to every code issue.
- Dependency sanity: no cycles, no bottleneck issues blocking too many downstream.
- Critical chain analysis: reasonable length, parallelism opportunities noted.
- AC testability: acceptance criteria are concrete enough to write a test against.

### crochet:execute

#### Inner loop (Ralph Loop prompt)

**If test-driven-development is available:** the Ralph Loop prompt references
`superpowers:test-driven-development` for RED-GREEN-REFACTOR discipline.

**Otherwise:** inline TDD instructions in the prompt.

#### Convergence failure

**If systematic-debugging is available:** when the Ralph Loop hits max
iterations without converging, stop Ralph and invoke systematic-debugging to
diagnose root cause. Based on findings: fix and restart Ralph, split the issue,
or escalate to user.

**Otherwise:** stop and report "Issue did not converge" (current behavior).

#### Parallel ready issues

**If dispatching-parallel-agents is available:** when multiple issues are
`--ready` simultaneously (no mutual dependencies), dispatch parallel inner loops.

**Otherwise:** pick one at a time sequentially.

#### Milestone completion

**If verification-before-completion is available:** run it before marking the
milestone complete.

**Otherwise:** run tests and build manually.

### crochet:postmortem

**If verification-before-completion is available:** verify all data sources are
complete before generating the retrospective.

**Otherwise:** gather what is available, note missing sources.

### crochet:pushback — PRD/spec context

paad:pushback handles spec quality (contradictions, ambiguity, scope). The old
crochet:pushback PRD context handled pipeline readiness (source control
conflicts, omissions, feasibility). These are complementary:

- paad:pushback: "Is this a good spec?"
- Pipeline-readiness checks: "Will this spec decompose well?"

paad:pushback runs first (within crochet:assess). Pipeline-readiness checks run
within crochet:refinement before decomposition.

### crochet:verify (new)

On-demand environment health check:

- Report templates reference valid milestones, labels, and plugins.
- Plugin commands (sanbao, verify, docs) are on `$PATH`.
- Data commands in templates exit successfully and return non-empty data.
- Template structure is complete (prompt section, structure section, data commands).

Separate from preflight: preflight is lightweight and automatic; verify is
thorough and on-demand.

## Changes from Current State

1. **New skills:** crochet:preflight, crochet:verify, crochet:chain-review.
2. **Restructured:** crochet:pushback and crochet:alignment become internal
   skills called by chain-review.
3. **Expanded:** crochet:assess absorbs paad:pushback as first step, becomes
   required gate before refinement.
4. **Expanded:** crochet:refinement absorbs pipeline-readiness pre-checks.
5. **Enhanced:** crochet:execute gains conditional superpowers integration (TDD,
   systematic-debugging, verification, parallel dispatch).
6. **Enhanced:** crochet:refinement gains conditional parallel dispatch for
   SQE + techwriter.
7. **Retired as user-facing:** crochet:pushback and crochet:alignment (kept as
   internal skills under chain-review).

## Assessment Findings (resolved)

The following gaps were identified by `crochet:assess` and addressed in this
document:

1. **Manifest gitignore policy** — `.claude/crochet/capabilities.json` is
   machine-specific and must be gitignored. (Added to Manifest section.)
2. **Internal skill convention** — internal skills have no command stub.
   (Added definition to Internal skills section.)
3. **Install-time scan paths** — `crochet:install` scans specific directories
   for superpowers and paad skills. (Added paths to Lifecycle section.)
4. **Assess fallback checks** — lightweight inline spec quality checks when
   paad:pushback is unavailable. (Added check list to assess section.)
5. **Preflight visibility** — preflight is infrastructure-only, not
   user-invokable. Users use `crochet:verify` for explicit health checks.
   (Added to preflight section and infrastructure table.)
