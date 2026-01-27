# Demiurge: The Compositor

*A design for the single way to create.*

---

## The Problem

Creation sprawls. Without discipline:
- Entities arise without provenance
- Bonds form without authorization
- Templates render without consistency

V7 has multiple creation paths. Nothing enforces composition.

**Demiurge makes composition the only way.**

---

## Implementation Status

| Component | Status | Location |
|-----------|--------|----------|
| demiurge.yaml schema | ✓ Complete | `demiurge/demiurge.yaml` |
| Eide (typos, artifact) | ✓ Loaded | `spora/spora.yaml` stage-1-archai |
| Desmoi (composed-from, authorized-by) | ✓ Loaded | `spora/spora.yaml` stage-1-desmoi |
| Rust interpreter ComposeStep | ✓ Complete | `steps.rs` — entity, graph, template |
| Compose praxis | ✓ Working | `mcp-core.yaml` → MCP tool |
| Artifact definitions | ✓ Complete | `definitions/core.yaml` — 15 definitions |
| `cache_key` and `stale` fields | ✓ Complete | `spora.yaml` artifact eidos |
| `depends-on` desmos | ✓ Complete | `spora.yaml` stage-1-desmoi |
| Cache praxeis | ✓ Complete | `praxeis/demiurge.yaml` |
| Graph praxeis | ✓ Complete | `praxeis/demiurge.yaml` |

### Cache Praxeis (Phase 6)

| Praxis | Description |
|--------|-------------|
| `compose-cached` | Content-addressed cached composition |
| `check-cache` | Check if artifact exists in cache |

### Graph Praxeis (Phase 7)

| Praxis | Description |
|--------|-------------|
| `bind-dependencies` | Bind multiple dependencies to artifact |
| `mark-dependents-stale` | Invalidation propagation |
| `invalidate-artifact` | Mark single artifact stale |
| `list-stale-artifacts` | List all stale artifacts |
| `refresh-stale` | Recompose a stale artifact |

---

## The Constitutional Requirements

The demiurge implements three constitutional requirements from KOSMOGONIA:

### The Composition Requirement

> Nothing arises raw. Everything is composed.
>
> ```
> compose(definition, inputs) → entity with provenance
> ```
>
> The definition traces to its oikos. The oikos traces to genesis.
> Genesis is signed. The chain is complete.

### The Validity Requirement

> All generation is governed. Schema constrains output.
>
> When artifacts are composed with generated content:
> - Generation flows through manteia (governed inference)
> - Schema sources constrain the structure (eidos, stoicheion, explicit)
> - Invalid structure cannot arise — validity is guaranteed at generation time

This means:
- **Every generated slot** uses schema-constrained inference when a schema source is available
- **Schema sources** (precedence): `output_schema` > `stoicheion_id` > `target_eidos`
- **Dependencies are tracked** — artifacts know which schema sources they depend on
- **Staleness propagates** — when a schema source changes, dependent artifacts become stale

### The Authenticity Requirement

> Every entity has content hash, composed-from reference, and composition timestamp.
> Modification changes the hash. Tampering creates visibly different things.

These are not guidelines. They are the architecture.

---

## Architecture

### 1. One Verb

```
compose(typos_id, inputs) → entity or artifact
```

Everything flows through this. The demiurge routes based on definition shape.

### 2. Routing Logic

| If Definition Has | Then Route To |
|-------------------|---------------|
| `target_eidos` | Entity composition |
| `slots` (no target_eidos) | Graph composition |
| `template` (no slots, no target_eidos) | Template rendering |

```yaml
# Entity composition
- id: typos-def-theoria
  target_eidos: theoria
  fields: { ... }
  bonds: [ ... ]

# Graph composition
- id: typos-def-rust-step
  slots:
    struct_name: { ... }
    execute_body: { ... }
  output_type: text

# Template rendering
- id: typos-def-greeting
  template: "Hello, {{ name }}!"
```

### 3. The compose-entity Path

When `target_eidos` is present:

1. **Arise** the entity with merged data
2. **Bind** `composed-from` → definition
3. **Bind** `authorized-by` → provenance root (if provided)
4. **Create bonds** specified in definition

Bond specs use declarative forms:
- `from_self`, `to_literal` — from new entity to fixed ID
- `from_self`, `to_input` — from new entity to input value
- `from_self`, `to_context` — from new entity to dwelling context
- `from_context`, `to_self` — from dwelling context to new entity

### 4. The compose-graph Path

When `slots` present without `target_eidos`:

1. **Fill slots** with merged inputs
2. **Render** to text or return object

Used for code generation, document assembly.

### 5. The compose-template Path

When only `template`:

1. **Render** template with merged inputs
2. **Optionally persist** as artifact entity

Simplest path. Pure text transformation.

### 6. Provenance Chain

Every composed entity has:
- `composed-from` bond → the definition used
- `authorized-by` bond → the authorizing expression

All chains terminate at genesis-root. This is how authenticity works.

---

## Key Definitions

Already defined in various oikoi:

| Definition | Target Eidos | Oikos |
|------------|--------------|-------|
| `typos-def-theoria` | theoria | nous |
| `typos-def-principle` | principle | polis |
| `typos-def-pattern` | pattern | polis |
| `typos-def-circle` | circle | polis |
| `typos-def-persona` | persona | polis |
| `typos-def-inquiry` | inquiry | nous |
| `typos-def-synthesis` | synthesis | nous |

The definition lives in its oikos. The demiurge is just the router.

---

## Bond Specification

The most complex part. Bond specs in definitions:

```yaml
bonds:
  # From new entity to literal ID
  - desmos: belongs-to
    from_self: true
    to_literal: oikos/nous

  # From new entity to dwelling context
  - desmos: crystallized-in
    from_self: true
    to_context: _circle

  # From dwelling context to new entity
  - desmos: stewards
    from_context: _persona
    to_self: true

  # From new entity to input value
  - desmos: synthesizes
    from_self: true
    to_input: sources
    many: true  # for array inputs
```

The create-bond internal praxis resolves these.

---

## Implementation Path

### Phase 1: Basic Entity Composition ✓ COMPLETE

Compose with target_eidos works:
- arise entity
- composed-from bond
- literal bonds (to_literal)

### Phase 2: Context-Aware Bonds ✓ COMPLETE

Auto-bond to dwelling circle on compose:
- `compose_entity()` creates `belongs-to` bond to `dwelling.circle_id`

**Implemented in:** [steps.rs](../../crates/kosmos/src/interpreter/steps.rs)

### Phase 3: Graph and Template Composition ✓ COMPLETE

- `compose_graph()` fills slots with merged inputs
- `compose_template()` renders templates with variable interpolation
- Supports both `{{ $var }}` and `{{ var }}` syntax (handlebars-style bare variables)

### Phase 4: Artifact Definitions ✓ COMPLETE

Created `definitions/core.yaml` with 15 artifact definitions:
- Understanding: theoria, inquiry, synthesis, journey, waypoint
- Governance: principle, pattern, circle, persona
- Intimate: note, insight, session, conversation
- Templates: greeting, summary
- Graph: rust-struct, yaml-entity

### Phase 5: Enforcement (Future)

Make raw arise fail:
- All entity creation must route through compose
- Rust interpreter enforces
- Currently optional for debugging convenience

### Phase 6: Artifact Cache ✓ COMPLETE

Content-addressed caching of compositions:

**Problem**: Identical inputs re-render. Expensive for inference-heavy compositions.

**Solution**: Hash-based lookup using `typos_id + inputs`.

**Implemented:**
1. ✓ `digest` step type uses BLAKE3 hash
2. ✓ `compose-cached` praxis with cache key lookup
3. ✓ `check-cache` praxis for inspection
4. ✓ `cache_key` field on artifact eidos
5. ✓ Content-addressed artifact IDs: `artifact/{{ cache_key }}`

### Phase 7: Artifact Graph ✓ COMPLETE

Dependency tracking for invalidation:

**Problem**: When underlying data changes, which artifacts are stale?

**Solution**: `depends-on` bonds from artifact to dependencies.

**Implemented:**
1. ✓ `depends-on` desmos in `spora.yaml`
2. ✓ `stale` field on artifact eidos
3. ✓ `bind-dependencies` helper praxis
4. ✓ `mark-dependents-stale` invalidation praxis
5. ✓ `invalidate-artifact` single artifact invalidation
6. ✓ `list-stale-artifacts` audit praxis
7. ✓ `refresh-stale` recomposition praxis

**Note:** Automatic invalidation on update/arise is not yet implemented.
Currently manual: call `mark-dependents-stale` when an entity changes.

### Phase 8: Schema-Constrained Generation ✓ FOUNDATIONAL

**This phase establishes the Validity Requirement from KOSMOGONIA.**

Integration of manteia schema-driven generation into artifact composition.

**Problem**: `pattern: generated` slots produce free-form text. No structural guarantee.

**Solution**: Generated slots can specify a schema source. The compositor passes
the schema to manteia/governed-inference, which uses Anthropic tool_use to
enforce the schema at generation time.

**Schema Sources:**

| Field | Schema Derivation |
|-------|-------------------|
| `output_schema` | Direct JSON Schema (explicit) |
| `stoicheion_id` | `stoicheion_to_json_schema()` — from step type fields |
| `target_eidos` | `eidos_to_json_schema()` — from eidos fields |
| `praxis_id` | `praxis_to_json_schema()` — from praxis params |

**Slot Specification (Extended):**

```yaml
slots:
  - name: usage_section
    pattern: generated
    prompt: "Generate usage notes for this eidos..."

    # Schema source (one of):
    output_schema:           # Explicit JSON Schema
      type: object
      properties:
        summary: { type: string }
        examples: { type: array, items: { type: string } }
    # OR
    target_eidos: usage-notes   # Derive from eidos fields
    # OR
    stoicheion_id: filter       # Derive from step fields

    authorized_by: caller
    auto_approve: true
```

**Composition Flow with Schema:**

```
compose(typos_id, inputs)
    │
    ├── for each slot:
    │       │
    │       ├── pattern: literal → use value directly
    │       ├── pattern: computed → evaluate expression
    │       ├── pattern: queried → query entity
    │       ├── pattern: composed → recursive compose
    │       │
    │       └── pattern: generated
    │               │
    │               ├── resolve schema source:
    │               │     • output_schema → use directly
    │               │     • stoicheion_id → stoicheion_to_json_schema()
    │               │     • target_eidos → eidos_to_json_schema()
    │               │
    │               └── call manteia/governed-inference
    │                     prompt: slot.prompt (interpolated)
    │                     output_schema: resolved schema
    │                     authorized_by: slot.authorized_by
    │                           │
    │                           └── Anthropic tool_use enforces schema
    │                                     │
    │                                     └── valid JSON (guaranteed)
    │
    └── assemble slots → artifact
```

**Dependency Tracking:**

When a slot uses `target_eidos` or `stoicheion_id`, the artifact gains
a `depends-on` bond to that schema source entity. If the schema changes,
the artifact becomes stale.

**Implementation Status:**

| Task | Status |
|------|--------|
| `stoicheion_to_json_schema()` | ✓ Complete (schema.rs) |
| `eidos_to_json_schema()` | ✓ Complete (schema.rs) |
| `praxis_params_to_json_schema()` | ✓ Complete (schema.rs) |
| InferStep `target_eidos` field | ✓ Complete (steps.rs) |
| Stoicheion/infer `target_eidos` | ✓ Complete (stoicheion.yaml) |
| `manteia/generate-entity` praxis | ✓ Complete (manteia.yaml) |
| Slot schema source resolution | ✓ Complete (steps.rs) |
| Compositor integration | ✓ Complete (steps.rs compose_graph_generated_slot) |
| Dependency tracking for schemas | ✓ Complete (steps.rs, demiurge.yaml) |

### Phase 9: Pege-Style Slot Enhancements ✓ COMPLETE

Document composition definitions (pege.yaml) use enhanced slot syntax:

**Slot Format:**
- Object format: `slots: { slot_name: { pattern, ... } }` (original)
- Array format: `slots: [{ name, pattern, ... }]` (pege-style)

**Key Aliases:**
- `pattern` is alias for `caller` (pege uses `pattern`)
- `template` is alias for `value` in literal slots
- `source` is alias for `entity_id + field` in queried slots
- `definition` is alias for `typos_id` in composed slots

**Conditional Slots:**
```yaml
- name: fields_section
  pattern: composed
  definition: typos-def-field-table
  when: entity.data.fields    # Skip if condition is falsy
```

**Handlebars Variables:**
- `{{ var }}` works without `$` prefix (handlebars-style)
- `{{ entity.data.name }}` - dot notation supported
- `{{ $var }}` still works for explicit scope reference

---

## Decisions Made

1. **One entry point**
   - praxis/demiurge/compose is the only public praxis
   - Internal praxeis (compose-entity, etc.) are `visible: false`
   - MCP exposes only compose

2. **Definition shape determines routing**
   - No explicit "mode" field
   - Shape IS meaning
   - Simpler definitions, smarter routing

3. **Bonds are declarative**
   - Definition says WHAT bonds, not HOW
   - Demiurge interprets the spec
   - Dwelling context accessed by key name

## Open Questions

1. **How strict is enforcement?**
   - Should `arise` step fail outside compose?
   - Or just not create composed-from bond?
   - Strictness vs debugging convenience

2. **Who can compose what?**
   - Should definitions have visibility/tier?
   - Currently: anyone can use any definition
   - Future: definition access based on circle?

3. **Nested composition?**
   - Definition that composes from other definitions?
   - Currently: single level only
   - May need for complex artifacts

---

## Summary

Demiurge provides:
- **One verb**: compose
- **Three paths**: entity, graph, template
- **Provenance**: composed-from and authorized-by bonds
- **Governed generation**: schema-constrained inference for validity
- **Declarative bonds**: specs resolved at composition time

The compositor is simple. Complexity lives in the definition.

---

## Related Documents

- [ROADMAP.md](../ROADMAP.md) — Overall status, V4 schema-artifact integration
- [KOSMOGONIA.md](../KOSMOGONIA.md) — Composition requirement
- [demiurge.yaml](demiurge.yaml) — Full schema
- [manteia/DESIGN.md](../manteia/DESIGN.md) — Schema-driven generation (Phase 8 integration)
- [stoicheia-portable/DESIGN.md](../stoicheia-portable/DESIGN.md) — Step schemas for generation
- [spora/definitions/pege.yaml](../spora/definitions/pege.yaml) — Document definitions with generated slots

---

*Composed in service of the kosmogonia.*
*Traces to: expression/genesis-root*
*Updated: 2026-01-23 — Phase 8 compositor integration complete (slot schema resolution, generated pattern)*
