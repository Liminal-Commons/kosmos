# Storage Dispatch Convention — One Right Way

*Prompt for Claude Code in the chora + kosmos repository context.*

*Fixes `_entity_update` convention violations in storage operations. `local_write` and `local_delete` gain `_entity_update`. Four host.rs arms gain `dispatch_to_module` wrapping. After this work, every storage stoicheion follows the same convention: operation returns `_entity_update`, host arm applies it through `dispatch_to_module`. Object-storage-local advances from stage 3 to stage 6.*

*Depends on: PROMPT-STORAGE-LIFECYCLE.md, PROMPT-SUBSTRATE-S3.md*

---

## Architectural Principle — No Variance in Convention

Every stage 6 substrate follows one convention:

```
operation returns _entity_update → host arm wraps with dispatch_to_module → apply_entity_update merges to entity
```

No exceptions. Not "sense covers it eventually." Not "the reconciler works through the sense pathway." If an operation changes state in chora, it reports that change back through `_entity_update`. If a host arm dispatches to a substrate module, it wraps with `dispatch_to_module`.

Six violations exist today, all in the storage substrate:

| Stoicheion | Returns `_entity_update`? | Uses `dispatch_to_module`? |
|------------|--------------------------|---------------------------|
| `fs-write-file` | NO | NO |
| `fs-stat-file` | YES | YES |
| `fs-delete-file` | NO | NO |
| `r2-put-object` | YES | YES |
| `r2-head-object` | YES | YES |
| `r2-delete-object` | YES | **NO** |
| `s3-put-object` | YES | YES |
| `s3-head-object` | YES | YES |
| `s3-delete-object` | YES | **NO** |

Two operations lack `_entity_update` entirely (local write, local delete). Two operations return `_entity_update` but the host arm doesn't apply it (R2 delete, S3 delete). The result is the same: entity data is stale after the operation.

---

## Methodology — DDD + TDD

This work follows **Doc → Test → Build → Verify**, non-negotiably.

1. **Doc (prescriptive)**: This prompt IS the prescriptive doc. The target state described here is what code must match.
2. **Test (assert the doc)**: Write tests that assert `_entity_update` presence in local write and delete operations. Tests should fail before implementation.
3. **Build (satisfy the tests)**: Implement until tests pass.
4. **Verify doc**: After implementation, update success criteria to reflect completion.

All tests use the local filesystem — no network, no credentials, no `#[ignore]`.

---

## Current State

### What Exists and Works

| Component | Location | Status |
|-----------|----------|--------|
| `local_write()` | `storage.rs:58` | Working — writes file, computes BLAKE3 hash, returns `status: "manifested"` |
| `local_stat()` | `storage.rs:112` | Working — returns `_entity_update` with `_sensed.exists`, content hash |
| `local_delete()` | `storage.rs:172` | Working — deletes file, returns `status: "unmanifested"` |
| `fs-write-file` host arm | `host.rs:1373` | Working — calls `storage::execute_operation` directly |
| `fs-stat-file` host arm | `host.rs:1554` | Working — wraps with `dispatch_to_module` |
| `fs-delete-file` host arm | `host.rs:1725` | Working — calls `storage::execute_operation` directly |
| R2 delete | `r2.rs:729` | Working — returns `_entity_update` with `_sensed.exists: false` |
| `r2-delete-object` host arm | `host.rs:1726` | Working — calls `storage::execute_operation` directly |
| `s3-delete-object` host arm | `host.rs:1727` | Working — calls `storage::execute_operation` directly |

### What's Missing — The Two Gaps

**Gap 1: `local_write()` and `local_delete()` return no `_entity_update`.** After writing a file, the entity doesn't know the file exists. After deleting a file, the entity doesn't know it's gone. The information is computed (BLAKE3 hash, size) but not fed back to the entity. The sense operation covers it eventually, but "eventually" is variance.

**Gap 2: Three host arms skip `dispatch_to_module`.** `fs-write-file`, `fs-delete-file`, `r2-delete-object`, and `s3-delete-object` call the substrate module directly without wrapping. Even when the operation returns `_entity_update` (R2/S3 delete do), the update is never applied because `dispatch_to_module` → `apply_entity_update` is the mechanism that merges it into entity data.

---

## Target State

### `local_write()` returns `_entity_update`

```rust
Ok(json!({
    "status": "manifested",
    "entity_id": entity_id,
    "stoicheion": "fs-write-file",
    "mode": "object-storage",
    "provider": "local",
    "path": target_path,
    "content_hash": content_hash,
    "size_bytes": bytes_written,
    "_entity_update": {
        "_sensed": {
            "exists": true,
            "size_bytes": bytes_written,
            "content_hash": content_hash,
        },
        "actual_state": "manifested",
        "last_reconciled_at": chrono::Utc::now().to_rfc3339()
    }
}))
```

### `local_delete()` returns `_entity_update`

```rust
Ok(json!({
    "status": "unmanifested",
    "entity_id": entity_id,
    "stoicheion": "fs-delete-file",
    "mode": "object-storage",
    "provider": "local",
    "path": target_path,
    "_entity_update": {
        "_sensed": { "exists": false },
        "actual_state": "unmanifested",
        "last_reconciled_at": chrono::Utc::now().to_rfc3339()
    }
}))
```

### All storage host arms use `dispatch_to_module`

```rust
// manifest_by_stoicheion:
"fs-write-file" => self.dispatch_to_module(entity_id, data,
    crate::storage::execute_operation("write", entity_id, data, session_ref)),

// unmanifest_by_stoicheion:
"fs-delete-file" => self.dispatch_to_module(entity_id, data,
    crate::storage::execute_operation("delete", entity_id, data, session_ref)),
"r2-delete-object" => self.dispatch_to_module(entity_id, data,
    crate::storage::execute_operation("delete", entity_id, &inject_provider(data, "r2"), session_ref)),
"s3-delete-object" => self.dispatch_to_module(entity_id, data,
    crate::storage::execute_operation("delete", entity_id, &inject_provider(data, "s3"), session_ref)),
```

---

## Sequenced Work

### Phase 1: `_entity_update` on Local Operations (Rust)

**Goal:** `local_write()` and `local_delete()` return `_entity_update`, matching the convention.

**Tests:**
- `test_local_write_returns_entity_update` — call `storage::execute_operation("write", ...)` with `provider: "local"`, write a temp file, verify result contains `_entity_update._sensed.exists == true` and `_entity_update._sensed.content_hash`
- `test_local_delete_returns_entity_update` — write a temp file, then call `execute_operation("delete", ...)`, verify `_entity_update._sensed.exists == false` and `_entity_update.actual_state == "unmanifested"`
- `test_local_write_entity_update_matches_stat` — write a file, verify `_entity_update._sensed` from write matches `_entity_update._sensed` from subsequent stat (same hash, same size)

**Implementation:**

1. In `storage.rs` `local_write()`, add `_entity_update` with `_sensed.exists: true`, `_sensed.size_bytes`, `_sensed.content_hash`, `actual_state: "manifested"`, `last_reconciled_at`
2. In `storage.rs` `local_delete()`, add `_entity_update` with `_sensed.exists: false`, `actual_state: "unmanifested"`, `last_reconciled_at`

**Phase 1 Complete When:**
- [ ] `local_write()` returns `_entity_update` with `_sensed` and `actual_state`
- [ ] `local_delete()` returns `_entity_update` with `_sensed` and `actual_state`
- [ ] Write `_entity_update._sensed` matches subsequent stat `_entity_update._sensed`

### Phase 2: `dispatch_to_module` Wrapping (Rust)

**Goal:** All storage host arms use `dispatch_to_module`, applying `_entity_update` to entities.

**Tests:**
- `test_local_write_dispatch_applies_update` — bootstrap, create entity, call `manifest_by_stoicheion("fs-write-file", ...)`, verify entity data contains `_sensed.exists == true` after the call
- `test_local_delete_dispatch_applies_update` — bootstrap, create entity with file, call `unmanifest_by_stoicheion("fs-delete-file", ...)`, verify entity data contains `_sensed.exists == false`

**Implementation:**

1. In `host.rs` `manifest_by_stoicheion`, change `fs-write-file` to use `self.dispatch_to_module(...)`
2. In `host.rs` `unmanifest_by_stoicheion`, change `fs-delete-file` to use `self.dispatch_to_module(...)`
3. In `host.rs` `unmanifest_by_stoicheion`, change `r2-delete-object` to use `self.dispatch_to_module(...)`
4. In `host.rs` `unmanifest_by_stoicheion`, change `s3-delete-object` to use `self.dispatch_to_module(...)`

**Phase 2 Complete When:**
- [ ] All 4 arms use `dispatch_to_module`
- [ ] No storage arm in host.rs calls `execute_operation` without `dispatch_to_module` wrapping

### Phase 3: Verify

**Goal:** All tests pass. Convention is uniform.

```bash
cargo build -p kosmos 2>&1
cargo test -p kosmos --lib --tests 2>&1
cargo test -p kosmos --test storage_lifecycle 2>&1  # regression
cargo test -p kosmos --test local_storage_convention 2>&1
```

**Phase 3 Complete When:**
- [ ] All existing tests pass (including storage_lifecycle regression)
- [ ] 5 new tests pass
- [ ] Every storage stoicheion arm in host.rs uses `dispatch_to_module`

---

## Files to Read

### Current implementation
- `crates/kosmos/src/storage.rs` — `local_write` (no `_entity_update`), `local_stat` (has `_entity_update`), `local_delete` (no `_entity_update`)
- `crates/kosmos/src/host.rs` — storage arms in `manifest_by_stoicheion` (line 1373), `sense_by_stoicheion` (line 1554), `unmanifest_by_stoicheion` (line 1725)

### Convention reference
- `crates/kosmos/src/r2.rs` — R2 upload (line 698) and sense (line 703) as correct `_entity_update` examples
- `crates/kosmos/src/host.rs` — `dispatch_to_module` method, `apply_entity_update` method

---

## Files to Touch

| File | Change |
|------|--------|
| `crates/kosmos/src/storage.rs` | **MODIFY** — add `_entity_update` to `local_write()` and `local_delete()` |
| `crates/kosmos/src/host.rs` | **MODIFY** — wrap `fs-write-file`, `fs-delete-file`, `r2-delete-object`, `s3-delete-object` with `dispatch_to_module` |
| `crates/kosmos/tests/local_storage_convention.rs` | **NEW** — 5 tests |

---

## Success Criteria

**Phase 1 Complete When:**
- [ ] `local_write()` and `local_delete()` return `_entity_update`

**Phase 2 Complete When:**
- [ ] All storage host arms use `dispatch_to_module`

**Overall Complete When:**
- [ ] All existing tests pass
- [ ] 5 new tests pass in `local_storage_convention.rs`
- [ ] Object-storage-local at stage 6
- [ ] Zero storage arms in host.rs call `execute_operation` without `dispatch_to_module`

---

## What This Enables

1. **One convention** — every storage operation, every provider, same pattern: return `_entity_update`, host applies it
2. **Immediate entity state** — after `local_write()`, the entity knows the file exists *now*, not after the next sense cycle
3. **Correct R2/S3 delete** — `_entity_update` already exists in the operation result but was silently discarded. Now it's applied.
4. **Object-storage-local stage 6** — modes + dispatch + `_entity_update` + reconciler + reflexes + daemon. Complete.

---

## What Does NOT Change

1. **`local_stat()`** — already correct. Already returns `_entity_update`. Already uses `dispatch_to_module`.
2. **R2/S3 upload and sense** — already correct. Already return `_entity_update`. Already use `dispatch_to_module`.
3. **Reconciler** — `reconciler/release-artifact` unchanged. Reads `_sensed.exists` which is now written by all three operations, not just sense.
4. **Reflexes and daemon** — already exist and work. No changes needed.
5. **Other substrates** — DNS, process, cargo, credential untouched.

---

*Traces to: the convention principle (one right way — no variance in how operations report state), the `_entity_update` contract (every operation that changes state reports it), the dispatch wrapping principle (`dispatch_to_module` is the mechanism, not optional), PROMPT-STORAGE-LIFECYCLE.md*
