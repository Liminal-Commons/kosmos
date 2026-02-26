# Audio Device Selector — Settings UI, Signal Fix, Mode Transition Fix

*Prompt for Claude Code in the chora + kosmos repository context.*

*After this work, the settings panel has audio device selection and transcriber
configuration sections. The transcription button correctly shows inference
activity (not voice activity). Compose bar mode transitions are clean — no
cycling, no flash on expand from minimal. Depends on: PROMPT-SUBSTRATE-SIGNALS.md
(complete), PROMPT-VOICE-ACTIVITY.md (complete), PROMPT-LITERAL-FILL-ACCUMULATION.md
(complete).*

---

## Architectural Principle — Sensing Semantics Must Be Distinct

Each signal field must convey a single, unambiguous meaning. When two signal
fields track the same temporal window, the distinction they claim to make is
illusory — the UI cannot differentiate them and the user sees redundant feedback.

The mic button says "I hear you talking." The transcription button says
"I'm transcribing." These are different events in time: voice activity is
continuous during speech, transcription is a brief burst after speech ends.
If both signals are high during speech, the UI conflates them.

Mode transitions must be deterministic and user-intentional. A reflex that
fires on every entity sense cycle is not a transition — it's a loop. The
reflex should fire on meaningful state changes, not heartbeat updates.

---

## Methodology — DDD + TDD

This work follows **Doc → Test → Build → Verify**, non-negotiably.

1. **Doc (prescriptive)**: This prompt IS the prescriptive doc.
2. **Test (assert the doc)**: Write tests that assert the target state.
3. **Build (satisfy the tests)**: Implement until tests pass.
4. **Verify doc**: After implementation, update success criteria. Check
   docs/REGISTRY.md impact map.

Three concerns addressed in one prompt because they share the same files
and each is small enough that separate prompts would be over-ceremony.

---

## Current State

### What Exists and Works

| Component | Location | Status |
|-----------|----------|--------|
| `list-audio-devices` praxis | `genesis/soma/praxeis/voice.yaml` | Working — returns `{ devices: [{id, name, is_default}] }` |
| `update-audio-device` praxis | `genesis/soma/praxeis/voice.yaml` | Working — sets device_id + drift |
| `update-transcriber-config` praxis | `genesis/soma/praxeis/voice.yaml` | Working — sets model/lang/threads + drift |
| `list_audio_devices()` Rust | `crates/kosmos/src/voice.rs` | Working — cpal device enumeration |
| SettingsPanel | `app/src/components/SettingsPanel.tsx` | Working — credentials only |
| Signal registry | `crates/kosmos/src/signal.rs` | Working — general substrate signal broadcast |
| DOM signal bridge | `app/src/lib/layout-engine.tsx` | Working — `data-signal-*` attributes |
| Compose mode switch reflex | `genesis/thyra/reflexes/compose-mode-switch.yaml` | Working — fires on transcriber entity updates |

### What's Missing — The Gaps

1. **No audio device UI.** The three praxeis have no frontend. Users cannot
   select audio device or change whisper model from Thyra.

2. **Signal semantics conflated.** `segment_active` is `in_segment || inferring`.
   Since `in_segment` is true during voice (same window as `voice_active`),
   the transcription button lights up at the same time as the mic button.
   The transcription button should only respond to `inferring` — the brief
   whisper inference window after voice offset.

3. **Mode transition cycling.** `sense_transcription()` updates the transcriber
   entity on every sense cycle (via `last_sensed_at`). Each update fires the
   compose-mode-switch reflex. Although the praxis is effectively a no-op when
   modes are already correct, the reflex invocation is wasteful and can cause
   re-render churn. The reflex needs a meaningful state-change guard.

4. **Expand from minimal flashes.** compose-minimal's expand button hardcodes
   `to_mode_id: mode/compose-full`. When transcriber is active, the reflex
   then switches to compose-transcribing — visible flash. The expand should
   go directly to the right mode.

---

## Target State

### 1. SettingsPanel with Audio + Transcriber Sections

```typescript
// SettingsPanel.tsx — new sections after "Add Credential"

// Audio Input section:
// - On mount, call invokeKosmos("soma/list-audio-devices", {})
// - Show <select> with "System Default" + enumerated devices
// - On change, call invokeKosmos("soma/update-audio-device", {...})

// Transcriber section:
// - On mount, call findEntity("transcriber/default") for current config
// - Whisper model dropdown: tiny.en, base.en, small.en, medium.en, large-v3
// - Language input
// - Thread count input (1-16)
// - Save button → invokeKosmos("soma/update-transcriber-config", {...})
```

### 2. Signal Fix — `segment_active` Becomes `transcribing`

In `voice.rs`, the signal source registration:

```rust
// BEFORE (wrong — in_segment tracks same window as voice_active):
let segment_active = tsessions.values().any(|ts| {
    ts.in_segment.load(Ordering::Relaxed) || ts.inferring.load(Ordering::Relaxed)
});
map.insert("segment_active".into(), json!(segment_active));

// AFTER (correct — only the inference window):
let transcribing = tsessions.values().any(|ts| {
    ts.inferring.load(Ordering::Relaxed)
});
map.insert("transcribing".into(), json!(transcribing));
```

Whisper config — add `suppress_blank`:
```rust
// In run_whisper_inference():
params.set_single_segment(true);
params.set_suppress_blank(true);   // Always on — prevent empty transcript segments
```

CSS update:
```css
/* BEFORE */
.compose-bar__transcription[data-signal-segment-active="true"] { color: var(--color-voice); }

/* AFTER */
.compose-bar__transcription[data-signal-transcribing="true"] { color: var(--color-voice); }
```

### 3. Mode Transition Fixes

**compose-minimal expand** — two buttons with `when` conditions:

```yaml
# Expand to full (when transcriber not active)
- widget: button
  when: "@fed-by-transcriber.data.desired_state != 'active'"
  props:
    variant: ghost
    class: compose-bar__expand
    on_click: thyra/switch-mode
    on_click_params:
      config_id: thyra-config/workspace
      from_mode_id: mode/compose-minimal
      to_mode_id: mode/compose-full
  children:
    - widget: icon
      props:
        name: chevron-up
        size: sm

# Expand to transcribing (when transcriber active)
- widget: button
  when: "@fed-by-transcriber.data.desired_state == 'active'"
  props:
    variant: ghost
    class: compose-bar__expand
    on_click: thyra/switch-mode
    on_click_params:
      config_id: thyra-config/workspace
      from_mode_id: mode/compose-minimal
      to_mode_id: mode/compose-transcribing
  children:
    - widget: icon
      props:
        name: chevron-up
        size: sm
```

**Reflex guard** — The compose-mode-switch reflex should only fire on
`desired_state` changes, not every sense update. Add a condition to the
trigger that checks the field that changed:

Option A: Add a `response_condition` to the reflex that checks whether the
current mode already matches (requires interpreter support for conditions).

Option B: The simpler fix — have `sense_transcription()` NOT update
`last_sensed_at` when nothing meaningful changed (no new transcript, same
segment_status). This prevents the entity update, which prevents the reflex
from firing on heartbeat sense cycles.

Option B is correct — don't update the entity when nothing changed:

```rust
// In sense_transcription():
// Only include _entity_update when there IS new information
let has_new_transcript = !new_text.is_empty();
let status_changed = segment_status != data.get("segment_status")
    .and_then(|v| v.as_str())
    .unwrap_or("idle");

// Only update entity when something meaningful changed
if has_new_transcript || status_changed {
    // Include _entity_update with transcript + segment_status + last_sensed_at
} else {
    // Return sense result WITHOUT _entity_update — no entity mutation, no reflex
}
```

---

## Sequenced Work

### Phase 1: Signal Fix + Mode Transitions

**Goal:** Fix the transcription button signal and mode transition issues.

**Tests:**
- `test_signal_transcribing_only_during_inference` — verify signal field is
  `transcribing` (not `segment_active`), and only true when `inferring` is true
- `test_sense_transcription_no_update_on_idle` — verify `sense_transcription()`
  returns no `_entity_update` when nothing meaningful changed

**Implementation:**
1. In `voice.rs` signal registration: replace `segment_active = in_segment || inferring`
   with `transcribing = inferring`
2. In `voice.rs` `sense_transcription()`: only return `_entity_update` when
   transcript or segment_status actually changed
3. In `compose-minimal.yaml`: split expand button into two with `when` conditions
   based on `@fed-by-transcriber.data.desired_state`
4. In `voice.rs` `run_whisper_inference()`: add `params.set_suppress_blank(true)`
   after `set_single_segment(true)` — always on, not configurable
5. In `styles.css`: replace `[data-signal-segment-active="true"]` with
   `[data-signal-transcribing="true"]`
6. In `render-spec-authoring.md`: update signal attribute examples if referenced

**Phase 1 Complete When:**
- [x] Transcription button lights up only during whisper inference, not during voice
- [x] Mic button still lights up during voice activity (unchanged)
- [x] `suppress_blank` enabled in whisper inference
- [x] Expanding from compose-minimal goes directly to the correct mode
- [x] No mode cycling from sense heartbeats
- [x] All existing tests pass
- [x] 2 new tests pass

### Phase 2: Audio Device Selector

**Goal:** Add audio device and transcriber config to SettingsPanel.

**Tests:**
No new test file — this is a thin UI layer over tested praxeis. Verify
manually via `just dev`.

**Implementation:**
1. In `SettingsPanel.tsx`:
   - Import `findEntity` and `invokeKosmos` from stores
   - Add constants: `WHISPER_MODELS` array
   - Add state signals for device list, current device, transcriber config
   - Add `loadAudioConfig()` called on mount — fetches devices + entity state
   - Add `handleDeviceChange()` — calls `soma/update-audio-device`
   - Add `handleTranscriberSave()` — calls `soma/update-transcriber-config`
   - Add Audio Input section JSX after "Add Credential" section
   - Add Transcriber Configuration section JSX after Audio Input
2. In `styles.css`:
   - Add `.settings-panel__select--full { width: 100%; }`
   - Add `.settings-panel__field-label` styling

**Phase 2 Complete When:**
- [x] Settings panel shows audio device dropdown with enumerated devices
- [x] "System Default" option is present and selected when device_id is "default"
- [x] Changing device while mic is active restarts capture on new device
- [x] Settings panel shows transcriber config (model, language, threads)
- [x] Saving config while transcriber is active restarts transcription with new config
- [x] `just prod` builds successfully

---

## Files to Read

### Voice Substrate
- `crates/kosmos/src/voice.rs` — signal registration, sense_transcription()
- `crates/kosmos/src/signal.rs` — registry API

### Frontend
- `app/src/components/SettingsPanel.tsx` — existing settings panel
- `app/src/stores/kosmos.ts` — findEntity, invokeKosmos exports
- `app/src/styles.css` — signal CSS selectors

### Render-Specs
- `genesis/thyra/render-specs/compose-minimal.yaml` — expand button
- `genesis/thyra/render-specs/compose-full.yaml` — signal source bindings
- `genesis/thyra/render-specs/compose-transcribing.yaml` — signal source bindings

### Genesis
- `genesis/soma/praxeis/voice.yaml` — praxis param signatures
- `genesis/soma/entities/voice-defaults.yaml` — default entity IDs
- `genesis/thyra/reflexes/compose-mode-switch.yaml` — reflex definition

---

## Files to Touch

| File | Change |
|------|--------|
| `crates/kosmos/src/voice.rs` | **MODIFY** — Signal: `transcribing` replaces `segment_active`. Sense: conditional `_entity_update` |
| `app/src/components/SettingsPanel.tsx` | **MODIFY** — Add audio device + transcriber config sections |
| `app/src/styles.css` | **MODIFY** — Signal selector rename, settings CSS additions |
| `genesis/thyra/render-specs/compose-minimal.yaml` | **MODIFY** — Context-aware expand button |
| `crates/kosmos/tests/substrate_signals.rs` | **MODIFY** — Add signal semantics test |
| `crates/kosmos/tests/voice_activity.rs` | **MODIFY** — Add sense conditional update test |

---

## Success Criteria

### Phase 1
- [x] Signal field renamed from `segment_active` to `transcribing`
- [x] `transcribing` is true only when `inferring` is true (not `in_segment`)
- [x] `suppress_blank` enabled in `run_whisper_inference()`
- [x] CSS selector updated to `[data-signal-transcribing="true"]`
- [x] `sense_transcription()` returns no `_entity_update` on idle sense cycles
- [x] compose-minimal expand respects transcriber state
- [x] No mode cycling or flashing
- [x] 2 new tests pass

### Phase 2
- [x] Audio device dropdown in settings panel with cpal-enumerated devices
- [x] "System Default" option present
- [x] Device change calls `soma/update-audio-device` and triggers drift
- [x] Transcriber config section with model/language/threads
- [x] Config save calls `soma/update-transcriber-config` and triggers drift
- [x] `just prod` builds successfully

**Overall Complete When:**
- [x] All existing tests still pass
- [x] Transcription button visually distinct from mic button
- [x] Mode transitions are clean and deterministic
- [x] Audio device and transcriber config accessible from settings
- [x] No signal-related console errors

---

## What This Enables

1. **Users can select their preferred mic** — critical for setups with multiple
   audio inputs (external mic, headset, built-in).

2. **Users can choose whisper model** — trade off speed vs accuracy (tiny.en
   for fast/low quality, small.en for better accuracy).

3. **Clean visual feedback** — mic button = "I hear you", transcription button
   = "I'm transcribing". Two distinct temporal events, two distinct visual
   indicators.

4. **No reflex churn** — sense cycles don't fire reflexes unnecessarily. Entity
   updates happen only when state actually changes.

---

## What Does NOT Change

- Voice substrate operations (start/stop/sense) — unchanged
- Signal registry architecture — unchanged
- DOM signal bridge in layout-engine.tsx — unchanged
- Praxis definitions (list-audio-devices, update-audio-device, update-transcriber-config) — unchanged
- Compose-full and compose-transcribing render-specs — unchanged (except CSS selector)
- Bond traversal mechanism — unchanged
- Daemon sense loop frequency — unchanged

---

## Doc Impact Assessment

After implementation, these docs need review per REGISTRY.md Impact Map:

| Doc | What Changed |
|-----|-------------|
| `docs/reference/infrastructure/rest-api.md` | Update `substrate_signal` example: `segment_active` → `transcribing` (line 589) |
| `docs/design/VOICE-OIKOS-DESIGN.md` | Update signal field name in table (line 147) and CSS selector reference (line 149) |
| `docs/reference/presentation/render-spec-authoring.md` | Update signal attribute example if `segment_active` referenced |
| `docs/reference/domain/phasis-workspace.md` | compose-minimal description may need update re: context-aware expand |
| `docs/how-to/presentation/voice-authoring.md` | compose-minimal description update |
| `docs/REGISTRY.md` | No new files — verify voice.rs impact map still accurate |

---

*Traces to: PROMPT-SUBSTRATE-SIGNALS.md (signal architecture), PROMPT-VOICE-ACTIVITY.md (VAD + signals), PROMPT-LITERAL-FILL-ACCUMULATION.md (mode switching), T11 (reconciliation is substrate-universal)*
