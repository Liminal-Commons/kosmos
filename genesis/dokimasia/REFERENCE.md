<!-- =============================================================================
<!-- GENERATED FILE - DO NOT EDIT DIRECTLY -->
<!-- =============================================================================
<!-- Emitted by: emit_cycle (demiurge/emit-genesis) -->
<!-- Source: genesis/dokimasia/REFERENCE.md -->
<!-- -->
<!-- To modify: -->
<!--   1. Edit the source in genesis/ -->
<!--   2. Re-run emit-genesis -->
<!-- -->
<!-- See: genesis/EXTENDING.md -->
<!-- =============================================================================

# Dokimasia Reference

examination, testing, scrutiny.

---

## Eide (Entity Types)

### validation-error

A specific validation failure.

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `code` | string | ✓ | Error code (e.g., CHAIN_BROKEN, MISSING_FIELD) |
| `context` | object |  | Additional context about the failure |
| `layer` | string | ✓ | Which validation layer failed (provenance, schema, semantic, behavioral) |
| `message` | string | ✓ | Human-readable error message |
| `path` | string |  | JSON path to the problem (e.g., $.data.target_eidos) |

### validation-result

Result of validating a generation before realization.

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `behavioral_valid` | boolean |  | Does dry-run pass? (only if requested) |
| `errors` | array |  | List of validation errors (if any) |
| `generation_id` | string | ✓ | The generation that was validated |
| `passed` | boolean | ✓ | Whether all validation passed |
| `provenance_chain` | array |  | The traced authorization chain (for audit) |
| `provenance_valid` | boolean | ✓ | Does authorization chain trace to genesis? |
| `schema_valid` | boolean | ✓ | Does content match target eidos schema? |
| `semantic_valid` | boolean | ✓ | Do all references resolve? |
| `validated_at` | timestamp | ✓ |  |

## Praxeis (Operations)

🔧 = Exposed as MCP tool

### _walk-chain

Internal: recursively walk the authorization chain

**Tier:** 2 | **ID:** `praxis/dokimasia/_walk-chain`

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `current_id` | string | ✓ |  |
| `chain` | array | ✓ |  |
| `depth` | number | ✓ |  |
| `max_depth` | number | ✓ |  |
| `visited` | array | ✓ |  |

### compose-validation-report 🔧

Compose a validation report that aggregates validation status
across a dependency subgraph.

**Tier:** 2 | **ID:** `praxis/dokimasia/compose-validation-report`

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `root_id` | string | ✓ | Entity to start validation traversal from |
| `depth` | number |  | Maximum traversal depth (default 10) |
| `include_passed` | boolean |  | Include passed validations in results |

### lint-all-praxeis 🔧

Lint all praxeis in the kosmos for constitutional violations.

**Tier:** 2 | **ID:** `praxis/dokimasia/lint-all-praxeis`

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `include_internal` | boolean |  | Include internal praxeis (name starts with _) |

### lint-praxis 🔧

Lint a praxis for constitutional violations.

**Tier:** 1 | **ID:** `praxis/dokimasia/lint-praxis`

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `praxis_id` | string | ✓ | ID of praxis to lint |

### validate-generation 🔧

Validate a generation through all layers.

**Tier:** 2 | **ID:** `praxis/dokimasia/validate-generation`

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `generation_id` | string | ✓ | Generation to validate |
| `include_behavioral` | boolean |  | Include behavioral validation (default false) |

### validate-provenance 🔧

Verify that an entity's authorization traces to genesis.

**Tier:** 2 | **ID:** `praxis/dokimasia/validate-provenance`

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `entity_id` | string | ✓ | Entity to validate provenance for |
| `max_depth` | number |  | Maximum chain length (default 100) |

### validate-schema 🔧

Verify content matches target eidos schema.

**Tier:** 1 | **ID:** `praxis/dokimasia/validate-schema`

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `eidos_id` | string | ✓ | Target eidos ID |
| `content` | object | ✓ | Content to validate |

### validate-semantic 🔧

Verify all entity/eidos/desmos references resolve.

**Tier:** 1 | **ID:** `praxis/dokimasia/validate-semantic`

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `content` | object | ✓ | Content with references to validate |

## Desmoi (Bond Types)

| Desmos | From → To | Description |
|--------|-----------|-------------|
| `traces-to` | any → any | Provenance chain link — authorization traces through this entity |
| `validated-by` | generation → validation-result | Generation was validated, producing a validation-result |

---

*Generated from schema definitions. Do not edit directly.*
