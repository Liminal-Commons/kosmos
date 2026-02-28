# Substrate Module Integration

> How substrate modules implement the actualization cycle in Rust.

Every dimension of chora — every way kosmos actualizes — is a **substrate**. Each substrate has a Rust module in `crates/kosmos/src/` that implements the standard contract. This document prescribes the seven-substrate taxonomy, the two dispatch patterns, the two invocation contexts, the standard module contract, and the provider entity pattern.

For the TypeScript handler pattern (screen and media substrates), see [substrate-lifecycle.md](substrate-lifecycle.md).
For the actualization cycle vocabulary, see [actualization-pattern.md](../reactivity/actualization-pattern.md).
For command template execution within substrate modules, see [command-template-execution.md](command-template-execution.md).

---

## The Seven Substrates

Chora receives kosmos. These are the **seven dimensions** of that reception:

| # | Substrate | What It Is | Providers | Module |
|---|-----------|-----------|-----------|--------|
| 1 | **Screen** | Visual presentation | thyra (SolidJS) | `layout-engine.tsx` |
| 2 | **Compute** | Process execution and build toolchains | local, docker, systemd, nixos, cargo | `process.rs` |
| 3 | **Storage** | Data persistence | fs-local, R2, S3 | `storage.rs` → `r2.rs` |
| 4 | **Network** | System communication | cloudflare (DNS), route53, manual | `dns.rs` |
| 5 | **Credential** | Identity, keys, secrets | session-bridge, environment | `credential.rs` |
| 6 | **Media** | Capture devices and real-time streams | whisper (voice), livekit (WebRTC) | `voice.rs`, `livekit.rs` |
| 7 | **Inference** | LLM inference and embedding | anthropic, openai | `nous.rs` |

---

## Two Dispatch Patterns

How substrates actualize **persistent phenomena** — a process that should be running, an object that should exist, a connection that should be open.

**Stoicheion-dispatched** (request/response): compute, storage, network, credential
- Operations are atomic: call → result
- Module exports `execute_operation()`
- host.rs dispatch is a one-line delegation via `stoicheion_for_mode()`

**Handler-dispatched** (event-driven): screen, media
- Operations are lifecycle-bound: start → stream events → stop
- Screen: managed by thyra layout engine (TypeScript)
- Media: managed by substrate handlers registered by mode ID
- Module exports handler registration, not `execute_operation`

These two patterns cover how substrates drive the **reconciliation cycle** — manifest/sense/unmanifest for persistent actuality.

## Two Invocation Contexts

How substrate operations are **called** — orthogonal to the dispatch pattern.

**Reconciler-driven** (persistent lifecycle): desired_state → reconcile → actual_state
- A process should be running. An object should exist. A DNS record should resolve.
- Reconciler reads entity, invokes mode operations via stoicheion dispatch or handler dispatch
- This is the actualization cycle (Sections 1-9 of [actualization-pattern.md](../reactivity/actualization-pattern.md))

**Interpreter-driven** (transient operation): praxis step → host function → result
- Run this command. Infer from this prompt. Embed this text.
- Interpreter steps call host methods directly during praxis execution
- No mode entity, no reconciler — the operation is transient, producing a result not a persistent phenomenon

These cross-cut: **compute** has both (mode/process-local for lifecycle via reconciler, CommandStep/execute_command_template for transient invocation). **Inference** currently has only interpreter-driven invocation (InferStep, EmbedStep). Its lifecycle operations (provider availability sensing, connection warmup) are deferred — a maturity fact, not an ontological one.

---

## The Standard Contract

Every stoicheion-dispatched substrate module exports:

```rust
pub fn execute_operation(
    operation: &str,
    entity_id: &str,
    data: &Value,
    session: Option<&Arc<dyn SessionBridge>>,
) -> Result<Value>
```

| Parameter | What It Is |
|-----------|-----------|
| `operation` | One of the mode's operation names (e.g. "spawn", "check", "kill") |
| `entity_id` | The entity being actualized |
| `data` | The entity's data object (`serde_json::Value`) |
| `session` | Optional session bridge for credential/keychain access |

### Return Value

All operations return JSON with standard fields:

```json
{
  "status": "manifested | sensed | unmanifested | error | stub",
  "entity_id": "the-entity-id",
  "stoicheion": "the-stoicheion-name"
}
```

Plus operation-specific fields:
- **Manifest**: `+ { manifest_handle?, content_hash?, artifact_path? }`
- **Sense**: `+ { exists: bool, is_fresh?: bool, actual_state?, divergence? }`
- **Unmanifest**: `+ { cleaned?: bool, deleted?: bool }`

### Entity Update Convention

Modules cannot call `self.update_entity()` — they don't have host context. Instead, modules return `_entity_update` in their result:

```json
{
  "status": "manifested",
  "_entity_update": {
    "manifest_handle": "12345",
    "actual_state": "running"
  }
}
```

host.rs applies this generically via `apply_entity_update()` after dispatch.

### Signal Sources

Substrate modules can also register **signal sources** for ephemeral sensing data that flows outside the entity update cycle. Signals are high-frequency, read-only measurements — not entity state.

```rust
signal::register_signal_source(Box::new(|| -> Vec<SubstrateSignal> {
    // Read atomics, return current measurements.
    // MUST be fast — no I/O, no locks, no allocations.
    vec![SubstrateSignal { entity_id, kind, value }]
}))
```

The broadcast timer reads all registered signal sources at **10Hz** and emits them over WebSocket as `WsEvent` variants. Clients consume these as ephemeral reactive values (e.g. SolidJS signals), not as entity store updates.

**Constraints:**
- Signal source closures must be `Send + Sync + 'static`
- No disk or network I/O — read from atomics or lock-free state only
- Return an empty vec when there is nothing to report

Voice is the first consumer of this pattern (`read_voice_signal()` reads `AtomicU32`/`AtomicBool` from `AudioSession`). Any substrate with continuous sensing data — device telemetry, connection quality, resource pressure — follows the same registration pattern.

---

## Module Roster

| Module | Substrate | Dispatch | Invocation | Status |
|--------|-----------|----------|------------|--------|
| `credential.rs` | Credential | Stoicheion | Reconciler | Standard contract — unlock/store/retrieve/list/lock |
| `process.rs` | Compute | Stoicheion | Reconciler + Interpreter | Standard contract — spawn/check/kill; also CommandStep transient |
| `storage.rs` | Storage | Stoicheion | Reconciler | Facade — dispatches to local or `r2.rs` by provider |
| `r2.rs` | Storage (R2) | Stoicheion | Reconciler | Standard 4-param signature, provider within storage |
| `dns.rs` | Network | Stoicheion | Reconciler | Standard 4-param facade + typed internal functions |
| `signal.rs` | (cross-cutting) | — | — | Signal source registry — 10Hz broadcast of ephemeral sensing data |
| `voice.rs` | Media | Handler | Reconciler | Handler-dispatched (out of scope for module contract) |
| `livekit.rs` | Media | Handler | Reconciler | Handler-dispatched (out of scope for module contract) |
| `nous.rs` | Inference | — | Interpreter | Interpreter-driven only — `infer_with_provider()`, `embed_with_provider()`, `list_models_with_provider()` |

Note: `nous.rs` has no dispatch pattern because inference currently has no lifecycle operations. When provider availability sensing arrives, it will gain stoicheion-dispatched operations alongside its interpreter-driven invocation — the same dual-context pattern compute already has.

---

## Credential Substrate

Credentials are a **substrate**, not a utility. The session keyring has a real actualization cycle:

| Operation | Actualization | What Happens |
|-----------|--------------|--------------|
| `unlock` | Manifest | Decrypt credentials into session memory — bring trust into actuality |
| `store` | Manifest | Encrypt + persist credential entity — add a specific capability |
| `retrieve` | Sense | Query session for decrypted value — current trust state |
| `list` | Sense | Enumerate credential entities — full state inspection |
| `lock` | Unmanifest | Zero session memory — remove trust from actuality |

### resolve_credential()

The credential module exposes a convenience function for other substrate modules:

```rust
pub fn resolve_credential(
    service_name: &str,
    session: Option<&Arc<dyn SessionBridge>>,
) -> Result<String>
```

Resolution order:
1. **SessionBridge**: `session.get_credential(service_name)` — PRIMARY (decrypted from kleidoura-encrypted entities)
2. **Environment fallback**: well-known env var mapping (for headless/CI only)
3. **Uppercase convention**: `SERVICE_NAME` as env var
4. Error with guidance to unlock keyring

The session bridge is always tried first; env vars are the headless escape hatch, not a peer.

---

## Provider Entity Pattern

The real structural contribution of the inference substrate is the **provider entity pattern** — graph-driven configuration for external service access.

External inference services are `provider` entities in genesis. Adding a provider means adding a genesis entity — no code changes required (for providers using the `anthropic` or `openai` request formats).

```yaml
- eidos: provider
  id: provider/anthropic
  data:
    name: Anthropic
    capabilities: [inference]
    credential_config:
      service: anthropic
      auth_header: x-api-key
      grants_attainment: use-anthropic-api
    inference_config:
      endpoint: https://api.anthropic.com/v1/messages
      request_format: anthropic
      extra_headers:
        anthropic-version: "2023-06-01"
    models_config:
      endpoint: https://api.anthropic.com/v1/models
      request_format: anthropic
```

### Invocation Flow

Inference operations are interpreter-driven — `InferStep`/`EmbedStep` in `steps.rs` call host methods, which read provider entities:

```
InferStep (steps.rs)
  → host.infer(prompt, system, model, temperature, provider)
    → nous::infer_with_provider(ctx, ...)
      → find_entity("provider/{provider}")
      → read credential_config → resolve_credential(service)
      → read inference_config → build request (anthropic or openai format)
      → HTTP POST → parse response
```

This is the same invocation context as `CommandStep` → `host.execute_command_template()` for compute. The substrate is different; the calling pattern is the same.

### Two Request Formats

| Format | System Prompt | Auth Header | Auth Value |
|--------|--------------|-------------|------------|
| `anthropic` | Top-level `system` field | `x-api-key` | Raw key |
| `openai` | In `messages` array as role:system | `Authorization` | `Bearer {key}` |

The OpenAI format also covers: Mistral, Groq, Together, Fireworks, Ollama (local). Any provider declaring `request_format: openai` works without code changes.

### Model Tier Resolution

Model tiers (`model-tier/{provider}/{tier}`) are populated automatically when credentials are added — reflexes fire `soma/resolve-model-tiers` which queries the provider's models API and categorizes by family:

- **Anthropic**: opus → capable, sonnet → balanced, haiku → fast
- **OpenAI**: o-series → capable, gpt-4o → balanced, mini → fast

### Provider Pattern Extensibility

The provider entity pattern established for inference extends naturally to non-inference providers. `provider/cloudflare` declaring DNS + storage capabilities, bonded to credentials, discoverable in settings — same pattern, different substrate dimensions. That's a follow-on scope, but the pattern is proven.

---

## Dispatch Protocol

After extraction, every stoicheion match arm in host.rs is a one-liner:

```rust
// manifest_by_stoicheion
"spawn-process"    => self.dispatch_to_module(entity_id, data,
    process::execute_operation("spawn", entity_id, data, session_ref)),
"fs-write-file"    => storage::execute_operation("write", entity_id, data, session_ref),
"r2-put-object"    => self.dispatch_to_module(entity_id, data,
    storage::execute_operation("upload", entity_id, &inject_provider(data, "r2"), session_ref)),
```

`dispatch_to_module()` calls the module, applies `_entity_update`, and returns the result.

Stubs (docker-*, s3-*, cf-*) remain as inline JSON — they will be replaced when their respective substrate prompts land.

---

## Multi-Provider Pattern

Modules with provider variants dispatch internally:

**Storage** (facade pattern):
```rust
match provider {
    "local" => execute_local(op, entity_id, data),
    "r2"    => r2::execute_operation(op, entity_id, data, session),
    "s3"    => r2::execute_operation(op, entity_id, data, session), // same API
}
```

**DNS** (enum pattern):
```rust
DnsProvider::Cloudflare { .. } => cloudflare_manifest(..),
DnsProvider::Route53 { .. }    => route53_manifest(..),
DnsProvider::Manual            => Err("no actuality operations"),
```

**Inference** (entity-driven pattern):
```rust
// Provider entity determines format — no match arms needed
let provider_entity = ctx.find_entity(&format!("provider/{}", provider));
let request_format = provider_entity["data"]["inference_config"]["request_format"];
// Build request based on format...
```

---

## Extension Guide — Adding a New Substrate Module

### Stoicheion-dispatched (compute, storage, network, credential)

1. Create `crates/kosmos/src/{module}.rs`
2. Export `pub fn execute_operation(operation, entity_id, data, session) -> Result<Value>`
3. Match on `operation` to dispatch internally
4. Return standard `{ status, entity_id, stoicheion }` plus operation-specific fields
5. Include `_entity_update` for entity mutations
6. Use `credential::resolve_credential()` for external API credentials
7. Register in `lib.rs`: `pub mod {module};`
8. Add one-line match arm in host.rs dispatch methods
9. Write tests in `tests/substrate_standard.rs`

### Handler-dispatched (screen, media)

1. Create `crates/kosmos/src/{module}.rs`
2. Export handler struct with lifecycle methods (start/stop/on_event)
3. Register handler by mode ID
4. Document in this file's Module Roster

### Adding a provider (inference substrate)

1. Add a `provider/{name}` entity in genesis with `credential_config`, `inference_config`, etc.
2. If the provider uses a new `request_format`, add a request builder in `nous.rs`
3. Add model tier entities (`model-tier/{provider}/{tier}`) in genesis
4. Add trigger + reflex for credential-added → model tier resolution
5. Write tests in `tests/inference_provider.rs`

---

## Anti-Patterns

- **Inline logic in host.rs**: All substrate logic lives in modules. host.rs is pure dispatch.
- **Module-specific credential resolution**: Use `credential::resolve_credential()`, not inline env var lookups.
- **Typed returns instead of Value**: Modules return `serde_json::Value`, not custom structs. The caller is host.rs dispatch, which needs uniform handling.
- **Treating credential as a utility**: Credential is a substrate with its own actualization cycle, not a cross-cutting concern.
- **Hardcoded provider configuration**: Inference provider config (endpoints, auth headers, request formats) lives in genesis entities, not in code. Adding a provider should not require code changes.
- **Confusing dispatch patterns with invocation contexts**: Two dispatch patterns (stoicheion, handler) describe how substrates actualize persistent phenomena. Two invocation contexts (reconciler-driven, interpreter-driven) describe how operations are called. These cross-cut — a substrate can have both.
- **Deprecated wrappers**: Delete old signatures. Dead code is contextual poison.

---

*Traces to: V7 §L1 Dynamis module pattern, KOSMOGONIA §Mode Pattern, T5 (code is artifact), PROMPT-INFERENCE-SUBSTRATE.md*
