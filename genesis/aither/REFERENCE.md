<!-- =============================================================================
<!-- GENERATED FILE - DO NOT EDIT DIRECTLY -->
<!-- =============================================================================
<!-- Emitted by: emit_cycle (demiurge/emit-genesis) -->
<!-- Source: genesis/aither/REFERENCE.md -->
<!-- -->
<!-- To modify: -->
<!--   1. Edit the source in genesis/ -->
<!--   2. Re-run emit-genesis -->
<!-- -->
<!-- See: genesis/EXTENDING.md -->
<!-- =============================================================================

# Aither Reference

the upper air, the pure element. Network transport.

---

## Eide (Entity Types)

### data-channel

WebRTC peer-to-peer data channel for entity synchronization.

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `channel_id` | string | ✓ | Unique channel identifier |
| `connected_at` | timestamp |  |  |
| `created_at` | timestamp | ✓ |  |
| `disconnected_at` | timestamp |  |  |
| `intent` | string | ✓ | Desired state: connected, disconnected |
| `last_message_at` | timestamp |  |  |
| `remote_chora` | string |  | ID of the remote chora |
| `sdp_answer` | string |  | SDP answer (if we're answerer) |
| `sdp_offer` | string |  | SDP offer (if we're offerer) |
| `signaling_session_id` | string |  | The signaling session used to establish this channel |
| `status` | string | ✓ | Actual state: new, connecting, connected, disconnected, failed |

### outbound-message

Message queued for delivery when offline or channel unavailable.

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `attempts` | integer |  |  |
| `content` | string | ✓ | JSON-encoded message payload |
| `created_at` | timestamp | ✓ |  |
| `delivered_at` | timestamp |  |  |
| `expires_at` | timestamp |  | Message TTL (default 24h) |
| `last_attempt_at` | timestamp |  |  |
| `last_error` | string |  |  |
| `max_attempts` | integer |  |  |
| `message_type` | enum: phoreta, content-sync, presence-update, phasis | ✓ | Type of message for routing |
| `status` | enum: pending, sending, delivered, failed, expired | ✓ |  |
| `target_peer` | string | ✓ | Peer ID or room ID to deliver to |

### presence-record

Ephemeral presence in a room or oikos.

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `oikos_id` | string |  | Oikos where present |
| `connected_at` | timestamp |  |  |
| `expire_after_ms` | integer |  | Expire presence after this many ms without heartbeat |
| `heartbeat_interval_ms` | integer |  | Heartbeat interval in milliseconds |
| `last_heartbeat` | timestamp | ✓ |  |
| `prosopon_id` | string | ✓ | Prosopon whose presence this represents |
| `room_id` | string |  | Signaling room where present |
| `status` | enum: online, away, busy, offline | ✓ |  |

### signaling-session

WebSocket connection to propylon-relay for WebRTC signaling.

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `connected_at` | timestamp |  |  |
| `disconnected_at` | timestamp |  |  |
| `intent` | string | ✓ | Desired state: connected, disconnected |
| `relay_url` | string | ✓ | WebSocket URL of propylon-relay |
| `role` | string | ✓ | Role in the room: offerer, answerer |
| `room_id` | string | ✓ | The room to join on the relay |
| `session_handle` | string |  | Internal session ID when connected |
| `status` | string | ✓ | Actual state: connecting, connected, disconnected, failed |

### sync-message

Envelope for P2P synchronization messages.

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `action` | enum: create, update, delete, request, response | ✓ | Action being synced |
| `oikos_id` | string | ✓ | Oikos context for this sync |
| `entities` | array |  | Multiple entities (for catch-up-response) |
| `entity` | object |  | The entity being synced (for create/update) |
| `sender_id` | string | ✓ | Prosopon ID of the sender |
| `since` | timestamp |  | For catch-up-request: fetch entities since this time |
| `timestamp` | timestamp | ✓ | When the sync message was created |
| `type` | enum: phasis, entity, presence, catch-up-request, catch-up-response | ✓ | Type of sync message |

### syndesmos

A desired connection to another peer or room.

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `backoff_ms` | integer |  | Current backoff interval in milliseconds |
| `oikos_id` | string |  | Oikos context for this connection |
| `created_at` | timestamp | ✓ |  |
| `intent` | enum: connected, disconnected, suspended | ✓ | Desired connection state |
| `last_connected_at` | timestamp |  |  |
| `last_error` | string |  | Last error message if failed |
| `max_retries` | integer |  | Maximum reconnection attempts before giving up |
| `next_retry_at` | timestamp |  | Next scheduled reconnection attempt (exponential backoff) |
| `peer_id` | string |  | Remote peer identifier (if known) |
| `retry_count` | integer |  | Number of reconnection attempts |
| `room_id` | string | ✓ | Signaling room ID for the connection |
| `status` | enum: disconnected, connecting, connected, reconnecting, failed, suspended | ✓ | Actual connection state |

## Praxeis (Operations)

🔧 = Exposed as MCP tool

### accept-answer 🔧

Accept an SDP answer from remote peer (offerer side).

**Tier:** 3 | **ID:** `praxis/aither/accept-answer`

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `channel_id` | string | ✓ | The data channel |
| `sdp_answer` | string | ✓ | SDP answer from remote peer |

### answer-channel 🔧

Answer an incoming WebRTC offer (as answerer).

**Tier:** 3 | **ID:** `praxis/aither/answer-channel`

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `sdp_offer` | string | ✓ | SDP offer from remote peer |
| `channel_id` | string |  | Optional channel ID (generated if not provided) |
| `signaling_session_id` | string |  | Signaling session the offer came from |

### apply-catch-up

Apply catch-up response entities to local kosmos.

**Tier:** 2 | **ID:** `praxis/aither/apply-catch-up`

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `entities` | array | ✓ | Entities from catch-up response |
| `oikos_id` | string | ✓ | Oikos context |

### apply-phasis-sync

Apply an incoming phasis sync to local kosmos.

**Tier:** 2 | **ID:** `praxis/aither/apply-phasis-sync`

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `action` | string | ✓ | create, update, or delete |
| `entity` | object | ✓ | The phasis entity |
| `oikos_id` | string | ✓ | Oikos context |
| `sender_id` | string | ✓ | Original author |

### attempt-reconnect 🔧

Attempt to reconnect a failed or disconnected syndesmos.

**Tier:** 3 | **ID:** `praxis/aither/attempt-reconnect`

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `syndesmos_id` | string | ✓ | The syndesmos to reconnect |

### broadcast-sync 🔧

Broadcast a sync message to all connected peers.

**Tier:** 2 | **ID:** `praxis/aither/broadcast-sync`

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `message_type` | string | ✓ | Type: phasis, entity, presence |
| `action` | string | ✓ | Action: create, update, delete |
| `entity` | object |  | The entity being synced |
| `oikos_id` | string | ✓ | Oikos context |
| `sender_id` | string | ✓ | Sender's prosopon ID |

### close-channel 🔧

Close a data channel.

**Tier:** 3 | **ID:** `praxis/aither/close-channel`

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `channel_id` | string | ✓ | The channel to close |

### connect-signaling 🔧

Connect to a signaling relay and join a room.

**Tier:** 3 | **ID:** `praxis/aither/connect-signaling`

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `room_id` | string | ✓ | The room to join |
| `relay_url` | string | ✓ | WebSocket URL of propylon-relay |
| `role` | string | ✓ | Role: offerer or answerer |

### create-channel 🔧

Create a WebRTC data channel (as offerer).

**Tier:** 3 | **ID:** `praxis/aither/create-channel`

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `channel_id` | string |  | Optional channel ID (generated if not provided) |
| `signaling_session_id` | string |  | Signaling session to use for SDP exchange |

### disconnect-signaling 🔧

Disconnect from signaling relay.

**Tier:** 3 | **ID:** `praxis/aither/disconnect-signaling`

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `session_id` | string | ✓ | The signaling session to disconnect |

### disconnect-syndesmos 🔧

Disconnect a syndesmos gracefully.

**Tier:** 3 | **ID:** `praxis/aither/disconnect-syndesmos`

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `syndesmos_id` | string | ✓ | The syndesmos to disconnect |

### ensure-connection 🔧

Ensure a connection exists to a peer/room.

**Tier:** 3 | **ID:** `praxis/aither/ensure-connection`

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `room_id` | string | ✓ | The signaling room to connect through |
| `peer_id` | string |  | Remote peer identifier if known |
| `oikos_id` | string |  | Oikos context for this connection |

### expire-stale-presence 🔧

Clean up stale presence records.

**Tier:** 2 | **ID:** `praxis/aither/expire-stale-presence`

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `oikos_id` | string |  | Limit to specific oikos |

### flush-queue 🔧

Flush queued messages for a syndesmos.

**Tier:** 2 | **ID:** `praxis/aither/flush-queue`

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `syndesmos_id` | string | ✓ | The syndesmos to flush queue for |

### heartbeat 🔧

Send heartbeat to update presence timestamp.

**Tier:** 1 | **ID:** `praxis/aither/heartbeat`

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `presence_id` | string | ✓ | The presence record to update |

### list-channels 🔧

List data channels, optionally filtered by status.

**Tier:** 1 | **ID:** `praxis/aither/list-channels`

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `status` | string |  | Filter by status |
| `limit` | number |  | Maximum results (default: 50) |

### list-connections 🔧

List syndesmos connections, optionally filtered by status.

**Tier:** 1 | **ID:** `praxis/aither/list-connections`

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `status` | string |  | Filter by status |
| `oikos_id` | string |  | Filter by oikos |
| `limit` | number |  | Maximum results (default: 50) |

### list-presence 🔧

List presence records for a oikos or room.

**Tier:** 1 | **ID:** `praxis/aither/list-presence`

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `oikos_id` | string |  | Filter by oikos |
| `room_id` | string |  | Filter by room |
| `status` | string |  | Filter by status (online, away, busy, offline) |
| `exclude_offline` | boolean |  | Exclude offline users (default true) |

### poll-signaling 🔧

Poll for pending messages from the signaling relay.

**Tier:** 2 | **ID:** `praxis/aither/poll-signaling`

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `session_id` | string | ✓ | The signaling session to poll |

### queue-message 🔧

Queue a message for delivery when offline.

**Tier:** 2 | **ID:** `praxis/aither/queue-message`

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `syndesmos_id` | string | ✓ | The syndesmos to queue for |
| `message_type` | string | ✓ | Type of message (phoreta, content-sync, etc) |
| `content` | string | ✓ | JSON-encoded message content |
| `ttl_hours` | number |  | Hours until message expires (default 24) |

### receive-messages 🔧

Receive pending messages from a data channel.

**Tier:** 2 | **ID:** `praxis/aither/receive-messages`

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `channel_id` | string | ✓ | The channel to receive from |

### receive-sync 🔧

Handle an incoming sync message from a peer.

**Tier:** 2 | **ID:** `praxis/aither/receive-sync`

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `peer_id` | string | ✓ | ID of the sending peer |
| `message_json` | string | ✓ | JSON-encoded sync message |

### reconcile-channel 🔧

Reconcile a data channel — align intent with actuality.

**Tier:** 3 | **ID:** `praxis/aither/reconcile-channel`

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `channel_id` | string | ✓ | The channel to reconcile |

### request-catch-up 🔧

Request catch-up sync from peers after reconnection (C8.5).

**Tier:** 2 | **ID:** `praxis/aither/request-catch-up`

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `oikos_id` | string | ✓ | Oikos to catch up |
| `since` | string |  | Fetch entities since this timestamp (default: 1 hour ago) |
| `sender_id` | string | ✓ | Requester's prosopon ID |

### respond-catch-up

Respond to a catch-up request with entities since timestamp.

**Tier:** 2 | **ID:** `praxis/aither/respond-catch-up`

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `peer_id` | string | ✓ | Requesting peer |
| `oikos_id` | string | ✓ | Oikos to gather from |
| `since` | string | ✓ | Timestamp to gather since |

### send-answer 🔧

Send an SDP answer through the signaling relay.

**Tier:** 2 | **ID:** `praxis/aither/send-answer`

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `session_id` | string | ✓ | The signaling session |
| `sdp` | string | ✓ | The SDP answer |

### send-message 🔧

Send a message through a data channel.

**Tier:** 2 | **ID:** `praxis/aither/send-message`

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `channel_id` | string | ✓ | The channel to send through |
| `message` | string | ✓ | The message to send |

### send-offer 🔧

Send an SDP offer through the signaling relay.

**Tier:** 2 | **ID:** `praxis/aither/send-offer`

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `session_id` | string | ✓ | The signaling session |
| `sdp` | string | ✓ | The SDP offer |

### sense-channel 🔧

Sense the actual state of a data channel.

**Tier:** 1 | **ID:** `praxis/aither/sense-channel`

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `channel_id` | string | ✓ | The channel to sense |

### sense-signaling 🔧

Sense the actual state of a signaling session.

**Tier:** 1 | **ID:** `praxis/aither/sense-signaling`

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `session_id` | string | ✓ | The signaling session to sense |

### update-presence 🔧

Update or create presence record in an oikos/room.

**Tier:** 2 | **ID:** `praxis/aither/update-presence`

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `prosopon_id` | string | ✓ | The prosopon whose presence to update |
| `oikos_id` | string |  | Oikos to update presence in |
| `room_id` | string |  | Room to update presence in |
| `status` | string |  | Presence status (online, away, busy, offline) |

## Desmoi (Bond Types)

| Desmos | From → To | Description |
|--------|-----------|-------------|
| `connected-via` | syndesmos → data-channel | Syndesmos is connected via this data channel. |
| `presence-of` | presence-record → prosopon | This presence record represents the presence of this prosopon. |
| `present-in-oikos` | presence-record → oikos | Prosopon presence in an oikos or room. |
| `queued-for` | outbound-message → syndesmos | Message queued for delivery through this syndesmos. |
| `targets-peer` | syndesmos → prosopon | This syndesmos is trying to connect to this remote prosopon. |

---

*Generated from schema definitions. Do not edit directly.*
