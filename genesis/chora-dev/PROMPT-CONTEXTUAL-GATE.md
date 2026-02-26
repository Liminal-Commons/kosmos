# PROMPT: Contextual Gate — Every Arise Requires Context

**Adds the four-part contextual gate (prosopon, oikos, session, attainment) to `compose_entity()`. Adds `session_id` to `DwellingContext`. Creates `typed-by` and `authorized-by` bonds during composition. Removes the "allow without context" bypass from `check_praxis_authorization()`. After this work, every composed entity has full provenance bonds and every composition occurs in an authenticated context.**

**Depends on**: PROMPT-COMPOSITION-AS-ONE-PATH.md (Phase 2 — compose is the one path, arise gated), Phase 0 doc prescriptions (7 docs already prescribe the contextual gate table)
**Prior art**: Bootstrap already creates authorized-by and typed-by bonds. DwellingState already has session_id — it's dropped in to_dwelling_context(). ValidatedSession already carries attainments.
**Enables**: Phase 4 (bootstrap under constitution — spora as germination context)

---

## Architectural Principle

**Every arise requires context. No exceptions.**

The docs have prescribed this since Phase 0:

```
| Context          | What It Provides     | Bootstrap Source                        |
|------------------|----------------------|----------------------------------------|
| Prosopon (who)   | Identity creating    | genesis_root.expressed_by              |
| Oikos (where)    | Dwelling context     | Primordial oikos (created in stage 3)  |
| Session (when)   | Temporal context     | Germination session                    |
| Attainment (right)| Authorization       | Genesis root Ed25519 signature         |
```

The code has three gaps:

1. `DwellingContext` lacks `session_id` — `DwellingState` has it but `to_dwelling_context()` drops it
2. `compose_entity()` creates `composed-from` and `depends-on` bonds but NOT `typed-by` or `authorized-by`
3. `check_praxis_authorization()` bypasses when dwelling is None or parousia_id is None — clean break means these bypasses are removed for composition

After this work:

```
INVARIANT:  compose_entity() requires dwelling context with session_id — no Option, no bypass
INVARIANT:  compose_entity() creates typed-by bond (entity → eidos)
INVARIANT:  compose_entity() creates authorized-by bond (entity → session)
INVARIANT:  DwellingContext carries session_id
INVARIANT:  to_dwelling_context() passes session_id through
REMOVES:    "No dwelling = allow" bypass in check_praxis_authorization()
REMOVES:    "No parousia = allow" bypass in check_praxis_authorization()
PRESERVES:  Bootstrap path — is_bootstrapping() still skips validation and reflexes
PRESERVES:  Bootstrap bond creation in bootstrap.rs — it creates its own authorized-by/typed-by bonds
```

---

## Methodology — DDD + TDD

This work follows **Doc → Test → Build → Verify**, non-negotiably.

1. **Doc (prescriptive)**: Phase 0 already prescribes the target. No new doc updates needed — all 7 docs already describe the contextual gate.
2. **Test (assert the doc)**: Write tests that compose_entity creates typed-by and authorized-by bonds. Write tests that composition without dwelling context fails.
3. **Build (satisfy the tests)**: Add session_id to DwellingContext, thread dwelling through compose_entity, create bonds.
4. **Verify doc**: After implementation, confirm docs still describe actuality.

**Pure code changes — no genesis changes, no doc changes.**

---

## Current State

### DwellingContext — Missing session_id

```rust
// scope.rs:17
pub struct DwellingContext {
    pub prosopon_id: String,
    pub oikos_id: String,
    pub parousia_id: Option<String>,
    pub locale: Option<String>,
    // ← NO session_id
}
```

### DwellingState — HAS session_id but drops it

```rust
// kosmos-mcp/src/lib.rs:440
pub struct DwellingState {
    pub prosopon_id: String,
    pub oikos_id: String,
    pub parousia_id: Option<String>,
    pub session_id: Option<String>,    // ← EXISTS
    pub locale: Option<String>,
}

impl DwellingState {
    pub fn to_dwelling_context(&self) -> DwellingContext {
        DwellingContext {
            prosopon_id: self.prosopon_id.clone(),
            oikos_id: self.oikos_id.clone(),
            parousia_id: self.parousia_id.clone(),
            locale: self.locale.clone(),
            // ← session_id DROPPED
        }
    }
}
```

### compose_entity — Missing typed-by and authorized-by bonds

```rust
// steps.rs:1881
fn compose_entity(
    ctx: &HostContext,
    scope: &mut Scope,
    definition: &Value,
    inputs: Value,
) -> Result<Value> {
    // ...
    // γένεσις path creates:
    //   composed-from bond ✓ (line 1935)
    //   depends-on bonds  ✓ (line 1956)
    //   typed-by bond     ✗ MISSING
    //   authorized-by bond ✗ MISSING
    // ...
}
```

### Bootstrap — Creates both bonds (the model to follow)

```rust
// bootstrap.rs:831-839
ctx.create_bond(id, "authorized-by", authorized_by, None)?;

if eidos != "eidos" {
    let eidos_id = format!("eidos/{}", eidos);
    ctx.create_bond(id, "typed-by", &eidos_id, None)?;
}
```

### check_praxis_authorization — Bypasses without context

```rust
// mod.rs:79-87
// No dwelling = bootstrap/CLI/test mode — allow
let Some(dwelling) = dwelling else {
    return Ok(());
};

// No parousia = pre-arising state — allow
let Some(ref parousia_id) = dwelling.parousia_id else {
    return Ok(());
};
```

### ValidatedSession — Has attainments

```rust
// auth.rs:19
pub struct ValidatedSession {
    pub prosopon_id: String,
    pub oikoi: Vec<String>,
    pub attainments: Vec<String>,
    pub issued_at: String,
    pub expires_at: String,
    pub parousia_id: Option<String>,
}
```

### REST layer — Builds DwellingContext without session_id

```rust
// rest.rs:276
let dwelling = session.0.map(|s| DwellingContext {
    prosopon_id: s.prosopon_id.clone(),
    oikos_id: s.oikoi.first().cloned().unwrap_or_default(),
    parousia_id: None,
    locale: None,
    // ← NO session_id
});
```

---

## Target State

### DwellingContext — With session_id

```rust
pub struct DwellingContext {
    pub prosopon_id: String,
    pub oikos_id: String,
    pub parousia_id: Option<String>,
    pub session_id: Option<String>,
    pub locale: Option<String>,
}
```

`session_id` is `Option<String>` because bootstrap has no session entity until stage 5 creates it (Phase 4 addresses germination session). During runtime, it is always present.

### compose_entity — Creates all four bond types

```rust
fn compose_entity(
    ctx: &HostContext,
    scope: &mut Scope,
    definition: &Value,
    inputs: Value,
) -> Result<Value> {
    let composed = compose_data(ctx, scope, definition, inputs)?;

    // ... (hash comparison, idempotency — unchanged)

    let entity = if let Some(existing) = ctx.find_entity(&composed.entity_id)? {
        // μεταβολή path — unchanged (depends-on refresh, no new provenance bonds)
        // ...
    } else {
        // γένεσις path
        let entity = ctx.arise_entity(
            &composed.target_eidos,
            &composed.entity_id,
            Value::Object(composed.data),
        )?;

        // composed-from bond (unchanged)
        if let Some(ref def_id) = composed.def_id {
            ctx.create_bond(&composed.entity_id, "composed-from", def_id, None)?;
        }

        // typed-by bond — NEW
        let eidos_id = format!("eidos/{}", composed.target_eidos);
        ctx.create_bond(&composed.entity_id, "typed-by", &eidos_id, None)?;

        // authorized-by bond — NEW
        // Uses session_id from dwelling context if available
        if let Some(ref dwelling) = scope.dwelling {
            if let Some(ref session_id) = dwelling.session_id {
                ctx.create_bond(&composed.entity_id, "authorized-by", session_id, None)?;
            }
        }

        entity
    };

    // depends-on bonds — unchanged
    // ...

    Ok(entity)
}
```

### to_dwelling_context — Passes session_id through

```rust
impl DwellingState {
    pub fn to_dwelling_context(&self) -> DwellingContext {
        DwellingContext {
            prosopon_id: self.prosopon_id.clone(),
            oikos_id: self.oikos_id.clone(),
            parousia_id: self.parousia_id.clone(),
            session_id: self.session_id.clone(),
            locale: self.locale.clone(),
        }
    }
}
```

### REST layer — Passes session context

Every place that constructs a `DwellingContext` in rest.rs must include `session_id`. The session_id comes from the session entity created during `POST /api/session/arise`.

### check_praxis_authorization — No bypass without context

```rust
fn check_praxis_authorization(
    ctx: &HostContext,
    praxis_id: &str,
    dwelling: Option<&DwellingContext>,
) -> Result<()> {
    let required_bonds = ctx.trace_bonds(Some(praxis_id), None, Some("requires-attainment"))?;

    // No requirements = public praxis (unchanged)
    if required_bonds.is_empty() {
        return Ok(());
    }

    // No dwelling = error (was: bypass)
    let Some(dwelling) = dwelling else {
        return Err(KosmosError::Invalid(format!(
            "Praxis {} requires attainments but no dwelling context provided",
            praxis_id
        )));
    };

    // No parousia = error (was: bypass)
    let Some(ref parousia_id) = dwelling.parousia_id else {
        return Err(KosmosError::Invalid(format!(
            "Praxis {} requires attainments but dwelling has no parousia",
            praxis_id
        )));
    };

    // ... rest unchanged (held ⊇ required check)
}
```

**Note**: This means tests and CLI invocations that call attainment-gated praxeis without dwelling context will now fail. This is correct — they were silently bypassing authorization. Tests must provide proper dwelling context.

---

## Implementation Order

### Step 1: Add session_id to DwellingContext

**File: `crates/kosmos/src/interpreter/scope.rs`**

Add `pub session_id: Option<String>` to `DwellingContext`. Update `Scope::with_dwelling()` — no change needed since it takes the whole struct.

### Step 2: Thread session_id through all DwellingContext construction sites

**File: `crates/kosmos-mcp/src/lib.rs`**

Update `DwellingState::to_dwelling_context()` to include `session_id`.

**File: `crates/kosmos-mcp/src/rest.rs`**

Every `DwellingContext { ... }` construction must include `session_id`. There are at minimum two sites:
- Line 276 (gather entities endpoint) — set from ValidatedSession context
- Line 434 (praxis invocation endpoint) — set from ValidatedSession context

The REST layer currently has no session_id on ValidatedSession. It needs to either: (a) look up the session entity from the parousia, or (b) carry session_id in the token. Option (b) is simpler and avoids a graph query on every request. Add `session_id: Option<String>` to `ValidatedSession` (auth.rs) and `SessionToken` (lib.rs), populated during `POST /api/session/arise`.

**File: `crates/kosmos-mcp/src/lib.rs` (McpServer arise/dwelling)**

Every `DwellingContext { ... }` in McpServer (lines 628, 729) must include `session_id`.

### Step 3: Create typed-by and authorized-by bonds in compose_entity

**File: `crates/kosmos/src/interpreter/steps.rs`**

In the γένεσις path of `compose_entity()` (the `else` branch at line 1926), add:

1. `typed-by` bond: `ctx.create_bond(&composed.entity_id, "typed-by", &eidos_id, None)?;` — always created (following bootstrap pattern: skip only if eidos IS "eidos")
2. `authorized-by` bond: `ctx.create_bond(&composed.entity_id, "authorized-by", session_id, None)?;` — created when dwelling context has session_id

**The μεταβολή path (entity already exists) does NOT create new provenance bonds** — the entity keeps its original typed-by and authorized-by from first composition.

### Step 4: Remove authorization bypasses

**File: `crates/kosmos/src/interpreter/mod.rs`**

In `check_praxis_authorization()`:

1. Replace "No dwelling = allow" (line 80-82) with "No dwelling = error"
2. Replace "No parousia = allow" (line 85-87) with "No parousia = error"

### Step 5: Fix test fixtures

Tests that invoke attainment-gated praxeis must provide proper dwelling context. Tests that invoke compose and expect bonds must verify typed-by and authorized-by bonds are created.

Scan all test files for:
- `execute_praxis(ctx, praxis, inputs, None)` — the `None` dwelling was a bypass, now it only works for public praxeis
- `compose_entity` / ComposeStep tests — verify they check for new bonds

**Expected test updates:**
- `composition_reconciliation.rs` — tests that compose entities must check typed-by/authorized-by bonds
- `conversational_composition.rs` — same
- `literal_fill_accumulation.rs` — same
- Any test calling gated praxeis with `dwelling: None` — must provide DwellingContext

### Step 6: Build and test

```bash
cargo build -p kosmos          # Must compile cleanly
cargo build -p kosmos-mcp      # Must compile cleanly (DwellingContext changed)
cargo test -p kosmos -- --test-threads=1    # Full suite passes
cargo test -p kosmos-mcp       # MCP tests pass
```

---

## Files to Read

| File | Why |
|------|-----|
| `crates/kosmos/src/interpreter/scope.rs` | DwellingContext struct |
| `crates/kosmos/src/interpreter/steps.rs` | compose_entity() — where bonds are created |
| `crates/kosmos/src/interpreter/mod.rs` | execute_praxis() and check_praxis_authorization() |
| `crates/kosmos/src/host.rs` | compose() convenience method, arise_entity() |
| `crates/kosmos-mcp/src/lib.rs` | DwellingState, to_dwelling_context(), McpServer |
| `crates/kosmos-mcp/src/rest.rs` | DwellingContext construction in REST handlers |
| `crates/kosmos-mcp/src/auth.rs` | ValidatedSession struct |
| `crates/kosmos/src/bootstrap.rs` | Bond creation pattern to follow |

## Files to Touch

| File | Action |
|------|--------|
| `crates/kosmos/src/interpreter/scope.rs` | **MODIFY** — add session_id to DwellingContext |
| `crates/kosmos/src/interpreter/steps.rs` | **MODIFY** — add typed-by and authorized-by bonds in compose_entity |
| `crates/kosmos/src/interpreter/mod.rs` | **MODIFY** — remove bypasses in check_praxis_authorization |
| `crates/kosmos-mcp/src/lib.rs` | **MODIFY** — update to_dwelling_context, McpServer DwellingContext sites |
| `crates/kosmos-mcp/src/rest.rs` | **MODIFY** — include session_id in DwellingContext construction |
| `crates/kosmos-mcp/src/auth.rs` | **MODIFY** — add session_id to ValidatedSession |
| `crates/kosmos/tests/*.rs` | **MODIFY** — fix tests that relied on None-dwelling bypass or missing bonds |

---

## Success Criteria

- [ ] `DwellingContext` has `session_id: Option<String>` field
- [ ] `DwellingState::to_dwelling_context()` passes `session_id` through
- [ ] `compose_entity()` creates `typed-by` bond on γένεσις path (entity → eidos)
- [ ] `compose_entity()` creates `authorized-by` bond on γένεσις path (entity → session)
- [ ] `compose_entity()` does NOT create provenance bonds on μεταβολή path (update preserves original)
- [ ] `check_praxis_authorization()` errors when dwelling is None and praxis requires attainments
- [ ] `check_praxis_authorization()` errors when parousia_id is None and praxis requires attainments
- [ ] REST handlers construct DwellingContext with session_id
- [ ] ValidatedSession carries session_id
- [ ] `cargo build -p kosmos` compiles cleanly
- [ ] `cargo build -p kosmos-mcp` compiles cleanly
- [ ] `cargo test -p kosmos -- --test-threads=1` passes (full suite)
- [ ] `cargo test -p kosmos-mcp` passes

---

## What Does NOT Change

1. **`compose_data()` in steps.rs** — Pure data composition, no bonds. Unchanged.
2. **`ctx.arise_entity()` signature in host.rs** — Still takes (eidos, id, data). No context parameter on arise_entity — context flows through scope.dwelling in compose_entity.
3. **Bootstrap's bond creation in bootstrap.rs** — Bootstrap creates its own authorized-by and typed-by bonds. compose_entity's bond creation is for the runtime composition path. Phase 4 unifies these.
4. **Bootstrap's `is_bootstrapping()` skip** — Validation and reflexes are still skipped during bootstrap. Phase 4 addresses this.
5. **`_genesis` metadata stamping** — Still happens. Phase 4 replaces it with proper graph-traversable bonds.
6. **Public praxis authorization** — Praxeis without `requires-attainment` bonds remain public. The bypass removal only affects praxeis that DO require attainments.
7. **Genesis files** — No genesis changes.
8. **Docs** — No doc changes. Phase 0 already prescribed the target.

---

## What This Enables

**Phase 4 — Bootstrap Under Constitution**: Once compose_entity creates all four bond types with dwelling context, bootstrap can flow through the same compose_entity path. The spora provides the germination context: genesis-root prosopon, primordial oikos, germination session. `_genesis` metadata becomes graph-traversable bonds. Bootstrap becomes just another composition run.

---

## Findings That Are Out of Scope

1. **Germination session creation** — Bootstrap doesn't create a session entity today. Phase 4 adds the germination session as part of spora loading.

2. **MCP tool creation (transport entities)** — `rest.rs` creates parousia and session entities via `ctx.arise_entity()` directly (lines 555, 576). These are transport entities, not domain entities — they don't go through composition. Phase 4 may address these with transport-specific typos, or they may remain as documented exceptions (like substrate callbacks).

3. **Attainment checking during composition** — This prompt adds authorized-by bonds (who authorized this entity's creation) but does NOT add attainment checks on the composition path itself. Attainment checking currently happens at the praxis level (`check_praxis_authorization`). Adding it to compose_entity would duplicate the check. The praxis gate is the right place — if you can invoke the praxis, you can compose within it.

4. **compose_entity receiving DwellingContext as parameter** — This prompt reads dwelling context from `scope.dwelling`, which is set by `execute_praxis()`. An alternative design would pass DwellingContext explicitly to compose_entity. The scope approach is chosen because: (a) scope already carries dwelling, (b) compose_data already receives scope, (c) no signature change needed. If Phase 4 requires explicit context for bootstrap, the signature can be extended then.

5. **Removing `_genesis` metadata** — compose_data still passes through `_genesis` metadata (line 1844-1849). Phase 4 replaces this with bonds.

---

*Traces to: Phase 0 doc prescriptions (contextual gate table), composition.md (arise contract 7 obligations), CONTRIBUTING.md (T12: One right way to arise). The docs prescribe four-part context. The code has two-part bond creation. This prompt closes the gap — typed-by and authorized-by bonds join composed-from and depends-on. Every entity has full provenance.*
