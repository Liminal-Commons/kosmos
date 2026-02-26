# Substrate Reconciliation: Making One Kosmos Actual Across Many

*Reconciliation is the mechanism. Federation is the pattern that emerges.*

---

## Grounding

From KOSMOGONIA:

> **Visibility = Reachability**
> You can only perceive what you can cryptographically reach through the bond graph.
> There is no separate permission layer. The bond graph IS the access control graph.

> **Continuous sync enables time-sensitive execution.**
> The mechanism that delivers topoi also initiates ergon work.

There is ONE kosmos — the ordering of entities and bonds that a dweller has relationship to. This kosmos may be actualized across multiple substrates (Victor's laptop, Victor's phone, Alice's device). Reconciliation ensures these actualizations stay consistent.

---

## The Core Insight

From any dweller's vantage, there is one kosmos — the world they dwell in. The fact that this kosmos is actualized across multiple substrates (different `.db` files on different hardware) is an implementation detail of actualization.

```
                         κόσμος (ONE)
            Victor's oikoi, bonds, entities, theoria
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

Same prosopon on multiple substrates. No scoping bond needed.

```
prosopon/victor on laptop  ←→  prosopon/victor on phone
         │                              │
         └──────── reconciler ──────────┘
                       │
              filter: everything
         (same prosopon = full visibility)
```

Victor's oikoi, theoria, phaseis — all sync because Victor has visibility to all of it from both substrates.

### Oikos-Scoped Reconciliation (Federation)

Different prosopa sharing an oikos. The `federates-with` bond scopes what syncs.

```
oikos/project contains entity/doc-123
         │
         ├── sovereign-to → parousia (Victor)
         └── sovereign-to → parousia (Alice)

Victor's substrate  ←→  Alice's substrate
         │                     │
         └──── reconciler ─────┘
                    │
           filter: oikos/project
      (bond determines visibility)
```

When Victor adds content to oikos/project, it syncs to Alice's substrate because she's sovereign to the same oikos. The `federates-with` bond doesn't *start* federation — it *scopes* what the reconciler syncs.

---

## Reconciliation is the Mechanism

| Scope | What Syncs | Filter |
|-------|-----------|--------|
| Self | All of prosopon's content | None (same prosopon = full visibility) |
| Oikos | Content in shared oikos | Bond reachability (`federates-with`) |

The reconciler doesn't have "modes." It syncs entities that pass the visibility filter. The filter is determined by prosopon identity and bond graph reachability.

**Federation** is what we call it when the scope extends beyond self — when the reconciler syncs content between different prosopa' substrates, mediated by oikos bonds.

---

## Ontology

### Existing Primitives

| What | Role |
|------|------|
| **oikos** | Governance unit, determines visibility scope |
| **sovereign-to** | Bond connecting oikos to parousia (membership) |
| **desmos: federates-with** | Scopes oikos-level reconciliation between prosopa |
| **phoreta** | Signed bundle for transport (exists in hypostasis) |
| **data-channel** | WebRTC transport (exists in aither) |

### Federation-Specific Desmos

```yaml
desmos/federates-with:
  description: |
    Scopes reconciliation for an oikos across substrates.
    When prosopa share an oikos, this bond determines sync behavior.
    The bond scopes — it doesn't initiate. Reconciliation is continuous.
  from_eidos: oikos
  to_eidos: oikos
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
    scope: string                # "self" or oikos ID
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
    ├── Self-reconciliation: sync to all of prosopon's substrates
    │
    └── Oikos-scoped: sync to substrates with federates-with bond
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
| Oikos membership | Full sync of oikos content to new member's substrate |
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

For self-reconciliation, the channel connects the same prosopon's substrates.
For oikos-scoped reconciliation, the channel connects different prosopa' substrates.

---

## Praxeis

### Substrate Registration

```yaml
praxis/hypostasis/register-substrate:
  description: |
    Register this substrate for reconciliation.
    Creates substrate identity for sync tracking.
  params:
    prosopon_id: string
  steps:
    - Generate substrate ID if not exists
    - Create substrate record
    - Initialize for self-reconciliation
```

### Self-Reconciliation

```yaml
praxis/hypostasis/sync-self:
  description: |
    Sync prosopon's full kosmos to another of their substrates.
    No oikos bond needed — same prosopon means full visibility.
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

### Oikos-Scoped Reconciliation

```yaml
praxis/politeia/federate-oikos:
  description: |
    Enable oikos-scoped reconciliation with another prosopon's substrate.
    Creates federates-with bond to scope what syncs.
  params:
    oikos_id: string
    remote_substrate_id: string
    remote_prosopon_pubkey: string
    sync_direction: enum [push, pull, bidirectional]
  steps:
    - Verify caller is sovereign to oikos
    - Create federates-with bond with scope properties
    - Create data-channel via aither
    - Initialize sync-cursor (scope: oikos_id)
    - Trigger initial sync of oikos content

praxis/politeia/unfederate-oikos:
  description: Remove oikos-scoped reconciliation.
  params:
    oikos_id: string
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
    - determine visibility scope (self or oikos)
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

Topos distribution uses oikos-scoped reconciliation:

```
commons/my-topos ──[distributes]──► topos-prod/foo-1.0.0

user joins commons/my-topos via invitation
    │
    ▼
user's parousia becomes sovereign to commons/my-topos
    │
    ▼
oikos-scoped reconciliation syncs topos-prod/foo-1.0.0
to user's substrate
```

The `distributes` bond makes topos-prod visible within the oikos. Oikos membership makes it sync to the member's substrate. Same mechanism as phaseis, theoria, or any other content.

---

## Integration with Ergon

Work coordination uses the same mechanism:

```
oikos/project contains ergon/task-123

Alice creates task in oikos/project
    │
    ▼
oikos-scoped reconciliation delivers to Victor's substrate
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
| Substrate impersonation | Substrate ID tied to prosopon keypair |

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
1. Test same-prosopon across devices
2. Use hypostasis export/import for initial sync
3. Continuous sync via reconciler

### Phase 5: Oikos-Scoped Reconciliation
1. Test oikos-to-oikos across prosopa
2. Invitation flow establishes federation
3. Topos distribution via commons oikoi

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
