# Oikos-Centric Rendering Design

Design perspective and implementation pathway for oikos-centric rendering, Thyra as HUD, and personal HUD oikoi.

---

## Current Architecture Analysis

### Rendering Entity Stack

The rendering architecture defines a layered entity stack:

```
entity → eidos → render-type → renderer → visual form
                      ↓
                 render-spec (if declarative)
                      ↓
                   widget (field-level)
```

**Entities defined in opsis:**
- `render-type` — semantic category for how an eidos should render
- `renderer` — component that implements render-types (strategies: core, declarative, web-component, wasm)
- `render-spec` — declarative specification for layout/fields
- `widget` — field-level display component

**Bonds:**
- `renders-with` — render-type → renderer
- `applies-to-eidos` — render-type → eidos
- `displays-as` — field-def → widget

### Current Instances (spora.yaml)

**render-type entities:** 8 defined
- expression-thread, circle-list, presence-list, theoria-display
- voice-composer, artifact-editor, agora-territory, connection-status

**renderer entities:** All use `render_strategy: core`
- ExpressionThread, CircleList, PresenceList, TheoriaPanel
- VoiceComposer, ArtifactEditor

**render-spec entities:** None instantiated

### The Duality Tension

Panel's `render_type` field is an **enum** (closed set):
```yaml
render_type:
  type: enum
  values: [entity-list, expression-thread, presence-list, ...]
```

Meanwhile, `render-type` is an **eidos** (open set):
```yaml
- eidos: render-type
  id: render-type/expression-thread
  data: { source_eidos: expression, ... }
```

This creates duplication — the enum values mirror entity IDs.

**Resolution:** Treat enum as "well-known shortcuts." Panel's render_type becomes a string that can be:
1. Enum shortcut (e.g., "expression-thread") — resolved to render-type/{shortcut}
2. Full entity ID (e.g., "render-type/pragma-card") — used directly

---

## Design Decisions

### D1: Oikos Rendering Ownership

**Decision:** Oikoi own presentation for their eide.

Instead of centralizing all render-types in opsis, each oikos:
1. Declares renderable eide in `manifest.provides.renderable`
2. Defines render-types in its entities directory
3. Optionally provides render-specs for declarative rendering

**Manifest structure:**
```yaml
# genesis/ergon/manifest.yaml
provides:
  renderable:
    - eidos: pragma
      description: "Work item cards and lists"
```

**Entity structure:**
```yaml
# genesis/ergon/entities/rendering.yaml
- eidos: render-type
  id: render-type/pragma-card
  data:
    name: pragma-card
    source_eidos: pragma
    description: "Single pragma as card"

- eidos: render-spec
  id: render-spec/pragma-card
  data:
    name: pragma-card-spec
    target_eidos: pragma
    fields_to_display:
      - field: title
        label: Title
      - field: status
        widget_id: widget/status-badge
    layout_template: |
      <div class="pragma-card">
        <h3>{title}</h3>
        <span class="status">{status}</span>
      </div>
```

### D2: Generic Declarative Renderers

**Decision:** Opsis provides generic renderers; oikoi provide specifications.

Generic renderers in opsis:
```yaml
- eidos: renderer
  id: renderer/declarative-card
  data:
    name: declarative-card
    render_strategy: declarative
    substrate: universal
    description: "Generic card renderer using render-spec"

- eidos: renderer
  id: renderer/declarative-list
  data:
    name: declarative-list
    render_strategy: declarative
    substrate: universal
    description: "Generic list renderer using render-spec"

- eidos: renderer
  id: renderer/declarative-detail
  data:
    name: declarative-detail
    render_strategy: declarative
    substrate: universal
    description: "Generic detail view renderer using render-spec"
```

These renderers accept ANY render-type and use the associated render-spec for layout.

### D3: Thyra Discovery Mechanism

**Decision:** Thyra discovers rendering via graph traversal.

Discovery algorithm:
```
1. Given entity to render, get its eidos
2. Trace: eidos ←[applies-to-eidos]— render-types
3. Filter render-types by context (card vs list vs detail)
4. For each render-type, trace: render-type —[renders-with]→ renderer
5. Select renderer by substrate preference (web > universal > terminal)
6. If renderer is declarative, load render-spec
7. Render using selected component/spec
```

**Fallback chain:**
1. Oikos-specific render-type + renderer
2. Oikos render-type + generic declarative renderer
3. Generic entity renderer (display all fields)

### D4: Personal HUD Oikoi

**Decision:** Dwellers can create custom rendering oikoi.

A personal HUD oikos:
1. Declares `provides.renderable` for eide it wants to customize
2. Defines render-types/render-specs with preferred styling
3. Has higher priority than commons oikoi for that dweller

Priority order:
1. Self-circle oikos (personal preference)
2. Peer-circle oikos (shared styling)
3. Commons oikos (community standard)
4. Original defining oikos (default)

---

## Implementation Phases

### Phase 1: Enable Declarative Rendering (Chora)

**Goal:** Make render_strategy: declarative functional.

**Tasks:**
1. Implement declarative renderer engine in chora
   - Parse render-spec.layout_template
   - Resolve {field} interpolations
   - Apply style_bindings
2. Create generic declarative renderers in opsis
   - declarative-card, declarative-list, declarative-detail
3. Add test render-specs for theoria eidos

**Verification:** Theoria entities render using declarative renderer.

### Phase 2: Manifest Renderable Declaration

**Goal:** Oikoi declare rendering ownership.

**Tasks:**
1. Define `provides.renderable` manifest schema
2. Update oikos manifests with renderable declarations
3. Bootstrap processes renderable declarations

**Manifest schema:**
```yaml
provides:
  renderable:
    - eidos: {eidos-name}
      description: {optional description}
      render_types:  # optional, auto-discovered if omitted
        - render-type/{id}
```

### Phase 3: Distributed Render-Types

**Goal:** Move render-types to owning oikoi.

**Tasks:**
1. Move expression render-types to thyra
2. Move theoria render-types to nous
3. Move circle render-types to politeia
4. Create pragma render-types in ergon (new)
5. Update bootstrap to load from oikos directories

### Phase 4: Opsis Discovery Praxeis ✓

**Goal:** Programmatic discovery and selection of render-specs.

**Status:** Complete

**Implemented praxeis:**
1. `opsis/discover-render-specs` — Find all render-specs for an eidos
2. `opsis/get-render-spec` — Get specific render-spec by eidos and view type
3. `opsis/select-renderer` — Find appropriate renderer for a render-spec
4. `opsis/list-renderable-eide` — List all eide with render-specs
5. `opsis/render-entity` — Main entry point for DeclarativeEngine

**Usage:**
```yaml
# Discover what views are available for theoria
call: opsis/discover-render-specs
params:
  eidos_name: "theoria"
# Returns: { card: spec, detail: spec, list: spec, spec_count: N }

# Get rendering info for a specific entity
call: opsis/render-entity
params:
  entity_id: "theoria/my-insight"
  view_type: "card"
# Returns: { entity, spec, view_type, has_spec }
```

### Phase 5: Personal HUD Oikoi

**Goal:** Dwellers can customize rendering.

**Tasks:**
1. Define personal oikos creation workflow
2. Implement priority resolution for render-type selection
3. Create example personal HUD oikos
4. Document personal HUD authoring

---

## Migration Path

### Panel render_type Field

**Current:** Enum with hardcoded values

**Migration:**
1. Keep enum for backward compatibility
2. Add `render_type_id` field (string, optional)
3. If `render_type_id` is set, use it; otherwise resolve enum to entity
4. Eventually deprecate enum values

**Example:**
```yaml
# Old style (still works)
render_type: expression-thread

# New style (extensible)
render_type: custom
render_type_id: render-type/pragma-kanban
```

### Existing Render-Types

**Current location:** spora.yaml (bootstrap seeds)

**Migration:**
1. Keep in spora.yaml for Phase 1-2
2. Phase 3: Move to owning oikos directories
3. Bootstrap order: core oikoi first, then domain oikoi

---

## Example: Ergon Rendering

After implementing this design, ergon would provide:

**manifest.yaml:**
```yaml
provides:
  renderable:
    - eidos: pragma
      description: "Work items with status tracking"
```

**entities/rendering.yaml:**
```yaml
- eidos: render-type
  id: render-type/pragma-card
  data:
    name: pragma-card
    source_eidos: pragma
    description: "Single pragma as status card"

- eidos: render-type
  id: render-type/pragma-kanban
  data:
    name: pragma-kanban
    source_eidos: pragma
    grouping: by-status
    description: "Pragmas grouped by status in kanban columns"

- eidos: render-spec
  id: render-spec/pragma-card
  data:
    name: pragma-card-spec
    target_eidos: pragma
    fields_to_display:
      - field: title
      - field: status
        widget_id: widget/status-badge
      - field: priority
        widget_id: widget/priority-indicator
    layout_template: |
      <article class="pragma-card pragma-{status}">
        <header>{title}</header>
        <footer>{status} | {priority}</footer>
      </article>
    style_bindings:
      pragma-open: "border-left: 4px solid var(--status-open)"
      pragma-accepted: "border-left: 4px solid var(--status-accepted)"
      pragma-resolved: "border-left: 4px solid var(--status-resolved)"
```

---

## Related Theoria

- **T75: Homoiconic rendering** — Render types, renderers, and specs are all entities
- **theoria/rendering-duality** — Enum vs entity tension and resolution
- **theoria/declarative-renderer-gap** — All current renderers are core, not declarative
- **theoria/rendering-discovery-path** — Full graph traversal for rendering
- **theoria/oikos-rendering-ownership** — Oikoi own presentation for their eide
- **theoria/thyra-hud-discovery** — Thyra discovers and composes across oikoi

---

*Composed in service of the kosmogonia.*
*Appearance is not existence, but rendering makes existence visible.*
