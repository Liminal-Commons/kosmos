# Model Tier Resolution — Homoiconic Model Selection via Provider API

*Prompt for Claude Code in the chora + kosmos repository context.*

*After this work, inference model selection is tier-based, not model-ID-based.
Three tiers (capable, balanced, fast) map to the latest models from each provider.
A praxis resolves tiers by querying the provider's models API on credential add.
Tier entities are the source of truth — no hardcoded model IDs remain in the
interpreter. Depends on: credential lifecycle (complete).*

---

## Architectural Principle — Everything Is Composed

Model IDs change multiple times per year. Hardcoding `claude-sonnet-4-20250514`
in the interpreter creates a hidden dependency on a specific release moment.
When the model rotates, nothing in the graph knows. The interpreter silently
uses a stale model until someone edits Rust code.

The model ID is data. It should live in the graph as an entity — traversable,
queryable, updatable. It should arrive at inference as a composition input,
not a compiled-in default. When a user adds an API key, a praxis queries the
provider, categorizes available models into tiers, and writes the mapping to
entities. When `fill: generated` runs, it reads the tier entity. The graph IS
the configuration (T3).

Three tiers name the meaningful axis — capability vs speed vs cost:

| Tier | Meaning | Anthropic Class | Use Case |
|------|---------|-----------------|----------|
| `capable` | Highest reasoning | Opus | Complex analysis, difficult generation |
| `balanced` | General purpose | Sonnet | Standard generation, clarification |
| `fast` | Fastest, cheapest | Haiku | Simple tasks, high-frequency calls |

The tier name is provider-agnostic. The resolution is provider-specific.

---

## Methodology — DDD + TDD

This work follows **Doc → Test → Build → Verify**, non-negotiably.

1. **Doc (prescriptive)**: This prompt IS the prescriptive doc.
2. **Test (assert the doc)**: Write tests that assert the target state.
3. **Build (satisfy the tests)**: Implement until tests pass.
4. **Verify doc**: After implementation, update success criteria. Check
   docs/REGISTRY.md impact map.

Clean break — the hardcoded model strings are deleted, not wrapped.
If tier entities don't exist, inference fails explicitly.

---

## Current State

### What Exists and Works

| Component | Location | Status |
|-----------|----------|--------|
| `fill: generated` slot handler | `crates/kosmos/src/interpreter/steps.rs:2332` | Working — hardcoded `claude-sonnet-4-20250514` default |
| `step: infer` handler | `crates/kosmos/src/interpreter/steps.rs:2827` | Working — same hardcoded default |
| `call_anthropic_inference()` | `crates/kosmos/src/nous.rs` | Working — takes model as &str param |
| `call_anthropic_structured()` | `crates/kosmos/src/nous.rs` | Working — takes model as &str param |
| `host.infer()` / `host.infer_structured()` | `crates/kosmos/src/host.rs:1120` | Working — passes model through |
| `typos/clarify-phasis` | `genesis/thyra/typos/clarify-expression.yaml` | Working — no model field, uses default |
| `typos/compose-from-prompt` | `genesis/thyra/typos/compose-from-prompt.yaml` | Working — no model field |
| Credential add flow | `genesis/hypostasis/praxeis/hypostasis.yaml` | Working — stores API key in keyring |

### What's Missing — The Gaps

1. **Hardcoded model IDs.** Two places in `steps.rs` (lines 2354 and 2839)
   contain `"claude-sonnet-4-20250514"`. When models rotate, this becomes
   silently stale. No entity knows what model is being used.

2. **No tier abstraction.** No `model-tier` eidos, no tier entities. The
   meaningful dimension (capability level) is not expressed in the graph.

3. **No model discovery.** No praxis queries the Anthropic models API. The
   system doesn't know what models are available.

4. **No resolution trigger.** When a user adds an Anthropic API key, nothing
   resolves what models that key can access.

---

## Target State

### 1. Eidos and Entities

```yaml
# genesis/soma/eide/inference.yaml
- eidos: eidos
  id: eidos/model-tier
  data:
    name: model-tier
    description: |
      Maps a capability tier to a specific model ID for a provider.
      Resolved at runtime by querying the provider's models API.
    fields:
      tier:
        type: string
        description: "Capability tier: capable, balanced, or fast"
      provider:
        type: string
        description: "Provider name: anthropic, openai"
      model_id:
        type: string
        description: "Resolved model identifier (e.g., claude-sonnet-4-6-20250514)"
      resolved_at:
        type: string
        description: "ISO 8601 timestamp of last resolution"

# genesis/soma/entities/inference-defaults.yaml
- eidos: model-tier
  id: model-tier/anthropic/capable
  data:
    tier: capable
    provider: anthropic
    model_id: ""
    resolved_at: ""

- eidos: model-tier
  id: model-tier/anthropic/balanced
  data:
    tier: balanced
    provider: anthropic
    model_id: ""
    resolved_at: ""

- eidos: model-tier
  id: model-tier/anthropic/fast
  data:
    tier: fast
    provider: anthropic
    model_id: ""
    resolved_at: ""
```

Entities start with empty `model_id`. The resolution praxis fills them.

### 2. Resolution Praxis

```yaml
# genesis/soma/praxeis/inference.yaml
- eidos: praxis
  id: praxis/soma/resolve-model-tiers
  data:
    topos: soma
    name: resolve-model-tiers
    visible: true
    tier: 2
    description: |
      Query a provider's models API and resolve capability tiers.

      For Anthropic: GET /v1/models, categorize by model family
      (opus → capable, sonnet → balanced, haiku → fast),
      pick latest per tier, update model-tier entities.
    params:
      - name: provider
        type: string
        required: true
        description: "Provider to resolve (e.g., anthropic)"
    steps:
      - step: invoke
        dynamis: inference
        operation: list-models
        params:
          provider: "$provider"
        bind_to: models_result

      # Update each tier entity with resolved model_id
      - step: switch
        cases:
          - when: "$models_result.capable"
            then:
              - step: update
                id: "model-tier/$provider/capable"
                data:
                  model_id: "$models_result.capable"
                  resolved_at: "$_now"
          - when: "true"
            then: []

      - step: switch
        cases:
          - when: "$models_result.balanced"
            then:
              - step: update
                id: "model-tier/$provider/balanced"
                data:
                  model_id: "$models_result.balanced"
                  resolved_at: "$_now"
          - when: "true"
            then: []

      - step: switch
        cases:
          - when: "$models_result.fast"
            then:
              - step: update
                id: "model-tier/$provider/fast"
                data:
                  model_id: "$models_result.fast"
                  resolved_at: "$_now"
          - when: "true"
            then: []

      - step: return
        value:
          provider: "$provider"
          capable: "$models_result.capable"
          balanced: "$models_result.balanced"
          fast: "$models_result.fast"
```

### 3. Tier Resolution in the Interpreter

```rust
// In steps.rs — fill: generated slot handler and InferStep
// Replace:
//   let model = slot_def.get("model").and_then(|v| v.as_str())
//       .unwrap_or("claude-sonnet-4-20250514");
// With:
let model = resolve_model(ctx, slot_def, scope)?;

/// Resolve model ID from tier entity or explicit model field.
///
/// Priority:
/// 1. Explicit `model:` on the slot/step → use as-is
/// 2. `tier:` on the slot/step → look up model-tier/{provider}/{tier}
/// 3. No field → default tier "fast", provider "anthropic"
fn resolve_model(ctx: &HostContext, def: &Value, scope: &Scope) -> Result<String> {
    // Explicit model — escape hatch for testing or pinning
    if let Some(model) = def.get("model").and_then(|v| v.as_str()) {
        return Ok(eval_string(model, scope)?);
    }

    let tier = def.get("tier")
        .and_then(|v| v.as_str())
        .unwrap_or("fast");
    let provider = def.get("provider")
        .and_then(|v| v.as_str())
        .unwrap_or("anthropic");

    let entity_id = format!("model-tier/{}/{}", provider, tier);
    let entity = ctx.find_entity(&entity_id)?
        .ok_or_else(|| KosmosError::NotFound(format!(
            "Model tier entity not found: {}. Run soma/resolve-model-tiers first.", entity_id
        )))?;

    let model_id = entity.get("data")
        .and_then(|d| d.get("model_id"))
        .and_then(|v| v.as_str())
        .filter(|s| !s.is_empty())
        .ok_or_else(|| KosmosError::Invalid(format!(
            "Model tier {} has no resolved model_id. Add an API key and resolve tiers.", entity_id
        )))?;

    Ok(model_id.to_string())
}
```

### 4. Model Discovery in nous.rs

```rust
// New function in nous.rs
/// List available models from the Anthropic API.
///
/// Calls GET /v1/models and categorizes into tiers:
/// - "opus" in name → capable
/// - "sonnet" in name → balanced
/// - "haiku" in name → fast
/// Returns the latest model ID per tier.
pub fn list_anthropic_models(api_key: &str) -> Result<Value> {
    // GET https://api.anthropic.com/v1/models
    // Parse response, categorize, pick latest per tier
    // Return: { capable: "model-id", balanced: "model-id", fast: "model-id" }
}
```

### 5. Stoicheion Dispatch for list-models

The `list-models` operation dispatches through the standard stoicheion pattern.
New stoicheion entry in `stoicheion.yaml`:

```yaml
- mode: inference
  provider: anthropic
  operations:
    list-models:
      step_type: invoke
```

The `execute_operation` in a new `inference.rs` module (or added to `nous.rs`)
handles `list-models` by calling `list_anthropic_models()`.

### 6. Resolution Trigger

When a credential is added with service `anthropic`, resolve tiers automatically.
Two options:

**Option A**: Add steps to the `push-token` praxis (or a post-credential reflex)
that calls `soma/resolve-model-tiers` after an Anthropic key is stored.

**Option B**: A reflex on credential entity creation that fires for Anthropic
credentials and invokes the resolution praxis.

Option B is more homoiconic — the reflex is an entity in the graph.

### 7. Typos Updates

```yaml
# typos/clarify-phasis — add tier field
slots:
  clarification:
    fill: generated
    tier: fast
    prompt: |
      You are a clarification assistant...
    output_schema: ...

# typos/compose-from-prompt — add tier field
slots:
  generation:
    fill: generated
    tier: fast
    prompt: "{{ prompt }}"
    output_schema: ...
```

---

## Sequenced Work

### Phase 1: Genesis + Tier Resolution Function

**Goal:** Define the eidos, entities, and model discovery function.

**Tests:**
- `test_list_anthropic_models_parses_response` — mock HTTP response from
  models API, verify tier categorization returns correct model IDs
- `test_resolve_model_from_tier_entity` — create a model-tier entity with
  model_id, verify `resolve_model()` returns it
- `test_resolve_model_empty_fails` — model-tier entity with empty model_id
  returns explicit error
- `test_resolve_model_missing_entity_fails` — no entity → clear error message

**Implementation:**
1. Create `genesis/soma/eide/inference.yaml` with `eidos/model-tier`
2. Create `genesis/soma/entities/inference-defaults.yaml` with three tier entities
3. Add `list_anthropic_models()` to `nous.rs` — HTTP GET, parse, categorize
4. Add `resolve_model()` function to `steps.rs`
5. Wire `resolve_model()` into both `fill: generated` handler and `InferStep`
6. Remove hardcoded `"claude-sonnet-4-20250514"` from both locations
7. Add `tier: fast` to `typos/clarify-phasis` and `typos/compose-from-prompt`

**Phase 1 Complete When:**
- [ ] `eidos/model-tier` bootstraps correctly
- [ ] Three tier entities exist after bootstrap
- [ ] `list_anthropic_models()` parses mock response correctly
- [ ] `resolve_model()` reads from tier entity
- [ ] `resolve_model()` fails explicitly when entity missing or empty
- [ ] No hardcoded model IDs in interpreter
- [ ] 4 new tests pass
- [ ] All existing tests pass

### Phase 2: Praxis + Trigger

**Goal:** Wire the resolution praxis and credential trigger.

**Tests:**
- `test_resolve_model_tiers_praxis_updates_entities` — invoke the praxis,
  verify tier entities have model_id populated
- `test_credential_add_triggers_resolution` — add Anthropic credential,
  verify tier resolution fires automatically

**Implementation:**
1. Add stoicheion entry for `inference/anthropic/list-models`
2. Add dispatch in `nous.rs` or new `inference.rs` for `list-models` operation
3. Create `genesis/soma/praxeis/inference.yaml` with `resolve-model-tiers` praxis
4. Create trigger + reflex for credential-added → resolve tiers
   (fires on credential entity creation where service == "anthropic")
5. Update `genesis/soma/manifest.yaml` to include new files

**Phase 2 Complete When:**
- [ ] `soma/resolve-model-tiers` praxis invocable and updates entities
- [ ] Adding Anthropic credential auto-resolves tiers
- [ ] Tier entities populated with real model IDs after resolution
- [ ] 2 new tests pass
- [ ] `just prod` builds successfully

---

## Files to Read

### Interpreter
- `crates/kosmos/src/interpreter/steps.rs` — `fill: generated` handler, InferStep
- `crates/kosmos/src/interpreter/step_types.rs` — step type definitions

### Inference
- `crates/kosmos/src/nous.rs` — Anthropic API calls
- `crates/kosmos/src/host.rs` — `infer()`, `infer_structured()`

### Genesis
- `genesis/thyra/typos/clarify-expression.yaml` — typos/clarify-phasis
- `genesis/thyra/typos/compose-from-prompt.yaml` — typos/compose-from-prompt
- `genesis/arche/stoicheion.yaml` — stoicheion dispatch table
- `genesis/hypostasis/praxeis/hypostasis.yaml` — credential praxeis

### Docs
- `docs/reference/composition/typos-composition.md` — fill patterns
- `docs/explanation/composition/clarification-as-composition.md` — generated example

---

## Files to Touch

| File | Change |
|------|--------|
| `genesis/soma/eide/inference.yaml` | **NEW** — `eidos/model-tier` |
| `genesis/soma/entities/inference-defaults.yaml` | **NEW** — three tier entities |
| `genesis/soma/praxeis/inference.yaml` | **NEW** — `resolve-model-tiers` praxis |
| `genesis/soma/manifest.yaml` | **MODIFY** — include new files |
| `crates/kosmos/src/nous.rs` | **MODIFY** — add `list_anthropic_models()` |
| `crates/kosmos/src/interpreter/steps.rs` | **MODIFY** — add `resolve_model()`, remove hardcoded defaults |
| `genesis/thyra/typos/clarify-expression.yaml` | **MODIFY** — add `tier: fast` |
| `genesis/thyra/typos/compose-from-prompt.yaml` | **MODIFY** — add `tier: fast` |
| `genesis/arche/stoicheion.yaml` | **MODIFY** — add inference stoicheion |
| `crates/kosmos/tests/model_tier_resolution.rs` | **NEW** — test file |
| `docs/reference/composition/typos-composition.md` | **MODIFY** — update generated fill docs |
| `docs/explanation/composition/clarification-as-composition.md` | **MODIFY** — add tier to example |
| `docs/REGISTRY.md` | **MODIFY** — add nous.rs impact map entries |

---

## Success Criteria

### Phase 1
- [ ] No hardcoded model IDs in interpreter code
- [ ] `resolve_model()` reads model_id from tier entity
- [ ] Explicit failure when tier entity missing or unresolved
- [ ] `model:` field still works as explicit override
- [ ] `tier: fast` is the default when neither model nor tier specified
- [ ] Typos updated with tier field
- [ ] 4 new tests pass

### Phase 2
- [ ] Resolution praxis queries Anthropic models API
- [ ] Tier entities populated after resolution
- [ ] Credential add triggers automatic resolution
- [ ] `just prod` builds and installs

**Overall Complete When:**
- [ ] All existing tests still pass
- [ ] Inference uses graph-resolved model IDs
- [ ] No hardcoded model strings anywhere in chora
- [ ] Docs updated to reflect tier pattern
- [ ] Model rotation requires zero code changes — just re-run resolution

---

## What This Enables

1. **Model rotation without code changes.** When Anthropic releases new models,
   re-running `soma/resolve-model-tiers` updates the graph. No Rust edits.

2. **Multi-provider inference.** The tier abstraction is provider-agnostic.
   Adding OpenAI: create `model-tier/openai/*` entities, add resolution logic,
   done. The typos just says `tier: balanced`.

3. **Inspectable model selection.** `find model-tier/anthropic/balanced` shows
   exactly what model is being used and when it was resolved.

4. **Per-slot tier selection.** A complex typos can use `tier: capable` for
   its critical slot and `tier: fast` for a simple one. Cost control at the
   composition level.

---

## What Does NOT Change

- `call_anthropic_inference()` / `call_anthropic_structured()` — still take
  model as `&str`, no changes
- `host.infer()` / `host.infer_structured()` — unchanged API
- Composition pipeline — `fill: generated` still works the same way, just
  resolves model differently
- Credential storage and keyring — unchanged
- `typos/clarify-phasis` prompt and output_schema — unchanged
- MCP tool exposure — unchanged (manteia tools still work)

---

## Doc Impact Assessment

| Doc | What Changed |
|-----|-------------|
| `docs/reference/composition/typos-composition.md` | Update `generated` fill pattern — add `tier` field, show tier example |
| `docs/explanation/composition/clarification-as-composition.md` | Update typos example with `tier: fast` |
| `docs/how-to/presentation/create-artifact-mode.md` | Update generated pattern row if tier mentioned |
| `docs/REGISTRY.md` | Add `nous.rs` → typos-composition, clarification-as-composition |

---

*Traces to: T3 (schema+graph+cache are one practice), T5 (code is artifact),
PROMPT-COMPOSE-BAR.md (composition pipeline), PROMPT-LITERAL-FILL-ACCUMULATION.md
(literal fill pattern)*
