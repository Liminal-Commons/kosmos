# Hypostasis: Substrate Replication

*Phase 25 — ὑπόστασις (hypostasis): underlying reality, that which stands beneath*

---

## Purpose

Hypostasis enables the kosmos to replicate itself — the same circle across multiple devices, backup and recovery, content-addressed authenticity. This is self-constitution: the substrate that can reconstitute itself.

**Key insight:** Phoreta are the universal format. Federation, backup, and recovery all use the same signed bundle structure.

---

## Current State

V8 has **working SQLite persistence**:

```
.chora/kosmos.db
├── entities table (id, eidos, data, version, timestamps, embedding)
└── bonds table (from_id, to_id, desmos, data)
```

**What exists:**
- Single-file database
- Entity/bond storage
- Embedding storage (inline BLOB)
- Basic versioning (integer increment)

**What's missing:**
- Content-addressed IDs (hash-based)
- Composition chain verification
- Genesis signing (threshold signatures)
- Circle-scoped encryption
- Phoreta export/import
- Multi-device sync
- Migration strategy

---

## Core Concepts

### Two Pillars of Kosmos Security

1. **Visibility = Reachability** — You can only perceive what you can cryptographically reach through the bond graph.

2. **Authenticity = Provenance** — Everything you reach is verifiably derived from signed genesis.

Both are structural, not policy. Both are mathematical, not hopeful.

### Content-Addressed Identity

Entity identity includes content hash:

```
theoria/insight-slug@blake3:7f3a2b...
```

The hash covers:
- Entity content (data)
- Composed-from reference
- Timestamp of composition

Modification changes the hash. Different hash = different entity. Tampering is not hidden; it creates a visibly different thing.

### The Composition Chain

Every entity traces back to signed genesis:

```
my-theoria@hash1
    │
    └─► composed-from: typos-def-theoria@hash2
            │
            └─► composed-from: oikos/demiurge@hash3
                    │
                    └─► composed-from: genesis@hash4
                            │
                            └─► signed-by: [key1, key2, key3]
                                    │
                                    └─► kosmogonia (constitutional root)
```

Verification: walk the chain, verify each hash, terminate at multi-signed genesis.

### Genesis Signing

Genesis is not signed by a single authority. It uses threshold signatures:

```
Genesis validity requires: 3-of-5 known signers

Signer 1: [public key, attestation]
Signer 2: [public key, attestation]
Signer 3: [public key, attestation]
Signer 4: [public key, attestation]
Signer 5: [public key, attestation]
```

No single party can forge genesis. Compromise of one or two keys does not compromise authenticity.

### Phoreta: Universal Transport

Phoreta are signed bundles of state changes — the vessels that carry reality between sovereign spaces.

```yaml
phoreta:
  id: string
  origin_chora: string          # Where this came from
  entities: [object]            # Entities being transported
  bonds: [object]               # Bonds being transported
  signature: string             # Ed25519 signature over content
  signed_by: string             # Persona who signed
  created_at: timestamp
```

**Same format for:**
- Backup (export to file)
- Recovery (import from file)
- Federation (sync between circles)
- Archive (cold storage)

### Circle-Scoped Encryption

Each circle has encryption keys derived from root:

```
mnemonic (BIP-39)
    │
    └─► master keypair (ed25519)
            │
            ├─► persona key (derived for identity)
            │
            └─► circle keys (derived per circle membership)
                    │
                    └─► session keys (ephemeral, per session)
```

Key derivation mirrors trust derivation. The social structure and the cryptographic structure are the same structure.

### Kleidoura: Encrypted Keyring

**The Problem:** Currently, signing operations require the raw mnemonic each time. This is secure but has terrible UX for frequent operations (creating invites, signing expressions).

**The Solution:** Password-protected encrypted seed storage.

```
First Use (Setup):
  mnemonic (24 words)
      ↓
  derive master seed (BIP-39)
      ↓
  password → Argon2id → encryption_key
      ↓
  AES-256-GCM encrypt master_seed
      ↓
  store encrypted blob in kleidoura entity

Session Unlock:
  password → derive encryption_key
      ↓
  decrypt master_seed
      ↓
  master_seed stays in memory (process state, not kosmos)
      ↓
  all circle keys derivable without re-prompting

Auto-Lock:
  - App close → memory cleared
  - Timeout (configurable) → memory cleared
  - Explicit lock action
```

**Security Model:**

| Layer | Protection |
|-------|------------|
| Mnemonic → Master Seed | BIP-39 derivation (irreversible) |
| Password → Encryption Key | Argon2id with per-keyring salt |
| Encrypted Seed | AES-256-GCM with authenticated encryption |
| Circle Keys | Derived from master seed + circle_id (HKDF) |

**What's Stored Where:**

| Data | Location | Encrypted |
|------|----------|-----------|
| Mnemonic | Nowhere (user memory only) | N/A |
| Master seed (encrypted) | kleidoura entity | ✅ AES-256-GCM |
| Master seed (decrypted) | Process memory (chora) | In-memory only |
| Circle keys | Derived on-demand | Never stored |
| Password | Nowhere | N/A |
| Salt | kleidoura entity | No (public) |

**Key Insight:** Session state lives in chora (process memory), not kosmos (entities). Even if kosmos.db is copied, the seed requires the password to decrypt. This follows T16: Session state lives in chora, not kosmos.

**Kleidoura Praxeis:**

| Praxis | Purpose |
|--------|---------|
| `hypostasis/create-keyring` | Encrypt mnemonic with password, create kleidoura entity |
| `hypostasis/unlock-keyring` | Decrypt seed, store in session (process memory) |
| `hypostasis/lock-keyring` | Clear session, remove from memory |
| `hypostasis/check-keyring-status` | Check if session is unlocked |
| `hypostasis/change-keyring-password` | Re-encrypt with new password |
| `hypostasis/sign-with-session` | Sign content using unlocked session key |
| `hypostasis/derive-key-from-session` | Derive circle public key from session |

### Credentials: External Service Access with Attainment Integration

Credentials extend the kleidoura pattern to external service API keys. When a credential is unlocked, it grants an **attainment** that praxeis can check before using the service.

**The Problem:** Users need to bring their own API keys (OpenAI, Anthropic, etc.) for features like semantic search. These keys must be:
- Encrypted at rest (like the mnemonic)
- Unlocked into session memory (not stored decrypted)
- Subject to governance (who can use shared keys)

**The Solution:** Credential entities with attainment grants.

```
credential (encrypted in kosmos)
    │
    ├── credential-of ────► persona (who owns it)
    │
    ├── shared-with ──────► circle (optional team access)
    │
    ├── unlocks-attainment ► attainment (what it grants)
    │
    └── enables-function ──► function (what it powers)

On session unlock:
    credentials decrypt → session gains attainments

Praxis requiring API:
    checks has-attainment → uses credential if present
```

**Credential Fields:**

| Field | Type | Purpose |
|-------|------|---------|
| `service` | string | Provider (openai, anthropic, cloudflare) |
| `credential_type` | enum | api-key, oauth-token, bearer-token |
| `encrypted_value` | string | AES-256-GCM encrypted credential |
| `salt` | string | Per-credential encryption salt |
| `label` | string | Human-readable name |
| `scope` | enum | persona (private) or circle (shared) |
| `grants_attainment` | string | Attainment name granted when unlocked |
| `status` | enum | active, revoked, expired |

**Integration with Politeia Attainments:**

Credentials integrate with the governance layer via attainments:

```yaml
# Credential grants attainment
credential/persona/alice/openai:
  service: openai
  grants_attainment: use-embedding-api
  # Bond: unlocks-attainment → attainment/use-embedding-api

# Praxis checks attainment
praxis/nous/index:
  # Uses get-credential-value with required_attainment: use-embedding-api
  # If attainment present, gets API key from session
  # If not, step fails gracefully with helpful message
```

**Session Flow:**

```
1. User unlocks keyring (password)
       ↓
2. hypostasis/unlock-credentials called
       ↓
3. Each credential decrypts → value stored in session memory
       ↓
4. Each credential's attainment granted to session
       ↓
5. Praxeis can now:
   - Check has-attainment before using service
   - Get credential value if attainment present
       ↓
6. Session lock → credentials cleared → attainments removed
```

**Credential Praxeis:**

| Praxis | Purpose |
|--------|---------|
| `hypostasis/add-credential` | Encrypt and store API key, create attainment grant |
| `hypostasis/unlock-credentials` | Decrypt credentials, grant session attainments |
| `hypostasis/get-credential-value` | Get decrypted credential from session (internal) |
| `hypostasis/list-credentials` | List credentials without exposing values |
| `hypostasis/remove-credential` | Revoke credential, remove from session |
| `hypostasis/check-session-attainment` | Check if session has an attainment |

**Security Model:**

| Concern | How It's Addressed |
|---------|-------------------|
| Credential at rest | AES-256-GCM encrypted with session-derived key |
| Credential in use | Lives in session memory only (chora, not kosmos) |
| Who can use | Attainments govern access (persona or circle scope) |
| Credential rotation | Remove old, add new — no migration needed |
| Audit trail | Credential entity tracks last_used_at |

**Key Insight:** Credentials follow the same chora/kosmos separation as kleidoura. The encrypted credential lives in kosmos (entities). The decrypted value lives in chora (process memory). Even if kosmos.db is copied, credentials are protected by the session password.

---

## Database Evolution

### Current Schema

```sql
CREATE TABLE entities (
    id TEXT PRIMARY KEY,
    eidos TEXT NOT NULL,
    data TEXT NOT NULL,
    version INTEGER DEFAULT 1,
    created_at TEXT,
    updated_at TEXT,
    embedding BLOB,
    embedding_text TEXT,
    embedding_model TEXT
);

CREATE TABLE bonds (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    from_id TEXT NOT NULL,
    to_id TEXT NOT NULL,
    desmos TEXT NOT NULL,
    data TEXT,
    created_at TEXT
);
```

### Hypostasis Schema Additions

```sql
-- Content-addressed fields
ALTER TABLE entities ADD COLUMN content_hash TEXT;           -- BLAKE3 hash
ALTER TABLE entities ADD COLUMN composed_from TEXT;          -- Parent entity hash
ALTER TABLE entities ADD COLUMN composition_chain TEXT;      -- JSON array of chain

-- Encryption
ALTER TABLE entities ADD COLUMN encrypted_data BLOB;         -- Encrypted content
ALTER TABLE entities ADD COLUMN encryption_circle TEXT;      -- Which circle's key

-- Signature
ALTER TABLE entities ADD COLUMN signature TEXT;              -- Creator signature
ALTER TABLE entities ADD COLUMN signed_by TEXT;              -- Signing persona

-- Sync tracking
ALTER TABLE entities ADD COLUMN sync_version INTEGER;        -- For conflict detection
ALTER TABLE entities ADD COLUMN sync_origin TEXT;            -- Original source chora

-- Genesis table
CREATE TABLE genesis (
    id TEXT PRIMARY KEY,
    content TEXT NOT NULL,
    content_hash TEXT NOT NULL,
    signatures TEXT NOT NULL,                                -- JSON array of signer signatures
    threshold INTEGER DEFAULT 3,
    created_at TEXT
);

-- Migration tracking
CREATE TABLE schema_versions (
    version INTEGER PRIMARY KEY,
    applied_at TEXT,
    description TEXT
);
```

---

## Implementation Phases

### 25.1: Content-Addressed Entity IDs (Rust)

- Add BLAKE3 hashing to entity creation
- Hash covers: eidos, data, composed_from, timestamp
- Entity ID format: `{eidos}/{slug}@blake3:{hash}`
- Verification on entity read

```rust
fn compute_entity_hash(eidos: &str, data: &Value, composed_from: Option<&str>) -> String {
    let mut hasher = blake3::Hasher::new();
    hasher.update(eidos.as_bytes());
    hasher.update(&serde_json::to_vec(data).unwrap());
    if let Some(cf) = composed_from {
        hasher.update(cf.as_bytes());
    }
    format!("blake3:{}", hasher.finalize().to_hex())
}
```

### 25.2: Composition Chain Storage and Verification

- Store `composed_from` reference on every entity
- Store chain as JSON array for quick verification
- Verify chain integrity on entity access
- Report broken chains

### 25.3: Genesis Structure with Signature Fields

- Create genesis table
- Store multi-signature structure
- Verify threshold on genesis read
- Provide genesis verification praxis

### 25.4: Circle-Scoped Key Derivation

- Implement BIP-39 mnemonic handling
- Derive master keypair (Ed25519)
- Derive circle keys (per membership)
- Store encrypted data with circle key

### 25.5: Phoreta Export Praxis

```yaml
praxis: hypostasis/export-phoreta
params:
  entity_ids: [string]          # Entities to export
  include_dependencies: boolean  # Follow composed-from chains
  encrypt_for_circle: string?    # Optional circle encryption

steps:
  - gather entities and bonds
  - include composition chains
  - sign with persona key
  - encrypt if circle specified
  - return phoreta bundle
```

### 25.6: Phoreta Import Praxis

```yaml
praxis: hypostasis/import-phoreta
params:
  phoreta: object               # The bundle to import
  verify_signatures: boolean    # Verify origin signatures
  merge_strategy: string        # newer_wins, local_wins, fail_on_conflict

steps:
  - verify phoreta signature
  - verify composition chains (all trace to genesis)
  - decrypt if encrypted
  - detect conflicts with local entities
  - apply merge strategy
  - import entities and bonds
  - return import report
```

### 25.7: Self-Federation (Same Persona, Multiple Devices)

Self-federation is the proving ground for infrastructure.

**Three Separate Concerns:**

| Concern | Mechanism | What It Provides |
|---------|-----------|------------------|
| **Identity** | Mnemonic (24 words) | Cryptographic keys (who you are) |
| **Location** | Propylon links | Where to connect (relay URL, circle) |
| **State** | Phoreta bundles | What gets synced (entities, bonds) |

These remain separate. The mnemonic doesn't encode where to connect. Links don't contain state. Phoreta carries state but not identity.

**The Flow:**

```
Device A                              Device B
    │                                      │
    ├── create-self-link ──────────────────┤
    │   (propylon — contains relay URL)    │
    │                                      │
    ├── Store link (password manager) ─────┤
    │                                      │
    │                    Fresh install ◀───┤
    │                                      │
    │                    Enter mnemonic ◀──┤
    │   (identity restored, keys derived)  │
    │                                      │
    │                    Enter link ◀──────┤
    │   (location known, relay contact)    │
    │                                      │
    │◀── WebRTC signaling (relay) ─────────┤
    │                                      │
    ├── pubkey verification ───────────────┤
    │   (same mnemonic = same keys)        │
    │                                      │
    ├── export phoreta ────────────────────┤
    │   (full state or delta)              │
    │                                      │
    │                    import phoreta
    │                    verify chains
    │                    merge state
    │                                      │
    └────────────── sync complete ─────────┘
```

**What flows in phoreta:**
- All entities visible to persona
- All bonds involving those entities
- Composition chains for verification

**Conflict resolution:**
- `newer_wins` — timestamp comparison
- `local_wins` — preserve local state
- `manual` — surface conflicts for resolution

**Recovery Paths:**

| What's Available | Recovery Path |
|------------------|---------------|
| Mnemonic + saved link | Full restore via self-federation |
| Mnemonic only | Identity restored; need peer to re-invite |
| Mnemonic + backup file | Full restore from phoreta (encrypted backup) |
| Nothing | Sovereignty means you can lose everything |

### 25.8: Genesis Signing Ceremony

The ceremony that creates the authentic root:

1. **Identify signers** — 5 trusted individuals/organizations
2. **Generate signing keys** — Each signer creates Ed25519 keypair
3. **Document ceremony** — Record process, attestations
4. **Sign genesis** — Each signer signs the genesis content
5. **Publish** — Genesis with 5 signatures, only 3 required for validity
6. **Verify** — Bootstrap verifies genesis on startup

---

## Praxeis Summary

### Content-Addressed Operations

| Praxis | Purpose |
|--------|---------|
| `hypostasis/compute-hash` | BLAKE3 hash of entity content |
| `hypostasis/verify-chain` | Verify composition chain to genesis |
| `hypostasis/verify-genesis` | Verify genesis signatures |

### Phoreta Operations

| Praxis | Purpose |
|--------|---------|
| `hypostasis/export-phoreta` | Create signed bundle for export |
| `hypostasis/import-phoreta` | Verify and import bundle |
| `hypostasis/create-snapshot` | Full state export |
| `hypostasis/restore-snapshot` | Full state restore |
| `hypostasis/sync-delta` | Export changes since last sync |

### Key Operations

| Praxis | Purpose |
|--------|---------|
| `hypostasis/generate-mnemonic` | Generate new BIP-39 24-word phrase |
| `hypostasis/derive-circle-key` | Derive Ed25519 keypair for circle |
| `hypostasis/sign-content` | Sign content with mnemonic |
| `hypostasis/verify-signature` | Verify signature against public key |

### Encrypted Keyring Operations

| Praxis | Purpose |
|--------|---------|
| `hypostasis/create-keyring` | Encrypt mnemonic with password |
| `hypostasis/unlock-keyring` | Decrypt seed, store in session |
| `hypostasis/lock-keyring` | Clear session memory |
| `hypostasis/check-keyring-status` | Check if session is unlocked |
| `hypostasis/change-keyring-password` | Re-encrypt with new password |
| `hypostasis/sign-with-session` | Sign using unlocked session key |
| `hypostasis/derive-key-from-session` | Derive circle key from session |

### Persona Operations

| Praxis | Purpose |
|--------|---------|
| `hypostasis/export-persona` | Export persona for federation |
| `hypostasis/import-persona` | Import persona from another device |
| `hypostasis/sync-devices` | Bidirectional sync between devices |

### Genesis Ceremony

| Praxis | Purpose |
|--------|---------|
| `hypostasis/begin-genesis-ceremony` | Start multi-signature signing |
| `hypostasis/add-genesis-signature` | Add signer signature |
| `hypostasis/finalize-genesis` | Finalize when threshold reached |
| `hypostasis/get-genesis-status` | Check ceremony progress |

### Credential Operations

| Praxis | Purpose |
|--------|---------|
| `hypostasis/add-credential` | Encrypt and store API key with attainment grant |
| `hypostasis/unlock-credentials` | Decrypt credentials, grant session attainments |
| `hypostasis/get-credential-value` | Get decrypted credential from session (internal) |
| `hypostasis/list-credentials` | List credentials without exposing values |
| `hypostasis/remove-credential` | Revoke credential, remove from session |
| `hypostasis/check-session-attainment` | Check if session has an attainment |

---

## Migration Strategy

### Incremental Migration

```sql
-- Track schema versions
INSERT INTO schema_versions (version, applied_at, description)
VALUES (1, datetime('now'), 'Initial V8 schema');

-- Migration 2: Add content-addressed fields
ALTER TABLE entities ADD COLUMN content_hash TEXT;
-- Backfill: compute hashes for existing entities

INSERT INTO schema_versions (version, applied_at, description)
VALUES (2, datetime('now'), 'Content-addressed entities');
```

### Migration Praxis

```yaml
praxis: hypostasis/migrate-schema
params:
  target_version: number

steps:
  - check current version
  - for each version between current and target:
    - apply migration SQL
    - run backfill if needed
    - record version
  - return migration report
```

---

## Security Considerations

### Structural Guarantees

To capture kosmos, an adversary must:

| Attack | Blocked By |
|--------|------------|
| Forge genesis signatures | Threshold cryptography (3-of-5) |
| Modify entity content | Content-addressed hashes |
| Break composition chain | Chain verification on access |
| Forge traversal rights | Encrypted bond keys |
| Hide modifications | Mutual attestation reveals difference |

Every attack is either cryptographically hard or immediately visible.

### Fork Transparency

If someone creates a modified kosmos:
- Different genesis hash
- Federation verification fails
- Mutual attestation fails
- Users know they're in a fork

They can choose the fork knowingly, but they cannot be deceived into it.

---

## Dependencies

- **Phase 21 (Synecheia):** Working end-to-end infrastructure
- **Phase 18 (Syndesmos):** Phoreta format for federation

---

## Constitutional Alignment

Hypostasis implements the deepest constitutional requirements:

| Principle | How Hypostasis Implements It |
|-----------|------------------------------|
| **Visibility = Reachability** | Phoreta bundles contain only what the exporter can reach. Visibility is structural, enforced by the bond graph. |
| **Authenticity = Provenance** | Content-addressed hashes (BLAKE3) and Ed25519 signatures create unforgeable provenance chains. |
| **Composition Requirement** | Every composed entity has `composed-from` bond. Chains terminate at signed genesis. No orphans. |
| **Full-Circle Genesis** | The kosmos can emit itself, re-bootstrap from emission, and emit again with identical output. Self-verifying coherence. |

**Full-Circle Genesis Verification:**

```
kosmos.db (750+ entities)
     ↓
emit-genesis praxis (demiurge/emit-genesis)
     ↓
chora-output/
├── arche/ (eidos, desmos, stoicheion)
├── spora/ (personas, circles, definitions, praxeis)
└── oikoi/ (dev, prod packages)
     ↓ hash = H1

bootstrap(chora-output/) → kosmos-2.db
     ↓
emit-genesis praxis
     ↓
chora-output-2/
     ↓ hash = H2

assert(H1 == H2) ✓
```

**Caller Pattern:** Hypostasis content is **constitutional** — mnemonic derivation, hash computation, signature verification are literal operations. The algorithms cannot be derived; they are foundational.

---

## Grounding

This design draws from:
- `docs/design/PERSISTENCE.md` (phoreta as universal format)
- `docs/design/CRYPTOGRAPHIC-TOPOLOGY.md` (visibility, authenticity)
- `docs/design/FEDERATION.md` (circle-mediated federation)

---

*Hypostasis is self-constitution — the kosmos that can replicate itself.*
*Traces to: expression/genesis-root*
*Updated: 2026-01-25 — Added credentials with attainment integration for external service access*
