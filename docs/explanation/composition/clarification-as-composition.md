# Clarification as Composition

*Why clarification is a content transformation that writes back to the literal fill input.*

---

## The Insight

When a user speaks or types raw text, the clarified version is an **artifact** — produced by composition from a definition, with provenance and a dependency on the input. This is the same compositional law that governs all artifacts in kosmos.

Clarification is not a special operation. It is `demiurge/compose` with a typos that uses `fill: generated`, followed by writing the result back to the accumulation's literal composition input.

---

## The Alternative We Rejected

The naive approach: create a `clarify-accumulation` praxis with hardcoded LLM prompts, custom pipeline logic, and purpose-specific state management.

Problems with this:
- Creates a one-off pattern for what is fundamentally composition
- The prompt, schema, and evaluation criteria are buried in praxis steps
- No caching, no provenance, no dependency tracking
- Cannot be reused for other clarification contexts (different eide, different domains)

---

## The Composition Approach

Clarification is a **typos definition**:

```yaml
typos/clarify-phasis:
  output_type: object
  slots:
    clarification:
      fill: generated
      tier: fast
      prompt: "Clarify this raw text: {{ raw_content }} ..."
      output_schema:
        type: object
        properties:
          content: { type: string }
          stance: { type: string, enum: [...] }
```

### How Clarification Fits the Literal-Fill Pattern

The `thyra/clarify-accumulation` praxis:

1. Reads current content from `_composition_inputs.inputs.content` on the accumulation
2. Invokes `demiurge/compose(typos_id: "typos/clarify-phasis", inputs: { raw_content: ... })`
3. Receives `{ "clarification": { "content": "Clarified text", "stance": "declaration" } }`
4. Writes clarified content back to `_composition_inputs.inputs.content`
5. Re-composes the accumulation (literal fill → template → `entity.data.content`)
6. Creates `clarified-by` bond for audit trail

This follows the same pattern as all content sources — voice flush and manual sync also update `_composition_inputs.inputs.content` and compose. Clarification simply transforms the content in-place rather than appending or replacing from an external source.

---

## What This Enables

### Reusability

The same pattern works for any clarification context. Different typos for different domains:
- `typos/clarify-phasis` — voice/text phasis clarification
- `typos/clarify-theoria` — refining crystallized understanding
- `typos/clarify-proposal` — cleaning up governance proposals

### Provenance

Every clarification traces to its definition and inputs. The artifact graph records what was clarified, when, and from what source.

### Composability

Clarification can be a slot in a larger composition:

```yaml
typos/phasis-with-context:
  slots:
    clarified:
      fill: composed
      typos_id: typos/clarify-phasis
    context:
      fill: queried
      query: "gather(eidos: theoria)"
```

### Governed Generation

The `fill: generated` pattern supports evaluation criteria. Clarification can be governed:
- Is the original meaning preserved?
- Were all disfluencies removed?
- Is the detected stance reasonable?

If the verdict fails, composition fails — no silent degradation.

---

## Grounding

This pattern follows from two principles:

**Composition-only**: Nothing arises raw. Clarification is composed from a definition.

**The compositor is simple; complexity lives in the definition**: The typos declares what to generate and how to constrain it. The compositor just executes.

The `fill: generated` slot pattern is the bridge between compositional structure and generative capability. LLM inference becomes a slot fill strategy — schema-constrained, evaluable, cacheable. And the literal-fill pattern ensures clarification's output flows back through the same composition path as every other content source.

---

*Understanding crystallized from voice authoring implementation — updated for literal-fill accumulation pattern.*
