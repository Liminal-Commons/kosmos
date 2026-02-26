# Cargo Autonomic Loop — Lifecycle as Data, Not Code

*Prompt for Claude Code in the chora + kosmos repository context.*

*Wires cargo substrates (build, test, clippy) into the generic reconciliation engine. After this work, cargo entities have intent fields, return `_entity_update` through the standard dispatch path, and are governed by transition-table reconcilers that `host.reconcile()` interprets. Cargo modes advance from stage 5 to stage 6 (fully autonomic).*

*Depends on: PROMPT-SUBSTRATE-STANDARD.md, PROMPT-SUBSTRATE-DNS.md, PROMPT-HOST-DECOMPOSITION.md, PROMPT-ONTOLOGICAL-COHERING.md*

---

## Architectural Principle — Autonomic Means Self-Healing

An autonomic system senses its own state, compares it to intent, and acts. No orchestrator decides. No daemon custom-codes the logic. The reconciler reads a transition table from an entity and dispatches: manifest, sense, unmanifest, or none.

```
intent: "succeeded"  +  actual: "stale"     → action: manifest
intent: "succeeded"  +  actual: "failed"    → action: manifest
intent: "succeeded"  +  actual: "manifested" → action: none
```

This is what `host.reconcile()` already does — pure data interpretation. It works for deployment. It works for release-artifact. It should work for cargo builds.

**An entity becomes autonomic when its lifecycle is expressed as data, not as code.** Transition tables are data. Inline entity updates in host.rs are code. Moving from code to data is the completion of the autonomic loop.

**One convention for entity updates.** Every substrate module that modifies entity state should do so through `_entity_update` in its return value, applied by `dispatch_to_module()`. Process does this. DNS does this. Storage does this. Cargo does NOT — it updates entities inline. This prompt fixes that.

---

## Methodology — DDD + TDD

This work follows **Doc → Test → Build → Verify**, non-negotiably.

1. **Doc (prescriptive)**: This prompt IS the prescriptive doc. The target state described here is what code must match.
2. **Test (assert the doc)**: Write tests that assert reconciler transition lookup, `_entity_update` return convention, and dispatch_to_module wiring. Tests should fail before implementation.
3. **Build (satisfy the tests)**: Implement until tests pass.
4. **Verify doc**: After implementation, update success criteria to reflect completion. Check docs/REGISTRY.md impact map.

---

## Current State

### What Exists and Works

| Component | Location | Status |
|-----------|----------|--------|
| Cargo stoicheion dispatch | `host.rs:1385` (manifest), `:1571` (sense) | Working — but updates entities inline, not via `_entity_update` |
| Command template execution | `command_template.rs` | Working — `execute_template()` and `sense_artifact()` |
| `execute_command_template()` | `host.rs:1770` | Working — but calls `update_entity()` inline (bypasses convention) |
| `sense_build_artifact()` | `host.rs:1824` | Working — but calls `update_entity()` inline |
| `sense_run_status()` | `host.rs:1854` | Working — returns data but no `_entity_update` |
| `dispatch_to_module()` + `apply_entity_update()` | `host.rs:1342`, `:1326` | Working — used by DNS, process, storage |
| `host.reconcile()` | `host.rs:1883` | Working — reads intent/actuality/transitions generically |
| Cargo mode dispatch | `mode_dispatch.rs` | Working — cargo-build/test/clippy entries generated |
| `reconciler/chora-dev-builds` | `genesis/chora-dev/entities/ergon-integration.yaml` | **Wrong format** — daemon-style (praxis + interval), NOT transition-table |
| build-target eidos | `genesis/chora-dev/eide/chora-dev.yaml` | Defined — has `actual_state` but **no `desired_state`** (no intent) |

### What's Missing — The Three Gaps

**Gap 1: No intent field.** build-target has `build_status` (what happened) and `actual_state` (what was sensed) but no `desired_state` (what should happen). Without intent, `host.reconcile()` has nothing to compare against. Same gap for test-run and lint-run.

**Gap 2: Inline entity updates bypass the convention.** `execute_command_template()` calls `self.update_entity()` directly (line 1804). `sense_build_artifact()` does the same (line 1840). Both bypass `dispatch_to_module()` → `apply_entity_update()`, which is the standard path every other substrate uses.

**Gap 3: Wrong reconciler format.** `reconciler/chora-dev-builds` uses `praxis` + `interval` (daemon-style). `host.reconcile()` requires `intent_field` + `actuality_field` + `transitions` (transition-table style). The reconciler entity is incompatible with the engine.

---

## Target State

### Cargo dispatch follows the standard convention

```rust
// manifest_by_stoicheion:
"cargo-build-run" | "cargo-test-run" | "cargo-clippy-run" | "cargo-clean" =>
    self.dispatch_to_module(entity_id, data,
        self.execute_command_template(entity_id, stoicheion, data)),

// sense_by_stoicheion:
"cargo-build-sense" => self.dispatch_to_module(entity_id, data,
    self.sense_build_artifact(entity_id, stoicheion, data)),
"cargo-test-sense" | "cargo-clippy-sense" => self.dispatch_to_module(entity_id, data,
    self.sense_run_status(entity_id, stoicheion, data)),
```

### execute_command_template returns _entity_update

```rust
fn execute_command_template(&self, entity_id, stoicheion, data) -> Result<Value> {
    // ... runs template, gets result ...
    // NO self.update_entity() call
    Ok(json!({
        "status": if result.success { "manifested" } else { "failed" },
        "entity_id": entity_id,
        "stoicheion": stoicheion,
        "success": result.success,
        "_entity_update": {
            "actual_state": if result.success { "manifested" } else { "failed" },
            "duration_ms": result.duration_ms,
            "content_hash": result.content_hash,
            "artifact_path": result.artifact_path,
        }
    }))
}
```

### build-target eidos has intent

```yaml
desired_state:
  type: enum
  values: [succeeded, absent]
  default: "succeeded"
  required: true
  description: "Intent — what state this build-target should be in"
```

### Transition-table reconciler

```yaml
- eidos: reconciler
  id: reconciler/build-target
  data:
    target_eidos: build-target
    intent_field: desired_state
    actuality_field: actual_state
    transitions:
      - intent: succeeded
        actual: [absent, stale, pending]
        action: manifest
      - intent: succeeded
        actual: failed
        action: manifest
      - intent: succeeded
        actual: manifested
        action: sense
      - intent: absent
        actual: [manifested, stale, failed]
        action: unmanifest
      - intent: absent
        actual: absent
        action: none
```

---

## Sequenced Work

### Phase 1: Intent Fields + Reconcilers (Genesis)

**Goal:** Cargo entities have intent, reconcilers have transition tables.

**Tests:**
- `test_build_target_reconcile_absent_to_manifest` — create entity with desired_state=succeeded, actual_state=absent, reconcile, verify action_taken=="manifest"
- `test_build_target_reconcile_manifested_to_sense` — desired_state=succeeded, actual_state=manifested → action_taken=="sense"
- `test_build_target_reconcile_stale_to_manifest` — desired_state=succeeded, actual_state=stale → action_taken=="manifest"
- `test_build_target_reconcile_absent_to_none` — desired_state=absent, actual_state=absent → action_taken=="none"

**Implementation:**

1. Add `desired_state` field to build-target, test-run, lint-run eide in `genesis/chora-dev/eide/chora-dev.yaml`
2. Replace `reconciler/chora-dev-builds` (daemon-style) with `reconciler/build-target`, `reconciler/test-run`, `reconciler/lint-run` (transition-table) in `genesis/chora-dev/entities/ergon-integration.yaml`
3. Unify `build_status` into `actual_state` — `actual_state` becomes the authoritative field, `build_status` can be retired
4. Keep daemon entities (watcher, build-queue) — they serve a different purpose

**Phase 1 Complete When:**
- [ ] build-target, test-run, lint-run eide have `desired_state` field
- [ ] Transition-table reconcilers exist for all three
- [ ] Old daemon-style reconciler/chora-dev-builds removed
- [ ] `host.reconcile("reconciler/build-target", entity_id)` returns correct action

### Phase 2: Standard Dispatch Convention (Rust)

**Goal:** Cargo stoicheion handlers return `_entity_update` and dispatch through `dispatch_to_module()`.

**Tests:**
- `test_cargo_manifest_returns_entity_update` — call `execute_command_template`, verify result contains `_entity_update` key
- `test_cargo_sense_returns_entity_update` — call `sense_build_artifact`, verify result contains `_entity_update` key with `actual_state` and `last_sensed_at`
- `test_cargo_dispatch_through_module` — call through `dispatch_to_module`, verify entity was updated (not via inline call)

**Implementation:**

1. Refactor `execute_command_template` — remove `self.update_entity()` call, add `_entity_update` to return value
2. Refactor `sense_build_artifact` — same pattern
3. Refactor `sense_run_status` — same pattern
4. Wire cargo stoicheion arms through `dispatch_to_module` in `manifest_by_stoicheion` and `sense_by_stoicheion`

**Phase 2 Complete When:**
- [ ] `execute_command_template` returns `_entity_update` instead of calling `update_entity` inline
- [ ] `sense_build_artifact` returns `_entity_update` instead of calling `update_entity` inline
- [ ] `sense_run_status` returns `_entity_update`
- [ ] Cargo stoicheion dispatch uses `dispatch_to_module()` in both manifest and sense

### Phase 3: Verify

**Goal:** Everything works together.

```bash
cargo build -p kosmos 2>&1
cargo test -p kosmos --lib --tests 2>&1
cargo test -p kosmos --test cargo_reconcile 2>&1
cargo test -p kosmos --test reconciler_generic 2>&1  # regression
```

**Phase 3 Complete When:**
- [ ] All existing tests pass
- [ ] 7 new tests pass
- [ ] `host.reconcile("reconciler/build-target", entity_id)` works end-to-end

---

## Files to Read

### Dispatch convention (the pattern to follow)
- `crates/kosmos/src/host.rs` — `dispatch_to_module` (line 1342), `apply_entity_update` (line 1326)
- `crates/kosmos/src/process.rs` — `_entity_update` convention examples

### Cargo dispatch (what to change)
- `crates/kosmos/src/host.rs` — `execute_command_template` (line 1770), `sense_build_artifact` (line 1824), `sense_run_status` (line 1854)
- `crates/kosmos/src/command_template.rs` — template execution, `sense_artifact`

### Genesis (what to update)
- `genesis/chora-dev/eide/chora-dev.yaml` — build-target, test-run, lint-run eide
- `genesis/chora-dev/entities/ergon-integration.yaml` — current reconciler (wrong format)
- `genesis/dynamis/reconcilers/dynamis.yaml` — correct transition-table format (reference)

---

## Files to Touch

| File | Change |
|------|--------|
| `genesis/chora-dev/eide/chora-dev.yaml` | **MODIFY** — add `desired_state` to build-target, test-run, lint-run |
| `genesis/chora-dev/entities/ergon-integration.yaml` | **MODIFY** — replace daemon-style reconciler with 3 transition-table reconcilers |
| `crates/kosmos/src/host.rs` | **MODIFY** — wire cargo through `dispatch_to_module`, remove inline `update_entity` calls |
| `crates/kosmos/tests/cargo_reconcile.rs` | **NEW** — 7 tests |

---

## Success Criteria

**Phase 1 Complete When:**
- [ ] `desired_state` field on build-target, test-run, lint-run
- [ ] 3 transition-table reconcilers (build-target, test-run, lint-run)
- [ ] Reconcile dispatches correct action for all intent/actual combinations

**Phase 2 Complete When:**
- [ ] `_entity_update` in all cargo operation return values
- [ ] `dispatch_to_module` wiring for all cargo stoicheion arms

**Overall Complete When:**
- [ ] All existing tests pass
- [ ] 7 new tests pass in `cargo_reconcile.rs`
- [ ] Cargo modes at stage 6 (fully autonomic)

---

## What This Enables

1. **Cargo modes advance to stage 6** — reconciler compares intent vs actuality, dispatches correct action
2. **Background reconciliation** — daemon periodically calls `host.reconcile` for each build-target, pure data-driven
3. **Self-healing builds** — stale build detected → automatically rebuilt
4. **Uniform dispatch convention** — every substrate (process, DNS, storage, cargo) follows `_entity_update`
5. **CI integration foundation** — reconcilers triggered by external events (webhooks → reflex → reconcile)

---

## What Does NOT Change

1. **command_template.rs** — template execution and sense_artifact stay, only the entity update path changes
2. **mode_dispatch.rs** — generated table already correct
3. **Daemon entities** — daemon/chora-dev-watcher and daemon/chora-dev-build-queue stay
4. **Reflex definitions** — existing reflexes stay, they trigger the reconciler
5. **Other substrates** — DNS, storage, process untouched

---

*Traces to: the autonomic principle (sense→compare→act as data, not code), the dispatch convention (_entity_update as universal contract), PROMPT-REACTIVE-LOOP.md (reconciler engine), PROMPT-SUBSTRATE-STANDARD.md (substrate contract)*
