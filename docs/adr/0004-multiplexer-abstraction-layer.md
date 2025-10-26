# ADR-0004: Multiplexer abstraction layer

## Status

Accepted

## Context

Terminal multiplexers (tmux, Zellij, screen) provide essential functionality for persistent sessions, window management, and remote workflows. However, each multiplexer has distinct command syntax, configuration formats, and operational models.

Switching between multiplexers requires relearning commands, reconfiguring keybindings, and adapting workflows. This friction inhibits experimentation with new tools and forces premature commitment to specific implementations.

## Decision Drivers

- **Experimentation**: Enable risk-free evaluation of new multiplexers
- **Portability**: Consistent workflows across different tools
- **Migration cost**: Minimize switching overhead
- **Functionality preservation**: Maintain feature parity across implementations
- **Complexity**: Keep abstraction layer maintainable
- **Performance**: Negligible overhead from abstraction

## Considered Options

1. **Single multiplexer commitment** - Standardize on one tool
2. **Manual switching** - Reconfigure as needed when switching
3. **Abstraction layer** - Unified interface over multiple backends
4. **Configuration templates** - Shared config generation
5. **Wrapper scripts** - Command translation layer

## Decision Outcome

**Chosen option**: Abstraction layer (Option 3)

Implement a multiplexer abstraction providing unified keybindings, session management, and configuration interfaces while preserving tool-specific capabilities.

### Implementation

**Core abstraction functions** (dot_config/zsh/conf.d/06-functions.zsh):
```zsh
# Detection
in-multiplexer() {
    [[ -n "${TMUX:-}" ]] || [[ -n "${ZELLIJ:-}" ]]
}

current-multiplexer() {
    [[ -n "${TMUX:-}" ]] && echo "tmux" && return
    [[ -n "${ZELLIJ:-}" ]] && echo "zellij" && return
    echo "none"
}

# Window management abstraction
mux-kill-window() {
    local current=$(current-multiplexer)
    case "$current" in
        tmux)   tmux kill-window ;;
        zellij) zellij action close-tab ;;
    esac
}

# Repository navigation abstraction
mux-repo() {
    local current=$(current-multiplexer)
    case "$current" in
        tmux)   tmux-repo "$@" ;;
        zellij) # Zellij implementation when available
                echo "Zellij repo integration pending" ;;
    esac
}
```

**Configuration switching**:
```zsh
switch-multiplexer() {
    local target="${1:-tmux}"

    chezmoi edit ~/.config/chezmoi/.chezmoi.toml.tmpl
    # User sets: zsh.multiplexer = "tmux" | "zellij"

    chezmoi apply
    exec zsh
}
```

## Consequences

### Positive

- **Risk-free experimentation**: Try new multiplexers without workflow disruption
- **Unified mental model**: Single set of commands across tools
- **Gradual migration**: Incremental transition between multiplexers
- **Preserved muscle memory**: Keybindings remain consistent
- **Tool-specific features**: Abstraction doesn't prevent direct tool access
- **Future-proof**: New multiplexers easily integrated

### Negative

- **Abstraction maintenance**: Functions require updates for new features
- **Lowest common denominator**: Advanced features may not abstract cleanly
- **Performance overhead**: Minimal but non-zero function call cost
- **Debugging complexity**: Additional indirection layer
- **Documentation burden**: Users need abstraction layer documentation

## Pros and Cons of the Options

### Single multiplexer commitment

**Pros**:
- Zero abstraction complexity
- Full feature utilization
- Optimal performance
- Simple documentation

**Cons**:
- High switching cost
- Vendor lock-in
- Missed innovation from new tools
- Workflow rigidity

### Manual switching

**Pros**:
- No abstraction maintenance
- Direct tool usage
- Maximum flexibility

**Cons**:
- High reconfiguration cost
- Workflow disruption
- Lost productivity during transitions
- Discourages experimentation

### Abstraction layer

**Pros**:
- Unified interface
- Low switching cost
- Encourages experimentation
- Portable workflows

**Cons**:
- Maintenance overhead
- Potential feature limitations
- Additional complexity
- Learning curve for abstraction

### Configuration templates

**Pros**:
- Consistent configurations
- Shareable settings
- Version controlled

**Cons**:
- Syntax differences remain
- Command memorization still required
- Limited runtime flexibility

### Wrapper scripts

**Pros**:
- Command-level abstraction
- Transparent tool switching

**Cons**:
- High complexity
- Difficult debugging
- Performance overhead
- Incomplete feature coverage

## Abstraction Coverage

| Feature | tmux | Zellij | Abstracted |
|---------|------|--------|------------|
| Session creation | ✓ | ✓ | ✓ |
| Window/tab management | ✓ | ✓ | ✓ |
| Pane splitting | ✓ | ✓ | ✓ |
| Copy mode | ✓ | ✓ | ✓ |
| Repository navigation | ✓ | Partial | ✓ |
| Plugin system | ✓ | ✓ | ✗ |
| Scripting | ✓ | Limited | Partial |

## Design Principles

1. **Transparent abstraction**: Functions should feel native, not wrapped
2. **Graceful degradation**: Fall back to tool-specific behavior when abstraction unavailable
3. **Minimal overhead**: Abstraction cost must be negligible (<1ms)
4. **Discoverable**: Abstracted functions clearly named and documented
5. **Extensible**: Easy to add new multiplexers or features

## Validation

Success criteria:
- Switching multiplexers completes in <5 minutes
- 90%+ of common operations work through abstraction
- Performance overhead <1% of operation time
- User can switch multiplexers and continue work without retraining

Testing:
```bash
# Verify abstraction functions
current-multiplexer  # Should return "tmux" or "zellij"
in-multiplexer       # Should return true/false

# Test switching
switch-multiplexer zellij
current-multiplexer  # Should return "zellij"

switch-multiplexer tmux
current-multiplexer  # Should return "tmux"
```

## Migration Experience

Real-world usage demonstrates the value:
1. User runs tmux daily for 5+ years
2. Zellij announced with interesting features
3. `switch-multiplexer zellij` enables evaluation
4. No muscle memory retraining required
5. User can immediately assess Zellij's value proposition
6. Easy rollback if Zellij doesn't meet needs

## References

- [tmux documentation](https://github.com/tmux/tmux/wiki)
- [Zellij documentation](https://zellij.dev/)
- [Multiplexer comparison analysis](https://jdhao.github.io/2021/01/04/tmux_vs_zellij/)
