# Bond Traversal in Render-Specs — Reading Across Entity Boundaries

*Prompt for Claude Code in the chora + kosmos repository context.*

*After this work, render-specs can reference data from bonded entities via `@bond-name` syntax. A compose bar render-spec can read `@fed-by-audio.data.intent` to show mic state without custom interpreter logic. Bond traversal is a binding extension — one graph hop before data resolution.*

---

## Architectural Principle — Graph-Native Rendering

T7 says: "How content displays is embodied as entities. Rendering is graph-traversable."

Currently, a render-spec binds to ONE entity. `{content}` reads `entity.data.content`. But some presentations need data from multiple related entities — the compose bar needs accumulation content AND audio-source intent AND transcriber status. These entities are bonded in the graph.

The graph-native answer: traverse bonds in the binding expression. `@fed-by-audio` means "follow the bond named `fed-by-audio` from my entity." This is one hop — not arbitrary graph traversal. The interpreter already resolves entity data into bindings; this adds one edge traversal before resolution.

No second mechanism (context injection, prop drilling, entity merging). Bonds are how entities relate. The render-spec reads across bonds. One right way.

---

## Methodology — DDD + TDD

This work follows **Doc → Test → Build → Verify**, non-negotiably.

1. **Doc (prescriptive)**: This prompt IS the prescriptive doc.
2. **Test (assert the doc)**: Write tests that assert `@bond-name` resolution works.
3. **Build (satisfy the tests)**: Implement binding extension.
4. **Verify doc**: After implementation, update success criteria.

**Pure extension, no breaking changes.** Existing `{field}` bindings are untouched. `@` syntax is additive.

---

## Current State

### What Exists and Works

| Component | Location | Status |
|-----------|----------|--------|
| `{field}` binding | `app/src/lib/bindings.ts` | Working — resolves `entity.data.field` |
| `{field.nested}` binding | `app/src/lib/bindings.ts` | Working — dot-path traversal |
| `{id}`, `{eidos}` binding | `app/src/lib/bindings.ts` | Working — entity metadata |
| `{.}` item binding | `app/src/lib/bindings.ts` | Working — `each` iteration |
| `$form.*` binding | `app/src/lib/bindings.ts` | Working — form context |
| `traceBonds()` API | `app/src/stores/kosmos.ts` | Working — fetches bonds from kosmos |
| `Bond` interface | `app/src/stores/kosmos.ts` | Defined — `{ from_id, to_id, desmos, data? }` |
| Bond WebSocket events | `app/src/stores/kosmos.ts` | Working — `bond_created`, `bond_deleted` |
| `WidgetNodeRenderer` | `app/src/lib/render-spec.tsx` | Working — generic widget dispatch |
| `resolveProps()` | `app/src/lib/bindings.ts` | Working — resolves all prop bindings |

### What's Missing — The Gaps

1. **No `@bond-name` syntax in binding resolution.** `resolveBindingValue()` does not recognize `@` prefix. A render-spec cannot reference data from a bonded entity.

2. **No bonded entity fetching during rendering.** `RenderSpecRenderer` fetches one entity. It has no mechanism to fetch bonded entities for the binding context.

3. **No bond cache per render cycle.** If multiple widgets in one render-spec reference the same `@bond-name`, the bonded entity should be fetched once, not per-widget.

4. **No reactive update on bond change.** If the bonded entity changes, the render-spec should re-render. Currently only the primary entity triggers re-render.

---

## Target State

### Binding Syntax Extension

The `@` prefix triggers bond traversal. Resolution: from the current entity, follow the bond with the given desmos name, fetch the target entity, and resolve the remaining path against it.

```
@bond-name.data.field     →  follow bond "bond-name" from entity, read target.data.field
@bond-name.id             →  follow bond "bond-name" from entity, read target.id
@bond-name.eidos          →  follow bond "bond-name" from entity, read target.eidos
@bond-name.data           →  follow bond "bond-name" from entity, read target.data (object)
```

Examples in a compose bar render-spec:

```yaml
# Mute button reads audio-source intent via bond
- widget: button
  props:
    icon: "{{ @fed-by-audio.data.intent == 'capturing' ? 'mic' : 'mic-off' }}"
    label: "{{ @fed-by-audio.data.intent == 'capturing' ? 'Mute' : 'Unmute' }}"
    on_click: soma/toggle-audio-intent
    on_click_params:
      entity_id: "{{ @fed-by-audio.id }}"
      intent: "{{ @fed-by-audio.data.intent == 'capturing' ? 'stopped' : 'capturing' }}"

# Transcription button reads transcriber state via bond
- widget: button
  props:
    icon: "{{ @fed-by-transcriber.data.intent == 'transcribing' ? 'mic-lines' : 'mic-off-lines' }}"
    on_click: soma/toggle-transcriber-intent
    on_click_params:
      entity_id: "{{ @fed-by-transcriber.id }}"
```

### Bond Context in Rendering Pipeline

```typescript
interface BondContext {
  // Maps desmos name → target entity
  // Populated lazily on first @-reference, cached for render cycle
  bondedEntities: Map<string, Entity | null>;
}

interface BindingContext {
  id: string;
  eidos: string;
  data: Record<string, unknown>;
  formContext?: FormContext;
  bondContext?: BondContext;    // NEW — populated by RenderSpecRenderer
}
```

### Resolution Algorithm

```
resolveBindingValue(key, context):
  if key starts with "@":
    bondName = key.split(".")[0].slice(1)   // "@fed-by-audio.data.intent" → "fed-by-audio"
    remainingPath = key.split(".").slice(1)  // ["data", "intent"]

    entity = context.bondContext.get(bondName)
    if entity is null (not yet fetched):
      entity = await fetchBondedEntity(context.id, bondName)
      context.bondContext.set(bondName, entity)

    if entity is undefined (bond doesn't exist):
      return undefined   // Graceful — missing bond renders as empty

    // Resolve remaining path against bonded entity
    return resolveNestedPath(entityToObj(entity), remainingPath.join("."))

  // ... existing resolution for {field}, {.}, $form, etc.
```

### Conditional Support

`when` expressions also support `@` syntax:

```yaml
- widget: badge
  when: "@fed-by-audio.data.intent == 'capturing'"
  props:
    label: "Live"
    variant: "success"
```

### Reactive Updates

When a bonded entity changes (via WebSocket event), the render-spec re-renders:
- `EntityBoundModeRenderer` subscribes to bond target entity IDs
- On change, re-fetches bonded entity, updates bond context
- Existing SolidJS reactivity propagates to widget tree

---

## Sequenced Work

### Phase 1: Binding Extension

**Goal:** `@bond-name.data.field` resolves in binding expressions.

**Tests (frontend — vitest):**
- `test_at_binding_parses_bond_name` — `@fed-by-audio.data.intent` extracts bond name "fed-by-audio" and path "data.intent"
- `test_at_binding_resolves_from_bond_context` — with a pre-populated bondContext, `@fed-by-audio.data.intent` returns "capturing"
- `test_at_binding_missing_bond_returns_undefined` — `@nonexistent.data.field` returns undefined (no error)
- `test_at_binding_in_string_interpolation` — `"Mic: {{ @fed-by-audio.data.intent }}"` resolves to `"Mic: capturing"`
- `test_at_binding_id_and_eidos` — `@fed-by-audio.id` returns entity ID, `@fed-by-audio.eidos` returns "audio-source"

**Implementation:**

1. Extend `BindingContext` interface in `app/src/lib/bindings.ts`:
   - Add `bondContext?: BondContext` field
   - `BondContext` is `{ bondedEntities: Map<string, Entity | null> }`

2. Extend `resolveBindingValue()` in `app/src/lib/bindings.ts`:
   - Detect `@` prefix
   - Extract bond name (first segment after `@`)
   - Look up bonded entity from `bondContext.bondedEntities`
   - Resolve remaining path against bonded entity data
   - Return undefined if bond not found (graceful degradation)

3. Extend `resolveBinding()` (string interpolation) to handle `@` in `{{ }}` templates.

4. Extend `evaluateWhen()` in `app/src/lib/conditions.ts` to handle `@bond-name` references in condition expressions.

**Phase 1 Complete When:**
- [ ] Unit tests pass for `@` binding resolution
- [ ] No changes to existing `{field}` binding behavior
- [ ] Missing bonds return undefined, not errors

### Phase 2: Bond Fetching in Render Pipeline

**Goal:** `RenderSpecRenderer` populates `bondContext` by tracing bonds from the primary entity.

**Tests (frontend — vitest):**
- `test_render_spec_fetches_bonded_entities` — a render-spec with `@fed-by-audio.data.intent` causes `traceBonds(entityId)` to be called
- `test_bond_cache_per_render` — multiple widgets referencing same `@fed-by-audio` only fetch once
- `test_bond_context_created_from_entity_bonds` — given entity with bonds, bondContext is populated correctly

**Implementation:**

1. In `RenderSpecRenderer` (or `EntityBoundModeRenderer`):
   - After fetching primary entity, scan render-spec layout for `@` references
   - Extract unique bond names from all props/when expressions
   - Call `traceBonds(fromId: entityId)` to get all outbound bonds
   - For each referenced bond name, match by desmos, fetch target entity via `findEntity()`
   - Build `BondContext` with results
   - Pass into `createBindingContext()`

2. Optimize: scan render-spec once to extract all `@bond-name` references. Batch-fetch all bonded entities.

3. Cache: `bondContext.bondedEntities` is a Map populated once per render cycle. Subsequent `@` references for the same bond name hit the cache.

**Phase 2 Complete When:**
- [ ] Render-spec with `@` bindings fetches bonded entities
- [ ] Bond cache prevents duplicate fetches
- [ ] Rendering works with primary entity having zero bonds (bondContext empty, `@` returns undefined)

### Phase 3: Reactive Bond Updates

**Goal:** When a bonded entity changes, the render-spec re-renders with fresh data.

**Tests (frontend — vitest):**
- `test_bonded_entity_change_triggers_rerender` — mock entity change event for bonded entity → bondContext refreshes
- `test_bond_created_triggers_rerender` — new bond created to entity → bondContext gains new entry
- `test_bond_deleted_triggers_rerender` — bond removed → bondContext loses entry

**Implementation:**

1. In `EntityBoundModeRenderer`:
   - After populating bondContext, subscribe to change events for all bonded entity IDs
   - On bonded entity change → refetch bonded entity, update bondContext
   - SolidJS reactivity propagates: bondContext signal → binding re-evaluation → widget re-render

2. Subscribe to bond events (bond_created, bond_deleted) for the primary entity:
   - On bond change → rescan, refetch bondContext
   - Handles: new bond added at runtime, bond removed at runtime

**Phase 3 Complete When:**
- [ ] Bonded entity update triggers re-render
- [ ] Bond creation/deletion updates bondContext reactively
- [ ] No memory leaks (subscriptions cleaned up on unmount)

### Phase 4: Integration Verification

**Goal:** End-to-end: a render-spec with `@` bindings works in the running app.

**Tests (manual or E2E):**
- Create two entities bonded together
- Create a render-spec that references `@bond-name.data.field`
- Create a mode that uses the render-spec with entity A as source
- Verify: field from entity B appears in rendered output
- Update entity B → verify render-spec updates reactively

**Implementation:**
1. Create test genesis entities (optional — may use existing audio-source/accumulation)
2. Run `just dev`
3. Verify render-spec resolves `@` bindings correctly in browser

**Phase 4 Complete When:**
- [ ] `@` bindings resolve in running app
- [ ] Reactive updates work (change bonded entity → UI updates)

---

## Files to Read

### Frontend (understand current binding system)
- `app/src/lib/bindings.ts` — current binding resolution: `resolveBindingValue`, `resolveBinding`, `resolveProps`, `createBindingContext`
- `app/src/lib/conditions.ts` — `evaluateWhen` for conditional rendering
- `app/src/lib/render-spec.tsx` — `RenderSpecRenderer`, `WidgetNodeRenderer`, `WidgetTree`
- `app/src/lib/layout-engine.tsx` — `EntityBoundModeRenderer`, `CollectionModeRenderer`
- `app/src/stores/kosmos.ts` — `traceBonds`, `findEntity`, `onEntityChange`
- `app/src/lib/executor-context.tsx` — executor pattern for event handlers

### Genesis (understand bond patterns)
- `genesis/arche/desmoi/arche.yaml` — `composed-from` and other arche-level desmoi

### Tests
- `app/vitest.config.ts` — frontend test configuration
- `app/src/test-setup.ts` — test setup and mocking

---

## Files to Touch

| File | Change |
|------|--------|
| `app/src/lib/bindings.ts` | **MODIFY** — add `BondContext` interface, extend `resolveBindingValue()` for `@` prefix, extend `resolveBinding()` for `@` in interpolation |
| `app/src/lib/conditions.ts` | **MODIFY** — extend `evaluateWhen()` for `@` in condition expressions |
| `app/src/lib/render-spec.tsx` | **MODIFY** — scan layout for `@` references, populate `bondContext` in `WidgetTree` |
| `app/src/lib/layout-engine.tsx` | **MODIFY** — `EntityBoundModeRenderer` fetches bonds, creates `bondContext`, subscribes to bonded entity changes |
| `app/src/stores/kosmos.ts` | **MODIFY** (if needed) — may need helper for batch bond+entity fetch |

---

## Success Criteria

- [ ] `@bond-name.data.field` resolves in render-spec bindings
- [ ] `@bond-name.id` and `@bond-name.eidos` resolve
- [ ] Missing bonds return undefined (graceful, no error)
- [ ] Bond cache prevents duplicate entity fetches per render cycle
- [ ] Bonded entity changes trigger reactive re-render
- [ ] Bond creation/deletion updates bondContext
- [ ] `when: "@bond-name.data.field == 'value'"` works in conditionals
- [ ] All existing binding tests still pass (no regressions)
- [ ] Frontend test suite passes: `cd app && npm test`

---

## What This Enables

- **Compose bar render-specs** can read audio-source and transcriber state via bonds
- **Any render-spec** can reference bonded entity data — one-hop graph traversal in presentation
- **Multi-entity views** without custom interpreter logic or context injection
- **Bond-driven presentation** — bonds shape what is visible, not just what is related

---

## What Does NOT Change

- `{field}` binding syntax — untouched
- `{field.nested}` traversal — untouched
- `$form.*` bindings — untouched
- `{.}` item bindings — untouched
- Widget registry and dispatch — untouched
- Mode system (entity-bound, collection, compound, singleton) — untouched
- Backend (Rust) — untouched. Bond traversal is purely a frontend binding extension
- `each` iteration — untouched
- Event handler resolution — untouched (but `@` syntax works in `on_click_params`)

---

*Traces to: T7 (rendering is graph-traversable), T8 (mode is topos presence), Compose Bar Design Dialogue (bond traversal as the one right way for multi-entity rendering)*
