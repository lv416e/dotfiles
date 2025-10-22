#!/usr/bin/env bash
# Lightweight RAM usage display for tmux status bar (macOS)
set -euo pipefail

# Get memory info from vm_stat
VM_STAT=$(vm_stat)

# Get page size (usually 4096 bytes)
PAGE_SIZE=$(pagesize)

# Parse vm_stat output
PAGES_FREE=$(echo "$VM_STAT" | grep "Pages free" | awk '{print $3}' | tr -d '.')
PAGES_ACTIVE=$(echo "$VM_STAT" | grep "Pages active" | awk '{print $3}' | tr -d '.')
PAGES_INACTIVE=$(echo "$VM_STAT" | grep "Pages inactive" | awk '{print $3}' | tr -d '.')
PAGES_SPECULATIVE=$(echo "$VM_STAT" | grep "Pages speculative" | awk '{print $3}' | tr -d '.')
PAGES_WIRED=$(echo "$VM_STAT" | grep "Pages wired down" | awk '{print $4}' | tr -d '.')

# Calculate used memory in GB
USED_PAGES=$((PAGES_ACTIVE + PAGES_INACTIVE + PAGES_WIRED))
USED_BYTES=$((USED_PAGES * PAGE_SIZE))
USED_GB=$(awk "BEGIN {printf \"%.1f\", $USED_BYTES / 1024 / 1024 / 1024}")

# Get total memory (in GB)
TOTAL_BYTES=$(sysctl -n hw.memsize)
TOTAL_GB=$(awk "BEGIN {printf \"%.0f\", $TOTAL_BYTES / 1024 / 1024 / 1024}")

# Calculate percentage
PERCENT=$(awk "BEGIN {printf \"%.0f\", ($USED_GB / $TOTAL_GB) * 100}")

# Output with emoji
if [[ $PERCENT -gt 80 ]]; then
  echo "🧠${USED_GB}G"
elif [[ $PERCENT -gt 60 ]]; then
  echo "📊${USED_GB}G"
else
  echo "💾${USED_GB}G"
fi
