#!/bin/bash
# Claude Code statusline — context usage % + token counts + caveman mode badge
# Styled to match the dark-ansi PS1 theme (muted separators, orange caveman badge).

# Resolve the caveman plugin hook by glob so it survives version/hash changes.
CAVEMAN_SCRIPT=$(ls "$HOME"/.claude/plugins/cache/caveman/caveman/*/hooks/caveman-statusline.sh 2>/dev/null | head -1)

input=$(cat)

# --- Context usage ---
used=$(printf '%s' "$input" | jq -r '.context_window.used_percentage // empty')
if [ -n "$used" ]; then
    used_int=$(printf '%.0f' "$used")
    # Color: green ≤60 %, yellow ≤85 %, red >85 %
    if [ "$used_int" -le 60 ]; then
        ctx_color="\033[38;5;71m"   # muted green
    elif [ "$used_int" -le 85 ]; then
        ctx_color="\033[38;5;178m"  # muted yellow
    else
        ctx_color="\033[38;5;167m"  # muted red
    fi
    printf "${ctx_color}[ctx:%d%%]\033[0m" "$used_int"
fi

# --- Token counts (session totals: input + output) ---
# Uses pre-accumulated totals so the numbers grow across the session.
# Only shown after the first API response (when current_usage is non-null).
has_usage=$(printf '%s' "$input" | jq -r '.context_window.current_usage // empty')
if [ -n "$has_usage" ]; then
    in_tok=$(printf '%s' "$input" | jq -r '.context_window.total_input_tokens // 0')
    out_tok=$(printf '%s' "$input" | jq -r '.context_window.total_output_tokens // 0')

    # Format a raw integer as a compact human-readable string: 1234 → 1.2k, 12345 → 12k
    fmt_k() {
        local n=$1
        if [ "$n" -ge 1000 ]; then
            # awk keeps one decimal for values < 10k, drops it for ≥ 10k
            awk -v n="$n" 'BEGIN {
                v = n / 1000
                if (v < 10) printf "%.1fk", v
                else         printf "%dk",   int(v + 0.5)
            }'
        else
            printf '%d' "$n"
        fi
    }

    in_fmt=$(fmt_k "$in_tok")
    out_fmt=$(fmt_k "$out_tok")
    printf ' \033[38;5;245m[in:%s out:%s]\033[0m' "$in_fmt" "$out_fmt"
fi

# --- Caveman badge (delegated entirely to the plugin script) ---
if [ -x "$CAVEMAN_SCRIPT" ]; then
    badge=$(bash "$CAVEMAN_SCRIPT" 2>/dev/null)
    [ -n "$badge" ] && printf ' %s' "$badge"
fi
