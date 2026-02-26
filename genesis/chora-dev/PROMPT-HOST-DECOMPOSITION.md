# PROMPT: Host Decomposition

**Decomposes host.rs from 4039 lines / 7+ concerns into focused modules. Extracts graph operations, embedding/vector search, LLM inference, command templates, emission, and signaling into their own modules. host.rs becomes HostContext lifecycle + actuality coordination (~1200 lines).**

**Depends on**: PROMPT-SUBSTRATE-STANDARD.md (substrate modules already extracted: process.rs, storage.rs, credential.rs)
**Enables**: Every future prompt that touches host.rs — smaller files mean less context pollution, faster navigation, clearer ownership

---

## Architectural Principle

**A Module Should Have One Reason to Change**

host.rs currently changes when:
- Entity CRUD logic changes (graph)
- Embedding/vector search changes (AI)
- LLM inference API changes (AI)
- Command template format changes (cargo/build)
- Actuality dispatch routing changes (substrate)
- Reconciliation logic changes (reactive)
- Signaling protocol changes (WebRTC)
- Emission format changes (filesystem)
- Schema migration runs (database)

That's nine reasons. The substrate standard prompt extracted three substrate modules. This prompt extracts six more concern-modules. host.rs retains: HostContext lifecycle, actuality coordination, and schema init — one reason to change (how the host orchestrates).

---

## Methodology — Test → Extract → Verify → Repeat

This is pure structural refactoring. No behavior changes. No new features. The methodology:

1. **Verify green**: `cargo test -p kosmos --lib --tests` passes before any changes
2. **Extract one module at a time**: Move functions, update imports, verify tests pass
3. **After each extraction**: `cargo test -p kosmos --lib --tests` must still pass
4. **After all extractions**: Full test suite must match pre-refactor results exactly

No doc changes needed — this is internal restructuring. Cross-references to "host.rs" in docs remain valid (HostContext is still the entry point).

---

## Current State: Seven Concerns in One File

| Lines | Concern | Functions | ~Size |
|-------|---------|-----------|-------|
| 749–1585 | **Graph operations** — entity CRUD, bonds, traverse, visibility, cursors | arise, find, gather, dissolve, update, create_bond, trace_bonds, find_bond, loose_bond, gather_bonds, traverse, visible_to, get_cursor, update_cursor, get_oikos_notifications, get_attainment_grants, is_valid_sort_field, row_to_record | ~840 |
| 1586–1770 + 3274–3300 | **Embedding/vector search** — OpenAI embed, index, surface, cosine similarity | embed, index_embedding, surface, bytes_to_f32, cosine_similarity | ~220 |
| 1771–1985 | **LLM inference** — Anthropic API, structured output | infer, infer_structured | ~215 |
| 2877–3086 + 3507–3670 | **Command templates** — cargo build/test/clippy execution | execute_command_template, sense_build_artifact, sense_run_status, template_for_stoicheion, interpolate_template_args, compute_artifact_path, parse_command_output | ~340 |
| 3315–3461 | **Emission** — filesystem output, entity serialization | emit, entity_to_markdown | ~150 |
| 3190–3273 | **Signaling** — WebRTC/aither | signal | ~84 |
| 3670–3700 | **Reconciliation helpers** — field resolution, value matching | resolve_field_path, values_match | ~30 |

**What stays in host.rs:**
| Lines | Concern | Functions | ~Size |
|-------|---------|-----------|-------|
| 27–223 | Types & traits | SurfaceResult, SessionBridge, TestSessionBridge, ChangeEvent, ChangeListener | ~197 |
| 223–665 | HostContext lifecycle | new, in_memory, set_change_listener, set_reflex_registry, bootstrap, daemon, invoke_praxis, session_bridge | ~443 |
| 665–748 | Schema | init_schema, migrate_hypostasis_schema | ~83 |
| 1986–2876 | Actuality coordination | manifest, sense_actuality, unmanifest, *_by_stoicheion, apply_entity_update, dispatch_to_module, inject_provider, resolve_mode | ~890 |
| 3087–3189 | Reconciliation | reconcile | ~103 |
| 3701–4039 | Tests | 12 tests (move with their respective modules) | ~339 |

---

## Target State: Module Map

```
crates/kosmos/src/
├── host.rs              (~1200 lines) HostContext lifecycle + actuality coordination
├── graph.rs             (~840 lines)  Entity/bond CRUD, traverse, visibility
├── embedding.rs         (~220 lines)  Vector search, OpenAI embedding
├── inference.rs         (~215 lines)  LLM inference (Anthropic API)
├── command_template.rs  (~340 lines)  Cargo command execution + template helpers
├── emission.rs          (~150 lines)  Filesystem emit + entity serialization
├── signal.rs            (~84 lines)   WebRTC/aither signaling
├── credential.rs        (exists)      Credential substrate
├── process.rs           (exists)      Process substrate
├── storage.rs           (exists)      Storage substrate facade
├── r2.rs                (exists)      R2 provider
├── dns.rs               (exists)      DNS provider
├── voice.rs             (exists)      Voice handler
├── livekit.rs           (exists)      LiveKit handler
├── ...
```

---

## Design Decisions

### 1. Extracted modules take `&HostContext` or connection reference

Graph, embedding, inference, and emission functions currently access `self.conn` (the SQLite connection). Rather than breaking the HostContext abstraction, extracted modules receive a reference:

```rust
// graph.rs — functions take connection directly
pub fn arise_entity(conn: &Connection, eidos: &str, id: &str, data: Value) -> Result<Value>
pub fn find_entity(conn: &Connection, id: &str) -> Result<Option<Value>>
```

HostContext keeps thin delegation methods for public API compatibility:

```rust
// host.rs — delegation (preserves public API)
pub fn arise_entity(&self, eidos: &str, id: &str, data: Value) -> Result<Value> {
    let conn = self.conn.lock().map_err(|e| KosmosError::Internal(e.to_string()))?;
    let result = crate::graph::arise_entity(&conn, eidos, id, data)?;
    self.notify_change(ChangeEvent::EntityCreated { ... });
    Ok(result)
}
```

This keeps the graph module pure (no HostContext dependency, testable in isolation) while HostContext handles notification side-effects.

### 2. Notification stays in host.rs

`notify_change()` fires reflexes and notifies change listeners. It must happen after mutations. This side-effect stays in host.rs — the extracted modules are pure data operations.

### 3. Tests move with their functions

The 12 tests in host.rs test specific concerns. They move to the module that owns the function:

| Test | Target Module |
|------|---------------|
| test_arise_and_find | graph.rs |
| test_create_and_trace_bond | graph.rs |
| test_cosine_similarity | embedding.rs |
| test_bytes_roundtrip | embedding.rs |
| test_index_and_retrieve_embedding | embedding.rs |
| test_visible_to_member_of_oikos | graph.rs |
| test_visible_to_public_oikos | graph.rs |
| test_visible_to_unassigned_entity | graph.rs |
| test_traverse_inward | graph.rs |
| test_traverse_outward | graph.rs |
| test_cursor_operations | graph.rs |
| test_gather_entities_since_version | graph.rs |

### 4. reconcile() stays in host.rs

The `reconcile()` method (103 lines) calls `self.manifest()`, `self.sense_actuality()`, `self.unmanifest()`. It's tightly coupled to HostContext and uses `resolve_field_path` + `values_match`. These 30 lines of helpers move with it — they stay in host.rs or move into the existing `reconciler.rs` module.

### 5. Actuality coordination stays in host.rs

`manifest()`, `sense_actuality()`, `unmanifest()` and their `*_by_stoicheion` variants are the core of HostContext — they do mode resolution, eidos-specific dispatch, and stoicheion dispatch. This is host.rs's reason to exist. ~890 lines is substantial but coherent: it's one concern (how entities are actualized).

### 6. command_template.rs gets the cargo-specific logic

`execute_command_template()` (133 lines) plus its helpers (`template_for_stoicheion`, `interpolate_template_args`, `compute_artifact_path`, `parse_command_output`) plus the sense helpers (`sense_build_artifact`, `sense_run_status`) form a self-contained unit. They reference `self` only for `find_entity` (to load templates) and `update_entity` (to save results).

These functions take `conn: &Connection` or receive the template data as params rather than looking it up internally. host.rs calls `command_template::execute(...)` and handles entity updates.

---

## Implementation Order

### Step 1: Verify green baseline

```bash
cargo test -p kosmos --lib --tests 2>&1 | tail -5
# Record test count and pass status
```

### Step 2: Extract graph.rs (~840 lines)

**Move from host.rs:**
- Entity operations: `arise_entity`, `arise_entity_with_version`, `find_entity`, `gather_entities`, `dissolve_entity`, `update_entity`, `get_attainment_grants`, `gather_entities_since_version`, `count_changes_since_version`, `get_cursor`, `update_cursor`, `get_oikos_notifications`, `is_valid_sort_field`
- Bond operations: `create_bond`, `trace_bonds`, `find_bond`, `loose_bond`, `gather_bonds`
- Graph queries: `traverse`, `visible_to`
- Data mapping: `row_to_record`

**Function signatures change** from `&self` to `conn: &Connection`:
```rust
// graph.rs
pub fn arise_entity(conn: &Connection, eidos: &str, id: &str, data: Value) -> Result<Value>
pub fn find_entity(conn: &Connection, id: &str) -> Result<Option<Value>>
pub fn create_bond(conn: &Connection, from_id: &str, desmos: &str, to_id: &str, data: Option<Value>) -> Result<Value>
// ... etc
```

**host.rs retains thin delegations** that lock the connection, call graph.rs, and fire notifications:
```rust
pub fn arise_entity(&self, eidos: &str, id: &str, data: Value) -> Result<Value> {
    let conn = self.conn.lock().map_err(|e| KosmosError::Internal(e.to_string()))?;
    let result = crate::graph::arise_entity(&conn, eidos, id, data.clone())?;
    // Fire notification
    let eidos_str = result.get("eidos").and_then(|v| v.as_str()).unwrap_or("").to_string();
    self.notify_change(ChangeEvent::EntityCreated { eidos: eidos_str, id: id.to_string(), data });
    Ok(result)
}
```

**Move tests**: test_arise_and_find, test_create_and_trace_bond, test_visible_to_*, test_traverse_*, test_cursor_operations, test_gather_entities_since_version → graph.rs

**Register**: `pub mod graph;` in lib.rs

**Verify**: `cargo test -p kosmos --lib --tests`

### Step 3: Extract embedding.rs (~220 lines)

**Move from host.rs:**
- `embed` (OpenAI API call)
- `index_embedding` (SQLite insert)
- `surface` (vector similarity search)
- `bytes_to_f32` (utility)
- `cosine_similarity` (utility)

**Function signatures**: `embed` needs `openai_key: &str`, others need `conn: &Connection`.

**Move tests**: test_cosine_similarity, test_bytes_roundtrip, test_index_and_retrieve_embedding → embedding.rs

**Register**: `pub mod embedding;` in lib.rs

**Verify**: `cargo test -p kosmos --lib --tests`

### Step 4: Extract inference.rs (~215 lines)

**Move from host.rs:**
- `infer` (Anthropic API call)
- `infer_structured` (Anthropic tool_use for JSON schema)

**Function signatures**: Need `session: Option<&Arc<dyn SessionBridge>>` for API key resolution.

**Register**: `pub mod inference;` in lib.rs

**Verify**: `cargo test -p kosmos --lib --tests`

### Step 5: Extract command_template.rs (~340 lines)

**Move from host.rs:**
- `execute_command_template` (the main function)
- `sense_build_artifact`
- `sense_run_status`
- `template_for_stoicheion` (free function)
- `interpolate_template_args` (free function)
- `compute_artifact_path` (free function)
- `parse_command_output` (free function)

**Function signatures**: `execute_command_template` needs access to `find_entity` (to load templates) and `update_entity` (to save results). Two approaches:
- **Option A**: Pass `conn: &Connection` and call `graph::find_entity` / `graph::update_entity` directly
- **Option B**: Pass the template data as pre-resolved params

Option A is cleaner — the command template module loads its own template entity and updates the target entity through graph.rs.

**Register**: `pub mod command_template;` in lib.rs

**Verify**: `cargo test -p kosmos --lib --tests`

### Step 6: Extract emission.rs (~150 lines)

**Move from host.rs:**
- `emit` (write entity/content to filesystem)
- `entity_to_markdown` (entity → markdown serialization)

**Function signatures**: `emit` needs `conn: &Connection` (to look up entities). `entity_to_markdown` is pure transformation.

**Register**: `pub mod emission;` in lib.rs

**Verify**: `cargo test -p kosmos --lib --tests`

### Step 7: Extract signal.rs (~84 lines)

**Move from host.rs:**
- `signal` (WebRTC/aither signaling dispatch)

**Register**: `pub mod signal;` in lib.rs

**Verify**: `cargo test -p kosmos --lib --tests`

### Step 8: Move reconciliation helpers

**Move from host.rs to existing reconciler.rs:**
- `resolve_field_path` (free function, ~15 lines)
- `values_match` (free function, ~15 lines)

These are only used by `reconcile()`. If reconciler.rs already has its own helpers, merge. If not, add.

**Verify**: `cargo test -p kosmos --lib --tests`

### Step 9: Final verification

```bash
cargo test -p kosmos --lib --tests 2>&1 | tail -5
# Must match Step 1 baseline — same test count, all pass

# Verify host.rs line count
wc -l crates/kosmos/src/host.rs
# Target: ~1200 lines (±100)

# Verify no function is duplicated
# Each extracted function should exist in exactly one module
```

---

## Files to Read

**Before starting (verify current state)**:
- `crates/kosmos/src/host.rs` — the 4039-line file being decomposed
- `crates/kosmos/src/lib.rs` — current module registrations
- `crates/kosmos/src/reconciler.rs` — existing reconciler module (check what's already there)

**Already extracted (do not touch)**:
- `crates/kosmos/src/process.rs` — substrate module (from substrate standard)
- `crates/kosmos/src/storage.rs` — substrate module (from substrate standard)
- `crates/kosmos/src/credential.rs` — substrate module (from substrate standard)

---

## Files to Touch

| File | Change |
|------|--------|
| `crates/kosmos/src/graph.rs` | **NEW** — entity/bond CRUD, traverse, visibility (~840 lines) |
| `crates/kosmos/src/embedding.rs` | **NEW** — vector search, OpenAI embedding (~220 lines) |
| `crates/kosmos/src/inference.rs` | **NEW** — LLM inference via Anthropic API (~215 lines) |
| `crates/kosmos/src/command_template.rs` | **NEW** — cargo command execution + helpers (~340 lines) |
| `crates/kosmos/src/emission.rs` | **NEW** — filesystem emit + markdown serialization (~150 lines) |
| `crates/kosmos/src/signal.rs` | **NEW** — WebRTC/aither signaling (~84 lines) |
| `crates/kosmos/src/host.rs` | **MODIFY** — remove extracted functions, add thin delegations (~1200 lines remaining) |
| `crates/kosmos/src/reconciler.rs` | **MODIFY** — add resolve_field_path + values_match helpers |
| `crates/kosmos/src/lib.rs` | **MODIFY** — register new modules |

---

## Success Criteria

- [ ] `cargo test -p kosmos --lib --tests` passes with identical test count before and after
- [ ] `cargo test -p kosmos` (all tests including integration) passes
- [ ] `host.rs` is ≤1300 lines
- [ ] `graph.rs` exists and contains all entity/bond/traverse/visibility functions
- [ ] `embedding.rs` exists and contains embed/index/surface + vector math
- [ ] `inference.rs` exists and contains infer/infer_structured
- [ ] `command_template.rs` exists and contains all cargo template logic
- [ ] `emission.rs` exists and contains emit/entity_to_markdown
- [ ] `signal.rs` exists and contains WebRTC signaling
- [ ] No function is duplicated across modules
- [ ] All extracted functions are `pub` and importable
- [ ] Tests that moved with their functions still pass in their new locations

---

## What This Enables

1. **Context clarity**: Each module file can be read independently — no scrolling through 4000 lines to find the embedding logic
2. **Parallel work**: Changes to graph operations don't require reading inference code
3. **Testing isolation**: graph.rs tests can run without AI API keys; inference tests can be `#[ignore]` without affecting graph tests
4. **Future extraction**: graph.rs becomes the candidate for a standalone crate if kosmos ever splits
5. **Session context**: Claude Code navigates smaller files faster, fewer wrong turns from mixed concerns

---

## What Does NOT Change

1. **Public API**: `HostContext` retains all its `pub fn` methods — callers don't change
2. **Behavior**: Zero functional changes. This is pure structural extraction
3. **Actuality dispatch**: manifest/sense/unmanifest coordination stays in host.rs
4. **Substrate modules**: process.rs, storage.rs, credential.rs, r2.rs, dns.rs untouched
5. **Integration tests**: All external test files (tests/*.rs) continue to use `HostContext` unchanged
6. **Genesis YAML**: No changes
7. **Reconciliation**: `reconcile()` stays in host.rs; only its utility helpers move

---

## Risk Mitigation

The primary risk is breaking the public API or import paths. Mitigations:

1. **One module at a time**: Extract, verify, commit. Never extract two modules between test runs.
2. **Thin delegation pattern**: host.rs keeps `pub fn` methods that delegate to extracted modules. External callers don't change.
3. **Notification side-effects**: Only host.rs calls `notify_change()`. Extracted modules are pure data operations.
4. **Connection locking**: Only host.rs locks the mutex. Extracted modules receive `&Connection` (already locked).

---

*Traces to: V7 §L1 module organization, dead code policy (mixed concerns are contextual poison for Claude Code), PROMPT-SUBSTRATE-STANDARD.md (began the extraction pattern)*
