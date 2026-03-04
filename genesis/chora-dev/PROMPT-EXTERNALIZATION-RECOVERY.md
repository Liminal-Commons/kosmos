# Externalization Recovery Reconciliation — Remove Workarounds, Keep One Mechanism

*Prompt for Claude Code in the chora + kosmos repository context.*

*After this work, recovery after DB wipe follows the same externalization reconciliation path as backup/federation, without special-case adoption/decryption commands. Recovery is implemented as design-conformant import/reconcile, not post-hoc patching. This prompt is recovery-only; self-sync and federation transport are separate prompts.*

---

## Architectural Principle — One Mechanism Across Time and Space

KOSMOGONIA states that reconciliation is universal (`sense -> compare -> act`) and applies at phoreta federation scale (`genesis/KOSMOGONIA.md:285-343`). Recovery is the same mechanism pointed at local historical substrate state, not a second architecture.

From the unified externalization doc (`docs/explanation/externalization.md`):

- externalization is reconciliation
- change tracking is hybrid (version + hash)
- no new ontology is required for recovery-first

So this implementation removes recovery-only exception paths and aligns recovery with the same structural pattern.

---

## Methodology — DDD + TDD

This work follows **Doc -> Test -> Build -> Verify**, non-negotiably.

1. **Doc (prescriptive)**: `docs/explanation/externalization.md` and rewritten `docs/explanation/federation.md` are the spec.
2. **Test (assert the doc)**: Add/adjust tests that fail under workaround-based recovery behavior.
3. **Build (satisfy the tests)**: Remove workaround paths and implement recovery-aligned import/reconcile flow.
4. **Verify doc**: Ensure implementation behavior matches spec language and invariants.

Notes:

- Clean break for workaround API surface is allowed.
- No federation transport implementation in this prompt.
- No new eidos/desmos creation in this prompt.

---

## Current State

### What Exists and Works

| Component | Location | Status |
|-----------|----------|--------|
| Phoreta carrier, content-addressed storage, import path | `crates/kosmos/src/phoreta.rs` | Working |
| Graph version/hash primitives | `crates/kosmos/src/graph.rs` | Working |
| Auto-emission reflexes for identity/credential paths | `genesis/hypostasis/reflexes/phoreta-emission.yaml` | Working |
| Recovery entry flow (mnemonic -> arise -> keyring) | `app/src/stores/kosmos.ts`, `app/src-tauri/src/main.rs` | Working |

### What's Missing — The Gaps

1. Recovery invokes workaround command `adopt_orphan_credentials` (`app/src/stores/kosmos.ts:313-316`) instead of relying on normalized import/reconcile.
2. Workaround command performs post-import decryption + bond repair (`app/src-tauri/src/main.rs:3122-3188`).
3. Host exposes `decrypt_phoreta_entities` schema-bypassing path for this flow (`crates/kosmos/src/host.rs:986-1038`).
4. Recovery contract is not asserted by focused tests that enforce workaround-free behavior.

---

## Target State

Recovery path after DB wipe:

1. Mnemonic derives identity deterministically.
2. Keyring is created/unlocked.
3. Recovery import/reconcile applies restorable phoreta state directly into valid graph state.
4. Credentials and bonds are present without orphan-adoption command.
5. No workaround API calls are required in UI or Tauri bridge.

### Explicit Recovery Requirements

- `recoverKeyring()` no longer calls `adopt_orphan_credentials`.
- `adopt_orphan_credentials` command removed.
- `HostContext::decrypt_phoreta_entities` removed.
- Recovery succeeds from phoreta state using primary import/reconcile flow only.

### Compatibility Requirement

- Existing non-recovery behavior remains intact.
- Existing phoreta lifecycle tests remain green.

---

## Sequenced Work

### Phase 1: Recovery Contract Tests

**Goal:** Codify desired recovery behavior before modifying runtime paths.

**Tests:**

- `recovery_flow_has_no_orphan_adoption_step` — front-end/store recovery flow does not invoke orphan-adoption command.
- `phoreta_recovery_import_restores_credentials_without_posthoc_decrypt` — recovery import path yields usable credential entities without explicit decryption helper call.
- `phoreta_recovery_preserves_credential_ownership_bonds` — recovered credentials carry ownership relationships via normal import/reconcile.

**Implementation:**

1. Add tests in Rust and TS suites where existing harnesses are available.
2. Ensure tests fail with current workaround-dependent flow.

**Phase 1 Complete When:**

- [ ] New tests exist and fail pre-build.
- [ ] Failures specifically identify workaround coupling.

### Phase 2: Remove Workaround APIs

**Goal:** Delete recovery-specific patch surfaces.

**Tests (run first):**

- Re-run Phase 1 tests to confirm they fail before edits.

**Implementation:**

1. Remove Tauri command `adopt_orphan_credentials` from command set and implementation in `app/src-tauri/src/main.rs`.
2. Remove `decrypt_phoreta_entities` from `crates/kosmos/src/host.rs` and any call path exposure.
3. Remove `adopt_orphan_credentials` invocation from `recoverKeyring` in `app/src/stores/kosmos.ts`.

**Phase 2 Complete When:**

- [ ] Workaround command/function symbols no longer exist.
- [ ] Build compiles with removed interfaces.

### Phase 3: Align Recovery Import/Reconcile Path

**Goal:** Ensure recovery succeeds through primary phoreta import/reconcile semantics.

**Tests:**

- `recover_after_db_wipe_restores_identity_and_credentials` — end-to-end recovery path works without workaround step.
- `recovery_import_is_idempotent` — repeated recovery import does not duplicate entities/bonds.

**Implementation:**

1. Update recovery sequencing to run import when key material is available and normal import path can satisfy decryption/application semantics.
2. Ensure bond restoration semantics are driven by emitted/imported graph state, not post-hoc mutation commands.
3. Keep behavior consistent with externalization doc invariant: one mechanism, different destination.

**Technical Mechanism (Required):**

1. **Import timing relative to unlock**
   - Bootstrap/discovery phase may read phoreta index metadata, but MUST NOT finalize encrypted credential recovery before key material exists.
   - After `recover_keyring` and keyring creation/unlock complete, run the authoritative recovery import pass with backup key available.
   - Recovery success criteria require decrypted, schema-valid runtime entities through this primary pass (no post-hoc decrypt helper).

2. **Bond ordering and prosopon availability**
   - Ensure prosopon/parousia identity entities needed as bond endpoints exist before credential bond reconciliation.
   - Import flow must apply entities first, then perform deterministic bond replay/retry for skipped bonds whose endpoints become available later in the same recovery transaction.
   - `credential-of` bonds MUST be restored through this replay logic, not via orphan-adoption command.

3. **Deterministic convergence**
   - Bond replay runs to fixpoint (or bounded retry with explicit unresolved-bond failure), then reports unresolved endpoints as recovery errors.
   - Re-running recovery import must be idempotent: no duplicate entities, no duplicate bonds, no new side-effects once converged.

**Phase 3 Complete When:**

- [ ] Recovery succeeds without workaround APIs.
- [ ] No orphan credential state remains after successful recovery.
- [ ] Idempotency holds for repeated recovery attempts.
- [ ] Recovery import timing is explicitly post-unlock for encrypted payload finalization.
- [ ] Bond replay/fixpoint logic restores `credential-of` without orphan-adoption command.

### Phase 4: Verification and Cleanup

**Goal:** Verify convergence and remove stale references.

**Tests:**

- Full relevant suites including `crates/kosmos/tests/phoreta_lifecycle.rs` and impacted app tests.

**Implementation:**

1. Remove stale comments/docs in touched files that mention workaround behavior as required.
2. Confirm no remaining references to removed symbols.

**Phase 4 Complete When:**

- [ ] All impacted tests pass.
- [ ] No references to removed workaround APIs remain.
- [ ] Recovery behavior matches `docs/explanation/externalization.md`.

---

## Files to Read

### Specification

- `docs/explanation/externalization.md` — canonical externalization model and Q1-Q6 outcomes
- `docs/explanation/federation.md` — federation-specific projection of same model
- `docs/reference/authorization/session-identity.md` — recovery semantics and existing flow

### Runtime Implementation

- `crates/kosmos/src/phoreta.rs` — import/store behavior
- `crates/kosmos/src/host.rs` — recovery-related host helpers
- `app/src-tauri/src/main.rs` — Tauri commands and recovery orchestration
- `app/src/stores/kosmos.ts` — client recovery flow

### Tests

- `crates/kosmos/tests/phoreta_lifecycle.rs` — phoreta import/export lifecycle assertions
- `crates/kosmos/tests/crypto.rs` — mnemonic/seed derivation invariants
- existing app test files covering store/recovery flows (create if absent)

---

## Files to Touch

| File | Change |
|------|--------|
| `app/src/stores/kosmos.ts` | **MODIFY** — remove orphan-adoption invocation from recovery flow |
| `app/src-tauri/src/main.rs` | **MODIFY** — remove `adopt_orphan_credentials` command and registration |
| `crates/kosmos/src/host.rs` | **MODIFY** — remove `decrypt_phoreta_entities` workaround path |
| `crates/kosmos/src/phoreta.rs` | **MODIFY** — ensure import/reconcile path supports recovery contract directly |
| `crates/kosmos/tests/phoreta_lifecycle.rs` | **MODIFY** — add recovery assertions |
| `app` test file(s) for recovery flow | **NEW/MODIFY** — assert no workaround call path |

---

## Success Criteria

**Overall Complete When:**

- [ ] Recovery path contains no orphan-adoption or post-hoc decrypt command calls.
- [ ] Workaround symbols removed from codebase.
- [ ] Recovery after DB wipe restores identity and credential usability through primary import/reconcile flow.
- [ ] Existing phoreta lifecycle behavior remains intact.
- [ ] Self-sync/federation transport implementation remains out of scope.

---

## What This Enables

- Recovery behavior that matches constitutional reconciliation architecture.
- Elimination of fragile, special-case recovery mutation paths.
- A clean base for later self-sync and federation transport prompts.

---

## What Does NOT Change

1. Phoreta carrier format and content-addressed storage design.
2. Existing federation ontology (`federates-with`, `sync-cursor`, `sync-conflict`).
3. Content hash and version primitives in graph layer.
4. Any self-sync or cross-device transport implementation.

---

*Traces to: `docs/explanation/externalization.md`, `genesis/KOSMOGONIA.md:285-343`, `app/src/stores/kosmos.ts:290-330`, `app/src-tauri/src/main.rs:3122-3188`, `crates/kosmos/src/host.rs:986-1038`.*
