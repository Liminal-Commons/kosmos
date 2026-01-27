# COMPOSITION-GUIDE.md

How to compose artifacts in kosmos. The complete guide for agents.

---

## The One Thing

**Composition is explicit content assembly.**

An typos declares exactly what content blocks exist. Each slot either:
- **IS** content (literal)
- **REFERENCES** an entity (queried)
- **COMPOSES** another artifact (composed)
- **GENERATES** meaning (generated)

There is no iteration. No dynamic discovery. When you want a new block, you add a slot.

---

## Typos Routing Modes

The demiurge routes composition based on definition shape. All composition produces entities, but the routing determines what kind:

| Mode | Definition Shape | Result |
|------|-----------------|--------|
| **Entity composition** | Has `target_eidos` | Domain entity (theoria, circle, etc.) |
| **Graph composition** | Has `slots`, no `target_eidos` | Artifact entity with structured content |
| **Template rendering** | Has `template` only | Artifact entity with rendered content |

**Entity composition** creates domain entities — the "atomics" of each oikos. Use `typos-def-*` naming.

**Graph/Template composition** creates content artifacts — views, documents, rendered output. These can query and compose domain entities without being domain entities themselves.

Example naming convention:
- `typos-def-theoria` → creates a theoria entity
- `typos-view-theoria-card` → creates an artifact containing a rendered view of a theoria

---

## Fill Patterns

| Pattern | What It Does | When to Use |
|---------|--------------|-------------|
| `literal` | Value is in the definition | Templates, constants, headers |
| `queried` | Fetch entity from graph | Get data for composition/generation |
| `composed` | Invoke child typos | Structural parts of output |
| `generated` | LLM inference via manteia | Descriptions, doc comments, usage examples |

**Note on `computed`:** While the system supports computed expressions, prefer the above four patterns. If you need a name transform, use template filters. If you need a type mapping, use a literal lookup table or generated content.

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

**Source:** `actuality-mode` entities
**Output:** `crates/kosmos/src/dynamis/dispatch.rs`
**Method:** Explicit slots per actuality-mode, generated handlers

### E11: Configuration

**Source:** `app-config` entities (to be defined)
**Output:** `tauri.conf.json`, `Cargo.toml`, etc.
**Method:** Explicit slots per config section, literal or queried values

### E12: Documentation

**Source:** `oikos` entities and their contents
**Output:** `genesis/{oikos}/REFERENCE.md`
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

Before publishing an oikos, generated slots are resolved to literals:

```yaml
# Before baking
- name: usage_section
  pattern: generated
  prompt: "Write usage examples..."

# After baking
- name: usage_section
  pattern: literal
  value: "## Usage\n\nTo create a new circle..."
```

The `bake-oikos` praxis resolves all generation specs to their outputs.

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

3. Create entities of the type in appropriate oikos

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

### Adding an Oikos

1. Create directory: `genesis/{oikos-name}/`

2. Create `manifest.yaml`:
   ```yaml
   id: oikos/{name}
   name: {name}
   version: 0.1.0
   content_paths:
     - eide/
     - desmoi/
     - praxeis/
   ```

3. Create DESIGN.md documenting the oikos

4. Add praxeis in `praxeis/{name}.yaml`

---

## Anti-Patterns

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
- name: eidos_persona
  pattern: queried
  source: "find('eidos/persona')"

- name: eidos_circle
  pattern: queried
  source: "find('eidos/circle')"

template: |
  - {{ eidos_persona.data.name }}
  - {{ eidos_circle.data.name }}
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

## Summary

**One form of composition.** Artifact-definitions with explicit slots.

**Four patterns.** Literal, queried, composed, generated.

**Explicit is better.** Every content block is visible. Adding a block means adding a slot.

**Generated for meaning.** Structure is in templates and composed children.

**Full-circle proves coherence.** Emit → bootstrap → emit → identical hash.

---

*This guide replaces COMPOSITION.md, EMISSION.md, EXTENDING.md, and ARTIFACT-GRAPH-DESIGN.md.*
