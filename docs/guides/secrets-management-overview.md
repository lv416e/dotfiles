# Secrets Management with 1Password & age

## Overview

This dotfiles repository supports two complementary approaches to secrets management:
- **1Password CLI**: For frequently-updated secrets like API tokens and environment variables
- **age encryption**: For large configuration files that rarely change

## 1Password CLI Integration

### Setup

1. **Install 1Password CLI**:
   ```bash
   brew install --cask 1password-cli
   # Already added to Brewfile
   ```

2. **Authenticate**:
   ```bash
   op account add --address <subdomain>.1password.com --email <email>
   eval $(op signin)
   ```

3. **Configuration**:
   The `.chezmoi.toml.tmpl` already includes 1Password configuration:
   ```toml
   [onepassword]
       mode = "account"
   ```

### Usage in Templates

Use the `onepasswordRead` function in any `.tmpl` file:

```bash
# Example: dot_zshenv.tmpl
{{- if onepasswordRead "op://Personal/OpenAI/api_key" -}}
export OPENAI_API_KEY="{{ onepasswordRead "op://Personal/OpenAI/api_key" }}"
{{- end }}

{{- if onepasswordRead "op://Personal/GitHub/token" -}}
export GITHUB_TOKEN="{{ onepasswordRead "op://Personal/GitHub/token" }}"
{{- end }}
```

### 1Password Item Reference Format

Format: `op://vault/item/field`

Examples:
- `op://Personal/OpenAI/api_key`
- `op://Work/AWS/access_key_id`
- `op://Dev/GitHub/token`

### Advanced: Structured Data

For complex items:
```bash
{{- $sshHosts := onepassword "SSH-Hosts-UUID" -}}
{{- range $sshHosts.fields }}
Host {{ .label }}
    HostName {{ .value }}
{{- end }}
```

## age Encryption

### Setup

1. **Generate encryption key**:
   ```bash
   chezmoi age-keygen --output=$HOME/.config/chezmoi/key.txt
   ```

   This outputs your public key (starts with `age1...`). **Save it!**

2. **Enable age in configuration**:
   Edit `.chezmoi.toml.tmpl` and uncomment:
   ```toml
   encryption = "age"
   [age]
       identity = "{{ .chezmoi.homeDir }}/.config/chezmoi/key.txt"
       recipient = "age1ql3z..." # Your public key from step 1
   ```

3. **Regenerate config**:
   ```bash
   chezmoi init
   ```

### Usage

Add encrypted files to chezmoi:
```bash
chezmoi add --encrypt ~/.aws/credentials
chezmoi add --encrypt ~/.kube/config
chezmoi add --encrypt ~/.ssh/id_rsa
```

Chezmoi automatically decrypts these files during `chezmoi apply`.

### Key Management

**IMPORTANT**: Backup your age private key (`~/.config/chezmoi/key.txt`)!

- Store in password manager
- Print hardcopy in safe location
- Without this key, encrypted files cannot be decrypted

## Strategy: When to Use Each

| Use Case | Tool | Reason |
|----------|------|--------|
| API tokens | 1Password | Frequently rotated, shared across devices |
| Environment variables | 1Password | Dynamic, team-shared |
| SSH keys | 1Password | Auto-rotation, secure notes |
| AWS credentials | age | Large files, rarely change |
| kubeconfig | age | Contains certificates |
| Private keys | age | Binary data support |

## Security Best Practices

1. **Never commit secrets to git**:
   - `.chezmoi.toml.tmpl` already includes `secrets = "error"`
   - This prevents accidental secret commits

2. **Use conditional templating**:
   ```bash
   {{- if onepasswordRead "..." -}}
   # Only include if secret exists
   {{- end }}
   ```

3. **Keep age key secure**:
   - Permissions: `chmod 600 ~/.config/chezmoi/key.txt`
   - Never share via unencrypted channels
   - Backup to secure offline location

4. **Rotate secrets regularly**:
   - Update in 1Password
   - Run `chezmoi apply` to refresh

## Troubleshooting

### 1Password CLI not authenticated
```bash
# Check session status
op whoami

# Re-authenticate
eval $(op signin)
```

### age decryption fails
```bash
# Verify key exists
ls -la ~/.config/chezmoi/key.txt

# Check permissions
chmod 600 ~/.config/chezmoi/key.txt

# Regenerate config
chezmoi init
```

### Template evaluation error
```bash
# Test template manually
chezmoi execute-template "{{ onepasswordRead \"op://...\" }}"

# Dry-run to see errors
chezmoi apply --dry-run --verbose
```

## Examples

### Complete SSH config with 1Password
```bash
# dot_ssh/config.tmpl
{{- if onepasswordRead "op://Personal/SSH-Work/hostname" }}
Host work
    HostName {{ onepasswordRead "op://Personal/SSH-Work/hostname" }}
    User {{ onepasswordRead "op://Personal/SSH-Work/username" }}
    IdentityFile ~/.ssh/id_ed25519
{{- end }}
```

### AWS credentials with age
```bash
# Add to chezmoi
chezmoi add --encrypt ~/.aws/credentials

# Verify
chezmoi managed | grep aws
```

### Combined approach
```bash
# API keys from 1Password
export API_KEY="{{ onepasswordRead "op://..." }}"

# Large configs from age-encrypted files
# (Automatically decrypted by chezmoi)
```

## References

- [chezmoi 1Password integration](https://www.chezmoi.io/user-guide/password-managers/1password/)
- [chezmoi age encryption](https://www.chezmoi.io/user-guide/encryption/age/)
- [1Password CLI documentation](https://developer.1password.com/docs/cli/)
