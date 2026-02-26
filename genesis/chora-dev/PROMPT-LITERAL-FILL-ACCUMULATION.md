# Literal-Fill Accumulation — Three Sources, One Pattern

*Prompt for Claude Code in the chora + kosmos repository context.*

*After this work, the accumulation entity receives content from three sources — voice transcription, manual editing, and LLM clarification — all through the same literal-fill composition pattern. The transcriber's transcript field is a temporary sense buffer that gets flushed to the accumulation. Mode switching is reflex-driven. No `depends-on` bond exists between accumulation and transcriber.*

---

## Architectural Principle — Mutable Composition

Composition is one-way and deterministic: definition + inputs → output. But the compose bar needs content from multiple sources — voice, keyboard, LLM. The naive approach breaks composition (make content directly mutable) or forces a single source (bond-based queried slot from transcriber).

The resolution: **literal-fill via praxis**. The typos slot is `fill: literal`. The actual value comes from `_composition_inputs.inputs.content`. Praxeis update this literal input and invoke re-composition. Composition stays deterministic; content is mutable through the input.

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

This preserves T4's composition reconciliation loop while enabling the bidirectional content flow the compose bar requires.

---

## Methodology — DDD + TDD

This work follows **Doc → Test → Build → Verify**, non-negotiably.

1. **Doc (prescriptive)**: This prompt IS the prescriptive doc. The six reference docs have already been updated to prescribe this target state (voice-authoring, phasis-workspace, typos-composition, VOICE-OIKOS-DESIGN, composition, clarification-as-composition).
2. **Test (assert the doc)**: Write tests that assert the target state. Tests should fail before implementation.
3. **Build (satisfy the tests)**: Implement until tests pass.
4. **Verify doc**: After implementation, update success criteria. Check docs/REGISTRY.md impact map.

**Clean break from bond-based queried slot.** The `depends-on` bond and queried slot are removed, not deprecated. The flush reflex replaces the composition cascade. No backward compatibility shims.

---

## Current State

### What Exists and Works

| Component | Location | Status |
|-----------|----------|--------|
| `typos-def-accumulation` | `genesis/thyra/typos/thyra.yaml` | Working — queried slot via `fed-by-transcriber` bond |
| `accumulation/default` genesis | `genesis/thyra/entities/default-accumulation.yaml` | Working — has `_composition_inputs`, `depends-on` bond to transcriber |
| `compose-dependents` reflex | `genesis/demiurge/reflexes/composition.yaml` | Working — fires on any entity-mutation/updated |
| `thyra/commit-phasis` | `genesis/thyra/praxeis/thyra.yaml` | Working — clears transcriber transcript via bond traversal |
| `thyra/clarify-accumulation` | `genesis/thyra/praxeis/thyra.yaml` | Working — reads `$form.content`, runs clarification, updates entity |
| Voice capture pipeline | `crates/kosmos/src/voice.rs` | Working — cpal+VAD+whisper-rs, sense daemon appends to transcript |
| Compose bar modes | `genesis/thyra/modes/screen.yaml` | Working — compose-full, compose-transcribing, compose-minimal |
| Entity caching (flicker fix) | `app/src/lib/layout-engine.tsx`, `app/src/lib/render-spec.tsx` | Working — cached signals prevent flicker |
| Button data-* passthrough | `app/src/lib/widgets/button.tsx` | Working — splitProps + spread |
| Voice signal DOM bridge | `app/src/lib/layout-engine.tsx` | Working — toggles voice-active class |

### What's Missing — The Gaps

1. **Literal fill slot**: `typos-def-accumulation` uses `fill: queried` with bond-based query. Needs `fill: literal` with `default: ""`.
2. **`depends-on` bond removal**: Accumulation still has `depends-on` bond to transcriber, causing composition cascade on every transcript change. Should be removed.
3. **Flush transcript praxis**: No `thyra/flush-transcript` exists. Need praxis that reads transcriber.transcript, appends to literal input, clears buffer, composes.
4. **Content sync praxis**: No `thyra/sync-compose-content` exists. Need praxis that reads `$form.content` from DOM, writes to literal input, composes.
5. **Flush reflex**: No reflex triggers flush when transcriber.transcript changes.
6. **Clarify reads literal input**: `thyra/clarify-accumulation` currently reads `$form.content`. Should read `_composition_inputs.inputs.content`.
7. **Mode switch reflex**: No reflex switches between compose-full and compose-transcribing when transcriber.desired_state transitions.
8. **Content sync before mode switch**: No mechanism syncs DOM content to literal input before switching modes.

---

## Target State

### typos-def-accumulation (literal fill)

```yaml
- eidos: typos
  id: typos-def-accumulation
  data:
    name: accumulation
    description: "Accumulation entity — literal fill from praxis-updated inputs"
    target_eidos: accumulation
    slots:
      content:
        fill: literal
        default: ""
    template: "{{ content }}"
```

### accumulation/default genesis (no depends-on)

```yaml
- eidos: accumulation
  id: accumulation/default
  data:
    content: ""
    status: active
    started_at: "2026-02-06T00:00:00Z"
    _composition_inputs:
      typos_id: typos-def-accumulation
      inputs:
        content: ""
  bonds:
    - desmos: fed-by-audio
      to: audio-source/default
    - desmos: fed-by-transcriber
      to: transcriber/default
```

Note: `depends-on` bond removed. `fed-by-audio` and `fed-by-transcriber` bonds remain for render-spec bindings.

### New praxeis

```yaml
# thyra/flush-transcript — reflex-driven voice content flush
- eidos: praxis
  id: praxis/thyra/flush-transcript
  data:
    name: flush-transcript
    description: "Flush transcriber transcript to accumulation literal input"
    steps:
      # 1. Find the accumulation entity
      - step: set
        name: accumulation_id
        value: "accumulation/default"
      - step: find
        id: "$accumulation_id"
        bind_to: accumulation
      # 2. Trace fed-by-transcriber bond to get transcriber
      - step: trace
        from: "$accumulation_id"
        desmos: fed-by-transcriber
        bind_to: transcriber_bonds
      - step: find
        id: "$transcriber_bonds.0.to_id"
        bind_to: transcriber
      # 3. Read transcript, bail if empty
      - step: set
        name: transcript
        value: "$transcriber.data.transcript"
      # 4. Get existing content from composition inputs
      - step: set
        name: existing_content
        value: "$accumulation.data._composition_inputs.inputs.content"
      # 5. Append transcript to existing content (with space separator if both non-empty)
      - step: set
        name: new_content
        value: "$existing_content $transcript"
      # 6. Update accumulation's _composition_inputs.inputs.content
      - step: call
        praxis: demiurge/compose
        params:
          entity_id: "$accumulation_id"
          inputs:
            content: "$new_content"
      # 7. Clear transcriber transcript
      - step: update
        entity_id: "$transcriber_bonds.0.to_id"
        data:
          transcript: ""
```

```yaml
# thyra/sync-compose-content — sync DOM content to literal input
- eidos: praxis
  id: praxis/thyra/sync-compose-content
  data:
    name: sync-compose-content
    description: "Sync textarea content to accumulation literal composition input"
    params:
      content:
        type: string
        description: "Current textarea content (from $form.content)"
        required: true
    steps:
      - step: call
        praxis: demiurge/compose
        params:
          entity_id: "accumulation/default"
          inputs:
            content: "$params.content"
```

### New reflexes

```yaml
# Flush transcript reflex — fires when transcriber.transcript changes
- eidos: trigger
  id: trigger/thyra/flush-transcript
  data:
    name: flush-transcript
    enabled: true
    event: entity-mutation/updated
    matches:
      eidos: transcriber
    condition: "$entity.data.transcript != '' && $entity.data.desired_state == 'active'"

- eidos: reflex
  id: reflex/thyra/flush-transcript
  data:
    name: flush-transcript
    enabled: true
    responds_with:
      praxis: praxis/thyra/flush-transcript
  bonds:
    - desmos: triggered-by
      to: trigger/thyra/flush-transcript
```

```yaml
# Mode switch reflex — fires when transcriber.desired_state transitions
- eidos: trigger
  id: trigger/thyra/transcriber-mode-switch
  data:
    name: transcriber-mode-switch
    enabled: true
    event: entity-mutation/updated
    matches:
      eidos: transcriber
    condition: "$mutation.changed_fields.desired_state"

- eidos: reflex
  id: reflex/thyra/transcriber-mode-switch
  data:
    name: transcriber-mode-switch
    enabled: true
    responds_with:
      praxis: praxis/thyra/switch-compose-mode
      params:
        transcriber_desired_state: "$entity.data.desired_state"
  bonds:
    - desmos: triggered-by
      to: trigger/thyra/transcriber-mode-switch
```

### Updated praxis: clarify-accumulation

```yaml
# Updated: reads from literal input, writes back to literal input
- step: find
  id: "accumulation/default"
  bind_to: accumulation
- step: set
  name: current_content
  value: "$accumulation.data._composition_inputs.inputs.content"
- step: call
  praxis: demiurge/compose
  params:
    typos_id: typos/clarify-phasis
    inputs:
      raw_content: "$current_content"
  bind_to: clarification_result
# Write clarified content back to literal input
- step: call
  praxis: demiurge/compose
  params:
    entity_id: "accumulation/default"
    inputs:
      content: "$clarification_result.clarification.content"
# Update stance if detected
- step: update
  entity_id: "accumulation/default"
  data:
    stance: "$clarification_result.clarification.stance"
```

### New praxis: switch-compose-mode

```yaml
- eidos: praxis
  id: praxis/thyra/switch-compose-mode
  data:
    name: switch-compose-mode
    description: "Switch compose bar mode based on transcriber state"
    params:
      transcriber_desired_state:
        type: string
        required: true
    steps:
      - step: switch
        on: "$params.transcriber_desired_state"
        cases:
          - when: "active"
            then:
              - step: call
                praxis: thyra/switch-mode
                params:
                  from: "mode/compose-full"
                  to: "mode/compose-transcribing"
          - when: "closed"
            then:
              - step: call
                praxis: thyra/switch-mode
                params:
                  from: "mode/compose-transcribing"
                  to: "mode/compose-full"
```

---

## Sequenced Work

### Phase 1: The Accumulation Receives (Literal Fill)

**Goal:** Change the accumulation's composition from bond-based queried to literal fill. Remove the `depends-on` bond.

**Tests:**
- `test_typos_def_accumulation_literal_fill` — assert slot is `fill: literal` with `default: ""`
- `test_accumulation_default_no_depends_on` — assert no `depends-on` bond to transcriber
- `test_accumulation_compose_with_literal_input` — compose with `inputs: { content: "hello" }`, verify `entity.data.content == "hello"`
- `test_accumulation_compose_empty_default` — compose with empty inputs, verify `entity.data.content == ""`
- `test_accumulation_recompose_updates_content` — compose twice with different content, verify content changes

**Implementation:**
1. Update `genesis/thyra/typos/thyra.yaml`: change `typos-def-accumulation` slot from `fill: queried` to `fill: literal`
2. Update `genesis/thyra/entities/default-accumulation.yaml`: remove `depends-on` bond, set `_composition_inputs.inputs.content: ""`
3. Verify bootstrap loads correctly with `just dev`

**Phase 1 Complete When:**
- [x] `typos-def-accumulation` has `fill: literal` slot with `default: ""`
- [x] `accumulation/default` has no `depends-on` bond to transcriber
- [x] `_composition_inputs.inputs.content` is `""` in genesis
- [x] Composition with literal input produces correct content
- [x] All existing tests still pass

### Phase 2: Three Sources, One Pattern

**Goal:** Create the three content praxeis and the flush reflex.

**Tests:**
- `test_flush_transcript_appends_to_content` — set transcriber.transcript = "hello", invoke flush, verify accumulation content includes "hello" and transcriber.transcript is cleared
- `test_flush_transcript_empty_noop` — invoke flush with empty transcript, verify no change
- `test_sync_compose_content` — invoke sync with content "typed text", verify accumulation content updated
- `test_clarify_reads_literal_input` — set literal input to "um like hello", invoke clarify, verify content updated to clarified text
- `test_commit_clears_literal_input` — set literal input, commit, verify `_composition_inputs.inputs.content` is ""
- `test_flush_reflex_fires_on_transcript_change` — update transcriber.transcript, verify flush praxis was invoked

**Implementation:**
1. Add `praxis/thyra/flush-transcript` to `genesis/thyra/praxeis/thyra.yaml`
2. Add `praxis/thyra/sync-compose-content` to `genesis/thyra/praxeis/thyra.yaml`
3. Add flush reflex (trigger + reflex) to `genesis/thyra/reflexes/` (new file: `flush-transcript.yaml`)
4. Update `praxis/thyra/clarify-accumulation` to read from `_composition_inputs.inputs.content` instead of `$form.content`
5. Update `praxis/thyra/commit-phasis` to clear `_composition_inputs.inputs.content`

**Phase 2 Complete When:**
- [x] `thyra/flush-transcript` reads transcript, appends to literal input, clears buffer, composes
- [x] `thyra/sync-compose-content` writes content to literal input and composes
- [x] `thyra/clarify-accumulation` reads from literal input and writes back
- [x] `thyra/commit-phasis` clears literal input and transcriber transcript
- [x] Flush reflex fires when transcriber.transcript changes while desired_state is active
- [x] All tests pass

### Phase 3: Mode Follows Transcriber

**Goal:** Reflex-driven mode switching when transcriber toggles. Content synced before each switch.

**Tests:**
- `test_mode_switch_to_transcribing` — set transcriber.desired_state to active, verify active mode switches from compose-full to compose-transcribing
- `test_mode_switch_to_full` — set transcriber.desired_state to closed, verify active mode switches from compose-transcribing to compose-full
- `test_content_synced_before_mode_switch` — verify sync-compose-content is called before mode switch

**Implementation:**
1. Add `praxis/thyra/switch-compose-mode` to `genesis/thyra/praxeis/thyra.yaml`
2. Add mode switch reflex (trigger + reflex) to `genesis/thyra/reflexes/` (new file: `compose-mode-switch.yaml`)
3. Ensure `switch-compose-mode` calls `sync-compose-content` before switching modes (content preservation)

**Phase 3 Complete When:**
- [x] Mode switches from compose-full to compose-transcribing when transcriber.desired_state → active
- [x] Mode switches from compose-transcribing to compose-full when transcriber.desired_state → closed
- [x] DOM content is synced to literal input before mode switch
- [x] All tests pass

---

## Files to Read

### Composition
- `crates/kosmos/src/interpreter/steps.rs` — compose step, `_composition_inputs` handling, re-compose path
- `crates/kosmos/src/interpreter/schema.rs` — slot resolution, literal fill handling
- `genesis/demiurge/reflexes/composition.yaml` — compose-dependents reflex (still exists, just won't fire for accumulation)

### Genesis
- `genesis/thyra/typos/thyra.yaml` — typos-def-accumulation (to modify)
- `genesis/thyra/entities/default-accumulation.yaml` — accumulation entity (to modify)
- `genesis/thyra/praxeis/thyra.yaml` — commit-phasis, clarify-accumulation (to modify)
- `genesis/soma/praxeis/voice.yaml` — toggle praxeis (reference)
- `genesis/thyra/modes/screen.yaml` — compose modes (reference)

### Tests
- `crates/kosmos/tests/conversational_composition.rs` — existing tests to update
- `crates/kosmos/tests/composition_reconciliation.rs` — composition cascade tests (reference)

### Frontend
- `app/src/lib/layout-engine.tsx` — entity-bound mode renderer, voice signal bridge
- `app/src/lib/render-spec.tsx` — bond context, binding resolution

---

## Files to Touch

| File | Change |
|------|--------|
| `genesis/thyra/typos/thyra.yaml` | **MODIFY** — change typos-def-accumulation slot from queried to literal |
| `genesis/thyra/entities/default-accumulation.yaml` | **MODIFY** — remove depends-on bond, add content to inputs |
| `genesis/thyra/praxeis/thyra.yaml` | **MODIFY** — add flush-transcript, sync-compose-content, switch-compose-mode; update clarify-accumulation and commit-phasis |
| `genesis/thyra/reflexes/flush-transcript.yaml` | **NEW** — trigger + reflex for transcript flush |
| `genesis/thyra/reflexes/compose-mode-switch.yaml` | **NEW** — trigger + reflex for mode switching |
| `crates/kosmos/tests/conversational_composition.rs` | **MODIFY** — update tests for literal fill pattern |
| `crates/kosmos/tests/literal_fill_accumulation.rs` | **NEW** — tests for the new pattern |

---

## Success Criteria

### Phase 1: Literal Fill
- [x] Updated docs to prescribe new target state (6 docs)
- [x] `typos-def-accumulation` has `fill: literal` slot
- [x] No `depends-on` bond from accumulation to transcriber
- [x] Composition with literal input produces correct content
- [x] All existing tests still pass

### Phase 2: Three Sources
- [x] `thyra/flush-transcript` works end-to-end
- [x] `thyra/sync-compose-content` works end-to-end
- [x] `thyra/clarify-accumulation` reads/writes literal input
- [x] `thyra/commit-phasis` clears literal input
- [x] Flush reflex fires on transcript change
- [x] All new tests pass

### Phase 3: Mode Switching
- [x] Mode switches reflex-driven on transcriber.desired_state transition
- [x] Content synced before mode switch
- [x] All tests pass

**Overall Complete When:**
- [x] All existing tests still pass
- [x] 10+ new tests cover the literal-fill pattern, flush, sync, clarify, commit, mode switch (20 literal_fill + 18 conversational_composition = 38 total)
- [x] Voice → accumulation → commit → phasis pipeline works end-to-end
- [x] Manual editing → commit works end-to-end
- [x] Clarification reads from and writes to literal input
- [x] Mode switching happens automatically on transcriber toggle

---

## What This Enables

- **Seamless voice/text interleaving**: Turn transcription on and off freely without losing content. Both sources contribute to the same content buffer.
- **Clarification in place**: LLM clarification transforms the content buffer directly. No separate pipeline for clarified vs unclarified content.
- **Future content sources**: Any praxis can update `_composition_inputs.inputs.content` — paste, import, AI generation — all through the same path.
- **Composition coherence**: Composition remains one-way and deterministic. The "mutability" is in the input, not in the composition itself.

---

## What Does NOT Change

- **Voice capture pipeline** (cpal, VAD, whisper-rs, sense daemon) — unchanged
- **Render-specs** (compose-full, compose-transcribing, compose-minimal) — unchanged
- **Widget tree** (button, textarea, form bindings) — unchanged
- **Bond traversal in render-specs** (`@fed-by-audio`, `@fed-by-transcriber`) — unchanged
- **Voice signal architecture** (atomics, WsEvent::VoiceSignal, 10Hz broadcast) — unchanged
- **Entity caching and flicker fixes** — unchanged
- **compose-dependents reflex** — still exists, just won't fire for accumulation (no depends-on bond)
- **Autonomic triple** for audio-source and transcriber — unchanged

---

*Traces to: PROMPT-CONVERSATIONAL-COMPOSITION.md (superseded), PROMPT-VOICE-ACTIVITY.md, T4 (composition reconciliation), T8 (mode is topos presence)*
