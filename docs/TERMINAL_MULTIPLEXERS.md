# Terminal Multiplexer Configuration

## Overview

This dotfiles repository supports two terminal multiplexers:
- **tmux**: Traditional, mature multiplexer (default)
- **Zellij**: Modern Rust-based multiplexer with built-in UI

You can switch between them seamlessly using the `switch-multiplexer` command.

## Installation

Both multiplexers are included in the Brewfile:
```bash
brew bundle --file=~/.Brewfile
```

## Switching Multiplexers

### Command Usage

```bash
# Show current multiplexer
switch-multiplexer

# Switch to tmux
switch-multiplexer tmux

# Switch to zellij
switch-multiplexer zellij
```

### What Happens

1. Updates `.chezmoi.toml.tmpl` with your choice
2. Regenerates chezmoi configuration
3. Prompts you to restart your shell

After restart, you can use your chosen multiplexer.

## tmux Configuration

### Current Setup

Your tmux configuration includes:
- Custom status bar with system metrics
- Claude Code usage tracking
- Green theme
- 15-second refresh interval
- **Custom prefix: Ctrl+g** (instead of default Ctrl+b)
- **Custom split keys: \ and -** (instead of default % and ")
- Vi-mode copy bindings (v for selection, y for copy)

### Key Bindings (Custom)

**Prefix: `Ctrl+g`** (custom, not standard Ctrl+b)

Common commands:
```bash
# Sessions
tmux new -s <name>          # Create new session
tmux attach -t <name>       # Attach to session
tmux ls                     # List sessions

# Windows
Ctrl+g c                    # Create window
Ctrl+g n                    # Next window
Ctrl+g p                    # Previous window
Ctrl+g ,                    # Rename window

# Panes (custom split keys)
Ctrl+g \                    # Split horizontally (custom: \ instead of %)
Ctrl+g -                    # Split vertically (custom: - instead of ")
Ctrl+g h/j/k/l              # Navigate panes (vi-style)
Ctrl+g Ctrl+h/j/k/l         # Resize panes (repeatable)
Ctrl+g x                    # Close pane
Ctrl+g z                    # Zoom/unzoom pane

# Copy mode (vi-mode)
Ctrl+g [                    # Enter copy mode
v                           # Begin selection
y                           # Copy selection
Ctrl+g ]                    # Paste

# Plugins
Ctrl+g /                    # tmux-jump (search)
Ctrl+g m                    # tmux-menus
Ctrl+g Ctrl+r               # tmux-resurrect restore
```

### Custom Functions

```bash
tm <name>      # Alias for tmux attach/new
tma            # Attach to last session
tml            # List sessions
twk            # Kill current window
```

## Zellij Configuration

### Key Features

- **Built-in UI**: Keybinding hints displayed in status bar
- **Modern defaults**: Sensible out-of-the-box configuration
- **Plugin system**: WebAssembly-based plugins
- **Session management**: Automatic session persistence
- **Custom tmux-compatible keybindings**: Matches your custom tmux config

### Key Bindings (Custom tmux-compatible)

**Prefix: `Ctrl+g`** (matching your custom tmux config)

The zellij configuration has been customized to match your tmux keybindings:

```bash
# Sessions
zellij                      # Start/attach to session
zellij attach <name>        # Attach to specific session
zellij ls                   # List sessions

# In Zellij (tmux mode with Ctrl+g prefix)
Ctrl+g c                    # New pane
Ctrl+g \                    # Split horizontally (matching tmux)
Ctrl+g -                    # Split vertically (matching tmux)
Ctrl+g h/j/k/l              # Navigate panes (vi-style)
Ctrl+g Ctrl+h/j/k/l         # Resize panes (matching tmux)
Ctrl+g x                    # Close pane
Ctrl+g z                    # Zoom/unzoom pane
Ctrl+g d                    # Detach

# Tabs (like tmux windows)
Ctrl+g t                    # New tab
Ctrl+g n                    # Next tab
Ctrl+g p                    # Previous tab
Ctrl+g ,                    # Rename tab

# Copy mode (vi-mode, matching tmux)
Ctrl+g [                    # Enter scroll/copy mode
v                           # Begin selection
Space                       # Begin selection (alternative)
Enter                       # Copy selection

# Search (matching tmux-jump)
Ctrl+g /                    # Search in scrollback

# Session management
Ctrl+g w                    # Session menu
Ctrl+g Ctrl+r               # Session restore (future plugin)
```

### Quick Navigation (Alt shortcuts)

For convenience, these work without the Ctrl+g prefix:
```bash
Alt+h/j/k/l                 # Quick pane navigation
Alt+n                       # Quick new pane
Alt+=/-                     # Quick resize
```

### Configuration

The zellij config is already customized in `~/.config/zellij/config.kdl` to match your tmux keybindings:

```kdl
// Custom tmux-compatible keybindings (matching dot_tmux.conf)
keybinds {
    normal clear-defaults=true {
        bind "Ctrl g" { SwitchToMode "tmux"; }  // Matches your tmux prefix
    }
    tmux clear-defaults=true {
        bind "c" { NewPane; SwitchToMode "Normal"; }
        bind "\\" { NewPane "Right"; SwitchToMode "Normal"; }   // Matches tmux \
        bind "-" { NewPane "Down"; SwitchToMode "Normal"; }     // Matches tmux -
        bind "h" { MoveFocus "Left"; }                          // Vi-style navigation
        bind "Ctrl h" { Resize "Left"; }                        // Matches tmux resize
        bind "d" { Detach; }
    }
}

// Theme
theme "default"

// Simplified UI (matching tmux minimalism)
simplified_ui true
pane_frames false
default_layout "compact"
```

## Comparison

| Feature | tmux | Zellij |
|---------|------|--------|
| **Maturity** | 15+ years | 3 years |
| **Ecosystem** | Extensive | Growing |
| **Learning Curve** | Steep | Gentle |
| **UI** | Minimal | Built-in |
| **Configuration** | Shell/config | KDL format |
| **Plugins** | Limited | WebAssembly |
| **Performance** | Excellent | Excellent (Rust) |
| **Default Prefix** | Ctrl+g (custom) | Ctrl+g (matches tmux) |
| **Keybinding Discovery** | Manual | Built-in UI |
| **Session Persistence** | Manual save/restore | Automatic |

## Migration Tips

### From tmux to Zellij

**Good news**: Your zellij config already matches your tmux keybindings! The transition should be seamless.

1. **Same prefix**: Both use `Ctrl+g`
2. **Same split keys**: Both use `\` (horizontal) and `-` (vertical)
3. **Same navigation**: Both use `h/j/k/l` for panes
4. **Same resize**: Both use `Ctrl+h/j/k/l` for resizing

**Key concept differences**:
- Zellij: Panes can be floating
- Zellij: Sessions auto-resume (no need for tmux-resurrect)
- Zellij: Layouts are first-class
- Zellij: Built-in UI shows available commands

**Additional benefits**:
- Status bar shows keybinding hints
- Press `Ctrl+g ?` for inline help
- Automatic session persistence (no manual save/restore)

### From Zellij to tmux

**Seamless transition**: Since zellij matches your tmux config, switching back is natural.

**Same keybindings**:
- Prefix: `Ctrl+g` (both)
- Split: `\` and `-` (both)
- Navigate: `h/j/k/l` (both)
- Resize: `Ctrl+h/j/k/l` (both)

**Only differences**:
1. **Session persistence**: tmux requires manual save with `Ctrl+g Ctrl+r`
2. **Status bar**: tmux shows system metrics (CPU, RAM, Claude usage)
3. **Plugins**: tmux has tmux-jump, tmux-menus, extrakto available

## Recommendations

### Use tmux if:
- You have extensive tmux configuration
- You rely on specific tmux plugins
- You need maximum compatibility

### Try Zellij if:
- You're new to multiplexers
- You want modern defaults
- You prefer discoverable keybindings
- You're interested in Rust ecosystem

## Parallel Usage

You can use both multiplexers:

```bash
# tmux for production work
tmux attach -t work

# Zellij for experimentation
zellij attach experiments
```

The `switch-multiplexer` command only changes the default.

## Troubleshooting

### Zellij sessions not persisting
```bash
# Check Zellij data directory
ls ~/.local/share/zellij/

# Sessions are automatically saved
zellij attach <session-name>
```

### tmux status bar not showing
```bash
# Verify scripts are executable
ls -la ~/.local/bin/tmux-*

# Refresh tmux config
tmux source-file ~/.tmux.conf
```

### Keybindings conflict
```bash
# In Zellij, lock mode disables keybindings
Ctrl+g l    # Lock
Ctrl+g l    # Unlock

# In tmux, prefix key can be changed
# Edit ~/.tmux.conf: set -g prefix C-a
```

## Resources

- [tmux documentation](https://github.com/tmux/tmux/wiki)
- [Zellij documentation](https://zellij.dev/documentation/)
- [tmux Cheat Sheet](https://tmuxcheatsheet.com/)
- [Zellij Tutorial](https://zellij.dev/tutorials/)
