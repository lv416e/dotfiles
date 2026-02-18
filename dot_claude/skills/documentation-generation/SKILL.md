---
name: documentation-generation
description: "Use when generating or overhauling technical documentation - README files, API references, architecture docs, onboarding guides, changelogs - following documentation-as-code principles where docs live next to code, describe intent and contracts, and never duplicate what the code already says | 技術文書の生成または刷新時に使用 - READMEファイル、APIリファレンス、アーキテクチャ文書、オンボーディングガイド、変更履歴 - ドキュメント・アズ・コードの原則に従い、文書はコードの隣に置き、意図と契約を記述し、コードが既に述べていることを重複させない"
---

# Documentation Generation

## Overview

Bad documentation is worse than no documentation. Stale docs actively mislead. Docs that restate what the code says add noise without signal. Docs without examples are reference manuals nobody reads.

**Core principle:** Documentation describes INTENT and CONTRACTS, not implementation details. The code shows what happens. The docs explain why it matters and how to use it.

**If your docs require updating every time you refactor internals, you're documenting the wrong thing.**

**Announce at start:** "I'm using the documentation-generation skill to create this documentation."

## The Iron Law

```
DOCUMENTATION DESCRIBES INTENT AND CONTRACTS, NOT IMPLEMENTATION DETAILS
```

If a doc would become stale from an internal refactor that doesn't change behavior, that doc is wrong. Rewrite it to describe the contract, not the mechanism.

## When to Use

Generate documentation for ANY of these:

- **New project setup** (README from scratch)
- **API surface changes** (new endpoints, changed contracts)
- **Architecture overhaul** (system redesign, new components)
- **Onboarding friction** (new engineers keep asking the same questions)
- **Release milestones** (changelog entries, migration guides)
- **Public-facing libraries** (usage docs, API references, examples)

**Use this ESPECIALLY when:**
- There is no documentation at all (the most common case)
- Existing docs are stale and misleading (worse than nothing)
- Multiple teams consume your API or library
- Onboarding a new engineer takes more than a day of hand-holding
- Users file issues that are answered by reading the code

**Don't skip when:**
- Project is "just internal" (internal projects outlive their creators)
- "The code is self-documenting" (it isn't; it's self-describing at best)
- You're moving fast (fast without docs means fast into a wall)

## Documentation Types

Not all docs are equal. Each type serves a different audience at a different moment.

| Type | Audience | Purpose | When to Write |
|------|----------|---------|---------------|
| **README** | First-time visitors | "What is this and how do I start?" | Project creation, always keep current |
| **API Reference** | Developers integrating | "What can I call and what comes back?" | Every public interface change |
| **Architecture Docs** | Team members, future maintainers | "How does this system fit together and why?" | Initial design, major changes |
| **Onboarding Guide** | New team members | "How do I set up, build, test, and deploy?" | When onboarding takes too long |
| **Changelog** | Users, operators | "What changed and do I need to act?" | Every release |
| **Migration Guide** | Users upgrading | "How do I move from version N to N+1?" | Breaking changes |
| **ADR** | Future decision-makers | "Why did we choose this approach?" | Every architectural decision |
| **Runbook** | On-call engineers | "How do I diagnose and fix this in production?" | Every production system |

## The Four Phases

### Phase 1: Audit Existing Documentation

**Before writing anything new:**

1. **Inventory what exists**
   - What docs are present? Where do they live?
   - What's current? What's stale? What's missing entirely?
   - Are there docs in wikis, Notion, Google Docs that should be in the repo?

2. **Identify the gaps**
   - What questions do new engineers ask repeatedly?
   - What do users file issues about that docs should answer?
   - What tribal knowledge exists only in people's heads?

3. **Decide what to kill**
   - Stale docs that nobody maintains: DELETE. Don't "plan to update."
   - Duplicate docs: pick the canonical location, redirect or remove the rest.
   - Docs that describe implementation details: rewrite to describe contracts.

### Phase 2: Structure the Documentation

**Documentation-as-code principles:**

```
project/
├── README.md              # Entry point, always
├── docs/
│   ├── architecture.md    # System overview (C4 model)
│   ├── adr/               # Architecture decision records
│   │   ├── index.md
│   │   └── 0001-*.md
│   ├── api/               # API reference (or generated)
│   ├── guides/
│   │   ├── onboarding.md  # Getting started for developers
│   │   ├── deployment.md  # How to deploy
│   │   └── migration-v2.md
│   └── runbooks/          # Operational procedures
├── CHANGELOG.md           # At the root, always
└── CONTRIBUTING.md        # At the root, always
```

**Rules:**
- Docs live in the repo, version controlled with the code
- README.md is always the entry point
- CHANGELOG.md and CONTRIBUTING.md are always at the root
- Generated docs (from docstrings/JSDoc) go in `docs/api/`
- Guides go in `docs/guides/`
- Never put docs in a separate repo (they will drift immediately)

### Phase 3: Write Each Document Type

Follow the specific templates below for each type.

### Phase 4: Verify and Maintain

1. **Test all code examples** - Every snippet in docs must run. Copy-paste it and verify.
2. **Test all commands** - Every CLI command in docs must work. Run it.
3. **Link check** - Every internal link must resolve. Every external link should be verified.
4. **Review cycle** - Docs get reviewed in PRs just like code. No exceptions.

## README Template

The README is the front door. It answers: "What is this, why should I care, and how do I start?"

```markdown
# Project Name

[One-sentence description of what this does and who it's for.]

[![CI](badge-url)](ci-url)
[![Coverage](badge-url)](coverage-url)
[![License](badge-url)](license-url)

## Why

[2-3 sentences: What problem does this solve? Why does it exist?
Not "what it is" but "why you need it."]

## Quick Start

[Shortest possible path from zero to working. 5 steps maximum.]

### Prerequisites

- [Runtime] >= [version]
- [Dependency] (install: `command`)

### Install

```bash
npm install project-name
# or
pip install project-name
```

### Usage

```python
# Minimal working example - this MUST run as-is
from project import Thing

thing = Thing(config="value")
result = thing.do_something("input")
print(result)  # Expected output
```

## API

[Brief overview of main API surface. Link to full API docs if extensive.]

### `function_name(param1, param2) -> ReturnType`

[One sentence: what it does.]

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `param1` | `string` | Yes | What this parameter controls |
| `param2` | `int` | No | Default: `10`. What this parameter controls |

**Returns:** `ReturnType` - description

**Example:**
```python
result = function_name("value", param2=20)
```

## Configuration

[Table of configuration options with types, defaults, and descriptions.]

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for development setup, testing, and PR process.

## License

[License type] - see [LICENSE](LICENSE)
```

**README rules:**
- Quick Start must get someone to a working state in under 5 minutes
- Every code example must be copy-pasteable and runnable
- No "see code for details" - if it's in the README, explain it in the README
- Badges at the top: CI status, coverage, license, version
- Keep it concise. Link to detailed docs in `docs/` for depth.

## API Documentation from Code

Extract documentation from source code annotations. Don't maintain API docs separately from code.

### JSDoc / TypeScript

```typescript
/**
 * Retrieves a user by their unique identifier.
 *
 * @param id - The user's UUID
 * @returns The user object, or null if not found
 * @throws {AuthorizationError} If the caller lacks read permissions
 *
 * @example
 * ```typescript
 * const user = await getUser("550e8400-e29b-41d4-a716-446655440000");
 * if (user) {
 *   console.log(user.name);
 * }
 * ```
 */
async function getUser(id: string): Promise<User | null> {
```

### Python Docstrings

```python
def get_user(user_id: str) -> User | None:
    """Retrieve a user by their unique identifier.

    Args:
        user_id: The user's UUID string.

    Returns:
        The User object if found, None otherwise.

    Raises:
        AuthorizationError: If the caller lacks read permissions.
        ValueError: If user_id is not a valid UUID format.

    Example:
        >>> user = get_user("550e8400-e29b-41d4-a716-446655440000")
        >>> if user:
        ...     print(user.name)
    """
```

### Rules for Code-Level Docs

- Document the CONTRACT: what it accepts, what it returns, what can go wrong
- Don't document the MECHANISM: "iterates over the list and filters" is useless
- Every public function/method gets a docstring. No exceptions.
- Include at least one example for non-trivial functions
- Document exceptions/errors that callers need to handle
- Use the language's standard format (JSDoc, Google-style docstrings, rustdoc, godoc)

## Architecture Documentation (C4 Model)

Use the C4 model to document architecture at four zoom levels. Not every project needs all four.

### Level 1: System Context

"What is this system and what does it interact with?"

```markdown
## System Context

[Project Name] is a [type of system] that [what it does].

### External Systems
| System | Relationship | Protocol |
|--------|-------------|----------|
| User Browser | Sends requests | HTTPS |
| Payment Gateway | Processes payments | REST API |
| Email Service | Sends notifications | SMTP |
| Auth Provider | Authenticates users | OAuth 2.0 |
```

### Level 2: Container

"What are the major deployable units?"

```markdown
## Containers

| Container | Technology | Purpose |
|-----------|-----------|---------|
| Web App | Next.js | Serves UI, handles SSR |
| API Server | FastAPI | Business logic, REST endpoints |
| Worker | Celery | Async job processing |
| Database | PostgreSQL | Primary data store |
| Cache | Redis | Session store, query cache |
| Queue | RabbitMQ | Job queue for workers |
```

### Level 3: Component

"What are the major components inside each container?"

```markdown
## API Server Components

| Component | Responsibility | Key Interfaces |
|-----------|---------------|----------------|
| Auth Module | Token validation, permissions | `verify_token()`, `check_permission()` |
| Order Service | Order lifecycle management | `create_order()`, `cancel_order()` |
| Payment Service | Payment processing orchestration | `charge()`, `refund()` |
| Notification Service | Event-driven notifications | `notify()`, subscribes to order events |
```

### Level 4: Code

This level is the code itself. Don't write Level 4 docs. That's what the code and its docstrings are for.

### Rules for Architecture Docs

- Start at Level 1. Every project needs at least a System Context.
- Level 2 for any project with more than one deployable unit.
- Level 3 only when a container is complex enough to need it.
- Never Level 4 in docs. That's what code is for.
- Reference ADRs for "why" questions: "See ADR-0005 for why PostgreSQL over DynamoDB."
- Update architecture docs when containers or external systems change, not on every commit.

## Changelog Maintenance

Follow [Keep a Changelog](https://keepachangelog.com/) format. No exceptions.

```markdown
# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/),
and this project adheres to [Semantic Versioning](https://semver.org/).

## [Unreleased]

### Added
- New `/users/search` endpoint with full-text search (#142)

### Changed
- Rate limiting increased from 100 to 500 requests/minute (#138)

### Fixed
- Token refresh race condition causing intermittent 401s (#145)

## [2.1.0] - 2025-03-15

### Added
- Webhook support for order status changes (#130)
- Bulk user import endpoint (#127)

### Deprecated
- `GET /users/list` deprecated in favor of `GET /users` with pagination (#131)

### Security
- Upgrade jwt-decode to 4.0.0 to fix CVE-2024-XXXXX (#135)

[Unreleased]: https://github.com/org/repo/compare/v2.1.0...HEAD
[2.1.0]: https://github.com/org/repo/compare/v2.0.0...v2.1.0
```

### Changelog Rules

- **Added** for new features
- **Changed** for changes in existing functionality
- **Deprecated** for soon-to-be removed features
- **Removed** for now removed features
- **Fixed** for bug fixes
- **Security** for vulnerability fixes
- Always link to the issue or PR number
- Write for USERS, not developers: "Fixed login failing on Safari" not "Fixed null check in auth middleware"
- `[Unreleased]` section always exists at the top
- Update changelog in the same PR as the change, not retroactively

## Anti-Patterns

### Documenting Obvious Code

```
BAD:
# Increment counter by one
counter += 1

GOOD:
# Track failed login attempts for rate limiting (locks after 5 failures)
failed_attempts += 1
```

Document WHY, not WHAT. If the comment restates the code, delete it.

### Stale Documentation

```
BAD:  Write docs once, never update, let them rot for 2 years
GOOD: Docs are updated in the same PR that changes the behavior
```

The fix is process, not discipline. Make doc updates part of the PR checklist. Review docs in code review. If a PR changes behavior, the reviewer asks: "Where are the doc updates?"

### No Examples

```
BAD:
  `transform(data, options)` - Transforms the data with the given options.

GOOD:
  `transform(data, options)` - Applies configured transformations to the dataset.

  Example:
    result = transform(
        data=load_csv("input.csv"),
        options={"normalize": True, "drop_nulls": True}
    )
    # Returns a cleaned DataFrame with 0-1 scaled numeric columns
```

API docs without examples are dictionaries without example sentences. Technically complete, practically useless.

### Documentation in a Separate Repo

```
BAD:  Code in repo-A, docs in repo-B (drift guaranteed within a week)
GOOD: Code and docs in the same repo, same PR, same review
```

Documentation-as-code means docs are code artifacts. They version together, deploy together, and get reviewed together.

### Describing Implementation Instead of Intent

```
BAD:
  "This function iterates over all users, checks if their
   subscription_end_date is before today, and if so, sets
   their status to 'expired' and sends an email via SendGrid."

GOOD:
  "Expires subscriptions that have passed their end date.
   Affected users are notified via email.
   Runs daily via cron (see deployment docs)."
```

The first version breaks every time you change the implementation. The second survives refactors because it describes the contract.

## Common Rationalizations

| Excuse | Reality |
|--------|---------|
| "The code is self-documenting" | Code shows WHAT. Docs explain WHY, WHEN, and HOW TO USE. |
| "Nobody reads docs" | Nobody reads BAD docs. Good docs with examples get read constantly. |
| "Docs get stale immediately" | Only when docs describe implementation. Contract-level docs stay current. |
| "We'll write docs later" | You won't. Write them now or accept they'll never exist. |
| "README is enough" | README is the entry point, not the whole story. |
| "Just read the source" | Forcing users to read source is a failure of documentation. |
| "We move too fast for docs" | You move too fast for BAD docs. Good docs accelerate the team. |
| "It's only used internally" | Internal tools become critical infrastructure. Document them. |

## Quick Reference

| Phase | Key Activities | Success Criteria |
|-------|---------------|------------------|
| **1. Audit** | Inventory existing docs, identify gaps, kill stale docs | Clear picture of what exists and what's missing |
| **2. Structure** | Set up doc directory, choose types needed | `docs/` directory with clear organization |
| **3. Write** | Use templates, include examples, describe contracts | Every doc answers its audience's core questions |
| **4. Verify** | Test examples, check links, review in PR | All code runs, all links resolve, team approved |

## Integration with Other Skills

**This skill works with:**
- **architecture-decision-records** - ADRs provide the "why" behind architectural choices. Architecture docs reference ADRs for rationale. ADRs are a specific TYPE of documentation with their own format.
- **api-design** - API documentation is generated from well-designed APIs. Good API design makes good API docs possible. Bad API design makes good API docs impossible.
- **writing-plans** - Implementation plans often reveal documentation gaps. When a plan requires explaining context, that context should become permanent documentation.

**Workflow:**
```
Design API → Document contracts (API docs) → Record decisions (ADRs) → Write guides (onboarding, migration)
```

## Real-World Impact

From teams that adopted documentation-as-code:
- Onboarding time: reduced 50-70% (answers are findable, not tribal)
- Support tickets for "how do I...": reduced 60% (README and guides answer them)
- API integration time: reduced 40% (examples that actually run)
- Post-incident "nobody knew how this works": eliminated (architecture docs + runbooks)
- Time spent re-explaining decisions: near zero (ADRs + architecture docs)

