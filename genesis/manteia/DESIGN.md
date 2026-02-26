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

## Oikos Context

### Self Oikos

A solitary dweller uses manteia to:
- Generate entity data constrained to eidos schemas (notes, theoria, insights)
- Query schema information to understand kosmos structure
- Create personal praxeis via generate-praxis
- Build custom typoi for their composition patterns

Inference is the primary creative act when structure is required.

### Peer Oikos

Collaborators use manteia to:
- Generate shared artifacts with consistent structure
- Create praxeis that encode team workflows
- Evaluate generation quality against shared criteria
- Build typoi that reflect team patterns

Governed envelopes provide quality assurance for shared artifacts.

### Commons Oikos

A commons oikos uses manteia to:
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

## Bonds (Desmoi)

### generated-by

Generation was produced by this inference call.

- **From:** generation
- **To:** governed-envelope
- **Cardinality:** one-to-one
- **Traversal:** Find the governance context for a generation

### evaluated-against

Generation was evaluated against these criteria.

- **From:** governed-envelope
- **To:** criterion
- **Cardinality:** one-to-many
- **Traversal:** Find what criteria governed a generation

### constrained-to

Generation was constrained to this schema source.

- **From:** generation
- **To:** eidos (or stoicheion)
- **Cardinality:** many-to-one
- **Traversal:** Find generations for an eidos

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
- **Scope:** oikos
- **Rationale:** Basic inference with schema constraints is the fundamental manteia capability

### attainment/generate-meta

Meta-level generation capability — creating kosmos definitions.

- **Grants:** generate-step, generate-praxis, generate-typos
- **Scope:** oikos
- **Rationale:** Generating definitions that alter kosmos behavior requires explicit authorization

## Inference Context Composition

The prompt is not a string — it's a composed artifact.

Traditional LLM integration treats prompts as hardcoded templates with variable interpolation. Manteia introduces **homoiconic prompt composition**: the prompt itself is assembled from graph operations, making what inference sees as composable as any other artifact.

### The Core Insight

What goes into an inference call can be decomposed:

| Component | Source | Purpose |
|-----------|--------|---------|
| Schema source | Eidos or typos | What structured output we want |
| Domain theoria | Graph surface query | Relevant crystallized understanding |
| Role/prosopon | Slot default or input | How to reason about this |
| Constraints | Array of guardrails | What to avoid or enforce |
| Input artifacts | Entity IDs | Primary subjects being worked on |
| Human phasis | Phasis entity | What the human said/wants |
| Additional context | Graph traversal | Supporting entities |
| Context depth | Number | How deep to follow bonds |
| Request | String | The actual instruction |

Each component is a slot. The inference context is a typos. Composition assembles what inference sees.

### The Base Typos

`typos-def-inference-context` (defined in `manteia/typos/manteia.yaml`) provides the base pattern:

```yaml
- eidos: typos
  id: typos-def-inference-context
  data:
    name: inference-context
    description: |
      Compose an inference call context from graph operations.
      This enables homoiconic prompt engineering — prompts are data, not code.
    slots:
      # SYSTEM PROMPT COMPONENTS
      schema_source:      # Entity ID of eidos/typos for output schema
      domain_theoria:     # Query spec to surface relevant theoria
      role:               # Prosopon for the inference
      constraints:        # Explicit guardrails on generation

      # USER PROMPT COMPONENTS
      input_artifacts:    # Entity IDs of primary subjects
      human_phasis:       # Entity ID of the driving phasis
      additional_context: # Query spec for supporting entities
      context_depth:      # Bond traversal depth (default 1)
      request:            # The actual instruction

      # OUTPUT CONFIGURATION
      output_schema:      # Explicit JSON schema (or derived from schema_source)
      evaluate:           # Whether to produce governed envelope
      criteria:           # Evaluation criteria if evaluate=true
```

### Domain Extensions

Topoi extend the base with domain-appropriate defaults:

**typos-inference-update-artifact** (voice-authoring):
```yaml
extends: typos-def-inference-context
slots:
  role:
    default: |
      You are an editor. Update documents based on human discussion
      while maintaining consistency with existing style and structure.
  constraints:
    default:
      - "Preserve existing section structure unless explicitly asked"
      - "Use the same voice and terminology as the existing document"
      - "Make minimal changes to achieve the intent"
```

**typos-inference-eidos** (topos generation):
```yaml
extends: typos-def-inference-context
slots:
  role:
    default: |
      You are an ontology designer for the kosmos system.
      Eide define what can exist — they are the forms, the types.
  constraints:
    default:
      - "Field names should be snake_case"
      - "Description should explain ontological purpose"
      - "Consider what bonds this eidos will participate in"
```

See `manteia/typos/manteia.yaml` and `demiurge/typos/oikos-generation.yaml` for the full catalog.

### The Canonical Usage Pattern

Praxeis that need inference follow this two-step pattern:

```yaml
# Step 1: Compose inference context
- step: compose
  typos_id: typos-inference-eidos
  inputs:
    name: "$name"
    purpose: "$purpose"
    domain: "$domain"
    field_hints: "$field_hints"
  bind_to: inference_context

# Step 2: Call governed inference with composed context
- step: call
  praxis: manteia/governed-inference
  params:
    prompt: "$inference_context.request"
    output_schema: "$inference_context.output_schema"
    system_prompt: "$inference_context.role"
  bind_to: result
```

The inference context is composed like any artifact. Then governed-inference receives the assembled components.

### The Reasoning Surface

Manteia provides the **reasoning** surface — the capability for governed inference. Other topoi consume this surface:

| Consumer | What They Do |
|----------|--------------|
| demiurge | Generate eidos, praxis, desmos definitions |
| nous | Invoke for theoria synthesis |
| voice-authoring | Update artifacts from phaseis |
| dokimasia | Generate test cases |

The surface pattern (`surfaces_provided: [reasoning]` in manifest) makes this dependency explicit. Topoi that consume reasoning extend `typos-def-inference-context` with their domain defaults.

### Why This Matters

1. **Prompts are inspectable** — The inference context is an entity. You can see exactly what inference saw.

2. **Prompts are composable** — Theoria, artifacts, phaseis all flow in through graph operations, not string concatenation.

3. **Domain knowledge accumulates** — As theoria crystallizes, inference contexts automatically incorporate it via `domain_theoria` queries.

4. **Patterns are reusable** — Domain extensions capture best practices. Teams compose with `typos-inference-eidos`, not raw prompts.

5. **Context is bounded** — `context_depth` controls how much graph context flows in, preventing unbounded expansion.

This is homoiconic prompt engineering: the prompt is composed from the same graph that inference operates on.

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
