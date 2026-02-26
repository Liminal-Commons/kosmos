# Distributed Architecture Design

*Decoupling Thyra from Kosmos backend — enabling oikos-scoped instances, mobile/browser clients, and Commons infrastructure.*

**Operations:** See [docs/OPERATIONS.md](docs/OPERATIONS.md) for bootstrap sequence and operational patterns

---

## Executive Summary

**Goal:** Transform Kosmos from a single-machine, tightly-coupled system into a distributed architecture where:
- Multiple clients (Thyra, browser, mobile) connect to oikos-scoped instances
- Commons can participate in federation via HTTP
- The constitutional principles (visibility = reachability, sovereignty via cryptography) are preserved

**Key Design Decisions:**
1. **kosmos-server** = kosmos-mcp evolved with HTTP REST API alongside MCP
2. **One instance per oikos** — SQLite single-writer constraint honored
3. **Federation extended to HTTP** — Enables Commons participation
4. **soma-client library** — Shared abstraction for all clients
5. **Substrate bootstraps kosmos** — External process management (systemd, Thyra, launchd) starts kosmos-server

---

## 1. Component Definitions

### 1.1 kosmos-server

**Definition:** The unified server process that owns one oikos's database and serves both MCP protocol (for AI agents) and HTTP REST API (for UI clients).

| Aspect | Description |
|--------|-------------|
| **IS** | Evolution of kosmos-mcp; single-process database owner; praxis execution context |
| **IS NOT** | Multi-tenant; cross-oikos router; stateless gateway |
| **Owns** | SQLite database, FederationReconciler, ReflexRegistry, ReconcilerLoop |
| **Serves** | MCP (stdio/HTTP), HTTP REST, WebSocket events, Federation HTTP |

**API Surface:**

```
# MCP Protocol
JSON-RPC over stdio           → for Claude Code direct
JSON-RPC over HTTP/SSE        → for Claude Code via bridge

# HTTP REST API
GET    /api/entities/{id}
GET    /api/entities?eidos=X&limit=N
POST   /api/entities
PUT    /api/entities/{id}
DELETE /api/entities/{id}

GET    /api/bonds?from=X&desmos=Y
POST   /api/bonds
DELETE /api/bonds?from=X&desmos=Y&to=Z

POST   /api/praxis/{praxis_id}
GET    /api/dwelling                    → Session context

# Session Management
POST   /api/session/arise               → Create session (direct)
POST   /api/session/depart              → End session
POST   /api/session/switch-oikos       → Change dwelling
GET    /api/launch/state                → Onboarding check

# Challenge-Response Auth
POST   /api/challenge-entry             → Request nonce with public key
POST   /api/verify-entry                → Verify signed nonce, get session

# WebSocket
WS     /ws/events                       → Real-time entity/bond changes

# Federation HTTP
POST   /federation/sync                 → Receive phoreta
GET    /federation/changes?since=V      → Fetch changes since version
```

### 1.2 soma-client

**Definition:** Client library/abstraction that connects to kosmos-server(s). Embedded in Thyra, browser app, and mobile app.

| Aspect | Description |
|--------|-------------|
| **IS** | HTTP client library; session manager; event subscriber; offline queue |
| **IS NOT** | Separate process; praxis executor; database owner |
| **Handles** | HTTP communication, WebSocket events, session tokens, offline caching |

**TypeScript Interface (implemented in `packages/soma-client-ts/`):**

```typescript
interface SomaClient {
  // Initialization
  init(): Promise<void>;

  // Authentication
  authenticateWithChallenge(): Promise<AriseResponse>;  // Challenge-response
  arise(personaId: string, oikosId?: string): Promise<AriseResponse>;
  depart(): Promise<void>;
  switchOikos(circleId: string): Promise<AriseResponse>;
  dwelling(): Promise<DwellingInfo>;

  // Entity operations
  findEntity(id: string): Promise<Entity | null>;
  gatherEntities(eidos?: string, limit?: number): Promise<Entity[]>;
  createEntity(eidos: string, id: string, data: object): Promise<Entity>;
  updateEntity(id: string, data: object): Promise<Entity>;
  deleteEntity(id: string): Promise<void>;

  // Bond operations
  traceBonds(from?: string, to?: string, desmos?: string): Promise<Bond[]>;
  createBond(from: string, desmos: string, to: string, data?: object): Promise<Bond>;
  deleteBond(from: string, desmos: string, to: string): Promise<void>;

  // Praxis
  invokePraxis(praxisId: string, params?: object): Promise<unknown>;

  // Events
  subscribeToEvents(callback: (event: WsEvent) => void): () => void;
  onConnectionStateChange(callback: (state: ConnectionState) => void): () => void;

  // Offline
  flushOfflineQueue(): Promise<{ success: number; failed: number }>;

  // Properties
  readonly connectionState: ConnectionState;
  readonly sessionToken: string | null;
  readonly queuedMutationsCount: number;
}
```

**Substrate Implementations:**

| Substrate | Session Storage | Signing | Offline Cache |
|-----------|----------------|---------|---------------|
| Thyra (Rust) | OS Keychain | Ed25519 via ring | SQLite |
| Browser (TS) | IndexedDB | noble-ed25519 | IndexedDB |
| Mobile | Keychain/Keystore | Native crypto | SQLite |

### 1.3 Running Kosmos (Node + Deployment Model)

**Definition:** A kosmos-server process runs on a `node` and is represented by `dynamis/deployment` + `soma/kosmos-instance`.

```
node (physical substrate)
  └── hosts-service ──► service-instance (kosmos-server)
                              │
                              └── represented by ──► kosmos-instance (observational)
                              └── managed by ──► deployment (dynamis reconciler)
```

**Key insight:** The substrate (systemd, launchd, Thyra, Docker) starts kosmos-server **outside kosmos**. Creating a `kosmos-instance` entity does not cause a process to start — it describes a running instance.

| Oikos Kind | Bootstrapped By | Database Location | Node Kind |
|-------------|-----------------|-------------------|-----------|
| Self | Thyra | `~/.kosmos/{prosopon-id}/kosmos.db` | personal |
| Peer | Thyra/systemd | `~/.kosmos/{oikos-id}/kosmos.db` | personal |
| Commons | systemd/Docker | `/data/{oikos-id}/kosmos.db` | commons |

**Ontology entities used:**
- `soma/node` — Physical/virtual machine hosting the process
- `soma/service-instance` — Running kosmos-server with endpoint
- `soma/kosmos-instance` — Observational entity for health/federation
- `dynamis/deployment` — Desired state reconciliation (optional)

---

## 2. Flow Diagrams

### 2.1 Oikos Creation Flow

**Self Oikos (Onboarding):**

```
User                    Thyra                    kosmos-server
  │                       │                           │
  │ 1. Enter mnemonic     │                           │
  ├──────────────────────►│                           │
  │                       │                           │
  │                       │ 2. Derive keypair         │
  │                       │ 3. Create database        │
  │                       │ 4. Bootstrap genesis      │
  │                       │                           │
  │                       │ 5. Start kosmos-server    │
  │                       ├──────────────────────────►│
  │                       │                           │
  │                       │ 6. POST /api/entities     │
  │                       │    (oikos, prosopon)      │
  │                       ├──────────────────────────►│
  │                       │                           │
  │                       │ 7. POST /api/session/arise│
  │                       ├──────────────────────────►│
  │                       │                           │
  │ 8. Ready              │◄──────────────────────────┤
  │◄──────────────────────┤                           │
```

**Peer Oikos (Joining via Invitation):**

```
Inviter                 Entrant Thyra           kosmos-server (new)
  │                           │                         │
  │ 1. Share propylon-link    │                         │
  ├──────────────────────────►│                         │
  │                           │                         │
  │                           │ 2. Decode link          │
  │                           │ 3. Verify signature     │
  │                           │                         │
  │                           │ 4. Create database      │
  │                           │ 5. Bootstrap from link's│
  │                           │    phoreta              │
  │                           │                         │
  │                           │ 6. Start kosmos-server  │
  │                           ├────────────────────────►│
  │                           │                         │
  │                           │ 7. Create prosopon       │
  │                           │ 8. Create federation    │
  │                           │    bond to inviter      │
  │                           │                         │
  │◄─────────────────────────────────────────────────────┤
  │           9. Federation sync (phoreta)              │
```

### 2.2 Client Connection Flow

**Browser Connecting to Oikos:**

```
Browser                 kosmos-server              Propylon Relay
   │                         │                          │
   │ 1. Load page            │                          │
   │                         │                          │
   │ 2. Check IndexedDB      │                          │
   │    for session token    │                          │
   │                         │                          │
   │    [If no token]        │                          │
   │                         │                          │
   │ 3. GET propylon-link    │                          │
   │    (from URL/QR)        │                          │
   │                         │                          │
   │ 4. POST /challenge-entry│                          │
   ├────────────────────────►│                          │
   │                         │                          │
   │ 5. Receive nonce        │                          │
   │◄────────────────────────┤                          │
   │                         │                          │
   │ 6. Sign nonce locally   │                          │
   │    (Ed25519)            │                          │
   │                         │                          │
   │ 7. POST /verify-entry   │                          │
   ├────────────────────────►│                          │
   │                         │                          │
   │ 8. Session token +      │                          │
   │    dwelling context     │                          │
   │◄────────────────────────┤                          │
   │                         │                          │
   │ 9. Store in IndexedDB   │                          │
   │                         │                          │
   │ 10. WS /ws/events       │                          │
   │    (with token header)  │                          │
   ├────────────────────────►│                          │
   │                         │                          │
   │ Ready                   │                          │
```

### 2.3 Phoreta Sync Flow

**P2P Federation (WebRTC):**

```
Oikos A (kosmos-server)              Oikos B (kosmos-server)
         │                                      │
         │ 1. Entity created                    │
         │                                      │
         │ 2. FederationReconciler              │
         │    on_entity_changed()               │
         │                                      │
         │ 3. Create Phoreta                    │
         │    - Sign with Ed25519               │
         │    - Hash with BLAKE3               │
         │                                      │
         │ 4. Send via WebRTC data-channel      │
         ├─────────────────────────────────────►│
         │                                      │
         │                                      │ 5. Verify signature
         │                                      │
         │                                      │ 6. apply_phoreta()
         │                                      │    - Check version
         │                                      │    - Handle conflicts
         │                                      │
         │                                      │ 7. Update sync cursor
```

**HTTP Federation (Commons):**

```
Oikos A (kosmos-server)              Commons (kosmos-server)
         │                                      │
         │ 1. Entity created                    │
         │                                      │
         │ 2. FederationReconciler              │
         │    (HTTP transport mode)             │
         │                                      │
         │ 3. Create Phoreta                    │
         │                                      │
         │ 4. POST /federation/sync             │
         │    Body: { phoreta: [...] }          │
         │    Header: Authorization: <token>    │
         ├─────────────────────────────────────►│
         │                                      │
         │                                      │ 5. Validate session
         │                                      │ 6. Verify signatures
         │                                      │ 7. Apply phoreta
         │                                      │
         │ 8. 200 OK { applied: 5 }             │
         │◄─────────────────────────────────────┤
```

### 2.4 Multi-Oikos MCP Flow

**Claude Connecting to Multiple Oikoss:**

```
Claude Code            MCP Bridge           kosmos-server A    kosmos-server B
    │                      │                      │                  │
    │ 1. initialize        │                      │                  │
    ├─────────────────────►│                      │                  │
    │                      │                      │                  │
    │                      │ 2. Discover oikoi  │                  │
    │                      │    (via member-of)   │                  │
    │                      │                      │                  │
    │                      │ 3. Connect A         │                  │
    │                      ├─────────────────────►│                  │
    │                      │                      │                  │
    │                      │ 4. Connect B         │                  │
    │                      ├──────────────────────┼─────────────────►│
    │                      │                      │                  │
    │ 5. tools/list        │                      │                  │
    ├─────────────────────►│                      │                  │
    │                      │                      │                  │
    │                      │ 6. Aggregate tools   │                  │
    │                      │    from A and B      │                  │
    │                      │                      │                  │
    │ 7. Combined tools    │                      │                  │
    │◄─────────────────────┤                      │                  │
    │                      │                      │                  │
    │ 8. tools/call        │                      │                  │
    │    { oikos: "A" }   │                      │                  │
    ├─────────────────────►│                      │                  │
    │                      │                      │                  │
    │                      │ 9. Route to A        │                  │
    │                      ├─────────────────────►│                  │
    │                      │                      │                  │
    │ 10. Result           │                      │                  │
    │◄─────────────────────┤◄─────────────────────┤                  │
```

---

## 3. Data Ownership Model

### 3.1 Where Data Lives

| Data Type | Location | Owner | Sync |
|-----------|----------|-------|------|
| Genesis entities | Every database | Constitutional | Bootstrapped, not synced |
| Oikos-specific entities | Oikos's database | Oikos instance | Via federation |
| Session tokens | OS keyring (native) / IndexedDB (browser) | Client | Not synced |
| Sync cursors | Both sides of federation | Federation pair | Updated on sync |
| Offline queue | Client | Client | Flushed on connect |

### 3.2 Who Can Modify

**Within an oikos:**
- Any prosopon with appropriate attainment can create/modify entities
- Attainments determined by bonds (politeia governance)
- All modifications signed with prosopon's key

**Across oikoi (federation):**
- Phoreta carries signed entity changes
- Receiving oikos validates signature against `signed_by` prosopon
- Conflicts create `sync-conflict` entities, not silent overwrites

### 3.3 Host Disappearance

**Peer oikos host goes offline:**

```
Scenario: Victor hosts peer oikos, goes offline

Other peers ──────► Cannot access oikos data
                    ▼
Options:
  1. Wait for host to return
  2. If federation enabled with others:
     - Partial data available via federated peers
  3. If no federation:
     - Oikos inaccessible until host returns

Future enhancement:
  - Multi-host replication (not in initial scope)
  - Commons as backup host (federation with push)
```

**Commons goes offline:**

```
Scenario: Commons oikos unavailable

Members ──────► Cannot sync with Commons
               ▼
But:
  - Local oikos-instances continue working
  - P2P federation between members continues
  - Queue phoreta for Commons, flush on reconnect
```

### 3.4 Backup Strategy

**Self oikos:**
- User responsible for mnemonic backup (sovereignty)
- Optional: Federate with Commons for data backup
- Database can be manually backed up

**Peer oikos:**
- Host has primary database
- Members can maintain federated copies
- Mnemonic + federation = recovery path

**Commons:**
- Standard cloud backup (persistent volumes, snapshots)
- Federation with member oikoi for distributed redundancy

---

## 4. Ontology for Distributed Operation

*Types and bonds for distributed operation.*

### 4.1 Existing Ontology (Use As-Is)

**dynamis topos** — Process management:

| Entity | Purpose | Key Fields |
|--------|---------|------------|
| `deployment` | Desired state for running process | `mode`, `desired_state`, `actual_state` |
| `actuality-record` | Observed state from substrate | `status`, `message`, `observed_at` |
| `reconciler` | Alignment loop | `target_deployment`, `interval` |
| `substrate` | Deployment target category | `name`, `kind` |

**agora topos** — Real-time infrastructure:

| Entity | Purpose | Key Fields |
|--------|---------|------------|
| `livekit-server` | Real-time communication server | `host`, `ws_url`, `status` |
| `territory` | 2D spatial gathering space | `name`, `room_name`, `status` |
| `presence` | Parousia present in territory | `position`, `status` |
| `room` | LiveKit room for audio/video | `name`, `livekit_room_id` |

### 4.2 Soma Infrastructure Entities

**soma/node** — Physical or virtual machine:

```yaml
fields:
  name: string (required) - hostname or identifier
  kind: enum [personal, commons] - personal=individual chora, commons=shared
  platform: enum [nixos, linux, darwin, other]
  address: string - network address (Tailscale or public)
  public_endpoint: string - public URL if accessible
  steward_oikos_id: string - for commons nodes, which oikos governs
  status: enum [online, offline, degraded, unknown]
```

**soma/service-instance** — Running service on infrastructure:

```yaml
fields:
  name: string (required) - human-readable service name
  service_kind: string (required) - livekit, kosmos-server, transcription, relay
  endpoint: string (required) - connection URL
  config: object - service-specific configuration
  status: enum [provisioning, running, stopped, error]
  started_at: timestamp
  error_message: string
```

**soma/kosmos-instance** — Running kosmos interpreter (observational):

```yaml
fields:
  name: string (required)
  oikos_id: string (required) - oikos this instance serves
  server_url: string - HTTP endpoint if exposed
  mcp_available: boolean (default: true)
  http_available: boolean (default: false)
  status: enum [starting, running, stopping, stopped, error]
  version: string - kosmos version
  last_health_check: timestamp
```

### 4.3 Infrastructure Desmoi

| Desmos | From → To | Purpose |
|--------|-----------|---------|
| `hosts-service` | node → service-instance | Node hosts a service |
| `provides-to` | service-instance → oikos | Service provides capability to oikos |
| `runs-on` | kosmos-instance → node | Instance runs on node |
| `targets-node` | deployment → node | Deployment targets specific machine |
| `manifests-as` | deployment → service-instance | Deployment manifested as running service |
| `steward-of` | oikos → node | Oikos governs commons node |

### 4.4 Attainment for Infrastructure

**attainment/infrastructure** — Grants capability to manage infrastructure:
- `praxis/soma/register-node`
- `praxis/soma/sense-node`
- `praxis/soma/register-service`
- `praxis/soma/sense-service`
- `praxis/soma/sense-kosmos-instance`

---

## 5. Bootstrap Sequence

*Critical clarification: How kosmos-server gets started.*

### The Bootstrap Exception

Kosmos can describe but not cause itself. The substrate starts kosmos-server **outside kosmos**:

```
SUBSTRATE (chora)                    KOSMOS (world)
─────────────────                    ──────────────
systemd unit file                    entities
launchd plist                        bonds
Thyra application                    praxeis
Docker container                     reconciliation

    │                                    │
    │  starts (external)                 │
    └────────────────────────────────────┤
                                         ▼
                                    kosmos-server
                                    (process running
                                     in chora)
```

### Startup Sequence

```
1. SUBSTRATE STARTS KOSMOS-SERVER
   - systemd: ExecStart=/usr/bin/kosmos-server --oikos <id> --port 3000
   - Thyra: spawn kosmos-server subprocess
   - Docker: ENTRYPOINT ["/kosmos-server"]

2. KOSMOS-SERVER INITIALIZES
   - Load genesis (constitutional content)
   - Open oikos's SQLite database
   - Initialize HostContext
   - Start FederationReconciler
   - Start ReflexRegistry
   - Begin serving HTTP/MCP

3. ANIMI JOIN VIA PROPYLON
   - Client connects with session token
   - Propylon validates identity
   - Parousia arises in oikos
   - Dwelling context established

4. RECONCILIATION LOOPS ACTIVATE
   - dynamis reconciler manages OTHER deployments
   - Federation reconciler syncs with peers
   - Reflex registry responds to events
```

### kosmos-server Cannot Manage Itself

```
CAN manage:                          CANNOT manage:
- livekit-server deployment          - own process lifecycle
- transcription-daemon               - own database location
- other kosmos-server instances      - own genesis loading
  (on remote nodes)
```

The substrate is responsible for process lifecycle. The `kosmos-instance` entity is **observational** — it describes what's running, it doesn't cause processes to start.

---

## 6. Capability Flow

*How Commons services become usable through the capability chain.*

### The Chain: Topos → Attainment → Affordance

```
OIKOS (e.g., agora)
    │
    │ defines attainments and praxeis
    │ - attainment/agora-enter
    │ - attainment/agora-admin
    │ - praxis/agora/enter
    │ - praxis/agora/create-livekit-server
    │
    ▼
CIRCLE (e.g., vibe-cafe)
    │
    │ attaches topos/agora
    │ grants attainments via roles
    │ - role/member → attainment/agora-enter
    │ - role/steward → attainment/agora-admin
    │
    ▼
MEMBER (e.g., victor)
    │
    │ member-of oikos/vibe-cafe
    │ holds role/steward
    │ thereby gains attainment/agora-admin
    │
    ▼
CONTEXT (dwelling in vibe-cafe)
    │
    │ affordance check: can invoke agora/create-livekit-server?
    │ → yes, because attainment/agora-admin grants it
    │
    ▼
AFFORDANCE (surface operation)
```

### Example: Vibe Cafe Using Commons Infrastructure

1. **Liminal Commons** operates shared livekit-server on commons node
2. **Vibe Cafe oikos** attaches `topos/agora`
3. Commons provides `service-instance/livekit` via `provides-to` desmos
4. Vibe Cafe steward creates `livekit-server` entity pointing to commons endpoint
5. Members with `attainment/agora-enter` can join territories
6. Territories use the commons livekit-server via `served-by` desmos

### Why This Matters for Distributed Architecture

- **Oikos sovereignty**: Each oikos chooses which topoi to attach
- **Service sharing**: Commons provides services, oikoi consume via bonds
- **Capability-based access**: No global permission system, all flows from oikos membership
- **Federation respects bonds**: Cross-oikos sync follows the bond graph

---

## 7. Implementation Components

### 7.1 kosmos-server (Rust)

kosmos-mcp extended with HTTP REST API, WebSocket events, session validation, and federation transport.

| Module | Purpose | File |
|--------|---------|------|
| REST handlers | Entity, bond, praxis, dwelling, session endpoints | `crates/kosmos-mcp/src/rest.rs` |
| WebSocket broadcast | Real-time entity/bond change events | `crates/kosmos-mcp/src/websocket.rs` |
| Session auth | Bearer token validation, `ValidatedSession` extractor | `crates/kosmos-mcp/src/auth.rs` |
| HTTP server | Route wiring, CORS, static serving | `crates/kosmos-mcp/src/http.rs` |
| Federation | HTTP sync client, pull loop, push handler | `crates/kosmos-mcp/src/federation.rs` |
| Multi-oikos bridge | Connection pooling, tool aggregation, routing | `crates/kosmos-mcp/src/bridge.rs` |
| Oikos discovery | `KOSMOS_HOME` → graph traversal via `member-of` bonds | `crates/kosmos-mcp/src/discovery.rs` |
| Bridge config | Config entity lookup for operational params | `crates/kosmos-mcp/src/bridge_config.rs` |
| Connection manager | Per-oikos connections, error isolation | `crates/kosmos-mcp/src/connection.rs` |
| Reconnection | Background reconnect with exponential backoff | `crates/kosmos-mcp/src/reconnect.rs` |
| Config types | `MultiOikosConfig`, `OikosConfig` | `crates/kosmos-mcp/src/config.rs` |

### 7.2 soma-client (Rust)

HTTP client library with offline queue, embedded in Thyra.

| Module | Purpose | File |
|--------|---------|------|
| Client lib | HTTP communication, session tokens, offline caching | `crates/soma-client/` |
| Process management | kosmos-server subprocess lifecycle | `app/src-tauri/src/process.rs` |

### 7.3 soma-client-ts (TypeScript)

NPM-publishable TypeScript library (`@liminal/soma-client`) for browser clients.

| Module | Purpose | File |
|--------|---------|------|
| Client core | Entity, bond, praxis operations over HTTP | `packages/soma-client-ts/src/` |
| Session storage | IndexedDB-backed session persistence | `packages/soma-client-ts/src/session.ts` |
| Client-side signing | Ed25519 via `@noble/ed25519` | `packages/soma-client-ts/src/signing.ts` |
| Event stream | WebSocket with exponential backoff reconnection | `packages/soma-client-ts/src/events.ts` |
| Web client demo | Solid.js browser app | `packages/web-client/` |

### 7.4 Deployment Infrastructure

| Module | Purpose | File |
|--------|---------|------|
| NixOS module | Complete NixOS service with hardening | `deploy/nixos/kosmos-server.nix` |
| systemd unit | Template unit file with instance substitution (%i) | `deploy/systemd/kosmos-server@.service` |
| Docker | Multi-stage build for Commons deployment | `deploy/Dockerfile` |
| Docker Compose | Commons deployment configuration | `deploy/docker-compose.yml` |

**Deployment stoicheia (Tier 3):**
- `nixos-activate` / `nixos-deactivate` — NixOS module management
- `systemd-enable` / `systemd-disable` — Direct systemd unit management
- `systemctl-status` — Query systemd for unit state

**Actuality modes:**
- `mode/process-nixos` — NixOS module deployment (substrate: nixos)
- `mode/process-systemd` — Direct systemd unit deployment (substrate: systemd)

### 7.5 Homoiconic Configuration

All configuration flows through the graph. No external config files.

| Concern | Mechanism |
|---------|-----------|
| Oikos discovery | `KOSMOS_HOME` env → authenticate → trace `member-of` bonds from prosopon |
| MCP tool visibility | `attainment/mcp-essential` grants access to specific praxeis |
| Default dwelling | `home_oikos` field on prosopon entity |
| Bridge operational params | `config/mcp-bridge` entity with reconnect intervals, timeouts |
| Adding/removing oikoi | `soma/join-oikos` and `soma/leave-oikos` praxeis modify `member-of` bonds |

The bridge connects to a home oikos and discovers additional oikoi via graph traversal:

```bash
KOSMOS_HOME=http://localhost:3000 ./kosmos-mcp-bridge
```

---

## 8. Trade-offs and Decisions

| Decision | Trade-off | Rationale |
|----------|-----------|-----------|
| One instance per oikos | More processes, more complexity | Honors SQLite single-writer; clear ownership |
| HTTP for Commons federation | Adds latency vs WebRTC | WebRTC unsuitable for servers; HTTP is universal |
| Session token in IndexedDB | Less secure than OS keyring | Browser has no alternative; TLS + same-origin mitigates |
| Client-side signing in browser | Key exposure risk | Required for sovereignty; WebAuthn can add hardware protection later |
| MCP bridge for multi-oikos | Extra process hop | Keeps MCP protocol unchanged; routing is bridge's job |

---

## 9. Kosmogonia Alignment

| Principle | How Expressed |
|-----------|---------------|
| **Visibility = Reachability** | Bond graph determines visibility; federation respects bonds |
| **Sovereignty via cryptography** | All signing with prosopon keys; session tokens signed |
| **Graph-driven** | Oikos membership, federation bonds, configuration — all in graph |
| **Cache-driven** | Content-addressed phoreta; BLAKE3 hashing |
| **Composition-only** | Entities composed via typoi with provenance |
| **Homoiconic** | Configuration is entities + bonds, not external files |

---

## 10. Use Case Verification

*Three deployment scenarios covered by the architecture.*

### Self Oikos (Local)

Victor's self-oikos runs entirely on his laptop with local transcription.

```
ONTOLOGY PATH:
─────────────────────────────────────────────────────────────────
node/victors-laptop (kind: personal, platform: darwin)
    │
    ├── hosts-service ──► service-instance/transcription-daemon
    │                      (service_kind: transcription, endpoint: localhost:8080)
    │
    └── runs-on ◄── kosmos-instance/self-oikos
                     (oikos_id: oikos/victor-self, mcp_available: true)

BOOTSTRAP:
─────────────────────────────────────────────────────────────────
1. Thyra starts → bootstraps kosmos-server for self-oikos
2. Creates node entity describing Victor's laptop
3. Transcription runs locally via dynamis/deployment
4. kosmos-instance describes the running interpreter

CAPABILITY:
─────────────────────────────────────────────────────────────────
- Victor has full sovereignty (personal node)
- Local services, no Commons dependency
- MCP available for Claude Code
```

### Peer Oikos (P2P)

Victor and Alice collaborate via P2P federation.

```
ONTOLOGY PATH:
─────────────────────────────────────────────────────────────────
node/victors-laptop                    node/alices-laptop
(kind: personal)                       (kind: personal)
    │                                      │
    └── runs-on ◄── kosmos-instance/peer   └── runs-on ◄── kosmos-instance/peer
                     │                                      │
                     └── serves oikos/peer-group ◄─────────┘
                                (federated via aither/phoreta)

BOOTSTRAP:
─────────────────────────────────────────────────────────────────
1. Victor creates peer oikos, invites Alice via propylon-link
2. Alice accepts → Thyra bootstraps local kosmos-server
3. Both machines run kosmos-instance for same oikos
4. Federation syncs via WebRTC (aither)

CAPABILITY:
─────────────────────────────────────────────────────────────────
- Each node is sovereign
- Federation handles sync, not central server
- If Victor offline, Alice has local copy
```

### Commons Oikos (Hosted)

Vibe Cafe runs on Liminal Commons infrastructure.

```
ONTOLOGY PATH:
─────────────────────────────────────────────────────────────────
node/minis-forum (kind: commons, steward: oikos/liminal-commons)
    │
    ├── hosts-service ──► service-instance/livekit
    │                      │
    │                      └── provides-to ──► oikos/vibe-cafe
    │                                          (quota: {...}, config: {...})
    │
    ├── hosts-service ──► service-instance/kosmos-server-vibe-cafe
    │                      (service_kind: kosmos-server, endpoint: https://vibe.cafe/api)
    │
    └── runs-on ◄── kosmos-instance/vibe-cafe
                     (oikos_id: oikos/vibe-cafe, http_available: true)

BOOTSTRAP:
─────────────────────────────────────────────────────────────────
1. Liminal Commons operates minis-forum node
2. Creates service-instance for kosmos-server and livekit
3. Vibe Cafe oikos attaches topos/agora
4. provides-to desmos connects livekit to Vibe Cafe

CAPABILITY FLOW:
─────────────────────────────────────────────────────────────────
1. Vibe Cafe attaches topos/agora
2. Role/steward granted attainment/agora-admin
3. Victor (steward) can create territories
4. Territories use commons livekit-server via served-by desmos
5. Members with attainment/agora-enter can join
```

---

## 11. Open Questions

1. **Offline duration limit** — How long can client queue offline mutations?
2. **Conflict resolution UI** — How does user resolve sync-conflict entities?
3. **Multi-oikos auth** — Does one session token cover multiple oikoi?
4. **Rate limiting** — How do we prevent Commons abuse?
5. **Billing model** — How does Commons charge for infrastructure?

---

## Related Documents

| Document | Purpose |
|----------|---------|
| [docs/OPERATIONS.md](docs/OPERATIONS.md) | Operational companion |
| [docs/api/REST.md](docs/api/REST.md) | REST API documentation |
| [genesis/soma/manifest.yaml](genesis/soma/manifest.yaml) | Soma topos with infrastructure entities |
| [genesis/dynamis/DESIGN.md](genesis/dynamis/DESIGN.md) | Dynamis design with deployment relationships |

---

*Distributed architecture for oikos-scoped kosmos instances with federation, multi-client support, and Commons infrastructure.*
