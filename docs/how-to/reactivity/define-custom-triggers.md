# How-To: Define Custom Triggers

Task-oriented guide for creating trigger patterns in the reactive system.

---

## Match Entity Creation

**Goal:** Trigger when any entity of a specific type is created.

```yaml
- eidos: trigger
  id: trigger/deployment-created
  data:
    name: deployment-created
    enabled: true

- bond:
    from: trigger/deployment-created
    desmos: matches-event
    to: entity-mutation/created

- bond:
    from: trigger/deployment-created
    desmos: filters-eidos
    to: eidos/deployment
```

---

## Match Entity Updates with Condition

**Goal:** Trigger when a specific field changes to a specific value.

```yaml
- eidos: trigger
  id: trigger/pragma-resolved
  data:
    name: pragma-resolved
    condition: '$entity.data.status == "resolved" && $previous.data.status != "resolved"'
    enabled: true

- bond:
    from: trigger/pragma-resolved
    desmos: matches-event
    to: entity-mutation/updated

- bond:
    from: trigger/pragma-resolved
    desmos: filters-eidos
    to: eidos/pragma
```

**Key:** Use `$previous` to check the state before the update.

---

## Match Bond Creation

**Goal:** Trigger when a specific type of bond is created.

```yaml
- eidos: trigger
  id: trigger/pragma-signaled
  data:
    name: pragma-signaled
    enabled: true

- bond:
    from: trigger/pragma-signaled
    desmos: matches-event
    to: bond-mutation/created

- bond:
    from: trigger/pragma-signaled
    desmos: filters-desmos
    to: desmos/signals-to
```

**Note:** Use `filters-desmos` for bond events, `filters-eidos` for entity events.

---

## Match Bond with Source/Target Conditions

**Goal:** Trigger when a bond is created between specific entity types.

```yaml
- eidos: trigger
  id: trigger/pragma-to-oikos
  data:
    name: pragma-to-oikos
    condition: '$from.eidos == "pragma" && $to.eidos == "oikos"'
    enabled: true

- bond:
    from: trigger/pragma-to-oikos
    desmos: matches-event
    to: bond-mutation/created

- bond:
    from: trigger/pragma-to-oikos
    desmos: filters-desmos
    to: desmos/signals-to
```

**Available variables for bond events:** `$bond`, `$from`, `$to`

---

## Match Any Entity of Multiple Types

**Goal:** Trigger when any of several entity types is created.

Use conditions instead of filters-eidos:

```yaml
- eidos: trigger
  id: trigger/content-created
  data:
    name: content-created
    condition: '$entity.eidos in ["theoria", "inquiry", "journey"]'
    enabled: true

- bond:
    from: trigger/content-created
    desmos: matches-event
    to: entity-mutation/created
```

**Note:** Omit `filters-eidos` and use condition for OR logic.

---

## Match Entity Deletion

**Goal:** Trigger cleanup when an entity is deleted.

```yaml
- eidos: trigger
  id: trigger/oikos-deleted
  data:
    name: oikos-deleted
    enabled: true

- bond:
    from: trigger/oikos-deleted
    desmos: matches-event
    to: entity-mutation/deleted

- bond:
    from: trigger/oikos-deleted
    desmos: filters-eidos
    to: eidos/oikos
```

---

## Share a Trigger Across Multiple Reflexes

**Goal:** Reuse the same trigger pattern for different responses.

```yaml
# One trigger
- eidos: trigger
  id: trigger/any-entity-created
  data:
    name: any-entity-created
    enabled: true

- bond:
    from: trigger/any-entity-created
    desmos: matches-event
    to: entity-mutation/created

# Multiple reflexes using the same trigger
- eidos: reflex
  id: reflex/audit/log-creation
  data:
    name: log-creation
    description: Log all entity creations for audit
    enabled: true
    scope: global

- eidos: reflex
  id: reflex/search/index-creation
  data:
    name: index-creation
    description: Index new entities for search
    enabled: true
    scope: global

# Both bond to the same trigger
- bond:
    from: reflex/audit/log-creation
    desmos: triggered-by
    to: trigger/any-entity-created

- bond:
    from: reflex/search/index-creation
    desmos: triggered-by
    to: trigger/any-entity-created
```

---

## Temporarily Disable a Trigger

**Goal:** Turn off a trigger without deleting it.

**Option 1:** Update the trigger entity:

```yaml
- step: update
  entity_id: trigger/pragma-signaled
  data:
    enabled: false
```

**Option 2:** Disable the reflex instead:

```yaml
- step: update
  entity_id: reflex/ergon/pragma-signaled
  data:
    enabled: false
```

---

## Use Complex Conditions

**Goal:** Fine-grained matching with multiple criteria.

```yaml
- eidos: trigger
  id: trigger/high-priority-pragma-created
  data:
    name: high-priority-pragma-created
    condition: |
      $entity.data.priority == "critical" &&
      $entity.data.status == "open" &&
      $entity.data.title != ""
    enabled: true

- bond:
    from: trigger/high-priority-pragma-created
    desmos: matches-event
    to: entity-mutation/created

- bond:
    from: trigger/high-priority-pragma-created
    desmos: filters-eidos
    to: eidos/pragma
```

**Tip:** Multi-line conditions are supported with YAML `|` syntax.

---

## Respond with Dynamic Parameters

**Goal:** Pass mutation context to the response praxis.

```yaml
- eidos: reflex
  id: reflex/ergon/pragma-signaled
  data:
    name: pragma-signaled
    description: Notify when pragma is signaled
    enabled: true
    response_params:
      # Static values
      type: pragma_received
      # Entity fields (resolved at trigger time)
      pragma_id: "$entity.id"
      title: "$entity.data.title"
      priority: "$entity.data.priority"
  bonds:
    - desmos: triggered-by
      to: trigger/pragma-signaled
    - desmos: responds-with
      to: praxis/soma/add-notification
```

**Available substitutions in `response_params`:**
- `$entity` — the mutated entity (entity events)
- `$previous` — state before mutation (entity_updated only)
- `$bond` — the bond (bond events)
- `$from` — source entity (bond events)
- `$to` — target entity (bond events)

Note: `response_params` lives on the **reflex entity's data**, not on the bond. The reflex carries inline bonds (`triggered-by`, `responds-with`) to declare its wiring.

---

## Scope Reflexes to Oikos or Topos

**Goal:** Limit where a reflex fires.

```yaml
- eidos: reflex
  id: reflex/project/task-created
  data:
    name: task-created
    description: Notify within project oikos only
    enabled: true
    scope: oikos
    oikos_id: "oikos/project-alpha"
```

**Scopes:**
- `global` — fires for all matching mutations (default)
- `oikos` — fires only within specified oikos
- `topos` — fires only for entities of specified topos

---

## Common Patterns

| Pattern | Event | Filter | Condition Example |
|---------|-------|--------|-------------------|
| Entity created | `entity-mutation/created` | `filters-eidos` | — |
| Field changed | `entity-mutation/updated` | `filters-eidos` | `$entity.data.x != $previous.data.x` |
| Status transition | `entity-mutation/updated` | `filters-eidos` | `$entity.data.status == "done" && $previous.data.status != "done"` |
| Bond created | `bond-mutation/created` | `filters-desmos` | — |
| Bond between types | `bond-mutation/created` | `filters-desmos` | `$from.eidos == "X" && $to.eidos == "Y"` |
| Any deletion | `entity-mutation/deleted` | — | — |

---

## See Also

- [Reactive System Reference](../../reference/reactivity/reactive-system-reference.md) — Full specification
- [Create Your First Reflex](../../tutorial/reactivity/create-your-first-reflex.md) — Step-by-step tutorial
- [Homoiconic Reactive Architecture](../../explanation/architecture/homoiconic-reactive-architecture.md) — Conceptual overview
