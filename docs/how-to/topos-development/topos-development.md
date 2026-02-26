# Topos Development Guide

*How to build domain packages for the kosmos.*

---

## What is a Topos?

A **topos** — is a dwelling place for capability. It is both:

- **Dwelling**: A place where capability lives and where context forms
- **Package**: A distributable unit with manifest, definitions, and praxeis

Topoi declare what dynamis (power) they require. The substrate provides or refuses.

From KOSMOGONIA:
> At the topos scale, capability has a home.

---

## Part 1: The Topos Completeness Ladder

A topos progresses through levels of "aliveness" — this is the **metapattern** for topos development:

| Level | What It Means | Implementation |
|-------|---------------|----------------|
| **Defined** | Eide, desmoi, praxeis exist in YAML | Create files in `genesis/{topos}/` |
| **Loaded** | Bootstrap loads into kosmos.db | Bootstrap validates and loads |
| **Projected** | MCP projects praxeis as tools | Praxeis with `visible: true` become tools |
| **Embodied** | Body-schema reflects capabilities | sense-body aggregates topos state |
| **Surfaced** | Reconciler notices when actions are relevant | Reconciler surfaces pending actions |
| **Afforded** | Thyra UI presents contextual actions | render-specs enable affordance buttons |

A topos is *complete* when usage flows naturally from context.

### Current State

All 20 topoi in kosmos have achieved **Loaded** level. Progression to higher levels requires chora implementation (see [CHORA-HANDOFF-TOPOS-DEV.md](../../implementation/CHORA-HANDOFF-TOPOS-DEV.md)).

---

## Part 2: The Generative Development Spiral

The canonical path for topos development. This replaces manual composition with AI-assisted generation that accumulates learning.

```
DESIGN.md (human intent)
    ↓ develop-topos-from-design
Design Artifact (structured spec)
    ↓ generate-eidos/praxis/desmos for each
Component Artifacts (definitions)
    ↓ review
Human Approval
    ↓ actualize-*
Entities in Kosmos
    ↓ validate-topos
Validated Definitions
    ↓ genesis/emit-topos
Genesis Filesystem
    ↓ crystallize-theoria
Theoria (accumulated understanding)
    ↓ surfaces into future generations
Better Generations...
```

### Why This Pattern

1. **Intent is explicit** — DESIGN.md captures human reasoning
2. **Generation is informed** — Theoria surfaces into inference context
3. **Review is possible** — Artifacts exist before actualization
4. **Provenance is complete** — Every entity traces to what informed it
5. **Learning accumulates** — Insights crystallize for future use

---

## Part 3: Topos Structure

A topos lives in `genesis/{topos-name}/` with this structure:

```
genesis/{topos}/
├── DESIGN.md           # Design document (required)
├── manifest.yaml       # Topos manifest v2.1 (required)
├── eide/
│   └── {topos}.yaml    # Entity definitions + attainments
├── desmoi/
│   └── {topos}.yaml    # Bond definitions
├── praxeis/
│   └── {topos}.yaml    # Operations
├── entities/
│   └── *.yaml          # Concrete entities (render-specs, reflexes, etc.)
└── render-specs/       # Declarative rendering templates
    └── *.yaml
```

### Manifest v2.1 Format

```yaml
format_version: "2.1"
topos_id: {name}
version: "0.1.0"

topos_name: {Name}
topos_description: |
  What this topos does.
topos_scale: {cross-scale | klimax-scale}

# Development metadata
topos_category: {domain | interface | infrastructure}
surfaces_provided:
  - {understanding | rendering | reasoning | ...}
surfaces_consumed:
  - {reasoning | ...}

content_paths:
  - path: eide/
    content_types: [eidos]
  - path: desmoi/
    content_types: [desmos]
  - path: praxeis/
    content_types: [praxis]
  - path: entities/
    content_types: [render-spec, reflex]

requires_dynamis:
  - db.find
  - db.bind
  # ... stoicheia requirements

provides:
  eide:
    - {eidos-name}
  desmoi:
    - {desmos-name}
  attainments:
    - {attainment-name}
  praxeis:
    - {topos}/{praxis-name}
  renderable:
    - eidos: {eidos-name}
      description: "..."

depends_on:
  - {other-topos}
```

---

## Part 4: The DESIGN.md Template

Every topos should have a DESIGN.md following this structure:

```markdown
# {Topos} Design

{Greek} ({transliteration}) — {meaning}

## Ontological Purpose

What gap in being does this topos address?
What becomes possible that wasn't before?

## Oikos Context

### Self Oikos
How does a solitary dweller use this?

### Peer Oikos
How do collaborators use this together?

### Commons Oikos
How does this serve a community?

## Core Entities (Eide)

### {eidos-name}
- Purpose
- Fields and their meaning
- Lifecycle (how instances arise, change, depart)

## Bonds (Desmoi)

### {desmos-name}
- from/to eidos
- Cardinality
- Traversal semantics

## Operations (Praxeis)

### {praxis-name}
- What it does
- When to use it
- What it requires (attainments, context)

## Attainments

### attainment/{name}
- What capability it grants
- Which praxeis it gates
- Scope (oikos, soma, parousia)

## Embodiment

### Completeness Status
| Level | Status |
|-------|--------|
| Defined | |
| Loaded | |
| Projected | |
| Embodied | |
| Surfaced | |
| Afforded | |

### Body-Schema Contribution
What does sense-body reveal about this topos?

### Reconciler
What opportunities does this topos surface?

## Compound Leverage

How does this topos amplify other topoi?
What cross-topos patterns emerge?

## Theoria

New theoria crystallized during this design.

## Future Extensions

What's not in scope now but could be later?
```

---

## Part 5: Defining Eide

Eide are entity type definitions. They live in `eide/{topos}.yaml` using the `entities:` format.

```yaml
entities:

- eidos: eidos
  id: eidos/{name}
  data:
    name: {name}
    description: |
      What this entity type represents.
    fields:
      field_name:
        type: {string | integer | boolean | enum | array | object | timestamp}
        required: {true | false}
        default: {value}
        description: "What this field means"
      enum_field:
        type: enum
        values: [option1, option2, option3]
        required: true

# Attainments are also eide (defined in same file)
- eidos: attainment
  id: attainment/{name}
  data:
    name: {name}
    description: |
      What capability this attainment grants.
    topos: {topos-name}
    scope: {oikos | soma | parousia}
    grants:
      - praxis/{topos}/{praxis-name}
```

### Field Types

| Type | Rust Equivalent | Notes |
|------|-----------------|-------|
| `string` | `String` | Text content |
| `integer` | `i64` | Whole numbers |
| `boolean` | `bool` | True/false |
| `enum` | `enum` | Fixed set of values |
| `array` | `Vec<T>` | List of items |
| `object` | `serde_json::Value` | Arbitrary JSON |
| `timestamp` | `i64` | Unix timestamp |

---

## Part 6: Defining Desmoi

Desmoi are bond type definitions. They live in `desmoi/{topos}.yaml`.

```yaml
entities:

- eidos: desmos
  id: desmos/{name}
  data:
    name: {name}
    description: |
      What relationship this bond represents.
    from_eidos:
      - {source-eidos}
    to_eidos:
      - {target-eidos}
    cardinality: {one-to-one | one-to-many | many-to-one | many-to-many}
    symmetric: {true | false}
    data_fields:
      field_name:
        type: string
        description: "Bond data"
```

### Cardinality Semantics

| Cardinality | Meaning | Example |
|-------------|---------|---------|
| `one-to-one` | Single bidirectional link | prosopon ↔ parousia |
| `one-to-many` | Parent to children | oikos → members |
| `many-to-one` | Children to parent | phaseis → stream |
| `many-to-many` | Arbitrary connections | theoria ↔ theoria |

### Common Bond Patterns

- **contains** — Composition (topos contains eidos)
- **authored-by** — Provenance (phasis authored-by parousia)
- **composed-from** — Definition trace (entity composed-from typos)
- **crystallized-in** — Location (theoria crystallized-in oikos)

---

## Part 7: Authoring Praxeis

Praxeis are operations composed of steps. Each step invokes a stoicheion.

```yaml
entities:

- eidos: praxis
  id: praxis/{topos}/{name}
  data:
    topos: {topos}
    name: {name}
    visible: true                    # Expose as MCP tool?
    tier: 2                          # Dynamis tier (0-3)
    description: |
      What this praxis does.
    params:
      - name: param_name
        type: string
        required: true
        description: "..."
    steps:
      - step: assert
        condition: "$param_name"
        message: "param_name required"

      - step: find
        id: "entity/$param_name"
        bind_to: entity

      - step: compose
        typos_id: typos-def-thing
        inputs:
          id: "result/$param_name"
          field: "$entity.data.field"
        bind_to: result

      - step: return
        value: "$result"
```

### Stoicheion Tiers

| Tier | Dynamis | Stoicheia |
|------|---------|-----------|
| 0 | None | `set`, `return`, `assert` |
| 1 | None | `gather`, `filter`, `map`, `reduce`, `sort`, `limit`, `for_each` |
| 2 | Kosmos | `find`, `update`, `bind`, `loose`, `compose`, `switch`, `try`, `trace`, `traverse` |
| 3 | Chora | `manifest`, `emit`, `infer`, `signal`, `embed`, `invoke` |
| internal | — | `arise`, `infer` (use compose/governed-inference instead) |

### Common Step Patterns

**Assertion:**
```yaml
- step: assert
  condition: "$param"
  message: "param is required"
```

**Entity lookup:**
```yaml
- step: find
  id: "$entity_id"
  bind_to: entity
```

**Entity creation:**
```yaml
- step: compose
  typos_id: typos-def-theoria
  inputs:
    id: "theoria/$insight"
    insight: "$insight"
    domain: "$domain"
  bind_to: theoria
```

**Bond creation:**
```yaml
- step: bind
  from_id: "$entity.id"
  to_id: "$target.id"
  desmos: crystallized-in
```

**Traversal:**
```yaml
- step: trace
  from_id: "$entity.id"
  desmos: contains
  resolve: to
  bind_to: children
```

**Conditional:**
```yaml
- step: switch
  cases:
    - when: '$status == "valid"'
      then:
        - step: emit
          entity_id: "$entity.id"
```

---

## Part 8: Attainments and Governance

Attainments gate capability. They are derived from oikos membership (politeia), not directly assigned.

### Defining Attainments

```yaml
- eidos: attainment
  id: attainment/{name}
  data:
    name: {name}
    description: |
      What this capability allows.
    topos: {topos}
    scope: {oikos | soma | parousia}
    grants:
      - praxis/{topos}/{praxis1}
      - praxis/{topos}/{praxis2}
```

### Scope Meanings

| Scope | Context | Example |
|-------|---------|---------|
| `oikos` | Capability within a specific oikos | govern, crystallize |
| `soma` | Capability for an embodied parousia | render, emit |
| `parousia` | Personal capability | navigate, perceive |

### Theoria: T25

> Attainments are derived, not assigned.

You receive attainments by joining oikoi that grant them. The bond graph IS the access control graph.

---

## Part 9: Rendering Integration

Each topos owns the rendering for its eide. Render-specs live in `render-specs/` or `entities/`.

### Declaring Renderable Eide

In manifest.yaml:
```yaml
provides:
  renderable:
    - eidos: theoria
      description: "Crystallized understanding cards"
```

### Defining Render-Specs

Render-specs define widget trees using the generic widget vocabulary:

```yaml
entities:

- eidos: render-spec
  id: render-spec/{eidos}-card
  data:
    name: {eidos}-card
    target_eidos: {eidos}
    variant: card

    layout:
      - widget: card
        props:
          variant: bordered
          padding: sm
        children:
          - widget: heading
            props:
              content: "{title}"
          - widget: text
            props:
              content: "{content}"
          - widget: badge
            props:
              content: "{domain}"
```

### Widget Vocabulary

Render-specs use the widget vocabulary defined in `genesis/thyra/eide/widget.yaml`:

- `card` — Content card container
- `text` — Text content
- `heading` — Headers (h1-h6)
- `badge` — Status labels
- `button` — Interactive buttons
- `icon` — Icons (Lucide names)
- `stack` — Vertical layout
- `row` — Horizontal layout
- `scroll` — Scrollable container
- `form` — Form context (captures input values at action time)
- `artifact` — Composed content via demiurge

---

## Part 10: Interaction Surface Palette

When developing a topos, choose which **interaction surfaces** to engage:

| Surface | What It Provides | Interface Topos | Integration Pattern |
|---------|------------------|-----------------|---------------------|
| **Rendering** | Visual presence | thyra | eidos → render-spec → mode |
| **Reasoning** | Intelligence | manteia | prompt + context → governed-inference |
| **Understanding** | Knowledge crystallization | nous | insight → theoria → surfaceable |
| **Computation** | Sandboxed execution | ergon/WASM | entity → manifest → execution |
| **Transport** | Cross-boundary flow | aither | syndesmos → presence → sync |
| **Coordination** | Cross-oikos work | ergon | gap → pragma → signals-to → resolution |
| **Emission** | Filesystem persistence | thyra | entity → emit → chora |

### Topos Categories

| Category | Character | Examples |
|----------|-----------|----------|
| **Interface** | Provide access to substrate | manteia, aither, thyra |
| **Domain** | Model specific concerns | nous, politeia, psyche |
| **Infrastructure** | Manage substrate resources | dynamis, ergon, soma |

---

## Part 11: Packaging and Distribution

### Development Workflow

1. **compose-topos-dev** — Package topos from genesis source
2. **validate-topos** — Check definitions before emission
3. **bake-topos** — Resolve generation specs to literals
4. **publish-topos** — Sign and release topos-prod

### Federation Sync

Topoi distribute via the **federation model** (politeia):
- Same mechanism for phaseis, theoria, and topoi
- Continuous sync enables time-sensitive execution
- Oikos sovereignty determines what flows where

---

## Part 12: Example Walkthrough

### Building a "recipes" Topos

**Step 1: Create DESIGN.md**

```markdown
# Recipes Design

μαγειρική (mageirike) — the art of cooking

## Ontological Purpose

Recipes addresses the gap between having ingredients and knowing
what to cook — making culinary knowledge actionable.

## Core Entities

### recipe
- title, ingredients, steps, prep_time, difficulty

### ingredient
- name, amount, unit, optional
```

**Step 2: Create manifest.yaml**

```yaml
format_version: "2.1"
topos_id: recipes
version: "0.1.0"
topos_name: Recipes
topos_category: domain
surfaces_provided: []
surfaces_consumed:
  - reasoning

content_paths:
  - path: eide/
    content_types: [eidos]
  - path: praxeis/
    content_types: [praxis]

provides:
  eide:
    - recipe
    - ingredient
  attainments:
    - cook
  praxeis:
    - recipes/create-recipe
    - recipes/suggest-meal
```

**Step 3: Define eide**

```yaml
# eide/recipes.yaml
entities:

- eidos: eidos
  id: eidos/recipe
  data:
    name: recipe
    description: A cooking recipe with ingredients and steps
    fields:
      title:
        type: string
        required: true
      ingredients:
        type: array
        required: true
      steps:
        type: array
        required: true
      prep_time:
        type: integer
        description: "Minutes"
      difficulty:
        type: enum
        values: [easy, medium, hard]

- eidos: attainment
  id: attainment/cook
  data:
    name: cook
    topos: recipes
    scope: oikos
    grants:
      - praxis/recipes/create-recipe
      - praxis/recipes/suggest-meal
```

**Step 4: Define praxeis**

```yaml
# praxeis/recipes.yaml
entities:

- eidos: praxis
  id: praxis/recipes/create-recipe
  data:
    topos: recipes
    name: create-recipe
    visible: true
    tier: 2
    description: Create a new recipe
    params:
      - name: title
        type: string
        required: true
      - name: ingredients
        type: array
        required: true
      - name: steps
        type: array
        required: true
    steps:
      - step: compose
        typos_id: typos-def-recipe
        inputs:
          id: "recipe/$title"
          title: "$title"
          ingredients: "$ingredients"
          steps: "$steps"
        bind_to: recipe
      - step: return
        value: "$recipe"
```

**Step 5: Bootstrap and test**

```bash
just dev

# Test via MCP
recipes_create-recipe title="Pasta" ingredients="[...]" steps="[...]"
```

---

## Appendix A: Anti-Patterns to Avoid

| Anti-Pattern | Issue | Correct Pattern |
|--------------|-------|-----------------|
| Raw `arise` | No provenance | Use `compose` with typos |
| Raw `infer` | Ungoverned inference | Use `call manteia/governed-inference` |
| `each` step | Wrong name | Use `for_each` |
| `sense` step | Wrong name | Use `sense_actuality` |
| Missing depends_on | Silent failures | Declare topos dependencies |
| `id:` in manifest | Wrong key | Use `entity_id:` |

---

## Appendix B: Theoria Reference

70 theoria (T18-T87) have been crystallized across all topoi. See [genesis/nous/theoria/INDEX.md](genesis/nous/theoria/INDEX.md) for the complete index.

Key theoria for topos development:

| ID | Statement |
|----|-----------|
| T18 | Topos embodiment requires body-schema contribution |
| T19 | Reconcilers surface opportunities, not just drift |
| T20 | Attainments make capabilities discoverable |
| T34 | Composition is the single act of creation |
| T35 | Definition shape determines behavior |

---

## Appendix C: Key Documents

| Document | Purpose |
|----------|---------|
| [KOSMOGONIA.md](genesis/KOSMOGONIA.md) | Constitutional root — ontology and principles |
| [ARCHITECTURE.md](ARCHITECTURE.md) | Technical implementation |
| [COMPOSITION-GUIDE.md](COMPOSITION-GUIDE.md) | Artifact composition patterns |
| [genesis/OIKOS-MAP.md](genesis/OIKOS-MAP.md) | Map of all 20 topoi |
| [genesis/nous/theoria/INDEX.md](genesis/nous/theoria/INDEX.md) | Theoria cross-reference |

---

*Composed in service of the kosmogonia.*
