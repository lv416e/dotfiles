---
name: architecture-decision-records
description: "Use when making any significant architectural decision - framework selection, infrastructure change, API design choice, database selection, pattern adoption - to record the decision in MADR format with full context, alternatives, and rationale so future engineers understand WHY | 重要なアーキテクチャ上の意思決定（フレームワーク選定、インフラ変更、API設計選択、データベース選定、パターン採用）を行う際に使用 - MADR形式で完全なコンテキスト、代替案、根拠を記録し、将来のエンジニアがなぜその決定をしたか理解できるようにする"
---

# Architecture Decision Records

## Overview

Architectural decisions made in hallways, Slack threads, and "let's just go with X" moments vanish. Six months later nobody remembers why PostgreSQL over DynamoDB, why REST over gRPC, why that particular auth pattern. Engineers reverse-engineer intent from code that was never designed to explain itself.

**Core principle:** EVERY architectural decision gets written down with context, alternatives, and consequences. No exceptions.

**If you didn't record it, you didn't decide it. You just happened to do something.**

**Announce at start:** "I'm using the architecture-decision-records skill to document this decision."

**Save ADRs to:** `docs/adr/NNNN-title-in-kebab-case.md`

## The Iron Law

```
EVERY ARCHITECTURAL DECISION GETS RECORDED WITH ALTERNATIVES AND RATIONALE
```

If there were no alternatives considered, you didn't make a decision. You drifted.

## When to Use

Write an ADR for ANY of these:

- **New framework or library** adoption (React, FastAPI, Terraform)
- **Infrastructure changes** (moving to Kubernetes, switching cloud providers, new CI/CD)
- **API design choices** (REST vs GraphQL, sync vs async, versioning strategy)
- **Database selection** (SQL vs NoSQL, which engine, schema strategy)
- **Significant pattern adoption** (event sourcing, CQRS, microservices split)
- **Authentication/authorization** approach changes
- **Breaking changes** to public interfaces
- **Build/deploy pipeline** architecture changes
- **Cross-cutting concerns** (logging strategy, error handling patterns, caching layer)

**Use this ESPECIALLY when:**
- Multiple valid approaches exist (if there's only one option, there's no decision)
- The team disagrees (record the disagreement and resolution)
- You're choosing something hard to reverse later
- Future-you will ask "why didn't we just..."
- A vendor or technology is being locked in

**Don't skip when:**
- Decision seems obvious (obvious decisions are the ones people question most later)
- Team is small ("we all know" stops being true the moment someone joins or leaves)
- You're in a hurry (writing the ADR takes 15 minutes; re-debating the decision later takes hours)

## MADR Format

Use Markdown Architecture Decision Records. Every ADR follows this structure exactly.

### Template

```markdown
# NNNN: [Decision Title]

**Status:** [Proposed | Accepted | Deprecated | Superseded by NNNN]

**Date:** YYYY-MM-DD

**Deciders:** [List people involved in the decision]

## Context

[What is the issue? What forces are at play? What constraints exist?
Write this so someone with ZERO project context understands the problem.
2-4 paragraphs. No jargon without explanation.]

## Decision

[What is the change being proposed or decided?
State it clearly in 1-3 paragraphs. Be specific about WHAT, not just "we chose X."
Include configuration, integration points, migration path if relevant.]

## Consequences

### Positive
- [What becomes easier or better]
- [What problems does this solve]

### Negative
- [What becomes harder]
- [What new constraints does this create]
- [What operational burden does this add]

### Neutral
- [Trade-offs that are neither clearly good nor bad]
- [Things that change but don't improve or worsen]

## Alternatives Considered

### Alternative 1: [Name]
- **Description:** [What this option would look like]
- **Pros:** [Why this was attractive]
- **Cons:** [Why we didn't choose this]
- **Reason rejected:** [One clear sentence]

### Alternative 2: [Name]
- **Description:** [What this option would look like]
- **Pros:** [Why this was attractive]
- **Cons:** [Why we didn't choose this]
- **Reason rejected:** [One clear sentence]

### Alternative 3: Do Nothing
- **Description:** [Keep current approach]
- **Pros:** [No migration cost, known behavior]
- **Cons:** [Why status quo is insufficient]
- **Reason rejected:** [One clear sentence]

## References

- [Links to relevant docs, RFCs, benchmarks, prior art]
- [Related ADRs: NNNN, NNNN]
```

## ADR Lifecycle

ADRs are immutable records. They move through states, never get deleted.

```
Proposed → Accepted → [Deprecated | Superseded]
```

| Status | Meaning |
|--------|---------|
| **Proposed** | Under discussion, not yet agreed upon |
| **Accepted** | Team agreed, this is the current approach |
| **Deprecated** | No longer relevant (technology retired, feature removed) |
| **Superseded by NNNN** | Replaced by a newer decision; link to the new ADR |

**Rules:**
- Never delete an ADR. Mark it Deprecated or Superseded.
- Never edit the Context or Alternatives of an Accepted ADR. If the decision changes, write a NEW ADR that supersedes it.
- Status changes and Date updates are the only permitted edits to Accepted ADRs.

## File Naming Convention

```
docs/adr/0001-use-postgresql-for-primary-datastore.md
docs/adr/0002-adopt-rest-over-grpc-for-public-api.md
docs/adr/0003-migrate-ci-from-jenkins-to-github-actions.md
```

**Rules:**
- Four-digit zero-padded number
- Kebab-case title
- Lowercase everything
- Numbers are sequential and never reused
- Keep an `docs/adr/index.md` listing all ADRs with status

### Index File Format

```markdown
# Architecture Decision Records

| ADR | Title | Status | Date |
|-----|-------|--------|------|
| [0001](0001-use-postgresql-for-primary-datastore.md) | Use PostgreSQL for primary datastore | Accepted | 2025-03-15 |
| [0002](0002-adopt-rest-over-grpc-for-public-api.md) | Adopt REST over gRPC for public API | Accepted | 2025-04-02 |
| [0003](0003-migrate-ci-from-jenkins-to-github-actions.md) | Migrate CI from Jenkins to GitHub Actions | Proposed | 2025-04-10 |
```

## Linking ADRs to Code

Decisions mean nothing if engineers can't find them when working on the code they govern.

### In Code Comments

```python
# Architecture: See ADR-0001 for why PostgreSQL over DynamoDB
connection = psycopg2.connect(...)

# Architecture: See ADR-0007 for retry strategy rationale
@retry(max_attempts=3, backoff=exponential)
def call_external_service():
    ...
```

### In Commit Messages

```
feat: add Redis caching layer for user sessions

Implements caching strategy from ADR-0012.
Uses write-through pattern with 15-minute TTL.
```

### In Pull Requests

```markdown
## Related ADRs
- Implements ADR-0012 (Redis caching strategy)
- Relates to ADR-0008 (session management approach)
```

### In Configuration Files

```yaml
# Architecture: ADR-0003 - GitHub Actions chosen over Jenkins
# See docs/adr/0003-migrate-ci-from-jenkins-to-github-actions.md
name: CI Pipeline
on: [push, pull_request]
```

## The Three Phases

### Phase 1: Identify the Decision Point

**Before writing anything:**

1. **Is this actually an architectural decision?**
   - Does it affect multiple components or teams?
   - Is it hard to reverse once implemented?
   - Will future engineers need to know WHY?
   - If yes to any: write an ADR.

2. **Check existing ADRs**
   - Has this already been decided? Check `docs/adr/index.md`
   - Is this superseding a previous decision? Reference it.
   - Are there related ADRs that constrain your options?

3. **Gather context**
   - What constraints exist (budget, timeline, team skill, existing infrastructure)?
   - What has been tried before?
   - What do stakeholders care about?

### Phase 2: Research Alternatives

**You MUST consider at least two alternatives plus "do nothing":**

1. **Research genuinely viable options**
   - Don't include straw-man alternatives just to pad the list
   - Each alternative should be something a reasonable engineer might choose
   - Include the option you're leaning toward AND at least one you're not

2. **Evaluate honestly**
   - List real pros, not just "it's popular"
   - List real cons, not just "it's less popular"
   - Use evidence: benchmarks, case studies, team experience
   - Acknowledge uncertainty. "We don't know how this scales past 10K requests/sec" is valid.

3. **Always include "Do Nothing"**
   - Status quo is always an option
   - If "do nothing" is genuinely fine, you probably don't need an ADR
   - Forces you to articulate why change is necessary

### Phase 3: Write and Review

1. **Draft the ADR** using the template above
2. **Context check:** Could a new team member understand this without asking questions?
3. **Alternatives check:** Would someone who disagrees feel their option was fairly represented?
4. **Consequences check:** Are you honest about the downsides?
5. **Get the ADR reviewed** before marking Accepted

## Anti-Patterns

### Recording Too Late

```
BAD:  Ship feature → months later → "we should document why we chose X"
GOOD: Identify decision point → write ADR → implement decision
```

The ADR is written BEFORE or DURING implementation, never after. Memory is unreliable. Context is lost. Alternatives are forgotten.

### No Alternatives Section

```
BAD:  "We decided to use Kafka." (Why? Over what? What did you consider?)
GOOD: "We decided to use Kafka over RabbitMQ and SQS because..."
```

An ADR without alternatives is a press release, not a decision record.

### Vague Context

```
BAD:  "We need a message queue."
GOOD: "Our order processing pipeline currently processes events synchronously,
       causing 500ms p99 latency. We need asynchronous event processing that
       handles 5,000 events/second with at-least-once delivery guarantees."
```

Context must include specific constraints, numbers, and requirements. If you can't articulate the problem precisely, you're not ready to make the decision.

### Rubber-Stamp ADRs

```
BAD:  Writing the ADR after the decision is already implemented and irreversible
GOOD: Writing the ADR when the decision is still open for discussion
```

If the ADR is Proposed but everyone knows the code is already merged, the process is theater. Write ADRs when they can still influence the outcome.

### Missing Consequences

```
BAD:  Consequences: "This will work well for our use case."
GOOD: Consequences:
      Positive: Handles our 5K events/sec requirement with headroom
      Negative: Adds operational complexity (ZooKeeper cluster management),
                team has no Kafka experience (2-week ramp-up estimated)
```

Every decision has negative consequences. If you can't list any, you haven't thought hard enough.

## Common Rationalizations

| Excuse | Reality |
|--------|---------|
| "Everyone knows why we chose this" | They won't in 6 months. New hires never will. |
| "It's obvious, no need to document" | If it's obvious, the ADR takes 10 minutes. Write it. |
| "We can always change it later" | Without the ADR, nobody will know when or why to change it. |
| "Too busy shipping features" | Re-debating undocumented decisions wastes more time than writing ADRs. |
| "It's just a library choice" | Libraries shape architecture. If you debated it, record it. |
| "We'll document it in the wiki" | Wikis are where decisions go to die. ADRs live with the code. |
| "The PR description explains it" | PRs explain WHAT changed. ADRs explain WHY this approach over others. |
| "Only two of us, we'll remember" | You won't. And you won't always be two. |

## Quick Reference

| Phase | Key Activities | Success Criteria |
|-------|---------------|------------------|
| **1. Identify** | Confirm decision point, check existing ADRs, gather context | Clear problem statement with constraints |
| **2. Research** | Evaluate alternatives, gather evidence, include "do nothing" | At least 3 options fairly evaluated |
| **3. Write** | Draft ADR, review for completeness, get team input | New engineer could understand without asking questions |

## Integration with Other Skills

**This skill works with:**
- **writing-plans** - Implementation plans should reference the ADRs that drove architectural choices. Plans answer HOW; ADRs answer WHY.
- **brainstorming** - Brainstorming sessions often surface architectural decisions. When a brainstorm converges on a choice, capture it as an ADR before moving to planning.
- **documentation-generation** - Architecture documentation (C4 model) should reference ADRs for detailed rationale. ADRs feed into the "why" layer of architecture docs.

**Workflow:**
```
Brainstorm → ADR (capture decision) → Plan (implement decision) → Documentation (explain system)
```

## Real-World Impact

From teams that adopted ADRs:
- Onboarding time: reduced 40% (new engineers stop asking "why did we...")
- Re-litigation of decisions: reduced 80% (the record settles debates)
- Decision quality: improved (writing alternatives forces rigorous thinking)
- Post-mortem root causes: traceable (bad outcomes link back to specific decisions)
- Architecture drift: reduced (decisions are visible and reviewable)

