# Front 1: Reflex Declarations Across Topoi

## Goal

Declare reflex entities for every topos that describes event-driven automation. Reflexes are the nervous system — entity mutations trigger automated responses. The reflex *engine* is chora-side, but the *definitions* are kosmos YAML.

When the engine is implemented, these reflexes activate immediately.

## Reflex Entity Structure

From `genesis/ergon/eide/ergon.yaml` and existing examples in nous/demiurge:

```yaml
- eidos: reflex
  id: reflex/{topos}/{name}
  data:
    name: {name}
    description: |
      What this reflex does and why.
    trigger:
      event: entity_created | entity_updated | bond_created
      eidos: {target_eidos}          # filter by entity type
      condition: '$entity.data.field == "value"'  # optional condition
    response:
      praxis: {topos}/{praxis-name}
      params:
        param_name: "$entity.data.field"
    enabled: true
    scope: global | oikos | topos
```

**Context variables in conditions and params:**
- `$entity` — the mutated entity
- `$previous` — entity state before mutation (for updates)
- `$bond` — the bond (for bond events)
- `$from` / `$to` — source/target entities (for bond events)

## Existing Reflexes (don't duplicate)

**Nous** (`genesis/nous/entities/reflexes.yaml`):
- `reflex/nous/index-theoria` — Index theoria on creation for semantic surfacing
- `reflex/nous/ambient-intelligence` — Suggest related theoria when context changes

**Demiurge** (`genesis/demiurge/entities/reflexes.yaml`):
- `reflex/demiurge/track-artifact` — Track artifact dependencies on creation
- `reflex/demiurge/validate-praxis` — Validate praxis on creation/update

**Ergon** (`genesis/ergon/entities/reflexes.yaml`):
- Various pragma-related reflexes (check before modifying)

## New Reflexes to Declare

### oikos — `genesis/oikos/entities/reflexes.yaml` (create new file)

```yaml
# Reflexes for the intimate dwelling layer
entities:

  # When insight is surfaced, emit a phasis announcing it
  - eidos: reflex
    id: reflex/oikos/announce-insight
    data:
      name: announce-insight
      description: |
        When an insight is surfaced, emit a phasis into the oikos discourse
        so all dwellers see the crystallization.
      trigger:
        event: entity_created
        eidos: insight
      response:
        praxis: logos/emit-phasis
        params:
          content: "$entity.data.content"
          stance: declaration
          source_kind: topos
          metadata:
            source_eidos: insight
            source_id: "$entity.id"
      enabled: true
      scope: oikos

  # When a note is created, check if it should be surfaced as insight
  - eidos: reflex
    id: reflex/oikos/note-to-insight
    data:
      name: note-to-insight
      description: |
        When multiple notes accumulate in a domain, suggest surfacing
        an insight via manteia analysis.
      trigger:
        event: entity_created
        eidos: note
      response:
        praxis: oikos/surface-insight
        params:
          note_id: "$entity.id"
      enabled: true
      scope: oikos
```

### politeia — `genesis/politeia/entities/reflexes.yaml` (create new file)

```yaml
entities:

  # When membership changes, re-derive attainments
  - eidos: reflex
    id: reflex/politeia/derive-attainments-on-join
    data:
      name: derive-attainments-on-join
      description: |
        When a prosopon joins an oikos (membership bond created),
        automatically derive their attainments from oikos configuration.
      trigger:
        event: bond_created
        desmos: member-of
      response:
        praxis: politeia/derive-attainments
        params:
          prosopon_id: "$from.id"
          oikos_id: "$to.id"
      enabled: true
      scope: global

  # When membership changes, create a membership-event entity
  - eidos: reflex
    id: reflex/politeia/log-membership-change
    data:
      name: log-membership-change
      description: |
        When membership bonds are created or dissolved, create a
        membership-event entity for audit trail.
      trigger:
        event: bond_created
        desmos: member-of
      response:
        praxis: politeia/create-membership-event
        params:
          prosopon_id: "$from.id"
          oikos_id: "$to.id"
          event_type: joined
      enabled: true
      scope: global

  # When an invitation is accepted, emit phasis
  - eidos: reflex
    id: reflex/politeia/announce-join
    data:
      name: announce-join
      description: |
        When a new member joins, announce it in the oikos discourse.
      trigger:
        event: entity_created
        eidos: membership-event
        condition: '$entity.data.event_type == "joined"'
      response:
        praxis: logos/emit-phasis
        params:
          content: "New member joined the oikos"
          stance: declaration
          source_kind: topos
          metadata:
            source_eidos: membership-event
            source_id: "$entity.id"
      enabled: true
      scope: oikos
```

### propylon — `genesis/propylon/entities/reflexes.yaml` (create new file)

```yaml
entities:

  # When entry is requested, notify steward
  - eidos: reflex
    id: reflex/propylon/notify-entry-request
    data:
      name: notify-entry-request
      description: |
        When an entry request arrives (via propylon link), emit a phasis
        requesting steward approval.
      trigger:
        event: entity_created
        eidos: entry-request
      response:
        praxis: logos/emit-phasis
        params:
          content: "Entry request received — approval needed"
          stance: request
          source_kind: topos
          metadata:
            source_eidos: entry-request
            source_id: "$entity.id"
      enabled: true
      scope: oikos

  # When entry is approved, announce
  - eidos: reflex
    id: reflex/propylon/announce-entry-approved
    data:
      name: announce-entry-approved
      description: |
        When entry is approved, announce in discourse.
      trigger:
        event: entity_updated
        eidos: entry-request
        condition: '$entity.data.status == "approved"'
      response:
        praxis: logos/emit-phasis
        params:
          content: "Entry approved — new prosopon arriving"
          stance: declaration
          source_kind: topos
          metadata:
            source_eidos: entry-request
            source_id: "$entity.id"
      enabled: true
      scope: oikos
```

### agora — `genesis/agora/entities/reflexes.yaml` (create new file)

```yaml
entities:

  # When gathering begins, announce it
  - eidos: reflex
    id: reflex/agora/announce-gathering
    data:
      name: announce-gathering
      description: |
        When a gathering begins in a territory, emit a phasis
        inviting dwellers to join.
      trigger:
        event: entity_created
        eidos: gathering
      response:
        praxis: logos/emit-phasis
        params:
          content: "Gathering started — join the assembly"
          stance: invitation
          source_kind: topos
          metadata:
            source_eidos: gathering
            source_id: "$entity.id"
      enabled: true
      scope: oikos

  # When parousia enters territory, track presence
  - eidos: reflex
    id: reflex/agora/track-territory-presence
    data:
      name: track-territory-presence
      description: |
        When a presence-in-territory bond is created, update
        the gathering's participant count and emit notification.
      trigger:
        event: bond_created
        desmos: present-in
      response:
        praxis: agora/update-gathering-presence
        params:
          territory_id: "$to.id"
          parousia_id: "$from.id"
      enabled: true
      scope: oikos
```

### nous — add to existing `genesis/nous/entities/reflexes.yaml`

```yaml
  # When theoria accumulate in a domain, suggest pattern clustering
  - eidos: reflex
    id: reflex/nous/suggest-pattern
    data:
      name: suggest-pattern
      description: |
        When a new theoria is crystallized, check if enough theoria
        exist in the same domain to suggest pattern detection.
      trigger:
        event: entity_created
        eidos: theoria
      response:
        praxis: nous/detect-patterns
        params:
          domain: "$entity.data.domain"
      enabled: true
      scope: global

  # When a pattern is crystallized, announce via logos
  - eidos: reflex
    id: reflex/nous/announce-pattern
    data:
      name: announce-pattern
      description: |
        When a pattern emerges from theoria clustering, announce
        in discourse as a significant knowledge event.
      trigger:
        event: entity_created
        eidos: pattern
      response:
        praxis: logos/emit-phasis
        params:
          content: "Pattern emerged: $entity.data.name"
          stance: declaration
          source_kind: topos
          metadata:
            source_eidos: pattern
            source_id: "$entity.id"
      enabled: true
      scope: global
```

### dynamis — `genesis/dynamis/entities/reflexes.yaml` (create new file)

```yaml
entities:

  # When deployment drift is detected, announce
  - eidos: reflex
    id: reflex/dynamis/announce-drift
    data:
      name: announce-drift
      description: |
        When a deployment's actual state diverges from desired state,
        emit a phasis alerting dwellers to the drift.
      trigger:
        event: entity_updated
        eidos: deployment
        condition: '$entity.data.status != $previous.data.status'
      response:
        praxis: logos/emit-phasis
        params:
          content: "Deployment status changed: $entity.data.name is now $entity.data.status"
          stance: declaration
          source_kind: topos
          metadata:
            source_eidos: deployment
            source_id: "$entity.id"
      enabled: true
      scope: global
```

## How to Do It

For each topos:

1. **Read** any existing reflexes file (check `entities/reflexes.yaml`)
2. **Create** or **append** the reflex definitions above
3. **Verify** that referenced praxeis exist in the target topos (e.g., `politeia/derive-attainments`, `agora/update-gathering-presence`)
4. **If a referenced praxis doesn't exist**, note it as a gap but still declare the reflex — the reflex shows the intent
5. **Update** the topos `manifest.yaml` content_paths to include the new entities file if not already listed
6. **Check** for consistency: trigger eidos names match actual eidos IDs, desmos names match actual desmos IDs

## Verification

After declaring all reflexes:
- Every new file is valid YAML with `entities:` array
- Every reflex has: id, name, description, trigger, response, enabled, scope
- Trigger eidos/desmos references are verified against actual definitions
- Response praxis references use correct `{topos}/{name}` format
- No duplicate reflex IDs across files
- Manifest content_paths updated where needed
