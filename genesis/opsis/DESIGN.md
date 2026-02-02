# Opsis Design

ὄψις (ópsis) — sight, appearance, visual form

## Ontological Purpose

Opsis addresses **the gap between existence and appearance** — how kosmos entities become visible to dwellers.

Without opsis:
- Entities exist but have no visual form
- Layout is hardcoded in substrate
- Themes are implementation details
- Rendering decisions are opaque

With opsis:
- **Layouts**: Define visual structure (regions, panels)
- **Themes**: Define visual style (palette, density, typography)
- **Panels**: Bridge entities to visual areas
- **Render intents**: Declare what should be visible
- **Reconciliation**: Compare intent to actual rendering

The central concept is **appearance** — not the entities themselves (nous, thyra), but how they show up visually.

## Circle Context

### Self Circle

A solitary dweller uses opsis to:
- Choose personal layout and theme
- Arrange workspace panels
- Focus on specific artifacts
- Customize visual density

Personal appearance is self-expression.

### Peer Circle

Collaborators use opsis to:
- Share layouts for common activities
- Coordinate panel visibility
- Present shared workspaces
- Synchronize focus context

Peer appearance is shared attention.

### Commons Circle

A commons uses opsis to:
- Define standard layouts for members
- Brand with community themes
- Guide attention through panels
- Analyze engagement patterns

Commons appearance is designed experience.

## Core Entities (Eide)

### layout

Top-level HUD structure — defines arrangement of regions.

**Fields:**
- `name` — layout identifier (e.g., 'default', 'minimal', 'focused')
- `regions` — region specifications [{kind, position, config}]
- `active` — whether this layout is currently active
- `composed_from` — definition ID if composed from typos

### panel

Renderable content area — surfaces entities within a region.

**Fields:**
- `name` — panel identifier
- `render_type` — how to render (entity-list, expression-thread, etc.)
- `source_query` — query to gather entities
- `source_entity_id` — specific entity if single
- `region_id` — which region this panel renders in
- `priority` — rendering priority within region
- `visible` — whether currently visible

### style-theme

Visual styling — palette, density, and contextual appearance.

**Fields:**
- `name` — theme identifier
- `palette` — color definitions {background, foreground, accent, ...}
- `density` — visual density (compact, comfortable, spacious)
- `typography` — font family, sizes, weights
- `world_context` — intended circle kind
- `active` — whether this theme is currently active

### render-intent

Reconciler intent for rendering — declares what should be visible.

**Fields:**
- `target_region_id` — region this intent targets
- `visible_entities` — entity IDs that should be visible
- `panel_states` — desired state of panels
- `layout_id` — active layout
- `theme_id` — active theme
- `intent_status` — pending, reconciling, rendered, stale

### workspace

Open artifacts and focus state — what the animus is working on.

**Fields:**
- `name` — workspace identifier
- `open_artifact_ids` — artifact IDs currently open (tab order)
- `focused_artifact_id` — currently focused artifact
- `animus_id` — animus this workspace belongs to

### render-type

How an eidos should render — makes display configuration traversable.

**Fields:**
- `name` — render type identifier
- `source_eidos` — the eidos this render type applies to
- `grouping` — how to group instances
- `sort_by` — default sort field
- `filters` — available filter options

### renderer

Component that implements a render-type.

**Fields:**
- `name` — renderer identifier
- `render_strategy` — core, declarative, web-component, wasm
- `substrate` — target substrate (web, native, terminal, universal)
- `accepts_render_types` — render type IDs this renderer handles

### render-spec

Declarative rendering specification — graph-driven rendering without code.

**Fields:**
- `name` — render spec identifier
- `target_eidos` — the eidos this spec renders
- `fields_to_display` — entity fields to render
- `layout_template` — structural template
- `style_bindings` — CSS mappings

### widget

Field-level display component — how individual fields render.

**Fields:**
- `name` — widget identifier
- `field_types` — field types this widget can render
- `component_path` — path to widget component
- `editable` — whether widget supports editing

## Bonds (Desmoi)

### renders-with

Panel uses renderer.

- **From:** panel
- **To:** renderer
- **Semantics:** This panel is displayed using this renderer

### displays-as

Field uses widget.

- **From:** field-def (within eidos)
- **To:** widget
- **Semantics:** This field is displayed using this widget

## Operations (Praxeis)

*Praxeis remain in thyra namespace as parent.*

### gather-render-intent

Assemble a render intent for a region.

- **When:** Before reconciliation
- **Provides:** Render intent entity

### reconcile-region

Compare render intent to actual visibility, emit changes.

- **When:** Reconciliation loop
- **Provides:** Reconciliation actions

### emit-render

Push rendering changes to substrate.

- **When:** After reconciliation
- **Provides:** Rendered state confirmation

### activate-layout / activate-theme

Set active layout or theme.

- **When:** User preference change
- **Provides:** Updated active state

### open-artifact / close-artifact / focus-artifact

Workspace tab management.

- **When:** User interaction
- **Provides:** Updated workspace state

## Attainments

### attainment/render (defined in thyra)

Rendering capability — visual emission and workspace management.

- **Grants:** All render-related praxeis in thyra namespace
- **Scope:** soma (substrate-local)
- **Rationale:** Rendering is substrate-local; each soma has its own viewport

## Embodiment

### Completeness Status

| Level | Status |
|-------|--------|
| Defined | 9 eide, 2 desmoi, attainment via thyra |
| Loaded | Bootstrap loads all definitions |
| Projected | Praxeis visible as MCP tools |
| Embodied | Full — render loop implemented |
| Surfaced | Full — panels, layouts visible |
| Afforded | Full — theme/layout switching |

### Body-Schema Contribution

When sense-body gathers opsis state:

```yaml
visual:
  active_layout: "default"
  active_theme: "dark"
  panels_visible: 4
  focused_artifact: "artifact/my-doc"
  workspace_tabs: 3
```

This reveals the visual configuration of the substrate.

## Compound Leverage

### amplifies thyra

Thyra defines streams and expressions; opsis determines how they appear. Without opsis, thyra's portal has no face.

### amplifies nous

Nous defines theoria and journeys; opsis provides theoria-card and journey-view render types. Understanding becomes visible.

### amplifies politeia

Politeia defines circles and attainments; opsis provides presence-list and affordance-bar. Governance becomes navigable.

### amplified by hodos

Hodos determines which panel to show at each waypoint. Navigation drives rendering decisions.

## Theoria

### T73: Appearance is not existence

Entities exist in kosmos whether or not they're rendered. Opsis is the projection layer — it chooses what to show, not what is. Multiple opsis configurations can exist for the same kosmos state.

### T74: Rendering is reconciliation

The render loop follows the dynamis pattern: intent → sense → compare → act. Render intents declare desired visibility; reconciliation makes it actual. Stale intents trigger re-render.

### T75: Homoiconic rendering

Render types, renderers, and specs are all entities. The rendering configuration is traversable. You can query "how does theoria render?" and get an entity answer.

---

*Composed in service of the kosmogonia.*
*The visible is the appearance of the real. Opsis makes it so.*
