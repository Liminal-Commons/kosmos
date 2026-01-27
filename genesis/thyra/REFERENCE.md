<!-- =============================================================================
<!-- GENERATED FILE - DO NOT EDIT DIRECTLY -->
<!-- =============================================================================
<!-- Emitted by: emit_cycle (demiurge/emit-genesis) -->
<!-- Source: genesis/thyra/REFERENCE.md -->
<!-- -->
<!-- To modify: -->
<!--   1. Edit the source in genesis/ -->
<!--   2. Re-run emit-genesis -->
<!-- -->
<!-- See: genesis/EXTENDING.md -->
<!-- =============================================================================

# Thyra Reference

the door, the boundary membrane.

---

## Eide (Entity Types)

### accumulation

Buffer state for stream content awaiting commitment. Tracks raw transcripts, clarified content, and visual state.

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `capture_state` | enum | ✓ | Voice capture state for UI feedback |
| `clarification_generation_id` | string |  | Manteia generation ID for audit trail and redo |
| `clarification_status` | enum | ✓ | State of clarification: pending (raw only), clarifying (LLM in flight), clarified (LLM done), manual (user edited), failed |
| `clarified_at` | timestamp |  |  |
| `committed_at` | timestamp |  |  |
| `content` | string | ✓ | Clarified content — after disfluency removal, ready for edit/commit |
| `expression_id` | string |  | Expression ID if committed |
| `last_fragment_at` | timestamp |  |  |
| `raw_content` | string |  | Concatenated raw transcripts — verbatim STT output |
| `raw_fragments` | array |  | Individual raw transcript fragments [{text, utterance_id, timestamp}] |
| `started_at` | timestamp | ✓ |  |
| `status` | enum | ✓ |  |
| `stream_id` | string | ✓ | The terminal stream this accumulation belongs to |

### app-config

Application configuration for Thyra. Makes tauri.conf.json settings

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `deep_link_schemes` | list |  | Custom URL schemes for deep linking (e.g., ['thyra']) |
| `dev_url` | string |  | Development server URL |
| `frontend_dist` | string | ✓ | Path to built frontend assets |
| `identifier` | string | ✓ | Reverse domain identifier (e.g., 'io.chora.app') |
| `product_name` | string | ✓ | Application display name |
| `version` | string | ✓ | Semantic version (e.g., '0.9.0-beta.1') |
| `window_fullscreen` | boolean |  | Start in fullscreen mode |
| `window_height` | number | ✓ | Default window height in pixels |
| `window_resizable` | boolean | ✓ | Whether the window can be resized |
| `window_title` | string | ✓ | Default window title |
| `window_width` | number | ✓ | Default window width in pixels |

### expression

Intentional contribution — the commitment boundary. When ephemeral becomes durable.

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `circle_id` | string | ✓ | Circle ID where this was expressed |
| `content` | string | ✓ | The content being expressed |
| `content_type` | string |  | MIME type of the content |
| `expressed_at` | timestamp | ✓ |  |
| `expressed_by` | string | ✓ | Persona ID of who expressed this |
| `in_reply_to` | string |  | Expression ID this replies to, if any |
| `metadata` | object |  |  |
| `mode` | enum |  | Expression mode — how the expression should be received |
| `source_artifact_id` | string |  | Artifact ID if originated from composition |
| `source_kind` | enum |  | How this expression originated |
| `source_stream_id` | string |  | Terminal stream ID if source_kind is stream |

### release

A versioned release of the Thyra application. Tracks version, artifacts, and deployment status.

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `changelog` | string |  | What's new in this release |
| `created_at` | timestamp | ✓ |  |
| `git_commit` | string |  | Git commit SHA |
| `git_tag` | string |  | Git tag for this release |
| `published` | boolean | ✓ | Whether this release is publicly available |
| `published_at` | timestamp |  |  |
| `release_type` | enum | ✓ | Release type |
| `version` | string | ✓ | Semantic version (e.g., '0.9.0-beta.1') |

### release-artifact

Platform-specific binary artifact for a release. Tracks hash, size, and storage location.

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `arch` | string | ✓ | Target architecture (e.g., 'universal', 'x64', 'amd64') |
| `content_hash` | string | ✓ | BLAKE3 hash of the artifact content |
| `download_url` | string |  | Public download URL |
| `filename` | string | ✓ | Artifact filename (e.g., 'Thyra_0.9.0_universal.dmg') |
| `platform` | enum | ✓ | Target platform |
| `size_bytes` | number | ✓ | Artifact size in bytes |
| `storage_path` | string | ✓ | R2 storage path (e.g., 'v0.9.0/Thyra_0.9.0_universal.dmg') |
| `uploaded_at` | timestamp | ✓ |  |

### render-spec

Declarative rendering specification — defines how to render entities

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `children` | array |  | Child render-spec IDs for nested structures |
| `created_at` | timestamp | ✓ |  |
| `description` | string |  |  |
| `fields_to_display` | array | ✓ | Entity fields to render [{field, label?, widget_id?}] |
| `layout_template` | string | ✓ | Structural template using simple markup. Supports: |
| `name` | string | ✓ | Render spec identifier |
| `style_bindings` | object |  | CSS class or style mappings by element |
| `target_eidos` | string | ✓ | The eidos this spec renders (e.g., 'expression', 'theoria') |

### render-type

How an eidos should render — makes display configuration traversable. Bonds to renderer via renders-with.

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `created_at` | timestamp | ✓ |  |
| `description` | string |  |  |
| `filters` | array |  | Available filter options [{field, label, options}] |
| `grouping` | string |  | How to group instances (e.g., 'in-reply-to-chains', 'by-date') |
| `name` | string | ✓ | Render type identifier (e.g., 'expression-thread', 'entity-list') |
| `sort_by` | string |  | Default sort field |
| `sort_order` | enum |  |  |
| `source_eidos` | string |  | The eidos this render type applies to (optional for input-only render types) |

### renderer

Component that implements a render-type — maps graph structure to visual form.

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `accepts_render_types` | array | ✓ | Render type IDs this renderer can handle |
| `component_path` | string |  | Path to core component (render_strategy=core). e.g., 'panels/ExpressionThread' |
| `component_url` | string |  | URL to Web Component bundle (render_strategy=web-component). Loaded dynamically. |
| `created_at` | timestamp | ✓ |  |
| `fallback_renderer_id` | string |  | Renderer to use if this one fails to load (graceful degradation) |
| `name` | string | ✓ | Renderer identifier |
| `props_schema` | object |  | JSON schema for component props |
| `render_spec_id` | string |  | Entity ID of render-spec (render_strategy=declarative). Graph-driven template. |
| `render_strategy` | enum | ✓ | How this renderer is loaded and executed: |
| `substrate` | enum | ✓ | Target substrate. 'universal' for wasm/declarative that work everywhere. |
| `wasm_module` | string |  | Path or URL to WASM module (render_strategy=wasm). Cross-platform rendering. |

### stream

Bounded media flow — voice, video, text, or document. Streams follow the reconciler pattern.

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `closed_at` | timestamp |  |  |
| `config` | object |  | Stream-specific configuration |
| `created_at` | timestamp |  |  |
| `direction` | enum | ✓ | Flow direction — inward is perception, outward is emission |
| `intent` | enum | ✓ | Desired state |
| `kind` | enum | ✓ | The modality of the stream |
| `last_error` | string |  |  |
| `manifest_handle` | string |  | Substrate handle for manifested stream (e.g., PID) |
| `manifested_at` | timestamp |  |  |
| `sink` | string |  | Destination identifier for outward streams |
| `source` | string |  | Source identifier (device ID, file path, channel ID) |
| `status` | enum |  | Current lifecycle state |

### utterance

VAD-bounded speech segment — atomic unit of voice perception.

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `audio_hash` | string |  | Hash of audio segment if captured |
| `contributed_to` | string |  | Expression ID this utterance contributed to |
| `duration_ms` | number |  |  |
| `ended_at` | timestamp |  | VAD speech end |
| `started_at` | timestamp | ✓ | VAD speech start |
| `stream_id` | string | ✓ | The audio stream this utterance came from |
| `transcribed_at` | timestamp |  |  |
| `transcription` | string |  |  |

## Praxeis (Operations)

🔧 = Exposed as MCP tool

### abandon-accumulation 🔧

Abandon an accumulation — discard without committing.

**Tier:** 2 | **ID:** `praxis/thyra/abandon-accumulation`

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `accumulation_id` | string | ✓ | The accumulation to abandon |
| `reason` | string |  | Optional reason for abandoning |

### activate-layout 🔧

Activate a layout for the current circle.

**Tier:** 2 | **ID:** `praxis/thyra/activate-layout`

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `layout_id` | string | ✓ | The layout to activate |

### activate-theme 🔧

Activate a style theme for the current circle.

**Tier:** 2 | **ID:** `praxis/thyra/activate-theme`

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `theme_id` | string | ✓ | The theme to activate |

### append-fragment 🔧

Append a fragment to an active accumulation.

**Tier:** 2 | **ID:** `praxis/thyra/append-fragment`

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `accumulation_id` | string | ✓ | The accumulation to append to |
| `fragment` | string | ✓ | The fragment content to append |
| `separator` | string |  | Separator between fragments (default: space) |

### begin-accumulation 🔧

Begin accumulating content from a stream.

**Tier:** 2 | **ID:** `praxis/thyra/begin-accumulation`

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `stream_id` | string | ✓ | The terminal stream this accumulation belongs to |
| `initial_content` | string |  | Optional initial content |

### bind-zone-provider 🔧

Bind a zone to its DNS provider with credentials.

**Tier:** 2 | **ID:** `praxis/dns/bind-zone-provider`

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `zone_id` | string | ✓ | Zone entity ID |
| `provider_zone_id` | string | ✓ | Provider's zone ID (from their dashboard) |
| `credential_ref` | string | ✓ | Reference to API token (secret://... or env://...) |
| `account_id` | string |  | Provider account ID (for cloudflare) |

### clear-accumulation 🔧

Clear an accumulation — reset content without closing.

**Tier:** 2 | **ID:** `praxis/thyra/clear-accumulation`

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `accumulation_id` | string | ✓ | The accumulation to clear |

### close-artifact 🔧

Close an artifact in the workspace (remove from tabs).

**Tier:** 2 | **ID:** `praxis/thyra/close-artifact`

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `artifact_id` | string | ✓ | The artifact to close |

### close-stream 🔧

Close a stream — set intent to closed and reconcile.

**Tier:** 3 | **ID:** `praxis/thyra/close-stream`

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `stream_id` | string | ✓ | The stream to close |

### commit-accumulation 🔧

Commit an accumulation — create expression from buffer.

**Tier:** 3 | **ID:** `praxis/thyra/commit-accumulation`

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `accumulation_id` | string | ✓ | The accumulation to commit |
| `mode` | string |  | Expression mode (default: declaration) |

### create-panel 🔧

Create a panel for rendering content in a region.

**Tier:** 2 | **ID:** `praxis/thyra/create-panel`

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `name` | string | ✓ | Panel identifier |
| `render_type` | string | ✓ | How this panel renders (expression-thread, presence-list, etc.) |
| `region_id` | string | ✓ | The region this panel renders in |
| `priority` | number |  | Rendering priority (default 0) |
| `config` | object |  | Panel-specific configuration |

### create-record 🔧

Create a DNS record entity (intent). Does NOT create at provider yet.
Use reconcile-record to actualize.

**Tier:** 2 | **ID:** `praxis/dns/create-record`

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `zone_id` | string | ✓ | Zone this record belongs to |
| `record_type` | string | ✓ | Record type (A, AAAA, CNAME, TXT, MX, etc.) |
| `name` | string | ✓ | Record name (subdomain part, use @ for root) |
| `content` | string | ✓ | Record value (IP, hostname, text, etc.) |
| `ttl` | number |  | Time-to-live in seconds (1 = auto for Cloudflare) |
| `priority` | number |  | Priority for MX/SRV records |
| `proxied` | boolean |  | Cloudflare proxy (orange cloud) |
| `addresses` | string |  | Entity ID this record addresses (optional) |

### create-zone 🔧

Create a DNS zone managed by the dwelling circle.

**Tier:** 2 | **ID:** `praxis/dns/create-zone`

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `name` | string | ✓ | Zone name (e.g., liminalcommons.com) |
| `provider` | string | ✓ | DNS provider (cloudflare, route53, manual) |

### delete-record 🔧

Mark a DNS record for deletion. Sets desired_state=absent.
Calls reconcile to actually delete at provider.

**Tier:** 2 | **ID:** `praxis/dns/delete-record`

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `record_id` | string | ✓ | The record to delete |

### emit 🔧

Emit content or entity to the filesystem (ekthesis).

**Tier:** 3 | **ID:** `praxis/thyra/emit`

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `path` | string | ✓ | File path to write to |
| `entity_id` | string |  | Entity ID to emit (serialized based on format) |
| `content` | string |  | Direct content to write (if entity_id not provided) |
| `format` | string |  | Output format (yaml, json, markdown, text). Default yaml. |

### emit-render 🔧

Emit render commands to substrate.

**Tier:** 3 | **ID:** `praxis/thyra/emit-render`

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `region_id` | string | ✓ | The region to render |
| `intent` | object | ✓ | The render intent from gather-render-intent |

### express 🔧

Create an expression — the commitment boundary.

**Tier:** 2 | **ID:** `praxis/thyra/express`

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `content` | string | ✓ | The content being expressed |
| `mode` | string |  | Expression mode: declaration, inquiry, suggestion, request, proposal (default: declaration) |
| `in_reply_to` | string |  | Expression ID this replies to |
| `source_kind` | string |  | How this originated: stream, compose, direct (default: direct) |
| `content_type` | string |  | MIME type (default: text/plain) |

### focus-artifact 🔧

Focus an artifact in the workspace (switch tabs).

**Tier:** 2 | **ID:** `praxis/thyra/focus-artifact`

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `artifact_id` | string | ✓ | The artifact to focus |

### gather-render-intent 🔧

Gather entities visible from dwelling position for a region.

**Tier:** 2 | **ID:** `praxis/thyra/gather-render-intent`

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `region_id` | string | ✓ | The HUD region to gather intent for |
| `layout_id` | string |  | Layout context (defaults to active layout) |

### get-accumulation 🔧

Get the current state of an accumulation.

**Tier:** 1 | **ID:** `praxis/thyra/get-accumulation`

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `accumulation_id` | string | ✓ | The accumulation to get |

### get-active-layout 🔧

Get the active layout for the current circle.

**Tier:** 1 | **ID:** `praxis/thyra/get-active-layout`

*No parameters*

### get-active-theme 🔧

Get the active theme for the current circle.

**Tier:** 1 | **ID:** `praxis/thyra/get-active-theme`

*No parameters*

### get-thread 🔧

Get a conversation thread from an expression.

**Tier:** 2 | **ID:** `praxis/thyra/get-thread`

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `expression_id` | string | ✓ | The expression to get thread for |
| `direction` | string |  | Direction: ancestors (default), descendants, or both |

### get-workspace 🔧

Get the current workspace state.

**Tier:** 1 | **ID:** `praxis/thyra/get-workspace`

*No parameters*

### list-accumulations 🔧

List accumulations, optionally filtered by status.

**Tier:** 1 | **ID:** `praxis/thyra/list-accumulations`

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `status` | string |  | Filter by status (active, committed, abandoned, cleared) |
| `stream_id` | string |  | Filter by source stream |
| `limit` | number |  | Maximum results (default: 50) |

### list-expressions 🔧

List expressions in a circle.

**Tier:** 2 | **ID:** `praxis/thyra/list-expressions`

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `circle_id` | string |  | Circle to list from (defaults to current circle) |
| `expressed_by` | string |  | Filter by persona ID |
| `mode` | string |  | Filter by expression mode |
| `limit` | number |  | Maximum expressions to return (default: 50) |

### list-panels 🔧

List panels, optionally filtered by region or render type.

**Tier:** 1 | **ID:** `praxis/thyra/list-panels`

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `region_id` | string |  | Filter by region |
| `render_type` | string |  | Filter by render type |
| `limit` | number |  | Maximum results (default: 50) |

### list-records 🔧

List DNS records in a zone.

**Tier:** 1 | **ID:** `praxis/dns/list-records`

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `zone_id` | string | ✓ | Zone to list records from |
| `record_type` | string |  | Filter by record type |
| `limit` | number |  | Maximum results |

### list-streams 🔧

List streams, optionally filtered by kind, direction, or status.

**Tier:** 1 | **ID:** `praxis/thyra/list-streams`

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `kind` | string |  | Filter by stream kind (voice, video, text, document) |
| `direction` | string |  | Filter by direction (inward, outward) |
| `status` | string |  | Filter by status |
| `limit` | number |  | Maximum results (default: 50) |

### list-zones 🔧

List DNS zones, optionally filtered by circle management.

**Tier:** 1 | **ID:** `praxis/dns/list-zones`

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `circle_id` | string |  | Filter to zones managed by this circle |
| `limit` | number |  | Maximum results |

### open-artifact 🔧

Open an artifact in the workspace (add to tabs).

**Tier:** 2 | **ID:** `praxis/thyra/open-artifact`

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `artifact_id` | string | ✓ | The artifact to open |
| `focus` | boolean |  | Whether to focus the artifact (default true) |

### open-stream 🔧

Open an inward or outward stream.

**Tier:** 3 | **ID:** `praxis/thyra/open-stream`

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `kind` | string | ✓ | Stream kind: voice, video, text, document |
| `direction` | string | ✓ | Flow direction: inward (perception), outward (emission) |
| `source` | string |  | Source identifier (device ID, file path) |
| `sink` | string |  | Sink identifier for outward streams |
| `config` | object |  | Stream-specific configuration |

### pause-stream 🔧

Pause a stream — set intent to paused.

**Tier:** 2 | **ID:** `praxis/thyra/pause-stream`

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `stream_id` | string | ✓ | The stream to pause |

### reconcile-record 🔧

Align DNS record intent with actuality (phylax pattern).

**Tier:** 3 | **ID:** `praxis/dns/reconcile-record`

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `record_id` | string | ✓ | The record to reconcile |

### reconcile-region 🔧

Align region actuality with intent.

**Tier:** 3 | **ID:** `praxis/thyra/reconcile-region`

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `region_id` | string | ✓ | The region to reconcile |

### reconcile-stream 🔧

Reconcile stream intent with actuality.

**Tier:** 3 | **ID:** `praxis/thyra/reconcile-stream`

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `stream_id` | string | ✓ | The stream to reconcile |

### reconcile-zone 🔧

Reconcile all records in a zone. Bulk phylax operation.

**Tier:** 3 | **ID:** `praxis/dns/reconcile-zone`

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `zone_id` | string | ✓ | Zone to reconcile |

### render-all 🔧

Reconcile all regions in the active layout.

**Tier:** 3 | **ID:** `praxis/thyra/render-all`

*No parameters*

### reply-to 🔧

Reply to an expression.

**Tier:** 2 | **ID:** `praxis/thyra/reply-to`

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `expression_id` | string | ✓ | The expression to reply to |
| `content` | string | ✓ | The reply content |
| `mode` | string |  | Expression mode (default: declaration) |

### resume-stream 🔧

Resume a paused stream — set intent back to active and reconcile.

**Tier:** 3 | **ID:** `praxis/thyra/resume-stream`

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `stream_id` | string | ✓ | The stream to resume |

### sense-record 🔧

Sense the actual state of a DNS record at the provider.
Does NOT modify the entity - just returns current state.

**Tier:** 3 | **ID:** `praxis/dns/sense-record`

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `record_id` | string | ✓ | The record to sense |

### sense-stream 🔧

Sense the actual state of a stream.

**Tier:** 1 | **ID:** `praxis/thyra/sense-stream`

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `stream_id` | string | ✓ | The stream to sense |

### sense-zone 🔧

Sense all records in a zone without reconciling.
Useful for detecting drift.

**Tier:** 3 | **ID:** `praxis/dns/sense-zone`

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `zone_id` | string | ✓ | Zone to sense |

## Desmoi (Bond Types)

| Desmos | From → To | Description |
|--------|-----------|-------------|
| `consumes` | daemon → stream | Daemon consumes stream content. |
| `contributes-to` | utterance → expression | Utterance contributes to expression. |
| `derives-from` | expression → any | Expression derives from stream or artifact. Provenance. |
| `expressed-in` | expression → circle | Expression expressed in circle. The dwelling context. |
| `in-reply-to` | expression → expression | Expression threading — conversation structure. |
| `produces` | daemon → stream | Daemon produces stream content. |
| `transforms-to` | stream → stream | Stream transformation relationship. Audio → transcription → clarified. |

---

*Generated from schema definitions. Do not edit directly.*
