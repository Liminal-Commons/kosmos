# Chora Handoff: Render-Spec Processing

*Document for chora implementation team. Describes the declarative rendering pipeline from render-spec to visual output.*

---

## Why This Is Needed

**The Problem:** Traditional UI systems require central knowledge of all entity types. Adding a new eidos means modifying the core UI codebase. This creates bottlenecks and couples domain evolution to UI development.

**The Solution:** Oikos-centric rendering inverts the dependency. Each oikos declares how its eide should appear via render-specs. The core UI becomes a generic rendering engine that processes these declarations.

**The Value:**
1. **Decoupled evolution** — Adding a new eidos with its render-spec requires no core UI changes
2. **Domain ownership** — The team that understands theoria best defines how theoria renders
3. **Extensibility** — New oikoi can provide completely custom visualizations
4. **Consistency** — Shared component vocabulary (cards, badges, buttons) ensures coherent UX

**Constitutional alignment:** This implements the KOSMOGONIA principle that "composition chain terminates in genesis." A render-spec traces to its oikos, which traces to genesis. The visual form of an entity has provenance, just like its data.

**The homoiconic insight:** Render-specs are themselves entities with bonds. They can be queried, surfaced, and composed like any other entity. The rendering system doesn't require special cases — it's "just entities" all the way down.

Without declarative render-specs, adding visual capability requires Rust/TypeScript changes. With them, new visualizations are YAML changes in the oikos that owns the eidos. This enables oikoi to be truly self-contained: eide, desmoi, praxeis, AND presentation.

---

## Context

The **oikos-centric rendering** model places render-specs in the oikoi that own the eide they render. This inverts the traditional approach where a central UI system knows about all types.

- **opsis** — owns the rendering machinery (layouts, panels, renderers)
- **thyra** — owns the commitment boundary (streams, expressions)
- **each oikos** — owns render-specs for its eide

This document describes how render-specs are discovered, processed, and rendered in chora.

---

## The Rendering Pipeline

```
entity  →  eidos  →  render-type  →  renderer  →  render-spec  →  visual output
   ↓         ↓          ↓              ↓              ↓
 "what"   "type"    "semantic     "implementation"  "template"
 exists    of it     category"     (how to render)  (structure)
```

### Step by Step

1. **Entity arrives** — An entity needs to be rendered
2. **Determine render-type** — What semantic category? (card, detail, list-item)
3. **Select renderer** — Which renderer handles this render-type?
4. **Find render-spec** — If declarative, locate the render-spec entity
5. **Prepare data** — Execute data_preparation queries
6. **Render template** — Bind data to template, produce output

---

## Render-Spec Structure

```yaml
- eidos: render-spec
  id: render-spec/theoria-card
  data:
    for_eidos: theoria
    render_type: card
    description: |
      Compact card view of a theoria showing insight and status.

    template: |
      <entity-card>
        <card-header>
          <icon name="lightbulb" />
          <title>{{ entity.data.domain | capitalize }}</title>
          <status-badge status="{{ entity.data.status }}" />
        </card-header>
        <card-body>
          <insight-text>{{ entity.data.insight }}</insight-text>
        </card-body>
        <card-footer>
          <timestamp>{{ entity.data.crystallized_at | relative_time }}</timestamp>
          <source-tag>{{ entity.data.source }}</source-tag>
        </card-footer>
      </entity-card>

    data_preparation: |
      # Optional queries to gather additional data
      evidence = trace(entity.id, 'evidences', 'from')
      related = surface(entity.data.insight, limit: 3) | exclude(entity.id)
```

---

## Render Strategies

### 1. Core (Built-in)

Renderer is a static React/Solid component built into chora.

```yaml
- eidos: renderer
  id: renderer/core-entity-card
  data:
    render_strategy: core
    component: "EntityCard"  # Mapped to built-in component
```

**Implementation:** Direct import, no runtime resolution.

### 2. Declarative (Render-Spec)

Renderer processes a render-spec template.

```yaml
- eidos: renderer
  id: renderer/declarative-card
  data:
    render_strategy: declarative
    processor: "render-spec-processor"
```

**Implementation:** Template parsing, data binding, component composition.

### 3. Web Component

Renderer loads a Custom Element.

```yaml
- eidos: renderer
  id: renderer/web-component-diagram
  data:
    render_strategy: web-component
    element_name: "kosmos-diagram"
    module_url: "https://oikos.example/diagrams/kosmos-diagram.js"
```

**Implementation:** Dynamic import, Custom Element registration.

### 4. WASM

Renderer loads a WebAssembly module.

```yaml
- eidos: renderer
  id: renderer/wasm-graph-viz
  data:
    render_strategy: wasm
    module_url: "https://oikos.example/wasm/graph-viz.wasm"
    init_function: "init_renderer"
```

**Implementation:** WASM instantiation, memory bridge.

---

## Chora Implementation

### 1. Render-Spec Discovery

**At bootstrap:**

```rust
fn discover_render_specs(genesis_path: &Path) -> Vec<RenderSpec> {
    // Walk all oikoi
    // Find manifest.yaml, read content_paths
    // For paths with content_types including render-spec
    // Load and parse render-spec entities
}
```

**Index structure:**

```rust
struct RenderSpecIndex {
    // by_eidos["theoria"] = ["render-spec/theoria-card", "render-spec/theoria-detail"]
    by_eidos: HashMap<EidosId, Vec<RenderSpecId>>,

    // by_render_type["card"]["theoria"] = "render-spec/theoria-card"
    by_render_type: HashMap<RenderType, HashMap<EidosId, RenderSpecId>>,
}
```

### 2. Render-Spec Selection

Given an entity and desired render-type:

```rust
fn select_render_spec(
    entity: &Entity,
    render_type: RenderType,
    index: &RenderSpecIndex,
) -> Option<RenderSpecId> {
    // 1. Exact match: render-spec for this eidos + render-type
    if let Some(spec) = index.by_render_type.get(&render_type)?.get(&entity.eidos) {
        return Some(spec.clone());
    }

    // 2. Fallback: default render-spec for this render-type
    if let Some(spec) = index.by_render_type.get(&render_type)?.get("default") {
        return Some(spec.clone());
    }

    // 3. None found
    None
}
```

### 3. Data Preparation

Execute the `data_preparation` expression to gather additional data:

```rust
fn prepare_data(
    entity: &Entity,
    render_spec: &RenderSpec,
    store: &EntityStore,
) -> DataContext {
    let mut ctx = DataContext::new();
    ctx.set("entity", entity);

    if let Some(prep) = &render_spec.data.data_preparation {
        // Parse and execute preparation expressions
        let expressions = parse_preparation(prep);
        for expr in expressions {
            match expr {
                PrepExpr::Trace { from, desmos, direction, bind_to } => {
                    let results = store.trace(&from, &desmos, direction);
                    ctx.set(&bind_to, results);
                }
                PrepExpr::Surface { query, limit, bind_to } => {
                    let results = search_index.surface(&query, limit);
                    ctx.set(&bind_to, results);
                }
                PrepExpr::Filter { input, condition, bind_to } => {
                    let filtered = ctx.get(&input).filter(|e| eval(&condition, e));
                    ctx.set(&bind_to, filtered);
                }
            }
        }
    }

    ctx
}
```

### 4. Template Processing

Parse and render the template with bound data:

```rust
fn render_template(
    template: &str,
    ctx: &DataContext,
) -> RenderedOutput {
    // 1. Parse template into AST
    let ast = parse_template(template);

    // 2. Walk AST, resolve bindings
    let resolved = resolve_bindings(ast, ctx);

    // 3. Convert to component tree
    let components = to_component_tree(resolved);

    // 4. Return for rendering
    RenderedOutput { components }
}
```

### 5. Component Mapping

Map template elements to actual UI components:

| Template Element | UI Component | Notes |
|------------------|--------------|-------|
| `<entity-card>` | Card container | Standard card wrapper |
| `<card-header>` | Card.Header | Flexbox header |
| `<card-body>` | Card.Body | Content area |
| `<card-footer>` | Card.Footer | Metadata area |
| `<icon>` | Icon | Icon from set |
| `<status-badge>` | StatusBadge | Colored status pill |
| `<timestamp>` | Timestamp | Relative time display |
| `<action-button>` | ActionButton | Praxis invocation |
| `<section-collapsible>` | Collapsible | Expandable section |

---

## Template Syntax

### Variable Binding

```
{{ entity.data.field }}           # Direct field access
{{ entity.data.field | filter }}  # With filter
{{ items | length }}              # Computed value
```

### Filters

| Filter | Example | Output |
|--------|---------|--------|
| `capitalize` | `"theoria" \| capitalize` | "Theoria" |
| `relative_time` | `"2026-01-29T10:00:00Z" \| relative_time` | "2 hours ago" |
| `truncate(n)` | `"long text" \| truncate(10)` | "long te..." |
| `length` | `[1,2,3] \| length` | 3 |
| `first` | `[1,2,3] \| first` | 1 |
| `exclude(id)` | `items \| exclude(entity.id)` | Items without entity |

### Conditionals

```xml
<if condition="{{ entity.data.status == 'provisional' }}">
  <warning-banner>This theoria is provisional</warning-banner>
</if>

<switch value="{{ entity.data.status }}">
  <case match="crystallized">
    <icon name="check" color="green" />
  </case>
  <case match="provisional">
    <icon name="question" color="yellow" />
  </case>
  <default>
    <icon name="circle" color="gray" />
  </default>
</switch>
```

### Iteration

```xml
<for-each items="{{ evidence }}" as="e">
  <evidence-card entity="{{ e }}" />
</for-each>
```

### Slots and Composition

```xml
<entity-card>
  <slot name="header">
    <custom-header>{{ title }}</custom-header>
  </slot>
  <slot name="body">
    <custom-content />
  </slot>
</entity-card>
```

---

## Praxis Integration

### Action Buttons

Render-specs can include action buttons that invoke praxeis:

```xml
<action-button
  action="nous/confirm-theoria"
  params="{{ {theoria_id: entity.id} }}"
  label="Confirm"
  enabled="{{ entity.data.status == 'provisional' }}"
/>
```

**Implementation:**

```rust
fn handle_action_button_click(
    action: &str,       // "nous/confirm-theoria"
    params: Value,      // {theoria_id: "theoria/T21"}
    mcp_client: &McpClient,
) {
    // Parse action as praxis ID
    let praxis_id = format!("praxis/{}", action);

    // Invoke via MCP
    mcp_client.call_tool(&praxis_id, params).await;

    // Re-render on completion
}
```

### Navigation

```xml
<navigation-link
  target="{{ related_entity.id }}"
  label="{{ related_entity.data.title }}"
/>
```

---

## Opsis Praxeis for Rendering

### discover-render-specs

Discover all render-specs for an eidos:

```yaml
- eidos: praxis
  id: praxis/opsis/discover-render-specs
  data:
    oikos: opsis
    name: discover-render-specs
    visible: true
    description: |
      Find all render-specs available for an eidos.
      Returns specs from all oikoi that provide them.
    params:
      - name: eidos
        type: string
        required: true
    steps:
      - step: gather
        where:
          eidos: render-spec
          "$.data.for_eidos": "$eidos"
        bind_to: specs

      - step: return
        value: "$specs"
```

### render-entity

Render an entity using discovered render-spec:

```yaml
- eidos: praxis
  id: praxis/opsis/render-entity
  data:
    oikos: opsis
    name: render-entity
    visible: true
    description: |
      Render an entity using the appropriate render-spec.
      Selects spec based on eidos and render-type.
    params:
      - name: entity_id
        type: string
        required: true
      - name: render_type
        type: string
        required: false
        default: card
    steps:
      - step: find
        id: "$entity_id"
        bind_to: entity

      - step: call
        praxis: opsis/select-renderer
        params:
          eidos: "$entity.eidos"
          render_type: "$render_type"
        bind_to: renderer_info

      # Actual rendering happens in chora (UI layer)
      - step: return
        value:
          entity: "$entity"
          render_spec: "$renderer_info.render_spec"
          render_strategy: "$renderer_info.strategy"
```

---

## Widget System

Widgets are field-level renderers used within render-specs:

```yaml
- eidos: widget
  id: widget/timestamp-relative
  data:
    for_field_type: timestamp
    description: Renders timestamp as relative time ("2 hours ago")
    template: |
      <span class="timestamp-relative" title="{{ value | iso8601 }}">
        {{ value | relative_time }}
      </span>
```

### Widget Selection

```xml
<!-- Explicit widget -->
<field name="created_at" widget="widget/timestamp-relative" />

<!-- Auto-select by field type -->
<field name="created_at" />  <!-- Infers widget from field type -->
```

---

## Testing Strategy

### Unit Tests

1. **Template parsing:**
   - Parse template string
   - Verify AST structure
   - Test edge cases (nested tags, filters, conditionals)

2. **Data binding:**
   - Create DataContext with entity
   - Resolve `{{ entity.data.field }}`
   - Verify correct value

3. **Filter execution:**
   - Test each filter in isolation
   - Verify expected output

### Integration Tests

1. **Full render pipeline:**
   - Load render-spec from genesis
   - Create test entity
   - Call render-entity praxis
   - Verify output structure

2. **Data preparation:**
   - Create entity with bonds
   - Render with data_preparation that traces
   - Verify gathered data available in template

3. **Action buttons:**
   - Render entity with action button
   - Simulate click
   - Verify praxis invocation

### Visual Tests

1. **Component rendering:**
   - Render each component type
   - Compare to baseline screenshots

2. **Theme compliance:**
   - Render with different themes
   - Verify style variables applied

---

## Current Implementation Status

### Kosmos Render-Specs (Complete)

All core render-specs exist and are loaded:

| Component | Render-Spec | Status |
|-----------|-------------|--------|
| CircleList | render-spec/circle-card | ✅ Complete |
| JourneyList | render-spec/journey-card | ✅ Complete |
| PresenceList | render-spec/persona-card | ✅ Complete |
| ExpressionThread | render-spec/expression-card | ✅ Complete |
| TheoriaPanel | render-spec/theoria-card | ✅ Complete |
| CredentialPanel | render-spec/credential-item | ✅ Complete |

List-item variants also available: circle-list-item, journey-list-item, persona-item.

### Thyra CSS Support (Complete)

CSS classes aligned with render-spec structure:
- `.render-card` with `.card-header`, `.card-body`, `.card-footer`
- `.render-detail` with `.detail-header`, `.detail-body`, `.detail-footer`
- `.list-item` for compact views
- Badge components (`.domain-badge`, `.kind-badge`, `.mode-badge`)
- CSS variables for oikos-specific colors

### Current Rendering Approach

Thyra uses **hybrid rendering**: React/Solid components read render-spec metadata (fields_to_display, layout structure) but render via native components rather than parsing templates. This provides:
- Type safety from TypeScript
- Performance from compiled components
- Flexibility from render-spec metadata

---

## Dependencies

| Component | Location | Status |
|-----------|----------|--------|
| render-spec eidos | genesis/opsis/eide/ | ✅ Exists |
| widget eidos | genesis/opsis/eide/ | ✅ Exists |
| renderer eidos | genesis/opsis/eide/ | ✅ Exists |
| render-entity praxis | genesis/opsis/praxeis/ | ✅ Exists |
| Render-spec entities | genesis/*/entities/ | ✅ Complete |
| CSS component styles | thyra/src/styles/ | ✅ Complete |
| Template parser | chora/src/rendering/ | ⏳ Deferred (hybrid approach) |
| Data preparation executor | chora/src/rendering/ | ⏳ Deferred |
| Component mapping | chora/src/ui/ | ✅ Native components |

---

## Remaining Work

### Phase 1: Current (Complete)
- ✅ Render-specs defined in kosmos
- ✅ CSS structure aligned with specs
- ✅ Native components render entities

### Phase 2: Future (Optional)
- Full declarative template parsing
- Dynamic data_preparation execution
- Web component / WASM render strategies

The hybrid approach works well for the current scope. Full declarative rendering is optional enhancement.

---

## Questions for Chora Team

1. **Template engine:** Should we use an existing template engine (Handlebars, Tera) or build custom? Custom gives control, existing gives features.

2. **Component library:** What's the base component library? Are we using Solid, Leptos, or custom?

3. **SSR consideration:** Will render-specs need to render on server (for SEO/sharing)?

4. **Streaming:** For large lists, should rendering stream incrementally?

5. **Caching:** Should rendered output be cached? At what granularity?

6. **Error handling:** What renders when a render-spec has errors? Fallback component? Error boundary?

---

*This document prepared from kosmos session 2026-01-29.*
*Implementing team: chora/opsis+thyra*
