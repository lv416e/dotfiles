# Repository Analysis Checklist

Use this checklist to ensure comprehensive repository analysis.

## Pre-Analysis

- [ ] Identify repository location and type
- [ ] Check git status and repository health
- [ ] Determine analysis scope with user (quick/standard/deep)
- [ ] Note any specific focus areas requested

## Discovery Phase

- [ ] Run quick-stats.sh for overview
- [ ] Run find-configs.sh for configuration discovery
- [ ] Launch Explore agent for structure analysis
- [ ] Identify primary programming language(s)
- [ ] Locate entry points and main files

## Technology Stack

- [ ] List all programming languages used
- [ ] Identify package manager(s)
- [ ] Extract all dependencies (production + dev)
- [ ] Identify frameworks and libraries
- [ ] Note development tools (linters, formatters, etc.)
- [ ] Check for containerization (Docker)
- [ ] Review CI/CD configuration

## Best Practices Research

- [ ] Context7 lookup for major frameworks
- [ ] Web search for language-specific best practices
- [ ] Web search for framework-specific patterns
- [ ] Research security best practices
- [ ] Check dependency management strategies

## Configuration Analysis

- [ ] Review package manager configs
- [ ] Check build tool configurations
- [ ] Evaluate linter/formatter settings
- [ ] Assess environment variable management
- [ ] Review Docker configurations (if applicable)
- [ ] Analyze CI/CD pipeline setup
- [ ] Check git configuration (.gitignore, etc.)

## Documentation Assessment

- [ ] README.md existence and quality
- [ ] CONTRIBUTING.md present?
- [ ] LICENSE file present?
- [ ] CHANGELOG.md or release notes?
- [ ] API documentation?
- [ ] Code comments quality
- [ ] Setup/installation instructions
- [ ] Usage examples

## Code Quality

- [ ] Directory structure organization
- [ ] Naming conventions consistency
- [ ] Code modularity
- [ ] Separation of concerns
- [ ] Testing strategy and coverage
- [ ] Error handling patterns
- [ ] Logging approach

## Security & Dependencies

- [ ] Secret management approach
- [ ] Dependency vulnerability check
- [ ] Version locking strategy
- [ ] Security headers/configurations
- [ ] Authentication/authorization patterns
- [ ] Input validation

## DevOps & Automation

- [ ] CI/CD pipeline effectiveness
- [ ] Automated testing
- [ ] Code quality checks
- [ ] Deployment automation
- [ ] Pre-commit hooks
- [ ] Branch protection

## Synthesis

- [ ] Calculate overall health score
- [ ] Identify critical issues
- [ ] List important improvements
- [ ] Note nice-to-have enhancements
- [ ] Document quick wins
- [ ] Provide actionable recommendations
- [ ] Cite all sources

## Report Generation

- [ ] Executive summary written
- [ ] All sections completed
- [ ] Recommendations prioritized
- [ ] Sources attributed
- [ ] Next steps defined
- [ ] Report formatted properly

## Quality Check

- [ ] All findings have evidence
- [ ] Recommendations are specific and actionable
- [ ] Tone is constructive, not critical
- [ ] Confidence levels stated where uncertain
- [ ] Report is well-structured and readable
- [ ] User's specific questions answered

## Follow-up

- [ ] Offer to deep-dive into specific areas
- [ ] Ask if user wants report saved to file
- [ ] Suggest monitoring/maintenance plan
- [ ] Provide implementation priority guidance
