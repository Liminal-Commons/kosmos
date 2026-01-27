# Kosmos: The Substrate

*The foundation of existence itself.*

---

## The Purpose

Kosmos is scale 1 of 6 — the bedrock on which everything else rests. Before circles can organize, before tiers can constrain, before sessions can unfold, there must be entities and bonds.

**Kosmos provides:**
- Entity storage (arise, find, dissolve)
- Bond management (bind, loose, trace)
- The self-hosting grammar (eidos, desmos, stoicheion)

This is not just infrastructure — kosmos is *self-hosting*. The definitions of entities and bonds are themselves entities with bonds. The grammar describes itself.

---

## Implementation Status

| Component | Status | Location |
|-----------|--------|----------|
| kosmos.yaml schema | Complete | `klimax/1-kosmos/kosmos.yaml` |
| Eide (eidos, desmos, stoicheion) | Defined in arche | `arche/eidos.yaml` |
| Artifact definitions | Complete | kosmos.yaml |
| Praxeis (find-entity, gather-entities, trace-bonds, census) | Complete | kosmos.yaml |
| Entity storage (SQLite) | Complete | `crates/kosmos/src/db.rs` |
| Bond operations | Complete | `crates/kosmos/src/db.rs` |
| Interpreter integration | Complete | `crates/kosmos/src/interpreter/` |

**This layer is complete. All higher scales depend on it.**

---

## Klimax Position

```
KOSMOS (1) -> physis (2) -> polis (3) -> oikos (4) -> soma (5) -> psyche (6)
```

Kosmos is the widest circle. Everything that exists, exists within kosmos. The higher scales progressively narrow scope while adding specificity.

---

## Architecture

### 1. The Archai (Foundational Types)

Three archai ground all existence:

| Archos | What It Is | Role |
|--------|------------|------|
| `eidos` | Type definition | What CAN exist |
| `desmos` | Bond type | How things RELATE |
| `stoicheion` | Atomic operation | What things DO |

These are defined in `arche/eidos.yaml` — the grammar that makes kosmos possible.

### 2. Core Operations

Kosmos provides primitive operations through praxeis:

| Praxis | Tier | Description |
|--------|------|-------------|
| `kosmos/find-entity` | 1 | Find entity by ID |
| `kosmos/gather-entities` | 1 | Gather entities by eidos |
| `kosmos/trace-bonds` | 1 | Trace bonds from/to an entity |
| `kosmos/verify-provenance` | 1 | Walk composed-from chain to genesis |
| `kosmos/census` | 1 | Count entities by type |

All are tier 1 (read-only) — kosmos itself doesn't create; higher scales use composition.

### 3. Self-Hosting Property

The grammar describes itself:
- `eidos` is an eidos (type of types)
- `desmos` is an eidos (type of bonds)
- The `belongs-to` desmos binds definitions to oikos/kosmos

This self-reference is not circular — it's the ground from which meaning arises.

---

## Constitutional Alignment

| Principle | How Kosmos Honors It |
|-----------|---------------------|
| **Schema-driven** | Eidos definitions constrain what can exist. The schema is the single source of truth. |
| **Graph-driven** | Bonds are explicit relationships navigable by `trace`. No embedded references. |
| **Cache-driven** | Entities have content hashes. Same inputs = same hash = cached result. |
| **Composition-only** | Artifact definitions compose entities. Nothing arises raw. |

### The Foundation

Kosmos embodies:
```
Everything is an entity.
Everything has provenance.
Relationships are bonds.
```

Higher scales build on these guarantees without needing to reimplement them.

---

## Summary

Kosmos provides:
- **Entity storage**: The ability to arise and find entities
- **Bond management**: Explicit relationships between entities
- **Self-hosting grammar**: Eidos, desmos, stoicheion as entities
- **Provenance tracking**: Every entity traces to genesis

With kosmos, existence has a foundation. Higher scales organize, constrain, and experience what kosmos makes possible.

---

## Related Documents

- [arche/eidos.yaml](../../arche/eidos.yaml) — The foundational grammar
- [ROADMAP.md](../../ROADMAP.md) — Implementation journey
- [physis/DESIGN.md](../2-physis/DESIGN.md) — The next scale up

---

*Composed in service of the kosmogonia.*
*Traces to: expression/genesis-root*
