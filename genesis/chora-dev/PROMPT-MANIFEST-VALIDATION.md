# Manifest Validation — Topos Reliability

*Prompt for Claude Code in the chora repository context.*

---

## Methodology — Doc-Driven, Clean Break

This work follows **Doc → Test → Build → Verify Doc**, non-negotiably.

### The Cycle

1. **Doc (prescriptive)**: Write `docs/reference/manifest-validation.md` describing the *desired state* — what gets validated, when, how failures surface, what error messages look like. This doc is the specification.
2. **Test (assert the doc)**: Write tests with mock topoi that have unsatisfied dependencies, missing provides, unknown dynamis. Tests should fail (no validation exists yet) — that's the point.
3. **Build (satisfy the tests)**: Implement validation phases until tests pass.
4. **Verify doc (confirm truth)**: After implementation, re-read the reference doc. Does it match? Do the actual error messages match the documented ones? Update deviations so the doc ends as truth.

### Clean Break — No Backward Compatibility

There is no existing validation to be backward-compatible with. But the principle applies to the *strictness*:

- **No opt-in validation.** Bootstrap validates manifests. Period. No `KOSMOS_SKIP_VALIDATION=true` escape hatch.
- **No soft failures for hard contracts.** If `depends_on` names a topos that isn't loaded, that's an error — not a warning. If `provides.praxeis` lists a praxis that doesn't exist, that's a contract violation.
- **No partial validation.** All three phases (dependency resolution, provides verification, requirements check) run every time. You don't get to validate dependencies but skip provides checking.
- **Warnings exist for genuinely soft constraints** — like `surfaces_consumed` referencing a surface with no current provider (which might be loaded later). Errors exist for everything else.

### What "Reference Doc" Means

Reference docs in this project are *prescriptive* (target state), not descriptive (current state). When code doesn't match a reference doc, the code has a gap — not the doc (unless the design changed). See CONTRIBUTING.md for the full methodology.

---

## Context

A topos manifest is a contract: "I provide these capabilities, I require these dependencies, I need these substrate powers." Today, bootstrap loads manifests and creates entities, but **does not validate the contract**. A topos can declare `requires_dynamis: [intelligence.infer]` and bootstrap will happily load it — the failure only surfaces at praxis execution time, far from the declaration.

This prompt implements manifest validation: making the manifest a true, enforced contract where violations are caught at bootstrap, not at runtime.

**The goal:** When the system bootstraps, every topos manifest is validated against what actually exists. Missing dynamis, unsatisfied dependencies, orphaned praxeis, undeclared eide — all caught before any praxis executes.

---

## Current State

### What bootstrap does today

In `crates/kosmos/src/bootstrap.rs`:

1. Reads `manifest.yaml` for each topos
2. Parses into `ToposManifest` struct
3. Walks `content_paths` and loads YAML entities
4. Creates entities and bonds in the graph
5. **No validation of declared contracts**

### What's NOT validated

| Declaration | What It Claims | Current Validation |
|-------------|---------------|-------------------|
| `requires_dynamis: [intelligence.infer]` | Needs LLM capability | None — fails at execution |
| `depends_on: [manteia]` | Needs manteia loaded | None — load order is implicit |
| `provides.eide: [parousia]` | Defines parousia type | None — could be missing from eide/ |
| `provides.praxeis: [politeia/create-oikos]` | Exposes this praxis | None — praxis file could be absent |
| `provides.attainments: [govern]` | Declares this attainment | None — attainment entity could be missing |
| `surfaces_consumed: [reasoning]` | Needs reasoning surface | None — no surface existence check |
| `requires_attainments: [mcp-essential]` | Needs this attainment | None — attainment may not exist |

### Available dynamis in the interpreter

From `crates/kosmos/src/host.rs` — the `HostContext` trait provides:
- `db.*` operations (arise, find, bind, update, delete, gather, trace, loose, surface, index)
- `intelligence.infer` (LLM invocation)
- `webrtc.*` (signaling, connection)
- `fs.*` (read, write, stat, delete)
- `process.*` (spawn, check, kill)
- `dns.*` (create, get, delete records)
- `r2.*` / `s3.*` (object storage)

These are the actual capabilities. But there's no registry that maps dynamis strings to implemented methods.

---

## Design

### Validation Phases

Bootstrap validation happens in three phases, after all content is loaded:

#### Phase 1: Dependency Resolution (load order)

```
For each topos with depends_on:
  Verify every dependency topos is loaded
  Verify no circular dependencies
  Log: "Topos {name} depends on {deps} — all satisfied"
```

**Result:** Fail bootstrap if dependency missing. Warning if circular.

#### Phase 2: Provides Verification

```
For each topos:
  For each provides.eide entry:
    Verify eidos entity exists in graph (find eidos/{name})
  For each provides.desmoi entry:
    Verify desmos entity exists in graph
  For each provides.praxeis entry:
    Verify praxis entity exists in graph
  For each provides.attainments entry:
    Verify attainment entity exists in graph
  For each provides.reflexes entry:
    Verify reflex entity exists in graph
```

**Result:** Warning for each declared-but-missing entity. These are contract violations — the topos promised something it didn't deliver.

#### Phase 3: Requirements Check

```
For each topos:
  For each requires_dynamis entry:
    Verify dynamis is in the known dynamis registry
  For each surfaces_consumed entry:
    Verify at least one topos provides this surface
  For each requires_attainments entry:
    Verify attainment entity exists
```

**Result:** Warning for unresolvable requirements. Error for critical dynamis.

### Dynamis Registry

A static registry mapping dynamis strings to capabilities:

```rust
// In host.rs or a new validation.rs
const KNOWN_DYNAMIS: &[&str] = &[
    "db.arise", "db.find", "db.bind", "db.update", "db.delete",
    "db.gather", "db.trace", "db.loose", "db.surface", "db.index",
    "intelligence.infer",
    "webrtc.manifest", "webrtc.sense", "webrtc.unmanifest",
    "fs.read", "fs.write", "fs.stat", "fs.delete",
    "process.spawn", "process.check", "process.kill",
    "dns.create", "dns.get", "dns.delete",
    "r2.put", "r2.head", "r2.delete",
    "s3.put", "s3.head", "s3.delete",
];
```

**Future:** This registry should itself become homoiconic — dynamis entities in the graph. But for now, a const array catches the common case.

---

## Implementation Order

### Step 1: Doc (prescriptive spec)

**Write `docs/reference/manifest-validation.md`** — the specification for manifest validation:
- The three validation phases and when they run (after all content is loaded, before any praxis executes)
- Phase 1: Dependency resolution — what constitutes a satisfied dependency, error on missing, detection of circular dependencies
- Phase 2: Provides verification — every declared entity must exist in the graph, what "exists" means for each category (eide, praxeis, desmoi, attainments, reflexes)
- Phase 3: Requirements check — dynamis registry, surface consumption, attainment requirements
- Error vs warning classification — which failures prevent bootstrap, which log and continue
- Exact error message format (implementers should match these strings)
- The dynamis registry — complete list of known capabilities

This doc describes the *desired end state*. Read it and ask: "if I only had this doc, could I implement the validation?" If not, the doc is incomplete.

### Step 2: Test (assert the doc)

**Write tests BEFORE implementation:**
- Test: mock topos with `depends_on: [nonexistent]` — bootstrap must fail
- Test: mock topos with `provides.praxeis: [praxis/fake]` where praxis doesn't exist — contract violation logged
- Test: mock topos with `requires_dynamis: [gpu.compute]` — unknown dynamis error
- Test: mock topos with circular dependency — detected and reported
- Test: valid topos with all contracts satisfied — bootstrap succeeds cleanly

These tests SHOULD FAIL before implementation. That's the point.

### Step 3: Build (satisfy the tests)

3. **Add `KNOWN_DYNAMIS` registry** to `crates/kosmos/src/host.rs` (or new `validation.rs`)
4. **Implement Phase 1** (dependency resolution) in `bootstrap.rs`
5. **Implement Phase 2** (provides verification) in `bootstrap.rs`
6. **Implement Phase 3** (requirements check) in `bootstrap.rs`

### Step 4: Verify

7. **`cargo build && cargo test`**
8. **Re-read `docs/reference/manifest-validation.md`** — does it match what was built? Do the error messages match? Update deviations so the doc represents implemented truth
9. **Update `docs/REGISTRY.md`** impact map with new code areas

---

## Files to Touch

### Chora (implementation)
- `crates/kosmos/src/bootstrap.rs` — validation phases after content loading
- `crates/kosmos/src/host.rs` — `KNOWN_DYNAMIS` registry (or new `validation.rs`)
- `crates/kosmos/tests/` — manifest validation tests

### Docs (written FIRST, verified LAST)
- `docs/reference/manifest-validation.md` — validation specification (prescriptive → verified)

---

## Validation Output Format

Bootstrap should log validation results clearly:

```
[bootstrap] Validating topos contracts...
[bootstrap] ✓ manteia: all dependencies satisfied
[bootstrap] ✓ manteia: provides 3/3 praxeis, 2/2 eide
[bootstrap] ✓ manteia: dynamis [intelligence.infer] available
[bootstrap] ✗ ergon: provides praxis/ergon/missing-praxis but entity not found
[bootstrap] ✗ dynamis: requires_dynamis [gpu.compute] not in known dynamis
[bootstrap] ! oikos: consumes surface [understanding] but no provider loaded
[bootstrap] Validation complete: 2 errors, 1 warning
```

Use `tracing` for structured output. Errors prevent bootstrap. Warnings log but allow boot.

---

## Verification

```bash
# Build
cargo build 2>&1

# Tests
cargo test 2>&1

# Manual: bootstrap with full genesis and check logs
KOSMOS_LOG=debug just dev 2>&1 | grep '\[bootstrap\]'
```

---

## What This Enables

When manifests are validated contracts:
- A topos author gets **immediate feedback** when their manifest is inconsistent
- The system **fails fast** — no runtime surprises from missing capabilities
- The dependency graph is **explicit and checked** — no implicit load ordering
- The provides section becomes **trustworthy** — if it says it provides 3 praxeis, all 3 exist
- The foundation for **topos distribution** is solid — when topoi are distributed between oikoi, the receiving system can validate before loading

This is the reliability layer that makes "topos as app" possible. An app store needs contracts you can trust.
