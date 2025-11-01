# Documentation

Comprehensive documentation for this dotfiles management system, organized using the [Diátaxis framework](https://diataxis.fr/) for optimal information architecture.

## Quick Navigation

### 🎯 Getting Started
Start here for initial setup and onboarding.

- [Machine Setup (macOS)](getting-started/machine-setup-macos.md) - Complete guide for setting up dotfiles on a fresh macOS machine

### 📖 How-To Guides
Task-oriented guides for specific operations.

- [Zsh Configuration Switching](guides/zsh-configuration-switching.md) - Switch between modular and monolithic Zsh configurations
- [Zsh Configuration Rollback](guides/zsh-configuration-rollback.md) - Restore previous Zsh configurations
- [Secrets Management Overview](guides/secrets-management-overview.md) - Manage sensitive data with age and 1Password
- [Secrets Management with fnox](guides/secrets-management-fnox.md) - Unified secret manager integration
- [Tmux Status Bar Customization](guides/tmux-statusbar-customization.md) - Customize tmux status bar appearance
- [Zed Configuration Guide](guides/zed-configuration-guide.md) - Configure Zed editor with vim mode and LSP
- [Codespaces Quick Start](guides/codespaces-quickstart.md) - Get started with GitHub Codespaces in 2 minutes
- [DevContainer Setup](guides/devcontainer-setup-complete.md) - Complete guide for DevContainer configuration
- [DevContainer Troubleshooting](guides/devcontainer-troubleshooting.md) - Common DevContainer issues and solutions
- [macOS Defaults Automation Guide](guides/macos-defaults-automation-guide.md) - Automate macOS system preferences
- [Claude Code Skills Integration](guides/claude-code-skills-integration.md) - Integrate Claude Code skills with dotfiles
- [Tooling Implementation Guide 2025](guides/tooling-implementation-guide-2025.md) - Modern tooling enhancements

### 📚 Reference
Information-oriented documentation for lookup.

- [Keybindings Reference](reference/keybindings-reference.md) - Quick reference for multiplexer keybindings
- [Mise Tasks Reference](reference/mise-tasks-reference.md) - Available mise task runner commands
- [Terminal Multiplexers Comparison](reference/terminal-multiplexers-comparison.md) - Tmux and Zellij comparison and configuration
- [Tools Evaluation Criteria](reference/tools-evaluation-criteria.md) - Modern alternatives and tooling recommendations
- [Helix Configuration Reference](reference/helix-configuration-reference.md) - Helix editor configuration
- [Raycast Extensions Reference](reference/raycast-extensions-reference.md) - Installed Raycast extensions

### 💡 Explanation
Understanding-oriented documentation explaining architectural decisions.

- [Multiplexer Abstraction Design](explanation/multiplexer-abstraction-design.md) - Design and rationale for multiplexer abstraction layer
- [Zsh Modular Configuration Design](explanation/zsh-modular-configuration-design.md) - Architecture of modular Zsh configuration system
- [Pre-Commit Hooks Rationale](explanation/pre-commit-hooks-rationale.md) - Lefthook and gitleaks integration

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

- **General setup**: Start with [Machine Setup (macOS)](getting-started/machine-setup-macos.md)
- **Specific task**: Check the relevant how-to guide
- **Understanding design**: Read architecture decision records
- **Quick lookup**: Use reference documentation

## Feedback

Found an issue or have suggestions? Please open an issue in the repository.
