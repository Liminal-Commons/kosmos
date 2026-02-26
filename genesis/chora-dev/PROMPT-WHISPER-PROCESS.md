# PROMPT-WHISPER-PROCESS — Whisper Server as Process Entity with Model Selection

*Prompt for Claude Code in the chora + kosmos repository context.*

*After this work, the whisper server is a `deployment` entity managed by process-local reconciliation. Model, device, and compute type are configurable entity fields. The transcription mode connects to the running server but does not manage its lifecycle. Custom process management code (~60 lines) is deleted from voice.rs. Depends on: PROMPT-VOICE-DECOMPOSITION.md (transcription mode exists), process substrate (proven at stage 6).*

---

## Architectural Principle — Process Management Belongs to the Process Substrate

Every substrate has its own reconciliation engine. Audio capture belongs to the media substrate. Transcription belongs to the compute substrate. Process lifecycle — spawn, check, kill — belongs to the process substrate.

Currently, `start_transcription()` in voice.rs manages the whisper server process inline: `start_whisper_server()` spawns python3, polls the port for 120 seconds, probes TCP health. This is ~60 lines of custom process management that duplicates what `process.rs` already does through `local_spawn()` / `local_check()` / `local_kill()` with full reconciliation support (deployment reconciler, intent-changed + drift reflexes, 30s sense daemon).

The whisper server IS a process. It should be managed as one.

```
Before:
  toggle-transcriber-intent
    → reflex → reconcile(transcription)
    → transcription-start
    → start_whisper_server()     ← inline process management
    → take_audio_channel()
    → spawn ws_thread
    → [120s blocking timeout]

After:
  toggle-transcriber-intent
    → also toggles deployment/whisper-server
    → reflex → reconcile(deployment) → spawn python3 whisper-server.py
    → reflex → reconcile(transcription) → connect to ws://localhost:9012
    → take_audio_channel()
    → spawn ws_thread
    → [fail-fast if whisper not ready, drift retries]
```

---

## Methodology — DDD + TDD

This work follows **Doc → Test → Build → Verify**, non-negotiably.

1. **Doc (prescriptive)**: This prompt IS the prescriptive doc. The target state described here is what code must match.
2. **Test (assert the doc)**: Write tests that assert the target state. Tests should fail before implementation.
3. **Build (satisfy the tests)**: Implement until tests pass.
4. **Verify doc**: After implementation, update success criteria to reflect completion. Check docs/REGISTRY.md impact map.

Clean separation: the whisper server becomes a deployment entity; the transcription mode becomes a pure WebSocket client. No backward compatibility with inline process management.

---

## Current State

### What Exists and Works

| Component | Location | Status |
|-----------|----------|--------|
| Transcription mode (whisper-local) | `genesis/dynamis/modes/transcription.yaml` | Working |
| Stoicheion dispatch (transcription/whisper-local) | `mode_dispatch.rs` (generated) | Working |
| `start_transcription()` | `voice.rs:362` | Works but embeds process mgmt |
| `start_whisper_server()` | `voice.rs:512` | Works in dev, **broken in app bundle** |
| `probe_whisper()` | `voice.rs:549` | Working |
| `find_python()` | `voice.rs:558` | Working |
| `whisper-server.py` | `scripts/whisper-server.py` | Working standalone |
| Process substrate (local) | `process.rs` | Working, stage 6 |
| Deployment reconciler | `genesis/dynamis/reconcilers/dynamis.yaml` | Working, proven |
| Deployment autonomic triple | `genesis/dynamis/reflexes/reflexes.yaml` | Working, proven |
| Transcriber entity | `genesis/soma/entities/voice-defaults.yaml` | Working |
| Toggle praxis | `genesis/soma/praxeis/voice.yaml` | Working |

### What's Missing — The Gaps

1. **No deployment entity for whisper server** — the whisper process has no graph presence. It's spawned inline and invisible to the reconciliation system.

2. **Path resolution broken in app bundle** — `scripts/whisper-server.py` is relative. Sidecar cwd from app bundle is `/`, producing `//scripts/whisper-server.py`. Error: `python3: can't open file '//scripts/whisper-server.py'`.

3. **120s blocking timeout in reflex thread** — `start_whisper_server()` polls for 120 seconds on the reflex thread. If whisper isn't available, the entire reflex pipeline stalls.

4. **No model selection** — model size (tiny.en → large-v3), device (cpu/cuda), compute type (int8/float16) are hardcoded defaults in whisper-server.py CLI args and not exposed as entity fields.

5. **Custom process management duplicates process substrate** — `start_whisper_server()`, `probe_whisper()`, `find_python()` are ~60 lines that replicate what `local_spawn()` + `local_check()` already do.

---

## Target State

### Deployment Entity

A singleton `deployment/whisper-server` entity manages the whisper process through the process substrate:

```yaml
# In genesis/soma/entities/voice-defaults.yaml
- eidos: deployment
  id: deployment/whisper-server
  data:
    name: whisper-server
    actuality_mode: process
    provider: local
    desired_state: stopped
    actual_state: unknown
    config:
      command: python3
      args:
        - "scripts/whisper-server.py"
        - "--port"
        - "9012"
        - "--model"
        - "base.en"
        - "--device"
        - "cpu"
        - "--compute-type"
        - "int8"
      working_dir: null   # resolved at runtime from KOSMOS_SPORA parent
    whisper_model: "base.en"
    whisper_device: "cpu"
    whisper_compute_type: "int8"
    whisper_port: 9012
    mode: process
    provider: local
```

The `whisper_model`, `whisper_device`, `whisper_compute_type` fields are the source of truth. The `config.args` array is reconstructed from them at manifest time via a reflex or praxis step. (Alternatively, the toggle praxis rebuilds args from these fields before updating desired_state.)

### Bond: transcriber depends-on deployment

```yaml
# In genesis/soma/entities/voice-defaults.yaml bonds section
bonds:
  - from: transcriber/default
    to: deployment/whisper-server
    desmos: depends-on
```

### Toggle Praxis — Dual Toggle

`soma/toggle-transcriber-intent` also toggles `deployment/whisper-server`:

```yaml
# After toggling transcriber desired_state, also toggle whisper deployment:
- step: trace
  from_id: "$entity_id"
  desmos: "depends-on"
  resolve: "to"
  bind_to: dependencies

- step: for_each
  items: "$dependencies"
  as: dep
  do:
    - step: switch
      cases:
        - when: '$new_state == "active"'
          then:
            - step: update
              id: "$dep.id"
              data:
                desired_state: "running"
        - when: '$new_state == "closed"'
          then:
            - step: update
              id: "$dep.id"
              data:
                desired_state: "stopped"
```

### Transcription Start — Connect Only

`start_transcription()` in voice.rs no longer manages the whisper process. It just connects:

```rust
fn start_transcription(entity_id: &str, data: &Value) -> Result<Value> {
    // Check if already running
    // ...

    let port = data.get("whisper_port")
        .and_then(|p| p.as_u64())
        .unwrap_or(WHISPER_PORT) as u16;

    // Probe whisper — fail fast if not ready (drift will retry)
    if !probe_whisper(port) {
        return Err(KosmosError::Invalid(
            "Whisper server not running. Waiting for deployment/whisper-server to manifest.".into()
        ));
    }

    // Get audio channel, start WebSocket thread (unchanged)
    let (audio_rx, sample_rate, channels) = take_audio_channel()?;
    // ...
}
```

No `start_whisper_server()`. No 120s timeout. No `find_python()`. Fail fast → the reconciler retries via drift detection.

### Deleted Functions

Remove from voice.rs:
- `start_whisper_server()` (~35 lines)
- `find_python()` (~8 lines)

Keep `probe_whisper()` — transcription-start uses it to check whisper is ready.

### Working Directory Resolution

The deployment entity needs a valid `working_dir` for `scripts/whisper-server.py` to resolve. The `local_spawn()` in process.rs already supports `config.working_dir`. The sidecar knows the spora path via `KOSMOS_SPORA` env var — the workspace root is derivable from it (spora.yaml is at `genesis/spora/spora.yaml`, so workspace = 3 levels up from spora).

However: a simpler approach is to resolve the script path to an absolute path at manifest time. The praxis that toggles whisper deployment can compute the absolute path from the spora location.

### Eidos/Transcriber — New Field

Add `whisper_port` to `eidos/transcriber` (default: 9012) so the transcriber knows where to connect:

```yaml
whisper_port:
  type: integer
  required: false
  default: 9012
  description: "Port of the whisper server to connect to"
```

---

## Sequenced Work

### Phase 1: Genesis — Deployment Entity and Bonds

**Goal:** Whisper server exists as a deployment entity with model configuration, bonded to the transcriber.

**Tests:**
- `test_whisper_deployment_exists` — after bootstrap, `deployment/whisper-server` entity exists with expected fields
- `test_whisper_deployment_has_model_config` — entity data contains `whisper_model`, `whisper_device`, `whisper_compute_type`
- `test_transcriber_depends_on_whisper` — `depends-on` bond exists from `transcriber/default` to `deployment/whisper-server`
- `test_whisper_deployment_reconciler` — `reconciler/deployment` handles whisper entity (already proven, just verify it applies)

**Implementation:**
1. Add `deployment/whisper-server` entity to `genesis/soma/entities/voice-defaults.yaml`
2. Add `depends-on` bond from `transcriber/default` to `deployment/whisper-server`
3. Add `whisper_port` field to `eidos/transcriber` in `genesis/soma/eide/voice.yaml`
4. Add `whisper_port: 9012` to `transcriber/default` entity data

**Phase 1 Complete When:**
- [ ] `deployment/whisper-server` bootstraps with model/device/compute-type fields
- [ ] `depends-on` bond exists from transcriber to whisper deployment
- [ ] All existing tests still pass

### Phase 2: Toggle Praxis — Dual Toggle

**Goal:** Toggling transcriber intent also toggles whisper deployment desired_state.

**Tests:**
- `test_toggle_transcriber_also_toggles_whisper_deployment` — after calling `soma/toggle-transcriber-intent`, both `transcriber/default.desired_state` and `deployment/whisper-server.desired_state` are updated
- `test_toggle_back_stops_whisper` — toggling transcriber to closed also sets whisper deployment to stopped

**Implementation:**
1. Update `praxis/soma/toggle-transcriber-intent` in `genesis/soma/praxeis/voice.yaml`:
   - After toggling transcriber, trace `depends-on` bonds
   - For each dependency, toggle desired_state (active→running, closed→stopped)
2. Verify the deployment reconciler fires on the whisper entity's desired_state change (existing reflex should handle this)

**Phase 2 Complete When:**
- [ ] Toggle praxis updates both transcriber and deployment desired_state
- [ ] Deployment reflex fires on whisper entity change
- [ ] All existing tests still pass

### Phase 3: Rust — Remove Inline Process Management

**Goal:** `start_transcription()` connects to whisper, does not manage the process. Custom process functions deleted.

**Tests:**
- `test_transcription_start_fails_fast_without_whisper` — `start_transcription()` returns error immediately (not 120s timeout) when whisper not running
- `test_transcription_start_connects_when_whisper_running` — (hardware, #[ignore]) when whisper is running on port 9012, transcription-start succeeds

**Implementation:**
1. Modify `start_transcription()` in `voice.rs`:
   - Read `whisper_port` from entity data (default 9012)
   - Call `probe_whisper(port)` — if false, return `Err` immediately
   - Remove `start_whisper_server(data)?` call
   - Rest unchanged (take audio channel, spawn ws_thread)
2. Delete `start_whisper_server()` function
3. Delete `find_python()` function
4. Keep `probe_whisper()` — still needed for the probe check

**Phase 3 Complete When:**
- [ ] `start_whisper_server()` deleted from voice.rs
- [ ] `find_python()` deleted from voice.rs
- [ ] `start_transcription()` fails fast when whisper not running
- [ ] No 120s blocking timeout in reflex thread
- [ ] All existing tests still pass

---

## Files to Read

### Transcription Substrate
- `crates/kosmos/src/voice.rs` — current implementation with inline process management
- `genesis/dynamis/modes/transcription.yaml` — mode definition
- `genesis/soma/entities/voice-defaults.yaml` — transcriber/default entity
- `genesis/soma/eide/voice.yaml` — eidos/transcriber fields
- `genesis/soma/praxeis/voice.yaml` — toggle and sense praxeis
- `genesis/soma/reconcilers/transcription.yaml` — transcription reconciler

### Process Substrate
- `crates/kosmos/src/process.rs` — local_spawn/check/kill implementation
- `genesis/dynamis/reconcilers/dynamis.yaml` — deployment reconciler transitions
- `genesis/dynamis/reflexes/reflexes.yaml` — deployment intent-changed + drift reflexes
- `genesis/dynamis/daemons/daemons.yaml` — sense-deployments daemon

### Infrastructure
- `scripts/whisper-server.py` — the whisper server script (CLI args)
- `crates/kosmos/src/mode_dispatch.rs` — stoicheion dispatch (generated)
- `crates/kosmos/build.rs` — mode dispatch generation from mode YAML
- `crates/kosmos/src/host.rs` — manifest/sense/unmanifest dispatch

---

## Files to Touch

| File | Change |
|------|--------|
| `genesis/soma/entities/voice-defaults.yaml` | **MODIFY** — add `deployment/whisper-server` entity, `depends-on` bond, `whisper_port` to transcriber |
| `genesis/soma/eide/voice.yaml` | **MODIFY** — add `whisper_port` field to `eidos/transcriber` |
| `genesis/soma/praxeis/voice.yaml` | **MODIFY** — toggle-transcriber-intent also toggles whisper deployment |
| `crates/kosmos/src/voice.rs` | **MODIFY** — delete `start_whisper_server()`, `find_python()`, simplify `start_transcription()` |
| `crates/kosmos/tests/whisper_process.rs` | **NEW** — tests for deployment entity, dual toggle, fail-fast connection |

---

## Success Criteria

### Phase 1
- [ ] `deployment/whisper-server` bootstraps correctly
- [ ] Model configuration fields present on entity
- [ ] `depends-on` bond from transcriber to whisper deployment
- [ ] `whisper_port` field on eidos/transcriber

### Phase 2
- [ ] Toggle praxis updates both entities
- [ ] Deployment reconciler fires on whisper desired_state change
- [ ] No orphaned whisper processes (closed = stopped)

### Phase 3
- [ ] `start_whisper_server()` deleted
- [ ] `find_python()` deleted
- [ ] `start_transcription()` fails fast (< 1s, not 120s)
- [ ] `probe_whisper()` retained for connection check

### Overall Complete When
- [ ] All existing tests still pass
- [ ] New tests cover deployment entity, dual toggle, fail-fast
- [ ] No inline process management in voice.rs
- [ ] Whisper model/device/compute-type are entity fields (changeable without code changes)
- [ ] `just local` produces working app bundle (path resolution works from /Applications)

---

## What This Enables

1. **Model selection** — changing whisper model is an entity field update + process restart. No code changes. A settings UI could let the user pick tiny.en through large-v3.

2. **Whisper visibility** — the whisper server is a graph entity. Its status (running/stopped/failed) is visible in the UI. Drift detection restarts it if it crashes.

3. **Path resolution** — the deployment entity has `working_dir`, solving the app bundle path problem.

4. **Non-blocking reflex** — `local_spawn()` returns immediately with PID. No 120s timeout stalling the reflex thread. Transcription connects when ready, retries via drift.

5. **Future providers** — deepgram, commons-asr, or any other ASR service connects as a different `provider` on the transcription mode. Each has different substrate needs but the same interface: audio in, transcript out. Whisper-local happens to need a process entity; deepgram doesn't.

6. **VAD tuning** — whisper-server.py's CLI args can be extended with `--vad-threshold`, `--silence-duration`, `--min-utterance`. These become entity fields on the deployment, changeable without code edits.

---

## What Does NOT Change

- **Audio capture** — media substrate, cpal, audio-source entity — untouched
- **Transcription WebSocket protocol** — voice.rs's `run_transcription_loop()` stays the same, it just connects to a server it didn't spawn
- **Transcription reconciler** — `reconciler/transcription` transitions unchanged
- **Transcription reflexes** — `reflex/soma/reconcile-transcription-on-intent` and drift unchanged
- **Transcription sense daemon** — `daemon/sense-transcribers` unchanged
- **whisper-server.py itself** — no changes to the Python script (it already accepts all needed CLI args)
- **Compose bar render-specs** — `@fed-by-transcriber` bond traversal unchanged
- **Deployment reconciler and reflexes** — already proven, just gets a new entity

---

*Traces to: PROMPT-VOICE-DECOMPOSITION.md (transcription mode), PROMPT-SENSE-COMPUTE-PROCESS.md (process substrate at stage 6), PROMPT-COMPOSE-BAR.md (compose bar toggle UI)*
