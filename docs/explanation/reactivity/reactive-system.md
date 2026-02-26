# Reactive System Design

*The complete system for detecting change, aligning state, and touching substrate.*

## ✅ Implementation Status: COMPLETE (2026-01-30)

| Component | Kosmos | Chora |
|-----------|--------|-------|
| Reflex definitions (10) | ✅ | ✅ |
| Response praxeis (6) | ✅ | ✅ |
| Process stoicheia (4) | ✅ | ✅ |
| ReflexRegistry | — | ✅ |
| DaemonLoop | — | ✅ |
| Actuality dispatch | ✅ | ✅ |

**Verified E2E:** `desired_state: running` → reflex → reconciler → `spawn-process` → `actual_state: running`

---

## Overview

The reactive system is the autonomic nervous system of kosmos. It enables:

1. **Immediate response** to graph mutations (reflexes)
2. **Continuous alignment** between intent and actuality (reconcilers)
3. **Substrate abstraction** for external resources (infrastructure modes)

Together, these layers form a complete reactive architecture where the system *feels* its state and responds appropriately — whether to internal changes or external drift.

---

## The Three Layers

```
┌─────────────────────────────────────────────────────────────────┐
│  LAYER 1: EVENT DETECTION                                       │
│  ─────────────────────────                                      │
│  Reflex System                                                  │
│  • Watches graph mutations                                      │
│  • Matches trigger patterns                                     │
│  • Invokes response praxeis                                     │
│  • Question: "Something changed — what should happen?"          │
│  • Lives in: ergon                                              │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│  LAYER 2: STATE ALIGNMENT                                       │
│  ────────────────────────                                       │
│  Reconciler System                                              │
│  • Compares intent to actuality                                 │
│  • Determines action (manifest/unmanifest/none)                 │
│  • Declarative transition rules                                 │
│  • Question: "Is intent aligned with actuality?"                │
│  • Lives in: dynamis                                            │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│  LAYER 3: SUBSTRATE INTERFACE                                   │
│  ──────────────────────────                                     │
│  Mode System (Infrastructure Substrate)                         │
│  • Maps operations to stoicheia                                 │
│  • Provider abstraction                                         │
│  • Executes in chora, touches substrate                         │
│  • Question: "How does this type become actual?"                │
│  • Lives in: dynamis                                            │
└─────────────────────────────────────────────────────────────────┘
```

| Layer | Question | Trigger | Home |
|-------|----------|---------|------|
| Reflex | "What should happen?" | Graph mutation (event) | ergon |
| Reconciler | "Is intent aligned?" | Reflex or schedule (poll) | dynamis |
| Mode (Infrastructure) | "How to touch substrate?" | Reconciler action | dynamis |

---

## Layer 1: Reflex System

### Purpose

A **reflex** is an autonomic response to graph mutations. When the graph changes in a way that matches a reflex's trigger pattern, the reflex fires automatically without conscious invocation.

This implements the somatic architecture principle: the system *feels* its state and responds automatically, rather than requiring explicit polling or invocation.

### Mechanism

```
Graph mutation (entity/bond created, updated, deleted)
    ↓
Chora post-commit hook checks reflex registry
    ↓
Matching reflexes fire automatically
    ↓
Response praxis invoked with mutation context
```

### Definition

```yaml
- eidos: reflex
  id: reflex/deployment-intent-changed
  data:
    name: deployment-intent-changed
    description: "Trigger reconciliation when deployment intent changes"
    trigger:
      event: entity_updated
      eidos: deployment
      condition: '$entity.data.desired_state != $previous.data.desired_state'
    response:
      praxis: dynamis/reconcile-deployment
      params:
        deployment_id: "$entity.id"
```

### Trigger Events

| Event | Context Variables | Use Case |
|-------|-------------------|----------|
| `entity_created` | `$entity` | New entity arrived |
| `entity_updated` | `$entity`, `$previous` | Entity data changed |
| `entity_deleted` | `$entity` | Entity removed |
| `bond_created` | `$bond`, `$from`, `$to` | Relationship established |
| `bond_updated` | `$bond`, `$from`, `$to`, `$previous` | Bond data changed |
| `bond_deleted` | `$bond`, `$from`, `$to` | Relationship dissolved |

**Note:** The `$previous` variable is available for `_updated` events, containing the entity/bond state before the mutation.

### Reflex → Reconciler Binding

Reflexes often trigger reconcilers rather than doing work directly. This is the bridge between event-detection and state-alignment:

```yaml
# Reflex detects intent change
trigger:
  event: entity_updated
  eidos: deployment
  condition: '$entity.data.desired_state != $previous.data.desired_state'

# Response invokes reconciler
response:
  praxis: dynamis/reconcile-deployment
  params:
    deployment_id: "$entity.id"
```

This separation keeps reflexes focused on detection while reconcilers handle alignment logic.

### See Also

- [ergon/DESIGN.md](ergon/DESIGN.md) — Full reflex specification
- [CHORA-HANDOFF-REFLEXES.md](../CHORA-HANDOFF-REFLEXES.md) — Implementation guide

---

## Layer 2: Reconciler System

### Purpose

A **reconciler** aligns intent with actuality. It implements the phylax (φύλαξ / guardian) pattern:

1. **Sense** — Query actual state in substrate
2. **Compare** — Does actuality match intent?
3. **Act** — Manifest or unmanifest to align

### Mechanism

Reconcilers are declarative transition rules. Given an intent value and an actuality value, they determine what action to take:

```yaml
- eidos: reconciler
  id: reconciler/deployment
  data:
    target_eidos: deployment
    intent_field: desired_state
    actuality_field: actual_state

    # How to find the mode
    actuality:
      mode_field: mode                # or literal: "process"
      provider_field: provider        # or literal: "local"
      handle_field: manifest_handle   # where to store PID/handle

    transitions:
      # Want running, but not running → manifest
      - intent: running
        actual: [stopped, unknown, failed]
        action: manifest

      # Want stopped, but running → unmanifest
      - intent: stopped
        actual: running
        action: unmanifest

      # Already aligned → no action
      - intent: running
        actual: running
        action: none

      - intent: stopped
        actual: [stopped, unknown]
        action: none
```

### Two Modes of Triggering

**1. Sympathetic (Event-Driven)**

A reflex fires when intent changes, triggering immediate reconciliation:

```
User sets desired_state: running
    ↓
Reflex detects entity_updated
    ↓
Reflex invokes reconcile-deployment
    ↓
Reconciler senses, compares, manifests
```

**2. Parasympathetic (Poll-Based)**

A background loop periodically senses actuality and reconciles drift:

```
Process crashes externally (no kosmos mutation)
    ↓
Health check loop runs reconcile-deployment
    ↓
Reconciler senses actual_state: failed
    ↓
Reconciler re-manifests
```

The parasympathetic loop is the background metabolism — it detects external failures and self-heals without requiring a graph mutation to trigger it.

### Generic Reconcile Praxis

The `dynamis/reconcile` praxis interprets reconciler definitions:

```yaml
- eidos: praxis
  id: praxis/dynamis/reconcile
  data:
    name: reconcile
    description: "Generic reconciliation using declarative reconciler definition"
    params:
      - name: reconciler_id
        type: string
        required: true
      - name: entity_id
        type: string
        required: true
    steps:
      - step: find
        id: "$reconciler_id"
        bind_to: reconciler

      - step: find
        id: "$entity_id"
        bind_to: entity

      - step: sense_actuality
        entity_id: "$entity.id"
        bind_to: sensed

      # Extract intent and actual values
      - step: set
        bindings:
          intent: "$entity.data[$reconciler.data.intent_field]"
          actual: "$sensed.status"

      # Find matching transition
      - step: filter
        items: "$reconciler.data.transitions"
        condition: |
          (($item.intent == $intent) || ($intent in $item.intent)) &&
          (($item.actual == $actual) || ($actual in $item.actual))
        bind_to: matches

      # Execute action
      - step: switch
        cases:
          - when: "$matches[0].action == 'manifest'"
            then:
              - step: manifest
                entity_id: "$entity.id"
          - when: "$matches[0].action == 'unmanifest'"
            then:
              - step: unmanifest
                entity_id: "$entity.id"

      # Update entity with sensed state
      - step: update
        id: "$entity.id"
        data:
          actual_state: "$sensed.status"
          last_reconciled_at: "{{ now() }}"
```

### See Also

- [dynamis/DESIGN.md](dynamis/DESIGN.md) — Full reconciler specification
- [dynamis/reconcilers/dynamis.yaml](dynamis/reconcilers/dynamis.yaml) — Existing reconciler definitions

---

## Layer 3: Mode System (Infrastructure Substrate)

### Purpose

An **infrastructure mode** is a category of substrate manifestation. It answers: "In what manner does this type of entity become actual?"

Different entities become actual in different ways:

| Entity | Mode | Substrate |
|--------|------|-----------|
| deployment | process | OS process table |
| release-artifact | object-storage | R2, S3, filesystem |
| dns-record | dns | Cloudflare, Route53 |

### Mode and Provider

The **mode** is the category of actuality: `process`, `object-storage`, `dns`

The **provider** is the specific substrate: `local`, `docker`, `r2`, `s3`, `cloudflare`

Same mode, different providers:

| Mode | Provider | Manifest Stoicheion |
|------|----------|---------------------|
| process | local | spawn-process |
| process | docker | docker-run |
| object-storage | local | fs-write-file |
| object-storage | r2 | r2-put-object |
| dns | cloudflare | cf-create-record |

### The Three Operations

Every infrastructure mode defines three operations:

**1. Manifest (γένεσις)** — Bring into actuality
- Process: spawn the command
- Object-storage: write the bytes
- DNS: create the record

**2. Sense (αἴσθησις)** — Perceive current actuality
- Process: is PID alive? what's its state?
- Object-storage: does key exist? what's its etag?
- DNS: what does the record resolve to?

**3. Unmanifest (φθορά)** — Remove from actuality
- Process: kill the process
- Object-storage: delete the object
- DNS: remove the record

### Definition

```yaml
- eidos: mode
  id: mode/process-local
  data:
    name: process
    provider: local
    description: "Local process execution mode"
    operations:
      manifest:
        stoicheion: spawn-process
        params: [command, args, env, working_dir]
        returns:
          pid: number
          status: string
      sense:
        stoicheion: check-process
        params: [pid]
        returns:
          running: boolean
          exit_code: number
      unmanifest:
        stoicheion: kill-process
        params: [pid, signal]
```

### Schema-Driven Dispatch

The interpreter looks up modes at runtime:

```
Entity declares: mode = "process", provider = "local"
    ↓
Lookup: mode/process-local
    ↓
Operation: manifest → stoicheion: spawn-process
    ↓
Execute stoicheion with entity params
```

This is schema-driven: adding a new provider requires only YAML, not code changes (unless the stoicheion itself is new).

### See Also

- [dynamis/DESIGN.md](dynamis/DESIGN.md) — Full mode specification
- [dynamis/modes/dynamis.yaml](dynamis/modes/dynamis.yaml) — Existing mode definitions

---

## The Complete Flow

### Scenario 1: User Sets desired_state = "running"

```
1. MUTATION
   Entity updated: deployment/my-service
   Change: desired_state: stopped → running

2. REFLEX FIRES
   reflex/deployment-intent-changed matches:
   - event: entity_updated ✓
   - eidos: deployment ✓
   - condition: desired_state changed ✓

   Response: invoke dynamis/reconcile-deployment

3. RECONCILER RUNS
   praxis/dynamis/reconcile-deployment:

   a. Load reconciler definition (reconciler/deployment)
   b. Load entity (deployment/my-service)
   c. Sense actuality via mode
   d. Compare: intent=running, actual=stopped
   e. Match transition: → action: manifest

4. MANIFEST VIA ACTUALITY MODE

   a. Get mode from entity: mode = "process"
   b. Get provider from entity: provider = "local"
   c. Lookup: mode/process-local
   d. Get stoicheion: manifest → spawn-process
   e. Map params from entity data

5. STOICHEION EXECUTES

   spawn-process(
     command: "./server",
     args: ["--port", "8080"],
     env: { PORT: "8080" },
     working_dir: "/app"
   )

   Returns: { pid: 12345, status: "running" }

6. ENTITY UPDATED

   deployment/my-service:
     actual_state: running
     manifest_handle: "12345"
     last_reconciled_at: "2026-01-30T..."
```

### Scenario 2: Process Crashes Externally

```
1. NO MUTATION (substrate event, not kosmos)

   Process 12345 terminates unexpectedly.
   Kosmos is unaware — no graph mutation occurred.

2. PARASYMPATHETIC LOOP (periodic health check)

   Background task runs reconcile-deployment for all
   deployments with desired_state: running

3. RECONCILER SENSES DRIFT

   a. Sense actuality: check-process(pid: 12345)
   b. Returns: { running: false, exit_code: 1 }
   c. Update entity: actual_state: failed

4. RECONCILER ACTS

   a. Compare: intent=running, actual=failed
   b. Match transition: → action: manifest
   c. spawn-process(...) → new PID 12346

5. SELF-HEALING COMPLETE

   deployment/my-service:
     actual_state: running
     manifest_handle: "12346"
     last_reconciled_at: "2026-01-30T..."
```

---

## Relationship to Other Systems

### Cursor Model

The cursor model (`last-saw` desmos) tracks what Claude has *observed*.
Reflexes track what the *system* should *do* in response to changes.

They complement each other:

| System | Question | Tracks |
|--------|----------|--------|
| Cursor | "What's new for Claude to see?" | Observation |
| Reflex | "What should happen automatically?" | Action |
| Reconciler | "Are we where we want to be?" | Alignment |

### Tier Model

The reactive system maps to the stoicheion tier model:

| Tier | Operations | Reactive System Role |
|------|------------|----------------------|
| 0-1 | Pure computation, control flow | Reflex matching, reconciler logic |
| 2 | Graph operations | Entity reads/updates |
| 3 | Actuality operations | Substrate interface |

Tier 0-1 operations (matching, comparison) are portable and could run in a sandboxed environment. Tier 3 operations (spawn-process, etc.) require native access to substrate.

### Attainments

Tier 3 operations are gated by attainments:

- `deploy` attainment required for deployment reconciliation
- `distribute` attainment required for release distribution
- `reconcile` attainment required for generic reconciliation

A reflex can trigger a reconciler, but the reconciler's Tier 3 operations still require the invoking parousia to hold the appropriate attainment.

---

## Error Handling

### Manifest Failures

When a manifest operation fails:

1. **Log the error** with context (entity_id, stoicheion, params)
2. **Update entity** with `actual_state: failed`
3. **Optionally create pragma** for manual intervention

Example reflex for auto-pragma on failure:

```yaml
- eidos: reflex
  id: reflex/manifest-failure-pragma
  data:
    trigger:
      event: entity_updated
      condition: '$entity.data.actual_state == "failed"'
    response:
      praxis: ergon/create-pragma
      params:
        title: "Manifest failed: $entity.id"
        signals_to: "oikos/ops"
```

### Reflex Failures

When a reflex's response praxis fails:

1. **Isolate the failure** — don't block other reflexes
2. **Log with reflex_id and mutation context**
3. **Continue processing** — one bad reflex shouldn't break the system

### Reconciliation Loops

Prevent infinite loops:

- **Depth limit** — reflexes can't trigger more than N levels deep
- **Debounce** — same reflex on same entity within T seconds is suppressed
- **Circuit breaker** — disable reflex after repeated failures

---

## Implementation Details (Chora)

*These are the actual implementations, verified working.*

### Reflex Registry (reflex.rs)

```rust
pub struct ReflexRegistry {
    // Indexed by event type for fast lookup
    by_event: HashMap<EventType, Vec<ReflexEntry>>,
}

impl ReflexRegistry {
    /// Load all enabled reflexes at bootstrap
    pub fn load(host: &HostContext) -> Result<Self>;

    /// Check which reflexes match a mutation event
    pub fn check(&self, event: &MutationEvent) -> Vec<ReflexMatch>;

    /// Refresh when reflex entities change
    pub fn refresh(&mut self, host: &HostContext) -> Result<()>;
}
```

### Post-Commit Hook (host.rs:notify_change)

```rust
impl HostContext {
    fn on_mutation(&self, event: MutationEvent) {
        // Check reflex registry
        let matches = self.reflex_registry.check(&event);

        for m in matches {
            // Invoke response praxis with context
            if let Err(e) = self.invoke_praxis(
                &m.reflex.response.praxis,
                m.context.to_params(&m.reflex.response.params)
            ) {
                eprintln!("[reflex] {} failed: {}", m.reflex.id, e);
                // Continue — don't let one failure block others
            }
        }
    }
}
```

### Actuality Dispatch (host.rs:manifest)

```rust
pub fn manifest(&self, entity_id: &str) -> Result<Value> {
    // 1. Find entity
    let entity = self.find_entity(entity_id)?;

    // 2. Get actuality configuration from entity or eidos
    let mode = entity.get("data.mode").as_str()
        .unwrap_or("process");
    let provider = entity.get("data.provider").as_str()
        .unwrap_or("local");

    // 3. Lookup mode (generated dispatch table)
    let stoicheion_name = stoicheion_for_mode(mode, provider, ModeOperation::Manifest)
        .ok_or_else(|| KosmosError::NotFound(
            format!("No manifest stoicheion for {}/{}", mode, provider)
        ))?;

    // 4. Map params from entity data
    let mode_entity = self.find_entity(
        &format!("mode/{}-{}", mode, provider)
    )?;
    let param_names = mode_entity
        .get("data.operations.manifest.params")
        .as_array()?;
    let params = self.map_entity_to_params(&entity, param_names)?;

    // 5. Execute stoicheion
    execute_stoicheion(stoicheion_name, params)
}
```

### Daemon Loop + Reconciler Engine

The parasympathetic (periodic) path uses the daemon loop as a trigger mechanism that feeds into `host.reconcile()`:

```rust
// Daemon loop (daemon_loop.rs) — periodic trigger
// Each daemon entity declares a praxis and interval.
// The loop ticks at 1s resolution and invokes praxeis when due.

// Reconciler engine (host.rs) — generic sense-compare-act
// host.reconcile(reconciler_id, entity_id) reads transition tables
// from reconciler entities and dispatches actions through modes.
```

Federation orchestration (the former `FederationReconciler`) has been dissolved. Federation sync is now prescribed by aither genesis entities (reflexes, daemons, reconciler entities) and executed through the same generic mechanisms as every other reconciliation cycle.

---

## Schema Definitions (Implemented)

### Process Stoicheia

Located at `genesis/stoicheia-portable/eide/stoicheion.yaml`:

```yaml
# Tier 3: Process actuality operations

- eidos: eidos
  id: eidos/stoicheion/spawn-process
  data:
    name: spawn-process
    tier: 3
    description: "Spawn a background process"
    params:
      command: { type: string, required: true }
      args: { type: array, required: false }
      env: { type: object, required: false }
      working_dir: { type: string, required: false }
    returns:
      pid: { type: number }
      status: { type: string }

- eidos: eidos
  id: eidos/stoicheion/check-process
  data:
    name: check-process
    tier: 3
    description: "Check if a process is running"
    params:
      pid: { type: number, required: true }
    returns:
      running: { type: boolean }
      exit_code: { type: number }
      cpu_usage: { type: number }
      memory_usage: { type: number }

- eidos: eidos
  id: eidos/stoicheion/kill-process
  data:
    name: kill-process
    tier: 3
    description: "Terminate a process"
    params:
      pid: { type: number, required: true }
      signal: { type: number, required: false, default: 15 }
    returns:
      success: { type: boolean }
```

### Deployment Eidos (with actuality fields)

Located at `genesis/dynamis/eide/dynamis.yaml`:

```yaml
- eidos: eidos
  id: eidos/deployment
  data:
    name: deployment
    fields:
      # ... existing fields ...

      mode:
        type: string
        required: true
        default: process
        description: "Mode (process, object-storage, dns)"

      provider:
        type: string
        required: false
        default: local
        description: "Provider within the mode (local, docker, r2)"
```

---

## What Was Built

### Seed Reflexes (10)

| Topos | Reflex | Trigger | Response |
|-------|--------|---------|----------|
| demiurge | artifact-added | bond_created (contains → topos) | update-manifest |
| demiurge | praxis-added | bond_created (contains → praxis) | register-praxis-tool |
| demiurge | praxis-changed | entity_updated (praxis) | validate-praxis |
| ergon | pragma-signaled | bond_created (signals-to → oikos) | add-notification |
| ergon | pragma-resolved | entity_updated (pragma) | add-notification |
| nous | theoria-created | entity_created (theoria) | index-entity |
| nous | phasis-created | entity_created (phasis) | index-entity |
| dynamis | deployment-intent-changed | entity_updated (deployment) | reconcile |
| dynamis | release-artifact-intent-changed | entity_updated (release-artifact) | reconcile |
| aither | sync-message-received | entity_created (sync-message) | process-sync-message |

### Response Praxeis (6)

| Praxis | Topos | Purpose |
|--------|-------|---------|
| demiurge/update-manifest | demiurge | Update topos manifest on artifact add |
| demiurge/register-praxis-tool | demiurge | Register praxis as MCP tool |
| demiurge/validate-praxis | demiurge | Validate praxis steps against schemas |
| soma/add-notification | soma | Create notification for body-schema |
| nous/index-entity | nous | Semantic indexing via embeddings |
| aither/process-sync-message | aither | Route federation sync messages |

### Process Stoicheia (4)

| Stoicheion | Tier | Purpose |
|------------|------|---------|
| spawn-process | 3 | Spawn background process, return PID |
| check-process | 3 | Check if PID is alive via kill(0) |
| kill-process | 3 | Terminate process with signal |
| register-mcp-tool | 3 | Register praxis as dynamic MCP tool |

### Chora Implementation

| Component | Location | Description |
|-----------|----------|-------------|
| ChangeEvent | host.rs:82-133 | 6 symmetric variants (EntityCreated/Updated/Deleted, BondCreated/Updated/Deleted) |
| ReflexRegistry | reflex.rs | Load, index, match, execute reflexes |
| DaemonLoop | daemon_loop.rs | Parasympathetic periodic trigger (per-daemon intervals) |
| Actuality dispatch | host.rs:manifest() | Mode/provider → stoicheion routing |
| Depth limiting | host.rs:notify_change() | MAX_REFLEX_DEPTH=10 prevents infinite chains |

### Key Design Decisions

| Decision | Rationale |
|----------|-----------|
| 6 symmetric ChangeEvent variants | 1:1 mapping with EventType eliminates conditional logic |
| AtomicU32 for depth | Thread-safe across async contexts |
| Enrich at notification time | Capture from_eidos/to_eidos once, all reflexes benefit |
| Full entity resolution | $from/$to are complete entities, not just IDs |
| Failures don't block | Reflex errors logged but don't stop original mutation |

---

## Constitutional Alignment

The reactive system honors kosmos principles:

| Principle | How Honored |
|-----------|-------------|
| **Schema-driven** | Reflexes, reconcilers, and modes are all YAML definitions interpreted at runtime. Adding new behaviors = editing YAML, not code. |
| **Graph-driven** | Reflexes trigger on graph mutations. Reconciler state is entity fields. The bond graph IS the configuration. |
| **Cache-driven** | Actuality records provide audit trail. Content-addressed sensing could enable caching of substrate state. |
| **Composition-only** | Reflexes compose trigger + response. Reconcilers compose intent + actuality + transitions. Modes compose operations + stoicheia. |

---

## References

### Kosmos Definitions

| Path | Contents |
|------|----------|
| [demiurge/entities/reflexes.yaml](demiurge/entities/reflexes.yaml) | 3 topos development reflexes |
| [ergon/entities/reflexes.yaml](ergon/entities/reflexes.yaml) | 2 pragma notification reflexes |
| [nous/entities/reflexes.yaml](nous/entities/reflexes.yaml) | 2 knowledge indexing reflexes |
| [dynamis/entities/reflexes.yaml](dynamis/entities/reflexes.yaml) | 2 reconciliation reflexes |
| [aither/entities/reflexes.yaml](aither/entities/reflexes.yaml) | 1 federation sync reflex |
| [stoicheia-portable/eide/stoicheion.yaml](stoicheia-portable/eide/stoicheion.yaml) | Process stoicheia definitions |
| [dynamis/reconcilers/dynamis.yaml](dynamis/reconcilers/dynamis.yaml) | Reconciler entities |

### Design Documents

- [ergon/DESIGN.md](ergon/DESIGN.md) — Reflex system specification
- [dynamis/DESIGN.md](dynamis/DESIGN.md) — Reconciler and mode specification
- [REACTIVE-SYSTEM-PLAN.md](../REACTIVE-SYSTEM-PLAN.md) — Implementation plan (complete)
- [CHORA-HANDOFF-REFLEXES.md](../CHORA-HANDOFF-REFLEXES.md) — Chora implementation guide

---

*Implemented 2026-01-30.*
*The system feels its state. Intent aligns with actuality. The graph responds.*

*For mode catalog, completion status, and the extension pattern for adding new modes, see [actualization-pattern.md](../../reference/reactivity/actualization-pattern.md).*
