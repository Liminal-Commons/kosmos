# Directory Conventions Reference

Standard directory structure and naming conventions for genesis content.

---

## Topos Directory Structure

```
genesis/{topos}/
├── manifest.yaml          # Required: Package metadata
├── DESIGN.md              # Required: Ontological purpose
├── REFERENCE.md           # Optional: API documentation
│
├── eide/                  # Entity type definitions
│   ├── {topos}.yaml       # Primary eide file
│   └── {category}.yaml    # Additional categorized eide
│
├── desmoi/                # Bond type definitions
│   ├── {topos}.yaml       # Primary desmoi file
│   └── {category}.yaml    # Additional categorized desmoi
│
├── praxeis/               # Operation definitions
│   ├── {topos}.yaml       # Primary praxeis file
│   └── {category}.yaml    # Additional categorized praxeis
│
├── entities/              # Pre-composed entity instances
│   ├── reflexes.yaml      # Reactive responses
│   ├── rendering.yaml     # Render specifications
│   └── {category}.yaml    # Other pre-composed entities
│
├── render-specs/          # UI widget specifications
│   └── {component}.yaml   # Per-component specs
│
├── typos/                 # Composition templates
│   └── {definition}.yaml  # Template definitions
│
├── modes/                 # Substrate integration
│   └── {mode}.yaml        # Mode specifications
│
└── theoria/               # Knowledge (nous topos)
    └── {topic}.md         # Theoria files
```

---

## Required Files

### manifest.yaml

Every topos must have a manifest. See [Manifest Schema](manifest-schema.md).

```yaml
format_version: "2.1"
topos_id: my-topos
version: "0.1.0"
# ...
```

### DESIGN.md

Every topos must have a design document explaining:
- Purpose and gap addressed
- Core entities and their lifecycle
- Oikos context
- Relationships to other topoi

```markdown
# My Topos

## Purpose

What this topos does and why it exists.

## Gap Addressed

What problem it solves.

## Core Entities

### entity-name

Description of the entity type.

## Lifecycle

How entities flow through states.

## Oikos Context

How entities relate to oikoi.
```

---

## Content Directories

### eide/

Entity type definitions. Each file contains an `entities` array of eidos definitions.

**Naming**: `{topos}.yaml` for primary, `{category}.yaml` for additional.

```yaml
# eide/nous.yaml
entities:
  - eidos: eidos
    id: eidos/theoria
    data:
      name: theoria
      fields:
        insight: { type: string, required: true }
```

### desmoi/

Bond type definitions. Each file contains an `entities` array of desmos definitions.

**Naming**: `{topos}.yaml` for primary, `{category}.yaml` for additional.

```yaml
# desmoi/nous.yaml
entities:
  - eidos: desmos
    id: desmos/crystallized-in
    data:
      name: crystallized-in
      from_eidos: theoria
      to_eidos: oikos
```

### praxeis/

Operation definitions. Each file contains an `entities` array of praxis definitions.

**Naming**: `{topos}.yaml` for primary, `{category}.yaml` for additional.

```yaml
# praxeis/nous.yaml
entities:
  - eidos: praxis
    id: praxis/nous/surface
    data:
      topos: nous
      name: surface
      visible: true
      steps: [...]
```

### entities/

Pre-composed entity instances loaded at bootstrap.

**Common files**:
- `reflexes.yaml` — Reactive response definitions
- `{category}.yaml` — Domain-specific entities (daemons, reconcilers, surfaces, etc.)

```yaml
# entities/reflexes.yaml
entities:
  - eidos: reflex
    id: reflex/nous/theoria-created
    data:
      trigger: { eidos: theoria, event: created }
      response: praxis/nous/index-theoria
```

### render-specs/

Declarative UI specifications for rendering entities.

**Naming**: `{component}.yaml` or `{entity-type}.yaml`

```yaml
# render-specs/theoria-card.yaml
entities:
  - eidos: render-spec
    id: render-spec/theoria-card
    data:
      target_eidos: theoria
      widget_tree: [...]
```

### typos/

Composition templates for creating entities.

**Naming**: `{definition}.yaml`

```yaml
# typos/theoria.yaml
entities:
  - eidos: typos
    id: typos/typos-def-theoria
    data:
      target_eidos: theoria
      slots: [...]
```

### modes/

Substrate integration specifications.

**Naming**: `{mode}.yaml`

```yaml
# modes/r2.yaml
entities:
  - eidos: mode
    id: mode/r2
    data:
      substrate: r2
      provider: cloudflare-r2
      sense_operation: r2_head_object
```

---

## Naming Conventions

### Entity IDs

Pattern: `{eidos}/{namespace}/{name}` or `{eidos}/{name}`

| Type | Pattern | Example |
|------|---------|---------|
| Eidos | `eidos/{name}` | `eidos/theoria` |
| Desmos | `desmos/{name}` | `desmos/crystallized-in` |
| Praxis | `praxis/{topos}/{name}` | `praxis/nous/surface` |
| Typos | `typos/typos-def-{name}` | `typos/typos-def-theoria` |
| Reflex | `reflex/{topos}/{trigger}` | `reflex/nous/theoria-created` |

### File Names

- Use lowercase with hyphens: `my-category.yaml`
- Primary file matches topos: `nous.yaml` in `genesis/nous/eide/`
- Category files describe content: `event-types.yaml`, `reflexes.yaml`

### Directory Names

- Use lowercase with hyphens: `voice-authoring/`
- Keep short but descriptive
- Match topos_id in manifest

---

## Special Directories

### arche/

The grammar of being. Contains foundational definitions:

```
genesis/arche/
├── eidos.yaml       # Entity type meta-definitions
├── desmos.yaml      # Bond type meta-definitions
├── stoicheion.yaml  # Step type meta-definitions
└── functions.yaml   # Expression functions
```

**Note**: arche is not a standard topos. It has no manifest.

### spora/

The bootstrap seed — the thin germination sequence. Content lives in per-topos directories.

```
genesis/spora/
├── spora.yaml         # Germination stages + content roots
└── praxeis/           # Seed praxeis (bootstrap operations)
```

### stoicheia-portable/

Step vocabulary for praxis generation:

```
genesis/stoicheia-portable/
├── manifest.yaml
└── eide/
    └── stoicheion.yaml  # Complete stoicheion schemas
```

---

## Content Roots

When manifest v2.1 `content_paths` is used, bootstrap:

1. Reads path declarations
2. Loads files from declared paths
3. Creates `sourced-from` bonds to content roots

This enables:
- Provenance tracking
- Alternative directory structures
- Selective loading

---

## File Format

All content files are YAML with standard structure:

```yaml
# Optional: file-level metadata
# Most files just have entities array

entities:
  - eidos: {type}
    id: {unique-id}
    data:
      # Entity-specific fields
```

### Multi-Document Files

Not currently supported. Use one YAML document per file.

### Comments

YAML comments (`#`) are allowed and encouraged for documentation.

```yaml
entities:
  # Theoria: crystallized understanding
  # See KOSMOGONIA.md for constitutional definition
  - eidos: eidos
    id: eidos/theoria
```

---

## See Also

- [Manifest Schema](manifest-schema.md)
- [Genesis Overview](../../explanation/genesis/index.md)
- [Create a Topos](../../tutorial/foundations/create-a-topos.md)
