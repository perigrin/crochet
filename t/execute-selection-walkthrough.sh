#!/bin/sh
# ABOUTME: Product check — drives execute's selection protocol (R1-R3) against real git-zhi.
# ABOUTME: Scratch chain; the orchestrator assigns each pick, workers confirm, start, check.
#
# Usage: sh t/execute-selection-walkthrough.sh [selection]
#
# Every verdict below is computed from the scratch chain and from the records
# the simulated workers write, and names the scratch issues it judged. A line
# that says `ok` without one of those behind it would be a verdict, not a check.
# The protocol modelled is skills/execute/execute.md Step 2: the pick, the
# hand-over, the ownership check, and what the orchestrator does on a return.
#
# WALKTHROUGH_KEEP=<empty dir> keeps the scratch repository there after the run.

set -u

# Clear what a git hook exports, as xt/run.sh does, so no command here can aim
# at the developer's own refs/zhi. ZHI_ACTOR too: every actor below is explicit.
unset GIT_DIR GIT_WORK_TREE GIT_INDEX_FILE GIT_OBJECT_DIRECTORY \
      GIT_ALTERNATE_OBJECT_DIRECTORIES GIT_NAMESPACE GIT_COMMON_DIR ZHI_ACTOR

MODE="${1:-selection}"
HERE=$(cd "$(dirname "$0")/.." && pwd)
SETTLE=5   # execute.md's settle interval before every ownership re-read

for tool in git jq; do
    command -v "$tool" >/dev/null 2>&1 || { echo "not ok - $tool is not on \$PATH — the walkthrough cannot run"; exit 1; }
done
command -v git-zhi >/dev/null 2>&1 || { echo "not ok - git-zhi is not on \$PATH — the walkthrough cannot run"; exit 1; }

# ------------------------------------------------------------ version guard
# The protocol leans on behaviour observed at the declared floor (the shape of
# `issue list --ready`, `next` preferring the caller's assignment). Below it the
# walkthrough would be judging a binary the skill does not claim to support.
floor=$(sed -n 's/.*"git_zhi_min_version"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' \
        "$HERE/.claude-plugin/plugin.json" | head -1)
installed=$(git zhi version 2>/dev/null | head -1 | awk '{print $2}')
is_version() { case "$1" in ''|*[!0-9.]*) return 1 ;; *) return 0 ;; esac; }
if ! is_version "$floor"; then
    echo "not ok - plugin.json git_zhi_min_version is '$floor', not a version"; exit 1
fi
if ! is_version "$installed"; then
    echo "not ok - could not read a version from git zhi version (got '$installed'); need git_zhi_min_version $floor"; exit 1
fi
if [ "$installed" != "$floor" ] &&
   [ "$(printf '%s\n%s\n' "$installed" "$floor" | sort -V | head -1)" = "$installed" ]; then
    echo "not ok - installed git-zhi version $installed is below git_zhi_min_version $floor"; exit 1
fi

case "$MODE" in
    selection) ;;
    *) echo "not ok - unknown mode '$MODE' (known: selection)"; exit 2 ;;
esac

# ------------------------------------------------------------ scratch space
TMP=$(mktemp -d "${TMPDIR:-/tmp}/zhi-walk.XXXXXX") || { echo "not ok - mktemp failed"; exit 1; }
mkdir -p "$TMP/rec" "$TMP/wt" "$TMP/pid" "$TMP/mark"
: > "$TMP/pids"; : > "$TMP/returns"; : > "$TMP/dispatch"; : > "$TMP/seen"
: > "$TMP/report"; : > "$TMP/cases"; : > "$TMP/fails"

cleanup() {
    trap - EXIT HUP INT PIPE TERM
    # shellcheck disable=SC2046
    [ -s "$TMP/pids" ] && kill $(cat "$TMP/pids") 2>/dev/null
    wait 2>/dev/null
    [ -n "${WALKTHROUGH_KEEP:-}" ] && [ -n "${REPO:-}" ] && git -C "$REPO" worktree prune 2>/dev/null
    case "$TMP" in */zhi-walk.*) rm -rf "$TMP" ;; esac
}
trap cleanup EXIT
trap 'exit 141' PIPE
trap 'exit 130' HUP INT TERM

if [ -n "${WALKTHROUGH_KEEP:-}" ]; then
    mkdir -p "$WALKTHROUGH_KEEP" || exit 1
    if [ -n "$(ls -A "$WALKTHROUGH_KEEP")" ]; then
        echo "not ok - WALKTHROUGH_KEEP=$WALKTHROUGH_KEEP is not empty"; exit 1
    fi
    REPO=$(cd "$WALKTHROUGH_KEEP" && pwd)
else
    REPO="$TMP/repo"; mkdir -p "$REPO"
fi

pass() { echo "ok - $*"; }
fail() { echo "not ok - $*"; echo x >> "$TMP/fails"; }

# A read concurrent with a worker's write can fail on 0.7.2 with "ref file is
# empty". The orchestrator's own reads are retried; a worker's next and start
# are not, because the protocol makes any failure there a stand-down.
retry() {
    _i=0
    while [ $_i -lt 3 ]; do
        _i=$((_i + 1))
        if _out=$("$@" 2>&1); then printf '%s\n' "$_out"; return 0; fi
        sleep 1
    done
    printf '%s\n' "$_out" >&2; return 1
}

cd "$REPO" || exit 1
git init -q . && git config user.name walkthrough && git config user.email walk@example.invalid &&
    git config commit.gpgsign false && git commit -q --allow-empty -m "walkthrough root" ||
    { echo "not ok - could not create the scratch repository"; exit 1; }

RUN=$(od -An -N4 -tx1 /dev/urandom | tr -d ' \n')
N=0

add_issue() {  # milestone title [--after id]; prints the new issue's full id
    _m=$1 _t=$2; shift 2
    git zhi issue add --format json --milestone "$_m" --body "walkthrough: $_t" "$@" "$_t" |
        jq -r '.[0].id'
}
milestone_of() { git zhi issue show "$1" --format json | jq -r '.milestone // empty'; }

# The other milestone: a three-issue chain, longer than anything a case
# creates, so it holds critical_chain for the whole run and is never worked.
git zhi milestone add other >/dev/null
O1=$(add_issue other other-1); O2=$(add_issue other other-2 --after "$O1")
O3=$(add_issue other other-3 --after "$O2")

# ------------------------------------------------------------ the pick (R1)
# Pool: the milestone's ready set with no `assigned`. Order: critical_chain's
# order, then `created` ascending (fraction padded so it sorts), then UUID.
pick() {  # case milestone; prints the chosen id, or nothing when the pool is empty
    _ready=$(retry git zhi issue list --ready --milestone "$2" --format json) || return 1
    _crit=$(retry git zhi list --critical --format json) || return 1
    printf '%s\n' "$_ready" | jq -r '.[] | select(.assigned == null) | .id' |
        sed "s/^/$1 /" >> "$TMP/seen"
    jq -rn --argjson r "$_ready" --argjson c "$_crit" '
        def ts: (.created | capture("^(?<s>[^.Z]+)(\\.(?<f>[0-9]+))?Z$")) as $t
                | $t.s + (($t.f // "") + "000000000")[0:9];
        (($c.critical_chain // []) | map(.id)) as $cc
        | [ $r[] | select(.assigned == null) ]
        | sort_by([ ((. as $i | $cc | index($i.id)) // 1000000000), ts, .id ])
        | .[0].id // empty'
}

# ------------------------------------------------------------ the worker (R2, R3)
# Runs in its own worktree, sets its token on every git zhi command, and writes
# its own record: the token, the issue it was dispatched for, and what it did.
worker() {  # case n token id; always run in a subshell
    trap - EXIT HUP INT PIPE TERM
    _c=$1 _n=$2 _tok=$3 _id=$4 _rec="$TMP/rec/$2" _mk="$TMP/mark/$1"
    (
        echo "token $_tok"; echo "case $_c"; echo "dispatched $_id"
        cd "$TMP/wt/$_n" || { echo "outcome stood-down"; echo "reason no worktree"; exit 0; }
        # For the overlap check: which peers had already finished starting.
        echo "saw-ended $(ls "$_mk" 2>/dev/null | sed -n 's/^ended\.//p' | tr '\n' ' ')"

        _got=$(ZHI_ACTOR="$_tok" git zhi next --format json 2>"$_rec.err" | jq -r '.id // empty' 2>/dev/null)
        echo "next ${_got:-none}"
        if [ "$_got" != "$_id" ]; then   # R2: the hand-over is exactly the pick, or nothing
            : > "$_mk/ended.$_n"
            echo "outcome stood-down"; echo "reason next returned ${_got:-nothing}: $(head -1 "$_rec.err")"
            exit 0
        fi
        if ! ZHI_ACTOR="$_tok" git zhi issue edit "$_id" --state start >/dev/null 2>"$_rec.err"; then
            : > "$_mk/ended.$_n"
            echo "outcome stood-down"; echo "reason start refused: $(head -1 "$_rec.err")"
            exit 0
        fi
        : > "$_mk/ended.$_n"
        echo "started $_id"

        _own=unknown _i=0      # R3: settle, re-read, at most three reads
        while [ $_i -lt 3 ]; do
            _i=$((_i + 1)); sleep "$SETTLE"
            _j=$(ZHI_ACTOR="$_tok" git zhi issue show "$_id" --format json 2>/dev/null) || continue
            [ "$(printf '%s' "$_j" | jq -r '.id // empty' 2>/dev/null)" = "$_id" ] || continue
            _st=$(printf '%s' "$_j" | jq -r '.state')
            _act=$(printf '%s' "$_j" | jq -r '(.transitions // [])[-1].actor // empty')
            if [ "$_st" = in-progress ] && [ "$_act" = "$_tok" ]; then _own=owned
            else _own="lost to ${_act:-nobody} ($_st)"; fi
            break
        done
        case "$_own" in
            owned) ;;
            unknown) echo "outcome unknown"; echo "reason ownership of $_id unknown after 3 reads"; exit 0 ;;
            *) echo "outcome stood-down"; echo "reason $_own"; exit 0 ;;
        esac

        # The work itself, then the close (lifecycle, which is #27's, so the
        # close is retried rather than modelled).
        git commit -q --allow-empty -m "walkthrough: $_id by $_tok" && echo "worked $_id"
        if retry env ZHI_ACTOR="$_tok" git zhi issue edit "$_id" --state done >/dev/null 2>&1; then
            echo "closed $_id"
        fi
        echo "outcome worked"
    ) > "$_rec" 2>>"$_rec.err"
    echo "$_n" >> "$TMP/returns"  # the return the orchestrator waits on
}

# ------------------------------------------------------------ after a return
# Sets HELD=1 when a stand-down leaves its issue pending or reopened.
on_return() {  # case n
    _rec="$TMP/rec/$2"
    _out=$(sed -n 's/^outcome //p' "$_rec"); _tok=$(sed -n 's/^token //p' "$_rec")
    _id=$(sed -n 's/^dispatched //p' "$_rec")
    case "$_out" in
        worked) HELD=0; return ;;
        stood-down) ;;
        *) echo "$1 $_id ownership unknown for $_tok" >> "$TMP/report"; HELD=0; return ;;
    esac
    _j=$(retry git zhi issue show "$_id" --format json) || return
    _st=$(printf '%s' "$_j" | jq -r '.state')
    _act=$(printf '%s' "$_j" | jq -r '(.transitions // [])[-1].actor // empty')
    _asg=$(printf '%s' "$_j" | jq -r '.assigned // empty')
    if [ "$_st" = in-progress ] && [ "$_act" != "$_tok" ]; then
        HELD=0; return          # a lost start: left alone, #27's
    fi
    [ "$_asg" = "$_tok" ] && retry git zhi issue edit "$_id" --unassign >/dev/null
    case "$_st" in
        pending|reopened) HELD=1; echo "$_id $(sed -n 's/^reason //p' "$_rec")" > "$TMP/held.$1" ;;
        *) HELD=0 ;;
    esac
}

# ------------------------------------------------------------ one run
run_case() {  # case milestone path(parallel|one) max_workers
    _c=$1 _m=$2 _path=$3 _max=$4
    echo "$_c $_m" >> "$TMP/cases"; mkdir -p "$TMP/mark/$_c"
    LIVE=0 HELD=0 _handled=$(wc -l < "$TMP/returns")
    while :; do
        # Pick for every free slot first, then launch the workers together.
        _batch=""
        while [ "$HELD" = 0 ] && [ $((LIVE + $(echo $_batch | wc -w))) -lt "$_max" ]; do
            _id=$(pick "$_c" "$_m") || break
            [ -n "$_id" ] || break
            N=$((N + 1)); _tok="agent:$RUN-$N"
            retry git zhi issue edit "$_id" --assign "$_tok" >/dev/null || break  # R1: the assign step
            git worktree add -q --detach "$TMP/wt/$N" 2>/dev/null
            echo "$_c $_tok $_id $N $(wc -l < "$TMP/returns")" >> "$TMP/dispatch"  # last: returns so far
            _batch="$_batch $N:$_tok:$_id"
        done
        for _w in $_batch; do
            _n=${_w%%:*}; _rest=${_w#*:}; _id=${_rest##*:}; _tok=${_rest%:*}
            if [ "$_path" = parallel ]; then
                ( worker "$_c" "$_n" "$_tok" "$_id" ) &
                echo $! > "$TMP/pid/$_n"; echo $! >> "$TMP/pids"; LIVE=$((LIVE + 1))
            else
                # One worker: the agent is its own worker and does not count as live.
                ( worker "$_c" "$_n" "$_tok" "$_id" ); _handled=$((_handled + 1))
                on_return "$_c" "$_n"
            fi
        done
        if [ "$_path" = one ]; then
            { [ -z "$_batch" ] || [ "$HELD" = 1 ]; } && break
            continue
        fi
        [ "$LIVE" -eq 0 ] && break
        # Wait for the next return, whichever worker it is.
        until [ "$(wc -l < "$TMP/returns")" -gt "$_handled" ]; do sleep 1; done
        _handled=$((_handled + 1)); _n=$(sed -n "${_handled}p" "$TMP/returns")
        wait "$(cat "$TMP/pid/$_n")" 2>/dev/null
        LIVE=$((LIVE - 1))
        on_return "$_c" "$_n"
        [ "$HELD" = 1 ] && [ "$LIVE" -eq 0 ] && break
    done
    # End of run: name what is left in the pool, with the refusal if one held it.
    _left=$(retry git zhi issue list --ready --milestone "$_m" --format json |
            jq -r '.[] | select(.assigned == null) | .id')
    for _id in $_left; do
        _why="still in the pool"
        [ -f "$TMP/held.$_c" ] && _why="$_why; held: $(cat "$TMP/held.$_c")"
        echo "$_c $_id $_why" >> "$TMP/report"
        echo "# report [$_c]: $_id $_why"
    done
}

ids_of() { awk -v c="$1" '$1 == c {print $3}' "$TMP/dispatch" | tr '\n' ' '; }

# ------------------------------------------------------------ case: off-milestone
# The other milestone leads critical_chain, so an unassigned bare `next` leaves
# the case's milestone. Asserted first, so the case cannot pass vacuously.
git zhi milestone add off >/dev/null
OFF1=$(add_issue off off-1)
lead=$(git zhi list --critical --format json | jq -r '(.critical_chain // [])[0].id // empty')
bare=$(ZHI_ACTOR="agent:$RUN-probe" git zhi next --format json | jq -r '.id // empty')
if [ -n "$lead" ] && [ "$(milestone_of "$lead")" = other ] &&
   [ -n "$bare" ] && [ "$(milestone_of "$bare")" != off ]; then
    pass "other milestone leads critical_chain: $lead (other), and unassigned bare next returns $bare, not off's $OFF1"
else
    fail "other milestone leads critical_chain: lead '${lead:-none}', unassigned next '${bare:-none}'"
fi
run_case off off parallel 2
echo "# case off-milestone: dispatched $(ids_of off)"

# ------------------------------------------------------------ case: concurrent
# Two workers launched together, plus an issue a human assigned before the run.
git zhi milestone add pair >/dev/null
P1=$(add_issue pair pair-1); P2=$(add_issue pair pair-2); PH=$(add_issue pair pair-human)
git zhi issue edit "$PH" --assign human:alice >/dev/null
run_case pair pair parallel 2
echo "# case concurrent: dispatched $(ids_of pair)"

set -- $(awk '$1 == "pair" {print $4}' "$TMP/dispatch")
if [ $# -ge 2 ]; then
    a=$1 b=$2
    ta=$(sed -n 's/^token //p' "$TMP/rec/$a"); tb=$(sed -n 's/^token //p' "$TMP/rec/$b")
    ia=$(sed -n 's/^dispatched //p' "$TMP/rec/$a"); ib=$(sed -n 's/^dispatched //p' "$TMP/rec/$b")
    if grep -q "^saw-ended.* $b " "$TMP/rec/$a" || grep -q "^saw-ended.* $a " "$TMP/rec/$b" ||
       ! grep -q '^saw-ended' "$TMP/rec/$a" || ! grep -q '^saw-ended' "$TMP/rec/$b"; then
        fail "concurrent workers overlapped: $ta ($ia) and $tb ($ib) ran one after the other"
    else
        pass "concurrent workers overlapped: $ta ($ia) and $tb ($ib) each began before the other finished starting"
    fi
else
    fail "concurrent workers overlapped: fewer than two workers dispatched for pair ($P1 $P2)"
fi

# ------------------------------------------------------------ case: more issues than workers
# Three issues, two workers: the third is dispatched only after a return (R1a).
git zhi milestone add many >/dev/null
for t in many-1 many-2 many-3; do add_issue many "$t" >/dev/null; done
run_case many many parallel 2
echo "# case more-issues-than-workers: dispatched $(ids_of many)"
# The third dispatch must follow a return from one of the first two workers.
pair_n=$(awk '$1 == "many" {print $4}' "$TMP/dispatch" | head -2)
set -- $(awk '$1 == "many"' "$TMP/dispatch" | sed -n 3p)
if [ $# -ge 5 ] && [ -n "$pair_n" ] &&
   head -n "$5" "$TMP/returns" | grep -Fxq "$pair_n"; then
    pass "more issues than workers: $3 dispatched to $2 only after a first-pair worker returned ($(ids_of many))"
else
    fail "more issues than workers: no dispatch after a return for many ($(ids_of many))"
fi

# ------------------------------------------------------------ case: one worker
git zhi milestone add solo >/dev/null
for t in solo-1 solo-2; do add_issue solo "$t" >/dev/null; done
run_case solo solo one 1
echo "# case one-worker: dispatched $(ids_of solo)"

# ------------------------------------------------------------ verdicts
# Judged across every selection case, from the workers' own records and the
# scratch chain. Each line names the issues it judged.
all_ids=$(awk '{print $3}' "$TMP/dispatch" | tr '\n' ' ')

bad=""; started=""
for r in "$TMP"/rec/*; do
    case "$r" in *.err) continue ;; esac
    s=$(sed -n 's/^started //p' "$r"); [ -n "$s" ] || continue
    c=$(sed -n 's/^case //p' "$r"); m=$(awk -v c="$c" '$1 == c {print $2}' "$TMP/cases")
    started="$started $s"
    [ "$(milestone_of "$s")" = "$m" ] || bad="$bad $s(case $c)"
done
otr=$(git zhi issue list --all --format json |
      jq -r '[.[] | select(.milestone == "other") | (.transitions // []) | length] | add')
if [ -z "$bad" ] && [ -n "$started" ] && [ "$otr" = 0 ]; then
    pass "no worker started an issue outside the milestone: started$started; other's $O1 $O2 $O3 untouched"
else
    fail "no worker started an issue outside the milestone: off-milestone starts:${bad:- none}; other milestone transitions: $otr"
fi

dup=$(cat "$TMP"/rec/[0-9]* 2>/dev/null | awk '$1 == "token" {t = $2} $1 == "worked" {w[$2] = w[$2] " " t; n[$2]++}
      END {for (i in n) if (n[i] > 1) print i ":" w[i]}' | tr '\n' ' ')
worked=$(cat "$TMP"/rec/[0-9]* 2>/dev/null | awk '$1 == "worked" {print $2}' | sort | tr '\n' ' ')
if [ -z "$dup" ] && [ -n "$worked" ]; then
    pass "no issue carries work from two workers: each of $worked worked by one token, per the workers' records"
else
    fail "no issue carries work from two workers: ${dup:-nothing worked}"
fi

mism=""; okw=""
while read -r c tok id n _r; do
    w=$(sed -n 's/^worked //p' "$TMP/rec/$n" 2>/dev/null)
    [ -n "$w" ] || continue
    j=$(git zhi issue show "$w" --format json)
    act=$(printf '%s' "$j" | jq -r '[(.transitions // [])[] | select(.state == "in-progress")][-1].actor // empty')
    asg=$(printf '%s' "$j" | jq -r '.assigned // empty')
    if [ "$w" = "$id" ] && [ "$act" = "$tok" ] && [ "$asg" = "$tok" ]; then okw="$okw $id"
    else mism="$mism $tok:assigned=$id,worked=$w,start-actor=$act"; fi
done < "$TMP/dispatch"
if [ -z "$mism" ] && [ -n "$okw" ]; then
    pass "each worker worked the issue assigned to it:$okw"
else
    fail "each worker worked the issue assigned to it:${mism:- nothing worked}"
fi

idle=""
while read -r c tok id n _r; do
    grep -q '^outcome worked' "$TMP/rec/$n" 2>/dev/null ||
        idle="$idle $tok($id: $(sed -n 's/^reason //p' "$TMP/rec/$n" 2>/dev/null))"
done < "$TMP/dispatch"
if [ -z "$idle" ] && [ -n "$all_ids" ]; then
    pass "every dispatched worker in the selection cases worked an issue: $all_ids"
else
    fail "every dispatched worker in the selection cases worked an issue: stood down or unknown:${idle:- no dispatch}"
fi

missed=""
sort -u "$TMP/seen" > "$TMP/seen.u"
while read -r c id; do
    awk -v c="$c" -v i="$id" '$1 == c && $3 == i {f = 1} END {exit !f}' "$TMP/dispatch" && continue
    awk -v c="$c" -v i="$id" '$1 == c && $2 == i {f = 1} END {exit !f}' "$TMP/report" && continue
    missed="$missed $id(case $c)"
done < "$TMP/seen.u"
if [ -z "$missed" ] && [ -s "$TMP/seen.u" ]; then
    pass "every ready unassigned issue dispatched or reported: $(awk '{print $2}' "$TMP/seen.u" | sort -u | tr '\n' ' ')"
else
    fail "every ready unassigned issue dispatched or reported: missed${missed:- (no pool observed)}"
fi

# Judged last, so no later case can have touched it unnoticed.
hj=$(git zhi issue show "$PH" --format json)
h_asg=$(printf '%s' "$hj" | jq -r '.assigned // empty')
h_tr=$(printf '%s' "$hj" | jq -r '(.transitions // []) | length')
if [ "$h_asg" = human:alice ] && [ "$h_tr" = 0 ] &&
   ! grep -q " $PH" "$TMP/dispatch" "$TMP/report" "$TMP/seen"; then
    pass "human-assigned issue left alone: $PH still human:alice, no transitions, never pooled, dispatched or reported"
else
    fail "human-assigned issue left alone: $PH assigned '$h_asg', $h_tr transitions, or it was pooled/dispatched/reported"
fi

[ -s "$TMP/fails" ] && exit 1
exit 0
