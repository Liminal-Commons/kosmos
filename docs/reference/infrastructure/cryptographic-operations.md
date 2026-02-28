# Cryptographic Operations Reference

*Prescriptive — describes the target state.*

This document specifies the cryptographic operations available in kosmos, their primitives, interfaces, and guarantees. All operations are implemented in the shared `crypto` module (`crates/kosmos/src/crypto.rs`) and called by stoicheion steps, the Tauri app, and host internals.

---

## Principles

1. **One module, all crypto.** Every cryptographic operation routes through `crypto.rs`. No inline crypto in `host.rs`, no duplicated implementations in the Tauri app.
2. **Canonical serialization.** Content hashing uses deterministic JSON (sorted keys, no trailing whitespace) so that `emit → bootstrap → emit` produces identical BLAKE3 hashes.
3. **Keys never persist in plaintext.** Master seeds are encrypted at rest (kleidoura). Decrypted material lives in process memory only, cleared on lock or timeout.
4. **Tier 3 — arche only.** Crypto stoicheia require host key access, system entropy, and session keyring. They are excluded from WASM expansion.

---

## Content Hashing

### `hash_content(data: &Value) -> String`

Computes a deterministic BLAKE3 hash of entity content.

**Algorithm:**
1. Serialize `data` to canonical JSON (sorted keys, no optional whitespace)
2. Compute `blake3::hash(canonical_bytes)`
3. Return hex string

**Format:** 64-character lowercase hex string (BLAKE3 output)

**Canonical serialization rules:**
- Object keys sorted lexicographically (recursive)
- No trailing newlines or whitespace
- Numbers serialized without unnecessary precision
- Null values included (not elided)

**Used by:**
- `arise_entity()` in host.rs — content-address for every entity
- `apply_change()` in host.rs — updated content-address on mutation
- `DigestStep` — stoicheion step for content hashing
- Phoreta export — bundle content hash

### `hash_bytes(data: &[u8]) -> String`

Computes BLAKE3 hash of raw bytes. Returns 64-character lowercase hex.

**Used by:**
- `HashPathStep` — file content hashing for staleness detection
- Genesis hash verification in Tauri app

### `hash_content_prefixed(data: &Value) -> String`

Same as `hash_content` but returns `"blake3:{hex}"` format for use in stoicheion step bindings.

---

## Hash Chain Verification

### `verify_chain(entities: &[EntityHashEntry]) -> ChainVerification`

Verifies integrity of a sequence of content-addressed entities.

**Input:** Ordered list of `EntityHashEntry { id, data, stored_hash }`

**Algorithm:**
1. For each entity, compute `hash_content(&data)`
2. Compare computed hash against `stored_hash`
3. Collect mismatches

**Output:**
```rust
pub struct ChainVerification {
    pub valid: bool,
    pub total: usize,
    pub verified: usize,
    pub mismatches: Vec<HashMismatch>,
}

pub struct HashMismatch {
    pub entity_id: String,
    pub expected: String,
    pub actual: String,
}
```

---

## Canonical Serialization

### `canonical_json(value: &Value) -> String`

Produces deterministic JSON from a `serde_json::Value`.

**Rules:**
- Object keys sorted lexicographically at every nesting level
- No pretty-printing (compact format)
- Standard serde_json numeric formatting
- Null values preserved

This is the serialization used by `hash_content`. All content hashes in kosmos depend on this function producing identical output for semantically identical data.

---

## Key Derivation

### `generate_mnemonic() -> String`

Generates a BIP-39 mnemonic phrase.

**Algorithm:**
1. Generate 32 bytes of cryptographically secure entropy (`OsRng`)
2. Encode as BIP-39 English mnemonic (24 words)

**Output:** Space-separated 24-word mnemonic string

### `seed_from_mnemonic(mnemonic: &str) -> Result<[u8; 64]>`

Derives a 64-byte seed from a BIP-39 mnemonic.

**Algorithm:** BIP-39 seed derivation with empty passphrase (`mnemonic.to_seed("")`)

### `derive_signing_key(seed: &[u8; 64], oikos_id: &str) -> SigningKey`

Derives an oikos-scoped Ed25519 signing key from a master seed.

**Algorithm:**
1. HKDF-SHA256 extract: `salt = oikos_id.as_bytes()`, `ikm = seed`
2. HKDF-SHA256 expand: `info = b"ed25519-key"`, output 32 bytes
3. Construct `ed25519_dalek::SigningKey` from the 32 bytes

**Determinism:** Same seed + same oikos_id always produces the same keypair.

### `derive_encryption_key(seed: &[u8; 64], salt: &[u8]) -> [u8; 32]`

Derives an AES-256-GCM encryption key from a master seed.

**Algorithm:**
1. HKDF-SHA256 extract: `salt = salt`, `ikm = seed`
2. HKDF-SHA256 expand: `info = b"credential-encryption"`, output 32 bytes

**Used by:** Credential encrypt/decrypt operations.

### `derive_keyring_key(password: &str, salt: &[u8; 32]) -> [u8; 32]`

Derives an encryption key from a user password for keyring (kleidoura) encryption.

**Algorithm:** Argon2id with default parameters:
- `m_cost`: 19456 (memory in KiB)
- `t_cost`: 2 (iterations)
- `p_cost`: 1 (parallelism)

**Output:** 32-byte AES-256-GCM key

---

## Ed25519 Signing

### `sign_content(signing_key: &SigningKey, content: &[u8]) -> Signature`

Signs content with an Ed25519 signing key.

**Algorithm:** Ed25519 signature (RFC 8032) via `ed25519-dalek`

**Output:** 64-byte Ed25519 signature

### `verify_signature(public_key: &[u8; 32], content: &[u8], signature: &[u8; 64]) -> bool`

Verifies an Ed25519 signature.

**Returns:** `true` if signature is valid for the given content and public key.

### Encoding Conventions

- **Public keys:** Base64 standard encoding of 32-byte Ed25519 verifying key
- **Signatures:** Base64 standard encoding of 64-byte Ed25519 signature
- **Library:** `base64::engine::general_purpose::STANDARD`

---

## AES-256-GCM Encryption

### `encrypt(key: &[u8; 32], plaintext: &[u8]) -> EncryptedData`

Encrypts data with AES-256-GCM.

**Algorithm:**
1. Generate 12-byte random nonce (`OsRng`)
2. AES-256-GCM encrypt with key and nonce
3. Return nonce + ciphertext

**Output:**
```rust
pub struct EncryptedData {
    pub nonce: [u8; 12],
    pub ciphertext: Vec<u8>,
}
```

**Wire format (base64):** `nonce (12 bytes) || ciphertext` encoded as base64 standard.

### `decrypt(key: &[u8; 32], nonce: &[u8; 12], ciphertext: &[u8]) -> Result<Vec<u8>>`

Decrypts AES-256-GCM ciphertext. Returns error if authentication tag fails (wrong key, tampered data, or wrong nonce).

### `encrypt_to_base64(key: &[u8; 32], plaintext: &[u8]) -> String`

Convenience: encrypt and return base64-encoded `nonce || ciphertext`.

### `decrypt_from_base64(key: &[u8; 32], encoded: &str) -> Result<Vec<u8>>`

Convenience: decode base64, split nonce from ciphertext, decrypt.

---

## Session Keyring

The session keyring holds decrypted key material in process memory. It is the chora-side complement to the kosmos kleidoura entity.

### Lifecycle

1. **Locked** (default) — no key material in memory
2. **Unlocked** — master seed decrypted, credentials accessible
3. **Expired** — auto-lock timeout reached, treated as locked

### Interface

```rust
pub struct SessionKeyring {
    master_seed: Option<[u8; 64]>,
    unlocked_at: Option<Instant>,
    timeout_secs: u64,  // default: 900 (15 minutes)
    credentials: HashMap<String, SessionCredential>,
    attainments: HashSet<String>,
}
```

**Operations:**
- `unlock(seed, timeout_secs)` — store seed, start timer
- `lock()` — zero-fill seed, clear credentials and attainments
- `is_unlocked()` — true if seed present and not expired
- `get_master_seed()` — returns seed if unlocked, None otherwise
- `store_credential(id, value, service, attainment)` — add to session
- `get_credential(service)` — retrieve by service name
- `remove_credential(id)` — remove from session
- `has_attainment(attainment)` — check granted attainment
- `list_attainments()` — all granted attainments
- `list_credentials()` — all credential metadata

**Auto-lock:** On any access, if `unlocked_at.elapsed() >= timeout_secs`, call `lock()` and return locked state.

**Secure cleanup:** `lock()` zero-fills the master seed bytes before dropping.

---

## Phoreta (Encrypted, Signed Entity Bundles)

Phoreta (φορητά = "carried things") are encrypted, signed, content-addressed entity bundles for transport across time (backup/recovery) and space (federation). Recovery IS federation with your past self — one format, one import path.

### Bundle Format

```rust
pub struct Phoreta {
    pub format_version: u32,           // 2
    pub phoreta_type: PhoretaType,     // Emission | FullSnapshot | Delta
    pub entities: Vec<PhoretaEntity>,  // [{id, eidos, version, data, encrypted}]
    pub bonds: Vec<PhoretaBond>,       // [{from_id, to_id, desmos, data?}]
    pub entity_count: usize,
    pub bond_count: usize,
    pub content_hash: String,          // BLAKE3 of canonical JSON({entities, bonds})
    pub signature: Option<String>,     // Ed25519 over content_hash (base64)
    pub public_key: Option<String>,    // Signer's public key (base64)
    pub encryption: Option<PhoretaEncryption>,  // {algorithm, key_derivation, key_hint}
    pub origin_oikos_id: Option<String>,
    pub origin_prosopon_id: Option<String>,
    pub created_at: String,
    pub since_version: Option<i64>,
}
```

### SOPS Pattern — Metadata Cleartext, Data Encrypted

Entity data is encrypted per-entity with AES-256-GCM. Structural metadata (entity IDs, eidos, bonds) remains cleartext. This satisfies the bootstrap constraint: the system can discover which entities exist before keyring unlock.

Content hash covers **ciphertext**, not plaintext — integrity is verifiable without decryption.

### Key Derivation

Backup encryption uses a deterministic key derived from the mnemonic seed:

```
derive_backup_key(seed) → HKDF-SHA256(salt="phoreta-backup", ikm=seed, info="aes-256-gcm") → [u8; 32]
```

Same mnemonic → same backup key → can decrypt all emission phoreta.

### Emission (Single Entity + Bonds)

1. Gather entity and its outbound bonds
2. Build `Phoreta::from_entity_with_bonds(entity, bonds)`
3. Encrypt with `derive_backup_key(seed)` — **mandatory**, emission deferred if keyring locked
4. Optionally sign with identity key
5. Write to content-addressed store via `emit_to_store()`

### Content-Addressed Immutable Storage

Phoreta files are never overwritten. Storage uses git-style content-addressed paths:

```
~/Library/Application Support/kosmos/phoreta/
  store/
    a3/b7c4d5e6...rest.phoreta.json    # immutable
    f1/2e3d4c5b...rest.phoreta.json
  index.json                            # latest pointer per entity scope
```

The index tracks latest hash + history per entity. Pruning keeps the most recent N entries.

### Import

`import_from_index(host, base_dir, backup_key)` reads the index, loads phoreta files, and restores entities + bonds:

1. Read index, iterate entries
2. Load phoreta from content-addressed path
3. Verify integrity (recompute BLAKE3, compare)
4. If encrypted and key available: decrypt
5. If encrypted and no key: import with encrypted data blob (opaque import — entity exists in graph, data decrypted later when keyring unlocks)
6. Apply entities and bonds to graph, skipping entities that already exist

### Trust Model

Integrity verification:
- **Content hash**: BLAKE3 recomputed from canonical payload, compared against stored hash
- **Signature**: Ed25519 verification against content hash and public key

Authorization is orthogonal — the attainment system gates what actions the importer can take with the restored entities.

---

## Stoicheion Wiring

All crypto stoicheia are **Tier 3 (arche)** — they require host capabilities.

| Step | Operation | Crypto Function |
|------|-----------|----------------|
| `digest` | (implicit) | `crypto::hash_bytes()` (input is pre-evaluated string, not JSON) |
| `keyring` | `generate_mnemonic` | `crypto::generate_mnemonic()` |
| `keyring` | `derive_key` | `crypto::seed_from_mnemonic()` + `crypto::derive_signing_key()` |
| `keyring` | `sign` | `crypto::seed_from_mnemonic()` + `crypto::derive_signing_key()` + `crypto::sign_content()` |
| `keyring` | `verify` | `crypto::verify_signature()` |
| `keyring` | `encrypt_credential` | `crypto::derive_encryption_key()` + `crypto::encrypt()` |
| `keyring` | `decrypt_credential` | `crypto::derive_encryption_key()` + `crypto::decrypt()` |
| `keyring` | `encrypt_seed` | `crypto::derive_keyring_key()` + `crypto::encrypt()` |
| `keyring` | `decrypt_seed` | `crypto::derive_keyring_key()` + `crypto::decrypt()` |
| `keyring` | `session_sign` | SessionBridge → `crypto::derive_signing_key()` + `crypto::sign_content()` |
| `keyring` | `session_pubkey` | SessionBridge → `crypto::derive_signing_key()` → verifying key |
| `hash-path` | (implicit) | `crypto::hash_bytes()` (via BLAKE3 Hasher) |

---

## Error Handling

Crypto operations return structured errors via `KosmosError::Invalid(String)`:

| Condition | Error |
|-----------|-------|
| Keyring locked | `"Keyring is locked"` |
| Session not available | `"Session not available for {operation}"` |
| Master seed missing | `"Master seed not available"` |
| Invalid mnemonic | `"Invalid mnemonic: {detail}"` |
| Invalid signature bytes | `"Invalid signature: {detail}"` |
| Invalid public key bytes | `"Invalid public key: {detail}"` |
| Decryption failed | `"Decryption failed: {detail}"` |
| HKDF expansion failed | `"HKDF expansion failed"` |
| Phoreta hash mismatch | `"Content hash mismatch: expected {expected}, got {actual}"` |
| Phoreta signature invalid | `"Bundle signature verification failed"` |

---

## Dependencies

All crypto primitives come from audited Rust crates declared in workspace `Cargo.toml`:

| Crate | Version | Purpose |
|-------|---------|---------|
| `blake3` | 1.5 | Content hashing |
| `ed25519-dalek` | 2.0 | Ed25519 signing/verification |
| `aes-gcm` | 0.10 | AES-256-GCM authenticated encryption |
| `hkdf` | 0.12 | HMAC-based key derivation |
| `sha2` | 0.10 | SHA-256 (for HKDF) |
| `bip39` | 2.0 | Mnemonic generation and seed derivation |
| `rand` | 0.8 | Cryptographic randomness |
| `argon2` | 0.5 | Password-based key derivation (kleidoura) |
| `base64` | 0.22 | Binary-to-text encoding |
