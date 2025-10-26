# Documentation

Comprehensive documentation for this dotfiles management system, organized using the [Diátaxis framework](https://diataxis.fr/) for optimal information architecture.

## Quick Navigation

### 🎯 Getting Started
Start here for initial setup and onboarding.

- [New Machine Setup](getting-started/new-machine-setup.md) - Complete guide for setting up dotfiles on a fresh machine

### 📖 How-To Guides
Task-oriented guides for specific operations.

- [Zsh Configuration Switching](guides/zsh-config-switching.md) - Switch between modular and monolithic Zsh configurations
- [Zsh Rollback Guide](guides/zsh-rollback.md) - Restore previous Zsh configurations
- [Secrets Management](guides/secrets-management.md) - Manage sensitive data with age and 1Password
- [Tmux Status Bar Configuration](guides/tmux-status-bar.md) - Customize tmux status bar appearance

### 📚 Reference
Information-oriented documentation for lookup.

- [Keybindings Reference](reference/keybindings.md) - Quick reference for multiplexer keybindings
- [Mise Tasks](reference/mise-tasks.md) - Available mise task runner commands
- [Terminal Multiplexers](reference/terminal-multiplexers.md) - Tmux and Zellij comparison and configuration
- [New Tools](reference/new-tools.md) - Modern alternatives and tooling recommendations

### 💡 Explanation
Understanding-oriented documentation explaining architectural decisions.

- [Multiplexer Abstraction](explanation/multiplexer-abstraction.md) - Design and rationale for multiplexer abstraction layer
- [Zsh Modular Configuration](explanation/zsh-modular-config.md) - Architecture of modular Zsh configuration system
- [Pre-Commit Hooks](explanation/pre-commit-hooks.md) - Lefthook and gitleaks integration

### 🏛️ Architecture Decision Records
Formal documentation of significant architectural decisions.

- [ADR Index](adr/README.md) - Complete list of architectural decisions
- Key decisions:
  - [ADR-0001: Adopt Jujutsu alongside Git](adr/0001-adopt-jujutsu-alongside-git.md)
  - [ADR-0002: Use zsh-defer for deferred loading](adr/0002-use-zsh-defer-for-deferred-loading.md)
  - [ADR-0003: Dual encryption strategy](adr/0003-dual-encryption-strategy.md)
  - [ADR-0004: Multiplexer abstraction layer](adr/0004-multiplexer-abstraction-layer.md)
  - [ADR-0005: Configuration variants system](adr/0005-configuration-variants-system.md)
  - [ADR-0006: Rust ecosystem adoption](adr/0006-rust-ecosystem-adoption.md)
  - [ADR-0007: Difftastic integration](adr/0007-difftastic-integration.md)

## Documentation Structure

```
docs/
├── README.md                     # This file
├── adr/                          # Architecture Decision Records
├── getting-started/              # Tutorials and setup guides
├── guides/                       # Task-oriented how-to guides
├── reference/                    # Information lookups
└── explanation/                  # Conceptual explanations
```

## Contributing to Documentation

When adding new documentation:

1. **Identify category**: Determine if it's a tutorial, guide, reference, or explanation
2. **Follow templates**: Use existing documents as templates for consistency
3. **Link appropriately**: Cross-reference related documents
4. **Update this README**: Add new documents to the appropriate section above
5. **Use native English**: Write in clear, professional, technical English

## Documentation Principles

- **Single source of truth**: One canonical location for each piece of information
- **Progressive disclosure**: Surface essential information first, details later
- **Consistent formatting**: Follow Markdown best practices and style guide
- **Actionable content**: Include practical examples and commands
- **Maintained currency**: Update documentation alongside code changes

## Need Help?

- **General setup**: Start with [New Machine Setup](getting-started/new-machine-setup.md)
- **Specific task**: Check the relevant how-to guide
- **Understanding design**: Read architecture decision records
- **Quick lookup**: Use reference documentation

## Feedback

Found an issue or have suggestions? Please open an issue in the repository.
