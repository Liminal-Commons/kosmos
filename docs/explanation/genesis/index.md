# Genesis: The Constitutional Layer

Genesis is the source of truth for kosmos — the definitional layer where the world is authored.

---

## What is Genesis?

**Genesis** (`genesis/`) is where kosmos is defined. It contains:
- Entity types (eide) that specify what can exist
- Bond types (desmoi) that specify how things relate
- Operations (praxeis) that specify what can be done
- Composition templates (typos) that specify how to create
- Pre-composed entities that seed the initial state

Everything in kosmos traces back to genesis. The interpreter (chora) loads genesis at bootstrap, validating definitions and exposing operations as MCP tools.

---

## The Two Repositories

| Repository | Contains | Role |
|------------|----------|------|
| **kosmos** | Genesis layer (YAML + Markdown) | The world as definition |
| **chora** | Interpreter (Rust/WASM) | The world as execution |

Chora depends on kosmos via symlink: `chora/genesis → ../kosmos/genesis`

---

## Genesis Structure

```
genesis/
├── KOSMOGONIA.md              ← Constitutional root
├── CLAUDE.md                  ← Agent instructions
│
├── arche/                     ← The grammar of being
│   ├── eidos.yaml             # Entity type definitions
│   ├── desmos.yaml            # Bond type definitions
│   └── stoicheion.yaml        # Step type definitions
│
├── spora/                     ← The seed (bootstrap)
│   ├── spora.yaml             # Germination stages
│   └── definitions/           # Typos for composition
│
├── stoicheia-portable/        ← Step vocabulary
│   └── eide/
│       └── stoicheion.yaml    # Full stoicheion schemas
│
└── {topos}/                   ← Domain packages (30+)
    ├── manifest.yaml          # Topos metadata
    ├── DESIGN.md              # Ontological purpose
    ├── eide/                  # Entity definitions
    ├── desmoi/                # Bond definitions
    ├── praxeis/               # Operations
    └── entities/              # Pre-composed instances
```

---

## Core Concepts

### The Archai

Five foundational forms define the grammar of existence:

| Arche | What It Defines | Location |
|-------|-----------------|----------|
| **Eidos** | Entity types — what things ARE | `arche/eidos.yaml` |
| **Desmos** | Bond types — how things RELATE | `arche/desmos.yaml` |
| **Stoicheion** | Step types — atomic operations | `stoicheia-portable/` |
| **Typos** | Composition templates | `{topos}/typos/` |
| **Dynamis** | Substrate capabilities | `spora/spora.yaml` |

See [The Five Archai](archai.md) for detailed explanation.

### The Topoi

A **topos** (household) is a domain package — a collection of related eide, desmoi, and praxeis that provide coherent capability.

Genesis contains 30+ topoi organized by purpose:
- **nous** — Understanding, theoria, journeys
- **thyra** — Portal, streams, rendering
- **politeia** — Governance, oikoi, attainments
- **soma** — Embodiment, channels, parousia lifecycle

See [Topoi Organization](topoi.md) for the complete list.

### The Klimax

The **klimax** (scale hierarchy) positions topoi across five nested levels:

```
kosmos    → substrate (entities, bonds)
  physis  → constraints and operations
    polis → governance (oikoi, attainments)
      oikos → dwelling (sessions, presence)
        soma → embodiment and sensing
          psyche → experience
```

Each scale establishes context for the next. See [Klimax Scales](../klimax/index.md).

---

## Bootstrap Flow

When chora starts, it loads genesis through defined stages:

1. **Stage 0 (Prime)**: Compose `eidos/eidos` — the self-grounding foundation
2. **Stage 1 (Archai)**: Load entity types, bond types, stoicheia
3. **Stage 2 (Presence)**: Compose prosopon, parousia, oikos definitions
4. **Stage 3 (Founder)**: Create initial prosopa and oikoi
5. **Stage 3.5 (Politeia)**: Establish attainments and affordances
6. **Topos Loading**: Discover manifests, load domain packages

See [Bootstrap Process](bootstrap.md) for the complete flow.

---

## The Manifest Contract

Each topos declares its capabilities via `manifest.yaml`:

```yaml
topos_id: nous
version: "0.1.0"
topos_scale: cross-scale

provides:
  eide: [journey, waypoint, theoria]
  praxeis: [nous/surface, nous/crystallize-theoria]
  attainments: [crystallize, journey]

requires_dynamis:
  - db.find
  - aisthesis.surface

depends_on:
  - manteia
  - politeia
```

The manifest enables:
- Dependency-ordered loading
- Capability verification
- Graph-queryable requirements

See [Manifest Schema](../../reference/genesis/manifest-schema.md).

---

## Constitutional Principles

Genesis enforces the constitutional promises from [KOSMOGONIA.md](../../../genesis/KOSMOGONIA.md):

### Composition-Only Creation

Entities must flow through typos (composition templates). Direct `arise` is internal to the interpreter.

```yaml
# Correct: use compose
- step: compose
  typos_id: typos-def-theoria
  inputs: { insight: "...", domain: "..." }

# Wrong: bypass composition (internal only)
- step: arise
  eidos: theoria
  data: { ... }
```

### Provenance by Construction

Every entity has bonds tracing to genesis:
- `composed-from` → the typos used
- `authorized-by` → the phasis that authorized

### Visibility = Reachability

Access is determined by bond traversal from dwelling position. There are no hidden backdoors — the graph IS access control.

---

## See Also

- [The Five Archai](archai.md) — Foundational forms in depth
- [Topoi Organization](topoi.md) — Domain packages explained
- [Bootstrap Process](bootstrap.md) — How genesis loads
- [Manifest Schema](../../reference/genesis/manifest-schema.md) — Technical reference
- [Directory Conventions](../../reference/genesis/directory-conventions.md) — File organization

---

*Genesis is the world as pure definition. The interpreter makes it breathe.*
