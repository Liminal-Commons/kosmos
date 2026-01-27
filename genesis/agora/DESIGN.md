# Agora: Spatial Gathering Oikos

*ἀγορά — the public assembly, where citizens gather*

---

## Purpose

The agora is where members of a circle gather — 2D spatial territories (Phaser.js) with proximity-based presence and communication (LiveKit). Like the ancient Greek agora, it's the space for assembly, discussion, and shared experience.

**Key insight:** Infrastructure is owned by the circle, not a corporate service. A commons can run its own LiveKit server on its own hardware.

---

## Ontological Alignment

| Concept | Greek | Meaning in Agora |
|---------|-------|------------------|
| Territory | τόπος | The place where gathering occurs |
| Presence | παρουσία | Being-there in the territory |
| Room | δωμάτιον | The communication chamber |

The agora operates at **klimax level 4 (oikos)** — the intimate scale where members dwell together.

---

## Vision: Infrastructure Through Kosmos

```
Core Dev Circle
    │  ← develops agora oikos
    ▼
Commons Circle (e.g., Liminal Commons)
    │  ← installs agora oikos
    │  ← owns infrastructure entities (livekit-server, territory)
    │  ← grants attainments to members
    ▼
NixOS Server (96GB RAM, 4TB NVMe, NPU)
    │  ← reconciliation actualizes infrastructure
    │  ← runs LiveKit, serves territories
    ▼
Circle Members
    ← enter agora via thyra
    ← spatial audio/video, shared presence
```

**The path to infrastructure is through kosmos, not chora.** We don't SSH into servers; we compose infrastructure entities and let reconciliation actualize them.

---

## Eide

### territory

The 2D space where members gather.

| Field | Type | Description |
|-------|------|-------------|
| name | string | Human-readable territory name |
| dimensions | object | { width, height } in units |
| tilemap_url | string | URL to Phaser tilemap JSON |
| spawn_point | object | { x, y } default entry location |
| capacity | number | Maximum concurrent occupants |
| room_name | string | Associated LiveKit room |
| status | enum | active, locked, archived |

### presence

An animus present in a territory — ephemeral, created on enter, destroyed on leave.

| Field | Type | Description |
|-------|------|-------------|
| position | object | { x, y } |
| facing | enum | up, down, left, right |
| status | enum | active, away, do-not-disturb |
| audio_enabled | boolean | Audio stream active |
| video_enabled | boolean | Video stream active |
| display_name | string | Shown above avatar |

### livekit-server

Infrastructure entity with actuality reconciliation.

| Field | Type | Description |
|-------|------|-------------|
| host | string | e.g., livekit.liminalcommons.com |
| ws_url | string | WebSocket URL |
| api_key_ref | string | Secret reference |
| api_secret_ref | string | Secret reference |
| status | enum | provisioning, running, stopped, error |

**Actuality:** `mode: process, provider: nixos`

### room

A LiveKit room for audio/video communication.

| Field | Type | Description |
|-------|------|-------------|
| name | string | Unique room identifier |
| max_participants | number | Capacity |
| recording_enabled | boolean | Recording active |
| transcription_enabled | boolean | Local whisper via NPU |

---

## Desmoi

| Desmos | From | To | Meaning |
|--------|------|-----|---------|
| `hosts-territory` | circle | territory | Circle owns this space |
| `operates-server` | circle | livekit-server | Circle runs this infrastructure |
| `present-in` | presence | territory | Animus is here |
| `uses-room` | territory | room | Territory's communication layer |
| `served-by` | room | livekit-server | Room runs on this server |
| `instantiates-presence` | animus | presence | Animus embodies this presence |

---

## Attainments

| Attainment | Grants |
|------------|--------|
| `agora-enter` | Can enter agora territories in circle |
| `agora-speak` | Can enable audio in agora |
| `agora-video` | Can enable video in agora |
| `agora-create` | Can create new territories |
| `agora-admin` | Can manage territories, moderate |

---

## Praxeis

### agora/enter

Enter a territory, creating presence.

```
params: territory_id, spawn_at?
returns: presence_id, territory, livekit_token, livekit_url
```

1. Assert embodiment (animus exists)
2. Find territory
3. Verify circle membership (visibility = reachability)
4. Get LiveKit token
5. Create presence entity
6. Bind presence to territory
7. Bind animus to presence

### agora/move

Update position in territory.

```
params: presence_id, position, facing?
returns: (signals to other presences)
```

### agora/leave

Exit territory, destroying presence.

```
params: presence_id
returns: status
```

### agora/create-territory

Create a new gathering territory.

```
params: name, dimensions?, tilemap_url?, spawn_point?, capacity?
returns: territory_id, room_id, status
```

### agora/actualize-server

Reconcile livekit-server with infrastructure.

```
params: server_id
returns: status, server
```

Uses phylax pattern: sense → compare → manifest

---

## Integration with Thyra

Thyra renders the agora in the WebView:

```
┌─────────────────────────────────────────────────────────────┐
│                         Thyra                                │
├──────────────────────┬──────────────────────────────────────┤
│     Rust Backend     │         WebView Frontend             │
│  ┌────────────────┐  │  ┌────────────────────────────────┐  │
│  │ agora praxeis  │  │  │      Phaser.js Canvas          │  │
│  │                │──┼─►│  ┌──────────────────────────┐  │  │
│  │ presence sync  │◄─┼──│  │    Territory Tilemap     │  │  │
│  └────────────────┘  │  │  │    Avatar Sprites        │  │  │
│         │            │  │  │    Proximity Zones       │  │  │
│  ┌──────▼─────────┐  │  │  └──────────────────────────┘  │  │
│  │ livekit-client │  │  │                                │  │
│  │ (rust/wasm)    │──┼─►│  ┌──────────────────────────┐  │  │
│  └────────────────┘  │  │  │    LiveKit Tracks        │  │  │
│                      │  │  │    Audio/Video Elements  │  │  │
│                      │  │  └──────────────────────────┘  │  │
└──────────────────────┴──────────────────────────────────────┘
```

---

## Constitutional Alignment

| Principle | How Agora Honors It |
|-----------|---------------------|
| **Sovereignty** | Circle owns its infrastructure. No corporate dependency. |
| **Visibility = Reachability** | You see others in territory because you have `agora-enter` attainment. |
| **Infrastructure as Entity** | Servers are entities with reconciliation, not manual config. |
| **Composition** | Territories, presences, rooms all compose from definitions with provenance. |

**Caller Pattern:** Most agora content uses `literal` or `computed` patterns. Infrastructure config is literal (it's what you want). Presence is computed (derived from movement).

---

## Implementation Path

### Phase 1: Core Entities
- Define eide: territory, presence, room, livekit-server
- Define desmoi: hosts-territory, present-in, uses-room, served-by
- Define attainments: agora-enter, agora-speak, agora-video

### Phase 2: Basic Praxeis
- enter, move, leave
- create-territory
- Basic presence sync

### Phase 3: LiveKit Integration
- Token generation
- Spatial audio configuration
- Video track management

### Phase 4: Phaser.js Frontend
- Territory rendering
- Avatar movement
- Proximity-based UI

### Phase 5: Infrastructure Actualization
- livekit-server actuality mode (NixOS)
- actualize-server praxis
- Local AI services (whisper, LLM)

---

## Dependencies

| Dependency | Status | Notes |
|------------|--------|-------|
| Thyra (WebView) | ✅ | UI rendering |
| aither (signaling) | ✅ | WebRTC foundation |
| dynamis (actuality) | ✅ | Infrastructure reconciliation |
| LiveKit server | ⏳ To Deploy | On NixOS server |

---

*The agora is where circles become communities.*
*Infrastructure through kosmos, not chora.*
*Traces to: expression/genesis-root*
