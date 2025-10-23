# ============================================================================
# Plugin Management
# Description: zsh-autosuggestions configuration and Sheldon plugin loading
# Dependencies: sheldon, zsh-defer (loaded by sheldon)
# ============================================================================

# --- zsh-autosuggestions configuration ---
export ZSH_AUTOSUGGEST_MANUAL_REBIND=1
export ZSH_AUTOSUGGEST_USE_ASYNC=1
export ZSH_AUTOSUGGEST_BUFFER_MAX_SIZE=20

# --- sheldon (plugin manager with cache) ---
_sheldon_cache="${XDG_CACHE_HOME:-$HOME/.cache}/sheldon/sheldon.zsh"
_sheldon_toml="${XDG_CONFIG_HOME:-$HOME/.config}/sheldon/plugins.toml"
if [[ ! -r "$_sheldon_cache" || "$_sheldon_toml" -nt "$_sheldon_cache" ]]; then
  mkdir -p "${_sheldon_cache:h}"
  sheldon source > "$_sheldon_cache"
fi
source "$_sheldon_cache"
unset _sheldon_cache _sheldon_toml
