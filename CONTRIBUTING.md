# Contributing

Crochet is a Claude Code plugin: skills and command stubs, written in markdown.
There is no build and no compiled output, so the files in the tree are the files
that ship.

## Short Links to Important Resources

- [Architecture](docs/architecture) — what crochet is and how its parts fit
- [Contributing guides](docs/contributing) — coding conventions and development workflow
- [Decisions](docs/decisions) — the numbered decision archive, and why things are as they are
- [Postmortems](docs/postmortems) — milestone retrospectives
- [Plans](docs/plans) — pre-series design and implementation documents, frozen and cited by path

Every link here points at a directory that holds a file. Git does not track
empty directories, so a link into one survives locally and dies on the first
clone.

## Checks

```bash
git zhi docs check     # reachability, dead links, decision numbering, covers paths
git zhi docs health    # drift between a document's covers: paths and their churn
```

What each check enforces is written in the check, not restated here.
`docs/contributing/development-workflow.md` describes how to validate a change,
and `docs/contributing/coding-conventions.md` describes what the skills must
hold to.

## Working here

Feature branches come off `pu` and return by pull request. `pu` is protected.

Update a live document before the change it describes, in the same pull
request. The reasoning is in
[decision 0001](docs/decisions/0001-documentation-architecture.md).
