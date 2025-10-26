# ADR-0007: Difftastic integration

## Status

Accepted

## Context

Code review and diff analysis require understanding semantic changes, not syntactic ones. Traditional line-based diff tools (including git-delta) highlight every changed line but struggle with:
- Formatting changes (Prettier, Black, rustfmt output)
- Code movement and refactoring
- Structural changes in YAML/JSON
- Language-specific semantics

Difftastic uses tree-sitter parsers to perform structural diffs, comparing abstract syntax trees rather than text lines. This surfaces meaningful code changes while ignoring irrelevant formatting.

Git-delta excels at readable syntax highlighting for line-based diffs. Rather than replacing it, difftastic complements it for specific use cases requiring semantic analysis.

## Decision Drivers

- **Code review quality**: Focus on semantic changes
- **Refactoring analysis**: Track structural changes accurately
- **Post-formatter workflows**: Analyze changes after auto-formatting
- **Debugging efficiency**: Understand complex history
- **Default workflow preservation**: Maintain familiar git diff
- **Tool compatibility**: Integrate with existing delta setup

## Considered Options

1. **git-delta only** - Continue with line-based diff enhancement
2. **Replace delta with difftastic** - Switch to structural diff as default
3. **Complementary tools** - Use both for different scenarios
4. **Semantic diff service** - Use GitHub's or GitLab's built-in features
5. **Custom diff scripts** - Language-specific diff tools

## Decision Outcome

**Chosen option**: Complementary tools (Option 3)

Deploy difftastic alongside git-delta, using delta for general diffs (`git diff`) and difftastic for semantic analysis (`git ddiff`).

### Implementation

**Installation** (dot_Brewfile):
```ruby
brew "git-delta"      # Default diff viewer
brew "difftastic"     # Structural diff tool
```

**Git configuration** (dot_gitconfig.tmpl):
```ini
[core]
    pager = delta    # Default: delta for all commands

[diff]
    tool = difftastic

[difftool]
    prompt = false

[difftool "difftastic"]
    cmd = difft "$LOCAL" "$REMOTE"

[alias]
    ddiff = -c diff.external=difft diff
    dshow = -c diff.external=difft show --ext-diff
    dlog = -c diff.external=difft log -p --ext-diff
    dft = difftool
```

**Usage patterns**:
```bash
# Daily workflow: delta (line-based, syntax highlighted)
git diff
git show HEAD
git log -p

# Semantic analysis: difftastic (AST-based, structural)
git ddiff                    # Review changes after formatter
git dshow HEAD              # Understand refactoring commit
git dlog -n 5               # Analyze complex history
git dft path/to/file        # Compare specific files
```

## Consequences

### Positive

- **Best of both worlds**: Line-based for daily use, structural for analysis
- **Preserved workflows**: Muscle memory intact for `git diff`
- **Semantic clarity**: Refactoring and formatting changes properly contextualized
- **Language awareness**: Parser understands code structure
- **Zero switching cost**: Easy invocation via aliases
- **Format independence**: Changes clear despite reformatting

### Negative

- **Dual mental models**: Two different diff paradigms
- **Tool selection overhead**: Deciding which diff to use
- **Parser limitations**: Some languages lack tree-sitter support
- **Complex output**: Structural diffs can be harder to read initially
- **Performance cost**: Parsing overhead for large diffs

## Pros and Cons of the Options

### git-delta only

**Pros**:
- Single tool, simple mental model
- Excellent syntax highlighting
- Fast performance
- Wide language support

**Cons**:
- Line-based limitations
- Formatting noise
- Refactoring difficulty
- No structural awareness

### Replace delta with difftastic

**Pros**:
- Consistent structural analysis
- Format-independent changes
- Language-aware diffs

**Cons**:
- Breaking change to workflows
- Not ideal for all diff scenarios
- Slower for large diffs
- Limited language coverage

### Complementary tools

**Pros**:
- Optimized tool for each use case
- Gradual adoption
- No workflow disruption
- Flexibility in diff strategy

**Cons**:
- Dual tool maintenance
- Decision overhead
- Learning curve for both tools
- Increased complexity

### Semantic diff service

**Pros**:
- Zero local configuration
- Automatic in GitHub/GitLab
- Team collaboration features

**Cons**:
- Cloud dependency
- No local workflow integration
- Limited customization
- Vendor lock-in

### Custom diff scripts

**Pros**:
- Maximum control
- Language-specific optimization
- Tailored to exact needs

**Cons**:
- High implementation cost
- Maintenance burden
- Limited reusability
- Debugging complexity

## Use Case Matrix

| Scenario | Tool | Rationale |
|----------|------|-----------|
| Daily code review | delta | Fast, readable, familiar |
| Post-formatter analysis | difftastic | Ignores formatting, shows semantic changes |
| Refactoring review | difftastic | Tracks structural changes accurately |
| YAML/JSON changes | difftastic | Structural understanding crucial |
| Quick commits | delta | Speed and familiarity |
| Complex history debugging | difftastic | Semantic clarity through refactors |
| Hotfix review | delta | Quick visual scan |
| Architecture changes | difftastic | High-level structural view |

## Supported Languages

Difftastic supports 40+ languages via tree-sitter:
- **Full support**: Rust, Python, JavaScript, TypeScript, Go, Java, C, C++
- **Good support**: Ruby, PHP, Elixir, Haskell, OCaml, Scala
- **Basic support**: Bash, CSS, HTML, JSON, YAML, TOML, Markdown

Fallback to line-based diff for unsupported languages.

## Validation

Success criteria:
- Both tools installed and functional
- Difftastic used for 20%+ of diff operations
- Zero conflicts between delta and difftastic
- Measurable improvement in refactoring change clarity

Usage tracking:
```bash
# Monitor diff command usage
history | grep -E 'git (diff|ddiff|show|dshow)' | \
    awk '{print $3}' | sort | uniq -c

# Test both tools
git diff HEAD~1              # Should use delta
git ddiff HEAD~1             # Should use difftastic
```

## Real-World Scenarios

**Scenario 1: Post-Prettier formatting**
```bash
# After running Prettier on entire codebase
git ddiff
# Shows only semantic changes, ignoring 1000+ formatting changes
```

**Scenario 2: Complex refactoring**
```bash
# After extracting functions and moving code
git dshow HEAD
# Displays structural changes clearly, tracks moved code
```

**Scenario 3: YAML configuration update**
```bash
# After reorganizing nested YAML structure
git dft config.yaml
# Shows structural changes in hierarchical format
```

## Performance Characteristics

Benchmark on medium-sized repository:

```bash
# Line-based diff (delta): 50ms
time git diff HEAD~1 | wc -l

# Structural diff (difftastic): 200ms
time git ddiff HEAD~1 | wc -l

# Trade-off: 4x slower for semantic accuracy
```

Acceptable for analysis workflows; not for rapid iteration.

## References

- [Difftastic documentation](https://difftastic.wilfred.me.uk/)
- [git-delta repository](https://github.com/dandavison/delta)
- [Tree-sitter parsers](https://tree-sitter.github.io/tree-sitter/)
- [Structural diff comparison](https://news.ycombinator.com/item?id=29383796)
