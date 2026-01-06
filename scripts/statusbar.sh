#!/bin/bash

# ANSI color codes
GREEN='\033[0;32m'
RED='\033[0;31m'
PURPLE='\033[0;35m'
GRAY='\033[0;90m'
LIGHT_GRAY='\033[0;37m'
RESET='\033[0m'

# Read JSON input from stdin
input=$(cat)

# Extract current session ID and model info from Claude Code input
session_id=$(echo "$input" | jq -r '.session_id // empty')
model_name=$(echo "$input" | jq -r '.model.display_name // empty')
current_dir=$(echo "$input" | jq -r '.workspace.current_dir // empty')
cwd=$(echo "$input" | jq -r '.cwd // empty')

# Get current git branch with error handling
if git rev-parse --git-dir >/dev/null 2>&1; then
    branch=$(git branch --show-current 2>/dev/null || echo "detached")
    if [ -z "$branch" ]; then
        branch="detached"
    fi
    
    # Check for pending changes (staged or unstaged)
    if ! git diff-index --quiet HEAD -- 2>/dev/null || ! git diff-index --quiet --cached HEAD -- 2>/dev/null; then
        # Get line changes for unstaged and staged changes
        unstaged_stats=$(git diff --numstat 2>/dev/null | awk '{added+=$1; deleted+=$2} END {print added+0, deleted+0}')
        staged_stats=$(git diff --cached --numstat 2>/dev/null | awk '{added+=$1; deleted+=$2} END {print added+0, deleted+0}')
        
        # Parse the stats
        unstaged_added=$(echo $unstaged_stats | cut -d' ' -f1)
        unstaged_deleted=$(echo $unstaged_stats | cut -d' ' -f2)
        staged_added=$(echo $staged_stats | cut -d' ' -f1)
        staged_deleted=$(echo $staged_stats | cut -d' ' -f2)
        
        # Total changes
        total_added=$((unstaged_added + staged_added))
        total_deleted=$((unstaged_deleted + staged_deleted))
        
        # Build the branch display with changes (with colors)
        changes=""
        if [ $total_added -gt 0 ]; then
            changes="${GREEN}+$total_added${RESET}"
        fi
        if [ $total_deleted -gt 0 ]; then
            if [ -n "$changes" ]; then
                changes="$changes ${RED}-$total_deleted${RESET}"
            else
                changes="${RED}-$total_deleted${RESET}"
            fi
        fi
        
        if [ -n "$changes" ]; then
            branch="$branch${PURPLE}*${RESET} ($changes)"
        else
            branch="$branch${PURPLE}*${RESET}"
        fi
    fi
else
    branch="no-git"
fi

# Get basename of current directory
dir_name=$(basename "$current_dir")

# Get today's date in YYYYMMDD format
today=$(date +%Y%m%d)

# Function to format numbers
format_cost() {
    printf "%.2f" "$1"
}

format_tokens() {
    local tokens=$1
    if [ "$tokens" -ge 1000000 ]; then
        printf "%.1fM" "$(echo "scale=1; $tokens / 1000000" | bc -l)"
    elif [ "$tokens" -ge 1000 ]; then
        printf "%.1fK" "$(echo "scale=1; $tokens / 1000" | bc -l)"
    else
        printf "%d" "$tokens"
    fi
}

format_time() {
    local minutes=$1
    local hours=$((minutes / 60))
    local mins=$((minutes % 60))
    if [ "$hours" -gt 0 ]; then
        printf "%dh %dm" "$hours" "$mins"
    else
        printf "%dm" "$mins"
    fi
}

# Initialize variables with defaults
session_cost="0.00"
session_tokens=0
daily_cost="0.00"
total_messages=0

# Pricing per model (cost per 1M tokens)
# Based on https://www.anthropic.com/pricing
declare -A input_prices=(
    ["claude-opus-4"]="15.00"
    ["claude-opus"]="15.00" 
    ["claude-sonnet-3.5"]="3.00"
    ["claude-sonnet"]="3.00"
    ["claude-haiku-3.5"]="0.80"
    ["claude-haiku"]="0.25"
)

declare -A output_prices=(
    ["claude-opus-4"]="75.00"
    ["claude-opus"]="75.00"
    ["claude-sonnet-3.5"]="15.00"
    ["claude-sonnet"]="15.00"
    ["claude-haiku-3.5"]="4.00"
    ["claude-haiku"]="1.25"
)

# Function to calculate cost based on tokens and model
calculate_cost() {
    local input_tokens=$1
    local output_tokens=$2
    local model_key=$3
    
    # Default to Opus pricing if model not found
    local input_rate=${input_prices[$model_key]:-"15.00"}
    local output_rate=${output_prices[$model_key]:-"75.00"}
    
    # Calculate cost (price per 1M tokens)
    local input_cost=$(echo "scale=4; $input_tokens * $input_rate / 1000000" | bc -l)
    local output_cost=$(echo "scale=4; $output_tokens * $output_rate / 1000000" | bc -l)
    local total_cost=$(echo "$input_cost + $output_cost" | bc -l)
    
    echo "$total_cost"
}

# Get session data from JSONL file
if [ -n "$session_id" ] && [ "$session_id" != "empty" ]; then
    # Look for the session JSONL file in Claude project directories
    session_jsonl_file=$(find "$HOME/.claude/projects" -name "${session_id}.jsonl" -type f 2>/dev/null | head -1)
    
    if [ -n "$session_jsonl_file" ] && [ -f "$session_jsonl_file" ]; then
        session_tokens=0
        session_cost_calc=0
        total_messages=0
        total_input_tokens=0
        total_output_tokens=0
        
        # Extract model from the first assistant message to determine pricing
        model_name_for_pricing=$(grep '"type":"assistant"' "$session_jsonl_file" | head -1 | jq -r '.message.model // "claude-opus-4"' 2>/dev/null)
        
        # Simplify model name for pricing lookup
        model_key="claude-opus-4"  # default
        case "$model_name_for_pricing" in
            *"opus-4"*) model_key="claude-opus-4" ;;
            *"opus"*) model_key="claude-opus" ;;
            *"sonnet-3.5"*|*"sonnet-3-5"*) model_key="claude-sonnet-3.5" ;;
            *"sonnet"*) model_key="claude-sonnet" ;;
            *"haiku-3.5"*|*"haiku-3-5"*) model_key="claude-haiku-3.5" ;;
            *"haiku"*) model_key="claude-haiku" ;;
        esac
        
        while IFS= read -r line; do
            if [ -n "$line" ]; then
                # Only count assistant messages (they have usage data)
                if echo "$line" | jq -e '.type == "assistant"' >/dev/null 2>&1; then
                    total_messages=$((total_messages + 1))
                    
                    # Extract token usage
                    input_tokens=$(echo "$line" | jq -r '.message.usage.input_tokens // 0' 2>/dev/null || echo "0")
                    output_tokens=$(echo "$line" | jq -r '.message.usage.output_tokens // 0' 2>/dev/null || echo "0")
                    cache_read_tokens=$(echo "$line" | jq -r '.message.usage.cache_read_input_tokens // 0' 2>/dev/null || echo "0")
                    
                    # Add to totals (don't double-count cache tokens as they're already discounted)
                    total_input_tokens=$((total_input_tokens + input_tokens))
                    total_output_tokens=$((total_output_tokens + output_tokens))
                fi
            fi
        done < "$session_jsonl_file"
        
        session_tokens=$((total_input_tokens + total_output_tokens))
        
        # Calculate session cost based on actual usage
        if command -v bc >/dev/null 2>&1 && [ $session_tokens -gt 0 ]; then
            session_cost=$(calculate_cost "$total_input_tokens" "$total_output_tokens" "$model_key")
        fi
    fi
fi

# Calculate daily cost by summing all today's sessions
if [ -d "$HOME/.claude/projects" ]; then
    daily_cost_calc=0
    # Find all JSONL files modified today
    today_sessions=$(find "$HOME/.claude/projects" -name "*.jsonl" -type f -newermt "$today" 2>/dev/null)
    
    for session_file in $today_sessions; do
        if [ -f "$session_file" ]; then
            daily_input=0
            daily_output=0
            
            # Get model for this session
            session_model=$(grep '"type":"assistant"' "$session_file" | head -1 | jq -r '.message.model // "claude-opus-4"' 2>/dev/null)
            session_model_key="claude-opus-4"
            case "$session_model" in
                *"opus-4"*) session_model_key="claude-opus-4" ;;
                *"opus"*) session_model_key="claude-opus" ;;
                *"sonnet-3.5"*|*"sonnet-3-5"*) session_model_key="claude-sonnet-3.5" ;;
                *"sonnet"*) session_model_key="claude-sonnet" ;;
                *"haiku-3.5"*|*"haiku-3-5"*) session_model_key="claude-haiku-3.5" ;;
                *"haiku"*) session_model_key="claude-haiku" ;;
            esac
            
            while IFS= read -r line; do
                if echo "$line" | jq -e '.type == "assistant"' >/dev/null 2>&1; then
                    daily_input=$((daily_input + $(echo "$line" | jq -r '.message.usage.input_tokens // 0')))
                    daily_output=$((daily_output + $(echo "$line" | jq -r '.message.usage.output_tokens // 0')))
                fi
            done < "$session_file"
            
            if command -v bc >/dev/null 2>&1 && [ $((daily_input + daily_output)) -gt 0 ]; then
                session_daily_cost=$(calculate_cost "$daily_input" "$daily_output" "$session_model_key")
                daily_cost_calc=$(echo "$daily_cost_calc + $session_daily_cost" | bc -l)
            fi
        fi
    done
    
    if [ $(echo "$daily_cost_calc > 0" | bc -l) -eq 1 ]; then
        daily_cost="$daily_cost_calc"
    fi
fi

# Format the output
formatted_session_cost=$(format_cost "$session_cost")
formatted_daily_cost=$(format_cost "$daily_cost")
formatted_block_cost=$(format_cost "$block_cost")
formatted_tokens=$(format_tokens "$session_tokens")

# Build the status line with colors (light gray as default)
status_line="${LIGHT_GRAY}🌿 $branch ${GRAY}|${LIGHT_GRAY} 📁 $dir_name ${GRAY}|${LIGHT_GRAY} 🤖 $model_name ${GRAY}|${LIGHT_GRAY} 💰 \$$formatted_session_cost ${GRAY}/${LIGHT_GRAY} 📅 \$$formatted_daily_cost ${GRAY}|${LIGHT_GRAY} 🧩 ${formatted_tokens} ${GRAY}tokens${RESET}"

# Add message count if available
if [ $total_messages -gt 0 ]; then
    status_line="$status_line ${GRAY}(${total_messages} msgs)${RESET}"
fi

printf "%b\n" "$status_line"
