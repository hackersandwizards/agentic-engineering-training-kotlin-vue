#!/bin/bash
#
# Claude Code Status Line Script - Highly optimized
# Displays: Model Name | ████░░░░░░ XX% | ↑ Xk ↓ Xk | "latest prompt..."

IFS= read -r -d '' input

# Single regex pass - extract all values at once
[[ $input =~ \"display_name\":\"([^\"]+)\" ]] && model="${BASH_REMATCH[1]}" || model="Claude"
[[ $input =~ \"context_window_size\":([0-9]+) ]] && size="${BASH_REMATCH[1]}" || size=200000
[[ $input =~ \"total_input_tokens\":([0-9]+) ]] && total_in="${BASH_REMATCH[1]}" || total_in=0
[[ $input =~ \"total_output_tokens\":([0-9]+) ]] && total_out="${BASH_REMATCH[1]}" || total_out=0
[[ $input =~ \"input_tokens\":([0-9]+) ]] && input_tok="${BASH_REMATCH[1]}" || input_tok=0
[[ $input =~ \"cache_read_input_tokens\":([0-9]+) ]] && cache_read="${BASH_REMATCH[1]}" || cache_read=0
[[ $input =~ \"cache_creation_input_tokens\":([0-9]+) ]] && cache_create="${BASH_REMATCH[1]}" || cache_create=0
[[ $input =~ \"output_tokens\":([0-9]+) ]] && output_tok="${BASH_REMATCH[1]}" || output_tok=0

# Calculate percentage and bar index
# Only add autocompact buffer (45k) when there's actual content
tokens=$((input_tok + cache_read + cache_create + output_tok))
if (( tokens > 0 )); then
    pct=$(( (tokens + 45000) * 100 / size ))
else
    pct=0
fi
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
