# PROMPT: One Right Way Survey — Narrowing Divergent Paths

**Arc**: Post-T12 Structural Integrity
**Prerequisite**: One Right Way to Arise (T12) complete. Dead Code Sweep complete.
**Principle**: Where multiple paths exist for the same fundamental operation, narrow to one right way. Completeness and consistency contribute to coherence.

---

## Context

The T12 arc established one right way to arise: every entity flows through `compose_entity()` with typed-by and authorized-by bonds. This prompt surveys the ENTIRE codebase for analogous divergences — operations where multiple paths exist and should be narrowed.

Three comprehensive surveys were conducted:
1. **Entity mutation paths** (create, update, dissolve, bond create, bond remove)
2. **Query and dispatch paths** (lookup, gather, traverse, praxis invocation, mode dispatch, reconciliation, emission, change notification)
3. **Authorization and validation paths** (praxis auth, dokimasia, composition validation, bootstrap guard, dwelling propagation, attainments, step gating)

---

## Architecture Baseline: What Is Clean

These operations already have one canonical path. No action needed.

### Entity lookup
- **Canonical**: `graph::find_entity()` → `host::find_entity()`
- All callers go through host.rs. No direct SQL reads outside graph.rs.

### Mode dispatch
- **Canonical**: `host::manifest()` / `host::sense()` / `host::unmanifest()`
- Fully centralized through generated `stoicheion_for_mode()` dispatch table.
- No code calls substrate modules directly — all route through host methods.

### Reconciliation
- **Canonical**: `host::reconcile(reconciler_id, entity_id)`
- One entry point. Intent/actuality field resolution, transition matching, action dispatch all centralized.
- Daemon loop invokes sensing praxeis, not reconciliation directly.

### Emission (ekthesis)
- **Canonical**: `host::emit()` → `emission::serialize_entity()` + `emission::write_to_path()`
- One path to write files. No bypasses.

### Bond traversal
- **Canonical**: `graph::trace_bonds()` → `host::trace_bonds()`
- One query family. Specialized functions (`get_cursor`, `get_oikos_notifications`, `count_changes_since_version`, `max_version_in_oikos`) return scalars/counts, not full bond records — these are intentionally different operations, not bypass paths.

### Change notification
- **Canonical**: `host::notify_change(event)` (private)
- All five mutation operations call it: `arise_entity_with_version`, `update_entity`, `dissolve_entity`, `create_bond`, `loose_bond`.
- One intentional bypass: `index_embedding()` modifies supplementary columns (embedding, embedding_text, embedding_model) without notification — correct, since embedding is metadata outside core identity.
- One undeclared variant: `FileChanged` event is declared but never emitted by any code path.

### Graph SQL layer
- All SQL writes confined to `graph.rs`. All `graph.rs` write functions called only from `host.rs` wrappers.
- `kosmos-mcp` has zero direct SQL — every operation goes through `HostContext`.
- One semi-bypass: `nous::index_embedding()` executes `UPDATE entities SET embedding = ...` directly. This only touches embedding columns (not the `data` column), routed through `host::index_embedding()`. Intentional for performance — embedding updates shouldn't trigger reflex evaluation.

### SQL write layer (complete inventory)

| Module | SQL Type | Operations |
|--------|----------|------------|
| `graph.rs` | Read | `find_entity`, `gather_entities`, `gather_entities_since_version`, `count_changes_since_version`, `trace_bonds`, `find_bond`, `gather_bonds`, `get_cursor`, `get_oikos_notifications`, `max_version_in_oikos`, `visible_to`, `get_attainment_grants` |
| `graph.rs` | Write | `arise_entity`, `update_entity_data`, `dissolve_entity`, `create_bond`, `loose_bond` |
| `nous.rs` | Read | `surface_by_similarity` |
| `nous.rs` | Write | `index_embedding` (embedding columns only) |
| `host.rs` | DDL | Table creation, schema migration (PRAGMA, ALTER TABLE) |

---

## Finding 1: Entity Creation — arise_entity Has Many Direct Callers

### The One Right Way (T12)

`compose_entity()` in `composition.rs` is the promoted path. It enforces:
- Content-hash idempotency (no-op if hash unchanged)
- `composed-from` provenance bond
- `typed-by` bond (eidos guard: skipped when target_eidos == "eidos")
- `authorized-by` bond (when dwelling.session_id is Some)
- `depends-on` bonds (with DAG cycle detection)
- Delegates to `arise_entity()` for the actual SQL insert
- On recomposition (metabole): calls `update_entity()` instead

`arise_entity()` is the internal implementation detail — it does:
- Dokimasia validation (skipped during bootstrap and for validation-result entities)
- SQL insert/upsert via `graph::arise_entity()`
- Change notification (`EntityCreated` event)

### Direct arise_entity Callers That Bypass Composition

| File:Line | Caller | Entity Types Created | Bonds Created | Authorization |
|-----------|--------|---------------------|---------------|---------------|
| `composition.rs:414` | `compose_entity()` genesis path | Domain entities | composed-from, typed-by, authorized-by, depends-on | Via dwelling context |
| `steps.rs` (AriseStep) | `step: arise` in praxis YAML | Any (gated: requires `internal: true`) | None automatically | Praxis-level auth via check_praxis_authorization |
| `dynamis.rs:275` | WASM `db_arise` host function | Any | None | None |
| `bootstrap.rs:346` | Genesis root phasis creation | phasis/genesis-root | None (primordial) | None (primordial) |
| `bootstrap.rs:532` | `load_entities_from_file()` | Bulk genesis entities | None via arise (bonds loaded separately) | None |
| `dokimasia.rs:377` | `enforce_entity()` | validation-result | None | None (meta-entity) |
| `phoreta.rs:265` | `apply_phoreta()` | Any (from remote sync) | None | None (federation replication) |
| `phoreta.rs:291` | `create_conflict()` | sync-conflict | conflicts-on bond | None |
| `release.rs:127` | `load_yaml_file()` | Any (release script) | None | None (tooling) |
| `rest.rs:295` | `POST /api/entities` | **Any domain entity** | **None** | **None (session accepted but ignored)** |
| `rest.rs:504-559` | `POST /api/session/arise` | prosopon, oikos, parousia, session | member-of, instantiates, dwells-in, has-attainment | Session-based (but entity creation is raw) |
| `rest.rs:1082` | `challenge_entry()` | auth-challenge | None | None (pre-auth) |
| `rest.rs:1208-1263` | `verify_entry()` | prosopon, oikos, parousia, session | member-of, instantiates, dwells-in | Challenge-response verified |
| `lib.rs:597` | `McpServer::arise()` | session | None directly | MCP session token |
| `lib.rs:644` | `McpServer::arise()` fallback | parousia | manifests, contains, has-attainment | MCP session token |
| `lib.rs:699,746` | `McpServer::depart()` | **session, parousia (upsert)** | None | MCP session token |

### Analysis

The `host.rs` doc comment says arise_entity is for: "Genesis root entities, Validation results, Test fixture setup. Do NOT use for domain entity creation in praxeis — use `step: compose`."

**Legitimate exceptions** (pre-compositional infrastructure):
- Genesis root phasis — primordial, can't compose before composition exists
- Validation-result — meta-entity, prevents recursion
- Sync-conflict — infrastructure for federation conflict resolution
- Auth-challenge — ephemeral, pre-authentication
- Session lifecycle (prosopon, oikos, parousia, session) — transport entities, pre-compositional by design

**Questionable**:
- `REST POST /api/entities` — creates **any** domain entity without composition, no provenance bonds, no authorization. This is the most significant bypass.
- WASM `db_arise` — no composition, no provenance bonds. But WASM stoicheia are invoked from steps within praxeis, so praxis-level auth applies.
- `bootstrap.rs:532` `load_entities_from_file()` — bulk loading, already routed through bootstrap_arise in main path but this is the manifest/simple-manifest fallback path.
- MCP `depart()` using arise as upsert — wrong operation (see Finding 3).

### Decision Needed

Should transport/session entities get typos definitions and flow through composition? Or is the current split (domain entities compose, infrastructure entities arise directly) the right boundary?

---

## Finding 2: MCP Praxis Invocation Duplicates Host Praxis Invocation

### The Two Paths

**Path A — `host.rs:invoke_praxis_dwelling()`** (lines 488-540):
1. Normalize praxis ID prefix (`praxis/`)
2. `find_entity()` to load praxis entity
3. Extract `data` from entity
4. Parse `steps` via `serde_json::from_value`
5. Parse `params` schema via `serde_json::from_value`
6. Construct `Praxis` struct
7. Call `execute_praxis(self, &praxis, params, dwelling)`

**Path B — `kosmos-mcp/lib.rs:call_tool_impl()`** (lines ~870-940):
1. Normalize praxis ID prefix
2. `find_entity()` to load praxis entity
3. Extract `data` from entity
4. Parse `steps` via `serde_json::from_value`
5. Parse `params` schema via `serde_json::from_value`
6. Construct `Praxis` struct
7. Call `execute_praxis(host, &praxis, params, Some(dwelling))`

Steps 1-6 are duplicated verbatim (~25 lines). Both converge at `execute_praxis()`, so authorization (`check_praxis_authorization`) and execution are shared. But the praxis-loading logic is duplicated.

### Why This Matters

If praxis loading changes (e.g., new fields, new validation, new normalization), the change must be made in two places. This is the definition of "more than one way."

### Resolution

MCP's `call_tool_impl` should delegate to `host.invoke_praxis_dwelling()` instead of reimplementing the praxis loading. The MCP layer's only added value is constructing the `DwellingContext` from the MCP session — once dwelling is built, it should hand off to host.

---

## Finding 3: arise_entity Used as Upsert Instead of update_entity

### The Problem

MCP `depart()` (`lib.rs:699, 746`) calls `arise_entity()` on **existing** session and parousia entities to change their status:

```rust
// Changes session status to "ended"
host.arise_entity("session", &session_id, json!({
    "status": "ended",
    "ended_at": ...,
    ...
}))

// Changes parousia status to "departed"
host.arise_entity("parousia", &parousia_id, json!({
    "status": "departed",
    "departed_at": ...,
    ...
}))
```

Because `arise_entity` does `INSERT OR REPLACE` (upsert), this overwrites the existing entity. But:
- Fires `EntityCreated` instead of `EntityUpdated`
- No previous-state capture — reflexes can't evaluate conditions like "status changed from X to Y"
- Reflexes listening for entity updates miss these transitions entirely
- Change listeners see a "creation" event for an entity that already existed

### Resolution

Replace with `update_entity()`. This fires `EntityUpdated` with previous state, enabling proper reflex evaluation. Requires read-modify-write pattern since update_entity is REPLACE semantics.

---

## Finding 4: daemon_loop Passes Partial Data to REPLACE-Semantics Update

### The Problem

`daemon_loop.rs` (lines 72, 87, 102, 121) calls `update_entity()` with partial data:

```rust
ctx.update_entity(&daemon_id, json!({"status": "running"}))
ctx.update_entity(&daemon_id, json!({"status": "errored", "error": ...}))
ctx.update_entity(&daemon_id, json!({"status": "stopped"}))
```

Since `update_entity()` is REPLACE (not merge), this **destroys all other fields** on the daemon entity. If daemon entities have fields beyond `status` and `error` (e.g., `interval`, `praxis`, `name`), those fields are wiped.

### Resolution

Either:
- **(a)** Change to read-modify-write pattern (read entity, update status field, write back)
- **(b)** Confirm daemon entities truly have no other runtime-relevant fields (they may have static fields from genesis that are re-populated on next bootstrap)
- **(c)** Add a merge-update helper that reads current data, merges, then calls update_entity

Option (a) is the principled fix. Option (c) is a convenience wrapper that could serve all future callers.

---

## Finding 5: REST CRUD Endpoints Ignore Session — Unguarded Mutation Surface

### The Problem

Five REST endpoints accept `_session: OptionalSession` but prefix it with underscore and never use it:

| Endpoint | Method | Handler | Line |
|----------|--------|---------|------|
| `/api/entities` | POST | `create_entity` | rest.rs:~285 |
| `/api/entities/{id}` | PUT | `update_entity` | rest.rs:~355 |
| `/api/entities/{id}` | DELETE | `delete_entity` | rest.rs:~440 |
| `/api/bonds` | POST | `create_bond` | rest.rs:~375 |
| `/api/bonds` | DELETE | `delete_bond` | rest.rs:~465 |

Any HTTP client can:
- Create any entity of any eidos with any data — no composition, no provenance bonds
- Update any entity's data — no ownership check
- Delete any entity — no authorization
- Create any bond — no ownership check
- Delete any bond — no authorization

The `OptionalSession` extractor means the session is available but not required. Unauthenticated requests succeed.

### Context

These endpoints are used by the Thyra frontend (SolidJS app communicating with the sidecar via HTTP). The frontend builds requests and sends them directly. Currently, the sidecar runs locally (same machine, same user), so the security boundary is the OS process boundary. But architecturally, this is a wide-open mutation surface.

### Decision Needed

What is the desired state?
- **(a)** Require ValidatedSession on all mutation endpoints (authentication enforced)
- **(b)** Route mutations through praxis invocation (all CRUD goes through praxeis, REST is transport only)
- **(c)** Keep as-is for local sidecar (security boundary is OS), but document as intentional
- **(d)** Remove direct CRUD endpoints entirely — Thyra uses praxis invocation for all mutations

Option (b) or (d) would be the "one right way" answer — all mutations flow through praxeis, which have authorization via `check_praxis_authorization`. But this requires the frontend to invoke praxeis for every entity operation, which may affect latency and UX.

---

## Finding 6: Step::Unmanifest Lacks Tier 3 Gating (Asymmetric with Manifest)

### The Problem

In `steps.rs` `execute_step()`:

```rust
Step::Manifest(s) => {
    require_tier3_access(ctx, "manifest")?;  // ← HAS gating
    s.execute(ctx, scope)
}
Step::Unmanifest(s) => {
    // ← NO gating
    s.execute(ctx, scope)
}
```

`Step::Manifest` checks `require_tier3_access("manifest")` which:
1. Looks up the `manifest` stoicheion entity
2. Finds its `requires-attainment` bond
3. Verifies the session bridge has that attainment

`Step::Unmanifest` does NOT check. Both are actuality operations on external resources:
- Manifest can start processes, create DNS records, provision storage
- Unmanifest can **kill processes, delete DNS records, deprovision storage**

### Resolution

Add `require_tier3_access("unmanifest")` to the `Step::Unmanifest` arm. This requires:
1. A `requires-attainment` bond on the `unmanifest` stoicheion entity in genesis
2. The corresponding attainment entity to exist

### Also Relevant: Other Step Gating Asymmetries

| Step | Tier 3 Gate | Internal Gate | Notes |
|------|------------|---------------|-------|
| `Step::Arise` | No | Yes (`internal: true` required) | Correct — gated by composition path |
| `Step::Manifest` | Yes | No | Correct |
| `Step::Unmanifest` | **No** | No | **GAP** — should match Manifest |
| `Step::Signal` | Yes | No | Correct |
| `Step::Invoke` | Yes | No | Correct |
| `Step::Emit` | Yes | No | Correct |
| `Step::Infer` | Yes | Yes (`internal: true`) | Correct — double-gated |
| `Step::Dissolve` | **No** | **No** | **Debatable** — no compositional alternative exists |
| `Step::Keyring` | **No** | No | **Potential gap** — crypto operations ungated |
| `Step::Bind` | No | No | Acceptable — bond creation is graph operation, dokimasia validates |
| `Step::Loose` | No | No | Acceptable — bond removal is graph operation |

---

## Finding 7: gather_entities Visibility Not Implemented

### The Problem

`host.rs` `gather_entities()` (line ~757):

```rust
// Visibility filtering: not yet implemented
let _ = dwelling;
```

The `dwelling` parameter is accepted but explicitly discarded. All entities are returned regardless of who is asking. The `surface()` method DOES filter by `visible_to()` when dwelling is provided — so semantic search respects visibility but gather does not.

### Impact

Any MCP tool or REST endpoint that calls `gather_entities` returns all entities in the database, regardless of oikos membership or visibility bonds. This means:
- An agent dwelling in oikos A can see all entities in oikos B
- Entity visibility is not enforced at the query level

### Resolution

Implement the visibility check using `graph::visible_to()` which already exists but is only called from `surface()`. The `gather_entities` path should filter results the same way `surface` does.

---

## Finding 8: host.compose() Passes No Dwelling Context

### The Problem

`host.rs` (line ~726):

```rust
pub fn compose(&mut self, typos_id: &str, inputs: Value) -> Result<Value, KosmosError> {
    self.invoke_praxis("demiurge/compose", json!({
        "typos_id": typos_id,
        "inputs": inputs
    }))
}
```

`invoke_praxis()` calls `invoke_praxis_dwelling(..., None)`. Dwelling is None. When `compose_entity()` runs, `scope.dwelling` is None, so:
- No `authorized-by` bond is created (line composition.rs:435-439 checks `dwelling.session_id`)
- The entity arises without authorization provenance

### Who Calls host.compose()

This is the public Rust API for composition. Called from:
- Test code (integration tests that compose entities)
- Potentially from substrate callbacks or internal operations

### Resolution

Either:
- **(a)** Add a `compose_dwelling()` variant that accepts `DwellingContext` (parallel to invoke_praxis/invoke_praxis_dwelling)
- **(b)** Make `compose()` require dwelling context (breaking change for callers)
- **(c)** Accept that Rust-API composition doesn't carry authorization provenance (document as intentional)

---

## Intentional Bypasses (Documented, No Action)

These are multiple paths that exist for good architectural reasons:

### Bootstrap mode
- `is_bootstrapping()` skips dokimasia validation, reflex firing, and reflex registry refresh during bootstrap.
- Bootstrap creates entities via `arise_entity()` (wrapped in `bootstrap_arise` which uses `compose_entity`), not through praxis invocation.
- Germination dwelling context provides prosopon and session for authorization bonds.
- Post-bootstrap validation (`post_bootstrap_validate()`) runs a batch check after bootstrap completes.

### Constitutional eide self-definition
- Entities with eidos in `["eidos", "desmos", "stoicheion", "function", "genesis", "content-root", "slot-pattern", "attainment", "signature"]` skip dokimasia validation.
- These define the grammar itself — validation would be circular.

### Reflex/daemon invocation without dwelling
- Reflexes call `invoke_praxis()` with `None` for dwelling — autonomic responses are system-level.
- Daemons call `invoke_praxis()` with `None` — periodic background operations.
- Both can only invoke public praxeis (no `requires-attainment` bonds). This is intentional.
- If a reflex/daemon needs to invoke an attainment-gated praxis, a "system dwelling" concept would be needed.

### Embedding indexing bypass
- `nous::index_embedding()` writes directly to embedding columns without `notify_change()`.
- Embedding is supplementary metadata outside core entity identity (id, eidos, data, version, content_hash).
- Notifications would trigger unnecessary reflex evaluation and WebSocket traffic.

### dissolve_entity cascade
- `graph::dissolve_entity()` deletes all bonds via raw SQL (`DELETE FROM bonds WHERE from_id = ?1 OR to_id = ?1`) without individual `BondDeleted` notifications.
- Only the parent `EntityDeleted` event fires.
- Generating per-bond deletion events during cascade would be expensive and unlikely to be useful (the entity is gone, so its bonds are meaningless).

### Dokimasia enforcement mode
- Default is `Warn` (log but allow), set via `KOSMOS_ENFORCEMENT` env var.
- `strict` mode rejects invalid entities.
- Warn mode is intentional for development ergonomics. Production should use `strict`.

### Post-bootstrap bond validation gap
- Post-bootstrap validation checks entity data but not bond constraints.
- Bonds created during bootstrap are from signed spora — correct by construction.
- Minor gap but acceptable given the trust model.

---

## Summary: Actionable Items Ranked

| # | Finding | Type | Severity | Effort |
|---|---------|------|----------|--------|
| 5 | REST CRUD ignores session | Missing contract | **High** | Medium |
| 2 | MCP praxis invocation duplicated | One-right-way | **High** | Low |
| 1 | arise_entity direct callers (esp. REST POST) | One-right-way | **High** | High (design decision) |
| 3 | arise_entity used as upsert in MCP depart | Wrong path | **Medium** | Low |
| 6 | Unmanifest lacks tier 3 gating | Missing contract | **Medium** | Low |
| 4 | daemon_loop partial data to REPLACE update | Latent bug | **Medium** | Low |
| 7 | gather_entities visibility not implemented | Missing contract | **Medium** | Medium |
| 8 | host.compose() no dwelling | Missing contract | **Low** | Low |

---

## Next Steps

Each finding will be explored in depth before action. The exploration should determine:
1. **What is the desired state?** (prescriptive — decide first)
2. **What is the current state?** (sense after prescribing)
3. **What is the gap?** (delta between desired and actual)
4. **What is the minimal change to close the gap?** (implementation)

Findings may be grouped into phases based on natural dependencies.
