# PROMPT-CARGO-AUTONOMIC-WIRING — Complete the autonomic loop for cargo compute modes

*Prompt for Claude Code in the chora + kosmos repository context.*

*After this work, cargo compute modes (build-target, test-run, lint-run) have intent-changed reflexes, drift-detection reflexes, and a standard sensing daemon — completing the autonomic loop. When a build-target's `desired_state` changes, reconciliation fires. When actual state drifts from intent (e.g., build target becomes stale from source changes), reconciliation corrects. The daemon periodically senses all build entities, closing the self-healing cycle.*

---

## Architectural Principle — The Autonomic Triple

Every entity with an actualization cycle needs three autonomic wiring elements:

```
  INTENT CHANGE                  DRIFT DETECTION                PERIODIC SENSE
  ┌───────────┐                  ┌───────────────┐              ┌──────────┐
  │ trigger:  │                  │ trigger:      │              │ daemon:  │
  │ intent != │──→ reflex ──→   │ intent !=     │──→ reflex    │ praxis:  │
  │ previous  │    reconcile    │ actual        │    reconcile │ sense-*  │
  └───────────┘                  └───────────────┘              └──────────┘
```

1. **Intent-changed reflex** — fires when a dweller changes what they want (desired_state changes)
2. **Drift reflex** — fires when sensed actuality diverges from intent (actual_state changes)
3. **Sensing daemon** — periodically invokes sense to discover drift, writing `_sensed` back to entities

The deployment pattern in `genesis/dynamis/reflexes/reflexes.yaml` is the proven reference implementation. It has all three elements. The cargo modes have reconcilers (transition tables) but lack the autonomic wiring that invokes them.

---

## Methodology — DDD + TDD

This work follows **Doc → Test → Build → Verify**, non-negotiably.

1. **Doc (prescriptive)**: This prompt IS the prescriptive doc.
2. **Test (assert the doc)**: Write tests that assert reflex entities exist with correct bonds and daemon entities have standard `praxis` field.
3. **Build (satisfy the tests)**: Create the genesis entities.
4. **Verify doc**: Check docs/REGISTRY.md impact map.

Pure genesis work + one daemon fix. No new Rust module code. The reconcilers already exist. The reflex engine already works. Only the wiring entities are missing.

---

## Current State

### What Exists and Works

| Component | Location | Status |
|-----------|----------|--------|
| Reconciler: build-target | `genesis/chora-dev/entities/ergon-integration.yaml` | Working — 5-state transition table |
| Reconciler: test-run | same file | Working — identical structure |
| Reconciler: lint-run | same file | Working — identical structure |
| Notification reflex: build-complete | `genesis/chora-dev/reflexes/reflexes.yaml` | Working — triggers `praxis/thyra/notify` |
| Notification reflex: test-failure | same file | Working — triggers `praxis/thyra/notify` |
| Staleness reflexes | same file | Working — file-change triggers `praxis/chora-dev/mark-stale` |
| Auto-indexing reflexes | same file | Working — entity-created triggers `praxis/nous/index-entity` |
| Deployment intent-changed reflex | `genesis/dynamis/reflexes/reflexes.yaml` | Proven pattern — `trigger → reflex → praxis/dynamis/reconcile` |
| Deployment drift reflex | same file | Proven pattern — same structure |
| Deployment sensing daemon | `genesis/dynamis/daemons/daemons.yaml` | Proven pattern — standard `praxis:` field, 30s interval |

### What's Missing — The Gaps

1. **No intent-changed reflexes for cargo eide.** When `build-target.desired_state` changes (e.g., from "absent" to "succeeded"), nothing fires. The reconciler exists but has no trigger. A dweller must manually invoke `praxis/dynamis/reconcile` — the loop is open.

2. **No drift-detection reflexes for cargo eide.** When `build-target.actual_state` diverges from `desired_state` (e.g., staleness detection sets `actual_state: stale` while `desired_state: succeeded`), nothing fires reconciliation. The staleness reflex marks entities as stale but doesn't invoke the reconciler to rebuild.

3. **Non-standard daemon definitions.** `daemon/chora-dev-watcher` uses `on_event.praxis` and `daemon/chora-dev-build-queue` uses `on_item.praxis`. The daemon loop (`daemon_loop.rs:176`) reads `data.praxis` — a top-level field. These daemons are silently skipped because they don't have a `praxis` field. Log says: `"missing praxis field, skipping"`.

4. **No sensing daemon for cargo entities.** No daemon periodically invokes sense on build-target/test-run/lint-run entities to detect external drift (e.g., build artifacts deleted, test results invalidated by dependency updates).

---

## Target State

### New Triggers (genesis/chora-dev/reflexes/reflexes.yaml)

```yaml
# INTENT-CHANGE TRIGGERS
- eidos: trigger
  id: trigger/chora-dev/build-intent-changed
  data:
    name: build-intent-changed
    condition: '$entity.data.desired_state != $previous.data.desired_state'
    enabled: true
  bonds:
    - { desmos: matches-event, to: entity-mutation/updated }
    - { desmos: filters-eidos, to: eidos/build-target }

- eidos: trigger
  id: trigger/chora-dev/test-intent-changed
  data:
    name: test-intent-changed
    condition: '$entity.data.desired_state != $previous.data.desired_state'
    enabled: true
  bonds:
    - { desmos: matches-event, to: entity-mutation/updated }
    - { desmos: filters-eidos, to: eidos/test-run }

- eidos: trigger
  id: trigger/chora-dev/lint-intent-changed
  data:
    name: lint-intent-changed
    condition: '$entity.data.desired_state != $previous.data.desired_state'
    enabled: true
  bonds:
    - { desmos: matches-event, to: entity-mutation/updated }
    - { desmos: filters-eidos, to: eidos/lint-run }

# DRIFT-DETECTION TRIGGERS
- eidos: trigger
  id: trigger/chora-dev/build-drift
  data:
    name: build-drift
    condition: '$entity.data.desired_state != $entity.data.actual_state'
    enabled: true
  bonds:
    - { desmos: matches-event, to: entity-mutation/updated }
    - { desmos: filters-eidos, to: eidos/build-target }

- eidos: trigger
  id: trigger/chora-dev/test-drift
  data:
    name: test-drift
    condition: '$entity.data.desired_state != $entity.data.actual_state'
    enabled: true
  bonds:
    - { desmos: matches-event, to: entity-mutation/updated }
    - { desmos: filters-eidos, to: eidos/test-run }

- eidos: trigger
  id: trigger/chora-dev/lint-drift
  data:
    name: lint-drift
    condition: '$entity.data.desired_state != $entity.data.actual_state'
    enabled: true
  bonds:
    - { desmos: matches-event, to: entity-mutation/updated }
    - { desmos: filters-eidos, to: eidos/lint-run }
```

### New Reflexes (genesis/chora-dev/reflexes/reflexes.yaml)

```yaml
# INTENT-CHANGE REFLEXES
- eidos: reflex
  id: reflex/chora-dev/build-intent-changed
  data:
    name: build-intent-changed
    description: |
      Trigger reconciliation when build target intent changes.
      When desired_state changes, the reconciler senses actuality and converges.
    enabled: true
    scope: global
    response_params:
      reconciler_id: "reconciler/build-target"
      entity_id: "$entity.id"
  bonds:
    - { desmos: triggered-by, to: trigger/chora-dev/build-intent-changed }
    - { desmos: responds-with, to: praxis/dynamis/reconcile }

- eidos: reflex
  id: reflex/chora-dev/test-intent-changed
  data:
    name: test-intent-changed
    description: |
      Trigger reconciliation when test run intent changes.
    enabled: true
    scope: global
    response_params:
      reconciler_id: "reconciler/test-run"
      entity_id: "$entity.id"
  bonds:
    - { desmos: triggered-by, to: trigger/chora-dev/test-intent-changed }
    - { desmos: responds-with, to: praxis/dynamis/reconcile }

- eidos: reflex
  id: reflex/chora-dev/lint-intent-changed
  data:
    name: lint-intent-changed
    description: |
      Trigger reconciliation when lint run intent changes.
    enabled: true
    scope: global
    response_params:
      reconciler_id: "reconciler/lint-run"
      entity_id: "$entity.id"
  bonds:
    - { desmos: triggered-by, to: trigger/chora-dev/lint-intent-changed }
    - { desmos: responds-with, to: praxis/dynamis/reconcile }

# DRIFT-DETECTION REFLEXES
- eidos: reflex
  id: reflex/chora-dev/build-drift
  data:
    name: build-drift
    description: |
      When a build target's sensed actuality diverges from intent,
      invoke reconciliation to correct. Fires on actual_state changes
      from external drift (e.g., build artifacts deleted, source changes
      marking build as stale).
    enabled: true
    scope: global
    response_params:
      reconciler_id: "reconciler/build-target"
      entity_id: "$entity.id"
  bonds:
    - { desmos: triggered-by, to: trigger/chora-dev/build-drift }
    - { desmos: responds-with, to: praxis/dynamis/reconcile }

- eidos: reflex
  id: reflex/chora-dev/test-drift
  data:
    name: test-drift
    description: |
      When a test run's sensed actuality diverges from intent,
      invoke reconciliation to correct.
    enabled: true
    scope: global
    response_params:
      reconciler_id: "reconciler/test-run"
      entity_id: "$entity.id"
  bonds:
    - { desmos: triggered-by, to: trigger/chora-dev/test-drift }
    - { desmos: responds-with, to: praxis/dynamis/reconcile }

- eidos: reflex
  id: reflex/chora-dev/lint-drift
  data:
    name: lint-drift
    description: |
      When a lint run's sensed actuality diverges from intent,
      invoke reconciliation to correct.
    enabled: true
    scope: global
    response_params:
      reconciler_id: "reconciler/lint-run"
      entity_id: "$entity.id"
  bonds:
    - { desmos: triggered-by, to: trigger/chora-dev/lint-drift }
    - { desmos: responds-with, to: praxis/dynamis/reconcile }
```

### Standard Sensing Daemon (genesis/chora-dev/daemons/)

```yaml
entities:

  - eidos: daemon
    id: daemon/sense-cargo-builds
    data:
      name: sense-cargo-builds
      description: |
        Periodically sense cargo build/test/lint entity actuality.
        Gathers all build-target, test-run, and lint-run entities
        and invokes sense on each. Entity updates trigger drift-detection
        reflexes via the autonomic triple.
      praxis: chora-dev/sense-build-states
      interval: 60
      enabled: true
      scope: dwelling
      backoff_max: 300
```

### Non-Standard Daemons Fixed (genesis/chora-dev/entities/ergon-integration.yaml)

The `daemon/chora-dev-watcher` and `daemon/chora-dev-build-queue` entities use non-standard `on_event` and `on_item` structures. Two options:

**Option A (Preferred): Remove non-standard daemons.** The file-watcher pattern (`on_event`) and queue-processor pattern (`on_item`) are not implemented in `daemon_loop.rs`. These daemons are aspirational — they describe desired behavior but the runtime ignores them. Remove them to eliminate dead entities (per dead code policy). The staleness detection they intend is already handled by the staleness reflexes (`trigger/chora-dev/detect-staleness` fires on file mutations). The build queue they intend is handled by direct praxis invocation.

**Option B: Keep but mark disabled.** If the intent is to implement these daemon types later, mark them `enabled: false` with a comment explaining they require runtime support not yet built.

---

## Sequenced Work

### Phase 1: Add Intent-Changed Triggers and Reflexes

**Goal:** When `desired_state` changes on build-target, test-run, or lint-run entities, reconciliation fires automatically.

**Tests:**
- `test_cargo_intent_reflexes_exist` — gather reflex entities, assert `reflex/chora-dev/build-intent-changed`, `test-intent-changed`, `lint-intent-changed` exist
- `test_cargo_intent_reflex_bonds` — for each reflex, assert `triggered-by` bond to correct trigger, `responds-with` bond to `praxis/dynamis/reconcile`
- `test_cargo_intent_triggers_filter_correct_eidos` — for each trigger, assert `filters-eidos` bond to correct eidos

**Implementation:**
1. Add 3 intent-changed triggers to `genesis/chora-dev/reflexes/reflexes.yaml`
2. Add 3 intent-changed reflexes to same file
3. Verify bootstrap loads them correctly

**Phase 1 Complete When:**
- [ ] 3 triggers + 3 reflexes exist with correct bonds
- [ ] All existing tests pass
- [ ] Bootstrap succeeds with new entities

### Phase 2: Add Drift-Detection Triggers and Reflexes

**Goal:** When `actual_state` diverges from `desired_state` (from sensing or staleness marking), reconciliation fires.

**Tests:**
- `test_cargo_drift_reflexes_exist` — gather reflex entities, assert `reflex/chora-dev/build-drift`, `test-drift`, `lint-drift` exist
- `test_cargo_drift_reflex_responds_with_reconcile` — each drift reflex responds-with `praxis/dynamis/reconcile` with correct reconciler_id

**Implementation:**
1. Add 3 drift-detection triggers to `genesis/chora-dev/reflexes/reflexes.yaml`
2. Add 3 drift-detection reflexes to same file

**Phase 2 Complete When:**
- [ ] 3 drift triggers + 3 drift reflexes exist with correct bonds
- [ ] All existing tests pass

### Phase 3: Add Standard Sensing Daemon

**Goal:** Periodic sensing of cargo entities discovers external drift, writing actuality back to entities which triggers drift reflexes.

**Tests:**
- `test_cargo_sensing_daemon_exists` — gather daemon entities, assert `daemon/sense-cargo-builds` exists with standard `praxis:` field
- `test_cargo_sensing_daemon_discoverable` — `discover_daemons()` finds `daemon/sense-cargo-builds` (has `praxis` field, not `on_event`)

**Implementation:**
1. Create `genesis/chora-dev/daemons/daemons.yaml` with `daemon/sense-cargo-builds`
2. Ensure the referenced praxis `chora-dev/sense-build-states` exists (or create a stub praxis entity)

**Phase 3 Complete When:**
- [ ] Standard daemon entity exists with `praxis:` field
- [ ] `daemon_loop.rs` discovery finds it (not skipped)
- [ ] Referenced praxis exists

### Phase 4: Clean Non-Standard Daemons

**Goal:** Remove or disable aspirational daemon entities that the runtime cannot execute.

**Tests:**
- `test_no_nonstandard_daemon_fields` — gather all daemon entities, assert none use `on_event` or `on_item` (unless disabled)

**Implementation:**
1. Remove `daemon/chora-dev-watcher` and `daemon/chora-dev-build-queue` from `genesis/chora-dev/entities/ergon-integration.yaml` (Option A), OR mark `enabled: false` (Option B)
2. Verify no runtime errors from daemon discovery

**Phase 4 Complete When:**
- [ ] No enabled daemons with non-standard fields exist
- [ ] All existing tests pass
- [ ] No daemon discovery warnings for chora-dev daemons

---

## Files to Read

### Genesis (proven patterns)
- `genesis/dynamis/reflexes/reflexes.yaml` — deployment intent-changed + drift reflexes (the pattern to copy)
- `genesis/dynamis/daemons/daemons.yaml` — deployment sensing daemon (standard format)
- `genesis/release/reflexes/reflexes.yaml` — release drift reflex (another pattern reference)
- `genesis/release/daemons/daemons.yaml` — release sensing daemon (standard format)

### Genesis (current cargo state)
- `genesis/chora-dev/reflexes/reflexes.yaml` — existing notification + staleness reflexes
- `genesis/chora-dev/entities/ergon-integration.yaml` — reconcilers + non-standard daemons

### Implementation
- `crates/kosmos/src/daemon_loop.rs` — `discover_daemons()` reads `data.praxis`, lines 176-182
- `crates/kosmos/src/host.rs` — `reconcile()` dispatches based on reconciler transition tables

---

## Files to Touch

| File | Change |
|------|--------|
| `genesis/chora-dev/reflexes/reflexes.yaml` | **MODIFY** — add 6 triggers + 6 reflexes (intent-changed + drift for 3 eide) |
| `genesis/chora-dev/daemons/daemons.yaml` | **NEW** — standard sensing daemon for cargo entities |
| `genesis/chora-dev/entities/ergon-integration.yaml` | **MODIFY** — remove or disable non-standard daemon entities |
| `genesis/chora-dev/praxeis/` | **MODIFY** or **NEW** — ensure `chora-dev/sense-build-states` praxis exists |
| `crates/kosmos/tests/` | **MODIFY** — add tests for autonomic wiring entities |

---

## Success Criteria

**Phase 1:**
- [ ] 3 intent-changed triggers + 3 reflexes with correct bonds

**Phase 2:**
- [ ] 3 drift triggers + 3 reflexes with correct bonds

**Phase 3:**
- [ ] Standard sensing daemon discoverable by `daemon_loop.rs`

**Phase 4:**
- [ ] No enabled daemons with non-standard `on_event`/`on_item` patterns

**Overall Complete When:**
- [ ] All existing tests still pass
- [ ] 12 new genesis entities (6 triggers + 6 reflexes)
- [ ] 1 new daemon entity with standard `praxis:` field
- [ ] Non-standard daemons removed or disabled
- [ ] Sense prompt `PROMPT-SENSE-COMPUTE-CARGO.md` can be re-run to confirm stage 6

---

## What This Enables

1. **Self-healing builds** — when source files change and staleness is detected (`actual_state: stale`), the drift reflex fires reconciliation, which dispatches `manifest` (rebuild). The build target self-corrects without manual intervention.
2. **Intent-driven development** — a dweller sets `desired_state: succeeded` on a build-target. The intent-changed reflex fires, the reconciler senses actuality, and if not already built, dispatches manifest. The build happens because intent was declared.
3. **Daemon-sensed drift** — even without file-change events, the periodic daemon senses build freshness. If a build artifact is deleted externally, the daemon detects the drift, the reflex fires, and reconciliation rebuilds. The system converges toward intent.
4. **Cargo modes reach stage 6** — completing the autonomic triple closes the last gap identified by PROMPT-SENSE-COMPUTE-CARGO.md.

---

## What Does NOT Change

- **Reconciler definitions** (`ergon-integration.yaml` reconcilers) — already correct, transition tables don't change
- **Existing notification reflexes** — build-complete and test-failure notifications remain
- **Existing staleness reflexes** — file-change detection continues to mark targets stale
- **Cargo stoicheion implementations** — no changes to cargo-build, cargo-test, cargo-clippy module code
- **Mode dispatch entries** — already generated correctly by build.rs
- **daemon_loop.rs** — no Rust changes; it already reads `data.praxis` correctly

---

*Traces to: PROMPT-SENSE-COMPUTE-CARGO.md (gap identification), actualization-pattern.md Section 2 (the autonomic triple), genesis/dynamis/reflexes/reflexes.yaml (proven deployment pattern)*
