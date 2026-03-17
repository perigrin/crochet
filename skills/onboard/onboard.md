---
name: onboard
description: Automated executor of the onboard procedure — runs the full git-zhi adoption walkthrough with human approval at each decision point
---

# crochet:onboard

Executes the onboard procedure step by step, with human approval at each decision point. Every step is independently verifiable and reversible.

## Trigger

User wants to adopt git-zhi in an existing repository: "set up zhi", "onboard this repo", "bootstrap this project."

## Process

Execute each step in order. At each step: explain what will happen, ask for approval, execute, verify, report.

### Step 1: Assess Current State

Check what exists:
- `ls docs/` — documentation structure?
- `ls .git/refs/zhi/` — existing zhi state?
- `git log --oneline -5` — active repository?
- `cat CONTRIBUTING.md 2>/dev/null` — existing contributor docs?
- `cat CLAUDE.md 2>/dev/null` — existing agent config?

Report findings and ask: "Ready to proceed with scaffolding?"

### Step 2: Scaffold Documentation

Run `git zhi docs init` to create the canonical `docs/` directory structure and living documents.

**Verify:** `git zhi docs check` passes.
**Rollback:** `git checkout -- docs/ CONTRIBUTING.md` to revert.

### Step 3: Bootstrap History

This is the key step — converting existing git history into zhi issues.

1. Ask: "What ticket prefix does your team use? (e.g., LOPS-, PROJ-, or none)"
2. Preview: `git zhi historian --title-match "<prefix>*" --label <team> --dry-run`
3. Show the preview: how many commits mapped, how many unmapped, estimated issue count
4. Ask: "Does this look right? Proceed with import?"
5. Execute: `git zhi historian --title-match "<prefix>*" --label <team>`

**Verify:** `git zhi historian status` shows expected coverage.
**Rollback:** Delete refs under `refs/zhi/_/issues/` to start over.

### Step 4: Check Coverage

Run `git zhi historian status` and review:
- What percentage of commits are mapped?
- Any low-coherence clusters?
- Any unmapped commits worth triaging?

If coverage is acceptable, continue. If not, offer: `git zhi historian triage` for interactive resolution.

### Step 5: Configure Sync (Optional)

If the team uses an external tracker:

1. Ask: "What tracker do you use? (Jira, GitLab, Linear, or none)"
2. For Jira: collect URL, email, token
3. Configure: `git config zhi.sync.jira.url/email/token`
4. Preview: `git zhi jira sync --dry-run`
5. Ask: "Does this look right? Enable sync?"

**Verify:** Dry-run shows expected matches.
**Rollback:** `git config --remove-section zhi.sync.jira` to unconfigure.

### Step 6: Verify Baseline

Run `git zhi sanbao report <milestone>` (if sanbao is installed) to check that telemetry produces sensible numbers.

Check: Does speed make sense? Is MPG reasonable? Does the fever chart reflect reality?

If sanbao isn't installed, skip with a note.

### Step 7: Start Working

```bash
git zhi next
```

The chain is live. Show the first recommended issue and explain the workflow: pick up issue, start, work, done, next advances.

## Key Constraints

- **Every step asks for approval.** No silent mutations.
- **Every step has verification.** If verification fails, stop and explain.
- **Every step has rollback instructions.** The user can undo any step independently.
- **A human can execute this procedure from the terminal without Crochet.** The skill automates; it doesn't replace. Every command listed here works standalone.
