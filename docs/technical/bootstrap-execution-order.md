# Bootstrap Execution Order

This document explains the exact order in which dotfiles are installed and configured across different environments (macOS new machine, GitHub Codespaces, DevContainers).

## Overview

The bootstrap process follows a carefully designed sequence to ensure dependencies are available when needed:

```
1. Install chezmoi
2. Run chezmoi init/apply
   ├─ run_once_before_10-install-homebrew.sh    (Foundation: Package Manager)
   ├─ run_once_before_20-install-mise.sh        (Foundation: Runtime Manager)
   ├─ run_once_before_30-install-base-tools.sh  (Foundation: Shell Tools)
   ├─ (Apply all dotfiles: .zshrc, .gitconfig, etc.)
   ├─ run_onchange_install-packages.sh          (Install from Brewfile)
   └─ run_onchange_after_setup-*.sh             (Post-setup configurations)
```

## Detailed Execution Flow

### Phase 1: Bootstrap Script Execution

**Trigger:** Different per environment

| Environment | Script | Location |
|------------|--------|----------|
| GitHub Codespaces | `install` | `/workspaces/.codespaces/.persistedshare/dotfiles/install` |
| DevContainer | `.devcontainer/scripts/setup-dotfiles.sh` | Called from `postCreateCommand` |
| New macOS | Manual: `./install` | After cloning dotfiles repo |

**Actions:**
1. ✅ Install chezmoi to `~/.local/bin`
2. ✅ Run `chezmoi init --apply` (this triggers Phase 2)

**Note:** As of this refactoring, the bootstrap script **no longer** installs Homebrew or mise directly. These are now installed by chezmoi scripts in Phase 2.

### Phase 2: chezmoi Scripts Execution

When `chezmoi apply` runs, it executes scripts in this exact order:

#### 2.1 Foundation Tools (run_once_before)

Scripts with `run_once_before_*` prefix execute **before** dotfiles are written.

**File:** `.chezmoiscripts/run_once_before_10-install-homebrew.sh.tmpl`
- **Purpose:** Install Homebrew package manager
- **Platforms:** macOS, Linux
- **Locations:**
  - macOS arm64: `/opt/homebrew`
  - macOS x86_64: `/usr/local`
  - Linux: `/home/linuxbrew/.linuxbrew`
- **Execution:** Once per unique content (SHA256-tracked)

**File:** `.chezmoiscripts/run_once_before_20-install-mise.sh.tmpl`
- **Purpose:** Install mise runtime version manager
- **Depends on:** Homebrew (script 10)
- **Method:** `brew install mise`
- **Execution:** Once per unique content

**File:** `.chezmoiscripts/run_once_before_30-install-base-tools.sh.tmpl`
- **Purpose:** Install essential shell tools
- **Depends on:** Homebrew (script 10)
- **Tools installed:**
  - `sheldon` - Zsh plugin manager (required by .zshrc)
  - `starship` - Cross-shell prompt
- **Execution:** Once per unique content

#### 2.2 Dotfile Application

After `run_once_before_*` scripts complete, chezmoi writes all managed files:
- `~/.zshrc` (requires sheldon to be installed)
- `~/.gitconfig`
- `~/.config/mise/config.toml`
- etc.

#### 2.3 Configuration Scripts (run_onchange_before)

**File:** `run_onchange_before_configure-macos.sh.tmpl`
- **Purpose:** Apply macOS system defaults
- **Platform:** macOS only (skipped on Linux)
- **Execution:** When content changes

#### 2.4 Package Installation (run_onchange)

**File:** `run_onchange_install-packages.sh.tmpl`
- **Purpose:** Install packages from Brewfile
- **Depends on:** Homebrew (script 10)
- **Execution:** When Brewfile content changes
- **Trigger:** Brewfile hash: `{{ include "dot_Brewfile.tmpl" | sha256sum }}`

#### 2.5 Post-Setup (run_onchange_after)

Scripts with `run_onchange_after_*` prefix execute **after** dotfiles are written.

**Files:**
- `run_onchange_after_setup-lefthook.sh.tmpl` - Git hooks setup
- `run_onchange_after_setup-nushell.sh.tmpl` - Nushell configuration
- `run_onchange_after_setup-nvim.sh.tmpl` - Neovim plugin installation
- `run_onchange_after_setup-tmux.sh.tmpl` - Tmux plugin installation

**Execution:** When respective config files change

#### 2.6 One-Time Setup (run_once)

**File:** `run_once_install-powerlevel10k.sh.tmpl`
- **Purpose:** Clone powerlevel10k theme
- **Execution:** Once per unique content

## Script Naming Convention

chezmoi uses filename prefixes to control execution order:

| Prefix | Timing | Frequency | Example |
|--------|--------|-----------|---------|
| `run_once_before_` | Before dotfiles applied | Once per content | `run_once_before_10-install-homebrew.sh` |
| `run_onchange_before_` | Before dotfiles applied | On content change | `run_onchange_before_configure-macos.sh` |
| `run_onchange_` | During application | On content change | `run_onchange_install-packages.sh` |
| `run_onchange_after_` | After dotfiles applied | On content change | `run_onchange_after_setup-nvim.sh` |
| `run_once_` | During application | Once per content | `run_once_install-powerlevel10k.sh` |

**Numeric Prefixes:**
Within the same category, scripts execute in alphabetical order:
- `10-*` → `20-*` → `30-*`
- This ensures Homebrew (10) installs before mise (20)

## Environment-Specific Behavior

### GitHub Codespaces

**Entry Point:** `install` script (auto-executed by GitHub)

**Flow:**
```bash
# GitHub clones dotfiles to /workspaces/.codespaces/.persistedshare/dotfiles
# GitHub executes ./install

install script:
  1. Install chezmoi
  2. chezmoi init --source=/workspaces/.codespaces/.persistedshare/dotfiles --apply
     ├─ run_once_before_10-install-homebrew.sh  (installs to /home/linuxbrew)
     ├─ run_once_before_20-install-mise.sh
     ├─ run_once_before_30-install-base-tools.sh
     ├─ (apply dotfiles)
     └─ run_onchange_install-packages.sh
```

**Key Points:**
- Dotfiles location: `/workspaces/.codespaces/.persistedshare/dotfiles`
- OS: Linux
- Architecture: arm64 or amd64 (we force amd64 for Homebrew bottles)
- Homebrew path: `/home/linuxbrew/.linuxbrew`

### DevContainer (Local)

**Entry Point:** `.devcontainer/scripts/setup-dotfiles.sh` (from `postCreateCommand`)

**Flow:**
```bash
# devcontainer.json specifies postCreateCommand
# Runs after container is created

setup-dotfiles.sh:
  1. Install chezmoi
  2. chezmoi init --apply https://github.com/lv416e/dotfiles.git
     ├─ run_once_before_10-install-homebrew.sh  (installs to /home/linuxbrew)
     ├─ run_once_before_20-install-mise.sh
     ├─ run_once_before_30-install-base-tools.sh
     ├─ (apply dotfiles)
     └─ run_onchange_install-packages.sh
```

**Key Points:**
- Same flow as Codespaces
- Can use pre-built image from GHCR (if workflow ran)

### New macOS Machine

**Entry Point:** Manual clone + `./install`

**Flow:**
```bash
# User manually clones repo
git clone https://github.com/lv416e/dotfiles.git ~/dotfiles
cd ~/dotfiles
./install

install script:
  1. Install chezmoi
  2. chezmoi init --source=~/dotfiles --apply
     ├─ run_once_before_10-install-homebrew.sh  (installs to /opt/homebrew or /usr/local)
     ├─ run_once_before_20-install-mise.sh
     ├─ run_once_before_30-install-base-tools.sh
     ├─ (apply dotfiles)
     └─ run_onchange_install-packages.sh
```

**Key Points:**
- OS: macOS (darwin)
- Architecture: arm64 or x86_64
- Homebrew path: `/opt/homebrew` (arm64) or `/usr/local` (x86_64)

## Dependency Graph

```
chezmoi (installed by install script)
  └─ run_once_before_10-install-homebrew.sh
       ├─ run_once_before_20-install-mise.sh
       │    └─ (future: could manage chezmoi itself)
       ├─ run_once_before_30-install-base-tools.sh
       │    ├─ sheldon (required by .zshrc)
       │    └─ starship (optional prompt)
       └─ run_onchange_install-packages.sh
            └─ (all Brewfile packages: zoxide, atuin, fzf, etc.)

.zshrc (applied by chezmoi)
  ├─ Requires: sheldon (installed by script 30)
  ├─ Requires: Homebrew PATH (set by script 10)
  └─ Optional: zoxide, atuin, mise (from Brewfile)
```

## Troubleshooting

### Problem: "command not found: sheldon" in .zshrc

**Cause:** Script 30 failed or didn't run before .zshrc was sourced

**Solution:**
```bash
# Manually install sheldon
brew install sheldon

# Re-run chezmoi apply
chezmoi apply -v
```

### Problem: "Homebrew not found" in run_onchange_install-packages.sh

**Cause:** Script 10 failed to install Homebrew

**Solution:**
```bash
# Check script 10 status
chezmoi state dump | grep run_once_before_10

# Re-run by changing script content (adds comment to change hash)
# Or manually install Homebrew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

### Problem: Want to force script re-execution

chezmoi tracks script execution by content hash. To force re-run:

**Option 1: Modify script content**
```bash
# Add/remove a comment in the script
# This changes the SHA256 hash, triggering re-execution
```

**Option 2: Clear state**
```bash
# Remove from state database (advanced)
chezmoi state delete-bucket --bucket=scriptState
```

## References

- [chezmoi Use Scripts Documentation](https://www.chezmoi.io/user-guide/use-scripts-to-perform-actions/)
- [GitHub Codespaces Dotfiles](https://docs.github.com/en/codespaces/setting-your-user-preferences/personalizing-github-codespaces-for-your-account)
- [DevContainer Lifecycle Scripts](https://containers.dev/implementors/json_reference/#lifecycle-scripts)
