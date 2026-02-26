# How-To: Mode Development

Task-oriented recipes for creating and extending modes. For conceptual background, see [Modes and Topoi](../../explanation/presentation/modes-and-topoi.md) and [Modes as Topoi](../../explanation/presentation/modes-as-topoi.md). For the full UI ontology, see [Thyra Topos](../../explanation/presentation/thyra-topos.md).

---

## Creating a Mode (Complete Walkthrough)

### 1. Define the Mode Entity

```yaml
# genesis/my-topos/modes/my-mode.yaml
entities:
  - eidos: mode
    id: mode/my-view
    data:
      name: my-view
      topos: my-topos
      description: Interactive view of my entities
      render_spec_id: render-spec/my-view
      spatial:
        position: center
        height: fill
      source_query: "gather(eidos: my-eidos, sort: name, order: asc)"
```

The `source_query` supports `sort`, `order`, and `limit` parameters:

```yaml
# Sort by field, ascending (default)
source_query: "gather(eidos: phasis, sort: expressed_at, order: asc)"

# Descending, with limit
source_query: "gather(eidos: theoria, sort: domain, order: desc, limit: 50)"

# No sort (legacy, still works)
source_query: "gather(eidos: oikos)"
```

### 2. Create the Render-Spec (or Item-Spec)

Each mode has exactly one render-spec. No `when` conditions — the render-spec is a definitive widget tree for this mode.

**Mode patterns determine how entities are rendered:**

| Pattern | Mode Fields | When to Use |
|---------|-------------|-------------|
| **Singleton** | `render_spec_id` | Single entity or dashboard view |
| **Collection** | `item_spec_id` + `arrangement` + optional `chrome_spec_id` | List/grid of entities from `source_query` |
| **Compound** | `sections[]` | Multiple sub-regions within one mode |

For **collection modes** (the most common pattern), the mode itself handles iteration — no iteration widget needed in the spec. The mode's `source_query` provides entities, and each entity is rendered via `item_spec_id`:

```yaml
# genesis/my-topos/modes/my-mode.yaml (collection pattern)
entities:
  - eidos: mode
    id: mode/my-view
    data:
      name: my-view
      topos: my-topos
      description: Interactive view of my entities
      item_spec_id: render-spec/my-card
      arrangement: scroll
      chrome_spec_id: render-spec/my-view-chrome  # optional header/footer
      spatial:
        position: center
        height: fill
      source_query: "gather(eidos: my-eidos, sort: name, order: asc)"
```

The `arrangement` controls how items are laid out:

| Arrangement | Behavior |
|-------------|----------|
| `scroll` | Vertical scrollable list |
| `scroll-bottom` | Scrollable list, auto-scrolls to latest item |
| `stack` | Vertical stack (no scroll) |
| `list` | Simple list layout |
| `grid` | CSS grid layout |

For **singleton modes**, the render-spec is a complete widget tree:

```yaml
# genesis/my-topos/render-specs/my-dashboard.yaml
entities:
  - eidos: render-spec
    id: render-spec/my-dashboard
    data:
      name: my-dashboard
      description: Dashboard view
      target_eidos: null
      variant: panel

      layout:
        - widget: stack
          props:
            gap: md
          children:
            - widget: heading
              props:
                content: "Overview"
            - widget: text
              props:
                content: "Welcome to my topos"
```

### 3. Add Substrate Requirements (If Needed)

If the mode needs substrate access (microphone, network, etc.), define an infrastructure mode (a mode with a `substrate` field):

```yaml
# genesis/my-topos/modes/my-substrate.yaml
entities:
  - eidos: mode
    id: mode/my-substrate
    data:
      substrate: my-substrate
      operations:
        manifest:
          handler: my_topos::manifest
          params: [config_param]
        sense:
          handler: my_topos::sense
          returns: [status]
        unmanifest:
          handler: my_topos::unmanifest
```

Then reference it in the presentation mode:

```yaml
requires:
  - mode/my-substrate
```

### 4. Add to a Thyra Configuration

```yaml
# genesis/thyra/configs/workspace.yaml
entities:
  - eidos: thyra-config
    id: thyra-config/workspace
    data:
      name: workspace
      window:
        size: full
      active_modes:
        - mode/oikos-nav
        - mode/phasis-feed
        - mode/theoria-sidebar
        - mode/compose-full
        - mode/my-view          # Your new mode
```

---

## Recipes

### Create a Card Render-Spec

**Goal:** Create a card that displays a single entity.

```yaml
entities:
  - eidos: render-spec
    id: render-spec/my-card
    data:
      name: my-card
      target_eidos: my-eidos    # Which eidos this renders
      variant: card

      layout:
        - widget: card
          props:
            variant: bordered
            padding: sm
            on_click: ui/set-selection
            on_click_params:
              selection_type: active-item
              entity_id: "{id}"
          children:
            - widget: row
              props:
                gap: sm
                align: center
              children:
                - widget: icon
                  props:
                    name: cube
                    size: sm
                - widget: text
                  props:
                    content: "{name}"
                    variant: emphasis
```

### Create a Collection Mode with Empty State

**Goal:** Render a list of entities with a message when empty.

Use the **collection mode pattern** — the mode iterates entities via `item_spec_id`. Empty state is handled by the `arrangement`:

```yaml
# Mode definition (handles iteration)
- eidos: mode
  id: mode/item-list
  data:
    name: item-list
    topos: my-topos
    item_spec_id: render-spec/item-card
    arrangement: scroll
    source_query: "gather(eidos: item)"
    spatial:
      position: center
```

For **field-level iteration** (iterating over an array field within a single entity), use the `each` property on any widget node:

```yaml
# Render-spec with field-level iteration via `each`
layout:
  - widget: scroll
    children:
      - widget: card
        each: "{tags}"
        each_empty: "No tags assigned"
        props:
          padding: sm
        children:
          - widget: text
            props:
              content: "{.}"   # {.} binds to the current item for primitives
```

### Add Selection Handling

**Goal:** Make items selectable with visual feedback.

In the card render-spec:

```yaml
- widget: card
  props:
    variant: bordered
    on_click: ui/set-selection
    on_click_params:
      selection_type: active-node    # Namespaced selection key
      entity_id: "{id}"
```

In the detail render-spec, reference the selected item:

```yaml
- widget: heading
  props:
    content: "{selected_node.name}"
```

### Add Conditional Rendering

**Goal:** Show a widget only when a condition is true.

Use the `when` attribute:

```yaml
- widget: badge
  when: "{status} == 'error'"
  props:
    content: "Error"
    variant: error

- widget: text
  when: "{error_message}"
  props:
    content: "{error_message}"
    variant: error
```

### Add a Status Indicator

**Goal:** Show online/offline/error status visually.

```yaml
- widget: status-indicator
  props:
    status: "{status}"      # online, offline, error, unknown
    variant: dot            # or badge
```

### Iterate Over a Field Array

**Goal:** Render each item in an entity's array field.

Use the `each` property on any widget node. The widget renders once, and its children repeat per item. Use `{.}` to bind to the item itself (for primitives like strings), or `{field}` for object items:

```yaml
# Iterate over an array of service objects
- widget: card
  each: "{services}"
  each_empty: "No services registered"
  props:
    padding: sm
  children:
    - widget: text
      props:
        content: "{name}"      # field on each service object
    - widget: badge
      props:
        content: "{status}"
```

### Access Data from Bonded Entities

**Goal:** Display data from a related entity via bond traversal.

Use `@bond-name` to follow a bond from the current entity and read the target entity's data. The bond name is the desmos name. One hop only.

```yaml
# Render-spec for accumulation entity
# Reads audio-source state via fed-by-audio bond
layout:
  - widget: row
    props:
      gap: sm
      align: center
    children:
      # Mic button — shows state from bonded audio-source
      - widget: button
        props:
          variant: ghost
          on_click: soma/toggle-audio-intent
          on_click_params:
            entity_id: "{@fed-by-audio.id}"
        children:
          - widget: icon
            props:
              name: mic
              size: md
      # Status badge — only shown when audio is capturing
      - widget: badge
        when: "@fed-by-audio.data.intent == 'capturing'"
        props:
          content: "Live"
          variant: success
```

**Prerequisites:** The entity must have a bond with the given desmos name. Define the desmos in genesis and create the bond instance on the entity.

**Reactivity:** When the bonded entity changes, the render-spec re-renders automatically — no extra wiring needed.

### Declare Dependencies in Manifest

**Goal:** Ensure the mode loads after its dependencies.

```yaml
depends_on:
  - soma       # For node, service-instance eide
  - politeia   # For oikos eide
  - thyra      # Always needed for rendering
```

The `surfaces_consumed` field documents which eide the mode uses:

```yaml
surfaces_consumed:
  - node
  - service-instance
  - oikos
```

---

## Widget Vocabulary

Modes use the widget vocabulary defined in `genesis/thyra/eide/widget.yaml`:

| Widget | Purpose |
|--------|---------|
| `stack` | Vertical layout |
| `row` | Horizontal layout |
| `card` | Container with styling |
| `text` | Text content |
| `heading` | Headers (h1-h6) |
| `badge` | Status labels |
| `button` | Interactive buttons |
| `textarea` | Multi-line text input |
| `icon` | Icons (Lucide names) |
| `form` | Form context (captures input values at action time, supports `reset_form` for immediate clearing) |
| `artifact` | Composed content via demiurge |
| `spinner` | Loading indicator |
| `scroll` | Scrollable container |
| `status-indicator` | Online/offline/error states |

**Universal widget properties** (available on any widget node):

| Property | Purpose |
|----------|---------|
| `each` | Field-level iteration — `each: "{array_field}"` repeats children per item |
| `each_empty` | Message shown when the `each` array is empty |
| `when` | Conditional rendering expression |

See [Mode Reference](../../reference/presentation/mode-reference.md) for full widget and render-spec schemas.

---

## Binding Syntax

| Pattern | Phase | Usage | Example |
|---------|-------|-------|---------|
| `{field}` | Render-time | Entity data | `{name}`, `{status}` |
| `{.}` | Render-time | Current item in `each` iteration (primitives) | `{.}` for strings/numbers |
| `{@bond-name.path}` | Render-time | Bonded entity data | `{@fed-by-audio.data.intent}` |
| `$event.target.value` | Event-time | DOM event values | In on_input handlers |
| `$form.field` | Event-time | Form input at action time | `$form.content` |

See [Two-Phase Bindings](../../explanation/architecture/two-phase-bindings.md) for the full binding resolution model.

---

## Data Flow

```
Thyra config → active modes → spatial declarations → layout
                    |
              each mode:
                render-spec → widget tree → entity bindings → DOM
                required modes → manifest substrates
```

---

## Example: Compose Bar Modes

The compose bar has two modes for the same spatial position:

**mode/compose-full** — Full compose bar with mic controls, transcription toggle, stance badge, clarify, express, and editable textarea. Bound to `accumulation/default`.

**mode/compose-transcribing** — Same control row, but textarea is readonly with 'Transcribing...' placeholder. Bound to `accumulation/default`.

Switching between them is reflex-driven: when `transcriber/default.desired_state` changes, a reflex swaps the active mode in the thyra-config. No field conditionals.

---

## Testing a Mode

1. Add mode entity to genesis
2. Add render-spec to genesis
3. Reference mode in a thyra-config's `active_modes`
4. Delete database and restart: `just dev`

### Debugging

- Check console for render-spec not found errors
- Verify render-spec IDs match mode's `render_spec_id`
- Ensure entity bindings resolve (check `{field}` values)
- Verify substrate mode handlers exist in Rust if substrates required

---

## Checklist

- [ ] Mode entity with render_spec_id, spatial declaration
- [ ] Render-spec with widget tree (`when` for presentation variation only)
- [ ] Form widget wrapping inputs if read-at-action-time needed (see [Form-Based Mode](form-based-mode.md))
- [ ] `reset_form: true` on submit button if immediate clearing needed
- [ ] Infrastructure mode (eidos: mode with substrate) if substrate needed
- [ ] Mode referenced in thyra-config active_modes
- [ ] Seed data for development testing
- [ ] Dependencies declared in topos manifest

---

## Related

- [Modes and Topoi](../../explanation/presentation/modes-and-topoi.md) — Why modes are topos presence
- [Modes as Topoi](../../explanation/presentation/modes-as-topoi.md) — Why modes are independent packages
- [Thyra Topos](../../explanation/presentation/thyra-topos.md) — Full UI ontology design
- [Mode Reference](../../reference/presentation/mode-reference.md) — Widget and render-spec schemas
- [Voice Authoring](voice-authoring.md) — Voice-specific mode recipe
- [Form-Based Mode](form-based-mode.md) — Form pattern recipe
- [Create Artifact Mode](create-artifact-mode.md) — Artifact widget in a mode
