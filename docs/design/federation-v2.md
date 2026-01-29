# Federation V2: Continuous Sync Through the Bond Graph

*Distribution = Federation. Same pipe for all content.*

---

## Grounding

From KOSMOGONIA:

> **Visibility = Reachability**
> You can only perceive what you can cryptographically reach through the bond graph.
> There is no separate permission layer. The bond graph IS the access control graph.

> **Continuous sync enables time-sensitive execution.**
> The mechanism that delivers oikoi also initiates ergon work.

Federation is not a special subsystem. It is the natural consequence of circles bonding across kosmoi.

---

## The Core Insight

A circle exists in a kosmos. When circles bond across kosmoi, their members can perceive each other's content. Federation sync makes this perception actual.

```
kosmos A                          kosmos B
    │                                 │
    └── circle/alpha ──[federates-with]── circle/beta ──┘
           │                                  │
           │ (bond implies sync)              │
           ▼                                  ▼
    entities in alpha              entities in beta
    become reachable               become reachable
    from kosmos B                  from kosmos A
```

The `federates-with` bond IS the sync relationship. No separate "link" entity needed.

---

## Ontology

### Existing Primitives (no new eide needed)

| What | How It Works |
|------|--------------|
| **circle** | Governance unit, contains entities via `contains` bonds |
| **desmos: federates-with** | Circle-to-circle bond establishing sync |
| **phoreta** | Signed bundle for transport (exists in hypostasis) |
| **data-channel** | WebRTC transport (exists in aither) |

### New Desmos

```yaml
desmos/federates-with:
  description: |
    Establishes federation between circles across kosmoi.
    Content in bonded circles syncs continuously.
    Both circles must bond (mutual consent).
  from_eidos: [circle]
  to_eidos: [circle]
  cardinality: many-to-many
  properties:
    - sync_direction: enum [push, pull, bidirectional]
    - eidos_filter: array[string]  # Which eide to sync (empty = all)
    - channel_id: string           # Underlying data-channel
```

### New Eidos (minimal)

```yaml
eidos/sync-cursor:
  description: |
    Tracks sync position per federation bond.
    Enables delta sync (only send what changed).
  fields:
    - federation_id: string    # ID of the federates-with bond
    - local_version: integer   # Last local version synced
    - remote_version: integer  # Last remote version received
    - updated_at: timestamp
```

```yaml
eidos/sync-conflict:
  description: |
    When the same entity diverges across kosmoi.
    Created when both sides modify independently.
  fields:
    - entity_id: string
    - local_version: integer
    - local_data: object
    - remote_version: integer
    - remote_data: object
    - status: enum [open, resolved]
    - resolution: enum [local, remote, merged]
    - resolved_at: timestamp
```

---

## The Sync Model

### Continuous, Not Batch

Traditional federation: "sync now" triggers batch transfer.
Kosmos federation: changes flow continuously as they happen.

```
Entity created/modified in circle A
    │
    ▼
Change event emitted locally
    │
    ▼
Reconciler checks: any federates-with bonds?
    │
    ▼
For each federated circle:
    - Package as phoreta (signed)
    - Send via data-channel
    │
    ▼
Remote receives, verifies, applies
```

### What Triggers Sync?

| Event | Action |
|-------|--------|
| Entity created | Push to federated circles |
| Entity modified | Push delta to federated circles |
| Bond created | Push if entity now visible |
| Federation established | Full sync of existing content |
| Dwell changes | No special action (sync is continuous) |

### Delta Sync via Version Vectors

Each entity has a version number (incremented on change).
Each federation bond has a sync-cursor tracking position.

```
sync-cursor for circle/alpha ↔ circle/beta:
  local_version: 147   # We've synced up to local version 147
  remote_version: 92   # We've received up to remote version 92
```

To sync:
1. Find entities with version > sync-cursor.local_version
2. Send as phoreta
3. Update cursor

---

## Conflict Resolution

When both kosmoi modify the same entity independently:

```
kosmos A: entity/foo version 5 → modified → version 6
kosmos B: entity/foo version 5 → modified → version 6'

Both syncs arrive:
  A receives B's version 6'
  B receives A's version 6
```

**Resolution strategies** (per-federation or per-eidos):

| Strategy | Behavior |
|----------|----------|
| `last-write-wins` | Higher version wins (simple but loses data) |
| `manual` | Create sync-conflict for human resolution |
| `merge` | Type-specific merge (for mergeable types) |

**Default**: `manual` for most types, `last-write-wins` for ephemeral.

---

## Transport Layer

Federation uses existing aither data-channels.

```
circle/alpha ──[federates-with]── circle/beta
                    │
                    │ channel_id: "chan_abc123"
                    ▼
              data-channel/chan_abc123
                    │
                    │ (WebRTC, propylon-relay signaling)
                    ▼
              Actual P2P connection
```

The `federates-with` bond references a data-channel. Aither reconciler manages the channel lifecycle.

---

## Praxeis

### Federation Management

```yaml
praxis/politeia/federate-circles:
  description: |
    Establish federation between local and remote circle.
    Creates mutual federates-with bonds and data-channel.
  params:
    - local_circle_id: string
    - remote_circle_id: string
    - remote_pubkey: string
    - sync_direction: enum [push, pull, bidirectional]
    - eidos_filter: array[string] (optional)
  steps:
    - Create data-channel via aither
    - Create federates-with bond (local → remote)
    - Signal remote to create reciprocal bond
    - Initialize sync-cursor
    - Trigger initial full sync

praxis/politeia/unfederate-circles:
  description: Dissolve federation, close channel.
  params:
    - federation_id: string
  steps:
    - Close data-channel
    - Remove federates-with bonds
    - Mark sync-cursor inactive
```

### Sync Operations

```yaml
praxis/politeia/sync-federation:
  description: |
    Push pending changes through federation.
    Called by reconciler, not usually by user.
  params:
    - federation_id: string
  steps:
    - Get sync-cursor
    - Find entities with version > cursor.local_version
    - Filter by eidos_filter if present
    - Package as phoreta
    - Send via data-channel
    - Update cursor

praxis/politeia/receive-phoreta:
  description: |
    Process incoming phoreta from federation.
    Handles conflict detection and resolution.
  params:
    - phoreta: object
    - federation_id: string
  steps:
    - Verify signature
    - Check for local entity
    - If no conflict: apply
    - If conflict: create sync-conflict or auto-resolve
    - Update sync-cursor.remote_version
```

### Conflict Resolution

```yaml
praxis/politeia/resolve-conflict:
  description: Resolve a sync conflict manually.
  params:
    - conflict_id: string
    - resolution: enum [local, remote, merged]
    - merged_data: object (if merged)
  steps:
    - Apply chosen resolution
    - Mark conflict resolved
    - Propagate resolved version
```

---

## Reconciler

Federation has one reconciler: `federation-reconciler`.

```yaml
reconciler/federation:
  triggers:
    - entity_changed       # Push changes to federated circles
    - channel_message      # Receive incoming phoreta
    - channel_state_change # Handle disconnect/reconnect
    - bond_created         # New federation bond

  reconcile:
    # On entity change: push to federated circles
    - trace federates-with bonds from entity's circle
    - for each: sync-federation

    # On channel message: process phoreta
    - receive-phoreta

    # On disconnect: mark federation as degraded
    # On reconnect: full delta sync
```

---

## Integration with Distribution

Oikos distribution falls out naturally:

```
commons/my-oikos ──[distributes]──► oikos-prod/foo-1.0.0

user joins commons/my-oikos via invitation
    │
    ▼
commons/my-oikos ──[federates-with]──► user's self circle
    │
    ▼
Federation sync delivers oikos-prod/foo-1.0.0
```

The `distributes` bond makes oikos-prod visible. The `federates-with` bond makes it sync. Same mechanism as expressions, theoria, or any other content.

---

## Integration with Ergon

Work coordination uses the same pipe:

```
circle/project ──[federates-with]──► peer circles

ergon/task-123 created in circle/project
    │
    ▼
Federation sync delivers to all federated circles
    │
    ▼
Remote circles see the task, can claim/execute
```

Continuous sync means work appears immediately. No polling.

---

## Security Model

| Concern | Mitigation |
|---------|------------|
| Unauthorized sync | Must have mutual federates-with bond |
| Content tampering | Phoreta signature verification |
| Replay attacks | Version vectors prevent re-application |
| Visibility leak | Bond graph IS visibility; no back doors |

---

## Implementation Path

### Phase 1: Ontology (kosmos)
1. Add `federates-with` desmos to politeia
2. Add `sync-cursor` eidos to politeia
3. Add `sync-conflict` eidos to politeia
4. Add federation praxeis (federate-circles, sync-federation, etc.)

### Phase 2: Reconciler (chora)
1. Implement federation-reconciler in Rust
2. Wire to entity change events
3. Wire to aither channel events
4. Implement phoreta send/receive via data-channel

### Phase 3: Conflict UI (thyra)
1. Surface sync-conflicts in UI
2. Resolution interface (local/remote/merge)
3. Federation status indicator

### Phase 4: Self-Federation
1. Test same-persona across devices
2. Use hypostasis export/import for initial sync
3. Continuous sync via federation

### Phase 5: Circle Federation
1. Test circle-to-circle across kosmoi
2. Invitation flow creates federation
3. Oikos distribution via commons

---

## Comparison with Syndesmos V1

| Aspect | Syndesmos V1 | Federation V2 |
|--------|--------------|---------------|
| Link model | Separate syndesmos-link entity | federates-with desmos (simpler) |
| Sync trigger | Manual/batch | Continuous (entity change events) |
| Transport | Uses data-channel | Uses data-channel (same) |
| Phoreta | Separate tracking entity | Transport format only |
| Policies | Per-link sync-policy entity | Properties on federates-with bond |
| Conflicts | First-class entity | First-class entity (same) |

Key simplification: The bond IS the federation. No separate "link" abstraction.

---

## Open Questions

1. **Initial sync on federation**: Full dump or negotiated delta?
2. **Large entity graphs**: How to handle entities with many bonds?
3. **Offline/reconnect**: How long to buffer changes?
4. **Bandwidth**: Compression? Binary protocol?

---

*Federation is not a feature. It is the natural consequence of circles bonding across sovereign spaces.*

*Drafted 2026-01-29*
