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

### Key Bindings

Default prefix: `Ctrl+b`

Common commands:
```bash
# Sessions
tmux new -s <name>          # Create new session
tmux attach -t <name>       # Attach to session
tmux ls                     # List sessions

# Windows
Ctrl+b c                    # Create window
Ctrl+b n                    # Next window
Ctrl+b p                    # Previous window
Ctrl+b ,                    # Rename window

# Panes
Ctrl+b %                    # Split vertically
Ctrl+b "                    # Split horizontally
Ctrl+b arrow                # Navigate panes
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

### Key Bindings

Two modes available:

#### Normal Mode (Default)
- `Ctrl+g` prefix for commands
- Built-in help visible in status bar

#### tmux Mode (Optional)
- `Ctrl+b` prefix (familiar to tmux users)
- Configured in `~/.config/zellij/config.kdl`

### Basic Commands

```bash
# Sessions
zellij                      # Start/attach to session
zellij attach <name>        # Attach to specific session
zellij ls                   # List sessions

# In Zellij (Normal mode)
Ctrl+g n                    # New pane
Ctrl+g arrow                # Navigate panes
Ctrl+g t                    # New tab
Ctrl+g d                    # Detach
```

### Configuration

Create `~/.config/zellij/config.kdl` for customization:

```kdl
// tmux-compatible keybindings
keybinds {
    shared_except "locked" {
        bind "Ctrl b" { SwitchToMode "tmux"; }
    }
    tmux {
        bind "c" { NewPane; SwitchToMode "Normal"; }
        bind "\"" { NewPane "Down"; SwitchToMode "Normal"; }
        bind "%" { NewPane "Right"; SwitchToMode "Normal"; }
        bind "d" { Detach; }
    }
}

// Theme
theme "catppuccin-mocha"

// Simplified UI
simplified_ui true
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
| **Default Prefix** | Ctrl+b | Ctrl+g |
| **Keybinding Discovery** | Manual | Built-in UI |
| **Session Persistence** | Manual save/restore | Automatic |

## Migration Tips

### From tmux to Zellij

1. **Try tmux mode first**:
   ```kdl
   // In ~/.config/zellij/config.kdl
   keybinds {
       shared_except "locked" {
           bind "Ctrl b" { SwitchToMode "tmux"; }
       }
   }
   ```

2. **Gradually learn Zellij bindings**:
   - Status bar shows available commands
   - Press `Ctrl+g ?` for help

3. **Key concept differences**:
   - Zellij: Panes can be floating
   - Zellij: Sessions auto-resume
   - Zellij: Layouts are first-class

### From Zellij to tmux

1. **Relearn prefix**:
   - Zellij: `Ctrl+g`
   - tmux: `Ctrl+b`

2. **Manual session management**:
   ```bash
   # Detach: Ctrl+b d
   # Reattach: tmux attach
   ```

3. **Status bar configuration**:
   - Already configured in `.tmux.conf`
   - Custom scripts in `~/.local/bin/tmux-*`

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
