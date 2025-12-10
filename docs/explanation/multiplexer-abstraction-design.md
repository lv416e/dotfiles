# Multiplexer Abstraction Layer

This dotfiles repository includes a multiplexer abstraction layer that allows seamless switching between tmux and zellij without changing your workflow.

## Overview

The abstraction layer provides:
- **Automatic Detection**: Detects configured multiplexer from chezmoi config
- **Unified Interface**: Same commands work with tmux or zellij
- **Backward Compatibility**: All existing tmux-specific commands continue to work
- **Easy Switching**: One command to switch multiplexers system-wide

## Architecture

```
User Command (rt, mux-nvim, etc.)
         ↓
get-multiplexer() → reads ~/.config/chezmoi/chezmoi.toml
         ↓
    tmux or zellij?
         ↓
   ┌─────┴─────┐
   ↓           ↓
tmux-nvim   zellij layouts
  script      (nvim.kdl)
```

## Core Functions

### Multiplexer Detection

```bash
# Get configured multiplexer (returns "tmux" or "zellij")
get-multiplexer

# Check if inside a multiplexer
in-multiplexer && echo "Inside multiplexer"

# Get current multiplexer type
current-multiplexer  # Returns: tmux, zellij, or none
```

### Abstracted Commands

| Command | Description | tmux equivalent | zellij equivalent |
|---------|-------------|-----------------|-------------------|
| `mux-nvim` | Launch nvim workspace | `tmux-nvim` | `zellij --layout nvim` |
| `mux-claude` | Launch nvim+claude workspace | `tmux-claude` | `zellij --layout nvim-dual` |
| `mux-nu` | Launch nushell workspace | `tmux-nu` | `zellij --layout nu` |
| `mux-vim` | Launch docs/shell workspace | `tmux-vim` | `zellij --layout vim` |
| `mux-work` | Launch 6-pane work environment | `tmux-work` | `zellij --layout work` |
| `mux-repo` | Open repo in workspace | `tmux-repo` | Uses zellij layout |
| `mux-kill-window` | Close current window | `twk` | `zellij action close-tab` |

### Repository Commands

```bash
# Open repository with multiplexer (1 pane)
rt dotfiles              # Same as: repo -t dotfiles
repo -t my-project       # Same as: repo --tmux my-project
repo -m my-project       # New: explicit --mux flag

# Open repository with multiplexer (2 panes)
rt2 dotfiles             # Same as: repo -t2 dotfiles
repo -t2 my-project      # Dual pane layout
repo -m2 my-project      # New: explicit -m2 flag

# Direct mux-repo calls
mr dotfiles              # mux-repo dotfiles
mr2 my-project          # mux-repo --dual my-project
mux-repo my-project     # Full command
```

## Environment Variables

### Global Configuration

```bash
# Override multiplexer detection
export MULTIPLEXER=zellij

# Then use any command
rt dotfiles  # Will use zellij even if tmux is configured
```

### Workspace Configuration

These variables work with both tmux and zellij:

```bash
# Directory to open (default: $HOME/Documents)
LEFT_DIR=/path/to/project mux-nvim

# Number of top panes: 1 or 2 (default: 1)
TOP_PANES=2 mux-nvim my-project

# Claude monitor plan (default: max20)
CLAUDE_PLAN=max20 mux-nvim

# Session name (default: desk for tmux, auto for zellij)
SESSION_DEFAULT=work mux-nvim

# Combined example
LEFT_DIR=~/code/myapp TOP_PANES=2 CLAUDE_PLAN=max20 mux-nvim myapp
```

## Workspace Layouts

### tmux Layout (via tmux-nvim)

```
┌─────────────────────────────────┬──────────────────┐
│                                 │                  │
│         nvim (editor)           │   claude (opt)   │
│                                 │                  │
├──────────┬──────────────────────┴──────────────────┤
│  claude  │       gitui          │      btm         │
│ monitor  │   (git interface)    │   (monitor)      │
└──────────┴──────────────────────┴──────────────────┘
```

### Zellij Layout (nvim.kdl / nvim-dual.kdl)

Same visual layout as tmux, implemented using KDL configuration files:
- **nvim.kdl**: Single editor pane (TOP_PANES=1)
- **nvim-dual.kdl**: Dual panes with nvim + claude (TOP_PANES=2)

Both include:
- Tab bar (top)
- Status bar (bottom)
- 60% for editor, 40% for monitoring tools
- claude-monitor, gitui, btm in bottom section

## Usage Examples

### Basic Usage

```bash
# Workspace launchers (use configured multiplexer)
mux-nvim my-project     # nvim + monitoring tools
mux-claude my-project   # nvim + claude + monitoring
mux-nu my-project       # dual nushell + monitoring
mux-vim my-docs         # dual zsh + monitoring
mux-work my-work        # 6-pane professional environment

# Open repository with workspace
rt my-repo              # 1 pane
rt2 my-repo             # 2 panes (nvim + claude)

# Use shortcuts
mr my-repo              # mux-repo
mr2 my-repo             # mux-repo --dual
```

### Workspace Types

#### mux-nvim (Development)
- **Top**: nvim editor (or nvim + claude with TOP_PANES=2)
- **Bottom**: claude-monitor, gitui, btm
- **Best for**: Coding projects with git integration

#### mux-claude (AI-Assisted Development)
- **Top**: nvim + claude (always dual pane)
- **Bottom**: claude-monitor, gitui, btm
- **Best for**: AI-pair programming sessions

#### mux-nu (Nushell Development)
- **Top**: dual nushell panes
- **Bottom**: claude-monitor, btm, tty-clock
- **Best for**: Learning/using nushell

#### mux-vim (Documentation/Scripting)
- **Top**: dual zsh panes
- **Bottom**: claude-monitor, btm, tty-clock
- **Best for**: Writing docs, shell scripting

#### mux-work (Professional Environment)
- **Left**: 2 zsh panes (main + secondary)
- **Right Top**: ccusage watch (API usage tracking)
- **Right Mid**: claude-monitor
- **Right Bottom**: btm + tty-clock
- **Best for**: Professional work with monitoring

### Temporary Override

```bash
# Force zellij for one command
MULTIPLEXER=zellij mux-nvim my-project

# Force tmux for one command
MULTIPLEXER=tmux rt dotfiles
```

### Switching Default Multiplexer

```bash
# Show current multiplexer
switch-multiplexer
# Output: Current multiplexer: tmux

# Switch to zellij
switch-multiplexer zellij
# 1. Updates .chezmoi.toml.tmpl
# 2. Regenerates config
# 3. Applies terminal configs
# Now all mux-* commands will use zellij

# Switch back to tmux
switch-multiplexer tmux
```

## Migration from tmux-specific Commands

### Old Commands (still work!)

```bash
tmux-nvim my-project    # Still works (uses tmux)
tmux-claude my-project  # Still works (uses tmux)
tmux-nu my-project      # Still works (uses tmux)
tmux-vim my-docs        # Still works (uses tmux)
tmux-work my-work       # Still works (uses tmux)
tmux-repo dotfiles      # Deprecated warning, uses mux-repo
twk                     # Still works (uses tmux)
```

### New Commands (recommended)

```bash
mux-nvim my-project     # Multiplexer-agnostic
mux-claude my-project   # Multiplexer-agnostic
mux-nu my-project       # Multiplexer-agnostic
mux-vim my-docs         # Multiplexer-agnostic
mux-work my-work        # Multiplexer-agnostic
mux-repo dotfiles       # Multiplexer-agnostic
mux-kill-window         # Multiplexer-agnostic
```

### Benefits of Migration

1. **Flexibility**: Easy to try zellij without changing your workflow
2. **Consistency**: Same muscle memory works with both multiplexers
3. **Future-proof**: New multiplexers can be added easily
4. **No Lock-in**: Switch back to tmux anytime with one command

## Zellij-specific Features

When using zellij, you get additional benefits:

1. **Auto-session Persistence**: Sessions automatically save and restore
2. **Built-in UI**: Tab and status bars integrated into layout
3. **Floating Panes**: Can be added to layouts (not in current implementation)
4. **Layout Files**: Human-readable KDL format in `~/.config/zellij/layouts/`

## Troubleshooting

### Command not found: mux-nvim

```bash
# Ensure script is in PATH and executable
ls -l ~/.local/bin/mux-nvim
chmod +x ~/.local/bin/mux-nvim

# Reload shell
exec zsh
```

### Wrong multiplexer detected

```bash
# Check chezmoi config
cat ~/.config/chezmoi/chezmoi.toml | grep multiplexer

# If incorrect, run:
switch-multiplexer [tmux|zellij]
```

### Zellij layout not found

```bash
# Check layouts exist
ls ~/.config/zellij/layouts/

# Should see: nvim.kdl, nvim-dual.kdl

# If missing, apply chezmoi:
chezmoi apply ~/.config/zellij/layouts/
```

### Functions not available

```bash
# Reload zsh config
source ~/.config/zsh/conf.d/04-env.zsh
source ~/.config/zsh/conf.d/07-repo.zsh

# Or restart shell
exec zsh
```

## Implementation Details

### Files Modified

1. **dot_config/zsh/conf.d/04-env.zsh.tmpl**
   - Added multiplexer detection functions
   - Added `mux-kill-window()` abstraction

2. **dot_config/zsh/conf.d/07-repo.zsh**
   - Updated `repo()` to use `mux-nvim`
   - Renamed `tmux-repo()` to `mux-repo()`
   - Added deprecation warnings

3. **dot_config/zsh/conf.d/05-aliases.zsh**
   - Updated comments
   - Added `mr`, `mr2` aliases

4. **dot_local/bin/executable_mux-nvim**
   - New wrapper script
   - Routes to tmux-nvim or zellij layouts

5. **dot_config/zellij/layouts/**
   - **nvim.kdl**: Single-pane workspace
   - **nvim-dual.kdl**: Dual-pane workspace

### Design Decisions

1. **Backward Compatibility**: All `tmux-*` commands still work
2. **Opt-in Migration**: Users can migrate gradually
3. **Environment Override**: `MULTIPLEXER` env var for flexibility
4. **Same Interface**: Minimal learning curve for new commands
5. **Config-driven**: Detection from chezmoi config, not hardcoded

## Future Enhancements

Possible future improvements:

- [ ] Add more layout options (3-pane, 4-pane, etc.)
- [ ] Support for window/tab management abstractions
- [ ] Session management abstractions
- [ ] Copy mode abstractions
- [ ] Plugin system for custom layouts
- [ ] Auto-detect based on running multiplexer (fallback)

## Related Documentation

- [Terminal Multiplexers](../reference/terminal-multiplexers-comparison.md) - tmux vs zellij comparison
- [Keybindings Reference](../reference/keybindings-reference.md) - Quick reference
- [Repository Management](../dot_config/zsh/conf.d/07-repo.zsh) - repo command details
