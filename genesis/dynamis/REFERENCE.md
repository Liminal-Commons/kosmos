<!-- =============================================================================
<!-- GENERATED FILE - DO NOT EDIT DIRECTLY -->
<!-- =============================================================================
<!-- Emitted by: emit_cycle (demiurge/emit-genesis) -->
<!-- Source: genesis/dynamis/REFERENCE.md -->
<!-- -->
<!-- To modify: -->
<!--   1. Edit the source in genesis/ -->
<!--   2. Re-run emit-genesis -->
<!-- -->
<!-- See: genesis/EXTENDING.md -->
<!-- =============================================================================

# Dynamis Reference

Deployment and actuality management

> Release lifecycle reference is in the [release topos](../release/).

---

## Eide (Entity Types)

### actuality-record

A snapshot of sensed actuality. When sense() is called, the result

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `actual_state` | string | ✓ | The sensed state |
| `aligned` | boolean | ✓ | Whether actual matched expected |
| `details` | object |  | Provider-specific sensing details |
| `drift_type` | enum |  | Type of drift if not aligned |
| `entity_id` | string | ✓ | Entity this actuality was sensed for |
| `expected_state` | string |  | What we expected to find |
| `reconciliation_action` | enum |  | Action taken (or to be taken) in response |
| `sensed_at` | timestamp | ✓ |  |

### deployment

A manifestation of a release to a specific target. Deployments

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `actual_state` | enum | ✓ | Sensed actual state |
| `config` | object |  | Deployment-specific configuration |
| `deployed_at` | timestamp |  |  |
| `deployed_by` | string |  | Prosopon ID who deployed |
| `desired_state` | enum | ✓ | Desired deployment state |
| `last_reconciled_at` | timestamp |  |  |
| `last_sensed_at` | timestamp |  |  |
| `manifest_handle` | string |  | Handle for manifested deployment (process ID, deployment ID, etc.) |
| `name` | string | ✓ | Deployment identifier |

### substrate

A target platform or environment where software runs. Substrates

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `active` | boolean | ✓ | Whether this substrate is actively targeted |
| `arch` | enum |  | Architecture (for platform substrates) |
| `description` | string |  |  |
| `environment_type` | enum |  | Environment type (for environment substrates) |
| `kind` | enum | ✓ | Substrate category |
| `name` | string | ✓ | Substrate identifier (e.g., 'mac-arm64', 'production') |
| `os` | enum |  | Operating system (for platform substrates) |
| `parent_substrate` | string |  | Parent substrate ID for hierarchy |
| `runtime_type` | enum |  | Runtime type (for runtime substrates) |

## Praxeis (Operations)

🔧 = Exposed as MCP tool

### create-deployment 🔧

Create a deployment target.

**Tier:** 2 | **ID:** `praxis/dynamis/create-deployment`

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `name` | string | ✓ |  |
| `release_id` | string | ✓ |  |
| `substrate_id` | string | ✓ |  |
| `node_id` | string | ✓ | Target node for deployment |
| `channel_id` | string |  |  |
| `config` | object |  |  |

### create-substrate 🔧

Create a substrate (target platform/environment).

**Tier:** 2 | **ID:** `praxis/dynamis/create-substrate`

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `name` | string | ✓ | Substrate identifier (e.g., 'mac-arm64') |
| `kind` | string | ✓ | Kind: platform, runtime, or environment |
| `description` | string |  |  |
| `os` | string |  | OS for platform substrates |
| `arch` | string |  | Architecture for platform substrates |
| `parent_substrate` | string |  | Parent substrate ID for hierarchy |

### list-substrates 🔧

List all substrates, optionally filtered by kind.

**Tier:** 2 | **ID:** `praxis/dynamis/list-substrates`

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `kind` | string |  | Filter by kind (platform, runtime, environment) |
| `limit` | integer |  |  |

### manifest-deployment 🔧

Bring a deployment into actuality.

**Tier:** 3 | **ID:** `praxis/dynamis/manifest-deployment`

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `deployment_id` | string | ✓ |  |

### reconcile 🔧

Generic reconciliation using declarative reconciler definition.

**Tier:** 3 | **ID:** `praxis/dynamis/reconcile`

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `reconciler_id` | string | ✓ | Reconciler entity ID (e.g., reconciler/deployment) |
| `entity_id` | string | ✓ | Entity to reconcile |

### reconcile-deployment 🔧

Reconcile deployment intent with actuality.

**Tier:** 3 | **ID:** `praxis/dynamis/reconcile-deployment`

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `deployment_id` | string | ✓ |  |

### restart-deployment 🔧

Restart a deployment by triggering stop and start transitions.

**Tier:** 2 | **ID:** `praxis/dynamis/restart-deployment`

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `deployment_id` | string | ✓ | Deployment entity ID to restart |

### sense-deployment 🔧

Sense the actual state of a deployment.

**Tier:** 3 | **ID:** `praxis/dynamis/sense-deployment`

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `deployment_id` | string | ✓ |  |

## Desmoi (Bond Types)

| Desmos | From → To | Description |
|--------|-----------|-------------|
| `deploys-release` | deployment → release | Deployment deploys this release |
| `has-actuality` | * → actuality-record | Entity has this sensed actuality record |
| `manifests-as` | deployment → service-instance | Deployment manifested as this service-instance |
| `steward-of` | oikos → node | Oikos stewards (governs) this commons node |
| `substrate-of` | substrate → substrate | Substrate is a specialization of parent substrate |
| `succeeds-release` | release → release | This release succeeds (is a newer version of) another |
| `supersedes-release` | release → release | This release supersedes another (deprecates it) |
| `targets` | deployment → substrate | Deployment targets this substrate |
| `targets-node` | deployment → node | Deployment targets this specific node for execution |
| `targets-substrate` | release → substrate | Release targets this substrate (platform) |
| `through-channel` | deployment → distribution-channel | Deployment uses this distribution channel |
| `triggered-journey` | actuality-record → journey | Actuality drift triggered this learning journey |

---

*Generated from schema definitions. Do not edit directly.*
