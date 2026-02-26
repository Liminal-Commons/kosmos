# Governed Generation Integration

*Two-step inference with self-evaluation — the V4 pattern integrated into V8 manteia.*

**Status:** DRAFT

---

## The V4 Insight

From `archive/genesis-v4-DEPRECATED/demiurge-v4/demiurge.core.yaml`:

> "**Dokimasia is not a feature of the demiurge. Dokimasia IS the demiurge.**"
>
> "The demiurge embodies a singular insight: *specification is the generative act*."

Generation without evaluation is incomplete. The evaluation step is part of what it means to generate properly.

---

## Current State: Manteia

Current `manteia/governed-inference` provides **structural validity**:

```
prompt + schema → LLM (tool_use) → valid JSON → done
```

The schema constrains structure. Invalid structure cannot arise. But this says nothing about:
- Is the *content* good?
- Does it follow expected patterns?
- Would it compile? Would it work?

---

## The V4 Pattern: Two-Step Inference

V4 governed generation added **quality evaluation**:

```
Step 1: Generation Inference
  prompt + inputs → LLM → raw output

Step 2: Evaluation Inference
  output + criteria → LLM → verdict + guidance

Step 3: Envelope Assembly (mechanical)
  output + verdict + guidance + provenance → governed envelope
```

### The Governed Envelope

```yaml
governed-envelope:
  verdict: TRUE | FALSE | UNDECIDABLE

  output:
    content: "..."        # The generated artifact
    path: "..."           # Target location
    type: rust | yaml | md | etc

  provenance:
    action: governed-generate
    config_id: "..."
    timestamp: "..."
    tests_run: 3
    tests_passed: 3

  criteria_results:
    - name: compiles
      status: PASS
      reason: "Valid Rust syntax"
    - name: follows_idioms
      status: PASS
      reason: "Uses standard patterns"
    - name: handles_errors
      status: PASS
      reason: "Returns Result, no unwrap()"

  guidance: null  # or resolution hints if verdict != TRUE
```

### Verdict Semantics

| Verdict | Meaning | Action |
|---------|---------|--------|
| **TRUE** | All critical criteria pass | Safe to emit/realize |
| **FALSE** | Critical criterion failed | Return guidance for fix |
| **UNDECIDABLE** | Cannot determine | Human review required |

### Guidance Structure

When verdict != TRUE, guidance provides actionable direction:

```yaml
guidance:
  direction: ASCEND | DESCEND | LATERAL
  target_stratum: stoicheion | praxis | topos
  target_topos: soma | nous | etc
  gap_kind: missing | incomplete | incoherent
  resolution_hint: "Need to add error handling for network failures"
```

---

## Integration Proposal

### Extend `manteia/governed-inference`

Add optional evaluation phase to current praxis:

```yaml
- eidos: praxis
  id: praxis/manteia/governed-inference
  data:
    name: governed-inference
    description: |
      Generate structured output with optional quality evaluation.

      Phases:
      1. Schema-constrained generation (always)
      2. Quality evaluation against criteria (optional)

      Returns governed envelope with verdict and guidance.
    params:
      - name: prompt
        required: true
      - name: output_schema
        required: false
        description: "JSON Schema for structural constraint"
      - name: target_eidos
        required: false
        description: "Derive schema from eidos fields"
      - name: stoicheion_id
        required: false
        description: "Derive schema from stoicheion fields"

      # NEW: Evaluation parameters
      - name: evaluation_criteria
        required: false
        description: "Array of {name, description, weight}"
      - name: skip_evaluation
        required: false
        default: true
        description: "If true, skip evaluation (default for backward compat)"

    steps:
      # Phase 1: Schema-constrained generation (existing)
      - step: infer
        prompt: "$prompt"
        output_schema: "$output_schema"
        target_eidos: "$target_eidos"
        stoicheion: "$stoicheion_id"
        bind_to: generated_content

      # Phase 2: Evaluation (new, optional)
      - step: switch
        cases:
          - when: "$evaluation_criteria and not $skip_evaluation"
            then:
              - step: call
                praxis: manteia/_evaluate-generation
                params:
                  content: "$generated_content"
                  criteria: "$evaluation_criteria"
                bind_to: evaluation
          - when: "true"
            then:
              - step: set
                bindings:
                  evaluation:
                    verdict: UNDECIDABLE
                    criteria_results: []
                    guidance: null

      # Phase 3: Assemble envelope
      - step: return
        value:
          content: "$generated_content"
          verdict: "$evaluation.verdict"
          criteria_results: "$evaluation.criteria_results"
          guidance: "$evaluation.guidance"
          provenance:
            action: governed-inference
            timestamp: "{{ now() }}"
```

### New Internal Praxis: `_evaluate-generation`

```yaml
- eidos: praxis
  id: praxis/manteia/_evaluate-generation
  data:
    name: _evaluate-generation
    visible: false
    description: |
      Evaluate generated content against criteria.
      Returns verdict, criteria_results, and guidance.
    params:
      - name: content
        required: true
      - name: criteria
        required: true
    steps:
      - step: set
        bindings:
          eval_prompt: |
            Evaluate this generated content against the criteria below.

            ## Content
            $content

            ## Criteria
            $criteria

            For each criterion, determine PASS, FAIL, or UNDECIDABLE.

            Return:
            - criteria_results: [{name, status, reason}]
            - verdict: TRUE (all critical pass), FALSE (any critical fail), UNDECIDABLE
            - guidance: (if verdict != TRUE) {resolution_hint, gap_kind}

      - step: infer
        prompt: "$eval_prompt"
        output_schema:
          type: object
          properties:
            criteria_results:
              type: array
              items:
                type: object
                properties:
                  name: { type: string }
                  status: { type: string, enum: [PASS, FAIL, UNDECIDABLE] }
                  reason: { type: string }
            verdict:
              type: string
              enum: [TRUE, FALSE, UNDECIDABLE]
            guidance:
              type: object
              properties:
                resolution_hint: { type: string }
                gap_kind: { type: string, enum: [missing, incomplete, incoherent] }
          required: [criteria_results, verdict]
        bind_to: result

      - step: return
        value: "$result"
```

### New Eidos: `governed-envelope`

```yaml
- eidos: eidos
  id: eidos/governed-envelope
  data:
    name: governed-envelope
    description: |
      Result of governed generation with quality evaluation.
      Contains content, verdict, criteria results, and guidance.
    fields:
      content:
        type: any
        required: true
        description: "The generated content"
      verdict:
        type: string
        required: true
        enum: [TRUE, FALSE, UNDECIDABLE]
      criteria_results:
        type: array
        required: true
        description: "Per-criterion evaluation results"
      guidance:
        type: object
        required: false
        description: "Resolution guidance if verdict != TRUE"
      provenance:
        type: object
        required: true
        description: "Generation provenance (action, timestamp, config)"
```

---

## Relation to Three Pillars

The three pillars (schema-driven, graph-driven, cache-driven) plus governed generation:

| Pillar | What It Ensures | Mechanism |
|--------|-----------------|-----------|
| Schema-driven | Structure valid | JSON Schema + tool_use |
| Graph-driven | References resolve | Bonds, not embedded IDs |
| Cache-driven | Content-addressed | BLAKE3 hash, memoization |
| **Governed** | Quality verified | Evaluation criteria + verdict |

This isn't a fourth pillar — it's **the integration point where the pillars meet generation**:

- Schema-driven governs *structure*
- Evaluation governs *quality*
- Together = **valid by construction + verified by evaluation**

---

## Relation to Dokimasia

Dokimasia validates *entities* (provenance, schema, semantics).
Governed generation validates *generation output* (criteria, quality).

They operate at different phases:

```
┌─────────────────────────────────────────────────────────────┐
│                    GENERATION PHASE                          │
├─────────────────────────────────────────────────────────────┤
│  manteia/governed-inference                                  │
│    1. Schema constraint (structural validity)                │
│    2. Criteria evaluation (quality verdict)                  │
│    → governed-envelope                                       │
└─────────────────────────────────────────────────────────────┘
                           │
                           ▼ (if verdict = TRUE)
┌─────────────────────────────────────────────────────────────┐
│                   COMPOSITION PHASE                          │
├─────────────────────────────────────────────────────────────┤
│  demiurge/compose                                            │
│    1. Resolve definition                                     │
│    2. Fill slots (literal, computed, queried, generated)     │
│    3. dokimasia validates before arise                       │
│       - Provenance: authorized_by chain                      │
│       - Schema: fields match eidos                           │
│       - Semantic: references resolve                         │
│    → entity with provenance                                  │
└─────────────────────────────────────────────────────────────┘
```

**Governed generation** operates on LLM output.
**Dokimasia** operates on entity persistence.

Both are validation — at different levels, for different purposes.

---

## Fill Method Integration

The `generated` fill method in artifact composition could use governed generation:

```yaml
# Artifact definition with governed slot
artifact-def-code-module:
  name: code-module
  target_eidos: code-artifact
  slots:
    implementation:
      caller: generated
      prompt: "Generate implementation for {{ module_name }}"
      output_schema: { ... }
      # NEW: Criteria for quality evaluation
      evaluation_criteria:
        - name: compiles
          description: "Valid syntax"
          weight: critical
        - name: handles_errors
          description: "Proper error handling"
          weight: desired
      require_verdict: TRUE  # Only use if verdict = TRUE
```

When `require_verdict: TRUE`, the slot only fills if evaluation passes. If FALSE, composition fails with guidance for fix.

---

## Benefits

1. **Quality gates without human bottleneck** — LLM evaluates its own output
2. **Actionable feedback** — guidance tells what to fix, not just that it failed
3. **Traceable** — governed envelopes record criteria results and provenance
4. **Composable** — works with artifact composition fill methods
5. **Optional** — skip_evaluation for speed when quality is less critical

---

## Implementation Steps

1. Add `governed-envelope` eidos to manteia
2. Implement `_evaluate-generation` internal praxis
3. Extend `governed-inference` with optional evaluation params
4. Update `generated` fill method to support `evaluation_criteria`
5. Add `require_verdict` option to composition

---

## Open Questions

1. **Model for evaluation** — Same model as generation, or different?
2. **Critical vs desired weights** — How to aggregate?
3. **Retry on FALSE** — Should governed-inference auto-retry with guidance?
4. **Human escalation** — UI for UNDECIDABLE cases?

---

## Theoria

**T22: Generation without evaluation is incomplete**
The V4 insight: "Dokimasia IS the demiurge." Evaluation is not a separate concern — it's part of what it means to generate properly. Schema constraint ensures structure; criteria evaluation ensures quality.

**T23: Verdict gates realization**
TRUE → safe to emit/realize. FALSE → guidance for fix. UNDECIDABLE → human review. The envelope carries both content and its quality status.

**T24: Two validations, two levels**
Governed generation validates LLM output (generation phase). Dokimasia validates entity persistence (composition phase). Both are necessary; neither is sufficient alone.

---

*Drafted 2026-01-25 — integrating V4 governed envelope pattern with V8 manteia*
