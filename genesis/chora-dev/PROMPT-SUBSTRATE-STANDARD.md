# PROMPT: Substrate Module Standard

**Establishes the six-substrate taxonomy and the standard contract for Rust substrate modules. Extracts process-local from host.rs into its own module. Elevates credential from utility to full substrate. Aligns r2.rs and dns.rs to the standard. Creates the reference doc `docs/reference/infrastructure/substrate-integration.md`. Reconciles back to V7's dynamis module principle: each substrate dimension is a module with a uniform API contract; host.rs is pure dispatch.**

**Depends on**: PROMPT-SUBSTRATE-STORAGE.md (R2 + fs-local wired through generic dispatch)
**Prior art**: V7 target architecture (`archive/v7-genesis/kosmos-core/TARGET_ARCHITECTURE_V7.md` §L1 Dynamis), which defined 7 host modules each in `host/*.rs` with standard function signatures
**Enables**: PROMPT-SUBSTRATE-DNS.md, all Phase 2–4 substrate prompts (they implement against this contract)

---

## Architectural Principle

**Each Substrate Dimension Is a Module; host.rs Is Pure Dispatch**

V7 established a clean pattern: each dynamis capability is a Rust module in `host/`. The current codebase drifted — some substrates have modules (r2.rs, dns.rs, voice.rs, livekit.rs), some are inline in host.rs (process spawn/check/kill, fs read/write), and the modules that exist have incompatible API shapes. Worse, the substrate taxonomy itself is incomplete — credential management and media capture are treated as utilities rather than substrates, creating ad-hoc patterns that resist standardization.

The standard:

```
INVARIANT:  Six substrate dimensions — the complete taxonomy of how kosmos actualizes in chora
INVARIANT:  Every substrate module exports execute_operation(op, entity_id, data, session) → Result<Value>
INVARIANT:  host.rs match arms are ONE LINE — delegate to module::execute_operation()
INVARIANT:  Credential resolution is itself a substrate, not a utility
VARIES BY:  What operations a module supports (manifest/sense/unmanifest/custom)
VARIES BY:  What provider variants exist within a substrate
```

This is not a refactor for aesthetics. Without a standard contract:
- Every new substrate prompt re-invents the integration pattern
- PROMPT-SUBSTRATE-DNS.md cannot "follow the R2 pattern" because R2's pattern differs from the process pattern
- Reconcilers and daemons that operate across substrates cannot have uniform dispatch
- The completion matrix stages 3→6 multiply by the number of ad-hoc patterns

---

## The Six Substrates

Chora receives kosmos. These are the **six dimensions** of that reception — the complete taxonomy of how intent becomes actuality:

| # | Substrate | What It Is | Providers (current + planned) | Module |
|---|-----------|-----------|-------------------------------|--------|
| 1 | **Screen** | Visual presentation — where entities become visible | thyra (SolidJS) | `layout-engine.tsx` |
| 2 | **Compute** | Process execution and build toolchains | local, docker, systemd, nixos, cargo | `process.rs` |
| 3 | **Storage** | Data persistence — where content endures | fs-local, R2, S3 | `storage.rs` → `r2.rs` |
| 4 | **Network** | System communication — how systems find and reach each other | cloudflare (DNS), route53, manual | `dns.rs` |
| 5 | **Credential** | Identity, keys, secrets — how trust is established and maintained | macos-keychain, environment, (future: linux-secret-service, hardware-token) | `credential.rs` |
| 6 | **Media** | Capture devices and real-time streams — perception and presence | whisper (voice), livekit (WebRTC) | `voice.rs`, `livekit.rs` |

### Why Six, Not Four

The prior taxonomy had four substrates: screen, compute, storage, network. This was incomplete:

**Credential is a substrate, not a utility.** The keyring has a real actualization cycle (unlock=manifest, check=sense, lock=unmanifest). Platform variation is real (macOS Keychain vs Linux Secret Service vs env vars). Other substrates depend on it. Treating it as a cross-cutting utility creates three incompatible credential patterns; treating it as a substrate gives it one.

**Media is a substrate, not a subcategory.** Voice was lumped into compute and WebRTC into network. But neither is computation or networking — they are perception and presence. Both use event-driven handler patterns (not request/response stoicheia). Both are consumed via `requires` dependencies from screen modes. V7 recognized this: its `media` dynamis module had `capture_start/capture_status/capture_stop`. Grouping them as one substrate makes the handler pattern a substrate-level trait, not an exception to explain.

### Two Dispatch Patterns

Not all substrates use the same dispatch mechanism, and this is correct:

**Stoicheion-dispatched** (request/response): compute, storage, network, credential
- Operations are atomic: call → result
- Dispatched via `manifest_by_stoicheion` / `sense_by_stoicheion` / `unmanifest_by_stoicheion`
- Module exports `execute_operation()`

**Handler-dispatched** (event-driven): screen, media
- Operations are lifecycle-bound: start → stream events → stop
- Screen: managed by thyra layout engine (TypeScript)
- Media: managed by substrate handlers registered by mode ID
- Module exports handler registration, not `execute_operation`

Both patterns are standard. The reference doc prescribes both.

---

## Methodology — Doc → Test → Build → Align → Track

1. **Doc**: Create `docs/reference/infrastructure/substrate-integration.md` defining the six-substrate taxonomy, standard contract, both dispatch patterns, credential substrate, and module checklist
2. **Test**: Write tests that assert the standard contract for process module (extraction target) and credential module (elevation target)
3. **Build**: Extract process-local from host.rs → process.rs. Elevate credential.rs to substrate with execute_operation. Create storage.rs facade. Align r2.rs and dns.rs. Slim host.rs dispatch arms to one-line delegations
4. **Align**: Update docs that reference substrate integration. Update REGISTRY.md impact map
5. **Track**: Verify completion matrix stages unchanged (this is structural, not functional)

---

## Context — Three Patterns, One Should Win

### Current State: Three Incompatible Patterns

**Pattern A — Dedicated module with `execute_operation` (R2)**
```rust
// r2.rs
pub fn execute_operation_with_session(
    operation: &str,        // "manifest" | "sense" | "delete"
    params: &Value,         // Raw params (not entity data)
    session: Option<&Arc<dyn SessionBridge>>,
) -> Result<Value>
```
- Credential resolution: SessionBridge → params → env vars (triple fallback)
- Returns: `Result<Value>` (R2Actuality serialized)
- Entity data extraction happens in host.rs BEFORE calling r2

**Pattern B — Dedicated module with typed functions (DNS)**
```rust
// dns.rs
pub fn manifest(provider: &DnsProvider, record: &DnsRecord) -> Result<DnsActuality>
pub fn sense(provider: &DnsProvider, name: &str, ...) -> Result<DnsActuality>
pub fn unmanifest(provider: &DnsProvider, record_id: &str) -> Result<()>
```
- Credential resolution: `resolve_credential("env://VAR")` (env-only, no keychain integration)
- Returns: typed structs, caller serializes
- Entity data extraction: `DnsRecord::from_entity_data(&data)` inside the module

**Pattern C — Inline in host.rs (process, fs-local before storage prompt)**
```rust
// host.rs — manifest_by_stoicheion match arm for "spawn-process"
"spawn-process" => {
    let command = data.get("command").and_then(|v| v.as_str()).unwrap_or("echo");
    // ... 40 lines of inline implementation ...
    let child = std::process::Command::new(command).args(&args).spawn()?;
    // ... entity update, return JSON ...
}
```
- No credential resolution
- Returns: hand-built `serde_json::json!({...})`
- Entity data extraction inline in the match arm

### Target State: Uniform Module Contract

All stoicheion-dispatched substrate modules export the same shape. host.rs match arms become:

```rust
"spawn-process"      => process::execute_operation("spawn", entity_id, data, &self.session),
"check-process"      => process::execute_operation("check", entity_id, data, &self.session),
"kill-process"       => process::execute_operation("kill",  entity_id, data, &self.session),
"keyring-unlock"     => credential::execute_operation("unlock", entity_id, data, &self.session),
"keyring-retrieve"   => credential::execute_operation("retrieve", entity_id, data, &self.session),
```

---

## Design — The Standard Substrate Module Contract

### 1. Module Signature (stoicheion-dispatched substrates)

Every stoicheion-dispatched substrate module in `crates/kosmos/src/` exports:

```rust
/// Execute a substrate operation.
///
/// - `operation`: one of the mode's declared operation names (e.g. "spawn", "check", "kill")
/// - `entity_id`: the entity being actualized
/// - `data`: the entity's data object (serde_json::Value)
/// - `session`: optional session bridge for credential/keychain access
///
/// Returns: serde_json::Value with at minimum { status: string }
/// May include `_entity_update: { ... }` for host.rs to apply to the entity.
pub fn execute_operation(
    operation: &str,
    entity_id: &str,
    data: &Value,
    session: Option<&Arc<dyn SessionBridge>>,
) -> Result<Value>
```

Inside `execute_operation`, the module:
1. Extracts fields from `data` (provider-specific)
2. Resolves credentials via the credential substrate (if needed)
3. Dispatches to internal typed functions (`manifest()`, `sense()`, etc.)
4. Returns `serde_json::Value` with standard fields plus provider-specific fields
5. Includes `_entity_update` if the entity should be mutated (host.rs applies it)

### 2. Return Value Standard

All operations return JSON with these standard fields:

```json
{
  "status": "manifested | sensed | unmanifested | error",
  "entity_id": "the-entity-id",
  "stoicheion": "the-stoicheion-name",
  "timestamp": "RFC3339"
}
```

Plus operation-specific fields:
- Manifest: `+ { manifest_handle?, content_hash?, artifact_path? }`
- Sense: `+ { exists: bool, is_fresh: bool, actual_state?, divergence? }`
- Unmanifest: `+ { cleaned: bool }`

### 3. Entity Update Convention

Modules cannot call `self.update_entity()` — they don't have access to the host context. Instead, modules return `_entity_update: { field: value, ... }` in their result. host.rs applies this generically after dispatch:

```rust
// host.rs — after any module call
if let Some(update) = result.get("_entity_update") {
    self.apply_entity_update(entity_id, data, update)?;
}
```

This keeps match arms as one-liners while preserving entity update behavior. The `apply_entity_update` helper merges the update object into the entity's data and calls `self.update_entity()`.

### 4. Credential Substrate

Credentials are a **substrate**, not a utility. The keyring has a real actualization cycle:

| Operation | What it does | Keychain equivalent |
|-----------|-------------|---------------------|
| `unlock` | Decrypt keyring into session memory | Manifest — bring trust into actuality |
| `store` | Add credential for a service | Manifest — add a specific capability |
| `retrieve` | Get credential by service name | Sense — query current trust state |
| `list` | Enumerate available credentials + attainments | Sense — full state inspection |
| `lock` | Clear decrypted material from memory | Unmanifest — remove trust from actuality |

The credential module exports `execute_operation()` conforming to the standard contract:

```rust
// credential.rs
pub fn execute_operation(
    operation: &str,
    entity_id: &str,
    data: &Value,
    session: Option<&Arc<dyn SessionBridge>>,
) -> Result<Value> {
    match operation {
        "unlock"   => unlock_keyring(data, session),
        "store"    => store_credential(data, session),
        "retrieve" => retrieve_credential(data, session),
        "list"     => list_credentials(session),
        "lock"     => lock_keyring(session),
        _ => Err(KosmosError::Invalid(format!("Unknown credential operation: {}", operation))),
    }
}
```

**Provider variation:**

```
OS Keychain → SessionToken → SessionBridge.get_credential(service) → substrate module
```

When a parousia arises and the keyring is unlocked, credentials are available via `session.get_credential(service_name)`. This is the **primary and expected path** (macOS Keychain via the `keyring` crate). Environment variables exist only as a fallback for headless/CI contexts where `KOSMOS_NO_SESSION=1` skips keychain access.

The credential substrate also provides a convenience function for other substrate modules:

```rust
/// Resolve a credential by service name. Used by storage, network, and other
/// substrate modules that need credentials for external APIs.
///
/// Resolution order:
/// 1. SessionBridge (keychain): session.get_credential(service_name) — PRIMARY
/// 2. Environment fallback: env var (for headless/CI only)
///
/// This is NOT a separate utility — it's the credential substrate's "retrieve"
/// operation exposed as a helper for ergonomic use by other modules.
pub fn resolve_credential(
    service_name: &str,
    session: Option<&Arc<dyn SessionBridge>>,
) -> Result<String>
```

This replaces three current patterns:
- R2's triple-fallback inline in execute_operation_with_session (session → params → env)
- DNS/LiveKit's `resolve_credential("env://VAR")` (env-only, no keychain integration)
- Process's no-credential-at-all approach

The keychain is always tried first; env vars are the headless escape hatch, not a peer.

### 5. host.rs Dispatch Pattern

After extraction, every stoicheion match arm in host.rs becomes a one-liner:

```rust
// manifest_by_stoicheion
"spawn-process"    => process::execute_operation("spawn", entity_id, data, &self.session),
"fs-write-file"    => storage::execute_operation("write", entity_id, data, &self.session),
"r2-put-object"    => storage::execute_operation("upload", entity_id, data, &self.session),
"cf-create-record" => dns::execute_operation("create", entity_id, data, &self.session),
"keyring-store"    => credential::execute_operation("store", entity_id, data, &self.session),

// sense_by_stoicheion
"check-process"    => process::execute_operation("check", entity_id, data, &self.session),
"fs-stat-file"     => storage::execute_operation("stat", entity_id, data, &self.session),
"r2-head-object"   => storage::execute_operation("head", entity_id, data, &self.session),
"cf-get-record"    => dns::execute_operation("get", entity_id, data, &self.session),
"keyring-retrieve" => credential::execute_operation("retrieve", entity_id, data, &self.session),

// unmanifest_by_stoicheion
"kill-process"     => process::execute_operation("kill", entity_id, data, &self.session),
"fs-delete-file"   => storage::execute_operation("delete", entity_id, data, &self.session),
"r2-delete-object" => storage::execute_operation("delete-object", entity_id, data, &self.session),
"cf-delete-record" => dns::execute_operation("delete", entity_id, data, &self.session),
"keyring-lock"     => credential::execute_operation("lock", entity_id, data, &self.session),
```

After dispatch, host.rs generically applies `_entity_update` and injects the stoicheion name.

### 6. Module Roster (Current → Standard)

| Module File | Substrate | Current State | Work in This Prompt |
|-------------|-----------|---------------|---------------------|
| `credential.rs` | credential | Does not exist | **NEW** — full substrate module with execute_operation (unlock/store/retrieve/list/lock) + resolve_credential convenience function |
| `process.rs` | compute | Inline in host.rs (Pattern C) | **NEW** — extract from host.rs. Three operations: spawn, check, kill. ~120 lines |
| `storage.rs` | storage | Split: fs-local inline, R2 in r2.rs | **NEW** — facade dispatching to local or r2 by provider |
| `r2.rs` | storage (R2 provider) | Pattern A — `execute_operation_with_session` | **ALIGN** — standard 4-param signature, move entity data extraction in, use credential substrate. Delete old signature (no deprecated wrapper — dead code is contextual poison) |
| `dns.rs` | network | Pattern B — typed functions | **ALIGN** — add execute_operation facade, use credential substrate |
| `voice.rs` | media | Handler — not stoicheion-dispatched | **Out of scope** — handler-dispatched substrate (Phase 4). Taxonomy acknowledges it |
| `livekit.rs` | media | Handler — token-only | **Out of scope** — handler-dispatched substrate (Phase 4). Taxonomy acknowledges it |

### 7. Storage Module Consolidation

Currently `fs-write-file`/`fs-stat-file`/`fs-delete-file` are inline in host.rs (implemented in PROMPT-SUBSTRATE-STORAGE.md) and R2 delegates to `r2::execute_operation_with_session()`. Both are storage operations.

Create `crates/kosmos/src/storage.rs` that:
- Handles `fs-*` operations internally (move from host.rs)
- Delegates R2 operations to `r2.rs` (r2.rs becomes a provider within storage)
- Handles S3 operations by calling r2.rs with endpoint override (when S3 prompt lands)

This mirrors the DNS module's multi-provider enum: `DnsProvider::Cloudflare | Route53 | Manual`.

```rust
// storage.rs
pub fn execute_operation(op: &str, entity_id: &str, data: &Value, session: ...) -> Result<Value> {
    let provider = data.get("provider").and_then(|v| v.as_str()).unwrap_or("local");
    match provider {
        "local" => execute_local(op, entity_id, data),
        "r2"    => r2::execute_operation(op, entity_id, data, session),
        "s3"    => r2::execute_operation(op, entity_id, data, session), // same API, different endpoint
        _       => Err(KosmosError::Invalid(format!("Unknown storage provider: {}", provider))),
    }
}
```

---

## Implementation Order

### Step 1: Reference Doc (DDD Phase 1)

Create `docs/reference/infrastructure/substrate-integration.md`:

1. **Purpose** — what a substrate module is, why the standard exists
2. **The Six Substrates** — complete taxonomy table with dimension, providers, module, dispatch pattern
3. **Two Dispatch Patterns** — stoicheion-dispatched (request/response) vs handler-dispatched (event-driven)
4. **The Standard Contract** — `execute_operation` signature, return value schema, `_entity_update` convention
5. **Module Checklist** — what a new substrate module must provide:
   - `execute_operation()` function with standard signature (stoicheion-dispatched) OR handler registration (handler-dispatched)
   - Operation dispatch (match on operation name)
   - Entity data extraction (from `data: &Value`)
   - Credential resolution via credential substrate (if applicable)
   - Standard return value shape (status + entity_id + stoicheion + timestamp + operation-specific)
6. **Credential Substrate** — the keyring lifecycle as actualization cycle, resolve_credential convenience, keychain-first resolution
7. **Dispatch Protocol** — how host.rs routes stoicheia to modules (one-liner arms + apply_entity_update)
8. **Multi-Provider Pattern** — how modules with provider variants dispatch internally (dns enum, storage delegation, credential providers)
9. **Module Roster** — table of all current modules, their substrate, dispatch pattern, and conformance status
10. **Extension Guide** — step-by-step for adding a new substrate module (either dispatch pattern)
11. **Anti-Patterns** — inline logic in host.rs, module-specific credential resolution, typed returns instead of Value, treating credential as a utility

Cross-reference from:
- `docs/reference/reactivity/actualization-pattern.md` → "Substrate modules implement the stoicheion operations; see substrate-integration.md"
- `docs/reference/infrastructure/command-template-execution.md` → "Command templates are one implementation strategy within a substrate module; see substrate-integration.md for the module contract"
- `docs/reference/infrastructure/substrate-lifecycle.md` → "For the TypeScript handler pattern (screen and media substrates), see substrate-lifecycle.md. For the Rust module contract (compute, storage, network, credential), see substrate-integration.md"

### Step 2: Credential Substrate Module

Create `crates/kosmos/src/credential.rs` (~80 lines):

```rust
pub fn execute_operation(
    operation: &str,
    entity_id: &str,
    data: &Value,
    session: Option<&Arc<dyn SessionBridge>>,
) -> Result<Value>
```

Operations:
- `"unlock"` → verify session, check keyring state, return `{ status: "manifested", is_unlocked: true }`
- `"store"` → extract service_name + value from data, call `session.store_credential()`, return `{ status: "manifested" }`
- `"retrieve"` → extract service_name from data, call `session.get_credential()`, return `{ status: "sensed", value }` or error
- `"list"` → call `session.list_credentials()` + `session.list_attainments()`, return `{ status: "sensed", credentials, attainments }`
- `"lock"` → not directly possible via SessionBridge trait (keyring lock is session-level), return advisory `{ status: "unmanifested" }`

Convenience function for other substrate modules:
```rust
pub fn resolve_credential(
    service_name: &str,
    session: Option<&Arc<dyn SessionBridge>>,
) -> Result<String>
```

Resolution order:
1. `session.get_credential(service_name)` → return value (keychain — primary)
2. Env var fallback for headless/CI: look up well-known env var for the service (e.g. `"cloudflare-r2"` → `CLOUDFLARE_R2_ACCESS_KEY_ID`)
3. No session + no env var → error: "Unlock keyring and add {service} credential in Settings → Credentials"

Register in `lib.rs`: `pub mod credential;`

### Step 3: Extract process.rs

Create `crates/kosmos/src/process.rs` by extracting from host.rs:

- `"spawn-process"` match arm → `process::execute_operation("spawn", ...)`
- `"check-process"` match arm → `process::execute_operation("check", ...)`
- `"kill-process"` match arm → `process::execute_operation("kill", ...)`

The process module:
```rust
pub fn execute_operation(
    operation: &str,
    entity_id: &str,
    data: &Value,
    _session: Option<&Arc<dyn SessionBridge>>,  // unused but contract-conformant
) -> Result<Value>
```

Match internally on `operation`:
- `"spawn"` → extract command/args/dir/env from data, `std::process::Command::new().spawn()`, return pid + status + `_entity_update`
- `"check"` → extract manifest_handle (pid), `waitpid`/`kill(pid,0)` check, return running + exit_code + `_entity_update`
- `"kill"` → extract manifest_handle (pid) + signal from data, `kill(pid, signal)`, return status + `_entity_update`

Signal for kill: host.rs injects `data["_signal"]` at top of `unmanifest_by_stoicheion` before calling the module.

### Step 4: Create storage.rs Facade

Create `crates/kosmos/src/storage.rs`:
- Move `fs-write-file`, `fs-stat-file`, `fs-delete-file` logic from host.rs into `execute_local()`
- Delegate R2 operations to `r2::execute_operation()`
- Export `execute_operation()` with provider dispatch

### Step 5: Align r2.rs to Standard

Rename `execute_operation_with_session` → `execute_operation` with standard signature:
```rust
pub fn execute_operation(
    operation: &str,
    entity_id: &str,
    data: &Value,
    session: Option<&Arc<dyn SessionBridge>>,
) -> Result<Value>
```

Move entity data extraction (storage_key, content_type, etc.) INTO r2.rs from host.rs.
Replace inline credential fallback with `credential::resolve_credential()`.
Delete the old 2-param `execute_operation(operation, params)` — no deprecated wrapper. Dead code is contextual poison.

### Step 6: Align dns.rs to Standard

Add `execute_operation()` facade:
```rust
pub fn execute_operation(
    operation: &str,
    entity_id: &str,
    data: &Value,
    session: Option<&Arc<dyn SessionBridge>>,
) -> Result<Value> {
    let provider = DnsProvider::from_entity_data(data, session)?;
    match operation {
        "create" => { let record = DnsRecord::from_entity_data(data)?; manifest(&provider, &record).map(serialize) }
        "get"    => { sense(&provider, ...).map(serialize) }
        "delete" => { unmanifest(&provider, ...).map(serialize) }
        _ => Err(...)
    }
}
```

Replace `resolve_credential()` with `credential::resolve_credential()`.

### Step 7: Slim host.rs Dispatch

Add `apply_entity_update(&self, entity_id, data, result)` helper — extracts `_entity_update` from result, merges into entity data, calls `self.update_entity()`.

Replace all multi-line match arms with one-line delegations:

```rust
// BEFORE (40+ lines for spawn-process)
"spawn-process" => {
    let command = data.get("command")...;
    let args = ...;
    let child = std::process::Command::new(command)...;
    // ... entity update ...
    Ok(serde_json::json!({...}))
}

// AFTER (1 line)
"spawn-process" => process::execute_operation("spawn", entity_id, data, &self.session),
```

Apply to:
- manifest_by_stoicheion: spawn-process, fs-write-file, r2-put-object
- sense_by_stoicheion: check-process, fs-stat-file, r2-head-object
- unmanifest_by_stoicheion: kill-process, fs-delete-file, r2-delete-object

After each dispatch call, apply `_entity_update` and inject stoicheion name generically.

**Keep stubs as-is** — docker-*, s3-*, cf-* remain stubs. They will be replaced when their respective substrate prompts land.

### Step 8: Write Tests

Create `crates/kosmos/tests/substrate_standard.rs`:

1. `test_credential_execute_operation_retrieve` — mock session bridge with credential for "test-service", call `credential::execute_operation("retrieve", ...)`, assert standard return shape with value
2. `test_credential_execute_operation_list` — mock session bridge with credentials + attainments, call list, assert both returned
3. `test_credential_resolve_keychain_primary` — mock session, call `credential::resolve_credential("test-service", session)`, assert keychain value returned
4. `test_credential_resolve_env_fallback` — no session, set env var, call resolve, assert env var returned
5. `test_credential_resolve_no_session_no_env` — no session, no env var, assert error message mentions keyring unlock
6. `test_process_execute_operation_spawn` — call `process::execute_operation("spawn", ...)` with echo command, assert standard return shape + `_entity_update`
7. `test_process_execute_operation_check` — spawn then check, assert `{ status, running, pid }`
8. `test_process_execute_operation_kill` — spawn then kill, assert `{ status: "unmanifested" }`
9. `test_storage_local_via_facade` — call `storage::execute_operation("write", ...)` with provider=local, assert standard return
10. `test_storage_r2_via_facade` — call `storage::execute_operation("upload", ...)` with provider=r2, assert credential error (no creds in test = expected failure mode, not stub)
11. `test_host_dispatch_uses_modules` — bootstrap, create entity with mode=process-local, call manifest_by_stoicheion, assert result matches standard shape

### Step 9: Verify and Align

```bash
cargo build -p kosmos 2>&1
cargo test -p kosmos --lib --tests 2>&1
cargo test -p kosmos --test substrate_standard 2>&1

# Verify host.rs has no inline substrate logic (only one-line delegations)
# The match arms for spawn-process, check-process, kill-process, fs-write-file,
# fs-stat-file, fs-delete-file, r2-put-object, r2-head-object, r2-delete-object
# should each be a single line calling module::execute_operation()
```

Update REGISTRY.md impact map if stale.

---

## Files to Read

**Implementation (verify current state before changing)**:
- `crates/kosmos/src/host.rs` — manifest/sense/unmanifest dispatch, inline process/fs logic, SessionBridge trait
- `crates/kosmos/src/r2.rs` — current execute_operation_with_session signature
- `crates/kosmos/src/dns.rs` — current typed function API, DnsProvider enum, resolve_credential
- `crates/kosmos/src/crypto.rs` — SessionKeyring: store_credential, get_credential, lock, unlock
- `crates/kosmos/src/voice.rs` — handler pattern (what media substrate looks like)
- `crates/kosmos/src/livekit.rs` — handler pattern + resolve_credential
- `crates/kosmos/src/lib.rs` — module registrations
- `crates/kosmos/src/mode_dispatch.rs` — generated stoicheion-to-module mapping

**Architecture (prior art)**:
- `archive/v7-genesis/kosmos-core/TARGET_ARCHITECTURE_V7.md` §L1 Dynamis — 7 host modules pattern, especially `media` module

**Documentation (cross-references)**:
- `docs/reference/reactivity/actualization-pattern.md` — unified reference (add cross-ref, update substrate taxonomy to six)
- `docs/reference/infrastructure/command-template-execution.md` — template pattern (add cross-ref)
- `docs/reference/infrastructure/substrate-lifecycle.md` — frontend handler pattern (cross-ref to distinguish from Rust module contract)

---

## Files to Touch

| File | Change |
|------|--------|
| `docs/reference/infrastructure/substrate-integration.md` | **NEW** — standard contract reference doc with six-substrate taxonomy |
| `crates/kosmos/src/credential.rs` | **NEW** — credential substrate module with execute_operation + resolve_credential (~80 lines) |
| `crates/kosmos/src/process.rs` | **NEW** — extracted from host.rs (~120 lines) |
| `crates/kosmos/src/storage.rs` | **NEW** — facade over fs-local + r2 + future s3 (~80 lines) |
| `crates/kosmos/src/r2.rs` | **MODIFY** — standard 4-param signature, move data extraction in, use credential substrate, delete old 2-param signature |
| `crates/kosmos/src/dns.rs` | **MODIFY** — add execute_operation facade, use credential substrate |
| `crates/kosmos/src/livekit.rs` | **MODIFY** — delegate resolve_credential to credential substrate |
| `crates/kosmos/src/host.rs` | **MODIFY** — replace inline logic with one-line module delegations, add apply_entity_update helper |
| `crates/kosmos/src/lib.rs` | **MODIFY** — register credential, process, storage modules |
| `crates/kosmos/tests/substrate_standard.rs` | **NEW** — 11 tests |
| `docs/reference/reactivity/actualization-pattern.md` | **MODIFY** — update substrate taxonomy to six, add cross-reference |
| `docs/reference/infrastructure/command-template-execution.md` | **MODIFY** — add cross-reference |
| `docs/reference/infrastructure/substrate-lifecycle.md` | **MODIFY** — add cross-reference distinguishing handler vs module patterns |

---

## Success Criteria

- [ ] `docs/reference/infrastructure/substrate-integration.md` exists and prescribes the six-substrate taxonomy and standard contract
- [ ] `credential::execute_operation("retrieve"|"list"|"store"|"unlock"|"lock", ...)` works with standard signature
- [ ] `credential::resolve_credential()` resolves via keychain (SessionBridge) first, env var fallback for headless — used by r2.rs, dns.rs, livekit.rs
- [ ] `process::execute_operation("spawn"|"check"|"kill", ...)` works with standard signature
- [ ] `storage::execute_operation(...)` dispatches to local or R2 based on provider field
- [ ] `r2::execute_operation()` has standard 4-param signature (no deprecated wrapper)
- [ ] `dns::execute_operation()` has standard 4-param signature
- [ ] Every non-stub match arm in `manifest_by_stoicheion`, `sense_by_stoicheion`, `unmanifest_by_stoicheion` is a one-line delegation to a module
- [ ] `apply_entity_update()` generically handles `_entity_update` from module results
- [ ] `cargo test -p kosmos --lib --tests` passes (all existing tests)
- [ ] `cargo test -p kosmos --test substrate_standard` passes (11 new tests)
- [ ] Stubs (docker-*, s3-*, cf-*) remain untouched — they are other prompts' responsibility
- [ ] actualization-pattern.md updated to reflect six substrates

---

## What This Enables

1. **PROMPT-SUBSTRATE-DNS.md becomes trivial**: Wire cf-* stubs to `dns::execute_operation()` — the contract is established
2. **Phase 2 prompts have a template**: Every "advance to stage 6" prompt follows the same integration pattern
3. **Phase 3 prompts have a contract**: Docker, S3, systemd, NixOS implementors know exactly what to export
4. **Phase 4 prompts have a taxonomy**: Voice and WebRTC know they're media substrates with handler dispatch, not exceptions
5. **Reconcilers can be generic**: A reconciler that calls `manifest_by_stoicheion` gets uniform return values regardless of substrate
6. **host.rs stops growing**: New substrates add a file + one-line match arm, not 40 lines of inline logic
7. **Completion matrix becomes meaningful**: "Stage 3 = has execute_operation" is now a precise criterion
8. **Credential lifecycle can be reconciled**: As a substrate, the keyring can have its own daemon, reflexes, and reconciler (e.g. detect expiry, refresh tokens)

---

## What Does NOT Change

1. **mode_dispatch.rs** — generated dispatch table unchanged (stoicheion names stay the same)
2. **Command template pipeline** — `execute_command_template()` remains in host.rs (it's a dispatch mechanism, not a substrate)
3. **Stub match arms** — docker-run/inspect/stop, s3-put/head/delete, cf-create/get/delete stay as stubs
4. **voice.rs / livekit.rs handler pattern** — acknowledged as handler-dispatched media substrate, not converted to execute_operation. Phase 4 scope
5. **Genesis YAML** — no mode/eidos/typos changes needed (this is structural, not ontological). Credential modes may be prescribed in a future prompt
6. **Frontend substrate-lifecycle.md** — that doc covers the TypeScript handler pattern (screen + media); this covers Rust modules (compute + storage + network + credential). They complement, not conflict
7. **SessionBridge trait** — unchanged. credential.rs wraps it, doesn't modify it

---

## Findings That Are Out of Scope

1. **Entity update side-effects**: The `_entity_update` convention keeps modules pure. Whether entity updates eventually move into modules (giving them host context) is deferred to Phase 2 lifecycle prompts.
2. **Async operations**: All current substrate operations are synchronous (blocking). Async substrate operations (long-running builds, remote deployments) will need a different pattern. Deferred to Phase 2.
3. **Credential mode entities in genesis**: This prompt establishes credential.rs as a substrate module. Prescribing `mode/credential-keychain` and `mode/credential-env` in genesis YAML is a follow-up — the module contract comes first.
4. **Time as a seventh substrate**: Temporal operations (scheduling, cron, daemon intervals) may constitute their own substrate dimension. Left as an open question in the reference doc rather than forced prematurely.
5. **Handler-to-stoicheion convergence**: Whether media substrates eventually expose execute_operation in addition to their handler interface is a Phase 4 design question.

---

*Traces to: V7 §L1 Dynamis module pattern, KOSMOGONIA §Mode Pattern, T5 (code is artifact), PROMPT-SUBSTRATE-STORAGE.md (predecessor), PROMPT-ACTUALIZATION-PATTERN.md (vocabulary)*
