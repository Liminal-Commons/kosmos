# Daemon Runner — Generic Periodic Praxis Invocation

**STATUS: SHIPPED** — `daemon_loop.rs` (~250 lines), `reconciler_loop.rs` retired, 5 sensing daemons + drift reflexes in genesis, integration tests passing.

*Prompt for Claude Code in the chora + kosmos repository context.*

*Replaces PROMPT-RECONCILER-ENGINE.md. Reconciliation decomposes into the reflex engine + a generic daemon runner. See `docs/proposal/homoiconic-reconciliation.md` for the design rationale.*

---

## Methodology — Doc-Driven, Clean Break

This work follows **Doc → Test → Build → Verify Doc**, non-negotiably.

### The Cycle

1. **Doc (prescriptive)**: Write `docs/reference/daemon-runner.md` describing the *desired state* — daemon eidos, bootstrap loading, periodic invocation, backoff, status tracking.
2. **Test (assert the doc)**: Write tests that assert daemon entities load at bootstrap, praxeis are invoked at interval, backoff works, disabled daemons don't fire. Tests should fail before implementation.
3. **Build (satisfy the tests)**: Implement until tests pass.
4. **Verify doc (confirm truth)**: After implementation, re-read the reference doc. Update deviations so the doc ends as truth.

### Clean Break — No Custom Reconciler Engine

The original plan (PROMPT-RECONCILER-ENGINE.md) proposed building `reconciler_ergon.rs` — a ~1,000+ line Rust module with custom sense-compare-act logic. This is replaced by:

- **One generic substrate primitive**: the daemon runner (~100-150 lines), which periodically invokes any praxis
- **Reconciliation as composition**: sensing daemons + drift-detection reflexes + corrective praxeis, all declared in genesis YAML
- **No reconciler-specific Rust code.** The reconciler entities remain as declarative configuration that praxeis read from. The engine that executes them is the interpreter, the reflex engine, and the daemon runner — all general-purpose.

### What "Reference Doc" Means

Reference docs in this project are *prescriptive* (target state), not descriptive (current state). When code doesn't match a reference doc, the code has a gap — not the doc (unless the design changed). See CONTRIBUTING.md for the full methodology.

---

## The Core Insight

Reconciliation decomposes into two concerns:

1. **Sensing** — periodically check external/actual state and update entity fields
2. **Reacting** — when actuality diverges from intent, take corrective action

Concern 2 is a reflex. The reflex engine (already shipped) handles this: graph mutation (actuality field changed) → trigger match (intent != actuality) → response praxis (correct the drift).

Concern 1 needs one substrate primitive: periodic praxis invocation. That's a generic daemon capability, not a reconciler.

```
daemon ticks → sense_actuality praxis updates entity field
                                        │
                                  entity_updated mutation
                                        │
                               reflex trigger matches drift
                                        │
                               response praxis corrects + reports
```

The reconciler dissolves into: **the reflex engine + a daemon runner.**

---

## Dependencies

### Reflex Engine (PROMPT-REFLEX-ENGINE.md) — prerequisite, already shipped

The drift-detection reflexes fire on `entity_updated` when intent != actuality. The reflex engine handles:
- Bonded trigger matching (matches-event → entity-mutation/updated, filters-eidos)
- Condition evaluation (`$entity.data.desired_state != $entity.data.actual_state`)
- Response praxis invocation (corrective action)
- Error isolation (reflex failure doesn't block the triggering mutation)

### Manifest Validation (PROMPT-MANIFEST-VALIDATION.md) — already shipped

Validates that target_eidos references in reconciler entities actually exist.

**Post-ship finding:** `genesis/ergon/manifest.yaml` `provides.eide` must include `daemon` — the eidos is defined in `genesis/ergon/eide/ergon.yaml` but the manifest doesn't declare it. Without this, manifest validation would flag `eidos/daemon` as undeclared.

### Attainment Authorization (PROMPT-ATTAINMENT-AUTHORIZATION.md) — already shipped

The daemon runner calls `invoke_praxis()` with no dwelling context. The authorization gate bypasses entirely when dwelling is `None` (bootstrap/CLI/system mode). This is by design — daemons and reflexes are internal system machinery, not user-facing operations. The attainment gate only applies to user-invoked praxeis via `invoke_praxis_dwelling()`.

No system-level attainment or public praxis marking is needed for daemon-invoked praxeis.

---

## Context

### What Exists

**Reconciler entities** (4, across 4 topoi):

| Entity | Topos | Target | Intent vs Actuality |
|--------|-------|--------|---------------------|
| `reconciler/deployment-health` | dynamis | deployment | `desired_state` vs `actual_state` |
| `reconciler/syndesmos-reconnect` | aither | syndesmos | `intent` vs `status` |
| `reconciler/release-distribution` | release | release | distributed vs artifact presence |
| `reconciler/graph-integrity` | dokimasia | validation-result | `expected_outcome` vs `outcome` |

These remain as **declarative configuration** — the transition tables, target eidos, and field mappings that praxeis read from.

**Daemon entities** (2, in chora-dev — ahead of their eidos):

| Entity | Type | Purpose |
|--------|------|---------|
| `daemon/chora-dev-watcher` | file-watcher | Watch source files, trigger staleness detection |
| `daemon/chora-dev-build-queue` | queue-processor | Process build queue |

These use a more specialized daemon pattern (file-watcher, queue-processor). The generic daemon runner handles the simpler `interval + praxis` pattern first.

**Missing: `eidos/daemon`** — the daemon eidos is referenced by entities but never defined.

**`sense_actuality`** — already a stoicheion used in dynamis, aither, thyra, and chora-dev praxeis. The sensing mechanism exists.

**`for_each`** — widely used stoicheion. Iterating over target entities is standard.

---

## Design

### 1. Define `eidos/daemon`

```yaml
- eidos: eidos
  id: eidos/daemon
  data:
    name: daemon
    description: "Background task that periodically invokes a praxis"
    fields:
      - name: name
        type: string
        required: true
      - name: description
        type: string
      - name: praxis
        type: string
        required: true
        description: "Praxis ID to invoke periodically"
      - name: interval
        type: number
        required: true
        description: "Seconds between invocations"
      - name: enabled
        type: boolean
        default: true
      - name: scope
        type: enum
        values: [global, dwelling, topos]
        default: global
      - name: backoff_max
        type: number
        description: "Maximum backoff interval in seconds (for retry on failure)"
      - name: status
        type: enum
        values: [running, stopped, errored]
        default: stopped
        description: "Current daemon status (set by runner, not by author)"
```

Place in `genesis/ergon/eide/ergon.yaml` (ergon owns background tasks).

### 2. Daemon Runner (~100-150 lines of Rust)

At bootstrap, after all content is loaded:

1. `gather(eidos: daemon)` — find all daemon entities
2. For each enabled daemon:
   - Validate that `daemon.data.praxis` exists (fail fast on misconfiguration)
   - Spawn a `tokio::interval` task at `daemon.data.interval` seconds
   - On each tick: invoke the declared praxis via the interpreter
   - On success: reset backoff to `interval`
   - On failure: log error, increase backoff (capped at `backoff_max` if set), update daemon status to `errored`
3. Track daemon status as entity field update (`running`, `stopped`, `errored`)

This is NOT a new module file. It's a function in `host.rs` or `bootstrap.rs` — `start_daemons()` — called after bootstrap completes.

### 3. Express Reconciliation as Daemon + Reflex + Praxis

Each of the 4 reconcilers becomes a triplet: **sensing daemon + drift-detection reflex + corrective praxis**.

#### deployment-health

**Sensing daemon:**
```yaml
- eidos: daemon
  id: daemon/sense-deployments
  data:
    name: sense-deployments
    description: "Periodically sense deployment actuality"
    praxis: dynamis/sense-deployment-states
    interval: 30
    enabled: true
```

**Sensing praxis** (invoked by daemon):
```yaml
# dynamis/sense-deployment-states
steps:
  - step: gather
    eidos: deployment
    bind_to: deployments
  - step: for_each
    items: "$deployments"
    item_name: deployment
    steps:
      - step: sense_actuality
        entity_id: "$deployment.id"
```

**Drift-detection reflex** (fires on entity update):
```yaml
- eidos: trigger
  id: trigger/dynamis/deployment-drift
  data:
    name: deployment-drift
    condition: '$entity.data.desired_state != $entity.data.actual_state'
    enabled: true

# Bonds:
# trigger/dynamis/deployment-drift --[matches-event]--> entity-mutation/updated
# trigger/dynamis/deployment-drift --[filters-eidos]--> eidos/deployment
# reflex/dynamis/deployment-drift --[triggered-by]--> trigger/dynamis/deployment-drift
# reflex/dynamis/deployment-drift --[responds-with]--> praxis/dynamis/reconcile-deployment
```

**Corrective praxis** (invoked by reflex):
```yaml
# dynamis/reconcile-deployment
steps:
  - step: find
    entity_id: reconciler/deployment-health
    bind_to: reconciler
  - step: set
    name: intent
    value: "$entity.data.desired_state"
  - step: set
    name: actual
    value: "$entity.data.actual_state"
  # Match transitions — if action is manifest, invoke dynamis
  # If action is none, skip
  # Always report drift via phasis
  - step: call
    praxis: logos/emit-phasis
    params:
      content: "Drift: $entity.id — intent $intent, actual $actual"
      stance: observation
      source_kind: topos
```

Apply the same pattern for the other 3 reconcilers:

#### syndesmos-reconnect
- Daemon: `daemon/sense-syndesmos` → `aither/sense-syndesmos-states` (interval: 30, backoff_max: 300)
- Reflex: trigger on `entity_updated` + `eidos/syndesmos` + condition `$entity.data.intent != $entity.data.status`
- Corrective praxis: `aither/reconcile-syndesmos`

#### release-distribution
- Daemon: `daemon/sense-releases` → `release/sense-release-distribution` (interval: 300)
- Reflex: trigger on `entity_updated` + `eidos/release` + condition on distribution state
- Corrective praxis: `release/reconcile-distribution`

#### graph-integrity
- Daemon: `daemon/sense-graph-integrity` → `dokimasia/sense-validation-results` (interval: 60)
- Reflex: trigger on `entity_updated` + `eidos/validation-result` + condition `$entity.data.expected_outcome != $entity.data.outcome`
- Corrective praxis: `dokimasia/reconcile-validation`

### 4. Reconciler Entity Schema Stays

The `eidos/reconciler` entities remain as **declarative configuration**. The corrective praxeis read from them:

```yaml
- step: find
  entity_id: reconciler/deployment-health
  bind_to: reconciler
# Now $reconciler.data.transitions is available for matching
```

The transition tables, target_eidos, intent_field, actuality_field — all still useful as configuration that praxeis consume. What changes is that no custom Rust engine interprets them.

---

## Implementation Order

### Step 1: Doc (prescriptive spec)

**Write `docs/reference/daemon-runner.md`** — the complete specification:
- Daemon eidos (praxis, interval, enabled, scope, backoff_max, status)
- Bootstrap loading: gather all daemon entities, validate praxis references, spawn tasks
- Periodic invocation: interval-based, per-daemon task
- Backoff: on failure, double interval capped at backoff_max, reset on success
- Status tracking: running/stopped/errored as entity field updates
- Error handling: per-daemon, failure doesn't affect other daemons
- Integration with reflex engine: daemon sensing triggers entity updates, reflexes react
- Reconciliation as composition: the 4 reconciler decompositions

### Step 2: Genesis (daemon eidos + reconciler decomposition)

1. **Define `eidos/daemon`** in `genesis/ergon/eide/ergon.yaml`
2. **Create 4 sensing daemons** in their respective topoi:
   - `genesis/dynamis/entities/daemons.yaml` — `daemon/sense-deployments`
   - `genesis/aither/entities/daemons.yaml` — `daemon/sense-syndesmos`
   - `genesis/release/entities/daemons.yaml` — `daemon/sense-releases`
   - `genesis/dokimasia/entities/daemons.yaml` — `daemon/sense-graph-integrity`
3. **Create 4 sensing praxeis** in their respective topoi
4. **Create 4 drift-detection reflexes** (trigger + reflex + bonds) in their respective topoi
5. **Create 4 corrective praxeis** in their respective topoi

### Step 3: Test (assert the doc)

**Write tests BEFORE implementation** in `crates/kosmos/tests/daemon_runner.rs`:
- Test: daemon entities load at bootstrap
- Test: daemon with valid praxis starts successfully (status → running)
- Test: daemon with invalid praxis fails at load time (not at first tick)
- Test: disabled daemon (enabled: false) doesn't spawn a task
- Test: daemon invokes its praxis at the declared interval
- Test: daemon failure increases backoff interval
- Test: daemon backoff caps at backoff_max
- Test: daemon success resets backoff to interval
- Test: daemon failure doesn't affect other daemons
- Test: daemon status tracks as entity field (running, errored)
- Test: sensing daemon updates entity actuality field → reflex fires on drift
- Test: full reconciliation loop — daemon senses, entity updated, reflex detects drift, corrective praxis runs

### Step 4: Build (satisfy the tests)

1. **Add `start_daemons()` function** in `host.rs` or `bootstrap.rs`:
   - `gather(eidos: daemon)` all daemon entities
   - Validate praxis references exist
   - For each enabled daemon, spawn `tokio::interval` task
   - Invoke praxis via interpreter on each tick
   - Track backoff state per daemon
   - Update daemon entity status field
2. **Call `start_daemons()`** after bootstrap completes (after content loading, after validation)
3. **Wire daemon status updates** through `update_entity()` so reflex engine sees them

### Step 5: Verify

1. `cargo build && cargo test`
2. Manual verification:
   - Create a deployment with desired_state: running, actual_state: stopped
   - Wait for sensing daemon tick → verify actual_state field updated
   - Verify drift-detection reflex fires → corrective praxis runs → phasis emitted
   - Verify daemon status shows `running` in entity data
3. Re-read `docs/reference/daemon-runner.md` — confirm it matches implementation
4. Audit:
   ```bash
   # Daemon entities load
   KOSMOS_LOG=debug just dev 2>&1 | grep '\[daemon\]'
   # Should show: "Loaded N daemon entities, started N"

   # No custom reconciler engine
   ls crates/kosmos/src/reconciler_ergon.rs
   # Should not exist

   # Sensing praxeis exist
   rg 'sense-deployment-states\|sense-syndesmos-states\|sense-release-distribution\|sense-validation-results' genesis/ --glob '*.yaml'
   # Should show 4 praxeis

   # Drift reflexes exist
   rg 'deployment-drift\|syndesmos-drift\|release-drift\|validation-drift' genesis/ --glob '*.yaml'
   # Should show 4 trigger + 4 reflex entities
   ```
5. Update `docs/REGISTRY.md` impact map

---

## Chora Codebase Context

The chora repo is at `/Users/victorpiper/code/chora`. Key files:

- **`crates/kosmos/src/reflex.rs`** — Reflex engine (already shipped, bonded-only). Handles drift-detection reflexes.
- **`crates/kosmos/src/host.rs`** — HostContext. Where `start_daemons()` lives. Entity query methods, `update_entity()` for status tracking.
- **`crates/kosmos/src/bootstrap.rs`** — Bootstrap loading. `start_daemons()` is called after bootstrap completes.
- **`crates/kosmos/src/interpreter/steps.rs`** — `sense_actuality` stoicheion already implemented.
- **`crates/kosmos/src/reconciler.rs`** — Federation reconciler (1,500 lines). Leave as-is. Long-term it may converge to the same daemon + reflex pattern, but that's future work.

---

## Files to Touch

### Kosmos (genesis)
- `genesis/ergon/eide/ergon.yaml` — define `eidos/daemon`
- `genesis/dynamis/entities/daemons.yaml` (new) — sensing daemon
- `genesis/dynamis/praxeis/dynamis.yaml` — sensing praxis + corrective praxis
- `genesis/dynamis/entities/reflexes.yaml` — drift-detection reflex (or new file)
- Same pattern for `aither/`, `release/`, `dokimasia/`
- Reconciler entities stay unchanged

### Chora (implementation)
- `crates/kosmos/src/host.rs` or `bootstrap.rs` — `start_daemons()` function (~100-150 lines)
- `crates/kosmos/tests/daemon_runner.rs` (new) — daemon runner tests

### Docs (written FIRST, verified LAST)
- `docs/reference/daemon-runner.md` — daemon runner specification

### Retired
- `PROMPT-RECONCILER-ENGINE.md` — replaced by this prompt

---

## Verification

```bash
# Build
cargo build 2>&1

# Tests
cargo test 2>&1

# Daemon entities load
KOSMOS_LOG=debug just dev 2>&1 | grep '\[daemon\]'

# No custom reconciler engine exists
test ! -f crates/kosmos/src/reconciler_ergon.rs && echo "PASS: no custom engine"

# Full reconciliation loop: sense → update → reflex → correct → report
# Manual: create drifted deployment, wait for daemon tick, verify phasis emitted
```

---

## What This Enables

When the daemon runner ships:
- **Reconciliation is composition, not engine.** Daemon + reflex + praxis, all declared in genesis YAML. No custom Rust reconciler code.
- **Adding a reconciler is pure genesis.** Create a daemon, a sensing praxis, a drift-detection reflex, and a corrective praxis. Zero code changes.
- **The daemon runner is generic.** Useful for: scheduled cleanup, periodic re-indexing, health checks, cache expiry, metrics collection, session timeout enforcement. Any "do X every N seconds" need.
- **One reconciliation concept.** The federation reconciler (reconciler.rs) and the ergon reconcilers use the same conceptual pattern. Long-term, federation can converge to daemon + reflex + praxis too.
- **The reflex engine's value multiplies.** It's not just for notifications — it's the reactive core of reconciliation, state alignment, and any mutation-driven workflow.
- **~100-150 lines of Rust replace ~1,000+ lines.** The substrate stays thin; the graph carries the complexity.

---

## Post-Ship Notes

### Shipped Implementation Details

- **`crates/kosmos/src/daemon_loop.rs`** — ~250 lines (including unit tests and doc comments). Implements `DaemonLoop` struct with `start()/stop()/is_running()`, `DaemonState` per-daemon tracking, `discover_daemons()` loading, and `daemon_tick_once()` testing seam.
- **`reconciler_loop.rs` retired** — removed from lib.rs, host.rs, and deleted.
- **Thread-based, not tokio** — single background thread with per-daemon `next_run` tracking, 500ms sleep chunks for responsive shutdown, `Drop` calls `stop()`.
- **5 sensing daemons** (deployment, syndesmos, release, graph-integrity, voice-streams) + corresponding praxeis + drift reflexes in genesis.
- **Authorization bypass confirmed** — `invoke_praxis()` passes `None` dwelling → authorization gate allows all daemon praxis invocations.

### Outstanding Genesis Fix

**`genesis/ergon/manifest.yaml`** — `provides.eide` needs `daemon` added. Currently lists `[pragma, reflex, trigger, mutation-event, entity-mutation, bond-mutation]` but not `daemon`. Manifest validation would flag `eidos/daemon` as undeclared.

### Dokimasia Interaction

When dokimasia enforcement ships, daemon `update_entity()` calls (setting `status` to `running`/`stopped`/`errored`) will be validated against `eidos/daemon` field definitions. The enum values match the eidos declaration, so no breakage expected. However, this means **update-time validation** (not just arise-time) matters for daemon status tracking — see PROMPT-DOKIMASIA-ENFORCEMENT.md.
