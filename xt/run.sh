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

# The count lives in a file rather than a variable. A variable cannot survive a
# subshell, and the right-hand side of a pipeline is one — so a `note` inside
# `... | while read` printed FAIL: and incremented nothing, and the runner
# reported ok: and exited 0. `t/git-zhi-subcommands.sh` already carried the
# warning ("Redirect from a file, not a pipe, so the counters survive the loop")
# and this file violated it anyway. A file-backed count removes the hazard
# instead of asking the next author to remember.
FAILS="${TMPDIR:-/tmp}/zhi-xt-fail-$$"
: > "$FAILS"
trap 'rm -f "$FAILS"' EXIT
note() { echo "FAIL: $*"; echo x >> "$FAILS"; }

# A root with nothing to check is a failure. A runner that reports success
# while observing nothing has failed open, which is worse than being absent.
if [ ! -d "$ROOT/docs" ]; then
    echo "FAIL: no docs/ under $ROOT — this runner is observing nothing" >&2
    exit 1
fi

# ---------------------------------------------------------------- product
# A check whose subject is missing is a finding, not a skip. `[ -f X ] &&` made
# a deleted product check indistinguishable from a passing one: moving this file
# away left the runner reporting ok: and exiting 0.
if [ "$SELFTEST" = yes ]; then
    if [ ! -f t/git-zhi-subcommands.sh ]; then
        note "t/git-zhi-subcommands.sh is missing — the product check cannot run"
    elif ! sh t/git-zhi-subcommands.sh; then
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

# --------------------------------------------- accepted on a proposed footing
# A decision may not be accepted while a decision it amends is still proposed:
# the amendment would be in force against a rule nobody has agreed to. 0004 came
# within one step of this against 0003, which is why the rule exists. Checkable
# at the moment `state: accepted` is written, which is the only moment it can be
# broken.
state_of() { sed -n '2,/^---$/p' "$1" | sed -n 's/^state:[[:space:]]*//p' | head -1; }

if [ -d "$DEC" ]; then
    for f in "$DEC"/*.md; do
        [ -f "$f" ] || continue
        [ "$(state_of "$f")" = accepted ] || continue
        me=$(num_of "$f")
        entries=$(sed -n '2,/^---$/p' "$f" | grep -E '^amends:' |
                  sed -E 's/^amends:[[:space:]]*//; s/[][]//g; s/,/ /g')
        for e in $entries; do
            case "$e" in
                ""|"[]") continue ;;
                */*|*.md) continue ;;
            esac
            target=$(ls "$DEC/$e"-*.md 2>/dev/null | head -1)
            [ -n "$target" ] || continue
            st=$(state_of "$target")
            case "$st" in
                accepted|superseded) : ;;
                *) note "$me is accepted, but $e — which it amends — is '$st'" ;;
            esac
        done
    done
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

# --------------------------------------------- implementing an accepted one
# A gate that was skipped and a gate that passed leave the same trace: none.
# This is the one place a skip is recoverable afterwards, because the claim to
# have implemented a decision is written into the commit, and the decision says
# whether it had been accepted yet. Per 0003, acceptance is what refinement
# writes; implementing before that is the pipeline running out of order.
if [ "$SELFTEST" = yes ] && [ -d "$DEC" ]; then
    for n in $(git log --format='%(trailers:key=Implements,valueonly)' | tr -d ' ' | grep . | sort -u); do
        target=$(ls "$DEC/$n"-*.md 2>/dev/null | head -1)
        if [ -z "$target" ]; then
            note "a commit claims Implements: $n, which is not a decision in the series"
            continue
        fi
        state=$(sed -n '2,/^---$/p' "$target" | sed -n 's/^state:[[:space:]]*//p')
        case "$state" in
            accepted|superseded) : ;;
            *) note "commits implement $n while it is '$state' — the refinement gate was skipped" ;;
        esac
    done
fi

# ------------------------------------------- declared floor vs installed binary
# The repository declares git_zhi_min_version and crochet:preflight compares the
# installed binary against it at runtime. Nothing here read either value, so the
# two criteria asserting they agree were satisfied by checks that never looked —
# a floor raised past the installed binary was invisible to everything in xt/.
#
# git-zhi is required, not optional: the product check and `docs check` above
# both fail without it, so the earlier claim that this runner tolerates a
# machine without the binary was never true.
if [ "$SELFTEST" = yes ]; then
    if [ ! -f .claude-plugin/plugin.json ]; then
        note ".claude-plugin/plugin.json is missing — nothing declares a git-zhi floor"
    else
        floor=$(sed -n 's/.*"git_zhi_min_version"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' \
                .claude-plugin/plugin.json | head -1)
        installed=$(git zhi version 2>/dev/null | head -1 | awk '{print $2}')
        if [ -z "$floor" ]; then
            note "plugin.json declares no git_zhi_min_version — preflight has no floor to enforce"
        elif [ -z "$installed" ]; then
            note "could not read a version from git zhi version — the floor is unverifiable"
        else
            # sort -V understands versions, so 1.10.0 sorts above 1.2.3, a
            # four-field version works, and a floor that is not a version at all
            # sorts last and is reported rather than silently passing.
            lowest=$(printf '%s\n%s\n' "$installed" "$floor" | sort -V | head -1)
            if [ "$installed" != "$floor" ] && [ "$lowest" = "$installed" ]; then
                note "installed git-zhi $installed is below the declared floor $floor"
            fi
        fi
    fi
fi

# -------------------------------------------------------------- self-test
# The runner must be able to fail. A guardrail that silently stopped firing
# has failed open, and you stopped watching for what it caught.
#
# One exit code is not enough to say that. It only proves *some* check fired,
# and it stayed green while four checks were deleted outright — link symmetry,
# accepted-on-a-proposed-footing, cite-symbols and Implements, 106 lines, with
# output identical to a full run. So the fixture declares what every check must
# report, in xt/fixture/expected, and a check that stops examining goes missing
# from the fixture's output and is named here.
if [ "$SELFTEST" = yes ]; then
    if [ ! -d xt/fixture ]; then
        note "xt/fixture is missing — the runner cannot demonstrate that it fails"
    elif [ ! -s xt/fixture/expected ]; then
        note "xt/fixture/expected is missing or empty — nothing says which checks must fire"
    else
        TMP="${TMPDIR:-/tmp}/zhi-xt-self-$$"
        rm -rf "$TMP"
        mkdir -p "$TMP"
        cp -R xt/fixture "$TMP/fixture"

        # `git zhi docs check` reports every tree clean when it is not a git
        # repository, so without this the fixture could never prove that check
        # still fires.
        ( cd "$TMP/fixture" && git init -q . &&
          git -c user.email=xt@fixture -c user.name=xt add -A &&
          git -c user.email=xt@fixture -c user.name=xt commit -qm fixture
        ) >/dev/null 2>&1

        OUT=$(sh "$0" "$TMP/fixture" 2>&1) || true
        if printf '%s\n' "$OUT" | grep -q '^ok:'; then
            note "the runner passed its own broken fixture — it can no longer fail"
        fi
        while IFS= read -r want; do
            [ -n "$want" ] || continue
            case "$want" in \#*) continue ;; esac
            printf '%s\n' "$OUT" | grep -qF "$want" ||
                note "no check reported \"$want\" against the fixture — that check has gone quiet"
        done < xt/fixture/expected

        rm -rf "$TMP"
    fi
fi

fail=$(wc -l < "$FAILS" | tr -d ' ')

if [ "$fail" -gt 0 ]; then
    echo "$fail check(s) failed in $ROOT" >&2
    exit 1
fi

# Name the mode. A partial run and a full one reported the same success text,
# so "ok" carried no information about how much was examined.
if [ "$SELFTEST" = yes ]; then
    echo "ok: xt checks pass in $ROOT (full run)"
else
    echo "ok: xt checks pass in $ROOT (structural checks only)"
fi
exit 0
