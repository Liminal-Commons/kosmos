<!-- =============================================================================
<!-- GENERATED FILE - DO NOT EDIT DIRECTLY -->
<!-- =============================================================================
<!-- Emitted by: emit_cycle (demiurge/emit-genesis) -->
<!-- Source: genesis/agora/REFERENCE.md -->
<!-- -->
<!-- To modify: -->
<!--   1. Edit the source in genesis/ -->
<!--   2. Re-run emit-genesis -->
<!-- -->
<!-- See: genesis/EXTENDING.md -->
<!-- =============================================================================

# Agora Reference

the public assembly, where citizens gather

---

## Praxeis (Operations)

🔧 = Exposed as MCP tool

### actualize-server

Reconcile livekit-server entity with actual infrastructure

**Tier:** 3 | **ID:** `praxis/agora/actualize-server`

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `server_id` | string | ✓ |  |

### create-livekit-server

Create a LiveKit server infrastructure entity for the circle

**Tier:** 2 | **ID:** `praxis/agora/create-livekit-server`

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `host` | string | ✓ | e.g., livekit.mycircle.com |
| `ws_url` | string |  | WebSocket URL (defaults to wss://{host}) |
| `api_key_ref` | string | ✓ | Secret reference for API key |
| `api_secret_ref` | string | ✓ | Secret reference for API secret |

### create-territory

Create a new gathering territory for the circle

**Tier:** 2 | **ID:** `praxis/agora/create-territory`

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `name` | string | ✓ |  |
| `dimensions` | object |  |  |
| `tilemap_url` | string |  |  |
| `spawn_point` | object |  |  |
| `capacity` | number |  |  |

### delete-territory

Archive a territory (removes active presences)

**Tier:** 2 | **ID:** `praxis/agora/delete-territory`

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `territory_id` | string | ✓ |  |

### enter

Enter an agora territory, creating presence

**Tier:** 2 | **ID:** `praxis/agora/enter`

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `territory_id` | string | ✓ | Territory to enter |
| `spawn_at` | object |  | Optional { x, y } position override |

### get-presences

Get all current presences in a territory

**Tier:** 2 | **ID:** `praxis/agora/get-presences`

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `territory_id` | string | ✓ |  |

### get-room-token

Generate a LiveKit room token for participant

**Tier:** 3 | **ID:** `praxis/agora/get-room-token`

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `room_name` | string | ✓ |  |

### leave

Leave a territory, destroying presence

**Tier:** 2 | **ID:** `praxis/agora/leave`

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `presence_id` | string | ✓ |  |

### list-territories

List all territories hosted by the current circle

**Tier:** 2 | **ID:** `praxis/agora/list-territories`

*No parameters*

### move

Update position in territory

**Tier:** 2 | **ID:** `praxis/agora/move`

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `presence_id` | string | ✓ |  |
| `position` | object | ✓ | { x: number, y: number } |
| `facing` | string |  |  |

### toggle-audio

Toggle audio streaming for a presence

**Tier:** 2 | **ID:** `praxis/agora/toggle-audio`

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `presence_id` | string | ✓ |  |
| `enabled` | boolean | ✓ |  |

### toggle-video

Toggle video streaming for a presence

**Tier:** 2 | **ID:** `praxis/agora/toggle-video`

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `presence_id` | string | ✓ |  |
| `enabled` | boolean | ✓ |  |

### update-presence-status

Update presence status (active, away, do-not-disturb)

**Tier:** 2 | **ID:** `praxis/agora/update-presence-status`

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `presence_id` | string | ✓ |  |
| `status` | string | ✓ |  |

---

*Generated from schema definitions. Do not edit directly.*
