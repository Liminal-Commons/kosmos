# Bootstrap Alignment — Making the Constitution Loadable

*65 bootstrap warnings prevent the kosmos from fully materializing. This prompt fixes them.*

---

## Context

All 412 chora tests pass. The implementation is complete: attainment authorization, crypto layer, daemon runner, dokimasia enforcement, reflex engine, reconciler engine, surface schemas, WASM stoicheia, widget homoiconicity — all shipped and tested.

But when the bootstrap runs against the live genesis definitions, 65 warnings appear. The constitution is well-authored but doesn't fully load. The issues are mechanical — format mismatches between what genesis declares and what the chora parser expects.

**This is pure alignment work.** No new features, no new concepts. Make the YAML match the parser.

---

## The Bootstrap Command

```bash
cd /path/to/chora
KOSMOS_DB=/tmp/test.db KOSMOS_SPORA=genesis/spora/spora.yaml cargo run --bin bootstrap
```

Run this after each fix category. The target is zero warnings (excluding intentional future-function references).

---

## Issue 1: Reflexes Bond Format (13 files, ~40 warnings)

**The problem.** All 13 `entities/reflexes.yaml` files mix entity entries and standalone `- bond:` entries in the same `entities:` array. The parser (`SourceFile`) only understands `- eidos:` entries.

```yaml
# Parser understands this:
- eidos: reflex
  id: reflex/nous/theoria-created
  data: { ... }

# Parser does NOT understand this:
- bond:
    from: trigger/nous/theoria-created
    desmos: matches-event
    to: entity-mutation/created
```

**The fix.** Move bonds onto the entity they originate from using the `bonds:` field. This is the established pattern — see `genesis/politeia/eide/politeia.yaml` where attainments carry `grants-praxis` bonds inline:

```yaml
- eidos: attainment
  id: attainment/govern
  data: { ... }
  bonds:
    - { desmos: grants-praxis, to: praxis/politeia/create-oikos }
    - { desmos: grants-praxis, to: praxis/politeia/create-attainment }
```

### The Refactoring Pattern

Each reflexes.yaml file has three groups of bonds to relocate:

**1. Trigger bonds** (matches-event, filters-eidos, filters-desmos) → move onto the trigger entity:

```yaml
# BEFORE (standalone bond):
- bond:
    from: trigger/nous/theoria-created
    desmos: matches-event
    to: entity-mutation/created
- bond:
    from: trigger/nous/theoria-created
    desmos: filters-eidos
    to: eidos/theoria

# AFTER (on the trigger entity):
- eidos: trigger
  id: trigger/nous/theoria-created
  data:
    name: theoria-created
    enabled: true
  bonds:
    - { desmos: matches-event, to: entity-mutation/created }
    - { desmos: filters-eidos, to: eidos/theoria }
```

**2. Reflex-to-trigger bonds** (triggered-by) → move onto the reflex entity:

```yaml
# BEFORE:
- bond:
    from: reflex/nous/theoria-created
    desmos: triggered-by
    to: trigger/nous/theoria-created

# AFTER (on the reflex entity):
- eidos: reflex
  id: reflex/nous/theoria-created
  data: { ... }
  bonds:
    - { desmos: triggered-by, to: trigger/nous/theoria-created }
```

**3. Reflex-to-praxis bonds** (responds-with, may carry params) → move onto the reflex entity:

```yaml
# BEFORE:
- bond:
    from: reflex/nous/theoria-created
    desmos: responds-with
    to: praxis/nous/index-entity
    data:
      params:
        entity_id: "$entity.id"

# AFTER (on the reflex entity):
- eidos: reflex
  id: reflex/nous/theoria-created
  data:
    name: theoria-created
    description: Auto-index theoria for semantic search.
    enabled: true
    scope: global
    response_params:
      entity_id: "$entity.id"
  bonds:
    - { desmos: triggered-by, to: trigger/nous/theoria-created }
    - { desmos: responds-with, to: praxis/nous/index-entity }
```

**The `response_params` field:** The current `SourceBond` struct has only `{desmos, to}` — no `data` field. Bond-carried params must move to the reflex entity's data. The reflex engine already reads entity data; `response_params` becomes the canonical location for response parameters.

If extending `SourceBond` to support `data` is preferred instead (chora change), the reflex entity bonds can carry params inline:
```yaml
bonds:
  - { desmos: responds-with, to: praxis/nous/index-entity, data: { params: { entity_id: "$entity.id" } } }
```
This requires adding `data: Option<Value>` to the `SourceBond` struct in `bootstrap.rs:1231` and passing it through at line 1147.

### Files to Refactor

All 13 files follow the identical pattern. Process mechanically:

1. `genesis/agora/entities/reflexes.yaml`
2. `genesis/aither/entities/reflexes.yaml`
3. `genesis/chora-dev/entities/reflexes.yaml`
4. `genesis/demiurge/entities/reflexes.yaml`
5. `genesis/dokimasia/entities/reflexes.yaml`
6. `genesis/dynamis/entities/reflexes.yaml`
7. `genesis/ergon/entities/reflexes.yaml`
8. `genesis/nous/entities/reflexes.yaml`
9. `genesis/oikos/entities/reflexes.yaml`
10. `genesis/politeia/entities/reflexes.yaml`
11. `genesis/propylon/entities/reflexes.yaml`
12. `genesis/release/entities/reflexes.yaml`
13. `genesis/thyra/entities/reflexes.yaml`

Also fix: `genesis/thyra/reflexes/clarify-on-transcript.yaml` (same issue).

### How to Do It

For each file:

1. **Read** the file. Identify triggers, reflexes, and bonds.
2. **For each trigger entity**: collect its bonds (matches-event, filters-eidos, filters-desmos, filters-from-eidos, filters-to-eidos). Add a `bonds:` array to the trigger.
3. **For each reflex entity**: collect its bonds (triggered-by, responds-with). Add a `bonds:` array to the reflex. If `responds-with` carries `data.params`, move those to `response_params:` in the reflex's `data:`.
4. **Remove** all standalone `- bond:` entries.
5. **Verify** the file is valid YAML with only `- eidos:` entries in the `entities:` array.

### Chora Alignment (if response_params approach is taken)

The reflex engine needs to read `response_params` from entity data instead of (or in addition to) bond data. Check `crates/kosmos/src/reflex.rs` — the `interpolate_params` function. Update it to look for params in:
1. Bond data (existing path, for backwards compatibility)
2. Entity data `response_params` field (new path)

---

## Issue 2: Missing `entities:` Wrapper (6 files)

**The problem.** Six files use bare YAML arrays. The parser expects a `SourceFile` struct with an `entities:` (or `eide:`, `praxeis:`, `desmoi:`) top-level key.

**The fix.** Wrap each file's array in `entities:`.

### Files

1. `genesis/ergon/typos/ergon.yaml` — add `entities:` wrapper
2. `genesis/chora-dev/render-specs/workspace-panel.yaml` — add `entities:` wrapper
3. `genesis/chora-dev/render-specs/build-target-card.yaml` — add `entities:` wrapper
4. `genesis/chora-dev/render-specs/test-run-card.yaml` — add `entities:` wrapper
5. `genesis/chora-dev/render-specs/lint-run-card.yaml` — check, may also need wrapper
6. `genesis/chora-dev/render-specs/source-crate-card.yaml` — check, may also need wrapper

### How to Do It

For each file, read it. If it starts with `- eidos:` at the top level, indent the entire array under `entities:`:

```yaml
# BEFORE:
- eidos: typos
  id: typos-def-pragma
  data: { ... }

# AFTER:
entities:
  - eidos: typos
    id: typos-def-pragma
    data: { ... }
```

---

## Issue 3: Praxis Step Validation (43 praxeis, ~70 step errors)

**The problem.** 43 praxeis produce validation warnings for two reasons:
- Steps use field names the parser doesn't recognize
- Steps use step names that don't exist in chora's Step enum

### 3a. Wrong Field Names

The most common errors, with the correct field names from the Step structs:

| Error | Likely Cause | Correct Field |
|-------|-------------|---------------|
| `find`: missing `id` (9x) | Using `entity_id:` | Use `id:` |
| `for_each`: missing `from_id` (5x) | Using wrong iteration field | Use `items:` (alias `in:`) |
| `bind`: missing `from_id` (4x) | Using `from:` or `entity_id:` | Use `from_id:`, `to_id:`, `desmos:` |
| `update`: missing `id` (3x) | Using `entity_id:` | Use `id:` |
| `switch`: missing `from_id` (3x) | Parser confusion — `switch` needs `value:` and `cases:`, not `from_id` | Check actual step schema |
| `append`: missing `to` (1x) | Missing field | Add `to:` and `value:` |

### 3b. Unknown Step Names

| Step Name | Occurrences | Resolution |
|-----------|-------------|------------|
| `render` | 2 (nous/invoke, nous/navigate) | Not a stoicheion. Rewrite using `set` with `eval_string`, or add `render` step to chora |
| `while` | 1 (nous/navigate) | Not a stoicheion. Rewrite using `for_each` with bounded iteration, or add `while` step to chora |
| `call_stoicheion` | 3 (aither praxeis) | Not a step type. Rewrite using `call` |
| `continue` | 1 (aither praxis) | Not a step type. Rewrite for_each body flow |

### How to Do It

For each praxis that produces warnings:

1. **Read** the praxis definition
2. **Check** which steps fail and why (field name vs step name)
3. **For field name errors**: Read the Step struct definition in `crates/kosmos/src/interpreter/step_types.rs` (or the generated `step_types.rs` in the build directory) to find the correct field names. Rename fields.
4. **For unknown step names**: Rewrite using existing stoicheia, or note as a chora extension needed.
5. **Run bootstrap** to verify the warning is resolved.

### Affected Praxeis by Topos

**demiurge** (12 praxeis — most affected):
- `validate-topos`, `generate-eidos`, `generate-praxis`, `generate-desmos`, `generate-topos`, `actualize-eidos`, `actualize-praxis`, `actualize-desmos`, `actualize-render-spec`, `develop-topos-from-design`, `list-stale-artifacts`, `bake-topos`

**chora-dev** (10 praxeis):
- `build`, `deploy-build`, `lint`, `mark-stale`, `reconcile-builds`, `register-for-release`, `scan-workspace`, `sense-build`, `test`

**aither** (3 praxeis):
- `apply-entity-sync`, `attempt-reconnect`, `process-sync-message`

**nous** (3 praxeis):
- `invoke`, `navigate`, `index-functions`

**dns** (4 praxeis):
- `create-zone`, `bind-zone-provider`, `create-record`, `list-records`

**Others** (1-2 each):
- `genesis/emit-genesis`, `genesis/emit-topos`, `genesis/register-content-root`
- `dokimasia/lint-all-praxeis`, `dokimasia/validate-all-topoi`
- `dynamis/register-artifact`
- `ekdosis/publish-release`, `ekdosis/list-releases`
- `manteia/list-stoicheia`
- `oikos/compare-semver`
- `propylon/validate-session-token`
- `thyra/switch-mode`

---

## Issue 4: Unknown Functions (~20 warnings)

**The problem.** The praxis validator flags functions not in chora's `KNOWN_FUNCTIONS` list (`crates/kosmos/src/interpreter/expr.rs`).

### Real Functions (need adding to interpreter or KNOWN_FUNCTIONS)

| Function | Used In | Purpose |
|----------|---------|---------|
| `map` | demiurge, dokimasia, chora-dev | Transform array items |
| `replace` | dynamis, dns | String replacement |
| `split` | oikos, propylon | String splitting |
| `startsWith`/`startswith` | dokimasia, ekdosis, manteia | String prefix check |
| `parseInt` | oikos | Parse string to integer |
| `includes` | ekdosis | Array/string contains check |
| `select` | dokimasia | Filter/select from array |
| `take` | dns | Take first N items |
| `min` | chora-dev | Minimum of values |
| `json_extract` | demiurge | Extract from JSON (may be SQLite-side) |

### False Positives (function-like patterns in description text)

| Pattern | Location | Resolution |
|---------|----------|------------|
| `bootstrap` | genesis/emit-genesis | Appears in description text |
| `hash` | genesis/emit-genesis | Appears in description text |
| `bake` | demiurge/bake-topos | Appears in description text |
| `surface` | nous/index-functions | Appears in description text |

### How to Fix

**Option A (chora-side):** Add the real functions to `KNOWN_FUNCTIONS` in `expr.rs`. If the functions are already implemented, just add the name. If not, implement them. Also improve the validator to skip scanning `description:` fields (which produce false positives).

**Option B (kosmos-side):** Rewrite praxeis to avoid functions that don't exist yet. Use existing functions like `join`, `prefix`, `suffix`, `keys`, `values`, `entries` to achieve the same results.

**Recommended:** Option A for `map`, `replace`, `split`, `includes`, `startsWith`, `min` (common string/array operations). Option B for `json_extract` and `select` (which may require more complex implementation). Fix the validator to skip descriptions.

---

## Issue 5: Surface Dependency Warnings (3 warnings)

**The problem.** `my-nodes` consumes surfaces `kosmos-instance`, `node`, `service-instance` but no topos provides them.

**The fix.** Add `surfaces_provided` to `genesis/soma/manifest.yaml`:

```yaml
surfaces_provided:
  - kosmos-instance
  - node
  - service-instance
```

These are soma eide that my-nodes renders. Soma provides them; my-nodes consumes them.

---

## Execution Order

1. **Issue 2 first** — trivial, 6 files, immediate wins
2. **Issue 5 next** — trivial, 1 file
3. **Issue 1** — mechanical but large (13 files, ~142 bond entries to relocate)
4. **Issue 3** — requires reading each praxis and understanding intent
5. **Issue 4** — decide chora-side vs kosmos-side approach

After each category, re-run bootstrap to verify warning count decreases.

---

## Verification

**Target state:** Bootstrap completes with zero warnings (or only warnings for intentionally forward-declared functions that are planned but not yet implemented).

```bash
cd /path/to/chora
KOSMOS_DB=/tmp/verify.db KOSMOS_SPORA=genesis/spora/spora.yaml cargo run --bin bootstrap 2>&1 | grep '⚠' | wc -l
# Target: 0
```

Also verify:
- `cargo test` still passes (412 tests, 0 failures)
- Reflex entities load and have correct bond counts
- All render-specs, typos, daemons, reconcilers, surfaces load without error

---

## Decision Points

**Response params location:** Entity data (`response_params:`) vs extended `SourceBond` (`data:` field). Entity data is kosmos-only. Extended SourceBond requires a small chora change but is cleaner long-term.

**Unknown step names:** Add `render`/`while`/`call_stoicheion` to chora's Step enum, or rewrite the praxeis. Adding steps is a chora commitment; rewriting keeps the step vocabulary stable.

**Function coverage:** Which functions to implement in chora vs which to work around in kosmos. Core string/array operations (`map`, `split`, `replace`, `includes`, `startsWith`) should probably be implemented — they're universally useful. Specialized functions (`json_extract`, `select`) may not be worth the complexity.

---

*The constitution is written. The machinery is running. The wiring just needs to match.*
