# Cryptographic Layer — Wire Primitives to Praxeis

*Prompt for Claude Code in the chora + kosmos repository context.*

*Supersedes FRONT2-CRYPTO-LAYER.md. Adds dependency cross-references to WASM Stoicheia and Attainment Authorization.*

---

## Methodology — Doc-Driven, Clean Break

This work follows **Doc → Test → Build → Verify Doc**, non-negotiably.

### The Cycle

1. **Doc (prescriptive)**: Write `docs/reference/cryptographic-operations.md` describing the *desired state* — content hashing, signing, encryption, key derivation, phoreta bundles, session keyring, and their wiring to stoicheion implementations.
2. **Test (assert the doc)**: Write tests that assert deterministic hashing, sign/verify round-trips, encrypt/decrypt round-trips, key derivation determinism, phoreta export/import, and keyring auto-lock. Tests should fail before implementation.
3. **Build (satisfy the tests)**: Implement until tests pass.
4. **Verify doc (confirm truth)**: After implementation, re-read the reference doc. Update deviations so the doc ends as truth.

### Clean Break — No Placeholder Crypto

Currently, crypto code is scattered:
- BLAKE3 hashing in `host.rs` (`arise_entity()` line 760) — inline, not reusable
- BIP-39, Ed25519, AES-GCM in the Tauri app (`app/src-tauri/src/`) — not accessible from the core crate
- Stoicheion step implementations in `steps.rs` — crypto steps are either missing or placeholder

The clean break: **one `crypto` module in the kosmos crate** that provides all cryptographic operations. All stoicheion implementations (hash-content, sign-content, verify-signature, encrypt, decrypt) call through to this module. The Tauri app imports from the shared module instead of duplicating. No placeholder implementations — if a stoicheion invokes crypto, it must use real crypto or fail explicitly.

### What "Reference Doc" Means

Reference docs in this project are *prescriptive* (target state), not descriptive (current state). When code doesn't match a reference doc, the code has a gap — not the doc (unless the design changed). See CONTRIBUTING.md for the full methodology.

---

## Dependencies — Coordination Points

### WASM Stoicheia (PROMPT-WASM-STOICHEIA.md) — shared boundary

Crypto stoicheia (hash-content, sign-content, verify-signature, encrypt, decrypt) are **Tier 3 — they require host access** (key material, system entropy). They remain arche implementations even after WASM expansion. Both prompts must agree on this boundary:

- WASM Stoicheia expands Tier 0-2 (database operations) to WASM
- Crypto operations stay arche because they need host key access, system randomness, and session keyring
- The crypto module provides the implementations that Tier 3 stoicheion steps call

If WASM Stoicheia ships first, it will correctly leave crypto stoicheia as arche. If crypto layer ships first, it wires the arche implementations that WASM expansion won't touch. No ordering conflict — but both prompts should reference the same tier classification.

### Attainment Authorization (PROMPT-ATTAINMENT-AUTHORIZATION.md) — gating crypto operations

Keyring operations (unlock, lock) are sensitive. If the unified authorization gate is in place:
- `hypostasis/unlock-keyring` should require an attainment (e.g., `attainment/govern` or a dedicated `attainment/keyring`)
- `hypostasis/sign-content` should require the keyring to be unlocked (enforced by the crypto module, not by attainment)
- `credentials/store-credential` and `credentials/unlock-credential` should require `attainment/govern`

This is a consideration, not a hard dependency. The crypto layer can ship before attainment authorization — the gating is additive.

### Dokimasia Enforcement (PROMPT-DOKIMASIA-ENFORCEMENT.md) — validation of crypto entities

Phoreta import creates entities. If dokimasia enforcement is active, imported entities are validated against eidos schemas at arise-time. This is correct behavior — imported entities should pass the same validation as locally created ones. No special exemption for imports.

---

## Context

### What Hypostasis Declares

From `genesis/hypostasis/DESIGN.md` and praxeis:

**Key derivation:**
- BIP-39 mnemonic → master seed (via PBKDF2)
- Master seed → oikos keys (via HKDF with oikos_id as context)
- Each oikos gets: signing keypair (Ed25519), encryption key (AES-256-GCM)

**Content addressing:**
- BLAKE3 hash of entity content → content-address
- Content-address chains: entity.hash = BLAKE3(entity.data + parent.hash)
- Genesis ceremony: threshold of founders sign the initial content root

**Phoreta (signed bundles):**
- Export: serialize entities → sign with Ed25519 → bundle
- Import: verify signature → validate content → integrate

**Kleidoura (encrypted keyring):**
- Keys encrypted at rest with passphrase-derived key
- Unlocked into session memory
- Session timeout → automatic re-lock

### What Credentials Declares

From `genesis/credentials/DESIGN.md`:
- External API keys encrypted with AES-256-GCM
- Decrypted into session-scoped credential-attainment entities
- Session timeout → credentials re-locked

### Praxeis That Need Crypto

**Hypostasis:**
- `hypostasis/hash-content` — BLAKE3 hash
- `hypostasis/verify-chain` — verify hash chain integrity
- `hypostasis/generate-mnemonic` — BIP-39 mnemonic generation
- `hypostasis/derive-oikos-keys` — HKDF key derivation
- `hypostasis/sign-content` — Ed25519 signing
- `hypostasis/verify-signature` — Ed25519 verification
- `hypostasis/export-phoreta` — serialize + sign bundle
- `hypostasis/import-phoreta` — verify + import bundle
- `hypostasis/unlock-keyring` — decrypt keys into session
- `hypostasis/lock-keyring` — clear session keys

**Credentials:**
- `credentials/store-credential` — AES-256-GCM encrypt
- `credentials/unlock-credential` — AES-256-GCM decrypt
- `credentials/lock-credential` — clear from session

---

## Design

### 1. Shared Crypto Module

All crypto operations live in `crates/kosmos/src/crypto.rs` (or `crypto/` directory if needed):

| Operation | Primitive | Used By |
|-----------|-----------|---------|
| `hash_content` | BLAKE3 | Content addressing, full-circle genesis |
| `verify_chain` | BLAKE3 | Hash chain integrity |
| `sign_content` | Ed25519 | Phoreta export, genesis ceremony |
| `verify_signature` | Ed25519 | Phoreta import, trust verification |
| `encrypt` | AES-256-GCM | Credential storage, kleidoura |
| `decrypt` | AES-256-GCM | Credential unlocking, kleidoura |
| `generate_mnemonic` | BIP-39 | Onboarding |
| `derive_oikos_keys` | HKDF + SHA-256 | Per-oikos key derivation |

**Critical constraint:** `hash_content` must use **canonical serialization** (deterministic sorted keys, no whitespace variance). This is what makes `emit → bootstrap → emit` produce identical BLAKE3 hashes. The existing inline hashing in `host.rs` must be replaced with the shared function.

### 2. Session Keyring

In-memory keyring holding unlocked keys per oikos:
- `unlock(oikos_id, keys)` — decrypt and store keys for session
- `lock(oikos_id)` — clear specific oikos keys
- `lock_all()` — clear all keys (session timeout or explicit lock)
- `is_expired()` — check session timeout
- `get(oikos_id)` — retrieve keys (returns None if locked/expired)

Auto-lock: If `is_expired()` is true on any `get()` call, lock all keys and return None.

### 3. Phoreta (Signed Bundles)

Export: serialize entities + bonds → canonical JSON → BLAKE3 hash → Ed25519 sign → bundle
Import: verify Ed25519 signature → verify BLAKE3 content hash → validate entities → integrate

Bundle format includes: entities, bonds, content_hash, signature, signer_public_key, created_at.

**Note:** Import creates entities via `arise_entity()`. If dokimasia enforcement is active, imported entities are validated at creation. This is intended — no bypass for imports.

### 4. Stoicheion Wiring

Each crypto stoicheion in `steps.rs` calls through to the shared `crypto` module:
- `hash-content` step → `crypto::hash_content()`
- `sign-content` step → `crypto::sign_content()` (requires unlocked keyring)
- `verify-signature` step → `crypto::verify_signature()`
- `encrypt` step → `crypto::encrypt()` (requires unlocked keyring)
- `decrypt` step → `crypto::decrypt()` (requires unlocked keyring)

Steps that require keys must check the session keyring and return a structured error if keys are locked. These stoicheia remain **Tier 3 (arche)** — they need host key access and are excluded from WASM expansion.

---

## Implementation Order

### Step 1: Doc (prescriptive spec)

**Write `docs/reference/cryptographic-operations.md`** — the complete specification:
- Canonical serialization format (deterministic JSON for BLAKE3)
- Content hashing: BLAKE3, when it runs, content-address format
- Hash chain verification: how parent hashes chain
- Ed25519 signing: key format, signature format, what gets signed
- Ed25519 verification: public key resolution, signature validation
- AES-256-GCM encryption: nonce generation, ciphertext format, key requirements
- BIP-39 mnemonic: word count (24), language (English), seed derivation
- HKDF key derivation: master seed → per-oikos keys, context format
- Session keyring: lifecycle (unlock/lock/timeout), auto-lock behavior
- Phoreta bundle format: serialization, signing, verification, import flow
- Stoicheion step wiring: which steps call which crypto operations (all Tier 3, arche)
- Error handling: locked keyring, invalid signature, decryption failure

### Step 2: Test (assert the doc)

**Write tests BEFORE implementation** in `crates/kosmos/tests/crypto.rs`:
- Test: `hash_content` produces deterministic output (same input = same hash)
- Test: `hash_content` with reordered JSON keys produces same hash (canonical serialization)
- Test: `verify_chain` succeeds for valid chain, fails for tampered content
- Test: Ed25519 sign + verify round-trip succeeds
- Test: Ed25519 verify with wrong key fails
- Test: Ed25519 verify with tampered content fails
- Test: AES-256-GCM encrypt + decrypt round-trip succeeds
- Test: AES-256-GCM decrypt with wrong key fails
- Test: AES-256-GCM decrypt with wrong nonce fails
- Test: BIP-39 generates valid 24-word mnemonic
- Test: Same mnemonic + passphrase → same seed (deterministic)
- Test: HKDF derives deterministic keys from same seed + oikos_id
- Test: Different oikos_id → different keys
- Test: Phoreta export → import round-trip preserves entities
- Test: Phoreta import rejects tampered content (hash mismatch)
- Test: Phoreta import rejects invalid signature
- Test: Session keyring unlock + get succeeds
- Test: Session keyring lock → get returns None
- Test: Session keyring timeout → get returns None and locks all
- Test: Stoicheion hash-content step returns correct hash
- Test: Stoicheion sign-content step with locked keyring returns structured error

### Step 3: Build (satisfy the tests)

1. **Extract Tauri crypto**: Read existing crypto code in `app/src-tauri/src/`, identify reusable implementations
2. **Create `crates/kosmos/src/crypto.rs`**: Shared crypto module with all operations
3. **Canonical serialization**: Implement deterministic JSON serialization (sorted keys)
4. **Replace inline BLAKE3**: Replace the inline hashing in `host.rs` line 760 with `crypto::hash_content()`
5. **Session keyring**: Implement `SessionKeyring` struct with timeout logic
6. **Phoreta**: Implement export/import with signing and verification
7. **Wire stoicheion steps**: Update `steps.rs` to call `crypto::*` for hash-content, sign-content, verify-signature, encrypt, decrypt
8. **Add crypto crate deps to kosmos**: Ensure `crates/kosmos/Cargo.toml` has blake3, ed25519-dalek, aes-gcm, hkdf, sha2, bip39, rand

### Step 4: Verify

1. `cargo build && cargo test`
2. Manual verification:
   - Hash entity content → verify same hash on re-hash
   - Sign content → verify signature → tamper → verify fails
   - Encrypt credential → decrypt → verify plaintext matches
   - Generate mnemonic → derive keys → sign → verify with derived public key
   - Export phoreta → import → verify entities match original
3. Re-read `docs/reference/cryptographic-operations.md` — confirm it matches implementation
4. Audit:
   ```bash
   # No more inline crypto in host.rs (should use crypto module)
   grep -n "blake3::hash" crates/kosmos/src/host.rs
   # Should show import from crypto module, not inline usage

   # All crypto stoicheia wired
   grep -n "hash-content\|sign-content\|verify-signature\|encrypt\|decrypt" crates/kosmos/src/interpreter/steps.rs
   # Should show calls to crypto:: module

   # Full-circle: emit → bootstrap → emit produces same hashes
   cargo test full_circle

   # Crypto stoicheia are Tier 3 (arche) — not in WASM
   grep -n "hash-content\|sign-content\|verify-signature" genesis/stoicheia-portable/wasm/
   # Should return nothing — these are arche only
   ```

---

## Chora Codebase Context

The chora repo is at `/Users/victorpiper/code/chora`. Key files:

- **`crates/kosmos/src/host.rs`** (~3,500 lines) — BLAKE3 already used at line 760 for content hashing in `arise_entity()`. This inline usage should be replaced with the shared crypto module.
- **`crates/kosmos/src/interpreter/steps.rs`** (~4,366 lines) — Where stoicheion implementations live. Crypto steps (hash-content, sign-content, verify-signature, encrypt, decrypt) need to be wired here. These remain Tier 3 (arche).
- **`app/src-tauri/Cargo.toml`** — Already has: blake3, ed25519-dalek, aes-gcm, bip39, hkdf, sha2, argon2 as dependencies
- **`app/src-tauri/src/`** — Tauri onboarding likely has existing BIP39/Ed25519 code to extract
- **Workspace `Cargo.toml`** — All crypto crates declared as workspace dependencies

Start by reading what crypto code exists in the Tauri app, then extract into the shared module.

---

## Files to Touch

### Kosmos (genesis)
- No genesis changes needed — praxeis already declare the correct stoicheion steps

### Chora (implementation)
- `crates/kosmos/src/crypto.rs` (new) — shared crypto module
- `crates/kosmos/src/host.rs` — replace inline BLAKE3 with crypto module call
- `crates/kosmos/src/interpreter/steps.rs` — wire crypto stoicheion implementations
- `crates/kosmos/Cargo.toml` — add crypto crate dependencies
- `crates/kosmos/tests/crypto.rs` (new) — crypto tests

### Docs (written FIRST, verified LAST)
- `docs/reference/cryptographic-operations.md` — cryptographic operations specification

---

## Verification

```bash
# Build
cargo build 2>&1

# Tests
cargo test 2>&1

# Canonical hashing determinism
cargo test hash_content 2>&1

# Full-circle coherence
cargo test full_circle 2>&1

# No inline crypto remaining
grep -rn "blake3::hash" crates/kosmos/src/ --include="*.rs" | grep -v crypto.rs
# Should show 0 results (all routed through crypto module)
```

---

## What This Enables

When the crypto layer is wired:
- **Content addressing is real.** Every entity has a deterministic BLAKE3 hash. `emit → bootstrap → emit` produces identical hashes. Integrity is verifiable.
- **Phoreta bundles are trustworthy.** Signed bundles can be exported, verified, and imported across oikoi with cryptographic guarantees.
- **The keyring is principled.** Keys are encrypted at rest, unlocked into session, auto-locked on timeout. No plaintext keys persisting beyond session scope.
- **Stoicheia use real crypto.** When a praxis invokes `hash-content` or `sign-content`, it calls through to the shared module — not a placeholder.
- **The Tauri app doesn't duplicate.** One crypto module in the core crate, imported by both the interpreter and the UI. No divergent implementations.
- **The foundation for federation trust.** When oikoi exchange phoreta, cryptographic verification ensures the content is authentic and untampered.
