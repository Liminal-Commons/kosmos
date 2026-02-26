# Mode Unification — Tropos: One Shape for All Substrates

*Prompt for Claude Code in the chora + kosmos repository context.*

*Dissolves the ontological split between `mode` and `actuality-mode` into a single concept: tropos — how existence becomes actuality on a substrate. After this work, screen rendering, process management, storage, DNS, voice capture, and federation are all modes of the same shape, differing only in substrate. The reconciler pattern operates through modes universally.*

---

## Architectural Principle — One Concept, Not Two

KOSMOGONIA V11 prescribes:

> A **mode** declares how existence becomes actuality on a specific substrate. It is the bridge between the two modes of being.

> Every mode has three operations: **Manifest**, **Sense**, **Unmanifest**.

> The reconciler operates through modes. The reconciler is substrate-agnostic — it reads transition tables from entities. The mode is substrate-specific — it knows what manifesting means for its substrate.

Currently, the system splits this one concept into two eide:

| Eidos | Where | Substrate | What It Knows |
|-------|-------|-----------|---------------|
| `mode` | thyra | screen only | render-spec, spatial position, arrangement |
| `actuality-mode` | dynamis | compute, storage, network, filesystem | stoicheion dispatch, provider, operations |

This split violates three meta-patterns:

1. **Narrow Way** — two archai where one suffices
2. **Fractal Specification** — the pattern breaks across scales (screen renders are not recognizable as the same concept as process spawns)
3. **Homoiconicity** — the relationship between screen and infrastructure actuality is implicit in code (`requires_actuality` field) rather than structural in the graph

The fix is dissolution: one eidos, one shape, substrate-specific configuration.

### What Changes

The `mode` eidos becomes universal. Every mode declares:
- **Substrate** — what it acts on (screen, compute, storage, network, filesystem, remote)
- **Manifest / Sense / Unmanifest** — substrate-specific operations
- **Requires** — other modes this one depends on (replaces `requires_actuality`)

The `actuality-mode` eidos is retired. Its entities become `mode` entities with explicit substrates.

### What Does NOT Change

- The reconciler engine (`host.reconcile()`) — already substrate-agnostic
- The dispatch table shape (`actuality_stoicheion(mode, provider, op)`) — still generated, same signature
- The layout engine's rendering logic — still dispatches on render pattern (singleton/collection/compound)
- The actuality handler registry (`actuality.ts`) — still manifest/unmanifest lifecycle
- The three render patterns — still the three ways a screen-mode manifests

---

## Methodology — Doc-Driven, Test-Driven

This work follows **Doc → Test → Build → Verify Doc**, non-negotiably.

1. **Doc (prescriptive)**: This prompt IS the prescriptive doc. Target state described here is what code must match.
2. **Test (assert the doc)**: Write tests that assert the unified mode schema, dispatch generation from unified YAML, and mode resolution from the new structure. Tests should fail before implementation.
3. **Build (satisfy the tests)**: Implement until tests pass.
4. **Verify doc**: After implementation, update reference docs and this prompt to reflect completion.

### Clean Break

- **No `actuality-mode` eidos after this work.** Every entity that was `eidos: actuality-mode` becomes `eidos: mode` with `substrate` field.
- **No `requires_actuality` field.** Replaced by `requires` — mode IDs, not actuality-mode IDs.
- **No `desmos/requires-actuality`.** Replaced by `desmos/requires-mode` — mode→mode bond.
- **`mode` field name `oikos` renamed to `topos`.** The mode eidos currently uses `oikos` for the owning domain — but the owning domain is a topos, not an oikos. Fix this misnaming.
- **Screen modes gain `substrate: screen`.** Explicit, not implicit.
- **Infrastructure modes gain structured manifest/sense/unmanifest.** Already present in YAML, now under unified eidos.

---

## Current State

### Mode Eidos (thyra)

**File:** `genesis/thyra/eide/mode.yaml`

Screen-only. 11 fields including `render_spec_id`, `item_spec_id`, `sections`, `spatial`, `requires_actuality`, `source_query`, `arrangement`, `chrome_spec_id`. No `substrate` field — screen is implicit.

6 mode entities in `genesis/thyra/entities/layout.yaml`:
- `mode/authoring-feed` — collection, center, gather phasis
- `mode/text-composing` — singleton, bottom, bound to accumulation
- `mode/oikos-nav` — collection, left, gather oikos
- `mode/theoria-sidebar` — collection, right, gather theoria
- `mode/phasis-feed` — collection, center, gather phasis (scroll-bottom)
- `mode/voice-composing` — singleton, bottom, `requires_actuality: [actuality-mode/voice]`

### Actuality-Mode Entities (dynamis + thyra)

**File:** `genesis/dynamis/actuality-modes/dynamis.yaml` — 8 entities:
- `actuality-mode/dns-cloudflare`
- `actuality-mode/object-storage-{r2,s3,local}`
- `actuality-mode/process-{local,docker,nixos,systemd}`

**File:** `genesis/thyra/actuality-modes/voice.yaml` — 1 entity:
- `actuality-mode/voice`

Each has: `name`, `provider`, `operations.{manifest,sense,unmanifest}` (stoicheion + params + returns), `config_schema`.

No explicit `eidos: actuality-mode` eidos definition exists — the entities claim `eidos: actuality-mode` and are parsed directly by build.rs. This is a bootstrap exception.

### Desmoi

**File:** `genesis/thyra/desmoi/mode.yaml`:
- `desmos/requires-actuality` — from `mode` to `actuality-mode`, one-to-many
- `desmos/uses-render-spec` — from `mode` to `render-spec`, many-to-one

### Build.rs Dispatch Generation

**File:** `crates/kosmos/build.rs`

Reads only `genesis/dynamis/actuality-modes/dynamis.yaml`. Does NOT read voice.yaml (voice dispatch is hand-wired in host.rs). Generates:
- `ActualityOperation` enum: Manifest, Sense, Unmanifest
- `ACTUALITY_MODES` const: 8 (mode, provider) tuples
- `actuality_stoicheion(mode, provider, op) → Option<&str>` — 24 entries
- `actuality_mode_info(mode, provider) → Option<ActualityModeInfo>`

### Frontend

**File:** `app/src/lib/layout-engine.tsx`
- ModeRenderer dispatches on `source_entity_id` → `item_spec_id` → `sections` → `render_spec_id`
- Reads `mode.data.requires_actuality` → calls `reconcileActuality(required)`

**File:** `app/src/lib/actuality.ts`
- Handler registry: `registerActualityHandler(id, { manifest, unmanifest })`
- `reconcileActuality(required: Set<string>)` — diffs manifested vs required

### Rust Backend

**File:** `crates/kosmos/src/host.rs`
- `resolve_actuality_mode(data, eidos, host)` reads `data.actuality_mode` + `data.provider`
- `manifest()` / `sense_actuality()` / `unmanifest()` dispatch via `actuality_stoicheion()`

---

## Design — Unified Mode Eidos

### The Unified Shape

Every mode has:

```yaml
eidos: mode
id: mode/{name}
data:
  name: string                # human-readable
  topos: string               # owning topos (was incorrectly "oikos")
  substrate: string           # screen | compute | storage | network | filesystem | remote
  provider: string            # default "local" — allows multiple providers per substrate
  description: string

  # Dependencies — other modes this one needs active
  requires: [mode-id, ...]

  # === Substrate-specific manifest configuration ===

  # Screen substrate:
  render_spec_id: string      # singleton pattern
  item_spec_id: string        # collection pattern
  sections: array             # compound pattern
  spatial: object             # { position, height }
  arrangement: string         # scroll, scroll-bottom, stack, list, grid
  chrome_spec_id: string
  source_entity_id: string
  source_query: string
  empty_message: string
  config: object

  # Infrastructure substrates (compute, storage, network, filesystem, remote):
  operations:
    manifest: { stoicheion, params, returns, description }
    sense: { stoicheion, params, returns, description }
    unmanifest: { stoicheion, params, returns, description }
    # Additional operations (e.g., voice: push_fragment, clarify)
    {custom}: { ... }
  config_schema: object
  requires_dynamis: [string]  # dynamis capabilities needed
```

### Screen Mode Example (unchanged shape, explicit substrate)

```yaml
- eidos: mode
  id: mode/voice-composing
  data:
    name: voice-composing
    topos: voice
    substrate: screen
    description: "Voice input — speak, transcribe, clarify, send"
    render_spec_id: render-spec/voice-bar
    spatial:
      position: bottom
      height: auto
    source_entity_id: accumulation/default
    requires:
      - mode/voice
```

### Infrastructure Mode Example (was actuality-mode)

```yaml
- eidos: mode
  id: mode/process-local
  data:
    name: process
    topos: dynamis
    substrate: compute
    provider: local
    description: "Local process execution mode."
    operations:
      manifest:
        stoicheion: spawn-process
        params: [command, args, env, working_dir]
        returns: { pid: number }
      sense:
        stoicheion: check-process
        params: [pid]
        returns: { running: boolean, exit_code: number }
      unmanifest:
        stoicheion: kill-process
        params: [pid, signal]
    config_schema:
      command: { type: string, required: true }
      args: { type: array, required: false }
```

### Voice Mode Example (was actuality-mode/voice)

```yaml
- eidos: mode
  id: mode/voice
  data:
    name: voice
    topos: soma
    substrate: compute
    provider: local
    description: "Voice capture substrate — audio input, VAD, streaming transcription."
    requires_dynamis: [audio-capture, transcription]
    operations:
      manifest:
        handler: voice::manifest_stream
        params: { device_id: { type: string, default: "default" }, ... }
        returns: { manifest_handle: { type: string } }
      sense:
        handler: voice::sense_stream
        params: { manifest_handle: { type: string } }
        returns: { stream_status: { type: enum }, ... }
      unmanifest:
        handler: voice::unmanifest_stream
        params: { manifest_handle: { type: string } }
      push_fragment:
        handler: voice::push_fragment
        params: { stream_id: { type: string }, text: { type: string }, ... }
      clarify:
        handler: voice::clarify
        params: { accumulation_id: { type: string } }
```

### Unified Desmoi

Replace `desmos/requires-actuality` with `desmos/requires-mode`:

```yaml
- eidos: desmos
  id: desmos/requires-mode
  data:
    name: requires-mode
    description: |
      Mode depends on another mode being active.
      When this mode activates, required modes are manifested first.
      Cross-substrate: screen mode may require compute mode.
    from_eidos: mode
    to_eidos: mode
    cardinality: one-to-many
    symmetric: false
```

`desmos/uses-render-spec` stays — still mode→render-spec for screen modes.

### ID Migration

| Old ID | New ID | Reason |
|--------|--------|--------|
| `actuality-mode/voice` | `mode/voice` | Unified eidos |
| `actuality-mode/process-local` | `mode/process-local` | Unified eidos |
| `actuality-mode/process-docker` | `mode/process-docker` | Unified eidos |
| `actuality-mode/process-nixos` | `mode/process-nixos` | Unified eidos |
| `actuality-mode/process-systemd` | `mode/process-systemd` | Unified eidos |
| `actuality-mode/object-storage-r2` | `mode/object-storage-r2` | Unified eidos |
| `actuality-mode/object-storage-s3` | `mode/object-storage-s3` | Unified eidos |
| `actuality-mode/object-storage-local` | `mode/object-storage-local` | Unified eidos |
| `actuality-mode/dns-cloudflare` | `mode/dns-cloudflare` | Unified eidos |

---

## Implementation Order

### Step 1: Genesis — Unified Mode Eidos

Update `genesis/thyra/eide/mode.yaml`:

1. Add `substrate` field (string, required, enum: screen/compute/storage/network/filesystem/remote)
2. Add `provider` field (string, default: "local")
3. Add `operations` field (object, required: false — only for non-screen substrates)
4. Add `config_schema` field (object, required: false)
5. Add `requires_dynamis` field (array, required: false)
6. Add `requires` field (array, required: false — replaces `requires_actuality`)
7. Rename `oikos` field to `topos` in description and usage
8. Remove `requires_actuality` field
9. Update description to reflect KOSMOGONIA language ("how existence becomes actuality on a substrate")

Add `eidos/actuality-mode` as a tombstone or simply remove all references.

### Step 2: Genesis — Migrate Screen Mode Entities

Update `genesis/thyra/entities/layout.yaml`:

For each of the 6 mode entities:
1. Add `substrate: screen`
2. Rename `oikos` → `topos` (if field exists; some use the field name inconsistently)
3. For `mode/voice-composing`: change `requires_actuality: [actuality-mode/voice]` to `requires: [mode/voice]`

### Step 3: Genesis — Migrate Infrastructure Mode Entities

**Move** `genesis/dynamis/actuality-modes/dynamis.yaml` → `genesis/dynamis/modes/dynamis.yaml`

For each of the 8 entities:
1. Change `eidos: actuality-mode` → `eidos: mode`
2. Change `id: actuality-mode/{name}` → `id: mode/{name}`
3. Add `substrate: compute` (for process-*), `substrate: storage` (for object-storage-*), `substrate: network` (for dns-*)
4. Add `topos: dynamis`

### Step 4: Genesis — Migrate Voice Mode

**Move** `genesis/thyra/actuality-modes/voice.yaml` → `genesis/soma/modes/voice.yaml` (or keep in thyra if soma topos doesn't exist yet)

1. Change `eidos: actuality-mode` → `eidos: mode`
2. Change `id: actuality-mode/voice` → `id: mode/voice`
3. Add `substrate: compute`
4. Add `topos: soma` (or `topos: voice`)

### Step 5: Genesis — Update Desmoi

Update `genesis/thyra/desmoi/mode.yaml`:
1. Replace `desmos/requires-actuality` with `desmos/requires-mode` (from_eidos: mode, to_eidos: mode)
2. Keep `desmos/uses-render-spec` unchanged

### Step 6: Genesis — Update Bonds

In `genesis/thyra/entities/layout.yaml` bonds section, add requires-mode bond:
```yaml
- from_id: mode/voice-composing
  to_id: mode/voice
  desmos: requires-mode
```

### Step 7: Build.rs — Read Unified Modes

Update `crates/kosmos/build.rs`:

1. Change the actuality mode YAML path from `genesis/dynamis/actuality-modes/dynamis.yaml` to scan all `genesis/*/modes/*.yaml` files
2. Filter for entities where `substrate != "screen"` (screen modes don't need Rust dispatch)
3. Update `ActualityModeEntity` struct to accept the new field names (still `name`, `provider`, `operations`)
4. Add `cargo:rerun-if-changed` for all mode files
5. Update generated comments to say "mode" not "actuality-mode"

The generated `actuality_modes.rs` output shape stays identical — same `actuality_stoicheion()` signature, same dispatch table. Only the input path changes.

### Step 8: Rust — Update Entity Resolution

In `crates/kosmos/src/host.rs`:

`resolve_actuality_mode()` already reads `data.actuality_mode` + `data.provider`. For the unified model, entities that need infrastructure actuality still have these fields in their data (e.g., a `deployment` entity has `actuality_mode: "process"` and `provider: "local"`). No change needed here — the dispatch consumer doesn't read mode entities, it reads the entities being manifested.

If any code references `actuality-mode/` ID prefixes, update to `mode/` prefixes.

### Step 9: Frontend — Update Layout Engine

In `app/src/lib/layout-engine.tsx`:

1. Change `mode.data.requires_actuality` reads to `mode.data.requires`
2. Filter requires list: screen-mode requires are handled by layout (already active modes), non-screen requires go to `reconcileActuality()`
3. The actuality handler registry keys change from `actuality-mode/voice` to `mode/voice`

In `app/src/lib/actuality.ts`:
1. Handler registration: `registerActualityHandler("mode/voice", ...)` instead of `registerActualityHandler("actuality-mode/voice", ...)`

### Step 10: Tests — Maintain All Passing

1. Existing bootstrap tests must pass (entity IDs change, so `genesis/` must be consistent)
2. Existing reflex tests must pass
3. Existing v9_equivalence tests must pass
4. Add new test: `mode_unification.rs` — assert unified mode entities load, dispatch still works, `actuality-mode` eidos is absent

### Step 11: Docs — Update Reference

Update `docs/reference/presentation/mode-reference.md` to reflect unified eidos with substrate field.
Update `docs/reference/reactivity/reconciliation.md` to use "mode" not "actuality-mode".
Check all docs that reference `actuality-mode` — should be zero after this work.

### Step 12: Verify — Audit for Vestiges

```bash
# No actuality-mode eidos references should exist
rg 'actuality-mode' genesis/ --type yaml
# Expected: zero results

# No actuality_mode references in TypeScript (except data field on domain entities)
rg 'actuality.mode' app/src/ --type ts
# Expected: only in entity data field access, not in mode ID strings

# No requires_actuality references
rg 'requires_actuality|requires-actuality' genesis/ app/src/
# Expected: zero results

# Build succeeds
cargo build 2>&1

# All tests pass
cargo test -p kosmos --lib --tests 2>&1

# Frontend tests pass
cd app && npx vitest run 2>&1
```

---

## Files to Touch

### Kosmos (genesis)

| File | Action |
|------|--------|
| `genesis/thyra/eide/mode.yaml` | Add substrate, provider, operations, requires; remove requires_actuality |
| `genesis/thyra/entities/layout.yaml` | Add substrate: screen to all modes; rename oikos→topos; voice-composing: requires_actuality→requires |
| `genesis/thyra/desmoi/mode.yaml` | Replace requires-actuality with requires-mode |
| `genesis/dynamis/actuality-modes/dynamis.yaml` | **Delete** (migrated to modes/) |
| `genesis/dynamis/modes/dynamis.yaml` | **Create** — migrated entities with eidos: mode, substrate, topos |
| `genesis/thyra/actuality-modes/voice.yaml` | **Delete** (migrated to soma or voice) |
| `genesis/soma/modes/voice.yaml` | **Create** — migrated voice with eidos: mode, substrate: compute |

### Chora (implementation)

| File | Action |
|------|--------|
| `crates/kosmos/build.rs` | Scan `genesis/*/modes/*.yaml`, filter non-screen, update comments |
| `crates/kosmos/src/actuality_modes.rs` | Regenerated (same shape, updated comments) |
| `app/src/lib/layout-engine.tsx` | `requires_actuality` → `requires`, filter screen vs non-screen |
| `app/src/lib/actuality.ts` | Handler keys: `mode/voice` instead of `actuality-mode/voice` |

### Docs

| File | Action |
|------|--------|
| `docs/reference/presentation/mode-reference.md` | Unified eidos with substrate |
| `docs/reference/reactivity/reconciliation.md` | "mode" not "actuality-mode" |

---

## What This Enables

When mode unification is complete:

- **One shape governs all substrate actuality.** Screen rendering, process management, storage, DNS, voice capture, and federation sync are all modes — differing in substrate, identical in shape.
- **The reconciler pattern is visibly universal.** KOSMOGONIA's "the reconciler operates through modes" is literally true in code, not just in principle.
- **Federation becomes a mode.** Arc 3 (Federation Dissolution) can express sync as `mode/federation-{direction}` with substrate: remote. The reconciler cycle operates through it like any other mode.
- **Mode generation is possible.** The generative spiral can produce modes for any substrate — `generate-mode` praxis with substrate as input. One typos-inference per substrate pattern.
- **Cross-substrate dependencies are graph-traversable.** `mode/voice-composing --requires-mode--> mode/voice` is mode→mode, not a cross-eidos bond. The bond graph is simpler.
- **No ontological debt.** The system's concepts match KOSMOGONIA's prescriptions. One concept, one eidos, one shape.

---

*Traces to: KOSMOGONIA V11 §Two Modes of Being, §Mode — The Bridge, §Reconciler Pattern*
