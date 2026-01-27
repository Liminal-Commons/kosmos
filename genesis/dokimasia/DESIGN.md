# Dokimasia: Validation

*Examination before realization.*

> **Note:** For consolidated architectural concepts (validation layers, three reconciliation loops), see [../ARCHITECTURE.md](../ARCHITECTURE.md). This document covers dokimasia-specific implementation details.

---

## The Problem

Manteia governs *who* authorizes generation. But authorization alone is insufficient:

- A malformed praxis passes review but fails at runtime
- A generation references non-existent eide
- A composition chain claims authorization but doesn't actually trace to genesis
- An entity's content doesn't match its eidos schema

**Dokimasia ensures only valid things are realized.**

---

## Implementation Status

| Component | Status | Location |
|-----------|--------|----------|
| `validation-result` eidos | **Complete** | `spora/spora.yaml` |
| `validation-error` eidos | **Complete** | `spora/spora.yaml` |
| `validated-by` desmos | **Complete** | `spora/spora.yaml` |
| `traces-to` desmos | **Complete** | `spora/spora.yaml` |
| Provenance validation praxis | **Complete** | `genesis/dokimasia/praxeis/dokimasia.yaml` |
| Schema validation praxis | **Complete** | `genesis/dokimasia/praxeis/dokimasia.yaml` |
| Semantic validation praxis | **Complete** | `genesis/dokimasia/praxeis/dokimasia.yaml` |
| Combined validation praxis | **Complete** | `genesis/dokimasia/praxeis/dokimasia.yaml` |
| Integration with realize-generation | **Complete** | `genesis/manteia/praxeis/manteia.yaml` |
| Step schema validation | **Design Complete** | This document |
| Bootstrap step validation | **Pending** | `crates/kosmos/src/bootstrap.rs` |
| Stoicheion eide | **Pending** | `genesis/spora/eide/stoicheia.yaml` |

**Phase 20.1 complete** (2026-01-20): Core eide and desmoi added to spora.yaml.
**Phase 20.2-20.4 complete** (2026-01-20): All validation praxeis implemented.
**Phase 20.5 complete** (2026-01-20): `realize-generation` now gates on dokimasia validation.
**Phase 20.6 designed** (2026-01-23): Three reconciliation loops identified; step schema validation designed.

---

## The Constitutional Requirement

From KOSMOGONIA.md:

> **Authenticity = Provenance**
>
> Everything traces back to signed genesis through composition chains.
> Modification anywhere breaks the chain. Authenticity is verified, not asserted.

Dokimasia operationalizes this requirement. Before any generation becomes an entity, we verify:

1. **Provenance** — The authorization chain terminates at `expression/genesis-root`
2. **Schema** — Content matches the target eidos definition
3. **Semantics** — All references resolve (eidos, desmoi, entities)
4. **Behavior** (optional) — Praxis executes without error in dry-run

---

## Architecture

### 1. The Validation Flow

```
┌────────────────────────────────────────────────────────────────────┐
│                        REALIZATION WITH VALIDATION                  │
├────────────────────────────────────────────────────────────────────┤
│                                                                     │
│  ┌──────────────┐                                                  │
│  │  Generation  │  (approved by manteia)                           │
│  │   Entity     │                                                  │
│  └──────┬───────┘                                                  │
│         │                                                          │
│         ▼                                                          │
│  ┌──────────────────────────────────────────────────────────────┐ │
│  │                      DOKIMASIA GATE                           │ │
│  ├──────────────────────────────────────────────────────────────┤ │
│  │                                                               │ │
│  │  ┌────────────┐  ┌────────────┐  ┌────────────┐  ┌────────┐ │ │
│  │  │ Provenance │─▶│   Schema   │─▶│  Semantic  │─▶│Behavior│ │ │
│  │  │ Validation │  │ Validation │  │ Validation │  │  (opt) │ │ │
│  │  └────────────┘  └────────────┘  └────────────┘  └────────┘ │ │
│  │         │              │               │              │       │ │
│  │         ▼              ▼               ▼              ▼       │ │
│  │     CHAIN_OK?      SCHEMA_OK?      REFS_OK?       RUNS_OK?   │ │
│  │         │              │               │              │       │ │
│  │         └──────────────┴───────────────┴──────────────┘       │ │
│  │                              │                                 │ │
│  │                    ALL PASS? │                                 │ │
│  │                              │                                 │ │
│  └──────────────────────────────┼────────────────────────────────┘ │
│                                 │                                   │
│         ┌───────────────────────┴───────────────────────┐          │
│         │                                               │          │
│         ▼                                               ▼          │
│  ┌──────────────┐                            ┌──────────────────┐  │
│  │    Entity    │  (arises)                  │ Validation Error │  │
│  │   Created    │                            │    Recorded      │  │
│  └──────────────┘                            └──────────────────┘  │
│                                                                     │
└────────────────────────────────────────────────────────────────────┘
```

### 2. Integration with Manteia

Dokimasia embeds within manteia's `realize-generation` praxis:

```
           MANTEIA                          DOKIMASIA
    ┌──────────────────┐            ┌──────────────────────┐
    │                  │            │                      │
    │  governed-       │            │  validate-           │
    │  inference       │            │  provenance          │
    │       │          │            │       │              │
    │       ▼          │            │       ▼              │
    │  approve/        │            │  validate-           │
    │  reject          │            │  schema              │
    │       │          │            │       │              │
    │       ▼          │───────────▶│       ▼              │
    │  realize-        │  (calls)   │  validate-           │
    │  generation      │◀───────────│  semantic            │
    │       │          │  (result)  │       │              │
    │       ▼          │            │       ▼              │
    │  entity arises   │            │  validation-result   │
    │                  │            │                      │
    └──────────────────┘            └──────────────────────┘
```

The flow:
1. LLM generates via `governed-inference`
2. Human or policy reviews via `approve-generation`
3. `realize-generation` is called
4. **Dokimasia validates before entity creation**
5. If valid → entity arises
6. If invalid → `validation-result` records errors, entity does NOT arise

---

## Core Eide

### validation-result

Records the outcome of validating a generation.

```yaml
eidos:
  id: eidos/validation-result
  description: "Result of validating a generation before realization"
  fields:
    generation_id:
      type: string
      required: true
      description: The generation that was validated
    passed:
      type: boolean
      required: true
      description: Whether all validation passed
    provenance_valid:
      type: boolean
      required: true
      description: Does authorization chain trace to genesis?
    schema_valid:
      type: boolean
      required: true
      description: Does content match target eidos schema?
    semantic_valid:
      type: boolean
      required: true
      description: Do all references resolve?
    behavioral_valid:
      type: boolean
      required: false
      description: Does dry-run pass? (only if requested)
    errors:
      type: array
      required: false
      description: List of validation errors (if any)
    provenance_chain:
      type: array
      required: false
      description: The traced authorization chain (for audit)
    validated_at:
      type: timestamp
      required: true
```

### validation-error

A specific validation failure.

```yaml
eidos:
  id: eidos/validation-error
  description: "A specific validation failure"
  fields:
    layer:
      type: string
      required: true
      enum: [provenance, schema, semantic, behavioral]
      description: Which validation layer failed
    code:
      type: string
      required: true
      description: Error code (e.g., CHAIN_BROKEN, MISSING_FIELD)
    message:
      type: string
      required: true
      description: Human-readable error message
    path:
      type: string
      required: false
      description: JSON path to the problem (e.g., "$.data.target_eidos")
    context:
      type: object
      required: false
      description: Additional context about the failure
```

---

## Core Desmoi

| Desmos | From | To | Meaning |
|--------|------|-----|--------|
| `validated-by` | generation | validation-result | Generation was validated, producing this result |
| `traces-to` | * | * | Provenance chain link (entity authorized by another) |

---

## Validation Layers

### Layer 1: Provenance Validation

**Question:** Does the `authorized_by` chain terminate at `expression/genesis-root`?

**Algorithm:**
1. Start with the entity to validate
2. Get its `authorized_by` reference
3. Walk the chain, recording each step
4. Check for:
   - Chain reaches `expression/genesis-root` → PASS
   - Entity without `authorized_by` → FAIL (CHAIN_BROKEN)
   - Cycle detected → FAIL (CYCLE_DETECTED)
   - Max depth exceeded → FAIL (MAX_DEPTH_EXCEEDED)
   - Entity not found → FAIL (ENTITY_NOT_FOUND)

**Error Codes:**

| Code | Meaning |
|------|---------|
| `CHAIN_BROKEN` | Entity has no `authorized_by` |
| `CYCLE_DETECTED` | Provenance chain contains a cycle |
| `MAX_DEPTH_EXCEEDED` | Chain too long (possible attack) |
| `ENTITY_NOT_FOUND` | Referenced entity doesn't exist |

### Layer 2: Schema Validation

**Question:** Does the content match the target eidos definition?

**Algorithm:**
1. Get the target eidos from the generation
2. Get the eidos definition (fields, types, required)
3. Check content against schema:
   - Required fields present?
   - Field types match?
   - Enum values valid?
   - Unknown fields? (warning only)

**Error Codes:**

| Code | Meaning |
|------|---------|
| `EIDOS_NOT_FOUND` | Target eidos doesn't exist |
| `MISSING_FIELD` | Required field not present |
| `TYPE_MISMATCH` | Field has wrong type |
| `INVALID_ENUM` | Value not in enum |
| `PARSE_ERROR` | Content is not valid JSON/YAML |

### Layer 3: Semantic Validation

**Question:** Do all references in the content resolve?

**Algorithm:**
1. Parse the content
2. Find all ID references (fields ending in `_id`, `_ids`, or containing entity IDs)
3. For each reference:
   - Entity exists?
   - Correct eidos type?
   - Desmos type exists (for bond references)?

**Error Codes:**

| Code | Meaning |
|------|---------|
| `UNRESOLVED_ENTITY` | Referenced entity doesn't exist |
| `WRONG_EIDOS` | Entity exists but wrong type |
| `UNRESOLVED_DESMOS` | Bond type doesn't exist |
| `UNRESOLVED_PRAXIS` | Praxis reference doesn't resolve |

### Layer 4: Behavioral Validation (Optional)

**Question:** Does the praxis execute without error?

For praxis entities only. Performs a dry-run.

**Algorithm:**
1. Parse praxis steps
2. Validate step syntax
3. Execute in sandbox with mock data
4. Check assertions don't fail

**Error Codes:**

| Code | Meaning |
|------|---------|
| `INVALID_STEP` | Step syntax error |
| `ASSERTION_FAILED` | Assertion step failed |
| `UNKNOWN_STOICHEION` | Step references unknown stoicheion |
| `TIER_EXCEEDED` | Step exceeds praxis tier |

---

## Praxeis

### validate-provenance

Walk the authorization chain to verify it terminates at genesis.

```yaml
- eidos: praxis
  id: praxis/dokimasia/validate-provenance
  data:
    oikos: dokimasia
    name: validate-provenance
    visible: true
    tier: 2
    description: |
      Verify that an entity's authorization traces to genesis.

      Returns:
        valid: boolean
        chain: array of entity IDs traced
        error: validation-error if failed
    params:
      - name: entity_id
        type: string
        required: true
        description: Entity to validate provenance for
      - name: max_depth
        type: number
        required: false
        description: Maximum chain length (default 100)
```

### validate-schema

Verify content matches eidos definition.

```yaml
- eidos: praxis
  id: praxis/dokimasia/validate-schema
  data:
    oikos: dokimasia
    name: validate-schema
    visible: true
    tier: 1
    description: |
      Verify content matches target eidos schema.

      Returns:
        valid: boolean
        errors: array of validation-error
    params:
      - name: eidos
        type: string
        required: true
        description: Target eidos ID
      - name: content
        type: object
        required: true
        description: Content to validate
```

### validate-semantic

Verify all references resolve.

```yaml
- eidos: praxis
  id: praxis/dokimasia/validate-semantic
  data:
    oikos: dokimasia
    name: validate-semantic
    visible: true
    tier: 1
    description: |
      Verify all entity/eidos/desmos references resolve.

      Returns:
        valid: boolean
        errors: array of validation-error
    params:
      - name: eidos
        type: string
        required: true
        description: Target eidos (determines reference fields)
      - name: content
        type: object
        required: true
        description: Content with references to validate
```

### validate-generation

Full validation of a generation before realization.

```yaml
- eidos: praxis
  id: praxis/dokimasia/validate-generation
  data:
    oikos: dokimasia
    name: validate-generation
    visible: true
    tier: 2
    description: |
      Validate a generation through all layers.

      Creates a validation-result entity recording the outcome.
      Bonds the generation to its validation-result.

      Returns the validation-result.
    params:
      - name: generation_id
        type: string
        required: true
        description: Generation to validate
      - name: include_behavioral
        type: boolean
        required: false
        description: Include behavioral validation (default false)
```

---

## Implementation Phases

### Phase 20.1: Core Eide and Desmoi (YAML)

Add to `spora/spora.yaml`:
- `validation-result` eidos
- `validation-error` eidos
- `validated-by` desmos
- `traces-to` desmos

**Deliverable:** Bootstrap loads new eide/desmoi.

### Phase 20.2: Provenance Validation (YAML)

Create `spora/praxeis/dokimasia.yaml`:
- `validate-provenance` praxis
- `_walk-provenance` internal praxis

**Deliverable:** Can verify authorization chains trace to genesis.

### Phase 20.3: Schema Validation (YAML)

Add to `spora/praxeis/dokimasia.yaml`:
- `validate-schema` praxis

**Deliverable:** Can validate content against eidos definitions.

### Phase 20.4: Semantic Validation (YAML)

Add to `spora/praxeis/dokimasia.yaml`:
- `validate-semantic` praxis

**Deliverable:** Can verify all references resolve.

### Phase 20.5: Integration (YAML)

Modify `spora/praxeis/manteia.yaml`:
- Update `realize-generation` to call dokimasia validation
- Add `validate-generation` praxis for standalone use

**Deliverable:** Realization gate enforced. No invalid entities arise.

### Phase 20.6: Behavioral Validation (In Progress)

Add to `spora/praxeis/dokimasia.yaml`:
- `validate-behavioral` praxis (dry-run)
- `validate-step-schema` praxis (step vocabulary)

Requires sandbox execution capability.

**Deliverable:** Praxis validation via dry-run.

---

## The Three Reconciliation Loops

D3 E2E testing (2026-01-23) revealed three distinct reconciliation loops operating at different layers:

### Loop 1: Actuality Reconciliation (Dynamis)

```
┌─────────────────────────────────────────────────────────┐
│  KOSMOS (intent)                    CHORA (actuality)   │
│                                                         │
│  release entity  ←──  sense()  ──→  R2 bucket          │
│       ↓                                                 │
│  compare intent vs actual                               │
│       ↓                                                 │
│  manifest() / unmanifest()  ──→  align                  │
└─────────────────────────────────────────────────────────┘
```

This is the **phylax pattern** — sense, compare, act. It operates between kosmos (the entity describing what should exist) and chora (the actual state in R2, DNS, processes).

### Loop 2: Generation Reconciliation (Manteia/Dokimasia)

```
┌─────────────────────────────────────────────────────────┐
│  EXPRESSION (desire)              ARTIFACT (generation) │
│                                                         │
│  "create a praxis"  ──→  LLM  ──→  generated content   │
│                            ↓                            │
│                     manteia governs                     │
│                            ↓                            │
│  dokimasia validates ←── approve/reject                 │
│                            ↓                            │
│                     entity arises                       │
└─────────────────────────────────────────────────────────┘
```

Manteia governs **who** authorizes. Dokimasia validates **what** is valid. Together they ensure only authorized, valid content becomes entities.

### Loop 3: Schema Reconciliation (NEW)

```
┌─────────────────────────────────────────────────────────┐
│  AUTHORED CONTENT                 INTERPRETER SCHEMA    │
│                                                         │
│  praxis YAML         ←── validate ──→  Step enum       │
│  "step: each"                         "for_each"        │
│  "id: foo"                            "entity_id: foo"  │
│       ↓                                                 │
│  DRIFT DETECTED: unknown variant 'each'                 │
│       ↓                                                 │
│  RECONCILIATION: edit YAML, retry                       │
└─────────────────────────────────────────────────────────┘
```

This loop was discovered during D3 testing when praxis YAML used `step: each` but the interpreter expected `step: for_each`. The gap is between **authored content** and **interpreter expectations**.

### The Insight: Shift Validation Left

Currently, schema reconciliation happens at **runtime** — errors surface when praxeis execute. This is expensive (restart cycles, debugging).

The proposal: shift validation to **bootstrap** or **generation** time:

1. **Bootstrap validation** — Validate praxis steps when loading, before storing
2. **Structured outputs** — Constrain LLM generation to valid schemas
3. **Schema-as-eidos** — Reflect interpreter expectations as queryable entities

---

## Step Schema Validation

### The Problem Discovered

During D3 E2E testing, these mismatches were discovered:

| Authored | Expected | Error |
|----------|----------|-------|
| `step: each` | `step: for_each` | `unknown variant 'each'` |
| `step: sense` | `step: sense_actuality` | `unknown variant 'sense'` |
| `id: $foo` | `entity_id: $foo` | `missing field 'entity_id'` |

These are **schema-level** errors — the content doesn't match the serde deserialization schema.

### The Step Vocabulary

The interpreter's `Step` enum (in `crates/kosmos/src/interpreter/steps.rs`) defines the valid vocabulary:

```rust
#[derive(Debug, Clone, Serialize, Deserialize)]
#[serde(tag = "step", rename_all = "snake_case")]
pub enum Step {
    // Tier 0 - Pure data flow
    Set(SetStep),
    Return(ReturnStep),

    // Tier 1 - Control flow
    Switch(SwitchStep),
    ForEach(ForEachStep),
    Filter(FilterStep),
    Map(MapStep),
    Reduce(ReduceStep),

    // Tier 2 - Entity operations
    Find(FindStep),
    Arise(AriseStep),
    Bind(BindStep),
    Update(UpdateStep),
    Loose(LooseStep),
    Dissolve(DissolveStep),
    Gather(GatherStep),
    Trace(TraceStep),
    Traverse(TraverseStep),

    // Tier 2 - Composition
    Compose(ComposeStep),
    Call(CallStep),

    // Tier 2 - Aisthesis (perception)
    Embed(EmbedStep),
    Index(IndexStep),
    Surface(SurfaceStep),

    // Tier 2 - Aggregate
    Sort(SortStep),
    Limit(LimitStep),

    // Tier 2 - Manteia (inference)
    Digest(DigestStep),
    Infer(InferStep),

    // Tier 3 - Energeia (actuality)
    Manifest(ManifestStep),
    SenseActuality(SenseActualityStep),
    Unmanifest(UnmanifestStep),

    // Tier 3 - Communication
    Signal(SignalStep),

    // Tier 3 - Ekthesis (emission)
    Emit(EmitStep),

    // Tier 3 - Hypostasis (cryptography)
    Keyring(KeyringStep),

    // Control
    Assert(AssertStep),
}
```

### Solution A: Schema-as-Eidos

Reflect the Step vocabulary as eidos entities in the kosmos:

```yaml
- eidos: stoicheion
  id: stoicheion/for_each
  data:
    name: for_each
    tier: 1
    description: Iterate over items
    fields:
      items:
        type: expression
        required: true
        description: Array to iterate
      as:
        type: string
        required: true
        description: Loop variable name
      do:
        type: array
        required: true
        description: Steps to execute
```

This makes the schema **queryable** — praxis authors can ask "what steps are available?" and "what fields does `manifest` require?"

### Solution B: Bootstrap Validation

Add a validation pass during bootstrap:

```rust
fn validate_praxis_steps(praxis: &Entity) -> Result<()> {
    let steps = praxis.data.get("steps")?;
    for step in steps.as_array()? {
        // Attempt to deserialize each step
        let _: Step = serde_json::from_value(step.clone())
            .map_err(|e| KosmosError::InvalidStep {
                praxis_id: praxis.id.clone(),
                error: e.to_string(),
            })?;
    }
    Ok(())
}
```

This shifts validation to **load time** — invalid praxeis fail to bootstrap.

### Solution C: Structured Outputs for Generation

When generating praxeis via manteia, constrain the output:

```yaml
- step: infer
  prompt: "Generate steps for distribute-release"
  response_format:
    type: json_schema
    json_schema:
      name: praxis_steps
      schema:
        type: array
        items:
          type: object
          properties:
            step:
              type: string
              enum: [set, return, find, for_each, manifest, sense_actuality, ...]
            # ... field schemas per step type
```

This shifts validation to **generation time** — the LLM cannot produce invalid step names.

### Recommended Approach: All Three

1. **Schema-as-eidos** (long-term) — Makes the kosmos self-describing
2. **Bootstrap validation** (immediate) — Catches errors early
3. **Structured outputs** (generation-time) — Prevents errors by construction

---

## Integration Example

Modified `realize-generation` (Phase 20.5):

```yaml
- eidos: praxis
  id: praxis/manteia/realize-generation
  data:
    oikos: manteia
    name: realize-generation
    visible: true
    tier: 2
    description: |
      Realize an approved generation as an entity.

      VALIDATES BEFORE CREATION:
      1. Provenance — authorized_by traces to genesis
      2. Schema — content matches target eidos
      3. Semantic — all references resolve

      Entity arises ONLY if all validation passes.
    params:
      - name: generation_id
        type: string
        required: true
      - name: entity_id
        type: string
        required: true
    steps:
      # ... existing approval checks ...

      # VALIDATION GATE
      - step: call
        praxis: praxis/dokimasia/validate-generation
        params:
          generation_id: "$generation_id"
        bind_to: validation

      - step: switch
        cases:
          - when: "not $validation.data.passed"
            then:
              - step: return
                value:
                  realized: false
                  validation_id: "$validation.id"
                  errors: "$validation.data.errors"

      # ... continue with entity creation ...
```

---

## Error Handling

When validation fails:

1. **Validation-result created** — Records what failed and why
2. **Bond created** — `generation → validated-by → validation-result`
3. **Entity NOT created** — Realization stops
4. **Return value** — Includes error details for caller

The generation remains `approved` (manteia's concern). It's simply not realized (dokimasia's concern). The caller can:
- Fix the content and re-attempt
- Inspect the validation-result for details
- Modify the generation and re-validate

---

## Relationship to Manteia

| Concern | Manteia | Dokimasia |
|---------|---------|-----------|
| **Who authorized?** | ✓ | — |
| **Is it approved?** | ✓ | — |
| **Audit trail?** | ✓ | — |
| **Memoization?** | ✓ | — |
| **Is chain valid?** | — | ✓ |
| **Is schema correct?** | — | ✓ |
| **Do refs resolve?** | — | ✓ |
| **Does it run?** | — | ✓ (opt) |

Manteia = authorization + audit
Dokimasia = validation + integrity

Together they ensure:
- Nothing arises without authorization
- Nothing arises that cannot work
- Full audit trail of attempts

---

## Future Considerations

### Test Case Entities

For behavioral validation, we could add:

```yaml
eidos:
  id: eidos/test-case
  description: "Test case for a praxis"
  fields:
    praxis_id: { type: string, required: true }
    name: { type: string, required: true }
    inputs: { type: object, required: true }
    expected_output: { type: object }
    expected_error: { type: string }
```

This would enable:
- Praxis authors to define test cases
- Behavioral validation to run them
- CI/CD integration

### Continuous Validation

Some validation could run continuously:
- Watch for broken provenance chains
- Detect orphaned entities
- Surface referential integrity issues

This would be a separate daemon/task.

---

## Related Documents

- [manteia/DESIGN.md](../manteia/DESIGN.md) — Governed inference
- [KOSMOGONIA.md](../KOSMOGONIA.md) — Constitutional root (provenance requirement)
- [politeia/DESIGN.md](../politeia/DESIGN.md) — Governance & capability
- [demiurge/DESIGN.md](../demiurge/DESIGN.md) — Composition

---

*Composed in service of the kosmogonia.*
*Traces to: expression/genesis-root*
*Created: 2026-01-20*
