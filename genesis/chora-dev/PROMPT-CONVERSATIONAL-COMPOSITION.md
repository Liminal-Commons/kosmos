# Conversational Composition — Content Enters Kosmos Through the Graph

*Prompt for Claude Code in the chora + kosmos repository context.*

*After this work, transcript text lives on the transcriber entity in the graph. Accumulation content is composed from the bonded transcriber via typos-def-accumulation. When the transcriber entity updates with new transcript, composition reconciliation fires and accumulation content recomposes. Transcription and manual text entry are mutually exclusive — the textarea is disabled during transcription, enabled when transcription is off. Mic and transcription buttons provide visual feedback: gray when muted, dark green when active, light green on voice activity, bright green while transcribing a segment. Clarification works regardless of mode. This establishes the one right way for content to enter kosmos: through graph-mediated composition.*

*Depends on:*
- *PROMPT-COMPOSITION-RECONCILIATION.md — depends-on bonds, idempotent compose, cascade (DONE)*
- *PROMPT-VOICE-ACTIVITY.md — VAD, segment-based transcription, sense daemon (DONE)*
- *PROMPT-COMPOSE-BAR.md — modes, render-specs, bond traversal (DONE)*

---

## Architectural Principle — The Composition Requirement

> "Nothing arises raw. Everything is composed."
> — KOSMOGONIA, The Composition Requirement

> "compose(typos, inputs) → entity with provenance"

> "Typos declares slots and fill methods — how to produce an entity"

The compose bar is where a parousia speaks. Two input modalities exist — voice transcription and manual text entry — but they are **mutually exclusive**. When transcription is active, the textarea is disabled and content flows through the graph: whisper produces text → sensed onto transcriber entity → composition reconciliation → accumulation content. When transcription is off, the textarea is enabled and the user types directly.

**Clarification** works the same regardless of mode. Click the button → governed inference refines content → content updates. Commit works the same regardless of mode — cross the commitment boundary, content becomes phasis.

Currently, transcript text is trapped in an `Arc<Mutex<Vec<TranscriptResult>>>` — invisible to kosmos. The `_entity_update` contract writes `actual_state` and `last_sensed_at` to the transcriber entity but discards the transcript. The text evaporates at the boundary between substrate and graph.

The fix is not to "route transcripts to the accumulation." The fix is to make the transcript entity state, and let the graph do what it already knows how to do.

```
whisper → buffer → sense drains → _entity_update → transcriber entity
                                                         │
                                              fed-by-transcriber bond
                                            (depends-on created at compose)
                                                         │
                                              compose-dependents reflex
                                                         │
                                              compose(typos-def-accumulation)
                                                         │
                                              queried slot resolves
                                              transcriber.transcript
                                                         │
                                              accumulation.content
                                                         │
                                                  textarea displays
```

The pattern established here — content entering kosmos through graph-mediated composition — is the pattern for conversational entity creation. If we get this right, the same pattern scales to creating eide, thyra modes, actualization modes, render-specs — anything expressible as kosmos content. The homoiconic reach means the compose bar is the universal creation surface.

### Mutual Exclusivity — Mode Switching Replaces Conditionals

Transcription and manual text entry do not coexist. This is a design commitment:

- **Transcription on**: textarea disabled (read-only), content composed from transcriber via graph. User sees transcript appearing as they speak.
- **Transcription off**: textarea enabled, user types directly. Content is entity state, not composed.
- **Turning off transcription**: transcript text becomes the starting content. User can now edit, clarify, or commit.
- **Turning on transcription**: clears content and begins fresh capture. Or appends — this is a UX decision, but the architecture supports both.

The two existing modes handle this: `mode/compose-full` (manual entry) and `mode/compose-transcribing` (transcription active). Mode switching is the mechanism — no conditionals in the interpreter.

### Visual Feedback — Buttons as State Indicators

The mic and transcription buttons provide continuous visual feedback:

| Button | State | Color | Source |
|--------|-------|-------|--------|
| Mic | Muted (desired_state: closed) | Gray | Entity state |
| Mic | Active, no voice | Dark green | Entity state (desired_state: active) |
| Mic | Voice activity detected | Light green | VoiceSignal (voice_active: true) |
| Transcription | Disabled (desired_state: closed) | Gray | Entity state |
| Transcription | Active, idle | Dark green | Entity state (desired_state: active, segment_status: idle) |
| Transcription | Detecting speech | Dark green | Entity state (segment_status: detecting) |
| Transcription | Transcribing segment | Bright green | Entity state (segment_status: transcribing) |

Entity-state-driven colors bind through render-spec `data-state` attributes + CSS. Signal-driven colors (voice activity) use the VoiceSignal WebSocket channel — ephemeral, 10Hz, separate from entity state.

---

## Methodology — DDD + TDD

This work follows **Doc → Test → Build → Verify**, non-negotiably.

1. **Doc (prescriptive)**: This prompt IS the prescriptive doc.
2. **Test (assert the doc)**: Write tests that assert transcript reaches entity, composition fires, accumulation content updates.
3. **Build (satisfy the tests)**: Implement until tests pass.
4. **Verify doc**: After implementation, update success criteria. Check docs/REGISTRY.md impact map.

**Additive layering.** Each phase builds on the prior. Phase 1 can be tested independently (transcript on entity). Phase 2 requires Phase 1 (composition needs entity state). Phase 3 requires Phase 2 (visual feedback requires the full pipeline).

---

## Current State

### What Exists and Works

| Component | Location | Status |
|-----------|----------|--------|
| `typos-def-accumulation` | `thyra/typos/thyra.yaml` | Shell — `target_eidos: accumulation`, no slots |
| `accumulation/default` entity | `thyra/entities/default-accumulation.yaml` | Working — bonds to audio-source and transcriber |
| `desmos/fed-by-transcriber` | `thyra/desmoi/thyra.yaml` | Working — accumulation → transcriber bond |
| `desmos/clarified-by` | `thyra/desmoi/thyra.yaml` | Working — accumulation → generation bond |
| `eidos/transcriber` | `soma/eide/voice.yaml` | Working — lifecycle fields, `segment_status` field, no transcript field |
| `sense_transcription()` | `crates/kosmos/src/voice.rs:581` | Working — drains buffer, returns transcripts in JSON, `_entity_update` excludes transcript |
| `apply_entity_update()` | `crates/kosmos/src/host.rs:1257` | Working — merges `_entity_update` fields into entity data |
| `compose-dependents` reflex | `demiurge/reflexes/composition.yaml` | Working — traces depends-on, composes dependents |
| `_composition_inputs` | `interpreter/steps.rs` | Working — stored on composed entities, read for μεταβολή path |
| `clarify-accumulation` praxis | `thyra/praxeis/thyra.yaml` | Working — governed inference on content |
| `clarify-on-transcript` reflex | `thyra/reflexes/clarify-on-transcript.yaml` | Defined — references `raw_content` field (premature — manual clarification first) |
| `append-utterance` praxis | `thyra/praxeis/thyra.yaml` | Working — direct mutation (to be deprecated by composition) |
| Voice pipeline | `crates/kosmos/src/voice.rs` | Working — cpal capture, VAD, whisper inference, segment detection |
| 10Hz signal broadcast | `crates/kosmos-mcp/src/http.rs` | Working — VoiceSignal events over WebSocket |
| `mode/compose-full` | `thyra/modes/screen.yaml` | Working — manual entry mode |
| `mode/compose-transcribing` | `thyra/modes/screen.yaml` | Working — transcription mode with badge |
| `segment_status` field | `soma/eide/voice.yaml` | Working — idle/detecting/transcribing |
| `compose-full` render-spec | `thyra/render-specs/compose-full.yaml` | Working — `when` clauses for mic icon, bond traversal |

### What's Missing — The Gaps

1. **Transcript never reaches the entity.** `sense_transcription()` drains the buffer and returns transcripts in the response, but `_entity_update` only includes `actual_state` and `last_sensed_at`. The transcript text evaporates — returned in the sense result JSON but never written to the transcriber entity.

2. **No transcript field on transcriber eidos.** `eidos/transcriber` has lifecycle fields but no field to hold transcript output. The eidos doesn't declare that a transcriber produces text.

3. **Accumulation typos has no slots.** `typos-def-accumulation` is a shell — `target_eidos: accumulation` and nothing else. No slots, no fill methods. The typos doesn't declare how accumulation content is composed from sources.

4. **No depends-on bond from accumulation to transcriber.** The `fed-by-transcriber` bond exists (rendering bond for @-syntax traversal), but no `depends-on` bond connects them for composition reconciliation. The compose-dependents reflex traces `depends-on` bonds — without one, transcriber changes don't trigger accumulation recomposition.

5. **Textarea not disabled during transcription.** `compose-transcribing` render-spec doesn't set the textarea to read-only. Users could edit while transcribing, creating conflicting writes.

6. **No visual feedback on buttons.** Mic and transcription buttons don't indicate muted/active/voice-activity/transcribing states via color. No CSS support for state-driven button colors.

7. **`append-utterance` uses direct mutation.** Bypasses composition — transcript text should flow through the graph, not through a praxis that directly writes to accumulation.content.

---

## Target State

### Enhanced Transcriber Eidos

`eidos/transcriber` gains a `transcript` field:

```yaml
transcript:
  type: string
  required: false
  default: ""
  description: "Accumulated transcript text from whisper inference. Appended by sense daemon, cleared on session stop or phasis commit."
```

### Enhanced Accumulation Typos

`typos-def-accumulation` declares slots and fill methods:

```yaml
- eidos: typos
  id: typos-def-accumulation
  data:
    name: accumulation
    description: |
      Compose an accumulation entity from its sources.

      One queried slot resolves transcript text from the bonded
      transcriber entity via fed-by-transcriber:

        transcript: queried from bonded transcriber.transcript

      content = transcript (direct mapping).

      When no transcriber is bonded or transcript is empty,
      content defaults to empty string.

      Manual text entry bypasses composition — in manual mode,
      content is written directly to the entity. Composition
      only governs the transcription-to-accumulation flow.
    target_eidos: accumulation
    slots:
      transcript:
        fill: queried
        query:
          bond: fed-by-transcriber
          field: transcript
        default: ""
    template:
      content: "{{ transcript }}"
```

### Sense Writes Transcript to Entity

`sense_transcription()` includes accumulated transcript text in `_entity_update`:

```rust
// In sense_transcription(), after draining buffer:
let new_text: String = transcripts.iter()
    .filter_map(|t| {
        let text = t.get("text")?.as_str()?.trim();
        if text.is_empty() { None } else { Some(text.to_string()) }
    })
    .collect::<Vec<_>>()
    .join(" ");

// Append to existing transcript on entity
let existing = data
    .get("transcript")
    .and_then(|v| v.as_str())
    .unwrap_or("");

let full_transcript = match (existing.is_empty(), new_text.is_empty()) {
    (_, true) => existing.to_string(),      // No new text — preserve existing
    (true, false) => new_text,               // First text
    (false, false) => format!("{} {}", existing, new_text),  // Append
};

Ok(json!({
    "status": "active",
    "entity_id": entity_id,
    "model": session.model_name,
    "transcripts": transcripts,
    "_entity_update": {
        "actual_state": "active",
        "transcript": full_transcript,
        "last_sensed_at": chrono::Utc::now().to_rfc3339()
    }
}))
```

### Depends-On Bond

When `begin-accumulation` or bootstrap composes accumulation via `typos-def-accumulation`, `compose_entity()` creates a `depends-on` bond from `accumulation/default` to `transcriber/default` (because the `transcript` slot queries the transcriber). This bond is created automatically by the composition infrastructure — no manual bond authoring needed.

The `fed-by-transcriber` bond continues to serve rendering (for @-syntax in render-specs). `depends-on` serves composition reconciliation. Both exist in parallel — different purposes, same entities.

### Textarea Disabled During Transcription

`compose-transcribing` render-spec sets the textarea to read-only:

```yaml
# In compose-transcribing render-spec
- widget: textarea
  props:
    name: content
    value: "{content}"
    placeholder: "Transcribing..."
    rows: 2
    class: compose-bar__textarea
    readonly: true
```

`compose-full` render-spec keeps the textarea editable (no `readonly` prop — current behavior).

### Button Visual Feedback

Render-specs bind button state via `data-state` attributes. CSS drives color:

```yaml
# Mic button — state from bonded audio-source
- widget: button
  props:
    variant: ghost
    class: compose-bar__mic
    data-state: "{@fed-by-audio.data.desired_state}"
    on_click: soma/toggle-audio-intent
    on_click_params:
      accumulation_id: "{id}"
  children:
    - widget: icon
      when: "@fed-by-audio.data.desired_state == 'active'"
      props:
        name: mic
        size: sm
    - widget: icon
      when: "@fed-by-audio.data.desired_state != 'active'"
      props:
        name: mic-off
        size: sm

# Transcription button — state from bonded transcriber
- widget: button
  props:
    variant: ghost
    class: compose-bar__transcription
    data-state: "{@fed-by-transcriber.data.desired_state}"
    data-segment: "{@fed-by-transcriber.data.segment_status}"
    on_click: soma/toggle-transcriber-intent
    on_click_params:
      accumulation_id: "{id}"
  children:
    - widget: icon
      props:
        name: headphones
        size: sm
```

CSS:

```css
/* Mic button states */
.compose-bar__mic[data-state="closed"] { color: var(--color-muted); }
.compose-bar__mic[data-state="active"] { color: var(--color-active); }
.compose-bar__mic.voice-active { color: var(--color-voice); }

/* Transcription button states */
.compose-bar__transcription[data-state="closed"] { color: var(--color-muted); }
.compose-bar__transcription[data-state="active"] { color: var(--color-active); }
.compose-bar__transcription[data-segment="transcribing"] { color: var(--color-transcribing); }
```

CSS variables:

```css
:root {
  --color-muted: #6b7280;        /* Gray — muted/disabled */
  --color-active: #166534;        /* Dark green — active, no activity */
  --color-voice: #22c55e;         /* Light green — voice activity detected */
  --color-transcribing: #4ade80;  /* Bright green — segment being transcribed */
}
```

The `voice-active` CSS class is applied by the frontend VoiceSignal handler — driven by the ephemeral 10Hz WebSocket signal, not entity state. Entity state (`data-state`, `data-segment`) drives the base color; the ephemeral signal adds the voice-activity pulse.

### Mode Switching on Toggle

When the user toggles transcription:

- **On (transcription starts)**: mode switches from `compose-full` to `compose-transcribing`. Textarea becomes read-only. Content recomposition begins from transcriber.
- **Off (transcription stops)**: mode switches from `compose-transcribing` to `compose-full`. Textarea becomes editable. Current content (last transcript) stays — user can edit, clarify, or commit.

The toggle praxis (`soma/toggle-transcriber-intent`) already flips desired_state. Mode switching is triggered by a reflex that watches transcriber desired_state transitions.

### What Becomes Unnecessary

- **`append-utterance` praxis**: Direct mutation replaced by graph-mediated composition. Remove.
- **`append-fragment` praxis**: Same pattern — direct append replaced by composition input. Remove.
- **`clarify-on-transcript` reflex**: Premature — designed for automatic clarification on raw_content change. Manual clarification via button is the first step. Reflex can be disabled or removed; re-introduce when automatic clarification is desired.

---

## Sequenced Work

### Phase 1: Transcript Becomes Entity State

**Goal:** Whisper output reaches the transcriber entity as graph state. Queryable, bondable, composable.

**Tests:**
- `test_sense_transcription_includes_transcript_in_entity_update` — call `sense_transcription()` with accumulated transcript buffer → verify `_entity_update` contains `transcript` field with text
- `test_sense_transcription_appends_to_existing_transcript` — entity already has transcript "hello", sense returns "world" → `_entity_update.transcript` = "hello world"
- `test_sense_transcription_empty_buffer_preserves_existing` — no new transcripts → `_entity_update.transcript` preserves existing value
- `test_transcriber_entity_holds_transcript_after_sense` — bootstrap + start transcription + sense → `transcriber/default.data.transcript` has text

**Implementation:**

1. Add `transcript` field to `eidos/transcriber` in `genesis/soma/eide/voice.yaml`
2. Add `transcript: ""` default to `transcriber/default` in `genesis/soma/entities/voice-defaults.yaml`
3. Modify `sense_transcription()` in `voice.rs`:
   - After draining buffer, concatenate transcript text from segments
   - Read existing `transcript` from entity data (the `data` parameter)
   - Append new text to existing with space separator
   - Include `transcript` in `_entity_update`
4. `apply_entity_update()` in host.rs already handles merge — no change needed
5. Clear `transcript` field in `stop_transcription()` (reset on session end)

**Phase 1 Complete When:**
- [ ] `eidos/transcriber` has `transcript` field
- [ ] `sense_transcription()` includes transcript in `_entity_update`
- [ ] Transcript accumulates across sense cycles (append, not replace)
- [ ] `transcriber/default.data.transcript` holds transcribed text after voice session
- [ ] All existing tests pass

### Phase 2: Accumulation Composes From the Graph

**Goal:** Accumulation content is composed from the bonded transcriber via `typos-def-accumulation`. When the transcriber entity updates with new transcript, composition reconciliation fires and accumulation content recomposes.

**Tests:**
- `test_accumulation_typos_has_transcript_slot` — verify `typos-def-accumulation` has `transcript` queried slot
- `test_compose_accumulation_resolves_transcript_from_bond` — compose accumulation → transcript slot queries bonded transcriber.transcript → content = transcript text
- `test_compose_accumulation_creates_depends_on_bond` — after composition, `depends-on` bond exists from accumulation to transcriber
- `test_transcriber_update_triggers_accumulation_recompose` — update `transcriber/default.data.transcript` → compose-dependents fires → `accumulation/default.data.content` updates
- `test_compose_accumulation_idempotent` — compose twice with same transcript → no change (hash match, cascade terminates)
- `test_compose_accumulation_empty_transcript` — transcriber has empty transcript → content = "" (graceful handling)

**Implementation:**

1. Enhance `typos-def-accumulation` in `genesis/thyra/typos/thyra.yaml`:
   - Add `transcript` queried slot: bond `fed-by-transcriber`, field `transcript`
   - Template: `content: "{{ transcript }}"`
2. Verify or implement bond-based queried slot resolution in `resolve_slot()` (`steps.rs`):
   - When slot fill is `queried` with a `bond` field: trace the bond from the composed entity, read the target field
   - If not implemented, add: `trace_bonds(entity_id, None, bond_name)` → get target → read field
3. Verify `compose_entity()` creates `depends-on` bond for queried slot (from PROMPT-COMPOSITION-RECONCILIATION)
4. Update `begin-accumulation` praxis to work with enhanced typos (may need to pass empty inputs for literal slots)
5. Verify compose-dependents reflex fires when transcriber updates → recomposes accumulation
6. Remove `append-utterance` praxis (replaced by composition)
7. Remove `append-fragment` praxis (replaced by composition)

**Phase 2 Complete When:**
- [ ] `typos-def-accumulation` has queried slot for transcript from bonded transcriber
- [ ] Bond-based slot resolution works (follow bond → read field)
- [ ] `depends-on` bond created from accumulation to transcriber during composition
- [ ] Transcriber update triggers accumulation recomposition via compose-dependents
- [ ] Accumulation content reflects current transcript text
- [ ] Idempotent compose with hash termination
- [ ] All existing tests pass

### Phase 3: Visual Feedback and Mode Integration

**Goal:** Mic and transcription buttons indicate state via color. Textarea disabled during transcription. Mode switching wired to transcription toggle. Clarification works in both modes.

**Tests:**
- `test_compose_transcribing_textarea_readonly` — verify compose-transcribing render-spec has `readonly: true` on textarea
- `test_compose_full_textarea_editable` — verify compose-full render-spec has no `readonly` prop
- `test_mic_button_has_data_state` — verify compose-full render-spec mic button has `data-state` binding
- `test_transcription_button_has_data_segment` — verify render-spec transcription button has `data-segment` binding
- `test_clarify_works_in_manual_mode` — accumulation has content "hello" → invoke clarify-accumulation → content updates
- `test_clarify_works_after_transcription` — transcript composed to content → turn off transcription → invoke clarify-accumulation → content refined
- `test_commit_clears_transcript` — commit-phasis → accumulation content cleared AND transcriber.transcript cleared

**Implementation:**

1. Update `compose-transcribing` render-spec: add `readonly: true` to textarea widget
2. Update `compose-full` and `compose-transcribing` render-specs: add `data-state` and `data-segment` bindings to mic and transcription buttons
3. Add CSS variables and rules for button state colors to `app/src/styles.css`
4. Update frontend VoiceSignal handler to apply `voice-active` CSS class to mic button when voice_active is true
5. Add mode-switching reflex: when transcriber desired_state changes → switch between compose-full and compose-transcribing modes
6. Update `commit-phasis` praxis: after committing, also update `transcriber/default` to clear transcript field (reset for next utterance cycle)
7. Update `clarify-accumulation` praxis: ensure it reads and writes `content` directly (works regardless of composition mode — when transcription is off, content is directly editable)
8. Disable `clarify-on-transcript` reflex (automatic clarification is premature — manual button first)

**Phase 3 Complete When:**
- [ ] Textarea read-only during transcription, editable when off
- [ ] Mic button: gray (muted) / dark green (active) / light green (voice activity)
- [ ] Transcription button: gray (disabled) / dark green (active) / bright green (transcribing segment)
- [ ] Mode switches automatically with transcription toggle
- [ ] Clarification works in both modes
- [ ] commit-phasis clears both accumulation content and transcriber transcript
- [ ] Full E2E: voice → transcriber entity → composition → accumulation.content → textarea
- [ ] All existing tests pass

---

## Files to Read

### Voice substrate
- `crates/kosmos/src/voice.rs` — `sense_transcription()`, `TranscriptionSession`, transcript buffer, `run_inference_loop()`
- `genesis/soma/eide/voice.yaml` — transcriber eidos fields
- `genesis/soma/entities/voice-defaults.yaml` — default transcriber entity

### Composition infrastructure
- `crates/kosmos/src/interpreter/steps.rs` — `compose_entity()`, `resolve_slot()`, `_composition_inputs`, depends-on bond creation
- `genesis/demiurge/reflexes/composition.yaml` — compose-dependents reflex
- `genesis/demiurge/praxeis/composition.yaml` — compose-dependents praxis

### Accumulation
- `genesis/thyra/typos/thyra.yaml` — `typos-def-accumulation` (currently a shell)
- `genesis/thyra/eide/thyra.yaml` — accumulation eidos fields
- `genesis/thyra/entities/default-accumulation.yaml` — default accumulation with bonds
- `genesis/thyra/praxeis/thyra.yaml` — accumulation praxeis (append-utterance, clarify, commit)

### Render-specs and modes
- `genesis/thyra/render-specs/compose-full.yaml` — current compose bar render-spec
- `genesis/thyra/render-specs/compose-transcribing.yaml` — transcription mode render-spec
- `genesis/thyra/modes/screen.yaml` — compose-full and compose-transcribing mode entities

### Reactive system
- `genesis/thyra/reflexes/clarify-on-transcript.yaml` — clarify reflex (premature, to be disabled)
- `genesis/soma/reflexes/transcription.yaml` — transcriber autonomic triple
- `crates/kosmos/src/host.rs` — `apply_entity_update()`, `dispatch_to_module()`
- `crates/kosmos-mcp/src/http.rs` — VoiceSignal broadcast timer

### Frontend
- `app/src/styles.css` — CSS for compose bar
- `app/src/App.tsx` — WebSocket event handling

---

## Files to Touch

| File | Change |
|------|--------|
| `genesis/soma/eide/voice.yaml` | **MODIFY** — add `transcript` field to eidos/transcriber |
| `genesis/soma/entities/voice-defaults.yaml` | **MODIFY** — add `transcript: ""` default |
| `crates/kosmos/src/voice.rs` | **MODIFY** — `sense_transcription()` includes transcript in `_entity_update`; `stop_transcription()` clears transcript |
| `genesis/thyra/typos/thyra.yaml` | **MODIFY** — enhance `typos-def-accumulation` with queried transcript slot |
| `genesis/thyra/eide/thyra.yaml` | **REVIEW** — accumulation eidos may not need new fields (content suffices) |
| `genesis/thyra/entities/default-accumulation.yaml` | **REVIEW** — may need `transcript: ""` if slot requires it at entity level |
| `crates/kosmos/src/interpreter/steps.rs` | **MODIFY** — implement bond-based queried slot resolution if not present |
| `genesis/thyra/praxeis/thyra.yaml` | **MODIFY** — remove `append-utterance` and `append-fragment`; update `commit-phasis` to clear transcriber transcript |
| `genesis/thyra/render-specs/compose-transcribing.yaml` | **MODIFY** — add `readonly: true` to textarea |
| `genesis/thyra/render-specs/compose-full.yaml` | **MODIFY** — add `data-state` and `data-segment` bindings to buttons |
| `genesis/thyra/reflexes/clarify-on-transcript.yaml` | **MODIFY** — disable (set enabled: false) |
| `app/src/styles.css` | **MODIFY** — add button state color CSS variables and rules |
| `crates/kosmos/tests/conversational_composition.rs` | **NEW** — test suite for the full pipeline |

---

## Success Criteria

**Phase 1:**
- [x] `transcriber/default.data.transcript` holds transcribed text after sense
- [x] Transcript accumulates across sense cycles (append, not replace)
- [x] Transcript cleared on session stop

**Phase 2:**
- [x] `typos-def-accumulation` has queried slot resolving transcript from bonded transcriber
- [x] Bond-based slot resolution implemented and working
- [x] `depends-on` bond created from accumulation to transcriber during composition
- [x] Transcriber update triggers accumulation recomposition
- [x] Accumulation content reflects current transcript text
- [x] `append-utterance` and `append-fragment` removed (composition replaces them)

**Phase 3:**
- [x] Textarea read-only during transcription
- [x] Button colors indicate muted/active/voice-activity/transcribing states
- [ ] Mode switches with transcription toggle
- [x] Clarification works in both modes
- [x] commit-phasis clears both accumulation and transcriber transcript
- [x] Full E2E: voice → entity → composition → textarea

**Overall Complete When:**
- [x] All existing tests pass
- [x] New test suite passes (18 tests)
- [x] Transcript text visible in compose bar textarea after speaking
- [x] The pattern is established: content enters kosmos through graph-mediated composition

---

## What This Enables

**Conversational entity creation.** With the composition pipeline established, the compose bar becomes the universal creation surface. Speak → transcript appears → clarify → commit → entities arise. Because kosmos is homoiconic, "entities arise" means anything: new eide, new thyra modes, new actualization modes, new render-specs. The compose bar is the development environment.

**Phasis as entity genesis (Phasis IV — future prompt).** When accumulation commits, the content is interpreted as entity declarations via governed generation. The committed phasis doesn't just become a message — it becomes graph structure. The composition pipeline established here is the input channel for that genesis.

**Modality-agnostic input.** The typos slot pattern is extensible. Future input modalities (paste, drag-and-drop, API integration, camera OCR) become additional queried slots on additional bonded entities — same composition pattern, same graph mediation.

**Automatic clarification (future).** The `clarify-on-transcript` reflex is disabled but defined. When the manual clarification pattern is proven, re-enabling automatic clarification adds an autonomous refinement loop — transcript arrives → auto-clarify → polished content appears. Same architecture, just an enabled reflex away.

---

## What Does NOT Change

- **Existing reconciliation** (intent-vs-actuality for audio-source, transcriber) — untouched. Lifecycle reconciliation is a separate loop.
- **Voice pipeline** (cpal, VAD, whisper inference) — untouched. Only the sense boundary changes (transcript text enters `_entity_update`).
- **Render-spec binding syntax** — `{content}` in compose-full.yaml continues to bind to `accumulation.data.content`. The textarea doesn't know or care that content is now composed.
- **Signal broadcast** (VoiceSignal WebSocket events at 10Hz) — untouched. Ephemeral signals remain separate from entity state.
- **Bootstrap** — untouched. Composition reconciliation operates at runtime.
- **Frontend interpreter** — untouched. No new widget types. `readonly` and `data-*` props are standard HTML attributes passthrough. `voice-active` CSS class applied by existing signal handler.
- **clarify-accumulation praxis** — stays. Works by reading and writing content directly. In manual mode this is direct edit; in transcription mode it overwrites composed content (OK because transcription should be off when clarifying).

---

*Traces to: KOSMOGONIA (The Composition Requirement, The Composition Triad), T3 (three pillars as one practice), T4 (four reconciliation loops — composition reconciliation), T7 (rendering is graph-traversable), T8 (mode is topos presence — mode switching replaces conditionals), Compose Bar Design Dialogue (bond traversal is the one right way, button-driven intent), Voice Activity Sensing/Being distinction.*
