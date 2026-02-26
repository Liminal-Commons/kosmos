# Front 1: Topos Deepening

## Goal

Per-topos interventions that complete patterns already begun. These are the gaps identified in the hearing report that don't fit the other four prompts.

## 1. Nous Knowledge Ladder — Complete the Climb

**Problem:** Nous defines eide for the full knowledge ladder (theoria → pattern → principle → axiom) but only has praxeis for the first two levels. The attainments reference praxeis that don't exist yet.

**Missing praxeis** (declared in attainments but not authored):
- `crystallize-principle` — granted by `attainment/crystallize`
- `elevate-to-pattern` — granted by `attainment/crystallize`
- `elevate-to-principle` — granted by `attainment/crystallize`
- `crystallize-axiom` — granted by `attainment/constitute`
- `elevate-to-axiom` — granted by `attainment/constitute`
- `establish-axiom` — granted by `attainment/constitute`

### Actions

Read `genesis/nous/praxeis/nous.yaml` and add these praxeis, following the pattern of `crystallize-theoria` and `crystallize-pattern`:

**crystallize-principle:**
```yaml
params: [name, guidance, rationale, domain, grounded_in_pattern_ids]
steps:
  - assert: $_prosopon, $_oikos
  - compose: principle entity with fields
  - for_each: grounded_in_pattern_ids → bind grounded-in bonds
  - call: nous/index (for semantic surfacing)
  - call: logos/emit-phasis (announce)
  - return: principle entity
```

**elevate-to-pattern / elevate-to-principle / elevate-to-axiom:**
These promote an entity up one rung. Pattern:
```yaml
params: [source_id, name, domain, rationale]
steps:
  - find: source entity
  - assert: source exists
  - compose: new higher-level entity
  - bind: grounded-in bond from new → source
  - call: nous/index
  - call: logos/emit-phasis
  - return: new entity
```

**crystallize-axiom:**
```yaml
params: [name, statement, rationale, domain, grounded_in_principle_ids]
steps:
  - assert, compose, for_each bonds, index, announce, return
  - status defaults to "provisional"
```

**establish-axiom:**
```yaml
params: [axiom_id]
steps:
  - find: axiom
  - assert: axiom exists and status == "provisional"
  - update: status → "established"
  - call: logos/emit-phasis (announce establishment)
  - return: updated axiom
```

### Eidos field reference (from `genesis/nous/eide/nous.yaml`):

**axiom:** name, statement, rationale, domain, status (provisional|established)
**principle:** name, guidance, rationale, domain, status (provisional|established), grounded_in (array)
**pattern:** name, description, structure, when, example, domain, status (provisional|established), grounded_in (array)

## 2. Soma Visibility — Render-Specs for Infrastructure

**Problem:** Soma has no render-specs. The body is invisible through thyra.

### Actions

Create render-specs in `genesis/soma/render-specs/`:

**node-card.yaml:**
```yaml
entities:
  - eidos: render-spec
    id: render-spec/node-card
    data:
      name: node-card
      target_eidos: node
      variant: card
      layout:
        - widget: card
          props:
            variant: bordered
            padding: md
          children:
            - widget: stack
              props:
                gap: sm
              children:
                - widget: row
                  props:
                    justify: between
                    align: center
                  children:
                    - widget: text
                      props:
                        content: "{name}"
                        variant: emphasis
                    - widget: status-indicator
                      props:
                        status: "{status}"
                - widget: row
                  props:
                    gap: sm
                  children:
                    - widget: badge
                      props:
                        content: "{platform}"
                        variant: info
                    - widget: badge
                      when: "kind == 'commons'"
                      props:
                        content: "Commons"
                        variant: success
                    - widget: badge
                      when: "kind == 'personal'"
                      props:
                        content: "Personal"
                        variant: info
                - widget: text
                  when: "address"
                  props:
                    content: "{address}"
                    variant: caption
```

**service-instance-card.yaml:**
```yaml
entities:
  - eidos: render-spec
    id: render-spec/service-instance-card
    data:
      name: service-instance-card
      target_eidos: service-instance
      variant: card
      layout:
        - widget: card
          props:
            variant: bordered
            padding: md
          children:
            - widget: stack
              props:
                gap: sm
              children:
                - widget: row
                  props:
                    justify: between
                    align: center
                  children:
                    - widget: text
                      props:
                        content: "{name}"
                        variant: emphasis
                    - widget: status-indicator
                      props:
                        status: "{status}"
                - widget: badge
                  props:
                    content: "{service_kind}"
                    variant: info
                - widget: text
                  when: "endpoint"
                  props:
                    content: "{endpoint}"
                    variant: caption
                - widget: text
                  when: "error_message"
                  props:
                    content: "{error_message}"
                    variant: caption
```

**kosmos-instance-card.yaml** — similar pattern with name, status, version, server_url.

Also update `genesis/soma/manifest.yaml`:
- Add `render-specs/` to content_paths
- Add renderable entries for node, service-instance, kosmos-instance

## 3. Hodos Thyra Integration — Journey Navigation Panel

**Problem:** Hodos navigates journeys but has no thyra mode/panel for the UI surface.

### Actions

Create a journey navigation render-spec in `genesis/hodos/render-specs/` (create directory):

**journey-progress.yaml:**
```yaml
entities:
  - eidos: render-spec
    id: render-spec/journey-progress
    data:
      name: journey-progress
      target_eidos: journey
      variant: progress
      description: |
        Journey progress view showing current waypoint,
        step indicators, and navigation controls.
      layout:
        - widget: card
          props:
            variant: bordered
            padding: md
          children:
            - widget: stack
              props:
                gap: md
              children:
                - widget: text
                  props:
                    content: "{desire}"
                    variant: title
                - widget: steps
                  props:
                    current: "{current_waypoint}"
                    orientation: horizontal
                    items: "{waypoints}"
                - widget: divider
                - widget: text
                  props:
                    content: "{current_description}"
                    variant: body
                - widget: row
                  props:
                    justify: end
                    gap: sm
                  children:
                    - widget: button
                      when: "can_advance"
                      props:
                        label: "Continue"
                        variant: primary
                        on_click: hodos/advance-waypoint
                        on_click_params:
                          journey_id: "{id}"
```

Create `genesis/hodos/manifest.yaml` update to add render-specs path and renderable declaration.

## 4. Logos Thyra Panel — Phasis Feed

**Problem:** Logos defines the discourse layer but has no thyra panel/mode for displaying the phasis feed as a navigable surface.

### Actions

Check if `genesis/thyra/entities/layout.yaml` already defines a phasis panel. If not, add a panel entity:

```yaml
- eidos: panel
  id: panel/logos/phasis-feed
  data:
    name: phasis-feed
    description: |
      Live phasis feed showing discourse from all sources
      (human phaseis, topos announcements, reflex notifications).
    render_type: artifact
    config:
      typos_id: typos/phasis-feed-view
      watch_eidos: phasis
```

Also check if a typos for phasis-feed-view exists. If not, create it in `genesis/thyra/typos/` or note the gap.

Logos already has render-specs (phasis-bubble, phasis-thread, phasis-thread-item) — the panel just needs to compose them.

## 5. Manteia Example Criteria

**Problem:** Manteia's governed-envelope pattern uses evaluation criteria, but no example criteria entities exist.

### Actions

Create `genesis/manteia/entities/criteria.yaml`:

```yaml
entities:
  - eidos: criterion
    id: criterion/factual-accuracy
    data:
      name: factual-accuracy
      description: "Generated content must be factually consistent with provided context"
      weight: critical
      check_prompt: "Does the generated content contain any factual errors relative to the provided context?"

  - eidos: criterion
    id: criterion/schema-compliance
    data:
      name: schema-compliance
      description: "Generated content must conform to the target schema"
      weight: critical

  - eidos: criterion
    id: criterion/kosmos-vocabulary
    data:
      name: kosmos-vocabulary
      description: "Generated content must use V11 vocabulary (prosopon, parousia, oikos, topos, phasis)"
      weight: desired
      check_prompt: "Does the content use the correct Greek vocabulary? Check for legacy terms: persona, animus, circle, expression."

  - eidos: criterion
    id: criterion/gds-compliance
    data:
      name: gds-compliance
      description: "Generated templates must use only simple {{ variable }} substitution, no computation"
      weight: critical
      check_prompt: "Does the template contain any computational patterns like {{#each}}, {{#if}}, ternaries, or block conditionals?"

  - eidos: criterion
    id: criterion/conciseness
    data:
      name: conciseness
      description: "Generated content should be concise and focused"
      weight: advisory
```

Update `genesis/manteia/manifest.yaml` content_paths to include `entities/`.

## 6. Dokimasia Error Catalog

**Problem:** Dokimasia describes validation error codes in DESIGN.md but doesn't define them as entities.

### Actions

Create `genesis/dokimasia/entities/error-catalog.yaml` with error code definitions as entities. Use the codes from DESIGN.md:

**Provenance errors:** CHAIN_BROKEN, CYCLE_DETECTED, MAX_DEPTH_EXCEEDED, ENTITY_NOT_FOUND
**Schema errors:** EIDOS_NOT_FOUND, MISSING_FIELD, TYPE_MISMATCH, INVALID_ENUM, PARSE_ERROR
**Semantic errors:** UNRESOLVED_ENTITY, WRONG_EIDOS, UNRESOLVED_DESMOS, UNRESOLVED_PRAXIS

Each as an entity with code, layer, severity, human-readable description, and suggested fix.

## Verification Checklist

After all interventions:
- [ ] Nous has 7 new knowledge ladder praxeis matching attainment grants
- [ ] Soma has render-specs for node, service-instance, kosmos-instance + manifest updated
- [ ] Hodos has a journey-progress render-spec + manifest updated
- [ ] Logos has a thyra panel entity for phasis-feed
- [ ] Manteia has 5+ example criterion entities + manifest updated
- [ ] Dokimasia has error catalog entities + manifest updated
- [ ] All new files are valid YAML with correct `entities:` array format
