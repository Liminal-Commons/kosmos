# Voice Activity & Device Selection — Intelligent Voice Pipeline

*Prompt for Claude Code in the chora + kosmos repository context.*

*After this work, the voice pipeline is intelligent: it detects voice activity, segments speech from silence, transcribes only speech segments, and reports continuous signal state to the screen substrate. Users can select audio input devices and whisper configuration. The fixed 1-second inference window is replaced by VAD-driven segmentation. Continuous voice signals (energy, VAD) flow through a dedicated signal channel — ontologically distinct from entity state.*

*Depends on: PROMPT-VOICE-DECOMPOSITION.md (audio-capture + transcription modes), PROMPT-WHISPER-RS.md (in-process whisper-rs). Both complete.*

---

## Architectural Principle — Sensing vs Being

Entity state is being — it has lifecycle, desired/actual, is reconciled. Voice energy is not being. It is sensing — a continuous observation of the substrate's own activity. The distinction matters:

| | Entity State (Being) | Voice Signal (Sensing) |
|---|---|---|
| Nature | Lifecycle, reconciled | Continuous measurement |
| Frequency | Low (user actions, 0.1-2Hz) | High (audio frames, 10-20Hz) |
| Persistence | Stored in graph | Ephemeral, overwritten |
| Transport | Entity update → WebSocket → refetch → binding → DOM | Signal event → WebSocket → SolidJS signal → CSS |
| Examples | desired_state, device_id, whisper_model, segment_status | energy_db, voice_active |

The current architecture has one transport: entity state changes flow through the graph, over WebSocket, through reactive bindings, to the DOM. This is correct for lifecycle state. It is wrong for continuous signals — entity updates at 20Hz would trigger 20 refetches per second, each an HTTP GET.

The one right way: entity state for being, signal events for sensing. Both flow over the same WebSocket, but the frontend consumes them differently. Entity events trigger refetch and binding resolution. Signal events update a SolidJS signal directly — no refetch, no entity, just a value.

```
Entity state path (being):
  entity update → ChangeListener → WsEvent::EntityUpdated → refetch → binding → DOM

Signal path (sensing):
  audio chunk → compute energy/VAD → WsEvent::VoiceSignal → SolidJS signal → CSS
```

Both use the existing `tokio::sync::broadcast` channel in `websocket.rs`. The signal path adds a new `WsEvent` variant, not a new transport.

### Device Selection Is Entity State

Available audio devices are ephemeral hardware state, but the *selected* device is entity configuration. `audio-source/default.device_id` is already an entity field. Changing it is an entity update that triggers reconciliation — stop capture on old device, start on new one. Device enumeration is a praxis that senses available hardware.

### Config Change Is Drift

When `device_id` or `whisper_model` changes while `desired_state` remains `active`, the running session uses the old config. The entity's actuality has drifted from intent — not in state (still `active`) but in configuration. The reconciler must detect config drift and restart the session.

The pattern: update config fields + set `actual_state: closed` (while `desired_state` stays `active`). The drift trigger fires. The reconciler re-manifests with the new config.

---

## Methodology — DDD + TDD

This work follows **Doc → Test → Build → Verify**, non-negotiably.

1. **Doc (prescriptive)**: This prompt IS the prescriptive doc.
2. **Test (assert the doc)**: Write tests that assert the target state.
3. **Build (satisfy the tests)**: Implement until tests pass.
4. **Verify doc**: After implementation, update success criteria.

**Empirical emphasis.** VAD thresholds and timing parameters are tuned against real audio. Unit tests verify computation correctness; integration testing verifies the user experience.

---

## Current State

### What Exists and Works

| Component | Location | Status |
|-----------|----------|--------|
| Audio capture (cpal, in-process) | `crates/kosmos/src/voice.rs:125-232` | Working — manifest/sense/unmanifest |
| Transcription (whisper-rs, in-process) | `crates/kosmos/src/voice.rs:352-441` | Working — manifest/sense/unmanifest |
| Fixed 1-second inference loop | `crates/kosmos/src/voice.rs:549-631` | Working — but processes silence, no VAD |
| Resampler (downsample_to_16k_mono_f32) | `crates/kosmos/src/voice.rs:641-686` | Working — keep |
| device_id field on eidos/audio-source | `genesis/soma/eide/voice.yaml` | Defined — not wired to device selection |
| whisper_model/language/threads on eidos/transcriber | `genesis/soma/eide/voice.yaml` | Defined — config change doesn't restart |
| Toggle praxeis | `genesis/soma/praxeis/voice.yaml` | Working — flip desired_state |
| Autonomic triple (triggers + reflexes + daemons) | `genesis/soma/reflexes/` | Working — intent-changed + drift + audio-ready |
| Reconcilers | `genesis/soma/reconcilers/` | Working — manifest/sense/unmanifest transitions |
| WebSocket broadcast channel | `crates/kosmos-mcp/src/websocket.rs` | Working — `tokio::sync::broadcast<WsEvent>` |
| WsEvent enum (entity/bond events) | `crates/kosmos-mcp/src/websocket.rs:28-78` | Working — needs VoiceSignal variant |
| Frontend WebSocket listener | `app/src/stores/kosmos.ts` | Working — handles entity events |

### What's Missing — The Gaps

1. **No device enumeration.** No praxis to list available audio input devices. User cannot select a device.

2. **No config-change restart.** Changing `device_id` or `whisper_model` while active doesn't restart the session. The reconciler sees intent=active, actual=active → sense (not re-manifest).

3. **No voice activity detection.** The inference loop processes every chunk equally. No energy computation, no VAD, no silence detection. GPU cycles wasted on silence.

4. **No signal channel.** No `WsEvent::VoiceSignal` variant. No mechanism to send high-frequency ephemeral state to the frontend. No frontend signal store.

5. **No segment detection.** Fixed 1-second windows ignore speech boundaries. A word split across windows produces garbage. No voice onset/offset detection.

6. **Dead code: voice_capture.rs.** `app/src-tauri/src/voice_capture.rs` is the old Python whisper-server bridge — tungstenite, Deepgram JSON, tokio tasks. Superseded by the kosmos substrate approach. Dead code is contextual poison.

---

## Target State

### 1. Device Enumeration

New praxis `soma/list-audio-devices` returns available input devices:

```yaml
# genesis/soma/praxeis/voice.yaml — new praxis
- eidos: praxis
  id: praxis/soma/list-audio-devices
  data:
    name: list-audio-devices
    description: "Enumerate available audio input devices via cpal."
    visible: true
    steps:
      - step: custom
        stoicheion: list-audio-devices
```

In Rust (`voice.rs`), the `list-audio-devices` operation returns:

```json
{
  "devices": [
    { "id": "default", "name": "MacBook Pro Microphone", "is_default": true },
    { "id": "External Mic", "name": "External Mic", "is_default": false }
  ]
}
```

New praxis `soma/update-audio-device` changes the device and cycles reconciliation:

```yaml
- eidos: praxis
  id: praxis/soma/update-audio-device
  data:
    name: update-audio-device
    description: "Change audio input device. Cycles reconciliation if active."
    visible: true
    steps:
      - step: read
        entity_id: "{{ params.entity_id }}"
        output: entity
      - step: update
        entity_id: "{{ params.entity_id }}"
        data:
          device_id: "{{ params.device_id }}"
          actual_state: "closed"
```

Setting `actual_state: closed` while `desired_state` remains `active` triggers the drift reflex → reconciler re-manifests with the new `device_id`.

### 2. Config Change Praxis

Same pattern for transcriber config:

```yaml
- eidos: praxis
  id: praxis/soma/update-transcriber-config
  data:
    name: update-transcriber-config
    description: "Change whisper config. Cycles reconciliation if active."
    visible: true
    steps:
      - step: read
        entity_id: "{{ params.entity_id }}"
        output: entity
      - step: update
        entity_id: "{{ params.entity_id }}"
        data:
          whisper_model: "{{ params.whisper_model | default: entity.data.whisper_model }}"
          language: "{{ params.language | default: entity.data.language }}"
          whisper_threads: "{{ params.whisper_threads | default: entity.data.whisper_threads }}"
          actual_state: "closed"
```

### 3. Voice Signal Channel

New `WsEvent` variant:

```rust
// crates/kosmos-mcp/src/websocket.rs
#[derive(Debug, Clone, Serialize)]
#[serde(tag = "type", rename_all = "snake_case")]
pub enum WsEvent {
    // ... existing variants ...

    /// Ephemeral voice signal — not entity state, not persisted.
    VoiceSignal {
        entity_id: String,
        energy_db: f32,
        voice_active: bool,
    },
}
```

### 4. Energy + VAD Computation

In `voice.rs`, the inference loop computes energy and VAD on every chunk:

```rust
// Voice Activity Detector state
struct VadState {
    /// RMS energy in dB (updated per chunk)
    energy_db: f32,
    /// Is voice currently active
    voice_active: bool,
    /// Consecutive frames above onset threshold
    onset_frames: u32,
    /// Consecutive frames below offset threshold
    offset_frames: u32,
}

// Thresholds (tunable)
const VAD_ONSET_DB: f32 = -35.0;    // Energy above this = potential speech
const VAD_OFFSET_DB: f32 = -45.0;   // Energy below this = potential silence
const VAD_ONSET_FRAMES: u32 = 3;    // Frames above onset to confirm speech
const VAD_OFFSET_FRAMES: u32 = 15;  // Frames below offset to confirm silence (~750ms at 20Hz)
```

Energy computation per chunk:
```rust
let rms = (samples.iter().map(|s| s * s).sum::<f32>() / samples.len() as f32).sqrt();
let db = 20.0 * rms.max(1e-10).log10();
```

### 5. Signal State in AudioSession

Signal state is stored on the `AudioSession` using atomics (lock-free, safe for audio thread timing):

```rust
struct AudioSession {
    // ... existing fields ...
    /// Latest energy in dB (f32 stored as u32 bits for atomic access)
    energy_db: Arc<std::sync::atomic::AtomicU32>,
    /// Voice activity detected
    voice_active: Arc<std::sync::atomic::AtomicBool>,
}
```

Public API for reading signal state:

```rust
/// Read the current voice signal for an entity.
/// Returns None if no audio session exists for the entity.
pub fn read_voice_signal(entity_id: &str) -> Option<VoiceSignal> {
    let sessions = audio_sessions().lock().unwrap();
    sessions.get(entity_id).map(|s| VoiceSignal {
        entity_id: entity_id.to_string(),
        energy_db: f32::from_bits(s.energy_db.load(Ordering::Relaxed)),
        voice_active: s.voice_active.load(Ordering::Relaxed),
    })
}
```

### 6. Signal Broadcast Timer

In `http.rs`, spawn a timer that reads signal state and broadcasts:

```rust
// In serve_http(), after creating ws_state:
let signal_tx = ws_tx.clone();
tokio::spawn(async move {
    let mut interval = tokio::time::interval(Duration::from_millis(100)); // 10Hz
    loop {
        interval.tick().await;
        if let Some(signal) = kosmos::voice::read_voice_signal("audio-source/default") {
            let _ = signal_tx.send(WsEvent::VoiceSignal {
                entity_id: signal.entity_id,
                energy_db: signal.energy_db,
                voice_active: signal.voice_active,
            });
        }
    }
});
```

### 7. Frontend Signal Store

In `app/src/stores/kosmos.ts`, handle the new event type:

```typescript
// New SolidJS signal for voice state (separate from entity store)
const [voiceSignal, setVoiceSignal] = createSignal<VoiceSignal | null>(null);

// In handleWsEvent():
case "voice_signal":
    setVoiceSignal({
        entityId: event.entity_id,
        energyDb: event.energy_db,
        voiceActive: event.voice_active,
    });
    break;
```

This signal is exported and available to render-spec bindings or direct component use. It updates at 10Hz with no entity refetch.

### 8. Segment-Based Transcription

Replace the fixed 1-second window with VAD-segmented inference:

```rust
fn run_inference_loop(/* ... existing params ... */) -> Result<(), String> {
    // ... model loading ...
    let mut vad = VadState::new();
    let mut segment_buffer: Vec<f32> = Vec::new();
    let mut in_segment = false;

    loop {
        // ... receive audio chunk, check stop ...

        let pcm = downsample_to_16k_mono_f32(&chunk, sample_rate, channels);

        // Compute energy + VAD on every chunk
        vad.update(&pcm);

        // Update signal state atomics (read by signal broadcast timer)
        energy_db_atomic.store(vad.energy_db.to_bits(), Ordering::Relaxed);
        voice_active_atomic.store(vad.voice_active, Ordering::Relaxed);

        if vad.voice_active {
            if !in_segment {
                // Voice onset — start new segment
                in_segment = true;
                // Update entity: segment_status = detecting
                entity_updates.lock().unwrap().push(("segment_status", "detecting"));
            }
            segment_buffer.extend_from_slice(&pcm);
        } else if in_segment {
            // Voice offset — flush segment to whisper
            if segment_buffer.len() >= 8000 { // At least 0.5s of speech
                // Update entity: segment_status = transcribing
                entity_updates.lock().unwrap().push(("segment_status", "transcribing"));

                // Run whisper on the segment
                run_whisper_inference(&mut state, &params_template, &segment_buffer, &transcripts);

                // Update entity: segment_status = idle
                entity_updates.lock().unwrap().push(("segment_status", "idle"));
            }
            segment_buffer.clear();
            in_segment = false;
        }
    }
}
```

`segment_status` is an entity field on `eidos/transcriber` — it changes at speech-event frequency (1-2Hz), appropriate for entity updates.

### 9. Transcriber Eidos Update

Add `segment_status` field:

```yaml
# genesis/soma/eide/voice.yaml — transcriber eidos
- eidos: eidos
  id: eidos/transcriber
  data:
    name: transcriber
    fields:
      # ... existing fields ...
      segment_status:
        type: string
        default: "idle"
        description: "Current segment lifecycle: idle | detecting | transcribing"
```

### 10. Dead Code Deletion

Delete `app/src-tauri/src/voice_capture.rs`. Remove any references to it from `main.rs`. Dead code is contextual poison.

---

## Sequenced Work

### Phase 1: Device & Config Praxeis

**Goal:** Users can enumerate devices and change audio/whisper config with automatic reconciliation restart.

**Tests:**
- `test_list_audio_devices` — calling `list-audio-devices` returns a non-empty device list with id, name, is_default fields
- `test_update_audio_device_cycles_reconciliation` — changing device_id on an audio-source sets actual_state=closed, triggering drift
- `test_update_transcriber_config_cycles_reconciliation` — changing whisper_model sets actual_state=closed, triggering drift

**Implementation:**
1. Add `list-audio-devices` operation to `voice.rs` `execute_operation()` match
2. Implement `list_audio_devices()` using `cpal::default_host().input_devices()`
3. Add praxis definitions to `genesis/soma/praxeis/voice.yaml`
4. Wire `list-audio-devices` stoicheion in `mode_dispatch.rs` (or as a standalone praxis step)
5. Verify reconciler restarts session with new config after drift trigger fires

**Phase 1 Complete When:**
- [ ] `list-audio-devices` returns real device list
- [ ] Changing device_id while active triggers drift → re-manifest on new device
- [ ] Changing whisper_model while active triggers drift → re-manifest with new model
- [ ] All existing voice tests still pass

### Phase 2: Voice Activity Signal

**Goal:** Energy and VAD computed inline, signal state readable, broadcast over WebSocket, consumed by frontend signal store.

**Tests:**
- `test_energy_computation` — known waveform produces expected dB value
- `test_vad_onset_detection` — energy above threshold for N frames → voice_active = true
- `test_vad_offset_detection` — energy below threshold for M frames → voice_active = false
- `test_vad_silence_stays_inactive` — sustained low energy → voice_active stays false
- `test_read_voice_signal` — returns signal state from active audio session
- `test_read_voice_signal_no_session` — returns None when no session active

**Implementation:**
1. Define `VadState` struct with energy/VAD computation
2. Add `energy_db: Arc<AtomicU32>` and `voice_active: Arc<AtomicBool>` to `AudioSession`
3. Pass atomics to inference loop (or compute in a fork of the audio consumer)
4. Compute energy + VAD on every chunk in the inference loop
5. Update atomics after computation
6. Add `pub fn read_voice_signal(entity_id: &str) -> Option<VoiceSignal>` to `voice.rs`
7. Add `WsEvent::VoiceSignal` variant to `websocket.rs`
8. Spawn signal broadcast timer in `http.rs` (10Hz, reads `read_voice_signal`)
9. Add `voice_signal` case to frontend `handleWsEvent()` in `kosmos.ts`
10. Export `voiceSignal()` accessor from the store

**Phase 2 Complete When:**
- [ ] Energy computation matches expected values for known waveforms
- [ ] VAD detects onset and offset with configurable thresholds
- [ ] `read_voice_signal()` returns current energy/VAD from active session
- [ ] `VoiceSignal` events appear on WebSocket at ~10Hz when audio is active
- [ ] Frontend `voiceSignal()` signal updates in real-time

### Phase 3: Segment-Based Transcription

**Goal:** Replace fixed 1-second window with VAD-segmented inference. Only speech segments go to whisper. `segment_status` reflects the current segment lifecycle on the transcriber entity.

**Tests:**
- `test_segment_detection_speech_then_silence` — speech followed by silence produces one segment
- `test_segment_detection_silence_only` — sustained silence produces no segments
- `test_segment_minimum_duration` — segments shorter than 0.5s are discarded (noise)
- `test_segment_status_transitions` — entity updates flow: idle → detecting → transcribing → idle

**Implementation:**
1. Add `segment_status` field to `eidos/transcriber` in genesis
2. Replace the fixed-window accumulation in `run_inference_loop` with VAD-gated segment buffer
3. On voice onset: start buffering, update `segment_status: detecting`
4. On voice offset: flush buffer to whisper if ≥ 0.5s, update `segment_status: transcribing`
5. After whisper returns: push transcript, update `segment_status: idle`
6. Entity updates for `segment_status` flow through the standard `_entity_update` mechanism
7. Delete `app/src-tauri/src/voice_capture.rs` and remove references

**Phase 3 Complete When:**
- [ ] Only speech segments are sent to whisper (silence is skipped)
- [ ] `segment_status` transitions correctly on the transcriber entity
- [ ] Transcription quality improves (no garbage from silence, no mid-word splits)
- [ ] `voice_capture.rs` deleted
- [ ] All existing tests pass

---

## Files to Read

### Voice Substrate
- `crates/kosmos/src/voice.rs` — current inference loop, session registries, audio capture
- `crates/kosmos/src/mode_dispatch.rs` — stoicheion dispatch table (add new operations)
- `crates/kosmos/src/host.rs` — substrate operation dispatch path

### WebSocket + Signal Transport
- `crates/kosmos-mcp/src/websocket.rs` — WsEvent enum, broadcast channel, WsChangeListener
- `crates/kosmos-mcp/src/http.rs` — serve_http(), where broadcast channel is created, where signal timer goes

### Genesis
- `genesis/soma/eide/voice.yaml` — audio-source + transcriber eidos fields
- `genesis/soma/praxeis/voice.yaml` — toggle praxeis (add device/config praxeis)
- `genesis/soma/reconcilers/audio-capture.yaml` — reconciler transitions
- `genesis/soma/reconcilers/transcription.yaml` — reconciler transitions

### Frontend
- `app/src/stores/kosmos.ts` — handleWsEvent(), entity change callbacks, signal store location
- `app/src/lib/http-client.ts` — WebSocket connection setup

### Dead Code
- `app/src-tauri/src/voice_capture.rs` — old Python whisper bridge, to delete

---

## Files to Touch

| File | Change |
|------|--------|
| `crates/kosmos/src/voice.rs` | **MODIFY** — add VadState, energy/VAD computation, segment buffering, read_voice_signal API, list_audio_devices |
| `crates/kosmos/src/mode_dispatch.rs` | **MODIFY** — add `list-audio-devices` dispatch entry |
| `crates/kosmos-mcp/src/websocket.rs` | **MODIFY** — add `WsEvent::VoiceSignal` variant |
| `crates/kosmos-mcp/src/http.rs` | **MODIFY** — spawn signal broadcast timer |
| `genesis/soma/eide/voice.yaml` | **MODIFY** — add `segment_status` field to transcriber |
| `genesis/soma/praxeis/voice.yaml` | **MODIFY** — add list-audio-devices, update-audio-device, update-transcriber-config praxeis |
| `app/src/stores/kosmos.ts` | **MODIFY** — add voice_signal handling + signal store |
| `app/src-tauri/src/voice_capture.rs` | **DELETE** — dead code (old Python whisper bridge) |
| `crates/kosmos/tests/voice_activity.rs` | **NEW** — VAD computation + signal tests |

---

## Success Criteria

### Phase 1
- [ ] `list-audio-devices` returns device list from cpal
- [ ] Device change triggers reconciliation restart
- [ ] Config change triggers reconciliation restart
- [ ] All existing tests pass

### Phase 2
- [ ] Energy computation verified against known waveforms
- [ ] VAD onset/offset detection with tunable thresholds
- [ ] `VoiceSignal` WebSocket events at ~10Hz during active capture
- [ ] Frontend signal store receives and exposes voice signal

### Phase 3
- [ ] Segment-based inference (only speech goes to whisper)
- [ ] `segment_status` entity field transitions correctly
- [ ] `voice_capture.rs` deleted
- [ ] All tests pass

**Overall Complete When:**
- [ ] All 3 phases complete
- [ ] No fixed-window inference — all transcription is VAD-segmented
- [ ] Voice signal channel established (entity state for being, signal events for sensing)
- [ ] Device and config selection working via praxeis
- [ ] Dead code removed

---

## What This Enables

- **Device selection UI** — presentation layer can call `list-audio-devices` and bind to `device_id`
- **Visual voice feedback** — frontend `voiceSignal()` drives button shading, energy indicators via CSS
- **Segment status indication** — `@fed-by-transcriber.data.segment_status` binding shows detecting/transcribing
- **Reduced GPU waste** — whisper only runs on speech, not silence
- **Config selection UI** — presentation layer can update whisper_model/language/threads
- **Future VAD improvements** — VadState is a clean abstraction for swapping in better algorithms (Silero ONNX, etc.)

---

## What Does NOT Change

- **Render-specs and modes** — no presentation changes in this prompt. Device selector UI, button shading, and segment indicators are a separate prompt.
- **Accumulation and phasis** — transcript flow to accumulation unchanged.
- **Toggle praxeis** — existing soma/toggle-audio-intent and soma/toggle-transcriber-intent unchanged.
- **Reflexes, reconcilers, daemons** — existing autonomic triple unchanged (drift trigger already handles the config-change pattern).
- **WebSocket entity events** — existing entity/bond event flow unchanged. VoiceSignal is additive.
- **whisper-rs integration** — model loading, inference API, resampling all unchanged.

---

*Traces to: PROMPT-VOICE-DECOMPOSITION.md (voice coordination pattern), PROMPT-WHISPER-RS.md (in-process transcription), T11 (substrate-universal reconciliation), session discussion on sensing vs being.*
