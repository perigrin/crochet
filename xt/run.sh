#!/bin/sh
# ABOUTME: Author tests — does the repo do what CONTRIBUTING.md claims of it?
# ABOUTME: Nine check families; xt/fixture/expected names which ones it proves.
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

# Every git call below means the repository at $ROOT, and `cd` does not say so:
# git reads GIT_DIR from the environment and a cd cannot override it. Git
# exports GIT_DIR and GIT_INDEX_FILE to hooks — absolute ones when the checkout
# is a worktree — so a runner wired in as a pre-commit hook, which is what
# CONTRIBUTING.md's check list invites, would aim the self-test's `git init`,
# `add -A` and `commit` at the developer's own repository rather than at its
# fixture copy. Clear them rather than fight them.
unset GIT_DIR GIT_WORK_TREE GIT_INDEX_FILE GIT_OBJECT_DIRECTORY \
      GIT_ALTERNATE_OBJECT_DIRECTORIES GIT_NAMESPACE GIT_COMMON_DIR

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

# Counter in a file: a variable cannot survive the subshell a pipeline's right
# side runs in.
FAILS="${TMPDIR:-/tmp}/zhi-xt-fail-$$"
: > "$FAILS"
trap 'rm -f "$FAILS" "$FAILS.live"' EXIT
note() { echo "FAIL: $*"; echo x >> "$FAILS"; }

# One missing binary produced four failure messages, none of which named it:
# a skill supposedly naming a subcommand that does not exist, unreachable files
# and dead links, and a working check accused of having gone quiet. The rule
# this repository already states is to read the failure text rather than the
# exit code, and a check that fails for the wrong reason has told you nothing.
# `t/git-zhi-subcommands.sh` learned this and guards itself; the caller did not.
if [ "$SELFTEST" = yes ] && ! command -v git-zhi >/dev/null 2>&1; then
    echo "FAIL: git-zhi is not on \$PATH — most of these checks cannot run" >&2
    exit 1
fi

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
# ------------------------------------------------------------- the live set
# Two checks below ask what the live layer is, and both answer it the same way:
# CLAUDE.md and what CLAUDE.md imports. Derived once, here, so they cannot drift
# apart about it — and so a missing import is reported once rather than twice or
# not at all.
#
# One path per line, never a space-joined string. A $ROOT or TMPDIR containing a
# space split the list and reported five decisions uncited and a check gone
# quiet, none of which was true. Read with `while IFS= read -r`, not `for`.
LIVE="$FAILS.live"
: > "$LIVE"
if [ -f "$ROOT/CLAUDE.md" ]; then
    printf '%s\n' "$ROOT/CLAUDE.md" >> "$LIVE"
    # A check whose subject is missing is a finding, not a skip — the rule this
    # runner states above the product check. A typo in an @import silently
    # removed a document from the live set and both checks below narrowed with
    # no finding anywhere; renaming a different import reported a *decision*
    # uncited, naming the wrong thing entirely.
    sed -n 's/^@//p' "$ROOT/CLAUDE.md" | while IFS= read -r rel; do
        [ -n "$rel" ] || continue
        if [ -f "$ROOT/$rel" ]; then
            printf '%s\n' "$ROOT/$rel" >> "$LIVE"
        else
            note "CLAUDE.md imports $rel, which is not there — the live set is short a document"
        fi
    done
else
    # CLAUDE.md is load-bearing the way docs/ is: without it the two checks
    # below observe nothing and would otherwise report nothing, one of them
    # through a bare `sed:` on stderr that the counter never sees.
    note "no CLAUDE.md under $ROOT — the live set cannot be derived, so the covers and citation checks cannot run"
fi

# ----------------------------------------------------------------- covers
# A live document declaring covers: [] is watched by nothing. It is the state
# git zhi docs init leaves its templates in, and the state this repo was in.
#
# CLAUDE.md is in the set and passes through harmlessly: the awk reports a
# `covers:` key with no items beneath it, and a file carrying no such key never
# sets `bare`. Measured, and the reason there is no branch excluding the door.
while IFS= read -r f; do
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
done < "$LIVE"
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
        # Both YAML sequence styles. Flow (`supersedes: [0001, 0002]`) is what
        # every decision here uses; block (`supersedes:` then `  - 0001`) is
        # what `git zhi docs init` templates and a human writing several links
        # produce, and it parsed to nothing — so the obligation this check
        # exists to discharge mechanically was silently undischarged for it.
        # The covers: check fifteen lines above already handled both.
        entries=$(sed -n '2,/^---$/p' "$f" | awk -v key="$forward" '
            $0 ~ "^" key ":" {
                rest = $0; sub("^" key ":[[:space:]]*", "", rest)
                gsub(/[][,]/, " ", rest)
                if (rest ~ /[^[:space:]]/) { print rest; next }
                block = 1; next
            }
            block && /^[[:space:]]*-[[:space:]]/ {
                item = $0; sub(/^[[:space:]]*-[[:space:]]*/, "", item); print item; next
            }
            block { block = 0 }
        ')
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
# A skipped gate and a passed one leave the same trace: none. The commit's claim
# to implement a decision is the exception, so commits implementing a decision
# that is still proposed are the pipeline running out of order — 0003 sets the
# rule. Reads $ROOT so the fixture can witness it.
#
# The population is read from parsed trailers, never from the commit body. A
# body grep matches prose about implementing a decision — this repository's own
# issue text quotes the trailer form — and would credit a decision because
# somebody wrote about it. Walked once, here, because the backstop below needs
# the same list and two walks are two things to keep in step.
IMPL=$( (cd "$ROOT" && git log --format='%(trailers:key=Implements,valueonly)' 2>/dev/null) |
        tr -d ' ' | grep . | sort -u)
if [ -d "$DEC" ]; then
    for n in $IMPL; do
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

# ------------------------------------------ accepted decisions cited nowhere
# Review is a judgment and judgments do not run on every commit. This is the
# mechanical backstop for the coarsest failure doc-first has: an accepted
# decision, already implemented, that no live document reflects at all.
#
# IT IS DELIBERATELY WEAK AND A GREEN RESULT PROVES ALMOST NOTHING. The
# predicate is that the decision's number appears in a live document in one of
# the two citation forms pinned below — the slug-bearing filename, or [NNNN].
# A sentence naming the bare number does not satisfy it; a link, a code fence or
# a references entry does. It cannot tell a claim from a criticism: on the day
# this landed it was green for 0002 because coding-conventions.md faults that
# decision three times. Never read a pass here as evidence that a live document
# is complete. 0008 says the same at greater length, and crochet:review is what
# actually judges it.
#
# The live set is $LIVE, derived once above, so this and the covers check cannot
# disagree about what "live" means. Reads $ROOT so the fixture can witness it.
if [ -d "$DEC" ]; then
    population=''
    for n in $IMPL; do
        target=$(ls "$DEC/$n"-*.md 2>/dev/null | head -1)
        [ -n "$target" ] || continue
        state=$(sed -n '2,/^---$/p' "$target" | sed -n 's/^state:[[:space:]]*//p')
        case "$state" in accepted|superseded) population="$population $n" ;; esac
    done

    # A subject the check could not see is a finding, never a skip. The two
    # sub-causes emit different text on purpose: they are indistinguishable from
    # each other and from a clean run if they share a literal, and the fixture
    # can then only prove that one of them fired.
    if [ -z "$population" ]; then
        # Iterating citations rather than decisions makes an empty document
        # indistinguishable from a complete one. So does an empty population.
        note "cannot see: population is empty — no accepted decision carries an implementing trailer"
    fi
    if [ "$( (cd "$ROOT" && git rev-parse --is-shallow-repository 2>/dev/null) )" = true ]; then
        # actions/checkout produces this by default. A truncated history exempts
        # every decision implemented earlier while reporting clean.
        note "cannot see: history is shallow — decisions implemented before the cut are exempt"
    fi

    for n in $population; do
        # Match a citation, not a number. A bare search for 0002 matches the
        # milestone name rfc-0002, and this repository names milestones that way
        # — so the forms are the slug-bearing filename and the [NNNN] bracket.
        cited=no
        while IFS= read -r f; do
            grep -qE "\[$n\]|$n-[a-z0-9-]+\.md" "$f" && { cited=yes; break; }
        done < "$LIVE"
        [ "$cited" = yes ] ||
            note "accepted and implemented, but cited nowhere in the live layer: $n"
    done
fi

# ------------------------------------------------- README against commands/
# development-workflow.md claimed this check existed and it did not, in a
# document imported into every agent's context — a false coverage claim inside
# the coverage layer, which is this runner's own defect class. Written rather
# than the sentence deleted, because the claim is worth making true.
if [ "$SELFTEST" = yes ] && [ -f "$ROOT/README.md" ] && [ -d "$ROOT/commands" ]; then
    for c in "$ROOT"/commands/*.md; do
        [ -f "$c" ] || continue
        name=$(basename "$c" .md)
        grep -q "crochet:$name" "$ROOT/README.md" ||
            note "commands/$name.md has no row in README.md"
    done
    # The other direction. A skill on the internal-skills line has no stub by
    # design, so exempt only the names on that line — the guard must be about
    # the name under test. tr because the case below matches space-delimited
    # words and sort emits newlines.
    internal=$(grep -i 'internal' "$ROOT/README.md" | grep -oE 'crochet:[a-z-]+' |
               sed 's/^crochet://' | sort -u | tr '\n' ' ')
    for name in $(grep -oE 'crochet:[a-z-]+' "$ROOT/README.md" | sed 's/^crochet://' | sort -u); do
        [ -f "$ROOT/commands/$name.md" ] && continue
        case " $internal " in *" $name "*) continue ;; esac
        note "README.md names crochet:$name with no commands/$name.md"
    done
fi

# ------------------------------------------- declared floor vs installed binary
# Compares the declared floor against the installed binary. Reads $ROOT rather
# than the current directory, so the fixture can witness it.
if [ -f "$ROOT/.claude-plugin/plugin.json" ] || [ "$SELFTEST" = yes ]; then
    if [ ! -f "$ROOT/.claude-plugin/plugin.json" ]; then
        note ".claude-plugin/plugin.json is missing — nothing declares a git-zhi floor"
    else
        floor=$(sed -n 's/.*"git_zhi_min_version"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' \
                "$ROOT/.claude-plugin/plugin.json" | head -1)
        installed=$(git zhi version 2>/dev/null | head -1 | awk '{print $2}')
        # Both operands must be versions, not just non-empty: `v0.7.1` and
        # `garbage` sort above a 0.7.2 floor.
        is_version() { case "$1" in ''|*[!0-9.]*) return 1 ;; *) return 0 ;; esac; }

        if [ -z "$floor" ]; then
            note "plugin.json declares no git_zhi_min_version — preflight has no floor to enforce"
        elif ! is_version "$floor"; then
            note "git_zhi_min_version is '$floor', which is not a version — the floor cannot be compared"
        elif [ -z "$installed" ]; then
            note "could not read a version from git zhi version — the floor is unverifiable"
        elif ! is_version "$installed"; then
            note "git zhi version reported '$installed', which is not a version — the floor is unverifiable"
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
    elif [ "$(grep -cvE '^[[:space:]]*(#|$)' xt/fixture/expected)" != \
           "$(sed -n 's/^# count: *//p' xt/fixture/expected | head -1)" ]; then
        # An empty list is caught above, a shortened one was not: deleting a
        # single line disarmed one check silently, which is the cheapest
        # possible attack on this whole mechanism. The list declares its own
        # length, so removing an entry is a finding and adding one is a
        # deliberate edit in two places.
        note "xt/fixture/expected has $(grep -cvE '^[[:space:]]*(#|$)' xt/fixture/expected) entries but declares $(sed -n 's/^# count: *//p' xt/fixture/expected | head -1)"
    else
        TMP="${TMPDIR:-/tmp}/zhi-xt-self-$$"
        rm -rf "$TMP"
        mkdir -p "$TMP"
        cp -R xt/fixture "$TMP/fixture"

        # Two checks need this copy to be a git repository. `git zhi docs check`
        # reports every tree clean when it is not one, and the Implements check
        # reads commit trailers — so the trailer names 0004, which the fixture
        # keeps `proposed`, giving that check something to report.
        #
        # The trailer also names 0002, which the fixture keeps `accepted` and no
        # live document there cites: that is the backstop's subject. And HEAD is
        # written into .git/shallow afterwards, so `rev-parse
        # --is-shallow-repository` reports true here and false in a real
        # checkout — the red-in-the-fixture, green-in-the-repository pairing
        # development-workflow.md asks every check to have.
        ( cd "$TMP/fixture" && git init -q . &&
          git -c user.email=xt@fixture -c user.name=xt add -A &&
          git -c user.email=xt@fixture -c user.name=xt commit -qm "fixture

Implements: 0004
Implements: 0002" &&
          git rev-parse HEAD > .git/shallow
        ) >/dev/null 2>&1 || note "the self-test could not build its fixture repository"

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
