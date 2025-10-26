# ADR-0001: Adopt Jujutsu alongside Git

## Status

Accepted

## Context

Version control workflows in modern development environments face several persistent challenges: complex conflict resolution, difficult commit history manipulation, and cognitive overhead from Git's staging area model. While Git remains the industry standard with universal adoption, emerging tools offer improved user experiences for common operations.

Jujutsu (jj) presents a modern approach to version control with first-class support for working with Git repositories while providing a cleaner operational model based on evolving changes rather than static commits.

## Decision Drivers

- **User experience**: Simplified mental model without staging area complexity
- **Safety**: Built-in operation log with trivial undo capabilities
- **Interoperability**: Full Git compatibility for team collaboration
- **Conflict resolution**: Superior handling of merge conflicts and rebases
- **Learning curve**: Investment required to master new tooling
- **Ecosystem maturity**: Tool stability and community support

## Considered Options

1. **Git only** - Continue with standard Git workflows
2. **Complete Jujutsu migration** - Replace Git entirely
3. **Parallel adoption** - Use both tools interchangeably
4. **Alternative VCS** - Evaluate Mercurial, Fossil, or Pijul

## Decision Outcome

**Chosen option**: Parallel adoption (Option 3)

Install Jujutsu alongside Git, allowing selective use based on task requirements while maintaining full Git compatibility for collaboration and CI/CD integration.

### Implementation

```bash
# Install via Homebrew
brew install jj

# Initialize in existing Git repository
cd ~/.local/share/chezmoi
jj git init --colocate

# Configure user identity
jj config set --user user.name "Name"
jj config set --user user.email "email@example.com"
```

## Consequences

### Positive

- **Improved workflow ergonomics**: Operations like `jj undo` eliminate anxiety about destructive actions
- **Better conflict resolution**: Automatic rebase conflict handling reduces manual intervention
- **Preserved Git compatibility**: Seamless integration with existing workflows and tooling
- **Enhanced history manipulation**: Edit any change in history without complex rebase gymnastics
- **Zero migration cost**: Colocated repositories require no team coordination

### Negative

- **Dual tooling maintenance**: Requires maintaining proficiency in both systems
- **Documentation overhead**: Team members need resources for both tools
- **Edge case complexity**: Some advanced Git operations may require fallback to Git
- **Cognitive switching cost**: Context switching between different operational models

## Pros and Cons of the Options

### Git only

**Pros**:
- Universal knowledge and tooling support
- No learning investment required
- Single mental model to maintain
- Comprehensive documentation and resources

**Cons**:
- Staging area adds conceptual overhead
- Destructive operations require careful execution
- Complex history manipulation with rebase
- Conflict resolution workflow remains challenging

### Complete Jujutsu migration

**Pros**:
- Consistent operational model
- Full benefit of Jujutsu's UX improvements
- Simplified mental model without Git legacy

**Cons**:
- Breaking change for team workflows
- CI/CD systems require reconfiguration
- Limited ecosystem tooling support
- High migration risk and cost

### Parallel adoption

**Pros**:
- Best-of-both-worlds approach
- Gradual learning curve
- No breaking changes for collaborators
- Selective tool usage based on task suitability

**Cons**:
- Dual mental models to maintain
- Increased cognitive load for tool selection
- Potential for operational confusion
- Documentation complexity

### Alternative VCS

**Pros** (Mercurial):
- Simpler model than Git
- Strong Windows support
- Consistent command structure

**Cons**:
- Declining ecosystem and adoption
- Limited modern tooling integration
- No Git interoperability without bridges

## Validation

Success criteria:
- Jujutsu handles 50%+ of local version control operations
- Zero conflicts between jj and git operations in colocated repository
- Subjective workflow satisfaction improvement

Monitoring:
- Track usage patterns via shell history
- Document problematic scenarios requiring Git fallback
- Measure time savings on complex history operations

## References

- [Jujutsu Documentation](https://github.com/martinvonz/jj)
- [Jujutsu vs Git comparison](https://v5.chriskrycho.com/essays/jj-init/)
- [Colocated repositories guide](https://martinvonz.github.io/jj/latest/working-with-git/)
