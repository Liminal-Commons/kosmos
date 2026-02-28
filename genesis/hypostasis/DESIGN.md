# Hypostasis Design

ὑπόστασις (hypostasis) — underlying reality, that which stands beneath.

## Ontological Purpose

What gap in being does hypostasis address?

**The gap of identity and authenticity.** Without hypostasis, entities exist but have no verifiable origin. Actions occur but cannot be attributed. The kosmos would be a sea of anonymous content with no way to know what is authentic, what came from where, or who stands behind any claim.

Hypostasis provides:
- **Identity** — cryptographic proof of who exists (prosopa, keys)
- **Authenticity** — verifiable provenance chains to signed genesis
- **Self-replication** — the kosmos can back itself up and restore across devices
- **Session security** — fluid operation without sacrificing protection

**What becomes possible:**
- Trust without central authority (cryptographic, not institutional)
- Multi-device sync with verification
- Backup and recovery with integrity guarantees
- Federation between oikoi with proof of origin
- Credentials that grant capabilities when unlocked

## Oikos Context

### Self Oikos

A solitary dweller uses hypostasis to:
- Generate and secure their mnemonic (root of all keys)
- Create an encrypted keyring (password-protected access)
- Store API credentials that enable AI features
- Back up their kosmos to file (phoreta export)
- Restore on a new device with same identity

The self oikos is where hypostasis is most intimate — your keys, your identity, your sovereignty.

### Peer Oikos

Collaborators use hypostasis to:
- Verify each other's signatures on shared content
- Sync theoria and entities via phoreta exchange
- Share credentials with oikos scope (team API keys)
- Multi-sign genesis for constitutional establishment
- Export/import oikos state for new members

Trust between peers is cryptographic — if you can verify the signature, you know who created it.

### Commons Oikos

A community uses hypostasis to:
- Establish authoritative genesis with threshold signatures (3-of-5)
- Verify that distributed topoi trace to signed constitutional root
- Audit provenance chains for any entity
- Provide transparent key ownership (who can sign for what)

The commons oikos is where hypostasis becomes constitutional — the signed genesis that all content traces back to.

## Core Entities (Eide)

### kleidoura

κλειδωρός — key-keeper. The encrypted keyring.

**Fields:**
- `encrypted_seed` — AES-256-GCM encrypted master seed (base64)
- `encryption_salt` — Salt for password derivation (base64, 32 bytes)
- `kdf_algorithm` — Key derivation function (argon2id or pbkdf2-sha256)
- `kdf_params` — Algorithm parameters (memory_cost, time_cost, etc.)
- `public_key` — Master Ed25519 public key for verification
- `version` — Keyring format version
- `created_at` — Creation timestamp
- `locked_at` — When last locked
- `password_hint` — Optional user-provided hint

**Lifecycle:**
1. **Arise** — Created via `create-keyring` with mnemonic + password
2. **Unlock** — Decrypted into session memory via `unlock-keyring`
3. **Use** — Session signing/derivation while unlocked
4. **Lock** — Session cleared via `lock-keyring` or timeout

**Security model:** The mnemonic never persists. Only the encrypted seed is stored. Decrypted material lives in chora (process memory), not kosmos (entities).

### genesis-record

Multi-signature genesis for threshold signing.

**Fields:**
- `content` — The constitutional content being signed
- `content_hash` — BLAKE3 hash of the content
- `threshold` — Number of signatures required (default 3)
- `signatures` — Array of {public_key, signature, attestation, signed_at}
- `verified` — Whether threshold has been reached
- `created_at` — Creation timestamp
- `finalized_at` — When threshold was reached

**Lifecycle:**
1. **Begin ceremony** — Content proposed, hash computed
2. **Collect signatures** — Multiple signers add their attestations
3. **Finalize** — Threshold reached, marked verified
4. **Verify** — Anyone can verify all signatures

### credential

Encrypted external service credential with attainment grants.

**Fields:**
- `service` — Provider name (openai, anthropic, cloudflare)
- `credential_type` — Type (api-key, oauth-token, bearer-token, access-key)
- `encrypted_value` — AES-256-GCM encrypted credential (base64)
- `salt` — Per-credential encryption salt (base64)
- `label` — Human-readable name
- `scope` — Who can use (prosopon or oikos)
- `grants_attainment` — Attainment granted when unlocked
- `status` — State (active, revoked, expired)
- `created_at` — Creation timestamp
- `last_used_at` — Last usage timestamp
- `expires_at` — Optional expiration

**Lifecycle:**
1. **Add** — Created via `add-credential` with value encrypted
2. **Unlock** — Decrypted into session via `unlock-credentials`
3. **Use** — Praxeis check attainment, get value from session
4. **Revoke** — Marked revoked, removed from session

## Bonds (Desmoi)

### secures-key-for
- **From:** kleidoura
- **To:** prosopon
- **Cardinality:** one-to-one
- **Traversal:** Find keyring for a prosopon, or prosopon for a keyring

### signed-by
- **From:** any entity
- **To:** prosopon
- **Cardinality:** many-to-one
- **Traversal:** Who signed this? What has this prosopon signed?

### chains-to
- **From:** any entity
- **To:** any entity
- **Cardinality:** many-to-one
- **Traversal:** Composition chain verification to genesis

### verifies
- **From:** genesis-record
- **To:** any entity
- **Cardinality:** one-to-many
- **Traversal:** What does this genesis verify?

### credential-of
- **From:** credential
- **To:** prosopon
- **Cardinality:** many-to-one
- **Traversal:** Whose credentials? What credentials does this prosopon own?

### shared-with
- **From:** credential
- **To:** oikos
- **Cardinality:** many-to-one
- **Traversal:** Which oikos can use this credential?

### unlocks-attainment
- **From:** credential
- **To:** attainment
- **Cardinality:** many-to-one
- **Traversal:** What capability does this credential grant?

### enables-function
- **From:** credential
- **To:** function
- **Cardinality:** many-to-many
- **Traversal:** What dynamis operations require this credential?

## Operations (Praxeis)

### Content-Addressed Operations

#### compute-hash
Compute BLAKE3 hash of entity content. Returns content-addressed ID.
- **When:** Verify entity integrity, generate content-addressed references
- **Requires:** Entity must exist

#### verify-chain
Verify composition chain to genesis. Walks composed-from bonds.
- **When:** Validate entity authenticity
- **Requires:** Entity with composition chain

#### verify-genesis
Verify genesis record signatures meet threshold.
- **When:** Validate constitutional root
- **Requires:** Genesis record with signatures

### Phoreta Operations

Phoreta are signed, encrypted, content-addressed entity bundles. One format
serves four purposes: emission, backup, recovery, federation. Recovery IS federation with
your past self (T24).

**Format properties:**
- **Subgraph-carrying:** entities + their outbound bonds as an atomic unit
- **Encrypted (mandatory):** AES-256-GCM with HKDF-derived backup key from mnemonic seed
- **SOPS pattern:** metadata (IDs, eidos, bonds) cleartext; entity data always encrypted
- **Content-addressed:** files stored at BLAKE3 hash path, never overwritten
- **Signed:** Ed25519 over content hash (covers all entities/bonds transitively)

**Bootstrap constraint:** metadata is readable without the decryption key. Bootstrap scans
phoreta to discover which kleidoura exists, presents the unlock screen, THEN decrypts entity
data after the user enters their password and the backup key becomes derivable.

**Emission requires unlocked keyring.** If the keyring is locked, emission is deferred — entities
persist in the database and emit when the keyring next unlocks. This ensures no unencrypted
phoreta are ever written to disk.

#### emit-phoreta
Auto-emit entity + outbound bonds to local phoreta store. Reflex-invoked, not user-facing.
- **When:** Entity create/update (kleidoura, credential — via reflexes), keyring unlocked
- **Encrypts:** Always (mandatory). Emission deferred if keyring locked.
- **Storage:** Content-addressed file in `~/Library/Application Support/kosmos/phoreta/store/`

#### export-phoreta
Create signed bundle of entities and bonds for transport.
- **When:** Backup, federation, sharing
- **Requires:** Entity IDs to export
- **Gated by:** `attainment/export`

#### import-phoreta
Verify and import a phoreta bundle with merge strategy.
- **When:** Restore, sync, receive shared content
- **Requires:** Valid phoreta bundle, merge strategy (newer_wins, local_wins, fail_on_conflict)

#### create-snapshot
Full state export of an oikos.
- **When:** Complete backup before major changes
- **Requires:** Oikos scope
- **Gated by:** `attainment/export`

#### restore-snapshot
Restore state from a snapshot.
- **When:** Disaster recovery
- **Requires:** Valid snapshot, merge strategy

#### sync-delta
Export changes since a version/timestamp.
- **When:** Incremental sync between devices
- **Requires:** Version marker

### Key Operations

#### generate-mnemonic
Generate new BIP-39 24-word phrase.
- **When:** Creating new identity
- **Returns:** Mnemonic (store securely!)

#### derive-oikos-key
Derive oikos-scoped Ed25519 keypair from mnemonic.
- **When:** Getting public key for an oikos
- **Requires:** Mnemonic + oikos_id

#### sign-content
Sign content with oikos-scoped key.
- **When:** Attesting to content
- **Requires:** Mnemonic + oikos_id + content
- **Gated by:** `attainment/sign`

#### verify-signature
Verify signature against content and public key.
- **When:** Validating attestation
- **Requires:** Content, signature, public key

### Keyring Operations

#### create-keyring
Encrypt mnemonic with password, create kleidoura.
- **When:** Setting up identity for first time
- **Requires:** Mnemonic + password
- **Gated by:** One per prosopon (enforced)

#### unlock-keyring
Decrypt seed into session memory.
- **When:** Starting work session
- **Requires:** Password

#### lock-keyring
Clear session memory.
- **When:** Ending session, timeout, explicit lock
- **Effect:** All signing requires password again

#### check-keyring-status
Check if session is unlocked.
- **When:** Before signing operations
- **Returns:** Unlock state

#### change-keyring-password
Re-encrypt with new password.
- **When:** Password rotation
- **Requires:** Old password + new password

#### sign-with-session
Sign using unlocked session key.
- **When:** Signing while session is active
- **Requires:** Session unlocked + oikos_id
- **Gated by:** `attainment/sign`

#### derive-key-from-session
Derive oikos public key from session.
- **When:** Need public key without re-entering mnemonic
- **Requires:** Session unlocked

### Prosopon Operations

#### export-prosopon
Export prosopon with oikoi, theoria for federation.
- **When:** Moving to new device
- **Requires:** Mnemonic for signing
- **Gated by:** `attainment/export`

#### import-prosopon
Import prosopon from another device.
- **When:** Setting up new device
- **Requires:** Export bundle + matching mnemonic

#### sync-devices
Bidirectional sync between devices.
- **When:** Keeping multiple devices in sync
- **Requires:** Same mnemonic on both sides

### Genesis Ceremony

#### begin-genesis-ceremony
Start multi-signature signing process.
- **When:** Establishing new constitutional root
- **Requires:** Content + threshold
- **Gated by:** `attainment/genesis-signer`

#### add-genesis-signature
Add signer signature to ceremony.
- **When:** Participating in ceremony
- **Requires:** Mnemonic + attestation
- **Gated by:** `attainment/genesis-signer`

#### finalize-genesis
Complete ceremony when threshold reached.
- **When:** Enough signatures collected
- **Effect:** Genesis marked verified

#### get-genesis-status
Check ceremony progress.
- **When:** Monitoring ceremony state
- **Returns:** Signatures collected, remaining needed

### Credential Operations

> **Note:** Credential eidos and praxeis have moved to the **credentials** topos.
> See `genesis/credentials/DESIGN.md` for full documentation.
> Hypostasis provides the cryptographic foundation (keyring, session unlock)
> that credentials depend on, but credential management is owned by its own topos.

## Attainments

### attainment/sign
**Capability:** Sign content with oikos-scoped keys.
**Gates:** `sign-content`, `sign-with-session`
**Scope:** oikos

### attainment/export
**Capability:** Export phoreta bundles and snapshots.
**Gates:** `export-phoreta`, `create-snapshot`, `export-prosopon`
**Scope:** oikos

### attainment/manage-keyring
**Capability:** Create and manage keyring.
**Gates:** `create-keyring`, `change-keyring-password`
**Scope:** prosopon

### attainment/manage-credentials
**Moved to credentials topos.** See `genesis/credentials/DESIGN.md`.

### attainment/genesis-signer
**Capability:** Participate in genesis signing ceremony.
**Gates:** `begin-genesis-ceremony`, `add-genesis-signature`
**Scope:** oikos

## Embodiment

### Completeness Status

| Level | Status |
|-------|--------|
| Defined | eide, desmoi, praxeis exist in YAML |
| Loaded | Bootstrap loads into kosmos.db |
| Projected | MCP projects praxeis as tools |
| Embodied | Body-schema reflects capabilities |
| Surfaced | Reconciler notices when actions are relevant |
| Afforded | Thyra UI presents contextual actions |

### Body-Schema Contribution

When `sense-body` runs, hypostasis contributes:

```yaml
body-schema:
  identity:
    keyring_exists: true|false
    session_unlocked: true|false
    public_key: "base64..." # if unlocked
  capabilities:
    - name: sign
      available: "$session_unlocked"
      topos: hypostasis
    - name: export
      available: "$session_unlocked"
      topos: hypostasis
  credentials:
    - service: openai
      attainment: use-embedding-api
      status: unlocked|locked|not_configured
  pending_actions:
    - action: unlock_keyring
      reason: "Session locked, signing unavailable"
      when: "$keyring_exists and not $session_unlocked"
```

### Reconciler

```yaml
reconciler/hypostasis-session:
  trigger: on-dwell
  sense: |
    - Check if keyring exists for dwelling prosopon
    - Check if session is locked
    - Check if credentials need refresh
  surface: |
    - If keyring exists but locked: suggest unlock
    - If no keyring: suggest setup
    - If credentials expiring: warn
```

## Compound Leverage

### Amplifies Other Topoi

| Topos | How Hypostasis Amplifies |
|-------|-------------------------|
| **politeia** | Attainments verify identity. Credentials grant capabilities. |
| **ekdosis** | Signing topos-prod requires hypostasis keys. |
| **propylon** | Entry links signed with oikos keys. |

| **nous** | Semantic search needs API credentials (use-embedding-api). |
| **manteia** | Generation needs API credentials (use-anthropic-api). |
| **aither** | Federation phoreta signed by origin. |

### Cross-Topos Patterns

1. **Credential → Attainment → Praxis**
   Credentials unlock attainments. Attainments gate praxeis. Praxeis enable features.
   Example: OpenAI credential → use-embedding-api → nous/index works.

2. **Sign → Verify → Trust**
   Content signed with hypostasis keys. Other parties verify. Trust established structurally.
   Example: Topos-prod signed → distributed → installed after verification.

3. **Export → Transport → Import**
   Phoreta exported with signature. Transported via any channel. Imported with verification.
   Example: Backup to file → store anywhere → restore on new device.

## Theoria

New theoria crystallized during this redesign:

### T21: Identity is the foundation of all capability

Without identity (prosopon + keys), there can be no signed content, no verified attribution, no trust. Hypostasis must exist before any topos that requires authentication.

### T22: Cryptographic bonds create structural trust

Trust in kosmos is not policy-based (someone decided to trust) but structure-based (cryptographic verification succeeds). This is T1 (visibility = reachability) applied to authenticity.

### T23: Session state bridges security and usability

The kleidoura pattern — encrypted at rest, unlocked into session memory — enables fluid operation without sacrificing security. Session state lives in chora (process), not kosmos (persistence). This extends T16.

## Two Pillars of Kosmos Security

1. **Visibility = Reachability** — You can only perceive what you can cryptographically reach through the bond graph.

2. **Authenticity = Provenance** — Everything you reach is verifiably derived from signed genesis.

Both are structural, not policy. Both are mathematical, not hopeful.

## Key Derivation Architecture

```
mnemonic (BIP-39, 24 words)
    │
    └─► master seed (BIP-39 derivation)
            │
            ├─► prosopon key (Ed25519 master identity)
            │       │
            │       └─► prosopon ID: "prosopon/" + BLAKE3(public_key_bytes)[..16] hex
            │
            ├─► self-oikos ID: "oikos/self-" + prosopon_hash
            │
            └─► oikos keys (HKDF per oikos_id)
                    │
                    └─► session keys (ephemeral)
```

Key derivation mirrors trust derivation. The social structure and the cryptographic structure are the same structure.

**Deterministic identity:** The prosopon ID is a function of cryptographic material — same mnemonic always produces the same prosopon ID and self-oikos ID. Identity is derivation, not storage. The mnemonic is the sovereign substrate — not any platform service.

## Sovereign Substrate

The mnemonic is the **sovereign substrate** — the irreducible root from which all identity derives. It is not stored by the system. The user holds it. Everything else is derived.

Graph entities (kleidoura, credential) are **first-class entities**, not projections of a platform-specific store. They persist in the kosmos database like all entities. If the database is wiped, recovery follows the same path as federation — mnemonic re-derivation + phoreta import:

- **Mnemonic** → deterministic re-derivation of prosopon ID, self-oikos ID, signing keys
- **Phoreta** → signed bundles restore entity state (credentials, theoria, bonds)

This dissolves the platform keychain dependency. Recovery IS federation with your past self. The mechanism that moves state between devices also moves state across database resets. One pattern, not two.

What persists where:
- **Mnemonic**: held by the user (paper, memory, password manager — their choice, their sovereignty)
- **Phoreta emission**: local filesystem (`~/Library/Application Support/kosmos/phoreta/store/`) — reflex-driven auto-emission on entity create/update, survives DB wipe. Files are content-addressed (BLAKE3 hash → path) and immutable (new state = new file). An index tracks the latest phoreta per entity scope. Encryption is mandatory: entity data encrypted with AES-256-GCM using an HKDF-derived backup key (same mnemonic → same key). Emission only occurs when keyring is unlocked (backup key derivable). Metadata (IDs, eidos, bonds) stays cleartext. Trigger/reflex entities in the graph declare which eide auto-emit; adding new eide to the emission set requires a new reflex entity, not a code change
- **Session token**: OS keyring (ephemeral cross-process IPC — Thyra ↔ kosmos-mcp, not identity persistence)

## Bootstrap Dwelling Discovery

After constitutional bootstrap (genesis), a discovery phase scans for prior dwelling state:

1. **Scan local phoreta** for existing identity emission (`~/Library/Application Support/kosmos/phoreta/`)
2. **If found:** import phoreta → re-derive prosopon ID from kleidoura public key → derive self-oikos → compose prosopon entity → compose self-oikos entity → establish `member-of` and `stewards` bonds → present unlock screen
3. **If empty:** present welcome screen (fresh setup)
4. **After unlock:** import credential phoreta → compose credential entities → bond to providers → trigger attainment derivation via reflexes

Discovery does not create from nothing — it re-derives from what persists. This is the reconciliation pattern (sense → compare → act) applied to local emission. The same phoreta format used for federation serves recovery.

### discover-dwelling (praxis)
Scan local phoreta emission, re-derive identity, reconstitute dwelling entities.
- **When:** After constitutional bootstrap completes
- **Requires:** Access to local phoreta directory
- **Effect:** Prosopon, self-oikos, and credential entities re-composed if emission exists

## Future Extensions

- **Hardware key support** — YubiKey, Ledger for signing
- **Multi-party computation** — Threshold signing without key combination
- **Key rotation** — Graceful migration to new keys
- **Delegated signing** — Time-limited signing authority
- **Audit log** — Immutable record of all signing operations

---

*Hypostasis is self-constitution — the kosmos that knows who it is, can prove where anything came from, and can replicate itself while maintaining integrity. Identity is the foundation upon which all other capabilities build.*
