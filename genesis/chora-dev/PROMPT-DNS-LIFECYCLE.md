# DNS Lifecycle Completion — Closing the Sense Loop

*Prompt for Claude Code in the chora + kosmos repository context.*

*Adds `_entity_update` to DNS operations, creates a transition-table reconciler, wires reflexes for drift detection, and adds a daemon for periodic sensing. After this work, DNS records are fully autonomic — sense writes actuality back to entities, the reconciler aligns intent with actuality through `host.reconcile()`, and reflexes respond to drift. Advances dns-cloudflare from stage 3 to stage 6.*

*Depends on: PROMPT-SUBSTRATE-DNS.md (dispatch wiring), PROMPT-STORAGE-LIFECYCLE.md (established `_entity_update` pattern)*

---

## Architectural Principle — The Phylax Must Be Data

DNS already embodies the phylax (φύλαξ — guardian) pattern in prose. The DESIGN.md describes it. The praxis `dns/reconcile-record` implements it as code:

```
desired=present, actual=absent   → manifest
desired=present, actual=diverged → manifest (update)
desired=absent,  actual=present  → unmanifest
```

This is a transition table written as if-else logic inside a praxis. The problem: `host.reconcile()` can't read it. The generic reconciler engine reads transition tables from reconciler entities — `intent_field`, `actuality_field`, `transitions[]`. It doesn't parse praxis code.

Every other substrate moved from code-as-logic to data-as-logic:
- Cargo: `reconciler/build-target` replaced inline reconciliation
- Process: `reconciler/deployment` already existed as data
- Credential: `reconciler/credential` created from scratch
- Storage: `reconciler/release-artifact` already existed as data

DNS is the last substrate where reconciliation is code, not data. This prompt converts it.

The second gap: **DNS sense doesn't write back.** `dns::execute_operation("get", ...)` returns `DnsActuality` with `status`, `content`, `divergence` — but without `_entity_update`. The entity's `actual_state` is never updated by the sense operation. The reconciler reads stale data. This is the same gap R2 had before PROMPT-STORAGE-LIFECYCLE closed it.

---

## Methodology — DDD + TDD

This work follows **Doc → Test → Build → Verify**, non-negotiably.

1. **Doc (prescriptive)**: This prompt IS the prescriptive doc. The target state described here is what code must match.
2. **Test (assert the doc)**: Write tests that assert `_entity_update` presence in DNS operations, reconciler transitions, and dispatch wiring. Tests should fail before implementation.
3. **Build (satisfy the tests)**: Implement until tests pass.
4. **Verify doc**: After implementation, update success criteria to reflect completion. Check docs/REGISTRY.md impact map.

DNS operations make HTTP calls to Cloudflare's API. Tests that require real API credentials should be `#[ignore]`. Tests that verify `_entity_update` structure, reconciler transitions, and dispatch wiring use in-memory entities — no network required.

---

## Current State

### What Exists and Works

| Component | Location | Status |
|-----------|----------|--------|
| `dns::execute_operation()` | `dns.rs` | Working — 3 operations (create, get, delete), standard 4-param contract |
| Stoicheion dispatch | `host.rs` (cf-create/get/delete-record) | Working — all through `dispatch_to_module` |
| `mode/dns-cloudflare` | `genesis/dynamis/modes/dynamis.yaml:425` | Defined — stoicheion mapping for manifest/sense/unmanifest |
| `eidos/dns-record` | `genesis/thyra/dns/eide/dns.yaml` | Defined — **has `desired_state` and `actual_state`** already |
| `eidos/dns-zone` | Same file | Defined — zone management with provider binding |
| `eidos/dns-provider-binding` | Same file | Defined — credential reference for provider API |
| `praxis/dns/reconcile-record` | `genesis/thyra/praxeis/dns.yaml` | Defined — inline phylax logic (code, not data) |
| `praxis/dns/sense-record` | Same file | Defined — sense without entity update |
| Divergence detection | `dns.rs` sense operation | Working — compares expected vs actual content, returns `diverged` status |
| Cloudflare API integration | `dns.rs` | Working — create/update/delete/query via HTTP |

### What's Missing — The Four Gaps

**Gap 1: No `_entity_update` on DNS operations.** All three operations return direct result JSON without the `_entity_update` key. `dispatch_to_module()` → `apply_entity_update()` finds nothing to apply. Entity `actual_state`, `last_sensed_at`, `last_reconciled_at`, `provider_record_id`, `divergence` are never updated from sense/manifest results. The reconciler reads stale entity data.

**Gap 2: No transition-table reconciler.** `praxis/dns/reconcile-record` implements the phylax pattern as code — if/else on desired_state and actual_state. `host.reconcile()` requires a `reconciler/dns-record` entity with `intent_field`, `actuality_field`, and `transitions[]`. Without this entity, DNS can't participate in the generic reconciliation engine that every other substrate uses.

**Gap 3: No reflexes for DNS drift.** When a DNS record's `actual_state` changes (e.g., sense detects it was deleted externally), no reflex fires. No trigger watches `actual_state` on dns-record entities. Drift goes undetected until someone manually calls sense.

**Gap 4: No periodic sensing daemon.** DNS records can drift — someone modifies a record in the Cloudflare dashboard, or a record expires. Without periodic sensing, the kosmos doesn't know. Process has `daemon/sense-deployments`. Aither has `daemon/sense-syndesmos`. DNS has nothing.

---

## Target State

### DNS operations return `_entity_update`

**create (manifest):**
```rust
Ok(json!({
    "status": "present",
    "entity_id": entity_id,
    "stoicheion": "cf-create-record",
    "content": actuality.content,
    "provider_record_id": actuality.provider_record_id,
    "ttl": actuality.ttl,
    "proxied": actuality.proxied,
    "_entity_update": {
        "actual_state": "present",
        "provider_record_id": actuality.provider_record_id,
        "last_reconciled_at": chrono::Utc::now().to_rfc3339()
    }
}))
```

**get (sense):**
```rust
Ok(json!({
    "status": actuality.status,  // "present", "absent", "diverged", "unknown"
    "entity_id": entity_id,
    "stoicheion": "cf-get-record",
    "content": actuality.content,
    "provider_record_id": actuality.provider_record_id,
    "divergence": actuality.divergence,
    "_entity_update": {
        "actual_state": actuality.status,
        "provider_record_id": actuality.provider_record_id,
        "divergence": actuality.divergence,
        "last_sensed_at": chrono::Utc::now().to_rfc3339()
    }
}))
```

**delete (unmanifest):**
```rust
Ok(json!({
    "status": "unmanifested",
    "entity_id": entity_id,
    "stoicheion": "cf-delete-record",
    "deleted_record_id": record_id,
    "_entity_update": {
        "actual_state": "absent",
        "provider_record_id": null,
        "last_reconciled_at": chrono::Utc::now().to_rfc3339()
    }
}))
```

### Transition-table reconciler

```yaml
- eidos: reconciler
  id: reconciler/dns-record
  data:
    target_eidos: dns-record
    intent_field: desired_state
    actuality_field: actual_state
    transitions:
      # Want present, but absent or unknown → manifest (create at provider)
      - intent: present
        actual: [absent, unknown]
        action: manifest

      # Want present, but diverged → manifest (update at provider)
      - intent: present
        actual: diverged
        action: manifest

      # Want present, already present → sense (verify still correct)
      - intent: present
        actual: present
        action: sense

      # Want absent, but present or diverged → unmanifest (delete from provider)
      - intent: absent
        actual: [present, diverged]
        action: unmanifest

      # Want absent, already absent → none
      - intent: absent
        actual: [absent, unknown]
        action: none
```

### DNS reflexes

```yaml
# Trigger on desired_state change → reconcile
- eidos: trigger
  id: trigger/dns-record-intent-change
  data:
    watch_field: desired_state
    on_change: true
    target_eidos: dns-record

- eidos: reflex
  id: reflex/reconcile-dns-on-intent
  data:
    trigger: trigger/dns-record-intent-change
    action: reconcile
    reconciler_id: reconciler/dns-record

# Trigger on actual_state drift → reconcile
- eidos: trigger
  id: trigger/dns-record-drift
  data:
    watch_field: actual_state
    on_change: true
    target_eidos: dns-record

- eidos: reflex
  id: reflex/reconcile-dns-on-drift
  data:
    trigger: trigger/dns-record-drift
    action: reconcile
    reconciler_id: reconciler/dns-record
```

### Periodic sensing daemon

```yaml
- eidos: daemon
  id: daemon/sense-dns-records
  data:
    name: sense-dns-records
    description: |
      Periodically sense all dns-record entities to detect external drift.
      When a record is modified or deleted outside the kosmos,
      sensing updates actual_state, which triggers reconciliation.
    type: interval
    enabled: true
    scope: dwelling
    config:
      interval_ms: 300000  # 5 minutes — DNS changes are rare, respect rate limits
      target_eidos: dns-record
      action: sense
```

---

## Sequenced Work

### Phase 1: `_entity_update` Convention (Rust)

**Goal:** DNS operations return `_entity_update`, closing the sense loop.

**Tests:**
- `test_dns_create_returns_entity_update` — call `dns::execute_operation("create", ...)` with mock data, verify result contains `_entity_update.actual_state == "present"` and `_entity_update.provider_record_id`
- `test_dns_get_returns_entity_update` — call `execute_operation("get", ...)`, verify `_entity_update.actual_state` matches the sensed status and `_entity_update.last_sensed_at` is present
- `test_dns_delete_returns_entity_update` — call `execute_operation("delete", ...)`, verify `_entity_update.actual_state == "absent"` and `_entity_update.provider_record_id` is null

**Implementation:**

1. In `dns.rs` "create" arm, add `_entity_update` with `actual_state: "present"`, `provider_record_id`, `last_reconciled_at`
2. In `dns.rs` "get" arm, add `_entity_update` with `actual_state` (mapped from DnsActuality status), `provider_record_id`, `divergence`, `last_sensed_at`
3. In `dns.rs` "delete" arm, add `_entity_update` with `actual_state: "absent"`, `provider_record_id: null`, `last_reconciled_at`

**Phase 1 Complete When:**
- [ ] DNS create returns `_entity_update` with `actual_state: "present"` and `provider_record_id`
- [ ] DNS get returns `_entity_update` with `actual_state` mapped from sensed status
- [ ] DNS delete returns `_entity_update` with `actual_state: "absent"`
- [ ] `dispatch_to_module()` applies the updates to entity data

### Phase 2: Transition-Table Reconciler + Reflexes + Daemon (Genesis)

**Goal:** DNS has a data-driven reconciler, reflexes for drift response, and periodic sensing.

**Tests:**
- `test_dns_reconcile_absent_to_manifest` — create dns-record entity with desired_state=present, actual_state=absent, reconcile, verify action_taken=="manifest"
- `test_dns_reconcile_present_to_sense` — desired_state=present, actual_state=present → action_taken=="sense"
- `test_dns_reconcile_diverged_to_manifest` — desired_state=present, actual_state=diverged → action_taken=="manifest"
- `test_dns_reconcile_present_to_unmanifest` — desired_state=absent, actual_state=present → action_taken=="unmanifest"
- `test_dns_reconcile_absent_to_none` — desired_state=absent, actual_state=absent → action_taken=="none"

**Implementation:**

1. Create `genesis/thyra/dns/reconcilers/dns.yaml` with `reconciler/dns-record` (transition table)
2. Create `genesis/thyra/dns/reflexes/dns.yaml` with 2 triggers + 2 reflexes (intent-change, drift)
3. Create `genesis/thyra/dns/daemons/dns.yaml` with `daemon/sense-dns-records` (300s interval)
4. Update `genesis/thyra/dns/manifest.yaml` if needed to include new entity directories

**Phase 2 Complete When:**
- [ ] `reconciler/dns-record` exists with 5 transition rules
- [ ] `host.reconcile("reconciler/dns-record", entity_id)` returns correct action for all intent/actual combinations
- [ ] 2 triggers + 2 reflexes defined for intent-change and drift
- [ ] `daemon/sense-dns-records` defined with 300s interval

### Phase 3: Verify

**Goal:** Everything works together. DNS is fully autonomic.

```bash
cargo build -p kosmos 2>&1
cargo test -p kosmos --lib --tests 2>&1
cargo test -p kosmos --test dns_lifecycle 2>&1
cargo test -p kosmos --test dns_dispatch 2>&1   # regression
cargo test -p kosmos --test reconciler_generic 2>&1  # regression
```

**Phase 3 Complete When:**
- [ ] All existing tests pass (including dns_dispatch regression)
- [ ] 8 new tests pass in `dns_lifecycle.rs`
- [ ] dns-cloudflare at stage 6

---

## Files to Read

### Current implementation
- `crates/kosmos/src/dns.rs` — `execute_operation` (3 arms), `DnsActuality` struct, credential resolution
- `crates/kosmos/src/host.rs` — cf-create/get/delete dispatch arms

### Genesis (already prescribes intent/actuality)
- `genesis/thyra/dns/eide/dns.yaml` — `eidos/dns-record` with `desired_state`, `actual_state`, `divergence`
- `genesis/thyra/dns/DESIGN.md` — phylax pattern description
- `genesis/thyra/praxeis/dns.yaml` — `praxis/dns/reconcile-record` (inline logic, to be complemented by reconciler entity)

### Pattern reference
- `genesis/dynamis/reconcilers/dynamis.yaml` — transition-table format (reconciler/deployment, reconciler/release-artifact)
- `genesis/dynamis/reflexes/reflexes.yaml` — trigger/reflex pattern (deployment-intent-change)

---

## Files to Touch

| File | Change |
|------|--------|
| `crates/kosmos/src/dns.rs` | **MODIFY** — add `_entity_update` to create, get, delete operations |
| `genesis/thyra/dns/reconcilers/dns.yaml` | **NEW** — `reconciler/dns-record` with transition table |
| `genesis/thyra/dns/reflexes/dns.yaml` | **NEW** — 2 triggers + 2 reflexes for intent-change and drift |
| `genesis/thyra/dns/daemons/dns.yaml` | **NEW** — `daemon/sense-dns-records` (300s interval) |
| `crates/kosmos/tests/dns_lifecycle.rs` | **NEW** — 8 tests |

---

## Success Criteria

**Phase 1 Complete When:**
- [ ] All DNS operations return `_entity_update`
- [ ] Entity `actual_state`, `provider_record_id`, `divergence` updated by sense

**Phase 2 Complete When:**
- [ ] Transition-table `reconciler/dns-record` exists
- [ ] Reflexes fire on intent-change and drift
- [ ] Daemon defined for periodic sensing

**Overall Complete When:**
- [ ] All existing tests pass
- [ ] 8 new tests pass in `dns_lifecycle.rs`
- [ ] dns-cloudflare at stage 6 (fully autonomic)
- [ ] `host.reconcile("reconciler/dns-record", entity_id)` dispatches correct actions

---

## What This Enables

1. **DNS fully autonomic** — sense writes back, reconciler compares, reflexes respond — the complete loop
2. **External drift detection** — someone modifies a Cloudflare record through the dashboard → daemon senses → `actual_state: "diverged"` → reflex fires → reconciler restores intent
3. **Infrastructure-as-code** — DNS records are entities with `desired_state`. Create a dns-record entity with `desired_state: "present"` → reconciler creates it. Set `desired_state: "absent"` → reconciler deletes it.
4. **Generic reconciliation** — DNS uses the same `host.reconcile()` engine as process, cargo, credential, storage. One engine, many substrates.
5. **Zone-level reconciliation** — with per-record reconciliation working, `praxis/dns/reconcile-zone` can gather all records and reconcile each through the generic engine

---

## What Does NOT Change

1. **dns.rs internals** — `manifest()`, `sense()`, `unmanifest()` functions unchanged. Cloudflare API integration unchanged. Only the wrapping in `execute_operation()` gains `_entity_update`.
2. **host.rs dispatch** — cf-create/get/delete already use `dispatch_to_module`. No change needed.
3. **`eidos/dns-record`** — already has `desired_state`, `actual_state`, `divergence`, `provider_record_id`, `last_sensed_at`, `last_reconciled_at`. No schema changes needed.
4. **`praxis/dns/reconcile-record`** — stays as-is. It implements inline reconciliation for direct praxis invocation. The new `reconciler/dns-record` complements it for the generic engine path.
5. **Credential resolution** — `resolve_credential("cloudflare-dns", session)` unchanged.
6. **Other substrates** — cargo, process, storage, credential untouched.

---

*Traces to: the phylax pattern (guardian reconciliation — data, not code), the sense-write-back principle (sensing without memory breaks the loop), the autonomic triad (sensing + reactivity + reconciliation), PROMPT-SUBSTRATE-DNS.md (dispatch wiring), PROMPT-STORAGE-LIFECYCLE.md (`_entity_update` convention)*
