# Aither Design

αἰθήρ (aither) — the upper air, the pure element

## Ontological Purpose

Aither addresses **the gap between here and there** — the transport of data between chorai without knowledge of what that data means.

Without aither:
- Peers cannot discover each other
- Data has no path to travel
- Connection failures leave no trace
- Presence is invisible

With aither:
- **Signaling**: Peers discover and negotiate connections
- **Channels**: Data flows peer-to-peer
- **Syndesmos**: Connection state reconciles intent with actuality
- **Presence**: Who is here, who is there, who has departed

The central concept is the **syndesmos** (σύνδεσμος — bond, connection). A syndesmos declares desired connection state; the network is what actually is. Reconciliation aligns them.

## Oikos Context

### Self Oikos

A solitary dweller uses aither to:
- Federate their own devices (laptop, phone)
- Queue messages when offline
- Track their own presence across substrates
- Maintain self-sync connections

Self-federation enables one prosopon, many devices.

### Peer Oikos

Collaborators use aither to:
- Maintain persistent connections to each other
- See who is present (online, away, busy)
- Exchange phaseis in real-time
- Reconnect automatically after disruption

Peer connections enable the living graph.

### Commons Oikos

A commons uses aither to:
- Coordinate presence across many members
- Route sync messages between distributed peers
- Provide relay infrastructure (via propylon)
- Aggregate connection health metrics

Commons provide the ether through which oikoi breathe.

## Core Entities (Eide)

### signaling-session

WebSocket connection to propylon-relay for SDP exchange.

**Fields:**
- `room_id` — room to join on the relay
- `relay_url` — WebSocket URL of propylon-relay
- `role` — offerer or answerer
- `intent` — desired state (connected, disconnected)
- `status` — actual state (connecting, connected, disconnected, failed)
- `session_handle` — internal session ID when connected

**Lifecycle:**
- Arise: connect-signaling creates session
- Reconcile: Sense WebSocket state, reconnect if needed
- Depart: disconnect-signaling closes session

### data-channel

WebRTC peer-to-peer data channel for entity synchronization.

**Fields:**
- `channel_id` — unique identifier
- `remote_chora` — ID of the remote peer
- `intent`, `status` — desired vs actual state
- `sdp_offer`, `sdp_answer` — negotiation state
- `signaling_session_id` — bootstrap path

**Lifecycle:**
- Arise: create-channel (offerer) or answer-channel (answerer)
- Change: SDP negotiation, ICE candidate exchange
- Depart: close-channel terminates connection

### syndesmos

Persistent connection state with reconciliation — the core abstraction.

**Fields:**
- `room_id` — signaling room
- `peer_id` — remote peer (if known)
- `oikos_id` — oikos context
- `intent` — connected, disconnected, suspended
- `status` — disconnected, connecting, connected, reconnecting, failed, suspended
- `retry_count`, `backoff_ms`, `max_retries` — exponential backoff state
- `last_error` — for debugging failures

**Lifecycle:**
- Arise: ensure-connection creates syndesmos with intent=connected
- Reconcile: attempt-reconnect with exponential backoff
- Depart: disconnect-syndesmos sets intent=disconnected

### outbound-message

Queued message for offline delivery.

**Fields:**
- `target_peer` — destination peer or room
- `message_type` — phoreta, content-sync, presence-update, phasis
- `content` — JSON-encoded payload
- `status` — pending, sending, delivered, failed, expired
- `attempts`, `max_attempts` — delivery tracking
- `expires_at` — TTL (default 24h)

**Lifecycle:**
- Arise: queue-message creates when offline
- Change: flush-queue attempts delivery
- Depart: delivered, failed, or expired

### presence-record

Ephemeral presence in a room or oikos.

**Fields:**
- `prosopon_id` — whose presence
- `oikos_id`, `room_id` — where present
- `status` — online, away, busy, offline
- `last_heartbeat` — last activity timestamp
- `heartbeat_interval_ms`, `expire_after_ms` — timing

**Lifecycle:**
- Arise: update-presence on join
- Change: heartbeat bumps timestamp
- Depart: expire-stale-presence marks offline

### sync-message

Envelope for P2P synchronization messages.

**Fields:**
- `type` — phasis, entity, presence, catch-up-request, catch-up-response
- `action` — create, update, delete, request, response
- `entity`, `entities` — payload(s)
- `oikos_id` — context
- `sender_id`, `timestamp` — provenance

## Bonds (Desmoi)

### bootstrapped-by

Data channel bootstrapped via signaling session.

- **From:** data-channel
- **To:** signaling-session
- **Cardinality:** many-to-one
- **Traversal:** Trace how a channel was established

### connected-via

Syndesmos uses this data channel.

- **From:** syndesmos
- **To:** data-channel
- **Cardinality:** many-to-one
- **Traversal:** Find which channel carries a connection

### queued-for

Outbound message queued for this syndesmos.

- **From:** outbound-message
- **To:** syndesmos
- **Cardinality:** many-to-one
- **Traversal:** Find pending messages for a connection

### targets-peer

Syndesmos targets this prosopon.

- **From:** syndesmos
- **To:** prosopon
- **Cardinality:** many-to-one
- **Traversal:** Find connections to a peer

### present-in-oikos

Presence record in an oikos.

- **From:** presence-record
- **To:** oikos
- **Cardinality:** many-to-one
- **Traversal:** List who is present in an oikos

### presence-of

Presence record belongs to prosopon.

- **From:** presence-record
- **To:** prosopon
- **Cardinality:** many-to-one
- **Traversal:** Find a prosopon's presence across oikoi

## Operations (Praxeis)

### Signaling Operations

- **connect-signaling**: Join relay room, begin peer discovery
- **disconnect-signaling**: Leave relay room
- **sense-signaling**: Query WebSocket state
- **poll-signaling**: Get pending offers/answers/ICE candidates
- **send-offer** / **send-answer**: SDP exchange

### Channel Operations

- **create-channel**: Create as offerer, generate SDP offer
- **accept-answer**: Offerer accepts SDP answer
- **answer-channel**: Answerer creates channel, generates SDP answer
- **close-channel**: Terminate data channel
- **sense-channel**: Query WebRTC state
- **reconcile-channel**: Align intent with actuality
- **list-channels**: Query all channels

### Syndesmos Operations (Reconciler Pattern)

- **ensure-connection**: Create syndesmos with intent=connected
- **attempt-reconnect**: Reconnect with exponential backoff
- **disconnect-syndesmos**: Graceful disconnect
- **list-connections**: Query syndesmos entities

### Message Operations

- **send-message**: Send through channel
- **receive-messages**: Get pending messages
- **queue-message**: Queue for offline delivery
- **flush-queue**: Deliver queued messages on reconnect

### Presence Operations

- **update-presence**: Create/update presence record
- **heartbeat**: Bump heartbeat timestamp
- **expire-stale-presence**: Mark stale records as offline
- **list-presence**: Query presence records

### Sync Operations

- **broadcast-sync**: Send entity change to peers
- **receive-sync**: Process incoming sync message
- **request-catch-up**: Request missed entities after reconnect

## Attainments

### attainment/connect

Connection capability — establishing and managing network connections.

- **Grants:** connect-signaling, disconnect-signaling, send-offer, send-answer, create-channel, accept-answer, answer-channel, close-channel, reconcile-channel, ensure-connection, attempt-reconnect, disconnect-syndesmos
- **Scope:** soma (local substrate)
- **Rationale:** Connection management is substrate-local; the network interface belongs to the substrate

### attainment/message

Messaging capability — sending and receiving through channels.

- **Grants:** send-message, receive-messages, queue-message, flush-queue
- **Scope:** soma
- **Rationale:** Message flow requires an established connection on this substrate

### attainment/presence

Presence capability — tracking who is here.

- **Grants:** update-presence, heartbeat, expire-stale-presence, list-presence
- **Scope:** oikos
- **Rationale:** Presence is visible within oikos context

### attainment/sync

Synchronization capability — P2P entity replication.

- **Grants:** broadcast-sync, receive-sync, request-catch-up
- **Scope:** oikos
- **Rationale:** Sync operates on oikos data; requires membership

### attainment/sense

Sense capability — reading connection and signaling state.

- **Grants:** sense-signaling, poll-signaling, sense-channel, list-channels, list-connections
- **Scope:** soma
- **Rationale:** Sensing is read-only; useful for debugging

## Embodiment

### Completeness Status

| Level | Status |
|-------|--------|
| Defined | 6 eide, 6 desmoi, 28 praxeis |
| Loaded | Bootstrap loads all definitions |
| Projected | All praxeis visible as MCP tools |
| Embodied | Partial — syndesmos contributes to body-schema |
| Surfaced | Partial — connection status indicator |
| Afforded | Partial — presence list |

### Body-Schema Contribution

When sense-body gathers aither state:

```yaml
network:
  syndesmos_count: 3          # Active connections
  connected_peers: 2          # Successfully connected
  reconnecting: 1             # In backoff
  presence_online: 5          # Peers present
  queued_messages: 0          # Pending delivery
```

This reveals network health and connectivity.

### Reconciler

An aither reconciler would surface:

- **Connection failures** — "Connection to alice failed after 10 attempts"
- **Stale presence** — "3 presence records expired"
- **Queue backlog** — "5 messages queued for 2+ hours"
- **Intent mismatch** — "Syndesmos wants connected, actually disconnected"

## Compound Leverage

### amplifies propylon

Propylon provides signaling relay. Aither uses relay for peer discovery before P2P handoff.

### amplifies thyra

Phaseis flow through aither channels. Voice streams could use WebRTC media.

### amplifies politeia

Oikos membership determines who you connect to. Presence is oikos-scoped.

### amplifies hypostasis

Phoreta sync flows through aither channels. Device federation uses sync.

### amplifies nous

Theoria sync could propagate insights across the graph in real-time.

## Theoria

### T58: Connection state is intent reconciling with actuality

The syndesmos declares what we want (intent: connected). The network is what actually is (status: disconnected). Reconciliation aligns them. This is the dynamis pattern applied to network transport.

### T59: The network forgets, the graph remembers

WebRTC connections are ephemeral — they come and go. But syndesmos entities persist, tracking connection history, retry counts, last errors. The substrate forgets; the graph remembers.

### T60: Presence is ephemeral state, syndesmos is durable intent

Presence records expire after 90 seconds without heartbeat — they reflect actual liveness. Syndesmos entities persist — they declare ongoing intent to connect. Different purposes, different lifetimes.

## Future Extensions

### ICE Restart

Reconnection without full re-signaling when network path changes.

### TURN Fallback

Relay through TURN server for restrictive NAT scenarios.

### Multi-Peer Rooms

Beyond 1:1 connections to mesh or selective forwarding.

### Bandwidth Sensing

Adaptive quality based on connection quality metrics.

### Media Channels

WebRTC media tracks for audio/video streams (beyond data channels).

---

*Composed in service of the kosmogonia.*
*The ether carries what it does not understand. Intent reconciles with actuality. The graph remembers.*
