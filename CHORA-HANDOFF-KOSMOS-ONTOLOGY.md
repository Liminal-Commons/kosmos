# Kosmos Handoff: Infrastructure Ontology

**Purpose:** Add infrastructure eide to soma oikos for distributed architecture support.

**Context:** The distributed architecture design requires representing physical substrate (nodes), running services, and kosmos instances. These concepts existed in v4 archive but need revival with modern structure.

---

## Summary

Add to existing `soma` oikos:

| Entity | Purpose | Source |
|--------|---------|--------|
| **node** | Physical/virtual machine | Revive from v4 |
| **service-instance** | Running service on a node | Revive from v4 |
| **kosmos-instance** | Running kosmos interpreter | New (minimal) |

Add desmoi:

| Bond | From → To | Purpose |
|------|-----------|---------|
| **hosts-service** | node → service-instance | Node hosts service |
| **provides-to** | service-instance → circle | Service provides to circle |
| **runs-on** | kosmos-instance → node | Instance runs on node |

---

## 1. Eide Definitions

### node

Physical or virtual machine in the infrastructure. Revived from v4 with adaptations.

```yaml
- eidos: eidos
  id: eidos/node
  data:
    name: node
    description: |
      A physical or virtual machine in the infrastructure.
      Personal nodes run individual chorai; commons nodes host shared infrastructure.
    fields:
      name:
        type: string
        required: true
        description: "Node hostname or identifier"
      kind:
        type: enum
        values: [personal, commons]
        required: true
        default: personal
        description: "personal = individual chora; commons = shared infrastructure"
      platform:
        type: enum
        values: [nixos, linux, darwin, other]
        required: true
        description: "Operating system"
      address:
        type: string
        required: false
        description: "Network address (Tailscale or public)"
      public_endpoint:
        type: string
        required: false
        description: "Public URL if accessible outside private network"
      steward_circle_id:
        type: string
        required: false
        description: "For commons nodes — which circle governs this infrastructure"
      status:
        type: enum
        values: [online, offline, degraded, unknown]
        required: true
        default: unknown
        description: "Current node status"
```

**Changes from v4:**
- Renamed `slots` → `fields`
- Removed `services` array (use `hosts-service` desmos instead)
- Added `status` field for health sensing

---

### service-instance

A running service on infrastructure.

```yaml
- eidos: eidos
  id: eidos/service-instance
  data:
    name: service-instance
    description: |
      A running service on infrastructure (commons or personal).
      Examples: livekit-server, kosmos-server, transcription-daemon.
    fields:
      name:
        type: string
        required: true
        description: "Human-readable service name"
      service_kind:
        type: string
        required: true
        description: "Type of service (livekit, kosmos-server, transcription, relay, etc.)"
      endpoint:
        type: string
        required: true
        description: "Connection URL for the service"
      config:
        type: object
        required: false
        description: "Service-specific configuration"
      status:
        type: enum
        values: [provisioning, running, stopped, error]
        required: true
        default: provisioning
      started_at:
        type: timestamp
        required: false
      error_message:
        type: string
        required: false
        description: "Error details if status is error"
```

**Changes from v4:**
- Renamed `slots` → `fields`
- Removed `node_id` field (use `hosts-service` desmos instead)

---

### kosmos-instance

A running kosmos interpreter serving a circle. New entity for distributed operation.

```yaml
- eidos: eidos
  id: eidos/kosmos-instance
  data:
    name: kosmos-instance
    description: |
      A running kosmos interpreter serving one circle's database.
      Observational entity for health sensing and federation discovery.
      Note: The substrate (systemd, Thyra) starts the instance; this entity describes it.
    fields:
      name:
        type: string
        required: true
        description: "Instance identifier"
      circle_id:
        type: string
        required: true
        description: "Circle this instance serves"
      server_url:
        type: string
        required: false
        description: "HTTP endpoint if exposed"
      mcp_available:
        type: boolean
        required: true
        default: true
        description: "Whether MCP protocol is available"
      http_available:
        type: boolean
        required: true
        default: false
        description: "Whether HTTP REST API is available"
      status:
        type: enum
        values: [starting, running, stopping, stopped, error]
        required: true
        default: stopped
      version:
        type: string
        required: false
        description: "Kosmos version"
      last_health_check:
        type: timestamp
        required: false
```

---

## 2. Desmoi Definitions

### hosts-service

Node hosts a service instance.

```yaml
- eidos: desmos
  id: desmos/hosts-service
  data:
    name: hosts-service
    description: "A node hosts a service instance"
    from_eidos:
      - node
    to_eidos:
      - service-instance
    cardinality: one-to-many
```

---

### provides-to

Service instance provides capability to a circle.

```yaml
- eidos: desmos
  id: desmos/provides-to
  data:
    name: provides-to
    description: "A service instance provides capability to a circle"
    from_eidos:
      - service-instance
    to_eidos:
      - circle
    cardinality: many-to-many
    data_fields:
      quota:
        type: object
        required: false
        description: "Resource limits for this circle"
      config:
        type: object
        required: false
        description: "Circle-specific service configuration"
```

---

### runs-on

Kosmos instance runs on a node.

```yaml
- eidos: desmos
  id: desmos/runs-on
  data:
    name: runs-on
    description: "A kosmos instance runs on a node"
    from_eidos:
      - kosmos-instance
    to_eidos:
      - node
    cardinality: many-to-one
```

---

## 3. Attainments

### attainment/infrastructure

Capability to manage infrastructure entities.

```yaml
- eidos: attainment
  id: attainment/infrastructure
  data:
    name: infrastructure
    description: |
      Capability to register and manage infrastructure entities (nodes, services).
      Required for commons operations and self-hosting.
    oikos: soma
    scope: circle
    grants:
      - praxis/soma/register-node
      - praxis/soma/sense-node
      - praxis/soma/register-service
      - praxis/soma/sense-service
```

---

## 4. Manifest Updates

Add to `soma/manifest.yaml` provides section:

```yaml
provides:
  eide:
    # ... existing eide ...
    - node
    - service-instance
    - kosmos-instance

  desmoi:
    # ... existing desmoi ...
    - hosts-service
    - provides-to
    - runs-on

  attainments:
    # ... existing attainments ...
    - infrastructure

  praxeis:
    # ... existing praxeis ...
    - soma/register-node
    - soma/sense-node
    - soma/register-service
    - soma/sense-service
    - soma/sense-kosmos-instance
```

---

## 5. File Locations

| Content | File |
|---------|------|
| Eide | `genesis/soma/eide/soma.yaml` (append) |
| Desmoi | `genesis/soma/desmoi/soma.yaml` (append) |
| Manifest | `genesis/soma/manifest.yaml` (update provides) |
| Praxeis | `genesis/soma/praxeis/soma.yaml` (new operations) |

---

## 6. Design Rationale

### Why soma oikos?

V4 had infrastructure in soma/hypostasis (underlying substance). The current soma focuses on embodiment but can expand to include the physical substrate where embodiment occurs.

### Why separate from dynamis/deployment?

- `deployment` = process lifecycle management (start/stop/reconcile)
- `service-instance` = running service description (what it is, where to connect)
- `node` = physical substrate (what machine hosts things)

They're complementary: a `deployment` manifests a `service-instance` on a `node`.

### Why kosmos-instance is observational?

The substrate (systemd, Thyra, launchd) starts kosmos-server processes. Creating a kosmos-instance entity doesn't cause a process to start — it describes an existing process for sensing and federation purposes.

---

## 7. Use Case Mapping

### Self Circle (Local)

```
node/victors-laptop (kind: personal)
    │
    └── hosts-service ──► service-instance/transcription-daemon
    │
    └── runs-on ◄── kosmos-instance/self-circle
```

### Peer Circle (P2P)

```
node/victors-laptop                    node/alices-laptop
    │                                      │
    └── runs-on ◄── kosmos-instance/peer   └── runs-on ◄── kosmos-instance/peer
                         │                                      │
                         └── serves circle/peer-group ◄─────────┘
                                    (federated)
```

### Commons Circle

```
node/minis-forum (kind: commons, steward: circle/liminal-commons)
    │
    ├── hosts-service ──► service-instance/livekit
    │                         │
    │                         └── provides-to ──► circle/vibe-cafe
    │
    ├── hosts-service ──► service-instance/kosmos-server-vibe-cafe
    │
    └── runs-on ◄── kosmos-instance/vibe-cafe
                         │
                         └── serves circle/vibe-cafe
```

---

## 8. Migration Notes

### From v4 Archive

Source: `archive/genesis-v4-DEPRECATED/soma/soma.core.yaml`

| V4 Pattern | Current Pattern |
|------------|-----------------|
| `slots:` | `fields:` |
| `node.services: array` | Use `hosts-service` desmos |
| `service-instance.node_id: string` | Use `hosts-service` desmos |
| Topos organization | Flat oikos structure |

### Not Reviving

- `vitals` eidos (use `actuality-record` from dynamis instead)
- `nix-service` eidos (too NixOS-specific; use generic `service-instance`)
- Pain/monitoring system (separate concern, can add later)

---

*Handoff created for kosmos repository development.*
*After implementation, update chora research/design docs to reference new ontology.*
