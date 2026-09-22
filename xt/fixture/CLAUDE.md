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

## The decoy

The string `rfc-0002` is on this line on purpose, and nothing else here may name
the amender decision in a citation form.

The fixture's only accepted, implemented decision is the one numbered two, and
no document here cites it — so the backstop must report it as cited nowhere. A
bare search for the number would match the decoy above, go silent, leave the
declared entry unmatched, and the self-test would report that a check has gone
quiet. This is the only thing in either suite that can tell a citation pattern
from a number search.

Do not remove the decoy, and do not write that decision's filename or bracketed
number anywhere in this file — doing so cites it, which silences the arm this
fixture exists to prove. That mistake was made once while writing this file and
the fixture caught it.
