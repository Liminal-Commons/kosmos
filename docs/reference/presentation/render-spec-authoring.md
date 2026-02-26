# Render-Spec Authoring Guide

*The definitive reference for designing thyra rendering experiences.*

**For:** Agents (Claude) and human developers authoring render-specs
**See also:** [Widget Vocabulary](../thyra/eide/widget.yaml), [THYRA-AWARENESS.md](THYRA-AWARENESS.md)

---

## What is a Render-Spec?

A **render-spec** is a declarative widget tree that defines how an entity (or collection of entities) appears in thyra. Render-specs replace hardcoded React/SolidJS components with data — making UI composable, versionable, and generatable.

```yaml
- eidos: render-spec
  id: render-spec/my-card
  data:
    name: my-card
    description: "What this render-spec displays"
    target_eidos: my-entity-type  # or null for panels
    variant: card                  # card | list-item | detail | panel
    layout:
      - widget: card
        props:
          padding: md
        children:
          - widget: text
            props:
              content: "{name}"
```

---

## The Widget Vocabulary

**29 widgets** across 9 categories (synced with chora implementation). All widget names are dispatched through `getWidget()` -- the interpreter has zero hardcoded widget names.

### Categories

| Category | Widgets | Purpose |
|----------|---------|---------|
| **layout** | card, stack, row, list, list-item | Spatial arrangement |
| **display** | text, heading, badge, icon, image, code | Content primitives |
| **interactive** | button, link | User actions |
| **form** | input, textarea, select, checkbox, toggle | Input elements |
| **utility** | divider, spacer | Structure helpers |
| **feedback** | progress, avatar, spinner, tooltip, toast, skeleton | Status indicators |
| **overlay** | modal, confirm | Dialog content |
| **navigation** | steps, tabs, accordion | Multi-step flows |
| **composition** | scroll | Scrollable containers |

### Quick Reference

```yaml
# Layout (5)
- widget: card          # variant, padding, on_click, on_click_params
- widget: stack         # gap, align
- widget: row           # gap, align, justify
- widget: list          # ordered, gap
- widget: list-item     # bullet

# Display (6)
- widget: text          # content, variant
- widget: heading       # content, level
- widget: badge         # content, variant
- widget: icon          # name, size, color
- widget: image         # src, alt, fit
- widget: code          # content, language, wrap

# Interactive (2)
- widget: button        # label, variant, on_click, on_click_params, disabled, loading
- widget: link          # content, href, on_click, external

# Form (5)
- widget: input         # field, placeholder, type
- widget: textarea      # field, placeholder, rows
- widget: select        # field, options, placeholder
- widget: checkbox      # field, label
- widget: toggle        # field, label

# Utility (2)
- widget: divider       # orientation, spacing
- widget: spacer        # size (xs|sm|md|lg|xl|flex)

# Feedback (6)
- widget: progress      # value, variant (bar|circle), color
- widget: avatar        # name, src, size
- widget: spinner       # size, label
- widget: tooltip       # content, position (wraps children)
- widget: toast         # message, variant, duration (triggered by praxis)
- widget: skeleton      # variant (text|circle|rect), lines

# Overlay (2)
- widget: modal         # open, title, on_close (has children)
- widget: confirm       # open, title, message, on_confirm, on_cancel, variant

# Navigation (3)
- widget: steps         # current, items, orientation
- widget: tabs          # active, items, on_change
- widget: accordion     # items, allow_multiple, default_open

# Composition (1)
- widget: scroll        # auto_scroll_bottom, max_height

# Iteration (on any widget node)
# each: "{array_field}"    — children repeat per item in the array
# each_empty: "message"    — shown when array is empty
```

---

## Binding Syntax

### Entity Data Bindings

Use `{field}` to bind to entity data:

```yaml
- widget: text
  props:
    content: "{name}"           # Entity's name field

- widget: text
  props:
    content: "{author.name}"    # Nested field access

- widget: text
  props:
    content: "ID: {id}"         # Entity's ID
```

### Form State Bindings

Use `$form.field` (NO braces) for form inputs:

```yaml
# In button on_click_params
- widget: button
  props:
    label: "Submit"
    on_click: my-topos/submit
    on_click_params:
      content: $form.content    # CORRECT: no braces
      mode: $form.mode          # CORRECT: no braces
```

**CRITICAL:** Never use `{$form.field}` — the `$` prefix signals a different binding context.

### Bond Graph Traversal (`@bond-name`)

Use `{@bond-name.path}` to read data from a bonded entity — one hop across the bond graph:

```yaml
# Read a field from a bonded entity
- widget: text
  props:
    content: "{@fed-by-audio.data.intent}"    # Follow fed-by-audio bond, read target's intent

# Read the bonded entity's ID (e.g. for praxis params)
- widget: button
  props:
    on_click: soma/toggle-audio-intent
    on_click_params:
      entity_id: "{@fed-by-audio.id}"         # Bonded entity's ID

# Use in string interpolation
- widget: text
  props:
    content: "Source: {@fed-by-audio.eidos}"   # Bonded entity's eidos
```

**Key rules:**
- `{@bond-name}` follows the bond with that desmos name from the current entity
- Paths: `{@bond-name.data.field}`, `{@bond-name.id}`, `{@bond-name.eidos}`
- In `when` conditions: bare `@bond-name` (no braces) — e.g. `when: "@fed-by-audio.data.intent == 'capturing'"`
- One hop only — no transitive traversal (`@bond1.@bond2` is not supported)
- Missing bond returns undefined (graceful — widget renders empty, `when` treats as falsy)
- Bonded entities are cached per render cycle — multiple widgets referencing the same `@bond-name` fetch once
- Bonded entity changes trigger reactive re-render (subscribed via `onEntityChange`)

### Substrate Signal Bindings

Use `data-signal-source` to bind a widget to high-frequency signals from a substrate entity (e.g., voice activity). The layout engine reads signals at 10Hz and applies each signal field as a `data-signal-{field}` attribute on the DOM element — no entity update, no refetch.

```yaml
- widget: button
  props:
    class: compose-bar__mic
    data-signal-source: "{@fed-by-audio.id}"       # Signal source (entity ID)
    data-state: "{@fed-by-audio.data.desired_state}" # Normal entity data binding
```

**Key rules:**
- `data-signal-source` declares which entity's signals to bind — typically via bond traversal (`{@bond-name.id}`)
- Signal fields (e.g., `energy_db`, `voice_active`) become hyphenated attributes: `data-signal-energy-db`, `data-signal-voice-active`
- CSS targets signal state with attribute selectors: `[data-signal-voice-active="true"] { color: var(--voice-active); }`
- Signals are ephemeral sensor data (energy, VAD) — lifecycle state (`desired_state`, `actual_state`) uses normal `{@bond}` bindings
- A widget can combine both binding types — `data-state` for entity data, `data-signal-*` for live sensor values

### Conditional Rendering

Use `when:` on any widget:

```yaml
# Truthy check
- widget: text
  when: "description"           # Show only if description exists
  props:
    content: "{description}"

# Equality check
- widget: badge
  when: "status == 'active'"
  props:
    content: "Active"
    variant: success

# Inequality check
- widget: badge
  when: "status != 'pending'"
  props:
    content: "{status}"

# Bond field check
- widget: badge
  when: "@fed-by-audio.data.intent == 'capturing'"
  props:
    content: "Live"
    variant: success
```

### Field-Level Iteration (`each`)

Use `each:` on any widget node to repeat its children per item in an array field:

```yaml
# Repeat children for each tag in entity's tags array
- widget: row
  each: "{tags}"
  each_empty: "No tags"
  props:
    gap: xs
  children:
    - widget: badge
      props:
        content: "{item}"
```

**Key rules:**
- `each: "{array_field}"` — binds to an array field on the entity
- Inside the loop, `{item}` refers to the current element (for primitives), or `{item.field}` for objects
- `each_empty: "message"` — optional text shown when the array is empty
- The widget itself renders once; its **children** repeat per item

### Entity-Level Iteration (Modes)

To iterate over **entities** (not fields), use a **collection mode** — not a render-spec widget. The mode declares:

```yaml
# In mode definition
mode/item-feed:
  item_spec_id: render-spec/item-card    # Each entity renders via this spec
  source_query: "gather(eidos: item)"    # Which entities to show
  arrangement: stack                      # How to arrange them (stack, grid, etc.)
  chrome_spec_id: render-spec/feed-chrome # Optional wrapper (heading, scroll, etc.)
```

Three mode patterns:
- **Singleton** (`render_spec_id`): Renders one entity or static layout
- **Collection** (`item_spec_id` + `arrangement` + optional `chrome_spec_id`): Iterates entities via source_query, renders each through item_spec_id
- **Compound** (`sections[]`): Multiple sub-sections in one mode

---

## Common Patterns

### Pattern 1: Entity Card

The most common pattern — a card displaying entity details.

```yaml
layout:
  - widget: card
    props:
      variant: bordered
      padding: md
    children:
      - widget: stack
        props:
          gap: sm
        children:
          # Header row
          - widget: row
            props:
              justify: between
              align: center
            children:
              - widget: text
                props:
                  content: "{name}"
                  variant: emphasis
              - widget: badge
                props:
                  content: "{status}"
                  variant: info
          # Description
          - widget: text
            when: "description"
            props:
              content: "{description}"
              variant: caption
```

### Pattern 2: Clickable Card

Card that invokes a praxis when clicked.

```yaml
layout:
  - widget: card
    props:
      variant: elevated
      padding: md
      on_click: my-topos/view-entity
      on_click_params:
        entity_id: "{id}"
    children:
      - widget: row
        props:
          gap: md
          align: center
        children:
          - widget: icon
            props:
              name: file
              size: md
          - widget: text
            props:
              content: "{name}"
```

### Pattern 3: Collection Mode (List Panel)

Entity-level iteration is handled by **modes**, not by widgets. Define a collection mode with `item_spec_id` + `source_query` + `arrangement`:

```yaml
# Mode definition (in modes/ directory)
- eidos: mode
  id: mode/item-feed
  data:
    name: item-feed
    item_spec_id: render-spec/item-card
    source_query: "gather(eidos: item, sort: created_at, order: desc)"
    arrangement: stack
    chrome_spec_id: render-spec/item-feed-chrome

# Chrome spec (optional wrapper around the collection)
- eidos: render-spec
  id: render-spec/item-feed-chrome
  data:
    name: item-feed-chrome
    variant: panel
    layout:
      - widget: stack
        props:
          gap: md
        children:
          - widget: heading
            props:
              level: 3
              content: "Items"
          - widget: scroll
            children: []   # Collection items injected here by layout engine
```

The layout engine gathers entities via `source_query`, renders each through `item_spec_id`, and wraps the result in `chrome_spec_id` if provided.

### Pattern 3b: Field-Level List

For iterating over an **array field within a single entity** (not separate entities), use `each`:

```yaml
layout:
  - widget: stack
    props:
      gap: md
    children:
      - widget: heading
        props:
          level: 3
          content: "Tags"
      - widget: stack
        each: "{tags}"
        each_empty: "No tags yet"
        props:
          gap: xs
        children:
          - widget: badge
            props:
              content: "{item}"
```

### Pattern 4: Form with Submission

Form inputs with a submit button.

```yaml
layout:
  - widget: card
    props:
      padding: md
    children:
      - widget: stack
        props:
          gap: sm
        children:
          - widget: select
            props:
              field: category
              options:
                - value: a
                  label: Option A
                - value: b
                  label: Option B
          - widget: textarea
            props:
              field: content
              placeholder: "Enter content..."
              rows: 3
          - widget: button
            props:
              label: "Submit"
              variant: primary
              on_click: my-topos/create
              on_click_params:
                category: $form.category
                content: $form.content
```

### Pattern 5: Status-Based Display

Different display based on entity state.

```yaml
layout:
  - widget: card
    props:
      padding: md
    children:
      - widget: stack
        props:
          gap: sm
        children:
          - widget: row
            props:
              gap: sm
              align: center
            children:
              # Icon changes based on status
              - widget: icon
                when: "status == 'success'"
                props:
                  name: check
                  color: success
              - widget: icon
                when: "status == 'error'"
                props:
                  name: x-circle
                  color: error
              - widget: icon
                when: "status == 'pending'"
                props:
                  name: clock
              # Status-specific badges
              - widget: badge
                when: "status == 'success'"
                props:
                  content: "Complete"
                  variant: success
              - widget: badge
                when: "status == 'error'"
                props:
                  content: "Failed"
                  variant: error
              - widget: badge
                when: "status == 'pending'"
                props:
                  content: "Pending"
                  variant: warning
```

### Pattern 6: Action Buttons Row

Multiple action buttons at the bottom of a card.

```yaml
# At end of card children
- widget: row
  props:
    gap: sm
    justify: end
  children:
    - widget: button
      props:
        label: "Cancel"
        variant: ghost
        on_click: my-topos/cancel
        on_click_params:
          id: "{id}"
    - widget: button
      props:
        label: "Confirm"
        variant: primary
        on_click: my-topos/confirm
        on_click_params:
          id: "{id}"
```

---

## Render-Spec Variants

### card

Single entity display. Used as `item_spec_id` in collection modes.

```yaml
target_eidos: oikos
variant: card
```

### list-item

Compact row for dense lists.

```yaml
target_eidos: membership-event
variant: list-item
```

### detail

Full entity detail view (expanded card).

```yaml
target_eidos: theoria
variant: detail
```

### panel

Compound view (not tied to single entity). Contains sections with headings.

```yaml
target_eidos: null
variant: panel
```

---

## Icon Reference (100+ icons)

Organized by topos domain:

**Status:**
- circle, circle-check, circle-x, circle-dot, alert-circle
- check, x-circle, alert-triangle, info, help-circle, clock

**Media:**
- mic, mic-off, video, video-off, camera, headphones
- volume, volume-x, play, pause, stop, record

**Infrastructure:**
- server, terminal, cloud, database, globe
- monitor, smartphone, wifi

**Security:**
- lock, unlock, key, shield, shield-check

**Knowledge:**
- lightbulb, brain, compass, book-open, file-text

**Navigation:**
- chevron-right, chevron-down, chevron-left, chevron-up
- arrow-left, arrow-right, arrow-up, arrow-down
- map-pin, flag, navigation, map, target, crosshair, x

**Communication:**
- mail, mail-open, send, reply, at-sign
- message-circle, message-square, bell, bell-off

**Organization:**
- folder, folder-plus, folder-open, layers, grid
- list, hash, tag, file, file-text, file-plus

**Alerts:**
- bell, bell-off, zap, flame

**Progress:**
- loader, hourglass, refresh-cw

**Governance:**
- building, crown, award, hand, heart

**Actions:**
- plus, plus-circle, edit, edit-2, trash, trash-2
- save, settings, sliders, star

**Users:**
- user, users, user-plus, user-minus, user-x, user-check

---

## Badge Variants

| Variant | Use Case | Example |
|---------|----------|---------|
| `default` | Neutral information | Tag, category |
| `success` | Positive state | Active, Complete, Joined |
| `warning` | Caution state | Pending, Expiring |
| `error` | Negative state | Failed, Removed, Declined |
| `info` | Informational | Role, Type, Count |

---

## Gap and Size Scales

### gap (spacing)

| Value | Typical Use |
|-------|-------------|
| `none` | No space |
| `xs` | Tight grouping |
| `sm` | Related items |
| `md` | Default spacing |
| `lg` | Section separation |
| `xl` | Major sections |

### size (icons, avatars)

| Value | Use Case |
|-------|----------|
| `sm` | Inline, list items |
| `md` | Default, cards |
| `lg` | Hero, detail views |

---

## Common Mistakes

### 1. Wrong form binding syntax

```yaml
# WRONG
on_click_params:
  content: "{$form.content}"

# CORRECT
on_click_params:
  content: $form.content
```

### 2. Using dissolved for-each/include widgets

```yaml
# WRONG — for-each and include are dissolved
- widget: for-each
  props:
    source: "{items}"
  children:
    - widget: include
      props:
        spec: render-spec/item-card

# CORRECT — entity-level iteration uses collection modes
# (Define a mode with item_spec_id + source_query + arrangement)

# CORRECT — field-level iteration uses `each` on any widget
- widget: stack
  each: "{items}"
  each_empty: "No items"
  children:
    - widget: text
      props:
        content: "{item.name}"
```

### 3. Missing children wrapper

```yaml
# WRONG
- widget: card
  props:
    padding: md
  - widget: text  # Direct sibling, not child!

# CORRECT
- widget: card
  props:
    padding: md
  children:
    - widget: text
```

### 4. Using content for button

```yaml
# WRONG
- widget: button
  props:
    content: "Click me"

# CORRECT
- widget: button
  props:
    label: "Click me"
```

### 5. Bare @bond-name without braces in props

```yaml
# WRONG — bare @ passes through as literal string (not resolved)
content: "@fed-by-audio.data.intent"

# CORRECT — braces required for binding resolution
content: "{@fed-by-audio.data.intent}"

# CORRECT — in string interpolation
content: "Mic: {@fed-by-audio.data.intent}"

# NOTE: `when` conditions are different — bare @ is correct there
when: "@fed-by-audio.data.intent == 'capturing'"
```

### 6. Forgetting required on_click for button

```yaml
# WRONG - button without action
- widget: button
  props:
    label: "Submit"

# CORRECT
- widget: button
  props:
    label: "Submit"
    on_click: my-topos/submit
```

---

## File Naming Convention

```
genesis/{topos}/render-specs/{entity-name}-{variant}.yaml
```

Examples:
- `genesis/politeia/render-specs/oikos-card.yaml`
- `genesis/politeia/render-specs/invitation-card.yaml`
- `genesis/nous/render-specs/theoria-list.yaml`

---

## Manifest Integration

Add `render-specs/` path to topos manifest:

```yaml
content_paths:
  - path: eide/
    content_types: [eidos]
  - path: praxeis/
    content_types: [praxis]
  - path: render-specs/
    content_types: [render-spec]  # Widget-tree format
```

For topoi with renderable entities, add `renderable` section:

```yaml
provides:
  eide:
    - my-entity

  renderable:
    - eidos: my-entity
      description: "How this entity appears"
```

---

## Connecting Render-Specs to Modes

Render-specs become visible through modes. A mode bonds to its render-spec via `uses-render-spec`:

```yaml
# In layout.yaml bonds section
- from_id: mode/my-entity-feed
  to_id: render-spec/my-entity-card
  desmos: uses-render-spec
```

The layout engine resolves modes → render-specs → widget trees. No renderer entities needed.

---

## Real Examples

See these files for production render-specs:

**Cards:**
- [politeia/render-specs/affordance-card.yaml](../politeia/render-specs/affordance-card.yaml) — Interactive clickable card
- [politeia/render-specs/invitation-card.yaml](../politeia/render-specs/invitation-card.yaml) — Card with action buttons
- [politeia/render-specs/attainment-card.yaml](../politeia/render-specs/attainment-card.yaml) — Status-based display

**List Items:**
- [politeia/render-specs/membership-event-item.yaml](../politeia/render-specs/membership-event-item.yaml) — Compact event log entry

**Panels:**
- [politeia/render-specs/governance-panel.yaml](../politeia/render-specs/governance-panel.yaml) — Compound panel with sections
- [nous/render-specs/theoria-list.yaml](../nous/render-specs/theoria-list.yaml) — Scrollable entity list

**Forms:**
- [thyra/render-specs/voice-composer.yaml](../thyra/render-specs/voice-composer.yaml) — Form with submission

---

## Generation via Demiurge

Agents can generate render-specs using the Generative Development Spiral:

```yaml
# Generate a render-spec
demiurge/generate-render-spec:
  eidos_name: "my-entity"
  variant: "card"
  purpose: "Display entity with status and actions"
  interactive: true
  topos_context: "my-topos"

# Actualize after review
demiurge/actualize-render-spec:
  artifact_id: "artifact/render-spec/my-entity-card"
```

See [THYRA-AWARENESS.md](THYRA-AWARENESS.md) for the full generation workflow.

---

*Composed in service of the kosmogonia.*
*The widget is the atom. The render-spec is the molecule. Thyra is the living body.*
