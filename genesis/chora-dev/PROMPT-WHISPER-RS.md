# Whisper-RS — In-Process Transcription via whisper.cpp

*Prompt for Claude Code in the chora + kosmos repository context.*

*After this work, transcription runs in-process via whisper-rs (Rust bindings to whisper.cpp) with Silero VAD for utterance boundary detection. The Python whisper-server subprocess, its deployment entity, the depends-on bond, the dual toggle cascade, the WebSocket bridge, and the tungstenite dependency are all deleted. Transcription follows the same in-process pattern as audio-capture: load model on manifest, infer on audio, unload on unmanifest. No subprocess, no IPC.*

*Depends on: PROMPT-VOICE-DECOMPOSITION.md (audio-capture + transcription modes), PROMPT-WHISPER-PROCESS.md (deployment entity — being reversed).*

---

## Architectural Principle — Substrate Symmetry

Audio capture and transcription are both in-process compute operations. Audio capture uses cpal to open a microphone — no subprocess, no IPC. Transcription should use whisper-rs to run inference — same pattern. The Python whisper-server.py introduced an asymmetry: one substrate operation ran in-process (cpal), while its partner ran as a managed subprocess with deployment entities, process reconciliation, depends-on bonds, and WebSocket IPC.

This asymmetry created a cascade of accidental complexity:
- Deployment entity → process substrate reconciliation
- depends-on bond → dual toggle cascade in toggle-transcriber-intent
- WebSocket bridge → tungstenite dependency, probe_whisper(), JSON response parsing
- Subprocess CWD → working_dir resolution, SIGPIPE from dropped pipe handles

The one right way: both audio-capture and transcription are in-process substrate operations with in-memory session registries. The model is loaded on manifest, inference runs on a background thread consuming audio from the audio session, and the model is unloaded on unmanifest.

```
┌─────────────────────────────────────────────────┐
│                   voice.rs                       │
│                                                  │
│  Audio Capture (cpal)       Transcription        │
│  ┌──────────────────┐      ┌──────────────────┐ │
│  │ AudioSession     │      │ TranscriptSession │ │
│  │  - cpal stream   │─pcm─▶│  - WhisperState  │ │
│  │  - audio_rx/tx   │      │  - VAD model      │ │
│  │  - stop_tx       │      │  - transcripts    │ │
│  └──────────────────┘      └──────────────────┘ │
│                                                  │
│  Both: in-process, session registry, standard    │
│  substrate contract (_entity_update)             │
└─────────────────────────────────────────────────┘
```

No deployment entity. No subprocess. No WebSocket. No IPC.

---

## Methodology — DDD + TDD

This work follows **Doc → Test → Build → Verify**, non-negotiably.

1. **Doc (prescriptive)**: This prompt IS the prescriptive doc.
2. **Test (assert the doc)**: Write tests that assert the target state.
3. **Build (satisfy the tests)**: Implement until tests pass.
4. **Verify doc**: After implementation, update success criteria.

**Clean break with dead code deletion.** The Python whisper-server, deployment entity, depends-on bond, dual toggle cascade, tungstenite dependency, and WebSocket bridge code are all deleted — not deprecated, not feature-flagged. Per dead code policy: dead code is contextual poison.

---

## Current State

### What Exists and Works

| Component | Location | Status |
|-----------|----------|--------|
| Audio capture (cpal, in-process) | `voice.rs:133-240` | Working — manifest/sense/unmanifest |
| Transcription (WebSocket to Python) | `voice.rs:360-506` | Working — but requires subprocess |
| Whisper-server.py (faster-whisper + Silero VAD) | `scripts/whisper-server.py` | Working — but Python dependency |
| Deployment entity (process substrate) | `genesis/soma/entities/voice-defaults.yaml:32-56` | Working — manages Python subprocess |
| Depends-on bond (transcriber → deployment) | `genesis/soma/entities/voice-defaults.yaml:29-30` | Working — but accidental complexity |
| Dual toggle cascade | `genesis/soma/praxeis/voice.yaml:153-177` | Working — cascades to deployment |
| WebSocket response types | `voice.rs:79-96` | Working — Deepgram-compatible JSON |
| tungstenite dependency | `Cargo.toml:41` | Exists — only used for whisper WebSocket |
| Transcriber eidos (whisper_port field) | `genesis/soma/eide/voice.yaml:84-96` | Working — but port is subprocess artifact |
| Resampler (downsample_to_16k_mono) | `voice.rs:617-659` | Working — **keep** (feeds whisper-rs too) |
| Transcript parsing (parse_transcript) | `voice.rs:665-684` | Working — but parses JSON from Python server |

### What's Missing — The Gaps

1. **No whisper-rs dependency** — Cargo.toml has tungstenite but not whisper-rs. Need whisper-rs with `metal` feature for macOS GPU acceleration.
2. **No VAD crate** — Silero VAD runs in Python. Need `voice_activity_detector` crate (ONNX-based Silero VAD V5) or whisper.cpp's built-in VAD.
3. **No model management** — Models need to be downloaded and cached. whisper-server.py delegates this to huggingface_hub. whisper-rs needs explicit model file paths.
4. **Transcription is subprocess-based** — `start_transcription()` connects via WebSocket, not in-process inference.
5. **Dead code cascade** — deployment entity, depends-on bond, dual toggle, probe_whisper, WebSocket types, tungstenite — all dead after migration.

---

## Target State

### Dependencies (Cargo.toml)

```toml
# REMOVE
# tungstenite = { workspace = true }

# ADD
whisper-rs = { version = "0.15", features = ["metal"] }  # macOS Metal GPU
```

**VAD decision**: Use whisper.cpp's built-in VAD (`WhisperVadParams`) rather than adding an ONNX Runtime dependency. whisper-rs 0.15 exposes `WhisperVadContext` which wraps whisper.cpp's energy-based + Silero-compatible VAD. This avoids pulling in `ort` (ONNX Runtime) as a separate native dependency. If the built-in VAD proves insufficient, the `voice_activity_detector` crate can be added later — the architecture supports swapping VAD implementations without structural changes.

### Transcriber Eidos (genesis/soma/eide/voice.yaml)

```yaml
# transcriber — transcription lifecycle entity
- eidos: eidos
  id: eidos/transcriber
  data:
    name: transcriber
    description: |
      A transcription process bridging audio to text. Has desired_state/
      actual_state lifecycle for reconciliation. Created when voice composing
      begins or live captions start. Reconciler keeps model loaded while
      desired_state is active. Produces utterance entities from
      VAD-bounded speech.
    fields:
      whisper_model:
        type: string
        required: true
        default: "base.en"
        description: "Whisper model name (tiny.en, base.en, small.en, medium.en, large-v3)"
      language:
        type: string
        required: true
        default: "en"
      whisper_threads:
        type: integer
        required: false
        default: 4
        description: "Number of inference threads"
      desired_state:
        type: enum
        values: [active, closed]
        required: true
        default: closed
      actual_state:
        type: enum
        values: [pending, active, failed, closed]
        required: true
        default: pending
      mode:
        type: string
        required: true
        default: "transcription"
      provider:
        type: string
        required: true
        default: "whisper-local"
```

**Removed**: `transcription_provider` (redundant with `provider`), `whisper_port` (no subprocess).
**Added**: `whisper_model`, `whisper_threads`.

### Voice Defaults (genesis/soma/entities/voice-defaults.yaml)

```yaml
entities:

  - eidos: audio-source
    id: audio-source/default
    data:
      device_id: default
      sample_rate: 16000
      channels: 1
      desired_state: closed
      actual_state: closed
      mode: audio-capture
      provider: local

  - eidos: transcriber
    id: transcriber/default
    data:
      whisper_model: "base.en"
      language: en
      whisper_threads: 4
      desired_state: closed
      actual_state: closed
      mode: transcription
      provider: whisper-local
    # NO depends-on bond. NO deployment entity.
```

**Deleted**: `deployment/whisper-server` entity, `depends-on` bond, `whisper_port`, `transcription_provider`.

### Toggle Praxis (genesis/soma/praxeis/voice.yaml)

The `toggle-transcriber-intent` praxis simplifies — remove the depends-on trace and for_each cascade:

```yaml
- eidos: praxis
  id: praxis/soma/toggle-transcriber-intent
  data:
    topos: soma
    name: toggle-transcriber-intent
    visible: true
    tier: 2
    description: |
      Toggle transcriber desired_state between active and closed.

      Traces the fed-by-transcriber bond from the accumulation to find
      the transcriber entity, then flips its desired_state field.
      The reconciler/transcription observes the change and drives
      actual transcription start/stop.
    params:
      - name: accumulation_id
        type: string
        required: true
        description: The accumulation entity whose transcriber to toggle
    steps:
      - step: trace
        from_id: "$accumulation_id"
        desmos: "fed-by-transcriber"
        resolve: "to"
        bind_to: transcribers

      - step: assert
        condition: "length($transcribers) > 0"
        message: "No transcriber bonded to accumulation: $accumulation_id"

      - step: set
        bindings:
          transcriber: "$transcribers.0"

      - step: set
        bindings:
          current_state: "$transcriber.data.desired_state"
          entity_id: "$transcriber.id"

      - step: switch
        cases:
          - when: '$current_state == "active"'
            then:
              - step: set
                bindings:
                  new_state: "closed"
          - when: '$current_state == "closed"'
            then:
              - step: set
                bindings:
                  new_state: "active"
        default:
          - step: set
            bindings:
              new_state: "active"

      - step: update
        id: "$entity_id"
        data:
          desired_state: "$new_state"

      - step: return
        value:
          entity_id: "$entity_id"
          desired_state: "$new_state"
          previous_state: "$current_state"
```

**Deleted**: depends-on trace, for_each deployment toggle (lines 153-177 of current).

### Transcription Session (voice.rs)

```rust
struct TranscriptionSession {
    /// Signal to stop the inference thread
    stop_tx: std::sync::mpsc::Sender<()>,
    /// Handle to the inference thread
    _inference_thread: std::thread::JoinHandle<()>,
    /// Whisper model name (for logging/sense)
    model_name: String,
    /// Accumulated transcripts (drained on sense)
    transcripts: Arc<Mutex<Vec<TranscriptResult>>>,
    /// Error state
    error: Arc<Mutex<Option<String>>>,
}
```

**Removed**: `port` (no subprocess), `_ws_thread` renamed to `_inference_thread`.

### Model Cache

Models are cached in the app data directory:

```
~/Library/Application Support/kosmos/models/
  ggml-base.en.bin
  ggml-small.en.bin
  ...
```

Model download is NOT in scope for this prompt. The model file must exist at the expected path. If it doesn't exist, `start_transcription` returns an error with a clear message telling the user where to place the model file. Automatic download can be added in a future prompt.

Model path resolution:
```rust
fn model_path(model_name: &str) -> PathBuf {
    let models_dir = dirs::data_dir()
        .unwrap_or_else(|| PathBuf::from("."))
        .join("kosmos")
        .join("models");
    models_dir.join(format!("ggml-{}.bin", model_name))
}
```

### Transcription Inference Loop (voice.rs)

```rust
fn run_inference_loop(
    model_path: PathBuf,
    language: String,
    threads: i32,
    audio_rx: std::sync::mpsc::Receiver<Vec<f32>>,
    stop_rx: std::sync::mpsc::Receiver<()>,
    sample_rate: u32,
    channels: u16,
    transcripts: Arc<Mutex<Vec<TranscriptResult>>>,
) -> std::result::Result<(), String> {
    // Load model
    let ctx = WhisperContext::new_with_params(
        model_path.to_str().unwrap(),
        WhisperContextParameters::default(),
    ).map_err(|e| format!("Failed to load whisper model: {}", e))?;

    let mut state = ctx.create_state()
        .map_err(|e| format!("Failed to create whisper state: {}", e))?;

    // Accumulate audio until VAD detects utterance boundary
    let mut audio_buffer: Vec<f32> = Vec::new();

    loop {
        if stop_rx.try_recv().is_ok() { break; }

        // Collect audio chunks
        match audio_rx.recv_timeout(Duration::from_millis(50)) {
            Ok(chunk) => {
                let pcm = downsample_to_16k_mono_f32(&chunk, sample_rate, channels);
                audio_buffer.extend_from_slice(&pcm);
            }
            Err(RecvTimeoutError::Timeout) => {}
            Err(RecvTimeoutError::Disconnected) => break,
        }

        // When enough audio accumulated (≥1 second), run inference
        // whisper.cpp's built-in VAD handles utterance detection
        if audio_buffer.len() >= 16000 {
            let mut params = FullParams::new(SamplingStrategy::Greedy { best_of: 1 });
            params.set_language(Some(&language));
            params.set_n_threads(threads);
            params.set_no_timestamps(true);
            params.set_single_segment(true);

            state.full(params, &audio_buffer)
                .map_err(|e| format!("Whisper inference failed: {}", e))?;

            let n_segments = state.full_n_segments()
                .map_err(|e| format!("Failed to get segments: {}", e))?;

            for i in 0..n_segments {
                if let Ok(text) = state.full_get_segment_text(i) {
                    let text = text.trim().to_string();
                    if !text.is_empty() {
                        transcripts.lock().unwrap().push(TranscriptResult {
                            text,
                            is_final: true,
                            speech_final: true,
                        });
                    }
                }
            }

            audio_buffer.clear();
        }
    }

    Ok(())
}
```

**Note**: This is the minimal viable loop. The accumulation strategy (fixed 1s chunks) is intentionally simple. VAD-driven chunking can be refined in a subsequent prompt without structural changes — the `audio_buffer` accumulation and the inference call are the only parts that change.

### Resampler Update

The current `downsample_to_16k_mono()` outputs `Vec<u8>` (i16 little-endian bytes) for the WebSocket protocol. whisper-rs expects `&[f32]`. Add a new function:

```rust
/// Downsample to 16kHz mono f32 samples (for whisper-rs input).
fn downsample_to_16k_mono_f32(input: &[f32], input_sample_rate: u32, input_channels: u16) -> Vec<f32> {
    // ... same channel mixing and resampling logic, but output f32 instead of i16 bytes
}
```

The old `downsample_to_16k_mono()` (i16 bytes output) is deleted — it was only used for the WebSocket protocol.

---

## Sequenced Work

### Phase 1: Genesis Cleanup — Delete Subprocess Scaffolding

**Goal:** Remove deployment entity, depends-on bond, dual toggle cascade, and whisper_port from genesis.

**Tests:**
- test_no_whisper_deployment — assert `find_entity("deployment/whisper-server")` returns None
- test_no_depends_on_bond — assert transcriber/default has no depends-on bonds
- test_transcriber_has_model_fields — assert eidos/transcriber has `whisper_model`, `whisper_threads`, no `whisper_port`
- test_toggle_transcriber_no_cascade — invoke toggle-transcriber-intent, assert no deployment entities were updated

**Implementation:**
1. Delete `deployment/whisper-server` from `genesis/soma/entities/voice-defaults.yaml`
2. Delete `depends-on` bond from `transcriber/default`
3. Update `eidos/transcriber` in `genesis/soma/eide/voice.yaml`: remove `whisper_port`, `transcription_provider`; add `whisper_model`, `whisper_threads`
4. Update `transcriber/default` entity data to match new eidos fields
5. Simplify `toggle-transcriber-intent` in `genesis/soma/praxeis/voice.yaml`: remove depends-on trace and for_each cascade
6. Delete `scripts/whisper-server.py`

**Phase 1 Complete When:**
- [ ] No deployment/whisper-server entity in genesis
- [ ] No depends-on bond on transcriber
- [ ] Toggle praxis has no deployment cascade
- [ ] whisper-server.py deleted
- [ ] All existing tests pass (whisper_process.rs tests that reference deployment/whisper-server will need updating or deletion)

### Phase 2: Rust — Replace WebSocket with whisper-rs

**Goal:** Replace the WebSocket-based transcription with in-process whisper-rs inference.

**Tests:**
- test_whisper_model_path_resolution — assert model_path("base.en") returns expected path
- test_start_transcription_missing_model — assert start_transcription fails with clear error when model file doesn't exist
- test_transcription_session_lifecycle — assert start → sense (active) → stop → sense (closed)
- test_downsample_f32_output — assert downsample_to_16k_mono_f32 produces correct f32 samples
- test_execute_operation_transcription — assert all three operations dispatch correctly

**Implementation:**
1. Add `whisper-rs` to `Cargo.toml` (with `metal` feature), remove `tungstenite`
2. Add `dirs` crate for platform-appropriate data directory
3. In `voice.rs`:
   a. Delete: `WhisperResponse`, `WhisperChannel`, `WhisperAlternative` structs
   b. Delete: `probe_whisper()` function
   c. Delete: `run_transcription_loop()` (WebSocket loop)
   d. Delete: `downsample_to_16k_mono()` (i16 bytes output)
   e. Delete: `WHISPER_PORT` constant
   f. Add: `model_path()` function
   g. Add: `downsample_to_16k_mono_f32()` function
   h. Add: `run_inference_loop()` function (whisper-rs inference)
   i. Rewrite: `start_transcription()` — load model, spawn inference thread
   j. Update: `TranscriptionSession` struct — remove port, rename ws_thread
4. Update `sense_transcription()` — remove port from response
5. Update `stop_transcription()` — remove whisper server lifecycle comment

**Phase 2 Complete When:**
- [ ] tungstenite removed from Cargo.toml
- [ ] whisper-rs added with metal feature
- [ ] No WebSocket code in voice.rs
- [ ] No probe_whisper, no WHISPER_PORT
- [ ] Transcription uses in-process whisper-rs
- [ ] Model path resolves to `~/Library/Application Support/kosmos/models/`
- [ ] Clear error message when model file missing
- [ ] All tests pass

### Phase 3: Integration — End-to-End Verification

**Goal:** Verify the full pipeline works: audio-capture → transcription → utterance entities.

**Tests:**
- test_transcription_reconcile_fires — assert reflex fires on transcriber desired_state change
- test_no_deployment_reconcile — assert no deployment-related reflexes fire for transcription toggle
- test_compose_dependents_no_noise — assert transcriber entity updates don't trigger compose-dependents errors (entity is not composed)

**Implementation:**
1. Delete or update `crates/kosmos/tests/whisper_process.rs` — tests that assert deployment entity behavior
2. Verify `reconciler/transcription` transitions work without deployment dependency
3. Verify sense daemon for transcribers works independently
4. Run full test suite

**Phase 3 Complete When:**
- [ ] whisper_process.rs tests cleaned up or deleted
- [ ] No deployment-related test failures
- [ ] Full test suite passes
- [ ] `cargo clippy` clean

---

## Files to Read

### Rust (what changes)
- `crates/kosmos/src/voice.rs` — full transcription implementation to rewrite
- `crates/kosmos/Cargo.toml` — dependency changes
- `crates/kosmos/src/mode_dispatch.rs` — transcription stoicheion dispatch (unchanged but verify)
- `crates/kosmos/src/host.rs` — manifest/sense/unmanifest dispatch (unchanged but verify)
- `crates/kosmos/tests/whisper_process.rs` — tests to delete/update
- `crates/kosmos/tests/voice_decomposition.rs` — tests to verify still pass

### Genesis (what changes)
- `genesis/soma/entities/voice-defaults.yaml` — delete deployment, update transcriber
- `genesis/soma/eide/voice.yaml` — update transcriber eidos
- `genesis/soma/praxeis/voice.yaml` — simplify toggle-transcriber-intent
- `genesis/soma/reconcilers/transcription.yaml` — verify transitions (unchanged)
- `genesis/soma/reflexes/transcription.yaml` — verify reflexes (unchanged)

### Dead Code (what dies)
- `scripts/whisper-server.py` — the Python server
- `genesis/chora-dev/PROMPT-WHISPER-PROCESS.md` — the prompt that created what we're deleting

---

## Files to Touch

| File | Change |
|------|--------|
| `crates/kosmos/Cargo.toml` | **MODIFY** — add whisper-rs + dirs, remove tungstenite |
| `Cargo.toml` (workspace) | **MODIFY** — add whisper-rs + dirs to workspace deps, remove tungstenite |
| `crates/kosmos/src/voice.rs` | **MODIFY** — replace WebSocket transcription with whisper-rs inference |
| `genesis/soma/entities/voice-defaults.yaml` | **MODIFY** — delete deployment entity, update transcriber |
| `genesis/soma/eide/voice.yaml` | **MODIFY** — update transcriber eidos fields |
| `genesis/soma/praxeis/voice.yaml` | **MODIFY** — simplify toggle-transcriber-intent |
| `scripts/whisper-server.py` | **DELETE** — Python server no longer needed |
| `crates/kosmos/tests/whisper_process.rs` | **DELETE** or **MODIFY** — deployment tests obsolete |

---

## Success Criteria

**Phase 1:**
- [ ] deployment/whisper-server deleted from genesis
- [ ] depends-on bond deleted
- [ ] Toggle praxis simplified (no cascade)
- [ ] whisper-server.py deleted
- [ ] All tests pass

**Phase 2:**
- [ ] whisper-rs in Cargo.toml, tungstenite removed
- [ ] voice.rs uses whisper-rs, no WebSocket code
- [ ] Model path resolution works
- [ ] Clear error on missing model
- [ ] All tests pass

**Phase 3:**
- [ ] whisper_process.rs cleaned up
- [ ] Full test suite passes
- [ ] cargo clippy clean

**Overall Complete When:**
- [ ] All existing tests still pass (minus deleted deployment tests)
- [ ] New tests cover whisper-rs integration
- [ ] Zero dead code from the Python whisper-server era
- [ ] tungstenite fully removed from dependency tree
- [ ] Transcription follows same in-process pattern as audio-capture

---

## What This Enables

- **No Python dependency** — users don't need Python3, pip, faster-whisper, or PyTorch installed
- **Cross-platform** — whisper.cpp compiles on macOS/Windows/Linux, Metal acceleration on macOS
- **Runtime model selection** — change `whisper_model` on the entity, toggle off/on
- **Simpler architecture** — transcription is symmetric with audio-capture, no subprocess lifecycle
- **Future VAD upgrade** — the `voice_activity_detector` crate can replace the accumulation strategy without structural changes
- **Future provider swap** — the mode/provider pattern supports adding deepgram, commons-asr providers alongside whisper-local

---

## What Does NOT Change

- **Audio capture** — cpal-based, stays as-is
- **Mode/provider dispatch** — transcription stoicheion dispatch in mode_dispatch.rs unchanged
- **Stoicheion operations** — transcription-start/sense/stop operation names unchanged
- **Reconciler/reflex/daemon** — transcription autonomic triple unchanged
- **Accumulation/utterance/phasis flow** — entity lifecycle unchanged
- **Compose bar render-specs** — bond traversal to transcriber unchanged (reads desired_state/actual_state, same fields)
- **process.rs** — the SIGPIPE fix stays (useful for other deployment entities)
- **Audio resampling logic** — same algorithm, just outputs f32 instead of i16 bytes

---

*Traces to: PROMPT-VOICE-DECOMPOSITION.md (created the transcription mode), PROMPT-WHISPER-PROCESS.md (created the deployment entity being deleted), PROMPT-COMPOSE-BAR.md (compose bar reads transcriber state via bonds — field names unchanged)*
