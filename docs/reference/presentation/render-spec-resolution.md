# Render-Spec Resolution

*How the interpreter discovers which render-spec to use for a given entity.*

**Status: PRESCRIPTIVE** — describes target state. Current implementation uses only literal resolution (step 1). Graph discovery (step 2) is development scope.

---

## Resolution Order

Two mechanisms, checked in order:

1. **Literal**: Mode declares `render_spec_id` — use that render-spec directly
2. **Graph Discovery**: Traverse from entity's eidos through bonds to find applicable render-spec

If neither resolves, the mode renders nothing (no fallback widget tree).

---

## 1. Literal Resolution (Implemented)

Mode entity carries `render_spec_id` as a data field:

```yaml
mode/oikos-nav:
  render_spec_id: render-spec/oikos-list
  spatial: { position: left, height: fill }
```

The layout engine reads `mode.data.render_spec_id` and fetches the render-spec entity by ID.

**When to use:** Modes that always render the same view regardless of entity type. This is an explicit override — graph discovery is skipped entirely.

---

## 2. Graph Discovery (Target)

When a mode omits `render_spec_id`, the layout engine discovers the render-spec by traversing the bond graph from the entity's eidos.

### Bond Path

```
entity (eidos: phasis)
    ↓ read eidos
eidos/phasis
    ↓ traverse applies-to-eidos (inward, from: render-type)
render-type/phasis-thread
    ↓ read render_spec_id from render-type data
render-spec/phasis-thread
```

### Traversal Steps

1. Read the entity's `eidos` field
2. Query bonds: `trace(to: eidos/{eidos}, desmos: applies-to-eidos)` — finds render-types bonded to this eidos
3. If mode declares `variant`, filter render-types by matching variant field
4. If multiple render-types match, select by specificity (exact variant match > unqualified)
5. Read `render_spec_id` from the selected render-type's data
6. Fetch the render-spec entity by that ID

### Required Entities in Genesis

For graph discovery to work, these must exist:

```yaml
# 1. Render-type entity (what semantic view exists)
- eidos: render-type
  id: render-type/phasis-thread
  data:
    name: Phasis Thread
    variant: thread
    render_spec_id: render-spec/phasis-thread

# 2. Bond: render-type applies to eidos
- eidos: desmos-instance
  data:
    desmos: applies-to-eidos
    from: render-type/phasis-thread
    to: eidos/phasis
```

The desmos type `applies-to-eidos` already exists at `genesis/thyra/desmoi/thyra.yaml:191-200`.

### Mode Without render_spec_id

```yaml
# Mode that relies on graph discovery
mode/entity-detail:
  spatial: { position: center, height: fill }
  source_entity_id: "{focused_entity_id}"
  # No render_spec_id — discovered from entity's eidos
```

### Collection Modes

For collection modes (`source_query`), graph discovery uses the eidos from the query:

```yaml
mode/feed:
  spatial: { position: center, height: fill }
  source_query: "gather(eidos: phasis)"
  # Discovers render-spec from eidos/phasis
```

---

## Anti-Patterns

### Wrong: Eidos checks in the interpreter

```typescript
// WRONG — interpreter must be domain-agnostic
if (entity.eidos === "phasis") {
  renderSpecId = "render-spec/phasis-thread";
}
```

The interpreter never names domain eide. All mapping lives in the bond graph.

### Wrong: Duplicating render-spec IDs across modes

```yaml
# WRONG — three modes all hardcoding the same render-spec
mode/a:
  render_spec_id: render-spec/phasis-thread
mode/b:
  render_spec_id: render-spec/phasis-thread
mode/c:
  render_spec_id: render-spec/phasis-thread
```

When multiple modes render the same eidos, the render-spec should be discovered via `applies-to-eidos`, not repeated as literals.

---

## Implementation Location

| File | Change |
|------|--------|
| `app/src/lib/layout-engine.tsx` | Add graph discovery fallback when `render_spec_id` is absent |
| `genesis/thyra/entities/` | Create render-type entities with `applies-to-eidos` bonds |
| `genesis/thyra/desmoi/thyra.yaml` | Desmos already exists (lines 191-200) |

---

## Test Assertions

1. **Graph discovery resolves**: Given a mode WITHOUT `render_spec_id`, an entity with eidos X, a render-type bonded to eidos X via `applies-to-eidos`, and the render-type carrying `render_spec_id: render-spec/Y` — the layout engine renders using `render-spec/Y`.

2. **Literal takes precedence**: Given a mode WITH explicit `render_spec_id` and a conflicting `applies-to-eidos` bond — the literal ID is used.

3. **Variant selection**: Given multiple render-types bonded to the same eidos with different `variant` values, and a mode declaring `variant: thread` — the render-type with `variant: thread` is selected.

4. **Graceful absence**: Given a mode WITHOUT `render_spec_id` and no applicable `applies-to-eidos` bonds — the mode renders nothing, no error thrown.

5. **Collection mode discovery**: Given a collection mode with `source_query: "gather(eidos: X)"` and no `render_spec_id` — discovery uses eidos X from the query to find the render-spec.

---

*See [THYRA-RENDERING.md](../../architecture/THYRA-RENDERING.md) for the full rendering architecture.*
*See [RENDERING-GAPS.md](../../architecture/RENDERING-GAPS.md) for current divergences.*
