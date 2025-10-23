# ============================================================================
# Aliases
# Description: All shell aliases for productivity
# Dependencies: nvim, eza, bat, rg, btm, dust, duf, procs, trash, tmux, chezmoi
# ============================================================================

# --- Editor ---
alias vim='nvim'
alias vi='nvim'
alias v='nvim'

# --- File operations (eza) ---
alias e='eza --icons --git --sort=type'
alias l=e
alias ls=e
alias ea='eza -a --icons --git --sort=type'
alias la=ea
alias ee='eza -aahl --icons --git --sort=type'
alias ll=ee
alias et='eza -T -L 3 -a -I "node_modules|.git|.cache" --icons --sort=type'
alias lt=et
alias eta='eza -T -a -I "node_modules|.git|.cache" --color=always --icons --sort=type | less -r'
alias lta=eta

# --- Modern CLI tools ---
alias cat='bat --paging=never'
alias less='bat'
alias grep='rg -S'
alias -g G='| rg -S'
alias top='btm'
alias bottom='btm'
alias du='dust'
alias df='duf'
alias ps='procs --tree'
alias rm='trash'

# --- Navigation ---
alias d='cd ~/Documents'
alias dot='cd ~/.local/share/chezmoi'
alias obs='cd ~/Google\ Drive/My\ Drive/obsidian/'
alias ..1='cd ../'
alias ..2='cd ../../'
alias ..3='cd ../../../'
alias ..4='cd ../../../../'

# --- History ---
alias h1='history -100 | tail -r | bat -l sh'
alias h10='history -1000 | tail -r | bat -l sh'

# --- Multiplexer Workspaces (abstracted) ---
alias twork='mux-work'       # Multiplexer-agnostic (was tmux-work)
alias tw='mux-work'          # Short form
alias tcc='mux-claude'       # Multiplexer-agnostic (was tmux-claude)
alias tc='mux-claude'        # Short form
alias tvim='mux-nvim'        # Multiplexer-agnostic (was tmux-nvim)
alias tv='mux-nvim'          # Short form
alias tnu='mux-nu'           # Multiplexer-agnostic (was tmux-nu)
alias tn='mux-nu'            # Short form
alias twk='mux-kill-window'  # Multiplexer-agnostic window kill

# --- Tmux-specific (when you explicitly need tmux) ---
alias tmux-health='tmux list-panes -a -F "Pane #{pane_id}: #{history_size}/#{history_limit} lines"'

# --- Nushell ---
alias nu='nu'
alias nuscript='nu -c'
alias vnu='chezmoi edit ~/.config/nushell/config.nu'

# --- Chezmoi ---
alias vzsh='chezmoi edit ~/.zshrc'
alias vbrew='chezmoi edit ~/.Brewfile'
alias szsh='source ~/.zshrc'
alias cdot='chezmoi cd'
alias adot='chezmoi apply'

# --- Claude Code ---
alias ai='claude'

# --- Git ---
alias lg='gitui'
alias ld='lazydocker'

# --- Repository shortcuts ---
# These now use mux-nvim (multiplexer-agnostic)
alias rt='repo -t'          # repo with multiplexer (1 pane)
alias rt2='repo -t2'        # repo with multiplexer (2 panes)
alias rtd='repo -t2'        # repo with multiplexer (dual panes)
alias mr='mux-repo'         # direct mux-repo call
alias mr2='mux-repo --dual' # direct mux-repo call (2 panes)

# --- Misc ---
alias c='clear'
alias cl='tty-clock -sc'
alias tenki='http wttr.in/Tokyo'
alias zsh-bench='for i in $(seq 1 20); do time zsh -i -c exit; done'
