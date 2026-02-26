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
- **Phasis**: The commitment boundary — ephemeral becomes durable
- **Emission (ekthesis)**: Outward flow of renders, layouts, visual state
- **Streams follow the reconciler pattern**: Intent → sense → reconcile → actualize

The central concept is the **commitment boundary** — the moment when ephemeral stream content becomes durable phasis. This is the "send moment."

## Oikos Context

### Self Oikos

A solitary dweller uses thyra to:
- Capture voice input, clarify it, commit as phaseis
- Configure voice pipeline (VAD, transcription, clarification)
- Render their personal workspace with open artifacts
- Emit entities to filesystem for persistence

Self oikos phaseis are notes to oneself.

### Peer Oikos

Collaborators use thyra to:
- Exchange phaseis in conversation threads
- Share workspaces showing what each is working on
- See presence via rendered panels
- Follow in-reply-to chains for context

Phasis stances signal intent: declaration, inquiry, suggestion, request, proposal.

### Commons Oikos

A commons uses thyra to:
- Distribute thyra-configs and themes to members
- Provide modes and render-specs for custom eide
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

### phasis

Intentional contribution — the commitment boundary.

**Fields:**
- `content` — the expressed content
- `expressed_by` — prosopon ID
- `oikos_id` — where expressed
- `expressed_at` — timestamp
- `source_kind` — stream, compose, direct
- `stance` — declaration, inquiry, suggestion, request, proposal
- `in_reply_to` — for threading

**Lifecycle:**
- Arise: emit-phasis or commit-phasis creates it
- Change: Phaseis are immutable after creation
- Depart: Phaseis persist (archive, don't delete)

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
- Depart: commit-phasis creates phasis, or abandon

### utterance

VAD-bounded speech segment — atomic unit of voice perception.

**Fields:**
- `stream_id` — source audio stream
- `started_at`, `ended_at`, `duration_ms` — timing
- `transcription` — speech-to-text result
- `contributed_to` — phasis ID if committed

### mode

Topos presence in a spatial position — how a topos becomes visible.

**Fields:**
- `name` — mode identifier
- `render_spec_id` — which render-spec defines the widget tree
- `spatial` — position and sizing (`position`: top/left/center/right/bottom; `height`: fill/auto)
- `source_entity_id` — for entity-bound modes (e.g., accumulation/default)
- `source_query` — for collection modes (e.g., `gather(eidos: phasis, sort: expressed_at, order: asc)`)
- `requires` — modes (compute, etc.) that must be manifested
- `config` — mode-specific configuration (typos_id, watch_eidos)

**Three mode patterns:**
- **Singleton** (`render_spec_id`): Renders one entity or static layout via a render-spec
- **Collection** (`item_spec_id` + `source_query` + `arrangement`): Gathers entities, renders each through `item_spec_id`, optional `chrome_spec_id` wrapper
- **Compound** (`sections[]`): Multiple sub-sections in one mode

### thyra-config

Active mode set — which modes are rendered and window behavior.

**Fields:**
- `name` — config identifier (workspace, hud, compact)
- `active_modes` — array of mode IDs to render
- `window` — window behavior (size, always_on_top)

### style-theme

Visual styling — palette, density, typography.

**Fields:**
- `name` — theme identifier
- `palette` — color definitions
- `density` — compact, comfortable, spacious
- `typography` — font settings
- `active` — whether currently active

### workspace

Open artifacts and focus state — what the parousia is working on.

**Fields:**
- `name` — workspace identifier
- `open_artifact_ids` — tab order
- `focused_artifact_id` — active tab
- `parousia_id` — ownership

### render-spec

Declarative widget tree — defines how a mode renders its content.

Render-specs are domain-agnostic. They compose widgets (text, card, stack, form, etc.) with data bindings. The widget interpreter dispatches all widget names through `getWidget()` -- zero hardcoded widget names. Field-level iteration uses the `each` property on any widget node (with `each_empty` for empty arrays). Entity-level iteration is handled by collection modes (`item_spec_id` + `source_query` + `arrangement`). 29 widget types available.

### voice-pipeline-config

Configuration for voice capture and clarification — homoiconic settings.

**Fields:**
- Audio: input device, VAD settings, input mode
- Transcription: provider, language, model, streaming
- Clarification: enabled, model, system prompt

## Bonds (Desmoi)

### phasis-in

Phasis belongs to an oikos.

- **From:** phasis
- **To:** oikos
- **Cardinality:** many-to-one
- **Traversal:** Find phaseis in an oikos, or which oikos a phasis belongs to

### in-reply-to

Phasis replies to another phasis — conversation threading.

- **From:** phasis
- **To:** phasis
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

Phasis derives from stream or artifact — provenance.

- **From:** phasis
- **To:** stream, artifact
- **Cardinality:** many-to-many
- **Traversal:** Trace phasis origin

### contributes-to

Utterance contributes to phasis.

- **From:** utterance
- **To:** phasis
- **Cardinality:** many-to-one
- **Traversal:** See which utterances formed a phasis

### uses-render-spec

Mode uses a render-spec for its widget tree.

- **From:** mode
- **To:** render-spec
- **Cardinality:** many-to-one
- **Traversal:** Find which render-spec a mode uses, or which modes use a render-spec

### requires-mode

Mode depends on another mode being active (cross-substrate).

- **From:** mode
- **To:** mode
- **Cardinality:** one-to-many
- **Traversal:** Find substrate requirements for a mode

### workspace-of / has-open / focused-on

Workspace ownership and tab state.

## Operations (Praxeis)

### Phasis Operations

- **emit-phasis**: Create phasis (the commitment boundary)
- **reply-to**: Reply to a phasis (sets in-reply-to)
- **list-phaseis**: Query phaseis in oikos
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
- **commit-phasis**: Cross commitment boundary → phasis
- **abandon-accumulation**: Discard without committing
- **clear-accumulation**: Reset content, keep active
- **get-accumulation** / **list-accumulations**: Query buffer state

### Mode Operations

- **switch-mode**: Replace one mode with another in a thyra-config's active_modes
- **switch-config**: Switch the active thyra-config (e.g., workspace → hud)
- **activate-theme** / **get-active-theme**: Theme management
- **open-artifact** / **close-artifact** / **focus-artifact**: Tab management

### Emission Operations

- **emit**: Write entity or content to filesystem (ekthesis)

### Navigation Operations (Hodos)

- **get-current-waypoint**: Where am I in a journey
- **advance-waypoint**: Move forward
- **branch-waypoint**: Take alternate path
- **validate-form**: Check form input
- **start-onboarding**: Begin onboarding journey

## Attainments

### attainment/perceive

Perception capability — capturing streams and managing accumulation.

- **Grants:** open-stream, close-stream, sense-stream, reconcile-stream, list-streams, pause-stream, resume-stream, begin-accumulation, append-fragment, commit-phasis, abandon-accumulation, clear-accumulation, get-accumulation, list-accumulations
- **Scope:** soma (local substrate)
- **Rationale:** Perception requires substrate access (media capture)

### attainment/express

Phasis capability — creating durable contributions.

- **Grants:** emit-phasis, reply-to, list-phaseis, get-thread
- **Scope:** oikos
- **Rationale:** Phaseis belong to oikoi; requires membership

### attainment/render

Rendering capability — mode switching and workspace management.

- **Grants:** switch-mode, switch-config, activate-theme, get-active-theme, open-artifact, close-artifact, focus-artifact, get-workspace
- **Scope:** soma (local substrate)
- **Rationale:** Rendering is substrate-local

### attainment/actuate

Filesystem actuation capability — writing to chora.

- **Grants:** emit
- **Scope:** soma
- **Rationale:** Filesystem access is substrate-local

### attainment/navigate

Journey navigation capability — following waypoints.

- **Grants:** get-current-waypoint, advance-waypoint, branch-waypoint, validate-form, start-onboarding
- **Scope:** parousia (personal navigation)
- **Rationale:** Navigation is per-parousia state

## Embodiment

### Completeness Status

| Level | Status |
|-------|--------|
| Defined | ~15 eide, 10+ desmoi, 30+ praxeis |
| Loaded | Bootstrap loads all definitions |
| Projected | All visible praxeis available as MCP tools |
| Embodied | Partial — accumulation affects body-schema |
| Surfaced | 5 modes across 4 spatial positions |
| Afforded | Phasis feed, voice bar, text compose, theoria sidebar, oikos nav |

### Body-Schema Contribution

When sense-body gathers thyra state:

```yaml
perception:
  active_streams: 2       # Currently manifested
  accumulation_active: true
  accumulation_content: "..."
  capture_state: listening

emission:
  active_config: thyra-config/workspace
  active_modes: [mode/oikos-nav, mode/phasis-feed, mode/theoria-sidebar, mode/compose-full]
  current_theme: dark
```

This reveals what's being captured and what's being shown.

### Reconciler

A thyra reconciler would surface:

- **Pending commitment** — "Voice buffer has content, ready to send?"
- **Stream failures** — "Audio capture stopped unexpectedly"
- **Mode drift** — "Actuality-mode manifested but mode deactivated"
- **Draft phaseis** — "Uncommitted accumulation from earlier"

## Compound Leverage

### amplifies soma

Streams manifest via soma/arise-parousia pattern. Perception requires embodiment.

### amplifies politeia

Phasis scoping enforces oikos visibility. Layout/theme are oikos-level.

### amplifies nous

Phaseis become searchable, indexable. Theoria can surface from conversation.

### amplifies manteia

Voice clarification flows through manteia/governed-inference.

### amplifies dynamis

Render state follows reconciler pattern (sense → compare → act).

### amplifies propylon

Entry creates first phasis. Session tokens enable cross-process auth.

## Theoria

### T50: The commitment boundary is the send moment

Before commitment, content is ephemeral buffer. After commitment, content is durable phasis with provenance. The moment between is the commitment boundary — intentional, observable, reversible until crossed.

### T51: Streams follow the reconciler pattern

Intent declares what we want. Actuality reflects what substrate reports. Reconciler aligns them. This applies to all actuality modes: media, process, network, signaling.

### T52: Phasis stances signal intent

Declaration states what is understood. Inquiry invites exploration. Suggestion offers possibility. Request asks for action. Proposal co-creates direction. The stance tells the recipient how to receive the content.

### T53: Modes make topos presence traversable

Modes and render-specs are entities with bonds. Display configuration is data, not code. Adding a new view = creating a mode with a render-spec. Each topos contributes modes; thyra-config selects which are active. `uses-render-spec` bonds make the relationship graph-traversable.

### T54: Three mode patterns serve different needs

Singleton modes (`render_spec_id`) serve focused editing -- one entity, overlays for optimistic updates. Collection modes (`item_spec_id` + `source_query` + `arrangement`) serve browsing -- gathering entities by type, rendering each through a shared item spec, with optional chrome wrapping. Compound modes (`sections[]`) serve dashboards -- multiple sub-sections in one spatial position. The layout engine dispatches automatically based on which fields are present.

## Future Extensions

### Media Actuality Mode

Full media capture/playback beyond process spawn — audio levels, VAD events, recording.

### Audio Rendering (Akoe)

Voice synthesis for bidirectional voice interaction. TTS from phasis content.

### Web Extraction

Extract WebView frontend to standalone web app with WebSocket bridge.

---

*Composed in service of the kosmogonia.*
*The door opens both ways. Perceive. Express. Render. The membrane breathes.*
