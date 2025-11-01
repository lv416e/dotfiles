# GitHub Codespaces & DevContainer Setup Guide

## Overview

This guide explains how to use your chezmoi-managed dotfiles with:
- **GitHub Codespaces** (cloud development environment)
- **VS Code DevContainers** (local containerized development)

Both setups are **fully automated** and **non-interactive** thanks to environment detection in `.chezmoi.toml.tmpl`.

## Table of Contents

1. [GitHub Codespaces Setup](#github-codespaces-setup)
2. [Local DevContainer Setup](#local-devcontainer-setup)
3. [How It Works](#how-it-works)
4. [Shell Configuration (zsh)](#shell-configuration)
5. [Secrets Management](#secrets-management)
6. [Performance Optimizations](#performance-optimizations)
7. [Troubleshooting](#troubleshooting)

---

## GitHub Codespaces Setup

### Method 1: Account-Wide Dotfiles (Recommended for Personal Use)

This applies your dotfiles to **ALL** your Codespaces automatically.

#### Step 1: Enable Dotfiles in GitHub Settings

1. Go to [GitHub Settings → Codespaces](https://github.com/settings/codespaces)
2. Under **Dotfiles**, check "Automatically install dotfiles"
3. Select your dotfiles repository: `lv416e/dotfiles`
4. Click **Save**

#### Step 2: Create a Codespace

1. Go to any repository
2. Click **Code** → **Codespaces** → **Create codespace on main**
3. Wait for creation (first time takes ~3-5 minutes)
4. Your dotfiles will be applied automatically via the `install` script

#### What Happens Automatically

```
1. GitHub clones lv416e/dotfiles to /workspaces/.codespaces/.persistedshare/dotfiles
2. Executes ./install script
3. Installs chezmoi to ~/.local/bin
4. Runs: chezmoi init --apply --source=/workspaces/.codespaces/.persistedshare/dotfiles
5. Changes default shell to zsh
6. ✅ Your environment is ready!
```

### Method 2: Project-Specific (Per-Repository)

Use the included `.devcontainer/devcontainer.json` configuration.

1. Ensure `.devcontainer/` folder is in your project
2. Open repository in Codespace
3. Dotfiles applied via `postCreateCommand` in devcontainer.json

---

## Local DevContainer Setup

### Prerequisites

- Docker Desktop installed and running
- VS Code with "Dev Containers" extension

### Setup for Your Project

#### Step 1: Copy DevContainer Configuration

```bash
cd /path/to/your-project
mkdir -p .devcontainer/scripts

# Copy template
cp ~/.local/share/chezmoi/.devcontainer/devcontainer-template.json \
   .devcontainer/devcontainer.json

# Copy setup script
cp ~/.local/share/chezmoi/.devcontainer/scripts/setup-dotfiles.sh \
   .devcontainer/scripts/
```

#### Step 2: Customize Configuration

Edit `.devcontainer/devcontainer.json`:

```json
{
  "name": "Your Project Name",
  "containerEnv": {
    "DOTFILES_REPO": "https://github.com/YOUR_USERNAME/dotfiles.git"
  }
}
```

#### Step 3: Open in DevContainer

**Option A: Open Existing Folder**
1. Open your project folder in VS Code
2. Press `F1` → "Dev Containers: Reopen in Container"
3. Wait for container to build (~2-5 minutes first time)

**Option B: Clone in Container Volume**
1. Press `F1` → "Dev Containers: Clone Repository in Container Volume"
2. Enter your repository URL
3. Container builds and opens automatically

### Step 2: Verify Setup

Open a new terminal in VS Code:

```bash
# Check shell
echo $SHELL
# Should output: /usr/bin/zsh

# Check dotfiles
chezmoi managed | head -5

# Check tools installed via dotfiles
which fzf bat eza
```

---

## How It Works

### Environment Detection

The `.chezmoi.toml.tmpl` automatically detects the environment:

| Environment Variable | Set In | Purpose |
|---------------------|--------|---------|
| `CODESPACES=true` | GitHub Codespaces | Skip interactive prompts |
| `CONTAINER=devcontainer` | DevContainer | Skip Homebrew installation |
| `CI=true` | CI/CD pipelines | Non-interactive mode |

### Non-Interactive Initialization

In Codespaces/containers, chezmoi uses **default values** instead of prompting:

| Setting | Local (Interactive) | Codespaces/Container |
|---------|-------------------|---------------------|
| Email | Prompts user | Uses `git config` or default |
| 1Password | Prompts to enable | **Disabled** (use GitHub Secrets) |
| Age encryption | Prompts to enable | **Disabled** |
| Zsh variant | Prompts choice | `monolithic` (default) |
| Multiplexer | Prompts choice | `tmux` (default) |

### Package Installation Strategy

| Environment | Homebrew | Core Tools | Language Runtimes |
|------------|----------|------------|------------------|
| **macOS Local** | ✅ Full install | via Homebrew | via mise |
| **Codespaces** | ⏭️ Skip | via devcontainer Features | via Features |
| **DevContainer** | ⏭️ Skip | via devcontainer Features | via Features |

**Why skip Homebrew in containers?**
- ⚡ **Performance**: Installing Homebrew takes 5-10 minutes
- 💾 **Caching**: DevContainer Features are cached by Docker
- 🎯 **Best Practice**: Use Dockerfile/Features for container packages

---

## Shell Configuration

### Default Shell Issue (CRITICAL)

**Problem:** Codespaces and DevContainers default to **bash**, not **zsh**.

**Solution:** Multi-layer approach ensures zsh is used:

#### Layer 1: VS Code Terminal (Immediate)

Set in `.devcontainer/devcontainer.json`:

```json
"customizations": {
  "vscode": {
    "settings": {
      "terminal.integrated.defaultProfile.linux": "zsh"
    }
  }
}
```

**Effect:** All VS Code terminal windows open with zsh.

#### Layer 2: System Default (For SSH, etc.)

Set in `install` script:

```bash
sudo chsh -s $(which zsh) $USER
```

**Effect:** SSH sessions and non-VS Code terminals use zsh.

### Powerlevel10k in Codespaces

**Fonts:**
- Powerlevel10k glyphs render correctly in VS Code (local & web)
- Requires Nerd Font on **client side** (your computer)
- No font installation needed in container

**Configuration:**
1. Local VS Code: Set font in `settings.json`:
   ```json
   "terminal.integrated.fontFamily": "HackGen35Nerd Console"
   ```
2. VS Code Web: Configure in browser settings (if font is system-installed)

---

## Secrets Management

### Local Development

**1Password Integration** (Interactive prompt during `chezmoi init`)

```bash
# Enabled locally
op signin
chezmoi apply
```

### Codespaces/DevContainers

**GitHub Codespaces Secrets** (Recommended)

1. Go to [GitHub Settings → Codespaces → Secrets](https://github.com/settings/codespaces)
2. Add secrets (e.g., `GITHUB_TOKEN`, `API_KEY`)
3. Select repository access
4. Secrets automatically available as environment variables in Codespaces

**Using in Templates:**

```toml
# .chezmoi.toml.tmpl
github_token = "{{ or (env "GITHUB_TOKEN") "" }}"
```

**Fallback Pattern (Local + Cloud):**

```toml
# Try environment variable first (Codespaces), then 1Password (local)
api_key = "{{ or (env "API_KEY") (onepasswordRead "op://vault/item/field" | default "") }}"
```

### What's Disabled in Codespaces

- ❌ 1Password CLI (requires interactive auth)
- ❌ Age encryption (key management complexity)
- ✅ Use GitHub Secrets instead

---

## Performance Optimizations

### Architecture Decision: x86_64 vs ARM64

This configuration uses **x86_64/amd64** architecture even on Apple Silicon Macs:

```json
{
  "runArgs": ["--platform=linux/amd64"]
}
```

**Why x86_64?**
- ✅ Homebrew bottles (binary packages) available for x86_64 Linux
- ❌ ARM64 Linux is Tier 2 (no bottles, must build from source)
- ⚡ Installing binaries: seconds vs source builds: 10-60+ minutes per package
- 🐌 QEMU emulation overhead < compilation time

**Performance Comparison:**

| Architecture | Homebrew | Package Install | Total Setup |
|--------------|----------|-----------------|-------------|
| ARM64 (native) | No bottles | Source build (30-60 min) | ~45-90 min |
| x86_64 (QEMU) | Bottles ✅ | Binary install (1-5 min) | ~5-10 min |

### Build Time Comparison

| Component | First Build | With Prebuild | Rebuild |
|-----------|-------------|---------------|---------|
| Container + Homebrew | ~10-15 min | ~30 sec | ~2-3 min |
| Dotfiles application | ~1-2 min | Instant | ~30 sec |
| **Total** | **~12-17 min** | **~30 sec** | **~3 min** |

### Using Codespaces Prebuilds (Recommended)

Prebuilds dramatically reduce startup time:

1. **Enable in Repository Settings:**
   - Go to: `Settings` → `Codespaces` → `Set up prebuild`
   - Branch: `main`
   - Configuration: `.devcontainer/devcontainer.json`
   - Region: Select closest to you
   - Click **Create**

2. **Automatic Rebuilds:**
   - Triggers on changes to `.devcontainer/` or `Brewfile`
   - Weekly automatic rebuild (keeps dependencies fresh)
   - Workflow: `.github/workflows/codespaces-prebuild.yml`

3. **Benefits:**
   - Codespace startup: **30 seconds** instead of 15 minutes
   - Homebrew packages pre-installed
   - Dotfiles pre-applied

### Optimization Checklist

- ✅ **x86_64 architecture**: Ensures Homebrew bottles work
- ✅ **Codespaces Prebuilds**: Cache container for instant startup
- ✅ **Unified Homebrew**: Same Brewfile across all environments
- ✅ **Shell config**: Set in devcontainer.json (instant)
- ✅ **Minimal Features**: Only base tools, rest via Homebrew

### DevContainer Lifecycle

```
┌─────────────────────────────────────────────────────────┐
│ 1. Pull prebuild image (if available)       [INSTANT]  │
├─────────────────────────────────────────────────────────┤
│ 2. Build container (if no prebuild)         [10-15min] │
│    - Install minimal Features (git, curl)               │
│    - Install Homebrew                                   │
│    - Install packages from Brewfile                     │
├─────────────────────────────────────────────────────────┤
│ 3. postCreateCommand (chezmoi apply)         [1st only] │
├─────────────────────────────────────────────────────────┤
│ 4. postStartCommand (info message)           [every]    │
└─────────────────────────────────────────────────────────┘
```

**With Prebuilds:** Steps 1-2 are cached, startup takes ~30 seconds
**Without Prebuilds:** Full build each time, takes ~12-17 minutes

---

## Troubleshooting

### Issue: Terminal still opens with bash

**Symptoms:**
```bash
$ echo $SHELL
/bin/bash
```

**Solutions:**

1. **Reload VS Code window:**
   - `F1` → "Developer: Reload Window"

2. **Check VS Code settings:**
   ```bash
   # In container terminal:
   cat ~/.vscode-server/data/Machine/settings.json | grep defaultProfile
   ```
   Should show `"zsh"`.

3. **Manually open zsh:**
   ```bash
   zsh -l
   ```

4. **Verify zsh installed:**
   ```bash
   which zsh
   # Should output: /usr/bin/zsh
   ```

### Issue: Dotfiles not applying in Codespaces

**Check logs:**

```bash
# View creation log
cat /workspaces/.codespaces/.persistedshare/creation.log

# Check if install script ran
ls -la /workspaces/.codespaces/.persistedshare/dotfiles/install
```

**Common causes:**
- ❌ `install` script not executable → Run `chmod +x install`
- ❌ Private repository without access → Make repo public or grant Codespaces access
- ❌ Script errors → Check logs for error messages

### Issue: "command not found" for tools

**If tool should be in Homebrew (local):**
```bash
brew bundle --file="$HOME/.Brewfile"
```

**If tool should be in devcontainer:**
- Check `.devcontainer/devcontainer.json` → `features`
- Rebuild container: `F1` → "Dev Containers: Rebuild Container"

### Issue: Slow container startup

**Diagnosis:**
```bash
# Check if Homebrew ran (it shouldn't in containers!)
grep "Installing Homebrew" ~/.local/share/chezmoi/run_onchange_install-packages.sh.log
```

**If Homebrew ran:**
- Environment detection failed
- Check: `.chezmoi.toml.tmpl` has `is_container` and `is_codespaces` variables
- Rebuild: `chezmoi apply -v`

---

## Quick Reference

### Useful Commands

```bash
# Verify environment detection
chezmoi execute-template "{{ .is_codespaces }}"  # Should be "true" in Codespaces
chezmoi execute-template "{{ .is_container }}"   # Should be "true" in containers

# Re-apply dotfiles
chezmoi apply -v

# Check what files are managed
chezmoi managed

# Edit dotfiles
chezmoi edit ~/.zshrc

# Update dotfiles from repo
chezmoi update
```

### File Locations

| File | Purpose |
|------|---------|
| `install` | Codespaces bootstrap script |
| `.chezmoi.toml.tmpl` | Environment detection & config |
| `.devcontainer/devcontainer.json` | Container configuration |
| `run_onchange_install-packages.sh.tmpl` | Skips Homebrew in containers |

---

## Next Steps

1. ✅ **Test in Codespace:**
   - Create a test Codespace
   - Verify zsh prompt loads
   - Check tools are available

2. ✅ **Test in Local DevContainer:**
   - Open `.devcontainer` in VS Code
   - Rebuild container
   - Verify setup

3. 📖 **Customize:**
   - Add GitHub Secrets for your API keys
   - Adjust devcontainer Features for project needs
   - Customize `.chezmoiignore` for container-specific exclusions

4. 🚀 **Share:**
   - Template works for team members
   - Document project-specific setup in README
   - Consider creating organization-level Codespace secrets

---

## References

- [Official chezmoi Containers Guide](https://www.chezmoi.io/user-guide/machines/containers-and-vms/)
- [GitHub Codespaces Dotfiles](https://docs.github.com/en/codespaces/setting-your-user-preferences/personalizing-github-codespaces-for-your-account)
- [DevContainers Specification](https://containers.dev/)
- [DevContainer Features](https://containers.dev/features)
