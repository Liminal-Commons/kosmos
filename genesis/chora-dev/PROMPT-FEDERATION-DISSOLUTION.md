# Federation Dissolution — Dissolving Federation Orchestration into the Generic Reactive Loop

*Prompt for Claude Code in the chora + kosmos repository context.*

*Dissolves the imperative FederationReconciler into the generic reactive infrastructure (reflexes + daemons + reconciler engine) that already exists. Extracts protocol types (Phoreta, SyncMessage) into their own module. Deletes dead federation code. After this work, federation sync is prescribed by genesis YAML and executed by the same mechanisms as every other reconciliation cycle.*

---

## Prerequisite: Doc Alignment

Three reference docs have drift against KOSMOGONIA that this dissolution will compound if left unfixed. Correct these before or during the implementation:

1. **`docs/reference/reactivity/daemon-runner.md`** — Says "The daemon runner replaces custom reconciler engines." This contradicts KOSMOGONIA §Reconciler Pattern and this prompt's own treatment of `host.reconcile()` as the engine. The daemon is a trigger mechanism (parasympathetic: periodic sensing), not a replacement for the reconciler. Remove the "replaces" language; reframe as "trigger mechanism that feeds into the reconciler."

2. **`docs/explanation/reactivity/reactive-system.md`** — References `ReconcilerLoop` struct in `reconciler_loop.rs`. That file was retired. After this dissolution removes `reconciler.rs` too, the stale references compound. Update to reflect current architecture: daemon loop + reflex engine as triggers, `host.reconcile()` as the engine.

3. **`docs/reference/reactivity/reconciliation.md`** — Victor has aligned this with KOSMOGONIA during the review session (renamed "Actuality-Mode Integration" → "Mode Integration", unified mode language). Verify it reflects the post-Mode-Unification terminology before implementation begins.

All doc references and comments written during this work should use post-unification terminology: **"mode"** (not "actuality-mode"). Mode Unification (Arc 1) retired `eidos/actuality-mode` into the unified `eidos/mode` with `substrate` field.

---

## Architectural Principle — Orchestration is a Smell

KOSMOGONIA §Reconciler Pattern:

> The reconciler operates through modes. The reconciler is substrate-agnostic — it reads transition tables from entities. The mode is substrate-specific.

The `FederationReconciler` violates this principle. It is an imperative orchestrator that:
1. Intercepts **every** graph mutation via `ChangeListener`
2. Maintains its own **in-memory state** (`FederationState` with `RwLock`)
3. Manually decides which mutations to sync and constructs phoreta in code
4. Sends sync messages through channels by direct `host.signal()` calls

The kosmos already has a generic nervous system that does all of this:
- **Reflexes** fire praxeis on specific graph mutations (filtered by trigger patterns)
- **Daemons** sense actuality periodically (time-driven)
- **Reconciler engine** (`host.reconcile()`) compares intent with actuality, dispatches actions through modes
- **Aither genesis** already prescribes the correct architecture using all four mechanisms

The FederationReconciler is a bypass. It duplicates what reflexes should do (event-driven sync), what daemons should do (periodic sensing), and what the reconciler engine should do (intent/actuality alignment). It was written before these generic mechanisms existed. Now they exist.

Delete the orchestrator. Trust the nervous system.

---

## Current State

### What must be deleted

| File | Lines | Status | Problem |
|------|-------|--------|---------|
| `crates/kosmos-mcp/src/federation.rs` | 462 | **Completely unwired** | HTTP federation client — exported but never called from any running code path. `spawn_federation_pull_loop()` is never invoked. `http.rs:72` has a comment: "Federation reconciler can be added here when integrated" — it was never integrated. |
| `crates/kosmos-mcp/build.rs` | 9 | **Empty stub** | Comment says essential praxeis now loaded from `attainment/mcp-essential` at runtime. No build-time generation. |
| `FederationReconciler` in `reconciler.rs` | ~350 | **Replaced by reflexes** | Imperative ChangeListener that manually intercepts all mutations, maintains in-memory state, and constructs sync messages. Everything it does is now prescribed by aither's reflexes, daemons, and reconciler entities. |
| `FederationState`, `FederationInfo` | ~45 | **State that should be entity data** | In-memory cache of active federations. Kosmos entities ARE the state — `gather(eidos: syndesmos)` replaces `load_federations()`. |
| `load_federations()` | ~60 | **Orchestration** | Reads `federates-with` bonds and builds in-memory cache. Replaced by graph traversal in aither praxeis. |
| `gather_pending_entities()` | ~35 | **Orchestration** | Gathers entities by version. Replaced by `rest.rs` `/federation/changes` endpoint and catch-up praxeis. |
| `get_sync_cursor()` / `update_sync_cursor()` | ~50 | **Orchestration** | Cursor management. Replaced by entity data fields — cursors are entities, not function calls. |

### What must be preserved

These types are actively used by `rest.rs` federation endpoints (`/federation/sync`, `/federation/changes`):

| Type/Function | Used By | Purpose |
|---------------|---------|---------|
| `Phoreta` struct + `sign()` / `verify()` | `rest.rs:988`, `rest.rs:907-935` | Signed entity transport bundle |
| `SyncMessage` enum | Aither genesis praxeis (protocol type) | Federation sync protocol messages |
| `apply_phoreta()` | `rest.rs:901`, `rest.rs:938` | Apply incoming phoreta to local database |
| `ApplyResult` enum | `rest.rs:901`, `rest.rs:939-962` | Result of applying a phoreta |
| `create_conflict()` | Conflict resolution flow | Create sync-conflict entity |
| `SyncDirection` | Bond data field type | Push/pull/bidirectional |
| `FederationTransport` | Bond data field type | WebRTC vs HTTP |

### What the aither genesis already prescribes

The target architecture **already exists in genesis YAML**. No new genesis entities are needed.

**Reconciler**: `reconciler/syndesmos-reconnect` — intent/actuality alignment for connection state
```yaml
# genesis/aither/reconcilers/reconcilers.yaml (already exists)
transitions:
  - intent: connected, actual: [disconnected, failed], action: manifest
  - intent: disconnected, actual: connected, action: unmanifest
  - intent: suspended, actual: connected, action: unmanifest
```

**Daemon**: `daemon/sense-syndesmos` — senses connection actuality every 30 seconds
```yaml
# genesis/aither/daemons/daemons.yaml (already exists)
praxis: aither/sense-syndesmos-states
interval: 30
```

**Reflex**: `reflex/aither/sync-message-received` — event-driven sync message processing
```yaml
# genesis/aither/reflexes/reflexes.yaml (already exists)
trigger: sync-message entity created
responds-with: praxis/aither/process-sync-message
```

**Reflex**: `reflex/aither/syndesmos-drift` — drift detection triggers reconciliation
```yaml
# genesis/aither/reflexes/reflexes.yaml (already exists)
condition: intent="connected" and status in [disconnected, failed]
responds-with: praxis/dynamis/reconcile
```

The FederationReconciler was doing manually what these four entities do declaratively.

---

## Design — Extract Types, Delete Orchestration

### New module: `phoreta.rs`

Extract the protocol types from `reconciler.rs` into `crates/kosmos/src/phoreta.rs`:

```rust
// crates/kosmos/src/phoreta.rs — Federation transport types
//
// Phoreta (φορητά) are signed entity bundles for transport across federation.
// These types are protocol-level: they define the shape of data exchanged
// between oikoi. They are NOT orchestration — they don't decide when or
// how to sync. That's the job of reflexes, daemons, and the reconciler engine.

pub struct Phoreta { ... }        // Signed entity bundle
pub enum SyncMessage { ... }      // Protocol message types
pub enum ApplyResult { ... }      // Result of applying a phoreta
pub enum SyncDirection { ... }    // Push/pull/bidirectional
pub enum FederationTransport { ... } // WebRTC vs HTTP

pub fn apply_phoreta(host: &HostContext, phoreta: &Phoreta) -> Result<ApplyResult> { ... }
pub fn create_conflict(host: &HostContext, ...) -> Result<String> { ... }
```

### Delete: `reconciler.rs`

After extracting types to `phoreta.rs`, delete the entire file. Everything left is orchestration:
- `FederationState` — in-memory state (entities should be the state)
- `FederationInfo` — cached bond data (use graph traversal)
- `FederationReconciler` — ChangeListener bypass
- `load_federations()` — imperative state loading
- `gather_pending_entities()` — version-based entity scanning
- `get_sync_cursor()` / `update_sync_cursor()` — cursor management
- `SyncStats` — orchestrator metrics

### Delete: `federation.rs` (kosmos-mcp)

Delete entirely. Never wired. The HTTP federation functionality it attempted to provide is already served by the REST endpoints in `rest.rs` (`/federation/sync`, `/federation/changes`).

### Delete: `build.rs` (kosmos-mcp)

Delete entirely. Empty stub.

### Update: `lib.rs` (kosmos)

```rust
// Before
pub mod reconciler;
pub use reconciler::{FederationReconciler, Phoreta, SyncMessage, SyncStats};

// After
pub mod phoreta;
pub use phoreta::{Phoreta, SyncMessage, ApplyResult, SyncDirection, FederationTransport};
```

### Update: `lib.rs` (kosmos-mcp)

```rust
// Before
pub mod federation;

// After
// (line removed — federation module deleted)
```

### Update: `rest.rs` (kosmos-mcp)

```rust
// Before
use kosmos::reconciler::{apply_phoreta, ApplyResult};
use kosmos::reconciler::Phoreta;

// After
use kosmos::phoreta::{apply_phoreta, ApplyResult};
use kosmos::phoreta::Phoreta;
```

### Update: `host.rs` comment

```rust
// Before (line 478)
// 2. Notify existing ChangeListener (FederationReconciler)

// After
// 2. Notify ChangeListener (e.g., WsChangeListener for real-time events)
```

### Update: `lib.rs` MultiChangeListener comment (kosmos-mcp)

```rust
// Before
/// HostContext only supports one ChangeListener, but we need both
/// FederationReconciler and WsChangeListener to receive events.

// After
/// HostContext only supports one ChangeListener. MultiChangeListener
/// composes multiple listeners (e.g., WsChangeListener, future listeners).
```

---

## Implementation Order

### Step 1: Create `phoreta.rs`

Create `crates/kosmos/src/phoreta.rs`. Move these items from `reconciler.rs`:
- `Phoreta` struct + `from_entity()`, `sign()`, `verify()` methods
- `SyncMessage` enum (all 6 variants)
- `SyncDirection` enum + `Default` + `From<&str>` impls
- `FederationTransport` enum + `Default` + `From<&str>` impls
- `ApplyResult` enum
- `apply_phoreta()` function
- `create_conflict()` function
- Tests: `test_phoreta_creation`, `test_sync_direction_from_str`, `test_sync_message_serialization`

Preserve all imports these items need: `crate::host::HostContext`, `crate::{KosmosError, Result}`, `serde`, `serde_json`, `blake3`, `ed25519_dalek`, `chrono`, `hex`.

### Step 2: Update `lib.rs` (kosmos)

Replace:
```rust
pub mod reconciler;
pub use reconciler::{FederationReconciler, Phoreta, SyncMessage, SyncStats};
```

With:
```rust
pub mod phoreta;
pub use phoreta::{ApplyResult, FederationTransport, Phoreta, SyncDirection, SyncMessage};
```

### Step 3: Delete `reconciler.rs`

Delete `crates/kosmos/src/reconciler.rs` entirely. All reusable content has been moved to `phoreta.rs`.

### Step 4: Delete `federation.rs` (kosmos-mcp)

Delete `crates/kosmos-mcp/src/federation.rs`.

Remove `pub mod federation;` from `crates/kosmos-mcp/src/lib.rs`.

### Step 5: Delete `build.rs` (kosmos-mcp)

Delete `crates/kosmos-mcp/build.rs`.

### Step 6: Update `rest.rs` imports

Change `use kosmos::reconciler::` to `use kosmos::phoreta::` for all federation type imports. The `rest.rs` comment on line 322 references `kosmos/reconciler.rs` — update it to reference `kosmos/phoreta.rs`.

### Step 7: Update host.rs comment

Line 478: Change `"Notify existing ChangeListener (FederationReconciler)"` to remove the FederationReconciler reference.

Line 301: The `set_change_listener` doc comment mentions `"needed for FederationReconciler circular reference"` — update.

### Step 8: Update MultiChangeListener comment

In `kosmos-mcp/lib.rs`, update the doc comment that mentions FederationReconciler.

### Step 9: Fix doc drift

Apply the prerequisite doc alignment (see §Prerequisite above):

1. **`docs/reference/reactivity/daemon-runner.md`**: Remove "The daemon runner replaces custom reconciler engines" and the surrounding framing. Rewrite the "Reconciliation as Composition" section to describe daemons as trigger mechanisms that feed into `host.reconcile()`, not replacements for it.

2. **`docs/explanation/reactivity/reactive-system.md`**: Replace stale `ReconcilerLoop` / `reconciler_loop.rs` references with current architecture: daemon loop as periodic trigger, reflex engine as event trigger, `host.reconcile()` as the reconciler engine.

3. Verify `docs/reference/reactivity/reconciliation.md` uses post-unification "mode" terminology (not "actuality-mode").

### Step 10: Verify

```bash
# Build succeeds
cargo build 2>&1

# All tests pass (phoreta tests included)
cargo test -p kosmos --lib --tests 2>&1

# No references to deleted modules
rg 'reconciler::' crates/ --type rust
# Expected: only host.rs line ~2971 (local variable name, not module import)

rg 'mod federation' crates/kosmos-mcp/src/
# Expected: zero results

rg 'federation\.rs' crates/
# Expected: zero results

# rest.rs still compiles (federation endpoints use phoreta module)
cargo test -p kosmos-mcp --lib 2>&1

# Dead code scan
rg 'FederationReconciler|FederationState|FederationInfo|SyncStats' crates/
# Expected: zero results
```

---

## What This Enables

- **Conceptual clarity**: Federation sync is no longer a special-case orchestrator — it uses the same mechanisms (reflexes, daemons, reconciler) as every other reconciliation cycle in the kosmos
- **Dead code elimination**: 462 + 1049 + 9 = ~1520 lines of code removed or restructured. Contextual poison eliminated.
- **Protocol types preserved**: `Phoreta`, `SyncMessage`, `apply_phoreta()` remain available for the REST federation endpoints and future aither stoicheion implementations
- **ChangeListener freed**: The trait is no longer associated with federation — it's a general-purpose mutation notification mechanism (currently used only by WsChangeListener). With FederationReconciler gone, WsChangeListener is the sole consumer. The `MultiChangeListener` wrapper and `ChangeListener` trait may be over-abstracted for a single consumer — candidate for simplification in a future session, not blocking for this work.
- **Aither validation**: The genesis YAML that prescribes federation through reflexes+daemons+reconciler is now the ONLY description of how federation works — no competing imperative implementation

---

## What Does NOT Change

- `ChangeListener` trait in `host.rs` — unchanged (WsChangeListener uses it)
- `MultiChangeListener` in `kosmos-mcp/lib.rs` — unchanged (but comment updated)
- `host.reconcile()` — unchanged (generic reconciler engine)
- Reflex system (`reflex.rs`) — unchanged
- Daemon system (`daemon_loop.rs`) — unchanged
- Mode dispatch (`actuality_modes.rs`) — unchanged
- `rest.rs` federation endpoints — unchanged (imports updated)
- All aither genesis entities — unchanged
- `release.rs` binary — **NOT dead** (functional CI/CD release publisher)

---

## Findings That Are Out of Scope

### Aither manifest vestiges

The aither manifest contains `actuality_modes:` and `stoicheia_form:` sections in the pre-Mode-Unification format. These are vestiges from before Arc 1. Fixing them requires:
1. Creating `genesis/aither/modes/webrtc.yaml` with unified `eidos: mode` entities (post-unification: `substrate` field, not separate `actuality-mode` eidos)
2. Implementing webrtc stoicheion handlers in Rust
3. Removing the shorthand from the manifest

This is substrate implementation work, not dissolution. Track separately.

### Aither stoicheion implementations

The aither praxeis use `step: manifest`, `step: sense_actuality`, `step: unmanifest`, and `step: signal`. The signal step dispatches to Tauri WebRTC integration. The manifest/sense/unmanifest steps dispatch through modes — but no webrtc stoicheion implementations exist yet. These will be needed when WebRTC is wired end-to-end.

### `genesis/spora/praxeis/` empty directory

An empty directory that was never populated. Safe to delete but not part of this arc.

---

*Traces to: KOSMOGONIA V11 §Reconciler Pattern, PROMPT-MODE-UNIFICATION.md (Arc 1), PROMPT-RECONCILIATION-SURFACE.md (Arc 2)*
