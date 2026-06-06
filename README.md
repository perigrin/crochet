# Crochet

Intelligence layer for git-zhi. Crochet is a Claude Code plugin that provides
skills for decomposing specs into executable chains, importing external tickets,
generating reports, onboarding repos, and validating pipeline outputs.

## Skills

| Skill | Purpose |
|-------|---------|
| `crochet:assess` | Analyze a PRD against the codebase to identify gaps, partial implementations, and blockers before decomposition |
| `crochet:refinement` | Decompose a spec into an executable git-zhi chain (architect, decomposer, SQE, tech writer) |
| `crochet:chain-review` | Review a decomposed issue chain for quality, coverage, and dependency integrity before execution |
| `crochet:execute` | Execute issues from the chain via TDD with Ralph Loop inner cycle and PAAD outer gate |
| `crochet:postmortem` | Mandatory process retrospective at milestone completion |
| `crochet:install` | Install git-zhi binary and companion symlinks |
| `crochet:preflight` | Validate environment and prerequisites before starting a pipeline run |
| `crochet:verify` | Verify pipeline outputs meet acceptance criteria at each stage |
| `crochet:onboard` | Step-by-step git-zhi adoption walkthrough with verification at each step |
| `crochet:import` | Assisted ticket import from Jira or other trackers with dependency inference |
| `crochet:report` | Generate narrative reports from user-defined templates with Mermaid charts |

The following are internal skills (not directly user-invocable): `crochet:pushback`, `crochet:alignment`, `crochet:how-to-use-git-zhi`

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
