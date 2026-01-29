# Kosmogonia V9

*The constitutional root. Everything derives from here.*

---

## The Seed

```
"for my babe, for the liberation of all. ever. eternally."

expressed_by: persona/victor
signature:    5fd550ad1d738802d38a2abfa802a2616695bc1e1c0c0d3287b6fd52ca9816893a17dca06bb1ad0631d502e16facebb70c9f3263ba7401887f46d9e8d7031601
public_key:   b196e54638c421529120fc10ebb3ea9b82f015ec768854364e7696613be4f70c
algorithm:    ed25519
```

This is the root expression. All provenance chains terminate here.

---

## The Receiving

χώρα (chora) receives. κόσμος (kosmos) is received.

This genesis establishes the kosmos that actualizes within chora. Everything that arises here traces back to this root. The composition chain terminates here. The signatures attest here.

---

## The Five Archai

Five foundational forms define existence:

| Arche | Greek | What It Is |
|-------|-------|------------|
| **Eidos** | εἶδος | Form — what things ARE (type schema) |
| **Typos** | τύπος | Mold — HOW things are made (composition template) |
| **Desmos** | δεσμός | Bond — how things RELATE |
| **Stoicheion** | στοιχεῖον | Element — what things DO (atomic operation) |
| **Dynamis** | δύναμις | Power — substrate capability that operations draw upon |

From these five, all else derives.

### The Reflexive Ground

Eidos is self-grounding: the eidos `eidos` specifies how to compose eide. From this reflexive ground, all structure unfolds.

### The Composition Triad

Three archai form the composition stack:

```
eidos (type)  →  typos (mold)  →  entity (instance)
     ↓              ↓                ↓
  "what CAN      "HOW to         "what IS"
   exist"        make one"
```

- **Eidos** declares fields, constraints, what properties an entity of this type can have
- **Typos** declares slots and fill methods — how to produce an entity
- **Entity** is the composed instance, with content hash and provenance bonds

A typos always produces an entity. The demiurge routes based on definition shape:

- **`target_eidos` specified** → entity composition (creates domain entity of that type)
- **`slots` without `target_eidos`** → graph composition (creates `artifact` entity with structured content)
- **`template` only** → template rendering (creates `artifact` entity with rendered content)

In all cases, an entity is produced with content hash and provenance. The routing determines which eidos — either the specified domain type or the generic `artifact` type. The chain is unbroken.

### The Relational Arche

**Desmos** defines how entities relate. Every relationship is a bond instance of a desmos type.

```
entity A  —[desmos-type]→  entity B
```

The bond graph emerges from entities and their desmoi. The graph is not itself an entity — it is the shape that appears when you trace bonds.

### The Operational Archai

Two archai define what things DO:

- **Stoicheion** — atomic, typed operation steps (the vocabulary)
- **Praxis** — composed sequences of stoicheia (the sentences)

Praxeis are defined as typoi targeting the praxis eidos. They specify which stoicheia to invoke, in what order, with what parameters.

### The Power Arche

**Dynamis** is substrate capability. Operations draw on power:

| Tier | Name | Dynamis Required | Character |
|------|------|------------------|-----------|
| 0 | Elemental | None | Pure computation, self-contained |
| 1 | Aggregate | None | Collection operations, memory only |
| 2 | Compositional | Kosmos dynamis | Entity/bond operations |
| 3 | Generative | Chora dynamis | Network, filesystem, inference |

**Portable** (Tier 0-1): Self-contained, runs anywhere.
**Anchored** (Tier 2-3): Requires the chora bridge.

---

## The Constitutional Pillars

Two pillars ground all access and trust:

### Visibility = Reachability

You can only perceive what you can cryptographically reach through the bond graph. There is no separate permission layer. The bond graph IS the access control graph.

### Authenticity = Provenance

Everything traces back to signed genesis through composition chains. Modification anywhere breaks the chain. Authenticity is verified, not asserted.

---

## The Development Pillars

Three pillars guide implementation:

| Pillar | Principle |
|--------|-----------|
| **Schema-driven** | Structure declared in eidos, then actualized |
| **Graph-driven** | Relationships are explicit desmoi |
| **Cache-driven** | Composition memoized by content hash |

These implement the constitutional pillars. Schema-driven ensures validity. Graph-driven ensures visibility = reachability. Cache-driven ensures authenticity through content-addressing.

---

## The Fill Methods

Slots in a typos are filled by **fill methods**:

| Method | What It Does | Used For |
|--------|--------------|----------|
| `literal` | Value is in the typos | Constitutional content, constants |
| `queried` | Fetch entity from graph | Referencing existing entities |
| `composed` | Invoke child typos | Building structure recursively |
| `generated` | LLM inference via manteia | Descriptions, documentation |

**Constitutional content** (eide, desmoi, stoicheia) uses `literal` only — it IS the ground.

**Derivable content** can use any method — it is built atop the ground.

---

## The Klimax

We build from container toward contained:

```
kosmos   — the substrate, entities and bonds
  │
  └─► physis   — the given, constraints and stoicheia
        │
        └─► polis   — the political, circles and governance
              │
              └─► oikos   — the household, dwelling and sessions
                    │
                    └─► soma   — the body, embodiment and sensing
                          │
                          └─► psyche   — the soul, the experiencer
```

Each scale establishes ambient context for the next. By the time psyche arrives, the receiving structure is complete.

### Oikos — Where Capability Dwells

At the oikos scale, capability has a home. An oikos is:
- **Dwelling**: A place where capability lives
- **Package**: A distributable unit with manifest

Oikoi declare what dynamis they require. The substrate provides or refuses.

### Oikos Lifecycle

An oikos progresses through states:

| State | Form | Location |
|-------|------|----------|
| **oikos-dev** | Working content | genesis/ filesystem |
| **oikos-prod** | Signed, versioned | kosmos graph + registry |
| **installed** | Loaded into kosmos | local kosmos.db |

The ekdosis flow (bake → sign → upload → publish) transitions oikos-dev to oikos-prod. Distribution delivers oikos-prod to other kosmoi.

### The Distribution Model

Distribution is federation. The same mechanism that syncs expressions, theoria, and ergon also delivers oikoi.

```
self/peer circle ──[stewards]──► commons circle ──[distributes]──► oikos-prod
                                       │
                                       │ (invitation or payment)
                                       ▼
                               user's circle ──[uses]──► oikos-prod
```

The flow:
1. Developer creates oikos in self/peer circle
2. Developer creates commons circle for distribution
3. Commons circle bonds to oikos-prod via `distributes`
4. User joins commons (invitation or payment gate)
5. Federation syncs reachable content through bond graph
6. oikos-prod arrives in user's kosmos

This is elegant because:
- Uses existing primitives (circles, bonds, invitations)
- Preserves visibility = reachability
- Distribution IS governance
- Payment fits naturally as a gate to joining
- Same pipe for all content types

Continuous sync enables time-sensitive execution. The mechanism that delivers oikoi also initiates ergon work.

### The Boundary Principle

Maximize what lives as oikos (YAML definitions). Minimize what requires Rust (interpreter) or TypeScript (UI).

```
Rust foundation ←──── oikos (YAML) ────► TypeScript UI
   (interpreter)     (definitions)        (presentation)
```

Push capability toward content, away from code. When something can be expressed as eidos/praxis, it should be.

---

## The Rendering Layer

Thyra (θύρα) — the door — mediates between kosmos and perception.

Rendering follows the homoiconic pattern: configuration that is usually implicit becomes entities with bonds.

| Eidos | What It Does |
|-------|--------------|
| **render-type** | Semantic category — how an eidos SHOULD appear |
| **renderer** | Implementation — component that renders a type, with loading strategy |

```
entity  →  [eidos]  →  render-type  →  renderer  →  visual form
```

### Render Strategies

Renderers declare a `render_strategy` that determines how they load:

| Strategy | Character |
|----------|-----------|
| `core` | Built-in, static import |
| `declarative` | Graph-driven from render-spec |
| `web-component` | Dynamic Custom Element |
| `wasm` | WebAssembly module |

This enables oikoi to provide their own renderers without core changes.

### Strategy-Specific Eide

Some eide serve specific strategies:

- **render-spec** — declarative template (for `declarative` strategy)
- **widget** — field-level display component (used within render-specs)

These are not top-level archai but domain-specific forms within thyra.

---

## The Composition Requirement

Nothing arises raw. Everything is composed.

```
compose(typos, inputs) → entity with provenance
```

The typos traces to its oikos. The oikos traces to genesis. Genesis is signed. The chain is complete.

---

## The Dwelling Requirement

Context is not passed. Context is position.

When an animus dwells in a circle:
- The circle is not a parameter
- The circle is the dwelling position
- Bonds flow from position automatically

The interpreter derives context from bond graph position. Position IS context.

---

## The Authenticity Requirement

Every entity has:
- Content hash (identity includes hash of content)
- `composed-from` bond (chain to typos)
- Composition timestamp

Modification changes the hash. Different hash = different entity. Tampering creates visibly different things.

---

## The Validity Requirement

All generation is governed. Schema constrains output.

```
prompt + schema → governed inference → valid output → artifact
```

Generation without schema constraint produces free-form text. This is permitted but exceptional. The default path ensures structural validity.

---

## The Genesis Structure

```
chora/
├── genesis/                    # Bootstrap content (loaded at startup)
│   ├── KOSMOGONIA.md           # This document (constitutional root)
│   ├── ARCHITECTURE.md         # Technical implementation guide
│   │
│   ├── arche/                  # Bootstrap archai definitions
│   │   ├── eidos.yaml          # Form definitions (including eidos itself)
│   │   ├── typos.yaml          # Mold definitions (composition templates)
│   │   ├── desmos.yaml         # Bond type definitions
│   │   ├── stoicheion.yaml     # Step type definitions
│   │   └── dynamis.yaml        # Power tier definitions
│   │
│   ├── klimax/                 # Scale documentation
│   │   └── ...                 # Each scale has DESIGN.md
│   │
│   ├── spora/                  # Bootstrap seed
│   │   └── spora.yaml
│   │
│   ├── stoicheia-portable/     # Portable step vocabulary
│   │
│   └── [oikoi]/                # Domain packages
│       ├── nous/               # Knowledge operations
│       ├── politeia/           # Governance
│       ├── propylon/           # Entry and invitations
│       ├── thyra/              # Interface and rendering
│       ├── demiurge/           # Composition
│       ├── hypostasis/         # Integrity and signing
│       ├── dokimasia/          # Validation
│       ├── manteia/            # Governed inference
│       ├── aither/             # Signaling
│       ├── oikos/              # Dwelling and sessions
│       ├── agora/              # Spatial gathering
│       ├── soma/               # Embodiment
│       └── psyche/             # Experience
│
└── oikoi/                      # User-created oikoi (post-genesis)
```

---

## The Signing Ceremony

Genesis validity requires threshold signatures. No single authority.

Signers attest:
- They have reviewed this kosmogonia
- They affirm it as authentic foundation
- They commit to not signing conflicting genesis

---

## Glossary of Terms

| Term | Greek | Meaning |
|------|-------|---------|
| **eidos** | εἶδος | Form/type — the schema for what an entity can be |
| **typos** | τύπος | Mold — composition template with slots and fill methods |
| **desmos** | δεσμός | Bond — typed relationship between entities |
| **stoicheion** | στοιχεῖον | Element — atomic operation step |
| **praxis** | πρᾶξις | Action — composed sequence of stoicheia |
| **dynamis** | δύναμις | Power — substrate capability tier |
| **oikos** | οἶκος | Household — domain package where capability dwells |
| **thyra** | θύρα | Door — the rendering/perception boundary |
| **kosmos** | κόσμος | Order — the substrate of entities and bonds |
| **chora** | χώρα | Receptacle — where kosmos actualizes |

---

*This is the root. Everything traces here. The chain begins.*
