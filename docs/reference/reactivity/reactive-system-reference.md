# Reference: Reactive System

Technical specification for the homoiconic reactive system in kosmos.

All reflexes use **bonded form only** — trigger patterns, event matching, and response bindings are expressed as entities connected by bonds. There is no embedded/inline form.

---

## Eide

### mutation-event

Abstract base type for graph mutations.

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| — | — | — | Abstract type, no direct instances |

**Location:** `genesis/ergon/eide/mutation-event.yaml`

---

### entity-mutation

Mutation affecting an entity lifecycle.

| Field | Type | Required | Values | Description |
|-------|------|----------|--------|-------------|
| `operation` | enum | yes | `created`, `updated`, `deleted` | Which lifecycle event |

**Seed Instances:**
- `entity-mutation/created`
- `entity-mutation/updated`
- `entity-mutation/deleted`

**Context Variables:**
- `$entity` — the mutated entity
- `$previous` — entity state before mutation (for updates)

**Location:** `genesis/ergon/eide/mutation-event.yaml`

---

### bond-mutation

Mutation affecting a bond lifecycle.

| Field | Type | Required | Values | Description |
|-------|------|----------|--------|-------------|
| `operation` | enum | yes | `created`, `updated`, `deleted` | Which lifecycle event |

**Seed Instances:**
- `bond-mutation/created`
- `bond-mutation/updated`
- `bond-mutation/deleted`

**Context Variables:**
- `$bond` — the bond
- `$from` — source entity (fully resolved)
- `$to` — target entity (fully resolved)

**Location:** `genesis/ergon/eide/mutation-event.yaml`

---

### file-mutation

Mutation affecting a file in the substrate.

| Field | Type | Required | Values | Description |
|-------|------|----------|--------|-------------|
| `operation` | enum | yes | `changed` | Which file event |

**Seed Instances:**
- `file-mutation/changed`

**Context Variables:**
- `$trigger.path` — the file path that changed

**Location:** `genesis/ergon/eide/mutation-event.yaml`

---

### trigger

Pattern that matches graph mutations.

| Field | Type | Required | Default | Description |
|-------|------|----------|---------|-------------|
| `name` | string | yes | — | Short identifier |
| `condition` | string | no | — | Expression evaluated against mutation context |
| `pattern` | string | no | — | Glob pattern for file-mutation triggers |
| `enabled` | boolean | no | `true` | Whether trigger is active |

**Bonds (outgoing):**
- `matches-event` → `entity-mutation`, `bond-mutation`, or `file-mutation` (required, exactly one)
- `filters-eidos` → `eidos` (optional, for entity events)
- `filters-desmos` → `desmos` (optional, for bond events)
- `filters-from-eidos` → `eidos` (optional, source entity type for bond events)
- `filters-to-eidos` → `eidos` (optional, target entity type for bond events; multiple bonds = OR)

**Location:** `genesis/ergon/eide/trigger.yaml`

---

### reflex

Autonomic response to graph mutations.

| Field | Type | Required | Default | Description |
|-------|------|----------|---------|-------------|
| `name` | string | yes | — | Short identifier |
| `description` | string | yes | — | What this reflex does |
| `enabled` | boolean | no | `true` | Whether reflex is active |
| `scope` | enum | no | `global` | `oikos`, `topos`, or `global` |
| `oikos_id` | string | no | — | Oikos ID when scope is `oikos` |
| `topos_id` | string | no | — | Topos ID when scope is `topos` |

**Bonds (outgoing):**
- `triggered-by` → `trigger` (required, exactly one)
- `responds-with` → `praxis` (required, exactly one; bond data carries params)

**Location:** `genesis/ergon/eide/ergon.yaml`

---

## Desmoi

### matches-event

Connects trigger to mutation event type.

| Property | Value |
|----------|-------|
| **From** | `trigger` |
| **To** | `entity-mutation`, `bond-mutation`, `file-mutation` |
| **Cardinality** | many-to-one |
| **Symmetric** | no |

**Example:**
```yaml
- bond:
    from: trigger/pragma-signaled
    desmos: matches-event
    to: bond-mutation/created
```

**Location:** `genesis/ergon/desmoi/trigger.yaml`

---

### filters-eidos

Optional filter to specific entity type.

| Property | Value |
|----------|-------|
| **From** | `trigger` |
| **To** | `eidos` |
| **Cardinality** | many-to-one |
| **Symmetric** | no |

**Example:**
```yaml
- bond:
    from: trigger/pragma-resolved
    desmos: filters-eidos
    to: eidos/pragma
```

**Location:** `genesis/ergon/desmoi/trigger.yaml`

---

### filters-desmos

Optional filter to specific bond type.

| Property | Value |
|----------|-------|
| **From** | `trigger` |
| **To** | `desmos` |
| **Cardinality** | many-to-one |
| **Symmetric** | no |

**Example:**
```yaml
- bond:
    from: trigger/pragma-signaled
    desmos: filters-desmos
    to: desmos/signals-to
```

**Location:** `genesis/ergon/desmoi/trigger.yaml`

---

### filters-from-eidos

Optional filter on bond source entity type.

| Property | Value |
|----------|-------|
| **From** | `trigger` |
| **To** | `eidos` |
| **Cardinality** | many-to-one |
| **Symmetric** | no |

**Example:**
```yaml
- bond:
    from: trigger/artifact-added
    desmos: filters-from-eidos
    to: eidos/topos
```

**Location:** `genesis/ergon/desmoi/trigger.yaml`

---

### filters-to-eidos

Optional filter on bond target entity type(s). Multiple bonds create an OR filter.

| Property | Value |
|----------|-------|
| **From** | `trigger` |
| **To** | `eidos` |
| **Cardinality** | many-to-many |
| **Symmetric** | no |

**Example (single):**
```yaml
- bond:
    from: trigger/praxis-added
    desmos: filters-to-eidos
    to: eidos/praxis
```

**Example (multiple = OR):**
```yaml
- bond:
    from: trigger/artifact-added
    desmos: filters-to-eidos
    to: eidos/eidos

- bond:
    from: trigger/artifact-added
    desmos: filters-to-eidos
    to: eidos/praxis

- bond:
    from: trigger/artifact-added
    desmos: filters-to-eidos
    to: eidos/desmos
```

**Location:** `genesis/ergon/desmoi/trigger.yaml`

---

### triggered-by

Connects reflex to its trigger pattern.

| Property | Value |
|----------|-------|
| **From** | `reflex` |
| **To** | `trigger` |
| **Cardinality** | many-to-one |
| **Symmetric** | no |

Multiple reflexes can share the same trigger.

**Example:**
```yaml
- bond:
    from: reflex/ergon/pragma-signaled
    desmos: triggered-by
    to: trigger/pragma-signaled
```

**Location:** `genesis/ergon/desmoi/reflex.yaml`

---

### responds-with

Connects reflex to response praxis. Bond data carries invocation parameters.

| Property | Value |
|----------|-------|
| **From** | `reflex` |
| **To** | `praxis` |
| **Cardinality** | many-to-one |
| **Symmetric** | no |
| **Bond Data** | None — response parameters live in `reflex.data.response_params` |

**Example:**
```yaml
- eidos: reflex
  id: reflex/ergon/pragma-signaled
  data:
    name: pragma-signaled
    description: Add notification when pragma signals to an oikos.
    enabled: true
    scope: global
    response_params:
      type: pragma_received
      oikos_id: "$to.id"
      pragma_id: "$from.id"
  bonds:
    - desmos: triggered-by
      to: trigger/pragma-signaled
    - desmos: responds-with
      to: praxis/soma/add-notification
```

**Location:** `genesis/ergon/desmoi/reflex.yaml`

---

## Context Variables

Available when evaluating conditions and substituting response params.

### Entity Events

| Variable | Type | Description |
|----------|------|-------------|
| `$entity` | entity | The mutated entity |
| `$previous` | entity | Entity state before mutation (updates only) |

### Bond Events

| Variable | Type | Description |
|----------|------|-------------|
| `$bond` | bond | The bond |
| `$from` | entity | Source entity of the bond (fully resolved) |
| `$to` | entity | Target entity of the bond (fully resolved) |
| `$desmos` | string | Bond type |

### File Events

| Variable | Type | Description |
|----------|------|-------------|
| `$trigger.path` | string | The file path that changed |

### Accessing Fields

```
$entity.id              # Entity ID
$entity.eidos           # Entity type
$entity.data.status     # Field in entity data
$from.data.title        # Field from source entity
```

---

## Matching Algorithm

When a graph mutation occurs:

1. **Identify event type** — `entity-mutation/created`, `bond-mutation/deleted`, `file-mutation/changed`, etc.

2. **Lookup by event type** — Registry is indexed by EventType for O(1) lookup.

3. **Apply structural filters** (cheap, no DB access) — For each candidate reflex:
   - If `filters-eidos` bond exists, check mutated entity type matches
   - If `filters-desmos` bond exists, check bond type matches (bond events only)
   - If `filters-from-eidos` bond exists, check source entity type matches (bond events only)
   - If `filters-to-eidos` bond(s) exist, check target entity type matches any (bond events only)
   - If `pattern` field exists, check file path matches glob (file events only)

4. **Apply scope filter** (may access DB) — Check reflex scope:
   - `global` — always matches
   - `oikos` — entity must be in specified oikos (via member-of bonds)
   - `topos` — entity's eidos must belong to specified topos

5. **Evaluate condition** (expensive, last) — If trigger `condition` field exists:
   - Evaluate expression against context variables
   - Skip if falsy; fail-closed on evaluation error

6. **Invoke responses** — For each matching reflex:
   - Traverse `responds-with` to get praxis
   - Extract params from bond data
   - Substitute context variables in params
   - Call praxis with depth tracking

---

## Guard Rails

| Mechanism | Value | Description |
|-----------|-------|-------------|
| **Depth limiting** | `MAX_REFLEX_DEPTH = 10` | Prevents infinite reflex chains |
| **Error isolation** | per-reflex | One reflex failure does not affect others or the triggering mutation |
| **Enabled flag** | per-reflex and per-trigger | Honor `enabled: true/false` |
| **Bootstrap dormancy** | during bootstrap | Reflexes do not fire during genesis loading |
| **Cache invalidation** | on reflex mutation | Registry reloads when reflex entities change |

---

## Graph-Queryable Discovery

With inward traversal, the reactive topology is discoverable via pure graph queries:

**"What reflexes fire when a theoria is created?"**

```
1. trace_bonds(to: entity-mutation/created, desmos: matches-event)  → candidate triggers
2. trace_bonds(to: eidos/theoria, desmos: filters-eidos)            → triggers filtered to theoria
3. Intersect sets → matching triggers
4. trace_bonds(to: <trigger_id>, desmos: triggered-by)              → reflexes for each trigger
5. trace_bonds(from: <reflex_id>, desmos: responds-with)            → response praxis
```

No registry loading required — pure graph traversal.

---

## Typos

### typos-def-trigger

Compose a trigger entity.

| Property | Value |
|----------|-------|
| **Target Eidos** | `trigger` |
| **Defaults** | `enabled: true` |

**Usage:**
```yaml
- step: compose
  typos_id: typos-def-trigger
  inputs:
    id: "trigger/my-trigger"
    name: "my-trigger"
    condition: '$entity.data.status == "complete"'
  bind_to: trigger
```

**Location:** `genesis/ergon/typos/ergon.yaml`

---

## File Locations

| File | Contents |
|------|----------|
| `genesis/ergon/eide/mutation-event.yaml` | mutation-event, entity-mutation, bond-mutation, file-mutation |
| `genesis/ergon/eide/trigger.yaml` | trigger |
| `genesis/ergon/eide/ergon.yaml` | reflex |
| `genesis/ergon/desmoi/trigger.yaml` | matches-event, filters-eidos, filters-desmos, filters-from-eidos, filters-to-eidos |
| `genesis/ergon/desmoi/reflex.yaml` | triggered-by, responds-with |
| `genesis/ergon/entities/event-types.yaml` | 7 seed mutation event instances |
| `genesis/*/entities/reflexes.yaml` | Reflex declarations per topos |
| `genesis/ergon/typos/ergon.yaml` | typos-def-trigger |

---

## See Also

- [Homoiconic Reactive Architecture](../../explanation/architecture/homoiconic-reactive-architecture.md) — Conceptual overview
- [Create Your First Reflex](../tutorial/reactivity/create-your-first-reflex.md) — Step-by-step tutorial
- [Define Custom Triggers](../how-to/reactivity/define-custom-triggers.md) — Task-oriented guide
