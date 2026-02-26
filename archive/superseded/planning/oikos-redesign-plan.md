# Oikos Redesign Plan

A high-touch, comprehensive redesign of each oikos in the kosmos genesis layer. The goal is ontological coherence and compound leverage through intentional design.

**Related:** [CHORA-HANDOFF-OIKOS-DEV.md](../../../CHORA-HANDOFF-OIKOS-DEV.md) — Implementation requirements for Projected/Embodied/Surfaced/Afforded levels.

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

### Phase 2 Oikoi (Separated from parents)

| # | Oikos | Greek | Purpose | Extracted From | Status |
|---|-------|-------|---------|----------------|--------|
| 17 | **hodos** | ὁδός | Journey navigation — the way | thyra | ✅ |
| 18 | **opsis** | ὄψις | Visual rendering — appearance | thyra | ✅ |
| 19 | **release** | — | Artifact lifecycle — distribution | dynamis | ✅ |
| 20 | **credentials** | — | External service credentials | hypostasis | ✅ |
| ~~21~~ | ~~syndesmos~~ | — | ~~Connection state~~ | aither | ↩️ merged back |
| ~~22~~ | ~~synthesis~~ | — | ~~Combining understandings~~ | nous | ↩️ merged back |

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
| T70 | The way is distinct from the destination | hodos |
| T71 | Navigation is personal | hodos |
| T72 | Form validation belongs to navigation | hodos |
| T73 | Appearance is not existence | opsis |
| T74 | Rendering is reconciliation | opsis |
| T75 | Homoiconic rendering | opsis |
| T76 | Releases are journeys | release |
| T77 | Artifacts are the actuality of releases | release |
| T78 | Channels multiply reach | release |
| T79 | Credentials are capability bridges | credentials |
| T80 | Session is the trust boundary | credentials |
| T81 | Attainment unifies capability sources | credentials |
| T82 | Connection intent survives failure | syndesmos |
| T83 | Messages deserve delivery attempts | syndesmos |
| T84 | Sync is eventual consistency | syndesmos |
| T85 | Synthesis is not summary | synthesis |
| T86 | Inquiries drive understanding forward | synthesis |
| T87 | Sources preserve provenance | synthesis |

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

- **Created hodos as standalone oikos** (Phase 2)
  - Created DESIGN.md following template (ontological purpose, circle context, embodiment)
  - Hodos addresses the gap between knowing the destination and arriving — navigation mechanics
  - Central concept: the way (kinetics of movement through journeys)
  - Moved praxeis from thyra/praxeis/hodos.yaml to genesis/hodos/praxeis/
  - Added 1 attainment: navigate (scope: animus)
  - Crystallized T70-T72 theoria
- **Created opsis as standalone oikos** (Phase 2, extracted from thyra)
  - Created DESIGN.md following template
  - Opsis addresses the gap between existence and appearance — visual rendering
  - Central concept: appearance (how entities show up visually)
  - 9 eide: layout, panel, style-theme, render-intent, workspace, render-type, renderer, render-spec, widget
  - 1 attainment: render (scope: soma)
  - Praxis namespace: praxis/opsis/*
  - Crystallized T73-T75 theoria
- **Created release as standalone oikos** (Phase 2, extracted from dynamis)
  - Created DESIGN.md following template
  - Release addresses the gap between built artifact and available download
  - Central concept: artifact journey (from git commit to user installation)
  - 3 eide: release, release-artifact, distribution-channel
  - 1 attainment: release (scope: circle)
  - Praxis namespace: praxis/release/*
  - Crystallized T76-T78 theoria
- **Created credentials as standalone oikos** (Phase 2, extracted from hypostasis)
  - Created DESIGN.md following template
  - Credentials addresses the gap between external service access and kosmos capability
  - Central concept: capability bridge (external credentials become internal attainments)
  - 1 eidos: credential
  - 2 attainments: unlock-credential, use-credential
  - Praxis namespace: praxis/credentials/*
  - Crystallized T79-T81 theoria
- **Created syndesmos as standalone oikos** (Phase 2, extracted from aither)
  - Created DESIGN.md following template
  - Syndesmos addresses the gap between connection intent and connection actuality
  - Central concept: the desired connection (intent that persists across failures)
  - 3 eide: syndesmos, outbound-message, sync-message
  - 1 attainment: sync (scope: circle)
  - Praxis namespace: praxis/syndesmos/*
  - Crystallized T82-T84 theoria
- **Created synthesis as standalone oikos** (Phase 2, extracted from nous)
  - Created DESIGN.md following template
  - Synthesis addresses the gap between multiple insights and unified understanding
  - Central concept: the bringing-together (many become one, greater than sum)
  - 2 eide: synthesis, inquiry
  - 1 attainment: inquire (scope: circle)
  - Praxis namespace: praxis/synthesis/*
  - Crystallized T85-T87 theoria

- **Merged syndesmos back into aither** (first principles review)
  - Syndesmos addresses the same gap as aither (here ↔ there) via dynamis pattern
  - Connection intent/actuality is *how* aither works, not a distinct gap
  - Eide (syndesmos, outbound-message, sync-message) merged into aither/eide/aither.yaml
  - Sync attainment merged into aither with praxis/aither/* grants
  - Removed genesis/syndesmos/ directory
  - T82-T84 theoria remain valid (describe the pattern, not the oikos)

- **Merged synthesis back into nous** (first principles review)
  - Synthesis addresses the same gap as nous (ignorance ↔ understanding)
  - Combining insights is a *method* of understanding, not a distinct kind
  - Eide (synthesis, inquiry) merged into nous/eide/nous.yaml
  - Inquire attainment merged into nous with praxis/nous/* grants
  - Removed genesis/synthesis/ directory
  - T85-T87 theoria remain valid (describe the pattern, not the oikos)

### 2026-01-29 (continued)
- **Completed oikos-centric rendering** (Phase 4 of rendering architecture)
  - Added render-specs for all user-facing eide across 15+ oikoi
  - Added `provides.renderable` declarations to all manifests
  - Added `entities/` content_paths for render-spec files
  - Render-spec convention: `render-spec/{eidos}-card`, `render-spec/{eidos}-item`
  - Created rendering.yaml files: psyche, oikos, propylon, aither, agora, dynamis, dokimasia, ekdosis

- **Updated completeness ladder status**
  - All 20 oikoi now at Loaded level
  - Documented what's possible (kosmos-side) vs what requires chora
  - Linked to CHORA-HANDOFF-OIKOS-DEV.md for implementation requirements
  - Split post-redesign tasks into kosmos-side and chora-side

---

## Completion Summary

**20 oikoi total** (16 original + 4 extracted in Phase 2). Each now has:
- DESIGN.md following the standard template
- eide/*.yaml in `entities:` format with attainments (scope + grants)
- manifest.yaml with attainments section
- Own praxis namespace (praxis/{oikos}/*)
- Render-specs for user-facing eide (oikos-centric rendering)

**70 theoria crystallized** (T18-T87) capturing insights across all domains.

---

## Completeness Ladder Implementation Status

All 20 oikoi have achieved **Loaded** level. The path to full completeness requires chora implementation.

See [CHORA-HANDOFF-OIKOS-DEV.md](CHORA-HANDOFF-OIKOS-DEV.md) for detailed implementation requirements.

### Current State

| Level | Status | What's Required |
|-------|--------|-----------------|
| **Defined** | ✅ All 20 oikoi | YAML definitions in genesis |
| **Loaded** | ✅ All 20 oikoi | Bootstrap loads into kosmos.db |
| **Projected** | ⏳ Chora-dependent | Dynamic praxis registration at runtime |
| **Embodied** | ⏳ Chora-dependent | Body-schema aggregates oikos state |
| **Surfaced** | ⏳ Chora-dependent | Reconcilers surface opportunities |
| **Afforded** | ⏳ Chora-dependent | Thyra renders contextual actions |

### Implementation Priority (from handoff)

| Feature | Chora Subsystem | Impact |
|---------|-----------------|--------|
| **Body-schema contribution** | soma | Enables Claude awareness of oikos state |
| **Development reconciler** | ergon | Surfaces opportunities contextually |
| **project-oikos** | kosmos-mcp | Dynamic tool registration for testing |
| **Thyra oikos-view** | opsis/thyra | Visual development environment |

### What's Possible Now (Kosmos-side)

With Loaded level complete, the following patterns work:

1. **Praxis composition** — All praxeis can be authored and validated
2. **Entity creation** — Entities arise via compose/typos pattern
3. **Bond traversal** — Graph queries work (trace, traverse, gather)
4. **Render-specs** — Declarative rendering definitions exist for all user-facing eide
5. **Attainment definitions** — All oikoi declare what capabilities they gate
6. **MCP projection** — Praxeis project as MCP tools at bootstrap

### What Requires Chora

The remaining completeness levels require Rust implementation:

1. **Dynamic projection** — Register/unregister praxeis at runtime (project stoicheion)
2. **Body-schema sensing** — Aggregate development state into sense-body output
3. **Reconciler infrastructure** — On-dwell triggers, pending action surfacing
4. **Declarative rendering** — Template parsing, data preparation, component binding

---

## Completeness Strategy by Oikos Type

The path to "Afforded" differs by oikos category and scale. Not all oikoi need full UI — infrastructure oikoi operate quietly while interface oikoi need rich rendering.

### Oikos Taxonomy

| Category | Oikoi | What "Complete" Means |
|----------|-------|----------------------|
| **infrastructure** | hypostasis, soma, propylon, demiurge, ekdosis, dokimasia, dynamis, ergon, credentials, release, stoicheia | Projected + Embodied. Minimal UI (admin views). Reconcilers sense drift. |
| **interface** | thyra, opsis, aither, manteia | Full stack. These ARE the rendering/interaction layer. |
| **domain** | oikos, politeia, psyche, nous, agora, hodos | Afforded. User-facing with contextual actions in Thyra. |

### Implementation Tiers

**Tier 0: Foundation (unlocks all others)**

| Oikos | Scale | Why First | Chora Work |
|-------|-------|-----------|------------|
| **soma** | soma | Owns body-schema. All embodiment flows through soma. | sense-body extension |
| **politeia** | polis | Attainment checks gate all praxeis. | attainment enforcement |

**Tier 1: Interface Layer (visual experience)**

| Oikos | Scale | Why | Chora Work |
|-------|-------|-----|------------|
| **opsis** | soma | Owns rendering. All visual display flows through opsis. | render-spec processing |
| **thyra** | soma | Owns streams/expression. Commitment boundary. | panel/view rendering |
| **hodos** | animus | Navigation kinetics. Journey execution. | step navigation |

**Tier 2: User-Facing Domains**

| Oikos | Scale | Why | Chora Work |
|-------|-------|-----|------------|
| **oikos** | oikos | Dwelling experience. Sessions, notes, insights. | session reconciler |
| **psyche** | psyche | Attention/intention. What matters now. | attention surfacing |
| **agora** | oikos | Spatial presence. Gathering space. | territory rendering |
| **nous** | cross | Understanding. Theoria discovery. | semantic surfacing |

**Tier 3: Capability Projection**

| Oikos | Scale | Why | Chora Work |
|-------|-------|-----|------------|
| **manteia** | cross | Generation. Claude's creative faculty. | inference pipeline |
| **demiurge** | cross | Composition. Entity creation. | typos resolution |
| **ergon** | cross | Work coordination. Pragma flow. | pragma reconciler |
| **aither** | physis | Networking. P2P transport. | connection reconciler |

**Tier 4: Infrastructure (quiet operation)**

| Oikos | Scale | Why Last | Chora Work |
|-------|-------|----------|------------|
| **hypostasis** | cross | Identity. Cryptographic substrate. | keyring UI (admin) |
| **propylon** | cross | Entry. Authentication flows. | entry flow UI |
| **dynamis** | cross | Actuality bridging. Deployment. | deployment reconciler |
| **ekdosis** | cross | Publication. Release management. | release reconciler |
| **dokimasia** | cross | Validation. Schema enforcement. | validation reporting |
| **credentials** | cross | External access. API keys. | credential admin UI |
| **release** | cross | Artifact lifecycle. Distribution. | artifact reconciler |

### Category-Specific Completion Criteria

**Infrastructure oikoi** are complete when:
- ✅ Defined (YAML exists)
- ✅ Loaded (in kosmos.db)
- ⬜ Projected (praxeis as MCP tools — at bootstrap, sufficient)
- ⬜ Embodied (state in body-schema — only relevant subset)
- ⬜ Surfaced (reconciler for drift/errors — operational alerts)
- ⬜ Afforded (admin views only — not user-facing)

**Interface oikoi** are complete when:
- ✅ Defined
- ✅ Loaded
- ⬜ Projected (full dynamic projection for development)
- ⬜ Embodied (rendering state in body-schema)
- ⬜ Surfaced (rendering opportunities)
- ⬜ Afforded (full declarative rendering pipeline)

**Domain oikoi** are complete when:
- ✅ Defined
- ✅ Loaded
- ⬜ Projected (praxeis available contextually)
- ⬜ Embodied (domain state in body-schema)
- ⬜ Surfaced (contextual actions based on dwelling)
- ⬜ Afforded (domain-specific views and affordances)

### Recommended Sequence

```
Tier 0 ─────────────────────────────────────────────────────►
        soma (body-schema) → politeia (attainments)

Tier 1 ─────────────────────────────────────────────────────►
        opsis (rendering) → thyra (streams) → hodos (navigation)

Tier 2 ─────────────────────────────────────────────────────►
        oikos → psyche → agora → nous

Tier 3 ─────────────────────────────────────────────────────►
        manteia → demiurge → ergon → aither

Tier 4 ─────────────────────────────────────────────────────►
        hypostasis → propylon → dynamis → ekdosis → dokimasia → credentials → release
```

Each tier unlocks capabilities for the next. Soma enables body-schema for all. Opsis enables rendering for all. Domain oikoi need both before they can be fully afforded.

---

### Post-Redesign Tasks

**Kosmos-side (complete in genesis):**

1. ✅ Update this completion summary
2. ✅ Add render-specs for all user-facing eide
3. ✅ Crystallize theoria as entities in `genesis/nous/theoria/`
4. ~~Wire attainment checks~~ — Redundant per KOSMOGONIA: "Visibility = Reachability" means attainments are positions in the bond graph, not separate gates
5. ✅ Create oikos map summary document (OIKOS-MAP.md)

**Chora-side (requires Rust implementation):**

6. ⏳ Extend sense-body with development state
7. ⏳ Implement reconciler infrastructure
8. ⏳ Add project stoicheion for dynamic praxis registration
9. ⏳ Implement declarative render-spec processing
10. ⏳ Run bootstrap validation across all 20 oikoi

---

*The kosmos becomes coherent through intentional design. Each oikos, well-crafted, makes the whole greater than the sum.*
