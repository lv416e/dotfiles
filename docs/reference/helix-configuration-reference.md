# Helix Editor Setup

## Overview

Helix is set up as an experimental editor for quick edits alongside Neovim. All LSP servers are managed via mise for unified tool management.

**Version**: helix 25.07.1

## Architecture

```
┌─────────────────────────────────────────────────────────┐
│                    Helix Editor                         │
│  - Selection-first editing (noun-verb model)            │
│  - Built-in LSP/tree-sitter                             │
│  - Tmux integration (Ctrl+t, Ctrl+h, Ctrl+l)           │
└─────────────────────────────────────────────────────────┘
                           │
                           │ languages.toml
                           ▼
┌─────────────────────────────────────────────────────────┐
│              Language Server Protocol (LSP)             │
│  Python    │ TypeScript │ Go      │ Rust    │ C/C++    │
│  pyright   │ ts-ls      │ gopls   │ rust-   │ clangd   │
│            │            │         │ analyzer│          │
└─────────────────────────────────────────────────────────┘
                           │
                           │ mise exec wrapper
                           ▼
┌─────────────────────────────────────────────────────────┐
│                  mise Tool Manager                      │
│  npm:typescript-language-server@5.0.1                  │
│  npm:pyright@1.1.407                                    │
│  go:golang.org/x/tools/gopls@latest                     │
│  ubi:clangd/clangd@21.1.0                               │
│  pipx:ruff@0.14.2                                       │
│  npm:prettier@3.6.2                                     │
└─────────────────────────────────────────────────────────┘
                           │
                           │ (rust-analyzer via rustup)
                           ▼
┌─────────────────────────────────────────────────────────┐
│              ~/.cargo/bin/rust-analyzer                 │
│  (installed via: rustup component add rust-analyzer)   │
└─────────────────────────────────────────────────────────┘
```

## LSP Server Configuration

### TypeScript/JavaScript
- **LSP**: typescript-language-server@5.0.1 (npm backend)
- **Formatter**: prettier@3.6.2 (npm backend)
- **Wrapper**: Uses `mise exec` to access npm-installed tools
- **Health**: ✓ All checks passing

```toml
[[language]]
name = "typescript"
language-servers = ["typescript-language-server"]
auto-format = true
formatter = { command = "sh", args = ["-c", "mise exec -- prettier --parser typescript"] }

[language-server.typescript-language-server]
command = "sh"
args = ["-c", "mise exec -- typescript-language-server --stdio"]
```

### Python
- **LSP**: pyright@1.1.407 (npm backend)
- **Formatter**: ruff@0.14.2 (pipx backend)
- **Wrapper**: Uses `mise exec` for both LSP and formatter
- **Health**: ✓ All checks passing

```toml
[[language]]
name = "python"
language-servers = ["pyright"]
auto-format = true
formatter = { command = "sh", args = ["-c", "mise exec -- ruff format -"] }

[language-server.pyright]
command = "sh"
args = ["-c", "mise exec -- pyright-langserver --stdio"]
```

### Go
- **LSP**: gopls@latest (go backend)
- **Formatter**: gofmt (built-in with Go)
- **Direct access**: Found via mise PATH at `~/.local/share/mise/installs/go/1.25.3/bin/gopls`
- **Health**: ✓ All checks passing including debug adapter (dlv)

```toml
[[language]]
name = "go"
language-servers = ["gopls"]
auto-format = true
formatter = { command = "gofmt" }

[language-server.gopls]
command = "gopls"
```

### Rust
- **LSP**: rust-analyzer (rustup component, NOT mise)
- **Installation**: `rustup component add rust-analyzer`
- **Location**: `~/.cargo/bin/rust-analyzer`
- **Health**: ✓ All checks passing including debug adapter (lldb-dap)

```toml
[[language]]
name = "rust"
language-servers = ["rust-analyzer"]
auto-format = true

[language-server.rust-analyzer]
command = "rust-analyzer"
```

**Note**: rust-analyzer is installed via rustup because the crates.io package is only a library, not an installable binary. Attempting to install via `cargo:rust-analyzer` will fail.

### C/C++
- **LSP**: clangd@21.1.0 (ubi backend - GitHub releases)
- **Installation**: Via mise from GitHub releases (not Homebrew)
- **Location**: Managed by mise, accessible via PATH
- **Health**: ✓ All checks passing including debug adapter (lldb-dap)

```toml
[[language]]
name = "cpp"
language-servers = ["clangd"]
auto-format = true

[language-server.clangd]
command = "clangd"
args = ["--background-index", "--clang-tidy", "--completion-style=detailed"]
```

## Key Technical Decisions

### mise exec Wrapper Strategy

npm and pipx-installed tools (TypeScript LSP, Python LSP, ruff) use a shell wrapper:

```toml
command = "sh"
args = ["-c", "mise exec -- <tool-name> <args>"]
```

**Why?**
- mise shims may not be in Helix's PATH at startup
- `mise exec` ensures tools are found via mise's internal resolution
- Portable across different shell configurations
- Works even if mise shims aren't activated in the environment

**Alternatives considered**:
- Direct paths: Too brittle, breaks on version changes
- Rely on PATH: Doesn't work reliably in all environments

### mise Backends Used

| Backend | Tools | Rationale |
|---------|-------|-----------|
| npm | typescript-language-server, pyright, prettier | Official distribution method |
| pipx | ruff | Python tool isolation |
| go | gopls | Official Go LSP distribution |
| ubi | clangd | GitHub releases (cross-platform) |
| rustup | rust-analyzer | Rust component, not cargo installable |

### Why Not All mise?

rust-analyzer is the only exception managed outside mise:
- Available as rustup component (official distribution)
- crates.io package is library-only, not installable via cargo
- rustup ensures version compatibility with Rust toolchain
- mise internally uses rustup for Rust anyway

## Configuration Files

All configuration files are managed by chezmoi:

### ~/.config/helix/config.toml
Main editor configuration:
- Theme: onedark
- Relative line numbers
- Auto-save enabled
- LSP features enabled (inlay hints, signatures)
- Tmux integration keybindings
- jk to exit insert mode

### ~/.config/helix/languages.toml
LSP and formatter configuration for all languages.

### ~/.config/mise/config.toml
Tool version management:
```toml
[tools]
# LSP Servers
"npm:typescript-language-server" = "latest"
"npm:typescript" = "latest"
"npm:pyright" = "latest"
"go:golang.org/x/tools/gopls" = "latest"
"ubi:clangd/clangd" = "latest"

# Formatters
"npm:prettier" = "latest"
"npm:@fsouza/prettierd" = "latest"
"pipx:ruff" = "latest"
```

### ~/.Brewfile
```ruby
brew "helix"  # Modern modal editor with built-in LSP/tree-sitter
```

## Usage

### Launch Helix
```bash
hx                    # Open Helix
hx file.py           # Open specific file
hx file1 file2       # Open multiple files
```

### Health Checks
```bash
hx --health python      # Check Python LSP setup
hx --health typescript  # Check TypeScript LSP setup
hx --health go          # Check Go LSP setup
hx --health rust        # Check Rust LSP setup
hx --health cpp         # Check C++ LSP setup
```

### Tmux Integration
- `Ctrl+t`: Open tmux pane below (30% height)
- `Ctrl+h`: Switch to left tmux pane
- `Ctrl+l`: Switch to right tmux pane
- `Ctrl+s`: Quick save

### Keybindings
- `jk` in insert mode: Exit to normal mode
- Standard Helix selection-first editing model

## Testing

All language servers verified with health checks:

```bash
$ hx --health python
Configured language servers:
  ✓ pyright: /bin/sh
Configured formatter:
  ✓ /bin/sh
Tree-sitter parser: ✓

$ hx --health typescript
Configured language servers:
  ✓ typescript-language-server: /bin/sh
Configured formatter:
  ✓ /bin/sh
Tree-sitter parser: ✓

$ hx --health go
Configured language servers:
  ✓ gopls: ~/.local/share/mise/installs/go/1.25.3/bin/gopls
Configured debug adapter:
  ✓ ~/.local/share/mise/installs/go/1.25.3/bin/dlv
Configured formatter:
  ✓ ~/.local/share/mise/installs/go/1.25.3/bin/gofmt
Tree-sitter parser: ✓

$ hx --health rust
Configured language servers:
  ✓ rust-analyzer: ~/.cargo/bin/rust-analyzer
Configured debug adapter:
  ✓ /opt/homebrew/opt/llvm/bin/lldb-dap
Tree-sitter parser: ✓

$ hx --health cpp
Configured language servers:
  ✓ clangd: /opt/homebrew/opt/llvm/bin/clangd
Configured debug adapter:
  ✓ /opt/homebrew/opt/llvm/bin/lldb-dap
Tree-sitter parser: ✓
```

## Maintenance

### Update LSP servers
```bash
mise upgrade              # Update all tools
mise outdated            # Check for outdated tools
```

### Update Helix
```bash
brew upgrade helix
```

### Reinstall LSP servers
```bash
mise install             # Install all tools from config.toml
```

### Troubleshooting

**LSP not found**:
```bash
# Check mise installation
mise ls | grep <tool-name>

# Check if tool is accessible
mise exec -- which <tool-name>

# Reinstall if needed
mise install npm:pyright
```

**Formatter not working**:
- Verify tool is installed: `mise ls | grep <formatter>`
- Check languages.toml uses `mise exec` wrapper
- Run health check: `hx --health <language>`

## Future Enhancements

Potential improvements:
- Add more language configurations (Lua, Shell, etc.)
- Configure debug adapters for more languages
- Add custom Helix themes
- Integrate with other development tools

## References

- [Helix Documentation](https://docs.helix-editor.com/)
- [mise Documentation](https://mise.jdx.dev/)
- [LSP Configuration](https://docs.helix-editor.com/languages.html)
