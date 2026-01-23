# Kosmos

*The generative commons distribution point.*

---

## What This Is

This repository is **not** a live kosmos. It is a **publication target** — a place where artifacts from active development (in chora) are published for distribution.

Think of it as the released form, the actualized output. Chora births; kosmos receives.

---

## Contents

### `/phoreta/`

Exported entity bundles from chora. These are snapshots of kosmos state that can be:
- Imported into another kosmos
- Used for backup/recovery
- Federated to other circles

Current phoreta:
- `full-federation.yaml` — Complete genesis export (750+ entities, 990+ bonds)
- `chora-kosmos-dev.yaml` — Development federation bundle

### `/oikoi/`

Published oikos packages organized by MVP priority:

#### `/oikoi/core/` — MVP Critical

These oikoi support the Thyra invitation flow (C1-C9):

| Oikos | Roadmap | Description |
|-------|---------|-------------|
| `aither` | C4 | WebRTC signaling for P2P connections |
| `hypostasis` | C2, C7 | Cryptographic identity and phoreta exchange |
| `oikos` | C8 | Session and conversation management |
| `politeia` | C2 | Circles, governance, and attainments |
| `propylon` | C3-C6 | Entry via invitation links |
| `soma` | C2 | Animus embodiment and channels |
| `thyra` | C6-C8 | Expressions, streams, and rendering |

#### `/oikoi/extended/` — Post-MVP

These oikoi provide additional capabilities beyond the invitation flow:

| Oikos | Description |
|-------|-------------|
| `nous` | Understanding and knowledge management |
| `demiurge` | Artifact composition and caching |
| `dokimasia` | Validation and verification |
| `manteia` | Governed LLM inference |
| `psyche` | Attention, intention, and mood |
| `pege` | Documentation emission |
| `syndesmos` | Federation between circles |
| `self-federation` | Device synchronization |
| ... | (14 total extended oikoi) |

### `/theoria/`

Crystallized understanding emitted as documentation. Will be populated by `pege/emit-*` praxeis.

### `/docs/` (planned)

Emitted reference documentation:
- `/docs/reference/eide/` — Eidos reference pages
- `/docs/reference/stoicheia/` — Stoicheion reference pages
- `/docs/reference/praxeis/` — Praxis summaries

### `/releases/` (planned)

Tagged release bundles:
- Signed genesis spora
- Version-tagged phoreta
- App distribution packages

---

## This Is Not

- **Not a development environment** — Development happens in chora
- **Not a live kosmos** — No active animus dwells here
- **Not a database** — No kosmos.db to modify
- **Not infrastructure** — The relay lives at liminalcommons/propylon-relay

---

## Relationship to Chora

```
chora/                           kosmos/
├── genesis/                     ├── oikoi/
│   └── [oikos]/                │   ├── core/        ← MVP-critical
│       ├── eide/               │   │   └── [oikos]/
│       ├── desmoi/             │   └── extended/    ← Post-MVP
│       └── praxeis/            │       └── [oikos]/
├── crates/                      │
│   └── kosmos-v8/              ├── phoreta/
├── app/                         │   └── (exported bundles)
│   └── thyra/                  │
└── docs/                        ├── theoria/
    └── (source)                │   └── (emitted)
                                └── docs/
                                    └── (emitted)
```

The flow is always: **chora → kosmos**

- Oikoi are published from genesis/ definitions
- Phoreta are exported via `hypostasis/export-phoreta`
- Documentation is emitted via `pege/emit-*` praxeis

---

## Roadmap

### Phase K1: Repository Structure ← Current

| Task | Description | Status |
|------|-------------|--------|
| K1.1 | Remove experimental files | ✅ |
| K1.2 | Create directory structure | ✅ |
| K1.3 | Write README | ✅ |
| K1.4 | Organize oikoi (core/extended) | ✅ |
| K1.5 | Remove .mcp.json | |

### Phase K2: Phoreta Management

| Task | Description | Status |
|------|-------------|--------|
| K2.1 | Versioned phoreta naming convention | |
| K2.2 | Phoreta verification (composition chains) | |
| K2.3 | Delta phoreta generation | |

### Phase K3: Oikoi Publication

| Task | Description | Status |
|------|-------------|--------|
| K3.1 | Oikos package format specification | |
| K3.2 | Publication workflow from chora | |
| K3.3 | Version tagging | |

### Phase K4: Documentation Emission

| Task | Description | Status |
|------|-------------|--------|
| K4.1 | Set up docs/ structure | |
| K4.2 | Emit eide references | |
| K4.3 | Emit stoicheia references | |
| K4.4 | Emit praxeis summaries | |

### Phase K5: Release Packaging

| Task | Description | Status |
|------|-------------|--------|
| K5.1 | Signed genesis bundles | |
| K5.2 | Release tagging workflow | |
| K5.3 | App distribution artifacts | |

---

## For App Developers

If you're building an app that uses kosmos:

1. **Genesis is embedded** — Your app includes genesis spora at build time
2. **Oikoi are the source** — Pull from `/oikoi/` for package definitions
3. **Phoreta is for sync** — After bootstrap, phoreta carries circle content

See [chora/genesis/thyra/ROADMAP.md](https://github.com/liminalcommons/chora/blob/main/genesis/thyra/ROADMAP.md) for the Thyra app implementation roadmap.

---

## For Circle Operators

If you're running your own circle infrastructure:

1. **Deploy your relay** — Fork [propylon-relay](https://github.com/liminalcommons/propylon-relay)
2. **Import genesis** — Start with genesis phoreta
3. **Create invitations** — Use propylon links to grow your circle

---

## License

The kosmos is a commons. Content here is shared under commons principles.

---

*χώρα receives. This repository is form that receives.*
*Traces to: expression/genesis-root*
