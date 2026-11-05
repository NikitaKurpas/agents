#!/bin/sh
# oh-my-zsh "apple"-style prompt (~/cwd/ branch) plus session info.
# Input schema: https://code.claude.com/docs/en/statusline.md
# Needs bash (macOS /bin/sh is bash 3.2). Costs two execs per run: one jq, one git.
LC_ALL=en_US.UTF-8  # so ${#plain} counts characters, not bytes
IFS= read -rd '' input
printf -v e '\033'; R="${e}[0m"
printf -v bicon '\356\202\240'  # U+E0A0, the powerline/Nerd Font branch glyph
printf -v clock '\357\200\227'  # U+F017, the Nerd Font clock

# All input fields in one jq call. Times use jq's own clock, so no `date`.
eval "$(jq -r '
  def n: if . == null then "" else . end;
  now as $t |
  @sh "dir=\(.workspace.current_dir // .cwd | n)
model=\(.model.display_name | n)
effort=\(.effort.level | n)
ctx=\(.context_window.used_percentage | if . == null then "" else round end)
used5=\(.rate_limits.five_hour.used_percentage | if . == null then "" else round end)
reset5=\(.rate_limits.five_hour.resets_at | if . == null or . <= $t then "" else (. - $t | floor) end)
used7=\(.rate_limits.seven_day.used_percentage | if . != null and . >= 80 then round else "" end)
cost=\(.cost.total_cost_usd | if . == null then "" else (. * 100 | round / 100 | tostring) end)
pr=\(.pr.number | n)
prstate=\(.pr.review_state | n)
cache=\(.prompt_cache | if . == null or .caching_observed != true then "" elif .warm == true and (.expires_at // 0) > $t then "warm" else "cold" end)
cacheleft=\(.prompt_cache.expires_at | if . == null or . <= $t then "" else (. - $t | floor) end)"
' <<<"$input")"

# Both set a global instead of printing, to avoid a subshell per call.
# heat: ANSI color for a percent used (green, yellow from 50, red from 80) -> $H
heat() { if [ "$1" -ge 80 ]; then H=31; elif [ "$1" -ge 50 ]; then H=33; else H=32; fi; }
# dur: seconds -> 2h14m / 37m / <1m -> $D
dur() { if [ "$1" -ge 3600 ]; then D="$(($1 / 3600))h$(($1 % 3600 / 60))m"; elif [ "$1" -ge 60 ]; then D="$(($1 / 60))m"; else D='<1m'; fi; }

# --- folder, branch, PR: $lead is colored, $leadp is the same text uncolored ---
[ -n "$dir" ] || dir=$PWD
case "$dir" in
  "$HOME") full='~' ;;
  "$HOME"/*) full="~${dir#"$HOME"}" ;;
  *) full=$dir ;;
esac
full="${full%/}/"
short=${dir%/}; short=${short##*/}; [ -n "$short" ] || short=/
[ "$dir" = "$HOME" ] && short='~'
lead=; leadp=

# One git call for branch + dirty state; -uno ignores untracked files.
# --no-optional-locks: don't contend with the user's own git commands.
if st=$(git --no-optional-locks -C "$dir" status --porcelain=v2 --branch -uno 2>/dev/null); then
  branch=; oid=; staged=; unstaged=
  while read -r f1 f2 f3; do
    case $f1 in
      '#') [ "$f2" = branch.head ] && branch=$f3; [ "$f2" = branch.oid ] && oid=$f3 ;;
      1 | 2 | u) [ "${f2%?}" != . ] && staged=1; [ "${f2#?}" != . ] && unstaged=1 ;;
    esac
  done <<EOF
$st
EOF
  [ "$branch" = '(detached)' ] && branch=${oid:0:7}
  lead="$lead ${e}[32m${bicon} ${branch}"; leadp="$leadp ${bicon} ${branch}"
  [ -n "$staged" ] && { lead="$lead${e}[33m+"; leadp="$leadp+"; }
  [ -n "$unstaged" ] && { lead="$lead${e}[31m*"; leadp="$leadp*"; }
  lead="$lead${R}"
fi
if [ -n "$pr" ]; then
  case $prstate in
    approved) pc=32 ;; pending) pc=33 ;; changes_requested) pc=31 ;; draft) pc=2 ;; *) pc=36 ;;
  esac
  lead="$lead ${e}[${pc}m#${pr}${R}"; leadp="$leadp #$pr"
fi

# Context bar, plus the prompt-cache state: warm keeps the usage color,
# cold turns the whole context group gray. No cache data: usage color only.
bar=; ctxcolor=; cachetxt=
if [ -n "$ctx" ]; then
  n=$(( (ctx * 8 + 50) / 100 )); [ "$n" -gt 8 ] && n=8
  i=0
  while [ "$i" -lt 8 ]; do
    if [ "$i" -lt "$n" ]; then bar="${bar}▰"; else bar="${bar}▱"; fi
    i=$((i + 1))
  done
  heat "$ctx"; ctxcolor=$H
  case $cache in
    warm) dur "$cacheleft"; cachetxt=$D ;;
    cold) ctxcolor=90; cachetxt=cold ;;
  esac
fi

reset=
[ -n "$reset5" ] && { dur "$reset5"; reset=$D; }

# add <color> <separator> <text>: append to the colored and the plain line
add() { line="$line$2${e}[$1m$3${R}"; plain="$plain$2$3"; }
# build <with cost> <with bar> <folder name only>: groups are separated by two spaces
build() {
  if [ "$3" = 1 ]; then fol=$short; else fol=$full; fi
  line=$fol$lead; plain=$fol$leadp
  [ -n "$model" ] && add 39 '  ' "$model"  # 39 = terminal default foreground
  [ -n "$effort" ] && add 39 ' ' "$effort"
  if [ -n "$ctx" ]; then
    cg="${ctx}%"
    [ "$2" = 1 ] && cg="$bar $cg"
    [ -n "$cachetxt" ] && cg="$cg $cachetxt"
    add "$ctxcolor" '  ' "$cg"
  fi
  if [ -n "$used5" ]; then
    if [ "$used5" -ge 90 ]; then c5=31; elif [ "$used5" -ge 80 ]; then c5=33; else c5=39; fi
    add "$c5" '  ' "${clock} ${used5}%${reset:+ $reset}"
  fi
  [ -n "$used7" ] && add 31 '  ' "7d ${used7}%"  # only shown at 80%+, so always red
  [ "$1" = 1 ] && [ -n "$cost" ] && add 33 '  ' "\$$cost"
}

# shortcut: the 2-column margin for the UI's own padding is a guess; raise it if the line wraps.
fits() { [ $((${#plain} + 2)) -le "${COLUMNS:-9999}" ]; }
build 1 1 0
fits || build 0 1 0  # drop cost first
fits || build 0 0 0  # then the context bar, keeping the percentage
fits || build 0 0 1  # then the full path, keeping the folder name
printf '%s ' "$line"
