# kosmos-server REST API

HTTP REST API for kosmos-server, enabling UI clients and external systems to interact with the kosmos graph.

## Authentication

Most `/api/*` endpoints accept authentication via the `Authorization` header. Entity/bond CRUD and praxis endpoints use `OptionalSession` — they accept requests with or without a token (supporting pre-auth flows like onboarding and recovery).

```
Authorization: Bearer <token>
```

The token is a base64url-encoded JSON object:

```json
{
  "prosopon_id": "prosopon/victor",
  "oikoi": ["oikos/self", "oikos/vibe-cafe"],
  "attainments": ["attainment/basic"],
  "issued_at": "2026-01-01T00:00:00Z",
  "expires_at": "2026-02-01T00:00:00Z"
}
```

**How to obtain tokens:**
- **Thyra (desktop):** Token obtained on unlock, stored in OS keyring
- **Browser:** Use challenge-response auth (`/api/challenge-entry` → `/api/verify-entry`)
- **Direct:** Use `/api/session/arise` with a prosopon ID

### Error Responses

| Status | Description |
|--------|-------------|
| 401 | Missing, invalid, or expired token |
| 403 | Insufficient permissions (future) |
| 404 | Entity/praxis not found |
| 400 | Invalid request parameters |
| 500 | Internal server error |

Error response body:

```json
{
  "error": "unauthorized",
  "message": "Token has expired"
}
```

---

## Visibility

All entity and bond operations apply **visibility filtering** based on the session's dwelling context. Invisible entities are absent — the API returns 404 or omits them from lists, indistinguishable from nonexistence.

**The rule**: A prosopon sees an entity if and only if that entity `exists-in` an oikos that the prosopon is `member-of`. Entities with no `exists-in` bonds (genesis/constitutional) are universally visible.

| Endpoint | Visibility Behavior |
|----------|-------------------|
| `GET /api/entities/{id}` | Returns entity only if visible. 404 if invisible or nonexistent. |
| `GET /api/entities` | Filters results to visible set. |
| `PUT /api/entities/{id}` | Entity must be visible. 404 if not. |
| `POST /api/entities` | New entity receives `exists-in` bond to dwelling oikos. |
| `DELETE /api/entities/{id}` | Entity must be visible. 404 if invisible or nonexistent. |
| `GET /api/bonds` | Both endpoints must be visible. Invisible bonds excluded. |
| `POST /api/bonds` | Source entity (from_id) must be visible. 404 if not. |
| `DELETE /api/bonds` | Source entity (from_id) must be visible. 404 if not. |

Without a session token, requests bypass visibility filtering (supporting pre-auth flows). With a token, the prosopon's oikos membership determines what is returned.

See [visibility-semantics.md](../dwelling/visibility-semantics.md) for the formal model.

---

## Endpoints

### Health Check

```
GET /health
```

Returns server status. No authentication required.

**Response:**

```json
{
  "status": "healthy",
  "version": "0.1.0",
  "transport": "http",
  "capabilities": {
    "mcp": true,
    "rest": true,
    "websocket": true,
    "federation": false
  }
}
```

---

### Dwelling

```
GET /api/dwelling
```

Get current session/dwelling context.

**Response:**

```json
{
  "prosopon_id": "prosopon/victor",
  "oikoi": ["oikos/self"],
  "attainments": ["attainment/basic"]
}
```

---

### Entities

#### Get Entity

```
GET /api/entities/{id}
```

Get a single entity by ID. The ID must be URL-encoded (e.g., `oikos%2Fself` for `oikos/self`).

**Example:**

```bash
curl -H "Authorization: Bearer $TOKEN" \
  "http://localhost:3000/api/entities/oikos%2Fself"
```

**Response:**

```json
{
  "id": "oikos/self",
  "eidos": "oikos",
  "data": {
    "name": "Self Oikos",
    "kind": "self"
  },
  "version": 42
}
```

#### List Entities

```
GET /api/entities
GET /api/entities?eidos=phasis
GET /api/entities?eidos=phasis&limit=50
GET /api/entities?eidos=phasis&sort=expressed_at&order=desc&limit=50
```

List entities with optional filtering, sorting, and limiting.

| Parameter | Type | Description |
|-----------|------|-------------|
| `eidos` | string | Filter by entity type (e.g., `phasis`, `oikos`) |
| `limit` | integer | Maximum number of results (default: 100) |
| `sort` | string | Sort by data field name (e.g., `expressed_at`, `name`, `domain`) |
| `order` | string | Sort order: `asc` (default) or `desc` |

Sorting uses `json_extract(data, '$.field')` in SQLite. The `sort` field name must be alphanumeric/underscores only (validated server-side to prevent injection).

**Example:**

```bash
curl -H "Authorization: Bearer $TOKEN" \
  "http://localhost:3000/api/entities?eidos=phasis&sort=expressed_at&order=asc&limit=10"
```

**Response:**

```json
[
  {
    "id": "phasis/123",
    "eidos": "phasis",
    "data": { "content": "Hello world" },
    "version": 1
  },
  ...
]
```

#### Create Entity

```
POST /api/entities
```

Create a new entity.

**Request Body:**

```json
{
  "eidos": "phasis",
  "id": "phasis/my-id",
  "data": {
    "content": "Hello world"
  }
}
```

**Response:** `201 Created`

```json
{
  "id": "phasis/my-id",
  "eidos": "phasis",
  "data": { "content": "Hello world" },
  "version": 1
}
```

#### Update Entity

```
PUT /api/entities/{id}
```

Update an existing entity's data.

**Request Body:**

```json
{
  "data": {
    "content": "Updated content"
  }
}
```

**Response:**

```json
{
  "id": "phasis/my-id",
  "eidos": "phasis",
  "data": { "content": "Updated content" },
  "version": 2
}
```

#### Delete Entity

```
DELETE /api/entities/{id}
```

Delete an entity.

**Response:** `204 No Content`

---

### Bonds

#### List Bonds

```
GET /api/bonds
GET /api/bonds?from=phasis/123
GET /api/bonds?from=phasis/123&desmos=in-reply-to
GET /api/bonds?to=oikos/self
```

List bonds with optional filtering.

| Parameter | Type | Description |
|-----------|------|-------------|
| `from` | string | Filter by source entity ID |
| `to` | string | Filter by target entity ID |
| `desmos` | string | Filter by bond type |

**Example:**

```bash
curl -H "Authorization: Bearer $TOKEN" \
  "http://localhost:3000/api/bonds?from=phasis%2F123"
```

**Response:**

```json
[
  {
    "id": 1,
    "from_id": "phasis/123",
    "to_id": "phasis/456",
    "desmos": "in-reply-to",
    "data": null
  }
]
```

#### Create Bond

```
POST /api/bonds
```

Create a bond between entities.

**Request Body:**

```json
{
  "from_id": "phasis/123",
  "desmos": "in-reply-to",
  "to_id": "phasis/456",
  "data": null
}
```

**Response:** `201 Created`

```json
{
  "id": 2,
  "from_id": "phasis/123",
  "to_id": "phasis/456",
  "desmos": "in-reply-to",
  "data": null
}
```

#### Delete Bond

```
DELETE /api/bonds?from=phasis/123&desmos=in-reply-to&to=phasis/456
```

Delete a bond. All three parameters are required.

**Response:** `204 No Content`

---

### Praxis Invocation

```
POST /api/praxis/{praxis_id}
```

Invoke a praxis (operation) by ID. The server injects dwelling context (`$_prosopon`, `$_oikos`) from the session token — praxeis receive these as ambient bindings, not as caller-supplied parameters.

**Request Body:**

```json
{
  "params": {
    "content": "Hello from REST"
  }
}
```

**Example:**

```bash
curl -X POST \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"params": {"content": "Hello"}}' \
  "http://localhost:3000/api/praxis/praxis%2Fnous%2Fcreate-phasis"
```

**Response:**

```json
{
  "result": {
    "id": "phasis/abc123",
    "eidos": "phasis",
    "data": { "content": "Hello" },
    "version": 1
  }
}
```

---

### Session Management

#### Arise (Create Session)

```
POST /api/session/arise
```

Create a new session for a prosopon. Returns a session token.

**Request Body:**

```json
{
  "prosopon_id": "prosopon/victor",
  "oikos_id": "oikos/self"  // optional
}
```

**Response:** `201 Created`

```json
{
  "session_id": "session/abc123",
  "parousia_id": "parousia/def456",
  "prosopon_id": "prosopon/victor",
  "oikos_id": "oikos/victor-self",
  "token": "eyJwZXJzb25hX2lkIjoi...",
  "expires_at": "2026-02-02T12:00:00Z"
}
```

#### Depart (End Session)

```
POST /api/session/depart
```

End the current session. Requires authentication.

**Response:** `204 No Content`

#### Switch Oikos

```
POST /api/session/switch-oikos
```

Change the dwelling context to a different oikos.

**Request Body:**

```json
{
  "oikos_id": "oikos/vibe-cafe"
}
```

**Response:** Returns new session with updated token (same as arise).

#### Push Session Token

```
POST /api/session/push-token
```

Push a session token from Thyra to update the kosmos-mcp session bridge. This propagates credentials and attainments from the desktop keyring to the MCP server process.

**Request Body:**

```json
{
  "token": "eyJwZXJzb25hX2lkIjoi..."  // base64url-encoded SessionToken, or null to lock
}
```

When `token` is non-null, creates an `McpSessionBridge` with full credentials and attainments. When `null`, clears the bridge — credential-gated operations will fail.

**Response:** `200 OK`

```json
{
  "status": "bridge_updated"
}
```

See [session-identity](session-identity.md) for the full token flow.

---

#### Launch State

```
GET /api/launch/state
```

Get the list of prosopa with their keyring status. No authentication required. Used by Thyra's WelcomeScreen to present entry path options.

**Response:**

```json
{
  "prosopa": [
    {
      "id": "prosopon/victor",
      "name": "Victor",
      "kind": "human",
      "has_keyring": true,
      "home_oikos_id": "oikos/victor-self"
    },
    {
      "id": "prosopon/claude",
      "name": "Claude",
      "kind": "ai",
      "has_keyring": false,
      "home_oikos_id": null
    }
  ]
}
```

---

### Challenge-Response Authentication

For browser clients that need to authenticate without a pre-existing token.

#### Request Challenge

```
POST /api/challenge-entry
```

Request a nonce to sign with your Ed25519 keypair.

**Request Body:**

```json
{
  "public_key": "a1b2c3d4..."  // 64 hex chars (32 bytes)
}
```

**Response:**

```json
{
  "nonce": "e5f6a7b8...",  // 64 hex chars to sign
  "expires_at": "2026-02-01T12:05:00Z"  // 5 minute expiry
}
```

#### Verify Challenge

```
POST /api/verify-entry
```

Submit the signed nonce to complete authentication.

**Request Body:**

```json
{
  "nonce": "e5f6a7b8...",      // The nonce from challenge-entry
  "signature": "1234abcd...",   // 128 hex chars (64 bytes Ed25519 signature)
  "public_key": "a1b2c3d4..."   // Same public key as challenge-entry
}
```

**Response:** `201 Created` — Same as `/api/session/arise`

```json
{
  "session_id": "session/abc123",
  "parousia_id": "parousia/def456",
  "prosopon_id": "prosopon/a1b2c3d4...",  // Derived from public key
  "oikos_id": "oikos/a1b2c3d4...-self",
  "token": "eyJwZXJzb25hX2lkIjoi...",
  "expires_at": "2026-02-02T12:00:00Z"
}
```

**Browser Example (TypeScript):**

```typescript
import { createClient } from "@liminal/soma-client";

const client = createClient({ baseUrl: "http://localhost:3000" });
await client.init();

// Generates keypair, signs nonce, gets session token
const session = await client.authenticateWithChallenge();
console.log("Authenticated as:", session.prosopon_id);
```

---

## WebSocket Events

```
WS /ws/events
WS /ws/events?token=<base64url-token>
```

Connect to receive real-time entity and bond change events.

**Optional Authentication:**

Since browser WebSocket API has limited header support, pass the token as a query parameter.

**Event Types:**

```json
{"type": "connected", "message": "Connected to kosmos-server events"}
{"type": "entity_created", "id": "...", "eidos": "...", "version": 1, "data": {...}}
{"type": "entity_updated", "id": "...", "eidos": "...", "version": 2, "data": {...}, "previous": {...}}
{"type": "entity_deleted", "id": "...", "eidos": "..."}
{"type": "bond_created", "from_id": "...", "to_id": "...", "desmos": "...", "data": null}
{"type": "bond_deleted", "from_id": "...", "to_id": "...", "desmos": "..."}
{"type": "substrate_signal", "entity_id": "...", "signals": {"energy_db": -28.3, "voice_active": true, "transcribing": false}}
```

**Note on substrate signals:** The `substrate_signal` event carries ephemeral sensing data sent at ~10Hz for active substrates (e.g., voice energy levels, VAD state). These are distinct from entity mutations — they reflect continuous measurement, not state changes, and are never persisted to the graph.

**Example (websocat):**

```bash
websocat "ws://localhost:3000/ws/events?token=$TOKEN"
```

---

## Federation

HTTP-based federation for syncing with Commons and other oikoi.

### Sync Phoreta

```
POST /federation/sync
```

Receive and apply phoreta (signed entity bundles) from a remote oikos.

**Request Body:**

```json
{
  "phoreta": [
    {
      "entity_id": "phasis/abc123",
      "entity_eidos": "phasis",
      "entity_version": 5,
      "entity_data": { "content": "Hello" },
      "origin_oikos_id": "oikos/remote",
      "content_hash": "a1b2c3...",
      "signature": "d4e5f6...",
      "signed_by": "7890ab...",
      "timestamp": 1706745600
    }
  ]
}
```

**Response:**

```json
{
  "applied": 1,
  "conflicts": [],
  "errors": []
}
```

### Fetch Changes

```
GET /federation/changes?since=100
GET /federation/changes?since=100&eidos=phasis&limit=50
```

Get entities changed since a given version.

| Parameter | Type | Description |
|-----------|------|-------------|
| `since` | integer | Version number to start from (required) |
| `eidos` | string | Filter by entity type |
| `limit` | integer | Maximum number of results |

**Response:**

```json
{
  "changes": [
    {
      "entity_id": "phasis/abc123",
      "entity_eidos": "phasis",
      "entity_version": 6,
      "entity_data": { "content": "Updated" },
      "origin_oikos_id": "oikos/local",
      "content_hash": "b2c3d4...",
      "timestamp": 1706745700
    }
  ],
  "latest_version": 6
}

---

## MCP Protocol

```
POST /mcp    → JSON-RPC requests
GET  /sse    → SSE event stream
```

These endpoints are for Claude Code integration via MCP protocol. See the MCP specification for details.

---

## Example Workflow

```bash
# Start server
kosmos-mcp --transport http --port 3000

# Create a token (normally done by Thyra)
TOKEN=$(echo -n '{"prosopon_id":"prosopon/test","oikoi":["oikos/self"],"attainments":[],"issued_at":"2026-01-01T00:00:00Z","expires_at":"2099-12-31T23:59:59Z"}' | base64 | tr -d '=' | tr '+/' '-_')

# Check health
curl http://localhost:3000/health

# Get dwelling context
curl -H "Authorization: Bearer $TOKEN" http://localhost:3000/api/dwelling

# List oikoi
curl -H "Authorization: Bearer $TOKEN" "http://localhost:3000/api/entities?eidos=oikos"

# Create a phasis
curl -X POST \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"eidos":"phasis","id":"phasis/test-1","data":{"content":"Hello REST API"}}' \
  http://localhost:3000/api/entities

# Connect to WebSocket for real-time events
websocat "ws://localhost:3000/ws/events"
```
