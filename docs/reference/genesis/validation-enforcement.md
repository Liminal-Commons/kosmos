# Validation Enforcement

*Prescriptive reference — describes the target state for schema conformance and integrity sensing.*

---

## Overview

Schema conformance is constitutive of the `typed-by` bond. An entity whose data does not conform to the eidos it is typed-by has a bond that does not hold. Validation is not external checking — it is the typed-by bond asserting its own meaning.

Two distinct concerns:

- **Structural enforcement** — the composition path and mutation operations prevent non-conforming entities from arising or persisting. This is inherent to the mechanism, not a separate layer.
- **Integrity sensing** — the dokimasia topos senses drift in existing entities (provenance chains, schema conformance, referential integrity) and produces validation-result entities through the standard composition path. This is a reconciliation concern.

The gate is the mechanism. The sense is the topos.

---

## Structural Enforcement

### Composition Path (Arise-Time)

When `compose_entity()` creates a `typed-by` bond, the entity's data must conform to the target eidos. The composition path enforces this:

1. **Resolve eidos**: Look up `eidos/{target_eidos}` entity in the store
2. **No eidos found** → composition fails with `EIDOS_NOT_FOUND`
3. **No fields defined** → valid (permissive for simple eide)
4. **Check required fields**: For each field with `required: true`, verify the field exists in composed data → `MISSING_FIELD`
5. **Check field types**: For each field present that has a declared type, verify the value matches → `TYPE_MISMATCH`
6. **Check enum values**: For fields with `enum` constraint, verify value is in the allowed list → `INVALID_ENUM`

Non-conforming data is rejected. There is no warn mode. Composition either produces a valid entity or fails.

### Update Path (Mutation-Time)

`update_entity()` maintains the typed-by contract. The entity already has a typed-by bond; the update must not break it:

1. Resolve the entity's eidos from its existing `eidos` field
2. Validate the new data against the eidos field definitions
3. Non-conforming updates are rejected

### Bond Creation (Bind-Time)

`create_bond()` enforces desmos constraints as part of its own semantics:

1. **Desmos exists**: Look up `desmos/{name}` entity
2. **From-eidos constraint**: If desmos declares `from_eidos` (not "any"), verify source entity's eidos matches → `WRONG_EIDOS`
3. **To-eidos constraint**: If desmos declares `to_eidos` (not "any"), verify target entity's eidos matches → `WRONG_EIDOS`

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

### Error Codes (Structural)

| Code | When |
|------|------|
| `EIDOS_NOT_FOUND` | Entity's eidos has no definition in the store |
| `MISSING_FIELD` | Required field absent from entity data |
| `TYPE_MISMATCH` | Field value type doesn't match declaration |
| `INVALID_ENUM` | Field value not in allowed enum values |
| `WRONG_EIDOS` | Bond endpoint has wrong eidos for desmos constraint |

---

## Bootstrap Behavior

Self-grounding applies to validation (Axiom IV). The type system cannot validate itself before it exists. During bootstrap, the grammar is being constituted — constitutional eide carry reduced validation just as they carry reduced provenance.

The `is_bootstrapping()` flag handles this. During bootstrap, schema conformance checks are skipped — the same mechanism that handles reduced provenance. No hardcoded list of constitutional eide is needed.

The germination stages are ordered to ensure eidos definitions exist before entities of those types are created:
- **Stage 0 (Prime)**: `eidos/eidos` — self-grounding, validation not yet possible
- **Stage 1 (Archai)**: Core eide — grammar being constituted
- **Stages 2+**: Full schema conformance as eidos definitions now exist

---

## Integrity Sensing (Dokimasia Topos)

The dokimasia topos is an **integrity reconciler** — it senses the state of the graph and reports drift. This is the reconciler pattern (sense/compare/act) applied to graph integrity.

### Operations

| Praxis | What It Senses |
|--------|---------------|
| `validate-provenance` | Authorization chains trace to genesis |
| `validate-schema` | Entity data conforms to eidos fields |
| `validate-semantic` | All entity/eidos/desmos references resolve |
| `validate-generation` | Full multi-layer validation, produces validation-result |
| `compose-validation-report` | Aggregate integrity status across dependency subgraph |

### Daemon

`daemon/sense-graph-integrity` periodically senses validation-result entities for integrity drift (60s interval).

### Validation-Result Entities

`validation-result` entities are products of the audit praxeis — composed through the standard composition path with proper provenance bonds and `exists-in` placement. They are NOT side effects of gate enforcement.

---

## Relationship to Other Layers

| Layer | When | What | Where |
|-------|------|------|-------|
| **Manifest validation** | Bootstrap (static) | Topos structure, dependencies | bootstrap.rs |
| **Schema conformance** | Arise/update/bind (structural) | Typed-by contract enforcement | composition.rs, host.rs |
| **Integrity sensing** | Periodic/on-demand (reactive) | Drift detection, provenance walking | dokimasia topos praxeis |

---

## Current State

**Structural enforcement**: Schema conformance is inline in `host.rs` — `validate_entity_schema()` runs inside `arise_entity_with_version()` and `update_entity()`, `validate_bond_constraints()` runs inside `create_bond()`. All three are gated by `is_bootstrapping()`. The `dokimasia.rs` wrapper module has been dissolved. No enforcement modes, no env vars — always reject non-conforming data.

**Post-bootstrap diagnostics**: `post_bootstrap_diagnostics()` runs after `exit_bootstrap_mode()`, batch-validates all entities, logs warnings. Warn-only — does not block bootstrap completion.

**Integrity sensing**: The dokimasia topos defines praxeis, daemon, reflex, and mode in genesis. These are not yet embodied as executable operations.

---

*Traces to: Axiom I (Composition), Axiom IV (Self-Grounding), Axiom V (Adequacy), theoria/conformance-constitutive-of-typed-by, theoria/composition-gates-topos-senses, theoria/self-grounding-applies-to-validation*
*Updated: 2026-02-25 — dokimasia.rs dissolved, conformance inline in host.rs*
