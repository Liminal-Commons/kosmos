# Kosmos Infrastructure Roadmap

*The path from genesis to a living, distributed kosmos.*

---

## Current Focus

**Phase K: Oikos Packaging** — ✅ Complete

| Task | What | Status |
|------|------|--------|
| [K1-K2](#k1-oikos-entity-composition) | Oikos entity composition, manifest v2.1 | ✅ Complete |
| [K3](#k3-oikos-packaging-pipeline) | Packaging pipeline | ✅ Complete |
| [K4](#k4-oikos-distribution) | Distribution circles, install-oikos | ✅ Complete |

**Recently completed:**
- K4 (Oikos distribution) ✅ — install-oikos, uses-oikos desmos
- K3 (Oikos packaging pipeline) ✅ — compose-oikos-dev, bake-oikos, publish-oikos
- K1-K2 (Oikos entity composition) ✅ — Manifest v2.1, oikos entities from manifests
- E7-E12 (Full-scope emission) ✅ — TypeScript, MCP dispatch, step types, reference docs
- R4 (Propylon relay) ✅ — wss://propylon.liminalcommons.com

See [Phase K details](#phase-k-oikos-packaging) for implementation guidance.

---

## Vision

A kosmos that:
1. Actualizes in multiple substrates (desktop, mobile, web)
2. Federates between circles via P2P
3. Maintains cryptographic provenance to genesis
4. Self-documents and self-validates

For technical architecture details, see [ARCHITECTURE.md](ARCHITECTURE.md).
For ontological foundations, see [KOSMOGONIA.md](KOSMOGONIA.md).
For completed phases, see [archive/ROADMAP-completed.md](../../archive/ROADMAP-completed.md).

---

## Phase Summary

| Phase | Name | Objective | Status |
|-------|------|-----------|--------|
| D | Dynamis | Distribution layer for releases/deployments | ✅ D3, D4.2/D4.4 Complete |
| V | Validation | Schema-driven validation and generation | ✅ V5.0 Complete |
| **V6** | **Governed Generation** | **Two-step inference with evaluation (verdict/guidance)** | **✅ V6.1-V6.4 Complete** |
| G | Genesis | Align folders with generative principle | ✅ G3 Complete |
| **T** | **Thyra** | **Desktop application** | **✅ MVP Complete** |
| R | Relay | WebRTC signaling infrastructure | ✅ R1-R2 Complete |
| **E** | **Emission** | **Full-scope genesis emission with headers** | **✅ E7-E12 Complete** |
| **F** | **Format Consolidation** | **Single-stream genesis (emit = source format)** | **✅ F1-F3 Complete** |
| **CE** | **Constitutional Enforcement** | **Gate arise/infer, enforce compose/governed-inference** | **✅ CE1-CE4 Complete** |
| K | Kosmos | Oikos packaging and distribution | ✅ K0-K5 Complete, ⏳ K6 Planned |
| S | Commons | Self-sovereign infrastructure for circles | ⏳ Post-MVP |
| I | Infrastructure | Cloudflare, documentation | ✅ I1 Complete |

**Current Focus:** K0-K5 complete (content roots, oikos packaging, two-repo workflow). K6 (Ekdosis) ontology complete — content publication system. S1 kosmos ontology complete (Agora eide/desmoi/praxeis/attainments). Next: K6 implementation (bake/sign/upload/publish) or S1 chora implementation (LiveKit, Phaser.js).

**MVP Definition:** A friend can join a circle via invitation link. ✅ **MVP ACHIEVED** (Phase T, C7 complete).

---

## The User Journey (End-to-End)

The complete path from installing Thyra to inviting a friend:

```
Distribution → Bootstrap → Identity → Invitation → Landing → Entry → Signaling → Verification → Phoreta → Federation
    (1)          (2)         (3)         (4)         (5)       (6)       (7)          (8)          (9)        (10)
     ✅          ✅          ✅          ✅          ✅        ✅        ✅           ✅           ✅          ⏳
                                                                                                    ↑
                                                                                              ✅ MVP Complete
```

| Phase | What Happens | Status |
|-------|--------------|--------|
| 1. Distribution | User downloads Thyra from website | ✅ |
| 2. Bootstrap | First launch creates kosmos.db from embedded spora (754 entities) | ✅ C1 |
| 3. Identity | Generate mnemonic, create persona, home circle | ✅ C2 |
| 4. Invitation | Create propylon link, share via any channel | ✅ C3 |
| 5. Landing | Friend clicks link → deep link or download prompt | ✅ R2 |
| 6. Entry | Friend opens link, enters name, waits for inviter | ✅ C5 |
| 7. Signaling | Both devices connect via relay, establish P2P | ✅ C4 |
| 8. Verification | Video call — "the call IS the verification" | ✅ C6 |
| 9. Phoreta | On approval, membership bundle exchanged | ✅ C7 |
| 10. Federation | Circle content syncs (post-MVP) | ⏳ C8 |

**The Sovereignty Promise:**
> Your circle is YOURS. You decide who enters, what they can do, and what syncs. Your sovereignty rests on your mnemonic — guard it.

---

## Phase D: Dynamis — Distribution Layer

**Objective:** Bring release/deployment lifecycle into kosmos coherence.

**D1-D3: ✅ Complete** — Ontology, energeia integration, and bootstrap. See [archive/ROADMAP-completed.md](../../archive/ROADMAP-completed.md#phase-d-dynamis--distribution-layer--d1-d3-complete) for detailed task records.

**Note:** Dynamis is now in `genesis/` (core), loaded at bootstrap.

### D4: Build Pipeline Integration ⏳ In Progress

| Task | Description | Status |
|------|-------------|--------|
| D4.1 | justfile targets for cargo build | ⏳ |
| D4.2 | GitHub Actions cross-platform builds (macOS, Windows, Linux) | ✅ |
| D4.3 | Artifact registration (hash, size, path) | ⏳ |
| D4.4 | Auto-upload to R2 on release | ✅ |
| D4.5 | Version bump workflow | ⏳ |

**Implementation:**
- [.github/workflows/release.yml](../../.github/workflows/release.yml) — GitHub Actions workflow
- Triggers on `v*` tags or manual dispatch
- Builds universal macOS DMG, Windows NSIS installer, Linux AppImage
- Uploads artifacts to R2 bucket and creates GitHub Release

### D5: Landing Page Integration ⏳ Post-MVP

| Task | Description | Status |
|------|-------------|--------|
| D5.1 | thyra-landing Worker queries release entities | ⏳ |
| D5.2 | Dynamic version from kosmos (not hardcoded) | ⏳ |
| D5.3 | Platform detection → substrate resolution | ⏳ |
| D5.4 | Download URL from distribution-channel | ⏳ |

---

## Phase V: Validation Infrastructure

**Objective:** Shift validation left — from runtime to bootstrap/generation time.

**V1-V5: ✅ Complete** — Bootstrap validation, stoicheion eide, manteia structured outputs, schema-driven artifact composition, code generation. See [archive/ROADMAP-completed.md](../../archive/ROADMAP-completed.md#phase-v-validation-infrastructure--v1-v5-complete) for detailed task records.

**Key Insight (T2):** Fix at generation level — when generated code is wrong, fix the schema or generator, never the output.

---

## Phase G: Genesis Restructure ✅ G3 Complete

**Objective:** Align genesis folders with the generative principle.

All oikoi are in `genesis/` and loaded at bootstrap:

| Location | Count | Oikoi | Purpose |
|----------|-------|-------|---------|
| genesis/ | 15 | agora, aither, demiurge, dokimasia, dynamis, hypostasis, manteia, nous, oikos, politeia, propylon, psyche, soma, stoicheia-portable, thyra | Core — loaded at bootstrap |
| oikoi/ | 0 | (user-created post-genesis) | Extended capabilities |

---

## Phase T: Thyra Application ✅ MVP Complete

**Objective:** Desktop app where users can create identity, invite friends, and verify entry via video call.

**C1-C7: ✅ MVP Complete** — Foundation, identity, invitation, signaling, entry, verification, phoreta exchange. See [archive/ROADMAP-completed.md](../../archive/ROADMAP-completed.md#phase-t-thyra-application--mvp-complete) for detailed task records.

**C10-C11: ✅ Complete** — Kleidoura (encrypted keyring), Syndesmos (connection state).

### Critical Path

```
C1 (Foundation) ✅ → C2 (Identity) ✅ → C3 (Invitation) ✅ → C4 (Signaling) ✅
    → C5 (Entry) ✅ → C6 (Verification) ✅ → C7 (Phoreta) ✅ ←── MVP ACHIEVED
    → C8 (Sync) ✅ C8.1-3 → C9 (Polish) ✅ C9.1-3
    → C10 (Kleidoura) ✅ → C11 (Syndesmos) ✅
```

### C8: Post-Entry Sync ⏳ Partial

| Task | Status |
|------|--------|
| C8.1-3: Content request, incremental phoreta, progress UI | ✅ |
| C8.4: Real-time updates while connected | ⏳ Future |
| C8.5: Reconnection and catch-up sync | ⏳ Future |

### C9: Polish & Edge Cases ⏳ Partial

| Task | Status |
|------|--------|
| C9.1-3: Expiry, single-use, revocation | ✅ |
| C9.4-6: Offline handling, error states, audit trail | ⏳ Future |

### Rendering Subsystem

**Status:** Foundation complete, integrated into Tauri app.

| Component | Status |
|-----------|--------|
| Rendering eide (layout, panel, style-theme, workspace) | ✅ |
| Rendering desmoi (renders-in, styled-by, shows, etc.) | ✅ |
| Opsis praxeis (14 praxeis for HUD rendering) | ✅ |
| Tauri substrate bridge (display.emit via IPC) | ✅ |
| Solid frontend framework | ✅ |

**Architecture:**
```
┌─────────────────────────────────────────────────────┐
│                    Tauri App                         │
├──────────────────────┬──────────────────────────────┤
│     Rust Backend     │       WebView Frontend       │
│  ┌────────────────┐  │  ┌────────────────────────┐  │
│  │    kosmos      │◄─┼──┤   Solid components     │  │
│  │  entities      │  │  │   HUD / panels         │  │
│  │  bonds         │──┼─►│   affordances          │  │
│  │  praxeis       │  │  │                        │  │
│  └────────────────┘  │  └────────────────────────┘  │
│         │            │            ▲                 │
│  ┌──────▼─────────┐  │  ┌─────────┴──────────────┐  │
│  │ display dynamis│──┼─►│    Tauri IPC Bridge    │  │
│  └────────────────┘  │  └────────────────────────┘  │
└──────────────────────┴──────────────────────────────┘
```

**Future:** Web thyra extraction (Phase 7) — same Solid frontend, different backend (WASM or server).

---

## Phase R: Relay Infrastructure

The signaling relay enables P2P connection establishment.

**R1-R2: ✅ Complete** — WebSocket relay for SDP exchange, landing page for propylon links. See [archive/ROADMAP-completed.md](../../archive/ROADMAP-completed.md#phase-r-relay-infrastructure--r1-r2-complete) for detailed task records.

**Implementation:** [relay/thyra-landing/src/index.ts](../../relay/thyra-landing/src/index.ts)

### R3: Production Hardening ⏳ Post-MVP

| Task | Description | Status |
|------|-------------|--------|
| R3.1 | Rate limiting | ⏳ |
| R3.2 | Room cleanup (stale connections) | ⏳ |
| R3.3 | Monitoring and logging | ⏳ |
| R3.4 | Custom domain SSL | ⏳ |
| R3.5 | Geographic distribution | ⏳ |

---

## Phase K: Kosmos Publication ⏳ Post-MVP

**Objective:** Bring oikos packaging into ontological coherence.

### K0: Content Root Infrastructure ✅ Complete

**Objective:** Enable multi-source content loading via graph-driven content roots.

Content roots are the ontological embodiment of "where things come from." They enable:
- Provenance tracking for all content sources
- Multi-source composition (arche + oikoi + extensions)
- Two-repo workflow (chora code / kosmos content)
- Traversable graph of content origin

| Task | Description | Status |
|------|-------------|--------|
| K0.1 | Define `content-root` eidos (constitutional: true) | ✅ |
| K0.2 | Define `sources-content-from` desmos | ✅ |
| K0.3 | Extend spora.yaml format to v2.0 (content_roots, stages) | ✅ |
| K0.4 | Update bootstrap.rs to create content-root entities and bonds | ✅ |

**Implementation:** `content-root` eidos in arche/eidos.yaml. `sources-content-from` desmos in demiurge/desmoi. spora.yaml v2.0 format with content_roots section. bootstrap.rs creates content-root entities and bonds automatically.

**Content-root eidos:**
```yaml
eidos: content-root
data:
  name: content-root
  description: A location from which kosmos content can be loaded.
  constitutional: true
  fields:
    path: { type: string, required: true }
    kind: { type: string, enum: [arche, oikoi, extension] }
    priority: { type: number, description: "Loading order (lower = earlier)" }
    constitutional: { type: boolean, description: "If true, content is literal-only" }
```

**Graph structure:**
```
substrate-instance/macbook
    │
    ├── sources-content-from ──► content-root/arche (constitutional: true)
    │                                  │ path: ./genesis/arche
    │
    ├── sources-content-from ──► content-root/genesis (constitutional: true)
    │                                  │ path: ./genesis
    │
    └── sources-content-from ──► content-root/oikoi
                                       │ path: ${KOSMOS_OIKOI_PATH:-./oikoi}
```

**Impact on Phase C:** K0.x has minimal impact on C4-C7 (MVP). The current bootstrap works for single-repo development. K0.x prepares the foundation for K1+ (two-repo workflow, multi-source composition).

### K1: Oikos Entity Composition ✅ Complete

| Task | Description | Status |
|------|-------------|--------|
| K1.1 | Bootstrap praxis to compose oikos entity from manifest.yaml | ✅ |
| K1.2 | Compose oikos entities for all oikoi | ✅ |
| K1.3 | Validate oikos entities match manifest.yaml content | ✅ |

**Implementation:** Manifest v2.1 format introduced with `oikos_name`, `oikos_description`, `oikos_scale` fields. Bootstrap now composes `oikos/` entities from `manifest.yaml` for all 15 genesis oikoi.

### K2: Affordance/Attainment Binding ✅ Complete

| Task | Description | Status |
|------|-------------|--------|
| K2.1 | Define `provides-affordance` bond (oikos → affordance) | ✅ |
| K2.2 | Define `requires-attainment` bond (oikos → attainment) | ✅ |
| K2.3 | Bind existing affordances to their oikos | ✅ |
| K2.4 | Bind existing attainments to their oikos | ✅ |

**Implementation:** Manifest `provides` section now populates oikos entities with eide, desmoi, praxeis, stoicheia, seeds. The graph captures which oikos provides what capability.

### K3: Oikos Packaging Pipeline ✅ Complete

| Task | Description | Status |
|------|-------------|--------|
| K3.1 | Compose `oikos-dev` from oikos + manifest | ✅ |
| K3.2 | Implement `demiurge/bake-oikos` (resolve generation specs) | ✅ |
| K3.3 | Implement `demiurge/publish-oikos` (sign and freeze) | ✅ |
| K3.4 | Create `oikos-prod` with content hash and signature | ✅ |

**Implementation:**
- `demiurge/compose-oikos-dev` — packages genesis oikos into oikos-dev entity
- `demiurge/compose-all-oikoi-dev` — batch compose all genesis oikoi
- `demiurge/bake-oikos` — resolves generation specs to literals with i18n support
- `demiurge/publish-oikos` — signs content hash, creates oikos-prod with signature
- `demiurge/verify-oikos` — verifies oikos-prod integrity and signature
- `demiurge/publish-oikos-multilocale` — publishes to multiple locales
- New desmoi: `packages`, `baked-from`, `published-by`, `attests-to`, `derives-from`
- Supports generative-commons distribution (fork, local bake)

### K4: Oikos Distribution ✅ Complete

| Task | Description | Status |
|------|-------------|--------|
| K4.1 | Create distribution circles for oikos-prod | ✅ |
| K4.2 | Implement `politeia/distribute-oikos` | ✅ |
| K4.3 | Grant `oikos-use` attainment to circle members | ✅ |
| K4.4 | Enable oikos installation from distribution circle | ✅ |

**Implementation:**
- `politeia/create-distribution-circle` — creates distribution circle (commons or premium)
- `politeia/distribute-oikos` — adds oikos-prod to existing circle
- `politeia/install-oikos` — installs oikos for a circle (creates uses-oikos bond)
- `politeia/uninstall-oikos` — removes oikos from circle
- `politeia/list-installed-oikoi` — lists oikoi installed for a circle
- `politeia/list-distributed-oikoi` — lists oikoi distributed by a circle
- `politeia/list-oikos-distributors` — lists circles that distribute an oikos
- New desmos: `uses-oikos` (circle → oikos-prod)

**NOTE:** Dynamic oikos content loading (loading new eide/praxeis at runtime) is a future capability. Currently installation tracks intent; genesis oikoi are loaded at bootstrap.

### K5: Two-Repo Workflow ✅ Complete

| Task | Description | Status |
|------|-------------|--------|
| K5.1 | Create emit target directory structure | ✅ |
| K5.2 | Add emit-genesis justfile target | ✅ |
| K5.3 | Test emit + bootstrap round-trip | ✅ |
| K5.4 | Full-circle hash verification | ✅ |

**Implementation:**
- `just emit-genesis` — emits genesis to `dist/genesis/`
- `just verify-genesis` — verifies full-circle integrity
- `just clean-genesis` — removes emitted genesis
- `emit_cycle bootstrap` — creates loadable manifest from spora
- `emit_cycle cycle` — bootstraps from manifest and emits again
- `bootstrap_from_manifest()` — loads emitted genesis in any kosmos

**Two-Repo Workflow:**
```
chora repo (development)
    │
    ├── genesis/           ← source content (YAML definitions)
    ├── crates/            ← Rust implementation
    └── just emit-genesis  → dist/genesis/
                                   │
                                   ▼
kosmos repo (library)
    │
    └── bootstrap_from_manifest("../chora/dist/genesis/manifest.yaml")
            │
            ▼
        kosmos.db (754 entities, 1098 bonds)
```

**Verification:** Same BLAKE3 hash after full cycle proves content integrity.

### K6: Ekdosis — Content Publication ⏳ Planned

**Objective:** Enable developers to publish and release oikoi through kosmos.

Ekdosis (ἔκδοσις — the giving out, publication) is the content release system, complementary to dynamis which handles binary releases. While dynamis releases Thyra app binaries via GitHub Actions, ekdosis releases oikos content packages through kosmos praxeis.

| Task | Description | Status |
|------|-------------|--------|
| K6.1 | Create ekdosis oikos structure (manifest, eide, desmoi, praxeis) | ✅ |
| K6.2 | Implement bake-oikos praxis (oikos-dev → oikos-prod) | ⏳ |
| K6.3 | Implement sign-oikos praxis (keyring integration) | ⏳ |
| K6.4 | Implement upload-oikos praxis (R2 dynamis integration) | ⏳ |
| K6.5 | Implement publish-release praxis (circle distribution) | ⏳ |
| K6.6 | Implement list-releases, verify-release, rollback-release | ⏳ |
| K6.7 | End-to-end test: compose → bake → sign → upload → publish → receive | ⏳ |

**Two Release Territories:**

| Territory | What | Where | How |
|-----------|------|-------|-----|
| **Dynamis** | Binary artifacts (Thyra app) | GitHub Releases, R2 | GitHub Actions, release-please |
| **Ekdosis** | Content packages (oikoi) | R2, circle distribution | Kosmos praxeis, baking |

**The Developer Journey:**

```
Consumer → Developer → Publisher
   │           │            │
   │ Join      │ Create     │ Bake, sign,
   │ circle    │ oikos-dev  │ distribute
   │ Receive   │            │
   │ oikoi     │            │
```

**Implementation:**
- `genesis/ekdosis/` — eide (release, release-channel, build-attestation), desmoi, praxeis
- `ekdosis/bake-oikos` — transforms oikos-dev → oikos-prod (resolves generation specs)
- `ekdosis/sign-oikos` — signs content hash with Ed25519, creates build-attestation
- `ekdosis/upload-oikos` — uploads to R2 via dynamis, sets fetch_url
- `ekdosis/publish-release` — creates release entity, distributes to circles
- `ekdosis/rollback-release` — reverts to previous release via succeeds chain

**Key Insight:** Ekdosis enables OTHER developers to release oikoi — it's the path from consumer to creator within the kosmos ontology.

---

## Phase S: Commons Infrastructure ⏳ Post-MVP

**Objective:** Enable circles to own and operate self-sovereign infrastructure through kosmos.

**Key Insight:** The path to infrastructure is through kosmos, not chora. We don't SSH into servers; we compose infrastructure entities and let reconciliation actualize them.

### The Generative Stack

```
Core Dev Circle
    │  ← develops oikoi, most generative fills
    │  ← owns genesis/, crates/, app/
    ▼
Core Prod Circle
    │  ← bakes to literal, signs oikos-prod
    │  ← emits base kosmos
    ▼
Base Kosmos (754 entities)
    │  ← what users bootstrap from
    ▼
Commons Circle (e.g., Liminal Commons)
    │  ← installs oikoi (gathering-space, manteia)
    │  ← owns infrastructure entities
    │  ← grants attainments to members
    ▼
Infrastructure (NixOS Server: 96GB RAM, 4TB NVMe, NPU)
    │  ← reconciliation actualizes services
    │  ← LiveKit, local LLM, transcription
    ▼
Circle Members
    ← enter gathering spaces, use AI features
    ← all through kosmos, never direct server access
```

### S1: Agora Oikos ✅ Kosmos Complete, ⏳ Chora Implementation

2D spatial environments with real-time communication (ἀγορά — the public assembly).

| Task | Description | Status |
|------|-------------|--------|
| S1.1 | Define eide: territory, presence, livekit-server, room | ✅ |
| S1.2 | Define desmoi: hosts-territory, operates-server, present-in, uses-room, served-by, instantiates-presence | ✅ |
| S1.3 | Define attainments: agora-enter, agora-speak, agora-video, agora-create, agora-admin | ✅ |
| S1.4 | Define praxeis: enter, move, leave, create-territory, get-room-token, actualize-server | ✅ |
| S1.4a | Define utility praxeis: list-territories, get-presences, toggle-audio, toggle-video, update-presence-status, create-livekit-server, delete-territory | ✅ |
| S1.4b | Create artifact definitions for entity composition (CE4 pattern) | ✅ |
| S1.5 | LiveKit client integration (Rust or WASM) | ⏳ Chora |
| S1.6 | Phaser.js frontend integration | ⏳ Chora |
| S1.7 | Spatial audio configuration | ⏳ Chora |

**Kosmos ontology complete:** 4 eide, 6 desmoi, 13 praxeis, 5 attainments, 4 artifact definitions.
**Remaining work requires chora code changes:** LiveKit Rust bindings, Phaser.js frontend, WebRTC integration.

**Design:** [genesis/agora/DESIGN.md](./agora/DESIGN.md)

### S2: Infrastructure Reconciliation ⏳ Pending

Actualize infrastructure entities on owned hardware.

| Task | Description | Status |
|------|-------------|--------|
| S2.1 | `server` eidos — represents owned hardware | ⏳ |
| S2.2 | `nixos-service` actuality mode | ⏳ |
| S2.3 | `actualize-server` praxis — sense/compare/manifest for services | ⏳ |
| S2.4 | Deploy LiveKit on NixOS server | ⏳ |
| S2.5 | Reconciliation loop (periodic health check) | ⏳ |

### S3: Local AI Services ⏳ Pending

Run inference locally on commons hardware.

| Task | Description | Status |
|------|-------------|--------|
| S3.1 | `inference-server` eidos | ⏳ |
| S3.2 | Local Ollama/llama.cpp deployment | ⏳ |
| S3.3 | Local Whisper transcription with NPU | ⏳ |
| S3.4 | Manteia config for local inference endpoint | ⏳ |
| S3.5 | Embeddings for local semantic search | ⏳ |

### S4: Commons Distribution ⏳ Future

Package commons capabilities for other circles.

| Task | Description | Status |
|------|-------------|--------|
| S4.1 | Commons oikos bundle (gathering-space + local-ai) | ⏳ |
| S4.2 | Distribution circle for commons software | ⏳ |
| S4.3 | Installation workflow for other municipalities | ⏳ |
| S4.4 | Federation between commons circles | ⏳ |

### Vision: Municipal Sovereignty

```
Circle = Household (oikos scale)
    │
    ▼
Federation of Circles = Municipality (polis scale)
    │
    ▼
Network of Municipalities = Region (county scale)
    │
    ▼
Civilization's Information Layer
    ← self-sovereign, federated, AI-assisted
    ← local alternatives to corporate software
    ← return to localism and municipal power
```

**The kosmos architecture enables this because:**
- No central authority — mnemonic is identity, federation is voluntary
- Infrastructure is replaceable — circles run their own servers
- Content is verifiable — full-circle genesis proves integrity
- Capabilities are composable — oikoi package anything

---

## Phase I: Infrastructure

### I1: Cloudflare Infrastructure ✅ Complete

| Task | Description | Status |
|------|-------------|--------|
| I1.1 | propylon-relay Worker (WebRTC signaling) | ✅ |
| I1.2 | thyra-landing Worker (download page) | ✅ |
| I1.3 | R2 bucket for releases | ✅ |
| I1.4 | DNS records (thyra.liminalcommons.com) | ✅ |
| I1.5 | DNS managed via kosmos (dns-record eidos) | ✅ |

### I2: Documentation Infrastructure ⏳ Pending

| Task | Description | Status |
|------|-------------|--------|
| I2.1 | pege oikos — document composition | ✅ Designed |
| I2.2 | Emit eide reference docs | ⏳ |
| I2.3 | Emit stoicheia reference docs | ⏳ |
| I2.4 | Emit desmoi reference docs | ⏳ |
| I2.5 | Generate indices | ⏳ |

---

## Cross-Cutting Concerns

### Actuality Modes

| Mode | Provider | Status | Used By |
|------|----------|--------|---------|
| `process` | Local OS | ✅ | daemons, tasks |
| `object-storage` | R2/S3 | ✅ | releases, artifacts |
| `api` | GitHub, etc. | ⏳ | github-releases channel |
| `dns` | Cloudflare | ✅ | dns-record |
| `media` | WebRTC | ⏳ | streams |
| `nixos-service` | NixOS | ⏳ | livekit-server, inference-server |
| `livekit-room` | LiveKit | ⏳ | gathering-room |

### Reconciliation as Learning

Every entity with actuality follows the phylax pattern:
```
sense()     → What is the actual state in chora?
compare()   → Does it match the entity's desired state?
act()       → Manifest, update, or unmanifest to align
```

### Three Reconciliation Loops (T1)

1. **Actuality loop** (dynamis): kosmos ↔ chora (R2, DNS, processes)
2. **Generation loop** (manteia): expression → LLM → artifact
3. **Schema loop**: authored content ↔ interpreter expectations

---

## Timeline

```
        Jan W4   Feb W1   Feb W2   Feb W3   Feb W4   Mar W1   Mar W2   Mar W3   Mar W4
        ─────────────────────────────────────────────────────────────────────────────────
Dynamis │ D1-3✅ │       │       │  D4  │  D5  │       │       │       │       │
        │Complete│       │       │Build │Landing│       │       │       │       │
        ─────────────────────────────────────────────────────────────────────────────────
Valid   │ V1-5✅ │       │       │       │       │       │       │       │       │
        │Complete│       │       │       │       │       │       │       │       │
        ─────────────────────────────────────────────────────────────────────────────────
Thyra   │ C1-3✅ │  C4  │  C5  │  C6  │  C7  │  C8  │  C9  │       │       │
        │Complete│Signal│Entry │Verify│Phoreta│ Sync │Polish│       │       │
        ─────────────────────────────────────────────────────────────────────────────────
Relay   │ R1 ✅ │  R2  │  R2  │       │       │       │  R3  │       │       │
        │ Core  │Landing page  │       │       │       │Harden│       │       │
        ─────────────────────────────────────────────────────────────────────────────────
Kosmos  │       │       │       │       │       │  K1  │ K2-4 │       │       │
        │       │       │       │       │       │Oikos │Bind+ │       │       │
        ─────────────────────────────────────────────────────────────────────────────────
Commons │       │       │       │       │       │       │       │  S1  │ S2-3 │
        │       │       │       │       │       │       │       │Gather│Infra │
        ─────────────────────────────────────────────────────────────────────────────────
                                              ▲ MVP: C7 complete
                                                              ▲ Commons: S3 complete
```

---

## Dependencies

| Dependency | From | To | Status |
|------------|------|-----|--------|
| Dynamis ontology | D1 | D2-D5 | ✅ Ready |
| Energeia R2 | D2 | D3-D5 | ✅ Complete |
| Relay signaling | R1 | C4 | ✅ Ready |
| Landing page | R2 | C5 | ✅ Complete |
| Genesis bootstrap | Spora | All | ✅ Ready |
| MVP complete | C7 | K0-K4 | ⏳ Post-MVP |
| Content roots | K0 | K1-K4 | ⏳ Foundation |
| Oikos entities | K1 | K2 | ⏳ Pending |
| Oikos packaging | K3 | S1 | ⏳ Post-MVP |
| LiveKit integration | S1.5 | S2.4 | ⏳ Post-MVP |
| NixOS reconciliation | S2 | S3 | ⏳ Future |

---

## Immediate Next Actions

### Phase E: Full-Scope Emission

**Objective:** Expand emission to all kosmos content with composed file headers.

| Priority | Task | Description | Status |
|----------|------|-------------|--------|
| 1 | E1 | Composed file headers (agent instructions) | ✅ Complete |
| 2 | E2 | Bond emission (relationships graph) | ✅ Complete |
| 3 | E3 | WAT file emission (stoicheia-portable) | ✅ Complete |
| 4 | E4 | Strategic knowledge (journeys, waypoints, panels) | ✅ Complete |
| 5 | E5 | Expanded entity coverage (541 entities, 17 types) | ✅ Complete |
| 6 | E6 | Klimax hierarchy emission | ⏳ Next |
| 7 | R3 | Production hardening (rate limits, monitoring) | ⏳ Future |
| 8 | C8.4-5 | Live sync (persistent connection, queue flush) | ⏳ Future |

### Blocking Questions

- [ ] Code signing for macOS builds (Apple Developer account)?
- [ ] Windows code signing (Authenticode certificate)?
- [ ] Linux distribution format (AppImage, .deb, Flatpak)?

### Success Criteria (MVP Complete ✅)

- [x] C1: App launches, shows entity count (754) ✅
- [x] C2: New user has mnemonic + persona ✅
- [x] C3: Link created and copied to clipboard ✅
- [x] C4: Two apps connect via relay ✅
- [x] C5: Entrant waiting screen shows ✅
- [x] C6: Video call works, approval triggers flow ✅
- [x] C7: Friend's kosmos has membership ✅ **MVP ACHIEVED**
- [~] C8: Content syncs between members ← C8.1-3 ✅ (progress UI), C8.4-5 future
- [~] C9: Edge cases handled ← C9.1-3 ✅ (expiry, single-use, revocation), C9.4-6 future

---

## Full-Circle Genesis

Full-circle genesis is self-verifying coherence: the kosmos can emit itself, re-bootstrap from emission, and emit again with identical output.

### Why This Matters for the Roadmap

| Roadmap Concern | How Full-Circle Genesis Addresses It |
|-----------------|--------------------------------------|
| **Bootstrap reliability** | Emitted content IS verified bootstrap source. C1 (Foundation) uses content that has passed full-circle verification. |
| **Recovery** | If kosmos.db is lost, re-bootstrap from emitted files. Mnemonic + emitted content = full recovery. |
| **Distribution** | Phase K (Oikos packaging) uses emit-genesis to create distributable packages. Content hashes verify integrity. |
| **Federation** | Phase C8 (Sync) uses phoreta bundles. Full-circle proves phoreta → import → re-export produces identical content. |
| **Validation** | Phase V (Validation) is verified end-to-end: schema → types → praxeis → emit → re-bootstrap → identical schema. |

### The Verification Cycle

```
┌──────────────────────────────────────────────────────────────────────┐
│                    FULL-CIRCLE GENESIS                               │
├──────────────────────────────────────────────────────────────────────┤
│                                                                      │
│   kosmos.db (754 entities after bootstrap)                          │
│       │                                                              │
│       ▼                                                              │
│   demiurge/emit-genesis                                              │
│       │  output_path: "./chora-output"                               │
│       ▼                                                              │
│   chora-output/                                                      │
│   ├── arche/          (eidos, desmos, stoicheion — constitutional)   │
│   ├── spora/          (personas, circles, definitions, praxeis)     │
│   ├── oikoi/          (dev, prod packages if any)                   │
│   └── MANIFEST.yaml   (hash, file list, entity counts)              │
│       │                                                              │
│       ▼ hash = H1                                                    │
│                                                                      │
│   bootstrap(chora-output/) → kosmos-2.db                            │
│       │                                                              │
│       ▼                                                              │
│   demiurge/emit-genesis → chora-output-2/                           │
│       │                                                              │
│       ▼ hash = H2                                                    │
│                                                                      │
│   demiurge/verify-full-circle                                        │
│       │  hash_a: H1, hash_b: H2                                      │
│       ▼                                                              │
│   H1 == H2 ✓ COHERENT                                                │
│                                                                      │
└──────────────────────────────────────────────────────────────────────┘
```

### Caller Patterns and Constitutional Content

Not all content is equal. The distinction that enables full-circle verification:

| Content Type | Caller Pattern | Can Re-derive? | Examples |
|-------------|----------------|----------------|----------|
| **Constitutional** | `literal` only | No — foundational | arche (eidos, desmos, stoicheion), seed expressions |
| **Derivable** | `generated`, `queried`, `computed` | Yes | Reference docs, indexes, status reports |

Constitutional content uses `literal` caller because it cannot be derived from anything else.
Derivable content CAN use `generated` (LLM inference), but must be **baked** before emission to ensure identical output.

The `demiurge/bake-oikos` praxis resolves generation specs to literals. Published oikos-prod contains only literals.

### Implementation

| Praxis | Purpose | Status |
|--------|---------|--------|
| `demiurge/emit-genesis` | Emit all genesis content with BLAKE3 hash | ✅ Complete |
| `demiurge/verify-full-circle` | Compare two emission hashes | ✅ Complete |
| `hypostasis/export-phoreta` | Export entity bundles for federation | ✅ Complete |
| `hypostasis/import-phoreta` | Import and verify phoreta bundles | ✅ Complete |

---

## Phase E: Full-Scope Emission ⏳ Next Priority

**Objective:** Expand emit-genesis to cover ALL kosmos content with composed file headers.

### Current vs Full Scope

| Currently Emitted (456 entities + 733 bonds) | Missing for Full Scope |
|----------------------------------------------|------------------------|
| eidos (58) | **WAT files** — stoicheia-portable/*.wat |
| desmos (105) | **Oikos manifests** — manifest.yaml files |
| stoicheion (0 - defined in oikoi) | **Patterns/Principles** — spora strategic knowledge |
| persona (2), circle (2) | **Theoria** — crystallized understanding |
| typos (50) | **Journeys/Waypoints** — onboarding entities |
| praxis (239) | **Klimax hierarchy** — scale definitions |
| ✅ **Bonds (733)** | |
| ✅ **File headers** | |

### E1: Composed File Headers ✅ Complete

**Objective:** All emitted files include headers instructing agents not to edit directly.

| Task | Description | Status |
|------|-------------|--------|
| E1.1 | Define `typos-def-file-header` in pege.yaml | ✅ |
| E1.2 | Update emit_cycle to generate headers following artifact pattern | ✅ |
| E1.3 | Support comment styles: `#` (YAML), `//` (Rust/TS), `;;` (WAT), `<!-- -->` (MD) | ✅ |
| E1.4 | Verify full-circle works with headers (hash from entity data, not files) | ✅ |

**Header format (composed from typos-def-file-header):**
```
# =============================================================================
# GENERATED FILE - DO NOT EDIT DIRECTLY
# =============================================================================
# Emitted by: demiurge/emit-genesis
# Source: genesis/arche/eidos.yaml
#
# To modify:
#   1. Edit the source in genesis/
#   2. Re-run emit-genesis
#
# See: genesis/EXTENDING.md
# =============================================================================
```

### E2: Bond Emission ✅ Complete

**Objective:** Emit all bonds as YAML alongside entities.

| Task | Description | Status |
|------|-------------|--------|
| E2.1 | Add `gather_bonds` function to host.rs | ✅ |
| E2.2 | Extend emit-genesis to emit `arche/bonds.yaml` | ✅ |
| E2.3 | Organize bonds by desmos type (sorted by desmos, from, to) | ✅ |
| E2.4 | Update bootstrap to load bond files | ✅ |
| E2.5 | Verify cycle: emit bonds → bootstrap → emit = identical | ✅ |

**Verified:** 733 bonds emitted, full-circle hash identical (blake3:ac09db0756f616f68713c3e9887957303c38933aa547164b9683b51e4d85a06e).

**Output format (compact):**
```yaml
# arche/bonds.yaml
- from: typos-def-file-header
  desmos: authored-by
  to: persona/claude
- from: eidos/praxis
  desmos: typed-by
  to: eidos/eidos
```

### E3: WAT File Emission ✅ Complete

**Objective:** Emit stoicheia-portable WASM source files.

| Task | Description | Status |
|------|-------------|--------|
| E3.1 | Explore existing WAT files in stoicheia-portable | ✅ |
| E3.2 | Emit WAT files with `;;` comment headers | ✅ |
| E3.3 | Read WAT files for cycle verification (strip_header) | ✅ |
| E3.4 | Verify cycle: emit WAT → bootstrap → emit = identical | ✅ |

**WAT files emitted:**
- `tier2-db-find.wat`
- `tier2-db-arise.wat`
- `tier2-db-bind.wat`

**Verified:** 3 WAT files emitted, full-circle hash identical (blake3:eda32204d72e161e223dcc434c912215e66473994014f9044e44d7af2f080f28).

### E4: Strategic Knowledge Emission ✅ Complete

**Objective:** Emit journeys, waypoints, and panels.

| Task | Description | Status |
|------|-------------|--------|
| E4.1 | Explore strategic knowledge entities | ✅ |
| E4.2 | Add journey, waypoint, panel to emission | ✅ |
| E4.3 | Verify cycle: emit strategic → bootstrap → emit = identical | ✅ |

**Entities emitted:**
- 1 journey (onboarding)
- 6 waypoints (onboarding steps)
- 6 panels (onboarding UI)

**Verified:** Full-circle hash identical (blake3:f7ecb4eda0df6c63b2e5ba7c2559c555fb96a3418c016056ddee9de455cb4921).

**Note:** Pattern, principle, and theoria entities are not yet bootstrapped (no instances in spora.yaml). These types exist as eidos but have no instances yet.

### E5: Expanded Entity Coverage ✅ Complete

**Objective:** Emit all bootstrapped entity types, not just core types.

| Task | Description | Status |
|------|-------------|--------|
| E5.1 | Identify missing entity types (dynamis, politeia, soma) | ✅ |
| E5.2 | Add dynamis-function, dynamis-domain to emission | ✅ |
| E5.3 | Add attainment, affordance to emission | ✅ |
| E5.4 | Add hud-region, genesis-marker, animus to emission | ✅ |
| E5.5 | Verify full-circle with expanded types | ✅ |

**Entities emitted (541 total, 17 types):**
- Arche: eidos (58), desmos (105), stoicheion (0)
- Spora: persona (2), circle (2), typos (50), praxis (239), journey (1), waypoint (6), genesis-marker (1)
- Dynamis: function (37), domain (10)
- Politeia: attainment (15), affordance (4)
- Thyra: panel (6), hud-region (4)
- Soma: animus (1)

**Verified:** Full-circle hash identical (blake3:77890584b77adaf0c02310fb8401a11b0117b8f3321fbcf3a864221fd989fac6).

**Note:** ~17 entities remain unemitted (specialized types like expression). These can be added in future E iterations.

### E6: Klimax Hierarchy Emission ⏳ Future

**Objective:** Emit scale definitions (kosmos → psyche).

| Task | Description | Status |
|------|-------------|--------|
| E6.1 | Emit klimax definitions to `klimax/{scale}/` | ⏳ |
| E6.2 | Include DESIGN.md for each scale | ⏳ |
| E6.3 | Verify hierarchical ordering preserved | ⏳ |

### E7: Code Artifact Emission ✅ Complete (Rust), ⏳ TypeScript Pending

**Objective:** Treat Rust/TypeScript as emittable artifacts with provenance.

| Task | Description | Status |
|------|-------------|--------|
| E7.1 | Stoicheion entities drive code generation | ✅ |
| E7.2 | Emit step_types.rs with provenance headers | ✅ |
| E7.3 | Emit TypeScript type definitions with headers | ⏳ → E8 |
| E7.4 | Full-circle verification for generated code | ✅ |

**Implementation (2026-01-26):**
- `emit_cycle` binary generates `step_types.rs` from stoicheion entities in kosmos
- Code hash included in full-circle BLAKE3 verification (H1 == H2)
- `emit_cycle verify` mode compares generated code against existing without overwriting
- Verified hash: `blake3:b51d397730f6c185fe971b02e54da0df5eda91b3b6be5dc994e4ba59468f2580`

**Vision:** All generated code (Step enum, type definitions) is emitted with provenance, enabling:
- Schema change → regenerate → emit → commit (with header showing source)
- Agent sees header → edits schema instead of generated code

### E8: TypeScript Emission ✅ Complete

**Objective:** Generate TypeScript artifacts from eidos definitions.

| Task | Description | Status |
|------|-------------|--------|
| E8.1 | Generate entity type interfaces from `eidos` definitions | ✅ |
| E8.2 | Emit `app/src/types/entities.ts` with provenance headers | ✅ |
| E8.3 | Generate Zustand store slice types from eidos fields | ✅ |
| E8.4 | Include TypeScript in full-circle hash verification | ✅ |

**Source:** `genesis/arche/eidos.yaml` + per-oikos `eide/*.yaml`

**Target Files:**
- `app/src/types/entities.ts` — All entity interfaces
- `app/src/types/[oikos].ts` — Per-oikos type definitions
- `app/src/store/types.ts` — Store state types

**Pattern:**
```typescript
// GENERATED FILE - DO NOT EDIT DIRECTLY
// Source: eidos/circle

export interface Circle {
  id: string;
  name: string;
  description?: string;
  created_at: string;
  // ... fields from eidos definition
}
```

### E9: MCP Dispatch Emission ✅ Complete

**Objective:** Auto-generate MCP tool wrappers from praxis definitions.

| Task | Description | Status |
|------|-------------|--------|
| E9.1 | Generate MCP tool registration from visible praxeis | ✅ |
| E9.2 | Emit dispatch match arms in `kosmos-mcp/src/lib.rs` | ✅ |
| E9.3 | Generate JSON Schema for praxis params | ✅ |
| E9.4 | Include MCP dispatch in full-circle verification | ✅ |

**Source:** `praxis` entities where `visible: true`

**Target Files:**
- `crates/kosmos-mcp/src/generated/tools.rs` — Tool definitions
- `crates/kosmos-mcp/src/generated/dispatch.rs` — Dispatch match arms

**Pattern:**
```rust
// GENERATED FILE - DO NOT EDIT DIRECTLY
// Source: praxis/nous/crystallize-theoria

pub fn register_tools(builder: &mut ToolBuilder) {
    builder.add_tool(Tool {
        name: "nous_crystallize-theoria",
        description: "Crystallize an understanding into theoria",
        input_schema: json!({ /* from praxis.params */ }),
    });
    // ... all visible praxeis
}
```

**Benefit:** Adding a praxis with `visible: true` automatically exposes it as an MCP tool.

### E10: Dynamis Dispatch Emission ✅ Complete

**Objective:** Generate tier-gated substrate dispatch from dynamis definitions.

| Task | Description | Status |
|------|-------------|--------|
| E10.1 | Generate dynamis function dispatch from `dynamis-function` entities | ✅ |
| E10.2 | Emit tier-gated access control in `interpreter/dynamis.rs` | ✅ |
| E10.3 | Generate HostContext method stubs from dynamis API | ✅ |
| E10.4 | Include dynamis dispatch in full-circle verification | ✅ |

**Source:** `genesis/dynamis/eide/dynamis.yaml` (dynamis-function definitions)

**Target Files:**
- `crates/kosmos/src/interpreter/generated/dynamis_dispatch.rs` — Function routing
- `crates/kosmos/src/generated/host_api.rs` — HostContext trait stubs

**Pattern:**
```rust
// GENERATED FILE - DO NOT EDIT DIRECTLY
// Source: dynamis-function/db-find

pub fn dispatch_dynamis(
    ctx: &HostContext,
    function: &str,
    tier: u8,
    args: Value,
) -> Result<Value> {
    // Tier gate: verify caller has sufficient tier
    match function {
        "db-find" => { /* tier 2 required */ }
        "db-arise" => { /* tier 2 required */ }
        // ... all dynamis functions
    }
}
```

**Benefit:** Substrate capabilities are declaratively defined; dispatch is generated.

### E11: Configuration Emission ✅ Complete

**Objective:** Generate configuration files from app metadata entities.

| Task | Description | Status |
|------|-------------|--------|
| E11.1 | Define `app-config` eidos for Tauri metadata | ✅ |
| E11.2 | Emit `tauri.conf.json` from app-config entity | ✅ |
| E11.3 | Include configuration in full-circle verification | ✅ |

**Source:** New `eidos/app-config` with fields: productName, version, identifier, window dimensions

**Target Files:**
- `app/src-tauri/tauri.conf.json` — Tauri configuration

**Pattern:**
```json
{
  "// GENERATED": "from app-config/thyra-desktop",
  "productName": "Thyra",
  "version": "0.1.0",
  "identifier": "com.chora.thyra"
}
```

**Note:** Lower priority — config is stable and rarely changes.

### E12: Reference Documentation Emission ✅ Complete

**Objective:** Generate reference documentation from schema entities.

| Task | Description | Status |
|------|-------------|--------|
| E12.1 | Generate eidos reference (field tables) from eidos entities | ✅ |
| E12.2 | Generate praxis reference (param tables) from praxis entities | ✅ |
| E12.3 | Generate stoicheion API reference from stoicheion entities | ✅ |
| E12.4 | Emit per-oikos `REFERENCE.md` files | ✅ |

**Source:** All eidos, praxis, stoicheion, desmos entities

**Target Files:**
- `genesis/[oikos]/REFERENCE.md` — Per-oikos reference
- `docs/api/steps.md` — Stoicheion API reference
- `docs/api/praxeis.md` — Praxis reference

**Pattern:**
```markdown
<!-- GENERATED FILE - DO NOT EDIT DIRECTLY -->
<!-- Source: eidos/circle, eidos/persona, ... -->

# Politeia Reference

## Eide

### circle
| Field | Type | Required | Description |
|-------|------|----------|-------------|
| name | string | ✓ | Circle name |
| description | string | | Optional description |
```

**Benefit:** Documentation stays in sync with schema changes.

### Dependencies (Full Coverage)

```
E1 (Headers) ──────────────────────────────────────────────────────┐
                                                                    │
E2 (Bonds) ────────► E3 (WAT) ────► E4 (Strategic) ────► E5 (Manifests)
                                                                    │
                                                    E6 (Klimax) ◄───┘
                                                         │
                                                    E7 (Rust) ✅
                                                         │
                    ┌────────────────────────────────────┼────────────────────────────────────┐
                    │                                    │                                    │
               E8 (TypeScript)                    E9 (MCP Dispatch)                  E10 (Dynamis)
                    │                                    │                                    │
                    └────────────────────────────────────┼────────────────────────────────────┘
                                                         │
                                              E11 (Config) ─────► E12 (Docs)
                                                         │
                                                    FULL CIRCLE
```

### Priority Order

| Phase | Priority | Benefit | Complexity |
|-------|----------|---------|------------|
| E8 | **High** | Type-safe frontend, eliminate interface drift | Medium |
| E9 | **High** | Auto-expose praxeis, no manual tool wrappers | Medium |
| E10 | **High** | Tier-gated substrate, declarative capabilities | Medium |
| E11 | Low | Stable config, rarely changes | Low |
| E12 | Medium | Docs stay in sync, developer experience | Low |

### Success Criteria

- [x] All emitted files have composed headers (file-header artifact)
- [x] Bonds emit and re-bootstrap identically (733 bonds, E2 verified)
- [x] WAT files emit with `;;` comment headers (3 files, E3 verified)
- [x] Journeys, waypoints, panels emit correctly (13 entities, E4 verified)
- [x] Expanded entity coverage (541 entities, 17 types, E5 verified)
- [x] emit_cycle binary verifies full-scope hash equality (H1 == H2)
- [x] Rust code generation from stoicheion entities (E7.2 verified)
- [x] Code files included in full-circle hash verification (E7.4 verified)
- [ ] TypeScript entity types generated from eidos (E8)
- [ ] MCP tool dispatch generated from praxis (E9)
- [ ] Dynamis dispatch generated from dynamis-function (E10)
- [ ] Configuration generated from app-config (E11)
- [ ] Reference docs generated from schema (E12)

### Full Coverage Summary

**Currently Verified:**
```
✅ step_types.rs (Rust)         — stoicheion → Step enum + structs
✅ 17 entity type YAML          — kosmos entities → emitted YAML
✅ 3 WAT files                  — genesis WAT → emitted with headers
✅ manifest.yaml                — combined BLAKE3 hash
```

**Pending (E8-E12):**
```
⏳ entities.ts (TypeScript)     — eidos → interfaces
⏳ tools.rs (MCP)               — praxis → tool wrappers
⏳ dynamis_dispatch.rs          — dynamis-function → tier gates
⏳ tauri.conf.json              — app-config → Tauri config
⏳ REFERENCE.md                 — schema → documentation
```

**Constitutional (never emitted — IS the source):**
```
📜 93 YAML files in genesis/    — eidos, desmos, praxis, stoicheion definitions
📜 KOSMOGONIA.md               — constitutional root
📜 ARCHITECTURE.md             — constitutional documentation
📜 DESIGN.md files             — oikos design narratives
```

---

## Phase F: Format Consolidation ✅ F1-F3 Complete

**Objective:** Single-stream genesis format where emitted format = source format.

**F1-F3: ✅ Complete** — Target structure defined, composition working, full-circle verified. See [archive/ROADMAP-completed.md](../../archive/ROADMAP-completed.md#phase-f-format-consolidation--f1-f3-complete) for detailed task records.

**Verified Hash (2026-01-26):**
```
blake3:e185be8c61569666f51b7aa064cc211c9a768dfe0051e1bf93f0746f67f3b0fe
```

### F4: Replace Genesis ⏸️ Deferred

**Decision:** Keep per-oikos structure for editing. Use emit_cycle for full-circle verification as needed.

---

## Phase V6: Governed Generation ✅ V6.1-V6.4 Complete

**Objective:** Extend manteia/governed-inference with quality evaluation.

**V6.1-V6.4: ✅ Complete** — Governed envelope, evaluation praxis, extended inference, fill method integration. See [archive/ROADMAP-completed.md](../../archive/ROADMAP-completed.md#phase-v6-governed-generation--v61-v64-complete) for detailed task records.

**Verdicts:**
| Verdict | Meaning | Action |
|---------|---------|--------|
| TRUE | All critical criteria pass | Safe to emit/realize |
| FALSE | Critical criterion failed | Return guidance for fix |
| UNDECIDABLE | Cannot determine | Human review required |

---

## Phase CE: Constitutional Enforcement ✅ CE1-CE4 Complete

**Objective:** Close the gap between KOSMOGONIA promises and implementation — make "impossible to do wrong" actual.

**CE1-CE4: ✅ Complete** — Stoicheion visibility, interpreter gating, praxis linting, full migration. See [archive/ROADMAP-completed.md](../../archive/ROADMAP-completed.md#phase-ce-constitutional-enforcement--ce1-ce4-complete) for detailed task records.

**Core insight:** `arise` and `infer` are escape hatches. `compose` and `governed-inference` are the constitutional interfaces.

**What changes for agents:**
```yaml
# Before (bypasses constitution):
- step: arise
  eidos: theoria
  data: { ... }

# After (follows constitution):
- step: compose
  typos_id: typos-def-theoria
  inputs: { ... }
```

**Exception:** `hypostasis/import-phoreta` — dynamic eidos from incoming bundle requires arise

---

## Proposal Integration Summary

### Dependency Graph

```
                         ┌─────────────────────────────────────────────┐
                         │           Constitutional Enforcement          │
                         │ CE1 (visibility) → CE2 (gating) → CE3 (lint) │
                         │                      ↑                        │
                         │                      │ CE4 (migration)        │
                         └──────────────────────┼────────────────────────┘
                                                │
                      ┌─────────────────────────┼─────────────────────────┐
                      │                         │                         │
              ┌───────▼───────┐         ┌───────▼───────┐
              │ Single-Stream │         │   Governed    │
              │ Genesis (F)   │         │ Generation (V6)│
              ├───────────────┤         ├───────────────┤
              │ F1 → F2 → F3  │◄───────►│ V6.1 → V6.2   │
              │       ↓       │         │       ↓       │
              │      F4       │         │ V6.3 → V6.4   │
              └───────────────┘         └───────────────┘
                      │                         │
                      └──────────┬──────────────┘
                                 │
                         ┌───────▼───────┐
                         │  Phase E      │
                         │ (Emission)    │
                         │ E1-E5 ✅      │
                         └───────────────┘
```

### Recommended Implementation Order

1. **V6.1-V6.3** (Governed Generation core) — Enables quality-gated generation
2. **CE1-CE2** (Visibility + Gating) — Establishes enforcement mechanism
3. **F1** (Target structure definitions) — Creates artifact definitions
4. **CE3** (Praxis linting) — Catches violations at authoring time
5. **V6.4** (Fill method integration) — Enables governed `generated` caller
6. **F2-F3** (Compose and verify) — Uses governed generation for any generated slots
7. **CE4** (Migration) — Replaces all arise/infer with compose/governed-inference
8. **F4** (Replace genesis) — Adopt single-stream format

### Success Criteria

- [ ] governed-inference returns verdicts for generated content
- [ ] `arise` and `infer` are gated — external use rejected
- [ ] All entity creation flows through `compose`
- [ ] All LLM generation flows through `governed-inference`
- [ ] Single-stream format emits and bootstraps identically
- [ ] Full-circle hash verification passes (H1 == H2)

---

## Theoria Crystallized

**T1 (2026-01-23):** Three reconciliation loops discovered during D3 E2E testing — actuality, generation, and schema loops operate at different levels.

**T2 (2026-01-23):** Fix at generation level — when generated code is wrong, fix the generative process (schema + build.rs), not the output. The schema is the single source of truth.

**T3 (2026-01-24):** Full-circle genesis is self-verifying coherence — emit → bootstrap → emit = identical output. This proves the kosmos can reconstitute itself.

**T4 (2026-01-24):** The path to infrastructure is through kosmos, not chora. We don't SSH into servers; we compose infrastructure entities and let reconciliation actualize them. Circles own their infrastructure as entities.

**T5 (2026-01-24):** Content roots embody "where things come from" as entities, not configuration. Graph-driven content sourcing: sources-content-from bonds make provenance traversable. This enables multi-source composition while maintaining the graph-driven pillar.

**T16 (2026-01-25):** Session state lives in chora, not kosmos. The unlocked master seed exists in process memory (chora), not as an entity (kosmos). This separation ensures that copying kosmos.db doesn't grant key access. Kleidoura stores only encrypted material; the decryption happens in chora at runtime.

**T17 (2026-01-25):** Intent/status pattern enables reconciliation. Syndesmos declares what we want (intent: connected), reconciliation senses what is (status: disconnected), and acts to align. This is the dynamis pattern applied to networking. Connection state becomes traversable entities rather than ephemeral process state.

**T18 (2026-01-25):** File headers are composed artifacts. Even "DO NOT EDIT" instructions follow composition — the file-header artifact definition computes comment style from file type, fills source path from provenance, and composes consistently across all emitted content. Nothing escapes composition.

---

## Related Documents

| Document | Purpose |
|----------|---------|
| [KOSMOGONIA.md](./KOSMOGONIA.md) | Constitutional root — ontological foundations |
| [ARCHITECTURE.md](./ARCHITECTURE.md) | Technical architecture — development pillars |
| [demiurge/DESIGN.md](./demiurge/DESIGN.md) | Composition layer philosophy |
| [hypostasis/DESIGN.md](./hypostasis/DESIGN.md) | Phoreta, cryptographic identity, kleidoura |
| [aither/DESIGN.md](./aither/DESIGN.md) | Network transport, syndesmos, presence |
| [propylon/DESIGN.md](./propylon/DESIGN.md) | Invitation link philosophy |
| [politeia/DESIGN.md](./politeia/DESIGN.md) | Circles and governance |
| [soma/DESIGN.md](./soma/DESIGN.md) | Embodiment and channels |
| [thyra/DESIGN.md](./thyra/DESIGN.md) | Application architecture |
| [thyra/ALIGNMENT.md](./thyra/ALIGNMENT.md) | Design review (6 lenses) |
| [thyra/END-TO-END.md](./thyra/END-TO-END.md) | Invitation flow architecture |
| [archive/dynamis-pillar-alignment.md](../../archive/dynamis-pillar-alignment.md) | Dynamis pillar alignment (✅ complete, archived) |
| [agora/DESIGN.md](./agora/DESIGN.md) | Agora oikos — spatial gathering (Phase S) |
| [../../docs/proposals/genesis-restructure.md](../../docs/proposals/genesis-restructure.md) | Genesis restructure proposal (Phase 2 ✅, Phases 3-8 future) |

---

*χώρα receives. The roadmap is how we navigate toward that receiving.*
*Traces to: expression/genesis-root*
*Created: 2026-01-23*
*Consolidated: 2026-01-24*
*Updated: 2026-01-25 — Phase E: E1-E5 complete (541 entities, 17 types, hash blake3:77890584b77adaf0c02310fb8401a11b0117b8f3321fbcf3a864221fd989fac6)*
