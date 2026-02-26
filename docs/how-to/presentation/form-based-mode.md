# Creating a Form-Based Mode

*How to build modes where users type freely and values are captured on action.*

---

## When to Use This Pattern

Use the form pattern when:
- Users type into text inputs and submit on action (button click)
- You don't need per-keystroke updates or real-time feedback
- The mode has a "compose and send" interaction

Use the [overlay pattern](voice-authoring.md) instead when:
- Multiple sources write to the same field (voice transcription + manual typing)
- You need per-keystroke reactivity (live preview, search-as-you-type)

---

## Step 1: Create the Render-Spec

Wrap your interactive area in a `form` widget. Every input inside it must have a `name` prop.

```yaml
# genesis/my-topos/render-specs/my-composer.yaml
entities:
  - eidos: render-spec
    id: render-spec/my-composer
    data:
      name: my-composer
      description: Compose and submit content
      target_eidos: my-entity
      variant: fixture

      layout:
        - widget: form
          props:
            class: my-composer
          children:
            - widget: row
              props:
                align: center
                gap: sm
                padding: sm
              children:
                - widget: textarea
                  props:
                    name: content              # Required — identifies field in form
                    value: "{content}"          # Pre-populate from entity data
                    placeholder: "Type here..."
                    rows: 2

                - widget: button
                  props:
                    variant: primary
                    on_click: my-topos/submit
                    on_click_params:
                      entity_id: "{id}"
                      content: $form.content   # Read from DOM at click time
                  children:
                    - widget: icon
                      props:
                        name: arrow-up
                        size: md
```

Key points:
- `form` widget wraps everything — provides `FormRegistrationContext`
- `textarea` has `name: content` — registers a DOM ref getter with the form
- `value: "{content}"` — pre-populates from entity data (render-time binding)
- `$form.content` — reads textarea DOM value at button click (event-time binding)
- No `on_input` handler — no per-keystroke events

## Step 2: Create the Mode

```yaml
# genesis/my-topos/modes/my-composer.yaml
entities:
  - eidos: mode
    id: mode/my-composer
    data:
      name: my-composer
      topos: my-topos
      render_spec_id: render-spec/my-composer
      source_entity_id: my-entity/default
      spatial:
        position: bottom
        height: 120
```

`source_entity_id` binds the mode to a specific entity. The layout engine fetches this entity and passes it to the render-spec.

## Step 3: Add to Thyra Config

```yaml
# In your thyra-config
active_modes:
  - mode/my-feed
  - mode/my-composer      # Your new mode
```

## Step 4: Create the Praxis

The praxis receives `$form.content` as a regular param:

```yaml
- eidos: praxis
  id: praxis/my-topos/submit
  data:
    name: submit
    topos: my-topos
    description: Submit composed content
    params:
      - name: entity_id
        type: string
        required: true
      - name: content
        type: string
        required: true
    steps:
      - type: create-entity
        # ... your logic
```

---

## How It Works Internally

```
User types "hello world" into textarea
  → No events fire, no state changes
  → DOM textarea.value = "hello world"

User clicks submit button
  → Handler fires with params: { entity_id: "{id}", content: "$form.content" }
  → resolveEventBindings runs:
      entity_id: already resolved at render time → "my-entity/default"
      content: "$form.content" → formContext.getValue("content")
        → FormRegistrationContext.fields.get("content")()
        → textareaRef.value
        → "hello world"
  → execute("my-topos/submit", { entity_id: "my-entity/default", content: "hello world" })
```

---

## Multiple Form Fields

Forms support multiple named fields:

```yaml
- widget: form
  children:
    - widget: input
      props:
        name: title
        value: "{title}"
        placeholder: "Title"

    - widget: textarea
      props:
        name: body
        value: "{body}"
        placeholder: "Body text..."
        rows: 4

    - widget: button
      props:
        on_click: my-topos/save
        on_click_params:
          entity_id: "{id}"
          title: $form.title
          body: $form.body
```

Each `$form.fieldname` reads the corresponding named input's DOM value at click time.

---

## After Submit: Clearing the Form

Two strategies for clearing form fields after submission:

### Immediate reset (recommended)

Add `reset_form: true` to the submit button. After the handler executes successfully, all registered form fields clear immediately via their DOM refs — no server roundtrip needed:

```yaml
- widget: button
  props:
    on_click: my-topos/submit
    on_click_params:
      content: $form.content
    reset_form: true
```

TextareaWidget registers a resetter that sets `textareaRef.value = ""`. The form clears as soon as the praxis call succeeds, before the entity update arrives via WebSocket.

### Entity-driven reset

When the praxis completes, the server updates (or clears) the entity. The WebSocket event triggers a re-fetch. The render-spec re-renders with the new entity data, and `value: "{content}"` updates the textarea to reflect the new state (typically empty after a clear).

This works but can feel laggy — and if the entity value was already empty before the praxis ran, SolidJS may skip the DOM update entirely (same value === no reactive change). Use `reset_form: true` to avoid this edge case.

---

## Related

- [Two-Phase Binding Resolution](../../explanation/architecture/two-phase-bindings.md) — Why `{field}` and `$form.*` resolve differently
- [Voice Authoring](voice-authoring.md) — The alternative overlay pattern for real-time input
- [Mode Development Guide](mode-development.md) — General mode creation

---

*Guide for the form-based authoring pattern in Thyra.*
