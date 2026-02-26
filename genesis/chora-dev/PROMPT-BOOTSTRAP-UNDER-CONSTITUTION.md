# PROMPT: Bootstrap Under Constitution — One Path Through Composition

**Routes all bootstrap entity creation through `compose_entity()` — the same path as runtime. Creates germination dwelling context from the spora (prosopon from `expressed_by`, session from genesis-root phasis). Deletes `_genesis` metadata entirely — provenance is bonds, not embedded data. After this work, every entity in the graph — whether created at bootstrap or runtime — arises through `compose_entity()` with typed-by and authorized-by bonds.**

**Depends on**: PROMPT-CONTEXTUAL-GATE.md (Phase 3 — compose_entity creates typed-by + authorized-by bonds, DwellingContext has session_id)
**Prior art**: Bootstrap already creates authorized-by and typed-by bonds manually. `_genesis` metadata is write-only — nothing reads it. compose_data already has CE4 input passthrough for minimal typos.
**Completes**: The "One Right Way to Arise" arc (Phases 0–4)

---

## Architectural Principle

**One path. No exceptions. No separate "bootstrap arise."**

The docs prescribe this (composition.md, bootstrap-genesis.md, bootstrap.md — all since Phase 0):

> "Bootstrap uses the same composition path as runtime. There is no separate 'bootstrap arise' — every entity, whether created in stage 0 or at runtime, goes through `compose_entity()`."

The code has one remaining violation: bootstrap creates entities via `ctx.arise_entity()` + manual bond creation in 5 functions across ~18 sites. `_genesis` metadata (9 stamping sites, 1 passthrough) embeds provenance as data instead of bonds.

After this work:

```
INVARIANT:  Every entity (except genesis-root phasis) arises through compose_entity()
INVARIANT:  compose_entity() creates typed-by + authorized-by bonds (Phase 3)
INVARIANT:  Bootstrap provides germination dwelling context from the spora
REMOVES:    _genesis metadata — all 9 stamping sites + 1 passthrough
REMOVES:    Manual authorized-by and typed-by bond creation in bootstrap.rs
EXCEPTION:  Genesis-root phasis (phasis/genesis-root) — primordial entity, created
            before any eidos exists, authorized by Ed25519 signature not by session
PRESERVES:  is_bootstrapping() guards (dokimasia skip, reflex dormancy)
PRESERVES:  Additional bonds (member-of, provides-function, etc.) — still created directly
```

---

## Methodology — DDD + TDD

This work follows **Doc → Test → Build → Verify**, non-negotiably.

1. **Doc (prescriptive)**: Phase 0 already prescribes the target. No new doc updates needed.
2. **Test (assert the doc)**: Write tests that bootstrap entities have typed-by and authorized-by bonds. Write tests that `_genesis` metadata is absent.
3. **Build (satisfy the tests)**: Route through compose_entity, remove _genesis.
4. **Verify doc**: After implementation, confirm docs describe actuality.

**Pure code changes — no genesis changes, no doc changes.**

---

## Current State

### Entity Creation in bootstrap.rs — 5 Functions, ~18 Sites

| Function | Lines | Entities | authorized-by | typed-by | _genesis |
|----------|-------|----------|---------------|----------|----------|
| genesis-root phasis | 362-374 | phasis | None | None | None |
| `execute_compose_step` | 798-851 | stage entities | ✓ | ✓ (unless eidos) | ✓ line 819 |
| `create_content_root_entities` | 883-919 | content-root | ✓ | ✓ | ✓ line 900 |
| `load_source_file` | 922-981 | theoria, praxis, etc. | ✓ | **MISSING** | ✓ line 946 |
| `load_topos_manifests` | 1074-1349 | topos, manifest, surface, content-root | ✓ | ✓ (some) | ✓ lines 1171,1212,1263,1290,1322 |

**Note**: `load_source_file` is missing typed-by bonds. Phase 4 fixes this by routing through compose_entity.

### _genesis Metadata — Write-Only Dead Data

**9 stamping sites** in bootstrap.rs (lines 819, 900, 946, 1171, 1212, 1263, 1290, 1322).
**1 passthrough** in steps.rs:1844-1849 (compose_data forwards _genesis from inputs).
**0 readers** anywhere in the codebase. The frontend never references it.

### compose_entity — Private, Missing Eidos Guard

```rust
// steps.rs:1881 — private function
fn compose_entity(
    ctx: &HostContext,
    scope: &mut Scope,
    definition: &Value,
    inputs: Value,
) -> Result<Value> {
    // ...
    // typed-by bond (Phase 3) — no guard for eidos entities
    let eidos_id = format!("eidos/{}", composed.target_eidos);
    ctx.create_bond(&composed.entity_id, "typed-by", &eidos_id, None)?;
    // ...
}
```

### compose_data — CE4 Drops Non-Eidos Fields

```rust
// steps.rs:1826-1843
// CE4: Only passes through inputs matching eidos field definitions
// If eidos doesn't exist (early bootstrap), NOTHING passes through
// If eidos exists but doesn't declare all fields, extras are dropped
if let Ok(Some(eidos_entity)) = ctx.find_entity(&eidos_id) {
    // ... only matching fields copied ...
}
```

For bootstrap use, compose_data needs a fallback: when there are no slots, pass through ALL input fields not already covered by CE4.

---

## Target State

### compose_entity — pub(crate), Eidos Guard

```rust
// steps.rs — accessible to bootstrap.rs within the kosmos crate
pub(crate) fn compose_entity(
    ctx: &HostContext,
    scope: &mut Scope,
    definition: &Value,
    inputs: Value,
) -> Result<Value> {
    // ... (hash comparison, idempotency — unchanged)

    // γένεσις path:
    let entity = ctx.arise_entity(
        &composed.target_eidos,
        &composed.entity_id,
        Value::Object(composed.data),
    )?;

    // composed-from bond (unchanged — only if def_id exists)
    if let Some(ref def_id) = composed.def_id {
        ctx.create_bond(&composed.entity_id, "composed-from", def_id, None)?;
    }

    // typed-by bond — with eidos guard (bootstrap pattern)
    if composed.target_eidos != "eidos" {
        let eidos_id = format!("eidos/{}", composed.target_eidos);
        ctx.create_bond(&composed.entity_id, "typed-by", &eidos_id, None)?;
    }

    // authorized-by bond (Phase 3 — from dwelling session_id)
    if let Some(ref dwelling) = scope.dwelling {
        if let Some(ref session_id) = dwelling.session_id {
            ctx.create_bond(&composed.entity_id, "authorized-by", session_id, None)?;
        }
    }

    entity
    // ...
}
```

### compose_data — No-Slot Input Passthrough

```rust
// After CE4 block, before _composition_inputs:
// When no slots are defined, pass through any input fields not already resolved
// This enables bootstrap's "raw entity" pattern: data provided directly as inputs
let has_slots = def_data.get("slots").is_some();
if !has_slots {
    for (k, v) in &inputs_map {
        if k != "id" && !composed_data.contains_key(k) {
            composed_data.insert(k.clone(), v.clone());
        }
    }
}
```

This is strictly additive — never overrides CE4 results, only fills gaps. Handles:
- Stage 0 (eidos/eidos): eidos doesn't exist yet → CE4 finds nothing → passthrough provides all data
- Stage 1+ (other eide): eidos exists → CE4 passes matching fields → passthrough fills any extras
- Runtime minimal typos: same behavior, eidos validation catches invalid fields

### Germination Dwelling Context

```rust
// In bootstrap_from_spora_inner(), after creating genesis-root phasis:
let germination_dwelling = DwellingContext {
    prosopon_id: spora.genesis_root.expressed_by.clone(),
    oikos_id: "oikos/kosmos".to_string(),
    parousia_id: None,
    session_id: Some(spora.genesis_root.id.clone()), // "phasis/genesis-root"
    locale: Some("en".to_string()),
};
let mut scope = Scope::with_dwelling(germination_dwelling);
```

The spora provides germination context:
- **Who**: `genesis_root.expressed_by` (prosopon/victor — the signer)
- **Where**: oikos/kosmos (the primordial oikos)
- **When/By what right**: `genesis_root.id` (phasis/genesis-root — Ed25519-signed authorization)

The prosopon and oikos entities don't exist in the DB until stage 3. This is correct — the dwelling context carries IDs, not entity references. The spora IS the authorization. Once context entities exist, the bonds connect them.

### bootstrap_arise Helper

```rust
/// Create a bootstrap entity through the composition path.
///
/// Wraps compose_entity for bootstrap use: constructs a synthetic
/// definition (target_eidos only, no slots), passes entity data as inputs.
/// compose_entity handles arise, typed-by, authorized-by bonds.
fn bootstrap_arise(
    ctx: &HostContext,
    scope: &mut Scope,
    eidos: &str,
    id: &str,
    data: Value,
    result: &mut BootstrapResult,
) -> Result<Value> {
    // Synthetic definition — just target_eidos, no slots
    let definition = json!({
        "data": { "target_eidos": eidos }
    });

    // Entity data becomes compose inputs. Include "id" for entity ID resolution.
    let mut inputs = data;
    if let Value::Object(ref mut map) = inputs {
        map.insert("id".to_string(), Value::String(id.to_string()));
    }

    let entity = compose_entity(ctx, scope, &definition, inputs)?;

    // Update counts (compose_entity creates entity + bonds internally)
    result.entities_created += 1;
    if eidos != "eidos" {
        result.bonds_created += 1; // typed-by
    }
    if scope.dwelling.as_ref().and_then(|d| d.session_id.as_ref()).is_some() {
        result.bonds_created += 1; // authorized-by
    }

    Ok(entity)
}
```

### _genesis Removal

Delete all 9 stamping sites. Delete compose_data passthrough (lines 1844-1849). `_genesis` becomes absent from the codebase.

---

## Implementation Order

### Step 1: Make compose_entity pub(crate) and add eidos guard

**File: `crates/kosmos/src/interpreter/steps.rs`**

Change `fn compose_entity(` to `pub(crate) fn compose_entity(`.

Add eidos guard to typed-by bond creation (Phase 3 added typed-by but without guard):
```rust
if composed.target_eidos != "eidos" {
    let eidos_id = format!("eidos/{}", composed.target_eidos);
    ctx.create_bond(&composed.entity_id, "typed-by", &eidos_id, None)?;
}
```

**File: `crates/kosmos/src/interpreter/mod.rs`**

Add `compose_entity` to the `pub use steps::{...}` export list.

### Step 2: Add no-slot input passthrough to compose_data

**File: `crates/kosmos/src/interpreter/steps.rs`**

After the CE4 block (line ~1843) and BEFORE the _genesis passthrough (which we delete in Step 3), add:

```rust
// No-slot input passthrough: when definition has no slots, pass through
// any input fields not already resolved by CE4. Enables bootstrap's raw
// entity pattern and minimal typos without explicit slot definitions.
let has_slots = def_data.get("slots").is_some();
if !has_slots {
    for (k, v) in &inputs_map {
        if k != "id" && !composed_data.contains_key(k) {
            composed_data.insert(k.clone(), v.clone());
        }
    }
}
```

### Step 3: Delete _genesis metadata

**File: `crates/kosmos/src/interpreter/steps.rs`**

Delete lines 1844-1849 (the `_genesis` passthrough in compose_data):
```rust
// DELETE THIS:
// Also pass through any "_genesis" metadata if provided (for bootstrap)
if !composed_data.contains_key("_genesis") {
    if let Some(genesis_meta) = inputs_map.get("_genesis") {
        composed_data.insert("_genesis".to_string(), genesis_meta.clone());
    }
}
```

**File: `crates/kosmos/src/bootstrap.rs`**

Delete all 9 `_genesis` stamping blocks. Each is a `map.insert("_genesis".to_string(), json!({...}))` or inline `"_genesis": {...}` in a json! macro.

Sites (work bottom-up since line numbers shift):
1. Line 1322: `load_topos_manifests` — content-root `_genesis`
2. Line 1290: `load_topos_manifests` — surface (consumed) `_genesis`
3. Line 1263: `load_topos_manifests` — surface (provided) `_genesis`
4. Line 1212: `load_topos_manifests` — topos-manifest `_genesis`
5. Line 1171: `load_topos_manifests` — topos entity `_genesis`
6. Line 946: `load_source_file` — `_genesis` stamping
7. Line 900: `create_content_root_entities` — `_genesis` in json!
8. Line 815-825: `execute_compose_step` — `_genesis` stamping block

### Step 4: Create germination scope in bootstrap

**File: `crates/kosmos/src/bootstrap.rs`**

In `bootstrap_from_spora_inner()`, after the genesis-root phasis creation (line 374) and before stage execution (line 381):

```rust
// Germination dwelling context — the spora provides primordial context
let germination_dwelling = DwellingContext {
    prosopon_id: spora.genesis_root.expressed_by.clone(),
    oikos_id: "oikos/kosmos".to_string(),
    parousia_id: None,
    session_id: Some(spora.genesis_root.id.clone()),
    locale: Some("en".to_string()),
};
let mut germination_scope = Scope::with_dwelling(germination_dwelling);
```

Add imports: `use crate::interpreter::{Scope, DwellingContext, compose_entity};`

Thread `germination_scope` through all entity-creating functions. Each function that currently takes `(ctx, ..., result)` gains `scope: &mut Scope`:
- `execute_stage(ctx, &stage, &mut result, spora_path)` → `execute_stage(ctx, &stage, &mut germination_scope, &mut result, spora_path)`
- `create_content_root_entities(ctx, &spora.content_roots, &mut result)` → add scope
- `load_topos_manifests(...)` → add scope
- `load_topos_content(...)` → add scope
- Each cascades scope to inner calls.

### Step 5: Create bootstrap_arise helper

**File: `crates/kosmos/src/bootstrap.rs`**

Add the `bootstrap_arise` function (shown in Target State above). Place it near the top of the file, after imports.

### Step 6: Replace entity creation in execute_compose_step

**Before:**
```rust
let mut data = spec.data.clone();
// _genesis stamping (DELETED in Step 3)
ctx.arise_entity(eidos, id, data)?;
result.entities_created += 1;
ctx.create_bond(id, "authorized-by", authorized_by, None)?;
result.bonds_created += 1;
if eidos != "eidos" {
    ctx.create_bond(id, "typed-by", &eidos_id, None)?;
    result.bonds_created += 1;
}
```

**After:**
```rust
let data = spec.data.clone();
bootstrap_arise(ctx, scope, eidos, id, data, result)?;
```

The `authorized_by` parameter is no longer needed — it comes from `scope.dwelling.session_id`. Remove `authorized_by` from `execute_compose_step`'s signature.

Additional bonds (spec.bonds) still created directly after bootstrap_arise.

### Step 7: Replace entity creation in create_content_root_entities

**Before:**
```rust
let data = json!({ "path": ..., "constitutional": ..., "_genesis": {...} });
ctx.arise_entity("content-root", &root.id, data)?;
ctx.create_bond(&root.id, "authorized-by", "phasis/genesis-root", None)?;
ctx.create_bond(&root.id, "typed-by", "eidos/content-root", None)?;
```

**After:**
```rust
let data = json!({ "path": root.path, "constitutional": root.constitutional, "order": root.order, "content_types": root.content_types, "description": root.description });
bootstrap_arise(ctx, scope, "content-root", &root.id, data, result)?;
```

### Step 8: Replace entity creation in load_source_file

**Before:**
```rust
let mut data = entity.data.clone().unwrap_or(Value::Object(Default::default()));
// _genesis stamping (DELETED)
ctx.arise_entity(eidos, id, data.clone())?;
ctx.create_bond(id, "authorized-by", authorized_by, None)?;
// NOTE: typed-by was MISSING here — Phase 4 fixes this
```

**After:**
```rust
let data = entity.data.clone().unwrap_or(Value::Object(Default::default()));
bootstrap_arise(ctx, scope, eidos, id, data, result)?;
```

compose_entity creates typed-by automatically — the missing bond is fixed.

Entity-declared bonds (from entity.bonds) still created directly after bootstrap_arise.

Remove `authorized_by` parameter from `load_source_file` — comes from scope.

### Step 9: Replace entity creation in load_topos_manifests

This function creates 5 entity types. Each `arise_entity` + manual bond site becomes `bootstrap_arise`:

1. **Topos entity** (line 1177): `bootstrap_arise(ctx, scope, "topos", &topos_entity_id, topos_data, result)?;`
2. **Topos-manifest entity** (line 1218): `bootstrap_arise(ctx, scope, "topos-manifest", &entity_id, data, result)?;`
3. **Surface entity (provided)** (line 1269): `bootstrap_arise(ctx, scope, "surface", &surface_id, surface_data, result)?;`
4. **Surface entity (consumed)** (line 1296): `bootstrap_arise(ctx, scope, "surface", &surface_id, surface_data, result)?;`
5. **Content-root entity** (line 1328): `bootstrap_arise(ctx, scope, "content-root", &content_root_id, root_data, result)?;`

Remove manual `authorized-by` and `typed-by` bond creation after each. Additional bonds (manifest-for, provides-affordance, requires-attainment, provides-surface, consumes-surface, sources-content-from) still created directly.

### Step 10: Build and test

```bash
cargo build -p kosmos          # Must compile cleanly
cargo build -p kosmos-mcp      # Must compile cleanly
cargo test -p kosmos -- --test-threads=1    # Full suite passes
```

---

## Files to Read

| File | Why |
|------|-----|
| `crates/kosmos/src/bootstrap.rs` | Primary target — all entity creation sites |
| `crates/kosmos/src/interpreter/steps.rs` | compose_entity, compose_data, _genesis passthrough |
| `crates/kosmos/src/interpreter/mod.rs` | Export list for compose_entity |
| `crates/kosmos/src/interpreter/scope.rs` | DwellingContext struct (has session_id from Phase 3) |
| `crates/kosmos/src/host.rs` | arise_entity, create_bond signatures |

## Files to Touch

| File | Action |
|------|--------|
| `crates/kosmos/src/interpreter/steps.rs` | **MODIFY** — make compose_entity pub(crate), add eidos guard, add no-slot passthrough, delete _genesis passthrough |
| `crates/kosmos/src/interpreter/mod.rs` | **MODIFY** — export compose_entity |
| `crates/kosmos/src/bootstrap.rs` | **MODIFY** — add germination scope + bootstrap_arise helper, replace all entity creation sites (~18), delete _genesis stamping (9 sites), thread scope through functions |
| `crates/kosmos/tests/*.rs` | **MODIFY** — tests that check _genesis metadata → check bonds instead |

---

## Success Criteria

- [ ] `compose_entity` is `pub(crate)` and exported from interpreter module
- [ ] compose_entity skips typed-by bond when target_eidos == "eidos"
- [ ] compose_data passes through all inputs when no slots are defined (no-slot fallback)
- [ ] `_genesis` does not appear anywhere in the codebase (except archive files)
- [ ] Bootstrap entities have `authorized-by` bonds (to phasis/genesis-root via session_id)
- [ ] Bootstrap entities have `typed-by` bonds (except eidos entities) — including source-file entities that were previously missing them
- [ ] Genesis-root phasis (phasis/genesis-root) is the one entity created via arise_entity directly
- [ ] `execute_compose_step` no longer takes `authorized_by` parameter
- [ ] `load_source_file` no longer takes `authorized_by` parameter
- [ ] `germination_scope` is created in `bootstrap_from_spora_inner` with spora-derived dwelling context
- [ ] `cargo build -p kosmos` compiles cleanly
- [ ] `cargo build -p kosmos-mcp` compiles cleanly
- [ ] `cargo test -p kosmos -- --test-threads=1` passes (full suite)

---

## What Does NOT Change

1. **Genesis-root phasis creation** — The one exception. Created via `ctx.arise_entity("phasis", ...)` before any eidos exists. No typed-by bond (eidos/phasis doesn't exist yet). No authorized-by bond (it IS the authority). The primordial entity.

2. **`is_bootstrapping()` guards** — Dokimasia validation skip and reflex dormancy remain. Bootstrap creates entities before eide are fully loaded; validation would fail. Reflexes fire after `exit_bootstrap_mode()`.

3. **Additional bonds in bootstrap** — `member-of`, `provides-function`, `grants-attainment`, `manifest-for`, `provides-surface`, `consumes-surface`, `sources-content-from`, entity-declared bonds — all still created via `ctx.create_bond()` after bootstrap_arise. compose_entity only handles the four provenance bonds (composed-from, typed-by, authorized-by, depends-on).

4. **`execute_bond_step`** — Standalone bond steps between existing entities. These don't create entities, just bonds. Unchanged.

5. **WASM module compilation** — `load_wasm_modules()` in bootstrap. No entity creation. Unchanged.

6. **Topos contract validation** — `validate_dynamis_requirements()`, `validate_surface_dependencies()`, `validate_topos_contracts()`. Read-only. Unchanged.

7. **BootstrapResult struct** — Same fields. Counts may shift slightly since compose_entity creates bonds internally.

8. **Genesis files** — No genesis changes.

9. **Docs** — No doc changes. Phase 0 already prescribed the target.

---

## What This Completes

Phase 4 is the final phase of the "One Right Way to Arise" arc:

| Phase | Prompt | Status | What It Did |
|-------|--------|--------|-------------|
| 0 | (inline) | DONE | Prescribed target in 7 docs + T12 theoria |
| 1 | PROMPT-DISPATCH-SCAFFOLDING-REMOVAL.md | DONE | Removed WASM dispatch scaffolding |
| 2 | PROMPT-COMPOSITION-AS-ONE-PATH.md | DONE | Migrated praxeis, gated arise, added ctx.compose() |
| 3 | PROMPT-CONTEXTUAL-GATE.md | IN PROGRESS | Added session_id, typed-by/authorized-by bonds, removed bypasses |
| 4 | **This prompt** | PENDING | Bootstrap through compose_entity, _genesis deleted |

After Phase 4, the arise contract is fully satisfied everywhere. Every entity has provenance bonds. The composition path IS the entity creation path. The docs describe actuality.

---

## Findings That Are Out of Scope

1. **Germination session as a first-class entity** — This prompt uses phasis/genesis-root as the session_id during bootstrap. A dedicated session/germination entity could be created in a future stage, but it adds complexity without clear benefit. phasis/genesis-root IS the authorization anchor. If a germination session is desired later, it can be added as a spora stage step.

2. **compose_entity for transport entities** — `rest.rs` creates parousia and session entities via `ctx.arise_entity()` directly. These are transport entities at the MCP/REST boundary. A separate prompt could migrate these to composition if typos definitions are created for them.

3. **BootstrapResult count accuracy** — compose_entity creates bonds internally. The count tracking in bootstrap_arise is approximate (counts expected bonds). If precise counting matters, compose_entity could return a BondCount, but this adds complexity for cosmetic benefit.

4. **Removing steps.rs.archive** — There's a `steps.rs.archive` file with dead _genesis code. Dead file, should be deleted, but out of scope for this prompt.

5. **CE4 field matching refinement** — The no-slot input passthrough makes CE4 less restrictive. In theory, this could pass unexpected fields through for runtime compose operations with minimal typos. Dokimasia validation catches invalid fields, so this is safe. But it's a behavior change for runtime callers with no-slot definitions.

---

*Traces to: Phase 0 doc prescriptions (T12: One right way to arise), composition.md (arise contract), bootstrap-genesis.md ("the spora IS the definition, the genesis root IS the authorization, the germination IS the session"). The spora hatches the chicken. The chicken lays eggs through the same path. One path.*
