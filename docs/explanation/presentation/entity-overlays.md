# Entity Overlays

*How local state changes appear instantly without a database roundtrip.*

---

## The Problem

A user types into the voice bar textarea. Each keystroke should appear immediately. But the entity lives in the kosmos database, accessed via HTTP. A roundtrip per keystroke would be sluggish and wasteful.

---

## The Overlay Pattern

Overlays are local, in-memory patches applied on top of fetched entity data. They exist only in the browser — never persisted, never synced.

```
Database entity              Local overlay              Merged entity
┌──────────────────┐    ┌───────────────────┐    ┌──────────────────────┐
│ id: acc/default   │    │ { content: "hi" } │    │ id: acc/default       │
│ data:             │ +  │                   │ =  │ data:                 │
│   content: ""     │    │                   │    │   content: "hi"       │
│   capture_state:  │    └───────────────────┘    │   capture_state:      │
│     inactive      │                              │     inactive          │
└──────────────────┘                              └──────────────────────┘
```

### Three Functions

```typescript
// Set a field locally (no DB call)
setEntityFieldLocal(entityId, field, value, eidos)

// Read the current overlay (returns undefined if none)
getEntityOverlay(entityId): Record<string, unknown> | undefined

// Remove the overlay (after commit or reset)
clearEntityOverlay(entityId)
```

### How the Layout Engine Merges

The `EntityBoundModeRenderer` in [layout-engine.tsx](../../app/src/lib/layout-engine.tsx) merges overlays reactively:

```typescript
const entity = createMemo(() => {
  const base = baseEntity();          // From DB via HTTP
  if (!base) return null;
  const overlay = getEntityOverlay(entityId());  // Local patches
  if (overlay) {
    return { ...base, data: { ...base.data, ...overlay } };
  }
  return base;
});
```

The overlay signal (`overlayVersion`) triggers SolidJS reactivity. When `setEntityFieldLocal` is called, the memo recomputes and the widget tree re-renders with the merged data.

---

## When Overlays Are Used

### Voice Bar — Per-Keystroke Updates

The voice bar textarea uses `on_input: ui/update-entity-field`, which calls `setEntityFieldLocal`:

```yaml
- widget: textarea
  props:
    name: content
    value: "{content}"                    # Reads merged entity data
    on_input: ui/update-entity-field      # Fires per keystroke
    on_input_params:
      entity_id: "{id}"
      field: content
      value: $event.target.value          # Current keystroke value
      eidos: accumulation
```

Flow per keystroke:
1. User types a character
2. `on_input` fires → `ui/update-entity-field`
3. `setEntityFieldLocal("accumulation/default", "content", "h")`
4. Overlay signal increments
5. `EntityBoundModeRenderer` memo recomputes
6. `{content}` binding picks up merged value
7. Textarea `value` updates (though DOM already has it — this keeps entity state in sync)

### Voice Transcription — Server Writes + Local Reads

When voice transcription arrives, the server updates the entity via praxis. A WebSocket event triggers refetch of the base entity. The overlay (if any) merges on top, so the user sees both their manual edits and incoming transcription.

---

## When Overlays Are NOT Used

### Text Compose — Form Pattern

The text compose mode uses the [form pattern](../../how-to/presentation/form-based-mode.md) instead:

```yaml
- widget: form
  children:
    - widget: textarea
      props:
        name: content
        value: "{content}"
        # No on_input — no overlay updates
    - widget: button
      props:
        on_click: thyra/commit-phasis
        on_click_params:
          content: $form.content    # Read DOM at click time
```

No overlays, no per-keystroke events. The DOM holds the truth until the user clicks send. The form pattern is simpler and has zero typing overhead.

---

## Overlay Lifecycle

```
1. Entity fetched from DB (base)
2. User types → setEntityFieldLocal → overlay created
3. Each keystroke → overlay updated → widget re-renders
4. User clicks send → praxis runs → server clears entity
5. WebSocket event → base entity refetched (now empty)
6. clearEntityOverlay called → overlay removed
7. Widget shows empty state (fresh for next input)
```

If the user types but never sends, the overlay persists in memory until the page reloads or the overlay is explicitly cleared.

---

## Implementation Details

Overlays are stored in a simple `Map<string, Record<string, unknown>>`:

```typescript
const entityOverlays = new Map<string, Record<string, unknown>>();
const [overlayVersion, setOverlayVersion] = createSignal(0);
```

The `overlayVersion` signal is a coarse-grained reactivity trigger. Any overlay change bumps the version, causing all overlay-dependent memos to recompute. This is intentionally simple — the number of simultaneous overlays is small (typically 1, the accumulation entity).

---

## Related

- [Two-Phase Binding Resolution](two-phase-bindings.md) — How `{field}` reads merged entity data
- [Phasis Workspace Reference](../../reference/domain/phasis-workspace.md) — Accumulation entity schema
- [Creating a Form-Based Mode](../../how-to/presentation/form-based-mode.md) — The no-overlay alternative

---

*Understanding crystallized from the voice bar implementation — optimistic local state for real-time input.*
