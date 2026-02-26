# Credential Lifecycle — From Utility to Substrate

*Prompt for Claude Code in the chora + kosmos repository context.*

*Elevates credentials from a utility module (helper functions called by other substrates) to a full substrate with modes, stoicheion dispatch, reconciler, and reflexes. Adds credential health sensing (expiry, validity). After this work, credentials are entities with lifecycle — storable, sensable, reconcilable — visible to the autonomic loop. Advances credential from stage 1 to stage 6.*

*Depends on: PROMPT-SUBSTRATE-STANDARD.md, PROMPT-SUBSTRATE-DNS.md*

---

## Architectural Principle — If It Has State, It Is an Entity

Today, credential.rs serves two roles:

1. **Utility**: `resolve_credential("cloudflare-dns", session)` — called by DNS, R2, and other modules to get API tokens. This works. It stays.
2. **Substrate module**: `execute_operation("store", entity_id, data, session)` — five operations (unlock, store, retrieve, list, lock) that follow the standard contract. This also works.

But there is no connection between these operations and the mode dispatch pattern. No modes are defined in genesis. No stoicheion exists in mode_dispatch.rs. No reconciler watches credential health. No reflex fires when a credential expires.

This means credentials are invisible to the autonomic loop. When an API key expires, nothing detects it. When a credential is stored, no entity updates. When the keyring locks, no reflex fires. Credentials exist as a utility function call, not as entities with lifecycle.

**If something has state that can change (locked/unlocked, valid/expired, present/absent), it is an entity with a lifecycle, not a utility function.** Making it visible to the mode dispatch pattern means making it governable — reconcilers can heal it, reflexes can respond to it, the world can know about it.

---

## The Trust Lifecycle

Credentials don't just exist or not-exist. They have a trust lifecycle:

```
absent → stored → unlocked → active → expired → revoked
```

Each transition has meaning:
- **absent → stored**: A credential entity was created with encrypted value
- **stored → unlocked**: The keyring was unlocked, credential decrypted into session memory
- **unlocked → active**: The credential was used successfully (API returned 200, not 401)
- **active → expired**: The credential's TTL elapsed or the API rejected it
- **expired → revoked**: Explicitly removed

The reconciler's job is to maintain the desired trust state. If a credential should be "active" but sensing reveals it's "expired" (API returns 401), the reconciler can't fix it automatically — but it can update the entity state, trigger a reflex, and surface the problem.

---

## Methodology — DDD + TDD

This work follows **Doc → Test → Build → Verify**, non-negotiably.

1. **Doc (prescriptive)**: This prompt IS the prescriptive doc. The target state described here is what code must match.
2. **Test (assert the doc)**: Write tests that assert `_entity_update` presence in credential operations, stoicheion dispatch wiring, and reconciler transitions. Tests should fail before implementation.
3. **Build (satisfy the tests)**: Implement until tests pass.
4. **Verify doc**: After implementation, update success criteria to reflect completion. Check docs/REGISTRY.md impact map.

Credential operations depend on `SessionBridge` for keychain access. Tests that require actual keychain interaction should use `TestSessionBridge` or be `#[ignore]`. Reconciler and dispatch-wiring tests use in-memory entities.

---

## Current State

### What Exists and Works

| Component | Location | Status |
|-----------|----------|--------|
| credential.rs operations | `credential.rs` (5 operations) | Working — unlock, store, retrieve, list, lock |
| `resolve_credential()` helper | `credential.rs` | Working — called by DNS, R2, other modules |
| credential eidos | `genesis/credentials/eide/credentials.yaml` | Defined — has `service`, `credential_type`, `encrypted_value`, `salt`, `grants_attainment` |
| credential-attainment eidos | Same file | Defined — has `expires_at` timestamp |
| credential praxeis | `genesis/credentials/praxeis/credentials.yaml` | Defined — store-credential, unlock-credential, etc. |
| Attainment integration | Attainment authorization bonds | Working — `grants-praxis` / `requires-attainment` |

### What's Missing — The Gaps

**Gap 1: No modes in genesis.** No mode entities for credential operations exist. `mode_dispatch.rs` has no `("credential", ...)` entries. Credential operations are called directly from praxis execution, bypassing mode dispatch entirely.

**Gap 2: No stoicheion dispatch.** No `keyring-*` match arms exist in `manifest_by_stoicheion`, `sense_by_stoicheion`, or `unmanifest_by_stoicheion` in host.rs. Credential operations cannot participate in the actuality loop.

**Gap 3: No `_entity_update` in operations.** All five credential operations return standard `{ status, entity_id, stoicheion }` but do NOT include `_entity_update`. The keyring state lives in the SessionBridge (in-memory), not in entity data. State changes are invisible to the graph.

**Gap 4: No lifecycle fields on eidos.** The credential eidos has no `mode`, `provider`, `desired_state`, `actual_state`, `last_verified_at`, or `actuality` block. Without these, entities cannot be reconciled.

**Gap 5: No reconciler or reflexes.** No `reconciler/credential` exists. No reflexes fire on credential state changes or expiry. Credential drift is undetected.

---

## Target State

### Credential mode defined in genesis

```yaml
- eidos: mode
  id: mode/credential-keyring
  data:
    name: credential-keyring
    mode: credential
    provider: keyring
    stoicheion:
      manifest: keyring-store
      sense: keyring-check
      unmanifest: keyring-revoke
    description: |
      Credential lifecycle through the system keyring.
      Manifest stores encrypted credential. Sense checks validity.
      Unmanifest revokes and removes.
```

Generated in `mode_dispatch.rs`:
```rust
("credential", "keyring", ModeOperation::Manifest) => Some("keyring-store"),
("credential", "keyring", ModeOperation::Sense) => Some("keyring-check"),
("credential", "keyring", ModeOperation::Unmanifest) => Some("keyring-revoke"),
```

### Credential eidos with lifecycle fields

```yaml
# Added to eidos/credential:
mode:
  type: string
  default: "credential"
provider:
  type: string
  default: "keyring"
desired_state:
  type: enum
  values: [active, locked, revoked]
  default: "active"
  required: true
actual_state:
  type: string
  required: false
last_verified_at:
  type: timestamp
  required: false
expires_at:
  type: timestamp
  required: false
actuality:
  mode: credential
```

### Credential operations return `_entity_update`

```rust
// store operation:
"_entity_update": {
    "actual_state": "stored",
    "last_reconciled_at": now
}

// check operation (sense — new alias):
"_entity_update": {
    "actual_state": "active" | "absent",
    "last_verified_at": now
}

// lock/revoke operation (unmanifest):
"_entity_update": {
    "actual_state": "locked",
    "last_reconciled_at": now
}
```

### Stoicheion dispatch in host.rs

```rust
// manifest_by_stoicheion:
"keyring-store" => self.dispatch_to_module(entity_id, data,
    crate::credential::execute_operation("store", entity_id, data, session_ref)),

// sense_by_stoicheion:
"keyring-check" => self.dispatch_to_module(entity_id, data,
    crate::credential::execute_operation("check", entity_id, data, session_ref)),

// unmanifest_by_stoicheion:
"keyring-revoke" => self.dispatch_to_module(entity_id, data,
    crate::credential::execute_operation("revoke", entity_id, data, session_ref)),
```

### Transition-table reconciler

```yaml
- eidos: reconciler
  id: reconciler/credential
  data:
    target_eidos: credential
    intent_field: desired_state
    actuality_field: actual_state
    transitions:
      - intent: active
        actual: [absent, locked, stored]
        action: manifest
      - intent: active
        actual: active
        action: sense
      - intent: locked
        actual: [active, stored]
        action: unmanifest
      - intent: locked
        actual: [locked, absent]
        action: none
      - intent: revoked
        actual: [active, stored, locked]
        action: unmanifest
      - intent: revoked
        actual: [absent, revoked]
        action: none
```

---

## Sequenced Work

### Phase 1: Genesis — Modes, Eidos Fields, Reconciler, Reflexes

**Goal:** Credential entities have intent, modes exist, reconciler has transition table, reflexes wire state changes.

**Tests:**
- `test_credential_reconcile_absent_to_manifest` — create credential entity with desired_state=active, actual_state=absent, reconcile, verify action_taken=="manifest"
- `test_credential_reconcile_active_to_sense` — desired_state=active, actual_state=active → action_taken=="sense"
- `test_credential_reconcile_locked_to_none` — desired_state=locked, actual_state=locked → action_taken=="none"
- `test_credential_stoicheion_dispatch` — bootstrap, verify `mode_dispatch("credential", "keyring", Manifest)` returns `Some("keyring-store")`

**Implementation:**

1. Create `genesis/credentials/modes/credential-modes.yaml` with `mode/credential-keyring`
2. Add `mode`, `provider`, `desired_state`, `actual_state`, `last_verified_at`, `expires_at`, and `actuality` to credential eidos in `genesis/credentials/eide/credentials.yaml`
3. Create `genesis/credentials/reconcilers/credential.yaml` with `reconciler/credential` (transition-table)
4. Create `genesis/credentials/reflexes/credential-reflexes.yaml` with trigger/credential-state-change + reflex/reconcile-credential-drift, and trigger/credential-expiry + reflex/sense-expired-credential

**Phase 1 Complete When:**
- [ ] `mode/credential-keyring` exists in genesis → generates dispatch table entries
- [ ] Credential eidos has `desired_state`, `actual_state`, `mode`, `provider`, `last_verified_at`, `expires_at`
- [ ] `reconciler/credential` exists with transition table
- [ ] Credential reflexes exist for state change and expiry
- [ ] `host.reconcile("reconciler/credential", entity_id)` returns correct action

### Phase 2: `_entity_update` Convention + Stoicheion Dispatch (Rust)

**Goal:** Credential operations return `_entity_update`. Stoicheion dispatch wired in host.rs.

**Tests:**
- `test_credential_store_entity_update` — call `execute_operation("store", ...)` with valid session, verify `_entity_update.actual_state == "stored"`
- `test_credential_check_entity_update` — store a credential, then check, verify `_entity_update.actual_state == "active"` or `"absent"`
- `test_credential_lock_entity_update` — call lock operation, verify `_entity_update.actual_state == "locked"`

**Implementation:**

1. Add `_entity_update` to each credential operation in `credential.rs`:
   - **store**: `_entity_update.actual_state = "stored"`
   - **unlock**: `_entity_update.actual_state = "unlocked" | "locked"`
   - **retrieve/check**: `_entity_update.actual_state = "active" | "absent"`, `_entity_update.last_verified_at = now`
   - **lock/revoke**: `_entity_update.actual_state = "locked"`
2. Add `"check"` as alias for `"retrieve"` that returns `_entity_update` but does NOT include the credential value in the response (sense should not leak secrets)
3. Add `keyring-store`, `keyring-check`, `keyring-revoke` match arms to host.rs `manifest_by_stoicheion`, `sense_by_stoicheion`, `unmanifest_by_stoicheion`

**Important**: The existing `"retrieve"` operation that returns credential values must remain as-is for backward compatibility. The new `"check"` alias provides the same `_entity_update` but omits the secret value.

**Phase 2 Complete When:**
- [ ] All credential operations return `_entity_update`
- [ ] `"check"` alias exists for sense-safe credential verification
- [ ] `keyring-store`, `keyring-check`, `keyring-revoke` match arms in host.rs
- [ ] `dispatch_to_module` wiring for all three stoicheion

### Phase 3: Verify

**Goal:** Everything works together. Credential substrate is fully autonomic.

```bash
cargo build -p kosmos 2>&1
cargo test -p kosmos --lib --tests 2>&1
cargo test -p kosmos --test credential_lifecycle 2>&1
cargo test -p kosmos --test reconciler_generic 2>&1  # regression
```

**Phase 3 Complete When:**
- [ ] All existing tests pass
- [ ] 7 new tests pass in `credential_lifecycle.rs`
- [ ] `resolve_credential()` unchanged (backward compatible)

---

## Files to Read

### Current implementation
- `crates/kosmos/src/credential.rs` — current operations, `resolve_credential` helper
- `crates/kosmos/src/host.rs` — dispatch methods (no credential arms yet), `SessionBridge` trait

### Dispatch convention (the pattern to follow)
- `crates/kosmos/src/host.rs` — `dispatch_to_module` (line 1342), `apply_entity_update` (line 1326)
- `crates/kosmos/src/process.rs` — `_entity_update` convention examples

### Genesis
- `genesis/credentials/eide/credentials.yaml` — current eidos definition
- `genesis/credentials/praxeis/credentials.yaml` — existing praxeis
- `genesis/dynamis/reconcilers/dynamis.yaml` — correct transition-table format (reference)
- `crates/kosmos/src/mode_dispatch.rs` — no credential entries yet

---

## Files to Touch

| File | Change |
|------|--------|
| `genesis/credentials/modes/credential-modes.yaml` | **NEW** — `mode/credential-keyring` with stoicheion mapping |
| `genesis/credentials/eide/credentials.yaml` | **MODIFY** — add `mode`, `provider`, `desired_state`, `actual_state`, `last_verified_at`, `expires_at`, `actuality` |
| `genesis/credentials/reconcilers/credential.yaml` | **NEW** — `reconciler/credential` with transition table |
| `genesis/credentials/reflexes/credential-reflexes.yaml` | **NEW** — triggers and reflexes for credential lifecycle |
| `crates/kosmos/src/credential.rs` | **MODIFY** — add `_entity_update` to all operations, add `"check"` alias |
| `crates/kosmos/src/host.rs` | **MODIFY** — add `keyring-store`/`keyring-check`/`keyring-revoke` match arms |
| `crates/kosmos/tests/credential_lifecycle.rs` | **NEW** — 7 tests |

---

## Success Criteria

**Phase 1 Complete When:**
- [ ] Credential mode defined in genesis → generated in `mode_dispatch.rs`
- [ ] Credential eidos has lifecycle fields
- [ ] `reconciler/credential` exists with transition table
- [ ] Credential reflexes defined

**Phase 2 Complete When:**
- [ ] All credential operations return `_entity_update`
- [ ] Stoicheion dispatch wired in host.rs

**Overall Complete When:**
- [ ] All existing tests pass
- [ ] 7 new tests pass in `credential_lifecycle.rs`
- [ ] `resolve_credential()` helper unchanged (backward compatible)
- [ ] Credential substrate at stage 6 (fully autonomic)

---

## What This Enables

1. **Credential substrate fully autonomic** — modes → dispatch → reconciler → reflexes — the complete cycle
2. **Credential health monitoring** — periodic sensing can verify credentials are still valid (API responds 200, not 401)
3. **Expiry awareness** — when a time-limited token expires, the reflex detects it and surfaces the state change
4. **Credential drift detection** — if a credential is revoked externally, sensing detects the change and updates entity state
5. **Self-documenting lifecycle** — the transition table declares what should happen in every (intent, actual) combination — no implicit logic

---

## What Does NOT Change

1. **resolve_credential()** — the ergonomic helper called by other substrate modules stays as-is
2. **SessionBridge trait** — the keychain interface doesn't change — credential.rs still calls session methods
3. **Environment variable fallback** — headless/CI credential resolution unchanged
4. **Existing praxeis** — store-credential, unlock-credential, etc. stay — they call `execute_operation`
5. **Attainment integration** — `grants-praxis` bonds and attainment authorization unchanged

---

## Scope Boundaries

**In scope**: Mode definition, eidos lifecycle fields, `_entity_update` convention, stoicheion dispatch, reconciler, reflexes.

**Out of scope**: External credential validation (calling the actual API to verify a key works). The `"check"` operation verifies that the credential exists in the keyring — actual API validation is a future enhancement that would require knowing the API endpoint for each service.

**Out of scope**: Credential rotation (automatically generating new credentials when old ones expire). This is a future capability that builds on the lifecycle infrastructure this prompt establishes.

---

*Traces to: the entity principle (if it has state that changes, it's an entity with lifecycle), the trust lifecycle (credentials aren't binary exist/not-exist — they have a trust progression), the autonomic loop (sense→compare→act applied to credential health), PROMPT-SUBSTRATE-STANDARD.md*
