# WASM Stoicheia Expansion — Topos Independence

*Prompt for Claude Code in the chora repository context.*

---

## Methodology — Doc-Driven, Clean Break

This work follows **Doc → Test → Build → Verify Doc**, non-negotiably.

### The Cycle

1. **Doc (prescriptive)**: Write `docs/reference/stoicheia-wasm.md` describing the *desired state* — the WASM execution model, tier constraints, host function interface, portability rules. This doc is the specification. It describes what WILL be true, not what IS true today.
2. **Test (assert the doc)**: Write equivalence tests for each new stoicheion before implementing the WASM module. Tests should fail (no WASM module yet) — that's the point.
3. **Build (satisfy the tests)**: Write WAT modules and host bindings until equivalence tests pass in `compare` mode.
4. **Verify doc (confirm truth)**: After implementation, re-read the reference doc. Does it accurately describe the WASM execution model as built? Update deviations so the doc ends as truth.

### Clean Break — No Backward Compatibility

When a stoicheion gets a WASM implementation:

- **No "prefer arche" fallback.** Once WASM exists and passes equivalence tests, the WASM path is the path. No runtime detection logic that falls back to Rust.
- **No dual execution modes in production.** `compare` mode exists for testing. Production uses `wasm` for Tier 0-2, `arche` for Tier 3. No per-topos override that keeps individual stoicheia on the old path.
- **Arche is for host dynamis only.** When this work is done, arche is exclusively for Tier 3 operations that require host access (networking, LLM, filesystem). Not a safety net for portable operations.

### What "Reference Doc" Means

Reference docs in this project are *prescriptive* (target state), not descriptive (current state). When code doesn't match a reference doc, the code has a gap — not the doc (unless the design changed). See CONTRIBUTING.md for the full methodology.

---

## Context

Stoicheia are the atomic operations of the interpreter — `arise`, `find`, `bind`, `update`, `gather`, `trace`, `loose`, `delete`, `fetch_topos`, `surface`, etc. Today, only **3 stoicheia have WASM implementations** (find, arise, bind). Everything else executes as "arche" — hand-written Rust in `steps.rs`.

The V9 equivalence test infrastructure already exists and validates that WASM and Rust implementations produce identical results. The `stoicheia_form` field in topos manifests already declares which execution mode to use. The path is clear: expand WASM coverage so topoi can bring their own computation.

**The goal:** Every Tier 0-2 stoicheion (database operations) has a WASM implementation, validated by equivalence tests. The interpreter defaults to WASM for all portable operations. Arche remains only for Tier 3 host-level dynamis (networking, LLM, filesystem).

---

## Current State

### WASM modules that exist (3)

Located in `genesis/stoicheia-portable/wasm/`:
```
tier2-db-arise.wat    — entity creation
tier2-db-bind.wat     — bond creation
tier2-db-find.wat     — entity lookup
```

### Stoicheia that need WASM (from stoicheion.yaml)

| Stoicheion | Tier | Current | What It Does |
|-----------|------|---------|--------------|
| `arise` | 2 | WASM | Create entity |
| `find` | 1 | WASM | Find entity by ID |
| `bind` | 2 | WASM | Create bond |
| `update` | 2 | Arche | Update entity data |
| `delete` | 2 | Arche | Delete entity |
| `loose` | 2 | Arche | Delete bond |
| `gather` | 1 | Arche | Query entities by eidos |
| `trace` | 1 | Arche | Follow bonds from entity |
| `surface` | 1 | Arche | Semantic search |
| `index` | 2 | Arche | Index entity for semantic search |
| `fetch_topos` | 1 | Arche | Load topos config |

### Equivalence test infrastructure

`crates/kosmos/tests/v9_equivalence.rs` tests:
- `FindStep` — reads entity, compares WASM vs Rust output
- `AriseStep` — creates entity, compares
- `BindStep` — creates bond, compares

Environment variables control mode:
```
KOSMOS_STOICHEION_FIND=rust|wasm|compare
KOSMOS_STOICHEION_ARISE=rust|wasm|compare
```

### Manifest declarations

Most topoi declare `stoicheia_form: arche` or leave it unset:
```yaml
# soma/manifest.yaml
stoicheia_form: arche  # "No WASM modules yet"
```

---

## Implementation Order

### Phase 0: Doc (prescriptive spec)

**Write `docs/reference/stoicheia-wasm.md`** — the specification for the WASM execution model:
- WASM sandbox model (fuel metering, memory limits, import/export interface)
- Tier constraints: Tier 0-2 operations run as WASM, Tier 3 remains arche
- Host function interface contract (the `wasm.rs` bindings)
- How to write a new WAT module (input/output JSON via shared memory, host calls)
- Equivalence testing protocol (`compare` mode, what "identical results" means)
- Portability rules: what makes a stoicheion WASM-eligible vs arche-only
- Default execution mode: `wasm` for all Tier 0-2 after this work completes

This doc describes the *desired end state*. Read it and ask: "if I only had this doc, could I write a new WAT module?" If not, the doc is incomplete.

### Phase 1: Tier 2 Write Operations (update, delete, loose)

These are direct parallels to `arise` and `bind` — they modify the database through the same host function interface.

1. **`tier2-db-update.wat`** — Update entity data fields
   - Input: entity_id, data (JSON merge)
   - Host calls: `db_update_entity`
   - Returns: updated entity record

2. **`tier2-db-delete.wat`** — Delete entity
   - Input: entity_id
   - Host calls: `db_delete_entity`
   - Returns: success/failure

3. **`tier2-db-loose.wat`** — Delete bond
   - Input: from_id, to_id, desmos
   - Host calls: `db_delete_bond`
   - Returns: success/failure

4. **Equivalence tests** for each: add `UpdateStep`, `DeleteStep`, `LooseStep` to `v9_equivalence.rs`

### Phase 2: Tier 1 Read Operations (gather, trace)

These are more complex — they return collections and support filtering.

5. **`tier1-db-gather.wat`** — Query entities by eidos with optional limit/sort
   - Input: eidos, limit, sort_field, sort_order
   - Host calls: `db_gather_entities`
   - Returns: array of entity records

6. **`tier1-db-trace.wat`** — Follow bonds from entity
   - Input: entity_id, desmos (optional), direction
   - Host calls: `db_trace_bonds`
   - Returns: array of bond records with related entities

7. **Equivalence tests** for gather and trace

### Phase 3: Tier 1 Semantic Operations (surface, index)

These require the embedding/vector system.

8. **`tier1-db-surface.wat`** — Semantic similarity search
   - Input: query string, optional eidos filter, threshold, limit
   - Host calls: `db_surface_query`
   - Returns: array of scored entity matches

9. **`tier2-db-index.wat`** — Index entity for semantic search
   - Input: entity_id, content to index
   - Host calls: `db_index_entity`
   - Returns: success/failure

### Phase 4: Default to WASM (clean break)

10. Update `stoicheia_form` in all topos manifests to declare `wasm` for Tier 0-2 operations
11. Change default execution mode from arche to wasm in interpreter — no fallback
12. Run full equivalence test suite in `compare` mode
13. Remove any arche dispatch paths for stoicheia that now have WASM — dead code is not "safety net"

### Phase 5: Verify doc (confirm truth)

14. **Re-read `docs/reference/stoicheia-wasm.md`** — does it match what was built? Update any deviations so the doc represents implemented truth, not just intent
15. Update `docs/REGISTRY.md` impact map with new code areas

---

## Files to Touch

### Kosmos (genesis)
- `genesis/stoicheia-portable/wasm/tier2-db-update.wat` — new
- `genesis/stoicheia-portable/wasm/tier2-db-delete.wat` — new
- `genesis/stoicheia-portable/wasm/tier2-db-loose.wat` — new
- `genesis/stoicheia-portable/wasm/tier1-db-gather.wat` — new
- `genesis/stoicheia-portable/wasm/tier1-db-trace.wat` — new
- `genesis/stoicheia-portable/wasm/tier1-db-surface.wat` — new
- `genesis/stoicheia-portable/wasm/tier2-db-index.wat` — new
- Topos manifests: update `stoicheia_form` fields

### Chora (implementation)
- `crates/kosmos/src/interpreter/steps.rs` — WASM dispatch for new stoicheia
- `crates/kosmos/src/interpreter/wasm.rs` — host function bindings for new operations
- `crates/kosmos/tests/v9_equivalence.rs` — new equivalence tests
- `crates/kosmos/build.rs` — ensure WAT files compile

### Docs (written FIRST, verified LAST)
- `docs/reference/stoicheia-wasm.md` — WASM execution model specification (prescriptive → verified)

---

## Verification

```bash
# Build
cargo build 2>&1

# Equivalence tests (compare mode)
KOSMOS_STOICHEION_UPDATE=compare \
KOSMOS_STOICHEION_DELETE=compare \
KOSMOS_STOICHEION_LOOSE=compare \
KOSMOS_STOICHEION_GATHER=compare \
KOSMOS_STOICHEION_TRACE=compare \
cargo test v9_equivalence 2>&1

# Full test suite
cargo test 2>&1
```

---

## What This Enables

When all Tier 0-2 stoicheia are WASM:
- A topos can bring **custom stoicheia** as WASM modules — not just types and UI, but computation
- The interpreter becomes truly generic at the execution layer, not just the rendering layer
- Stoicheia are **content-addressed artifacts** with provenance — same inputs, same hash, cached result
- The path to **user-defined stoicheia** opens: a topos author writes a WAT file, declares it in their manifest, and the interpreter executes it
- Arche becomes the exception (Tier 3 host dynamis only), not the rule

---

## Design Principle

The existing WAT modules follow a pattern:
1. Receive input as JSON via shared memory
2. Call host functions (`db_arise_entity`, `db_find_entity`, etc.)
3. Return output as JSON via shared memory

New WAT modules must follow the same pattern. The host function interface in `wasm.rs` is the contract. Study the existing `tier2-db-arise.wat` as the reference implementation.

**Do not change the host function interface.** New stoicheia compose from existing host functions. If a new host function is needed (e.g., `db_gather_entities`), add it to `wasm.rs` following the existing pattern.
