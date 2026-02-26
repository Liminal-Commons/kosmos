# Surface Contracts — Topos Interoperability

Surfaces are capability contracts between topoi. A surface declares what a topos provides to (or requires from) other topoi — making inter-topos dependencies explicit, validated, and graph-traversable.

---

## Surface Eidos

A surface is an entity of eidos `surface`. Every surface has:

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `surface_id` | string | yes | Unique identifier (e.g., `reasoning`, `transport`) |
| `description` | string | yes | What this surface provides |
| `praxeis` | array | yes | Praxis IDs this surface exposes |
| `version` | string | no | Contract version (semver) |

Surface entities live in the providing topos's `entities/` directory:

```yaml
# genesis/manteia/entities/surfaces.yaml
entities:
  - eidos: surface
    id: surface/reasoning
    data:
      surface_id: reasoning
      description: |
        LLM-powered inference: schema-constrained generation,
        governed evaluation, and memoized results.
      praxeis:
        - praxis/manteia/governed-inference
        - praxis/manteia/generate-entity
        - praxis/manteia/generate-step
        - praxis/manteia/generate-praxis
        - praxis/manteia/generate-typos
        - praxis/manteia/get-stoicheion-schema
        - praxis/manteia/list-stoicheia
      version: "1.0"
```

---

## Surface Desmoi

Two bond types connect topos manifests to surfaces:

### `provides-surface`

A topos manifest provides a surface contract.

| Property | Value |
|----------|-------|
| `from_eidos` | `topos-manifest` |
| `to_eidos` | `surface` |
| `cardinality` | `many-to-many` |

### `consumes-surface`

A topos manifest requires a surface contract.

| Property | Value |
|----------|-------|
| `from_eidos` | `topos-manifest` |
| `to_eidos` | `surface` |
| `cardinality` | `many-to-many` |

---

## Manifest Declaration

Topoi declare surfaces in their `manifest.yaml`:

```yaml
# genesis/manteia/manifest.yaml
topos_id: manteia
surfaces_provided:
  - reasoning
surfaces_consumed: []
```

```yaml
# genesis/nous/manifest.yaml
topos_id: nous
surfaces_provided:
  - understanding
surfaces_consumed:
  - reasoning
```

---

## Bootstrap Behavior

During bootstrap, after loading each topos manifest:

1. **Surface entity creation**: For each entry in `surfaces_provided`, bootstrap finds or creates a `surface/{name}` entity. If the entity already exists (created by a prior manifest or loaded from genesis YAML), it is reused.

2. **Bond creation**: Bootstrap creates:
   - `provides-surface` bond: `topos-manifest/{topos_id}` → `surface/{name}` for each `surfaces_provided` entry
   - `consumes-surface` bond: `topos-manifest/{topos_id}` → `surface/{name}` for each `surfaces_consumed` entry

3. **Validation pass**: After ALL manifests are loaded, bootstrap validates that every `surfaces_consumed` entry has at least one corresponding `surfaces_provided` entry from another topos. In **strict mode**, unsatisfied surface dependencies are errors that fail bootstrap. In **non-strict mode** (default), they produce warnings.

### Error behavior

| Condition | Behavior |
|-----------|----------|
| Consumed surface has no provider (strict) | **Error** — bootstrap fails |
| Consumed surface has no provider (non-strict) | **Warning** — logged but bootstrap continues |
| Multiple topoi provide the same surface | **Allowed** — many-to-many cardinality |
| Topos provides surface but no YAML entity exists | **Warning** — surface entity created with minimal data |
| Surface entity YAML defines praxeis that don't exist | Content loading handles this separately |

---

## Graph Queries

Once surfaces are homoiconic, these queries become possible:

### Discover all surfaces
```
gather(eidos: surface)
```

### What surfaces does a topos provide?
```
trace(from: topos-manifest/manteia, desmos: provides-surface)
```

### Who provides the reasoning surface?
```
trace(to: surface/reasoning, desmos: provides-surface)
```

### What does a topos consume?
```
trace(from: topos-manifest/nous, desmos: consumes-surface)
```

### Are all dependencies satisfied?
Bootstrap validates this automatically. Post-bootstrap, traverse `consumes-surface` bonds and verify corresponding `provides-surface` bonds exist for each target surface.

---

## Known Surfaces

Surfaces are either **active** (consumers invoke praxeis directly) or **declarative** (consumers declare entities, the engine processes them autonomously). Declarative surfaces may have an empty `praxeis` array — the contract is the entity schema and the engine's guarantees, not an invocable entry point.

| Surface | Provider | Consumers | Type | Description |
|---------|----------|-----------|------|-------------|
| `reasoning` | manteia | demiurge, nous, stoicheia-portable | active | LLM inference and governed generation |
| `understanding` | nous | chora-dev, hodos, oikos | active | Semantic search and knowledge surfacing |
| `computation` | dynamis | chora-dev, release | active | Substrate computation capabilities |
| `reconciliation` | dynamis | aither, dokimasia, release | declarative | Declarative state alignment via transition rules |
| `reactivity` | dynamis | agora, aither, chora-dev, demiurge, dokimasia, ergon, nous, oikos, politeia, propylon, release, thyra | declarative | Event-driven mutation response via reflexes |
| `sensing` | dynamis | aither, chora-dev, dokimasia, release, thyra | declarative | Periodic actuality sensing via daemons |
| `transport` | aither | agora | active | Network transport and federation |
| `coordination` | ergon | — | active | Task coordination and daemon management |
| `emission` | genesis, thyra | ekdosis, release | active | Content emission to chora |
| `rendering` | thyra | agora, hodos | declarative | UI rendering via render-spec widget trees |
| `phasis` | logos | — | active | Expression threading and phasis management |
| `substrate-develop` | chora-dev | — | active | Development substrate tooling |

---

## Versioning

Surface versions use semver strings. Version checking is not enforced at bootstrap in the initial implementation — the version field exists for future contract evolution. When version checking is added, the rule will be: a consumer's required version must be compatible with the provider's advertised version.
