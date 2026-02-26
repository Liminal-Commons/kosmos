# Future Releases Plan

*A view over the journey graph. The source of truth is [spora/journeys/future-releases.yaml](spora/journeys/future-releases.yaml).*

**Traverse the graph:**
```
journey/r1-emission
  ├── contains-journey → journey/r1-typescript
  │     └── contains-waypoint → waypoint/r1-typescript-{0-3}
  ├── contains-journey → journey/r1-mcp-dispatch
  │     └── contains-waypoint → waypoint/r1-mcp-{0-3}
  └── ...
```

For current work see [ROADMAP.md](ROADMAP.md).

---

## Overview

MVP is complete: a friend can join a circle via invitation link. What remains is deepening the implementation across six release milestones.

```
MVP ✅
 │
 ├── R1: Emission Completion ─────── Full-circle code generation
 │
 ├── R2: Thyra Polish ────────────── Production-ready desktop
 │
 ├── R3: Distribution Pipeline ───── Automated release flow
 │
 ├── R4: Production Hardening ────── Relay resilience
 │
 ├── R5: Kosmos Publication ──────── Oikos packaging
 │
 └── R6: Commons ─────────────────── Self-sovereign infrastructure
```

---

## R1: Emission Completion

**Objective:** Complete full-scope emission — all generated code flows from schema with provenance.

**Why first:** This is the foundation. Type-safe frontend, auto-generated dispatchers, and schema-synced docs reduce maintenance burden for everything that follows.

### Tasks

| ID | Task | Description | Depends On |
|----|------|-------------|------------|
| E8.1 | Entity interfaces | Generate TypeScript interfaces from eidos definitions | — |
| E8.2 | Emit entities.ts | Write `app/src/types/entities.ts` with provenance headers | E8.1 |
| E8.3 | Store slice types | Generate Zustand store types from eidos fields | E8.1 |
| E8.4 | TypeScript in hash | Include TypeScript in full-circle verification | E8.2 |
| E9.1 | Tool registration | Generate MCP tool registration from visible praxeis | — |
| E9.2 | Dispatch match arms | Emit dispatch in `kosmos-mcp/src/lib.rs` | E9.1 |
| E9.3 | Param JSON Schema | Generate JSON Schema for praxis params | E9.1 |
| E9.4 | MCP in hash | Include MCP dispatch in full-circle verification | E9.2 |
| E10.1 | Dynamis dispatch | Generate dispatch from dynamis-function entities | — |
| E10.2 | Tier gates | Emit tier-gated access control | E10.1 |
| E10.3 | HostContext stubs | Generate HostContext method stubs | E10.1 |
| E10.4 | Dynamis in hash | Include dynamis dispatch in full-circle verification | E10.2 |
| E11.1 | app-config eidos | Define eidos for Tauri metadata | — |
| E11.2 | Emit tauri.conf.json | Generate config from app-config entity | E11.1 |
| E12.1 | Eidos reference | Generate field tables from eidos entities | — |
| E12.2 | Praxis reference | Generate param tables from praxis entities | — |
| E12.3 | Stoicheion reference | Generate API reference from stoicheion entities | — |
| E12.4 | Per-oikos REFERENCE.md | Emit reference docs per oikos | E12.1-3 |

### Success Criteria

- [ ] `app/src/types/entities.ts` generated from eidos, included in hash
- [ ] MCP tools auto-registered from `visible: true` praxeis
- [ ] Dynamis dispatch generated with tier gates
- [ ] Full-circle hash includes all generated code (H1 == H2)
- [ ] Per-oikos REFERENCE.md files generated

### Estimated Scope

17 tasks across 5 emission targets. E8-E10 are high priority (eliminate manual sync). E11-E12 are lower priority (stable config, developer experience).

---

## R2: Thyra Polish

**Objective:** Production-ready desktop experience with sync, offline handling, and error states.

**Why second:** Users are joining circles. Now make the experience robust.

### Tasks

| ID | Task | Description | Depends On |
|----|------|-------------|------------|
| C8.4 | Real-time updates | Live sync while connected | — |
| C8.5 | Reconnection | Catch-up sync after reconnect | C8.4 |
| C9.4 | Offline handling | Graceful degradation when offline | — |
| C9.5 | Error states | Clear error UI for all failure modes | — |
| C9.6 | Audit trail | Visible history of membership changes | — |
| E6.1 | Klimax emission | Emit scale definitions to `klimax/{scale}/` | — |
| E6.2 | Scale DESIGN.md | Include DESIGN.md for each scale | E6.1 |
| E6.3 | Hierarchy ordering | Verify hierarchical ordering preserved | E6.1 |

### Success Criteria

- [ ] Content syncs in real-time while peers are connected
- [ ] Reconnection triggers catch-up sync
- [ ] Offline mode shows clear status, queues actions
- [ ] All error states have user-facing explanations
- [ ] Membership changes are auditable
- [ ] Klimax hierarchy emitted correctly

### Estimated Scope

8 tasks. C8.4-5 require networking work. C9.4-6 are UI polish. E6 is emission extension.

---

## R3: Distribution Pipeline

**Objective:** Automated release flow from tag to download.

**Why third:** Manual releases work but don't scale. Automate before adding more platforms.

### Tasks

| ID | Task | Description | Depends On |
|----|------|-------------|------------|
| D4.1 | justfile targets | Cargo build targets in justfile | — |
| D4.3 | Artifact registration | Register artifacts (hash, size, path) in kosmos | D4.1 |
| D4.5 | Version bump workflow | Automated version bumping | — |
| D5.1 | Landing queries releases | thyra-landing Worker queries release entities | — |
| D5.2 | Dynamic version | Version from kosmos, not hardcoded | D5.1 |
| D5.3 | Platform detection | Detect platform → resolve substrate | D5.1 |
| D5.4 | Download URL | URL from distribution-channel entity | D5.1 |

### Blocking Questions

These must be resolved before R3 is complete:

- [ ] **macOS code signing** — Apple Developer account ($99/year)?
- [ ] **Windows code signing** — Authenticode certificate?
- [ ] **Linux format** — AppImage, .deb, Flatpak, or multiple?

### Success Criteria

- [ ] `just release` triggers full build pipeline
- [ ] Artifacts registered in kosmos with hashes
- [ ] Landing page shows current version dynamically
- [ ] Platform detection works correctly
- [ ] Download links resolve from distribution-channel

### Estimated Scope

7 tasks. D4 is build tooling. D5 is landing page integration. Code signing decisions block final deployment.

---

## R4: Production Hardening

**Objective:** Relay resilience and observability.

**Why fourth:** Core flow works. Now make it reliable under load.

### Tasks

| ID | Task | Description | Depends On |
|----|------|-------------|------------|
| R3.1 | Rate limiting | Prevent abuse of signaling relay | — |
| R3.2 | Room cleanup | Garbage collect stale connections | — |
| R3.3 | Monitoring | Logging and metrics for relay | — |
| R3.4 | Custom domain SSL | SSL for custom domain | — |
| R3.5 | Geographic distribution | Multi-region relay deployment | R3.1-4 |

### Success Criteria

- [ ] Rate limiting prevents signaling abuse
- [ ] Stale rooms cleaned up automatically
- [ ] Relay metrics visible in dashboard
- [ ] Custom domain has valid SSL
- [ ] Relay deployed to multiple regions

### Estimated Scope

5 tasks. R3.1-4 are incremental improvements. R3.5 requires infrastructure planning.

---

## R5: Kosmos Publication

**Objective:** Package and distribute oikoi to circles.

**Why fifth:** With stable infrastructure, enable ecosystem growth.

### Tasks

| ID | Task | Description | Depends On |
|----|------|-------------|------------|
| K0.1 | content-root eidos | Define content-root (constitutional: true) | — |
| K0.2 | sources-content-from desmos | Define provenance bond | K0.1 |
| K0.3 | spora.yaml v2.0 | Extend format with content_roots, stages | K0.1 |
| K0.4 | Bootstrap content roots | Create content-root entities and bonds | K0.3 |
| K1.1 | Oikos entity composition | Compose oikos entity from manifest.yaml | K0.4 |
| K1.2 | Compose all oikoi | Create oikos entities for all oikoi | K1.1 |
| K1.3 | Validate oikos entities | Validate against manifest.yaml | K1.2 |
| K2.1 | provides-affordance bond | Oikos → affordance bond | K1.2 |
| K2.2 | requires-attainment bond | Oikos → attainment bond | K1.2 |
| K2.3 | Bind affordances | Bind existing affordances to oikos | K2.1 |
| K2.4 | Bind attainments | Bind existing attainments to oikos | K2.2 |
| K3.1 | oikos-dev composition | Compose oikos-dev from oikos + manifest | K2.3-4 |
| K3.2 | bake-oikos | Resolve generation specs to literals | K3.1 |
| K3.3 | publish-oikos | Sign and freeze oikos-prod | K3.2 |
| K3.4 | oikos-prod | Create with content hash and signature | K3.3 |
| K4.1 | Distribution circles | Create circles for oikos-prod | K3.4 |
| K4.2 | distribute-oikos | Implement distribution praxis | K4.1 |
| K4.3 | oikos-use attainment | Grant attainment to circle members | K4.2 |
| K4.4 | Install from distribution | Enable oikos installation | K4.3 |

### Success Criteria

- [ ] Content roots are entities with provenance bonds
- [ ] Oikos entities composed from manifests
- [ ] Affordances and attainments bound to oikoi
- [ ] oikos-prod packages are signed and hashable
- [ ] Circles can install oikoi from distribution circles

### Estimated Scope

19 tasks across 5 sub-phases (K0-K4). This is the largest release. Consider splitting K0-K2 from K3-K4.

---

## R6: Commons

**Objective:** Self-sovereign infrastructure for circles.

**Why last:** Requires stable oikos packaging, infrastructure reconciliation, and hardware investment.

### Tasks

| ID | Task | Description | Depends On |
|----|------|-------------|------------|
| S1.5 | LiveKit client | LiveKit integration (Rust or WASM) | — |
| S1.6 | Phaser.js frontend | 2D spatial environment | — |
| S1.7 | Spatial audio | Spatial audio configuration | S1.5 |
| S2.1 | server eidos | Represents owned hardware | — |
| S2.2 | nixos-service mode | Actuality mode for NixOS services | S2.1 |
| S2.3 | actualize-server | Sense/compare/manifest for services | S2.2 |
| S2.4 | Deploy LiveKit | LiveKit on NixOS server | S2.3 |
| S2.5 | Reconciliation loop | Periodic health check | S2.4 |
| S3.1 | inference-server eidos | Local inference server entity | — |
| S3.2 | Ollama deployment | Local llama.cpp/Ollama | S3.1 |
| S3.3 | Whisper transcription | Local transcription with NPU | S3.1 |
| S3.4 | Manteia local config | Configure for local inference endpoint | S3.2 |
| S3.5 | Local embeddings | Embeddings for semantic search | S3.2 |
| S4.1 | Commons oikos bundle | gathering-space + local-ai bundle | S1-S3 |
| S4.2 | Commons distribution | Distribution circle for commons | S4.1 |
| S4.3 | Installation workflow | Install workflow for other circles | S4.2 |
| S4.4 | Federation | Federation between commons circles | S4.3 |

### Success Criteria

- [ ] Agora spatial environments work with LiveKit
- [ ] NixOS services reconciled from kosmos entities
- [ ] Local inference running on owned hardware
- [ ] Commons capabilities packaged as oikos
- [ ] Other circles can install and run commons

### Estimated Scope

17 tasks across 4 sub-phases (S1-S4). Requires hardware (96GB RAM, 4TB NVMe, NPU). Consider S1-S2 as "infrastructure foundation" and S3-S4 as "AI commons."

---

## Release Sequencing

```
          R1          R2          R3          R4          R5          R6
       Emission    Thyra     Distribution  Hardening  Publication  Commons
          │          │           │            │           │           │
          ▼          ▼           ▼            ▼           ▼           ▼
    ┌─────────┐ ┌─────────┐ ┌─────────┐ ┌─────────┐ ┌─────────┐ ┌─────────┐
    │ E8-E12  │ │ C8.4-5  │ │ D4.1-5  │ │ R3.1-5  │ │ K0-K4   │ │ S1-S4   │
    │ 17 tasks│ │ C9.4-6  │ │ D5.1-4  │ │ 5 tasks │ │ 19 tasks│ │ 17 tasks│
    │         │ │ E6      │ │ 7 tasks │ │         │ │         │ │         │
    │         │ │ 8 tasks │ │         │ │         │ │         │ │         │
    └─────────┘ └─────────┘ └─────────┘ └─────────┘ └─────────┘ └─────────┘
         │           │           │            │           │           │
         ▼           ▼           ▼            ▼           ▼           ▼
    Full-circle  Production   Automated    Resilient   Ecosystem   Sovereign
    generation   experience   releases     relay       packaging   infrastructure
```

### Dependencies Between Releases

| Release | Hard Dependencies | Soft Dependencies |
|---------|-------------------|-------------------|
| R1 | None | — |
| R2 | None | R1 (type-safe frontend helps) |
| R3 | None | R1 (generated docs), code signing decisions |
| R4 | None | R3 (before geographic distribution) |
| R5 | None | R1 (emission patterns), R3 (distribution) |
| R6 | R5 (oikos packaging) | R4 (hardened relay) |

### Parallelization Opportunities

R1-R4 can proceed in parallel with different focus areas:
- **R1** (Emission): Schema/codegen work
- **R2** (Thyra): Frontend/UX work
- **R3** (Distribution): DevOps/build work
- **R4** (Hardening): Infrastructure work

R5 and R6 are more sequential and depend on foundation work.

---

## Scope Summary

| Release | Tasks | Priority | Focus |
|---------|-------|----------|-------|
| R1 | 17 | High | Schema → code generation |
| R2 | 8 | High | User experience |
| R3 | 7 | Medium | Automation |
| R4 | 5 | Medium | Reliability |
| R5 | 19 | Medium | Ecosystem |
| R6 | 17 | Lower | Infrastructure |
| **Total** | **73** | — | — |

---

## Decision Points

### Before R3 (Distribution)
- macOS code signing approach
- Windows code signing approach
- Linux distribution format(s)

### Before R5 (Publication)
- Content root implementation strategy
- Oikos signing key management
- Distribution circle governance

### Before R6 (Commons)
- Hardware procurement (server specs)
- NixOS configuration approach
- Local LLM model selection

---

*Crystallized from ROADMAP.md scope analysis.*
*Created: 2026-01-26*
