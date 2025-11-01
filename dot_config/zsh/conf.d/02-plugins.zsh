# ============================================================================
# Plugin Management
# Description: zsh-autosuggestions configuration and Sheldon plugin loading
# Dependencies: sheldon, zsh-defer (loaded by sheldon)
# ============================================================================

# --- zsh-autosuggestions configuration ---
export ZSH_AUTOSUGGEST_MANUAL_REBIND=1
export ZSH_AUTOSUGGEST_USE_ASYNC=1
export ZSH_AUTOSUGGEST_BUFFER_MAX_SIZE=20
export ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=8'  # Gray color for suggestions
export ZSH_AUTOSUGGEST_STRATEGY=(history completion)

# --- sheldon (plugin manager with cache) ---
if command -v sheldon >/dev/null 2>&1; then
  _sheldon_cache="${XDG_CACHE_HOME:-$HOME/.cache}/sheldon/sheldon.zsh"
  _sheldon_toml="${XDG_CONFIG_HOME:-$HOME/.config}/sheldon/plugins.toml"

  # Regenerate cache if it doesn't exist, is older than config, or is empty
  if [[ ! -s "$_sheldon_cache" ]] || [[ "$_sheldon_toml" -nt "$_sheldon_cache" ]]; then
    mkdir -p "${_sheldon_cache:h}"
    if sheldon source > "$_sheldon_cache" 2>/dev/null; then
      # Verify cache was created and is not empty
      [[ -s "$_sheldon_cache" ]] || rm -f "$_sheldon_cache"
    fi
  fi

  # Source cache if it exists and is not empty
  if [[ -s "$_sheldon_cache" ]]; then
    source "$_sheldon_cache"
  else
    # Fallback: source directly without cache
    eval "$(sheldon source 2>/dev/null)"
  fi

  unset _sheldon_cache _sheldon_toml
else
  echo "Warning: sheldon not found. Plugins will not be loaded." >&2
  echo "Install with: brew install sheldon" >&2
fi
