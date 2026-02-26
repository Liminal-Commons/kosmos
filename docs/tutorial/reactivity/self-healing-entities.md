# Tutorial: Self-Healing Entities

Learn the reconciliation pattern — entities that automatically align their desired state with actual state.

---

## What You'll Learn

- How reconciler entities declare transition rules
- How reflexes trigger reconciliation on state changes
- How actuality modes bridge intent and reality
- The complete self-healing cycle

---

## Prerequisites

- Completed [Create Your First Reflex](create-your-first-reflex.md)
- Understanding of [triggers and reflexes](../../how-to/reactivity/define-custom-triggers.md)

---

## Step 1: Understand the Pattern

A self-healing entity has two state fields:
- **desired_state** — what you want (intent)
- **actual_state** — what exists (reality)

When these diverge, a **reconciler** determines what action to take:

| Desired | Actual | Action |
|---------|--------|--------|
| running | stopped | manifest (start it) |
| stopped | running | unmanifest (stop it) |
| running | running | sense (check health) |
| stopped | stopped | none (already aligned) |

---

## Step 2: Examine a Real Reconciler

Look at the deployment reconciler in genesis:

```yaml
# genesis/dynamis/reconcilers/dynamis.yaml
- eidos: reconciler
  id: reconciler/deployment
  data:
    name: deployment
    description: Reconcile deployment desired vs actual state
    target_eidos: deployment
    intent_field: desired_state
    actuality_field: actual_state
    transitions:
      - intent: running
        actual: [stopped, unknown, error]
        action: manifest

      - intent: stopped
        actual: running
        action: unmanifest

      - intent: running
        actual: running
        action: sense

      - intent: stopped
        actual: stopped
        action: none
```

Key parts:
- `target_eidos: deployment` — this reconciler handles deployment entities
- `intent_field` / `actuality_field` — which fields to compare
- `transitions` — rules mapping (intent, actual) pairs to actions
- `actual: [stopped, unknown, error]` — array means "match ANY of these" (OR logic)

---

## Step 3: See the Wiring

The reconciler doesn't run by itself. It needs a reflex to trigger it. Here's the pattern:

```yaml
# Trigger: fires when a deployment entity is updated
- eidos: trigger
  id: trigger/deployment-updated
  data:
    name: deployment-updated
  bonds:
    - desmos: matches-event
      to: entity-mutation/updated
    - desmos: filters-eidos
      to: eidos/deployment

# Reflex: calls reconcile when triggered
- eidos: reflex
  id: reflex/dynamis/reconcile-deployment
  data:
    name: reconcile-deployment
    description: Reconcile deployment state on update
    enabled: true
    response_params:
      reconciler_id: "reconciler/deployment"
      entity_id: "$entity.id"
  bonds:
    - desmos: triggered-by
      to: trigger/deployment-updated
    - desmos: responds-with
      to: praxis/ergon/reconcile
```

The chain:
1. Deployment entity updated → mutation event fires
2. Trigger matches (entity-mutation/updated + eidos/deployment)
3. Reflex fires → calls `ergon/reconcile` with reconciler_id and entity_id
4. `host.reconcile()` loads reconciler, reads fields, matches transition, dispatches action

---

## Step 4: Trace the Reconciliation

When `host.reconcile("reconciler/deployment", "deployment/my-service")` runs:

1. **Load reconciler** → gets transition table
2. **Load entity** → reads `desired_state` and `actual_state`
3. **Match transition** → finds first rule where intent and actual match
4. **Dispatch action:**
   - `manifest` → `resolve_mode(entity)` → calls substrate to start process
   - `sense` → `resolve_mode(entity)` → probes substrate for health
   - `unmanifest` → `resolve_mode(entity)` → calls substrate to stop process
   - `none` → no-op

The `resolve_mode()` function reads `data.mode` and `data.provider` from the entity to determine which substrate handler to call.

---

## Step 5: Introduce Drift

To see reconciliation in action, update an entity's desired state:

```yaml
# Entity currently: desired_state=stopped, actual_state=stopped (aligned)

# Change desired state to "running"
oikos/update:
  entity_id: "deployment/my-service"
  data:
    desired_state: running
```

What happens:
1. Entity updated → mutation event
2. Reflex fires → calls `ergon/reconcile`
3. Reconciler reads: intent=`running`, actual=`stopped`
4. Matches: `intent: running, actual: [stopped, unknown, error], action: manifest`
5. Dispatches `manifest` → substrate starts the process
6. Entity gets `last_reconciled_at` timestamp

---

## Step 6: Understand the Cycle

The reconciliation cycle is continuous:

```
Developer sets desired_state
    ↓
Entity update triggers reflex
    ↓
Reconciler compares intent vs actual
    ↓
Dispatches action (manifest/sense/unmanifest/none)
    ↓
Substrate executes (start/check/stop)
    ↓
Entity actual_state updated
    ↓
Update triggers reflex again
    ↓
Reconciler: intent == actual → action: none (converged)
```

The cycle converges when intent matches actuality. If the substrate fails, the reconciler will keep trying on subsequent triggers.

---

## Key Concepts

**Declarative, not imperative.** You don't write "start the service." You set `desired_state: running` and the reconciler figures out what to do.

**Generic engine.** `host.reconcile()` doesn't know about deployments, DNS records, or objects. It reads field paths and transition tables from the reconciler entity.

**Actuality modes bridge the gap.** The reconciler decides *what* to do (manifest/sense/unmanifest). The actuality mode decides *how* to do it (which substrate stoicheion to call).

**Reflexes are dormant during bootstrap.** Entity loading at startup doesn't trigger reconciliation. Reflexes activate after `exit_bootstrap_mode()`.

---

## See Also

- [Wire a Reconciliation Cycle](../../how-to/reactivity/wire-reconciliation-cycle.md) — Step-by-step guide for your own entities
- [Create Your First Reflex](create-your-first-reflex.md) — How reflexes work
- [Reactive System Reference](../../reference/reactivity/reactive-system-reference.md) — Full specification

---

*You've seen the reconciliation pattern. Entities heal themselves — set the desired state, and the kosmos converges toward it.*
