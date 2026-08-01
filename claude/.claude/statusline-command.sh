#!/bin/bash
# Claude Code statusline - model, dir, branch, context usage, caveman badge.
# One faint line in the muted dark-ansi palette. Terminals cannot change font
# size from a statusline, so "small" here means dim (SGR 2) text and thin
# separators rather than an actual smaller glyph size.

set -u

# Resolve the caveman plugin hook by glob so it survives version/hash changes.
CAVEMAN_SCRIPT=$(ls "$HOME"/.claude/plugins/cache/caveman/caveman/*/hooks/caveman-statusline.sh 2>/dev/null | head -1)

input=$(cat)

DIM=$'\033[2m'
OFF=$'\033[0m'
GREY=$'\033[38;5;245m'
BLUE=$'\033[38;5;110m'
SEP="${DIM}"$'\033[38;5;240m'" ┊ ${OFF}"

# Compact token count: 940 -> 940, 36542 -> 36.5k, 1000000 -> 1M
fmt_tokens() {
    awk -v n="$1" 'BEGIN {
        if (n >= 1000000)  { v = n / 1000000; printf (v == int(v) ? "%dM" : "%.1fM"), v }
        else if (n >= 1000) { v = n / 1000;   printf (v < 10 ? "%.1fk" : "%dk"),    v }
        else                                  printf "%d", n
    }'
}

# One jq pass; -1 percentage means "no API call yet, hide the context segment".
IFS=$'\t' read -r model cwd used_pct in_tok out_tok win < <(
    printf '%s' "$input" | jq -r '[
        .model.display_name           // "?",
        .workspace.current_dir        // "",
        (.context_window.used_percentage // -1 | floor),
        .context_window.total_input_tokens   // 0,
        .context_window.total_output_tokens  // 0,
        .context_window.context_window_size  // 0
    ] | @tsv'
)

line="${DIM}${GREY}${model}${OFF}"
[ -n "$cwd" ] && line="${line}${SEP}${DIM}${GREY}${cwd##*/}${OFF}"

# Branch, suffixed with * when the worktree has uncommitted changes.
branch=$(git -C "${cwd:-.}" rev-parse --abbrev-ref HEAD 2>/dev/null)
if [ -n "$branch" ]; then
    git -C "${cwd:-.}" diff --quiet --ignore-submodules HEAD 2>/dev/null || branch="${branch}*"
    line="${line}${SEP}${DIM}${BLUE}${branch}${OFF}"
fi

# Context used / model window, colored by pressure: green ≤60%, yellow ≤85%, red above.
if [ "$used_pct" -ge 0 ] && [ "$win" -gt 0 ]; then
    if   [ "$used_pct" -le 60 ]; then ctx_color=$'\033[38;5;71m'
    elif [ "$used_pct" -le 85 ]; then ctx_color=$'\033[38;5;178m'
    else                              ctx_color=$'\033[38;5;167m'
    fi
    line="${line}${SEP}${DIM}${ctx_color}$(fmt_tokens "$((in_tok + out_tok))")/$(fmt_tokens "$win") ${used_pct}%${OFF}"
fi

printf '%s' "$line"

# Caveman badge (delegated entirely to the plugin script).
if [ -x "$CAVEMAN_SCRIPT" ]; then
    badge=$(bash "$CAVEMAN_SCRIPT" 2>/dev/null)
    [ -n "$badge" ] && printf '%s%s%s%s' "$SEP" "$DIM" "$badge" "$OFF"
fi
printf '\n'
