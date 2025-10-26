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
# iostat output format: ... us sy id ...
# Use $(NF-3) to get 'id' (idle) field from the end of the line
# -w 3: 3-second sampling interval for more stable average
CPU_IDLE=$(iostat -c 2 -w 3 | tail -n 1 | awk '{print $(NF-3)}' 2>/dev/null || echo "0")

# Calculate CPU usage (100 - idle)
if [[ -n "$CPU_IDLE" ]] && [[ "$CPU_IDLE" != "0" ]]; then
  CPU=$(awk "BEGIN {printf \"%.1f\", 100 - $CPU_IDLE}")
else
  CPU="0.0"
fi

# Convert to integer for comparison
CPU_INT=${CPU%.*}

# Output with text label
OUTPUT="CPU:${CPU}%"

# Cache the result
echo "$OUTPUT" | tee "$CACHE_FILE"
