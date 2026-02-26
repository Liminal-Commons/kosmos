# Generative Proof — The Spiral's First Turn

*Prompt for Claude Code in the chora + kosmos repository context.*

*The generative spiral is designed. The manteia infrastructure works. The composition pipeline works. What's missing: proof that the spiral can generate a composite element — a render-spec — end to end. This prompt is that proof.*

---

## Methodology — Empirical DDD+TDD

This work follows **Doc → Test → Build → Verify**, but with an empirical emphasis. The spiral is a design (`THYRA-AWARENESS.md`, `RENDER-SPEC-GUIDE.md`). This prompt tests the design against reality.

### The Cycle

1. **Doc (already written)**: `genesis/demiurge/THYRA-AWARENESS.md` specifies render-spec generation. `genesis/demiurge/RENDER-SPEC-GUIDE.md` specifies the widget vocabulary. These are the input specifications.
2. **Test (assert the design)**: Tests assert: inference context composes correctly, validation accepts/rejects correctly, actualization creates entities.
3. **Build (genesis definitions + interpreter fixes)**: Create the typos and praxeis in genesis. Fix any interpreter gaps discovered during testing.
4. **Empirical proof**: Invoke `generate-render-spec` for a real eidos. Does the output render?

### What "Proof" Means

Not "implement the complete spiral for all 12 element types." One composite element type (render-spec), end to end. If this works, the pattern extends. If it doesn't, we learn what the design missed.

---

## Context — What Exists

### Ready: Interpreter (chora)

The composition pipeline (`compose`, `compose-cached`), governed inference (`infer` step), graph operations (`find`, `gather`, `trace`, `surface`), template evaluation (`{{ expr }}`, pipe filters), and all 45+ step types work. 288 tests pass.

### Ready: Manteia Infrastructure (kosmos)

- `manteia/governed-inference`: schema-constrained LLM generation with optional evaluation
- `typos-def-inference-context`: base typos for composing inference contexts
- The `infer` stoicheion: accepts `output_schema` for structured generation

### Ready: Demiurge Spiral — 3 of 12 Element Types

- `generate-eidos`, `generate-praxis`, `generate-desmos` with inference context typos
- `actualize-eidos`, `actualize-praxis`, `actualize-desmos`
- Pattern established: compose inference context → call governed-inference → validate → actualize

### Ready: Render-Spec Exemplars (kosmos)

11 render-specs in `genesis/thyra/render-specs/`. These are the few-shot examples. Key patterns:
- **Card**: `affordance-card`, `phasis-card`, `theoria-card` — concise, `card` root widget
- **Detail**: `phasis-detail` — expanded view with sections
- **Panel**: `governance-panel` — compound view, `for-each` + `include` composition
- **Compose**: `text-compose` — form elements with `$form.*` bindings

### Ready: Widget Vocabulary (chora)

40 widget types implemented in `app/src/lib/widgets/*.tsx`. Complete reference in `genesis/demiurge/RENDER-SPEC-GUIDE.md` with props, patterns, and common mistakes.

### Not Ready: The Wiring

| What | Status | What's Missing |
|------|--------|----------------|
| `typos-inference-render-spec` | Designed in THYRA-AWARENESS.md | Not created as entity |
| `generate-render-spec` praxis | Designed | Not defined |
| `validate-render-spec` praxis | Designed | Not defined |
| `actualize-render-spec` praxis | Trivial (same as actualize-eidos) | Not defined |
| Widget vocabulary in context | Available as documentation | Not surfaced to generator |
| End-to-end proof | Never attempted | No generated render-spec exists |

---

## The Three Gaps

### Gap 1: No Widget Vocabulary for the Generator

The generator needs to know what widgets exist, their props, and their patterns. This knowledge lives in TSX implementations and in `RENDER-SPEC-GUIDE.md`. But the generator can't read files — it needs this in its inference context.

**Approach**: Condense the widget vocabulary into a reference string embedded in the inference context typos. The full `RENDER-SPEC-GUIDE.md` is too large — extract a concise widget table (name, key props, when to use, children pattern) suitable for LLM context.

This is pragmatic. Widget entities (queryable via `gather`) can come later. Static context proves the pattern.

### Gap 2: No Inference Context for Render-Specs

`typos-inference-eidos/praxis/desmos` exist. `typos-inference-render-spec` does not. This is the core missing piece. It must compose:
- **Role**: UI designer perspective, widget tree expertise
- **Constraints**: Binding syntax rules (the `{field}` vs `$form.field` distinction is critical — most common mistake), widget-only vocabulary, variant conventions
- **Context**: Target eidos fields (what data to display), example render-specs (how similar eide are rendered), widget reference (what's available)
- **Schema**: Render-spec entity structure with recursive widget tree `$defs`

### Gap 3: No Generation Pipeline Praxeis

No praxeis wire the inference context to governed-inference and back. The pattern is established (identical to generate-eidos) but the render-spec-specific versions don't exist:
1. Find target eidos → extract fields
2. Gather example render-specs of same variant
3. Compose inference context (typos-inference-render-spec)
4. Call governed-inference
5. Return as artifact

---

## Design

### The Inference Context

The `typos-inference-render-spec` follows the same pattern as `typos-inference-eidos` (in `genesis/demiurge/typos/oikos-generation.yaml`):

```yaml
eidos: typos
id: typos-inference-render-spec
data:
  name: inference-render-spec
  extends: typos-def-inference-context
  description: "Inference context for generating render-specs from eidos field schemas"

  slots:
    # Required inputs (caller provides)
    eidos_name:
      type: string
      required: true
    variant:
      type: string
      required: true
    purpose:
      type: string
      required: true
    interactive:
      type: boolean
      default: false

    # Context (praxis gathers, passes to compose)
    eidos_fields:
      type: string
      required: true
      description: "YAML of target eidos field definitions"
    example_specs:
      type: string
      default: ""
      description: "Existing render-specs of same variant, YAML-encoded"

    # Inference parameters (defaults — rarely overridden)
    role:
      type: string
      default: |
        You are a UI designer for the kosmos system. You design declarative
        widget trees called render-specs. Each render-spec targets an eidos
        (entity type) and defines how entities of that type appear visually.
        You understand the widget vocabulary, binding syntax, conditional
        rendering, and composition patterns. You produce clean, minimal
        render-specs that display the most important information.

    constraints:
      type: array
      default:
        - "Use ONLY widgets from the provided vocabulary"
        - "Entity data bindings use braces: {field_name}, {nested.path}"
        - "Form state uses dollar WITHOUT braces: $form.field_name"
        - "WRONG: {$form.field} — this is the #1 mistake. CORRECT: $form.field"
        - "Conditional: when: \"field\" (truthy) or when: \"field == 'value'\""
        - "Every button needs on_click (praxis id string) and label"
        - "Card variant: concise, 3-5 widgets, root is 'card'"
        - "Detail variant: sections with headings, root is 'stack'"
        - "List-item variant: single row, compact"
        - "Panel variant: compound, for-each + include for lists, root is 'stack'"
        - "Use for-each + include to render lists of related entities"

    output_schema:
      type: object
      default:
        type: object
        required: [eidos, id, data]
        properties:
          eidos:
            type: string
            const: render-spec
          id:
            type: string
            pattern: "^render-spec/"
          data:
            type: object
            required: [name, target_eidos, variant, layout]
            properties:
              name: { type: string }
              target_eidos: { type: string }
              variant:
                type: string
                enum: [card, list-item, detail, panel]
              layout:
                type: array
                items:
                  $ref: "#/$defs/widget_node"
        $defs:
          widget_node:
            type: object
            required: [widget]
            properties:
              widget: { type: string }
              props: { type: object }
              when: { type: string }
              children:
                type: array
                items:
                  $ref: "#/$defs/widget_node"
```

The `request` template (the actual prompt sent to the LLM) is composed from slots:

```yaml
    request:
      type: string
      default: |
        Generate a render-spec for the '{{ eidos_name }}' eidos.

        **Variant:** {{ variant }}
        **Purpose:** {{ purpose }}
        **Interactive:** {{ interactive }}

        ## Target Eidos Fields

        These are the fields defined on the target eidos. Your render-spec
        should display the most important fields for this variant.

        {{ eidos_fields }}

        ## Widget Vocabulary

        (condensed widget reference — see Phase 1)

        ## Examples

        {{ example_specs }}
```

### The Generation Praxis

```yaml
praxis/demiurge/generate-render-spec:
  name: generate-render-spec
  topos: demiurge
  tier: 2
  description: "Generate a render-spec for an eidos using the widget vocabulary"
  params:
    - { name: eidos_name, type: string, required: true }
    - { name: variant, type: string, required: true }
    - { name: purpose, type: string, required: true }
    - { name: interactive, type: boolean, required: false }

  steps:
    # 1. Find target eidos → get field definitions
    - step: find
      id: "eidos/{{ eidos_name }}"
      bind_to: target_eidos

    - step: set
      bind_to: eidos_fields
      value: "{{ target_eidos.data.fields | yaml_encode }}"

    # 2. Gather example render-specs of same variant
    - step: gather
      eidos: render-spec
      bind_to: all_specs

    - step: filter
      source: $all_specs
      condition: "$item.data.variant == $variant"
      limit: 3
      bind_to: matching_specs

    - step: set
      bind_to: examples_yaml
      value: "{{ matching_specs | yaml_encode }}"

    # 3. Compose inference context
    - step: compose
      typos_id: typos-inference-render-spec
      inputs:
        eidos_name: $eidos_name
        variant: $variant
        purpose: $purpose
        interactive: $interactive
        eidos_fields: $eidos_fields
        example_specs: $examples_yaml
      bind_to: context

    # 4. Call governed inference
    - step: call
      praxis: manteia/governed-inference
      params:
        prompt: $context.data.request
        system_prompt: $context.data.role
        output_schema: $context.data.output_schema
      bind_to: generated

    # 5. Return
    - step: return
      value:
        render_spec: $generated
        target_eidos: $eidos_name
        variant: $variant
```

### Validation Praxis

```yaml
praxis/demiurge/validate-render-spec:
  name: validate-render-spec
  topos: demiurge
  tier: 1
  description: "Validate a generated render-spec against the widget vocabulary"
  params:
    - { name: render_spec, type: object, required: true }

  steps:
    - step: assert
      condition: $render_spec.data.layout
      message: "render-spec must have layout array"

    - step: assert
      condition: $render_spec.data.target_eidos
      message: "render-spec must declare target_eidos"

    - step: assert
      condition: $render_spec.data.variant
      message: "render-spec must declare variant"

    - step: return
      value:
        valid: true
        id: $render_spec.id
```

### Actualization Praxis

```yaml
praxis/demiurge/actualize-render-spec:
  name: actualize-render-spec
  topos: demiurge
  tier: 2
  description: "Create a render-spec entity from a generated artifact"
  params:
    - { name: render_spec, type: object, required: true }

  steps:
    - step: arise
      eidos: render-spec
      id: $render_spec.id
      data: $render_spec.data
      bind_to: entity

    - step: return
      value:
        status: actualized
        entity_id: $render_spec.id
```

---

## Implementation Order

### Phase 1: Widget Vocabulary Context

Extract a condensed widget reference from `genesis/demiurge/RENDER-SPEC-GUIDE.md` suitable for LLM context. Format:

```
## Widget Vocabulary

### Layout
- card: { variant, padding, on_click, on_click_params } — root container for card variant
- stack: { gap, padding } — vertical layout, children required
- row: { gap, align, justify } — horizontal layout, children required
- scroll: {} — scrollable container, children required
...

### Display
- text: { content, variant: body|caption|emphasis|code } — text display
- heading: { content, level: 1-6 } — section header
- badge: { content, variant: default|success|warning|error } — status tag
...
```

This should be ~50-80 lines — enough for the LLM to know what's available without overwhelming context.

### Phase 2: Genesis Definitions

Create the YAML definitions:

1. **`genesis/demiurge/typos/thyra-generation.yaml`** — `typos-inference-render-spec` with the condensed widget vocabulary embedded in the `request` template
2. **`genesis/demiurge/praxeis/render-spec-generation.yaml`** — `generate-render-spec`, `validate-render-spec`, `actualize-render-spec`
3. **Update `genesis/demiurge/manifest.yaml`** — add new content paths

### Phase 3: Test the Pipeline

Tests in `crates/kosmos/tests/render_spec_generation.rs`:

1. **Bootstrap loads new definitions** — typos and praxeis exist after bootstrap
2. **Inference context composition** — compose `typos-inference-render-spec` with test inputs, verify it produces a context with role, constraints, request (with interpolated fields), and output_schema
3. **Validation: accept good** — pass an existing render-spec (e.g., `affordance-card` structure) to `validate-render-spec`, verify it passes
4. **Validation: reject bad** — pass a spec with missing layout, verify it fails with clear error
5. **Actualization** — pass a hand-crafted render-spec to `actualize-render-spec`, verify entity exists in graph

**Note**: Tests that call `governed-inference` require API access. Mark these `#[ignore]` for CI. The empirical proof (Phase 4) is interactive, not automated.

### Phase 4: Generate One Render-Spec

Target: `render-spec/note-card` for the `note` eidos.

Why `note`:
- Simple entity (title, content, maybe tags)
- Card variant is the most constrained (concise, well-understood pattern)
- Non-interactive (display only, no form complexity)
- Existing `theoria-card` is a close analog for few-shot learning

Invocation:
```
generate-render-spec(
  eidos_name: "note",
  variant: "card",
  purpose: "Display a note with title and content preview"
)
```

Evaluation:
1. Does the generated spec have valid widget types?
2. Do the bindings reference actual fields from `eidos/note`?
3. Is the structure reasonable (card → stack → text, heading, etc.)?
4. Does it render in thyra when actualized?
5. What did the generator get wrong? What context was missing?

Document findings as theoria — this is the spiral learning from its first turn.

---

## Files to Read

### Inference context pattern (follow this)
- `genesis/demiurge/typos/oikos-generation.yaml` — `typos-inference-eidos/praxis/desmos` (the pattern to follow)
- `genesis/demiurge/praxeis/demiurge.yaml` — `generate-eidos/praxis/desmos` (the generation praxis pattern)

### Widget vocabulary (input for context)
- `genesis/demiurge/RENDER-SPEC-GUIDE.md` — complete widget reference
- `genesis/demiurge/THYRA-AWARENESS.md` — render-spec generation design

### Render-spec exemplars (for understanding output shape)
- `genesis/thyra/render-specs/affordance-card.yaml` — interactive card with on_click
- `genesis/thyra/render-specs/theoria-card.yaml` — simple display card
- `genesis/thyra/render-specs/governance-panel.yaml` — compound panel with for-each

### Target eidos (for Phase 4)
- Find `eidos/note` in genesis — its field definitions are the input

### Interpreter (if fixes needed)
- `crates/kosmos/src/interpreter/steps.rs` — compose, infer, filter step implementations
- `crates/kosmos/src/interpreter/expr.rs` — template evaluation

---

## Risks and Mitigations

### Risk: Generated widget trees are structurally invalid

The output_schema uses recursive `$ref` for widget nodes. The `infer` step may not handle recursive JSON Schema well.

**Mitigation**: If recursive schema fails, flatten to 3 levels (layout → children → children) with explicit nesting. Alternatively, generate as YAML string and parse.

### Risk: Widget vocabulary context is too large

40 widgets with props could overwhelm the inference context, leaving little room for eidos fields and examples.

**Mitigation**: Phase 1 condenses to essential widgets only (~20 most used). Card/stack/row/text/heading/badge/button/icon cover 90% of render-specs.

### Risk: Binding syntax errors in generated output

`{$form.field}` vs `$form.field` is the most common mistake, even for humans. LLM may make this error.

**Mitigation**: The constraints explicitly call this out. Validation could check for this pattern. Post-generation fixup is acceptable for the first proof.

### Risk: `eidos/note` doesn't exist or lacks field definitions

The target eidos might not have rich enough field definitions for meaningful generation.

**Mitigation**: If `note` is too thin, use `theoria` or `phasis` — eide with known fields and existing render-specs for comparison.

---

## Success Criteria

**Phase 1 Complete When:**
- [ ] Condensed widget vocabulary reference exists (~50-80 lines)
- [ ] Covers all commonly-used widgets with key props

**Phase 2 Complete When:**
- [ ] `typos-inference-render-spec` bootstraps successfully
- [ ] `generate-render-spec` praxis bootstraps successfully
- [ ] `validate-render-spec` praxis bootstraps successfully
- [ ] `actualize-render-spec` praxis bootstraps successfully

**Phase 3 Complete When:**
- [ ] Inference context composition test passes
- [ ] Validation accepts known-good render-specs
- [ ] Validation rejects malformed render-specs
- [ ] Actualization creates entity in graph
- [ ] All non-ignored tests pass

**Phase 4 Complete When:**
- [ ] `generate-render-spec` invoked for a real eidos
- [ ] Generated render-spec passes validation
- [ ] Generated render-spec actualized as entity
- [ ] Findings documented: what worked, what context was missing, what the generator got wrong
- [ ] At least one theoria crystallized about render-spec generation

**Overall Complete When:**
- [ ] The spiral works end-to-end for one composite element type
- [ ] The pattern is validated: inference context → governed generation → validation → actualization
- [ ] All existing tests still pass
- [ ] The first generated render-spec exists in kosmos with provenance

---

## What This Enables

When the first turn succeeds:

- **The pattern extends**: `generate-mode`, `generate-reconciler`, `generate-reflex` follow the same shape — compose inference context, call governed-inference, validate, actualize. The machinery is proven.
- **Presentation becomes generatable**: Given an eidos and the widget vocabulary, the spiral can generate a render-spec. New topoi get UI presence as part of development, not as an afterthought.
- **Theoria about generation accumulates**: "This widget combination works for list entities." "Card variant needs this much context." Insights crystallize and improve future generations.
- **The kosmos begins to generate itself**: The spiral is no longer a design document. It's an operational capability.

---

*The generative spiral is how the kosmos develops itself. This prompt proves it works — one render-spec, one turn of the spiral, one step from design to actuality.*

---

## Findings — The Spiral's First Turn

### Completion Status

All phases complete. All success criteria met.

**Phase 4 checklist:**
- [x] `generate-render-spec` invoked for `eidos/note`, card variant
- [x] Generated render-spec passes validation (verdict: TRUE)
- [x] Generated render-spec actualized as entity (render-spec/note-card)
- [x] Findings documented (this section)
- [x] Theoria crystallized (T9, T10 below)

**Overall checklist:**
- [x] The spiral works end-to-end for one composite element type (render-spec)
- [x] The pattern is validated: inference context → governed generation → validation → actualization
- [x] All existing tests still pass (322 pass)
- [x] The first generated render-spec exists in kosmos with provenance

### The Generated Render-Spec

`render-spec/note-card` — generated for `eidos/note`, card variant:

```yaml
layout:
  - widget: card
    props: { padding: md, variant: bordered }
    children:
      - widget: stack
        props: { gap: sm }
        children:
          - widget: row
            props: { align: center, justify: between }
            children:
              - widget: badge
                props: { content: "{kind}", variant: info }
              - widget: text
                props: { content: "{created_at}", variant: caption }
          - widget: text
            props: { content: "{content}", variant: body }
          - widget: text
            props: { content: "{reason}", variant: caption }
            when: "reason"
```

### What Worked

1. **Schema-constrained generation via tool_use**: The `output_schema` in the inference context forced structurally valid JSON. No post-processing needed. The recursive `$defs/widget_node` schema worked — the generator produced a properly nested tree.

2. **Widget vocabulary in prompt**: The condensed vocabulary (~40 widgets with key props) fit within context and the generator used appropriate widgets. Every widget type in the output (card, stack, row, badge, text) is valid.

3. **Binding syntax**: All bindings (`{kind}`, `{content}`, `{created_at}`, `{reason}`) reference actual fields from `eidos/note`. The `{$form.field}` mistake the constraints warned about did not occur.

4. **Conditional rendering**: `when: "reason"` correctly gates the optional reason field. The generator understood that optional fields need conditional display.

5. **Variant awareness**: Card variant produced a concise, single-card layout — not an expanded detail view. The variant descriptions in the inference context guided the structure correctly.

### What the Generator Got Wrong

Nothing structurally wrong. The output was valid on the first generation attempt. This is likely because:
- `eidos/note` is simple (4 fields)
- Card variant is well-constrained
- The schema enforcement left little room for structural errors

For more complex eide or interactive variants, expect more issues.

### What Context Was Missing (for future generations)

1. **No existing exemplars**: The `example_specs` slot was empty because no existing render-specs matched the `card` variant filter (the gather step filters by variant). Future generations for less common variants will benefit from few-shot examples of any variant.

2. **No field importance weighting**: All fields are presented equally. For entities with many fields, the generator won't know which are most important for a card (concise) vs detail (expanded) variant.

3. **No eidos description**: The generator received field definitions but not the eidos-level description. Context about *what* a note is would help for ambiguous fields.

### Interpreter Bugs Discovered and Fixed

Two bugs in the compose pipeline were discovered during empirical testing:

**Bug 1: `resolve_slot` clobbering caller inputs** (`steps.rs`)
In `compose_entity`, inputs are merged into scope, then `resolve_slot` is called for each slot. For input-only slots (type/required/description but no fill pattern), `resolve_slot` returned `Value::Null`, which was then set back into scope — overwriting the caller's input. Fix: `resolve_slot` now checks `inputs.get(slot_name)` as fallback before returning Null.

**Bug 2: Praxis param defaults not applied** (`mod.rs`)
`execute_praxis` only bound explicit caller inputs to scope. Params with `default` values (like `evaluate: true` in governed-inference) were never applied. This caused the governed-inference praxis to take the wrong return branch (returning raw content instead of the evaluation envelope). Fix: Added default application loop before input binding.

Both bugs were latent — they didn't affect previous test cases because those either provided all values explicitly or didn't use param defaults.

### Crystallized Theoria

**T9: Schema enforcement is the generator's primary guardrail**
The recursive JSON Schema (`output_schema`) via tool_use was the single most important factor in producing valid output. Without it, structural errors would dominate. With it, the generator could focus on semantic correctness (which fields to display, what layout to use) rather than syntactic correctness (valid JSON, correct nesting). For generative capabilities, invest in the schema first — constraints on the output shape are more reliable than instructions in the prompt.

**T10: Latent compose pipeline bugs surface only at integration boundaries**
The `resolve_slot` and param-default bugs existed from the beginning but only manifested when the full pipeline was exercised end-to-end (compose → infer → switch → return). Unit tests of individual steps don't trigger these paths because they construct scope manually. The empirical proof was essential — it tested the seams between components, not just the components themselves. Future changes to the compose pipeline should include at least one multi-step integration test that exercises the full slot-resolution → step-execution → return chain.
