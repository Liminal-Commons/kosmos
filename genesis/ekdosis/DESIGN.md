# Ekdosis Design

ἔκδοσις (ekdosis) — the giving out, publication, release

## Ontological Purpose

Ekdosis addresses **the gap between private and public** — how content moves from local development to shared distribution.

Without ekdosis:
- Oikos packages have no versioning
- Content cannot be shared between circles
- Updates have no provenance
- Distribution is manual

With ekdosis:
- **Baking**: oikos-dev → oikos-prod (frozen, hashable)
- **Signing**: Cryptographic attestation of build provenance
- **Publishing**: Versioned releases to channels
- **Distribution**: Circles receive oikoi via bonds

The central concept is the **release** — a versioned, signed, distributable unit of content. Releases flow through circles to members via the reconciler.

## Circle Context

### Self Circle

A solitary dweller uses ekdosis to:
- Package their personal oikoi for backup
- Create local releases for version tracking
- Sign content for self-attestation
- Maintain release history

Self-publication enables personal version control.

### Peer Circle

Collaborators use ekdosis to:
- Share oikos packages between circle members
- Coordinate release channels (stable, beta)
- Verify each other's releases via signatures
- Receive updates through circle distribution

Peer distribution enables collaborative development.

### Commons Circle

A commons uses ekdosis to:
- Publish oikoi to the broader community
- Maintain multiple release channels
- Provide attestation for public trust
- Enable fork-and-extend workflows

Commons publishing enables ecosystem growth.

## Core Entities (Eide)

### oikos-release

A versioned publication of an oikos-prod.

**Fields:**
- `version` — semantic version
- `oikos_prod_id` — what's being released
- `channel` — stable, beta, alpha, canary
- `notes` — release notes
- `published_at` — timestamp
- `publisher_persona` — who published

**Lifecycle:**
- Arise: publish-release creates after bake/sign/upload
- Bond: releases → oikos-prod, published-to → channel
- Traverse: succeeds chain for version history

### release-channel

A publication channel with update semantics.

**Fields:**
- `name` — channel identifier
- `description` — channel purpose
- `auto_update` — whether reconciler auto-updates
- `requires_attestation` — whether signature required

**Channels:**
- **stable**: Production-ready, auto-update enabled
- **beta**: Feature-complete, opt-in updates
- **alpha**: Experimental, manual updates only
- **canary**: Bleeding edge, for testing

### build-attestation

Cryptographic attestation of build provenance.

**Fields:**
- `builder_persona` — who built
- `build_timestamp` — when built
- `source_hash` — hash of oikos-dev content
- `output_hash` — hash of oikos-prod content
- `signature` — Ed25519 signature
- `builder_pubkey` — verification key

## Bonds (Desmoi)

### publishes

Persona publishes an oikos-release.

- **From:** persona
- **To:** oikos-release
- **Cardinality:** one-to-many
- **Traversal:** Find releases by a publisher

### releases

Oikos-release contains an oikos-prod.

- **From:** oikos-release
- **To:** oikos-prod
- **Cardinality:** many-to-one
- **Traversal:** Find what's in a release

### published-to

Oikos-release is published to a channel.

- **From:** oikos-release
- **To:** release-channel
- **Cardinality:** many-to-one
- **Traversal:** Find releases in a channel

### succeeds

Oikos-release supersedes a previous release.

- **From:** oikos-release
- **To:** oikos-release
- **Cardinality:** one-to-one
- **Traversal:** Walk version history

### attests

Attestation covers an oikos-prod.

- **From:** build-attestation
- **To:** oikos-prod
- **Cardinality:** one-to-one
- **Traversal:** Verify build provenance

### distributed-by

Oikos-release is distributed through a circle.

- **From:** oikos-release
- **To:** circle
- **Cardinality:** many-to-many
- **Traversal:** Find distribution channels

## Operations (Praxeis)

### bake-oikos

Transform oikos-dev → oikos-prod. Resolves generation specs, freezes content, computes hashes.

### sign-oikos

Sign an oikos-prod with publisher's key. Creates build-attestation.

### upload-oikos

Upload oikos-prod content to storage (R2). Populates fetch_url.

### publish-release

Create a release and optionally distribute via circles.

### list-releases

List releases for an oikos, optionally filtered by channel.

### verify-release

Verify a release's signatures and hashes.

## Attainments

### attainment/publish

Publication capability — can bake, sign, upload, and publish releases.

- **Grants:** bake-oikos, sign-oikos, upload-oikos, publish-release, verify-release, list-releases
- **Scope:** circle
- **Rationale:** Publishing affects what circle members receive; requires trust

## Embodiment

### Completeness Status

| Level | Status |
|-------|--------|
| Defined | 3 eide, 6 desmoi, 6 praxeis |
| Loaded | ✅ Bootstrap loads all definitions |
| Projected | ✅ All praxeis visible as MCP tools |
| Embodied | ⏳ Body-schema pending |
| Surfaced | ⏳ Publication reconciler pending |
| Afforded | ⏳ Publishing UI pending |

### Body-Schema Contribution

When sense-body gathers ekdosis state:

```yaml
publication:
  publishable_oikoi: 2
  pending_releases: 1
  channels_available: [stable, beta]
  recent_publications: 3
```

This reveals publication readiness and history.

### Reconciler

An ekdosis reconciler would surface:

- **Ready to publish** — "oikos-dev/my-oikos is ready to publish"
- **New version available** — "ekdosis 0.2.0 available (you have 0.1.0)"
- **Signature expired** — "Release signature older than 90 days"
- **Distribution opportunity** — "3 circles could receive this release"

## Compound Leverage

### amplifies oikos

Oikos packages are what ekdosis publishes. The oikos-dev → oikos-prod flow.

### amplifies dynamis

Dynamis handles binary releases (Thyra app). Ekdosis handles content releases (oikoi). Complementary territories.

### amplifies hypostasis

Signing requires keyring. Publisher identity traces through bonds.

### amplifies politeia

Circle distribution uses circle membership. Attainments gate publishing.

### amplifies propylon

Authentication via session. Signing key from keyring.

## The Publication Flow

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
│ oikos-release│────►│   circle    │ (distributed-by bond)
└──────────────┘     └─────────────┘
```

## Theoria

### T18: Oikos embodiment requires body-schema contribution

When an animus has the capability to publish, sense-body should reflect this. Capabilities become visible through the body, not just through explicit queries.

### T19: Reconcilers surface opportunities, not just drift

The oikos reconciler surfaces consumption opportunities. A publication reconciler surfaces creation opportunities. Reconcilers reveal what's possible, not just what's misaligned.

### T20: Attainments make capabilities discoverable

Publishing requires `attainment/publish`. This makes the capability visible through the authorization graph. The kosmos can answer: "What can I do here?"

## Future Extensions

### Generative Commons

Share oikos-dev (with generation specs) for others to bake locally with their own context.

### Differential Updates

Only transfer changed entities, not entire oikos packages.

### Rollback

Revert to previous release via succeeds chain.

### Announcements

Notify circle members of new releases via expressions.

---

*Composed in service of the kosmogonia.*
*Publication makes private public. Circles carry content to members.*
