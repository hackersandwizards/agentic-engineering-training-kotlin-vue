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

# Claude Code reserves ~33k tokens for compaction, leaving 96.7% usable (1M context).
USABLE_CONTEXT_PERMILLE=967

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

# --- Format -----------------------------------------------------------

# Rescale so 100% means "compaction imminent" rather than "context full."
if (( pct > 0 )); then
    pct=$(( (pct * 1000 + USABLE_CONTEXT_PERMILLE / 2) / USABLE_CONTEXT_PERMILLE ))
    (( pct > 100 )) && pct=100
fi

format_tokens "$tokens_in" fmt_in
format_tokens "$tokens_out" fmt_out

bar_idx=$(( pct / 10 ))

if   (( pct >= 31 )); then bar_color=$RED
elif (( pct >= 21 )); then bar_color=$YELLOW
else                        bar_color=$GREEN
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
