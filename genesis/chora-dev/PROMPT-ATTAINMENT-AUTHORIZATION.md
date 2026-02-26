# Attainment Authorization — Graph-Based Access Control

*Prompt for Claude Code in the chora repository context.*

---

## Methodology — Doc-Driven, Clean Break

This work follows **Doc → Test → Build → Verify Doc**, non-negotiably.

### The Cycle

1. **Doc (prescriptive)**: Write `docs/reference/attainment-authorization.md` describing the *desired state* — how attainments gate praxis invocation, how authorization is graph-traversable, what the bond topology looks like. This doc is the specification.
2. **Test (assert the doc)**: Write tests that assert praxis → attainment bonds are queryable, that unauthorized invocation is rejected, that "what can this prosopon do?" is answerable via graph traversal. Tests should fail before implementation.
3. **Build (satisfy the tests)**: Implement until tests pass.
4. **Verify doc (confirm truth)**: After implementation, re-read the reference doc. Update deviations so the doc ends as truth.

### Clean Break — No Backward Compatibility

- **One authorization mechanism.** Today there are two: graph-based (stoicheia, MCP tool exposure) and YAML-step-based (praxis-internal permission checks). After this work, authorization is graph-based. Period.
- **No implicit permissions.** If a praxis has no `requires-attainment` bond, it's either public (explicitly marked) or gated by a default attainment. No "if there's no bond, allow it."
- **No field-based grants.** The `grants` array field on attainment entities is replaced by `grants-praxis` bonds. Attainment → praxis relationships are bonds, not embedded arrays. The array was a shortcut; bonds are the architecture.

### What "Reference Doc" Means

Reference docs in this project are *prescriptive* (target state), not descriptive (current state). When code doesn't match a reference doc, the code has a gap — not the doc (unless the design changed). See CONTRIBUTING.md for the full methodology.

---

## Context

Attainments are the authorization system — they determine what a prosopon can do within an oikos. The system today has strong foundations but splits authorization between two mechanisms that should be one.

**What works (graph-based):**
- `attainment/mcp-essential` entity has a `grants` field listing praxis IDs
- MCP tool projection reads `grants` to determine which praxeis to expose as tools
- Stoicheion tier-3 operations use `requires-attainment` bonds (stoicheion → attainment)
- Parousia → attainment derivation traverses: parousia → member-of → oikos → grants-attainment → attainment

**What doesn't work (logic-based):**
- Praxeis don't declare what attainment they require — no `requires-attainment` bond from praxis to attainment
- Authorization for praxis invocation is checked inside YAML steps (ad-hoc `trace` + `filter` + `assert` patterns)
- Affordances use an embedded `required_attainments` array field, not bonds
- "What can a prosopon with attainment/govern do?" requires reading praxis YAML, not traversing the graph

---

## Current State

### Attainment eidos and instances

**Eidos** (`genesis/politeia/eide/politeia.yaml:12–45`):
- Fields: `name`, `description`, `scope` (oikos/topos/global), `constraints`, `grants` (array of praxis IDs)

**Instances** (`genesis/politeia/entities/`):
- `attainment/mcp-essential` — grants 9 praxeis (nous/find, nous/surface, demiurge/compose, manteia/governed-inference, etc.)
- `attainment/govern` — grants oikos creation, attainment management
- `attainment/invite` — grants invitation praxeis
- `attainment/distribute` — grants distribution praxeis
- `attainment/hud` — grants affordance/region creation
- `attainment/admin` — global scope, bypasses checks
- `attainment/federate` — grants federation praxeis

### Desmoi

- `desmos/grants-attainment` — oikos → attainment (one-to-many)
- `desmos/has-attainment` — parousia → attainment (many-to-many)
- `desmos/granted-by` — attainment → oikos (inverse)

### Two authorization paths

| Path | Where | How | Graph-Based? |
|------|-------|-----|-------------|
| MCP tool exposure | `kosmos-mcp/src/projection.rs` | Read `attainment.grants` array → expose matching praxeis | Partially (reads entity data, not bonds) |
| Stoicheion gating | `interpreter/steps.rs:256–326` | Traverse `stoicheion --requires-attainment--> attainment` | Yes (bond traversal) |
| Praxis authorization | YAML praxis steps | Ad-hoc trace/filter/assert in each praxis | No (logic in content) |
| Affordance gating | Affordance entity data | `required_attainments` array field | No (embedded data) |

### The `grants` field problem

`attainment/mcp-essential` stores granted praxeis as an array in the entity's data:

```yaml
grants:
  - praxis/nous/find
  - praxis/nous/surface
  # ...
```

This is **data, not bonds**. You can read it, but you can't:
- Traverse from a praxis to find "what attainment grants me?"
- Query bidirectionally
- Validate that the listed praxeis actually exist

---

## Design

### Bond Topology (target state)

```
# What an oikos grants
oikos/my-dwelling --[grants-attainment]--> attainment/govern

# What a prosopon has (derived)
parousia/victor --[has-attainment]--> attainment/govern

# What an attainment permits (NEW — replaces grants field)
attainment/govern --[grants-praxis]--> praxis/politeia/create-oikos
attainment/govern --[grants-praxis]--> praxis/politeia/grant-attainment

# What a praxis requires (NEW — replaces ad-hoc YAML checks)
praxis/politeia/create-oikos --[requires-attainment]--> attainment/govern
```

### New Desmos

```yaml
# genesis/politeia/desmoi/attainment.yaml (additions)
- eidos: desmos
  id: desmos/grants-praxis
  data:
    name: grants-praxis
    description: "Attainment grants permission to invoke this praxis"
    from_eidos: attainment
    to_eidos: praxis
    cardinality: many-to-many

- eidos: desmos
  id: desmos/requires-attainment
  data:
    name: requires-attainment
    description: "Praxis requires this attainment for invocation"
    from_eidos: praxis
    to_eidos: attainment
    cardinality: many-to-one
```

### Attainment Entity Migration

Replace the `grants` array field with `grants-praxis` bonds:

**Before:**
```yaml
- eidos: attainment
  id: attainment/mcp-essential
  data:
    name: mcp-essential
    grants:
      - praxis/nous/find
      - praxis/nous/surface
```

**After:**
```yaml
- eidos: attainment
  id: attainment/mcp-essential
  data:
    name: mcp-essential
    # grants field REMOVED — replaced by bonds

# Bonds:
- from_id: attainment/mcp-essential
  to_id: praxis/nous/find
  desmos: grants-praxis

- from_id: attainment/mcp-essential
  to_id: praxis/nous/surface
  desmos: grants-praxis
```

### Praxis Authorization Bonds

Each praxis that requires an attainment gets a `requires-attainment` bond:

```yaml
# Bond declarations (in praxis entity files or bond files)
- from_id: praxis/politeia/create-oikos
  to_id: attainment/govern
  desmos: requires-attainment

- from_id: praxis/politeia/grant-attainment
  to_id: attainment/govern
  desmos: requires-attainment
```

### Authorization Check (unified)

Before invoking any praxis, the system checks:

```
1. trace_bonds(from_id: praxis_id, desmos: "requires-attainment")
   → returns required attainment(s)

2. If no required attainment: praxis is public, allow

3. trace_bonds(from_id: parousia_id, desmos: "has-attainment")
   → returns prosopon's attainments

4. If required attainment ∈ prosopon's attainments: allow
   Else: reject with "Missing attainment: {name}"
```

This replaces both MCP projection's `grants` field reading AND praxis-internal YAML step authorization.

### Graph Query: "What can this prosopon do?"

```
parousia/victor --[has-attainment]--> attainment/govern
attainment/govern --[grants-praxis]--> praxis/politeia/create-oikos
attainment/govern --[grants-praxis]--> praxis/politeia/grant-attainment
```

Traverse: `parousia → has-attainment → attainment → grants-praxis → praxis`

Result: all praxeis this prosopon can invoke. Pure graph traversal.

### Graph Query: "What attainment do I need for praxis X?"

```
praxis/politeia/create-oikos --[requires-attainment]--> attainment/govern
```

Single hop. Pure graph traversal.

---

## Implementation Order

### Step 1: Doc (prescriptive spec)

**Write `docs/reference/attainment-authorization.md`** — the specification:
- Attainment eidos and bond topology (has-attainment, grants-attainment, grants-praxis, requires-attainment)
- Authorization check: how praxis invocation is gated
- Public praxeis: explicitly marked, no attainment required
- The two graph queries: "what can prosopon X do?" and "what does praxis Y require?"
- Migration from `grants` field to `grants-praxis` bonds
- Migration from YAML-step authorization to bond-based gating

### Step 2: Genesis (constitutional content)

1. **Define `desmos/grants-praxis`** and **`desmos/requires-attainment`** in genesis
2. **Migrate attainment entities**: remove `grants` array field, create `grants-praxis` bonds
3. **Add `requires-attainment` bonds** for praxeis that currently check permissions in YAML steps
4. **Remove `grants` field** from `eidos/attainment` schema

### Step 3: Test (assert the doc)

5. **Write tests BEFORE implementation:**
   - Test: `trace_bonds(attainment/govern, grants-praxis)` returns expected praxeis
   - Test: `trace_bonds(praxis/politeia/create-oikos, requires-attainment)` returns `attainment/govern`
   - Test: praxis invocation with correct attainment succeeds
   - Test: praxis invocation without required attainment fails with clear error
   - Test: full chain traversal answers "what can prosopon X do?"
   - Test: praxis with no `requires-attainment` bond is invocable by anyone (public)

### Step 4: Build (satisfy the tests)

6. **Update MCP projection** (`kosmos-mcp/src/projection.rs`) to use `grants-praxis` bonds instead of `grants` field
7. **Add authorization gate** to praxis invocation path — check `requires-attainment` bond before executing
8. **Remove ad-hoc YAML authorization patterns** from praxis definitions (the trace/filter/assert sequences)
9. **Update `get_attainment_grants`** in `host.rs` to traverse `grants-praxis` bonds instead of reading `grants` array

### Step 5: Verify

10. **`cargo build && cargo test`**
11. **Re-read `docs/reference/attainment-authorization.md`** — confirm it matches implementation
12. **Audit**: verify no praxis definitions contain ad-hoc authorization patterns:
    ```bash
    rg 'has-attainment.*assert\|required_attainment' genesis/ --glob '*.yaml'
    # Should return nothing — authorization is in bonds, not in steps
    ```
13. **Update `docs/REGISTRY.md`** impact map

---

## Files to Touch

### Kosmos (genesis)
- `genesis/politeia/desmoi/attainment.yaml` — add `grants-praxis`, `requires-attainment` desmoi
- `genesis/politeia/eide/politeia.yaml` — remove `grants` field from attainment eidos
- `genesis/politeia/entities/` — migrate attainment entities: remove `grants` arrays, add `grants-praxis` bonds
- Various topos `praxeis/` files — add `requires-attainment` bonds, remove ad-hoc YAML authorization

### Chora (implementation)
- `crates/kosmos-mcp/src/projection.rs` — use `grants-praxis` bonds instead of `grants` field
- `crates/kosmos/src/host.rs` — update `get_attainment_grants` to traverse bonds
- `crates/kosmos/src/interpreter/mod.rs` or `steps.rs` — add authorization gate before praxis execution
- `crates/kosmos/tests/` — attainment authorization tests

### Docs (written FIRST, verified LAST)
- `docs/reference/attainment-authorization.md` — authorization specification (prescriptive → verified)

---

## Verification

```bash
# Build
cargo build 2>&1

# Tests
cargo test 2>&1

# Verify grants field is gone from attainment entities
rg '^\s+grants:' genesis/politeia/ --glob '*.yaml'
# Should return nothing — grants are bonds, not fields

# Verify requires-attainment bonds exist
rg 'requires-attainment' genesis/ --glob '*.yaml'
# Should show bond declarations

# Verify no ad-hoc authorization in praxis steps
rg 'has-attainment.*filter\|assert.*attainment' genesis/ --glob '*.yaml'
# Should return nothing — authorization is in the invocation layer
```

---

## What This Enables

When authorization is graph-based:
- "What can prosopon X do?" is a **graph traversal**: parousia → has-attainment → attainment → grants-praxis → praxis
- "What does praxis Y require?" is a **single hop**: praxis → requires-attainment → attainment
- Authorization is **visible and auditable** — traverse the graph, see the permissions. No reading YAML step logic.
- The praxis invocation layer **enforces authorization uniformly** — not left to each praxis to implement its own checks
- The foundation for **capability-based security** is solid: attainments are capabilities, bonds are grants, the graph is the policy
- Topos authors **don't write authorization logic** — they declare `requires-attainment` bonds, the system enforces them
