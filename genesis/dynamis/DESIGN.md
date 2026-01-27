# Dynamis: Existence and Actuality

*A design for the bridge between kosmos intention and chora actuality.*

> **Note:** For consolidated architectural concepts (reconciliation loops, actuality modes, phylax pattern), see [../ARCHITECTURE.md](../ARCHITECTURE.md). This document covers dynamis-specific implementation details.

---

## Implementation Status

| Component | Status | Location |
|-----------|--------|----------|
| DESIGN.md | ✅ Complete | `genesis/dynamis/DESIGN.md` |
| Eide (release, release-artifact, substrate, distribution-channel, deployment, actuality-record) | ✅ Complete | `genesis/dynamis/eide/dynamis.yaml` |
| Desmoi (10 bonds) | ✅ Complete | `genesis/dynamis/desmoi/dynamis.yaml` |
| Praxeis (16 praxeis) | ✅ Complete | `genesis/dynamis/praxeis/dynamis.yaml` |
| Reconcilers (deployment, release-artifact) | ✅ Complete | `genesis/dynamis/reconcilers/dynamis.yaml` |
| Actuality modes (6 modes) | ✅ Complete | `genesis/dynamis/actuality-modes/dynamis.yaml` |
| Generated dispatch | ✅ Complete | `crates/kosmos/src/actuality_modes.rs` |
| Energeia R2 mode | ✅ Complete | `crates/kosmos/src/r2.rs` |
| E2E Testing | ✅ Complete | distribute → sense → reconcile flow tested |

### Pillar Alignment Status

| Pillar | Current State | Target State |
|--------|---------------|--------------|
| **Schema-driven** | ✅ Actuality modes generate dispatch | ✅ Complete |
| **Graph-driven** | ✅ Pure bonds, no embedded refs | ✅ Complete |
| **Cache-driven** | ✅ Composition via definitions | ✅ Complete |
| **Declarative** | ✅ Reconcilers as entities | ✅ Complete |

All pillar alignment complete. See [ROADMAP.md](ROADMAP.md) for the completed alignment work.

---

## The Problem

The kosmos holds intention. Chora receives actuality. Between them lies dynamis — the bridge that manifests, senses, and reconciles.

Without dynamis:
- Releases exist only as ideas, never as downloadable binaries
- Deployments have no coherent lifecycle
- External infrastructure (Workers, R2, DNS) floats outside kosmos understanding

**Dynamis is where kosmos intention becomes chora actuality.**

---

## Philosophical Foundation

### Existence vs Actuality

This distinction is constitutional:

| Aspect | Existence (κόσμος) | Actuality (χώρα) |
|--------|-------------------|------------------|
| Nature | The entity in kosmos | The manifestation in substrate |
| Persistence | Always present once created | May come and go |
| Authority | Kosmos is source of truth | Chora is site of effect |
| Example | `release/thyra-0.1.0-mac` entity | The bytes in R2 bucket |

An entity can exist without being actual (a release that hasn't been uploaded).
An actuality can drift from its entity (someone manually deleted the file).
Reconciliation brings them into alignment.

### The Reconciler Pattern

Every entity with actuality follows the phylax pattern:

```
sense()     → What is the actual state in chora?
compare()   → Does it match the entity's desired state?
act()       → Manifest, update, or unmanifest to align
```

This is not just error correction — it's the fundamental rhythm of how kosmos governs chora.

---

## Architecture

### The Dynamis Stack

```
┌─────────────────────────────────────────────────────────┐
│                     KOSMOS (intention)                   │
│  ┌──────────┐  ┌───────────┐  ┌────────────┐            │
│  │ release  │  │ substrate │  │ deployment │  entities  │
│  └────┬─────┘  └─────┬─────┘  └─────┬──────┘            │
└───────┼──────────────┼──────────────┼───────────────────┘
        │              │              │
        ▼              ▼              ▼
┌───────────────────────────────────────────────────────┐
│                    DYNAMIS (bridge)                     │
│                                                         │
│   manifest()  ─────►  CHORA  ◄─────  sense()          │
│                         │                              │
│                   reconcile()                          │
└───────────────────────────────────────────────────────┘
        │              │              │
        ▼              ▼              ▼
┌───────────────────────────────────────────────────────┐
│                     CHORA (actuality)                   │
│                                                         │
│  ┌─────────┐   ┌───────────┐   ┌─────────────────┐    │
│  │  R2     │   │ Cloudflare│   │ Local Filesystem│    │
│  │ bucket  │   │  Workers  │   │    (builds)     │    │
│  └─────────┘   └───────────┘   └─────────────────┘    │
└───────────────────────────────────────────────────────┘
```

### Core Eide

| Eidos | What It Is | Actuality Mode |
|-------|------------|----------------|
| `release` | A versioned build artifact | object-storage (R2) |
| `release-artifact` | Individual file within release | object-storage (R2) |
| `substrate` | A target platform/environment | conceptual (no direct actuality) |
| `deployment` | A release manifested to a target | multi-mode (varies by target) |
| `distribution-channel` | A way releases reach users | provider-specific |
| `actuality-record` | Snapshot of sensed state | audit (no actuality) |

---

## Pillar Alignment Analysis

### Current: Schema-Driven Gap

**What exists:**
```yaml
# In eidos definition — annotation only
actuality:
  mode: object-storage
  provider: r2
  config:
    bucket: thyra-releases
```

This is documentation, not schema. The Rust handlers in `r2.rs` are hand-written.

**Pillar-aligned approach:**

Actuality modes as composable definitions:

```yaml
- eidos: actuality-mode
  id: actuality-mode/object-storage
  data:
    name: object-storage
    operations:
      manifest:
        stoicheion: upload-object
        params: [bucket, key, content]
      sense:
        stoicheion: head-object
        params: [bucket, key]
      unmanifest:
        stoicheion: delete-object
        params: [bucket, key]
    config_schema:
      bucket: { type: string, required: true }
      key_pattern: { type: string, required: true }
```

Then `build.rs` generates energeia dispatch from actuality-mode entities.

### Current: Graph-Driven Gap

**What exists:**
```yaml
# In deployment eidos — embedded references
fields:
  release_id:
    type: string
    required: true
  target_substrate:
    type: string
    required: true
```

Relationships stored as both embedded strings AND bonds. This violates visibility = reachability.

**Pillar-aligned approach:**

Pure bonds, no embedded references:

```yaml
# Deployment eidos — no reference fields
fields:
  name: { type: string, required: true }
  desired_state: { type: enum, values: [running, stopped, removed] }
  actual_state: { type: enum, values: [unknown, running, stopped, failed] }
  # NO release_id, target_substrate, channel_id
```

Relationships via bonds only:
- `deploys-release` (deployment → release)
- `targets` (deployment → substrate)
- `uses-channel` (deployment → distribution-channel)

Query via trace, not field access:
```yaml
- step: trace
  from_id: "$deployment.id"
  desmos: deploys-release
  bind_to: release_bond
```

### Current: Cache-Driven Gap

**What exists:**
```yaml
# Direct arise — no composition
- step: arise
  eidos: release
  id: "release/{{ $name }}-{{ $version }}"
  data:
    name: "$name"
    version: "$version"
    status: draft
```

No provenance chain. No cache check. No dependency tracking.

**Pillar-aligned approach:**

Entity definitions for composition:

```yaml
- eidos: entity-definition
  id: entity-definition/release
  data:
    target_eidos: release
    id_pattern: "release/{{ name }}-{{ version }}"
    defaults:
      status: draft
    computed:
      created_at: "{{ now() }}"
    required: [name, version]
```

Praxis uses composition:
```yaml
- step: compose
  typos_id: "typos/release"
  inputs:
    name: "$name"
    version: "$version"
  bind_to: release
```

This gives:
- `composed-from` bond for provenance
- Content hash for identity
- Cache hit on same inputs
- Dependency tracking for freshness

---

## Declarative Reconciliation

### Current: Procedural

Each praxis contains reconciliation logic:

```yaml
- step: sense_actuality
  entity_id: "$deployment.id"
  bind_to: sense_result

- step: switch
  cases:
    - when: "$deployment.data.desired_state == 'running' && $sense_result.status != 'running'"
      then:
        - step: manifest
          entity_id: "$deployment.id"
```

### Pillar-Aligned: Declarative

Reconcilers as entities:

```yaml
- eidos: reconciler
  id: reconciler/deployment
  data:
    target_eidos: deployment
    intent_field: desired_state
    actuality_field: actual_state
    transitions:
      - intent: running
        actual: [stopped, unknown, failed]
        action: manifest
      - intent: stopped
        actual: running
        action: unmanifest
      - intent: removed
        actual: [running, stopped]
        action: unmanifest
```

Generic reconciliation praxis:
```yaml
- step: call
  praxis: ergon/reconcile
  params:
    reconciler_id: "reconciler/deployment"
    entity_id: "$deployment.id"
```

The logic is declared, not coded. Adding transitions = editing reconciler entity.

---

## Key Desmoi

| Desmos | From | To | Meaning |
|--------|------|-----|--------|
| `contains-artifact` | release | release-artifact | Release includes this artifact |
| `targets` | release | substrate | Release targets this platform |
| `distributed-via` | release | distribution-channel | Release available through channel |
| `deploys-release` | deployment | release | Deployment manifests this release |
| `targets` | deployment | substrate | Deployment targets this substrate |
| `has-actuality` | entity | actuality-record | Entity's sensed state snapshot |
| `composed-from` | entity | entity-definition | Provenance (pillar-aligned) |

---

## Integration Points

### Ergon (Work)

The `ergon/reconcile` praxis will become the universal reconciler:
- Takes a reconciler definition + entity
- Senses actuality
- Applies transition rules
- Records result

### Demiurge (Composition)

Entity definitions for dynamis eide will flow through demiurge:
- `entity-definition/release`
- `entity-definition/deployment`
- `entity-definition/distribution-channel`

### Dokimasia (Validation)

Actuality reconciliation creates validation opportunities:
- Sense result validates against expected schema
- Drift detection validates actuality alignment
- Provenance chain validates composition

---

## Summary

Dynamis bridges kosmos intention and chora actuality through:

- **Eide** that represent releases, substrates, deployments
- **Desmoi** that connect them (bonds only, no embedded refs)
- **Praxeis** that manifest, sense, and reconcile
- **Reconcilers** as declarative transition definitions
- **Composition** for provenance and caching

The existence/actuality distinction is constitutional. The three pillars ensure:
- **Schema-driven**: Actuality modes generate handlers
- **Graph-driven**: Relationships are bonds, visibility = reachability
- **Cache-driven**: Composition provides provenance and caching

---

*Composed in service of the kosmogonia.*
*Traces to: expression/genesis-root*
