# Mode-Absorbed Iteration — Directives Dissolve into Modes and Widgets

*Prompt for Claude Code in the chora + kosmos repository context.*

*Completes the mode architecture by absorbing iteration and composition from interpreter directives into modes (entity-level) and widgets (field-level). After this work, the interpreter has zero hardcoded widget names — it dispatches widgets, nothing else. Render-specs answer only "how does one entity appear." Modes answer "what entities, which specs, what arrangement."*

---

## Architectural Principle — The Interpreter Renders, Modes Compose

The interpreter's job is widget dispatch. Given a render-spec and an entity, it renders widgets. That's it.

Three hardcoded directives currently violate this:

```typescript
// render-spec.tsx — these must go
if (props.node.widget === "for-each") { ... }
if (props.node.widget === "include")  { ... }
if (props.node.widget === "form")     { ... }
```

These embed control flow in the interpreter. The architectural direction (T8: each mode has a single definitive render-spec, no conditionals) extends to all control flow:

| What | Current Home | Target Home |
|------|-------------|-------------|
| Entity-level iteration | `for-each` directive in interpreter | Mode `source_query` + layout engine |
| Render-spec composition | `include` directive in interpreter | Mode `item_spec_id` field |
| Conditional rendering | `when` property in interpreter | Mode switching (already transitional) |
| Field-level array iteration | `for-each` directive in interpreter | Widget `each` prop (generic) |
| Form context bridging | `form` directive in interpreter | FormWidget component (internal) |

The hierarchy after this work:

```
thyra-config                    ← which modes are active + window behavior
  └── mode                      ← topos presence in a spatial position
       ├── render_spec_id       ← widget tree for ONE entity (singleton modes)
       ├── item_spec_id         ← widget tree for EACH entity (collection modes)
       ├── source_query         ← what entities to gather
       ├── arrangement          ← scroll, stack, list, scroll-bottom
       ├── sections[]           ← compound modes: multiple sources + specs
       └── actuality-mode       ← substrate requirements (bonded)
```

---

## The Two Kinds of Iteration

### Entity-level (mode absorbs)

"Show all phaseis in this thread" — gathering entities and rendering each one.

**Before:** Mode gathers entities → passes to list render-spec → `for-each` iterates → `include` references card spec.

**After:** Mode declares `item_spec_id` and `arrangement`. Layout engine gathers, iterates, renders each entity with the item spec. No list render-spec needed.

```yaml
# BEFORE
mode/phasis-feed:
  render_spec_id: render-spec/phasis-thread    # ← list spec with for-each + include
  source_query: "gather(eidos: phasis, sort: expressed_at, order: desc)"

# AFTER
mode/phasis-feed:
  item_spec_id: render-spec/phasis-bubble      # ← renders ONE phasis
  source_query: "gather(eidos: phasis, sort: expressed_at, order: desc)"
  arrangement: scroll-bottom
  empty_message: "No phaseis yet"
```

### Field-level (widget handles)

"Show each tag on this note as a badge" — iterating over an entity's own array field.

This is the spec's job. The spec knows the eidos structure. But the mechanism should be generic — a property any render-spec node can carry, like `when:` was.

**`each`** — a generic property on any render-spec node:

```yaml
# BEFORE (interpreter directive)
- widget: for-each
  props: { source: "{tags}" }
  children:
    - widget: badge
      props: { content: "{value}" }

# AFTER (generic node property)
- widget: row
  each: "{tags}"
  each_empty: "No tags"
  children:
    - widget: badge
      props: { content: "{.}" }
```

The interpreter handles `each` uniformly before widget dispatch — the same way it currently handles `when`. Any node can carry `each`. The interpreter resolves the array, renders children per item with item as binding context.

**Why `each` is not like `when`:** `when` is conditional logic (should this exist?) — that's a mode concern, and `when` is transitional. `each` is data display (how does this entity's array field look?) — that's genuinely the spec's responsibility.

---

## Current State

| Component | Location | Status |
|-----------|----------|--------|
| **Mode eidos** | `genesis/thyra/eide/mode.yaml` | Has `source_entity_id`, `source_query`, `render_spec_id`. Missing `item_spec_id`, `arrangement`, `sections`. |
| **Layout engine** | `app/src/lib/layout-engine.tsx` | Groups modes by spatial position, gathers source entities, passes to RenderSpecRenderer. Does NOT iterate per-entity — passes whole collection. |
| **Interpreter directives** | `app/src/lib/render-spec.tsx:100-109` | Three hardcoded branches: `for-each`, `include`, `form`. |
| **Widget entities** | `genesis/thyra/eide/widget.yaml:1285-1325` | `widget/for-each` and `widget/include` defined with `category: composition`. |
| **List render-specs** | Various | `phasis-thread`, `theoria-list`, `oikos-list` — all boilerplate wrappers around `for-each` + `include`. |
| **Mode entities** | `genesis/thyra/entities/layout.yaml` | 6 modes, all use `render_spec_id`. Collection modes use `source_query`. |
| **Layout bonds** | Same file | 6 `uses-render-spec` bonds from modes to render-specs. |
| **Form widget** | `app/src/lib/widgets/form.tsx` | FormWidget provides form registration context via SolidJS context. Directive bridges this into BindingContext. |

---

## Methodology — Doc-Driven, Test-Driven

This work follows **Doc -> Test -> Build -> Verify Doc**, non-negotiably.

1. **Doc (prescriptive)**: This prompt IS the prescriptive doc.
2. **Test (assert the doc)**: Write tests that assert the new mode fields, layout engine iteration, `each` property handling, and absence of directives.
3. **Build (satisfy the tests)**: Implement until tests pass.
4. **Verify doc**: After implementation, update this prompt's status.

### Clean Break — No Backward Compatibility

- **No interpreter directives.** Zero hardcoded widget names in `render-spec.tsx`. The interpreter renders widgets, period.
- **No list render-specs as for-each wrappers.** Collection modes iterate directly. The list render-specs dissolve.
- **No `widget/for-each` or `widget/include` entities.** These are not widgets. Remove from genesis.
- **`when` remains transitional.** It still works but should not appear in new render-specs. New variation = new mode.

---

## Phase 1 — Mode-Absorbed Entity Iteration

The largest impact change. Collection modes gain `item_spec_id` and `arrangement`.

### 1a. Update mode eidos

In `genesis/thyra/eide/mode.yaml`, add fields:

```yaml
item_spec_id:
  type: string
  required: false
  description: |
    Render-spec for each entity in a collection mode.
    When present, the layout engine iterates source entities
    and renders each with this spec. Mutually exclusive with
    render_spec_id for collection modes.

arrangement:
  type: string
  required: false
  description: |
    How items are laid out in a collection mode.
    Values: scroll, scroll-bottom, stack, list, grid
    Only meaningful when item_spec_id is set.

empty_message:
  type: string
  required: false
  description: "Text shown when source_query returns no entities"

chrome_spec_id:
  type: string
  required: false
  description: |
    Optional render-spec for surrounding chrome (heading, etc.)
    rendered once, with the mode's context entity.

sections:
  type: array
  required: false
  description: |
    For compound modes: multiple data sources with their own specs.
    Each section has: heading?, source_query, item_spec_id, arrangement.
    Mutually exclusive with item_spec_id at the mode level.
```

### 1b. Migrate mode entities

Update `genesis/thyra/entities/layout.yaml`:

```yaml
# Collection modes: replace render_spec_id with item_spec_id + arrangement
mode/oikos-nav:
  item_spec_id: render-spec/oikos-card
  arrangement: scroll
  empty_message: "No oikoi"
  chrome_spec_id: render-spec/oikos-chrome     # heading "Oikoi"
  # remove: render_spec_id: render-spec/oikos-list

mode/theoria-sidebar:
  item_spec_id: render-spec/theoria-card
  arrangement: scroll
  empty_message: "No theoria yet"
  # remove: render_spec_id: render-spec/theoria-list

mode/phasis-feed:
  item_spec_id: render-spec/phasis-bubble
  arrangement: scroll-bottom
  empty_message: "No phaseis yet"
  # remove: render_spec_id: render-spec/phasis-thread

# Singleton modes: unchanged
mode/text-composing:
  render_spec_id: render-spec/text-compose     # ← stays as-is
mode/voice-composing:
  render_spec_id: render-spec/voice-bar        # ← stays as-is
```

### 1c. Update layout engine

In `app/src/lib/layout-engine.tsx`, the mode rendering logic:

**Current:** All modes render via `RenderSpecRenderer(renderSpecId, contextEntity)`.

**New:** Branch on mode type:
- `render_spec_id` only (singleton) → `RenderSpecRenderer(specId, entity)` — unchanged
- `item_spec_id` (collection) → gather entities, wrap in arrangement widget, render each via `RenderSpecRenderer(itemSpecId, entity)`
- `sections` (compound) → render each section as a sub-collection

The arrangement maps to wrapper widgets: `scroll` → ScrollWidget, `stack` → StackWidget, `scroll-bottom` → ScrollWidget with `auto_scroll_bottom`, etc.

### 1d. Update bonds

Replace `uses-render-spec` bonds for collection modes:
- `mode/oikos-nav → render-spec/oikos-card` via `uses-render-spec`
- `mode/theoria-sidebar → render-spec/theoria-card` via `uses-render-spec`
- `mode/phasis-feed → render-spec/phasis-bubble` via `uses-render-spec`

### 1e. Remove dissolved render-specs

Delete list render-specs that were just `for-each` + `include` wrappers:
- `render-spec/oikos-list` (if it exists as entity/file)
- `render-spec/theoria-list`
- `render-spec/phasis-thread`

If these have useful chrome (headings, etc.), extract to `chrome_spec_id` on the mode.

### 1f. Tests

- Layout engine renders collection mode: gathers entities, renders each with item_spec
- Layout engine renders singleton mode: unchanged behavior
- Layout engine handles empty collection with empty_message
- Layout engine renders chrome_spec_id when present
- Mode eidos validates: item_spec_id XOR render_spec_id required

---

## Phase 2 — Field-Level `each` Property

### 2a. Extend RenderSpecNode

In `app/src/lib/render-spec.tsx`, add `each` and `each_empty` to the node interface:

```typescript
interface RenderSpecNode {
  widget: string;
  props?: Record<string, unknown>;
  children?: RenderSpecNode[];
  when?: string;        // existing — transitional
  each?: string;        // NEW — field-level iteration
  each_empty?: string;  // NEW — empty message for each
}
```

### 2b. Handle `each` generically in WidgetNodeRenderer

Before widget dispatch, check for `each`. If present:
1. Resolve the array from the binding context
2. If empty and `each_empty` present, render empty message
3. For each item, render children with item as binding context

This follows the same pattern as the existing `when` handling — a generic property processed before widget dispatch.

### 2c. Update render-spec output schema

In `genesis/demiurge/typos/thyra-generation.yaml`, the `widget_node` schema's `$defs` should include `each` and `each_empty` as optional properties.

### 2d. Tests

- `each` on a row: renders children per item
- `each` with empty array: shows `each_empty` message
- `each` on a card: renders card per item (composes with widget)
- `each` absent: normal widget rendering (no behavior change)

---

## Phase 3 — Remove Interpreter Directives

### 3a. Remove directive branches

In `app/src/lib/render-spec.tsx`, remove:
- `ForEachDirective` component and its `if` branch
- `IncludeDirective` component and its `if` branch
- `IncludedRenderSpec` helper component
- `FormDirective` — replace with FormWidget handling context internally

### 3b. Internalize form context bridging

Move the form context bridge INTO the FormWidget component. The FormWidget already provides `FormRegistrationContext`. The bridging into `BindingContext` should happen inside the widget, not in the interpreter. This may require the widget to receive the current `BindingContext` as a prop (which the interpreter already resolves).

### 3c. Remove widget entities

In `genesis/thyra/eide/widget.yaml`:
- Remove `widget/for-each` entity
- Remove `widget/include` entity

### 3d. Update widget vocabulary docs

In `genesis/demiurge/RENDER-SPEC-GUIDE.md` and `genesis/demiurge/typos/thyra-generation.yaml`:
- Remove `for-each` and `include` from widget vocabulary
- Add `each` as a node property alongside `when`
- Document: entity-level iteration lives in modes, field-level uses `each`

### 3e. Tests

- Interpreter has no hardcoded widget name checks
- `widget: for-each` renders as "Unknown widget" (it's no longer handled)
- FormWidget works without FormDirective (context bridging internal)
- Existing render-specs that used directives are migrated or removed

---

## Phase 4 — Compound Modes (Optional, if time allows)

### 4a. Support `sections` on mode entities

A compound mode with multiple data sources:

```yaml
mode/topos-detail:
  spatial: { position: center, height: fill }
  source_entity_id: "topos/demiurge"
  chrome_spec_id: render-spec/topos-header
  sections:
    - heading: "Praxeis"
      source_query: "trace(from: self, desmos: provides-praxis)"
      item_spec_id: render-spec/praxis-card
      arrangement: scroll
    - heading: "Eide"
      source_query: "trace(from: self, desmos: provides-eidos)"
      item_spec_id: render-spec/eidos-card
      arrangement: scroll
```

### 4b. Layout engine handles sections

For each section: resolve `source_query` (potentially relative to `source_entity_id` via `self`), gather entities, render section heading, iterate with `item_spec_id`.

---

## What Dissolves

| Gone | Why |
|------|-----|
| `ForEachDirective` | Mode engine iterates (entity-level), `each` prop handles (field-level) |
| `IncludeDirective` | Mode declares `item_spec_id` directly |
| `IncludedRenderSpec` | No longer needed |
| `FormDirective` | FormWidget handles context internally |
| `widget/for-each` entity | Not a widget |
| `widget/include` entity | Not a widget |
| `render-spec/oikos-list` | Mode IS the list configuration |
| `render-spec/theoria-list` | Mode IS the list configuration |
| `render-spec/phasis-thread` | Mode IS the list configuration |
| Registry warning | No pseudo-widgets in the graph |

## What Emerges

| New | Purpose |
|-----|---------|
| `mode.item_spec_id` | Per-entity rendering in collection modes |
| `mode.arrangement` | Layout of items: scroll, stack, grid |
| `mode.empty_message` | Empty state for collections |
| `mode.chrome_spec_id` | Surrounding chrome (headings, etc.) |
| `mode.sections[]` | Compound modes with multiple sources |
| `each` node property | Field-level array iteration in render-specs |
| `each_empty` node property | Empty message for field-level arrays |

---

## Verification

After all phases:

1. `cargo test -p kosmos --lib --tests` — all pass
2. `npm test` in app/ — render-spec tests pass with `each` property
3. `just dev` — Thyra loads, phasis feed scrolls, oikos nav lists oikoi, theoria sidebar lists theoria
4. Zero hardcoded widget names in `render-spec.tsx`
5. Zero `for-each` or `include` widget references in any render-spec
6. No `widget/for-each` or `widget/include` in the widget registry
