# Composition Reconciliation — The Fourth Loop

*Prompt for Claude Code in the chora + kosmos repository context.*

*After this work, when an entity changes, all entities composed from it are detected as stale and composed again. Compose is idempotent — it handles both genesis and change. Content hashes terminate cascades where compose produces no actual change. The three pillars (schema, graph, cache) operate as one practice.*

*Depends on: nothing (foundational infrastructure).*

---

## Architectural Principle — T3: The Three Pillars Are One Practice

> "Schema-driven, graph-driven, and cache-driven are not separate concerns. They are one methodology viewed from three angles: structure (schema), relationship (graph), identity (cache)."

Currently they are separate:
- **Schema** defines composition structure (typos slots). ✓
- **Graph** tracks provenance (composed-from bonds). ✓
- **Cache** computes content hashes (BLAKE3). ✓

But nothing connects them. When an entity that fed a composition changes, the composed entity doesn't know. The hash sits inert. The composed-from bond is provenance, not a dependency trigger.

T4 names three reconciliation loops:
1. **Actuality** (dynamis): intent ↔ actual state → stoicheion dispatch
2. **Generation** (manteia): expression → LLM → artifact
3. **Schema**: authored content ↔ interpreter expectations

Loop 3 was described too narrowly. It is: **when an input in the graph changes, composed entities downstream are stale and need composing again.** This is composition reconciliation — the fourth loop (or: loop 3 properly understood).

The cycle:
```
Entity A changes
    → ChangeEvent fires
    → Reflex: "A has inbound depends-on bonds"
    → Trace: find all entities that depend-on A
    → For each dependent entity D:
        → Compose D again (from stored inputs)
        → Compose is idempotent: compare new hash to stored hash
        → If different: update D, fire ChangeEvent (cascade continues)
        → If same: no-op (no actual change, cascade terminates)
```

Content hash is the **efficiency** optimization — it prunes the cascade early when compose produces no change.

The **structural** guarantee is that `depends-on` bonds form a directed acyclic graph (DAG). Composition is derivation: an entity's content is a function of its inputs. Circular derivation is incoherent — it has no evaluation order. When `compose_entity()` creates a `depends-on` bond, it verifies that the target does not transitively depend on the composed entity. If it does, the composition is rejected as a circular dependency. The DAG structure makes infinite loops impossible by construction; no artificial depth limit is needed.

Together: the cascade traverses a finite, acyclic path, terminating either at leaf nodes (no dependents) or earlier at nodes where content hashing shows no change.

### Compose is idempotent — γένεσις or μεταβολή by context

Compose is one operation that handles both modes of becoming:

- **First invocation** (entity doesn't exist): γένεσις — `arise_entity()` → `EntityCreated`. The entity comes into being.
- **Subsequent invocations** (entity already exists): hash comparison → μεταβολή if content changed (`update_entity()` → `EntityUpdated`), no-op if same (cascade terminates).

There is no separate "recompose" operation. Composing an entity that already exists IS the change operation. The distinction between genesis and change is ontologically real but determined by context within a single compose — just as `manifest` is one operation that may create or confirm actuality.

This idempotency means the cascade response is simply: compose each dependent again. Compose handles the rest.

---

## Methodology — DDD + TDD

This work follows **Doc → Test → Build → Verify**, non-negotiably.

1. **Doc (prescriptive)**: This prompt IS the prescriptive doc.
2. **Test (assert the doc)**: Write tests that assert dependency tracking and cascade.
3. **Build (satisfy the tests)**: Implement dependency bonds, staleness detection, idempotent compose.
4. **Verify doc**: After implementation, update success criteria.

**Additive infrastructure.** Existing composition behavior is preserved. New bonds and reflexes extend the system; nothing is removed or broken.

---

## Current State

### What Exists and Works

| Component | Location | Status |
|-----------|----------|--------|
| `composed-from` bond | `steps.rs:1720` | Working — created during `compose_entity()` |
| `hash_content()` | `crypto.rs:51-54` | Working — BLAKE3 over canonical JSON |
| `verify_chain()` | `crypto.rs:96-119` | Working — batch hash verification |
| `ChangeEvent` enum | `host.rs:143-195` | Working — 6 event types with enrichment |
| `notify_change()` | `host.rs:446-501` | Working — fires reflexes on entity/bond mutation |
| `ReflexRegistry` | `reflex.rs:197-241` | Working — indexed by EventType, homoiconic |
| `compose_entity()` | `steps.rs:1612-1724` | Working — creates entity + composed-from bond |
| `resolve_slot()` | `steps.rs:1826-1975` | Working — 5 resolution patterns |
| `reconcile()` | `host.rs:1676-1714` | Working — generic schema-driven dispatch |
| `trace` step | `steps.rs` | Working — bond graph traversal |

### What's Missing — The Gaps

1. **No dependency bonds.** `compose_entity()` creates a `composed-from` bond (entity → definition) but does NOT track which entities fed the composition. If a queried slot resolves entities, no bond records that dependency.

2. **No staleness detection.** When an entity changes, nothing checks whether other entities were composed from it. The `composed-from` bond goes entity → definition, not entity → input-entity.

3. **Compose is not idempotent.** `compose_entity()` always calls `arise_entity()` (fires `EntityCreated`). It does not check whether the entity already exists, compare hashes, or use `update_entity()` for existing entities. There is no way to compose an entity again and have it handle the γένεσις/μεταβολή distinction automatically.

4. **No hash-based cascade termination.** Content hashes are computed and stored but never compared to determine whether composing again actually changed anything.

5. **No composition input storage.** To compose an entity again, we need to know what inputs were passed to the original `compose()` call. These are not stored.

---

## Target State

### New Desmos: `depends-on`

A bond from a composed entity to any entity whose data was read during composition.

Already defined at `genesis/demiurge/desmoi/demiurge.yaml` as `desmos/depends-on` (artifact dependency tracking, shared with nous for journey dependencies). No new desmos needed — composition dependencies use the existing bond with `slot_name` metadata.

### New Entity Field: `_composition_inputs`

Stored on composed entities. Records the inputs that were passed to the compose call, enabling the entity to be composed again.

```json
{
  "id": "accumulation/abc123",
  "eidos": "accumulation",
  "data": {
    "content": "Hello world",
    "status": "active",
    "_composition_inputs": {
      "typos_id": "typos-def-accumulation",
      "inputs": { "content": "", "status": "active" }
    }
  }
}
```

The `_composition_inputs` field is internal metadata — not part of the eidos schema. It's written by `compose_entity()` and read when compose is invoked again.

### Dependency Bond Creation in `compose_entity()`

During slot resolution, when a `queried` slot resolves entities from the graph, `compose_entity()` creates `depends-on` bonds from the composed entity to each resolved entity.

```rust
// In compose_entity(), after resolve_slot() for queried patterns:
if slot_resolved_entities {
    for resolved_entity_id in resolved_entity_ids {
        ctx.create_bond(&entity_id, "depends-on", &resolved_entity_id,
            Some(json!({"slot_name": slot_name})))?;
    }
}
```

For `literal` and `computed` slots: no dependency bonds (these depend on inputs, not graph entities).

For `composed` slots (recursive composition): the child entity will have its own `depends-on` bonds. The parent inherits staleness transitively via the cascade.

### DAG Enforcement

Before creating a `depends-on` bond from composed entity C to source entity S, verify that S does not transitively depend on C through existing `depends-on` bonds. If it does, the composition is rejected — circular derivation has no evaluation order. This is enforced at bond creation time with a single `trace_bonds` check.

```rust
// Before creating depends-on bond:
let transitive = ctx.trace_bonds(Some(&resolved_entity_id), None, Some("depends-on"))?;
if transitive.iter().any(|b| b.to_id == entity_id) {
    return Err(KosmosError::Invalid(format!(
        "Circular composition dependency: {} already depends on {}",
        resolved_entity_id, entity_id
    )));
}
```

### Idempotent Compose

`compose_entity()` gains awareness of existing entities:

```rust
// In compose_entity(), after compose_data():
if let Some(existing) = ctx.find_entity(&entity_id)? {
    // Entity exists — μεταβολή path
    let current_hash = hash_excluding_metadata(existing.data);
    let new_hash = hash_excluding_metadata(composed.data);

    if current_hash == new_hash {
        return Ok(existing); // No change — cascade terminates
    }

    // Content changed — update (fires EntityUpdated)
    ctx.update_entity(&entity_id, composed.data)?;
    // Refresh depends-on bonds...
    Ok(updated_entity)
} else {
    // Entity doesn't exist — γένεσις path (current behavior)
    ctx.arise_entity(&target_eidos, &entity_id, composed.data)?;
    // Create depends-on bonds...
    Ok(new_entity)
}
```

Hash comparison excludes `_composition_inputs` to avoid false positives from the metadata itself.

### Staleness Detection Reflex

A reflex that fires when any entity is updated, traces inbound `depends-on` bonds, and invokes composition on each dependent.

```yaml
# genesis/demiurge/reflexes/composition.yaml

entities:
  - eidos: trigger
    id: trigger/demiurge/composition-dependency-changed
    data:
      name: composition-dependency-changed
      description: |
        Fires when any entity is updated. The response praxis
        checks for inbound depends-on bonds and composes dependents.
      enabled: true
    bonds:
      - { desmos: matches-event, to: entity-mutation/updated }

  - eidos: reflex
    id: reflex/demiurge/compose-dependents
    data:
      name: compose-dependents
      description: |
        When any entity is updated, find all entities that depend on it
        (via depends-on bonds) and compose them again. Compose is
        idempotent — hash comparison terminates cascades where no
        actual change occurred.
      enabled: true
      scope: global
      response_params:
        changed_entity_id: "$entity.id"
    bonds:
      - { desmos: triggered-by, to: trigger/demiurge/composition-dependency-changed }
      - { desmos: responds-with, to: praxis/demiurge/compose-dependents }
```

### Compose-Dependents Praxis

A praxis that traces inbound `depends-on` bonds from the changed entity and composes each dependent again. Compose is idempotent, so the praxis is simple — compose handles hash comparison and conditional update internally.

```yaml
# genesis/demiurge/praxeis/composition.yaml

entities:
  - eidos: praxis
    id: praxis/demiurge/compose-dependents
    data:
      name: compose-dependents
      description: |
        Find all entities that depend on the changed entity and compose
        them again. Compose is idempotent: same inputs → same hash → no
        update → cascade terminates.
      topos: demiurge
      params:
        - name: changed_entity_id
          type: string
          required: true
      steps:
        - step: trace
          to_id: "{{ changed_entity_id }}"
          desmos: depends-on
          direction: inbound
          bind_to: dependents

        - step: for_each
          items: "$dependents"
          variable: dependent
          steps:
            - step: compose
              entity_id: "{{ dependent.from_id }}"
              # No typos_id or inputs — compose reads _composition_inputs
              # from the existing entity and composes again.
              # Idempotent: if hash unchanged, no-op.
```

When the compose step receives only an `entity_id` (no `typos_id`), it reads the stored `_composition_inputs` from the existing entity and composes from those. This is the same compose operation — just invoked with stored inputs rather than fresh ones.

### Hash-Based Cascade Termination

The termination condition is inside compose itself. If composing an existing entity produces the same content hash, compose returns without calling `update_entity()`, no `EntityUpdated` fires, no reflex triggers, and the cascade stops.

This makes the system genuinely cache-driven: same inputs → same hash → no work.

---

## Sequenced Work

### Phase 1: Dependency Bonds

**Goal:** `compose_entity()` creates `depends-on` bonds for queried slot dependencies.

**Tests:**
- `test_compose_creates_depends_on_bond` — compose an entity whose slot queries another entity → `depends-on` bond exists from composed entity to queried entity
- `test_compose_literal_slot_no_depends_on` — compose with literal slots only → no `depends-on` bonds created
- `test_compose_multiple_queried_entities` — slot gathers 3 entities → 3 `depends-on` bonds created
- `test_compose_stores_composition_inputs` — composed entity has `_composition_inputs` field with typos_id and inputs
- `test_depends_on_bond_has_slot_name` — `depends-on` bond data includes `slot_name`

**Implementation:**

1. `desmos/depends-on` already exists in `genesis/demiurge/desmoi/demiurge.yaml` — no genesis change needed.

2. In `compose_entity()` (`steps.rs`):
   - Track entity IDs resolved during `resolve_slot()` for queried patterns
   - After entity creation, create `depends-on` bonds for each resolved entity
   - Store `_composition_inputs` field on entity data

3. In `resolve_slot()`:
   - For `queried` pattern: return resolved entity IDs alongside the resolved value
   - Modify return type or use a side-channel (e.g., `&mut Vec<String>` for dependency tracking)

**Phase 1 Complete When:**
- [x] `depends-on` desmos defined in genesis
- [x] `compose_entity()` creates `depends-on` bonds for queried slot inputs
- [x] `_composition_inputs` stored on composed entities
- [x] All existing tests pass (no regressions)
- [x] New dependency bond tests pass

### Phase 2: Idempotent Compose + Staleness Detection

**Goal:** Make compose idempotent (handles existing entities via hash comparison). Add staleness reflex that triggers composition of dependents.

**Tests:**
- `test_compose_existing_entity_updates_if_changed` — compose an entity, change a source, compose again → entity updated via `update_entity` (not `arise_entity`)
- `test_compose_existing_entity_noop_if_unchanged` — compose an entity, compose again without source changes → no update (hash matches)
- `test_compose_with_entity_id_only` — compose step with only `entity_id` (no `typos_id`) reads `_composition_inputs` and composes
- `test_trace_inbound_depends_on` — entity A composed from entity B via queried slot → trace from B finds A
- `test_reflex_fires_on_dependency_change` — update entity B → reflex fires → `compose-dependents` praxis invoked with B's ID
- `test_no_reflex_during_bootstrap` — dependency changes during bootstrap don't trigger composition (bootstrapping flag)

**Implementation:**

1. Make `compose_entity()` idempotent:
   - After `compose_data()`, check if entity exists via `find_entity()`
   - If exists: hash comparison → `update_entity()` if different, return existing if same
   - If not: `arise_entity()` as before (current behavior)
   - Hash comparison excludes `_composition_inputs` field

2. Add `entity_id`-only mode to compose step:
   - When compose step has `entity_id` but no `typos_id`, read `_composition_inputs` from entity
   - Use stored `typos_id` and `inputs` to compose again

3. Add trigger and reflex entities to `genesis/demiurge/reflexes/composition.yaml`

4. Add `praxis/demiurge/compose-dependents` to `genesis/demiurge/praxeis/composition.yaml`

5. Ensure reflex registry loads the new reflex at bootstrap exit

**Phase 2 Complete When:**
- [x] Compose is idempotent (handles existing entities)
- [x] Hash comparison prevents unnecessary updates
- [x] Compose with `entity_id` only reads stored inputs
- [x] Staleness reflex defined in genesis
- [x] Reflex fires on entity update
- [x] Compose-dependents praxis invoked for each dependent

### Phase 3: Cascade Verification

**Goal:** Prove the full cycle: change input → cascade composes dependents → hash terminates.

**Tests:**
- `test_full_cascade_three_layers` — Entity C → composed entity B (depends-on C) → composed entity A (depends-on B). Change C → B composed again (hash changes) → A composed again. Verify all three entities have correct final state.
- `test_cascade_terminates_on_hash_match` — A depends-on B depends-on C. Change C → B composed again (hash changes) → A composed again (hash matches, no upstream change) → cascade stops at A
- `test_dag_enforcement_rejects_cycle` — A composed from B, attempt to compose B from A → rejected as circular dependency. The depends-on graph is structurally a DAG; no artificial depth limit needed.
- `test_cascade_with_multiple_dependents` — Entity X → entities A, B, C all depend-on X. Change X → all three composed independently.
- `test_compose_no_inputs_graceful` — entity without `_composition_inputs` → compose is no-op (guard catches)

**Implementation:**
1. Run the full cycle with multi-layer dependency graphs
2. Verify cascade behavior under various graph topologies
3. Verify DAG enforcement rejects circular compositions

**Phase 3 Complete When:**
- [x] Multi-layer cascade works
- [x] Cascade terminates on hash match
- [x] Circular dependency composition is rejected (DAG enforced)
- [x] Multiple dependents compose independently
- [x] All existing tests pass (518)

---

## Files to Read

### Composition pipeline
- `crates/kosmos/src/interpreter/steps.rs` — `compose_entity()`, `resolve_slot()`, composed-from bond creation
- `crates/kosmos/src/crypto.rs` — `hash_content()`, `verify_chain()`, canonical JSON

### Reactive system
- `crates/kosmos/src/reflex.rs` — `ReflexRegistry`, `TriggerPattern`, `ResponseAction`, event matching
- `crates/kosmos/src/host.rs` — `notify_change()`, `ChangeEvent`, `reconcile()`, `arise_entity()`, `create_bond()`

### Genesis patterns
- `genesis/demiurge/desmoi/demiurge.yaml` — existing demiurge desmoi (depends-on, composed-from, etc.)
- `genesis/chora-dev/reflexes/reflexes.yaml` — reflex pattern examples (autonomic triple)
- `genesis/dynamis/reconcilers/dynamis.yaml` — reconciler pattern examples

### Expression evaluator
- `crates/kosmos/src/interpreter/expr.rs` — `eval_string()`, `KNOWN_FUNCTIONS`

---

## Files to Touch

| File | Change |
|------|--------|
| `genesis/demiurge/desmoi/demiurge.yaml` | **EXISTS** — `desmos/depends-on` already defined here |
| `genesis/demiurge/reflexes/composition.yaml` | **NEW** — staleness trigger + compose-dependents reflex |
| `genesis/demiurge/praxeis/composition.yaml` | **NEW** — `compose-dependents` praxis |
| `crates/kosmos/src/interpreter/steps.rs` | **MODIFY** — `compose_entity()` idempotent, creates `depends-on` bonds, stores `_composition_inputs` |
| `crates/kosmos/tests/composition_reconciliation.rs` | **NEW** — test suite for dependency tracking, cascade, hash termination |

---

## Success Criteria

- [x] `depends-on` bonds created during composition for queried slot inputs
- [x] `_composition_inputs` stored on composed entities
- [x] Compose is idempotent — existing entity → hash compare → update or no-op
- [x] Staleness reflex fires on entity update, traces dependents
- [x] Compose-dependents praxis composes each dependent
- [x] Hash comparison prevents unnecessary updates (cascade termination)
- [x] Multi-layer cascade propagates correctly
- [x] Circular dependencies rejected at composition time (DAG enforced)
- [x] All existing tests pass (518)
- [x] New test suite passes (16 tests)

---

## What This Enables

- **T3 as one practice**: Schema defines structure, graph tracks dependencies, cache (hash) prevents redundant work. The three pillars connected.
- **Compose bar**: When utterance appends to accumulation, or clarification modifies content, downstream compositions (if any) automatically compose again.
- **Genesis evolution**: When a typos definition changes (via bootstrap refresh), entities composed from it can be detected as stale.
- **Generation cascades**: When a generated entity's inputs change, the generation can be re-triggered (generation reconciliation becomes a special case of composition reconciliation).

---

## What Does NOT Change

- **Existing reconciliation** (intent-vs-actuality) — untouched. This is a parallel loop, not a replacement.
- **Bootstrap** — still wipes and rebuilds. Composition reconciliation operates at runtime, not during bootstrap.
- **compose_graph()** — not affected. Only `compose_entity()` (which creates persisted entities) gets dependency tracking.
- **Existing praxeis** — `begin-accumulation`, `commit-phasis`, etc. continue to work. They update entities directly; composition reconciliation adds an additional reactive layer.
- **Frontend** — purely backend/Rust changes. No frontend impact.

---

*Traces to: T3 (three pillars as one practice), T4 (three reconciliation loops → now four), T10 (latent bugs surface at integration boundaries), Compose Bar Design Dialogue ("I have yet to see that actually reflected in any of our designs")*
