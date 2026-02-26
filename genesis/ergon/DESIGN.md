# Ergon Design

ἔργον (ergon) — work, deed, thing to be done

> Ergon's reflex system provides autonomic response to graph mutations.

## Ontological Purpose

Ergon addresses **the gap between discovery and capability** — the coordination of work across discipline boundaries where gaps are discovered in one context but must be resolved in another.

Without ergon:
- Gaps discovered during dwelling vanish into conversation
- Work items have no graph representation
- Cross-oikos coordination requires external tools
- Resolution has no traceability to discovery

With ergon:
- **Pragma entities**: Gaps become first-class entities
- **Signals-to bonds**: Work flows to oikoi with capability
- **Evidence bonds**: Traceability from gap to what demonstrated it
- **Resolution bonds**: Traceability from gap to what fixed it

The central concept is the **pragma** (πρᾶγμα — a thing to be done). A pragma is created where a gap is discovered and signals to the oikos with the capability to resolve it.

## Oikos Context

### Self Oikos

A solitary dweller uses ergon to:
- Track gaps discovered during exploration
- Create pragma for self-reminders
- Mark pragma resolved when addressed
- Maintain personal work queue

Self-oikos pragma are notes about what needs doing.

### Peer Oikos

Collaborators use ergon to:
- Signal gaps discovered in shared work
- Accept pragma to take ownership
- Track who is working on what
- Resolve pragma with shared visibility

Peer oikos pragma enable coordination without external tools.

### Commons Oikos

A commons uses ergon to:
- Receive pragma from member oikoi (kosmos → chora)
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

Pragma signals to an oikos for attention.

- **From:** pragma
- **To:** oikos
- **Cardinality:** many-to-one
- **Traversal:** Find pragma waiting for an oikos's attention

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

Create a pragma and signal it to a target oikos.

- **When:** Gap discovered requiring work in another context
- **Requires:** signal attainment
- **Provides:** Pragma entity bonded to target oikos

### list-pragma

List pragma signaled to an oikos, optionally filtered by status.

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

Signal capability — creating gaps for other oikoi's attention.

- **Grants:** create-pragma
- **Scope:** oikos
- **Rationale:** Signaling requires membership in the discovering oikos

### attainment/work

Work capability — managing pragma lifecycle.

- **Grants:** list-pragma, accept-pragma, resolve-pragma, sense-pragma
- **Scope:** oikos
- **Rationale:** Work operations require membership in the target oikos

## Embodiment

### Completeness Status

| Level | Status |
|-------|--------|
| Defined | 2 eide (pragma, reflex), 4 desmoi, 5 praxeis |
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

Pragma signal to oikoi. Oikos membership determines who can accept/resolve.

### amplifies nous

Pragma can be indexed, related to theoria. Resolution becomes searchable knowledge.

### amplifies thyra

Pragma could surface as phaseis in the portal for discussion.

### amplifies dynamis

Pragma follow similar lifecycle to releases (open → in_progress → resolved).

## Theoria

### T55: Gaps discovered are gaps captured

When work is interrupted by a gap, capturing it as a pragma preserves the discovery. The alternative — making a mental note or mentioning in chat — loses the structured context.

### T56: Work flows to capability

Pragma signal to oikoi where capability exists. A gap in kosmos signals to chora because that's where the interpreter lives. The graph knows where work should flow.

### T57: Resolution completes the loop

Bonding the resolving entity to the pragma creates traceability. Future exploration can trace from gap discovery through to what fixed it. This is institutional memory in graph form.

## Reflex System — Autonomic Response

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

### Homoiconic Reactive Architecture

Reflexes, triggers, and responses are all entities connected by bonds. No inline trigger/response fields -- the graph IS the configuration.

```
reflex --[triggered-by]--> trigger --[matches-event]--> mutation-event
                                  \--[filters-eidos]--> eidos (optional)
                                  \--[filters-desmos]--> desmos (optional)
reflex --[responds-with]--> praxis (bond data carries params)
```

This homoiconic form means:
- Triggers are reusable across reflexes (many-to-one)
- The graph can be traversed to answer "what responds to this event?"
- Configuration is queryable, not embedded in opaque fields

### Example: Pragma Signaled

When a pragma signals to an oikos, notify members:

```yaml
# Trigger entity
- eidos: trigger
  id: trigger/pragma-signaled
  data:
    name: pragma-signaled
    enabled: true

# Reflex entity
- eidos: reflex
  id: reflex/ergon/pragma-signaled
  data:
    name: pragma-signaled
    description: Add notification when pragma signals to an oikos.
    enabled: true
    scope: global

# Bonds connecting the pieces
- bond:
    from: trigger/pragma-signaled
    desmos: matches-event
    to: bond-mutation/created

- bond:
    from: trigger/pragma-signaled
    desmos: filters-desmos
    to: desmos/signals-to

- bond:
    from: reflex/ergon/pragma-signaled
    desmos: triggered-by
    to: trigger/pragma-signaled

- bond:
    from: reflex/ergon/pragma-signaled
    desmos: responds-with
    to: praxis/soma/add-notification
    data:
      params:
        type: pragma_received
        oikos_id: "$to.id"
        pragma_id: "$from.id"
```

### Reflex vs Reconciler

| Aspect | Reconciler | Reflex |
|--------|------------|--------|
| **Trigger** | Poll-based (intent vs actuality) | Event-based (mutation occurred) |
| **Focus** | State convergence | Immediate response |
| **Use case** | External resources (deploy, DNS) | Internal graph housekeeping |
| **Latency** | Polling interval | Immediate (post-commit) |

Reconcilers answer: "Is intent aligned with actuality?"
Reflexes answer: "Something changed -- what should happen?"

### Reflex Eidos

```yaml
- eidos: reflex
  fields:
    name: Short identifier
    description: What this reflex does
    enabled: Whether this reflex is active
    scope: oikos | topos | global
    oikos_id: Oikos ID when scope is 'oikos'
    topos_id: Topos ID when scope is 'topos'
```

Trigger and response are expressed via bonds, not inline fields:
- `triggered-by` bond to a `trigger` entity
- `responds-with` bond to a `praxis` entity (bond data carries params)

### Trigger Eidos

```yaml
- eidos: trigger
  fields:
    name: Short identifier for this trigger pattern
    condition: Expression evaluated against mutation context
    enabled: Whether this trigger is active
```

Trigger scope is expressed via bonds:
- `matches-event` bond to `entity-mutation` or `bond-mutation` instance
- `filters-eidos` bond to an `eidos` (optional)
- `filters-desmos` bond to a `desmos` (optional)

### Mutation Events

| Event | Context Variables | Use Case |
|-------|-------------------|----------|
| `entity-mutation/created` | `$entity` | New entity arrived |
| `entity-mutation/updated` | `$entity`, `$previous` | Entity data changed |
| `entity-mutation/deleted` | `$entity` | Entity removed |
| `bond-mutation/created` | `$bond`, `$from`, `$to` | Relationship established |
| `bond-mutation/updated` | `$bond`, `$from`, `$to`, `$previous` | Bond data changed |
| `bond-mutation/deleted` | `$bond`, `$from`, `$to` | Relationship dissolved |

### Scope

- **oikos** -- Reflex fires only for mutations within a specific oikos
- **topos** -- Reflex fires for mutations involving entities of a topos
- **global** -- Reflex fires for all matching mutations

### Implementation Path

**In kosmos (schema-driven):**
1. Reflex, trigger, and mutation-event eide define the reactive vocabulary
2. Entities and bonds loaded at bootstrap
3. Trigger registry indexed by event type for fast lookup via graph traversal

**In chora (event-driven):**
1. Entity/bond mutations fire post-commit hook
2. Hook traverses `matches-event` bonds to find matching triggers
3. Traverses `triggered-by` bonds to find reflexes
4. Traverses `responds-with` bonds to find response praxeis
5. Response praxis invoked with mutation context and bond params
6. Reflex execution logged for auditability

### Relationship to Cursor Model

The cursor model (`last-saw` desmos) tracks what Claude has *observed*.
Reflexes track what the *system* should *do* in response to changes.

They complement each other:
- Cursor: "What's new for Claude to see?"
- Reflex: "What should happen automatically?"

---

## Future Extensions

### Auto-creation from Failures

When a praxis fails due to a missing stoicheion, automatically create a pragma for it. The error becomes a tracked work item.

**With reflexes:** A reflex could fire on praxis execution failures, auto-creating pragma.

### Notification System

Alert oikos members when pragma arrive. Integration with parousia/attention system.

**With reflexes:** The pragma-signaled reflex triggers notification creation.

### Pragma Archiving

Policy for archiving resolved pragma while keeping the graph traversable.

### External Tool Sync

Bi-directional sync with GitHub Issues, Linear, etc. Pragma as the source of truth.

---

*Composed in service of the kosmogonia.*
*Work discovered flows to work accomplished. The graph remembers.*
*Reflexes close the loop from change to response.*
