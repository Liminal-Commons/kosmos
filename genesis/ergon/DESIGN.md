# Ergon Design

ἔργον (ergon) — work, deed, thing to be done

> **See also:** [REACTIVE-SYSTEM.md](../REACTIVE-SYSTEM.md) — Ergon's reflex system is Layer 1 of the complete reactive architecture.

## Ontological Purpose

Ergon addresses **the gap between discovery and capability** — the coordination of work across discipline boundaries where gaps are discovered in one context but must be resolved in another.

Without ergon:
- Gaps discovered during dwelling vanish into conversation
- Work items have no graph representation
- Cross-circle coordination requires external tools
- Resolution has no traceability to discovery

With ergon:
- **Pragma entities**: Gaps become first-class entities
- **Signals-to bonds**: Work flows to circles with capability
- **Evidence bonds**: Traceability from gap to what demonstrated it
- **Resolution bonds**: Traceability from gap to what fixed it

The central concept is the **pragma** (πρᾶγμα — a thing to be done). A pragma is created where a gap is discovered and signals to the circle with the capability to resolve it.

## Circle Context

### Self Circle

A solitary dweller uses ergon to:
- Track gaps discovered during exploration
- Create pragma for self-reminders
- Mark pragma resolved when addressed
- Maintain personal work queue

Self-circle pragma are notes about what needs doing.

### Peer Circle

Collaborators use ergon to:
- Signal gaps discovered in shared work
- Accept pragma to take ownership
- Track who is working on what
- Resolve pragma with shared visibility

Peer circle pragma enable coordination without external tools.

### Commons Circle

A commons uses ergon to:
- Receive pragma from member circles (kosmos → chora)
- Track gaps in shared infrastructure
- Coordinate resolution across contributors
- Maintain traceability from gap to fix

Commons pragma aggregate work across the ecosystem.

## Core Entities (Eide)

### pragma

A thing to be done — gap, issue, or work item.

**Fields:**
- `title` — short description of the gap
- `description` — full context (what failed, what was attempted)
- `context` — situation when gap was encountered
- `status` — open, accepted, in_progress, resolved, declined, blocked
- `priority` — critical, high, normal, low
- `resolution` — how it was resolved (filled on completion)
- `created_at`, `resolved_at` — timestamps

**Lifecycle:**
- Arise: create-pragma composes entity with status=open
- Change: accept-pragma → accepted, work → in_progress
- Resolve: resolve-pragma → resolved with resolution text
- Alternative: declined with reason, blocked awaiting dependency

## Bonds (Desmoi)

### signals-to

Pragma signals to a circle for attention.

- **From:** pragma
- **To:** circle
- **Cardinality:** many-to-one
- **Traversal:** Find pragma waiting for a circle's attention

### evidenced-by

Pragma is evidenced by an entity that demonstrates the gap.

- **From:** pragma
- **To:** any entity
- **Cardinality:** many-to-many
- **Traversal:** Trace what triggered the pragma

### blocks

Pragma blocks another pragma — dependency.

- **From:** pragma (blocker)
- **To:** pragma (blocked)
- **Cardinality:** many-to-many
- **Traversal:** Find what must be resolved first

### resolves

Entity resolves a pragma — traceability to the fix.

- **From:** any entity (commit, theoria, etc.)
- **To:** pragma
- **Cardinality:** many-to-one
- **Traversal:** Find what fixed a gap

## Operations (Praxeis)

### create-pragma

Create a pragma and signal it to a target circle.

- **When:** Gap discovered requiring work in another context
- **Requires:** signal attainment
- **Provides:** Pragma entity bonded to target circle

### list-pragma

List pragma signaled to a circle, optionally filtered by status.

- **When:** Checking work queue
- **Requires:** work attainment
- **Provides:** Pragma entities with status

### accept-pragma

Accept ownership of a pragma (status: open → accepted).

- **When:** Taking responsibility for resolution
- **Requires:** work attainment
- **Provides:** Updated pragma status

### resolve-pragma

Mark pragma resolved with resolution text.

- **When:** Gap has been addressed
- **Requires:** work attainment
- **Provides:** Resolved pragma with resolution, optional resolving entity bond

## Attainments

### attainment/signal

Signal capability — creating gaps for other circles' attention.

- **Grants:** create-pragma
- **Scope:** circle
- **Rationale:** Signaling requires membership in the discovering circle

### attainment/work

Work capability — managing pragma lifecycle.

- **Grants:** list-pragma, accept-pragma, resolve-pragma
- **Scope:** circle
- **Rationale:** Work operations require membership in the target circle

## Embodiment

### Completeness Status

| Level | Status |
|-------|--------|
| Defined | 1 eidos, 4 desmoi, 4 praxeis |
| Loaded | Bootstrap loads all definitions |
| Projected | All praxeis visible as MCP tools |
| Embodied | Partial — pragma count in body-schema |
| Surfaced | Pending — reconciler not implemented |
| Afforded | Pending — pragma list UI |

### Body-Schema Contribution

When sense-body gathers ergon state:

```yaml
work:
  open_pragma: 5          # Awaiting attention
  accepted_pragma: 2      # In progress
  blocked_pragma: 1       # Waiting on dependencies
  resolved_today: 3       # Recently completed
```

This reveals workload and progress.

### Reconciler

An ergon reconciler would surface:

- **New pragma** — "3 new gaps signaled since last session"
- **Stale accepted** — "Pragma accepted 5 days ago with no progress"
- **Blocked chains** — "Pragma X blocks 3 others"
- **High priority** — "2 critical pragma need attention"

## Compound Leverage

### amplifies politeia

Pragma signal to circles. Circle membership determines who can accept/resolve.

### amplifies nous

Pragma can be indexed, related to theoria. Resolution becomes searchable knowledge.

### amplifies thyra

Pragma could surface as expressions for discussion.

### amplifies dynamis

Pragma follow similar lifecycle to releases (open → in_progress → resolved).

## Theoria

### T55: Gaps discovered are gaps captured

When work is interrupted by a gap, capturing it as a pragma preserves the discovery. The alternative — making a mental note or mentioning in chat — loses the structured context.

### T56: Work flows to capability

Pragma signal to circles where capability exists. A gap in kosmos signals to chora because that's where the interpreter lives. The graph knows where work should flow.

### T57: Resolution completes the loop

Bonding the resolving entity to the pragma creates traceability. Future exploration can trace from gap discovery through to what fixed it. This is institutional memory in graph form.

## Reflex System — Autonomic Response

> **Full architecture:** See [REACTIVE-SYSTEM.md](../REACTIVE-SYSTEM.md) for how reflexes integrate with reconcilers and actuality modes.

### Concept

A **reflex** is an autonomic response to graph mutations. When the graph changes in a way that matches a reflex's trigger pattern, the reflex fires automatically without conscious invocation.

This implements the somatic architecture principle: the system *feels* its state and responds automatically, rather than requiring explicit polling or invocation.

### Why Reflexes?

**The Problem:** Without reflexes, Claude must explicitly check for changes and decide what to do. Every graph mutation requires polling to detect and manual invocation to respond.

**The Solution:** Reflexes close the loop between detection and response:

```
Graph mutation (entity/bond created, updated, deleted)
    ↓
Chora post-commit hook checks reflex registry
    ↓
Matching reflexes fire automatically
    ↓
Response praxis invoked with mutation context
```

### Example: Oikos Development

When an eidos is added to a developing oikos:

```yaml
- eidos: reflex
  id: reflex/oikos-artifact-added
  data:
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
```

This reflex:
1. Detects when a `contains` bond is created from an oikos to an artifact
2. Checks that the oikos is in "composing" status
3. Automatically invokes `demiurge/update-manifest` with the context

### Reflex vs Reconciler

| Aspect | Reconciler | Reflex |
|--------|------------|--------|
| **Trigger** | Poll-based (intent vs actuality) | Event-based (mutation occurred) |
| **Focus** | State convergence | Immediate response |
| **Use case** | External resources (deploy, DNS) | Internal graph housekeeping |
| **Latency** | Polling interval | Immediate (post-commit) |

Reconcilers answer: "Is intent aligned with actuality?"
Reflexes answer: "Something changed — what should happen?"

### Reflex Eidos

```yaml
- eidos: reflex
  fields:
    name: Short identifier
    description: What this reflex does
    trigger:
      event: entity_created | entity_updated | entity_deleted |
             bond_created | bond_updated | bond_deleted
      eidos: Entity type filter (for entity events)
      desmos: Bond type filter (for bond events)
      from_eidos: Source entity type (for bond events)
      to_eidos: Target entity type (for bond events)
      condition: Expression evaluated against mutation context
    response:
      praxis: Praxis to invoke
      params: Parameters (can reference $from, $to, $entity, $bond)
    enabled: Whether this reflex is active
    scope: circle | oikos | global
```

### Trigger Events

| Event | Context Variables | Use Case |
|-------|-------------------|----------|
| `entity_created` | `$entity` | New entity arrived |
| `entity_updated` | `$entity`, `$previous` | Entity data changed |
| `entity_deleted` | `$entity` | Entity removed |
| `bond_created` | `$bond`, `$from`, `$to` | Relationship established |
| `bond_updated` | `$bond`, `$from`, `$to`, `$previous` | Bond data changed |
| `bond_deleted` | `$bond`, `$from`, `$to` | Relationship dissolved |

### Scope

- **circle** — Reflex fires only for mutations within a specific circle
- **oikos** — Reflex fires for mutations involving entities of an oikos
- **global** — Reflex fires for all matching mutations

### Implementation Path

**In kosmos (schema-driven):**
1. Reflex eidos defines trigger/response structure
2. Reflex entities are loaded at bootstrap
3. Reflex registry indexed by event type for fast lookup

**In chora (event-driven):**
1. Entity/bond mutations fire post-commit hook
2. Hook checks reflex registry for matching triggers
3. Matching reflexes invoke response praxis with context
4. Reflex execution logged for auditability

### Relationship to Cursor Model

The cursor model (`last-saw` desmos) tracks what Claude has *observed*.
Reflexes track what the *system* should *do* in response to changes.

They complement each other:
- Cursor → "What's new for Claude to see?"
- Reflex → "What should happen automatically?"

### Example Reflexes

**1. Update manifest on artifact addition:**
```yaml
trigger:
  event: bond_created
  desmos: contains
  from_eidos: oikos
response:
  praxis: demiurge/update-manifest
```

**2. Validate on praxis change:**
```yaml
trigger:
  event: entity_updated
  eidos: praxis
response:
  praxis: demiurge/validate-praxis
```

**3. Notify on pragma received:**
```yaml
trigger:
  event: bond_created
  desmos: signals-to
  to_eidos: circle
response:
  praxis: soma/add-notification
  params:
    type: pragma_received
    pragma_id: "$from.id"
```

**4. Auto-register MCP tool on praxis added to developing oikos:**
```yaml
trigger:
  event: bond_created
  desmos: contains
  from_eidos: oikos
  to_eidos: praxis
  condition: '$from.data.status == "composing"'
response:
  praxis: demiurge/register-praxis-tool
```

This last reflex would **obsolete project-oikos** — praxeis become available automatically as they're added.

---

## Future Extensions

### Auto-creation from Failures

When a praxis fails due to a missing stoicheion, automatically create a pragma for it. The error becomes a tracked work item.

**With reflexes:** A reflex could fire on praxis execution failures, auto-creating pragma.

### Notification System

Alert circle members when pragma arrive. Integration with presence/attention system.

**With reflexes:** The pragma-signaled reflex triggers notification creation.

### Pragma Archiving

Policy for archiving resolved pragma while keeping the graph traversable.

### External Tool Sync

Bi-directional sync with GitHub Issues, Linear, etc. Pragma as the source of truth.

---

*Composed in service of the kosmogonia.*
*Work discovered flows to work accomplished. The graph remembers.*
*Reflexes close the loop from change to response.*
