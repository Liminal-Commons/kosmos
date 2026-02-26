<!-- =============================================================================
<!-- GENERATED FILE - DO NOT EDIT DIRECTLY -->
<!-- =============================================================================
<!-- Emitted by: emit_cycle (demiurge/emit-genesis) -->
<!-- Source: genesis/hypostasis/REFERENCE.md -->
<!-- -->
<!-- To modify: -->
<!--   1. Edit the source in genesis/ -->
<!--   2. Re-run emit-genesis -->
<!-- -->
<!-- See: genesis/EXTENDING.md -->
<!-- =============================================================================

# Hypostasis Reference

underlying reality, substrate replication.

---

## Praxeis (Operations)

🔧 = Exposed as MCP tool

### add-credential 🔧

Add an encrypted credential for an external service.

**Tier:** 3 | **ID:** `praxis/hypostasis/add-credential`

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `service` | string | ✓ | Service provider (e.g., 'openai', 'anthropic') |
| `credential_value` | string | ✓ | The API key or token to encrypt |
| `label` | string | ✓ | Human-readable label (e.g., 'My OpenAI Key') |
| `grants_attainment` | string | ✓ | Attainment name granted when unlocked (e.g., 'use-embedding-api') |
| `credential_type` | string |  | Type of credential (api-key, oauth-token, bearer-token) |
| `scope` | string |  | Scope of access (prosopon or oikos) |
| `prosopon_id` | string | ✓ | Prosopon who owns this credential |
| `oikos_id` | string |  | Oikos to share with (if scope is oikos) |

### add-genesis-signature 🔧

Add a signature to a genesis record.

**Tier:** 3 | **ID:** `praxis/hypostasis/add-genesis-signature`

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `genesis_id` | string | ✓ | Genesis record to sign |
| `mnemonic` | string | ✓ | Signer's mnemonic |
| `oikos_id` | string | ✓ | Oikos context for key derivation |
| `attestation` | string | ✓ | Signer's attestation statement |

### begin-genesis-ceremony 🔧

Begin a new genesis signing ceremony.

**Tier:** 3 | **ID:** `praxis/hypostasis/begin-genesis-ceremony`

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `genesis_id` | string | ✓ | ID for the genesis record |
| `content` | string | ✓ | The constitutional content to sign |
| `threshold` | number |  | Number of signatures required (default 3) |

### change-keyring-password 🔧

Change the keyring password.

**Tier:** 3 | **ID:** `praxis/hypostasis/change-keyring-password`

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `keyring_id` | string | ✓ | Keyring to change password for |
| `old_password` | string | ✓ | Current password |
| `new_password` | string | ✓ | New password |
| `new_hint` | string |  | New password hint |

### check-keyring-status 🔧

Check if the keyring is currently unlocked.

**Tier:** 1 | **ID:** `praxis/hypostasis/check-keyring-status`

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `prosopon_id` | string |  | Check keyring for specific prosopon |

### check-session-attainment 🔧

Check if the current session has a specific attainment.

**Tier:** 1 | **ID:** `praxis/hypostasis/check-session-attainment`

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `attainment` | string | ✓ | Attainment name to check |

### compute-hash 🔧

Compute BLAKE3 hash of entity content.

**Tier:** 1 | **ID:** `praxis/hypostasis/compute-hash`

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `entity_id` | string | ✓ | Entity to compute hash for |

### create-keyring 🔧

Create an encrypted keyring for a prosopon.

**Tier:** 3 | **ID:** `praxis/hypostasis/create-keyring`

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `prosopon_id` | string | ✓ | Prosopon this keyring secures keys for |
| `mnemonic` | string | ✓ | BIP-39 24-word mnemonic phrase |
| `password` | string | ✓ | Password to encrypt the keyring |
| `password_hint` | string |  | Optional hint to help remember password |

### create-snapshot 🔧

Create a full state snapshot of an oikos.

**Tier:** 3 | **ID:** `praxis/hypostasis/create-snapshot`

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `oikos_id` | string |  | Oikos to snapshot (defaults to current dwelling oikos) |
| `include_embeddings` | boolean |  | Include embedding vectors (default false, they're large) |

### derive-oikos-key 🔧

Derive an oikos-scoped Ed25519 keypair.

**Tier:** 2 | **ID:** `praxis/hypostasis/derive-oikos-key`

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `mnemonic` | string | ✓ | BIP-39 mnemonic phrase (24 words) |
| `oikos_id` | string | ✓ | Oikos to derive key for |

### derive-key-from-session 🔧

Derive an oikos-scoped public key from the unlocked session.

**Tier:** 1 | **ID:** `praxis/hypostasis/derive-key-from-session`

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `oikos_id` | string | ✓ | Oikos to derive key for |

### export-prosopon 🔧

Export a prosopon for federation to another device.

**Tier:** 3 | **ID:** `praxis/hypostasis/export-prosopon`

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `prosopon_id` | string | ✓ | Prosopon to export |
| `mnemonic` | string | ✓ | Mnemonic to sign the export |
| `oikos_id` | string | ✓ | Oikos context for signing key |
| `include_sessions` | boolean |  | Include session/conversation history (default false) |

### export-phoreta 🔧

Create a signed phoreta bundle for export.

**Tier:** 3 | **ID:** `praxis/hypostasis/export-phoreta`

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `entity_ids` | array | ✓ | Entities to include in the bundle |
| `include_dependencies` | boolean |  | Include composed-from chains (default true) |
| `include_bonds` | boolean |  | Include bonds involving these entities (default true) |

### finalize-genesis 🔧

Finalize a genesis record once threshold is reached.

**Tier:** 3 | **ID:** `praxis/hypostasis/finalize-genesis`

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `genesis_id` | string | ✓ | Genesis record to finalize |

### generate-mnemonic 🔧

Generate a new BIP-39 mnemonic phrase.

**Tier:** 2 | **ID:** `praxis/hypostasis/generate-mnemonic`

*No parameters*

### get-credential-value

Get a decrypted credential value from the session.

**Tier:** 1 | **ID:** `praxis/hypostasis/get-credential-value`

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `service` | string | ✓ | Service to get credential for (e.g., 'openai') |
| `required_attainment` | string |  | Attainment to check (optional) |

### get-genesis-status 🔧

Get the current status of a genesis signing ceremony.

**Tier:** 1 | **ID:** `praxis/hypostasis/get-genesis-status`

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `genesis_id` | string | ✓ | Genesis record to check |

### import-prosopon 🔧

Import a prosopon from another device.

**Tier:** 3 | **ID:** `praxis/hypostasis/import-prosopon`

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `export_bundle` | object | ✓ | The prosopon export bundle |
| `mnemonic` | string | ✓ | Mnemonic (should match original) |
| `oikos_id` | string | ✓ | Oikos context for key verification |
| `merge_strategy` | string |  | How to handle conflicts (default newer_wins) |

### import-phoreta 🔧

Verify and import a phoreta bundle.

**Tier:** 3 | **ID:** `praxis/hypostasis/import-phoreta`

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `phoreta` | object | ✓ | The phoreta bundle to import |
| `verify_signatures` | boolean |  | Verify origin signatures (default true) |
| `merge_strategy` | string |  | newer_wins, local_wins, or fail_on_conflict (default newer_wins) |

### list-credentials 🔧

List credentials for a prosopon.

**Tier:** 1 | **ID:** `praxis/hypostasis/list-credentials`

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `prosopon_id` | string | ✓ | Prosopon to list credentials for |

### lock-keyring 🔧

Lock the keyring, clearing the session seed.

**Tier:** 2 | **ID:** `praxis/hypostasis/lock-keyring`

*No parameters*

### remove-credential 🔧

Remove (revoke) a credential.

**Tier:** 3 | **ID:** `praxis/hypostasis/remove-credential`

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `credential_id` | string | ✓ | Credential to remove |

### restore-snapshot 🔧

Restore state from a snapshot.

**Tier:** 3 | **ID:** `praxis/hypostasis/restore-snapshot`

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `snapshot` | object | ✓ | The snapshot to restore |
| `merge_strategy` | string |  | How to handle conflicts (default newer_wins) |

### sign-content 🔧

Sign content with oikos-scoped key.

**Tier:** 2 | **ID:** `praxis/hypostasis/sign-content`

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `mnemonic` | string | ✓ | BIP-39 mnemonic phrase |
| `oikos_id` | string | ✓ | Oikos whose key to use for signing |
| `content` | string | ✓ | Content to sign |

### sign-with-session 🔧

Sign content using the unlocked session key.

**Tier:** 2 | **ID:** `praxis/hypostasis/sign-with-session`

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `oikos_id` | string | ✓ | Oikos context for key derivation |
| `content` | string | ✓ | Content to sign |

### sync-delta 🔧

Export changes since a given version/timestamp.

**Tier:** 2 | **ID:** `praxis/hypostasis/sync-delta`

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `since_version` | number |  | Export entities with version > this |
| `since_timestamp` | string |  | Export entities updated after this timestamp |

### sync-devices 🔧

Sync state between two devices with same prosopon.

**Tier:** 3 | **ID:** `praxis/hypostasis/sync-devices`

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `mnemonic` | string | ✓ | Shared mnemonic for signing/verification |
| `oikos_id` | string | ✓ | Oikos context |
| `local_version` | number | ✓ | Local sync version (last sync point) |
| `remote_delta` | object |  | Delta from remote device (if receiving) |

### unlock-credentials 🔧

Unlock credentials for the session, granting their attainments.

**Tier:** 2 | **ID:** `praxis/hypostasis/unlock-credentials`

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `prosopon_id` | string | ✓ | Prosopon whose credentials to unlock |

### unlock-keyring 🔧

Unlock a keyring with password.

**Tier:** 2 | **ID:** `praxis/hypostasis/unlock-keyring`

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `keyring_id` | string | ✓ | Keyring to unlock |
| `password` | string | ✓ | Password to decrypt the keyring |

### verify-chain 🔧

Verify composition chain to genesis.

**Tier:** 2 | **ID:** `praxis/hypostasis/verify-chain`

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `entity_id` | string | ✓ | Entity to verify chain for |
| `max_depth` | number |  | Maximum chain depth (default 100) |

### verify-genesis 🔧

Verify genesis record signatures.

**Tier:** 2 | **ID:** `praxis/hypostasis/verify-genesis`

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `genesis_id` | string |  | Genesis record to verify (defaults to phasis/genesis-root) |

### verify-signature 🔧

Verify a signature against content and public key.

**Tier:** 1 | **ID:** `praxis/hypostasis/verify-signature`

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `content` | string | ✓ | Content that was signed |
| `signature` | string | ✓ | Base64-encoded signature |
| `public_key` | string | ✓ | Base64-encoded public key |

## Desmoi (Bond Types)

| Desmos | From → To | Description |
|--------|-----------|-------------|
| `composed-from` | * → * | Entity was composed from this artifact-definition |
| `signed-by` | any → prosopon | Entity signed by prosopon keypair — cryptographic attribution |

---

*Generated from schema definitions. Do not edit directly.*
