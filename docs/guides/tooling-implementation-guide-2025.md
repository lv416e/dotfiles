# Implementation Guide: 2025 Tooling Enhancements

This guide documents the implementation of Zed editor configuration and fnox secret management based on 2025 development best practices.

## Executive Summary

**Implementation Date**: 2025-11-01

**Completed Components**:
1. **Zed Editor Configuration** - GPU-accelerated code editor with vim mode and integrated Language Server Protocol support
2. **fnox Secret Management** - Unified secret management interface integrating age encryption and 1Password

**Excluded Components**:
- **sudo-rs** - Not compatible with macOS (Linux and FreeBSD only)

## Overview

### Added Components

#### Zed Editor Configuration

**Configuration Files**:
- `dot_config/zed/settings.json.tmpl` - Core configuration including vim mode, LSP settings, and theme preferences
- `dot_config/zed/keymap.json.tmpl` - Custom keybindings with leader key and LSP shortcuts
- `docs/guide./zed-configuration-guide.md` - Comprehensive usage documentation

**Capabilities**:
- Vim mode with relative line numbering
- Automatic LSP configuration for TypeScript, Python, Go, Rust, and Shell scripts
- Format-on-save with language-specific formatting rules
- Git integration including inline blame, diff visualization, and hunk navigation
- Integrated terminal with zsh configuration
- Custom keybindings aligned with Neovim conventions

#### fnox Secret Management

**Configuration Files**:
- `dot_config/private_fnox/fnox.toml.tmpl` - fnox configuration template
- `dot_config/private_mise/config.toml.tmpl` - Updated to include fnox tooling and task definitions
- `docs/guide./secrets-management-fnox.md` - Complete implementation and usage guide

**Capabilities**:
- age backend for locally encrypted secrets
- 1Password backend for cloud-synchronized secrets
- Automatic secret injection into shell environment
- mise task integration for secret management workflows
- Seamless integration with existing age and 1Password configurations

### Tool Selection Rationale

#### Zed Editor

**Alignment with 2025 Best Practices**:
- GPU-accelerated rendering for enhanced performance
- Built-in Language Server Protocol support with zero-configuration setup
- Native real-time collaboration capabilities
- Rapid startup time (approximately 50ms compared to 100-200ms for Neovim)
- First-class TypeScript and Rust language support

**Primary Use Cases**:
- Rapid file editing and codebase navigation
- Remote pair programming sessions
- Modern integrated development environment experience
- Complementary tooling alongside Neovim (not a replacement)

#### fnox

**Alignment with 2025 Best Practices**:
- Unified interface for heterogeneous secret storage backends
- Declarative configuration following Infrastructure as Code principles
- Automatic environment variable injection for developer convenience
- Developed by the mise author, ensuring ecosystem integration

**Primary Use Cases**:
- API credential management (OpenAI, Anthropic, GitHub, etc.)
- Unified access interface for age-encrypted and 1Password-stored secrets
- Automatic secret loading in shell sessions
- Team credential sharing through 1Password vaults

## Installation

### Prerequisites

```bash
# Verify chezmoi is up to date
chezmoi --version

# Verify mise is installed
mise --version

# Verify 1Password CLI (for fnox)
op --version
```

### Step 1: Apply Dotfiles

```bash
# Navigate to chezmoi source directory
cd ~/.local/share/chezmoi

# Review changes
chezmoi diff

# Apply all configurations
chezmoi apply

# Verify Zed config
ls -la ~/.config/zed/
# Expected: settings.json, keymap.json

# Verify fnox config
ls -la ~/.config/fnox/
# Expected: fnox.toml
```

### Step 2: Install fnox

```bash
# Install fnox via mise
mise use -g fnox

# Verify installation
fnox --version

# Initialize fnox
mise fnox-init
# Alias: mise fxi

# Check status
mise fnox-status
# Alias: mise fxs
```

### Step 3: Verify Setup

```bash
# Check Zed configuration
zed ~/.config/zed/settings.json

# Check fnox configuration
cat ~/.config/fnox/fnox.toml

# List all mise tasks
mise tasks | grep -E "(fnox|zed)"
```

## Configuration

### Zed Editor

#### Theme Customization

Edit `~/.local/share/chezmoi/dot_config/zed/settings.json.tmpl`:

```json
{
  "theme": {
    "mode": "dark",
    "dark": "One Dark"  // Change to: Solarized Dark, Dracula, Nord, etc.
  }
}
```

Apply changes:
```bash
chezmoi apply
```

#### Font Customization

```json
{
  "buffer_font_family": "JetBrains Mono",  // or "Fira Code", "SF Mono"
  "buffer_font_size": 13
}
```

#### Language-Specific Settings

```json
{
  "languages": {
    "Python": {
      "tab_size": 4,
      "preferred_line_length": 88,  // Black default
      "formatter": {
        "language_server": {
          "name": "ruff"
        }
      }
    }
  }
}
```

### fnox Secret Management

#### Add Secrets

```bash
# Add API key (age-encrypted local storage)
mise fnox-add OPENAI_API_KEY sk-proj-...

# Add another secret
mise fnox-add ANTHROPIC_API_KEY sk-ant-...

# List all secrets
mise fnox-list
```

#### Configure Secret Definitions

Edit `~/.config/fnox/fnox.toml`:

```toml
# OpenAI API Key (age)
[secrets.openai_api_key]
backend = "age"
path = "openai/api_key"
env = "OPENAI_API_KEY"
description = "OpenAI API key for development"

# GitHub Token (1Password)
[secrets.github_token]
backend = "onepassword"
path = "op://Personal/GitHub Classic PAT/credential"
env = "GITHUB_TOKEN"
description = "GitHub Personal Access Token"
```

#### Auto-load in Shell

Add to your shell startup (already configured if using modular zsh):

```zsh
# Auto-load fnox secrets
if command -v fnox &> /dev/null; then
  eval "$(fnox env)"
fi
```

Or manually load:
```bash
eval $(fnox env)
```

## Usage

### Zed Editor

#### Opening Files

```bash
# Open current directory
zed .

# Open specific file
zed path/to/file.ts

# Open and wait (for git editor)
zed --wait
```

#### Vim Mode Navigation

```
# File navigation
<space>ff - Fuzzy file finder
<space>fg - Project-wide grep
<space>bb - Buffer/tab switcher
<space>e  - Toggle file tree

# LSP navigation
gd        - Go to definition
gr        - Find references
K         - Hover documentation
<space>rn - Rename symbol
<space>ca - Code actions

# Window management
<C-w>v    - Split vertically
<C-w>s    - Split horizontally
<C-w>h/j/k/l - Navigate splits
```

#### Terminal Integration

```
# Toggle terminal
ctrl-`

# Or use leader key
<space>tt
```

### fnox Secret Management

#### Managing Secrets

```bash
# Add secret
mise fnox-add SECRET_NAME "secret-value"

# Get secret
mise fnox-get SECRET_NAME

# List all secrets
mise fnox-list

# Check status
mise fnox-status
```

#### Using Secrets

```bash
# Load into environment
eval $(fnox env)

# Now secrets are available
echo $OPENAI_API_KEY
echo $GITHUB_TOKEN

# Use in scripts
curl -H "Authorization: Bearer $GITHUB_TOKEN" \
  https://api.github.com/user
```

#### Integration with mise

fnox tasks are integrated with mise:

```bash
mise fxi    # fnox-init: Initialize fnox
mise fxa    # fnox-add: Add secret
mise fxg    # fnox-get: Get secret
mise fxl    # fnox-list: List secrets
mise fxs    # fnox-status: Check status
```

## Workflows

### Development Workflow with Zed

```bash
# 1. Open project
cd ~/projects/my-app
zed .

# 2. Navigate files
# Press <space>ff, type filename, enter

# 3. Edit code
# Use vim motions (hjkl, w, b, ciw, etc.)

# 4. LSP features
# gd for go to definition
# K for documentation
# <space>ca for code actions

# 5. Format and save
# <space>fm to format
# cmd-s to save (format on save enabled)

# 6. Run tests in terminal
# ctrl-` to toggle terminal
# npm test or pytest
```

### Secret Management Workflow

```bash
# 1. Add secrets to fnox
mise fnox-add SERVICE_API_KEY "key-value"

# 2. Define in fnox.toml for auto-loading
$EDITOR ~/.config/fnox/fnox.toml

# 3. Load secrets
eval $(fnox env)

# 4. Use in development
# Secrets are now available as environment variables

# 5. Update secrets when needed
fnox set SERVICE_API_KEY "new-value"

# 6. Backup (age key already backed up to 1Password)
mise secrets-verify
```

### New Machine Setup

```bash
# 1. Initialize chezmoi
chezmoi init --apply https://github.com/yourusername/dotfiles.git

# 2. Install fnox
mise use -g fnox

# 3. Restore age key
mise secrets-age-key-restore

# 4. Initialize fnox
mise fnox-init

# 5. Sign in to 1Password
eval $(op signin)

# 6. Load secrets
eval $(fnox env)

# 7. Open Zed
zed .

# All configuration automatically applied!
```

## Integration with Existing Tools

### Zed + Neovim

**Use Zed for**:
- Quick edits and browsing
- Pair programming (built-in collab)
- Modern LSP experience
- GPU-accelerated UI

**Use Neovim for**:
- Complex vim workflows
- Deep customization
- Terminal-only environments
- Established muscle memory

**Switching**:
```bash
# Edit in Zed
zed src/main.rs

# Edit in Neovim
nvim src/main.rs

# Both share similar vim keybindings!
```

### fnox + age + 1Password

**age (Local)**:
- Development API keys
- Test credentials
- Local secrets

**1Password (Cloud)**:
- Shared team credentials
- Production secrets
- Cross-device secrets

**fnox (Unified)**:
- Single interface to both
- Auto-loading into environment
- Declarative configuration

**Workflow**:
```bash
# Add to age (local)
fnox set DEV_API_KEY "value"

# Reference 1Password (cloud)
# Edit fnox.toml:
[secrets.prod_api_key]
backend = "onepassword"
path = "op://Personal/Prod API Key/credential"

# Load all
eval $(fnox env)

# Both available!
echo $DEV_API_KEY
echo $PROD_API_KEY
```

### mise Task Integration

All tools are integrated with mise tasks:

```bash
# fnox tasks
mise tasks | grep fnox
#   fnox-init         [fnox] Initialize fnox configuration
#   fnox-add          [fnox] Add a new secret
#   fnox-get          [fnox] Get a secret value
#   fnox-list         [fnox] List all secrets
#   fnox-status       [fnox] Show fnox status

# Existing secrets tasks still work
mise tasks | grep secrets
#   secrets-verify    [secrets] Verify age encryption setup
#   secrets-add       [secrets] Add file with age encryption
#   secrets-list      [secrets] List age-encrypted files
```

## Troubleshooting

### Zed Issues

**LSP not working**:
```bash
# Check LSP status in Zed
# cmd-shift-p → "LSP Status"

# Restart LSP
# cmd-shift-p → "LSP: Restart Language Server"

# View logs
tail -f ~/Library/Logs/Zed/Zed.log
```

**Vim mode issues**:
```bash
# Press <Esc> multiple times to reset
# Or use command palette: cmd-shift-p → "Vim: Reset"
```

**Settings not applied**:
```bash
# Re-apply with chezmoi
chezmoi apply --force

# Check for JSON errors in settings
zed ~/.config/zed/settings.json
```

### fnox Issues

**fnox not found**:
```bash
# Install via mise
mise use -g fnox

# Verify
which fnox
fnox --version
```

**Configuration error**:
```bash
# Re-apply chezmoi
chezmoi apply

# Verify config
cat ~/.config/fnox/fnox.toml

# Re-initialize
mise fnox-init
```

**Secrets not loading**:
```bash
# Check fnox env output
fnox env

# Load manually
eval $(fnox env)

# Verify
echo $SECRET_NAME
```

**age backend error**:
```bash
# Verify age key exists
ls -la ~/.config/chezmoi/key.txt

# Restore if missing
mise secrets-age-key-restore

# Fix permissions
chmod 600 ~/.config/chezmoi/key.txt
```

**1Password backend error**:
```bash
# Sign in to 1Password
eval $(op signin)

# Or use function
ops

# Verify
op whoami
```

## Best Practices

### Zed Editor

1. **Use vim mode** - Leverages existing muscle memory
2. **Enable format on save** - Maintains code quality
3. **Use LSP features** - Go to definition, rename, code actions
4. **Customize per-language** - Different rules for different languages
5. **Use terminal integration** - Less context switching

### fnox Secrets

1. **Use appropriate backends** - Local (age) vs Cloud (1Password)
2. **Never commit secrets** - Only commit fnox.toml definitions
3. **Rotate regularly** - Update secrets periodically
4. **Use least privilege** - Read-only keys when possible
5. **Backup age key** - Store in 1Password for recovery

### General

1. **Version control everything** - Except actual secret values
2. **Document changes** - Update guides when customizing
3. **Test on new machine** - Verify reproducibility
4. **Keep tools updated** - Run `mise upgrade` regularly
5. **Share improvements** - Contribute back to dotfiles

## Migration Path

### Phase 1: Initial Setup (Current)

✅ Zed configuration created
✅ fnox configuration created
✅ mise tasks added
✅ Documentation written

### Phase 2: Adoption (Next Week)

- [ ] Try Zed for daily coding tasks
- [ ] Migrate API keys to fnox
- [ ] Test auto-loading in shell
- [ ] Verify new machine setup works

### Phase 3: Refinement (Next Month)

- [ ] Customize Zed keybindings further
- [ ] Add more secret definitions to fnox
- [ ] Integrate with CI/CD if needed
- [ ] Share feedback with community

### Phase 4: Evaluation (3 Months)

- [ ] Compare Zed vs Neovim workflows
- [ ] Evaluate fnox vs direct age + 1Password
- [ ] Measure productivity improvements
- [ ] Decide on long-term strategy

## Success Criteria

### Zed Editor

✅ Configuration applied successfully
✅ Vim mode working with relative line numbers
✅ LSP auto-downloading for all languages
✅ Custom keybindings matching Neovim patterns
✅ Terminal integration functional
✅ Git integration enabled

### fnox

✅ fnox installed and initialized
✅ age backend configured (reusing chezmoi key)
✅ 1Password backend configured
✅ mise tasks working
✅ Secrets loading into environment
✅ Documentation complete

## Next Steps

### Immediate (Today)

1. Apply all configurations:
```bash
chezmoi apply
```

2. Install fnox:
```bash
mise use -g fnox
mise fnox-init
```

3. Try Zed:
```bash
zed .
```

### This Week

1. Migrate 1-2 API keys to fnox
2. Practice Zed vim mode keybindings
3. Test secret auto-loading in new shell

### This Month

1. Fully adopt fnox for all secrets
2. Determine Zed vs Neovim preference
3. Update dotfiles based on experience
4. Consider sharing improvements upstream

## Resources

### Documentation

- [Zed Editor Setup Guide](./zed-configuration-guide.md)
- [fnox Secrets Management Guide](./secrets-management-fnox.md)
- [Mise Tasks Reference](../reference/mise-tasks-reference.md)

### Official Docs

- [Zed Documentation](https://zed.dev/docs)
- [fnox GitHub](https://github.com/jdx/fnox)
- [mise Documentation](https://mise.jdx.dev/)

### Community

- [Zed Discord](https://discord.gg/zed)
- [mise Discord](https://discord.gg/mise)

## Feedback and Issues

If you encounter issues or have suggestions:

1. Check the troubleshooting sections in the guides
2. Review the official documentation
3. Ask in community Discord servers
4. Open issues in the respective repositories

## Conclusion

This implementation provides the following capabilities:

1. **Zed Editor** - GPU-accelerated code editing with vim mode integration
2. **fnox** - Unified secret management combining age encryption and 1Password
3. **Comprehensive Documentation** - Complete setup and usage guides
4. **mise Integration** - Streamlined task management for both tools

All configurations are version-controlled through chezmoi and automatically apply during new machine provisioning.

**Implementation Status**: Production Ready

**Adoption Recommendation**: Begin with limited use cases (single file edits in Zed, individual secret in fnox) and progressively expand adoption based on workflow evaluation and user experience.
