# PROMPT: Dead Code Sweep and Refactor

**Arc**: Post-T12 Structural Hygiene
**Prerequisite**: One Right Way to Arise arc (Phases 0–4) complete. 262 tests pass.
**Principle**: Dead code is contextual poison. Completeness and consistency contribute to coherence.

---

## Pre-Phase: Preserve Current State

Before any deletions, commit everything to preserve the current state.

```
git add -A
git commit -m "checkpoint: T12 One Right Way to Arise complete — all 4 phases

All entities (bootstrap + runtime) arise through compose_entity() with
typed-by and authorized-by bonds. _genesis metadata fully removed.
262 tests pass. Committing before dead code sweep."

git push origin main
```

This creates a restoration point. Every deletion below can be reversed by checking out this commit.

---

## Phase 1: Pure Deletion — Dead Code Removal

**Risk**: Zero. Removing code that is never compiled, never called, or never read.
**Verification**: `cargo build -p kosmos && cargo build -p kosmos-mcp && cargo test -p kosmos`

### 1.1 Delete dead archive file

**File**: `crates/kosmos/src/interpreter/steps.rs.archive`
**Action**: `rm crates/kosmos/src/interpreter/steps.rs.archive`
**Lines saved**: 3,047

This file is not referenced by any `mod` declaration, not compiled, not imported. It's a historical snapshot from before the steps.rs refactor. The functions it references (e.g., `eval_optional_f64`) are orphaned in expr.rs because of this file's existence.

### 1.2 Delete dead step handlers from steps.rs

**File**: `crates/kosmos/src/interpreter/steps.rs`

These step types have handler implementations but **zero active genesis YAML invocations** (only found in `archive/` directories). The step types remain in `step_types.rs` (generated from stoicheion.yaml) — we only delete the handler `impl` blocks and associated helpers.

| Step Handler | Approximate Lines | Notes |
|-------------|-------------------|-------|
| `SpawnProcessStep::execute` | 3828–3910 | No active praxis calls step: spawn-process |
| `CheckProcessStep::execute` | 3918–3945 | No active praxis |
| `KillProcessStep::execute` | 3953–3996 | No active praxis |
| `RegisterMcpToolStep::execute` | 4004–4052 | No active praxis |
| `NixosActivateStep::execute` | 4058–4107 | No active praxis |
| `NixosDeactivateStep::execute` | 4109–4153 | No active praxis |
| `SystemctlStatusStep::execute` | 4155–4190 | No active praxis |
| `SystemdEnableStep::execute` | 4192–4263 | No active praxis |
| `SystemdDisableStep::execute` | 4265–4328 | No active praxis |
| NixOS helpers + `SystemctlProperties` | 4330–4404 | Transitively dead (only called by above) |
| `ShellExecuteStep::execute` | 4420–4528 | No active praxis |
| `HashPathStep::execute` | 4530–4623 | No active praxis |
| `ParseOutputStep::execute` | 4625–4770 | No active praxis |
| `FileExistsStep::execute` | 4772–4827 | No active praxis |
| `FetchToposStep::execute` | 3145–3219 | No active praxis |
| `EmbedStep::execute` | 2572–2596 | No active praxis |

**Also delete** the corresponding match arms in `execute_step()` that dispatch to these handlers. The step types remain defined in step_types.rs (they're still in stoicheion.yaml) — only the Rust handler implementations are removed. If any are invoked at runtime, the match arm falls through to a clear error rather than silently executing dead code.

**Lines saved**: ~1,000

### 1.3 Delete dead functions from expr.rs

**File**: `crates/kosmos/src/interpreter/expr.rs`

| Function | Lines | Why Dead |
|----------|-------|----------|
| `eval_optional_f64` | ~1757–1775 | Zero callers. Only caller was in steps.rs.archive. |
| `eval_optional_i32` | ~1776–1792 | Zero callers. Same. |
| `eval_optional_usize` | ~1793–1808 | Zero callers. Same. |
| `eval_optional_string` | ~1811–1823 | Zero callers. Same. |
| `validate_expression_functions` (non-dynamic) | ~1950–1962 | Only called from test module. Production uses `_dynamic` variant. |
| `validate_expression_functions_with` | ~1966–1983 | Only called from test module. |

**Also**: Remove re-exports of these functions from `mod.rs` and `lib.rs` if any exist.

**Lines saved**: ~95

### 1.4 Delete dead functions from host.rs

**File**: `crates/kosmos/src/host.rs`

| Function | Lines | Why Dead |
|----------|-------|----------|
| `list_dynamic_tools` | 381–388 | Zero callers. Write-side (`register_dynamic_tool`) is alive, read-side is not. |
| `get_dynamic_tool` | 393–395 | Zero callers. Same. |

**Also delete** the empty section header "Composition Reconciliation — The Fourth Loop" (lines 938–942) which contains no content.

**Lines saved**: ~15

### 1.5 Delete dead code from r2.rs

**File**: `crates/kosmos/src/r2.rs`

| Item | Lines | Why Dead |
|------|-------|----------|
| `R2Provider` type alias | 38–39 | Zero references. False comment claims host.rs uses it. |
| `ObjectStorageProvider::from_channel` | 46–90 | 45 lines, zero callers. Superseded by `resolve_storage_credentials()`. |
| `R2Object::from_entity_data` | 105–131 | Only called from tests. Production constructs R2Object inline. |
| `manifest_from_file` | 209–217 | Zero callers. |

**Also remove** the stale comment on line 38 and the unused `Deserialize` derive on `R2Object` (line 94).

**Lines saved**: ~85

### 1.6 Delete dead code from reflex.rs

**File**: `crates/kosmos/src/reflex.rs`

| Item | Lines | Why Dead |
|------|-------|----------|
| Aither stub section (entire `handle_signal` match body) | 887–968 | 82 lines of hardcoded stub strings. Every operation returns "stub — would do X in production." Live call path but does nothing. |

**Also fix** the duplicate `"message"` JSON key bug at lines 946–951 (or just delete the whole section per above).

**Lines saved**: ~82

### 1.7 Delete dead code from nous.rs

**File**: `crates/kosmos/src/nous.rs`

| Item | Lines | Why Dead |
|------|-------|----------|
| `classify_model_by_patterns` | 680–719 | Private helper, only caller is `categorize_models` which is test-only. |
| `categorize_models` | 726–769 | MEMORY.md: "kept as test utility only — not called from production path." |

These 84 lines ship in every production binary for test support only. Move them behind `#[cfg(test)]` in the test module, or into a test helper file. Since they're called from integration tests (`tests/model_tier_resolution.rs`), they can't simply go behind `#[cfg(test)]` — instead, move them to the test file that uses them.

**Lines saved**: ~84 (from production binary)

### 1.8 Delete dead code from kosmos-mcp/lib.rs

**File**: `crates/kosmos-mcp/src/lib.rs`

| Item | Lines | Why Dead |
|------|-------|----------|
| `MultiChangeListener::add` | 100–103 | Zero callers. |
| `SessionToken::has_oikos` | 264–266 | Superseded by `ValidatedSession::has_oikos` in auth.rs. |
| `SessionToken::has_attainment` | 269–271 | Zero callers anywhere. |

**Also**: Collapse the redundant `#[cfg(test)]` / `#[cfg(not(test))]` split of `get_tools_with_session` (lines 810–821) into a single unconditional method. Both branches are identical.

**Lines saved**: ~20

### 1.9 Delete dead code from kosmos-mcp/rest.rs

**File**: `crates/kosmos-mcp/src/rest.rs`

| Item | Lines | Why Dead |
|------|-------|----------|
| `EntityResponse` struct | 39–45 | Zero references anywhere. Handlers return raw `Value`. |
| `BondResponse` struct | 77–84 | Zero references anywhere. |

**Lines saved**: ~15

### 1.10 Delete dead code from bootstrap.rs

**File**: `crates/kosmos/src/bootstrap.rs`

| Item | Lines | Why Dead |
|------|-------|----------|
| `bootstrap_from_single_stream` | 478–489 | Zero callers. |
| `bootstrap_from_single_stream_inner` | 492–566 | Only called by above. |
| `load_single_stream_entity_file` | 570–599 | Only called by above. |
| `load_single_stream_bond_file` | 603–630 | Only called by above. |
| `SingleStreamManifest` struct | 452–464 | Only used by above. |

**Also remove** re-exports of these items from `lib.rs` if present.

**Lines saved**: ~153

### 1.11 Delete dead struct fields

These fields are parsed from YAML but never read:

**bootstrap.rs — `SporaConfig`**: `format_version`, `topos`, `version`, `status`, `description` (5 of 8 fields dead). Either delete these fields (with `#[serde(deny_unknown_fields)]` removed or adjusted) or mark them `#[allow(dead_code)]` with a comment explaining they are YAML schema fields not needed at runtime. **Prefer deletion** — if we need them later, we add them back.

**bootstrap.rs — `GerminationStage`**: `description`, `notes` — parsed never read.

**bootstrap.rs — `StoicheiaForm`**: `tier` — parsed never read.

**bootstrap.rs — `SubstrateManifest`**: `oikos_distributed` — parsed never read.

**Note**: Deleting serde struct fields requires that the YAML files don't include those keys, OR that we add `#[serde(default)]` to the remaining fields and use `#[serde(flatten)]` or `#[serde(deny_unknown_fields = false)]`. Since serde by default ignores unknown fields, **simply deleting the field works** — serde will skip it during deserialization.

### 1.12 Clean up stale version labels

Replace all "V8 API", "V9", "V10", "V11" version labels in comments with neutral descriptions. These are in:
- host.rs lines 6, 721, 943 ("V8 API")
- steps.rs various lines ("V9 WASM support", "V10", "V11")
- kosmos-mcp/lib.rs lines 8, 950 ("V8")

This is cosmetic but removes misleading historical markers.

### 1.13 Delete `value_to_f64` from steps.rs

**File**: `crates/kosmos/src/interpreter/steps.rs`
**Line**: ~76
Already marked `#[allow(dead_code)]`. Delete it. `opt_value_to_f64` and `value_to_f64_opt` are the live variants.

### Phase 1 Verification

```bash
cargo build -p kosmos 2>&1 | head -5
cargo build -p kosmos-mcp 2>&1 | head -5
cargo test -p kosmos 2>&1 | tail -5
cargo test -p kosmos-mcp 2>&1 | tail -5
```

All tests must pass. No new warnings about dead code.

**Expected total lines removed in Phase 1**: ~4,600

---

## Phase 2: Deduplication — Extract Common Patterns

**Risk**: Low. Logic is preserved, only refactored into shared functions.
**Verification**: Same as Phase 1.

### 2.1 Extract Rust/WASM dispatch helper in steps.rs

Nine step types (Find, Gather, Trace, Bind, Loose, Update, Dissolve, Index, Surface) repeat identical dispatch boilerplate:

```rust
fn execute(&self, ctx: &mut HostContext, scope: &Scope) -> Result<Value, ...> {
    match std::env::var("KOSMOS_STOICHEION_XXX").as_deref() {
        Ok("arche") => self.execute_rust(ctx, scope),
        Ok("compare") => { /* run both, compare */ }
        _ => self.execute_wasm(ctx, scope),
    }
}
```

Extract a generic dispatch function:

```rust
fn dispatch_rust_wasm<F, G>(
    stoicheion_name: &str,
    rust_fn: F,
    wasm_fn: G,
    ctx: &mut HostContext,
    scope: &Scope,
) -> Result<Value, StepError>
where
    F: FnOnce(&mut HostContext, &Scope) -> Result<Value, StepError>,
    G: FnOnce(&mut HostContext, &Scope) -> Result<Value, StepError>,
```

Each step's `execute()` becomes a one-liner calling `dispatch_rust_wasm`.

**Lines saved**: ~150–200

### 2.2 Extract slot resolution helper in steps.rs

`compose_data()` (lines ~1776–1817) and `compose_graph()` (lines ~2006–2038) share near-identical slot resolution loops. Extract:

```rust
fn resolve_all_slots(
    slots: &[SlotDef],
    scope: &Scope,
    ctx: &HostContext,
) -> Result<Vec<(String, Value)>, StepError>
```

Both callers use this shared function.

**Lines saved**: ~40

### 2.3 Consolidate `invoke_praxis` / `invoke_praxis_dwelling` in host.rs

**File**: `crates/kosmos/src/host.rs` (lines 507–598)

These two methods share ~40 lines of identical praxis-loading logic. Make `invoke_praxis` delegate to `invoke_praxis_dwelling` with `None`:

```rust
pub fn invoke_praxis(&mut self, praxis_id: &str, params: Value) -> Result<Value, ...> {
    self.invoke_praxis_dwelling(praxis_id, params, None)
}
```

Delete the duplicated logic from `invoke_praxis`.

**Lines saved**: ~40

### 2.4 Consolidate `len()` and `length()` in expr.rs

**File**: `crates/kosmos/src/interpreter/expr.rs`

Both compute array/string/object length with slightly different null handling. Make `length()` delegate to `len()`, or vice versa. Harmonize the null handling (prefer the more defensive version).

**Lines saved**: ~15

### 2.5 Extract TraceStep resolve duplication in steps.rs

TraceStep has identical "resolve" blocks in both `execute_rust()` and `execute_wasm()` (~26 lines each). Extract to a shared `resolve_trace_results()` helper.

**Lines saved**: ~26

### Phase 2 Verification

Same as Phase 1. All tests must pass unchanged.

**Expected total lines saved in Phase 2**: ~270–320

---

## Phase 3: Module Extraction — File Splitting

**Risk**: Low. Pure code movement, no logic changes.
**Verification**: Same cargo build + test.

### 3.1 Extract `composition.rs` from `steps.rs`

Create `crates/kosmos/src/interpreter/composition.rs` containing:

| Item | Current Location in steps.rs |
|------|------------------------------|
| `ComposedData` struct | ~line 1730 |
| `compose_data()` | ~line 1743 |
| `compose_entity()` | ~line 1881 |
| `compose_graph()` | ~line 1940 (after compose_entity) |
| `compose_template()` | after compose_graph |
| `resolve_slot()` helper | ~line 2140 |
| `resolve_all_slots()` | (created in Phase 2.2) |
| `ComposeStep::execute` | ~line 1553 (routes to the three compose_* fns) |

Update `interpreter/mod.rs`:
- Add `mod composition;`
- Move the `pub(crate) use` for `compose_entity` to point at `composition::`
- Move the `pub use` for `compose_data` and `ComposedData` to point at `composition::`

**Lines moved**: ~500–600 from steps.rs → composition.rs

After this, steps.rs drops from ~3,200 (post Phase 1+2) to ~2,600–2,700. Still large but within working range.

### 3.2 Narrow `resolve_mode` in host.rs

Delete the unused `_eidos` and `_host` parameters from `resolve_mode()` (lines 1937–1951). Update the 3 call sites to pass only `data`.

### 3.3 Remove disabled visibility filtering TODO

**File**: `crates/kosmos/src/host.rs` (lines 829–831)

Either implement the visibility filtering or remove the TEMP/TODO comment and the dead `dwelling.is_some()` branch. Prefer: remove the dead branch and leave a clean `// Visibility filtering: not yet implemented` one-line comment.

### Phase 3 Verification

Same cargo build + test. File structure should now be:

```
interpreter/
  mod.rs          (~200 lines)
  composition.rs  (~500-600 lines)  ← NEW
  steps.rs        (~2,600 lines)    ← was 4,827
  expr.rs         (~2,650 lines)    ← was 2,776
  dynamis.rs      (~2,311 lines)    ← unchanged (dedup is Phase 2 optional)
  step_types.rs   (~1,366 lines)    ← generated, unchanged
  wasm.rs         (~470 lines)      ← was 868
  schema.rs       (~421 lines)      ← unchanged
  scope.rs        (~159 lines)      ← unchanged
```

---

## Phase 4 (Optional): WASM Boilerplate Extraction in dynamis.rs

This is the largest single dedup opportunity (~600 lines) but also the most complex since it involves WASM memory management. **Defer unless dynamis.rs needs modification for another reason.**

The pattern: 10 WASM host function registrations repeat identical read-string/allocate/write-JSON boilerplate. Extract three helpers:
- `read_wasm_string(caller, ptr, len) -> Result<String>`
- `write_json_to_wasm(caller, value) -> (i32, i32)`
- `read_json_from_wasm(caller, ptr, len) -> Result<Value>`

Each host function registration drops from ~80 lines to ~15 lines.

---

## Summary

| Phase | Action | Lines Removed/Saved | Risk |
|-------|--------|-------------------|------|
| Pre | Git commit + push (backup) | 0 | None |
| 1 | Pure deletion (dead code) | ~4,600 | Zero |
| 2 | Deduplication | ~270–320 | Low |
| 3 | Module extraction | ~0 net (moved) | Low |
| 4 | WASM dedup (optional) | ~600 | Medium |
| **Total** | | **~5,500–5,800** | |

Post-sweep codebase: ~22,600 lines (down from ~28,400). The 21% that was cruft is gone.

---

## Verification Checklist (after all phases)

- [ ] `cargo build -p kosmos` — clean
- [ ] `cargo build -p kosmos-mcp` — clean
- [ ] `cargo test -p kosmos` — all pass (expect 262+)
- [ ] `cargo test -p kosmos-mcp` — all pass
- [ ] `grep -r "_genesis" crates/` — no hits (except comments)
- [ ] `grep -r "steps.rs.archive" crates/` — no hits
- [ ] `grep -r "#\[allow(dead_code)\]" crates/kosmos/src/` — minimal (only generated code)
- [ ] No `V8`, `V9`, `V10`, `V11` labels in non-archive code
