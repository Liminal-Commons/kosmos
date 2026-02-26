# Chora Handoff: Topos Development Experience — Deferred Scope

> **Status:** Active
> **Waiting on:** Projected/Embodied levels in chora (project-topos, reconciler)

*Document for chora implementation team. Describes features that require Rust/MCP implementation.*

---

## Context

The topos development experience has been implemented in kosmos with:

- **8 development praxeis**: begin-topos, add-eidos, add-praxis, add-desmos, validate-topos, emit-topos, get-topos, list-developing
- **4 palette discovery praxeis**: discover-stoicheia, discover-typos, discover-desmoi, discover-surfaces
- **Development bonds**: contains, developing, emitted-to
- **Enhanced topos eidos**: category, surfaces, status, validation_errors fields

**Current Status:**
- ✅ **Loaded** — Praxeis bootstrap and execute
- ✅ **Cursor infrastructure** — last-saw desmos, notification stoicheia, global versioning
- ✅ **Hybrid rendering** — render-specs rendered by native components

The current implementation reaches **Loaded** level of the topos completeness ladder (Defined → Loaded → Projected → Embodied → Surfaced → Afforded).

This document covers the remaining levels: **Projected**, **Embodied**, **Surfaced**, and **Afforded**.

**Key insight:** Most of Embodied and Surfaced levels can now be implemented in **kosmos YAML** by extending sense-body with the cursor infrastructure that chora has implemented.

---

## 1. project-topos — Projection Without Emission (Projected Level)

> **Note:** The reactive system ([REACTIVE-SYSTEM.md](genesis/REACTIVE-SYSTEM.md)) may obsolete explicit projection. A reflex that fires on `bond_created` (contains + praxis) could auto-register praxeis as MCP tools during development, eliminating the need for explicit `project-topos` invocation. See the reflex example in [ergon/DESIGN.md](genesis/ergon/DESIGN.md#example-reflexes).

### Purpose

Enable testing praxeis during topos development without emitting to genesis. A developing topos's praxeis become temporarily available as MCP tools.

### Expected Behavior

```
project-topos(topos_id: "topos/recipes")
  → praxis/recipes/create becomes testable MCP tool
  → praxis/recipes/list becomes testable MCP tool
  → changes don't persist to genesis
  → teardown removes projection
```

### Implementation Requirements

**In chora (Rust):**

1. **Dynamic praxis registration** — The MCP server currently discovers praxeis at bootstrap. Need ability to register praxeis dynamically at runtime.

2. **Projection lifecycle** — Track which topoi are projected. Praxeis should be prefixed or scoped to indicate projection (e.g., `projected_recipes_create` or namespace).

3. **Teardown** — `unproject-topos` removes the projected praxeis from MCP tools.

4. **Isolation** — Projected praxeis may create entities. Consider whether these are:
   - In a separate "projection" namespace (clean teardown)
   - In the main graph but marked as "projected" (integration testing)

**In kosmos (YAML praxis):**

```yaml
- eidos: praxis
  id: praxis/demiurge/project-topos
  data:
    topos: demiurge
    name: project-topos
    visible: true
    tier: 2
    description: |
      Temporarily project a topos's praxeis as MCP tools.

      Enables testing praxeis during development without emission.
      Use unproject-topos to remove the projection.
    params:
      - name: topos_id
        type: string
        required: true
      - name: scope
        type: string
        required: false
        description: "isolated (default) or integrated"
    steps:
      # This step requires chora support
      - step: project
        topos_id: "$topos_id"
        scope: "$scope"
        bind_to: projection

      - step: update
        id: "$topos_id"
        data:
          status: projected

      - step: return
        value:
          projection: "$projection"
          tools: "$projection.tools"
          message: "Praxeis projected as MCP tools. Test via tool calls."
```

**New stoicheion required:** `project` (tier 2)
- Invokes chora's dynamic praxis registration
- Returns projection metadata (tool names, scope)

### Testing

1. Begin topos, add praxis
2. Call project-topos
3. Verify MCP tool list includes projected praxeis
4. Call projected praxis
5. Call unproject-topos
6. Verify MCP tool list no longer includes them

---

## 2. Development Notifications (Surfaced Level)

### Purpose

Surface development opportunities when changes occur in topos being developed. Uses the cursor-based notification system (now complete) to detect changes.

### How This Works

The cursor model (documented in ARCHITECTURE.md) provides change detection:

```
parousia --last-saw[version=38]--> oikos/chora

Notification query:
  entities in oikos WHERE version > 38
  → 4 entities changed since last view
```

For topos development, Claude sees notifications about:
- New definitions added to developing topoi
- Validation state changes
- Emission events

### Expected Body-Schema Section

```yaml
body-schema:
  notifications:
    - oikos_id: "topos/recipes"
      unseen_count: 3  # 3 new entities since last view

  development:
    active_topoi:
      - id: "topos/recipes"
        status: composing
        pending_actions:
          - validate-topos  # When has definitions
          - emit-topos      # When status = valid
```

### Implementation Requirements

**Already complete in chora:**
- ✅ `last-saw` desmos with version data
- ✅ Cursor stoicheia (get_cursor, update_cursor)
- ✅ Global entity versioning
- ✅ Notification count queries

**Needed in kosmos (YAML praxis extension):**

Extend sense-body praxis to compute development `pending_actions`:

```yaml
# In sense-body extension
- step: trace
  from_id: "$_parousia.id"
  desmos: developing
  resolve: to
  bind_to: developing_topoi

- step: for_each
  items: "$developing_topoi"
  as: topos
  do:
    - step: trace
      from_id: "$topos.id"
      desmos: contains
      resolve: to
      bind_to: definitions

    - step: switch
      cases:
        - when: '$topos.data.status == "composing" && $definitions | length > 0'
          then:
            - step: set
              bindings:
                pending: ["validate-topos"]
        - when: '$topos.data.status == "valid"'
          then:
            - step: set
              bindings:
                pending: ["emit-topos", "project-topos"]
```

This is **kosmos YAML work** — no chora Rust changes needed.

---

## 3. Body-Schema Contribution (Embodied Level)

### Purpose

Development state appears in body-schema, giving Claude awareness of development context.

### Expected Body-Schema Section

```yaml
body-schema:
  # ... other sections ...

  development:
    active_topoi:
      - id: "topos/recipes"
        name: "recipes"
        status: composing
        eide_count: 3
        praxeis_count: 2
        desmoi_count: 1

    palette_awareness:
      stoicheia_tiers:
        tier_0: 3
        tier_1: 8
        tier_2: 12
        tier_3: 5
      typos_count: 47
      desmoi_count: 23

    available_surfaces:
      rendering:
        status: available
        interface: opsis
      reasoning:
        status: available
        interface: manteia
      coordination:
        status: available
        interface: ergon
```

### Implementation Requirements

**This is kosmos YAML work** — sense-body is a praxis that can be extended with steps.

See [CHORA-HANDOFF-SENSE-BODY.md](CHORA-HANDOFF-SENSE-BODY.md) for the complete sense-body extension plan, which includes:
- Development context section (trace `developing` bonds)
- Palette awareness section (gather stoicheia/typos/desmoi counts)
- Surface availability section (query topos manifests)

**Implementation approach:**

```yaml
# Extend sense-body praxis with development sensing
- step: trace
  from_id: "$_parousia.id"
  desmos: developing
  resolve: to
  bind_to: developing_topoi

- step: for_each
  items: "$developing_topoi"
  as: topos
  do:
    - step: trace
      from_id: "$topos.id"
      desmos: contains
      resolve: to
      bind_to: definitions
    # Count by eidos type, compute status...
```

**Chora dependencies (already complete):**
- ✅ Cursor stoicheia for notifications
- ✅ Global entity versioning

---

## 4. Thyra topos-view (Afforded Level)

### Purpose

Visual development environment in thyra. The topos renders with contextual affordances based on status.

### Expected Rendering

**render-type: topos-dev-view**

```
┌─────────────────────────────────────────────────────┐
│ recipes                                    [composing] │
│ Purpose: Recipe management and meal planning         │
├─────────────────────────────────────────────────────┤
│ ▼ Eide (3)                                          │
│   ├─ recipe — A cooking recipe                      │
│   ├─ ingredient — An ingredient with amount         │
│   └─ meal-plan — Weekly meal planning               │
├─────────────────────────────────────────────────────┤
│ ▼ Praxeis (2)                                       │
│   ├─ create-recipe — Create a new recipe            │
│   └─ suggest-meal — Suggest meal from ingredients   │
├─────────────────────────────────────────────────────┤
│ ▼ Desmoi (1)                                        │
│   └─ contains-ingredient — Recipe has ingredient    │
├─────────────────────────────────────────────────────┤
│ ⚠ Warnings                                          │
│   • uses raw 'arise' in create-recipe               │
├─────────────────────────────────────────────────────┤
│ [Validate]  [Emit]  [Project for Testing]           │
└─────────────────────────────────────────────────────┘
```

### Implementation Requirements

**In kosmos (render-type definition):**

```yaml
- eidos: render-type
  id: render-type/topos-dev-view
  data:
    for_eidos: topos
    description: |
      Development view for a topos being composed.
      Shows contained definitions, validation state, and contextual actions.
    render_strategy: declarative
    render_spec: render-spec/topos-dev-view
```

**In kosmos (render-spec):**

```yaml
- eidos: render-spec
  id: render-spec/topos-dev-view
  data:
    template: |
      <topos-dev-view>
        <header>
          <title>{{ entity.data.name }}</title>
          <status-badge status="{{ entity.data.status }}" />
        </header>
        <purpose>{{ entity.data.purpose }}</purpose>

        <section-collapsible title="Eide" count="{{ eide | length }}">
          <definition-list definitions="{{ eide }}" />
        </section-collapsible>

        <section-collapsible title="Praxeis" count="{{ praxeis | length }}">
          <definition-list definitions="{{ praxeis }}" />
        </section-collapsible>

        <section-collapsible title="Desmoi" count="{{ desmoi | length }}">
          <definition-list definitions="{{ desmoi }}" />
        </section-collapsible>

        <validation-warnings warnings="{{ validation_warnings }}" />

        <action-bar>
          <action-button
            action="validate-topos"
            params="{{ {topos_id: entity.id} }}"
            enabled="{{ entity.data.status == 'composing' }}" />
          <action-button
            action="emit-topos"
            params="{{ {topos_id: entity.id} }}"
            enabled="{{ entity.data.status == 'valid' }}" />
          <action-button
            action="project-topos"
            params="{{ {topos_id: entity.id} }}"
            enabled="{{ entity.data.status == 'valid' }}" />
        </action-bar>
      </topos-dev-view>

    data_preparation: |
      # Gather contained definitions
      eide = trace(entity.id, 'contains', 'to') | filter(eidos == 'eidos')
      praxeis = trace(entity.id, 'contains', 'to') | filter(eidos == 'praxis')
      desmoi = trace(entity.id, 'contains', 'to') | filter(eidos == 'desmos')
      validation_warnings = entity.data.validation_errors | filter(type == 'warning')
```

**In chora (opsis/thyra):**

1. **Render-spec processing** — The declarative render strategy needs to:
   - Parse the template
   - Run data_preparation queries
   - Bind data to template variables
   - Render to UI component

2. **Components:**
   - `<topos-dev-view>` — Main container
   - `<section-collapsible>` — Expandable section
   - `<definition-list>` — List of eide/praxeis/desmoi
   - `<validation-warnings>` — Warning display
   - `<action-bar>` / `<action-button>` — Affordance buttons

3. **Action binding** — action-button invokes praxeis via MCP

**Panel: development-context**

Sidebar panel showing topoi being developed:

```yaml
- eidos: panel
  id: panel/development-context
  data:
    title: "Development"
    position: sidebar
    render_spec: render-spec/development-panel
    visibility_condition: '$_parousia | trace("developing") | length > 0'
```

---

## Implementation Priority

| Feature | Effort | Value | Implementation |
|---------|--------|-------|----------------|
| **Body-schema contribution** | Low | High | Kosmos YAML — extend sense-body praxis |
| **Development notifications** | Low | High | Kosmos YAML — uses existing cursor infrastructure |
| **project-topos** | High | Medium | Chora Rust — dynamic MCP tool registration |
| **Thyra topos-view** | Medium | High | Hybrid — render-spec + thyra components |

Body-schema and notifications are **kosmos YAML work** that builds on the now-complete cursor infrastructure. These have the highest impact for Claude-based development.

project-topos requires chora changes for dynamic tool registration. Thyra view uses the hybrid rendering pattern (render-specs rendered by native components).

---

## Dependencies

| Feature | Where | Notes |
|---------|-------|-------|
| Body-schema | Kosmos | Extend sense-body praxis in YAML |
| Notifications | Kosmos | Uses cursor infrastructure (complete) |
| project-topos | Chora | kosmos-mcp dynamic tool registration |
| Thyra view | Both | render-spec (kosmos) + components (chora) |

---

## Testing Strategy

### Body-Schema

1. Create developing bond from parousia to topos
2. Call sense-body
3. Verify development section populated
4. Add definitions, verify counts update

### Development Notifications

1. Create last-saw bond from prosopon to topos oikos
2. Add entities to the topos (version advances)
3. Query notifications — should show unseen count > 0
4. Call mark-oikos-seen to update cursor
5. Query notifications — unseen count should be 0

### project-topos

1. Create topos with praxis
2. Validate topos
3. Call project-topos
4. Verify MCP tools include projected praxis
5. Call projected praxis, verify execution
6. Call unproject-topos
7. Verify MCP tools no longer include it

### Thyra View

1. Navigate to topos entity in thyra
2. Verify topos-dev-view renders
3. Verify sections show correct counts
4. Click action buttons, verify praxis invocation
5. Verify status badge updates after actions

---

## Questions for Chora Team

1. **Dynamic tool registration** — What's the cleanest way to add/remove MCP tools at runtime? Is there an existing pattern in kosmos-mcp?

2. **Render-spec processing** — What's the current state of declarative rendering? Is data_preparation expression parsing implemented? (Hybrid rendering is now working for cards — does this extend to complex views?)

3. **Isolation scope** — For projected praxeis, should entities created during testing be isolated or integrated? What's the cleanup story?

---

## Implementation Status

| Component | Status | Notes |
|-----------|--------|-------|
| Cursor infrastructure | ✅ Complete | last-saw desmos, stoicheia, versioning |
| Hybrid rendering | ✅ Complete | render-specs + native components working |
| Body-schema extension | ⏳ Kosmos YAML | Extend sense-body praxis |
| Development notifications | ⏳ Kosmos YAML | Build on cursor infrastructure |
| project-topos | ⏳ Chora | Dynamic MCP tool registration |
| Thyra topos-view | ⏳ Both | render-spec + components |

---

*This document prepared from kosmos session 2026-01-29, updated 2026-01-30.*
*Implementing team: chora/soma/demiurge*
