# PROMPT-SENSE-COMPUTE-PROCESS — Sense actuality of process compute modes

*Sense prompt for Claude Code. This is an αἴσθησις instrument — it observes actuality and reports whether it conforms to existence (the prescriptive target in actualization-pattern.md).*

*Do NOT implement anything. Only sense and report.*

---

## Modes Under Observation

| Mode | Provider | Target Stage | Source |
|------|----------|-------------|--------|
| `mode/process-local` | local | 6 (React) | `genesis/dynamis/modes/dynamis.yaml` |
| `mode/process-docker` | docker | 6 (React) | `genesis/dynamis/modes/dynamis.yaml` |
| `mode/process-systemd` | systemd | 6 (React) | `genesis/dynamis/modes/dynamis.yaml` |
| `mode/process-nixos` | nixos | 6 (React) | `genesis/dynamis/modes/dynamis.yaml` |

---

## Stage Criteria — What to Check

### Stage 1: Prescribe
- [ ] Mode entities exist in `genesis/dynamis/modes/dynamis.yaml` with operations defined
- **Check:** Read the YAML. Confirm all four modes have `manifest`, `sense`, `unmanifest` operations with stoicheion names (`spawn-process`/`check-process`/`kill-process`, `docker-run`/`docker-inspect`/`docker-stop`, `systemd-enable`/`systemctl-status`/`systemd-disable`, `nixos-activate`/`systemctl-status`/`nixos-deactivate`).

### Stage 2: Dispatch
- [ ] `build.rs` generates dispatch table entries for all four providers
- [ ] `stoicheion_for_mode("process", "local"|"docker"|"systemd"|"nixos", op)` returns correct stoicheion names
- **Check:** Read `crates/kosmos/src/mode_dispatch.rs`. Search for each (mode, provider) pair. Confirm all 12 operation→stoicheion mappings exist.

### Stage 3: Implement
- [ ] `process.rs` has `execute_operation()` dispatching all four providers
- [ ] `execute_local()` spawns real OS processes via `std::process::Command`
- [ ] `execute_docker()` runs real `docker run/inspect/stop` commands
- [ ] `execute_systemd()` runs real `systemctl enable/is-active/disable` commands
- [ ] `execute_nixos()` generates NixOS module and runs `nixos-rebuild switch`
- [ ] All operations return `_entity_update` for state reconciliation
- **Check:** Read `crates/kosmos/src/process.rs`. Verify each provider function contains real shell commands (not stubs/todos). Check that `_entity_update` is returned with `manifest_handle` and `actual_state`.

### Stage 4: Compose
- [ ] Deployment entities can be composed with `mode: process` and `provider: local|docker|systemd|nixos`
- [ ] Praxeis or typos exist that create deployment entities
- **Check:** Search genesis for typos referencing `deployment` eidos with process mode. Check if `praxis/dynamis/reconcile` is wired.

### Stage 5: Sense
- [ ] `check-process` queries OS via `kill(pid, 0)` + `waitpid` — NOT just entity data
- [ ] `docker-inspect` queries Docker daemon via `docker inspect`
- [ ] `systemctl-status` queries systemd via `systemctl is-active`
- [ ] All sense operations return `_entity_update` with sensed `actual_state`
- **Check:** Read the sense functions in `process.rs`. Verify they execute real system calls (libc, Docker CLI, systemctl). Distinguish "true substrate sensing" from "returning last-known entity data."

### Stage 6: React
- [ ] `reflex/deployment-intent-changed` fires on `entity_updated` for deployment entities
- [ ] `reconciler/deployment` reads transition tables and drives manifest/unmanifest
- [ ] Daemon tick senses all deployment entities and detects drift
- [ ] **Test evidence:** `test_sympathetic_cycle_restart_on_intent_change` passes
- [ ] **Test evidence:** `test_parasympathetic_cycle_detect_crash` passes
- **Check:** Search genesis for reflex entities targeting deployment eidos. Read `genesis/dynamis/reconcilers/dynamis.yaml` for the deployment reconciler. Read `crates/kosmos/tests/` for sympathetic/parasympathetic cycle tests. Run: `cargo test -p kosmos sympathetic parasympathetic`

---

## Files to Read

| File | What to Check |
|------|---------------|
| `genesis/dynamis/modes/dynamis.yaml` | Mode entity definitions (process section) |
| `crates/kosmos/src/mode_dispatch.rs` | Generated dispatch — all 4 providers present |
| `crates/kosmos/src/process.rs` | Real implementations for local, docker, systemd, nixos |
| `crates/kosmos/src/host.rs` | `manifest_by_stoicheion()` routing to `process::execute_operation()` |
| `genesis/dynamis/reconcilers/dynamis.yaml` | Deployment reconciler definition |
| `genesis/dynamis/reflexes/` or equivalent | Reflex entities for deployment |
| `crates/kosmos/src/reflex.rs` | Reflex engine |
| `crates/kosmos/src/daemon_loop.rs` | Daemon tick and deployment sensing |
| `crates/kosmos/tests/` | Sympathetic and parasympathetic cycle tests |

---

## Report Format

For each mode, report:

```
mode/process-local:
  Actual stage: N
  Evidence: {what was found at each stage}
  Gap from target: {6 - N} stages
  Blocking issue: {what prevents advancement to next stage}
```

Then update the Target Completion Matrix in `docs/reference/reactivity/actualization-pattern.md` Section 7.

---

*Traces to: actualization-pattern.md Section 2 (The Actualization Cycle — Sense moment), PROMPT-PROCESS-COMPLETION.md (prior sensing of this substrate)*
