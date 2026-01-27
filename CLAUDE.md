# CLAUDE.md

This is **kosmos** — the world as pure ontology (YAML + Markdown).

The implementation lives in [chora](https://github.com/liminalcommons/chora).

---

## The Two Repositories

| Repository | What It Contains |
|------------|------------------|
| **kosmos** (here) | The world — eide, desmoi, praxeis, design docs |
| **chora** | The implementation — interpreter, MCP, UI |

**Kosmos is the world. Chora makes it breathe.**

Chora depends on kosmos via symlink: `chora/genesis → ../kosmos/genesis`

---

## Context

You are working in the genesis layer — the constitutional definitions of the kosmos.

Genesis is the source of truth. Definitions here ARE the kosmos.

---

## Key Documents

| Document | Purpose |
|----------|---------|
| [KOSMOGONIA.md](KOSMOGONIA.md) | Constitutional root — ontology and principles |
| [ARCHITECTURE.md](ARCHITECTURE.md) | Technical implementation — reconciliation loops, validation |
| [COMPOSITION-GUIDE.md](COMPOSITION-GUIDE.md) | Artifact composition — fill patterns, extending kosmos, emission scopes |
| [ROADMAP.md](ROADMAP.md) | Development phases |

---

## The Archai

Six foundational forms define what can exist:

| Arche | File | What It Defines |
|-------|------|-----------------|
| **Eidos** | `arche/eidos.yaml` | Entity types — what things ARE |
| **Desmos** | `arche/desmos.yaml` | Bond types — how things RELATE |
| **Stoicheion** | `stoicheia-portable/eide/stoicheion.yaml` | Step types — what things DO |
| **Oikos** | Implicit in praxeis | Domains — where capability DWELLS |
| **Typos** | `spora/definitions/` | Molds — composition templates |
| **Dynamis** | Tier annotations | Power — substrate capability stoicheia draw upon |

---

## Structure

```
genesis/
├── KOSMOGONIA.md           # Constitutional root (read this first)
├── ROADMAP.md              # Development phases
│
├── arche/                  # The grammar of being
│   ├── eidos.yaml          # Entity types
│   └── desmos.yaml         # Bond types
│
├── stoicheia-portable/     # Step definitions
│   └── eide/
│       └── stoicheion.yaml # Stoicheion definitions (schema source)
│
├── spora/                  # Seeds — praxeis organized by oikos
│   └── praxeis/
│       ├── nous.yaml       # Mind — thinking, theoria
│       ├── soma.yaml       # Body — channels, embodiment
│       ├── thyra.yaml      # Portal — streams, expression
│       ├── ergon.yaml      # Work — daemons, reconciliation
│       ├── demiurge.yaml   # Craftsman — composition
│       ├── politeia.yaml   # Governance — circles, attainments
│       └── ...
│
└── {oikos}/                # Per-oikos design docs
    └── DESIGN.md
```

---

## Composition Quickstart

**To create an entity:**
```yaml
- step: compose
  typos_id: typos-def-{eidos}   # e.g., typos-def-theoria
  inputs:
    id: "{eidos}/my-id"
    # ... eidos fields
  bind_to: result
```

**To generate content:**
```yaml
- step: call
  praxis: manteia/governed-inference
  params:
    prompt: "Generate..."
    output_schema: { ... }            # or target_eidos: theoria
  bind_to: result
```

**Never use `arise` or `infer` directly** — they are internal. See [ARCHITECTURE.md § Constitutional Enforcement](ARCHITECTURE.md#constitutional-enforcement).

---

## Authoring Praxeis

Praxeis are composed of steps. Each step invokes a stoicheion.

```yaml
- eidos: praxis
  id: praxis/{oikos}/{name}
  data:
    oikos: {oikos}
    name: {name}
    visible: true                    # Expose as MCP tool?
    description: |
      What this praxis does.
    params:
      - name: param_name
        type: string
        required: true
    steps:
      - step: assert
        condition: "$param_name"
        message: "param_name required"
      - step: compose
        typos_id: typos-def-thing
        inputs:
          id: "entity/$param_name"
          field: "$param_name"
        bind_to: entity
      - step: return
        value: "$entity"
```

### Step Names

Use exact stoicheion names. Common errors:
- `each` → use `for_each`
- `sense` → use `sense_actuality`
- `id:` in manifest → use `entity_id:`

---

## The Dynamis Gradation

| Tier | Dynamis | What It Permits |
|------|---------|-----------------|
| 0 | None | set, return, assert — pure data flow |
| 1 | None | filter, map, reduce, sort — aggregation |
| 2 | Kosmos | find, arise, bind, trace, traverse — entity ops |
| 3 | Chora | manifest, emit, infer, signal — actuality |

---

## Validation

After authoring, test via MCP:

```
# Bootstrap
cargo run --bin kosmos-mcp -- --db ./kosmos.db --genesis ./genesis

# Test praxis
Use tool: {oikos}_{name}
```

Bootstrap validates all praxis YAML against stoicheion schemas.
