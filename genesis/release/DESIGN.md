# Release Design

Artifact lifecycle — the journey from build to user

## Ontological Purpose

Release addresses **the gap between built artifact and available download** — how versioned software reaches users.

Without release:
- Artifacts exist but aren't versioned
- Distribution is manual and ad-hoc
- No pipeline from commit to download
- Version history is opaque

With release:
- **Releases**: Versioned containers with lifecycle states
- **Artifacts**: Platform-specific binaries with hashes
- **Channels**: Distribution pathways (R2, GitHub, Homebrew)
- **Pipeline**: draft → building → built → distributing → distributed

The central concept is **the artifact journey** — from git commit to user installation.

## Oikos Context

### Self Oikos

A solo developer uses release to:
- Create releases from local builds
- Track version history
- Distribute to personal channels
- Manage pre-release testing

Personal releases are controlled experiments.

### Peer Oikos

Collaborators use release to:
- Coordinate release schedules
- Share signing responsibilities
- Review artifacts before distribution
- Track who released what when

Peer releases are coordinated shipping.

### Commons Oikos

A commons uses release to:
- Define release processes
- Enforce signing requirements
- Manage multiple distribution channels
- Analyze download statistics

Commons releases are production pipelines.

## Core Entities (Eide)

### release

A versioned build artifact — exists in kosmos as intention, actualizes as downloadable binary.

**Fields:**
- `name` — release name (e.g., 'thyra')
- `version` — semantic version (e.g., '0.1.0')
- `status` — lifecycle state (draft, building, built, distributing, distributed, failed, deprecated)
- `description` — release notes
- `changelog` — what changed
- `build_commit` — git commit SHA
- `build_timestamp` — when build completed
- `distributed_at` — when distribution completed
- `distribution_channels` — channel IDs where distributed

**Actuality:** Object storage (R2) with key pattern `{name}/{version}/{filename}`

### release-artifact

An individual file within a release — platform-specific binary, checksum, or signature.

**Fields:**
- `filename` — artifact filename (e.g., 'thyra-0.1.0-mac-arm64.dmg')
- `artifact_type` — type (binary, checksum, signature, archive, installer, metadata)
- `platform` — target platform (e.g., 'mac-arm64')
- `size_bytes` — file size
- `content_hash` — BLAKE3 hash
- `mime_type` — MIME type
- `uploaded` — whether uploaded to distribution
- `upload_url` — accessible URL
- `local_path` — filesystem path if built locally

### distribution-channel

A pathway for releases to reach users.

**Fields:**
- `name` — channel identifier (e.g., 'thyra-r2', 'github-releases')
- `provider` — distribution provider (r2, github, homebrew, npm, crates, direct)
- `config` — provider-specific configuration
- `base_url` — base URL for downloads
- `status` — active, paused, deprecated

## Bonds (Desmoi)

### contains-artifact

Release contains artifacts.

- **From:** release
- **To:** release-artifact
- **Semantics:** This release includes this artifact

### distributed-via

Release distributed through channel.

- **From:** release
- **To:** distribution-channel
- **Semantics:** This release is available on this channel

## Operations (Praxeis)

### create-release

Create a new release entity.

- **When:** Starting a new version
- **Provides:** Release entity in draft state

### register-artifact

Register an artifact for a release.

- **When:** After building a platform binary
- **Provides:** Release-artifact entity with hash

### mark-release-built

Transition release from building to built.

- **When:** All artifacts registered
- **Provides:** Updated release status

### distribute-release

Upload release artifacts to channels.

- **When:** Ready for distribution
- **Provides:** Distributed state, download URLs

### sense-release

Check actual state of distributed release.

- **When:** Reconciliation loop
- **Provides:** Actuality record

### reconcile-release

Compare release intent with actuality.

- **When:** Detecting drift
- **Provides:** Reconciliation actions

## Attainments

### attainment/release

Release management capability — creating and tracking releases.

- **Grants:** create-release, register-artifact, mark-built, list-releases, get-release
- **Scope:** oikos
- **Rationale:** Releases are shared resources of a development oikos

### attainment/publish-release

Release distribution capability — uploading to channels.

- **Grants:** distribute, sense-release, reconcile-release
- **Scope:** oikos
- **Rationale:** Distribution affects external systems; requires authorization

## Embodiment

### Completeness Status

| Level | Status |
|-------|--------|
| Defined | 3 eide, 2 desmoi, 2 attainments, 8 praxeis |
| Loaded | Bootstrap loads all definitions |
| Projected | Praxeis visible as MCP tools |
| Embodied | Partial — R2 upload implemented |
| Surfaced | Future — release dashboard |
| Afforded | Future — one-click release |

### Body-Schema Contribution

When sense-body gathers release state:

```yaml
releases:
  latest_version: "0.9.0"
  latest_status: "distributed"
  channels_active: 2
  artifacts_count: 4
  pending_distribution: false
```

This reveals the release pipeline health.

### Reconciler

A release reconciler would surface:

- **Distribution failed** — "Artifact upload to R2 failed, retrying"
- **Version drift** — "GitHub release missing artifact mac-arm64"
- **Stale release** — "Release 0.8.0 still marked building after 24h"

## Compound Leverage

### amplifies dynamis

Dynamis provides the manifest/sense/reconcile pattern; release applies it to versioned artifacts. Release is the primary user of dynamis's distribution capabilities.

### amplifies hypostasis

Hypostasis provides signing; releases should be signed. The `signature` artifact type connects release integrity to cryptographic identity.

### amplifies ergon

Ergon daemons can automate release pipelines. A build-release daemon watches for tags and creates releases automatically.

### amplified by thyra

Thyra's release eide (in the DESIGN) reference distribution. Release provides the lifecycle; thyra provides the runtime.

## Theoria

### T76: Releases are journeys

A release follows a path: draft → building → built → distributing → distributed. Each state is a waypoint. Failed is a branch. The release lifecycle is a journey through states.

### T77: Artifacts are the actuality of releases

The release entity is intention; the downloadable binary is actuality. Sense detects whether the artifact exists at the URL. Reconcile uploads if missing. This is the dynamis pattern applied to software distribution.

### T78: Channels multiply reach

One release, many channels. Each channel (R2, GitHub, Homebrew) is a separate actuality with its own reconciliation. Distribution success means all channel actualities match the release intent.

---

*Composed in service of the kosmogonia.*
*From commit to download, the artifact journey unfolds.*
