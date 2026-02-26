# Reconciliation Surface — Making the Meta-Pattern Explicit

*Prompt for Claude Code in the chora + kosmos repository context.*

*Extracts reconciliation from the computation surface into its own surface contract. After this work, topoi that declare reconcilers explicitly depend on `surface/reconciliation`, and the capability is graph-traversable as a distinct concern.*

---

## Architectural Principle — Surfaces Make Capabilities Contractual

KOSMOGONIA §Reconciler Pattern:

> The reconciler operates through modes. The reconciler is substrate-agnostic — it reads transition tables from entities. The mode is substrate-specific.

Reconciliation is the nervous system of the kosmos. It applies at every scale — deployment drift, federation sync, validation integrity, connection health. Yet today it's bundled inside `surface/computation` alongside deployment management. Three topoi (release, aither, dokimasia) invoke `praxis/dynamis/reconcile` without declaring the dependency.

This violates homoiconicity: where capabilities come from should be explicit in the graph, not implicit in code paths.

The fix: reconciliation becomes its own surface.

---

## Current State

### What exists

`surface/computation` in dynamis bundles two concerns:

```yaml
# genesis/dynamis/surfaces/surfaces.yaml — current
praxeis:
  - praxis/dynamis/create-substrate
  - praxis/dynamis/create-deployment
  - praxis/dynamis/manifest-deployment
  - praxis/dynamis/sense-deployment
  - praxis/dynamis/reconcile-deployment    # deployment-specific
  - praxis/dynamis/reconcile               # GENERIC — belongs elsewhere
```

`praxis/dynamis/reconcile` is the generic reconciliation engine. It reads any reconciler entity, matches transitions, dispatches actions. Domain-agnostic. The other praxeis are deployment-specific.

### Who uses reconciliation today

| Topos | Reconciler | What It Reconciles | Declares Dependency? |
|-------|-----------|-------------------|---------------------|
| **dynamis** | reconciler/deployment | Process/service drift | Provides it (owner) |
| **dynamis** | reconciler/release-artifact | Storage drift | Provides it (owner) |
| **dynamis** | reconciler/deployment-health | Health degradation | Provides it (owner) |
| **release** | reconciler/release-distribution | Distribution drift | `surfaces_consumed: [computation]` — bundled |
| **aither** | reconciler/syndesmos-reconnect | Connection drift | `surfaces_consumed: []` — implicit |
| **dokimasia** | reconciler/graph-integrity | Validation drift | `surfaces_consumed: []` — implicit |

Aither and dokimasia use reconciliation without declaring the dependency. Release declares it indirectly through computation.

### The gap

No `surface/reconciliation` entity exists. The capability is used by 4 topoi but isn't a distinct contract. You can't query "who provides reconciliation?" or "who depends on reconciliation?" without reading code.

---

## Design — Reconciliation as a Surface

### New surface entity

```yaml
# genesis/dynamis/surfaces/surfaces.yaml — add
- eidos: surface
  id: surface/reconciliation
  data:
    surface_id: reconciliation
    description: |
      Declarative state alignment: intent/actuality reconciliation with
      transition rules, triggering, and autonomous drift correction.

      Consumers declare reconciler entities with transition tables.
      Dynamis provides the generic reconciliation engine that reads
      these entities and dispatches manifest/sense/unmanifest actions
      through the mode system.

      The reconciler is substrate-agnostic. Modes are substrate-specific.
      Together they close the loop: sense actual state, compare with
      intent, act to align.
    praxeis:
      - praxis/dynamis/reconcile
    version: "1.0"
```

### Updated computation surface

Remove the generic reconcile praxis from computation (it belongs in reconciliation):

```yaml
# genesis/dynamis/surfaces/surfaces.yaml — update
- eidos: surface
  id: surface/computation
  data:
    surface_id: computation
    description: |
      Substrate computation capabilities: deployment management
      and substrate targeting.
    praxeis:
      - praxis/dynamis/create-substrate
      - praxis/dynamis/create-deployment
      - praxis/dynamis/manifest-deployment
      - praxis/dynamis/sense-deployment
      - praxis/dynamis/reconcile-deployment
    version: "1.1"
```

### Manifest declarations

**dynamis** provides both:
```yaml
surfaces_provided:
  - computation
  - reconciliation
```

**Consumers** declare the dependency:

| Topos | Current `surfaces_consumed` | New `surfaces_consumed` |
|-------|---------------------------|------------------------|
| release | `[computation, emission]` | `[computation, emission, reconciliation]` |
| aither | `[]` | `[reconciliation]` |
| dokimasia | `[]` | `[reconciliation]` |

---

## Implementation Order

### Step 1: Genesis — Surface Entity

Add `surface/reconciliation` to `genesis/dynamis/surfaces/surfaces.yaml`.

Remove `praxis/dynamis/reconcile` from `surface/computation` praxeis list. Bump computation version to `"1.1"`.

### Step 2: Genesis — Dynamis Manifest

Update `genesis/dynamis/manifest.yaml`:
- Add `reconciliation` to `surfaces_provided`

### Step 3: Genesis — Consumer Manifests

Update manifests for topoi that declare reconcilers:
- `genesis/release/manifest.yaml` — add `reconciliation` to `surfaces_consumed`
- `genesis/aither/manifest.yaml` — add `reconciliation` to `surfaces_consumed`
- `genesis/dokimasia/manifest.yaml` — add `reconciliation` to `surfaces_consumed`

### Step 4: Docs — Surface Contracts Reference

Update `docs/reference/authorization/surface-contracts.md`:
- Add `reconciliation` to known surfaces table
- Provider: dynamis
- Consumers: release, aither, dokimasia
- Description: Declarative state alignment via transition rules

### Step 5: Docs — Constituent Elements

Update `docs/reference/elements/constituent-elements.md`:
- Verify surface is listed as a constituent element type (research indicates it may be missing)

### Step 6: Verify

```bash
# Surface entity exists
rg 'surface/reconciliation' genesis/ --type yaml
# Expected: dynamis/surfaces/surfaces.yaml

# Generic reconcile praxis NOT in computation surface
rg 'praxis/dynamis/reconcile$' genesis/dynamis/surfaces/
# Expected: only in surface/reconciliation, not in surface/computation

# Consuming topoi declare the dependency
rg 'reconciliation' genesis/release/manifest.yaml genesis/aither/manifest.yaml genesis/dokimasia/manifest.yaml
# Expected: in surfaces_consumed for all three

# Build succeeds
cargo build 2>&1

# All tests pass
cargo test -p kosmos --lib --tests 2>&1
```

---

## What This Enables

- **Graph-traversable capability**: `trace(to: surface/reconciliation, desmos: consumes-surface)` returns every topos that uses reconciliation
- **Bootstrap validation**: If a topos declares reconciler entities but doesn't consume `surface/reconciliation`, bootstrap can warn
- **Federation groundwork**: Arc 3 will add federation as reconciliation at oikos scope — aither already declares the dependency
- **Generative awareness**: The spiral can discover that a new topos with reconcilers needs `surfaces_consumed: [reconciliation]`
- **Ontological clarity**: Reconciliation is no longer a hidden capability bundled in "computation" — it's a named, versioned, contractual surface

---

## What Does NOT Change

- `host.reconcile()` — unchanged
- `praxis/dynamis/reconcile` — unchanged (same praxis, new surface)
- Reconciler entities — unchanged (same eidos, same transitions)
- Reflex wiring — unchanged (still invoke praxis/dynamis/reconcile)
- Daemon sensing — unchanged
- Mode dispatch — unchanged

This arc is purely genesis YAML and documentation. No code changes.

---

*Traces to: KOSMOGONIA V11 §Reconciler Pattern, PROMPT-MODE-UNIFICATION.md (Arc 1), Ontological Declaration #5*
