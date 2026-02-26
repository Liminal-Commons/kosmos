# Two-Phase Binding Resolution

*Why `{field}` and `$form.content` resolve at different times, and what breaks if you mix them.*

---

## The Two Phases

Thyra's binding system resolves values in two distinct phases. The phase determines **when** the value is read.

| Syntax | Phase | When It Resolves | Source |
|--------|-------|-----------------|--------|
| `{field}` | Render-time | Every re-render (entity data changes) | `entity.data.field` |
| `{id}`, `{eidos}` | Render-time | Every re-render | Entity identity |
| `{@bond-name.path}` | Render-time | Every re-render (bonded entity changes) | Traversed entity via bond graph |
| `$form.field` | Event-time | When handler fires (click, submit) | DOM element via FormRegistrationContext |
| `$event.path` | Event-time | When handler fires | DOM event object |

### Phase 1: Render-Time (`resolveProps`)

When the widget tree renders, `resolveProps()` in [bindings.ts](../../app/src/lib/bindings.ts) walks all props and resolves `{field}` placeholders against entity data:

```yaml
# Render-spec
- widget: text
  props:
    content: "{title}"        # Resolved NOW from entity.data.title
```

This runs on every render cycle. When entity data changes (via WebSocket event or overlay), the binding produces a new value and the widget updates.

#### Bond Traversal (`@bond-name`)

Bond bindings are also render-time. When `resolveProps()` encounters an `@` prefix, it:

1. Extracts the desmos name (e.g. `@fed-by-audio.data.intent` → desmos `fed-by-audio`)
2. Looks up the bonded entity in `BondContext` — a cache populated once per render cycle by scanning the render-spec for all `@` references, then batch-fetching via `traceBonds()` + `findEntity()`
3. Resolves the remaining path (`data.intent`) against the bonded entity

Re-renders trigger when the bonded entity changes: `RenderSpecRenderer` subscribes to `onEntityChange` for each bonded entity ID. When the bonded entity updates, the version signal increments and the widget tree re-evaluates.

If a bond doesn't exist (entity has no bond with that desmos name), the binding returns `undefined` — the widget renders empty, and `when` conditions treat it as falsy.

### Phase 2: Event-Time (`resolveEventBindings`)

When a handler fires (button click, input event), `resolveEventBindings()` in [executor-context.tsx](../../app/src/lib/executor-context.tsx) resolves `$form.*` and `$event.*` bindings:

```yaml
# Render-spec
- widget: button
  props:
    on_click: thyra/commit-phasis
    on_click_params:
      accumulation_id: "{id}"       # Phase 1 — resolved at render
      content: $form.content        # Phase 2 — resolved at CLICK
```

`$form.content` reads the textarea's current DOM value at the moment the user clicks. Not when the component renders. Not when the user typed. At click time.

---

## How `$form.*` Works

The form directive creates a bridge between DOM elements and the binding system:

```
FormWidget                          TextareaWidget
  │                                    │
  ├─ provides FormRegistrationContext  │
  │                                    ├─ calls registerField("content", () => textareaRef.value)
  │                                    │
  └─ getValue("content") ─────────────┘
       ↑                                    calls the getter → reads DOM
       │
   resolveEventBindings("$form.content")
       ↑
   handler fires (user clicks button)
```

1. `FormWidget` provides `FormRegistrationContext` to children
2. `TextareaWidget` registers a getter: `() => textareaRef.value`
3. User types freely (no events fire, no state updates)
4. User clicks button — handler calls `resolveEventBindings`
5. `$form.content` calls `formContext.getValue("content")`
6. The getter reads `textareaRef.value` — the current DOM text
7. That value is passed to the praxis

---

## How `$event.*` Works

Event bindings extract values from the DOM event at handler execution:

```yaml
on_input: ui/update-entity-field
on_input_params:
  value: $event.target.value    # Reads event.target.value when input fires
```

Supports nested paths: `$event.target.value`, `$event.detail.data`, or plain `$event` for the entire event object.

---

## The Critical Mistake: `{$form.content}`

**Never put `$form.*` inside braces.** Here's why:

```yaml
# WRONG — resolves at render time
content: "{$form.content}"
# resolveBinding() looks for entity.data["$form.content"] → undefined → ""

# RIGHT — resolves at event time
content: $form.content
# Survives resolveProps unchanged (no braces, not an on_* key)
# Resolved by resolveEventBindings at click time
```

`$form.*` strings survive `resolveProps` because they contain no `{` braces and aren't `on_*` keys. They pass through as literal strings into the handler's params, then `resolveEventBindings` recognizes and resolves them when the handler fires.

---

## When to Use Which

### Use `{field}` when:
- Displaying entity data (text content, badges, status)
- The value should update live as entity changes
- Pre-populating form inputs with current entity state

### Use `@bond-name` when:
- Displaying data from a related entity (mic state, transcriber status)
- The value should update live as the bonded entity changes
- One entity's render-spec needs to show another entity's state
- The entities are connected by a desmos in the bond graph

### Use `$form.field` when:
- Reading user input at action time (send button, submit)
- You want zero per-keystroke overhead
- The value lives in the DOM, not in entity data

### Use `$event.*` when:
- Responding to DOM events (input, change, click)
- You need the event's live value per-keystroke (voice-bar overlay pattern)
- Updating entity overlays for real-time feedback

---

## The Two Authoring Patterns

These two phases enable two distinct authoring patterns in Thyra:

### Text Compose (form pattern)
```yaml
- widget: form
  children:
    - widget: textarea
      props:
        name: content           # Registers with form context
        value: "{content}"      # Shows entity data (render-time)
    - widget: button
      props:
        on_click: thyra/commit-phasis
        on_click_params:
          content: $form.content  # Reads textarea at click (event-time)
```

No per-keystroke events. User types freely. Value captured at send.

### Voice Bar (overlay pattern)
```yaml
- widget: textarea
  props:
    name: content
    value: "{content}"          # Shows entity data (render-time)
    on_input: ui/update-entity-field
    on_input_params:
      value: $event.target.value  # Reads each keystroke (event-time)
```

Per-keystroke overlay updates. Needed because voice transcription writes to entity data and the textarea must reflect both sources.

---

## Related

- [Entity Overlays](../presentation/entity-overlays.md) — The overlay pattern used by voice-bar
- [Phasis Workspace Reference](../../reference/domain/phasis-workspace.md) — Accumulation schema
- [Mode Development Guide](../../how-to/presentation/mode-development.md) — Creating modes with these patterns

---

*Understanding crystallized from the surgical cleanup — aligning typing behavior with binding semantics.*
