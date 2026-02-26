# Dokimasia Enforcement — Validation with Authority

*Prompt for Claude Code in the chora + kosmos repository context.*

*Supersedes FRONT2-DOKIMASIA-ENFORCEMENT.md. Removes `off` mode, targets `strict` default, integrates with manifest validation.*

---

## Methodology — Doc-Driven, Clean Break

This work follows **Doc → Test → Build → Verify Doc**, non-negotiably.

### The Cycle

1. **Doc (prescriptive)**: Write `docs/reference/validation-enforcement.md` describing the *desired state* — schema validation at arise-time, bond validation at bind-time, enforcement modes, error codes, and provenance checking.
2. **Test (assert the doc)**: Write tests that assert invalid entities are rejected (strict) or flagged (warn), bonds validate referential integrity, and error codes from the catalog are used. Tests should fail before implementation.
3. **Build (satisfy the tests)**: Implement until tests pass.
4. **Verify doc (confirm truth)**: After implementation, re-read the reference doc. Update deviations so the doc ends as truth.

### Clean Break — No Silent Acceptance, No Escape Hatches

Currently, `arise_entity()` accepts any entity regardless of schema compliance. The clean break:

- **Validation always runs.** There is no `off` mode. There is no `KOSMOS_SKIP_VALIDATION=true`. If an entity is created, it is validated. Period.
- **Two modes, not three.** `strict` (reject on failure) and `warn` (log + create validation-result, allow creation). No `off`.
- **`strict` is the target default.** `warn` exists for the migration period — when existing genesis content or runtime praxeis create entities that don't yet conform. The documented trajectory is `warn` → `strict`. There is no trajectory back to "don't validate."
- **Error codes from the catalog.** Every validation failure uses a structured error code from the dokimasia error-catalog entities. No ad-hoc error strings.

### What "Reference Doc" Means

Reference docs in this project are *prescriptive* (target state), not descriptive (current state). When code doesn't match a reference doc, the code has a gap — not the doc (unless the design changed). See CONTRIBUTING.md for the full methodology.

---

## Dependencies — Complementary Layers

### Manifest Validation (PROMPT-MANIFEST-VALIDATION.md) — complementary, not overlapping

Manifest validation and dokimasia enforcement are two layers of the same principle:

| Layer | When | What | Catches |
|-------|------|------|---------|
| **Manifest validation** | Bootstrap (static) | Topos declarations | Missing eide, broken dependencies, orphaned praxeis, unknown dynamis |
| **Dokimasia enforcement** | Runtime (dynamic) | Entity/bond creation | Wrong field types, missing required fields, invalid enum values, referential integrity |

Manifest validation catches structural misconfiguration before any praxis executes. Dokimasia enforcement catches data-level violations during execution. Both are needed. Neither replaces the other.

If manifest validation has shipped first, some dokimasia checks become redundant at bootstrap (eidos existence is already validated). But at runtime — when praxeis create entities dynamically — dokimasia enforcement is the only guard.

### Daemon Runner (PROMPT-DAEMON-RUNNER.md) — already shipped, feeds the reactive loop

The `daemon/sense-graph-integrity` daemon periodically invokes `dokimasia/sense-validation-results` to re-validate existing entities (reactive). Drift-detection reflexes fire when `expected_outcome != outcome`. Dokimasia enforcement validates at creation time (proactive). Together they ensure:
- New entities are valid when created (dokimasia enforcement)
- Existing entities stay valid over time (daemon sensing + drift reflexes)
- When dokimasia runs in `warn` mode, validation-result entities are created — the graph-integrity daemon/reflex loop picks these up and escalates persistent issues

**Update-time validation:** The daemon runner calls `update_entity()` to set daemon status (`running`/`stopped`/`errored`). When dokimasia enforcement ships, these updates will be validated against `eidos/daemon` field definitions. The enum values match, so no breakage expected. However, this means dokimasia must consider **update-time validation** (not just arise-time):
- At minimum: validate that updated fields conform to their declared type/enum constraints
- Scope: update-time validation can be a follow-on phase after arise-time and bind-time ship. The daemon runner's status updates are safe because the values match the eidos declaration.

### Attainment Authorization (PROMPT-ATTAINMENT-AUTHORIZATION.md) — bond validation interaction

Dokimasia's bond validation (`WRONG_EIDOS` checks on `bind_desmos`) will validate the new `grants-praxis` and `requires-attainment` bonds. Any new desmoi from attainment authorization get automatic referential integrity checking.

**Note:** Daemon-invoked praxeis bypass the attainment gate entirely (no dwelling context → allow). This means dokimasia enforcement is the only validation layer for entities created by daemon-triggered praxeis. If a sensing praxis creates a malformed entity, only dokimasia catches it — attainment authorization doesn't apply.

---

## Context

### What Dokimasia Declares

Four validation layers:
1. **Provenance** — does the chain trace to genesis?
2. **Schema** — does content match eidos field definitions?
3. **Semantic** — do references resolve?
4. **Behavioral** — does a dry-run pass?

This prompt implements layers 2 and 3 as proactive enforcement. Layer 1 gets a lightweight check. Layer 4 is out of scope (future work).

### What Exists in Chora

- **`crates/kosmos/src/interpreter/schema.rs`** (421 lines) — Schema validation infrastructure. Read this first to understand what's already implemented.
- **`crates/kosmos/src/bootstrap.rs`** — `validate_typos_template()` (line 2484) shows existing validation-as-warnings pattern
- **`crates/kosmos/src/host.rs`** — `arise_entity()` (line 742+) where validation should be called, `bind_desmos()` where bond validation should be called

### What Exists in Genesis

12 error code entities in `genesis/dokimasia/entities/error-catalog.yaml`:
- **Provenance:** CHAIN_BROKEN, CYCLE_DETECTED, MAX_DEPTH_EXCEEDED, ENTITY_NOT_FOUND
- **Schema:** EIDOS_NOT_FOUND, MISSING_FIELD, TYPE_MISMATCH, INVALID_ENUM, PARSE_ERROR
- **Semantic:** UNRESOLVED_ENTITY, WRONG_EIDOS, UNRESOLVED_DESMOS, UNRESOLVED_PRAXIS

The `reconciler/graph-integrity` (dokimasia) periodically re-validates — that's reactive. This prompt adds proactive enforcement at creation time.

---

## Design

### 1. Schema Validation at Arise-Time

When `arise_entity()` is called:

1. **Resolve eidos**: Find the eidos definition for the entity's declared eidos
2. **Validate required fields**: Check all required fields are present
3. **Validate field types**: Check values match declared types (string, number, boolean, array, object, enum)
4. **Validate enum values**: If a field has `values: [a, b, c]`, check the provided value is in the list
5. **Return structured error**: With error code from the catalog

### 2. Bond Validation at Bind-Time

When `bind_desmos()` is called:

1. **Verify entity existence**: Both `from_id` and `to_id` entities exist (ENTITY_NOT_FOUND)
2. **Verify desmos exists**: The desmos type is declared (UNRESOLVED_DESMOS)
3. **Verify eidos constraints**: If desmos declares `from_eidos` or `to_eidos`, verify them (WRONG_EIDOS)

### 3. Enforcement Mode

Two modes, configured via environment variable or bootstrap config:
- **strict** — reject creation, return structured error. Target default.
- **warn** — log failure, create validation-result entity, allow creation. Migration default.

No `off` mode. Validation always runs. The mode controls only the consequence.

Configuration: `KOSMOS_ENFORCEMENT=strict` or `KOSMOS_ENFORCEMENT=warn`. Default: `warn` initially, with documented intent to flip to `strict` once genesis content fully conforms.

### 4. Validation Result Entities

On validation failure (in warn mode), create a `validation-result` entity:

```yaml
eidos: validation-result
data:
  target_id: "the entity that failed"
  layer: schema  # or provenance, semantic
  outcome: invalid
  expected_outcome: valid
  errors:
    - code: MISSING_FIELD
      field: name
      message: "Required field 'name' is missing"
  validated_at: "2026-02-09T..."
```

This feeds the graph-integrity reconciler. In `strict` mode, no validation-result is created — the creation is simply rejected.

### 5. Provenance Enforcement (Lightweight)

At arise-time, if `authorized-by` bond is declared:
- Verify the bond target exists (ENTITY_NOT_FOUND)
- Don't verify the full chain (too expensive for hot path) — the reconciler handles that

---

## Implementation Order

### Step 1: Doc (prescriptive spec)

**Write `docs/reference/validation-enforcement.md`** — the complete specification:
- Schema validation: when it runs, what it checks, how eidos fields are resolved
- Bond validation: referential integrity, desmos constraints
- Enforcement modes (strict/warn) and their behavior — no `off` mode
- Error codes and structured error format (from dokimasia error-catalog)
- Validation-result entity creation (warn mode only)
- Provenance lightweight check
- Bootstrap validation (startup pass over all loaded entities)
- Configuration mechanism (environment variable)
- Relationship to manifest validation (complementary layers)
- Trajectory: `warn` → `strict` as default

### Step 2: Test (assert the doc)

**Write tests BEFORE implementation:**
- Test: entity with missing required field → rejected (strict) / flagged (warn)
- Test: entity with wrong enum value → INVALID_ENUM error code
- Test: entity with wrong field type → TYPE_MISMATCH error code
- Test: entity with unknown eidos → EIDOS_NOT_FOUND
- Test: bond to nonexistent entity → ENTITY_NOT_FOUND
- Test: bond with wrong from_eidos → WRONG_EIDOS
- Test: bond with unknown desmos → UNRESOLVED_DESMOS
- Test: strict mode rejects creation, returns structured error
- Test: warn mode allows creation + creates validation-result entity
- Test: validation-result entity has correct error codes from catalog
- Test: bootstrap validates all existing genesis entities and reports results
- Test: there is NO `off` mode — unknown mode value defaults to `warn`

### Step 3: Build (satisfy the tests)

1. Extend `schema.rs` with eidos field validation (required, type, enum)
2. Add validation call in `arise_entity()` in `host.rs`
3. Add bond validation in `bind_desmos()` in `host.rs`
4. Add enforcement mode configuration (env var, default `warn`)
5. Create validation-result entities on failure (warn mode)
6. Wire error codes from the dokimasia error-catalog entities
7. Extend bootstrap to validate all loaded entities and report results

### Step 4: Verify

1. `cargo build && cargo test`
2. Manual verification:
   - Create entity with missing field → verify rejection/warning
   - Create bond to nonexistent entity → verify error
   - Bootstrap with existing genesis → verify 0 validation failures (or document known issues and fix them)
3. Re-read `docs/reference/validation-enforcement.md` — confirm it matches implementation
4. Audit:
   ```bash
   # Enforcement modes
   KOSMOS_ENFORCEMENT=strict cargo test
   KOSMOS_ENFORCEMENT=warn cargo test

   # No off mode
   KOSMOS_ENFORCEMENT=off cargo test  # Should default to warn, not skip validation

   # Bootstrap validation
   KOSMOS_LOG=debug just dev 2>&1 | grep '\[dokimasia\]'
   # Should show validation results for all loaded entities

   # Error codes from catalog
   rg 'MISSING_FIELD\|TYPE_MISMATCH\|INVALID_ENUM\|WRONG_EIDOS' crates/kosmos/src/
   # Should show usage of catalog codes, not ad-hoc strings
   ```

---

## Chora Codebase Context

The chora repo is at `/Users/victorpiper/code/chora`. Key files:

- **`crates/kosmos/src/interpreter/schema.rs`** (421 lines) — Existing schema validation. Read first.
- **`crates/kosmos/src/host.rs`** (~3,500 lines) — `arise_entity()` (line 742+), `bind_desmos()` — where validation hooks go
- **`crates/kosmos/src/bootstrap.rs`** (~2,500 lines) — `validate_typos_template()` (line 2484) shows validation-as-warnings pattern

---

## Files to Touch

### Kosmos (genesis)
- Error catalog already exists: `genesis/dokimasia/entities/error-catalog.yaml`
- No genesis changes needed

### Chora (implementation)
- `crates/kosmos/src/interpreter/schema.rs` — extend with eidos field validation
- `crates/kosmos/src/host.rs` — add validation calls in arise_entity/bind_desmos
- `crates/kosmos/src/bootstrap.rs` — extend startup validation pass
- `crates/kosmos/tests/validation.rs` (new) — validation tests

### Docs (written FIRST, verified LAST)
- `docs/reference/validation-enforcement.md` — validation specification

---

## Verification

```bash
# Build
cargo build 2>&1

# Tests
cargo test 2>&1

# Bootstrap validation
KOSMOS_LOG=debug just dev 2>&1 | grep '\[dokimasia\]'
# Should show validation results for all loaded entities

# Enforcement modes
KOSMOS_ENFORCEMENT=strict just dev 2>&1  # Strict: rejects invalid
KOSMOS_ENFORCEMENT=warn just dev 2>&1    # Warn: logs + creates validation-result
```

---

## What This Enables

When dokimasia enforcement is active:
- **Invalid entities are caught at creation, not at usage.** A praxis that creates an entity with missing required fields gets immediate feedback — not a silent corruption that surfaces later.
- **Bond integrity is guaranteed.** Bonds can't point to nonexistent entities or violate eidos constraints. The graph is always structurally sound.
- **The error catalog is alive.** Error codes from dokimasia entities are used in real validation failures — the catalog is operational infrastructure, not documentation.
- **The graph-integrity reconciler has less work.** Proactive enforcement reduces the reactive reconciler's load to detecting drift over time, not cleaning up creation-time errors.
- **Topos authors get immediate feedback.** When developing a topos, validation failures surface at creation time with structured error codes — not as mysterious runtime behavior.
