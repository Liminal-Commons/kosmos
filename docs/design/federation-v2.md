# Substrate Reconciliation: Making One Kosmos Actual Across Many

*Reconciliation is the mechanism. Federation is the pattern that emerges.*

---

## Grounding

From KOSMOGONIA:

> **Visibility = Reachability**
> You can only perceive what you can cryptographically reach through the bond graph.
> There is no separate permission layer. The bond graph IS the access control graph.

> **Continuous sync enables time-sensitive execution.**
> The mechanism that delivers oikoi also initiates ergon work.

There is ONE kosmos — the ordering of entities and bonds that a dweller has relationship to. This kosmos may be actualized across multiple substrates (Victor's laptop, Victor's phone, Alice's device). Reconciliation ensures these actualizations stay consistent.

---

## The Core Insight

From any dweller's vantage, there is one kosmos — the world they dwell in. The fact that this kosmos is actualized across multiple substrates (different `.db` files on different hardware) is an implementation detail of actualization.

```
                         κόσμος (ONE)
            Victor's circles, bonds, entities, theoria
            ONE coherent ordering
                           │
                           │ actualization
           ┌───────────────┼───────────────┐
           ▼               ▼               ▼
      substrate A     substrate B     substrate C
      (laptop)        (phone)         (Alice's)
      kosmos.db       kosmos.db       kosmos.db
```

The **reconciler** ensures that changes on one substrate propagate to others, maintaining the coherence of the one kosmos across its actualizations.

---

## Two Scopes of Reconciliation

The reconciler is always substrate-level — it syncs between kosmos.db instances. What varies is the **visibility filter**:

### Self-Reconciliation

Same persona on multiple substrates. No scoping bond needed.

```
persona/victor on laptop  ←→  persona/victor on phone
         │                              │
         └──────── reconciler ──────────┘
                       │
              filter: everything
         (same persona = full visibility)
```

Victor's circles, theoria, expressions — all sync because Victor has visibility to all of it from both substrates.

### Circle-Scoped Reconciliation (Federation)

Different personas sharing a circle. The `federates-with` bond scopes what syncs.

```
circle/project contains entity/doc-123
         │
         ├── sovereign-to → animus (Victor)
         └── sovereign-to → animus (Alice)

Victor's substrate  ←→  Alice's substrate
         │                     │
         └──── reconciler ─────┘
                    │
           filter: circle/project
      (bond determines visibility)
```

When Victor adds content to circle/project, it syncs to Alice's substrate because she's sovereign to the same circle. The `federates-with` bond doesn't *start* federation — it *scopes* what the reconciler syncs.

---

## Reconciliation is the Mechanism

| Scope | What Syncs | Filter |
|-------|-----------|--------|
| Self | All of persona's content | None (same persona = full visibility) |
| Circle | Content in shared circle | Bond reachability (`federates-with`) |

The reconciler doesn't have "modes." It syncs entities that pass the visibility filter. The filter is determined by persona identity and bond graph reachability.

**Federation** is what we call it when the scope extends beyond self — when the reconciler syncs content between different personas' substrates, mediated by circle bonds.

---

## Ontology

### Existing Primitives

| What | Role |
|------|------|
| **circle** | Governance unit, determines visibility scope |
| **sovereign-to** | Bond connecting circle to animus (membership) |
| **desmos: federates-with** | Scopes circle-level reconciliation between personas |
| **phoreta** | Signed bundle for transport (exists in hypostasis) |
| **data-channel** | WebRTC transport (exists in aither) |

### Federation-Specific Desmos

```yaml
desmos/federates-with:
  description: |
    Scopes reconciliation for a circle across substrates.
    When personas share a circle, this bond determines sync behavior.
    The bond scopes — it doesn't initiate. Reconciliation is continuous.
  from_eidos: circle
  to_eidos: circle
  cardinality: many-to-many
  properties:
    sync_direction: enum [push, pull, bidirectional]
    eidos_filter: array[string]  # Which eide to sync (empty = all)
    channel_id: string           # Underlying data-channel
```

### Reconciliation-Tracking Eide

```yaml
eidos/sync-cursor:
  description: |
    Tracks sync position between substrates.
    Enables delta sync — only send what changed since last sync.
  fields:
    local_substrate_id: string   # This substrate's identifier
    remote_substrate_id: string  # Paired substrate's identifier
    scope: string                # "self" or circle ID
    local_version: integer       # Last local version synced
    remote_version: integer      # Last remote version received
    status: enum [active, paused, failed]
    last_sync_at: timestamp
```

```yaml
eidos/sync-conflict:
  description: |
    Created when the same entity diverges across substrates.
    Both substrates modified independently before reconciliation.
    Surfaces in UI for human resolution.
  fields:
    entity_id: string
    entity_eidos: string
    local_version: integer
    local_data: object
    remote_version: integer
    remote_data: object
    status: enum [open, resolved]
    resolution: enum [local, remote, merged]
    resolved_by: string
    detected_at: timestamp
    resolved_at: timestamp
```

---

## The Sync Model

### Continuous, Not Batch

Traditional sync: "sync now" triggers batch transfer.
Kosmos reconciliation: changes flow continuously as they happen.

```
Entity created/modified on substrate A
    │
    ▼
Change event emitted locally
    │
    ▼
Reconciler checks: what's the visibility scope?
    │
    ├── Self-reconciliation: sync to all of persona's substrates
    │
    └── Circle-scoped: sync to substrates with federates-with bond
    │
    ▼
For each target substrate:
    - Package as phoreta (signed)
    - Send via data-channel
    │
    ▼
Remote substrate receives, verifies, applies
```

### What Triggers Sync?

| Event | Action |
|-------|--------|
| Entity created | Push to substrates with visibility |
| Entity modified | Push delta to substrates with visibility |
| Bond created | Re-evaluate visibility, sync if newly visible |
| Circle membership | Full sync of circle content to new member's substrate |
| Substrate connects | Delta sync from last cursor position |

### Delta Sync via Version Vectors

Each entity has a version number (incremented on change).
Each substrate-pair has a sync-cursor tracking position.

```
sync-cursor for laptop ↔ phone (self):
  local_version: 147   # We've synced up to local version 147
  remote_version: 92   # We've received up to remote version 92
  scope: self
```

To sync:
1. Find entities with version > sync-cursor.local_version
2. Filter by visibility scope
3. Send as phoreta
4. Update cursor

---

## Conflict Resolution

When substrates modify the same entity before reconciliation:

```
substrate A: entity/foo version 5 → modified → version 6
substrate B: entity/foo version 5 → modified → version 6'

Both syncs arrive:
  A receives B's version 6'
  B receives A's version 6
```

**Resolution strategies** (per-scope or per-eidos):

| Strategy | Behavior |
|----------|----------|
| `last-write-wins` | Higher timestamp wins (simple but loses data) |
| `manual` | Create sync-conflict for human resolution |
| `merge` | Type-specific merge (for mergeable types) |

**Default**: `manual` for most types, `last-write-wins` for ephemeral.

---

## Transport Layer

Reconciliation uses aither data-channels for substrate-to-substrate communication.

```
substrate A  ────[data-channel]────  substrate B
                     │
                     │ channel_id: "chan_abc123"
                     ▼
            WebRTC P2P connection
            (propylon-relay signaling)
```

For self-reconciliation, the channel connects the same persona's substrates.
For circle-scoped reconciliation, the channel connects different personas' substrates.

---

## Praxeis

### Substrate Registration

```yaml
praxis/hypostasis/register-substrate:
  description: |
    Register this substrate for reconciliation.
    Creates substrate identity for sync tracking.
  params:
    persona_id: string
  steps:
    - Generate substrate ID if not exists
    - Create substrate record
    - Initialize for self-reconciliation
```

### Self-Reconciliation

```yaml
praxis/hypostasis/sync-self:
  description: |
    Sync persona's full kosmos to another of their substrates.
    No circle bond needed — same persona means full visibility.
  params:
    remote_substrate_id: string
    channel_id: string (optional)
  steps:
    - Get or create sync-cursor (scope: self)
    - Gather entities with version > cursor
    - Package as phoreta
    - Send via data-channel
    - Update cursor
```

### Circle-Scoped Reconciliation

```yaml
praxis/politeia/federate-circle:
  description: |
    Enable circle-scoped reconciliation with another persona's substrate.
    Creates federates-with bond to scope what syncs.
  params:
    circle_id: string
    remote_substrate_id: string
    remote_persona_pubkey: string
    sync_direction: enum [push, pull, bidirectional]
  steps:
    - Verify caller is sovereign to circle
    - Create federates-with bond with scope properties
    - Create data-channel via aither
    - Initialize sync-cursor (scope: circle_id)
    - Trigger initial sync of circle content

praxis/politeia/unfederate-circle:
  description: Remove circle-scoped reconciliation.
  params:
    circle_id: string
    remote_substrate_id: string
  steps:
    - Close data-channel
    - Remove federates-with bond
    - Mark sync-cursor inactive
```

### Conflict Resolution

```yaml
praxis/politeia/resolve-conflict:
  description: Resolve a sync conflict manually.
  params:
    conflict_id: string
    resolution: enum [local, remote, merged]
    merged_data: object (if merged)
  steps:
    - Apply chosen resolution
    - Mark conflict resolved
    - Propagate resolved version to paired substrates
```

---

## Reconciler

One reconciler handles both scopes: `substrate-reconciler`.

```yaml
reconciler/substrate:
  triggers:
    - entity_changed       # Push to substrates with visibility
    - channel_message      # Receive incoming phoreta
    - channel_state_change # Handle disconnect/reconnect
    - bond_created         # Re-evaluate visibility scope

  reconcile:
    # On entity change
    - determine visibility scope (self or circle)
    - for each substrate in scope: sync

    # On channel message
    - verify phoreta signature
    - check for conflict
    - apply or create sync-conflict

    # On disconnect
    - mark sync-cursor as degraded

    # On reconnect
    - delta sync from cursor position
```

---

## Integration with Distribution

Oikos distribution uses circle-scoped reconciliation:

```
commons/my-oikos ──[distributes]──► oikos-prod/foo-1.0.0

user joins commons/my-oikos via invitation
    │
    ▼
user's animus becomes sovereign to commons/my-oikos
    │
    ▼
circle-scoped reconciliation syncs oikos-prod/foo-1.0.0
to user's substrate
```

The `distributes` bond makes oikos-prod visible within the circle. Circle membership makes it sync to the member's substrate. Same mechanism as expressions, theoria, or any other content.

---

## Integration with Ergon

Work coordination uses the same mechanism:

```
circle/project contains ergon/task-123

Alice creates task in circle/project
    │
    ▼
circle-scoped reconciliation delivers to Victor's substrate
    │
    ▼
Victor sees task, can claim/execute
```

Continuous reconciliation means work appears immediately. No polling.

---

## Security Model

| Concern | Mitigation |
|---------|------------|
| Unauthorized sync | Visibility determined by bond graph; no back doors |
| Content tampering | Phoreta signature verification |
| Replay attacks | Version vectors prevent re-application |
| Substrate impersonation | Substrate ID tied to persona keypair |

---

## Implementation Path

### Phase 1: Ontology (kosmos) ✓
1. Add `federates-with` desmos to politeia ✓
2. Add `sync-cursor` eidos to politeia ✓
3. Add `sync-conflict` eidos to politeia ✓
4. Add reconciliation praxeis

### Phase 2: Reconciler (chora)
1. Implement substrate-reconciler in Rust ✓ (partial)
2. Wire to entity change events
3. Wire to aither channel events
4. Implement phoreta send/receive via data-channel

### Phase 3: Conflict UI (thyra)
1. Surface sync-conflicts in UI
2. Resolution interface (local/remote/merge)
3. Reconciliation status indicator

### Phase 4: Self-Reconciliation
1. Test same-persona across devices
2. Use hypostasis export/import for initial sync
3. Continuous sync via reconciler

### Phase 5: Circle-Scoped Reconciliation
1. Test circle-to-circle across personas
2. Invitation flow establishes federation
3. Oikos distribution via commons circles

---

## Open Questions

1. **Initial sync**: Full dump or negotiated delta?
2. **Large entity graphs**: How to handle entities with many bonds?
3. **Offline/reconnect**: How long to buffer changes?
4. **Bandwidth**: Compression? Binary protocol?
5. **Substrate identity**: How does substrate ID relate to device vs app instance?

---

*Reconciliation is the mechanism by which one kosmos stays coherent across its actualizations.*
*Federation is what we call it when the scope extends beyond self.*

*Drafted 2026-01-29, revised 2026-01-29*
