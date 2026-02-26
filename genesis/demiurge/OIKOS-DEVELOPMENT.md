# Topos Development Workflow

> **SUPERSEDED**: This document has been consolidated into [DESIGN.md](DESIGN.md) § The Generative Development Spiral.
> The canonical pattern is now documented there.

---

*The content below is preserved for reference but may be out of date.*

---

The canonical pattern for developing topoi in kosmos.

---

## The Compound Leverage Pattern

Each topos development compounds learning:

```
DESIGN.md (human intent)
    ↓ develop-topos-from-design
Design Artifact (structured spec)
    ↓ generate-eidos/praxis/desmos for each
Component Artifacts (definitions)
    ↓ actualize-*
Entities in Kosmos
    ↓ informed-by bonds
Provenance Graph (what shaped what)
    ↓ crystallize-theoria
Theoria (accumulated understanding)
    ↓ surfaces into future generations
Better Generations...
```

**The leverage**: Every successful topos development adds to the theoria corpus. Future generations are informed by past learnings. The more we use the pattern, the better it gets.

---

## Development Workflow

### Phase 1: Design (Human Intent)

Write a DESIGN.md that captures:

```markdown
# {Topos} Design

{Greek etymology} — meaning

## Ontological Purpose

{Topos} addresses **the gap between X and Y** — what becomes possible.

Without {topos}:
- Problem 1
- Problem 2

With {topos}:
- Capability 1
- Capability 2

## Oikos Context

### Self Oikos
How a solitary dweller uses this topos.

### Peer Oikos
How collaborators use this topos.

### Commons Oikos
How a community uses this topos.

## Core Entities (Eide)

### {eidos-name}
Purpose and fields.

## Bonds (Desmoi)

### {desmos-name}
From → To, meaning.

## Operations (Praxeis)

### {praxis-name}
- **When:** Trigger context
- **Requires:** Attainment
- **Provides:** Result

## Attainments

### attainment/{name}
Capability gating.

## Theoria

### T{N}: Insight title
Crystallized understanding.
```

### Phase 2: Generate Design Artifact

```bash
# From purpose/capabilities (AI generates design)
demiurge_develop-topos name="myoikos" \
  purpose="What gap this addresses" \
  capabilities='["cap1", "cap2"]'

# From DESIGN.md (human-written design)
demiurge_develop-topos-from-design \
  topos_name="myoikos" \
  design_content="$(cat genesis/myoikos/DESIGN.md)"
```

### Phase 3: Review Artifacts

The workflow generates artifacts for each component:

- `artifact/topos-{name}-design` — The parsed/generated design
- `artifact/eidos-{name}` — Each eidos definition
- `artifact/praxis-{topos}-{name}` — Each praxis definition
- `artifact/desmos-{name}` — Each desmos definition

Review these before actualization.

### Phase 4: Actualize

```bash
# Actualize all at once
demiurge_develop-topos ... actualize=true

# Or actualize individually
demiurge_actualize-eidos artifact_id="artifact/eidos-foo" topos_id="topos/myoikos"
demiurge_actualize-praxis artifact_id="artifact/praxis-myoikos-bar"
demiurge_actualize-desmos artifact_id="artifact/desmos-baz"
```

### Phase 5: Crystallize Theoria

When development reveals insights:

```bash
nous_crystallize-theoria \
  theoria_id="theoria/myoikos-insight" \
  insight="The pattern we discovered..." \
  domain="myoikos"
```

This theoria will surface in future generations via the `informed-by` bond.

---

## Praxeis Reference

### Generation (Tier 3 — requires inference)

| Praxis | Purpose |
|--------|---------|
| `demiurge/generate-eidos` | Generate complete eidos from purpose |
| `demiurge/generate-praxis` | Generate complete praxis from purpose |
| `demiurge/generate-desmos` | Generate complete desmos from purpose |
| `demiurge/generate-topos` | Generate topos design from purpose |

### Actualization (Tier 2 — kosmos ops)

| Praxis | Purpose |
|--------|---------|
| `demiurge/actualize-eidos` | Create eidos from artifact |
| `demiurge/actualize-praxis` | Create praxis from artifact |
| `demiurge/actualize-desmos` | Create desmos from artifact |

### Workflow (Tier 3 — orchestration)

| Praxis | Purpose |
|--------|---------|
| `demiurge/develop-topos` | Full workflow from purpose |
| `demiurge/develop-topos-from-design` | Full workflow from DESIGN.md |

---

## Provenance Tracking

Every generation creates `informed-by` bonds:

```
artifact/eidos-foo
  ├── informed-by → theoria/ontology-pattern-1
  ├── informed-by → theoria/field-design-best-practice
  └── composed-from → artifact/topos-myoikos-design
```

Query provenance to understand what shaped any entity:

```bash
nous_traverse root_id="eidos/foo" desmoi='["informed-by", "composed-from"]'
```

---

## Example: Developing a New Topos

### 1. Write DESIGN.md

```markdown
# Recipes Design

μαγειρική (mageirikí) — the culinary art

## Ontological Purpose

Recipes addresses **the gap between ingredients and meals** — structured cooking knowledge.

Without recipes:
- Cooking knowledge is prose
- Ingredient relationships unclear
- Scaling requires manual math

With recipes:
- Structured ingredient lists
- Step sequences
- Automatic scaling
- Dietary filtering

## Core Entities (Eide)

### recipe
A complete cooking procedure.

### ingredient
A component used in recipes.

## Bonds (Desmoi)

### has-ingredient
Recipe contains ingredient with quantity.

## Operations (Praxeis)

### create-recipe
Create a new recipe with ingredients and steps.

### scale-recipe
Scale ingredient quantities.

### filter-by-diet
Filter recipes by dietary requirements.
```

### 2. Generate and Actualize

```bash
demiurge_develop-topos-from-design \
  topos_name="recipes" \
  design_content="$(cat genesis/recipes/DESIGN.md)" \
  actualize=true
```

### 3. Crystallize Learning

```bash
nous_crystallize-theoria \
  theoria_id="theoria/recipes-scaling" \
  insight="Recipe scaling works by multiplying all ingredient quantities by a factor while preserving ratios. This is a general pattern for any entity with proportional relationships." \
  domain="recipes"
```

---

## Migration Path for Existing Topoi

Existing well-authored topoi (hodos, opsis, voice-authoring) don't need regeneration. Their value is proven.

For future development:
1. All new topoi use the workflow
2. Major changes to existing topoi go through generation
3. Theoria accumulates from all development

---

## Topos Patterns

The workflow handles different topos patterns found across kosmos:

### Pattern 1: Kinetics Topos (e.g., hodos)

Operates on entities from dependencies, defines no eide of its own.

```markdown
## Core Entities (Eide)

Hodos does not define its own eide. It operates on entities defined in nous:

### journey (from nous)
A teleological container.
```

**Handling**: Mark eide with `(from X)` in DESIGN.md. Parser sets `source: nous`. Workflow skips generation for external eide but tracks them in result.

### Pattern 2: Interface Topos (e.g., opsis)

Defines many eide for rendering/display. May use attainments from parent.

```markdown
## Attainments

### attainment/render (defined in thyra)
Rendering capability.
```

**Handling**: Mark attainments with `(defined in X)`. Parser sets `source: thyra`. Attainment not generated, only tracked.

### Pattern 3: Namespace Override (e.g., opsis praxeis in thyra)

Praxeis defined by topos but exposed under another namespace.

```markdown
## Operations (Praxeis)

*Praxeis remain in thyra namespace as parent.*

### gather-render-intent
...
```

**Handling**: Parser sets `namespace: thyra`. Praxis generated with that namespace.

### Pattern 4: Foundational Topos (e.g., nous)

Some eide defined at genesis/spora level, not in the topos.

```markdown
### theoria (defined in spora)
Crystallized understanding that persists.
```

**Handling**: Mark with `(defined in spora)`. Parser sets `source: spora`. Eidos not generated.

### Pattern 5: Mode Topos (e.g., voice-authoring)

Experiential mode with session tracking, layouts, specialized workflows.

- Defines session eidos for mode state
- Defines layout for visual arrangement
- Praxeis for mode lifecycle (enter, exit, pause, resume)

**Handling**: Standard generation. Session, layout, and lifecycle praxeis are all local.

---

## Output Structure

The develop-topos praxeis return structured results:

```yaml
topos_name: "myoikos"
design_artifact: { id: "artifact/topos-mytopos-design", ... }
design: { purpose: "...", eide: [...], praxeis: [...], ... }
artifacts:
  eide: [...]       # Generated eidos artifacts
  praxeis: [...]    # Generated praxis artifacts
  desmoi: [...]     # Generated desmos artifacts
external:
  eide: [...]       # External eide (from dependencies)
  desmoi: [...]     # External desmoi (from dependencies)
actualized: [...]   # Actualized entities (if actualize=true)
```

This enables downstream processing to:
- Review artifacts before actualization
- Understand dependency relationships
- Track what was generated vs what was used

The pattern is prospective — we don't rewrite history, we compound forward.

---

*Composed in service of the kosmogonia.*
*The pattern compounds. Knowledge accumulates. Development improves.*
