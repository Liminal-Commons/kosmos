# Process Lifecycle Completion — Living Entities Need Periodic Sensing

*Prompt for Claude Code in the chora + kosmos repository context.*

*Wires process substrate into the autonomic loop. Replaces docker/systemd/nixos stubs with provider-appropriate implementations. Adds daemon-driven periodic sensing for long-running processes. After this work, docker and systemd providers are operational, process health is sensed periodically, and the reconciler restarts crashed processes. Advances process modes from stage 4 to stage 6.*

*Depends on: PROMPT-SUBSTRATE-STANDARD.md, PROMPT-SUBSTRATE-DNS.md*

---

## Architectural Principle — Living Entities Must Be Sensed

A process is not a fire-and-forget command. It is an entity that was manifested into actuality — spawned into chora. Like a DNS record or an R2 object, a process has a lifecycle: it can be manifested (started), sensed (is it still running?), and unmanifested (stopped).

But processes differ from static substrates in one essential way: **they can die on their own.** A DNS record doesn't disappear unless someone deletes it. A process can crash, OOM, or be killed by the OS. This means:

1. **Periodic sensing is mandatory**, not optional. Without it, the entity says "running" while the process is dead.
2. **The reconciler must handle external death gracefully** — when intent is "running" but actual is "stopped" (due to crash), the action is "manifest" (restart), not an error.
3. **Drift is expected**, not exceptional. The autonomic loop exists precisely for this — to detect drift and correct it.

**An entity that represents something living must be sensed periodically, because life includes the possibility of death.** Static substrates can be sensed on-demand. Living substrates must be sensed on a schedule.

The second principle: **same contract, different mechanisms.** Process modes have four providers (local, docker, systemd, nixos). Each manifests, senses, and unmanifests processes differently — `spawn()` vs `docker run` vs `systemctl enable`. But the `_entity_update` contract is the same: every provider sets `actual_state` and `manifest_handle`. The reconciler compares intent to actuality in domain-neutral terms; the provider translates those terms into substrate-specific actions.

---

## Methodology — DDD + TDD

This work follows **Doc → Test → Build → Verify**, non-negotiably.

1. **Doc (prescriptive)**: This prompt IS the prescriptive doc. The target state described here is what code must match.
2. **Test (assert the doc)**: Write tests that assert provider dispatch, `_entity_update` format, and reconciler behavior. Tests should fail before implementation.
3. **Build (satisfy the tests)**: Implement until tests pass.
4. **Verify doc**: After implementation, update success criteria to reflect completion. Check docs/REGISTRY.md impact map.

Docker and systemd tests that require external infrastructure should be `#[ignore]`. Tests that verify dispatch routing and `_entity_update` structure can use the local provider. Reconciler tests use in-memory entities.

---

## Current State

### What Exists and Works

| Component | Location | Status |
|-----------|----------|--------|
| Local process operations | `process.rs` | Working — spawn/check/kill with correct `_entity_update` |
| Local dispatch in host.rs | `host.rs` (spawn-process, check-process, kill-process) | Working — uses `dispatch_to_module` |
| reconciler/deployment | `genesis/dynamis/reconcilers/dynamis.yaml` | Working — transition table for running/stopped |
| Deployment reflexes | `genesis/dynamis/reflexes/reflexes.yaml` | Working — trigger on desired_state change |
| Docker stubs in host.rs | `host.rs` (docker-run, docker-inspect, docker-stop) | Stubs — return `"status": "stub"` |
| Systemd/NixOS entries | `mode_dispatch.rs` | Generated — but NO match arms in host.rs (fall through to `unknown_stoicheion`) |

### What's Missing — The Gaps

**Gap 1: Docker stubs bypass the process module.** `docker-run`, `docker-inspect`, `docker-stop` return `"status": "stub"` inline in host.rs. They should dispatch through `dispatch_to_module` → `process::execute_operation` with `provider: "docker"`.

**Gap 2: No docker provider implementation.** `process.rs` only handles the `local` provider. Docker operations (shell out to `docker run -d`, `docker inspect`, `docker stop`) are not implemented. Same for systemd (`systemctl enable --now`, `systemctl is-active`, `systemctl disable --now`).

**Gap 3: No periodic sensing daemon.** Long-running processes can die between sense operations. No `daemon/process-health-check` entity exists to drive periodic sensing. Without it, a crashed process stays in "running" state forever — the reconciler never learns about the drift.

**Gap 4: Systemd/NixOS stoicheion have no match arms.** `mode_dispatch.rs` generates stoicheion mappings for systemd and nixos providers, but `host.rs` has no match arms for them. They fall through to `unknown_stoicheion` — not even stubs.

---

## Target State

### process.rs dispatches by provider

```rust
pub fn execute_operation(operation, entity_id, data, session) -> Result<Value> {
    let provider = data.get("provider").and_then(|p| p.as_str()).unwrap_or("local");
    match provider {
        "local" => execute_local(operation, entity_id, data),
        "docker" => execute_docker(operation, entity_id, data),
        "systemd" => execute_systemd(operation, entity_id, data),
        _ => Err(...)
    }
}
```

### Docker operations

```rust
fn execute_docker(operation: &str, entity_id: &str, data: &Value) -> Result<Value> {
    let image = data["image"].as_str().ok_or(...)?;
    let name = data.get("name").and_then(|n| n.as_str()).unwrap_or(entity_id);
    match operation {
        "spawn" => {
            // docker run -d --name {name} {image}
            // parse container ID from stdout
            Ok(json!({
                "status": "manifested",
                "entity_id": entity_id,
                "_entity_update": {
                    "actual_state": "running",
                    "manifest_handle": container_id,
                    "last_reconciled_at": now
                }
            }))
        }
        "check" => {
            // docker inspect --format '{{.State.Running}}' {container_id}
            Ok(json!({
                "status": "sensed",
                "entity_id": entity_id,
                "_entity_update": {
                    "actual_state": if running { "running" } else { "stopped" },
                    "last_sensed_at": now
                }
            }))
        }
        "kill" => {
            // docker stop {container_id}
            Ok(json!({
                "status": "unmanifested",
                "entity_id": entity_id,
                "_entity_update": {
                    "actual_state": "stopped",
                    "manifest_handle": null,
                    "last_reconciled_at": now
                }
            }))
        }
    }
}
```

### Stubs replaced with one-liner delegations

```rust
// manifest_by_stoicheion:
"docker-run" => self.dispatch_to_module(entity_id, data,
    crate::process::execute_operation("spawn", entity_id, data, session_ref)),

// sense_by_stoicheion:
"docker-inspect" => self.dispatch_to_module(entity_id, data,
    crate::process::execute_operation("check", entity_id, data, session_ref)),

// unmanifest_by_stoicheion:
"docker-stop" => self.dispatch_to_module(entity_id, data,
    crate::process::execute_operation("kill", entity_id, data, session_ref)),
```

### Process health daemon

```yaml
- eidos: daemon
  id: daemon/process-health-check
  data:
    name: process-health-check
    description: |
      Periodically sense all deployment entities to detect drift.
      When a process dies unexpectedly, sensing updates actual_state
      to "stopped", which triggers the reconciler to restart it.
    type: interval
    enabled: true
    scope: dwelling
    config:
      interval_ms: 60000
      target_eidos: deployment
      action: sense
```

---

## Sequenced Work

### Phase 1: Provider Dispatch + Docker Implementation (Rust)

**Goal:** `process.rs` dispatches by provider. Docker operations are implemented.

**Tests:**
- `test_process_dispatch_by_provider_local` — call `execute_operation("spawn", ..., provider="local")`, verify returns `_entity_update` with `actual_state: "running"`
- `test_process_dispatch_by_provider_docker` — call `execute_operation("spawn", ..., provider="docker", image="alpine")`, verify returns `_entity_update` (mark `#[ignore]` — requires docker)
- `test_docker_check_returns_entity_update` — call `execute_operation("check", ..., provider="docker")`, verify `_entity_update.actual_state` is "running" or "stopped" (mark `#[ignore]`)

**Implementation:**

1. Refactor `process::execute_operation` to dispatch by provider (local, docker, systemd)
2. Implement `execute_docker()` — spawn via `docker run -d`, check via `docker inspect`, kill via `docker stop`
3. All docker operations return `_entity_update` following the same convention as local

**Phase 1 Complete When:**
- [ ] `process::execute_operation` dispatches by provider field
- [ ] Docker spawn returns `_entity_update` with `manifest_handle` (container ID) and `actual_state: "running"`
- [ ] Docker check returns `_entity_update` with `actual_state` ("running" or "stopped")
- [ ] Docker kill returns `_entity_update` with `actual_state: "stopped"` and `manifest_handle: null`

### Phase 2: Systemd Implementation + Stub Replacement (Rust + Genesis)

**Goal:** Systemd provider implemented. Docker/systemd/nixos stubs replaced in host.rs.

**Tests:**
- `test_systemd_check_returns_entity_update` — call `execute_operation("check", ..., provider="systemd", unit="test.service")`, verify `_entity_update` format (mark `#[ignore]`)
- `test_docker_dispatch_not_stub` — bootstrap, call `manifest_by_stoicheion("docker-run", ...)`, verify result does NOT contain `"status": "stub"`
- `test_deployment_reconcile_restart` — create deployment entity with desired_state=running, actual_state=stopped, reconcile, verify action_taken=="manifest"
- `test_deployment_reconcile_stop` — desired_state=stopped, actual_state=running → action_taken=="unmanifest"

**Implementation:**

1. Implement `execute_systemd()` — spawn via `systemctl enable --now {unit}`, check via `systemctl is-active {unit}`, kill via `systemctl disable --now {unit}`
2. Replace docker stubs in host.rs with one-liner delegations through `dispatch_to_module`
3. Add systemd match arms to host.rs (these don't exist yet — not even stubs)
4. NixOS: defer full implementation. Add match arms that delegate to systemd for now (NixOS uses systemctl for sense, different mechanism for manifest/unmanifest)

**Phase 2 Complete When:**
- [ ] Systemd operations implemented with `_entity_update` convention
- [ ] Docker stubs in host.rs replaced with one-liner delegations
- [ ] Systemd match arms added to host.rs
- [ ] Reconciler works for docker and systemd entities (same transition table)

### Phase 3: Periodic Sensing Daemon (Genesis)

**Goal:** Process health daemon defined for periodic sensing.

**Implementation:**

1. Create `genesis/dynamis/entities/daemon-health.yaml` with `daemon/process-health-check`
2. Daemon gathers deployment entities, calls sense for each on schedule

**Phase 3 Complete When:**
- [ ] `daemon/process-health-check` entity defined in genesis
- [ ] Daemon has correct `interval_ms`, `target_eidos`, and `action` configuration

### Phase 4: Verify

**Goal:** Everything works together.

```bash
cargo build -p kosmos 2>&1
cargo test -p kosmos --lib --tests 2>&1
cargo test -p kosmos --test process_lifecycle 2>&1
cargo test -p kosmos --test reconciler_generic 2>&1  # regression
```

**Tests:**
- `test_local_spawn_entity_update` — spawn `sleep 10`, verify `_entity_update.actual_state == "running"` (regression)
- `test_local_check_dead_process` — spawn, kill externally, then check, verify `actual_state == "stopped"`
- `test_local_kill_entity_update` — spawn, then kill, verify `_entity_update.actual_state == "stopped"` and `manifest_handle == null`

**Phase 4 Complete When:**
- [ ] All existing tests pass
- [ ] 7+ new tests pass in `process_lifecycle.rs`
- [ ] No stubs remain for docker/systemd in host.rs

---

## Files to Read

### The pattern to follow (local provider)
- `crates/kosmos/src/process.rs` — current local provider, `_entity_update` patterns

### What to change
- `crates/kosmos/src/host.rs` — docker/systemd/nixos stubs, process dispatch arms
- `crates/kosmos/src/mode_dispatch.rs` — all process provider stoicheion mappings

### Reference
- `genesis/dynamis/reconcilers/dynamis.yaml` — `reconciler/deployment` transition table
- `genesis/dynamis/reflexes/reflexes.yaml` — deployment intent-change triggers

---

## Files to Touch

| File | Change |
|------|--------|
| `crates/kosmos/src/process.rs` | **MODIFY** — add docker and systemd provider implementations, refactor to dispatch by provider |
| `crates/kosmos/src/host.rs` | **MODIFY** — replace docker stubs with one-liner delegations, add systemd/nixos match arms |
| `genesis/dynamis/entities/daemon-health.yaml` | **NEW** — `daemon/process-health-check` for periodic sensing |
| `crates/kosmos/tests/process_lifecycle.rs` | **NEW** — 7+ tests |

---

## Success Criteria

**Phase 1 Complete When:**
- [ ] Docker operations implemented with standard `_entity_update` convention
- [ ] `process.rs` dispatches by provider (local/docker/systemd)

**Phase 2 Complete When:**
- [ ] Systemd operations implemented with standard `_entity_update` convention
- [ ] All stubs replaced with one-liner delegations in host.rs

**Phase 3 Complete When:**
- [ ] `daemon/process-health-check` defined in genesis

**Overall Complete When:**
- [ ] All existing tests pass
- [ ] 7+ new tests pass in `process_lifecycle.rs`
- [ ] Process modes at stage 6 (fully autonomic)
- [ ] No process stubs remain in host.rs

---

## What This Enables

1. **Docker deployments** — `desired_state: running` + `provider: docker` + `image: "nginx:latest"` → container started and health-checked
2. **Systemd services** — `desired_state: running` + `provider: systemd` + `unit: "kosmos-mcp.service"` → service enabled and monitored
3. **Self-healing processes** — daemon senses periodically → process died → `actual_state: "stopped"` → reflex fires → reconciler restarts
4. **Process substrate fully autonomic** — all providers operational through generic dispatch, reconcilers handle lifecycle
5. **Deployment on NixOS** — same reconciler, different provider — no new reconcilers needed

---

## What Does NOT Change

1. **Local process operations** — spawn/check/kill already work — this prompt adds providers, not rewrites
2. **reconciler/deployment** — transition table already correct — works for any provider
3. **Reflexes** — deployment-intent-change trigger and reconcile-on-intent-change reflex already exist
4. **mode_dispatch.rs** — already has entries for docker, systemd, nixos — generated from genesis modes
5. **Other substrates** — DNS, storage, cargo untouched

---

## Scope Boundaries

**In scope**: Docker and systemd provider implementations (shell execution), periodic sensing daemon entity, stub replacement in host.rs.

**Out of scope**: NixOS provider implementation (requires nix-specific tooling — defer to when NixOS deployment is needed). NixOS match arms can delegate to systemd for now.

**Out of scope**: Daemon loop infrastructure (the actual interval-based execution loop that processes daemon entities). This prompt defines the daemon entity; the daemon loop is a separate concern.

---

*Traces to: the living entity principle (processes can die, therefore must be sensed periodically), the provider principle (same contract, different mechanisms — the reconciler is provider-agnostic), the autonomic loop (sense→compare→act applied to process lifecycle), PROMPT-SUBSTRATE-STANDARD.md*
