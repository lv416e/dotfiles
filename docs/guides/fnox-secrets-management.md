# fnox Secret Management Guide

This guide explains how to use fnox for modern secret management, integrated with your existing age encryption and 1Password setup.

## Overview

**fnox** is a modern secret manager by @jdx (author of mise) that provides:

- **Unified interface** for multiple secret backends (age, 1Password, AWS, Azure, GCP, Bitwarden, Vault)
- **Auto-loading** secrets into environment variables
- **Simple configuration** via `fnox.toml` (version controlled)
- **Shell integration** for seamless workflow

## Philosophy

fnox complements your existing secrets management:

- **age encryption** - Local secrets (API keys, tokens)
- **1Password** - Shared/cloud secrets (team credentials)
- **fnox** - Unified interface to both, with auto-loading

This provides:
- Local secrets encrypted with age (offline access)
- Cloud secrets from 1Password (cross-device sync)
- Environment variable auto-loading (convenience)
- Multiple backend support (flexibility)

## Quick Start

### Installation

fnox is already configured in your mise tools. Install it:

```bash
# Install fnox globally via mise
mise use -g fnox

# Verify installation
fnox --version
```

### Initialize Configuration

```bash
# Apply dotfiles to generate fnox config
chezmoi apply

# Initialize fnox
mise fnox-init
# Alias: mise fxi

# Check status
mise fnox-status
# Alias: mise fxs
```

### Basic Usage

```bash
# Add a secret (stored in age-encrypted file)
mise fnox-add OPENAI_API_KEY sk-proj-...
# Alias: mise fxa OPENAI_API_KEY sk-proj-...

# Get a secret
mise fnox-get OPENAI_API_KEY
# Alias: mise fxg OPENAI_API_KEY

# List all secrets
mise fnox-list
# Alias: mise fxl

# Load secrets into environment
eval $(fnox env)
```

## Configuration

### Configuration File

Location: `~/.config/fnox/fnox.toml`

Managed by chezmoi from: `dot_config/private_fnox/fnox.toml.tmpl`

### Backends

fnox supports multiple backends. Your configuration includes:

#### 1. age (Local Encrypted Secrets)

**Storage**: `~/.config/fnox/secrets/` (age-encrypted files)

**Identity**: Reuses your chezmoi age key (`~/.config/chezmoi/key.txt`)

**Use for**:
- API keys (OpenAI, Anthropic, etc.)
- Local development tokens
- Private credentials

**Example**:
```bash
# Add secret to age backend (default)
fnox set ANTHROPIC_API_KEY sk-ant-...

# Stored at: ~/.config/fnox/secrets/ANTHROPIC_API_KEY.age
```

#### 2. 1Password (Cloud Secrets)

**Storage**: 1Password vault (cloud-synced)

**Vault**: Configured from chezmoi (default: "Personal")

**Use for**:
- Shared team credentials
- Cross-device secrets
- Backup of important tokens

**Example**:
```bash
# Reference 1Password item in fnox config
[secrets.github_token]
backend = "onepassword"
path = "op://Personal/GitHub Classic PAT/credential"
env = "GITHUB_TOKEN"
```

### Adding Secret Definitions

Edit `~/.config/fnox/fnox.toml` to define secrets:

```toml
# Example: OpenAI API Key (age)
[secrets.openai_api_key]
backend = "age"
path = "openai/api_key"
env = "OPENAI_API_KEY"
description = "OpenAI API key for Claude Code and other tools"

# Example: GitHub Token (1Password)
[secrets.github_token]
backend = "onepassword"
path = "op://Personal/GitHub Classic PAT/credential"
env = "GITHUB_TOKEN"
description = "GitHub Personal Access Token"

# Example: AWS Credentials (1Password)
[secrets.aws_access_key]
backend = "onepassword"
path = "op://Personal/AWS/access_key_id"
env = "AWS_ACCESS_KEY_ID"

[secrets.aws_secret_key]
backend = "onepassword"
path = "op://Personal/AWS/secret_access_key"
env = "AWS_SECRET_ACCESS_KEY"
```

## Workflow

### Adding Secrets

#### Method 1: Via mise task (age backend)

```bash
# Add secret (prompts for value)
mise fnox-add API_KEY_NAME

# Or provide value directly
mise fnox-add API_KEY_NAME "secret-value-here"
```

#### Method 2: Via fnox directly

```bash
# Age backend (default)
fnox set MY_SECRET "value"

# Specific backend
fnox set --backend onepassword MY_SECRET "value"
```

#### Method 3: Define in config + manual storage

1. Edit `~/.config/fnox/fnox.toml`:
```toml
[secrets.my_api_key]
backend = "age"
path = "service/api_key"
env = "SERVICE_API_KEY"
```

2. Store value:
```bash
fnox set SERVICE_API_KEY "actual-key-value"
```

### Accessing Secrets

#### In Shell

```bash
# Load all secrets into environment
eval $(fnox env)

# Now secrets are available
echo $OPENAI_API_KEY
echo $GITHUB_TOKEN
```

#### In Scripts

```bash
#!/bin/bash

# Load fnox secrets
eval $(fnox env)

# Use secrets
curl -H "Authorization: Bearer $GITHUB_TOKEN" \
  https://api.github.com/user
```

#### Auto-load in zsh

Add to your shell startup (already configured if using this dotfiles):

```zsh
# Auto-load fnox secrets
if command -v fnox &> /dev/null; then
  eval "$(fnox env)"
fi
```

### Updating Secrets

```bash
# Update secret value
fnox set EXISTING_KEY "new-value"

# Verify update
fnox get EXISTING_KEY
```

### Removing Secrets

```bash
# Remove secret
fnox remove OLD_KEY

# Verify removal
fnox list | grep OLD_KEY  # Should return nothing
```

## Integration with Existing Tools

### chezmoi Integration

fnox configuration is managed by chezmoi:

```bash
# Modify fnox config
$EDITOR ~/.local/share/chezmoi/dot_config/private_fnox/fnox.toml.tmpl

# Apply changes
chezmoi apply

# Verify
cat ~/.config/fnox/fnox.toml
```

### 1Password Integration

fnox uses the same 1Password setup as chezmoi:

```bash
# Sign in to 1Password (if not already)
eval $(op signin)
# Or use the 'ops' function from zsh config

# fnox will use the active 1Password session
fnox get --backend onepassword GITHUB_TOKEN
```

### age Integration

fnox reuses your chezmoi age key:

```bash
# Same key location
~/.config/chezmoi/key.txt

# Backup age key to 1Password (if not already done)
mise secrets-age-key-backup

# Restore on new machine
mise secrets-age-key-restore
```

## Use Cases

### API Keys for Development

```bash
# Store API keys in age-encrypted files
fnox set OPENAI_API_KEY sk-proj-...
fnox set ANTHROPIC_API_KEY sk-ant-...
fnox set GOOGLE_GEMINI_API_KEY ...

# Load in shell
eval $(fnox env)

# Use in development
claude-code --api-key $ANTHROPIC_API_KEY
```

### Environment-Specific Secrets

```toml
# Development
[secrets.db_password_dev]
backend = "age"
path = "db/dev_password"
env = "DB_PASSWORD"

# Production (from 1Password)
[secrets.db_password_prod]
backend = "onepassword"
path = "op://Personal/Production DB/password"
env = "DB_PASSWORD"
```

Switch by loading different configs or using conditions in fnox.toml.

### Team Shared Secrets

```toml
# Stored in shared 1Password vault
[secrets.team_api_key]
backend = "onepassword"
path = "op://TeamVault/Shared API Key/credential"
env = "TEAM_API_KEY"
description = "Shared API key for team services"
```

### CI/CD Secrets

For CI/CD, use cloud provider backends:

```toml
# AWS Secrets Manager
[backends.aws]
enabled = true
region = "us-east-1"

[secrets.ci_token]
backend = "aws"
path = "ci/github_token"
env = "CI_GITHUB_TOKEN"
```

## Advanced Usage

### Multiple Backends

fnox supports simultaneous backends:

```toml
# Local development (age)
[secrets.dev_db_password]
backend = "age"
path = "local/db_password"
env = "DEV_DB_PASSWORD"

# Production (1Password)
[secrets.prod_db_password]
backend = "onepassword"
path = "op://Personal/Prod DB/password"
env = "PROD_DB_PASSWORD"

# CI/CD (AWS Secrets Manager)
[secrets.ci_db_password]
backend = "aws"
path = "ci/db_password"
env = "CI_DB_PASSWORD"
```

### Secret Rotation

```bash
# 1. Generate new secret
NEW_KEY=$(openssl rand -hex 32)

# 2. Update in fnox
fnox set API_KEY "$NEW_KEY"

# 3. Update in services
curl -X POST https://api.service.com/rotate \
  -H "Authorization: Bearer $API_KEY"

# 4. Verify new key works
curl -H "Authorization: Bearer $NEW_KEY" \
  https://api.service.com/verify
```

### Backup and Restore

#### Backup

```bash
# age secrets are in ~/.config/fnox/secrets/
# Back up with chezmoi or manually:
tar czf fnox-secrets-backup.tar.gz ~/.config/fnox/secrets/

# 1Password secrets are already backed up in the cloud
```

#### Restore

```bash
# Restore age identity
mise secrets-age-key-restore

# Restore fnox config
chezmoi apply

# Re-initialize fnox
mise fnox-init

# Secrets from age backend will be accessible
# Secrets from 1Password require signing in
eval $(op signin)
```

## Security Best Practices

### 1. Never Commit Secrets

```bash
# fnox.toml (safe to commit)
✅ Secret definitions
✅ Backend configuration
✅ Environment variable names

# NOT safe to commit:
❌ Actual secret values
❌ Age-encrypted files (optional)
❌ 1Password credentials
```

### 2. Use Appropriate Backends

```
Local development → age
Team sharing → 1Password
Production/CI → Cloud provider (AWS/Azure/GCP)
```

### 3. Rotate Regularly

```bash
# Set up rotation reminders
# For critical secrets: 90 days
# For development: 180 days
# For CI/CD: 30 days
```

### 4. Limit Scope

```toml
# Instead of admin keys:
[secrets.api_key_readonly]
backend = "age"
path = "service/readonly_key"
env = "SERVICE_API_KEY"
description = "Read-only API key (least privilege)"
```

### 5. Audit Access

```bash
# Check what secrets exist
fnox list

# Check backend status
mise fnox-status

# Review 1Password access logs
op activity list
```

## Troubleshooting

### fnox Not Found

```bash
# Install via mise
mise use -g fnox

# Verify installation
which fnox
fnox --version
```

### Configuration Not Found

```bash
# Apply chezmoi templates
chezmoi apply

# Verify config
cat ~/.config/fnox/fnox.toml

# Re-initialize
mise fnox-init
```

### age Backend Errors

```bash
# Check age key exists
ls -la ~/.config/chezmoi/key.txt

# Generate if missing
chezmoi age-keygen --output ~/.config/chezmoi/key.txt

# Set correct permissions
chmod 600 ~/.config/chezmoi/key.txt
```

### 1Password Backend Errors

```bash
# Check 1Password CLI
op whoami

# Sign in if needed
eval $(op signin)
# Or: ops (zsh function)

# Test access
op vault list
```

### Secrets Not Loading

```bash
# Check fnox env output
fnox env

# Should show export statements:
# export GITHUB_TOKEN="ghp_..."
# export OPENAI_API_KEY="sk-proj-..."

# Load manually
eval $(fnox env)

# Verify
echo $GITHUB_TOKEN
```

### Permission Errors

```bash
# Secrets directory should be 700
chmod 700 ~/.config/fnox/secrets

# Age key should be 600
chmod 600 ~/.config/chezmoi/key.txt

# Config should be 600
chmod 600 ~/.config/fnox/fnox.toml
```

## Comparison with Alternatives

| Feature | fnox | age + 1Password | direnv | pass | Vault |
|---------|------|----------------|--------|------|-------|
| **Multiple backends** | ✅ | Partial | ❌ | ❌ | ✅ |
| **Auto-load env vars** | ✅ | ❌ | ✅ | ❌ | Partial |
| **Cloud sync** | ✅ | ✅ | ❌ | ❌ | ✅ |
| **Local encryption** | ✅ | ✅ | ❌ | ✅ | ❌ |
| **Simple config** | ✅ | ✅ | ✅ | Partial | ❌ |
| **Team sharing** | ✅ | ✅ | ❌ | Partial | ✅ |
| **Learning curve** | Low | Low | Low | Medium | High |

### When to Use fnox

✅ Need multiple secret backends
✅ Want auto-loading into environment
✅ Prefer declarative configuration
✅ Already using mise ecosystem

### When to Use Alternatives

- **age + 1Password only**: Simpler needs, no auto-loading required
- **direnv**: Project-specific env vars (not secrets)
- **pass**: GPG-based workflow, command-line only
- **HashiCorp Vault**: Enterprise secrets management, complex policies

## Migration Guide

### From age + 1Password Only

```bash
# 1. Install fnox
mise use -g fnox

# 2. Apply chezmoi config
chezmoi apply

# 3. Initialize fnox
mise fnox-init

# 4. Define secrets in fnox.toml
# (edit ~/.config/fnox/fnox.toml)

# 5. Migrate secrets
# age secrets: Copy to fnox age backend
# 1Password: Reference in fnox config

# 6. Update shell startup
# Add: eval $(fnox env)
```

### From direnv

```bash
# 1. Review .envrc files
cat .envrc

# 2. For secrets, add to fnox
fnox set SECRET_KEY "value"

# 3. For non-secrets, keep in .envrc
# (paths, feature flags, etc.)

# 4. Update .envrc to use fnox
echo 'eval "$(fnox env)"' >> .envrc
```

### From pass

```bash
# 1. Export secrets from pass
pass show path/to/secret > secret.txt

# 2. Import to fnox
fnox set SECRET_NAME "$(cat secret.txt)"

# 3. Securely delete export
shred -u secret.txt
```

## Resources

### Official Documentation

- [fnox GitHub](https://github.com/jdx/fnox)
- [mise Documentation](https://mise.jdx.dev/)
- [@jdx on Twitter/X](https://twitter.com/jdxcode)

### Related Documentation

- [Mise Tasks Reference](../reference/mise-tasks.md)
- [Secrets Management Overview](./secrets-management.md)
- [1Password CLI Setup](./onepassword-setup.md) (TODO)
- [age Encryption Guide](./age-encryption.md) (TODO)

### Community

- [mise Discord](https://discord.gg/mise)
- [fnox Issues](https://github.com/jdx/fnox/issues)

## See Also

- [macOS Defaults Automation](./macos-defaults-automation.md)
- [Configuration Variants](../explanation/configuration-variants.md)
- [New Machine Setup](../getting-started/new-machine-setup.md)
