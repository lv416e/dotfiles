# ADR-0008: Linux best-effort support strategy

## Status

Accepted

## Context

This dotfiles repository was designed primarily for macOS environments, with extensive use of macOS-specific tools (Hammerspoon, Raycast, macOS casks). However, there are scenarios where applying these dotfiles on Linux systems is beneficial:

- **DevContainer/Codespaces**: Cloud development environments typically run Ubuntu/Debian
- **Remote servers**: SSH into Linux machines for development work
- **Multi-platform workflows**: Working across personal Mac and company Linux machines

The challenge is maintaining macOS optimization while providing graceful degradation on Linux platforms, without duplicating configuration or adding significant maintenance overhead.

## Decision Drivers

- **YAGNI principle**: Avoid implementing unused Linux-specific features
- **Maintenance burden**: Single codebase easier than platform-specific branches
- **User experience**: Errors should not block Linux setup
- **DevContainer compatibility**: Enable cloud development workflows
- **Homebrew availability**: Homebrew works on Linux (via Linuxbrew)
- **macOS optimization**: Retain focus on primary platform

## Considered Options

1. **macOS-only strict** - Fail on non-macOS platforms
2. **Dual codebase** - Separate Brewfiles and configs for each OS
3. **Best-effort with fallback** - Conditional OS detection, skip incompatible items
4. **Full Linux parity** - Implement apt/dnf equivalents for all tools

## Decision Outcome

**Chosen option**: Best-effort with graceful degradation (Option 3)

Apply dotfiles on Linux where possible, silently skip macOS-specific components (primarily casks), and document limitations clearly.

### Implementation

**Brewfile OS detection** (dot_Brewfile.tmpl):
```ruby
# Formulae work cross-platform
brew "chezmoi"
brew "mise"
brew "gitui"
# ... 102 formulae total

{{- if eq .chezmoi.os "darwin" }}
# macOS-only casks (GUI applications, fonts, etc.)
# On Linux, these will be silently skipped
cask "alacritty"
cask "hammerspoon"
cask "raycast"
# ... 25 casks total
{{- end }}
```

**Container detection** (dot_install.sh):
```bash
if [ "${CODESPACES:-false}" = "true" ]; then
  CONTAINER_TYPE="codespaces"
elif [ "${REMOTE_CONTAINERS:-false}" = "true" ]; then
  CONTAINER_TYPE="devcontainer"
fi
```

### Positive Consequences

- **Single source of truth**: One Brewfile for all platforms
- **Minimal overhead**: Template adds 3 lines (if/end comments)
- **Silent failure**: Linux users don't see cask errors
- **DevContainer ready**: Works in GitHub Codespaces out-of-the-box
- **Maintainability**: Changes apply to both platforms automatically

### Negative Consequences

- **Limited Linux testing**: macOS remains primary development platform
- **No apt integration**: Linux users must manually install GUI apps
- **Partial feature parity**: Some workflows remain macOS-only
- **Documentation required**: Must explain limitations clearly

## Pros and Cons of the Options

### Option 1: macOS-only strict

**Pros:**
- Simplest implementation
- No cross-platform bugs
- Clear scope

**Cons:**
- DevContainer setup requires separate dotfiles
- Cannot use familiar config on Linux servers
- Fails loudly on non-macOS platforms

### Option 2: Dual codebase

**Pros:**
- Full platform optimization
- No compromises on either platform
- Clear separation of concerns

**Cons:**
- Double maintenance burden
- Configuration drift between platforms
- Testing complexity (need both environments)
- Against YAGNI principle (Linux is secondary use case)

### Option 3: Best-effort with fallback ✅

**Pros:**
- Single codebase
- Works on both platforms
- Minimal overhead
- Graceful degradation

**Cons:**
- Linux experience is degraded
- Requires OS detection logic
- Some features unavailable on Linux

### Option 4: Full Linux parity

**Pros:**
- Consistent experience across platforms
- Professional multi-platform support

**Cons:**
- Massive maintenance burden
- apt/dnf/pacman complexity
- Different package names per distro
- Overkill for personal dotfiles
- Violates YAGNI (not actually using Linux regularly)

## Compatibility Matrix

| Component | macOS | Linux | Notes |
|-----------|-------|-------|-------|
| **Shell (zsh)** | ✅ Full | ✅ Full | Cross-platform |
| **Brew formulae** | ✅ Full | ✅ Full | 102 CLI tools work |
| **Brew casks** | ✅ Full | ❌ Skip | macOS-only (25 apps) |
| **Hammerspoon** | ✅ Full | ❌ N/A | macOS automation |
| **Raycast** | ✅ Full | ❌ N/A | macOS launcher |
| **Git config** | ✅ Full | ✅ Full | Cross-platform |
| **mise** | ✅ Full | ✅ Full | Version manager |
| **Secrets (age/1Password)** | ✅ Full | ✅ CLI only | 1Password app macOS-only |
| **Terminal configs** | ✅ Full | ⚠️ Partial | Alacritty/Kitty work but via different install |
| **DevContainer** | ✅ Test | ✅ Primary | Linux environment |

## Documentation Requirements

Users must understand Linux limitations:

1. **new-machine-setup.md**: Document DevContainer/Codespaces workflow
2. **This ADR**: Explain design rationale and compatibility
3. **.chezmoiignore comments**: Clarify exclusions
4. **Brewfile.tmpl comments**: Explain OS detection

## Testing Strategy

**macOS testing** (primary):
```bash
chezmoi apply --dry-run
chezmoi apply
brew bundle --file=~/.Brewfile
```

**Linux simulation** (pre-deployment):
```bash
# Test template rendering
CHEZMOI_OS=linux chezmoi execute-template < dot_Brewfile.tmpl | grep -c cask
# Expected: 0 (casks excluded)
```

**DevContainer testing** (post-deployment):
- Create Codespace from repository
- Verify dotfiles applied successfully
- Confirm casks silently skipped
- Check core tools (zsh, git, mise) functional

## Future Considerations

**If** regular Linux usage increases, consider:
- apt-based fallbacks for essential casks (fonts, terminals)
- i3/sway configs (Linux window managers)
- Systemd user units (Linux service management)

**Current stance**: Wait for actual need before implementing. YAGNI.

## References

- [Homebrew on Linux documentation](https://docs.brew.sh/Homebrew-on-Linux)
- [chezmoi template variables](https://www.chezmoi.io/reference/templates/variables/)
- [GitHub Codespaces dotfiles](https://docs.github.com/en/codespaces/customizing-your-codespace/personalizing-github-codespaces-for-your-account#dotfiles)
- ADR-0006: Rust ecosystem adoption (similar platform compatibility considerations)

## Decision Date

2025-10-31
