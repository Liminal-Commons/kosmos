# Demiurge Design

δημιουργός (dēmiourgós) — the craftsman, the public worker, the maker

## Ontological Purpose

Demiurge addresses **the gap between intention and creation** — the distance between wanting something to exist and it actually existing with proper form, provenance, and relationships.

Without demiurge:
- Entities arise without provenance tracking
- Artifacts are created ad-hoc without composition patterns
- There's no single interface for creation
- Dependencies between artifacts aren't tracked
- Oikos packages have no lifecycle

With demiurge:
- **One verb**: `compose` is the single interface for all creation
- **Provenance**: Every entity traces to its definition and authorization
- **Routing**: Definition shape determines composition mode (entity, graph, template)
- **Caching**: Content-addressed artifacts avoid redundant composition
- **Dependencies**: Artifact staleness propagates through the graph
- **Packaging**: Oikoi move from development through baking to publication

The compositor is simple. Complexity lives in the definition.

## Circle Context

### Self Circle

A solitary dweller uses demiurge to:
- Compose personal notes, insights, and theoria via definitions
- Build custom artifact definitions for their workflows
- Package personal oikoi for backup or sharing
- Fork generative-commons packages for local adaptation

Composition is the primary creation act — everything arises through compose.

### Peer Circle

Collaborators use demiurge to:
- Share artifact definitions that encode team patterns
- Compose artifacts with shared context (all trace to same circle)
- Build oikos-dev packages for team-specific extensions
- Publish signed oikos-prod packages for the team

The provenance chain shows who composed what and when.

### Commons Circle

A commons circle uses demiurge to:
- Define canonical composition patterns (typos definitions)
- Publish oikos-prod packages for broad distribution
- Maintain generative-commons packages others can fork and bake
- Emit genesis for verification and recovery

Distribution channels (politeia) receive packages from demiurge.

## Core Entities (Eide)

### typos

τύπος — the mold, the composition template.

**Fields:**
- `name` — Human-readable name
- `description` — What this definition composes
- `target_eidos` — For entity composition: the eidos to create
- `slots` — For graph composition: named slots to fill
- `template` — For template rendering: string with `{{ variable }}` placeholders
- `defaults` — Default values for slots/template variables
- `bonds` — Bond specifications to create during composition
- `output_type` — Format of output (text, object)

**Shape Routing:**
- Has `target_eidos` → entity composition (arise entity, bind provenance)
- Has `slots`, no `target_eidos` → graph composition (fill slots, render)
- Has `template` only → template rendering (interpolate variables)

**Lifecycle:**
- Arise: Composed via `typos-def-typos` or directly authored
- Change: Updated when composition patterns evolve
- Depart: Archived when no longer used (artifacts retain composed-from bond)

### artifact

A composed artifact — the result of graph or template composition.

**Fields:**
- `typos_id` — The definition used to compose this
- `content` — The composed content (text or object)
- `inputs` — The inputs used during composition
- `composed_at` — Timestamp of composition
- `cache_key` — Content-addressed key for caching
- `stale` — Whether the artifact needs recomposition

**Lifecycle:**
- Arise: Created through compose, compose-cached, or compose-indexed
- Change: Marked stale when dependencies change; refreshed via refresh-stale
- Depart: Archived or deleted when no longer needed

## Bonds (Desmoi)

### composed-from

Entity was composed from this typos definition.

- **From:** any entity
- **To:** typos
- **Cardinality:** many-to-one
- **Traversal:** From entity, find its definition; from definition, find all composed entities

### authorized-by

This composition was authorized by that expression/entity.

- **From:** any entity
- **To:** any entity
- **Cardinality:** many-to-one
- **Traversal:** Provenance chain terminating at genesis-root

### depends-on

Artifact depends on entity for cache invalidation.

- **From:** artifact (or any)
- **To:** any entity
- **Cardinality:** many-to-many
- **Traversal:** From artifact, find dependencies; from entity, find dependent artifacts

### packages

An oikos-dev packages a source oikos.

- **From:** oikos-dev
- **To:** oikos
- **Cardinality:** many-to-one
- **Traversal:** From dev package, find source oikos

### baked-from

An oikos-prod was baked from an oikos-dev.

- **From:** oikos-prod
- **To:** oikos-dev
- **Cardinality:** many-to-one
- **Traversal:** From production package, find development source

### published-by

An oikos-prod was published by an animus.

- **From:** oikos-prod
- **To:** animus
- **Cardinality:** many-to-one
- **Traversal:** From package, find publisher identity

### attests-to

A publish-attestation attests to an oikos-prod publication.

- **From:** publish-attestation
- **To:** oikos-prod
- **Cardinality:** many-to-one
- **Traversal:** From attestation, find attested package

### derives-from

An oikos-dev was forked from another oikos-dev.

- **From:** oikos-dev
- **To:** oikos-dev
- **Cardinality:** many-to-one
- **Traversal:** Fork lineage for generative-commons

### sources-content-from

Entity sources content from a content-root.

- **From:** any
- **To:** content-root
- **Cardinality:** many-to-many
- **Traversal:** Content provenance (bootstrap traces these to discover all content)

## Operations (Praxeis)

### Core Composition

#### compose

The single interface for all creation. Every composition:
- Creates entity with provenance (composed-from, authorized-by bonds)
- Indexes for semantic search (circle-scoped)
- Routes based on definition shape (entity, graph, or template mode)

- **When:** Any creation act
- **Requires:** compose attainment
- **Provides:** Entity with provenance, indexed for search

#### compose-cached

Content-addressed cached composition.

- **When:** Expensive compositions that may be repeated
- **Requires:** compose attainment
- **Provides:** Artifact from cache or fresh composition

#### check-cache

Query cache without composing.

- **When:** Checking if composition is needed
- **Requires:** compose attainment
- **Provides:** Cache hit/miss status

### Dependency Management

#### bind-dependencies / mark-dependents-stale / list-stale-artifacts / refresh-stale

Staleness propagation through artifact graph.

- **When:** Sources change, dependents need recomposition
- **Requires:** compose attainment
- **Provides:** Dependency tracking and batch refresh

### Generative Development Spiral

The canonical path for oikos development. See § The Generative Development Spiral below.

#### develop-oikos-from-design

Entry point: parse DESIGN.md and generate all artifacts.

- **When:** Developing a new oikos from human intent
- **Requires:** develop attainment
- **Provides:** Design artifact + generated component artifacts

#### generate-eidos / generate-praxis / generate-desmos / generate-oikos

Generate definitions using inference context composition.

Each generation:
1. Composes an inference context (typos-inference-*)
2. Surfaces relevant theoria
3. Calls manteia/governed-inference
4. Returns artifact ready for actualization

- **When:** Creating definitions with AI assistance
- **Requires:** develop attainment
- **Provides:** Artifact containing generated definition

#### actualize-eidos / actualize-praxis / actualize-desmos

Create real entities from generated artifacts.

- **When:** Artifact reviewed and approved
- **Requires:** develop attainment
- **Provides:** Entity in kosmos with provenance

### Validation

#### validate-oikos / validate-praxis

Check definitions before emission.

- **When:** Before emitting to genesis
- **Requires:** develop attainment
- **Provides:** Validation result with errors if any

### Discovery

#### discover-stoicheia / discover-typos / discover-desmoi

Explore the compositional palette.

- **When:** Understanding available building blocks
- **Requires:** develop attainment
- **Provides:** Available step types, templates, bond types

### Packaging

#### compose-oikos-dev

Package oikos from genesis source.

- **When:** Preparing for distribution
- **Requires:** package attainment
- **Provides:** oikos-dev entity with content

#### bake-oikos

Resolve generation specs to literals.

- **When:** Before publication
- **Requires:** package attainment
- **Provides:** Baked content ready for signing

#### publish-oikos

Sign and release oikos-prod.

- **When:** Distributing to other circles
- **Requires:** package attainment + signing capability
- **Provides:** Signed oikos-prod with attestation

#### verify-oikos

Verify package integrity.

- **When:** Receiving packages
- **Requires:** None (read-only)
- **Provides:** Validity status

### Emission

> **Note:** Emission operations have moved to the **genesis** oikos.
> See [genesis/DESIGN.md](../genesis/DESIGN.md) for emit-genesis, genesis/emit-oikos, and verify-full-circle.

## Attainments

Three attainments gate demiurge capabilities:

### attainment/compose

Core composition capability — the fundamental demiurge act.

- **Grants:** compose, compose-cached, check-cache, bind-dependencies, mark-dependents-stale, list-stale-artifacts, refresh-stale
- **Scope:** circle
- **Rationale:** Composition is the basic creation act; every entity arises through compose

### attainment/develop

Oikos development capability — the Generative Development Spiral.

- **Grants:** develop-oikos-from-design, generate-eidos, generate-praxis, generate-desmos, generate-oikos, actualize-eidos, actualize-praxis, actualize-desmos, validate-oikos, validate-praxis, discover-stoicheia, discover-typos, discover-desmoi
- **Scope:** circle
- **Rationale:** Definition generation uses inference and affects kosmos structure

### attainment/package

Oikos packaging and publishing capability.

- **Grants:** compose-oikos-dev, bake-oikos, publish-oikos, verify-oikos
- **Scope:** circle
- **Rationale:** Publishing affects other circles; requires signing authority

## Embodiment

### Completeness Status

| Level | Status |
|-------|--------|
| Defined | ✅ typos, artifact, 8 desmoi, 25 praxeis |
| Loaded | ✅ Bootstrap loads all definitions |
| Projected | ✅ All praxeis visible as MCP tools |
| Embodied | ⏳ Body-schema contribution pending |
| Surfaced | ⏳ Reconciler not yet implemented |
| Afforded | ⏳ Thyra composition affordances pending |

### Body-Schema Contribution

When sense-body gathers demiurge state:

```yaml
composition:
  available_definitions: 47    # typos entities
  cached_artifacts: 128        # artifacts with cache_key
  stale_artifacts: 3           # artifacts needing refresh

development:
  current_oikos: "oikos/recipes"
  pending_artifacts: 3         # Generated, not yet actualized
  actualized_definitions: 5
  validation_status: valid
  theoria_used: 4              # Theoria that informed generation

packaging:
  draft: 2
  ready_to_publish: 1
  published: 5
```

### Reconciler

A demiurge reconciler would surface:

- **Stale artifacts** — "3 artifacts need refresh after dependency changes"
- **Pending actualizations** — "3 generated artifacts await review and actualization"
- **Validation opportunities** — "oikos/recipes has 5 actualized definitions, ready for validation"
- **Emission readiness** — "oikos/recipes is valid and ready to emit"

## Compound Leverage

### amplifies politeia

Circle governance determines who can compose, publish, and fork. Distribution circles receive oikos-prod packages.

### amplifies hypostasis

Oikos publishing requires signing with circle-scoped keys. Publication attestations provide cryptographic provenance.

### amplifies nous

Theoria, inquiries, and journeys are all composed entities. Definition generation uses nous/invoke for inference.

### amplifies manteia

Baking oikos-dev packages routes through manteia for generation resolution. Schema constraints come from eidos definitions.

### amplifies dokimasia

emit-single-stream validates entities against schemas before emission. Full-circle verification proves kosmos coherence.

## Theoria

### T34: Composition is the single act of creation

Everything in the kosmos arises through compose. Raw arise is constitutional only. This simplifies reasoning: all creation has provenance, all provenance traces to genesis.

### T35: Definition shape determines behavior

No explicit "mode" parameter — the presence of target_eidos, slots, or template determines routing. Shape IS meaning. The compositor routes; definitions specify.

### T36: Artifact graphs enable smart invalidation

When a source changes, staleness propagates through depends-on bonds. This is lazy — artifacts stay stale until explicitly refreshed, allowing batched updates.

### T37: Generative-commons bridges creation and adaptation

By sharing generation specs rather than just baked content, circles enable local adaptation. Fork lineage through derives-from maintains attribution.

## The Generative Development Spiral

The canonical path for developing oikoi. This replaces manual composition with AI-assisted generation that accumulates learning.

### The Pattern

```
DESIGN.md (human intent)
    ↓ develop-oikos-from-design
Design Artifact (structured spec)
    ↓ generate-eidos/praxis/desmos for each
Component Artifacts (definitions)
    ↓ review
Human Approval
    ↓ actualize-*
Entities in Kosmos
    ↓ validate-oikos
Validated Definitions
    ↓ genesis/emit-oikos
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

### Inference Context Integration

Each generation step uses inference context composition from manteia:

```yaml
# generate-eidos internally:
- step: compose
  typos_id: typos-inference-eidos
  inputs:
    name: "$name"
    purpose: "$purpose"
    domain: "$domain"
  bind_to: inference_context

- step: surface
  query: "$domain ontology eidos"
  eidos: theoria
  limit: 5
  bind_to: theoria

- step: call
  praxis: manteia/governed-inference
  params:
    prompt: "$inference_context.request"
    system_prompt: "$inference_context.role"
    output_schema: "$inference_context.output_schema"
```

The inference context slots:
- `schema_source` — What output structure we want
- `domain_theoria` — Relevant crystallized understanding
- `role` — Persona for reasoning
- `constraints` — Guardrails on generation
- `request` — The actual instruction

See manteia DESIGN.md § Inference Context Composition for the full pattern.

### The Workflow

#### Step 1: Write DESIGN.md

Human writes a DESIGN.md capturing:
- Ontological purpose (what gap this addresses)
- Circle contexts (self, peer, commons usage)
- Eide (entity types)
- Desmoi (bond types)
- Praxeis (operations)
- Attainments (capability gates)

Template:

```markdown
# {Oikos} Design

{Greek etymology} — meaning

## Ontological Purpose

{Oikos} addresses **the gap between X and Y** — what becomes possible.

## Circle Context

### Self Circle / Peer Circle / Commons Circle
How each circle type uses this oikos.

## Core Entities (Eide)
### {eidos-name}
Purpose and fields.

## Bonds (Desmoi)
### {desmos-name}
From → To, meaning.

## Operations (Praxeis)
### {praxis-name}
When, requires, provides.

## Attainments
### attainment/{name}
Capability gating.
```

#### Step 2: Generate Design Artifact

```
develop-oikos-from-design(design_content: "...")
  → Parses DESIGN.md
  → Generates design artifact with structured spec
  → Returns: { design_artifact, eide_specs, praxeis_specs, desmoi_specs }
```

#### Step 3: Generate Components

```
generate-eidos(name, purpose, domain, field_hints)
  → Composes inference context
  → Surfaces domain theoria
  → Calls governed-inference
  → Returns: artifact containing eidos definition

generate-praxis(name, oikos, purpose, params)
  → Same pattern
  → Returns: artifact containing praxis definition

generate-desmos(name, purpose, from_eidos, to_eidos)
  → Same pattern
  → Returns: artifact containing desmos definition
```

#### Step 4: Review Artifacts

Human reviews generated artifacts. Each artifact contains:
- The generated definition
- Verdict (TRUE/FALSE/UNDECIDABLE)
- Guidance if issues
- Provenance (what theoria informed it)

#### Step 5: Actualize

```
actualize-eidos(artifact_id)
  → Creates real eidos entity
  → Bonds: composed-from → typos-def-eidos
  → Bonds: informed-by → [theoria used]
  → Bonds: contains ← oikos

actualize-praxis(artifact_id)
  → Same pattern

actualize-desmos(artifact_id)
  → Same pattern
```

#### Step 6: Validate and Emit

```
validate-oikos(oikos_id)
  → Checks all definitions resolve
  → Checks praxeis use valid stoicheia
  → Returns: { valid: true/false, errors: [...] }

genesis/emit-oikos(oikos_id)
  → Writes to genesis/{oikos}/
  → Creates manifest.yaml, eide/, praxeis/, desmoi/
```

#### Step 7: Crystallize Theoria

```
nous/crystallize-theoria(
  insight: "Field naming pattern X works well for...",
  domain: "ontology"
)
  → Theoria surfaces in future generations
```

### Direct Composition (No AI)

For cases where you know exactly what you want:

```yaml
compose(typos-def-eidos, {
  name: "recipe",
  description: "A cooking recipe with ingredients and steps",
  fields: { ... }
})
```

This bypasses generation but maintains provenance. Use when:
- Migrating existing definitions
- Simple, well-understood structures
- Testing

### Bonds

**informed-by** — Generation was informed by theoria
```yaml
desmos/informed-by:
  from_eidos: any
  to_eidos: theoria
  cardinality: many-to-many
```
Traces what shaped each generated definition.

**contains** — Oikos contains definition
```yaml
desmos/contains:
  from_eidos: oikos
  to_eidos: [eidos, praxis, desmos]
  cardinality: one-to-many
```
The package relationship.

### Body-Schema Contribution

```yaml
development:
  current_oikos: "oikos/recipes"
  pending_artifacts: 3        # Generated, not yet actualized
  actualized_definitions: 5   # Real entities
  validation_status: valid
  theoria_used: 4             # Theoria that informed generation

pending_actions:
  - action: actualize-eidos
    artifact_id: "artifact/eidos-recipe"
    reason: "Generated and approved"
  - action: genesis/emit-oikos
    reason: "All definitions valid"
```

---

## Interaction Surface Palette

When developing an oikos, you're not just defining structure — you're choosing which **interaction surfaces** to engage to make your domain "come alive" within kosmos.

### The Surfaces

| Surface | What It Provides | Interface Oikos | Integration Pattern |
|---------|------------------|-----------------|---------------------|
| **Rendering** | Visual presence | opsis | eidos → render-type → renderer |
| **Reasoning** | Intelligence | manteia | prompt + context → governed-inference → yield |
| **Understanding** | Knowledge crystallization | nous | insight → theoria → surfaceable |
| **Computation** | Sandboxed execution | ergon/WASM | entity → manifest → execution |
| **Transport** | Cross-boundary flow | aither | syndesmos → presence → sync |
| **Coordination** | Cross-circle work | ergon | gap → pragma → signals-to → resolution |
| **Emission** | Filesystem persistence | thyra | entity → emit → chora |

### Oikos Categories

Oikoi fall into three categories based on their relationship to these surfaces:

| Category | Character | Examples |
|----------|-----------|----------|
| **Interface** | Provide access to substrate capabilities | manteia, opsis, aither, thyra |
| **Domain** | Model specific concerns | nous, politeia, psyche |
| **Infrastructure** | Manage substrate resources | dynamis, ergon, soma |

An oikos developer should ask: "Which interaction surfaces does my domain need?"

### Example: Recipe Oikos

| Surface | How Used |
|---------|----------|
| Rendering | Recipe cards, ingredient lists, step-by-step views |
| Reasoning | "Suggest recipes from these ingredients" via manteia |
| Understanding | Cooking techniques crystallize as theoria |
| Computation | Nutrition calculation via WASM |
| Transport | Recipes sync across family circle |

### Example: Code Review Oikos

| Surface | How Used |
|---------|----------|
| Rendering | Diff views, comment threads, approval badges |
| Reasoning | Pattern analysis, suggestions via manteia |
| Understanding | Review patterns crystallize as theoria |
| Coordination | Review requests as pragma to dev circle |
| Transport | Reviews sync across team circles |

### Surface Integration Patterns

Each surface has a composition pattern — how your oikos connects to it:

**Rendering integration:**
```yaml
# Define or reference render-types for your eide
- eidos: render-type
  id: render-type/recipes/recipe-card
  data:
    for_eidos: recipes/recipe
    renderer: renderer/recipes/card
```

**Reasoning integration:**
```yaml
# In your praxis, call manteia with domain context
- step: call
  praxis: manteia/governed-inference
  params:
    prompt: "Suggest recipes using: $ingredients"
    context:
      theoria_domain: "cooking"
    output_schema: { ... }
```

**Understanding integration:**
```yaml
# Crystallize domain insights as theoria
- step: call
  praxis: nous/crystallize-theoria
  params:
    insight: "When searing meat, always preheat the pan"
    domain: "cooking-techniques"
```

### Attainments as Surface Access

Attainments gate which surfaces an oikos can leverage:

| Surface | Required Attainment |
|---------|---------------------|
| Rendering | attainment/render (opsis) |
| Reasoning | attainment/manteia (manteia) |
| Understanding | attainment/crystallize (nous) |
| Computation | attainment/execute (ergon) |
| Transport | attainment/sync (aither) |
| Coordination | attainment/signal (ergon) |

When composing an oikos, declaring `depends_on: [manteia]` signals you'll use reasoning integration.

---

## Compositional Palette

The building blocks for developing an oikos are discovered via the graph itself — the palette IS the kosmos:

### Stoicheia Discovery

```
gather(eidos: "stoicheion") → all step types
```

Each stoicheion has:
- `tier` — dynamis requirement (0-3)
- `fields` — parameter schema
- `description` — usage guidance

**Tier Summary:**

| Tier | Dynamis | Available Stoicheia |
|------|---------|---------------------|
| 0 | None | set, return, assert |
| 1 | None | gather, trace, surface, filter, map, reduce, sort, limit |
| 2 | Kosmos | find, update, bind, loose, compose, switch, for_each, try, append |
| 3 | Chora | embed, manifest, signal, emit, invoke |
| internal | — | arise, infer (use compose/governed-inference instead) |

### Typos Discovery

```
gather(eidos: "typos") → all composition templates
```

Each typos has:
- `target_eidos` — what entity type it creates
- `defaults` — default field values
- `bonds` — automatic bonds to create

**Typos Categories:**
- **Constitutional** — typos-def-eidos, typos-def-praxis, typos-def-desmos, typos-def-oikos
- **Domain** — typos-def-theoria, typos-def-journey, typos-def-circle, etc.

### Desmoi Discovery

```
gather(eidos: "desmos") → all bond types
```

Each desmos has:
- `from_eidos`, `to_eidos` — what can be connected
- `cardinality` — relationship constraints
- `description` — semantic meaning

### Dynamis Inference

When you compose a praxis, the stoicheia used determine dynamis requirements:

```
praxis uses emit (tier 3) → oikos requires_dynamis: [chora.emit]
praxis uses compose (tier 2) → oikos requires_dynamis: [kosmos]
praxis uses only set, return (tier 0) → portable, no dynamis needed
```

The `validate-oikos` operation infers these requirements and warns on mismatches.

### Anti-Pattern Detection

Certain patterns violate KOSMOGONIA principles:

| Anti-Pattern | Issue | Correct Pattern |
|--------------|-------|-----------------|
| Raw `arise` | No provenance | Use `compose` with typos |
| Raw `infer` | Ungoverned inference | Use `call manteia/governed-inference` |
| Missing depends_on | Silent failures | Declare oikos dependencies explicitly |

Validation surfaces these during development.

---

## Future Extensions

### Meta-Pattern Completeness

The oikos development experience currently reaches the **Loaded** level of the completeness ladder. Full completion requires:

| Level | Current | Future Work |
|-------|---------|-------------|
| **Defined** | ✓ | — |
| **Loaded** | ✓ | — |
| **Projected** | ✗ | `project-oikos` — temporarily project praxeis as MCP tools without emission |
| **Embodied** | ✗ | Development context in body-schema via sense-body gathering |
| **Surfaced** | ✗ | Development reconciler surfaces validation/emit opportunities |
| **Afforded** | ✗ | Thyra `oikos-view` render-type with contextual actions |

**project-oikos** would enable testing praxeis during development without emitting to genesis:
```
project-oikos(oikos_id: "oikos/recipes")
  → praxis/recipes/create becomes testable MCP tool
  → changes don't persist to genesis
  → teardown removes projection
```

**Development reconciler** would surface opportunities on-dwell:
```yaml
# Reconciler output
pending_actions:
  - action: validate-oikos
    oikos_id: "oikos/recipes"
    reason: "Has 3 eide, 2 praxeis — ready for validation"
  - action: genesis/emit-oikos
    oikos_id: "oikos/recipes"
    reason: "Validated and ready"
```

**Body-schema contribution** would show development state:
```yaml
development:
  active_oikoi:
    - id: "oikos/recipes"
      status: composing
      eide_count: 3
      praxeis_count: 2
  available_surfaces:
    rendering: available
    reasoning: available
    computation: requires_wasm
```

### Automatic Invalidation Hooks

Currently manual: call mark-dependents-stale when sources change. Future: trigger invalidation automatically on entity update.

### Composition Metrics

Track composition frequency, cache hit rates, staleness duration. Surface in body-schema for capacity planning.

### Cross-Circle Composition

Current: composition happens in dwelling circle context. Future: compose-for-circle allowing authorized composition into another circle's graph.

### Streaming Composition

Current: compose returns complete result. Future: compose-stream for large artifacts with progress reporting.

### Hot Registration

Currently, emitted oikoi require restart to bootstrap. Future: dynamic schema registry that recognizes newly composed eide/praxeis without restart.

### Theoria Integration

Auto-surface design patterns during oikos development via nous. When composing praxeis, relevant theoria about stoicheia usage would surface contextually.

### Oikos Templates

Start from oikos templates (e.g., "CRUD oikos", "integration oikos") that provide common scaffolding.

---

*Composed in service of the kosmogonia.*
*The demiurge makes. The definition specifies. The provenance traces.*
