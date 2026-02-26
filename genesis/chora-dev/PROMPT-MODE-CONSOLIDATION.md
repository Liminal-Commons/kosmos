# Mode Consolidation — Dissolving Pre-Unification Vestiges, Completing the Mode Graph

*Prompt for Claude Code in the chora + kosmos repository context.*

*Dissolves pre-Mode-Unification `actuality_modes:` sections from 4 manifests, creates proper unified mode entities for aither and chora-dev, removes vestigial `actuality-modes/` content paths, and cleans empty `stoicheia_form:` placeholders. After this work, every mode in the kosmos is a unified `eidos/mode` entity in a `modes/` directory — no shorthand, no vestiges, no pre-unification formats.*

---

## Architectural Principle — Every Mode Is an Entity

KOSMOGONIA §Mode Pattern: a mode is how existence becomes actuality on a substrate. Mode Unification (Arc 1) introduced `eidos/mode` with a `substrate` field, making this concrete — every mode is a graph entity with operations, traversable via `gather(eidos: mode)`, bondable via `uses-render-spec` and `requires-mode`.

Four manifests still describe modes as manifest shorthand — key/value pairs in a YAML section, not entities. This shorthand predates Mode Unification. It has no runtime representation in the graph. It can't be gathered, bonded, or traversed. It is a vestige of a format that was replaced.

The principle: if it's structural, it's an entity. Modes are structural. Therefore modes are entities.

---

## Methodology — Doc-Driven, Test-Driven

The cycle: **Doc → Test → Build → Align → Track**.

1. **Doc**: Read `docs/reference/presentation/mode-reference.md`. Verify it describes the unified mode schema (it does — Arc 1 updated it). No new reference doc needed — the existing one already prescribes the target state.
2. **Test**: Write a bootstrap test asserting all 20 mode entities load and the dispatch table has the expected entries. This test should fail before implementation (cargo modes don't exist yet).
3. **Build**: Create mode entities, edit manifests, delete vestiges.
4. **Align**: Check `docs/REGISTRY.md` Impact Map for stale docs. Update any that reference `actuality_modes:` manifest sections.

---

## Prerequisite: Understand the Mode Unification

Three topoi already have proper unified mode entities:

| Topos | File | Modes | Status |
|-------|------|-------|--------|
| dynamis | `genesis/dynamis/modes/dynamis.yaml` | 9 infrastructure modes (storage×3, compute×4, DNS, network) | Unified |
| thyra | `genesis/thyra/modes/screen.yaml` | 6 screen modes | Unified |
| soma | `genesis/soma/modes/voice.yaml` | 1 compute mode (handler-based) | Unified |

Four manifests still have pre-unification `actuality_modes:` sections — shorthand declarations that were never migrated to proper entities. Two manifests declare `actuality-modes/` content paths for directories that contain no entities.

---

## Current State — The Four Vestiges

### 1. Aither (`genesis/aither/manifest.yaml`, lines 141–152)

```yaml
stoicheia_form:
  manifest: arche       # Routes to webrtc dynamis
  sense_actuality: arche
  unmanifest: arche
  signal: arche

actuality_modes:
  webrtc:
    manifest: create_peer_connection
    sense: connection_state
    unmanifest: close_connection
    signal: sdp_exchange
```

**Problem**: Pre-unification format. No `genesis/aither/modes/` directory exists. No `eidos: mode` entities.

**Target**: Create `genesis/aither/modes/webrtc.yaml` with a unified `mode/webrtc-livekit` entity. Add `modes/` content path to manifest. Delete `actuality_modes:` and `stoicheia_form:` sections.

### 2. Chora-dev (`genesis/chora-dev/manifest.yaml`, lines 147–177)

```yaml
actuality_modes:
  cargo-build:
    mode: cargo-build
    description: "Compile Rust crate via cargo build"
    manifest_stoicheion: cargo-build-run
    sense_stoicheion: cargo-build-sense
    unmanifest_stoicheion: cargo-clean
  cargo-test:
    mode: cargo-test
    description: "Run tests via cargo test"
    manifest_stoicheion: cargo-test-run
    sense_stoicheion: cargo-test-sense
  cargo-clippy:
    mode: cargo-clippy
    description: "Run lints via cargo clippy"
    manifest_stoicheion: cargo-clippy-run
    sense_stoicheion: cargo-clippy-sense

stoicheia_form:
  scan-workspace: arche
  build: arche
  ...
```

**Problem**: Three modes declared as manifest shorthand, not as entities. The `stoicheia_form:` section lists all praxeis as `arche` — accurate but has no runtime effect.

**Target**: Create `genesis/chora-dev/modes/compute.yaml` with three unified mode entities (`mode/cargo-build`, `mode/cargo-test`, `mode/cargo-clippy`). These use the `stoicheion` pattern (not `handler`) — build.rs will generate dispatch. Add `modes/` content path to manifest. Delete both sections.

### 3. Dynamis (`genesis/dynamis/manifest.yaml`, lines 146–160)

```yaml
actuality_modes:
  deployment:
    mode: process
    description: "Deployments actualize as running processes or services"

stoicheia_form:
  create-substrate: arche
  ...
```

**Problem**: Single-entry vestige — dynamis already has 9 proper mode entities in `genesis/dynamis/modes/dynamis.yaml`. The `deployment` entry is already expressed by deployment entities having `actuality_mode: process` in their data.

**Target**: Delete `actuality_modes:` section. Delete `stoicheia_form:` section. Remove `actuality-modes/` from `content_paths`.

### 4. Stoicheia-portable (`genesis/stoicheia-portable/manifest.yaml`, lines 117–122)

```yaml
actuality_modes:
  wasm:
    compile_at: bootstrap
    runtime: wasmtime
    fuel_limit: 10000000
```

**Problem**: Structurally different. Describes WASM execution configuration, not an entity-backed mode. The WASM runtime is an interpreter subsystem, not a mode in the unified sense.

**Target**: Rename `actuality_modes:` to `wasm_runtime:` to disambiguate from unified modes. Content stays — it's legitimate configuration.

### Vestigial Content Paths

Two manifests declare `actuality-modes/` content paths for directories that contain no entities:

| Manifest | Target |
|----------|--------|
| `genesis/dynamis/manifest.yaml` | Delete `actuality-modes/` content path entry |
| `genesis/thyra/manifest.yaml` (if present) | Delete `actuality-modes/` content path entry |

---

## Design — New Mode Entities

### Aither: `genesis/aither/modes/webrtc.yaml`

Aither's WebRTC operations don't have Rust stoicheion implementations yet — the WebRTC substrate is prescribed but not actualized. Use `handler` pattern (like soma/voice) since WebRTC operations will need hand-wired Rust when implemented:

```yaml
# Aither WebRTC Mode — Network substrate via LiveKit
#
# Peer connection lifecycle: manifest creates connections,
# sense queries state, unmanifest closes them. Signal handles
# SDP/ICE exchange. The handler pattern is used because WebRTC
# operations are complex multi-step flows that need hand-wired
# Rust, not simple stoicheion dispatch.
#
# The signal operation is unique to aither — it extends the
# standard manifest/sense/unmanifest trio with protocol-specific
# exchange.

entities:

  - eidos: mode
    id: mode/webrtc-livekit
    data:
      name: webrtc
      topos: aither
      substrate: network
      provider: livekit
      description: |
        P2P network transport via LiveKit WebRTC.
        Manages peer connections, data channels, and signaling.
      requires_dynamis:
        - webrtc.manifest
        - webrtc.sense
        - webrtc.unmanifest
        - webrtc.signal
      operations:
        manifest:
          handler: livekit::create_peer_connection
          params:
            - room_id
            - peer_id
            - ice_servers
          returns:
            session_handle: string
            connection_state: string
          description: Create WebRTC peer connection via LiveKit
        sense:
          handler: livekit::connection_state
          params:
            - session_handle
          returns:
            connection_state: string
            ice_state: string
            data_channels: number
          description: Query WebRTC connection state
        unmanifest:
          handler: livekit::close_connection
          params:
            - session_handle
          description: Close WebRTC peer connection
        signal:
          handler: livekit::sdp_exchange
          params:
            - session_handle
            - signal_type
            - payload
          returns:
            response_type: string
            response_payload: string
          description: SDP/ICE signaling exchange
```

**Note**: The `signal` operation extends the standard manifest/sense/unmanifest trio. This is the same pattern as soma/voice's `push_fragment` and `clarify` operations — modes can define custom operations beyond the standard three.

### Chora-dev: `genesis/chora-dev/modes/compute.yaml`

Chora-dev's cargo operations use the `stoicheion` pattern — build.rs will generate dispatch entries for these. The stoicheia (`cargo-build-run`, `cargo-build-sense`, etc.) are already declared in the manifest's `provides.stoicheia` list:

```yaml
# Chora-Dev Compute Modes — Cargo operations as substrate modes
#
# Three modes for Rust development: build, test, lint.
# All use stoicheion dispatch — build.rs generates the dispatch table.
# The stoicheia themselves are implemented in steps.rs (shell-execute
# based, using cargo command templates from genesis entities).
#
# These modes are referenced by build-target, test-run, and lint-run
# entities via actuality_mode field in their data.

entities:

  - eidos: mode
    id: mode/cargo-build
    data:
      name: cargo-build
      topos: chora-dev
      substrate: compute
      provider: local
      description: |
        Compile a Rust crate via cargo build.
        Manifest spawns the build process, sense checks if
        the artifact exists and is fresh, unmanifest runs cargo clean.
      operations:
        manifest:
          stoicheion: cargo-build-run
          params:
            - crate_path
            - profile
            - features
          returns:
            success: boolean
            artifact_path: string
            content_hash: string
            duration_ms: number
            error: string
          description: Run cargo build for a crate
        sense:
          stoicheion: cargo-build-sense
          params:
            - crate_path
            - profile
          returns:
            exists: boolean
            is_fresh: boolean
            artifact_path: string
            content_hash: string
          description: Check if build artifact exists and is fresh
        unmanifest:
          stoicheion: cargo-clean
          params:
            - crate_path
            - profile
          description: Clean build artifacts for a crate

  - eidos: mode
    id: mode/cargo-test
    data:
      name: cargo-test
      topos: chora-dev
      substrate: compute
      provider: local
      description: |
        Run Rust tests via cargo test.
        Manifest runs the test suite, sense checks last result.
      operations:
        manifest:
          stoicheion: cargo-test-run
          params:
            - crate_path
            - test_filter
            - features
          returns:
            success: boolean
            passed: number
            failed: number
            ignored: number
            duration_ms: number
            output: string
          description: Run cargo test for a crate
        sense:
          stoicheion: cargo-test-sense
          params:
            - crate_path
          returns:
            last_run_at: timestamp
            last_result: string
            passed: number
            failed: number
          description: Check last test run status

  - eidos: mode
    id: mode/cargo-clippy
    data:
      name: cargo-clippy
      topos: chora-dev
      substrate: compute
      provider: local
      description: |
        Run Rust lints via cargo clippy.
        Manifest runs clippy, sense checks last result.
      operations:
        manifest:
          stoicheion: cargo-clippy-run
          params:
            - crate_path
            - features
          returns:
            success: boolean
            warnings: number
            errors: number
            output: string
            duration_ms: number
          description: Run cargo clippy for a crate
        sense:
          stoicheion: cargo-clippy-sense
          params:
            - crate_path
          returns:
            last_run_at: timestamp
            warnings: number
            errors: number
          description: Check last clippy run status
```

### Build System Impact

`build.rs` reads `genesis/*/modes/*.yaml` for non-screen substrates with `stoicheion` dispatch and generates `actuality_modes.rs`. After this work:

**New entries in `actuality_modes.rs`** (from chora-dev modes):

| Mode | Provider | Manifest | Sense | Unmanifest |
|------|----------|----------|-------|------------|
| `cargo-build` | `local` | `cargo-build-run` | `cargo-build-sense` | `cargo-clean` |
| `cargo-test` | `local` | `cargo-test-run` | `cargo-test-sense` | (none) |
| `cargo-clippy` | `local` | `cargo-clippy-run` | `cargo-clippy-sense` | (none) |

**No new entries from aither** — handler-based modes are skipped by build.rs (same as soma/voice).

**Existing entries unchanged** — dynamis modes already generate from `genesis/dynamis/modes/dynamis.yaml`.

---

## Implementation Order

### Step 1: Doc — Verify reference doc describes target state

Read `docs/reference/presentation/mode-reference.md`. Confirm it describes the unified `eidos/mode` schema with `substrate`, `operations`, `stoicheion`/`handler` patterns. If it doesn't mention that all modes across all topoi are entities in `modes/` directories, add a sentence stating this.

### Step 2: Test — Write bootstrap test for mode entities

Create a test in `crates/kosmos/tests/` that bootstraps genesis and asserts:

1. `gather(eidos: mode)` returns exactly 20 entities (thyra 6 + dynamis 9 + soma 1 + aither 1 + chora-dev 3)
2. `mode/cargo-build` entity exists with `substrate: compute`, `provider: local`
3. `mode/webrtc-livekit` entity exists with `substrate: network`, `provider: livekit`
4. `actuality_stoicheion("cargo-build", "local", Manifest)` returns `Some("cargo-build-run")`

This test should **fail** before Step 3 (no aither or chora-dev mode entities exist yet).

### Step 3: Build — Create aither modes directory and entity

Create `genesis/aither/modes/webrtc.yaml` with the `mode/webrtc-livekit` entity as specified in Design.

### Step 4: Build — Create chora-dev modes directory and entities

Create `genesis/chora-dev/modes/compute.yaml` with three mode entities as specified in Design.

### Step 5: Build — Update aither manifest

In `genesis/aither/manifest.yaml`:

1. Add `modes/` content path:
```yaml
  - path: modes/
    content_types: [mode]
```

2. Delete `stoicheia_form:` section (lines 141–145)
3. Delete `actuality_modes:` section (lines 147–152)

### Step 6: Build — Update chora-dev manifest

In `genesis/chora-dev/manifest.yaml`:

1. Add `modes/` content path:
```yaml
  - path: modes/
    content_types: [mode]
```

2. Delete `actuality_modes:` section (lines 147–166)
3. Delete `stoicheia_form:` section (lines 167–177)

### Step 7: Build — Clean dynamis manifest

In `genesis/dynamis/manifest.yaml`:

1. Delete `actuality_modes:` section (lines 146–149)
2. Delete `stoicheia_form:` section (lines 151–160)
3. Remove `actuality-modes/` content path entry (line 55–56)

### Step 8: Build — Rename stoicheia-portable section

In `genesis/stoicheia-portable/manifest.yaml`:

1. Rename `actuality_modes:` to `wasm_runtime:` (line 117)

### Step 9: Build — Check thyra manifest for vestigial content paths

In `genesis/thyra/manifest.yaml`, check for and remove any `actuality-modes/` content path entry.

### Step 10: Test — Verify tests pass

```bash
# Rebuild — build.rs reads new mode entities
cargo build -p kosmos 2>&1

# Inspect generated dispatch table
cat crates/kosmos/src/actuality_modes.rs
# Expected: existing 8 modes + 3 new cargo modes = 11 mode/provider pairs

# All tests pass (including the new mode entity test from Step 2)
cargo test -p kosmos --lib --tests 2>&1
```

### Step 11: Verify — No vestiges remain

```bash
# No actuality_modes: sections in manifests
rg 'actuality_modes:' genesis/*/manifest.yaml
# Expected: zero results (stoicheia-portable renamed to wasm_runtime:)

# No actuality-modes content paths
rg 'actuality-mode' genesis/*/manifest.yaml
# Expected: zero results

# No stoicheia_form: sections
rg 'stoicheia_form:' genesis/*/manifest.yaml
# Expected: zero results

# All modes are unified entities
rg 'eidos: mode' genesis/*/modes/
# Expected: dynamis (9), thyra (6), soma (1), aither (1), chora-dev (3) = 20 modes

# Mode entities exist in modes/ directories only
ls genesis/*/modes/
# Expected: aither, chora-dev, dynamis, soma, thyra
```

### Step 12: Align — Update stale docs

Check `docs/REGISTRY.md` Impact Map. Search docs for references to `actuality_modes:` manifest sections and update them.

---

## What This Enables

- **Complete mode graph**: Every mode in the kosmos is a unified `eidos/mode` entity — traversable, queryable, cacheable. `gather(eidos: mode)` returns all 20 modes.
- **Build.rs consolidation**: build.rs reads from one pattern (`genesis/*/modes/*.yaml`) — no special cases for manifest shorthand.
- **Aither manifest cleaned**: The longest-standing vestige is resolved. When WebRTC handlers are implemented, they connect to the mode entity directly.
- **Chora-dev actualization ready**: The three cargo modes generate dispatch entries, enabling `praxis/chora-dev/build` to use `step: manifest` with mode dispatch.
- **Graph-traversable development tools**: `trace(from: mode/cargo-build, desmos: belongs-to-topos)` reveals the tooling topology.

---

## What Does NOT Change

- `build.rs` reading logic — already reads `genesis/*/modes/*.yaml` for stoicheion dispatch generation. New entities are just more files to read.
- `actuality_modes.rs` structure — same generated match table, just more entries.
- `host.manifest()` / `host.sense_actuality()` — unchanged. Dispatch through `resolve_actuality_mode()` → `actuality_stoicheion()`.
- All existing mode entities (dynamis, thyra, soma) — unchanged.
- `eidos/mode` definition — unchanged.
- `mode-reference.md` — unchanged (already describes unified schema).

---

## Findings That Are Out of Scope

### Stoicheia-portable WASM execution model

The `wasm_runtime:` configuration (formerly `actuality_modes:`) describes how WASM modules execute. This is an interpreter subsystem configuration, not a mode in the unified sense. Whether WASM execution should eventually be modeled as a unified `eidos/mode` entity with `substrate: wasm` is an architectural question — it works today as configuration, and forcing it into the mode framework would be over-fitting.

### Aither stoicheion handler implementations

The `mode/webrtc-livekit` entity declares handlers (`livekit::create_peer_connection`, etc.) that don't have Rust implementations yet. Implementing them is WebRTC substrate work, not mode consolidation. The mode entity is correctly shaped — when implementations arrive, they plug in.

### Cargo stoicheion implementations

The three chora-dev modes reference stoicheia (`cargo-build-run`, etc.) that need Rust implementations in `steps.rs` or `host.rs`. The `manifest_by_stoicheion()` dispatch in `host.rs` needs new match arms for these stoicheia. This is actualization work (PROMPT-ACTUALIZATION-CARGO.md).

### Empty `stoicheia_form:` sections in other manifests

~15 other manifests have empty `stoicheia_form:` sections (just comments or empty dicts). These are harmless placeholders but could be cleaned for consistency. Not blocking — cosmetic.

---

*Traces to: KOSMOGONIA V11 §Mode Pattern, PROMPT-MODE-UNIFICATION.md (Arc 1), PROMPT-AUTONOMIC-TRIAD.md (Arc 4)*
