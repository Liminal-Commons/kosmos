# KOSMOGONIA V11 Coordination — For Chora Dev Window

This is a coordination note. It describes what changed in kosmos so the chora holonic diataxis plan can be updated accordingly. This file can be deleted after coordination is complete.

---

## What Changed

KOSMOGONIA has been revised from V10 to V11. The primary change is a **unified Greek vocabulary** — all constitutional-level ontological terms are now Greek. Additionally, the concept of **topos** (τόπος) has been restored as the name for capability domains (previously called "oikos"), and **oikos** (οἶκος) now means the social dwelling (previously called "circle").

### Vocabulary Migration

| Old Term | New Term | Greek | What It Is |
|----------|----------|-------|------------|
| **persona** | **prosopon** | πρόσωπον | Identity that persists across time |
| **animus** | **parousia** | παρουσία | Embodied presence in an oikos |
| **circle** | **oikos** | οἶκος | Social dwelling where prosopa gather |
| **oikos** (package) | **topos** | τόπος | Capability domain where praxeis dwell |
| **expression** | **phasis** | φάσις | Intentional contribution with provenance |

### Why This Change

The previous vocabulary had Latin terms (persona, animus) alongside Greek, and misused oikos (Greek for "household") to mean "software package" while using the Latin-derived "circle" for the social dwelling concept. V11 restores linguistic coherence:

- **oikos** means what it means in Greek — the household, where people gather
- **topos** means what it means in Greek — a place where capability dwells
- The primordial bond **"oikos hosts topos"** from the legacy architecture is restored
- All constitutional terms in the glossary are now Greek

### Structural Changes in V11

| Section | Change |
|---------|--------|
| The Seed | `expressed_by: persona/victor` preserved (signed content) but vocabulary is now prosopon |
| The Dwelling | Expanded from 3 forms (Triad) to 4 forms: prosopon, parousia, oikos, phasis |
| The Klimax | polis scale now says "governance and oikoi"; oikos scale says "dwelling and presence" |
| Oikos — The Pivotal Scale | Reworked: oikos = social dwelling, introduces topos as capability domain |
| Topos — Where Capability Dwells | New subsection under Klimax. Covers domain/package/boundary, lifecycle, distribution |
| The Navigation | "Per-topos design and purpose" and "genesis/{topos}/DESIGN.md" |
| Glossary | 18 terms, all Greek. Added: parousia, phasis, prosopon, topos. Removed: circle, expression, persona |

---

## Impact on Chora Implementation

### Phase 1: Genesis Definitions — COMPLETE

All genesis YAML and kosmos documentation has been migrated:

| Scope | Status |
|-------|--------|
| All 24 topos YAML files (eide, desmoi, praxeis, manifest, entities) | Done — 0 legacy terms |
| `arche/eidos.yaml`, `arche/desmos.yaml`, `arche/dynamis-interface.yaml` | Done |
| `spora/` definitions (all files) | Done |
| All per-topos DESIGN.md and REFERENCE.md files | Done |
| All klimax DESIGN.md files (7) | Done |
| `CLAUDE.md`, `CONTRIBUTING.md`, `KOSMOGONIA.md` | Done |
| `genesis/ROADMAP.md` | Done |
| `thyra/ALIGNMENT.md`, `dns/DESIGN.md`, `END-TO-END.md`, `credentials/DESIGN.md` | Done |
| All diataxis docs (`docs/architecture/`, `docs/reference/`, `docs/explanation/`) | Done |
| `expression/genesis-root` → `phasis/genesis-root` (8 files) | Done |

**Preserved correctly:**
- `persona/victor` in KOSMOGONIA signed block (cryptographically immutable)
- "full-circle" as English idiom (not ontological "circle")
- "expression" in stoicheia/programming contexts (not discourse "expression")

**Not in scope for Phase 1:**
- `oikoi/` directory (runtime content, migrates with Phase 2)
- `phoreta/` directory (generated bundle, regenerated after Phase 2)

### Phase 2: Chora Implementation — NOT STARTED

| Component | Changes Needed |
|-----------|---------------|
| **Rust interpreter** | Entity type strings, bond types, ID prefix handling |
| **Database** | Migration script: rename entity types and bond types in kosmos.db |
| **TypeScript UI** | Component names, labels, API types |
| **MCP tools** | Tool names that reference oikos (currently `{oikos}_{name}`) become `{topos}_{name}` |

### Vocabulary Reference for Migration

**Plurals:**
- prosopon → prosopa (πρόσωπα)
- topos → topoi (τόποι)
- oikos → oikoi (οἶκοι) — already in use
- phasis → phaseis (φάσεις)
- parousia → (use "parousia instances" or avoid plural)

**ID namespace changes:**
- `persona/*` → `prosopon/*`
- `circle/*` → `oikos/*`
- `animus/*` → `parousia/*`
- `expression/*` → `phasis/*`
- `oikos` field in praxis → `topos` field in praxis

---

## Impact on Holonic Diataxis Plan

### Doc naming
- References to "oikos" in doc filenames that mean "package/module" should become "topos"
- References to "oikos" that mean "social dwelling" stay as "oikos"
- `docs/explanation/oikos/` is now correctly named (it explains the social dwelling concept)

### REGISTRY.md
- Should list KOSMOGONIA V11 as constitutional root
- Vocabulary migration entry: tracks the old→new term mapping for the transition period

### Holonic principle
- Every new doc should use V11 vocabulary from the glossary
- The glossary in KOSMOGONIA V11 is the authoritative term list (18 terms, all Greek)

### CLAUDE.md alignment
- kosmos/CLAUDE.md has been updated to V11 vocabulary
- chora/CLAUDE.md should reference kosmos/CLAUDE.md for shared vocabulary
- During transition: chora code still uses old terms; docs should use new terms with notes

---

## Suggested Migration Order

1. **Constitutional declaration** — DONE (KOSMOGONIA V11 + CLAUDE.md)
2. **Genesis YAML** — DONE (all 24 topoi, arche, spora, klimax)
3. **Kosmos documentation** — DONE (diataxis docs, per-topos docs, CONTRIBUTING.md)
4. **Chora interpreter** — Update Rust entity type handling
5. **Database migration** — Script to rename types/bonds in kosmos.db
6. **UI/MCP** — Update TypeScript and tool names

Steps 1–3 are complete. The kosmos repository uses V11 vocabulary exclusively (except for the cryptographically signed `persona/victor` in KOSMOGONIA and English idiom "full-circle"). Steps 4–6 are chora implementation work.
