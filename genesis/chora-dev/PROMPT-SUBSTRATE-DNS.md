# PROMPT: Wire DNS Through Generic Dispatch

**Replaces three cf-* stubs with one-line delegations to dns::execute_operation(). Removes legacy eidos-specific dns-record handling from host.rs. Removes dns.rs local resolve_credential (dead after credential substrate). Advances dns-cloudflare from stage 2 to stage 3.**

**Depends on**: PROMPT-SUBSTRATE-STANDARD.md (dns.rs already has execute_operation with standard 4-param signature)

---

## The Principle: One Path, Not Two

Every actualization in kosmos follows the same path:

```
entity data → resolve_mode() → stoicheion_for_mode() → dispatch_to_module() → substrate module
```

This is the mode pattern. The mode entity declares the stoicheion; the dispatch table routes it; the substrate module executes it. When this path works, adding a new provider (Route53, manual, any future DNS provider) means adding one line to the dispatch table and one module function. No host.rs changes. No special cases.

But today, dns-record entities follow **two** paths simultaneously:

```
PATH A (stubs):   cf-create-record → { status: "stub" }
PATH B (legacy):  eidos == "dns-record" → inline zone/binding resolution → dns::manifest()
```

Path A is the mode pattern — but it dead-ends at a stub. Path B is a legacy bypass — it works but hardcodes zone resolution, credential lookup, and entity updates inline in host.rs. ~238 lines of code that duplicate what `dns::execute_operation()` already does.

This prompt eliminates the duality. One path. The mode pattern wins.

```
AFTER:  cf-create-record → dns::execute_operation("create", ...) → dns::manifest()
        eidos == "dns-record" match arms → deleted
```

The deeper principle: **every eidos-specific match arm in host.rs is a legacy bypass waiting to be retired.** Each one represents a moment when the mode pattern wasn't yet ready, so the behavior was wired directly. Now that the standard substrate contract exists, each bypass can be replaced with a one-liner.

---

## The Credential Principle: One Resolution Path

dns.rs still has its own `resolve_credential()` (line 482) — a local function that handles `env://` prefix and literal strings. This is dead code. The credential substrate's `credential::resolve_credential()` handles keychain-first + env fallback. Having two resolution paths means confusion about which one governs.

After this prompt, credential resolution for DNS is:
```rust
let api_token = crate::credential::resolve_credential("cloudflare-dns", session)?;
```

One call. Keychain-first. The credential substrate governs.

---

## Methodology — Test → Wire → Remove → Verify

1. **Write failing tests** that exercise the mode dispatch path and expect real responses (not stubs)
2. **Wire**: Replace 3 stub match arms with one-line delegations to `dns::execute_operation()`
3. **Remove**: Delete legacy eidos-specific dns-record handling from manifest(), sense_actuality(), unmanifest()
4. **Remove**: Delete local `resolve_credential()` from dns.rs, simplify execute_operation credential chain
5. **Verify**: All tests pass, no behavior regression

---

## Context — What Already Exists

### dns.rs execute_operation (line 518, ready from substrate standard)

```rust
pub fn execute_operation(
    operation: &str,
    entity_id: &str,
    data: &Value,
    session: Option<&Arc<dyn SessionBridge>>,
) -> Result<Value>
```

Operations:
- `"create"` → `DnsRecord::from_entity_data(data)` → `manifest(&provider, &record)` → JSON with status/content/provider_record_id + `_entity_update`
- `"get"` → `sense(&provider, name, record_type, expected_content)` → JSON with status/content/divergence + `_entity_update`
- `"delete"` → `unmanifest(&provider, record_id)` → JSON with status/deleted_record_id + `_entity_update`

Manual provider short-circuit: if `provider == "manual"`, returns early without credential resolution.

### host.rs stubs (to be replaced)

```rust
// manifest_by_stoicheion, line 1457
"cf-create-record" => {
    Ok(json!({ "status": "stub", "entity_id": entity_id, "stoicheion": stoicheion,
               "message": "Cloudflare DNS manifest not yet implemented" }))
}

// sense_by_stoicheion, line 1744
"cf-get-record" => {
    Ok(json!({ "status": "stub", "entity_id": entity_id, "stoicheion": stoicheion,
               "message": "Cloudflare DNS sense not yet implemented" }))
}

// unmanifest_by_stoicheion, line 2010
"cf-delete-record" => {
    Ok(json!({ "status": "stub", "entity_id": entity_id, "stoicheion": stoicheion,
               "message": "Cloudflare DNS unmanifest not yet implemented" }))
}
```

### host.rs legacy eidos-specific bypass (to be removed)

Three `"dns-record"` match arms in the eidos-based dispatch fallback:

- **manifest()** lines 1229–1299 (~70 lines): Resolves zone bond → provider binding → credentials, calls `dns::manifest()` directly, updates entity
- **sense_actuality()** lines 1522–1611 (~89 lines): Same zone/binding/credential resolution, calls `dns::sense()` directly
- **unmanifest()** lines 1795–1874 (~79 lines): Resolves zone/binding, calls `dns::unmanifest()` directly, clears provider_record_id

This ~238 lines of legacy code duplicates what `dns::execute_operation()` already does — credential resolution, provider construction, typed function dispatch, and entity update via `_entity_update`. The only difference is the legacy path resolves zone via bond traversal (in-zone → provided-by), while execute_operation expects zone_id in entity data. The entity data DOES contain zone_id (populated at compose time from typos slots), so the bond traversal is redundant.

### host.rs release-artifact blocks also use dns::resolve_credential

Six call sites for `crate::dns::resolve_credential` exist in host.rs (lines 1272, 1349, 1591, 1674, 1856, 1940). Three are in the dns-record blocks being deleted. Three are in release-artifact blocks. The release-artifact calls must be updated to use `crate::credential::resolve_credential()` instead, since the dns.rs local function is being deleted.

### mode_dispatch.rs (already correct)

```rust
("dns", "cloudflare", ModeOperation::Manifest) => Some("cf-create-record"),
("dns", "cloudflare", ModeOperation::Sense) => Some("cf-get-record"),
("dns", "cloudflare", ModeOperation::Unmanifest) => Some("cf-delete-record"),
```

### dns.rs local resolve_credential (line 482, to be removed)

```rust
pub fn resolve_credential(credential_ref: &str) -> Result<String>
// Comment says: "For keychain-first resolution, use credential::resolve_credential() instead"
```

Only handles `env://` prefix and literal strings. The credential substrate handles keychain-first + env fallback. Dead code — its own comment says so.

---

## Implementation Order

### Step 1: Write tests

Create `crates/kosmos/tests/dns_dispatch.rs`:

1. `test_dns_execute_operation_create_manual` — call `dns::execute_operation("create", ...)` with provider=manual, expect error or manual-specific response (no credentials needed)
2. `test_dns_execute_operation_get_manual` — call with "get", provider=manual, assert `{ status: "unknown" }` (no actuality for manual)
3. `test_dns_execute_operation_delete_manual` — call with "delete", provider=manual, expect error or manual-specific response
4. `test_dns_execute_operation_create_no_creds` — call with provider=cloudflare, no session, no env var, assert credential error (NOT a stub response)
5. `test_dns_stoicheion_dispatch_not_stub` — bootstrap, create entity with mode=dns/provider=cloudflare, call `manifest_by_stoicheion("cf-create-record", ...)`, assert result does NOT contain `"status": "stub"` (should be a credential error, confirming the stub was replaced)

### Step 2: Replace stubs with one-liners

In `manifest_by_stoicheion` (line 1457):
```rust
"cf-create-record" => self.dispatch_to_module(entity_id, data,
    crate::dns::execute_operation("create", entity_id, data, session_ref)),
```

In `sense_by_stoicheion` (line 1744):
```rust
"cf-get-record" => self.dispatch_to_module(entity_id, data,
    crate::dns::execute_operation("get", entity_id, data, session_ref)),
```

In `unmanifest_by_stoicheion` (line 2010):
```rust
"cf-delete-record" => self.dispatch_to_module(entity_id, data,
    crate::dns::execute_operation("delete", entity_id, data, session_ref)),
```

Where `session_ref` is obtained the same way as other substrate dispatch — check how existing process/storage one-liners get the session reference for the exact pattern.

### Step 3: Remove legacy eidos-specific bypass

Delete the `"dns-record"` match arms from:
- `manifest()` — lines 1229–1299
- `sense_actuality()` — lines 1522–1611
- `unmanifest()` — lines 1795–1874

These entities now flow through mode dispatch: entity data has `mode: "dns"` + `provider: "cloudflare"` → `resolve_mode()` → `stoicheion_for_mode()` → `cf-create-record` → `dns::execute_operation()`.

If any entity still uses `eidos: "dns-record"` without `mode`/`provider` in its data, it will fall through to the default "unknown_stoicheion" arm. Verify that genesis dns-record entities include mode/provider fields (they should, from typos defaults).

### Step 4: Update release-artifact credential calls

The remaining `crate::dns::resolve_credential` calls in release-artifact eidos blocks (~lines 1349, 1674, 1940) must be updated to use `crate::credential::resolve_credential()` instead. Check the credential module's function signature — it may require a session parameter. If the release-artifact blocks have access to the session bridge, pass it. If not, use the env-only fallback path.

### Step 5: Remove dns.rs local resolve_credential

Delete the `pub fn resolve_credential(credential_ref: &str) -> Result<String>` function from dns.rs (lines 478–494).

Simplify `execute_operation`'s credential resolution to one call:
```rust
let api_token = crate::credential::resolve_credential("cloudflare-dns", session)?;
```

No more `data.get("credential_ref")` → local resolve → credential substrate chain. The credential substrate is the sole path.

### Step 6: Verify

```bash
cargo build -p kosmos 2>&1
cargo test -p kosmos --lib --tests 2>&1
cargo test -p kosmos --test dns_dispatch 2>&1
cargo test -p kosmos --test substrate_standard 2>&1  # regression check
```

---

## Files to Read

- `crates/kosmos/src/dns.rs` — execute_operation (line 518), local resolve_credential (line 482), manifest/sense/unmanifest
- `crates/kosmos/src/host.rs` — cf-* stubs (lines 1457, 1744, 2010), legacy dns-record blocks (lines 1229, 1522, 1795), release-artifact credential calls, dispatch_to_module
- `crates/kosmos/src/mode_dispatch.rs` — ("dns", "cloudflare") stoicheion mapping
- `crates/kosmos/src/credential.rs` — resolve_credential (the one that stays)

---

## Files to Touch

| File | Change |
|------|--------|
| `crates/kosmos/src/host.rs` | **MODIFY** — replace 3 cf-* stubs with one-liner delegations, delete 3 dns-record eidos blocks (~238 lines), update 3 release-artifact credential calls |
| `crates/kosmos/src/dns.rs` | **MODIFY** — delete local resolve_credential (~16 lines), simplify credential chain in execute_operation |
| `crates/kosmos/tests/dns_dispatch.rs` | **NEW** — 5 tests |

---

## Success Criteria

- [ ] `cf-create-record` dispatches to `dns::execute_operation("create", ...)` — not stub
- [ ] `cf-get-record` dispatches to `dns::execute_operation("get", ...)` — not stub
- [ ] `cf-delete-record` dispatches to `dns::execute_operation("delete", ...)` — not stub
- [ ] No `"dns-record"` eidos-specific match arms remain in manifest(), sense_actuality(), unmanifest()
- [ ] No local `resolve_credential` in dns.rs — credential substrate is sole credential path
- [ ] Release-artifact credential calls use credential substrate, not dns::resolve_credential
- [ ] Manual provider short-circuit still works (no credentials needed)
- [ ] `cargo test -p kosmos --lib --tests` passes (all existing tests)
- [ ] `cargo test -p kosmos --test dns_dispatch` passes (5 new tests)
- [ ] Net line reduction in host.rs: ~250 lines removed

---

## What This Enables

1. **dns-cloudflare advances to stage 3**: Fully implemented through generic dispatch, one path
2. **Last eidos-specific DNS bypass retired**: host.rs no longer knows about dns-record entities
3. **Credential path unified**: All DNS credential resolution goes through the credential substrate (keychain-first)
4. **Route53 provider ready**: Adding `("dns", "route53")` to mode_dispatch + one module function. No host.rs changes
5. **PROMPT-CREDENTIAL-LIFECYCLE.md** can add credential expiry sensing for cloudflare-dns

---

## What Does NOT Change

1. **dns.rs typed functions**: `manifest()`, `sense()`, `unmanifest()` stay — `execute_operation` dispatches to them
2. **DnsProvider enum**: Cloudflare, Route53, Manual variants stay
3. **Cloudflare API implementation**: `cloudflare_manifest()`, `cloudflare_sense()`, `cloudflare_unmanifest()` unchanged
4. **mode_dispatch.rs**: Generated table already correct
5. **Other stubs**: docker-*, s3-* stubs untouched
6. **release-artifact eidos blocks**: These stay (they serve the storage substrate pattern, not DNS). Only their credential calls change.

---

*Traces to: the mode pattern (one path through dispatch, not two competing paths), the credential principle (one resolution path through the credential substrate), PROMPT-SUBSTRATE-STANDARD.md (established the contract)*
