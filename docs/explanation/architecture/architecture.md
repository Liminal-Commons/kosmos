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

**Infrastructure modes**: Each provider (R2, S3, Cloudflare, Docker, local) has a mode entity defining its sense/act operations.

### 2. Generation Loop (Manteia)

Governs LLM inference with schema constraints.

```
phasis  →  manteia  →  artifact
   intent      governed     result
              inference
```

**Governance**: All generation flows through `manteia/governed-inference`:
- Schema constrains output structure
- Authorization via phasis provenance
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

## Cursor-Based Change Detection

Change detection implements the cache-driven pillar: changes are computed from deltas, not stored as entities.

### The Model

```
prosopon --last-saw[version=38]--> oikos/chora

Notification query:
  entities in oikos/chora WHERE version > 38
  → 4 entities changed since you last looked
```

**Key insight:** A "change" isn't an entity. A change is the delta between:
1. The state you last observed (your cursor)
2. The current state (entity versions)

### Entity Versioning

Every entity has:
- `version` — Monotonically increasing global sequence number
- `content_hash` — Blake3 hash of entity data

When an entity is created or updated:
1. Assign next global version
2. Compute content_hash from data
3. Store entity

### The `last-saw` Desmos

```yaml
- id: last-saw
  from_eidos: [prosopon]
  to_eidos: [oikos]
  cardinality: one-to-one
  data_schema:
    version:
      type: integer
      description: Version when prosopon last observed this oikos
```

### Notification Query

For each oikos a prosopon is member-of:
1. Get prosopon's `last-saw` version for that oikos
2. Count entities in oikos with `version > cursor`
3. Return `{ oikos_id, unseen_count }`

### Cursor Update

When prosopon views an oikos:
1. Get current max version in oikos
2. Upsert `last-saw` bond with that version
3. Notification count becomes 0

### Why Not Change-Record Entities?

| Approach | Storage | Consistency | Cleanup |
|----------|---------|-------------|---------|
| Change-record entities | Proliferates | Can drift | Needs policy |
| Cursor bonds | O(prosopa × oikoi) | Always consistent | Nothing to prune |

The cursor model is simpler and aligns with content-addressing: the cache key (content_hash) already tells you if something changed.

### Cache Alignment

For artifact rendering:
```
cache_key = (entity_id, content_hash, render_spec_id)
```

When content_hash changes, cache misses. No explicit invalidation needed — content-addressing handles it automatically.

---

## Reactive System

The reactive system is the autonomic nervous system of kosmos. It unifies three layers:

| Layer | Purpose | Question | Home |
|-------|---------|----------|------|
| **Reflex** | Event detection | "Something changed — what should happen?" | ergon |
| **Reconciler** | State alignment | "Is intent aligned with actuality?" | dynamis |
| **Mode** | Substrate interface | "How does this type become actual?" | dynamis |

### The Complete Flow

```
Graph mutation (entity/bond created, updated, deleted)
    ↓
Reflex fires (post-commit hook checks trigger patterns)
    ↓
Response praxis invokes reconciler
    ↓
Reconciler senses actuality, compares to intent
    ↓
Reconciler action (manifest/unmanifest) via mode
    ↓
Stoicheion executes against substrate
```

### Relationship to Cursor Model

| System | Question | Tracks |
|--------|----------|--------|
| Cursor | "What's new for Claude to see?" | Observation |
| Reflex | "What should happen automatically?" | Action |
| Reconciler | "Are we where we want to be?" | Alignment |

Cursors track what Claude has *observed*. Reflexes track what the *system* should *do*.

### See Also

- [genesis/REACTIVE-SYSTEM.md](genesis/REACTIVE-SYSTEM.md) — Complete reactive system design
- [genesis/ergon/DESIGN.md](genesis/ergon/DESIGN.md) — Reflex system (Layer 1)
- [genesis/dynamis/DESIGN.md](genesis/dynamis/DESIGN.md) — Reconciler and modes (Layers 2-3)

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

## Modes (Infrastructure)

Modes define how to bridge kosmos intent to chora providers.

### Mode as Entity

```yaml
eidos: mode
id: mode/r2
data:
  name: r2
  substrate: r2
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

`build.rs` generates `mode_dispatch.rs` with dispatch logic:

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

### Stage 1: Topos Loading
Load topos packages in dependency order:
- Read manifest.yaml for each topos
- Validate `requires_dynamis` dependencies
- Load eide, desmoi, praxeis

### Stage 2: Dwelling Establishment
Establish operational context:
- Create or restore parousia
- Establish oikos membership
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
- Governance (oikoi, attainments, invitations)
- Phasis (express, reply, threads)
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
entity → authorized-by → phasis → ... → genesis-root
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
- `genesis/` - Foundational content (bootstrap source, core topoi)
- `topoi/` - Deferred topoi (not loaded at bootstrap)

### kosmos (future)
Pure content repository:
- Topoi developed natively in kosmos
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
| Composition layer | typos, topos, praxis |
| Knowledge layer | theoria, principle, pattern |
| Infrastructure | reconciler, mode |
| Reference documentation | eidos-reference, praxis-reference |

The distinction is marked by `constitutional: true` on eidos definitions.

---

## Key Invariants

From [KOSMOGONIA.md](KOSMOGONIA.md) constitutional axioms:
1. **Axiom I: Composition**: Nothing arises raw; everything is composed through definitions with provenance
2. **Axiom II: Authority**: The kosmos acts only as authorized by those who dwell in it
3. **Axiom III: Traceability**: Every entity's origin is verifiable through the bond graph
4. **Visibility = Reachability** (pillar): Access determined by bond traversal from dwelling position
5. **Authenticity = Provenance** (pillar): Everything traces to signed genesis

From the development pillars:
6. **Schema as source**: Generated code is derivative, never authoritative
7. **Bonds over references**: Relationships exist as desmoi, not embedded IDs

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
- **Provenance**: Composed entity has ``authorized-by` bond to authorizing phasis
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
- [../../topoi/dynamis/](../../topoi/dynamis/) — Actuality bridging details (deferred topos)
- [../../topoi/dokimasia/](../../topoi/dokimasia/) — Validation layer details (deferred topos)

---

*Technical architecture consolidated from dynamis, stoicheia-portable, schema-driven-vision, and dokimasia designs.*
