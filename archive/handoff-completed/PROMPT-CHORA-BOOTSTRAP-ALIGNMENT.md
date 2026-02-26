# Chora Bootstrap Alignment — Making the Parser Match the Constitution

**Status:** ACTIVE — Kosmos-side alignment complete (2026-02-09). Chora-side parser changes pending. 7 changes needed for zero-warning bootstrap.

*Kosmos genesis definitions have been aligned to chora's parser. This prompt covers the chora-side changes needed to complete bootstrap with zero warnings.*

---

## Context

The kosmos-side alignment is complete:
- 14 reflexes files refactored: standalone `- bond:` entries moved to inline `bonds:` arrays on entities
- 6 files wrapped with `entities:` top-level key
- Soma manifest `surfaces_provided` populated
- 43 praxeis fixed: field names aligned to stoicheion schemas (`entity_id:` → `id:`, `from:`/`to:` → `from_id:`/`to_id:`, etc.)
- `render`/`while` steps rewritten using existing stoicheia

This prompt addresses the **chora-side changes** needed to bootstrap cleanly against the updated genesis.

---

## Change 1: SourceBond — Support `bonds:` Array on Entities

**What changed in kosmos.** All reflex and trigger entities now carry bonds inline:

```yaml
- eidos: trigger
  id: trigger/nous/theoria-created
  data:
    name: theoria-created
    enabled: true
  bonds:                                    # NEW: inline bonds
    - desmos: matches-event
      to: entity-mutation/created
    - desmos: filters-eidos
      to: eidos/theoria

- eidos: reflex
  id: reflex/nous/theoria-created
  data:
    name: theoria-created
    description: "Auto-index theoria..."
    enabled: true
    scope: global
    response_params:                        # NEW: params for responds-with
      entity_id: "$entity.id"
  bonds:                                    # NEW: inline bonds
    - desmos: triggered-by
      to: trigger/nous/theoria-created
    - desmos: responds-with
      to: praxis/nous/index-entity
```

**What chora needs.**

### 1a. Parse `bonds:` on `SourceEntry`

In `crates/kosmos/src/bootstrap.rs`, the `SourceEntry` struct (around line 1231) currently has:
```rust
struct SourceEntry {
    eidos: String,
    id: String,
    data: Value,
    // ... no bonds field
}
```

Add:
```rust
struct SourceEntry {
    eidos: String,
    id: String,
    data: Value,
    bonds: Option<Vec<SourceBond>>,     // NEW
}
```

Where `SourceBond` already exists but only has `{desmos, to}`. During bootstrap processing (around line 1147), after creating the entity, iterate over `entry.bonds` and create bonds from the entity's id.

### 1b. Read `response_params` from Reflex Entity Data

The reflex engine (`crates/kosmos/src/reflex.rs`) currently reads response params from bond data on the `responds-with` bond. Update the `interpolate_params` function to read from the reflex entity's `data.response_params` field instead:

```rust
// In the reflex trigger handler, after finding the responds-with bond:
let params = entity.data["response_params"].clone();
// Instead of: let params = bond.data["params"].clone();
```

The `SourceBond` struct intentionally has no `data` field — all param data lives on the entity for homoiconic composition.

---

## Change 2: Trace Step — Support `resolve:` Field

**What kosmos uses.** Multiple praxeis use `resolve:` on trace steps to control which end of the bond graph to return:

```yaml
# Return entities at the "to" end (outward traversal)
- step: trace
  from_id: "$oikos_id"
  desmos: manages-zone
  resolve: "to"
  bind_to: managed_zones

# Return entities at the "from" end (inward traversal)
- step: trace
  to_id: "$zone_id"
  desmos: in-zone
  resolve: "from"
  bind_to: records
```

**Files using this pattern:**
- `genesis/dokimasia/praxeis/dokimasia.yaml` (2 occurrences)
- `genesis/soma/praxeis/soma.yaml` (1)
- `genesis/hodos/praxeis/hodos.yaml` (2)
- `genesis/thyra/praxeis/dns.yaml` (1)
- `genesis/aither/praxeis/aither.yaml` (1)

**What chora needs.** In the trace step implementation (`step_types.rs` or `interpreter.rs`), add `resolve` as an optional field:

```rust
struct TraceStep {
    from_id: Option<String>,
    to_id: Option<String>,
    desmos: String,
    resolve: Option<String>,   // "from" | "to" — which end to return
    bind_to: String,
}
```

Behavior:
- `resolve: "to"` + `from_id`: follow bonds outward, return target entities
- `resolve: "from"` + `to_id`: follow bonds inward, return source entities
- No `resolve`: return bond objects (existing behavior)

---

## Change 3: Limit Step — Add as Stoicheion

**What kosmos uses.** The `limit` step appears in 12 praxis files across the codebase:

```yaml
- step: limit
  items: "$results"
  count: 10
  bind_to: top_ten
```

**Files using this:** logos, thyra, politeia (4x), aither (2x), nous (1x — for bounded while-loop replacement).

**What chora needs.** Add `limit` as a Tier 1 stoicheion (pure data flow, no dynamis needed):

```rust
struct LimitStep {
    items: String,     // Expression resolving to array
    count: String,     // Expression resolving to number
    bind_to: String,
}
```

Implementation: `items[..min(count, items.len())]`

Also add to `KNOWN_STEP_TYPES` so the validator stops flagging it.

---

## Change 4: Filter Step — Support `where:` Alias

**What kosmos uses.** Most filter steps use `condition:` (the canonical field), but 4 occurrences in `genesis/dynamis/praxeis/dynamis.yaml` use `where:`:

```yaml
# Canonical (manteia, thyra, etc.):
- step: filter
  items: "$transitions"
  condition: "$item.intent == $intent"
  bind_to: matches

# Legacy alias (dynamis):
- step: filter
  items: "$steward_oikoi"
  where: "$item.id == $_oikos"
  bind_to: authorized
```

**What chora needs.** In the filter step parser, accept `where:` as an alias for `condition:`:

```rust
struct FilterStep {
    items: String,
    #[serde(alias = "where")]
    condition: String,
    bind_to: String,
}
```

---

## Change 5: `eval_string()` Function in Expressions

**What kosmos uses.** The `nous/invoke` praxis uses `eval_string()` inside `{{ }}` expressions to interpolate template strings at runtime:

```yaml
- step: set
  bindings:
    system_prompt: "{{ eval_string($pattern.data.system_template, { theoria: $context.theoria, recent: $context.recent, additional: $context.additional }) }}"
```

This renders an invocation-pattern's template with dynamic context, replacing the removed `render` step.

**What chora needs.** If `eval_string` is not already in the expression evaluator, add it:

```rust
// In expr.rs or evaluator.rs
fn eval_string(template: &str, context: &Value) -> String {
    // Substitute {{ variable }} patterns in template using context map
}
```

Also add `eval_string` to `KNOWN_FUNCTIONS` in `expr.rs` so the validator doesn't flag it.

---

## Change 6: Add Missing Functions to KNOWN_FUNCTIONS

**What kosmos uses.** Praxeis reference these functions in expressions. The bootstrap validator flags them as unknown.

### Must implement (standard string/array operations):

| Function | Used In | Signature | Purpose |
|----------|---------|-----------|---------|
| `map` | demiurge, dokimasia, chora-dev, manteia | `map(items, transform)` | Transform array items |
| `replace` | dynamis, dns | `replace(str, from, to)` | String replacement |
| `split` | oikos, propylon | `split(str, delimiter)` | String to array |
| `includes` | ekdosis | `includes(arr_or_str, value)` | Contains check |
| `startsWith` | dokimasia, ekdosis, manteia | `startsWith(str, prefix)` | String prefix check |
| `parseInt` | oikos | `parseInt(str)` | String to integer |
| `min` | chora-dev | `min(a, b)` | Minimum of values |
| `take` | dns | `take(arr, n)` | First N items |
| `select` | dokimasia | `select(arr, predicate)` | Filter/select from array |

### Fix false positives (skip description scanning):

The validator scans `description:` fields for function-like patterns, producing false positives:

| False Positive | Location | Why |
|----------------|----------|-----|
| `bootstrap()` | genesis/emit-genesis description | English word in description |
| `hash()` | genesis/emit-genesis description | English word in description |
| `bake()` | demiurge/bake-topos description | English word in description |
| `surface()` | nous/index-functions description | English word in description |

**Fix:** In the function validator, skip scanning `description:` and `message:` fields. Only scan expression contexts (`condition:`, `value:`, `items:`, `bindings:`, etc.).

---

## Change 7: Map Step — Support `transform:` Field

**What kosmos uses.** The manteia praxis uses `map` with `transform:`:

```yaml
- step: map
  items: "$stoicheia"
  transform: |
    { name: $item.data.name, tier: $item.data.tier, description: $item.data.description }
  bind_to: result
```

**What chora needs.** If the map step currently uses a different field name (e.g., `to:` or `expression:`), add `transform:` as the canonical field or alias:

```rust
struct MapStep {
    items: String,
    #[serde(alias = "to", alias = "expression")]
    transform: String,
    bind_to: String,
}
```

---

## Execution Order

1. **Change 1** (SourceBond + response_params) — unlocks all 14 reflexes files loading correctly
2. **Change 3** (limit step) — unlocks 12 praxis files, including the while→for_each rewrite
3. **Change 2** (trace resolve) — unlocks 6 trace-using praxeis
4. **Change 4** (filter where alias) — unlocks 4 dynamis filter steps
5. **Change 5** (eval_string) — unlocks nous/invoke template rendering
6. **Change 6** (KNOWN_FUNCTIONS) — eliminates ~20 warnings
7. **Change 7** (map transform) — unlocks manteia/list-stoicheia

After each change, re-run bootstrap:
```bash
KOSMOS_DB=/tmp/test.db KOSMOS_SPORA=genesis/spora/spora.yaml cargo run --bin bootstrap 2>&1 | grep -c '⚠'
```

---

## Verification

**Target state:** Bootstrap completes with zero warnings.

```bash
KOSMOS_DB=/tmp/verify.db KOSMOS_SPORA=genesis/spora/spora.yaml cargo run --bin bootstrap 2>&1 | grep '⚠' | wc -l
# Target: 0
```

Also verify:
- `cargo test` still passes (412+ tests, 0 failures)
- Reflex entities load with correct bond counts via inline `bonds:` arrays
- `response_params` are accessible to reflex engine during trigger handling
- `limit`, `trace resolve`, `filter where`, `eval_string`, `map transform` all execute correctly

---

*The constitution loads. The machinery matches. Zero warnings.*
