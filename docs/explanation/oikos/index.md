# Topos Conceptual Guide

Understanding the domain packages of kosmos.

---

## What is an Topos?

A **topos** (οἶκος) is a household — a domain where capability dwells. Each topos packages related eide, desmoi, and praxeis into a coherent unit.

See [KOSMOGONIA.md](../../../genesis/KOSMOGONIA.md) for the constitutional definition.

---

## The Twenty Topoi

### Core Infrastructure

| Topos | Purpose | Design |
|-------|---------|--------|
| **demiurge** | Composition and artifact generation | [DESIGN.md](../../../genesis/demiurge/DESIGN.md) |
| **dynamis** | Power tiers and capability | [DESIGN.md](../../../genesis/dynamis/DESIGN.md) |
| **dokimasia** | Validation and testing | [DESIGN.md](../../../genesis/dokimasia/DESIGN.md) |
| **stoicheia-portable** | Step vocabulary (Tier 0-1) | [DESIGN.md](../../../genesis/stoicheia-portable/DESIGN.md) |

### Knowledge & Understanding

| Topos | Purpose | Design |
|-------|---------|--------|
| **nous** | Understanding operations, theoria, journeys | [DESIGN.md](../../../genesis/nous/DESIGN.md) |
| **logos** | Phasis and communication | [DESIGN.md](../../../genesis/logos/DESIGN.md) |
| **manteia** | Governed inference (LLM) | [DESIGN.md](../../../genesis/manteia/DESIGN.md) |
| **hodos** | Journey navigation | [DESIGN.md](../../../genesis/hodos/DESIGN.md) |

### Governance & Identity

| Topos | Purpose | Design |
|-------|---------|--------|
| **politeia** | Oikoss, attainments, governance | [DESIGN.md](../../../genesis/politeia/DESIGN.md) |
| **propylon** | Entry and invitations | [DESIGN.md](../../../genesis/propylon/DESIGN.md) |
| **hypostasis** | Prosopon and identity | [DESIGN.md](../../../genesis/hypostasis/DESIGN.md) |
| **credentials** | Credential management | [DESIGN.md](../../../genesis/credentials/DESIGN.md) |

### Interface & Experience

| Topos | Purpose | Design |
|-------|---------|--------|
| **thyra** | Rendering and UI | [DESIGN.md](../../../genesis/thyra/DESIGN.md) |
| **psyche** | Attention and experience | [REFERENCE.md](../../../genesis/psyche/REFERENCE.md) |
| **voice-authoring** | Voice-first composition | [DESIGN.md](../../../genesis/voice-authoring/DESIGN.md) |

### Embodiment & Infrastructure

| Topos | Purpose | Design |
|-------|---------|--------|
| **soma** | Body and channels | [DESIGN.md](../../../genesis/soma/DESIGN.md) |
| **oikos** | Session and dwelling | [DESIGN.md](../../../genesis/oikos/DESIGN.md) |
| **agora** | Spatial gathering | [DESIGN.md](../../../genesis/agora/DESIGN.md) |

### Operations & Distribution

| Topos | Purpose | Design |
|-------|---------|--------|
| **ergon** | Work, daemons, pragmata | [DESIGN.md](../../../genesis/ergon/DESIGN.md) |
| **aither** | Signaling | [DESIGN.md](../../../genesis/aither/DESIGN.md) |
| **ekdosis** | Publishing and distribution | [DESIGN.md](../../../genesis/ekdosis/DESIGN.md) |
| **release** | Release management | [DESIGN.md](../../../genesis/release/DESIGN.md) |

---

## Topos Anatomy

Every topos contains:

```
genesis/{topos}/
├── manifest.yaml      # Package metadata
├── DESIGN.md          # Conceptual design (explanation)
├── REFERENCE.md       # API reference (generated)
├── eide/              # Entity type definitions
├── desmoi/            # Bond type definitions
├── praxeis/           # Operation definitions
├── entities/          # Pre-composed entities (reflexes, etc.)
└── render-specs/      # UI render specifications
```

---

## See Also

- [Klimax Scales](../klimax/index.md) — The nested containment hierarchy
- [Topos Development Guide](../../how-to/topos-development/topos-development.md) — How to build a topos
- [Topos Map](../../../genesis/OIKOS-MAP.md) — Visual map of all topoi
