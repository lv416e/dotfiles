#!/usr/bin/env bash
# Lightweight Claude Code usage display for tmux status bar
set -euo pipefail

# Ensure Homebrew binaries are in PATH
export PATH="/opt/homebrew/bin:/usr/local/bin:$PATH"

# Get ccusage path dynamically (mise-managed or system-wide)
if command -v ccusage &> /dev/null; then
  CCUSAGE="ccusage"
else
  # Fallback: search in mise installs directory
  CCUSAGE_DIR="${HOME}/.local/share/mise/installs/npm-ccusage"
  if [[ -d "$CCUSAGE_DIR" ]]; then
    # Find the latest version
    LATEST_VERSION=$(ls -1 "$CCUSAGE_DIR" | sort -V | tail -1)
    CCUSAGE="${CCUSAGE_DIR}/${LATEST_VERSION}/bin/ccusage"
  fi
fi

# Check if ccusage is available
if ! [[ -x "$CCUSAGE" ]] && ! command -v "$CCUSAGE" &> /dev/null; then
  echo "CLD:N/A"
  exit 0
fi

# Get today's usage (cached for 30 seconds - shorter for more frequent updates)
CACHE_FILE="/tmp/tmux-claude-usage.cache"
CACHE_MAX_AGE=30  # Reduced from 60 to 30 seconds for more frequent updates
UPDATE_LOCK="/tmp/tmux-claude-usage.lock"

# Handle background update request - must be checked BEFORE cache check
# to avoid infinite loop where background process also returns cached value
if [[ "${1:-}" == "--update-cache" ]]; then
  # This runs in background, so we can take our time
  # Skip cache check and force update by setting cache age to 0
  CACHE_MAX_AGE=0
  # Delete cache to force regeneration
  rm -f "$CACHE_FILE"
fi

# Check if cache exists and is valid
if [[ -f "$CACHE_FILE" ]]; then
  CACHE_AGE=$(( $(date +%s) - $(stat -f %m "$CACHE_FILE" 2>/dev/null || echo 0) ))
  CONTENT=$(cat "$CACHE_FILE" 2>/dev/null || echo "")

  # If cache is fresh, use it immediately
  if [[ $CACHE_AGE -lt $CACHE_MAX_AGE ]] && [[ -n "$CONTENT" ]] && [[ "$CONTENT" != "CLD:N/A" ]]; then
    echo "$CONTENT"
    exit 0
  fi

  # Cache is stale, but display old value while updating in background
  if [[ -n "$CONTENT" ]] && [[ "$CONTENT" != "CLD:N/A" ]]; then
    echo "$CONTENT"

    # Update cache in background if not already updating
    # Check lock file age - if older than 10 seconds, assume stale and remove
    if [[ -f "$UPDATE_LOCK" ]]; then
      LOCK_AGE=$(( $(date +%s) - $(stat -f %m "$UPDATE_LOCK" 2>/dev/null || echo 0) ))
      if [[ $LOCK_AGE -gt 10 ]]; then
        rm -f "$UPDATE_LOCK"
      fi
    fi

    if ! [[ -f "$UPDATE_LOCK" ]]; then
      (
        # Create lock file
        touch "$UPDATE_LOCK"

        # Update cache in background (no timeout needed - ccusage is fast)
        bash "$0" --update-cache >/dev/null 2>&1 || true

        # Remove lock file
        rm -f "$UPDATE_LOCK"
      ) &

      # Disown the background process so it doesn't block
      disown
    fi
    exit 0
  fi
fi

# Get today's date in the format ccusage uses (YYYY-MM-DD)
TODAY=$(date +%Y-%m-%d)

# Get JSON output - ccusage is fast enough that timeout isn't necessary
# The timeout command was causing issues in tmux environment
JSON_OUTPUT=$("$CCUSAGE" --today --json 2>/tmp/tmux-claude-usage.err || echo "")

# More robust empty check
if [[ -z "$JSON_OUTPUT" ]] || [[ "$JSON_OUTPUT" == "{}" ]] || ! echo "$JSON_OUTPUT" | grep -q '"daily"'; then
  # If we have old cache, keep using it even if expired
  if [[ -f "$CACHE_FILE" ]]; then
    OLD_CONTENT=$(cat "$CACHE_FILE" 2>/dev/null || echo "")
    if [[ -n "$OLD_CONTENT" ]] && [[ "$OLD_CONTENT" != "CLD:N/A" ]]; then
      echo "$OLD_CONTENT"
      exit 0
    fi
  fi

  # No valid cache, show N/A
  echo "CLD:N/A"
  exit 0
fi

# Check if jq is available for better JSON parsing
if ! command -v jq &> /dev/null; then
  echo "CLD:jq?" | tee "$CACHE_FILE"
  exit 0
fi

# Try to get today's data (tokens and cost)
TOKENS=$(echo "$JSON_OUTPUT" | jq -r ".daily[] | select(.date == \"$TODAY\") | .totalTokens" 2>/dev/null)
COST_USD=$(echo "$JSON_OUTPUT" | jq -r ".daily[] | select(.date == \"$TODAY\") | .totalCost" 2>/dev/null)

# If no data for today, get the most recent day's data
if [[ -z "$TOKENS" ]] || [[ "$TOKENS" == "null" ]]; then
  TOKENS=$(echo "$JSON_OUTPUT" | jq -r '.daily[-1].totalTokens' 2>/dev/null || echo "0")
  COST_USD=$(echo "$JSON_OUTPUT" | jq -r '.daily[-1].totalCost' 2>/dev/null || echo "0")
fi

# Validate that we got valid data
if [[ -z "$TOKENS" ]] || [[ "$TOKENS" == "null" ]] || [[ "$TOKENS" == "0" ]]; then
  echo "CLD:0"
  exit 0
fi

# Format cost (round to 2 decimal places)
COST_FORMATTED=$(awk "BEGIN {printf \"%.2f\", $COST_USD}")

# Format tokens (K for thousands, M for millions)
if [[ $TOKENS -ge 1000000 ]]; then
  TOKENS_M=$(awk "BEGIN {printf \"%.1f\", $TOKENS / 1000000}")
  TOKENS_FMT="${TOKENS_M}M"
elif [[ $TOKENS -ge 1000 ]]; then
  TOKENS_K=$(awk "BEGIN {printf \"%.0f\", $TOKENS / 1000}")
  TOKENS_FMT="${TOKENS_K}k"
else
  TOKENS_FMT="${TOKENS}"
fi

# Output format: CLD:13.9M/$8.98
OUTPUT="CLD:${TOKENS_FMT}/\$${COST_FORMATTED}"
echo "$OUTPUT" | tee "$CACHE_FILE"
