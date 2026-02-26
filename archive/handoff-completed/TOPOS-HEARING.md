# Hearing Each Topos

## Context

This is the kosmos repository — pure ontology (YAML + Markdown). The implementation lives in chora.

We've just completed the V11 vocabulary migration (Phase 1 — all genesis definitions are clean). We've deleted the stale `oikoi/` directory (it was generated output). Now we want to do something deeper: **hear each topos into its fullness**.

## The Task

Go topos by topos through all 24 topoi in `genesis/`. For each one:

### 1. Read deeply

Read its DESIGN.md, manifest.yaml, eide/, desmoi/, and praxeis/ files. Don't skim — absorb what it's trying to say.

### 2. Hear what it's trying to be

Not just what the DESIGN.md declares, but what the topos is *reaching toward*. The DESIGN.md is not the limit — it's one articulation. Listen for:

- What is the ontological telos of this topos? What would it look like if it were *fully itself*?
- Where does the design describe something the artifacts can't yet express?
- Where might the design be underselling what the topos actually is?
- What relationships to other topoi are implied but not yet formalized as desmoi?

### 3. Check participation

A topos participates in the kosmos through:

- **Reachability** — desmoi that connect its entities to other topoi's entities
- **Visibility** — render-specs that make its entities perceivable through thyra
- **Composability** — its eide being usable as inputs to demiurge/compose

For each topos, ask: can other topoi find it and work with it? Is it isolated or woven in?

### 4. Identify the gap between aspiration and artifact

Not "missing files from a checklist" but genuine tensions:

- A topos that describes discourse but has no desmoi connecting utterances
- A topos that describes presence but can't be rendered
- A topos that describes validation but lacks attainments for the praxeis it actually provides
- A manifest that declares renderable eide but has no render-specs

### 5. Produce an assessment

For each topos, write a short (2-4 paragraph) assessment that captures:

- What this topos is trying to be (its telos, heard generously)
- Where it is now (what it actually provides)
- What would help it become more fully itself
- Whether it needs new artifacts, or whether its existing artifacts need to grow

## The Topoi (organized by klimax scale)

### Kosmos Scale — Substrate
1. **genesis** — Bootstrap, filesystem-to-graph
2. **stoicheia-portable** — Step vocabulary
3. **dynamis** — Power, capability tiers
4. **demiurge** — Composition, caching
5. **manteia** — Governed inference
6. **dokimasia** — Validation, provenance

### Physis Scale — Constraints
7. **ergon** — Work, daemons, reconciliation
8. **ekdosis** — Publication between oikoi
9. **release** — Artifact lifecycle

### Polis Scale — Governance
10. **politeia** — Oikoi, attainments, affordances
11. **hypostasis** — Identity, cryptography, phoreta
12. **credentials** — External service integration
13. **agora** — Embodied gathering

### Oikos Scale — Dwelling
14. **oikos** — Sessions, conversations, notes
15. **hodos** — Journeys, navigation paths
16. **nous** — Thinking, understanding, theoria
17. **logos** — Discourse, intentional utterance
18. **propylon** — Sovereign entry, device federation

### Soma Scale — Embodiment
19. **soma** — Channels, embodiment, sensing
20. **aither** — WebRTC, signaling
21. **my-nodes** — Node awareness

### Psyche Scale — Experience
22. **psyche** — Attention, intention, mood
23. **thyra** — Rendering, modes, phaseis

(Plus special structures: **arche**, **spora**, **klimax**, **chora-dev** — assess these too if they have DESIGN.md)

## What "Complete" Means (for reference)

A topos at full maturity has:

- **manifest.yaml** — honest declaration of what it provides and depends on
- **DESIGN.md** — ontological purpose (but remember: don't treat this as the ceiling)
- **eide/{topos}.yaml** — all declared entity types
- **praxeis/{topos}.yaml** — all declared operations
- **desmoi/{topos}.yaml** — bond types connecting to other topoi (if relational)
- **render-specs/** — widget trees for user-facing entities (if visible)
- **REFERENCE.md** — detailed semantics (if complex)

But completion is not the goal. **Participation** is. A topos is complete when it can do what it's trying to do and other topoi can work with it.

## Approach

Work through 4-6 topoi at a time in parallel (using explore agents). Synthesize the findings into a single coherent document. Don't produce a spreadsheet — produce a *listening report* that captures what each topos is saying and what it needs.

When you find a topos that needs something, note it concretely:
- "logos needs desmoi connecting utterances to oikos conversations"
- "dokimasia declares renderable eide but has no render-specs"
- "hodos describes journeys but can't link waypoints to nous theoria"

After the hearing, propose a prioritized list of interventions — not by topos importance, but by what would create the most participation (the most connections, the most visibility, the most composability).
