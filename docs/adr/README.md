# Architecture Decision Records (ADR)

## Overview

This directory contains Architecture Decision Records (ADRs) documenting significant architectural and design decisions made for this dotfiles management system.

## Format

ADRs follow the [MADR (Markdown ADR)](https://adr.github.io/madr/) template format with the following structure:

- **Status**: Current state (Accepted, Proposed, Deprecated, Superseded)
- **Context**: The situation prompting the decision
- **Decision Drivers**: Key factors influencing the choice
- **Considered Options**: Alternatives evaluated
- **Decision Outcome**: Selected option with justification
- **Consequences**: Positive and negative outcomes
- **Pros and Cons**: Detailed analysis of each option

## Naming Convention

ADRs use sequential numbering: `NNNN-title-with-dashes.md`

Example: `0001-adopt-jujutsu-alongside-git.md`

## Index

| ADR | Title | Status | Date |
|-----|-------|--------|------|
| [0001](0001-adopt-jujutsu-alongside-git.md) | Adopt Jujutsu alongside Git | Accepted | 2025-10-26 |
| [0002](0002-use-zsh-defer-for-deferred-loading.md) | Use zsh-defer for deferred loading | Accepted | 2025-10-26 |
| [0003](0003-dual-encryption-strategy.md) | Dual encryption strategy | Accepted | 2025-10-26 |
| [0004](0004-multiplexer-abstraction-layer.md) | Multiplexer abstraction layer | Accepted | 2025-10-26 |
| [0005](0005-configuration-variants-system.md) | Configuration variants system | Accepted | 2025-10-26 |
| [0006](0006-rust-ecosystem-adoption.md) | Rust ecosystem adoption | Accepted | 2025-10-26 |
| [0007](0007-difftastic-integration.md) | Difftastic integration | Accepted | 2025-10-26 |
| [0008](0008-linux-best-effort-support.md) | Linux best-effort support strategy | Accepted | 2025-10-31 |
| [0009](0009-macos-defaults-automation.md) | macOS defaults automation strategy | Accepted | 2025-11-01 |

## Process

1. **Proposal**: Create new ADR with "Proposed" status
2. **Discussion**: Gather feedback from stakeholders
3. **Decision**: Update status to "Accepted" or "Rejected"
4. **Deprecation**: Mark as "Deprecated" if superseded
5. **Supersession**: Create new ADR and link from deprecated one

## Best Practices

- One decision per ADR
- Keep decisions reversible where possible
- Update status when circumstances change
- Link related ADRs
- Document both technical and organizational impacts
