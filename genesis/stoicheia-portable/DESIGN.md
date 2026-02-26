# Stoicheia: The Vocabulary of Praxis Steps

*The atomic operations that compose praxis execution.*

> **Note:** For consolidated architectural concepts (tier model, code generation pipeline), see [../ARCHITECTURE.md](../ARCHITECTURE.md). This document is the complete step vocabulary reference.

---

## Overview

Stoicheia (Greek: "elements") are the atomic operations available within praxis execution. Each step in a praxis references a stoicheion, which determines what operation is performed.

The interpreter's `Step` enum (in `crates/kosmos/src/interpreter/steps.rs`) defines the complete vocabulary. This document serves as a reference until schema-as-eidos is implemented.

---

## Step Vocabulary

### Tier 0: Pure Data Flow

These steps manipulate scope without side effects.

| Step | Purpose | Key Fields |
|------|---------|------------|
| `set` | Bind values to names in scope | `bindings: object` |
| `return` | Return a value from the praxis | `value: any` |

#### set

Bind values to named variables in the execution scope.

```yaml
- step: set
  bindings:
    foo: "bar"
    count: 42
    computed: "$some_expression"
```

#### return

Return a value from the praxis, ending execution.

```yaml
- step: return
  value:
    success: true
    data: "$result"
```

---

### Tier 1: Control Flow

These steps control execution flow without direct entity operations.

| Step | Purpose | Key Fields |
|------|---------|------------|
| `switch` | Conditional branching | `cases: array` |
| `for_each` | Iterate over items | `items: expression`, `as: string`, `do: array` |
| `filter` | Filter array by condition | `items: expression`, `condition: expression`, `bind_to: string` |
| `map` | Transform array elements | `items: expression`, `transform: expression`, `bind_to: string` |
| `reduce` | Reduce array to single value | `items: expression`, `initial: any`, `accumulator: string`, `item: string`, `reducer: expression`, `bind_to: string` |
| `assert` | Verify a condition | `condition: expression`, `message: string` |

#### switch

Execute different branches based on conditions.

```yaml
- step: switch
  cases:
    - when: "$status == 'active'"
      then:
        - step: return
          value: "is active"
    - when: "$status == 'draft'"
      then:
        - step: return
          value: "is draft"
  default:
    - step: return
      value: "unknown status"
```

#### for_each

Iterate over an array, executing steps for each item.

```yaml
- step: for_each
  items: "$artifacts"
  as: artifact
  do:
    - step: manifest
      entity_id: "$artifact.id"
```

**Note:** The step name is `for_each`, not `each`.

#### filter

Filter an array by a condition.

```yaml
- step: filter
  items: "$entities"
  condition: "$item.status == 'active'"
  bind_to: active_entities
```

#### map

Transform each element of an array.

```yaml
- step: map
  items: "$entities"
  transform:
    id: "$item.id"
    name: "$item.data.name"
  bind_to: simplified
```

#### reduce

Reduce an array to a single value.

```yaml
- step: reduce
  items: "$numbers"
  initial: 0
  accumulator: sum
  item: n
  reducer: "$sum + $n"
  bind_to: total
```

#### assert

Verify a condition, failing the praxis if false.

```yaml
- step: assert
  condition: "$entity != null"
  message: "Entity not found"
```

---

### Tier 2: Entity Operations

These steps read or modify the kosmos.

| Step | Purpose | Key Fields |
|------|---------|------------|
| `find` | Find entity by ID | `id: expression`, `bind_to: string` |
| `arise` | Create a new entity | `id: expression`, `eidos: string`, `data: object`, `bind_to: string` |
| `bind` | Create a bond between entities | `from: expression`, `to: expression`, `desmos: string` |
| `update` | Update entity data | `entity_id: expression`, `data: object` |
| `loose` | Remove a bond | `from: expression`, `to: expression`, `desmos: string` |
| `dissolve` | Delete an entity | `entity_id: expression` |
| `gather` | Gather entities by eidos | `eidos: string`, `bind_to: string`, `limit: number` |
| `trace` | Find bonds for an entity | `entity_id: expression`, `desmos: string`, `direction: string`, `bind_to: string` |
| `traverse` | Walk the graph | `root_id: expression`, `desmoi: array`, `depth: number`, `bind_to: string` |
| `compose` | Compose from a typos | `typos_id: expression`, `inputs: object`, `bind_to: string` |
| `call` | Call another praxis | `praxis: string`, `params: object`, `bind_to: string` |

#### find

Find an entity by its ID.

```yaml
- step: find
  id: "release/$release_id"
  bind_to: release
```

#### arise

Create a new entity.

```yaml
- step: arise
  id: "$new_id"
  eidos: release
  data:
    name: "$name"
    version: "$version"
    status: draft
  bind_to: new_release
```

#### bind

Create a bond between two entities.

```yaml
- step: bind
  from: "$release.id"
  to: "$artifact.id"
  desmos: contains-artifact
```

#### update

Update an entity's data fields.

```yaml
- step: update
  entity_id: "$release.id"
  data:
    status: built
    built_at: "$now"
```

#### loose

Remove a bond between entities.

```yaml
- step: loose
  from: "$source.id"
  to: "$target.id"
  desmos: member-of
```

#### dissolve

Delete an entity entirely.

```yaml
- step: dissolve
  entity_id: "$entity.id"
```

#### gather

Gather all entities of a type.

```yaml
- step: gather
  eidos: release
  bind_to: all_releases
  limit: 100
```

#### trace

Find bonds connected to an entity.

```yaml
- step: trace
  entity_id: "$release.id"
  desmos: contains-artifact
  direction: outward
  bind_to: artifact_bonds
```

#### traverse

Walk the graph following bond types.

```yaml
- step: traverse
  root_id: "$entity.id"
  desmoi:
    - depends-on
    - composed-from
  depth: 10
  bind_to: dependencies
```

#### compose

Compose an artifact from a definition.

```yaml
- step: compose
  typos_id: "typos/release-notes"
  inputs:
    release_id: "$release.id"
  bind_to: notes
```

#### call

Call another praxis.

```yaml
- step: call
  praxis: praxis/dokimasia/validate-schema
  params:
    eidos: release
    content: "$data"
  bind_to: validation_result
```

---

### Tier 2: Aisthesis (Perception)

These steps handle semantic search and indexing.

| Step | Purpose | Key Fields |
|------|---------|------------|
| `embed` | Generate embedding for text | `text: expression`, `bind_to: string` |
| `index` | Index entity for semantic search | `entity_id: expression`, `text: expression` |
| `surface` | Semantic search | `query: expression`, `limit: number`, `bind_to: string` |

#### embed

Generate an embedding vector for text.

```yaml
- step: embed
  text: "$description"
  bind_to: embedding
```

#### index

Index an entity for semantic search.

```yaml
- step: index
  entity_id: "$entity.id"
  text: "$entity.data.description"
```

#### surface

Find entities by semantic similarity.

```yaml
- step: surface
  query: "authentication and authorization"
  limit: 10
  bind_to: related_entities
```

---

### Tier 2: Aggregate Operations

| Step | Purpose | Key Fields |
|------|---------|------------|
| `sort` | Sort an array | `items: expression`, `by: expression`, `order: string`, `bind_to: string` |
| `limit` | Take first N items | `items: expression`, `count: number`, `bind_to: string` |

#### sort

Sort an array by a field or expression.

```yaml
- step: sort
  items: "$releases"
  by: "$item.data.created_at"
  order: desc
  bind_to: sorted_releases
```

#### limit

Take the first N items from an array.

```yaml
- step: limit
  items: "$results"
  count: 10
  bind_to: top_ten
```

---

### Tier 2: Manteia (Inference)

| Step | Purpose | Key Fields |
|------|---------|------------|
| `digest` | Summarize or extract from text | `text: expression`, `prompt: string`, `bind_to: string` |
| `infer` | LLM inference | `prompt: expression`, `system: string`, `bind_to: string` |

#### digest

Use LLM to summarize or extract from text.

```yaml
- step: digest
  text: "$document.content"
  prompt: "Extract the key points"
  bind_to: summary
```

#### infer

Run LLM inference.

```yaml
- step: infer
  system: "You are a helpful assistant."
  prompt: "$user_query"
  bind_to: response
```

---

### Tier 3: Energeia (Actuality)

These steps bridge kosmos intent with chora actuality.

| Step | Purpose | Key Fields |
|------|---------|------------|
| `manifest` | Bring entity into actuality | `entity_id: expression`, `bind_to: string` |
| `sense_actuality` | Query actual state | `entity_id: expression`, `bind_to: string` |
| `unmanifest` | Remove from actuality | `entity_id: expression`, `bind_to: string` |

#### manifest

Bring an entity's desired state into actuality (e.g., upload to R2).

```yaml
- step: manifest
  entity_id: "$artifact.id"
  bind_to: manifest_result
```

**Note:** The field is `entity_id`, not `id`.

#### sense_actuality

Query the actual state of an entity in chora.

```yaml
- step: sense_actuality
  entity_id: "$artifact.id"
  bind_to: actual_state
```

**Note:** The step name is `sense_actuality`, not `sense`.

#### unmanifest

Remove an entity's manifestation from actuality.

```yaml
- step: unmanifest
  entity_id: "$artifact.id"
  bind_to: unmanifest_result
```

---

### Tier 3: Communication

| Step | Purpose | Key Fields |
|------|---------|------------|
| `signal` | Emit a signal | `kind: string`, `data: object` |

#### signal

Emit a signal for external consumption.

```yaml
- step: signal
  kind: release-distributed
  data:
    release_id: "$release.id"
    channel: "$channel.id"
```

---

### Tier 3: Ekthesis (Emission)

| Step | Purpose | Key Fields |
|------|---------|------------|
| `emit` | Emit content to filesystem | `path: expression`, `content: expression` or `entity_id: expression` |

#### emit

Emit content or entity to the filesystem.

```yaml
- step: emit
  path: "docs/reference/eide/$eidos_name.md"
  entity_id: "$doc.id"
  format: markdown
```

---

### Tier 3: Hypostasis (Cryptography)

| Step | Purpose | Key Fields |
|------|---------|------------|
| `keyring` | Key derivation and signing | `operation: string`, various per operation |

#### keyring

Perform cryptographic operations.

```yaml
- step: keyring
  operation: sign
  content: "$content_hash"
  oikos_id: "$oikos.id"
  bind_to: signature
```

---

## Common Errors

These errors were discovered during D3 E2E testing (2026-01-23):

| Error | Cause | Fix |
|-------|-------|-----|
| `unknown variant 'each'` | Used `step: each` | Use `step: for_each` |
| `unknown variant 'sense'` | Used `step: sense` | Use `step: sense_actuality` |
| `missing field 'entity_id'` | Used `id:` for manifest | Use `entity_id:` |

---

## WASM Implementations

Some stoicheia have portable WASM implementations:

| File | Stoicheion | Purpose |
|------|------------|---------|
| `wasm/tier2-db-find.wat` | find | Entity lookup |
| `wasm/tier2-db-arise.wat` | arise | Entity creation |
| `wasm/tier2-db-bind.wat` | bind | Bond creation |

These enable V9 execution where stoicheia run in sandboxed WASM with fuel metering.

---

## Schema-as-Eidos ✅ Implemented

Phase V2 is complete. Each stoicheion is now an eidos entity in `stoicheion.yaml`:

```yaml
- eidos: stoicheion
  id: stoicheion/for_each
  data:
    name: for_each
    tier: 1
    description: Iterate over items, executing steps for each
    fields:
      items:
        type: string
        required: true
        description: Array expression to iterate
        aliases: [in]
      item_var:
        type: string
        required: true
        description: Loop variable name
        aliases: [as]
      steps:
        type: array
        required: true
        items:
          type: step
        description: Steps to execute for each item
        aliases: [do]
```

This makes the step vocabulary queryable within the kosmos, enabling:
- ✅ Validation at bootstrap (deserialize against schema)
- ✅ Structured outputs for generation (JSON schema from eidos)
- ✅ Rust type generation (build.rs → step_types.rs)
- ✅ Self-documenting praxeis

## Code Generation Pipeline

The schema-driven pipeline (V5.0.6):

```
stoicheion.yaml (schema)
       │
       ▼
   build.rs (generator)
       │
       ├─► step_types.rs (generated types)
       │         │
       │         ▼
       │   steps.rs (hand-written impl blocks)
       │
       └─► JSON Schema (for manteia governed inference)
```

**Key principle:** Generated types ARE production types. The `Step` enum and all step structs come from generation. Only the `impl` blocks with execution logic are hand-written.

**Fix at generation level:** When something is wrong in generated code, fix the schema or build.rs — never edit generated code directly.

---

## Constitutional Alignment

Stoicheia implements constitutional axioms from KOSMOGONIA:

| Axiom / Principle | How Stoicheia Honors It |
|-------------------|-------------------------|
| **Axiom I: Composition** | Each stoicheion is an entity with provenance. Steps in praxeis reference stoicheia by ID. The chain is traceable. |
| **Schema-driven** | Step types are generated from `stoicheion.yaml` schema. The schema is the single source of truth — types, validation, and JSON schema all derive from it. |
| **Fix at generation level** | T2 (Active Theoria): When generated code is wrong, fix the schema or generator, never the output. This ensures coherence. |
| **Tier model** | Steps are organized by dynamis tier: Tier 0 (pure data), Tier 1 (control flow), Tier 2 (entity ops), Tier 3 (actuality). Higher tiers depend on lower. |

**Caller Pattern:** Stoicheia definitions are **constitutional content** — they use `literal` caller only. Step vocabulary is foundational grammar, not derived content. Changes to stoicheia require careful consideration as they affect all praxeis.

**Full-Circle Genesis:** Stoicheia are emitted via `demiurge/emit-genesis` as part of the arche layer. Re-bootstrap from emitted content must produce identical step vocabulary.

---

*Composed in service of the kosmogonia.*
*Traces to: phasis/genesis-root*
*Created: 2026-01-23*
