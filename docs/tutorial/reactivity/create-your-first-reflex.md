# Tutorial: Create Your First Reflex

Learn to create a reflex by building an automatic notification system.

**Time:** 20 minutes
**Prerequisites:** Understanding of kosmos entities and YAML

---

## What You'll Build

A reflex that sends a notification whenever a new theoria is created. This teaches:
- Creating trigger entities with inline bonds
- Connecting triggers to mutation events and eidos filters
- Creating reflex entities with response parameters
- Connecting reflexes to response praxeis

---

## Step 1: Understand the Goal

When someone creates a theoria, we want to:
1. **Detect** — notice the entity_created event
2. **Filter** — only theoria entities, not other types
3. **Respond** — call a notification praxis with context

The graph structure will be:

```
trigger/theoria-created
    │
    ├──[matches-event]──→ entity-mutation/created
    │
    └──[filters-eidos]──→ eidos/theoria

reflex/nous/theoria-created-notify
    │
    ├──[triggered-by]──→ trigger/theoria-created
    │
    └──[responds-with]──→ praxis/soma/add-notification
    (response_params in reflex.data)
```

---

## Step 2: Create the Trigger Entity

Create a file `genesis/nous/reflexes/reflexes.yaml` (or add to existing):

```yaml
# Nous Reflexes — Homoiconic Form
# Autonomic responses for knowledge crystallization
#
# Bonds are inline on their parent entities:
#   trigger.bonds: matches-event, filters-eidos/filters-desmos
#   reflex.bonds: triggered-by, responds-with
#   reflex.data.response_params: params for the responds-with praxis

entities:

  # =============================================================================
  # TRIGGERS
  # =============================================================================

  - eidos: trigger
    id: trigger/theoria-created
    data:
      name: theoria-created
      enabled: true
      # No condition — matches all theoria creations
    bonds:
      - desmos: matches-event
        to: entity-mutation/created
      - desmos: filters-eidos
        to: eidos/theoria
```

The trigger is a simple entity. It becomes a pattern matcher through its bonds:
- **matches-event** → `entity-mutation/created` declares what mutation type to respond to
- **filters-eidos** → `eidos/theoria` narrows to only theoria entities

The `entity-mutation/created` and `eidos/theoria` entities already exist — they're seed entities loaded at bootstrap.

---

## Step 3: Create the Reflex Entity

Add the reflex that will respond:

```yaml
  # =============================================================================
  # REFLEXES
  # =============================================================================

  - eidos: reflex
    id: reflex/nous/theoria-created-notify
    data:
      name: theoria-created-notify
      description: |
        Notify when a new theoria is crystallized.
        Helps dwellers stay aware of new insights.
      enabled: true
      scope: global
      response_params:
        type: theoria_created
        title: "New Theoria: $entity.data.title"
        body: "$entity.data.insight"
        entity_id: "$entity.id"
    bonds:
      - desmos: triggered-by
        to: trigger/theoria-created
      - desmos: responds-with
        to: praxis/soma/add-notification
```

Key points:
- **response_params** lives in `reflex.data`, not on the bond. These are the parameters passed to the response praxis.
- **triggered-by** connects this reflex to the trigger defined in Step 2.
- **responds-with** connects to the praxis that will be invoked.
- Context variables like `$entity` are substituted at runtime with the entity that triggered the reflex.

---

## Step 4: Understand the Complete File

Your complete `genesis/nous/reflexes/reflexes.yaml`:

```yaml
# Nous Reflexes — Homoiconic Form
# Autonomic responses for knowledge crystallization
#
# Bonds are inline on their parent entities:
#   trigger.bonds: matches-event, filters-eidos/filters-desmos
#   reflex.bonds: triggered-by, responds-with
#   reflex.data.response_params: params for the responds-with praxis

entities:

  # =============================================================================
  # TRIGGERS
  # =============================================================================

  - eidos: trigger
    id: trigger/theoria-created
    data:
      name: theoria-created
      enabled: true
    bonds:
      - desmos: matches-event
        to: entity-mutation/created
      - desmos: filters-eidos
        to: eidos/theoria

  # =============================================================================
  # REFLEXES
  # =============================================================================

  - eidos: reflex
    id: reflex/nous/theoria-created-notify
    data:
      name: theoria-created-notify
      description: |
        Notify when a new theoria is crystallized.
        Helps dwellers stay aware of new insights.
      enabled: true
      scope: global
      response_params:
        type: theoria_created
        title: "New Theoria: $entity.data.title"
        body: "$entity.data.insight"
        entity_id: "$entity.id"
    bonds:
      - desmos: triggered-by
        to: trigger/theoria-created
      - desmos: responds-with
        to: praxis/soma/add-notification
```

Notice the pattern: bonds are inline on their parent entities. This is the standard form used throughout genesis. Every reflex file follows this structure.

---

## Step 5: Update the Manifest

Add the reflexes content path to `genesis/nous/manifest.yaml`:

```yaml
content_paths:
  - path: reflexes/
    content_types: [reflex, trigger]
```

---

## Step 6: Test Your Reflex

After bootstrap loads your definitions:

1. Create a theoria:
   ```
   nous_crystallize-theoria(
     insight: "Reflexes are autonomic responses",
     domain: "kosmos"
   )
   ```

2. Check for notification:
   ```
   soma_list-notifications()
   ```

You should see a notification with title "New Theoria: ..." and your insight as the body.

---

## What You Learned

- **Triggers** are entities with bonds to event types and optional eidos/desmos filters
- **matches-event** declares what mutation type to respond to
- **filters-eidos** narrows to specific entity types
- **Reflexes** bond to triggers via **triggered-by** and to praxeis via **responds-with**
- **response_params** lives in reflex.data — these are the parameters passed to the response praxis
- Context variables (`$entity`, `$from`, `$to`) enable dynamic parameter substitution
- Bonds are inline on their parent entities — no separate bond entries needed

---

## Next Steps

- Add a condition to filter by domain: `condition: '$entity.data.domain == "kosmos"'`
- Create a trigger for theoria updates using `entity-mutation/updated`
- Share a trigger across multiple reflexes (just add another `triggered-by` bond)
- Explore existing reflexes in `genesis/ergon/reflexes/reflexes.yaml` for more patterns

---

## See Also

- [Reactive System Reference](../../reference/reactivity/reactive-system-reference.md) — Full specification
- [Define Custom Triggers](../../how-to/reactivity/define-custom-triggers.md) — Advanced trigger patterns
- [Homoiconic Reactive Architecture](../../explanation/architecture/homoiconic-reactive-architecture.md) — Why it works this way
