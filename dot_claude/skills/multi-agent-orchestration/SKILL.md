---
name: multi-agent-orchestration
description: "Use when work can be decomposed into independent, parallelizable tasks - Planner/Worker/Judge pattern for spawning subagents with bounded scope, clear acceptance criteria, and quality gates before merging results | 作業を独立した並列化可能なタスクに分解できる場合に使用 - 境界付きスコープ、明確な受け入れ基準、マージ前の品質ゲートを持つサブエージェント生成のためのPlanner/Worker/Judgeパターン"
---

# Multi-Agent Orchestration

## Overview

Sequential execution of parallelizable work is wasted time. But naive parallelization creates merge conflicts, duplicated effort, and incoherent results.

**Core principle:** Decompose into independent bounded tasks, execute in parallel with isolated contexts, verify before merging. The orchestrator thinks; the workers execute; the judge validates.

**Violating task boundaries is violating the entire pattern.**

## The Iron Law

```
EACH AGENT GETS ONE BOUNDED TASK WITH CLEAR ACCEPTANCE CRITERIA
```

If you cannot write a two-sentence task description with a concrete "done when" condition, the task is not ready for delegation.

## When to Use

Use when work decomposes into **independent** units:
- Writing tests for multiple modules simultaneously
- Implementing features that touch separate files/modules
- Reviewing multiple PRs or components in parallel
- Migrating multiple services/packages to a new pattern
- Generating documentation for separate subsystems
- Refactoring parallel, non-overlapping code paths

**Use this ESPECIALLY when:**
- You have 3+ tasks that don't depend on each other
- Each task takes more than a few minutes of focused work
- The work is well-understood enough to specify clearly upfront
- You need to maximize throughput under time pressure

**Do NOT use when:**
- Tasks have sequential dependencies (B needs output of A)
- Work requires continuous shared state or conversation
- The problem is not yet understood (use systematic-debugging first)
- There's only one task (overhead of orchestration exceeds benefit)
- Tasks heavily overlap in the files they modify

## The Three Roles

### Planner (You, the Orchestrator)

The Planner never writes code. The Planner decomposes, delegates, and coordinates.

**Responsibilities:**
1. Analyze the work and identify independent units
2. Define task boundaries and acceptance criteria
3. Assign each task to a Worker agent
4. Collect results and resolve conflicts
5. Dispatch Judge agent for quality verification

### Worker (Subagent via Task Tool)

Each Worker receives ONE bounded task and works in isolation.

**Characteristics:**
- Operates on a defined scope (specific files, specific module, specific test suite)
- Has no knowledge of other Workers or their tasks
- Produces a concrete deliverable (code, review, documentation)
- Reports success/failure with evidence

### Judge (Subagent via Task Tool)

The Judge reviews Worker output against acceptance criteria.

**Characteristics:**
- Receives the original task description + Worker output
- Evaluates against acceptance criteria only
- Returns PASS/FAIL with specific reasons
- Never fixes problems — sends back to a new Worker if FAIL

## The Five Phases

### Phase 1: Task Decomposition

**BEFORE spawning any agents:**

1. **Map the Work**
   - List all units of work
   - Identify file-level boundaries
   - Mark dependencies between units

2. **Find Independence**
   - Group work into non-overlapping scopes
   - A task is independent when: changing its output cannot break another task's output
   - If two tasks touch the same file → they are NOT independent (merge or sequence them)

3. **Write Task Specifications**

   Each task spec MUST include:
   ```
   TASK: [One-sentence description]
   SCOPE: [Exact files/modules/functions this task may touch]
   INPUT: [What the agent needs to know — context, requirements, examples]
   ACCEPTANCE CRITERIA: [Concrete "done when" conditions]
   CONSTRAINTS: [What the agent must NOT do — files to avoid, patterns to follow]
   ```

4. **Verify Decomposition**
   - Do any two tasks share files in their SCOPE? → Merge or sequence them
   - Can each task be completed without knowledge of the others? → If no, add missing INPUT
   - Are acceptance criteria testable? → If no, rewrite them

### Phase 2: Workspace Isolation

**Each Worker needs an isolated context.** Two strategies:

#### Strategy A: Git Worktrees (Preferred for Code Changes)

**REQUIRED SUB-SKILL:** Use **using-git-worktrees** to create one worktree per Worker.

```bash
# Orchestrator creates worktrees before spawning Workers
git worktree add .worktrees/task-auth -b orchestrate/task-auth
git worktree add .worktrees/task-api -b orchestrate/task-api
git worktree add .worktrees/task-tests -b orchestrate/task-tests
```

**Why worktrees:** Each Worker gets a full working copy. No merge conflicts during execution. Workers can build and test independently.

#### Strategy B: Scope Isolation (For Reviews, Analysis, Documentation)

When Workers produce output that doesn't modify the repository:
- Each Worker reads from the same codebase
- Each Worker writes to separate output locations
- No worktrees needed — shared read access is safe

### Phase 3: Worker Execution

**Spawn Workers using the Task tool with precise prompts.**

Each Task tool invocation MUST include:
1. The complete task specification from Phase 1
2. The working directory (worktree path if using Strategy A)
3. Relevant context the Worker cannot discover on its own
4. Explicit instruction to report completion status

**Task prompt template:**
```
You are a Worker agent. Complete this task and NOTHING ELSE.

TASK: Write unit tests for the authentication module.
SCOPE: Only modify files in src/auth/__tests__/
INPUT: The auth module exposes login(), logout(), refreshToken().
  Each function returns a Promise. See src/auth/index.ts for signatures.
ACCEPTANCE CRITERIA:
  - Tests cover all three exported functions
  - Tests cover success and error paths
  - All tests pass when run with `npm test -- --testPathPattern=auth`
  - No modifications outside src/auth/__tests__/
CONSTRAINTS:
  - Do NOT modify source code, only test files
  - Use existing test utilities from test/helpers.ts
  - Follow test naming patterns from src/users/__tests__/ as reference

Working directory: /project/.worktrees/task-auth-tests

When complete, report: PASS (all criteria met) or FAIL (which criteria unmet and why).
```

**Parallel execution:**
- Spawn all Workers simultaneously using multiple Task tool calls
- Do NOT wait for one Worker before spawning the next
- The orchestrator waits for all Workers to complete

### Phase 4: Result Merging

**After all Workers complete:**

1. **Collect Results**
   - Gather each Worker's completion status and output
   - Any FAIL? → Triage: re-specify and re-dispatch, or handle manually

2. **Merge Strategy (for code changes)**

   ```bash
   # Start from main development branch
   git checkout main

   # Merge each Worker's branch
   git merge orchestrate/task-auth --no-edit
   git merge orchestrate/task-api --no-edit
   git merge orchestrate/task-tests --no-edit
   ```

   **If merge conflict:**
   - STOP. Conflicts mean task boundaries were wrong.
   - Resolve manually. Document what overlapped.
   - Tighten boundaries for next time.

3. **Merge Strategy (for non-code output)**
   - Concatenate, deduplicate, or integrate outputs as appropriate
   - Check for contradictions between Worker outputs

### Phase 5: Quality Gate (Judge)

**BEFORE declaring done, spawn a Judge agent.**

```
You are a Judge agent. Review the following work against its acceptance criteria.

ORIGINAL TASK: [paste full specification]
WORKER OUTPUT: [paste result or point to changed files]

Evaluate EACH acceptance criterion:
- MET / NOT MET with specific evidence

Final verdict: PASS (all criteria met) or FAIL (list unmet criteria).

Do NOT fix anything. Only evaluate.
```

**If Judge returns FAIL:**
- Create a new Worker task addressing ONLY the unmet criteria
- Re-run Phase 3-5 for that specific remediation
- Do NOT re-run the entire orchestration

## Communication Patterns

### Orchestrator to Worker

- **Always:** Complete task spec, working directory, relevant context
- **Never:** Vague instructions, references to "the other tasks", shared mutable state

### Worker to Orchestrator

- **Always:** Completion status (PASS/FAIL), evidence of completion, list of files changed
- **Never:** Questions requiring orchestrator judgment mid-task (if Worker needs to ask, the task spec was incomplete)

### Orchestrator to Judge

- **Always:** Original task spec AND Worker output together
- **Never:** Just the output without the criteria to judge against

## Error Handling

| Situation | Action |
|-----------|--------|
| Worker reports FAIL | Re-read its output. Is the task spec wrong? Fix spec and re-dispatch. Is the code genuinely broken? Fix in a new focused Worker. |
| Worker modifies files outside its SCOPE | Discard that Worker's output entirely. The boundary violation means results are untrustworthy. Re-dispatch with stricter constraints. |
| Merge conflict between Worker branches | Resolve manually. This means your decomposition had overlapping scopes. Document and prevent next time. |
| Worker hangs or produces no output | Kill and re-dispatch. Likely the task spec was ambiguous or the scope was too large. Break it down further. |
| Judge returns FAIL on specific criteria | Spawn a NEW Worker to fix only the failing criteria. Do not re-run the entire task. |
| Multiple Workers fail on the same issue | STOP orchestration. Shared problem indicates missing context in Phase 1. Re-analyze before re-dispatching. |

## Practical Examples

### Example 1: Parallel Test Writing

```
DECOMPOSITION:
  Task 1: Write unit tests for src/auth/ → worktree: task-auth-tests
  Task 2: Write unit tests for src/billing/ → worktree: task-billing-tests
  Task 3: Write unit tests for src/notifications/ → worktree: task-notif-tests

WHY PARALLELIZABLE: Each test suite touches only its own __tests__/ directory.
No shared files. No shared state.

MERGE: Fast-forward merges (no conflicts possible if scopes are respected).
JUDGE: Run full test suite. All tests pass. No regressions.
```

### Example 2: Parallel Feature Implementation

```
DECOMPOSITION:
  Task 1: Add REST endpoint for /api/export (src/api/export.ts, src/api/export.test.ts)
  Task 2: Add CSV formatter (src/formatters/csv.ts, src/formatters/csv.test.ts)
  Task 3: Add email delivery integration (src/delivery/email.ts, src/delivery/email.test.ts)

WHY PARALLELIZABLE: Each feature is in a separate module with a defined interface.
Workers implement to the interface spec, not to each other's code.

MERGE: Sequential merges. Integration test after all merges.
JUDGE: Each module works in isolation. Integration test passes.
```

### Example 3: Parallel Code Review

```
DECOMPOSITION:
  Task 1: Review PR #42 for correctness and edge cases
  Task 2: Review PR #43 for security implications
  Task 3: Review PR #44 for performance impact

WHY PARALLELIZABLE: Each review is independent read-only analysis.
No file modifications. No worktrees needed.

MERGE: Collect all review comments. Deduplicate if PRs overlap.
JUDGE: Not needed (reviews are already evaluative).
```

## Red Flags - STOP and Re-Decompose

If you catch yourself thinking:
- "This Worker needs to know what the other Worker is doing"
- "I'll have them share this utility file"
- "Let me update the shared config and tell both Workers"
- "Worker 2 should wait for Worker 1's output"
- "I'll just have one Worker do both since they're related"
- "The merge conflicts aren't that bad, I'll resolve them"

**ALL of these mean: Your decomposition is wrong. Return to Phase 1.**

## Common Rationalizations

| Excuse | Reality |
|--------|---------|
| "Tasks are mostly independent, a little overlap is fine" | A little overlap guarantees merge conflicts. Eliminate overlap or sequence the dependent parts. |
| "I'll coordinate between Workers as they go" | Workers are isolated. Mid-task coordination means the task wasn't properly specified. |
| "One big task is easier than decomposing" | One big task is sequential. Decomposition is the entire point. If it can't decompose, don't use this pattern. |
| "The Judge step is overhead, I'll skip it" | Skipping quality gates means shipping unverified work. The Judge catches what each Worker misses about the whole. |
| "I'll parallelize everything for maximum speed" | Over-parallelization creates merge hell. Parallelize ONLY what is truly independent. |
| "Workers can figure out the details" | Vague specs produce vague results. Every minute spent on task specs saves ten minutes of rework. |
| "Just spawn more agents for more speed" | Diminishing returns. Communication overhead grows. 3-5 parallel Workers is usually the sweet spot. |
| "I'll fix the boundaries after seeing what conflicts" | Fix boundaries BEFORE execution. Post-hoc conflict resolution is the expensive path. |

## Quick Reference

| Phase | Key Activities | Success Criteria |
|-------|---------------|------------------|
| **1. Decompose** | Map work, find independence, write task specs | Each task has bounded scope, clear criteria, zero overlap |
| **2. Isolate** | Create worktrees or scope boundaries | Each Worker has isolated workspace |
| **3. Execute** | Spawn Workers in parallel via Task tool | All Workers complete with PASS status |
| **4. Merge** | Combine results, resolve any conflicts | Clean merges, integrated output |
| **5. Judge** | Quality gate review against criteria | All acceptance criteria verified MET |

## Integration with Other Skills

**This skill requires using:**
- **using-git-worktrees** - REQUIRED when Workers make code changes (see Phase 2, Strategy A)

**Complementary skills:**
- **writing-plans** - Use to create the implementation plan BEFORE decomposing into parallel tasks
- **executing-plans** - Each Worker follows plan execution within its bounded scope
- **systematic-debugging** - Use when a Worker fails and the cause is unclear
- **test-driven-development** - Workers writing code should follow TDD within their scope
- **requesting-code-review** - Judge agent role can be formalized as a code review request

**Called by:**
- **brainstorming** - When the design phase produces work that decomposes into parallel tracks
- **writing-plans** - When a plan identifies parallelizable implementation phases

## Decision: Parallel vs Sequential

```
Can tasks run without knowing each other's output?
  YES → Parallel (use this skill)
  NO  → Do they form a strict chain (A→B→C)?
          YES → Sequential (don't use this skill)
          NO  → Partial: group independent tasks, sequence dependent groups
```

**The overhead rule:** If you have fewer than 3 independent tasks, or each task takes under 2 minutes, the orchestration overhead exceeds the parallelization benefit. Just do them sequentially.

