# Operations: Distributed Kosmos

*Companion to KOSMOGONIA — operational patterns for distributed deployment.*

---

## Overview

KOSMOGONIA establishes constitutional principles. This document explains how those principles manifest in distributed operation — multiple kosmos instances, federation, and Commons infrastructure.

**Key insight:** Kosmogonia is ontological, not operational. This document bridges the gap.

---

## 1. Bootstrap Sequence

### The Chora/Kosmos Boundary

```
┌─────────────────────────────────────────────────────────────┐
│                       CHORA (Substrate)                     │
│  systemd, launchd, Thyra, NixOS, container runtime          │
│                                                              │
│  Starts kosmos-server process (OUTSIDE kosmos)               │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                    KOSMOS-SERVER (Process)                   │
│  Loads genesis, interprets praxeis, serves one database     │
│                                                              │
│  Can manage OTHER processes via dynamis/deployment          │
│  Cannot manage ITSELF (bootstrap exception)                  │
└─────────────────────────────────────────────────────────────┘
```

**Critical distinction:**
- The substrate starts kosmos-server (causal)
- Kosmos can describe kosmos-server as entity (observational)
- Kosmos-server is NOT an agent that dwells — only animi dwell

### Startup Sequence

1. **Substrate invokes binary**
   - systemd: `ExecStart=/usr/bin/kosmos-server --db /data/oikos.db`
   - Thyra: spawns child process on app launch
   - Container: entrypoint runs kosmos-server

2. **kosmos-server initializes**
   - Opens SQLite database (one per oikos)
   - Loads genesis entities from compiled YAML
   - Loads oikos's attached topoi
   - Initializes MCP projection (if enabled)
   - Initializes HTTP server (if configured)

3. **Ready for connections**
   - MCP: Claude Code connects via stdio or HTTP
   - HTTP: Thyra/browser connects via REST API
   - WebSocket: Real-time events for UI updates

4. **Animi join**
   - Propylon authenticates prosopon
   - Parousia arises in oikos
   - Dwelling established — context is now position

---

## 2. One Instance Per Oikos

### The Principle

Each oikos has exactly one kosmos-server process with one SQLite database.

```
Oikos A ←──serves── kosmos-server-A ←──owns── oikos-a.db
Oikos B ←──serves── kosmos-server-B ←──owns── oikos-b.db
Oikos C ←──serves── kosmos-server-C ←──owns── oikos-c.db
```

### Why?

1. **SQLite single-writer constraint** — Only one process can write safely
2. **Clear ownership** — No ambiguity about which process owns which data
3. **Oikos sovereignty** — Each oikos controls its own infrastructure

### Multiple Oikoss on One Node

A node (physical machine) can host multiple kosmos-server processes:

```
Node (Victor's laptop)
    │
    ├── kosmos-server (self-oikos) :3001
    ├── kosmos-server (peer-oikos-alpha) :3002
    └── kosmos-server (peer-oikos-beta) :3003
```

Resource management is the node operator's responsibility.

### Dormancy Pattern (Future)

Oikoss not actively dwelt in could be dormant:

```
Active dwelling → kosmos-server running
No active animi → kosmos-server can stop
Entry attempt → substrate wakes kosmos-server
```

This reduces resource overhead for users in many oikoi.

---

## 3. Node and Service Model

### Ontological Stack

```
node (physical substrate)
    │
    └── hosts-service ──► service-instance (running software)
                              │
                              └── provides-to ──► oikos (social unit)
```

### Node Types

| Kind | Purpose | Example |
|------|---------|---------|
| **personal** | Individual's infrastructure | Victor's laptop, phone |
| **commons** | Shared infrastructure | NixOS server hosting Vibe Cafe |

### Service Instances

Running software that provides capability:

| service_kind | What It Does |
|--------------|--------------|
| `kosmos-server` | Interprets praxeis, serves database |
| `livekit` | Real-time audio/video |
| `transcription` | Speech-to-text daemon |
| `relay` | Propylon signaling relay |

### Relationship to dynamis/deployment

```
deployment (dynamis)     ─── manages lifecycle ───►  service-instance (soma)
  mode: process                                        service_kind: livekit
  desired_state: running                               status: running
  manifest_handle: PID                                 endpoint: wss://...
```

Deployment is the reconciler pattern (intent vs actuality).
Service-instance is the description (what it is, where to connect).

---

## 4. Federation

### The Model

Federation is peer-to-peer synchronization via signed phoreta bundles.

```
Oikos A (kosmos-server)              Oikos B (kosmos-server)
         │                                      │
         │ 1. Entity created                    │
         │                                      │
         │ 2. FederationReconciler              │
         │    creates Phoreta                   │
         │    - Signs with Ed25519              │
         │    - Hashes with BLAKE3             │
         │                                      │
         │ 3. Transport (WebRTC or HTTP)        │
         ├─────────────────────────────────────►│
         │                                      │
         │                                      │ 4. Verify signature
         │                                      │ 5. Apply changes
         │                                      │ 6. Update sync cursor
```

### Transport Modes

| Mode | Mechanism | Use Case |
|------|-----------|----------|
| **P2P (aither)** | WebRTC data channel | Peer oikoi, direct connection |
| **HTTP** | REST API | Commons participation, firewall traversal |

### Federation as Discovery

You don't need a central directory. Federated knowledge tells you where to connect:

1. Join oikos via propylon-link
2. Oikos entity includes connection info
3. Federation syncs oikos entities to your local database
4. Your Thyra queries local kosmos-server for oikos connection info
5. Thyra connects to remote kosmos-server

**The graph IS the directory.**

### Conflict Handling

When federation encounters conflicts:

1. Both versions preserved temporarily
2. `sync-conflict` entity created
3. Surfaces for human resolution
4. No silent data loss

---

## 5. Capability Flow

### The Chain

```
topos (defines)
    │
    └── eide, desmoi, praxeis, attainments
              │
              ▼
oikos (attaches topos)
    │
    └── distributes topos to members
              │
              ▼
prosopon (member of oikos)
    │
    └── gains attainments from oikos membership
              │
              ▼
parousia (embodied in oikos)
    │
    └── context reveals affordances
              │
              ▼
affordance (contextual action)
    │
    └── "Start Call" button appears
```

### Commons Services Example

How does a Vibe Cafe member use LiveKit?

1. **Vibe Cafe oikos** attaches `topos/agora`
2. **Agora provides** `livekit-server` eidos, `convene-experience` praxis
3. **Member joins** Vibe Cafe → gains `agora-enter`, `agora-speak` attainments
4. **Member enters** territory → Thyra senses affordances
5. **"Start Call" appears** → praxis `agora/convene-experience` is available
6. **Click invokes praxis** → LiveKit room created, token returned
7. **Thyra renders** LiveKit call UI

**The service (livekit-server) enables the attainment.**
**The attainment + context = affordance.**

---

## 6. Client Connection Model

### Client Types

| Client | Runtime | Session Storage | Signing |
|--------|---------|-----------------|---------|
| **Thyra** | Tauri (Rust) | OS Keychain | Ed25519 (ring) |
| **Browser** | Web | IndexedDB | noble-ed25519 |
| **MCP (Claude)** | Rust | Keychain via bridge | Ed25519 |
| **Mobile** | Native | Keychain/Keystore | Native crypto |

### Connection Flow

```
Client                     kosmos-server
   │                            │
   │ 1. Present propylon-link   │
   │    or session token        │
   ├───────────────────────────►│
   │                            │
   │ 2. Validate signature      │
   │    Check attainments       │
   │◄───────────────────────────┤
   │                            │
   │ 3. Session established     │
   │    WebSocket for events    │
   ├───────────────────────────►│
   │                            │
   │ 4. Invoke praxeis          │
   │    via HTTP or MCP         │
   │◄──────────────────────────►│
```

### Multi-Oikos Access

A prosopon may be member of multiple oikoi. Client options:

1. **Single connection** — Connect to one kosmos-server, switch manually
2. **Multiple connections** — Connect to several, context determines routing
3. **MCP bridge** — Aggregates tools from multiple kosmos-servers

---

## 7. Commons Infrastructure

### What Commons Provides

A Commons oikos operates shared infrastructure:

```
Commons Oikos (Vibe Cafe)
    │
    ├── operates ──► node/vibe-cafe-server (kind: commons)
    │                    │
    │                    ├── hosts-service ──► service-instance/livekit
    │                    │                         │
    │                    │                         └── provides-to ──► oikos/vibe-cafe
    │                    │
    │                    └── hosts-service ──► service-instance/kosmos-server
    │
    └── steward_oikos_id: oikos/liminal-commons (who governs the node)
```

### Access Patterns

| Who | How They Access |
|-----|-----------------|
| **Member** | Join oikos → gain attainments → use services |
| **Steward** | Manage infrastructure via `infrastructure` attainment |
| **Visitor** | Limited access via public affordances (if any) |

### Commons vs Self-Hosted

| Aspect | Commons | Self-Hosted |
|--------|---------|-------------|
| Who operates | Commons oikos | Individual |
| Who pays | Shared cost | Individual |
| Availability | High (managed) | Depends on your uptime |
| Sovereignty | Oikos governs | You govern |

Both are valid. Federation makes them interoperable.

---

## 8. Observational Entities

### The Pattern

Some entities are observational — they describe what exists, they don't cause it to exist.

**kosmos-instance** is observational:
- Creating it doesn't start a process
- It describes a running interpreter
- Useful for health sensing and federation discovery

**deployment** is causal:
- Creating it with `desired_state: running` causes manifestation
- The dynamis reconciler starts the process
- Manages lifecycle (start, stop, restart)

### When to Use Which

| Need | Entity | Why |
|------|--------|-----|
| Start a service | deployment | Reconciler manifests it |
| Describe running service | service-instance | Reference for connection |
| Describe physical machine | node | Reference for hosting |
| Describe running interpreter | kosmos-instance | Federation and health |

---

## 9. Failure Modes

### Node Goes Offline

```
Personal node offline:
  - Your oikoi inaccessible until you return
  - Federated peers have their copy
  - Queue phoreta for delivery on reconnect

Commons node offline:
  - Services unavailable
  - Members' local oikoi continue working
  - P2P federation between members continues
```

### Kosmos-Server Crashes

Substrate restarts it (systemd, Thyra, etc.). The database persists. State recovers.

### Network Partition

Federation queues phoreta. Sync resumes when connectivity returns. Conflicts surface if both sides mutated.

---

## 10. Security Boundaries

### Trust Model

| Boundary | Trust |
|----------|-------|
| Your node | Full trust (your machine) |
| Peer's node | Trust per oikos membership |
| Commons node | Trust per oikos membership + operator trust |
| Public network | No trust (everything signed + encrypted) |

### What's Signed

- Phoreta (entity bundles)
- Session tokens
- Propylon links
- Genesis phaseis

### What's Encrypted

- Phoreta content (between federated peers)
- WebRTC data channels
- HTTPS transport

**Visibility = Reachability** — cryptographic bonds determine access.

---

*Operations documented for distributed kosmos deployment.*
*Constitutional principles remain in KOSMOGONIA.*
