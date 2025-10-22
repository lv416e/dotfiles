#!/usr/bin/env bash
# Lightweight Claude Code usage display for tmux status bar
set -euo pipefail

# Get ccusage path from mise
CCUSAGE="${HOME}/.local/share/mise/installs/npm-ccusage/17.1.3/bin/ccusage"

if [[ ! -x "$CCUSAGE" ]]; then
  echo "N/A"
  exit 0
fi

# Get today's usage (cached for 60 seconds to avoid performance hit)
CACHE_FILE="/tmp/tmux-claude-usage.cache"
CACHE_MAX_AGE=60

if [[ -f "$CACHE_FILE" ]]; then
  CACHE_AGE=$(( $(date +%s) - $(stat -f %m "$CACHE_FILE" 2>/dev/null || echo 0) ))
  if [[ $CACHE_AGE -lt $CACHE_MAX_AGE ]]; then
    cat "$CACHE_FILE"
    exit 0
  fi
fi

# Extract token count from ccusage output
# Use timeout to prevent hanging
OUTPUT=$(timeout 3 "$CCUSAGE" --today --no-color 2>/dev/null || echo "")

if [[ -z "$OUTPUT" ]]; then
  echo "⚡N/A" | tee "$CACHE_FILE"
  exit 0
fi

# Parse the output to get total tokens
# Looking for lines like "Total tokens used: 12345"
TOKENS=$(echo "$OUTPUT" | grep -i "total.*token" | grep -oE '[0-9,]+' | tr -d ',' | head -1 || echo "0")

# Format tokens (K for thousands)
if [[ $TOKENS -gt 0 ]]; then
  if [[ $TOKENS -ge 1000 ]]; then
    TOKENS_K=$((TOKENS / 1000))
    echo "⚡${TOKENS_K}k" | tee "$CACHE_FILE"
  else
    echo "⚡${TOKENS}" | tee "$CACHE_FILE"
  fi
else
  echo "⚡0" | tee "$CACHE_FILE"
fi
