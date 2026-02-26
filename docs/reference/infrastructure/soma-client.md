# soma-client

Rust HTTP client library for communicating with kosmos-mcp. Used by Thyra (Tauri) to interact with the kosmos server.

**Crate:** `crates/soma-client/`

## Architecture

```
Thyra UI (SolidJS)
  └─ invoke("tauri_command", args)
       └─ Tauri command (main.rs)
            └─ soma_client.method()
                 └─ HTTP request → kosmos-mcp REST API
```

soma-client is a thin HTTP client that translates Tauri commands into REST calls. It manages session tokens and provides WebSocket event streaming.

---

## Client Configuration

```rust
pub struct SomaClientConfig {
    pub base_url: String,           // e.g., "http://127.0.0.1:3000"
    pub session_token: Option<String>,  // Set later when user arises
}
```

Created during Tauri setup with `session_token: None`. Token is set after `arise()` or keyring unlock.

---

## Public API

### Lifecycle

| Method | Endpoint | Description |
|--------|----------|-------------|
| `SomaClient::new(config)` | — | Create client instance |
| `health()` | `GET /health` | Verify server is running |

### Session

| Method | Endpoint | Description |
|--------|----------|-------------|
| `get_launch_state()` | `GET /api/launch/state` | Get prosopon list with keyring status (`LaunchState { prosopa: Vec<ProsoponInfo> }`) |
| `arise(prosopon_id, oikos_id)` | `POST /api/session/arise` | Create session, get token |
| `switch_circle(oikos_id)` | `POST /api/session/switch-oikos` | Change dwelling oikos |
| `set_session_token(token)` | — | Set token for subsequent requests (in-memory) |
| `push_session_token(token)` | `POST /api/session/push-token` | Push token to kosmos-mcp session bridge |

### Entity CRUD

| Method | Endpoint | Description |
|--------|----------|-------------|
| `find_entity(id)` | `GET /api/entities/{id}` | Get entity by ID |
| `gather_entities(eidos, limit, sort, order)` | `GET /api/entities?eidos=&limit=&sort=&order=` | List entities by type, with optional sort |
| `create_entity(eidos, id, data)` | `POST /api/entities` | Create entity |
| `update_entity(id, data)` | `PUT /api/entities/{id}` | Update entity data |

### Bonds

| Method | Endpoint | Description |
|--------|----------|-------------|
| `trace_bonds(from, to, desmos)` | `GET /api/bonds?from=&to=&desmos=` | Query bonds |
| `create_bond(from, desmos, to, data)` | `POST /api/bonds` | Create bond |

### Praxis Invocation

| Method | Endpoint | Description |
|--------|----------|-------------|
| `invoke_praxis(praxis_id, args)` | `POST /api/praxis/{id}` | Invoke a praxis with parameters |

### Events

| Method | Endpoint | Description |
|--------|----------|-------------|
| `EventStream::connect(base_url, token)` | `WS /ws/events` | WebSocket event stream |
| `event_stream.subscribe()` | — | Get broadcast receiver for events |
| `event_stream.disconnect()` | — | Close WebSocket |

---

## Event Stream

WebSocket connection with automatic reconnection (exponential backoff, 1s to 30s max).

```rust
pub enum WsEvent {
    EntityCreated { id, eidos, version, data },
    EntityUpdated { id, eidos, version, data, previous },
    EntityDeleted { id, eidos },
    BondCreated { from_id, from_eidos, to_id, to_eidos, desmos, data },
    BondUpdated { from_id, from_eidos, to_id, to_eidos, desmos, data, previous_data },
    BondDeleted { from_id, from_eidos, to_id, to_eidos, desmos },
    Unknown,  // Forward compatibility
}

pub enum EventStreamState {
    Disconnected,
    Connecting,
    Connected,
    Reconnecting,
}
```

---

## Authentication

All `GET /api/*` and `POST /api/*` requests include the session token as `Authorization: Bearer <token>` when a token is set. Token is a base64url-encoded JSON `SessionToken` (see [session-identity](session-identity.md)).

---

## Usage from Tauri

```rust
// In Tauri setup
let config = soma_client::SomaClientConfig {
    base_url: base_url.clone(),
    session_token: None,
};
let client = Arc::new(soma_client::SomaClient::new(config)?);

// Stored in AppState
state.soma_client = Mutex::new(Some(client));

// In Tauri commands
let client = state.soma_client.lock().unwrap()
    .as_ref()
    .ok_or("soma client not initialized")?
    .clone();

let result = client.invoke_praxis(&praxis_id, args).await?;
```

---

## Error Types

```rust
pub enum SomaError {
    Http(reqwest::Error),
    Api { status: u16, message: String },
    Serialization(serde_json::Error),
    WebSocket(String),
}
```

---

## Dependencies

- `reqwest` — HTTP client
- `tokio-tungstenite` — WebSocket
- `serde` / `serde_json` — Serialization
- `tokio` — Async runtime with broadcast channels
