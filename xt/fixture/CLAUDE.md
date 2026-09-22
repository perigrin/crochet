<!-- ABOUTME: The fixture's door onto its live documentation layer, mirroring the repository's own. -->
<!-- ABOUTME: Imports the deliberately broken document so the covers check keeps a subject after retargeting. -->
# CLAUDE.md

The fixture repository's live layer. It exists so that `xt/run.sh`'s
empty-`covers:` check has a subject list here once that loop reads what
`CLAUDE.md` imports rather than two hardcoded directories.

## The live layer

@docs/architecture/unwatched.md

That document declares `covers: []` and names nothing, so nothing watches it.
It is broken on purpose and `xt/fixture/expected` declares the finding it
produces. Do not repair it, and do not remove this import: the loop would then
iterate nothing, the declared entry would go unmatched, and the self-test would
report that the check has gone quiet.

This file carries no frontmatter and no `covers:` of its own, the same way the
repository's `CLAUDE.md` does. It is the door onto the live set, not a member
of it.
