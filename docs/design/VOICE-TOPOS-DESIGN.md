# Voice Topos Design

*Voice authoring via modes, substrates, and the accumulation pipeline.*

**Status:** Implemented (literal-fill pattern prescriptive — gap)
**Depends on:** THYRA-INTERPRETER.md, MODE-DEVELOPMENT.md

---

## Overview

The voice topos is an embodied topos — it has modes on both screen and compute substrates. Voice authoring follows the commitment boundary pattern:

```
voice sense → transcriber.transcript → flush reflex → literal fill → compose → accumulation → commit → phasis
      ↑              ↑                     ↑              ↑            ↑           ↑            ↑
   substrate     temp buffer          reflex-driven    praxis     composition   entity       logos
   (dynamis)     (sense data)         (reactive)       (update)   (demiurge)    (reactive)   (surface)
```

**Key insight:** The transcriber's `transcript` field is a temporary sense buffer. Praxeis flush it to the accumulation's literal composition input, where composition produces `content`. All content sources — voice, keyboard, LLM clarification — update the same literal input.

---

## Topos Nature

The voice topos is embodied — it has modes on both screen and compute substrates:

| Topos Nature | Has Screen Modes? | Has Infrastructure Modes? | Example |
|-------------|-----------|---------------------|---------|
| Pure thought | No | No | demiurge |
| Infrastructure | No | Yes | dynamis |
| Presence only | Yes | No | authoring |
| **Embodied** | **Yes** | **Yes** | **voice** |

---

## Modes

The compose bar has two screen modes:

| Mode | Render-Spec | Description |
|------|-------------|-------------|
| `mode/compose-full` | `render-spec/compose-full` | Full compose bar — control row (mic, transcription, stance badge, spacer, clarify, express) + editable textarea |
| `mode/compose-transcribing` | `render-spec/compose-transcribing` | Compose bar with transcribing — same control row, readonly textarea |

Mode switching is **reflex-driven**: when `transcriber/default.desired_state` transitions between `active` and `closed`, a reflex swaps the active mode in the thyra-config. Before each switch, `thyra/sync-compose-content` syncs DOM text to the literal input so no content is lost.

---

## The Accumulation Entity

All compose modes bind to `accumulation/default` — a singleton entity that always exists.

### Literal-Fill Content Flow

The accumulation entity is composed via `typos-def-accumulation` with a **literal fill** slot:

```yaml
slots:
  content:
    fill: literal
    default: ""
template: "{{ content }}"
```

The literal value comes from `_composition_inputs.inputs.content`. Praxeis update this input and then invoke composition to produce `entity.data.content`. There is no `depends-on` bond to the transcriber — composition does not cascade from transcriber changes.

### Three Sources, One Pattern

All content updates follow the same path:

```
source (voice / keyboard / clarify)
         ↓
praxis updates _composition_inputs.inputs.content
         ↓
demiurge/compose (literal fill → template → content)
         ↓
accumulation.content updated
         ↓
UI re-renders from entity state
```

| Source | Praxis | Trigger |
|--------|--------|---------|
| Voice transcription | `thyra/flush-transcript` | Reflex on transcriber.transcript change |
| Manual editing | `thyra/sync-compose-content` | Transcription start, commit, blur |
| Clarification | `thyra/clarify-accumulation` | User clicks clarify button |

### Bonds

| Desmos | Target | Purpose |
|--------|--------|---------|
| `fed-by-audio` | `audio-source/default` | Audio capture state — `{@fed-by-audio.data.desired_state}` in render-specs |
| `fed-by-transcriber` | `transcriber/default` | Transcription state — `{@fed-by-transcriber.data.desired_state}` in render-specs |

These bonds exist for **render-spec bindings only** — they let widgets display voice state without domain logic in the interpreter. They do not create composition cascade.

---

## Two Decomposed Voice Entities

| Entity | Eidos | Fields | Purpose |
|--------|-------|--------|---------|
| `audio-source/default` | `audio-source` | desired_state, actual_state, device_id | Audio capture lifecycle |
| `transcriber/default` | `transcriber` | desired_state, actual_state, whisper_model, language, whisper_threads, transcript, segment_status | Transcription lifecycle + temporary sense buffer |

Both follow the autonomic pattern: desired_state/actual_state reconciliation with intent-changed and drift reflexes.

The transcriber's `transcript` field is a **temporary sense buffer**: whisper-rs writes to it via the sense daemon, a flush reflex reads it and propagates to the accumulation's literal input, then clears it. It is NOT a durable record — it is cleared after each flush and after each commit.

---

## Voice Capture Architecture

```
Tauri (Rust) — all in-process
┌───────────────────────────────────────────────────┐
│ cpal mic capture → ring buffer → VAD              │
│                    (AtomicU32    (VadState:        │
│                     energy_db)   onset/offset)     │
│                                    ↓              │
│                          whisper-rs inference      │
│                          (Metal-accelerated)      │
│                                    ↓              │
│                          transcriber.transcript   │
│                          updated via sense daemon  │
└───────────────────────────────────────────────────┘
         ↓ (flush reflex → literal fill → compose)
    accumulation.content updated
```

Everything runs locally and in-process — no subprocess, no WebSocket, no API keys:
- **cpal** captures audio from the selected device
- **VAD** (voice activity detection) segments speech using energy thresholds
- **whisper-rs** (with Metal acceleration) transcribes each segment
- The sense daemon writes results to `transcriber.transcript`
- A flush reflex propagates transcript to the accumulation via literal-fill composition

### Signal Architecture (Sensing vs Being)

| Concern | Storage | Frequency | Purpose |
|---------|---------|-----------|---------|
| Entity state | DB (desired_state, actual_state, device_id, whisper_model) | Low (lifecycle events) | Reconciliation |
| Voice signals | Atomics in AudioSession (energy_db, voice_active, transcribing) | 10Hz | Continuous measurement |

Voice signals use the **general substrate signal registry** (`signal.rs`). The voice module registers a signal source on first audio start; the 10Hz timer in `http.rs` calls `signal::read_all_signals()` and broadcasts `WsEvent::SubstrateSignal`. Widgets opt in via `data-signal-source` in render-specs; CSS targets `[data-signal-voice-active="true"]` and `[data-signal-transcribing="true"]`.

---

## Clarification Pipeline

When the user clicks clarify (sparkles icon):

```
_composition_inputs.inputs.content (current content)
    ↓
thyra/clarify-accumulation
    ↓
demiurge/compose(typos_id: "typos/clarify-phasis", inputs: { raw_content: ... })
    ↓
output_schema enforces { content: string, stance: enum } (T9)
    ↓
writes clarified content to _composition_inputs.inputs.content
    ↓
demiurge/compose (re-compose accumulation)
    ↓
accumulation.content + accumulation.stance updated
```

Automatic clarification via reflex (`clarify-on-transcript`) is currently **disabled**. Manual clarification via button is the active pattern.

---

## Praxeis

| Praxis | Purpose |
|--------|---------|
| `thyra/flush-transcript` | Read transcriber.transcript, append to literal input, clear buffer, compose |
| `thyra/sync-compose-content` | Read `$form.content` from DOM, write to literal input, compose |
| `thyra/clarify-accumulation` | Schema-enforced clarification — write clarified content to literal input, compose |
| `thyra/commit-phasis` | Create phasis from content + stance, clear accumulation + transcriber |
| `soma/toggle-audio-intent` | Flip audio-source desired_state (active ↔ closed) |
| `soma/toggle-transcriber-intent` | Flip transcriber desired_state (active ↔ closed) |

---

## Sending

When the user clicks express (arrow-up):

1. `thyra/sync-compose-content` reads `$form.content` and syncs to literal input
2. `thyra/commit-phasis` creates a phasis entity via `logos/emit-phasis`
3. Clears `_composition_inputs.inputs.content`, transcriber transcript, and accumulation content
4. Form cleared via `reset_form: true`
5. The phasis appears in the phasis-feed collection mode

---

## Design Principle

This design demonstrates that "substrates" don't require special components. The pattern:

1. **Substrate** (dynamis modes) handles hardware interaction in Rust
2. **Entity state** (transcriber) captures the substrate's output as a temporary sense buffer
3. **Praxis** (flush-transcript) propagates data by updating the literal composition input
4. **Composition** (typos-def-accumulation) produces content from the literal fill
5. **Render-spec** (compose-full/transcribing) binds widgets to entity fields
6. **Reflex** (mode switch) swaps presentation when transcriber state changes

The interpreter never knows it's rendering a voice feature. It renders widgets bound to entity data — the same as any other mode.

---

*Voice authoring via the mode framework — substrates in dynamis, literal-fill composition, UI in widgets.*
