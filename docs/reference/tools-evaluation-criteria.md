# New Tools & Modern Alternatives

## Overview

This dotfiles repository now includes several modern CLI tools that enhance developer productivity:
- **Jujutsu (jj)**: Next-generation version control system
- **WezTerm**: Lua-configurable terminal emulator
- **Zellij**: Modern terminal multiplexer

All tools are added to the Brewfile and will be installed automatically.

## Jujutsu (jj) - Modern Git Alternative

### What is Jujutsu?

Jujutsu is a Git-compatible version control system developed by Google engineers. It provides:
- **Universal undo**: `jj undo` works for all operations
- **Branchless workflow**: No need to create branches explicitly
- **Conflict handling**: Conflicts can be committed and resolved later
- **History rewriting**: Safe and easy to rewrite commit history

### Key Advantage: Git Compatible

Jujutsu works **directly with Git repositories**. No migration required:
```bash
cd ~/.local/share/chezmoi
jj git init --colocate
```

Now you can use both `jj` and `git` commands in the same repository!

### Basic Commands

#### Setup
```bash
# Use jj with existing Git repo
jj git init --colocate

# Configure user
jj config set --user user.name "Your Name"
jj config set --user user.email "your@email.com"
```

#### Daily Workflow
```bash
# Create new change (like git commit but automatic)
jj new
# Edit files...
jj desc -m "Add new feature"

# Show changes
jj diff
jj status
jj log

# Undo last operation
jj undo

# Push to remote
jj git push
```

#### Advanced Features
```bash
# Edit a previous change
jj edit @--         # Edit parent change
# Make changes...
jj desc -m "Updated message"

# Squash changes
jj squash           # Merge current change into parent

# View operation history
jj op log

# Undo any operation
jj op undo <operation-id>
```

### Git vs jj Comparison

| Git Command | jj Command | Notes |
|-------------|------------|-------|
| `git add . && git commit -m "msg"` | `jj desc -m "msg"` | jj auto-tracks changes |
| `git checkout -b feature` | `jj new` | Automatic branch creation |
| `git rebase -i HEAD~3` | `jj edit @--` | Direct edit, no interactive mode |
| `git reset --hard HEAD~` | `jj undo` | Safe undo of last operation |
| `git reflog` | `jj op log` | Operation history |
| `git push` | `jj git push` | Push to Git remote |

### When to Use jj

**Try jj if you:**
- Frequently use `git rebase`
- Want safer history rewriting
- Need universal undo
- Work with stacked changes

**Stick with git if you:**
- Use Git LFS (not yet supported)
- Use submodules (not yet supported)
- Need `.gitattributes` (not yet supported)

### Learn More
- [jj documentation](https://jj-vcs.github.io/jj/)
- [Git comparison](https://jj-vcs.github.io/jj/latest/git-comparison/)
- [Tutorial](https://jj-vcs.github.io/jj/latest/tutorial/)

## WezTerm - Lua-Configurable Terminal

### What is WezTerm?

WezTerm is a GPU-accelerated terminal emulator with:
- **Lua configuration**: Infinitely customizable
- **SSH integration**: First-class remote workflows
- **Image support**: Kitty Graphics Protocol
- **Multiplexing**: Built-in tabs and panes

### Why WezTerm?

- **Alacritty/Kitty/Ghostty aesthetic**: Can be configured to look identical
- **More features**: SSH domains, remote multiplexing, Lua scripting
- **Cross-platform**: macOS, Linux, Windows

### Minimal Configuration

Create `~/.config/wezterm/wezterm.lua`:

```lua
local wezterm = require 'wezterm'
local config = {}

-- Minimal window decorations
config.window_decorations = "RESIZE"
config.enable_tab_bar = false

-- No padding (like Alacritty/Ghostty)
config.window_padding = {
  left = 0,
  right = 0,
  top = 0,
  bottom = 0,
}

-- Color scheme
config.color_scheme = 'Catppuccin Mocha'

-- Font (matches your current setup)
config.font = wezterm.font 'HackGen Console NF'
config.font_size = 13.0

-- GPU acceleration
config.front_end = "WebGpu"

return config
```

### Advanced Features

#### SSH Integration
```lua
config.ssh_domains = {
  {
    name = 'work-server',
    remote_address = 'server.example.com',
    username = 'user',
  },
}
```

Then: `wezterm connect work-server`

#### Dynamic Tab Titles
```lua
wezterm.on('update-right-status', function(window, pane)
  local cwd_uri = pane:get_current_working_dir()
  if cwd_uri then
    window:set_right_status(wezterm.format {
      { Text = cwd_uri.file_path },
    })
  end
end)
```

### WezTerm vs Current Terminals

| Feature | Alacritty | Kitty | Ghostty | WezTerm |
|---------|-----------|-------|---------|---------|
| **Config Language** | TOML | Config | Config | Lua |
| **SSH Integration** | No | Basic | No | Advanced |
| **Extensibility** | Low | Medium | Low | **Infinite** |
| **Image Support** | No | Yes | Yes | Yes |
| **Multiplexing** | No | Yes | Yes | Yes |
| **Startup Speed** | Fastest | Fast | Fast | Fast |

### Try It

```bash
# Launch WezTerm
wezterm

# Test SSH
wezterm ssh user@host

# Connect to SSH domain
wezterm connect <domain-name>
```

## Zellij - Modern Multiplexer

See [Terminal Multiplexers](terminal-multiplexers-comparison.md) for detailed information.

### Quick Start

```bash
# Launch Zellij
zellij

# Built-in UI shows keybindings
# Press Ctrl+g for prefix
# Status bar displays available commands
```

## Installation

All new tools are in the Brewfile:
```bash
brew bundle --file=~/.Brewfile
```

Or install individually:
```bash
brew install jj         # Jujutsu VCS
brew install wezterm    # Terminal emulator
brew install zellij     # Multiplexer
```

## Migration Path

### Low Risk: Try jj
```bash
# No migration needed - use alongside git
cd any-git-repo
jj git init --colocate

# Try jj commands
jj status
jj log

# Still works!
git status
git log
```

### Medium Risk: Try WezTerm
```bash
# Keep existing terminals
# Launch WezTerm for new windows
wezterm

# Configure to match current aesthetic
# Edit ~/.config/wezterm/wezterm.lua
```

### Reversible: Try Zellij
```bash
# Use switch-multiplexer to try
switch-multiplexer zellij

# Don't like it? Switch back
switch-multiplexer tmux
```

## Resources

- [Jujutsu documentation](https://jj-vcs.github.io/jj/)
- [WezTerm documentation](https://wezfurlong.org/wezterm/)
- [Zellij documentation](https://zellij.dev/)
