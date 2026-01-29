# Agora Design

ἀγορά (agora) — the public assembly, where citizens gather

## Ontological Purpose

Agora addresses **the gap between being-together and being-apart** — the spatial medium where circle members encounter each other as present bodies, not just messages.

Without agora:
- Members are disembodied text
- Presence is binary (online/offline)
- Conversation has no spatial context
- Infrastructure depends on corporations

With agora:
- **Territories**: 2D spaces where gathering occurs
- **Presence**: Position, facing, status — being-there embodied
- **Proximity**: Near others → see and hear them
- **Sovereignty**: Circle owns its communication infrastructure

The central concept is the **territory** (τόπος) — a place where gathering occurs. Unlike chat rooms (aspatial), territories have dimension. You move through them. Proximity matters.

## Circle Context

### Self Circle

A solitary dweller uses agora to:
- Create private territories for focused work
- Leave presence as "away" when stepping back
- Test infrastructure setup (their own LiveKit)
- Practice spatial layouts for future gatherings

Self-territories enable personal spatial organization.

### Peer Circle

Collaborators use agora to:
- Gather in shared territories
- See each other's positions (who is near whom)
- Use proximity-based audio (walk closer to talk)
- Leave and return fluidly

Peer gathering creates the living room of collaboration.

### Commons Circle

A commons uses agora to:
- Host large gatherings (50+ simultaneous)
- Create multiple territories (lobby, workshop, quiet room)
- Run sovereign infrastructure (circle-owned LiveKit)
- Enable local AI services (whisper transcription via NPU)

Commons territories become the agora proper — the public assembly.

## Core Entities (Eide)

### territory

The 2D spatial environment where members gather.

**Fields:**
- `name` — human-readable territory name
- `dimensions` — { width, height } in units
- `tilemap_url` — URL to Phaser tilemap JSON
- `spawn_point` — { x, y } default entry location
- `capacity` — maximum concurrent occupants
- `room_name` — associated LiveKit room
- `status` — active, locked, archived

**Lifecycle:**
- Arise: create-territory composes new space
- Change: Status can lock (private event) or archive (defunct)
- Depart: delete-territory archives and evicts presences

### presence

An animus present in a territory — ephemeral embodiment.

**Fields:**
- `position` — { x, y } in territory coordinates
- `facing` — up, down, left, right
- `status` — active, away, do-not-disturb
- `audio_enabled`, `video_enabled` — media state
- `display_name` — shown above avatar

**Lifecycle:**
- Arise: enter creates presence at spawn point
- Change: move updates position, toggle-audio/video changes media
- Depart: leave destroys presence

### livekit-server

Circle-owned real-time communication infrastructure.

**Fields:**
- `host` — e.g., livekit.liminalcommons.com
- `ws_url` — WebSocket URL for connections
- `api_key_ref`, `api_secret_ref` — secret references
- `status` — provisioning, running, stopped, error

**Actuality:**
- Mode: process
- Provider: nixos
- Reconciliation: actualize-server aligns with infrastructure

### room

A LiveKit room for audio/video communication.

**Fields:**
- `name` — unique room identifier
- `max_participants` — capacity
- `recording_enabled` — recording active
- `transcription_enabled` — local whisper via NPU

**Lifecycle:**
- Arise: Created when territory is created
- Bond: Bound to territory (uses-room) and server (served-by)

## Bonds (Desmoi)

### hosts-territory

Circle hosts this territory.

- **From:** circle
- **To:** territory
- **Cardinality:** one-to-many
- **Traversal:** Find all territories for a circle

### operates-server

Circle operates this LiveKit server.

- **From:** circle
- **To:** livekit-server
- **Cardinality:** one-to-few
- **Traversal:** Find infrastructure for a circle

### present-in

Presence is located in this territory.

- **From:** presence
- **To:** territory
- **Cardinality:** many-to-one
- **Traversal:** List who is in a territory

### uses-room

Territory uses this room for communication.

- **From:** territory
- **To:** room
- **Cardinality:** one-to-one
- **Traversal:** Get room for territory

### served-by

Room runs on this LiveKit server.

- **From:** room
- **To:** livekit-server
- **Cardinality:** many-to-one
- **Traversal:** Route room to server

### instantiates-presence

Animus embodies this presence.

- **From:** animus
- **To:** presence
- **Cardinality:** one-to-many (one per territory)
- **Traversal:** Find animus's presences across territories

## Operations (Praxeis)

### Core Presence Operations

- **enter**: Enter territory, create presence, get LiveKit token
- **move**: Update position and facing in territory
- **leave**: Exit territory, destroy presence
- **get-presences**: List all presences in a territory

### Media Operations

- **toggle-audio**: Enable/disable audio streaming
- **toggle-video**: Enable/disable video streaming
- **update-presence-status**: Change status (active, away, dnd)

### Territory Management

- **create-territory**: Create new gathering space for circle
- **list-territories**: List all territories in circle
- **delete-territory**: Archive territory, evict presences

### Infrastructure Operations

- **create-livekit-server**: Create infrastructure entity for circle
- **actualize-server**: Reconcile server entity with NixOS
- **get-room-token**: Generate LiveKit token for participant

## Attainments

### attainment/agora-enter

Basic participation — can enter and exist in territories.

- **Grants:** enter, leave, move, get-presences
- **Scope:** circle
- **Rationale:** Entry is circle membership in spatial form

### attainment/agora-speak

Audio capability — can enable voice communication.

- **Grants:** toggle-audio
- **Scope:** circle
- **Rationale:** Voice requires trust; some spaces may be listen-only

### attainment/agora-video

Video capability — can enable video streaming.

- **Grants:** toggle-video
- **Scope:** circle
- **Rationale:** Video is more intimate; separate from audio permission

### attainment/agora-create

Space creation — can create new territories.

- **Grants:** create-territory, list-territories
- **Scope:** circle
- **Rationale:** Territory creation shapes the circle's spatial topology

### attainment/agora-admin

Management — can manage territories and infrastructure.

- **Grants:** delete-territory, create-livekit-server, actualize-server, get-room-token, update-presence-status (for moderation)
- **Scope:** circle
- **Rationale:** Infrastructure requires governance authority

## Embodiment

### Completeness Status

| Level | Status |
|-------|--------|
| Defined | 4 eide, 6 desmoi, 13 praxeis |
| Loaded | Bootstrap loads all definitions |
| Projected | All praxeis visible as MCP tools |
| Embodied | Partial — presence state in body-schema |
| Surfaced | Future — "3 others in Main Hall" |
| Afforded | Future — territory list, enter button |

### Body-Schema Contribution

When sense-body gathers agora state:

```yaml
agora:
  current_territory: "Main Hall"
  position: { x: 450, y: 320 }
  presences_nearby: 3
  audio_enabled: true
  video_enabled: false
  territories_available: 2
```

This reveals spatial context and social presence.

### Reconciler

An agora reconciler would surface:

- **Infrastructure drift** — "LiveKit server unreachable"
- **Crowded territory** — "Main Hall at 90% capacity"
- **Abandoned presence** — "Your presence in Workshop idle 30 min"
- **New gathering** — "5 others just entered Main Hall"

## Compound Leverage

### amplifies thyra

Thyra renders territories via WebView. Phaser.js canvas lives in thyra frame.

### amplifies aither

Aither provides signaling foundation. LiveKit uses WebRTC established via aither patterns.

### amplifies soma

Presence in territory extends body-schema. Agora is spatial embodiment.

### amplifies politeia

Circle membership determines territory access. Attainments gate audio/video.

### amplifies dynamis

Infrastructure entities (livekit-server) use dynamis reconciliation. Infrastructure through kosmos, not chora.

## Theoria

### T61: Gathering creates the space, not the other way around

We don't build territories hoping people will come. Territories arise because members want to gather. The space serves the assembly, not the reverse.

### T62: Infrastructure sovereignty enables authentic assembly

When communication runs on corporate servers, the corporation is always present. Circle-owned LiveKit servers enable spaces where only the members are present. Sovereignty is prerequisite for authentic gathering.

### T63: Presence is spatial embodiment

Position in territory is not metadata — it's how you exist in the space. Your facing, your proximity to others, your movement patterns — all are visible. Presence is embodiment.

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

## Future Extensions

### Proximity Audio

Spatial audio that attenuates with distance — closer means louder.

### Private Zones

Areas within territory where only certain attainments can enter.

### Recording/Playback

Territory sessions that can be recorded and replayed (with consent).

### AI Facilitation

Local LLM that can observe and assist gatherings (via NPU).

### Multi-Territory Portals

Walk through a door in one territory, appear in another.

---

*Composed in service of the kosmogonia.*
*The agora is where circles become communities. Infrastructure through kosmos, not chora.*
