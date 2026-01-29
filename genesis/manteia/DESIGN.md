# Manteia Design

μαντεία (manteía) — divination, prophecy, oracle

## Ontological Purpose

Manteia addresses **the gap between intention and valid structure** — the distance between wanting to generate something and having it arrive with guaranteed correctness.

Without manteia:
- LLM outputs are free-form text requiring parse-and-validate cycles
- Invalid structures can arise, requiring error handling and retry
- Generation and evaluation are separate, ad-hoc processes
- Meta-generation (praxis, typos) has no schema constraints

With manteia:
- **Schema-constrained generation**: Outputs conform to JSON schema at generation time
- **Valid-by-construction**: Invalid structure cannot arise
- **Schema sources**: Derive constraints from stoicheion, eidos, or explicit schema
- **Governed envelopes**: Generation + evaluation in one flow with verdicts
- **Meta-generation**: Create valid praxeis, steps, and typoi

The oracle speaks in structured forms. The schema constrains the prophecy.

## Circle Context

### Self Circle

A solitary dweller uses manteia to:
- Generate entity data constrained to eidos schemas (notes, theoria, insights)
- Query schema information to understand kosmos structure
- Create personal praxeis via generate-praxis
- Build custom typoi for their composition patterns

Inference is the primary creative act when structure is required.

### Peer Circle

Collaborators use manteia to:
- Generate shared artifacts with consistent structure
- Create praxeis that encode team workflows
- Evaluate generation quality against shared criteria
- Build typoi that reflect team patterns

Governed envelopes provide quality assurance for shared artifacts.

### Commons Circle

A commons circle uses manteia to:
- Define evaluation criteria for generation quality gates
- Generate canonical typoi for distribution
- Maintain generation quality standards
- Provide schema introspection for developers

Generation standards propagate through governed-envelope verdicts.

## Core Entities (Eide)

### governed-envelope

Result of governed generation with quality evaluation.

**Fields:**
- `content` — The generated content (JSON, text, code)
- `verdict` — Quality gate verdict (TRUE, FALSE, UNDECIDABLE)
- `criteria_results` — Per-criterion evaluation results [{name, status, reason}]
- `guidance` — Resolution guidance when verdict != TRUE
- `provenance` — Generation tracking (action, timestamp, prompt_hash, model)
- `created_at` — When this envelope was created

**Verdicts:**
- **TRUE**: All critical criteria pass — safe to use
- **FALSE**: Critical criterion failed — includes guidance for improvement
- **UNDECIDABLE**: Cannot determine — human review required

**Lifecycle:**
- Arise: Created by governed-inference with evaluate=true
- Change: Immutable (new generation creates new envelope)
- Depart: Archived when superseded by newer generation

### evaluation-criterion

A criterion for evaluating generated content quality.

**Fields:**
- `name` — Criterion identifier (e.g., "compiles", "handles_errors")
- `description` — What this criterion checks for
- `weight` — How failures affect verdict (critical, desired, advisory)
- `check_prompt` — Custom prompt for checking (optional)
- `created_at` — When defined

**Weights:**
- **critical**: Failure forces verdict=FALSE
- **desired**: Failure noted but doesn't force FALSE
- **advisory**: Informational only

**Lifecycle:**
- Arise: Composed when defining quality standards
- Change: Updated as quality requirements evolve
- Depart: Archived when superseded

### criterion-result

Result of evaluating a single criterion (embedded in governed-envelope).

**Fields:**
- `name` — Criterion name that was evaluated
- `status` — PASS, FAIL, or UNDECIDABLE
- `reason` — Explanation of why this status was determined
- `created_at` — When evaluated

## Operations (Praxeis)

### governed-inference

Generate structured output constrained to a JSON schema.

- **When:** Any generation requiring valid structure
- **Requires:** manteia attainment
- **Provides:** Schema-constrained JSON, optionally wrapped in governed envelope

**Schema Sources (precedence):**
1. `output_schema` — Explicit JSON schema
2. `stoicheion_id` — Derive from stoicheion eidos fields
3. `target_eidos` — Derive from any eidos fields

### generate-entity

Generate entity data constrained to an eidos schema.

- **When:** Creating entity content via inference
- **Requires:** manteia attainment
- **Provides:** Valid entity data matching eidos fields

### generate-step

Generate a single valid praxis step constrained to stoicheion schema.

- **When:** Building praxeis incrementally
- **Requires:** generate-meta attainment
- **Provides:** Valid step object for praxis steps array

### generate-praxis

Generate a complete praxis from high-level description.

- **When:** Creating new workflows via inference
- **Requires:** generate-meta attainment
- **Provides:** Complete praxis with id, params, and steps

### generate-typos

Generate a valid typos for composing entities.

- **When:** Creating new composition patterns
- **Requires:** generate-meta attainment
- **Provides:** Complete typos ready for compose

### get-stoicheion-schema

Get the JSON schema for a stoicheion step type.

- **When:** Understanding step structure
- **Requires:** manteia attainment
- **Provides:** JSON schema with properties, required fields

### list-stoicheia

List all available step types with descriptions.

- **When:** Discovering available steps
- **Requires:** manteia attainment
- **Provides:** Step types grouped by tier

## Attainments

### attainment/manteia

Core governed inference capability — schema-constrained generation.

- **Grants:** governed-inference, generate-entity, get-stoicheion-schema, list-stoicheia
- **Scope:** circle
- **Rationale:** Basic inference with schema constraints is the fundamental manteia capability

### attainment/generate-meta

Meta-level generation capability — creating kosmos definitions.

- **Grants:** generate-step, generate-praxis, generate-typos
- **Scope:** circle
- **Rationale:** Generating definitions that alter kosmos behavior requires explicit authorization

## Embodiment

### Completeness Status

| Level | Status |
|-------|--------|
| Defined | ✅ 3 eide, 8 praxeis |
| Loaded | ✅ Bootstrap loads all definitions |
| Projected | ✅ 7 praxeis visible as MCP tools (1 internal) |
| Embodied | ⏳ Body-schema contribution pending |
| Surfaced | ⏳ Reconciler not yet implemented |
| Afforded | ⏳ Thyra generation affordances pending |

### Body-Schema Contribution

When sense-body gathers manteia state:

```yaml
generation:
  available_schemas: 24       # Stoicheia with schemas
  eide_with_schemas: 18       # Eide that can constrain generation
  recent_generations: 5       # Governed envelopes in last hour
  pending_evaluations: 0      # Generations awaiting criteria check
```

This reveals generation capacity and recent activity.

### Reconciler

A manteia reconciler would surface:

- **Stale schemas** — "stoicheion/filter has been updated; regenerate dependent content"
- **Evaluation patterns** — "3 recent generations failed criterion 'compiles'"
- **Generation opportunities** — "Eidos 'task' has no typos-def; would you like to generate one?"

## Compound Leverage

### amplifies demiurge

Composition with generated slots routes through manteia. Schema-constrained generation ensures valid slot content.

### amplifies nous

Theoria crystallization can use governed-inference to structure insights. Inquiry synthesis benefits from schema constraints.

### amplifies dokimasia

Evaluation criteria can become validation rules. Governed-envelope verdicts inform validation pipelines.

### amplifies stoicheia-portable

Stoicheion field definitions ARE the schema source. Every step type gains automatic schema derivation.

## Theoria

### T38: Schema-driven generation enables valid-by-construction outputs

Traditional LLM generation requires parse-validate-retry cycles. With schema constraints enforced at generation time, invalid structure cannot arise. The constraint IS the guarantee.

### T39: Evaluation closes the generation loop

Generation without evaluation is incomplete. Governed envelopes bundle content with quality assessment, making generation a complete act rather than half a conversation.

### T40: Meta-generation enables kosmos self-extension

When the kosmos can generate valid praxeis and typoi, it gains the ability to extend itself. This is not just code generation — it's ontological growth.

## Future Extensions

### Streaming Generation

Current: Generation returns complete result. Future: Stream tokens while maintaining schema awareness for early termination.

### Evaluation Caching

Cache criterion results for similar content. Reuse evaluations when generation is semantically equivalent.

### Multi-Model Support

Current: Single model for generation. Future: Route to different models based on task type, cost constraints, or latency requirements.

### Collaborative Evaluation

Current: Single-pass evaluation. Future: Multiple evaluators with consensus for high-stakes generation.

---

*Composed in service of the kosmogonia.*
*The oracle speaks truth. The schema binds form. The verdict guides action.*
