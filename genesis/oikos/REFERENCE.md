<!-- =============================================================================
<!-- GENERATED FILE - DO NOT EDIT DIRECTLY -->
<!-- =============================================================================
<!-- Emitted by: emit_cycle (demiurge/emit-genesis) -->
<!-- Source: genesis/oikos/REFERENCE.md -->
<!-- -->
<!-- To modify: -->
<!--   1. Edit the source in genesis/ -->
<!--   2. Re-run emit-genesis -->
<!-- -->
<!-- See: genesis/EXTENDING.md -->
<!-- =============================================================================

# Oikos Reference

the intimate

---

## Eide (Entity Types)

### conversation

A dialogue within a session. Conversations have participants and unfold through segments.

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `closed_at` | timestamp |  |  |
| `opened_at` | timestamp | ✓ |  |
| `status` | enum | ✓ |  |
| `title` | string |  |  |

### insight

Emerging understanding. Not yet crystallized into theoria, but surfaced from notes.

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `confidence` | number |  |  |
| `content` | string | ✓ |  |
| `domain` | string | ✓ |  |
| `surfaced_at` | timestamp | ✓ |  |

### note

An attention marker. Notes mark something as worthy of attention.

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `content` | string | ✓ |  |
| `created_at` | timestamp | ✓ |  |
| `kind` | enum | ✓ |  |
| `reason` | string |  |  |

### segment

A unit within a conversation. A turn of dialogue, a moment of work.

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `author_kind` | enum | ✓ |  |
| `content` | string | ✓ |  |
| `created_at` | timestamp | ✓ |  |
| `kind` | enum | ✓ |  |
| `metadata` | object |  |  |

### session

Current presence instance

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `parousia_id` | string | ✓ |  |
| `started_at` | timestamp | ✓ |  |

## Praxeis (Operations)

🔧 = Exposed as MCP tool

### add-segment 🔧

Add a segment to a conversation.

**Tier:** 2 | **ID:** `praxis/oikos/add-segment`

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `conversation_id` | string | ✓ | The conversation to add segment to |
| `content` | string | ✓ | The segment content |
| `kind` | string |  | Segment kind: message, action, observation, reflection (default: message) |
| `author_kind` | string |  | Author kind: human, ai, system (default: human) |

### close-session 🔧

Close a session.

**Tier:** 2 | **ID:** `praxis/oikos/close-session`

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `session_id` | string | ✓ | The session to close |

### crystallize-insight 🔧

Crystallize an insight into theoria.

**Tier:** 2 | **ID:** `praxis/oikos/crystallize-insight`

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `insight_id` | string | ✓ | The insight to crystallize |

### list-notes 🔧

List notes, optionally filtered.

**Tier:** 2 | **ID:** `praxis/oikos/list-notes`

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `about` | string |  | Filter to notes about this entity |
| `kind` | string |  | Filter by note kind |

### open-conversation 🔧

Open a new conversation within a session.

**Tier:** 2 | **ID:** `praxis/oikos/open-conversation`

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `session_id` | string | ✓ | The session to open conversation in |
| `title` | string |  | Optional title for the conversation |

### open-session 🔧

Open a new session. Requires dwelling context (parousia in oikos).

**Tier:** 2 | **ID:** `praxis/oikos/open-session`

*No parameters*

### surface-insight 🔧

Surface an insight from notes or observations.

**Tier:** 2 | **ID:** `praxis/oikos/surface-insight`

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `content` | string | ✓ | The insight content |
| `domain` | string | ✓ | Domain this insight belongs to |
| `confidence` | number |  | Confidence level 0.0 to 1.0 |
| `from_notes` | array |  | Note IDs that contributed to this insight |

### take-note 🔧

Take a note about something.

**Tier:** 2 | **ID:** `praxis/oikos/take-note`

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `content` | string | ✓ | What is being noted |
| `reason` | string |  | Why it matters |
| `kind` | string |  | Note kind: observation, question, concern, insight, todo (default: observation) |
| `about` | string |  | Entity ID this note is about |

## Desmoi (Bond Types)

| Desmos | From → To | Description |
|--------|-----------|-------------|
| `about` | note → any | Note is about an entity |
| `attests-to` | publish-attestation → topos-prod | Publish attestation attests to a production topos. |
| `authored-by` | any → prosopon | Prosopon authored this segment/note |
| `baked-from` | topos-prod → topos-dev | Production topos was baked from a development topos. |
| `crystallizes` | insight → theoria | Insight crystallizes into theoria |
| `distributes` | oikos → topos-prod | Oikos distributes a topos (commons or premium). |
| `topos-derives-from` | topos-dev → topos-dev | Topos-dev derives from another topos-dev (fork/adaptation). Tracks generative-commons lineage. |
| `published-by` | topos-prod → prosopon | Production topos was published by a prosopon. |
| `surfaced-in` | insight → oikos | Insight surfaced in oikos |
| `surfaces` | note → insight | Note surfaces into insight |
| `uses-topos` | oikos → topos-prod | Oikos has installed/activated a topos-prod. Tracks which topoi are active for a dwelling. |
| `within` | any → any | Containment within session/conversation |

---

*Generated from schema definitions. Do not edit directly.*
