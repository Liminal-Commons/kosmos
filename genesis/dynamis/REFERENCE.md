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

existence-actuality bridging

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
| `deployed_by` | string |  | Persona ID who deployed |
| `desired_state` | enum | ✓ | Desired deployment state |
| `last_reconciled_at` | timestamp |  |  |
| `last_sensed_at` | timestamp |  |  |
| `manifest_handle` | string |  | Handle for manifested deployment (process ID, deployment ID, etc.) |
| `name` | string | ✓ | Deployment identifier |

### distribution-channel

A pathway for releases to reach users. Channels have providers

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `base_url` | string |  | Base URL for downloads (e.g., 'https://thyra.liminalcommons.com/download') |
| `config` | object | ✓ | Provider-specific configuration |
| `created_at` | timestamp | ✓ |  |
| `description` | string |  |  |
| `name` | string | ✓ | Channel identifier (e.g., 'thyra-r2', 'github-releases') |
| `provider` | enum | ✓ | Distribution provider |
| `status` | enum | ✓ |  |

### release

A versioned release of the Thyra application. Tracks version, artifacts, and deployment status.

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `changelog` | string |  | What's new in this release |
| `created_at` | timestamp | ✓ |  |
| `git_commit` | string |  | Git commit SHA |
| `git_tag` | string |  | Git tag for this release |
| `published` | boolean | ✓ | Whether this release is publicly available |
| `published_at` | timestamp |  |  |
| `release_type` | enum | ✓ | Release type |
| `version` | string | ✓ | Semantic version (e.g., '0.9.0-beta.1') |

### release-artifact

Platform-specific binary artifact for a release. Tracks hash, size, and storage location.

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `arch` | string | ✓ | Target architecture (e.g., 'universal', 'x64', 'amd64') |
| `content_hash` | string | ✓ | BLAKE3 hash of the artifact content |
| `download_url` | string |  | Public download URL |
| `filename` | string | ✓ | Artifact filename (e.g., 'Thyra_0.9.0_universal.dmg') |
| `platform` | enum | ✓ | Target platform |
| `size_bytes` | number | ✓ | Artifact size in bytes |
| `storage_path` | string | ✓ | R2 storage path (e.g., 'v0.9.0/Thyra_0.9.0_universal.dmg') |
| `uploaded_at` | timestamp | ✓ |  |

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
| `channel_id` | string |  |  |
| `config` | object |  |  |

### create-distribution-channel 🔧

Create a distribution channel for releases.

**Tier:** 2 | **ID:** `praxis/dynamis/create-distribution-channel`

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `name` | string | ✓ | Channel identifier (e.g., 'thyra-r2') |
| `provider` | string | ✓ | Provider: r2, github, homebrew, npm, crates, direct |
| `description` | string |  |  |
| `config` | object | ✓ | Provider-specific configuration |
| `base_url` | string |  | Base URL for downloads |

### create-release 🔧

Create a new release in draft state.

**Tier:** 2 | **ID:** `praxis/dynamis/create-release`

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `name` | string | ✓ | Release name (e.g., 'thyra') |
| `version` | string | ✓ | Semantic version (e.g., '0.1.0') |
| `description` | string |  | Release description or notes |
| `changelog` | string |  | What changed in this version |
| `build_commit` | string |  | Git commit SHA |

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

### distribute-release 🔧

Distribute a release through a channel.

**Tier:** 3 | **ID:** `praxis/dynamis/distribute-release`

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `release_id` | string | ✓ |  |
| `channel_id` | string | ✓ |  |

### list-distribution-channels 🔧

List all distribution channels.

**Tier:** 2 | **ID:** `praxis/dynamis/list-distribution-channels`

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `provider` | string |  | Filter by provider (r2, github, etc.) |
| `limit` | integer |  |  |

### list-releases 🔧

List all releases, optionally filtered by status.

**Tier:** 2 | **ID:** `praxis/dynamis/list-releases`

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `status` | string |  | Filter by status (draft, built, distributed, etc.) |
| `limit` | integer |  |  |

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

### mark-release-built 🔧

Mark a release as built (ready for distribution).

**Tier:** 2 | **ID:** `praxis/dynamis/mark-release-built`

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `release_id` | string | ✓ |  |

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

### reconcile-release 🔧

Reconcile a release's intent with its actuality.

**Tier:** 3 | **ID:** `praxis/dynamis/reconcile-release`

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `release_id` | string | ✓ |  |

### register-artifact 🔧

Register a build artifact with a release.

**Tier:** 2 | **ID:** `praxis/dynamis/register-artifact`

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `release_id` | string | ✓ | Release entity ID |
| `filename` | string | ✓ | Artifact filename (e.g., 'thyra-0.1.0-mac-arm64.dmg') |
| `artifact_type` | string | ✓ | Type: binary, checksum, signature, archive, installer |
| `platform` | string |  | Target platform (e.g., 'mac-arm64') |
| `local_path` | string |  | Local filesystem path to the built artifact |
| `size_bytes` | integer |  |  |
| `content_hash` | string |  | BLAKE3 hash of contents |

### sense-deployment 🔧

Sense the actual state of a deployment.

**Tier:** 3 | **ID:** `praxis/dynamis/sense-deployment`

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `deployment_id` | string | ✓ |  |

### sense-release 🔧

Sense the actual state of a release in its distribution channels.

**Tier:** 3 | **ID:** `praxis/dynamis/sense-release`

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `release_id` | string | ✓ |  |

## Desmoi (Bond Types)

| Desmos | From → To | Description |
|--------|-----------|-------------|
| `contains-artifact` | release → release-artifact | Release contains this artifact (binary, checksum, etc.) |
| `deploys-release` | deployment → release | Deployment deploys this release |
| `distributed-via` | release → distribution-channel | Release is distributed through this channel |
| `has-actuality` | * → actuality-record | Entity has this sensed actuality record |
| `substrate-of` | substrate → substrate | Substrate is a specialization of parent substrate |
| `succeeds-release` | release → release | This release succeeds (is a newer version of) another |
| `supersedes-release` | release → release | This release supersedes another (deprecates it) |
| `targets` | deployment → substrate | Deployment targets this substrate |
| `targets-substrate` | release → substrate | Release targets this substrate (platform) |
| `through-channel` | deployment → distribution-channel | Deployment uses this distribution channel |
| `triggered-journey` | actuality-record → journey | Actuality drift triggered this learning journey |

---

*Generated from schema definitions. Do not edit directly.*
