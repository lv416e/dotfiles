# Zed Editor Configuration Guide

This guide explains how to configure Zed editor with 2025 best practices, integrated with your existing dotfiles workflow.

## Overview

Zed is a modern, GPU-accelerated code editor with built-in LSP support, vim mode, and collaboration features. This configuration focuses on:

- **Vim-first workflow** - Matching your Neovim muscle memory
- **LSP-powered development** - TypeScript, Python, Go, Rust, and more
- **Performance-oriented** - Minimal bloat, maximum speed
- **Consistent aesthetics** - Matching your existing terminal setup

## Quick Start

### Installation

Zed is already installed via Homebrew (from your Brewfile). If not:

```bash
brew install --cask zed
```

### Apply Configuration

```bash
# Apply all dotfiles (includes Zed configuration)
chezmoi apply

# Verify configuration
cat ~/.config/zed/settings.json
cat ~/.config/zed/keymap.json
```

### First Launch

1. Launch Zed: `open -a Zed` or `zed .` from terminal
2. Vim mode is automatically enabled
3. LSP servers auto-download on first use
4. Extensions can be installed via Settings → Extensions

## Configuration Files

### `~/.config/zed/settings.json`

Main configuration file with:

- **Vim mode** settings (clipboard, multiline find)
- **Editor appearance** (theme, fonts, UI density)
- **LSP configuration** (per-language settings)
- **Formatting** (format on save, indent guides)
- **Terminal integration** (zsh, font)
- **Performance** (auto-save, telemetry)

### `~/.config/zed/keymap.json`

Custom keybindings with:

- **Leader key patterns** (`space` as leader, matching Neovim)
- **File navigation** (fuzzy finder, project search)
- **LSP shortcuts** (go to definition, rename, code actions)
- **Window management** (vim-style splits)
- **Git integration** (blame, diff, hunks)

## Vim Mode

### Built-in Features

Zed has excellent vim mode with:

- Standard vim motions (`hjkl`, `w`, `b`, `e`, etc.)
- Visual mode (character, line, block)
- Text objects (`ciw`, `di"`, `va}`, etc.)
- Registers and macros
- Relative line numbers
- Search with `/` and `?`

### Custom Enhancements

#### Leader Key Mappings

```
<space>ff - Fuzzy file finder (like Telescope)
<space>fg - Project-wide grep (like live_grep)
<space>bb - Buffer/tab switcher
<space>e  - Toggle file tree
<space>o  - Toggle symbols outline
```

#### LSP Mappings

```
gd        - Go to definition
gt        - Go to type definition
gi        - Go to implementation
gr        - Find references
K         - Hover documentation
<space>rn - Rename symbol
<space>ca - Code actions
<space>fm - Format document
]d        - Next diagnostic
[d        - Previous diagnostic
```

#### Window Management

```
<C-w>v    - Split vertically
<C-w>s    - Split horizontally
<C-w>h/j/k/l - Navigate splits
<C-w>q    - Close split
```

## Language Support

### TypeScript/JavaScript

**LSP**: `typescript-language-server` (auto-installed)

**Settings**:
- Tab size: 2 spaces
- Formatter: Prettier
- Inlay hints enabled (parameter names, types)

**Usage**:
```typescript
// Hover over functions to see type info
// Rename variables with <space>rn
// Organize imports on save
```

### Python

**LSP**: `pyright` (auto-installed)

**Formatter**: `ruff` (from mise)

**Settings**:
- Tab size: 4 spaces
- Type checking: basic mode
- Diagnostics: workspace-wide

**Usage**:
```python
# Code actions for imports
# Format with ruff on save
# Jump to definitions across files
```

### Go

**LSP**: `gopls` (auto-installed)

**Formatter**: `gofmt` (built-in)

**Settings**:
- Hard tabs (standard Go style)
- Static analysis enabled
- Unused params detection

**Usage**:
```go
// Auto-imports on save
// Clippy lints on save
// Jump to interface implementations
```

### Rust

**LSP**: `rust-analyzer` (auto-installed)

**Formatter**: `rustfmt` (built-in)

**Settings**:
- Tab size: 4 spaces
- Cargo: all features enabled
- Check on save: clippy

**Usage**:
```rust
// Inlay type hints
// Macro expansion
// Crate graph navigation
```

### Shell Scripts

**Formatter**: `shfmt` (from mise)

**Settings**:
- Tab size: 2 spaces
- Format on save enabled

### Markdown

**Settings**:
- Tab size: 2 spaces
- Soft wrap at 80 characters
- Format on save

## Extensions

### Recommended Extensions

Install via: Settings → Extensions (`cmd-,` then Extensions tab)

**Language support**:
- Dockerfile
- TOML
- Just
- Prisma
- Tailwind CSS

**Utilities**:
- GitHub Copilot (if you use it)
- GitLens (enhanced git features)

**Themes** (optional):
- One Dark Pro
- Dracula
- Nord

### Managing Extensions

Extensions are managed per-user, not via dotfiles. This is intentional to allow flexibility across machines.

## Terminal Integration

### Opening Terminal

- `ctrl-`backtick`` - Toggle terminal panel
- `<space>tt` - Focus terminal

### Terminal Settings

- **Shell**: zsh (from your dotfiles)
- **Font**: SF Mono (macOS) / monospace (Linux)
- **Working directory**: Current project
- **Copy on select**: Disabled (vim muscle memory)

### Opening Zed from Terminal

```bash
# Open current directory
zed .

# Open specific file
zed path/to/file.ts

# Open and wait (for git editor)
zed --wait
```

## Git Integration

### Built-in Features

- **Inline blame** - See commit info in editor
- **Diff view** - Compare changes
- **Gutter indicators** - Modified/added/deleted lines

### Custom Keybindings

```
<space>gb - Toggle git blame
<space>gd - Toggle hunk diff
]h        - Next git hunk
[h        - Previous git hunk
```

### Git Editor

Set Zed as your git editor:

```bash
git config --global core.editor "zed --wait"
```

## Customization

### Changing Theme

Edit `~/.config/zed/settings.json`:

```json
{
  "theme": {
    "mode": "system",      // or "dark" or "light"
    "light": "One Light",
    "dark": "One Dark"     // Change to preferred dark theme
  }
}
```

Available themes:
- One Dark / One Light
- Solarized Dark / Light
- Dracula
- Nord
- Gruvbox
- Ayu (via extension)

### Changing Font

```json
{
  "buffer_font_family": "JetBrains Mono",  // or "Fira Code", "SF Mono"
  "buffer_font_size": 13
}
```

### Per-Language Settings

Add to `languages` section:

```json
{
  "languages": {
    "Python": {
      "tab_size": 4,
      "preferred_line_length": 88,  // Black default
      "format_on_save": "on"
    }
  }
}
```

### Custom Keybindings

Edit `~/.config/zed/keymap.json`:

```json
[
  {
    "context": "Editor && VimControl",
    "bindings": {
      "<your-key>": "<action>"
    }
  }
]
```

## Troubleshooting

### LSP Not Working

**Check LSP status**:
1. Open command palette: `cmd-shift-p`
2. Type "LSP Status"
3. View active language servers

**Restart LSP**:
1. Command palette → "LSP: Restart Language Server"

**Check logs**:
```bash
# View Zed logs
tail -f ~/Library/Logs/Zed/Zed.log
```

### Vim Mode Issues

**Reset vim state**:
- Press `<Esc>` multiple times
- Or `:` then `reset`

**Check vim mode status**:
- Bottom right shows current mode (NORMAL, INSERT, VISUAL)

### Performance Issues

**Disable features**:

```json
{
  "inlay_hints": {
    "enabled": false  // Disable if slowing down large files
  },
  "git": {
    "inline_blame": {
      "enabled": false  // Disable if slow on large repos
    }
  }
}
```

**Exclude directories**:

```json
{
  "file_scan_exclusions": [
    "**/node_modules",
    "**/target",
    "**/.git"
  ]
}
```

### Settings Not Applied

**Verify configuration location**:
```bash
# Settings should be at:
~/.config/zed/settings.json

# Keymaps should be at:
~/.config/zed/keymap.json
```

**Re-apply with chezmoi**:
```bash
chezmoi apply --force
```

**Check for JSON errors**:
- Open settings in Zed: `cmd-,`
- Look for error indicators (red squiggles)

## Workflow Tips

### Opening Projects

```bash
# Open in Zed
cd ~/projects/my-app
zed .

# From within Zed
# File → Open → Select directory
# Or: cmd-o
```

### Multi-Cursor Editing

```
<C-d>     - Select next occurrence (in visual mode)
<C-shift-up/down> - Add cursor above/below
```

### Fuzzy Navigation

```
cmd-p     - Fuzzy file finder
cmd-shift-f - Project-wide search
cmd-f     - Buffer search
```

### Code Navigation

```
gd        - Go to definition
<C-o>     - Jump back
<C-i>     - Jump forward
cmd-shift-o - Symbol search
```

### Refactoring

```
<space>rn - Rename symbol
<space>ca - Code actions
<space>fm - Format document
```

## Comparison: Zed vs Neovim

| Feature | Zed | Neovim (AstroNvim/LazyVim) |
|---------|-----|---------------------------|
| **Startup time** | ~50ms | ~100-200ms |
| **LSP setup** | Auto-download | Manual configuration |
| **Vim mode** | Built-in emulation | Native |
| **Collaboration** | Built-in | Requires plugins |
| **Customization** | JSON config | Lua scripting |
| **GPU acceleration** | Yes | No |
| **Extensions** | Growing ecosystem | Mature plugin ecosystem |

### When to Use Zed

- Quick edits and browsing
- Pair programming (built-in collab)
- Modern LSP experience out-of-box
- GPU-accelerated rendering

### When to Use Neovim

- Complex vim workflows (macros, advanced motions)
- Deep customization needs
- Terminal-only environments
- Mature plugin requirements

## Integration with Existing Workflow

### Use with tmux

```bash
# In tmux pane
zed .

# Or open in new window
tmux new-window "zed ."
```

### Use with Terminal

Zed has built-in terminal, but for complex workflows:

1. Keep tmux for terminal multiplexing
2. Use Zed for editing
3. Switch with `<C-w>` splits or `<C-backtick>` terminal

### Dotfiles Management

All Zed configuration is managed via chezmoi:

```bash
# Modify settings
$EDITOR ~/.local/share/chezmoi/dot_config/zed/settings.json.tmpl

# Apply changes
chezmoi apply

# Commit to git
chezmoi cd
git add dot_config/zed/
git commit -m "feat(zed): update configuration"
git push
```

## Advanced Features (2025)

### Inline Completions

Zed has built-in AI completions (disabled by default for privacy):

```json
{
  "features": {
    "copilot": true  // Enable if you use GitHub Copilot
  }
}
```

### Collaboration

**Start collaboration session**:
1. Command palette → "Collaborate"
2. Share link with collaborator
3. Real-time editing with presence

**Join session**:
1. Click shared link
2. Sign in with GitHub
3. Start editing together

### Multi-Buffer Editing

- Open multiple files side-by-side
- Sync scrolling across buffers
- Compare diffs

## Resources

### Official Documentation

- [Zed Documentation](https://zed.dev/docs)
- [Vim Mode Guide](https://zed.dev/docs/vim)
- [Key Bindings Reference](https://zed.dev/docs/key-bindings)
- [Language Support](https://zed.dev/docs/languages)

### Community

- [Zed GitHub](https://github.com/zed-industries/zed)
- [Zed Discord](https://discord.gg/zed)
- [Extension Registry](https://zed.dev/extensions)

### Related Documentation

- [Mise Tasks Reference](../reference/mise-tasks.md)
- [Neovim Configuration](./neovim-setup.md) (TODO)
- [Development Environment Setup](../getting-started/development-setup.md)

## See Also

- [Terminal Setup Guide](./terminal-setup.md)
- [Secrets Management](./secrets-management.md)
- [Configuration Variants](../explanation/configuration-variants.md)
