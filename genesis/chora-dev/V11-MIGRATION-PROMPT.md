# V11 Migration — Vocabulary + Topos Alignment

*The constitution leads. The definitions follow.*

---

## What This Is

KOSMOGONIA V11 unified the constitutional vocabulary to all-Greek and restored the primordial bond between oikos and topos. But vocabulary migration alone does not produce coherence. The existing topoi were authored across different periods with different conventions. Many predate current design principles (GDS, render-specs, reconciler pattern). This migration addresses both dimensions:

1. **Vocabulary** — Mechanical rename of legacy terms to V11 Greek
2. **Alignment** — Each topos reviewed against constitutional criteria derived from KOSMOGONIA

The goal is not backward-compatible evolution. It is **complete coherence** — every topos aligned to the same constitutional principles, expressed in the same vocabulary, following the same patterns.

---

## The Vocabulary Migration

| Old Term | New Term | Greek | What It Is | Plural |
|----------|----------|-------|------------|--------|
| **persona** | **prosopon** | πρόσωπον | Identity that persists across time | prosopa |
| **animus** | **parousia** | παρουσία | Embodied presence of a prosopon in an oikos | (avoid plural) |
| **circle** | **oikos** | οἶκος | Social dwelling where prosopa gather and govern | oikoi |
| **oikos** (package) | **topos** | τόπος | Capability domain where praxeis inhabit | topoi |
| **expression** | **phasis** | φάσις | Intentional contribution with provenance | phaseis |

### Restored Primordial Bonds

```
oikos hosts topos       — the dwelling hosts capability domains
praxis inhabits topos   — actions dwell in places of capability
parousia dwells-in oikos — presence arises in a household
```

### The Seed — Special Case

The signed block in KOSMOGONIA says `expressed_by: persona/victor` — cryptographically signed content that cannot change without re-signing. The vocabulary around it uses V11 terms. This is a historical artifact, not a contradiction.

---

## What a Topos Is

A topos is a **capability domain** — an organized body of eide, typoi, desmoi, and praxeis dedicated to a specific concern. It is the distributable unit of capability in the kosmos.

**The relationship:** Prosopa dwell in oikoi. Oikoi host topoi. Praxeis inhabit topoi. A topos is not where you dwell — an oikos is where you dwell. A topos is the capability your dwelling provides. When an oikos hosts the nous topos, its members gain thinking capability. When it hosts soma, they gain embodiment.

**Topos categories:**

| Category | Character | Examples |
|----------|-----------|----------|
| **Infrastructure** | The machinery — what makes the kosmos work | genesis, demiurge, dynamis, stoicheia-portable, hypostasis, ekdosis, propylon, credentials, dokimasia |
| **Interface** | Boundaries — where kosmos meets human, network, or LLM | thyra, aither, manteia |
| **Domain** | Practice — where prosopa exercise capability | nous, psyche, politeia, oikos, agora, hodos, soma, ergon, logos |
| **Tooling** | Development — meta-tools for building kosmos itself | chora-dev |

**Topos lifecycle:**

| State | Form | Location |
|-------|------|----------|
| **topos-dev** | Working content | genesis/ filesystem |
| **topos-prod** | Signed, versioned | kosmos graph + registry |
| **installed** | Loaded into kosmos | local kosmos.db |

---

## Topos Evaluation Criteria

Every criterion traces to a KOSMOGONIA principle. These are not preferences — they are constitutional requirements.

### I. Constitutional Positioning

**1. Klimax alignment**
Does the topos know its scale? Does it establish context for scales below it?

*Derives from:* KOSMOGONIA § The Klimax — "Each scale establishes ambient context for the next."

**2. Dwelling participation**
Does the topos properly use dwelling context (`$_prosopon`, `$_parousia`, `$_oikos`)? Does it respect the dwelling requirement — context is position, not parameter?

*Derives from:* KOSMOGONIA § The Dwelling Requirement — "Context is not passed. Context is position."

**3. Sovereignty respect**
Does the topos honor visibility=reachability? Does it verify through bonds, not assume through permissions? Does every entity carry provenance?

*Derives from:* KOSMOGONIA § The Constitutional Pillars — Sovereignty, Visibility, Authenticity.

### II. Ontological Integrity

**4. Eidos completeness**
Every entity type fully specified: fields with types, descriptions, and constraints. Attainments defined with proper scope (oikos-level). No entity types used in praxeis that aren't declared as eide.

*Derives from:* KOSMOGONIA § The Five Archai — "Eidos declares fields, constraints, what properties an entity of this type can have."

**5. Desmos correctness**
Bonds properly typed with from_eidos/to_eidos that match actual usage. No dead desmos definitions. No bonds used in praxeis that aren't declared.

*Derives from:* KOSMOGONIA § The Relational Arche.

**6. Manifest accuracy**
Every praxis declared in the manifest exists in the YAML. Every praxis in the YAML is declared in the manifest. Stoicheia form matches actual usage. No ghosts.

*Derives from:* KOSMOGONIA § Performative Bootstrap — "The specification becomes the thing."

### III. Compositional Discipline

**7. GDS compliance (templates are dumb molds)**
No `{{#each}}`, `{{#if}}`, ternaries, or block conditionals in any template. Computation lives in praxis steps. Templates only assemble pre-computed values via `{{ variable }}` and `{{ var | filter }}`.

*Derives from:* CLAUDE.md § The GDS Principle — "Computation lives in praxis steps. Templates only assemble pre-computed values."

**8. Constitutional enforcement**
No direct `arise` or `infer` in praxeis. Entity creation uses `compose` (via demiurge). LLM generation uses `governed-inference` (via manteia). These are the constitutional interfaces.

*Derives from:* KOSMOGONIA § The Constitutional Enforcement — "Nothing arises raw. Everything is composed."

**9. Stoicheion consistency**
One syntax per stoicheion across the entire kosmos. Filter uses `items:` / `condition:` / `bind_to:` (not `in:` / `as:` / `where:`). Params match stoicheion schema in arche/stoicheion.yaml.

*Derives from:* KOSMOGONIA § The Operational Arche — stoicheion is the atomic, typed vocabulary of action.

### IV. Pattern Adherence

**10. Reconciler pattern**
Eide that declare actuality follow sense→compare→act. Actuality is sensed, not assumed. The kosmos declares intent; the reconciler discovers actuality; praxeis bridge the gap.

*Derives from:* KOSMOGONIA § Actuation = Reconciliation.

**11. Render-spec for UI**
Views defined as render-spec widgets (for-each, when:, include), not template+script. The render-spec IS the model — it proves the GDS pattern for UI.

*Derives from:* CLAUDE.md § Render-Specs Are the Model.

**12. Narrow Way**
Nothing that can be composed from what exists. No redundant praxeis. No helper abstractions for one-time operations. The constraint creates the freedom.

*Derives from:* KOSMOGONIA § The Meta-Patterns — Narrow Way.

### V. Coherence

**13. V11 vocabulary**
All terms from KOSMOGONIA V11 glossary. Zero legacy terms (persona, animus, circle, expression, oikos-as-package). No backward-compatibility shims.

*Derives from:* KOSMOGONIA V11 glossary — 18 terms, all Greek.

**14. DESIGN.md**
Every topos has a DESIGN.md that traces to KOSMOGONIA. It explains the topos's place in the klimax, its eide, its desmoi, its praxeis, and how they serve the constitutional vision. This is explanation, not reference.

*Derives from:* KOSMOGONIA § The Navigation — "DESIGN.md files in each topos trace back to this document's archai and pillars."

**15. Self-description (homoiconicity)**
The topos participates in the graph it describes. Its manifest, eide, and praxeis are themselves entities. It can describe itself using its own vocabulary.

*Derives from:* KOSMOGONIA § The Meta-Patterns — Homoiconicity.

---

## Migration Status

### Phase 0 — Constitutional Declaration: DONE

KOSMOGONIA V11, CLAUDE.md (both repos), coordination note — all updated.

### Phase 1 — Genesis Definitions: IN PROGRESS

**Grammar layer (arche + spora): DONE**
- arche/eidos.yaml, arche/desmos.yaml, arche/stoicheion.yaml, arche/dynamis-interface.yaml
- All spora definitions, circles, theoria, patterns, principles, journeys
- logos/eide/logos.yaml (expression → phasis)
- All manifests: `oikos_id:` → `topos_id:` (24/24)
- All praxeis: `oikos:` field → `topos:` field (bulk)
- All eide attainments: `scope: circle` → `scope: oikos` (bulk)

**Per-topos alignment: DONE**

All 24 topoi migrated. All YAML files verified clean:
- `persona`: 0 matches in YAML (only `persona/victor` in signed KOSMOGONIA block)
- `animus`: 0 matches
- `circle` (ontological): 0 matches in YAML
- `expression` (discourse sense): 0 matches in YAML
- `$_circle`, `$_persona`, `$_animus`: 0 matches
- `create-circle`, `join-circle`, `leave-circle`: 0 matches
- `eidos: circle/persona/animus`: 0 matches
- `expression/genesis-root` → `phasis/genesis-root`: migrated everywhere

Design pattern fixes applied during migration:
- Filter stoicheion syntax standardized to `items:/condition:/bind_to:`
- Direct `infer`/`emit` usage flagged (psyche — to be fixed in chora)
- Manifest-declared praxeis verified against actual praxeis
- Deprecated fields removed where found

**Klimax DESIGN.md files: DONE**
All 7 klimax scale DESIGN.md files migrated (persona→prosopon, animus→parousia, circle→oikos).

**Other documentation: DONE**
- thyra/ALIGNMENT.md (~106 replacements)
- ROADMAP.md (~38 replacements)
- thyra/dns/DESIGN.md, END-TO-END.md, credentials/DESIGN.md migrated
- Per-topos DESIGN.md and REFERENCE.md files all clean

**Diataxis docs: DONE**
- docs/architecture/overview.md — `_persona` → `_prosopon`
- docs/reference/session-identity.md — `$_persona` → `$_prosopon`
- docs/reference/rest-api.md — `$_persona` → `$_prosopon`
- docs/explanation/federation.md — `remote_persona_pubkey` → `remote_prosopon_pubkey`
- README.md — `expression/genesis-root` → `phasis/genesis-root`
- CONTRIBUTING.md — "expression" → "phasis", "cross-circle" → "cross-oikos", dwelling vars migrated

**Discourse "expression" sweep: DONE**
- spora/definitions/manteia.yaml — "expression content" → "phasis content" (2 occurrences)
- spora/journeys/future-releases.yaml — "expression sync" → "phasis sync"
- spora/theoria/cosmology.yaml — `genesis-signed-expression` → `genesis-signed-phasis`
- spora/spora.yaml — "signed expression" → "signed phasis"
- spora/principles/core.yaml — "Embodiment over expression" → "Embodiment over articulation"

**Doc file renames: DONE**
- `docs/reference/expression-entity.md` → `phasis-entity.md`
- `docs/reference/expression-workspace.md` → `phasis-workspace.md`
- `docs/tutorial/first-expression.md` → `first-phasis.md`
- `docs/reference/expression-evaluator.md` — KEPT (programming concept)
- All cross-references updated (index.md, REGISTRY.md, phasis-entity.md, first-phasis.md, entity-overlays.md, two-phase-bindings.md)

**Grammar fix: DONE**
- docs/index.md — "Create an Topos" → "Create a Topos"

### Kosmos V11 Migration: COMPLETE

Zero legacy ontological terms remain in any active kosmos file. Verified by exhaustive grep across all .md and .yaml files. Every remaining match is accounted for:

| Category | Status |
|----------|--------|
| `persona` in phoreta/, oikoi/, archive/ | Expected — these migrate with chora Phase 2 |
| `animus` in phoreta/, oikoi/, archive/ | Expected — same |
| `circle` as "full-circle" idiom or CSS icon | Correct English / icon names — preserved |
| `expression` as programming concept | Correct stoicheion parameter type — preserved |
| `persona/victor` in KOSMOGONIA signed block | Cryptographically immutable — documented |
| `expression-evaluator.md` filename | Programming evaluator, not discourse — preserved |
| Legacy terms in chora-dev/ migration docs | Intentional — describes old→new mapping |

### Phase 2 — Chora Implementation: NOT STARTED

See [CHORA-V11-MIGRATION-PROMPT.md](CHORA-V11-MIGRATION-PROMPT.md) for the comprehensive chora migration guide.

- Rust interpreter: entity type strings, bond types, ID prefixes (~565 occurrences across 40+ files)
- Database migration: rename types/bonds in kosmos.db
- TypeScript UI: component names, labels, API types
- MCP tools: `{oikos}_{name}` → `{topos}_{name}`

---

## Per-Topos Review Template

For each topos, the review produces:

```
## {topos_name} ({topos_id})

**Scale:** {klimax scale}
**Category:** infrastructure | interface | domain | tooling

### Vocabulary
- [ ] Zero legacy terms in all YAML files
- [ ] Entity IDs use V11 prefixes

### Ontological Integrity
- [ ] All eide complete with fields, descriptions, attainments
- [ ] All desmoi properly typed and used
- [ ] Manifest matches actual praxeis (no ghosts, no undeclared)

### Compositional Discipline
- [ ] GDS compliant (templates are dumb molds)
- [ ] No direct arise/infer (use compose/governed-inference)
- [ ] Filter syntax: items/condition/bind_to

### Pattern Adherence
- [ ] Reconciler pattern for actualized eide
- [ ] Render-specs for UI (not template+script)
- [ ] No redundant abstractions (Narrow Way)

### Coherence
- [ ] DESIGN.md traces to KOSMOGONIA
- [ ] Self-describing (homoiconic participation in graph)
```

---

## Reference

| Document | Purpose |
|----------|---------|
| [KOSMOGONIA V11](../KOSMOGONIA.md) | Constitutional root — the authoritative vocabulary and principles |
| [CLAUDE.md](../../CLAUDE.md) | Operational guidance — design principles and authoring patterns |
| [KOSMOGONIA-COORDINATION.md](KOSMOGONIA-COORDINATION.md) | Coordination note for chora developers |

---

*The constitution leads. The definitions follow. No backward compatibility. No bridges to the past. Complete coherence.*
