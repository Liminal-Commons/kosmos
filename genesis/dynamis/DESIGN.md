# Dynamis Design

δύναμις (dýnamis) — power, potency, the capacity for change

> **See also:** [REACTIVE-SYSTEM.md](../REACTIVE-SYSTEM.md) — Dynamis provides Layers 2 (Reconciler) and 3 (Actuality Mode) of the complete reactive architecture.

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

## Actuation via Emission

Per KOSMOGONIA's **Actuation = Reconciliation** pillar, dynamis never directly manipulates substrate. All actuation flows through reconciliation and emission:

```
Intent (deployment.desired_state)
    ↓
Reconciler (sense actuality, compare, decide)
    ↓
Thyra Emit (write configuration to chora)
    ↓
Substrate Actualization (nixos-rebuild, systemctl, etc.)
```

**What "manifest-deployment" actually means:**
1. Update `deployment.desired_state` to `running`
2. Reconciler detects desired ≠ actual
3. Emit deployment configuration (NixOS module, systemd unit, etc.)
4. Substrate watches emitted files and actualizes
5. Sense actuality, update `deployment.actual_state`

Kosmos expresses intent. Thyra emits configuration. Substrate actualizes. This separation is constitutional.

## Oikos Context

### Self Oikos

A solitary dweller uses dynamis to:
- Create releases for personal projects
- Track which binaries are uploaded where
- Monitor deployment status
- Reconcile drift between intent and actuality

Personal infrastructure becomes visible and manageable.

### Peer Oikos

Collaborators use dynamis to:
- Coordinate release schedules
- Share distribution channels
- Track who deployed what and when
- Maintain shared deployment infrastructure

The provenance chain shows who actualized what.

### Commons Oikos

A commons oikos uses dynamis to:
- Publish official releases to public channels
- Maintain community infrastructure
- Define canonical substrates for the ecosystem
- Audit distribution integrity

Dynamis serves as the infrastructure layer for topos distribution.

## Core Entities (Eide)

> Release eide (release, release-artifact, distribution-channel) are defined in the [release topos](../release/DESIGN.md).
> Dynamis consumes release entities via the `deploys-release` bond.

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

> Release-domain bonds (contains-artifact, distributed-via) are defined in the [release topos](../release/DESIGN.md).

### targets-substrate / targets

Release or deployment targets this substrate.

- **From:** release, deployment
- **To:** substrate
- **Cardinality:** many-to-many
- **Traversal:** Find what targets a substrate

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

### Infrastructure Deployment Relationships

These desmoi connect dynamis deployments to soma infrastructure entities (node, service-instance). This bridges intent (deployment) to actuality (running services on physical machines).

#### targets-node

Deployment targets a specific node for execution.

- **From:** deployment
- **To:** node
- **Cardinality:** many-to-many
- **Traversal:** From deployment, find target nodes; from node, find deployments targeting it
- **Note:** Unlike `targets` (abstract substrate), targets-node points to concrete machines. Many-to-many supports replication across nodes.

#### manifests-as

Deployment manifested as a service-instance.

- **From:** deployment
- **To:** service-instance
- **Cardinality:** one-to-many
- **Traversal:** From deployment, find running instances; from instance, trace back to deployment intent
- **Note:** Created when reconciliation actualizes the deployment. The bridge from intent to actuality.

#### steward-of

Oikos stewards (governs) a commons node.

- **From:** oikos
- **To:** node
- **Cardinality:** one-to-many
- **Traversal:** From oikos, find stewarded nodes; from node, find steward oikos
- **Note:** Replaces embedded `node.steward_oikos_id` field with a proper bond. The steward oikos has authority over node configuration.

## Operations (Praxeis)

> Release lifecycle praxeis (create-release, register-artifact, mark-built, distribute, sense-release, reconcile-release) are defined in the [release topos](../release/DESIGN.md).

### create-substrate

Create a substrate definition.

- **When:** Defining target platforms
- **Requires:** substrate attainment
- **Provides:** Substrate entity

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

### list-substrates

Query substrates, optionally filtered by kind.

- **When:** Exploring what substrates exist
- **Requires:** substrate attainment
- **Provides:** Filtered substrate list

### reconcile (generic)

Generic reconciliation using declarative reconciler definition.

- **When:** Any entity needs reconciliation
- **Requires:** reconcile attainment
- **Provides:** Declarative phylax execution

## Attainments

> Release-domain attainments (attainment/release, attainment/channel, attainment/distribute) are defined in the [release topos](../release/DESIGN.md).

### attainment/substrate

Substrate management capability — defining target platforms.

- **Grants:** create-substrate, list-substrates
- **Scope:** oikos
- **Rationale:** Substrate definitions are infrastructure configuration

### attainment/deploy

Deployment management capability — running services.

- **Grants:** create-deployment, manifest-deployment, sense-deployment, reconcile-deployment
- **Scope:** oikos
- **Rationale:** Deployments affect external systems; requires authorization

### attainment/reconcile

Generic reconciliation capability — the phylax pattern.

- **Grants:** reconcile
- **Scope:** oikos
- **Rationale:** Reconciliation is a powerful actuality operation

## Embodiment

### Completeness Status

| Level | Status |
|-------|--------|
| Defined | ✅ 4 eide, 9 desmoi, 10 praxeis |
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

Topos-prod packages flow through distribution channels. Baked packages become distributable releases.

### amplifies ekdosis

Content publication uses dynamis patterns for object-storage actuality.

### amplifies politeia

Distribution channels may be oikos-scoped. Who can distribute requires governance.

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
