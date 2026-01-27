# Physis: The Natural Order

*What is possible before what is permitted.*

---

## The Purpose

Physis is scale 2 of 6 — the given constraints that kosmos obeys. This is not governance (that's polis). This is the physics of the kosmos: what CAN happen, not what SHOULD happen.

**Physis provides:**
- Tier system (capability constraints)
- Filter catalog (data transformations)
- Validation rules (what is well-formed)

A tier-0 praxis cannot call `infer` — not because it's forbidden, but because tier-0 doesn't include that capability. This is natural law, not policy.

---

## Implementation Status

| Component | Status | Location |
|-----------|--------|----------|
| physis.yaml schema | Complete | `klimax/2-physis/physis.yaml` |
| Eide (tier, filter, constraint) | Complete | physis.yaml |
| Tier definitions (0-3) | Complete | physis.yaml seeds |
| Filter catalog (30+ filters) | Complete | physis.yaml seeds |
| Artifact definitions | Complete | physis.yaml |
| Praxeis (list-tiers, list-filters, validate-tier) | Complete | physis.yaml |
| Tier enforcement in interpreter | Complete | `crates/kosmos/src/interpreter/steps.rs` |

**This layer is complete. Tier constraints are enforced at execution time.**

---

## Klimax Position

```
kosmos (1) -> PHYSIS (2) -> polis (3) -> oikos (4) -> soma (5) -> psyche (6)
```

Physis sits above kosmos (which provides existence) and below polis (which provides organization). Physis constrains what operations are possible; polis constrains who can perform them.

---

## Architecture

### 1. The Tier System

Four tiers form a capability hierarchy:

| Tier | Name | What It Enables |
|------|------|-----------------|
| 0 | Elemental | Pure data flow: `set`, `return`, `assert` |
| 1 | Aggregate | Collection ops: `find`, `gather`, `trace`, `filter` |
| 2 | Compositional | Creation: `compose`, `bind`, `call`, `switch`, `for_each` |
| 3 | Generative | External: `infer`, `embed`, `emit`, `spawn` |

Higher tiers include all lower tier capabilities. A tier-2 praxis can use tier-0, tier-1, and tier-2 stoicheia.

### 2. Filter Catalog

Filters are pure transformations used in expressions:
```
{{ value | filter_name(args) }}
```

Categories include:
- **String**: `lower`, `upper`, `trim`, `slugify`, `truncate`
- **Object**: `keys`, `values`, `get`, `merge`, `set_key`
- **Array**: `first`, `last`, `length`, `join`, `sort`, `unique`
- **Type**: `int`, `float`, `string`, `json`, `bool`
- **Date**: `now`, `format_date`

All filters are tier-0 — they're always available, have no side effects.

### 3. Tier Enforcement

The interpreter enforces tiers at execution time:
1. Praxis declares its tier in `praxis.tier`
2. Each step uses a stoicheion with a tier
3. If step.tier > praxis.tier, execution fails

This is not permission checking — it's capability limitation.

---

## Constitutional Alignment

| Principle | How Physis Honors It |
|-----------|---------------------|
| **Schema-driven** | Tier definitions declare what stoicheia are available. Filter catalog is schema-defined. |
| **Graph-driven** | Tiers and filters are entities with bonds to oikos/physis. |
| **Cache-driven** | Filter results are deterministic — same input = same output. |

### The Natural Order

Physis embodies:
```
Capability is not permission.
What you CAN do precedes what you MAY do.
Tiers constrain execution, not authorization.
```

---

## Summary

Physis provides:
- **Tiers**: Four levels of capability (elemental → generative)
- **Filters**: Pure data transformations for expressions
- **Validation**: What constitutes well-formed content

With physis, kosmos has natural law. Higher scales add social structure (polis) and intimate context (oikos), but they operate within physis constraints.

---

## Related Documents

- [kosmos/DESIGN.md](../1-kosmos/DESIGN.md) — The foundation below
- [polis/DESIGN.md](../3-polis/DESIGN.md) — Social organization above
- [ROADMAP.md](../../ROADMAP.md) — Implementation journey

---

*Composed in service of the kosmogonia.*
*Traces to: expression/genesis-root*
