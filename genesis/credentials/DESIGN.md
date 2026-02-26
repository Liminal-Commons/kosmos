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
- **Scope control**: Prosopon or oikos level access

The central concept is **the capability bridge** — external credentials become internal attainments.

## Oikos Context

### Self Oikos

A solitary dweller uses credentials to:
- Store personal API keys securely
- Unlock capabilities for a session
- Manage multiple service accounts
- Track usage of external services

Personal credentials are private capability.

### Peer Oikos

Collaborators use credentials to:
- Share oikos-scoped credentials
- Coordinate API key rotation
- Audit credential usage
- Manage team service accounts

Peer credentials are shared resources.

### Commons Oikos

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
- `scope` — who can use (prosopon, oikos)
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

### owned-by (from politeia)

Credential owned by prosopon or oikos.

- **From:** credential
- **To:** prosopon or oikos
- **Semantics:** This credential belongs to this owner

### authenticates (from soma)

Credential authenticates a provider.

- **From:** credential
- **To:** provider
- **Semantics:** This credential grants access to this provider's API
- **Traversal:** Which provider does this credential authenticate? What credentials can access this provider?
- **Note:** The `authenticates` desmos connects the credentials topos to the inference substrate. When a credential entity's `service` field matches a provider entity's `credential_config.service`, this bond makes the relationship graph-traversable.

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
- **Scope:** prosopon
- **Rationale:** Credentials are personal; only the owner manages them

### Dynamic attainments (granted by credentials)

When a credential is unlocked, it grants its `grants_attainment` value. These attainments are defined by provider entities in soma — each provider's `credential_config.grants_attainment` field declares what capability the credential unlocks:

- `use-anthropic-api` — granted by Anthropic credentials (provider/anthropic)
- `use-openai-api` — granted by OpenAI credentials (provider/openai)
- `use-storage-api` — granted by Cloudflare R2 credentials
- `use-dns-api` — granted by DNS provider credentials

These are checked by praxeis requiring external services. The attainment name comes from the provider entity, not from credential code — adding a new provider automatically defines its attainment.

## Embodiment

### Completeness Status

| Level | Status |
|-------|--------|
| Defined | 1 eidos, 1 attainment via hypostasis |
| Loaded | Bootstrap loads definition |
| Projected | Praxeis visible as MCP tools |
| Embodied | Encryption implemented, credential-manager widget discovers providers from graph |
| Surfaced | Credential-manager widget in settings panel |
| Afforded | Future — one-click unlock |

### Body-Schema Contribution

When sense-body gathers credential state:

```yaml
credentials:
  stored_count: 5
  unlocked_count: 3
  granted_attainments:
    - use-anthropic-api
    - use-openai-api
    - use-storage-api
  services: ["anthropic", "openai", "cloudflare"]
```

This reveals session capability state.

## Compound Leverage

### amplifies hypostasis

Hypostasis provides kleidoura (encrypted keyring); credentials extends this pattern to external services. Same encryption, different purpose.

### amplifies soma/inference

Soma's provider entities define what services exist. Credentials grants provider-specific attainments (e.g., `use-anthropic-api`) which inference steps check before calling APIs. No credential → no inference. The credential-manager widget discovers providers from the graph via `gatherEntities("provider")`.

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

Whether capability comes from oikos membership (politeia) or credential unlock (credentials), praxeis check attainments uniformly. The source differs; the check is the same.

### T82: Provider entities make credential config graph-driven

Credential service presets (what to call the service, how to label it, what attainment to grant) are not hardcoded in the UI — they come from provider entities in the graph. The credential-manager widget discovers providers via `gatherEntities("provider")` and reads `credential_config` from each. Adding a provider to genesis automatically updates the credential UI.

---

*Composed in service of the kosmogonia.*
*External access through internal capability. The bridge is credentials.*
