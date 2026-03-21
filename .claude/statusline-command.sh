#!/bin/bash
#
# Claude Code Status Line
#
# Renders a colored, single-line status bar:
#   [Agent |] Model | ████░░░░░░ XX% | ↑Xk ↓Xk | $X.XX
#
# Pure bash. No external commands, no subshells, no file I/O.
# Runs after every assistant message — keep it fast.

# --- Constants --------------------------------------------------------

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

# Context degradation starts at ~147k tokens regardless of model.
# Thresholds are pre-computed percentages of each model's usable context.
#   Opus 1M  (967k usable): red=15%, yellow=10%
#   200k     (194k usable): red=76%, yellow=52%
THRESH_RED_1M=15   THRESH_YELLOW_1M=10   USABLE_PERMILLE_1M=967
THRESH_RED_200K=76 THRESH_YELLOW_200K=52 USABLE_PERMILLE_200K=970

# --- Functions --------------------------------------------------------

# Sets the variable named by $2 to a human-readable token count.
# Uses printf -v to assign by name without spawning a subshell.
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

# --- Parse ------------------------------------------------------------

IFS= read -r -d '' input

[[ $input =~ \"display_name\":\"([^\"]+)\" ]] && model="${BASH_REMATCH[1]}" || model="Claude"
[[ $input =~ \"used_percentage\":([0-9]+) ]] && pct="${BASH_REMATCH[1]}" || pct=0
[[ $input =~ \"total_input_tokens\":([0-9]+) ]] && tokens_in="${BASH_REMATCH[1]}" || tokens_in=0
[[ $input =~ \"total_output_tokens\":([0-9]+) ]] && tokens_out="${BASH_REMATCH[1]}" || tokens_out=0
[[ $input =~ \"agent\":\{[^}]*\"name\":\"([^\"]+)\" ]] && agent="${BASH_REMATCH[1]}" || agent=""

# Cost arrives as float "1.234" or integer "0"
if [[ $input =~ \"total_cost_usd\":([0-9]+)\.([0-9]+) ]]; then
    cost_int="${BASH_REMATCH[1]}"
    cost_dec="${BASH_REMATCH[2]}00"
else
    [[ $input =~ \"total_cost_usd\":([0-9]+) ]] && cost_int="${BASH_REMATCH[1]}" || cost_int=0
    cost_dec="00"
fi

# --- Model detection & thresholds -------------------------------------

if [[ $model == *"1M"* ]]; then
    usable_permille=$USABLE_PERMILLE_1M
    thresh_red=$THRESH_RED_1M
    thresh_yellow=$THRESH_YELLOW_1M
else
    usable_permille=$USABLE_PERMILLE_200K
    thresh_red=$THRESH_RED_200K
    thresh_yellow=$THRESH_YELLOW_200K
fi

# --- Format -----------------------------------------------------------

# Rescale so 100% means "compaction imminent" rather than "context full."
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

# --- Render -----------------------------------------------------------

out=""
[[ -n $agent ]] && out+="${MAGENTA}${agent}${RESET} ${SEP} "
out+="${CYAN}${model}${RESET}"
out+=" ${SEP} "
out+="${bar_color}${FILLED:0:bar_idx}${RESET}${EMPTY:bar_idx} ${bar_color}${pct}%${RESET}"
out+=" ${SEP} "
out+="${GRAY}↑${fmt_in} ↓${fmt_out}${RESET}"
out+=" ${SEP} "
out+="${cost_color}\$${cost_int}.${cost_dec:0:2}${RESET}"

printf '%s\n' "$out"
