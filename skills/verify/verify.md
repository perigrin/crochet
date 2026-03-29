---
name: verify
description: Environment health check skill — runs four verification areas against the crochet environment and reports findings
---
<!-- ABOUTME: User-invokable skill for explicit environment health checking across report templates, plugins, data commands, and template structure. -->
<!-- ABOUTME: Distinct from preflight: verify is explicit and comprehensive, preflight is lightweight and automatic. -->

# crochet:verify

This skill runs an explicit environment health check. It is invoked directly by users who want to audit the crochet environment. Other crochet skills use `crochet:preflight` for their automatic lightweight startup check; this skill goes deeper.

## First Step

Run `crochet:preflight` as the first step. Preflight confirms git-zhi availability and loads the capabilities map. If preflight fails, report the failure and stop — the remaining checks depend on git-zhi being present.

## Verification Areas

Verify runs four checks in order and collects findings for a final report.

### 1. Report Template Validity

Locate report templates in `.claude/crochet/templates/`. For each template file found:

- Parse the frontmatter. Confirm required keys are present (at minimum: `title`).
- Confirm the template body is non-empty.
- Report any template that fails to parse or is missing required keys as invalid.

If no templates are found, report that finding — it is not an error, but the user should know.

### 2. Plugin Commands on PATH

For each plugin recorded in the capabilities manifest, identify the commands that plugin relies on. Check each command with `which <command>`. Report any command not found on PATH.

At minimum, check:

- `git-zhi` — required by all crochet skills
- Any additional commands declared in installed plugin manifests

### 3. Data Command Execution

For each report template that defines a `data` section, extract the data command and run it. Capture exit code and output. Report any data command that exits non-zero or produces no output.

If a template has no `data` section, skip it for this check.

### 4. Template Structural Completeness

Review each template for structural completeness:

- All placeholder variables referenced in the body are defined in the frontmatter or will be supplied by the data command.
- The template structure follows the expected layout (frontmatter block, body, optional Mermaid chart sections).
- No unclosed template directives or malformed Mermaid fence blocks.

Report any structural issues found.

## Output

After running all four checks, produce a summary report:

```
crochet:verify — environment health check
==========================================
preflight:          OK
template validity:  <N> templates checked, <M> issues
PATH checks:        <N> commands checked, <M> missing
data commands:      <N> commands checked, <M> failures
template structure: <N> templates checked, <M> issues

<detail for each issue found>
```

If all checks pass with no issues, say so explicitly: "All checks passed."

## Key Constraints

- **Never modify the environment.** Verify is read-only. It reports findings; it does not fix them.
- **Report all findings.** Do not stop at the first failure. Complete all four checks and report everything.
- **Distinguish warnings from errors.** Missing optional fields are warnings. Missing required fields and non-zero data command exits are errors.
