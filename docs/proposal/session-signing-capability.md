# Session Signing Capability

*Extending SessionToken to include signing capability for MCP*

**Status:** DRAFT

## The Gap

Currently:
- Thyra holds master_seed in process memory when unlocked
- SessionToken (OS keyring) contains identity claims only: prosopon_id, oikoi, attainments
- MCP reads SessionToken but cannot sign (no master_seed access)
- ekdosis/sign-topos fails with "Session not available for signing"

## Architectural Alignment

From **Kosmogonia** - Axiom II: Authority:
> "The kosmos acts only as authorized by those who dwell in it."
> "Context is not passed. Context is position."

From **Hypostasis** - T23:
> "Session state bridges security and usability"

From **Hypostasis** - Security model:
> "Decrypted material lives in chora (process memory), not kosmos (entities)."

The session IS the dwelling position. If MCP has valid session, it should have the capabilities of that position - including signing.

## Design

### Principle

The SessionToken should include signing capability, not just identity claims. When Thyra unlocks the keyring, the session provides full dwelling capability.

### SessionToken Extension

```rust
// Current
pub struct SessionToken {
    pub prosopon_id: String,
    pub oikoi: Vec<String>,
    pub attainments: Vec<String>,
    pub issued_at: String,
    pub expires_at: String,
}

// Extended
pub struct SessionToken {
    pub prosopon_id: String,
    pub oikoi: Vec<String>,
    pub attainments: Vec<String>,
    pub issued_at: String,
    pub expires_at: String,
    // NEW: Session signing capability
    pub master_seed_b64: Option<String>,  // base64-encoded 64-byte seed
}
```

### Flow

**Thyra on unlock:**
1. Decrypt master_seed from kleidoura (already happening)
2. Include master_seed in SessionToken payload (base64 encoded)
3. Write to OS keyring (already happening)

**Thyra on lock:**
1. Clear master_seed from memory (already happening)
2. Delete SessionToken from OS keyring (already happening)

**MCP on read:**
1. Read SessionToken from OS keyring (already happening)
2. Decode master_seed from token
3. Implement SessionBridge with decoded seed
4. Session signing now works

### Security Analysis

| Concern | Mitigation |
|---------|------------|
| Master seed in OS keyring | OS keyring provides access control - only user's processes can read |
| Exposure window | Session expiry (24h default) + explicit lock deletes token |
| Process isolation | Each process reads independently from OS keyring |
| Theft if machine compromised | Same risk as current keyring - machine access = game over |

The OS keyring is already trusted for:
- Session tokens (identity claims)
- Potentially sensitive attainments
- Service name for credential lookup

Adding master_seed extends this trust, which is consistent with "session state bridges security and usability."

### Implementation Changes

#### 1. Thyra: write_session_token (main.rs)

```rust
fn write_session_token(
    host: &HostContext,
    dwelling: &DwellingContext,
    state: &State<AppState>,
) -> Result<(), String> {
    use base64::Engine;

    // ... existing oikos/attainment gathering ...

    // NEW: Get master seed from session
    let keyring_guard = state.keyring.lock().unwrap();
    let master_seed_b64 = keyring_guard
        .as_ref()
        .map(|s| base64::engine::general_purpose::STANDARD.encode(&s.master_seed));
    drop(keyring_guard);

    let payload = json!({
        "prosopon_id": dwelling.prosopon_id,
        "oikoi": oikoi,
        "attainments": attainments,
        "issued_at": now.to_rfc3339(),
        "expires_at": expires_at.to_rfc3339(),
        "master_seed_b64": master_seed_b64  // NEW
    });

    // ... rest unchanged ...
}
```

#### 2. MCP: SessionToken struct (lib.rs)

```rust
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct SessionToken {
    pub prosopon_id: String,
    pub oikoi: Vec<String>,
    pub attainments: Vec<String>,
    pub issued_at: String,
    pub expires_at: String,
    #[serde(default)]
    pub master_seed_b64: Option<String>,  // NEW
}

impl SessionToken {
    /// Get master seed if present in token
    pub fn get_master_seed(&self) -> Option<[u8; 64]> {
        use base64::Engine;

        let b64 = self.master_seed_b64.as_ref()?;
        let bytes = base64::engine::general_purpose::STANDARD
            .decode(b64)
            .ok()?;

        if bytes.len() != 64 {
            return None;
        }

        let mut seed = [0u8; 64];
        seed.copy_from_slice(&bytes);
        Some(seed)
    }
}
```

#### 3. MCP: Implement SessionBridge

```rust
/// MCP session bridge using SessionToken from OS keyring
pub struct McpSessionBridge {
    token: SessionToken,
    credentials: RwLock<HashMap<String, (String, String, String)>>, // service -> (id, value, attainment)
}

impl McpSessionBridge {
    pub fn from_token(token: SessionToken) -> Self {
        Self {
            token,
            credentials: RwLock::new(HashMap::new()),
        }
    }
}

impl SessionBridge for McpSessionBridge {
    fn is_unlocked(&self) -> bool {
        self.token.master_seed_b64.is_some()
    }

    fn get_master_seed(&self) -> Option<[u8; 64]> {
        self.token.get_master_seed()
    }

    fn has_attainment(&self, attainment: &str) -> bool {
        self.token.attainments.iter().any(|a| a == attainment)
    }

    fn list_attainments(&self) -> Vec<String> {
        self.token.attainments.clone()
    }

    // Credential operations delegate to in-memory store
    fn store_credential(&self, id: String, value: String, service: String, grants: String) {
        self.credentials.write().unwrap().insert(service.clone(), (id, value, grants));
    }

    fn get_credential(&self, service: &str) -> Option<(String, String)> {
        self.credentials.read().unwrap()
            .get(service)
            .map(|(id, value, _)| (id.clone(), value.clone()))
    }

    fn remove_credential(&self, credential_id: &str) -> bool {
        let mut creds = self.credentials.write().unwrap();
        let key = creds.iter()
            .find(|(_, (id, _, _))| id == credential_id)
            .map(|(k, _)| k.clone());
        if let Some(k) = key {
            creds.remove(&k);
            true
        } else {
            false
        }
    }

    fn list_credentials(&self) -> Vec<(String, String, String)> {
        self.credentials.read().unwrap()
            .values()
            .cloned()
            .collect()
    }
}
```

#### 4. MCP: Wire SessionBridge to HostContext

```rust
impl McpServer {
    pub async fn arise(&self) -> Result<(), McpError> {
        // ... existing code ...

        // If we have a session token with signing capability, create bridge
        if let Some(token) = SessionToken::try_read() {
            let bridge = Arc::new(McpSessionBridge::from_token(token));
            self.ctx.set_session_bridge(Some(bridge));
        }

        // ... rest of arise ...
    }
}
```

### Credential Flow (Bonus)

With McpSessionBridge, we can also populate credentials from the session. The cloudflare-r2 credential flow we implemented earlier would work by:

1. Thyra stores credential in session (already implemented)
2. SessionToken could include encrypted credentials (future extension)
3. MCP decrypts using master_seed and populates McpSessionBridge

For now, R2 credentials still need to come from SessionBridge.get_credential(), which Thyra populates. The MCP can read these via a separate mechanism or we extend SessionToken to include them.

## Testing

After implementation:

```bash
# 1. Unlock Thyra keyring (sets SessionToken with master_seed)
# 2. In Claude Code, test signing:
mcp__kosmos__nous_call-praxis(
  praxis_id: "praxis/ekdosis/sign-topos",
  params: { topos_prod_id: "topos-prod/test-ekdosis/0.1.0" }
)
# Should succeed with signature
```

## Future Considerations

1. **Credential inclusion**: Extend SessionToken to include encrypted credentials for full self-contained session
2. **Session key derivation**: Could derive session-specific keys instead of passing master_seed directly
3. **Hardware key support**: When hardware keys are supported, signing requests could be delegated

---

*The session bridges security and usability. Signing capability flows with dwelling position.*
