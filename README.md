# Kosmos

*The world as ordered whole.*

---

## What This Is

Kosmos is the ontological foundation for sovereign dwelling — a system where each person owns their understanding of reality and shares it with those they choose.

This repository contains the **genesis layer**: pure YAML and Markdown definitions that describe what can exist, how things relate, and what operations are possible. These definitions bootstrap into a living runtime via the Thyra application, available as pre-built binaries in [Releases](https://github.com/Liminal-Commons/kosmos/releases).

There is no central authority, no algorithmic intermediation, no rent extracted from your attention or relationships. Each kosmos is sovereign. Each prosopon owns their own keys. Federation is peer-to-peer.

---

## Getting Started

### Download Thyra

Pre-built binaries are available on the [Releases](https://github.com/Liminal-Commons/kosmos/releases) page for macOS, Linux, and Windows.

### From Source

If you want to modify the genesis definitions and see them come alive:

1. Clone this repository
2. Author or modify YAML definitions in `genesis/`
3. Bootstrap via Thyra to see changes take effect

---

## Contents

### Constitutional Documents

| Document | Purpose |
|----------|---------|
| [KOSMOGONIA](genesis/KOSMOGONIA.md) | The constitutional root — how the kosmos comes to be |
| [ROADMAP](genesis/ROADMAP.md) | Development phases |

### Genesis Layer

The seed content from which a kosmos bootstraps:

```
genesis/
├── KOSMOGONIA.md              # Constitutional root
├── arche/                     # The grammar of being
│   ├── eidos.yaml             # Entity types
│   └── desmos.yaml            # Bond types
├── stoicheia-portable/        # Step definitions (WASM-portable)
├── spora/                     # Bootstrap seed
├── klimax/                    # Scale documentation
└── {topos}/                   # 21 capability domains
    ├── manifest.yaml          # Identity, dependencies
    ├── DESIGN.md              # Design rationale
    ├── eide/                  # Entity type definitions
    ├── desmoi/                # Bond definitions
    ├── praxeis/               # Operations
    ├── typos/                 # Composition molds
    ├── reflexes/              # Reactive behaviors
    └── render-specs/          # UI widget definitions
```

### The Topoi

| Topos | Scale | What It Provides |
|-------|-------|------------------|
| **nous** | cross-scale | Understanding, journeys, theoria |
| **demiurge** | cross-scale | Composition, artifact caching |
| **manteia** | cross-scale | Governed inference |
| **dokimasia** | cross-scale | Validation, testing |
| **hypostasis** | cross-scale | Cryptographic identity, signing |
| **dynamis** | infrastructure | Distribution, substrate bridging |
| **aither** | infrastructure | Network transport, WebRTC |
| **thyra** | infrastructure | Display, rendering, modes |
| **soma** | embodiment | Channels, percepts, body-schema |
| **psyche** | experience | Attention, intention, mood, prospect |
| **oikos** | intimate | Sessions, conversations, notes |
| **politeia** | governance | Oikoi, prosopa, attainments |
| **propylon** | entry | Invitations, verification |
| **credentials** | identity | Credential management |
| **logos** | discourse | Phasis authoring and ownership |
| **hodos** | navigation | Paths, waypoints |
| **ekdosis** | publishing | Content publication |
| **ergon** | coordination | Cross-oikos work |
| **release** | lifecycle | Artifact lifecycle |
| **my-nodes** | personal | Personal node views |
| **chora-dev** | development | Development tooling |

---

## Architecture

Kosmos follows a strict separation between ontology and implementation:

```
kosmos (this repo)          thyra (application)
─────────────────           ───────────────────
YAML definitions    →       bootstrap    →    runtime graph
entity types                interpreter       MCP projection
bond definitions            praxis engine     UI rendering
step sequences              composition       federation
```

The genesis definitions are the source of truth. The application reads them, validates against schema constraints, creates a runtime graph of entities and bonds, and exposes operations via MCP and the Thyra UI.

### The Five Archai

Five foundational forms define what can exist:

| Arche | What It Defines |
|-------|-----------------|
| **Eidos** | Entity types — what things ARE |
| **Typos** | Molds — HOW things are made |
| **Desmos** | Bond types — how things RELATE |
| **Stoicheion** | Step types — what things DO |
| **Dynamis** | Power — substrate capabilities |

### Full-Circle Verification

The kosmos can emit itself, re-bootstrap from emission, and emit again with identical output. `emit → bootstrap → emit` = same BLAKE3 hash. This proves the system is self-consistent and deterministic.

---

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for how to contribute ontology definitions — new topoi, eide, desmoi, praxeis, and design documents.

---

## License

AGPL-3.0-or-later. See [LICENSE](LICENSE).

The commons stays common.

---

*χώρα receives. κόσμος is received.*
