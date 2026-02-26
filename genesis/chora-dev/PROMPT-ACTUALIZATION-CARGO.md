# Actualization — Wiring chora-dev/build End-to-End

*Prompt for Claude Code in the chora + kosmos repository context.*

*Wires the prescribed `praxis/chora-dev/build` pipeline into a functioning end-to-end flow: entity → mode dispatch → command template → shell execution → result. After this work, a Claude Code session can invoke `chora-dev/build` with a crate name and profile, and the kosmos will orchestrate the cargo build through the mode system, tracking the result as graph entities with content hashes and bonds.*

*Depends on: PROMPT-MODE-CONSOLIDATION.md (creates the unified `mode/cargo-build` entity that build.rs generates dispatch for).*

---

## Architectural Principle — Commands as Data, Not Code

KOSMOGONIA §Homoiconic: if it's structural, it's an entity. Commands are structural — they have arguments, conditions, output formats, timeout constraints. These are data, not code.

The existing stoicheion implementations (`spawn-process`, `r2-put-object`, `cf-create-record`) hardcode their behavior in Rust match arms. This works when each stoicheion has unique logic. But cargo operations share a common pattern: read a template, interpolate args, shell-execute, parse output. The template entities already exist (`genesis/chora-dev/entities/command-templates.yaml`). The Rust implementation should read them, not duplicate them.

The principle: `execute_command_template()` reads `command-template/cargo-build` from the graph, interpolates conditional args using entity data, executes via shell, parses output. Adding npm, go, or make requires only new YAML templates — no new Rust code for the execution path.

---

## Methodology — Doc-Driven, Test-Driven

The cycle: **Doc → Test → Build → Align → Track**.

1. **Doc**: Read `docs/reference/composition/` and `docs/reference/infrastructure/`. Verify there is a reference doc describing the command-template execution pattern and stoicheion dispatch for cargo modes. If none exists, create `docs/reference/infrastructure/command-template-execution.md` describing the target state.
2. **Test**: Write a failing test for `execute_command_template()` — bootstrap genesis, execute `praxis/chora-dev/build`, assert a build-target entity is created with `builds-into` bond and the manifest dispatches through the cargo mode. This test should fail before implementation (no `cargo-build-run` match arm exists).
3. **Build**: Implement template execution, arg interpolation, sense stoicheia, helper praxeis.
4. **Align**: Check `docs/REGISTRY.md` Impact Map for stale docs. Update any that reference stoicheion dispatch or actuality modes.

---

## What Already Works

The prescribed architecture has substantial implementation depth. Understanding what already works is critical — this prompt connects the existing pieces, it does not rewrite them.

### Fully implemented (Tier 0–2 steps)

| Step | Implementation | Used by chora-dev/build |
|------|---------------|------------------------|
| `find` | `steps.rs` → `ctx.find_entity()` | Find source-crate by ID |
| `assert` | `steps.rs` → condition eval + error | Verify source-crate exists |
| `call` | `steps.rs` → `execute_praxis()` recursive | Call hash-source helper |
| `compose` | `steps.rs` → typos composition pipeline | Create build-target entity |
| `bind` | `steps.rs` → `ctx.create_bond()` | builds-into / compiled-from bonds |
| `update` | `steps.rs` → `ctx.update_entity()` | Update build status |
| `return` | `steps.rs` → scope return value | Return result |
| `for_each` | `steps.rs` → iteration | scan-workspace iterate crates |
| `switch` | `steps.rs` → conditional branching | sense-build null check |

### Implemented but need new dispatch arms (Tier 3 steps)

| Step | Implementation | Gap |
|------|---------------|-----|
| `manifest` | `steps.rs:ManifestStep` → `ctx.manifest()` → `resolve_actuality_mode()` → `manifest_by_stoicheion()` | `manifest_by_stoicheion()` has no match arm for `cargo-build-run` |
| `sense_actuality` | `steps.rs:SenseActualityStep` → `ctx.sense_actuality()` → `sense_by_stoicheion()` | `sense_by_stoicheion()` has no match arm for `cargo-build-sense` |

### Implemented generic primitives

| Primitive | Implementation | Status |
|-----------|---------------|--------|
| `shell-execute` step | `steps.rs:ShellExecuteStep` — spawns process, captures stdout/stderr/exit_code | Working |
| `hash-path` step | `steps.rs:HashPathStep` — BLAKE3 hash of files matching glob | Working |
| `parse-output` step | `steps.rs:ParseOutputStep` — json/lines/regex/cargo-test/cargo-clippy/cargo-metadata | Working |
| `file-exists` step | `steps.rs:FileExistsStep` — path existence check | Working |
| `spawn-process` | `host.rs:manifest_by_stoicheion("spawn-process")` — background process spawn | Working |
| `check-process` | `host.rs:sense_by_stoicheion("check-process")` — kill(0) alive check | Working |
| `kill-process` | `host.rs:unmanifest_by_stoicheion("kill-process")` — SIGTERM/SIGKILL | Working |

### Prescribed in genesis, not yet wired

| Component | File | Status |
|-----------|------|--------|
| Command templates | `genesis/chora-dev/entities/command-templates.yaml` | 5 templates (build, test, clippy, metadata, clean) |
| Helper praxeis | `genesis/chora-dev/praxeis/chora-dev.yaml` | `cargo-metadata`, `hash-source` referenced by `call` steps |
| Stoicheion entities | `genesis/chora-dev/stoicheia/shell.yaml` | 4 generic stoicheia (shell-execute, hash-path, parse-output, file-exists) |
| Eide | `genesis/chora-dev/eide/` | source-crate, build-target, test-run, lint-run |
| Typos | `genesis/chora-dev/typos/` | typos-def-source-crate, typos-def-build-target, etc. |
| Reflexes | `genesis/chora-dev/reflexes/` | notify-build-complete, detect-staleness, etc. |

---

## The Architecture — How It Should Flow

### `praxis/chora-dev/build` execution path

```
1. Claude invokes: chora-dev/build { crate_name: "kosmos", profile: "release" }

2. Interpreter executes steps sequentially:
   a. find → source-crate/kosmos (already exists from scan-workspace)
   b. assert → source-crate exists
   c. call → chora-dev/hash-source → hash-path step → BLAKE3 hash of src/
   d. compose → build-target/kosmos-release entity (status: "building")
   e. bind → builds-into bond, compiled-from bond

   f. manifest → build-target/kosmos-release
      ↓
      host.manifest("build-target/kosmos-release")
      ↓
      resolve_actuality_mode(data, "build-target", host)
      → (mode: "cargo-build", provider: "local")
      ↓
      actuality_stoicheion("cargo-build", "local", Manifest)
      → Some("cargo-build-run")
      ↓
      manifest_by_stoicheion("build-target/kosmos-release", "cargo-build-run", data)
      → [NEW: reads command-template/cargo-build, interpolates args, shell-executes]
      → returns { success, artifact_path, content_hash, duration_ms, error }

   g. update → build-target status, artifact_path, content_hash, etc.
   h. return → { build_target_id, success, duration_ms }
```

### The key gap

`manifest_by_stoicheion()` in `host.rs` matches on stoicheion names. It handles `spawn-process`, `r2-put-object`, `cf-create-record`, etc. — but has no match arm for `cargo-build-run`. See Design section for the template-driven approach.

---

## Design — Template-Driven Stoicheia

### Why not hardcode cargo in Rust

The existing `spawn-process` implementation in `manifest_by_stoicheion()` reads `command`, `args`, `working_dir`, `env` directly from entity data. This works for generic process lifecycle but doesn't handle conditional args, output parsing, artifact path computation, or content hashing.

Hardcoding these in Rust would violate the principle: "Commands become data in the graph, not code in Rust."

### The template-driven pattern

The stoicheion implementations compose the generic primitives:

```
cargo-build-run  = find(command-template/cargo-build) + shell-execute(template) + parse-output(result)
cargo-build-sense = file-exists(artifact_path) + hash-path(source) + compare hashes
cargo-clean      = find(command-template/cargo-clean) + shell-execute(template)
```

New match arms in `manifest_by_stoicheion()` delegate to `execute_command_template()` — a single function that reads any command template from the graph, interpolates args, and shell-executes. New match arms in `sense_by_stoicheion()` delegate to `sense_build_artifact()` — checks freshness via hash comparison, not re-execution.

### Entity data requirements

Build-target entities must have `actuality_mode: cargo-build` and `provider: local` in their data for `resolve_actuality_mode()` to route correctly. This comes from the typos composition — the typos-def-build-target must include these fields, or the compose step must set them explicitly.

---

## Implementation Order

### Step 1: Doc — Verify or create reference doc

Read `docs/reference/infrastructure/`. Check whether a reference doc describes the command-template execution pattern (template lookup → arg interpolation → shell execution → output parsing → artifact hashing). If none exists, create `docs/reference/infrastructure/command-template-execution.md` describing:

- The `execute_command_template()` function signature and purpose
- Template lookup: stoicheion name → `command-template/*` entity ID
- Arg interpolation: string args vs conditional `{value, when}` args
- Output parsing via `output_format` field
- Artifact path computation from `artifact_path_segments`
- Sense pattern: freshness via hash comparison, not re-execution

This doc prescribes the target state — the code should match it after implementation.

### Step 2: Test — Write failing tests

Create `crates/kosmos/tests/chora_dev_build.rs` with tests that assert the end-to-end flow. These tests should **fail** before implementation.

```rust
#[test]
fn test_build_target_entity_has_actuality_mode() {
    // Bootstrap, compose a build-target entity
    // Assert data.actuality_mode == "cargo-build"
    // Assert data.provider == "local"
    // → Fails if typos-def-build-target is missing these fields
}

#[test]
fn test_execute_command_template_dispatches_cargo_build() {
    // Bootstrap, find command-template/cargo-build entity
    // Call execute_command_template with test data
    // Assert args are interpolated correctly
    // Assert conditional args are included/excluded based on data
    // → Fails because execute_command_template doesn't exist yet
}

#[test]
fn test_build_praxis_dispatches_to_cargo_mode() {
    // Bootstrap, ensure source-crate entity exists
    // Execute praxis/chora-dev/build { crate_name: "kosmos", profile: "dev" }
    // Assert build-target entity created with builds-into bond
    // Assert manifest was called (dispatched through cargo mode)
    // Assert build_status is "succeeded" or "failed" (not "building")
    // → Fails because manifest_by_stoicheion has no cargo-build-run arm
}

#[test]
fn test_sense_build_artifact_checks_freshness() {
    // Bootstrap, create a build-target entity with known hash
    // Call sense_build_artifact
    // Assert is_fresh is true when hash matches, false when stale
    // → Fails because sense_by_stoicheion has no cargo-build-sense arm
}
```

### Step 3: Build — Entity data alignment

**Goal**: Ensure build-target entities have the data fields that `resolve_actuality_mode()` reads.

Read `genesis/chora-dev/typos/` to find the build-target typos. Verify it includes `actuality_mode` field. If not, add it:

```yaml
# In the typos definition
fields:
  actuality_mode:
    type: string
    default: "cargo-build"
  provider:
    type: string
    default: "local"
```

Or ensure the compose step in `praxis/chora-dev/build` explicitly sets it in inputs.

Verify `resolve_actuality_mode()` in `host.rs` reads `data.actuality_mode` and `data.provider` — confirm the entity data path matches.

### Step 4: Build — Command template execution

**Goal**: Implement `execute_command_template()` in `host.rs`.

Add template lookup mapping (stoicheion name → template entity ID):

```rust
fn template_for_stoicheion(stoicheion: &str) -> Option<&'static str> {
    match stoicheion {
        "cargo-build-run" => Some("command-template/cargo-build"),
        "cargo-test-run" => Some("command-template/cargo-test"),
        "cargo-clippy-run" => Some("command-template/cargo-clippy"),
        "cargo-clean" => Some("command-template/cargo-clean"),
        "cargo-metadata" => Some("command-template/cargo-metadata"),
        _ => None,
    }
}
```

Implement `execute_command_template()` — the template-driven execution function:

1. Find the command template entity in the graph
2. Extract the command name
3. Interpolate args (handle conditional `when:` objects)
4. Execute via `std::process::Command`
5. Parse output using the template's `output_format`
6. Compute artifact path from `artifact_path_segments` (if present)
7. Hash artifact (if present)
8. Return structured result

Implement `interpolate_template_args()` — template args are either strings (always included) or objects with `{value, when}` (conditionally included). Populate a scope from entity data, eval conditions using `eval_condition()`, interpolate `{{ }}` expressions using `eval_string()`.

Add match arms in `manifest_by_stoicheion()`:

```rust
"cargo-build-run" | "cargo-test-run" | "cargo-clippy-run" | "cargo-clean" => {
    self.execute_command_template(entity_id, stoicheion, data)
}
```

### Step 5: Build — Sense stoicheia

**Goal**: Implement `cargo-build-sense`, `cargo-test-sense`, `cargo-clippy-sense`.

Sense for build artifacts doesn't run cargo — it checks:
1. Does the artifact file exist?
2. Is the source hash current? (compare stored hash with computed hash)

For test/lint: return last run info from entity data (last_run_at, status, passed/failed counts).

Add match arms in `sense_by_stoicheion()`:

```rust
"cargo-build-sense" => { /* exists + freshness check */ }
"cargo-test-sense" | "cargo-clippy-sense" => { /* last run info */ }
```

### Step 6: Build — Helper praxeis

**Goal**: Ensure `chora-dev/cargo-metadata` and `chora-dev/hash-source` helper praxeis exist and work.

The `praxis/chora-dev/build` calls these via `step: call`. Check if they're declared in `genesis/chora-dev/praxeis/chora-dev.yaml`. If missing, add them — 3-5 steps each, using existing generic primitives.

### Step 7: Test — Verify all tests pass

```bash
# Rebuild — new dispatch arms compile
cargo build -p kosmos 2>&1

# All existing tests still pass
cargo test -p kosmos --lib --tests 2>&1

# New tests from Step 2 now pass
cargo test -p kosmos --test chora_dev_build 2>&1
```

### Step 8: Verify — No hardcoded cargo commands

```bash
# Dispatch table includes cargo modes (requires Mode Consolidation first)
grep 'cargo-build' crates/kosmos/src/actuality_modes.rs
# Expected: ("cargo-build", "local", ...) entries

# No hardcoded cargo commands in Rust outside of command templates
rg 'cargo build' crates/kosmos/src/ --type rust
# Expected: zero results (cargo commands live in YAML templates, not Rust)
```

### Step 9: Verify — MCP integration

```bash
# Start kosmos-mcp
KOSMOS_NO_SESSION=1 just serve

# In another terminal, invoke via MCP
# Expected: chora-dev/build executes, creates entities, runs cargo build
```

### Step 10: Align — Update stale docs

Check `docs/REGISTRY.md` Impact Map. Search docs for references to stoicheion dispatch patterns. Update the new reference doc (from Step 1) if the implementation diverged from the prescribed target.

---

## What This Enables

- **Self-describing builds**: The kosmos can build itself through its own praxis system. `chora-dev/build` is invoked like any other praxis — by Claude, by MCP, by reflexes.
- **Template-driven tool integration**: The `execute_command_template()` pattern works for any tool. Adding npm, go, or make requires only new YAML templates and stoicheion-to-template mappings — no new Rust code for the execution path.
- **Full cycle validation**: The complete sense/compose/manifest/update cycle runs end-to-end. build-target entities track source hashes, artifact paths, content hashes, and build status. Staleness detection via `reconcile-builds` praxis becomes functional.
- **Graph-traversable development**: `trace(from: source-crate/kosmos, desmos: builds-into)` returns all build targets. Reflexes like `detect-staleness` can fire when source hashes change.
- **T11 empirical confirmation**: The screen substrate (SolidJS) already proves substrate-specific reconciliation. This work proves the same pattern on the compute substrate — prescribed in genesis, dispatched through modes, reconciled through the graph.

---

## What Does NOT Change

- `steps.rs` step implementations — all Tier 0–2 steps unchanged. ManifestStep and SenseActualityStep delegate to `ctx.manifest()` / `ctx.sense_actuality()` as they already do.
- `build.rs` — unchanged (generates dispatch table from mode entities; Mode Consolidation prompt handles the new cargo mode entities).
- `actuality_modes.rs` — unchanged by this prompt (Mode Consolidation creates the new entries).
- Genesis praxeis — `praxis/chora-dev/build` and related praxeis are already correctly prescribed. Their steps are valid.
- Generic primitives (`shell-execute`, `hash-path`, `parse-output`, `file-exists`) — unchanged. These are the foundation.

---

## Findings That Are Out of Scope

### Daemon-triggered builds

The chora-dev reflexes prescribe automatic rebuilds when source changes are detected (`reflex/chora-dev/detect-staleness`). The daemon `daemon/chora-dev-watcher` periodically senses file changes. Wiring these autonomous triggers is a separate concern — this prompt wires the manual invocation path first. Autonomous builds follow naturally once the manual path works.

### Test and lint praxeis

`praxis/chora-dev/test` and `praxis/chora-dev/lint` follow the same pattern as `build` — they use `step: manifest` with entities that have `actuality_mode: cargo-test` or `actuality_mode: cargo-clippy`. Once the template-driven pattern is proven for build, extending to test and lint is mechanical.

### scan-workspace

`praxis/chora-dev/scan-workspace` runs `cargo metadata` and creates source-crate entities. It's a prerequisite for build (build needs source-crate entities to exist). Implementing it requires the same `execute_command_template()` function. It should work once the template execution is implemented.

### Cross-crate dependency tracking

The build pipeline could track inter-crate dependencies and rebuild dependents when a crate changes. The bond graph supports this (`builds-into`, `compiled-from`), but the reconciliation logic in `reconcile-builds` needs the full dependency graph. Not blocking for the initial build path.

---

*Traces to: KOSMOGONIA V11 §Reconciler Pattern, PROMPT-MODE-CONSOLIDATION.md (Arc 5), T11 (reconciliation is substrate-universal)*
