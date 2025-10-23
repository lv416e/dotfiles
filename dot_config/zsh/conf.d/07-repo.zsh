# ============================================================================
# Repository Management
# Description: ghq-based repository navigation and multiplexer integration
# Dependencies: ghq, fzf, bat, eza, mux-nvim, zsh-defer (for completions)
# ============================================================================

# Repository navigation with fzf and multiplexer integration
repo() {
  local launch_mux=false
  local top_panes="${TOP_PANES:-1}"
  local repo_arg=""

  while [[ $# -gt 0 ]]; do
    case "$1" in
      --tmux|-t|--mux|-m)
        launch_mux=true
        shift
        ;;
      -t2|-m2)
        launch_mux=true
        top_panes=2
        shift
        ;;
      --dual)
        top_panes=2
        shift
        ;;
      *)
        repo_arg="$1"
        shift
        ;;
    esac
  done

  local repo=""

  if [ -n "$repo_arg" ]; then
    local matched=$(ghq list | grep -i "$repo_arg" | head -1)
    if [ -n "$matched" ]; then
      repo="$matched"
    else
      echo "No repository matching '$repo_arg' found" >&2
      echo "Available repositories:" >&2
      ghq list | grep -i "$repo_arg" >&2
      return 1
    fi
  else
    repo=$(ghq list | fzf --preview "bat --color=always --style=header,grid $(ghq root)/{}/README.md 2>/dev/null || eza -al --tree --level=2 $(ghq root)/{}")
  fi

  if [ -n "$repo" ]; then
    local repo_path=$(ghq root)/$repo

    if [ "$launch_mux" = true ]; then
      local repo_name=$(basename "$repo")
      LEFT_DIR="$repo_path" TOP_PANES="$top_panes" mux-nvim "$repo_name"
    else
      cd "$repo_path"
    fi
  fi
}

# Clone repository with ghq
clone() {
  if [ -z "$1" ]; then
    echo "Usage: clone <repo-url>" >&2
    echo "Example: clone github.com/anthropics/claude-code" >&2
    return 1
  fi
  ghq get "$1" && cd $(ghq root)/$(ghq list | tail -1)
}

# Repository navigation with multiplexer nvim workspace
# Opens repository in mux-nvim workspace
mux-repo() {
  local repo_path=""
  local repo_name=""
  local top_panes="${TOP_PANES:-1}"
  local repo_arg=""

  while [[ $# -gt 0 ]]; do
    case "$1" in
      --dual|-2)
        top_panes=2
        shift
        ;;
      *)
        repo_arg="$1"
        shift
        ;;
    esac
  done

  if [ -n "$repo_arg" ]; then
    local matched=$(ghq list | grep -i "$repo_arg" | head -1)
    if [ -n "$matched" ]; then
      repo_path=$(ghq root)/$matched
      repo_name=$(basename "$matched")
    else
      echo "No repository matching '$repo_arg' found" >&2
      return 1
    fi
  else
    local current_path=$(pwd)
    local ghq_root=$(ghq root)

    if [[ "$current_path" == "$ghq_root"* ]]; then
      repo_path="$current_path"
      repo_name=$(basename "$current_path")
    else
      local repo=$(ghq list | fzf --preview "bat --color=always --style=header,grid $(ghq root)/{}/README.md 2>/dev/null || eza -al --tree --level=2 $(ghq root)/{}")
      if [ -n "$repo" ]; then
        repo_path=$(ghq root)/$repo
        repo_name=$(basename "$repo")
      else
        return 0
      fi
    fi
  fi

  if [ -n "$repo_path" ]; then
    LEFT_DIR="$repo_path" TOP_PANES="$top_panes" mux-nvim "$repo_name"
  fi
}

# Deprecated: use mux-repo instead
tmux-repo() {
  echo "Warning: tmux-repo is deprecated, use mux-repo instead" >&2
  mux-repo "$@"
}

# Repository statistics
ghq-stats() {
  echo "Total repositories: $(ghq list | wc -l | tr -d ' ')"
  echo "GitHub: $(ghq list | grep github.com | wc -l | tr -d ' ')"
  echo "GitLab: $(ghq list | grep gitlab.com | wc -l | tr -d ' ')"
  echo "Bitbucket: $(ghq list | grep bitbucket.org | wc -l | tr -d ' ')"
  echo ""
  echo "Most recently updated repositories:"
  ghq list --full-path | head -5 | while read repo_path; do
    local last_commit=$(git -C "$repo_path" log -1 --format='%ar' 2>/dev/null || echo "unknown")
    echo "  $(basename $repo_path): $last_commit"
  done
}

# ============================================================================
# Completions
# ============================================================================

_repo() {
  _arguments \
    '(-t --tmux -m --mux)'{-t,--tmux,-m,--mux}'[Launch mux-nvim with 1 pane]' \
    '(-t2 -m2)'{-t2,-m2}'[Launch mux-nvim with 2 panes]' \
    '--dual[Use 2 panes layout]' \
    '1:repository:_repo_list'
}

_repo_list() {
  local -a repos
  repos=(${(f)"$(ghq list 2>/dev/null)"})
  _describe -t repos 'ghq repositories' repos
}

_register_repo_completion() {
  if (( $+functions[compdef] )); then
    compdef _repo repo
    compdef _repo rt
    compdef _repo rt2
    compdef _repo rtd
  fi
}
zsh-defer _register_repo_completion
