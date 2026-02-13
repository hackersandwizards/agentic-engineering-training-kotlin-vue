#!/bin/bash
#
# Claude Code Status Line Script - Highly optimized
# Displays: Model Name | ████░░░░░░ XX% | ↑ Xk ↓ Xk

IFS= read -r -d '' input

# Extract values via regex
[[ $input =~ \"display_name\":\"([^\"]+)\" ]] && model="${BASH_REMATCH[1]}" || model="Claude"
[[ $input =~ \"used_percentage\":([0-9]+) ]] && pct="${BASH_REMATCH[1]}" || pct=0

# Adjust for 33k token compaction buffer (~16.5% of 200k, 83.5% usable context)
(( pct > 0 )) && pct=$(( (pct * 1000 + 417) / 835 )) || pct=0
(( pct > 100 )) && pct=100
[[ $input =~ \"total_input_tokens\":([0-9]+) ]] && total_in="${BASH_REMATCH[1]}" || total_in=0
[[ $input =~ \"total_output_tokens\":([0-9]+) ]] && total_out="${BASH_REMATCH[1]}" || total_out=0

# Progress bar index (0-10)
idx=$(( pct/10 > 10 ? 10 : pct/10 ))

# Format tokens inline (no subshell, no intermediate vars)
(( total_in >= 1000 )) && fmt_in="$((total_in/1000)).$((total_in%1000/100))k" || fmt_in=$total_in
(( total_out >= 1000 )) && fmt_out="$((total_out/1000)).$((total_out%1000/100))k" || fmt_out=$total_out

# Progress bar strings (sliced dynamically)
f="██████████"; e="░░░░░░░░░░"

# Get last user prompt - commented out for performance (saves 4 external processes)
# prompt=""
# if [[ $input =~ \"transcript_path\":\"([^\"]+)\" ]]; then
#     tf="${BASH_REMATCH[1]}"
#     [[ -f "$tf" ]] && prompt=$(grep -F '"type":"user"' "$tf" 2>/dev/null | tac | \
#         jaq -r 'select(.message.content | type == "string") | .message.content | gsub("\n"; " ") | if length > 10 then .[:10] + "…" else . end' 2>/dev/null | \
#         head -1)
# fi

# Output
echo "$model | ${f:0:idx}${e:idx} $pct% | ↑ $fmt_in ↓ $fmt_out"
