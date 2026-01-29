# Oikos Redesign Plan

A high-touch, comprehensive redesign of each oikos in the kosmos genesis layer. The goal is ontological coherence and compound leverage through intentional design.

---

## Guiding Principles

1. **Ontological coherence** — Each oikos addresses a specific gap in being
2. **Circle context** — Design for self, peer, and commons circle usage
3. **Compound leverage** — Each well-designed oikos amplifies others
4. **Embodiment** — Oikoi become alive when they surface naturally in context
5. **Minimal necessary** — Only what's needed, nothing more

---

## Meta Pattern: Oikos Completeness

An oikos progresses through levels of aliveness:

| Level | What It Means |
|-------|---------------|
| **Defined** | Eide, desmoi, praxeis exist in YAML |
| **Loaded** | Bootstrap loads into kosmos.db |
| **Projected** | MCP projects praxeis as tools |
| **Embodied** | Body-schema reflects capabilities |
| **Surfaced** | Reconciler notices when actions are relevant |
| **Afforded** | Thyra UI presents contextual actions |

An oikos is *complete* when usage flows naturally from context.

---

## DESIGN.md Template

Each oikos DESIGN.md will follow this structure:

```markdown
# {Oikos} Design

{Greek} ({transliteration}) — {meaning}

## Ontological Purpose

What gap in being does this oikos address?
What becomes possible that wasn't before?

## Circle Context

### Self Circle
How does a solitary dweller use this?

### Peer Circle
How do collaborators use this together?

### Commons Circle
How does this serve a community?

## Core Entities (Eide)

### {eidos-name}
- Fields and their purpose
- Lifecycle (how instances arise, change, depart)

## Bonds (Desmoi)

### {desmos-name}
- from/to eidos
- Cardinality
- Traversal semantics

## Operations (Praxeis)

### {praxis-name}
- What it does
- When to use it
- What it requires (attainments, context)

## Attainments

### attainment/{name}
- What capability it grants
- Which praxeis it gates
- Scope (circle, oikos, global)

## Embodiment

### Completeness Status
| Level | Status |
|-------|--------|
| Defined | |
| Loaded | |
| Projected | |
| Embodied | |
| Surfaced | |
| Afforded | |

### Body-Schema Contribution
What does sense-body reveal about this oikos?

### Reconciler
What opportunities does this oikos surface?

## Compound Leverage

How does this oikos amplify other oikoi?
What cross-oikos patterns emerge?

## Theoria

New theoria crystallized during this redesign.

## Future Extensions

What's not in scope now but could be later?
```

---

## Redesign Order

Ordered by dependency (foundational first):

| # | Oikos | Greek | Purpose | Status |
|---|-------|-------|---------|--------|
| 1 | **hypostasis** | ὑπόστασις | Identity — who exists | ✅ |
| 2 | **politeia** | πολιτεία | Governance — circles, attainments | ✅ |
| 3 | **soma** | σῶμα | Body — embodiment, channels | ✅ |
| 4 | **nous** | νοῦς | Mind — thinking, theoria | ✅ |
| 5 | **demiurge** | δημιουργός | Craftsman — composition | ✅ |
| 6 | **manteia** | μαντεία | Prophecy — generation | ✅ |
| 7 | **oikos** | οἶκος | Household — intimate dwelling | ✅ |
| 8 | **ekdosis** | ἔκδοσις | Publication — content releases | ✅ |
| 9 | **dynamis** | δύναμις | Power — actuality bridging | ✅ |
| 10 | **propylon** | πρόπυλον | Gateway — authentication | ✅ |
| 11 | **thyra** | θύρα | Door — streams, expression | ✅ |
| 12 | **ergon** | ἔργον | Work — cross-circle coordination | ✅ |
| 13 | **aither** | αἰθήρ | Ether — networking | ✅ |
| 14 | **agora** | ἀγορά | Gathering — presence, meetings | ✅ |
| 15 | **dokimasia** | δοκιμασία | Testing — validation | ✅ |
| 16 | **dns** | — | Infrastructure — DNS substrate (thyra sub-module) | ✅ |

---

## Outputs Per Oikos

For each oikos, the redesign produces:

1. **DESIGN.md** — Full document following template above
2. **manifest.yaml** — Updated to v2.1 format
3. **eide/*.yaml** — Revised entity definitions + attainments
4. **desmoi/*.yaml** — Revised bond definitions (if needed)
5. **praxeis/*.yaml** — Revised operations + reconcilers

---

## Cross-Cutting Concerns

### Attainment Consolidation

Current attainment inventory (may have duplicates):

| Source | Attainments |
|--------|-------------|
| spora.yaml | compose, invite, govern, nous, manteia, dns, oikos-develop, oikos-publish, oikos-bake, oikos-fork, external-emit, external-manifest, external-signal, use-embedding-api, use-anthropic-api |
| agora | agora-enter, agora-speak, agora-video, agora-create, agora-admin |
| ekdosis | publish |

**Action:** During redesign, consolidate and deduplicate. Each attainment should live in its oikos's eide file.

### Reconciler Pattern

Each oikos may define reconcilers that:
- Trigger on-dwell or on-schedule
- Sense state (what exists, what's changed)
- Surface opportunities to body-schema

### Body-Schema Contributions

The soma/sense-body praxis should aggregate:
- Channels (from soma)
- Capabilities (from attainments across all oikoi)
- Pending actions (from reconcilers)
- Context (from current dwelling)

---

## Theoria Registry

Theoria crystallized during redesign:

| ID | Statement | Source |
|----|-----------|--------|
| T18 | Oikos embodiment requires body-schema contribution | ekdosis |
| T19 | Reconcilers surface opportunities, not just drift | ekdosis |
| T20 | Attainments make capabilities discoverable | ekdosis |
| T21 | Identity is the foundation of all capability | hypostasis |
| T22 | Cryptographic bonds create structural trust | hypostasis |
| T23 | Session state bridges security and usability | hypostasis |
| T24 | Governance flows through the bond graph | politeia |
| T25 | Attainments are derived, not assigned | politeia |
| T26 | Affordances surface capabilities contextually | politeia |
| T27 | Presence precedes perception | soma |
| T28 | Channels are typed attention | soma |
| T29 | Body-schema is proprioceptive truth | soma |
| T30 | Understanding compounds through explicit capture | nous |
| T31 | Questions are first-class entities | nous |
| T32 | Journeys make goals navigable | nous |
| T33 | Semantic proximity enables serendipitous discovery | nous |
| T34 | Composition is the single act of creation | demiurge |
| T35 | Definition shape determines behavior | demiurge |
| T36 | Artifact graphs enable smart invalidation | demiurge |
| T37 | Generative-commons bridges creation and adaptation | demiurge |
| T38 | Schema-driven generation enables valid-by-construction outputs | manteia |
| T39 | Evaluation closes the generation loop | manteia |
| T40 | Meta-generation enables kosmos self-extension | manteia |
| T41 | Dwelling is structured presence | oikos |
| T42 | Notes bridge perception and understanding | oikos |
| T43 | Insights are understanding in motion | oikos |
| T44 | Actuality is sensed, not assumed | dynamis |
| T45 | Reconciliation is declarative, not procedural | dynamis |
| T46 | Distribution channels are typed pathways | dynamis |
| T47 | Links are primary, channels are orthogonal | propylon |
| T48 | Human verification is the highest assurance | propylon |
| T49 | Sovereignty includes the right to lose everything | propylon |
| T50 | The commitment boundary is the send moment | thyra |
| T51 | Streams follow the reconciler pattern | thyra |
| T52 | Expression modes signal stance | thyra |
| T53 | Homoiconic rendering makes display traversable | thyra |
| T54 | Two paths to render (structural vs content) | thyra |
| T55 | Gaps discovered are gaps captured | ergon |
| T56 | Work flows to capability | ergon |
| T57 | Resolution completes the loop | ergon |
| T58 | Connection state is intent reconciling with actuality | aither |
| T59 | The network forgets, the graph remembers | aither |
| T60 | Presence is ephemeral state, syndesmos is durable intent | aither |
| T61 | Gathering creates the space, not the other way around | agora |
| T62 | Infrastructure sovereignty enables authentic assembly | agora |
| T63 | Presence is spatial embodiment | agora |
| T64 | Validation is verification, not permission | dokimasia |
| T65 | The three loops operate at different layers | dokimasia |
| T66 | Schema-as-eidos makes the kosmos self-describing | dokimasia |
| T67 | DNS makes the kosmos addressable from outside | dns |
| T68 | Infrastructure sovereignty extends to naming | dns |
| T69 | Zone management is circle governance in network form | dns |

---

## Progress Log

### 2026-01-28
- Created oikos-redesign-plan.md
- Completed ekdosis redesign (pilot for meta pattern)
- Identified attainment duplication (publish vs oikos-publish)
- **Completed hypostasis redesign**
  - Rewrote DESIGN.md following template (ontological purpose, circle context, embodiment)
  - Added 5 attainments: sign, export, manage-keyring, manage-credentials, genesis-signer
  - Updated eide/hypostasis.yaml with proper `entities:` format and attainments
  - Updated manifest.yaml with attainments section
  - Crystallized T21-T23 theoria
- **Completed politeia redesign**
  - Rewrote DESIGN.md following template (ontological purpose, circle context, embodiment)
  - Added 5 attainments: govern, invite, distribute, hud, admin
  - Updated eide/politeia.yaml with proper `entities:` format and attainments
  - Updated manifest.yaml with attainments section
  - Crystallized T24-T26 theoria
- **Completed soma redesign**
  - Rewrote DESIGN.md following template (ontological purpose, circle context, embodiment)
  - Added 2 attainments: embody, channel
  - Updated eide/soma.yaml with proper `entities:` format and attainments
  - Updated manifest.yaml with attainments section
  - Crystallized T27-T29 theoria
- **Completed nous redesign**
  - Created DESIGN.md following template (ontological purpose, circle context, embodiment)
  - Added 4 attainments: crystallize, inquire, journey, invoke
  - Updated eide/nous.yaml with attainments
  - Updated manifest.yaml with attainments section
  - Crystallized T30-T33 theoria
- **Completed demiurge redesign**
  - Rewrote DESIGN.md following template (ontological purpose, circle context, embodiment)
  - Created eide/demiurge.yaml with typos, artifact eide + 7 attainments
  - Added 7 attainments: compose, generate-definitions, oikos-develop, oikos-bake, oikos-publish, oikos-fork, genesis-emit
  - Updated manifest.yaml with attainments section
  - Crystallized T34-T37 theoria
- **Completed manteia redesign**
  - Rewrote DESIGN.md following template (ontological purpose, circle context, embodiment)
  - Updated eide/manteia.yaml to entities format + 2 attainments
  - Added 2 attainments: manteia, generate-meta
  - Updated manifest.yaml with attainments section
  - Crystallized T38-T40 theoria
- **Completed oikos redesign**
  - Created DESIGN.md following template (ontological purpose, circle context, embodiment)
  - Corrected understanding: oikos is about intimate dwelling (sessions, notes, insights), not package system
  - Package eide (oikos-dev, oikos-prod) are defined here but manipulated by demiurge praxeis
  - Added 2 attainments: dwell, reflect
  - Updated eide/oikos.yaml with proper `entities:` format and attainments
  - Updated manifest.yaml with attainments section
  - Crystallized T41-T43 theoria
- **Completed dynamis redesign**
  - Rewrote DESIGN.md following template (ontological purpose, circle context, embodiment)
  - Dynamis addresses the gap between intention and actuality — phylax pattern (sense → compare → act)
  - Added 6 attainments: release, substrate, channel, distribute, deploy, reconcile
  - Updated eide/dynamis.yaml with attainments (eide already in entities format)
  - Updated manifest.yaml with attainments section
  - Crystallized T44-T46 theoria
- **Completed propylon redesign**
  - Rewrote DESIGN.md following template (ontological purpose, circle context, embodiment)
  - Propylon addresses the gap between outside and inside — entry without surveillance
  - Key insight: links are primary (self-contained, self-validating), channels are orthogonal (how you share)
  - Added 5 attainments: invite, enter (global scope), approve, audit, session (soma scope)
  - Converted eide/propylon.yaml from old `eide:` format to `entities:` format
  - Added entry-request and session-token to eide list in manifest
  - Updated manifest.yaml with attainments section and organized praxeis
  - Crystallized T47-T49 theoria
- **Completed thyra redesign**
  - Rewrote DESIGN.md following template (ontological purpose, circle context, embodiment)
  - Thyra addresses the gap between inside and outside — the boundary membrane
  - Central concept: commitment boundary (ephemeral → durable, the "send moment")
  - Added 5 attainments: perceive (soma), express (circle), render (soma), emit (soma), navigate (animus)
  - Converted eide/thyra.yaml from old `eide:` format to `entities:` format (18+ eide)
  - Added missing eide to manifest: layout, panel, style-theme, render-intent, workspace, widget, etc.
  - Updated manifest.yaml with attainments section
  - Crystallized T50-T54 theoria
- **Completed ergon redesign**
  - Created DESIGN.md following template (ontological purpose, circle context, embodiment)
  - Ergon addresses the gap between discovery and capability — work coordination across circles
  - Central concept: pragma (πρᾶγμα — a thing to be done) signals from discovering circle to resolving circle
  - Added 2 attainments: signal (create pragma), work (manage pragma lifecycle)
  - Converted eide/ergon.yaml from old format to `entities:` format
  - Updated manifest.yaml with attainments section
  - Crystallized T55-T57 theoria
- **Completed aither redesign**
  - Rewrote DESIGN.md following template (ontological purpose, circle context, embodiment)
  - Aither addresses the gap between here and there — P2P transport without semantic knowledge
  - Central concept: syndesmos (connection state that reconciles intent with actuality)
  - Added 5 attainments: connect (soma), message (soma), presence (circle), sync (circle), sense (soma)
  - Converted eide/aither.yaml from old `eide:` format to `entities:` format (6 eide)
  - Updated manifest.yaml with attainments section
  - Crystallized T58-T60 theoria
- **Completed agora redesign**
  - Rewrote DESIGN.md following template (ontological purpose, circle context, embodiment)
  - Agora addresses the gap between being-together and being-apart — spatial presence
  - Central concept: territory (τόπος — a place where gathering occurs with dimension)
  - Updated 5 attainments with scope and grants: agora-enter, agora-speak, agora-video, agora-create, agora-admin
  - Eide already in `entities:` format (4 eide: territory, presence, livekit-server, room)
  - Manifest already had attainments section
  - Crystallized T61-T63 theoria
- **Completed dokimasia redesign**
  - Rewrote DESIGN.md following template (ontological purpose, circle context, embodiment)
  - Dokimasia addresses the gap between authorization and validity — validation gate
  - Central concept: validation gate (prevents realization of anything that cannot work)
  - Added 1 attainment: examine (scope: circle, grants all validation praxeis)
  - Converted eide/dokimasia.yaml from old `eide:` format to `entities:` format (2 eide)
  - Updated manifest.yaml with attainments section
  - Crystallized T64-T66 theoria
- **Completed dns redesign** (thyra sub-module)
  - Rewrote DESIGN.md following template (ontological purpose, circle context, embodiment)
  - DNS addresses the gap between existence and addressability — making kosmos reachable
  - Central concept: dual existence (intent in kosmos, actuality at provider, reconciler aligns)
  - Added 3 attainments: dns-read, dns-write, dns-admin (all scope: circle, oikos: thyra)
  - Converted eide/dns.yaml from old `eide:` format to `entities:` format (3 eide)
  - Note: DNS is under genesis/thyra/dns/ as a sub-module, praxeis in thyra namespace
  - Crystallized T67-T69 theoria

---

## Completion Summary

**All 16 oikoi redesigned.** Each now has:
- DESIGN.md following the standard template
- eide/*.yaml in `entities:` format with attainments (scope + grants)
- manifest.yaml with attainments section

**52 theoria crystallized** (T18-T69) capturing insights across all domains.

### Post-Redesign Tasks

1. ✅ Update this completion summary
2. ⏳ Crystallize theoria as entities in `genesis/nous/theoria/`
3. ⏳ Wire attainment checks into praxeis (enforcement)
4. ⏳ Run bootstrap validation in chora
5. ⏳ Create oikos map summary document

---

*The kosmos becomes coherent through intentional design. Each oikos, well-crafted, makes the whole greater than the sum.*
