# Provenance Mechanism

How Axiom III (Traceability), Axiom IV (Self-Grounding), and Axiom V (Adequacy) are realized in the composition engine.

**This document is prescriptive.** It describes the target state. Where implementation diverges, the code has a gap.

---

## The Provenance Bonds

Every entity that arises through composition carries provenance bonds. These bonds ARE the entity's origin — traversable, verifiable, structural.

### typed-by

```
entity --[typed-by]--> eidos
```

**What it records**: The form this entity instantiates. Every entity has an eidos; the `typed-by` bond makes the relationship traversable rather than implicit.

**The existential test**: Can an entity exist without a type? No. Type determines what the entity IS — its fields, its valid bonds, its role in the graph. `typed-by` is constitutive for all entities.

**Self-grounding exception**: The eidos `eidos` cannot be `typed-by` itself at genesis — the type system is being built. This is the canonical self-grounding case. The bond is created for all other eide.

**Implementation**: Created by `compose_entity()` in `composition.rs`. Skipped only when `target_eidos == "eidos"`.

### composed-from

```
entity --[composed-from]--> typos/definition
```

**What it records**: The definition (typos) that produced this entity. Traces intent — why this entity exists, what template shaped it.

**The existential test**: Can an entity exist without a definition? During bootstrap, entities arise from spora definitions embedded in source files. During runtime, entities arise from typos definitions in the graph. In both cases, the definition is what gives the entity its shape. `composed-from` is constitutive.

**Implementation**: Created by `compose_entity()` when `def_id` is present. Bootstrap entities have synthetic definitions (the spora pattern — inline data with target_eidos).

### authorized-by

```
entity --[authorized-by]--> session
```

**What it records**: The session context under which this entity was composed. Traces WHO authorized the composition — the prosopon's session carries their identity and dwelling position.

**The existential test**: Can an entity exist without authorization? During bootstrap, no session exists yet — the genesis root signature IS the authorization. During runtime, every composition happens within a session. `authorized-by` is constitutive when available (Axiom V: Adequacy).

**Self-grounding exception**: Bootstrap entities arise before session infrastructure exists. They carry genesis-root authorization implicitly (the signed spora). As the klimax unfolds, session becomes available and subsequent entities carry explicit `authorized-by` bonds.

**Implementation**: Created by `compose_entity()` when `dwelling.session_id` is present in scope. Absent during bootstrap germination.

### depends-on

```
entity --[depends-on]--> dependency_entity
```

**What it records**: The entities this entity's composition depended on — slot fills that were resolved from the graph, composed sub-entities, queried dependencies.

**The existential test**: Can an entity exist without dependencies? Yes — many entities are self-contained. `depends-on` is constitutive only when the entity's composition actually resolved slots from other entities. The bond carries `slot_name` metadata identifying which slot created the dependency.

**DAG enforcement**: Before creating a `depends-on` bond, `compose_entity()` traces the transitive `depends-on` graph from the target to verify no circular dependency. Circular composition is a hard error.

**Implementation**: Created by `compose_entity()` for each entry in `composed.dependency_bonds`. Validated against cycles via `trace_bonds()`.

### crystallized-in

```
theoria --[crystallized-in]--> oikos
```

**What it records**: The dwelling context where understanding was crystallized. Specific to theoria entities — connects understanding to the place where it arose.

**The existential test**: Can a theoria exist without a dwelling context? Theoria crystallizes through dwelling — the oikos IS the context that gave rise to the understanding. `crystallized-in` is constitutive for theoria.

**Implementation**: Created by the `crystallize-theoria` praxis, not by `compose_entity()` directly. This is domain-specific provenance layered on top of the general composition provenance.

---

## The Self-Grounding Boundary

Axiom IV states: *The ground does not ground itself.*

Provenance infrastructure — the entities that constitute the system through which provenance flows — cannot carry full provenance bonds because they ARE what provenance is made of.

### What constitutes provenance infrastructure

| Entity | Why it's self-grounding |
|--------|------------------------|
| `eidos/eidos` | The type of types. Cannot be typed by a type system that doesn't exist yet. |
| `eidos/desmos` | The bond type bond. Cannot be bonded before bonds exist. |
| `eidos/stoicheion` | The step type type. Steps are the mechanism of composition. |
| Genesis-root phasis | The primordial authorization. No prior phasis authorizes it. |
| First oikos | The primordial dwelling. No prior dwelling context exists. |
| First prosopon | The primordial dweller. Transcendent to the klimax being established. |

### The provenance these entities carry

Self-grounding entities carry **reduced provenance** — whatever the circumstances make available:

- **typed-by**: Present for all except `eidos/eidos` (which IS the type system)
- **composed-from**: Present when a definition exists (synthetic spora definition for bootstrap)
- **authorized-by**: Absent — no session exists during genesis
- **depends-on**: Absent — no graph to resolve dependencies from

As bootstrap proceeds and infrastructure comes into being, subsequent entities carry progressively fuller provenance chains.

---

## The Provenance Depth Gradient

Provenance depth increases as the klimax descends from cosmic to individual:

| Klimax Scale | Provenance Depth | Why |
|-------------|-----------------|-----|
| **kosmos** (1) | Minimal | Self-grounding boundary. Archai, genesis root. |
| **physis** (2) | Reduced | Substrate definitions. Type system exists but session does not. |
| **polis** (3) | Moderate | Governance infrastructure. First prosopa and oikoi co-arise. |
| **oikos** (4) | Full | Session exists. All four provenance bonds available. |
| **soma** (5) | Full | Parousia composition. Full dwelling context. |
| **psyche** (6) | Full | Individual entities. Richest provenance chains. |

The gradient is not a rule to enforce — it is a structural fact that emerges from the self-grounding axiom. Earlier klimax scales lack infrastructure that later scales can use.

---

## Composition Engine Path

All entity creation flows through one path: `compose_entity()` (pub(crate)).

```
compose_entity(ctx, scope, definition, inputs)
    ├── compose_data()          — resolve slots, fill template, merge inputs
    ├── content_hash()          — deterministic identity from content
    ├── ctx.arise_entity()      — raw entity creation (internal only)
    ├── create_bond(typed-by)   — unless eidos == "eidos"
    ├── create_bond(composed-from) — if def_id present
    ├── create_bond(authorized-by) — if session_id present
    ├── create_bond(depends-on)    — for each dependency, with DAG check
    └── change_notification()   — fire ChangeEvent::EntityChanged
```

Bootstrap and runtime both use this path. Bootstrap uses `bootstrap_arise()` which constructs a synthetic definition and calls `compose_entity()`. Runtime uses praxeis that invoke `compose_entity()` through the interpreter.

---

## Axiom Realization Summary

| Axiom | How It's Realized |
|-------|-------------------|
| **III: Traceability** | Four bond types (typed-by, composed-from, authorized-by, depends-on) make every entity's origin traversable. Trace far enough and you reach genesis or the self-grounding boundary. |
| **IV: Self-Grounding** | Constitutional infrastructure carries reduced provenance. `compose_entity()` creates whatever bonds the context provides — skipping typed-by for eidos/eidos, skipping authorized-by when no session exists. |
| **V: Adequacy** | `compose_entity()` creates all bonds that are both constitutive and available. It never omits a bond it could create, and never fails for a bond it cannot. The two dimensions (ontological + circumstantial) are structural in the code. |

---

*Traces to: KOSMOGONIA Axioms III, IV, V; T12 (one right way to arise); composition.rs*
*Created: 2026-02-21*
