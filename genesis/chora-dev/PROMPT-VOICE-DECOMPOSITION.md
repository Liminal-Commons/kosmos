# Voice Decomposition — From Clean Slate to Coordinated Facets

*Prompt for Claude Code in the chora + kosmos repository context.*

*Depends on: PROMPT-VOICE-STREAM-RETIREMENT.md (completed). The monolithic mode/voice, eidos/stream, voice.rs, and all voice-specific genesis entities have been deleted. Accumulation is modality-agnostic (7 fields). This prompt builds on clean ground.*

*After this work, audio capture and transcription are separate dynamis modes with independent stoicheion dispatch. Each has its own lifecycle entity, reconciler, reflexes, and daemon (the autonomic triple). Utterances are composed entities with their own typos. Real cpal audio capture and whisper transcription flow through stoicheion dispatch. Transcription results route through kosmos praxeis — not Tauri events.*

---

## Architectural Principle — Voice Is a Coordination Pattern

Voice is not a substrate, not a mode, not an entity. Voice composing is a **coordination pattern** — a set of modes that work together through entity mediation:

| Facet | What | Substrate | Shared With |
|-------|------|-----------|-------------|
| Audio capture | PCM stream from microphone | Media (dynamis) | WebRTC calls, recording, live captions |
| Transcription bridge | Audio → text | Compute (dynamis) | Live captions, recording transcription |
| Composition surface | Accumulation rendering | Screen (thyra) | Keyboard composing, paste composing |
| Commitment | Accumulation → phasis | Graph (praxis) | All input modalities |

The kosmogonia establishes: composition is the constitutional way entities arise. Every entity — accumulation, utterance, phasis — flows through a typos. The accumulation is not a raw buffer; it is a composed entity that receives text from any modality.

Audio capture is a dynamis capability — as dumb as a keyboard. It captures PCM signal. It knows nothing about speech, language, or meaning. Transcription is a compute mode that bridges modalities — it consumes audio and produces text. The composition surface renders the accumulation, agnostic to input source. Commitment creates a phasis from accumulated content.

```
audio-capture (media)  →  in-process channel  →  transcription (compute)
                                                         ↓
                                                  utterance entities
                                                         ↓
                                                  accumulation.content
                                                         ↓
                                              composition surface (thyra)
                                                         ↓
                                                  commit-phasis (praxis)
                                                         ↓
                                                    phasis entity
```

### Relationship to Soma's Perception Ontology

Soma already defines `eidos/channel` (perception/action interface with modality and status) and `eidos/percept` (unit of sensory input through a channel). An audio capture device IS a perception channel with modality: audio. An utterance IS a percept — a unit of auditory sensory input.

The new lifecycle entities (eidos/audio-source, eidos/transcriber) are deliberately separate from channel/percept because they need reconciliation fields (intent + actuality_mode + provider) that channel doesn't carry. A future unification is possible — for now, keep the dynamis lifecycle pattern clean and note the alignment.

---

## Methodology — DDD + TDD

This work follows **Doc → Test → Build → Verify**, non-negotiably.

1. **Doc (prescriptive)**: This prompt IS the prescriptive doc. The target state described here is what code must match.
2. **Test (assert the doc)**: Write tests that assert the target state. Tests should fail before implementation.
3. **Build (satisfy the tests)**: Implement until tests pass.
4. **Verify doc**: After implementation, update success criteria to reflect completion. Check docs/REGISTRY.md impact map.

---

## Current State — Clean Slate

The voice stream retirement (PROMPT-VOICE-STREAM-RETIREMENT.md) has been completed. The ground is clear:

**Deleted (no longer exists):**

| Component | Was In |
|-----------|--------|
| mode/voice | soma/modes/voice.yaml |
| mode/voice-composing | thyra/modes/screen.yaml |
| eidos/stream | thyra/eide/thyra.yaml |
| eidos/voice-pipeline-config | thyra/eide/thyra.yaml |
| voice.rs | crates/kosmos/src/voice.rs |
| voice_substrate.rs tests | crates/kosmos/tests/voice_substrate.rs |
| capture.ts | app/src/lib/voice/capture.ts |
| render-spec/voice-bar | thyra/render-specs/voice-bar.yaml |
| render-spec/stream-card | thyra/render-specs/stream-card.yaml |
| All stream praxeis (8) | thyra/praxeis/thyra.yaml |
| Voice reflexes/reconcilers/daemons | soma/{reflexes,reconcilers,daemons}/ |
| Voice stoicheion dispatch | host.rs match arms |

**Remains and is correct:**

| Component | Location | Status |
|-----------|----------|--------|
| eidos/accumulation | thyra/eide/thyra.yaml | Clean — 7 modality-agnostic fields |
| eidos/utterance | thyra/eide/thyra.yaml | Clean — no stream_id |
| eidos/phasis | logos/eide/logos.yaml | Clean — no source_stream_id |
| typos-def-accumulation | thyra/typos/thyra.yaml | Exists |
| typos-def-phasis | logos/typos/logos.yaml | Exists |
| accumulation/default entity | thyra/entities/default-accumulation.yaml | Clean — 4 fields |
| mode/text-composing | thyra/modes/screen.yaml | Works — uses accumulation |
| voice_capture.rs (real cpal) | app/src-tauri/src/voice_capture.rs | Port source — not wired to kosmos dispatch |
| actuality.ts | app/src/lib/actuality.ts | Stays — other substrates use it |
| eidos/channel, eidos/percept | soma/eide/soma.yaml | Soma perception ontology — aligned but separate |

### What's Missing — The Gaps

1. **No audio capture mode**: No way to capture PCM through dynamis dispatch.
2. **No transcription mode**: No way to bridge audio → text through dynamis dispatch.
3. **No lifecycle entities**: No entity type for "an active audio capture" or "an active transcription session" — needed for reconciliation.
4. **No typos-def-utterance**: The utterance eidos exists but has no typos. Utterances cannot be composed constitutionally.
5. **No autonomic triple**: No reconcilers, reflexes, or daemons for audio or transcription.
6. **No Rust module**: voice.rs was deleted. Stoicheion dispatch for audio/transcription needs to be built.
7. **No utterance composition**: VAD-bounded speech should arise as composed utterance entities. No mechanism for this exists.

---

## Target State

### Decomposed Dynamis Modes

**mode/audio-capture** (media substrate, provider: local):

```yaml
- eidos: mode
  id: mode/audio-capture
  data:
    name: audio-capture
    topos: dynamis
    substrate: media
    provider: local
    description: |
      Audio capture substrate — opens microphone, produces PCM.
      Dumb device. Knows nothing about speech, language, or transcription.
      Shared by voice composing, WebRTC calls, recording, live captions.
      Ontologically: a perception channel (soma) with modality: audio.
    operations:
      manifest:
        stoicheion: audio-capture-start
        description: "Open audio input device, start PCM stream"
      sense:
        stoicheion: audio-capture-sense
        description: "Check audio device health"
      unmanifest:
        stoicheion: audio-capture-stop
        description: "Close audio input device"
```

**mode/transcription** (compute substrate, provider: whisper-local):

```yaml
- eidos: mode
  id: mode/transcription
  data:
    name: transcription
    topos: dynamis
    substrate: compute
    provider: whisper-local
    description: |
      ASR bridge — consumes audio PCM, produces text utterances.
      Modality bridge: transforms audio signal into semantic content.
      Shared by voice composing (utterances), live captions, recording transcription.
    operations:
      manifest:
        stoicheion: transcription-start
        description: "Start transcription process, connect to audio source"
      sense:
        stoicheion: transcription-sense
        description: "Check transcription process health"
      unmanifest:
        stoicheion: transcription-stop
        description: "Stop transcription process"
```

### Lifecycle Entities

Reconciliation requires entities with intent/status fields. Each facet gets its own entity type — specific, not generic. These live in soma (embodiment/perception domain).

**eidos/audio-source** (audio capture lifecycle):

```yaml
- eidos: eidos
  id: eidos/audio-source
  data:
    name: audio-source
    description: |
      An audio input source under capture. Has intent/status lifecycle
      for reconciliation. Created when voice composing begins or WebRTC
      call starts. Reconciler keeps actual capture aligned with intent.
      Conceptually: a perception channel (soma) with dynamis lifecycle.
    fields:
      device_id:
        type: string
        required: true
        default: "default"
        description: "Audio device identifier"
      sample_rate:
        type: integer
        required: false
        default: 16000
      channels:
        type: integer
        required: false
        default: 1
      intent:
        type: enum
        values: [active, closed]
        required: true
        default: closed
      status:
        type: enum
        values: [pending, active, failed, closed]
        required: true
        default: pending
      actuality_mode:
        type: string
        required: true
        default: "audio-capture"
      provider:
        type: string
        required: true
        default: "local"
```

**eidos/transcriber** (transcription lifecycle):

```yaml
- eidos: eidos
  id: eidos/transcriber
  data:
    name: transcriber
    description: |
      A transcription process bridging audio to text. Has intent/status
      lifecycle for reconciliation. Created when voice composing begins
      or live captions start. Reconciler keeps process alive while intent
      is active. Produces utterance entities from VAD-bounded speech.
    fields:
      transcription_provider:
        type: string
        required: true
        default: "whisper-local"
      language:
        type: string
        required: true
        default: "en"
      intent:
        type: enum
        values: [active, closed]
        required: true
        default: closed
      status:
        type: enum
        values: [pending, active, failed, closed]
        required: true
        default: pending
      actuality_mode:
        type: string
        required: true
        default: "transcription"
      provider:
        type: string
        required: true
        default: "whisper-local"
```

### typos-def-utterance

The one missing typos. Utterances must be composable:

```yaml
- eidos: typos
  id: typos-def-utterance
  data:
    name: utterance
    description: "Compose an utterance entity (VAD-bounded speech segment)"
    target_eidos: utterance
```

### Reconcilers

Follow the standard pattern from dynamis/reconcilers/dynamis.yaml:

```yaml
- eidos: reconciler
  id: reconciler/audio-capture
  data:
    target_eidos: audio-source
    intent_field: intent
    actuality_field: status
    transitions:
      - intent: active
        actual: [pending, closed]
        action: manifest
      - intent: active
        actual: active
        action: sense
      - intent: active
        actual: failed
        action: manifest
      - intent: closed
        actual: [active]
        action: unmanifest
      - intent: closed
        actual: [closed, pending]
        action: none

- eidos: reconciler
  id: reconciler/transcription
  data:
    target_eidos: transcriber
    intent_field: intent
    actuality_field: status
    transitions:
      - intent: active
        actual: [pending, closed]
        action: manifest
      - intent: active
        actual: active
        action: sense
      - intent: active
        actual: failed
        action: manifest
      - intent: closed
        actual: [active]
        action: unmanifest
      - intent: closed
        actual: [closed, pending]
        action: none
```

### Reflexes (Standard Autonomic Triple)

Follow the pattern from chora-dev/reflexes/reflexes.yaml — intent-changed + drift triggers, each with a reflex that invokes praxis/dynamis/reconcile.

**Audio capture (4 entities):**

```yaml
# Intent-changed trigger
- eidos: trigger
  id: trigger/soma/audio-source-intent-changed
  data:
    name: audio-source-intent-changed
    condition: '$entity.data.intent != $previous.data.intent'
    enabled: true
  bonds:
    - { desmos: matches-event, to: entity-mutation/updated }
    - { desmos: filters-eidos, to: eidos/audio-source }

# Drift trigger
- eidos: trigger
  id: trigger/soma/audio-source-drift
  data:
    name: audio-source-drift
    condition: '$entity.data.intent == "active" and $entity.data.status not in ["active", "manifesting", "pending"]'
    enabled: true
  bonds:
    - { desmos: matches-event, to: entity-mutation/updated }
    - { desmos: filters-eidos, to: eidos/audio-source }

# Intent-changed reflex
- eidos: reflex
  id: reflex/soma/reconcile-audio-on-intent
  data:
    name: reconcile-audio-on-intent
    description: "When audio source intent changes, reconcile."
    enabled: true
    scope: global
    response_params:
      reconciler_id: "reconciler/audio-capture"
      entity_id: "$entity.id"
  bonds:
    - { desmos: triggered-by, to: trigger/soma/audio-source-intent-changed }
    - { desmos: responds-with, to: praxis/dynamis/reconcile }

# Drift reflex
- eidos: reflex
  id: reflex/soma/reconcile-audio-on-drift
  data:
    name: reconcile-audio-on-drift
    description: "When audio source drifts from intent, reconcile."
    enabled: true
    scope: global
    response_params:
      reconciler_id: "reconciler/audio-capture"
      entity_id: "$entity.id"
  bonds:
    - { desmos: triggered-by, to: trigger/soma/audio-source-drift }
    - { desmos: responds-with, to: praxis/dynamis/reconcile }
```

**Transcription (4 entities):** Same pattern, targeting eidos/transcriber and reconciler/transcription.

```yaml
- eidos: trigger
  id: trigger/soma/transcriber-intent-changed
  data:
    name: transcriber-intent-changed
    condition: '$entity.data.intent != $previous.data.intent'
    enabled: true
  bonds:
    - { desmos: matches-event, to: entity-mutation/updated }
    - { desmos: filters-eidos, to: eidos/transcriber }

- eidos: trigger
  id: trigger/soma/transcriber-drift
  data:
    name: transcriber-drift
    condition: '$entity.data.intent == "active" and $entity.data.status not in ["active", "manifesting", "pending"]'
    enabled: true
  bonds:
    - { desmos: matches-event, to: entity-mutation/updated }
    - { desmos: filters-eidos, to: eidos/transcriber }

- eidos: reflex
  id: reflex/soma/reconcile-transcription-on-intent
  data:
    name: reconcile-transcription-on-intent
    description: "When transcriber intent changes, reconcile."
    enabled: true
    scope: global
    response_params:
      reconciler_id: "reconciler/transcription"
      entity_id: "$entity.id"
  bonds:
    - { desmos: triggered-by, to: trigger/soma/transcriber-intent-changed }
    - { desmos: responds-with, to: praxis/dynamis/reconcile }

- eidos: reflex
  id: reflex/soma/reconcile-transcription-on-drift
  data:
    name: reconcile-transcription-on-drift
    description: "When transcriber drifts from intent, reconcile."
    enabled: true
    scope: global
    response_params:
      reconciler_id: "reconciler/transcription"
      entity_id: "$entity.id"
  bonds:
    - { desmos: triggered-by, to: trigger/soma/transcriber-drift }
    - { desmos: responds-with, to: praxis/dynamis/reconcile }
```

### Daemons

```yaml
- eidos: daemon
  id: daemon/sense-audio-sources
  data:
    name: sense-audio-sources
    description: |
      Periodically sense all audio-source entities to detect drift.
      When a mic dies (device disconnect, permission revoked), sensing
      updates status, which triggers the drift reflex → reconciliation.
    praxis: soma/sense-audio-source-states
    interval: 10
    enabled: true
    scope: dwelling
    backoff_max: 60

- eidos: daemon
  id: daemon/sense-transcribers
  data:
    name: sense-transcribers
    description: |
      Periodically sense all transcriber entities to detect drift.
      When whisper crashes or WebSocket disconnects, sensing updates
      status, which triggers the drift reflex → reconciliation.
    praxis: soma/sense-transcriber-states
    interval: 10
    enabled: true
    scope: dwelling
    backoff_max: 60
```

### Rust Voice Module

NEW `crates/kosmos/src/voice.rs` — handles decomposed stoicheia:

```rust
pub fn execute_operation(
    operation: &str,
    entity_id: &str,
    data: &Value,
    _session: Option<&Arc<dyn SessionBridge>>,
) -> Result<Value> {
    match operation {
        // Audio capture (media substrate)
        "audio-capture-start" => start_audio_capture(entity_id, data),
        "audio-capture-sense" => sense_audio_capture(entity_id, data),
        "audio-capture-stop" => stop_audio_capture(entity_id, data),

        // Transcription (compute substrate)
        "transcription-start" => start_transcription(entity_id, data),
        "transcription-sense" => sense_transcription(entity_id, data),
        "transcription-stop" => stop_transcription(entity_id, data),

        _ => Err(KosmosError::Invalid(format!(
            "Unknown voice operation: {}", operation
        ))),
    }
}
```

Key implementation details:
- `start_audio_capture` opens real cpal mic (ported from voice_capture.rs), stores handle in in-process registry
- `start_transcription` starts whisper process, connects to audio channel from capture registry
- Transcription results route through kosmos praxis invocation (NOT Tauri events)
- VAD-bounded segments compose utterance entities via typos-def-utterance
- No AppHandle dependency — results enter the graph through praxis invocation

---

## Sequenced Work

### Phase 1: Genesis — Build the Ontology

**Goal:** Create decomposed modes, lifecycle entities, typos, reconcilers, reflexes, daemons. All genesis entities for the voice decomposition.

**Tests (assert before implementation):**
- `test_audio_capture_mode_exists` — mode/audio-capture entity exists after bootstrap
- `test_transcription_mode_exists` — mode/transcription entity exists after bootstrap
- `test_audio_source_eidos_exists` — eidos/audio-source exists with intent/status fields
- `test_transcriber_eidos_exists` — eidos/transcriber exists with intent/status fields
- `test_typos_def_utterance_exists` — typos-def-utterance exists and targets eidos/utterance
- `test_reconcilers_exist` — reconciler/audio-capture and reconciler/transcription exist, target correct eide
- `test_reflexes_exist` — 4 triggers + 4 reflexes exist with correct filter eide and bonds

**Implementation:**

Create new genesis files:
1. `genesis/dynamis/modes/audio-capture.yaml` — mode/audio-capture
2. `genesis/dynamis/modes/transcription.yaml` — mode/transcription
3. `genesis/soma/eide/voice.yaml` — eidos/audio-source + eidos/transcriber
4. `genesis/soma/reconcilers/audio-capture.yaml` — reconciler/audio-capture
5. `genesis/soma/reconcilers/transcription.yaml` — reconciler/transcription
6. `genesis/soma/reflexes/audio-capture.yaml` — 2 triggers + 2 reflexes
7. `genesis/soma/reflexes/transcription.yaml` — 2 triggers + 2 reflexes
8. `genesis/soma/daemons/audio-capture.yaml` — daemon/sense-audio-sources
9. `genesis/soma/daemons/transcription.yaml` — daemon/sense-transcribers

Modify existing files:
10. `genesis/thyra/typos/thyra.yaml` — add typos-def-utterance
11. `genesis/soma/manifest.yaml` — add audio-source, transcriber to eide; add new praxeis
12. Verify build.rs glob pattern includes `genesis/dynamis/modes/*.yaml` for new mode files

Verify: `cargo test -p kosmos --lib` (bootstrap succeeds with new entities)

**Phase 1 Complete When:**
- [ ] Both dynamis modes exist (audio-capture + transcription)
- [ ] Both lifecycle eide exist in soma (audio-source + transcriber)
- [ ] typos-def-utterance exists in thyra/typos
- [ ] Both reconcilers target correct eide
- [ ] Autonomic triple for both facets (4 triggers + 4 reflexes + 2 daemons)
- [ ] Bootstrap succeeds, all existing tests pass

### Phase 2: Rust — Build the Voice Module

**Goal:** Create NEW voice.rs handling decomposed stoicheia. Bridge real cpal audio capture and whisper transcription. Route results through kosmos praxeis.

**Tests:**
- `test_audio_capture_stoicheion_dispatch` — mode_dispatch routes ("audio-capture", "local") to correct stoicheia
- `test_transcription_stoicheion_dispatch` — mode_dispatch routes ("transcription", "whisper-local") to correct stoicheia
- `test_host_dispatches_audio_capture` — host.rs dispatch_to_module routes audio-capture-start/sense/stop to voice::execute_operation
- `test_host_dispatches_transcription` — same for transcription-start/sense/stop
- Hardware tests (marked `#[ignore]`):
  - `test_audio_capture_opens_device` — execute_operation("audio-capture-start") opens real mic
  - `test_transcription_connects_whisper` — execute_operation("transcription-start") connects to whisper

**Implementation:**
1. Create NEW `crates/kosmos/src/voice.rs` with execute_operation handling 6 operations
2. Port cpal logic from `voice_capture.rs` into audio capture functions:
   - Device selection (device_id from entity data)
   - Stream building (cpal InputStreamConfig)
   - PCM channel (mpsc sender/receiver)
   - Resampling (downsample_to_16k_mono)
3. Port whisper logic from `voice_capture.rs` into transcription functions:
   - WhisperServer management (start/probe/stop)
   - WebSocket connection and message handling
   - Route transcript messages through praxis invocation (NOT app.emit)
4. Add utterance composition: VAD speech-final → compose(typos-def-utterance) → bond to accumulation
5. In-process registries:
   - `AUDIO_SESSIONS: EntityId → (shutdown_tx, audio_thread, audio_sender)`
   - `TRANSCRIPTION_SESSIONS: EntityId → (whisper_server, shutdown_tx)`
6. Add `pub mod voice;` to `crates/kosmos/src/lib.rs`
7. Add stoicheion match arms in `crates/kosmos/src/host.rs`:
   - audio-capture-start, audio-capture-sense, audio-capture-stop → voice::execute_operation
   - transcription-start, transcription-sense, transcription-stop → voice::execute_operation
8. Verify mode_dispatch.rs regenerates with both new modes
9. Build and test: `cargo test -p kosmos --lib --tests`

**Phase 2 Complete When:**
- [ ] voice.rs handles all 6 decomposed operations
- [ ] host.rs dispatches to voice module for all 6 stoicheia
- [ ] mode_dispatch.rs has ("audio-capture", "local") and ("transcription", "whisper-local")
- [ ] Real cpal mic opens on audio-capture-start (hardware test, `#[ignore]`)
- [ ] Real whisper connects on transcription-start (hardware test, `#[ignore]`)
- [ ] All tests pass

### Phase 3: End-to-End Verification

**Goal:** Verify the full cycle works: capture → transcription → utterance → accumulation → phasis.

**Tests:**
- `test_utterance_composition` — VAD-bounded speech produces a composed utterance entity via typos-def-utterance
- `test_accumulation_receives_text` — utterance text updates accumulation.content (via append-fragment praxis)
- `test_commit_produces_phasis` — commit-phasis composes a phasis from accumulation via typos-def-phasis
- `test_reconciler_transitions` — audio-source with intent:active, status:pending → reconciler fires manifest

**Implementation:**
1. Write integration tests with mocked audio input (bypass cpal, inject PCM directly)
2. Verify utterance entities are composed (constitutional compliance) through typos-def-utterance
3. Verify accumulation.content updates when utterance text arrives
4. Verify commit-phasis produces phasis through typos-def-phasis
5. Mark hardware-dependent tests as `#[ignore]`

**Phase 3 Complete When:**
- [ ] Integration tests prove the cycle
- [ ] Utterances are composed entities (constitutional compliance)
- [ ] Phasis arises through composition (typos-def-phasis)
- [ ] Reconciler transitions work for both audio-source and transcriber entities
- [ ] All tests pass

---

## Files to Read

### Genesis (existing ground)
- `genesis/thyra/eide/thyra.yaml` — accumulation, utterance eide (clean)
- `genesis/thyra/typos/thyra.yaml` — existing typos (add typos-def-utterance here)
- `genesis/logos/eide/logos.yaml` — phasis eidos
- `genesis/logos/typos/logos.yaml` — typos-def-phasis
- `genesis/thyra/entities/default-accumulation.yaml` — clean default
- `genesis/soma/eide/soma.yaml` — channel, percept, body-signal (aligned ontology)
- `genesis/soma/manifest.yaml` — soma provides
- `genesis/dynamis/modes/dynamis.yaml` — existing dynamis modes (pattern to follow)
- `genesis/dynamis/reconcilers/dynamis.yaml` — existing reconcilers (pattern to follow)
- `genesis/chora-dev/reflexes/reflexes.yaml` — autonomic triple pattern (most recent)
- `genesis/chora-dev/daemons/daemons.yaml` — daemon pattern

### Rust (port source + dispatch patterns)
- `app/src-tauri/src/voice_capture.rs` — real cpal + whisper (port FROM here)
- `crates/kosmos/src/host.rs` — stoicheion dispatch pattern (dispatch_to_module)
- `crates/kosmos/src/process.rs` — reference dynamis module implementation
- `crates/kosmos/src/mode_dispatch.rs` — generated dispatch table
- `crates/kosmos/build.rs` — mode dispatch generation (verify glob pattern includes new mode files)

---

## Files to Touch

| File | Change |
|------|--------|
| `genesis/dynamis/modes/audio-capture.yaml` | **NEW** — mode/audio-capture |
| `genesis/dynamis/modes/transcription.yaml` | **NEW** — mode/transcription |
| `genesis/soma/eide/voice.yaml` | **NEW** — eidos/audio-source + eidos/transcriber |
| `genesis/soma/reconcilers/audio-capture.yaml` | **NEW** — reconciler/audio-capture |
| `genesis/soma/reconcilers/transcription.yaml` | **NEW** — reconciler/transcription |
| `genesis/soma/reflexes/audio-capture.yaml` | **NEW** — 2 triggers + 2 reflexes |
| `genesis/soma/reflexes/transcription.yaml` | **NEW** — 2 triggers + 2 reflexes |
| `genesis/soma/daemons/audio-capture.yaml` | **NEW** — daemon/sense-audio-sources |
| `genesis/soma/daemons/transcription.yaml` | **NEW** — daemon/sense-transcribers |
| `genesis/thyra/typos/thyra.yaml` | **MODIFY** — add typos-def-utterance |
| `genesis/soma/manifest.yaml` | **MODIFY** — add audio-source, transcriber eide; add sensing praxeis |
| `crates/kosmos/src/voice.rs` | **NEW** — decomposed voice module |
| `crates/kosmos/src/lib.rs` | **MODIFY** — add `pub mod voice;` |
| `crates/kosmos/src/host.rs` | **MODIFY** — add 6 stoicheion match arms |
| `crates/kosmos/tests/voice_decomposition.rs` | **NEW** — tests for decomposed voice lifecycle |

---

## Success Criteria

### Phase 1
- [ ] mode/audio-capture exists (substrate: media, provider: local)
- [ ] mode/transcription exists (substrate: compute, provider: whisper-local)
- [ ] eidos/audio-source and eidos/transcriber exist in soma with intent/status fields
- [ ] typos-def-utterance exists targeting eidos/utterance
- [ ] reconciler/audio-capture targets eidos/audio-source
- [ ] reconciler/transcription targets eidos/transcriber
- [ ] Autonomic triple: 4 triggers + 4 reflexes + 2 daemons
- [ ] Bootstrap succeeds

### Phase 2
- [ ] voice.rs handles 6 decomposed operations
- [ ] host.rs dispatches all 6 stoicheia to voice module
- [ ] mode_dispatch.rs has both decomposed modes
- [ ] Real cpal mic opens on audio-capture-start (`#[ignore]` test)
- [ ] Real whisper connects on transcription-start (`#[ignore]` test)
- [ ] All tests pass

### Phase 3
- [ ] End-to-end cycle verified (mocked audio → utterance → accumulation → phasis)
- [ ] Utterances are composed entities (typos-def-utterance)
- [ ] Phasis arises through composition (typos-def-phasis)
- [ ] Reconciler transitions work for both lifecycle entities
- [ ] All tests pass

**Overall:**
- [ ] 9 new genesis files + 2 modified
- [ ] 15+ new genesis entities (2 modes, 2 eide, 1 typos, 2 reconcilers, 4 triggers, 4 reflexes, 2 daemons)
- [ ] New voice.rs module with 6 stoicheion operations
- [ ] Full cycle: capture → transcription → utterance → accumulation → phasis
- [ ] All existing + new tests pass

---

## What This Enables

1. **WebRTC audio sharing**: mode/audio-capture can serve WebRTC calls independently of transcription. A call requires audio-source + webrtc connection — no transcription needed.

2. **Live captions**: Transcription can serve captions during calls — audio-source + transcriber + WebRTC, no composition surface needed.

3. **Keyboard composing**: mode/text-composing uses the same accumulation, no substrate requirements. Already works.

4. **Modality-agnostic phasis**: Whether text arrived via keyboard or voice, the phasis is the same entity, composed through the same typos. Voice-originated phaseis carry utterance provenance (bonds), keyboard-originated ones do not.

5. **Audio recording**: Future mode/recording requires audio-source + storage substrate, independent of transcription.

6. **Self-healing**: Mic dies → daemon senses → status changes to failed → drift reflex fires → reconciler manifests → mic reopens. Same for whisper crash.

---

## What Does NOT Change

- **Other substrate modules** (process, storage, dns, livekit, credential) — untouched
- **The composition pipeline** (steps.rs, compose_graph, typos resolution) — untouched
- **The thyra layout engine** — untouched
- **The reactive system engine** — untouched
- **eidos/accumulation** — already clean (7 fields), not touched
- **eidos/utterance** — already clean, not touched (only typos-def-utterance added)
- **eidos/phasis** — already clean, not touched
- **mode/text-composing** — continues working through accumulation
- **voice_capture.rs** — stays as port source. Code is ported FROM it to voice.rs. Not deleted until TypeScript handler path is fully retired.
- **actuality.ts** — stays. Other substrates may use it.
- **soma channel/percept ontology** — untouched. Alignment noted, unification deferred.

---

*Traces to: KOSMOGONIA §Composition Triad, T4 (four reconciliation loops), T8 (mode is topos presence), PROMPT-VOICE-STREAM-RETIREMENT.md (completed), Voice Ontological Commitments (design dialogue)*
