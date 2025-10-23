# Pre-Commit Hooks with Lefthook & Gitleaks

## Overview

This repository uses **Lefthook** (Git hooks manager) and **Gitleaks** (secret scanner) to automatically prevent commits containing secrets, large files, or private keys.

## Architecture

```
┌─────────────────────────────────────────┐
│ Git Hooks (managed by Lefthook)        │
│  ↓ Triggers on git commit/push          │
│                                         │
│ ┌─────────────────────────────────┐   │
│ │ Security Checks (parallel)      │   │
│ │ • Gitleaks (secret detection)   │   │
│ │ • File size validation          │   │
│ │ • Private key detection         │   │
│ │ • Chezmoi config validation     │   │
│ └─────────────────────────────────┘   │
└─────────────────────────────────────────┘
```

## Tools Used

### Lefthook
- **Purpose**: Modern Git hooks manager
- **Language**: Go (single binary, no dependencies)
- **Features**: Parallel execution, simple YAML config
- **GitHub**: https://github.com/evilmartians/lefthook

### Gitleaks
- **Purpose**: Secret detection in code
- **Language**: Go (single binary)
- **Features**: Fast scanning, customizable rules
- **GitHub**: https://github.com/gitleaks/gitleaks

## Installation

Hooks are automatically installed by chezmoi via `run_onchange_after_setup-lefthook.sh.tmpl`.

### Manual Installation

If needed, you can manually install:

```bash
# Install tools via mise
mise install go:github.com/evilmartians/lefthook@latest
mise install go:github.com/gitleaks/gitleaks/v8@latest

# Install Git hooks
cd ~/.local/share/chezmoi
lefthook install
```

## Configuration Files

### `lefthook.yml`
Main configuration defining which hooks run and when.

**Pre-commit hooks**:
- **gitleaks**: Scans staged files for secrets
- **check-file-size**: Prevents commits of files > 1MB
- **check-private-keys**: Blocks `.key`, `.pem` files
- **check-chezmoi-config**: Validates chezmoi security settings

**Pre-push hooks**:
- **gitleaks-full**: Full repository scan before push

### `.gitleaks.toml`
Customizes secret detection rules and allowlists.

**Key allowlists**:
- Age public keys (`age1...`) - safe to commit
- Documentation examples - clearly marked placeholders
- Test files - test data and fixtures
- Package locks - dependency files
- Common false positives - UUIDs, version numbers

## Usage

### Normal Workflow

Hooks run automatically on commit:

```bash
git add .
git commit -m "feat: add new feature"
# ↑ Automatically runs all pre-commit hooks
```

**Output example**:
```
🔍 Running pre-commit hooks...
✓ gitleaks (0.3s)
✓ check-file-size (0.1s)
✓ check-private-keys (0.1s)
✓ check-chezmoi-config (0.1s)
```

### Skipping Hooks

**Skip all hooks** (emergency only):
```bash
LEFTHOOK=0 git commit -m "emergency fix"
```

**Skip specific hook**:
```bash
LEFTHOOK_EXCLUDE=gitleaks git commit -m "skip gitleaks only"
```

**Skip via git flag** (not recommended):
```bash
git commit --no-verify -m "bypass all hooks"
```

### Manual Execution

Run hooks manually without committing:

```bash
# Run all pre-commit hooks
lefthook run pre-commit

# Run specific hook
lefthook run pre-commit --commands gitleaks

# Run pre-push hooks
lefthook run pre-push
```

### Gitleaks Commands

**Scan staged files**:
```bash
gitleaks protect --staged --verbose
```

**Scan entire repository**:
```bash
gitleaks detect --verbose --redact
```

**Scan specific files**:
```bash
gitleaks detect --source="path/to/file.txt" --verbose
```

**Scan git history**:
```bash
gitleaks detect --log-opts="--all" --verbose
```

## What Gets Detected

### 🔴 Blocked (Commit Fails)

| Type | Example | Hook |
|------|---------|------|
| API Keys | `AKIA...`, `sk-...` | gitleaks |
| Passwords | `password: "secret123"` | gitleaks |
| Tokens | `github_pat_...` | gitleaks |
| Private Keys | `id_rsa`, `*.pem` | check-private-keys |
| Large Files | Files > 1MB | check-file-size |
| AWS Credentials | `aws_access_key_id: ...` | gitleaks |

### 🟢 Allowed (Commit Succeeds)

| Type | Example | Reason |
|------|---------|--------|
| Age Public Keys | `age14t9x0z...` | Encryption only, safe to share |
| 1Password References | `op://Personal/Item/field` | Not actual secrets |
| Documentation Examples | `YOUR_API_KEY`, `example-token` | Clearly placeholders |
| Test Data | Files in `test/` directory | Test fixtures |
| UUIDs | `123e4567-e89b-12d3-a456-426614174000` | Not secrets |
| Version Numbers | `1.2.3` | Metadata |

## Troubleshooting

### Hook Fails with False Positive

If gitleaks incorrectly flags a safe value:

1. **Add to allowlist** in `.gitleaks.toml`:
   ```toml
   [[allowlists]]
   description = "My custom allowlist"
   regexes = [
     '''pattern-to-ignore''',
   ]
   paths = [
     '''file-to-ignore\.txt$''',
   ]
   ```

2. **Or skip temporarily**:
   ```bash
   LEFTHOOK_EXCLUDE=gitleaks git commit -m "message"
   ```

### Hook Not Running

**Check installation**:
```bash
# Verify hooks are installed
ls -la .git/hooks/ | grep -E "(pre-commit|pre-push)"

# Should show:
# pre-commit -> lefthook
# pre-push -> lefthook
```

**Reinstall hooks**:
```bash
lefthook install
```

**Check lefthook status**:
```bash
lefthook version
```

### Gitleaks Not Found

```bash
# Check if installed
which gitleaks

# Install via mise
mise install go:github.com/gitleaks/gitleaks/v8@latest

# Or via Homebrew
brew install gitleaks
```

### Performance Issues

If hooks are slow:

1. **Check file count**:
   ```bash
   git diff --cached --name-only | wc -l
   ```

2. **Limit file types** in `lefthook.yml`:
   ```yaml
   gitleaks:
     glob: "*.{yml,yaml,toml,sh}"  # Only relevant files
   ```

3. **Use parallel execution** (already enabled):
   ```yaml
   parallel: true
   ```

## Customization

### Add Custom Hook

Edit `lefthook.yml`:

```yaml
pre-commit:
  commands:
    my-custom-check:
      glob: "*.py"
      run: |
        echo "Running custom check..."
        # Your custom validation
```

### Add Custom Gitleaks Rule

Edit `.gitleaks.toml`:

```toml
[[rules]]
id = "my-custom-secret"
description = "Detect my custom secret format"
regex = '''custom-secret-[a-zA-Z0-9]{32}'''
keywords = ["custom-secret"]
```

### Disable Specific Hook

Edit `lefthook.yml`:

```yaml
pre-commit:
  commands:
    gitleaks:
      skip: true  # Disable this hook
```

## Best Practices

### ✅ Do

- Keep hooks fast (< 5 seconds total)
- Use specific glob patterns to limit scanned files
- Document custom allowlists in `.gitleaks.toml`
- Test hooks before pushing: `lefthook run pre-commit`
- Use `LEFTHOOK_EXCLUDE` for legitimate skips

### ❌ Don't

- Skip hooks without understanding why they failed
- Commit secrets and remove them later (they're in git history)
- Add broad allowlists (e.g., `.*`) that weaken security
- Use `--no-verify` habitually
- Store real secrets in documentation examples

## CI/CD Integration

While lefthook runs locally, you can also run gitleaks in CI:

### GitHub Actions

```yaml
name: Security Scan
on: [pull_request, push]
jobs:
  gitleaks:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
        with:
          fetch-depth: 0
      - uses: gitleaks/gitleaks-action@v2
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
```

## Resources

- [Lefthook Documentation](https://github.com/evilmartians/lefthook/blob/master/docs/usage.md)
- [Gitleaks Documentation](https://github.com/gitleaks/gitleaks#readme)
- [Gitleaks Configuration](https://github.com/gitleaks/gitleaks/blob/master/config/gitleaks.toml)
- [chezmoi Security Best Practices](https://www.chezmoi.io/user-guide/frequently-asked-questions/security/)

## FAQ

### Q: What's the difference between pre-commit and lefthook?

**A**: Both are Git hooks managers, but:
- **pre-commit**: Python-based, sequential execution, huge community
- **lefthook**: Go-based, parallel execution, simpler config

We chose lefthook for speed and simplicity.

### Q: Why not just use gitleaks directly?

**A**: Lefthook provides:
- Automatic hook installation/management
- Parallel execution of multiple checks
- Easy skip/exclude functionality
- Consistent hook behavior across team

### Q: Can I use this with other Git hooks?

**A**: Yes! Lefthook manages all hooks. Add them to `lefthook.yml`:
- `pre-commit`: Before commit
- `pre-push`: Before push
- `post-merge`: After merge
- `post-checkout`: After checkout
- And more...

### Q: What if I need to commit a file that looks like a secret?

**A**: Three options:
1. Add specific allowlist in `.gitleaks.toml` (preferred)
2. Skip gitleaks for that commit: `LEFTHOOK_EXCLUDE=gitleaks git commit`
3. Mark as false positive in commit message and document why

### Q: How do I update the tools?

```bash
# Update via mise
mise upgrade

# Or manually
mise install go:github.com/evilmartians/lefthook@latest
mise install go:github.com/gitleaks/gitleaks/v8@latest

# Reinstall hooks
lefthook install
```

---

**Remember**: These hooks are your first line of defense against accidental secret exposure. Don't disable them lightly!
