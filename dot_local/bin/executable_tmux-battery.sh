#!/usr/bin/env bash
# Lightweight battery status display for tmux status bar (macOS)
set -euo pipefail

# Get battery info from pmset
BATTERY_INFO=$(pmset -g batt 2>/dev/null)

# Check if battery exists (not all Macs have battery)
if ! echo "$BATTERY_INFO" | grep -q "InternalBattery"; then
  echo ""
  exit 0
fi

# Extract percentage
PERCENT=$(echo "$BATTERY_INFO" | grep -o '[0-9]*%' | tr -d '%' | head -1)

# Extract charging status
if echo "$BATTERY_INFO" | grep -q "AC Power"; then
  CHARGING="⚡"
elif echo "$BATTERY_INFO" | grep -q "charging"; then
  CHARGING="🔌"
else
  CHARGING=""
fi

# Select emoji based on battery level
if [[ $PERCENT -gt 80 ]]; then
  EMOJI="🔋"
elif [[ $PERCENT -gt 50 ]]; then
  EMOJI="🔋"
elif [[ $PERCENT -gt 20 ]]; then
  EMOJI="🪫"
else
  EMOJI="⚠️"
fi

# Output
if [[ -n "$CHARGING" ]]; then
  echo "${CHARGING}${PERCENT}%"
else
  echo "${EMOJI}${PERCENT}%"
fi
