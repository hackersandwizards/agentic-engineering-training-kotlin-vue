#!/usr/bin/env bash
# shellcheck disable=SC2154
# (extract/pct_color/time_color/render_bar all assign via `printf -v "$var"`,
#  which shellcheck can't trace — so it flags every consumer as unset.)
#
# Claude Code Status Line
#
# Renders a colored, single-line status bar:
#   [Project |] [Branch* |] [(REBASING 3/7) |] [↑N↓N |] [Agent |] Model | [Effort |] ████░░░░░░ XX% | [████░░░░░░ XX% Xh Xm] [| status]
#
# Colors match starship prompt: cyan=directory, gray=branch, red=dirty, yellow=git state.
# Effort badge colors match Claude's UI: low=yellow, medium=green, high=blue, xhigh=magenta, max=gradient.
#
# Performance: hot path forks `git status` once when in a git repo; pure bash
# otherwise. `env bash` picks up bash 5+ for $EPOCHSECONDS (no `date` fork).
# Service status fetched in a backgrounded curl every 5min and cached as a tiny
# derived file (just the component status string), with a sidecar epoch for freshness.

ESC=$'\033'
RESET="${ESC}[0m"
CYAN="${ESC}[36m"
GREEN="${ESC}[32m"
YELLOW="${ESC}[33m"
BLUE="${ESC}[34m"
RED="${ESC}[31m"
MAGENTA="${ESC}[35m"
GRAY="${ESC}[90m"
# Truecolor for the `max` effort gradient — m=orange, a=gold, x=sky.
ORANGE="${ESC}[38;2;230;130;50m"
GOLD="${ESC}[38;2;220;200;60m"
SKY="${ESC}[38;2;110;180;200m"

FILLED="██████████"
EMPTY="░░░░░░░░░░"
SEP="${GRAY}|${RESET}"

# Context window: Claude reports "% context used" against the auto-compact threshold,
# not the full window. As of cli v2.1.156 the threshold is:
#   context_window_size − reservedForSummary − 13000(buffer)
# where reservedForSummary = min(maxOutputTokens, 20000) and the default maxOutput is
# capped at 8000, so the reserve is a fixed 8000 + 13000 = 21000 tokens. It's a token
# count (not a %), so the same value is correct for any window size (200k, 1M, …).
# Not exposed in the statusline JSON — re-sync this if Anthropic changes the constants.
CTX_RESERVE_TOKENS=21000
# % of the usable window at which the context bar turns red / yellow (how far toward
# auto-compact we are). Percentage-based, so the same pair holds for any window size.
CTX_BAR_RED=76  CTX_BAR_YELLOW=52

# 5-hour rate limit thresholds (raw %, no rescaling).
RL5_RED=80   RL5_YELLOW=50

# Service status: how long to trust the cache, and the curl timeout for refreshes.
STATUS_CACHE_TTL=300   STATUS_FETCH_TIMEOUT=5

format_countdown() {
    local secs="$1" var="$2"
    if (( secs <= 0 )); then printf -v "$var" '%s' "0m"
    elif (( secs < 3600 )); then printf -v "$var" '%s' "$((secs / 60))m"
    elif (( secs < 86400 )); then printf -v "$var" '%s' "$((secs / 3600))h$((secs % 3600 / 60))m"
    else printf -v "$var" '%s' "$((secs / 86400))d$((secs % 86400 / 3600))h"
    fi
}

# Capture group 1 of $pat from $src (default: $input) into $var; fall back to $def.
extract() {
    local pat="$1" var="$2" def="$3" src="${4-$input}"
    if [[ $src =~ $pat ]]; then printf -v "$var" '%s' "${BASH_REMATCH[1]}"
    else                        printf -v "$var" '%s' "$def"
    fi
}

# Render "[colored filled][empty] [colored pct%]" into $var.
render_bar() {
    local color="$1" idx="$2" pct="$3" var="$4"
    printf -v "$var" '%s%s%s%s %s%s%%%s' \
        "$color" "${FILLED:0:idx}" "$RESET" "${EMPTY:idx}" \
        "$color" "$pct" "$RESET"
}

pct_color() {
    local pct="$1" red="$2" yellow="$3" var="$4"
    if   (( pct >= red    )); then printf -v "$var" '%s' "$RED"
    elif (( pct >= yellow )); then printf -v "$var" '%s' "$YELLOW"
    else                            printf -v "$var" '%s' "$GREEN"
    fi
}

# Color the rate-limit countdown by how alarming the burn rate is.
# Matrix (pct used × seconds left):
#   high pct (≥80) + lots of time left → red (burning too fast)
#   mid  pct (≥50) + lots of time left → yellow; ≤30min left → green (almost reset)
#   low  pct (<50)                     → gray (no concern, ignore time)
time_color() {
    local pct="$1" secs="$2" var="$3"
    if (( pct >= 80 )); then
        if   (( secs > 3600 ));  then printf -v "$var" '%s' "$RED"
        elif (( secs > 1200 ));  then printf -v "$var" '%s' "$YELLOW"
        else                          printf -v "$var" '%s' "$GREEN"
        fi
    elif (( pct >= 50 )); then
        if   (( secs > 7200 ));  then printf -v "$var" '%s' "$YELLOW"
        elif (( secs <= 1800 )); then printf -v "$var" '%s' "$GREEN"
        else                          printf -v "$var" '%s' "$GRAY"
        fi
    else
        printf -v "$var" '%s' "$GRAY"
    fi
}

IFS= read -r -d '' input

# bash 5+ exposes $EPOCHSECONDS as a no-fork builtin; `date +%s` is the bash 3-4 fallback.
now=${EPOCHSECONDS:-$(date +%s)}

extract '"project_dir":"([^"]+)"'                       project_dir ""
project_dir="${project_dir##*/}"
extract '"display_name":"([^"]+)"'                      model       "Claude"
extract '"agent":\{[^}]*"name":"([^"]+)"'               agent       ""
extract '"context_window_size":([0-9]+)'                ctx_size    200000
extract '"effort":\{[^}]*"level":"([^"]+)"'             effort      ""
extract '"five_hour":\{[^}]*"used_percentage":([0-9]+)' rl5_pct     ""
extract '"five_hour":\{[^}]*"resets_at":([0-9]+)'       rl5_resets  ""

# Context usage: sum the live token counts from context_window.current_usage
# (input + cache_creation + cache_read — Claude excludes output_tokens). Strip rate_limits
# first so the token regexes only ever see the context-window block. "input_tokens" does
# not match inside "total_input_tokens"/"cache_*_input_tokens" (no leading quote there).
ctx_only="${input%%\"rate_limits\"*}"
extract '"input_tokens":([0-9]+)'                tok_input  0  "$ctx_only"
extract '"cache_creation_input_tokens":([0-9]+)' tok_cc     0  "$ctx_only"
extract '"cache_read_input_tokens":([0-9]+)'     tok_cr     0  "$ctx_only"
tokens=$(( tok_input + tok_cc + tok_cr ))

# Find .git in $PWD or an ancestor without forking; resolve worktree pointer files inline.
git_dir="" git_state=""
branch="" dirty="" ahead="" behind=""
dir=$PWD
while [[ $dir && $dir != / ]]; do
    if [[ -d $dir/.git ]]; then
        git_dir=$dir/.git; break
    elif [[ -f $dir/.git ]]; then
        # Worktree: .git is a text file containing "gitdir: <path>"
        gitdir_pointer=$(< "$dir/.git")
        git_dir=${gitdir_pointer#gitdir: }
        # Relative gitdir → absolute (worktrees can use either form).
        [[ $git_dir == /* ]] || git_dir=$dir/$git_dir
        break
    fi
    dir=${dir%/*}
done

if [[ -n $git_dir ]]; then
    git_status=$(git status --porcelain -b 2>/dev/null)
    if [[ -n $git_status ]]; then
        [[ $git_status =~ ^##\ ([^.$'\n']+) ]] && branch="${BASH_REMATCH[1]%%...*}"
        [[ $git_status == *$'\n'* ]] && dirty=1
        [[ $git_status =~ ahead\ ([0-9]+) ]] && ahead="${BASH_REMATCH[1]}"
        [[ $git_status =~ behind\ ([0-9]+) ]] && behind="${BASH_REMATCH[1]}"
    fi
    if [[ -d $git_dir/rebase-merge ]]; then
        git_state="REBASING $(< "$git_dir/rebase-merge/msgnum")/$(< "$git_dir/rebase-merge/end")"
    elif [[ -d $git_dir/rebase-apply ]]; then
        git_state="REBASING $(< "$git_dir/rebase-apply/next")/$(< "$git_dir/rebase-apply/last")"
    elif [[ -f $git_dir/MERGE_HEAD ]]; then       git_state="MERGING"
    elif [[ -f $git_dir/CHERRY_PICK_HEAD ]]; then git_state="CHERRY-PICKING"
    elif [[ -f $git_dir/REVERT_HEAD ]]; then      git_state="REVERTING"
    elif [[ -f $git_dir/BISECT_LOG ]]; then       git_state="BISECTING"
    fi
fi

# "% context used" exactly as Claude renders it: round against the usable window
# (full window minus the auto-compact reserve), mirroring 100 − round(remaining/usable).
usable=$(( ctx_size - CTX_RESERVE_TOKENS ))
(( usable < 1 )) && usable=1
if (( tokens >= usable )); then
    pct=100
else
    pct=$(( 100 - ( ( (usable - tokens) * 100 + usable / 2 ) / usable ) ))
fi

bar_idx=$(( pct / 10 ))
pct_color "$pct" "$CTX_BAR_RED" "$CTX_BAR_YELLOW" bar_color

# --- Build output ---
# Convention: trailing " ${SEP} " on a section means "more sections may follow."
# Leading " ${SEP} " (used by the rl5 bar and the status badge) means "only joins
# when something rendered before us" — the load-bearing inconsistency is intentional.

out=""

[[ -n $project_dir ]] && out+="${CYAN}${project_dir}${RESET} ${SEP} "
if [[ -n $branch ]]; then
    out+="${GRAY}${branch}${RESET}"
    [[ -n $dirty ]] && out+="${RED}*${RESET}"
    out+=" ${SEP} "
fi
[[ -n $git_state ]] && out+="${YELLOW}(${git_state})${RESET} ${SEP} "
if [[ -n $ahead || -n $behind ]]; then
    [[ -n $ahead ]] && out+="${GRAY}↑${ahead}${RESET}"
    [[ -n $behind ]] && out+="${GRAY}↓${behind}${RESET}"
    out+=" ${SEP} "
fi

[[ -n $agent ]] && out+="${ORANGE}${agent}${RESET} ${SEP} "
out+="${CYAN}${model}${RESET}"
out+=" ${SEP} "
if [[ -n $effort ]]; then
    case "$effort" in
        low)    out+="${YELLOW}low${RESET}" ;;
        medium) out+="${GREEN}med${RESET}" ;;
        high)   out+="${BLUE}high${RESET}" ;;
        xhigh)  out+="${MAGENTA}xhigh${RESET}" ;;
        max)    out+="${ORANGE}m${GOLD}a${SKY}x${RESET}" ;;
        *)      out+="${GRAY}${effort}${RESET}" ;;
    esac
    out+=" ${SEP} "
fi

render_bar "$bar_color" "$bar_idx" "$pct" ctx_bar
out+="$ctx_bar"
if [[ -n $rl5_pct ]]; then
    rl5_idx=$(( rl5_pct / 10 ))
    pct_color "$rl5_pct" "$RL5_RED" "$RL5_YELLOW" rl5_color
    rl5_secs=$(( rl5_resets - now ))
    format_countdown "$rl5_secs" rl5_time
    time_color "$rl5_pct" "$rl5_secs" rl5_time_color
    render_bar "$rl5_color" "$rl5_idx" "$rl5_pct" rl5_bar
    out+=" ${SEP} ${rl5_bar} ${rl5_time_color}${rl5_time}${RESET}"
fi

# Service status: background curl every 5min stores just the Claude Code component
# status string (~20 bytes), so the hot path doesn't have to regex a 30 KB summary JSON.
status_cache="/tmp/claude-statusline-status.cc"
status_expiry_file="/tmp/claude-statusline-status.expiry"
status_expiry=0
read -r status_expiry < "$status_expiry_file" 2>/dev/null
[[ $status_expiry =~ ^[0-9]+$ ]] || status_expiry=0
if (( now >= status_expiry )); then
    # Pre-write next expiry so parallel renders don't all spawn fetches; also
    # debounces retries when the upstream is unreachable (curl fails → cache stays).
    echo $(( now + STATUS_CACHE_TTL )) > "$status_expiry_file"
    (
        resp=$(curl -s --max-time "$STATUS_FETCH_TIMEOUT" "https://status.claude.com/api/v2/summary.json")
        if [[ $resp =~ \"name\":\"Claude\ Code\"[^}]*\"status\":\"([^\"]+)\" ]]; then
            printf '%s' "${BASH_REMATCH[1]}" > "${status_cache}.tmp" \
                && mv "${status_cache}.tmp" "$status_cache"
        fi
    ) >/dev/null 2>&1 &
fi
if [[ -s $status_cache ]]; then
    read -r cc_status < "$status_cache"
    case "$cc_status" in
        operational|"")       label="" ;;
        degraded_performance) label="${YELLOW}degraded" ;;
        partial_outage)       label="${YELLOW}partial outage" ;;
        major_outage)         label="${RED}major outage" ;;
        under_maintenance)    label="${YELLOW}maintenance" ;;
        *)                    label="" ;;
    esac
    [[ -n $label ]] && out+=" ${SEP} ${label}${RESET}"
fi

printf '%s\n' "$out"
