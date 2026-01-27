<!-- =============================================================================
<!-- GENERATED FILE - DO NOT EDIT DIRECTLY -->
<!-- =============================================================================
<!-- Emitted by: emit_cycle (demiurge/emit-genesis) -->
<!-- Source: genesis/manteia/REFERENCE.md -->
<!-- -->
<!-- To modify: -->
<!--   1. Edit the source in genesis/ -->
<!--   2. Re-run emit-genesis -->
<!-- -->
<!-- See: genesis/EXTENDING.md -->
<!-- =============================================================================

# Manteia Reference

divination, prophecy. Governed inference.

---

## Eide (Entity Types)

### criterion-result

Result of evaluating a single criterion.

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `created_at` | timestamp | ✓ |  |
| `name` | string | ✓ | Criterion name that was evaluated |
| `reason` | string | ✓ | Explanation of why this status was determined |
| `status` | enum | ✓ | Did the content meet this criterion? |

### evaluation-criterion

A criterion for evaluating generated content quality.

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `check_prompt` | string |  | Custom prompt for checking this criterion (optional) |
| `created_at` | timestamp | ✓ |  |
| `description` | string | ✓ | What this criterion checks for |
| `name` | string | ✓ | Criterion identifier (e.g., 'compiles', 'handles_errors') |
| `weight` | enum | ✓ | How failures affect verdict: |

### governed-envelope

Result of governed generation with quality evaluation.

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `content` | any | ✓ | The generated content (JSON, text, code, etc.) |
| `created_at` | timestamp | ✓ |  |
| `criteria_results` | array | ✓ | Per-criterion evaluation results [{name, status, reason}] |
| `guidance` | object |  | Resolution guidance when verdict != TRUE. |
| `provenance` | object | ✓ | Generation provenance tracking. |
| `verdict` | enum | ✓ | Quality gate verdict |

---

*Generated from schema definitions. Do not edit directly.*
