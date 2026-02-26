# PROMPT: Composition as One Path — Migrate Praxeis, Enforce Gating

**Migrates 8 genesis praxeis from `step: arise` to `step: compose` (or documents exceptions), flips the internal gating default to ON, adds docstrings marking `ctx.arise_entity()` as internal, and adds a convenience `ctx.compose()` method on HostContext. After this work, no praxis can use `step: arise` in production — all entity creation flows through composition.**

**Depends on**: PROMPT-DISPATCH-SCAFFOLDING-REMOVAL.md (Phase 1 — dispatch removed, all callers through host methods), Phase 0 doc prescriptions (7 docs already prescribe compose_entity as the one path)
**Prior art**: AriseStep is already gated via `gate_internal_stoicheion("arise")` — but defaults to OFF
**Enables**: Phase 3 (contextual gate), Phase 4 (bootstrap under constitution)

---

## Architectural Principle

**Composition is the one path. Arise is internal.**

T12 prescribes: "ctx.arise_entity() is internal to the composition path, never called directly. No exceptions."

After Phase 1, all entity creation goes through `ctx.arise_entity()`. But `arise_entity()` is still directly callable from anywhere — praxeis can use `step: arise`, MCP can call `ctx.arise_entity()`, any code with a HostContext reference can bypass composition.

Phase 2 makes composition the enforced boundary:

```
INVARIANT:  step: compose is the only step type for entity creation in praxeis
INVARIANT:  step: arise is gated (errors in production)
INVARIANT:  ctx.arise_entity() is documented as internal — reserved for bootstrap, substrate callbacks, and the composition path itself
PROMOTED:   ctx.compose() is the public API for entity creation from outside the interpreter
EXCEPTION:  Praxeis that persist the result of multi-step composition (end-of-pipeline arise) are documented exceptions
EXCEPTION:  Dynamic-eidos import (hypostasis phoreta) is a documented exception
```

---

## Methodology — DDD + TDD

This work follows **Doc → Test → Build → Verify**, non-negotiably.

1. **Doc (prescriptive)**: Phase 0 already prescribes the target. No new doc updates needed.
2. **Test (assert the doc)**: Write a test that AriseStep errors when gating is enforced. Verify existing praxis tests still pass after migration.
3. **Build (satisfy the tests)**: Migrate praxeis, flip default, add docstrings.
4. **Verify doc**: After implementation, confirm docs still describe actuality.

**Mixed genesis + code changes.** Genesis praxeis are migrated in kosmos repo (via symlink). Rust changes are in chora.

---

## Current State

### AriseStep Gating (already exists, defaults OFF)

```rust
// steps.rs:239
fn is_internal_gating_enforced() -> bool {
    std::env::var("KOSMOS_ENFORCE_INTERNAL_GATING")
        .map(|v| v == "true" || v == "1")
        .unwrap_or(false)  // ← defaults to OFF
}
```

When gating is ON, `step: arise` in a praxis errors with:
```
"Stoicheion 'arise' is internal and cannot be used directly. Use 'compose' instead."
```

### Genesis Praxeis Using `step: arise` (8 usages)

| # | File | Line | Creates | Can Migrate? |
|---|------|------|---------|-------------|
| 1 | `genesis/praxeis/genesis.yaml` | 450 | `content-root` entity | Yes — create typos |
| 2 | `ekdosis/praxeis/ekdosis.yaml` | 61 | `oikos-prod` entity | Yes — create typos |
| 3 | `ekdosis/praxeis/ekdosis.yaml` | 143 | `build-attestation` entity | Yes — create typos |
| 4 | `ekdosis/praxeis/ekdosis.yaml` | 310 | `oikos-release` entity | Yes — create typos |
| 5 | `hypostasis/praxeis/hypostasis.yaml` | 427 | Dynamic-eidos import from phoreta | **Exception** — eidos is runtime-dynamic |
| 6 | `thyra/praxeis/thyra.yaml` | 634 | `preference` entity | Yes — create typos |
| 7 | `demiurge/praxeis/render-spec-generation.yaml` | 215 | `render-spec` from LLM output | **Exception** — end-of-pipeline persist |
| 8 | `demiurge/praxeis/demiurge.yaml` | 154 | `artifact` from composed content | **Exception** — end-of-pipeline persist |

### Caller Categories for `ctx.arise_entity()`

| Category | Count | Phase 2 Action |
|----------|-------|----------------|
| Inside `compose_entity()` | 3 | Already correct |
| bootstrap.rs | ~37 | Keep — bootstrap is special case (same crate) |
| WASM callbacks (dynamis.rs) | 2 | Keep — low-level substrate (same crate) |
| dokimasia.rs | 1 | Keep — validation-result synthesis (same crate) |
| MCP lib.rs (production) | ~6 | Route through praxis or document as transport exception |
| AriseStep | 1 | Gated — will error when default flips |
| Tests | ~490 | Keep — test fixture setup is acceptable |

---

## Target State

### 1. Gating Default Flipped

```rust
fn is_internal_gating_enforced() -> bool {
    std::env::var("KOSMOS_ENFORCE_INTERNAL_GATING")
        .map(|v| v == "false" || v == "0")
        .map(|disabled| !disabled)
        .unwrap_or(true)  // ← defaults to ON
}
```

`step: arise` in any praxis errors unless `KOSMOS_ENFORCE_INTERNAL_GATING=false` is set (escape hatch for debugging only).

### 2. Genesis Praxeis Migrated

**5 praxeis** migrated from `step: arise` to `step: compose` with new typos definitions.

**3 praxeis** documented as exceptions (with inline comments explaining why):
- hypostasis import: dynamic eidos from incoming bundle
- demiurge artifact persist: end-of-pipeline, content already composed by prior steps
- render-spec-generation persist: end-of-pipeline, content from LLM

For the 3 exceptions, the `step: arise` remains but with a comment:

```yaml
# Exception: end-of-pipeline persist — content composed by prior steps.
# Allowed under KOSMOS_ENFORCE_INTERNAL_GATING via explicit bypass.
- step: arise
  ...
```

The exceptions bypass gating via a new mechanism: a `_internal: true` flag on the step that is honored by the gating function. This keeps the env var as the global switch while allowing individual steps to opt in.

### 3. `ctx.compose()` on HostContext

```rust
/// Compose an entity through a typos definition.
///
/// This is the promoted public API for entity creation.
/// Internally invokes praxis/demiurge/compose.
pub fn compose(&self, typos_id: &str, inputs: Value) -> Result<Value> {
    self.invoke_praxis("demiurge/compose", json!({
        "typos_id": typos_id,
        "inputs": inputs
    }))
}
```

### 4. `arise_entity()` Docstring

```rust
/// Create a new entity in the graph.
///
/// **INTERNAL**: Prefer `compose()` for entity creation. This method is
/// reserved for:
/// - The composition path (`compose_entity` in the interpreter)
/// - Bootstrap (loading spora.yaml during initialization)
/// - Substrate callbacks (WASM modules, reconcilers)
/// - Transport entities (MCP session/parousia)
/// - Validation results (dokimasia synthesis)
/// - Test fixture setup
///
/// Do NOT use for domain entity creation in praxeis — use `step: compose`
/// with a typos definition instead.
pub fn arise_entity(&self, eidos: &str, id: &str, data: Value) -> Result<Value> {
```

Same pattern for `create_bond()` — stays pub, docstring as internal.

---

## Implementation Order

### Step 1: Create typos definitions for migrating praxeis

Create typos for the 5 praxeis that will migrate from `step: arise` to `step: compose`:

**1a. `typos-def-content-root`** (for genesis.yaml:450)
```yaml
- eidos: typos
  id: typos-def-content-root
  data:
    name: content-root
    target_eidos: content-root
    slots:
      path: { fill: input, required: true }
      content_types: { fill: input, required: true }
      topos_id: { fill: input, required: true }
```

**1b. `typos-def-oikos-prod`** (for ekdosis.yaml:61)
Fields: oikos_id, version, locale, description, manifest, content, content_hash

**1c. `typos-def-build-attestation`** (for ekdosis.yaml:143)
Fields: builder_prosopon, build_timestamp, source_hash, output_hash, signature, builder_pubkey

**1d. `typos-def-oikos-release`** (for ekdosis.yaml:310)
Fields: version, oikos_prod_id, channel, notes, published_at, publisher_prosopon

**1e. `typos-def-preference`** (for thyra.yaml:634)
Fields: name, value

For each: create the typos entity in the appropriate topos `typos/` directory. All slots use `fill: input`.

### Step 2: Migrate praxis steps

Replace each `step: arise` with `step: compose` in the 5 migrating praxeis.

**Before:**
```yaml
- step: arise
  eidos: content-root
  id: "content-root/$path"
  data:
    path: "$path"
    content_types: "$content_types"
    topos_id: "$topos_id"
  bind_to: content_root
```

**After:**
```yaml
- step: compose
  typos_id: typos-def-content-root
  id: "content-root/$path"
  inputs:
    path: "$path"
    content_types: "$content_types"
    topos_id: "$topos_id"
  bind_to: content_root
```

Repeat for all 5 praxeis. Verify the ComposeStep `id` field is supported (check step_types.rs).

### Step 3: Document exception praxeis

Add inline comments to the 3 exception `step: arise` usages:

```yaml
# Exception: dynamic-eidos import from phoreta bundle.
# Cannot use step: compose because target_eidos varies at runtime.
- step: arise
  eidos: "$incoming.eidos"
  ...
```

```yaml
# Exception: end-of-pipeline persist. Content composed by prior steps.
# The arise persists the composed result — not raw entity creation.
- step: arise
  eidos: render-spec
  ...
```

### Step 4: Add `_internal` bypass to AriseStep gating

For the 3 exception praxeis to work when gating is ON, add a bypass mechanism.

**Option A** (recommended): Add `internal: true` field to AriseStep struct:

```rust
// step_types.rs — AriseStep
pub struct AriseStep {
    pub bind_to: Option<String>,
    pub data: Option<serde_json::Value>,
    pub eidos: String,
    pub id: String,
    #[serde(default)]
    pub internal: bool,  // bypass gating when true
}
```

In the gating check:
```rust
Step::Arise(s) => {
    if !s.internal {
        gate_internal_stoicheion("arise")?;
    }
    s.execute(ctx, scope)
}
```

**Option B**: Use a different env var or context flag for exceptions.

**Note**: AriseStep struct is auto-generated by build.rs from stoicheion.yaml. To add the `internal` field, update the `stoicheion/db-arise` definition in `genesis/arche/stoicheion.yaml` to include the field, OR add it manually to the struct with `#[serde(default)]` (since it's a boolean with default false, it won't break YAML that doesn't include it).

Read `stoicheion.yaml` and `build.rs` to determine the right approach.

### Step 5: Flip gating default

In `steps.rs`, change `is_internal_gating_enforced()`:

```rust
fn is_internal_gating_enforced() -> bool {
    // Default ON — step: arise is internal. Set KOSMOS_ENFORCE_INTERNAL_GATING=false to override.
    std::env::var("KOSMOS_ENFORCE_INTERNAL_GATING")
        .map(|v| v != "false" && v != "0")
        .unwrap_or(true)
}
```

### Step 6: Add `ctx.compose()` and docstrings to host.rs

Add the convenience method and update docstrings as shown in Target State above.

### Step 7: Build and test

```bash
cargo build -p kosmos                           # Must compile
cargo test -p kosmos -- --test-threads=1        # Full suite passes
cargo test -p kosmos --test v9_equivalence      # Equivalence tests pass
```

Verify that no production praxis uses `step: arise` without `internal: true`:

```bash
# In genesis/, should only match the 3 documented exceptions:
grep -rn "step: arise" genesis/*/praxeis/*.yaml
```

---

## Files to Read

| File | Why |
|------|-----|
| `crates/kosmos/src/interpreter/steps.rs` | AriseStep gating, compose_entity, ComposeStep |
| `crates/kosmos/src/interpreter/step_types.rs` | AriseStep struct (auto-generated) |
| `crates/kosmos/build.rs` | How step types are generated |
| `genesis/arche/stoicheion.yaml` | Stoicheion definitions (source for build.rs) |
| `crates/kosmos/src/host.rs` | arise_entity, create_bond, invoke_praxis signatures |
| `genesis/genesis/praxeis/genesis.yaml` | content-root arise (line 450) |
| `genesis/ekdosis/praxeis/ekdosis.yaml` | 3 arise usages (lines 61, 143, 310) |
| `genesis/hypostasis/praxeis/hypostasis.yaml` | phoreta import (line 427) |
| `genesis/thyra/praxeis/thyra.yaml` | preference arise (line 634) |
| `genesis/demiurge/praxeis/render-spec-generation.yaml` | render-spec arise (line 215) |
| `genesis/demiurge/praxeis/demiurge.yaml` | artifact arise (line 154) |

## Files to Touch

| File | Action |
|------|--------|
| `genesis/genesis/typos/content-root.yaml` | **NEW** — typos-def-content-root |
| `genesis/ekdosis/typos/ekdosis.yaml` | **NEW** — typos for oikos-prod, build-attestation, oikos-release |
| `genesis/thyra/typos/preference.yaml` | **NEW** — typos-def-preference |
| `genesis/genesis/praxeis/genesis.yaml` | **MODIFY** — arise → compose (line 450) |
| `genesis/ekdosis/praxeis/ekdosis.yaml` | **MODIFY** — 3 arise → compose (lines 61, 143, 310) |
| `genesis/thyra/praxeis/thyra.yaml` | **MODIFY** — arise → compose (line 634) |
| `genesis/hypostasis/praxeis/hypostasis.yaml` | **MODIFY** — add exception comment (line 427) |
| `genesis/demiurge/praxeis/render-spec-generation.yaml` | **MODIFY** — add exception comment (line 215) |
| `genesis/demiurge/praxeis/demiurge.yaml` | **MODIFY** — add exception comment (line 154) |
| `crates/kosmos/src/interpreter/steps.rs` | **MODIFY** — flip gating default |
| `crates/kosmos/src/interpreter/step_types.rs` | **MODIFY** — add `internal` field to AriseStep (if not via build.rs) |
| `crates/kosmos/src/host.rs` | **MODIFY** — add compose() method, update docstrings |

---

## Success Criteria

- [ ] `is_internal_gating_enforced()` defaults to `true`
- [ ] 5 genesis praxeis migrated from `step: arise` to `step: compose`
- [ ] 5 new typos definitions created (content-root, oikos-prod, build-attestation, oikos-release, preference)
- [ ] 3 exception praxeis have inline comments documenting why arise is acceptable
- [ ] 3 exception praxeis use `internal: true` (or equivalent bypass) to avoid gating error
- [ ] `ctx.compose(typos_id, inputs)` method exists on HostContext
- [ ] `arise_entity()` has docstring marking it as internal with list of acceptable callers
- [ ] `create_bond()` has docstring marking it as internal
- [ ] `grep "step: arise" genesis/*/praxeis/*.yaml` returns only the 3 documented exceptions
- [ ] `cargo build -p kosmos` compiles cleanly
- [ ] `cargo test -p kosmos -- --test-threads=1` passes (full suite, zero regressions)
- [ ] No praxis in genesis uses `step: arise` without `internal: true` or equivalent

---

## What Does NOT Change

1. **`arise_entity()` visibility** — stays `pub`. Making it `pub(crate)` would break ~490 integration tests and all kosmos-mcp calls. The boundary is enforced at the step level (gating) and documented via docstrings.
2. **`compose_entity()` location** — stays in steps.rs. It depends on interpreter machinery (Scope, slot resolution). Extraction to host.rs is a future refinement.
3. **Bootstrap** — continues calling `ctx.arise_entity()` directly. Same crate, special case.
4. **WASM substrate callbacks** — continue calling `ctx.arise_entity()` directly. Same crate, special case.
5. **MCP session/parousia creation** — stays as direct `ctx.arise_entity()` calls. These are transport concerns, not domain composition. Documented as acceptable.
6. **Test fixture setup** — tests continue using `ctx.arise_entity()` directly. Test setup is not domain composition.
7. **BindStep** — stays public, not gated. Bonds are always explicit operations.
8. **Docs** — no changes. Phase 0 already prescribes the target.
9. **Other step types' dispatch scaffolding** — separate cleanup.

---

## What This Enables

1. **Praxis authors cannot bypass composition** — `step: arise` errors; `step: compose` with a typos is required. This ensures every domain entity has provenance (composed-from bond), content-hash idempotency, and dependency tracking.

2. **Phase 3 (contextual gate)** — with all domain entities flowing through composition, adding prosopon/oikos/session/attainment requirements to the composition path covers all production entity creation.

3. **Audit trail** — `grep "step: arise" genesis/` immediately reveals the 3 documented exceptions. No hidden raw-arise usages.

---

## Findings That Are Out of Scope

1. **Extracting compose_entity to HostContext** — compose_entity depends on Scope (interpreter machinery). A future refinement could extract the persist logic (hash check + arise + bonds) into a host method, but this adds complexity without immediate benefit since `ctx.compose()` wraps invoke_praxis.

2. **MCP session/parousia migration** — session and parousia creation could theoretically go through praxeis (e.g., `praxis/politeia/create-session`). Deferred — these are transport concerns with legitimate need for direct creation.

3. **BindStep gating** — BindStep is not gated. Bonds are explicit operations in kosmos (not composed from definitions). If bond creation should also flow through composition in the future, that's a separate design question.

4. **Other step types' dispatch scaffolding** — FindStep, GatherStep, etc. still have three-way env var dispatch. Separate cleanup.

5. **ComposeStep `id` field support** — ComposeStep may not currently support an explicit `id` field (compose_entity derives ID from the typos definition). If ComposeStep doesn't support `id`, the typos definitions need an `id` slot with `fill: input`. Verify during implementation.

---

*Traces to: Phase 1 (PROMPT-DISPATCH-SCAFFOLDING-REMOVAL.md — scaffolding removed), Phase 0 (T12: One right way to arise), composition-reconciliation (compose_entity + composed-from bonds). The gate was already built. This prompt closes it.*
