# Topoi: Domain Packages

A topos (household) is where capability dwells — a package of related eide, desmoi, and praxeis.

---

## What is an Topos?

A **topos** is a self-contained domain package that provides:
- **Eide** — Entity types specific to this domain
- **Desmoi** — Bond types for domain relationships
- **Praxeis** — Operations exposed as MCP tools
- **Entities** — Pre-composed instances (reflexes, renderers, etc.)
- **Typos** — Composition templates for the domain

Each topos has a manifest declaring what it provides and requires.

---

## Topos Anatomy

```
genesis/{topos}/
├── manifest.yaml          # Package metadata (required)
├── DESIGN.md              # Ontological purpose (required)
├── REFERENCE.md           # API reference (optional)
│
├── eide/                  # Entity type definitions
│   └── {topos}.yaml
│
├── desmoi/                # Bond type definitions
│   └── {topos}.yaml
│
├── praxeis/               # Operations (MCP tools)
│   └── {topos}.yaml
│
├── entities/              # Pre-composed instances
│   ├── reflexes.yaml
│   └── rendering.yaml
│
├── render-specs/          # UI specifications (optional)
│   └── {component}.yaml
│
└── typos/                 # Composition templates (optional)
    └── {definition}.yaml
```

---

## The Complete Topos List

### Infrastructure (Cross-Scale)

| Topos | Purpose | Key Entities |
|-------|---------|--------------|
| **arche** | Grammar of being | eidos, desmos, stoicheion |
| **stoicheia-portable** | Step vocabulary | stoicheion definitions |
| **spora** | Bootstrap seed | germination stages, typos |
| **dynamis** | Substrate capabilities | domains, functions |
| **hypostasis** | Integrity verification | signatures, proofs |
| **dokimasia** | Validation | test cases, assertions |
| **credentials** | Secret management | credentials, vaults |

### Knowledge & Understanding

| Topos | Purpose | Key Entities |
|-------|---------|--------------|
| **nous** | Understanding operations | theoria, journey, waypoint |
| **logos** | Phasis surface | phasis, thread |
| **manteia** | Governed inference | governed envelope, schema |
| **hodos** | Journey navigation | waypoint, milestone |

### Governance & Identity

| Topos | Purpose | Key Entities |
|-------|---------|--------------|
| **politeia** | Governance | oikos, attainment, affordance |
| **propylon** | Entry/invitations | invitation, challenge |

### Interface & Experience

| Topos | Purpose | Key Entities |
|-------|---------|--------------|
| **thyra** | Portal/rendering | stream, widget, mode |
| **psyche** | Experience/attention | intention, attention |
| **voice-authoring** | Voice composition | transcript, accumulation |

### Embodiment

| Topos | Purpose | Key Entities |
|-------|---------|--------------|
| **soma** | Body/channels | parousia, channel, body-schema |
| **oikos** | Dwelling/sessions | session, presence |
| **agora** | Spatial gathering | territory, proximity |
| **aither** | Signaling/WebRTC | signal, peer |

### Operations & Meta

| Topos | Purpose | Key Entities |
|-------|---------|--------------|
| **demiurge** | Composition | compose operations |
| **ergon** | Work/daemons | reflex, trigger, daemon |
| **ekdosis** | Publishing | package, artifact |
| **release** | Release management | release, version |
| **klimax** | Scale documentation | scale definitions |
| **chora-dev** | Developer tools | debug, introspection |
| **genesis** | Self-reference | meta operations |

---

## Topos Categories

### By Klimax Level

```
kosmos (substrate)
├── arche, stoicheia-portable, dynamis, spora
│
physis (constraints)
├── dokimasia, hypostasis, manteia, demiurge
│
polis (governance)
├── politeia, propylon
│
oikos (dwelling)
├── oikos, agora, hodos, nous, logos
│
soma (embodiment)
├── soma, thyra, voice-authoring, aither
│
psyche (experience)
└── psyche
```

### By Surface Type

| Surface | Topoi |
|---------|-------|
| **understanding** | nous, logos, manteia |
| **governance** | politeia, propylon |
| **rendering** | thyra, psyche |
| **embodiment** | soma, oikos, agora |
| **infrastructure** | dynamis, hypostasis, dokimasia |

---

## Manifest Structure

Each topos declares its contract via `manifest.yaml`:

```yaml
format_version: "2.1"
topos_id: nous
version: "0.1.0"

topos_name: "Nous"
topos_description: |
  Understanding operations — theoria, inquiry, synthesis.
topos_scale: cross-scale
topos_category: domain

# Service interfaces
surfaces_provided:
  - understanding
surfaces_consumed:
  - reasoning

# Where content lives
content_paths:
  - path: eide/
    content_types: [eidos]
  - path: desmoi/
    content_types: [desmos]
  - path: praxeis/
    content_types: [praxis]
  - path: entities/
    content_types: [reflex, render-spec]

# Substrate requirements
requires_dynamis:
  - db.find
  - db.bind
  - aisthesis.surface

# Capability declarations
provides:
  eide:
    - journey
    - waypoint
    - theoria
  praxeis:
    - nous/surface
    - nous/crystallize-theoria
    - nous/traverse
  attainments:
    - crystallize
    - journey

# Dependencies
depends_on:
  - manteia
  - politeia
```

---

## Loading Order

Topoi are loaded in dependency order during bootstrap:

1. **arche** — Grammar (eidos, desmos, stoicheion)
2. **spora** — Bootstrap seed (germination stages)
3. **stoicheia-portable** — Step vocabulary
4. Infrastructure topoi (dynamis, dokimasia, etc.)
5. Domain topoi (in `depends_on` topological order)

The manifest's `depends_on` field declares dependencies. Cycles are rejected at bootstrap.

---

## Creating an Topos

See [Create a Topos](../../tutorial/foundations/create-a-topos.md) for a step-by-step tutorial.

Minimum viable topos:

```
genesis/my-topos/
├── manifest.yaml     # Required
├── DESIGN.md         # Required
└── praxeis/
    └── my-topos.yaml # At least one praxis
```

---

## See Also

- [Genesis Overview](index.md) — The constitutional layer
- [The Five Archai](archai.md) — Foundational forms
- [Manifest Schema](../../reference/genesis/manifest-schema.md) — Technical reference
- [Topos Development](../../how-to/topos-development.md) — Practical guide

---

*Each topos is a household where capability dwells. Together they form the kosmos.*
