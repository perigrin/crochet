#!/bin/sh
# ABOUTME: Product check — every `git zhi <subcommand>` named in code really exists.
# ABOUTME: Reads code contexts only (fenced blocks and backtick spans), never prose.
#
# Usage: sh t/git-zhi-subcommands.sh [dir]   (default: skills)
#
# A skill naming a subcommand the binary does not have is a document asserting
# something that was never built. Prose is not code: a subcommand named in a
# sentence is being discussed, not invoked, so only fenced blocks and backtick
# spans are read.
#
# Two shapes, two mechanisms, because --help is only an existence test for one
# of them:
#
#   git zhi <sub>           --help exits non-zero when <sub> does not exist
#   git zhi <parent> <sub>  --help exits ZERO either way; cobra falls back to
#                           the parent's help. So the child is looked for in
#                           the parent's "Available Commands" list instead.
#
# Verified on git-zhi 0.5.0: `git zhi project nonexistent --help` exits 0.

DIR="${1:-skills}"

# Without the binary every probe fails, and this reported "30 of 30 subcommands
# named in skills do not exist" — thirty false statements, none naming the real
# problem. The repository's own rule is to read the failure text rather than the
# exit code; a check that exits non-zero for the wrong reason has told you
# nothing.
if ! command -v git-zhi >/dev/null 2>&1; then
    echo "FAIL: git-zhi is not on \$PATH — this check cannot run" >&2
    exit 1
fi

if [ ! -d "$DIR" ]; then
    echo "FAIL: not a directory: $DIR" >&2
    exit 1
fi

# Code contexts only: lines inside ``` fences, plus the contents of `spans`.
CODE=$(find "$DIR" -name '*.md' -type f -exec awk '
    FNR == 1     { fence = 0 }
    /^[ \t]*```/ { fence = !fence; next }
    fence        { print; next }
    {
        line = $0
        while (match(line, /`[^`]*`/)) {
            print substr(line, RSTART + 1, RLENGTH - 2)
            line = substr(line, RSTART + RLENGTH)
        }
    }
' {} +)

# A second word is taken only when it is a plain word, so flags and
# <placeholders> end the match.
CANDIDATES=$(
    printf '%s\n' "$CODE" |
    grep -oE 'git[ -]zhi +[a-z][a-z-]*( +[a-z][a-z-]*)?' |
    sed -E 's/^git[ -]zhi +//; s/ +/ /g' |
    sort -u
)

if [ -z "$CANDIDATES" ]; then
    echo "FAIL: no git zhi subcommands named in $DIR — this check is observing nothing" >&2
    exit 1
fi

# Hyphenated companion invocations (`git-zhi-docs`, `git-zhi-sanbao`, ...).
# v0.5.0 folded the plugin trees into one binary and dropped dispatch by name,
# so these no longer work. They fail open rather than loudly: the stale symlink
# is still on $PATH, so `git-zhi-sanbao --help` exits 0 while really running
# `git-zhi --help`. Any such invocation in code is broken.
# Fenced blocks only. An inline `git-zhi-verify` usually names the component
# under discussion; a fenced line is something to run. Naming is not calling.
FENCED=$(find "$DIR" -name '*.md' -type f -exec awk '
    FNR == 1     { fence = 0 }
    /^[ \t]*```/ { fence = !fence; next }
    fence        { print }
' {} +)
HYPHENATED=$(
    printf '%s\n' "$FENCED" |
    grep -oE 'git-zhi-[a-z][a-z-]*' |
    sort -u
)
if [ -n "$HYPHENATED" ]; then
    echo "$HYPHENATED" | while IFS= read -r h; do
        [ -n "$h" ] || continue
        echo "FAIL: $h is a companion invoked by name; dispatch was removed in v0.5.0 (use 'git zhi ${h#git-zhi-}')"
    done
    hyph_count=$(printf '%s\n' "$HYPHENATED" | grep -c .)
else
    hyph_count=0
fi

# The other direction: assert that a hyphenated companion does not dispatch.
# This one passes today and would fail if dispatch by name came back, which is
# what makes the suite able to detect its own absence — every other assertion
# here is of the form "this should fail", and a suite that only knows how to
# fail cannot tell a broken harness from a real defect.
#
# It must test behaviour, not presence. The symlinks are still on $PATH and
# fail open: `git-zhi-docs --help` exits 0 because it runs `git-zhi --help`.
# So ask for a companion SUBCOMMAND, which only dispatch could satisfy.
if command -v git-zhi-docs >/dev/null 2>&1; then
    if git-zhi-docs check >/dev/null 2>&1; then
        echo "FAIL: git-zhi-docs dispatches again — the hyphenated-name checks above are now wrong"
        dispatch_bad=1
    else
        dispatch_bad=0
    fi
else
    dispatch_bad=0   # name absent entirely, which is the other correct state
fi

# A string-valued flag written bare is accepted by the shell and rejected by the
# binary. `issue edit <id> --body` exits 1 with "flag needs an argument" while
# the next line of the same block succeeds, so the body is never written and
# nothing says so — the reopened issue comes back without the findings that
# were meant to be in it.
#
# Arity comes from the binary, not a list here: a flag that changes kind is
# then caught rather than assumed. Fenced blocks only, for the same reason the
# hyphenated check uses them — a backtick span may name a flag to discuss it,
# where a fenced line is something to run.
STRFLAGS=$(
    for sub in 'issue edit' 'issue add' 'milestone edit' 'milestone add'; do
        # shellcheck disable=SC2086
        git zhi $sub --help 2>&1 | sed -n 's/^ *--\([a-z][a-z-]*\) string .*/\1/p'
    done | sort -u | tr '\n' '|' | sed 's/|$//'
)
if [ -z "$STRFLAGS" ]; then
    echo "FAIL: no string-valued flags found on the binary — the arity check is observing nothing" >&2
    exit 1
fi
BARE=$(printf '%s\n' "$FENCED" |
       grep -E -- "--($STRFLAGS)([[:space:]]*\$|[[:space:]]*\||[[:space:]]*<<)" || true)
if [ -n "$BARE" ]; then
    printf '%s\n' "$BARE" | while IFS= read -r l; do
        [ -n "$l" ] || continue
        echo "FAIL: a string-valued flag is written bare, so the binary rejects it:$(printf '%s' "$l" | sed 's/^[[:space:]]*/ /')"
    done
    arity_bad=$(printf '%s\n' "$BARE" | grep -c .)
else
    arity_bad=0
fi

TMP="${TMPDIR:-/tmp}/zhi-subcommands.$$"
printf '%s\n' "$CANDIDATES" > "$TMP"

total=0
bad=0
# Redirect from a file, not a pipe, so the counters survive the loop.
while IFS= read -r cand; do
    [ -n "$cand" ] || continue
    total=$((total + 1))

    parent=${cand%% *}
    child=${cand#* }

    if [ "$child" = "$cand" ]; then
        # One word: --help is a real existence test.
        if ! git zhi "$parent" --help >/dev/null 2>&1; then
            echo "FAIL: git zhi $parent does not exist (named in $DIR)"
            bad=$((bad + 1))
        fi
        continue
    fi

    # Two words: ask the parent what children it has.
    if ! git zhi "$parent" --help >/dev/null 2>&1; then
        echo "FAIL: git zhi $parent does not exist (named in $DIR as '$cand')"
        bad=$((bad + 1))
        continue
    fi
    if ! git zhi "$parent" --help 2>&1 |
         awk '/Available Commands:/ { in_list = 1; next }
              /^[A-Za-z]+:/         { in_list = 0 }
              in_list               { print $1 }' |
         grep -qx "$child"; then
        echo "FAIL: git zhi $parent has no '$child' subcommand (named in $DIR)"
        bad=$((bad + 1))
    fi
done < "$TMP"
rm -f "$TMP"

bad=$((bad + hyph_count + dispatch_bad + arity_bad))

if [ "$bad" -gt 0 ]; then
    # Not "$bad of $total subcommands do not exist": the count now mixes
    # missing subcommands with flags written at the wrong arity, and a summary
    # naming the wrong defect sends the reader to the wrong line.
    echo "$bad problem(s) in $DIR across $total subcommands named" >&2
    exit 1
fi

echo "ok: $total subcommands named in $DIR all exist"
exit 0
