---
name: data-pipeline-engineering
description: "Use when building or modifying any data pipeline, before writing transformation logic - idempotent-first approach covering schema design, quality checks, incremental loads, CDC, and observability that ensures every step is repeatable and verifiable | データパイプラインの構築や変更時、変換ロジックを書く前に使用 - スキーマ設計、品質チェック、増分ロード、CDC、オブザーバビリティを網羅する冪等性ファースト手法により、全ステップの再実行可能性と検証可能性を保証"
---

# Data Pipeline Engineering

## Overview

Data pipelines fail silently. Bad data propagates downstream before anyone notices. Reprocessing a non-idempotent pipeline corrupts your warehouse.

**Core principle:** EVERY PIPELINE STEP IS IDEMPOTENT AND PRODUCES VERIFIABLE OUTPUT. If you can't safely re-run any step at any time, your pipeline is a ticking bomb.

**Violating the letter of this process is violating the spirit of data engineering.**

## The Iron Law

```
EVERY PIPELINE STEP IS IDEMPOTENT AND PRODUCES VERIFIABLE OUTPUT
```

If re-running a step produces different results or duplicates data, you cannot ship it.

## When to Use

**Always:**
- ETL/ELT pipeline development
- Data model changes
- New data source integrations
- Pipeline failure recovery design
- Data quality rule implementation
- Schema migrations

**Use this ESPECIALLY when:**
- Under pressure to "just load the data"
- Source data is messy or undocumented
- Multiple teams consume the output
- Pipeline runs on a schedule (batch)
- Data volume is growing

**Don't skip when:**
- It's a "one-time load" (one-time loads always repeat)
- Data is "clean" from the source (it never is)
- Only one consumer right now (they always multiply)
- It's just a simple SELECT INTO (simple queries become complex pipelines)

## Phase 1: Schema Design and Data Modeling

**BEFORE writing any transformation logic:**

1. **Understand the Source**
   - Document every source table, field, type, and constraint
   - Identify primary keys, foreign keys, and business keys
   - Profile the data: nulls, cardinality, distributions, outliers
   - Document known data quality issues
   - Never trust source documentation alone - profile the actual data

2. **Choose Your Modeling Approach**

   | Pattern | Use When | Characteristics |
   |---------|----------|-----------------|
   | Star schema | BI/analytics, known query patterns | Denormalized facts + dimensions, fast reads |
   | Snowflake schema | Normalized dimensions needed | Normalized dimensions, less storage |
   | Data vault | Multiple sources, audit requirements | Hubs + links + satellites, full history |
   | Wide tables | Simple analytics, small data | Single denormalized table, easy queries |

3. **Define Layers**
   ```
   raw/staging  → Exact copy of source (no transforms)
   cleaned      → Type casting, dedup, null handling
   transformed  → Business logic, joins, aggregations
   presentation → Consumer-ready marts and views
   ```

   Each layer has a purpose. Don't skip layers. Don't combine them.

4. **Design for Change**
   - Use surrogate keys (don't rely on source PKs)
   - Track SCD Type 2 for dimensions that change
   - Store raw data permanently - you will need to reprocess
   - Separate business logic from plumbing

## Phase 2: Idempotent Pipeline Design

**This is non-negotiable. Every step must be safely re-runnable.**

### Idempotency Patterns

**DELETE-INSERT (simplest, preferred for small-medium data):**
```sql
-- Idempotent: safe to re-run for any date
DELETE FROM orders_fact WHERE order_date = '{{ ds }}';
INSERT INTO orders_fact
SELECT ... FROM staging_orders WHERE order_date = '{{ ds }}';
```

**MERGE/UPSERT (for large datasets where delete-insert is too slow):**
```sql
MERGE INTO dim_customers AS target
USING staging_customers AS source
ON target.business_key = source.customer_id
WHEN MATCHED THEN UPDATE SET ...
WHEN NOT MATCHED THEN INSERT ...;
```

**TABLE SWAP (for full rebuilds):**
```sql
CREATE TABLE orders_fact_new AS SELECT ...;
-- Atomic swap
ALTER TABLE orders_fact RENAME TO orders_fact_old;
ALTER TABLE orders_fact_new RENAME TO orders_fact;
DROP TABLE orders_fact_old;
```

### What Breaks Idempotency

| Anti-Pattern | Why It Breaks | Fix |
|-------------|---------------|-----|
| INSERT without dedup check | Duplicates on re-run | DELETE-INSERT or MERGE |
| Auto-increment surrogate keys | Different IDs on re-run | Hash-based or natural keys for matching |
| `NOW()` in transforms | Different results on re-run | Pass execution timestamp as parameter |
| Appending to files | Duplicates on re-run | Write to partitioned paths, overwrite partition |
| Sequence-dependent operations | Order matters across runs | Make each step independent |

**Test idempotency explicitly:** Run the pipeline twice for the same input. Output must be identical.

## Phase 3: Incremental vs Full Load

**Default to incremental. Fall back to full only when necessary.**

### Incremental Load

```
Load only what changed since last run.
```

**Requirements:**
- Reliable change indicator: `updated_at`, sequence number, CDC log
- Watermark tracking: store and advance the high-water mark
- Late-arriving data handling

```python
# Watermark-based incremental
last_watermark = get_watermark('orders_pipeline')
new_data = extract(f"SELECT * FROM orders WHERE updated_at > '{last_watermark}'")
load(new_data)
set_watermark('orders_pipeline', new_data.max('updated_at'))
```

**WARNING:** If the source doesn't have a reliable `updated_at`, you CANNOT do incremental safely. Use CDC or full load.

### Change Data Capture (CDC)

**Use CDC when:**
- Source has no reliable change indicator
- You need deletes (incremental misses them)
- You need real-time or near-real-time
- Audit trail is required

**CDC approaches:**

| Method | Latency | Source Impact | Complexity |
|--------|---------|--------------|------------|
| Log-based (Debezium, DMS) | Seconds | None | Medium |
| Trigger-based | Seconds | High | High |
| Timestamp-based polling | Minutes | Low | Low |
| Diff/compare | Hours | High | Low |

**Prefer log-based CDC.** It captures all changes (including deletes) without impacting source performance.

### Full Load

**Use full load ONLY when:**
- Source is small enough (define "small" for your context)
- No reliable change indicator AND no CDC option
- Initial backfill
- Data reconciliation

Even with full load, make it idempotent: table swap or delete-insert.

## Phase 4: Data Quality Checks

**Every pipeline step produces verifiable output. No exceptions.**

### Quality Check Layers

```
Source checks  → Before extraction: Is source available? Schema matches?
Load checks    → After extraction: Row counts, null rates, type conformance
Business rules → After transform: Domain constraints, referential integrity
Output checks  → Before serving: Completeness, freshness, accuracy
```

### Essential Checks

**ALWAYS implement these. Non-negotiable:**

| Check | Example | Action on Failure |
|-------|---------|-------------------|
| Not null | `id IS NOT NULL` | Block pipeline |
| Unique | `COUNT(id) = COUNT(DISTINCT id)` | Block pipeline |
| Referential integrity | All `order.customer_id` exist in `dim_customers` | Block or quarantine |
| Row count threshold | Today's count within 20% of yesterday | Alert, review |
| Freshness | Source data within expected window | Alert, review |
| Accepted values | `status IN ('active', 'inactive', 'pending')` | Quarantine bad rows |
| Value range | `price > 0 AND price < 1000000` | Quarantine bad rows |

### Implementation with dbt

```yaml
# schema.yml
models:
  - name: orders_fact
    columns:
      - name: order_id
        tests:
          - not_null
          - unique
      - name: customer_id
        tests:
          - not_null
          - relationships:
              to: ref('dim_customers')
              field: customer_id
      - name: order_total
        tests:
          - not_null
          - dbt_expectations.expect_column_values_to_be_between:
              min_value: 0
              max_value: 1000000
```

### Implementation with Great Expectations

```python
validator.expect_column_values_to_not_be_null("order_id")
validator.expect_column_values_to_be_unique("order_id")
validator.expect_column_values_to_be_between("order_total", min_value=0, max_value=1000000)
validator.expect_column_pair_values_a_to_be_greater_than_b("ship_date", "order_date", or_equal=True)
```

### Failure Strategy

**Block:** Pipeline stops. Data does not propagate. Fix required.
- Use for: Primary key violations, critical nulls, schema changes

**Quarantine:** Bad rows redirected to error table. Good rows continue.
- Use for: Value range violations, format issues, late-arriving dimensions

**Alert:** Pipeline continues. Human reviews.
- Use for: Row count anomalies, statistical outliers, freshness warnings

**NEVER silently drop bad data.** Every rejected row must be accounted for.

## Phase 5: Error Handling and Retry

**Pipelines fail. Design for it.**

### Retry Strategy

```python
# Exponential backoff with jitter
@retry(
    stop=stop_after_attempt(3),
    wait=wait_exponential(multiplier=1, min=4, max=60) + wait_random(0, 2),
    retry=retry_if_exception_type((ConnectionError, TimeoutError)),
    before_sleep=log_retry_attempt
)
def extract_from_source(query):
    ...
```

**Retryable failures:**
- Network timeouts
- Database connection drops
- Rate limits (respect `Retry-After`)
- Transient cloud service errors

**Non-retryable failures (fix the code):**
- Schema mismatch
- Authentication failure
- Data type errors
- Business logic violations

### Partial Failure Handling

- Process data in partitions (date, region, category)
- Failed partition doesn't block successful ones
- Track which partitions succeeded
- Re-run only failed partitions

```python
for partition_date in date_range:
    try:
        process_partition(partition_date)
        mark_success(partition_date)
    except RetryableError:
        mark_failed(partition_date)
        continue  # Next partition
    except FatalError:
        mark_failed(partition_date)
        alert_and_stop()
        break
```

### Dead Letter Queues

For streaming pipelines, route unparseable/invalid messages to a dead letter queue:
- Preserve the original message
- Add error metadata (reason, timestamp, pipeline version)
- Monitor DLQ size as a health metric
- Process DLQ manually or with fix-and-replay

## Phase 6: Data Lineage and Observability

**If you can't trace where data came from, you can't trust it.**

### Lineage Requirements

Every output table must answer:
- What source tables fed into this?
- What transformations were applied?
- When was it last updated?
- What pipeline version produced it?
- Can I trace a specific output row back to its source?

### Implementation

**Column-level lineage with dbt:**
```sql
-- models/orders_fact.sql
-- depends_on: {{ ref('stg_orders') }}, {{ ref('dim_customers') }}

SELECT
    o.order_id,           -- from stg_orders.order_id
    o.order_date,         -- from stg_orders.order_date
    c.customer_name,      -- from dim_customers.customer_name
    o.quantity * o.price AS order_total  -- derived
FROM {{ ref('stg_orders') }} o
JOIN {{ ref('dim_customers') }} c ON o.customer_id = c.customer_id
```

**Run metadata:**
```sql
-- Add to every output table
_pipeline_name      VARCHAR,  -- 'orders_daily'
_pipeline_run_id    VARCHAR,  -- 'run-2024-01-15-001'
_pipeline_version   VARCHAR,  -- 'v2.3.1'
_loaded_at          TIMESTAMP -- pipeline execution time (parameter, not NOW())
```

### Observability Metrics

**Monitor these. Alert on anomalies.**

| Metric | What It Tells You |
|--------|------------------|
| Row count delta | Sudden spikes or drops = source issue or bug |
| Pipeline duration | Increasing duration = scaling problem |
| Error rate | Rising errors = source degradation |
| Data freshness | Stale data = pipeline stuck or source delayed |
| Quality check pass rate | Declining = source quality degrading |
| DLQ size (streaming) | Growing = parsing/schema issues |

### DAG Design (Airflow / Orchestrators)

```python
# Explicit dependencies, not implicit
extract_orders >> validate_source >> transform_orders >> quality_checks >> load_mart

# NOT this
extract_orders >> transform_orders >> load_mart  # Missing validation!
```

**Rules for DAGs:**
- One task per logical step (don't combine extract + transform)
- Explicit dependencies (never rely on schedule timing)
- Catchup enabled with idempotent tasks
- Alerting on failure AND SLA breach
- Retries configured per task based on failure type

## Red Flags - STOP and Revisit Design

If you catch yourself:
- Writing INSERT without a dedup strategy
- Using `NOW()` inside a transformation
- Skipping data quality checks "for now"
- Loading data without profiling the source first
- Building a pipeline with no lineage tracking
- Combining extraction and transformation in one step
- Designing a pipeline that can't be re-run safely
- Hardcoding connection strings or credentials
- Loading into production without a staging layer
- Ignoring late-arriving data

**ALL of these mean: STOP. Return to Phase 1.**

## Common Rationalizations

| Excuse | Reality |
|--------|---------|
| "One-time load, doesn't need idempotency" | One-time loads always run again. Build it right. |
| "Source data is clean" | Profile it. It isn't. Data quality issues always exist. |
| "Quality checks slow the pipeline down" | Silent bad data costs more than pipeline latency. |
| "We'll add lineage tracking later" | Later never comes. Lineage is foundational, not optional. |
| "Full load is simpler" | Full load doesn't scale. Design incremental from the start. |
| "Small dataset, don't need partitioning" | Small datasets grow. Partition early or redesign later. |
| "Just an internal dashboard" | Internal consumers deserve correct data too. |
| "CDC is overkill" | Missing deletes and updates is data corruption. Evaluate CDC honestly. |
| "Schema won't change" | Schemas always change. Design for evolution. |
| "We can fix data manually" | Manual fixes don't scale and aren't auditable. Automate. |

## Quick Reference

| Phase | Key Activities | Success Criteria |
|-------|---------------|------------------|
| **1. Schema Design** | Profile source, choose model, define layers | Documented schema, clear layers |
| **2. Idempotency** | DELETE-INSERT/MERGE, parameterized timestamps | Re-run produces identical output |
| **3. Load Strategy** | Incremental, CDC, or full with justification | Efficient, handles late arrivals |
| **4. Quality Checks** | Null, unique, referential, range, freshness | Every step has verifiable checks |
| **5. Error Handling** | Retry, partition, dead letter, alerting | Failures are handled, not silent |
| **6. Lineage** | Source tracking, run metadata, observability | Every output traceable to source |

## Verification Checklist

Before deploying any pipeline:

- [ ] Source data profiled and documented
- [ ] Schema designed with appropriate modeling pattern
- [ ] Every step is idempotent (tested by running twice)
- [ ] Incremental strategy defined with watermark tracking
- [ ] Data quality checks at every layer boundary
- [ ] Failure strategy defined: block, quarantine, or alert
- [ ] Retry logic with backoff for transient failures
- [ ] Lineage metadata on every output table
- [ ] Pipeline run metadata tracked
- [ ] Observability metrics and alerting configured
- [ ] Late-arriving data handled
- [ ] Raw/staging data preserved for reprocessing
- [ ] No hardcoded credentials or environment-specific values

Can't check all boxes? You're not ready to deploy.

## Integration with Other Skills

**This skill integrates with:**
- **test-driven-development** - Write tests for transformations BEFORE implementing them. Test each transformation function in isolation. Use dbt tests as part of the TDD cycle.
- **documentation-generation** - Generate data dictionaries and pipeline documentation from schema definitions and dbt docs.

**Complementary skills:**
- **systematic-debugging** - When pipeline output is wrong, debug systematically: trace data from source through each layer
- **defense-in-depth** - Validate data at every layer boundary, not just the final output

## Final Rule

```
Profile source → design schema → implement idempotent steps → verify quality at every boundary
Otherwise → not data engineering
```

No pipeline ships without idempotency and quality checks. No exceptions without your human partner's permission.

