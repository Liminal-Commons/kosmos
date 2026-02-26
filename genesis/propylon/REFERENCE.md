<!-- =============================================================================
<!-- GENERATED FILE - DO NOT EDIT DIRECTLY -->
<!-- =============================================================================
<!-- Emitted by: emit_cycle (demiurge/emit-genesis) -->
<!-- Source: genesis/propylon/REFERENCE.md -->
<!-- -->
<!-- To modify: -->
<!--   1. Edit the source in genesis/ -->
<!--   2. Re-run emit-genesis -->
<!-- -->
<!-- See: genesis/EXTENDING.md -->
<!-- =============================================================================

# Propylon Reference

the gateway, the entrance before the entrance.

---

## Eide (Entity Types)

### propylon-link

Shareable invitation link. Encodes everything needed to attempt entry.

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `bootstrap` | string | ✓ | Gateway URL (e.g., wss://propylon.liminalcommons.com) |
| `oikos_id` | string | ✓ | Target oikos for entry |
| `created_at` | timestamp | ✓ |  |
| `display` | object |  | Human-readable metadata for link previews |
| `expires_at` | timestamp |  |  |
| `invitation_id` | string | ✓ | Reference to the invitation entity |
| `inviter_id` | string | ✓ | Prosopon ID of the inviter |
| `inviter_pubkey` | string | ✓ | Ed25519 public key for signature verification |
| `max_uses` | number |  |  |
| `require_approval` | boolean |  |  |
| `revoked_at` | timestamp |  |  |
| `signature` | string | ✓ | Ed25519 signature over invitation_id |
| `status` | enum | ✓ |  |
| `use_count` | number |  | Number of times this link has been used |

### propylon-relay

WebSocket signaling relay for entry handshakes. Each commons operates

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `bootstrap_url` | string | ✓ | WebSocket endpoint (e.g., wss://propylon.liminalcommons.com) |
| `config` | object |  | Substrate-specific configuration |
| `deployed_at` | timestamp |  |  |
| `name` | string | ✓ | Relay identifier (e.g., 'liminal') |
| `status` | enum | ✓ |  |
| `substrate` | enum | ✓ | Where the relay runs |
| `version` | string |  | Deployed version (git tag or commit) |

### propylon-session

Authentication session. Tracks challenge-response flow.

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `parousia_id` | string |  | Created parousia ID after successful auth |
| `approved_at` | timestamp |  |  |
| `approved_by` | string |  |  |
| `authenticated_at` | timestamp |  |  |
| `challenge_expires` | timestamp | ✓ |  |
| `oikos_id` | string | ✓ | Target oikos |
| `created_at` | timestamp | ✓ |  |
| `entrant_pubkey` | string |  | Public key of the entrant (known for returning entry) |
| `invitation_id` | string | ✓ | Which invitation is being used |
| `nonce` | string | ✓ | Challenge nonce to sign |
| `prosopon_name` | string |  | Display name for new prosopon |
| `rejected_at` | timestamp |  |  |
| `rejected_by` | string |  |  |
| `rejection_reason` | string |  |  |
| `require_approval` | boolean |  |  |
| `status` | enum | ✓ |  |

## Praxeis (Operations)

🔧 = Exposed as MCP tool

### approve-entry 🔧

Approve a pending entry request.

**Tier:** 2 | **ID:** `praxis/propylon/approve-entry`

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `session_id` | string | ✓ | The pending session to approve |

### challenge-entry 🔧

Issue an authentication challenge for entry.

**Tier:** 2 | **ID:** `praxis/propylon/challenge-entry`

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `encoded` | string | ✓ | The encoded invitation link |
| `entrant_pubkey` | string |  | Existing public key (for returning entry) |

### create-link 🔧

Create a shareable invitation link for an oikos.

**Tier:** 2 | **ID:** `praxis/propylon/create-link`

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `oikos_id` | string | ✓ | Oikos to invite to |
| `message` | string |  | Optional message to include |
| `expires_in_days` | number |  | Days until expiration (default 7) |
| `max_uses` | number |  | Maximum uses (omit for unlimited) |
| `require_approval` | boolean |  | Whether inviter must approve (default false) |

### create-self-link 🔧

Create a self-invite link for device synchronization.

**Tier:** 2 | **ID:** `praxis/propylon/create-self-link`

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `oikos_id` | string | ✓ | Oikos to sync (typically home oikos) |
| `expires_in_days` | number |  | Days until expiration (default 30) |
| `label` | string |  | Optional label for this link (e.g., "laptop", "phone backup") |

### decode-link 🔧

Decode a URL-safe propylon link string to its components.

**Tier:** 1 | **ID:** `praxis/propylon/decode-link`

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `encoded` | string | ✓ | The encoded link string |

### encode-link

Encode a propylon-link entity to URL-safe string.

**Tier:** 1 | **ID:** `praxis/propylon/encode-link`

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `link_id` | string | ✓ | The propylon-link entity ID |

### list-entry-audit 🔧

Query entry history for an oikos.

**Tier:** 1 | **ID:** `praxis/propylon/list-entry-audit`

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `oikos_id` | string | ✓ | Oikos to query |
| `status` | string |  | Filter by status (challenged, authenticated, failed, pending_approval) |
| `limit` | number |  | Maximum results (default 50) |

### reject-entry 🔧

Reject a pending entry request.

**Tier:** 2 | **ID:** `praxis/propylon/reject-entry`

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `session_id` | string | ✓ | The pending session to reject |
| `reason` | string |  | Reason for rejection |

### revoke-link 🔧

Revoke an invitation link.

**Tier:** 2 | **ID:** `praxis/propylon/revoke-link`

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `invitation_id` | string | ✓ | The invitation to revoke |

### validate-link 🔧

Validate an invitation link.

**Tier:** 2 | **ID:** `praxis/propylon/validate-link`

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `encoded` | string | ✓ | The encoded link string |

### verify-entry 🔧

Verify entry response and complete authentication.

**Tier:** 2 | **ID:** `praxis/propylon/verify-entry`

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `session_id` | string | ✓ | The propylon-session ID |
| `signed_nonce` | string | ✓ | Signature of the nonce |
| `entrant_pubkey` | string | ✓ | Public key that signed the nonce |
| `prosopon_name` | string |  | Display name for new prosopon (first-time entry) |

## Desmoi (Bond Types)

| Desmos | From → To | Description |
|--------|-----------|-------------|
| `authenticated-via` | parousia → propylon-session | Parousia authenticated through a propylon-session |
| `connects-via` | propylon-session → propylon-relay | A propylon-session connected through a propylon-relay |
| `grants-entry-to` | propylon-link → oikos | A propylon-link grants entry to an oikos |
| `operates-relay` | oikos → propylon-relay | An oikos operates a propylon-relay. The relay is commons infrastructure |
| `used-link` | propylon-session → propylon-link | A propylon-session used a propylon-link for entry |

---

*Generated from schema definitions. Do not edit directly.*
