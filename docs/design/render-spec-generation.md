# Demiurge Thyra-Awareness

*Extending the Generative Development Spiral for render-spec generation.*

**Status:** Design → Implementation
**Depends on:** [RENDER-SPEC-GUIDE.md](RENDER-SPEC-GUIDE.md), [Widget Vocabulary](../thyra/eide/widget.yaml)

---

## Overview

Demiurge generates definitions: eidos, praxis, desmos. With thyra-awareness, it also generates **render-specs** — how entities appear visually.

One pattern. Same spiral:

```
generate-eidos → actualize-eidos
generate-praxis → actualize-praxis
generate-desmos → actualize-desmos
generate-render-spec → actualize-render-spec  # NEW
```

**Result:** Any eidos can have UI generated automatically. No manual YAML authoring required.

---

## Agent Context

When generating render-specs, agents receive:

1. **Target Eidos** — The entity type and its fields
2. **Widget Vocabulary** — Available widgets with props schemas
3. **Binding Rules** — Syntax for `{field}`, `$form.field`, `when:`
4. **Example Specs** — Working render-specs from the domain
5. **Domain Theoria** — Crystallized understanding about the topos

This context enables generation that:
- Uses only valid widgets
- Binds to actual entity fields
- Follows established patterns
- Respects domain conventions

---

## New Praxeis

### Generation (Tier 3 - requires inference)

| Praxis | Purpose |
|--------|---------|
| `demiurge/generate-render-spec` | Generate render-spec for an eidos |

### Actualization (Tier 2 - kosmos ops)

| Praxis | Purpose |
|--------|---------|
| `demiurge/actualize-render-spec` | Create render-spec entity from artifact |

### Discovery (Tier 1 - read-only)

| Praxis | Purpose |
|--------|---------|
| `demiurge/discover-widgets` | List available widget types with props |

### Validation (Tier 2)

| Praxis | Purpose |
|--------|---------|
| `demiurge/validate-render-spec` | Validate widget refs, binding syntax |

---

## Generation Context Composition

The `typos-inference-render-spec` template surfaces everything an agent needs:

```yaml
- eidos: typos
  id: typos-inference-render-spec
  data:
    name: inference-render-spec
    description: |
      Generate a render-spec for an eidos using widget vocabulary.

      Context surfaced:
      - Target eidos fields (what to bind)
      - Widget vocabulary (what to compose)
      - Binding syntax rules
      - Existing render-spec examples

    slots:
      eidos_name:
        type: string
        required: true
        description: The eidos to create a render-spec for

      variant:
        type: string
        required: true
        description: Render variant (card, list-item, detail, panel)

      purpose:
        type: string
        required: true
        description: What this render-spec should accomplish

      interactive:
        type: boolean
        required: false
        default: false
        description: Whether to include click handlers

      topos_context:
        type: string
        required: false
        description: Oikos for domain-specific patterns

    context_sources:
      - source: gather
        query: "eidos: eidos, id contains '$eidos_name'"
        as: target_eidos
        description: The eidos definition (fields to bind)

      - source: gather
        query: "eidos: widget"
        as: widget_vocabulary
        description: Available widget types

      - source: static
        content: |
          ## Binding Syntax Reference

          ### Entity Data
          - {field_name} — Direct field access
          - {field.nested} — Nested field access
          - {id} — Entity ID
          - {eidos} — Entity type

          ### Form State (NO braces)
          - $form.field — Form input value
          - $event.target.value — Event value

          ### Conditionals (when:)
          - when: "field_name" — Truthy check
          - when: "status == 'active'" — Equality
          - when: "status != 'pending'" — Inequality

          ## Widget Categories

          ### Layout (support children)
          - card: variant, padding, on_click, on_click_params
          - stack: gap, align
          - row: gap, align, justify
          - scroll: auto_scroll_bottom

          ### Content (no children)
          - text: content, variant
          - badge: content, variant
          - icon: name, size
          - avatar: name, src, size
          - heading: content, level

          ### Interactive
          - button: label, variant, on_click, on_click_params

          ### Form
          - select: field, options
          - textarea: field, placeholder, rows
          - input: field, placeholder, type

          ### Iteration (on any widget node)
          - each: "{array_field}" — children repeat per item
          - each_empty: "message" — shown when array is empty
          - Entity-level iteration uses collection modes (item_spec_id + source_query)

          ## Common Mistakes to Avoid
          - WRONG: {$form.field} — CORRECT: $form.field
          - WRONG: widget: for-each — DISSOLVED: use `each` on any widget, or collection modes
          - WRONG: widget: include — DISSOLVED: use collection modes with item_spec_id
          - WRONG: content: for buttons — CORRECT: label:
        as: binding_rules

      - source: gather
        query: "eidos: render-spec"
        filter: ".data.variant == '$variant'"
        limit: 3
        as: example_specs
        description: Existing render-specs for pattern reference

    output_schema:
      type: object
      properties:
        eidos:
          type: string
          const: render-spec
        id:
          type: string
          pattern: "^render-spec/.*"
        data:
          type: object
          required: [name, target_eidos, variant, layout]
```

---

## generate-render-spec Praxis

```yaml
- eidos: praxis
  id: praxis/demiurge/generate-render-spec
  data:
    topos: demiurge
    name: generate-render-spec
    visible: true
    tier: 3
    description: |
      Generate a render-spec for an eidos using inference-context.

      Surfaces widget vocabulary, binding rules, and examples to the inference.
      Returns an artifact containing the generated render-spec,
      ready for review and actualization.

    params:
      - name: eidos_name
        type: string
        required: true
        description: The eidos to create a render-spec for

      - name: variant
        type: string
        required: true
        description: Render variant (card, list-item, detail, panel)

      - name: purpose
        type: string
        required: true
        description: What this render-spec should accomplish

      - name: interactive
        type: boolean
        required: false
        default: false
        description: Include click handlers for actions

      - name: topos_context
        type: string
        required: false
        description: Oikos for domain-specific theoria

    steps:
      - step: compose
        typos_id: typos-inference-render-spec
        inputs:
          eidos_name: "$eidos_name"
          variant: "$variant"
          purpose: "$purpose"
          interactive: "$interactive"
          topos_context: "$topos_context"
        bind_to: inference_context

      - step: call
        praxis: manteia/governed-inference
        params:
          context: "$inference_context"
          output_schema: "$inference_context.output_schema"
        bind_to: generated

      - step: call
        praxis: demiurge/validate-render-spec
        params:
          render_spec: "$generated"
        bind_to: validation

      - step: assert
        condition: "$validation.valid"
        message: "Generated render-spec has validation errors: $validation.errors"

      - step: compose
        typos_id: typos-def-artifact
        inputs:
          id: "artifact/render-spec/$eidos_name-$variant"
          content_type: render-spec
          content: "$generated"
          source: generation
          metadata:
            generator: demiurge/generate-render-spec
            eidos_name: "$eidos_name"
            variant: "$variant"
        bind_to: artifact

      - step: return
        value:
          artifact: "$artifact"
          render_spec: "$generated"
          validation: "$validation"
```

---

## validate-render-spec Praxis

```yaml
- eidos: praxis
  id: praxis/demiurge/validate-render-spec
  data:
    topos: demiurge
    name: validate-render-spec
    visible: true
    tier: 2
    description: |
      Validate a render-spec for correctness.

      Checks:
      - Widget types exist in vocabulary
      - Props match widget schemas
      - Binding syntax is valid
      - Required props are present

    params:
      - name: render_spec
        type: object
        required: true
        description: The render-spec to validate

    steps:
      - step: set
        bindings:
          errors: []
          valid: true

      # Gather valid widget types
      - step: gather
        query:
          eidos: widget
        bind_to: widgets

      - step: map
        source: "$widgets"
        expression: ".data.widget_type"
        bind_to: valid_widget_types

      # Recursive validation would go here
      # For now, basic structure check

      - step: assert
        condition: "$render_spec.data.layout"
        message: "render-spec must have layout"
        bind_to: has_layout

      - step: switch
        cases:
          - when: "!$has_layout"
            then:
              - step: append
                to: errors
                value: "Missing layout array"
              - step: set
                bindings:
                  valid: false

      - step: return
        value:
          valid: "$valid"
          errors: "$errors"
          widget_types: "$valid_widget_types"
```

---

## discover-widgets Praxis

```yaml
- eidos: praxis
  id: praxis/demiurge/discover-widgets
  data:
    topos: demiurge
    name: discover-widgets
    visible: true
    tier: 1
    description: |
      Discover available widget types from thyra.

      Returns widget vocabulary with types and props schemas.
      Useful for understanding what's available before generation.

    params:
      - name: category
        type: string
        required: false
        description: Filter by category (layout, display, interactive, form, composition, feedback, overlay, navigation, utility)

    steps:
      - step: gather
        query:
          eidos: widget
        bind_to: all_widgets

      - step: filter
        source: "$all_widgets"
        condition: "$category ? .data.category == $category : true"
        bind_to: widgets

      - step: map
        source: "$widgets"
        expression: |
          {
            widget_type: .data.widget_type,
            category: .data.category,
            props_schema: .data.props_schema,
            supports_children: .data.supports_children,
            description: .data.description
          }
        bind_to: result

      - step: return
        value: "$result"
```

---

## Integration with develop-topos-from-design

When developing a topos, render-specs can be generated alongside definitions:

```yaml
# In develop-topos-from-design, after generating eide:
- step: for_each
  source: "$design.renderable"
  as: renderable_spec
  steps:
    - step: call
      praxis: demiurge/generate-render-spec
      params:
        eidos_name: "$renderable_spec.eidos"
        variant: "card"
        purpose: "$renderable_spec.description"
        interactive: true
        topos_context: "$topos_name"
      bind_to: result

    - step: append
      to: render_spec_artifacts
      value: "$result.artifact"
```

---

## Agent Instructions

When generating render-specs, follow these guidelines:

### 1. Understand the Entity First

Read the eidos definition to know:
- What fields exist and their types
- Which fields are required vs optional
- What the entity represents semantically

### 2. Choose the Right Variant

| Variant | When to Use |
|---------|-------------|
| `card` | Single entity in a list, clickable tiles |
| `list-item` | Compact rows in dense lists |
| `detail` | Full entity view with all fields |
| `panel` | Compound views, dashboards, not tied to single entity |

### 3. Use Appropriate Widgets

- **For text:** Use `text` with appropriate variant
- **For status:** Use `badge` with semantic variant
- **For actions:** Use `button` with `on_click`
- **For entity lists:** Use collection modes (`item_spec_id` + `source_query`)
- **For field arrays:** Use `each` on any widget node
- **For layout:** Nest `stack` (vertical) and `row` (horizontal)

### 4. Make It Interactive

When `interactive: true`:
- Add `on_click` to cards for navigation
- Add action buttons for state changes
- Bind click params to entity fields

### 5. Handle Empty States

Always provide `each_empty` when using `each`:

```yaml
- widget: stack
  each: "{items}"
  each_empty: "No items to display"
  children:
    - widget: text
      props:
        content: "{item.name}"
```

### 6. Use Conditional Display

Show/hide widgets based on entity state:

```yaml
- widget: text
  when: "description"  # Only show if exists
  props:
    content: "{description}"
```

---

## Demonstration: Politeia Governance UI

Generate render-specs for politeia eide to bring governance to life:

| Eidos | Render-Spec | Purpose |
|-------|-------------|---------|
| attainment | `render-spec/attainment-card` | Show capability with icon |
| affordance | `render-spec/affordance-card` | Clickable action button |
| invitation | `render-spec/invitation-card` | Accept/decline pending invite |
| membership-event | `render-spec/membership-event-item` | Audit log entry |

**Result:** A governance panel showing:
- Your attainments (what you can do)
- Available affordances (actions you can take right now)
- Pending invitations (with accept/decline)
- Recent membership events (who joined/left)

This demonstrates:
1. Render-spec generation at scale (4 eide)
2. Interactive UI (click handlers on affordances)
3. Compound leverage (one generation pattern → many UIs)

---

## Files to Create

| File | Purpose |
|------|---------|
| `demiurge/typos/thyra-generation.yaml` | typos-inference-render-spec |
| `demiurge/praxeis/render-spec.yaml` | New praxeis (generate, validate, discover) |
| `demiurge/manifest.yaml` | Declare new praxeis |

---

## Compound Leverage

One `generate-render-spec` investment yields:

1. **Any new eidos gets a UI** — No manual YAML authoring
2. **Consistent patterns** — AI learns from existing specs
3. **Interactive by default** — Click handlers when appropriate
4. **Theoria-informed** — Domain knowledge surfaces into generation
5. **Validatable** — `validate-render-spec` catches errors before runtime

The spiral completes: **Intent → Generate → Review → Actualize → See it in thyra.**

---

## References

- [RENDER-SPEC-GUIDE.md](RENDER-SPEC-GUIDE.md) — Complete authoring reference
- [Widget Vocabulary](../thyra/eide/widget.yaml) — All widgets with examples
- [Politeia Render-Specs](../politeia/render-specs/) — Working examples

---

*Composed in service of the kosmogonia.*
*The craftsman now sees. What exists can appear. What appears can be touched.*
