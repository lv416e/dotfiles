# ========================================
# Aliases Configuration
# ========================================
#
# zsh-compatible aliases with Nushell enhancements
# Loaded automatically at startup

# ===== Editor =====
alias v = ^nvim
alias vim = ^nvim
alias vi = ^nvim

# ===== File Listing (eza) =====
alias e = ^eza --icons --git --sort=type
alias l = ^eza --icons --git --sort=type
alias ls = ^eza --icons --git --sort=type
alias ea = ^eza -a --icons --git --sort=type
alias la = ^eza -a --icons --git --sort=type
alias ee = ^eza -aahl --icons --git --sort=type
alias ll = ^eza -aahl --icons --git --sort=type
alias et = ^eza -T -L 3 -a -I 'node_modules|.git|.cache' --icons --sort=type
alias lt = ^eza -T -L 3 -a -I 'node_modules|.git|.cache' --icons --sort=type
alias eta = ^eza -T -a -I 'node_modules|.git|.cache' --color=always --icons --sort=type
alias lta = ^eza -T -a -I 'node_modules|.git|.cache' --color=always --icons --sort=type

# ===== Monitoring =====
alias top = ^btm
alias bottom = ^btm

# ===== File Viewing =====
alias less = ^bat
alias cat = ^bat --paging=never

# ===== Search =====
alias grep = ^rg -S
alias rg = ^rg -S
alias find = ^fd

# ===== Directory Navigation =====
alias d = cd ~/Documents
alias dot = cd ~/.local/share/chezmoi
alias obs = cd "~/Google Drive/My Drive/obsidian/"
alias .. = cd ..
alias ... = cd ../..
alias ..1 = cd ..
alias ..2 = cd ../..
alias ..3 = cd ../../..
alias ..4 = cd ../../../..

# ===== System Utilities =====
alias c = clear
alias cl = ^tty-clock -sc
alias du = ^dust
alias df = ^duf
alias ps = ^procs --tree
alias rm = ^trash
alias tenki = ^http wttr.in/Tokyo

# ===== Multiplexer Workspaces (abstracted) =====
alias twork = ^mux-work
alias tvim = ^mux-nvim
alias tnu = ^mux-nu
alias tcc = ^mux-claude
alias tw = ^mux-work
alias tv = ^mux-nvim
alias tn = ^mux-nu
alias tc = ^mux-claude
alias twk = ^mux-kill-window

# ===== Git =====
alias gs = ^git status
alias ga = ^git add
alias gc = ^git commit
alias gp = ^git push
alias gl = ^git log --oneline --graph --decorate
alias gd = ^git diff
alias lg = ^gitui
alias ld = ^lazydocker

# ===== chezmoi =====
alias cdot = ^chezmoi cd
alias adot = ^chezmoi apply
alias vzsh = ^chezmoi edit ~/.zshrc
alias vbrew = ^chezmoi edit ~/.Brewfile
alias vnu = ^chezmoi edit ~/.config/nushell/config.nu

# ===== Modern CLI Tools (explicit) =====
alias dust = ^dust
alias duf = ^duf
alias bat = ^bat
alias fd = ^fd
alias procs = ^procs
alias trash = ^trash
alias eza = ^eza
