# Genesis Restructure Proposal

*Aligning genesis folders with klimax levels, three pillars, and generative flow*

**Status:** DRAFT

---

## Core Vision

### The Generative Principle

**Genesis is composed, then emitted.**

All content — including bootstrap content — flows through the three-pillar compositional framework. What varies is the **fill method**, not the compositional law:

| Fill Method | Use Case | Example |
|-------------|----------|---------|
| **literal** | Bootstrap, constants | Archai definitions |
| **computed** | Derived values | Timestamps, counts |
| **queried** | Entity data | Field definitions from eidos |
| **generated** | LLM inference | Usage summaries |
| **composed** | Nested artifacts | Sections from subsections |

The canonical flow:
```
schema (eidos) → composition (demiurge) → emission (thyra) → genesis content
```

Bootstrap uses literal fill methods. The mature kosmos uses queried, computed, and generated fills. Both paths are compositional — the three pillars apply universally.

The three pillars apply universally:
- **Schema-driven**: Eide define what can exist. Composition validates against schema.
- **Graph-driven**: Bonds define relationships. The graph IS the access control.
- **Cache-driven**: Content-addressed. Same inputs = same hash = same artifact.

### The Topos Duality

"Topos" intentionally carries two meanings:

| Meaning | Greek Sense | Technical Sense |
|---------|-------------|-----------------|
| **Dwelling** | House, household | Where capability dwells |
| **Package** | Domain, estate | Deliverable unit with manifest |

These are not confusion — they are unified. A domain package IS a dwelling place for capability. When you install a topos, you're creating a place where those capabilities can dwell.

### What Is and Isn't an Topos

| Category | Examples | Packageable? | Why |
|----------|----------|--------------|-----|
| **Archai** | eidos, desmos, stoicheion | No | Pre-topos, constitutional grammar |
| **Klimax levels** | The 6 scales themselves | No | Constitutional structure |
| **Domain packages** | politeia, nous, thyra | Yes | Capability that can dwell |
| **Seeds** | spora content | No | Bootstrap, becomes archai |

**Principle**: Archai and klimax are constitutional — they define what topoi CAN be. They are not themselves topoi.

---

## Current State Analysis

### Observed Structure

The current genesis folder has **duplication** between two organizational approaches:

| Approach | Location | Purpose |
|----------|----------|---------|
| **Klimax folders** | `klimax/1-kosmos/` through `klimax/6-psyche/` | Design documents with consolidated YAML |
| **Topos folders** | `politeia/`, `thyra/`, `nous/`, etc. | Loaded by MCP server, split into subdirs |

**Key observations:**

1. `klimax/3-polis/polis.yaml` (500 lines) vs `politeia/` (2117 lines) — the topos folder is more developed
2. The klimax folders appear to be an earlier design attempt, now superseded
3. Form definitions live in `thyra/definitions/forms.yaml` but target multiple topoi
4. Naming is inconsistent: klimax uses Greek (polis), topos uses Greek (politeia) — but they're different words

### Current Topoi (Domain Packages)

| Topos | Klimax Alignment | Purpose |
|-------|------------------|---------|
| arche | 1-kosmos | Foundational archai (eidos, desmos, stoicheion) |
| politeia | 3-polis | Governance, oikoi, attainments |
| soma | 5-soma | Embodiment, channels, parousia lifecycle |
| psyche | 6-psyche | Intentions, attention, mood |
| nous | Cross-cutting | Knowledge operations, theoria, journeys |
| thyra | Cross-cutting | Interface, rendering, phaseis |
| demiurge | Meta-level | Composition, caching |
| dynamis | 1-kosmos | Substrate capabilities, deployment |
| hypostasis | Cross-cutting | Identity, cryptography, backup |
| propylon | 3-polis | Entry, invitations |
| oikos | 4-oikos | Intimate dwelling (sessions, notes) |
| manteia | Cross-cutting | Inference, generation |
| dokimasia | Cross-cutting | Validation, provenance |
| aither | Cross-cutting | WebRTC, P2P communication |
| spora | Bootstrap | Genesis germination |

---

## The Problem

### 1. Duplication Creates Confusion

The existence of both `klimax/` and top-level topos folders creates ambiguity about what's canonical.

### 2. Forms Misplaced

`thyra/definitions/forms.yaml` contains:
- **Onboarding forms** → should be in `hypostasis/` (identity)
- **Invitation forms** → should be in `propylon/` (entry)
- **Oikos forms** → should be in `politeia/` (governance)

This violates **graph-driven** principle: forms compose entities of specific eide, so they should live with the topos that owns that eidos.

### 3. Naming Inconsistency

| Klimax Level | Greek | Current Topos | Confusion |
|--------------|-------|---------------|-----------|
| 3-polis | πόλις | politeia | Different words (polis = city-state, politeia = constitution) |
| 4-oikos | οἶκος | oikos | Now "topos" for package, "oikos" for dwelling |

---

## The Generative Flow

### How Genesis Content Should Be Created

**Phase 0 (Bootstrap)**: Hand-write minimal archai to enable composition
```
phasis/genesis-root → eidos/eidos → eidos/desmos → eidos/stoicheion
                       → eidos/artifact-definition → eidos/praxis
```

**Phase 1 (Composition)**: Use kosmos to compose definitions
```rust
// Instead of writing YAML by hand:
kosmos.compose("artifact-definition/theoria-form", {
  target_eidos: "theoria",
  slots: { insight: { type: "string", required: true }, ... }
})
```

**Phase 2 (Emission)**: Emit composed content to filesystem
```rust
// thyra/emit writes kosmos content to genesis/
kosmos.invoke("thyra/emit", {
  entity_id: "artifact-definition/theoria-form",
  path: "genesis/nous/definitions/forms.yaml",
  format: "yaml"
})
```

**Phase 3 (Distribution)**: Package topoi for distribution
```rust
// Create topos-dev, bake to topos-prod, sign
kosmos.invoke("demiurge/publish-topos", {
  topos_dev_id: "topos-dev/nous-1.0.0",
  ...
})
```

### What This Means for Genesis Structure

```
genesis/
├── KOSMOGONIA.md           # Constitutional root (human-authored, signed)
├── arche/                  # Pre-topos archai (minimal bootstrap)
│   ├── eidos.yaml         # Hand-written: eidos, desmos, stoicheion, etc.
│   ├── desmos.yaml        # Hand-written: foundational bonds
│   └── stoicheion.yaml    # Hand-written: step type schemas
│
├── spora/                  # Bootstrap seed (hand-written)
│   └── spora.yaml         # Germination stages
│
├── klimax/                 # Constitutional structure (documentation)
│   ├── 1-kosmos/DESIGN.md # What kosmos level IS
│   ├── 2-physis/DESIGN.md # What physis level IS
│   └── ...                # (not loadable content, just design)
│
└── [topoi]/               # Domain packages (EMITTED, not hand-written)
    ├── nous/
    │   ├── manifest.yaml      # Declares what nous provides
    │   ├── eide/nous.yaml     # EMITTED from kosmos
    │   ├── desmoi/nous.yaml   # EMITTED from kosmos
    │   ├── praxeis/nous.yaml  # EMITTED from kosmos
    │   └── definitions/       # EMITTED from kosmos
    ├── politeia/
    ├── thyra/
    └── ...
```

### The Bootstrap Problem

**Problem**: How do we compose content before full composition capability exists?

**Solution**: Staged bootstrap with literal fill methods, transitioning to richer fills:

| Stage | Fill Methods Used | What Gets Composed |
|-------|-------------------|-------------------|
| 0 | literal only | archai (eidos, desmos, stoicheion) |
| 1 | literal + computed | spora, demiurge praxeis, foundational eide |
| 2 | literal + computed + queried | topos definitions, thyra/emit praxis |
| 3 | all fill methods | everything else (including generated) |

Each stage expands the available fill methods. Even stage 0 is compositional — it validates against eidos/eidos, bonds to genesis, and is content-addressed. The difference is that literal slots don't query entities or invoke inference.

Eventually, mature composition uses all fill methods. Bootstrap content can be re-emitted with richer fills if desired.

---

## Proposed Restructure

### Guiding Principles

1. **Archai are constitutional** — hand-written, signed, minimal
2. **Klimax is structure** — design documentation, not loadable content
3. **Topoi are packages** — emitted from kosmos, distributable
4. **Generation is canonical** — compose → emit → commit

### Phase 1: Establish Generative Infrastructure

Before restructuring content, ensure the generation pipeline works:

**1a. Verify emission capability**
```bash
# Test thyra/emit praxis works
kosmos invoke thyra/emit --entity-id artifact-definition/test --path /tmp/test.yaml
```

**1b. Create topos emission praxis**
```yaml
# praxis/demiurge/emit-topos
# Emits all entities belonging to a topos to their canonical locations
steps:
  - type: gather
    eidos: [eidos, desmos, praxis, artifact-definition]
    filter: "belongs-to topos/{{ topos_id }}"
    bind_to: entities
  - type: for_each
    items: "{{ entities }}"
    do:
      - type: invoke
        praxis: thyra/emit
        inputs:
          entity_id: "{{ item.id }}"
          path: "genesis/{{ topos_id }}/{{ item.eidos }}/{{ item.id }}.yaml"
```

**1c. Test round-trip**
- Compose an entity via kosmos
- Emit to YAML
- Delete from kosmos
- Reload from YAML
- Verify identical

### Phase 2: Document Constitutional Structure

Update KOSMOGONIA.md with clear distinction:

```markdown
## Archai, Klimax, and Topoi

### The Three Categories

| Category | Nature | Location | Authored By |
|----------|--------|----------|-------------|
| **Archai** | Constitutional grammar | `genesis/arche/` | Human (signed) |
| **Klimax** | Constitutional structure | `genesis/klimax/` | Human (DESIGN.md) |
| **Topoi** | Domain packages | `genesis/[topos]/` | Kosmos (emitted) |

### Archai — What CAN Exist

Archai define the grammar of existence:
- eidos, desmos, stoicheion (foundational forms)
- artifact-definition, praxis (composition capability)

These are pre-topos. They must be hand-written because composition
capability doesn't exist until they exist.

### Klimax — How Existence Organizes

The klimax describes six scales. Each scale provides ambient context
for the next:

| Scale | Greek | What It Provides |
|-------|-------|------------------|
| 1-kosmos | κόσμος | Substrate — entities and bonds |
| 2-physis | φύσις | Constraints — stoicheia and schemas |
| 3-polis | πόλις | Governance — oikoi and visibility |
| 4-oikos | οἶκος | Intimacy — dwelling and sessions |
| 5-soma | σῶμα | Embodiment — channels and streams |
| 6-psyche | ψυχή | Experience — intentions and attention |

Klimax levels are not themselves packages. `genesis/klimax/` contains
DESIGN.md files only — documentation of what each level IS.

### Topoi — Where Capability Dwells

Topoi are domain packages. The duality is intentional:
- **Dwelling**: A place where capability lives
- **Package**: A distributable unit with manifest

| Klimax Alignment | Topos | What It Provides |
|------------------|-------|------------------|
| 1-kosmos | dynamis | Substrate capabilities |
| 2-physis | stoicheia-portable | Portable operations |
| 3-polis | politeia, propylon | Governance, entry |
| 4-oikos | oikos | Dwelling, sessions |
| 5-soma | soma | Embodiment, channels |
| 6-psyche | psyche | Experience, intentions |

Cross-cutting topoi serve multiple scales:
- nous, thyra, demiurge, manteia, hypostasis, dokimasia, aither

**Topos content is EMITTED from kosmos.** When mature, we:
1. Compose definitions via demiurge
2. Emit to genesis/ via thyra
3. Commit to git
4. Bootstrap loads emitted content
```

### Phase 3: Migrate Content to Correct Topoi

Move artifact-definitions to their owning topoi:

| Definition | Target Eidos | Move From | Move To |
|------------|--------------|-----------|---------|
| mnemonic-entry-form | form-submission | thyra/definitions/ | hypostasis/definitions/ |
| mnemonic-confirm-form | form-submission | thyra/definitions/ | hypostasis/definitions/ |
| prosopon-name-form | form-submission | thyra/definitions/ | hypostasis/definitions/ |
| invitation-form | propylon-link | thyra/definitions/ | propylon/definitions/ |
| accept-invitation-form | propylon-session | thyra/definitions/ | propylon/definitions/ |
| create-oikos-form | oikos | thyra/definitions/ | politeia/definitions/ |

**After migration, emit these via kosmos** to establish the generative pattern.

### Phase 4: Clean Up Klimax Duplication

The klimax/ folder currently has both DESIGN.md and .yaml files:

**Current state:**
```
klimax/3-polis/
├── DESIGN.md        # Valuable — keep
├── manifest.yaml    # Duplicate — remove
└── polis.yaml       # Duplicate — remove
```

**Target state:**
```
klimax/3-polis/
└── DESIGN.md        # Constitutional documentation only
```

The .yaml content lives in `politeia/` (the topos). Remove duplicates from klimax/.

### Phase 5: Establish Emission Workflow

Once infrastructure works, establish the workflow:

**For new content:**
```bash
# 1. Compose via kosmos
kosmos compose artifact-definition/new-form --target-eidos theoria ...

# 2. Emit to genesis
kosmos invoke thyra/emit --entity-id artifact-definition/new-form \
  --path genesis/nous/definitions/forms.yaml

# 3. Commit
git add genesis/nous/definitions/forms.yaml
git commit -m "feat(nous): Add theoria form definition

Composed and emitted via kosmos."
```

**For existing content (eventual):**
```bash
# Re-emit topos to sync hand-written with composed
kosmos invoke demiurge/emit-topos --topos-id nous
git diff genesis/nous/  # Review changes
git commit -m "chore(nous): Sync emitted content"
```

### Phase 6: Praxis Exposure Model

Add `exposure` field to praxis eidos to classify capability surface:

```yaml
# Addition to eidos/praxis in arche/eidos.yaml
exposure:
  type: enum
  values: [ambient, affordance, internal, developer]
  default: affordance
  description: |
    Controls how this praxis surfaces:
    - ambient: Always available to dwellers (find, surface, traverse)
    - affordance: Available via attainment grant
    - internal: System-only, invoked by other praxeis, not exposed as tool
    - developer: Dev/debug mode only
```

**Classification of existing praxeis:**

| Exposure | Character | Examples |
|----------|-----------|----------|
| **ambient** | Core navigation, always available | `nous/find`, `nous/surface`, `nous/traverse` |
| **affordance** | Gated by attainment | `politeia/create-oikos`, `nous/crystallize-theoria`, `thyra/express`, `nous/begin-journey` |
| **internal** | System plumbing, not dweller-facing | `nous/gather`, `nous/index`, `demiurge/bind-dependencies`, `demiurge/mark-dependents-stale`, `thyra/reconcile-region`, `thyra/emit-render`, phylax internals |
| **developer** | Dev/debug mode | `dokimasia/validate-*`, `thyra/emit`, `demiurge/compose` (direct), bootstrap praxeis |

**Rationale for `gather` as internal:**
- `find` — precise retrieval when you know the ID
- `surface` — semantic exploration by meaning
- `traverse` — relationship navigation through bonds
- `gather` — batch/exhaustive operation, system-level (e.g., validation, emission)

Dwellers navigate via find/surface/traverse. `gather` is for system operations.

### Phase 7: MCP Surface Alignment

Modify the MCP server projection to respect praxis exposure:

1. **Filter by exposure**: Exclude `internal` praxeis from tool generation
2. **Respect dwelling context**: Only expose `affordance` praxeis the caller has attainments for
3. **Dev mode flag**: Include `developer` praxeis when `--dev` is passed to MCP server

**Impact:**
```
Before: ~130 MCP tools (all praxeis)
After:  ~40-50 MCP tools (ambient + attained affordances + developer if dev mode)
```

This aligns MCP tools with affordances — the tool surface IS the affordance surface.

**Principle emerging:** "Capability exposure follows visibility = reachability. What you can invoke is what you can reach through the bond graph."

### Phase 8: Constitutional vs. Loadable Topoi

Add `constitutional: boolean` to manifest.yaml to distinguish core from optional:

| Constitutional (always in genesis) | Loadable (oikos installs) |
|------------------------------------|----------------------------|
| demiurge (composition) | aither (P2P communication) |
| politeia (governance) | dns (domain management) |
| nous (knowledge) | pege (document emission) |
| thyra (interface) | manteia advanced features |
| dynamis (substrate) | |
| hypostasis (identity) | |
| dokimasia (validation) | |
| soma (embodiment) | |
| psyche (experience) | |
| oikos (dwelling) | |
| propylon (entry) | |
| stoicheia-portable | |

**Implementation:**
- Add `constitutional: true/false` to manifest schema
- Mark all current topoi as `constitutional: true`
- Document loading mechanism for future non-constitutional topoi
- *This phase is post-MVP — mark the field but don't implement loading yet*

---

## Three Pillars Applied to All Categories

The three pillars are not separate concerns — they are one methodology viewed from three angles. **All content** follows these pillars, regardless of category.

### How Each Pillar Applies

| Category | Schema-Driven | Graph-Driven | Cache-Driven |
|----------|---------------|--------------|--------------|
| **Archai** | `eidos/eidos` is self-grounding — validates itself | `authorized-by → phasis/genesis-root` | Content-addressed IDs include hash |
| **Klimax** | Documentation only — no schema validation | Documentation only — no bonds | Documentation only — not composed |
| **Topoi** | All entities validate against their eidos | `belongs-to → topos/[name]` bonds | `compose-cached` memoizes by hash |
| **Spora** | Validates against archai during germination | Founder bonds (member-of, stewards, dwells-in) | Provenance chains via `composed-from` |

### Schema-Driven Details

**Validation chain:**
```
eidos/eidos → validates → eidos/desmos, eidos/stoicheion, eidos/artifact-definition
           → validates → all domain eide (theoria, oikos, phasis, etc.)
                      → validates → all entity instances
```

**Build.rs pattern:** This extends to code generation. `stoicheion.yaml → build.rs → step_types.rs`. The schema IS the source of truth for generated Rust types.

**Action**: Composition automatically validates. Emission preserves validity.

### Graph-Driven Details

**Visibility = Reachability:**
```
parousia → dwells-in → oikos → visibility scope
      → member-of → oikos → membership
      → has-attainment → attainment → capability
```

**Form ownership:** Forms bond to the topos that owns their target eidos. `create-oikos-form` targets `eidos/oikos` (owned by politeia), so the form belongs in politeia.

**Action**: Form migration restores correct bond topology.

### Cache-Driven Details

**Content-addressing:**
```
entity_id = "{eidos}/{slug}@blake3:{content_hash}"
```

**Idempotency:** Same composition = same hash = same entity. Re-emission produces identical output if inputs unchanged.

**Staleness propagation:** When a schema source changes, `depends-on` bonds propagate staleness to dependent artifacts.

**Action**: Emission workflow can be repeated without drift.

---

## Migration Checklist

### Phase 1: Generative Infrastructure

- [ ] Verify `thyra/emit` praxis works
- [ ] Test entity → YAML → reload round-trip
- [ ] Create `demiurge/emit-topos` praxis (batch emission)
- [ ] Document emission workflow

### Phase 2: Documentation

- [ ] Add "Archai, Klimax, and Topoi" section to KOSMOGONIA.md
- [ ] Update CONTRIBUTING.md with generative workflow
- [ ] Add header to klimax YAML: "Design reference only"

### Phase 3: Content Migration

- [ ] Create `hypostasis/definitions/` directory
- [ ] Create `propylon/definitions/` directory
- [ ] Create `politeia/definitions/` directory
- [ ] Move onboarding forms to hypostasis
- [ ] Move invitation forms to propylon
- [ ] Move oikos form to politeia
- [ ] Update bonds (`belongs-to` → correct topos)
- [ ] Test bootstrap loads from new locations
- [ ] Test UI loads forms correctly

### Phase 4: Klimax Cleanup

- [ ] Remove duplicate YAML from klimax/
- [ ] Keep only DESIGN.md per level
- [ ] Update cross-references

### Phase 5: Establish Workflow

- [ ] Document "compose → emit → commit" flow
- [ ] Create helper scripts if needed
- [ ] Train contributors on generative approach

### Phase 6: Praxis Exposure

- [ ] Add `exposure` field to eidos/praxis in arche/eidos.yaml
- [ ] Classify all praxeis (~168) by exposure level
- [ ] Update praxis YAML files with exposure field
- [ ] Test that exposure field loads correctly

### Phase 7: MCP Surface

- [ ] Modify MCP projection to filter by exposure
- [ ] Add dwelling context to tool gathering (affordance filtering)
- [ ] Add `--dev` flag for developer praxeis
- [ ] Verify tool count reduction (~130 → ~50)
- [ ] Test that internal praxeis are not exposed as tools

### Phase 8: Constitutional vs. Loadable Topoi

- [ ] Add `constitutional` field to manifest schema
- [ ] Mark all current topoi as `constitutional: true`
- [ ] Document loading mechanism design (future)
- [ ] Identify candidate loadable topoi (aither, dns, pege)

---

## Impact Assessment

| Phase | Risk | Benefit | Dependencies |
|-------|------|---------|--------------|
| 1 (Infrastructure) | Low | Enables everything | None |
| 2 (Documentation) | None | Clarity | None |
| 3 (Migration) | Medium | Correct ownership | Phase 1 |
| 4 (Cleanup) | Low | Reduce confusion | Phase 3 |
| 5 (Workflow) | None | Sustainable process | Phase 1-4 |
| 6 (Exposure) | Low | Praxis classification | None |
| 7 (MCP Surface) | Medium | Context efficiency (~60% reduction) | Phase 6 |
| 8 (Loadable) | Low | Future extensibility | Phase 6 |

---

## Theoria Crystallized

**T12: Genesis is composed, then emitted**
All genesis content flows through the three-pillar compositional framework. Bootstrap uses literal fill methods; the mature kosmos uses queried, computed, and generated fills. The fill method varies, not the compositional law.

**T13: Topos duality is resolved**
"Oikos" originally meant both dwelling and package. V11 resolved this: "topos" is the domain package, "oikos" is the social dwelling.

**T14: Archai are pre-topos**
Eidos, desmos, stoicheion cannot be packaged — they define what packages CAN be. They are constitutional grammar.

**T15: Klimax is structure, not content**
The six scales describe organization. They are not themselves packages. `genesis/klimax/` should contain only design documentation.

**T16: Capability exposure follows visibility**
The tool surface is the affordance surface. What you can invoke is what you can reach through the bond graph. Praxeis have audiences: ambient (all dwellers), affordance (attainment-gated), internal (system-only), developer (dev mode).

**T17: Navigation triad replaces exhaustive gather**
Dwellers navigate via `find` (precise), `surface` (semantic), `traverse` (relational). `gather` is a system operation for batch/exhaustive work, not a dweller operation.

---

## Decision Required

**Approve phases in order:**

1. **Phase 1** — Build generative infrastructure (prerequisite)
2. **Phase 2** — Update documentation (parallel with 1) ✅ Complete
3. **Phase 3** — Migrate content to correct topoi
4. **Phase 4** — Clean up klimax duplication
5. **Phase 5** — Establish sustainable workflow
6. **Phase 6** — Add praxis exposure model (parallel with 1-5)
7. **Phase 7** — Align MCP surface with affordances (requires Phase 6)
8. **Phase 8** — Mark constitutional vs. loadable topoi (post-MVP)

**Recommendation**: Approve all phases.

- Phases 1-5: Core restructure (Phase 1 is critical path)
- Phases 6-7: MCP optimization (reduces context ~60%, can run parallel)
- Phase 8: Future extensibility (post-MVP, mark fields now)

---

*Proposed 2026-01-24, extended 2026-01-24*
