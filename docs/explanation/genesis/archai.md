# The Five Archai

The archai are the foundational forms that define the grammar of existence in kosmos.

---

## Overview

Every entity, relationship, and operation in kosmos traces back to five foundational types:

| Arche | Greek | Role | Constitutional |
|-------|-------|------|----------------|
| **Eidos** | εἶδος (form) | What things ARE | Yes |
| **Desmos** | δεσμός (bond) | How things RELATE | Yes |
| **Stoicheion** | στοιχεῖον (element) | What things DO | Yes |
| **Typos** | τύπος (mold) | How things are CREATED | No |
| **Dynamis** | δύναμις (power) | What substrate PROVIDES | No |

The first three are **constitutional** — they define the grammar and cannot be derived. The last two are **derivable** — they use the grammar to enable composition and capability.

---

## Eidos: Forms of Being

An **eidos** defines what can exist. It specifies:
- A unique type name
- Fields with types and constraints
- Whether instances are constitutional or derivable

### Location

`genesis/arche/eidos.yaml` — Core type definitions

### Self-Grounding

Eidos is self-grounding: `eidos/eidos` is itself an eidos. This is the prime germination (Stage 0) — the first thing that must exist.

```yaml
- eidos: eidos
  id: eidos/eidos
  data:
    name: eidos
    description: "Form definition — what can exist"
    fields:
      name: { type: string, required: true }
      description: { type: string }
      fields: { type: object }
      constitutional: { type: boolean, default: false }
```

### Example: Theoria

```yaml
- eidos: eidos
  id: eidos/theoria
  data:
    name: theoria
    description: "Crystallized understanding"
    fields:
      insight:
        type: string
        required: true
      domain:
        type: string
        required: true
      status:
        type: enum
        values: [provisional, stable, superseded]
        default: provisional
```

### Key Eide in Genesis

| Eidos | Topos | Purpose |
|-------|-------|---------|
| `eidos/praxis` | arche | Composed action (MCP tool) |
| `eidos/theoria` | nous | Crystallized understanding |
| `eidos/oikos` | politeia | Trust boundary |
| `eidos/parousia` | soma | Dwelling presence |
| `eidos/journey` | nous | Teleological container |
| `eidos/typos` | spora | Composition template |

---

## Desmos: Bonds of Relation

A **desmos** defines how entities relate. It specifies:
- Source and target eidos types
- Cardinality constraints
- Whether the bond is symmetric
- Optional data schema for bond metadata

### Location

`genesis/arche/desmos.yaml` — Core bond type definitions

### Example: Crystallized-In

```yaml
- eidos: desmos
  id: desmos/crystallized-in
  data:
    name: crystallized-in
    description: "Theoria belongs to an oikos"
    from_eidos: theoria
    to_eidos: oikos
    cardinality: many-to-one
    symmetric: false
```

### Key Desmoi in Genesis

| Desmos | From → To | Purpose |
|--------|-----------|---------|
| `composed-from` | entity → typos | Provenance tracking |
| `authorized-by` | entity → phasis | Authorization chain |
| `dwells-in` | parousia → oikos | Presence location |
| `member-of` | prosopon → oikos | Oikos membership |
| `has-attainment` | parousia → attainment | Capability grant |
| `requires-attainment` | stoicheion → attainment | Access gating |

### Bond Graph as Access Control

Visibility in kosmos is determined by reachability through the bond graph. If a prosopon cannot traverse from their dwelling position to an entity, they cannot see it.

---

## Stoicheion: Steps of Action

A **stoicheion** defines an atomic operation. It specifies:
- Parameters with types and validation
- Power tier (capability level)
- Whether it's internal or external

### Location

`genesis/stoicheia-portable/eide/stoicheion.yaml` — Complete step vocabulary

### The Tier Model

| Tier | Name | Capability | Examples |
|------|------|------------|----------|
| 0 | Elemental | Pure data flow | `set`, `return`, `assert` |
| 1 | Aggregate | Control flow | `switch`, `for_each`, `filter` |
| 2 | Compositional | Entity operations | `find`, `compose`, `bind` |
| 3 | Generative | Actuality bridging | `infer`, `emit`, `signal` |

### Internal vs External

Some stoicheia are **internal** — only the interpreter can invoke them:
- `arise` — Creates entities (composition must use `compose`)
- `infer` — Raw LLM call (must use `governed-inference`)

This enforces constitutional constraints at the grammar level.

### Example: Surface

```yaml
- eidos: stoicheion
  id: stoicheion/surface
  data:
    name: surface
    tier: 1
    description: "Find entities by semantic proximity"
    fields:
      query:
        type: string
        required: true
      threshold:
        type: number
        default: 0.7
      limit:
        type: integer
        default: 10
      bind_to:
        type: string
        required: true
```

---

## Typos: Molds for Creation

A **typos** defines how to compose an entity. It specifies:
- Target eidos (what to create)
- Slots with fill patterns
- Bonds to create automatically

### Location

`genesis/{topos}/typos/` — Per-topos typos definitions

### Fill Patterns

| Pattern | Source | Use |
|---------|--------|-----|
| `literal` | Input value directly | Constitutional content |
| `computed` | Expression evaluation | Derived values |
| `queried` | Graph traversal | Context-dependent |
| `generated` | LLM inference | AI-created content |
| `composed` | Recursive composition | Nested structures |

### Example: Typos-Def-Theoria

```yaml
- eidos: typos
  id: typos/typos-def-theoria
  data:
    name: typos-def-theoria
    target_eidos: theoria
    slots:
      insight:
        pattern: literal
        required: true
      domain:
        pattern: literal
        required: true
      status:
        pattern: literal
        default: provisional
    bonds:
      - desmos: crystallized-in
        to_context: _oikos
```

### Routing by Shape

The demiurge routes composition based on typos shape:
- Has `target_eidos` → entity composition
- Has `slots` only → graph composition (content generation)
- Has `template` only → template rendering

---

## Dynamis: Powers of Substrate

A **dynamis** defines what the substrate provides. It specifies:
- Capability domains (db, fs, net, crypto, etc.)
- Functions within each domain
- Required attainments for access

### Location

`genesis/spora/spora.yaml` (stage-1-dynamis)

### Domains

| Domain | Capabilities |
|--------|--------------|
| `db` | find, bind, update, dissolve |
| `fs` | read, write, delete, watch |
| `net` | http, websocket |
| `crypto` | sign, verify, hash |
| `manteia` | infer (governed) |
| `aisthesis` | surface, index (embeddings) |

### Access Gating

Tier 3 stoicheia require attainments. During execution:

```
stoicheion/infer → requires-attainment → attainment/use-api
                                              ↑
parousia → has-attainment ────────────────────┘
```

If the parousia lacks the attainment, execution is denied.

---

## Relationships Between Archai

```
eidos (defines what exists)
  ↓ instances are
entities
  ↓ connected by
desmos (defines relationships)
  ↓ organized into
bonds
  ↓ operated on by
stoicheion (defines operations)
  ↓ composed into
praxis (MCP tools)
  ↓ creates via
typos (composition templates)
  ↓ using
dynamis (substrate capabilities)
```

---

## See Also

- [Genesis Overview](index.md) — The constitutional layer
- [Bootstrap Process](bootstrap.md) — How archai are loaded
- [KOSMOGONIA.md](../../../genesis/KOSMOGONIA.md) — Constitutional root

---

*The archai are the alphabet of kosmos. Everything else is spelled from them.*
