# Autonomic Triad — Making surface/reactivity and surface/sensing Explicit

*Prompt for Claude Code in the chora + kosmos repository context.*

*Introduces two new surface entities — `surface/reactivity` and `surface/sensing` — completing the autonomic triad alongside the existing `surface/reconciliation`. Updates all consumer manifests. Simplifies constituent elements from 12 to 9 by recognizing that reconcilers, reflexes, and daemons are eide configuring surfaces, not distinct element types. Deletes speculative `ReflexScope::Topos` code.*

*After this work, the nervous system is visible in the graph: every topos that declares reflexes is bonded to `surface/reactivity`, every topos with daemons to `surface/sensing`, and every topos with reconcilers to `surface/reconciliation`. The autonomic triad is how the kosmos senses, responds, and aligns.*

---

## Prerequisite: Understand the Triad

The kosmos already has a functioning nervous system — three mechanisms that compose a complete sense/respond/align loop:

1. **Sensing** (daemons): Periodic actuality probing. A daemon invokes a sense praxis on a schedule, discovering what IS.
2. **Reactivity** (reflexes): Event-driven mutation response. When a graph mutation matches a trigger pattern, the matching reflex fires its response praxis automatically.
3. **Reconciliation** (reconcilers): Intent/actuality alignment. Transition tables compare what SHOULD be with what IS and dispatch actions through modes.

The loop is already real in aither:
```
daemon/sense-syndesmos invokes sense praxis → discovers connection actuality
  → sense updates entity status field → graph mutation occurs
    → reflex/syndesmos-drift fires on mutation → invokes praxis/dynamis/reconcile
      → reconciler/syndesmos-reconnect compares intent with status → dispatches manifest
```

But only `surface/reconciliation` is declared as a surface (Arc 2). The other two are implicit — wired through `host.rs` but invisible in the graph. A topos that uses reflexes has no `surfaces_consumed` entry for the capability it depends on. This prompt makes the implicit explicit.

---

## Architectural Principle — Declarative Surfaces

The autonomic triad surfaces are **declarative**: consumers declare entities (reflexes, daemons, reconcilers) and the engine processes them automatically. This distinguishes them from **active** surfaces like `computation` or `transport` where consumers invoke praxeis directly.

| Surface Type | Consumer Interaction | Engine Role |
|--------------|---------------------|-------------|
| **Active** (computation, transport, reasoning) | Consumer invokes praxeis | Executes on demand |
| **Declarative** (reconciliation, reactivity, sensing) | Consumer declares entities | Engine reads entities, acts autonomously |

`surface/reconciliation` blurs this line — it's both declarative (reconciler entities with transition tables) and invocable (`praxis/dynamis/reconcile`). Reactivity and sensing are purely declarative: no invocable entry-point praxis exists. The reflex engine fires on every mutation through `notify_change()` in `host.rs`. The daemon loop invokes sensing praxeis on schedule. Neither requires explicit invocation.

The `praxeis` field on these surface entities can be empty. A surface contract is about the guarantee, not the entry point. The guarantee for reactivity: mutations get checked against patterns, matching triggers fire their responses, parameter interpolation works. The guarantee for sensing: praxeis get invoked on schedule, backoff works, lifecycle is managed.

---

## Current State

### What exists

| Entity | Where | Status |
|--------|-------|--------|
| `surface/reconciliation` | `genesis/dynamis/surfaces/surfaces.yaml` | Exists (Arc 2). Provider: dynamis. |
| `surface/computation` | `genesis/dynamis/surfaces/surfaces.yaml` | Exists. Provider: dynamis. |
| Dynamis manifest `surfaces_provided` | `genesis/dynamis/manifest.yaml` | Lists `computation`, `reconciliation` |

### What is implicit (should be explicit)

| Mechanism | Runtime Implementation | Genesis Declaration | Gap |
|-----------|----------------------|--------------------|----|
| **Reactivity** | `reflex.rs` + `host.rs:notify_change()` | 13 topoi declare reflex entities | No `surface/reactivity` entity. No `reactivity` in consumer manifests' `surfaces_consumed`. |
| **Sensing** | `daemon_loop.rs` + daemon entity interval field | 6 topoi declare daemon entities | No `surface/sensing` entity. No `sensing` in consumer manifests' `surfaces_consumed`. |

### Topoi that declare reflexes (13 — consume reactivity)

| Topos | Reflex Count | Current `surfaces_consumed` |
|-------|--------------|-----------------------------|
| agora | 2 | rendering, transport |
| aither | 2 | reconciliation |
| chora-dev | 6 | computation, understanding |
| demiurge | 3 | reasoning |
| dokimasia | 1 | reconciliation |
| dynamis | 4 | `[]` (provider — does not self-consume) |
| ergon | 2 | `[]` |
| nous | 6 | reasoning |
| oikos | 2 | understanding |
| politeia | 3 | `[]` |
| propylon | 2 | `[]` |
| release | 1 | computation, emission, reconciliation |
| thyra | 2 | `[]` |

Dynamis is the provider of `surface/reactivity` and does not need to self-consume. The remaining **12 topoi** add `reactivity` to their `surfaces_consumed`.

### Topoi that declare daemons (6 — consume sensing)

| Topos | Daemon(s) | Current `surfaces_consumed` |
|-------|-----------|----------------------------|
| aither | `daemon/sense-syndesmos` (interval: 30s) | reconciliation |
| chora-dev | `daemon/chora-dev-watcher`, `daemon/chora-dev-build-queue` | computation, understanding |
| dokimasia | `daemon/sense-graph-integrity` (interval: 60s) | reconciliation |
| dynamis | `daemon/sense-deployments` (interval: 30s) | `[]` (provider — does not self-consume) |
| release | `daemon/sense-releases` (interval: 300s) | computation, emission, reconciliation |
| thyra | `daemon/sense-voice-streams` (interval: 5s) | `[]` |

Dynamis is the provider. The remaining **5 topoi** add `sensing` to their `surfaces_consumed`.

### Speculative code to delete

| Code | Where | Problem |
|------|-------|---------|
| `ReflexScope::Topos` variant | `reflex.rs:88` | Zero consumers in genesis. No topos declares `scope: topos`. Speculative. |
| `entity_in_topos()` function | `reflex.rs:639-663` | Only called by `Topos` scope match arm |
| `"topos"` parse branch | `reflex.rs:277-283` | Only creates `Topos` scope |

~25 lines total. All other reflex.rs code stays — it backs `surface/reactivity`.

---

## Design — Two New Surface Entities

### `surface/reactivity`

```yaml
- eidos: surface
  id: surface/reactivity
  data:
    surface_id: reactivity
    description: |
      Event-driven autonomic mutation response. Consumers declare reflex
      entities with trigger patterns and response praxeis. The engine
      fires matching responses automatically on graph mutations.

      Reflexes are the sympathetic nervous system — immediate response
      to stimulus. The consumer declares what to watch and what to do;
      the engine handles matching, scoping, and parameter interpolation.

      Consumers declare:
        - trigger entities (eidos: trigger) with event patterns
        - reflex entities (eidos: reflex) bonded to triggers and response praxeis
      The engine automatically evaluates mutations against trigger patterns,
      filters by scope (global/oikos), and invokes response praxeis with
      interpolated parameters.
    praxeis: []
    version: "1.0"
```

### `surface/sensing`

```yaml
- eidos: surface
  id: surface/sensing
  data:
    surface_id: sensing
    description: |
      Periodic actuality sensing. Consumers declare daemon entities
      with a praxis and interval. The engine invokes the praxis on
      schedule with exponential backoff on failure.

      Daemons are the parasympathetic nervous system — rhythmic sensing
      that keeps the system aware of its environment. The consumer
      declares what to sense and how often; the engine handles scheduling,
      lifecycle, and backoff.

      Consumers declare:
        - daemon entities (eidos: daemon) with praxis, interval, and scope
      The engine invokes the daemon's praxis on schedule, manages backoff
      on failure (up to backoff_max), and respects enabled/disabled state.
    praxeis: []
    version: "1.0"
```

Both surfaces have empty `praxeis` arrays. They are purely declarative — the contract is the entity schema and the engine's guarantees, not an invocable entry point.

---

## Constituent Element Simplification — 12 to 9

The current `constituent-elements.md` lists 12 element types that a topos author uses. Three of these — reconciler, reflex, daemon — are not structurally distinct from other eide. They are entities that configure autonomic surfaces, just as render-specs are entities that configure presentation.

### The 9 constituent elements

| Element | What It Is | Example |
|---------|-----------|---------|
| **Eidos** | Entity type definition | `eidos/theoria` |
| **Desmos** | Bond type definition | `desmos/crystallizes` |
| **Praxis** | Executable procedure | `praxis/nous/crystallize-theoria` |
| **Typos** | Composition mold | `typos-def-render-spec` |
| **Render-Spec** | Declarative widget tree | `render-spec/note-card` |
| **Mode** | How existence becomes actuality on a substrate | `mode/voice-composing` |
| **Surface** | Capability contract between topoi | `surface/reactivity` |
| **Seed** | Initial entity instance loaded at genesis | `substrate/mac-universal` |
| **Theoria** | Crystallized understanding | (runtime via crystallize-theoria) |

### What was removed and why

| Former Element | Now Understood As |
|----------------|-------------------|
| **Trigger** | An eidos bonded to reflexes — part of the reactivity surface schema |
| **Reflex** | An eidos that configures `surface/reactivity` |
| **Reconciler** | An eidos that configures `surface/reconciliation` |
| **Daemon** | An eidos that configures `surface/sensing` |
| **Stoicheion** | Step types defined by `stoicheia-portable` — interpreter internals, not topos-level |
| **Widget** | UI primitives registered in thyra — interpreter internals, not topos-level |

The directory conventions remain: `genesis/{topos}/reflexes/`, `genesis/{topos}/reconcilers/`, `genesis/{topos}/daemons/`. These directories hold entities of the relevant eide. The ontological shift is: these are entities configuring surfaces, not a distinct category of "reactive elements."

---

## Implementation Order

### Step 1: Add surface entities

Add `surface/reactivity` and `surface/sensing` to `genesis/dynamis/surfaces/surfaces.yaml`, after the existing `surface/reconciliation` entity.

### Step 2: Update dynamis manifest

In `genesis/dynamis/manifest.yaml`, update `surfaces_provided`:

```yaml
# Before
surfaces_provided:
  - computation
  - reconciliation

# After
surfaces_provided:
  - computation
  - reconciliation
  - reactivity
  - sensing
```

### Step 3: Update consumer manifests

Add `reactivity` to `surfaces_consumed` for the 12 topoi with reflexes (excluding dynamis as provider):

| Topos | `surfaces_consumed` before | `surfaces_consumed` after |
|-------|---------------------------|--------------------------|
| agora | rendering, transport | rendering, transport, reactivity |
| aither | reconciliation | reconciliation, reactivity |
| chora-dev | computation, understanding | computation, understanding, reactivity, sensing |
| demiurge | reasoning | reasoning, reactivity |
| dokimasia | reconciliation | reconciliation, reactivity, sensing |
| ergon | `[]` | reactivity |
| nous | reasoning | reasoning, reactivity |
| oikos | understanding | understanding, reactivity |
| politeia | `[]` | reactivity |
| propylon | `[]` | reactivity |
| release | computation, emission, reconciliation | computation, emission, reconciliation, reactivity, sensing |
| thyra | `[]` | reactivity, sensing |

Add `sensing` to `surfaces_consumed` for the 5 topoi with daemons (excluding dynamis):
aither, chora-dev, dokimasia, release, thyra (shown in table above).

### Step 4: Update `constituent-elements.md`

Rewrite `docs/reference/elements/constituent-elements.md`:

1. Replace the current 4-group structure (Structural, Presentation, Reactive, Generative) with the 9-element catalog
2. Explain that triggers, reflexes, reconcilers, daemons, stoicheia, and widgets are eide — not distinct element types. They configure specific surfaces or subsystems
3. The "Where Instances Live" table stays, updated for the new framing
4. The "Generation Support" section stays unchanged

### Step 5: Update `surface-contracts.md`

Update `docs/reference/authorization/surface-contracts.md`:

1. Add `reactivity` and `sensing` to the "Known Surfaces" table:

```markdown
| `reactivity` | dynamis | agora, aither, chora-dev, demiurge, dokimasia, ergon, nous, oikos, politeia, propylon, release, thyra | Event-driven mutation response via reflexes |
| `sensing` | dynamis | aither, chora-dev, dokimasia, release, thyra | Periodic actuality sensing via daemons |
```

2. Note the distinction between active and declarative surfaces in the introductory text

### Step 6: Delete `ReflexScope::Topos`

In `crates/kosmos/src/reflex.rs`:

1. Remove `ReflexScope::Topos(String)` from the enum (line 88)
2. Remove `entity_in_topos()` function (lines 639–663)
3. Remove `"topos"` parse branch (lines 277–283)
4. Remove `ReflexScope::Topos` match arm from `matches_scope()` (line 605)

~25 lines. All other reflex.rs code stays.

### Step 7: Verify

```bash
# Build succeeds
cargo build 2>&1

# All tests pass
cargo test -p kosmos --lib --tests 2>&1

# No references to deleted Topos scope
rg 'ReflexScope::Topos' crates/
# Expected: zero results

rg 'entity_in_topos' crates/
# Expected: zero results

# Surface entities exist in genesis
rg 'surface/reactivity' genesis/
# Expected: dynamis surfaces.yaml + consumer manifests

rg 'surface/sensing' genesis/
# Expected: dynamis surfaces.yaml + consumer manifests

# Consumer manifests updated
rg 'reactivity' genesis/*/manifest.yaml
# Expected: 12 topoi (all reflex consumers except dynamis)

rg 'sensing' genesis/*/manifest.yaml
# Expected: 5 topoi (all daemon consumers except dynamis)
```

---

## What This Enables

- **Graph-traversable dependencies**: `trace(to: surface/reactivity, desmos: consumes-surface)` returns every topos that relies on reflexes. Bootstrap validates that these dependencies are satisfied. The nervous system is visible.
- **Conceptual simplification**: 9 constituent elements instead of 12. Topos authors learn: declare entities, bond them, done. Reflexes and daemons aren't special — they're entities the engine reads, like render-specs.
- **Autonomic triad visibility**: Three surfaces compose the complete nervous system loop. Aither already uses all three. Any topos can wire the same loop by declaring the right entities and consuming the right surfaces.
- **Dead code elimination**: `ReflexScope::Topos` was speculative code with no genesis consumer. Removing it aligns reflex.rs with what genesis actually prescribes.

---

## What Does NOT Change

- `reflex.rs` — unchanged except `Topos` variant deletion. The engine IS the stoicheion backing `surface/reactivity`.
- `daemon_loop.rs` — unchanged. The engine IS the stoicheion backing `surface/sensing`.
- `host.rs` — unchanged. `notify_change()` fires reflexes; daemon loop runs on schedule. Both continue working exactly as they do today.
- `host.reconcile()` — unchanged. The reconciler engine IS the stoicheion backing `surface/reconciliation`.
- All reflex, daemon, reconciler entities in genesis — unchanged. They gain a surface they're bonded to via manifest declarations, but the entities themselves don't change.
- Bootstrap — unchanged. Surface bond creation during bootstrap already handles `surfaces_consumed` / `surfaces_provided`. The new surfaces are just more entries.

---

## Findings That Are Out of Scope

### Active vs declarative surface distinction in the surface eidos

The `surface` eidos currently has a `praxeis` array field. For declarative surfaces, this is empty. A future refinement could add a `surface_type: active | declarative` field, or a `contract_schema` field that describes the entity shapes consumers declare. This is schema evolution, not blocking.

### Reflex engine V11 conformance gaps

`reflex.rs` has several non-V11 patterns identified during research:
- `EventType` enum duplicates `ChangeEvent` variants (should be unified)
- `build_scope()` is a 130-line hardcoded match (could be data-driven)
- `glob_match()` is hand-rolled (~50 lines) instead of using a crate

These are engine internals, not ontological. The engine works. Refactoring it is a separate concern — possibly a future arc if the code becomes a maintenance burden.

### Dynamis as nervous system provider

This prompt positions dynamis as the provider of all three autonomic surfaces. An alternative design would have `ergon` provide reactivity and sensing (since ergon introduces the `reflex`, `trigger`, and `daemon` eide), with dynamis providing only reconciliation. The current design keeps the triad unified under one provider. If ergon's role as the "coordination surface" grows, revisit.

---

*Traces to: KOSMOGONIA V11 §Reconciler Pattern, PROMPT-RECONCILIATION-SURFACE.md (Arc 2), PROMPT-FEDERATION-DISSOLUTION.md (Arc 3)*
