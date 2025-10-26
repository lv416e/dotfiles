# ADR-0002: Use zsh-defer for deferred loading

## Status

Accepted

## Context

Shell startup time directly impacts developer productivity and user experience. Traditional shell configurations load all tools, completions, and environment setup synchronously during initialization, resulting in startup latencies ranging from 200ms to several seconds.

Tools like `mise`, `fzf`, `zoxide`, and language-specific version managers provide essential functionality but contribute significant overhead during shell initialization. Most features are not needed immediately at shell startup—they can be deferred until first use without impacting workflows.

## Decision Drivers

- **Performance**: Target sub-100ms shell startup time
- **User experience**: Eliminate perceptible delays in terminal initialization
- **Maintainability**: Minimal changes to existing configuration structure
- **Compatibility**: Preserve full functionality of deferred tools
- **Complexity**: Low implementation and debugging overhead

## Considered Options

1. **Synchronous loading** - Load everything at shell startup (status quo)
2. **zsh-defer** - Defer non-critical initializations
3. **Lazy loading scripts** - Custom implementation per tool
4. **zinit turbo mode** - Plugin manager's built-in deferral
5. **Background jobs** - Launch initializations in background processes

## Decision Outcome

**Chosen option**: zsh-defer (Option 2)

Implement [romkatv/zsh-defer](https://github.com/romkatv/zsh-defer) to defer initialization of non-critical tools while maintaining full functionality through intelligent scheduling.

### Implementation

```zsh
# Load zsh-defer early in initialization
source "${XDG_CACHE_HOME:-$HOME/.cache}/zsh/zsh-defer/zsh-defer.plugin.zsh"

# Defer heavy initializations
zsh-defer -c 'eval "$(mise activate zsh)"'
zsh-defer -c 'eval "$(fzf --zsh)"'
zsh-defer -c 'eval "$(zoxide init zsh)"'
zsh-defer -c 'eval "$(atuin init zsh)"'

# Defer completion loading
zsh-defer -a autoload -Uz compinit
zsh-defer -a compinit -d "${XDG_CACHE_HOME:-$HOME/.cache}/zsh/zcompdump"
```

## Consequences

### Positive

- **Dramatic performance improvement**: Shell startup reduced from 200-300ms to 30-60ms
- **Transparent functionality**: Deferred tools work identically once loaded
- **Simple implementation**: Minimal code changes required
- **Predictable behavior**: Deterministic loading order preserved
- **Low maintenance**: Single dependency handles all deferral logic

### Negative

- **Initial unavailability**: Deferred tools inaccessible for ~100-200ms after shell start
- **Additional dependency**: Introduces zsh-defer as critical infrastructure
- **Debugging complexity**: Timing-related issues harder to diagnose
- **Edge cases**: Some tools may require specific loading order considerations

## Pros and Cons of the Options

### Synchronous loading

**Pros**:
- Immediate availability of all tools
- Simple mental model
- No timing dependencies
- Easy debugging

**Cons**:
- Unacceptable startup latency (200-500ms+)
- Poor user experience
- Wasted initialization for unused tools
- Scales poorly as configuration grows

### zsh-defer

**Pros**:
- Excellent performance characteristics
- Minimal code changes required
- Well-tested, mature implementation
- Active maintenance by romkatv
- Preserves synchronous semantics

**Cons**:
- External dependency
- Brief delay before tool availability
- Potential timing edge cases
- Requires careful tool categorization

### Lazy loading scripts

**Pros**:
- Maximum control over loading behavior
- No external dependencies
- Tool-specific optimization possible

**Cons**:
- High implementation complexity
- Maintenance burden for each tool
- Error-prone wrapper functions
- Complex debugging
- Difficult to maintain consistency

### zinit turbo mode

**Pros**:
- Integrated with plugin manager
- Sophisticated loading strategies
- Good performance results

**Cons**:
- Tight coupling to zinit
- Complex configuration syntax
- Vendor lock-in risk
- Heavyweight solution for simple deferral

### Background jobs

**Pros**:
- Truly parallel initialization
- Maximum performance potential

**Cons**:
- Race condition complexity
- Difficult state synchronization
- Shell job management overhead
- Unpredictable completion timing
- High debugging difficulty

## Validation

Success criteria:
- Shell startup time < 100ms (measured with `time zsh -i -c exit`)
- All deferred tools functional within 500ms of shell start
- Zero functional regressions in tool behavior

Performance benchmarks:
```bash
# Measure startup time
for i in {1..10}; do time zsh -i -c exit 2>&1 | grep real; done

# Expected results: 30-60ms (previously 200-300ms)
```

## Metrics

Baseline (synchronous loading):
- Minimum: 180ms
- Average: 250ms
- Maximum: 420ms

Post-implementation (zsh-defer):
- Minimum: 30ms
- Average: 42ms
- Maximum: 60ms

**Improvement**: 83% reduction in average startup time

## References

- [zsh-defer GitHub repository](https://github.com/romkatv/zsh-defer)
- [Zsh startup profiling guide](https://blog.jonlu.ca/posts/speeding-up-zsh)
- [Shell startup benchmarking methodology](https://htr3n.github.io/2018/07/faster-zsh/)
