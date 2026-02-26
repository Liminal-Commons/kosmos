# Substrate Signals — General Sensing Presence in Thyra

*Prompt for Claude Code in the chora + kosmos repository context.*

*After this work, any dynamis substrate can project ephemeral sensing data into thyra widgets through a general signal registry. Voice signals are the first consumer, but the mechanism is substrate-agnostic. Widgets opt into signals via render-spec bindings; CSS handles visual mapping. No per-substrate code in the layout engine.*

---

## Architectural Principle — Sensing Is Not Being

Entity state is **being** (ὕπαρξις) — persistent, reconciled, low frequency. `desired_state: active`, `actual_state: active`, `whisper_model: base`.

Substrate signals are **sensing** (αἴσθησις) — ephemeral, continuous measurement, high frequency. `energy_db: -28.3`, `voice_active: true`, `segment_active: true`.

Currently, voice signals are special-cased through the entire stack: a voice-specific struct, a voice-specific WsEvent variant, a voice-specific SolidJS signal, and a voice-specific `createEffect` that targets `.compose-bar__mic` by CSS class. This means every new substrate that wants live presence in thyra must add special-cased code at all four layers.

The general principle: **sensing data flows through a content-driven pipeline, not a code-driven one.**

```
SUBSTRATE MODULE          SIGNAL REGISTRY          WEBSOCKET          FRONTEND STORE          DOM

voice.rs ─────┐
              ├──► register_signal_source()
process.rs ───┘           │
                    read_all_signals()
                          │
                    10Hz timer (http.rs)
                          │
                    WsEvent::SubstrateSignal { entity_id, signals: Map }
                          │
                    substrateSignals: Map<entityId, Record<string, unknown>>
                          │
                    createEffect: [data-signal-source="X"] → data-signal-field="value"
                          │
                    CSS: .class[data-signal-field="value"] { ... }
```

The render-spec declares `data-signal-source` to opt a widget into signal binding. The layout engine applies signal fields as `data-signal-*` attributes. CSS handles visual mapping. No substrate-specific code in the frontend.

---

## Methodology — DDD + TDD

This work follows **Doc → Test → Build → Verify**, non-negotiably.

1. **Doc (prescriptive)**: This prompt IS the prescriptive doc.
2. **Test (assert the doc)**: Write tests that assert the target state. Tests should fail before implementation.
3. **Build (satisfy the tests)**: Implement until tests pass.
4. **Verify doc**: After implementation, update success criteria. Check docs/REGISTRY.md impact map.

**Clean break** from the voice-specific signal path. No backward compatibility — the old `VoiceSignal` struct, `WsEvent::VoiceSignal`, `voiceSignal()` store, and `.voice-active` CSS class are all replaced.

---

## Current State

### What Exists and Works

| Component | Location | Status |
|-----------|----------|--------|
| `VoiceSignal` struct | `voice.rs:174-181` | Working — 4 fields (entity_id, energy_db, voice_active, segment_active) |
| `read_voice_signal()` | `voice.rs:188-205` | Working — reads atomics from audio + transcription sessions |
| `WsEvent::VoiceSignal` | `websocket.rs:78-84` | Working — but only 3 fields (missing segment_active) |
| 10Hz timer | `http.rs:97-111` | Working — hardcoded `read_voice_signal("audio-source/default")` |
| `voiceSignal` SolidJS signal | `kosmos.ts:138-144` | Working — `VoiceSignalState` with 3 fields |
| Voice-active class toggle | `layout-engine.tsx:106-112` | Working — `createEffect` targets `.compose-bar__mic` |
| `data-segment` binding | compose-full.yaml:66, compose-transcribing.yaml:61 | Defined — reads `@fed-by-transcriber.data.segment_status` via entity update pipeline |
| CSS voice states | `styles.css:1164-1171` | Working — `.voice-active` class + `[data-segment]` selector |

### What's Missing — The Gaps

1. **No general signal registry.** Voice signals are the only kind, hardcoded at every layer. Adding process health signals, network status, or any other substrate would require duplicating the entire pipeline.

2. **`segment_active` never reaches the frontend.** The `VoiceSignal` struct has it, but `WsEvent::VoiceSignal` doesn't include it, so the transcription button never goes light green.

3. **Voice-specific code in layout-engine.** The `createEffect` that toggles `.voice-active` on `.compose-bar__mic` is substrate-specific code in what should be a generic interpreter.

4. **Two competing signal paths for transcription.** `data-segment` goes through entity update pipeline (slow, indirect); `segment_active` should go through the signal pipeline (fast, direct) but doesn't reach the frontend.

5. **No render-spec mechanism for signal binding.** Widgets can't declare which signal source they want — the layout engine targets them by CSS class name.

---

## Target State

### 1. Signal Registry (`crates/kosmos/src/signal.rs`)

```rust
use serde_json::{Map, Value};
use std::sync::{Mutex, OnceLock};

/// A snapshot of ephemeral substrate state — sensing, not being.
pub struct SubstrateSignal {
    pub entity_id: String,
    pub signals: Map<String, Value>,
}

type SignalSource = Box<dyn Fn() -> Vec<SubstrateSignal> + Send + Sync>;

fn signal_sources() -> &'static Mutex<Vec<SignalSource>> {
    static SOURCES: OnceLock<Mutex<Vec<SignalSource>>> = OnceLock::new();
    SOURCES.get_or_init(|| Mutex::new(Vec::new()))
}

/// Register a signal source. Called by substrate modules.
pub fn register_signal_source(source: SignalSource) {
    signal_sources().lock().unwrap().push(source);
}

/// Read all signals from all registered sources.
pub fn read_all_signals() -> Vec<SubstrateSignal> {
    let sources = signal_sources().lock().unwrap();
    sources.iter().flat_map(|s| s()).collect()
}
```

### 2. Voice Signal Source (registered in `voice.rs`)

```rust
/// Register voice as a signal source. Called once on first audio session start.
fn register_voice_signal_source() {
    signal::register_signal_source(Box::new(|| {
        let mut signals = Vec::new();
        let sessions = audio_sessions().lock().unwrap();
        for (entity_id, session) in sessions.iter() {
            let segment_active = {
                let tsessions = transcription_sessions().lock().unwrap();
                tsessions.values().any(|ts| {
                    ts.in_segment.load(Ordering::Relaxed) || ts.inferring.load(Ordering::Relaxed)
                })
            };
            let mut map = Map::new();
            map.insert("energy_db".into(), json!(f32::from_bits(
                session.energy_db_atomic.load(Ordering::Relaxed)
            )));
            map.insert("voice_active".into(), json!(
                session.voice_active_atomic.load(Ordering::Relaxed)
            ));
            map.insert("segment_active".into(), json!(segment_active));
            signals.push(SubstrateSignal {
                entity_id: entity_id.clone(),
                signals: map,
            });
        }
        signals
    }));
}
```

### 3. WsEvent (`websocket.rs`)

```rust
/// Ephemeral substrate signal — sensing, not being.
/// Sent at ~10Hz for active substrates.
SubstrateSignal {
    entity_id: String,
    signals: Map<String, Value>,
},
```

### 4. 10Hz Timer (`http.rs`)

```rust
// General: read all substrate signals, broadcast each
for signal in kosmos::signal::read_all_signals() {
    let _ = signal_tx.send(WsEvent::SubstrateSignal {
        entity_id: signal.entity_id,
        signals: signal.signals,
    });
}
```

### 5. Frontend Signal Store (`kosmos.ts`)

```typescript
// General signal store — keyed by entity ID
const [substrateSignals, setSubstrateSignals] =
  createSignal<Map<string, Record<string, unknown>>>(new Map());

// In handleWsEvent:
case "substrate_signal": {
  const entityId = event.entity_id as string;
  const newSignals = event.signals as Record<string, unknown>;
  setSubstrateSignals(prev => {
    const next = new Map(prev);
    next.set(entityId, newSignals);
    return next;
  });
  break;
}
```

### 6. Signal DOM Bridge (`layout-engine.tsx`)

```typescript
// General: find all elements with data-signal-source, apply signal values as data-signal-* attrs
createEffect(() => {
  const signals = substrateSignals();
  for (const [entityId, data] of signals) {
    const els = document.querySelectorAll(`[data-signal-source="${entityId}"]`);
    for (const el of els) {
      for (const [key, value] of Object.entries(data)) {
        el.setAttribute(`data-signal-${key.replace(/_/g, '-')}`, String(value));
      }
    }
  }
});
```

### 7. Render-Spec Signal Binding

Widgets opt into signal binding via `data-signal-source`:

```yaml
# compose-full.yaml — mic button
- widget: button
  props:
    class: compose-bar__mic
    data-signal-source: "{@fed-by-audio.id}"       # ← opt into signals
    data-state: "{@fed-by-audio.data.actual_state}"
    on_click: soma/toggle-audio-intent
    on_click_params:
      entity_id: "{@fed-by-audio.id}"

# compose-full.yaml — transcription button
- widget: button
  props:
    class: compose-bar__transcription
    data-signal-source: "{@fed-by-audio.id}"       # ← same source (segment_active comes from audio source's signal)
    data-state: "{@fed-by-transcriber.data.desired_state}"
    on_click: soma/toggle-transcription
    on_click_params:
      entity_id: "{@fed-by-transcriber.id}"
```

### 8. CSS Signal Selectors

```css
/* Mic button — entity state + signal-driven states */
.compose-bar__mic[data-state="closed"] { color: var(--color-muted); }
.compose-bar__mic[data-state="active"] { color: var(--color-active); }
.compose-bar__mic[data-signal-voice-active="true"] { color: var(--color-voice); }

/* Transcription button — entity state + signal-driven states */
.compose-bar__transcription[data-state="closed"] { color: var(--color-muted); }
.compose-bar__transcription[data-state="active"] { color: var(--color-active); }
.compose-bar__transcription[data-signal-segment-active="true"] { color: var(--color-voice); }
```

### What Gets Deleted

| Component | Why |
|-----------|-----|
| `VoiceSignal` struct in voice.rs | Replaced by `SubstrateSignal` |
| `read_voice_signal()` in voice.rs | Replaced by signal source closure |
| `WsEvent::VoiceSignal` variant | Replaced by `WsEvent::SubstrateSignal` |
| `VoiceSignalState` interface in kosmos.ts | Replaced by `Map<string, Record<string, unknown>>` |
| `voiceSignal` SolidJS signal | Replaced by `substrateSignals` |
| `.voice-active` CSS class toggle in layout-engine.tsx | Replaced by general signal DOM bridge |
| `.voice-active` CSS rule in styles.css | Replaced by `[data-signal-voice-active]` selector |
| `data-segment` binding in render-specs | Replaced by `data-signal-source` + `data-signal-segment-active` |
| `[data-segment]` CSS rule in styles.css | Replaced by `[data-signal-segment-active]` selector |

---

## Sequenced Work

### Phase 1: Signal Registry + Voice Migration (Rust)

**Goal:** Create the general signal registry module and migrate voice signals to use it. Replace `WsEvent::VoiceSignal` with `WsEvent::SubstrateSignal`.

**Tests** (in `crates/kosmos/tests/substrate_signals.rs`):
- `test_signal_registry_empty` — no registered sources → `read_all_signals()` returns empty
- `test_signal_registry_single_source` — register one source, read signals, verify entity_id + fields
- `test_signal_registry_multiple_sources` — register two sources, read all, verify both present
- `test_voice_registers_signal_source` — start audio session, verify voice signals appear in `read_all_signals()`

**Implementation:**
1. Create `crates/kosmos/src/signal.rs` with `SubstrateSignal`, `register_signal_source()`, `read_all_signals()`
2. Add `pub mod signal;` to `crates/kosmos/src/lib.rs`
3. In `voice.rs`: add `register_voice_signal_source()` function, call it once in `start_audio()` (use `OnceLock<bool>` guard)
4. Delete `VoiceSignal` struct and `read_voice_signal()` from `voice.rs`
5. In `websocket.rs`: replace `VoiceSignal` variant with `SubstrateSignal { entity_id: String, signals: Map<String, Value> }`
6. In `http.rs`: replace `read_voice_signal("audio-source/default")` with loop over `kosmos::signal::read_all_signals()`
7. Add `serde_json` to signal.rs imports (already workspace dep)

**Phase 1 Complete When:**
- [x] `signal.rs` module exists with registry API
- [x] Voice signals flow through registry (not direct read)
- [x] `WsEvent::SubstrateSignal` replaces `WsEvent::VoiceSignal`
- [x] 10Hz timer uses `read_all_signals()` instead of hardcoded entity ID
- [x] 4 new tests pass
- [x] All existing tests still pass

### Phase 2: Frontend Signal Store + DOM Bridge

**Goal:** Replace the voice-specific frontend signal path with a general signal store and data-attribute bridge. Update render-specs and CSS.

**Tests** (manual verification — SolidJS unit tests not available):
- Start Thyra, verify mic button goes green on voice activity (same behavior, new mechanism)
- Start Thyra, verify transcription button goes light green during active transcription
- Verify no console errors related to substrate_signal events

**Implementation:**
1. In `http-client.ts`: add `"substrate_signal"` to WsEvent type union, add `signals?: Record<string, unknown>` field
2. In `kosmos.ts`: replace `VoiceSignalState` and `voiceSignal` with `substrateSignals` (Map-based store). Update `handleWsEvent` for `substrate_signal` case. Export `substrateSignals` instead of `voiceSignal`.
3. In `layout-engine.tsx`: replace voice-specific `createEffect` with general signal DOM bridge. Import `substrateSignals` instead of `voiceSignal`.
4. In `compose-full.yaml`: add `data-signal-source: "{@fed-by-audio.id}"` to mic button and transcription button. Remove `data-segment` binding from transcription button.
5. In `compose-transcribing.yaml`: same changes as compose-full.yaml.
6. In `styles.css`: replace `.compose-bar__mic.voice-active` with `.compose-bar__mic[data-signal-voice-active="true"]`. Replace `.compose-bar__transcription[data-segment="transcribing"]` with `.compose-bar__transcription[data-signal-segment-active="true"]`.
7. Remove `compose-minimal.yaml` `data-segment` binding if present.

**Phase 2 Complete When:**
- [x] `substrateSignals` store replaces `voiceSignal`
- [x] General DOM bridge applies `data-signal-*` attributes
- [x] Render-specs use `data-signal-source` instead of voice-specific bindings
- [x] CSS uses `[data-signal-*]` attribute selectors
- [x] No voice-specific code remains in layout-engine.tsx
- [x] Mic button voice activity works (green on voice)
- [x] Transcription button segment activity works (light green during inference)
- [x] `just prod` builds successfully

---

## Files to Read

### Signal Architecture (Rust)
- `crates/kosmos/src/voice.rs` — current VoiceSignal struct, read_voice_signal(), session registries
- `crates/kosmos-mcp/src/websocket.rs` — current WsEvent::VoiceSignal variant
- `crates/kosmos-mcp/src/http.rs` — current 10Hz timer
- `crates/kosmos/src/lib.rs` — module declarations

### Frontend Signal Path
- `app/src/lib/http-client.ts` — WsEvent type definition
- `app/src/stores/kosmos.ts` — VoiceSignalState, voiceSignal, handleWsEvent
- `app/src/lib/layout-engine.tsx` — voice-active createEffect
- `app/src/styles.css` — voice state CSS rules

### Render-Specs
- `genesis/thyra/render-specs/compose-full.yaml` — mic + transcription buttons
- `genesis/thyra/render-specs/compose-transcribing.yaml` — mic + transcription buttons
- `genesis/thyra/render-specs/compose-minimal.yaml` — check for data-segment

---

## Files to Touch

| File | Change |
|------|--------|
| `crates/kosmos/src/signal.rs` | **NEW** — Signal registry module |
| `crates/kosmos/src/lib.rs` | **MODIFY** — Add `pub mod signal` |
| `crates/kosmos/src/voice.rs` | **MODIFY** — Delete VoiceSignal/read_voice_signal, add register_voice_signal_source |
| `crates/kosmos-mcp/src/websocket.rs` | **MODIFY** — Replace VoiceSignal with SubstrateSignal |
| `crates/kosmos-mcp/src/http.rs` | **MODIFY** — Use read_all_signals() in 10Hz timer |
| `crates/kosmos/tests/substrate_signals.rs` | **NEW** — Signal registry tests |
| `app/src/lib/http-client.ts` | **MODIFY** — Add substrate_signal to WsEvent |
| `app/src/stores/kosmos.ts` | **MODIFY** — Replace voiceSignal with substrateSignals |
| `app/src/lib/layout-engine.tsx` | **MODIFY** — Replace voice-specific effect with general bridge |
| `app/src/styles.css` | **MODIFY** — Replace .voice-active and [data-segment] with [data-signal-*] |
| `genesis/thyra/render-specs/compose-full.yaml` | **MODIFY** — Add data-signal-source, remove data-segment |
| `genesis/thyra/render-specs/compose-transcribing.yaml` | **MODIFY** — Add data-signal-source, remove data-segment |

---

## Success Criteria

### Phase 1
- [x] Signal registry module exists at `crates/kosmos/src/signal.rs`
- [x] `register_signal_source()` and `read_all_signals()` API works
- [x] Voice registers as a signal source (once, on first audio start)
- [x] `WsEvent::SubstrateSignal` carries `entity_id` + `signals: Map`
- [x] 10Hz timer iterates all signal sources
- [x] 4 new tests pass
- [x] All existing tests pass

### Phase 2
- [x] `substrateSignals` Map store replaces `voiceSignal`
- [x] General DOM bridge in layout-engine.tsx (no substrate-specific code)
- [x] Render-specs declare `data-signal-source` for signal binding
- [x] CSS uses `[data-signal-*]` selectors
- [x] Mic button: gray (closed) → dark green (active) → light green (voice activity)
- [x] Transcription button: gray (closed) → dark green (active) → light green (segment active)
- [x] `just prod` builds and runs successfully

**Overall Complete When:**
- [x] All existing tests still pass
- [x] 4 new signal registry tests pass
- [x] No voice-specific code in layout-engine.tsx
- [x] No VoiceSignal struct in voice.rs
- [x] No WsEvent::VoiceSignal in websocket.rs
- [x] Transcription button correctly shows three states
- [x] docs/REGISTRY.md impact map checked, affected docs updated

---

## What This Enables

1. **Any substrate can project live presence into thyra widgets** — process health, network status, storage sync progress — by registering a signal source and declaring `data-signal-source` in render-specs.

2. **New signal types require zero frontend code changes** — add a signal source in Rust, add CSS rules, done. The DOM bridge is fully generic.

3. **The transcription button finally works** — three-state visual (gray/dark green/light green) driven by the same fast 10Hz signal path as the mic button.

4. **Dead voice-specific code removed** — `VoiceSignal`, `read_voice_signal()`, `VoiceSignalState`, `.voice-active` class toggling — all replaced by the general mechanism.

---

## What Does NOT Change

- **Entity data bindings** (`{field}`, `{@bond-name.data.field}`) — unchanged. Signals are orthogonal to entity data.
- **Entity update pipeline** — `_entity_update`, `apply_entity_update()`, reconciliation — unchanged.
- **Voice substrate operations** — `start_audio()`, `start_transcription()`, `sense_audio()`, `sense_transcription()` — unchanged.
- **10Hz timer frequency** — stays at 100ms intervals.
- **Daemon loop** — no changes to daemon-driven sensing.
- **Form bindings** (`$form.*`) — unchanged.
- **Bond traversal** (`@bond-name`) — unchanged.

---

## Doc Impact Assessment

After implementation, these docs need review per REGISTRY.md Impact Map:

| Doc ID | What Changed |
|--------|-------------|
| substrate-integration | Add signal source to standard contract alongside `execute_operation` |
| actualization-pattern | Add continuous sensing signals concept (sensing vs being) |
| rest-api | Add `substrate_signal` to WebSocket event types |
| VOICE-OIKOS-DESIGN | Update to reference general signal mechanism |
| render-spec-authoring | Document `data-signal-source` binding |
| mode-development | How to create modes with live signal presence |
| voice-authoring | Update signal pathway documentation |
| soma-client | Updated WebSocket events |

---

*Traces to: PROMPT-VOICE-ACTIVITY.md (voice signal architecture), T11 (reconciliation is substrate-universal), Voice Signal Architecture (MEMORY.md)*
