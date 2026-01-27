# Manteia: Governed Inference with Structured Outputs

*Schema-constrained generation for valid-by-construction outputs.*

---

## Implementation Status

| Component | Status | Location |
|-----------|--------|----------|
| `infer` stoicheion | ✓ Complete | `crates/kosmos/src/interpreter/steps.rs` |
| `infer_structured` host function | ✓ Complete | `crates/kosmos/src/host.rs` |
| JSON schema generator | ✓ Complete | `crates/kosmos/src/interpreter/schema.rs` |
| Stoicheion eide with schemas | ✓ Complete | `genesis/stoicheia-portable/eide/stoicheion.yaml` |
| Manteia praxeis | ✓ Complete | `genesis/manteia/praxeis/manteia.yaml` |

### Praxeis Implemented

| Praxis | Description |
|--------|-------------|
| `governed-inference` | Generate structured JSON matching explicit, stoicheion-derived, or eidos-derived schema |
| `generate-entity` | Generate entity data constrained to eidos field schema |
| `generate-step` | Generate a single valid praxis step |
| `generate-praxis` | Generate complete praxis with multiple steps |
| `get-stoicheion-schema` | Query schema for a step type |
| `list-stoicheia` | List available step types with descriptions |

---

## The Key Insight

**Schema-driven generation enables valid-by-construction outputs.**

Traditional LLM generation:
```
prompt → LLM → free-form text → parse → validate → maybe fail
```

Schema-constrained generation:
```
prompt + schema → LLM (tool_use) → valid JSON → done
```

The LLM cannot produce invalid structure because Anthropic's tool_use enforces the schema at generation time.

---

## Architecture

### 1. Schema Sources

Schemas can come from three sources (in precedence order):

| Source | Use Case |
|--------|----------|
| Explicit `output_schema` | Custom schemas for one-off generation |
| `stoicheion` reference | Automatic schema derivation from step definitions |
| `target_eidos` reference | Automatic schema derivation from entity field definitions |

### 2. Schema Conversion

Stoicheion eide define fields with types, aliases, and defaults:

```yaml
# genesis/stoicheia-portable/eide/stoicheion.yaml
- eidos: eidos
  id: eidos/stoicheion/filter
  data:
    name: filter
    description: "Filter items by condition"
    tier: 0
    fields:
      items:
        type: string
        required: true
        aliases: ["in"]
        description: "Variable reference to items array"
      condition:
        type: string
        required: true
        aliases: ["where"]
        description: "Condition expression"
      bind_to:
        type: string
        description: "Variable to bind result"
```

The `stoicheion_to_json_schema()` function converts this to:

```json
{
  "type": "object",
  "properties": {
    "items": { "type": "string", "description": "Variable reference..." },
    "condition": { "type": "string", "description": "Condition expression" },
    "bind_to": { "type": "string", "description": "Variable to bind..." }
  },
  "required": ["items", "condition"]
}
```

### 3. Inference Path

```
┌─────────────────────────────────────────────────────────────┐
│                    INFER STEP EXECUTION                      │
├─────────────────────────────────────────────────────────────┤
│                                                              │
│  1. Check explicit output_schema                             │
│     ↓ (if null)                                              │
│  2. Check stoicheion reference → stoicheion_to_json_schema() │
│     ↓ (if null)                                              │
│  3. Check target_eidos reference → eidos_to_json_schema()    │
│     ↓                                                        │
│  4. Call host.infer_structured(prompt, schema)               │
│     ↓                                                        │
│  5. Anthropic tool_use enforces schema                       │
│     ↓                                                        │
│  6. Return valid JSON (guaranteed)                           │
│                                                              │
└─────────────────────────────────────────────────────────────┘
```

### 4. Anthropic API Integration

The `infer_structured` function uses Anthropic's tool_use:

```json
{
  "model": "claude-opus-4-20250514",
  "messages": [{ "role": "user", "content": "..." }],
  "tools": [{
    "name": "structured_output",
    "description": "Return structured output",
    "input_schema": { /* JSON Schema */ }
  }],
  "tool_choice": { "type": "tool", "name": "structured_output" }
}
```

The `tool_choice` forces the LLM to use the tool, guaranteeing structured output.

---

## Usage Examples

### Generate Step with Auto-Schema

```yaml
# Generate a filter step
generate-step:
  stoicheion: filter
  intent: "Filter users by active status"
  context: "Available: $users array"

# Returns:
# { "items": "$users", "condition": "item.active == true" }
```

### Generate with Explicit Schema

```yaml
# Generate custom JSON
governed-inference:
  prompt: "Generate a greeting"
  output_schema:
    type: object
    properties:
      message: { type: string }
      language: { type: string, enum: ["en", "es", "fr"] }
    required: ["message", "language"]

# Returns:
# { "message": "Hello!", "language": "en" }
```

### Generate Complete Praxis

```yaml
# Generate multi-step praxis
generate-praxis:
  praxis_id: praxis/custom/filter-and-count
  description: "Filter users by active status and count them"
  input_params: "users: array of user objects"

# Returns complete praxis definition with valid steps
```

---

## Future Applications

The schema-driven pattern extends beyond stoicheion:

| Domain | Schema Source | Application |
|--------|---------------|-------------|
| **Entities** | Eidos field definitions | Generate valid entity data |
| **Bonds** | Desmos definitions | Generate valid bond configurations |
| **Definitions** | Artifact-definition schemas | Generate slot content |
| **Migrations** | Delta schemas | Generate update operations |
| **Tests** | Praxis param/return schemas | Generate test cases |
| **Docs** | Eidos → markdown templates | Generate documentation |

### Entity Generation (V4.1) ✓ Complete

Given an eidos with field definitions, generate valid entity content:

```yaml
# Generate entity data matching eidos schema
generate-entity:
  target_eidos: eidos/theoria
  prompt: "Crystallize understanding about dependency tracking"

# Returns valid theoria data:
# { "insight": "...", "domain": "...", "status": "provisional" }
```

Also available via governed-inference:

```yaml
governed-inference:
  target_eidos: eidos/theoria  # Schema from eidos fields
  prompt: "Generate a theoria about..."
```

### Praxis Invocation Generation (V4.2)

Given a praxis definition, generate valid params:

```yaml
# Future: generate params for praxis invocation
generate-invocation:
  praxis_id: praxis/nous/crystallize-theoria
  intent: "Crystallize an understanding about composition"

# Returns: { theoria_id: "...", insight: "...", domain: "..." }
```

---

## Design Decisions

1. **Schema fallback logic**
   - Explicit `output_schema` takes precedence
   - Falls back to `stoicheion`-derived schema
   - Falls back to `target_eidos`-derived schema
   - Plain text if none specified

2. **Model selection**
   - Currently hardcoded to `claude-opus-4-20250514` for quality
   - Future: model specified per praxis or via environment

3. **Schema normalization**
   - String-encoded JSON is parsed
   - Missing `type: object` wrapper is added
   - Aliases are resolved at generation time

4. **Error handling**
   - Invalid schema → error (fail fast)
   - Missing stoicheion → error (explicit is better)
   - LLM refusal → error (should not happen with proper schemas)

---

## Related Documents

| Document | Purpose |
|----------|---------|
| [ROADMAP.md](../ROADMAP.md) | V2/V3 status, V4 future applications |
| [stoicheia-portable/DESIGN.md](../stoicheia-portable/DESIGN.md) | Step vocabulary and field schemas |
| [dokimasia/DESIGN.md](../dokimasia/DESIGN.md) | Validation integration |
| [KOSMOGONIA.md](../KOSMOGONIA.md) | Constitutional requirement for governance |
| [SCHEMA-DRIVEN-VISION.md](../SCHEMA-DRIVEN-VISION.md) | Unified schema-first architecture (V5+) |

---

*χώρα receives valid forms. Schema-driven generation ensures validity at the moment of arising.*
*Traces to: expression/genesis-root*
*Created: 2026-01-23 — V3 implementation complete*
*Updated: 2026-01-23 — V4.1 entity generation complete, V5 vision established*
