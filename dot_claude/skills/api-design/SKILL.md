---
name: api-design
description: "Use when designing or modifying any API endpoint, before writing handler code - contract-first approach covering resource modeling, URL design, schema conventions, versioning, and authentication that ensures the interface is right before implementation begins | APIエンドポイントの設計や変更時、ハンドラーコードを書く前に使用 - リソースモデリング、URL設計、スキーマ規約、バージョニング、認証を網羅するコントラクトファースト手法により、実装前にインターフェースの正しさを保証"
---

# API Design

## Overview

APIs are contracts. Broken contracts break everyone downstream. Fixing a shipped API is ten times harder than designing it right.

**Core principle:** DESIGN THE API CONTRACT BEFORE IMPLEMENTING THE HANDLER. Implementation details leak into APIs when you code first.

**Violating the letter of this process is violating the spirit of API design.**

## The Iron Law

```
DESIGN THE API CONTRACT BEFORE IMPLEMENTING THE HANDLER
```

If you haven't written the OpenAPI spec (or equivalent contract), you cannot write handler code.

## When to Use

**Always:**
- New REST endpoints
- New GraphQL types/queries/mutations
- Modifying existing API contracts
- Adding authentication/authorization
- Designing inter-service communication
- Building public or partner-facing APIs

**Use this ESPECIALLY when:**
- Under pressure to "just ship the endpoint"
- The database schema already exists and is pulling you toward a data-dump API
- Multiple consumers will use the API
- You're designing something that will be versioned

**Don't skip when:**
- It's an internal API ("internal today, public tomorrow")
- Only one consumer exists right now ("they always multiply")
- It's a simple CRUD endpoint ("simple endpoints set patterns for complex ones")

## Phase 1: Resource Modeling

**BEFORE touching URLs or HTTP methods:**

1. **Identify Resources, Not Actions**
   - Resources are nouns: `users`, `orders`, `invoices`
   - NOT verbs: `getUser`, `createOrder`, `sendInvoice`
   - If you can't name it as a noun, rethink the model

2. **Map Relationships**
   - Parent-child: `/users/{id}/orders`
   - Limit nesting to 2 levels maximum
   - Deeper than 2? Use top-level resource with filter: `/orders?user_id=123`

3. **Define Resource Representations**
   - What fields does each resource have?
   - What's required vs optional?
   - What are the data types and constraints?
   - Write it down BEFORE coding anything

4. **Distinguish Collection vs Instance**
   - Collection: `/orders` (list, create)
   - Instance: `/orders/{id}` (get, update, delete)
   - Every resource needs both unless there's a reason not to

## Phase 2: URL Design and HTTP Semantics

**URLs are the backbone of your API. Get them right.**

### URL Conventions

| Rule | Good | Bad |
|------|------|-----|
| Plural nouns | `/users`, `/orders` | `/user`, `/order` |
| Kebab-case | `/line-items` | `/lineItems`, `/line_items` |
| No verbs | `/orders` + POST | `/createOrder` |
| No trailing slash | `/users` | `/users/` |
| Lowercase only | `/users/{id}/orders` | `/Users/{ID}/Orders` |

### HTTP Methods

Use methods correctly. They have semantics. Respect them.

| Method | Purpose | Idempotent | Safe | Example |
|--------|---------|------------|------|---------|
| GET | Read resource(s) | Yes | Yes | `GET /orders/123` |
| POST | Create resource | No | No | `POST /orders` |
| PUT | Full replace | Yes | No | `PUT /orders/123` |
| PATCH | Partial update | Yes | No | `PATCH /orders/123` |
| DELETE | Remove resource | Yes | No | `DELETE /orders/123` |

**POST is not a catch-all.** If you're using POST for everything, you're building RPC, not REST.

**Actions that don't fit CRUD:**
- Use sub-resources: `POST /orders/123/cancel`
- Or use a "command" resource: `POST /order-cancellations`
- Never: `POST /cancelOrder`

### Status Codes

Use them. Use the RIGHT ones.

| Code | Meaning | When |
|------|---------|------|
| 200 | OK | Successful GET, PUT, PATCH, DELETE |
| 201 | Created | Successful POST that created a resource |
| 204 | No Content | Successful DELETE with no body |
| 400 | Bad Request | Validation error, malformed input |
| 401 | Unauthorized | Missing or invalid authentication |
| 403 | Forbidden | Authenticated but not authorized |
| 404 | Not Found | Resource doesn't exist |
| 409 | Conflict | State conflict (duplicate, version mismatch) |
| 422 | Unprocessable | Syntactically valid but semantically wrong |
| 429 | Too Many Requests | Rate limit exceeded |
| 500 | Internal Server Error | Server bug (never intentional) |

**Don't return 200 with `{ "error": "something failed" }`.** That's lying to HTTP clients.

### Versioning

Version from day one. Not "when we need it."

**Preferred: URL path versioning**
```
/v1/users
/v2/users
```

**Acceptable: Header versioning**
```
Accept: application/vnd.myapi.v2+json
```

**Unacceptable: No versioning**
You WILL break clients. It's a matter of when, not if.

## Phase 3: Request/Response Schema Design

**Consistency is more important than cleverness.**

### Response Envelope

Pick ONE envelope format. Use it EVERYWHERE.

```json
{
  "data": { ... },
  "meta": {
    "request_id": "abc-123",
    "timestamp": "2024-01-15T10:30:00Z"
  }
}
```

For collections:
```json
{
  "data": [ ... ],
  "meta": {
    "request_id": "abc-123",
    "timestamp": "2024-01-15T10:30:00Z"
  },
  "pagination": {
    "total": 142,
    "page": 2,
    "per_page": 20,
    "next_cursor": "eyJpZCI6MTIzfQ=="
  }
}
```

### Error Format

ONE error format. Consistent across ALL endpoints.

```json
{
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Request validation failed",
    "details": [
      {
        "field": "email",
        "message": "Must be a valid email address",
        "code": "INVALID_FORMAT"
      }
    ]
  },
  "meta": {
    "request_id": "abc-123",
    "timestamp": "2024-01-15T10:30:00Z"
  }
}
```

**Never return:**
- Plain strings as error bodies
- Different error shapes from different endpoints
- Stack traces to clients (log them server-side)
- Generic "Something went wrong" without a request ID

### Pagination

**Cursor-based for large/real-time datasets:**
```
GET /orders?cursor=eyJpZCI6MTIzfQ==&limit=20
```

**Offset-based for small, stable datasets:**
```
GET /orders?page=2&per_page=20
```

**Always include:** total count, current page/cursor, next page/cursor, per-page limit.

**Always set a maximum `per_page`.** Unbounded queries kill databases.

### Field Naming

- Use `snake_case` for JSON fields (most common convention)
- Be consistent: don't mix `createdAt` and `updated_at`
- Use ISO 8601 for dates: `2024-01-15T10:30:00Z`
- Use strings for IDs (even if numeric internally)

## Phase 4: Authentication and Authorization

**Security is not optional. Design it in from the start.**

### Authentication Patterns

| Pattern | Use When |
|---------|----------|
| OAuth 2.0 + JWT | User-facing APIs, third-party access |
| API Keys | Server-to-server, simple integrations |
| mTLS | Internal service mesh, high security |

**API Keys:**
- Pass in header: `Authorization: Bearer <key>` or `X-API-Key: <key>`
- NEVER in URL query parameters (they get logged)
- Rotate regularly, support multiple active keys

**JWT:**
- Short-lived access tokens (15 min)
- Longer-lived refresh tokens
- Include minimal claims (user ID, roles)
- Validate signature, expiry, issuer on EVERY request

### Authorization

- Check permissions at the resource level, not just the endpoint
- `GET /users/123/orders` must verify caller can access user 123's orders
- Return 403 for "authenticated but not allowed," 404 if you don't want to reveal existence

### Rate Limiting

Design it in. Don't bolt it on.

```
Headers:
X-RateLimit-Limit: 1000
X-RateLimit-Remaining: 847
X-RateLimit-Reset: 1705312200
```

- Per-client, not global
- Different tiers for different endpoints (reads vs writes)
- Return 429 with `Retry-After` header

## Phase 5: Contract Specification

**Write the OpenAPI spec BEFORE the handler.**

```yaml
openapi: 3.1.0
info:
  title: Orders API
  version: 1.0.0
paths:
  /v1/orders:
    get:
      summary: List orders
      parameters:
        - name: cursor
          in: query
          schema:
            type: string
        - name: limit
          in: query
          schema:
            type: integer
            minimum: 1
            maximum: 100
            default: 20
      responses:
        '200':
          description: Successful response
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/OrderListResponse'
        '401':
          $ref: '#/components/responses/Unauthorized'
```

**The spec is the source of truth.** Generate types, validators, and documentation from it. Don't write them by hand.

### GraphQL Considerations

When using GraphQL instead of REST:

- Design the schema as a graph, not a set of REST endpoints
- Use connections pattern for pagination (edges, nodes, pageInfo)
- Implement DataLoader for N+1 prevention
- Limit query depth and complexity
- Separate queries (reads) from mutations (writes)
- Use input types for mutation arguments

```graphql
type Query {
  order(id: ID!): Order
  orders(first: Int, after: String, filter: OrderFilter): OrderConnection!
}

type OrderConnection {
  edges: [OrderEdge!]!
  pageInfo: PageInfo!
  totalCount: Int!
}
```

## Phase 6: Discoverability and HATEOAS

**Good APIs tell you what you can do next.**

Include relevant links in responses:

```json
{
  "data": {
    "id": "order-123",
    "status": "pending",
    "links": {
      "self": "/v1/orders/order-123",
      "cancel": "/v1/orders/order-123/cancel",
      "items": "/v1/orders/order-123/items",
      "customer": "/v1/customers/cust-456"
    }
  }
}
```

At minimum, include `self` links. Full HATEOAS when clients need to discover transitions.

## Phase 7: Backward Compatibility and Deprecation

**Breaking changes are trust violations.**

### What's Breaking

- Removing a field from response
- Removing an endpoint
- Changing a field's type
- Making an optional field required
- Changing URL structure
- Changing error codes/formats

### What's Not Breaking

- Adding a new field to response
- Adding a new endpoint
- Adding a new optional parameter
- Adding a new error code (if clients handle unknown codes)

### Deprecation Process

1. Mark deprecated in spec and docs
2. Add `Sunset` header with removal date
3. Log usage of deprecated endpoints
4. Contact consumers directly
5. Maintain for minimum 6 months (12 for public APIs)
6. Remove only after usage drops to zero

```
Sunset: Sat, 15 Jun 2025 00:00:00 GMT
Deprecation: true
Link: </v2/users>; rel="successor-version"
```

**Never silently remove endpoints.** Ever.

## Red Flags - STOP and Revisit Design

If you catch yourself:
- Writing handler code without a spec
- Using verbs in URLs
- Returning 200 for errors
- Building different error formats per endpoint
- Adding query parameters to control response shape extensively
- Nesting URLs more than 2 levels deep
- Skipping versioning "for now"
- Exposing database column names as API fields
- Returning different field names for the same concept
- Adding authentication "later"

**ALL of these mean: STOP. Return to Phase 1.**

## Common Rationalizations

| Excuse | Reality |
|--------|---------|
| "Internal API, doesn't need design" | Internal APIs become external. Design it right from the start. |
| "Just one endpoint, don't need versioning" | One endpoint becomes twenty. Version from day one. |
| "We'll add auth later" | Unauthenticated APIs get abused. Security from the start. |
| "Database schema drives the API" | Database is implementation. API is contract. They're different. |
| "POST for everything is simpler" | POST for everything is RPC. You lose HTTP semantics and caching. |
| "Error format doesn't matter yet" | Inconsistent errors multiply. Fix on day one or fix forever. |
| "Breaking change is fine, we control the client" | You control it today. Tomorrow you won't. |
| "Spec is overhead, code is the spec" | Code drifts. Spec is the source of truth. |
| "HATEOAS is over-engineering" | At minimum, include self links. Clients need discoverability. |
| "Pagination can wait" | Unbounded queries will take down your database. Paginate from the start. |

## Quick Reference

| Phase | Key Activities | Success Criteria |
|-------|---------------|------------------|
| **1. Resource Modeling** | Identify nouns, map relationships | Resources are clear, no verbs |
| **2. URL Design** | Define paths, methods, status codes | Consistent, RESTful, versioned |
| **3. Schema Design** | Envelope, errors, pagination, naming | One format everywhere |
| **4. Auth** | Authentication, authorization, rate limits | Security designed in |
| **5. Contract Spec** | OpenAPI/GraphQL schema | Spec exists before code |
| **6. Discoverability** | Links, HATEOAS | Clients can navigate the API |
| **7. Compatibility** | Deprecation plan, breaking change rules | No surprise breakage |

## Verification Checklist

Before implementing any handler:

- [ ] Resources identified as nouns, not verbs
- [ ] URLs use plural, kebab-case, no verbs
- [ ] HTTP methods match semantics (GET reads, POST creates, etc.)
- [ ] Status codes are correct and specific
- [ ] Versioning strategy decided and applied
- [ ] Response envelope is consistent across all endpoints
- [ ] Error format is consistent across all endpoints
- [ ] Pagination designed with limits
- [ ] Authentication and authorization specified
- [ ] Rate limiting designed
- [ ] OpenAPI spec (or GraphQL schema) written
- [ ] No breaking changes to existing contracts
- [ ] Deprecation plan for any removed features

Can't check all boxes? You're not ready to write handler code.

## Integration with Other Skills

**This skill integrates with:**
- **test-driven-development** - Write contract tests from the spec BEFORE implementing handlers. The spec is your test oracle.
- **documentation-generation** - Generate API docs from the OpenAPI spec. The spec IS the documentation source.

**Complementary skills:**
- **systematic-debugging** - When API behavior doesn't match the contract, debug systematically
- **defense-in-depth** - Validate inputs at API boundary AND service layer

## Final Rule

```
API spec → contract tests → handler implementation
Otherwise → not API design
```

No handler code without a contract. No exceptions without your human partner's permission.

