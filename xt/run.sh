#!/bin/sh
# ABOUTME: Author tests — does the repo do what CONTRIBUTING.md claims of it?
# ABOUTME: Runs the product check, doc structure, covers, and decision-link symmetry.
#
# Usage:
#   sh xt/run.sh              run every check against this repo, then self-test
#   sh xt/run.sh <root>       run the structural checks against <root> only
#
# The second form is how the fixture is driven, and why it does not self-test:
# the self-test runs this script against xt/fixture, which must terminate.
#
# These are project tests, not product tests. None of this ships to anyone
# consuming crochet. t/ tests the product; xt/ tests the repo.

ROOT="$1"
SELFTEST=yes
if [ -n "$ROOT" ]; then
    SELFTEST=no
else
    ROOT=.
fi

if [ ! -d "$ROOT" ]; then
    echo "FAIL: not a directory: $ROOT" >&2
    exit 1
fi

fail=0
note() { echo "FAIL: $*"; fail=$((fail + 1)); }

# A root with nothing to check is a failure. A runner that reports success
# while observing nothing has failed open, which is worse than being absent.
if [ ! -d "$ROOT/docs" ]; then
    echo "FAIL: no docs/ under $ROOT — this runner is observing nothing" >&2
    exit 1
fi

# ---------------------------------------------------------------- product
if [ "$SELFTEST" = yes ] && [ -f t/git-zhi-subcommands.sh ]; then
    if ! sh t/git-zhi-subcommands.sh >/dev/null 2>&1; then
        note "t/git-zhi-subcommands.sh — a skill names a git zhi subcommand that does not exist"
    fi
fi

# ---------------------------------------------------------- doc structure
if ! ( cd "$ROOT" && git zhi docs check >/dev/null 2>&1 ); then
    note "git zhi docs check — unreachable files, dead links, decision gaps or bad covers paths"
fi

# ----------------------------------------------------------------- covers
# A live document declaring covers: [] is watched by nothing. It is the state
# git zhi docs init leaves its templates in, and the state this repo was in.
for d in "$ROOT"/docs/architecture "$ROOT"/docs/contributing; do
    [ -d "$d" ] || continue
    for f in "$d"/*.md; do
        [ -f "$f" ] || continue
        # Empty means: `covers: []`, or a bare `covers:` with no list items
        # under it. A bare key is YAML null and is the form a human writes
        # when interrupted, which is the case worth catching.
        if sed -n '2,/^---$/p' "$f" | awk '
            # awk runs END even after exit, so the has-items branch clears
            # the flag rather than relying on exit alone.
            /^covers:[[:space:]]*\[\][[:space:]]*$/ { print "empty"; bare = 0; exit }
            /^covers:[[:space:]]*$/                  { bare = 1; next }
            bare && /^[[:space:]]*-[[:space:]]/       { bare = 0; exit }
            bare                                     { print "empty"; bare = 0; exit }
            END                                      { if (bare) print "empty" }
        ' | grep -q empty; then
            note "covers is empty, so nothing watches it: ${f#"$ROOT"/}"
        fi
    done
done

# ------------------------------------------------- decision link symmetry
# supersedes/superseded-by and amends/amended-by are written both ways in one
# commit. The obligation is discharged mechanically here rather than by
# discipline. A pre-series entry is a path, not a number, and is skipped:
# Migration grandfathers those and nothing is written back into them.
DEC="$ROOT/docs/decisions"
num_of() { basename "$1" | cut -c1-4; }

link_check() {
    forward=$1
    back=$2
    for f in "$DEC"/*.md; do
        [ -f "$f" ] || continue
        me=$(num_of "$f")
        entries=$(sed -n '2,/^---$/p' "$f" | grep -E "^$forward:" | sed -E "s/^$forward:[[:space:]]*//; s/[][]//g; s/,/ /g")
        for e in $entries; do
            case "$e" in
                ""|"[]") continue ;;
                */*|*.md) continue ;;   # pre-series path — grandfathered
            esac
            target=$(ls "$DEC/$e"-*.md 2>/dev/null | head -1)
            if [ -z "$target" ]; then
                note "$me $forward $e, which does not exist"
                continue
            fi
            if ! sed -n '2,/^---$/p' "$target" | grep -E "^$back:" | grep -q "$me"; then
                note "$me $forward $e, but $e has no $back link back"
            fi
            # symmetric pair: both directions of the same relation is a cycle
            if sed -n '2,/^---$/p' "$target" | grep -E "^$forward:" | grep -q "$me"; then
                note "cycle: $me and $e each $forward the other"
            fi
        done
    done
}

if [ -d "$DEC" ]; then
    link_check supersedes superseded-by
    link_check amends amended-by
fi

# ------------------------------------------------- decisions cite symbols
# A decision names a symbol, never a line: line numbers decay silently, and a
# citation into another repository has no check anywhere in the world. The
# reasoning is in docs/contributing/coding-conventions.md.
if [ -d "$DEC" ]; then
    for f in "$DEC"/*.md; do
        [ -f "$f" ] || continue
        for h in $(grep -oE '[A-Za-z0-9_./-]+\.(go|md|json|sh|ya?ml):[0-9]+(-[0-9]+)?' "$f" | sort -u); do
            note "${f#"$ROOT"/} cites a line number, not a symbol: $h"
        done
    done
fi

# -------------------------------------------------------------- self-test
# The runner must be able to fail. A guardrail that silently stopped firing
# has failed open, and you stopped watching for what it caught.
if [ "$SELFTEST" = yes ]; then
    if [ ! -d xt/fixture ]; then
        note "xt/fixture is missing — the runner cannot demonstrate that it fails"
    else
        TMP="${TMPDIR:-/tmp}/zhi-xt-self-$$"
        rm -rf "$TMP"
        mkdir -p "$TMP"
        cp -R xt/fixture "$TMP/fixture"
        if sh "$0" "$TMP/fixture" >/dev/null 2>&1; then
            note "the runner passed its own broken fixture — it can no longer fail"
        fi
        rm -rf "$TMP"
    fi
fi

if [ "$fail" -gt 0 ]; then
    echo "$fail check(s) failed in $ROOT" >&2
    exit 1
fi

echo "ok: xt checks pass in $ROOT"
exit 0
