# Actualization Pattern — Documenting the Invariant Cycle

*Prompt for Claude Code in the chora + kosmos repository context.*

*The actualization cycle (manifest/sense/reconcile) is the invariant pattern by which kosmos intention becomes chora actuality. Mode is the atom of variation. This work fills a structural documentation gap: no single reference document describes the pattern as a whole. Fragments exist across five docs — reconciliation.md, reactive-system.md, reconciler-pattern.md, mode-reference.md, command-template-execution.md — but the unifying reference is missing. After this work, a single reference doc anchors the pattern, catalogs every mode, and defines the extension path for adding new modes.*

*This is pure DDD Phase 1 — documentation. No code changes.*

---

## Architectural Principle — The Actualization Cycle Is Invariant; Mode Is the Atom of Variation

The actualization cycle is how kosmos intention becomes chora actuality. It has three moments:

1. **Manifest** (γένεσις): Intent → Actuality. Make something real.
2. **Sense** (αἴσθησις): Actuality → Knowledge. Observe what is.
3. **Reconcile** (φύλαξ): Knowledge → Action. Correct any drift.

This cycle is **invariant** — it applies identically regardless of what is being actualized. What **varies** is the **mode**: the specific binding of (substrate, provider, operations) that determines how manifest/sense/reconcile execute for a given entity class.

```
INVARIANT:     manifest ──→ sense ──→ reconcile ──→ manifest ...
                 │            │            │
VARIES BY:      mode         mode         mode
                 │            │            │
BOUND TO:    (substrate,  (substrate,  (substrate,
              provider,    provider,    provider,
              stoicheion)  stoicheion)  stoicheion)
```

**Substrate** (ὑποκείμενον) is a dimension of chora through which intent becomes actual:
- **screen** — visual presentation (render-specs, spatial positions, widget trees)
- **compute** — process execution (cargo builds, OS processes, containers)
- **storage** — persistent data (local filesystem, R2, S3)
- **network** — connectivity (DNS records, WebRTC connections)

**Provider** is a specific implementation within a substrate (r2/s3/fs-local for storage; docker/systemd/local for compute; cloudflare for dns).

**Mode** binds substrate × provider × operations into one configurable unit — the atom of variation. Every mode is an `eidos/mode` entity in the graph, traversable via `gather(eidos: mode)`, bondable, cacheable.

**Stoicheion** is the atomic operation that a mode dispatches to — the concrete implementation of one operation (manifest, sense, or unmanifest) for a specific mode.

The principle: the pattern is one; the modes are many. Documenting both in a single reference enables systematic completion and agent configuration.

---

## Methodology — Doc-Driven

This work is pure DDD Phase 1: document the target state. No code changes, no tests.

The cycle: **Read → Synthesize → Write → Cross-reference → Track**.

1. **Read** all five fragment docs plus all genesis mode YAML files plus the generated dispatch table and host.rs implementation
2. **Synthesize** into a single unified reference that connects what the fragments describe separately
3. **Write** the reference doc at `docs/reference/reactivity/actualization-pattern.md`
4. **Cross-reference** from all five fragment docs back to the new unified reference
5. **Track** — update `docs/REGISTRY.md` Impact Map

### What "Reference Doc" Means Here

The reference doc is prescriptive — it describes the pattern we want the complete system to embody. Where modes are stubs, the doc says so explicitly. Where operations are not yet implemented, the doc marks the gap. The doc doesn't pretend stubs are implementations, and it doesn't pretend the doc alone makes things work.

### What This Is NOT

This is NOT a new explanation doc (those already exist — reactive-system.md, reconciler-pattern.md). This is a **reference** doc — schema definitions, enumeration, contracts, extension patterns. It answers "what are the parts and how do I use them?" not "why does this exist?"

---

## Context — The Five Fragments

### What exists

| Fragment | Location | What It Covers | What It Misses |
|----------|----------|----------------|----------------|
| Reconciliation engine | `docs/reference/reactivity/reconciliation.md` | Reconciler entity schema, transition matching, sense writeback | No substrate taxonomy, no mode catalog |
| Three-layer reactive system | `docs/explanation/reactivity/reactive-system.md` | Reflex → Reconciler → Mode architecture, complete flow | Explanation, not reference — no schemas, no extension pattern |
| Reconciler concept | `docs/explanation/reactivity/reconciler-pattern.md` | Intent vs actuality, continuous reconciliation | Explanation, not reference — conceptual only |
| Mode entity schema | `docs/reference/presentation/mode-reference.md` | Mode schema, render-spec schema, widget reference | Screen-biased — infrastructure modes treated as secondary |
| Command template execution | `docs/reference/infrastructure/command-template-execution.md` | Template interpolation, cargo-specific execution | Covers one pattern (templates) on one substrate (compute/cargo) |

### What's missing (the gaps this prompt fills)

1. **No unified reference** for the actualization cycle as a single coherent concept
2. **No mode catalog** — modes are enumerated only in genesis YAML, nowhere in docs
3. **No substrate taxonomy** — substrates aren't defined or documented as a concept
4. **No completion matrix** — nowhere documents which modes are implemented vs stub
5. **No extension pattern** — how to add a new mode is implicit, discoverable only by reading build.rs and host.rs
6. **mode-reference.md is screen-biased** — infrastructure modes are mentioned but not given equal treatment
7. **No agent configuration surface** — how an agent discovers and selects modes for a topos is undocumented

### Mode Enumeration (Ground Truth from Genesis)

19 mode entities across 5 genesis topoi:

**Screen Substrate** — `genesis/thyra/modes/screen.yaml` (6 modes)

| Mode | Pattern | Spatial | Status |
|------|---------|---------|--------|
| `mode/authoring-feed` | singleton | center | render-spec driven |
| `mode/text-composing` | singleton | bottom | render-spec driven |
| `mode/voice-composing` | singleton | bottom | render-spec driven |
| `mode/oikos-nav` | collection | left | render-spec driven |
| `mode/theoria-sidebar` | collection | right | render-spec driven |
| `mode/phasis-feed` | collection | center | render-spec driven |

**Compute Substrate** — `genesis/chora-dev/modes/compute.yaml`, `genesis/dynamis/modes/dynamis.yaml`, `genesis/soma/modes/voice.yaml` (8 modes)

| Mode | Provider | Manifest Stoicheion | Status |
|------|----------|---------------------|--------|
| `mode/cargo-build` | local | `cargo-build-run` | fully implemented (template-driven) |
| `mode/cargo-test` | local | `cargo-test-run` | fully implemented (template-driven) |
| `mode/cargo-clippy` | local | `cargo-clippy-run` | fully implemented (template-driven) |
| `mode/process-local` | local | `spawn-process` | partial (manifest/sense/unmanifest work) |
| `mode/process-docker` | docker | `docker-run` | stub (dispatched, returns stub) |
| `mode/process-nixos` | nixos | `nixos-activate` | stub (dispatched, returns stub) |
| `mode/process-systemd` | systemd | `systemd-start` | stub (dispatched, returns stub) |
| `mode/voice` | whisper | (handler-based) | handler declared, not dispatched |

**Storage Substrate** — `genesis/dynamis/modes/dynamis.yaml` (3 modes)

| Mode | Provider | Manifest Stoicheion | Status |
|------|----------|---------------------|--------|
| `mode/object-storage-r2` | r2 | `r2-put-object` | stub (dispatched, returns stub) |
| `mode/object-storage-s3` | s3 | `s3-put-object` | stub (dispatched, returns stub) |
| `mode/object-storage-local` | fs-local | `fs-write-file` | stub (dispatched, returns stub) |

**Network Substrate** — `genesis/dynamis/modes/dynamis.yaml`, `genesis/aither/modes/webrtc.yaml` (2 modes)

| Mode | Provider | Manifest Stoicheion | Status |
|------|----------|---------------------|--------|
| `mode/dns-cloudflare` | cloudflare | `cf-create-record` | stub (dispatched, returns stub) |
| `mode/webrtc-livekit` | livekit | (handler-based) | handler declared, not dispatched |

---

## Design — Target Reference Doc Structure

The new doc at `docs/reference/reactivity/actualization-pattern.md` should contain these sections:

### Section 1: The Actualization Cycle

Define the three moments (manifest, sense, reconcile). Show the invariant cycle diagram. Explain that the cycle applies to every entity that has a mode — regardless of substrate.

Cross-reference `docs/explanation/reactivity/reconciler-pattern.md` for the conceptual motivation and `docs/explanation/reactivity/reactive-system.md` for the three-layer architecture.

### Section 2: Ontological Vocabulary

Define precisely:

- **Substrate** (ὑποκείμενον) — dimension of chora through which intent becomes actual
- **Provider** — specific implementation within a substrate
- **Mode** — atom of variation, binding substrate × provider × operations
- **Stoicheion** — atomic operation dispatched by a mode
- **Reconciler** — entity that drives the cycle for a class of entities
- **Reflex** — event trigger that initiates reconciliation (sympathetic)
- **Daemon** — periodic trigger that initiates reconciliation (parasympathetic)

Each term gets a one-sentence definition, a note on its Greek origin where appropriate, and an example.

### Section 3: Mode Entity Schema

The full `eidos/mode` schema with all fields. This section should be authoritative for **all** substrates — not screen-biased. Include:

- Common fields (id, name, topos, substrate, provider, description)
- Operations object (manifest, sense, unmanifest — each with stoicheion/handler, params, returns)
- Screen-specific fields (spatial, render_spec_id, item_spec_id, arrangement, chrome_spec_id)
- Custom operations beyond the standard three (signal for webrtc, push_fragment/clarify for voice)

Cross-reference `docs/reference/presentation/mode-reference.md` for screen-specific details (widget trees, data bindings, spatial positions).

### Section 4: Substrate Taxonomy

Each substrate documented with:

| Substrate | ὑποκείμενον | Providers | Standard Operations | Modes |
|-----------|-------------|-----------|---------------------|-------|
| screen | visual | (implicit) | (render-spec driven) | 6 |
| compute | process | local, docker, systemd, nixos | manifest/sense/unmanifest | 8 |
| storage | data | r2, s3, fs-local | manifest/sense/unmanifest | 3 |
| network | connectivity | cloudflare, livekit | manifest/sense/unmanifest | 2 |

For each substrate:
- What it is (one sentence)
- How it maps to chora (what physical or virtual resource)
- Available providers with brief descriptions
- Which operations are standard vs custom

### Section 5: Mode Catalog

All 19 modes enumerated. For each mode:
- ID, substrate, provider
- Operations with stoicheion/handler names
- Completion stage (see Section 6)
- Implementation location (file + function for implemented; "genesis only" for stubs)
- What's needed to advance to the next stage

This is the work map. An agent reading this section knows exactly what exists, what's stub, and what each stub needs to become real.

### Section 6: Completion Stages

Define what "complete" means. For infrastructure modes (compute, storage, network):

| Stage | Name | Criterion |
|-------|------|-----------|
| 1 | **Prescribe** | Mode entity exists in genesis YAML with operations defined |
| 2 | **Dispatch** | build.rs generates dispatch table entry; `stoicheion_for_mode()` returns a stoicheion name |
| 3 | **Implement** | `manifest_by_stoicheion()` / `sense_by_stoicheion()` match arms execute real logic (not stubs) |
| 4 | **Compose** | Typos produce entities with `mode`/`provider` fields; praxeis invoke manifest/sense |
| 5 | **Sense** | Sense stoicheion queries actual substrate state (not just returning last-known from entity data) |
| 6 | **React** | Reflexes fire on state changes; reconciler drives corrections autonomously |

For screen modes, a different but parallel progression:

| Stage | Name | Criterion |
|-------|------|-----------|
| 1 | **Prescribe** | Mode entity exists with render_spec_id |
| 2 | **Render** | Render-spec entity exists and renders correctly via interpreter |
| 3 | **Compose** | Mode is referenced by thyra configuration entity |
| 4 | **Active** | Mode can be activated/deactivated; layout engine responds |
| 5 | **Reactive** | Mode switches trigger reflexes; state changes propagate |

### Section 7: Extension Pattern — Adding a New Mode

Step-by-step guide for adding a new mode to the system. Two paths:

**Path A: Stoicheion-dispatched mode** (simple operations, e.g., new cargo command, new cloud provider):
1. Create mode entity in `genesis/{topos}/modes/{substrate}.yaml`
2. Rebuild — `build.rs` generates dispatch table entry automatically
3. Add match arms in `manifest_by_stoicheion()` / `sense_by_stoicheion()` in `host.rs`
4. Create typos with `mode`/`provider` default fields
5. Write tests

**Path B: Handler-dispatched mode** (complex multi-step operations, e.g., WebRTC, voice):
1. Create mode entity with `handler:` instead of `stoicheion:` in operations
2. build.rs skips handler modes — no dispatch table entry generated
3. Implement handler functions directly in the appropriate module
4. Wire handler resolution in `manifest_by_stoicheion()` (or a future handler dispatch)
5. Write tests

Include: when to use stoicheion vs handler (simple shell/API operations → stoicheion; complex stateful flows → handler).

### Section 8: Agent Configuration Surface

How an agent (Claude Code, MCP tool, governed generation) discovers, selects, and configures modes for a topos:

```
# Discover all modes
gather(eidos: mode)

# Filter by substrate
gather(eidos: mode) where substrate = "compute"

# Find modes for a specific topos
gather(eidos: mode) where topos = "chora-dev"

# Check completion status
# (read mode catalog in this reference doc)

# Configure a topos to use a mode
# (add mode ID to topos manifest surfaces_consumed or mode dependencies)
```

This section bridges the gap between "modes exist as data" and "an agent can work with them." It makes the homoiconic promise concrete.

---

## Implementation Order

### Step 1: Read all fragments

Read these docs to build a complete mental model:

1. `docs/reference/reactivity/reconciliation.md` — reconciler engine schema
2. `docs/explanation/reactivity/reactive-system.md` — three-layer architecture
3. `docs/explanation/reactivity/reconciler-pattern.md` — conceptual motivation
4. `docs/reference/presentation/mode-reference.md` — mode entity schema (screen-focused)
5. `docs/reference/infrastructure/command-template-execution.md` — template execution pattern

### Step 2: Read all genesis mode definitions

Read every mode YAML to get the ground truth:

1. `genesis/thyra/modes/screen.yaml` — 6 screen modes
2. `genesis/dynamis/modes/dynamis.yaml` — 8 infrastructure modes
3. `genesis/chora-dev/modes/compute.yaml` — 3 cargo modes
4. `genesis/soma/modes/voice.yaml` — 1 voice mode
5. `genesis/aither/modes/webrtc.yaml` — 1 WebRTC mode

### Step 3: Read implementation to verify completion stages

1. `crates/kosmos/src/mode_dispatch.rs` — generated dispatch table (which modes have entries)
2. `crates/kosmos/src/host.rs` — `manifest_by_stoicheion()`, `sense_by_stoicheion()`, `unmanifest_by_stoicheion()` (which stoicheia have real implementations vs stubs)
3. `crates/kosmos/build.rs` — how dispatch is generated

### Step 4: Write the reference doc

Create `docs/reference/reactivity/actualization-pattern.md` with all 8 sections described in Design. The doc should be:
- Complete — every mode in genesis is in the catalog
- Accurate — completion stages match what code actually implements
- Prescriptive — describes the pattern we want, while honestly marking gaps
- Cross-referenced — links to the 5 fragment docs for details
- Actionable — an agent reading this doc knows what to do next

### Step 5: Update mode-reference.md

`docs/reference/presentation/mode-reference.md` is currently the closest thing to a mode reference but is screen-biased. Add a section at the top that points to `actualization-pattern.md` for the full mode taxonomy across all substrates. Ensure it's clear that mode-reference.md covers screen modes and render-spec details, while actualization-pattern.md covers the cross-substrate pattern.

### Step 6: Cross-reference from fragment docs

Add links from each fragment doc to the new reference:
- `reconciliation.md` — "For the full actualization pattern including mode taxonomy, see actualization-pattern.md"
- `reactive-system.md` — "For mode catalog and completion status, see actualization-pattern.md"
- `command-template-execution.md` — "This describes one execution pattern within the actualization cycle. For the full pattern, see actualization-pattern.md"

### Step 7: Update REGISTRY.md

Add `docs/reference/reactivity/actualization-pattern.md` to the Impact Map with cross-references to all 5 fragment docs.

### Step 8: Verify accuracy

```bash
# Count modes in genesis
rg '^  - eidos: mode' genesis/ --type yaml | wc -l
# Expected: 19

# Count modes in generated dispatch table (infrastructure only, excludes screen + handler)
rg 'REGISTERED_MODES' crates/kosmos/src/mode_dispatch.rs -A 1
# Expected: 11 entries

# Verify no stale naming in docs
rg 'actuality_mode' docs/ --type md
# Expected: zero in live docs

# Verify no stale naming in reference doc
rg 'actuality_mode' docs/reference/reactivity/actualization-pattern.md
# Expected: zero
```

---

## Files to Read

### Existing documentation fragments
- `docs/reference/reactivity/reconciliation.md`
- `docs/explanation/reactivity/reactive-system.md`
- `docs/explanation/reactivity/reconciler-pattern.md`
- `docs/reference/presentation/mode-reference.md`
- `docs/reference/infrastructure/command-template-execution.md`

### Genesis mode definitions
- `genesis/thyra/modes/screen.yaml`
- `genesis/dynamis/modes/dynamis.yaml`
- `genesis/chora-dev/modes/compute.yaml`
- `genesis/soma/modes/voice.yaml`
- `genesis/aither/modes/webrtc.yaml`

### Implementation (for completion stage verification)
- `crates/kosmos/src/mode_dispatch.rs` — generated dispatch table
- `crates/kosmos/src/host.rs` — `resolve_mode()`, `manifest_by_stoicheion()`, `sense_by_stoicheion()`
- `crates/kosmos/build.rs` — dispatch generation logic

### Documentation infrastructure
- `docs/REGISTRY.md` — Impact Map

## Files to Touch

- `docs/reference/reactivity/actualization-pattern.md` — **NEW** (the unified reference doc)
- `docs/reference/presentation/mode-reference.md` — add cross-reference to new doc
- `docs/reference/reactivity/reconciliation.md` — add cross-reference
- `docs/explanation/reactivity/reactive-system.md` — add cross-reference
- `docs/explanation/reactivity/reconciler-pattern.md` — add cross-reference
- `docs/reference/infrastructure/command-template-execution.md` — add cross-reference
- `docs/REGISTRY.md` — add to Impact Map

---

## Success Criteria

- [ ] `docs/reference/reactivity/actualization-pattern.md` exists with all 8 sections
- [ ] Mode catalog lists all 19 modes — zero omissions when cross-checked against genesis
- [ ] Completion stages are accurate — cross-checked against `mode_dispatch.rs` and `host.rs`
- [ ] Substrate taxonomy covers all 4 substrates with providers and mode counts
- [ ] Extension pattern is step-by-step, concrete, not vague
- [ ] Agent configuration surface shows actual queries, not theoretical
- [ ] All 5 fragment docs cross-reference the new doc
- [ ] `docs/REGISTRY.md` updated
- [ ] Zero references to `actuality_mode` in any live doc (mode consolidation renamed to `mode`)

---

## What This Enables

When this reference doc exists:

1. **Systematic substrate completion** — The mode catalog with completion stages becomes a work map. Subsequent prompts can say "advance mode/process-docker from stage 2 to stage 3" using shared vocabulary. The completion matrix tells you exactly what exists and what's next.

2. **Agent mode discovery** — A Claude Code session working on any topos can read the reference doc and understand all available modes, their completion status, and how to configure them. This makes the homoiconic promise concrete: modes are data, and agents can read data.

3. **Extension without archaeology** — New modes (GPU compute, WASI, CDN, edge functions) can be added following the documented pattern. No one needs to reverse-engineer build.rs and host.rs to understand the convention.

4. **Inference context composition** — The reference doc becomes composable into `typos-inference-*` for governed generation of mode-related entities. An LLM generating a new topos can read the mode catalog and select appropriate modes.

5. **Prompt scoping for substrate arcs** — Follow-on implementation prompts for specific substrates would reference this doc:
   - **PROMPT-SUBSTRATE-STORAGE.md** — Implement `mode/object-storage-local` (stage 2 → 5), the simplest non-cargo substrate
   - **PROMPT-SUBSTRATE-PROCESS.md** — Complete `mode/process-local` (stage 3 → 6), implement `mode/process-docker` (stage 2 → 4)
   - **PROMPT-SUBSTRATE-NETWORK.md** — Implement `mode/dns-cloudflare` (stage 2 → 4)

   Each prompt would advance specific modes through specific completion stages, referencing the catalog as ground truth.

---

## What Does NOT Change

- No Rust code — this is documentation only
- No genesis YAML — mode definitions are already correct
- No tests — nothing to test (no behavior changes)
- No build system — build.rs unchanged
- All existing fragment docs — content preserved, only cross-references added

---

*Traces to: KOSMOGONIA §Mode Pattern, PROMPT-MODE-CONSOLIDATION.md, PROMPT-ACTUALIZATION-CARGO.md, T5 (code is artifact), T8 (mode is topos presence)*
