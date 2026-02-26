# Dokimasia Design

δοκιμασία (dokimasia) — examination, testing, scrutiny

## Ontological Purpose

Dokimasia is the **integrity reconciler** — it senses the state of the graph and surfaces drift. Broken provenance, schema non-conformance, orphaned references, referential gaps — these are the phenomena dokimasia detects.

Dokimasia does NOT gate entity creation. Schema conformance is constitutive of the `typed-by` bond — it is enforced by the composition path itself (see [validation-enforcement.md](../../docs/reference/genesis/validation-enforcement.md)). The composition path gates. The topos senses.

### What dokimasia senses

- **Provenance integrity**: Authorization chains trace to genesis (or to a self-grounding boundary)
- **Schema conformance**: Entity data matches eidos field definitions
- **Semantic integrity**: All entity/eidos/desmos references resolve
- **Behavioral integrity**: Praxeis execute without error (future)

### The reconciler pattern

Dokimasia follows the standard reconciler pattern — sense/compare/act — applied to graph integrity:

1. **Sense**: Examine entities, bonds, and provenance chains
2. **Compare**: Check against eidos definitions, desmos constraints, genesis root reachability
3. **Act**: Produce validation-result entities that surface issues

## Oikos Context

### Self Oikos

A solitary dweller uses dokimasia to:
- Trace provenance of entities they receive via federation
- Sense referential integrity in their graph
- Debug composition or generation failures after the fact
- Verify authorization chains for entities of uncertain origin

### Peer Oikos

Collaborators use dokimasia to:
- Verify provenance of peer contributions
- Audit authorization chains for trust decisions
- Generate validation reports for review
- Sense schema drift across shared entities

### Commons Oikos

A commons uses dokimasia to:
- Maintain referential integrity at scale
- Audit provenance chains across the community
- Surface schema non-conformance for curation
- Monitor integrity health via daemon

## Core Entities (Eide)

### validation-result

Records the outcome of examining an entity or subgraph.

**Fields:**
- `generation_id` — the entity that was examined
- `passed` — whether all checks passed
- `provenance_valid`, `schema_valid`, `semantic_valid`, `behavioral_valid` — per-layer results
- `errors` — list of validation errors (if any)
- `provenance_chain` — the traced authorization chain (for audit)
- `validated_at` — timestamp

**Lifecycle:**
- Arise: `validate-generation` praxis composes a validation-result through the standard composition path
- Persist: Retained for audit trail
- Bond: `validated-by` links the examined entity to its validation-result

### validation-error

A specific validation finding.

**Fields:**
- `layer` — which layer (provenance, schema, semantic, behavioral)
- `code` — error code (e.g., CHAIN_BROKEN, MISSING_FIELD)
- `message` — human-readable message
- `path` — JSON path to the problem (e.g., "$.data.target_eidos")
- `context` — additional context

## Bonds (Desmoi)

### validated-by

Entity was examined, producing this result.

- **From:** any entity
- **To:** validation-result
- **Cardinality:** one-to-many (can re-examine)
- **Traversal:** Find examination history for an entity

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

Examine whether entity data conforms to its eidos field definitions.

- **Checks:** Required fields present, field types match, enum values valid
- **Error codes:** EIDOS_NOT_FOUND, MISSING_FIELD, TYPE_MISMATCH, INVALID_ENUM

### validate-semantic

Examine whether all references in an entity resolve.

- **Checks:** Entity references exist, correct eidos types, desmos types exist
- **Error codes:** UNRESOLVED_ENTITY, WRONG_EIDOS, UNRESOLVED_DESMOS, UNRESOLVED_PRAXIS

### validate-generation

Full multi-layer examination of an entity.

- Runs provenance, schema, and semantic checks
- Composes a validation-result entity through the standard composition path
- Bonds the entity to its validation-result via `validated-by`
- Returns the validation-result

### compose-validation-report

Aggregate integrity status across a dependency subgraph.

- Traverses `depends-on` bonds from a root entity
- Validates each entity in the subgraph
- Composes a report artifact summarizing findings

## Attainments

### attainment/examine

Validation capability — can run examination operations and verify authenticity.

- **Grants:** validate-provenance, validate-schema, validate-semantic, validate-generation, compose-validation-report
- **Scope:** oikos
- **Rationale:** Examination operates on entities visible within oikos context; anyone with oikos membership should be able to verify authenticity

## Embodiment

### Completeness Status

| Level | Status |
|-------|--------|
| Defined | 2 eide, 2 desmoi, 5+ praxeis |
| Loaded | Bootstrap loads all definitions |
| Projected | Praxeis visible as MCP tools |
| Embodied | Future — praxeis not yet wired to executable operations |
| Surfaced | Future — "3 entities have broken provenance" |
| Afforded | Future — validation action on entity |

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

The dokimasia reconciler surfaces:

- **Broken provenance** — "Entity X has no path to genesis"
- **Schema drift** — "Entity Y doesn't match eidos definition"
- **Orphaned references** — "Entity Z references non-existent entity"
- **Validation pending** — "5 entities awaiting examination"

### Daemon

`daemon/sense-graph-integrity` periodically examines entities for integrity drift. This is the parasympathetic sensing arm — continuous, ambient, not triggered by events.

### Reflex

`reflex/dokimasia/validation-drift` fires when a validation-result's expected outcome diverges from actual. This is the sympathetic arm — event-driven, responding to change.

## Compound Leverage

### amplifies manteia

Manteia generates content; dokimasia senses whether the generated content holds integrity after it enters the graph. Together they close the generation reconciliation loop.

### amplifies demiurge

Composition creates entities with typed-by bonds that carry conformance obligations. Dokimasia senses whether those obligations hold over time as the graph evolves.

### amplifies dynamis

Infrastructure reconciliation (dynamis) depends on valid entity definitions. Dokimasia senses whether definition integrity holds — bad definitions surface as validation failures before they cause runtime errors.

### amplifies politeia

Provenance validation traces authorization to governance. Dokimasia can verify that the governance bonds behind every entity actually reach genesis.

## Theoria

### T64: Validation is verification, not permission

Dokimasia doesn't decide who can create — that's governance (politeia). Dokimasia examines what exists and reports on its integrity. Authorization without integrity allows garbage; integrity without authorization allows anything.

### T65: The three loops operate at different layers

Actuality reconciliation (dynamis) aligns kosmos with chora. Generation reconciliation (manteia/dokimasia) aligns phasis with artifact. Schema reconciliation aligns authored content with interpreter expectations. Different gaps, different loops.

### T66: Schema-as-eidos makes the kosmos self-describing

When step vocabularies become queryable entities, the kosmos can answer "what steps are available?" The system describes itself. This enables structured outputs for generation — constraint by construction.

### Conformance is constitutive of typed-by

The typed-by bond carries an obligation: the entity's data must conform to the eidos it is typed-by. This is enforced by the composition path at creation and maintained through mutation. Dokimasia senses whether this obligation holds post-hoc — it does not enforce it.

### The composition path gates; the topos senses

Structural enforcement (preventing invalid entities) belongs in the composition path. Post-hoc verification (sensing drift, walking provenance) belongs in the dokimasia topos. The two serve different moments: prevention vs detection.

### Self-grounding applies to validation

The type system cannot validate itself before it exists (Axiom IV). Constitutional eide carry reduced validation just as they carry reduced provenance. The bootstrap phase handles this structurally.

## Future Extensions

### Behavioral Validation

Dry-run praxeis in a sandbox to catch runtime errors before realization.

### Test Case Entities

First-class test cases that define inputs and expected outputs for praxis validation.

### Federation Integrity

Verify integrity of entities received via federation — provenance chains that cross oikos boundaries, signatures that attest remote origin.

---

*Composed in service of the kosmogonia.*
*Examination of what exists. The composition path ensures what arises is valid. Dokimasia senses whether it stays that way.*
