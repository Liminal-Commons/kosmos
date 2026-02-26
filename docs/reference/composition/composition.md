# COMPOSITION-GUIDE.md

How to compose artifacts in kosmos. The complete guide for agents. For template syntax and field schema, see [Typos Reference](typos-composition.md).

---

## The One Thing

**Composition is explicit content assembly.**

A typos declares exactly what content blocks exist. Each slot either:
- **IS** content (literal)
- **REFERENCES** an entity (queried)
- **COMPOSES** another artifact (composed)
- **GENERATES** meaning (generated)

There is no iteration. No dynamic discovery. When you want a new block, you add a slot.

---

## The Arise Contract

Nothing arises raw. Every entity — whether created during bootstrap or at runtime — goes through `compose_entity()`, which enforces the full arise contract:

### Contextual Gate

Every arise requires context. No exceptions.

| Context | What It Provides | Bootstrap Source |
|---------|------------------|------------------|
| **Prosopon** (who) | Identity creating the entity | `genesis_root.expressed_by` |
| **Oikos** (where) | Dwelling context | Primordial oikos (created in stage 3) |
| **Session** (when) | Temporal context | Germination session |
| **Attainment** (by what right) | Authorization | Genesis root Ed25519 signature |

The method signature for creating entities requires this context. There is no public `arise_entity(eidos, id, data)` — the low-level database insert is internal to the composition path.

### Composition Obligations

When an entity arises, the composition path guarantees:

1. **Dokimasia validation** — entity data checked against eidos field definitions
2. **Content-hash idempotency** — same data = same hash = no redundant write
3. **`composed-from` bond** — provenance to the definition that produced it
4. **`typed-by` bond** — structural link to the entity's eidos
5. **`exists-in` bond** — dwelling placement (to oikos from dwelling context). This bond is the **complete dwelling index**: the set of entities reachable via `exists-in` from an oikos IS that oikos's content. Emission scope, visibility scope, and federation scope all derive from this bond.
6. **`authorized-by` bond** — chain to the authorizing phasis
7. **`depends-on` bonds** — composition dependency DAG for cache invalidation
8. **Change notification** — reflexes can respond

### No Raw Arise

These are violations of the arise contract:

```
ctx.arise_entity("theoria", id, data)        // No context, no provenance
ctx.arise_entity("session", id, data)         // No context, no provenance
arise_with_mode(ctx, eidos, id, data)         // Dispatch scaffolding, bypasses contract
```

The correct path is always through composition with context:

```
compose_entity(ctx, definition, inputs, context)  // Full contract
```

Genesis provenance is graph-traversable — never embedded as `_genesis` metadata in entity data. If it's structural, it's a bond.

---

## Typos Routing Modes

The demiurge routes composition based on definition shape. All composition produces entities, but the routing determines what kind:

| Mode | Definition Shape | Result |
|------|-----------------|--------|
| **Entity composition** | Has `target_eidos` | Domain entity (theoria, oikos, etc.) |
| **Graph composition** | Has `slots`, no `target_eidos` | Artifact entity with structured content |
| **Template rendering** | Has `template` only | Artifact entity with rendered content |

**Entity composition** creates domain entities — the "atomics" of each topos. Use `typos-def-*` naming.

**Graph/Template composition** creates content artifacts — views, documents, rendered output. These can query and compose domain entities without being domain entities themselves.

Example naming convention:
- `typos-def-theoria` → creates a theoria entity
- `typos-view-theoria-card` → creates an artifact containing a rendered view of a theoria

---

## Fill Patterns

| Pattern | What It Does | When to Use |
|---------|--------------|-------------|
| `literal` | Value is in the definition | Templates, constants, headers |
| `literal` (praxis-updatable) | Value from `_composition_inputs.inputs` | Mutable buffers updated by multiple sources |
| `queried` | Fetch entity from graph | Get data for composition/generation |
| `composed` | Invoke child typos | Structural parts of output |
| `generated` | LLM inference via manteia | Descriptions, doc comments, usage examples |

### Literal Fill via Praxis (Mutable Composition)

A literal slot can serve as a **praxis-updatable buffer**. When the slot has a `default` but no `value`, the actual value comes from `_composition_inputs.inputs.<slot_name>` at compose time:

```yaml
slots:
  content:
    fill: literal
    default: ""
template: "{{ content }}"
```

Multiple sources can update the literal input via praxeis, each following the same pattern:
1. Read/transform content as needed
2. Update `_composition_inputs.inputs.content` on the entity
3. Invoke `demiurge/compose` with `entity_id` (re-compose path reads stored inputs)
4. Composition produces updated `entity.data.content`

This preserves composition's one-way deterministic nature while allowing mutable content from multiple sources. The canonical example is the accumulation entity, where voice transcription, manual editing, and LLM clarification all update the same literal input.

### Queried Slot Variants

The `queried` pattern has two forms:

**String query** — resolves via graph query (`gather`, `find`):
```yaml
transcript_entities:
  fill: queried
  query: "gather(eidos: phasis, sort: expressed_at, order: asc)"
```

**Bond-based query** — resolves by tracing bonds from the entity being composed:
```yaml
transcript:
  fill: queried
  query:
    bond: fed-by-transcriber    # desmos name to trace
    field: transcript            # field to read from bonded entity
  default: ""                    # fallback when no bond or field is empty
```

Bond-based queries are the composition equivalent of `@bond-name` in render-specs — they read data through the bond graph. They also create `depends-on` bonds, enabling composition cascade when the source entity changes.

**Note on `computed`:** While the system supports computed phaseis, prefer the above four patterns. If you need a name transform, use template filters. If you need a type mapping, use a literal lookup table or generated content.

---

## Template Constraints (GDS Principle)

**Templates are dumb molds.** Computation lives in praxis steps; templates only assemble pre-computed values.

### Supported Syntax

Templates support **only**:
- `{{ variable }}` — Simple substitution
- `{{ variable | filter }}` — Filter pipes (snake_case, pascal_case, join, yaml, etc.)

### Not Supported

| Syntax | Example | Why | Fix |
|--------|---------|-----|-----|
| Block helpers | `{{#each items}}` | Templates don't iterate | Use `for_each` in praxis steps |
| Conditionals | `{{#if condition}}` | Templates don't branch | Use `switch`/`set` in praxis or slot `when:` |
| Closers | `{{/each}}`, `{{/if}}` | No blocks to close | Remove block structure |
| Else branches | `{{else}}` | No conditionals | Prepare both values in praxis |
| Jinja blocks | `{{ if $x }}...{{ end }}` | Not Jinja | Pre-compute sections |
| Ternaries | `$x ? 'a' : 'b'` | No expressions | Use praxis `switch` step |
| Embedded JS | `<script>` | No client computation | Use render-spec widgets |

### The Pattern

```
❌  Template with computation (conditionals, loops, branching)
✅  Praxis computes → slots receive finished values → template assembles
```

For **iteration**: Use `for_each` in praxis steps to build arrays, then pass the assembled result to a slot.

For **conditionals**: Use `switch`/`set` in praxis steps to prepare the right value, or use `when:` on typos slots to gate inclusion.

For **formatting**: Use praxis steps (`map`, `set`, `join()`) to prepare formatted strings before passing to the template.

### Render-Specs as Model

The render-spec widget system proves the GDS pattern for UI:
- `each` property on any widget = field-level iteration (not template loops)
- Collection modes with `item_spec_id` = entity-level iteration (not template loops)
- `when:` expressions = conditionals (not template branches)
- Compound mode `sections[]` = composition (not template partials)

Apply the same principle to all composition domains: configs, documents, prompts.

### Bootstrap Validation

The bootstrap process validates typos templates at load time. Templates containing block helpers, conditionals, or embedded scripts will produce warnings.

---

## The Mental Model

```
                           ┌─────────────────────┐
                           │  typos │
                           │                      │
                           │  slot: header        │ ← literal
                           │  slot: entity_a      │ ← queried
                           │  slot: section_1     │ ← composed from entity_a
                           │  slot: entity_b      │ ← queried
                           │  slot: section_2     │ ← composed from entity_b
                           │  slot: usage         │ ← generated from entities
                           │                      │
                           │  template: assemble  │
                           └─────────────────────┘
                                    ↓
                           demiurge/compose
                                    ↓
                           artifact entity with:
                           - content (rendered template)
                           - content_hash (BLAKE3)
                           - provenance (definition + inputs)
                                    ↓
                           thyra/emit
                                    ↓
                           file in chora
```

**Adding a content block means:**
1. Create the source entity (if new)
2. Add a `queried` slot to fetch it
3. Add a `composed` slot to transform it (or include in template directly)
4. Add reference in template

This is explicit. You see every block in the definition.

---

## Recipe: Designing an Artifact-Definition

### Step 1: Know Your Output

Look at the target file. Identify the parts:

```
step_types.rs
├── Header (provenance comment)
├── Helper types (SwitchCase struct)
├── Step enum with variants
├── step_name() function
├── STEP_NAMES array
├── SetStep struct
├── GatherStep struct
├── ... (one struct per stoicheion)
```

### Step 2: Map Parts to Patterns

For each part, ask:
- Is this constant text? → `literal`
- Does this need data from an entity? → `queried`
- Does this need structure from child artifact? → `composed`
- Does this need meaning extraction? → `generated`

### Step 3: Write the Definition with Explicit Slots

```yaml
- eidos: typos
  id: typos-def-step-types-rs
  data:
    name: step-types-rs
    description: "Rust step types file"
    slots:
      # Header is constant
      - name: header
        pattern: literal
        value: |
          // GENERATED FILE — DO NOT EDIT
          // Source: stoicheion entities
          // Generator: demiurge/compose

      # Helper types are constant
      - name: helper_types
        pattern: literal
        value: |
          #[derive(Debug, Clone)]
          pub struct SwitchCase {
              pub when: String,
              pub then: Vec<Step>,
          }

      # Each stoicheion is explicitly referenced
      - name: stoicheion_set
        pattern: queried
        source: "find('stoicheion/set')"

      - name: stoicheion_gather
        pattern: queried
        source: "find('stoicheion/gather')"

      # ... one slot per stoicheion ...

      # Each struct is explicitly composed
      - name: struct_set
        pattern: composed
        definition: typos-def-step-struct
        inputs:
          stoicheion: "$stoicheion_set"

      - name: struct_gather
        pattern: composed
        definition: typos-def-step-struct
        inputs:
          stoicheion: "$stoicheion_gather"

      # ... one slot per struct ...

      # Enum assembles all variants (listed explicitly)
      - name: step_enum
        pattern: literal
        value: |
          #[derive(Debug, Clone)]
          #[serde(tag = "step", rename_all = "snake_case")]
          pub enum Step {
              Set(SetStep),
              Gather(GatherStep),
              // ... each variant listed ...
          }

    template: |
      {{ header }}

      {{ helper_types }}

      {{ step_enum }}

      {{ struct_set }}

      {{ struct_gather }}
```

### Step 4: Adding a New Stoicheion

When you add `stoicheion/my-new-step`:

1. **Create the entity:**
   ```yaml
   - eidos: stoicheion
     id: stoicheion/my-new-step
     data:
       name: my_new_step
       tier: 1
       fields: [...]
   ```

2. **Add queried slot:**
   ```yaml
   - name: stoicheion_my_new_step
     pattern: queried
     source: "find('stoicheion/my-new-step')"
   ```

3. **Add composed slot:**
   ```yaml
   - name: struct_my_new_step
     pattern: composed
     definition: typos-def-step-struct
     inputs:
       stoicheion: "$stoicheion_my_new_step"
   ```

4. **Add to enum (literal):**
   ```yaml
   MyNewStep(MyNewStepStep),
   ```

5. **Add to template:**
   ```yaml
   {{ struct_my_new_step }}
   ```

**This is the discipline.** Every content block is visible in the definition.

---

## Child Typos

Complex structures compose from simpler ones.

### typos-def-step-struct (Level 2)

```yaml
- eidos: typos
  id: typos-def-step-struct
  data:
    name: step-struct
    description: "Rust struct for a stoicheion"
    slots:
      - name: stoicheion
        pattern: input
        required: true
        description: "The stoicheion entity"

      - name: doc_comment
        pattern: generated
        prompt: |
          Write a concise Rust doc comment for this step struct.
          Name: {{ stoicheion.data.name }}
          Description: {{ stoicheion.data.description }}
          Return only the comment text (no ///).

      # Fields are explicit per stoicheion, or use composed with explicit inputs
      - name: fields_content
        pattern: composed
        definition: typos-def-step-fields
        inputs:
          fields: "$stoicheion.data.fields"

    template: |
      /// {{ doc_comment }}
      #[derive(Debug, Clone, serde::Serialize, serde::Deserialize)]
      pub struct {{ stoicheion.data.name | pascal_case }}Step {
      {{ fields_content }}
      }
```

### typos-def-step-fields (Level 1)

```yaml
- eidos: typos
  id: typos-def-step-fields
  data:
    name: step-fields
    description: "Rust fields for a step struct"
    slots:
      - name: fields
        pattern: input
        required: true

      - name: rendered_fields
        pattern: generated
        prompt: |
          Generate Rust struct fields from these field definitions.

          Fields: {{ fields | json }}

          Rules:
          - Use snake_case for field names
          - Map types: string→String, integer→i64, boolean→bool, object→serde_json::Value
          - Optional fields use Option<T>
          - Add #[serde(default)] for optional fields
          - Include pub visibility

          Return only the field declarations, one per line.

    template: |
      {{ rendered_fields }}
```

**Why generated for fields?** The field-to-Rust transformation involves type mapping and serde annotations. Rather than complex computed logic, let the LLM apply the rules.

---

## The Emission Scopes

### E7: Rust Step Types

**Source:** `stoicheion` entities
**Output:** `crates/kosmos/src/interpreter/step_types.rs`
**Method:** Explicit slots per stoicheion, composed structs, generated docs

### E8: TypeScript Entities

**Source:** `eidos` entities
**Output:** `app/src/types/entities.ts`
**Method:** Explicit slots per eidos, generated interfaces

### E9: MCP Dispatch

**Source:** `praxis` entities (visible: true)
**Output:** `crates/kosmos-mcp/src/dispatch.rs`
**Method:** Explicit slots per visible praxis, generated dispatch arms

### E10: Dynamis Dispatch

**Source:** `mode` entities (infrastructure modes)
**Output:** `crates/kosmos/src/dynamis/dispatch.rs`
**Method:** Explicit slots per mode, generated handlers

### E11: Configuration

**Source:** `app-config` entities (to be defined)
**Output:** `tauri.conf.json`, `Cargo.toml`, etc.
**Method:** Explicit slots per config section, literal or queried values

### E12: Documentation

**Source:** `topos` entities and their contents
**Output:** `genesis/{topos}/REFERENCE.md`
**Method:** Explicit sections, generated descriptions and usage examples

---

## Full-Circle Verification

Full-circle proves the kosmos can emit itself and be reconstituted identically.

```
kosmos.db
    ↓ emit
cycle-1/
    ↓ BLAKE3 hash → H1
    ↓ bootstrap
cycle-1.db
    ↓ emit
cycle-2/
    ↓ BLAKE3 hash → H2

assert H1 == H2
```

### For Full-Circle to Work

1. **Constitutional content uses literal** — Eide, desmoi, stoicheia definitions are not derived
2. **Generated content must be deterministic** — Same prompt + schema = same output, OR baked at publish time
3. **All slots are explicit** — No dynamic discovery that could vary between cycles

### Baking Generated Content

Before publishing a topos, generated slots are resolved to literals:

```yaml
# Before baking
- name: usage_section
  pattern: generated
  prompt: "Write usage examples..."

# After baking
- name: usage_section
  pattern: literal
  value: "## Usage\n\nTo create a new oikos..."
```

The `bake-topos` praxis resolves all generation specs to their outputs.

---

## Extending Kosmos

### Adding an Eidos

1. Define in `genesis/arche/eidos.yaml`:
   ```yaml
   - eidos: eidos
     id: eidos/my-type
     data:
       name: my-type
       fields: [...]
   ```

2. Bootstrap to validate

3. Create entities of the type in appropriate topos

**No Rust code needed** — eide are pure schema.

### Adding a Desmos

1. Define in `genesis/arche/desmos.yaml`:
   ```yaml
   - eidos: desmos
     id: desmos/my-bond
     data:
       name: my-bond
       from_eidos: source-type
       to_eidos: target-type
   ```

2. Use via `bind` step in praxeis

3. Query via `trace` step

**No Rust code needed** — bonds are generic.

### Adding a Stoicheion

This DOES require Rust code:

1. Define in `genesis/stoicheia-portable/eide/stoicheion.yaml`

2. Build to generate types (`cargo build --package kosmos`)

3. Implement execution in `steps.rs`

4. Add to `execute_step` dispatch

5. **Update typos-def-step-types-rs** with new slots

### Adding an Topos

1. Create directory: `genesis/{topos-name}/`

2. Create `manifest.yaml`:
   ```yaml
   id: topos/{name}
   name: {name}
   version: 0.1.0
   content_paths:
     - eide/
     - desmoi/
     - praxeis/
   ```

3. Create DESIGN.md documenting the topos

4. Add praxeis in `praxeis/{name}.yaml`

---

## Anti-Patterns

See also [Template Constraints](#template-constraints-gds-principle) for template-specific anti-patterns.

### 1. Dynamic Iteration

**Wrong:**
```yaml
slots:
  - name: structs
    pattern: composed
    definition: typos-def-step-struct
    for_each: "$stoicheia"  # Dynamic!
```

**Right:**
```yaml
slots:
  - name: struct_set
    pattern: composed
    definition: typos-def-step-struct
    inputs: { stoicheion: "$stoicheion_set" }
  - name: struct_gather
    pattern: composed
    # ... explicit per stoicheion
```

### 2. Complex Computed Expressions

**Wrong:**
```yaml
- name: type_name
  pattern: computed
  source: |
    if $field.required:
      rust_type_map($field.type)
    else:
      "Option<" + rust_type_map($field.type) + ">"
```

**Right:**
```yaml
- name: fields_rust
  pattern: generated
  prompt: |
    Convert these fields to Rust struct fields.
    Apply type mapping and Option wrapper for optional fields.
    Fields: {{ fields | json }}
```

### 3. Queried Direct to Template

**Wrong:**
```yaml
- name: eide
  pattern: queried
  gather: { eidos: eidos }

template: |
  {% for e in eide %}
  {{ e.data.name }}
  {% endfor %}
```

**Right:**
```yaml
- name: eidos_prosopon
  pattern: queried
  source: "find('eidos/prosopon')"

- name: eidos_oikos
  pattern: queried
  source: "find('eidos/oikos')"

template: |
  - {{ eidos_prosopon.data.name }}
  - {{ eidos_oikos.data.name }}
```

### 4. Generated for Structure

**Wrong:**
```yaml
- name: struct_code
  pattern: generated
  prompt: "Generate the complete Rust struct for {{ stoicheion }}"
```

**Right:**
```yaml
- name: doc_comment
  pattern: generated
  prompt: "Write a doc comment for {{ stoicheion.data.description }}"

template: |
  /// {{ doc_comment }}
  #[derive(Debug, Clone)]
  pub struct {{ stoicheion.data.name | pascal_case }}Step {
  {{ fields }}
  }
```

Generated provides **meaning** (descriptions, comments). Structure is **literal** in templates.

### 5. Template-Level Computation

**Wrong:**
```yaml
template: |
  {{#each items}}
  - {{ name }}: {{ value }}
  {{/each}}

  {{#if has_notes}}
  ## Notes
  {{ notes }}
  {{/if}}
```

**Right:**
```yaml
# Praxis prepares the data
- step: for_each
  items: "$items"
  each:
    - step: set
      name: formatted_item
      value: "- {{ $item.name }}: {{ $item.value }}"
    - step: append
      list: "$formatted_items"
      item: "$formatted_item"

- step: switch
  on: "$has_notes"
  cases:
    - when: "true"
      then:
        - step: set
          name: notes_section
          value: "## Notes\n{{ $notes }}"
    - default:
        - step: set
          name: notes_section
          value: ""

# Template only assembles
template: |
  {{ formatted_items | join('\n') }}

  {{ notes_section }}
```

Templates are **dumb molds**. All computation happens in praxis steps.

---

## What an Agent Needs to Compose

### 1. Know the Output

Read the target file. Understand its structure.

### 2. Identify Content Blocks

Each distinct part of the output is a block.

### 3. Create Explicit Slots

One slot per block. No iteration.

### 4. Choose the Right Pattern

- Constant text → `literal`
- Entity data → `queried`
- Structured part → `composed`
- Meaning/description → `generated`

### 5. Assemble in Template

The template is the final assembly. It should be mostly `{{ slot_name }}` references.

### 6. Verify Full-Circle

Emit → bootstrap → emit → hash compare.

---

## Dependency Tracking and Idempotent Compose

Composition creates structural dependencies. When a `queried` slot resolves entities from the graph, `compose_entity()` creates `depends-on` bonds from the composed entity to each resolved entity. This makes the dependency graph explicit and traversable.

### What Gets Tracked

| Slot Pattern | Creates `depends-on` Bond? | Why |
|---|---|---|
| `literal` | No | Depends on the definition, not graph entities |
| `queried` | **Yes** — one bond per resolved entity | Reads data from graph entities |
| `composed` | No (child has its own bonds) | Staleness propagates transitively via cascade |
| `generated` | No (generation is a separate reconciliation loop) | Generation has its own reconciliation |

### Composition Cascade

Compose is idempotent. When a source entity changes:
1. `EntityUpdated` fires → staleness reflex detects inbound `depends-on` bonds
2. Each dependent entity is composed again from stored `_composition_inputs`
3. Compose compares new content hash to existing — updates only if different
4. `update_entity()` fires `EntityUpdated` → cascade continues to downstream dependents
5. When content hash matches → no update → cascade terminates

There is no separate "recompose" operation. Composing an entity that already exists handles the hash comparison and conditional update internally.

### DAG Constraint

`depends-on` bonds must form a directed acyclic graph. Circular composition dependencies are rejected at composition time — derivation requires an evaluation order, and cycles have none.

### Compose Handles Both Modes of Becoming

First composition is γένεσις (genesis) — the entity comes into being through the full arise contract (contextual gate, validation, provenance bonds, change notification).
Subsequent composition of an existing entity is μεταβολή (change) — the entity persists, its content evolves via update. The distinction is determined by context within a single compose operation. Both paths enforce the same arise contract — the only difference is whether the entity already exists.

See: [Actualization Pattern § Composition Reconciliation](../reactivity/actualization-pattern.md) for the reconciliation loop mechanics.

---

## Summary

**One form of composition.** Artifact-definitions with explicit slots.

**Four patterns.** Literal, queried, composed, generated.

**Explicit is better.** Every content block is visible. Adding a block means adding a slot.

**Generated for meaning.** Structure is in templates and composed children.

**Dependencies are explicit.** Queried slots create `depends-on` bonds. Staleness propagates through the DAG. Content hashing prunes redundant work.

**Full-circle proves coherence.** Emit → bootstrap → emit → identical hash.

---

*This guide replaces COMPOSITION.md, EMISSION.md, EXTENDING.md, and ARTIFACT-GRAPH-DESIGN.md.*
