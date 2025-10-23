# Zsh Configuration Rollback Guide

## Overview

This document outlines procedures for rolling back from the modular zsh configuration to the original monolithic setup.

## Backup Information

### Original Configuration (Monolithic)

Backup location: `backups/`

| File | Backup Filename | Lines | Last Commit |
|------|----------------|-------|-------------|
| `dot_zshrc.tmpl` | `backups/dot_zshrc.tmpl.monolithic` | 476 | `f275dca` |
| `dot_zshenv.tmpl` | `backups/dot_zshenv.tmpl.original` | 12 | `f275dca` |

### Current Configuration (Modular)

- `dot_zshenv.tmpl` (12 lines) - XDG-compliant bootstrap
- `dot_config/zsh/dot_zshenv.tmpl` (25 lines) - Environment variables
- `dot_config/zsh/dot_zshrc.tmpl` (38 lines) - Module loader
- `dot_config/zsh/conf.d/01-07.zsh` (7 modules)

## Rollback Methods

### Method 1: Restore from Backup (Recommended)

The simplest and safest approach.

```bash
# Navigate to chezmoi directory
cd ~/.local/share/chezmoi

# Remove modular configuration (optional: retain with `mv dot_config/zsh/ dot_config/zsh.modular.bak`)
# git rm -r dot_config/zsh/

# Restore original files from backup
cp backups/dot_zshrc.tmpl.monolithic dot_zshrc.tmpl
cp backups/dot_zshenv.tmpl.original dot_zshenv.tmpl

# Apply changes
chezmoi apply ~/.zshrc ~/.zshenv

# Restart zsh to verify
exec zsh

# Commit if satisfied
git add dot_zshrc.tmpl dot_zshenv.tmpl
git commit -m "Rollback to monolithic zsh configuration"
```

### Method 2: Restore from Git History

Revert to a specific commit.

```bash
# Navigate to chezmoi directory
cd ~/.local/share/chezmoi

# View commit history
git log --oneline --all -- dot_zshrc.tmpl

# Restore from specific commit (f275dca)
git checkout f275dca -- dot_zshrc.tmpl dot_zshenv.tmpl

# Remove modular configuration
git rm -r dot_config/zsh/

# Apply changes
chezmoi apply ~/.zshrc ~/.zshenv

# Restart zsh to verify
exec zsh

# Commit
git add .
git commit -m "Rollback to monolithic zsh configuration from f275dca"
```

### Method 3: Git Branch Strategy (Safest - Recommended)

Maintain both configurations simultaneously.

```bash
# Save current state (if uncommitted)
cd ~/.local/share/chezmoi
git add .
git commit -m "WIP: Modular zsh configuration"

# Create modular branch
git checkout -b feature/modular-zsh

# Commit modular changes
git add .
git commit -m "feat: Implement modular zsh configuration with defer optimization"

# Switch to original configuration
git checkout main
chezmoi apply

# Switch back to modular
git checkout feature/modular-zsh
chezmoi apply

# Merge if adopting modular approach
git checkout main
git merge feature/modular-zsh
git push
```

## Troubleshooting

### Issue: chezmoi apply fails

```bash
# Clear caches
rm -rf ~/.cache/sheldon/
rm -f ~/.config/zsh/.zcompdump

# Reapply
chezmoi apply
```

### Issue: zsh fails to start

```bash
# Start with minimal configuration
zsh -f

# Verify chezmoi source state
chezmoi source-path

# Force reapply
chezmoi apply --force
```

### Issue: Performance comparison

```bash
# Benchmark monolithic configuration
hyperfine --warmup 5 --runs 30 "zsh -i -c exit"

# Benchmark modular configuration
# (run after switching)
hyperfine --warmup 5 --runs 30 "zsh -i -c exit"
```

## Configuration Comparison

### Monolithic Configuration (Original)

**Advantages:**
- Simple, straightforward structure
- All configuration in single file
- No concerns about load order

**Disadvantages:**
- Difficult to maintain (476 lines)
- Challenging to selectively enable/disable features
- Difficult to partially port to other machines

**Startup Time:** ~57ms (measured baseline)

### Modular Configuration (Current)

**Advantages:**
- 7 meaningful modules improve maintainability
- Easy to selectively enable/disable features
- Defer optimization enhances startup performance
- Full XDG Base Directory compliance
- Straightforward partial porting to other machines

**Disadvantages:**
- Slightly more complex (comprehensive documentation provided)
- Increased file count

**Startup Time:** 48.7ms (min), 55.1ms (avg) - **15% faster**

## Recommendations

### For Temporary Testing

Use **Method 3 (Branch Strategy)**:
- Return to main branch anytime
- Develop while testing modular approach
- Quick rollback if issues arise

### For Complete Rollback

Use **Method 1 (Restore from Backup)**:
- Explicit backup file usage
- Straightforward procedure
- Clean Git history

## Reference Information

### Related Documentation

- `ZSH_MODULAR_CONFIG.md` - Modular configuration details
- `backups/` - Original file backups

### Git Commit History

```bash
# View configuration change history
git log --oneline --all -- dot_zshrc.tmpl dot_config/zsh/

# View specific commit content
git show f275dca:dot_zshrc.tmpl
```

### chezmoi Commands

```bash
# Check current configuration state
chezmoi status

# View differences
chezmoi diff

# Locate source directory
chezmoi source-path

# Reapply specific file
chezmoi apply ~/.zshrc
```

## Summary

This guide enables safe switching between modular and monolithic zsh configurations.

**Recommended Workflow:**
1. Test modular approach using **branch strategy**
2. Merge to main if stable
3. Rollback to main branch if issues arise
4. Always retain backup files

**Backup Importance:**
- Maintain `backups/` directory permanently
- Git commit history serves as secondary backup
- Accessible on new machines via chezmoi
