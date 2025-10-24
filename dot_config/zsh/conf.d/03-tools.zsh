# ============================================================================
# Tool Configuration & Deferred Loading
# Description: FZF, completion system, and deferred tool initialization
# Dependencies: zsh-defer (from plugins), fzf, zoxide, atuin, mise
# ============================================================================

# --- mise shims (immediate, for non-interactive shells like Zellij) ---
# Must be loaded BEFORE zsh-defer to ensure tools are available immediately
# in non-interactive contexts (Zellij panes, IDEs, scripts)
# Only load if not already loaded by .zprofile (prevents 10ms duplicate execution)
if command -v mise >/dev/null 2>&1 && [[ -z "${MISE_SHELL:-}" ]]; then
  eval "$(mise activate zsh --shims)"
fi

# --- FZF configuration ---
# FZF environment variables deferred - set before key bindings load
# (saves ~1ms at startup)

# --- Completion system (cached, deferred) ---
_load_completion() {
  autoload -Uz compinit
  local _comp_path="${ZDOTDIR:-$HOME}/.zcompdump"
  if [[ -n $_comp_path(#qNmh-24) ]]; then
    compinit -C -u -d "$_comp_path"
  else
    compinit -u -d "$_comp_path"
  fi
}
zsh-defer _load_completion

# --- Deferred tool initialization ---
zsh-defer -c 'export _ZO_FZF_OPTS="--height 40% --layout=reverse --border --preview \"eza --icons --color=always {2..}\""'
zsh-defer -c 'eval "$(zoxide init --cmd j zsh)"'
zsh-defer -c 'eval "$(atuin init zsh)"'
# mise activate (full features) - deferred for interactive shells
# Note: mise shims are already loaded above for immediate PATH access
zsh-defer -c 'eval "$(mise activate zsh)"'

# --- FZF key bindings ---
if [[ -f "${HOMEBREW_PREFIX}/opt/fzf/shell/key-bindings.zsh" ]]; then
  zsh-defer -c 'export FZF_DEFAULT_COMMAND="fd --type f --hidden --follow --exclude .git"
export FZF_DEFAULT_OPTS="--height 40% --layout=reverse --border --preview \"bat --color=always --style=numbers --line-range=:500 {}\""
source "${HOMEBREW_PREFIX}/opt/fzf/shell/key-bindings.zsh"'
fi
if [[ -f "${HOMEBREW_PREFIX}/opt/fzf/shell/completion.zsh" ]]; then
  zsh-defer source "${HOMEBREW_PREFIX}/opt/fzf/shell/completion.zsh"
fi

# --- Amazon Q (deferred, optional) ---
# zsh-defer -c '[[ -f "${HOME}/Library/Application Support/amazon-q/shell/zshrc.pre.zsh" ]] && builtin source "${HOME}/Library/Application Support/amazon-q/shell/zshrc.pre.zsh"'
zsh-defer -c '[[ -f "${HOME}/Library/Application Support/amazon-q/shell/zshrc.post.zsh" ]] && builtin source "${HOME}/Library/Application Support/amazon-q/shell/zshrc.post.zsh"'
