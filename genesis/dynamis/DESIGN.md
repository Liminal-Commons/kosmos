# Dynamis Design

δύναμις (dýnamis) — power, potency, the capacity for change

## Ontological Purpose

Dynamis addresses **the gap between intention and actuality** — the distance between what should exist and what actually does exist in the substrate.

Without dynamis:
- Releases exist only as ideas, never as downloadable binaries
- Deployments have no coherent lifecycle management
- External infrastructure floats outside kosmos understanding
- There's no feedback loop between intent and reality

With dynamis:
- **Releases**: Versioned artifacts that manifest into distribution channels
- **Substrates**: Target platforms where software runs
- **Distribution channels**: Pathways for releases to reach users
- **Deployments**: Running instances that can be sensed and reconciled
- **Actuality records**: Audit trail of what actually exists

The phylax pattern (sense → compare → act) is the fundamental rhythm of dynamis.

## Circle Context

### Self Circle

A solitary dweller uses dynamis to:
- Create releases for personal projects
- Track which binaries are uploaded where
- Monitor deployment status
- Reconcile drift between intent and actuality

Personal infrastructure becomes visible and manageable.

### Peer Circle

Collaborators use dynamis to:
- Coordinate release schedules
- Share distribution channels
- Track who deployed what and when
- Maintain shared deployment infrastructure

The provenance chain shows who actualized what.

### Commons Circle

A commons circle uses dynamis to:
- Publish official releases to public channels
- Maintain community infrastructure
- Define canonical substrates for the ecosystem
- Audit distribution integrity

Dynamis serves as the infrastructure layer for oikos distribution.

## Core Entities (Eide)

### release

A versioned build artifact — what will be distributed.

**Fields:**
- `name` — Release name (e.g., 'thyra')
- `version` — Semantic version
- `status` — Lifecycle state (draft, building, built, distributing, distributed, failed, deprecated)
- `description`, `changelog` — Documentation
- `build_commit`, `build_timestamp`, `build_command` — Build provenance
- `distributed_at`, `distribution_channels` — Distribution tracking

**Lifecycle:**
- Arise: create-release in draft state
- Change: register-artifact adds files, mark-release-built readies for distribution
- Actualize: distribute-release uploads to channels
- Depart: Deprecated when superseded

### release-artifact

Individual file within a release — a platform-specific binary.

**Fields:**
- `filename` — Artifact filename
- `artifact_type` — binary, checksum, signature, archive, installer, metadata
- `platform` — Target platform
- `size_bytes`, `content_hash`, `mime_type` — File metadata
- `uploaded`, `uploaded_at`, `upload_url` — Actuality tracking
- `local_path`, `built_at` — Build origin

**Lifecycle:**
- Arise: register-artifact creates linked to release
- Actualize: distribute-release uploads via energeia
- Sense: sense-release checks if artifact exists in channel

### substrate

Target platform or environment — where software runs.

**Fields:**
- `name` — Substrate identifier (e.g., 'mac-arm64')
- `kind` — platform, runtime, or environment
- `os`, `arch` — For platform substrates
- `runtime_type` — For runtime substrates
- `environment_type` — For environment substrates
- `parent_substrate` — Hierarchy support
- `active` — Whether actively targeted

**Lifecycle:**
- Arise: create-substrate defines target
- Change: May be deactivated
- No actuality: Substrates are conceptual categories

### distribution-channel

Pathway for releases to reach users — the "where" of distribution.

**Fields:**
- `name` — Channel identifier
- `provider` — r2, github, homebrew, npm, crates, direct
- `config` — Provider-specific configuration
- `base_url` — Download URL
- `status` — active, paused, deprecated

**Lifecycle:**
- Arise: create-distribution-channel with provider config
- Actualize: Provider-specific (R2 uses object-storage mode)
- Change: May be paused or deprecated

### deployment

Manifestation of release to target — running instances.

**Fields:**
- `name` — Deployment identifier
- `desired_state` — running, stopped, removed (intent)
- `actual_state` — unknown, running, stopped, degraded, failed, removed (sensed)
- `manifest_handle` — Process ID or deployment handle
- `last_sensed_at`, `last_reconciled_at` — Actuality tracking
- `deployed_at`, `deployed_by` — Deployment metadata

**Relationships via bonds:**
- `deploys-release` → release being deployed
- `targets` → substrate being deployed to
- `uses-channel` → distribution channel (optional)

**Lifecycle:**
- Arise: create-deployment with release and substrate bonds
- Actualize: manifest-deployment brings into running state
- Sense: sense-deployment queries actual state
- Reconcile: reconcile-deployment aligns intent with actuality

### actuality-record

Snapshot of sensed state — audit trail for reconciliation.

**Fields:**
- `entity_id` — Entity this was sensed for
- `sensed_at` — When sensing occurred
- `actual_state` — What was sensed
- `details` — Provider-specific details
- `expected_state` — What we expected
- `aligned` — Whether actual matched expected
- `drift_type` — none, missing, extra, different
- `reconciliation_action` — Action taken or planned

**Lifecycle:**
- Arise: Created during sense operations
- No actuality: Records are internal kosmos state

## Bonds (Desmoi)

### contains-artifact

Release contains this artifact.

- **From:** release
- **To:** release-artifact
- **Cardinality:** one-to-many
- **Traversal:** Find all artifacts in a release

### targets-substrate / targets

Release or deployment targets this substrate.

- **From:** release, deployment
- **To:** substrate
- **Cardinality:** many-to-many
- **Traversal:** Find what targets a substrate

### distributed-via

Release is distributed through this channel.

- **From:** release
- **To:** distribution-channel
- **Cardinality:** many-to-many
- **Traversal:** Find distribution channels for a release

### deploys-release

Deployment manifests this release.

- **From:** deployment
- **To:** release
- **Cardinality:** many-to-one
- **Traversal:** Find what release a deployment runs

### uses-channel / through-channel

Deployment uses this distribution channel.

- **From:** deployment
- **To:** distribution-channel
- **Cardinality:** many-to-one
- **Traversal:** Find channel for a deployment

### has-actuality

Entity has this actuality record.

- **From:** any entity
- **To:** actuality-record
- **Cardinality:** one-to-many
- **Traversal:** Find actuality history for an entity

### substrate-of

Substrate is a child of parent substrate.

- **From:** substrate
- **To:** substrate
- **Cardinality:** many-to-one
- **Traversal:** Navigate substrate hierarchy

### succeeds-release / supersedes-release

Release succession chain.

- **From:** release
- **To:** release
- **Cardinality:** one-to-one
- **Traversal:** Find release lineage

## Operations (Praxeis)

### create-release

Create a new release in draft state.

- **When:** Starting a release cycle
- **Requires:** release attainment
- **Provides:** Release entity with provenance

### register-artifact

Register a build artifact with a release.

- **When:** Build produces artifacts
- **Requires:** release attainment
- **Provides:** Artifact entity bonded to release

### mark-release-built

Mark a release as ready for distribution.

- **When:** All artifacts are registered
- **Requires:** release attainment
- **Provides:** Status update to 'built'

### distribute-release

Distribute a release through a channel (actualize).

- **When:** Release is built and ready
- **Requires:** distribute attainment
- **Provides:** Uploaded artifacts with URLs

### sense-release

Sense actual state of release in channels.

- **When:** Checking distribution status
- **Requires:** distribute attainment
- **Provides:** Actuality records with drift detection

### reconcile-release

Reconcile release intent with actuality.

- **When:** Drift detected or on schedule
- **Requires:** distribute attainment
- **Provides:** Reconciled state, actions taken

### create-substrate

Create a substrate definition.

- **When:** Defining target platforms
- **Requires:** substrate attainment
- **Provides:** Substrate entity

### create-distribution-channel

Create a distribution channel.

- **When:** Setting up distribution pathways
- **Requires:** channel attainment
- **Provides:** Channel entity with provider config

### create-deployment

Create a deployment target.

- **When:** Setting up where releases run
- **Requires:** deploy attainment
- **Provides:** Deployment entity with bonds

### manifest-deployment

Bring a deployment into actuality.

- **When:** Starting a service
- **Requires:** deploy attainment
- **Provides:** Running deployment with handle

### sense-deployment

Sense actual state of deployment.

- **When:** Checking deployment health
- **Requires:** deploy attainment
- **Provides:** Actual state, alignment status

### reconcile-deployment

Reconcile deployment intent with actuality.

- **When:** Drift detected or on schedule
- **Requires:** deploy attainment
- **Provides:** Reconciled state, actions taken

### list-releases / list-substrates / list-distribution-channels

Query operations for dynamis entities.

- **When:** Exploring what exists
- **Requires:** Respective attainments
- **Provides:** Filtered entity lists

### reconcile (generic)

Generic reconciliation using declarative reconciler definition.

- **When:** Any entity needs reconciliation
- **Requires:** reconcile attainment
- **Provides:** Declarative phylax execution

## Attainments

### attainment/release

Release management capability — creating and tracking releases.

- **Grants:** create-release, register-artifact, mark-release-built, list-releases
- **Scope:** circle
- **Rationale:** Release creation is a development act; distribution is separate

### attainment/substrate

Substrate management capability — defining target platforms.

- **Grants:** create-substrate, list-substrates
- **Scope:** circle
- **Rationale:** Substrate definitions are infrastructure configuration

### attainment/channel

Distribution channel management — defining distribution pathways.

- **Grants:** create-distribution-channel, list-distribution-channels
- **Scope:** circle
- **Rationale:** Channel configuration requires provider credentials

### attainment/distribute

Distribution actuality capability — uploading releases to channels.

- **Grants:** distribute-release, sense-release, reconcile-release
- **Scope:** circle
- **Rationale:** Tier-3 actuality operations require explicit authorization

### attainment/deploy

Deployment management capability — running services.

- **Grants:** create-deployment, manifest-deployment, sense-deployment, reconcile-deployment
- **Scope:** circle
- **Rationale:** Deployments affect external systems; requires authorization

### attainment/reconcile

Generic reconciliation capability — the phylax pattern.

- **Grants:** reconcile
- **Scope:** circle
- **Rationale:** Reconciliation is a powerful actuality operation

## Embodiment

### Completeness Status

| Level | Status |
|-------|--------|
| Defined | ✅ 6 eide, 11 desmoi, 16 praxeis |
| Loaded | ✅ Bootstrap loads all definitions |
| Projected | ✅ All praxeis visible as MCP tools |
| Embodied | ⏳ Body-schema contribution pending |
| Surfaced | ⏳ Reconciler not yet implemented |
| Afforded | ⏳ Thyra deployment affordances pending |

### Body-Schema Contribution

When sense-body gathers dynamis state:

```yaml
actuality:
  releases:
    total: 12
    distributed: 8
    pending_distribution: 2
  deployments:
    running: 3
    stopped: 1
    drifted: 1           # actual != desired
  channels:
    active: 2
    paused: 0
  last_reconciliation: "2026-01-28T10:30:00Z"
```

This reveals actuality status and pending reconciliation work.

### Reconciler

A dynamis reconciler would surface:

- **Distribution gaps** — "Release thyra-0.2.0 is built but not distributed"
- **Deployment drift** — "deployment/prod has drifted: desired=running, actual=stopped"
- **Missing artifacts** — "release-artifact/thyra-0.2.0-mac has disappeared from R2"
- **Stale sensing** — "deployment/staging hasn't been sensed in 24 hours"

## Compound Leverage

### amplifies demiurge

Oikos-prod packages flow through distribution channels. Baked packages become distributable releases.

### amplifies ekdosis

Content publication uses dynamis patterns for object-storage actuality.

### amplifies politeia

Distribution channels may be circle-scoped. Who can distribute requires governance.

### amplifies hypostasis

Signing releases for authenticity verification.

### amplifies dokimasia

Actuality sensing provides validation data. Reconciliation checks become validation rules.

## Theoria

### T44: Actuality is sensed, not assumed

The distinction between existence (kosmos entity) and actuality (chora state) is constitutional. Entities can exist without being actual. Actuality can drift from entities. Sensing closes the gap.

### T45: Reconciliation is declarative, not procedural

The phylax pattern (sense → compare → act) should be declared as reconciler entities, not coded as procedures. Adding reconciliation logic means editing definitions, not code.

### T46: Distribution channels are typed pathways

A channel isn't just a URL — it's a typed pathway with provider-specific actuality modes. R2, GitHub, Homebrew each have their own manifestation patterns.

## Future Extensions

### Auto-Reconciliation Daemons

Currently manual: call reconcile-* praxeis. Future: ergon daemons that reconcile on schedule.

### Multi-Region Distribution

Current: single region per channel. Future: distribute-release with region replication.

### Rollback Support

Current: manual revert. Future: deployment rollback to previous release via succeeds-release bonds.

### Health Checks

Current: simple sense. Future: health check definitions with degradation thresholds.

---

*Composed in service of the kosmogonia.*
*The power to actualize. The capacity to sense. The rhythm of reconciliation.*
