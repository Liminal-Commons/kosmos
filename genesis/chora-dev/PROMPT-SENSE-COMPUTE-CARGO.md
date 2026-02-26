# PROMPT-SENSE-COMPUTE-CARGO — Sense actuality of cargo compute modes

*Sense prompt for Claude Code. This is an αἴσθησις instrument — it observes actuality and reports whether it conforms to existence (the prescriptive target in actualization-pattern.md).*

*Do NOT implement anything. Only sense and report.*

---

## Modes Under Observation

| Mode | Target Stage | Source |
|------|-------------|--------|
| `mode/cargo-build` | 6 (React) | `genesis/chora-dev/modes/compute.yaml` |
| `mode/cargo-test` | 6 (React) | `genesis/chora-dev/modes/compute.yaml` |
| `mode/cargo-clippy` | 6 (React) | `genesis/chora-dev/modes/compute.yaml` |

---

## Stage Criteria — What to Check

### Stage 1: Prescribe
- [ ] Mode entity exists in `genesis/chora-dev/modes/compute.yaml` with operations defined
- **Check:** Read the YAML file and confirm each mode has `manifest`, `sense`, and (where applicable) `unmanifest` operations with stoicheion names.

### Stage 2: Dispatch
- [ ] `build.rs` generates dispatch table entries for each mode's stoicheia
- [ ] `stoicheion_for_mode()` returns a stoicheion name for each (mode, provider, operation) triple
- **Check:** Read `crates/kosmos/src/mode_dispatch.rs` (generated). Search for `cargo-build`, `cargo-test`, `cargo-clippy` in the dispatch table. Confirm entries exist for manifest and sense operations.

### Stage 3: Implement
- [ ] Match arms in `host.rs` execute real logic for each stoicheion
- [ ] `cargo-build-run` invokes actual `cargo build` (not a stub/todo)
- [ ] `cargo-test-run` invokes actual `cargo test`
- [ ] `cargo-clippy-run` invokes actual `cargo clippy`
- [ ] Sense stoicheia (`cargo-build-sense`, `cargo-test-sense`, `cargo-clippy-sense`) query real state
- **Check:** Read `crates/kosmos/src/host.rs` — find `manifest_by_stoicheion()` and `sense_by_stoicheion()` match arms for these stoicheia. Trace into the implementation (likely `command_template.rs` or `execute_command_template()`). Confirm real shell commands are executed, not stubs.

### Stage 4: Compose
- [ ] Typos exist that produce entities with `mode: cargo-build` / `cargo-test` / `cargo-clippy`
- [ ] Praxeis exist that invoke manifest/sense for these entities
- **Check:** Search genesis for typos or praxeis referencing `cargo-build`, `cargo-test`, `cargo-clippy` as mode values. Check if build-target, test-run, lint-run entities can be composed through the standard path.

### Stage 5: Sense
- [ ] Sense stoicheia query actual substrate state (file existence, last run status)
- [ ] `cargo-build-sense` checks whether the build artifact exists on disk (BLAKE3 hash)
- [ ] `cargo-test-sense` and `cargo-clippy-sense` check last-run entity data or actual state
- **Check:** Read the sense implementation. Does `cargo-build-sense` actually stat a file and hash it? Or does it just read entity data? True sensing queries the substrate, not the graph.

### Stage 6: React
- [ ] Reflexes fire when cargo entity intent changes (e.g., `desired_state` updated)
- [ ] Reconciler drives corrections autonomously (e.g., "needs rebuild" → triggers build)
- [ ] Daemon periodically senses and reconciles stale builds
- **Check:** Search `genesis/chora-dev/` for reflex entities targeting cargo eide. Check `genesis/dynamis/reconcilers/` for reconciler entities covering cargo modes. Check `crates/kosmos/src/daemon_loop.rs` for cargo-aware daemon ticks.

---

## Files to Read

| File | What to Check |
|------|---------------|
| `genesis/chora-dev/modes/compute.yaml` | Mode entity definitions |
| `crates/kosmos/src/mode_dispatch.rs` | Generated dispatch table entries |
| `crates/kosmos/src/host.rs` | `manifest_by_stoicheion()` and `sense_by_stoicheion()` match arms |
| `crates/kosmos/src/command_template.rs` | `execute_command_template()` implementation |
| `genesis/chora-dev/` | Reflex, reconciler, typos for cargo entities |
| `genesis/dynamis/reconcilers/dynamis.yaml` | Reconciler definitions |
| `crates/kosmos/src/daemon_loop.rs` | Daemon tick coverage |

---

## Report Format

For each mode, report:

```
mode/cargo-build:
  Actual stage: N
  Evidence: {what was found at each stage}
  Gap from target: {6 - N} stages
  Blocking issue: {what prevents advancement to next stage}
```

Then update the Target Completion Matrix in `docs/reference/reactivity/actualization-pattern.md` Section 7:
- If actual == target: Status = "Aligned"
- If actual < target: Status = "Gap: at stage N" with Notes describing the blocking issue

---

*Traces to: actualization-pattern.md Section 2 (The Actualization Cycle — Sense moment), KOSMOGONIA Two Modes of Being*
