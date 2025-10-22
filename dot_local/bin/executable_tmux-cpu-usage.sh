#!/usr/bin/env bash
# Lightweight CPU usage display for tmux status bar (macOS)
set -euo pipefail

# Use caching to avoid performance hit (cache for 5 seconds)
CACHE_FILE="/tmp/tmux-cpu-usage.cache"
CACHE_MAX_AGE=5

if [[ -f "$CACHE_FILE" ]]; then
  CACHE_AGE=$(( $(date +%s) - $(stat -f %m "$CACHE_FILE" 2>/dev/null || echo 0) ))
  if [[ $CACHE_AGE -lt $CACHE_MAX_AGE ]]; then
    cat "$CACHE_FILE"
    exit 0
  fi
fi

# Get CPU idle percentage using iostat (much faster than top)
# iostat shows: %user %nice %sys %idle
CPU_IDLE=$(iostat -c 2 -w 1 | tail -n 1 | awk '{print $6}' 2>/dev/null || echo "0")

# Calculate CPU usage (100 - idle)
if [[ -n "$CPU_IDLE" ]] && [[ "$CPU_IDLE" != "0" ]]; then
  CPU=$(awk "BEGIN {printf \"%.1f\", 100 - $CPU_IDLE}")
else
  CPU="0.0"
fi

# Convert to integer for comparison
CPU_INT=${CPU%.*}

# Color coding based on usage
if [[ $CPU_INT -gt 80 ]]; then
  # High usage
  OUTPUT="🔥${CPU}%"
elif [[ $CPU_INT -gt 50 ]]; then
  # Medium usage
  OUTPUT="⚙️${CPU}%"
else
  # Normal usage
  OUTPUT="💚${CPU}%"
fi

# Cache the result
echo "$OUTPUT" | tee "$CACHE_FILE"
