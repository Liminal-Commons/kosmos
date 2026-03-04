# Externalization: Recovery, Backup, and Federation Through One Reconciliation Shape

*Discovery output. Prescriptive after evidence review.*

---

## Why This Document Exists

The system currently has three overlapping narratives:

1. KOSMOGONIA defines actuation as reconciliation (`sense -> compare -> act`) and names phoreta as federation carrier (`genesis/KOSMOGONIA.md:285-343`, `genesis/KOSMOGONIA.md:463`).
2. Federation doc prescribes continuous reconciliation with sync-cursor tracking (`docs/explanation/federation.md:93-135`).
3. Recovery docs and code use phoreta import, but also include recovery-specific workaround paths (`docs/reference/authorization/session-identity.md:67-87`, `app/src-tauri/src/main.rs:3122-3188`, `app/src/stores/kosmos.ts:313-316`, `crates/kosmos/src/host.rs:986-1038`).

This document resolves those tensions through explicit hypothesis testing (Q1-Q6), not pre-committed answers.

---

## Decision Protocol Used

Each question was treated as `open -> provisional -> final`.

For every question, final status required all of:

- doc evidence
- implementation evidence
- use-case fit (recovery, backup, self-sync, oikos federation, topos distribution)
- constitutional fit (especially `Actuation = Reconciliation` and reconciler universality)

If evidence contradicted a provisional position, the position was revised.

---

## Phase 1 Evidence Grounding

### Claim Matrix (Docs vs Implementation)

| ID | Source Claim (Anchor) | Implementation Truth (Anchor) | Agreement? |
|----|------------------------|--------------------------------|------------|
| C1 | Actuation is reconciliation: sense/compare/act (`genesis/KOSMOGONIA.md:285-343`) | Generic reconciler loop is explicitly sense/compare/act (`docs/reference/reactivity/reconciliation.md:17-26`) | Yes |
| C2 | Emission writes graph state to filesystem (`docs/reference/provenance/emission-reference.md:9-16`) | Phoreta has content-addressed filesystem store with index (`crates/kosmos/src/phoreta.rs:496-640`) | Partial (format differs but both are filesystem externalization) |
| C3 | Phoreta is carrier for federation transport (`genesis/KOSMOGONIA.md:463`) | Phoreta type is shared by emission/export/recovery/sync (`crates/kosmos/src/phoreta.rs:140-176`) | Yes |
| C4 | Federation uses continuous reconciliation with sync-cursor tracking (`docs/explanation/federation.md:93-135`) | Graph has since-version query primitives and politeia has sync-cursor eidos (`crates/kosmos/src/graph.rs:153-212`, `genesis/politeia/eide/politeia.yaml:174-222`) | Yes |
| C5 | Recovery path is same pattern as federation (`docs/reference/authorization/session-identity.md:67-87`) | Recovery UI still executes workaround adoption step (`app/src/stores/kosmos.ts:313-316`) | Divergence |
| C6 | Sync cursor is federation tracking primitive (`docs/explanation/federation.md:121-135`) | Cursor eidos and creation praxis exist in politeia (`genesis/politeia/eide/politeia.yaml:174-222`, `genesis/politeia/praxeis/politeia.yaml:2383-2407`) | Yes |
| C7 | Phoreta integrity and content addressing are core (`genesis/hypostasis/eide/hypostasis.yaml:201-249`) | Entity content hash + phoreta content hash both computed and persisted (`crates/kosmos/src/graph.rs:726-783`, `crates/kosmos/src/phoreta.rs:198-339`) | Yes |
| C8 | Recovery should be re-derivation and import, not ad-hoc mutation (`docs/reference/authorization/session-identity.md:73-87`) | Host has `decrypt_phoreta_entities()` bypass path and Tauri `adopt_orphan_credentials` bridge (`crates/kosmos/src/host.rs:986-1038`, `app/src-tauri/src/main.rs:3122-3188`) | Divergence |
| C9 | Emission scope should be graph-driven | Emission triggers are graph entities/reflexes (`genesis/hypostasis/reflexes/phoreta-emission.yaml:1-143`) | Yes |
| C10 | Federation bond scopes sync domain, not a separate permission layer (`docs/explanation/federation.md:109-119`) | `federates-with` bond plus sync cursor creation implemented in genesis praxeis (`genesis/politeia/praxeis/politeia.yaml:2372-2416`) | Yes |

### Agreement and Divergence Summary

| Area | Agreement | Divergence |
|------|-----------|------------|
| Constitutional pattern | Reconciliation is universal pattern | Externalization docs and recovery code not yet uniformly reconciler-shaped |
| Carrier format | Phoreta is shared format across concerns | Recovery still needs workaround paths after import |
| Change tracking | Versions and hashes both exist | Federation doc does not explicitly define hash role in comparison step |
| Governance scope | `federates-with` + `sync-cursor` exist | Recovery/local externalization responsibilities still anchored in hypostasis-only flow |
| Frequency | Continuous sync documented for federation | No unified urgency model across backup/recovery/self-sync/federation |

---

## Phase 2: Q1-Q6 Resolution

## Q1: Is externalization reconciliation or emission?

**Status progression:** `open -> provisional -> final`

**Open hypothesis:** externalization could be pure write (emission) or full reconcile loop.

**Evidence:**

- KOSMOGONIA defines actuation as reconciliation (`genesis/KOSMOGONIA.md:285-343`).
- Same section also defines emission as delivery mechanism to substrate (`genesis/KOSMOGONIA.md:297-304`).
- Reconciler reference defines sense/compare/act as mandatory loop shape (`docs/reference/reactivity/reconciliation.md:17-26`).
- Recovery docs already describe phoreta recovery as reconciliation pattern (`docs/reference/authorization/session-identity.md:87`).

**Final:** Externalization is **reconciliation**, and emission is one possible **act** operation inside that reconciliation.

**What "sense" means for externalization:**

- Local sense: inspect phoreta index (`read_index`) and latest stored hashes per scope (`crates/kosmos/src/phoreta.rs:496-640`).
- Graph sense: inspect changed entities since cursor/version (`crates/kosmos/src/graph.rs:153-212`).
- Federation sense: inspect sync-cursor status and channel presence (`genesis/politeia/eide/politeia.yaml:174-222`, `genesis/politeia/praxeis/politeia.yaml:2372-2416`).

`Final`

---

## Q2: What tracks change: versions, hashes, or both?

**Status progression:** `open -> provisional -> final`

**Options considered:**

- Version-only
- Hash-only
- Hybrid

**Evidence:**

- Version traversal primitives exist and are efficient for delta queries (`crates/kosmos/src/graph.rs:153-212`).
- Entity and phoreta content hashes are first-class integrity/equality primitives (`crates/kosmos/src/graph.rs:726-783`, `crates/kosmos/src/phoreta.rs:198-339`).
- Federation doc uses cursor-tracked ordered progress for traversal (`docs/explanation/federation.md:121-135`).

**Tradeoff analysis:**

- Versions answer ordering and "what changed since N".
- Hashes answer equality and tamper/equivalence checks.
- Neither fully subsumes the other without performance or correctness loss.

**Final:** Use **hybrid tracking**:

- Versions/cursors for ordered delta windows.
- Hashes for equivalence checkpoints, integrity, and fast no-op detection.

`Final`

---

## Q3: Does the oikos need a manifest entity?

**Status progression:** `open -> provisional -> final`

**Options considered:**

1. Cursor-only (no manifest abstraction)
2. Persisted manifest entity (`eidos/oikos-manifest`)
3. Computed manifest view from existing primitives (no new ontology)

**Evidence:**

- Existing index already stores `latest_hash` and history per scope (`crates/kosmos/src/phoreta.rs:468-640`).
- Existing cursor tracks version position for federation (`genesis/politeia/eide/politeia.yaml:174-222`).
- No constitutional requirement mandates a standalone manifest eidos for this concern.

**Final:** Adopt a **staged manifest model**:

- **Recovery-first:** use computed manifest view (hash projection from existing graph/phoreta state).
- **Federation-scale target:** introduce persisted `eidos/oikos-manifest` as a graph-visible checkpoint entity.

Rationale:

- Computed view is sufficient for the first recovery implementation cycle.
- Persisted manifest improves architectural self-consistency for federation by making oikos state summary first-class in the graph (not only a store-side index detail).
- Cursor + hash checkpoints remain complementary: cursor for ordered traversal, manifest hash for O(1) scope equivalence checks.

`Final`

---

## Q4: What frequency model is correct?

**Status progression:** `open -> provisional -> final`

**Options considered:**

- Continuous-only
- Periodic-only
- On-demand-only
- Priority-triggered hybrid

**Evidence:**

- Federation doc prescribes continuous reconciliation for connected channels (`docs/explanation/federation.md:93-101`).
- Recovery/backup use cases are not uniformly latency-critical.
- Existing reflex emission already behaves as immediate for selected identity entities (`genesis/hypostasis/reflexes/phoreta-emission.yaml:1-143`).

**Final:** Adopt **priority-triggered hybrid** frequency:

- Immediate: identity/security-critical changes (kleidoura, credential structure).
- Continuous: active self-sync/federation channels.
- Periodic: durability sweeps/compaction and low-urgency backup batching.
- On-demand: explicit backup/export actions.

`Final`

---

## Q5: Where does externalization live in topos structure?

**Status progression:** `open -> provisional -> final`

**Options considered:**

- New dedicated topos
- Existing single topos ownership
- Cross-cutting ownership by concern

**Evidence:**

- Carrier and recovery primitives already live in hypostasis (`genesis/hypostasis/eide/hypostasis.yaml:175-285`, `genesis/hypostasis/praxeis/hypostasis.yaml:646-708`).
- Federation scope and cursor semantics live in politeia (`genesis/politeia/eide/politeia.yaml:174-285`).
- Reconciler loop is generic and substrate-level (`docs/reference/reactivity/reconciliation.md:17-117`).

**Final:** Externalization is **cross-cutting**, no new topos required.

Ownership split:

- Hypostasis: carrier format and recovery-facing emission/import primitives.
- Politeia: federation scope and cursor governance.
- Reactivity/Dynamis: reconcile loop orchestration.
- Aither: transport substrate for peer flows.

`Final`

---

## Q6: Local externalization and federation: same mechanism or different?

**Status progression:** `open -> provisional -> final`

**Options considered:**

- Different mechanisms sharing only format
- One mechanism with destination/transport variants

**Evidence:**

- Session identity doc states one pattern, not two (`docs/reference/authorization/session-identity.md:67-87`).
- KOSMOGONIA states reconciler pattern is universal and includes phoreta federation scale (`genesis/KOSMOGONIA.md:328-343`).
- Current code already reuses same phoreta type for recovery/export/sync (`crates/kosmos/src/phoreta.rs:140-176`).

**Final:** One mechanism, multiple destinations.

- Local destination: filesystem phoreta store (time continuity/recovery).
- Remote destination: peer substrate via channel (space continuity/federation).

`Final`

---

## Phase 3: Unified Externalization Architecture

## Core Model

Externalization reconciliation loop:

1. **Sense**
   - Graph state for changed entities/cursor windows.
   - Local external store state (`index.latest_hash`, history).
   - Remote cursor/channel state where applicable.
2. **Compare**
   - Version delta for traversal window.
   - Hash equivalence for checkpoint/no-op/integrity.
3. **Act**
   - Emit/update phoreta in local store.
   - Send/apply phoreta across channel for federation.
   - Update cursor/checkpoint metadata.

This preserves constitutional shape while reusing existing primitives.

## Use-Case Mapping

| Use Case | Sense | Compare | Act |
|----------|-------|---------|-----|
| Recovery | phoreta index + mnemonic-derived identity | index/hash/cursor consistency | import phoreta with key material available, rebuild graph state |
| Backup | graph changes + store state | version window + hash checkpoint | emit/update local phoreta artifacts |
| Self-sync | local graph + peer cursor/channel | since-version + hash checkpoint | exchange/apply deltas via phoreta |
| Oikos federation | scoped graph visibility + federation cursor | scope-filtered version/hash diff | exchange/apply scoped phoreta |
| Topos distribution | oikos visibility and distributed artifacts | release/checkpoint comparison | deliver artifacts through same externalization channel |

---

## Phase 4: Implemented Now vs Target

| Concern | Implemented Now | Target |
|---------|------------------|--------|
| Carrier | Unified phoreta struct + content-addressed store (`crates/kosmos/src/phoreta.rs:140-176`, `:468-640`) | Keep |
| Change tracking | Versions and content hashes both present (`crates/kosmos/src/graph.rs:153-212`, `:726-783`) | Make dual-role explicit in docs and reconcile logic |
| Federation scope | `federates-with`, `sync-cursor`, federation praxeis exist in genesis (`genesis/politeia/eide/politeia.yaml:174-285`, `genesis/politeia/praxeis/politeia.yaml:2372-2416`) | Keep and align with unified loop |
| Recovery flow | Includes workaround commands (`crates/kosmos/src/host.rs:986-1038`, `app/src-tauri/src/main.rs:3122-3188`, `app/src/stores/kosmos.ts:313-316`) | Remove workaround path in recovery implementation prompt |
| Frequency | Reflex-immediate for selected eide (`genesis/hypostasis/reflexes/phoreta-emission.yaml:1-143`) | Hybrid urgency model across all externalization destinations |

---

## What Stays, Changes, and Is Removed

### Stays

- Phoreta as carrier format and content-addressed storage.
- Entity-level content hashing.
- Sync cursor and federation scope primitives.
- Bond-graph visibility model.

### Changes

- Externalization is documented explicitly as reconciliation (emission becomes an act step).
- Federation docs align with dual tracking (versions + hashes).
- Frequency policy becomes urgency-based hybrid instead of a single global mode.

### Removed (by follow-up recovery implementation)

- `decrypt_phoreta_entities()` workaround path (`crates/kosmos/src/host.rs:986-1038`).
- `adopt_orphan_credentials` workaround command (`app/src-tauri/src/main.rs:3122-3188`).
- Recovery UI dependence on orphan-adoption step (`app/src/stores/kosmos.ts:313-316`).

---

## Phase 5: Doc-Only Genesis Definitions

Recovery-first introduces no new ontology in implementation, but discovery justifies one deferred federation primitive.

### Recovery-First Reuse Profile

```yaml
externalization_primitives:
  recovery_first_reuse:
    - eidos/phoreta
    - eidos/sync-cursor
    - eidos/sync-conflict
    - desmos/federates-with
  recovery_first_new_eidos: []
  recovery_first_new_desmoi: []
```

### Deferred Federation Primitive (Doc-Only)

```yaml
- eidos: eidos
  id: eidos/oikos-manifest
  data:
    name: oikos-manifest
    description: |
      Content-addressed summary of an oikos state at a reconciliation checkpoint.
      Supports O(1) scope-change detection and graph-visible checkpoint provenance.
    fields:
      oikos_id:
        type: string
        required: true
      root_hash:
        type: string
        required: true
        description: "Hash of canonical sorted {entity_id -> content_hash} projection for the scope"
      entity_count:
        type: integer
        required: true
      source_cursor_version:
        type: integer
        required: true
      previous_manifest_hash:
        type: string
        required: false
      created_at:
        type: timestamp
        required: true
```

Deferred rationale:

- Not required for the immediate recovery prompt.
- Required for federation-scale, graph-visible, auditable checkpoint semantics.

---

## Phase 6: Recovery-Only Prompt Boundary

The first implementation prompt is recovery-only.

Included:

- Remove workaround recovery code paths.
- Reconcile recovery against this architecture.
- Add/adjust tests to assert no workaround behavior is required.

Explicitly excluded:

- Self-sync implementation
- Federation transport implementation
- New ontology introduction

---

## Acceptance Criteria

This discovery is complete when all are true:

- Q1-Q6 each have a `Final` position grounded in evidence.
- Externalization model maps all five required use cases.
- No contradictory prescriptive statements remain between externalization and federation docs.
- No new ontology is introduced without necessity proof.
- Recovery-first implementation prompt is produced separately.

---

*Traces to: `genesis/KOSMOGONIA.md:285-343`, `genesis/KOSMOGONIA.md:463`, `docs/reference/reactivity/reconciliation.md:17-117`, `docs/reference/authorization/session-identity.md:67-87`, `crates/kosmos/src/phoreta.rs:140-176`, `crates/kosmos/src/graph.rs:153-212`.*
