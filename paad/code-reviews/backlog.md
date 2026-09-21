# Out-of-Scope Findings Backlog

> **These items were flagged by `/agentic-review` as out of scope for the branch
> on which they were found.** They may be stale, may already have been fixed by other
> means, may no longer apply after refactors, or may simply have been judged not worth
> addressing. Verify each entry against the current code before acting on it. Entries
> are removed only when explicitly addressed — no automatic cleanup.

---

## `c7ef6dd3` — Install pipes a mutable branch ref straight to `sh`
- **File (at first sighting):** `skills/install/install.md:45`
- **Symbol:** `<file-scope>`
- **Bug class:** Security
- **Description:**
```text
Step 3 runs: curl -fsSL https://raw.githubusercontent.com/perigrin/git-zhi/pu/install.sh | sh

The URL names a BRANCH (pu), not a release tag or commit SHA, and the script is
piped straight into a shell. There is no checksum, no signature, and no pinned
version. Whatever is on pu at the moment of execution is executed on the user's
machine. Step 4 verifies only that `git zhi version` runs -- not that the binary
is the one that was expected. The documented fallback at install.md:63,
`go install github.com/perigrin/git-zhi@latest`, is unpinned for the same reason.

Pre-existing: line 45 is untouched by branch rfc-0001-field-set. The related
in-scope angle (the branch raised git_zhi_min_version to 0.7.2 and added
enforcement, leaving no way to install a specific version) is finding [I8] in the
rfc-0001-field-set review report.
```
- **Suggested fix:**
```text
Pin the installer to a release tag or commit SHA rather than a branch, and verify
a published checksum before executing. Apply the same to the go install fallback
by pinning to the version declared in .claude-plugin/plugin.json rather than
@latest.
```
- **Confidence:** High
- **Found by:** Security (inline, not dispatched) (`claude-opus-5[1m]`)
- **First seen:** 2026-09-21 on branch `rfc-0001-field-set` at `3cb4e93`
- **Last seen:** 2026-09-21 on branch `rfc-0001-field-set` at `3cb4e93`
- **Severity:** Critical
