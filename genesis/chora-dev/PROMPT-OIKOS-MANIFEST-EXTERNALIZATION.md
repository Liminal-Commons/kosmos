# Oikos Externalization — Ontological Design Discovery

*Prompt for Claude Code in the chora + kosmos repository context.*

*Discovers the right ontological design for kosmos self-continuity: how entities externalize for recovery, backup, and federation. The current per-entity phoreta emission is a known deviation from established patterns. The federation doc prescribes one approach (sync-cursors, version vectors) that hasn't been implemented. A manifest-based approach has been explored in conversation but not grounded in the existing architecture. This session reads the existing prescriptive docs, examines the architectural patterns, works through the open questions, and arrives at a unified design. The output is a prescriptive doc + genesis entity definitions — not code.*

---

## Architectural Principle — Discovery Before Prescription

The prescriptive principle says docs describe the state we want. But before we can prescribe, we must understand what the right prescription IS. Two prescriptive designs exist for this space — the federation doc and the manifest concept — and they diverge. Neither is implemented. Both may be partially right.

This session works through the ontological questions to find the coherent design that serves all use cases. The methodology: read, articulate, synthesize, prescribe. Code comes later, in a follow-up prompt.

From KOSMOGONIA:

> **Actuation = Reconciliation.** Kosmos never directly manipulates substrate. Intent lives in the graph. Actuality lives in the substrate. Between them stands the reconciler.

> **Phoreta** — φορητά — Carrier — signed bundle for federation transport.

> **Emission (ekthesis)** is how kosmos configuration reaches the substrate.

The question: is externalization reconciliation, emission, or something else? The answer determines where the design lives and what patterns it follows.

---

## Methodology — DDD + TDD

This work follows **Doc → Test → Build → Verify**, non-negotiably.

This prompt is the **pre-Doc** phase: discovering what the doc should say. The output is:
1. A revised or new prescriptive doc describing the unified externalization design
2. Genesis entity definitions (eide, desmoi) for the ontological primitives
3. A follow-up implementation prompt (following the standard template) that builds against the doc

No code is written in this session. The discovery must complete before implementation begins.

---

## Current State

### What Exists — Prescriptive Docs

| Doc | What It Prescribes | Status |
|-----|-------------------|--------|
| `docs/explanation/federation.md` | Substrate reconciliation for multi-device sync. Sync-cursors with version vectors. One reconciler (`reconciler/substrate`). Continuous sync via data-channels. Phoreta as carrier format. | Not implemented. Prescribes sync-cursor, conflict resolution, channel transport. |
| `genesis/KOSMOGONIA.md` | Reconciler pattern (sense/compare/act). Phoreta as "carrier" (glossary). Emission as how kosmos reaches substrate. Remote substrate = "entity synced, phoreta applied across federation." | Constitutional root. |

### What Exists — Implementation

| Component | Location | Status |
|-----------|----------|--------|
| Per-entity emission reflexes | `genesis/hypostasis/reflexes/phoreta-emission.yaml` | Working but deviates: no reconciler, no sync-cursor, no oikos scope |
| Content-addressed phoreta storage | `crates/kosmos/src/phoreta.rs` | Working — sound storage layer |
| Entity content hashes | `crates/kosmos/src/graph.rs` | Working — BLAKE3 on arise/update |
| Recovery workarounds | `host.rs`, `rest.rs`, `main.rs`, `kosmos.ts` | Working but hacky: `decrypt_phoreta_entities`, `adopt_orphan_credentials`, schema bypass |
| `emit-phoreta` stoicheion | `steps.rs` | Working — emits single entity to store |
| Phoreta import | `phoreta.rs` — `import_from_index()` | Working — called at bootstrap |
| 50+ phoreta tests | `tests/phoreta_lifecycle.rs` | Passing |

### What Exists — Genesis Entities

| Entity | Location | Role |
|--------|----------|------|
| `eidos/phoreta` | `genesis/hypostasis/eide/hypostasis.yaml` | Bundle format definition |
| `praxis/hypostasis/emit-phoreta` | `genesis/hypostasis/praxeis/hypostasis.yaml` | Single-entity emission |
| `praxis/hypostasis/import-phoreta` | Same | Bundle import |
| `praxis/hypostasis/export-phoreta` | Same | Multi-entity export |
| `eidos/sync-cursor` | `genesis/politeia/` (if exists) | Prescribed in federation doc |
| `eidos/sync-conflict` | `genesis/politeia/` (if exists) | Prescribed in federation doc |
| `desmos/federates-with` | `genesis/politeia/` (if exists) | Prescribed in federation doc |

### The Gaps and Tensions

**Tension 1: Reconciler vs reflexes.** The federation doc prescribes a reconciler (`reconciler/substrate`). The current phoreta uses reflexes (fire-and-forget emission on mutation). KOSMOGONIA says reconciliation is the pattern for actuation. But emission (ekthesis) is also an established pattern — and it's one-way, not sense/compare/act. Which pattern fits externalization?

**Tension 2: Version vectors vs content hashes.** The federation doc tracks change via version numbers (`local_version: 147`). But content hashing is a constitutional pillar (T3). Version numbers say WHEN something changed. Content hashes say WHETHER two things are the same. Both exist in the system — which is primary for externalization?

**Tension 3: Continuous vs periodic.** The federation doc says "changes flow continuously as they happen." The manifest concept implies periodic flush. The user noted streaming doesn't apply to all federation cases. What's the right frequency model?

**Tension 4: Where does this live?** Current phoreta is in hypostasis (identity). Federation doc puts sync in politeia (governance). Neither may be right for the general externalization concern. What topos owns the kosmos's self-continuity?

**Tension 5: Oikos manifest — new concept or existing concept?** The oikos-manifest (root hash summarizing oikos state) isn't in any existing doc. It emerged from conversation. Is it the right abstraction? Does it subsume the sync-cursor, complement it, or is it unnecessary?

**Tension 6: What IS externalization?** Phoreta names the artifact (carried things). Emission names the act (writing to chora). Reconciliation names the pattern (sense/compare/act). Self-continuity names the purpose. The concept doesn't have a clear ontological home yet.

---

## Use Cases to Ground the Design

The design must serve all of these. If it can't, it's incomplete.

**Recovery**: DB wiped. Mnemonic entered. Everything comes back. No workaround code.

**Backup**: Ongoing protection against data loss. Entities written to durable storage. Content that was in the graph can be restored.

**Self-sync**: Same prosopon, two devices. Changes on laptop appear on phone. Same identity, full visibility.

**Oikos federation**: Shared oikos between prosopa. Changes in the shared space propagate to members. Scoped by oikos membership.

**Topos distribution**: Commons oikos distributes topos-prod packages to members. Same mechanism as entity sync.

---

## Questions to Resolve

Work through these in order. Each builds on the prior.

### Q1: Is externalization reconciliation or emission?

Read KOSMOGONIA's reconciler pattern (§Reconciler Pattern, §Actuation = Reconciliation) and emission pattern (§Ekthesis). Read the federation doc's reconciler design. Read how existing substrates (compute, storage, DNS) use the reconciler.

The question: does externalization have a "sense" step? Reconciliation senses actual state — is the process running? Is the DNS record correct? What would "sensing" mean for externalization — checking if the phoreta store has the latest state? Or is externalization purely write (emission) with no sense step?

### Q2: What tracks change — versions, hashes, or both?

Read how `graph.rs` computes content hashes. Read the federation doc's sync-cursor model. Read how the existing phoreta index works (`latest_hash`, `since_version`).

Content hashes give O(1) "has this entity changed?" — compare hashes. Version numbers give O(1) "what changed since last sync?" — filter by version > cursor. These serve different questions. Does the design need both? Can one subsume the other?

### Q3: Does the oikos need a manifest entity?

The oikos-manifest concept: a single entity summarizing all entities that exist-in an oikos, with their content hashes. Root hash = oikos state fingerprint. Enables O(1) "has this oikos changed?" and manifest-diff for delta computation.

Is this the right abstraction? Git has tree objects (sorted name → hash). IPFS has root CIDs. Both are content-addressed systems with root hashes. Does kosmos need the same? Or does the sync-cursor (tracking version position) make this unnecessary?

### Q4: What's the right frequency model?

Continuous (every mutation triggers externalization), periodic (batch at intervals), priority-triggered (some mutations trigger immediately, others batch), or on-demand (explicit backup action)?

The federation doc says continuous. The manifest concept implies periodic. The user noted that urgency varies by eidos. What frequency model serves all use cases without over-engineering?

### Q5: Where does this live in the topos structure?

Hypostasis owns identity (kleidoura, credentials, prosopon). Politeia owns governance (oikos, attainments). The federation doc puts sync tracking in politeia. Emission lives conceptually in ekthesis (emission.rs).

Does externalization need its own topos? Is it a facet of an existing topos? Is it a cross-cutting concern that multiple topoi participate in?

### Q6: What's the relationship between local externalization and federation?

Recovery writes to local filesystem. Federation writes to peer devices via data-channels. Are these the same act with different destinations? Or are they fundamentally different operations that happen to use the same carrier format (phoreta)?

The federation doc says: "There is ONE kosmos... actualized across multiple substrates." Local phoreta store is one actualization. Remote peer is another. If so, both are substrate reconciliation — same mechanism.

---

## Files to Read

### Constitutional root
- `genesis/KOSMOGONIA.md` — archai, substrates, reconciler pattern, emission, phoreta glossary entry

### Existing federation design
- `docs/explanation/federation.md` — sync-cursor, reconciler/substrate, continuous sync, conflict resolution

### Existing phoreta implementation
- `crates/kosmos/src/phoreta.rs` — structs, storage, encryption, import, index
- `genesis/hypostasis/reflexes/phoreta-emission.yaml` — per-entity triggers and reflexes
- `genesis/hypostasis/praxeis/hypostasis.yaml` — emit, import, export praxeis
- `genesis/hypostasis/eide/hypostasis.yaml` — phoreta eidos definition

### Substrate patterns (for reference)
- `crates/kosmos/src/host.rs` — reconciler dispatch, mode resolution, `host.reconcile()`
- `genesis/dynamis/reconcilers/` — transition table format
- Any substrate that has manifest/sense/unmanifest (DNS, process, storage)

### Content hash system
- `crates/kosmos/src/crypto.rs` — BLAKE3 hashing, canonical JSON
- `crates/kosmos/src/graph.rs` — content_hash computed on arise/update

### Recovery workarounds (what to dissolve)
- `crates/kosmos/src/host.rs` — `decrypt_phoreta_entities()`
- `app/src-tauri/src/main.rs` — `adopt_orphan_credentials`
- `app/src/stores/kosmos.ts` — `recoverKeyring` flow

### Dwelling context
- `docs/explanation/dwelling/dwelling.md` — the five dimensions of dwelling

---

## Sequenced Work

### Phase 1: Read and Articulate

**Goal:** Understand what exists and identify where the designs agree and diverge.

1. Read KOSMOGONIA: substrates table, reconciler pattern, emission, phoreta glossary
2. Read federation doc: full document, noting prescribed entities, patterns, assumptions
3. Read existing phoreta code: structs, storage model, emission step, import path
4. Read one substrate's full reconciler cycle (e.g., DNS or process) for pattern reference
5. Articulate: where do the federation doc and manifest concept agree? Where do they diverge?

**Phase 1 Complete When:**
- [ ] All source material read
- [ ] Agreement/divergence points articulated in phaseis or notes

### Phase 2: Work Through the Questions

**Goal:** Resolve the six open questions through discourse. Express thinking as phaseis.

Work through Q1-Q6 in order. For each:
1. State the question
2. Consider what existing architecture suggests
3. Consider what the use cases require
4. Arrive at a position
5. Express the position and reasoning

Not every question will have a clean answer. Mark unresolved questions as such — they become open questions in the prescriptive doc.

**Phase 2 Complete When:**
- [ ] Each question has a position or is explicitly marked unresolved
- [ ] Positions are grounded in KOSMOGONIA and use cases, not invented from scratch

### Phase 3: Synthesize the Design

**Goal:** Write the unified prescriptive design — a doc that supersedes or revises the federation doc to cover all use cases.

The doc should:
- Ground in KOSMOGONIA principles
- Define the ontological entities (eide, desmoi) the design needs
- Describe the mechanism for each use case (recovery, backup, self-sync, federation)
- Be clear about what's implemented now vs. what's future
- Identify what the first implementation step is (likely: recovery)

Write the doc to `docs/explanation/` or `docs/reference/` — determine the right Diataxis quadrant during the work.

**Phase 3 Complete When:**
- [ ] Prescriptive doc written
- [ ] Genesis entity definitions (YAML) drafted for new eide/desmoi
- [ ] Federation doc either revised or marked for revision with specific changes noted
- [ ] Relationship to existing phoreta code clarified (what stays, what goes, what changes)

### Phase 4: Draft the Implementation Prompt

**Goal:** Write a follow-up PROMPT-*.md that implements the first use case (recovery) against the prescriptive doc.

Follow the standard prompt template (PROMPT-TEMPLATE.md). The implementation prompt should:
- Reference the prescriptive doc as its specification
- Follow DDD+TDD (tests before implementation)
- Include the clean-break removal of workaround code
- Be scoped to recovery only — federation implementation is a separate prompt

**Phase 4 Complete When:**
- [ ] Implementation prompt written following PROMPT-TEMPLATE.md
- [ ] Prompt references the prescriptive doc, not ad-hoc design decisions
- [ ] Prompt is self-contained and executable by a fresh session

---

## Success Criteria

**Overall Complete When:**
- [ ] Open questions Q1-Q6 have positions or are explicitly unresolved
- [ ] Prescriptive doc written and placed in docs/
- [ ] Genesis entity definitions drafted
- [ ] Implementation prompt written following standard template
- [ ] No code written — this session is design only
- [ ] The design serves all five use cases (recovery, backup, self-sync, federation, topos distribution)
- [ ] The design traces to KOSMOGONIA principles, not invented patterns

---

## What This Enables

A coherent ontological foundation for kosmos self-continuity — recovery, backup, and federation — grounded in established architectural patterns rather than ad-hoc workarounds. The follow-up implementation prompt builds on solid ground.

---

## What Does NOT Change

1. **Content-addressed storage layer** — BLAKE3 hashing, phoreta file format, encryption, signing
2. **Phoreta as carrier format** — the bundle struct may evolve but the concept is constitutional
3. **exists-in bond semantics** — oikos membership
4. **Entity content hashes** — computed on arise/update
5. **The five constitutional axioms** — composition, authority, traceability, self-grounding, adequacy

---

*Traces to: KOSMOGONIA §Actuation = Reconciliation, §Reconciler Pattern; T3 (cache-driven); T4 (four reconciliation loops); T11 (reconciliation is substrate-universal); T24 (recovery-as-federation); docs/explanation/federation.md*
