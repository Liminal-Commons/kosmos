# Voice & Stream Retirement — Clean Break Before Decomposition

*Prompt for Claude Code in the chora + kosmos repository context.*

*After this work, eidos/stream, mode/voice, and all voice pipeline entities are deleted. The accumulation eidos is cleaned of voice-specific fields. No stream praxeis exist. No voice stoicheion dispatch exists. The codebase is a clean slate for the voice decomposition work (PROMPT-VOICE-DECOMPOSITION.md). This prompt is pure deletion — no new features.*

---

## Architectural Principle — Dead Code Is Contextual Poison

eidos/stream was designed as "bounded media flow" — a generic abstraction for voice, video, text, and document flows. In practice, no concrete use case needs it:

- Voice capture → decomposed into mode/audio-capture + mode/transcription (separate modes, no stream entity)
- WebRTC → already has syndesmos entities and livekit mode (its own lifecycle)
- Text input → keyboard doesn't need a stream entity
- Document flow → never materialized

The monolithic mode/voice conflates audio capture, transcription, composition, and commitment into one mode. It must be removed before the decomposed modes can be built on clean ground.

The voice-pipeline-config, stream desmoi, stream render-spec, stream reflexes, stream praxeis, and all voice-specific fields on accumulation are all part of the same dead web. Removing them piecemeal would leave references that confuse future sessions.

**Clean break. No backward compatibility. Delete everything that doesn't fit the target ontology.**

---

## Methodology — DDD + TDD

This work follows **Doc → Test → Build → Verify**, non-negotiably.

1. **Doc (prescriptive)**: This prompt IS the prescriptive doc. After this work, nothing in the deletion list exists.
2. **Test (assert the doc)**: Write a test that asserts stream/voice entities do NOT exist after bootstrap.
3. **Build (satisfy the tests)**: Delete everything on the list.
4. **Verify doc**: After deletion, all remaining tests pass. Bootstrap succeeds.

**Pure deletion, no backward compatibility.** No deprecated wrappers, no "// removed" comments, no re-exports of deleted items.

---

## Current State

### What Exists (and shouldn't)

**Entities (eide, typos, desmoi, render-specs, modes):**

| Entity | File | Why It Goes |
|--------|------|-------------|
| `eidos/stream` | thyra/eide/thyra.yaml | No use case needs a generic "stream" entity |
| `eidos/voice-pipeline-config` | thyra/eide/thyra.yaml | Monolithic config — decomposed modes will own their own config |
| `typos-def-stream` | thyra/typos/thyra.yaml | Composes an entity type that no longer exists |
| `typos-def-voice-pipeline-config` | thyra/typos/thyra.yaml | Same |
| `typos-def-default-voice-config` | thyra/typos/thyra.yaml | Same (default instance of deleted eidos) |
| `desmos/transforms-to` (stream→stream) | thyra/desmoi/thyra.yaml | Stream-specific relationship |
| `desmos/produces` (daemon→stream) | thyra/desmoi/thyra.yaml | Stream-specific relationship |
| `desmos/consumes` (daemon→stream) | thyra/desmoi/thyra.yaml | Stream-specific relationship |
| `desmos/active-voice-config` (parousia→voice-pipeline-config) | thyra/desmoi/thyra.yaml | References deleted eidos |
| `render-spec/stream-card` | thyra/render-specs/stream-card.yaml | Renders deleted eidos |
| `render-spec/voice-bar` | thyra/render-specs/voice-bar.yaml | References deleted accumulation fields (capture_state, clarification_status) |
| `mode/voice-composing` | thyra/modes/screen.yaml | `requires: [mode/voice]` — depends on deleted mode |

**Reactive layer (reflexes, reconcilers, daemons):**

| Entity | File | Why It Goes |
|--------|------|-------------|
| `trigger/thyra/stream-drift` | thyra/reflexes/stream-drift.yaml | Watches deleted eidos |
| `reflex/thyra/stream-drift` | thyra/reflexes/stream-drift.yaml | Responds to deleted trigger |
| `trigger/soma/voice-stream-intent-change` | soma/reflexes/voice.yaml | Watches deleted eidos (on accumulation, which loses these fields) |
| `trigger/soma/voice-stream-drift` | soma/reflexes/voice.yaml | Same |
| `reflex/soma/reconcile-voice-on-intent` | soma/reflexes/voice.yaml | References deleted reconciler |
| `reflex/soma/reconcile-voice-on-drift` | soma/reflexes/voice.yaml | Same |
| `reconciler/voice-stream` | soma/reconcilers/voice.yaml | Targets deleted eidos concept |
| `daemon/sense-voice-streams` (soma) | soma/daemons/voice.yaml | References nonexistent praxis |
| Thyra daemon entry for sense-stream-states | thyra/daemons/daemons.yaml | References deleted praxis |

**Praxeis (8 stream praxeis):**

| Praxis | File | Why It Goes |
|--------|------|-------------|
| `thyra/open-stream` | thyra/praxeis/thyra.yaml | Creates deleted eidos |
| `thyra/close-stream` | thyra/praxeis/thyra.yaml | Modifies deleted eidos |
| `thyra/sense-stream` | thyra/praxeis/thyra.yaml | Queries deleted eidos |
| `thyra/reconcile-stream` | thyra/praxeis/thyra.yaml | Reconciles deleted eidos |
| `thyra/list-streams` | thyra/praxeis/thyra.yaml | Lists deleted eidos |
| `thyra/pause-stream` | thyra/praxeis/thyra.yaml | Modifies deleted eidos |
| `thyra/resume-stream` | thyra/praxeis/thyra.yaml | Modifies deleted eidos |
| `thyra/sense-stream-states` | thyra/praxeis/thyra.yaml | Senses deleted eidos |

**Dynamis mode:**

| Entity | File | Why It Goes |
|--------|------|-------------|
| `mode/voice` | soma/modes/voice.yaml | Monolithic — replaced by decomposed modes in follow-up |

**Rust code:**

| Component | File | Why It Goes |
|-----------|------|-------------|
| `voice.rs` module | crates/kosmos/src/voice.rs | Placeholder implementation of deleted mode |
| `pub mod voice` + re-exports | crates/kosmos/src/lib.rs | Module declaration for deleted file |
| `voice-start-stream` match arm | crates/kosmos/src/host.rs | Stoicheion for deleted mode |
| `voice-sense-stream` match arm | crates/kosmos/src/host.rs | Same |
| `voice-stop-stream` match arm | crates/kosmos/src/host.rs | Same |
| `voice_substrate.rs` tests | crates/kosmos/tests/voice_substrate.rs | Tests deleted module |

**TypeScript:**

| Component | File | Why It Goes |
|-----------|------|-------------|
| `capture.ts` | app/src/lib/voice/capture.ts | Registers handler for deleted mode |

### What Stays (modified)

| Component | File | Change |
|-----------|------|--------|
| `eidos/accumulation` | thyra/eide/thyra.yaml | Remove voice-specific fields |
| `eidos/utterance` | thyra/eide/thyra.yaml | Remove `stream_id` field |
| `eidos/phasis` | logos/eide/logos.yaml | Remove `source_stream_id` field |
| `typos-def-accumulation` | thyra/typos/thyra.yaml | Stays (targets cleaned eidos) |
| `typos-def-phasis` | logos/typos/logos.yaml | Stays |
| `accumulation/default` entity | thyra/entities/default-accumulation.yaml | Remove voice-specific field values |
| `attainment/perceive` | thyra/eide/thyra.yaml | Remove 7 stream praxis grants |
| `desmos/clarified-by` | thyra/desmoi/thyra.yaml | Stays (general concept, not stream-specific) |
| Thyra manifest | thyra/manifest.yaml | Remove stream eidos, voice-pipeline-config, 8 stream praxeis |
| Genesis surfaces | genesis/surfaces/surfaces.yaml | Remove open-stream, close-stream |
| Accumulation praxeis | thyra/praxeis/thyra.yaml | Remove stream_id references from begin-accumulation, commit-phasis, list-accumulations |
| `voice_capture.rs` | app/src-tauri/src/voice_capture.rs | **Stays untouched** — real implementation, port source for decomposition |
| `actuality.ts` | app/src/lib/actuality.ts | **Stays untouched** — other substrates may use it |

---

## Target State

After this work:

- **No stream entity type exists** in genesis
- **No voice mode exists** in genesis (neither dynamis mode/voice nor thyra mode/voice-composing)
- **No stream praxeis exist** in genesis
- **No voice reflexes, reconciler, or daemon exist** in genesis
- **No voice-bar or stream-card render-specs exist** in genesis
- **Accumulation is modality-agnostic**: content, status, stance, started_at, last_modified_at, committed_at, phasis_id — nothing else
- **Utterance has no stream_id** — will bond to accumulation when rebuilt
- **Phasis has no source_stream_id** — provenance will come from utterance bonds when rebuilt
- **No voice.rs module** exists in kosmos crate
- **No voice stoicheion dispatch** exists in host.rs
- **No voice tests** reference deleted module
- **mode_dispatch.rs regenerates** without ("voice", "local") entries
- **Bootstrap succeeds** with all remaining entities
- **All remaining tests pass**

### Cleaned Accumulation Eidos

```yaml
- eidos: eidos
  id: eidos/accumulation
  data:
    name: accumulation
    description: "Composition buffer — text being prepared for commitment. Modality-agnostic: receives text from voice, keyboard, paste, or any source."
    fields:
      content:
        type: string
        required: true
        description: "Current composed text — ready for edit/commit"
      status:
        type: enum
        values: [active, committed, abandoned, cleared]
        required: true
        default: active
      stance:
        type: enum
        values: [declaration, inquiry, suggestion, request, proposal]
        required: true
        default: declaration
        description: "Phasis stance for commit"
      started_at:
        type: timestamp
        required: true
      last_modified_at:
        type: timestamp
        required: false
      committed_at:
        type: timestamp
        required: false
      phasis_id:
        type: string
        required: false
        description: "Phasis ID if committed"
```

### Cleaned Default Accumulation Entity

```yaml
- eidos: accumulation
  id: accumulation/default
  data:
    content: ""
    status: active
    stance: declaration
    started_at: "2026-02-06T00:00:00Z"
```

### Cleaned Attainment/Perceive

Remove all 7 `grants-praxis` bonds to stream praxeis. Keep all accumulation praxis grants.

---

## Sequenced Work

### Phase 1: Genesis Deletion

**Goal:** Delete all stream and voice entities, clean accumulation and utterance eide, clean all references.

**Tests:**
- `test_no_stream_eidos` — eidos/stream does NOT exist after bootstrap
- `test_no_voice_mode` — mode/voice does NOT exist after bootstrap
- `test_accumulation_has_no_stream_fields` — accumulation eidos has exactly 7 fields (content, status, stance, started_at, last_modified_at, committed_at, phasis_id)

**Implementation:**

Delete entire files:
1. `genesis/thyra/render-specs/stream-card.yaml` — DELETE
2. `genesis/thyra/render-specs/voice-bar.yaml` — DELETE
3. `genesis/thyra/reflexes/stream-drift.yaml` — DELETE
4. `genesis/soma/reflexes/voice.yaml` — DELETE
5. `genesis/soma/reconcilers/voice.yaml` — DELETE
6. `genesis/soma/daemons/voice.yaml` — DELETE
7. `genesis/soma/modes/voice.yaml` — DELETE

Modify `genesis/thyra/eide/thyra.yaml`:
7. DELETE eidos/stream (entire entity block)
8. DELETE eidos/voice-pipeline-config (entire entity block)
9. CLEAN eidos/accumulation — remove fields: stream_id, raw_content, raw_fragments, clarification_status, clarification_generation_id, capture_state, last_fragment_at. Update description.
10. CLEAN eidos/utterance — remove stream_id field
11. CLEAN attainment/perceive — remove 7 grants-praxis bonds to stream praxeis (open-stream, close-stream, sense-stream, reconcile-stream, list-streams, pause-stream, resume-stream)

Modify `genesis/thyra/typos/thyra.yaml`:
12. DELETE typos-def-stream
13. DELETE typos-def-voice-pipeline-config
14. DELETE typos-def-default-voice-config
15. UPDATE section header comment (remove VOICE PIPELINE + STREAMS headers, clean up)

Modify `genesis/thyra/desmoi/thyra.yaml`:
16. DELETE desmos/transforms-to
17. DELETE desmos/produces
18. DELETE desmos/consumes
19. DELETE desmos/active-voice-config

Modify `genesis/thyra/modes/screen.yaml`:
20. DELETE mode/voice-composing entity block (lines 88-101)
21. DELETE 2 bonds referencing mode/voice-composing (uses-render-spec → voice-bar, requires-mode → mode/voice)

Modify `genesis/thyra/desmoi/mode.yaml`:
22. UPDATE desmos/requires-mode description — remove voice-composing example (desmos itself stays as a general concept)

Modify `genesis/thyra/praxeis/thyra.yaml`:
23. DELETE 8 stream praxeis: open-stream, close-stream, sense-stream, reconcile-stream, list-streams, pause-stream, resume-stream, sense-stream-states
24. CLEAN accumulation praxeis that reference stream_id:
    - begin-accumulation: remove stream creation, remove stream_id from composed accumulation
    - commit-phasis: remove source_stream_id reference
    - list-accumulations: remove stream_id filter option
25. UPDATE switch-mode description — remove voice-composing reference

Modify `genesis/thyra/daemons/daemons.yaml`:
26. DELETE daemon entry referencing thyra/sense-stream-states

Modify `genesis/thyra/manifest.yaml`:
27. Remove `stream` from eidos list
28. Remove `voice-pipeline-config` from eidos list
29. Remove all 8 stream praxis names from praxis list
30. Remove `sense-stream-states` from daemon praxis list (if listed separately)

Modify `genesis/thyra/entities/default-accumulation.yaml`:
31. Clean accumulation/default — remove stream_id, raw_content, raw_fragments, clarification_status, capture_state

Modify `genesis/logos/eide/logos.yaml`:
32. Remove `source_stream_id` field from eidos/phasis

Modify `genesis/genesis/surfaces/surfaces.yaml`:
33. Remove praxis/thyra/open-stream and praxis/thyra/close-stream from essential praxeis list

**Phase 1 Complete When:**
- [ ] 7 genesis files deleted entirely
- [ ] All stream/voice references removed from remaining genesis files
- [ ] mode/voice-composing removed from screen.yaml
- [ ] accumulation eidos has exactly 7 fields
- [ ] Bootstrap succeeds: `cargo test -p kosmos --lib`

### Phase 2: Rust & TypeScript Deletion

**Goal:** Delete voice.rs, voice stoicheion dispatch, voice tests, and TypeScript voice handler.

**Tests:**
- Existing tests must still pass after deletion (voice_substrate.rs tests are deleted alongside)
- `test_no_voice_dispatch` — stoicheion_for_mode("voice", "local", Manifest) returns None

**Implementation:**

1. DELETE `crates/kosmos/src/voice.rs`
2. MODIFY `crates/kosmos/src/lib.rs` — remove `pub mod voice;` and `pub use voice::{VoiceSubstrate, push_transcript_fragment};`
3. MODIFY `crates/kosmos/src/host.rs` — remove 3 match arms:
   - `"voice-start-stream" => self.dispatch_to_module(...)` (manifest)
   - `"voice-sense-stream" => self.dispatch_to_module(...)` (sense)
   - `"voice-stop-stream" => self.dispatch_to_module(...)` (unmanifest)
4. DELETE `crates/kosmos/tests/voice_substrate.rs`
5. DELETE `app/src/lib/voice/capture.ts`
6. DELETE `app/src/lib/voice/` directory (if empty after capture.ts removal)
7. Verify build: `cargo build -p kosmos` (mode_dispatch.rs regenerates without voice entries)

**Phase 2 Complete When:**
- [ ] voice.rs deleted
- [ ] No voice references in lib.rs
- [ ] No voice stoicheion match arms in host.rs
- [ ] voice_substrate.rs tests deleted
- [ ] capture.ts deleted
- [ ] `cargo build -p kosmos` succeeds
- [ ] mode_dispatch.rs regenerated without ("voice", "local") entries

### Phase 3: Verification

**Goal:** Confirm clean slate — bootstrap loads, all remaining tests pass, no dangling references.

**Implementation:**
1. Run `cargo test -p kosmos --lib --tests` — all remaining tests pass
2. Grep entire codebase for "eidos/stream", "mode/voice", "voice-start-stream", "typos-def-stream", "voice-composing", "voice-bar" — zero results in non-archive files
3. Verify mode_dispatch.rs has 13 modes (was 14 — voice removed)
4. Verify bootstrap loads all remaining entities without errors

**Phase 3 Complete When:**
- [ ] All remaining tests pass
- [ ] Zero references to deleted entities in live code/genesis
- [ ] mode_dispatch.rs has 13 registered modes
- [ ] Bootstrap clean

---

## Files to Read

### Genesis (understand what to delete)
- `genesis/thyra/eide/thyra.yaml` — stream, accumulation, utterance, voice-pipeline-config eide + attainment/perceive
- `genesis/thyra/praxeis/thyra.yaml` — 8 stream praxeis + accumulation praxeis with stream_id refs + switch-mode comment
- `genesis/thyra/typos/thyra.yaml` — typos-def-stream, typos-def-voice-pipeline-config, typos-def-default-voice-config
- `genesis/thyra/desmoi/thyra.yaml` — 4 stream/voice desmoi
- `genesis/thyra/desmoi/mode.yaml` — desmos/requires-mode comment (voice-composing example)
- `genesis/thyra/modes/screen.yaml` — mode/voice-composing entity + 2 bonds
- `genesis/thyra/render-specs/stream-card.yaml` — stream render-spec
- `genesis/thyra/render-specs/voice-bar.yaml` — voice-bar render-spec (references deleted fields)
- `genesis/thyra/reflexes/stream-drift.yaml` — thyra stream reflexes
- `genesis/thyra/daemons/daemons.yaml` — thyra daemon for sense-stream-states
- `genesis/thyra/manifest.yaml` — eidos + praxis listings
- `genesis/thyra/entities/default-accumulation.yaml` — default accumulation
- `genesis/soma/modes/voice.yaml` — monolithic voice mode
- `genesis/soma/reflexes/voice.yaml` — soma voice reflexes
- `genesis/soma/reconcilers/voice.yaml` — voice reconciler
- `genesis/soma/daemons/voice.yaml` — soma voice daemon
- `genesis/logos/eide/logos.yaml` — phasis eidos (source_stream_id field)
- `genesis/genesis/surfaces/surfaces.yaml` — essential praxeis list

### Rust (understand what to delete)
- `crates/kosmos/src/voice.rs` — DELETE entirely
- `crates/kosmos/src/lib.rs` — mod declaration + re-exports
- `crates/kosmos/src/host.rs` — 3 stoicheion match arms
- `crates/kosmos/tests/voice_substrate.rs` — DELETE entirely

### TypeScript (understand what to delete)
- `app/src/lib/voice/capture.ts` — DELETE entirely

---

## Files to Touch

| File | Change |
|------|--------|
| `genesis/thyra/render-specs/stream-card.yaml` | **DELETE** |
| `genesis/thyra/render-specs/voice-bar.yaml` | **DELETE** |
| `genesis/thyra/reflexes/stream-drift.yaml` | **DELETE** |
| `genesis/soma/reflexes/voice.yaml` | **DELETE** |
| `genesis/soma/reconcilers/voice.yaml` | **DELETE** |
| `genesis/soma/daemons/voice.yaml` | **DELETE** |
| `genesis/soma/modes/voice.yaml` | **DELETE** |
| `crates/kosmos/src/voice.rs` | **DELETE** |
| `crates/kosmos/tests/voice_substrate.rs` | **DELETE** |
| `app/src/lib/voice/capture.ts` | **DELETE** |
| `genesis/thyra/eide/thyra.yaml` | **MODIFY** — delete stream + voice-pipeline-config eide, clean accumulation + utterance, clean attainment/perceive |
| `genesis/thyra/typos/thyra.yaml` | **MODIFY** — delete stream + voice-pipeline-config + default-voice-config typos, clean section headers |
| `genesis/thyra/desmoi/thyra.yaml` | **MODIFY** — delete 4 stream/voice desmoi |
| `genesis/thyra/desmoi/mode.yaml` | **MODIFY** — update requires-mode comment (remove voice-composing example) |
| `genesis/thyra/modes/screen.yaml` | **MODIFY** — delete mode/voice-composing entity + 2 bonds |
| `genesis/thyra/praxeis/thyra.yaml` | **MODIFY** — delete 8 stream praxeis, clean accumulation praxeis, update switch-mode comment |
| `genesis/thyra/daemons/daemons.yaml` | **MODIFY** — remove stream daemon entry |
| `genesis/thyra/manifest.yaml` | **MODIFY** — remove stream/voice entries |
| `genesis/thyra/entities/default-accumulation.yaml` | **MODIFY** — clean to 4 fields |
| `genesis/logos/eide/logos.yaml` | **MODIFY** — remove source_stream_id from phasis |
| `genesis/genesis/surfaces/surfaces.yaml` | **MODIFY** — remove stream praxeis |
| `crates/kosmos/src/lib.rs` | **MODIFY** — remove voice mod + re-exports |
| `crates/kosmos/src/host.rs` | **MODIFY** — remove 3 voice stoicheion match arms |

---

## Success Criteria

- [ ] 10 files deleted (7 genesis + voice.rs + voice_substrate.rs + capture.ts)
- [ ] 13 files modified (references cleaned)
- [ ] Zero grep results for: `eidos/stream`, `mode/voice`, `voice-start-stream`, `typos-def-stream`, `voice-pipeline-config`, `voice-composing`, `voice-bar` in live code
- [ ] eidos/accumulation has exactly 7 fields
- [ ] mode_dispatch.rs has 13 registered modes
- [ ] All remaining tests pass
- [ ] Bootstrap succeeds

---

## What This Enables

A clean slate for PROMPT-VOICE-DECOMPOSITION.md. No dead stream entities confusing the context. No monolithic mode/voice conflating facets. The decomposed modes (mode/audio-capture, mode/transcription) can be built on ground that doesn't contradict them.

---

## What Does NOT Change

- **voice_capture.rs** (`app/src-tauri/src/voice_capture.rs`) — real cpal implementation stays. It's the port source for the decomposition.
- **actuality.ts** (`app/src/lib/actuality.ts`) — handler registry stays. Other substrates may use it.
- **eidos/utterance** — stays (cleaned of stream_id). The right entity for VAD-bounded speech.
- **typos-def-accumulation** — stays. Accumulation is still composed.
- **desmos/clarified-by** — stays. General concept (accumulation clarified by generation), not stream-specific.
- **Accumulation praxeis** — begin-accumulation, append-fragment, commit-phasis, etc. stay but are cleaned of stream_id references.
- **Other substrate modules** — process, storage, dns, livekit, credential — untouched.
- **All non-voice tests** — untouched.

---

*Traces to: Dead Code Policy (MEMORY.md), Voice Ontological Commitments (design dialogue), KOSMOGONIA §Composition Triad*
