# Reflex Engine — Complete, Bonded, Traversable

*Prompt for Claude Code in the chora + kosmos repository context.*

*Supersedes FRONT2-REFLEX-ENGINE.md. Merges functional engine requirements with architectural clean-break.*

---

## Methodology — Doc-Driven, Clean Break

This work follows **Doc → Test → Build → Verify Doc**, non-negotiably.

### The Cycle

1. **Doc (prescriptive)**: Write `docs/reference/reflex-system.md` describing the *desired state* — the reflex engine, its bond topology, event detection, matching, execution, and graph-queryable discovery.
2. **Test (assert the doc)**: Write tests that assert reflexes fire on mutations, that embedded format is rejected, that inward traversal answers "what fires when X happens?" Tests should fail before implementation.
3. **Build (satisfy the tests)**: Implement until tests pass.
4. **Verify doc (confirm truth)**: After implementation, re-read the reference doc. Update deviations so the doc ends as truth.

### Clean Break — No Backward Compatibility

- **No embedded mode.** The inline trigger/response form is removed. All 29 reflex declarations must be bonded form before the engine ships. No runtime detection, no fallback parsing, no "Architecture 1 vs Architecture 2" — there is one architecture.
- **No registry-only discovery.** The reflex registry is an optimization (pre-indexed for runtime performance), but the graph must be independently queryable. "What reflexes fire when an oikos is created?" must be answerable via graph traversal alone.
- **No forward-only traversal.** If bonds exist, they're traversable in both directions. Inward `trace_bonds` is a prerequisite.

### What "Reference Doc" Means

Reference docs in this project are *prescriptive* (target state), not descriptive (current state). When code doesn't match a reference doc, the code has a gap — not the doc (unless the design changed). See CONTRIBUTING.md for the full methodology.

---

## Context

Chora has a reflex engine in `crates/kosmos/src/reflex.rs` (~1,500 lines) with an EventType enum (6 variants), MAX_REFLEX_DEPTH = 10, and bootstrap-time loading. The infrastructure exists.

Kosmos has 29 reflex entities declared across 10 topoi. Each has a trigger (event type + optional eidos filter + optional condition), a response (praxis + params), scope (global/oikos/topos), and enabled flag.

**Two problems:**

1. **Dual architecture.** Most topoi use embedded triggers (inline in reflex data). Ergon uses bonded triggers (separate trigger entities connected via desmoi). The engine supports both, creating two parsing paths, two matching paths, two mental models.

2. **Forward-only traversal.** The bonded form is graph-traversable outward (reflex → trigger → event-type), but not inward (event-type → trigger → reflex). You can't ask "what reflexes respond to oikos creation?" without loading the entire registry.

**The solution:** Migrate all reflexes to bonded form, implement the engine for bonded-only, and add inward traversal. One architecture, fully traversable.

---

## Current State

### The engine (`crates/kosmos/src/reflex.rs`)

- `Reflex` struct with EventType, optional eidos/desmos filters, condition, praxis response, params
- `RefRegistry` loaded at bootstrap, cached, invalidated on reflex entity mutations
- `parse_reflex_embedded()` — parses inline trigger/response from entity data fields
- `parse_reflex_bonded()` — traverses `triggered-by`, `matches-event`, `filters-eidos`, `responds-with` bonds
- `check()` — matches events against registry, returns matching reflexes
- Depth limiting via `MAX_REFLEX_DEPTH = 10`
- Wired into `host.rs` via `notify_change()` — fires after mutations complete

### The 29 reflex declarations (across 10 topoi)

| Topos | Reflexes | Current Form | Examples |
|-------|----------|-------------|---------|
| oikos | 4 | Embedded | announce-insight, announce-pragma, member-joined, member-departed |
| politeia | 3 | Embedded | attainment-granted, attainment-revoked, governance-change |
| propylon | 2 | Embedded | entry-approved, entry-denied |
| agora | 3 | Embedded | topic-created, motion-proposed, motion-decided |
| nous | 4 | Embedded | theoria-created, phasis-created, authoring-session-started, artifact-focused |
| dynamis | 2 | Embedded | deployment-intent-changed, release-artifact-intent-changed |
| aither | 2 | Embedded | transport-connected, transport-disconnected |
| demiurge | 2 | Embedded | composition-completed, composition-failed |
| ergon | 5 | **Bonded** | pragma-signaled, pragma-resolved, pragma-escalated, pragma-delegated, pragma-created |
| logos | 2 | Embedded | phasis-threaded, phasis-acknowledged |

**27 embedded, 5 bonded.** All 27 embedded reflexes must be migrated to bonded form.

### Bond topology (bonded form — the target)

**Eide** (`genesis/ergon/eide/`):
- `eidos/reflex` — the reactive binding (name, description, enabled, scope)
- `eidos/trigger` — pattern-matching entity with optional `condition` field
- `eidos/entity-mutation` — subtypes: created, updated, deleted
- `eidos/bond-mutation` — subtypes: created, updated, deleted

**Desmoi** (`genesis/ergon/desmoi/`):
- `desmos/triggered-by` — reflex → trigger (many-to-one)
- `desmos/responds-with` — reflex → praxis (many-to-one, bond.data carries params)
- `desmos/matches-event` — trigger → entity-mutation or bond-mutation
- `desmos/filters-eidos` — trigger → eidos (optional)
- `desmos/filters-desmos` — trigger → desmos (optional)

**Full bond chain for one reflex:**

```
entity-mutation/created <--[matches-event]-- trigger/nous/theoria-created
eidos/theoria <--[filters-eidos]-- trigger/nous/theoria-created
trigger/nous/theoria-created <--[triggered-by]-- reflex/nous/theoria-created
reflex/nous/theoria-created --[responds-with]--> praxis/logos/emit-phasis
                                                  (bond.data.params: { content: "$entity.data.content", ... })
```

### Event detection (already wired)

`host.rs` calls `notify_change()` after mutations. The `MutationEvent` carries:
- `event_type`: EntityCreated, EntityUpdated, EntityDeleted, BondCreated, BondUpdated, BondDeleted
- `entity`: the mutated entity
- `previous`: before-state (for updates)
- `bond`: the bond (for bond events)
- `from_entity` / `to_entity`: source and target (for bond events)

### Context variable resolution

Reflex params use `$entity`, `$previous`, `$bond`, `$from`, `$to` bindings:
- `$entity` → the mutated entity
- `$entity.id` → entity ID
- `$entity.data.field` → entity data field
- `$previous` → previous entity state (updates only)
- `$bond` → the bond (bond events only)
- `$from` → source entity (bond events)
- `$to` → target entity (bond events)

---

## Design

### 1. Migrate all embedded reflexes to bonded form

Every embedded reflex gets decomposed into:
- A `trigger/` entity (with optional condition)
- Bonds: `matches-event`, `filters-eidos` (or `filters-desmos`), `triggered-by`, `responds-with`

**Before (embedded):**
```yaml
- eidos: reflex
  id: reflex/nous/theoria-created
  data:
    name: theoria-created
    trigger:
      event: entity_created
      eidos: theoria
    response:
      praxis: praxis/logos/emit-phasis
      params:
        content: "$entity.data.content"
        stance: declaration
        source_kind: topos
    enabled: true
    scope: global
```

**After (bonded):**
```yaml
- eidos: trigger
  id: trigger/nous/theoria-created
  data:
    name: theoria-created
    enabled: true

- eidos: reflex
  id: reflex/nous/theoria-created
  data:
    name: theoria-created
    enabled: true
    scope: global
```

Plus bonds (in the same file or a bonds file):
```yaml
- from_id: trigger/nous/theoria-created
  to_id: entity-mutation/created
  desmos: matches-event

- from_id: trigger/nous/theoria-created
  to_id: eidos/theoria
  desmos: filters-eidos

- from_id: reflex/nous/theoria-created
  to_id: trigger/nous/theoria-created
  desmos: triggered-by

- from_id: reflex/nous/theoria-created
  to_id: praxis/logos/emit-phasis
  desmos: responds-with
  data:
    params:
      content: "$entity.data.content"
      stance: declaration
      source_kind: topos
```

Apply this pattern to all 27 embedded reflexes across 9 topoi.

### 2. Remove embedded parsing

Delete `parse_reflex_embedded()` from `reflex.rs`. The loader only calls `parse_reflex_bonded()`. No fallback, no detection logic.

### 3. Ensure inward traversal

`host.trace_bonds()` must support direction. If the current implementation only supports outward traversal, add inward:

```rust
// Forward: from entity following bonds outward
trace_bonds(from_id: Some("reflex/X"), to_id: None, desmos: Some("triggered-by"))

// Inward: to entity following bonds inward
trace_bonds(from_id: None, to_id: Some("trigger/X"), desmos: Some("triggered-by"))
```

This enables the reverse query: "what reflexes are triggered-by this trigger?"

### 4. Graph-queryable discovery

With inward traversal, "what reflexes fire when a theoria is created?" becomes:

```
1. Find triggers that match entity creation:
   trace_bonds(to_id: "entity-mutation/created", desmos: "matches-event", direction: inward)

2. Filter to triggers that match theoria:
   trace_bonds(to_id: "eidos/theoria", desmos: "filters-eidos", direction: inward)

3. Find reflexes for matching triggers:
   trace_bonds(to_id: trigger_id, desmos: "triggered-by", direction: inward)

4. Find response praxis:
   trace_bonds(from_id: reflex_id, desmos: "responds-with")
```

Pure graph traversal. No registry loading required for discovery.

### 5. Engine functional requirements

These are FRONT2's requirements, preserved:

**Event detection:** Hook into mutations at the store level. Entity created/updated/deleted, bond created/updated/deleted. Each event carries full context (entity, previous, bond, from, to).

**Reflex matching:** On each mutation:
1. Load all enabled reflexes (cached at bootstrap, invalidated on reflex mutation)
2. Filter by event type (matches-event bond target)
3. Filter by eidos/desmos (filters-eidos, filters-desmos bonds)
4. Evaluate condition (trigger entity's condition field, if present)
5. Filter by scope (global always matches, oikos matches dwelling, topos matches topos)

**Response execution:** For each matched reflex:
1. Resolve params: substitute `$entity`, `$previous`, `$bond`, `$from`, `$to`
2. Call the praxis via responds-with bond target
3. Log failures but don't block the original mutation

**Guard rails:**
- Depth limiting: MAX_REFLEX_DEPTH = 10 (already exists)
- Error isolation: one reflex failure must not affect others or the triggering mutation
- Enabled flag: honor `enabled: true/false`
- Bootstrap caching: load all reflexes at bootstrap, rebuild on reflex entity mutation

---

## Implementation Order

### Step 1: Doc (prescriptive spec)

**Write `docs/reference/reflex-system.md`** — the complete specification:
- Reflex eidos and bond topology (triggered-by, responds-with, matches-event, filters-eidos, filters-desmos)
- Bonded form as the only form — no embedded
- Event types and their context variables ($entity, $previous, $bond, $from, $to)
- Matching algorithm (event type → eidos/desmos filter → condition → scope)
- Response execution (param resolution, praxis invocation, error handling)
- Guard rails (depth limiting, error isolation, enabled flag)
- Scope rules (global, oikos, topos)
- Graph-queryable discovery via inward traversal
- Bootstrap loading and cache invalidation

This doc describes the *desired end state*. Read it and ask: "if I only had this doc, could I implement the full reflex engine?" If not, the doc is incomplete.

### Step 2: Genesis (migrate all reflexes to bonded form)

Migrate all 27 embedded reflexes across 9 topoi:

1. **`genesis/oikos/entities/reflexes.yaml`** — 4 reflexes (announce-insight, announce-pragma, member-joined, member-departed)
2. **`genesis/politeia/entities/reflexes.yaml`** — 3 reflexes (attainment-granted, attainment-revoked, governance-change)
3. **`genesis/propylon/entities/reflexes.yaml`** — 2 reflexes (entry-approved, entry-denied)
4. **`genesis/agora/entities/reflexes.yaml`** — 3 reflexes (topic-created, motion-proposed, motion-decided)
5. **`genesis/nous/entities/reflexes.yaml`** — 4 reflexes (theoria-created, phasis-created, authoring-session-started, artifact-focused)
6. **`genesis/dynamis/entities/reflexes.yaml`** — 2 reflexes (deployment-intent-changed, release-artifact-intent-changed)
7. **`genesis/aither/entities/reflexes.yaml`** — 2 reflexes (transport-connected, transport-disconnected)
8. **`genesis/demiurge/entities/reflexes.yaml`** — 2 reflexes (composition-completed, composition-failed)
9. **`genesis/logos/entities/reflexes.yaml`** — 2 reflexes (phasis-threaded, phasis-acknowledged)

For each: create trigger entity, remove inline trigger/response from reflex data, add bonds (matches-event, filters-eidos/filters-desmos, triggered-by, responds-with).

**Verify:** `rg 'trigger:' genesis/ --glob '*.yaml'` should return only `eidos: trigger` entity definitions, not embedded trigger fields inside reflex data.

### Step 3: Test (assert the doc)

**Write tests BEFORE implementation changes to the engine:**
- Test: bonded reflex fires when matching entity is created (e.g., theoria-created → emit-phasis)
- Test: bonded reflex fires on entity update with condition (e.g., pragma status → resolved)
- Test: bonded reflex fires on bond creation (e.g., pragma-signaled via signals-to bond)
- Test: embedded reflex format is **rejected** (parse error, not silent fallback)
- Test: scope filtering works (oikos-scoped reflex only fires in its oikos)
- Test: condition evaluation works ($entity.data.status == "resolved")
- Test: context variables resolve ($entity.id, $entity.data.field, $previous, $bond, $from, $to)
- Test: depth limiting prevents infinite chains
- Test: reflex failure doesn't block the triggering mutation
- Test: inward traversal from entity-mutation/created finds triggers that match it
- Test: full chain traversal answers "what fires when theoria is created?"
- Test: disabled reflex (enabled: false) does not fire

### Step 4: Build (satisfy the tests)

10. **Remove `parse_reflex_embedded`** from `crates/kosmos/src/reflex.rs` — loader uses only `parse_reflex_bonded`
11. **Verify/complete event detection wiring** in `host.rs` — ensure all 6 event types fire `notify_change()` with full context
12. **Verify/complete matching logic** — event type, eidos/desmos filter, condition evaluation, scope
13. **Verify/complete response execution** — param resolution with all context variables, praxis invocation, error isolation
14. **Add inward traversal support** to `trace_bonds` in `host.rs` (if not already supported)
15. **Verify bootstrap loading** loads all 29 reflexes, cache invalidation works on reflex mutation

### Step 5: Verify

16. **`cargo build && cargo test`**
17. **Manual verification against all 29 reflexes:**
    - Create a theoria → verify phasis is emitted (nous/theoria-created)
    - Create a pragma → verify phasis is emitted (oikos/announce-pragma)
    - Update pragma to resolved → verify notification (ergon/pragma-resolved)
    - Create a bond with signals-to → verify notification (ergon/pragma-signaled)
    - Verify recursion guard stops at depth limit
18. **Re-read `docs/reference/reflex-system.md`** — confirm it matches implementation
19. **Audit:**
    ```bash
    # No embedded trigger fields in genesis
    rg '^\s+trigger:' genesis/ --glob '*.yaml' | grep -v 'eidos: trigger'
    # Should return nothing

    # No embedded parser in engine
    rg 'parse_reflex_embedded' crates/kosmos/src/reflex.rs
    # Should return nothing

    # All 29 reflexes load
    # Bootstrap log should show: "Loaded 29 enabled reflexes (0 embedded, 29 bonded)"
    ```
20. **Update `docs/REGISTRY.md`** impact map

---

## Files to Touch

### Kosmos (genesis) — migrate 27 embedded reflexes
- `genesis/oikos/entities/reflexes.yaml` — 4 reflexes
- `genesis/politeia/entities/reflexes.yaml` — 3 reflexes
- `genesis/propylon/entities/reflexes.yaml` — 2 reflexes
- `genesis/agora/entities/reflexes.yaml` — 3 reflexes
- `genesis/nous/entities/reflexes.yaml` — 4 reflexes
- `genesis/dynamis/entities/reflexes.yaml` — 2 reflexes
- `genesis/aither/entities/reflexes.yaml` — 2 reflexes
- `genesis/demiurge/entities/reflexes.yaml` — 2 reflexes
- `genesis/logos/entities/reflexes.yaml` — 2 reflexes
- Trigger entity and bond declarations per topos

### Chora (implementation)
- `crates/kosmos/src/reflex.rs` — remove `parse_reflex_embedded`, keep and verify `parse_reflex_bonded`, matching, execution
- `crates/kosmos/src/host.rs` — verify event detection wiring, ensure inward `trace_bonds` support
- `crates/kosmos/tests/` — reflex engine tests (firing, matching, scope, conditions, depth, traversal)

### Docs (written FIRST, verified LAST)
- `docs/reference/reflex-system.md` — reflex engine specification (prescriptive → verified)

---

## Verification

```bash
# Build
cargo build 2>&1

# Tests
cargo test 2>&1

# No embedded reflexes in genesis
rg '^\s+trigger:' genesis/ --glob '*.yaml' | grep -v 'eidos: trigger'

# No embedded parser in code
rg 'parse_reflex_embedded' crates/kosmos/src/reflex.rs

# All 29 reflexes load as bonded
KOSMOS_LOG=debug just dev 2>&1 | grep '\[reflex\]'
# Should show: "Loaded 29 enabled reflexes (0 embedded, 29 bonded)"
```

---

## What This Enables

When the reflex engine is complete, bonded-only, and traversable:
- All 29 reflexes across 10 topoi **fire correctly** on mutations
- "What happens when a theoria is created?" is a **graph query**, not code inspection
- One execution path, one parsing path, **zero ambiguity** between architectures
- Topos authors declare reactivity via bonds — the engine discovers and executes it
- The reactive topology is **visible** to tooling — an IDE can show "creating this entity triggers these reflexes"
- The graph is the **reactive manifest** — structure, presentation, AND behavior are all traversable
