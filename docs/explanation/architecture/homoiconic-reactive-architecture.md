# Explanation: Homoiconic Reactive Architecture

Why kosmos represents reactive behavior as graph entities rather than embedded configuration.

---

## The Problem

Consider a reflex that notifies when a pragma arrives:

**Embedded approach:**
```yaml
- eidos: reflex
  id: reflex/pragma-signaled
  data:
    trigger:
      event: bond_created
      desmos: signals-to
    response:
      praxis: soma/add-notification
      params: { ... }
```

Problems:
- Trigger patterns are opaque objects, not queryable entities
- Cannot traverse from event type to reflexes that match it
- Cannot share trigger patterns across reflexes
- Reactive configuration is invisible to the graph

**Homoiconic approach:**
```yaml
# Trigger is a first-class entity
- eidos: trigger
  id: trigger/pragma-signaled

# Connected via bonds
- bond:
    from: trigger/pragma-signaled
    desmos: matches-event
    to: bond-mutation/created

- bond:
    from: reflex/pragma-signaled
    desmos: triggered-by
    to: trigger/pragma-signaled
```

Benefits:
- Triggers are entities you can query, traverse, and modify
- Event types are entities triggers bond to
- Graph traversal finds matching reflexes
- Self-describing reactive configuration

---

## The Pattern

```
┌─────────────────────────────────────────────────────────────┐
│                      MUTATION                                │
│  bond created: pragma --[signals-to]--> oikos              │
└─────────────────────────────────────────────────────────────┘
                          │
                          ▼
┌─────────────────────────────────────────────────────────────┐
│                    FIND TRIGGERS                             │
│  Traverse: bond-mutation/created <--[matches-event]-- ?     │
│  Filter by: filters-desmos --> desmos/signals-to            │
│  Returns: [trigger/pragma-signaled]                          │
└─────────────────────────────────────────────────────────────┘
                          │
                          ▼
┌─────────────────────────────────────────────────────────────┐
│                   EVALUATE CONDITION                         │
│  trigger.condition evaluated against mutation context        │
│  Context: { $bond, $from, $to, $entity, $previous }         │
└─────────────────────────────────────────────────────────────┘
                          │
                          ▼
┌─────────────────────────────────────────────────────────────┐
│                    FIND REFLEXES                             │
│  Traverse: trigger/pragma-signaled <--[triggered-by]-- ?    │
│  Returns: [reflex/ergon/pragma-signaled]                     │
└─────────────────────────────────────────────────────────────┘
                          │
                          ▼
┌─────────────────────────────────────────────────────────────┐
│                     INVOKE RESPONSE                          │
│  Traverse: reflex --[responds-with]--> praxis               │
│  Get params from bond data                                   │
│  Call praxis with substituted params                         │
└─────────────────────────────────────────────────────────────┘
```

---

## Why Homoiconic?

### The graph IS the configuration

In a homoiconic system, the representation and the meaning are the same. The reactive configuration isn't stored in opaque objects — it IS the graph.

To find all reflexes that fire on entity creation:
```
traverse(
  from: entity-mutation/created,
  reverse: matches-event,
  then: reverse triggered-by
)
```

This query works because triggers and reflexes are entities with bonds, not hidden configuration.

### Triggers can be shared

Multiple reflexes can share a trigger pattern:

```
trigger/any-entity-created
    ↑ [triggered-by]
    ├── reflex/audit-log-creation
    ├── reflex/update-search-index
    └── reflex/notify-watchers
```

With embedded triggers, each reflex would duplicate the same pattern.

### Runtime modification

Because triggers are entities, you can:
- Disable a trigger (affects all connected reflexes)
- Add filter bonds without modifying the trigger entity
- Query which reflexes share a trigger

```yaml
# Disable by updating entity
- step: update
  entity_id: trigger/pragma-signaled
  data:
    enabled: false
```

### Queryable reactive topology

Questions you can answer by traversing the graph:
- "What fires when a deployment is created?" — traverse from eidos/deployment
- "What does reflex X respond to?" — traverse triggered-by → matches-event
- "Which reflexes share triggers?" — group by triggered-by target

---

## The Entity Hierarchy

### Mutation Events

Abstract base with concrete subtypes:

```
eidos/mutation-event (abstract)
├── eidos/entity-mutation
│   ├── entity-mutation/created
│   ├── entity-mutation/updated
│   └── entity-mutation/deleted
└── eidos/bond-mutation
    ├── bond-mutation/created
    ├── bond-mutation/updated
    └── bond-mutation/deleted
```

These six instances represent all possible graph mutations. Triggers bond to them.

### Triggers

Pattern matchers that bond to:
- **matches-event** → exactly one mutation event type (required)
- **filters-eidos** → specific entity type (optional)
- **filters-desmos** → specific bond type (optional)

Plus an optional `condition` expression for fine-grained filtering.

### Reflexes

Autonomic responses that bond to:
- **triggered-by** → exactly one trigger
- **responds-with** → exactly one praxis (bond data carries params)

---

## Context Variables

When a mutation occurs, context is available for conditions and response params:

| Variable | Available When | Contains |
|----------|----------------|----------|
| `$entity` | entity events | The mutated entity |
| `$previous` | entity_updated | Entity state before mutation |
| `$bond` | bond events | The bond |
| `$from` | bond events | Source entity |
| `$to` | bond events | Target entity |

Conditions use these for fine-grained matching:
```yaml
condition: '$entity.data.status == "resolved" && $previous.data.status != "resolved"'
```

Response params use them for dynamic invocation:
```yaml
data:
  params:
    pragma_id: "$entity.id"
    title: "$entity.data.title"
```

---

## Comparison with Embedded Form

| Aspect | Embedded | Homoiconic |
|--------|----------|------------|
| Trigger storage | Object in reflex.data | Separate entity |
| Pattern sharing | Copy-paste | Bond to same trigger |
| Querying | Scan all reflexes | Graph traversal |
| Runtime changes | Update nested object | Update entity or bonds |
| Visibility | Hidden in data | First-class in graph |
| Response params | Object in reflex.data | Bond data on responds-with |

---

## Migration Strategy

The system supports both forms during transition:

1. **Check for bonded form** — look for `triggered-by` bond
2. **Fall back to embedded** — read `trigger` and `response` fields
3. **Deprecation period** — both work, embedded shows warnings
4. **Removal** — embedded fields removed, only bonded form works

---

## Theoria

### T61: Reactive configuration is graph configuration

Triggers, reflexes, and their relationships are entities and bonds. The reactive topology is queryable, traversable, and modifiable through the same operations as any other graph structure.

### T62: Separation enables composition

By separating triggers from reflexes, patterns can be shared and composed. A trigger is a reusable pattern; a reflex is a specific response.

### T63: Mutation events are first-class

The six mutation types (entity created/updated/deleted, bond created/updated/deleted) are entities, not strings. Triggers bond to them, making the relationship explicit and traversable.

---

## Related Concepts

- **[Reconciler Pattern](./reconciler-pattern.md)** — Continuous alignment of intent and actuality
- **[Entity-as-Source-of-Truth](./entity-as-source-of-truth.md)** — Why entities hold state
- **Reflexes** — Autonomic responses (ergon topos)
- **Dynamis** — Substrate capabilities reflexes may invoke

---

## References

- [genesis/ergon/DESIGN.md](../../genesis/ergon/DESIGN.md) — Ergon topos design
- [genesis/ergon/eide/trigger.yaml](../../genesis/ergon/eide/trigger.yaml) — Trigger eidos
- [genesis/ergon/desmoi/reflex.yaml](../../genesis/ergon/desmoi/reflex.yaml) — Reflex bonds
- [CHORA-HANDOFF-HOMOICONIC-REACTIVE-ONTOLOGY.md](https://github.com/liminalcommons/chora) — Implementation handoff

---

*The homoiconic reactive system makes reactive behavior visible. Configuration is graph. Traversal is query. Modification is entity operation.*
