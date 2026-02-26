# Propylon Design

πρόπυλον (propylon) — the gateway, the entrance before the entrance

## Ontological Purpose

Propylon addresses **the gap between outside and inside** — the passage through which beings enter the kosmos while preserving sovereignty.

Without propylon:
- Entry requires external identity providers
- Invitation links depend on centralized infrastructure
- Authentication creates surveillance points
- Device federation requires account systems

With propylon:
- **Self-contained links**: Everything needed is in the URL
- **Self-validating links**: Signature proves origin without lookup
- **Dumb relay**: Just forwards signaling, stores nothing
- **Human verification**: The call IS the verification
- **Device federation**: Same identity, multiple substrates

The relay forgets. The link is primary. Channels are orthogonal.

## Oikos Context

### Self Oikos

A solitary dweller uses propylon to:
- Create self-sync links for device federation
- Store links in password managers for recovery
- Restore identity from mnemonic + link combination

Self-federation enables a single prosopon across multiple devices.

### Peer Oikos

Collaborators use propylon to:
- Create invitation links for new members
- Share links via any channel (QR, SMS, email, Signal)
- Verify entrants via video call (human authentication)
- Approve or reject pending entry requests

The call IS the verification — you see and hear the person.

### Commons Oikos

A commons oikos uses propylon to:
- Operate a signaling relay for their community
- Define entry policies for public oikoi
- Audit entry history for security
- Distribute self-sync links to established members

Commons relays are infrastructure — shared, replaceable, not controlling.

## Core Entities (Eide)

### propylon-link

Shareable invitation encoding — everything needed to attempt entry.

**Fields:**
- `invitation_id` — Reference to invitation entity
- `bootstrap` — Relay URL for signaling
- `oikos_id` — Target oikos
- `inviter_id`, `inviter_pubkey` — Inviter identity
- `signature` — Ed25519 signature over invitation_id
- `display` — Human-readable metadata
- `expires_at`, `max_uses`, `require_approval` — Constraints
- `status` — active, used, expired, revoked
- `use_count` — Usage tracking

**Lifecycle:**
- Arise: create-link or create-self-link composes the link
- Use: Each entry increments use_count
- Depart: Expires, reaches max_uses, or is revoked

### entry-request

Incoming entry request from inviter's perspective.

**Fields:**
- `peer_id` — WebRTC peer ID of entrant
- `invitation_id` — Which invitation they're using
- `oikos_name`, `entrant_name`, `entrant_prosopon_id` — Display info
- `timestamp` — When received
- `status` — pending, verifying, approved, rejected

**Lifecycle:**
- Arise: When someone attempts to join via link
- Change: Status progresses through verification
- Depart: Resolved (approved or rejected)

### propylon-session

Authentication state machine — tracks challenge-response flow.

**Fields:**
- `invitation_id`, `oikos_id` — Context
- `nonce` — Challenge to sign
- `entrant_pubkey` — For returning entry
- `status` — challenged, pending_approval, authenticated, rejected, failed, expired
- `challenge_expires` — Challenge timeout
- `require_approval` — Whether inviter must confirm
- `parousia_id` — Created parousia after success
- `prosopon_name` — Display name for new prosopon

**Lifecycle:**
- Arise: challenge-entry creates session with nonce
- Change: verify-entry advances state
- Complete: authenticated → parousia created
- Fail: rejected, failed, or expired

### propylon-relay

WebSocket signaling infrastructure.

**Fields:**
- `name` — Relay identifier
- `bootstrap_url` — WebSocket endpoint
- `substrate` — cloudflare-workers, nixos-service, docker, other
- `status` — active, degraded, offline, deploying
- `deployed_at`, `version`, `config` — Deployment metadata

**Lifecycle:**
- Arise: create-relay defines infrastructure
- Actualize: Deploy via dynamis patterns
- Sense: Check relay health

### session-token

JWT for cross-process session sharing.

**Fields:**
- `prosopon_id` — Authenticated prosopon
- `oikoi` — Accessible oikos IDs
- `attainments` — Unlocked capabilities
- `issued_at`, `expires_at` — Validity window
- `signature` — Ed25519 over payload

**Lifecycle:**
- Arise: create-session-token on keyring unlock
- Use: MCP reads from OS credential store
- Depart: Expires or keyring locks

## Bonds (Desmoi)

### grants-entry-to

Link grants entry to an oikos.

- **From:** propylon-link
- **To:** oikos
- **Cardinality:** many-to-one
- **Traversal:** Find which oikos a link grants access to

### authenticated-via

Parousia was authenticated via this session.

- **From:** parousia
- **To:** propylon-session
- **Cardinality:** many-to-one
- **Traversal:** Audit how a parousia entered

### used-link

Session used this invitation link.

- **From:** propylon-session
- **To:** propylon-link
- **Cardinality:** many-to-one
- **Traversal:** Track which link was used for entry

### operates-relay

Oikos operates this relay.

- **From:** oikos
- **To:** propylon-relay
- **Cardinality:** one-to-many
- **Traversal:** Find relays operated by a commons

### connects-via

Parousia connects via this relay.

- **From:** parousia
- **To:** propylon-relay
- **Cardinality:** many-to-one
- **Traversal:** Track connection infrastructure

## Operations (Praxeis)

### create-link

Create a shareable invitation link.

- **When:** Inviting someone to an oikos
- **Requires:** invite attainment
- **Provides:** Encoded URL, shareable link

### create-self-link

Create a self-invite for device federation.

- **When:** Setting up a new device
- **Requires:** invite attainment
- **Provides:** Self-sync link with longer expiry

### decode-link / validate-link

Decode and validate an invitation link.

- **When:** Processing an incoming link
- **Requires:** enter attainment
- **Provides:** Link components, validation result

### challenge-entry

Issue authentication challenge.

- **When:** Entrant presents valid link
- **Requires:** enter attainment
- **Provides:** Session with nonce to sign

### verify-entry

Complete authentication, create parousia.

- **When:** Entrant signs challenge
- **Requires:** enter attainment
- **Provides:** Authenticated session, parousia, connection info

### approve-entry / reject-entry

Approve or reject pending entry request.

- **When:** Entry requires inviter approval
- **Requires:** approve attainment
- **Provides:** Resolution of pending request

### revoke-link

Revoke an invitation link.

- **When:** Link should no longer be valid
- **Requires:** invite attainment
- **Provides:** Revoked status

### list-entry-audit

Query entry history for an oikos.

- **When:** Auditing who entered when
- **Requires:** audit attainment
- **Provides:** Session history

### create-session-token / validate-session-token

Cross-process session management.

- **When:** Thyra unlocks, MCP starts
- **Requires:** session attainment
- **Provides:** JWT for credential store

## Attainments

### attainment/manage-links

Link management capability — creating and managing invitation links.

- **Grants:** create-link, create-self-link, revoke-link
- **Scope:** oikos
- **Rationale:** Creating invitations is a sovereign act within an oikos

### attainment/enter

Entry capability — using links to attempt entry.

- **Grants:** decode-link, validate-link, challenge-entry, verify-entry
- **Scope:** global (anyone with a link can attempt entry)
- **Rationale:** Entry flow requires no prior membership

### attainment/approve

Approval capability — resolving pending entry requests.

- **Grants:** approve-entry, reject-entry
- **Scope:** oikos
- **Rationale:** Only oikos members can approve/reject

### attainment/audit

Audit capability — viewing entry history.

- **Grants:** list-entry-audit
- **Scope:** oikos
- **Rationale:** Entry history is sensitive; requires authorization

### attainment/session

Session management capability — cross-process authentication.

- **Grants:** create-session-token, validate-session-token
- **Scope:** soma (local substrate)
- **Rationale:** Session tokens are substrate-local, not oikos-scoped

## Embodiment

### Completeness Status

| Level | Status |
|-------|--------|
| Defined | ✅ 5 eide, 5 desmoi, 13 praxeis |
| Loaded | ✅ Bootstrap loads all definitions |
| Projected | ✅ All praxeis visible as MCP tools |
| Embodied | ⏳ Body-schema contribution pending |
| Surfaced | ⏳ Reconciler not yet implemented |
| Afforded | ⏳ Thyra entry affordances pending |

### Body-Schema Contribution

When sense-body gathers propylon state:

```yaml
entry:
  pending_requests: 2      # Awaiting approval
  active_links: 5          # Not expired/revoked
  sessions_today: 3        # Entry attempts
  relay_status: active     # Connected relay
```

This reveals entry activity and pending approvals.

### Reconciler

A propylon reconciler would surface:

- **Pending approvals** — "2 entry requests awaiting your approval"
- **Expiring links** — "Self-sync link expires in 3 days"
- **Unused links** — "5 links created but never used"
- **Failed entries** — "3 entry attempts failed today"

## Compound Leverage

### amplifies hypostasis

Entry requires key derivation and signing. Mnemonic restores identity.

### amplifies soma

Parousia arises through soma/arise-parousia after authentication.

### amplifies politeia

Oikos membership is created via entry. Governance determines who can invite.

### amplifies aither

WebRTC signaling flows through relay before P2P handoff.

### amplifies thyra

Entry UI (video call, approval) renders in thyra.

## Theoria

### T47: Links are primary, channels are orthogonal

The invitation link encodes everything needed. How you share it (QR, SMS, email) is a separate concern. The link is the thing; the channel is just transport.

### T48: Human verification is the highest assurance

For trusted peer entry, eyes and ears prove identity better than cryptography. The video call IS the verification — no challenge-response needed when you see and hear the person.

### T49: Sovereignty includes the right to lose everything

The mnemonic stays with the user. If lost, you're gone. This is the cost of sovereignty — no administrator can recover your identity.

## Future Extensions

### WebAuthn Support

Hardware key authentication (YubiKey) for local unlock. Adds security without solving discovery.

### Domain-Based Discovery

Human-friendly addresses like `victor@liminalcommons.com` resolving to bootstrap info via `.well-known/kosmos`.

### Social Recovery

Trusted peers can regenerate invitations. This is an oikos governance feature, not infrastructure.

### Relay Federation

Multiple relays coordinating for availability. Currently single-relay per link.

---

*Composed in service of the kosmogonia.*
*Links are primary. Channels are orthogonal. The relay forgets.*
