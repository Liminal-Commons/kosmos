# Voice Authoring

How voice and text composition work through modes.

---

## Modes

The compose bar has two modes, each a distinct spatial presence:

| Mode | Render-Spec | When |
|------|-------------|------|
| `mode/compose-full` | `render-spec/compose-full` | Default — control row + editable textarea |
| `mode/compose-transcribing` | `render-spec/compose-transcribing` | Transcriber active — control row + readonly textarea, "Transcribing..." placeholder |

Both are entity-bound modes bound to `accumulation/default` via `source_entity_id`.

Mode switching is **reflex-driven**: when `transcriber/default.desired_state` transitions between `active` and `closed`, a reflex swaps the active mode in the thyra-config. Content is synced before each switch.

---

## The Accumulation Entity

All modes bind to `accumulation/default` — a singleton entity that always exists.

### Fields

| Field | Purpose | Updated By |
|-------|---------|-----------|
| `content` | Draft text | Composition from `_composition_inputs.inputs.content` (literal fill) |
| `stance` | Phasis stance | `thyra/clarify-accumulation`, or `$form.stance` at commit |
| `status` | Lifecycle | Always `active` for the singleton |

### Content Flow: Three Sources, One Pattern

All content updates follow the same pattern: a praxis updates `_composition_inputs.inputs.content` on the accumulation → composition produces `content` from the literal fill → UI re-renders.

```
source (voice / keyboard / clarify)
         ↓
praxis updates _composition_inputs.inputs.content
         ↓
demiurge/compose (literal fill → template)
         ↓
accumulation.content updated
         ↓
UI re-renders from entity state
```

The three content sources:

| Source | Praxis | Trigger |
|--------|--------|---------|
| Transcription flush | `thyra/flush-transcript` | Reflex on transcriber.transcript change |
| Manual edit sync | `thyra/sync-compose-content` | Transcription start, commit, blur |
| Clarification | `thyra/clarify-accumulation` | User clicks clarify button |

### Voice Pipeline (Flush Pattern)

The transcriber entity's `transcript` field is a **temporary sense buffer** — whisper-rs writes to it, a reflex flushes it to the accumulation's literal content input, then clears the buffer.

```
whisper-rs sense daemon → transcriber.transcript updated (append)
                                      ↓
                            flush reflex fires
                            (thyra/flush-transcript)
                                      ↓
                            reads transcriber.transcript
                            writes to accumulation._composition_inputs.inputs.content
                            clears transcriber.transcript
                                      ↓
                            composition produces accumulation.content
                                      ↓
                            UI re-renders from entity state
```

### Text Mode

The user types freely into the textarea. Before transitioning to voice mode or committing, `thyra/sync-compose-content` reads `$form.content` from the DOM and writes it to `_composition_inputs.inputs.content`. No per-keystroke entity updates. See [Two-Phase Bindings](../../explanation/architecture/two-phase-bindings.md).

---

## Sending

When the user clicks express (arrow-up):

1. `thyra/sync-compose-content` reads `$form.content` and syncs to literal input
2. `thyra/commit-phasis` creates a phasis entity via `logos/emit-phasis`
3. Clears `_composition_inputs.inputs.content` and transcriber transcript
4. Clears the accumulation (content reset, form cleared via `reset_form: true`)
5. The phasis appears in the feed via the phasis-feed collection mode

---

## Clarification

When the user clicks clarify (sparkles icon), `thyra/clarify-accumulation` runs schema-enforced clarification via `typos/clarify-phasis`:

1. Reads current `_composition_inputs.inputs.content`
2. Runs `demiurge/compose(typos_id: "typos/clarify-phasis", inputs: { raw_content: ... })`
3. Writes clarified content back to `_composition_inputs.inputs.content`
4. Composition produces updated `accumulation.content`

The clarification:
- Removes verbal disfluencies (um, uh, like, you know)
- Fixes grammar and punctuation
- Preserves the speaker's distinct voice and intent
- Detects phasis stance

Automatic clarification via reflex is currently **disabled** (`clarify-on-transcript` trigger/reflex set to `enabled: false`). Manual clarification via button is the active pattern.

---

## Voice Capture Architecture

The voice pipeline supports **two transcription providers**. VAD, audio capture, signal atomics, and transcript accumulation are always local — only the inference step differs.

```
Tauri (Rust)
┌──────────────────────────────────────────────────┐
│ cpal mic capture → ring buffer → Silero VAD      │
│                                    ↓             │
│                          speech segment (f32 PCM)│
│                                    ↓             │
│                  ┌─────────────────┴──────────┐  │
│                  │                            │  │
│          whisper-local              parakeet-lan  │
│          (in-process)               (network)    │
│          whisper-rs                HTTP POST to   │
│          inference                 provider       │
│                  │                endpoint        │
│                  └─────────────┬──────────┘  │   │
│                                ↓             │   │
│                    transcriber.transcript     │   │
│                    updated via sense          │   │
└──────────────────────────────────────────────────┘
         ↓ (flush reflex → literal fill → compose)
    accumulation.content updated
```

| Provider | Inference | When to Use |
|----------|-----------|-------------|
| `whisper-local` (default) | In-process whisper-rs (Metal-accelerated), hardcoded to `base.en` model | No network dependency, privacy-sensitive |
| `parakeet-lan` | HTTP POST to `provider/chora-node` on LAN | Faster inference via dedicated GPU, offloads CPU |

The `transcriber/default` entity's `provider` field selects the active backend. Changing the provider in settings triggers drift-driven re-manifestation — the reconciler stops the old inference path and starts the new one. The whisper model is hardcoded to `base.en` — no model selection UI is exposed. The settings panel exposes the provider selector alongside language and VAD tuning.

VAD (voice activity detection) segments speech on both paths. The sense daemon writes results to the transcriber entity's `transcript` field. A flush reflex propagates to the accumulation via literal-fill composition.

### Two Decomposed Voice Entities

| Entity | Eidos | Purpose |
|--------|-------|---------|
| `audio-source/default` | `audio-source` | Audio capture lifecycle (desired_state, actual_state, device_id) |
| `transcriber/default` | `transcriber` | Transcription lifecycle + temporary sense buffer (desired_state, actual_state, provider, whisper_model, transcript) |

Both are bonded to the accumulation: `fed-by-audio` and `fed-by-transcriber`. These bonds exist for render-spec bindings (e.g. `{@fed-by-audio.data.desired_state}`), not for composition cascade. The accumulation has **no** `depends-on` bond to the transcriber.

---

## Performance Observability

Each inference call is timed with wall-clock `Instant`. `TranscriptResult` carries `segment_secs` (audio duration) and `inference_ms` (inference wall-clock time). The sense daemon surfaces the most recent timing on the transcriber entity:

| Entity Field | Type | Meaning |
|-------------|------|---------|
| `last_inference_ms` | u64 | Wall-clock inference duration (milliseconds) |
| `last_segment_secs` | f32 | Audio segment duration (seconds) |

**Real-time factor (RTF)** = `inference_ms / (segment_secs * 1000)`. Below 1.0 means faster than real-time. Both paths log per-segment timing to stderr:

```
[whisper] 2.1s → 340ms (RTF 0.16x)
[transcription-http] 2.1s → 180ms (RTF 0.09x)
```

Timing is only surfaced in `_entity_update` when new transcripts are drained — idle sense cycles produce no timing updates (consistent with the existing churn-prevention pattern).

---

## Related

- [Accumulation Reference](../../reference/domain/phasis-workspace.md) — Accumulation schema and praxeis
- [Mode Development Guide](mode-development.md) — How modes work
- [Two-Phase Bindings](../../explanation/architecture/two-phase-bindings.md) — `{field}` vs `$form.*` resolution
- [Clarification as Composition](../../explanation/composition/clarification-as-composition.md) — Why clarification uses typos

---

*Guide for the voice authoring experience in Thyra.*
