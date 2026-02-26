# Widget Homoiconicity — Schema-Driven Rendering

*Prompt for Claude Code in the chora repository context.*

---

## Methodology — Doc-Driven, Clean Break

This work follows **Doc → Test → Build → Verify Doc**, non-negotiably.

### The Cycle

1. **Doc (prescriptive)**: Write `docs/reference/widget-system.md` describing the *desired state* — how widgets are declared, instantiated, discovered, validated, and resolved. This doc is the specification.
2. **Test (assert the doc)**: Write tests that assert widget entities exist after bootstrap, that render-specs referencing unknown widgets are caught, that the registry is graph-driven. Tests should fail before implementation.
3. **Build (satisfy the tests)**: Implement until tests pass.
4. **Verify doc (confirm truth)**: After implementation, re-read the reference doc. Update deviations so the doc ends as truth.

### Clean Break — No Backward Compatibility

- **No dual registries.** The widget registry is either graph-driven or hardcoded. Not both. When this work is done, widget discovery traverses the graph — the old `widgetRegistry` object literal is gone.
- **No silent fallbacks.** If a render-spec references `widget: "nonexistent"`, that's a validation error caught at bootstrap — not a runtime "Unknown widget" div.
- **No orphaned declarations.** Every `eidos/widget` definition in genesis gets a corresponding widget entity instance. Every widget entity has a TypeScript implementation. The chain is complete or it's a build error.

### What "Reference Doc" Means

Reference docs in this project are *prescriptive* (target state), not descriptive (current state). When code doesn't match a reference doc, the code has a gap — not the doc (unless the design changed). See CONTRIBUTING.md for the full methodology.

---

## Context

The widget system today exists in two disconnected worlds:

**Homoiconic (genesis):**
- `eidos/widget` is defined in `genesis/thyra/eide/thyra.yaml` (lines 605–638) with fields: `name`, `description`, `field_types`, `component_path`, `editable`, `config_schema`
- `desmos/displays-as` connects field definitions to widgets (from_eidos: field-def, to_eidos: widget)
- Render-specs are entities in the graph, referencing widgets by string name

**Hand-written (TypeScript):**
- 40 SolidJS components in `app/src/lib/widgets/`
- Manual registry in `app/src/lib/widgets/index.ts` (lines 76–137): a `Record<string, Component>` mapping string names to components
- `getWidget(name)` does a dictionary lookup — zero graph traversal

**The gap:** Widget eidos is defined but **no widget entities are ever instantiated**. Bootstrap loads render-specs but doesn't create widget entities. The `displays-as` bond exists in the schema but is **never traversed at runtime**. Adding a widget requires writing TypeScript AND manually updating the registry — genesis is uninvolved.

---

## Current State

### What exists

| Layer | Status | Location |
|-------|--------|----------|
| Widget eidos definition | Defined | `genesis/thyra/eide/thyra.yaml:605–638` |
| `displays-as` desmos | Defined, never traversed | `genesis/thyra/desmoi/thyra.yaml:169–178` |
| Widget entity instances | **Not created** | — |
| TypeScript components | 40 hand-written | `app/src/lib/widgets/` |
| Widget registry | Hardcoded object literal | `app/src/lib/widgets/index.ts:76–137` |
| Widget lookup | String → component map | `app/src/lib/widgets/index.ts:146–158` |
| Render-spec → widget binding | String name in JSON | `app/src/lib/render-spec.tsx:112–119` |
| Render-spec validation | None — unknown widgets render as error div | — |

### Widget categories (40 components)

| Category | Widgets | Nature |
|----------|---------|--------|
| Layout | card, stack, row, list, list-item, grid | Structural — props only |
| Display | text, heading, badge, icon, image, code | Data display — props + content |
| Interactive | button, link | Event handlers |
| Form | input, textarea, select, checkbox, toggle | Bidirectional binding |
| Feedback | progress, avatar, spinner, tooltip, toast, skeleton, status-indicator | State display |
| Overlay | modal, confirm | Portal rendering |
| Navigation | steps, tabs, accordion | State management |
| Substrate | video, scroll, phaser-canvas | Platform-specific |
| Composition | form, artifact | Compound |

### The disconnection

Render-spec resolution today:

```
render-spec entity (graph) → node.widget = "card" (string) → widgetRegistry["card"] (hardcoded) → CardWidget (TypeScript)
```

What it should be:

```
render-spec entity (graph) → node.widget = "card" (string) → find widget/card (graph) → component_path (entity data) → resolved component
```

---

## Design

### Widget Entity Instances

For every TypeScript widget, a corresponding entity in genesis:

```yaml
# genesis/thyra/entities/widgets.yaml
- eidos: widget
  id: widget/card
  data:
    name: card
    description: "Container with optional header, border, and padding"
    field_types: [any]
    component_path: widgets/card
    editable: false

- eidos: widget
  id: widget/text
  data:
    name: text
    description: "Text display with variant support"
    field_types: [string]
    component_path: widgets/text
    editable: false
    config_schema:
      variant:
        type: enum
        values: [body, secondary, caption, heading]

# ... one entry per widget
```

### Bootstrap: Widget Entity Creation

Bootstrap already loads entities from `content_paths`. Adding `entities/widgets.yaml` to thyra's `content_paths` is sufficient — no new bootstrap code for entity creation.

### Render-Spec Validation at Bootstrap

After loading all content, validate that every render-spec's widget references resolve:

```
For each render-spec entity:
  Walk the layout tree (RenderSpecNode[])
  For each node.widget:
    Verify widget/{name} entity exists in graph
  Log error for any unresolvable widget reference
```

This catches broken render-specs at bootstrap, not at runtime.

### Graph-Driven Widget Registry (TypeScript)

Replace the hardcoded registry with a graph-populated one:

```typescript
// During app initialization, after bootstrap:
const widgetEntities = await client.gatherEntities("widget", 100);
const registry = new Map<string, WidgetMeta>();
for (const entity of widgetEntities) {
  registry.set(entity.data.name, {
    componentPath: entity.data.component_path,
    fieldTypes: entity.data.field_types,
    editable: entity.data.editable ?? false,
    configSchema: entity.data.config_schema,
  });
}
```

Widget components are still TypeScript (they must be — rendering is substrate-specific). But **discovery** is graph-driven. The registry is populated from entities, not from a hardcoded object literal.

### The `displays-as` Bond

Field-level widget customization via bond traversal:

```
field-def/phasis.content --displays-as--> widget/markdown-text
```

When rendering a field, the renderer traverses `displays-as` to find the appropriate widget instead of defaulting by field type.

---

## Implementation Order

### Step 1: Doc (prescriptive spec)

**Write `docs/reference/widget-system.md`** — the specification for the widget system:
- Widget eidos schema and what each field means
- How widget entities are created (genesis YAML, bootstrap loads them)
- How render-specs reference widgets (by name, validated at bootstrap)
- How the TypeScript registry is populated from the graph
- The `displays-as` bond: field-level widget customization
- Validation rules: what makes a valid widget declaration, what breaks

This doc describes the *desired end state*. Read it and ask: "if I only had this doc, could I implement the widget system?" If not, the doc is incomplete.

### Step 2: Genesis (constitutional content)

1. **Create `genesis/thyra/entities/widgets.yaml`** — one widget entity per existing TypeScript component (40 entries)
2. **Add `entities/` to thyra's `content_paths`** in `genesis/thyra/manifest.yaml` if not already present

### Step 3: Test (assert the doc)

3. **Write tests BEFORE implementation:**
   - Test: after bootstrap, `find widget/card` returns a widget entity
   - Test: after bootstrap, `gather(eidos: widget)` returns all 40 widgets
   - Test: render-spec referencing `widget: "nonexistent"` produces a validation error
   - Test: render-spec referencing `widget: "card"` passes validation
   - Test: `displays-as` bond from a field-def to a widget is traversable

   These tests SHOULD FAIL before implementation.

### Step 4: Build (satisfy the tests)

4. **Add render-spec validation** to bootstrap — walk layout trees, check widget references
5. **Replace hardcoded `widgetRegistry`** in `app/src/lib/widgets/index.ts` with graph-populated registry
6. **Update render-spec resolver** in `app/src/lib/render-spec.tsx` to use graph-populated registry
7. **Implement `displays-as` traversal** in the field renderer

### Step 5: Verify

8. **`cargo build && cargo test`** and **`cd app && npm run build`**
9. **Re-read `docs/reference/widget-system.md`** — does it match what was built? Update deviations
10. **Update `docs/REGISTRY.md`** impact map

---

## Files to Touch

### Kosmos (genesis)
- `genesis/thyra/entities/widgets.yaml` — new: 40 widget entity instances
- `genesis/thyra/manifest.yaml` — ensure `entities/` in content_paths

### Chora (Rust)
- `crates/kosmos/src/bootstrap.rs` — render-spec validation (widget reference checking)
- `crates/kosmos/tests/` — widget entity and render-spec validation tests

### Chora (TypeScript)
- `app/src/lib/widgets/index.ts` — replace hardcoded registry with graph-populated one
- `app/src/lib/render-spec.tsx` — update widget resolution to use new registry
- `app/src/lib/bindings.ts` — `displays-as` bond traversal for field-level widgets (if applicable)

### Docs (written FIRST, verified LAST)
- `docs/reference/widget-system.md` — widget system specification (prescriptive → verified)

---

## Verification

```bash
# Build
cargo build 2>&1

# Tests
cargo test 2>&1

# TypeScript build
cd app && npm run build 2>&1

# Verify widget entities exist after bootstrap
# (MCP: nous_find widget/card, nous_find widget/text, etc.)

# Verify gather returns all widgets
# (MCP: gather eidos=widget)

# Verify hardcoded registry is gone
rg 'widgetRegistry.*=' app/src/lib/widgets/index.ts
# Should show graph-populated assignment, not object literal
```

---

## What This Enables

When widgets are homoiconic:
- A topos can **discover** available widgets by querying `gather(eidos: widget)` — no TypeScript inspection needed
- Render-specs are **validated at bootstrap** — broken widget references caught before runtime
- Field-level display is **configurable via bonds** — `displays-as` makes widget selection traversable
- The path to **topos-provided widgets** opens: a topos defines a widget entity, provides the component, and render-specs can use it
- Widget metadata (field types, editability, config schema) is **queryable** — tooling can inspect what a widget accepts without reading TypeScript

The widget eidos already exists. This work instantiates it, validates against it, and makes the registry graph-driven. The TypeScript components remain hand-written (rendering is substrate-specific), but everything else — discovery, validation, binding — moves to the graph.
