# New Machine Setup Guide

This guide explains how to set up a new macOS machine with this dotfiles repository.

## Prerequisites

1. **Install Homebrew** (if not already installed):
   ```bash
   /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
   ```

2. **Configure Git identity**:
   ```bash
   git config --global user.name "Your Name"
   git config --global user.email "your.email@example.com"
   ```

## Installation

### 1. Install chezmoi and initialize dotfiles

```bash
# Install chezmoi
brew install chezmoi

# Initialize with your dotfiles repository
chezmoi init --apply https://github.com/YOUR_USERNAME/dotfiles.git
```

### 2. Install Homebrew packages

```bash
# Navigate to dotfiles directory
cd ~/.local/share/chezmoi

# Install all Homebrew packages defined in Brewfile
brew bundle install
```

### 3. Install development tools with mise

```bash
# Mise should already be installed from Brewfile
# Install all tools defined in mise config
mise install

# Verify installation
mise ls
```

### 4. Set up tmux plugins

```bash
# Start tmux
tmux

# Inside tmux, press: Prefix (Ctrl+g) + I
# This will install all tmux plugins defined in .tmux.conf
```

### 5. Verify tmux status bar

The status bar should display:
- Claude Code usage and cost (CLD:X.XM/$X.XX)
- CPU usage (CPU:XX%)
- RAM usage (RAM:X.XG)
- Battery status (CHG/BAT/AC:XX%)
- Date and time

If Claude usage shows "CLD:N/A":
1. Ensure ccusage is installed: `which ccusage`
2. Try running: `ccusage --today`
3. Check logs: `cat /tmp/tmux-claude-usage.err`

## Dependencies for tmux Status Bar

All required dependencies are automatically installed:

### From Brewfile:
- `jq` - JSON parsing

### From mise config.toml:
- `npm:ccusage` - Claude Code usage tracker

### macOS built-in:
- `iostat` - CPU monitoring
- `vm_stat` - RAM monitoring
- `pmset` - Battery monitoring
- `timeout` - Command timeout utility

## Troubleshooting

### ccusage not found

If `ccusage` is not in PATH after mise installation:
```bash
# Activate mise in current shell
eval "$(mise activate zsh)"

# Or add to .zshrc (should already be there):
eval "$(mise activate zsh)"
```

### tmux status bar shows N/A

1. Check if scripts are executable:
   ```bash
   ls -l ~/.local/bin/tmux-*.sh
   ```

2. Test each script individually:
   ```bash
   ~/.local/bin/tmux-claude-usage.sh
   ~/.local/bin/tmux-cpu-usage.sh
   ~/.local/bin/tmux-ram-usage.sh
   ~/.local/bin/tmux-battery.sh
   ```

3. Clear cache and retry:
   ```bash
   rm /tmp/tmux-*-usage.cache
   tmux refresh-client -S
   ```

### Scripts have no execute permission

```bash
cd ~/.local/share/chezmoi
chezmoi apply --force
```

## Post-Installation

1. **Reload shell**:
   ```bash
   exec zsh
   ```

2. **Verify shell performance**:
   ```bash
   mise run sys-bench
   # or
   zsh-bench
   ```

3. **Test tmux setup**:
   ```bash
   tmux new -s test
   # Check if status bar displays correctly
   ```

## Notes

- The tmux status bar updates every 15 seconds
- Claude usage data is cached for 60 seconds to minimize API calls
- Scripts use background updates to prevent blocking tmux refresh
- First run may take 2-5 seconds to fetch Claude usage data
