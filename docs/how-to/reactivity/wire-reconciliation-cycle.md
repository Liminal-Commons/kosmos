# How to: Wire a Reconciliation Cycle

Wire a complete reconciliation cycle for an entity that needs self-healing — aligning desired state with actual state.

---

## When to Use

Use this pattern when:
- An entity has desired state (intent) and actual state (reality) that can diverge
- You need automatic correction when drift occurs
- The entity interacts with an external substrate (process, object storage, DNS)

---

## Overview

A reconciliation cycle has four parts:

1. **Reconciler entity** — declares transition rules (intent + actual → action)
2. **Mode entity** — maps actions to substrate operations
3. **Trigger + Reflex** — fires reconciliation when the entity changes
4. **Entity fields** — `desired_state` and `actual_state` on the target entity

---

## Step 1: Ensure the Entity Has State Fields

Your target eidos needs fields for intent and actuality:

```yaml
- eidos: eidos
  id: eidos/my-service
  data:
    name: my-service
    fields:
      desired_state:
        type: enum
        values: [running, stopped, removed]
        required: true
      actual_state:
        type: enum
        values: [running, stopped, error, unknown]
        default: unknown
      mode:
        type: string
        description: "Which mode handles this entity"
      provider:
        type: string
        default: local
        description: "Substrate provider"
```

---

## Step 2: Create the Reconciler Entity

The reconciler declares transition rules. Each rule matches an (intent, actual) pair to an action.

```yaml
# genesis/my-topos/reconcilers/my-service.yaml
entities:
  - eidos: reconciler
    id: reconciler/my-service
    data:
      name: my-service
      description: Reconcile desired vs actual state for my-service
      target_eidos: my-service
      intent_field: desired_state
      actuality_field: actual_state
      transitions:
        # Want running, currently stopped → start it
        - intent: running
          actual: [stopped, unknown, error]
          action: manifest

        # Want stopped, currently running → stop it
        - intent: stopped
          actual: running
          action: unmanifest

        # Want removed, currently running → stop first
        - intent: removed
          actual: running
          action: unmanifest

        # Want running, already running → check health
        - intent: running
          actual: running
          action: sense

        # Already in desired state → no action
        - intent: stopped
          actual: stopped
          action: none
```

**Transition fields:**
- `intent`: exact match against the intent field value
- `actual`: exact match or array (OR logic — matches any value in the array)
- `action`: `manifest`, `unmanifest`, `sense`, or `none`

---

## Step 3: Create or Reference a Mode Entity

The mode maps actions to substrate stoicheia. If your entity uses an existing mode (like `process/local`), skip this step.

For a custom mode:

```yaml
# genesis/my-topos/modes/my-substrate.yaml
entities:
  - eidos: mode
    id: mode/my-substrate-local
    data:
      substrate: compute
      name: my-substrate
      provider: local
      description: Manage my-service processes locally
      operations:
        manifest:
          stoicheion: spawn-process
          params: [command, working_dir, env]
        sense:
          stoicheion: check-process
          params: [pid]
          returns:
            alive: boolean
        unmanifest:
          stoicheion: kill-process
          params: [pid, signal]
```

Then ensure your entity's `mode` field matches (e.g., `"my-substrate"`) and `provider` matches (e.g., `"local"`).

---

## Step 4: Wire the Trigger and Reflex

Create a reflex that fires reconciliation when the entity is created or updated:

```yaml
# genesis/my-topos/reflexes/reconciliation.yaml
entities:
  # Trigger: fires on my-service entity creation
  - eidos: trigger
    id: trigger/my-service-created
    data:
      name: my-service-created
    bonds:
      - desmos: matches-event
        to: entity-mutation/created
      - desmos: filters-eidos
        to: eidos/my-service

  # Trigger: fires on my-service entity update
  - eidos: trigger
    id: trigger/my-service-updated
    data:
      name: my-service-updated
    bonds:
      - desmos: matches-event
        to: entity-mutation/updated
      - desmos: filters-eidos
        to: eidos/my-service

  # Reflex: reconcile on creation
  - eidos: reflex
    id: reflex/my-topos/reconcile-on-create
    data:
      name: reconcile-on-create
      description: Reconcile my-service when created
      enabled: true
      response_params:
        reconciler_id: "reconciler/my-service"
        entity_id: "$entity.id"
    bonds:
      - desmos: triggered-by
        to: trigger/my-service-created
      - desmos: responds-with
        to: praxis/ergon/reconcile

  # Reflex: reconcile on update
  - eidos: reflex
    id: reflex/my-topos/reconcile-on-update
    data:
      name: reconcile-on-update
      description: Reconcile my-service when state changes
      enabled: true
      response_params:
        reconciler_id: "reconciler/my-service"
        entity_id: "$entity.id"
    bonds:
      - desmos: triggered-by
        to: trigger/my-service-updated
      - desmos: responds-with
        to: praxis/ergon/reconcile
```

---

## Step 5: Add to Manifest

```yaml
content_paths:
  - path: reconcilers/
    content_types: [reconciler]
  - path: reflexes/
    content_types: [reflex, trigger]
  - path: modes/
    content_types: [mode]
```

---

## How It Works

```
Entity created/updated
    ↓
Reflex fires (matches eidos + event type)
    ↓
Calls ergon/reconcile with reconciler_id + entity_id
    ↓
host.reconcile() loads reconciler + entity
    ↓
Extracts intent (desired_state) and actual (actual_state)
    ↓
Finds matching transition rule
    ↓
Dispatches action:
  manifest  → resolve_mode() → spawn/create
  sense     → resolve_mode() → check/probe
  unmanifest → resolve_mode() → stop/delete
  none      → no-op
    ↓
Updates entity.last_reconciled_at
```

---

## Testing

```bash
just dev
```

Then create a test entity:
```yaml
demiurge/compose:
  typos_id: typos-def-my-service
  inputs:
    desired_state: running
    actual_state: stopped
    mode: process
    provider: local
```

The reflex should fire and attempt to manifest the service.

---

## See Also

- [Reactive System Reference](../../reference/reactivity/reactive-system-reference.md) — Full specification
- [Create Your First Reflex](../../tutorial/reactivity/create-your-first-reflex.md) — Reflex tutorial
- [Self-Healing Entities](../../tutorial/reactivity/self-healing-entities.md) — Hands-on tutorial

---

*Guide for wiring a complete reconciliation cycle.*
