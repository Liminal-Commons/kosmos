# PROMPT-SENSE-MEDIA — Sense actuality of media mode

*Sense prompt for Claude Code. This is an αἴσθησις instrument — it observes actuality and reports whether it conforms to existence (the prescriptive target in actualization-pattern.md).*

*Do NOT implement anything. Only sense and report.*

---

## Modes Under Observation

| Mode | Provider | Target Stage | Source |
|------|----------|-------------|--------|
| `mode/voice` | local | 6 (React) | `genesis/soma/modes/voice.yaml` |

---

## Stage Criteria — What to Check

### Stage 1: Prescribe
- [ ] Mode entity exists in `genesis/soma/modes/voice.yaml` with operations defined
- **Check:** Read the YAML. Confirm `manifest` (`voice-start-stream`), `sense` (`voice-sense-stream`), `unmanifest` (`voice-stop-stream`) are defined with params and returns.

### Stage 2: Dispatch
- [ ] `build.rs` generates dispatch entries for voice mode
- [ ] `stoicheion_for_mode("voice", "local", op)` returns correct stoicheion names
- **Check:** Read `crates/kosmos/src/mode_dispatch.rs`. Search for `voice`/`local` entries.

### Stage 3: Implement
- [ ] `voice.rs` has real audio capture implementation
- [ ] `voice-start-stream` spawns actual audio capture process with VAD pipeline
- [ ] `voice-sense-stream` queries actual stream state
- [ ] `voice-stop-stream` tears down the capture process
- [ ] Operations return `_entity_update` for state reconciliation
- **Check:** Read `crates/kosmos/src/voice.rs`. Does `execute_operation()` contain real audio capture code or delegate to a real transcription provider? Check for `_entity_update` in return values.

### Stage 4: Compose
- [ ] Stream entities can be composed with `mode: voice, provider: local`
- [ ] Accumulation entities are created by the voice pipeline
- **Check:** Search genesis for typos or praxeis producing stream/accumulation entities. Check thyra praxeis (`thyra/open-stream`, `thyra/begin-accumulation`).

### Stage 5: Sense
- [ ] `voice-sense-stream` queries actual capture device state (not just entity data)
- [ ] Returns `stream_status`, `capture_state`, `has_content`, `content_length`
- [ ] Sense distinguishes between "stream entity says active" vs "audio device is actually capturing"
- **Check:** Read the sense implementation. Does it query the actual audio stream/process, or read entity fields?

### Stage 6: React
- [ ] Reflexes fire when voice entity state changes
- [ ] Reconciler drives corrections (e.g., stream crashed → restart capture)
- [ ] Daemon periodically senses voice stream health
- **Check:** Search genesis for reflex entities targeting stream eidos. Check reconciler definitions. Check daemon loop for voice-aware sensing.

---

## Additional Concern: Commitment Boundary

The voice mode implements the commitment boundary pattern. Beyond lifecycle operations, check:
- [ ] Content operations (append-fragment, clarify) are praxeis, NOT stoicheion-dispatched
- [ ] Accumulation entity is the state bridge between substrate and UI
- [ ] Commit praxis (`thyra/commit-accumulation` or `thyra/commit-phasis`) crosses the boundary to logos

This is not part of the stage assessment but reveals architectural health.

---

## Files to Read

| File | What to Check |
|------|---------------|
| `genesis/soma/modes/voice.yaml` | Mode entity definition |
| `crates/kosmos/src/mode_dispatch.rs` | Dispatch entries |
| `crates/kosmos/src/voice.rs` | Real audio capture? VAD? Transcription? `_entity_update`? |
| `crates/kosmos/src/host.rs` | Routing for voice stoicheia |
| `genesis/soma/` or `genesis/thyra/` | Reflex, reconciler, praxeis for voice/accumulation |
| `genesis/dynamis/reconcilers/dynamis.yaml` | Voice reconciler definition |
| `crates/kosmos/src/daemon_loop.rs` | Daemon coverage for voice streams |
| `app/src-tauri/src/voice_capture.rs` | Tauri-side audio capture (if exists) |

---

## Report Format

```
mode/voice:
  Actual stage: N
  Evidence: {what was found at each stage}
  Gap from target: {6 - N} stages
  Blocking issue: {what prevents advancement to next stage}
  Commitment boundary: {healthy/partial/missing}
```

Then update the Target Completion Matrix in `docs/reference/reactivity/actualization-pattern.md` Section 7.

---

*Traces to: actualization-pattern.md Section 2 (The Actualization Cycle — Sense moment), PROMPT-SUBSTRATE-VOICE.md, Commitment Boundary explanation*
