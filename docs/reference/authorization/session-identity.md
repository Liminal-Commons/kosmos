# Session, Identity & Authentication

The authentication subsystem that connects human identity to kosmos operations. Spans three layers: Thyra (UI), kosmos-mcp (transport bridge), and kosmos (interpreter).

**This document is prescriptive.** It describes the target state. Where implementation diverges, the code has a gap.

---

## Launch Flow

Thyra enforces authentication before any kosmos interaction. The flow:

```
App launch
  ├─ kosmos-mcp starts (locked bridge, no credentials)
  ├─ check_launch_state()
  │   └─ Returns ProsoponInfo list (id, name, kind, has_keyring, home_oikos_id)
  │
  ├─ WELCOME SCREEN (always shown first):
  │   Presents all entry paths based on prosopon list:
  │   ├─ "Unlock" — if any human prosopon has has_keyring: true
  │   ├─ "Recover existing identity" — if any human prosopon lacks a keyring
  │   └─ "Create new identity" — always available
  │   User chooses → routes to appropriate screen
  │
  ├─ ONBOARDING (user chose "Create new identity"):
  │   1. Name → 2. Generate mnemonic (user writes down) → 3. Create password
  │   4. create_keyring() + complete_onboarding()
  │   5. Auto-unlock → arise → main app
  │
  ├─ UNLOCK (user chose "Unlock"):
  │   User enters password → unlock_keyring() → arise → main app
  │
  └─ RECOVERY (user chose "Recover existing identity"):
      User enters mnemonic + new password → recreate keyring → arise → main app
```

Each sub-screen has a "Back" button that returns to the WelcomeScreen via `returnToWelcome()`.

**Authentication is blocking.** The main app is not accessible until the user proves identity via password or mnemonic recovery. The unlock screen is NOT a banner — it is the only screen visible until authentication succeeds.

### Deterministic Identity Derivation

The prosopon ID is derived deterministically from the mnemonic — same mnemonic always produces the same prosopon ID. Identity is derivation, not storage.

```
mnemonic (BIP-39, 24 words)
  → master seed (BIP-39 derivation)
    → master public key (Ed25519)
      → prosopon ID: "prosopon/" + BLAKE3(public_key_bytes)[..16] hex
```

The self-oikos derives from the prosopon: `oikos/self-{prosopon_hash}`. One member, one steward. This is the prosopon's sovereign ground.

After a database reset, the same mnemonic produces the same prosopon ID and self-oikos ID. Identity is re-derived, not recovered from backup.

### Keyring Persistence — The Sovereign Substrate

The mnemonic is the **sovereign substrate** — the user holds it, the system derives from it. Kleidoura and credential entities are first-class graph entities, not projections of a platform-specific store.

What persists where:
- **Mnemonic**: held by the user (paper, password manager — their sovereignty)
- **Kleidoura + Credentials**: kosmos database (entities with bonds, like everything else)
- **Phoreta emission**: local filesystem — auto-emitted signed bundles that survive DB wipes
- **Session token**: OS keyring (ephemeral cross-process IPC between Thyra and kosmos-mcp)

Recovery after a database wipe follows the same path as federation: mnemonic re-derivation + phoreta import. The mechanism that moves state between devices also restores state locally. One pattern, not two.

The user's 24-word mnemonic is the ultimate recovery mechanism. As long as the user has their mnemonic, they can recreate their keyring and re-derive all keys. Phoreta emission restores credential and entity state without re-entry.

### Bootstrap Dwelling Discovery

After constitutional bootstrap (genesis), a **discovery phase** scans for prior dwelling state:

```
Genesis bootstrap complete
  ├─ Read phoreta store index
  │   ├─ Found: import from index → derive prosopon ID → derive self-oikos
  │   │         → establish membership bonds → present unlock screen
  │   └─ Empty: present welcome screen (fresh setup)
  │
  └─ After unlock, import credential phoreta
      ├─ Found: compose credential entities → bond to providers → trigger attainment derivation
      └─ Empty: credential manager shows empty state
```

Discovery does not create from nothing — it re-derives from what persists. This is the reconciliation pattern (sense → compare → act) applied to local phoreta emission. The same format used for federation serves recovery.

### Arise Requires Authentication

`arise()` MUST only succeed after authentication:

- After onboarding (keyring just created, auto-unlocked)
- After password unlock (kleidoura decrypted)
- After mnemonic recovery (keyring recreated)

The app MUST NOT auto-arise using a prosopon from genesis without proof of identity. The existence of `prosopon/victor` in genesis does not mean the user IS Victor — they must prove it via password or mnemonic.

---

## Architecture

```
Thyra (Tauri)                    kosmos-mcp (HTTP server)              kosmos (interpreter)
┌─────────────────┐              ┌─────────────────────┐              ┌──────────────────┐
│ KeyringSession   │─push-token─→│ McpSessionBridge     │──bridge──→  │ SessionBridge     │
│ (process memory) │              │ (process memory)     │              │ (trait on Host)   │
│                  │              │                      │              │                   │
│ Token write ─────┼──OS keyring──┼→ SessionToken::      │              │ require_attainment│
│ (session IPC)    │              │  try_read()          │              │ get_credential()  │
└─────────────────┘              └─────────────────────┘              └──────────────────┘
```

**Principle:** Decrypted credential values never stored in the database — only encrypted entities. Session state lives in chora (process memory), not kosmos (graph). The session bridge is the only credential source — no environment variable fallbacks.

### Dwelling Context and Visibility

The session carries dwelling context that determines what the prosopon can see:

- **prosopon_id** — WHO is acting (identity)
- **oikos_id** — WHERE visibility is rooted (which oikoi determine what's visible)
- **parousia_id** — WHICH embodied presence

All query operations receive this dwelling context. Visibility checks filter results: a prosopon sees only entities that `exists-in` any oikos they are `member-of`. Without a session, visibility filtering is bypassed (internal/system operations).

See [visibility-semantics.md](../dwelling/visibility-semantics.md) for the formal visibility model.

---

## Identity Entities (in kosmos graph)

### prosopon
Persistent identity that survives across sessions.

```yaml
prosopon/victor:
  eidos: prosopon
  data:
    name: "Victor"
    kind: human
    public_key: "b196e54638..."   # Ed25519 public key (hex)
```

### kleidoura (keyring)
Encrypted master seed bonded to a prosopon.

```yaml
kleidoura/<uuid>:
  eidos: kleidoura
  data:
    encrypted_seed: "<base64>"    # AES-256-GCM encrypted 64-byte seed
    nonce: "<base64>"             # GCM nonce
    salt: "<base64>"              # Argon2 salt
  bonds:
    - desmos: secures-key-for
      to: prosopon/victor
```

### credential
Encrypted API key or token, bonded to a prosopon.

```yaml
credential/<uuid>:
  eidos: credential
  data:
    service: "anthropic"          # Service provider
    label: "Anthropic API Key"
    encrypted_value: "<base64>"   # AES-256-GCM encrypted
    nonce: "<base64>"
    grants_attainment: "use-anthropic-api"
    credential_type: "api-key"
  bonds:
    - desmos: credential-of
      to: prosopon/victor
```

---

## Thyra Layer (Tauri)

**File:** `app/src-tauri/src/main.rs`

### UI States

Thyra has four mutually exclusive UI states before the main app:

| State | Condition | Screen | Blocking? |
|-------|-----------|--------|-----------|
| **Welcome** | Always shown first | Entry path selection (unlock/recover/create) | Yes |
| **Onboarding** | User chose "Create new identity" | Full-screen: name → mnemonic → password | Yes |
| **Unlock** | User chose "Unlock" | Full-screen: password entry | Yes |
| **Recovery** | User chose "Recover existing identity" | Full-screen: mnemonic + password entry | Yes |
| **Main app** | Keyring unlocked | Layout engine + modes | — |

The WelcomeScreen replaces auto-detection routing. Genesis seeds constitutional prosopa (`prosopon/victor`, `prosopon/claude`), so the old approach of checking "does a prosopon exist?" always returned true — making auto-routing unreliable. The user now explicitly chooses their entry path.

No state shows the main app content. The user MUST authenticate first.

### KeyringSession

In-memory decrypted keyring state. Created on unlock, cleared on lock.

| Field | Type | Description |
|-------|------|-------------|
| `master_seed` | `[u8; 64]` | BIP-39 derived seed |
| `unlocked_at` | `Instant` | When unlock occurred |
| `auto_lock_timeout_secs` | `u64` | Default: 900 (15 min) |
| `credentials` | `HashMap<String, SessionCredential>` | Decrypted credentials |
| `attainments` | `HashSet<String>` | Active attainments from credentials |

### Tauri Commands

| Command | Auth Required | Description |
|---------|--------------|-------------|
| `check_launch_state` | No | Returns `{prosopa: [{id, name, kind, has_keyring, home_oikos_id}]}` |
| `check_keyring_status` | No | Returns `{exists, unlocked, prosopon_id}` |
| `generate_mnemonic` | No | Returns 24-word BIP-39 mnemonic |
| `complete_onboarding` | No | Creates prosopon + oikos from name + mnemonic |
| `create_keyring` | Dwelling | Encrypts mnemonic with password, creates kleidoura entity |
| `unlock_keyring` | Dwelling | Decrypts seed, creates KeyringSession, pushes token |
| `lock_keyring` | Dwelling | Zeros seed, clears session, pushes null token |
| `recover_keyring` | No | Re-creates kleidoura from mnemonic + new password for existing prosopon |
| `add_credential` | Unlocked | Encrypts + stores credential, re-pushes token |
| `remove_credential` | Unlocked | Removes credential, re-pushes token |
| `list_credentials` | Dwelling | Returns metadata only (never values) |
| `list_session_attainments` | Dwelling | Returns current attainments from session |
| `arise` | Unlocked | Creates parousia + session, sets dwelling context |

**Note:** `arise` requires Unlocked state. It is called AFTER authentication, not before.

### Session Token Flow

When the keyring is unlocked, `write_session_token()` executes:

1. Query prosopon's oikos memberships via `trace_bonds`
2. Gather all attainments from keyring session
3. Build `SessionToken` with `prosopon_id`, `oikoi`, `attainments`, `master_seed_b64`
4. Encode as base64url JSON
5. Write to OS keyring (`com.liminalcommons.kosmos` / `session-token`)
6. Set on soma-client via `client.set_session_token()`
7. Push to kosmos-mcp via `POST /api/session/push-token`

---

## kosmos-mcp Layer (Transport Bridge)

**File:** `crates/kosmos-mcp/src/lib.rs`

### SessionToken

Self-contained session state, encoded as base64url JSON.

```rust
pub struct SessionToken {
    pub prosopon_id: String,
    pub oikoi: Vec<String>,
    pub attainments: Vec<String>,
    pub issued_at: String,            // RFC3339
    pub expires_at: String,           // RFC3339
    pub master_seed_b64: Option<String>,  // Base64 of 64-byte seed
}
```

| Method | Description |
|--------|-------------|
| `try_read()` | Read from OS keyring, validate expiry. Checks `KOSMOS_NO_SESSION` and `KOSMOS_TEST_SESSION` env vars. |
| `from_raw(raw)` | Decode base64url JSON string |
| `has_attainment(att)` | Check attainment presence |
| `has_signing_capability()` | `master_seed_b64.is_some()` |
| `get_master_seed()` | Decode base64 to `[u8; 64]` |

### McpSessionBridge

Implements `SessionBridge` trait for the MCP process.

**Two constructors:**

| Constructor | When Used | Signing? | Credentials? |
|-------------|----------|----------|-------------|
| `McpSessionBridge::locked(prosopon, oikoi, attainments)` | At `arise` time | No | No |
| `McpSessionBridge::from_token(session_token)` | After keyring unlock + push | If seed present | Populated from token |

### ValidatedSession (HTTP Auth)

**File:** `crates/kosmos-mcp/src/auth.rs`

Axum extractor that validates `Authorization: Bearer <token>` headers on REST endpoints.

```rust
pub struct ValidatedSession {
    pub prosopon_id: String,
    pub oikoi: Vec<String>,
    pub attainments: Vec<String>,
}
```

Extracted automatically from request headers. Returns 401 if missing/expired.

### REST Endpoints

**POST /api/session/push-token** — Receive token from Thyra

```json
{ "token": "<base64url-encoded>" }   // or { "token": null } to lock
```

Sets or clears the `McpSessionBridge` on `HostContext`. All subsequent interpreter operations use this bridge.

**POST /api/session/arise** — Create session

Creates parousia + session entities, computes attainments from oikos memberships, returns token. Sets a **locked** bridge (no credentials until keyring unlock).

---

## kosmos Layer (Interpreter)

**File:** `crates/kosmos/src/host.rs`

### SessionBridge Trait

```rust
pub trait SessionBridge: Send + Sync {
    fn is_unlocked(&self) -> bool;
    fn get_master_seed(&self) -> Option<[u8; 64]>;
    fn store_credential(&self, credential_id: String, value: String,
                        service: String, grants_attainment: String);
    fn get_credential(&self, service: &str) -> Option<(String, String)>;
    fn remove_credential(&self, credential_id: &str) -> bool;
    fn has_attainment(&self, attainment: &str) -> bool;
    fn list_attainments(&self) -> Vec<String>;
    fn list_credentials(&self) -> Vec<(String, String, String)>;
}
```

Stored on `HostContext` as `Arc<RwLock<Option<Arc<dyn SessionBridge>>>>`. Interior mutability allows dynamic updates after `Arc` wrapping.

### Attainment Gating

**File:** `crates/kosmos/src/interpreter/steps.rs`

```rust
fn require_attainment(ctx: &HostContext, attainment: &str, service_hint: &str) -> Result<()>
```

Called before any external API step:

| Step | Required Attainment |
|------|-------------------|
| `generated` | `use-anthropic-api` |
| `infer` | `use-anthropic-api` |
| `embed` | `use-embedding-api` |
| `index` | `use-embedding-api` (if no pre-computed embedding) |

Fails with clear error message if no bridge exists or attainment is missing.

### Credential Access

`HostContext::infer()` and `HostContext::embed()` obtain API keys exclusively from the session bridge:

```rust
let api_key = self.session_bridge()
    .and_then(|b| b.get_credential("anthropic"))
    .map(|(_, value)| value)
    .ok_or_else(|| KosmosError::Invalid("API key not configured".into()))?;
```

No environment variable fallback. Bridge presence is definitive.

---

## MCP Client Context

When Claude Code (or any MCP client) connects:

1. kosmos-mcp reads `SessionToken::try_read()` from OS keyring
2. If token exists and has signing capability, creates `McpSessionBridge::from_token()`
3. Sets bridge on `HostContext`
4. MCP tools are filtered by attainments before client sees them
5. Praxis invocations inject `$_prosopon` and `$_oikos` from session context

The MCP client operates AS the authenticated human prosopon, in the context of the specified oikos, for the duration of the session. All entity creation, composition, and phasis is attributed to the prosopon.

When no token exists (headless mode with `KOSMOS_NO_SESSION=1`), MCP operates without a bridge — credential-gated operations will fail cleanly.

---

## Attainments

| Attainment | Granted By | Gates |
|------------|-----------|-------|
| `use-anthropic-api` | Anthropic credential | infer, generated, governed-inference steps |
| `use-openai-api` | OpenAI credential | embed, index steps |
| `use-embedding-api` | OpenAI credential | embed, index steps |
| `mcp-essential` | oikos/kosmos membership | Core MCP tool visibility |

---

## Environment Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `KOSMOS_DB` | Database path | `~/.kosmos/kosmos.db` |
| `KOSMOS_NO_SESSION=1` | Skip OS keyring reads (headless) | Not set |
| `KOSMOS_TEST_SESSION` | JSON session token for testing | Not set |

---

## Security

- **Encryption:** AES-256-GCM with random nonce per operation
- **Key derivation:** Argon2 (password → symmetric key for seed encryption)
- **Master seed:** 64-byte BIP-39 entropy, used for HKDF credential encryption
- **Phoreta emission:** Signed bundles on local filesystem (identity + credential persistence across DB wipes)
- **Auto-lock:** 15-minute timeout (configurable), clears all in-memory state
- **Cross-process:** Session token in OS keyring allows kosmos-mcp to inherit session (ephemeral IPC only)
- **No bypass:** Main app inaccessible without authentication. No "browse while locked" mode.

---

## Implementation Gaps

All previously listed gaps have been closed:

- ~~Unlock screen is a non-blocking banner~~ — Now a full-screen blocking gate
- ~~No recovery flow~~ — `recover_keyring` command + RecoveryScreen implemented
- ~~`just dev` destroys kleidoura~~ — Recovery screen presented automatically when keyring missing
- ~~Auto-arise without auth~~ — `initializeKosmosCommon` no longer auto-arises; requires unlock first
- ~~`check_launch_state` missing `keyring_exists`~~ — Added `keyring_exists` field, removed `db_exists`
- ~~`arise` doesn't require Unlocked~~ — Now checks keyring exists → must be unlocked
