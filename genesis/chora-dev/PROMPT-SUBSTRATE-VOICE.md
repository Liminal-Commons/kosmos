# Voice Substrate — Same Contract, Different Medium

*Prompt for Claude Code in the chora + kosmos repository context.*

*Converts voice from handler-dispatched to stoicheion-dispatched. Adds stoicheion names to mode/voice, restructures voice.rs to standard execute_operation contract, wires dispatch in host.rs, adds `_entity_update` to all operations, adds reconciler/voice-stream with transition table, reflexes for capture state changes, and daemon for periodic stream health sensing. After this work, voice is fully autonomic — same dispatch pattern, same reconciliation loop, same reactive infrastructure as every other substrate. Advances voice from stage 1 to stage 6.*

*Depends on: PROMPT-SUBSTRATE-STANDARD.md*

---

## Architectural Principle — One Dispatch Pattern

Every substrate follows one pattern:

```
genesis mode (stoicheion names) → build.rs generates mode_dispatch.rs → host.rs match arms → module::execute_operation → _entity_update → dispatch_to_module applies it
```

Voice currently uses `handler:` fields in genesis, bypassing the generated dispatch entirely. The build.rs comment says "Modes using `handler` instead (e.g. voice) are hand-wired, not generated." This is a false distinction. Audio capture is complex internally — but so is AWS request signing, Docker container management, and Cloudflare API calls. Internal complexity doesn't change the dispatch contract.

The voice mode has three lifecycle operations (manifest/sense/unmanifest) and two content operations (push_fragment/clarify). The lifecycle operations get stoicheion names and follow the standard pattern. The content operations stay as praxeis — they're invoked by the transcription callback, not by the reconciler.

---

## Methodology — DDD + TDD

This work follows **Doc → Test → Build → Verify**, non-negotiably.

1. **Doc (prescriptive)**: This prompt IS the prescriptive doc. The target state described here is what code must match.
2. **Test (assert the doc)**: Write tests that assert `_entity_update` presence in voice operations, stoicheion dispatch wiring, and standard execute_operation contract conformance. Tests should fail before implementation.
3. **Build (satisfy the tests)**: Implement until tests pass.
4. **Verify doc**: After implementation, update success criteria to reflect completion.

Voice operations that require audio hardware or transcription providers should be `#[ignore]`. Tests that verify the standard contract, `_entity_update` format, and dispatch routing use mock/test data — no audio, no network.

---

## Current State

### What Exists and Works

| Component | Location | Status |
|-----------|----------|--------|
| `mode/voice` | `genesis/soma/modes/voice.yaml` | Defined — uses `handler:` not `stoicheion:` |
| `VoiceSubstrate` struct | `voice.rs:58` | Working — stream mapping, on_transcript_fragment |
| `push_transcript_fragment()` | `voice.rs:166` | Working — one-shot convenience function |
| `eidos/accumulation` | `genesis/thyra/eide/thyra.yaml:75` | Defined — capture_state, clarification_status, raw_content, content |
| `eidos/voice-pipeline-config` | `genesis/thyra/eide/thyra.yaml:201` | Defined — audio device, VAD, transcription provider settings |
| Content operations (push_fragment, clarify) | `voice.yaml:96-140` | Defined — handler-based, invoked by transcription callback |

### What's Missing — The Three Gaps

**Gap 1: No stoicheion names.** `mode/voice` uses `handler:` fields. build.rs skips it during dispatch generation. No entries in mode_dispatch.rs. No match arms in host.rs. Voice is invisible to the standard dispatch path.

**Gap 2: No standard execute_operation contract.** voice.rs has `VoiceSubstrate::on_transcript_fragment()` (praxis-based) but NOT `execute_operation(operation, entity_id, data, session)`. The module doesn't conform to the 4-param contract every other substrate uses.

**Gap 3: No `_entity_update`.** `on_transcript_fragment` calls `host.invoke_praxis("thyra/append-fragment", ...)` to update the accumulation. This works for content — but the lifecycle operations (start stream, check stream, stop stream) have no mechanism to update entity state. When a stream starts or stops, the accumulation's `capture_state` isn't updated through the standard path.

---

## Target State

### mode/voice with stoicheion names

```yaml
- eidos: mode
  id: mode/voice
  data:
    name: voice
    topos: soma
    substrate: compute
    provider: local
    description: |
      Voice capture substrate — audio input, VAD, streaming transcription.
    operations:
      manifest:
        stoicheion: voice-start-stream
        description: Start voice capture stream with transcription pipeline.
        params:
          device_id:
            type: string
            default: "default"
          transcription_provider:
            type: string
            default: "whisper-local"
      sense:
        stoicheion: voice-sense-stream
        description: Query stream and capture state.
        params:
          manifest_handle:
            type: string
      unmanifest:
        stoicheion: voice-stop-stream
        description: Close voice capture stream.
        params:
          manifest_handle:
            type: string
```

Content operations (`push_fragment`, `clarify`) move out of the mode definition — they are praxeis invoked by the transcription callback, not lifecycle operations dispatched by the reconciler.

### voice.rs with standard contract

```rust
pub fn execute_operation(
    operation: &str,
    entity_id: &str,
    data: &Value,
    session: Option<&Arc<dyn SessionBridge>>,
) -> Result<Value> {
    match operation {
        "start" | "manifest" => start_stream(entity_id, data),
        "sense" | "check" => sense_stream(entity_id, data),
        "stop" | "unmanifest" => stop_stream(entity_id, data),
        _ => Err(...)
    }
}
```

### Voice operations return `_entity_update`

**start (manifest):**
```rust
Ok(json!({
    "status": "manifested",
    "entity_id": entity_id,
    "stoicheion": "voice-start-stream",
    "stream_id": stream_id,
    "_entity_update": {
        "capture_state": "listening",
        "actual_state": "active",
        "manifest_handle": stream_id,
        "last_reconciled_at": now
    }
}))
```

**sense:**
```rust
Ok(json!({
    "status": "sensed",
    "entity_id": entity_id,
    "stoicheion": "voice-sense-stream",
    "stream_status": status,   // active, paused, closed, failed
    "capture_state": capture,  // inactive, listening, processing
    "_entity_update": {
        "capture_state": capture,
        "actual_state": status,
        "last_sensed_at": now
    }
}))
```

**stop (unmanifest):**
```rust
Ok(json!({
    "status": "unmanifested",
    "entity_id": entity_id,
    "stoicheion": "voice-stop-stream",
    "_entity_update": {
        "capture_state": "inactive",
        "actual_state": "closed",
        "manifest_handle": null,
        "last_reconciled_at": now
    }
}))
```

### host.rs dispatch

```rust
// manifest_by_stoicheion:
"voice-start-stream" => self.dispatch_to_module(entity_id, data,
    crate::voice::execute_operation("start", entity_id, data, session_ref)),

// sense_by_stoicheion:
"voice-sense-stream" => self.dispatch_to_module(entity_id, data,
    crate::voice::execute_operation("sense", entity_id, data, session_ref)),

// unmanifest_by_stoicheion:
"voice-stop-stream" => self.dispatch_to_module(entity_id, data,
    crate::voice::execute_operation("stop", entity_id, data, session_ref)),
```

---

## Sequenced Work

### Phase 1: Genesis — Stoicheion Names (YAML)

**Goal:** mode/voice uses stoicheion dispatch, not handler dispatch.

**Implementation:**

1. In `genesis/soma/modes/voice.yaml`, replace `handler:` with `stoicheion:` for manifest, sense, unmanifest
2. Move content operations (push_fragment, clarify) out of the mode operations block — they belong as praxis documentation, not mode operations
3. Verify build.rs generates dispatch entries after change

**Phase 1 Complete When:**
- [ ] mode/voice uses `stoicheion:` for manifest/sense/unmanifest
- [ ] mode_dispatch.rs generates `("voice", "local", ...)` entries
- [ ] Content operations documented as praxeis, not mode operations

### Phase 2: Standard Contract + `_entity_update` (Rust)

**Goal:** voice.rs conforms to the 4-param execute_operation contract with `_entity_update` on all operations.

**Tests:**
- `test_voice_start_returns_entity_update` — call `execute_operation("start", ...)`, verify `_entity_update.capture_state == "listening"` and `_entity_update.actual_state == "active"`
- `test_voice_sense_returns_entity_update` — call `execute_operation("sense", ...)`, verify `_entity_update` contains `capture_state` and `actual_state`
- `test_voice_stop_returns_entity_update` — call `execute_operation("stop", ...)`, verify `_entity_update.capture_state == "inactive"` and `_entity_update.manifest_handle` is null
- `test_voice_execute_operation_contract` — verify the function signature matches the standard 4-param contract
- `test_voice_unknown_operation_errors` — verify unknown operations return error

**Implementation:**

1. Add `pub fn execute_operation(operation, entity_id, data, session) -> Result<Value>` to voice.rs
2. Implement `start_stream()` — for now, create a stream ID, register mapping, return `_entity_update`. The actual audio capture integration is a separate concern.
3. Implement `sense_stream()` — check if stream is registered, return current state with `_entity_update`
4. Implement `stop_stream()` — unregister stream, return `_entity_update`
5. Keep `VoiceSubstrate` and `on_transcript_fragment` as-is — they handle content flow, not lifecycle dispatch
6. Keep `push_transcript_fragment` convenience function as-is

**Phase 2 Complete When:**
- [ ] `execute_operation` follows 4-param contract
- [ ] All three lifecycle operations return `_entity_update`
- [ ] Existing VoiceSubstrate and content functions unchanged

### Phase 3: Host Dispatch (Rust)

**Goal:** voice stoicheion wired in host.rs through `dispatch_to_module`.

**Tests:**
- `test_voice_dispatch_manifest` — bootstrap, call `manifest_by_stoicheion("voice-start-stream", ...)`, verify result contains `_entity_update`
- `test_voice_dispatch_sense` — call `sense_by_stoicheion("voice-sense-stream", ...)`, verify entity update applied

**Implementation:**

1. Add `voice-start-stream` match arm to `manifest_by_stoicheion` with `dispatch_to_module`
2. Add `voice-sense-stream` match arm to `sense_by_stoicheion` with `dispatch_to_module`
3. Add `voice-stop-stream` match arm to `unmanifest_by_stoicheion` with `dispatch_to_module`

**Phase 3 Complete When:**
- [ ] All three stoicheion match arms in host.rs
- [ ] All use `dispatch_to_module` wrapping
- [ ] Entity data updated after dispatch

### Phase 4: Verify

**Goal:** Everything works together.

```bash
cargo build -p kosmos 2>&1
cargo test -p kosmos --lib --tests 2>&1
cargo test -p kosmos --test voice_substrate 2>&1
```

**Phase 4 Complete When:**
- [ ] All existing tests pass
- [ ] 7 new tests pass
- [ ] Voice at stage 4 (dispatch + contract + entity update) — then continues to stage 6

### Phase 5: Dissolve handler dispatch from build.rs

**Goal:** If no genesis modes still use `handler:` instead of `stoicheion:`, remove the false distinction from build.rs.

**Precondition:** Both PROMPT-SUBSTRATE-VOICE and PROMPT-SUBSTRATE-WEBRTC must be complete. If the other prompt hasn't been implemented yet, skip this phase — it will be done by whichever prompt runs second.

**Implementation:**

1. In `crates/kosmos/build.rs`, remove `handler: Option<String>` from the `ModeOp` struct
2. Remove the comment "Modes using `handler` instead (e.g. voice) are hand-wired, not generated" from `ModeOp`
3. Remove the comment "Collect modes that have stoicheion-based operations (not handler-based like voice)" from `generate_mode_dispatch`
4. Update the comment "genesis/*/modes/*.yaml (non-screen substrates with stoicheion dispatch)" — remove "with stoicheion dispatch" qualifier since all non-screen substrates now use stoicheion
5. The filtering logic (`if ops.manifest.stoicheion.is_some()`) can stay as a defensive check — it's harmless and protects against future modes that might legitimately lack stoicheion

**Phase 5 Complete When:**
- [ ] No `handler` field on `ModeOp`
- [ ] No comments referencing the handler/stoicheion distinction
- [ ] build.rs compiles and generates correct mode_dispatch.rs

### Phase 6: Reconciler + Reflexes + Daemon (Genesis)

**Goal:** Voice has a transition-table reconciler, reflexes for state changes, and periodic stream sensing.

**Tests:**
- `test_voice_reconcile_inactive_to_manifest` — create accumulation entity with desired_state=active, actual_state=inactive, reconcile, verify action_taken=="manifest"
- `test_voice_reconcile_active_to_sense` — desired_state=active, actual_state=active → action_taken=="sense"
- `test_voice_reconcile_failed_to_manifest` — desired_state=active, actual_state=failed → action_taken=="manifest"
- `test_voice_reconcile_active_to_unmanifest` — desired_state=inactive, actual_state=active → action_taken=="unmanifest"
- `test_voice_reconcile_inactive_to_none` — desired_state=inactive, actual_state=inactive → action_taken=="none"

**Implementation:**

1. Create `genesis/soma/reconcilers/voice.yaml` with `reconciler/voice-stream`:

```yaml
- eidos: reconciler
  id: reconciler/voice-stream
  data:
    target_eidos: accumulation
    intent_field: desired_state
    actuality_field: actual_state
    transitions:
      - intent: active
        actual: [inactive, closed]
        action: manifest
      - intent: active
        actual: active
        action: sense
      - intent: active
        actual: failed
        action: manifest
      - intent: inactive
        actual: [active, paused]
        action: unmanifest
      - intent: inactive
        actual: [inactive, closed]
        action: none
```

2. Create `genesis/soma/reflexes/voice.yaml` with triggers and reflexes:

```yaml
# Trigger on desired_state change → reconcile
- eidos: trigger
  id: trigger/voice-stream-intent-change
  data:
    watch_field: desired_state
    on_change: true
    target_eidos: accumulation

- eidos: reflex
  id: reflex/reconcile-voice-on-intent
  data:
    trigger: trigger/voice-stream-intent-change
    action: reconcile
    reconciler_id: reconciler/voice-stream

# Trigger on actual_state drift → reconcile
- eidos: trigger
  id: trigger/voice-stream-drift
  data:
    watch_field: actual_state
    on_change: true
    target_eidos: accumulation

- eidos: reflex
  id: reflex/reconcile-voice-on-drift
  data:
    trigger: trigger/voice-stream-drift
    action: reconcile
    reconciler_id: reconciler/voice-stream
```

3. Create `genesis/soma/daemons/voice.yaml` with periodic sensing:

```yaml
- eidos: daemon
  id: daemon/sense-voice-streams
  data:
    name: sense-voice-streams
    description: |
      Periodically sense all voice stream entities to detect drift.
      When a stream dies (process crash, audio device disconnect),
      sensing updates actual_state, which triggers reconciliation.
    type: interval
    enabled: true
    scope: dwelling
    config:
      interval_ms: 10000  # 10 seconds — voice streams can die fast
      target_eidos: accumulation
      filter: actual_state != "inactive"
      action: sense
```

**Phase 6 Complete When:**
- [ ] `reconciler/voice-stream` exists with 5 transition rules
- [ ] `host.reconcile("reconciler/voice-stream", entity_id)` returns correct action for all intent/actual combinations
- [ ] 2 triggers + 2 reflexes defined for intent-change and drift
- [ ] `daemon/sense-voice-streams` defined with 10s interval
- [ ] 5 new reconciler tests pass

### Phase 7: Verify Full Autonomic

**Goal:** Voice is fully autonomic — stage 6.

```bash
cargo build -p kosmos 2>&1
cargo test -p kosmos --lib --tests 2>&1
cargo test -p kosmos --test voice_substrate 2>&1
cargo test -p kosmos --test reconciler_generic 2>&1  # regression
```

**Phase 7 Complete When:**
- [ ] All existing tests pass
- [ ] 12 total new tests pass (7 dispatch + 5 reconciler)
- [ ] Voice at stage 6

---

## Files to Read

### Current implementation
- `crates/kosmos/src/voice.rs` — VoiceSubstrate, on_transcript_fragment, push_transcript_fragment
- `genesis/soma/modes/voice.yaml` — mode/voice with handler: fields

### Pattern reference
- `crates/kosmos/src/dns.rs` — standard execute_operation example
- `crates/kosmos/src/host.rs` — dispatch_to_module pattern
- `genesis/dynamis/modes/dynamis.yaml` — stoicheion format in mode definitions

### Entity definitions
- `genesis/thyra/eide/thyra.yaml:75` — eidos/accumulation (target entity for voice state)
- `genesis/thyra/eide/thyra.yaml:201` — eidos/voice-pipeline-config (capture settings)

---

## Files to Touch

| File | Change |
|------|--------|
| `genesis/soma/modes/voice.yaml` | **MODIFY** — replace `handler:` with `stoicheion:` for lifecycle ops, remove content ops from mode definition |
| `crates/kosmos/src/voice.rs` | **MODIFY** — add `execute_operation` with standard contract, `_entity_update` on all lifecycle ops |
| `crates/kosmos/src/host.rs` | **MODIFY** — add `voice-start-stream`, `voice-sense-stream`, `voice-stop-stream` match arms |
| `crates/kosmos/tests/voice_substrate.rs` | **NEW** — 7 tests |
| `crates/kosmos/build.rs` | **MODIFY** — remove `handler` field from ModeOp, remove handler/stoicheion distinction comments (Phase 5, conditional on both media prompts complete) |
| `genesis/soma/reconcilers/voice.yaml` | **NEW** — `reconciler/voice-stream` with transition table |
| `genesis/soma/reflexes/voice.yaml` | **NEW** — 2 triggers + 2 reflexes for intent-change and drift |
| `genesis/soma/daemons/voice.yaml` | **NEW** — `daemon/sense-voice-streams` (10s interval) |

---

## Success Criteria

**Overall Complete When:**
- [ ] All existing tests pass
- [ ] 12 new tests pass (7 dispatch + 5 reconciler)
- [ ] Voice at stage 6 (fully autonomic)
- [ ] mode_dispatch.rs generates voice entries
- [ ] No `handler:` fields remain in mode/voice lifecycle operations
- [ ] `host.reconcile("reconciler/voice-stream", entity_id)` dispatches correct actions
- [ ] Reflexes fire on intent-change and drift
- [ ] Daemon defined for periodic stream sensing

---

## What This Enables

1. **Voice fully autonomic** — same dispatch, reconciliation, and reactive infrastructure as every other substrate
2. **Self-healing streams** — stream dies (crash, device disconnect) → daemon senses → actual_state: "closed" → reflex fires → reconciler restarts
3. **Intent-driven lifecycle** — set desired_state: "active" → stream starts. Set desired_state: "inactive" → stream stops. The reconciler handles the transition.
4. **Voice-authoring resilient** — accumulation persists even if the stream fails. Reconciler restarts the stream; content isn't lost.

---

## What Does NOT Change

1. **VoiceSubstrate struct** — stream mapping and content callback handling stays. This is the transcription bridge, not lifecycle dispatch.
2. **on_transcript_fragment / push_transcript_fragment** — content flow stays praxis-based. Transcription callbacks invoke praxeis, not stoicheion.
3. **eidos/accumulation** — schema unchanged. `_entity_update` writes to existing fields (capture_state, status).
4. **eidos/voice-pipeline-config** — configuration entity unchanged.
5. **Clarification pipeline** — LLM clarification (manteia) unchanged. Still triggered by praxis.
6. **Other substrates** — untouched.

---

## Scope Boundaries

**In scope**: Stoicheion names, standard contract, `_entity_update`, host.rs dispatch. This is the dispatch plumbing that makes voice visible to the autonomic loop.

**Out of scope**: Actual audio capture implementation (requires Tauri audio APIs), transcription provider integration (Deepgram, Whisper). The manifest operation creates a stream ID and registers state — the actual audio pipeline integration is a separate concern.

**Out of scope**: Daemon loop infrastructure (the actual interval-based execution loop that processes daemon entities). This prompt defines the daemon entity; the daemon loop is a separate concern.

---

*Traces to: the one-pattern principle (handler vs stoicheion is a false distinction), the standard contract (every substrate follows execute_operation with 4 params), the `_entity_update` convention (every operation reports state change), PROMPT-SUBSTRATE-STANDARD.md*
