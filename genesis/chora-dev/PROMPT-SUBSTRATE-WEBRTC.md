# WebRTC Substrate — Connection Lifecycle Through Standard Dispatch

*Prompt for Claude Code in the chora + kosmos repository context.*

*Converts WebRTC/LiveKit from handler-dispatched to stoicheion-dispatched. Adds stoicheion names to mode/webrtc-livekit, restructures livekit.rs to standard execute_operation contract with manifest/sense/unmanifest, wires dispatch in host.rs, adds `_entity_update` to all operations. Adds reconciler/syndesmos with transition table for connection lifecycle, reflexes for connection state changes, and daemon for periodic connection health sensing. The syndesmos entity already has intent/status fields — the autonomic loop just needs to reach them. Advances WebRTC from stage 1 to stage 6.*

*Depends on: PROMPT-SUBSTRATE-STANDARD.md*

---

## Architectural Principle — Intent and Status Are Already There

`eidos/syndesmos` already declares the autonomic pattern:

```yaml
intent:
  type: string
  enum: [connected, disconnected, suspended]
  default: connected
status:
  type: string
  enum: [disconnected, connecting, connected, reconnecting, failed, suspended]
```

This IS desired_state/actual_state — just named `intent` and `status`. The reconciler reads these fields. The reflex watches them. The only thing missing is the dispatch plumbing that lets the autonomic loop reach the LiveKit operations.

`livekit.rs` already has `execute_operation` with "create-token". It generates valid JWTs. What's missing is manifest (join room / generate token + establish connection state), sense (check connection / verify token validity), and unmanifest (leave room / close connection). Plus `_entity_update` on everything.

---

## Methodology — DDD + TDD

This work follows **Doc → Test → Build → Verify**, non-negotiably.

1. **Doc (prescriptive)**: This prompt IS the prescriptive doc. The target state described here is what code must match.
2. **Test (assert the doc)**: Write tests that assert `_entity_update` presence in LiveKit operations, stoicheion dispatch wiring, and standard contract conformance.
3. **Build (satisfy the tests)**: Implement until tests pass.
4. **Verify doc**: After implementation, update success criteria to reflect completion.

LiveKit operations that require a running LiveKit server should be `#[ignore]`. Token generation and credential resolution tests use mock/test data. Dispatch routing and `_entity_update` structure tests use in-memory entities.

---

## Current State

### What Exists and Works

| Component | Location | Status |
|-----------|----------|--------|
| `mode/webrtc-livekit` | `genesis/aither/modes/webrtc.yaml` | Defined — uses `handler:` not `stoicheion:` |
| `execute_operation("create-token")` | `livekit.rs:222` | Working — generates valid JWT with grants |
| `LiveKitServer` struct | `livekit.rs:24` | Working — host, ws_url, api_key, api_secret |
| `create_token()` | `livekit.rs:154` | Working — JWT with VideoGrant, configurable TTL |
| `resolve_credential()` | `livekit.rs:200` | Working — env:// resolution (but doesn't use SessionBridge) |
| `eidos/syndesmos` | `genesis/aither/eide/aither.yaml:99` | Defined — intent, status, room_id, peer_id, retry_count, backoff |
| `host.signal()` | `host.rs:1984` | Stub — delegates to `reflex::handle_signal` (all stubs) |
| `handle_signal()` | `reflex.rs:895` | Stubs — poll, send_offer, send_answer, etc. all return stub JSON |

### What's Missing — The Four Gaps

**Gap 1: No stoicheion names.** `mode/webrtc-livekit` uses `handler:` fields. build.rs skips it. No entries in mode_dispatch.rs. No match arms in host.rs for LiveKit lifecycle operations.

**Gap 2: No manifest/sense/unmanifest operations.** `execute_operation` only handles "create-token". There's no "join" (manifest a connection), no "check" (sense connection state), no "leave" (close connection). The syndesmos entity's intent/status fields exist but nothing writes to them through the standard path.

**Gap 3: No `_entity_update`.** "create-token" returns `{ token, expires_at }` — no `_entity_update`. The syndesmos entity's status field is never updated by operations.

**Gap 4: Credential resolution doesn't use SessionBridge.** `livekit::resolve_credential` has its own `env://` parsing, separate from the standard `credential::resolve_credential` helper. This should use the same path as every other substrate.

---

## Target State

### mode/webrtc-livekit with stoicheion names

```yaml
- eidos: mode
  id: mode/webrtc-livekit
  data:
    name: webrtc
    topos: aither
    substrate: network
    provider: livekit
    description: |
      P2P network transport via LiveKit WebRTC.
      Manages peer connections, data channels, and signaling.
    operations:
      manifest:
        stoicheion: lk-join-room
        description: Generate access token and establish connection intent.
        params:
          room_id:
            type: string
          identity:
            type: string
          name:
            type: string
            required: false
      sense:
        stoicheion: lk-sense-connection
        description: Check connection state and token validity.
        params:
          manifest_handle:
            type: string
      unmanifest:
        stoicheion: lk-leave-room
        description: Close connection and invalidate state.
        params:
          manifest_handle:
            type: string
```

Signal operations stay as a separate host method — they're protocol-specific exchange, not lifecycle.

### livekit.rs with standard contract

```rust
pub fn execute_operation(
    operation: &str,
    entity_id: &str,
    data: &Value,
    session: Option<&Arc<dyn SessionBridge>>,
) -> Result<Value> {
    match operation {
        "join" | "manifest" | "create-token" => join_room(entity_id, data, session),
        "sense" | "check" => sense_connection(entity_id, data),
        "leave" | "unmanifest" => leave_room(entity_id, data),
        _ => Err(...)
    }
}
```

### Operations return `_entity_update`

**join (manifest):**
```rust
Ok(json!({
    "status": "manifested",
    "entity_id": entity_id,
    "stoicheion": "lk-join-room",
    "token": token_result.token,
    "expires_at": token_result.expires_at,
    "ws_url": server.ws_url,
    "_entity_update": {
        "status": "connecting",
        "manifest_handle": token_result.token,
        "token_expires_at": token_result.expires_at,
        "last_reconciled_at": now
    }
}))
```

**sense:**
```rust
Ok(json!({
    "status": "sensed",
    "entity_id": entity_id,
    "stoicheion": "lk-sense-connection",
    "token_valid": !expired,
    "connection_state": state,
    "_entity_update": {
        "status": if expired { "disconnected" } else { state },
        "last_sensed_at": now
    }
}))
```

**leave (unmanifest):**
```rust
Ok(json!({
    "status": "unmanifested",
    "entity_id": entity_id,
    "stoicheion": "lk-leave-room",
    "_entity_update": {
        "status": "disconnected",
        "manifest_handle": null,
        "last_reconciled_at": now
    }
}))
```

### host.rs dispatch

```rust
// manifest_by_stoicheion:
"lk-join-room" => self.dispatch_to_module(entity_id, data,
    crate::livekit::execute_operation("join", entity_id, data, session_ref)),

// sense_by_stoicheion:
"lk-sense-connection" => self.dispatch_to_module(entity_id, data,
    crate::livekit::execute_operation("sense", entity_id, data, session_ref)),

// unmanifest_by_stoicheion:
"lk-leave-room" => self.dispatch_to_module(entity_id, data,
    crate::livekit::execute_operation("leave", entity_id, data, session_ref)),
```

### Credential resolution unified

```rust
// In join_room():
let (api_key, api_secret) = resolve_livekit_credentials(data, session)?;

fn resolve_livekit_credentials(data: &Value, session: Option<&Arc<dyn SessionBridge>>) -> Result<(String, String)> {
    // Try standard credential resolution first
    if let Some(session) = session {
        if let Ok(cred) = crate::credential::resolve_credential("livekit", session) {
            // Parse JSON credential with api_key and api_secret
            ...
        }
    }
    // Fall back to env vars
    let api_key = std::env::var("LIVEKIT_API_KEY")
        .or_else(|_| std::env::var("LK_API_KEY"))
        .map_err(|_| ...)?;
    let api_secret = std::env::var("LIVEKIT_API_SECRET")
        .or_else(|_| std::env::var("LK_API_SECRET"))
        .map_err(|_| ...)?;
    Ok((api_key, api_secret))
}
```

---

## Sequenced Work

### Phase 1: Genesis — Stoicheion Names (YAML)

**Goal:** mode/webrtc-livekit uses stoicheion dispatch, not handler dispatch.

**Implementation:**

1. In `genesis/aither/modes/webrtc.yaml`, replace `handler:` with `stoicheion:` for manifest, sense, unmanifest
2. Keep signal operation documented but not as a stoicheion (it's protocol-specific, stays hand-wired)
3. Verify build.rs generates dispatch entries after change

**Phase 1 Complete When:**
- [ ] mode/webrtc-livekit uses `stoicheion:` for manifest/sense/unmanifest
- [ ] mode_dispatch.rs generates `("webrtc", "livekit", ...)` entries

### Phase 2: Standard Contract + `_entity_update` (Rust)

**Goal:** livekit.rs conforms to the 4-param execute_operation contract with `_entity_update` on all operations.

**Tests:**
- `test_livekit_join_returns_entity_update` — call `execute_operation("join", ...)` with test credentials (env vars), verify `_entity_update.status == "connecting"` and `_entity_update.manifest_handle` is a valid JWT
- `test_livekit_sense_returns_entity_update` — call `execute_operation("sense", ...)` with a token, verify `_entity_update` contains `status` and `last_sensed_at`
- `test_livekit_leave_returns_entity_update` — call `execute_operation("leave", ...)`, verify `_entity_update.status == "disconnected"` and `_entity_update.manifest_handle` is null
- `test_livekit_execute_operation_contract` — verify the function takes (operation, entity_id, data, session) 4 params
- `test_livekit_credential_env_fallback` — set LIVEKIT_API_KEY and LIVEKIT_API_SECRET env vars, verify credential resolution works
- `test_livekit_unknown_operation_errors` — verify unknown operations return error
- `test_livekit_create_token_backward_compat` — "create-token" still works as an alias for "join"

**Implementation:**

1. Restructure `execute_operation` to standard 4-param contract: `(operation, entity_id, data, session)`
2. Add `join_room()` — resolves credentials, creates token, returns `_entity_update` with `status: "connecting"` and `manifest_handle` (the JWT)
3. Add `sense_connection()` — checks if token is still valid (not expired), returns `_entity_update` with `status`
4. Add `leave_room()` — returns `_entity_update` with `status: "disconnected"` and `manifest_handle: null`
5. Unify credential resolution — use standard `credential::resolve_credential("livekit", session)` with env var fallback (LIVEKIT_API_KEY, LIVEKIT_API_SECRET)
6. "create-token" remains as alias for backward compatibility

**Phase 2 Complete When:**
- [ ] `execute_operation` follows 4-param contract
- [ ] All three lifecycle operations return `_entity_update`
- [ ] Credential resolution uses SessionBridge with env var fallback
- [ ] "create-token" backward compatible

### Phase 3: Host Dispatch (Rust)

**Goal:** LiveKit stoicheion wired in host.rs through `dispatch_to_module`.

**Tests:**
- `test_livekit_dispatch_manifest` — bootstrap, call `manifest_by_stoicheion("lk-join-room", ...)`, verify result contains `_entity_update`
- `test_livekit_dispatch_sense` — call `sense_by_stoicheion("lk-sense-connection", ...)`, verify entity update applied

**Implementation:**

1. Add `lk-join-room` match arm to `manifest_by_stoicheion` with `dispatch_to_module`
2. Add `lk-sense-connection` match arm to `sense_by_stoicheion` with `dispatch_to_module`
3. Add `lk-leave-room` match arm to `unmanifest_by_stoicheion` with `dispatch_to_module`

**Phase 3 Complete When:**
- [ ] All three stoicheion match arms in host.rs
- [ ] All use `dispatch_to_module` wrapping

### Phase 4: Verify

**Goal:** Everything works together.

```bash
cargo build -p kosmos 2>&1
cargo test -p kosmos --lib --tests 2>&1
cargo test -p kosmos --test webrtc_substrate 2>&1
```

**Phase 4 Complete When:**
- [ ] All existing tests pass
- [ ] 9 new tests pass
- [ ] WebRTC at stage 4 (dispatch + contract + entity update)

### Phase 5: Dissolve handler dispatch from build.rs

**Goal:** If no genesis modes still use `handler:` instead of `stoicheion:`, remove the false distinction from build.rs.

**Precondition:** Both PROMPT-SUBSTRATE-VOICE and PROMPT-SUBSTRATE-WEBRTC must be complete. If the other prompt hasn't been implemented yet, skip this phase — it will be done by whichever prompt runs second.

**Implementation:**

1. In `crates/kosmos/build.rs`, remove `handler: Option<String>` from the `ModeOp` struct
2. Remove the comment "Modes using `handler` instead (e.g. voice) are hand-wired, not generated" from `ModeOp`
3. Remove the comment "Collect modes that have stoicheion-based operations (not handler-based like voice)" from `generate_mode_dispatch`
4. Update the comment "genesis/*/modes/*.yaml (non-screen substrates with stoicheion dispatch)" — remove "with stoicheion dispatch" qualifier since all non-screen substrates now use stoicheion
5. The filtering logic (`if ops.manifest.stoicheion.is_some()`) can stay as a defensive check

**Phase 5 Complete When:**
- [ ] No `handler` field on `ModeOp`
- [ ] No comments referencing the handler/stoicheion distinction
- [ ] build.rs compiles and generates correct mode_dispatch.rs

### Phase 6: Reconciler + Reflexes + Daemon (Genesis)

**Goal:** Syndesmos has a transition-table reconciler, reflexes for connection state changes, and periodic connection health sensing.

**Tests:**
- `test_syndesmos_reconcile_disconnected_to_manifest` — create syndesmos entity with intent=connected, status=disconnected, reconcile, verify action_taken=="manifest"
- `test_syndesmos_reconcile_connected_to_sense` — intent=connected, status=connected → action_taken=="sense"
- `test_syndesmos_reconcile_failed_to_manifest` — intent=connected, status=failed → action_taken=="manifest"
- `test_syndesmos_reconcile_reconnecting_to_sense` — intent=connected, status=reconnecting → action_taken=="sense"
- `test_syndesmos_reconcile_connected_to_unmanifest` — intent=disconnected, status=connected → action_taken=="unmanifest"
- `test_syndesmos_reconcile_disconnected_to_none` — intent=disconnected, status=disconnected → action_taken=="none"
- `test_syndesmos_reconcile_suspended_connected` — intent=suspended, status=connected → action_taken=="unmanifest"
- `test_syndesmos_reconcile_suspended_disconnected` — intent=suspended, status=disconnected → action_taken=="none"

**Implementation:**

1. Create `genesis/aither/reconcilers/syndesmos.yaml` with `reconciler/syndesmos`:

```yaml
- eidos: reconciler
  id: reconciler/syndesmos
  data:
    target_eidos: syndesmos
    intent_field: intent
    actuality_field: status
    transitions:
      # Want connected, but disconnected or failed → manifest (join room)
      - intent: connected
        actual: [disconnected, failed]
        action: manifest

      # Want connected, currently reconnecting → sense (wait for resolution)
      - intent: connected
        actual: reconnecting
        action: sense

      # Want connected, already connected → sense (verify still healthy)
      - intent: connected
        actual: connected
        action: sense

      # Want disconnected, but connected or reconnecting → unmanifest (leave room)
      - intent: disconnected
        actual: [connected, reconnecting, connecting]
        action: unmanifest

      # Want disconnected, already disconnected → none
      - intent: disconnected
        actual: [disconnected, failed]
        action: none

      # Suspended — close connection but preserve intent for resume
      - intent: suspended
        actual: [connected, reconnecting, connecting]
        action: unmanifest

      - intent: suspended
        actual: [disconnected, failed, suspended]
        action: none
```

2. Create `genesis/aither/reflexes/syndesmos.yaml` with triggers and reflexes:

```yaml
# Trigger on intent change → reconcile
- eidos: trigger
  id: trigger/syndesmos-intent-change
  data:
    watch_field: intent
    on_change: true
    target_eidos: syndesmos

- eidos: reflex
  id: reflex/reconcile-syndesmos-on-intent
  data:
    trigger: trigger/syndesmos-intent-change
    action: reconcile
    reconciler_id: reconciler/syndesmos

# Trigger on status drift → reconcile
- eidos: trigger
  id: trigger/syndesmos-drift
  data:
    watch_field: status
    on_change: true
    target_eidos: syndesmos

- eidos: reflex
  id: reflex/reconcile-syndesmos-on-drift
  data:
    trigger: trigger/syndesmos-drift
    action: reconcile
    reconciler_id: reconciler/syndesmos
```

3. Create `genesis/aither/daemons/syndesmos.yaml` with periodic sensing:

```yaml
- eidos: daemon
  id: daemon/sense-syndesmos
  data:
    name: sense-syndesmos
    description: |
      Periodically sense all syndesmos entities to detect connection drift.
      When a connection drops (network failure, server restart),
      sensing updates status, which triggers reconciliation.
    type: interval
    enabled: true
    scope: dwelling
    config:
      interval_ms: 30000  # 30 seconds — connections can drop silently
      target_eidos: syndesmos
      filter: intent != "disconnected"
      action: sense
```

**Phase 6 Complete When:**
- [ ] `reconciler/syndesmos` exists with 8 transition rules
- [ ] `host.reconcile("reconciler/syndesmos", entity_id)` returns correct action for all intent/status combinations
- [ ] 2 triggers + 2 reflexes defined for intent-change and drift
- [ ] `daemon/sense-syndesmos` defined with 30s interval
- [ ] 8 new reconciler tests pass

### Phase 7: Verify Full Autonomic

**Goal:** WebRTC is fully autonomic — stage 6.

```bash
cargo build -p kosmos 2>&1
cargo test -p kosmos --lib --tests 2>&1
cargo test -p kosmos --test webrtc_substrate 2>&1
cargo test -p kosmos --test reconciler_generic 2>&1  # regression
```

**Phase 7 Complete When:**
- [ ] All existing tests pass
- [ ] 17 total new tests pass (9 dispatch + 8 reconciler)
- [ ] WebRTC at stage 6

---

## Files to Read

### Current implementation
- `crates/kosmos/src/livekit.rs` — execute_operation, create_token, LiveKitServer, resolve_credential
- `crates/kosmos/src/reflex.rs:895` — handle_signal stubs
- `crates/kosmos/src/host.rs:1984` — host.signal() delegation
- `genesis/aither/modes/webrtc.yaml` — mode/webrtc-livekit with handler: fields

### Entity definitions
- `genesis/aither/eide/aither.yaml:99` — eidos/syndesmos (intent, status, room_id, peer_id, retry logic)

### Pattern reference
- `crates/kosmos/src/dns.rs` — standard execute_operation with _entity_update
- `crates/kosmos/src/credential.rs` — resolve_credential helper (the pattern to follow)

---

## Files to Touch

| File | Change |
|------|--------|
| `genesis/aither/modes/webrtc.yaml` | **MODIFY** — replace `handler:` with `stoicheion:` for lifecycle ops |
| `crates/kosmos/src/livekit.rs` | **MODIFY** — restructure to 4-param contract, add join/sense/leave with `_entity_update`, unify credential resolution |
| `crates/kosmos/src/host.rs` | **MODIFY** — add `lk-join-room`, `lk-sense-connection`, `lk-leave-room` match arms |
| `crates/kosmos/tests/webrtc_substrate.rs` | **NEW** — 9 tests |
| `crates/kosmos/build.rs` | **MODIFY** — remove `handler` field from ModeOp, remove handler/stoicheion distinction comments (Phase 5, conditional on both media prompts complete) |
| `genesis/aither/reconcilers/syndesmos.yaml` | **NEW** — `reconciler/syndesmos` with transition table (8 rules) |
| `genesis/aither/reflexes/syndesmos.yaml` | **NEW** — 2 triggers + 2 reflexes for intent-change and drift |
| `genesis/aither/daemons/syndesmos.yaml` | **NEW** — `daemon/sense-syndesmos` (30s interval) |

---

## Success Criteria

**Overall Complete When:**
- [ ] All existing tests pass
- [ ] 17 new tests pass (9 dispatch + 8 reconciler)
- [ ] WebRTC at stage 6 (fully autonomic)
- [ ] mode_dispatch.rs generates webrtc-livekit entries
- [ ] No `handler:` fields remain in mode/webrtc-livekit lifecycle operations
- [ ] Credential resolution unified with standard path
- [ ] `host.reconcile("reconciler/syndesmos", entity_id)` dispatches correct actions
- [ ] Reflexes fire on intent-change and drift
- [ ] Daemon defined for periodic connection sensing

---

## What This Enables

1. **WebRTC fully autonomic** — same dispatch, reconciliation, and reactive infrastructure as every other substrate
2. **Self-healing connections** — connection drops → daemon senses → status: "disconnected" → reflex fires → reconciler reconnects (generates new token, re-manifests)
3. **Intent-driven lifecycle** — set intent: "connected" → join room. Set intent: "disconnected" → leave room. Set intent: "suspended" → close but keep intent for resume.
4. **Token refresh** — when sense detects expired token, reconciler re-manifests (generates new token)

---

## What Does NOT Change

1. **create_token() function** — internal JWT generation stays as-is
2. **LiveKitServer struct** — configuration extraction unchanged
3. **ParticipantGrants** — permission model unchanged
4. **eidos/syndesmos** — schema unchanged. `_entity_update` writes to existing `status` field
5. **Signal handling** — `host.signal()` and `handle_signal()` stubs stay for now. Signal is protocol exchange, not lifecycle.
6. **Existing livekit.rs tests** — all 4 existing tests continue to pass
7. **Other substrates** — untouched

---

## Scope Boundaries

**In scope**: Stoicheion names, standard contract, `_entity_update`, host.rs dispatch, credential unification. This is the dispatch plumbing.

**Out of scope**: Actual WebRTC connection management (peer connections, ICE, data channels). The manifest operation generates a token and sets connection intent — the actual WebRTC session runs in the Tauri app's client-side code. Connection state flows back to syndesmos entities through the Tauri command bridge.

**Out of scope**: Signal handling implementation. The signaling stubs in reflex.rs stay. Replacing them with real SDP/ICE exchange requires a running LiveKit server and is a separate prompt.

**Out of scope**: Daemon loop infrastructure (the actual interval-based execution loop that processes daemon entities). This prompt defines the daemon entity; the daemon loop is a separate concern.

---

*Traces to: the one-pattern principle (handler vs stoicheion is a false distinction), the syndesmos pattern (intent/status already embodies desired/actual state), the standard contract (every substrate follows execute_operation with 4 params), PROMPT-SUBSTRATE-STANDARD.md*
