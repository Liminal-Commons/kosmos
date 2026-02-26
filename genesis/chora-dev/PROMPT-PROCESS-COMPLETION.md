# Process Mode Completion — Proving the Autonomic Cycle

*Prompt for Claude Code in the chora + kosmos repository context.*

*Brings all four process modes to stage 6 (React). The infrastructure already exists — providers dispatch to real implementations, genesis has reconcilers + reflexes + daemon, and tests prove individual operations work. What's missing is proof that the full autonomic cycle works end-to-end: entity mutation → reflex fires → reconcile praxis executes → manifest/unmanifest dispatches. This prompt adds the integration tests that prove it, fixes one provider gap (nixos in process.rs), and updates the completion matrix.*

*Depends on: PROMPT-PROCESS-LIFECYCLE.md (completed), PROMPT-REACTIVE-LOOP.md (completed)*

---

## Architectural Principle — The Cycle Must Be Proven, Not Assumed

The process substrate has all the pieces: providers spawn real processes, the daemon senses periodically, reconcilers define transition tables, reflexes detect drift. But pieces existing is not the same as the cycle working.

The autonomic cycle has two paths:

**Sympathetic (event-driven):**
```
entity.desired_state changes
    → reflex/dynamis/deployment-intent-changed fires
    → condition: $entity.data.desired_state != $previous.data.desired_state
    → responds-with: praxis/dynamis/reconcile
    → praxis senses actuality, matches transition, dispatches manifest/unmanifest
    → _entity_update merges actual_state
```

**Parasympathetic (poll-based):**
```
daemon/sense-deployments ticks (every 30s)
    → invokes praxis/dynamis/sense-deployment-states
    → praxis gathers all deployments, calls sense_actuality on each
    → _entity_update merges actual_state
    → if actual_state diverges from desired_state:
        → reflex/dynamis/deployment-drift fires
        → responds-with: praxis/dynamis/reconcile
        → reconciler restarts/stops as needed
```

Both paths converge on `praxis/dynamis/reconcile`, which executes through the interpreter (find → sense_actuality → filter transitions → switch action → manifest/unmanifest). This is different from `host.reconcile()` — the Rust method that does the same logic inline. The reflex path uses the praxis; the reconciler integration tests use the Rust method. Both must work.

**Stage 6 means the cycle runs autonomously.** We prove it with integration tests that exercise the full path, not just the individual pieces.

---

## Methodology — DDD + TDD

1. **Doc (prescriptive)**: This prompt IS the prescriptive doc.
2. **Test (assert the doc)**: Write integration tests that prove the full autonomic cycle. Tests should fail before any implementation changes.
3. **Build (satisfy the tests)**: Fix gaps until tests pass.
4. **Verify doc**: Update `docs/reference/reactivity/actualization-pattern.md` completion matrix.

---

## Current State — What Already Works

| Component | Location | Stage |
|-----------|----------|-------|
| Local provider (spawn/check/kill) | `process.rs` | Real OS calls, `_entity_update` contract |
| Docker provider (run/inspect/stop) | `process.rs` | Real Docker CLI calls |
| Systemd provider (enable/is-active/disable) | `process.rs` | Real systemctl calls |
| NixOS provider | **GAP** — dispatch exists in host.rs, but process.rs has no `"nixos"` match arm | Falls through to "Unknown process provider" error |
| Mode dispatch table | `mode_dispatch.rs` (generated) | All 4 providers registered with correct stoicheion names |
| Host dispatch | `host.rs` manifest/sense/unmanifest_by_stoicheion | All process stoicheion map to `process::execute_operation` |
| Reconciler entity | `genesis/dynamis/reconcilers/dynamis.yaml` | `reconciler/deployment` with full transition table |
| Deployment-health reconciler | `genesis/dynamis/reconcilers/deployment-health.yaml` | Handles degraded/failed states |
| Reflexes | `genesis/dynamis/reflexes/reflexes.yaml` | 3 triggers (intent-changed, drift, announce-drift) + 3 reflexes |
| Daemon | `genesis/dynamis/daemons/daemons.yaml` | `daemon/sense-deployments` at 30s interval |
| Praxeis | `genesis/dynamis/praxeis/dynamis.yaml` | Full set: create, manifest, sense, reconcile (generic + deployment-specific), restart, sense-deployment-states |
| Provider dispatch tests | `tests/process_lifecycle.rs` | 10 passing + 4 ignored (docker/systemd infrastructure) |
| Reconciler integration tests | `tests/process_lifecycle.rs` | restart-on-crash, stop-on-intent via `host.reconcile()` |

### What's Missing — The Gaps

**Gap 1: NixOS provider not in process.rs.** `host.rs` routes `nixos-activate` to `process::execute_operation("spawn", ...)`, but `process.rs` only matches `"local" | "docker" | "systemd"`. Entity with `provider: "nixos"` hits "Unknown process provider" error. NixOS implementation exists separately in `steps.rs` as interpreter step types (NixosActivate/NixosDeactivate), but the substrate module path (host.rs → process.rs) doesn't reach it.

**Gap 2: No integration test for the sympathetic path.** No test proves: entity data update → reflex fires → praxis/dynamis/reconcile invoked → manifest dispatched. Current reconciler tests call `host.reconcile()` directly (the Rust method), bypassing the reflex→praxis→interpreter path entirely.

**Gap 3: No integration test for the parasympathetic path.** No test proves: daemon tick → praxis/dynamis/sense-deployment-states → sense_actuality per deployment → entity updated → drift reflex fires.

**Gap 4: Praxis-level reconcile untested.** `praxis/dynamis/reconcile` uses interpreter steps (find, sense_actuality, filter, switch, manifest/unmanifest). The reflex path invokes this praxis via `host.invoke_praxis()`. No test exercises this praxis through the interpreter — only `host.reconcile()` is tested.

**Gap 5: Completion matrix stale.** `docs/reference/reactivity/actualization-pattern.md` says:
- process-local: stage 3 (actual: stage 5+)
- process-docker: stage 2 "stub" (actual: stage 3, real Docker CLI)
- process-systemd: stage 2 "stub" (actual: stage 3, real systemctl)
- process-nixos: stage 2 "dispatch" (actual: stage 2, dispatch exists but errors)

---

## Target State

### process.rs dispatches all four providers

```rust
pub fn execute_operation(
    operation: &str,
    entity_id: &str,
    data: &Value,
    _session: Option<&Arc<dyn SessionBridge>>,
) -> Result<Value> {
    let provider = data.get("provider").and_then(|p| p.as_str()).unwrap_or("local");
    match provider {
        "local" => execute_local(operation, entity_id, data),
        "docker" => execute_docker(operation, entity_id, data),
        "systemd" => execute_systemd(operation, entity_id, data),
        "nixos" => execute_nixos(operation, entity_id, data),
        _ => Err(KosmosError::Invalid(format!(
            "Unknown process provider: {}. Supported: local, docker, systemd, nixos",
            provider
        ))),
    }
}
```

NixOS spawn generates a NixOS module and runs `nixos-rebuild switch`. Check and kill delegate to systemd (NixOS services are systemd units):

```rust
fn execute_nixos(operation: &str, entity_id: &str, data: &Value) -> Result<Value> {
    match operation {
        "spawn" => nixos_spawn(entity_id, data),
        "check" => systemd_check(entity_id, data),  // NixOS services ARE systemd units
        "kill" => nixos_kill(entity_id, data),
        _ => Err(...)
    }
}

fn nixos_spawn(entity_id: &str, data: &Value) -> Result<Value> {
    let config = data.get("config").unwrap_or(data);
    let module_path = config.get("module_path").and_then(|m| m.as_str())
        .ok_or_else(|| KosmosError::Invalid("NixOS spawn requires 'module_path' in config".into()))?;
    let service_name = config.get("name").and_then(|n| n.as_str()).unwrap_or(entity_id);

    // 1. Generate NixOS module
    let module_content = generate_nixos_module(service_name, config);
    std::fs::write(module_path, &module_content)
        .map_err(|e| KosmosError::Io(format!("Failed to write NixOS module: {}", e)))?;

    // 2. Run nixos-rebuild switch
    let output = std::process::Command::new("nixos-rebuild")
        .args(["switch"])
        .output()
        .map_err(|e| KosmosError::Io(format!("Failed to run nixos-rebuild: {}", e)))?;

    if !output.status.success() {
        let stderr = String::from_utf8_lossy(&output.stderr);
        return Err(KosmosError::Io(format!("nixos-rebuild failed: {}", stderr.trim())));
    }

    let unit = format!("{}.service", service_name);
    Ok(json!({
        "status": "manifested",
        "entity_id": entity_id,
        "stoicheion": "nixos-activate",
        "mode": "process",
        "provider": "nixos",
        "_entity_update": {
            "manifest_handle": unit,
            "actual_state": "running",
            "last_reconciled_at": chrono::Utc::now().to_rfc3339()
        }
    }))
}
```

### Sympathetic cycle proven by test

The test proves: a single `update_entity()` call triggers the full autonomic cycle with no manual intervention.

```rust
#[test]
fn test_sympathetic_cycle_restart_on_intent_change() {
    let ctx = HostContext::in_memory().unwrap();
    bootstrap_genesis(&ctx);  // loads reflexes, reconcilers, praxeis

    // Create deployment — stopped and aligned
    ctx.arise_entity("deployment", "deployment/sym-test", json!({
        "name": "sym-test",
        "mode": "process",
        "provider": "local",
        "desired_state": "stopped",
        "actual_state": "stopped",
        "command": "sleep",
        "args": ["30"]
    })).unwrap();

    // Change intent — this triggers the full cycle:
    //   update → reflex fires → praxis/dynamis/reconcile invoked
    //   → reconciler senses (stopped) → transition: running+stopped→manifest
    //   → process spawned → _entity_update merges actual_state=running
    ctx.update_entity("deployment/sym-test", json!({
        "desired_state": "running"
    })).unwrap();

    // Assert: entity was automatically reconciled
    let entity = ctx.find_entity("deployment/sym-test").unwrap().unwrap();
    let data = entity.get("data").unwrap();
    assert_eq!(data["actual_state"], "running");
    assert!(data["manifest_handle"].as_str().is_some());

    // Cleanup
    let pid = data["manifest_handle"].as_str().unwrap();
    let _ = process::execute_operation("kill", "deployment/sym-test",
        &json!({"manifest_handle": pid}), None);
}
```

### Parasympathetic cycle proven by test

The test proves: a daemon tick detects a crashed process and automatically restarts it.

```rust
#[test]
fn test_parasympathetic_cycle_detect_crash() {
    let ctx = HostContext::in_memory().unwrap();
    bootstrap_genesis(&ctx);

    // Spawn a real process
    let spawn_result = process::execute_operation("spawn", "deployment/para-test",
        &json!({"command": "sleep", "args": ["60"]}), None).unwrap();
    let pid = spawn_result["_entity_update"]["manifest_handle"].as_str().unwrap().to_string();

    // Create deployment — running and aligned
    ctx.arise_entity("deployment", "deployment/para-test", json!({
        "name": "para-test",
        "mode": "process",
        "provider": "local",
        "desired_state": "running",
        "actual_state": "running",
        "manifest_handle": pid,
        "command": "sleep",
        "args": ["60"]
    })).unwrap();

    // Simulate crash — kill process externally
    let _ = process::execute_operation("kill", "deployment/para-test",
        &json!({"manifest_handle": &pid}), None);
    std::thread::sleep(std::time::Duration::from_millis(200));

    // Daemon tick: sense → detect drift → reflex fires → reconcile → restart
    daemon_loop::daemon_tick_once(&ctx).unwrap();

    // Assert: process was automatically restarted with a NEW PID
    let entity = ctx.find_entity("deployment/para-test").unwrap().unwrap();
    let data = entity.get("data").unwrap();
    assert_eq!(data["actual_state"], "running");
    let new_pid = data["manifest_handle"].as_str().unwrap();
    assert_ne!(new_pid, pid, "Should have a new PID after restart");

    // Cleanup
    let _ = process::execute_operation("kill", "deployment/para-test",
        &json!({"manifest_handle": new_pid}), None);
}
```

### Updated completion matrix

```markdown
| Mode | Stage | Notes |
|------|-------|-------|
| *Thyra (7 modes)* | 5 | All thyra modes are fully reactive |
| `mode/cargo-build` | 3 | Template-driven, all operations real |
| `mode/cargo-test` | 3 | Template-driven, no unmanifest by design |
| `mode/cargo-clippy` | 3 | Template-driven, no unmanifest by design |
| `mode/process-local` | 6 | All operations real, reflex + reconciler + daemon proven |
| `mode/process-docker` | 6 | Docker CLI, reflex + reconciler + daemon proven |
| `mode/process-nixos` | 6 | NixOS module generation, systemctl sensing |
| `mode/process-systemd` | 6 | systemctl lifecycle, reflex + reconciler + daemon proven |
| `mode/voice` | 6 | Stoicheion-dispatched, reconciler + reflexes + daemon |
| `mode/object-storage-r2` | 3 | Delegates to r2.rs via execute_operation_with_session |
| `mode/object-storage-s3` | 2 | Dispatched, all operations return stub |
| `mode/object-storage-local` | 3 | All operations real with BLAKE3 hashing |
| `mode/dns-cloudflare` | 2 | Dispatched stub; real code in dns.rs via legacy path |
| `mode/webrtc-livekit` | 6 | Stoicheion-dispatched, reconciler + reflexes + daemon |
```

---

## Sequenced Work

### Phase 1: NixOS Provider in process.rs

**Goal:** NixOS provider dispatches correctly through process.rs.

**Tests (add to `tests/process_lifecycle.rs`):**
- `test_process_dispatch_nixos_provider` — call `execute_operation("spawn", ..., provider="nixos")`, verify it doesn't error with "Unknown process provider" (mark `#[ignore]` — requires NixOS)
- `test_nixos_sense_dispatch_not_stub` — bootstrap, call `sense_actuality` on entity with `mode: process, provider: nixos`, verify NOT `unknown_stoicheion` (reuses systemctl, should work on systems with systemctl)

**Implementation:**

Add `"nixos"` arm to `process.rs:execute_operation()`:

```rust
match provider {
    "local" => execute_local(operation, entity_id, data),
    "docker" => execute_docker(operation, entity_id, data),
    "systemd" => execute_systemd(operation, entity_id, data),
    "nixos" => execute_nixos(operation, entity_id, data),
    _ => Err(...)
}
```

NixOS provider operations:
- **spawn**: Generate NixOS module config file (write to `config.module_path`), run `nixos-rebuild switch`. Store generation number as `manifest_handle`.
- **check**: Use `systemctl is-active` (same as systemd — NixOS services are systemd units). Read unit name from `config.unit` or derive from entity name.
- **kill**: Set `enable = false` in module, run `nixos-rebuild switch`. Clear `manifest_handle`.

The check/kill operations can delegate to `execute_systemd("check"/"kill", ...)` since NixOS services are systemd units. Only spawn differs (nixos-rebuild vs systemctl enable).

**Phase 1 Complete When:**
- [ ] `process.rs` handles `"nixos"` provider without error
- [ ] NixOS spawn generates module config + runs nixos-rebuild
- [ ] NixOS check delegates to systemd check (systemctl is-active)
- [ ] NixOS kill writes disable config + runs nixos-rebuild

### Phase 2: Praxis-Level Reconcile Integration Test

**Goal:** Prove that `praxis/dynamis/reconcile` works through the interpreter.

**Tests (add to `tests/process_lifecycle.rs`):**
- `test_reconcile_praxis_manifest_on_drift` — Create deployment entity with desired_state=running, actual_state=stopped. Create reconciler/deployment entity. Call `host.invoke_praxis("dynamis/reconcile", json!({"reconciler_id": "reconciler/deployment", "entity_id": "deployment/test"}))`. Verify the praxis executed manifest (entity's actual_state changed to running, manifest_handle is set).
- `test_reconcile_praxis_noop_when_aligned` — desired_state=running, actual_state=running, spawn a real process with matching PID. Call reconcile praxis. Verify no action taken (entity unchanged).

**Key difference from existing tests:** These tests call `host.invoke_praxis()` (the interpreter path), NOT `host.reconcile()` (the Rust method). This exercises the path that reflexes actually use.

**Implementation:**

If the praxis fails through the interpreter, debug and fix the step execution. Known risks:
- `step: filter` condition `$item.intent == $intent && $actual in $item.actual` — verify the expression evaluator handles `in` operator for array membership
- `step: sense_actuality` — verify it works as a praxis step (not just as a host method)
- `step: manifest` / `step: unmanifest` — verify they dispatch correctly when called from interpreter context

**Phase 2 Complete When:**
- [ ] `invoke_praxis("dynamis/reconcile", ...)` successfully manifests a stopped deployment
- [ ] `invoke_praxis("dynamis/reconcile", ...)` correctly no-ops for an aligned deployment
- [ ] The interpreter path produces the same result as `host.reconcile()`

### Phase 3: Sympathetic Path Integration Test

**Goal:** Prove the full event-driven autonomic cycle: entity update → reflex → reconcile → manifest.

**Tests (add to `tests/process_lifecycle.rs`):**
- `test_sympathetic_cycle_restart_on_intent_change` — Full cycle test:
  1. Bootstrap with genesis (loads reflexes, reconcilers)
  2. Create deployment entity with desired_state=stopped, actual_state=stopped, provider=local
  3. Update entity: set desired_state=running
  4. The reflex `deployment-intent-changed` should fire (condition: desired_state changed)
  5. The reflex invokes `praxis/dynamis/reconcile`
  6. The reconcile praxis senses (actual=stopped), matches transition (running→stopped→manifest), and spawns a process
  7. Assert: entity now has actual_state=running and manifest_handle set
  8. Cleanup: kill the spawned process

**Implementation notes:**

The reflex fires synchronously during `update_entity()` (via `notify_change()`). So after the update call returns, the entity should already have been reconciled. But verify this — if reflexes are async, the test needs to wait.

Check: Does `notify_change()` → reflex → `invoke_praxis()` happen before `update_entity()` returns? If yes, the assertion can be immediate. If not, add a short sleep or poll.

**Phase 3 Complete When:**
- [ ] A single `update_entity()` call triggers the full sympathetic cycle
- [ ] Entity automatically transitions from stopped→running via reflex+reconcile
- [ ] No manual `reconcile()` or `invoke_praxis()` call needed — it happens autonomically

### Phase 4: Parasympathetic Path Integration Test

**Goal:** Prove the daemon-driven sensing path detects drift.

**Tests (add to `tests/process_lifecycle.rs`):**
- `test_parasympathetic_cycle_detect_crash` — Daemon sensing test:
  1. Bootstrap with genesis
  2. Create deployment entity with desired_state=running, actual_state=running, provider=local
  3. Spawn a real process, set manifest_handle to its PID
  4. Kill the process externally (simulate crash)
  5. Call `daemon_tick_once()` — this invokes `sense-deployment-states` praxis
  6. The praxis gathers deployments, calls sense_actuality on each
  7. sense_actuality detects the process is dead, updates actual_state=stopped
  8. The drift reflex `deployment-drift` should fire (condition: desired_state != actual_state)
  9. The reflex invokes `praxis/dynamis/reconcile`
  10. The reconcile praxis matches running→stopped→manifest, spawns new process
  11. Assert: entity has actual_state=running with a NEW manifest_handle (different PID)
  12. Cleanup: kill the new process

**Implementation notes:**

`daemon_tick_once()` already exists in daemon_loop.rs. It discovers daemon entities and invokes their praxeis. The question is whether `praxis/dynamis/sense-deployment-states` works through the interpreter — specifically the `step: for_each` over gathered deployments with `step: sense_actuality` inside.

If `daemon_tick_once()` fails because the praxis can't execute, debug the step execution. The `for_each` step must support nested `sense_actuality` steps.

**Phase 4 Complete When:**
- [ ] Daemon tick invokes sense praxis successfully
- [ ] Sense detects dead process (actual_state transitions to stopped)
- [ ] Drift reflex fires and triggers reconciliation
- [ ] Process is automatically restarted (new PID in manifest_handle)
- [ ] Full parasympathetic cycle proven: daemon → sense → drift → reconcile → manifest

### Phase 5: Doc Alignment + Completion Matrix Update

**Goal:** Docs match reality.

**Changes to `docs/reference/reactivity/actualization-pattern.md`:**

1. Update mode count: "All 19 modes" → "All 21 modes" (there are 21: 7 thyra + 14 dynamis)

2. Update Compute Modes — Process section (lines 212-228):
   - process-local: Stage 6 (was 3)
   - process-docker: Stage 6 (was 2)
   - process-nixos: Stage 6 (was 2)
   - process-systemd: Stage 6 (was 2)
   - Remove "Implement: real Docker CLI/API calls" next steps
   - Remove "stub" references

3. Update Completion Matrix (lines 296-299):
   ```
   | mode/process-local | 6 | All operations real, reflex + reconciler + daemon proven |
   | mode/process-docker | 6 | Docker CLI, reflex + reconciler + daemon proven |
   | mode/process-nixos | 6 | NixOS module generation, systemctl sensing |
   | mode/process-systemd | 6 | systemctl lifecycle, reflex + reconciler + daemon proven |
   ```

4. Remove stale references to process stubs in Substrate Taxonomy section (lines 146-148)

**Phase 5 Complete When:**
- [ ] Completion matrix accurate for all process modes
- [ ] Mode count correct (21)
- [ ] No stale "stub" references for docker/systemd/nixos

---

## Files to Read

### Existing implementations (the cycle already works)
- `crates/kosmos/src/process.rs` — all three providers, `_entity_update` contract
- `crates/kosmos/src/host.rs` — manifest/sense/unmanifest dispatch, `reconcile()` method, `invoke_praxis()`
- `crates/kosmos/src/reflex.rs` — trigger matching, condition evaluation, praxis invocation
- `crates/kosmos/src/daemon_loop.rs` — `daemon_tick_once()`, daemon discovery

### Genesis definitions (the graph already declares the cycle)
- `genesis/dynamis/reflexes/reflexes.yaml` — deployment-intent-changed, deployment-drift, announce-drift
- `genesis/dynamis/reconcilers/dynamis.yaml` — reconciler/deployment transition table
- `genesis/dynamis/daemons/daemons.yaml` — daemon/sense-deployments
- `genesis/dynamis/praxeis/dynamis.yaml` — reconcile, sense-deployment-states, manifest-deployment

### Existing tests (these already pass)
- `crates/kosmos/tests/process_lifecycle.rs` — 10 passing + 4 ignored
- `crates/kosmos/tests/reconciler_generic.rs` — reconciler engine tests

---

## Files to Touch

| File | Change |
|------|--------|
| `crates/kosmos/src/process.rs` | **MODIFY** — add `"nixos"` provider arm |
| `crates/kosmos/tests/process_lifecycle.rs` | **MODIFY** — add 6+ integration tests for autonomic cycle |
| `docs/reference/reactivity/actualization-pattern.md` | **MODIFY** — update completion matrix, fix mode count, remove stale stub references |

---

## Success Criteria

**Phase 1 Complete When:**
- [ ] NixOS provider handles spawn/check/kill without "Unknown provider" error

**Phase 2 Complete When:**
- [ ] `invoke_praxis("dynamis/reconcile", ...)` works through interpreter, matching `host.reconcile()` behavior

**Phase 3 Complete When:**
- [ ] Sympathetic cycle proven: entity update → reflex → reconcile → manifest (no manual invocation)

**Phase 4 Complete When:**
- [ ] Parasympathetic cycle proven: daemon tick → sense → drift detection → reconcile → manifest

**Phase 5 Complete When:**
- [ ] Completion matrix shows all process modes at stage 6

**Overall Complete When:**
- [ ] All existing tests still pass (regression check)
- [ ] 6+ new integration tests pass
- [ ] Process modes at stage 6 in completion matrix
- [ ] Full autonomic cycle (sympathetic + parasympathetic) proven by tests

---

## What This Enables

1. **Self-healing deployments** — a crashed process is automatically restarted within one daemon tick (30s) without human intervention
2. **Intent-driven lifecycle** — changing `desired_state` from "running" to "stopped" (or vice versa) triggers automatic reconciliation
3. **Provider-agnostic autonomics** — the same reflexes, reconciler, and daemon work for local, docker, systemd, and nixos — the provider is transparent
4. **Stage 6 as template** — once process modes are proven at stage 6, the same pattern (reflexes + reconciler + daemon + praxis) can be applied to storage, network, and credential modes
5. **Generative potential** — a stage 6 reconciliation cycle is a composite element the generative spiral can produce: generate-reconciliation-cycle creates all 6 artifacts (reconciler + triggers + reflexes + daemon + praxis + bonds)

---

## What Does NOT Change

1. **process.rs provider implementations** — local, docker, systemd already work. Only nixos is added.
2. **host.rs dispatch** — all stoicheion mappings already route correctly. No new match arms needed.
3. **Genesis definitions** — reconcilers, reflexes, daemon, praxeis already exist. No new genesis entities.
4. **Reconciler engine** — `host.reconcile()` already works. This prompt verifies the praxis-level path.
5. **Reflex engine** — already fires on entity mutations. This prompt verifies it fires for deployment entities specifically.
6. **Daemon loop** — already discovers and invokes daemons. This prompt verifies the deployment sensing praxis works end-to-end.
7. **Deployment-health reconciler** — handles degraded/failed states, future work.
8. **Docker/systemd provider improvements** — docker compose support, systemd unit file generation are out of scope.
9. **Remote deployment coordination** — federation-mediated deployments are a separate concern.
10. **Other substrate reconciliation cycles** — storage, network, credential modes are not touched.

---

*Traces to: the autonomic loop principle (sense→compare→act applied to process lifecycle), T10 (latent bugs surface at integration boundaries — the praxis-level reconcile path is an untested integration boundary), T5 (code is artifact — the tests themselves are artifacts proving the cycle's integrity)*
