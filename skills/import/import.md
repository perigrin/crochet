---
name: import
description: Assisted ticket import from external trackers — reads ticket data from sync plugin stdout, proposes chain placement with dependencies and urgency, presents for user review
---

# crochet:import

Reads an external ticket (via the sync plugin's stdout format) and proposes chain placement with dependencies, urgency, and labels. Presents the enriched issue for user review before creation.

## Trigger

User wants to import a ticket into the chain: "import LOPS-142" or "add this Jira ticket."

## Process

### Step 1: Fetch Ticket Data

Run the appropriate sync plugin to get the ticket as zhi YAML:

```bash
git zhi jira LOPS-142
```

This emits issue YAML to stdout. Parse it to get the raw ticket data (title, description, priority, assignee).

### Step 2: Analyze Chain State

Read the existing chain:

```bash
git zhi list --format json
```

For each existing issue, note its `context.paths` and current state.

### Step 3: Propose Chain Placement

Based on the ticket's content and the existing chain:

- **Dependencies:** Compare the ticket's likely file paths (inferred from description keywords and any explicit file references) against existing issues' `context.paths`. Issues with overlapping paths are dependency candidates. Present them ranked by overlap strength.
- **Urgency:** Map from tracker priority. Jira "Critical"/"High" → `high`, "Medium" → `normal`, "Low" → `low`.
- **Label:** Suggest from tracker project prefix (e.g., Jira project "LOPS" → label "LOPS").
- **Context paths:** Infer from description, or ask the user.

### Step 4: Present for Review

Show the enriched issue YAML with proposed values highlighted:

```
Proposed issue from LOPS-142:

  title: "Extract config service"
  urgency: high          ← from Jira priority "High"
  labels: ["LOPS"]       ← from Jira project
  assigned: "dev-a"      ← from Jira assignee
  blocked_by: [019444a3] ← path overlap with "Implement config loader"

  ## Context
  - paths: internal/config/          ← inferred from description
  - commands: go test ./internal/config/...

  Accept? [y]es, [e]dit, [s]kip
```

### Step 5: Create Issue

On acceptance, pipe the final YAML to core:

```bash
echo "<issue yaml>" | git zhi issue add
```

If the user chose edit, open the YAML for modification before piping.

## Key Constraints

- The import skill is opt-in. The sync plugin works without it.
- Every proposed value must explain its reasoning (mapped from X, inferred from Y, overlaps with Z).
- The user has final say on every field. The skill proposes; the human decides.
- If dependency inference is uncertain, present candidates ranked by confidence rather than silently wiring dependencies.
