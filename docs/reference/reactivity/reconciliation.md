# Reconciliation

*How reconciler entities drive the sense-compare-act loop to align intent with actuality.*

**Status: CURRENT** — The generic reconciler engine is implemented. `host.reconcile(reconciler_id, entity_id)` reads reconciler entities from the graph and dispatches transitions. Schema-driven dispatch via `resolve_mode()` routes actions to the correct mode handler.

---

## Overview

Reconciliation is how kosmos aligns intent with actuality. Rather than imperative "do X" commands, the system declares desired state and continuously reconciles toward it.

The reconciler is entity-driven: reconciler entities in genesis declare what to watch and how to respond to drift. The loop discovers these entities and executes the cycle.

---

## The Loop

```
Periodic (every N seconds):
  1. GATHER  — find all reconciler entities
  2. For each reconciler:
     a. SENSE   — query actuality for current state
     b. COMPARE — diff intent vs actuality
     c. ACT     — execute transition action if drift detected
```

---

## Reconciler Entity Schema

```yaml
- eidos: reconciler
  id: reconciler/deployment
  data:
    name: Deployment Reconciler
    target_eidos: deployment
    intent_field: desired_state
    actuality_field: actual_state
    sense_interval_seconds: 30
    transitions:
      - intent: running
        actual: absent
        action: manifest
      - intent: running
        actual: stopped
        action: manifest
      - intent: stopped
        actual: running
        action: unmanifest
      - intent: removed
        actual: running
        action: unmanifest
      - intent: removed
        actual: stopped
        action: none
      - intent: running
        actual: running
        action: none
```

### Fields

| Field | Type | Description |
|-------|------|-------------|
| `target_eidos` | string | Which eidos this reconciler watches |
| `intent_field` | string | Path into entity data for desired state |
| `actuality_field` | string | Path into entity data for sensed state |
| `sense_interval_seconds` | integer | How often to run the sense-compare-act cycle |
| `transitions` | array | Rules mapping (intent, actual) pairs to actions |

### Transition Actions

| Action | Meaning |
|--------|---------|
| `manifest` | Bring into actuality (create, start, deploy) |
| `unmanifest` | Remove from actuality (stop, destroy, undeploy). Sends SIGTERM. |
| `sense` | Query actuality for current state, write back to entity |
| `none` | Intent matches actuality, no action needed |

---

## Reconciliation Engine

The engine is implemented in `crates/kosmos/src/host.rs` with the entry point `host.reconcile(reconciler_id, entity_id)`:

```
host.reconcile(reconciler_id, entity_id):
  1. Load reconciler entity (defines intent_field, actuality_field, transitions)
  2. Load target entity
  3. Extract intent = entity.data[intent_field]
  4. Extract actual = entity.data[actuality_field]
  5. Iterate transitions: find match where intent matches AND actual matches
  6. Dispatch action: manifest, unmanifest, sense, or none
  7. Update entity last_reconciled_at
  8. Return reconciliation result
```

### Transition Matching

Matching supports:
- **Exact value match** for intent field
- **Array membership** for actual field (if actual is an array, any item matching triggers the rule)
- **Type coercion** via `values_match()` — string `"true"`/`"false"` ↔ bool

### Mode Integration

Actions dispatch to mode operations via `resolve_mode()`:

| Reconciler Action | Mode Operation |
|-------------------|----------------|
| `manifest` | `host.manifest(entity_id)` |
| `unmanifest` | `host.unmanifest(entity_id, SIGTERM)` |
| `sense` | `host.sense_actuality(entity_id)` |
| `none` | No-op |

The reconciler discovers which mode to use by reading `mode` and `provider` from entity data, then dispatching through the generated `stoicheion_for_mode()` table in `mode_dispatch.rs`. Only exact `(mode, provider)` pairs are supported — no wildcards. Mode entities are unified — screen, compute, storage, network all share `eidos: mode` with different substrates.

### Reflex-Driven Invocation

Reconciliation is typically triggered by reflexes rather than periodic polling:

```
Entity mutation → trigger pattern match → reflex → dynamis/reconcile praxis
```

Reflexes are dormant during bootstrap and become active after `exit_bootstrap_mode()`.

### Sense Writes Back

After sensing, the engine writes sensed state back to the entity's `actuality_field`. This makes actuality visible in the graph — render-specs and modes can bind to actuality state.

---

## Existing Reconciler Entities

Two reconcilers already exist in genesis at `genesis/dynamis/reconcilers/dynamis.yaml`:

### reconciler/deployment

Reconciles deployment entities against process actuality:
- Intent: `desired_state` (running, stopped, removed)
- Actuality: `actual_state` (running, stopped, absent)
- Actions: manifest/unmanifest based on delta

### reconciler/release-artifact

Reconciles release artifacts against object storage:
- Intent: `uploaded` (boolean)
- Actuality: `_sensed.exists` (boolean)
- Actions: manifest (upload) / unmanifest (delete)

---

## Adding a Reconciler

1. Define the reconciler entity in genesis:

```yaml
- eidos: reconciler
  id: reconciler/my-reconciler
  data:
    target_eidos: my-entity-type
    intent_field: desired_state
    actuality_field: _sensed.state
    sense_interval_seconds: 60
    transitions:
      - intent: active
        actual: absent
        action: manifest
      - intent: active
        actual: active
        action: none
      - intent: inactive
        actual: active
        action: unmanifest
```

2. Ensure target entities have the intent field set
3. Register an actuality handler for the relevant mode
4. `just dev` — the loop discovers the reconciler and starts reconciling

No code changes needed. Adding a reconciler is adding an entity.

---

## Anti-Patterns

### Wrong: Imperative state management

```rust
// WRONG — imperative "do it now" approach
fn deploy(entity: &Entity) {
    start_process(entity);
    entity.data["state"] = "running";
}
```

Reconciliation is declarative: set intent, let the loop converge.

### Wrong: Hardcoded reconciler logic

```rust
// WRONG — reconciler behavior hardcoded in Rust
if entity.eidos == "deployment" && entity.data["desired_state"] == "running" {
    manifest(entity);
}
```

The loop reads reconciler entities from the graph. Adding new reconciliation behavior means adding entities, not code.

### Wrong: Reconciler without sense

```yaml
# WRONG — no feedback loop
transitions:
  - intent: running
    actual: null  # Never sensed!
    action: manifest
```

Every reconciler must sense actuality. Without sense, the loop can't detect drift or convergence.

---

## Implementation Location

| File | Purpose |
|------|---------|
| `crates/kosmos/src/phoreta.rs` | Federation transport types (Phoreta, SyncMessage, apply_phoreta) |
| `crates/kosmos/src/host.rs` | `host.reconcile()` entry point |
| `crates/kosmos/src/mode_dispatch.rs` | Generated `stoicheion_for_mode()` dispatch table |
| `crates/kosmos/src/reflex.rs` | Reflex engine that triggers reconciliation |
| `genesis/dynamis/reconcilers/dynamis.yaml` | Reconciler entity definitions |
| `app/src/lib/actuality.ts` | UI-side actuality handlers |

---

## Test Assertions

1. **Discovery**: The loop gathers all entities with `eidos: reconciler` and processes each one.

2. **Transition matching**: Given a reconciler with transitions `[(running, absent) → manifest]`, and a target entity with `intent=running, actual=absent` — the action `manifest` is selected.

3. **Manifest invocation**: When transition action is `manifest`, the mode handler's `manifest()` is called for the target entity.

4. **Sense writeback**: After `sense()` returns a state, the target entity's `actuality_field` is updated with the sensed value.

5. **Convergence**: After manifest succeeds and sense confirms `actual=running`, the transition `(running, running) → none` matches, and no further action is taken.

6. **No-op on match**: When intent equals actuality and the transition maps to `none`, no handler is invoked.

7. **New reconciler, no code**: Adding a new reconciler entity to genesis causes the loop to start reconciling that entity type on next cycle — no Rust code changes.

8. **Interval respect**: Each reconciler runs at its own `sense_interval_seconds` cadence, not every loop tick.

---

*See [HOMOICONIC-REACTIVE-SYSTEM.md](../../design/HOMOICONIC-REACTIVE-SYSTEM.md) for the reactive system design.*
*See [substrate-lifecycle.md](../infrastructure/substrate-lifecycle.md) for the mode handler interface.*
*For the full actualization pattern including mode taxonomy and completion stages, see [actualization-pattern.md](actualization-pattern.md).*
