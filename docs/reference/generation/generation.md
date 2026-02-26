# Generation Reference

*How kosmos generates constituent elements via governed inference.*

---

## Overview

Generation is the mechanism by which kosmos produces new element instances (render-specs, eide, praxeis, desmoi) from semantic intent rather than hand-authoring. Each generation pipeline follows the same pattern: compose an inference context from a typos, invoke governed inference with a structured output schema, validate the result, and actualize it as an entity.

---

## Generation Praxeis

All generation praxeis live in `genesis/demiurge/praxeis/render-spec-generation.yaml` and `genesis/demiurge/praxeis/demiurge.yaml`. They require the `develop` attainment (tier 3).

### Render-Spec Generation

| Praxis | Purpose |
|--------|---------|
| `demiurge/generate-render-spec` | Compose inference context → governed-inference → return artifact with generated render-spec |
| `demiurge/validate-render-spec` | Validate structure: layout array exists, target_eidos declared, variant declared |
| `demiurge/actualize-render-spec` | Create actual render-spec entity from artifact, bond with `composed-from` |

**Pipeline:**
```
generate-render-spec(eidos_name, variant, purpose)
  → compose typos-inference-render-spec with inputs
  → governed-inference with output_schema
  → validate-render-spec (structural checks)
  → return artifact
```

### Topos-Level Generation (in oikos-generation typos)

| Inference Context | Purpose |
|-------------------|---------|
| `typos-inference-eidos` | Generate eidos definitions (name, description, fields) |
| `typos-inference-praxis` | Generate praxis definitions (name, topos, params, steps) |
| `typos-inference-desmos` | Generate desmos definitions (name, purpose, from/to eidos, cardinality) |
| `typos-inference-topos` | Generate topos designs (meta-level: what eide, praxeis, desmoi a topos should contain) |

---

## Inference Contexts

Inference contexts are typos definitions that compose the prompt + schema for governed inference.

### typos-inference-render-spec

**Location:** `genesis/demiurge/typos/thyra-generation.yaml`

**Slots:**
- `eidos_name` — Which eidos this render-spec targets
- `variant` — card, detail, item, etc.
- `purpose` — What this render-spec should display
- `interactive` — Whether it handles user interaction
- `eidos_fields` — Field definitions from the eidos schema
- `example_specs` — Existing render-specs as few-shot examples

**Output schema:** Structured render-spec with `layout` array, `target_eidos`, `variant`, widget nodes.

**Widget vocabulary:** All 35+ registered widgets are included in the context so the LLM knows the available primitives.

### typos-inference-eidos / praxis / desmos

**Location:** `genesis/demiurge/typos/oikos-generation.yaml`

Each provides a schema-constrained inference context for generating the corresponding element type.

---

## The Governed Inference Step

The `governed-inference` stoicheion (tier 3, internal) invokes an LLM with:

1. **Composed context** — The filled inference context template
2. **output_schema** — JSON Schema enforced via `tool_use` response format
3. **Model selection** — Configurable, defaults to the session's LLM

**Key principle (T9):** `output_schema` via tool_use is more reliable than prompt instructions for constraining output structure. The LLM generates valid JSON matching the schema because the tool_use interface enforces it, not because instructions told it to.

---

## Validation

Each element type has specific validation rules:

### Render-Spec Validation
- `layout` must be a non-empty array
- Each node must have a `widget` field matching a registered widget
- `target_eidos` must be declared
- `variant` must be declared

### General Validation
- Entity IDs must follow naming conventions
- Required fields must be present
- Bond endpoints must reference valid eide

---

## Empirical Evidence

The generative proof (Phase 4) demonstrated end-to-end generation:

1. `render-spec/note-card` was generated via `demiurge/generate-render-spec`
2. The inference context was composed from `typos-inference-render-spec`
3. The output passed validation (valid widget tree, correct structure)
4. The verdict was TRUE — the kosmos can generate its own render-specs

Two latent compose bugs were fixed during this proof:
- `resolve_slot` input clobbering
- Param defaults not applied before binding

---

## Cross-References

- [Generative Spiral](../../explanation/generation/generative-spiral.md) — Why kosmos generates itself (three levels explained)
- [Schema Enforcement](../../explanation/generation/schema-enforcement.md) — Why output_schema > prompt instructions (T9)
- [Typos Composition](../composition/typos-composition.md) — Template syntax used in inference contexts
- [Composition Guide](../composition/composition.md) — How artifacts are composed
