#!/bin/bash
# Claude Code statusline script
# Line 1: Model | Context% | git stats | git branch
# Line 2: 5h rate limit bar │ 7d rate limit bar

input=$(cat)

# ---------- ANSI Colors ----------
GREEN=$'\e[38;2;151;201;195m'
YELLOW=$'\e[38;2;229;192;123m'
RED=$'\e[38;2;224;108;117m'
GRAY=$'\e[38;2;74;88;92m'
RESET=$'\e[0m'
DIM=$'\e[2m'

# ---------- Bonus Time Campaign End ----------
# 2026-03-28 23:59 PDT (= 2026-03-29 06:59 UTC)
BONUS_END_EPOCH=1774735140

# ---------- Bonus Time ----------
is_bonus_time() {
  if [ "$BONUS_END_EPOCH" -gt 0 ] && [ "$(date +%s)" -ge "$BONUS_END_EPOCH" ]; then
    return 1
  fi
  local hour minute dow total_min
  hour=$(TZ='Asia/Tokyo' date +%H)
  minute=$(TZ='Asia/Tokyo' date +%M)
  dow=$(TZ='Asia/Tokyo' date +%u)   # 1=Mon … 7=Sun
  total_min=$(( 10#$hour * 60 + 10#$minute ))
  if [ "$dow" -ge 6 ]; then
    return 0   # 土・日は終日
  elif [ "$total_min" -ge 180 ] && [ "$total_min" -lt 1260 ]; then
    return 0   # 平日 3:00–21:00 JST
  fi
  return 1
}

rainbow_text() {
  local text="$1"
  local offset="$2"
  local colors=(196 208 226 46 27 93 129)
  local result="" i=0
  while [ $i -lt ${#text} ]; do
    local char="${text:$i:1}"
    local cidx=$(( (i + offset) % 7 ))
    result+="\033[38;5;${colors[$cidx]}m${char}"
    (( i++ )) || true
  done
  result+="\033[0m"
  printf '%b' "$result"
}

# ---------- Color by percentage ----------
color_for_pct() {
  local pct="${1:-0}"
  if [ -z "$pct" ] || [ "$pct" = "null" ]; then
    printf '%s' "$GRAY"; return
  fi
  if [ "$pct" -ge 80 ] 2>/dev/null; then
    printf '%s' "$RED"
  elif [ "$pct" -ge 50 ] 2>/dev/null; then
    printf '%s' "$YELLOW"
  else
    printf '%s' "$GREEN"
  fi
}

# ---------- Progress bar (8 segments, solid fill + dot remainder) ----------
progress_bar() {
  local pct="$1"
  local color="$2"
  local width=8
  local filled
  filled=$(awk "BEGIN{printf \"%d\", int($pct / 100 * $width + 0.5)}" 2>/dev/null || echo 0)
  [ "$filled" -gt "$width" ] 2>/dev/null && filled=$width
  [ "$filled" -lt 0 ] 2>/dev/null && filled=0
  local empty=$(( width - filled ))
  local bar=""
  [ "$filled" -gt 0 ] && bar+="${color}" && for i in $(seq 1 $filled); do bar+="█"; done && bar+="${RESET}"
  [ "$empty"  -gt 0 ] && bar+="${DIM}${GRAY}" && for i in $(seq 1 $empty);  do bar+="░"; done && bar+="${RESET}"
  printf '%s' "$bar"
}

# ---------- Parse stdin (single jq call) ----------
eval "$(echo "$input" | jq -r '
  "model_name=" + (.model.display_name // "Unknown" | @sh),
  "used_pct=" + (.context_window.used_percentage // 0 | round | tostring),
  "cwd=" + (.cwd // "" | @sh),
  "lines_added=" + (.cost.total_lines_added // 0 | tostring),
  "lines_removed=" + (.cost.total_lines_removed // 0 | tostring),
  "FIVE_HOUR_PCT=" + (.rate_limits.five_hour.used_percentage // empty | round | tostring),
  "FIVE_HOUR_RESET=" + (.rate_limits.five_hour.resets_at // empty | tostring),
  "SEVEN_DAY_PCT=" + (.rate_limits.seven_day.used_percentage // empty | round | tostring),
  "SEVEN_DAY_RESET=" + (.rate_limits.seven_day.resets_at // empty | tostring)
' 2>/dev/null)"

# ---------- Git branch ----------
git_branch=""
if [ -n "$cwd" ] && [ -d "$cwd" ]; then
  git_branch=$(git -C "$cwd" --no-optional-locks rev-parse --abbrev-ref HEAD 2>/dev/null || true)
fi

# ---------- Line stats ----------
git_stats=""
if [ "${lines_added:-0}" -gt 0 ] 2>/dev/null || [ "${lines_removed:-0}" -gt 0 ] 2>/dev/null; then
  git_stats="+${lines_added}/-${lines_removed}"
fi

# ---------- Format reset time ----------
date_field() {
  local epoch="$1" fmt="$2"
  TZ="Asia/Tokyo" date -j -f "%s" "$epoch" "$fmt" 2>/dev/null || \
  TZ="Asia/Tokyo" date -d "@${epoch}" "$fmt" 2>/dev/null || echo ""
}

five_reset_display=""
if [ -n "$FIVE_HOUR_RESET" ] && [ "$FIVE_HOUR_RESET" != "0" ]; then
  _h=$(date_field "$FIVE_HOUR_RESET" "+%I" | sed 's/^0//')
  _ap=$(date_field "$FIVE_HOUR_RESET" "+%p" | tr 'A-Z' 'a-z')
  five_reset_display="Reset at ${_h}${_ap}(JST)"
fi

seven_reset_display=""
if [ -n "$SEVEN_DAY_RESET" ] && [ "$SEVEN_DAY_RESET" != "0" ]; then
  _mo=$(date_field "$SEVEN_DAY_RESET" "+%m" | sed 's/^0//')
  _d=$(date_field "$SEVEN_DAY_RESET" "+%d" | sed 's/^0//')
  _h=$(date_field "$SEVEN_DAY_RESET" "+%I" | sed 's/^0//')
  _ap=$(date_field "$SEVEN_DAY_RESET" "+%p" | tr 'A-Z' 'a-z')
  seven_reset_display="Reset at ${_mo}.${_d} ${_h}${_ap}(JST)"
fi

# ---------- Build output ----------
SEP="${GRAY} │ ${RESET}"
ctx_color=$(color_for_pct "${used_pct:-0}")

# Line 1: model | ctx% | git stats | branch
line1="🤖 ${model_name}${SEP}${ctx_color}📊 ${used_pct:-0}%${RESET}"
[ -n "$git_stats" ] && line1+="${SEP}✏️  ${GREEN}${git_stats}${RESET}"
[ -n "$git_branch" ] && line1+="${SEP}🔀 ${git_branch}"

# Line 2: 5h bar │ 7d bar
if [ -n "$FIVE_HOUR_PCT" ]; then
  c5=$(color_for_pct "$FIVE_HOUR_PCT")
  bar5=$(progress_bar "$FIVE_HOUR_PCT" "$c5")
  line2="${c5}5h ${bar5} ${FIVE_HOUR_PCT}%${RESET}"
  [ -n "$five_reset_display" ] && line2+=" ${DIM}${five_reset_display}${RESET}"
else
  line2="${GRAY}5h ░░░░░░░░ --%${RESET}"
fi

line2+="${SEP}"

if [ -n "$SEVEN_DAY_PCT" ]; then
  c7=$(color_for_pct "$SEVEN_DAY_PCT")
  bar7=$(progress_bar "$SEVEN_DAY_PCT" "$c7")
  line2+="${c7}7d ${bar7} ${SEVEN_DAY_PCT}%${RESET}"
  [ -n "$seven_reset_display" ] && line2+=" ${DIM}${seven_reset_display}${RESET}"
else
  line2+="${GRAY}7d ░░░░░░░░ --%${RESET}"
fi

# ---------- Output ----------
if is_bonus_time; then
  sec=$(date +%S)
  offset=$(( 10#$sec % 7 ))
  printf '%s\n' "$(rainbow_text "⚡ BONUS TIME!! ⚡" "$offset")"
fi
printf '%s\n' "$line1"
printf '%s' "$line2"
