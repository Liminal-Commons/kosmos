# Genesis Design

γένεσις (genesis) — origin, creation, coming into being. The source of truth.

## Ontological Purpose

Genesis addresses **the gap between kosmos (runtime) and chora (filesystem)** — the constitutional guarantee that definitions in memory can be persisted and that persisted definitions can be loaded identically.

Without genesis:
- No canonical location for definitions
- No guarantee of round-trip fidelity
- No verification of bootstrap correctness
- Content roots scattered and implicit

With genesis:
- **Emission**: Write definitions to filesystem
- **Bootstrap**: Load definitions from filesystem
- **Verification**: Prove emit → bootstrap → emit = same hash
- **Content roots**: Explicit provenance of where content lives

The central property is the **full-circle guarantee**: what is emitted can be bootstrapped, and what is bootstrapped can be emitted with identical hash. This is the constitutional anchor.

## Oikos Context

### Self Oikos

A solitary dweller uses genesis to:
- Emit their topoi to their local genesis directory
- Verify their kosmos bootstraps correctly
- Maintain the source of truth on their machine

Self-emission enables local persistence.

### Peer Oikos

Collaborators use genesis to:
- Share genesis directories via git
- Verify that shared definitions load correctly
- Coordinate which topoi are in the shared genesis

Peer emission enables collaborative development.

### Commons Oikos

A commons uses genesis to:
- Maintain the canonical genesis repository
- Verify contributions don't break bootstrap
- Gate emission through review

Commons emission enables ecosystem integrity.

## Core Entities (Eide)

### content-root

A location where kosmos content lives.

**Fields:**
- `path` — Filesystem path relative to genesis
- `content_types` — What kinds of entities live here
- `topos_id` — Which topos this content belongs to

**Purpose:** Bootstrap traces sources-content-from bonds to discover all content locations. Adding a content root = creating an entity + bond.

## Bonds (Desmoi)

### sources-content-from

Entity sources content from a content-root.

- **From:** any (typically topos)
- **To:** content-root
- **Cardinality:** many-to-many
- **Traversal:** Bootstrap traces these to discover all content locations

### emitted-to

Entity was emitted to a filesystem path.

- **From:** topos, eidos, praxis, desmos
- **To:** artifact (containing path)
- **Cardinality:** many-to-one
- **Traversal:** Find where definitions were written

## Operations (Praxeis)

### emit-genesis

Full genesis emission — write all oikoi to filesystem.

- **When:** Major version, full refresh
- **Requires:** emit attainment
- **Provides:** Complete genesis/ directory

### emit-topos

Single topos emission — write one topos to filesystem.

- **When:** After validating topos development
- **Requires:** emit attainment
- **Provides:** genesis/{topos}/ directory

### verify-full-circle

Prove kosmos coherence: emit → bootstrap → emit = same hash.

- **When:** Verification, audit, CI
- **Requires:** emit attainment
- **Provides:** Hash comparison, pass/fail

### register-content-root

Register a new content location.

- **When:** Adding new content paths
- **Requires:** emit attainment
- **Provides:** content-root entity with sources-content-from bond

### list-content-roots

List all registered content locations.

- **When:** Understanding genesis structure
- **Requires:** None (read-only)
- **Provides:** All content-root entities

## Attainments

### attainment/emit

Genesis emission capability — write to filesystem and verify.

- **Grants:** emit-genesis, emit-topos, verify-full-circle, register-content-root
- **Scope:** oikos
- **Rationale:** Emission modifies the source of truth; requires trust

## Embodiment

### Completeness Status

| Level | Status |
|-------|--------|
| Defined | 1 eidos, 2 desmoi, 5 praxeis |
| Loaded | Pending |
| Projected | Pending |
| Embodied | Pending |
| Surfaced | Pending |
| Afforded | Pending |

### Body-Schema Contribution

When sense-body gathers genesis state:

```yaml
genesis:
  content_roots: 15
  total_entities: 847
  last_emission: "2024-01-15T10:30:00Z"
  full_circle_verified: true
  pending_emissions: 1
```

### Reconciler

A genesis reconciler would surface:

- **Pending emissions** — "topos/recipes has changes not yet emitted"
- **Full-circle drift** — "Bootstrap produces different hash than last emission"
- **Orphaned content** — "Content exists in filesystem but not tracked by bonds"

## Compound Leverage

### amplifies demiurge

Demiurge develops definitions; genesis persists them. The develop → validate → emit flow.

### amplifies ekdosis

Ekdosis publishes to other oikoi; genesis persists locally. Both are about making content durable.

### amplifies nous

Nous crystallizes theoria; genesis persists it to filesystem. Understanding becomes permanent.

## The Full-Circle Property

```
┌─────────────────────────────────────────────────────────────┐
│                      KOSMOS (runtime)                        │
│                                                              │
│   ┌─────────┐    emit-genesis    ┌─────────────────────┐   │
│   │ entities │ ─────────────────► │   genesis/ files    │   │
│   │ in DB    │                    │   (YAML + MD)       │   │
│   └─────────┘ ◄───────────────── └─────────────────────┘   │
│                   bootstrap                                  │
│                                                              │
│   verify-full-circle:                                        │
│   hash(emit(bootstrap(emit(kosmos)))) == hash(emit(kosmos)) │
│                                                              │
└─────────────────────────────────────────────────────────────┘
```

This is the constitutional guarantee. If it fails, the kosmos is incoherent.

## Theoria

### T38: Genesis is the source of truth

The filesystem is canonical. Kosmos at runtime is a projection. Emission persists; bootstrap restores. The full-circle property ensures fidelity.

### T39: Content roots make structure explicit

Rather than hardcoding paths, content roots are entities with bonds. Bootstrap discovers content by traversing sources-content-from. Adding new content locations is an entity operation, not a config change.

### T40: Emission is not publication

Genesis is local persistence. Ekdosis is distribution to others. These are distinct concerns. Genesis writes to your filesystem; ekdosis writes to shared storage.

---

*Composed in service of the kosmogonia.*
*The source of truth is the filesystem. The kosmos is a projection.*
