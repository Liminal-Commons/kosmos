# Manifest Schema Reference

Technical specification for topos `manifest.yaml` files.

---

## Format Version

Current version: `2.1`

```yaml
format_version: "2.1"
```

---

## Required Fields

### topos_id

Unique identifier for the topos. Must match the directory name.

```yaml
topos_id: nous
```

- Type: `string`
- Pattern: `[a-z][a-z0-9-]*`
- Required: yes

### version

Semantic version of the topos.

```yaml
version: "0.1.0"
```

- Type: `string`
- Pattern: semver (`major.minor.patch`)
- Required: yes

---

## Metadata Fields

### topos_name

Human-readable name.

```yaml
topos_name: "Nous"
```

- Type: `string`
- Required: no (defaults to topos_id)

### topos_description

Description of the topos purpose.

```yaml
topos_description: |
  Understanding operations — theoria, inquiry,
  synthesis, journeys.
```

- Type: `string` (multiline supported)
- Required: no

### topos_scale

Position in the klimax hierarchy.

```yaml
topos_scale: cross-scale
```

- Type: `enum`
- Values: `kosmos`, `physis`, `polis`, `topos`, `soma`, `psyche`, `cross-scale`
- Required: no (defaults to `cross-scale`)

### topos_category

Organizational category.

```yaml
topos_category: domain
```

- Type: `enum`
- Values: `infrastructure`, `domain`, `interface`, `meta`
- Required: no

---

## Content Declaration

### content_paths

Declares where content files live. Bootstrap uses these paths to discover content.

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
  - path: typos/
    content_types: [typos]
```

- Type: `array` of path declarations
- Required: no (but recommended)

#### Path Declaration

| Field | Type | Description |
|-------|------|-------------|
| `path` | string | Directory path relative to topos root |
| `content_types` | array | Entity types contained |

---

## Capability Declaration

### provides

What the topos exposes.

```yaml
provides:
  eide:
    - journey
    - waypoint
    - theoria
  praxeis:
    - nous/surface
    - nous/crystallize-theoria
    - nous/traverse
  desmoi:
    - crystallized-in
    - inquires
  attainments:
    - crystallize
    - journey
```

- Type: `object`
- Fields: `eide`, `praxeis`, `desmoi`, `attainments`, `affordances`
- Each field: `array` of IDs (without prefix)
- Required: no

### surfaces_provided

Service interfaces this topos provides.

```yaml
surfaces_provided:
  - understanding
  - knowledge
```

- Type: `array` of strings
- Required: no

### surfaces_consumed

Service interfaces this topos requires.

```yaml
surfaces_consumed:
  - reasoning
  - governance
```

- Type: `array` of strings
- Required: no

---

## Dependency Declaration

### depends_on

Other topoi this one depends on.

```yaml
depends_on:
  - manteia
  - politeia
```

- Type: `array` of topos IDs
- Required: no (defaults to empty)
- Note: Creates loading order; cycles rejected

### requires_dynamis

Substrate capabilities needed.

```yaml
requires_dynamis:
  - db.find
  - db.bind
  - db.update
  - aisthesis.surface
  - aisthesis.index
```

- Type: `array` of dynamis function IDs
- Required: no
- Pattern: `domain.function`

---

## Full Example

```yaml
format_version: "2.1"
topos_id: nous
version: "0.1.0"

topos_name: "Nous"
topos_description: |
  Understanding operations — theoria, inquiry, synthesis, journeys.

  Provides the knowledge layer for kosmos: crystallized understanding
  (theoria), active investigation (inquiry), and teleological
  movement (journeys with waypoints).

topos_scale: cross-scale
topos_category: domain

surfaces_provided:
  - understanding
  - knowledge

surfaces_consumed:
  - reasoning
  - governance

content_paths:
  - path: eide/
    content_types: [eidos]
  - path: desmoi/
    content_types: [desmos]
  - path: praxeis/
    content_types: [praxis]
  - path: entities/
    content_types: [reflex, render-spec]
  - path: theoria/
    content_types: [theoria]
  - path: render-specs/
    content_types: [render-spec]

requires_dynamis:
  - db.find
  - db.bind
  - db.update
  - db.dissolve
  - aisthesis.surface
  - aisthesis.index

provides:
  eide:
    - journey
    - waypoint
    - inquiry
    - synthesis
    - theoria

  praxeis:
    - nous/surface
    - nous/find
    - nous/traverse
    - nous/crystallize-theoria
    - nous/call-praxis

  desmoi:
    - crystallized-in
    - inquires
    - answers
    - waypoint-of
    - depends-on

  attainments:
    - crystallize
    - inquire
    - journey
    - synthesize

depends_on:
  - manteia
  - politeia
  - demiurge
```

---

## Validation

At bootstrap, manifests are validated for:

| Check | Error |
|-------|-------|
| Format version recognized | `Unknown format_version: X` |
| topos_id matches directory | `topos_id 'X' doesn't match directory 'Y'` |
| dependencies exist | `Topos 'X' depends on 'Y' which doesn't exist` |
| no circular dependencies | `Circular dependency: a → b → c → a` |
| content_paths exist | `Content path 'X' doesn't exist in topos 'Y'` |

---

## Version History

### 2.1 (Current)

- Added `content_paths` for explicit content discovery
- Added `topos_scale` for klimax positioning
- Added `surfaces_provided` / `surfaces_consumed`
- Structured `provides` section

### 2.0

- Added `content_roots` for provenance tracking
- Added `sourced-from` bond creation

### 1.0

- Initial manifest format
- Basic metadata and dependencies

---

## See Also

- [Genesis Overview](../../explanation/genesis/index.md)
- [Directory Conventions](directory-conventions.md)
- [Create a Topos](../../tutorial/foundations/create-a-topos.md)
