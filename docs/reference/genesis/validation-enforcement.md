# Validation Enforcement

*Prescriptive reference — describes the target state for dokimasia enforcement.*

---

## Overview

Dokimasia enforcement validates entities and bonds at creation time. Validation always runs. The enforcement mode controls only the consequence: rejection or warning.

Two modes:
- **strict** — reject invalid entities/bonds with structured errors
- **warn** — allow creation, log warning, create `validation-result` entity

There is no `off` mode. The trajectory is `warn` (migration default) → `strict` (target default).

---

## Configuration

Environment variable: `KOSMOS_ENFORCEMENT`

| Value | Behavior |
|-------|----------|
| `strict` | Reject invalid entities/bonds |
| `warn` | Allow creation, log + create validation-result |
| *(anything else)* | Defaults to `warn` |

---

## Schema Validation (Arise-Time + Update-Time)

When `arise_entity()` or `update_entity()` is called (outside bootstrap):

1. **Resolve eidos**: Look up `eidos/{name}` entity in the store
2. **No eidos found** → `EIDOS_NOT_FOUND` error
3. **No fields defined** → valid (permissive for simple eide)
4. **Check required fields**: For each field with `required: true`, verify the field exists in entity data → `MISSING_FIELD`
5. **Check field types**: For each field present in data that has a declared type, verify the value matches → `TYPE_MISMATCH`
6. **Check enum values**: For fields with `enum` constraint, verify value is in the allowed list → `INVALID_ENUM`

### Type Checking Rules

| Declared Type | Valid JSON Value |
|---------------|-----------------|
| `string` | String |
| `integer` | Number (must be i64 or u64) |
| `number` | Number (any) |
| `boolean` | Boolean |
| `array` | Array |
| `object` | Object |
| `timestamp` | String |
| `any` | Any value |
| `enum` | String + value in enum list |

### Skipped Entities

Validation is skipped for:
- Entities with `eidos == "validation-result"` (recursion guard)
- Constitutional eide (`eidos`, `desmos`, `stoicheion`, `function`, `genesis`, `content-root`, `slot-pattern`, `attainment`, `signature`) — these define the grammar itself and are self-referential

Bootstrap entities are validated the same as runtime entities. The germination stages are ordered so that eidos definitions exist before entities of those types are created. There is no blanket bootstrap skip — the composition path validates all entities through dokimasia.

---

## Bond Validation (Bind-Time)

When `create_bond()` is called (outside bootstrap):

1. **From entity exists**: Verify `from_id` resolves to an existing entity → `ENTITY_NOT_FOUND`
2. **To entity exists**: Verify `to_id` resolves to an existing entity → `ENTITY_NOT_FOUND`
3. **Desmos exists**: Look up `desmos/{name}` entity → `UNRESOLVED_DESMOS` (warning-level, not critical)
4. **From-eidos constraint**: If desmos declares `from_eidos` (not "any"), verify from entity's eidos matches → `WRONG_EIDOS`
5. **To-eidos constraint**: If desmos declares `to_eidos` (not "any"), verify to entity's eidos matches → `WRONG_EIDOS`

---

## Error Codes

All error codes are defined as entities in `genesis/dokimasia/entities/error-catalog.yaml`.

### Schema Layer
| Code | When |
|------|------|
| `EIDOS_NOT_FOUND` | Entity's eidos has no definition in the store |
| `MISSING_FIELD` | Required field absent from entity data |
| `TYPE_MISMATCH` | Field value type doesn't match declaration |
| `INVALID_ENUM` | Field value not in allowed enum values |

### Semantic Layer
| Code | When |
|------|------|
| `ENTITY_NOT_FOUND` | Bond references nonexistent entity |
| `UNRESOLVED_DESMOS` | Bond type not defined in the store |
| `WRONG_EIDOS` | Bond endpoint has wrong eidos for desmos constraint |

### Structured Error Format

```json
{
  "code": "MISSING_FIELD",
  "layer": "schema",
  "message": "Required field 'name' is missing",
  "field": "name",
  "context": null
}
```

---

## Validation-Result Entities (Warn Mode)

In `warn` mode, when validation fails, a `validation-result` entity is created:

```yaml
eidos: validation-result
id: validation-result/{uuid}
data:
  generation_id: "{target_entity_id}"
  passed: false
  provenance_valid: true
  schema_valid: false
  semantic_valid: true
  errors:
    - code: MISSING_FIELD
      layer: schema
      message: "Required field 'name' is missing"
  validated_at: "{ISO 8601 timestamp}"
```

In `strict` mode, no validation-result is created — creation is rejected with a `ValidationFailed` error.

---

## Bootstrap Behavior

Bootstrap uses the same composition path as runtime. All entities are validated at creation time through dokimasia — there is no blanket validation skip during bootstrap.

The germination stages are ordered to ensure eidos definitions exist before entities of those types are created:
- **Stage 0 (Prime)**: `eidos/eidos` — constitutional, validation skipped (self-referential)
- **Stage 1 (Archai)**: Core eide — constitutional, validation skipped
- **Stages 2+**: All entities validated against eidos definitions that now exist

After bootstrap completes (`exit_bootstrap_mode()`), a **batch validation pass** runs to catch any cross-entity constraints that couldn't be checked during staged loading. Results are logged with `[dokimasia]` prefix.

---

## Relationship to Other Validation Layers

| Layer | When | What |
|-------|------|------|
| **Manifest validation** | Bootstrap (static) | Topos structure, dependencies |
| **Dokimasia enforcement** | Runtime (dynamic) | Entity/bond data validity |
| **Graph-integrity reconciler** | Periodic (reactive) | Drift detection over time |

Manifest validation catches structural misconfiguration before any praxis executes. Dokimasia enforcement catches data-level violations during execution. The graph-integrity reconciler detects drift over time.

---

## Trajectory

The default enforcement mode starts at `warn` to allow migration of existing content. The target is `strict` once all genesis content conforms. There is no trajectory back to unvalidated creation.
