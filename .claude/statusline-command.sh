#!/bin/bash
#
# Claude Code Status Line
#
# Renders a colored, single-line status bar:
#   [Agent |] Model | ████░░░░░░ XX% | ↑Xk ↓Xk | [████░░░░░░ XX% Xh Xm |] [XX% Xd Xh |] $X.XX
#
# Pure bash. One external command (date +%s for rate limit countdowns).
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

format_tokens() {
    local count="$1" var="$2"
    if (( count >= 1000000 )); then
        printf -v "$var" '%s' "$((count / 1000000)).$((count % 1000000 / 100000))M"
    elif (( count >= 1000 )); then
        printf -v "$var" '%s' "$((count / 1000)).$((count % 1000 / 100))k"
    else
        printf -v "$var" '%s' "$count"
    fi
}

IFS= read -r -d '' input

[[ $input =~ \"display_name\":\"([^\"]+)\" ]] && model="${BASH_REMATCH[1]}" || model="Claude"
[[ $input =~ \"used_percentage\":([0-9]+) ]] && pct="${BASH_REMATCH[1]}" || pct=0
[[ $input =~ \"total_input_tokens\":([0-9]+) ]] && tokens_in="${BASH_REMATCH[1]}" || tokens_in=0
[[ $input =~ \"total_output_tokens\":([0-9]+) ]] && tokens_out="${BASH_REMATCH[1]}" || tokens_out=0
[[ $input =~ \"agent\":\{[^}]*\"name\":\"([^\"]+)\" ]] && agent="${BASH_REMATCH[1]}" || agent=""
[[ $input =~ \"context_window_size\":([0-9]+) ]] && ctx_size="${BASH_REMATCH[1]}" || ctx_size=200000
[[ $input =~ \"five_hour\":\{[^}]*\"used_percentage\":([0-9]+) ]] && rl5_pct="${BASH_REMATCH[1]}" || rl5_pct=""
[[ $input =~ \"five_hour\":\{[^}]*\"resets_at\":([0-9]+) ]] && rl5_resets="${BASH_REMATCH[1]}" || rl5_resets=""
[[ $input =~ \"seven_day\":\{[^}]*\"used_percentage\":([0-9]+) ]] && rl7_pct="${BASH_REMATCH[1]}" || rl7_pct=""
[[ $input =~ \"seven_day\":\{[^}]*\"resets_at\":([0-9]+) ]] && rl7_resets="${BASH_REMATCH[1]}" || rl7_resets=""

# Cost arrives as float "1.234" or integer "0"
if [[ $input =~ \"total_cost_usd\":([0-9]+)\.([0-9]+) ]]; then
    cost_int="${BASH_REMATCH[1]}"
    cost_dec="${BASH_REMATCH[2]}00"
else
    [[ $input =~ \"total_cost_usd\":([0-9]+) ]] && cost_int="${BASH_REMATCH[1]}" || cost_int=0
    cost_dec="00"
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

format_tokens "$tokens_in" fmt_in
format_tokens "$tokens_out" fmt_out

bar_idx=$(( pct / 10 ))

if   (( pct >= thresh_red    )); then bar_color=$RED
elif (( pct >= thresh_yellow )); then bar_color=$YELLOW
else                                   bar_color=$GREEN
fi

if (( cost_int >= 5 )); then cost_color=$RED
else                         cost_color=$YELLOW
fi

out=""
[[ -n $agent ]] && out+="${MAGENTA}${agent}${RESET} ${SEP} "
out+="${CYAN}${model}${RESET}"
out+=" ${SEP} "
out+="${bar_color}${FILLED:0:bar_idx}${RESET}${EMPTY:bar_idx} ${bar_color}${pct}%${RESET}"
out+=" ${SEP} "
out+="${GRAY}↑${fmt_in} ↓${fmt_out}${RESET}"
if [[ -n $rl5_pct ]]; then
    rl5_idx=$(( rl5_pct / 10 ))
    if   (( rl5_pct >= 80 )); then rl5_color=$RED
    elif (( rl5_pct >= 50 )); then rl5_color=$YELLOW
    else                            rl5_color=$GREEN
    fi
    rl5_secs=$(( rl5_resets - NOW ))
    format_countdown "$rl5_secs" rl5_time
    out+=" ${SEP} "
    out+="${rl5_color}${FILLED:0:rl5_idx}${RESET}${EMPTY:rl5_idx} ${rl5_color}${rl5_pct}%${RESET} ${GRAY}${rl5_time}${RESET}"
fi
if [[ -n $rl7_pct ]] && (( rl7_pct >= 50 )); then
    if (( rl7_pct >= 80 )); then rl7_color=$RED
    else                          rl7_color=$YELLOW
    fi
    rl7_secs=$(( rl7_resets - NOW ))
    format_countdown "$rl7_secs" rl7_time
    out+=" ${SEP} "
    out+="${rl7_color}${rl7_pct}%${RESET} ${GRAY}${rl7_time}${RESET}"
fi
out+=" ${SEP} "
out+="${cost_color}\$${cost_int}.${cost_dec:0:2}${RESET}"

printf '%s\n' "$out"
