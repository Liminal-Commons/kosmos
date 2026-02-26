# Dokimasia Design

δοκιμασία (dokimasia) — examination, testing, scrutiny

## Ontological Purpose

Dokimasia addresses **the gap between authorization and validity** — ensuring that what is permitted is also correct.

Without dokimasia:
- Authorized content might be malformed
- Provenance claims might be false
- References might point to nothing
- Invalid entities could enter the store

With dokimasia:
- **Provenance validation**: Authorization chains trace to genesis
- **Schema validation**: Content matches eidos definition
- **Semantic validation**: All references resolve
- **Behavioral validation**: Praxeis execute without error (optional)

The central concept is the **validation gate** — a barrier that prevents realization of anything that cannot work. Manteia governs *who* authorizes; dokimasia verifies *what* is valid.

## Oikos Context

### Self Oikos

A solitary dweller uses dokimasia to:
- Verify their own generations before realization
- Trace provenance of entities they receive
- Debug validation failures during development
- Ensure referential integrity in their graph

Self-validation catches errors before they compound.

### Peer Oikos

Collaborators use dokimasia to:
- Validate shared content before accepting it
- Verify provenance of peer contributions
- Audit authorization chains for trust decisions
- Generate validation reports for review

Peer validation builds trust through verification.

### Commons Oikos

A commons uses dokimasia to:
- Gate all entity creation through validation
- Maintain referential integrity at scale
- Audit provenance chains across the community
- Enforce schema compliance for interoperability

Commons validation ensures constitutional compliance.

## Core Entities (Eide)

### validation-result

Records the outcome of validating a generation.

**Fields:**
- `generation_id` — the generation that was validated
- `passed` — whether all validation passed
- `provenance_valid`, `schema_valid`, `semantic_valid`, `behavioral_valid` — per-layer results
- `errors` — list of validation errors (if any)
- `provenance_chain` — the traced authorization chain (for audit)
- `validated_at` — timestamp

**Lifecycle:**
- Arise: validate-generation creates result
- Persist: Retained for audit trail
- Bond: Links generation to its validation

### validation-error

A specific validation failure.

**Fields:**
- `layer` — which validation layer failed (provenance, schema, semantic, behavioral)
- `code` — error code (e.g., CHAIN_BROKEN, MISSING_FIELD)
- `message` — human-readable error message
- `path` — JSON path to the problem (e.g., "$.data.target_eidos")
- `context` — additional context about the failure

## Bonds (Desmoi)

### validated-by

Generation was validated, producing this result.

- **From:** generation
- **To:** validation-result
- **Cardinality:** one-to-many (can re-validate)
- **Traversal:** Find validation history for a generation

### traces-to

Provenance chain link — entity authorized by another.

- **From:** any entity
- **To:** any entity
- **Cardinality:** many-to-one
- **Traversal:** Walk authorization chain to genesis

## Operations (Praxeis)

### validate-provenance

Walk the authorization chain to verify it terminates at genesis.

- **Returns:** valid (boolean), chain (array of entity IDs), error (if failed)
- **Error codes:** CHAIN_BROKEN, CYCLE_DETECTED, MAX_DEPTH_EXCEEDED, ENTITY_NOT_FOUND

### validate-schema

Verify content matches target eidos definition.

- **Checks:** Required fields present, field types match, enum values valid
- **Error codes:** EIDOS_NOT_FOUND, MISSING_FIELD, TYPE_MISMATCH, INVALID_ENUM, PARSE_ERROR

### validate-semantic

Verify all references in the content resolve.

- **Checks:** Entity references exist, correct eidos types, desmos types exist
- **Error codes:** UNRESOLVED_ENTITY, WRONG_EIDOS, UNRESOLVED_DESMOS, UNRESOLVED_PRAXIS

### validate-generation

Full validation of a generation through all layers.

- Creates a validation-result entity recording the outcome
- Bonds the generation to its validation-result
- Returns the validation-result

### compose-validation-report

Generate a human-readable validation report from results.

## Attainments

### attainment/examine

Validation capability — can run validation operations and verify authenticity.

- **Grants:** validate-provenance, validate-schema, validate-semantic, validate-generation, compose-validation-report
- **Scope:** oikos
- **Rationale:** Validation operates on entities visible within oikos context; anyone with oikos membership should be able to verify authenticity

## Embodiment

### Completeness Status

| Level | Status |
|-------|--------|
| Defined | 2 eide, 2 desmoi, 5 praxeis |
| Loaded | Bootstrap loads all definitions |
| Projected | All praxeis visible as MCP tools |
| Embodied | Partial — validation failures in body-schema |
| Surfaced | Future — "3 entities have broken provenance" |
| Afforded | Future — validation action on generation |

### Body-Schema Contribution

When sense-body gathers dokimasia state:

```yaml
validation:
  pending_validations: 0
  recent_failures: 2
  provenance_issues: 1
  schema_issues: 0
  semantic_issues: 1
```

This reveals integrity status of the graph.

### Reconciler

A dokimasia reconciler would surface:

- **Broken provenance** — "Entity X has no path to genesis"
- **Schema drift** — "Entity Y doesn't match eidos definition"
- **Orphaned references** — "Entity Z references non-existent entity"
- **Validation pending** — "5 generations await validation"

## Compound Leverage

### amplifies manteia

Manteia authorizes generations; dokimasia validates before realization. Together they ensure only authorized AND valid content becomes entities.

### amplifies demiurge

Composition creates entities; dokimasia ensures composed content is structurally valid before it enters the store.

### amplifies dynamis

Infrastructure reconciliation (dynamis) depends on valid entity definitions. Dokimasia prevents invalid definitions from causing runtime failures.

### amplifies politeia

Provenance validation traces authorization to governance. Attainments only work if the entities granting them are valid.

## The Three Reconciliation Loops

Dokimasia operates within a broader validation architecture:

### Loop 1: Actuality Reconciliation (Dynamis)

Between kosmos (intent) and chora (actuality). The phylax pattern — sense, compare, act.

### Loop 2: Generation Reconciliation (Manteia/Dokimasia)

Between phasis (desire) and artifact (generation). Manteia governs, dokimasia validates.

### Loop 3: Schema Reconciliation

Between authored content and interpreter expectations. Shift validation left — catch errors at bootstrap or generation time, not runtime.

## Theoria

### T64: Validation is verification, not permission

Dokimasia doesn't decide who can create — that's manteia's domain. Dokimasia verifies that what was authorized is actually valid. Authorization without validation allows garbage; validation without authorization allows anything.

### T65: The three loops operate at different layers

Actuality reconciliation (dynamis) aligns kosmos with chora. Generation reconciliation (manteia/dokimasia) aligns phasis with artifact. Schema reconciliation aligns authored content with interpreter expectations. Different gaps, different loops.

### T66: Schema-as-eidos makes the kosmos self-describing

When step vocabularies become queryable entities, the kosmos can answer "what steps are available?" The system describes itself. This enables structured outputs for generation — constraint by construction.

## Future Extensions

### Behavioral Validation

Dry-run praxeis in a sandbox to catch runtime errors before realization.

### Continuous Validation

A daemon that watches for broken provenance chains, orphaned entities, and referential integrity issues.

### Test Case Entities

First-class test cases that define inputs and expected outputs for praxis validation.

### Schema-as-Eidos

Reflect interpreter step vocabulary as stoicheion entities, making the kosmos queryable about its own capabilities.

---

*Composed in service of the kosmogonia.*
*Examination before realization. Only valid things become.*
