# GitHub Codespaces Prebuilds Configuration Guide

## Overview

GitHub Codespaces Prebuilds significantly reduce environment initialization time by executing resource-intensive operations before workspace creation. This guide covers configuration and optimization for dotfiles repositories using Homebrew.

## How Prebuilds Work

### Execution Phases

**Prebuild Phase** (runs in background via GitHub Actions):
- `onCreateCommand` executes
- `updateContentCommand` executes
- Container snapshot created and stored

**Workspace Creation Phase** (runs when user creates Codespace):
- Prebuild snapshot deployed to VM
- `postCreateCommand` executes
- `postStartCommand` executes
- `postAttachCommand` executes

### Critical Optimization

**Problem**: Homebrew installation in `postCreateCommand` executes every time, negating prebuild benefits.

**Solution**: Move Homebrew setup to prebuild-enabled scripts (`install` or devcontainer lifecycle hooks).

## Configuration

### Repository Settings

**Location**: Repository Settings → Codespaces → Prebuilds

**Required Settings**:
1. **Enable Prebuilds**: Toggle on
2. **Branch**: `main` (or primary development branch)
3. **Region**: Select geographical regions where team operates
4. **Trigger**:
   - Recommended: "Configuration change" (updates only when `.devcontainer/` changes)
   - Alternative: "Every push" (always current but consumes more Actions minutes)

### Devcontainer Lifecycle Hooks

Ensure Homebrew installation occurs in prebuild-compatible phases:

```json
{
  "onCreateCommand": {
    "homebrew": "command -v brew || NONINTERACTIVE=1 /bin/bash -c \"$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\""
  },
  "updateContentCommand": {
    "packages": "[ -f ~/.Brewfile ] && brew bundle --file=~/.Brewfile --no-lock || true"
  },
  "postCreateCommand": "bash ${containerWorkspaceFolder}/.devcontainer/scripts/setup-dotfiles.sh"
}
```

**Note**: This configuration assumes dotfiles (`install` script) handles Homebrew setup. The devcontainer hooks provide fallback coverage.

### Optimal Workflow

**Current Implementation** (via dotfiles):
1. Prebuild Phase:
   - Base image prepared
   - Features installed (common-utils, git)
   - Prebuild snapshot created

2. Workspace Creation:
   - `postCreateCommand` → `setup-dotfiles.sh` → Homebrew install → chezmoi apply → brew bundle
   - Initial wait: 10-20 minutes (Homebrew + packages)

**Optimized Implementation** (recommended):
1. Prebuild Phase:
   - Base image prepared
   - Features installed
   - `onCreateCommand` → Homebrew installed
   - `updateContentCommand` → Brewfile packages installed
   - Prebuild snapshot created with everything ready

2. Workspace Creation:
   - `postCreateCommand` → chezmoi apply only
   - Initial wait: 2-3 minutes (dotfiles configuration only)

## Cost Considerations

### Storage

Prebuilds consume GitHub-hosted storage billed identically to active Codespaces. Each configuration creates separate storage allocation.

**Optimization**: Limit to essential branches (typically `main` only).

### Actions Minutes

Prebuild updates consume GitHub Actions minutes from organization or personal allowance.

**Optimization**: Use "Configuration change" trigger instead of "Every push" for repositories with frequent commits unrelated to development environment.

### ROI Analysis

**Time Savings**:
- Without Prebuilds: 10-20 minutes per Codespace creation
- With Prebuilds: 2-3 minutes per Codespace creation
- Savings: ~15 minutes average

**Break-even**: If team creates 3+ Codespaces per day, prebuilds provide net positive ROI despite Actions consumption.

## Monitoring

### Prebuild Status

**GitHub Interface**: Repository → Actions → "Codespaces Prebuilds" workflow

### Troubleshooting

**Prebuild Failures**:
1. Check Actions workflow logs
2. Verify `.devcontainer/devcontainer.json` syntax
3. Ensure Homebrew installation commands are non-interactive

**Slow Prebuild Times**:
1. Review `onCreateCommand` and `updateContentCommand` efficiency
2. Consider limiting Brewfile packages in prebuild phase
3. Evaluate whether all dependencies require pre-installation

## Verification

### Confirm Prebuild Usage

When creating a new Codespace, GitHub indicates prebuild usage:

```
Creating codespace from prebuild...
```

### Measure Performance

```bash
# In Codespace terminal
echo "Codespace created at: $(date)"
echo "Homebrew packages: $(brew list --formula | wc -l)"
```

Compare initialization time with and without prebuilds.

## Advanced Configuration

### Multiple Prebuild Configurations

Create branch-specific configurations for different development scenarios:

```
main branch → Full prebuild (all tools)
feature/* branches → Minimal prebuild (essential tools only)
```

### Scheduled Updates

**GitHub Settings**: Configure prebuild refresh schedule independent of push events.

**Use Case**: Repositories with infrequent commits but regular dependency updates.

## Migration Checklist

Transitioning from Features-based to Homebrew-based environment:

- [ ] Remove language-specific Features from `devcontainer.json`
- [ ] Verify Homebrew installation in `install` script
- [ ] Configure Prebuilds in repository settings
- [ ] Monitor first prebuild execution (Actions workflow)
- [ ] Create test Codespace from prebuild
- [ ] Validate tool availability and versions
- [ ] Document team-specific customizations

## References

- [GitHub Codespaces Prebuilds Documentation](https://docs.github.com/en/codespaces/prebuilding-your-codespaces/about-github-codespaces-prebuilds)
- [Configuring Prebuilds](https://docs.github.com/en/codespaces/prebuilding-your-codespaces/configuring-prebuilds)
- [Homebrew on Linux](https://docs.brew.sh/Homebrew-on-Linux)
- [DevContainer Lifecycle Scripts](https://containers.dev/implementors/json_reference/#lifecycle-scripts)

## Support

For prebuild issues:
1. Review GitHub Actions workflow logs
2. Consult [DevContainer troubleshooting guide](./devcontainer-troubleshooting.md)
3. Verify Homebrew installation succeeds in manual tests
