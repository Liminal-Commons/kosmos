# How to: Use Generation

Use the generative spiral to generate definitions instead of writing them manually. The demiurge provides `generate-*` praxeis that produce schema-constrained, evaluated artifacts.

---

## When to Use

Use generation when:
- You need a render-spec for an entity type and want a well-structured starting point
- You're creating a new eidos, praxis, desmos, or topos and want AI-assisted scaffolding
- You want the generation informed by existing theoria (accumulated understanding)

---

## Available Generation Praxeis

| Praxis | What It Generates | Key Params |
|--------|-------------------|------------|
| `demiurge/generate-render-spec` | Widget tree render-spec | `eidos_name`, `variant`, `purpose` |
| `demiurge/generate-eidos` | Entity type definition | `name`, `purpose`, `field_hints` |
| `demiurge/generate-praxis` | Operation with steps | `name`, `topos`, `purpose`, `params_spec` |
| `demiurge/generate-desmos` | Bond type definition | `name`, `purpose`, `from_eidos`, `to_eidos` |
| `demiurge/generate-topos` | Complete topos design | `name`, `purpose`, `scale`, `capabilities` |

All generation praxeis require `attainment/develop`.

---

## Step 1: Choose the Right Generator

**For render-specs** (most common):
```yaml
demiurge/generate-render-spec:
  eidos_name: "theoria"
  variant: "card"
  purpose: "Display crystallized understanding with domain and status"
```

**For entity types:**
```yaml
demiurge/generate-eidos:
  name: "recipe"
  purpose: "A cooking recipe with ingredients and steps"
  field_hints:
    - "title (string, required)"
    - "ingredients (array)"
    - "prep_time (integer, minutes)"
```

**For praxeis:**
```yaml
demiurge/generate-praxis:
  name: "create-recipe"
  topos: "recipes"
  purpose: "Create a new recipe from ingredients and steps"
  params_spec:
    - "title: string, required"
    - "ingredients: array, required"
```

---

## Step 2: Invoke and Review

Every generator returns an **artifact** (not a live entity). This lets you review before actualizing.

The response includes:
- `artifact` — the generated content wrapped in an artifact entity
- `verdict` — `TRUE`, `FALSE`, or `UNDECIDABLE` based on evaluation criteria
- `informed_by` — theoria that were surfaced and used to inform the generation

**Check the verdict.** If `FALSE`, the generation failed a critical criterion. Read the `guidance` field for what to fix.

---

## Step 3: Actualize (Render-Specs Only)

For render-specs, use the actualize step to promote the artifact to a real entity:

```yaml
demiurge/actualize-render-spec:
  artifact_id: "artifact/render-spec-theoria-card"
```

This creates the actual `render-spec` entity with a `composed-from` bond to the artifact.

For other generated types (eidos, praxis, desmos), copy the generated YAML into your genesis files manually.

---

## How It Works

```
Developer provides intent (name, purpose, context)
    ↓
Generator composes inference context:
  - Gathers eidos fields, example specs, constraints
  - Surfaces relevant theoria for domain context
    ↓
Calls manteia/governed-inference:
  - LLM generates within schema constraints
  - Evaluator checks domain-specific criteria
  - Returns verdict + guidance
    ↓
Wraps result in artifact entity with provenance bonds
    ↓
Developer reviews → actualizes or regenerates
```

---

## Evaluation Criteria

Each generator has domain-specific criteria:

**Render-spec generation:**
- `widget_validity` — only uses known widget types
- `binding_correctness` — `{field}` for render-time, `$form.field` for event-time
- `field_coverage` — renders all important entity fields
- `variant_match` — matches card/list-item/detail/panel conventions

**Eidos generation:**
- `ontological_coherence` — entity type has clear purpose
- `field_completeness` — all necessary fields present
- `naming_consistency` — follows kosmos naming conventions

**Praxis generation:**
- `step_validity` — only uses known stoicheia
- `workflow_coherence` — steps form logical sequence
- `parameter_sufficiency` — all needed params declared

---

## Example: Generate a Note Card

```yaml
# 1. Generate
demiurge/generate-render-spec:
  eidos_name: "note"
  variant: "card"
  purpose: "Display a note with content, kind badge, and creation time"

# Response includes:
# verdict: TRUE
# artifact: { id: "artifact/render-spec-note-card", ... }

# 2. Actualize
demiurge/actualize-render-spec:
  artifact_id: "artifact/render-spec-note-card"

# Creates: render-spec/note-card with widget tree
```

---

## See Also

- [Generating Instead of Writing](../../tutorial/generation/generating-instead-of-writing.md) — Tutorial walkthrough
- [Compose an Artifact](compose-artifact.md) — Manual composition via demiurge/compose
- [Crystallize Theoria](crystallize-theoria.md) — Crystallize understanding to inform future generations

---

*Guide for using the generative spiral to produce definitions.*
