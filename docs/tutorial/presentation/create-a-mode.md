# Tutorial: Create a Mode

*Build a UI mode from scratch — making a topos spatially present in Thyra.*

**Time:** 30 minutes
**Prerequisites:** Familiarity with [Your First Praxis](../foundations/first-praxis.md) and basic YAML

---

## What You'll Learn

1. What a mode is and how it makes a topos present
2. How to write a render-spec with a widget tree
3. How to create a collection mode that lists entities
4. How to activate your mode in a thyra-config

---

## Step 1: Understand Modes

A **mode** is how a topos presents itself in a spatial position. A topos with no modes is invisible. A topos with modes is present in Thyra.

Every mode declares:
- **What to render** — a render-spec (widget tree)
- **Where to render** — spatial position (left, center, right, bottom, top)
- **What data to use** — a query or entity binding

There are three mode patterns:

| Pattern | Use When | Key Field |
|---------|----------|-----------|
| **Singleton** | Rendering one entity with one spec | `render_spec_id` |
| **Collection** | Listing entities from a query | `item_spec_id` + `source_query` |
| **Compound** | Multiple sections with different data | `sections[]` |

We'll build a **collection mode** — the most common pattern.

---

## Step 2: Create the Render-Spec

A render-spec is a widget tree that declares how to render an entity. Create `genesis/nous/render-specs/theoria-card.yaml`:

```yaml
- eidos: render-spec
  id: render-spec/theoria-card
  data:
    name: theoria-card
    description: Card view for a theoria entity
    target_eidos: theoria
    variant: card
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
              - widget: text
                props:
                  content: "{title}"
                  variant: heading
              - widget: text
                props:
                  content: "{insight}"
                  variant: body
              - widget: row
                props:
                  gap: sm
                  align: center
                  justify: between
                children:
                  - widget: badge
                    props:
                      content: "{domain}"
                  - widget: text
                    props:
                      content: "{crystallized_at}"
                      variant: caption
```

Key concepts:
- **`{field}`** binds to entity data fields. When rendering a theoria, `{title}` resolves to `theoria.data.title`.
- **widget tree** is a nested structure: each widget can have `children`.
- **`variant`** on the render-spec declares how this spec is used (card, detail, compact, etc.).
- **`target_eidos`** declares which entity type this spec renders.

---

## Step 3: Create the Mode Entity

A mode binds a render-spec to a spatial position and data source. Create `genesis/nous/entities/layout.yaml`:

```yaml
entities:

  - eidos: mode
    id: mode/theoria-list
    data:
      name: theoria-list
      oikos: nous
      item_spec_id: render-spec/theoria-card
      arrangement: scroll
      empty_message: "No theoria crystallized yet"
      spatial:
        position: center
        height: fill
      source_query: "gather(eidos: theoria, sort: crystallized_at, order: desc)"
```

This declares a **collection mode**:
- **`item_spec_id`** — render each entity using `render-spec/theoria-card`
- **`arrangement: scroll`** — wrap items in a scrollable container
- **`source_query`** — gather all theoria entities, sorted by newest first
- **`spatial.position: center`** — render in the center area
- **`spatial.height: fill`** — take all available vertical space
- **`empty_message`** — shown when the query returns no results

Available arrangements: `scroll`, `scroll-bottom`, `stack`, `list`, `grid`.

---

## Step 4: Activate in a Thyra-Config

Modes don't render until they're listed in a thyra-config's `active_modes`. Add your mode to the active thyra-config:

```yaml
  - eidos: thyra-config
    id: thyra-config/default
    data:
      name: default
      active_modes:
        - mode/oikos-nav
        - mode/theoria-list        # Add your mode
        - mode/compose-full
```

Each thyra-config is a set of active modes. Thyra reads the active config and renders every listed mode at its declared spatial position.

---

## Step 5: Update the Manifest

Add the new content paths to `genesis/nous/manifest.yaml`:

```yaml
content_paths:
  - path: render-specs/
    content_types: [render-spec]
  - path: entities/
    content_types: [mode]
```

---

## Step 6: Verify

After bootstrap (`just dev`), you should see:
1. Your theoria-list mode rendering in the center area
2. Each theoria displayed as a card with title, insight, domain badge, and timestamp
3. "No theoria crystallized yet" if no theoria entities exist

Create a theoria to test:
```
nous_crystallize-theoria(
  insight: "Modes make topoi present",
  domain: "kosmos"
)
```

The mode's `source_query` will pick up the new entity and render it with your card spec.

---

## Bonus: Add a Singleton Mode

For comparison, here's a singleton mode — it renders one specific entity:

```yaml
  - eidos: mode
    id: mode/compose-full
    data:
      name: compose-full
      topos: thyra
      render_spec_id: render-spec/compose-full
      spatial:
        position: bottom
        height: auto
      source_entity_id: accumulation/default
```

- **`render_spec_id`** — one spec for one entity (not per-item)
- **`source_entity_id`** — bind to a specific entity by ID
- **`height: auto`** — size to content, not fill

---

## Bonus: Add Chrome to a Collection

Collection modes can have a "chrome" — a header rendered once above the items:

```yaml
  - eidos: mode
    id: mode/oikos-nav
    data:
      name: oikos-nav
      oikos: politeia
      item_spec_id: render-spec/oikos-card
      chrome_spec_id: render-spec/oikos-chrome
      arrangement: scroll
      spatial:
        position: left
        height: fill
      source_query: "gather(eidos: oikos, sort: name, order: asc)"
```

The `chrome_spec_id` is rendered once at the top; `item_spec_id` renders for each entity.

---

## What You Learned

1. **Modes** make topoi spatially present — no mode, no visibility
2. **Render-specs** define widget trees with `{field}` data bindings
3. **Collection modes** use `item_spec_id` + `source_query` + `arrangement`
4. **Singleton modes** use `render_spec_id` + `source_entity_id`
5. **Spatial declarations** position modes: left, center, right, top, bottom
6. **Thyra-configs** activate modes — modes not listed are invisible

---

## See Also

- [Mode Development](../../how-to/presentation/mode-development.md) — Recipes for all mode patterns
- [Modes and Topoi](../../explanation/presentation/modes-and-topoi.md) — Why modes are topos presence
- [Mode Reference](../../reference/presentation/mode-reference.md) — Widget and render-spec schemas
- [Thyra Topos](../../explanation/presentation/thyra-topos.md) — Full UI ontology design
