---
name: performance-profiling
description: "Use when investigating performance issues, before attempting any optimization - four-phase methodology (baseline measurement, bottleneck profiling, complexity analysis, targeted optimization) that ensures data-driven decisions over gut-feel tuning | パフォーマンスの問題を調査する際、最適化を試みる前に使用 - 4フェーズ手法（ベースライン測定、ボトルネックプロファイリング、計算量分析、的を絞った最適化）により、直感的なチューニングではなくデータに基づく判断を保証"
---

# Performance Profiling

## Overview

Optimizing without measuring is guessing. Guessing wastes time and often makes things worse.

**Core principle:** ALWAYS measure before optimizing. Intuition about performance is wrong more often than right.

**Violating the letter of this process is violating the spirit of performance engineering.**

## The Iron Law

```
MEASURE FIRST, OPTIMIZE SECOND - NO PREMATURE OPTIMIZATION WITHOUT PROFILING DATA
```

If you haven't profiled it, you cannot optimize it. Hunches are not data.

## When to Use

Use for ANY performance concern:
- Slow API responses
- High memory usage
- Slow page loads
- Database query timeouts
- Build/CI pipeline slowdowns
- Memory leaks
- Throughput degradation under load

**Use this ESPECIALLY when:**
- Someone says "this feels slow"
- Under pressure to "just make it faster"
- A "quick optimization" seems obvious
- You want to add caching
- You want to rewrite in a "faster" language
- You're about to refactor for performance

**Don't skip when:**
- The fix seems obvious (obvious fixes are often wrong)
- It's "just" adding an index (measure the impact)
- You're an expert (experts still measure)

## The Four Phases

You MUST complete each phase before proceeding to the next.

### Phase 1: Establish Baseline

**BEFORE changing ANY code:**

1. **Define What "Fast Enough" Means**
   - Set concrete targets: "API responds in < 200ms at p95"
   - No vague goals like "make it faster"
   - Agree on metrics with stakeholders
   - If you can't define the target, you can't know when you're done

2. **Measure Current Performance**
   ```bash
   # HTTP endpoints
   hey -n 1000 -c 50 https://api.example.com/endpoint

   # Application benchmarks
   hyperfine --warmup 3 'command-to-benchmark'

   # Database queries
   EXPLAIN ANALYZE SELECT ...;
   ```

3. **Record the Baseline**
   - Response time: p50, p95, p99
   - Throughput: requests/second
   - Resource usage: CPU%, memory, I/O
   - Error rate under load
   - Write these numbers down. You will compare against them.

4. **Reproduce Under Realistic Conditions**
   - Production-like data volume
   - Concurrent users matching real traffic
   - Warm caches if production has warm caches
   - Cold start if measuring cold start

**No baseline? No optimization. Period.**

### Phase 2: Profile to Find Bottlenecks

**Find where time is actually spent:**

1. **CPU Profiling**
   ```bash
   # Node.js
   node --prof app.js
   node --prof-process isolate-*.log

   # Python
   python -m cProfile -o output.prof script.py

   # Go
   go tool pprof http://localhost:6060/debug/pprof/profile
   ```

2. **Generate Flame Graphs**
   - Flame graphs show exactly where CPU time goes
   - Wide bars = time spent there
   - Look for unexpected wide bars
   - Don't guess - read the graph

3. **Memory Profiling**
   ```bash
   # Node.js
   node --inspect app.js
   # Chrome DevTools → Memory → Heap Snapshot

   # Python
   tracemalloc.start()
   # ... run code ...
   snapshot = tracemalloc.take_snapshot()
   ```

4. **I/O and Network Profiling**
   - Database query logging with timing
   - Network request tracing (OpenTelemetry)
   - File system I/O monitoring
   - External API call latency

5. **Identify the Actual Bottleneck**

   | Bottleneck Type | Symptoms | Tools |
   |----------------|----------|-------|
   | **CPU-bound** | High CPU%, slow computation | Profiler, flame graph |
   | **Memory-bound** | High memory, GC pauses, swapping | Heap profiler, memory tracker |
   | **I/O-bound** | Low CPU%, waiting on disk/network | Tracing, query logs |
   | **Concurrency** | Lock contention, thread starvation | Thread profiler, lock analysis |

   **Key insight:** Most "slow" applications are I/O-bound, not CPU-bound. Don't optimize CPU when you're waiting on the database.

### Phase 3: Algorithmic Complexity Analysis

**Before micro-optimizing, check the algorithm:**

1. **Big-O Review**
   - What is the time complexity of the hot path?
   - Is there an O(n^2) hiding in a loop?
   - Are you doing O(n) lookups where O(1) is possible (array vs. hash map)?
   - Nested database queries (N+1 problem)?

2. **Common Hidden Complexity**

   <Bad>
   ```typescript
   // O(n*m) - linear search inside loop
   for (const user of users) {
     const role = roles.find(r => r.userId === user.id);
   }
   ```
   </Bad>

   <Good>
   ```typescript
   // O(n+m) - build lookup map first
   const roleMap = new Map(roles.map(r => [r.userId, r]));
   for (const user of users) {
     const role = roleMap.get(user.id);
   }
   ```
   </Good>

3. **Database Query Analysis**
   ```sql
   -- Always EXPLAIN before optimizing
   EXPLAIN ANALYZE
   SELECT u.*, COUNT(o.id)
   FROM users u
   LEFT JOIN orders o ON o.user_id = u.id
   GROUP BY u.id;
   ```

   - Check for sequential scans on large tables
   - Verify indexes are being used
   - Look for unnecessary joins
   - Detect N+1 queries in ORM-generated SQL

4. **N+1 Query Detection**

   <Bad>
   ```typescript
   // 1 query for users + N queries for orders
   const users = await db.query('SELECT * FROM users');
   for (const user of users) {
     user.orders = await db.query('SELECT * FROM orders WHERE user_id = ?', [user.id]);
   }
   ```
   </Bad>

   <Good>
   ```typescript
   // 2 queries total regardless of user count
   const users = await db.query('SELECT * FROM users');
   const orders = await db.query('SELECT * FROM orders WHERE user_id = ANY(?)', [userIds]);
   const ordersByUser = groupBy(orders, 'user_id');
   ```
   </Good>

### Phase 4: Targeted Optimization with Benchmarks

**Optimize only what profiling identified:**

1. **Write a Benchmark First**
   ```typescript
   // Before optimizing, capture current performance
   bench('current implementation', () => {
     currentFunction(testData);
   });

   bench('optimized implementation', () => {
     optimizedFunction(testData);
   });
   ```

2. **Make ONE Change at a Time**
   - Single optimization per iteration
   - Measure after each change
   - If no measurable improvement, revert
   - Don't stack optimizations without measuring each

3. **Verify Against Baseline**
   - Does it meet the target defined in Phase 1?
   - Yes? Stop optimizing. You're done.
   - No? Return to Phase 2, find next bottleneck.
   - Getting diminishing returns? Stop. Good enough is good enough.

4. **Frontend-Specific Optimization**
   - Core Web Vitals: LCP, FID/INP, CLS
   - Bundle size analysis (webpack-bundle-analyzer, source-map-explorer)
   - Lazy loading for below-fold content
   - Image optimization (WebP/AVIF, responsive images, lazy load)
   - Code splitting at route boundaries

5. **Memory Leak Resolution**
   - Take heap snapshots at intervals
   - Compare snapshots: what grows?
   - Common causes: event listeners not removed, closures holding references, growing caches without eviction
   - Fix the leak, verify with another snapshot series

## Load Testing

**Before any production deployment of performance-sensitive changes:**

```bash
# k6 example
k6 run --vus 50 --duration 5m load-test.js

# Artillery example
artillery run load-test.yml
```

- Test at expected load AND 2-3x expected load
- Monitor error rates under load
- Check for degradation patterns (gradual vs. cliff)
- Verify resource consumption stays bounded

## Red Flags - STOP and Follow Process

If you catch yourself thinking:
- "This is obviously the slow part"
- "Let me just add some caching"
- "Rewriting in Rust/Go will fix it"
- "Let me optimize this loop"
- "Add an index, that'll fix it"
- "Just increase the timeout"
- "Premature optimization is bad, so I won't measure"
- "The profiler is too hard to set up"
- "I'll measure after I optimize"

**ALL of these mean: STOP. Return to Phase 1.**

## Common Rationalizations

| Excuse | Reality |
|--------|---------|
| "Obviously slow, don't need to measure" | Obvious intuitions are wrong 70% of the time. Measure. |
| "Just add caching" | Caching without understanding causes stale data bugs and hides real issues. |
| "Rewrite in a faster language" | Algorithm matters more than language. O(n^2) in Rust is still O(n^2). |
| "Micro-benchmarks show improvement" | Micro-benchmarks don't reflect real workload. Measure end-to-end. |
| "Profiler is too hard to set up" | 10 minutes to set up profiler vs. hours guessing. Set it up. |
| "It's just one query" | One query called 10,000 times is 10,000 queries. Measure frequency. |
| "Increase the timeout" | Timeouts mask real problems. Find why it's slow. |
| "Premature optimization, skip it" | Measuring is not optimizing. Always measure. Decide after. |
| "Add an index, can't hurt" | Wrong indexes slow writes. EXPLAIN first. |
| "Optimize later when it matters" | Launching without baseline means you can't measure regression. |

## Anti-Patterns

| Anti-Pattern | Consequence | Correct Approach |
|-------------|-------------|-----------------|
| **Optimizing without measuring** | Wrong target, wasted effort, new bugs | Profile first, optimize the actual bottleneck |
| **Micro-optimizing cold paths** | No user-visible improvement | Focus on hot paths identified by profiling |
| **Premature caching** | Stale data, cache invalidation bugs, complexity | Fix the root cause; cache only after measuring |
| **Ignoring algorithmic complexity** | Linear "optimization" on exponential problem | Fix the algorithm before tuning constants |
| **Optimizing in isolation** | Benchmark looks good, production doesn't improve | Test under realistic load and data |
| **Stacking multiple optimizations** | Can't tell which one helped (or hurt) | One change at a time, measure each |

## Quick Reference

| Phase | Key Activities | Success Criteria |
|-------|---------------|------------------|
| **1. Baseline** | Define targets, measure current state, record numbers | Concrete metrics documented |
| **2. Profile** | CPU/memory/I/O profiling, flame graphs, identify bottleneck | Know WHERE time is spent |
| **3. Complexity** | Big-O review, N+1 detection, EXPLAIN queries | Algorithmic issues found or ruled out |
| **4. Optimize** | Benchmark, single change, measure, compare to baseline | Meets target or next bottleneck identified |

## Verification Checklist

Before marking performance work complete:

- [ ] Performance target defined with concrete numbers
- [ ] Baseline measured and recorded before any changes
- [ ] Profiling data collected (not just intuition)
- [ ] Bottleneck identified from profiling data
- [ ] Algorithmic complexity reviewed
- [ ] Database queries analyzed with EXPLAIN
- [ ] Optimization benchmarked against baseline
- [ ] Performance target met (or documented why not)
- [ ] Load tested under realistic conditions
- [ ] No regressions in correctness (all tests pass)
- [ ] Memory stable under sustained load (no leaks)

Can't check all boxes? You're not done.

## Integration with Other Skills

**This skill requires using:**
- **systematic-debugging** - REQUIRED when performance issue has an unclear cause (use Phase 1 root cause investigation)
- **test-driven-development** - REQUIRED for writing benchmarks and ensuring optimizations don't break correctness

**Complementary skills:**
- **documentation-generation** - Document baseline metrics, optimization decisions, and load test results

## Final Rule

```
No profiling data → no optimization
No baseline → no comparison
No target → no "done"
```

Measure. Profile. Optimize. Verify. In that order. Always.

