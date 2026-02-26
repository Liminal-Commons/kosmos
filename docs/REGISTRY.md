# Documentation Registry

*The prescriptive map. What documentation should exist, how it maps to code, and where reality has gaps.*

**Purpose:** This registry is the sensing instrument for the development reconciliation loop. It prescribes what docs SHOULD exist, organized by topos and cross-cutting pattern. Where a doc is listed as MISSING, that is development scope. Where a doc exists but diverges from code, that is a gap.

**Relationship to index.md:** `docs/index.md` is the reader-facing Diataxis navigation portal — organized by learning intent. This registry organizes by topos — the domain of knowledge — and tracks alignment. The gap between this registry and index.md drives documentation development.

**The prescriptive principle:** Docs describe the state we WANT. When code doesn't match a doc, the code has a gap. When this registry lists a doc as MISSING, the doc system has a gap.

---

## Topos Documentation

Each topos with active documentation beyond DESIGN.md. DESIGN.md is the canonical design rationale — always in `genesis/{topos}/DESIGN.md`.

### arche — The Grammar of Being

Foundation: eide, desmoi, stoicheia, the bootstrap sequence.

| Role | Doc | Status |
|------|-----|--------|
| Reference | [bootstrap-genesis.md](reference/genesis/bootstrap-genesis.md) | CURRENT |
| Reference | [manifest-schema.md](reference/genesis/manifest-schema.md) | CURRENT |
| Reference | [directory-conventions.md](reference/genesis/directory-conventions.md) | CURRENT |
| Reference | [manifest-validation.md](reference/genesis/manifest-validation.md) | CURRENT |
| Reference | [constituent-elements.md](reference/elements/constituent-elements.md) | CURRENT |
| Reference | [composite-patterns.md](reference/elements/composite-patterns.md) | CURRENT |
| Reference | [stoicheia-wasm.md](reference/elements/stoicheia-wasm.md) | CURRENT |
| Explanation | [genesis/index.md](explanation/genesis/index.md) | CURRENT |
| Explanation | [archai.md](explanation/genesis/archai.md) | CURRENT |
| Explanation | [topoi.md](explanation/genesis/topoi.md) | CURRENT |
| Explanation | [bootstrap.md](explanation/genesis/bootstrap.md) | CURRENT |
| Explanation | [klimax/index.md](explanation/klimax/index.md) | CURRENT |
| Tutorial | [create-a-topos.md](tutorial/foundations/create-a-topos.md) | CURRENT |
| How-to | [topos-development.md](how-to/topos-development/topos-development.md) | CURRENT |

### demiurge — Composition

How entities arise through definition. Typos, slots, fill patterns, composition pipeline.

| Role | Doc | Status |
|------|-----|--------|
| Reference | [composition.md](reference/composition/composition.md) | CURRENT |
| Reference | [typos-composition.md](reference/composition/typos-composition.md) | CURRENT |
| Reference | [expression-evaluator.md](reference/composition/expression-evaluator.md) | CURRENT |
| Explanation | [clarification-as-composition.md](explanation/composition/clarification-as-composition.md) | CURRENT |
| Explanation | [creative-journey-pattern.md](explanation/composition/creative-journey-pattern.md) | CURRENT |
| How-to | [compose-artifact.md](how-to/composition/compose-artifact.md) | CURRENT |
| How-to | [use-generation.md](how-to/composition/use-generation.md) | CURRENT |
| How-to | [crystallize-theoria.md](how-to/composition/crystallize-theoria.md) | CURRENT |
| How-to | [create-note.md](how-to/composition/create-note.md) | CURRENT |

### thyra — Presentation

How topoi become spatially present. Modes, render-specs, widgets, layout, bindings.

| Role | Doc | Status |
|------|-----|--------|
| Reference | [mode-reference.md](reference/presentation/mode-reference.md) | CURRENT |
| Reference | [render-spec-resolution.md](reference/presentation/render-spec-resolution.md) | PRESCRIPTIVE |
| Reference | [widget-system.md](reference/presentation/widget-system.md) | VERIFIED |
| Reference | [render-spec-authoring.md](reference/presentation/render-spec-authoring.md) | CURRENT |
| Explanation | [thyra-topos.md](explanation/presentation/thyra-topos.md) | CURRENT |
| Explanation | [modes-and-topoi.md](explanation/presentation/modes-and-topoi.md) | CURRENT |
| Explanation | [modes-as-topoi.md](explanation/presentation/modes-as-topoi.md) | CURRENT |
| Explanation | [artifact-based-modes.md](explanation/presentation/artifact-based-modes.md) | CURRENT |
| Explanation | [entity-overlays.md](explanation/presentation/entity-overlays.md) | CURRENT |
| How-to | [mode-development.md](how-to/presentation/mode-development.md) | CURRENT |
| How-to | [voice-authoring.md](how-to/presentation/voice-authoring.md) | CURRENT |
| How-to | [form-based-mode.md](how-to/presentation/form-based-mode.md) | CURRENT |
| How-to | [create-artifact-mode.md](how-to/presentation/create-artifact-mode.md) | CURRENT |
| Tutorial | [create-a-mode.md](tutorial/presentation/create-a-mode.md) | CURRENT |
| Design | [THYRA-INTERPRETER.md](design/THYRA-INTERPRETER.md) | CURRENT |
| Design | [VOICE-TOPOS-DESIGN.md](design/VOICE-TOPOS-DESIGN.md) | CURRENT |

### manteia — Generation

Governed inference, embedding, model tiers, the generative spiral.

| Role | Doc | Status |
|------|-----|--------|
| Reference | [generation.md](reference/generation/generation.md) | CURRENT |
| Explanation | [generative-spiral.md](explanation/generation/generative-spiral.md) | CURRENT |
| Explanation | [schema-enforcement.md](explanation/generation/schema-enforcement.md) | CURRENT |
| Tutorial | [generating-instead-of-writing.md](tutorial/generation/generating-instead-of-writing.md) | CURRENT |

### politeia — Authorization

How authority flows. Attainments, dwelling context, sovereignty.

| Role | Doc | Status |
|------|-----|--------|
| Reference | [attainment-authorization.md](reference/authorization/attainment-authorization.md) | CURRENT |
| Reference | [surface-contracts.md](reference/authorization/surface-contracts.md) | CURRENT |
| Explanation | [commitment-boundary.md](explanation/architecture/commitment-boundary.md) | CURRENT |

### hypostasis — Identity

Cryptographic identity, sessions, prosopon.

| Role | Doc | Status |
|------|-----|--------|
| Reference | [session-identity.md](reference/authorization/session-identity.md) | CURRENT |
| Design | [CRYPTOGRAPHIC-TOPOLOGY.md](design/CRYPTOGRAPHIC-TOPOLOGY.md) | CURRENT |

### logos — Expression

Phasis lifecycle, threading, stances.

| Role | Doc | Status |
|------|-----|--------|
| Reference | [phasis-entity.md](reference/domain/phasis-entity.md) | CURRENT |
| Reference | [phasis-workspace.md](reference/domain/phasis-workspace.md) | CURRENT |
| Tutorial | [first-phasis.md](tutorial/foundations/first-phasis.md) | CURRENT |

### oikos — Dwelling

Where prosopa dwell. Sessions, notes, personal knowledge.

| Role | Doc | Status |
|------|-----|--------|
| Explanation | [oikos/index.md](explanation/oikos/index.md) | CURRENT |
| Explanation | [dwelling.md](explanation/dwelling/dwelling.md) | CURRENT |

### chora-dev — Development Topos

Meta-topos for browsing the ontology through thyra.

| Role | Doc | Status |
|------|-----|--------|
| Design | [CHORA-DEV-TOPOS-DESIGN.md](design/CHORA-DEV-TOPOS-DESIGN.md) | DRAFT |

---

## Cross-Cutting Patterns

Docs that span multiple topoi. Organized by the pattern they document.

### Reactivity

How the kosmos responds. Triggers, reflexes, reconciliation, daemons, signals.

| Role | Doc | Status | Topoi |
|------|-----|--------|-------|
| Reference | [reactive-system-reference.md](reference/reactivity/reactive-system-reference.md) | CURRENT | dynamis, soma, thyra |
| Reference | [reconciliation.md](reference/reactivity/reconciliation.md) | CURRENT | dynamis |
| Reference | [daemon-runner.md](reference/reactivity/daemon-runner.md) | CURRENT | dynamis, ergon |
| Reference | [actualization-pattern.md](reference/reactivity/actualization-pattern.md) | CURRENT | dynamis, soma |
| Reference | [signal-reference.md](reference/reactivity/signal-reference.md) | CURRENT | soma, thyra |
| Explanation | [reactive-system.md](explanation/reactivity/reactive-system.md) | CURRENT | dynamis, soma |
| Explanation | [homoiconic-reactive-architecture.md](explanation/architecture/homoiconic-reactive-architecture.md) | CURRENT | dynamis, thyra |
| Explanation | [reconciler-pattern.md](explanation/reactivity/reconciler-pattern.md) | CURRENT | dynamis |
| How-to | [define-custom-triggers.md](how-to/reactivity/define-custom-triggers.md) | CURRENT | dynamis |
| How-to | [wire-reconciliation-cycle.md](how-to/reactivity/wire-reconciliation-cycle.md) | CURRENT | dynamis |
| How-to | [create-daemon.md](how-to/reactivity/create-daemon.md) | CURRENT | dynamis, ergon |
| Tutorial | [create-your-first-reflex.md](tutorial/reactivity/create-your-first-reflex.md) | CURRENT | dynamis |
| Tutorial | [self-healing-entities.md](tutorial/reactivity/self-healing-entities.md) | CURRENT | dynamis, psyche |
| Design | [HOMOICONIC-REACTIVE-SYSTEM.md](design/HOMOICONIC-REACTIVE-SYSTEM.md) | DRAFT | dynamis |

### Visibility and Dwelling

Where prosopa dwell and what they can see. Bond-graph reachability, federation.

| Role | Doc | Status | Topoi |
|------|-----|--------|-------|
| Reference | [visibility-semantics.md](reference/dwelling/visibility-semantics.md) | PRESCRIPTIVE | politeia, oikos |
| Reference | [query-system.md](reference/query-system.md) | CURRENT | arche, oikos |
| Explanation | [federation.md](explanation/federation.md) | CURRENT | aither, propylon |
| Design | [DISTRIBUTED-ARCHITECTURE.md](design/DISTRIBUTED-ARCHITECTURE.md) | CURRENT | aither |

### Architecture

System-level understanding that spans topoi.

| Role | Doc | Status |
|------|-----|--------|
| Explanation | [architecture.md](explanation/architecture/architecture.md) | CURRENT |
| Explanation | [entity-as-source-of-truth.md](explanation/architecture/entity-as-source-of-truth.md) | CURRENT |
| Explanation | [two-phase-bindings.md](explanation/architecture/two-phase-bindings.md) | CURRENT |
| Analysis | [overview.md](architecture/overview.md) | CURRENT |
| Analysis | [THYRA-RENDERING.md](architecture/THYRA-RENDERING.md) | CURRENT |
| Analysis | [RENDERING-GAPS.md](architecture/RENDERING-GAPS.md) | CURRENT |
| Analysis | [THYRA-NEXT-STEPS.md](architecture/THYRA-NEXT-STEPS.md) | CURRENT |
| Tutorial | [first-praxis.md](tutorial/foundations/first-praxis.md) | CURRENT |

### Infrastructure

REST, MCP, WebSocket, substrates, deployment.

| Role | Doc | Status | Topoi |
|------|-----|--------|-------|
| Reference | [rest-api.md](reference/infrastructure/rest-api.md) | CURRENT | soma, aither |
| Reference | [substrate-integration.md](reference/infrastructure/substrate-integration.md) | CURRENT | soma, dynamis |
| Reference | [substrate-lifecycle.md](reference/infrastructure/substrate-lifecycle.md) | PRESCRIPTIVE | thyra, dynamis |
| Reference | [soma-client.md](reference/infrastructure/soma-client.md) | CURRENT | soma |
| Reference | [cryptographic-operations.md](reference/infrastructure/cryptographic-operations.md) | CURRENT | hypostasis |
| How-to | [operations.md](how-to/operations/operations.md) | CURRENT | — |
| How-to | [developer-onboarding.md](how-to/operations/developer-onboarding.md) | CURRENT | — |
| Reference | [chora-dev-patterns.md](reference/infrastructure/chora-dev-patterns.md) | CURRENT | — |

### Provenance

How authority and authenticity are recorded. Composition chains, signatures.

| Role | Doc | Status |
|------|-----|--------|
| Reference | [provenance-mechanism.md](reference/provenance/provenance-mechanism.md) | CURRENT |
| Reference | [authority-mechanism.md](reference/provenance/authority-mechanism.md) | CURRENT |
| Reference | [emission-reference.md](reference/provenance/emission-reference.md) | CURRENT |

### Domain Reference

Cross-topos reference maps.

| Role | Doc | Status |
|------|-----|--------|
| Reference | [topos-map.md](reference/domain/topos-map.md) | CURRENT |
| Reference | [topos-index.md](reference/domain/topos-index.md) | CURRENT |

---

## Impact Map

When code changes, which docs need review. Read column-first: "If I changed X, which docs must I check?"

### kosmos core (crates/kosmos/)

| Code Module | Docs That Depend On It |
|-------------|----------------------|
| `host.rs` | session-identity, rest-api, bootstrap-genesis, query-system, actualization-pattern, substrate-integration, provenance-mechanism, authority-mechanism, visibility-semantics |
| `graph.rs` | query-system, visibility-semantics |
| `bootstrap.rs` | bootstrap-genesis, manifest-validation, reactive-system-reference, provenance-mechanism, authority-mechanism |
| `topos.rs` | bootstrap-genesis, manifest-schema, manifest-validation |
| `nous.rs` | generation, typos-composition, actualization-pattern, substrate-integration |
| `credential.rs` | substrate-integration, attainment-authorization |
| `process.rs` | substrate-integration, actualization-pattern |
| `storage.rs` | substrate-integration, actualization-pattern |
| `dns.rs` | substrate-integration |
| `r2.rs` | substrate-integration |
| `reflex.rs` | reactive-system-reference, homoiconic-reactive-architecture |
| `signal.rs` | signal-reference, substrate-integration, actualization-pattern, rest-api, render-spec-authoring |
| `voice.rs` | voice-authoring, VOICE-TOPOS-DESIGN, rest-api |
| `daemon_loop.rs` | daemon-runner, reconciliation |
| `mode_dispatch.rs` | actualization-pattern, mode-development, substrate-lifecycle |
| `emission.rs` | emission-reference |
| `command_template.rs` | — |
| `dokimasia.rs` | manifest-validation |
| `crypto.rs` | cryptographic-operations, CRYPTOGRAPHIC-TOPOLOGY |
| `build.rs` | actualization-pattern |

### Interpreter (crates/kosmos/src/interpreter/)

| Code Module | Docs That Depend On It |
|-------------|----------------------|
| `composition.rs` | composition, typos-composition, provenance-mechanism, authority-mechanism, visibility-semantics, bootstrap-genesis |
| `steps.rs` | constituent-elements, session-identity, typos-composition, composition, query-system |
| `expr.rs` | expression-evaluator, typos-composition |
| `schema.rs` | composition, typos-composition |
| `mod.rs` | attainment-authorization |
| `wasm.rs` | stoicheia-wasm |
| `dynamis.rs` | stoicheia-wasm |
| `step_types.rs` | constituent-elements (generated — do not edit) |

### kosmos-mcp (crates/kosmos-mcp/)

| Code Module | Docs That Depend On It |
|-------------|----------------------|
| `rest.rs` | rest-api, session-identity |
| `lib.rs` | session-identity |
| `auth.rs` | session-identity, rest-api |
| `main.rs` | bootstrap-genesis, CONTRIBUTING |
| `http.rs` | daemon-runner, rest-api |
| `bridge.rs` | session-identity |
| `websocket.rs` | rest-api, soma-client |
| `connection.rs` | soma-client, DISTRIBUTED-ARCHITECTURE |
| `projection.rs` | session-identity |

### Thyra UI (app/src/)

| Code Module | Docs That Depend On It |
|-------------|----------------------|
| `lib/render-spec.tsx` | THYRA-INTERPRETER, THYRA-RENDERING, RENDERING-GAPS, mode-reference |
| `lib/bindings.ts` | THYRA-INTERPRETER, THYRA-RENDERING, mode-development, render-spec-authoring, mode-reference, two-phase-bindings |
| `lib/executor-context.tsx` | THYRA-INTERPRETER, two-phase-bindings |
| `lib/widgets/*` | THYRA-INTERPRETER, THYRA-RENDERING, mode-development, mode-reference |
| `lib/layout-engine.tsx` | THYRA-INTERPRETER, THYRA-RENDERING, mode-development, RENDERING-GAPS, render-spec-resolution |
| `lib/voice/*` | voice-authoring, VOICE-TOPOS-DESIGN |
| `lib/http-client.ts` | soma-client |
| `stores/kosmos.ts` | THYRA-INTERPRETER, rest-api, session-identity |
| `App.tsx` | session-identity |
| `components/UnlockScreen.tsx` | session-identity |
| `lib/substrates/*` | substrate-lifecycle, RENDERING-GAPS |

### Tauri (app/src-tauri/)

| Code Module | Docs That Depend On It |
|-------------|----------------------|
| `main.rs` | session-identity, soma-client, rest-api, bootstrap-genesis |
| `process.rs` | session-identity |

### Genesis

| Content | Docs That Depend On It |
|---------|----------------------|
| `genesis/KOSMOGONIA.md` | architecture, provenance-mechanism, authority-mechanism |
| `genesis/arche/*` | archai, composition |
| `genesis/spora/spora.yaml` | bootstrap-genesis, manifest-schema |
| `genesis/*/manifest.yaml` | bootstrap-genesis, manifest-schema, manifest-validation |
| `genesis/stoicheia-portable/*` | stoicheia-wasm, constituent-elements |
| `genesis/thyra/render-specs/*` | render-spec-authoring, mode-development, mode-reference |
| `genesis/thyra/entities/layout.yaml` | mode-development, modes-and-topoi |
| `genesis/thyra/modes/*` | actualization-pattern |
| `genesis/thyra/eide/widget.yaml` | widget-system, mode-development, mode-reference |
| `genesis/logos/*` | phasis-entity, first-phasis |
| `genesis/soma/eide/provider.yaml` | substrate-integration, actualization-pattern |
| `genesis/soma/entities/providers.yaml` | substrate-integration, actualization-pattern |
| `genesis/soma/reflexes/inference.yaml` | reactive-system-reference, actualization-pattern |
| `genesis/ergon/desmoi/trigger.yaml` | reactive-system-reference, define-custom-triggers |
| `genesis/dynamis/reconcilers/*` | reconciliation, reconciler-pattern, self-healing-entities |
| `genesis/demiurge/praxeis/*` | use-generation, compose-artifact |
| `genesis/manteia/*` | use-generation, generation |
| `justfile` | CONTRIBUTING, operations |

---

## Gap Register

Known divergences between prescribed state and actual state.

### Visibility Gaps (from visibility-semantics.md)

| Gap | Severity | Description |
|-----|----------|-------------|
| `dissolve_entity` no visibility | MEDIUM | Deletion bypasses visibility — planned Session 5 |
| `create_bond` no visibility | MEDIUM | Bond creation bypasses visibility — planned Session 5 |
| MCP tool listing no oikos scope | MEDIUM | Praxeis not filtered by visibility — planned Session 5 |
| Genesis entities no `exists-in` bonds | MEDIUM | Transitional "no exists-in = universal" rule — planned Session 6 |

### Documentation Structure Gaps

| Gap | Severity | Description |
|-----|----------|-------------|
| No Thyra widget development docs | LOW | Missing: widget development guide for extending the widget vocabulary |

### Closed Gaps

| Gap | Session | Resolution |
|-----|---------|------------|
| oikos/topos vocabulary in docs | 1 | All files renamed, cross-references updated |
| CONTRIBUTING praxis `oikos:` field | 1 | Vocabulary aligned |
| CONTRIBUTING duplicates docs | 2 | Compressed to ~220 line gateway with pointer table |
| CONTRIBUTING attainment `grants` field | 2 | How-to sections removed, pointers to canonical docs |
| substrate-manifest `substrate_oikoi` | 4 | Renamed to `substrate_topoi`, dead topoi removed |
| Missing signal-reference.md | 7 | Created: reference/reactivity/signal-reference.md |
| Missing emission-reference.md | 7 | Created: reference/provenance/emission-reference.md |
| Missing dwelling-explanation.md | 7 | Created: explanation/dwelling/dwelling.md |
| No chora-specific dev docs | 7 | Created: reference/infrastructure/chora-dev-patterns.md |
| No `exists-in` desmos | Vis-1 | `exists-in` defined in spora.yaml and arche/desmos.yaml |
| Two visibility mechanisms | Vis-1 | Unified: `gather_entities` and `visible_to` both use exists-in + member-of |
| `find_entity` no visibility | Vis-3 | `find_entity_visible()` checks visibility via DwellingContext |
| `traverse` no visibility | Vis-3 | `traverse_visible()` stops at visibility boundaries |
| `trace_bonds` no visibility | Vis-3 | `trace_bonds_visible()` filters both endpoints |
| REST `get_entity` no visibility | Vis-3 | Uses `find_entity_visible` with OptionalSession |
| REST `list_bonds` no visibility | Vis-3 | Uses `trace_bonds_visible` with OptionalSession |
| REST `update_entity` no visibility | Vis-3 | Uses `find_entity_visible` with ValidatedSession |
| Interpreter steps no visibility | Vis-3 | FindStep/TraverseStep/TraceStep use visibility-aware host methods via DwellingContext |

---

## Proposals and Design

Active proposals and design documents. Mature along: research → proposal → design → reference/explanation.

| ID | Path | Status |
|----|------|--------|
| AGORA-TERRITORY | [design/AGORA-TERRITORY-DESIGN.md](design/AGORA-TERRITORY-DESIGN.md) | DRAFT |
| CHORA-DEV-TOPOS | [design/CHORA-DEV-TOPOS-DESIGN.md](design/CHORA-DEV-TOPOS-DESIGN.md) | DRAFT |
| cross-topos-coordination | [proposal/cross-topos-coordination.md](proposal/cross-topos-coordination.md) | DRAFT |
| genesis-restructure | [proposal/genesis-restructure.md](proposal/genesis-restructure.md) | DRAFT |
| governed-generation | [proposal/governed-generation-integration.md](proposal/governed-generation-integration.md) | DRAFT |
| session-signing | [proposal/session-signing-capability.md](proposal/session-signing-capability.md) | DRAFT |
| single-stream-genesis | [proposal/single-stream-genesis.md](proposal/single-stream-genesis.md) | DRAFT |
| distributed-research | [research/DISTRIBUTED-ARCHITECTURE-RESEARCH.md](research/DISTRIBUTED-ARCHITECTURE-RESEARCH.md) | CURRENT |

---

## Implementation Handoffs

Specifications waiting on chora development. Dissolve when implemented — content migrates to reference docs.

| ID | Path | Status |
|----|------|--------|
| handoff-deployment | [implementation/CHORA-HANDOFF-DEPLOYMENT.md](implementation/CHORA-HANDOFF-DEPLOYMENT.md) | CURRENT |
| handoff-kosmos-ontology | [implementation/CHORA-HANDOFF-KOSMOS-ONTOLOGY.md](implementation/CHORA-HANDOFF-KOSMOS-ONTOLOGY.md) | CURRENT |
| handoff-mcp-consolidation | [implementation/CHORA-HANDOFF-MCP-CONSOLIDATION.md](implementation/CHORA-HANDOFF-MCP-CONSOLIDATION.md) | CURRENT |
| handoff-topos-dev | [implementation/CHORA-HANDOFF-TOPOS-DEV.md](implementation/CHORA-HANDOFF-TOPOS-DEV.md) | CURRENT |
| handoff-render-specs | [implementation/CHORA-HANDOFF-RENDER-SPECS.md](implementation/CHORA-HANDOFF-RENDER-SPECS.md) | CURRENT |
| handoff-sense-body | [implementation/CHORA-HANDOFF-SENSE-BODY.md](implementation/CHORA-HANDOFF-SENSE-BODY.md) | CURRENT |
| handoff-voice-authoring | [implementation/CHORA-HANDOFF-VOICE-AUTHORING.md](implementation/CHORA-HANDOFF-VOICE-AUTHORING.md) | CURRENT |

---

## Meta-Documents

Governance documents that control the documentation system itself.

| ID | Path | Purpose | Status |
|----|------|---------|--------|
| REGISTRY | docs/REGISTRY.md | Prescriptive topos map, impact tracking, gap register | CURRENT |
| index | [docs/index.md](index.md) | Reader-facing Diataxis navigation portal | CURRENT |
| KOSMOGONIA | [genesis/KOSMOGONIA.md](../genesis/KOSMOGONIA.md) | Constitutional root — five axioms, archai, two modes of being | CURRENT |
| CLAUDE-kosmos | [../CLAUDE.md](../CLAUDE.md) | Authoring constitution for kosmos | CURRENT |
| CLAUDE-chora | chora/CLAUDE.md | Development constitution for chora | CURRENT |
| CONTRIBUTING | chora/CONTRIBUTING.md | Contributor gateway — setup, conventions, pointers | CURRENT |

---

## Status Definitions

| Status | Meaning |
|--------|---------|
| **CURRENT** | Describes target state; verified for correctness |
| **PRESCRIPTIVE** | Describes target state ahead of implementation; gaps listed in Gap Register |
| **VERIFIED** | Checked against implementation; confirmed accurate |
| **DRAFT** | Initial version, not yet validated |
| **MISSING** | Should exist but doesn't — scope for immediate development |

---

*This registry is the prescribed state of documentation. The gap between what's prescribed here and what exists in index.md drives documentation development. When you touch code, check the Impact Map. When you find a gap, add it to the Gap Register.*
