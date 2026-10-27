#!/bin/sh
# ABOUTME: Product check — drives execute's selection protocol (R1-R3) against real git-zhi.
# ABOUTME: Scratch chain; the orchestrator assigns each pick, workers confirm, start, check.
#
# Usage: sh t/execute-selection-walkthrough.sh [selection|control]
#
# Every verdict below is computed from the scratch chain and from the records
# the simulated workers write, and names the scratch issues it judged. A line
# that says `ok` without one of those behind it would be a verdict, not a check.
# The protocol modelled is skills/execute/execute.md Step 2: the pick, the
# hand-over, the ownership check, and what the orchestrator does on a return.
#
# The refusal cases follow the selection cases, each judged by its own verdict.
#
# `control` runs the same setup and cases with R1-R3 removed: no assignment,
# bare `next`, whatever it returns started, no ownership check, no give-back.
# It exits 0 only if that run fails a selection verdict for the expected
# reason and the setup precondition passed, so a broken setup or binary cannot
# pass as the protocol's absence.
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
    selection) PROTO=1 ;;
    control) PROTO=0 ;;
    *) echo "not ok - unknown mode '$MODE' (known: selection, control)"; exit 2 ;;
esac
# The binary a case's shim wraps: whatever git-zhi is first on $PATH now.
WALK_REAL=$(command -v git-zhi); export WALK_REAL

# ------------------------------------------------------------ scratch space
TMP=$(mktemp -d "${TMPDIR:-/tmp}/zhi-walk.XXXXXX") || { echo "not ok - mktemp failed"; exit 1; }
mkdir -p "$TMP/rec" "$TMP/wt" "$TMP/pid" "$TMP/mark" "$TMP/shim"
WALK_TMP=$TMP; export WALK_TMP
: > "$TMP/returns"; : > "$TMP/dispatch"; : > "$TMP/seen"
: > "$TMP/report"; : > "$TMP/cases"; : > "$TMP/fails"

kill_tree() {  # pid...; roots first, so no killed parent forks again
    _all=$(ps -A -o pid= -o ppid=) _tree="$*" _front="$*"
    while [ -n "$_front" ]; do
        _front=$(printf '%s\n' "$_all" | awk -v f=" $_front " 'index(f, " " $2 " ") {print $1}' | tr '\n' ' ')
        _tree="$_tree $_front"
    done
    kill $_tree 2>/dev/null
    _i=0   # give the tree up to five seconds to go before its directories are removed
    while [ $_i -lt 5 ] && kill -0 $_tree 2>/dev/null; do _i=$((_i + 1)); sleep 1; done
}

cleanup() {
    trap - EXIT HUP INT PIPE TERM
    # Each worker's whole process tree, not only the subshell `$!` names: its
    # inner subshell and git zhi children outlive a TERM to the parent, and
    # could still write to a WALKTHROUGH_KEEP repository.
    # Only live workers: a reaped worker's pid file is gone, so a reused pid is never hit.
    _live=$(cat "$TMP"/pid/* 2>/dev/null)
    [ -n "$_live" ] && kill_tree $_live
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

PRE_OK=0 EXPECTED=0   # control's two conditions: setup precondition, expected failure
pass() { echo "ok - $*"; }
fail() {
    echo "not ok - $*"; echo x >> "$TMP/fails"
    case "$*" in *"two workers"*|*"outside the milestone"*|*"assigned to it"*) EXPECTED=1 ;; esac
}

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
        # A refusal case may put a shim before git-zhi, for this case's workers only.
        [ -d "$TMP/shim/$_c" ] && PATH="$TMP/shim/$_c:$PATH"
        # For the overlap check: which peers had already finished starting.
        echo "saw-ended $(ls "$_mk" 2>/dev/null | sed -n 's/^ended\.//p' | tr '\n' ' ')"

        _got=$(ZHI_ACTOR="$_tok" git zhi next --format json 2>"$_rec.err" | jq -r '.id // empty' 2>/dev/null)
        echo "next ${_got:-none}"
        [ "$PROTO" = 0 ] && [ -n "$_got" ] && _id=$_got   # control: start whatever next returned
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
        [ "$PROTO" = 0 ] && _own=owned _i=3   # control: no ownership check
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
    [ "$PROTO" = 1 ] && [ "$_asg" = "$_tok" ] && retry git zhi issue edit "$_id" --unassign >/dev/null
    case "$_st" in
        pending|reopened) HELD=1; echo "$_id $(sed -n 's/^reason //p' "$_rec")" > "$TMP/held.$1" ;;
        *) HELD=0 ;;
    esac
}

# ------------------------------------------------------------ one run
run_case() {  # case milestone path(parallel|one) max_workers [token, reused for every pick]
    _c=$1 _m=$2 _path=$3 _max=$4 _fixed=${5:-}
    echo "$_c $_m" >> "$TMP/cases"; mkdir -p "$TMP/mark/$_c"
    LIVE=0 HELD=0 _handled=$(wc -l < "$TMP/returns")
    while :; do
        # Pick for every free slot first, then launch the workers together.
        _batch=""
        while [ "$HELD" = 0 ] && [ $((LIVE + $(echo $_batch | wc -w))) -lt "$_max" ]; do
            # A loop guard, so a run that never ends fails here instead of hanging.
            if [ "$(awk -v c="$_c" '$1 == c' "$TMP/dispatch" | wc -l)" -ge 12 ]; then
                fail "case $_c reached 12 dispatches — the run loops"; break
            fi
            _id=$(pick "$_c" "$_m") || break
            [ -n "$_id" ] || break
            N=$((N + 1)); _tok=${_fixed:-"agent:$RUN-$N"}
            if [ "$PROTO" = 1 ]; then   # R1: the assign step; control has none
                retry git zhi issue edit "$_id" --assign "$_tok" >/dev/null || break
            fi
            git worktree add -q --detach "$TMP/wt/$N" 2>/dev/null
            echo "$_c $_tok $_id $N $(wc -l < "$TMP/returns")" >> "$TMP/dispatch"  # last: returns so far
            _batch="$_batch $N:$_tok:$_id"
        done
        for _w in $_batch; do
            _n=${_w%%:*}; _rest=${_w#*:}; _id=${_rest##*:}; _tok=${_rest%:*}
            if [ "$_path" = parallel ]; then
                ( worker "$_c" "$_n" "$_tok" "$_id" ) &
                echo $! > "$TMP/pid/$_n"; LIVE=$((LIVE + 1))
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
        wait "$(cat "$TMP/pid/$_n")" 2>/dev/null; rm -f "$TMP/pid/$_n"
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
    PRE_OK=1
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

# Progress is judged per issue: a worker that rightly stood down (a refused or
# flaked start) fails nothing if its issue was re-dispatched and worked. An
# issue dispatched and never worked by anyone fails, so a run that only stands
# down is not a pass.
idle=""; downs=""
for id in $(awk '{print $3}' "$TMP/dispatch" | sort -u); do
    cat "$TMP"/rec/[0-9]* 2>/dev/null | grep -qx "worked $id" || idle="$idle $id"
done
while read -r c tok id n _r; do
    grep -q '^outcome worked' "$TMP/rec/$n" 2>/dev/null ||
        downs="$downs $tok($id: $(sed -n 's/^reason //p' "$TMP/rec/$n" 2>/dev/null))"
done < "$TMP/dispatch"
[ -n "$downs" ] && echo "# stand-downs:$downs"
if [ -z "$idle" ] && [ -n "$all_ids" ]; then
    pass "every dispatched worker in the selection cases worked an issue: each of $(awk '{print $3}' "$TMP/dispatch" | sort -u | tr '\n' ' ')worked by some worker"
else
    fail "every dispatched worker in the selection cases worked an issue: dispatched, never worked:${idle:- no dispatch}"
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

# ============================================================ refusal cases
# Each case below has its own milestone and its own verdict, read back from the
# workers' records and the scratch chain. They run after the selection verdicts,
# so a case that is meant to end with work undone cannot pass those vacuously.

mkshim() {  # case; the shim's body on stdin. Only that case's workers see it.
    mkdir -p "$TMP/shim/$1"
    { echo '#!/bin/sh'; cat; } > "$TMP/shim/$1/git-zhi" && chmod +x "$TMP/shim/$1/git-zhi"
}
show() { retry git zhi issue show "$1" --format json; }
recs() { awk -v c="$1" -v i="$2" '$1 == c && $3 == i {print $4}' "$TMP/dispatch" | tr '\n' ' '; }
ndisp() { awk -v c="$1" '$1 == c' "$TMP/dispatch" | wc -l | tr -d ' '; }
r_get() { sed -n "s/^$2 //p" "$TMP/rec/$1" 2>/dev/null | head -1; }   # record key
reported() { awk -v c="$1" -v i="$2" '$1 == c && $2 == i {f = 1} END {exit !f}' "$TMP/report"; }
ntr() { printf '%s' "$1" | jq -r '(.transitions // []) | length'; }
last_actor() { printf '%s' "$1" | jq -r '(.transitions // [])[-1].actor // empty'; }
J() { printf '%s' "$1" | jq -r "$2"; }

# ------------------------------------------------------------ case: lost start
# Another actor takes the issue between the worker's start and its ownership
# check. The worker must stand down; the orchestrator must leave the issue in
# progress under the other actor, its assignment untouched, and not re-dispatch.
git zhi milestone add lost >/dev/null
L1=$(add_issue lost lost-1)
mkshim lost <<'SHIM'
"$WALK_REAL" "$@"; rc=$?
if [ $rc = 0 ] && [ "$1 $2 $4 $5" = "issue edit --state start" ]; then
    ZHI_ACTOR=human:carol "$WALK_REAL" issue edit "$3" --state pause >/dev/null 2>&1 &&
        ZHI_ACTOR=human:carol "$WALK_REAL" issue edit "$3" --state resume >/dev/null 2>&1
fi
exit $rc
SHIM
run_case lost lost parallel 1
set -- $(recs lost "$L1"); j=$(show "$L1")
tok=$(r_get "${1:-x}" token)
if [ $# = 1 ] && [ "$(r_get "$1" outcome)" = stood-down ] &&
   r_get "$1" reason | grep -q '^lost to human:carol (in-progress)' &&
   ! grep -q '^worked' "$TMP/rec/$1" && [ "$(J "$j" .state)" = in-progress ] &&
   [ "$(last_actor "$j")" = human:carol ] && [ "$(J "$j" '.assigned // empty')" = "$tok" ]; then
    pass "lost start stands down only: $tok stood down on $L1, which stays in-progress under human:carol, still assigned $tok, dispatched once"
else
    fail "lost start stands down only: $L1 dispatched to [$*] as ${tok:-?}, state $(J "$j" .state) under '$(last_actor "$j")', assigned '$(J "$j" '.assigned // empty')'"
fi
retry env ZHI_ACTOR=human:carol git zhi issue edit "$L1" --state cancel >/dev/null

# ------------------------------------------------------------ case: failed ownership read
# A shim fails the worker's `issue show`: once for readok, always for readdead.
# A failed read is retried and never judged; an exhausted bound reports the
# issue as ownership unknown and does not unassign it.
for c in readok readdead; do
    git zhi milestone add "$c" >/dev/null
    case $c in readok) k=1 ;; *) k=99 ;; esac
    mkshim "$c" <<SHIM
if [ "\$1 \$2" = "issue show" ]; then
    echo x >> "\$WALK_TMP/reads.$c"
    [ "\$(wc -l < "\$WALK_TMP/reads.$c")" -le $k ] && { echo "walkthrough: injected read failure" >&2; exit 1; }
fi
exec "\$WALK_REAL" "\$@"
SHIM
done
RK=$(add_issue readok readok-1); RD=$(add_issue readdead readdead-1)
run_case readok readok parallel 1
run_case readdead readdead parallel 1
set -- $(recs readok "$RK") $(recs readdead "$RD")
jd=$(show "$RD"); tk=$(r_get "${1:-x}" token); td=$(r_get "${2:-x}" token)
nk=$(wc -l < "$TMP/reads.readok" 2>/dev/null | tr -d ' '); nd=$(wc -l < "$TMP/reads.readdead" 2>/dev/null | tr -d ' ')
if [ $# = 2 ] && [ "$nk" = 2 ] && [ "$(r_get "$1" outcome)" = worked ] && [ "$(r_get "$1" worked)" = "$RK" ] &&
   [ "$nd" = 3 ] && [ "$(r_get "$2" outcome)" = unknown ] && reported readdead "$RD" &&
   [ "$(J "$jd" .state)" = in-progress ] && [ "$(last_actor "$jd")" = "$td" ] &&
   [ "$(J "$jd" '.assigned // empty')" = "$td" ]; then
    pass "failed ownership read is retried, not judged: $RK read $nk times (first failed), then owned and worked by $tk; $RD read $nd times, all failed, reported ownership unknown and still assigned $td"
else
    fail "failed ownership read is retried, not judged: $RK reads ${nk:-0} outcome '$(r_get "${1:-x}" outcome)'; $RD reads ${nd:-0} outcome '$(r_get "${2:-x}" outcome)', assigned '$(J "$jd" '.assigned // empty')'"
fi
[ -n "$td" ] && retry env ZHI_ACTOR="$td" git zhi issue edit "$RD" --state cancel >/dev/null

# ------------------------------------------------------------ case: reused token (negative control)
# A token that already worked an issue now reopened. Reused for a new pick,
# `next` returns the reopened issue instead, so the run must fail to work the
# pick: the worker stands down and the pick is given back.
git zhi milestone add reuse >/dev/null
RX=$(add_issue reuse reuse-x); RY=$(add_issue reuse reuse-y)
N=$((N + 1)); rt="agent:$RUN-$N"
git zhi issue edit "$RX" --assign "$rt" >/dev/null &&
    ZHI_ACTOR="$rt" git zhi issue edit "$RX" --state start >/dev/null &&
    git commit -q --allow-empty -m "walkthrough: $RX by $rt" &&
    ZHI_ACTOR="$rt" git zhi issue edit "$RX" --state done >/dev/null &&
    ZHI_ACTOR="$rt" git zhi issue edit "$RX" --state reopen >/dev/null
xb=$(ntr "$(show "$RX")")
run_case reuse reuse parallel 1 "$rt"
set -- $(recs reuse "$RY"); jy=$(show "$RY"); jx=$(show "$RX")
if [ $# = 1 ] && [ "$(r_get "$1" token)" = "$rt" ] && [ "$(r_get "$1" outcome)" = stood-down ] &&
   [ "$(r_get "$1" next)" = "$RX" ] && ! grep -q '^started' "$TMP/rec/$1" &&
   [ "$(ntr "$jy")" = 0 ] && [ -z "$(J "$jy" '.assigned // empty')" ] && reported reuse "$RY" &&
   [ "$(J "$jx" .state)" = reopened ] && [ "$(ntr "$jx")" = "$xb" ]; then
    pass "reused token stands down: $rt, reused for $RY, got its reopened $RX from next, started nothing, gave $RY back unworked; $RX untouched"
else
    fail "reused token stands down: $RY dispatched to [$*], next '$(r_get "${1:-x}" next)', outcome '$(r_get "${1:-x}" outcome)', $RY transitions $(ntr "$jy")"
fi

# ------------------------------------------------------------ case: self-resume
# An agent told to continue resumes the issue it holds, under that issue's
# token, before any pick. An open session takes no transition; a paused one,
# whose last session has ended_at, takes --state resume.
self_resume() {  # token id record
    {
        echo "token $1"; echo "before $(ntr "$(show "$2")")"
        _got=$(ZHI_ACTOR="$1" git zhi next --format json 2>/dev/null | jq -r '.id // empty' 2>/dev/null)
        echo "next ${_got:-none}"
        if [ "$PROTO" = 0 ]; then   # control: no self-resume rule, so it starts what next gave
            ZHI_ACTOR="$1" git zhi issue edit "${_got:-none}" --state start >/dev/null 2>&1 && echo "ran start"
        elif [ "$_got" = "$2" ]; then
            _j=$(show "$2")
            if [ "$(J "$_j" .state)" = in-progress ] && [ "$(last_actor "$_j")" = "$1" ]; then
                if [ -n "$(J "$_j" '(.sessions // [])[-1].ended_at // empty')" ]; then
                    ZHI_ACTOR="$1" git zhi issue edit "$2" --state resume >/dev/null && echo "ran resume"
                else
                    echo "ran nothing"
                fi
            fi
        fi
        _j=$(show "$2")
        echo "after $(ntr "$_j")"; echo "after-actor $(last_actor "$_j")"
        echo "after-open $(J "$_j" 'if ((.sessions // [])[-1].ended_at // "") == "" then "yes" else "no" end')"
        git commit -q --allow-empty -m "walkthrough: $2 by $1" && echo "worked $2"
        retry env ZHI_ACTOR="$1" git zhi issue edit "$2" --state done >/dev/null && echo "closed $2"
    } > "$3" 2>&1
}
git zhi milestone add resume >/dev/null
SA=$(add_issue resume resume-open); SP=$(add_issue resume resume-paused)
N=$((N + 1)); ta="agent:$RUN-$N"; N=$((N + 1)); tp="agent:$RUN-$N"
git zhi issue edit "$SA" --assign "$ta" >/dev/null && ZHI_ACTOR="$ta" git zhi issue edit "$SA" --state start >/dev/null
git zhi issue edit "$SP" --assign "$tp" >/dev/null && ZHI_ACTOR="$tp" git zhi issue edit "$SP" --state start >/dev/null &&
    ZHI_ACTOR="$tp" git zhi issue edit "$SP" --state pause >/dev/null
self_resume "$ta" "$SA" "$TMP/rec/resume.a"
self_resume "$tp" "$SP" "$TMP/rec/resume.p"
ra=$TMP/rec/resume.a rp=$TMP/rec/resume.p
ab=$(sed -n 's/^before //p' "$ra"); aa=$(sed -n 's/^after //p' "$ra")
if grep -qx 'ran nothing' "$ra" && [ -n "$ab" ] && [ "$ab" = "$aa" ] &&
   grep -qx "next $SA" "$ra" && grep -qx "closed $SA" "$ra"; then
    pass "self-resume adds no transition: $SA under $ta had $ab transitions before resuming and $aa after, then was worked and closed"
else
    fail "self-resume adds no transition: $SA under $ta: $(tr '\n' ';' < "$ra")"
fi
pb=$(sed -n 's/^before //p' "$rp"); pa=$(sed -n 's/^after //p' "$rp")
if grep -qx 'ran resume' "$rp" && [ -n "$pb" ] && [ "$pa" = $((pb + 1)) ] &&
   grep -qx "after-actor $tp" "$rp" && grep -qx 'after-open yes' "$rp" && grep -qx "closed $SP" "$rp"; then
    pass "paused self-resume runs --state resume: $SP under $tp went from $pb to $pa transitions, its session reopened, then closed"
else
    fail "paused self-resume runs --state resume: $SP under $tp: $(tr '\n' ';' < "$rp")"
fi

# ------------------------------------------------------------ the held slot
# An actor outside the run holds a wip_limit slot with an issue of its own.
git zhi milestone add hold >/dev/null
H1=$(add_issue hold hold-1); H2=$(add_issue hold hold-2)
ZHI_ACTOR=human:dave git zhi issue edit "$H1" --state start >/dev/null

# ------------------------------------------------------------ case: refused start, slot frees
# wip_limit 2, dave holds one. Two workers: the second's start is held back
# until the first's has returned, so the first takes the last slot and the
# second is refused. The run must not re-dispatch while that is held; dave
# frees his slot once the stand-down is handled, and when the live worker
# returns the refused issue is dispatched again and worked.
git zhi config wip_limit 2 >/dev/null
git zhi milestone add refuse >/dev/null
FA=$(add_issue refuse refuse-1); FB=$(add_issue refuse refuse-2)
echo "$FB" > "$TMP/delay.refuse"
mkshim refuse <<'SHIM'
if [ "$1 $2 $4 $5" = "issue edit --state start" ] && [ "$3" = "$(cat "$WALK_TMP/delay.refuse")" ]; then
    _i=0
    until ls "$WALK_TMP/mark/refuse" 2>/dev/null | grep -q '^ended\.' || [ $_i -ge 30 ]; do
        _i=$((_i + 1)); sleep 1
    done
fi
exec "$WALK_REAL" "$@"
SHIM
(
    trap - EXIT HUP INT PIPE TERM; _i=0
    until [ -f "$TMP/held.refuse" ] || [ $_i -ge 120 ]; do _i=$((_i + 1)); sleep 1; done
    [ -f "$TMP/held.refuse" ] && retry env ZHI_ACTOR=human:dave git zhi issue edit "$H1" --state cancel >/dev/null &&
        wc -l < "$TMP/dispatch" | tr -d ' ' > "$TMP/freed.refuse"
) &
echo $! > "$TMP/pid/watch"
run_case refuse refuse parallel 2
wait "$(cat "$TMP/pid/watch")" 2>/dev/null; rm -f "$TMP/pid/watch"
freed=$(cat "$TMP/freed.refuse" 2>/dev/null)
set -- $(awk -v i="$FB" '$1 == "refuse" && $3 == i {print NR ":" $4 ":" $5}' "$TMP/dispatch")
first=${1:-0:x:0} second=${2:-0:x:0}
d1=${first%%:*} n1=${first#*:}; n1=${n1%%:*}
d2=${second%%:*} n2=${second#*:}; r2=${n2#*:}; n2=${n2%%:*}
na=$(recs refuse "$FA" | awk '{print $1}')
if [ $# = 2 ] && [ -n "$freed" ] && [ "$d1" -le "$freed" ] && [ "$d2" -gt "$freed" ] &&
   [ "$(r_get "$n1" outcome)" = stood-down ] && r_get "$n1" reason | grep -q 'WIP limit reached' &&
   [ -n "$na" ] && head -n "$r2" "$TMP/returns" | grep -qx "$na"; then
    pass "refused issue not re-dispatched before slot frees: $FB refused for $(r_get "$n1" token) ($(r_get "$n1" reason | sed 's/^start refused: //')), dispatched again only at dispatch $d2, after the slot freed at $freed and $(r_get "$na" token) ($FA) returned"
else
    fail "refused issue not re-dispatched before slot frees: $FB dispatches [$*], slot freed at '${freed:-never}', first outcome '$(r_get "$n1" outcome)': $(r_get "$n1" reason)"
fi
jb=$(show "$FB")
if [ $# = 2 ] && [ "$(r_get "$n2" worked)" = "$FB" ] && [ "$(r_get "$n2" outcome)" = worked ] &&
   [ "$(J "$jb" '[(.transitions // [])[] | select(.state == "in-progress")][-1].actor // empty')" = "$(r_get "$n2" token)" ]; then
    pass "refused issue re-dispatched once the slot frees: $FB worked by $(r_get "$n2" token), whose start the chain records"
else
    fail "refused issue re-dispatched once the slot frees: $FB second dispatch '$(r_get "$n2" token)' outcome '$(r_get "$n2" outcome)'"
fi

# ------------------------------------------------------------ cases: a slot held throughout
# wip_limit 1 and dave holds it with hold-2 for the next three cases.
ZHI_ACTOR=human:dave git zhi issue edit "$H2" --state start >/dev/null
git zhi config wip_limit 1 >/dev/null

# More than one issue pooled, two workers: both are refused, nobody is live,
# and the run ends naming the whole pool with git-zhi's refusal text (R1c).
git zhi milestone add wipheld >/dev/null
W1=$(add_issue wipheld wip-1); W2=$(add_issue wipheld wip-2); W3=$(add_issue wipheld wip-3)
run_case wipheld wipheld parallel 2
set -- $(awk '$1 == "wipheld" {print $4}' "$TMP/dispatch")
downs=0; for n; do r_get "$n" reason | grep -q 'WIP limit reached' && downs=$((downs + 1)); done
named=""; for id in $W1 $W2 $W3; do reported wipheld "$id" && named="$named $id"; done
if [ $# = 2 ] && [ "$downs" = 2 ] && [ "$named" = " $W1 $W2 $W3" ]; then
    pass "held wip slot ends run naming the pool: 2 workers dispatched, both refused, no re-dispatch; the report names$named"
else
    fail "held wip slot ends run naming the pool: $# dispatches, $downs refused, reported:${named:- none} of $W1 $W2 $W3"
fi
txt=$(awk '$1 == "wipheld"' "$TMP/report" | grep -o 'WIP limit reached[^;]*' | sort -u | head -1)
lacking=""; for id in $W1 $W2 $W3; do
    awk -v i="$id" '$1 == "wipheld" && $2 == i' "$TMP/report" | grep -q 'WIP limit reached' || lacking="$lacking $id"
done
if [ -n "$txt" ] && [ -z "$lacking" ]; then
    pass "end report carries refusal text: each of $W1 $W2 $W3 reported with git-zhi's '$txt'"
else
    fail "end report carries refusal text: missing for${lacking:- all}"
fi

# The one-worker path: the agent is not live, so a refusal ends the run.
git zhi milestone add solofull >/dev/null
U1=$(add_issue solofull solofull-1); U2=$(add_issue solofull solofull-2)
run_case solofull solofull one 1
set -- $(awk '$1 == "solofull" {print $4}' "$TMP/dispatch")
if [ $# = 1 ] && [ "$(r_get "$1" outcome)" = stood-down ] && r_get "$1" reason | grep -q 'WIP limit reached' &&
   reported solofull "$U1" && reported solofull "$U2"; then
    pass "one-worker refusal ends run: $(r_get "$1" token) refused on $(r_get "$1" dispatched), the run ended after one dispatch and reported $U1 $U2"
else
    fail "one-worker refusal ends run: $# dispatches for solofull ($U1 $U2), first outcome '$(r_get "${1:-x}" outcome)'"
fi

# A human assigns the issue while the worker's start is being refused, before
# the stand-down returns. The give-back must leave that assignment.
git zhi milestone add foreign >/dev/null
G1=$(add_issue foreign foreign-1)
mkshim foreign <<'SHIM'
"$WALK_REAL" "$@"; rc=$?
if [ $rc != 0 ] && [ "$1 $2 $4 $5" = "issue edit --state start" ]; then
    "$WALK_REAL" issue edit "$3" --assign human:bob >/dev/null 2>&1
fi
exit $rc
SHIM
run_case foreign foreign parallel 1
set -- $(recs foreign "$G1"); jg=$(show "$G1")
if [ $# = 1 ] && [ "$(r_get "$1" outcome)" = stood-down ] && r_get "$1" reason | grep -q '^start refused' &&
   [ "$(J "$jg" '.assigned // empty')" = human:bob ] && [ "$(ntr "$jg")" = 0 ]; then
    pass "foreign assignment survives stand-down: human:bob assigned $G1 during $(r_get "$1" token)'s refused start, and the give-back left it"
else
    fail "foreign assignment survives stand-down: $G1 assigned '$(J "$jg" '.assigned // empty')' after [$*] stood down"
fi

git zhi config wip_limit 0 >/dev/null
retry env ZHI_ACTOR=human:dave git zhi issue edit "$H2" --state cancel >/dev/null

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

if [ "$PROTO" = 0 ]; then
    # Control inverts the verdict, and both halves are needed: a broken setup
    # fails every case too, so a failure alone would not be the protocol's absence.
    if [ "$PRE_OK" = 1 ] && [ "$EXPECTED" = 1 ]; then
        pass "control: without R1-R3 the run failed a selection verdict for the expected reason, with the setup precondition passing"
        exit 0
    fi
    echo "not ok - control: setup precondition passed=$PRE_OK, expected selection failure seen=$EXPECTED"
    exit 1
fi
[ -s "$TMP/fails" ] && exit 1
exit 0
