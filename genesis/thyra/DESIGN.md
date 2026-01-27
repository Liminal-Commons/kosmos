# Thyra: The Door

*A design for the boundary membrane.*

---

## The Problem

The kosmos needs to perceive and emit — to receive from and send to the world outside:

- **Streams** flow media (voice, text, documents) but have no graph representation
- **Expressions** are the commitment boundary — when ephemeral becomes durable
- **Signaling** bootstraps P2P connections but has no supervision
- **Channels** connect chorai but have no reconciler pattern

V8 has process actuality (daemons, tasks). It lacks media, network, and signaling actuality.

**Thyra makes the boundary visible and supervised.**

---

## Implementation Status

| Component | Status | Location |
|-----------|--------|----------|
| **Perception (Aisthesis)** | | |
| `stream` eidos | **Complete** | `eide/thyra.yaml` |
| `expression` eidos | **Complete** | `eide/thyra.yaml` |
| `accumulation` eidos | **Complete** | `eide/thyra.yaml` |
| `utterance` eidos | **Complete** | `eide/thyra.yaml` |
| `signaling-session` eidos | **Complete** | `spora/spora.yaml` |
| `data-channel` eidos | **Complete** | `spora/spora.yaml` |
| Network actuality mode | **Complete** | `kosmos/src/host.rs` |
| Signaling actuality mode | **Complete** | `kosmos/src/host.rs` |
| Thyra desmoi (perception) | **Complete** | `desmoi/thyra.yaml` |
| Expression praxeis | **Complete** | `praxeis/thyra.yaml` |
| Stream praxeis | **Complete** | `praxeis/thyra.yaml` |
| Accumulation praxeis | **Complete** | `praxeis/thyra.yaml` |
| Aither praxeis | **Complete** | `genesis/aither/praxeis/aither.yaml` |
| **Emission (Ekthesis)** | | |
| `layout` eidos | **Complete** | `eide/thyra.yaml` |
| `panel` eidos | **Complete** | `eide/thyra.yaml` |
| `style-theme` eidos | **Complete** | `eide/thyra.yaml` |
| `render-intent` eidos | **Complete** | `eide/thyra.yaml` |
| `workspace` eidos | **Complete** | `eide/thyra.yaml` |
| `voice-pipeline-config` eidos | **Complete** | `eide/thyra.yaml` |
| Thyra desmoi (rendering) | **Complete** | `desmoi/thyra.yaml` |
| Artifact definitions | **Complete** | `spora/definitions/thyra.yaml` |
| Opsis praxeis | Planned | `praxeis/opsis.yaml` |
| Tauri substrate bridge | Planned | `app/tauri/` |
| **Oikoi-Provided Renderers** | | |
| `render-spec` eidos | **Complete** | `eide/thyra.yaml` |
| `render_strategy` on renderer | **Complete** | `eide/thyra.yaml` |
| Core strategy dispatch | **Partial** | `app/src/components/Region.tsx` |
| Declarative renderer | Planned | Needs render-spec interpreter |
| Web Component loader | Planned | Dynamic import + Custom Elements |
| WASM loader | Future | Cross-platform module loading |
| **Infrastructure** | | |
| Media actuality mode | Planned | `kosmos/src/host.rs` |
| Display dynamis | Planned | `app/tauri/src-tauri/` |

**Phase 17.1-17.4, 17.6 complete** (2026-01-20): Core perception eide, desmoi, and praxeis.
**Phase 18 ontology complete** (2026-01-21): Rendering eide, desmoi, voice pipeline, workspace.
**Phase 19.1 oikoi-provided renderers** (2026-01-27): render_strategy field, render-spec eidos, extensible dispatch.

---

## The Cosmological Foundation

From the genesis DESIGN.md:

> Thyra is the boundary membrane. It is where:
> - Ephemeral becomes durable (streams → expressions)
> - Human enters kosmos (perception)
> - Kosmos reaches human (emission)
> - Intent becomes actuality (reconciler pattern)

The central concept is the **commitment boundary** — the moment when ephemeral stream content becomes durable entity. This is the "send moment."

---

## Architecture

### 1. The Boundary Flow

```
┌─────────────────────────────────────────────────────────────────┐
│                        THYRA                                     │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│   PERCEPTION (aisthesis)              EMISSION (ekthesis)       │
│   ──────────────────────              ───────────────────        │
│   Inward flow                         Outward flow               │
│                                                                  │
│   stream(voice,inward)                expression(response)       │
│         │                                   │                    │
│         ▼                                   ▼                    │
│   accumulation                         TTS stream               │
│         │                                   │                    │
│         ▼ (commit)                          ▼                    │
│   expression(human)                    audio output              │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

### 2. Actuality Modes

Building on Phase 16's process actuality:

| Mode | Manifest | Sense | Unmanifest | Eide |
|------|----------|-------|------------|------|
| `process` | spawn | status | kill | daemon, task |
| `media` | capture_start | capture_status | capture_stop | stream |
| `network` | connect | connection_status | disconnect | aither-channel |
| `signaling` | ws_connect | poll | close | signaling-session |

### 3. Core Eide

| Eidos | What It Is | Actuality |
|-------|------------|-----------|
| `stream` | Bounded media flow (voice, text, document) | media |
| `expression` | Intentional contribution (commitment boundary) | none |
| `accumulation` | Buffer state awaiting commitment | none |
| `utterance` | VAD-bounded speech segment | none |
| `signaling-session` | WebSocket connection for SDP exchange | signaling |
| `data-channel` | WebRTC P2P data channel | network |

### 4. Core Desmoi

| Desmos | From | To | Meaning |
|--------|------|-----|--------|
| `expressed-in` | expression | circle | Expression scoped to circle |
| `transforms-to` | stream | stream | Stream pipeline transformation |
| `produces` | daemon | stream | Daemon produces stream content |
| `consumes` | daemon | stream | Daemon consumes stream content |
| `in-reply-to` | expression | expression | Conversation threading |
| `derives-from` | expression | stream, artifact | Expression provenance |
| `contributes-to` | utterance | expression | Utterance → expression |
| `bootstrapped-by` | data-channel | signaling-session | Channel origin |

### 5. The Commitment Boundary

Expression modes signal stance:

| Mode | Signals | Invites |
|------|---------|---------|
| `declaration` | stating what is understood | acknowledgment or correction |
| `inquiry` | inviting exploration | explanation or options |
| `suggestion` | offering possibility | acceptance or alternative |
| `request` | asking for action | compliance or negotiation |
| `proposal` | co-creating direction | refinement or commitment |

### 6. Stream Layers

Voice perception flows through layers:

```
Layer 1: Audio stream (voice capture daemon produces)
    │
    ▼ transforms-to
Layer 2: Transcription stream (whisper daemon produces)
    │
    ▼ transforms-to
Layer 3: Clarified text stream (clarifier produces)
    │
    ▼ commitment boundary
Expression entity
```

Only Layer 1 streams have recordings. Layer 2/3 are ephemeral.

---

## Part II: Emission (Ekthesis)

*Rendering kosmos state to human perception.*

### The Triad

**Substrate provides. Thyra renders. Chora receives.**

- **Substrate** (Tauri, browser) provides dynamis — the capability to actualize
- **Thyra** produces render state — what should be visible, where, how
- **Chora** receives the actualized rendering — the user sees

### 7. Rendering Architecture

```
┌─────────────────────────────────────────────────────────────────────┐
│                     THYRA RENDERING                                  │
├─────────────────────────────────────────────────────────────────────┤
│                                                                      │
│   KOSMOS STATE                        SUBSTRATE ACTUALITY            │
│   ─────────────                       ───────────────────            │
│                                                                      │
│   layout         ──────────────►      HUD regions                    │
│   panel          ──────────────►      React/Solid components         │
│   style-theme    ──────────────►      CSS/styles                     │
│   workspace      ──────────────►      Tab bar state                  │
│   accumulation   ──────────────►      Voice bar content              │
│   expression[]   ──────────────►      Chat thread                    │
│   artifact       ──────────────►      Preview panel                  │
│                                                                      │
│              ◄─── reconciler loop ───►                               │
│                                                                      │
└─────────────────────────────────────────────────────────────────────┘
```

### 8. Rendering Eide

| Eidos | Purpose | Key Fields |
|-------|---------|------------|
| `layout` | Top-level HUD structure | regions[], active |
| `panel` | Renderable content area | render_type, source_query, region_id |
| `style-theme` | Visual styling | palette, density, typography |
| `render-intent` | Reconciler intent | visible_entities[], intent_status |
| `workspace` | Open artifacts and focus | open_artifact_ids[], focused_artifact_id |
| `voice-pipeline-config` | Homoiconic voice config | transcription_*, clarification_* |

#### Homoiconic Rendering Eide

Configuration that is usually implicit becomes entities with bonds — traversable, queryable, cacheable.

| Eidos | Purpose | Key Fields |
|-------|---------|------------|
| `render-type` | How an eidos should render | source_eidos, grouping, sort_by |
| `renderer` | Component that implements a render-type | render_strategy, component_path, substrate, accepts_render_types |
| `render-spec` | Declarative rendering specification | target_eidos, fields_to_display, layout_template |
| `widget` | Field-level display component | field_types, editable, config_schema |
| `content-root` | Where content comes from (constitutional) | path, constitutional, order |

**Why homoiconic:**
- **render-type**: Display configuration for an eidos. Instead of hard-coded enum values, render-types are entities. Adding a new render type = creating an entity, not code change.
- **renderer**: Maps render-types to substrate components. The renderer bonds to its render-type via `renders-with`. Multiple renderers can implement the same render-type for different substrates (web, native, terminal). Renderers declare a `render_strategy` (core, declarative, web-component, wasm) that determines how they're loaded — enabling oikoi to provide their own renderers without core changes.
- **render-spec**: Declarative rendering template for the declarative strategy. Defines what fields to display, layout template, and style bindings. Enables graph-driven rendering without code.
- **widget**: Field-level display. Instead of hard-coding how fields render, widgets are entities that bond to field-defs via `displays-as`. Same field type can render differently in different contexts.
- **content-root**: Where bootstrap loads content from. The filesystem paths are entities with bonds, not hard-coded paths. Adding a content source = creating an entity with `sources-content-from` bond.

### 9. Rendering Desmoi

| Desmos | From → To | Meaning |
|--------|-----------|---------|
| `renders-in` | panel → hud-region | Panel location |
| `styled-by` | entity → style-theme | Visual appearance |
| `shows` | panel → entity | What's surfaced |
| `child-of` | hud-region → layout | Structural hierarchy |
| `active-layout` | circle → layout | Current layout |
| `active-theme` | circle → style-theme | Current theme |
| `workspace-of` | workspace → animus | Ownership |
| `has-open` | workspace → artifact | Open tabs |
| `focused-on` | workspace → artifact | Active tab |
| `active-voice-config` | animus → voice-pipeline-config | Voice settings |

#### Homoiconic Rendering Desmoi

| Desmos | From → To | Meaning |
|--------|-----------|---------|
| `renders-with` | render-type → renderer | Display implementation |
| `displays-as` | field-def → widget | Field-level rendering |
| `sources-content-from` | entity → content-root | Content provenance |
| `applies-to-eidos` | render-type → eidos | Type-level binding |

**Usage patterns:**

```
# Discover how to render an expression
eidos/expression
    │
    └── applies-to-eidos ◄─── render-type/expression-thread
                                    │
                                    └── renders-with ──► renderer/ExpressionThread

# Discover how to display a timestamp field
field-def/expression.expressed_at
    │
    └── displays-as ──► widget/timestamp-relative

# Discover where content comes from
eidos/theoria
    │
    └── sources-content-from ──► content-root/nous
```

The UI traverses bonds to discover rendering. Display configuration is data, not code.

### 10. Panel Render Types

```yaml
render_type:
  values:
    - entity-list          # Generic list of entities
    - expression-thread    # Conversation/chat view
    - presence-list        # Who's here (animi in circle)
    - journey-view         # Journey with waypoints
    - theoria-card         # Single theoria display
    - affordance-bar       # Available actions
    - accumulation-buffer  # Voice bar / input buffer
    - artifact-preview     # Rendered artifact content
    - artifact-tabs        # Tab bar for switching artifacts
    - workspace-view       # Open artifacts grid/list
    - custom               # Custom render component
```

### 11. Two-Path Rendering

```
┌─────────────────────────────────────────────────────────────────────┐
│                     TWO PATHS TO RENDER                              │
├─────────────────────────────────────────────────────────────────────┤
│                                                                      │
│   STRUCTURAL PATH (reconciler)        CONTENT PATH (direct)          │
│   ────────────────────────────        ─────────────────────          │
│                                                                      │
│   Layout changes                      Entity data changes            │
│   Panel addition/removal              Accumulation content           │
│   Region visibility                   Expression updates             │
│   Theme switching                     Artifact content               │
│                                                                      │
│   ┌────────┐                          ┌────────┐                     │
│   │ intent │                          │ entity │                     │
│   └───┬────┘                          └───┬────┘                     │
│       ▼                                   ▼                          │
│   ┌────────┐                          ┌────────────┐                 │
│   │ sense  │                          │ emit event │                 │
│   └───┬────┘                          └─────┬──────┘                 │
│       ▼                                     ▼                        │
│   ┌──────────┐                        ┌──────────────┐               │
│   │reconcile │                        │ direct update│               │
│   └───┬──────┘                        └──────────────┘               │
│       ▼                                                              │
│   ┌────────┐                                                         │
│   │ render │                                                         │
│   └────────┘                                                         │
│                                                                      │
└─────────────────────────────────────────────────────────────────────┘
```

**Why two paths:**
- Structural changes are infrequent → full reconciler is fine
- Content changes are frequent → direct update avoids latency
- The panel subscribes to entity changes, not reconciler events

### 12. Oikoi-Provided Renderers

Oikoi can bring their own renderers without modifying Thyra core. This enables domain-specific visualization while maintaining graph-driven architecture.

#### Render Strategies

Renderers declare a `render_strategy` that determines how they're loaded and executed:

| Strategy | Loading | Use Case | Example |
|----------|---------|----------|---------|
| `core` | Static import at build time | Core Thyra components | ExpressionThread, CircleList |
| `declarative` | Graph-driven from render-spec | Simple entity display | Theoria card, entity list |
| `web-component` | Dynamic Custom Element | Oikos-provided UI | Custom visualizations |
| `wasm` | WebAssembly module | Cross-platform, compute-heavy | 3D rendering, data viz |

#### Architecture Diagram

```
┌─────────────────────────────────────────────────────────────────────────┐
│                     RENDERER DISPATCH                                    │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                          │
│   panel.render_type ──► gather renderers ──► select by strategy          │
│                              │                      │                    │
│                              ▼                      ▼                    │
│                     ┌────────────────────────────────────────┐           │
│                     │         render_strategy                 │           │
│                     ├──────────┬──────────┬──────────┬───────┤           │
│                     │   core   │declarative│web-comp │ wasm  │           │
│                     ├──────────┼──────────┼──────────┼───────┤           │
│                     │component_│render_   │component_│wasm_  │           │
│                     │  path    │spec_id   │  url     │module │           │
│                     └────┬─────┴────┬─────┴────┬─────┴───┬───┘           │
│                          │          │          │         │               │
│                          ▼          ▼          ▼         ▼               │
│                     ┌────────┐ ┌────────┐ ┌────────┐ ┌────────┐          │
│                     │ Static │ │ Graph  │ │ Load   │ │ Load   │          │
│                     │ import │ │traverse│ │  URL   │ │ WASM   │          │
│                     └────┬───┘ └────┬───┘ └────┬───┘ └────┬───┘          │
│                          │          │          │         │               │
│                          └──────────┴──────────┴─────────┘               │
│                                         │                                │
│                                         ▼                                │
│                                    ┌─────────┐                           │
│                                    │ Render  │                           │
│                                    └─────────┘                           │
│                                                                          │
└─────────────────────────────────────────────────────────────────────────┘
```

#### Strategy: Core (render_strategy=core)

Built-in components with static imports. This is the default for Thyra's bundled renderers.

```yaml
renderer/ExpressionThread:
  render_strategy: core
  component_path: panels/ExpressionThread
  substrate: web
  accepts_render_types: [render-type/expression-thread]
```

The component registry maps `component_path` to actual component imports at build time. This provides compile-time guarantees but requires core changes for new renderers.

#### Strategy: Declarative (render_strategy=declarative)

Graph-driven rendering from a `render-spec` entity. No code required — rendering is pure data.

```yaml
renderer/TheoriaSimple:
  render_strategy: declarative
  render_spec_id: render-spec/theoria-card
  substrate: universal
  accepts_render_types: [render-type/theoria-display]

render-spec/theoria-card:
  target_eidos: theoria
  fields_to_display:
    - field: insight
      widget_id: widget/markdown-text
    - field: domain
      label: "Domain"
    - field: status
  layout_template: |
    <div class="theoria-card">
      <div class="theoria-insight">{insight}</div>
      <div class="theoria-meta">
        <span class="domain">{domain}</span>
        <span class="status">{status}</span>
      </div>
    </div>
  style_bindings:
    theoria-card: "card rounded shadow"
    theoria-insight: "text-lg font-medium"
```

**Advantages:**
- No code deployment for new renderers
- Fully inspectable — the rendering logic is in the graph
- Versioned — render-spec is an entity with provenance
- Oikos can define visual presentation as data

#### Strategy: Web Component (render_strategy=web-component)

Dynamic Custom Elements loaded at runtime. Oikoi bundle their renderers as standard Web Components.

```yaml
renderer/CustomViz:
  render_strategy: web-component
  component_url: https://oikos.example.com/components/custom-viz.js
  substrate: web
  accepts_render_types: [render-type/custom-visualization]
  props_schema:
    type: object
    properties:
      entity_id: { type: string }
      config: { type: object }
```

**Loading flow:**
1. UI encounters panel with matching render_type
2. Fetch and evaluate component_url (cached)
3. Register Custom Element if not already defined
4. Render `<custom-viz entity-id="..." config="..."/>`

**Security considerations:**
- Components loaded from trusted oikos sources only
- CSP (Content Security Policy) restricts script sources
- Sandboxing via Shadow DOM isolation
- Props schema validation before passing data

#### Strategy: WASM (render_strategy=wasm)

WebAssembly modules for compute-intensive or cross-platform rendering.

```yaml
renderer/DataViz3D:
  render_strategy: wasm
  wasm_module: https://oikos.example.com/modules/data-viz-3d.wasm
  substrate: universal
  accepts_render_types: [render-type/3d-visualization]
  props_schema:
    type: object
    properties:
      entity_id: { type: string }
      view_config: { type: object }
```

**Use cases:**
- 3D visualization (Three.js/Babylon compiled to WASM)
- Data processing (chart rendering, analytics)
- Cross-platform native rendering (terminal, native apps)

#### Oikos Manifest Extension

Oikoi declare their renderers in the manifest:

```yaml
# oikos/my-viz/manifest.yaml
id: oikos/my-viz
name: my-viz
version: 0.1.0

provides:
  eide:
    - custom-visualization
  renderers:
    - renderer/MyVizComponent
  render_specs:
    - render-spec/custom-viz-display

renderer_bundle:
  web_component_url: https://cdn.example.com/my-viz/bundle.js
  wasm_module_url: https://cdn.example.com/my-viz/module.wasm
```

When an oikos is loaded, its renderers are registered and available for panels.

#### Fallback Chain

Renderers can specify fallbacks for graceful degradation:

```yaml
renderer/RichTheoria:
  render_strategy: web-component
  component_url: https://oikos.example.com/rich-theoria.js
  fallback_renderer_id: renderer/TheoriaSimple  # Declarative fallback
  accepts_render_types: [render-type/theoria-display]

renderer/TheoriaSimple:
  render_strategy: declarative
  render_spec_id: render-spec/theoria-card
  # No fallback — this is the baseline
```

**Resolution order:**
1. Primary renderer loads successfully → use it
2. Primary fails → try fallback_renderer_id
3. Fallback fails → render placeholder with error

#### Implementation Status

| Component | Status | Notes |
|-----------|--------|-------|
| `render_strategy` field | **Complete** | Added to renderer eidos |
| `render-spec` eidos | **Complete** | For declarative strategy |
| Core strategy dispatch | **Partial** | Region.tsx uses component registry |
| Declarative renderer | **Planned** | Needs render-spec interpreter |
| Web Component loader | **Planned** | Dynamic import + Custom Elements |
| WASM loader | **Future** | Cross-platform module loading |

---

## Part III: Voice Pipeline (Clarification)

*The path from spoken word to expression.*

### 12. The Clarification Flow

```
┌─────────────────────────────────────────────────────────────────────┐
│                        VOICE BAR FLOW                                │
├─────────────────────────────────────────────────────────────────────┤
│                                                                      │
│   STREAM (voice, inward)                                            │
│      │                                                               │
│      │ VAD detects speech                                            │
│      ▼                                                               │
│   UTTERANCE                                                          │
│      │ transcription: "um so I think we should uh clarify this"     │
│      │                                                               │
│      ▼                                                               │
│   ACCUMULATION                                                       │
│      │                                                               │
│      │  raw_content: "um so I think we should uh clarify this"      │
│      │  raw_fragments: [{text: "...", utterance_id, timestamp}]     │
│      │  capture_state: listening → processing                        │
│      │  clarification_status: pending → clarifying                   │
│      │                                                               │
│      │ ─────── manteia/governed-inference ───────                    │
│      │         (fast model: claude-3-haiku)                          │
│      │         (authorized_by: stream)                               │
│      │                                                               │
│      │  clarification_status: clarifying → clarified                 │
│      │  content: "I think we should clarify this"  ← CLEAN           │
│      │  clarification_generation_id: gen/abc123                      │
│      │                                                               │
│      │ [USER EDITS if needed]                                        │
│      │  clarification_status: clarified → manual                     │
│      │                                                               │
│      ▼ COMMIT                                                        │
│   EXPRESSION                                                         │
│      content: "I think we should clarify this"                       │
│      mode: declaration                                               │
│      expressed_by: persona/victor                                    │
│      circle_id: circle/self                                          │
│                                                                      │
└─────────────────────────────────────────────────────────────────────┘
```

### 13. Accumulation State Machine

```
                      ┌─────────────┐
                      │   created   │
                      └──────┬──────┘
                             │ begin-accumulation
                             ▼
     ┌───────────────────────────────────────────────┐
     │                   ACTIVE                       │
     │                                                │
     │  capture_state:        clarification_status:  │
     │  ┌──────────┐         ┌─────────┐             │
     │  │ inactive │────────►│ pending │             │
     │  └──────────┘ hotkey  └────┬────┘             │
     │       ▲                    │ STT complete     │
     │       │                    ▼                  │
     │  ┌──────────┐         ┌───────────┐           │
     │  │listening │         │clarifying │           │
     │  └────┬─────┘         └─────┬─────┘           │
     │       │ VAD end             │ LLM complete    │
     │       ▼                     ▼                 │
     │  ┌───────────┐        ┌───────────┐           │
     │  │processing │        │ clarified │           │
     │  └───────────┘        └─────┬─────┘           │
     │                             │ user edit       │
     │                             ▼                 │
     │                       ┌──────────┐            │
     │                       │  manual  │            │
     │                       └──────────┘            │
     └───────────────────────────────────────────────┘
             │                    │
        abandon                 commit
             │                    │
             ▼                    ▼
     ┌───────────┐         ┌───────────┐
     │ abandoned │         │ committed │
     └───────────┘         └───────────┘
```

### 14. Voice Pipeline Configuration

```yaml
voice-pipeline-config:
  # Audio capture
  audio_input_device: "default"
  vad_enabled: true
  vad_silence_duration_ms: 2000
  input_mode: toggle  # push-to-talk | toggle | always-on

  # Transcription
  transcription_provider: deepgram  # whisper-local | whisper-cloud | assembly-ai
  transcription_language: "en"
  transcription_model: "nova-2"
  transcription_streaming: true

  # Clarification
  clarification_enabled: true
  clarification_model: "claude-3-haiku"
  clarification_system_prompt: |
    You are a speech clarifier. Receive raw transcripts of spoken text.
    Output only the clarified version. Remove disfluencies (um, ah, uh).
    Fix grammar and punctuation. Preserve the speaker's distinct voice and intent.
    Do not add conversational filler. Do not explain. Just output the clarified text.
```

This configuration is **homoiconic** — it's an entity in the kosmos, composed via artifact definition.

### 15. Latency Budget

| Stage | Target | Notes |
|-------|--------|-------|
| VAD silence detection | 2000ms | Configurable |
| STT (streaming) | ~300ms | Deepgram Nova-2 |
| Clarification | ~800ms | Haiku is fast |
| **Total** | **~3100ms** | From end of speech |

**Mitigation strategy:**
- Raw transcript appears immediately (streaming)
- Visual indicator shows "clarifying..."
- Clarified version replaces raw with smooth transition
- User can edit at any point (sets status to `manual`)

---

## Part IV: Workspace and Artifacts

*What the animus is working on.*

### 16. Workspace Model

```
┌─────────────────────────────────────────────────────────────────────┐
│  WORKSPACE                                                           │
├─────────────────────────────────────────────────────────────────────┤
│                                                                      │
│  animus/claude  ◄──── workspace-of ──── workspace/main              │
│                                                                      │
│  workspace/main:                                                     │
│    open_artifact_ids: [art/a, art/b, art/c]  ◄── has-open           │
│    focused_artifact_id: art/b                 ◄── focused-on        │
│                                                                      │
│  UI Rendering:                                                       │
│                                                                      │
│  ┌─────────────────────────────────────────────────────────────┐    │
│  │  [art/a]  [art/b●]  [art/c]                                  │   │
│  ├─────────────────────────────────────────────────────────────┤    │
│  │                                                              │    │
│  │  Content of art/b (focused artifact)                         │    │
│  │                                                              │    │
│  │  ┌─────────────────────────────────────────────────────────┐│    │
│  │  │                                                          ││    │
│  │  │  Rendered artifact preview                               ││    │
│  │  │                                                          ││    │
│  │  └─────────────────────────────────────────────────────────┘│    │
│  │                                                              │    │
│  └─────────────────────────────────────────────────────────────┘    │
│                                                                      │
└─────────────────────────────────────────────────────────────────────┘
```

### 17. Default Layout (chora)

```
┌─────────────────────────────────────────────────────────────────────┐
│  chora                                                ◉ victor       │
├────────────┬────────────────────────────┬───────────────────────────┤
│            │                            │                           │
│  circles   │  [artifact tabs]           │   expressions             │
│            │                            │                           │
│  • self    │  ┌──────────────────────┐  │   > What are you          │
│  • team    │  │                      │  │     working on?           │
│            │  │  artifact preview    │  │                           │
│  journeys  │  │                      │  │   I'm exploring the       │
│            │  │                      │  │   rendering ontology...   │
│  • render→ │  └──────────────────────┘  │                           │
│            │                            │   theoria:                │
│            │                            │   "thyra renders"         │
├────────────┴────────────────────────────┴───────────────────────────┤
│  [◉ voice]  I think we should clarify this              [send]      │
└─────────────────────────────────────────────────────────────────────┘

Regions:
  navigation (sidebar, left, 240px)  — circles, journeys
  artifacts  (main, center)          — artifact preview with tabs
  expressions (contextual, right, 320px) — expression thread
  input (toolbar, bottom, 80px)      — accumulation buffer
```

---

## Part V: Tauri Substrate

*Substrate provides dynamis.*

### 18. Architecture

```
┌─────────────────────────────────────────────────────────────────────┐
│                        TAURI APP                                     │
├────────────────────────────┬────────────────────────────────────────┤
│       Rust Backend         │         WebView Frontend               │
│                            │                                        │
│  ┌──────────────────────┐  │  ┌──────────────────────────────────┐  │
│  │      kosmos       │  │  │        React/Solid/Svelte        │  │
│  │                      │  │  │                                  │  │
│  │  entities            │◄─┼──┤  HUD components                  │  │
│  │  bonds               │  │  │  panels                          │  │
│  │  praxeis             │──┼─►│  affordances                     │  │
│  │                      │  │  │                                  │  │
│  └──────────────────────┘  │  └──────────────────────────────────┘  │
│           │                │              ▲                         │
│           ▼                │              │                         │
│  ┌──────────────────────┐  │  ┌───────────┴────────────────────┐    │
│  │   display dynamis    │──┼─►│      Tauri IPC Bridge          │    │
│  │   audio dynamis      │  │  │      (invoke/listen)           │    │
│  └──────────────────────┘  │  └────────────────────────────────┘    │
└────────────────────────────┴────────────────────────────────────────┘
```

### 19. IPC Protocol

```typescript
// Frontend listens for render state
listen('kosmos:render-state', (event) => {
  const { regions, panels, entities } = event.payload;
  updateUI(regions, panels, entities);
});

// Frontend listens for entity changes (content path)
listen('kosmos:entity-changed', (event) => {
  const { entity_id, entity } = event.payload;
  updateEntity(entity_id, entity);
});

// Frontend invokes praxeis
invoke('kosmos:invoke-praxis', {
  praxis_id: 'thyra/express',
  params: { content: '...', mode: 'declaration' }
});
```

### 20. Dynamis Bridge (Rust)

```rust
// Emit render state to frontend
fn emit_render_state(app: &AppHandle, state: RenderState) {
    app.emit_all("kosmos:render-state", state).unwrap();
}

// Emit entity change for content path
fn emit_entity_changed(app: &AppHandle, entity_id: &str, entity: &Entity) {
    app.emit_all("kosmos:entity-changed", EntityChangedEvent {
        entity_id: entity_id.to_string(),
        entity: entity.clone(),
    }).unwrap();
}

// Handle praxis invocation from frontend
#[tauri::command]
fn invoke_praxis(praxis_id: String, params: Value) -> Result<Value, String> {
    // Execute via kosmos interpreter
}
```

### 21. Frontend Choice: Solid

| Framework | Pros | Cons | Fit |
|-----------|------|------|-----|
| **Solid** | Fine-grained reactivity, small bundle | Smaller ecosystem | **Best** — reactivity model matches kosmos state |
| Svelte | Simple, compiled | Less TypeScript | Good |
| React | Large ecosystem | Larger bundle, more overhead | Acceptable |

**Decision: Solid** — its fine-grained reactivity model aligns naturally with kosmos entity state changes.

---

## Part VI: Invitation Flow UI Wireframes

*Detailed UI flows for the invitation/entry process.*

### Onboarding (C2)

```
┌─────────────────────────────────────────┐
│   Welcome to Thyra                      │
│                                         │
│   ○ Create new identity                 │
│   ○ Restore from mnemonic               │
│   ○ I have an invitation link           │
│                                         │
└─────────────────────────────────────────┘
```

### Invitation Creation (C3)

```
┌─────────────────────────────────────────┐
│  Create Invitation                      │
│                                         │
│  Message (optional):                    │
│  ┌─────────────────────────────────┐   │
│  │ Hey! Join our circle.           │   │
│  └─────────────────────────────────┘   │
│                                         │
│  Expires: [7 days ▼]                    │
│  Single use: [x]                        │
│  Require approval: [x]                  │
│                                         │
│  [Generate Link]                        │
└─────────────────────────────────────────┘
```

### Entry Request (C5)

```
┌─────────────────────────────────────────┐
│  Join "Liminal Commons"                 │
│                                         │
│  Invited by: Victor                     │
│  Message: "Hey! Join our circle."       │
│                                         │
│  Your name in this circle:              │
│  ┌─────────────────────────────────┐   │
│  │ Alice                           │   │
│  └─────────────────────────────────┘   │
│                                         │
│  [Request to Join]                      │
└─────────────────────────────────────────┘
```

### Video Verification (C6)

```
Victor's Screen:                      Friend's Screen:
┌─────────────────────────┐          ┌─────────────────────────┐
│  ┌───────────────────┐  │          │  ┌───────────────────┐  │
│  │   Alice's video   │  │          │  │   Victor's video  │  │
│  └───────────────────┘  │          │  └───────────────────┘  │
│                         │          │                         │
│  "Alice" wants to join  │          │  Waiting for Victor     │
│  Liminal Commons        │          │  to verify you...       │
│                         │          │                         │
│  [✓ Approve]  [✗ Reject]│          │  [Cancel]               │
└─────────────────────────┘          └─────────────────────────┘
```

**Philosophy:** "The call IS the verification" — eyes and ears prove identity better than cryptography for trusted relationships.

### Signaling Flow (C4)

```
Friend's Device               Relay                    Your Device
      │                         │                            │
      │── join(room) ──────────▶│                            │
      │                         │◀── join(room) ─────────────│
      │◀── peer_joined ─────────│                            │
      │── SDP offer ───────────▶│── forward ────────────────▶│
      │◀── SDP answer ──────────│◀── forward ────────────────│
      │◀═══════════ P2P CONNECTION ESTABLISHED ═════════════▶│
```

### Phoreta Contents (C7)

```yaml
phoreta:
  entities:
    - persona/alice-abc123       # Friend's identity in this circle
    - circle/liminal-commons     # The circle joined
    - attainment/express         # Can create expressions
    - attainment/perceive        # Can see circle content

  bonds:
    - persona/alice → member-of → circle/liminal-commons
    - persona/alice → has-attainment → attainment/express
    - persona/alice → has-attainment → attainment/perceive

  signature: "inviter's Ed25519 signature"
```

---

## Implementation Path

### Phase 17.1: Core Eide and Desmoi ✓

**Status: COMPLETE** (2026-01-20)

Added perception eide:

1. ✓ `stream` eidos with process actuality (media future)
2. ✓ `expression` eidos (no actuality — it's a record)
3. ✓ `accumulation` eidos (buffer state)
4. ✓ `utterance` eidos (VAD-bounded segment)
5. ✓ Thyra desmoi (expressed-in, transforms-to, produces, consumes, in-reply-to, derives-from, contributes-to)

### Phase 17.2: Basic Praxeis (Expression Flow) ✓

**Status: COMPLETE** (2026-01-20)

Created `spora/praxeis/thyra.yaml`:

1. ✓ `express` — Create expression (commit content)
2. ✓ `list-expressions` — Query expressions in circle
3. ✓ `reply-to` — Create expression in reply to another
4. ✓ `get-thread` — Follow in-reply-to bonds for threading

### Phase 17.3: Stream Praxeis ✓

**Status: COMPLETE** (2026-01-20)

Added stream management praxeis to `spora/praxeis/thyra.yaml`:

1. ✓ `open-stream` — Create stream with intent=active, reconcile to manifest
2. ✓ `close-stream` — Set intent=closed, reconcile to unmanifest
3. ✓ `sense-stream` — Query actual stream state via sense_actuality
4. ✓ `reconcile-stream` — Align intent with actuality (core reconciler)
5. ✓ `list-streams` — List streams with filters
6. ✓ `pause-stream` — Set intent=paused
7. ✓ `resume-stream` — Set intent=active, reconcile

### Phase 17.4: Accumulation Praxeis ✓

**Status: COMPLETE** (2026-01-20)

Added buffer management praxeis to `spora/praxeis/thyra.yaml`:

1. ✓ `begin-accumulation` — Create accumulation buffer for stream
2. ✓ `append-fragment` — Add fragment to accumulation
3. ✓ `commit-accumulation` — Create expression from buffer (commitment boundary)
4. ✓ `abandon-accumulation` — Discard without committing
5. ✓ `clear-accumulation` — Reset content, keep active
6. ✓ `get-accumulation` — Get current accumulation state
7. ✓ `list-accumulations` — List accumulations with filters

### Phase 17.5: Media Actuality (Future)

Implement media actuality mode in Rust:

1. Add `host/media.rs` with capture_start, capture_status, capture_stop
2. Wire to step types in interpreter
3. Update stream reconciler to use media actuality

**Dependencies:** Voice capture infrastructure (cpal, VAD)

### Phase 17.6: Signaling and Network Actuality ✓

**Status: COMPLETE** (2026-01-20)

WebRTC dynamis already exists in `kosmos-core/src/host/webrtc.rs`. Added YAML wiring:

1. ✓ `signaling-session` eidos with signaling actuality mode
2. ✓ `data-channel` eidos with network actuality mode
3. ✓ `bootstrapped-by` desmos (data-channel → signaling-session)
4. ✓ Aither praxeis (`spora/praxeis/aither.yaml`):
   - Signaling: connect-signaling, disconnect-signaling, sense-signaling, poll-signaling, send-offer, send-answer
   - Data channels: create-channel, accept-answer, answer-channel, close-channel, sense-channel, send-message, receive-messages, list-channels

**Runtime:** propylon-relay for signaling, WebRTC for P2P

### Phase 17.7: DNS Management (Propylon Extension)

**Status: IMPLEMENTED** (2026-01-21)

DNS records as actualized entities following the Energeia pattern. Each circle can manage zones it governs.

| Component | Status | Location |
|-----------|--------|----------|
| `dns-zone` eidos | ✓ Complete | `spora/spora.yaml` |
| `dns-record` eidos | ✓ Complete | `spora/spora.yaml` |
| `dns-provider-binding` eidos | ✓ Complete | `spora/spora.yaml` |
| DNS desmoi | ✓ Complete | `spora/spora.yaml` |
| DNS praxeis | ✓ Complete | `genesis/thyra/praxeis/dns.yaml` |
| DNS actuality mode | ✓ Complete | `kosmos/src/host.rs` |
| DNS dynamis (cloudflare) | ✓ Complete | `kosmos/src/dns.rs` |
| DNS attainment | ✓ Complete | `spora/spora.yaml` |

**Key concepts:**
- `dns-record` has `actuality: { mode: dns }` — dual existence (graph intent vs provider actuality)
- Reconciler pattern: sense → compare → manifest/unmanifest
- Provider abstraction in dynamis layer (cloudflare.rs, route53.rs)
- Circle governance over zones via `manages-zone` desmos
- Credential management via `secret://` or `env://` references

See [dns/DESIGN.md](dns/DESIGN.md) for full specification.

---

### Phase 18.1: Rendering Ontology ✓

**Status: COMPLETE** (2026-01-21)

Added rendering eide to `eide/thyra.yaml`:

1. ✓ `layout` — Top-level HUD structure with regions
2. ✓ `panel` — Renderable content areas with render_type
3. ✓ `style-theme` — Visual styling (palette, density)
4. ✓ `render-intent` — Reconciler intent for rendering
5. ✓ `workspace` — Open artifacts and focus state
6. ✓ `voice-pipeline-config` — Homoiconic voice configuration

Added rendering desmoi to `desmoi/thyra.yaml`:

- ✓ renders-in, styled-by, shows, child-of
- ✓ active-layout, active-theme
- ✓ workspace-of, has-open, focused-on
- ✓ active-voice-config, clarified-by

### Phase 18.2: Artifact Definitions ✓

**Status: COMPLETE** (2026-01-21)

Created `spora/definitions/thyra.yaml`:

| Definition | Target Eidos | Purpose |
|------------|--------------|---------|
| `voice-pipeline-config` | voice-pipeline-config | Base template |
| `default-voice-config` | voice-pipeline-config | Deepgram + Haiku |
| `workspace` | workspace | Track open artifacts |
| `layout` | layout | Base layout template |
| `chora-default-layout` | layout | Standard 4-region layout |
| `style-theme` | style-theme | Base theme template |
| `dark-theme` | style-theme | Dark mode colors |
| `panel` | panel | Base panel template |
| `voice-bar-panel` | panel | Accumulation buffer |
| `expression-thread-panel` | panel | Chat view |
| `artifact-preview-panel` | panel | Content preview |

### Phase 18.3: Opsis Praxeis ✓

**Status: COMPLETE** (2026-01-22)

Visual rendering praxeis in `praxeis/opsis.yaml`:

| Praxis | Tier | Purpose |
|--------|------|---------|
| `gather-render-intent` | 2 | Query entities visible from dwelling for a region |
| `reconcile-region` | 3 | Align region actuality with intent |
| `emit-render` | 3 | Emit render commands to substrate |
| `activate-layout` | 2 | Set active layout for circle |
| `get-active-layout` | 1 | Get current layout |
| `activate-theme` | 2 | Set active theme for circle |
| `get-active-theme` | 1 | Get current theme |
| `open-artifact` | 2 | Open artifact in workspace (tabs) |
| `close-artifact` | 2 | Close artifact in workspace |
| `focus-artifact` | 2 | Switch focus to artifact |
| `get-workspace` | 1 | Get workspace state |
| `create-panel` | 2 | Create panel for region |
| `list-panels` | 1 | List panels |
| `render-all` | 3 | Full render cycle (all regions) |

Key implementation details:
- `gather-render-intent` handles different render types dynamically
- Workspace praxeis use bonds (has-open, focused-on) for tab management
- `emit_display` dynamis step bridges to substrate (Tauri IPC)

### Phase 18.4: Tauri Substrate Bridge ✓

**Status: COMPLETE** (2026-01-22)

Implemented display dynamis in Tauri:

| Dynamis | Implementation | Purpose |
|---------|----------------|---------|
| `display.emit` | Tauri IPC | Send render state to WebView |
| `display.sense` | Tauri IPC | Query rendered state |
| `audio.emit` | cpal + Tauri | Send audio output |
| `audio.sense` | cpal | Query audio devices |

### Phase 18.5: First Thyra (Future)

Minimal Tauri app with:

- Solid frontend framework
- Four regions (navigation, artifacts, expressions, input)
- Expression thread panel
- Accumulation buffer (voice bar)
- Artifact preview with tabs

### Phase 18.6: Audio Rendering (Akoe) (Future)

Audio emission for voice interaction:

| Praxis | Purpose |
|--------|---------|
| `synthesize-voice` | TTS from expression content |
| `play-audio` | Emit audio stream to speakers |
| `mix-streams` | Combine audio sources |

**Dependencies:**
- Voice capture infrastructure (cpal)
- TTS provider integration (local or cloud)
- Integration with existing voice pipeline (whisper daemon for bidirectional voice)

**Audio actuality mode:**
```yaml
actuality-mode/audio:
  operations:
    manifest: audio_output_start
    sense: audio_device_status
    unmanifest: audio_output_stop
  config_schema:
    device: { type: string }
    sample_rate: { type: integer }
    channels: { type: integer }
```

### Phase 18.7: Web Extraction (Future)

Extract WebView frontend to standalone web app:

- Same Solid components
- WebSocket/HTTP bridge instead of Tauri IPC
- kosmos-wasm or kosmos-server backend
- IndexedDB or server storage

---

## Praxis Outline

### Expression Operations

```yaml
# express — Create expression (the commitment boundary)
praxis/thyra/express:
  params:
    content: string (required)
    mode: enum [declaration, inquiry, suggestion, request, proposal]
    in_reply_to: string (optional)
  returns:
    expression: entity

# list-expressions — Query expressions in circle
praxis/thyra/list-expressions:
  params:
    circle_id: string (optional, defaults to dwelling)
    limit: number
    expressed_by: string (optional)
  returns:
    expressions: array

# reply-to — Create reply expression
praxis/thyra/reply-to:
  params:
    expression_id: string (required)
    content: string (required)
    mode: enum (optional)
  returns:
    expression: entity
```

### Stream Operations

```yaml
# open-stream — Open inward/outward stream
praxis/thyra/open-stream:
  params:
    kind: enum [voice, video, text, document]
    direction: enum [inward, outward]
    source: string (optional)
    config: object (optional)
  returns:
    stream: entity
    stream_id: string

# reconcile-stream — Align intent with actuality
praxis/thyra/reconcile-stream:
  params:
    stream_id: string
  returns:
    action: string (manifest, unmanifest, none)
    stream: entity
```

### Accumulation Operations

```yaml
# begin-accumulation — Start buffer
praxis/thyra/begin-accumulation:
  params:
    stream_id: string
  returns:
    accumulation: entity

# commit-accumulation — Create expression from buffer
praxis/thyra/commit-accumulation:
  params:
    accumulation_id: string
    mode: enum (optional)
  returns:
    expression: entity
```

---

## Decisions Made

### Perception Decisions

1. **Expression is symmetric**
   - Same eidos for human and animus
   - `expressed_by` distinguishes who
   - Paths differ: human via stream, animus via compose

2. **Streams follow reconciler pattern**
   - Intent declares what we want (active, paused, closed)
   - Actuality reflects what substrate reports
   - Reconciler aligns them

3. **Accumulation makes buffer visible**
   - Clarifier buffer is kosmos state
   - Recoverable on restart
   - Queryable by animus

4. **Only Layer 1 streams have recordings**
   - Audio/video → recording
   - Transcription/clarified text → ephemeral
   - Expression preserves meaning, recording preserves raw

### Emission Decisions

5. **Substrate: Tauri first, Web later**
   - Tauri provides richest experience (native + web)
   - Rust backend aligns with kosmos
   - WebView frontend enables later extraction
   - Local-first fits personal/federated worlds

6. **Frontend: Solid**
   - Fine-grained reactivity matches kosmos state model
   - Small bundle size
   - TypeScript support

7. **Two-path rendering**
   - Structural changes → full reconciler loop
   - Content changes → direct entity subscription
   - Avoids latency for frequent updates

8. **Workspace model (not attention-based)**
   - Explicit workspace entity tracks open artifacts
   - Simpler than psyche attention integration
   - Clear separation of concerns

### Voice Pipeline Decisions

9. **Clarification via manteia**
   - Governed inference provides audit trail
   - Memoization prevents redundant calls
   - `clarified-by` bond links accumulation to generation

10. **Homoiconic configuration**
    - Voice pipeline config is an entity
    - Can be composed, versioned, shared
    - Active config linked via `active-voice-config` bond

11. **Capture state on accumulation**
    - `capture_state` (inactive/listening/processing) for UI
    - `clarification_status` tracks pipeline stage
    - Visual state derived from both

---

## Open Questions

### Perception Questions

1. **Should MCP expose expression creation?**
   - Currently: praxeis available as MCP tools
   - Alternative: expression only through thyra UI
   - Trade-off: flexibility vs intentionality

2. **How does accumulation timeout work?**
   - Currently: praxis-driven (explicit abandon)
   - Could: automatic timeout after inactivity
   - Needs: background task infrastructure

3. **Stream daemon coordination?**
   - Streams depend on daemons (voice-capture, whisper, TTS)
   - How are these supervised?
   - Integration with ergon phylax pattern

### Emission Questions

4. **Reconciler loop trigger?**
   - Push on entity change? (reactive)
   - Poll periodically? (simple)
   - Event-driven via bonds? (elegant)
   - *Leaning:* Push on change for responsiveness

5. **Render intent granularity?**
   - Per-region? Per-panel? Per-entity?
   - *Leaning:* Per-region initially, refine if needed

6. **Clarification race condition?**
   - User might start editing before clarification completes
   - Need to handle gracefully
   - *Approach:* User edit cancels pending clarification, sets status to `manual`

7. **Multiple workspaces per animus?**
   - Current design assumes one workspace
   - Could support named workspaces (draft, review, etc.)
   - Defer until needed

---

## Summary

Thyra is the boundary membrane — the door that opens both ways.

### Perception (Aisthesis)

- **Streams**: Supervised media flow with reconciler pattern
- **Expressions**: The commitment boundary (ephemeral → durable)
- **Accumulation**: Visible buffer state with clarification pipeline
- **Provenance**: Full chain from stream to expression

### Emission (Ekthesis)

- **Layouts**: Top-level HUD structure defining regions
- **Panels**: Renderable content areas (expression-thread, accumulation-buffer, artifact-preview)
- **Themes**: Visual styling (palette, density, typography)
- **Workspaces**: Open artifacts and focus state (tabs)

### Voice Pipeline

- **Utterances**: VAD-bounded speech segments
- **Clarification**: Raw transcript → manteia → clean text
- **Configuration**: Homoiconic settings as kosmos entities
- **Audit**: Every clarification linked to generation for provenance

### Implementation Order

1. ✓ Perception eide/desmoi/praxeis (Phase 17)
2. ✓ Emission eide/desmoi/definitions (Phase 18.1-18.2)
3. ✓ Opsis praxeis (Phase 18.3)
4. ✓ Tauri substrate bridge (Phase 18.4)
5. → First Tauri thyra (Phase 18.5)
6. → Audio rendering (Akoe) (Phase 18.6)
7. → Web extraction (Phase 18.7)

**Substrate provides. Thyra renders. Chora receives.**

---

## Related Documents

- [ROADMAP.md](../ROADMAP.md) — Overall implementation status
- [KOSMOGONIA.md](../KOSMOGONIA.md) — Constitutional foundation
- [energeia/DESIGN.md](../energeia/DESIGN.md) — Actuality infrastructure (Phase 16)
- [eide/thyra.yaml](eide/thyra.yaml) — Full eide definitions
- [desmoi/thyra.yaml](desmoi/thyra.yaml) — Bond definitions
- [spora/definitions/thyra.yaml](../spora/definitions/thyra.yaml) — Artifact definitions
- [praxeis/opsis.yaml](praxeis/opsis.yaml) — Visual rendering praxeis
- [SCHEMA-DRIVEN-VISION.md](../SCHEMA-DRIVEN-VISION.md) — V5 vision for generating TypeScript types and UI components from eidos schemas

---

## Future: Schema-Driven UI Generation (V5)

Phase V5 will enable generating Thyra frontend artifacts from eidos schemas:

| Generated Artifact | Source | Benefit |
|-------------------|--------|---------|
| TypeScript interfaces | eidos fields | Type safety, no manual duplication |
| Form components | field types + validation | Consistent entity editing |
| Display components | field layouts | Consistent entity viewing |
| IPC bindings | praxis params | Type-safe Tauri invocation |

See [SCHEMA-DRIVEN-VISION.md](../SCHEMA-DRIVEN-VISION.md) for full design.

---

## Constitutional Alignment

Thyra implements the constitutional requirements from KOSMOGONIA:

### Development Pillars

| Pillar | How Thyra Honors It |
|--------|---------------------|
| **Schema-driven** | Rendering eide (layout, panel, style-theme, workspace) define structure. V5 vision extends this to generating TypeScript interfaces and UI components from eidos schemas. |
| **Graph-driven** | Bonds determine rendering relationships: `renders-in`, `styled-by`, `shows`, `active-layout`, `has-open`, `focused-on`. No embedded references — relationships exist as desmoi. |
| **Cache-driven** | Content-addressing throughout: clarification memoization, phoreta integrity, render state caching. See detailed section below. |

### Cache-Driven Architecture

Thyra implements cache-driven design at multiple layers:

**1. Clarification Memoization**

Voice pipeline clarification flows through `manteia/governed-inference`, which memoizes by content hash:

```
raw_transcript + clarification_prompt + model
         │
         ▼
   hash(inputs) → cache key
         │
         ├── cache hit → return cached clarification
         │
         └── cache miss → invoke LLM → cache result
```

Same input transcript produces same clarification. No redundant LLM calls.

**2. Expression Content-Addressing**

Expressions include content hash in their provenance chain. This enables:
- **Deduplication**: Identical expressions share identity
- **Integrity**: Tampering changes the hash, creating a visibly different entity
- **Freshness**: Dependencies track staleness via hash comparison

```
expression/abc123
  content: "I think we should clarify this"
  content_hash: blake3("I think we should clarify this")
  composed_from: typos/expression
```

**3. Phoreta Integrity**

Phoreta bundles (C7) are content-addressed:

```yaml
phoreta:
  entities: [...]
  bonds: [...]
  content_hash: blake3(entities + bonds)  # Integrity verification
  signature: ed25519(content_hash, inviter_key)
```

Import verifies: `hash(received_content) == declared_hash`. Tampering is detectable.

**4. Render State Caching**

`gather-render-intent` can cache render state by dwelling position hash:

```
dwelling_position + visible_entity_hashes
         │
         ▼
   hash(inputs) → render cache key
         │
         ├── cache hit → return cached render state
         │
         └── cache miss → gather entities → cache result
```

Cache invalidates when:
- Dwelling changes (different circle)
- Visible entity content changes (expression edited, artifact updated)
- Layout structure changes

**5. Artifact Composition Caching**

Layouts, panels, themes, and workspaces are composed via artifact definitions. The composition cache:

```
typos_id + inputs
         │
         ▼
   hash(typos + inputs) → composition cache key
         │
         ├── cache hit → return cached entity
         │
         └── cache miss → compose → cache result
```

`chora-default-layout` composed once, reused across sessions. Same definition + inputs = same layout entity.

**6. Voice Pipeline Config as Entity**

`voice-pipeline-config` is itself an entity with content-addressed identity:

```yaml
voice-pipeline-config/default
  data:
    transcription_provider: deepgram
    clarification_model: claude-3-haiku
    ...
  content_hash: blake3(data)
```

Configuration changes create new entities, preserving history. Rollback = switch `active-voice-config` bond.

### Constitutional Requirements

| Requirement | How Thyra Honors It |
|-------------|---------------------|
| **Composition Requirement** | All thyra entities (layouts, panels, themes, workspaces) arise through composition with provenance. Nothing is created raw. |
| **Dwelling Requirement** | Context derives from position. The animus dwells in a circle; expressions are scoped to that circle. Panels render what's visible from dwelling position. |
| **Authenticity Requirement** | Expressions trace to personas. Workspaces bond to animi. The graph preserves who said what when. |
| **Validity Requirement** | Voice pipeline clarification flows through manteia (governed inference). Clarified text traces to its generation. |

### Visibility = Reachability

Thyra enforces the constitutional pillar: you can only perceive what you can cryptographically reach through the bond graph.

```
animus
   │
   ├── dwells-in ──────► circle
   │                        │
   │                        ├── contains ──► expression (visible)
   │                        │
   │                        └── active-layout ──► layout
   │                                                │
   │                                                └── child-of ──► panel
   │
   └── workspace-of ◄───── workspace
                              │
                              └── has-open ──► artifact (in workspace)
```

Panels query from dwelling position. `gather-render-intent` collects entities reachable from the animus's circle. No global queries — visibility = reachability.

### Actuality = Reconciliation

Thyra's media streams follow the phylax pattern (sense → compare → act):

```
stream entity (intent: active)
       │
       ▼
   sense_actuality → actual state from substrate
       │
       ▼
   compare → drift detected?
       │
       ▼
   act → manifest (start capture) or unmanifest (stop)
```

This is the actuality loop (T1) applied to media. Signaling sessions and data channels follow the same pattern for network actuality.

### Expression as Commitment Boundary

The commitment boundary is Thyra's central constitutional concept:

```
stream (ephemeral)  →  accumulation (buffer)  →  expression (durable)
                                                       │
                                              commitment moment
```

Before commitment: raw stream data, buffer state, clarification in progress.
After commitment: expression entity with provenance, scoped to circle, replied-to threading.

The commitment boundary enforces authenticity — once expressed, the content is signed by position in the graph. Modification creates new entities, not edits.

### Caller Patterns

| Thyra Content | Caller Pattern | Notes |
|---------------|----------------|-------|
| Eide definitions | `literal` | Constitutional — thyra eide define what CAN exist |
| Layout instances | `composed` | Created from artifact definitions |
| Voice config | `literal` / `composed` | Can be composed from templates |
| Expressions | `literal` | User's words — never generated |
| Clarified text | `generated` (via manteia) | But traced via `clarified-by` bond |

Clarification is the exception that proves the rule: generated content (clarified text) is explicitly bonded to its generation, preserving provenance while enabling AI assistance.

---

*Composed in service of the kosmogonia.*
*Traces to: expression/genesis-root*
*Created: 2026-01-20 — Phase 17 (perception)*
*Updated: 2026-01-23 — V5 schema-driven vision referenced*

