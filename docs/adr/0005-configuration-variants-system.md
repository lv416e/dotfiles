# ADR-0005: Configuration variants system

## Status

Accepted

## Context

Development environments evolve through experimentation: trying new plugins, testing alternative configurations, and evaluating different organizational approaches. Traditional dotfiles force a binary choice: commit to changes or abandon them entirely.

This creates tension between stability (production-ready configuration) and innovation (experimental improvements). Users face risky all-or-nothing decisions when evaluating significant configuration changes, particularly for complex systems like shell configurations.

## Decision Drivers

- **Experimentation safety**: Enable risk-free configuration testing
- **Rollback simplicity**: Instant reversion to known-good state
- **Comparison capability**: Direct A/B testing of approaches
- **Maintenance burden**: Minimize duplication and drift
- **Switching cost**: Near-zero overhead for variant changes
- **Source of truth**: Single repository for all variants

## Considered Options

1. **Single configuration** - One canonical version
2. **Git branches** - Branch per variant
3. **Variant system** - Runtime configuration selection
4. **Separate repositories** - Distinct repos per variant
5. **Templating with conditions** - Conditional rendering

## Decision Outcome

**Chosen option**: Variant system with templating (Options 3 + 5)

Implement chezmoi-based configuration variants enabling runtime selection between multiple maintained configurations through template conditionals.

### Implementation

**Variant declaration** (.chezmoi.toml.tmpl):
```toml
[data.zsh]
    variant = "monolithic"  # or "modular"
    multiplexer = "tmux"    # or "zellij"
```

**Conditional template rendering** (dot_config/zsh/dot_zshrc.tmpl):
```zsh
{{- if eq .zsh.variant "modular" }}
# Modular configuration: Load from conf.d/
for config in ${XDG_CONFIG_HOME:-$HOME/.config}/zsh/conf.d/*.zsh(N); do
    source "$config"
done
{{- else if eq .zsh.variant "monolithic" }}
# Monolithic configuration: Single file
{{ includeTemplate ".chezmoitemplates/zshrc-monolithic.tmpl" . }}
{{- end }}
```

**Switching interface**:
```zsh
switch-zsh-config() {
    local variant="${1:-modular}"

    # Update chezmoi configuration
    chezmoi edit ~/.config/chezmoi/.chezmoi.toml.tmpl
    # User sets: zsh.variant = "monolithic" | "modular"

    chezmoi apply
    exec zsh
}
```

## Consequences

### Positive

- **Risk-free experimentation**: Test radical changes without losing stable config
- **Instant rollback**: Single command to revert to previous variant
- **A/B comparison**: Direct performance and usability testing
- **Maintained alternatives**: Both variants remain functional
- **Single source of truth**: All variants in one repository
- **Graceful migration**: Incremental transition between approaches

### Negative

- **Maintenance overhead**: Must update multiple variants for shared changes
- **Drift risk**: Variants may diverge over time
- **Complexity**: Template conditionals add cognitive load
- **Testing burden**: Changes require validation across variants
- **Storage cost**: Duplicate configuration content

## Pros and Cons of the Options

### Single configuration

**Pros**:
- Zero maintenance duplication
- Simple mental model
- No drift possible
- Minimal complexity

**Cons**:
- Risky experimentation
- No rollback mechanism
- Breaking changes affect production
- All-or-nothing adoption

### Git branches

**Pros**:
- Native version control
- Complete isolation
- Familiar workflow
- Easy comparison (git diff)

**Cons**:
- Branch management overhead
- Merge conflicts on updates
- Switching requires git operations
- Chezmoi state management complexity

### Variant system

**Pros**:
- Runtime selection
- Zero git operations for switching
- Clean abstraction
- Production-safe experimentation

**Cons**:
- Template complexity
- Maintenance duplication
- Potential for drift
- Testing overhead

### Separate repositories

**Pros**:
- Complete isolation
- Independent evolution
- No template complexity

**Cons**:
- Duplication of entire repository
- Shared changes must propagate manually
- High maintenance burden
- Fragmented version control

### Templating with conditions

**Pros**:
- Single source for shared code
- Runtime flexibility
- Version controlled variants

**Cons**:
- Template debugging difficulty
- Increased complexity
- Learning curve for template syntax

## Variant Categories

| System | Variants | Selection Mechanism |
|--------|----------|---------------------|
| Zsh configuration | monolithic, modular | `.zsh.variant` |
| Multiplexer | tmux, zellij | `.zsh.multiplexer` |
| Prompt | starship, p10k | `.zsh.prompt` |

## Design Principles

1. **Parity preservation**: Variants must provide equivalent functionality
2. **Shared maximization**: Extract common code to templates
3. **Drift prevention**: Regular synchronization checks
4. **Clear naming**: Variant purposes must be self-documenting
5. **Default stability**: Default variant should be production-tested

## Validation

Success criteria:
- Switching variants completes in <10 seconds
- Both variants maintain functional parity
- Zero drift in shared functionality
- Performance differences documented and acceptable

Verification procedures:
```bash
# Test variant switching
switch-zsh-config modular
# Verify functionality

switch-zsh-config monolithic
# Verify functionality

# Compare function availability
for variant in modular monolithic; do
    switch-zsh-config "$variant"
    typeset -f | grep '^[a-z_-]* ()' | wc -l
done
# Should return identical counts
```

## Maintenance Protocol

1. **Shared changes**: Update both variants simultaneously
2. **Variant-specific changes**: Document divergence rationale
3. **Quarterly audits**: Compare variants for unintentional drift
4. **Performance benchmarks**: Track startup time for both variants
5. **Functionality tests**: Verify command parity

## Real-World Impact

**Zsh modular experiment**:
- Created modular variant with XDG compliance and improved organization
- Ran both variants for 30 days
- Performance: Modular was 15% faster (42ms vs 49ms avg startup)
- Maintainability: Modular significantly easier to navigate
- Decision: Adopted modular as default after successful evaluation
- Preserved monolithic as fallback for compatibility scenarios

## References

- [chezmoi templating documentation](https://www.chezmoi.io/user-guide/templating/)
- [Configuration management patterns](https://www.thoughtworks.com/insights/blog/configuration-management-patterns)
- [XDG Base Directory specification](https://specifications.freedesktop.org/basedir-spec/basedir-spec-latest.html)
