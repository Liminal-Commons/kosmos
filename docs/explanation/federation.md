# Federation: Oikos-Scoped Externalization Across Substrates

*Rewritten to align with the unified externalization architecture.*

---

## Scope

This document specifies federation behavior only.

For the cross-cutting model shared by recovery, backup, self-sync, and federation, see:

- `docs/explanation/externalization.md`

Federation is the cross-prosopon, oikos-scoped destination of the same externalization reconciliation mechanism.

---

## Grounding

From constitutional and reference sources:

- Reconciliation is the actuation shape: `sense -> compare -> act` (`genesis/KOSMOGONIA.md:285-343`).
- The same shape applies at phoreta federation scale (`genesis/KOSMOGONIA.md:342`).
- Visibility is reachability through bonds (`genesis/KOSMOGONIA.md:273-278`).
- Federation distribution is part of the same flow (`genesis/KOSMOGONIA.md:416`).

Federation therefore does not define a separate synchronization ontology. It applies externalization reconciliation to remote substrates under oikos governance.

---

## Federation Boundaries

## In Scope

- Oikos-scoped sync between substrates/prosopa using `federates-with`.
- Cursor-based delta tracking with hash checkpoint verification.
- Conflict detection and resolution semantics.
- Integration with distributed topos delivery through oikos visibility.

## Out of Scope

- Local recovery/backup implementation details (covered in `externalization.md`).
- New ontology beyond existing federation primitives, unless later evidence requires it.

---

## Existing Federation Primitives

| Primitive | Role | Anchor |
|-----------|------|--------|
| `desmos/federates-with` | Scope which oikos content can flow | `genesis/politeia/praxeis/politeia.yaml:2372-2381` |
| `eidos/sync-cursor` | Track per-federation sync positions | `genesis/politeia/eide/politeia.yaml:174-222` |
| `eidos/sync-conflict` | Represent divergence requiring resolution | `genesis/politeia/eide/politeia.yaml:223-285` |
| `eidos/phoreta` | Signed carrier for payload transport | `genesis/hypostasis/eide/hypostasis.yaml:175-285` |

No new federation-specific eidos/desmos are introduced by this rewrite.

---

## Federation Reconciliation Loop

Federation uses the same reconcile shape as other substrates.

### 1. Sense

Federation sense reads:

- local graph deltas for scoped oikos content (`crates/kosmos/src/graph.rs:153-212`)
- local cursor state (`genesis/politeia/eide/politeia.yaml:196-221`)
- local phoreta checkpoint state (`crates/kosmos/src/phoreta.rs:468-640`)
- channel/session state for destination reachability (via aither channel context)

### 2. Compare

Federation compare uses hybrid tracking:

- versions for traversal windows (`> local_version`)
- hashes for equality/checkpoint and tamper/equivalence validation (`crates/kosmos/src/graph.rs:726-783`, `crates/kosmos/src/phoreta.rs:154-339`)
- cursor-carried hash checkpoints for per-lane convergence state

### 3. Act

Federation act includes:

- package scoped deltas as phoreta
- send phoreta over data-channel
- verify and apply incoming phoreta
- update cursor/checkpoint state
- surface conflict entity when convergence cannot be automatic

---

## Frequency Model for Federation

Federation is not globally batch-only or globally periodic-only.

- Connected channels: continuous reconciliation.
- Reconnect: cursor/hash catch-up.
- Resource-protection mode: bounded batch windows, preserving semantics.

This keeps federation responsive while controlling operational cost.

---

## Data Model

## Federation Bond

`federates-with` scopes flow. It does not replace reconciler semantics.

```yaml
desmos/federates-with:
  from_eidos: oikos
  to_eidos: oikos
  properties:
    sync_direction: [push, pull, bidirectional]
    eidos_filter: [string]
    channel_id: string
```

## Sync Cursor

`sync-cursor` tracks ordered progress and hash-equivalence checkpoints for each direction.

```yaml
eidos/sync-cursor:
  fields:
    federation_bond_id: string
    local_oikos_id: string
    remote_oikos_id: string
    local_version: integer
    remote_version: integer
    local_hash_checkpoint: string
    remote_hash_checkpoint: string
    status: [active, paused, failed]
    last_sync_at: timestamp
```

## Conflict Entity

`sync-conflict` persists unresolved divergence for deterministic operator resolution.

```yaml
eidos/sync-conflict:
  fields:
    entity_id: string
    local_version: integer
    remote_version: integer
    local_data: object
    remote_data: object
    status: [open, resolved]
```

---

## Conflict Semantics

Default strategies by class:

- mergeable/domain-safe classes: merge strategy
- ephemeral classes: timestamp/LWW allowed
- sovereign/credential/governance classes: manual resolution required

When auto-convergence cannot preserve invariants, create `sync-conflict` and pause only affected lane, not the entire federation domain.

---

## Integration with Topos Distribution

Topos distribution remains federation by the same mechanism:

1. Oikos distributes a topos-prod.
2. Member visibility includes the distributed entity set.
3. Federation reconciliation carries those entities across substrates.

No separate distribution transport is defined.

---

## Integration with Ergon and Shared Work

Shared work entities in federated oikoi follow identical flow:

- creation/update in one substrate
- scoped visibility check
- reconcile through phoreta transport
- remote apply and cursor advance

Federation transport is not special-cased by eidos category.

---

## Security and Integrity

| Concern | Mechanism |
|---------|-----------|
| Unauthorized visibility | Bond graph scoping (`federates-with` + membership) |
| Payload tampering | Phoreta hash/signature validation |
| Replay and duplicate apply | Cursor windows + hash checkpoint checks |
| Divergent concurrent writes | `sync-conflict` with explicit resolution |

---

## Current Status and Gap Surface

## Implemented Today

- federation ontology entities/primitives in politeia genesis
- phoreta carrier and content-addressed storage
- version and hash primitives in graph/phoreta layers

## Gaps Remaining

- full runtime substrate reconciler wiring for federation lanes
- complete conflict UX and operator workflow
- removal of recovery workaround logic in favor of uniform externalization path
- sync-cursor genesis shape currently version-only; hash checkpoint fields are target-state additions

---

## Migration Discipline

This rewrite removes prior prescriptive ambiguity:

- Federation is no longer described as a parallel model separate from recovery/backup.
- Version vectors are no longer treated as sufficient alone; hash checkpoints are normative.
- Federation docs no longer imply a distinct ontology when existing primitives are sufficient.

---

## Non-Goals of This Rewrite

- No code changes.
- No genesis mutations.
- No self-sync implementation details beyond architecture-level alignment.

---

*Traces to: `docs/explanation/externalization.md`, `genesis/KOSMOGONIA.md:285-343`, `genesis/politeia/eide/politeia.yaml:174-285`, `genesis/politeia/praxeis/politeia.yaml:2372-2416`, `crates/kosmos/src/phoreta.rs:468-700`, `crates/kosmos/src/graph.rs:153-212`.*
