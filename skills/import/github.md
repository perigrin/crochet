---
name: import-github
description: Import GitHub Issues into git-zhi — fetches issues and native dependencies via gh CLI, maps fields, presents for review, creates issues with two-pass dependency wiring
---

## Prerequisites

Before proceeding:
1. Verify `git-zhi` is available: `which git-zhi`. If not found, run `crochet:install`.
2. Verify `gh` CLI is available: `which gh`. If not found, report: "gh CLI not found — install from https://cli.github.com"
3. Verify `gh` is authenticated: `gh auth status`. If it fails, report: "gh auth status failed — run 'gh auth login' first"

# crochet:import --source github

Imports GitHub Issues (with milestones, labels, assignees, and native
dependency relationships) into git-zhi. Uses `gh` CLI for all GitHub
interaction — no Go code or direct API calls.

## Trigger

User says "import from GitHub," "import GitHub issues," "import GitHub
milestone," or runs `crochet:import --source github`.

## Process

### Step 1: Identify Source

Ask the user for the import scope. Accept one of:

- A GitHub milestone name: e.g., "v2.0"
- A GitHub label: e.g., "sprint-23"
- Specific issue numbers: e.g., "1,2,3"
- All open issues (no filter)

Determine the repository from the current git remote:
```bash
gh repo view --json nameWithOwner -q '.nameWithOwner'
```

### Step 2: Fetch Issues

```bash
gh issue list --milestone "<milestone>" --state all --json number,title,body,state,labels,milestone,assignees --limit 0
```

Adjust the filter flags based on the source type from Step 1:
- `--milestone "<name>"` for milestone imports
- `--label "<name>"` for label imports
- No filter flags for "all open" (add `--state open`)
- For specific issue numbers, fetch each individually:
  `gh issue view <number> --json number,title,body,state,labels,milestone,assignees`

Parse the JSON output. If the result set has more than 100 issues, warn
the user with the count and ask for confirmation before proceeding.

### Step 3: Fetch Dependencies

For each issue, fetch native GitHub dependency data via the REST API.
The dependency endpoints require a versioned API header (GA August 2025):

```bash
gh api -H "X-GitHub-Api-Version: 2026-03-10" repos/{owner}/{repo}/issues/{number}/dependencies/blocked_by
gh api -H "X-GitHub-Api-Version: 2026-03-10" repos/{owner}/{repo}/issues/{number}/dependencies/blocking
```

Build a dependency graph from the responses.

**Cross-repo handling:** GitHub supports cross-repo blocking. If a
dependency points to an issue in a different repository, skip it with a
warning: "Skipping cross-repo dependency: {owner}/{repo}#{number} — only
intra-repo dependencies are imported."

**API errors:** If the dependency endpoints return 404 (older GitHub
Enterprise instance without dependency support), warn and continue without
dependencies: "GitHub dependency API not available — importing issues
without dependency data."

### Step 4: Map Fields

Apply field mappings from GitHub to zhi:

| GitHub Field | Zhi Field | Mapping |
|---|---|---|
| `title` | `title` | Direct |
| `body` | `body` | Direct |
| `state` (open) | `state` | `pending` |
| `state` (closed) | `state` | `done` |
| `labels[].name` | `labels` | Direct (array) |
| `milestone.title` | `milestone` | Direct (create if needed) |
| `assignees[0].login` | `assigned` | `human:<login>` |
| `number` | `tracker_id` | `github:<owner>/<repo>#<number>` |
| `blocked_by` deps | `blocked_by` | Map via issue number to zhi UUID |
| `blocking` deps | `blocks` | Map via issue number to zhi UUID |

### Step 5: Check Mapping File

Load `.git/zhi-sync/ghi-mapping.json` if it exists:

```json
{
  "repo": "owner/repo",
  "issues": {
    "42": "019d0891-xxxx-xxxx-xxxx-xxxxxxxxxxxx",
    "43": "019d0892-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
  }
}
```

If the file exists but the `repo` field doesn't match the current
repository, warn the user and ask whether to proceed (different repo
import into same zhi chain).

Skip any GitHub issue number already present in the mapping — these have
already been imported. Count them as "already imported" in the summary.

### Step 6: Create Milestone (if needed)

If the GitHub milestone maps to a zhi milestone that doesn't exist:

```bash
git zhi milestone add "<milestone name>"
```

If the GitHub milestone has a due date, set it:

```bash
git zhi milestone edit "<milestone name>" --due <YYYY-MM-DD>
```

If the zhi milestone already exists, report it as "exists" in the summary.

### Step 7: Present for Review

Show the proposed import to the user:

```
Import from github.com/<owner>/<repo> milestone "<name>":

  #42  "Fix login timeout"         -> pending, milestone: v2.0, labels: [bug]
  #43  "Add password reset"        -> pending, milestone: v2.0, blocked_by: #42
  #44  "Update auth docs"          -> done, milestone: v2.0, blocked_by: #43
  --   #45 "Already imported"       (skipped — already in mapping)

  3 issues to import (1 already imported, skipped)
  1 milestone (v2.0 — exists)
  2 dependency edges
  1 cross-repo dependency skipped

  Accept? [y]es, [e]dit, [s]kip
```

If the user chooses **edit**, allow them to modify the proposed issues
(remove issues, change field mappings, adjust dependencies) before
proceeding.

If the user chooses **skip**, abort without changes.

### Step 8: Create Issues (Two-Pass)

**Pass 1 — Create issues:**

For each accepted issue, create it via:
```bash
git zhi issue add "<title>" --body "<body>" --milestone "<ms>"
```

Capture the newly created zhi UUID from the command output (the 8-char
prefix in "Created XXXXXXXX: <title>"). Record the full UUID in the
mapping keyed by GitHub issue number.

After creation, set additional fields that `issue add` doesn't support
as flags:
```bash
# Set labels
git zhi issue edit <uuid> --label "<label>"

# Set assignee
git zhi issue edit <uuid> --assign "human:<login>"

# Set state to done for closed GitHub issues
git zhi issue edit <uuid> --state start
git zhi issue edit <uuid> --state done
```

**Pass 2 — Wire dependencies:**

For each dependency edge in the graph, look up both the source and target
zhi UUIDs from the mapping file, then wire the edge:

- GitHub `blocked_by` (issue X is blocked by issue Y):
  `git zhi issue edit <X-uuid> --after <Y-uuid>`
- GitHub `blocking` (issue X blocks issue Y):
  `git zhi issue edit <X-uuid> --block <Y-uuid>`

If a dependency target is not in the mapping (not in the import set and
not previously imported), skip the edge with a warning: "Skipping
dependency: #{number} not in mapping — import it first or wire manually."

### Step 9: Update Mapping

Write the updated mapping to `.git/zhi-sync/ghi-mapping.json`:

```bash
mkdir -p .git/zhi-sync
```

Write the JSON file with the `repo` field and all issue mappings
(both previously imported and newly created).

### Step 10: Report

Output a summary:

```
Import complete from github.com/<owner>/<repo>:

  Created: 3 issues
  Skipped: 1 (already imported)
  Dependencies wired: 2
  Dependencies skipped: 1 (cross-repo)
  Milestone: v2.0 (existed)

  Mapping file: .git/zhi-sync/ghi-mapping.json (4 entries)
```

## Error Handling

| Error | Action |
|---|---|
| `gh` not installed | Report with install URL, stop |
| `gh` not authenticated | Report with `gh auth login` command, stop |
| GitHub API rate limit | Report the error from `gh api`, suggest retry later |
| Dependency API returns 404 | Warn, continue without dependencies |
| Issue in mapping but deleted on GitHub | Skip with warning during re-run |
| Dependency target not in mapping | Skip edge with warning, suggest manual wiring |
| Cross-repo dependency | Skip with warning |
| `git zhi issue add` fails | Report the error, continue with remaining issues |
| Mapping file repo mismatch | Warn, ask user to confirm |

## Key Constraints

- All GitHub interaction through `gh` CLI — never call GitHub API directly
- All zhi interaction through `git zhi` CLI — never access refs directly
- The mapping file is the source of truth for import idempotency
- TrackerID (`github:<owner>/<repo>#<number>`) is set on every imported issue
- Dependencies are wired in a second pass after all issues exist
- The user reviews and approves before any issues are created
- Cross-repo dependencies are explicitly out of scope

## Integration

- **crochet:import** is the parent skill — this is the GitHub-specific subskill
- **crochet:refinement** can be run after import to add TDD structure and AC to imported issues
- **crochet:execute** can then execute the imported chain
