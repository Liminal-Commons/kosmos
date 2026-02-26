# PROMPT: V12 Doc Alignment

**Purpose**: Align all documentation with KOSMOGONIA V12 after the V11→V12 transition.

**Context**: KOSMOGONIA V12 restructured the constitutional root. The primary change: requirements and pillars (which did double duty in V11) are now separated into **axioms** (invariant truths) and **pillars** (protective mechanisms). New axioms were added. The constitution now commits to axiom, not architecture.

---

## What Changed: V11 → V12

### Structural

| V11 | V12 | Nature of change |
|-----|-----|------------------|
| "The Constitutional Pillars" (primary structure) | "The Constitutional Axioms" (new primary) + "The Constitutional Pillars" (now protects axioms) | Axioms elevated above pillars |
| "The Requirements" (4: Composition, Dwelling, Authenticity, Validity) | "The Constitutional Axioms" (5: Composition, Authority, Traceability, Self-Grounding, Adequacy) | Requirements restructured as axioms |
| "Five patterns" in Meta-Patterns | "Six patterns" — Self-Grounding added | New meta-pattern |

### Terminology mapping

| V11 term | V12 equivalent | Notes |
|----------|---------------|-------|
| "Composition Requirement" | Axiom I: Composition | Same content, elevated to axiom |
| "Dwelling Requirement" | Partially Axiom II: Authority; context-is-position remains in axiom text | No longer a named requirement |
| "Authenticity Requirement" | Axiom III: Traceability + Axiom V: Adequacy | Split across two axioms |
| "Validity Requirement" | Still exists (unchanged, not elevated) | Kept as requirement |
| "Constitutional Pillars" (as axioms) | "Constitutional Axioms" | Pillars still exist but protect axioms |
| "Five patterns" | "Six patterns" | Self-Grounding added |

### New concepts in V12

| Concept | What it is |
|---------|-----------|
| **Axiom II: Authority** | "The kosmos acts only as authorized by those who dwell in it." Covers prosopa, delegated agents, ambient infrastructure. The kosmos is intelligent but not sovereign. |
| **Axiom III: Traceability** | "Every entity's origin is verifiable through the bond graph." Provenance is structural, not asserted. |
| **Axiom IV: Self-Grounding** | "The ground does not ground itself." Provenance infrastructure has reduced provenance. |
| **Axiom V: Adequacy** | "Every arise path records whatever provenance is both constitutive and available." Ontological + circumstantial variance. |
| **Self-Grounding meta-pattern** | Sixth pattern. Constitutional infrastructure cannot have full provenance because it IS what provenance is made of. |
| **Klimax provenance gradient** | Provenance depth increases as the klimax descends. |

### What did NOT change

- The Five Archai (eidos, typos, desmos, stoicheion, dynamis) — unchanged
- Two Modes of Being (hyparxis, energeia) — unchanged
- The Dwelling forms (prosopon, parousia, oikos, phasis) — unchanged
- The Pillars (Sovereignty, Identity, Visibility, Authenticity, Actuation) — names unchanged, reframed as protecting axioms
- The Klimax structure — unchanged (provenance gradient sentence added)
- Topos structure — unchanged
- Constitutional Enforcement — unchanged
- Glossary — unchanged

---

## Phase 1: Must-Update Files

These files reference V11 concepts by name that changed. Update the specific references.

### 1. `docs/explanation/architecture/architecture.md`

**References found**:
- "Key Invariants" section (~line 437-444) cites "KOSMOGONIA constitutional pillars" and lists specific requirements
- Constitutional Enforcement section (~line 450) quotes KOSMOGONIA composition promise

**Required changes**:
- Update "Key Invariants" to reference constitutional axioms, not pillars
- Map any "Composition Requirement" → Axiom I, "Dwelling Requirement" → Axiom II, "Authenticity Requirement" → Axiom III/V
- Keep pillar references (Sovereignty, Identity, Visibility, Authenticity, Actuation) — these still exist

### 2. `genesis/thyra/ALIGNMENT.md`

**References found**:
- Lines 31-41: Table of 6 KOSMOGONIA requirements (K1-K6) including "The Composition Requirement", "The Dwelling Requirement", "visibility = reachability, authenticity = provenance"
- Lines 85-98: First mover problem analysis referencing klimax
- Lines 109-114: Dwelling authority analysis
- Lines 1430-1445: Federation sovereignty principles from KOSMOGONIA

**Required changes**:
- K1-K6 table: Update requirement names to axiom names where applicable
- K2 "Composition Requirement" → "Axiom I: Composition"
- K3 "Dwelling Requirement" → "Axiom II: Authority" (context-is-position is still in the axiom text)
- K4 pillar references (Visibility, Authenticity) — still valid, no change needed
- Consider adding new K entries for Authority, Self-Grounding, Adequacy axioms
- Federation sovereignty analysis still holds — Visibility = Reachability is still a pillar

### 3. `CLAUDE.md` (kosmos root)

**References found**:
- Line 38: KOSMOGONIA described as "Constitutional root — ontology and principles"
- Line 55: "see KOSMOGONIA § The Five Archai"
- Line 138: "operationalize the constitution established in KOSMOGONIA"

**Required changes**:
- These references are generic enough to remain valid. KOSMOGONIA is still the constitutional root, still has The Five Archai.
- **However**: If CLAUDE.md references specific V11 requirements anywhere in its "Principles" or "Theoria" sections, update those. The theoria T1-T11 may reference "requirements" — check and update if so.
- Verify no reference to "five patterns" (now six)

### 4. `CONTRIBUTING.md`

**References found**:
- Lines 93-97: "Visibility = Reachability" and "Authenticity = Provenance" stated as principles
- Lines 97-103: "Everything is composed. Nothing arises raw" as "the fundamental law"
- Line 109: "For the constitutional root, see genesis/KOSMOGONIA.md"

**Required changes**:
- Pillar references (Visibility = Reachability, Authenticity = Provenance) — still valid, no change
- "Everything is composed. Nothing arises raw" — still valid (Axiom I)
- Consider adding brief mention of the five axioms alongside pillar references
- The "fundamental law" framing is still correct — Axiom I is the composition axiom

### 5. `genesis/klimax/5-soma/DESIGN.md`

**References found**:
- ~Line 242: "Composition Requirement" in constitutional alignment table
- ~Line 249: "Dwelling Requirement" in constitutional alignment table

**Required changes**:
- "Composition Requirement" → "Axiom I: Composition"
- "Dwelling Requirement" → "Axiom II: Authority" (or describe the specific axiom content that applies to soma)

### 6. `genesis/klimax/3-polis/DESIGN.md`

**References found**:
- Line 39: "Visibility = Reachability" section header
- Line 52-62: Quotes "From KOSMOGONIA.md:" for Dwelling Requirement
- Lines 245-254: Constitution alignment table referencing all four V11 concepts

**Required changes**:
- Pillar references (Visibility, Authenticity) — still valid
- "Dwelling Requirement" quotes → update to reference Axiom II: Authority
- Constitution alignment table: update requirement names to axiom names

### 7. `genesis/klimax/nous/DESIGN.md`

**References found**:
- Lines 230-239: Constitution alignment section with Visibility, Authenticity, Composition Requirement, Dwelling Requirement

**Required changes**:
- Same pattern as polis and soma: update requirement names to axiom names
- Consider adding Traceability (Axiom III) and Adequacy (Axiom V) as relevant to nous (inference provenance)

### 8. `genesis/dynamis/DESIGN.md`

**References found**:
- Line 28: "Per KOSMOGONIA's **Actuation = Emission** pillar"

**Required changes**:
- Verify: V12 pillar is "Actuation = Reconciliation" (same as V11). "Actuation = Emission" appears to be a pre-existing misquotation. Fix to "Actuation = Reconciliation".

### 9. `genesis/hypostasis/DESIGN.md`

**References found**:
- Line 450: "Two Pillars of Kosmos Security"
- Lines 460-464: Visibility = Reachability, Authenticity = Provenance

**Required changes**:
- Pillar names are still valid — no change needed
- "Two Pillars" framing is fine since these are still pillars in V12
- Consider noting that these pillars now protect the Traceability axiom

### 10. `genesis/stoicheia-portable/DESIGN.md`

**References found**:
- Lines 599-612: "Constitutional Alignment" section referencing "Composition Requirement"

**Required changes**:
- "Composition Requirement" → "Axiom I: Composition"

### 11. `docs/reference/reactivity/actualization-pattern.md`

**References found**:
- Line 541: Traces to "KOSMOGONIA Two Modes of Being" and specific theoria

**Required changes**:
- "Two Modes of Being" is unchanged in V12 — no update needed
- Theoria references (T3, T5, T8, T11) are in CLAUDE.md, not KOSMOGONIA — no update needed

### 12. `genesis/demiurge/DESIGN.md`

**References found**:
- Lines 851-859: Anti-pattern detection referencing KOSMOGONIA principles

**Required changes**:
- Review anti-pattern list for any V11-specific terminology. Update if found.

---

## Phase 2: New Reference Docs

After alignment, write two new reference documents that specify the mechanism serving the axioms:

### `docs/reference/provenance/provenance-mechanism.md`

**Purpose**: Specify how axioms III (Traceability), IV (Self-Grounding), and V (Adequacy) are realized.

**Contents**:
- The five provenance bonds (typed-by, composed-from, authorized-by, depends-on, arises-in)
- When each bond is constitutive (the existential test)
- The self-grounding boundary (which entities constitute provenance infrastructure)
- The provenance depth gradient (how it maps to the klimax)
- Current implementation status (which bonds are implemented, which are prescribed)

### `docs/reference/provenance/authority-mechanism.md`

**Purpose**: Specify how Axiom II (Authority) is realized.

**Contents**:
- The authorization chain (prosopon → governance → action → entity)
- How daemons derive authority from oikos governance
- How agents derive authority from prosopon delegation
- How ambient infrastructure derives authority from governance configuration
- Current implementation status (session entity, MCP authentication, authorization bonds)

---

## Phase 3: REGISTRY.md Update

After all changes, update `docs/REGISTRY.md`:
- Add new docs from Phase 2 to the inventory
- Update verification dates on modified docs
- Update impact map entries if needed

---

## Verification

After each phase:
1. Grep for remaining "Composition Requirement", "Dwelling Requirement", "Authenticity Requirement" references outside of archive/ and chora-dev/ prompts
2. Grep for "five patterns" (should be "six patterns" in any doc that counts them)
3. Confirm all KOSMOGONIA links still resolve
4. Read each modified file to verify coherence — don't just search-and-replace, ensure the surrounding context still makes sense with the new terminology

---

## Out of scope

- **chora-dev prompts**: Historical records of executed work. Do NOT update. They document what was done at the time.
- **archive/ files**: Historical. Do NOT update.
- **V11-MIGRATION-PROMPT.md**: V11-era document. Mark as historical if needed, do not rewrite.
- **Code changes**: This prompt covers documentation only. Code alignment is a separate phase.
