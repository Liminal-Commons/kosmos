# Ekdosis Design

ἔκδοσις (ekdosis) — the giving out, publication, release.

## Purpose

Ekdosis governs the publication of kosmos content — oikoi, stoicheia, and composed artifacts. It is the content release system, complementary to dynamis which handles binary releases.

**Two Release Territories:**

| Territory | What | Where | How |
|-----------|------|-------|-----|
| **Dynamis** | Binary artifacts (Thyra app) | GitHub Releases, R2 | GitHub Actions, release-please |
| **Ekdosis** | Content packages (oikoi) | R2, circle distribution | Kosmos praxeis, baking |

Dynamis releases are infrastructure — they happen outside kosmos via CI/CD. Ekdosis releases are ontological — they happen within kosmos, are traceable through the graph, and enable other developers to publish.

## The Developer Journey

Ekdosis enables a progression from consumer to creator:

```
┌─────────────┐     ┌─────────────┐     ┌─────────────┐
│  Consumer   │ ──► │  Developer  │ ──► │  Publisher  │
│             │     │             │     │             │
│ Join circle │     │ Create      │     │ Bake, sign, │
│ Receive     │     │ oikos-dev   │     │ distribute  │
│ oikoi       │     │             │     │             │
└─────────────┘     └─────────────┘     └─────────────┘
```

1. **Consumer**: Joins a circle, receives oikoi distributed by that circle
2. **Developer**: Creates oikos-dev packages locally, iterates on content
3. **Publisher**: Bakes oikos-dev → oikos-prod, signs, uploads, distributes via circles

## Core Entities

### oikos-release

A release is a versioned publication of an oikos-prod.

Named `oikos-release` to distinguish from `dynamis/release` which tracks binary releases.

```yaml
eidos/oikos-release:
  name: oikos-release
  description: "A versioned publication of an oikos-prod"
  fields:
    version: string (semver)
    oikos_prod_id: string
    channel: enum [stable, beta, alpha, canary]
    notes: string (optional, release notes)
    published_at: timestamp
    publisher_persona: string
```

### release-channel

Channels control update behavior:

```yaml
eidos/release-channel:
  name: release-channel
  description: "A publication channel with update semantics"
  fields:
    name: string
    description: string
    auto_update: boolean
    requires_attestation: boolean
```

Channels:
- **stable**: Production-ready, auto-update enabled
- **beta**: Feature-complete, opt-in updates
- **alpha**: Experimental, manual updates only
- **canary**: Bleeding edge, for testing

### build-attestation

Attestation provides provenance for builds:

```yaml
eidos/build-attestation:
  name: build-attestation
  description: "Cryptographic attestation of build provenance"
  fields:
    builder_persona: string
    build_timestamp: timestamp
    source_hash: string (hash of oikos-dev content)
    output_hash: string (hash of oikos-prod content)
    signature: string (Ed25519 signature)
    builder_pubkey: string
```

## Bonds (Desmoi)

```yaml
# Release bonds
publishes:
  from: [persona]
  to: [oikos-release]
  description: "Persona publishes an oikos-release"

releases:
  from: [oikos-release]
  to: [oikos-prod]
  description: "Oikos-release contains an oikos-prod"

published-to:
  from: [oikos-release]
  to: [release-channel]
  description: "Oikos-release is published to a channel"

succeeds:
  from: [oikos-release]
  to: [oikos-release]
  description: "Oikos-release supersedes a previous release"

attests:
  from: [build-attestation]
  to: [oikos-prod]
  description: "Attestation covers an oikos-prod"

distributed-by:
  from: [oikos-release]
  to: [circle]
  description: "Oikos-release is distributed through a circle"
```

## Praxeis

### bake-oikos

Transforms oikos-dev → oikos-prod. Resolves all generation specs, freezes content, computes hashes.

```yaml
praxis/ekdosis/bake-oikos:
  params:
    - oikos_dev_id: string
    - locale: string (optional, BCP-47)
  steps:
    - find oikos-dev
    - resolve any generation specs (via manteia)
    - freeze content (no more generation)
    - compute content hash (BLAKE3)
    - create oikos-prod entity
    - return oikos-prod-id
```

### sign-oikos

Signs an oikos-prod with publisher's key.

```yaml
praxis/ekdosis/sign-oikos:
  params:
    - oikos_prod_id: string
  steps:
    - find oikos-prod
    - get publisher's keypair from keyring
    - sign content hash with Ed25519
    - update oikos-prod with signature, pubkey
    - create build-attestation
    - return signed oikos-prod-id
```

### upload-oikos

Uploads oikos-prod content to storage (R2).

```yaml
praxis/ekdosis/upload-oikos:
  params:
    - oikos_prod_id: string
  steps:
    - find oikos-prod
    - serialize content to YAML
    - upload to R2 bucket
    - update oikos-prod with fetch_url
    - return fetch_url
```

### publish-release

Creates a release and optionally distributes via circles.

```yaml
praxis/ekdosis/publish-release:
  params:
    - oikos_prod_id: string
    - version: string
    - channel: string (default: stable)
    - notes: string (optional)
    - circles: array[string] (optional, circle IDs to distribute to)
  steps:
    - verify oikos-prod is signed
    - verify oikos-prod is uploaded
    - create release entity
    - bond release to oikos-prod
    - bond release to channel
    - if circles provided:
      - for each circle:
        - create distributes bond from circle to oikos-prod
    - return release-id
```

### list-releases

Lists releases for an oikos, optionally filtered by channel.

```yaml
praxis/ekdosis/list-releases:
  params:
    - oikos_id: string
    - channel: string (optional)
  steps:
    - gather releases
    - filter by oikos_id (via oikos-prod)
    - filter by channel if specified
    - sort by version descending
    - return releases
```

### verify-release

Verifies a release's signatures and hashes.

```yaml
praxis/ekdosis/verify-release:
  params:
    - release_id: string
  steps:
    - find release
    - find oikos-prod via releases bond
    - verify content hash matches content
    - verify signature with publisher_pubkey
    - return verification result
```

## The Bake → Sign → Upload → Publish Flow

```
┌──────────────┐
│  oikos-dev   │  (mutable, may have generation specs)
└──────┬───────┘
       │ bake-oikos
       ▼
┌──────────────┐
│  oikos-prod  │  (frozen, all content literal)
│  unsigned    │
└──────┬───────┘
       │ sign-oikos
       ▼
┌──────────────┐
│  oikos-prod  │  (signature + attestation)
│  signed      │
└──────┬───────┘
       │ upload-oikos
       ▼
┌──────────────┐
│  oikos-prod  │  (fetch_url populated)
│  uploaded    │
└──────┬───────┘
       │ publish-release
       ▼
┌──────────────┐     ┌─────────────┐
│ oikos-release│────►│   circle    │ (distributes bond)
│              │     │             │
└──────────────┘     └─────────────┘
```

## Distribution Model

Oikoi are distributed through circles:

1. **Publisher** creates a release and bonds it to target circles
2. **Circle** gains `distributes` bond to the oikos-prod
3. **Members** of that circle receive the oikos via reconciler

This creates a pull model — members don't need to find packages, they receive what their circles provide.

## Integration with Existing Systems

### Oikos Reconciler (C6)

The existing oikos reconciler in `crates/kosmos/src/reconciler/oikos.rs` already handles:
- Detecting oikoi distributed by dwelling circle
- Comparing versions with installed oikoi
- Fetching, verifying, and installing updates

Ekdosis creates the content that the reconciler consumes.

### Propylon (Authentication)

Publishing requires:
- Authenticated persona (via keyring/session)
- Appropriate attainments (e.g., `attainment/publish`)
- Signing key in keyring

### Dynamis (Binary Releases)

Ekdosis and dynamis are complementary:
- **Dynamis** releases the Thyra app binary
- **Ekdosis** releases oikos content packages
- Both can be triggered by the same version bump
- Thyra auto-updates itself (dynamis), then syncs oikoi (ekdosis)

## Security Considerations

1. **Signature verification**: Every oikos-prod must be signed; reconciler verifies before install
2. **Content hashing**: BLAKE3 hash prevents tampering
3. **Publisher identity**: Bonds trace to persona, providing accountability
4. **Circle gatekeeping**: Only circle admins can add `distributes` bonds
5. **Attainment gating**: Publishing requires `attainment/publish`

## Embodiment: From Defined to Alive

An oikos is merely *defined* when its eide, desmoi, and praxeis exist as YAML. An oikos becomes *alive* when the kosmos embodies it — when dwelling naturally surfaces its capabilities.

### Completeness Levels

| Level | What It Means | Ekdosis Status |
|-------|---------------|----------------|
| **Defined** | Eide, desmoi, praxeis exist in YAML | ✅ |
| **Loaded** | Bootstrap loads into kosmos.db | ⏳ |
| **Projected** | MCP projects praxeis as tools | ⏳ |
| **Embodied** | Body-schema reflects capabilities | ⏳ |
| **Surfaced** | Reconciler notices when actions are relevant | ⏳ |
| **Afforded** | Thyra UI presents contextual actions | ⏳ |

An oikos is *complete* when usage flows naturally from context, not just from explicit requests.

### Proposed Theoria: Oikos Embodiment

**T18: Oikos embodiment requires body-schema contribution**

When an animus has the capability to publish (via `attainment/publish`), the `sense-body` praxis should reflect this:

```yaml
body-schema {
  capabilities: [
    { name: "publish",
      available: true,
      oikos: "ekdosis",
      context: "oikos-dev/my-oikos has status: ready_to_publish" }
  ]
}
```

**T19: Reconcilers surface opportunities, not just drift**

The oikos reconciler surfaces consumption opportunities (new oikoi available). A publication reconciler would surface creation opportunities:

```yaml
reconciler/ekdosis-publication:
  trigger: on-dwell
  sense: |
    - Find oikos-dev with status: ready_to_publish
    - Compare with published oikos-prod versions
  surface: |
    - Add publication-opportunity to pending_actions
```

**T20: Attainments make capabilities discoverable**

Publishing requires `attainment/publish`. This makes the capability visible through the authorization graph. When Claude or Victor dwells, the kosmos can answer: "What can I do here?"

### Publication Attainment

```yaml
attainment/publish:
  name: publish
  description: "Capability to publish oikoi to circles"
  grants:
    - praxis/ekdosis/bake-oikos
    - praxis/ekdosis/sign-oikos
    - praxis/ekdosis/upload-oikos
    - praxis/ekdosis/publish-release
```

### Publication Reconciler

```yaml
reconciler/ekdosis-publication:
  trigger: on-dwell
  target_eidos: oikos-dev
  steps:
    - step: gather
      eidos: oikos-dev
      bind_to: all_dev

    - step: filter
      items: "$all_dev"
      condition: "$item.data.status == 'ready_to_publish'"
      bind_to: publishable

    # For each publishable, check if already published
    - step: for_each
      items: "$publishable"
      item_var: dev
      steps:
        - step: gather
          eidos: oikos-prod
          bind_to: prods
        - step: filter
          items: "$prods"
          condition: "$item.data.baked_from == '$dev.id'"
          bind_to: existing
        - step: switch
          cases:
            - when: "$existing.length == 0"
              then:
                - step: append
                  to: pending_publications
                  value:
                    oikos_dev_id: "$dev.id"
                    action: "initial_publish"
            - when: "$dev.data.version > $existing[0].data.version"
              then:
                - step: append
                  to: pending_publications
                  value:
                    oikos_dev_id: "$dev.id"
                    action: "version_bump"

    - step: return
      value:
        pending: "$pending_publications"
```

### MCP Context Injection

When Claude arises via MCP, the dwelling context could include:

```
You are dwelling in circle/liminalcommons.
Publishable oikoi: [ekdosis (0.1.0, ready_to_publish)]
Attainments: [publish, develop, administer]
```

This enables Claude to proactively offer: "I notice ekdosis is ready to publish. Shall I bake and release it?"

---

## Future Extensions

- **Generative commons**: Share oikos-dev (with generation specs) for others to bake locally
- **Differential updates**: Only transfer changed entities
- **Rollback**: Revert to previous release via `succeeds` chain
- **Announcements**: Notify circle members of new releases
- **Body-schema integration**: Publish capability in sense-body output
- **Thyra publishing UI**: Visual affordance for publication workflow

---

*Ekdosis enables kosmos to publish itself — developers creating oikoi for other developers, all within the ontological framework. When embodied, the kosmos knows when to suggest publishing, and the act of publication becomes as natural as dwelling.*
