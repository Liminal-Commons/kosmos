# S3 Endpoint Parameterization — Providers Are Configuration, Not Code

*Prompt for Claude Code in the chora + kosmos repository context.*

*Parameterizes r2.rs to support any S3-compatible endpoint. After this work, the same module handles Cloudflare R2, AWS S3, MinIO, and any S3-compatible storage by reading endpoint and region from entity data. R2 remains the default. No new modules, no code duplication — the difference between providers is configuration. Advances object-storage-s3 from stage 3 to stage 6.*

*Depends on: PROMPT-STORAGE-LIFECYCLE.md (R2 `_entity_update` convention established)*

---

## Architectural Principle — Providers Are Configuration, Not Code

The S3 API is a protocol. R2 implements it. AWS S3 implements it. MinIO implements it. The difference between them is three strings: endpoint URL, region, and credential service name. Everything else — Signature V4 signing, object operations, `_entity_update` convention — is identical.

Today, r2.rs hardcodes all three:

```
endpoint:    https://{account_id}.r2.cloudflarestorage.com  ← hardcoded in R2Provider::endpoint()
region:      "auto"                                         ← hardcoded in sign_request()
credential:  "cloudflare-r2"                                ← hardcoded in resolve_r2_credentials()
```

This means S3 dispatch works at the routing level (storage.rs routes "s3" to r2.rs), but fails at the protocol level — every request goes to Cloudflare's endpoint with R2's "auto" region and R2's credentials.

**The fix is not a new S3 module.** The fix is reading endpoint, region, and credential service name from entity data, with R2 values as defaults. The same module, the same signing code, the same `_entity_update` convention — just different configuration.

Genesis already prescribes this. `mode/object-storage-s3` has `region` in its config_schema. Entity data can carry `endpoint`. The Rust code just doesn't read them yet.

---

## Methodology — DDD + TDD

This work follows **Doc → Test → Build → Verify**, non-negotiably.

1. **Doc (prescriptive)**: This prompt IS the prescriptive doc. The target state described here is what code must match.
2. **Test (assert the doc)**: Write tests that assert endpoint resolution, credential service dispatch, and region parameterization. Tests should fail before implementation.
3. **Build (satisfy the tests)**: Implement until tests pass.
4. **Verify doc**: After implementation, update success criteria to reflect completion. Check docs/REGISTRY.md impact map.

Pure refactoring of r2.rs internals. No new modules. No new genesis entities. No functional change for R2 operations — existing R2 tests must pass unchanged. S3 tests that require real AWS credentials should be `#[ignore]`.

---

## Current State

### What Exists and Works

| Component | Location | Status |
|-----------|----------|--------|
| `R2Provider` struct | `r2.rs:24` | Working — has `account_id`, `bucket`, `access_key_id`, `secret_access_key` |
| `R2Provider::endpoint()` | `r2.rs:70` | Working — **hardcoded** `https://{account_id}.r2.cloudflarestorage.com` |
| `sign_request()` | `r2.rs:421` | Working — **hardcoded** region `"auto"`, host `{account_id}.r2.cloudflarestorage.com` |
| `resolve_r2_credentials()` | `r2.rs:759` | Working — **hardcoded** service `"cloudflare-r2"` for session bridge lookup |
| `execute_operation()` | `r2.rs:605` | Working — standard contract, `_entity_update` on all operations |
| `storage.rs` routing | `storage.rs:34` | Working — routes "s3" to `r2::execute_operation()` |
| S3 dispatch in host.rs | `host.rs:1377,1559,1727` | Working — `dispatch_to_module` with `inject_provider(data, "s3")` |
| `mode/object-storage-s3` | `genesis/dynamis/modes/dynamis.yaml:73` | Defined — has `region` in config_schema |
| S3 stoicheion in mode_dispatch.rs | Generated | Working — `s3-put-object`, `s3-head-object`, `s3-delete-object` |
| R2 `_entity_update` | `r2.rs` | Working — sense/manifest/unmanifest all return `_entity_update` |

### What's Missing — The Three Gaps

**Gap 1: Hardcoded endpoint.** `R2Provider::endpoint()` returns `https://{account_id}.r2.cloudflarestorage.com`. For AWS S3, the endpoint is `https://s3.{region}.amazonaws.com`. For MinIO, it's whatever the user configures. The struct has no `endpoint` field. The `sign_request()` function also hardcodes the host header to `{account_id}.r2.cloudflarestorage.com`.

**Gap 2: Hardcoded region.** `sign_request()` uses `let region = "auto"`. R2's "auto" region is not valid for AWS S3, which requires a real region (e.g., `us-east-1`). The genesis mode already prescribes a `region` field in config_schema, but r2.rs never reads it.

**Gap 3: Hardcoded credential service.** `resolve_r2_credentials()` looks up `"cloudflare-r2"` in the session bridge. For S3, the service name should be `"aws-s3"` or similar. Environment variable fallbacks use `CLOUDFLARE_R2_*` and `R2_*` prefixes — S3 users expect `AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`, `AWS_REGION`.

---

## Target State

### R2Provider becomes S3Provider (or ObjectStorageProvider)

```rust
#[derive(Debug, Clone)]
pub struct ObjectStorageProvider {
    pub bucket: String,
    pub access_key_id: String,
    pub secret_access_key: String,
    pub endpoint: String,       // full URL — "https://xxx.r2.cloudflarestorage.com" or "https://s3.us-east-1.amazonaws.com"
    pub region: String,          // "auto" for R2, "us-east-1" for S3
    pub host: String,            // extracted from endpoint for signing — "xxx.r2.cloudflarestorage.com"
}

impl ObjectStorageProvider {
    fn object_url(&self, key: &str) -> String {
        format!("{}/{}/{}", self.endpoint, self.bucket, key)
    }
}
```

### Credential resolution reads provider from entity data

```rust
fn resolve_storage_credentials(
    data: &Value,
    session: Option<&Arc<dyn SessionBridge>>,
) -> Result<ObjectStorageProvider> {
    let provider_type = data.get("provider").and_then(|v| v.as_str()).unwrap_or("r2");

    match provider_type {
        "r2" => {
            // Existing R2 resolution: entity data → session("cloudflare-r2") → CLOUDFLARE_R2_* / R2_* env
            let account_id = resolve_field(data, session, "account_id",
                "cloudflare-r2", &["CLOUDFLARE_ACCOUNT_ID", "R2_ACCOUNT_ID"])?;
            let endpoint = format!("https://{}.r2.cloudflarestorage.com", account_id);
            let host = format!("{}.r2.cloudflarestorage.com", account_id);
            // ... resolve bucket, access_key_id, secret_access_key as before ...
            Ok(ObjectStorageProvider {
                bucket, access_key_id, secret_access_key,
                endpoint, region: "auto".into(), host,
            })
        }
        "s3" => {
            // S3 resolution: entity data → session("aws-s3") → AWS_* env
            let region = data.get("region").and_then(|v| v.as_str())
                .or_else(|| std::env::var("AWS_REGION").ok().as_deref()) // note: needs handling
                .unwrap_or("us-east-1");
            let endpoint = data.get("endpoint").and_then(|v| v.as_str())
                .map(String::from)
                .unwrap_or_else(|| format!("https://s3.{}.amazonaws.com", region));
            let host = endpoint.trim_start_matches("https://")
                .trim_start_matches("http://")
                .trim_end_matches('/')
                .to_string();
            // ... resolve bucket, access_key_id, secret_access_key with AWS env fallbacks ...
            Ok(ObjectStorageProvider {
                bucket, access_key_id, secret_access_key,
                endpoint, region: region.to_string(), host,
            })
        }
        _ => {
            // Custom S3-compatible (MinIO, etc.) — require explicit endpoint
            let endpoint = data.get("endpoint").and_then(|v| v.as_str())
                .ok_or_else(|| KosmosError::Invalid(
                    format!("Provider '{}' requires explicit 'endpoint' in entity data", provider_type)))?;
            // ...
        }
    }
}
```

### sign_request uses provider's host and region

```rust
fn sign_request(
    provider: &ObjectStorageProvider,
    method: &str,
    key: &str,
    timestamp: &str,
    body: Option<&[u8]>,
    content_type: Option<&str>,
) -> Result<Vec<(String, String)>> {
    let date_stamp = &timestamp[0..8];
    let region = &provider.region;   // was: "auto"
    let service = "s3";
    let host = &provider.host;       // was: format!("{}.r2.cloudflarestorage.com", ...)
    // ... rest unchanged — uses host and region variables ...
}
```

### S3 environment variable fallbacks

```
AWS_ACCESS_KEY_ID       → access_key_id (for provider "s3")
AWS_SECRET_ACCESS_KEY   → secret_access_key (for provider "s3")
AWS_REGION              → region (for provider "s3")
AWS_S3_BUCKET           → bucket (for provider "s3")
AWS_S3_ENDPOINT         → endpoint override (for custom S3-compatible)
```

These are in addition to the existing `CLOUDFLARE_R2_*` / `R2_*` variables, which continue to work for R2.

---

## Sequenced Work

### Phase 1: Struct Rename + Endpoint/Region Fields (Rust)

**Goal:** `R2Provider` becomes `ObjectStorageProvider` with `endpoint`, `region`, and `host` fields. R2 behavior unchanged.

**Tests:**
- `test_r2_provider_endpoint_default` — create provider with `provider_type="r2"`, `account_id="abc123"`, verify endpoint is `https://abc123.r2.cloudflarestorage.com`, region is `"auto"`
- `test_s3_provider_endpoint_default` — create provider with `provider_type="s3"`, `region="us-east-1"`, verify endpoint is `https://s3.us-east-1.amazonaws.com`, region is `"us-east-1"`
- `test_s3_provider_endpoint_override` — create provider with `provider_type="s3"`, `endpoint="https://minio.local:9000"`, verify endpoint is the override
- `test_s3_provider_host_extraction` — verify host is extracted correctly from various endpoint URL formats

**Implementation:**

1. Rename `R2Provider` → `ObjectStorageProvider`, add `endpoint: String`, `region: String`, `host: String`
2. Remove `R2Provider::endpoint()` method — endpoint is now a field
3. Update `R2Provider::from_channel()` → `ObjectStorageProvider::from_channel()` — compute endpoint/region/host from account_id (R2 default)
4. Update `sign_request()` to use `provider.host` and `provider.region` instead of hardcoded values
5. Update all references in r2.rs (function signatures, local variables)
6. Type alias for backward compatibility in from_channel if needed: `pub type R2Provider = ObjectStorageProvider;`

**Phase 1 Complete When:**
- [ ] `ObjectStorageProvider` has `endpoint`, `region`, `host` fields
- [ ] `sign_request()` uses provider fields instead of hardcoded values
- [ ] All existing R2 tests pass unchanged
- [ ] `from_channel()` still works (backward compatible)

### Phase 2: Credential Resolution by Provider (Rust)

**Goal:** Credential resolution dispatches by provider type. S3 credentials use AWS conventions.

**Tests:**
- `test_resolve_r2_credentials_unchanged` — pass data with `provider: "r2"`, verify resolution uses `"cloudflare-r2"` service and `CLOUDFLARE_R2_*` env vars (regression)
- `test_resolve_s3_credentials_from_data` — pass data with `provider: "s3"`, `access_key_id`, `secret_access_key`, `region`, `bucket`, verify provider constructed with correct endpoint
- `test_resolve_s3_credentials_from_env` — set `AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY` env vars, pass data with `provider: "s3"`, verify resolution picks up AWS env vars
- `test_resolve_s3_credentials_region_from_data` — pass data with `region: "eu-west-1"`, verify endpoint is `https://s3.eu-west-1.amazonaws.com`
- `test_resolve_custom_endpoint` — pass data with `provider: "s3"`, `endpoint: "https://minio.internal:9000"`, verify endpoint used as-is

**Implementation:**

1. Rename `resolve_r2_credentials()` → `resolve_storage_credentials()`, return `ObjectStorageProvider` directly (merge credential resolution and provider construction)
2. Add provider dispatch: `"r2"` uses existing R2 resolution, `"s3"` uses AWS conventions
3. R2 path: session service `"cloudflare-r2"`, env vars `CLOUDFLARE_R2_*` / `R2_*`, region `"auto"`
4. S3 path: session service `"aws-s3"`, env vars `AWS_*`, region from data or `AWS_REGION` or `"us-east-1"`, endpoint from data or computed from region
5. Update `execute_operation()` to call `resolve_storage_credentials()` instead of `resolve_r2_credentials()` + manual `R2Provider` construction
6. Remove `R2Credentials` struct if no longer needed separately

**Phase 2 Complete When:**
- [ ] `resolve_storage_credentials()` dispatches by provider field
- [ ] R2 resolution unchanged (backward compatible)
- [ ] S3 resolution reads `region` from entity data, falls back to `AWS_REGION` env, defaults to `"us-east-1"`
- [ ] S3 resolution reads `endpoint` from entity data, computes default from region
- [ ] S3 credential env vars: `AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`, `AWS_REGION`, `AWS_S3_BUCKET`

### Phase 3: Verify

**Goal:** R2 unchanged, S3 operational with correct endpoint/region/credentials.

```bash
cargo build -p kosmos 2>&1
cargo test -p kosmos --lib --tests 2>&1
cargo test -p kosmos --test storage_lifecycle 2>&1  # regression
```

**Tests:**
- `test_s3_full_cycle` — (mark `#[ignore]`) set AWS env vars, upload object, sense it, delete it, verify `_entity_update` on each operation
- `test_r2_existing_tests_unchanged` — all r2.rs unit tests pass without modification

**Phase 3 Complete When:**
- [ ] All existing tests pass (including r2 unit tests and storage_lifecycle integration tests)
- [ ] 9+ new tests in r2.rs or storage_lifecycle.rs
- [ ] S3 endpoint, region, and credentials configurable via entity data or env vars

---

## Files to Read

### What to change
- `crates/kosmos/src/r2.rs` — `R2Provider` struct (line 24), `endpoint()` (line 70), `sign_request()` (line 421, hardcoded host/region), `resolve_r2_credentials()` (line 759), `execute_operation()` (line 605, constructs provider), `R2Credentials` struct (line 747), `from_channel()` (line 33)

### Reference
- `genesis/dynamis/modes/dynamis.yaml` — `mode/object-storage-s3` config_schema (line 73, has `region` field)
- `crates/kosmos/src/storage.rs` — routing (line 34, both "r2" and "s3" go to r2.rs)
- `crates/kosmos/src/host.rs` — `inject_provider()` (line 2041), S3 dispatch arms (lines 1377, 1559, 1727)

### Existing tests (must not break)
- `crates/kosmos/src/r2.rs` — unit tests at line 830+
- `crates/kosmos/tests/storage_lifecycle.rs` — integration tests

---

## Files to Touch

| File | Change |
|------|--------|
| `crates/kosmos/src/r2.rs` | **MODIFY** — rename `R2Provider` → `ObjectStorageProvider`, add endpoint/region/host fields, update `sign_request()` to use provider fields, rename/refactor `resolve_r2_credentials()` → `resolve_storage_credentials()` with S3 dispatch, add AWS env var fallbacks |
| `crates/kosmos/tests/storage_lifecycle.rs` | **MODIFY** — add S3 provider construction tests, credential resolution tests, endpoint parameterization tests |

---

## Success Criteria

**Phase 1 Complete When:**
- [ ] `ObjectStorageProvider` replaces `R2Provider` with endpoint/region/host fields
- [ ] `sign_request()` reads host and region from provider, not hardcoded
- [ ] All existing R2 tests pass unchanged

**Phase 2 Complete When:**
- [ ] `resolve_storage_credentials()` dispatches by provider
- [ ] S3 credentials resolve via entity data → session("aws-s3") → AWS_* env
- [ ] S3 region/endpoint configurable

**Overall Complete When:**
- [ ] All existing tests pass
- [ ] 9+ new tests cover S3 parameterization
- [ ] R2 behavior identical (zero regression)
- [ ] object-storage-s3 at stage 6 (fully operational through same code path as R2)

---

## What This Enables

1. **AWS S3 operational** — `provider: "s3"`, `region: "us-east-1"`, `bucket: "my-bucket"` → uploads to AWS S3
2. **MinIO operational** — `provider: "s3"`, `endpoint: "https://minio.internal:9000"` → uploads to self-hosted MinIO
3. **Any S3-compatible storage** — same module, different configuration. The protocol is the contract; the endpoint is the variable.
4. **Credential substrate integration** — S3 credentials stored as `service: "aws-s3"` in the keyring, resolved through the same credential lifecycle
5. **Uniform `_entity_update`** — S3 operations return the same `_entity_update` as R2 (already implemented in PROMPT-STORAGE-LIFECYCLE), so reconciler/release-artifact works for S3 targets without changes

---

## What Does NOT Change

1. **R2 behavior** — R2Provider defaults preserved. `account_id` → R2 endpoint, region `"auto"`, credential service `"cloudflare-r2"`. Zero functional change for existing R2 operations.
2. **storage.rs routing** — already routes "s3" to `r2::execute_operation()`. No change needed.
3. **host.rs dispatch** — S3 stoicheion already dispatch through `dispatch_to_module`. No change needed.
4. **`_entity_update` convention** — already implemented in PROMPT-STORAGE-LIFECYCLE. S3 operations inherit it automatically since they use the same code path.
5. **mode_dispatch.rs** — already generates S3 stoicheion mappings. No change needed.
6. **genesis modes** — `mode/object-storage-s3` already exists with `region` in config_schema. No change needed.
7. **AWS Signature V4 core** — `sha256()`, `hmac_sha256()`, `hex_encode()`, canonical request construction — all unchanged. Only the inputs (host, region) become parameterized.
8. **`from_channel()`** — backward compatible (continues to construct R2-style providers from distribution channel entities)

---

*Traces to: the provider principle (providers are configuration, not code), the S3 protocol principle (one protocol, many endpoints), PROMPT-STORAGE-LIFECYCLE.md (`_entity_update` convention), PROMPT-SUBSTRATE-STANDARD.md (standard substrate contract)*
