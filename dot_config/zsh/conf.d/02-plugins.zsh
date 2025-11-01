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
  if [[ ! -r "$_sheldon_cache" || "$_sheldon_toml" -nt "$_sheldon_cache" ]]; then
    mkdir -p "${_sheldon_cache:h}"
    sheldon source > "$_sheldon_cache"
  fi
  source "$_sheldon_cache"
  unset _sheldon_cache _sheldon_toml
else
  echo "Warning: sheldon not found. Plugins will not be loaded." >&2
  echo "Install with: brew install sheldon" >&2
fi
