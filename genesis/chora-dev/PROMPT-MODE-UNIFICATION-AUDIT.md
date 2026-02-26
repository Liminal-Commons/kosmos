# Mode Unification Audit — Completeness, Consistency, and the Unknown Unknowns

*Prompt for Claude Code in the chora + kosmos repository context.*

*Audits the Mode Unification arc for completeness and consistency. Probes for things we didn't know to include — structural inconsistencies, orphaned references, semantic gaps, and alignment between what KOSMOGONIA prescribes and what the system actually does.*

---

## Purpose

Mode Unification dissolved `eidos/actuality-mode` into a unified `eidos/mode` with `substrate` field. The implementation touched genesis YAML, build.rs, layout-engine.tsx, actuality.ts, and tests. This audit ensures:

1. **No vestiges** — zero references to the retired concept
2. **Structural consistency** — unified modes follow one pattern across all topoi
3. **Semantic alignment** — what KOSMOGONIA says matches what the code does
4. **Unknown gaps** — things the unification prompt didn't anticipate

---

## Audit 1: Vestige Sweep

### Known Vestige (fix immediately)

**CLAUDE.md line 170** — prescriptive example used `requires_actuality: [actuality-mode/voice]`.
- **Fixed to**: `requires: [mode/voice]` with `substrate: screen`

### Documentation Vestiges (20 files, ~120 occurrences)

The following docs still reference `actuality-mode`, `requires_actuality`, or `requires-actuality`. They need updating to reflect the unified model.

**Critical** (canonical references that developers read first):
| File | Occurrences | Nature |
|------|-------------|--------|
| `docs/reference/infrastructure/substrate-lifecycle.md` | 18 | Canonical substrate reference — extensive YAML examples with `eidos: actuality-mode` |
| `docs/how-to/presentation/mode-development.md` | 8 | Primary how-to — "define an actuality-mode" instructions |
| `docs/reference/elements/constituent-elements.md` | 2 | Element catalog still lists actuality-mode as separate type |

**Major** (affect understanding of the system):
| File | Occurrences | Nature |
|------|-------------|--------|
| `docs/design/AGORA-TERRITORY-DESIGN.md` | 15 | `actuality-mode/webrtc`, `actuality-mode/phaser` throughout |
| `docs/design/VOICE-OIKOS-DESIGN.md` | 9 | "has modes AND actuality-modes" framing |
| `docs/explanation/reactivity/reactive-system.md` | 6 | Dispatch examples with old ID format |
| `docs/how-to/reactivity/wire-reconciliation-cycle.md` | 4 | "Create the Actuality Mode Entity" section |
| `docs/explanation/generation/generative-spiral.md` | 2 | Constituent element list |

**Moderate** (terminology updates):
| File | Occurrences | Nature |
|------|-------------|--------|
| `docs/reference/genesis/directory-conventions.md` | 4 | `actuality-modes/` directory structure |
| `docs/design/WEBRTC-OIKOS-DESIGN.md` | 5 | `eidos: actuality-mode` YAML |
| `docs/design/CHORA-DEV-OIKOS-DESIGN.md` | 7 | `actuality-mode/cargo-build` etc. |
| `docs/design/DISTRIBUTED-ARCHITECTURE.md` | 3 | Deployment mode IDs |
| `docs/reference/composition/composition.md` | 2 | Code generation source |

**Minor** (single references or cross-links):
| File | Occurrences | Nature |
|------|-------------|--------|
| `docs/REGISTRY.md` | 2 | Impact map paths |
| `docs/how-to/presentation/voice-authoring.md` | 2 | Table references |
| `docs/reference/elements/composite-patterns.md` | 1 | Reconciliation cycle pattern |
| `docs/explanation/architecture/architecture.md` | 2 | YAML example + diagram |
| `docs/explanation/presentation/modes-and-oikos.md` | 3 | Substrate descriptions |
| `docs/explanation/reactivity/reconciler-pattern.md` | 1 | See also link |

### Archive Vestiges (safe to leave)

Files in `archive/` contain historical references — these are correctly archive material and do not need updating.

### Code Vestiges

**Generated file name**: `actuality_modes.rs` — The generated dispatch file retains the name "actuality_modes" because it generates actuality operation dispatch tables. This is a function name, not an ontology reference. The module generates `actuality_stoicheion(mode, provider, op)` which routes manifest/sense/unmanifest operations. The name describes what the code does (actuality dispatch), not the entity type it comes from.

**Decision**: Keep the filename. The function dispatches actuality operations; the name is accurate to the function even after eidos unification.

---

## Audit 2: Structural Consistency

### Screen Modes Live in the Wrong Directory

**Finding**: Infrastructure modes follow the `genesis/{topos}/modes/` pattern:
- `genesis/dynamis/modes/dynamis.yaml` — 8 compute/storage/network modes
- `genesis/soma/modes/voice.yaml` — 1 compute mode

But screen modes remain in `genesis/thyra/entities/layout.yaml` — NOT in `genesis/thyra/modes/`.

**Impact**:
- build.rs scans `genesis/*/modes/*.yaml` — screen modes are excluded (correct, they don't need dispatch)
- build.rs watches `genesis/thyra/modes/` — directory doesn't exist (harmless but misleading)
- Inconsistent convention: modes of other substrates get their own `modes/` directory; screen modes don't

**Question**: Should screen modes move to `genesis/thyra/modes/layout.yaml` for structural consistency? Or does the `entities/` location make sense because screen modes are tightly coupled with thyra-config entities and bonds?

**Recommendation**: Move screen modes to `genesis/thyra/modes/screen.yaml`. Keep thyra-config entities and bonds in `genesis/thyra/entities/layout.yaml`. Rationale: thyra-config is not a mode — it's a configuration entity that references modes. Modes themselves should live in `modes/` regardless of substrate.

### Voice Mode Topos Assignment

**Finding**: The voice mode moved from `genesis/thyra/actuality-modes/voice.yaml` to `genesis/soma/modes/voice.yaml` with `topos: soma`.

**Question**: Does the soma topos exist as a full topos with manifest.yaml? If not, the voice mode is in a directory without a topos container. This would be an orphaned directory — modes exist but the topos that owns them doesn't have a manifest.

**Action**: Verify `genesis/soma/manifest.yaml` exists. If not, either:
1. Create a minimal soma manifest, or
2. Keep voice in thyra until soma is established

### build.rs Voice Exclusion

**Finding**: Voice mode uses `handler:` fields instead of `stoicheion:` fields. build.rs correctly excludes it from the dispatch table because it filters for stoicheion-based operations only.

**Question**: Is the `handler:` vs `stoicheion:` distinction documented in the mode eidos? The eidos definition says operations contain `{ stoicheion, params, returns, description }` but voice.yaml uses `{ handler, params, returns, description }`. This is a semantic gap — the eidos schema doesn't describe the handler variant.

**Action**: Either:
1. Add `handler` as an alternative to `stoicheion` in the operations field description, or
2. Treat handler-based modes as a separate concern (they're hand-wired Rust, not stoicheion-dispatched)

---

## Audit 3: Semantic Alignment with KOSMOGONIA

### KOSMOGONIA Says "Every mode has three operations"

KOSMOGONIA §Mode — The Bridge:
> Every mode has three operations: **Manifest**, **Sense**, **Unmanifest**.

**Question**: Do screen modes have manifest/sense/unmanifest?

- Screen modes have render_spec_id, spatial, etc. — but no explicit `operations` block
- The layout engine performs manifest (render widget tree), sense (check if rendered), unmanifest (remove from layout) — but these operations are implicit in code, not declared in the mode entity

**Gap**: Infrastructure modes declare their operations explicitly. Screen modes do not. KOSMOGONIA prescribes that EVERY mode has three operations. The screen operations exist (in layout-engine.tsx) but aren't declared in the mode entity.

**This is the deepest question the audit surfaces**: Should screen modes declare their operations? If so, what would they look like?

```yaml
# Hypothetical — screen mode with explicit operations
operations:
  manifest:
    handler: thyra::render_widget_tree
    params: [render_spec_id, spatial, source_query]
  sense:
    handler: thyra::check_rendered
    params: [mode_id]
  unmanifest:
    handler: thyra::remove_from_layout
    params: [mode_id]
```

This would make the system truly uniform — but it might be over-specification if screen manifest is always "render the widget tree." The question is whether the uniformity serves a purpose (generative, compositional) or whether it's ceremony.

**Recommendation**: Note this gap. Don't fix it now. Revisit when the generative spiral reaches mode generation — if `generate-mode` praxis needs to produce screen modes, explicit operations would make the pattern uniform and generatable.

### KOSMOGONIA Says "The reconciler operates through modes"

**Question**: Does `host.reconcile()` actually read mode entities?

The reconciler engine reads `reconciler` entities (transition tables). Actuality operations dispatch via `actuality_stoicheion()`. But the reconciler doesn't traverse mode entities to discover operations — it reads the entity being reconciled and uses its `actuality_mode` + `provider` data fields.

**Gap**: The reconciler doesn't operate "through modes" in the sense of reading mode entities. It operates through the actuality dispatch table, which is generated FROM mode entities at build time. The mode entity is a genesis-time declaration; the dispatch table is the runtime mechanism.

**Verdict**: This is fine — KOSMOGONIA describes the conceptual architecture, not the runtime data flow. The reconciler operates through modes because the dispatch table IS the compiled form of mode declarations. Compile-time composition counts.

### Thyra-Config References Mode IDs, Not Substrate

**Finding**: `thyra-config` entities reference mode IDs in `active_modes`:
```yaml
active_modes:
  - mode/oikos-nav
  - mode/authoring-feed
  - mode/text-composing
```

These are all screen modes. But with mode unification, the same `active_modes` field could theoretically reference a compute mode (`mode/process-local`). Nothing prevents this — no validation exists.

**Question**: Should thyra-config.active_modes be constrained to `substrate: screen` modes only? Or is the ability to activate any mode from thyra-config a feature (e.g., activating a compute mode from the UI)?

**Recommendation**: Leave unconstrained. The layout engine renders screen modes; non-screen modes in active_modes would be passed to the actuality manager. This is the `requires` mechanism generalized — thyra-config says "these modes should be active," and the system sorts out which ones render vs which ones manifest.

---

## Audit 4: The Unknown Unknowns

### What about generated mode entities?

The generative spiral (PROMPT-GENERATIVE-SPIRAL.md) identifies reconciliation cycles as composite patterns. With mode unification, `generate-mode` praxis should be possible. But the prompt doesn't prescribe:
- What the typos-inference schema for modes looks like
- How substrate-specific fields get constrained
- Whether a generated screen mode needs a paired render-spec (yes — and that's ALSO generated)

**Question for later**: When the spiral reaches mode generation, does the unified eidos make generation easier or harder? The substrate-specific fields mean the schema must branch on substrate value.

### What about mode discovery at bootstrap?

build.rs generates dispatch tables at compile time. But mode entities are also loaded into kosmos.db at bootstrap (via genesis sync). The runtime can query mode entities from the graph.

**Question**: Is anyone querying mode entities at runtime? The layout engine reads them (to render). Does anything else? If the reconciler needed to discover "all modes for topos X" or "all compute modes," it would query the graph.

**Action**: No action needed now. But the ability to query `gather(eidos: mode, filter: substrate=compute)` is powerful and should be noted as a capability the unified model enables.

### What about mode versioning?

Mode entities in genesis are unversioned (no version field). If a mode's operations change (e.g., a stoicheion is renamed), the dispatch table is regenerated — but existing entities in kosmos.db that reference the old stoicheion would break.

**Question**: Should modes have version fields? Or is the rebuild-and-resync pattern sufficient?

**Recommendation**: This is a genesis versioning problem, not a mode-specific problem. Same applies to eide and praxeis. No action needed here.

### What about the "remote" substrate?

KOSMOGONIA lists "Remote substrate" in the mode table. The prompt prescribes `substrate: remote` for federation modes. But no `mode/federation-*` entities exist yet — that's Arc 3.

**Question**: When federation modes are created, they'll need:
- `operations.manifest.stoicheion: push-phoreta`
- `operations.sense.stoicheion: check-sync-cursor`
- `operations.unmanifest.stoicheion: remove-federation`
- `config_schema: { remote_oikos_id, endpoint_url, sync_direction, eidos_filter }`

These stoicheia don't exist yet. Arc 3 will need to create them.

**Observation**: The unified mode eidos is ready for federation — the shape supports it. This validates the unification.

---

## Implementation Order

### Phase 1: Fix the Structural Inconsistency

1. Create `genesis/thyra/modes/screen.yaml` — move 6 screen mode entities from `entities/layout.yaml`
2. Keep thyra-config entities and bonds in `entities/layout.yaml`
3. Update build.rs watch statement (or remove the thyra/modes watch if screen modes don't need it)
4. Verify `genesis/soma/manifest.yaml` exists — create minimal manifest if needed
5. Run all tests

### Phase 2: Doc Sweep (critical docs first)

Update the 7 critical/major docs:
1. `docs/reference/infrastructure/substrate-lifecycle.md` — complete revision
2. `docs/how-to/presentation/mode-development.md` — reframe actuality-mode as substrate mode
3. `docs/reference/elements/constituent-elements.md` — remove actuality-mode row, update mode row
4. `docs/design/AGORA-TERRITORY-DESIGN.md` — update all 15 occurrences
5. `docs/design/VOICE-OIKOS-DESIGN.md` — reframe "modes AND actuality-modes" as unified modes
6. `docs/explanation/reactivity/reactive-system.md` — update dispatch examples
7. `docs/how-to/reactivity/wire-reconciliation-cycle.md` — rewrite actuality-mode section

### Phase 3: Doc Sweep (moderate + minor)

Update remaining 13 docs — mostly find-and-replace of:
- `eidos: actuality-mode` → `eidos: mode` (with substrate)
- `actuality-mode/` → `mode/`
- `requires_actuality` → `requires`
- `requires-actuality` → `requires-mode`
- `actuality-modes/` directory references → `modes/`

### Phase 4: Resolve Semantic Gaps

1. Document `handler:` vs `stoicheion:` distinction in mode eidos (or eidos description)
2. Note the screen-mode operations gap for future generative spiral work
3. Update `docs/REGISTRY.md` impact map

### Phase 5: Verify

```bash
# Zero actuality-mode references in live docs
rg 'actuality-mode' docs/ --type md | grep -v archive
# Expected: zero results (or only in design docs marked as historical)

# Zero requires_actuality in genesis
rg 'requires_actuality|requires-actuality' genesis/
# Expected: zero results

# All mode entities use consistent eidos
rg 'eidos: actuality-mode' genesis/
# Expected: zero results

# Build succeeds
cargo build 2>&1

# All tests pass
cargo test -p kosmos --lib --tests 2>&1
cd app && npx vitest run 2>&1
```

---

## What This Audit Surfaces

| Finding | Severity | Action |
|---------|----------|--------|
| CLAUDE.md vestige (line 170) | **Fixed** | Already updated |
| 20 docs with old terminology | **High** | Phase 2-3 doc sweep |
| Screen modes in entities/ not modes/ | **Medium** | Phase 1 structural fix |
| Soma topos may lack manifest | **Medium** | Phase 1 verification |
| handler vs stoicheion undocumented | **Low** | Phase 4 eidos description |
| Screen modes lack explicit operations | **Low** | Note for generative spiral |
| thyra-config not substrate-constrained | **Design** | Leave unconstrained (intentional) |
| Federation modes don't exist yet | **Expected** | Arc 3 scope |
| actuality_modes.rs filename | **None** | Name describes function, not ontology |

---

*Traces to: PROMPT-MODE-UNIFICATION.md, KOSMOGONIA V11 §Mode — The Bridge*
