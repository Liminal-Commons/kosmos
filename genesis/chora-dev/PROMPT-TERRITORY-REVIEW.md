# Territory Review — Implementation Handoffs, Designs, and Proposals

*Prompt for a collaborative discussion session in Claude Code.*

*This is not an execution prompt. It's a structured conversation. We're going to walk through every non-diataxis document in docs/ — implementation handoffs, architecture docs, design docs, proposals, and research — and for each territory they describe, determine: what's the desired state? What's the current state? Is this document still serving us, or is it contextual poison?*

---

## Why This Review

The diataxis documentation (reference, explanation, tutorial, how-to) has been restructured and audited. But five other directories exist under docs/ that predate or sit outside diataxis:

- `docs/architecture/` — 4 files (rendering gaps, next steps, thyra rendering, overview)
- `docs/design/` — 9 files (topos designs, distributed architecture, crypto, interpreter)
- `docs/implementation/` — 8 files (7 handoffs + README index)
- `docs/proposal/` — 6 files (genesis restructure, generation, signing, etc.)
- `docs/research/` — 1 file (distributed architecture research)

**28 files total.** Some describe work that's been completed and digested into diataxis. Some describe work that hasn't started. Some describe outmoded patterns and are actively misleading. Some prescribe a desired future that we may or may not still want.

---

## Prior Audit Findings

A structural audit has already been performed. Here's the starting position:

### Already Digested (content exists in diataxis — candidates for deletion)

| File | Why It's Digested |
|------|-------------------|
| `architecture/THYRA-RENDERING.md` | Content across mode-reference, widget-system, render-spec-authoring, two-phase-bindings |
| `design/HOMOICONIC-REACTIVE-SYSTEM.md` | Its own header says "see diataxis". Content in 4 diataxis docs. |
| `design/THYRA-INTERPRETER.md` | Marked "Implemented". Content in 5+ diataxis docs. |
| `design/render-spec-generation.md` | Generation pipeline documented in reference/generation/ |
| `proposal/homoiconic-reconciliation.md` | Marked "IMPLEMENTED". Content in 4 diataxis docs. |

### Outmoded (poisoned by dissolved patterns)

| File | Problem |
|------|---------|
| `architecture/overview.md` | Rendering section references dissolved render-type-to-renderer chain, panels/regions. Some non-rendering content (klimax, dwelling, coherence) may not be elsewhere. |
| `implementation/CHORA-HANDOFF-RENDER-SPECS.md` | Body still describes outmoded render-type-to-renderer pipeline. Diataxis docs cover the actual rendering system. |
| `implementation/CHORA-HANDOFF-VOICE-AUTHORING.md` | References dissolved VoiceAuthoringLayout.tsx, panels, regions. Voice authoring is implemented. |
| `implementation/CHORA-HANDOFF-OIKOS-DEV.md` | Section 4 references render-type pattern. Rest may be current. |

### Current (19 files — not digested, not outmoded, but not in diataxis)

These describe work that's forward-looking, in-progress, or outside the four diataxis quadrants.

---

## Discussion Framework

For each territory, we want to answer:

1. **What's the desired state?** — What do we actually want this part of the system to be? Has the vision changed since the doc was written?
2. **What's the current state?** — What exists today in code and genesis?
3. **What's the gap?** — Where does current fall short of desired?
4. **Is this doc serving us?** — Is it prescribing the right future? Is it misleading? Should its content live somewhere else (diataxis, DESIGN.md, archive)?
5. **What's the disposition?** — Delete, archive, digest into diataxis, rewrite, or keep as-is?

---

## Territory 1: Presentation — Rendering, Modes, Thyra Interpreter

**Documents:**
- `architecture/THYRA-RENDERING.md` — **DIGESTED** — comprehensive but superseded by diataxis
- `architecture/RENDERING-GAPS.md` — **CURRENT** — living gap tracker
- `architecture/THYRA-NEXT-STEPS.md` — **CURRENT** — roadmap (graph discovery, substrates, reconciliation wiring)
- `design/THYRA-INTERPRETER.md` — **DIGESTED** — marked "Implemented"
- `implementation/CHORA-HANDOFF-RENDER-SPECS.md` — **OUTMODED** — describes dissolved pipeline

**Known current state:**
- Mode system: singleton/collection/compound, fully implemented
- Widget interpreter: 38+ widgets, two-phase binding, generic dispatch
- Render-spec generation: proven via manteia (Phase 4 empirical)
- Graph-driven discovery: NOT implemented — modes carry literal render_spec_id
- Substrates: voice complete, WebRTC and Phaser are stubs

**Questions for discussion:**
- RENDERING-GAPS.md and THYRA-NEXT-STEPS.md serve a roadmap function. Is that function better served by issues, by a diataxis doc, or by keeping these as-is?
- The gap tracker format (design says X, implementation does Y) — is this worth maintaining, or does the DDD audit cycle (reference docs are prescriptive, system has gaps) make it redundant?

---

## Territory 2: Voice

**Documents:**
- `design/VOICE-OIKOS-DESIGN.md` — **CURRENT** — partially implemented (Phase 3B)
- `implementation/CHORA-HANDOFF-VOICE-AUTHORING.md` — **OUTMODED** — references dissolved UI patterns

**Known current state:**
- Voice capture: fully implemented (voice_capture.rs, whisper-server.py, voice.rs, capture.ts)
- Mode-actuality lifecycle: voice mode triggers actuality-mode/voice
- Accumulation entity, clarification pipeline: defined in genesis
- Three modes: text-composing, voice-composing, voice-minimal

**Questions for discussion:**
- Voice is partially implemented. Is VOICE-OIKOS-DESIGN.md still prescribing the right target?
- The handoff is outmoded — but does the design doc carry forward as the desired state, or has the vision shifted?

---

## Territory 3: Distributed Architecture / Infrastructure

**Documents:**
- `design/DISTRIBUTED-ARCHITECTURE.md` — **CURRENT** — 872 lines, comprehensive
- `design/CRYPTOGRAPHIC-TOPOLOGY.md` — **CURRENT** — key derivation, visibility=reachability
- `implementation/CHORA-HANDOFF-DEPLOYMENT.md` — **CURRENT** — deployment desmoi
- `implementation/CHORA-HANDOFF-KOSMOS-ONTOLOGY.md` — **CURRENT** — soma infrastructure eide
- `research/DISTRIBUTED-ARCHITECTURE-RESEARCH.md` — **CURRENT** — research spike

**Known current state:**
- soma-client: exists, handles auth tokens, offline queueing
- Session tokens: parousia_id, DwellingContext, sovereignty as attainment
- Federation: kosmos-mcp has REST/WebSocket server, discovery, reconnection
- Deployment entities: defined in genesis (dynamis), not wired to infrastructure
- Node/service-instance eide: defined in proposal, not in genesis
- Crypto: crates/kosmos/src/crypto.rs exists, key derivation scope unclear

**Questions for discussion:**
- This is the largest unbuilt territory. Is DISTRIBUTED-ARCHITECTURE.md still the right vision?
- Deployment and infrastructure ontology handoffs both wait on each other. What's the actual sequencing?
- CRYPTOGRAPHIC-TOPOLOGY.md is ambitious (BIP-39, full key hierarchy). Is that still the target, or has the scope narrowed?

---

## Territory 4: MCP / Binary Architecture

**Documents:**
- `implementation/CHORA-HANDOFF-MCP-CONSOLIDATION.md` — **CURRENT** — merge into single binary

**Known current state:**
- kosmos-mcp: separate binary, spawned per Claude Code window
- SQLite single-writer conflicts between concurrent sessions
- Bridge module exists (crates/kosmos-mcp/src/bridge.rs)

**Questions for discussion:**
- Is single-binary consolidation still the right target? Or has the architecture shifted toward server+client?
- The SQLite conflict is a real pain point. What's the desired resolution — single process, WAL mode, or something else?

---

## Territory 5: Topos Development Experience

**Documents:**
- `implementation/CHORA-HANDOFF-OIKOS-DEV.md` — **PARTIALLY OUTMODED** — Section 4 stale, rest may be current
- `design/CHORA-DEV-OIKOS-DESIGN.md` — **CURRENT** — self-building system topos
- `implementation/CHORA-HANDOFF-SENSE-BODY.md` — **CURRENT** — body-schema extension

**Known current state:**
- 8 development praxeis: loaded, executing
- 4 palette discovery praxeis: loaded
- Cursor/notification infrastructure: complete
- project-topos (projection without emission): not implemented
- Sense-body: Phase 1 (notifications) complete, Phases 2-3 pending
- Chora-dev topos (self-building): kosmos-side ontology complete, stoicheia pending

**Questions for discussion:**
- The topos completeness ladder (Defined → Loaded → Projected → Embodied → Surfaced → Afforded) — is this still the framework?
- Sense-body is about Claude's embodiment. With the trajectory toward governed inference, how does sense-body relate to inference context composition?
- CHORA-DEV-OIKOS-DESIGN.md describes kosmos building itself. Is this the next frontier, or is there prerequisite work?

---

## Territory 6: Reactive System

**Documents:**
- `design/HOMOICONIC-REACTIVE-SYSTEM.md` — **DIGESTED** — header points to diataxis
- `proposal/homoiconic-reconciliation.md` — **DIGESTED** — marked "IMPLEMENTED"

**Known current state:**
- Reconciler engine: generic host.reconcile()
- Reflex engine: bonded trigger → reflex → action
- Actuality dispatch: schema-driven, generated dispatch table
- Daemon loop: exists (daemon_loop.rs)

**Questions for discussion:**
- Both docs are fully digested. Straightforward deletion?
- Any content in either that isn't captured in the 4 diataxis reactivity docs?

---

## Territory 7: Genesis Structure

**Documents:**
- `proposal/genesis-restructure.md` — **CURRENT** — 8-phase plan, Phase 2 marked complete
- `proposal/single-stream-genesis.md` — **CURRENT** — flat-by-eidos migration

**Questions for discussion:**
- Are these two proposals complementary or competing?
- Genesis restructure Phase 2 is complete — what's the status of the other phases?
- Single-stream genesis (flat by eidos instead of by topos) — is this still desired?

---

## Territory 8: Generation / Governed Inference

**Documents:**
- `design/render-spec-generation.md` — **DIGESTED** — in reference/generation/
- `proposal/governed-generation-integration.md` — **CURRENT** — extends generation with evaluation criteria

**Known current state:**
- Render-spec generation: proven, 7 tests, empirical verdict TRUE
- Governed envelope pattern: content + verdict + provenance
- Evaluation criteria: proposed but not integrated into the core pipeline

**Questions for discussion:**
- render-spec-generation.md is digested — delete?
- governed-generation-integration.md extends the generation pipeline. Is this the next step for generation, or is extending to other element types (eidos, praxis, desmos) the priority?

---

## Territory 9: Social / Multi-User

**Documents:**
- `design/AGORA-TERRITORY-DESIGN.md` — **CURRENT** — assembly/territory modes, unbuilt
- `design/WEBRTC-OIKOS-DESIGN.md` — **CURRENT** — video call entities, unbuilt
- `proposal/cross-circle-coordination.md` — **CURRENT** — pragma eidos, draft

**Known current state:**
- WebRTC substrate: stub
- Phaser substrate: stub
- No agora implementation
- No cross-circle coordination

**Questions for discussion:**
- These are the most forward-looking docs. Are they still prescribing the right vision?
- Do they depend on distributed architecture (Territory 3) being in place first?

---

## Territory 10: Security / Signing

**Documents:**
- `proposal/session-signing-capability.md` — **CURRENT** — extend SessionToken for MCP signing

**Questions for discussion:**
- Does this overlap with CRYPTOGRAPHIC-TOPOLOGY.md (Territory 3)?
- Is MCP signing a prerequisite for federation, or independent?

---

## Architecture Overview

**Documents:**
- `architecture/overview.md` — **OUTMODED** — rendering sections poisoned, but contains broader architecture content

**Questions for discussion:**
- The non-rendering content (klimax, dwelling model, coherence invariants, identity patterns) — is it captured in diataxis explanation/architecture/?
- Should the valuable parts be extracted into explanation docs, or does the overall overview serve a purpose that diataxis quadrants don't?

---

## Disposition Options

For each territory, after discussion, we'll assign one of:

| Disposition | Meaning |
|-------------|---------|
| **Delete** | Content is digested or outmoded. Remove the file. |
| **Archive** | Historical value but no longer serves development. Move to archive/. |
| **Digest** | Extract valuable content into diataxis, then delete or archive the original. |
| **Rewrite** | The territory is right but the doc is wrong. Rewrite to prescribe current desired state. |
| **Keep** | The doc serves a purpose that diataxis doesn't cover (roadmap, design for unbuilt work, research). Keep as-is. |
| **Promote** | The doc should become a topos DESIGN.md (where topos designs naturally live). |

---

## After the Review

Once we've discussed each territory, the outcomes should be:

1. A clear disposition for all 28 files
2. An updated understanding of desired state for each territory
3. Identification of any docs that need rewriting vs deletion
4. Clarity on whether architecture/, design/, implementation/, proposal/, research/ should continue to exist as categories, be dissolved, or be reorganized

*This review is about alignment — making sure every document in the repository is either serving the desired state or being removed. Dead docs, like dead code, are contextual poison.*
