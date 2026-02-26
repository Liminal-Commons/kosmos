# Schema Enforcement — T9

*Why `output_schema` via tool_use is more reliable than prompt instructions for constraining LLM output.*

---

## The Principle

**Theoria T9:** When generating structured output from an LLM, use `output_schema` (JSON Schema enforced through the tool_use API) rather than prompt instructions ("please output valid YAML matching this format").

Schema enforcement is structural, not instructional. The LLM's response is constrained by the API interface itself, not by the LLM's compliance with instructions.

---

## Why This Matters

### Prompt Instructions Are Soft

```
Please generate a render-spec with the following structure:
- layout: array of widget nodes
- Each node must have a "widget" field
- target_eidos must be a string
```

The LLM will usually comply. But "usually" isn't good enough for a system that creates entities in a graph. A malformed render-spec that passes validation but has a subtle structural error will cause runtime failures in the interpreter.

### output_schema Is Hard

```json
{
  "type": "object",
  "required": ["layout", "target_eidos", "variant"],
  "properties": {
    "layout": {
      "type": "array",
      "items": {
        "type": "object",
        "required": ["widget"],
        "properties": {
          "widget": { "type": "string" }
        }
      }
    },
    "target_eidos": { "type": "string" },
    "variant": { "type": "string" }
  }
}
```

The API enforces this schema on the response. The LLM cannot produce output that doesn't match — not because it's following instructions, but because the response format is constrained. This is the difference between asking someone to follow rules and building guardrails.

---

## Empirical Evidence

The generative proof tested this directly. When `render-spec/note-card` was generated via `demiurge/generate-render-spec`:

1. The inference context composed the prompt (eidos fields, widget vocabulary, examples)
2. `governed-inference` called the LLM with `output_schema` via tool_use
3. The response was a valid render-spec — correct structure, valid widget names, proper binding syntax
4. Validation passed on the first attempt

The generated output was not just structurally valid — it was semantically appropriate (correct widgets for the field types, reasonable layout choices). The schema enforced structure; the composed context guided semantics.

---

## Implications for Future Generation

1. **Every generation pipeline should use output_schema** — Don't rely on prompt instructions for structure. Use them for semantics (what to generate, not how to format it).

2. **Schema design is critical** — The schema determines what the LLM can produce. A schema that's too restrictive prevents creativity. A schema that's too permissive allows malformed output. The render-spec schema hit the right balance: required structural fields (layout, target_eidos) with flexible content (widget choice, prop values).

3. **Validation is complementary, not redundant** — Even with schema enforcement, validate semantics that JSON Schema can't express (e.g., widget names must match the registry, binding syntax must be parseable). The `validate-render-spec` praxis catches what schema enforcement can't.

---

## The Integration Test Principle (T10)

**Theoria T10:** Generation output should be tested end-to-end, not just validated structurally. A generated render-spec should be loaded into the interpreter and rendered — the ultimate test is whether it produces a valid widget tree.

This was demonstrated in Phase 4 of the generative proof: the generated `render-spec/note-card` was loaded and verified to produce a valid widget tree via `manteia`.

---

## Cross-References

- [Generative Spiral](generative-spiral.md) — The three-level architecture
- [Generation Reference](../../reference/generation/generation.md) — Praxeis, inference contexts, validation
