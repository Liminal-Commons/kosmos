# Bootstrap: Loading Genesis

Bootstrap is the process of loading genesis into a running kosmos. It transforms YAML definitions into a living entity graph.

---

## Overview

When chora starts, it:
1. Initializes an empty database
2. Verifies the spora signature and establishes germination context
3. Loads genesis through staged germination — all entities arise through composition
4. Discovers and loads topos manifests
5. Validates all praxeis against stoicheion schemas
6. Projects visible praxeis as MCP tools

The process is deterministic — the same genesis always produces the same initial state.

### One Right Way to Arise

Bootstrap uses the same composition path as runtime. There is no separate "bootstrap arise" — every entity, whether created in stage 0 or at runtime, goes through `compose_entity()` with:

1. **Contextual gate** — prosopon (who), oikos (where), session (when), attainment (by what right)
2. **Dokimasia validation** — entity data checked against eidos field definitions
3. **Content-hash idempotency** — same data = same hash = no redundant write
4. **`composed-from` bond** — provenance to the definition that produced it
5. **`typed-by` bond** — structural link to the entity's eidos
6. **`authorized-by` bond** — chain to the authorizing phasis
7. **`depends-on` bonds** — composition dependency DAG for cache invalidation
8. **Change notification** — reflexes can respond (dormant during bootstrap, active after)

For bootstrap, the spora IS the definition. The genesis root signature IS the authorization. The germination IS the session. No exceptions.

---

## Germination Stages

Bootstrap proceeds through defined stages in `genesis/spora/spora.yaml`:

### Stage 0: Prime

The self-grounding moment — `eidos/eidos` is composed.

```yaml
stage-0-prime:
  - compose:
      target_eidos: eidos
      id: eidos/eidos
      data:
        name: eidos
        description: "Form definition"
        fields: { ... }
```

This is the only entity that can exist before eidos exists. Everything else requires eidos to already be present. Even `eidos/eidos` arises through composition — the spora step IS the definition, and the `composed-from` bond is created retroactively once the grammar exists.

### Stage 1: Archai

Load the foundational forms:

```yaml
stage-1-archai:
  # Core entity types
  - compose: eidos/desmos
  - compose: eidos/stoicheion
  - compose: eidos/praxis
  - compose: eidos/typos
  - compose: eidos/theoria
  - compose: eidos/oikos
  - compose: eidos/prosopon
  - compose: eidos/parousia
  # ... all core eide
```

Also loads:
- **stage-1-desmoi**: Bond types (composed-from, authorized-by, member-of, etc.)
- **stage-1-dynamis**: Capability domains and functions

### Stage 2: Presence

Establish the presence layer:

```yaml
stage-2-presence:
  - compose: eidos/prosopon    # Identity
  - compose: eidos/parousia     # Dwelling presence
  - compose: eidos/oikos     # Trust boundary
  - compose: eidos/session    # Active context
```

### Stage 3: Founder

Create the initial state:

```yaml
stage-3-founder:
  # Personas
  - compose:
      target_eidos: prosopon
      id: prosopon/victor
      data: { name: "Victor", ... }

  - compose:
      target_eidos: prosopon
      id: prosopon/claude
      data: { name: "Claude", ... }

  # Root oikos
  - compose:
      target_eidos: oikos
      id: oikos/kosmos
      data: { name: "Kosmos Commons", ... }

  # Memberships
  - bind:
      from: prosopon/victor
      to: oikos/kosmos
      desmos: member-of
```

### Stage 3.5: Politeia

Establish governance:

```yaml
stage-3.5-politeia:
  # Attainments
  - compose: attainment/compose
  - compose: attainment/invite
  - compose: attainment/govern
  - compose: attainment/nous

  # Grant to founders
  - bind:
      from: parousia/victor-default
      to: attainment/compose
      desmos: has-attainment

  # Tier 3 gating
  - bind:
      from: stoicheion/infer
      to: attainment/use-api
      desmos: requires-attainment
```

### Stage 5: Complete

Marker indicating germination is complete:

```yaml
stage-5-complete:
  - compose:
      target_eidos: marker
      id: marker/germination-complete
```

---

## Topos Discovery

After germination, bootstrap discovers topos packages:

### Discovery Process

1. Scan `genesis/*/manifest.yaml`
2. Parse each manifest
3. Build dependency graph from `depends_on`
4. Topological sort for load order
5. Reject if cycles detected

### Load Sequence

For each topos (in dependency order):

```
1. Read manifest.yaml
2. For each content_path:
   - Load files matching content_types
   - Create sourced-from bonds to content-root
3. Validate:
   - All eidos references resolve
   - All desmos endpoints valid
   - All praxis steps are known stoicheia
4. Index visible praxeis for MCP projection
```

### Content Paths (v2.1)

The manifest declares where content lives:

```yaml
content_paths:
  - path: eide/
    content_types: [eidos]
  - path: desmoi/
    content_types: [desmos]
  - path: praxeis/
    content_types: [praxis]
  - path: entities/
    content_types: [reflex, render-spec]
```

Bootstrap uses these paths instead of hardcoded conventions.

---

## Praxis Validation

Every praxis is validated against stoicheion schemas:

### Validation Steps

1. **Step resolution**: Each step name must match a stoicheion
2. **Field validation**: Parameters must match stoicheion field schemas
3. **Type checking**: Field types must be correct
4. **Reference resolution**: All entity/bond references must resolve

### Error Handling

Invalid praxeis are rejected at bootstrap:

```
Error: praxis/nous/surface
  Step 'serface' at index 0 is not a known stoicheion
  Did you mean 'surface'?
```

This catches errors at load time, not runtime.

---

## MCP Projection

Visible praxeis are exposed as MCP tools:

### Visibility Filter

Only praxeis with `visible: true` are projected:

```yaml
- eidos: praxis
  id: praxis/nous/surface
  data:
    visible: true    # ← Exposed to Claude
    name: surface
    params: [...]
```

### Tool Generation

```
praxis/nous/surface
    ↓
Tool {
  name: "mcp__kosmos__nous_surface"
  description: praxis.data.description
  input_schema: derive_from(praxis.data.params)
}
```

### Essential Filter

The MCP layer applies additional filtering to reduce context:
- Internal/debug praxeis excluded
- Redundant operations deduplicated
- Focused on dwelling operations

---

## Database Initialization

### Schema

Bootstrap creates the entity-bond schema:

```sql
-- Entities
CREATE TABLE entities (
  id TEXT PRIMARY KEY,
  eidos TEXT NOT NULL,
  data JSONB,
  version INTEGER,
  content_hash BLOB
);

-- Bonds
CREATE TABLE bonds (
  id TEXT PRIMARY KEY,
  from_id TEXT NOT NULL,
  to_id TEXT NOT NULL,
  desmos TEXT NOT NULL,
  data JSONB
);

-- Indexes for traversal
CREATE INDEX idx_bonds_from ON bonds(from_id);
CREATE INDEX idx_bonds_to ON bonds(to_id);
CREATE INDEX idx_bonds_desmos ON bonds(desmos);
```

### Content Addressing

Every entity gets:
- **version**: Global monotonic sequence number
- **content_hash**: Blake3 hash of data

This enables cache-driven operations.

---

## Validation Layers

Bootstrap validates at multiple levels:

| Layer | What | When |
|-------|------|------|
| **Syntax** | YAML parses correctly | File load |
| **Schema** | Fields match eidos definitions | Entity load |
| **Reference** | All IDs resolve | After full load |
| **Semantic** | Praxis steps are valid stoicheia | Praxis load |
| **Provenance** | Composition bonds present | Optional |

---

## Troubleshooting

### Common Errors

**Unknown stoicheion**:
```
Error: Step 'each' is not a known stoicheion
Fix: Use 'for_each' instead
```

**Missing dependency**:
```
Error: Topos 'my-topos' depends on 'foo' which doesn't exist
Fix: Add 'foo' to genesis or remove dependency
```

**Circular dependency**:
```
Error: Circular dependency detected: a → b → c → a
Fix: Restructure dependencies
```

**Invalid field**:
```
Error: praxis/foo/bar field 'limit' expects integer, got string
Fix: Change "10" to 10 in YAML
```

### Debug Mode

Run with `KOSMOS_DEBUG=bootstrap` for verbose output:

```
[bootstrap] Stage 0: Prime
[bootstrap]   Composed eidos/eidos
[bootstrap] Stage 1: Archai
[bootstrap]   Loading 47 eide...
[bootstrap]   Loading 23 desmoi...
```

---

## See Also

- [Genesis Overview](index.md) — The constitutional layer
- [The Five Archai](archai.md) — What gets loaded
- [Topoi Organization](topoi.md) — How packages work
- [Architecture](../architecture/architecture.md) — System design
- [Bootstrap & Genesis](../../reference/genesis/bootstrap-genesis.md) — Implementation specifics (code flow, database schema)

---

*Bootstrap transforms YAML into a living world. Same genesis, same kosmos.*
