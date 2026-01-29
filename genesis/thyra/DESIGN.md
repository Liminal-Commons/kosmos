# Thyra Design

θύρα (thyra) — the door, the boundary membrane

## Ontological Purpose

Thyra addresses **the gap between inside and outside** — the membrane through which human perception enters kosmos and kosmos state reaches human awareness.

Without thyra:
- Streams flow but leave no trace in the graph
- Speech vanishes without becoming contribution
- Kosmos state has no path to visibility
- The commitment boundary is undefined

With thyra:
- **Perception (aisthesis)**: Inward flow of streams, utterances, accumulations
- **Expression**: The commitment boundary — ephemeral becomes durable
- **Emission (ekthesis)**: Outward flow of renders, layouts, visual state
- **Streams follow the reconciler pattern**: Intent → sense → reconcile → actualize

The central concept is the **commitment boundary** — the moment when ephemeral stream content becomes durable expression. This is the "send moment."

## Circle Context

### Self Circle

A solitary dweller uses thyra to:
- Capture voice input, clarify it, commit as expressions
- Configure voice pipeline (VAD, transcription, clarification)
- Render their personal workspace with open artifacts
- Emit entities to filesystem for persistence

Self circle expressions are notes to oneself.

### Peer Circle

Collaborators use thyra to:
- Exchange expressions in conversation threads
- Share workspaces showing what each is working on
- See presence via rendered panels
- Follow in-reply-to chains for context

Expression modes signal stance: declaration, inquiry, suggestion, request, proposal.

### Commons Circle

A commons uses thyra to:
- Distribute layouts and themes to members
- Provide render-types and renderers for custom eide
- Configure voice pipelines for accessibility
- Manage content-roots for where content lives

Commons provide rendering infrastructure.

## Core Entities (Eide)

### stream

Bounded media flow — voice, video, text, or document.

**Fields:**
- `kind` — voice, video, text, document
- `direction` — inward (perception) or outward (emission)
- `intent` — active, paused, closed (desired state)
- `status` — pending, manifesting, active, paused, closing, closed, failed (actual)
- `source`, `sink` — identifiers for endpoints
- `manifest_handle` — substrate handle (PID) when manifested

**Lifecycle:**
- Arise: open-stream creates with intent=active
- Reconcile: Sense actuality, manifest if needed, unmanifest when closed
- Depart: close-stream sets intent=closed, reconciler terminates

### expression

Intentional contribution — the commitment boundary.

**Fields:**
- `content` — the expressed content
- `expressed_by` — persona ID
- `circle_id` — where expressed
- `expressed_at` — timestamp
- `source_kind` — stream, compose, direct
- `mode` — declaration, inquiry, suggestion, request, proposal
- `in_reply_to` — for threading

**Lifecycle:**
- Arise: express or commit-accumulation creates it
- Change: Expressions are immutable after creation
- Depart: Expressions persist (archive, don't delete)

### accumulation

Buffer state awaiting commitment — the voice bar.

**Fields:**
- `stream_id` — source stream
- `raw_content` — verbatim transcript
- `content` — clarified content (after LLM)
- `clarification_status` — pending, clarifying, clarified, manual, failed
- `capture_state` — inactive, listening, processing (for UI)
- `status` — active, committed, abandoned, cleared

**Lifecycle:**
- Arise: begin-accumulation creates buffer
- Change: append-fragment adds content, clarification updates it
- Depart: commit-accumulation creates expression, or abandon

### utterance

VAD-bounded speech segment — atomic unit of voice perception.

**Fields:**
- `stream_id` — source audio stream
- `started_at`, `ended_at`, `duration_ms` — timing
- `transcription` — speech-to-text result
- `contributed_to` — expression ID if committed

### layout

Top-level HUD structure — defines arrangement of regions.

**Fields:**
- `name` — layout identifier
- `regions` — array of region specifications
- `active` — whether currently active for circle

### panel

Renderable content area — surfaces entities within a region.

**Fields:**
- `name` — panel identifier
- `render_type` — entity-list, expression-thread, workspace-view, etc.
- `source_query` — how to gather entities
- `region_id` — which region to render in
- `visible` — whether currently shown

### style-theme

Visual styling — palette, density, typography.

**Fields:**
- `name` — theme identifier
- `palette` — color definitions
- `density` — compact, comfortable, spacious
- `typography` — font settings
- `active` — whether currently active

### workspace

Open artifacts and focus state — what the animus is working on.

**Fields:**
- `name` — workspace identifier
- `open_artifact_ids` — tab order
- `focused_artifact_id` — active tab
- `animus_id` — ownership

### render-type / renderer / render-spec

Homoiconic rendering configuration — makes display traversable.

- **render-type**: How an eidos should render (grouping, sorting, filters)
- **renderer**: Component that implements a render-type (strategies: core, declarative, web-component, wasm)
- **render-spec**: Declarative rendering template for graph-driven display

### voice-pipeline-config

Configuration for voice capture and clarification — homoiconic settings.

**Fields:**
- Audio: input device, VAD settings, input mode
- Transcription: provider, language, model, streaming
- Clarification: enabled, model, system prompt

## Bonds (Desmoi)

### expressed-in

Expression belongs to a circle.

- **From:** expression
- **To:** circle
- **Cardinality:** many-to-one
- **Traversal:** Find expressions in a circle, or which circle an expression belongs to

### in-reply-to

Expression replies to another expression — conversation threading.

- **From:** expression
- **To:** expression
- **Cardinality:** many-to-one
- **Traversal:** Build conversation threads

### transforms-to

Stream transforms to another stream — pipeline chaining.

- **From:** stream (e.g., audio)
- **To:** stream (e.g., transcription)
- **Cardinality:** one-to-many
- **Traversal:** Follow stream transformation pipeline

### produces / consumes

Daemon produces or consumes a stream.

- **From:** daemon
- **To:** stream
- **Traversal:** Understand stream data flow

### derives-from

Expression derives from stream or artifact — provenance.

- **From:** expression
- **To:** stream, artifact
- **Cardinality:** many-to-many
- **Traversal:** Trace expression origin

### contributes-to

Utterance contributes to expression.

- **From:** utterance
- **To:** expression
- **Cardinality:** many-to-one
- **Traversal:** See which utterances formed an expression

### renders-in / styled-by / shows

Panel renders in region, styled by theme, shows entities.

### workspace-of / has-open / focused-on

Workspace ownership and tab state.

## Operations (Praxeis)

### Expression Operations

- **express**: Create expression (the commitment boundary)
- **reply-to**: Reply to an expression (sets in-reply-to)
- **list-expressions**: Query expressions in circle
- **get-thread**: Follow in-reply-to bonds for threading

### Stream Operations (Reconciler Pattern)

- **open-stream**: Create with intent=active, reconcile to manifest
- **close-stream**: Set intent=closed, reconcile to unmanifest
- **sense-stream**: Query actual stream state from substrate
- **reconcile-stream**: Align intent with actuality (sense → compare → act)
- **list-streams**: Query streams with filters
- **pause-stream** / **resume-stream**: Suspend/resume flow

### Accumulation Operations (Buffer Management)

- **begin-accumulation**: Start buffer for stream
- **append-fragment**: Add content to buffer
- **commit-accumulation**: Cross commitment boundary → expression
- **abandon-accumulation**: Discard without committing
- **clear-accumulation**: Reset content, keep active
- **get-accumulation** / **list-accumulations**: Query buffer state

### Rendering Operations (Opsis)

- **gather-render-intent**: Collect entities visible from dwelling
- **reconcile-region**: Align region with intent
- **emit-render**: Send render commands to substrate
- **render-all**: Full render cycle
- **activate-layout** / **get-active-layout**: Layout management
- **activate-theme** / **get-active-theme**: Theme management
- **open-artifact** / **close-artifact** / **focus-artifact**: Tab management
- **create-panel** / **list-panels**: Panel management

### Emission Operations

- **emit**: Write entity or content to filesystem (ekthesis)

### Navigation Operations (Hodos)

- **get-current-waypoint**: Where am I in a journey
- **advance-waypoint**: Move forward
- **branch-waypoint**: Take alternate path
- **get-panel-render-data**: What to render for current step
- **validate-form**: Check form input
- **start-onboarding**: Begin onboarding journey

## Attainments

### attainment/perceive

Perception capability — capturing streams and managing accumulation.

- **Grants:** open-stream, close-stream, sense-stream, reconcile-stream, list-streams, pause-stream, resume-stream, begin-accumulation, append-fragment, commit-accumulation, abandon-accumulation, clear-accumulation, get-accumulation, list-accumulations
- **Scope:** soma (local substrate)
- **Rationale:** Perception requires substrate access (media capture)

### attainment/express

Expression capability — creating durable contributions.

- **Grants:** express, reply-to, list-expressions, get-thread
- **Scope:** circle
- **Rationale:** Expressions belong to circles; requires membership

### attainment/render

Rendering capability — visual emission and workspace management.

- **Grants:** gather-render-intent, reconcile-region, emit-render, render-all, activate-layout, get-active-layout, activate-theme, get-active-theme, open-artifact, close-artifact, focus-artifact, get-workspace, create-panel, list-panels
- **Scope:** soma (local substrate)
- **Rationale:** Rendering is substrate-local

### attainment/emit

Filesystem emission capability — writing to chora.

- **Grants:** emit
- **Scope:** soma
- **Rationale:** Filesystem access is substrate-local

### attainment/navigate

Journey navigation capability — following waypoints.

- **Grants:** get-current-waypoint, advance-waypoint, branch-waypoint, get-panel-render-data, validate-form, start-onboarding
- **Scope:** animus (personal navigation)
- **Rationale:** Navigation is per-animus state

## Embodiment

### Completeness Status

| Level | Status |
|-------|--------|
| Defined | ~20 eide, 12+ desmoi, 30+ praxeis |
| Loaded | Bootstrap loads all definitions |
| Projected | All visible praxeis available as MCP tools |
| Embodied | Partial — accumulation affects body-schema |
| Surfaced | Partial — render intent from dwelling |
| Afforded | Partial — expression thread, voice bar |

### Body-Schema Contribution

When sense-body gathers thyra state:

```yaml
perception:
  active_streams: 2       # Currently manifested
  accumulation_active: true
  accumulation_content: "..."
  capture_state: listening

emission:
  current_layout: chora-default
  current_theme: dark
  workspace_tabs: 3
  focused_artifact: artifact/xyz
```

This reveals what's being captured and what's being shown.

### Reconciler

A thyra reconciler would surface:

- **Pending commitment** — "Voice buffer has content, ready to send?"
- **Stream failures** — "Audio capture stopped unexpectedly"
- **Stale renders** — "Layout changed, regions need refresh"
- **Draft expressions** — "Uncommitted accumulation from earlier"

## Compound Leverage

### amplifies soma

Streams manifest via soma/arise-animus pattern. Perception requires embodiment.

### amplifies politeia

Expression scoping enforces circle visibility. Layout/theme are circle-level.

### amplifies nous

Expressions become searchable, indexable. Theoria can surface from conversation.

### amplifies manteia

Voice clarification flows through manteia/governed-inference.

### amplifies dynamis

Render state follows reconciler pattern (sense → compare → act).

### amplifies propylon

Entry creates first expression. Session tokens enable cross-process auth.

## Theoria

### T50: The commitment boundary is the send moment

Before commitment, content is ephemeral buffer. After commitment, content is durable expression with provenance. The moment between is the commitment boundary — intentional, observable, reversible until crossed.

### T51: Streams follow the reconciler pattern

Intent declares what we want. Actuality reflects what substrate reports. Reconciler aligns them. This applies to all actuality modes: media, process, network, signaling.

### T52: Expression modes signal stance

Declaration states what is understood. Inquiry invites exploration. Suggestion offers possibility. Request asks for action. Proposal co-creates direction. The mode tells the recipient how to receive the content.

### T53: Homoiconic rendering makes display traversable

Render-types, renderers, and render-specs are entities. Display configuration is data, not code. Adding a new render type = creating an entity. This enables oikoi to bring their own renderers.

### T54: Two paths to render

Structural changes (layout, panels) go through the reconciler. Content changes (expressions, artifacts) go direct via entity subscription. Structural is infrequent, content is frequent. Match the path to the frequency.

## Future Extensions

### Media Actuality Mode

Full media capture/playback beyond process spawn — audio levels, VAD events, recording.

### Audio Rendering (Akoe)

Voice synthesis for bidirectional voice interaction. TTS from expression content.

### Web Extraction

Extract WebView frontend to standalone web app with WebSocket bridge.

### Declarative Renderer

Full render-spec interpretation for graph-driven display without code.

---

*Composed in service of the kosmogonia.*
*The door opens both ways. Perceive. Express. Render. The membrane breathes.*
