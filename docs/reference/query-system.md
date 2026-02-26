# Query System Reference

Unified reference for all query operations in kosmos. Five query types serve different navigation intentions.

**Source:** `crates/kosmos/src/host.rs`, `crates/kosmos/src/interpreter/steps.rs`

---

## Overview

| Query | Purpose | Returns | Complexity |
|-------|---------|---------|-----------|
| **find** | Direct lookup by ID | Single entity or null | Trivial (PK lookup) |
| **gather** | Collect all of a type | Array of entities | Simple (SQL) |
| **trace** | Single-hop bond query | Array of bonds or entities | Simple (SQL join) |
| **traverse** | Multi-hop graph walk | Array of reachable entities | Moderate (BFS) |
| **surface** | Semantic search | Array of entities + similarity | Complex (embeddings) |

All queries respect visibility when a `DwellingContext` is provided. See [Visibility Filtering](#visibility-filtering) below.

---

## Visibility Filtering

When a `DwellingContext` is present (i.e., a prosopon is dwelling), query operations automatically apply visibility — returning only entities reachable through the `exists-in` + `member-of` bond path. When no dwelling context is present (internal operations, bootstrap), queries return all entities.

### Per-Operation Visibility

| Operation | Visibility Variant | Behavior |
|-----------|-------------------|----------|
| **find** | `find_entity_visible` | Returns entity only if visible to dwelling prosopon; returns `null` otherwise |
| **gather** | `gather_entities` | SQL-level `EXISTS` subquery filters by `exists-in` + `member-of` when prosopon_id provided |
| **trace** | `trace_bonds_visible` | Filters bonds where **both** endpoints are visible to dwelling prosopon |
| **traverse** | `traverse_visible` | BFS stops at visibility boundaries — invisible entities are not queued |
| **surface** | *(not yet filtered)* | Returns all indexed entities regardless of dwelling |

### How It Works

Visibility = reachability through the bond graph:

1. An entity is **visible** to a prosopon if:
   - The entity has an `exists-in` bond to some oikos, AND
   - The prosopon has a `member-of` bond to that same oikos
2. Entities with **no `exists-in` bonds** are universally visible (transitional rule for constitutional/genesis entities)
3. The check is **absence, not denial** — invisible entities return `null` or are omitted from results, never "access denied"

### Interpreter Integration

Praxis steps (`find`, `trace`, `traverse`) automatically use the visibility-aware variants. The `DwellingContext` is available in `scope.dwelling` during praxis execution. Internal operations (reflexes, composition, bootstrap) use the raw methods — no filtering.

### REST API

REST endpoints apply visibility through session context:
- `GET /entity/:id` — uses `find_entity_visible`
- `GET /bonds` — uses `trace_bonds_visible`
- `PUT /entity/:id` — uses `find_entity_visible` before mutation

**Source:** `crates/kosmos/src/graph.rs` (visibility functions), `crates/kosmos/src/interpreter/steps.rs` (step integration)

---

## find

Direct entity lookup by ID. The most direct path when you know exactly what you seek.

### Syntax

```yaml
- step: find
  id: "prosopon/victor"
  bind_to: entity
```

### Parameters

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `id` | string | yes | Entity ID (literal or `$expression`) |
| `bind_to` | string | no | Variable to store result |

### Returns

Single entity object or `null` if not found.

```json
{
  "id": "prosopon/victor",
  "eidos": "prosopon",
  "data": { "name": "Victor" },
  "version": 1
}
```

---

## gather

Collect all entities of a particular type. Structural and exact — returns complete sets.

### Syntax

```yaml
- step: gather
  eidos: theoria
  sort: domain
  order: DESC
  limit: 50
  bind_to: results
```

### Function-Call Syntax (in source_query)

```yaml
source_query: "gather(eidos: phasis, sort: expressed_at, order: asc, limit: 100)"
```

### Parameters

| Parameter | Type | Required | Default | Description |
|-----------|------|----------|---------|-------------|
| `eidos` | string | no | all | Entity type filter |
| `sort` | string | no | none | Field name to sort by |
| `order` | string | no | `ASC` | `ASC` or `DESC` |
| `limit` | number | no | 100 | Maximum results |
| `bind_to` | string | no | — | Variable to store results |

### Sort Field Safety

Sort field names must be alphanumeric + underscore only (SQL injection protection). Invalid characters are stripped.

### Returns

Array of entity objects.

### Examples

```yaml
# All theoriae sorted by domain
- step: gather
  eidos: theoria
  sort: domain
  order: ASC
  bind_to: theories

# Latest 10 phaseis
- step: gather
  eidos: phasis
  sort: expressed_at
  order: DESC
  limit: 10
  bind_to: recent

# All entities (no type filter)
- step: gather
  bind_to: everything
```

---

## trace

Follow bonds connecting entities. Single-step traversal — finds direct relationships.

### Syntax

```yaml
- step: trace
  from_id: "prosopon/victor"
  to_id: "oikos/kosmos"
  desmos: "member-of"
  resolve: "from"
  bind_to: bonds
```

### Parameters

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `from_id` | string | no | Source entity ID (omit for any source) |
| `to_id` | string | no | Target entity ID (omit for any target) |
| `desmos` | string | no | Bond type (omit for any type) |
| `resolve` | string | no | `"from"` or `"to"` — fetch entities instead of bond records |
| `bind_to` | string | no | Variable to store results |

At least one of `from_id`, `to_id`, or `desmos` should be specified.

### Returns

Without `resolve` — array of bond records:

```json
[{
  "from_id": "prosopon/victor",
  "to_id": "oikos/kosmos",
  "desmos": "member-of",
  "data": null
}]
```

With `resolve: "from"` or `resolve: "to"` — array of entity objects from the resolved side.

### Examples

```yaml
# Find all members of an oikos
- step: trace
  to_id: "oikos/kosmos"
  desmos: "member-of"
  resolve: "from"
  bind_to: members

# Find what a reflex responds with
- step: trace
  from_id: "reflex/ergon/pragma-signaled"
  desmos: "responds-with"
  resolve: "to"
  bind_to: response_praxeis

# Find all bonds from an entity
- step: trace
  from_id: "prosopon/victor"
  bind_to: all_bonds
```

---

## traverse

Walk the graph following specific bond types across multiple steps. Breadth-first search up to a specified depth.

### Syntax

```yaml
- step: traverse
  root_id: "oikos/kosmos"
  desmoi:
    - "member-of"
    - "contains"
  depth: 3
  direction: "inward"
  eidos: "prosopon"
  bind_to: reachable
```

### Parameters

| Parameter | Type | Required | Default | Description |
|-----------|------|----------|---------|-------------|
| `root_id` | string | yes | — | Starting entity ID |
| `desmoi` | array | yes | — | Bond types to follow |
| `depth` | number | no | 10 | Maximum traversal depth |
| `direction` | string | no | `"outward"` | `"outward"`, `"inward"`, or `"both"` |
| `eidos` | string | no | — | Filter results by entity type |
| `bind_to` | string | no | — | Variable to store results |

### Direction

- **outward:** Follow `root → entity` bonds (from_id to to_id)
- **inward:** Follow `entity → root` bonds (to_id to from_id)
- **both:** Follow bonds in both directions

### Returns

Array of all reachable entities (including root), each as a full entity object.

### Examples

```yaml
# Provenance chain
- step: traverse
  root_id: "artifact/my-doc"
  desmoi: ["composed-from", "authorized-by"]
  depth: 10
  direction: "outward"
  bind_to: provenance

# Oikos membership graph
- step: traverse
  root_id: "oikos/kosmos"
  desmoi: ["member-of"]
  depth: 1
  direction: "inward"
  eidos: "prosopon"
  bind_to: members
```

---

## surface

Semantic search — find entities whose meaning is close to a query. Uses embeddings for meaning-based discovery.

### Syntax

```yaml
- step: surface
  query: "bond topology in kosmos"
  limit: 10
  threshold: 0.75
  eidos_filter: theoria
  bind_to: results
```

### Parameters

| Parameter | Type | Required | Default | Description |
|-----------|------|----------|---------|-------------|
| `query` | string | yes | — | Natural language search query |
| `limit` | number | no | 10 | Maximum results |
| `threshold` | number | no | 0.7 | Minimum cosine similarity (0.0–1.0) |
| `eidos_filter` | string | no | — | Filter by entity type |
| `bind_to` | string | no | — | Variable to store results |

### Returns

Array of search results with similarity scores:

```json
[{
  "entity_id": "theoria/bonds-structure",
  "entity": { "id": "...", "eidos": "theoria", "data": { ... } },
  "text": "Indexed text for this entity",
  "similarity": 0.89
}]
```

### Prerequisites

Entities must have embeddings stored (via the `embed` step or `index` operation) to be discoverable by surface.

---

## Query Grammar in source_query

Mode entities use `source_query` strings parsed by the composition layer:

```yaml
# Function-call style (recommended)
source_query: "gather(eidos: phasis, sort: expressed_at, order: desc, limit: 100)"

# Legacy whitespace style (still works)
source_query: "gather eidos=phasis"
```

The parser supports both syntaxes. Parameters within parentheses use colon-delimited `key: value` pairs.

---

## Related

- [Expression Evaluator](expression-evaluator.md) — `$var` interpolation in query parameters
- [Composition Guide](composition.md) — Queried fill pattern
- [Reactive System Reference](reactive-system-reference.md) — Trigger matching uses trace/traverse
- [Mode Development](../how-to/presentation/mode-development.md) — `source_query` in mode entities
