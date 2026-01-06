#!/bin/bash

# ANSI color codes
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
RED='\033[0;31m'
PURPLE='\033[0;35m'
GRAY='\033[0;90m'
WHITE='\033[0;37m'
RESET='\033[0m'

# Read JSON input from stdin
input=$(cat)

# Extract data from Claude Code input
session_id=$(echo "$input" | jq -r '.session_id // empty')
model_name=$(echo "$input" | jq -r '.model.display_name // empty')
current_dir=$(echo "$input" | jq -r '.workspace.current_dir // empty')

# Extract context window data
context_input_tokens=$(echo "$input" | jq -r '.context_window.total_input_tokens // 0')
context_output_tokens=$(echo "$input" | jq -r '.context_window.total_output_tokens // 0')
context_window_size=$(echo "$input" | jq -r '.context_window.context_window_size // 0')

# Extract cost data
session_cost_usd=$(echo "$input" | jq -r '.cost.total_cost_usd // 0')
session_duration_ms=$(echo "$input" | jq -r '.cost.total_duration_ms // 0')

# Get current git branch
if git rev-parse --git-dir >/dev/null 2>&1; then
    branch=$(git branch --show-current 2>/dev/null || echo "detached")
    [ -z "$branch" ] && branch="detached"

    # Check for pending changes
    if ! git diff-index --quiet HEAD -- 2>/dev/null || ! git diff-index --quiet --cached HEAD -- 2>/dev/null; then
        branch="${branch}${PURPLE}*${RESET}"
    fi
else
    branch="no-git"
fi

# Format directory path - show relative to home or just last 2 components
dir_path="$current_dir"
if [[ "$dir_path" == "$HOME"* ]]; then
    dir_path="${dir_path#$HOME/}"
fi
# Keep only last 2 path components for brevity
dir_path=$(echo "$dir_path" | rev | cut -d'/' -f1-2 | rev)
[ -n "$dir_path" ] && dir_path="/$dir_path"

# Format functions
format_cost() { printf "%.2f" "$1"; }

format_tokens() {
    local tokens=$1
    if [ "$tokens" -ge 1000000 ]; then
        printf "%.1fM" "$(echo "scale=1; $tokens / 1000000" | bc -l)"
    elif [ "$tokens" -ge 1000 ]; then
        printf "%.0fk" "$(echo "scale=0; $tokens / 1000" | bc)"
    else
        printf "%d" "$tokens"
    fi
}

format_time() {
    local minutes=$1
    local hours=$((minutes / 60))
    local mins=$((minutes % 60))
    if [ "$hours" -gt 0 ]; then
        printf "%dh%02dm" "$hours" "$mins"
    else
        printf "%dm" "$mins"
    fi
}

# Modern Unicode progress bar
create_progress_bar() {
    local percentage=$1
    local bar_width=10
    local filled=$(echo "scale=0; ($percentage * $bar_width) / 100" | bc)
    local empty=$((bar_width - filled))

    # Ensure filled doesn't exceed bar_width
    [ "$filled" -gt "$bar_width" ] && filled=$bar_width
    [ "$filled" -lt 0 ] && filled=0
    empty=$((bar_width - filled))

    # Color based on percentage with gradient effect
    local color="$GREEN"
    local bg_color='\033[48;5;236m'  # Dark gray background
    [ "$percentage" -ge 50 ] && color="$YELLOW"
    [ "$percentage" -ge 80 ] && color="$RED"

    # Solid block characters
    local filled_char="█"
    local empty_char="░"

    local bar=""
    for ((i=0; i<filled; i++)); do bar="${bar}${color}${filled_char}${RESET}"; done
    for ((i=0; i<empty; i++)); do bar="${bar}${GRAY}${empty_char}${RESET}"; done

    printf "%b" "$bar"
}

# Initialize variables
session_cost="0.00"
session_tokens=0
session_time="0m"

# Get session cost and duration
if [ "$session_cost_usd" != "0" ] && [ "$session_cost_usd" != "null" ]; then
    session_cost="$session_cost_usd"
fi

if [ "$session_duration_ms" != "0" ] && [ "$session_duration_ms" != "null" ]; then
    session_minutes=$((session_duration_ms / 60000))
    session_time=$(format_time "$session_minutes")
fi

# Calculate context window percentage
context_total=$((context_input_tokens + context_output_tokens))
context_percentage=0
if [ "$context_window_size" -gt 0 ]; then
    context_percentage=$(echo "scale=0; ($context_total * 100) / $context_window_size" | bc)
fi

# Get session tokens from ccusage
if command -v ccusage >/dev/null 2>&1 && [ -n "$session_id" ] && [ "$session_id" != "empty" ]; then
    session_data=$(ccusage session --id "$session_id" --json 2>/dev/null)
    if [ $? -eq 0 ] && [ -n "$session_data" ] && [ "$session_data" != "null" ]; then
        [ "$session_cost" = "0.00" ] && session_cost=$(echo "$session_data" | jq -r '.totalCost // 0')
        session_tokens=$(echo "$session_data" | jq -r '.entries | map(.inputTokens + .outputTokens) | add // 0')
    fi
fi


# Format values
f_session_cost=$(format_cost "$session_cost")
f_session_tokens=$(format_tokens "$session_tokens")
f_context_total=$(format_tokens "$context_total")
f_context_max=$(format_tokens "$context_window_size")
context_percentage=${context_percentage:-0}

# Calculate session tokens percentage (relative to context window)
session_percentage=0
if [ "$context_window_size" -gt 0 ] && [ "$session_tokens" -gt 0 ]; then
    session_percentage=$(echo "scale=0; ($session_tokens * 100) / $context_window_size" | bc 2>/dev/null || echo "0")
fi

# Build progress bars
session_bar=$(create_progress_bar "$session_percentage")
context_bar=$(create_progress_bar "$context_percentage")

# Add some style colors
CYAN='\033[0;36m'
BLUE='\033[0;34m'
BOLD='\033[1m'
DIM='\033[2m'

# Build output line with modern styling
# Format: branch • /path • Model • Session stats • Context stats
output=""

# Git branch with icon
output="${output}${PURPLE}${branch}${RESET}"

# Directory
output="${output} ${DIM}│${RESET} ${CYAN}~${dir_path}${RESET}"

# Model name (shortened)
short_model=$(echo "$model_name" | sed 's/Claude //' | sed 's/ /_/')
output="${output} ${DIM}│${RESET} ${BLUE}${short_model}${RESET}"

# Session: cost + bar + time
output="${output} ${DIM}│${RESET} ${GREEN}\$${f_session_cost}${RESET}"
output="${output} ${session_bar}"
output="${output} ${DIM}${session_time}${RESET}"

# Context window: bar + percentage
output="${output} ${DIM}│${RESET} ${context_bar}"
output="${output} ${WHITE}${context_percentage}%${RESET}"

printf "%b\n" "$output"
