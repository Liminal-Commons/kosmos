# Surface Schemas — Topos Interoperability

*Prompt for Claude Code in the chora + kosmos repository context.*

---

## Methodology — Doc-Driven, Clean Break

This work follows **Doc → Test → Build → Verify Doc**, non-negotiably.

### The Cycle

1. **Doc (prescriptive)**: Write `docs/reference/surface-contracts.md` describing the *desired state* — what surfaces are, how they're validated, what the bootstrap contract looks like. This doc is the specification. It describes what WILL be true, not what IS true today.
2. **Test (assert the doc)**: Write tests that assert the documented behavior. They should fail against the current codebase — that's the point. A test that passes before you write code isn't testing anything new.
3. **Build (satisfy the tests)**: Implement until tests pass. The doc guides the implementation, not the other way around.
4. **Verify doc (confirm truth)**: After implementation, re-read the reference doc. Does it accurately describe what was built? If implementation required deviations, update the doc to reflect the actual state. The doc must end as truth, not aspiration.

### Clean Break — No Backward Compatibility

There are no existing surface entities, bonds, or validation logic to be backward-compatible with. But the principle applies to the *interface* too:

- **No feature flags.** Bootstrap validates surfaces or it doesn't. No `KOSMOS_VALIDATE_SURFACES=true` escape hatch.
- **No graceful degradation.** If a consumed surface has no provider, that's an error — not a warning that gets swallowed.
- **No dual paths.** Surface strings in manifests become entities and bonds. The old "bare string, ignored at bootstrap" behavior is gone.

### What "Reference Doc" Means

Reference docs in this project are *prescriptive* (target state), not descriptive (current state). When code doesn't match a reference doc, the code has a gap — not the doc (unless the design changed). See CONTRIBUTING.md for the full methodology.

---

## Context

Topoi declare capabilities they provide and consume via `surfaces_provided` and `surfaces_consumed` in their manifests. Today these are **bare strings** — names with no schema, no validation, no graph presence. A topos can claim to provide "reasoning" without actually providing anything. A topos can consume "transport" without any check that a transport provider exists.

This prompt implements surface schemas: making topos-to-topos contracts real, homoiconic, and traversable.

**The goal:** When a topos declares `surfaces_provided: [reasoning]`, the system knows exactly what praxeis that surface exposes, what input/output schemas they conform to, and which other topoi consume them. When `surfaces_consumed: [reasoning]` is declared, bootstrap validates that a provider exists and the contract is satisfied.

---

## Current State

### What exists

**Manifest declarations** (metadata only, not loaded into graph):
- `thyra`: `surfaces_provided: [emission, rendering]`
- `aither`: `surfaces_provided: [transport]`
- `dynamis`: `surfaces_provided: [computation]`
- `manteia`: `surfaces_provided: [reasoning]`
- `ergon`: `surfaces_provided: [coordination]`
- `oikos`: `surfaces_consumed: [understanding]`

**No `surface` eidos** exists in genesis. The word "surface" appears in stoicheion definitions (the `surface` search operation) and domain-specific desmoi (`surfaces-as`, `surfaces`), but not as a capability contract type.

**Bootstrap ignores surfaces.** `bootstrap.rs` parses `ToposManifest` but does not create entities or bonds for `surfaces_provided` / `surfaces_consumed`.

### What's needed

1. **`eidos/surface`** — a new entity type representing a capability contract
2. **`desmos/provides-surface`** — bond from topos manifest entity → surface entity
3. **`desmos/consumes-surface`** — bond from topos manifest entity → surface entity
4. **Surface schema** — what praxeis a surface includes, what guarantees it makes
5. **Bootstrap validation** — check that consumed surfaces have providers
6. **Graph traversal** — "what does the reasoning surface provide?" is a graph query

---

## Design

### Surface Eidos

```yaml
eidos: surface
id: eidos/surface
data:
  name: surface
  description: >
    A capability contract between topoi. Declares what praxeis
    a surface provides and what schemas they conform to.
  fields:
    - name: surface_id
      type: string
      required: true
      description: "Unique surface identifier (e.g., 'reasoning', 'transport')"
    - name: description
      type: string
      required: true
      description: "What this surface provides"
    - name: praxeis
      type: array
      required: true
      description: "Praxis IDs this surface exposes"
    - name: version
      type: string
      required: false
      description: "Surface contract version"
```

### Surface Instances

```yaml
# genesis/manteia/entities/surfaces.yaml
eidos: surface
id: surface/reasoning
data:
  surface_id: reasoning
  description: >
    LLM-powered inference capabilities: schema-constrained generation,
    governed evaluation, and memoized results.
  praxeis:
    - praxis/manteia/governed-inference
    - praxis/manteia/check-memo
    - praxis/manteia/clear-memo
  version: "1.0"
```

### Desmoi

```yaml
# genesis/arche/desmoi/surface.yaml
eidos: desmos
id: desmos/provides-surface
data:
  name: provides-surface
  from_eidos: topos-manifest
  to_eidos: surface
  cardinality: many-to-many
  description: "Topos provides this surface contract"

eidos: desmos
id: desmos/consumes-surface
data:
  name: consumes-surface
  from_eidos: topos-manifest
  to_eidos: surface
  cardinality: many-to-many
  description: "Topos requires this surface contract"
```

### Bootstrap Integration

In `bootstrap.rs`, after loading all topos manifests:

1. For each `surfaces_provided` entry, find or create the `surface/` entity
2. Create `provides-surface` bond from topos manifest entity → surface entity
3. For each `surfaces_consumed` entry, create `consumes-surface` bond
4. **Validation pass**: for every `consumes-surface` bond, verify at least one `provides-surface` bond exists for that surface
5. Log warnings for unsatisfied surface dependencies

---

## Implementation Order

### Phase 1: Doc (prescriptive spec)

1. **Write `docs/reference/surface-contracts.md`** — the specification for what surfaces are:
   - Surface eidos schema (fields, constraints, semantics)
   - Surface discovery: `gather(eidos: surface)` returns all known surfaces
   - Surface bonds: `provides-surface` and `consumes-surface` desmoi
   - Bootstrap validation rules: consumed surfaces MUST have providers
   - Error behavior: unsatisfied surface dependencies prevent bootstrap
   - Surface versioning model (if applicable)

   This doc describes the *desired end state*. Read it and ask: "if I only had this doc, could I implement the feature?" If not, the doc is incomplete.

### Phase 2: Genesis (constitutional content)

2. **Define `eidos/surface`** in `genesis/arche/eide/surface.yaml`
3. **Define `desmos/provides-surface` and `desmos/consumes-surface`** in `genesis/arche/desmoi/surface.yaml`
4. **Create `surface/` entities** for each existing surface name (reasoning, transport, computation, emission, rendering, coordination, understanding) — each in its respective topos

### Phase 3: Test (assert the doc)

5. **Write integration tests** that bootstrap and verify:
   - Surface entities exist after bootstrap (`find surface/reasoning`)
   - `provides-surface` bonds are traversable from topos manifest to surface
   - `consumes-surface` bonds exist where declared
   - A topos that consumes an unprovided surface **fails** bootstrap (not warns)
   - A topos that declares `provides` but doesn't deliver logs a contract violation

   These tests SHOULD FAIL before the implementation phase.

### Phase 4: Build (satisfy the tests)

6. **Update `bootstrap.rs`** to create surface entities and bonds from manifest declarations
7. **Add validation pass** that checks consumed surfaces have providers — error, not warning

### Phase 5: Verify doc (confirm truth)

8. **`cargo build && cargo test`**
9. **Re-read `docs/reference/surface-contracts.md`** — does it match what was built? Update any deviations so the doc represents implemented truth, not just intent.

---

## Files to Touch

### Kosmos (genesis)
- `genesis/arche/eide/surface.yaml` — new eidos
- `genesis/arche/desmoi/surface.yaml` — new desmoi
- `genesis/manteia/entities/surfaces.yaml` — reasoning surface definition
- `genesis/aither/entities/surfaces.yaml` — transport surface
- `genesis/dynamis/entities/surfaces.yaml` — computation surface
- `genesis/thyra/entities/surfaces.yaml` — emission + rendering surfaces
- `genesis/ergon/entities/surfaces.yaml` — coordination surface
- `genesis/nous/entities/surfaces.yaml` — understanding surface

### Chora (implementation)
- `crates/kosmos/src/bootstrap.rs` — surface entity creation + bond creation + validation
- `crates/kosmos/tests/` — surface graph traversal tests

### Docs (written FIRST, verified LAST)
- `docs/reference/surface-contracts.md` — surface contract specification (prescriptive → verified)

---

## Verification

```bash
# Build
cargo build 2>&1

# Tests
cargo test 2>&1

# Verify surface entities exist after bootstrap
# (manual check via MCP tools: nous_find surface/reasoning)

# Verify bonds traversable
# (traverse from topos manifest → provides-surface → surface entity)
```

---

## What This Enables

Once surfaces are homoiconic:
- A topos can **discover** what capabilities exist by querying `gather(eidos: surface)`
- A topos can **bind** to another topos's capabilities through the graph, not through hardcoded praxis imports
- Bootstrap **validates** that capability dependencies are satisfied before the system runs
- The graph becomes the **integration layer** — topoi compose through surface contracts, not through knowing each other's internal praxis IDs
