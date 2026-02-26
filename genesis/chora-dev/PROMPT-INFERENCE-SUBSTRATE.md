# PROMPT: Inference Substrate — Provider Entities and Generic Engine

**Recognizes inference as a substrate dimension — where understanding becomes actual. Introduces provider-as-entity for discoverable, credential-bound service configuration. Builds a generic HTTP inference engine that reads provider entities, replacing hardcoded API calls in nous.rs. Updates the settings UI to discover providers from the graph. Extends substrate signals for inference streaming.**

**Depends on**: PROMPT-SUBSTRATE-STANDARD.md (uniform module contract), PROMPT-ONTOLOGICAL-COHERING.md (nous.rs as host's mind), PROMPT-MODEL-TIER-RESOLUTION.md (tier entities and resolution), PROMPT-SETTINGS-PANEL-ONTOLOGY.md (credential management in settings)
**Prior art**: The voice decomposition pattern (soma prescribes, stoicheion dispatch actualizes), command_template.rs (template-driven actuality)
**Enables**: WASM stoicheia for exotic providers, thinking stream visualization, multi-provider model selection in settings

---

## Architectural Principle

**Inference is a substrate dimension — where intent becomes understanding through external intelligence.**

An LLM IS inferring. That's a present-tense phenomenon with temporal extent. It can be sensed while happening. It produces actuality (generated text, structured output, embeddings). The HTTP transport is incidental — a local Ollama over a Unix socket actualizes understanding through the same dimension.

The current codebase treats inference as hardcoded function calls in nous.rs. Every other external capability goes through a standard pattern: entities declare configuration, dispatch reads the declaration, modules execute against external services. Inference is the exception. This prompt eliminates the exception.

Two principles govern the work:

```
INVARIANT:  Provider is an entity — discoverable in the graph, bonded to credentials,
            declaring capabilities and configuration
INVARIANT:  The generic engine reads provider entities — no hardcoded API calls,
            no hardcoded endpoints, no hardcoded auth headers
VARIES BY:  Request format (anthropic, openai — covers ~95% of providers)
VARIES BY:  Which capabilities a provider offers (inference, embedding, or both)
```

### Why Not Fully Declarative Request/Response Mappings

The discussion that led to this prompt considered fully declarative providers where endpoint, auth, and request/response JSON paths are all entity data. This is the target — and for provider lifecycle (availability sensing), it works today.

For the inference call itself, two request formats (Anthropic Messages API, OpenAI Chat Completions) cover Anthropic, OpenAI, Mistral, Groq, Together, Fireworks, and local Ollama. The generic engine has code for both formats; the provider entity selects which one. Exotic providers that need custom logic are the WASM stoicheia escape hatch (stoicheia-portable topos, Tier 3).

### Streaming Is Infrastructure, Not Per-Provider

SSE streaming follows the same two-format split. The generic engine reads SSE events, parses JSON deltas at format-specific paths, and emits substrate signals. No per-provider streaming code. The substrate signal architecture (10Hz broadcast, frontend DOM bridge) already surfaces voice activity and transcription activity. Inference activity joins the same system.

---

## Current State

### What exists

**nous.rs** — three hardcoded API functions:
- `call_openai_embedding(api_key, text)` → POST to `https://api.openai.com/v1/embeddings`, model `text-embedding-3-small`, 1536 dimensions
- `call_anthropic_inference(api_key, prompt, system, model, temperature)` → POST to `https://api.anthropic.com/v1/messages`
- `call_anthropic_structured(api_key, prompt, system, model, temperature, schema)` → POST to Anthropic with tool_use for JSON Schema

Plus graph operations that stay unchanged:
- `index_embedding(conn, entity_id, text, embedding)` — store in SQLite
- `surface_by_similarity(conn, query_embedding, threshold, eidos_filter)` — cosine search
- `list_anthropic_models(api_key)` — GET /v1/models (paginated)
- `categorize_models(models)` — opus→capable, sonnet→balanced, haiku→fast

**Dispatch path** — through interpreter step types, NOT dynamis mode dispatch:
- `InferStep::execute()` (steps.rs:2873) → `ctx.infer()` or `ctx.infer_structured()` → `host.rs:1120` → `nous::call_anthropic_*`
- `EmbedStep::execute()` (steps.rs:2607) → `ctx.embed()` → `host.rs:1071` → `nous::call_openai_embedding()`
- Both gated by Tier 3 access control + attainment bonds

**Model tier resolution** — already provider-aware:
- `resolve_model_tier(ctx, provider, tier)` in steps.rs:203 → looks up `model-tier/{provider}/{tier}` entity
- Three entities: `model-tier/anthropic/{capable,balanced,fast}` in `genesis/soma/entities/inference-defaults.yaml`
- Auto-resolution reflex: `reflex/soma/resolve-tiers-on-credential` fires on credential add

**Manteia topos** — governed inference surface (7 praxeis):
- `surface/reasoning` with governed-envelope, evaluation-criterion eide
- This is the GOVERNANCE layer — it invokes inference, it doesn't provide it

**Settings panel** — credential-manager widget with hardcoded preset:
```typescript
const SERVICE_PRESETS: ServicePreset[] = [
  { service: "anthropic", label: "Anthropic", attainment: "use-anthropic-api", placeholder: "sk-ant-..." }
];
```

### The gaps

1. **No provider entities** — "Anthropic" and "OpenAI" exist only as strings in code and entity fields
2. **Hardcoded API calls** — nous.rs has endpoint URLs, auth headers, request schemas baked in
3. **No provider discovery** — the settings widget can't ask the graph "what providers exist?"
4. **No multi-provider inference** — InferStep always routes to Anthropic regardless of provider param
5. **No streaming** — all inference is blocking request/response; no substrate signals during generation
6. **Model discovery is Anthropic-only** — `list_anthropic_models()` hardcodes the Anthropic models endpoint

---

## Design

### 1. Provider Entity (eidos: provider)

A provider is an external service that offers capabilities through substrate dimensions. It is an entity in the graph:

```yaml
eidos: eidos
id: eidos/provider
data:
  name: provider
  description: |
    An external service providing capabilities across substrate dimensions.
    Discoverable in the graph, bonded to credentials, declaring capabilities
    and configuration. The generic engine reads provider entities to execute
    operations — no hardcoded API calls.
  fields:
    name:
      type: string
      required: true
    description:
      type: string
    capabilities:
      type: array
      description: "What this provider offers: inference, embedding"
    credential_config:
      type: object
      description: "How to authenticate with this provider"
      fields:
        service: { type: string, required: true }
        auth_header: { type: string, required: true }
        auth_prefix: { type: string, description: "e.g., 'Bearer ' for OpenAI" }
        grants_attainment: { type: string, required: true }
        placeholder: { type: string, description: "UI hint for API key format" }
    inference_config:
      type: object
      description: "Present if capabilities includes inference"
      fields:
        endpoint: { type: string, required: true }
        request_format: { type: string, required: true, description: "anthropic | openai" }
        extra_headers: { type: object, description: "Additional required headers" }
        streaming:
          type: object
          fields:
            format: { type: string, description: "sse" }
    embedding_config:
      type: object
      description: "Present if capabilities includes embedding"
      fields:
        endpoint: { type: string, required: true }
        request_format: { type: string, required: true }
        default_model: { type: string }
        dimensions: { type: number }
    models_config:
      type: object
      description: "How to discover available models"
      fields:
        endpoint: { type: string }
        request_format: { type: string }
```

### 2. Provider Instances

```yaml
# genesis/soma/entities/providers.yaml

entities:
  - eidos: provider
    id: provider/anthropic
    data:
      name: Anthropic
      description: "AI inference provider — Claude model family"
      capabilities:
        - inference
      credential_config:
        service: anthropic
        auth_header: x-api-key
        grants_attainment: use-anthropic-api
        placeholder: "sk-ant-..."
      inference_config:
        endpoint: https://api.anthropic.com/v1/messages
        request_format: anthropic
        extra_headers:
          anthropic-version: "2023-06-01"
        streaming:
          format: sse
      models_config:
        endpoint: https://api.anthropic.com/v1/models
        request_format: anthropic

  - eidos: provider
    id: provider/openai
    data:
      name: OpenAI
      description: "AI inference and embedding provider — GPT and embedding models"
      capabilities:
        - inference
        - embedding
      credential_config:
        service: openai
        auth_header: Authorization
        auth_prefix: "Bearer "
        grants_attainment: use-openai-api
        placeholder: "sk-..."
      inference_config:
        endpoint: https://api.openai.com/v1/chat/completions
        request_format: openai
        streaming:
          format: sse
      embedding_config:
        endpoint: https://api.openai.com/v1/embeddings
        request_format: openai
        default_model: text-embedding-3-small
        dimensions: 1536
      models_config:
        endpoint: https://api.openai.com/v1/models
        request_format: openai

bonds:
  - from_id: model-tier/anthropic/capable
    to_id: provider/anthropic
    desmos: provided-by

  - from_id: model-tier/anthropic/balanced
    to_id: provider/anthropic
    desmos: provided-by

  - from_id: model-tier/anthropic/fast
    to_id: provider/anthropic
    desmos: provided-by
```

### 3. Desmoi

```yaml
# New bond types
- authenticates    # credential → provider (the credential authenticates access)
- provided-by      # model-tier → provider (the model tier is provided by this provider)
```

### 4. Generic HTTP Inference Engine

Replace `call_anthropic_inference()`, `call_openai_embedding()`, and `call_anthropic_structured()` in nous.rs with a generic engine that reads provider entities:

```rust
/// Execute an inference call using provider configuration from the graph.
///
/// Reads provider entity to determine: endpoint, auth, request format.
/// Resolves credential through the credential substrate.
/// Builds request in the provider's format (anthropic or openai).
/// Returns response content.
pub fn infer_with_provider(
    provider_data: &Value,     // Provider entity data
    api_key: &str,             // Resolved credential
    prompt: &str,
    system: Option<&str>,
    model: &str,
    temperature: f64,
    schema: Option<&Value>,    // For structured generation
) -> Result<Value>

/// Execute an embedding call using provider configuration from the graph.
pub fn embed_with_provider(
    provider_data: &Value,
    api_key: &str,
    text: &str,
    model: Option<&str>,       // Override provider default
) -> Result<Vec<f32>>

/// List available models from a provider.
pub fn list_models_with_provider(
    provider_data: &Value,
    api_key: &str,
) -> Result<Value>
```

Internally, each function:
1. Reads `request_format` from provider data (anthropic | openai)
2. Reads endpoint URL
3. Reads auth header name + optional prefix
4. Reads extra_headers (e.g., anthropic-version)
5. Builds request body in the correct format
6. Makes HTTP call (blocking, in separate thread — same pattern as current)
7. Parses response in the correct format
8. Returns normalized result

### 5. Two Request Formats

**Anthropic format** — Messages API:
```
POST {endpoint}
x-api-key: {api_key}
anthropic-version: {version}
Content-Type: application/json

{
  "model": "{model}",
  "max_tokens": 4096,
  "messages": [{"role": "user", "content": "{prompt}"}],
  "system": "{system}"     // top-level, not in messages
}

Response: content[0].text
Structured: tool_use mechanism (tools + tool_choice)
```

**OpenAI format** — Chat Completions:
```
POST {endpoint}
Authorization: Bearer {api_key}
Content-Type: application/json

{
  "model": "{model}",
  "max_tokens": 4096,
  "messages": [
    {"role": "system", "content": "{system}"},  // system in messages
    {"role": "user", "content": "{prompt}"}
  ]
}

Response: choices[0].message.content
Structured: response_format: { type: "json_schema", json_schema: {schema} }
```

The OpenAI format also covers: Mistral, Groq, Together, Fireworks, Ollama (local). Any provider declaring `request_format: openai` works without code changes.

### 6. Host Integration

Modify `host.rs` functions to look up provider entities:

```rust
// host.rs — infer()
pub fn infer(&self, prompt: &str, system: Option<&str>, model: &str, temperature: f64, provider_name: &str) -> Result<String> {
    // 1. Find provider entity
    let provider_entity = self.find_entity(&format!("provider/{}", provider_name))?;
    let provider_data = &provider_entity["data"];

    // 2. Resolve credential through credential substrate
    let service = provider_data["credential_config"]["service"].as_str()
        .ok_or_else(|| KosmosError::Invalid("Provider missing credential_config.service".into()))?;
    let api_key = crate::credential::resolve_credential(service, self.session.as_ref())?;

    // 3. Delegate to generic engine
    let result = crate::nous::infer_with_provider(provider_data, &api_key, prompt, system, model, temperature, None)?;
    // Extract text from normalized result
    Ok(result["content"].as_str().unwrap_or("").to_string())
}
```

Similarly for `embed()` and `infer_structured()`.

**InferStep already passes provider** — `self.provider.as_deref().unwrap_or("anthropic")` at steps.rs:2891. This value now selects which provider entity to read. No step type changes needed.

**EmbedStep needs provider support** — currently hardcoded to OpenAI. Add `provider` field to EmbedStep (in stoicheion.yaml) with default `"openai"`. The step resolves the provider entity and reads embedding_config.

### 7. Settings UI Provider Discovery

Replace hardcoded `SERVICE_PRESETS` in credential-manager.tsx:

```typescript
// Before: hardcoded array
const SERVICE_PRESETS: ServicePreset[] = [
  { service: "anthropic", label: "Anthropic", ... }
];

// After: gather from graph
const [providers] = createResource(async () => {
  const result = await invokeKosmos("gather", { eidos: "provider" });
  return result.entities.map(e => ({
    id: e.id,
    service: e.data.credential_config.service,
    label: e.data.name,
    attainment: e.data.credential_config.grants_attainment,
    placeholder: e.data.credential_config.placeholder,
  }));
});
```

The widget renders dynamically from whatever provider entities exist in the graph. Adding a new provider = adding a genesis entity. No TypeScript changes.

### 8. Substrate Signals for Inference Streaming (Phase 2 scope)

When inference supports streaming, emit substrate signals:

```rust
// During SSE streaming
signal::register_signal_source("inference", json!({
    "status": "generating",     // idle | thinking | generating | complete
    "provider": "anthropic",
    "tokens_generated": 42,
}));
```

Frontend reads via the existing `substrateSignals` Map store → DOM bridge → CSS selectors.

**This is Phase 2 scope** — the generic engine initially uses blocking request/response (same as current). Streaming adds SSE reading + signal emission as a follow-on. The provider entity already declares `streaming.format: sse` so the configuration is ready.

---

## Methodology — Doc → Test → Build → Align → Track

1. **Doc**: Update `docs/reference/reactivity/actualization-pattern.md` — add inference to substrate taxonomy, note provider entity pattern
2. **Test**: Write tests asserting generic engine reads provider entities and produces correct API calls
3. **Build**: Create provider eidos + entities, build generic engine, wire host.rs, update settings widget
4. **Align**: Update model tier resolution to use provider bonds, update credential-manager
5. **Track**: Verify completion matrix, update REGISTRY.md

---

## Implementation Order

### Step 1: Genesis — Provider Eidos and Entities

Create `genesis/soma/eide/provider.yaml`:
- `eidos/provider` definition with fields as designed above

Create `genesis/soma/entities/providers.yaml`:
- `provider/anthropic` — inference capability
- `provider/openai` — inference + embedding capabilities
- `provided-by` bonds from model-tier entities to provider/anthropic

Add desmoi to `genesis/soma/desmoi/` (or appropriate location):
- `authenticates` — credential → provider
- `provided-by` — model-tier → provider

### Step 2: Genesis — Update Embed Stoicheion

Update `genesis/arche/stoicheion.yaml`:
- Add `provider` param to `embed` step type (default: `"openai"`)

This generates the updated `EmbedStep` struct via build.rs.

### Step 3: Doc — Update Actualization Pattern

Update `docs/reference/reactivity/actualization-pattern.md`:
- Section 5 (Substrate Taxonomy): Change "Five dynamis substrates" to six, add inference
- Note: inference operations dispatch through interpreter steps (InferStep, EmbedStep), not through dynamis mode dispatch. This is the correct path — inference is an operation within praxis execution, not a reconciled entity lifecycle
- Note: provider entities make the substrate discoverable; the generic engine makes it extensible

### Step 4: Rust — Generic Inference Engine

Modify `crates/kosmos/src/nous.rs`:

Keep unchanged:
- `SurfaceResult`, `EmbeddingResponse`, `EmbeddingData` types
- `index_embedding()`, `surface_by_similarity()`, `bytes_to_f32()`, `cosine_similarity()`
- `categorize_models()` (pure logic, no API call)
- All tests

Add new generic functions:
- `infer_with_provider(provider_data, api_key, prompt, system, model, temperature, schema) → Result<Value>`
- `embed_with_provider(provider_data, api_key, text, model) → Result<Vec<f32>>`
- `list_models_with_provider(provider_data, api_key) → Result<Value>`

Internal helpers:
- `build_anthropic_request(prompt, system, model, temperature, schema) → Value`
- `build_openai_request(prompt, system, model, temperature, schema) → Value`
- `parse_anthropic_response(body) → Result<Value>`
- `parse_openai_response(body) → Result<Value>`
- `make_provider_request(provider_data, api_key, endpoint, body) → Result<String>` — builds HTTP request with correct auth headers

Mark as deprecated (but don't delete yet — tests may reference them):
- `call_anthropic_inference()` — replaced by `infer_with_provider()`
- `call_anthropic_structured()` — replaced by `infer_with_provider()` with schema
- `call_openai_embedding()` — replaced by `embed_with_provider()`
- `list_anthropic_models()` — replaced by `list_models_with_provider()`

After all callers are migrated, delete the deprecated functions. Dead code is contextual poison.

### Step 5: Rust — Wire Host to Generic Engine

Modify `crates/kosmos/src/host.rs`:

**`infer()`** (line 1120):
- Add `provider_name: &str` parameter
- Look up `provider/{provider_name}` entity
- Resolve credential via `credential::resolve_credential(service, session)`
- Call `nous::infer_with_provider()` instead of `nous::call_anthropic_inference()`

**`infer_structured()`** (line 1138):
- Same pattern — look up provider, resolve credential, call generic engine

**`embed()`** (line 1071):
- Add `provider_name: &str` parameter
- Look up provider entity, read embedding_config
- Call `nous::embed_with_provider()` instead of `nous::call_openai_embedding()`

**`list_models()`** (add new function):
- Look up provider entity, read models_config
- Call `nous::list_models_with_provider()`

### Step 6: Rust — Wire Steps to Updated Host

Modify `crates/kosmos/src/interpreter/steps.rs`:

**`InferStep::execute()`** (line 2873):
- Already extracts `provider` (defaults to "anthropic")
- Pass provider to `ctx.infer()` — currently the provider is resolved for model tier but NOT passed to the inference call itself. Fix this.

**`EmbedStep::execute()`** (line 2607):
- After Step 2, EmbedStep has a `provider` field (default "openai")
- Pass provider to `ctx.embed()`

**`resolve_model_tier()`** (line 203):
- Already works correctly — looks up `model-tier/{provider}/{tier}` entity
- Optionally: trace `provided-by` bond to verify provider entity exists

### Step 7: TypeScript — Update Credential Manager

Modify `app/src/lib/widgets/credential-manager.tsx`:
- Remove hardcoded `SERVICE_PRESETS` array
- Add `createResource` that gathers `eidos: provider` entities from the graph
- Map provider entities to the preset interface
- Render dynamically

The widget must handle the case where providers haven't been bootstrapped yet (empty graph). Show "No providers configured" rather than breaking.

### Step 8: Genesis — Update Existing Triggers

Modify `genesis/soma/reflexes/inference.yaml`:
- `trigger/soma/anthropic-credential-added` currently checks `$entity.data.service == "anthropic"`
- Generalize: create a trigger that fires on any credential add and resolves model tiers for the matching provider
- Or: add `trigger/soma/openai-credential-added` for OpenAI alongside the existing Anthropic trigger

Modify `genesis/soma/praxeis/inference.yaml`:
- `praxis/soma/resolve-model-tiers` currently only handles Anthropic
- Update to accept any provider, look up provider entity for models_config, use generic engine

### Step 9: Tests

Create `crates/kosmos/tests/inference_provider.rs`:

1. `test_provider_entity_discovery` — bootstrap, gather eidos:provider, assert anthropic + openai found
2. `test_provider_credential_config` — read provider entity, assert credential_config fields present
3. `test_infer_with_provider_anthropic_format` — mock provider data with format:anthropic, verify request body structure (system as top-level field)
4. `test_infer_with_provider_openai_format` — mock provider data with format:openai, verify request body structure (system in messages)
5. `test_embed_with_provider` — mock provider data with embedding_config, verify request
6. `test_provider_auth_headers` — anthropic uses x-api-key, openai uses Authorization: Bearer
7. `test_provider_extra_headers` — anthropic has anthropic-version header
8. `test_model_tier_bonds_to_provider` — trace provided-by bond from model-tier to provider entity
9. `test_infer_step_uses_provider` — end-to-end: InferStep with provider=anthropic reads provider entity (will fail without real API key — mark as #[ignore] or mock)

### Step 10: Verify

```bash
# Build
cargo build -p kosmos 2>&1

# All existing tests pass (no regressions)
cargo test -p kosmos --lib --tests 2>&1

# New tests pass
cargo test -p kosmos --test inference_provider 2>&1

# Genesis validates
just validate-genesis

# Credential-manager discovers providers (manual verification)
just local
# Open settings → Credentials → verify Anthropic and OpenAI appear without hardcoded presets
```

---

## Doc Impact Analysis

This prompt changes fundamental architectural concepts. The following documents must be updated as part of implementation (DDD Phase 4: Align).

### High Priority — Core Ontology

| Document | Current State | Required Change |
|----------|--------------|-----------------|
| `docs/reference/reactivity/actualization-pattern.md` | Lists 5 dynamis substrates (compute, storage, network, credential, media) | Add inference as 6th dynamis substrate. Note: inference currently has only interpreter-driven invocation (InferStep, EmbedStep), lifecycle deferred. Add provider entity concept. Update mode catalog if inference modes are added. |
| `docs/reference/infrastructure/substrate-integration.md` | Lists 6 substrates total (screen + 5 dynamis). Two dispatch patterns: stoicheion-dispatched and handler-dispatched. | Add inference as 7th substrate. Add "invocation contexts" section distinguishing reconciler-driven (persistent lifecycle) from interpreter-driven (transient operation). Inference currently has only interpreter-driven invocation; lifecycle operations deferred. Add provider entity pattern as novel contribution. |
| `CLAUDE.md` (chora) | T11 lists "compute, network, storage" as infrastructure substrates. Memory section lists "Five substrates: compute, storage, network, credential, media" | Update T11 to include inference. Update memory substrate list to six. |

### Medium Priority — Architecture & Generation

| Document | Current State | Required Change |
|----------|--------------|-----------------|
| `docs/explanation/architecture/architecture.md` | Describes manteia as "generation loop" — second of three reconciliation loops. Tier 3 stoicheia listed as "infer, embed, http, emit, spawn" | Clarify relationship: inference is a substrate dimension; manteia governs it. Generation loop = governance over inference substrate. |
| `docs/reference/generation/generation.md` | Describes `governed-inference` as tier 3 stoicheion. Pipeline: compose context → governed inference → validate → actualize | Note that governed-inference wraps the inference substrate. Provider entities supply the underlying capability; manteia governs it. |
| `docs/reference/authorization/attainment-authorization.md` | Tier 3 stoicheion gating: infer requires `use-anthropic-api` attainment. | Generalize: infer requires attainment from the resolved provider entity's `credential_config.grants_attainment`. Not hardcoded to Anthropic. |
| `CONTRIBUTING.md` (chora) | Tier 3 described as "External systems, inference" | Clarify: inference is a substrate dimension with providers, not just "external system access" |

### Medium Priority — Topos Design

| Document | Current State | Required Change |
|----------|--------------|-----------------|
| `genesis/soma/DESIGN.md` | Owns model-tier, audio-source, transcriber entities | Add `eidos/provider` to entities section. Note relationship between providers and model-tier. |
| `genesis/soma/manifest.yaml` | Eide provided: model-tier, audio-source, transcriber | Add `provider` to eide provided |
| `genesis/manteia/DESIGN.md` | "No substrate operations; no hardcoded API calls" | Update: manteia consumes inference capability from providers and adds governance. Note provider-manteia relationship. |
| `genesis/manteia/manifest.yaml` | `surfaces_consumed: []` | Consider: should manteia declare dependency on inference capability? |
| `genesis/credentials/DESIGN.md` | credential.service field lists "openai, anthropic, cloudflare" | Add section on `authenticates` desmos bonding credentials to provider entities. |

### Low Priority — Supporting References

| Document | Current State | Required Change |
|----------|--------------|-----------------|
| `docs/reference/presentation/mode-reference.md` | Notes dynamis modes have substrate + provider fields | No change needed unless inference modes are added |
| `docs/REGISTRY.md` | Impact map for code → docs | Add nous.rs → substrate-integration, actualization-pattern. Add inference_provider tests → inference substrate docs |
| `docs/reference/infrastructure/substrate-lifecycle.md` | Covers TypeScript handler pattern for media substrates | No change needed — inference uses step dispatch, not handler dispatch |

### Key Nuance: Dispatch Patterns vs Invocation Contexts

The system has two substrate **dispatch patterns** (how substrates actualize persistent phenomena):

1. **Stoicheion-dispatched** (request/response): compute, storage, network, credential — `manifest_by_stoicheion()` in host.rs
2. **Handler-dispatched** (event-driven): screen, media — TypeScript lifecycle handlers

And two **invocation contexts** (how substrate operations are called):

1. **Reconciler-driven** (persistent lifecycle): desired_state → reconcile → actual_state. A process should be running. An object should exist.
2. **Interpreter-driven** (transient operation): praxis step → host function → result. Run this command. Infer from this prompt.

These cross-cut: compute has both (mode/process-local for lifecycle, CommandStep for transient invocation). Inference currently has only interpreter-driven invocation (InferStep, EmbedStep). Its lifecycle (provider availability sensing, connection warmup) is deferred — a maturity fact, not an ontological one.

The real structural contribution of this prompt is the **provider entity pattern** — graph-driven configuration for external service access — not a new dispatch type.

---

## Files to Read

**Implementation (verify current state before changing)**:
- `crates/kosmos/src/nous.rs` — current hardcoded API functions
- `crates/kosmos/src/host.rs` — infer(), embed(), infer_structured() dispatch (lines 1071-1154)
- `crates/kosmos/src/interpreter/steps.rs` — InferStep, EmbedStep, resolve_model_tier (lines 173-219, 2607-2911)
- `crates/kosmos/src/credential.rs` — resolve_credential() for credential resolution
- `genesis/arche/stoicheion.yaml` — infer and embed step type definitions
- `crates/kosmos/build.rs` — step type generation from stoicheion.yaml

**Genesis (existing entities)**:
- `genesis/soma/entities/inference-defaults.yaml` — model-tier entities
- `genesis/soma/eide/inference.yaml` — eidos/model-tier
- `genesis/soma/praxeis/inference.yaml` — resolve-model-tiers praxis
- `genesis/soma/reflexes/inference.yaml` — credential-add trigger + reflex
- `genesis/manteia/` — governed inference surface (context, not modified)

**Settings UI**:
- `app/src/lib/widgets/credential-manager.tsx` — hardcoded SERVICE_PRESETS
- `app/src/stores/kosmos.ts` — invokeKosmos for graph queries

**Documentation**:
- `docs/reference/reactivity/actualization-pattern.md` — substrate taxonomy to update

---

## Files to Touch

| File | Change |
|------|--------|
| `genesis/soma/eide/provider.yaml` | **NEW** — eidos/provider definition |
| `genesis/soma/entities/providers.yaml` | **NEW** — provider/anthropic, provider/openai + provided-by bonds |
| `genesis/soma/desmoi/provider.yaml` | **NEW** — authenticates, provided-by desmoi definitions |
| `genesis/arche/stoicheion.yaml` | **MODIFY** — add provider param to embed step type |
| `docs/reference/reactivity/actualization-pattern.md` | **MODIFY** — add inference to substrate taxonomy |
| `crates/kosmos/src/nous.rs` | **MODIFY** — add generic engine functions, deprecate then delete hardcoded API calls |
| `crates/kosmos/src/host.rs` | **MODIFY** — infer/embed/infer_structured read provider entities |
| `crates/kosmos/src/interpreter/steps.rs` | **MODIFY** — pass provider to host functions |
| `app/src/lib/widgets/credential-manager.tsx` | **MODIFY** — replace hardcoded presets with graph discovery |
| `genesis/soma/praxeis/inference.yaml` | **MODIFY** — generalize resolve-model-tiers for any provider |
| `genesis/soma/reflexes/inference.yaml` | **MODIFY** — generalize or add OpenAI trigger |
| `crates/kosmos/tests/inference_provider.rs` | **NEW** — 9 tests |

---

## Success Criteria

- [ ] `eidos/provider` exists in genesis with credential_config, inference_config, embedding_config fields
- [ ] `provider/anthropic` and `provider/openai` entities exist and bootstrap correctly
- [ ] `model-tier/anthropic/*` entities bond to `provider/anthropic` via `provided-by`
- [ ] `nous::infer_with_provider()` produces correct Anthropic-format request (system as top-level, x-api-key header, anthropic-version header)
- [ ] `nous::infer_with_provider()` produces correct OpenAI-format request (system in messages, Authorization: Bearer header)
- [ ] `nous::embed_with_provider()` works for OpenAI embedding format
- [ ] `host.infer()` reads provider entity from graph, resolves credential, delegates to generic engine
- [ ] `host.embed()` reads provider entity from graph, resolves credential, delegates to generic engine
- [ ] `InferStep` passes provider name through to host.infer()
- [ ] `EmbedStep` has provider field (default: openai), passes to host.embed()
- [ ] Credential-manager widget discovers providers from graph — no hardcoded presets
- [ ] Settings UI shows both Anthropic and OpenAI as available providers
- [ ] All existing tests pass (zero regressions)
- [ ] No hardcoded API endpoint URLs remain in nous.rs (except in deprecated functions pending deletion)
- [ ] No hardcoded auth header names remain in nous.rs (except in deprecated functions pending deletion)

---

## What Does NOT Change

1. **Graph operations in nous.rs** — `index_embedding()`, `surface_by_similarity()`, `cosine_similarity()`, `bytes_to_f32()` stay as-is. They operate on stored data, not external APIs
2. **`categorize_models()`** — pure categorization logic stays. The generic `list_models_with_provider()` calls it
3. **Manteia topos** — governed inference surface unchanged. It invokes the inference step, which now reads provider entities. The governance layer doesn't know or care about providers
4. **Dynamis mode dispatch** — inference doesn't use manifest_by_stoicheion(). It dispatches through interpreter steps. This is correct — inference is an operation, not a reconciled entity lifecycle
5. **Model tier entity schema** — `eidos/model-tier` unchanged. `provided-by` bonds are additive
6. **step_types.rs generation** — build.rs generates EmbedStep with the new provider field from stoicheion.yaml. No manual edits to generated code
7. **Substrate signal architecture** — unchanged. Streaming (Phase 2) will use the existing signal registration system
8. **WASM stoicheia** — `infer` remains Tier 3 (requires host access). WASM stoicheia for exotic providers is a future extension

---

## What This Enables

1. **Adding a provider without code** — Add `provider/mistral` entity to genesis with `request_format: openai`. It works. Credential discovery, model listing, inference dispatch — all driven by the entity.

2. **Settings-driven provider management** — Users see all available providers in Settings → Credentials. Adding an API key for a new provider enables its capabilities immediately (via the existing credential-add trigger → model tier resolution reflex).

3. **Multi-provider model selection** — A future settings UI can show "Use Anthropic for inference, OpenAI for embeddings" as provider selection, not just credential management. The provider entities declare which capabilities they offer.

4. **Streaming visualization (Phase 2)** — The provider entities already declare `streaming.format: sse`. Phase 2 adds SSE reading to the generic engine + substrate signal emission. The thinking stream becomes visible in thyra through the same architecture that surfaces voice activity.

5. **WASM provider modules (Phase 3)** — Exotic providers (AWS Bedrock with Sig V4, Azure OpenAI with AAD tokens) can ship as WASM stoicheia in the stoicheia-portable topos. The dispatch pattern is: check for WASM module → fall back to built-in format engine.

6. **Provider-as-substrate-pattern** — The eidos/provider pattern established here extends to non-inference providers. `provider/cloudflare` declaring DNS + storage capabilities, bonded to credentials, discoverable in settings. That's a follow-on prompt, but the pattern is proven.

---

## Findings That Are Out of Scope

1. **Provider lifecycle modes** — `mode/inference-anthropic` with manifest/sense/unmanifest for availability sensing. Deferred — interpreter-driven invocation handles immediate needs; lifecycle is autonomic extension.

2. **Streaming implementation** — SSE reading, delta parsing, substrate signal emission during generation. Deferred to Phase 2 — the provider entities declare streaming config so the infrastructure is ready.

3. **Non-inference provider entities** — `provider/cloudflare` for DNS and R2. Same pattern, different scope. Follow-on prompt.

4. **WASM provider modules** — Tier 3 stoicheia implemented as WASM for exotic auth schemes. Future extension via stoicheia-portable topos.

5. **Topos coherence** — Whether provider entities belong in soma, manteia, or a new topos. Currently placed in soma alongside model-tier entities. May need revisiting as provider pattern matures.

6. **OpenAI model tier resolution** — The existing resolve-model-tiers praxis handles Anthropic only. Extending it to OpenAI (gpt-4o → capable, gpt-4o-mini → fast) requires categorization logic for OpenAI model names. Noted in Step 8 but may be a separate PR.

---

*Traces to: PROMPT-SUBSTRATE-STANDARD.md (uniform module contract), PROMPT-ONTOLOGICAL-COHERING.md (nous.rs as host's mind), PROMPT-MODEL-TIER-RESOLUTION.md (tier entity pattern), ontological discussion establishing inference as a substrate dimension. The oracle produces understanding — that is what becomes actual.*
