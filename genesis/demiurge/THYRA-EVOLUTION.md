# Thyra Evolution via GDS

*Systematically evolving oikoi to use thyra rendering.*

**Status:** Design
**Depends on:** [THYRA-AWARENESS.md](THYRA-AWARENESS.md), [RENDER-SPEC-GUIDE.md](RENDER-SPEC-GUIDE.md)

---

## The Problem

Each topos has eide that users interact with. Without thyra evolution:
- UI is hardcoded in chora (SolidJS components)
- Adding new eide requires chora changes
- No consistency across oikoi presentations
- Agents can't generate UIs

With thyra evolution:
- Render-specs define presentation declaratively
- New eide get UIs via generation
- Consistent patterns via widget vocabulary
- Agents can evolve UIs without chora changes

---

## The Evolution Workflow

```
┌─────────────────────────────────────────────────────────────────┐
│                    evolve-topos-thyra                           │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  1. ANALYZE                                                     │
│     ├── Read manifest.yaml                                      │
│     ├── Gather eide from content_paths                          │
│     └── Understand topos purpose from DESIGN.md                 │
│                                                                 │
│  2. CLASSIFY                                                    │
│     ├── Which eide are user-facing? (renderable)               │
│     ├── What variants needed? (card, list-item, detail)        │
│     └── What interactions? (clickable, editable, actionable)   │
│                                                                 │
│  3. GENERATE                                                    │
│     ├── For each renderable eidos:                             │
│     │   ├── generate-render-spec (card variant)                │
│     │   ├── generate-render-spec (list-item if needed)         │
│     │   └── generate-render-spec (detail if needed)            │
│     └── Generate panel render-specs if needed                   │
│                                                                 │
│  4. CONNECT                                                     │
│     ├── Create renderer entities                                │
│     └── Map render-types to render-specs                        │
│                                                                 │
│  5. UPDATE                                                      │
│     ├── Add render-specs/ to content_paths                     │
│     ├── Add renderable section to provides                      │
│     └── Emit files to genesis/{topos}/render-specs/            │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

---

## Renderable Classification

Not all eide need render-specs. Classification criteria:

### Renderable (needs UI)

| Criterion | Examples |
|-----------|----------|
| User creates/views these | theoria, oikos, phasis |
| Appears in lists/panels | invitation, membership-event |
| Has status users track | stream, pragma, release |
| User takes actions on | affordance, attainment |

### Not Renderable (internal)

| Criterion | Examples |
|-----------|----------|
| Internal state | cursor, accumulation |
| Configuration | voice-pipeline-config |
| Bonds/relationships | (most desmoi) |
| System entities | content-root, topos |

### Classification Prompt

```
Given the topos "{topos_name}" with purpose:
{design_summary}

And these eide:
{eide_list}

Classify each eidos as:
- renderable: Users see and interact with these
- internal: System state, not user-facing

For renderable eide, specify:
- variants needed: card, list-item, detail, panel
- interactive: Does clicking do something?
- fields_to_show: Key fields to display
```

---

## New Praxeis

### evolve-topos-thyra

Main entry point for thyra evolution.

```yaml
- eidos: praxis
  id: praxis/demiurge/evolve-topos-thyra
  data:
    topos: demiurge
    name: evolve-topos-thyra
    visible: true
    tier: 3
    description: |
      Evolve a topos to use thyra rendering.

      Analyzes the topos, classifies renderable eide,
      generates render-specs, and updates the manifest.

      This is the compound leverage pattern:
      One invocation → multiple render-specs → complete UI coverage.

    params:
      - name: topos_name
        type: string
        required: true
        description: The topos to evolve (e.g., "nous", "hodos")

      - name: dry_run
        type: boolean
        required: false
        default: false
        description: If true, return plan without creating files

    steps:
      # 1. ANALYZE
      - step: call
        praxis: demiurge/analyze-topos-for-thyra
        params:
          topos_name: "$topos_name"
        bind_to: analysis

      # 2. CLASSIFY
      - step: call
        praxis: demiurge/classify-renderable-eide
        params:
          topos_name: "$topos_name"
          eide: "$analysis.eide"
          design_summary: "$analysis.design_summary"
        bind_to: classification

      # 3. GENERATE (for each renderable)
      - step: set
        bindings:
          render_specs: []
          renderers: []

      - step: for_each
        source: "$classification.renderable"
        as: renderable
        steps:
          - step: for_each
            source: "$renderable.variants"
            as: variant
            steps:
              - step: call
                praxis: demiurge/generate-render-spec
                params:
                  eidos_name: "$renderable.eidos"
                  variant: "$variant"
                  purpose: "$renderable.description"
                  interactive: "$renderable.interactive"
                  oikos_context: "$topos_name"
                bind_to: spec_result

              - step: append
                to: render_specs
                value: "$spec_result"

          # Create renderer for this eidos
          - step: call
            praxis: demiurge/generate-renderer
            params:
              eidos_name: "$renderable.eidos"
              topos_name: "$topos_name"
              variants: "$renderable.variants"
            bind_to: renderer_result

          - step: append
            to: renderers
            value: "$renderer_result"

      # 4. Plan or Execute
      - step: switch
        cases:
          - when: "$dry_run"
            then:
              - step: return
                value:
                  status: plan
                  topos: "$topos_name"
                  analysis: "$analysis"
                  classification: "$classification"
                  render_specs_planned: "$render_specs"
                  renderers_planned: "$renderers"
        default:
          # 5. UPDATE - Emit files and update manifest
          - step: call
            praxis: demiurge/apply-thyra-evolution
            params:
              topos_name: "$topos_name"
              render_specs: "$render_specs"
              renderers: "$renderers"
              classification: "$classification"
            bind_to: apply_result

          - step: return
            value:
              status: evolved
              topos: "$topos_name"
              files_created: "$apply_result.files_created"
              manifest_updated: "$apply_result.manifest_updated"
```

### analyze-topos-for-thyra

```yaml
- eidos: praxis
  id: praxis/demiurge/analyze-topos-for-thyra
  data:
    topos: demiurge
    name: analyze-topos-for-thyra
    visible: false
    tier: 1
    description: Analyze a topos for thyra evolution.

    params:
      - name: topos_name
        type: string
        required: true

    steps:
      # Read manifest
      - step: find
        query:
          eidos: content-root
          id: "content-root/$topos_name"
        bind_to: content_root

      # Gather eide
      - step: gather
        query:
          eidos: eidos
        filter: ".data.topos == '$topos_name' || .id contains '$topos_name/'"
        bind_to: eide

      # Read DESIGN.md for context (via file read or theoria)
      - step: surface
        query: "$topos_name purpose ontological"
        eidos: theoria
        limit: 3
        bind_to: theoria

      - step: return
        value:
          topos_name: "$topos_name"
          eide: "$eide"
          eide_count: "{{ len($eide) }}"
          design_summary: "$theoria"
```

### classify-renderable-eide

```yaml
- eidos: praxis
  id: praxis/demiurge/classify-renderable-eide
  data:
    topos: demiurge
    name: classify-renderable-eide
    visible: false
    tier: 3
    description: Use inference to classify which eide are renderable.

    params:
      - name: topos_name
        type: string
        required: true
      - name: eide
        type: array
        required: true
      - name: design_summary
        type: string
        required: false

    steps:
      - step: call
        praxis: manteia/governed-inference
        params:
          prompt: |
            Classify the eide from topos "$topos_name" for thyra rendering.

            Purpose: $design_summary

            Eide to classify:
            $eide

            For each eidos, determine:
            1. Is it renderable? (users see/interact with it)
            2. If renderable:
               - variants: which of [card, list-item, detail] are needed
               - interactive: does clicking trigger an action
               - description: what this renders

            Return JSON:
            {
              "renderable": [
                {
                  "eidos": "name",
                  "variants": ["card"],
                  "interactive": true,
                  "description": "Shows X with Y"
                }
              ],
              "internal": ["eidos1", "eidos2"]
            }
          output_schema:
            type: object
            properties:
              renderable:
                type: array
              internal:
                type: array
        bind_to: result

      - step: return
        value: "$result"
```

---

## Batch Evolution

To evolve all oikoi:

```yaml
# evolve-all-topoi-thyra
- step: gather
  query:
    eidos: content-root
  filter: ".data.content_type == 'topos'"
  bind_to: all_oikoi

- step: filter
  source: "$all_oikoi"
  condition: "!.data.thyra_evolved"  # Skip already evolved
  bind_to: unevolved

- step: for_each
  source: "$unevolved"
  as: topos
  steps:
    - step: call
      praxis: demiurge/evolve-topos-thyra
      params:
        topos_name: "$topos.data.name"
      bind_to: result

    - step: call
      praxis: nous/crystallize-theoria
      params:
        insight: "Evolved $topos.data.name to thyra: $result.files_created"
        domain: "thyra-evolution"
```

---

## Current State

| Oikos | Renderable Eide | Render-Specs | Status |
|-------|-----------------|--------------|--------|
| **politeia** | oikos, attainment, affordance, invitation, membership-event | oikos-card, oikos-list, attainment-card, affordance-card, invitation-card, membership-event-item, governance-panel | ✅ Evolved |
| **nous** | theoria, journey, waypoint, inquiry, axiom, principle, pattern | theoria-card, theoria-list, journey-card, waypoint-item, inquiry-card, axiom-card, principle-card, pattern-card | ✅ Evolved |
| **logos** | phasis | phasis-bubble, phasis-thread, phasis-thread-item | ✅ Evolved |
| **hypostasis** | prosopon | presence-list | ✅ Partial |
| **chora-dev** | source-crate, build-target, test-run, lint-run | source-crate-card, build-target-card, test-run-card, lint-run-card, workspace-panel | ✅ Evolved |
| **thyra** | voice-composer, panels | voice-composer, theoria-list, presence-list, oikos-list, phasis-thread, journey-list | ✅ Evolved |
| **psyche** | attention, intention, mood, thyra, prospect, kairos | attention-card, intention-card, mood-card, thyra-card, prospect-card, kairos-card | ✅ Evolved |
| **ergon** | pragma, reflex | pragma-card, reflex-card | ✅ Evolved |
| **release** | release, release-artifact, distribution-channel | release-card, release-artifact-card, distribution-channel-card | ✅ Evolved |
| **hodos** | journey, waypoint | (via nous render-specs) | ✅ Via nous |
| **agora** | territory, presence | | ⏳ Pending |
| **manteia** | (internal - no UI) | | — Skip |
| **dynamis** | (internal - no UI) | | — Skip |
| **soma** | (internal - no UI) | | — Skip |

---

## Evolution Order

Recommended order based on user impact and dependencies:

### Phase 1: Core User-Facing
1. **nous** - theoria cards are everywhere
2. **hodos** - journey navigation
3. **hypostasis** - prosopon display

### Phase 2: Interaction
4. **logos** - phasis thread
5. **psyche** - focus/intention indicators
6. **ergon** - daemon status, pragma cards

### Phase 3: Infrastructure Visibility
7. **release** - release tracking
8. **thyra** - stream status (if needed)

---

## Usage

### Single Oikos (Dry Run)

```
demiurge/evolve-topos-thyra:
  topos_name: "nous"
  dry_run: true
```

Returns plan without creating files.

### Single Oikos (Execute)

```
demiurge/evolve-topos-thyra:
  topos_name: "nous"
```

Creates render-specs, renderers, updates manifest.

### All Oikoi

```
demiurge/evolve-all-topoi-thyra
```

Evolves all unevolved oikoi in recommended order.

---

## Compound Leverage

One `evolve-topos-thyra` invocation:
- Analyzes the topos structure
- Classifies N eide as renderable
- Generates N×M render-specs (N eide × M variants)
- Creates N renderer entities
- Updates the manifest
- Crystallizes theoria about what was learned

**Example:** nous with 2 renderable eide, 2 variants each:
- 1 invocation → 4 render-specs + 2 renderers + manifest update

---

## Files Created

For each evolved topos:

```
genesis/{topos}/
├── manifest.yaml          # Updated with renderable section
├── render-specs/
│   ├── {eidos}-card.yaml
│   ├── {eidos}-list-item.yaml
│   └── ...
└── entities/
    └── renderers.yaml     # Or panel-renderers.yaml
```

---

## Integration with develop-topos-from-design

When creating a new topos via GDS, thyra evolution is automatic:

```yaml
# In develop-topos-from-design, after actualization:
- step: call
  praxis: demiurge/evolve-topos-thyra
  params:
    topos_name: "$topos_name"
```

New oikoi are born thyra-aware.

---

*Composed in service of the kosmogonia.*
*What exists can now appear. What appears can be evolved.*
