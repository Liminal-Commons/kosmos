# Oikos Map

A comprehensive map of all 20 oikoi in the kosmos genesis layer.

---

## Overview

**20 oikoi** organized into three categories:
- **Infrastructure** (11) — Foundational capabilities, minimal UI
- **Interface** (4) — Rendering and interaction layer
- **Domain** (5) — User-facing experiences

All oikoi are at **Loaded** level. Progression to Projected/Embodied/Surfaced/Afforded requires chora implementation.

---

## Oikos Taxonomy

### Infrastructure Oikoi (11)

Operate quietly. Minimal UI. Reconcilers sense drift.

| Oikos | Greek | Gap Addressed | Scale | Key Eide |
|-------|-------|---------------|-------|----------|
| **hypostasis** | ὑπόστασις | Identity substrate | cross | persona, animus, kleidoura, genesis-record |
| **politeia** | πολιτεία | Governance and circles | polis | circle, membership, attainment, affordance |
| **soma** | σῶμα | Embodiment and sensing | soma | body, channel, presence-channel |
| **demiurge** | δημιουργός | Composition | cross | typos, artifact, generation-result |
| **dokimasia** | δοκιμασία | Validation gate | cross | validation-result, validation-error |
| **dynamis** | δύναμις | Actuality bridging | cross | substrate, deployment, actuality-record |
| **ekdosis** | ἔκδοσις | Publication | cross | oikos-release, release-channel, build-attestation |
| **ergon** | ἔργον | Work coordination | cross | pragma |
| **propylon** | πρόπυλον | Entry without surveillance | cross | propylon-link, entry-request, session-token |
| **credentials** | — | External capability bridges | cross | credential |
| **release** | — | Artifact lifecycle | cross | release, release-artifact, distribution-channel |

### Interface Oikoi (4)

ARE the rendering/interaction layer. Full stack.

| Oikos | Greek | Gap Addressed | Scale | Key Eide |
|-------|-------|---------------|-------|----------|
| **thyra** | θύρα | Inside ↔ outside boundary | soma | stream, expression, segment |
| **opsis** | ὄψις | Existence ↔ appearance | soma | layout, panel, render-spec, renderer, widget |
| **aither** | αἰθήρ | Here ↔ there transport | physis | syndesmos, data-channel, presence-record, outbound-message |
| **manteia** | μαντεία | Unknown ↔ known generation | cross | generation-request |

### Domain Oikoi (6)

User-facing with contextual actions.

| Oikos | Greek | Gap Addressed | Scale | Key Eide |
|-------|-------|---------------|-------|----------|
| **oikos** | οἶκος | Dwelling experience | oikos | session, conversation, segment, note, insight |
| **psyche** | ψυχή | Attention and intention | psyche | attention, intention, mood, prospect, kairos |
| **nous** | νοῦς | Ignorance ↔ understanding | cross | theoria, journey, waypoint, inquiry, synthesis |
| **agora** | ἀγορά | Being-together | oikos | territory, presence, room, livekit-server |
| **hodos** | ὁδός | Knowing destination ↔ arriving | animus | step, step-state, journey-position |
| **dns** | — | Addressability from outside | cross | zone, record, dns-change |

---

## Dependency Graph

```
                    ┌─────────────┐
                    │  hypostasis │ ← identity foundation
                    └──────┬──────┘
                           │
           ┌───────────────┼───────────────┐
           ▼               ▼               ▼
     ┌──────────┐    ┌──────────┐    ┌────────────┐
     │ politeia │    │credentials│    │  propylon  │
     └────┬─────┘    └──────────┘    └────────────┘
          │
    ┌─────┴─────────────────────┐
    ▼                           ▼
┌────────┐                 ┌─────────┐
│  soma  │                 │  ergon  │
└───┬────┘                 └─────────┘
    │
    ├───────────────────────────────────┐
    ▼                                   ▼
┌────────┐  ┌────────┐  ┌────────┐  ┌────────┐
│ psyche │  │ thyra  │  │ opsis  │  │ aither │
└────────┘  └───┬────┘  └────────┘  └───┬────┘
                │                       │
                ▼                       ▼
           ┌────────┐              ┌────────┐
           │ hodos  │              │ agora  │
           └────────┘              └────────┘

               ┌─────────┐
               │  nous   │ ← cross-cutting understanding
               └────┬────┘
                    │
    ┌───────────────┼───────────────┐
    ▼               ▼               ▼
┌──────────┐  ┌──────────┐    ┌──────────┐
│ demiurge │  │ manteia  │    │  oikos   │
└────┬─────┘  └──────────┘    └──────────┘
     │
     ├───────────────────────────────────┐
     ▼                                   ▼
┌──────────┐  ┌──────────┐  ┌──────────┐
│ dokimasia│  │  dynamis │  │ ekdosis  │
└──────────┘  └────┬─────┘  └──────────┘
                   │
                   ▼
              ┌─────────┐
              │ release │
              └─────────┘
```

---

## Theoria Distribution

70 theoria crystallized across domains:

| Domain | Count | IDs |
|--------|-------|-----|
| aither | 6 | T58-T60, T82-T84 |
| nous | 7 | T30-T33, T85-T87 |
| thyra | 5 | T50-T54 |
| demiurge | 4 | T34-T37 |
| dynamis | 3 | T44-T46 |
| manteia | 3 | T38-T40 |
| propylon | 3 | T47-T49 |
| soma | 3 | T27-T29 |
| politeia | 3 | T24-T26 |
| hypostasis | 3 | T21-T23 |
| ekdosis | 3 | T18-T20 |
| ergon | 3 | T55-T57 |
| agora | 3 | T61-T63 |
| dokimasia | 3 | T64-T66 |
| dns | 3 | T67-T69 |
| hodos | 3 | T70-T72 |
| opsis | 3 | T73-T75 |
| release | 3 | T76-T78 |
| credentials | 3 | T79-T81 |
| oikos | 3 | T41-T43 |

---

## Completeness Status

### Kosmos-side (Complete)

| Level | Status |
|-------|--------|
| **Defined** | ✅ All 20 — YAML definitions exist |
| **Loaded** | ✅ All 20 — Bootstrap loads into kosmos.db |

### Chora-side (Pending)

| Level | Status | Required Implementation |
|-------|--------|------------------------|
| **Projected** | ⏳ | Dynamic praxis registration |
| **Embodied** | ⏳ | Body-schema aggregation |
| **Surfaced** | ⏳ | Reconciler infrastructure |
| **Afforded** | ⏳ | Declarative rendering pipeline |

---

## Implementation Tiers

Recommended sequence for chora implementation:

### Tier 0: Foundation
| Oikos | Why First |
|-------|-----------|
| **soma** | Owns body-schema; all embodiment flows through soma |
| **politeia** | Visibility = Reachability; graph IS access control |

### Tier 1: Interface
| Oikos | Why |
|-------|-----|
| **opsis** | Owns rendering; all visual display flows through opsis |
| **thyra** | Owns streams/expression; commitment boundary |
| **hodos** | Navigation kinetics; journey execution |

### Tier 2: User-Facing
| Oikos | Why |
|-------|-----|
| **oikos** | Dwelling experience |
| **psyche** | Attention/intention |
| **agora** | Spatial presence |
| **nous** | Understanding |

### Tier 3: Capability
| Oikos | Why |
|-------|-----|
| **manteia** | Generation |
| **demiurge** | Composition |
| **ergon** | Work coordination |
| **aither** | Networking |

### Tier 4: Infrastructure
| Oikos | Why Last |
|-------|----------|
| **hypostasis** | Identity (admin views only) |
| **propylon** | Entry flows |
| **dynamis** | Deployment |
| **ekdosis** | Publication |
| **dokimasia** | Validation |
| **credentials** | External access |
| **release** | Artifacts |
| **dns** | Naming |

---

## Quick Reference

### By Greek Name

| Greek | Oikos | Meaning |
|-------|-------|---------|
| ἀγορά | agora | marketplace, gathering |
| αἰθήρ | aither | upper air, ether |
| δημιουργός | demiurge | craftsman, maker |
| δοκιμασία | dokimasia | examination, testing |
| δύναμις | dynamis | power, capability |
| ἔκδοσις | ekdosis | giving out, publication |
| ἔργον | ergon | work, deed |
| ὁδός | hodos | way, road |
| μαντεία | manteia | prophecy, divination |
| νοῦς | nous | mind, understanding |
| οἶκος | oikos | house, household |
| ὄψις | opsis | sight, appearance |
| πολιτεία | politeia | citizenship, governance |
| πρόπυλον | propylon | gateway, vestibule |
| σῶμα | soma | body |
| θύρα | thyra | door |
| ὑπόστασις | hypostasis | substance, underlying reality |
| ψυχή | psyche | soul, mind |

### By Purpose

| Purpose | Oikoi |
|---------|-------|
| Identity & Trust | hypostasis, propylon, credentials |
| Governance | politeia |
| Embodiment | soma, psyche, agora |
| Understanding | nous |
| Composition | demiurge, manteia |
| Rendering | thyra, opsis |
| Navigation | hodos |
| Networking | aither |
| Work | ergon |
| Distribution | dynamis, ekdosis, release |
| Validation | dokimasia |
| Dwelling | oikos |
| Naming | dns |

---

*The kosmos becomes coherent through intentional design. Each oikos, well-crafted, makes the whole greater than the sum.*
