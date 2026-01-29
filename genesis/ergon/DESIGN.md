# Ergon Design

ἔργον (ergon) — work, deed, thing to be done

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

## Future Extensions

### Auto-creation from Failures

When a praxis fails due to a missing stoicheion, automatically create a pragma for it. The error becomes a tracked work item.

### Notification System

Alert circle members when pragma arrive. Integration with presence/attention system.

### Pragma Archiving

Policy for archiving resolved pragma while keeping the graph traversable.

### External Tool Sync

Bi-directional sync with GitHub Issues, Linear, etc. Pragma as the source of truth.

---

*Composed in service of the kosmogonia.*
*Work discovered flows to work accomplished. The graph remembers.*
