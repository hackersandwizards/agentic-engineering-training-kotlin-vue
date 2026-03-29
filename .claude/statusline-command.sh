#!/bin/bash
#
# Claude Code Status Line
#
# Renders a colored, single-line status bar:
#   [Project |] [Branch* ↑N ↓N |] [(REBASING 3/7) |] [Agent |] Model | ████░░░░░░ XX% | [████░░░░░░ XX% Xh Xm]
#
# Colors match starship prompt: cyan=directory, gray=branch, red=dirty, yellow=git state.
# Pure bash + git for branch/status/state.
# Runs after every assistant message — keep it fast.

NOW=$(date +%s)
ESC=$'\033'
RESET="${ESC}[0m"
CYAN="${ESC}[36m"
GREEN="${ESC}[32m"
YELLOW="${ESC}[33m"
RED="${ESC}[31m"
MAGENTA="${ESC}[35m"
GRAY="${ESC}[90m"

FILLED="██████████"
EMPTY="░░░░░░░░░░"
SEP="${GRAY}|${RESET}"

format_countdown() {
    local secs="$1" var="$2"
    if (( secs <= 0 )); then printf -v "$var" '%s' "0m"
    elif (( secs < 3600 )); then printf -v "$var" '%s' "$((secs / 60))m"
    elif (( secs < 86400 )); then printf -v "$var" '%s' "$((secs / 3600))h$((secs % 3600 / 60))m"
    else printf -v "$var" '%s' "$((secs / 86400))d$((secs % 86400 / 3600))h"
    fi
}

# Rate limit time color: is the remaining time enough to survive until the 5h reset?
#   high usage + long wait = red, high usage + almost reset = green
time_color() {
    local pct="$1" secs="$2"
    if (( pct >= 80 )); then
        if   (( secs > 3600 ));  then echo "$RED"
        elif (( secs > 1200 ));  then echo "$YELLOW"
        else                          echo "$GREEN"
        fi
    elif (( pct >= 50 )); then
        if   (( secs > 7200 ));  then echo "$YELLOW"
        else                          echo "$GRAY"
        fi
    else
        echo "$GRAY"
    fi
}

IFS= read -r -d '' input

[[ $input =~ \"project_dir\":\"([^\"]+)\" ]] && project_dir="${BASH_REMATCH[1]##*/}" || project_dir=""
[[ $input =~ \"display_name\":\"([^\"]+)\" ]] && model="${BASH_REMATCH[1]}" || model="Claude"
[[ $input =~ \"used_percentage\":([0-9]+) ]] && pct="${BASH_REMATCH[1]}" || pct=0
[[ $input =~ \"agent\":\{[^}]*\"name\":\"([^\"]+)\" ]] && agent="${BASH_REMATCH[1]}" || agent=""
[[ $input =~ \"context_window_size\":([0-9]+) ]] && ctx_size="${BASH_REMATCH[1]}" || ctx_size=200000
[[ $input =~ \"five_hour\":\{[^}]*\"used_percentage\":([0-9]+) ]] && rl5_pct="${BASH_REMATCH[1]}" || rl5_pct=""
[[ $input =~ \"five_hour\":\{[^}]*\"resets_at\":([0-9]+) ]] && rl5_resets="${BASH_REMATCH[1]}" || rl5_resets=""

# Git branch + dirty + ahead/behind
branch=$(git branch --show-current 2>/dev/null)
if [[ -n $branch ]]; then
    git_status=$(git status --porcelain -b 2>/dev/null)
    [[ $git_status == *$'\n'* ]] && dirty=1 || dirty=""
    ahead="" behind=""
    [[ $git_status =~ ahead\ ([0-9]+) ]] && ahead="${BASH_REMATCH[1]}"
    [[ $git_status =~ behind\ ([0-9]+) ]] && behind="${BASH_REMATCH[1]}"
fi

# Git state: rebase, merge, cherry-pick, revert, bisect
# Detected via .git directory files — no extra git commands needed.
git_state=""
git_dir=$(git rev-parse --git-dir 2>/dev/null)
if [[ -n $git_dir ]]; then
    if [[ -d "$git_dir/rebase-merge" ]]; then
        progress=$(< "$git_dir/rebase-merge/msgnum")
        total=$(< "$git_dir/rebase-merge/end")
        git_state="REBASING ${progress}/${total}"
    elif [[ -d "$git_dir/rebase-apply" ]]; then
        progress=$(< "$git_dir/rebase-apply/next")
        total=$(< "$git_dir/rebase-apply/last")
        git_state="REBASING ${progress}/${total}"
    elif [[ -f "$git_dir/MERGE_HEAD" ]]; then
        git_state="MERGING"
    elif [[ -f "$git_dir/CHERRY_PICK_HEAD" ]]; then
        git_state="CHERRY-PICKING"
    elif [[ -f "$git_dir/REVERT_HEAD" ]]; then
        git_state="REVERTING"
    elif [[ -f "$git_dir/BISECT_LOG" ]]; then
        git_state="BISECTING"
    fi
fi

# Context degradation starts at ~147k tokens regardless of model.
# Thresholds are pre-computed percentages of each model's usable context.
#   Opus 1M  (967k usable): red=15%, yellow=10%
#   200k     (194k usable): red=76%, yellow=52%
if (( ctx_size >= 1000000 )); then
    usable_permille=967 thresh_red=15 thresh_yellow=10
else
    usable_permille=970 thresh_red=76 thresh_yellow=52
fi
if (( pct > 0 )); then
    pct=$(( (pct * 1000 + usable_permille / 2) / usable_permille ))
    (( pct > 100 )) && pct=100
fi

bar_idx=$(( pct / 10 ))

if   (( pct >= thresh_red    )); then bar_color=$RED
elif (( pct >= thresh_yellow )); then bar_color=$YELLOW
else                                   bar_color=$GREEN
fi

out=""
[[ -n $project_dir ]] && out+="${CYAN}${project_dir}${RESET} ${SEP} "
if [[ -n $branch ]]; then
    out+="${GRAY}${branch}${RESET}"
    [[ -n $dirty ]] && out+="${RED}*${RESET}"
    [[ -n $ahead ]] && out+=" ${GRAY}↑${ahead}${RESET}"
    [[ -n $behind ]] && out+=" ${GRAY}↓${behind}${RESET}"
    out+=" ${SEP} "
fi
[[ -n $git_state ]] && out+="${YELLOW}(${git_state})${RESET} ${SEP} "
[[ -n $agent ]] && out+="${MAGENTA}${agent}${RESET} ${SEP} "
out+="${CYAN}${model}${RESET}"
out+=" ${SEP} "
out+="${bar_color}${FILLED:0:bar_idx}${RESET}${EMPTY:bar_idx} ${bar_color}${pct}%${RESET}"
if [[ -n $rl5_pct ]]; then
    rl5_idx=$(( rl5_pct / 10 ))
    if   (( rl5_pct >= 80 )); then rl5_color=$RED
    elif (( rl5_pct >= 50 )); then rl5_color=$YELLOW
    else                            rl5_color=$GREEN
    fi
    rl5_secs=$(( rl5_resets - NOW ))
    format_countdown "$rl5_secs" rl5_time
    rl5_time_color=$(time_color "$rl5_pct" "$rl5_secs")
    out+=" ${SEP} "
    out+="${rl5_color}${FILLED:0:rl5_idx}${RESET}${EMPTY:rl5_idx} ${rl5_color}${rl5_pct}%${RESET} ${rl5_time_color}${rl5_time}${RESET}"
fi

printf '%s\n' "$out"
