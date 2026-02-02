# Credentials Design

External service credentials — API keys and their attainment integration

## Ontological Purpose

Credentials addresses **the gap between external service access and kosmos capability** — how API keys become attainments.

Without credentials:
- API keys stored in plaintext
- No connection between keys and capabilities
- Manual key management
- No session-based access control

With credentials:
- **Encrypted storage**: AES-256-GCM at rest
- **Attainment integration**: Unlocked key → granted capability
- **Session lifecycle**: Unlock → use → lock
- **Scope control**: Persona or circle level access

The central concept is **the capability bridge** — external credentials become internal attainments.

## Circle Context

### Self Circle

A solitary dweller uses credentials to:
- Store personal API keys securely
- Unlock capabilities for a session
- Manage multiple service accounts
- Track usage of external services

Personal credentials are private capability.

### Peer Circle

Collaborators use credentials to:
- Share circle-scoped credentials
- Coordinate API key rotation
- Audit credential usage
- Manage team service accounts

Peer credentials are shared resources.

### Commons Circle

A commons uses credentials to:
- Define credential policies
- Manage organization-wide keys
- Monitor usage quotas
- Handle key rotation at scale

Commons credentials are infrastructure.

## Core Entities (Eide)

### credential

An encrypted external service credential with attainment integration.

**Fields:**
- `service` — service provider (e.g., 'openai', 'anthropic', 'cloudflare')
- `credential_type` — type (api-key, oauth-token, bearer-token, access-key)
- `encrypted_value` — AES-256-GCM encrypted value (base64)
- `salt` — per-credential salt for key derivation
- `label` — human-readable label (e.g., 'My OpenAI Key')
- `scope` — who can use (persona, circle)
- `grants_attainment` — attainment granted when unlocked
- `status` — active, revoked, expired
- `last_used_at` — tracking
- `expires_at` — optional expiration

**Session flow:**
1. User provides password → session unlocks
2. Credentials decrypt into memory (chora, not kosmos)
3. Session gains attainments from unlocked credentials
4. Praxeis check attainments before using services
5. Session lock → credentials cleared → attainments removed

## Bonds (Desmoi)

Credentials uses bonds defined elsewhere:

### owned-by (from politeia)

Credential owned by persona or circle.

- **From:** credential
- **To:** persona or circle
- **Semantics:** This credential belongs to this owner

## Operations (Praxeis)

*Praxeis remain in hypostasis namespace as parent.*

### add-credential

Store a new encrypted credential.

- **When:** User adds API key
- **Requires:** manage-credentials attainment
- **Provides:** Credential entity with encrypted value

### remove-credential

Remove a stored credential.

- **When:** User revokes key
- **Requires:** manage-credentials attainment
- **Provides:** Credential marked revoked

### unlock-credential (session operation)

Decrypt credential into session memory.

- **When:** Session unlock with password
- **Requires:** Session password
- **Provides:** Attainment granted for session duration

### list-credentials

List credentials (without values).

- **When:** Managing credentials
- **Provides:** Credential metadata

## Attainments

### attainment/manage-credentials (defined in hypostasis)

Capability to add and remove external service credentials.

- **Grants:** add-credential, remove-credential
- **Scope:** persona
- **Rationale:** Credentials are personal; only the owner manages them

### Dynamic attainments (granted by credentials)

When a credential is unlocked, it grants its `grants_attainment` value:

- `use-embedding-api` — granted by OpenAI/Anthropic credentials
- `use-storage-api` — granted by Cloudflare R2 credentials
- `use-dns-api` — granted by DNS provider credentials

These are checked by praxeis requiring external services.

## Embodiment

### Completeness Status

| Level | Status |
|-------|--------|
| Defined | 1 eidos, 1 attainment via hypostasis |
| Loaded | Bootstrap loads definition |
| Projected | Praxeis visible as MCP tools |
| Embodied | Partial — encryption implemented |
| Surfaced | Future — credential manager UI |
| Afforded | Future — one-click unlock |

### Body-Schema Contribution

When sense-body gathers credential state:

```yaml
credentials:
  stored_count: 5
  unlocked_count: 3
  granted_attainments:
    - use-embedding-api
    - use-storage-api
  services: ["openai", "cloudflare"]
```

This reveals session capability state.

## Compound Leverage

### amplifies hypostasis

Hypostasis provides kleidoura (encrypted keyring); credentials extends this pattern to external services. Same encryption, different purpose.

### amplifies manteia

Manteia needs LLM access. Credentials grants `use-embedding-api` which manteia checks before calling inference. No credential → no inference.

### amplifies dynamis

Dynamis distribution needs storage access. Credentials grants `use-storage-api` which dynamis checks before uploading. No credential → no distribution.

### amplifies thyra/dns

DNS operations need provider access. Credentials grants `use-dns-api` which dns praxeis check. No credential → no DNS changes.

## Theoria

### T79: Credentials are capability bridges

External services exist outside kosmos. Credentials bridge that gap by transforming encrypted secrets into attainments. The credential itself is never exposed; only the capability is granted.

### T80: Session is the trust boundary

Credentials live encrypted in kosmos. Decrypted values exist only in chora session memory. Session lock clears decrypted values. This creates a clear trust boundary: kosmos stores, chora uses, session controls.

### T81: Attainment unifies capability sources

Whether capability comes from circle membership (politeia) or credential unlock (credentials), praxeis check attainments uniformly. The source differs; the check is the same.

---

*Composed in service of the kosmogonia.*
*External access through internal capability. The bridge is credentials.*
