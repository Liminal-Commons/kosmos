# V11 Vocabulary Migration — Chora Implementation

*Prompt for Claude Code in the chora + kosmos repository context.*

*Supersedes FRONT2-V11-MIGRATION.md and CHORA-V11-MIGRATION-PROMPT.md. Applies Doc → Test → Build → Verify methodology with clean break.*

---

## Methodology — Doc-Driven, Clean Break

This work follows **Doc → Test → Build → Verify Doc**, non-negotiably.

### The Cycle

1. **Doc (prescriptive)**: Write `docs/reference/v11-vocabulary.md` describing the *desired state* — the complete V11 vocabulary with old → new mappings, and the rule that no legacy term string literals exist in the codebase.
2. **Test (assert the doc)**: Write tests that assert entity creation uses V11 terms, that legacy terms are not recognized as entity types, and that database queries use the new vocabulary. Tests should fail before implementation.
3. **Build (satisfy the tests)**: Implement until tests pass.
4. **Verify doc (confirm truth)**: After implementation, re-read the reference doc. Update deviations so the doc ends as truth.

### Clean Break — No Legacy Term Recognition

Phase 1 (genesis YAML + docs) is complete. All definition files use V11 vocabulary. The clean break for Phase 2:

- **Zero legacy string literals in runtime code.** The Rust interpreter, TypeScript UI, and database contain no legacy term string literals. No backward-compatibility aliases, no "if persona or prosopon" checks, no migration shims that recognize both. The old terms simply don't exist.
- **No reversible migration.** The database migration is forward-only. There is no DOWN migration. We don't maintain the ability to roll back to legacy terms — that would be backward compatibility by another name.
- **No serde aliases.** No `#[serde(alias = "persona")]` on Rust structs. No dual-key JSON parsing. The wire format uses V11 terms exclusively.

### Exceptions (preserved, not migrated)

- `expression` in expression evaluator code (`expr.rs`, `eval_string`, AST) — programming concept, NOT discourse
- `persona/victor` in cryptographically signed content (KOSMOGONIA) — immutable
- `circle` in CSS icon class names (`circle-check`, `circle-x`, `alert-circle`) — geometric, not ontological
- `"full-circle"` as English idiom

### What "Reference Doc" Means

Reference docs in this project are *prescriptive* (target state), not descriptive (current state). When code doesn't match a reference doc, the code has a gap — not the doc (unless the design changed). See CONTRIBUTING.md for the full methodology.

---

## Context

### V11 Vocabulary Changes

| Legacy Term | V11 Term | Greek | What It Is |
|-------------|----------|-------|---------|
| `persona` | `prosopon` | πρόσωπον | Identity that persists across time |
| `animus` | `parousia` | παρουσία | Embodied presence in an oikos |
| `circle` | `oikos` | οἶκος | Social dwelling where prosopa gather |
| `oikos` (package) | `topos` | τόπος | Capability domain where praxeis dwell |
| `expression` (discourse) | `phasis` | φάσις | Intentional contribution with provenance |

### Bond Type Changes

| Legacy Bond | V11 Bond |
|-------------|----------|
| `expressed-in` | `phasis-in` |
| `circles` (membership) | `oikos` (membership) |
| Any bond referencing "circle" | Equivalent with "oikos" |

### Scope Variable Bindings

| Old | New | Set In |
|-----|-----|--------|
| `$_persona` | `$_prosopon` | `interpreter/mod.rs` → scope |
| `$_animus` | `$_parousia` | `interpreter/mod.rs` → scope |
| `$_circle` | `$_oikos` | `interpreter/mod.rs` → scope |

### Plurals and Grammar

| Singular | Plural |
|----------|--------|
| prosopon | prosopa |
| topos | topoi |
| oikos | oikoi |
| phasis | phaseis |

- "an oikos" (not "a oikos" — vowel sound)
- "a topos" (consonant sound)

### Phase 1 Status (Complete)

- All 24 topos YAML files: 0 legacy terms
- All klimax, per-topos DESIGN.md/REFERENCE.md: clean
- All diataxis docs: clean
- Root docs (README, CONTRIBUTING, CLAUDE.md, KOSMOGONIA): clean
- Only immutable: `persona/victor` in KOSMOGONIA signed block

---

## The oikos ↔ topos Challenge

This is the trickiest part. In chora's current code:
- `oikos` means **software package/module** → must become `topos`
- `circle` means **social dwelling** → must become `oikos`

After migration, `oikos` means what it means in Greek — the household, where people dwell. The package concept gets the new name `topos`.

**Disambiguation guide:**

| Current Code Pattern | What It Means | Migration Target |
|---------------------|---------------|-----------------|
| `oikos_name` in manifest | Package name | `topos_name` |
| `oikos.rs` (module) | Package logic | `topos.rs` |
| `{oikos}_{praxis_name}` MCP tools | Package-scoped tool | `{topos}_{praxis_name}` |
| `oikos_id` in `OikosConfig` | Package identity | `topos_id` |
| `circle_id` in dwelling context | Social dwelling | `oikos_id` |
| `circle_name` in session | Dwelling name | `oikos_name` |
| `get_circle_notifications()` | Dwelling notifications | `get_oikos_notifications()` |

**Rule:** If the current code says `oikos` and means "package/domain", change to `topos`. If it says `circle` and means "dwelling/group", change to `oikos`.

---

## Scope

### In Scope (chora repo)

| Directory | What | Legacy Terms |
|-----------|------|-------------|
| `crates/kosmos/src/` | Rust interpreter core | ~150 refs |
| `crates/kosmos-mcp/src/` | MCP + REST server | ~370 refs |
| `crates/soma-client/src/` | Rust client library | ~15 refs |
| `packages/soma-client-ts/src/` | TypeScript client | ~15 refs |
| `app/src/` | Frontend stores, components | ~50 refs |
| `app/src-tauri/src/` | Tauri bridge | ~15 refs |

### In Scope (kosmos repo, runtime content)

| Directory | What | Note |
|-----------|------|------|
| `oikoi/` | Runtime praxis definitions | Use `$_persona`, `expression/genesis-root`; migrate WITH chora since scope vars change simultaneously |
| `phoreta/` | Generated federation bundle | Regenerate after migration (don't hand-edit) |

### Already Migrated (no action needed)

| Directory | What | Status |
|-----------|------|--------|
| `genesis/` | Constitutional definitions (symlinked) | V11 complete — 0 legacy terms |
| `docs/` | Diataxis documentation | V11 complete |

---

## Implementation Order

### Step 1: Doc (prescriptive spec)

**Write `docs/reference/v11-vocabulary.md`** — the complete specification:
- Complete mapping table (old → new for entities, bonds, scope variables, and UI terms)
- Rule: zero legacy string literals in runtime code
- Exceptions: `expression` in expression evaluator, `persona/victor` in signed content, `circle` in CSS icons
- Grammar note: "an oikos" (vowel start), not "a oikos"
- Database migration format (forward-only, no DOWN migration)
- The oikos ↔ topos disambiguation rule
- UI vocabulary (labels, CSS classes, component names)
- MCP tool naming convention

### Step 2: Test (assert the doc)

**Write tests BEFORE implementation** in `crates/kosmos/tests/v11_vocabulary.rs`:
- Test: Creating a prosopon entity stores eidos as "prosopon" not "persona"
- Test: Creating a parousia entity stores eidos as "parousia" not "animus"
- Test: Creating a phasis entity stores eidos as "phasis" not "expression"
- Test: Creating a phasis-in bond stores desmos as "phasis-in" not "expressed-in"
- Test: Querying by eidos "prosopon" returns prosopon entities
- Test: Bootstrap loads genesis entities with V11 vocabulary (0 type mismatches)
- Test: MCP tool names use V11 vocabulary (topos-scoped, not oikos-scoped)
- Test: Scope variables `$_prosopon`, `$_parousia`, `$_oikos` are set in DwellingContext

### Step 3: Build (satisfy the tests)

**Tier 1 — Core (breaking changes):**

1. **`crates/kosmos/src/interpreter/scope.rs`** — DwellingContext struct: `persona_id` → `prosopon_id`, `circle_id` → `oikos_id`, `animus_id` → `parousia_id`
2. **`crates/kosmos/src/interpreter/mod.rs`** — Scope variable bindings: `"_persona"` → `"_prosopon"`, etc.
3. **`crates/kosmos/src/host.rs`** — Function signatures, method names, entity type guards, doc comments
4. **`crates/kosmos/src/oikos.rs`** → rename to `topos.rs` — package logic uses topos vocabulary

**Tier 2 — API contracts:**

5. **`crates/kosmos-mcp/src/lib.rs`** — SessionToken, McpSessionBridge, tool name generation (`{oikos}_{name}` → `{topos}_{name}`)
6. **`crates/kosmos-mcp/src/rest.rs`** — REST handlers, AriseResponse, ValidatedSession, challenge-response
7. **`crates/soma-client/src/types.rs`** — AriseResponse, PersonaInfo → ProsoponInfo, switch_circle → switch_oikos
8. **`packages/soma-client-ts/src/`** — TypeScript parallel of Rust structs
9. **`app/src/stores/kosmos.ts`** — Store state: personaId → prosoponId, circleId → oikosId, animusId → parousiaId

**Tier 3 — References:**

10. **`crates/kosmos/src/bootstrap.rs`** — Entity type strings in guard/filter lists
11. **`crates/kosmos/src/bin/emit_cycle.rs`** — Guard type arrays
12. **`app/src-tauri/src/main.rs`** — Tauri command bindings
13. **Test files throughout** — Entity fixtures, IDs, assertion strings
14. **`oikoi/` directory** (kosmos repo) — `$_persona` → `$_prosopon` in all praxis steps, `expression/genesis-root` → `phasis/genesis-root`

**Database:**

15. **Forward-only migration script** — eidos renames, entity ID prefix renames, bond from_id/to_id renames, desmos renames. No DOWN migration.

### Step 4: Verify

1. `cargo build && cargo test`
2. `cd app && npm run build`
3. Manual verification:
   - Create a prosopon entity → verify stored as "prosopon"
   - Create a phasis → verify stored as "phasis"
   - Verify MCP tool names are correct
   - Verify scope variables resolve correctly in praxis execution
4. Re-read `docs/reference/v11-vocabulary.md` — confirm it matches implementation
5. Audit:
   ```bash
   # Zero legacy terms in Rust (excluding expression evaluator)
   rg '"persona"' crates/ --type rust
   # Should show 0 results

   rg '"animus"' crates/ --type rust
   # Should show 0 results

   rg '"circle"' crates/ --type rust
   # Should show 0 results

   # "expression" only in expression evaluator, not as entity type
   rg '"expression"' crates/ --type rust | grep -v expr.rs | grep -v eval
   # Should show 0 results

   # Zero legacy terms in TypeScript
   rg 'persona|animus|"circle"|"expression"' app/src/ --type ts
   # Should show 0 results

   # Zero legacy scope variables
   rg '\$_(persona|animus|circle)\b' crates/ app/src/ packages/ oikoi/
   # Should show 0 results

   # Zero legacy entity ID prefixes
   rg '"(persona|animus|circle|expression)/' crates/ app/src/ packages/ --type rust --type ts
   # Should show 0 results

   # No serde aliases for legacy terms
   rg 'alias.*persona\|alias.*animus\|alias.*circle' crates/ --type rust
   # Should show 0 results

   # Bootstrap clean
   just dev 2>&1 | grep -i "mismatch\|legacy"
   # Should show 0 results
   ```

---

## Search-Replace Patterns

Apply most-specific-first to avoid double-replacement:

**Rust identifiers:**

| Pattern | Replacement |
|---------|-------------|
| `persona_id` | `prosopon_id` |
| `animus_id` | `parousia_id` |
| `circle_id` | `oikos_id` |
| `PersonaInfo` | `ProsoponInfo` |
| `get_circle_notifications` | `get_oikos_notifications` |
| `is_visible_to_persona` | `is_visible_to_prosopon` |
| `switch_circle` | `switch_oikos` |
| `circle_name` | `oikos_name` |
| `persona_name` | `prosopon_name` |

**String literals (entity types):**

| Pattern | Replacement | Context |
|---------|-------------|---------|
| `"persona"` | `"prosopon"` | As eidos type |
| `"animus"` | `"parousia"` | As eidos type |
| `"circle"` | `"oikos"` | As eidos type |
| `"expression"` | `"phasis"` | As discourse entity type (NOT programming) |

**Entity ID prefixes in strings:**

| Pattern | Replacement |
|---------|-------------|
| `"persona/` | `"prosopon/` |
| `"animus/` | `"parousia/` |
| `"circle/` | `"oikos/` |
| `"expression/` | `"phasis/` |

**Scope variable strings:**

| Pattern | Replacement |
|---------|-------------|
| `"_persona"` | `"_prosopon"` |
| `"_animus"` | `"_parousia"` |
| `"_circle"` | `"_oikos"` |

**TypeScript (camelCase):**

| Pattern | Replacement |
|---------|-------------|
| `personaId` | `prosoponId` |
| `animusId` | `parousiaId` |
| `circleId` | `oikosId` |
| `circles` (oikoi array) | `oikoi` |

### Manual Review Required

| Pattern | Why |
|---------|-----|
| `"expression"` | Programming expression vs discourse phasis |
| `"circle"` | Social dwelling vs geometric/icon |
| Existing `oikos` in code | Old meaning (package → topos) vs new meaning (dwelling) |
| `oikos.rs` filename | Rename to `topos.rs` |

---

## Database

The schema is generic (`entities` table with `id`, `eidos`, `data` columns). No DDL migration needed.

**For dev:** `just dev` (clean-db) + re-bootstrap with V11 genesis. Simplest path.

**For data preservation (forward-only):**

```sql
-- Eidos type renames
UPDATE entities SET eidos = 'prosopon' WHERE eidos = 'persona';
UPDATE entities SET eidos = 'parousia' WHERE eidos = 'animus';
UPDATE entities SET eidos = 'oikos' WHERE eidos = 'circle';
UPDATE entities SET eidos = 'phasis' WHERE eidos = 'expression';

-- Entity ID prefix renames
UPDATE entities SET id = REPLACE(id, 'persona/', 'prosopon/') WHERE id LIKE 'persona/%';
UPDATE entities SET id = REPLACE(id, 'animus/', 'parousia/') WHERE id LIKE 'animus/%';
UPDATE entities SET id = REPLACE(id, 'circle/', 'oikos/') WHERE id LIKE 'circle/%';
UPDATE entities SET id = REPLACE(id, 'expression/', 'phasis/') WHERE id LIKE 'expression/%';

-- Bond from_id and to_id renames
UPDATE bonds SET from_id = REPLACE(from_id, 'persona/', 'prosopon/') WHERE from_id LIKE 'persona/%';
UPDATE bonds SET to_id = REPLACE(to_id, 'persona/', 'prosopon/') WHERE to_id LIKE 'persona/%';
UPDATE bonds SET from_id = REPLACE(from_id, 'animus/', 'parousia/') WHERE from_id LIKE 'animus/%';
UPDATE bonds SET to_id = REPLACE(to_id, 'animus/', 'parousia/') WHERE to_id LIKE 'animus/%';
UPDATE bonds SET from_id = REPLACE(from_id, 'circle/', 'oikos/') WHERE from_id LIKE 'circle/%';
UPDATE bonds SET to_id = REPLACE(to_id, 'circle/', 'oikos/') WHERE to_id LIKE 'circle/%';
UPDATE bonds SET from_id = REPLACE(from_id, 'expression/', 'phasis/') WHERE from_id LIKE 'expression/%';
UPDATE bonds SET to_id = REPLACE(to_id, 'expression/', 'phasis/') WHERE to_id LIKE 'expression/%';

-- Bond desmos type renames
UPDATE bonds SET desmos = 'phasis-in' WHERE desmos = 'expressed-in';

-- No DOWN migration. This is forward-only.
```

---

## Chora Codebase Context

The chora repo is at `/Users/victorpiper/code/chora`. Key files:

- **`crates/kosmos/src/`** (~11,400 lines) — Core Rust interpreter. Primary search target for legacy string literals.
- **`crates/kosmos/src/interpreter/expr.rs`** (~2,134 lines) — Expression evaluator. `"expression"` here is a programming concept — DO NOT change.
- **`crates/kosmos/src/interpreter/scope.rs`** — DwellingContext struct. Source of all scope variable bindings. Start here.
- **`crates/kosmos-mcp/src/`** — MCP protocol bridge. Tool name generation and session management.
- **`app/src/`** — Solid.js frontend (TypeScript). Component names, CSS classes, display labels.
- **`app/src-tauri/src/`** — Tauri native integration. May have legacy terms in onboarding code.
- **`crates/kosmos/tests/`** — Tests may have partial migration already.

---

## Files to Touch

### Kosmos (genesis)
- No genesis changes needed — Phase 1 is complete
- `oikoi/` — Runtime praxis definitions (scope variables, entity ID references)

### Chora (implementation)
- `crates/kosmos/src/interpreter/scope.rs` — DwellingContext struct
- `crates/kosmos/src/interpreter/mod.rs` — Scope variable bindings
- `crates/kosmos/src/host.rs` — Function signatures, method names, entity type guards
- `crates/kosmos/src/oikos.rs` → `topos.rs` — Rename and update
- `crates/kosmos-mcp/src/lib.rs` — Session, tool names
- `crates/kosmos-mcp/src/rest.rs` — REST API response fields
- `crates/soma-client/src/types.rs` — Client types
- `packages/soma-client-ts/src/` — TypeScript client
- `app/src/stores/kosmos.ts` — Store state
- `app/src-tauri/src/main.rs` — Tauri bindings
- `crates/kosmos/src/bootstrap.rs` — Guard type arrays
- `crates/kosmos/src/bin/emit_cycle.rs` — Guard type arrays
- All test files — Fixtures and assertions
- Database migration script (new, forward-only)
- `crates/kosmos/tests/v11_vocabulary.rs` (new) — Vocabulary tests

### Docs (written FIRST, verified LAST)
- `docs/reference/v11-vocabulary.md` — V11 vocabulary specification

---

## Coordination

### Genesis Boundary

Genesis definitions already use V11 vocabulary. When chora bootstraps:
- Eidos definitions say `prosopon`, `parousia`, `oikos`, `phasis`, `topos`
- Praxis definitions use `$_prosopon`, `$_oikos`, `$_parousia`
- Entity IDs use `prosopon/*`, `parousia/*`, `oikos/*`, `phasis/*`

The interpreter must match. Until this migration is done, bootstrap will fail on any praxis that references the new scope variables.

### API Boundary

REST API response fields change (e.g., `persona_id` → `prosopon_id`). Any external consumers of the REST API need to be updated simultaneously. Currently the only consumer is Thyra (the Tauri app), so this is all in-repo.

---

## Verification

```bash
# Build
cargo build 2>&1

# Tests
cargo test 2>&1

# TypeScript
cd app && npm run build 2>&1

# Audit: legacy identifiers (should be zero)
rg '\b(persona_id|animus_id|circle_id)\b' crates/ app/src/ packages/ --type rust --type ts
rg '"(persona|animus|circle)"' crates/ --type rust
rg '\$_(persona|animus|circle)\b' crates/ app/src/ packages/

# Audit: legacy entity IDs (should be zero)
rg '"(persona|animus|circle|expression)/' crates/ app/src/ packages/ --type rust --type ts

# Audit: no serde aliases
rg 'alias.*persona\|alias.*animus\|alias.*circle' crates/ --type rust

# Audit: oikoi praxeis (should be zero)
rg '\$_persona|\$_animus|\$_circle' oikoi/
rg 'expression/genesis-root' oikoi/
```

**Expected survivors** (correct, do NOT change):
- `eval_expression`, `ExpressionEvaluator`, `expression` as programming concept
- `"full-circle"` idiom
- `persona/victor` in signed/immutable content
- `circle` in CSS class names (`circle-check`, `circle-x`)

---

## What This Enables

When V11 migration is complete:
- **The constitution and the code speak the same language.** Genesis defines `prosopon`; the interpreter creates `prosopon`. No translation layer, no mapping table, no ambiguity.
- **The oikos ↔ topos split is clean.** `oikos` means dwelling, `topos` means capability domain. No more "which oikos do you mean?"
- **New developers read one vocabulary.** No legacy terms to explain, no "this used to be called..." footnotes.
- **Zero migration shims to maintain.** No `#[serde(alias)]`, no dual-path parsing, no backward compatibility code. The codebase is smaller and simpler.
