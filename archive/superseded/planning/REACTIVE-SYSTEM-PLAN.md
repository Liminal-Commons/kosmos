# Kosmos Reactive System Plan

*Definition roadmap for reactive system entities, praxeis, and seed reflexes.*

## ✅ STATUS: COMPLETE (2026-01-30)

| Phase | Kosmos | Chora |
|-------|--------|-------|
| 1. Stoicheia Definitions | ✅ | ✅ |
| 2. Seed Reflexes (10) | ✅ | ✅ |
| 3. Response Praxeis (6) | ✅ | ✅ |
| 4. Migration Support | ✅ | ✅ |
| 5. Manifest Updates | ✅ | ✅ |

**E2E Verified:** deployment entity → reconciler → manifest → action_taken: "manifest"

---

## Overview

This plan covers kosmos-side deliverables for the reactive system:
1. Stoicheia definitions (schemas for chora to implement)
2. Seed reflex entities (bootstrap reflexes)
3. Response praxeis (what reflexes invoke)
4. Migration support eide (new entity types needed)

**Sync with chora:** [chora/REACTIVE-SYSTEM-PLAN.md](../chora/REACTIVE-SYSTEM-PLAN.md)

---

## Current State

### Complete

| Component | Location | Status |
|-----------|----------|--------|
| Reflex eidos | `genesis/ergon/eide/ergon.yaml` | ✅ Defined |
| Reflex attainment | `genesis/ergon/eide/ergon.yaml` | ✅ Defined |
| Reconciler definitions | `genesis/dynamis/reconcilers/dynamis.yaml` | ✅ Defined |
| Actuality mode definitions | `genesis/dynamis/actuality-modes/dynamis.yaml` | ✅ Defined |
| REACTIVE-SYSTEM.md | `genesis/REACTIVE-SYSTEM.md` | ✅ Complete |
| ergon/DESIGN.md reflex section | `genesis/ergon/DESIGN.md` | ✅ Complete |
| CHORA-HANDOFF-REFLEXES.md | Root | ✅ Complete |

### Needed

| Component | Location | Blocks Chora Phase |
|-----------|----------|-------------------|
| ~~Process stoicheia~~ | ~~`genesis/stoicheia-portable/`~~ | ~~1.1~~ ✅ |
| ~~Seed reflexes~~ | ~~`genesis/{oikos}/entities/reflexes.yaml`~~ | ~~1.3~~ ✅ |
| ~~Response praxeis~~ | ~~Various oikoi~~ | ~~1.3~~ ✅ |
| ~~sync-message eidos~~ | ~~`genesis/aither/eide/`~~ | ~~4.1~~ ✅ |
| ~~Actuality declaration on deployment~~ | ~~`genesis/dynamis/eide/`~~ | ~~2.1~~ ✅ |
| ~~aither sync-message reflex~~ | ~~`genesis/aither/entities/`~~ | ~~4.3~~ ✅ |

---

## Phase 1: Stoicheia Definitions

**Goal:** Define Tier 3 stoicheia for process actuality operations.

**Blocks:** Chora Phase 1.1

### 1.1 Process Stoicheia

Add to `genesis/stoicheia-portable/eide/stoicheion.yaml`:

```yaml
# =============================================================================
# TIER 3: PROCESS ACTUALITY OPERATIONS
# =============================================================================

- eidos: eidos
  id: eidos/stoicheion/spawn-process
  data:
    name: spawn-process
    tier: 3
    description: |
      Spawn a background process.

      Used by process actuality mode to manifest deployments.
      Returns PID and initial status.
    params:
      command:
        type: string
        required: true
        description: Command to execute
      args:
        type: array
        required: false
        description: Command arguments
      env:
        type: object
        required: false
        description: Environment variables
      working_dir:
        type: string
        required: false
        description: Working directory for the process
    returns:
      pid:
        type: number
        description: Process ID
      status:
        type: string
        description: Initial status (running, failed)

- eidos: eidos
  id: eidos/stoicheion/check-process
  data:
    name: check-process
    tier: 3
    description: |
      Check if a process is running.

      Used by process actuality mode to sense deployment state.
    params:
      pid:
        type: number
        required: true
        description: Process ID to check
    returns:
      running:
        type: boolean
        description: Whether process is alive
      exit_code:
        type: number
        description: Exit code if not running
      cpu_usage:
        type: number
        description: CPU usage percentage
      memory_usage:
        type: number
        description: Memory usage in bytes

- eidos: eidos
  id: eidos/stoicheion/kill-process
  data:
    name: kill-process
    tier: 3
    description: |
      Terminate a process.

      Used by process actuality mode to unmanifest deployments.
    params:
      pid:
        type: number
        required: true
        description: Process ID to kill
      signal:
        type: number
        required: false
        default: 15
        description: Signal to send (default SIGTERM)
    returns:
      success:
        type: boolean
        description: Whether kill succeeded
```

**Deliverable:** Process stoicheia added, chora regenerates step_types.rs

---

## Phase 2: Seed Reflexes

**Goal:** Create bootstrap reflexes that chora loads at startup.

**Blocks:** Chora Phase 1.3

### 2.1 Oikos Development Reflexes

Create `genesis/demiurge/entities/reflexes.yaml`:

```yaml
entities:

# =============================================================================
# OIKOS DEVELOPMENT REFLEXES
# =============================================================================

- eidos: reflex
  id: reflex/demiurge/artifact-added
  data:
    name: artifact-added
    description: |
      Update oikos manifest when artifact is added.

      Fires when a contains bond is created from a composing oikos
      to any artifact (eidos, praxis, desmos).
    trigger:
      event: bond_created
      desmos: contains
      from_eidos: oikos
      to_eidos: [eidos, praxis, desmos]
      condition: '$from.data.status == "composing"'
    response:
      praxis: demiurge/update-manifest
      params:
        oikos_id: "$from.id"
        artifact_id: "$to.id"
    enabled: true
    scope: global

- eidos: reflex
  id: reflex/demiurge/praxis-added
  data:
    name: praxis-added
    description: |
      Auto-register praxis as MCP tool when added to developing oikos.

      This obsoletes explicit project-oikos invocation.
    trigger:
      event: bond_created
      desmos: contains
      from_eidos: oikos
      to_eidos: praxis
      condition: '$from.data.status == "composing"'
    response:
      praxis: demiurge/register-praxis-tool
      params:
        oikos_id: "$from.id"
        praxis_id: "$to.id"
    enabled: true
    scope: global

- eidos: reflex
  id: reflex/demiurge/praxis-changed
  data:
    name: praxis-changed
    description: |
      Re-validate praxis when its steps change.
    trigger:
      event: entity_updated
      eidos: praxis
      condition: '$entity.data.steps != $previous.data.steps'
    response:
      praxis: demiurge/validate-praxis
      params:
        praxis_id: "$entity.id"
    enabled: true
    scope: global
```

### 2.2 Pragma Notification Reflexes

Create `genesis/ergon/entities/reflexes.yaml`:

```yaml
entities:

# =============================================================================
# PRAGMA NOTIFICATION REFLEXES
# =============================================================================

- eidos: reflex
  id: reflex/ergon/pragma-signaled
  data:
    name: pragma-signaled
    description: |
      Add notification when pragma signals to a circle.

      Creates soma notification entity for circle members.
    trigger:
      event: bond_created
      desmos: signals-to
      from_eidos: pragma
      to_eidos: circle
    response:
      praxis: soma/add-notification
      params:
        type: pragma_received
        circle_id: "$to.id"
        pragma_id: "$from.id"
        title: "$from.data.title"
        priority: "$from.data.priority"
    enabled: true
    scope: global

- eidos: reflex
  id: reflex/ergon/pragma-resolved
  data:
    name: pragma-resolved
    description: |
      Notify when pragma is resolved.
    trigger:
      event: entity_updated
      eidos: pragma
      condition: '$entity.data.status == "resolved" && $previous.data.status != "resolved"'
    response:
      praxis: soma/add-notification
      params:
        type: pragma_resolved
        pragma_id: "$entity.id"
        title: "$entity.data.title"
        resolution: "$entity.data.resolution"
    enabled: true
    scope: global
```

### 2.3 Theoria Indexing Reflexes

Create `genesis/nous/entities/reflexes.yaml`:

```yaml
entities:

# =============================================================================
# KNOWLEDGE INDEXING REFLEXES
# =============================================================================

- eidos: reflex
  id: reflex/nous/theoria-created
  data:
    name: theoria-created
    description: |
      Auto-index theoria for semantic search when created.
    trigger:
      event: entity_created
      eidos: theoria
    response:
      praxis: nous/index-entity
      params:
        entity_id: "$entity.id"
    enabled: true
    scope: global

- eidos: reflex
  id: reflex/nous/expression-created
  data:
    name: expression-created
    description: |
      Auto-index expressions for semantic search.
    trigger:
      event: entity_created
      eidos: expression
    response:
      praxis: nous/index-entity
      params:
        entity_id: "$entity.id"
    enabled: true
    scope: global
```

### 2.4 Deployment Intent Reflexes

Add to `genesis/dynamis/entities/reflexes.yaml`:

```yaml
entities:

# =============================================================================
# DEPLOYMENT RECONCILIATION REFLEXES
# =============================================================================

- eidos: reflex
  id: reflex/dynamis/deployment-intent-changed
  data:
    name: deployment-intent-changed
    description: |
      Trigger reconciliation when deployment intent changes.

      Bridge between reflex system (event detection) and reconciler system (state alignment).
    trigger:
      event: entity_updated
      eidos: deployment
      condition: '$entity.data.desired_state != $previous.data.desired_state'
    response:
      praxis: dynamis/reconcile
      params:
        reconciler_id: "reconciler/deployment"
        entity_id: "$entity.id"
    enabled: true
    scope: global

- eidos: reflex
  id: reflex/dynamis/release-artifact-intent-changed
  data:
    name: release-artifact-intent-changed
    description: |
      Trigger reconciliation when release artifact upload intent changes.
    trigger:
      event: entity_updated
      eidos: release-artifact
      condition: '$entity.data.uploaded != $previous.data.uploaded'
    response:
      praxis: dynamis/reconcile
      params:
        reconciler_id: "reconciler/release-artifact"
        entity_id: "$entity.id"
    enabled: true
    scope: global
```

**Deliverable:** 9 seed reflexes across 4 oikoi (10th in Phase 4)

---

## Phase 3: Response Praxeis

**Goal:** Create the praxeis that reflexes invoke.

**Blocks:** Chora Phase 1.3

### 3.1 demiurge/update-manifest

Add to `genesis/demiurge/praxeis/demiurge.yaml`:

```yaml
- eidos: praxis
  id: praxis/demiurge/update-manifest
  data:
    oikos: demiurge
    name: update-manifest
    visible: false  # Internal, invoked by reflex
    tier: 2
    description: |
      Update oikos manifest when artifact is added.

      Called by reflex/demiurge/artifact-added.
    params:
      - name: oikos_id
        type: string
        required: true
      - name: artifact_id
        type: string
        required: true
    steps:
      - step: find
        id: "$oikos_id"
        bind_to: oikos

      - step: find
        id: "$artifact_id"
        bind_to: artifact

      # Determine artifact type and update appropriate provides section
      - step: switch
        cases:
          - when: '$artifact.eidos == "eidos"'
            then:
              - step: set
                bindings:
                  provides_key: eide
          - when: '$artifact.eidos == "praxis"'
            then:
              - step: set
                bindings:
                  provides_key: praxeis
          - when: '$artifact.eidos == "desmos"'
            then:
              - step: set
                bindings:
                  provides_key: desmoi

      # Log the update (actual manifest update happens on emit)
      - step: return
        value:
          updated: true
          oikos_id: "$oikos_id"
          artifact_id: "$artifact_id"
          artifact_type: "$artifact.eidos"
```

### 3.2 demiurge/register-praxis-tool

Add to `genesis/demiurge/praxeis/demiurge.yaml`:

```yaml
- eidos: praxis
  id: praxis/demiurge/register-praxis-tool
  data:
    oikos: demiurge
    name: register-praxis-tool
    visible: false  # Internal, invoked by reflex
    tier: 3  # Requires MCP registration (actuality)
    description: |
      Register praxis as MCP tool during development.

      Called by reflex/demiurge/praxis-added.
      Enables testing praxeis without emission.
    params:
      - name: oikos_id
        type: string
        required: true
      - name: praxis_id
        type: string
        required: true
    steps:
      - step: find
        id: "$praxis_id"
        bind_to: praxis

      # Register with MCP (requires chora stoicheion)
      - step: register_mcp_tool
        praxis_id: "$praxis_id"
        prefix: "dev"
        bind_to: registration

      - step: return
        value:
          registered: true
          tool_name: "$registration.tool_name"
          praxis_id: "$praxis_id"
```

### 3.3 soma/add-notification

Add to `genesis/soma/praxeis/soma.yaml`:

```yaml
- eidos: praxis
  id: praxis/soma/add-notification
  data:
    oikos: soma
    name: add-notification
    visible: false  # Internal, invoked by reflexes
    tier: 2
    description: |
      Add notification to body-schema.

      Called by pragma and other notification reflexes.
    params:
      - name: type
        type: string
        required: true
      - name: circle_id
        type: string
        required: false
      - name: pragma_id
        type: string
        required: false
      - name: title
        type: string
        required: false
      - name: priority
        type: string
        required: false
      - name: resolution
        type: string
        required: false
    steps:
      - step: compose
        typos_id: typos-def-notification
        inputs:
          type: "$type"
          circle_id: "$circle_id"
          pragma_id: "$pragma_id"
          title: "$title"
          priority: "$priority"
          created_at: "{{ now() }}"
        bind_to: notification

      - step: return
        value:
          notification_id: "$notification.id"
          type: "$type"
```

### 3.4 demiurge/validate-praxis

Add to `genesis/demiurge/praxeis/demiurge.yaml`:

```yaml
- eidos: praxis
  id: praxis/demiurge/validate-praxis
  data:
    oikos: demiurge
    name: validate-praxis
    visible: false  # Internal, invoked by reflex
    tier: 2
    description: |
      Validate praxis step definitions against stoicheion schemas.

      Called by reflex/demiurge/praxis-changed when steps are modified.
    params:
      - name: praxis_id
        type: string
        required: true
    steps:
      - step: find
        id: "$praxis_id"
        bind_to: praxis

      # Validate each step against stoicheion schema
      - step: for_each
        items: "$praxis.data.steps"
        as: step
        do:
          - step: find
            id: "eidos/stoicheion/$step.step"
            bind_to: stoicheion
          # Schema validation happens implicitly via find

      - step: return
        value:
          valid: true
          praxis_id: "$praxis_id"
          step_count: "{{ len($praxis.data.steps) }}"
```

### 3.5 nous/index-entity

Add to `genesis/nous/praxeis/nous.yaml`:

```yaml
- eidos: praxis
  id: praxis/nous/index-entity
  data:
    oikos: nous
    name: index-entity
    visible: false  # Internal, invoked by reflexes
    tier: 3  # Requires embedding generation
    description: |
      Index entity for semantic search.

      Called by theoria/expression creation reflexes.
    params:
      - name: entity_id
        type: string
        required: true
    steps:
      - step: find
        id: "$entity_id"
        bind_to: entity

      # Generate embedding (requires manteia)
      - step: call
        praxis: manteia/embed
        params:
          text: "$entity.data.insight || $entity.data.content"
        bind_to: embedding

      # Store in vector index
      - step: index_embedding
        entity_id: "$entity_id"
        embedding: "$embedding.vector"
        bind_to: indexed

      - step: return
        value:
          indexed: true
          entity_id: "$entity_id"
```

**Deliverable:** 5 response praxeis

---

## Phase 4: Migration Support

**Goal:** Define eide needed for chora migration.

**Blocks:** Chora Phase 4.1, 2.1

### 4.1 sync-message Eidos

Create `genesis/aither/eide/sync-message.yaml`:

```yaml
entities:

- eidos: eidos
  id: eidos/sync-message
  data:
    name: sync-message
    description: |
      Federation sync message.

      Created when a message arrives via WebRTC federation.
      Reflex triggers processing, then message is consumed.
    constitutional: false
    fields:
      channel_id:
        type: string
        required: true
        description: Federation channel this message arrived on

      message_type:
        type: string
        required: true
        description: Type of sync message (entity, bond, presence, etc.)

      payload:
        type: object
        required: true
        description: Message payload

      sender_id:
        type: string
        required: true
        description: Persona who sent the message

      received_at:
        type: timestamp
        required: true

      processed:
        type: boolean
        required: false
        default: false
        description: Whether this message has been processed
```

### 4.2 Actuality Declaration on Deployment

Update `genesis/dynamis/eide/dynamis.yaml` to add actuality fields:

```yaml
# Add to deployment eidos fields:
      actuality_mode:
        type: string
        required: true
        default: process
        description: |
          How this deployment becomes actual.
          Options: process, docker, kubernetes

      provider:
        type: string
        required: false
        default: local
        description: |
          Provider within the mode.
          For process: local
          For docker: local, remote
          For kubernetes: cluster name

      manifest_handle:
        type: string
        required: false
        description: |
          Handle to the manifested resource.
          For process: PID
          For docker: container ID
          For kubernetes: pod name
```

### 4.3 Federation Message Reflex

Add to `genesis/aither/entities/reflexes.yaml`:

```yaml
entities:

- eidos: reflex
  id: reflex/aither/sync-message-received
  data:
    name: sync-message-received
    description: |
      Process federation sync message when it arrives.

      Replaces poll_channels() interval.
    trigger:
      event: entity_created
      eidos: sync-message
    response:
      praxis: aither/process-sync-message
      params:
        message_id: "$entity.id"
    enabled: true
    scope: global
```

### 4.4 Federation Message Praxis

Add to `genesis/aither/praxeis/aither.yaml`:

```yaml
- eidos: praxis
  id: praxis/aither/process-sync-message
  data:
    oikos: aither
    name: process-sync-message
    visible: false  # Internal, invoked by reflex
    tier: 3  # Requires federation channel access
    description: |
      Process a federation sync message.

      Called by reflex/aither/sync-message-received when sync-message
      entity is created. Handles entity sync, bond sync, presence updates.
    params:
      - name: message_id
        type: string
        required: true
    steps:
      - step: find
        id: "$message_id"
        bind_to: message

      # Process based on message type
      - step: switch
        cases:
          - when: '$message.data.message_type == "entity_sync"'
            then:
              - step: call
                praxis: aither/apply-entity-sync
                params:
                  payload: "$message.data.payload"
          - when: '$message.data.message_type == "bond_sync"'
            then:
              - step: call
                praxis: aither/apply-bond-sync
                params:
                  payload: "$message.data.payload"
          - when: '$message.data.message_type == "presence"'
            then:
              - step: call
                praxis: aither/update-presence
                params:
                  sender_id: "$message.data.sender_id"
                  payload: "$message.data.payload"

      # Mark message as processed
      - step: update
        entity_id: "$message_id"
        data:
          processed: true

      - step: return
        value:
          processed: true
          message_id: "$message_id"
          message_type: "$message.data.message_type"
```

**Deliverable:** 1 new eidos, 1 eidos update, 1 reflex, 1 praxis

---

## Phase 5: Manifest Updates

**Goal:** Update oikos manifests to declare new content.

### 5.1 Update demiurge manifest

```yaml
provides:
  # Add:
  reflexes:
    - reflex/demiurge/artifact-added
    - reflex/demiurge/praxis-added
    - reflex/demiurge/praxis-changed

content_paths:
  # Add:
  - path: entities/
    content_types: [reflex]
```

### 5.2 Update ergon manifest

```yaml
provides:
  # Add:
  reflexes:
    - reflex/ergon/pragma-signaled
    - reflex/ergon/pragma-resolved

content_paths:
  # Add:
  - path: entities/
    content_types: [reflex, pragma]
```

### 5.3 Update nous manifest

```yaml
provides:
  # Add:
  reflexes:
    - reflex/nous/theoria-created
    - reflex/nous/expression-created

content_paths:
  # Add:
  - path: entities/
    content_types: [reflex]
```

### 5.4 Update dynamis manifest

```yaml
provides:
  # Add:
  reflexes:
    - reflex/dynamis/deployment-intent-changed
    - reflex/dynamis/release-artifact-intent-changed

content_paths:
  # Add:
  - path: entities/
    content_types: [reflex]
```

### 5.5 Update aither manifest

```yaml
provides:
  eide:
    # Add:
    - sync-message

  reflexes:
    - reflex/aither/sync-message-received

content_paths:
  # Add:
  - path: entities/
    content_types: [reflex]
```

---

## Sync Points with Chora

| Kosmos Phase | Chora Phase | Handoff |
|--------------|-------------|---------|
| 1 (Stoicheia) | 1.1 | Chora regenerates step_types.rs |
| 2 (Seed Reflexes) | 1.3 | Chora loads reflexes at bootstrap |
| 3 (Response Praxeis) | 1.3 | Chora invokes praxeis from reflexes |
| 4 (Migration Support) | 4.1, 2.1 | Chora uses new eide |
| 5 (Manifests) | All | Chora discovers content via manifests |

---

## Success Criteria

**Phase 1 Complete When:**
- [x] Process stoicheia added to stoicheia-portable (spawn-process, check-process, kill-process)
- [x] register-mcp-tool stoicheion added
- [x] Chora build succeeds with new stoicheia ✅

**Phase 2 Complete When:**
- [x] 9 seed reflexes defined across oikoi (demiurge: 3, ergon: 2, nous: 2, dynamis: 2)
- [x] Manifest updates for all oikoi
- [x] Chora loads all reflexes at bootstrap ✅

**Phase 3 Complete When:**
- [x] 5 response praxeis defined (demiurge: 3, soma: 1, nous: 1)
- [x] Manifests updated with new praxeis
- [x] Chora can invoke praxeis from reflex response ✅

**Phase 4 Complete When:**
- [x] sync-message eidos defined (added processed field)
- [x] deployment eidos has actuality fields (actuality_mode, provider)
- [x] aither sync-message reflex defined
- [x] aither/process-sync-message praxis defined

**Phase 5 Complete When:**
- [x] All manifest updates applied
- [x] Chora discovers reflexes via manifests ✅

---

## ✅ REACTIVE SYSTEM COMPLETE

**Verified by Chora (2026-01-30):**
- All 4 chora phases complete (Core Infrastructure, Process Stoicheia, Reconciliation Loop, Integration)
- E2E verified: deployment entity → reconciler → manifest → action_taken: "manifest"
- All tests pass (7 reconciler integration + 12 v9 equivalence)

---

## Appendix: New Stoicheion for MCP Registration

Phase 3.2 uses `register_mcp_tool` which doesn't exist yet. Add to stoicheia-portable:

```yaml
- eidos: eidos
  id: eidos/stoicheion/register-mcp-tool
  data:
    name: register-mcp-tool
    tier: 3
    description: |
      Dynamically register a praxis as an MCP tool.

      Used by oikos development for testing praxeis without emission.
    params:
      praxis_id:
        type: string
        required: true
        description: Praxis to register
      prefix:
        type: string
        required: false
        default: dev
        description: Tool name prefix
    returns:
      tool_name:
        type: string
        description: Registered tool name
      success:
        type: boolean
```

---

## Critical Requirements for Chora

### 1. $from/$to Must Be Full Entities (for condition evaluation)

**Issue:** Reflexes access `$from.data.status`, `$from.data.title`, etc.

**Two-level resolution needed:**
1. **Trigger filtering** — `from_eidos`/`to_eidos` in bond ChangeEvent variants (chora adding)
2. **Condition evaluation** — Full entity resolution in `build_scope()` (still required)

**Required in build_scope():**
```rust
// For bond events, resolve entities so conditions can access .data
let from_entity = self.find_entity(&from_id)?;
let to_entity = self.find_entity(&to_id)?;
scope.set("from".into(), serde_json::to_value(&from_entity)?);
scope.set("to".into(), serde_json::to_value(&to_entity)?);
```

**Reflexes using this pattern:**
- `reflex/demiurge/artifact-added`: `$from.data.status == "composing"`
- `reflex/demiurge/praxis-added`: `$from.data.status == "composing"`
- `reflex/ergon/pragma-signaled`: `$from.data.title`, `$from.data.priority`

### 2. Event Types — All 6 Supported

Chora implementing symmetrical 6-variant ChangeEvent design:
- `EntityCreated`, `EntityUpdated`, `EntityDeleted`
- `BondCreated`, `BondUpdated`, `BondDeleted`

All 9 seed reflexes (+ 1 in Phase 4) use supported events. ✅

### 3. Chora Design Improvements (Confirmed)

Chora-dev addressing consistency:
- [x] 6 ChangeEvent variants ↔ 6 EventType variants (1:1 mapping)
- [x] Bond events enriched with `from_eidos`/`to_eidos`
- [x] Scope filtering in `matches()` (circle/oikos/global)
- [x] Thread-safe depth via `AtomicU32`

---

## Missing Definitions — Resolved

### notification Eidos ✅

Added:
- `eidos/notification` in [genesis/soma/eide/soma.yaml](genesis/soma/eide/soma.yaml)
- `typos-def-notification` in [genesis/spora/definitions/soma.yaml](genesis/spora/definitions/soma.yaml)
- Updated soma manifest with notification in provides.eide

---

*Plan created: 2026-01-30*
*Reference: [genesis/REACTIVE-SYSTEM.md](genesis/REACTIVE-SYSTEM.md)*
*Sync with: [chora/REACTIVE-SYSTEM-PLAN.md](../chora/REACTIVE-SYSTEM-PLAN.md)*
