<!-- =============================================================================
<!-- GENERATED FILE - DO NOT EDIT DIRECTLY -->
<!-- =============================================================================
<!-- Emitted by: emit_cycle (demiurge/emit-genesis) -->
<!-- Source: genesis/nous/REFERENCE.md -->
<!-- -->
<!-- To modify: -->
<!--   1. Edit the source in genesis/ -->
<!--   2. Re-run emit-genesis -->
<!-- -->
<!-- See: genesis/EXTENDING.md -->
<!-- =============================================================================

# Nous Reference

understanding operations, theoria, inquiry, synthesis, journeys.

---

## Eide (Entity Types)

### inquiry

An open question. Inquiries drive understanding forward.

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `answered_at` | timestamp |  |  |
| `domain` | string | ✓ |  |
| `opened_at` | timestamp | ✓ |  |
| `question` | string | ✓ |  |
| `status` | enum: open, exploring, answered, dissolved | ✓ |  |

### journey

A teleological container — movement toward a desire (hodos).

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `abandon_reason` | string |  |  |
| `abandoned_at` | timestamp |  |  |
| `arrived_at` | timestamp |  |  |
| `current_waypoint` | number |  |  |
| `description` | string |  | Extended description of the journey |
| `desire` | string | ✓ | What we're moving toward (the telos) |
| `embarked_at` | timestamp |  |  |
| `feedback_loop` | boolean |  | Does completing this journey make it easier to create more of what it enables? |
| `leverage_multiplier` | string |  | What entity type multiplies value when this completes (e.g., 'praxis' for MCP dispatch) |
| `leverage_type` | enum: meta, compound, additive, terminal |  | How this journey's completion affects future work: |
| `status` | enum: potential, active, paused, arrived, abandoned | ✓ |  |

### synthesis

A bringing-together of multiple theoria into higher understanding.

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `domain` | string | ✓ |  |
| `insight` | string | ✓ |  |
| `sources` | array | ✓ | Theoria IDs that were synthesized |
| `synthesized_at` | timestamp | ✓ |  |

### waypoint

A consolidation point on a journey. Supports navigation via hodos praxeis.

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `artifact_id` | string |  | Optional artifact this waypoint yields |
| `branches` | array |  | Conditional branches [{condition, target}] |
| `description` | string | ✓ |  |
| `form_definition_id` | string |  | Artifact-definition for form validation |
| `journey_id` | string |  | Parent journey ID (optional if using contains-waypoint bond) |
| `next` | string |  | Explicit next waypoint (overrides ordinal+1) |
| `ordinal` | number | ✓ | Position in journey (0-indexed) |
| `panel_id` | string |  | Panel to render for this waypoint |
| `reached_at` | timestamp |  |  |
| `status` | enum: pending, reached | ✓ |  |
| `yields` | array |  | Entity types this waypoint yields on completion |

## Praxeis (Operations)

🔧 = Exposed as MCP tool

### abandon-journey 🔧

Abandon a journey.

**Tier:** 2 | **ID:** `praxis/nous/abandon-journey`

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `journey_id` | string | ✓ | The journey to abandon |
| `reason` | string |  | Why abandoning |

### add-waypoint 🔧

Add a waypoint to a journey.

**Tier:** 2 | **ID:** `praxis/nous/add-waypoint`

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `journey_id` | string | ✓ | The journey to add waypoint to |
| `waypoint_id` | string | ✓ | ID for the new waypoint |
| `ordinal` | number | ✓ | Position in journey (0-indexed) |
| `description` | string | ✓ | What this waypoint represents |

### answer-inquiry 🔧

Answer an inquiry with theoria.

**Tier:** 2 | **ID:** `praxis/nous/answer-inquiry`

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `inquiry_id` | string | ✓ | The inquiry to answer |
| `theoria_id` | string | ✓ | The theoria that answers it |

### begin-journey 🔧

Begin a new journey toward a desire.

**Tier:** 2 | **ID:** `praxis/nous/begin-journey`

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `journey_id` | string | ✓ | ID for the new journey |
| `desire` | string | ✓ | What we're moving toward (the telos) |

### call-praxis 🔧

Invoke any praxis by ID.

**Tier:** 2 | **ID:** `praxis/nous/call-praxis`

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `praxis_id` | string | ✓ | The praxis to invoke (e.g., "politeia/create-oikos" or full "praxis/politeia/create-oikos") |
| `params` | object |  | Parameters to pass to the praxis |

### complete-journey 🔧

Complete a journey (arrive at telos).

**Tier:** 2 | **ID:** `praxis/nous/complete-journey`

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `journey_id` | string | ✓ | The journey to complete |

### confirm-theoria 🔧

Confirm a provisional theoria as crystallized.

**Tier:** 2 | **ID:** `praxis/nous/confirm-theoria`

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `theoria_id` | string | ✓ | The theoria to confirm |

### crystallize-theoria 🔧

Crystallize an understanding into theoria.

**Tier:** 2 | **ID:** `praxis/nous/crystallize-theoria`

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `theoria_id` | string | ✓ | ID for the new theoria (e.g., theoria/uuid) |
| `insight` | string | ✓ | The understanding being crystallized |
| `domain` | string | ✓ | Domain this understanding belongs to |
| `source` | string |  | Where this understanding came from (default conversation) |
| `evidence` | array |  | Entity IDs that evidence this theoria |

### embark-journey 🔧

Embark on a journey (transition from potential to active).

**Tier:** 2 | **ID:** `praxis/nous/embark-journey`

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `journey_id` | string | ✓ | The journey to embark on |

### find 🔧

Find an entity by its ID.

**Tier:** 2 | **ID:** `praxis/nous/find`

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `id` | string | ✓ | The entity ID to find |

### find-related 🔧

Find theoria related to a given theoria.

**Tier:** 2 | **ID:** `praxis/nous/find-related`

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `theoria_id` | string | ✓ | The theoria to find relations for |

### gather 🔧

Gather entities by eidos.

**Tier:** 2 | **ID:** `praxis/nous/gather`

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `eidos` | string |  | Filter by eidos type |
| `limit` | number |  | Maximum results (default 100) |

### gather-context

Gather context for an invocation according to a pattern specification.

**Tier:** 2 | **ID:** `praxis/nous/gather-context`

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `pattern_id` | string | ✓ | The invocation-pattern to gather context for |

### get-journey-waypoints 🔧

Get all waypoints for a journey.

**Tier:** 2 | **ID:** `praxis/nous/get-journey-waypoints`

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `journey_id` | string | ✓ | The journey to get waypoints for |

### index 🔧

Index an entity for semantic search.

**Tier:** 2 | **ID:** `praxis/nous/index`

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `entity_id` | string | ✓ | The entity to index |
| `text` | string | ✓ | Text to generate embedding from |

### index-functions 🔧

Index all function entities for semantic search.

**Tier:** 2 | **ID:** `praxis/nous/index-functions`

*No parameters*

### invoke 🔧

Activate chora-nous via composed invocation.

**Tier:** 2 | **ID:** `praxis/nous/invoke`

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `pattern_id` | string | ✓ | The invocation-pattern to use |
| `utterance` | string | ✓ | The input to process (what triggered activation) |
| `phasis_stance` | string |  | How the yield should be received (suggestion, invitation, inquiry, request, proposal, declaration). Default declaration. |
| `additional_context` | object |  | Additional context to include (e.g., goal, iteration) |

### list-journeys 🔧

List journeys, optionally filtered by status.

**Tier:** 2 | **ID:** `praxis/nous/list-journeys`

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `status` | string |  | Filter by status (potential, active, paused, arrived, abandoned) |

### list-theoria 🔧

List theoria, optionally filtered by domain or status.

**Tier:** 2 | **ID:** `praxis/nous/list-theoria`

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `domain` | string |  | Filter by domain |
| `status` | string |  | Filter by status (provisional, crystallized, superseded) |

### navigate 🔧

Multi-step reasoning via iterative invocation.

**Tier:** 2 | **ID:** `praxis/nous/navigate`

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `goal` | string | ✓ | What we're navigating toward |
| `pattern_id` | string | ✓ | The invocation-pattern to use for each step |
| `max_iterations` | number |  | Maximum iterations before stopping (default 5) |

### open-inquiry 🔧

Open a new inquiry (question).

**Tier:** 2 | **ID:** `praxis/nous/open-inquiry`

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `inquiry_id` | string | ✓ | ID for the new inquiry |
| `question` | string | ✓ | The question being asked |
| `domain` | string | ✓ | Domain this inquiry belongs to |

### reach-waypoint 🔧

Mark a waypoint as reached.

**Tier:** 2 | **ID:** `praxis/nous/reach-waypoint`

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `waypoint_id` | string | ✓ | The waypoint that was reached |
| `artifact_id` | string |  | Optional artifact this waypoint yields |

### supersede-theoria 🔧

Supersede a theoria with a new understanding.

**Tier:** 2 | **ID:** `praxis/nous/supersede-theoria`

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `old_theoria_id` | string | ✓ | The theoria to supersede |
| `new_theoria_id` | string | ✓ | ID for the new theoria |
| `new_insight` | string | ✓ | The new understanding |
| `domain` | string |  | Domain (defaults to old theoria's domain) |

### surface 🔧

Surface entities by semantic proximity to a query.

**Tier:** 2 | **ID:** `praxis/nous/surface`

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `query` | string | ✓ | The semantic query |
| `eidos` | string |  | Optional filter by eidos type |
| `limit` | number |  | Maximum results (default 10) |
| `threshold` | number |  | Minimum similarity threshold (default 0.7) |

### surface-journeys 🔧

Surface journeys relevant to a query.

**Tier:** 2 | **ID:** `praxis/nous/surface-journeys`

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `query` | string | ✓ | What we're looking for |
| `limit` | number |  | How many journeys to surface |
| `status` | string |  | Optional filter by status |

### synthesize 🔧

Synthesize multiple theoria into higher understanding.

**Tier:** 2 | **ID:** `praxis/nous/synthesize`

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `synthesis_id` | string | ✓ | ID for the new synthesis |
| `insight` | string | ✓ | The synthesized understanding |
| `sources` | array | ✓ | Theoria IDs to synthesize (at least 2) |
| `domain` | string | ✓ | Domain for the synthesis |

### traverse 🔧

Traverse the graph from a root entity, following specified bond types.

**Tier:** 2 | **ID:** `praxis/nous/traverse`

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `root_id` | string | ✓ | Starting entity ID |
| `desmoi` | array | ✓ | Bond types to follow (e.g., ["depends-on", "composed-from"]) |
| `depth` | number |  | Maximum traversal depth (default 10) |
| `direction` | string |  | Direction to traverse bonds (outward, inward, both). Default outward. |
| `eidos` | string |  | Only return entities of this eidos |

## Desmoi (Bond Types)

| Desmos | From → To | Description |
|--------|-----------|-------------|
| `answers` | theoria → inquiry | Theoria answers an inquiry |
| `contains-waypoint` | journey → waypoint | Journey contains this waypoint |
| `contradicts` | theoria → theoria | Theoria contradicts another theoria |
| `crystallized-in` | theoria → oikos | Theoria crystallized in an oikos |
| `evidences` | any → theoria | Entity provides evidence for theoria |
| `inquires` | prosopon → inquiry | Prosopon opened an inquiry |
| `supersedes` | theoria → theoria | Theoria supersedes older understanding |
| `supports` | theoria → theoria | Theoria supports another theoria |
| `synthesizes` | synthesis → theoria | Synthesis draws from theoria |
| `waypoint-yields` | waypoint → artifact | Waypoint yields this artifact on completion |

---

*Generated from schema definitions. Do not edit directly.*
