# Kosmos Handoff: Deployment Infrastructure

> **Status:** Active
> **Waiting on:** Deployment-to-infrastructure desmoi in dynamis

**Purpose:** Bridge deployments to concrete infrastructure for commons node operations.

**Context:** With soma providing infrastructure eide (node, service-instance, kosmos-instance) and dynamis providing deployment lifecycle, we need desmoi connecting these domains. This enables kosmos to manage deployments of kosmos itself on infrastructure like chora-node.

---

## Summary

Added to **dynamis** topos (desmoi connecting deployment to soma infrastructure):

| Bond | From → To | Purpose |
|------|-----------|---------|
| **targets-node** | deployment → node | Deployment targets specific machine |
| **manifests-as** | deployment → service-instance | Deployment manifested as running service |
| **steward-of** | oikos → node | Oikos governs commons node |

These complement existing dynamis bonds:
- `deploys-release` (deployment → release) — what to deploy
- `targets` (deployment → substrate) — abstract platform target
- `through-channel` (deployment → distribution-channel) — how to obtain

---

## 1. New Desmoi

### targets-node

Deployment targets a specific node for execution.

```yaml
- eidos: desmos
  id: desmos/targets-node
  data:
    name: targets-node
    description: |
      Deployment targets this specific node for execution.
      Unlike 'targets' (which points to abstract substrate), targets-node
      points to a concrete machine where the deployment should run.
    from_eidos: deployment
    to_eidos: node
    cardinality: many-to-many
    symmetric: false
    note: |
      Many-to-many allows: same deployment on multiple nodes (replication),
      or different deployments on same node (multi-service).
```

**Use cases:**
- `deployment/kosmos-server` targets-node `node/chora-node`
- `deployment/livekit` targets-node `node/chora-node` AND `node/backup-node`

---

### manifests-as

Deployment manifested as a service-instance.

```yaml
- eidos: desmos
  id: desmos/manifests-as
  data:
    name: manifests-as
    description: |
      Deployment manifested as this service-instance.
      Created when reconciliation actualizes the deployment.
      The bridge from intent (deployment) to actuality (service-instance).
    from_eidos: deployment
    to_eidos: service-instance
    cardinality: one-to-many
    symmetric: false
    note: |
      One-to-many allows: one deployment manifests multiple instances
      (for HA/replication). Query via trace to find what a deployment became.
```

**Use cases:**
- `deployment/kosmos-vibe-cafe` manifests-as `service-instance/kosmos-vibe-cafe@chora-node`
- Trace from deployment to find its running manifestations
- Trace from service-instance to find originating deployment

---

### steward-of

Oikos stewards (governs) a commons node.

```yaml
- eidos: desmos
  id: desmos/steward-of
  data:
    name: steward-of
    description: |
      Oikos stewards (governs) this commons node.
      Replaces the embedded node.steward_oikos_id field with a proper bond.
      The steward oikos has authority over node configuration and service allocation.
    from_eidos: oikos
    to_eidos: node
    cardinality: one-to-many
    symmetric: false
    note: |
      A commons node has exactly one steward oikos.
      Query: from node, trace steward-of (reverse) to find governing oikos.
```

**Use cases:**
- `oikos/liminal-commons` steward-of `node/chora-node`
- Validates who can manage deployments on the node

---

## 2. Deployment Flow

### Abstract Flow (Current)

```
create-deployment(release, substrate, channel)
    │
    ├── deploys-release ──► release/kosmos-0.3.0
    ├── targets ──────────► substrate/linux-x64
    └── through-channel ──► channel/github-releases
```

### Concrete Flow (With Infrastructure)

```
create-deployment(release, substrate, node)
    │
    ├── deploys-release ──► release/kosmos-0.3.0
    ├── targets ──────────► substrate/linux-x64
    ├── targets-node ─────► node/chora-node
    │
    │   manifest-deployment
    │         │
    │         ▼
    └── manifests-as ─────► service-instance/kosmos@chora-node
                                    │
                                    └── hosts-service ◄── node/chora-node
```

---

## 3. Chora Implementation Notes

### Existing Infrastructure

The soma topos already provides:
- `node` eidos — physical/virtual machine representation
- `service-instance` eidos — running service description
- `kosmos-instance` eidos — running kosmos interpreter
- `hosts-service` desmos — node hosts service
- `provides-to` desmos — service provides to oikos
- `runs-on` desmos — instance runs on node

### What Chora Needs

1. **MCP/Substrate Bridge**
   - When `manifest-deployment` succeeds, create corresponding `service-instance` entity
   - Bind via `manifests-as` desmos
   - Bind service-instance to node via `hosts-service`

2. **Sensing Integration**
   - `sense-deployment` should query actual service-instance state
   - Align with soma's `sense-service` praxis

3. **Stewardship Validation**
   - Before manifesting on a commons node, verify oikos has stewardship
   - Trace `steward-of` from node to check authorization

4. **NixOS/systemd Actuation**
   - For chora-node specifically: translate deployment intent to NixOS configuration
   - Either imperative (systemctl) or declarative (NixOS module generation)

---

## 4. Example: Kosmos Self-Deployment

Scenario: Deploy kosmos-server serving vibe-cafe oikos on chora-node.

```yaml
# 1. Create node entity (via soma/register-node)
- node:
    id: node/chora-node
    name: chora-node
    kind: commons
    platform: nixos
    address: 192.168.1.163

# 2. Establish stewardship (governance bond)
bind(oikos/liminal-commons, node/chora-node, steward-of)

# 3. Create deployment (dynamis)
create-deployment:
  name: kosmos-vibe-cafe
  release_id: release/kosmos-0.3.0
  substrate_id: substrate/linux-x64
  node_id: node/chora-node   # New parameter

# 4. Manifest (actualize)
manifest-deployment:
  deployment_id: deployment/kosmos-vibe-cafe
  # → Creates service-instance/kosmos-vibe-cafe@chora-node
  # → Binds via manifests-as
  # → Binds via hosts-service

# 5. Sense (observe actuality)
sense-deployment:
  deployment_id: deployment/kosmos-vibe-cafe
  # → Checks actual service state on chora-node
```

---

## 5. File Locations

| Content | File |
|---------|------|
| Desmoi definitions | `genesis/dynamis/desmoi/dynamis.yaml` (lines 147-201) |
| Design documentation | `genesis/dynamis/DESIGN.md` (Infrastructure Deployment Relationships section) |
| Manifest | `genesis/dynamis/manifest.yaml` (desmoi list) |

---

## 6. Constitutional Alignment

### Visibility = Reachability

The bond graph determines deployment authorization:
- Can trace `steward-of` from oikos to node? → Can deploy
- Can trace `manifests-as` from deployment to service? → Can sense

### Authenticity = Provenance

Deployment entities trace back:
- `composed-from` → typos-def-deployment
- `authorized-by` → oikos with deploy attainment
- `manifests-as` → service-instance with sensing provenance

### Phylax Pattern

The sense → compare → act pattern:
1. **Sense**: Query service-instance actual state
2. **Compare**: deployment.desired_state vs actuality
3. **Act**: manifest/unmanifest as needed

---

## 7. Praxis Extension Notes

Current `create-deployment` takes `substrate_id` but not `node_id`. To support infrastructure targeting:

**Option A: Extend create-deployment**
```yaml
params:
  - name: node_id
    type: string
    required: false
    description: "Target node (optional, for infrastructure deployments)"
steps:
  # ... existing steps ...
  - step: switch
    cases:
      - when: "$node_id"
        then:
          - step: find
            id: "$node_id"
            bind_to: node
          - step: bind
            from_id: "$deployment.id"
            to_id: "$node.id"
            desmos: targets-node
```

**Option B: Separate praxis**
```yaml
praxis/dynamis/target-deployment-to-node:
  params:
    - deployment_id
    - node_id
  steps:
    - find deployment
    - find node
    - bind via targets-node
```

For `manifest-deployment`, extend to create service-instance:
```yaml
# After successful manifest
- step: compose
  typos_id: typos-def-service-instance
  inputs:
    name: "{{ $deployment.data.name }}@{{ $node.data.name }}"
    service_kind: "$deployment.data.config.service_kind"
    endpoint: "$manifest_result.endpoint"
  bind_to: service_instance

- step: bind
  from_id: "$deployment.id"
  to_id: "$service_instance.id"
  desmos: manifests-as
```

---

*Handoff created for chora repository development.*
*After implementation, update chora research/design docs to reference these desmoi.*
