# Kosmos

*κόσμος — the world as ordered whole.*

---

## What This Is

This repository IS the kosmos — the ontological foundation that defines what can exist, how things relate, and what operations are possible.

**Kosmos is the world. Chora makes it breathe.**

- **Kosmos** = pure ontology (YAML + Markdown)
- **Chora** = implementation (Rust + TypeScript)

The world is described here. The implementation lives in [chora](https://github.com/liminalcommons/chora).

---

## Contents

### Constitutional Documents

| Document | Purpose |
|----------|---------|
| [KOSMOGONIA.md](KOSMOGONIA.md) | The constitutional root — how the kosmos comes to be |
| [CLAUDE.md](CLAUDE.md) | Instructions for dwelling — how to inhabit this world |
| [ARCHITECTURE.md](ARCHITECTURE.md) | Technical implementation patterns |
| [COMPOSITION-GUIDE.md](COMPOSITION-GUIDE.md) | How to compose artifacts |
| [CREATIVE-JOURNEY-PATTERN.md](CREATIVE-JOURNEY-PATTERN.md) | How psyche + soma + nous work together |
| [ROADMAP.md](ROADMAP.md) | Development phases |

### `/genesis/`

The seed content from which a kosmos bootstraps:

```
genesis/
├── arche/                 # The five archai (foundational types)
│   ├── eidos.yaml         # Type definitions
│   ├── desmos.yaml        # Bond definitions
│   ├── stoicheion.yaml    # Element definitions
│   ├── dynamis-interface.yaml
│   └── functions.yaml
│
├── spora/                 # Bootstrap seed
│   ├── spora.yaml         # Germination stages
│   ├── definitions/       # Typos definitions
│   ├── journeys/          # Learning paths and active journeys
│   └── principles/        # Core values
│
├── klimax/                # Scale documentation
│   ├── 1-kosmos/DESIGN.md
│   ├── 2-physis/DESIGN.md
│   ├── 3-polis/DESIGN.md
│   ├── 4-oikos/DESIGN.md
│   ├── 5-soma/DESIGN.md
│   └── nous/DESIGN.md
│
└── [15 oikoi]/            # Domain packages
    ├── manifest.yaml      # Identity, dependencies
    ├── DESIGN.md          # How this oikos works
    ├── eide/              # Type definitions
    ├── desmoi/            # Bond types
    └── praxeis/           # Operations
```

### The 15 Oikoi

| Oikos | Scale | What It Provides |
|-------|-------|------------------|
| **nous** | cross-scale | Understanding operations, journeys, theoria |
| **demiurge** | cross-scale | Composition, artifact caching |
| **manteia** | cross-scale | Governed inference |
| **dokimasia** | cross-scale | Validation, testing |
| **hypostasis** | cross-scale | Cryptographic identity, signing |
| **dynamis** | infrastructure | Distribution, substrate bridging |
| **aither** | infrastructure | Network transport, WebRTC |
| **thyra** | infrastructure | Display, rendering, HUD |
| **soma** | embodiment | Channels, percepts, body-schema |
| **psyche** | experience | Attention, intention, mood, thyra, prospect, kairos |
| **oikos** | intimate | Sessions, conversations, notes |
| **politeia** | governance | Circles, personas, attainments |
| **propylon** | entry | Invitations, verification |
| **agora** | spatial | 2D territories, presence |
| **stoicheia-portable** | vocabulary | WASM step definitions |

---

## The Numbers

| Metric | Count |
|--------|-------|
| Entities at bootstrap | ~754 |
| Bonds | ~1098 |
| Praxeis | ~239 |
| Oikoi | 15 |
| Eide | ~58 |
| Desmoi | ~105 |

All of this is pure YAML + Markdown.

---

## How Chora Uses Kosmos

Chora depends on kosmos for its ontological foundation:

```
kosmos/genesis/  →  bootstrap  →  kosmos.db  →  runtime
     │
     └── Embedded at build time or symlinked for development
```

The implementation in chora reads these definitions and:
1. Parses YAML into entity structures
2. Validates against schema constraints
3. Creates the runtime graph of entities and bonds
4. Exposes operations via MCP and UI

---

## Contributing

### Ontology Changes (Here)

Make changes here for:
- New eidos definitions
- New desmos (bond type) definitions
- New praxis definitions
- Design documents
- Constitutional updates

### Implementation Changes (Chora)

Make changes in [chora](https://github.com/liminalcommons/chora) for:
- Interpreter fixes
- UI components
- MCP projection
- Build system

---

## Verification

The full-circle test ensures kosmos is self-consistent:

```
kosmos/genesis/  →  emit  →  dist/genesis/
                              │
                              ▼
                    bootstrap  →  kosmos.db
                              │
                              ▼
                         emit  →  dist/genesis/
                              │
                              ▼
                    BLAKE3 hash identical? ✓
```

This proves:
1. Kosmos is self-consistent
2. Emission is deterministic
3. No hidden state in implementation

---

## Legacy Content

The `/phoreta/`, `/oikoi/` (old structure), `/theoria/`, `/docs/`, and `/releases/` directories contain content from when this repo was conceived as a publication target. They are preserved for reference but the canonical source is now `/genesis/`.

---

## The Vision

Separation of world from implementation enables:

1. **Independent evolution** — ontology changes don't require Rust rebuilds
2. **Multiple implementations** — other languages could interpret kosmos
3. **Clear contribution paths** — designers work in kosmos, engineers in chora
4. **Documentation-first** — the world is described before implemented
5. **Portable oikoi** — domain packages can be shared independently

---

*χώρα receives. κόσμος is received.*
*Traces to: expression/genesis-root*
