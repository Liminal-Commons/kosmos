# Thyra Topos Design

*The UI ontology for kosmos — what CAN appear and how.*

**Status:** Revised draft — addresses review feedback
**Audience:** Kosmos dev team
**Depends on:** arche (eidos, stoicheion foundations)
**Revision:** Added rationale section, phased migration plan, prototype validation

---

## Overview

Thyra-as-topos defines the vocabulary for user interfaces. It declares:
- **What structures exist** (layouts, panels, regions, widgets)
- **What operations exist** (ui stoicheia)
- **How entities render** (render-spec format)

The interpreter (thyra-as-codebase in chora) reads these declarations and produces actual UI. This document defines only the kosmos side.

---

## Design Principles

1. **Widgets are primitives** — A small set (~20) of atomic UI elements
2. **Render-specs compose widgets** — Declarative templates, not code
3. **Each topos owns its render-specs** — nous defines how theoria renders
4. **UI operations are stoicheia** — Composable into praxeis
5. **No hardcoded behaviors** — Everything declared, nothing implicit

---

## Rationale: Architectural Questions

This section addresses architectural questions raised during review.

### Why Dissolve Opsis?

Opsis was created to extract "rendering" from thyra. The extraction made sense: separate the "how to display" concern. But experience revealed a problem: **there is no "rendering domain."**

Consider: what does opsis *know*? It knows about layouts, panels, and generic renderers. But it doesn't know what a theoria looks like, or how an oikos should display, or what makes a phasis bubble. That knowledge lives in the domain topoi.

Opsis became an awkward middle layer:
- It couldn't own domain-specific render-specs (those belong to domain topoi)
- It duplicated praxeis that thyra also needed
- Its generic `renderer` and `render-type` eide added indirection without value

The dissolution follows from recognizing two distinct concerns:

| Concern | Owner | What It Knows |
|---------|-------|---------------|
| **Presentation infrastructure** | thyra | Widget primitives, layout, panels, UI stoicheia |
| **How entities appear** | domain topoi | Render-specs for their eide |

There's no third layer. Opsis was trying to be something that doesn't exist.

**Alternative considered:** Clean up opsis instead of dissolving it. But cleaning up would mean moving render-specs to domain topoi anyway, removing duplicated praxeis, and removing `renderer`/`render-type` indirection. What remains? Layout and panel, which belong in thyra (presentation infrastructure). The "cleaned up" opsis IS thyra.

### Why UI Stoicheia (Not Praxeis)?

The feedback asks: should UI operations be stoicheia (interpreter primitives) or praxeis (composed from existing stoicheia)?

The answer follows from what stoicheia ARE. From Kosmogonia:

> **Stoicheion** — atomic, typed operation steps (the vocabulary)
> **Praxis** — composed sequences of stoicheia (the sentences)

UI operations like `navigate`, `set-selection`, `notify`, `modal` are:

1. **Atomic** — They cannot be decomposed into smaller UI operations
2. **Require substrate** — They need browser DOM APIs (not graph operations)
3. **Different tier** — They execute in the interpreter, not in kosmos

Compare to existing stoicheia tiers:

| Tier | Examples | Substrate |
|------|----------|-----------|
| Elemental (0) | `filter`, `sort`, `concat` | Pure computation |
| Aggregate (1) | `reduce`, `group-by` | Collection operations |
| Compositional (2) | `arise`, `bind`, `loose` | Kosmos dynamis |
| Generative (3) | `generate`, `shell` | Chora dynamis |
| **UI** | `navigate`, `notify`, `modal` | Browser dynamis |

UI operations draw on **browser dynamis** — the ability to manipulate DOM, show modals, trigger notifications. This is a substrate capability, like how `shell` draws on OS dynamis.

A praxis *composes* stoicheia. But you can't compose `notify` from graph operations — you need the browser. So `notify` must be a stoicheion.

**Example:** A praxis might be `show-delete-confirmation`:

```yaml
steps:
  - stoicheion: ui/confirm
    params:
      title: "Delete theoria?"
      message: "This cannot be undone."
      destructive: true
    output: confirmed
  - stoicheion: nous/delete-theoria
    when: "{confirmed}"
    params:
      theoria_id: "{theoria_id}"
```

The praxis composes a UI stoicheion (`confirm`) with a domain stoicheion (`delete-theoria`). The stoicheia are the primitives; the praxis is the composition.

### Domain Coupling to Widget Vocabulary

The feedback notes: if nous owns `render-spec/theoria-card`, does nous need to understand widget vocabulary? This creates coupling.

**Yes, this coupling is intentional.** And it's the same pattern used throughout kosmos:

| Domain Topos | Uses From |
|--------------|-----------|
| nous | Core desmoi (`belongs-to`, `authored-by`) |
| politeia | Core eide (`oikos`, `prosopon`) |
| All topoi | Archē stoicheia (`arise`, `bind`) |

Domain topoi depend on foundational vocabulary. Widgets are presentation vocabulary — a stable set of primitives like HTML elements. Domain topoi use this vocabulary to describe how their entities appear.

The coupling is **minimal and stable**:
- ~20 widget types (less than HTML element count)
- Widget props follow consistent patterns
- Changes to widget vocabulary are rare (like HTML changes)

The alternative — each topos defining its own rendering primitives — would be far worse. Inconsistent UIs, duplicated concepts, no theming.

**Key insight:** Widgets are to presentation what desmoi are to relationships. Every topos uses `belongs-to`; every topos uses `text` and `card`. Shared vocabulary enables composition.

---

## Eide

### eidos/widget

The atomic UI primitives. These are the building blocks that render-specs compose.

```yaml
- eidos: eidos
  id: eidos/widget
  data:
    name: widget
    description: |
      An atomic UI primitive that can be composed in render-specs.
      Widgets are the leaves of the render tree — they produce actual DOM.
    fields:
      - name: widget_type
        type: enum
        required: true
        values:
          # Content
          - text
          - heading
          - icon
          - image
          - badge
          - code

          # Interactive
          - button
          - link
          - input
          - textarea
          - select
          - checkbox
          - toggle

          # Layout
          - box          # flex container
          - stack        # vertical stack
          - row          # horizontal row
          - grid         # grid container
          - spacer
          - divider

          # Composite
          - card
          - list
          - list-item

      - name: props_schema
        type: object
        description: Widget-specific configuration (validated by interpreter)

      - name: default_props
        type: object
        description: Default values for props

      # Accessibility (required by Validity Requirement)
      - name: aria_label
        type: string
        description: Screen reader label (required for interactive widgets without visible text)

      - name: aria_describedby
        type: string
        description: ID of element that describes this widget

      - name: role
        type: string
        description: ARIA role override

      - name: tabindex
        type: integer
        description: Tab order (-1 to remove from tab order)

      # Animation (declarative, per Boundary Principle)
      - name: transition
        type: object
        description: |
          Transition configuration. Can be a string (transition name) or object
          with enter/exit/duration properties.
        properties:
          enter: { type: string }  # Transition on mount
          exit: { type: string }   # Transition on unmount
          duration_ms: { type: integer, default: 200 }
```

### eidos/layout

Screen structure — how regions are arranged.

```yaml
- eidos: eidos
  id: eidos/layout
  data:
    name: layout
    description: |
      Defines the screen structure — which regions exist and where.
      One layout is active at a time.
    fields:
      - name: name
        type: string
        required: true

      - name: description
        type: string

      - name: regions
        type: array
        required: true
        items:
          type: object
          properties:
            kind:
              type: string
              description: Region identifier (sidebar, main, contextual, toolbar, etc.)
            position:
              type: object
              properties:
                slot: { type: enum, values: [left, center, right, top, bottom] }
                width: { type: integer }
                height: { type: integer }
            name:
              type: string
              description: Human-readable region name
            config:
              type: object
              description: Region-specific config (scrollable, collapsible, etc.)

      - name: active
        type: boolean
        description: Whether this layout is currently active
```

### eidos/panel

What appears in a region.

```yaml
- eidos: eidos
  id: eidos/panel
  data:
    name: panel
    description: |
      A panel occupies a region and renders content.
      Panels declare which region they belong to via region_id.
    fields:
      - name: name
        type: string
        required: true

      - name: render_type
        type: string
        required: true
        description: Semantic type (oikos-list, phasis-thread, theoria-card, etc.)

      - name: region_id
        type: string
        required: true
        description: Which region kind this panel belongs to

      - name: priority
        type: integer
        default: 0
        description: Order within region (lower = earlier)

      - name: visible
        type: boolean
        default: true

      - name: is_default
        type: boolean
        default: false
        description: Show when no other panels match the region

      - name: source_query
        type: string
        description: Kosmos query for panel content (optional)

      - name: config
        type: object
        description: Panel-specific configuration
```

### eidos/theme

Style tokens as entity — homoiconic styling.

```yaml
- eidos: eidos
  id: eidos/theme
  data:
    name: theme
    description: |
      Style tokens as an entity. Themes are homoiconic — style configuration
      is graph-traversable, not hidden in CSS files.
    fields:
      - name: name
        type: string
        required: true

      - name: description
        type: string

      - name: tokens
        type: object
        required: true
        description: |
          Key-value pairs of token names to values.
          Organized by category: color-*, spacing-*, radius-*, etc.

      - name: extends
        type: string
        description: Theme ID to extend (inherit tokens from)

      - name: active
        type: boolean
        default: false
        description: Whether this theme is currently active
```

### eidos/render-spec

Declarative template for rendering entities.

```yaml
- eidos: eidos
  id: eidos/render-spec
  data:
    name: render-spec
    description: |
      A declarative template that describes how to render an entity.
      Composes widgets with data bindings and event handlers.
    fields:
      - name: target_eidos
        type: string
        required: true
        description: Which eidos this spec renders

      - name: variant
        type: string
        default: default
        description: Variant name (card, detail, compact, list-item, etc.)

      - name: layout
        type: array
        required: true
        description: Widget tree with bindings
        items:
          type: object
          properties:
            widget:
              type: string
              description: Widget type (text, card, button, etc.)
            props:
              type: object
              description: Static props and data bindings ({field} syntax)
            children:
              type: array
              description: Nested widgets
            when:
              type: string
              description: Conditional rendering expression

      - name: style_classes
        type: object
        description: CSS class bindings based on entity state

      - name: event_handlers
        type: object
        description: Maps events to praxis invocations
```

---

## Widget Catalog

### Content Widgets

```yaml
# text — Display text content
widget/text:
  props_schema:
    content: { type: string, binding: true }
    variant: { type: enum, values: [body, caption, label, emphasis], default: body }
    truncate: { type: boolean, default: false }
    lines: { type: integer }  # max lines before truncate

# heading — Section headers
widget/heading:
  props_schema:
    content: { type: string, binding: true }
    level: { type: enum, values: [1, 2, 3, 4], default: 2 }

# icon — Symbolic icons
widget/icon:
  props_schema:
    name: { type: string, required: true }  # icon identifier
    size: { type: enum, values: [sm, md, lg], default: md }
    color: { type: string }  # CSS color or semantic name

# badge — Status indicators
widget/badge:
  props_schema:
    content: { type: string, binding: true }
    variant: { type: enum, values: [default, success, warning, error, info] }

# code — Code display
widget/code:
  props_schema:
    content: { type: string, binding: true }
    language: { type: string }
    inline: { type: boolean, default: false }
```

### Interactive Widgets

```yaml
# button — Clickable action
widget/button:
  props_schema:
    label: { type: string, binding: true }
    variant: { type: enum, values: [primary, secondary, ghost, danger], default: secondary }
    size: { type: enum, values: [sm, md, lg], default: md }
    disabled: { type: boolean, default: false }
    on_click: { type: praxis_ref }  # praxis to invoke
    on_click_params: { type: object }  # params to pass (can include bindings)

# input — Text input
widget/input:
  props_schema:
    value: { type: string, binding: true }
    placeholder: { type: string }
    type: { type: enum, values: [text, password, email, number], default: text }
    on_change: { type: praxis_ref }
    on_submit: { type: praxis_ref }

# select — Dropdown selection
widget/select:
  props_schema:
    value: { type: string, binding: true }
    options: { type: array }  # [{value, label}] or binding
    placeholder: { type: string }
    on_change: { type: praxis_ref }
```

### Layout Widgets

```yaml
# box — Flex container
widget/box:
  props_schema:
    direction: { type: enum, values: [row, column], default: column }
    align: { type: enum, values: [start, center, end, stretch], default: stretch }
    justify: { type: enum, values: [start, center, end, between, around], default: start }
    gap: { type: enum, values: [none, xs, sm, md, lg, xl], default: none }
    padding: { type: enum, values: [none, xs, sm, md, lg, xl], default: none }

# stack — Vertical stack (shorthand for box direction=column)
widget/stack:
  props_schema:
    gap: { type: enum, values: [none, xs, sm, md, lg, xl], default: sm }
    align: { type: enum, values: [start, center, end, stretch], default: stretch }

# row — Horizontal row (shorthand for box direction=row)
widget/row:
  props_schema:
    gap: { type: enum, values: [none, xs, sm, md, lg, xl], default: sm }
    align: { type: enum, values: [start, center, end, stretch], default: center }

# card — Bordered container
widget/card:
  props_schema:
    variant: { type: enum, values: [default, bordered, elevated], default: default }
    padding: { type: enum, values: [none, sm, md, lg], default: md }
    on_click: { type: praxis_ref }  # makes card clickable
```

### List Widgets

```yaml
# list — Render a collection
widget/list:
  props_schema:
    source: { type: string, binding: true }  # array field or query
    item_spec: { type: string }  # render-spec ID for each item
    empty_message: { type: string }
    on_select: { type: praxis_ref }

# list-item — Single item in a list (usually used within render-spec)
widget/list-item:
  props_schema:
    on_click: { type: praxis_ref }
    selected: { type: boolean, binding: true }
```

**Note:** `widget/for-each` and `widget/include` have been dissolved. Entity-level iteration is handled by **collection modes** (`item_spec_id` + `source_query` + `arrangement`). Field-level iteration uses the `each` property available on any widget node. See [Iteration Patterns](#iteration-patterns) below.

### Substrate Widgets (Step 8)

```yaml
# video — WebRTC video display
widget/video:
  props_schema:
    track_id: { type: string, binding: true }  # MediaStreamTrack ID from WebRTC substrate
    muted: { type: boolean, default: false }
    autoplay: { type: boolean, default: true }
    fit: { type: enum, values: [contain, cover, fill], default: contain }
    mirror: { type: boolean, default: false }  # For self-view

# scroll — Auto-scrolling container
widget/scroll:
  props_schema:
    auto_scroll_bottom: { type: boolean, default: false }  # Scroll to bottom on content change
    max_height: { type: string }

# grid — CSS Grid layout
widget/grid:
  props_schema:
    columns: { type: [integer, enum], values: [auto-fit], default: 3 }
    min_column_width: { type: string, default: "200px" }
    gap: { type: enum, values: [xs, sm, md, lg], default: md }

# phaser-canvas — Phaser.js game container
widget/phaser-canvas:
  props_schema:
    scene_id: { type: string, required: true }  # Phaser scene to render
```

### Form Widgets

```yaml
# form — Container for form fields with submit handling
widget/form:
  props_schema:
    entity_id: { type: string, binding: true }  # Entity being edited
    on_submit: { type: praxis_ref, required: true }
    on_submit_params: { type: object }
    on_cancel: { type: praxis_ref }
    validate_on_change: { type: boolean, default: true }

# input with field binding — Auto-binds to entity.data[field]
widget/input:
  props_schema:
    field: { type: string }  # When inside form, binds to entity field
    value: { type: string, binding: true }  # Direct binding alternative
    label: { type: string }
    placeholder: { type: string }
    type: { type: enum, values: [text, password, email, number, url], default: text }
    required: { type: boolean, default: false }
    disabled: { type: boolean, default: false }
    error: { type: string }  # Validation error message
    on_change: { type: praxis_ref }

# textarea — Multi-line text input
widget/textarea:
  props_schema:
    field: { type: string }
    value: { type: string, binding: true }
    label: { type: string }
    placeholder: { type: string }
    rows: { type: integer, default: 3 }
    required: { type: boolean, default: false }
    disabled: { type: boolean, default: false }
    readonly: { type: boolean, default: false }
    on_change: { type: praxis_ref }

# checkbox — Boolean toggle
widget/checkbox:
  props_schema:
    field: { type: string }
    checked: { type: boolean, binding: true }
    label: { type: string, required: true }
    disabled: { type: boolean, default: false }
    on_change: { type: praxis_ref }

# toggle — Switch-style boolean
widget/toggle:
  props_schema:
    field: { type: string }
    checked: { type: boolean, binding: true }
    label: { type: string }
    disabled: { type: boolean, default: false }
    on_change: { type: praxis_ref }
```

---

## Iteration Patterns

Iteration over collections is handled at two levels, replacing the dissolved `widget/for-each` and `widget/include`.

### Entity-Level Iteration: Collection Modes

When a mode needs to render a list of entities, it uses the **collection mode pattern**. The mode declares `item_spec_id`, `source_query`, and `arrangement` — the runtime iterates entities and renders each via the item spec:

```yaml
- eidos: mode
  id: mode/node-list
  data:
    name: node-list
    topos: soma
    item_spec_id: render-spec/node-card     # Each entity renders via this
    arrangement: scroll-list                 # scroll-list | grid | thread
    chrome_spec_id: render-spec/node-chrome  # Optional header/footer chrome
    source_query: "gather(eidos: node)"
    spatial:
      position: sidebar
```

Mode patterns:

| Pattern | Mode Fields | Use Case |
|---------|-------------|----------|
| **Singleton** | `render_spec_id` | Dashboard, detail view, single entity |
| **Collection** | `item_spec_id` + `arrangement` + optional `chrome_spec_id` | Lists, grids, feeds |
| **Compound** | `sections[]` | Multiple sub-regions in one mode |

### Field-Level Iteration: The `each` Property

When a render-spec needs to iterate over an array field within a single entity (e.g., tags, participants, items), use the `each` property on any widget node:

```yaml
# Iterate over an array field
- widget: badge
  each: "{tags}"
  each_empty: "No tags"
  props:
    content: "{.}"        # {.} binds to the item itself (for primitives)
    variant: neutral

# Iterate over an array of objects
- widget: card
  each: "{participants}"
  each_empty: "No participants yet"
  props:
    padding: sm
  children:
    - widget: text
      props:
        content: "{name}"   # field on each participant object
    - widget: badge
      props:
        content: "{role}"
```

The `each` property:
- Available on **any widget node** (not a separate widget type)
- The widget renders once as a container; **children repeat per item**
- `{.}` binds to the current item for primitive values (strings, numbers)
- `{field}` binds to fields on the current item for object values
- `each_empty` provides a fallback message when the array is empty

---

## Stoicheia

UI operations that execute in the interpreter.

```yaml
# genesis/thyra/stoicheia/ui.yaml

stoicheia:

  # =========================================================================
  # Navigation
  # =========================================================================

  - id: stoicheion/ui/navigate
    tier: ui
    description: Navigate to a layout, panel, or entity view
    params:
      - name: layout_id
        type: string
        description: Layout to activate
      - name: panel_id
        type: string
        description: Panel to focus/open
      - name: entity_id
        type: string
        description: Entity to view (finds appropriate panel)
    returns:
      type: boolean
      description: Whether navigation succeeded

  - id: stoicheion/ui/set-active-layout
    tier: ui
    description: Change the active layout
    params:
      - name: layout_id
        type: string
        required: true
    returns:
      type: object
      description: The activated layout entity

  # =========================================================================
  # Selection & Context
  # =========================================================================

  - id: stoicheion/ui/set-selection
    tier: ui
    description: Set the current selection context
    params:
      - name: entity_id
        type: string
        required: true
      - name: selection_type
        type: string
        required: true
        description: Type of selection (active-oikos, focused-entity, etc.)
    returns:
      type: boolean

  - id: stoicheion/ui/get-selection
    tier: ui
    description: Get the current selection of a given type
    params:
      - name: selection_type
        type: string
        required: true
    returns:
      type: string
      description: Entity ID or null

  - id: stoicheion/ui/clear-selection
    tier: ui
    description: Clear a selection
    params:
      - name: selection_type
        type: string
        required: true
    returns:
      type: boolean

  # =========================================================================
  # Notifications & Feedback
  # =========================================================================

  - id: stoicheion/ui/notify
    tier: ui
    description: Show a notification toast
    params:
      - name: message
        type: string
        required: true
      - name: level
        type: enum
        values: [info, success, warning, error]
        default: info
      - name: duration_ms
        type: integer
        default: 3000
      - name: action
        type: object
        description: Optional action button {label, praxis_id, params}
    returns:
      type: string
      description: Notification ID (for dismissal)

  - id: stoicheion/ui/dismiss-notification
    tier: ui
    description: Dismiss a notification by ID
    params:
      - name: notification_id
        type: string
        required: true
    returns:
      type: boolean

  # =========================================================================
  # Modals & Dialogs
  # =========================================================================

  - id: stoicheion/ui/modal
    tier: ui
    description: Open a modal dialog
    params:
      - name: title
        type: string
      - name: entity_id
        type: string
        description: Entity to render in modal
      - name: render_spec_id
        type: string
        description: Specific render-spec to use
      - name: size
        type: enum
        values: [sm, md, lg, full]
        default: md
      - name: on_close
        type: praxis_ref
        description: Praxis to invoke on close
    returns:
      type: string
      description: Modal ID

  - id: stoicheion/ui/close-modal
    tier: ui
    description: Close a modal by ID
    params:
      - name: modal_id
        type: string
        required: true
    returns:
      type: boolean

  - id: stoicheion/ui/confirm
    tier: ui
    description: Show a confirmation dialog
    params:
      - name: title
        type: string
        required: true
      - name: message
        type: string
        required: true
      - name: confirm_label
        type: string
        default: "Confirm"
      - name: cancel_label
        type: string
        default: "Cancel"
      - name: destructive
        type: boolean
        default: false
    returns:
      type: boolean
      description: True if confirmed, false if cancelled

  # =========================================================================
  # Panel Operations
  # =========================================================================

  - id: stoicheion/ui/show-panel
    tier: ui
    description: Make a panel visible
    params:
      - name: panel_id
        type: string
        required: true
    returns:
      type: boolean

  - id: stoicheion/ui/hide-panel
    tier: ui
    description: Hide a panel
    params:
      - name: panel_id
        type: string
        required: true
    returns:
      type: boolean

  - id: stoicheion/ui/toggle-panel
    tier: ui
    description: Toggle panel visibility
    params:
      - name: panel_id
        type: string
        required: true
    returns:
      type: boolean
      description: New visibility state

  # =========================================================================
  # Clipboard
  # =========================================================================

  - id: stoicheion/ui/copy-to-clipboard
    tier: ui
    description: Copy text to clipboard
    params:
      - name: text
        type: string
        required: true
    returns:
      type: boolean

  # =========================================================================
  # Focus
  # =========================================================================

  - id: stoicheion/ui/focus
    tier: ui
    description: Focus an input element
    params:
      - name: element_id
        type: string
        required: true
    returns:
      type: boolean
```

---

## Render-Spec Format

### Data Bindings

Use `{field}` syntax for entity data bindings:

```yaml
- widget: text
  props:
    content: "{insight}"           # entity.data.insight

- widget: badge
  props:
    content: "{data.status}"       # explicit data path
    variant: "{status}"            # shorthand for data.status
```

Special bindings:
- `{id}` — entity ID
- `{eidos}` — entity eidos
- `{data.field}` — nested field access

### Form Bindings (Step 8)

Use `$form.field` syntax to access form input values:

```yaml
- widget: input
  props:
    field: message
    placeholder: "Type a message..."

- widget: button
  props:
    label: "Send"
    on_click: agora/send-message
    on_click_params:
      content: "$form.message"     # Get value from form input
```

### Event Bindings (Step 8)

Use `$event.path` syntax for event-time resolution:

```yaml
- widget: input
  props:
    on_input: ui/notify
    on_input_params:
      message: "$event.target.value"  # Resolved when event fires
```

Event bindings are resolved at call time, not at handler creation time. This is essential for capturing live input values.

### Conditional Rendering

Use `when` for conditional widgets:

```yaml
- widget: badge
  when: "status == 'provisional'"
  props:
    content: "Draft"
    variant: warning
```

### Event Handlers

Map events to praxis invocations:

```yaml
- widget: button
  props:
    label: "View Details"
    on_click: praxis/thyra/navigate-to-entity
    on_click_params:
      entity_id: "{id}"
```

### Complete Example

```yaml
# genesis/nous/render-specs/theoria-card.yaml

- eidos: render-spec
  id: render-spec/theoria-card
  data:
    target_eidos: theoria
    variant: card
    layout:
      - widget: card
        props:
          variant: bordered
          on_click: praxis/thyra/view-entity
          on_click_params:
            entity_id: "{id}"
        children:
          - widget: stack
            props:
              gap: sm
            children:
              - widget: row
                props:
                  justify: between
                  align: center
                children:
                  - widget: badge
                    props:
                      content: "{domain}"
                      variant: info
                  - widget: badge
                    when: "status == 'provisional'"
                    props:
                      content: "Draft"
                      variant: warning
                  - widget: badge
                    when: "status == 'crystallized'"
                    props:
                      content: "Crystallized"
                      variant: success

              - widget: text
                props:
                  content: "{insight}"
                  variant: body

              - widget: row
                props:
                  gap: xs
                children:
                  - widget: icon
                    props:
                      name: calendar
                      size: sm
                  - widget: text
                    props:
                      content: "{created_at}"
                      variant: caption

    style_classes:
      theoria-crystallized: "border-left: 4px solid var(--color-success)"
      theoria-provisional: "border-left: 4px solid var(--color-warning)"
```

---

## Topos Ownership

Each domain topos owns render-specs for its eide:

```
genesis/
├── nous/
│   ├── eide/theoria.yaml
│   └── render-specs/
│       ├── theoria-card.yaml
│       ├── theoria-detail.yaml
│       └── theoria-list-item.yaml
│
├── politeia/
│   ├── eide/oikos.yaml
│   └── render-specs/
│       ├── oikos-card.yaml
│       └── oikos-list-item.yaml
│
├── logos/
│   ├── eide/phasis.yaml
│   └── render-specs/
│       ├── phasis-bubble.yaml
│       └── phasis-thread-item.yaml
│
└── thyra/
    ├── eide/
    │   ├── widget.yaml
    │   ├── layout.yaml
    │   ├── panel.yaml
    │   └── render-spec.yaml
    ├── stoicheia/
    │   └── ui.yaml
    └── entities/
        └── layout.yaml  # thyra-default, default panels
```

---

## Phasis Surface: Logos

The diagram above shows `logos/` as a peer of domain topoi. But logos is special: it's an **interface topos** that provides the **phasis surface**.

### What Is the Phasis Surface?

Kosmos has several interaction surfaces — ways that topoi can engage with the world:

| Surface | What It Provides | Interface Topos |
|---------|------------------|-----------------|
| Rendering | Visual presence | thyra (after opsis dissolution) |
| Reasoning | Intelligence | manteia |
| Understanding | Knowledge crystallization | nous |
| **Phasis** | Intentional communication | **logos** |
| Emission | Filesystem persistence | thyra |

The phasis surface allows any entity to **speak** — to emit intentional communications into shared discourse. Without it, only humans speak. With it, the kosmos becomes conversational.

### Why Logos?

λόγος (lógos) — word, reason, discourse.

Phaseis were originally in thyra (the "door" where humans enter kosmos). But phaseis aren't just about human input — they're about **discourse**. When a theoria crystallizes, that's speech. When a daemon completes, that's an announcement. When governance invites someone, that's communication.

**Thyra** handles the *commitment boundary* — where ephemeral (voice streams, drafts) becomes durable.

**Logos** handles the *discourse surface* — where anything that wants to speak can speak.

The handoff: thyra captures voice → accumulation → commit. The commit creates a phasis via `logos/emit-phasis`. From there, logos manages the discourse.

### Integration Pattern

Topoi integrate with the phasis surface by calling `logos/emit-phasis`:

```yaml
# In nous, when crystallizing theoria:
- step: call
  praxis: logos/emit-phasis
  params:
    mode: declaration
    content: "Crystallized: $theoria.insight"
    source_kind: topos
    metadata:
      source_eidos: theoria
      source_id: "$theoria.id"
```

This enables:
- **Unified feed** — Human messages, theoria crystallizations, and daemon announcements in one stream
- **Reply threading across topoi** — Reply to a build completion or a governance decision
- **Conversational kosmos** — The system speaks, not just stores

### Logos Provides

| Category | Items |
|----------|-------|
| **Eidos** | phasis |
| **Attainment** | express |
| **Praxeis** | emit-phasis, reply-to, list-phaseis, get-thread |
| **Render-specs** | phasis-bubble, phasis-thread-item |

### Phase 3 Scope

Phase 3 creates logos as an interface topos:
- Create `genesis/logos/` with manifest and DESIGN.md
- Move phasis eidos from thyra to logos
- Move phasis praxeis (renamed: thyra/express → logos/emit-phasis)
- Create phasis render-specs in logos
- Update thyra to depend on logos

---

## Default Entities

### Default Layout

```yaml
# genesis/thyra/entities/layout.yaml

- eidos: layout
  id: layout/thyra-default
  data:
    name: thyra-default
    description: Default three-column layout with sidebar, main, and contextual regions.
    regions:
      - kind: sidebar
        position:
          slot: left
          width: 260
        name: navigation
        config:
          scrollable: true
          collapsible: false

      - kind: main
        position:
          slot: center
        name: workspace
        config:
          scrollable: true

      - kind: contextual
        position:
          slot: right
          width: 340
        name: conversation
        config:
          scrollable: true
          collapsible: true

      - kind: toolbar
        position:
          slot: bottom
          height: 72
        name: input
        config:
          fixed: true

    active: true
```

### Default Panels

```yaml
- eidos: panel
  id: panel/default/sidebar
  data:
    name: default-sidebar
    render_type: oikos-list
    region_id: sidebar
    is_default: true
    priority: 0
    visible: true

- eidos: panel
  id: panel/default/main
  data:
    name: default-main
    render_type: welcome
    region_id: main
    is_default: true
    priority: 0
    visible: true

- eidos: panel
  id: panel/default/contextual
  data:
    name: default-contextual
    render_type: phasis-thread
    region_id: contextual
    is_default: true
    priority: 0
    visible: true

- eidos: panel
  id: panel/default/toolbar
  data:
    name: default-toolbar
    render_type: voice-composer
    region_id: toolbar
    is_default: true
    priority: 0
    visible: true
```

---

## Render-Spec Discovery

Convention-based lookup:

```
render-spec/{eidos}-{variant}
```

Examples:
- `render-spec/theoria-card`
- `render-spec/oikos-list-item`
- `render-spec/phasis-bubble`

If no variant specified, use `{eidos}-default`.

---

## Migration from Current State

Migration should be **phased** to minimize risk and allow validation at each step.

### Phase 1: Consolidate Duplicates

Address the current duplication between thyra and opsis.

| Action | Details |
|--------|---------|
| Audit thyra/opsis praxeis | Identify 16 duplicated praxeis |
| Choose canonical home | Rendering praxeis → thyra |
| Remove duplicates | Delete opsis versions, update references |

**Validation:** Existing UI continues to work after consolidation.

### Phase 2: Implement Widget Vocabulary

Before migrating render-specs, establish the primitive vocabulary.

| Action | Details |
|--------|---------|
| Create `eidos/widget` | Define ~20 widget types |
| Prototype one render-spec | `render-spec/theoria-card` using widgets |
| Validate in interpreter | Chora team implements widget rendering |

**Validation:** One entity renders correctly with new format.

### Phase 3: Migrate Render-Specs

Move render-spec ownership to domain topoi.

| Action | Details |
|--------|---------|
| Create domain render-specs | `nous/render-specs/`, `politeia/render-specs/`, etc. |
| Convert existing specs | Rewrite using widget vocabulary |
| Update manifests | Domain topoi declare render-spec content paths |

**Validation:** All existing views render correctly with domain-owned specs.

### Phase 4: Dissolve Opsis

Only after phases 1-3 succeed.

| Action | Details |
|--------|---------|
| Move remaining eide | layout, panel → thyra |
| Delete opsis topos | Remove manifest, eide, praxeis |
| Update references | Any code/docs pointing to opsis |

**Validation:** No references to opsis remain; all rendering works.

### What Moves

| Current | New Home | Phase |
|---------|----------|-------|
| `opsis/eide/render-spec.yaml` | `thyra/eide/render-spec.yaml` | 2 |
| `opsis/eide/renderer.yaml` | Dissolves — render-specs replace | 4 |
| `opsis/entities/*.yaml` | Domain topoi own their render-specs | 3 |
| `thyra/entities/layout.yaml` | Stays in thyra | — |
| Duplicated praxeis | Consolidated in thyra | 1 |

### What's New

- `eidos/widget` — The primitive vocabulary (Phase 2)
- `thyra/stoicheia/ui.yaml` — UI operations (Phase 2)
- Domain render-specs (`nous/render-specs/`, etc.) (Phase 3)

### What's Removed

- `eidos/renderer` — Replaced by render-spec + widget primitives
- `eidos/render-type` — See note below
- Opsis topos — Dissolved, contents redistributed

### Note on render-type

The feedback suggested keeping `render-type` for semantic grouping. This is a reasonable concern.

**Current role of render-type:** Groups variants of how an eidos can appear (card, list-item, detail, etc.).

**How the proposal handles this:**
- `render-spec.variant` field captures the semantic type: `card`, `detail`, `list-item`
- Convention-based naming: `render-spec/{eidos}-{variant}` encodes the grouping
- `panel.render_type` still exists for panel categorization

**Trade-off:** We lose explicit `render-type` entities, but gain simpler discovery via naming convention. The variant information moves from a separate entity to a field on render-spec.

**If needed later:** We could add `render-type` back as metadata — entities that describe "what variants exist for an eidos" without affecting the rendering mechanism. This would be additive, not blocking.

---

## Constitutional Derivations

These design decisions follow from Kosmogonia axioms and principles.

### Widget Extensibility

**Principle:** The Boundary Principle + Render Strategies

> "Maximize what lives as topos (YAML definitions). Minimize what requires Rust (interpreter) or TypeScript (UI)."

**Decision:** Base widgets (~20) are interpreter primitives. Topoi compose from these via render-specs. If a topos needs a truly custom widget, it provides it via `web-component` or `wasm` strategy — loaded dynamically, not requiring interpreter changes.

Most rendering is declarative (YAML). Custom widgets are the exception.

### Style System

**Principle:** Homoiconic Pattern

> "Rendering follows the homoiconic pattern: configuration that is usually implicit becomes entities with bonds."

**Decision:** Themes and tokens are entities, not CSS files.

```yaml
# A theme is an entity
- eidos: theme
  id: theme/default
  data:
    tokens:
      color-primary: "#2563eb"
      color-success: "#16a34a"
      spacing-md: "16px"

# Render-specs reference tokens via variant props
- widget: badge
  props:
    variant: success  # → resolves to theme token color-success
```

Style configuration becomes graph-traversable. Themes bond to topoi. The graph IS the style system.

### Animation

**Principle:** Boundary Principle + Schema-driven

> "Push capability toward content, away from code."

**Decision:** Animation as declarative props on widgets, not as a separate system.

```yaml
- widget: card
  props:
    transition: fade-in
    duration_ms: 200

# Conditional transitions
- widget: badge
  props:
    transition:
      enter: scale-in
      exit: fade-out
```

The widget eidos declares supported transitions. The interpreter implements them. Animation is content (YAML), not code.

### Accessibility

**Principle:** The Validity Requirement + Schema-driven

> "All generation is governed. Schema constrains output."

**Decision:** Accessibility is a schema constraint. Widget eidos requires accessibility props.

```yaml
# Widget eidos includes accessibility fields
fields:
  - name: aria_label
    type: string
    description: Screen reader label (required for interactive widgets without visible label)
  - name: role
    type: string
    description: ARIA role override
  - name: tabindex
    type: integer

# Interactive widgets enforce accessibility
widget/button:
  props_schema:
    aria_label: { type: string, required_when: "!label" }
```

The interpreter validates: "button without aria_label or label is invalid." Accessibility is enforced at composition time.

### Form Handling

**Principle:** Axiom II: Authority + Stoicheion/Praxis model

> "The kosmos acts only as authorized by those who dwell in it." Context is not passed. Context is position.

**Decision:** Forms are widgets. Form state is entity state. Submit invokes a praxis.

```yaml
- widget: form
  props:
    entity_id: "{id}"
    on_submit: praxis/nous/update-theoria
    on_submit_params:
      theoria_id: "{id}"
  children:
    - widget: input
      props:
        field: insight
        label: "Insight"
    - widget: select
      props:
        field: domain
        options: "{$domains}"
    - widget: button
      props:
        type: submit
        label: "Save"
```

The form widget creates local signals, invokes praxis on submit, and reactivity flows through the standard entity update path. No special form handling code — standard stoicheion/praxis patterns.

---

## Prototype Validation

Before full implementation, validate the approach with a minimal prototype.

### Prototype Scope

Render one entity (theoria) using the new format:

1. **Kosmos side:**
   - Create `eidos/widget` with 5 types: `card`, `stack`, `row`, `text`, `badge`
   - Create `render-spec/theoria-card` using these widgets
   - No stoicheia yet (static render only)

2. **Chora side:**
   - Implement 5 widget components
   - Implement render-spec interpreter (binding resolution, conditional rendering)
   - Render a theoria entity using the spec

### Success Criteria

- [ ] Theoria card renders identically to current hardcoded version
- [ ] Data bindings resolve correctly (`{insight}`, `{domain}`, `{status}`)
- [ ] Conditional rendering works (`when: "status == 'provisional'"`)
- [ ] No hardcoded theoria-specific code in interpreter

### What We Learn

- Is the widget vocabulary sufficient?
- Is the binding syntax ergonomic?
- Does the interpreter complexity match expectations (~1000 lines)?
- Are there missing widget props or features?

This prototype de-risks the full migration by validating core assumptions.

---

## Next Steps

1. **Review this design** — Address feedback, reach consensus on rationale
2. **Prototype validation** — Implement minimal prototype per above
3. **Phase 1: Consolidate** — Remove duplicated praxeis between thyra/opsis
4. **Phase 2: Widget vocabulary** — Implement full `eidos/widget` and stoicheia
5. **Phase 3: Migrate render-specs** — Move ownership to domain topoi
6. **Phase 4: Dissolve opsis** — Complete the migration

---

*Authored for handoff to kosmos dev team. Revised based on review feedback.*
