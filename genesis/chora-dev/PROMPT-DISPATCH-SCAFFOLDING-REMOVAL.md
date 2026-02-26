# PROMPT: Dispatch Scaffolding Removal — One Path Through the Host

**Removes the three-way dispatch scaffolding (rust/wasm/compare) from bootstrap.rs and AriseStep in steps.rs. All entity creation and bond creation during bootstrap goes through `ctx.arise_entity()` and `ctx.create_bond()` — the host methods that perform validation and notification. The WASM engine/module statics in bootstrap.rs are deleted. AriseStep collapses to a single call through the host. V9 equivalence tests for arise and bind are removed — equivalence was proven, scaffolding comes down.**

**Depends on**: Phase 0 doc prescriptions (bootstrap-genesis.md, bootstrap.md, composition.md, validation-enforcement.md, attainment-authorization.md, CONTRIBUTING.md, CLAUDE.md T12 — all already updated to prescribe the target state)
**Prior art**: V9 migration proved WASM equivalence via compare mode. The scaffolding served its purpose.
**Enables**: Phase 2 (compose_entity as the one path), Phase 3 (contextual gate), Phase 4 (bootstrap under constitution)

---

## Architectural Principle

**One path through the host. No dispatch scaffolding.**

During the V9 migration, entity creation and bond creation were wrapped in dispatch functions that read environment variables (`KOSMOS_STOICHEION_ARISE`, `KOSMOS_STOICHEION_BIND`) to select between three execution paths:

- `"rust"` — V8 legacy, calls `ctx.arise_entity()` directly
- `"wasm"` — V9 default, instantiates WASM module, calls `DynamisInstance::call_arise()`
- `"compare"` — runs both, asserts equivalence

WASM won. The comparison proved equivalence. The scaffolding is dead code — contextual poison per our policy. This prompt removes it.

After this work, bootstrap.rs calls `ctx.arise_entity()` and `ctx.create_bond()` directly. These host methods perform dokimasia validation (skipped during bootstrap via `is_bootstrapping()`) and change notification (dormant during bootstrap since reflexes are dormant). AriseStep in steps.rs also collapses to `ctx.arise_entity()`.

```
INVARIANT:  Entity creation goes through ctx.arise_entity() — validation + notification
INVARIANT:  Bond creation goes through ctx.create_bond() — validation + notification
REMOVES:    arise_with_mode(), bind_with_mode(), WASM statics in bootstrap.rs
REMOVES:    AriseStep three-way dispatch in steps.rs
PRESERVES:  WASM engine/modules in steps.rs for OTHER step types (find, gather, trace, etc.)
```

---

## Methodology — DDD + TDD

This work follows **Doc → Test → Build → Verify**, non-negotiably.

1. **Doc (prescriptive)**: Phase 0 already completed. The docs prescribe one path through composition. This prompt aligns the code.
2. **Test (assert the doc)**: Existing tests must still pass. Dispatch-specific tests are removed.
3. **Build (satisfy the tests)**: Mechanical replacement — dispatch functions → host methods.
4. **Verify doc**: After implementation, check docs/REGISTRY.md impact map. No doc changes expected — Phase 0 already prescribed the target.

**Pure code cleanup — no genesis changes, no doc changes.**

---

## Current State

### What Exists — The Scaffolding

**bootstrap.rs** — lines 26-184:

| Lines | What | Purpose |
|-------|------|---------|
| 27-30 | `TIER2_DB_ARISE_WAT`, `TIER2_DB_BIND_WAT` | WASM module source (include_str!) |
| 33-56 | `get_wasm_engine()`, `get_tier2_db_arise_module()`, `get_tier2_db_bind_module()` | Lazy-initialized WASM statics |
| 60-62 | `arise_with_mode()` | Delegates to `arise_with_mode_versioned()` |
| 68-119 | `arise_with_mode_versioned()` | Three-way dispatch on `KOSMOS_STOICHEION_ARISE` |
| 123-184 | `bind_with_mode()` | Three-way dispatch on `KOSMOS_STOICHEION_BIND` |

**steps.rs** — AriseStep impl (lines 1495-1564):

| Lines | What | Purpose |
|-------|------|---------|
| 1499-1512 | `execute_rust()` | Calls `ctx.arise_entity()` |
| 1514-1530 | `execute_wasm()` | Instantiates WASM, calls `DynamisInstance::call_arise()` |
| 1532-1563 | `execute()` | Three-way dispatch on `KOSMOS_STOICHEION_ARISE` |

**v9_equivalence.rs** — arise/bind dispatch tests:

| Lines | Test | Tests What |
|-------|------|-----------|
| 289-335 | `test_arise_equivalence_create_entity` | Rust vs WASM produce identical entity |
| 337-383 | `test_arise_step_wasm_mode` | AriseStep with env=wasm |
| 385-417 | `test_arise_step_compare_mode` | AriseStep with env=compare |
| 424-471 | `test_bind_equivalence_create_bond` | Rust vs WASM produce identical bond |
| 473-517 | `test_bind_equivalence_with_data` | Rust vs WASM bond with data payload |
| 519-563 | `test_bind_step_wasm_mode` | BindStep with env=wasm |
| 568-606 | `test_bind_step_compare_mode` | BindStep with env=compare |

### Call Sites in bootstrap.rs

~36 call sites of `arise_with_mode()` and `bind_with_mode()` across these functions:

| Function | arise calls | bind calls | Purpose |
|----------|-------------|------------|---------|
| `germinate_with_authorization()` | 1 | 0 | Create genesis root phasis |
| `load_single_stream_entity_file()` | 1 | 0 | Load emitted entities |
| `load_single_stream_bond_file()` | 0 | 1 | Load emitted bonds |
| `load_manifest_entity_file()` | 1 | 0 | Load manifest entities |
| `load_bond_file()` | 0 | 1 | Load bond files |
| `execute_entity_step()` | 1 | 3 | Create entity + authorized-by + typed-by + extra bonds |
| `execute_bond_step()` | 0 | 1 | Create standalone bond |
| `load_content_roots()` | 1 | 2 | Create content-root + bonds |
| `load_source_file()` | 1 | 2+ | Create entity + authorized-by + source bonds |
| `load_topos_manifest()` | 5 | 13 | Create topos + manifest + surfaces + content-roots + bonds |

---

## Target State

### bootstrap.rs

No `arise_with_mode`, `bind_with_mode`, or WASM statics. Every entity creation calls `ctx.arise_entity()` or `ctx.arise_entity_with_version()`. Every bond creation calls `ctx.create_bond()`.

### steps.rs — AriseStep

```rust
impl AriseStep {
    pub fn execute(&self, ctx: &HostContext, scope: &mut Scope) -> Result<StepResult> {
        let id_val = eval_string(&self.id, scope)?;
        let eidos_val = eval_string(&self.eidos, scope)?;
        let data_val = self
            .data
            .as_ref()
            .map(|d| evaluate_value(d, scope))
            .transpose()?
            .unwrap_or(Value::Object(Default::default()));

        let result = ctx.arise_entity(&eidos_val, &id_val, data_val)?;

        if let Some(ref var) = self.bind_to {
            scope.set(var.clone(), result);
        }
        Ok(StepResult::Continue)
    }
}
```

No `execute_rust()`, no `execute_wasm()`, no env var dispatch.

### v9_equivalence.rs

Arise and bind equivalence/dispatch tests removed. File retains tests for other step types (find, gather, trace, update, delete, loose). Unused imports cleaned up.

---

## Implementation Order

### Step 1: Delete WASM statics from bootstrap.rs

Delete lines 26-56:
- `TIER2_DB_ARISE_WAT` constant
- `TIER2_DB_BIND_WAT` constant
- `get_wasm_engine()`
- `get_tier2_db_arise_module()`
- `get_tier2_db_bind_module()`

Delete the now-unused imports:
- `use wasmtime::{Config, Engine, Module};`
- `use std::sync::OnceLock;`
- `use crate::interpreter::DynamisInstance;` (verify not used elsewhere in bootstrap.rs)

### Step 2: Delete dispatch functions from bootstrap.rs

Delete lines 58-184:
- `arise_with_mode()` (lines 60-62)
- `arise_with_mode_versioned()` (lines 68-119)
- `bind_with_mode()` (lines 123-184)

### Step 3: Replace all call sites in bootstrap.rs

Mechanical transformation (work top-down since line numbers shift after deletions):

```
arise_with_mode(ctx, eidos, id, data)
→  ctx.arise_entity(eidos, id, data)

arise_with_mode_versioned(ctx, eidos, id, data, Some(version))
→  ctx.arise_entity_with_version(eidos, id, data, Some(version))

arise_with_mode_versioned(ctx, eidos, id, data, None)
→  ctx.arise_entity(eidos, id, data)

bind_with_mode(ctx, from, desmos, to, data)
→  ctx.create_bond(from, desmos, to, data)
```

**Return value handling**: Both old and new functions return `Result<Value>`. Most call sites use `?` and discard the value. Verify each site — a few may use the returned entity/bond value.

**Remove stale comments**: Delete all `// V9.5: Use arise_with_mode for feature-flagged execution` and similar V9 scaffolding comments.

### Step 4: Collapse AriseStep in steps.rs

Replace the AriseStep impl block (lines 1498-1564) with the target state shown above. Delete `execute_rust()` and `execute_wasm()` methods. The single `execute()` method calls `ctx.arise_entity()`.

### Step 5: Remove arise/bind tests from v9_equivalence.rs

Delete these 7 tests:
- `test_arise_equivalence_create_entity`
- `test_arise_step_wasm_mode`
- `test_arise_step_compare_mode`
- `test_bind_equivalence_create_bond`
- `test_bind_equivalence_with_data`
- `test_bind_step_wasm_mode`
- `test_bind_step_compare_mode`

Clean up imports that become unused: `AriseStep`, `BindStep`, `TIER2_DB_ARISE_WAT`, `TIER2_DB_BIND_WAT` (verify each — some may still be used by remaining tests).

### Step 6: Build and test

```bash
cargo build -p kosmos        # Must compile cleanly
cargo test -p kosmos --test v9_equivalence    # Remaining tests pass
cargo test -p kosmos -- --test-threads=1      # Full suite passes
```

---

## Files to Read

| File | Why |
|------|-----|
| `crates/kosmos/src/bootstrap.rs` | Primary target — dispatch functions and all call sites |
| `crates/kosmos/src/interpreter/steps.rs` | AriseStep three-way dispatch |
| `crates/kosmos/src/host.rs` | Verify `arise_entity()` and `create_bond()` signatures |
| `crates/kosmos/tests/v9_equivalence.rs` | Identify tests to remove |

## Files to Touch

| File | Action |
|------|--------|
| `crates/kosmos/src/bootstrap.rs` | **MODIFY** — delete dispatch functions + WASM statics, replace ~36 call sites |
| `crates/kosmos/src/interpreter/steps.rs` | **MODIFY** — collapse AriseStep impl to single host method call |
| `crates/kosmos/tests/v9_equivalence.rs` | **MODIFY** — remove 7 arise/bind dispatch tests, clean up imports |

---

## Success Criteria

- [ ] `arise_with_mode` does not appear anywhere in the codebase
- [ ] `bind_with_mode` does not appear anywhere in the codebase
- [ ] `KOSMOS_STOICHEION_ARISE` does not appear in bootstrap.rs or steps.rs
- [ ] `KOSMOS_STOICHEION_BIND` does not appear in bootstrap.rs
- [ ] No `wasmtime` imports in bootstrap.rs
- [ ] No `DynamisInstance` usage in bootstrap.rs
- [ ] AriseStep has a single `execute()` method — no `execute_rust()`, no `execute_wasm()`
- [ ] `cargo build -p kosmos` compiles with zero warnings related to these changes
- [ ] `cargo test -p kosmos --test v9_equivalence` passes (remaining tests)
- [ ] `cargo test -p kosmos -- --test-threads=1` passes (full suite, zero regressions)
- [ ] No `V9.5` or `V9.6` scaffolding comments remain in bootstrap.rs

---

## What Does NOT Change

1. **`ctx.arise_entity()` and `ctx.create_bond()` signatures in host.rs** — unchanged. Phase 3 adds the contextual gate.
2. **`compose_entity()` in steps.rs** — unchanged. Phase 2 makes it the one path.
3. **AriseStep struct in step_types.rs** — unchanged. AriseStep still exists as a step type, just without dispatch.
4. **Dispatch scaffolding in OTHER step types** (FindStep, GatherStep, TraceStep, BindStep, LooseStep, UpdateStep, DeleteStep, IndexStep, SurfaceStep) — unchanged. Same pattern exists, separate cleanup.
5. **WASM engine/module statics in steps.rs** — unchanged. Other step types use them.
6. **`_genesis` metadata stamping in bootstrap.rs** — unchanged. Phase 4 addresses this.
7. **Bootstrap validation skip** (`is_bootstrapping()` check in host.rs) — unchanged. Phases 3-4 address this.
8. **Genesis files** — no genesis changes.
9. **Docs** — no doc changes. Phase 0 already prescribed the target.

---

## Findings That Are Out of Scope

1. **Other step types' dispatch scaffolding** — FindStep, GatherStep, TraceStep, BindStep (interpreter), LooseStep, UpdateStep, DeleteStep, IndexStep, SurfaceStep all have the same three-way env var dispatch. Same pattern, separate cleanup. The `v9_equivalence.rs` tests for those step types remain.

2. **Contextual gate** — `ctx.arise_entity(eidos, id, data)` still takes no prosopon, oikos, session, or attainment. Phase 3 adds these parameters.

3. **`compose_entity` as the one path** — AriseStep still calls `ctx.arise_entity()` directly, bypassing composition. Phase 2 routes all callers through composition.

4. **`_genesis` metadata** — Bootstrap still stamps `_genesis` into entity data. Phase 4 replaces this with proper graph-traversable bonds.

5. **BindStep in steps.rs** — Has its own three-way dispatch on `KOSMOS_STOICHEION_BIND`. This prompt only removes the dispatch in bootstrap.rs and AriseStep. BindStep's interpreter dispatch is part of the "other step types" follow-up.

---

*Traces to: Phase 0 doc prescriptions (T12: One right way to arise), V9 migration (WASM stoicheion equivalence proven), dead code policy (contextual poison). The scaffolding served to prove equivalence. Equivalence is proven. The scaffolding comes down.*
