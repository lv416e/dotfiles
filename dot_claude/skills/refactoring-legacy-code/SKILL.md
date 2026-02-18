---
name: refactoring-legacy-code
description: "Use when modernizing, migrating, or restructuring existing code - systematic approach to safe refactoring through characterization tests, dependency analysis, strangler fig migration, and incremental transformation; ensures no behavior changes without test coverage first | 既存コードのモダナイゼーション、移行、再構築時に使用 - 特性テスト、依存関係分析、ストラングラーフィグ移行、段階的変換による安全なリファクタリングの体系的アプローチ。テストカバレッジなしでの動作変更を防止"
---

# Refactoring Legacy Code

## Overview

Big-bang rewrites fail. Refactoring without tests creates new bugs. Scope creep turns a "quick cleanup" into a six-month project.

**Core principle:** ALWAYS write characterization tests before changing legacy code. Understand current behavior before changing it.

**Violating the letter of this process is violating the spirit of refactoring.**

## The Iron Law

```
NO REFACTORING WITHOUT CHARACTERIZATION TESTS FIRST
```

If you haven't captured existing behavior in tests, you cannot change the code.

No exceptions:
- Not for "obvious" improvements
- Not for "simple" renames
- Not for "just moving code around"
- Not even for formatting changes that touch logic

## When to Use

Use for ANY code modernization work:
- Framework/library migration (class components to hooks, Angular to React, Python 2 to 3)
- Updating deprecated APIs
- Breaking monoliths into modules
- Replacing legacy patterns with modern idioms
- Reducing technical debt
- Extracting shared libraries
- Upgrading major dependency versions

**Use this ESPECIALLY when:**
- Code has no tests (most legacy code)
- You don't fully understand what the code does
- Multiple teams depend on this code
- "Just a quick refactor" is proposed
- Someone says "let's rewrite it from scratch"
- The code is older than the team working on it

**Don't skip when:**
- Refactoring seems trivial (trivial changes break things too)
- You're confident you understand the code (you don't, fully)
- Deadline pressure says "just do it" (broken code after refactoring costs more)

## The Five Phases

You MUST complete each phase before proceeding to the next.

### Phase 1: Reconnaissance

**BEFORE touching ANY code:**

1. **Map the Dependency Graph**
   - What depends on this code?
   - What does this code depend on?
   - Draw it out: imports, API consumers, database schemas, config files
   - Use tooling: dependency analyzers, import graphs, call hierarchies

   ```bash
   # Example: find all consumers of a module
   grep -r "import.*from.*legacy-module" --include="*.ts" src/
   grep -r "require.*legacy-module" --include="*.js" src/

   # Example: find all callers of a function
   grep -rn "legacyFunction\(" --include="*.py" .
   ```

2. **Identify the Blast Radius**
   - What breaks if this code changes?
   - Which teams, services, or systems are affected?
   - Are there downstream consumers you don't control?
   - Is there a public API contract?

3. **Catalog Code Smells and Prioritize**

   Not all smells are equal. Prioritize by impact:

   | Priority | Smell | Why |
   |----------|-------|-----|
   | **Critical** | Shared mutable state | Causes race conditions, impossible to reason about |
   | **Critical** | No separation of concerns | Changes ripple everywhere |
   | **High** | God classes/functions (500+ lines) | Untestable, incomprehensible |
   | **High** | Circular dependencies | Prevents modularization |
   | **Medium** | Copy-paste duplication | Bugs fixed in one copy, not others |
   | **Medium** | Primitive obsession | Stringly-typed code hides bugs |
   | **Low** | Naming conventions | Confusing but functional |
   | **Low** | Formatting inconsistency | Cosmetic, fix with tooling |

4. **Understand Before Changing**
   - Read the code thoroughly. Don't skim.
   - Trace execution paths manually
   - Read commit history: WHY was it written this way?
   - Check for commented-out code with explanations
   - Look for "HACK", "TODO", "FIXME" comments - they're documentation

5. **Define the Target State**
   - What does "done" look like?
   - Draw the target architecture
   - Write it down. Be specific.
   - If you can't describe the end state, you're not ready to start

### Phase 2: Characterization Tests

**REQUIRED before any code changes. No exceptions.**

Characterization tests capture CURRENT behavior, not DESIRED behavior. They answer: "What does this code actually do?"

1. **Write Tests for Current Behavior**

   ```python
   # Characterization test: capture what the code DOES, not what it SHOULD do
   def test_legacy_price_calculator_with_negative_quantity():
       # Legacy code silently returns 0 for negative quantities
       # This might be a bug, but it's CURRENT behavior
       result = calculate_price(item="widget", quantity=-5, price=10.00)
       assert result == 0  # Captures actual behavior

   def test_legacy_price_calculator_with_none_price():
       # Legacy code treats None as 0 - probably wrong, but current behavior
       result = calculate_price(item="widget", quantity=5, price=None)
       assert result == 0  # Captures actual behavior
   ```

2. **Cover All Code Paths**
   - Happy paths
   - Error paths
   - Edge cases (null, empty, negative, overflow)
   - Boundary conditions
   - Side effects (files written, APIs called, state mutated)

3. **Use Approval Testing for Complex Output**

   For code with complex output (HTML, reports, serialized data):
   ```python
   def test_legacy_report_generator():
       result = generate_report(sample_data)
       # First run: manually approve the output as "golden"
       # Subsequent runs: compare against golden file
       assert result == load_golden_file("report_golden.txt")
   ```

4. **Test the Boundaries, Not the Internals**
   - Test at public API surfaces
   - Test at module boundaries
   - Don't test private methods (they'll change during refactoring)
   - Focus on inputs and outputs

5. **Verify Tests Catch Changes**
   - Make a small intentional change to the legacy code
   - Confirm at least one test fails
   - Revert the change
   - If no test fails, your tests are inadequate

**Characterization test coverage must be sufficient before proceeding.**

### Phase 3: Incremental Migration Strategy

**Choose your pattern. Big-bang is NOT an option.**

#### The Strangler Fig Pattern

Wrap legacy code. Route new calls through new code. Gradually migrate old calls. Remove legacy when empty.

```
Phase A: Legacy handles everything
  [All Traffic] → [Legacy System]

Phase B: New code wraps legacy, intercepts some paths
  [All Traffic] → [Facade/Router]
                      ├── [New Code] (migrated paths)
                      └── [Legacy Code] (remaining paths)

Phase C: All paths migrated
  [All Traffic] → [New Code]
  [Legacy Code] ← (dead, remove it)
```

**Implementation:**

```typescript
// Step 1: Create facade that delegates to legacy
class UserServiceFacade {
  private legacy = new LegacyUserService();

  getUser(id: string): User {
    return this.legacy.getUser(id);  // Pass-through initially
  }
}

// Step 2: Migrate one method at a time
class UserServiceFacade {
  private legacy = new LegacyUserService();
  private modern = new ModernUserService();

  getUser(id: string): User {
    return this.modern.getUser(id);  // Migrated!
  }

  updateUser(id: string, data: UserData): void {
    return this.legacy.updateUser(id, data);  // Not yet migrated
  }
}

// Step 3: When all methods migrated, remove facade and legacy
```

#### Branch by Abstraction

For internal modules you can't wrap with a facade:

1. Create an abstraction (interface) over the existing implementation
2. Modify all clients to use the abstraction
3. Build new implementation behind same abstraction
4. Switch implementations (feature flag, config, or direct swap)
5. Remove old implementation

```typescript
// Step 1: Extract interface from legacy
interface DataStore {
  get(key: string): Promise<unknown>;
  set(key: string, value: unknown): Promise<void>;
}

// Step 2: Legacy implements interface
class LegacyFileStore implements DataStore { /* ... */ }

// Step 3: New implementation
class ModernDatabaseStore implements DataStore { /* ... */ }

// Step 4: Swap via configuration
const store: DataStore = config.useModernStore
  ? new ModernDatabaseStore()
  : new LegacyFileStore();
```

#### Feature Flags for Gradual Rollout

```typescript
function processOrder(order: Order): Result {
  if (featureFlags.isEnabled('modern-order-processing', order.userId)) {
    return modernProcessOrder(order);
  }
  return legacyProcessOrder(order);
}
```

Roll out to 1% of users, then 10%, 50%, 100%. Rollback instantly if issues arise.

### Phase 4: Execute Refactoring

**One transformation at a time. Run tests after EVERY change.**

1. **Make ONE Change**
   - Rename a function
   - Extract a method
   - Move a class
   - Replace one deprecated API call
   - ONE thing

2. **Run ALL Tests**
   ```bash
   # After every single change
   npm test        # or pytest, or cargo test, or whatever
   ```
   - All characterization tests pass? Continue.
   - Any test fails? Revert. Understand why. Try again.

3. **Commit Frequently**
   - Each atomic change gets its own commit
   - Commit messages describe the refactoring step
   - Easy to bisect if something breaks later
   - Easy to revert one step without losing everything

   ```bash
   git commit -m "Extract validation logic from OrderProcessor.process()"
   git commit -m "Rename UserManager to UserRepository"
   git commit -m "Replace deprecated crypto.createCipher with crypto.createCipheriv"
   ```

4. **Common Safe Transformations**

   These are mechanical and should not change behavior:

   | Transformation | Risk | Verify |
   |---------------|------|--------|
   | Rename (variable, function, class) | Low | Tests pass, grep for old name |
   | Extract method/function | Low | Tests pass, behavior identical |
   | Inline method/function | Low | Tests pass |
   | Move to different file/module | Medium | Tests pass, imports updated |
   | Extract interface | Low | Tests pass, no behavior change |
   | Replace inheritance with composition | Medium | Tests pass, behavior identical |
   | Replace deprecated API | Medium | Tests pass, read migration guide completely |
   | Change data structure | High | Tests pass, check serialization/persistence |

5. **Parallel Implementation for High-Risk Changes**

   When transformation risk is high:
   ```python
   def process_payment(order):
       legacy_result = legacy_process_payment(order)
       modern_result = modern_process_payment(order)

       if legacy_result != modern_result:
           log.error(f"MISMATCH: legacy={legacy_result}, modern={modern_result}")
           # Use legacy result until mismatch rate is 0%
           return legacy_result

       return modern_result
   ```

### Phase 5: Cleanup and Verification

1. **Remove Dead Code**
   - Delete the legacy code paths
   - Remove feature flags for completed migrations
   - Delete characterization tests that tested legacy-specific behavior
   - Keep tests that verify correct behavior regardless of implementation

2. **Update Documentation**
   - Architecture diagrams
   - API documentation
   - Onboarding guides
   - Dependency maps

3. **Verify End-to-End**
   - Integration tests pass
   - Performance benchmarks meet or exceed legacy
   - No regressions in dependent systems
   - Monitoring shows healthy behavior

4. **Retrospective**
   - What took longer than expected?
   - What broke that tests didn't catch?
   - What would you do differently?
   - Update this process for next time

## Red Flags - STOP and Follow Process

If you catch yourself thinking:
- "Let's just rewrite it from scratch"
- "This code is so bad, tests won't help"
- "I understand it well enough to change it without tests"
- "Quick rename, no tests needed"
- "Let me refactor this other thing while I'm here"
- "We'll add tests after the refactoring"
- "It's just moving code around"
- "The old tests will catch any problems"
- "Let me fix this bug I found while refactoring"
- "This is taking too long, let me skip the characterization tests"
- "One big PR is easier to review than ten small ones"

**ALL of these mean: STOP. Return to Phase 2.**

**If scope is growing:** You're in scope creep. Finish the current refactoring. File tickets for new work. ONE thing at a time.

## Common Rationalizations

| Excuse | Reality |
|--------|---------|
| "Code is too messy to test" | That's exactly why you need tests. Use characterization tests at the boundary. |
| "Rewrite will be faster" | Rewrites take 3-10x longer than estimated. You'll re-discover every edge case the hard way. |
| "Tests slow us down" | Tests slow you down 10 minutes now. No tests slow you down 10 days later. |
| "I know what this code does" | You know what you THINK it does. Characterization tests reveal what it ACTUALLY does. |
| "Small change, no test needed" | Small changes compound. One untested change invites another. |
| "We'll migrate all at once over the weekend" | Big-bang migrations fail. Always. No exceptions. |
| "Legacy code is too coupled to test" | Use seams: subclass-and-override, extract-and-override, parameterize constructor. |
| "Refactoring while fixing bugs saves time" | Mixing refactoring with behavior changes makes both harder to verify. Separate them. |
| "The old tests are enough" | Old tests test old behavior. Characterization tests verify you understand CURRENT behavior. |
| "Feature flags add complexity" | Feature flags add CONTROLLED complexity. Big-bang adds UNCONTROLLED chaos. |
| "Nobody understands this code anyway" | That's the reason to go slow, not fast. |

## Framework/Library Migration Checklist

When migrating frameworks (e.g., class components to hooks, jQuery to React, Python 2 to 3):

1. **Read the official migration guide COMPLETELY** - Don't skim. Every line.
2. **Identify all deprecated patterns** in your codebase
   ```bash
   # Example: find React class components
   grep -rn "extends React.Component\|extends Component" --include="*.tsx" src/
   ```
3. **Create a migration spreadsheet** - Every file, current pattern, target pattern, status
4. **Migrate ONE file first** - The simplest one. Get it working. Learn the gotchas.
5. **Document the gotchas** - Every surprise becomes a checklist item
6. **Migrate in dependency order** - Leaves first, then branches, then trunk
7. **Run codemods where possible** - Automated transforms are safer than manual
   ```bash
   # Example: React class to function component codemod
   npx react-codemod rename-unsafe-lifecycles ./src
   ```
8. **Verify each file independently** - Tests pass after each file migration
9. **Never mix migration with feature work** - Separate commits, separate PRs

## Dependency Graph Analysis

**Before touching code, understand the dependency graph:**

```
Step 1: Map imports/requires
  module-a → module-b → module-c
                       → module-d
  module-e → module-b

Step 2: Identify the refactoring order
  Leaves first: module-c, module-d (no dependents to break)
  Then: module-b (update after c and d are stable)
  Then: module-a, module-e (consumers of b)

Step 3: Identify circular dependencies (DANGER)
  module-a → module-b → module-a  ← BREAK THIS FIRST
```

**Rules:**
- Refactor leaves before branches
- Never refactor a module while its dependencies are also changing
- Break circular dependencies BEFORE other refactoring
- One layer at a time, bottom-up

## Breaking Monoliths into Modules

1. **Identify Seams** - Natural boundaries where code can be split
2. **Extract Data First** - Separate data access from business logic
3. **Create Module Boundaries** - Define interfaces between modules
4. **Enforce Boundaries** - Lint rules, import restrictions, separate packages
5. **Extract Gradually** - One module at a time, verify after each

```typescript
// Before: God module
// user-management.ts (2000 lines)
export function createUser() { /* ... */ }
export function authenticateUser() { /* ... */ }
export function getUserProfile() { /* ... */ }
export function updateUserPreferences() { /* ... */ }
export function sendUserNotification() { /* ... */ }
export function generateUserReport() { /* ... */ }

// After: Separated by concern
// users/creation.ts
export function createUser() { /* ... */ }

// users/authentication.ts
export function authenticateUser() { /* ... */ }

// users/profile.ts
export function getUserProfile() { /* ... */ }
export function updateUserPreferences() { /* ... */ }

// notifications/user-notifications.ts
export function sendUserNotification() { /* ... */ }

// reports/user-reports.ts
export function generateUserReport() { /* ... */ }
```

## Updating Deprecated APIs

1. **Find all usages** of the deprecated API
2. **Read the deprecation notice** - What replaces it? What changed?
3. **Write characterization tests** around each usage
4. **Replace ONE usage at a time**
5. **Test after each replacement**
6. **Search again** - Did you miss any? Dynamic calls? Reflection? Config files?

```python
# Before: deprecated API
import warnings
with warnings.catch_warnings():
    warnings.simplefilter("error", DeprecationWarning)
    # If this throws, you have deprecated API usage
    result = legacy_function()

# Systematic replacement
# 1. Find all usages
# 2. Replace one at a time
# 3. Test after each
# 4. Grep again to confirm zero remaining
```

## Quick Reference

| Phase | Key Activities | Success Criteria |
|-------|---------------|------------------|
| **1. Reconnaissance** | Map dependencies, catalog smells, define target | Understand blast radius and end state |
| **2. Characterization Tests** | Test current behavior at boundaries | Intentional change causes test failure |
| **3. Migration Strategy** | Choose pattern (strangler fig, branch by abstraction) | Written plan with incremental steps |
| **4. Execute** | One change at a time, test after each, commit frequently | All tests pass after every change |
| **5. Cleanup** | Remove dead code, update docs, verify end-to-end | No legacy code remaining, all tests green |

## Integration with Other Skills

**This skill requires using:**
- **test-driven-development** - REQUIRED for writing characterization tests (Phase 2) and for any new code written during refactoring. Characterization tests capture current behavior; TDD drives new behavior.

**Complementary skills:**
- **systematic-debugging** - Use when refactoring reveals unexpected behavior. Don't guess at the cause; follow the four-phase debugging process.
- **defense-in-depth** - Add validation at multiple layers when replacing legacy code with new modules. Legacy code often relies on implicit assumptions; make them explicit.

## When Process Reveals "Don't Refactor"

Sometimes Phase 1 reveals:
- The code works fine and nobody needs to change it
- The blast radius is too large for current resources
- A rewrite IS warranted (rare, but possible for truly isolated components with clear specs)
- The code is scheduled for deletion anyway

**These are valid outcomes.** Not every piece of legacy code needs refactoring. The reconnaissance phase exists to prevent wasted effort.

**But:** "Too hard to test" is never a valid reason to skip refactoring. It's a reason to invest more in characterization tests.

## Real-World Impact

From refactoring projects:
- Incremental migration: 95%+ success rate, predictable timeline
- Big-bang rewrite: 30% success rate, 3-10x over budget
- With characterization tests: near-zero regressions
- Without characterization tests: average 2.5 production incidents per migration
- Strangler fig pattern: zero-downtime migration, instant rollback capability

