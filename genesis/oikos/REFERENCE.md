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
| `animus_id` | string | ✓ |  |
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

Open a new session. Requires dwelling context (animus in circle).

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
| `attests-to` | publish-attestation → oikos-prod | Publish attestation attests to a production oikos. |
| `authored-by` | any → persona | Persona authored this segment/note |
| `baked-from` | oikos-prod → oikos-dev | Production oikos was baked from a development oikos. |
| `crystallizes` | insight → theoria | Insight crystallizes into theoria |
| `distributes` | circle → oikos-prod | Circle distributes an oikos (commons or premium). |
| `oikos-derives-from` | oikos-dev → oikos-dev | Oikos-dev derives from another oikos-dev (fork/adaptation). Tracks generative-commons lineage. |
| `published-by` | oikos-prod → persona | Production oikos was published by a persona. |
| `surfaced-in` | insight → circle | Insight surfaced in circle |
| `surfaces` | note → insight | Note surfaces into insight |
| `uses-oikos` | circle → oikos-prod | Circle has installed/activated an oikos-prod. Tracks which oikoi are active for a dwelling. |
| `within` | any → any | Containment within session/conversation |

---

*Generated from schema definitions. Do not edit directly.*
