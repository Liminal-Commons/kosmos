# ARCHITECTURE.md

Technical architecture for the kosmos implementation. This document consolidates implementation concerns; for ontological foundations see [KOSMOGONIA.md](KOSMOGONIA.md).

---

## The Development Pillars

All development follows three interconnected principles (see [KOSMOGONIA.md](KOSMOGONIA.md) for constitutional context):

| Pillar | Principle | Implementation |
|--------|-----------|----------------|
| **Schema-driven** | Structure declared, then actualized | stoicheion.yaml → build.rs → step_types.rs |
| **Graph-driven** | Relationships are explicit bonds | Bond graph IS access control |
| **Cache-driven** | Composition memoized by content hash | Same inputs = same hash = cached |

**Key discipline**: Fix at generation level — never edit generated code, fix schema or generator.

---

## Three Reconciliation Loops

The system maintains coherence through three distinct reconciliation processes:

### 1. Actuality Loop (Dynamis)

Aligns kosmos intent with chora actuality.

```
kosmos (intent)     →  dynamis bridge  →  chora (actuality)
desired_state=X         sense/act          actual_state=Y
```

**Pattern**: Phylax (sense → compare → act)
- **Sense**: Query provider for actual state
- **Compare**: Diff against kosmos intent
- **Act**: Manifest, unmanifest, or update

**Actuality modes**: Each provider (R2, S3, Cloudflare, Docker, local) has a mode entity defining its sense/act operations.

### 2. Generation Loop (Manteia)

Governs LLM inference with schema constraints.

```
expression  →  manteia  →  artifact
   intent      governed     result
              inference
```

**Governance**: All generation flows through `manteia/governed-inference`:
- Schema constrains output structure
- Authorization via expression provenance
- Results memoized by (prompt + schema + model) hash

### 3. Schema Loop

Aligns authored praxis YAML with interpreter expectations.

```
stoicheion.yaml  →  build.rs  →  step_types.rs
   (schema)        (generate)    (Rust enum)
```

**Validation sequence**:
1. Author writes praxis YAML with step definitions
2. Bootstrap parses steps against known stoicheia
3. Interpreter executes using generated Step enum
4. Type mismatches caught at parse time, not runtime

---

## Stoicheia Architecture

Stoicheia are the vocabulary of praxis steps. Each stoicheion defines:
- **Fields**: Parameters with types and validation
- **Tier**: Capability level (0-3)
- **Semantics**: What the step does

### Tier Model

| Tier | Name | Capability | Examples |
|------|------|------------|----------|
| 0 | Elemental | Pure data flow | set, return, literal |
| 1 | Aggregate | Control flow | switch, for_each, filter, map |
| 2 | Compositional | Entity/bond operations | arise, find, bind, trace |
| 3 | Generative | Actuality bridging | http, infer, reconcile |

### Code Generation Pipeline

Two stoicheion files serve different purposes:
- `genesis/arche/stoicheion.yaml` — Core type definitions (bootstrap)
- `genesis/stoicheia-portable/eide/stoicheion.yaml` — Detailed step vocabulary (code generation source)

```
genesis/stoicheia-portable/eide/stoicheion.yaml
           ↓
    crates/kosmos/build.rs
           ↓
    crates/kosmos/src/step_types.rs (generated)
           ↓
    crates/kosmos/src/interpreter/steps.rs (hand-written dispatch)
```

The build script:
1. Reads stoicheion definitions from genesis
2. Generates `Step` enum with all variants
3. Generates field accessor traits
4. Generates validation code

**Adding a stoicheion**:
1. Add definition to `stoicheia-portable/eide/stoicheion.yaml`
2. Run `cargo build` (generates enum variant)
3. Add execution logic in `steps.rs`

---

## Actuality Modes

Actuality modes define how to bridge kosmos intent to chora providers.

### Mode as Entity

```yaml
eidos: actuality-mode
id: actuality-mode/r2
data:
  name: r2
  provider: cloudflare-r2
  sense_operation: r2_head_object
  act_operations:
    manifest: r2_put_object
    unmanifest: r2_delete_object
  config_schema:
    bucket: { type: string, required: true }
    endpoint: { type: string, required: true }
```

### Generated Dispatch

`build.rs` generates `actuality_modes.rs` with dispatch logic:

```rust
// Generated - do not edit
pub fn dispatch_sense(mode: &str, config: &Value) -> Result<ActualityState> {
    match mode {
        "r2" => r2::sense(config),
        "s3" => s3::sense(config),
        "local" => local::sense(config),
        // ... generated from mode entities
    }
}
```

**Adding a mode**: Create mode entity in YAML, rebuild. No hand-written Rust required.

---

## Bootstrap Stages

System initialization proceeds through defined stages:

### Stage 0: Genesis Loading
Load foundational entities from `genesis/spora/`:
- Eide (type definitions)
- Desmoi (bond types)
- Core praxeis

### Stage 1: Oikos Loading
Load oikos packages in dependency order:
- Read manifest.yaml for each oikos
- Validate `requires_dynamis` dependencies
- Load eide, desmoi, praxeis

### Stage 2: Dwelling Establishment
Establish operational context:
- Create or restore animus
- Establish circle membership
- Derive attainments from membership

### Stage 3: MCP Projection
Project praxeis as MCP tools:
- Filter to essential praxeis
- Generate tool schemas from praxis parameters
- Register with MCP server

---

## MCP Projection

Praxeis are exposed to Claude via MCP (Model Context Protocol).

### Projection Pipeline

```
praxis entity  →  projection.rs  →  MCP tool
   (kosmos)        (transform)       (JSON schema)
```

### Essential Tools Filter

Not all praxeis are exposed. The essential filter:
- Reduces context consumption
- Focuses on dwelling operations
- Excludes internal/system praxeis

Categories exposed:
- Navigation (find, surface, traverse, gather)
- Knowledge (theoria, inquiry, journey)
- Governance (circles, attainments, invitations)
- Expression (express, reply, threads)
- Composition (compose, validate)
- Streams and embodiment

### Tool Schema Generation

```rust
fn project_praxis_as_tool(praxis: &Entity) -> Tool {
    Tool {
        name: format!("mcp__kosmos__{}", praxis.name),
        description: praxis.data.description,
        input_schema: derive_json_schema(&praxis.data.params),
    }
}
```

---

## Validation Architecture

Validation occurs at multiple layers:

### Layer 1: Provenance
Every entity traces to genesis via `authorized-by` bonds.
```
entity → authorized-by → expression → ... → genesis-root
```

### Layer 2: Schema
Content matches target eidos field definitions.
- Required fields present
- Types correct
- Enum values valid

### Layer 3: Semantic
All entity references resolve.
- Referenced entities exist
- Bond endpoints valid

### Layer 4: Behavioral (Future)
Runtime invariants hold.
- Praxis execution succeeds
- Side effects valid

### Shift-Left Validation

Validation moves toward authoring time:
1. **Definition time**: Schema errors caught at bootstrap
2. **Composition time**: Semantic errors caught at compose
3. **Execution time**: Only behavioral issues remain

---

## Repository Structure

### chora (this repo)
Rust/WASM implementation:
- `crates/kosmos/` - Core interpreter, entity system
- `crates/kosmos-mcp/` - MCP server projection
- `app/` - Thyra desktop application
- `genesis/` - Foundational content (bootstrap source, core oikoi)
- `oikoi/` - Deferred oikoi (not loaded at bootstrap)

### kosmos (future)
Pure content repository:
- Oikoi developed natively in kosmos
- No Rust code
- Depends on chora builds + kosmos database

---

## Constitutional vs Derivable Content

Content in kosmos falls into two categories based on how it must be filled during composition:

### Constitutional (Literal-Only)

Constitutional content defines what CAN exist. It must emit from `literal` fill methods because it cannot be derived — it IS the ground.

| Category | Eide | Location |
|----------|------|----------|
| Meta grammar | eidos, desmos, stoicheion | genesis/arche/ |
| Provenance root | genesis, signature | genesis/arche/ |
| Constitutional document | KOSMOGONIA.md | genesis/ |
| Contemplative register | CLAUDE.md | root |

**Constraint:** Constitutional entities cannot have `generated` or `queried` slots. They use `literal` fill only.

### Derivable (All Fill Methods)

Derivable content can use any fill method: literal, computed, queried, generated, composed.

| Category | Examples |
|----------|----------|
| Composition layer | typos, oikos, praxis |
| Knowledge layer | theoria, principle, pattern |
| Infrastructure | reconciler, actuality-mode |
| Reference documentation | eidos-reference, praxis-reference |

The distinction is marked by `constitutional: true` on eidos definitions.

---

## Key Invariants

From [KOSMOGONIA.md](KOSMOGONIA.md) constitutional pillars:
1. **Visibility = Reachability**: Access determined by bond traversal from dwelling position
2. **Authenticity = Provenance**: Everything traces to signed genesis

From the development pillars:
3. **Schema as source**: Generated code is derivative, never authoritative
4. **Bonds over references**: Relationships exist as desmoi, not embedded IDs
5. **Composition-only**: Nothing arises raw; everything is composed through definitions

---

## Constitutional Enforcement

KOSMOGONIA promises: *"Attempting to arise without composition fails. The system makes it impossible to do wrong."*

This section documents how that promise is enforced architecturally.

### The Problem: Escape Hatches

Raw stoicheia provide escape hatches that bypass constitutional requirements:

| Stoicheion | Constitutional Requirement | Escape Hatch |
|------------|---------------------------|--------------|
| `arise` | Composition-only: entities flow through definitions | "Create an entity directly (not via compose)" |
| `infer` | Governed generation: all LLM output is schema-constrained | Raw prompt → text output, no governance |

These exist for bootstrap (the interpreter itself needs them internally). But exposing them externally violates the constitution.

### The Solution: Internal vs External Stoicheia

Stoicheia are classified by visibility:

| Classification | Who Can Use | Examples |
|----------------|-------------|----------|
| **External** | Praxeis, agents, users | find, gather, compose, governed-inference, bind |
| **Internal** | Interpreter implementation only | arise, infer |

**Enforcement mechanism**: The interpreter gates internal stoicheia:
- If caller is not the composition subsystem → reject
- Internal stoicheia never appear in MCP projection
- Praxis authoring tools flag usage as error

### External Interfaces

These are the ONLY paths to creation and generation:

#### Entity Creation: `compose`

```
compose(typos_id, inputs) → entity with provenance
```

All entities flow through artifact definitions. The definition:
- Specifies the target eidos
- Declares slots with fill methods (literal, computed, queried, generated, composed)
- Declares bonds to create automatically
- Is itself an entity with provenance

Internally, `compose` may invoke `arise` — but that's implementation detail. The agent cannot call `arise` directly.

#### LLM Generation: `governed-inference`

```
governed-inference(prompt, schema) → governed envelope
```

All LLM output flows through manteia. The praxis:
- Requires output schema (explicit, from stoicheion, or from eidos)
- Returns structured JSON validated against schema
- Memoizes by (prompt + schema + model) hash
- [Future] Evaluates against criteria, returns verdict + guidance

Internally, `governed-inference` may invoke `infer` — but that's implementation detail. The agent cannot call `infer` directly.

### What This Means for Agents

Before enforcement:
```yaml
# Agent could bypass composition
- step: arise
  eidos: theoria
  id: theoria/my-insight
  data: { insight: "...", domain: "..." }
```

After enforcement:
```yaml
# Agent must use compose
- step: call
  praxis: demiurge/compose
  params:
    typos_id: typos-def-theoria
    inputs: { insight: "...", domain: "..." }
```

The difference:
- **Provenance**: Composed entity has `authorized-by` bond to authorizing expression
- **Validation**: Composition validates against eidos schema before arising
- **Defaults**: Definition can provide defaults, computed values, auto-bonds
- **Auditability**: Composition events are traceable

### Implementation Status

| Mechanism | Status | Location |
|-----------|--------|----------|
| Stoicheion visibility field | ✅ Implemented | `genesis/arche/eidos.yaml` |
| Internal stoicheion gating | ✅ Implemented (warning mode) | `crates/kosmos/src/interpreter/steps.rs` |
| MCP projection filtering | ✅ Implemented | `crates/kosmos-mcp/src/projection.rs` |
| Praxis linting | **Not implemented** | Future: `dokimasia/lint-praxis` |
| Governed envelope (verdict/guidance) | ✅ Implemented | `genesis/manteia/praxeis/manteia.yaml` |

**Gating Enforcement:**
- Default: Warning mode — logs deprecation but allows execution
- Enforced: Set `KOSMOS_ENFORCE_INTERNAL_GATING=true` to reject
- Migration: 66 praxeis need to migrate from `arise` → `compose` before enforcement

### Migration Path

Current praxeis using `arise` directly must migrate to composition:

1. **Create artifact definition** for the entity type
2. **Replace `arise` with `compose`** call using definition
3. **Validate provenance** flows correctly

Gating is implemented but in warning mode. Set `KOSMOS_ENFORCE_INTERNAL_GATING=true` to enforce after migration.

---

## See Also

- [KOSMOGONIA.md](KOSMOGONIA.md) — Ontological foundations
- [ROADMAP.md](ROADMAP.md) — Implementation phases
- [stoicheia-portable/](stoicheia-portable/) — Step vocabulary reference
- [../../oikoi/dynamis/](../../oikoi/dynamis/) — Actuality bridging details (deferred oikos)
- [../../oikoi/dokimasia/](../../oikoi/dokimasia/) — Validation layer details (deferred oikos)

---

*Technical architecture consolidated from dynamis, stoicheia-portable, schema-driven-vision, and dokimasia designs.*
