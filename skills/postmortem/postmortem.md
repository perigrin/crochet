---
name: postmortem
description: Generate a mandatory process retrospective at milestone completion — structured analysis of what worked, what didn't, what surprised us, and what to do differently
---

# crochet:postmortem

Required at milestone completion. A process retrospective, not a bug report. Modeled on Esther Derby's retrospective framework.

## Trigger

All issues done, resolution command passed, verify clean. Invoked before `git zhi milestone edit --state complete`.

## Preflight

Invoke `crochet:preflight` as the first step. Use the returned capabilities map for all conditional checks below.

## Verification

**If `superpowers:verification-before-completion` is available** (check preflight capabilities):
  Invoke it now, before data gathering. Follow it; do not reimplement it.

**Otherwise (not available):**
  Note that verification-before-completion is unavailable. Gather available
  data sources and note any missing sources in the postmortem output.

## Data Gathering

Collect all inputs via `git zhi` CLI commands:

```bash
# Issues in this milestone
git zhi issue list --milestone <name> --format json

# Milestone telemetry (speed, MPG, buffer, fever chart, forecast)
git zhi milestone show <name> --format json

# Verification results
git zhi verify <name> --format json

# Documentation health
git zhi docs health --format json

# Engineering metrics (if sanbao available)
git zhi sanbao <name> --format json

# Commit messages for sentiment context
git log <session-sha-ranges>
```

If a plugin is not on `$PATH`, skip its data with a note in the postmortem.

## Postmortem Structure

Generate a markdown document structured around four questions:

### 1. What worked well?

Analyze the data for positive signals:

- **Clean execution:** Issues with low commit counts (below MPG average), no reopens, ACs passing first time. Name the specific issues.
- **Accurate decomposition:** Issues that did not need splitting, merging, or cancellation. Was the issue sizing right?
- **Successful parallelization:** Workers that operated independently without merge friction. Were path predictions accurate?
- **Effective quality gates:** Did negative scenarios from the SQE agent catch problems? Did verify find regressions before manual review?

### 2. What didn't work?

Analyze the data for negative signals:

- **Worker struggles:** Issues with high commit counts (above 2x MPG), negative sentiment trajectories, reopened issues, session abandonment. What made them hard?
- **Decomposition errors:** Issues that were split or merged mid-milestone, undeclared coupling discovered via lineage, cancelled issues that represented scope mistakes.
- **Forecast misses:** Predicted vs actual completion time — and *why* the forecast was off, not just that it was. Was the critical chain longer than expected? Did parallelization not materialize?
- **Quality gaps:** ACs that passed but should not have (false positives), regressions caught late, doc drift.

### 3. What puzzles us?

Flag unexpected patterns:

- Issues that were easy on paper but hard in practice (or vice versa)
- Anomalous telemetry — speed changes mid-milestone, sudden MPG spikes
- Lineage surprises — coupling nobody anticipated
- Sentiment anomalies without obvious cause

### 3.5. Where did a human have to act, and what would have let the agent proceed?

The autonomy audit. Crochet exists to maximise the autonomy of agents
delivering software in collaboration with a human, so every point where the loop
stopped for a person is a defect to engineer away rather than a fact to record.

Ask it of each interruption:

- **Reopen cycles and stuck issues** — what did the agent lack that a human
  supplied?
- **Readiness checks that stopped and asked** — was the question answerable from
  the repository? If it was, the gate should have answered it.
- **Permissions and refusals** — a denied tool call is friction with a cause.
- **Escalations** — a judgment call handed up. Was it genuinely the human's, or
  did it only feel that way from the inside?

**Not every interruption is a defect.** Collaboration is the point, and a human
making a judgment the protocol reserves for them — the direction of the
repository, a decision to decline, an override — is the system working. The
audit distinguishes friction from collaboration rather than counting every human
touch as waste.

**The actor telemetry is not the source, yet.** Worker identity prefixes a
transition's actor with `human:` or `agent:`, which looks like the right signal
and is not: the prefix records whether `ZHI_ACTOR` was exported, not who acted.
`ZHI_ACTOR` is minted in execute's dispatch, so refinement, chain-review and a
backfilling review all write transitions outside it. An audit keyed on it today
would report every agent action as a human interruption. Ask the question of the
session instead, and use the query once identity discipline reaches every skill
that writes a transition.

### 4. What will we change?

Propose concrete, actionable process changes:

- **Decomposition improvements:** "Issues touching package X averaged 12 commits versus 4 for other packages — consider thinner slices in X-heavy milestones"
- **Convention changes:** "The SQE agent's negative scenarios caught 2 regressions — maintain this practice" or "Issue steps were too prescriptive and the agent had to deviate — use lighter steps"
- **Tooling observations:** "The frontmatter library returns `[]byte` not `io.Reader` — add to coding conventions"
- **Estimation corrections:** "Critical chain was underestimated by 30% due to undeclared coupling — decomposer should flag shared config files"

Each recommendation should be specific enough that a future `crochet:refinement` run can act on it.

## Output

Write the postmortem to the archive first. That write is unconditional and is
what makes the retrospective durable:

```bash
mkdir -p docs/postmortems
cat > docs/postmortems/<milestone>.md <<'EOF'
# Milestone <name> Postmortem

## What Worked Well
...

## What Didn't Work
...

## What Puzzles Us
...

## Where A Human Had To Act
...

## What Will We Change
...

---
Generated by crochet:postmortem on <date>
Data sources: issue list, milestone telemetry, verify results, docs health, sanbao report
EOF
```

`mkdir -p` is not redundant: `git zhi docs init` creates `docs/postmortems/`
but git does not track empty directories, so the first clone of a scaffolded
repo has no such directory.

Then attach it to the milestone, but only if the installed binary supports it.
The flag exists at git-zhi HEAD and not in every released build, so probe
rather than assume:

```bash
if git zhi milestone edit --help 2>&1 | grep -q -- '--postmortem'; then
  git zhi milestone edit <name> --postmortem - < docs/postmortems/<milestone>.md
fi
```

Note the sentinel. `--postmortem` takes a value, and `-` is what makes it read
stdin; a bare `--postmortem` before a heredoc consumes the next argument
instead, which is how every postmortem written by this skill was silently lost.

## Constraints

- The postmortem is about **process**, not product. Code quality is handled by verify, sanbao, and docs. The postmortem asks: how is our way of working holding up?
- Do not propose specific documentation updates — that is the technical writer's concern
- Every claim must reference specific data (issue IDs, metric values, commit counts)
- Recommendations must be actionable — "do better" is not a recommendation
- Keep the document under 1000 words. Concise retrospectives get read; long ones do not.
