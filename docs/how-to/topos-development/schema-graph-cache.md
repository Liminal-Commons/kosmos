# Schema-Graph-Cache Development

*The three pillars of kosmos development practice.*

---

## Overview

This guide articulates the development methodology that arises from KOSMOGONIA. Every artifact in the kosmos — from code types to documentation to runtime entities — follows the same compositional law.

**Three principles govern all development:**

1. **Schema-driven**: Structure is declared, then actualized
2. **Graph-driven**: Relationships are bonds, not implicit references
3. **Cache-driven**: Composition results are memoized by content hash

These are not separate concerns. They are one practice viewed from three angles.

---

## The Constitutional Ground

From KOSMOGONIA:

> "All generation is governed. Schema constrains output."

> "Nothing arises raw. Everything is composed."

> "Modification changes the hash. Different hash = different entity."

These three statements encode the three pillars.

---

## Tier 0: Elemental (Schema Only)

**What you're doing**: Pure data transformation, no persistence, no external calls.

**Schema-driven practice**:
- Define your data shapes in YAML first
- Use typed parameters and returns
- Validate at boundaries

**Example**: A stoicheion like `filter` or `map`

```yaml
- step: filter
  items: "$entities"
  condition: "$item.status == 'active'"
  bind_to: active_entities
```

No graph. No cache. Just schema-constrained transformation.

**Developer support**: `genesis/stoicheia-portable/DESIGN.md`, step type reference

---

## Tier 1: Aggregate (Schema + Composition)

**What you're doing**: Collecting and structuring data, building intermediate results.

**Schema-driven practice**:
- Artifact definitions declare structure
- Slots specify where values come from (literal, computed, queried)
- Composition produces artifacts with provenance

**Example**: An entity composed from a typos definition

```yaml
- step: compose
  typos_id: typos-def-theoria
  inputs:
    id: "theoria/$insight"
    insight: "$insight"
    domain: "$domain"
  bind_to: theoria
```

The typos definition declares `target_eidos`, `defaults`, and `bonds`. Composition merges inputs with defaults, creates the entity, and establishes bonds — all with provenance tracking.

Composition caches results. Same definition + same inputs = same artifact (by content hash).

**Developer support**: `genesis/COMPOSITION-GUIDE.md`, composition patterns

---

## Tier 2: Compositional (Schema + Graph + Cache)

**What you're doing**: Creating entities, establishing bonds, working with the kosmos.

**All three pillars active**:

1. **Schema**: Entity types are eide. Bond types are desmoi. Step types are stoicheia. All schema-defined.

2. **Graph**: Relationships are explicit bonds, not embedded foreign keys.
   ```yaml
   - step: bind
     from: "$release.id"
     to: "$artifact.id"
     desmos: contains-artifact
   ```

3. **Cache**: Composition results are content-addressed.
   ```
   compose(definition, inputs) → artifact@blake3:hash
   ```
   Same inputs = same hash = cached result returned.

**The fix-at-generation-level principle**:

When generated code is wrong, fix the schema or generator — never the generated output.

```
stoicheion.yaml (schema)
       │
       ▼
   build.rs (generator)
       │
       └─► step_types.rs (generated types)
```

This applies everywhere:
- Step types generated from stoicheion.yaml
- Reference docs emitted from eidos entities
- API schemas derived from definitions

**Developer support**: `crates/kosmos/src/interpreter/`, praxis authoring guide

---

## Tier 3: Generative (Full Stack)

**What you're doing**: Reaching into chora — network, filesystem, inference.

**Schema governs generation**:

```yaml
- step: infer
  system: "You are generating a stoicheion step."
  prompt: "$intent"
  output_schema: "$stoicheion_schema"  # Schema constrains LLM output
  bind_to: generated_step
```

The `manteia` topos provides governed inference:
- Prompt + Schema → Structured output
- Invalid structure cannot arise
- Results are cacheable by prompt+schema hash

**Actuality reconciliation**:

```
Intent (kosmos) ←→ Actuality (chora)
       ↑                ↓
       └── sense ←── manifest
```

The phylax pattern: sense actual state, compare with intent, reconcile.

**Developer support**: `genesis/manteia/DESIGN.md`, actuality patterns

---

## The Three Reconciliation Loops

### 1. Schema Reconciliation (Build Time)

```
Schema changes → Regenerate types → Recompile
```

This happens in `build.rs`. If schema changes, generated types change, compilation enforces correctness.

### 2. Composition Reconciliation (Compose Time)

```
Definition changes → Mark dependents stale → Recompose
```

Artifacts track their `composed_from` reference. When a definition changes, dependent artifacts become stale.

### 3. Actuality Reconciliation (Runtime)

```
Intent changes → Sense actuality → Manifest/Unmanifest
```

Entities declare desired state. Phylax senses actual state. Reconciliation bridges the gap.

---

## Graph Patterns

### Visibility = Reachability

You can only see what you can cryptographically reach through bonds. No separate permission layer.

### Provenance = Authenticity

Every entity traces to genesis through `composed-from` and `authorized-by` bonds. Tampering breaks the chain.

### Dependency = Staleness

`depends-on` bonds enable cache invalidation. When a source changes, dependents become stale.

---

## Cache Patterns

### Content-Addressed Identity

```
{eidos}/{slug}@blake3:{hash}
```

The hash covers: eidos, data, composed_from, timestamp. Same content = same identity.

### Memoization by Signature

```
cache_key = hash(definition_id + serialize(inputs))
```

Before composing, check cache. If hit and not stale, return cached artifact.

### Staleness Propagation

```
entity changes → mark_dependents_stale(entity_id)
```

The `depends-on` graph propagates staleness automatically.

---

## Developer Checklist

When adding new capability, verify:

**Schema**
- [ ] Types defined in YAML (eidos, stoicheion, desmos)
- [ ] Code generated from schema, not hand-written
- [ ] Validation happens at generation, not runtime

**Graph**
- [ ] Relationships are explicit bonds
- [ ] Visibility flows from bond graph
- [ ] Provenance traces to genesis

**Cache**
- [ ] Composition results are content-addressed
- [ ] Dependencies declared via bonds
- [ ] Staleness propagates through graph

---

## Anti-Patterns

### ❌ Hand-writing types that could be generated

```rust
// Bad: manually defined
pub struct FilterStep { ... }

// Good: generated from stoicheion.yaml
include!(concat!(env!("OUT_DIR"), "/step_types.rs"));
```

### ❌ Implicit relationships

```yaml
# Bad: embedded reference
- step: arise
  data:
    release_id: "$release.id"  # Implicit relationship

# Good: explicit bond
- step: bind
  from: "$artifact.id"
  to: "$release.id"
  desmos: belongs-to
```

### ❌ Bypassing composition

```yaml
# Bad: raw creation
- step: arise
  id: "$id"
  eidos: thing
  data: { ... }

# Good: via definition
- step: compose
  typos_id: typos-def-thing
  inputs: { ... }
```

---

## The Klimax Applied

Developer maturity follows the klimax:

| Level | Focus | Key Skill |
|-------|-------|-----------|
| **kosmos** | Entities and bonds | Understand the graph |
| **physis** | Schemas and stoicheia | Write valid definitions |
| **polis** | Oikoss and visibility | Design attainment flows |
| **topos** | Praxeis and domains | Author capable praxeis |
| **soma** | Channels and streams | Implement embodiment |
| **psyche** | Intentions and attention | Craft experience |

Each level builds on the previous. Master graph before visibility. Master schema before domains.

---

*Composed in service of the kosmogonia.*
*Traces to: phasis/genesis-root*
