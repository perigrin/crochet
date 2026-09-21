# Fixture

A deliberately broken repository root. `xt/run.sh` must fail against it — that
is how the runner demonstrates it can still fail.

Each defect here answers for exactly one check, so a line missing from
`xt/fixture/expected` names which check stopped examining.

## Short Links to Important Resources

- [Architecture](docs/architecture)
- [Decisions](docs/decisions)
- [A document that is not here](docs/decisions/0009-absent.md) — deliberately
  dead, so `git zhi docs check` must report a broken link. Without it that check
  passes against the fixture and the self-test cannot tell whether it ran.
