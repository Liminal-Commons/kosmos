# Diataxis Knowledge Layer — Reference and Explanation

*Prompt for Claude Code in the chora + kosmos repository context.*

*The diataxis documentation structure exists. 100+ docs are organized across tutorials, how-to guides, explanations, and reference. But several recent implementation arcs (Reactive Loop, Mode-Absorbed Iteration, Generative Proof) changed the system significantly. This prompt audits, extends, and aligns the reference and explanation docs with reality — and restructures directory layout so each cluster is apprehensible at a glance.*

---

## Methodology — Doc-Driven Development

Docs are **prescriptive** — they describe the state we want, not the state we have. When code doesn't match a doc, the code has a gap, not the doc (unless the target changed). This is DDD: docs drive the system toward the desired state.

The audit cycle:

1. **Read the doc**: What state does it prescribe?
2. **Is that the state we want?** Does it describe the right target — or an outmoded one (dissolved patterns, stale vocabulary, superseded architecture)?
3. **Fix the doc if the target is wrong**: If the doc prescribes an outmoded state, update it to prescribe the **desired** state. This is the critical step — we must never let docs describe what we've moved past.
4. **Check the system against the doc**: Now that the doc describes the right target, does the system match? Gaps are in the system, not the doc.
5. **Fix the system where feasible**: If the gap is small, fix the code to match the doc. If the gap is large, mark the doc as prescriptive and note the gap explicitly — the doc still leads.

### What "Reference" and "Explanation" Mean (Diataxis)

**Reference** = information-oriented. Describes what things ARE. A developer looks something up. Dry, accurate, complete. Like a dictionary or API spec. Organized by topic, not by task.

**Explanation** = understanding-oriented. Explains WHY things work the way they do. Helps a developer build mental models. Discursive, contextual, can express opinion. Not task-oriented.

Neither teaches (that's tutorials) nor guides through a task (that's how-to).

---

## Context — The Three-Level Conceptual Model

Recent work has clarified a conceptual model that the docs should reflect:

### Level 1: Constituent Elements (Atoms)

The building blocks of a topos. Each is an entity type (eidos) introduced by a specific topos:

| Element | Introduced By | What It Is |
|---------|--------------|------------|
| eidos | arche | Entity type definition |
| desmos | arche | Bond type definition |
| stoicheion | arche | Step type (interpreter primitive) |
| praxis | arche | Executable procedure |
| render-spec | thyra | Declarative widget tree |
| mode | thyra | Topos spatial presence |
| trigger | ergon | Mutation event pattern |
| reflex | ergon | Autonomic response |
| reconciler | dynamis | Declarative drift rules |
| actuality-mode | dynamis | Substrate bridge |
| typos | demiurge | Composition mold |
| theoria | nous | Crystallized understanding |

### Level 2: Composite Patterns (Molecules)

Recurring compositions of constituent elements that achieve a user-meaningful purpose:

| Pattern | Elements Composed | What It Achieves |
|---------|------------------|-----------------|
| Presentation pair | render-spec + mode + uses-render-spec bond | Entity becomes visible in thyra |
| Detection pair | trigger + reflex + triggered-by bond + responds-with bond | Entity changes trigger actions |
| Reconciliation cycle | trigger + reflex + reconciler + actuality-mode + bonds | Entity self-heals via sense→compare→act |
| Authorization graph | attainment + grants-praxis bonds + requires-attainment bonds | Access control is graph-traversable |
| Generation pipeline | typos-inference-* + generate-* praxis + governed-inference | Definitions produced from intent |

### Level 3: The Generative Spiral (Factory)

The mechanism by which the kosmos produces constituent elements and composite patterns. Users don't interact with "the spiral" — they invoke generation praxeis or follow topos development workflows. The spiral is the architectural explanation of why it works.

---

## Directory Restructuring — The Organizing Logic

**Problem**: Flat directories with 15-24 files are hard to apprehend at a glance. A developer opening `reference/` sees an undifferentiated list.

**Principle**: Concern domains as subdirectories within each diataxis quadrant. No directory has more than ~5-7 files. The topoi already ARE concern domains — let the directory structure mirror that.

### Target: reference/

```
reference/
├── elements/                  Cross-cutting element catalogs
│   ├── constituent-elements.md    (NEW — the atom catalog)
│   ├── composite-patterns.md      (NEW — the molecule catalog)
│   └── stoicheia-wasm.md          (from flat)
│
├── genesis/                   Genesis structure and bootstrap
│   ├── directory-conventions.md   (already here)
│   ├── manifest-schema.md         (already here)
│   ├── bootstrap-genesis.md       (from flat)
│   ├── manifest-validation.md     (from flat)
│   └── validation-enforcement.md  (from flat)
│
├── composition/               Composition pipeline and templates
│   ├── typos-composition.md       (from flat)
│   ├── composition.md             (from flat)
│   └── expression-evaluator.md    (from flat)
│
├── presentation/              Thyra modes, render-specs, widgets
│   ├── mode-reference.md          (from flat)
│   ├── render-spec-resolution.md  (from flat)
│   ├── widget-system.md           (from flat)
│   └── render-spec-authoring.md   (from genesis/demiurge/RENDER-SPEC-GUIDE.md)
│
├── reactivity/                Reactive system and reconciliation
│   ├── reactive-system-reference.md (from flat)
│   ├── reconciliation.md          (from flat)
│   └── daemon-runner.md           (from flat)
│
├── authorization/             Identity, access, and contracts
│   ├── attainment-authorization.md (from flat)
│   ├── session-identity.md        (from flat)
│   └── surface-contracts.md       (from flat)
│
├── infrastructure/            APIs, clients, substrates, crypto
│   ├── rest-api.md                (from flat)
│   ├── soma-client.md             (from flat)
│   ├── substrate-lifecycle.md     (from flat)
│   └── cryptographic-operations.md (from flat)
│
├── generation/                Generation praxeis and inference
│   └── generation.md              (NEW — generation capability reference)
│
├── domain/                    Topos-specific entity references
│   ├── phasis-entity.md           (from flat)
│   ├── phasis-workspace.md        (from flat)
│   └── oikos-map.md               (from flat)
│
└── query-system.md            Cross-cutting (keep at root — used by everyone)
```

Notes:
- `reference/oikos/` (1 file: index.md) absorbed into `domain/`
- Empty subdirs (`eide/`, `praxeis/`, `stoicheia/`) deleted — their content lives in `elements/`
- `query-system.md` stays at root — it's cross-cutting, referenced everywhere

### Target: explanation/

```
explanation/
├── architecture/              System-wide concepts
│   ├── architecture.md            (from flat)
│   ├── homoiconic-reactive-architecture.md (from flat)
│   ├── entity-as-source-of-truth.md (from flat)
│   ├── commitment-boundary.md     (from flat)
│   └── two-phase-bindings.md      (from flat)
│
├── presentation/              Thyra, modes, and visibility
│   ├── modes-and-oikos.md         (from flat)
│   ├── modes-as-oikoi.md          (from flat)
│   ├── thyra-oikos.md             (from flat)
│   ├── artifact-based-modes.md    (from flat)
│   └── entity-overlays.md         (from flat)
│
├── reactivity/                Reactive system and reconciliation
│   ├── reactive-system.md         (from flat)
│   └── reconciler-pattern.md      (from flat)
│
├── composition/               Composition and creative patterns
│   ├── clarification-as-composition.md (from flat)
│   └── creative-journey-pattern.md (from flat)
│
├── genesis/                   Genesis concepts (already exists)
│   ├── archai.md                  (already here)
│   ├── bootstrap.md               (already here)
│   ├── oikoi.md                   (already here)
│   └── index.md                   (already here)
│
├── generation/                Generative spiral and schema
│   ├── generative-spiral.md       (NEW — the factory explained)
│   └── schema-enforcement.md      (NEW — T9 explained)
│
├── federation.md              Cross-cutting (keep at root)
├── klimax/                    (keep — expected to grow)
│   └── index.md
└── oikos/                     (keep — expected to grow)
    └── index.md
```

### Target: tutorial/ and how-to/

These restructurings are specified in the companion prompt `PROMPT-DIATAXIS-EXPERIENCE.md`.

---

## Gap Analysis

### What may prescribe an outmoded state

These docs existed before recent arcs and may still prescribe patterns we've moved past:

| Doc | Risk | Recent Arc That Changed Things |
|-----|------|-------------------------------|
| `mode-reference.md` | May describe pre-Mode-Absorbed world (panels, renderers) | Mode-Absorbed Iteration |
| `widget-system.md` | May reference dissolved for-each/include widgets | Mode-Absorbed Iteration |
| `reactive-system-reference.md` | May not reflect generic reconciler or schema-driven dispatch | Reactive Loop |
| `reconciliation.md` | May not reflect `host.reconcile()` or `resolve_actuality_mode()` | Reactive Loop |
| `attainment-authorization.md` | May not reflect grants-praxis bonds or REST bond fix | Attainment Authorization |
| `explanation/reactive-system.md` | May not reflect completed reactive loop | Reactive Loop |
| `explanation/architecture.md` | May not reflect mode-absorbed architecture | Mode-Absorbed Iteration |

### What doesn't exist but should

| Doc | Target Location | Why It's Needed |
|-----|----------------|----------------|
| Constituent Element Types | `reference/elements/constituent-elements.md` | Cross-cutting catalog of all 12 types, their eide, their topoi |
| Composite Patterns | `reference/elements/composite-patterns.md` | Named patterns (reconciliation cycle, presentation pair, etc.) |
| Generation Reference | `reference/generation/generation.md` | generate-*, validate-*, actualize-* — what exists, what each does |
| The Generative Spiral | `explanation/generation/generative-spiral.md` | Why kosmos generates itself, the three levels, theoria accumulation |
| Schema Enforcement | `explanation/generation/schema-enforcement.md` | T9: why output_schema > prompt instructions |

### What exists but is misplaced

| Doc | Current Location | Target |
|-----|-----------------|--------|
| RENDER-SPEC-GUIDE.md | genesis/demiurge/ | `reference/presentation/render-spec-authoring.md` |
| THYRA-AWARENESS.md | genesis/demiurge/ | `docs/design/render-spec-generation.md` |
| REACTIVE-SYSTEM-PLAN.md | project root | `archive/` |

---

## Implementation Order

### Phase 0: Directory Restructuring

Restructure `reference/` and `explanation/` into concern-domain subdirectories as specified above.

1. Create all target subdirectories
2. Move each file to its target location (git mv to preserve history)
3. Update all internal cross-references (grep for old paths, update to new)
4. Update `docs/index.md` to reflect new structure
5. Update `docs/REGISTRY.md` to reflect new paths
6. Verify no broken links remain

**Do NOT change file content in this phase** — only move files and update references. Content changes come in later phases.

### Phase 1: Audit Existing Reference Docs

Read every doc now in `reference/` (in its new location). For each, apply the DDD audit cycle:

1. **Does it prescribe the right target?** Does it describe the state we want — or an outmoded one? (Dissolved patterns like panels, renderers, for-each widget are outmoded. Missing coverage of reconcilers, generation, mode-absorbed patterns is a gap.)
2. **Does the system match the doc?** Where the doc prescribes the right target, does the code implement it?
3. **Is it complete?** Does it cover recent capabilities that should be part of the desired state?
4. **Status**: mark as CURRENT (prescribes right target, system matches), OUTMODED (prescribes wrong target — needs doc rewrite), GAP (prescribes right target but system doesn't match), or INCOMPLETE (right target but missing coverage)

Update REGISTRY.md with current status for each doc.

**Priority files to audit** (most likely stale):
- `reference/presentation/mode-reference.md`
- `reference/presentation/widget-system.md`
- `reference/reactivity/reactive-system-reference.md`
- `reference/reactivity/reconciliation.md`
- `reference/authorization/attainment-authorization.md`

### Phase 2: Fix Outmoded and Incomplete Reference Docs

For each doc marked OUTMODED or INCOMPLETE in Phase 1:

1. Determine the **desired state** — what should this doc prescribe? (Read completed prompt docs, current genesis, and code to understand what we want.)
2. Rewrite the doc to prescribe the desired state
3. Remove all references to dissolved/superseded patterns (these are outmoded — they should not appear even as historical context)
4. Add coverage of capabilities that should be part of the desired state
5. Check the system against the rewritten doc — note any gaps where the system doesn't yet match

For docs marked GAP: the doc is right, the system is wrong. Fix the system where feasible; mark remaining gaps explicitly in the doc.

This is the bulk of the work. Each doc is a self-contained update.

### Phase 3: Write New Reference Docs

Create the cross-cutting reference docs that don't exist:

**`reference/elements/constituent-elements.md`** — The atom catalog
- Lists all 12 constituent element types
- For each: which topos introduces it, its eidos schema, where instances live in genesis, how many exist across all topoi
- Cross-references to topos-specific reference docs
- Notes which element types have generation support (generate-*) and which don't

**`reference/elements/composite-patterns.md`** — The molecule catalog
- Names and describes each composite pattern
- For each: what elements compose it, what bonds connect them, what the result achieves
- Example from genesis for each pattern
- Notes which patterns have composite generation support

**`reference/generation/generation.md`** — Generation capability reference
- Lists all generation praxeis (generate-eidos, generate-praxis, generate-desmos, generate-render-spec)
- Lists all inference contexts (typos-inference-*)
- Describes the generation pipeline: compose context → governed-inference → validate → actualize
- Notes which element types are covered and which aren't
- References T9 (schema enforcement) and T10 (integration testing)

### Phase 4: Audit and Fix Explanation Docs

Same DDD audit cycle as Phases 1-2 for `explanation/`:
1. Read each explanation doc — does it explain the architecture we want, or an outmoded one?
2. For outmoded docs: rewrite to explain the desired architecture
3. For gaps: the explanation is right but the system doesn't match — note explicitly
4. Write new explanation docs:

**`explanation/generation/generative-spiral.md`** — The factory explained
- Three levels: atoms, molecules, factory
- Why kosmos generates itself (not just "we can" — why it's necessary)
- How theoria accumulation works
- The constitutional exception (what bootstraps can't go through the spiral)
- References T9, T10

**`explanation/generation/schema-enforcement.md`** — T9 explained
- Why output_schema via tool_use is more reliable than prompt instructions
- Empirical evidence from the generative proof
- Implications for future generation work

### Phase 5: Relocate Misplaced Docs

Move docs to their diataxis-appropriate locations:
1. `genesis/demiurge/RENDER-SPEC-GUIDE.md` → `reference/presentation/render-spec-authoring.md`
2. `genesis/demiurge/THYRA-AWARENESS.md` → `docs/design/render-spec-generation.md`
3. `REACTIVE-SYSTEM-PLAN.md` → `archive/`
4. Update all internal links and REGISTRY.md
5. Clean up empty subdirs in `reference/` (`eide/`, `praxeis/`, `stoicheia/`, `oikos/`)

### Phase 6: Update REGISTRY.md and Index

1. REGISTRY.md: update all paths to reflect new directory structure
2. REGISTRY.md: add new docs to impact map
3. `docs/index.md`: rewrite to reflect concern-domain organization
4. Verify all cross-references resolve
5. Mark every doc with last-verified date

---

## Files to Read

### Existing docs (audit targets)
- `docs/index.md` — current entry point
- `docs/REGISTRY.md` — impact map
- All files in `docs/reference/` (flat + subdirs)
- All files in `docs/explanation/` (flat + subdirs)

### Current reality (verify against)
- `crates/kosmos/src/host.rs` — reconcile(), resolve_actuality_mode()
- `app/src/lib/layout-engine.tsx` — mode system (singleton, collection, compound)
- `app/src/lib/render-spec.tsx` — widget dispatch (no hardcoded widget names)
- `genesis/demiurge/praxeis/render-spec-generation.yaml` — generation praxeis
- `genesis/demiurge/typos/thyra-generation.yaml` — inference context

### Prompt docs (completed work to reference)
- `genesis/chora-dev/PROMPT-REACTIVE-LOOP.md` — reactive loop findings
- `genesis/chora-dev/PROMPT-MODE-ABSORBED-ITERATION.md` — mode system changes
- `genesis/chora-dev/PROMPT-GENERATIVE-PROOF.md` — generation findings, T9, T10
- `genesis/chora-dev/PROMPT-ATTAINMENT-AUTHORIZATION.md` — authorization changes

---

## Success Criteria

**Phase 0 Complete When:**
- [ ] All files in `reference/` moved to concern-domain subdirectories
- [ ] All files in `explanation/` moved to concern-domain subdirectories
- [ ] Empty legacy subdirs (`reference/eide/`, `reference/praxeis/`, `reference/stoicheia/`) removed
- [ ] `docs/index.md` updated with new paths
- [ ] `docs/REGISTRY.md` updated with new paths
- [ ] No broken cross-references (grep for old paths returns zero)

**Phase 1-2 Complete When:**
- [ ] Every doc in `reference/` has been audited against the DDD cycle
- [ ] Every doc prescribes the desired state (no outmoded patterns remain)
- [ ] No reference doc mentions dissolved patterns (panels, renderers, for-each widget, render-type)
- [ ] System gaps identified and either fixed or marked as prescriptive
- [ ] REGISTRY.md status column is current for all reference docs

**Phase 3 Complete When:**
- [ ] `reference/elements/constituent-elements.md` exists, lists all 12 types with schemas
- [ ] `reference/elements/composite-patterns.md` exists, names all patterns with examples
- [ ] `reference/generation/generation.md` exists, covers all generation praxeis and contexts

**Phase 4 Complete When:**
- [ ] Every doc in `explanation/` has been audited
- [ ] `explanation/generation/generative-spiral.md` exists, explains three levels
- [ ] `explanation/generation/schema-enforcement.md` exists, explains T9

**Phase 5-6 Complete When:**
- [ ] RENDER-SPEC-GUIDE.md relocated to `reference/presentation/`
- [ ] REACTIVE-SYSTEM-PLAN.md archived
- [ ] REGISTRY.md updated with all new docs and paths
- [ ] `docs/index.md` reflects concern-domain organization
- [ ] All cross-references resolve

**Overall Complete When:**
- [ ] A developer opening any `reference/` subdirectory sees ≤7 files in a coherent concern cluster
- [ ] A developer opening any `explanation/` subdirectory sees ≤7 files in a coherent concern cluster
- [ ] A developer can look up any kosmos concept in `reference/` and find accurate information
- [ ] A developer can understand any kosmos architectural decision in `explanation/`
- [ ] No documentation references superseded patterns
- [ ] The three-level model (atoms, molecules, factory) is reflected in documentation organization

---

*Reference and explanation are the knowledge layer. They don't teach or guide — they inform and illuminate. When this layer is accurate, the experience layer (tutorials, how-to guides) has a solid foundation to build on.*
