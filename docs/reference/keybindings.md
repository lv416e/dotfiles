# Keybindings Reference Card

Quick reference for tmux and zellij keybindings. Both have been configured to use identical keybindings for a seamless transition.

## Prefix Key

**Both tmux and zellij:** `Ctrl+g` (custom, not standard)

## Common Operations

| Action | tmux | Zellij | Notes |
|--------|------|--------|-------|
| **Enter command mode** | `Ctrl+g` | `Ctrl+g` | Both use same prefix |
| **Pass through prefix** | `Ctrl+g Ctrl+g` | `Ctrl+g Ctrl+g` | Send Ctrl+g to shell |

## Pane Management

| Action | Keybinding | tmux | Zellij |
|--------|------------|------|--------|
| **New pane/window** | `Ctrl+g c` | ✅ | ✅ |
| **Split horizontal** | `Ctrl+g \` | ✅ | ✅ |
| **Split vertical** | `Ctrl+g -` | ✅ | ✅ |
| **Close pane** | `Ctrl+g x` | ✅ | ✅ |
| **Zoom pane** | `Ctrl+g z` | ✅ | ✅ |

## Pane Navigation

| Action | Keybinding | tmux | Zellij |
|--------|------------|------|--------|
| **Move left** | `Ctrl+g h` | ✅ | ✅ |
| **Move down** | `Ctrl+g j` | ✅ | ✅ |
| **Move up** | `Ctrl+g k` | ✅ | ✅ |
| **Move right** | `Ctrl+g l` | ✅ | ✅ |

## Pane Resizing

| Action | Keybinding | tmux | Zellij |
|--------|------------|------|--------|
| **Resize left** | `Ctrl+g Ctrl+h` | ✅ (repeatable) | ✅ |
| **Resize down** | `Ctrl+g Ctrl+j` | ✅ (repeatable) | ✅ |
| **Resize up** | `Ctrl+g Ctrl+k` | ✅ (repeatable) | ✅ |
| **Resize right** | `Ctrl+g Ctrl+l` | ✅ (repeatable) | ✅ |
| **Resize mode** | `Ctrl+g r` | ❌ | ✅ |

## Window/Tab Management

| Action | Keybinding | tmux | Zellij |
|--------|------------|------|--------|
| **New window/tab** | `Ctrl+g t` | ❌ (use `c`) | ✅ |
| **Next window/tab** | `Ctrl+g n` | ✅ | ✅ |
| **Previous window/tab** | `Ctrl+g p` | ✅ | ✅ |
| **Rename window/tab** | `Ctrl+g ,` | ✅ | ✅ |
| **Close window/tab** | `Ctrl+g &` | ✅ | ✅ |
| **Go to window/tab 1-9** | `Ctrl+g 1-9` | ✅ | ✅ |

## Copy Mode

| Action | Keybinding | tmux | Zellij |
|--------|------------|------|--------|
| **Enter copy mode** | `Ctrl+g [` | ✅ | ✅ |
| **Begin selection** | `v` | ✅ (vi-mode) | ✅ |
| **Begin selection (alt)** | `Space` | ✅ | ✅ |
| **Copy selection** | `y` | ✅ (vi-mode) | ❌ (use Enter) |
| **Paste** | `Ctrl+g ]` | ✅ | ❌ (system clipboard) |
| **Rectangle toggle** | `Ctrl+v` | ✅ (vi-mode) | ❌ |

## Search

| Action | Keybinding | tmux | Zellij |
|--------|------------|------|--------|
| **Search/Jump** | `Ctrl+g /` | ✅ (tmux-jump) | ✅ (search) |

## Session Management

| Action | Keybinding | tmux | Zellij |
|--------|------------|------|--------|
| **Detach** | `Ctrl+g d` | ✅ | ✅ |
| **Session menu** | `Ctrl+g w` | ❌ | ✅ |
| **Save session** | `Ctrl+g Ctrl+r` | ✅ (resurrect) | ❌ (auto) |

## Special Features

| Action | Keybinding | tmux | Zellij |
|--------|------------|------|--------|
| **Menu** | `Ctrl+g m` | ✅ (tmux-menus) | ❌ |
| **Pane mode** | `Ctrl+g s` | ❌ | ✅ |
| **Lock mode** | `Ctrl+g g` | ❌ | ✅ |
| **Help** | `Ctrl+g ?` | ✅ (list keys) | ✅ (inline) |
| **Quit** | `Ctrl+g q` | ❌ | ✅ |

## Quick Actions (No Prefix)

Zellij provides Alt shortcuts for common actions without prefix:

| Action | Keybinding | tmux | Zellij |
|--------|------------|------|--------|
| **New pane** | `Alt+n` | ❌ | ✅ |
| **Move left** | `Alt+h` | ❌ | ✅ |
| **Move down** | `Alt+j` | ❌ | ✅ |
| **Move up** | `Alt+k` | ❌ | ✅ |
| **Move right** | `Alt+l` | ❌ | ✅ |
| **Resize increase** | `Alt+=` | ❌ | ✅ |
| **Resize decrease** | `Alt+-` | ❌ | ✅ |

## Key Differences

### tmux Only
- **Plugins**: tmux-jump, tmux-menus, tmux-resurrect, extrakto, tmux-yank
- **Status bar**: Custom scripts showing CPU, RAM, battery, Claude usage
- **Repeatable keys**: Resize commands can be repeated without re-entering prefix
- **Manual persistence**: Must save/restore sessions manually

### Zellij Only
- **Built-in UI**: Status bar shows available keybindings in each mode
- **Automatic persistence**: Sessions auto-save and restore
- **Floating panes**: Panes can float above others
- **Layouts**: First-class layout system
- **Quick actions**: Alt shortcuts for common operations
- **Modes**: Locked, pane, resize, search modes with dedicated keybindings

## Tips

### tmux
- Resize commands use `-r` flag for repeatability (press once, repeat without prefix)
- Vi-mode copy requires additional `y` to yank to tmux buffer
- Use `tmux-yank` plugin for clipboard integration
- Session restore requires `Ctrl+g Ctrl+r` after restart

### Zellij
- Press `Ctrl+g ?` in any mode to see available commands
- Status bar shows current mode and available keybindings
- Sessions auto-resume when you reconnect with same name
- Use `Esc` to exit any mode back to normal mode
- Copy directly goes to system clipboard (no paste command needed)

## Command-line Reference

### tmux
```bash
tmux                        # Start new session
tmux new -s <name>          # Start named session
tmux attach -t <name>       # Attach to session
tmux ls                     # List sessions
tmux kill-session -t <name> # Kill session
```

### Zellij
```bash
zellij                      # Start/attach to default session
zellij attach <name>        # Attach to named session
zellij attach -c            # Attach or create if doesn't exist
zellij ls                   # List sessions
zellij kill-session <name>  # Kill session
zellij delete-session <name> # Delete session data
```

## Configuration Files

- tmux: `~/.tmux.conf`
- Zellij: `~/.config/zellij/config.kdl`
- Switch multiplexer: `switch-multiplexer tmux|zellij`
- Config source: `.chezmoi.toml.tmpl` (multiplexer variable)
