# Repository Scoring Rubric

Use this rubric to assign consistent, objective scores to repository aspects.

## Overall Health Score (0-10)

Weighted average of all categories:
- Code Organization: 20%
- Documentation: 20%
- Testing: 15%
- Configuration: 15%
- Dependencies: 15%
- Security: 10%
- DevOps: 5%

## Code Organization (0-10)

### 10 - Excellent
- Crystal clear directory structure
- Perfect separation of concerns
- Consistent naming conventions
- Highly modular and reusable
- Zero code duplication
- Follows industry best practices

### 7-9 - Good
- Logical directory structure
- Good separation of concerns
- Mostly consistent naming
- Reasonable modularity
- Minimal code duplication
- Follows most best practices

### 4-6 - Fair
- Acceptable structure with some confusion
- Some mixing of concerns
- Inconsistent naming in places
- Limited modularity
- Some code duplication
- Misses some best practices

### 1-3 - Poor
- Confusing or flat structure
- Poor separation of concerns
- Inconsistent naming
- Monolithic code
- Significant duplication
- Ignores best practices

### 0 - Critical
- No discernible organization
- Complete mixing of concerns
- No naming conventions
- Unmaintainable

## Documentation (0-10)

### 10 - Excellent
- Comprehensive README
- All key files documented
- Clear setup instructions
- Usage examples provided
- API docs complete
- Code well-commented
- Up-to-date

### 7-9 - Good
- Good README
- Most files documented
- Setup instructions present
- Some examples
- API basics covered
- Adequate code comments
- Mostly up-to-date

### 4-6 - Fair
- Basic README
- Limited file documentation
- Minimal setup instructions
- Few examples
- Incomplete API docs
- Sparse code comments
- Some outdated sections

### 1-3 - Poor
- Minimal README
- No file documentation
- Missing setup instructions
- No examples
- No API docs
- Almost no comments
- Outdated

### 0 - Critical
- No README or documentation

## Testing (0-10)

### 10 - Excellent
- >80% code coverage
- Unit, integration, e2e tests
- All critical paths tested
- CI runs all tests
- Fast test suite
- Well-organized tests

### 7-9 - Good
- 60-80% coverage
- Good unit test coverage
- Some integration tests
- CI runs tests
- Reasonable test speed
- Tests well-organized

### 4-6 - Fair
- 30-60% coverage
- Basic unit tests
- Few integration tests
- Tests run manually
- Slow test suite
- Tests somewhat organized

### 1-3 - Poor
- <30% coverage
- Minimal unit tests
- No integration tests
- Tests often broken
- No test organization

### 0 - Critical
- No tests present

## Configuration (0-10)

### 10 - Excellent
- All configs present
- Well-documented
- Environment-specific
- Secrets properly managed
- Version-controlled
- Best practices followed

### 7-9 - Good
- Most configs present
- Documented
- Some env configs
- Secrets managed
- Version-controlled
- Good practices

### 4-6 - Fair
- Basic configs present
- Minimal documentation
- Limited env configs
- Basic secret management
- Some in version control

### 1-3 - Poor
- Missing key configs
- No documentation
- No env configs
- Poor secret management

### 0 - Critical
- No configuration management
- Secrets exposed

## Dependencies (0-10)

### 10 - Excellent
- All up-to-date
- Properly locked
- No vulnerabilities
- Minimal dependencies
- Well-organized
- License compliant

### 7-9 - Good
- Mostly up-to-date
- Locked versions
- Few vulnerabilities
- Reasonable dep count
- Organized
- Licenses checked

### 4-6 - Fair
- Some outdated
- Partially locked
- Some vulnerabilities
- Many dependencies
- Basic organization

### 1-3 - Poor
- Many outdated
- Not locked
- Multiple vulnerabilities
- Excessive dependencies

### 0 - Critical
- Critical vulnerabilities
- No version control

## Security (0-10)

### 10 - Excellent
- No secrets exposed
- All deps secure
- Security headers
- Input validation
- Auth/authz proper
- Security scanning
- Audit logs

### 7-9 - Good
- Secrets managed
- Most deps secure
- Basic security headers
- Some validation
- Auth implemented
- Basic scanning

### 4-6 - Fair
- Secrets mostly safe
- Some dep issues
- Limited headers
- Minimal validation
- Basic auth

### 1-3 - Poor
- Some secrets exposed
- Multiple dep vulns
- No security headers
- No validation

### 0 - Critical
- Secrets in git
- Critical vulnerabilities
- No security measures

## DevOps (0-10)

### 10 - Excellent
- Full CI/CD
- Automated tests
- Auto deployment
- Pre-commit hooks
- Quality gates
- Monitoring
- IaC

### 7-9 - Good
- CI configured
- Tests automated
- Manual deployment
- Some hooks
- Basic quality checks

### 4-6 - Fair
- Basic CI
- Some automation
- Manual processes
- Few hooks

### 1-3 - Poor
- Minimal CI
- Manual testing
- No automation

### 0 - Critical
- No CI/CD

## Quick Assessment Guide

### High-Performing Repository (8-10)
- Professional organization
- Comprehensive documentation
- Strong testing culture
- Secure by design
- Automated workflows
- Up-to-date dependencies
- Industry best practices

### Solid Repository (6-7)
- Good organization
- Adequate documentation
- Decent test coverage
- Basic security
- Some automation
- Mostly up-to-date
- Follows common practices

### Needs Work (4-5)
- Acceptable but inconsistent
- Limited documentation
- Sparse testing
- Security gaps
- Manual processes
- Some outdated deps
- Misses best practices

### Poor Repository (1-3)
- Disorganized
- Little documentation
- Minimal testing
- Security concerns
- No automation
- Outdated dependencies
- Ignores best practices

### Critical State (0)
- Unmaintainable
- No documentation
- No tests
- Security risks
- No process
- High technical debt
