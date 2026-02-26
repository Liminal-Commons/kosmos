# PROMPT-STORAGE-GENESIS-CLEANUP — Wire release artifacts through generic mode dispatch

*Prompt for Claude Code in the chora + kosmos repository context.*

*After this work, release-artifact entities carry `mode: object-storage` and `provider` in their data, stoicheion dispatch handles all R2/S3/local operations, the duplicate reconciler definitions are consolidated, and the legacy eidos-specific match arms in host.rs are removed. Storage modes advance from "functional but legacy-wired" to "fully generic."*

---

## Architectural Principle — One Dispatch Path

> resolve_mode() reads `mode` and `provider` from entity data → stoicheion_for_mode() returns the stoicheion name → manifest/sense/unmanifest_by_stoicheion() dispatches to module code.

This is the generic path. Every dynamis entity should follow it. When an entity lacks `mode`/`provider` fields, `resolve_mode()` returns `None` and dispatch falls through to the eidos-specific `match eidos { ... }` arms — a legacy bypass.

Release-artifact entities currently lack `mode`/`provider` in their data because `typos-def-release-artifact` only defaults `uploaded: false`. The R2 implementation works, but through the wrong door. The stoicheion dispatch table has the entries (`r2-put-object`, `r2-head-object`, `r2-delete-object`). The module code handles them. The only gap is that entities don't carry the fields that `resolve_mode()` reads.

Additionally, two reconciler entities target the same eidos with identical transition logic: `reconciler/release-artifact` (dynamis topos) and `reconciler/release-distribution` (release topos). Both compare `uploaded` vs `_sensed.exists`. Both are referenced by their own reflexes. This duplication means reconciliation can fire twice for the same entity.

---

## Methodology — DDD + TDD

This work follows **Doc → Test → Build → Verify**, non-negotiably.

1. **Doc (prescriptive)**: This prompt IS the prescriptive doc.
2. **Test (assert the doc)**: Write tests that assert release-artifact entities dispatch through stoicheion, not eidos-specific arms.
3. **Build (satisfy the tests)**: Fix typos defaults, consolidate reconciler, remove legacy arms.
4. **Verify doc**: Check docs/REGISTRY.md impact map.

Pure wiring fix — no new substrate implementations. The R2 module code (`r2.rs`) does not change. The S3 stubs do not change. Only the dispatch routing changes.

---

## Current State

### What Exists and Works

| Component | Location | Status |
|-----------|----------|--------|
| Mode dispatch entries (R2) | `crates/kosmos/src/mode_dispatch.rs:65-67` | Working — `("object-storage", "r2", op)` → stoicheion names |
| Mode dispatch entries (S3) | `crates/kosmos/src/mode_dispatch.rs:68-70` | Working — entries exist |
| Mode dispatch entries (local) | `crates/kosmos/src/mode_dispatch.rs:71-73` | Working — entries exist |
| Stoicheion routing (R2) | `crates/kosmos/src/host.rs:1375,1565,1744` | Working — `r2-put-object` etc. route to `dispatch_to_module()` |
| R2 module implementation | `crates/kosmos/src/r2.rs` | Working — real HTTP calls to Cloudflare R2 |
| Typos definition | `genesis/dynamis/typos/dynamis.yaml` `typos-def-release-artifact` | Defined — defaults only `uploaded: false` |
| Reconciler (dynamis) | `genesis/dynamis/reconcilers/dynamis.yaml` `reconciler/release-artifact` | Defined — `uploaded` vs `_sensed.exists` |
| Reconciler (release) | `genesis/release/reconcilers/reconcilers.yaml` `reconciler/release-distribution` | Defined — identical logic, different id |
| Intent-changed reflex | `genesis/dynamis/reflexes/reflexes.yaml` `reflex/dynamis/release-artifact-intent-changed` | Defined — invokes `reconciler/release-artifact` |
| Drift reflex (release) | `genesis/release/reflexes/reflexes.yaml` `reflex/release/distribution-drift` | Defined — invokes `reconciler/release-distribution` |
| Sensing daemon | `genesis/release/daemons/daemons.yaml` `daemon/sense-releases` | Defined — 300s interval, standard `praxis:` field |

### What's Missing — The Gaps

1. **Typos lack mode/provider defaults.** `typos-def-release-artifact` defaults only `uploaded: false`. Entities composed through this typos don't carry `mode: object-storage` or `provider`. `resolve_mode()` reads `data.mode` → gets `None` → stoicheion dispatch is skipped → falls to legacy eidos-specific arm. The generic dispatch path has all the entries, but entities don't trigger it.

2. **Duplicate reconciler definitions.** `reconciler/release-artifact` (dynamis) and `reconciler/release-distribution` (release) target the same eidos with the same fields and transitions. Both have their own reflex chains. When a release-artifact entity has `_sensed.exists` updated by the daemon, both reflex chains can fire, causing duplicate reconciliation.

3. **Legacy eidos-specific match arms in host.rs.** Three `"release-artifact" =>` match arms exist in `manifest()` (line 1236), `sense_actuality()` (line 1452), and `unmanifest()` (line 1626). These are ~240 lines of code that duplicate what the stoicheion dispatch already handles — finding the distribution channel, resolving credentials, calling R2Provider. Once entities carry `mode`/`provider`, these arms are unreachable dead code.

---

## Target State

### Typos Definition (genesis/dynamis/typos/dynamis.yaml)

```yaml
- eidos: typos
  id: typos-def-release-artifact
  data:
    name: release-artifact
    description: |
      Register a build artifact with a release.

      Creates a release-artifact entity. The artifact is not yet uploaded —
      that happens during distribution when it manifests to actuality.
    target_eidos: release-artifact
    defaults:
      uploaded: false
      mode: object-storage
      provider: r2
  bonds:
    - desmos: belongs-to
      from_self: true
      to_literal: topos/dynamis
```

The `provider: r2` default means R2 is the standard path. Callers can override `provider: s3` or `provider: local` at composition time.

### Consolidated Reconciler

Keep `reconciler/release-artifact` in `genesis/dynamis/reconcilers/dynamis.yaml` (the dynamis topos owns storage actuality). Remove `reconciler/release-distribution` from `genesis/release/reconcilers/reconcilers.yaml`.

Update the release reflex `reflex/release/distribution-drift` to reference `reconciler/release-artifact` instead of `reconciler/release-distribution`.

### Legacy Arms Removed

The three `"release-artifact" =>` match arms in `host.rs` are deleted. The `match eidos { ... }` blocks in `manifest()`, `sense_actuality()`, and `unmanifest()` no longer have a `"release-artifact"` branch.

---

## Sequenced Work

### Phase 1: Fix Typos Defaults

**Goal:** Release-artifact entities composed through `typos-def-release-artifact` carry `mode` and `provider` fields, enabling generic dispatch.

**Tests:**
- `test_release_artifact_has_mode_fields` — compose a release-artifact entity through the typos, assert `data.mode == "object-storage"` and `data.provider == "r2"`
- `test_release_artifact_dispatches_through_stoicheion` — create a release-artifact entity with `mode: object-storage, provider: r2`, call `manifest()`, assert it routes through `manifest_by_stoicheion()` (not eidos-specific arm)

**Implementation:**
1. Edit `genesis/dynamis/typos/dynamis.yaml`: add `mode: object-storage` and `provider: r2` to `typos-def-release-artifact` defaults
2. Verify `resolve_mode()` reads these fields correctly

**Phase 1 Complete When:**
- [ ] Typos defaults include `mode: object-storage` and `provider: r2`
- [ ] Composed entities carry both fields

### Phase 2: Consolidate Reconciler

**Goal:** One reconciler for release-artifact, no duplication.

**Tests:**
- `test_no_duplicate_reconcilers` — gather all reconciler entities, assert no two share the same `target_eidos`

**Implementation:**
1. Delete `genesis/release/reconcilers/reconcilers.yaml` (or remove the `reconciler/release-distribution` entity from it if the file contains other entities)
2. Update `genesis/release/reflexes/reflexes.yaml`: change `reflex/release/distribution-drift` → `response_params.reconciler_id: "reconciler/release-artifact"`

**Phase 2 Complete When:**
- [ ] Only `reconciler/release-artifact` exists for the `release-artifact` eidos
- [ ] `reflex/release/distribution-drift` references `reconciler/release-artifact`
- [ ] No entity references `reconciler/release-distribution`

### Phase 3: Remove Legacy Arms

**Goal:** Delete the eidos-specific `"release-artifact"` match arms from host.rs.

**Tests:**
- All existing storage/release tests still pass (the generic path handles everything)
- `test_no_eidos_specific_release_artifact` — grep host.rs for `"release-artifact" =>`, assert zero matches

**Implementation:**
1. Remove the `"release-artifact" => { ... }` arm from `manifest()` (lines ~1236-1314)
2. Remove the `"release-artifact" => { ... }` arm from `sense_actuality()` (lines ~1452-1533)
3. Remove the `"release-artifact" => { ... }` arm from `unmanifest()` (lines ~1626-1703)

**Phase 3 Complete When:**
- [ ] No `"release-artifact" =>` match arms in host.rs
- [ ] All existing tests pass
- [ ] R2 operations route through `manifest_by_stoicheion()` → `dispatch_to_module()`

---

## Files to Read

### Genesis (prescriptive layer)
- `genesis/dynamis/typos/dynamis.yaml` — typos-def-release-artifact defaults
- `genesis/dynamis/reconcilers/dynamis.yaml` — reconciler/release-artifact
- `genesis/release/reconcilers/reconcilers.yaml` — reconciler/release-distribution (to delete)
- `genesis/release/reflexes/reflexes.yaml` — reflex referencing release-distribution
- `genesis/dynamis/reflexes/reflexes.yaml` — reflex referencing release-artifact

### Implementation (actuality layer)
- `crates/kosmos/src/host.rs` — manifest/sense/unmanifest dispatch, legacy eidos arms
- `crates/kosmos/src/mode_dispatch.rs` — stoicheion_for_mode entries
- `crates/kosmos/src/r2.rs` — R2 module (should NOT change)

---

## Files to Touch

| File | Change |
|------|--------|
| `genesis/dynamis/typos/dynamis.yaml` | **MODIFY** — add `mode: object-storage`, `provider: r2` to release-artifact defaults |
| `genesis/release/reconcilers/reconcilers.yaml` | **DELETE** or **MODIFY** — remove `reconciler/release-distribution` |
| `genesis/release/reflexes/reflexes.yaml` | **MODIFY** — update reconciler_id reference to `reconciler/release-artifact` |
| `crates/kosmos/src/host.rs` | **MODIFY** — remove three `"release-artifact" =>` match arms (~240 lines deleted) |
| `crates/kosmos/tests/` | **MODIFY** — add tests for mode-aware dispatch |

---

## Success Criteria

**Phase 1:**
- [ ] `typos-def-release-artifact` defaults include `mode` and `provider`
- [ ] Entity composition produces mode-aware release-artifact entities

**Phase 2:**
- [ ] Single reconciler for release-artifact eidos
- [ ] All reflexes reference `reconciler/release-artifact`

**Phase 3:**
- [ ] Zero `"release-artifact" =>` match arms in host.rs
- [ ] All existing tests pass
- [ ] ~240 lines of dead code removed

**Overall Complete When:**
- [ ] All existing tests still pass
- [ ] New tests verify generic dispatch path
- [ ] No eidos-specific release-artifact code remains in host.rs
- [ ] Sense prompt `PROMPT-SENSE-STORAGE.md` can be re-run to confirm R2 at stage 6 through generic path

---

## What This Enables

1. **S3 and local storage entities work immediately** — once entities carry `mode: object-storage, provider: s3|local`, the generic dispatch path routes them correctly (S3 stubs will fail with "not implemented" rather than "no actuality mode")
2. **New storage providers require only genesis** — add a mode entity, a stoicheion routing entry in build.rs, and module code. No eidos-specific host.rs arms needed.
3. **Clean separation** — host.rs dispatch is pure routing. Domain logic lives in modules (r2.rs, storage.rs). Genesis defines intent. Each layer is independently testable.

---

## What Does NOT Change

- **R2 module code** (`r2.rs`) — no changes to HTTP calls, signing, or R2Actuality
- **S3 stub implementations** — this prompt doesn't implement S3; it only ensures the dispatch path works
- **Local storage module** (`storage.rs`) — no changes
- **Mode entity definitions** (`dynamis/modes/dynamis.yaml`) — already correct
- **Daemon definition** (`release/daemons/daemons.yaml`) — already standard format

---

*Traces to: PROMPT-SENSE-STORAGE.md (gap identification), actualization-pattern.md Section 2 (one dispatch path), PROMPT-STORAGE-LIFECYCLE.md (prior R2 work)*
