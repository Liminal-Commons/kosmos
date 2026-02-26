# Widget System

*How widgets are declared, discovered, validated, and resolved.*

**Status: VERIFIED** — implemented in chora. Graph-driven registry, render-spec validation, and displays-as bond traversal are operational.

---

## Overview

Widgets are atomic UI primitives — the leaves of the render tree. They produce actual DOM. The widget system has three layers:

1. **Genesis (constitutional)**: Widget eidos + entity instances in `genesis/thyra/eide/widget.yaml`
2. **Bootstrap (validation)**: Widget entities loaded into graph; render-specs validated against known widgets
3. **Runtime (rendering)**: Graph-populated registry maps widget names to SolidJS components

All three layers are connected. Genesis is the source of truth. Bootstrap validates consistency. Runtime resolves through the graph.

---

## Widget Eidos

Defined in `genesis/thyra/eide/widget.yaml`. The widget eidos declares:

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `widget_type` | enum | yes | The widget type name (e.g., `card`, `text`) |
| `category` | enum | yes | Category for discovery filtering |
| `props_schema` | object | no | Widget-specific configuration schema |
| `default_props` | object | no | Default values for props |
| `supports_children` | boolean | yes | Whether widget accepts children array |
| `supports_when` | boolean | yes | Whether widget supports conditional rendering |

### Categories

| Category | Widgets |
|----------|---------|
| layout | card, stack, row, list, list-item |
| display | text, heading, badge, icon, image, code |
| interactive | button, link |
| form | input, textarea, select, checkbox, toggle, form |
| utility | divider, spacer |
| feedback | progress, status-indicator, avatar, spinner, tooltip, toast, skeleton |
| overlay | modal, confirm |
| navigation | steps, tabs, accordion |
| composition | scroll, artifact |
| substrate | video, grid, phaser-canvas |

---

## Widget Entity Instances

Each widget type has a corresponding entity instance in genesis. Entity ID follows the pattern `widget/{widget_type}`.

Example:

```yaml
- eidos: widget
  id: widget/card
  data:
    widget_type: card
    category: layout
    description: "Bordered container for grouping content."
    props_schema:
      variant:
        type: enum
        values: [default, bordered, elevated, compact]
      padding:
        type: enum
        values: [none, sm, md, lg]
    supports_children: true
```

Widget entities are loaded at bootstrap like any other entity. After bootstrap, `find widget/card` returns the entity and `gather(eidos: widget)` returns all widgets.

---

## Render-Spec Validation

After bootstrap loads all content, render-specs are validated against known widgets:

1. Gather all widget entities to build a known-widgets set (by `widget_type` field)
2. Gather all render-spec entities
3. Walk each render-spec's `layout` tree recursively
4. For each `node.widget`, verify the name exists in the known-widgets set
5. Collect warnings for any unresolvable widget references

This catches broken render-specs at bootstrap, not at runtime. A render-spec referencing `widget: "nonexistent"` produces a validation warning during bootstrap.

---

## Graph-Driven Widget Registry

The TypeScript widget registry is populated from the graph at app initialization:

```
App start → gatherEntities("widget") → build registry Map → getWidget() resolves from map
```

### Registry Population

After bootstrap completes and the app connects, `initWidgetRegistry()` is called:

1. Call `gatherEntities("widget", 100)` to fetch all widget entities
2. Build a `Map<string, WidgetMeta>` from entity data
3. Each entry contains: `widgetType`, `category`, `supportsChildren`, `configSchema`
4. Log parity check — warns if graph entities and component map are mismatched

### Two-Layer Design

The registry has two layers:

1. **Component map** (static): TypeScript imports mapped to widget type names. Exists because component imports are compile-time.
2. **Widget metadata** (graph-driven): Populated from `gatherEntities("widget")`. Contains category, props_schema, supports_children from genesis entities.

`getWidget()` checks both layers: if the graph registry is initialized, a widget must exist as an entity AND have a component to resolve.

### getWidget Resolution

```
getWidget("card")
  → widgetMeta.has("card") ? true          (graph check)
  → componentMap["card"]                    (component lookup)
  → CardWidget (SolidJS component)
```

Before `initWidgetRegistry()` is called, `getWidget()` falls back to the component map directly.

---

## The `displays-as` Bond

Field-level widget customization via bond traversal:

```
field-def/phasis.content --displays-as--> widget/markdown-text
```

### Bond Definition

```yaml
- eidos: desmos
  id: desmos/displays-as
  data:
    name: displays-as
    from_eidos: field-def
    to_eidos: widget
    cardinality: many-to-one
    symmetric: false
```

### Traversal

When rendering a field, the renderer can traverse `displays-as` to find the appropriate widget:

1. Given a field-def entity ID, trace `displays-as` bonds outward
2. The target widget entity determines which component renders the field
3. Falls back to default widget selection by field type if no bond exists

This makes field-level display configuration traversable — data, not code.

---

## Validation Rules

### Valid Widget Declaration

A widget entity is valid when:
- `id` follows pattern `widget/{widget_type}`
- `widget_type` matches an enum value in the widget eidos
- `category` is a valid category enum value
- `supports_children` is a boolean
- If `props_schema` is present, it's a valid object

### Valid Render-Spec Widget Reference

A render-spec widget reference is valid when:
- `node.widget` matches a `widget_type` of an existing widget entity

### Build Errors

The following are validation errors:
- Render-spec references a widget type that has no corresponding widget entity
- Widget entity exists in genesis but has no TypeScript implementation
- TypeScript implementation exists but has no widget entity in genesis

---

## What This Enables

When widgets are homoiconic:

- **Discovery**: `gather(eidos: widget)` returns all available widgets with metadata
- **Validation**: Broken widget references caught at bootstrap, not runtime
- **Field binding**: `displays-as` bonds make widget selection traversable
- **Topos extensibility**: A topos can define widget entities; render-specs can reference them
- **Introspection**: Widget props_schema queryable without reading TypeScript
