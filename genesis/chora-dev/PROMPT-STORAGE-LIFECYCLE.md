# Storage Lifecycle Completion — Sense Must Write Back

*Prompt for Claude Code in the chora + kosmos repository context.*

*Adds `_entity_update` to R2 sense, manifest, and unmanifest operations. Replaces S3 stubs with one-liner delegations. After this work, R2 sense closes the autonomic loop by writing actuality back to entities, `reconciler/release-artifact` reads live state, and S3 stoicheion dispatch through the same code path as R2. Advances object-storage/r2 from stage 5 to stage 6.*

*Depends on: PROMPT-SUBSTRATE-STANDARD.md, PROMPT-SUBSTRATE-DNS.md*

---

## Architectural Principle — Sense Without Memory Is Not Sensing

An autonomic loop has three phases: sense → compare → act. The reconciler compares intent with actuality and dispatches action. But it can only compare what it can read. If a sense operation queries external state (does this object exist in R2?) but doesn't write the result back into the entity, the reconciler reads stale data. The loop is broken.

```
BROKEN:   sense() → returns { status: "present", size: 1234 }
                     entity._sensed is NEVER SET
          reconcile() → reads entity._sensed → undefined → mismatch → spurious manifest

WORKING:  sense() → returns { status: "sensed", _entity_update: { _sensed: { exists: true, size: 1234 } } }
                     dispatch_to_module() applies _entity_update
          reconcile() → reads entity._sensed.exists → true → matches intent → no action
```

Local filesystem storage (fs-stat-file) already does this correctly — it returns `_entity_update` with `_sensed.exists`, `_sensed.size_bytes`, `_sensed.content_hash`. R2 does NOT. R2 sense returns an `R2Actuality` struct serialized to JSON, but without `_entity_update`. The entity is never updated. The reconciler can never see R2's actual state.

**Every sense operation must close the loop by writing actuality back to the entity.** Without this, sensing is observation without memory — the world forgets what it learned.

The second principle: **providers are configuration, not code.** S3 and R2 use the same API protocol (S3-compatible). The difference is the endpoint URL. Today, S3 stoicheion (s3-put-object, s3-head-object, s3-delete-object) are stubs that return `"status": "stub"`. They should delegate to the same R2 implementation with a different endpoint.

---

## Methodology — DDD + TDD

This work follows **Doc → Test → Build → Verify**, non-negotiably.

1. **Doc (prescriptive)**: This prompt IS the prescriptive doc. The target state described here is what code must match.
2. **Test (assert the doc)**: Write tests that assert `_entity_update` presence in R2 operations and S3 stub replacement. Tests should fail before implementation.
3. **Build (satisfy the tests)**: Implement until tests pass.
4. **Verify doc**: After implementation, update success criteria to reflect completion. Check docs/REGISTRY.md impact map.

Empirical emphasis — R2 operations touch external services. Tests that require real R2 credentials should be `#[ignore]`. Tests that verify return structure (presence of `_entity_update` key) can use mock data.

---

## Current State

### What Exists and Works

| Component | Location | Status |
|-----------|----------|--------|
| storage.rs routing | `storage.rs:23` | Working — routes r2/s3 to `r2::execute_operation()`, local to `execute_local()` |
| Local `_entity_update` | `storage.rs` (fs-stat-file) | Working — returns `_sensed.exists`, `size_bytes`, `content_hash` |
| R2 manifest (upload) | `r2.rs:617` | Working — uploads to R2, but returns NO `_entity_update` |
| R2 sense (head) | `r2.rs:669` | Working — queries R2, returns `R2Actuality`, but NO `_entity_update` |
| R2 unmanifest (delete) | `r2.rs:686` | Working — deletes from R2, but returns NO `_entity_update` |
| R2 dispatch in host.rs | `host.rs` | Working — already uses `dispatch_to_module()` for R2 |
| reconciler/release-artifact | `genesis/dynamis/reconcilers/dynamis.yaml` | Defined — reads `_sensed.exists`, but R2 never populates it |
| S3 stubs in host.rs | `host.rs` (manifest/sense/unmanifest) | Stubs — return `"status": "stub"`, bypass storage module entirely |

### What's Missing — The Gaps

**Gap 1: R2 operations return no `_entity_update`.** R2 sense returns `R2Actuality` with `status`, `size`, `etag` — but without the `_entity_update` wrapper. `dispatch_to_module()` → `apply_entity_update()` finds nothing to apply. The entity is never updated. `reconciler/release-artifact` reads `_sensed.exists` from the entity — it's always undefined. The reconciler spuriously triggers manifest on every cycle.

**Gap 2: S3 stoicheion are stubs.** `s3-put-object`, `s3-head-object`, `s3-delete-object` return `"status": "stub"` inline in host.rs. `storage.rs` already routes "s3" to `r2::execute_operation()`. The stubs bypass this routing entirely. They need to become one-liner delegations through `dispatch_to_module`, like R2.

**Gap 3: No S3 endpoint configuration.** R2Provider likely hardcodes the R2 endpoint URL (`{account_id}.r2.cloudflarestorage.com`). S3 uses a different endpoint format (`s3.{region}.amazonaws.com`). The R2 module needs endpoint flexibility to support both providers through the same code path.

---

## Target State

### R2 sense returns `_entity_update`

```rust
"sense" | "head" => {
    let result = sense(&provider, key, expected_size, expected_etag)?;
    let mut value = serde_json::to_value(&result).unwrap_or(Value::Null);
    if let Some(obj) = value.as_object_mut() {
        obj.insert("entity_id".into(), json!(entity_id));
        obj.insert("stoicheion".into(), json!("r2-head-object"));
        obj.insert("_entity_update".into(), json!({
            "_sensed": {
                "exists": result.status == R2Status::Present,
                "size": result.size,
                "etag": result.etag,
                "content_type": result.content_type,
                "divergence": result.divergence
            },
            "last_sensed_at": chrono::Utc::now().to_rfc3339()
        }));
    }
    Ok(value)
}
```

### R2 manifest returns `_entity_update`

```rust
"upload" | "manifest" => {
    let result = manifest(&provider, &object, &content)?;
    // ... existing serialization ...
    obj.insert("_entity_update".into(), json!({
        "_sensed": { "exists": true, "size": content.len() },
        "actual_state": "manifested",
        "last_reconciled_at": chrono::Utc::now().to_rfc3339()
    }));
}
```

### R2 unmanifest returns `_entity_update`

```rust
"delete" => {
    unmanifest(&provider, key)?;
    Ok(json!({
        "status": "unmanifested",
        "entity_id": entity_id,
        "stoicheion": "r2-delete-object",
        "_entity_update": {
            "_sensed": { "exists": false },
            "actual_state": "unmanifested",
            "last_reconciled_at": chrono::Utc::now().to_rfc3339()
        }
    }))
}
```

### S3 stoicheion dispatch through `dispatch_to_module`

```rust
// manifest_by_stoicheion:
"s3-put-object" => self.dispatch_to_module(entity_id, data,
    crate::storage::execute_operation("upload", entity_id, &inject_provider(data, "s3"), session_ref)),

// sense_by_stoicheion:
"s3-head-object" => self.dispatch_to_module(entity_id, data,
    crate::storage::execute_operation("sense", entity_id, &inject_provider(data, "s3"), session_ref)),

// unmanifest_by_stoicheion:
"s3-delete-object" => self.dispatch_to_module(entity_id, data,
    crate::storage::execute_operation("delete", entity_id, &inject_provider(data, "s3"), session_ref)),
```

---

## Sequenced Work

### Phase 1: R2 `_entity_update` Convention (Rust)

**Goal:** R2 operations return `_entity_update` in their results, closing the sense loop.

**Tests:**
- `test_r2_sense_returns_entity_update` — call `r2::execute_operation("sense", ...)` with mock data, verify result contains `_entity_update._sensed.exists`
- `test_r2_manifest_returns_entity_update` — call `r2::execute_operation("upload", ...)`, verify `_entity_update` with `actual_state: "manifested"`
- `test_r2_unmanifest_returns_entity_update` — call `r2::execute_operation("delete", ...)`, verify `_entity_update._sensed.exists == false`
- `test_local_stat_has_entity_update` — verify existing local storage sense includes `_entity_update` (regression)

**Implementation:**

1. In `r2.rs` "sense" | "head" arm, add `_entity_update` with `_sensed` object containing `exists`, `size`, `etag`, `content_type`, `divergence`
2. In `r2.rs` "upload" | "manifest" arm, add `_entity_update` with `_sensed.exists: true`, `actual_state: "manifested"`
3. In `r2.rs` "delete" arm, add `_entity_update` with `_sensed.exists: false`, `actual_state: "unmanifested"`

**Phase 1 Complete When:**
- [ ] R2 sense returns `_entity_update._sensed.exists` (true or false based on R2Actuality status)
- [ ] R2 manifest returns `_entity_update` with `actual_state: "manifested"` and `_sensed.exists: true`
- [ ] R2 unmanifest returns `_entity_update` with `_sensed.exists: false`
- [ ] Local storage sense unchanged (regression)

### Phase 2: S3 Stub Replacement (Rust)

**Goal:** S3 stoicheion dispatch through `dispatch_to_module` to the storage module, not inline stubs.

**Tests:**
- `test_s3_dispatch_not_stub` — bootstrap, call manifest_by_stoicheion("s3-put-object", ...), verify result does NOT contain `"status": "stub"` (should be credential error, confirming stub was replaced)

**Implementation:**

1. Replace `s3-put-object` stub in `manifest_by_stoicheion` with one-liner delegation through `dispatch_to_module`
2. Replace `s3-head-object` stub in `sense_by_stoicheion` with one-liner delegation
3. Replace `s3-delete-object` stub in `unmanifest_by_stoicheion` with one-liner delegation
4. Assess `R2Provider` endpoint construction — if hardcoded to R2, add `endpoint` field that defaults to R2 but can be overridden for S3. If credential resolution differs (AWS uses different key names), add S3-specific credential resolver within the same module.

**Phase 2 Complete When:**
- [ ] S3 stoicheion dispatch through `dispatch_to_module` — no more stubs
- [ ] `storage.rs` routing handles "s3" provider (already does — no change needed)
- [ ] S3 endpoint configurable (entity data or provider-based resolution)

### Phase 3: Verify

**Goal:** Everything works together. The reconciler reads live state.

```bash
cargo build -p kosmos 2>&1
cargo test -p kosmos --lib --tests 2>&1
cargo test -p kosmos --test storage_lifecycle 2>&1
cargo test -p kosmos --test reconciler_generic 2>&1  # regression
```

**Tests:**
- `test_reconcile_release_artifact_with_sensed` — create entity with `_sensed.exists: true, uploaded: true`, reconcile, verify `action_taken=="none"` (confirms the loop closes)

**Phase 3 Complete When:**
- [ ] All existing tests pass
- [ ] 6 new tests pass in `storage_lifecycle.rs`
- [ ] `reconciler/release-artifact` reads `_sensed.exists` from entity data after R2 sense

---

## Files to Read

### The pattern to follow
- `crates/kosmos/src/storage.rs` — `execute_local()`, `local_stat()` `_entity_update` pattern
- `crates/kosmos/src/host.rs` — `dispatch_to_module` (line 1342), `apply_entity_update` (line 1326)

### What to change
- `crates/kosmos/src/r2.rs` — `execute_operation` (line 594), `R2Actuality` struct, `R2Provider` endpoint, `resolve_r2_credentials`
- `crates/kosmos/src/host.rs` — S3 stubs (s3-put-object, s3-head-object, s3-delete-object)

### Reference
- `genesis/dynamis/reconcilers/dynamis.yaml` — `reconciler/release-artifact` reads `_sensed.exists`

---

## Files to Touch

| File | Change |
|------|--------|
| `crates/kosmos/src/r2.rs` | **MODIFY** — add `_entity_update` to sense, manifest, unmanifest operations; optionally add endpoint flexibility for S3 |
| `crates/kosmos/src/host.rs` | **MODIFY** — replace 3 S3 stubs with one-liner delegations (~9 lines removed, 3 lines added) |
| `crates/kosmos/tests/storage_lifecycle.rs` | **NEW** — 6 tests |

---

## Success Criteria

**Phase 1 Complete When:**
- [ ] R2 sense (r2-head-object) returns `_entity_update` with `_sensed.exists` + metadata
- [ ] R2 manifest (r2-put-object) returns `_entity_update` with `actual_state: "manifested"`
- [ ] R2 unmanifest (r2-delete-object) returns `_entity_update` with `_sensed.exists: false`
- [ ] Local storage `_entity_update` unchanged (regression)

**Phase 2 Complete When:**
- [ ] S3 stoicheion dispatch through `dispatch_to_module` — not stubs
- [ ] S3 endpoint configurable

**Overall Complete When:**
- [ ] All existing tests pass
- [ ] 6 new tests pass in `storage_lifecycle.rs`
- [ ] `reconciler/release-artifact` can read `_sensed.exists` after R2 sense (loop closes)
- [ ] object-storage/r2 at stage 6 (fully autonomic)

---

## What This Enables

1. **object-storage/r2 advances to stage 6** — fully autonomic: sense closes the loop, reconciler reads actuality, dispatches correctly
2. **Release artifact reconciliation works** — `reconciler/release-artifact` reads `_sensed.exists` → compares to `uploaded` → correct action
3. **S3 provider operational** — same code path as R2, different endpoint — adding new S3-compatible storage requires only credential configuration
4. **Drift detection** — periodic sense → `_entity_update` → reflex detects divergence → reconcile — the full autonomic cycle for stored artifacts

---

## What Does NOT Change

1. **storage.rs routing** — already delegates r2/s3 to `r2::execute_operation()`
2. **Local filesystem operations** — fs-write-file, fs-stat-file, fs-delete-file already have correct `_entity_update`
3. **R2 typed functions** — `manifest()`, `sense()`, `unmanifest()` internals unchanged — only the wrapping in `execute_operation` changes
4. **AWS Signature V4 signing** — cryptographic implementation untouched
5. **reconciler/release-artifact** — already has correct transition table — just needs `_sensed` to be populated
6. **host.rs R2 dispatch** — already uses `dispatch_to_module` — just needs `_entity_update` in the return value

---

*Traces to: the sense-write-back principle (sensing without memory breaks the autonomic loop), the endpoint principle (providers are configuration not code), the `_entity_update` convention (universal contract for state changes), PROMPT-SUBSTRATE-STANDARD.md (substrate contract)*
