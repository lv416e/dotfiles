# ADR-0003: Dual encryption strategy

## Status

Accepted

## Context

Dotfiles repositories inevitably contain sensitive data: API tokens, SSH keys, application credentials, and service configurations. A robust secrets management strategy must balance security, usability, and operational complexity.

Traditional approaches include: unencrypted secrets (security risk), GPG encryption (complex key management), environment variables (scattered state), or commercial secret managers (vendor lock-in). The ideal solution provides strong encryption with minimal operational friction and recovery guarantees.

## Decision Drivers

- **Security**: Strong encryption with modern cryptographic primitives
- **Usability**: Minimal friction for daily operations
- **Recovery**: Guaranteed secret access across device loss scenarios
- **Portability**: Cross-platform compatibility (macOS, Linux, Windows)
- **Auditability**: Clear visibility into secret access patterns
- **Granularity**: Different sensitivity levels for different secrets

## Considered Options

1. **No encryption** - Store secrets in plaintext with gitignore
2. **GPG only** - Traditional PGP encryption with chezmoi
3. **age only** - Modern encryption with age
4. **1Password only** - Cloud-based secret management
5. **Dual strategy** - age + 1Password complementary approach
6. **HashiCorp Vault** - Enterprise secret management

## Decision Outcome

**Chosen option**: Dual strategy (Option 5)

Implement complementary encryption using age for file-level encryption and 1Password CLI for credential management, providing defense-in-depth with distinct use cases.

### Implementation

**age configuration** (.chezmoi.toml.tmpl):
```toml
encryption = "age"

[age]
    identity = "~/.config/chezmoi/key.txt"
    recipient = "age14t9x0zwv2adeujgjryk33s4f7wcxmsn7y7ws65hz7fs80fw9rfeqk8a4rg"
```

**1Password integration**:
```toml
[onepassword]
    mode = "account"

[data.onepassword]
    vault = "Personal"
```

**Usage patterns**:
```bash
# age: Static files (SSH keys, certificates)
chezmoi add --encrypt ~/.ssh/id_ed25519

# 1Password: Dynamic credentials (API tokens, passwords)
# In template: {{ onepasswordRead "op://Personal/GitHub/token" }}
```

## Consequences

### Positive

- **Defense-in-depth**: Multiple encryption layers reduce single points of failure
- **Use case optimization**: Right tool for each secret type
- **Recovery guarantee**: 1Password provides cloud backup and recovery
- **Audit trail**: 1Password logs all secret access
- **Team sharing**: 1Password enables secure credential sharing
- **Modern cryptography**: age uses Curve25519, ChaCha20-Poly1305

### Negative

- **Dual complexity**: Two systems to understand and maintain
- **1Password dependency**: Requires paid subscription for full features
- **Key management burden**: age identity must be manually backed up
- **Learning curve**: Users must understand both systems
- **Template complexity**: Conditional logic for secret sources

## Pros and Cons of the Options

### No encryption

**Pros**:
- Zero complexity
- Maximum usability
- No key management

**Cons**:
- Unacceptable security risk
- Secrets exposed in version control
- Compliance violations
- No audit capability

### GPG only

**Pros**:
- Industry standard
- Built-in chezmoi support
- Web of trust model

**Cons**:
- Complex key management
- Poor user experience
- Key expiration handling
- Cross-platform difficulties
- Declining modern adoption

### age only

**Pros**:
- Modern cryptography
- Simple key management
- Excellent chezmoi integration
- Single file identity

**Cons**:
- Manual key backup required
- No built-in sharing mechanism
- Key loss = permanent data loss
- No audit trail

### 1Password only

**Pros**:
- Exceptional user experience
- Cloud backup and sync
- Cross-platform excellence
- Audit logging
- Team sharing features

**Cons**:
- Vendor lock-in
- Subscription cost
- Cloud dependency
- Limited offline access
- API rate limits

### Dual strategy

**Pros**:
- Best-of-both-worlds approach
- Use case optimization
- Multiple recovery paths
- Flexibility in secret management

**Cons**:
- Increased complexity
- Dual mental models
- Decision overhead (which tool to use)
- Maintenance burden

### HashiCorp Vault

**Pros**:
- Enterprise-grade features
- Dynamic secret generation
- Fine-grained access control
- Excellent audit capabilities

**Cons**:
- Massive operational complexity
- Infrastructure requirements
- Overkill for personal dotfiles
- Steep learning curve
- High maintenance overhead

## Strategy Matrix

| Secret Type | Tool | Rationale |
|-------------|------|-----------|
| SSH private keys | age | Static, rarely change, local-only access |
| SSL certificates | age | Binary files, infrequent rotation |
| Application config files | age | Complete file encryption needed |
| API tokens | 1Password | Frequent rotation, audit trail valuable |
| Passwords | 1Password | Need sharing, cloud sync, recovery |
| Service credentials | 1Password | Team access, audit requirements |

## Validation

Success criteria:
- All sensitive files encrypted in repository
- Zero plaintext secrets in version control
- Successful secret retrieval on fresh machine setup
- Recovery possible with either 1Password account or age identity

Security verification:
```bash
# Audit repository for potential secrets
gitleaks detect --source . --verbose

# Verify age-encrypted files
chezmoi verify

# Test 1Password integration
op whoami
```

## Migration Path

1. **Identify secrets**: Audit existing dotfiles for sensitive data
2. **Categorize**: Classify by type (static files vs. credentials)
3. **Encrypt with age**: Static files and configuration
4. **Migrate to 1Password**: Dynamic credentials and shared secrets
5. **Verify**: Test retrieval and decryption
6. **Document**: Update team documentation

## References

- [age specification](https://age-encryption.org/)
- [1Password CLI documentation](https://developer.1password.com/docs/cli)
- [chezmoi encryption guide](https://www.chezmoi.io/user-guide/encryption/)
- [Secret management best practices](https://cloud.google.com/secret-manager/docs/best-practices)
