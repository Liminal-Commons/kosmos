# PROMPT: Survey Resolution — Eight Findings Against Five Axioms

**Purpose**: Resolve each of the 8 one-right-way survey findings against the KOSMOGONIA V12 axioms and mechanism specs. This is the pattern level of the ascent: axiom → constitution → ontology → **pattern** → code.

**Authority**: KOSMOGONIA V12 (five axioms), `docs/reference/provenance/provenance-mechanism.md`, `docs/reference/provenance/authority-mechanism.md`.

**Methodology**: For each finding, assess against the five axioms (Composition, Authority, Traceability, Self-Grounding, Adequacy). Determine: violation, valid variance, or clean. Then prescribe the resolution.

---

## Summary

| # | Finding | Severity | Axioms Violated | Resolution |
|---|---------|----------|-----------------|------------|
| 1 | arise_entity direct callers | **Mostly resolved** | I, II, III, V (for REST) | Remove remaining REST bypass |
| 2 | MCP praxis invocation duplicated | Low | None (pattern defect) | Deduplicate |
| 3 | arise as upsert in MCP depart | Medium | II, III | Use update_entity |
| 4 | daemon_loop partial REPLACE | Medium | III | Read-modify-write |
| 5 | REST CRUD ignores session | **Critical** | I, II, III | Require auth or remove |
| 6 | Unmanifest lacks tier 3 gating | Medium | II | Add symmetric gating |
| 7 | gather visibility not implemented | **Critical** | Visibility pillar | Implement filtering |
| 8 | host.compose() no dwelling | Medium | II, V | Require dwelling or document variance |

---

## Detailed Assessments

### Finding 1: arise_entity Direct Callers

**Status**: Mostly resolved by T12 arc (Phases 0-4).

**Current state**: All bootstrap and runtime entity creation now flows through `compose_entity()` via `bootstrap_arise` or praxis invocation. The remaining direct callers are:
- **REST POST /api/entities** — creates entities without composition, provenance, or authorization
- **WASM db_arise** — dead code candidate (verify and remove)
- **Legitimate exceptions** (genesis root, validation-result, sync-conflict, auth-challenge) — valid under Self-Grounding (IV) or circumstantial variance (V)

**Assessment**:
- REST POST: Violates Axioms I (Composition), II (Authority), III (Traceability), V (Adequacy). Dwelling context IS available via session header but ignored.
- Legitimate exceptions: Valid. Genesis root is self-grounding. Validation-result and auth-challenge are pre-infrastructure. Sync-conflict is federation infrastructure.

**Resolution**: Addressed in Finding 5 (REST CRUD). WASM db_arise should be verified dead and removed.

---

### Finding 2: MCP Praxis Invocation Duplicated

**Assessment**: No axiom violation. Both paths converge at `execute_praxis()` which enforces authorization. This is a code hygiene issue — narrow way pattern violation (duplicated logic), not a constitutional violation.

**Resolution**:
- Extract shared `load_praxis(ctx, praxis_id) -> Result<Praxis>` function
- Both `host::invoke_praxis_dwelling()` and `kosmos-mcp::call_tool_impl()` call it
- ~25 lines deduplicated
- **Priority**: Low. Do during next code cleanup pass.

---

### Finding 3: arise as Upsert in MCP Depart

**Assessment**:
- **Axiom II (Authority)**: Violated. Status transition (active → departed) happens without authorization context.
- **Axiom III (Traceability)**: Violated. INSERT OR REPLACE destroys existing provenance bonds. The replaced entity loses its composition history.

**Resolution**:
- Replace `arise_entity()` calls in `depart()` with read-modify-write via `update_entity()`:
  1. `find_entity(session_id)` — read current
  2. Merge status field into existing data
  3. `update_entity(session_id, merged_data)` — write back
- Same for parousia entity
- Fires `EntityUpdated` (correct) instead of `EntityCreated` (incorrect)
- **Priority**: Medium. Affects provenance integrity of session/parousia lifecycle.

---

### Finding 4: daemon_loop Partial REPLACE Update

**Assessment**:
- **Axiom III (Traceability)**: Content integrity violated. REPLACE with partial data destroys fields that constitute the entity's identity.
- Content hash changes to reflect only the partial data, making the entity unrecognizable.

**Resolution**:
- Read-modify-write pattern at all four update sites in daemon_loop.rs:
  1. `ctx.find_entity(daemon_id)` — read current
  2. Merge status/error fields into existing data
  3. `ctx.update_entity(daemon_id, merged_data)` — write back
- **Priority**: Medium. Daemon entities currently survive because bootstrap re-creates them, but the pattern is wrong.

---

### Finding 5: REST CRUD Ignores Session — CRITICAL

**Assessment**:
- **Axiom I (Composition)**: Violated. REST POST creates entities without composition.
- **Axiom II (Authority)**: Violated. "The kosmos acts only as authorized by those who dwell in it." Unauthenticated, unauthorized mutation is the direct opposite.
- **Axiom III (Traceability)**: Violated. No provenance bonds on REST-created entities.

This is the most severe finding. Five mutation endpoints accept any HTTP request and modify the graph without authorization, composition, or provenance. The entire security model (Visibility = Reachability, Authenticity = Provenance) is bypassed.

**Resolution options** (from survey):
- **(a) Require ValidatedSession** — all mutation endpoints check session. Read endpoints remain open.
- **(b) Route through praxis** — POST creates via `compose`, PUT/DELETE via dedicated praxeis. Authorization flows through attainment graph.
- **(c) Document as local-only** — acceptable only if the REST API is genuinely never network-exposed.
- **(d) Remove direct CRUD** — all mutation goes through MCP praxis invocation.

**Recommended**: **(a) + (b)**. Require session on all mutation endpoints. Route entity creation through composition. This aligns REST with the same authority chain as MCP.

**Priority**: **Critical**. This is the open door in an otherwise secured system.

---

### Finding 6: Unmanifest Lacks Tier 3 Gating

**Assessment**:
- **Axiom II (Authority)**: Asymmetric authorization. Manifest requires tier 3 access (correct — it's a substrate operation). Unmanifest does not (incorrect — it's equally a substrate operation that kills processes, deletes DNS records, deprovisions storage).

**Resolution**:
- Add `require_tier3_access("unmanifest")` check in steps.rs execute_step() for Step::Unmanifest
- Also audit Step::Dissolve and Step::Keyring for appropriate gating
- **Priority**: Medium. Asymmetric gating is a defect but exploitation requires praxis-level access.

---

### Finding 7: gather_entities Visibility Not Implemented — CRITICAL

**Assessment**:
- **Pillar: Visibility = Reachability**: Directly violated. "Without the bond, data is not hidden — it is absent from your kosmos. No bond path means no data." Currently, ALL data is returned regardless of bond paths.
- This makes the pillar aspirational rather than structural. The constitution requires it to be structural.

**Resolution**:
- Implement visibility filtering in `host::gather_entities()` using the same `graph::visible_to()` logic that `surface()` already uses
- Filter by oikos membership: entities belong to oikoi, prosopa are members of oikoi, visibility flows through membership bonds
- For single-prosopon/single-oikos (current state), this is trivially "show everything in my oikos." But the mechanism must exist for the pillar to be structural.
- **Priority**: **Critical** for constitutional integrity. The pillar is meaningless without enforcement.

---

### Finding 8: host.compose() Passes No Dwelling

**Assessment**:
- **Axiom II (Authority)**: Violated when dwelling IS available. Composition without dwelling means no authorized-by bond.
- **Axiom V (Adequacy)**: Violated. If dwelling context is available in the circumstances, adequacy requires recording it.

**Resolution**:
- Add `compose_with_dwelling(dwelling: &DwellingContext, typos_id, inputs)` variant
- Keep `compose(typos_id, inputs)` for cases where dwelling is genuinely unavailable (internal operations, tests)
- Document which callers use which variant and why
- **Priority**: Medium. Affects provenance completeness but not security (composition still happens, just without authorization bond).

---

## Execution Phases

### Phase 1: Critical fixes (Findings 5, 7)
REST authorization + visibility filtering. These are constitutional violations — the system claims authority and visibility guarantees it doesn't enforce.

### Phase 2: Provenance integrity (Findings 3, 4, 8)
Read-modify-write for depart upsert and daemon_loop. Dwelling context for compose. These fix provenance completeness.

### Phase 3: Symmetric gating (Finding 6)
Unmanifest tier 3 check. Quick fix, medium priority.

### Phase 4: Code hygiene (Findings 1 remainder, 2)
WASM db_arise removal. Praxis loading deduplication. Low priority, do during cleanup.

---

## Verification

After each phase:
1. Run full test suite
2. Verify no regression in existing provenance bonds (compose_entity still creates typed-by, authorized-by, composed-from)
3. For Phase 1: verify REST mutation endpoints reject unauthenticated requests
4. For Phase 1: verify gather_entities returns only oikos-visible entities
5. For Phase 2: verify depart() fires EntityUpdated (not EntityCreated) for session and parousia
6. For Phase 2: verify daemon_loop preserves all entity fields across status updates
