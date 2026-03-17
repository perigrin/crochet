# Crochet

A Claude Code plugin that bridges specs and executable git-zhi chains. Crochet provides the intelligence layer — decomposing PRDs into executable issue chains and generating mandatory postmortems at milestone completion.

## Skills

### crochet:refinement

Replaces `superpowers:writing-plans`. Takes a brainstorming spec and produces an executable git-zhi chain through four agent roles: architect, decomposer, SQE, and technical writer.

### crochet:postmortem

Required at milestone completion. Process retrospective structured around four questions: what worked, what didn't, what puzzles us, what we'll do differently.

## Prerequisites

- [git-zhi](https://github.com/perigrin/git-zhi) core binary on `$PATH`
- Optional: `git-zhi-verify`, `git-zhi-sanbao`, `git-zhi-docs` plugins for full integration

## How It Works

Crochet interacts with chain state exclusively through `git zhi` CLI commands — the same porcelain-over-plumbing pattern git itself uses. It never accesses `refs/zhi/` directly.

## Installation

```
# Claude Code plugin installation (future)
/plugin install crochet
```
