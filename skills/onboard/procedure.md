---
name: onboard-procedure
description: Human-executable adoption procedure for git-zhi — step-by-step walkthrough from blank repo to working chain
---

# git-zhi Onboard Procedure

A step-by-step procedure for adopting git-zhi in an existing repository. Every step works from the terminal without Crochet. The `crochet:onboard` skill automates this sequence.

## Prerequisites

- `git-zhi` on `$PATH`
- Optional: `git-zhi-historian`, `git-zhi-docs`, `git-zhi-sanbao`, `git-zhi-jira`

## Step 1: Assess Current State

```bash
ls docs/                           # existing documentation?
ls .git/refs/zhi/ 2>/dev/null      # existing zhi state?
git log --oneline -5               # active repository?
cat CONTRIBUTING.md 2>/dev/null    # contributor docs?
```

**Decision point:** If `refs/zhi/` already exists, this repo has been onboarded before. Ask whether to continue (extend) or start fresh (delete refs first).

## Step 2: Scaffold Documentation

```bash
git zhi docs init
```

Creates `docs/` directory structure and living documents. Preserves existing `CONTRIBUTING.md` content.

**Verify:**
```bash
git zhi docs check
# Expected: exit code 0, no structural issues
```

**Rollback:**
```bash
git checkout -- docs/ CONTRIBUTING.md
```

## Step 3: Bootstrap History

Determine your team's commit message convention for ticket references.

**Preview first (always):**
```bash
# If your team uses ticket prefixes in commits (e.g., [LOPS-123])
git zhi historian --title-match "LOPS-*" --label LOPS --dry-run

# If no ticket convention
git zhi historian --dry-run
```

Review the output: commit count, estimated issues, mapping coverage.

**Execute:**
```bash
git zhi historian --title-match "LOPS-*" --label LOPS

# Or without ticket matching
git zhi historian --label <your-team-name>
```

**Verify:**
```bash
git zhi historian status
# Expected: >80% coverage with ticket prefixes, 40-70% without
```

**Rollback:** Delete all historian-created refs:
```bash
# WARNING: destructive — removes all imported issues
git for-each-ref --format='%(refname)' refs/zhi/_/issues/ | xargs -n1 git update-ref -d
```

## Step 4: Triage Unmapped Commits (Optional)

If coverage is below your threshold:

```bash
git zhi historian triage
```

Interactive mode presents unmapped commit clusters one at a time. For each:
- `[a]ssign` to an existing issue
- `[n]ew issue` to create a standalone issue
- `[s]kip` to leave unmapped
- `[m]erge` with an adjacent cluster
- `[q]uit` to stop triaging

Triage is incremental — quit and resume later.

## Step 5: Configure Tracker Sync (Optional)

If your team uses Jira:

```bash
# Configure credentials
git config zhi.sync.jira.url "https://yourcompany.atlassian.net"
git config zhi.sync.jira.email "your@email.com"
git config zhi.sync.jira.token "<api-token>"

# Configure state mapping
git config zhi.sync.jira.state.done "Done"
git config zhi.sync.jira.state.in-progress "In Progress"
git config zhi.sync.jira.state.cancelled "Won't Do"

# Configure identity mapping
git config zhi.sync.jira.actor.perigrin "chris.prather@example.com"

# Preview sync
git zhi jira sync --dry-run
```

Review the dry-run output for unexpected matches or conflicts.

**Execute:**
```bash
git zhi jira sync pull | git zhi issue edit --batch   # pull Jira metadata
git zhi jira sync push                                 # push state changes
```

**Rollback:**
```bash
git config --remove-section zhi.sync.jira
```

## Step 6: Enrich from Tracker (Optional)

If historian issues have tracker IDs and you want Jira metadata:

```bash
git zhi jira enrich <milestone>
```

Augments historian-created issues with Jira titles, descriptions, and assignees.

## Step 7: Verify Baseline

Check that telemetry makes sense:

```bash
git zhi milestone show
# Review: speed, MPG, fever chart

# If sanbao is installed:
git zhi sanbao report <milestone>
# Review: DORA metrics, sentiment, complexity
```

**Sanity checks:**
- Does speed (issues/week) match your intuition?
- Is MPG (commits/issue) reasonable for your commit discipline?
- Does the fever chart color match your sense of the milestone's health?

## Step 8: Start Working

```bash
git zhi next
```

The chain is live. The recommended workflow:

```bash
git zhi next                           # what should I work on?
git zhi issue edit <id> --state start  # start working
# ... do your work, commit normally ...
git zhi issue edit <id> --state done   # mark complete
git zhi next                           # HEAD advances
```

For parallel work with agents:

```bash
git zhi list --ready                   # what can run in parallel?
git zhi next --actor "agent:claude"    # per-worker scheduling
```

## Summary

| Step | Command | Required | Reversible |
|------|---------|----------|------------|
| 1. Assess | `ls`, `git log` | yes | N/A (read-only) |
| 2. Scaffold | `git zhi docs init` | yes | `git checkout` |
| 3. Bootstrap | `git zhi historian` | yes | delete refs |
| 4. Triage | `git zhi historian triage` | no | skip/quit |
| 5. Sync config | `git config zhi.sync.*` | no | `--remove-section` |
| 6. Enrich | `git zhi jira enrich` | no | re-run historian |
| 7. Verify | `git zhi milestone show` | yes | N/A (read-only) |
| 8. Start | `git zhi next` | yes | N/A (read-only) |
