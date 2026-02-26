# Session Boundary — Clean Infrastructure Interface

*Prompt for Claude Code in the chora repository context.*

---

## Architectural Principle — The Bootstrap Substrate

Session is the **bootstrap substrate**. It enables access to kosmos, so it cannot itself be accessed through kosmos. This is the chicken-and-egg exception: the session boundary pattern (manifest/sense/unmanifest) applies conceptually, but the implementation must be hardcoded infrastructure — not homoiconic entities, not praxeis, not actuality mode dispatch.

SessionBridge already IS that hardcoded implementation:
- **Manifest** = unlock keyring, establish credentials in memory
- **Sense** = check session validity, query attainments, resolve credentials
- **Unmanifest** = lock keyring, clear credentials, expire token

Everything that happens *after* session is established — voice pipelines, LiveKit rooms, federation transport — can use the full actuality mode machinery because kosmos is reachable. Session is the ground that makes that possible.

This work treats the session token as the **interface between infrastructure and kosmos**. On the infrastructure side: HTTP middleware, Bearer tokens, base64url payloads, Axum extractors — standard patterns, using their own established idiom. On the kosmos side: DwellingContext, `$_prosopon`, attainment bonds, authorization gates — kosmos vocabulary on its own terms. The token is the boundary. Neither side reaches into the other.

### Broader context: Three moments of one loop

Chora's reactive system has three moments that compose into reconciliation loops:

```
mutation ──→ reflex ──→ reconciler ──→ actuality mode
             (detect)    (decide)       (act)
                                          │
             ┌────────────────────────────┘
             └── sense (feeds back as mutation)
```

- **Reflex** detects a change (trigger matches mutation)
- **Reconciler** decides what to do (compares intent with actuality)
- **Actuality mode** executes on the substrate (manifest/sense/unmanifest)

Session is where this loop bootstraps. Before session is established, there are no reflexes, no reconcilers, no actuality dispatch — just infrastructure. After session, the full loop is available for voice, deployment, federation, etc.

This prompt addresses the session boundary only. The broader unification of reflexes, reconcilers, and actuality modes is a separate concern.

---

## Methodology — Doc-Driven, Clean Break

This work follows **Doc → Test → Build → Verify Doc**, non-negotiably.

### The Cycle

1. **Doc (prescriptive)**: Update `docs/reference/attainment-authorization.md` to describe the session boundary — how the session token carries identity across the infrastructure/kosmos divide, what fields it contains, how DwellingContext is constructed from it.
2. **Test (assert the doc)**: Write tests that assert tokens round-trip with `parousia_id`, that DwellingContext construction handles missing sessions correctly, that `$_prosopon` and `$_parousia` populate from valid sessions. Tests should fail before implementation.
3. **Build (satisfy the tests)**: Implement until tests pass.
4. **Verify doc (confirm truth)**: After implementation, re-read the reference doc. Update deviations so the doc ends as truth.

### Clean Break — No Backward Compatibility Hacks

- **No empty-string DwellingContext.** When no session is present, dwelling is `None`. No fake DwellingContext with empty strings that silently fail `find_entity("")`.
- **No partial tokens.** The session token carries all identity fields needed by kosmos. If the token can't express dwelling, dwelling can't be established.
- **Infrastructure uses infrastructure idiom.** Token minting, validation, and extraction follow standard HTTP auth middleware patterns (Axum extractors, Bearer tokens, base64url-encoded payloads). Kosmos vocabulary stays on the kosmos side.

### What "Reference Doc" Means

Reference docs in this project are *prescriptive* (target state), not descriptive (current state). When code doesn't match a reference doc, the code has a gap — not the doc (unless the design changed). See CONTRIBUTING.md for the full methodology.

---

## Context

The attainment authorization architecture is complete: `requires-attainment` and `grants-praxis` bonds, the authorization gate in the interpreter, MCP projection via bond traversal, 8 passing tests. The infrastructure that feeds identity *into* that system has gaps at the token boundary.

**What works:**
- `ValidatedSession` Axum extractor validates Bearer tokens, checks expiry (standard HTTP auth middleware)
- `ValidatedSession` now includes `parousia_id: Option<String>` with `#[serde(default)]` for backward compatibility
- `SessionBridge` trait cleanly separates session state (chora/process memory) from entity state (kosmos/database)
- `check_praxis_authorization()` traverses `requires-attainment` bonds before praxis execution
- `execute_praxis()` populates `$_prosopon`, `$_oikos`, `$_parousia` from DwellingContext when present
- Call step propagates dwelling context to nested praxis calls (`scope.dwelling.clone()` at steps.rs:2246)
- Tauri's `write_session_token()` pushes token + credentials to kosmos-mcp for cross-process auth
- Token round-trip tests pass: `parousia_id` encodes/decodes correctly, old tokens without it parse as `None`

**What doesn't work:**
- `parousia_id` is never included in the session token payload — both minting paths (REST `session_arise` and Tauri `write_session_token`) omit it from the JSON they encode
- The REST `invoke_praxis` handler creates an empty-string DwellingContext when no session is present, instead of passing `None`. `find_entity("")` silently returns `None`, making `$_prosopon` unset
- `invoke_praxis_dwelling` takes `DwellingContext` (not `Option<DwellingContext>`), forcing callers to fabricate an empty one
- Sovereignty checks in politeia praxeis use ad-hoc trace/filter/assert patterns instead of attainment bonds

**Observed symptom:** After unlocking keyring and establishing a session, `thyra/commit-phasis` fails with "Cannot express without a prosopon" (assertion in `genesis/logos/praxeis/logos.yaml:62`).

---

## Current State

### Session Token (infrastructure side)

**`SessionToken` struct** (`crates/kosmos-mcp/src/lib.rs:124–134`):
```rust
pub struct SessionToken {
    pub prosopon_id: String,
    pub oikoi: Vec<String>,
    pub attainments: Vec<String>,
    pub issued_at: String,
    pub expires_at: String,
    #[serde(default)]
    pub master_seed_b64: Option<String>,
    // parousia_id: MISSING — needs to be added here too
}
```

**`ValidatedSession` struct** (`crates/kosmos-mcp/src/auth.rs:19–28`) — **DONE**:
```rust
pub struct ValidatedSession {
    pub prosopon_id: String,
    pub oikoi: Vec<String>,
    pub attainments: Vec<String>,
    pub issued_at: String,
    pub expires_at: String,
    #[serde(default)]
    pub parousia_id: Option<String>,  // ← ADDED, backward compatible
}
```

Token round-trip tests already pass (`test_session_token_roundtrip_with_parousia_id`, `test_session_token_backward_compatible`).

### Token minting (two paths, both incomplete)

**REST `session_arise`** (`crates/kosmos-mcp/src/rest.rs:559–638`):
- Creates parousia at line 559: `let parousia_id = format!("parousia/{}", uuid::Uuid::new_v4());`
- Creates session entity at line 580 with `parousia_id` in its data
- Mints token at line 632–638: **`parousia_id` NOT included in payload**

**Tauri `write_session_token`** (`app/src-tauri/src/main.rs:2675–2752`):
- Receives `dwelling: &DwellingContext` which HAS `parousia_id`
- Builds token at line 2727–2734: **`parousia_id` NOT included in payload**

### DwellingContext construction (the leak)

**REST `invoke_praxis`** (`crates/kosmos-mcp/src/rest.rs:423–455`):
```rust
let dwelling = session.0.map(|s| DwellingContext {
    prosopon_id: s.prosopon_id.clone(),
    oikos_id: s.oikoi.first().cloned().unwrap_or_default(),
    parousia_id: None,       // ← always None (not in token)
    locale: None,
}).unwrap_or_else(|| DwellingContext {
    prosopon_id: String::new(),  // ← empty string when no session
    oikos_id: String::new(),
    parousia_id: None,
    locale: None,
});
```

This always passes `Some(dwelling)` — even when the session is absent. `find_entity("")` returns `None`, so `$_prosopon` is never set.

### `invoke_praxis_dwelling` signature

**`host.rs`** — accepts `DwellingContext` (not `Option<DwellingContext>`):
```rust
pub fn invoke_praxis_dwelling(&self, praxis_id: &str, params: Value, dwelling: DwellingContext) -> Result<Value>
```

Callers must always provide a DwellingContext, even when there's no session. This forces the empty-string fabrication above.

### Ad-hoc sovereignty checks

**`genesis/politeia/praxeis/politeia.yaml`** — ~5 praxeis contain:
```yaml
- step: trace
  from: "$_parousia"
  desmos: sovereign-to
  bind_to: sovereignty

- step: filter
  source: "$sovereignty"
  where: "to_id == $oikos_id"
  bind_to: is_sovereign

- step: assert
  condition: "$is_sovereign"
  message: "Only the sovereign can ..."
```

This is authorization logic in YAML steps — the pattern the attainment work was supposed to eliminate. Sovereignty should be an attainment derived from the `sovereign-to` bond, checked by the authorization gate.

---

## Design

### The boundary principle

The session token is the interface between two sides:

| Side | Concern | Idiom |
|------|---------|-------|
| **Infrastructure** | Minting, validating, extracting tokens | HTTP middleware, Bearer auth, base64url, Axum extractors |
| **Kosmos** | DwellingContext, `$_prosopon`, attainment bonds, authorization | Graph traversal, bond topology, praxis execution |

Infrastructure produces a token with identity fields. Kosmos consumes it to construct dwelling. Neither side reaches into the other.

### Token payload (target state)

```json
{
  "prosopon_id": "prosopon/victor",
  "parousia_id": "parousia/abc-123",
  "oikoi": ["oikos/victors-oikos"],
  "attainments": ["attainment/mcp-essential", "attainment/govern"],
  "issued_at": "2026-02-10T10:00:00Z",
  "expires_at": "2026-02-11T10:00:00Z",
  "master_seed_b64": "..."
}
```

### DwellingContext construction (target state)

```rust
// When session is present: build dwelling from token
let dwelling = session.0.map(|s| DwellingContext {
    prosopon_id: s.prosopon_id.clone(),
    oikos_id: s.oikoi.first().cloned().unwrap_or_default(),
    parousia_id: s.parousia_id.clone(),  // from token
    locale: None,
});

// When session is absent: dwelling is None (not empty strings)
// Pass Option<DwellingContext> — let the interpreter handle None correctly
```

### Sovereignty as attainment

```yaml
# Entity
- eidos: attainment
  id: attainment/sovereign
  data:
    name: sovereign
    description: "Sovereign authority over an oikos"
    scope: oikos

# Bond: oikos grants sovereignty attainment
- from_id: oikos/victors-oikos
  to_id: attainment/sovereign
  desmos: grants-attainment

# Bond: praxis requires sovereignty
- from_id: praxis/politeia/invite-to-oikos
  to_id: attainment/sovereign
  desmos: requires-attainment
```

The authorization gate checks this automatically. No YAML trace/filter/assert needed.

---

## Implementation Order

### Step 1: Doc (update reference spec)

**Update `docs/reference/attainment-authorization.md`** to add:
- Session token as the identity boundary (what fields, who mints, who consumes)
- `parousia_id` in token payload
- DwellingContext construction from token (when present) or None (when absent)
- Sovereignty as an attainment (replacing ad-hoc YAML checks)

### Step 2: Test (assert the doc)

**Write tests BEFORE implementation:**

Token tests — **DONE** (already in `crates/kosmos-mcp/src/auth.rs` test module):
1. ~~`test_session_token_roundtrip_with_parousia_id`~~ — PASSING
2. ~~`test_session_token_backward_compatible`~~ — PASSING

Dwelling tests (new file `crates/kosmos/tests/dwelling_propagation.rs`):
3. `test_dwelling_populates_prosopon` — `execute_praxis` with valid dwelling sets `$_prosopon`
4. `test_dwelling_populates_parousia` — `execute_praxis` with `parousia_id` sets `$_parousia`
5. `test_none_dwelling_allows_public_praxis` — `execute_praxis` with `None` dwelling allows public praxis
6. `test_none_dwelling_blocks_gated_praxis_in_bootstrap` — `execute_praxis` with `None` dwelling allows gated praxis (bootstrap bypass)

Sovereignty tests (add to `crates/kosmos/tests/attainment_authorization.rs`):
7. `test_sovereign_attainment_gates_invite` — `politeia/invite-to-oikos` fails without `attainment/sovereign`
8. `test_sovereign_attainment_derived_from_oikos` — creating oikos + sovereign-to bond → sovereignty attainment derived

### Step 3: Genesis (sovereignty attainment)

9. **Define `attainment/sovereign`** in `genesis/politeia/entities/` with `scope: oikos`
10. **Add `grants-attainment → attainment/sovereign`** on oikoi that have a sovereign
11. **Add `requires-attainment → attainment/sovereign`** bonds to sovereignty-gated praxeis:
    - `praxis/politeia/invite-to-oikos`
    - `praxis/politeia/configure-federation`
    - `praxis/politeia/configure-topos-distribution`
    - `praxis/politeia/establish-federation-bond`
    - Any other praxeis with ad-hoc sovereignty checks
12. **Remove ad-hoc trace/filter/assert sovereignty patterns** from those praxeis

### Step 4: Build (satisfy the tests)

13. **Add `parousia_id` to `SessionToken`** (`crates/kosmos-mcp/src/lib.rs:124`)
    - `#[serde(default)] pub parousia_id: Option<String>`

14. **`ValidatedSession` already has `parousia_id`** (`crates/kosmos-mcp/src/auth.rs:19`) — DONE

15. **Include `parousia_id` in REST token mint** (`crates/kosmos-mcp/src/rest.rs:632`)
    - Add `"parousia_id": parousia_id` to `token_payload` JSON
    - Also update `verify_entry` handler and `session_switch_oikos` handler if they mint tokens

16. **Include `parousia_id` in Tauri token mint** (`app/src-tauri/src/main.rs:2727`)
    - Add `"parousia_id": dwelling.parousia_id` to payload JSON

17. **Change `invoke_praxis_dwelling` to accept `Option<DwellingContext>`** (`crates/kosmos/src/host.rs`)
    - Update signature: `dwelling: Option<DwellingContext>`
    - Pass through to `execute_praxis` directly
    - Update all call sites

18. **Fix REST `invoke_praxis` handler** (`crates/kosmos-mcp/src/rest.rs:433-444`)
    - Build `Option<DwellingContext>` from `OptionalSession`: `Some(dwelling)` when session present, `None` when absent
    - Include `parousia_id` from token when building DwellingContext

19. **Verify derive-attainments** includes sovereignty:
    - When `sovereign-to` bond is created, the sovereign's parousia should get `has-attainment → attainment/sovereign`
    - This may require a new reflex or logic in the `session_arise` handler's inline attainment computation

### Step 5: Verify

20. **`cargo build && cargo test`**
21. **End-to-end: `just dev`** — unlock keyring, type a phasis, verify it commits without error
22. **Re-read `docs/reference/attainment-authorization.md`** — confirm session boundary section matches implementation
23. **Audit:**
    ```bash
    # parousia_id in token structs
    rg 'parousia_id' crates/kosmos-mcp/src/auth.rs crates/kosmos-mcp/src/lib.rs
    # Should show field declarations

    # No empty-string DwellingContext
    rg 'prosopon_id: String::new' crates/
    # Should return nothing

    # No ad-hoc sovereignty checks in praxis YAML
    rg 'sovereign-to' genesis/ --glob '*.yaml' -l
    # Should return only desmos definitions and bond declarations, not praxis step logic

    # parousia_id in token payloads
    rg 'parousia_id' crates/kosmos-mcp/src/rest.rs app/src-tauri/src/main.rs
    # Should show inclusion in token JSON
    ```
24. **Update `docs/REGISTRY.md`** impact map

---

## Files to Touch

### Kosmos (genesis)
- `genesis/politeia/entities/` — add `attainment/sovereign` entity, `grants-attainment` bonds
- `genesis/politeia/praxeis/politeia.yaml` — add `requires-attainment` bonds, remove ad-hoc sovereignty checks

### Chora (implementation)
- `crates/kosmos-mcp/src/lib.rs` — add `parousia_id` to `SessionToken`
- `crates/kosmos-mcp/src/auth.rs` — add `parousia_id` to `ValidatedSession`, update tests
- `crates/kosmos-mcp/src/rest.rs` — include `parousia_id` in token mint, fix DwellingContext construction
- `crates/kosmos/src/host.rs` — change `invoke_praxis_dwelling` to accept `Option<DwellingContext>`
- `app/src-tauri/src/main.rs` — include `parousia_id` in `write_session_token` payload
- `crates/kosmos/tests/dwelling_propagation.rs` — new dwelling context tests
- `crates/kosmos/tests/attainment_authorization.rs` — sovereignty attainment tests

### Docs (updated FIRST, verified LAST)
- `docs/reference/attainment-authorization.md` — add session boundary section

---

## Verification

```bash
# Build
cargo build 2>&1

# All tests
cargo test 2>&1

# Specifically attainment + dwelling tests
cargo test attainment_authorization 2>&1
cargo test dwelling_propagation 2>&1

# Token auth tests
cargo test --package kosmos-mcp auth 2>&1

# No empty-string dwelling construction
rg 'prosopon_id: String::new' crates/
# Should return nothing

# No ad-hoc sovereignty in praxis steps
rg 'sovereign-to.*bind_to\|step: trace.*sovereign' genesis/ --glob '*.yaml'
# Should return nothing

# parousia_id present in tokens
rg 'parousia_id' crates/kosmos-mcp/src/rest.rs crates/kosmos-mcp/src/auth.rs crates/kosmos-mcp/src/lib.rs app/src-tauri/src/main.rs
# Should show field declarations and payload inclusions

# End-to-end
just dev
# Unlock keyring → type phasis → commit → no assertion error
```

---

## What This Enables

When the session boundary is clean:
- **`$_prosopon` and `$_parousia` are always populated** for authenticated requests — praxeis that need identity get it
- **No silent failures** from empty-string entity lookups — unauthenticated requests pass `None` dwelling, handled explicitly
- **The token is the single interface** between infrastructure and kosmos — infrastructure mints it using standard patterns, kosmos reads it using dwelling semantics
- **Sovereignty is an attainment** — checked by the same authorization gate as all other permissions, no special YAML patterns
- **Token backward compatibility** — old tokens without `parousia_id` parse with `None`, degrading gracefully
- **The foundation for capability-based security is complete** — attainments are capabilities, bonds are grants, the token carries identity, the graph is the policy
