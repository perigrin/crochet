#!/bin/sh
# ABOUTME: Asserts the installed git-zhi honours ZHI_ACTOR and excludes held work.
# ABOUTME: This is the floor skills/execute/execute.md selects against.
#
#   sh xt/zhi-actor-probe.sh
#
# Four assertions against a scratch repository, not against a version string.
# A version is what the binary calls itself; these are what it does.
#
#   1  a declared identity is recorded on the write path
#   2  a bare value is refused rather than defaulted to human
#   3  nothing declared behaves exactly as it did before ZHI_ACTOR existed
#   4  next does not hand out an issue whose blocker another worker holds
#
# 3 is the one that must pass rather than fail. A probe made only of "this
# should error" cannot tell a real refusal from a missing binary -- every
# assertion would go green on a tool that is not there. 3 goes red instead,
# which is what makes the other three trustworthy.
#
# Assertions read the recorded actor or the failure text, never a bare exit
# code: `git zhi next` exits 0 on "no actionable issues", so an exit code here
# would confirm nothing.

fail=0
note() { echo "FAIL: $*" >&2; fail=$((fail + 1)); }

command -v git-zhi >/dev/null 2>&1 || { echo "FAIL: git-zhi is not on PATH" >&2; exit 1; }
echo "probing: $(git zhi version | head -1)"

WORK="${TMPDIR:-/tmp}/zhi-actor-probe-$$"
cleanup() { cd / || exit; rm -rf "$WORK"; }
trap cleanup EXIT INT TERM

mk() {
    d="$WORK/$1"
    mkdir -p "$d" && cd "$d" || exit 1
    git init -q .
    git config user.email probe@example.com
    git config user.name Probe
    git commit -q --allow-empty -m init
}

# First issue id in a repository, whichever shape the JSON takes.
first_id() {
    git zhi list --format json | python3 -c '
import json, sys
d = json.load(sys.stdin)
print((d if isinstance(d, list) else d["issues"])[0]["id"])'
}

last_actor() {
    git zhi issue show "$1" --format json | python3 -c '
import json, sys
t = json.load(sys.stdin).get("transitions") or []
print(t[-1]["actor"] if t else "")'
}

add() { git zhi issue add "$1" --body b >/dev/null 2>&1; }

# -- 1: a declared identity reaches the transition log ----------------------
mk declared
add One
ID=$(first_id)
ZHI_ACTOR=agent:probe-1 git zhi issue edit "$ID" --state start >/dev/null 2>&1
GOT=$(last_actor "$ID")
[ "$GOT" = "agent:probe-1" ] || note "declared identity not recorded: got '$GOT', want 'agent:probe-1'"

# -- 2: a value with no type is refused, not defaulted ---------------------
mk bare
add Two
ID=$(first_id)
OUT=$(ZHI_ACTOR=probe git zhi issue edit "$ID" --state start 2>&1)
GOT=$(last_actor "$ID")
if [ -n "$GOT" ]; then
    note "bare ZHI_ACTOR was accepted and recorded '$GOT' -- an agent stored as a human"
elif ! printf '%s' "$OUT" | grep -qi 'actor\|agent:\|human:'; then
    note "bare ZHI_ACTOR was refused, but not for naming its type: $OUT"
fi

# -- 3: nothing declared is unchanged (the assertion that must pass) -------
mk underived
add Three
ID=$(first_id)
git zhi issue edit "$ID" --state start >/dev/null 2>&1
GOT=$(last_actor "$ID")
case "$GOT" in
    "")       note "no transition recorded with nothing declared -- is git-zhi working at all?" ;;
    human:*)  : ;;   # derived from the user.name/user.email set above
    *)        note "with nothing declared the actor was '$GOT', not a git-author derivation" ;;
esac

# -- 4: a blocker held by another worker still blocks ----------------------
# Without this, bare `next` hands a worker an issue whose dependency is
# unfinished in someone else's hands, and execute.md's selection is wrong.
mk excluded
add Upstream
UP=$(first_id)
git zhi issue add Downstream --body b >/dev/null 2>&1
DOWN=$(git zhi list --format json | python3 -c '
import json, sys
d = json.load(sys.stdin)
issues = d if isinstance(d, list) else d["issues"]
print([i for i in issues if i["title"] == "Downstream"][0]["id"])')
git zhi issue edit "$DOWN" --after "$UP" >/dev/null 2>&1
ZHI_ACTOR=agent:holder git zhi issue edit "$UP" --state start >/dev/null 2>&1
OUT=$(ZHI_ACTOR=agent:other git zhi next 2>&1)
if printf '%s' "$OUT" | grep -q "$(printf '%s' "$DOWN" | cut -c1-18)"; then
    note "next handed out an issue whose blocker is held by another worker"
elif ! printf '%s' "$OUT" | grep -q 'no actionable issues'; then
    note "next neither refused nor explained itself: $OUT"
fi

if [ "$fail" -gt 0 ]; then
    echo "$fail assertion(s) failed -- git-zhi 0.6.0 or later is required" >&2
    exit 1
fi

echo "ok: git-zhi honours ZHI_ACTOR and excludes work held by other workers"
exit 0
