# Chora Handoff: Reflex System — Autonomic Response

*Document for chora implementation team. Describes the reflex infrastructure for autonomic graph responses.*

> **Architecture context:** Reflexes are Layer 1 (Event Detection) of the complete reactive system. See [genesis/REACTIVE-SYSTEM.md](genesis/REACTIVE-SYSTEM.md) for the unified architecture covering reflexes, reconcilers, and actuality modes.

---

## Why Reflexes Are Needed

**The Problem:** Without reflexes, every graph mutation requires explicit polling to detect and manual invocation to respond. Claude must ask "what changed?" and then decide "what to do about it." This creates friction and token waste.

**The Solution:** Reflexes close the loop automatically:

```
Graph mutation occurs
    ↓
Post-commit hook fires
    ↓
Reflex registry checks for matching triggers
    ↓
Matching reflex invokes response praxis
    ↓
Body-schema reflects outcome
```

**The Value:**
1. **Zero-latency response** — Actions fire immediately on mutation
2. **Reduced cognitive load** — Claude doesn't need to remember to check
3. **Consistency** — Same mutation always produces same response
4. **Auditability** — Reflex invocations are logged

**Real Example:**
When developing an oikos, adding a praxis should automatically register it as an MCP tool. Without reflexes, this requires explicit `project-oikos` invocation. With reflexes, the tool appears automatically.

---

## Ontological Context

Reflexes implement the somatic architecture concept of "reflex arcs":

```
Void detected → Signal emitted → Focus triggered → Agent attends
```

Translated to kosmos terms:

```
Graph mutated → Trigger matched → Response praxis → State updated
```

This is the system's "autonomic nervous system" — responses that happen without conscious invocation.

---

## Architecture

### Reflex Entity Structure

```yaml
- eidos: reflex
  id: reflex/oikos-artifact-added
  data:
    name: oikos-artifact-added
    description: "Update manifest when artifact added to developing oikos"

    trigger:
      event: bond_created
      desmos: contains
      from_eidos: oikos
      to_eidos: [eidos, praxis, desmos]
      condition: '$from.data.status == "composing"'

    response:
      praxis: demiurge/update-manifest
      params:
        oikos_id: "$from.id"
        artifact_id: "$to.id"

    enabled: true
    scope: global
```

### Trigger Events

| Event | Fires When | Context Variables |
|-------|------------|-------------------|
| `entity_created` | New entity arises | `$entity` |
| `entity_updated` | Entity data changes | `$entity`, `$previous` |
| `entity_deleted` | Entity removed | `$entity` |
| `bond_created` | New bond established | `$bond`, `$from`, `$to` |
| `bond_updated` | Bond data changes | `$bond`, `$from`, `$to`, `$previous` |
| `bond_deleted` | Bond dissolved | `$bond`, `$from`, `$to` |

### Trigger Filters

| Filter | Applies To | Description |
|--------|------------|-------------|
| `eidos` | Entity events | Entity type must match |
| `desmos` | Bond events | Bond type must match |
| `from_eidos` | Bond events | Source entity type must match |
| `to_eidos` | Bond events | Target entity type must match (can be array) |
| `condition` | All events | Expression must evaluate to true |

### Response Structure

```yaml
response:
  praxis: praxis-id          # Required: praxis to invoke
  params:                    # Optional: parameters
    key: "$context.variable" # Can reference trigger context
```

### Scope

| Scope | Description | Use Case |
|-------|-------------|----------|
| `global` | All matching mutations | System-wide housekeeping |
| `circle` | Only within specified circle | Circle-specific behavior |
| `oikos` | Only for specified oikos entities | Development workflows |

---

## Implementation Requirements

### 1. Reflex Registry

**At bootstrap:**
```rust
// Pseudo-code
let reflexes = gather_entities_by_eidos("reflex")
    .filter(|r| r.data.enabled != false);

let registry = ReflexRegistry::new();
for reflex in reflexes {
    registry.index_by_event(reflex.data.trigger.event, reflex);
}
```

**Index structure:**
```rust
struct ReflexRegistry {
    // Fast lookup by event type
    by_event: HashMap<EventType, Vec<Reflex>>,
    // Secondary index by desmos (for bond events)
    by_desmos: HashMap<String, Vec<Reflex>>,
    // Secondary index by eidos (for entity events)
    by_eidos: HashMap<String, Vec<Reflex>>,
}
```

### 2. Post-Commit Hook

After every graph mutation, check for matching reflexes:

```rust
// Pseudo-code
fn post_commit_hook(mutation: Mutation) {
    let event_type = mutation.event_type();
    let candidates = registry.get_by_event(event_type);

    for reflex in candidates {
        if matches_trigger(&reflex.trigger, &mutation) {
            invoke_response(&reflex.response, &mutation);
        }
    }
}

fn matches_trigger(trigger: &Trigger, mutation: &Mutation) -> bool {
    // Check eidos/desmos filters
    if let Some(ref desmos) = trigger.desmos {
        if mutation.desmos() != Some(desmos) {
            return false;
        }
    }

    // Check from_eidos/to_eidos for bonds
    if let Some(ref from_eidos) = trigger.from_eidos {
        if mutation.from_entity().map(|e| &e.eidos) != Some(from_eidos) {
            return false;
        }
    }

    // Evaluate condition expression
    if let Some(ref condition) = trigger.condition {
        let context = build_context(&mutation);
        if !evaluate_expression(condition, &context) {
            return false;
        }
    }

    true
}
```

### 3. Response Invocation

```rust
fn invoke_response(response: &Response, mutation: &Mutation) {
    let context = build_context(mutation);
    let params = interpolate_params(&response.params, &context);

    // Log the invocation
    log::info!("Reflex firing: {} -> {}", reflex.id, response.praxis);

    // Invoke the praxis
    praxis_engine.invoke(&response.praxis, params)?;
}

fn build_context(mutation: &Mutation) -> Context {
    match mutation {
        Mutation::EntityCreated(entity) => {
            Context::new().with("entity", entity)
        }
        Mutation::BondCreated(bond) => {
            let from = find_entity(&bond.from_id);
            let to = find_entity(&bond.to_id);
            Context::new()
                .with("bond", bond)
                .with("from", from)
                .with("to", to)
        }
        // ... other mutation types
    }
}
```

### 4. Condition Expression Evaluation

The `condition` field uses the same expression language as praxis steps:

```yaml
condition: '$from.data.status == "composing"'
condition: '$entity.eidos == "praxis" && $entity.data.visible == true'
condition: '$to.eidos in ["eidos", "praxis", "desmos"]'
```

This requires evaluating expressions against the mutation context. The expression evaluator should already exist for praxis step conditions.

---

## Relationship to Existing Infrastructure

### Cursor Model (Complements)

| Cursor | Reflex |
|--------|--------|
| Tracks what Claude has *observed* | Defines what the *system* should *do* |
| Polling-based (query notifications) | Event-based (fires on mutation) |
| For awareness | For action |

### Reconcilers (Different Purpose)

| Reconciler | Reflex |
|------------|--------|
| Intent vs actuality convergence | Immediate mutation response |
| For external resources (deploy, DNS) | For internal graph housekeeping |
| State-driven | Event-driven |

### Actuality Modes (Orthogonal)

Actuality modes define *how* to manifest/sense external resources.
Reflexes define *when* to invoke praxeis in response to mutations.

A reflex *could* invoke a praxis that uses an actuality mode.

---

## Example Reflexes

### 1. Oikos Development — Auto-register Praxis as MCP Tool

```yaml
- eidos: reflex
  id: reflex/auto-register-praxis
  data:
    name: auto-register-praxis
    description: |
      When a praxis is added to a developing oikos, automatically
      register it as an MCP tool. This obsoletes project-oikos.
    trigger:
      event: bond_created
      desmos: contains
      from_eidos: oikos
      to_eidos: praxis
      condition: '$from.data.status == "composing"'
    response:
      praxis: demiurge/register-praxis-tool
      params:
        oikos_id: "$from.id"
        praxis_id: "$to.id"
    enabled: true
    scope: global
```

### 2. Pragma — Notify on Arrival

```yaml
- eidos: reflex
  id: reflex/pragma-notify
  data:
    name: pragma-notify
    description: Add notification when pragma signals to circle
    trigger:
      event: bond_created
      desmos: signals-to
      from_eidos: pragma
      to_eidos: circle
    response:
      praxis: soma/add-notification
      params:
        type: pragma_received
        circle_id: "$to.id"
        pragma_id: "$from.id"
        title: "$from.data.title"
    enabled: true
    scope: global
```

### 3. Theoria — Index on Creation

```yaml
- eidos: reflex
  id: reflex/index-theoria
  data:
    name: index-theoria
    description: Automatically index theoria for semantic search
    trigger:
      event: entity_created
      eidos: theoria
    response:
      praxis: nous/index-entity
      params:
        entity_id: "$entity.id"
    enabled: true
    scope: global
```

### 4. Validation — Re-validate on Change

```yaml
- eidos: reflex
  id: reflex/revalidate-praxis
  data:
    name: revalidate-praxis
    description: Re-validate praxis when its steps change
    trigger:
      event: entity_updated
      eidos: praxis
      condition: '$entity.data.steps != $previous.data.steps'
    response:
      praxis: demiurge/validate-praxis
      params:
        praxis_id: "$entity.id"
    enabled: true
    scope: global
```

---

## Testing Strategy

### Unit Tests

1. **Trigger matching:**
   - Bond event matches desmos filter
   - Entity event matches eidos filter
   - Condition expression evaluates correctly
   - Scope filtering works (circle, oikos, global)

2. **Response invocation:**
   - Praxis invoked with correct params
   - Context variables interpolated correctly
   - Invocation logged

3. **Registry:**
   - Reflexes indexed by event type
   - Disabled reflexes not in registry
   - Registry updates when reflex entity changes

### Integration Tests

1. **End-to-end flow:**
   - Create bond → reflex fires → praxis invokes → state changes
   - Verify the full pipeline

2. **Reflex on reflex:**
   - Reflex creates entity → another reflex fires on that creation
   - Verify no infinite loops (may need circuit breaker)

3. **Performance:**
   - Many reflexes registered
   - Mutation doesn't cause excessive overhead

---

## Safety Considerations

### 1. Infinite Loop Prevention

Reflexes can trigger other reflexes. Prevent infinite loops:

```rust
const MAX_REFLEX_DEPTH: u32 = 10;

fn invoke_response_with_depth(response: &Response, mutation: &Mutation, depth: u32) {
    if depth > MAX_REFLEX_DEPTH {
        log::warn!("Reflex depth exceeded, stopping");
        return;
    }
    // ... invoke with depth + 1 for any triggered reflexes
}
```

### 2. Audit Trail

Log all reflex invocations:

```rust
log::info!(
    "Reflex {} fired: mutation={:?}, praxis={}, params={:?}",
    reflex.id,
    mutation.id(),
    response.praxis,
    params
);
```

### 3. Error Handling

Reflex failures should not block the original mutation:

```rust
fn post_commit_hook(mutation: Mutation) {
    for reflex in matching_reflexes(&mutation) {
        if let Err(e) = invoke_response(&reflex.response, &mutation) {
            log::error!("Reflex {} failed: {}", reflex.id, e);
            // Optionally create a pragma for the failure
        }
    }
}
```

### 4. Attainment Gating

Creating reflexes is a privileged operation:

```yaml
- eidos: attainment
  id: attainment/configure-reflex
  data:
    grants:
      - praxis/ergon/create-reflex
      - praxis/ergon/disable-reflex
```

---

## Dependencies

| Component | Location | Status |
|-----------|----------|--------|
| Reflex eidos | genesis/ergon/eide/ergon.yaml | ✅ Defined |
| Reflex registry | chora/src/reflex/ | ⏳ Needs implementation |
| Post-commit hook | chora/src/store/ | ⏳ Needs implementation |
| Expression evaluator | chora/src/praxis/ | ✅ Exists (for praxis conditions) |
| Praxis invocation | chora/src/praxis/ | ✅ Exists |

---

## Implementation Order

### Phase 1: Core Infrastructure

1. Add `ReflexRegistry` struct
2. Populate registry at bootstrap from reflex entities
3. Add post-commit hook to mutation path
4. Implement trigger matching logic

### Phase 2: Response Invocation

1. Build mutation context with $entity, $bond, $from, $to
2. Interpolate params from context
3. Invoke response praxis
4. Add logging/audit

### Phase 3: Safety & Polish

1. Add depth tracking for infinite loop prevention
2. Add error handling (don't block original mutation)
3. Add metrics (reflex count, invocation time)
4. Update registry when reflex entities change

### Phase 4: Seed Reflexes

1. Create oikos development reflexes in kosmos
2. Test with actual development workflow
3. Iterate on trigger patterns

---

## Questions for Chora Team

1. **Post-commit hook location:** Where should the reflex check happen? After SQLite commit? In the store abstraction?

2. **Async vs sync:** Should reflexes fire synchronously (blocking) or asynchronously (background task)?

3. **Transaction scope:** Should reflex responses be in the same transaction as the triggering mutation? Separate transaction?

4. **Registry refresh:** When a reflex entity is created/updated/deleted, how does the registry refresh? Watch for changes? Reload on demand?

---

## Future Extensions

### Auto-create Pragma on Failure

When a praxis fails, automatically create a pragma:

```yaml
- eidos: reflex
  id: reflex/praxis-failure-pragma
  data:
    trigger:
      event: praxis_failed  # Future event type
    response:
      praxis: ergon/create-pragma
      params:
        title: "Praxis failed: $praxis.name"
        description: "$error.message"
```

### Scheduled Reflexes

Reflexes that fire on time intervals, not just mutations:

```yaml
trigger:
  schedule: "0 * * * *"  # Every hour
```

### Conditional Response Chains

Multiple responses based on conditions:

```yaml
response:
  - when: '$entity.data.priority == "critical"'
    praxis: soma/urgent-notification
  - else:
    praxis: soma/add-notification
```

---

*This document prepared from kosmos session 2026-01-30.*
*Implementing team: chora/ergon*
