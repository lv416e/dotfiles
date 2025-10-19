# Nushell Configuration Guide

Modern, rich shell configuration with all your favorite zsh aliases and powerful Nushell-specific commands.

## 📋 Quick Reference

### Aliases (zsh-compatible)

#### Editor
- `v`, `vim`, `vi` → nvim

#### File Listing (eza variants)
- `e`, `l`, `ls` → eza with icons and git
- `ea`, `la` → eza all files
- `ee`, `ll` → eza long format with all details
- `et`, `lt` → eza tree (3 levels)
- `eta`, `lta` → eza tree all levels

#### Viewing Files
- `cat` → bat (syntax highlighting, no paging)
- `less` → bat (with paging)

#### Searching
- `grep` → ripgrep with smart case
- `find` → fd

#### Monitoring
- `top`, `bottom` → btm (bottom)
- `ps` → procs --tree

#### Directory Navigation
- `d` → cd ~/Documents
- `dot` → cd ~/.local/share/chezmoi
- `obs` → cd ~/Google Drive/My Drive/obsidian/
- `..` → cd ..
- `...` → cd ../..
- `..1` through `..4` → go up 1-4 levels

#### tmux Workspaces
- `twork`, `tw`, `twk` → tmux-work
- `tvim`, `tv` → tmux-nvim
- `tnu`, `tn` → tmux-nu (Nushell workspace)
- `tcc`, `tc` → tmux-claude

#### Git Shortcuts
- `gs` → git status
- `ga` → git add
- `gc` → git commit
- `gp` → git push
- `gl` → git log (pretty)
- `gd` → git diff
- `lg` → gitui (TUI)
- `ld` → lazydocker

#### chezmoi
- `cdot` → chezmoi cd
- `adot` → chezmoi apply
- `vzsh` → edit .zshrc
- `vbrew` → edit Brewfile
- `vnu` → edit config.nu

#### System Utilities
- `c` → clear
- `cl` → tty-clock
- `du` → dust
- `df` → duf
- `rm` → trash (safe delete)
- `tenki` → weather in Tokyo

---

## 🎯 History Commands

| Command | Description |
|---------|-------------|
| `h1` | Show last 100 history entries with syntax highlighting |
| `h10` | Show last 1000 history entries |
| `hs <pattern>` | Search history by pattern |

**Examples:**
```nu
h1                    # Recent commands
h10                   # Extended history
hs "git"              # All git commands in history
```

---

## 🚀 Nushell Power Commands

### File Operations

| Command | Description | Example |
|---------|-------------|---------|
| `lss <pattern>` | List files matching pattern | `lss "*.rs"` |
| `lsd` | List only directories | `lsd` |
| `lsf` | List only files | `lsf` |
| `largest [n]` | Show n largest files (default: 10) | `largest 5` |
| `newest [n]` | Show n newest files | `newest 20` |
| `oldest [n]` | Show n oldest files | `oldest 10` |
| `dirsize` | Total size of current directory | `dirsize` |
| `count-ext` | Count files by extension | `count-ext` |
| `ff <pattern>` | Find files by name (fuzzy) | `ff "config"` |
| `fft <pattern> <type>` | Find by name and type | `fft "test" "file"` |

**Examples:**
```nu
largest 10            # 10 biggest files
newest 5              # 5 most recent files
lss "*.toml"          # All TOML files
count-ext             # File type distribution
```

### Git Enhanced Commands

| Command | Description | Example |
|---------|-------------|---------|
| `gstat` | Git status with clean output | `gstat` |
| `glog [n]` | Pretty git log (default: 10) | `glog 20` |
| `gbr` | Git branch with details | `gbr` |
| `gcom <msg>` | Add all & commit with message | `gcom "fix: bug"` |
| `gpush` | Push with upstream | `gpush` |
| `gcl <repo>` | Clone and cd into repo | `gcl https://github.com/user/repo` |

**Examples:**
```nu
gstat                 # Quick status check
glog 5                # Last 5 commits
gcom "feat: add feature"  # Quick commit
gpush                 # Push to origin
```

### Directory Operations

| Command | Description | Example |
|---------|-------------|---------|
| `mkcd <dir>` | Create directory and cd into it | `mkcd test-project` |
| `j <dir>` | Smart jump to directory (zoxide) | `j docs` |

**Examples:**
```nu
mkcd new-project      # Create and enter
j documents           # Jump to Documents
```

### System & Utilities

| Command | Description | Example |
|---------|-------------|---------|
| `sysinfo` | Show system information | `sysinfo` |
| `diskusage` | Show disk usage table | `diskusage` |
| `psg <pattern>` | Search processes | `psg "chrome"` |
| `find-large <size>` | Find files larger than size | `find-large 100MB` |
| `devupdate` | Update all dev tools | `devupdate` |

**Examples:**
```nu
sysinfo               # System overview
psg "node"            # Find node processes
find-large 1GB        # Files over 1GB
```

### Quick Notes

| Command | Description | Example |
|---------|-------------|---------|
| `note <text>` | Save a timestamped note | `note "Remember to..."` |
| `notes` | View last 20 notes | `notes` |

**Examples:**
```nu
note "Check deployment at 3pm"
note "Bug in auth module"
notes                 # View all notes
```

### Interactive

| Command | Description |
|---------|-------------|
| `pick` | Interactive file picker |

---

## 🔧 Tool Integrations

### mise
Automatic version switching for Node, Python, Go, Ruby, etc.
- Activates automatically when entering directories with `.mise.toml`

### zoxide
Smart directory jumping (replaces cd)
```nu
j documents           # Jump to Documents
j docs                # Fuzzy match
j pro                 # Jump to projects
```

### atuin
Magical shell history with sync
- Use `Ctrl+R` for interactive history search
- Syncs history across machines

### starship
Fast, customizable prompt
- Shows git status, current directory, etc.
- Configured via ~/.config/starship.toml

---

## 💡 Pro Tips

### Data Processing
```nu
# Find all Rust files and sum their sizes
ls **/*.rs | get size | math sum

# List processes using more than 50% CPU
ps | where cpu > 50

# Count files by type
ls **/* | where type == file | group-by type | transpose key count

# Find duplicate file names
ls **/* | group-by name | where (($it | get count) > 1)
```

### Pipeline Magic
```nu
# Top 5 largest Rust files
ls **/*.rs | sort-by size | reverse | first 5

# All git repos in subdirectories
ls **/* | where name == ".git" | get name | path dirname

# Files modified in last 7 days
ls **/* | where modified > ((date now) - 7day)
```

### Git Workflows
```nu
# Quick commit and push
gcom "feat: add feature" ; gpush

# See what changed in last 3 commits
glog 3

# Branch overview
gbr
```

### History Search
```nu
# Find all npm commands
hs "npm"

# Find all git commit commands
hs "git commit"
```

---

## 🎨 Customization

### Add Your Own Commands

Edit `~/.config/nushell/config.nu`:

```nu
# Custom command example
def my-command [arg: string] {
    print $"Processing ($arg)..."
    # Your logic here
}
```

### Modify Aliases

```nu
# Add new alias
alias myalias = ^my-external-command

# Override existing alias
alias ls = ^eza --icons --long
```

### Change Keybindings

Edit the `keybindings` section in `config.nu`.

---

## 🆘 Help

### Built-in Help
```nu
help commands          # List all commands
help <command>         # Get help for specific command
help operators         # Learn about operators
```

### This Configuration
```nu
vnu                    # Edit config.nu
source $nu.config-path # Reload configuration
```

---

## 📚 Learn More

- [Nushell Book](https://www.nushell.sh/book/)
- [Nushell Cookbook](https://www.nushell.sh/cookbook/)
- [Command Reference](https://www.nushell.sh/commands/)

---

## 🎯 Quick Start Checklist

- [ ] Try `tn` to start Nushell workspace
- [ ] Use `twk` to verify alias works
- [ ] Test `largest 5` to see big files
- [ ] Try `gstat` for git status
- [ ] Use `j` to jump to directories
- [ ] Search history with `hs "git"`
- [ ] Take a note with `note "test"`
- [ ] Check system with `sysinfo`
- [ ] See all custom commands with `help commands`

Enjoy your modern, rich shell experience! 🚀
