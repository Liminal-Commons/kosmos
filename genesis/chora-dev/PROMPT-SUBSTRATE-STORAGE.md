# Substrate Storage — Wiring Object Storage Through Generic Mode Dispatch

*Prompt for Claude Code in the chora + kosmos repository context.*

*The object storage substrate has a complete R2 implementation (`r2.rs`) but it's wired through an eidos-specific handler for `release-artifact` — not through the generic stoicheion dispatch path that the mode system prescribes. The stoicheion handlers (`r2-put-object`, `fs-write-file`, etc.) are stubs. This work fills the stubs: wires the existing R2 module through generic dispatch, implements local filesystem storage alongside it, and proves that any entity with `mode: object-storage` actuates through the mode system regardless of eidos.*

*Depends on: PROMPT-ACTUALIZATION-PATTERN.md (documents the actualization cycle, mode catalog, and completion stages).*
*References: PROMPT-ACTUALIZATION-CARGO.md (established the template-driven stoicheion pattern for compute substrate).*

---

## Architectural Principle — Dispatch Through Modes, Not Through Eidos

KOSMOGONIA §Mode Pattern: mode is how existence becomes actuality on a substrate. Mode dispatch is generic — the system resolves `(mode, provider)` from entity data, looks up stoicheion names in the dispatch table, and executes. The eidos of the entity is irrelevant to dispatch.

Today, `release-artifact` entities actualize through storage — but they bypass mode dispatch. `host.rs` has a hardcoded `"release-artifact"` match arm that directly calls `r2::manifest_from_file()`. This violates the pattern: dispatch should flow through `resolve_mode() → stoicheion_for_mode() → manifest_by_stoicheion()`, not through eidos matching.

The R2 implementation is excellent — 789 lines with S3-compatible auth, upload, sense, delete. The work is not implementing R2; it's **connecting** R2 to the generic path. And implementing `fs-local` alongside it so the storage substrate has two working providers.

```
CURRENT (eidos-specific):
  release-artifact → match eidos → hardcoded r2.rs calls
  anything else   → resolve_mode() → stoicheion stubs → "stub"

TARGET (mode-driven):
  any entity with mode: object-storage, provider: r2    → r2.rs
  any entity with mode: object-storage, provider: local → fs operations
  any entity with mode: object-storage, provider: s3    → (future)
```

After this work, any entity — not just `release-artifact` — can use object storage by having `mode: object-storage` and `provider: r2` or `provider: local` in its data. The homoiconic promise: mode is configurable data, not hardcoded dispatch.

---

## Methodology — Doc-Driven, Test-Driven

The cycle: **Doc → Test → Build → Align → Track**.

1. **Doc**: Read `docs/reference/reactivity/actualization-pattern.md` (created by PROMPT-ACTUALIZATION-PATTERN.md). The mode catalog should list `mode/object-storage-r2` at stage 2 (dispatched, stub), `mode/object-storage-local` at stage 2, `mode/object-storage-s3` at stage 2. After this work, R2 advances to stage 3 (implemented), local advances to stage 3, S3 remains at stage 2.
2. **Test**: Write failing tests that assert generic dispatch to storage stoicheia produces real results — not "stub" returns.
3. **Build**: Fill the stoicheion stubs with real implementations.
4. **Align**: Update actualization-pattern.md mode catalog to reflect new completion stages.

---

## Context — Two Paths, One Should Win

### What Exists and Works

| Component | Location | Status |
|-----------|----------|--------|
| R2 module | `crates/kosmos/src/r2.rs` | Complete (789 lines) — S3-compatible upload, HEAD, DELETE with AWS Sig V4 |
| Release-artifact handler | `host.rs` lines ~2133, ~2473, ~2787 | Works — finds distribution channel, resolves credentials, calls r2.rs |
| Credential resolution | `dns::resolve_credential()` + `SessionBridge` | Works — resolves R2 credentials from session or env |
| Mode dispatch table | `mode_dispatch.rs` (generated) | 9 storage entries for 3 providers × 3 operations |
| Reconciler | `reconciler/release-artifact` | Defined — intent (uploaded) vs actuality (_sensed.exists) |
| Mode entities | `genesis/dynamis/modes/dynamis.yaml` | 3 modes (r2, s3, local) with operations and configs |

### What's Stub

| Stoicheion | Dispatch Table Entry | Current Implementation |
|------------|---------------------|----------------------|
| `r2-put-object` | `("object-storage", "r2", Manifest)` | Returns `"stub"` |
| `r2-head-object` | `("object-storage", "r2", Sense)` | Returns `"stub"` |
| `r2-delete-object` | `("object-storage", "r2", Unmanifest)` | Returns `"stub"` |
| `s3-put-object` | `("object-storage", "s3", Manifest)` | Returns `"stub"` |
| `s3-head-object` | `("object-storage", "s3", Sense)` | Returns `"stub"` |
| `s3-delete-object` | `("object-storage", "s3", Unmanifest)` | Returns `"stub"` |
| `fs-write-file` | `("object-storage", "local", Manifest)` | Returns `"stub"` |
| `fs-stat-file` | `("object-storage", "local", Sense)` | Returns `"stub"` |
| `fs-delete-file` | `("object-storage", "local", Unmanifest)` | Returns `"stub"` |

### The Architectural Gap

The system has **two parallel dispatch mechanisms** for storage:

1. **Eidos-specific** (works today): `release-artifact` → hardcoded match arm → `r2.rs`
2. **Generic stoicheion dispatch** (mode-driven, stubs): `resolve_mode()` → `stoicheion_for_mode()` → `manifest_by_stoicheion("r2-put-object")` → returns `"stub"`

The eidos-specific path was implemented before Mode Unification. It works but violates the pattern — only `release-artifact` entities can use R2. Any other entity type that wants object storage would hit the stub.

---

## Design — Generic Storage Stoicheia

### R2 Stoicheia (wire existing module)

The R2 stoicheion handlers delegate to the existing `r2.rs` module. They read configuration from entity data (not from an eidos-specific handler):

```
r2-put-object:
  1. Read entity data: storage_key, local_path (or content), content_type, bucket
  2. Resolve R2 credentials (session bridge → env vars → entity data)
  3. Call r2::manifest_from_file() or r2::manifest_from_bytes()
  4. Return { success, etag, size_bytes, storage_key }

r2-head-object:
  1. Read entity data: storage_key, bucket
  2. Resolve R2 credentials
  3. Call r2::sense()
  4. Return { exists, etag, size_bytes, last_modified, content_type }

r2-delete-object:
  1. Read entity data: storage_key, bucket
  2. Resolve R2 credentials
  3. Call r2::unmanifest()
  4. Return { success }
```

### Local Filesystem Stoicheia (new implementation)

The fs-local provider uses standard filesystem operations. No external dependencies.

```
fs-write-file:
  1. Read entity data: base_path, path_pattern (or target_path), content/source_path
  2. Resolve target path from pattern + entity data
  3. Create parent directories if needed
  4. Write file (copy from source_path, or write content bytes)
  5. Compute BLAKE3 content hash
  6. Return { success, path, content_hash, size_bytes }

fs-stat-file:
  1. Read entity data: target_path (or base_path + path_pattern)
  2. Resolve path
  3. std::fs::metadata() — exists, size, modified time
  4. If exists, compute BLAKE3 content hash
  5. Return { exists, path, content_hash, size_bytes, modified_at }

fs-delete-file:
  1. Read entity data: target_path
  2. std::fs::remove_file()
  3. Return { success }
```

### Entity Data Contract

For an entity to actualize through the storage substrate, its data must contain:

**For R2 provider:**
```yaml
mode: object-storage
provider: r2
storage_key: "artifacts/kosmos/v0.1.0/kosmos-aarch64-apple-darwin"
local_path: "target/release/kosmos"  # for manifest (upload source)
content_type: "application/octet-stream"
# bucket comes from distribution-channel config or entity data
```

**For local provider:**
```yaml
mode: object-storage
provider: local
base_path: "/Users/victorpiper/.kosmos/artifacts"
target_path: "builds/kosmos-release"  # relative to base_path
source_path: "target/release/kosmos"   # for manifest (copy source)
```

### Credential Resolution for R2

The existing pattern in the eidos-specific handler:
1. Find distribution channel via bond
2. Get credential_ref from channel config
3. `dns::resolve_credential(credential_ref, session_bridge)`
4. Falls back to `R2_ACCESS_KEY_ID` / `R2_SECRET_ACCESS_KEY` env vars

The generic stoicheion handler should follow the same pattern but read credential_ref from entity data or from a bonded configuration entity — not from a hardcoded channel lookup. This makes credential resolution work for any entity, not just release-artifacts.

---

## Implementation Order

### Step 1: Doc — Verify reference doc describes storage substrate

Read `docs/reference/reactivity/actualization-pattern.md`. Verify the storage substrate section describes the three providers (r2, s3, local) and their stoicheia. If the doc doesn't exist yet (PROMPT-ACTUALIZATION-PATTERN.md hasn't been executed), note the gap but proceed — the reference doc is not blocking for implementation.

### Step 2: Test — Write failing tests

Create `crates/kosmos/tests/storage_substrate.rs` with:

```rust
#[test]
fn test_fs_write_file_stoicheion() {
    // Bootstrap, create entity with mode: object-storage, provider: local
    // Entity data: base_path (temp dir), target_path, source content
    // Call manifest_by_stoicheion("fs-write-file", entity_id, data)
    // Assert file exists at expected path
    // Assert content_hash is correct BLAKE3 hash
    // → Fails because fs-write-file returns "stub"
}

#[test]
fn test_fs_stat_file_stoicheion() {
    // Write a file to temp dir
    // Create entity with mode: object-storage, provider: local
    // Call sense_by_stoicheion("fs-stat-file", entity_id, data)
    // Assert exists: true, size matches, content_hash matches
    // → Fails because fs-stat-file returns "stub"
}

#[test]
fn test_fs_delete_file_stoicheion() {
    // Write a file to temp dir
    // Create entity with mode: object-storage, provider: local
    // Call unmanifest_by_stoicheion("fs-delete-file", entity_id, data)
    // Assert file no longer exists
    // → Fails because fs-delete-file returns "stub"
}

#[test]
fn test_fs_sense_nonexistent() {
    // Create entity pointing to nonexistent path
    // Call sense_by_stoicheion("fs-stat-file", entity_id, data)
    // Assert exists: false
}

#[test]
fn test_r2_stoicheion_dispatches_to_module() {
    // Bootstrap, create entity with mode: object-storage, provider: r2
    // Entity data: storage_key, bucket, credential fields
    // Call manifest_by_stoicheion("r2-put-object", entity_id, data)
    // Assert result is NOT "stub" — it either succeeds or fails with a real error
    // (This test may need env vars for actual R2 access; mark #[ignore] if so)
}

#[test]
fn test_generic_dispatch_reaches_storage() {
    // Bootstrap, create entity with mode: object-storage, provider: local
    // Call ctx.manifest(entity_id) — the full dispatch path
    // Assert it goes through resolve_mode → stoicheion_for_mode → manifest_by_stoicheion
    // Assert result is not "stub" or "unknown_stoicheion"
}
```

### Step 3: Build — Implement fs-local stoicheia

In `host.rs`, replace the `"fs-write-file"` stub in `manifest_by_stoicheion()` with a real implementation:

1. Read `base_path`, `target_path` (or `path_pattern`), `source_path` (or `content`) from entity data
2. Resolve full path: `base_path / target_path`
3. Create parent directories (`std::fs::create_dir_all`)
4. Write file: if `source_path`, copy; if `content`, write bytes
5. Compute BLAKE3 hash of written file
6. Return `{ success: true, path, content_hash, size_bytes }`

Replace `"fs-stat-file"` stub in `sense_by_stoicheion()`:

1. Read `target_path` (or `base_path` + `path_pattern`) from entity data
2. `std::fs::metadata()` — check existence
3. If exists: read file, compute BLAKE3 hash, return `{ exists: true, path, content_hash, size_bytes, modified_at }`
4. If not: return `{ exists: false }`

Replace `"fs-delete-file"` stub in `unmanifest_by_stoicheion()`:

1. Read `target_path` from entity data
2. `std::fs::remove_file()`
3. Return `{ success: true }` or `{ success: false, error }` if file didn't exist

### Step 4: Build — Wire R2 stoicheia to existing module

In `host.rs`, replace the `"r2-put-object"` stub in `manifest_by_stoicheion()`:

1. Read `storage_key`, `local_path` (or `content`), `content_type`, `bucket` from entity data
2. Read `credential_ref` from entity data (or from bonded config entity)
3. Resolve credentials via `dns::resolve_credential()` or env vars
4. Create `R2Provider` from resolved credentials + bucket
5. Call `r2::manifest_from_file()` or `r2::manifest_from_bytes()`
6. Return `{ success, etag, size_bytes, storage_key }`

This is essentially extracting the credential resolution and r2.rs calls from the eidos-specific `release-artifact` handler into the generic stoicheion handler.

Similarly wire `"r2-head-object"` → `r2::sense()` and `"r2-delete-object"` → `r2::unmanifest()`.

### Step 5: Test — Verify all tests pass

```bash
# Build
cargo build -p kosmos 2>&1

# All existing tests
cargo test -p kosmos --lib --tests 2>&1

# New storage tests
cargo test -p kosmos --test storage_substrate 2>&1

# R2 integration tests (if env vars set)
# R2_ACCESS_KEY_ID=... R2_SECRET_ACCESS_KEY=... cargo test -p kosmos --test storage_substrate -- --ignored 2>&1
```

### Step 6: Verify — No stubs remain for implemented providers

```bash
# Check that fs-* and r2-* stoicheia no longer return "stub"
rg '"stub"' crates/kosmos/src/host.rs
# Expected: only s3-*, cf-* stubs remain (not yet implemented)
# fs-write-file, fs-stat-file, fs-delete-file → real implementations
# r2-put-object, r2-head-object, r2-delete-object → real implementations
```

### Step 7: Align — Update actualization-pattern.md

If `docs/reference/reactivity/actualization-pattern.md` exists, update the mode catalog:
- `mode/object-storage-r2`: stage 2 → **stage 3** (implemented)
- `mode/object-storage-local`: stage 2 → **stage 3** (implemented)
- `mode/object-storage-s3`: remains stage 2 (stub)

---

## Files to Read

### Implementation
- `crates/kosmos/src/r2.rs` — existing R2 implementation (full module)
- `crates/kosmos/src/host.rs` — `manifest_by_stoicheion()`, `sense_by_stoicheion()`, `unmanifest_by_stoicheion()` (stub locations)
- `crates/kosmos/src/host.rs` — eidos-specific `release-artifact` handler (reference for credential resolution pattern)
- `crates/kosmos/src/dns.rs` — `resolve_credential()` function
- `crates/kosmos/src/mode_dispatch.rs` — verify dispatch table has storage entries

### Genesis definitions
- `genesis/dynamis/modes/dynamis.yaml` — storage mode entity definitions
- `genesis/release/eide/release.yaml` — eide that use storage modes
- `genesis/dynamis/reconcilers/dynamis.yaml` — reconciliation rules for storage entities

### Documentation
- `docs/reference/reactivity/actualization-pattern.md` — the unified pattern reference (if exists)
- `docs/REGISTRY.md` — Impact Map

## Files to Touch

- `crates/kosmos/src/host.rs` — replace 6 stubs with real implementations (fs-write-file, fs-stat-file, fs-delete-file, r2-put-object, r2-head-object, r2-delete-object)
- `crates/kosmos/tests/storage_substrate.rs` — **NEW** test file
- `docs/reference/reactivity/actualization-pattern.md` — update mode catalog completion stages (if exists)

---

## Success Criteria

- [ ] `fs-write-file` writes files to local filesystem with BLAKE3 hash
- [ ] `fs-stat-file` senses file existence, size, and hash
- [ ] `fs-delete-file` removes files
- [ ] `r2-put-object` delegates to `r2::manifest_from_file()` via generic dispatch
- [ ] `r2-head-object` delegates to `r2::sense()` via generic dispatch
- [ ] `r2-delete-object` delegates to `r2::unmanifest()` via generic dispatch
- [ ] Generic dispatch path (`ctx.manifest()` → `resolve_mode()` → `stoicheion_for_mode()` → real implementation) works for both providers
- [ ] All new tests pass
- [ ] All existing tests pass (no regressions in release-artifact path)
- [ ] No `"stub"` returns for `fs-*` or `r2-*` stoicheia

---

## What This Enables

1. **Any entity can use object storage** — Not just `release-artifact`. Build artifacts, theoria attachments, voice recordings — any entity with `mode: object-storage` in its data.
2. **Local-first development** — `provider: local` works without cloud credentials. Development and testing use filesystem; production uses R2.
3. **Provider switching** — Change `provider: r2` to `provider: local` in entity data; dispatch route changes automatically. No code changes.
4. **Build artifact persistence** — Connects to chora-dev: cargo build outputs can be stored via `fs-write-file`, sensed via `fs-stat-file`, making the build pipeline fully graph-tracked.
5. **Eidos-specific handler retirement path** — Once the generic path works for R2, the hardcoded `release-artifact` handler becomes redundant. A future cleanup prompt can retire it. (Not in scope for this prompt — the eidos handler stays as a working fallback.)

---

## What Does NOT Change

- `r2.rs` module — existing implementation preserved, just called from a new path
- `dns.rs` credential resolution — existing implementation reused
- S3 stoicheia — remain stubs (`s3-put-object`, `s3-head-object`, `s3-delete-object`)
- DNS stoicheia — remain stubs (`cf-create-record`, `cf-sense-record`, `cf-delete-record`)
- Release-artifact eidos handler — preserved as-is. Not retired by this prompt.
- Mode entities — unchanged. Mode dispatch table — unchanged (already generated correctly).
- Build system — unchanged.

---

## Findings That Are Out of Scope

### S3 provider implementation

`mode/object-storage-s3` shares the same protocol as R2 (S3-compatible). The existing `r2.rs` module could serve S3 by parameterizing the endpoint. But this is a separate concern — requires testing against actual AWS S3, different auth flows.

### Eidos-specific handler retirement

The `release-artifact` handler in host.rs (lines ~2133-2216) should eventually be replaced by generic dispatch. But it works today and retiring it requires verifying all release workflows still function. Separate prompt.

### Path pattern interpolation

The fs-local provider could support path patterns with `{{ }}` interpolation (e.g., `target_path: "{{ crate_name }}/{{ profile }}/{{ artifact_name }}"`). Useful but not required for the initial implementation — can use explicit `target_path` for now.

### Distribution channel bond traversal

The eidos-specific handler finds R2 config via `distributed-via` bond → distribution channel entity. The generic stoicheion handler reads config from entity data directly. If we want the generic handler to also support channel-based config resolution, that's additional bond traversal logic — out of scope for initial implementation.

---

*Traces to: KOSMOGONIA §Mode Pattern, PROMPT-ACTUALIZATION-PATTERN.md, PROMPT-ACTUALIZATION-CARGO.md (established template-driven stoicheion pattern), T5 (code is artifact)*
