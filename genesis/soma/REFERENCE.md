<!-- =============================================================================
<!-- GENERATED FILE - DO NOT EDIT DIRECTLY -->
<!-- =============================================================================
<!-- Emitted by: emit_cycle (demiurge/emit-genesis) -->
<!-- Source: genesis/soma/REFERENCE.md -->
<!-- -->
<!-- To modify: -->
<!--   1. Edit the source in genesis/ -->
<!--   2. Re-run emit-genesis -->
<!-- -->
<!-- See: genesis/EXTENDING.md -->
<!-- =============================================================================

# Soma Reference

presence, sensing, and the interface with world.

---

## Eide (Entity Types)

### body-schema

The parousia's sense of its own shape and capacity

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `capabilities` | array | ✓ |  |
| `channels` | array | ✓ |  |
| `limits` | object |  |  |
| `updated_at` | timestamp | ✓ |  |

### body-signal

A unit of output through a channel (renamed from signal to avoid collision with stoicheion/signal)

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `content` | any | ✓ |  |
| `emitted_at` | timestamp | ✓ |  |
| `metadata` | object |  |  |
| `modality` | string | ✓ |  |

### channel

Interface for perception or action

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `kind` | enum | ✓ |  |
| `modality` | string | ✓ |  |
| `name` | string | ✓ |  |
| `opened_at` | timestamp | ✓ |  |
| `status` | enum | ✓ |  |

### percept

A unit of sensory input through a channel

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `content` | any | ✓ |  |
| `metadata` | object |  |  |
| `modality` | string | ✓ |  |
| `perceived_at` | timestamp | ✓ |  |

## Praxeis (Operations)

🔧 = Exposed as MCP tool

### arise-parousia 🔧

Bring a parousia into being. The parousia instantiates a prosopon.

**Tier:** 2 | **ID:** `praxis/soma/arise-parousia`

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `prosopon_id` | string | ✓ | The prosopon this parousia instantiates |
| `parousia_id` | string | ✓ | ID for the new parousia (e.g., parousia/uuid) |

### close-channel 🔧

Close a channel.

**Tier:** 2 | **ID:** `praxis/soma/close-channel`

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `channel_id` | string | ✓ | The channel to close |

### depart-parousia 🔧

Have a parousia depart (end dwelling).

**Tier:** 2 | **ID:** `praxis/soma/depart-parousia`

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `parousia_id` | string | ✓ | The parousia to depart |

### emit 🔧

Emit a signal through a channel.

**Tier:** 2 | **ID:** `praxis/soma/emit`

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `channel_id` | string | ✓ | The channel to emit through |
| `signal_id` | string | ✓ | ID for the new signal (e.g., signal/uuid) |
| `content` | any | ✓ | The content to emit |
| `metadata` | object |  | Optional metadata about the signal |

### open-channel 🔧

Open a channel for a parousia.

**Tier:** 2 | **ID:** `praxis/soma/open-channel`

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `parousia_id` | string | ✓ | The parousia to open a channel for |
| `channel_id` | string | ✓ | ID for the new channel (e.g., channel/uuid) |
| `name` | string | ✓ | Channel name |
| `modality` | string | ✓ | What type of data (text, voice, vision, file, etc.) |
| `kind` | string |  | Channel kind (perception, action, bidirectional) |

### perceive 🔧

Record a perception through a channel.

**Tier:** 2 | **ID:** `praxis/soma/perceive`

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `channel_id` | string | ✓ | The channel to perceive through |
| `percept_id` | string | ✓ | ID for the new percept (e.g., percept/uuid) |
| `content` | any | ✓ | The perceived content |
| `metadata` | object |  | Optional metadata about the perception |

### sense-body 🔧

Sense the current body schema (idioaisthesis).

**Tier:** 2 | **ID:** `praxis/soma/sense-body`

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `parousia_id` | string | ✓ | The parousia to sense |

## Desmoi (Bond Types)

| Desmos | From → To | Description |
|--------|-----------|-------------|
| `channel-of` | channel → parousia | Channel belongs to parousia |
| `emitted-through` | signal → channel | Signal emitted through channel |
| `received-through` | percept → channel | Percept received through channel |
| `schema-of` | body-schema → parousia | Body schema belongs to parousia |

---

*Generated from schema definitions. Do not edit directly.*
