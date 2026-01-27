# Aither: Network Transport

*αἰθήρ (aither): the upper air, the pure element — network transport layer*

---

## Purpose

Aither provides P2P connectivity via WebRTC. It is the transport layer that moves data between chorai without knowledge of what that data means. Circles, governance, and content semantics live elsewhere (politeia, syndesmos); aither just moves bytes.

**Key insight:** Connection state is intent that reconciles with actuality. The syndesmos entity declares what we want (connected); the network is what actually is. Reconciliation aligns them.

---

## Current State

V8 has **working signaling and data channels**:

```
Frontend (SolidJS)                  Relay (propylon-relay)
    │                                      │
    ├── join_signaling_room ──────────────►│
    │                                      │
    ◄──────────────── peer_joined ─────────┤
    │                                      │
    ├── create_offer ──────────────────────┤
    │      │                               │
    │      ├── sdp_offer ─────────────────►│ ────────► remote peer
    │      │                               │
    │      ◄── sdp_answer ◄────────────────│ ◄──────── remote peer
    │      │                               │
    │      └── ICE candidates ◄───────────►│ ◄───────► remote peer
    │                                      │
    └── P2P data channel established ──────┘
```

**What exists:**
- Signaling via propylon-relay (WebSocket)
- WebRTC peer connection management (Tauri commands)
- Data channel creation and messaging
- Connection status tracking in frontend

**What's now added (C11):**
- Syndesmos entities (persistent connection state)
- Exponential backoff reconnection
- Presence heartbeat (30s interval)
- Offline message queuing
- Connection status indicator in HUD

---

## Core Concepts

### Syndesmos: Connection State

Syndesmos (σύνδεσμος: connection, bond) entities represent desired connection state that reconciles with network actuality.

**Intent vs Status:**

| Field | Purpose | Values |
|-------|---------|--------|
| `intent` | What we want | connected, disconnected, suspended |
| `status` | What actually is | disconnected, connecting, connected, reconnecting, failed, suspended |

**Reconciliation loop:**
1. Sense actual WebSocket/WebRTC state
2. Compare intent vs actuality
3. Act: connect, reconnect, or disconnect

```
Intent: connected          Intent: connected          Intent: connected
Status: disconnected  →    Status: connecting    →    Status: connected
       ↑                          ↑                          ↓
       └── reconnect ◄────────────┴──── timeout ◄────────────┘
                              (exponential backoff)
```

### Exponential Backoff

When connection fails, retry with increasing delays:

```
Attempt 1: 1s delay
Attempt 2: 2s delay
Attempt 3: 4s delay
Attempt 4: 8s delay
...
Attempt N: min(2^N * 1000, 60000)ms delay

After max_retries (default 10): status → failed
```

On successful connect, reset: `retry_count → 0`, `backoff_ms → 1000`.

### Offline Message Queue

When network unavailable, messages queue as outbound-message entities:

```yaml
outbound-message:
  target_peer: "room-id-123"
  message_type: "expression"
  content: '{"type": "expression", ...}'
  status: pending
  expires_at: "2026-01-26T12:00:00Z"  # 24h TTL
```

On reconnect, `aither/flush-queue` delivers in order:
- `pending` → `sending` → `delivered` (success)
- `pending` → `sending` → `failed` (after max_attempts)
- `pending` → `expired` (if TTL exceeded)

### Presence

Presence-record entities track who is "in" a room or circle:

```yaml
presence-record:
  persona_id: "persona/alice"
  circle_id: "circle/friends"
  room_id: "room-123"
  status: online      # online, away, busy, offline
  last_heartbeat: "2026-01-25T10:30:00Z"
```

**Heartbeat cycle:**
- Frontend calls `aither/heartbeat` every 30s
- `last_heartbeat` timestamp updates
- Records expire after 90s without heartbeat
- `aither/expire-stale-presence` marks stale records as offline

---

## Entity Types

### signaling-session

WebSocket connection to propylon-relay for SDP exchange.

| Field | Type | Purpose |
|-------|------|---------|
| room_id | string | Room to join on relay |
| relay_url | string | WebSocket URL |
| role | string | offerer or answerer |
| intent | string | Desired state |
| status | string | Actual state |
| session_handle | string | Internal session ID |

### data-channel

WebRTC peer-to-peer data channel.

| Field | Type | Purpose |
|-------|------|---------|
| channel_id | string | Unique identifier |
| remote_chora | string | Remote peer ID |
| intent | string | Desired state |
| status | string | Actual state |
| sdp_offer | string | SDP offer (if offerer) |
| sdp_answer | string | SDP answer |

### syndesmos

Persistent connection state with reconciliation.

| Field | Type | Purpose |
|-------|------|---------|
| room_id | string | Signaling room |
| peer_id | string | Remote peer (if known) |
| circle_id | string | Circle context |
| intent | enum | connected, disconnected, suspended |
| status | enum | disconnected, connecting, connected, reconnecting, failed, suspended |
| retry_count | integer | Reconnection attempts |
| backoff_ms | integer | Current backoff interval |
| max_retries | integer | Max attempts before giving up |

### outbound-message

Queued message for offline delivery.

| Field | Type | Purpose |
|-------|------|---------|
| target_peer | string | Destination |
| message_type | enum | phoreta, content-sync, presence-update, expression |
| content | string | JSON payload |
| status | enum | pending, sending, delivered, failed, expired |
| attempts | integer | Delivery attempts |
| expires_at | timestamp | TTL |

### presence-record

Ephemeral presence in room/circle.

| Field | Type | Purpose |
|-------|------|---------|
| persona_id | string | Who is present |
| circle_id | string | Where (circle) |
| room_id | string | Where (room) |
| status | enum | online, away, busy, offline |
| last_heartbeat | timestamp | Last activity |
| heartbeat_interval_ms | integer | Expected interval (30000) |
| expire_after_ms | integer | Expiry threshold (90000) |

---

## Bond Types

| Desmos | From | To | Purpose |
|--------|------|-----|---------|
| queued-for | outbound-message | syndesmos | Message queued for this connection |
| present-in | presence-record | circle | Presence in this circle |
| connected-via | syndesmos | data-channel | Connection uses this channel |
| presence-of | presence-record | persona | Whose presence this is |
| targets-peer | syndesmos | persona | Who we're connecting to |
| bootstrapped-by | data-channel | signaling-session | Channel bootstrapped via this session |

---

## Praxeis Summary

### Signaling Operations

| Praxis | Tier | Purpose |
|--------|------|---------|
| `aither/connect-signaling` | 3 | Connect to relay, join room |
| `aither/disconnect-signaling` | 3 | Disconnect from relay |
| `aither/sense-signaling` | 1 | Query signaling state |
| `aither/poll-signaling` | 2 | Get pending offers/answers/ICE |
| `aither/send-offer` | 2 | Send SDP offer |
| `aither/send-answer` | 2 | Send SDP answer |

### Data Channel Operations

| Praxis | Tier | Purpose |
|--------|------|---------|
| `aither/create-channel` | 3 | Create channel as offerer |
| `aither/accept-answer` | 3 | Accept SDP answer (offerer) |
| `aither/answer-channel` | 3 | Answer offer (answerer) |
| `aither/close-channel` | 3 | Close channel |
| `aither/sense-channel` | 1 | Query channel state |
| `aither/reconcile-channel` | 3 | Align intent with actuality |
| `aither/send-message` | 2 | Send through channel |
| `aither/receive-messages` | 2 | Get pending messages |
| `aither/list-channels` | 1 | List all channels |

### Syndesmos Operations

| Praxis | Tier | Purpose |
|--------|------|---------|
| `aither/ensure-connection` | 3 | Create or update syndesmos |
| `aither/attempt-reconnect` | 3 | Reconnect with backoff |
| `aither/disconnect-syndesmos` | 3 | Graceful disconnect |
| `aither/list-connections` | 1 | List syndesmos entities |

### Offline Queue Operations

| Praxis | Tier | Purpose |
|--------|------|---------|
| `aither/queue-message` | 2 | Queue for later delivery |
| `aither/flush-queue` | 2 | Deliver queued messages |

### Presence Operations

| Praxis | Tier | Purpose |
|--------|------|---------|
| `aither/update-presence` | 2 | Create/update presence |
| `aither/heartbeat` | 1 | Bump heartbeat timestamp |
| `aither/expire-stale-presence` | 2 | Mark stale as offline |
| `aither/list-presence` | 1 | List presence records |

---

## Frontend Integration

The frontend tracks connection state via signals in [kosmos.ts](../../app/src/store/kosmos.ts):

```typescript
interface ConnectionState {
  status: ConnectionStatus;  // disconnected, connecting, connected, reconnecting, failed
  retryCount: number;
  maxRetries: number;
  backoffMs: number;
  lastError: string | null;
  syndesmosId: string | null;  // Kosmos entity tracking this connection
}
```

**Connection flow:**
1. `joinSignalingRoom(roomId, peerId)` → creates syndesmos via `aither/ensure-connection`
2. Signaling events update `connectionState` signal
3. On disconnect, `attemptReconnect()` with exponential backoff
4. `disconnectSignaling()` → calls `aither/disconnect-syndesmos`

**Presence flow:**
1. On join room → `startPresenceHeartbeat()` calls `aither/update-presence`
2. Every 30s → `aither/heartbeat` updates timestamp
3. On leave room → `stopPresenceHeartbeat()` marks offline

**UI indicator:**
- [ConnectionStatusIndicator](../../app/src/components/ConnectionStatus.tsx) shows status in HUD header
- Green dot = connected, yellow = connecting/reconnecting, red = failed, gray = disconnected

---

## Constitutional Alignment

Aither follows the three pillars:

| Pillar | How Aither Implements It |
|--------|--------------------------|
| **Schema-driven** | Entity types (syndesmos, presence-record) define structure; praxeis define behavior |
| **Graph-driven** | Bonds connect syndesmos → channel, presence → circle; relationships are navigable |
| **Cache-driven** | Connection state is entity state; actuality is sensed, not assumed |

**Key theoria:**
- **T17:** Intent/status pattern enables reconciliation. Declare what you want, sense what is, act to align.
- The separation of intent from status mirrors the kosmos/chora distinction: intent lives in kosmos (entities), actuality lives in chora (network).

---

## Dependencies

- **webrtc dynamis** — Low-level WebRTC operations (manifest, sense, signal)
- **propylon-relay** — Signaling server for SDP exchange
- **politeia** — Circle context for presence visibility
- **thyra** — Stream operations that may use aither channels

---

## Future Work

- **ICE restart** — Reconnection without full re-signaling
- **TURN fallback** — For restrictive NAT scenarios
- **Multi-peer rooms** — Beyond 1:1 connections
- **Bandwidth sensing** — Adaptive quality based on connection quality
- **Mesh networking** — Peer-to-peer relay for unreachable peers

---

*Aither is the pure transport — moving data through the network without knowing what it means.*
*Traces to: expression/genesis-root*
*Updated: 2026-01-25 — Syndesmos connection state and presence heartbeat*
