# ============================================================================
# Utility Functions (Deferred)
# Description: Helper functions for productivity
# Dependencies: navi, bat, ag, jq, gron, claude
# Note: Shell management functions (switch-*, zsh-refresh) are in 04-env.zsh
# ============================================================================

# ============================================================================
# Utilities
# ============================================================================

# Cheat sheet viewer (navi + tldr)
# Usage:
#   ch           - Interactive navi (all cheatsheets)
#   ch <command> - Interactive navi with query
#   cht <command> - Direct tldr lookup (non-interactive)
ch() {
  if [[ $# -eq 0 ]]; then
    navi
  else
    navi --query "$*"
  fi
}
# Direct tldr lookup (non-interactive)
cht() { navi --tldr "$*" }
# Legacy cheat implementation (uncomment if needed):
# ch() { cheat $* | bat -l sh }

# Code search with bat
agg() { ag $* | bat -l sh }

# JSON grep
jgrep() { jq | gron | grep $* | gron -u }

# History utilities
hg() { history -1000 | grep $* | tail -r | bat -l sh }
hc() { history -1000 | awk -v cmd="$1" '$1 == cmd { $1=""; sub(/^ +/, ""); print; exit }' | tr -d '\n' | pbcopy }

# Claude ask with multi-line support
ask() {
  if [[ $# -eq 0 ]]; then
    echo "Enter your prompt (press Ctrl+D on a new line to finish):"
    local input="$(cat)"
    [[ -n "$input" ]] && claude -p "$input"
  else
    claude -p "$*"
  fi
}

