# Actualization Pattern

*The invariant cycle by which existence is reconciled with actuality.*

**Status: PRESCRIPTIVE** — Documents the complete actualization pattern across all substrates. Mode catalog enumerates all 19 modes (5 thyra + 14 dynamis). Target completion matrix declares every dynamis mode at stage 6, every thyra mode at stage 5. Modes not yet at target have gaps noted. Inference substrate currently has only interpreter-driven invocation; lifecycle operations deferred.

---

## 1. Two Modes of Being

The KOSMOGONIA establishes two independent modes of being:

| Mode | Greek | What It Answers |
|------|-------|-----------------|
| **Existence** | ὕπαρξις (hyparxis) | "Is there an entity?" — graph state, the entity record |
| **Actuality** | ἐνέργεια (energeia) | "Is the phenomenon happening?" — the living process, the stored file, the reachable endpoint |

An entity can exist without being actual. A deployment entity with `desired_state: running` **exists** in the graph — intent has been committed to existence. But a process is not yet running in the substrate. Existence declares what should be; actuality is what IS in the substrate.

The actualization cycle bridges these two modes of being. It does not transform intent into actuality — it **reconciles** actuality with existence. Existence and actuality are independent; the reconciler works to bring them into alignment.

## 2. The Actualization Cycle

The cycle has three moments:

1. **Manifest** (γένεσις) — Bring actuality into conformance with existence. Make the phenomenon real.
2. **Sense** (αἴσθησις) — Discover whether actuality conforms to existence. Observe what is.
3. **Reconcile** (φύλαξ) — Compare existence with sensed actuality. Act to correct any drift.

The cycle is **invariant** — it applies identically regardless of what is being actualized: a running process, a stored file, a DNS record, a visible widget.

```
              EXISTENCE (graph)               ACTUALITY (substrate)
              ┌──────────────┐                ┌──────────────┐
              │ desired_state│                │  phenomenon  │
              │   = running  │                │  (process,   │
              │              │                │   file, DNS) │
              └──────┬───────┘                └──────┬───────┘
                     │                               │
                     └──────── reconcile ─────────────┘
                                  │
                          sense ←─┤─→ manifest
                                  │    or unmanifest
```

What varies is the **mode**: the specific binding of substrate, provider, and operations that determines how manifest/sense/reconcile execute for a given entity class. The pattern is one; the modes are many.

### Two Trigger Paths

The cycle is initiated through two complementary paths:

**Sympathetic (event-driven):** A reflex fires when entity data changes, triggering immediate reconciliation. Fast response to graph mutations.

**Parasympathetic (poll-based):** A daemon periodically invokes reconciliation, detecting external drift that produced no graph mutation. The background metabolism that enables self-healing.

Both paths feed into the same `host.reconcile(reconciler_id, entity_id)` engine.

### See Also

- [Reconciler Pattern](../../explanation/reactivity/reconciler-pattern.md) — Conceptual motivation: why separate intent from actuality
- [Reactive System](../../explanation/reactivity/reactive-system.md) — The three-layer architecture: reflex → reconciler → mode

---

## 3. Ontological Vocabulary

| Term | Greek | Definition | Example |
|------|-------|------------|---------|
| **Substrate** | ὑποκείμενον | A dynamis capability through which existence becomes actual | `compute`, `storage`, `network`, `credential`, `media`, `inference` |
| **Provider** | — | A specific implementation within a substrate | `local`, `docker`, `r2`, `cloudflare`, `livekit`, `anthropic`, `openai` |
| **Mode** | — | The atom of variation. Dynamis modes bind substrate × provider × operations. Thyra modes bind spatial position × render-spec | `mode/process-local`, `mode/phasis-feed` |
| **Stoicheion** | στοιχεῖον | The atomic operation that a mode dispatches to — the concrete implementation of one operation | `spawn-process`, `cargo-build-run`, `r2-put-object` |
| **Reconciler** | φύλαξ | An entity that drives the sense-compare-act cycle for a class of entities | `reconciler/deployment` watches `eidos: deployment` |
| **Reflex** | — | An event trigger that initiates reconciliation (sympathetic) | `reflex/deployment-intent-changed` fires on `entity_updated` |
| **Daemon** | — | A periodic trigger that initiates reconciliation (parasympathetic) | Health check daemon runs every 30s |

### Two Kinds of Mode

Modes split into two categories aligned with the Kosmogonia:

**Dynamis modes** draw on substrate capability — they extend kosmos into external systems via stoicheion dispatch. A running process is a dynamis mode (substrate: compute). A stored file is a dynamis mode (substrate: storage). A DNS record is a dynamis mode (substrate: network). They have `operations:` with `stoicheion:` names, and `build.rs` generates dispatch tables for them.

**Thyra modes** open the door (θύρα) between kosmos and perception — they project kosmos state into spatial positions via reactive rendering. A visible widget tree is a thyra mode. They have `spatial:` and `render_spec_id:` / `item_spec_id:` / `sections:`, no `substrate` field, no `operations:` block. The layout engine renders them reactively through SolidJS; no stoicheion dispatch is needed.

---

## 4. Mode Entity Schema

All modes share `eidos: mode`. The schema splits into thyra fields and dynamis fields.

```yaml
- eidos: mode
  id: mode/<name>
  data:
    # ── Common fields (all modes) ──
    name: <string>                  # Required — mode name
    topos: <string>                 # Required — owning topos
    description: <string>           # Optional
    requires:                       # Optional — other mode IDs this needs active
      - <mode-id>

    # ── Thyra fields (presentation modes — no substrate) ──
    spatial:                        # Required for thyra modes
      position: <string>            # left, center, right, top, bottom
      height: <string|number>       # fill, <pixels>, auto
    render_spec_id: <string>        # Singleton pattern
    source_entity_id: <string>      # Singleton: entity to bind
    item_spec_id: <string>          # Collection pattern: spec per item
    source_query: <string>          # Collection/Compound: gather query
    arrangement: <string>           # stack, scroll, scroll-bottom
    chrome_spec_id: <string>        # Optional wrapper
    empty_message: <string>         # Shown when 0 results
    sections: [...]                 # Compound pattern: multiple sections
    config: <object>                # Mode-specific config

    # ── Dynamis fields (substrate modes) ──
    substrate: <string>             # Required for dynamis modes — compute, storage, network, credential, media
    provider: <string>              # Optional, default "local"
    operations:                     # Required for dynamis modes
      manifest:
        stoicheion: <string>        # Dispatch address
        params: [...]
        returns: {...}
        description: <string>
      sense:
        stoicheion: <string>
        params: [...]
        returns: {...}
        description: <string>
      unmanifest:                   # Optional — some modes have no cleanup
        stoicheion: <string>
        params: [...]
        description: <string>
    config_schema: <object>         # Optional — declares required config
    requires_dynamis: [<string>]    # Optional — dynamis capabilities needed
```

### See Also

- [Mode Reference](../presentation/mode-reference.md) — Thyra mode details: widget trees, data bindings, spatial positions, render-spec schema

---

## 5. Substrate Taxonomy

Six dynamis substrates — the complete taxonomy of capabilities the kosmos draws upon. For the Rust module contract and integration details, see [substrate-integration.md](../infrastructure/substrate-integration.md).

Thyra modes (presentation) are not substrates — they are the door (θύρα) between kosmos and perception. See [Mode Reference](../presentation/mode-reference.md) for thyra mode details.

| Substrate | ὑποκείμενον | What It Is | Actuality | Providers |
|-----------|-------------|------------|---------------|-----------|
| **compute** | process | How entities become running processes or command results | OS process table, cargo, containers | local, docker, systemd, nixos |
| **storage** | data | How entities become persistent objects | Filesystem, R2, S3 | local, r2, s3 |
| **network** | connectivity | How entities become reachable endpoints | DNS providers, WebRTC | cloudflare, route53, livekit |
| **credential** | trust | How identity and secrets are established and maintained | OS Keychain, env vars | macos-keychain, environment |
| **media** | perception | How capture devices and real-time streams operate | Audio capture, transcription | whisper, local |
| **inference** | understanding | How entities access LLM inference and embedding | Provider APIs (Anthropic, OpenAI) | anthropic, openai |

### Compute

Entities become running processes or command execution results. Operations vary by provider:

- **local** — Spawn OS processes via `process.rs`, sense via `kill(pid, 0)` + `waitpid`
- **docker** — Container lifecycle via Docker CLI (`docker run/inspect/stop`)
- **systemd** — Systemd unit management via `systemctl` (`enable --now/is-active/disable --now`)
- **nixos** — NixOS module generation + `nixos-rebuild switch`, sense via systemd

The chora-dev topos extends compute with cargo-specific modes that use command template entities for homoiconic tool integration.

### Storage

Entities become persistent objects on disk or cloud storage. `storage.rs` is the facade:

- **local** — Filesystem read/write via `std::fs` with BLAKE3 content hashing
- **r2** — Cloudflare R2 object storage via `r2.rs` (S3-compatible auth with AWS Signature V4)
- **s3** — AWS S3-compatible storage (parameterized R2 via `ObjectStorageProvider`)

### Network

Entities become reachable endpoints:

- **cloudflare** — DNS record management via Cloudflare API (`dns.rs` has full implementation)
- **route53** — AWS Route53 (planned)
- **manual** — Documentation only, no actuality operations

### Credential

Identity, keys, and secrets have a real actualization cycle (unlock=manifest, store=manifest, retrieve=sense, list=sense, lock=unmanifest). The `credential.rs` module also provides `resolve_credential()` — the standard way for other substrate modules to access external API credentials.

### Media

Capture devices and real-time streams:

- **whisper/local** — Voice transcription via `voice.rs` (stoicheion-dispatched: `voice-start-stream`, `voice-sense-stream`, `voice-stop-stream`)
- **livekit** — WebRTC peer connections via `livekit.rs` (stoicheion-dispatched: `lk-join-room`, `lk-sense-connection`, `lk-leave-room`)

### Inference

LLM inference and embedding via external provider APIs. Currently accessed through **interpreter-driven invocation** only — `InferStep` and `EmbedStep` in the interpreter read provider entities from the graph to determine endpoint, auth, and request format:

- **anthropic** — Claude model family via `nous.rs`. Auth: `x-api-key` header. System prompt as top-level field. Model tiers: opus (capable), sonnet (balanced), haiku (fast).
- **openai** — GPT and embedding models via `nous.rs`. Auth: `Authorization: Bearer`. System prompt in messages array. Model tiers: o-series (capable), gpt-4o (balanced), mini (fast).

The novel contribution is the **provider entity pattern**: `provider/{name}` entities carry `credential_config`, `inference_config`, `embedding_config`, and `models_config` — adding a provider means adding a genesis entity, not changing code. The same invocation context (interpreter step → host method → module) is used by compute's `CommandStep` → `execute_command_template()`. Inference lifecycle operations (provider availability sensing, connection warmup) are deferred — when they arrive, inference will gain stoicheion-dispatched operations alongside its interpreter-driven invocation.

---

## 6. Mode Catalog

All 17 modes across 5 genesis topoi.

### Thyra Modes (presentation)

Source: `genesis/thyra/modes/screen.yaml`

| Mode | Topos | Pattern | Position | Status | Stage |
|------|-------|---------|----------|--------|-------|
| `mode/compose-full` | thyra | singleton | bottom | Render-spec driven | 5 (Reactive) |
| `mode/compose-transcribing` | thyra | singleton | bottom | Render-spec driven | 5 (Reactive) |
| `mode/oikos-nav` | politeia | collection | left | Render-spec driven | 5 (Reactive) |
| `mode/theoria-sidebar` | nous | collection | right | Render-spec driven | 5 (Reactive) |
| `mode/phasis-feed` | logos | collection | center | Render-spec driven, scroll-bottom | 5 (Reactive) |

### Compute Modes — Cargo (substrate: compute, provider: local)

Source: `genesis/chora-dev/modes/compute.yaml`

| Mode | Manifest | Sense | Unmanifest | Stage | Next Step |
|------|----------|-------|------------|-------|-----------|
| `mode/cargo-build` | `cargo-build-run` | `cargo-build-sense` | `cargo-clean` | 3 (Implement) | Compose: typos that produce build-target entities |
| `mode/cargo-test` | `cargo-test-run` | `cargo-test-sense` | *(none)* | 3 (Implement) | Compose: typos that produce test-run entities |
| `mode/cargo-clippy` | `cargo-clippy-run` | `cargo-clippy-sense` | *(none)* | 3 (Implement) | Compose: typos that produce lint-run entities |

Implementation: `host.rs:execute_command_template()` reads command-template entities from the graph, interpolates args, shell-executes. Sense uses `sense_build_artifact()` (file existence + BLAKE3 hash) for builds, `sense_run_status()` (last-run entity data) for test/lint.

See: [Command Template Execution](../infrastructure/command-template-execution.md) for the template interpolation pattern.

### Compute Modes — Process (substrate: compute)

Source: `genesis/dynamis/modes/dynamis.yaml`

| Mode | Provider | Manifest | Sense | Unmanifest | Stage | Notes |
|------|----------|----------|-------|------------|-------|-------|
| `mode/process-local` | local | `spawn-process` | `check-process` | `kill-process` | 6 (React) | All operations real, reflex + reconciler + daemon proven |
| `mode/process-docker` | docker | `docker-run` | `docker-inspect` | `docker-stop` | 6 (React) | Docker CLI, reflex + reconciler + daemon proven |
| `mode/process-nixos` | nixos | `nixos-activate` | `systemctl-status` | `nixos-deactivate` | 6 (React) | NixOS module generation, systemctl sensing |
| `mode/process-systemd` | systemd | `systemd-enable` | `systemctl-status` | `systemd-disable` | 6 (React) | systemctl lifecycle, reflex + reconciler + daemon proven |

Note: `process-nixos` and `process-systemd` share the `systemctl-status` sense stoicheion (NixOS services are systemd units).

All four process providers dispatch through `process.rs` with the standard `execute_operation(operation, entity_id, data, session)` contract. Each returns `_entity_update` for state reconciliation.

Implementation details:
- **local**: `std::process::Command::spawn()` → PID, `libc::waitpid(WNOHANG)` → running/stopped, `libc::kill(signal)` → SIGTERM
- **docker**: `docker run -d` → container ID, `docker inspect --format '{{.State.Running}}'` → true/false, `docker stop` + `docker rm`
- **systemd**: `systemctl enable --now` → unit name, `systemctl is-active` → active/inactive, `systemctl disable --now`
- **nixos**: NixOS module generation + `nixos-rebuild switch`, sense delegates to systemd, kill writes disable config + rebuild

### Media Modes — Voice (substrate: media)

Source: `genesis/soma/modes/voice.yaml`

| Mode | Provider | Manifest | Sense | Unmanifest | Stage |
|------|----------|----------|-------|------------|-------|
| `mode/voice` | local | `voice-start-stream` | `voice-sense-stream` | `voice-stop-stream` | 6 (React) |

Stoicheion-dispatched. Content operations (append-fragment, clarify) are praxeis invoked by transcription callbacks, not lifecycle operations. Requires dynamis capabilities: `audio-capture`, `transcription`.

### Storage Modes (substrate: storage)

Source: `genesis/dynamis/modes/dynamis.yaml`

| Mode | Provider | Manifest | Sense | Unmanifest | Stage | Next Step |
|------|----------|----------|-------|------------|-------|-----------|
| `mode/object-storage-r2` | r2 | `r2-put-object` | `r2-head-object` | `r2-delete-object` | 3 (Implement) | Compose: typos that produce storage entities with `mode: object-storage, provider: r2` |
| `mode/object-storage-s3` | s3 | `s3-put-object` | `s3-head-object` | `s3-delete-object` | 2 (Dispatch) | Implement: S3 SDK calls in match arms |
| `mode/object-storage-local` | local | `fs-write-file` | `fs-stat-file` | `fs-delete-file` | 3 (Implement) | Compose: typos that produce storage entities with `mode: object-storage, provider: local` |

Implementation: R2 delegates to `r2::execute_operation_with_session()` (S3-compatible auth with AWS Signature V4, credential resolution via session bridge or env vars). Local uses `std::fs` operations with BLAKE3 content hashing for integrity. The legacy eidos-specific `release-artifact` handler remains as an alternative R2 entry point.

### Network Modes (substrate: network)

Source: `genesis/dynamis/modes/dynamis.yaml`, `genesis/aither/modes/webrtc.yaml`

| Mode | Provider | Manifest | Sense | Unmanifest | Stage | Next Step |
|------|----------|----------|-------|------------|-------|-----------|
| `mode/dns-cloudflare` | cloudflare | `cf-create-record` | `cf-get-record` | `cf-delete-record` | 2 (Dispatch) | Implement: wire existing `dns.rs` through stoicheion dispatch |
| `mode/webrtc-livekit` | livekit | `lk-join-room` | `lk-sense-connection` | `lk-leave-room` | 6 (React) | — |

Note: DNS has implementation in `dns.rs` via legacy eidos-specific handler for `dns-record` entities. Same gap as R2: existing code bypasses generic dispatch.

---

## 7. Completion Stages

### Dynamis Modes (compute, storage, network, credential, media)

Note: The inference substrate currently has only interpreter-driven invocation — it has no mode entities or lifecycle operations yet. See Section 5, Inference.

| Stage | Name | Criterion | Example |
|-------|------|-----------|---------|
| 1 | **Prescribe** | Mode entity exists in genesis YAML with operations defined | `mode/voice` has YAML, no dispatch |
| 2 | **Dispatch** | `build.rs` generates dispatch table entry; `stoicheion_for_mode()` returns a stoicheion name | All dynamis modes dispatch through generated table |
| 3 | **Implement** | `manifest_by_stoicheion()` / `sense_by_stoicheion()` match arms execute real logic via `dispatch_to_module` | `mode/process-local` spawns real OS processes |
| 4 | **Compose** | Typos produce entities with `mode`/`provider` fields; praxeis invoke manifest/sense | Build-target entities carry `mode: cargo-build` |
| 5 | **Sense** | Sense stoicheion queries actual substrate state (not just returning last-known from entity data) | `check-process` calls `waitpid`/`kill(0)` to query OS |
| 6 | **React** | Reflexes fire on state changes; reconciler drives corrections autonomously | `reflex/deployment-intent-changed` triggers `reconciler/deployment` |

### Thyra Modes (presentation)

| Stage | Name | Criterion |
|-------|------|-----------|
| 1 | **Prescribe** | Mode entity exists with `render_spec_id` or `item_spec_id` |
| 2 | **Render** | Render-spec entity exists and renders correctly via interpreter |
| 3 | **Compose** | Mode is referenced by thyra configuration entity |
| 4 | **Active** | Mode can be activated/deactivated; layout engine responds |
| 5 | **Reactive** | Mode switches trigger reflexes; state changes propagate |

### Target Completion Matrix

Every dynamis mode targets stage 6 (React). Thyra modes target stage 5 (Reactive). Modes below their target have gaps noted.

| Mode | Target | Status | Notes |
|------|--------|--------|-------|
| *Thyra (5 modes)* | 5 | Aligned | All thyra modes are fully reactive |
| `mode/cargo-build` | 6 | Aligned | Template-driven, desired_state + _entity_update + transition-table reconciler |
| `mode/cargo-test` | 6 | Aligned | Template-driven, desired_state + _entity_update + transition-table reconciler |
| `mode/cargo-clippy` | 6 | Aligned | Template-driven, desired_state + _entity_update, no unmanifest by design |
| `mode/process-local` | 6 | Aligned | All operations real, reflex + reconciler + daemon proven |
| `mode/process-docker` | 6 | Aligned | Docker CLI, reflex + reconciler + daemon proven |
| `mode/process-nixos` | 6 | Aligned | NixOS module generation, systemctl sensing |
| `mode/process-systemd` | 6 | Aligned | systemctl lifecycle, reflex + reconciler + daemon proven |
| `mode/voice` | 6 | Aligned | Stoicheion-dispatched, reconciler + reflexes + daemon |
| `mode/object-storage-r2` | 6 | Aligned | _entity_update on all ops, reconciler/release-artifact reads _sensed.exists |
| `mode/object-storage-s3` | 6 | Aligned | Parameterized r2.rs (ObjectStorageProvider), AWS env vars |
| `mode/object-storage-local` | 6 | Aligned | _entity_update on write/stat/delete, dispatch_to_module uniform |
| `mode/dns-cloudflare` | 6 | Aligned | _entity_update on all ops, reconciler + reflexes + daemon |
| `mode/credential-keyring` | 6 | Aligned | keyring-store/check/revoke, reconciler + reflexes |
| `mode/webrtc-livekit` | 6 | Aligned | Stoicheion-dispatched, reconciler + reflexes + daemon |

---

## 8. Extension Pattern — Adding a New Mode

### Adding a Dynamis Mode

All dynamis modes are stoicheion-dispatched or handler-dispatched. The inference substrate has no mode entities yet — it currently has only interpreter-driven invocation (see Section 5, Inference). For stoicheion-dispatched modes, there is one path:

**Step 1: Create mode entity**

Add to `genesis/<topos>/modes/<substrate>.yaml`:

```yaml
entities:
  - eidos: mode
    id: mode/my-new-mode
    data:
      name: my-mode-name
      topos: my-topos
      substrate: compute  # or storage, network
      provider: local
      description: "What this mode does"
      operations:
        manifest:
          stoicheion: my-mode-run
          params: [param1, param2]
          returns:
            success: boolean
          description: "What manifest does"
        sense:
          stoicheion: my-mode-sense
          params: [handle]
          returns:
            running: boolean
          description: "What sense does"
        unmanifest:  # Optional — omit if no cleanup needed
          stoicheion: my-mode-clean
          params: [handle]
          description: "What unmanifest does"
```

**Step 2: Rebuild**

```bash
cargo build -p kosmos
```

`build.rs` scans `genesis/*/modes/*.yaml`, finds the new mode, generates dispatch table entries in `mode_dispatch.rs`. The stoicheion names now appear in `stoicheion_for_mode()`.

**Step 3: Implement match arms**

In `crates/kosmos/src/host.rs`, add match arms to:

- `manifest_by_stoicheion()` for `"my-mode-run"`
- `sense_by_stoicheion()` for `"my-mode-sense"`
- `unmanifest_by_stoicheion()` for `"my-mode-clean"` (if applicable)

**Step 4: Create entities that use the mode**

Either through typos or direct genesis entities, create entities with:

```yaml
data:
  mode: my-mode-name
  provider: local
```

**Step 5: Write tests**

Test in `crates/kosmos/tests/` using `workspace_path()` helper for genesis access.

---

## 9. Agent Configuration Surface

How an agent (Claude Code, MCP tool, governed generation) discovers, selects, and configures modes.

### Discover modes

```
# All modes in the kosmos
gather(eidos: mode)

# Dynamis modes (have substrate field)
gather(eidos: mode) where substrate = "compute"

# Thyra modes (have spatial field, no substrate)
gather(eidos: mode) where topos = "thyra"

# Filter by topos
gather(eidos: mode) where topos = "chora-dev"

# Filter by provider
gather(eidos: mode) where provider = "local"
```

### Check mode completeness

Read this reference doc's Mode Catalog (Section 6) and Completion Matrix (Section 7) to determine:

- Which modes exist (Stage 1+)
- Which modes have dispatch routing (Stage 2+)
- Which modes have real implementations (Stage 3+)
- Which modes are integrated end-to-end (Stage 4+)

### Configure a topos to use a mode

An entity opts into a mode by carrying `mode` and `provider` fields in its data:

```yaml
- eidos: deployment
  id: deployment/my-service
  data:
    desired_state: running
    mode: process          # Mode name
    provider: local        # Provider within mode
    config:
      command: "./my-server"
      args: ["--port", "8080"]
```

The reconciliation engine reads `mode` + `provider` from entity data, looks up the dispatch table via `stoicheion_for_mode()`, and routes to the correct implementation.

### Check dispatch table programmatically

```rust
use kosmos::mode_dispatch::{stoicheion_for_mode, ModeOperation, REGISTERED_MODES};

// List all registered mode/provider pairs
for (mode, provider) in REGISTERED_MODES {
    println!("{}/{}", mode, provider);
}

// Check if a specific mode is dispatched
let stoicheion = stoicheion_for_mode("process", "local", ModeOperation::Manifest);
// → Some("spawn-process")
```

### Add a new mode (agent workflow)

1. Read this doc's Extension Pattern (Section 8)
2. Choose stoicheion vs handler based on complexity
3. Create mode entity YAML
4. Rebuild to generate dispatch
5. Implement match arms (or handlers)
6. Test

---

## Implementation Locations

| File | Purpose |
|------|---------|
| `crates/kosmos/build.rs` | Scans `genesis/*/modes/*.yaml`, generates dispatch table |
| `crates/kosmos/src/mode_dispatch.rs` | Generated `stoicheion_for_mode()`, `REGISTERED_MODES`, `ModeDispatchInfo` |
| `crates/kosmos/src/host.rs` | `manifest()`, `sense_actuality()`, `unmanifest()` entry points; `manifest_by_stoicheion()`, `sense_by_stoicheion()`, `unmanifest_by_stoicheion()` match arms; `execute_command_template()` for cargo modes |
| `crates/kosmos/src/reflex.rs` | Reflex engine — sympathetic triggers |
| `crates/kosmos/src/daemon_loop.rs` | Daemon loop — parasympathetic triggers |
| `crates/kosmos/src/r2.rs` | R2 object storage implementation (legacy eidos-specific wiring) |
| `crates/kosmos/src/dns.rs` | Cloudflare DNS implementation (legacy eidos-specific wiring) |
| `crates/kosmos/src/phoreta.rs` | Federation transport types |
| `genesis/*/modes/*.yaml` | Mode entity definitions (ground truth) |
| `genesis/dynamis/reconcilers/dynamis.yaml` | Reconciler entity definitions |

---

## 10. Composition Reconciliation — The Fourth Loop

The actualization cycle (Sections 1–9) reconciles existence with actuality across external substrates. A fourth reconciliation loop operates entirely within the graph: **composition reconciliation**.

When an entity changes, all entities composed from it may be stale. The composition reconciliation cycle:

1. **Detect** — A reflex fires on `entity_updated`, discovering inbound `depends-on` bonds
2. **Compose again** — Invoke compose for each dependent (from stored `_composition_inputs`)
3. **Compare** — Compose is idempotent: hash the new data against the current content hash
4. **Update or stop** — If the hash differs, `update_entity()` fires `EntityUpdated` (cascade continues). If identical, no update (cascade terminates).

### Structural Guarantees

**DAG enforcement**: `depends-on` bonds form a directed acyclic graph. Composition is derivation — an entity's content is a function of its inputs. Circular derivation has no evaluation order and is rejected at composition time. The DAG structure makes infinite cascades impossible by construction.

**Content-addressed termination**: Same inputs → same hash → no update → cascade prunes early even in deep DAGs.

**Compose is idempotent**: First composition creates the entity (`arise_entity` → `EntityCreated`). Subsequent composition of an existing entity compares hashes and updates only if content changed (`update_entity` → `EntityUpdated`). There is no separate "recompose" operation — compose handles both γένεσις and μεταβολή by context, just as `manifest` handles both creation and confirmation.

### Relationship to Other Loops

| Loop | What It Reconciles | Substrate |
|------|-------------------|-----------|
| **Actuality** (dynamis) | Intent ↔ external phenomena | Compute, storage, network, credential, media, inference |
| **Generation** (manteia) | Expression → LLM → artifact | LLM inference |
| **Schema** | Authored content ↔ interpreter | Interpreter expectations |
| **Composition** | Composed entity ↔ source dependencies | Graph (intra-kosmos) |

The composition loop is uniquely intra-graph: both sides of the reconciliation live in the kosmos. No external substrate is consulted. This makes T3 operational — schema, graph, and cache working as one practice.

See: `genesis/chora-dev/PROMPT-COMPOSITION-RECONCILIATION.md` for the prescriptive implementation prompt.

---

*Traces to: KOSMOGONIA Two Modes of Being, T3 (three pillars as one practice), T5 (code is artifact), T8 (mode is topos presence), T11 (reconciliation is substrate-universal)*
