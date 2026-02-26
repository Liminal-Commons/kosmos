# Explanation: Entity as Source of Truth

Why UI state lives in entities, not components, and how this enables declarative rendering.

---

## The Problem

Consider a voice composer with a mode selector and content textarea.

**Component-owned state:**
```typescript
// State lives in component
const [mode, setMode] = useState("declaration");
const [content, setContent] = useState("");

// On submit, gather state and send
const handleSubmit = () => {
  createExpression({ mode, content });
};
```

Problems:
- State is invisible to the graph
- Can't query "what mode was selected?" from elsewhere
- State lost on component unmount
- Multiple components can't share state
- Testing requires rendering components

**Entity-owned state:**
```yaml
# State lives in entity
eidos: accumulation
data:
  mode: declaration
  content: "Hello world"
```

```typescript
// Component binds to entity
const entity = useEntitySubscription(accumulationId);
// UI reads from entity
<select value={entity.data.mode} />
// Changes update entity via praxis
onChange={() => callPraxis("thyra/update-accumulation-mode", { ... })}
```

---

## The Pattern

```
┌─────────────────────────────────────────────────────┐
│                    ENTITY                           │
│  id: accumulation/abc                               │
│  data:                                              │
│    mode: declaration     ← single source of truth  │
│    content: "Hello"      ← single source of truth  │
│    status: active                                   │
└─────────────────────────────────────────────────────┘
         │                           ▲
         │ read                      │ write
         ▼                           │
┌─────────────────────────────────────────────────────┐
│                      UI                             │
│  <select value="{mode}" />                          │
│  <textarea value="{content}" />                     │
│                                                     │
│  on_change → praxis → entity update → UI re-render │
└─────────────────────────────────────────────────────┘
```

The flow:
1. UI reads from entity (via subscription)
2. User interaction triggers praxis call
3. Praxis updates entity
4. Entity update flows to UI (via subscription)
5. UI re-renders with new state

---

## Implementation

### Entity holds all state

```yaml
# genesis/thyra/eide/thyra.yaml
- eidos: eidos
  id: eidos/accumulation
  data:
    name: accumulation
    fields:
      content:
        type: string
        description: "Clarified content, ready for commit"
      mode:
        type: enum
        values: [declaration, inquiry, suggestion, request, proposal]
        default: declaration
        description: "Phasis mode for commit"
      clarification_status:
        type: enum
        values: [pending, clarifying, clarified, manual, failed]
      capture_state:
        type: enum
        values: [inactive, listening, processing]
```

### Render-spec binds to entity

```yaml
# genesis/thyra/render-specs/accumulation-composer.yaml
- widget: select
  props:
    value: "{mode}"                    # Reads from entity
    on_change: thyra/update-accumulation-mode
    on_change_params:
      accumulation_id: "{id}"
      mode: $event.target.value        # Writes via praxis

- widget: textarea
  props:
    value: "{content}"                 # Reads from entity
    on_input: thyra/update-accumulation-content
    on_input_params:
      accumulation_id: "{id}"
      content: $event.target.value     # Writes via praxis
```

### Praxis updates entity

```yaml
# genesis/thyra/praxeis/thyra.yaml
- eidos: praxis
  id: praxis/thyra/update-accumulation-mode
  data:
    params:
      - name: accumulation_id
      - name: mode
    steps:
      - step: update
        id: "$accumulation_id"
        data:
          mode: "$mode"
```

### Component subscribes to entity

```typescript
// Chora implementation
function AccumulationComposer({ accumulationId }) {
  const entity = createEntitySubscription(accumulationId);

  return (
    <RenderSpecRenderer
      renderSpec="render-spec/accumulation-composer"
      context={{ data: entity.data, id: entity.id }}
    />
  );
}
```

---

## Why This Matters

### Queryable

Entity state is in the graph. Any praxis can query it:

```yaml
- step: find
  id: "$accumulation_id"
  bind_to: acc

- step: assert
  condition: '$acc.data.mode == "proposal"'
  message: "Only proposals can be escalated"
```

### Bondable

Entities can bond to other entities:

```yaml
- step: bind
  from_id: "$phasis_id"
  to_id: "$accumulation_id"
  desmos: "derives-from"
```

Now the phasis knows its origin. This enables provenance tracking.

### Shareable

Multiple components can subscribe to the same entity:

```typescript
// Voice composer panel
const entity = createEntitySubscription(accumulationId);

// Status indicator (elsewhere in UI)
const entity = createEntitySubscription(accumulationId);
// Both see the same state
```

### Persistent

Entity survives component unmount:

```
1. Open voice panel → accumulation created
2. Switch to different mode → accumulation persists
3. Return to voice panel → same accumulation, same content
```

### Testable

Test praxeis without rendering UI:

```yaml
# Test: mode update
given:
  accumulation: { id: "acc/1", data: { mode: "declaration" } }
when:
  call: thyra/update-accumulation-mode
  params: { accumulation_id: "acc/1", mode: "inquiry" }
then:
  accumulation.data.mode: "inquiry"
```

---

## The Binding Syntax

Render-specs use two binding forms:

| Syntax | Meaning | Example |
|--------|---------|---------|
| `{field}` | Read from entity | `value: "{content}"` |
| `$event.target.value` | Read from DOM event | `content: $event.target.value` |
| `$form.field` | Read from form state (legacy) | Deprecated |

**Entity bindings** (`{field}`) are reactive. When the entity updates, the widget re-renders.

**Event bindings** (`$event.*`) capture values at interaction time for praxis params.

---

## Anti-patterns

### Local state for shared data

```typescript
// Bad: state in component
const [mode, setMode] = useState("declaration");
```

Use entity field instead. If it needs to be shared or persisted, it belongs in an entity.

### Direct mutation

```typescript
// Bad: directly mutating
entity.data.mode = "inquiry";
```

Always go through praxis. This ensures:
- Validation runs
- Side effects execute
- Audit trail exists

### Form state for entity fields

```yaml
# Bad: form-based binding
props:
  field: mode      # Creates local form state
  on_submit: ...   # Collects at submit time
```

```yaml
# Good: entity binding
props:
  value: "{mode}"  # Reads from entity
  on_change: ...   # Updates entity immediately
```

---

## Related Concepts

- **[Commitment Boundary](./commitment-boundary.md)** — Where accumulation commits to phasis
- **[Reconciler Pattern](./reconciler-pattern.md)** — How intent and status align
- **Render-spec** — Declarative widget composition with entity binding
- **Subscription** — Reactive updates from entity changes

---

## References

- [genesis/thyra/render-specs/accumulation-composer.yaml](../../genesis/thyra/render-specs/accumulation-composer.yaml) — Entity-bound render-spec
- [genesis/thyra/eide/thyra.yaml](../../genesis/thyra/eide/thyra.yaml) — Accumulation eidos with state fields
- [VOICE-TOPOS-DESIGN.md](../../design/VOICE-TOPOS-DESIGN.md) — Voice implementation using pattern

---

*The entity is the source of truth. Components are projections of that truth.*
