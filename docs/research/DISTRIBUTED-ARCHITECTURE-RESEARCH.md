# Distributed Architecture Research Summary

*Research spike deliverable — understanding the current state before designing.*

---

## Executive Summary

**Goal:** Understand what it takes to decouple Thyra from Kosmos, enabling oikos-scoped instances, mobile/browser clients, and Commons infrastructure.

**Key Findings (Initial Research):**

1. **Thyra-Kosmos coupling is HIGH (8.5/10)** — 54+ Tauri commands directly call kosmos internals. No API boundary exists.

2. **Session tokens use OS keyring** — Browsers cannot access this. Alternative storage required.

3. **Federation is P2P only** — WebRTC-based. Commons (cloud) would need HTTP transport not yet implemented.

4. **Single database per machine** — Oikos membership via bonds. Federation already handles cross-kosmos sync.

**Key Findings (Kosmogonia Alignment Research, 2026-02-01):**

5. **Much ontology already exists** — `dynamis/deployment` for processes, `agora/livekit-server` for infrastructure. No need to invent duplicates.

6. **Infrastructure ontology revived** — `node`, `service-instance`, `kosmos-instance` added to soma topos from v4 archive.

7. **Bootstrap boundary clarified** — Substrate (systemd, Thyra) starts kosmos-server **outside kosmos**. kosmos-instance is observational, not causal.

8. **Capability flow documented** — topos → oikos attachment → attainments → affordances. See [OPERATIONS.md](../OPERATIONS.md).

---

## 1. Thyra-Kosmos Coupling Analysis

### Current Architecture

```
┌─────────────────────────────────────────────────────────┐
│                     THYRA (Tauri App)                    │
│  ┌────────────────────────────────────────────────────┐ │
│  │ AppState                                           │ │
│  │   host: Arc<Mutex<Option<HostContext>>>            │ │
│  │   dwelling: Arc<Mutex<Option<DwellingContext>>>    │ │
│  │   reconciler: Arc<Mutex<Option<FederationRec>>>    │ │
│  └──────────────────────┬─────────────────────────────┘ │
│                         │                                │
│  ┌──────────────────────▼─────────────────────────────┐ │
│  │ 54+ Tauri Commands (direct kosmos calls)           │ │
│  │   init_kosmos() → HostContext::new()               │ │
│  │   arise() → arise_entity(), create_bond()          │ │
│  │   invoke_praxis() → execute_praxis()               │ │
│  │   find_entity() → host.find_entity()               │ │
│  │   ...                                              │ │
│  └──────────────────────┬─────────────────────────────┘ │
│                         │                                │
│  ┌──────────────────────▼─────────────────────────────┐ │
│  │ kosmos crate (embedded, not separate process)      │ │
│  │   HostContext, DwellingContext                     │ │
│  │   SQLite connection                                │ │
│  │   Praxis interpreter                               │ │
│  │   SessionBridge trait                              │ │
│  └────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────┘
```

### Key Coupling Points

| Component | How Coupled | Impact |
|-----------|-------------|--------|
| `HostContext::new()` | Called directly in `init_kosmos()` | Must extract to separate process |
| `TauriSessionBridge` | Implements trait in Thyra | Session management must cross process boundary |
| `execute_praxis()` | Called for every praxis invocation | All praxis calls become HTTP |
| `FederationReconciler` | Set as change listener on host | Sync must happen in Kosmos process |
| Direct entity methods | `arise_entity()`, `find_entity()`, etc. | 54+ commands become API endpoints |

### Decoupling Requirements

1. **Extract Kosmos to Separate Binary** — Create `kosmos-server` that runs HostContext, serves HTTP API
2. **Convert Commands to HTTP** — All 54+ Tauri commands become HTTP client calls
3. **Session Token Sharing** — Thyra creates token, sends to kosmos-server for validation
4. **Event Stream** — WebSocket/SSE for real-time updates (replaces Tauri events)
5. **Credential Delegation** — Signing operations must work across process boundary

### Estimated Effort: 3-4 weeks

---

## 2. Session Token Analysis

### Current Flow

```
┌──────────────────────────────────────────────────────────┐
│ Thyra (Desktop)                                          │
│                                                          │
│ 1. User enters mnemonic                                  │
│ 2. Derive master_seed                                    │
│ 3. Call praxis/propylon/create-session-token             │
│ 4. Sign with Ed25519                                     │
│ 5. Write to OS Keyring                                   │
│    Service: "com.liminalcommons.kosmos"                  │
│    Username: "session-token"                             │
└─────────────────────┬────────────────────────────────────┘
                      │
                      ▼
           ┌──────────────────────┐
           │ OS Keyring           │
           │ (Keychain/CredMgr)   │
           └──────────┬───────────┘
                      │
        ┌─────────────┼─────────────┐
        ▼             ▼             ▼
   ┌─────────┐  ┌─────────┐  ┌──────────┐
   │ MCP     │  │ CLI     │  │ Other    │
   │ Server  │  │         │  │ Processes│
   │         │  │         │  │          │
   │ try_read│  │ try_read│  │ try_read │
   └─────────┘  └─────────┘  └──────────┘
```

### Token Contents

```json
{
  "prosopon_id": "prosopon/victor",
  "oikoi": ["oikos/home", "oikos/work"],
  "attainments": ["attainment/invite", "attainment/sign-code"],
  "issued_at": "2026-01-31T12:00:00Z",
  "expires_at": "2026-02-01T12:00:00Z",
  "master_seed_b64": "<base64-encoded-64-byte-seed>"  // Optional
}
```

### Browser Adaptation Required

| Native | Browser |
|--------|---------|
| OS Keyring storage | IndexedDB / localStorage / HttpOnly cookie |
| `keyring` crate access | No access to OS credential store |
| Process-level session | Tab-level or domain-level session |
| `master_seed` available | Client-side keypair or server-side signing |

### Recommended Browser Approach

1. **Token Storage:** IndexedDB for persistence, with explicit logout to clear
2. **Signing:** Client-side Ed25519 library (tweetnacl-js or noble-ed25519)
3. **Authentication:** Propylon challenge-response flow works unchanged
4. **Session:** Short-lived access tokens with refresh mechanism

---

## 3. Federation and Phoreta Analysis

### Current State

| Component | Status | Notes |
|-----------|--------|-------|
| Phoreta struct | ✅ Complete | Ed25519 signed, BLAKE3 hashed bundles |
| P2P sync (WebRTC) | ✅ Complete | Real-time broadcast, catch-up sync |
| Presence tracking | ✅ Complete | 90s heartbeat, ephemeral records |
| Conflict detection | ✅ Complete | Version comparison, conflict entities |
| Message queue | ✅ Designed | `outbound-message` for offline delivery |
| HTTP transport | ❌ Not implemented | Needed for Commons |
| Auth integration | ❌ Not wired | Session tokens not validated in federation |
| Composite versioning | ❌ Not designed | Needed for multi-member Commons |

### P2P Sync Flow (Current)

```
Oikos A (Peer)                         Oikos B (Peer)
    │                                       │
    │ 1. Entity created                     │
    │                                       │
    │ 2. Reflex fires                       │
    │    (aither/broadcast-sync)            │
    │                                       │
    │ 3. Create Phoreta                     │
    │    - Sign with Ed25519                │
    │    - Hash with BLAKE3                 │
    │                                       │
    │ 4. Send via WebRTC data channel       │
    ├──────────────────────────────────────►│
    │                                       │
    │                                       │ 5. Verify signature
    │                                       │
    │                                       │ 6. Apply to local DB
    │                                       │
    │                                       │ 7. Handle conflicts
```

### Commons Gap Analysis

Current federation assumes **symmetric P2P peers**. Commons requires:

1. **HTTP Transport** — WebRTC unsuitable for cloud servers
2. **Asymmetric Roles** — Commons aggregates, members contribute
3. **Multi-Member Versioning** — Track sync position per member
4. **REST API** — `POST /federation/{oikos}/sync`, `GET /federation/{oikos}/entities`
5. **Authentication** — Validate session tokens on federation requests

---

## 4. Database Architecture Analysis

### Current State: Single Database Per Machine

```
~/.kosmos/kosmos.db
├── entities table
│   ├── id (TEXT)
│   ├── eidos (TEXT)
│   ├── version (INTEGER)
│   └── data (JSON)
│
├── bonds table
│   ├── from_id (TEXT)
│   ├── to_id (TEXT)
│   ├── desmos (TEXT)
│   └── data (JSON)
```

### Oikos Membership via Bonds

Entities don't have a `oikos_id` column. Membership expressed through bonds:

```
prosopon/victor ──[member-of]──► oikos/home
phasis/123 ──[exists-in]──► oikos/home
```

### Visibility Rules

```rust
fn visible_to(entity_id, prosopon_id) -> bool {
    // 1. Get oikoi entity belongs to
    let entity_oikoi = trace_bonds(entity_id, "exists-in");

    // 2. If no oikos, visible (genesis entities)
    if entity_oikoi.is_empty() {
        return true;
    }

    // 3. Get oikoi prosopon is member of
    let persona_oikoi = trace_bonds(prosopon_id, "member-of");

    // 4. Check intersection
    return entity_oikoi.intersects(persona_oikoi);
}
```

### Per-Oikos Database Implications

Moving to per-oikos databases would require:

1. **Constitutional Replication** — Genesis eide/desmoi in every database
2. **Cross-Database Bonds** — Federation protocol for inter-oikos queries
3. **Cursor Migration** — `last-saw` bonds move to prosopon's database
4. **Query Routing** — Determine which database to query

**Good news:** Federation already handles cross-kosmos sync. Per-oikos is an extension of the same pattern.

---

## 5. Constraints

### Constitutional (From KOSMOGONIA)

| Constraint | Implication |
|------------|-------------|
| **Visibility = Reachability** | Access control via bond graph, not separate permission layer |
| **Authenticity = Provenance** | Everything traces to signed genesis via composition chains |
| **Sovereignty via cryptography** | Keypairs are identity; no external authority |
| **Graph-driven** | Relationships are explicit bonds, traversable |
| **Cache-driven** | Content-addressed via BLAKE3 |

### Technical (From Implementation)

| Constraint | Implication |
|------------|-------------|
| **SQLite single-writer** | One process owns the database |
| **Bond graph traversal** | Queries assume single connection |
| **Tauri IPC** | Currently synchronous-feeling; HTTP adds latency |
| **WebRTC for P2P** | Not suitable for cloud servers |
| **OS keyring** | Browser cannot access |

### Practical (From Requirements)

| Constraint | Implication |
|------------|-------------|
| **Offline-capable** | Self-oikos must work without network |
| **Browser support** | No native code, no OS APIs |
| **Mobile support** | Intermittent connectivity |
| **Multi-oikos** | Claude needs context from multiple oikoi |
| **Commons infrastructure** | LiveKit, transcription need cloud hosting |

---

## 6. Prior Art Patterns

### Local-First Architecture (Ink & Switch)

- **Principle:** Data lives on user's device; sync is secondary
- **Pattern:** CRDTs for conflict-free merge
- **Applies to:** Per-oikos databases, offline support

### MCP Session Management

- **Pattern:** HTTP/SSE with session headers
- **Applies to:** kosmos-server serving multiple clients

### Federation Protocols (ActivityPub, Matrix)

- **Pattern:** Server-to-server HTTP with signed payloads
- **Applies to:** Commons participating in federation

### Token-Based Auth (JWT)

- **Pattern:** Signed tokens with claims, short-lived access + refresh
- **Applies to:** Browser session management

---

## 7. Existing Ontology for Distributed Operation

*Added 2026-02-01 based on kosmogonia alignment research.*

### Key Finding: Much Already Exists

Before inventing new entities, we discovered substantial existing ontology in genesis that covers distributed operation needs:

### dynamis Topos — Process Management

The `dynamis` topos already provides the core abstractions for running processes:

| Entity | Purpose |
|--------|---------|
| **deployment** | Desired state for a running process |
| **actuality-record** | Observed state from substrate |
| **reconciler** | Alignment loop between desired/actual |
| **substrate** | Deployment target category |

**deployment eidos** (key fields):
```yaml
mode: process | docker | kubernetes
desired_state: running | stopped | removed
actual_state: unknown | running | stopped | degraded | failed | removed
manifest_handle: string (PID or deployment ID)
```

The dynamis reconciler pattern already implements the sense-compare-act loop for process management.

### agora Topos — Spatial Infrastructure

The `agora` topos already provides infrastructure entities:

| Entity | Purpose |
|--------|---------|
| **territory** | 2D spatial gathering space |
| **presence** | Parousia present in territory |
| **room** | LiveKit room for audio/video |
| **livekit-server** | Real-time communication server |

**livekit-server eidos** (key fields):
```yaml
host: string (required)
ws_url: string
api_key_ref: string (secret reference)
status: provisioning | running | stopped | error
```

This means "running a LiveKit server" is already representable in the ontology.

### Implication for Design

Rather than inventing `oikos-instance` or `infrastructure-service`, we can:
- Use **deployment** for process lifecycle (starting/stopping kosmos-server)
- Use existing **livekit-server** for real-time infrastructure
- Add only what's genuinely missing (substrate hosting model)

---

## 8. Infrastructure Ontology (Soma Revival)

*Implemented in kosmos 2026-02-01 per CHORA-HANDOFF-KOSMOS-ONTOLOGY.md*

### Revived from V4 Archive + New Additions

The `soma` topos now includes infrastructure entities revived from the v4 archive:

### node Eidos

Physical or virtual machine in the infrastructure:

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

**Changes from v4:**
- `slots` → `fields`
- Removed `services` array (use `hosts-service` desmos instead)
- Added `status` field for health sensing

### service-instance Eidos

A running service on infrastructure:

```yaml
fields:
  name: string (required) - human-readable service name
  service_kind: string (required) - livekit, kosmos-server, transcription, relay
  endpoint: string (required) - connection URL
  config: object - service-specific configuration
  status: enum [provisioning, running, stopped, error]
  started_at: timestamp
  error_message: string - error details if status=error
```

**Changes from v4:**
- `slots` → `fields`
- Removed `node_id` field (use `hosts-service` desmos instead)

### kosmos-instance Eidos (New)

A running kosmos interpreter — **observational entity** for health sensing and federation discovery:

```yaml
fields:
  name: string (required) - instance identifier
  oikos_id: string (required) - oikos this instance serves
  server_url: string - HTTP endpoint if exposed
  mcp_available: boolean (default: true)
  http_available: boolean (default: false)
  status: enum [starting, running, stopping, stopped, error]
  version: string - kosmos version
  last_health_check: timestamp
```

**Critical distinction:** Creating a `kosmos-instance` entity does NOT cause a process to start. The substrate starts kosmos-server processes; this entity **describes** running instances for sensing and discovery.

### New Desmoi

| Desmos | From → To | Cardinality |
|--------|-----------|-------------|
| **hosts-service** | node → service-instance | one-to-many |
| **provides-to** | service-instance → oikos | many-to-many |
| **runs-on** | kosmos-instance → node | many-to-one |

### attainment/infrastructure

New attainment for managing infrastructure entities:
- `praxis/soma/register-node`
- `praxis/soma/sense-node`
- `praxis/soma/register-service`
- `praxis/soma/sense-service`
- `praxis/soma/sense-kosmos-instance`

---

## 9. Bootstrap Boundary (Chora/Kosmos)

*Critical clarification for distributed architecture.*

### The Bootstrap Exception

```
CHORA (Substrate)                    KOSMOS (World)
─────────────────                    ──────────────
systemd                              entities
launchd                              bonds
Thyra                                praxeis
Docker                               reconciliation

    │                                    │
    │  starts                            │
    └────────────────────────────────────┤
                                         ▼
                                    kosmos-server
                                    (process running
                                     in chora)
```

**Key insight:** Kosmos can describe but not cause itself. The substrate (systemd, launchd, Thyra, Docker) starts kosmos-server processes **outside kosmos**.

### What This Means

1. **kosmos-server is bootstrapped externally**
   - Thyra starts kosmos-server (or embeds it)
   - systemd/launchd start kosmos-server on servers
   - Docker orchestrates kosmos-server containers

2. **kosmos-instance is observational**
   - The entity describes a running interpreter
   - Creating the entity doesn't start the process
   - The reconciler CAN observe and report status

3. **kosmos-server manages OTHER deployments**
   - Once running, kosmos can reconcile livekit-server, transcription-daemon, etc.
   - It uses dynamis/deployment for these
   - It cannot manage itself (bootstrap exception)

### Substrate Bootstraps One Database

Each kosmos-server process:
- Loads genesis (constitutional content)
- Opens one oikos's database (SQLite)
- Serves that oikos's bond graph
- Can federate with other oikoi via phoreta

```
Substrate
    │
    └──► kosmos-server (process)
              │
              ├──► loads genesis
              ├──► opens oikos database
              ├──► serves bond graph
              └──► manages OTHER deployments via dynamis
```

---

## 10. Capability Flow (Topos → Affordance)

*How Commons services become usable through the capability chain.*

### The Flow

```
OIKOS (soma)
    │
    │ defines attainment/infrastructure
    │ with grants: [soma/register-node, soma/sense-node, ...]
    │
    ▼
CIRCLE (vibe-cafe)
    │
    │ attaches topos/soma
    │ grants attainment/infrastructure to steward role
    │
    ▼
MEMBER (victor)
    │
    │ member-of oikos/vibe-cafe
    │ holds role/steward
    │ thereby gains attainment/infrastructure
    │
    ▼
CONTEXT (dwelling in vibe-cafe)
    │
    │ affordance check: can invoke soma/register-node?
    │ → yes, because has attainment/infrastructure
    │
    ▼
AFFORDANCE (surface operation)
```

### Commons Example: Vibe Cafe

1. **Vibe Cafe oikos** attaches `topos/agora` (for spatial gathering)
2. Oikos steward has `attainment/agora-admin`
3. Steward can invoke `agora/create-livekit-server`
4. Creates `livekit-server` entity with desired state
5. dynamis reconciler manifests actual livekit-server on commons node
6. Members with `attainment/agora-enter` can join territories

### Why This Matters

- **Oikos sovereignty**: Oikos decides which topoi to attach
- **Role-based access**: Attainments granted through role membership
- **Context-aware**: Affordances surface based on dwelling context
- **No global permissions**: Everything flows from oikos membership

---

## 11. Open Questions for Design

*Many questions from initial research are now resolved. Remaining questions focus on implementation details.*

### Resolved Questions

| Question | Resolution |
|----------|------------|
| What is "kosmos-server"? | kosmos-mcp extended with HTTP transport |
| Oikos instance lifecycle? | Substrate bootstraps; kosmos-instance describes |
| Where do infrastructure entities live? | soma topos (now implemented) |
| What happens when host disappears? | Oikos = federation network, not single host |

### Remaining Questions

#### Component Definition

1. **What is "soma-client"?**
   - Is Thyra one soma-client?
   - Is browser another?
   - What's shared between them?

#### Oikos Lifecycle Details

2. **Who creates an oikos's database?**
   - Thyra creates self-oikos locally
   - Who creates peer oikos? The inviter?
   - Who creates Commons oikos? DevOps?

3. **How does a new oikos get bootstrapped?**
   - Genesis content replicated?
   - Topoi installed from registry?
   - Initial bonds created?

#### Multi-Oikos MCP

4. **Should Claude connect to one oikos or route between many?**
   - One: Simpler, explicit context switching
   - Many: Complex routing, but seamless

5. **If routing, what determines which oikos handles a request?**
   - Entity ID prefix?
   - Explicit oikos parameter?
   - Dwelling context?

#### Browser Specifics

6. **How does browser store session?**
   - IndexedDB (persistent)?
   - Memory only (lost on refresh)?
   - HttpOnly cookie (server-controlled)?

7. **How does browser sign?**
   - Client-side library?
   - Delegate to server?
   - WebAuthn/hardware key?

---

## 12. Recommended Design Direction

Based on research findings, the most viable path:

### Short Term: kosmos-mcp Becomes kosmos-server

- Already has HTTP/SSE transport (we just built it)
- Add REST API endpoints alongside MCP
- Session token validation via propylon praxis
- Single database per instance

### Medium Term: Thyra as HTTP Client

- Replace 54+ commands with HTTP calls
- WebSocket for real-time events
- Session token sent in headers
- Local caching for offline

### Long Term: Per-Oikos Instances

- Extend federation protocol for HTTP
- Commons runs kosmos-server in cloud
- Per-oikos databases with federation sync
- Mobile/browser connect via HTTP

### Key Insight

**Federation already solves the hard problem.** The architecture supports multiple kosmoi syncing via signed phoreta. The gap is HTTP transport, not the conceptual model.

---

## 13. Files Referenced

| Area | Key Files |
|------|-----------|
| **Chora Implementation** | |
| Thyra integration | `app/src-tauri/src/main.rs` (2100+ lines of Tauri commands) |
| Session tokens | `crates/kosmos-mcp/src/lib.rs` (SessionToken, McpSessionBridge) |
| Federation | `crates/kosmos/src/reconciler.rs` (FederationReconciler, Phoreta) |
| Database | `crates/kosmos/src/host.rs` (HostContext, visibility rules) |
| Operations guide | `docs/OPERATIONS.md` (bootstrap, federation, capability flow) |
| **Kosmos Ontology** | |
| Aither | `genesis/aither/praxeis/aither.yaml` (sync, presence, catch-up) |
| Propylon | `genesis/propylon/praxeis/propylon.yaml` (session management) |
| Politeia | `genesis/politeia/desmoi/politeia.yaml` (oikos bonds) |
| Dynamis | `genesis/dynamis/eide/dynamis.yaml` (deployment, reconciler) |
| Agora | `genesis/agora/eide/agora.yaml` (territory, presence, livekit-server) |
| Soma (infrastructure) | `genesis/soma/eide/soma.yaml` (node, service-instance, kosmos-instance) |
| Soma desmoi | `genesis/soma/desmoi/soma.yaml` (hosts-service, provides-to, runs-on) |
| **Reference** | |
| Kosmogonia | `genesis/KOSMOGONIA.md` (constitutional principles) |
| V4 archive | `archive/genesis-v4-DEPRECATED/soma/soma.core.yaml` (original infrastructure eide) |

---

## 14. Next Steps → Design Spike

With research complete, the design spike should:

1. ~~**Define kosmos-server precisely**~~ — ✅ kosmos-mcp extended with HTTP transport
2. **Define soma-client interface** — What Thyra/browser/mobile share
3. **Create flow diagrams** — Oikos creation, connection, sync, multi-oikos
4. ~~**Specify data ownership**~~ — ✅ One database per oikos, substrate bootstraps
5. ~~**Enumerate new eide/desmoi**~~ — ✅ Infrastructure ontology implemented in soma topos

### Remaining Design Work

1. **HTTP transport implementation** — Extend kosmos-mcp for Commons support
2. **soma-client interface** — Define shared API surface for all clients
3. **Oikos bootstrap flow** — Document how new oikoi get created
4. **Multi-oikos routing** — How Claude connects to multiple oikoi

### Related Documents

- [OPERATIONS.md](../OPERATIONS.md) — Operational companion to KOSMOGONIA
- [CHORA-HANDOFF-DISTRIBUTED-ARCHITECTURE.md](../../CHORA-HANDOFF-DISTRIBUTED-ARCHITECTURE.md) — Design document (needs revision)
- [CHORA-HANDOFF-KOSMOS-ONTOLOGY.md](../../CHORA-HANDOFF-KOSMOS-ONTOLOGY.md) — Kosmos handoff (completed)

---

*Research completed 2026-01-31. Updated 2026-02-01 with kosmogonia alignment findings and infrastructure ontology.*
