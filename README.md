# Crochet

Intelligence layer for git-zhi. Crochet is a Claude Code plugin that provides
skills for decomposing specs into executable chains, importing external tickets,
generating reports, onboarding repos, and validating pipeline outputs.

## Skills

| Skill | Purpose |
|-------|---------|
| `crochet:refinement` | Decompose a spec into an executable git-zhi chain (architect, decomposer, SQE, tech writer) |
| `crochet:assess` | Analyze a PRD against the codebase to identify gaps, partial implementations, and blockers |
| `crochet:import` | Assisted ticket import from Jira or other trackers with dependency inference |
| `crochet:report` | Generate narrative reports from user-defined templates with Mermaid charts |
| `crochet:onboard` | Step-by-step git-zhi adoption walkthrough with verification at each step |
| `crochet:pushback` | Pre-flight validation of specs, historian output, and report templates |
| `crochet:alignment` | Post-pipeline verification: refinement vs PRD, historian vs git log, forward vs historical chain |
| `crochet:postmortem` | Mandatory process retrospective at milestone completion |
| `crochet:install` | Install git-zhi binary and companion symlinks |

## Prerequisites

[git-zhi](https://github.com/perigrin/git-zhi) must be on `$PATH`. If it's
not installed, run `crochet:install` or install manually:

```bash
curl -fsSL https://raw.githubusercontent.com/perigrin/git-zhi/pu/install.sh | sh
```

Or build from source:

```bash
go install github.com/perigrin/git-zhi@latest
git zhi setup
```

## Installation

Install from the perigrin marketplace in Claude Code:

```
/plugin marketplace add perigrin/claude-plugins-marketplace
/plugin install crochet
```

## How It Works

Crochet interacts with chain state exclusively through `git zhi` CLI commands —
the same porcelain-over-plumbing pattern git itself uses. It never accesses
`refs/zhi/` directly. Each skill checks for `git-zhi` availability before
proceeding and directs users to `crochet:install` if it's missing.

## License

MIT
