# Kosmos Documentation

The world and its receptacle. Documentation follows the [Diataxis](https://diataxis.fr/) framework, unified across kosmos (ontology) and chora (implementation).

---

## Quick Links

| Document | Purpose |
|----------|---------|
| [KOSMOGONIA.md](../genesis/KOSMOGONIA.md) | Constitutional root — start here |
| [CLAUDE.md](../CLAUDE.md) | Design principles, development pillars |
| [REGISTRY.md](REGISTRY.md) | Holistic tracking frame — every doc, every dependency |

---

## Documentation Categories

### [Tutorial](tutorial/) — Learning-oriented

Step-by-step lessons to learn by doing.

- **Foundations** — Core concepts for newcomers
  - [Your First Praxis](tutorial/foundations/first-praxis.md) — Creating a praxis from scratch
  - [Your First Phasis](tutorial/foundations/first-phasis.md) — Phasis lifecycle, threading, stances
  - [Create a Topos](tutorial/foundations/create-a-topos.md) — Build a domain package from scratch
- **Presentation** — Making things visible
  - [Create a Mode](tutorial/presentation/create-a-mode.md) — Build a UI mode from scratch
- **Reactivity** — Making things respond
  - [Create Your First Reflex](tutorial/reactivity/create-your-first-reflex.md) — Autonomic reactive response
  - [Self-Healing Entities](tutorial/reactivity/self-healing-entities.md) — Reconciliation pattern
- **Generation** — Making things generate
  - [Generating Instead of Writing](tutorial/generation/generating-instead-of-writing.md) — The generative spiral

### [How-To](how-to/) — Task-oriented

Recipes for specific goals.

- **Topos Development** — Building and structuring topoi
  - [Topos Development](how-to/topos-development/topos-development.md) — Build domain packages
  - [Schema, Graph, Cache](how-to/topos-development/schema-graph-cache.md) — Three pillars methodology
- **Presentation** — Modes, render-specs, widgets
  - [Mode Development](how-to/presentation/mode-development.md) — UI mode recipes
  - [Voice Authoring](how-to/presentation/voice-authoring.md) — Voice/text composition modes
  - [Form-Based Mode](how-to/presentation/form-based-mode.md) — Form patterns and bindings
  - [Create Artifact Mode](how-to/presentation/create-artifact-mode.md) — Artifact-based modes
- **Reactivity** — Triggers, reflexes, daemons
  - [Define Custom Triggers](how-to/reactivity/define-custom-triggers.md) — Reactive trigger patterns
  - [Wire Reconciliation Cycle](how-to/reactivity/wire-reconciliation-cycle.md) — Complete reconciliation wiring
  - [Create Daemon](how-to/reactivity/create-daemon.md) — Supervised processes
- **Composition** — Artifacts, theoria, notes, generation
  - [Compose Artifact](how-to/composition/compose-artifact.md) — Compose artifacts from definitions
  - [Use Generation](how-to/composition/use-generation.md) — Governed generation for definitions
  - [Crystallize Theoria](how-to/composition/crystallize-theoria.md) — Crystallize understanding
  - [Create Note](how-to/composition/create-note.md) — Create note entities
- **Operations** — Deployment, onboarding, bootstrap
  - [Operations](how-to/operations/operations.md) — Bootstrap, distributed patterns
  - [Developer Onboarding](how-to/operations/developer-onboarding.md) — Federation and entry

### [Explanation](explanation/) — Understanding-oriented

Conceptual discussion of kosmos design.

- **Genesis**
  - [Genesis Layer](explanation/genesis/index.md) — The constitutional definitions
  - [The Five Archai](explanation/genesis/archai.md) — Foundational forms
  - [Topoi Organization](explanation/genesis/topoi.md) — Domain packages
  - [Bootstrap Process](explanation/genesis/bootstrap.md) — Loading genesis

- **Architecture**
  - [Architecture](explanation/architecture/architecture.md) — System design and reconciliation
  - [Homoiconic Reactive](explanation/architecture/homoiconic-reactive-architecture.md) — Triggers as graph entities
  - [Entity as Source of Truth](explanation/architecture/entity-as-source-of-truth.md) — UI state pattern
  - [Commitment Boundary](explanation/architecture/commitment-boundary.md) — State transition integrity
  - [Two-Phase Bindings](explanation/architecture/two-phase-bindings.md) — Binding resolution timing

- **Presentation**
  - [Thyra-Topos](explanation/presentation/thyra-topos.md) — UI ontology design
  - [Modes and Topoi](explanation/presentation/modes-and-topoi.md) — How topoi become present through modes
  - [Modes as Topoi](explanation/presentation/modes-as-topoi.md) — Why modes are independent packages
  - [Artifact-Based Modes](explanation/presentation/artifact-based-modes.md) — Rendering patterns
  - [Entity Overlays](explanation/presentation/entity-overlays.md) — Optimistic local updates

- **Reactivity**
  - [Reactive System](explanation/reactivity/reactive-system.md) — Triggers, reflexes, and autonomic responses
  - [Reconciler Pattern](explanation/reactivity/reconciler-pattern.md) — Sense → compare → act

- **Composition**
  - [Creative Journey Pattern](explanation/composition/creative-journey-pattern.md) — Voice-to-theoria workflow
  - [Clarification as Composition](explanation/composition/clarification-as-composition.md) — Reactive composition

- **Generation**
  - [Generative Spiral](explanation/generation/generative-spiral.md) — Three levels: atoms, molecules, factory
  - [Schema Enforcement](explanation/generation/schema-enforcement.md) — T9: output_schema > prompt instructions

- **Dwelling**
  - [Dwelling](explanation/dwelling/dwelling.md) — Multi-dimensional presence (prosopon + oikos + topos + kairos)
  - [Oikos](explanation/oikos/index.md) — Social dwelling concepts
  - [Federation](explanation/federation.md) — Distributed sync model

- **Other**
  - [Klimax Scales](explanation/klimax/index.md) — Nested containment hierarchy

### [Reference](reference/) — Information-oriented

Technical specifications and API documentation.

- **Genesis**
  - [Manifest Schema](reference/genesis/manifest-schema.md) — Topos manifest fields
  - [Directory Conventions](reference/genesis/directory-conventions.md) — File organization
  - [Bootstrap Genesis](reference/genesis/bootstrap-genesis.md) — Germination stages
  - [Manifest Validation](reference/genesis/manifest-validation.md) — Contract validation
  - [Validation Enforcement](reference/genesis/validation-enforcement.md) — Enforcement rules

- **Elements**
  - [Constituent Elements](reference/elements/constituent-elements.md) — The 12 atom types
  - [Composite Patterns](reference/elements/composite-patterns.md) — Named patterns catalog
  - [Stoicheia WASM](reference/elements/stoicheia-wasm.md) — WASM execution model

- **Composition**
  - [Composition Guide](reference/composition/composition.md) — Artifact composition patterns
  - [Typos Composition](reference/composition/typos-composition.md) — Template syntax, slot filling
  - [Expression Evaluator](reference/composition/expression-evaluator.md) — Functions, pipe syntax

- **Presentation**
  - [Mode Reference](reference/presentation/mode-reference.md) — Widget and schema reference
  - [Render-Spec Resolution](reference/presentation/render-spec-resolution.md) — Graph discovery
  - [Widget System](reference/presentation/widget-system.md) — Widget eidos, registry, bonds
  - [Render-Spec Authoring](reference/presentation/render-spec-authoring.md) — Guide to writing render-specs

- **Reactivity**
  - [Reactive System Reference](reference/reactivity/reactive-system-reference.md) — Trigger/reflex spec
  - [Reconciliation](reference/reactivity/reconciliation.md) — Reconciler entity schema
  - [Daemon Runner](reference/reactivity/daemon-runner.md) — Supervised process reference
  - [Signal Reference](reference/reactivity/signal-reference.md) — Substrate signal registry, 10Hz broadcast

- **Authorization**
  - [Attainment Authorization](reference/authorization/attainment-authorization.md) — Graph-based access control
  - [Session Identity](reference/authorization/session-identity.md) — Three-layer auth
  - [Surface Contracts](reference/authorization/surface-contracts.md) — Surface operation contracts

- **Infrastructure**
  - [REST API](reference/infrastructure/rest-api.md) — HTTP endpoints, federation
  - [soma-client](reference/infrastructure/soma-client.md) — Client library API
  - [Substrate Lifecycle](reference/infrastructure/substrate-lifecycle.md) — Actuality handlers
  - [Cryptographic Operations](reference/infrastructure/cryptographic-operations.md) — Crypto reference
  - [Chora Dev Patterns](reference/infrastructure/chora-dev-patterns.md) — Rust module contract, test patterns

- **Generation**
  - [Generation Reference](reference/generation/generation.md) — Praxeis, inference contexts, pipeline

- **Domain**
  - [Phasis Entity](reference/domain/phasis-entity.md) — Phasis schema, lifecycle, praxeis
  - [Phasis Workspace](reference/domain/phasis-workspace.md) — Accumulation schema, authoring patterns
  - [Topos Map](reference/domain/topos-map.md) — Topos inventory and relationships

- **Provenance**
  - [Provenance Mechanism](reference/provenance/provenance-mechanism.md) — Composition chains, signatures
  - [Authority Mechanism](reference/provenance/authority-mechanism.md) — Authorization requirements
  - [Emission Reference](reference/provenance/emission-reference.md) — Ekthesis patterns, format options

- **Cross-cutting**
  - [Query System](reference/query-system.md) — Unified query grammar (find, gather, trace, traverse, surface)

### [Design](design/) — Architectural Vision

Target state architecture.

- [Thyra Interpreter](design/THYRA-INTERPRETER.md) — Interpreter architecture, widgets, directives
- [Voice Topos](design/VOICE-TOPOS-DESIGN.md) — Voice pipeline, substrate separation
- [WebRTC Topos](design/WEBRTC-TOPOS-DESIGN.md) — Video calls via widgets
- [Homoiconic Reactive](design/HOMOICONIC-REACTIVE-SYSTEM.md) — Reactive system design
- [Cryptographic Topology](design/CRYPTOGRAPHIC-TOPOLOGY.md) — Visibility = reachability
- [Distributed Architecture](design/DISTRIBUTED-ARCHITECTURE.md) — Multi-client federation
- [Agora Territory](design/AGORA-TERRITORY-DESIGN.md) — Assembly + territory
- [Chora Dev Topos](design/CHORA-DEV-TOPOS-DESIGN.md) — Development tooling topos
- [Render-Spec Generation](design/render-spec-generation.md) — Generation awareness for thyra

### [Architecture](architecture/) — System Analysis

Implementation analysis and gap tracking.

- [Overview](architecture/overview.md) — Klimax, 6 scales, rendering
- [Thyra Rendering](architecture/THYRA-RENDERING.md) — Three architecture levels
- [Rendering Gaps](architecture/RENDERING-GAPS.md) — Design vs implementation gaps
- [Next Steps](architecture/THYRA-NEXT-STEPS.md) — Substrate implementation

### [Implementation](implementation/) — Handoffs

Active specifications waiting on chora development.

- [README](implementation/README.md) — Status of all handoffs

### [Proposal](proposal/) — Emerging Ideas

Design proposals under consideration.

- [Cross-Topos Coordination](proposal/cross-topos-coordination.md)
- [Genesis Restructure](proposal/genesis-restructure.md)
- [Governed Generation Integration](proposal/governed-generation-integration.md)
- [Session Signing Capability](proposal/session-signing-capability.md)
- [Single Stream Genesis](proposal/single-stream-genesis.md)

### [Research](research/) — Investigative

Research and analysis documents.

- [Distributed Architecture Research](research/DISTRIBUTED-ARCHITECTURE-RESEARCH.md)

---

## Source Documentation

Design documents live with their code in `genesis/`:

- Per-topos: `genesis/{topos}/DESIGN.md` and `REFERENCE.md`
- Per-scale: `genesis/klimax/{scale}/DESIGN.md`
- Constitutional: `genesis/KOSMOGONIA.md`
