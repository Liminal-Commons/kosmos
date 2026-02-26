# Mode Reference

Schema definitions and widget reference for mode development.

A mode declares how existence becomes actuality. This document covers **thyra modes** —
modes that open the door (θύρα) between kosmos and perception. Thyra modes have
spatial position and render-spec fields but no substrate, no stoicheion dispatch.
Every mode in the kosmos is a unified `eidos: mode` entity in a `genesis/<topos>/modes/` directory.

> **Dynamis modes:** For dynamis modes (compute, storage, network, credential, media) — modes that extend kosmos into substrate capabilities via stoicheion dispatch — see [Actualization Pattern](../reactivity/actualization-pattern.md).

---

## Mode Entity Schema

```yaml
- eidos: mode
  id: mode/<name>
  data:
    name: <string>                  # Required
    topos: <string>                 # Required — owning topos
    description: <string>           # Optional

    # Dependencies — other modes this one needs active
    requires:                       # Optional, mode IDs (e.g. thyra mode requiring a dynamis mode)
      - <mode-id>

    # === Thyra fields (presentation) ===

    spatial:                        # Required for thyra modes
      position: <string>            # left, center, right, top, bottom
      height: <string|number>       # fill, <pixels>, auto

    # Singleton pattern — one entity, one render-spec
    render_spec_id: <string>        # e.g. "render-spec/voice-bar"
    source_entity_id: <string>      # e.g. "accumulation/default"

    # Collection pattern — iterate entities
    item_spec_id: <string>          # e.g. "render-spec/phasis-card"
    source_query: <string>          # e.g. "gather(eidos: phasis)"
    arrangement: <string>           # stack, scroll, scroll-bottom
    chrome_spec_id: <string>        # Optional wrapper render-spec
    empty_message: <string>         # Optional, shown when 0 results

    # Compound pattern — multiple sections
    sections:                       # Array of section definitions
      - name: <string>
        item_spec_id: <string>
        source_query: <string>
        arrangement: <string>
        heading: <string>           # Optional section heading
        empty_message: <string>

    config: <object>                # Optional mode-specific config

    # === Dynamis fields (see actualization-pattern.md) ===
    # substrate, provider, operations — not used by thyra modes
```

---

## Render-Spec Entity Schema

```yaml
- eidos: render-spec
  id: render-spec/<name>
  data:
    name: <string>                  # Required
    description: <string>           # Optional
    target_eidos: <string|null>     # Optional, which eidos this renders
    variant: <string>               # Required: panel, card, detail, item

    layout:                         # Required, array of widgets
      - widget: <widget-type>
        when: <condition>           # Optional, conditional rendering
        props:
          <prop>: <value>
        children:                   # Optional, nested widgets
          - widget: ...

    created_at: <timestamp>         # Required
```

---

## Widget Reference

### Layout Widgets

| Widget | Props | Description |
|--------|-------|-------------|
| `stack` | `gap: xs\|sm\|md\|lg` | Vertical arrangement |
| `row` | `gap`, `align: start\|center\|end`, `justify: start\|center\|end\|space-between` | Horizontal arrangement |
| `scroll` | — | Scrollable container |
| `card` | `variant: bordered\|subtle\|compact`, `padding: xs\|sm\|md\|lg`, `on_click`, `on_click_params` | Bounded container |

### Content Widgets

| Widget | Props | Description |
|--------|-------|-------------|
| `heading` | `level: 1-6`, `content` | Section title |
| `text` | `content`, `variant: emphasis\|secondary\|mono\|label\|error`, `size: sm\|md\|lg` | Text content |
| `icon` | `name`, `size: sm\|md\|lg` | Icon display |
| `badge` | `content`, `variant: neutral\|success\|warning\|error` | Status tag |
| `avatar` | `name`, `src`, `size: sm\|md\|lg` | User/entity avatar |
| `status-indicator` | `status`, `variant: dot\|badge` | Online/offline indicator |

---

## Mode Patterns

Modes come in three patterns, determined by their fields:

| Pattern | Fields | Description |
|---------|--------|-------------|
| **Singleton** | `render_spec_id` | Renders one render-spec bound to one entity |
| **Collection** | `item_spec_id` + `source_query` + `arrangement` | Iterates entities, renders each via item_spec_id |
| **Compound** | `sections[]` | Multiple named sections, each with its own spec and query |

### Singleton Mode (thyra)

```yaml
- eidos: mode
  id: mode/compose-full
  data:
    name: compose-full
    topos: thyra
    render_spec_id: render-spec/compose-full
    spatial: { position: bottom, height: auto }
    source_entity_id: accumulation/default
```

### Collection Mode (thyra)

```yaml
- eidos: mode
  id: mode/phasis-feed
  data:
    name: phasis-feed
    topos: logos
    item_spec_id: render-spec/phasis-bubble
    source_query: "gather(eidos: phasis, sort: expressed_at, order: desc)"
    arrangement: scroll-bottom
    chrome_spec_id: null
    spatial: { position: center, height: fill }
    config:
      watch_eidos: phasis
```

`arrangement` controls how items are laid out: `stack` (vertical), `row` (horizontal), `grid`, `list`.

`chrome_spec_id` wraps the collection with a header/footer/toolbar render-spec.

### Compound Mode

```yaml
mode/workspace:
  sections:
    - name: sidebar
      item_spec_id: render-spec/nav-item
      source_query: "gather(eidos: nav-entry)"
      arrangement: stack
    - name: main
      render_spec_id: render-spec/detail-view
      source_entity_id: "{focused_entity_id}"
  spatial: { position: center, height: fill }
```

---

## The `each` Property

Any widget node can use `each` to repeat its children per array item. This handles field-level iteration within a render-spec (as opposed to entity-level iteration, which is handled by collection modes).

| Property | Type | Description |
|----------|------|-------------|
| `each` | string | Binding to an array field, e.g. `"{tags}"` |
| `each_empty` | string | Message shown when the array is empty |

### Example

```yaml
- widget: stack
  each: "{participants}"
  each_empty: "No participants yet"
  children:
    - widget: row
      children:
        - widget: avatar
          props: { name: "{.name}", size: sm }
        - widget: text
          props: { content: "{.name}" }
```

`{.}` binds to the current item itself (useful for primitive arrays like strings). `{.field}` binds to a field on the current item object.

---

## Data Binding Syntax

| Pattern | Example | Description |
|---------|---------|-------------|
| `{field}` | `{name}` | Bind entity data field |
| `{id}` | `{id}` | Bind entity ID |
| `{nested.field}` | `{selected_node.name}` | Bind nested/selected entity |
| `{@bond-name.data.field}` | `{@fed-by-audio.data.intent}` | Traverse bond, read target entity field |
| `{@bond-name.id}` | `{@fed-by-audio.id}` | Traverse bond, read target entity ID |
| `{field} == 'value'` | `{status} == 'error'` | Condition for `when` |
| `@bond == 'value'` | `@fed-by-audio.data.intent == 'capturing'` | Bond field condition for `when` (no braces) |

---

## Event Handlers

| Handler | Params | Description |
|---------|--------|-------------|
| `ui/set-selection` | `selection_type`, `entity_id` | Set selection state |
| `ui/navigate` | `target` | Navigate to route |
| `ui/toggle` | `key` | Toggle boolean state |

---

## Spatial Positions

Modes declare where they appear via `spatial.position`:

| Position | Purpose |
|----------|---------|
| `left` | Navigation, lists |
| `center` | Primary content |
| `right` | Details, related info |
| `top` | Toolbar, status bar |
| `bottom` | Input, composing |

Layout is emergent from active modes' spatial declarations — no separate layout entity.

---

## Status Values

Standard status values for `status-indicator`:

| Value | Visual | Meaning |
|-------|--------|---------|
| `online` | Green dot | Connected, healthy |
| `offline` | Gray dot | Disconnected |
| `error` | Red dot | Error state |
| `degraded` | Yellow dot | Partial functionality |
| `unknown` | Gray dot | State not known |
| `running` | Green dot | Process active |
| `stopped` | Gray dot | Process inactive |
| `starting` | Yellow dot | Transitioning up |
| `stopping` | Yellow dot | Transitioning down |
