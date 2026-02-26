# Topos Directory Convention — Decomposing the entities/ Grab Bag

*Prompt for Claude Code in the kosmos repository context.*

*Establishes the standard directory structure for topoi by extracting element types from the heterogeneous `entities/` directory into dedicated directories. After this work, every constituent element type lives in a directory named for its type, and `entities/` contains only domain-specific seed instances.*

---

## Architectural Principle — Directory = Element Type

Constituent element types are topos-defined (see PROMPT-GENERATIVE-SPIRAL.md § Context). The topoi that introduce element types into the vocabulary also define where instances of those types live:

| Introducing Topos | Element Type | Directory | Already Standard? |
|-------------------|-------------|-----------|-------------------|
| arche | eidos | `eide/` | Yes — all topoi |
| arche | desmos | `desmoi/` | Yes — most topoi |
| arche | praxis | `praxeis/` | Yes — all topoi |
| demiurge | typos | `typos/` | Yes — most topoi |
| thyra | render-spec | `render-specs/` | Yes — most topoi |
| ergon | reflex, trigger | `reflexes/` | thyra only |
| dynamis | reconciler | `reconcilers/` | dynamis only |
| dynamis | actuality-mode | `actuality-modes/` | dynamis, thyra |
| — | daemon | `daemons/` | nowhere |
| — | surface | `surfaces/` | nowhere |

The principle: **when a topos introduces an element type, instances of that type across all topoi get a directory named for the type.** The same way every topos puts eide in `eide/` and praxeis in `praxeis/`, every topos puts reflexes in `reflexes/`, reconcilers in `reconcilers/`, surfaces in `surfaces/`, and daemons in `daemons/`.

What remains in `entities/` is **domain-specific seed instances** — things that are instances of the topos's own eide, not instances of vocabulary introduced by other topoi. Examples: dokimasia's error-catalog, manteia's criteria, thyra's onboarding flow, politeia's mcp attainment.

---

## Current State — The Grab Bag

`entities/` currently holds wildly different things across topoi. The manifest `content_types` for `entities/` paths reveal the mess:

```
dynamis:    [render-spec, reflex, deployment, reconciler]
chora-dev:  [panel, render-spec, reflex, context-menu, command, navigation-item, command-template]
ergon:      [render-spec, reflex, trigger, entity-mutation, bond-mutation]
politeia:   [render-spec, attainment, renderer, reflex]
thyra:      [render-type, renderer, mode, thyra-config]
dokimasia:  [render-spec, reconciler, validation-error]
aither:     [render-spec, reflex, reconciler]
```

This means:
- You can't find all reflexes by looking in `reflexes/` — they're scattered in `entities/` across 13 topoi
- You can't find all reconcilers by looking in `reconcilers/` — dynamis has `reconcilers/` but dokimasia, aither, and release put theirs in `entities/`
- The generative spiral can't know where to emit a generated reflex without per-topos special-casing
- Manifest content_types are a heterogeneous list that doesn't help tooling

### Files to move

**reflexes.yaml** (13 topoi — move from `entities/` to `reflexes/`):
- agora, aither, chora-dev, demiurge, dokimasia, dynamis, ergon, nous, oikos, politeia, propylon, release, thyra

**surfaces.yaml** (8 topoi — move from `entities/` to `surfaces/`):
- aither, chora-dev, dynamis, ergon, genesis, logos, manteia, nous, thyra

**daemons.yaml** (4 topoi — move from `entities/` to `daemons/`):
- aither, dokimasia, dynamis, release, thyra

**reconcilers.yaml** (3 topoi — move from `entities/` to `reconcilers/`):
- aither, dokimasia, release (dynamis already has `reconcilers/`)

### Files that stay in entities/

These are domain-specific seed instances — they ARE the topos's own content, not cross-cutting infrastructure:

| Topos | File | Why It Stays |
|-------|------|-------------|
| dokimasia | error-catalog.yaml | Seed instances of validation-error eidos |
| manteia | criteria.yaml | Seed instances of evaluation-criterion eidos |
| ergon | event-types.yaml | Seed instances of trigger/mutation eidos |
| thyra | layout.yaml | Seed instances of mode + thyra-config eidos |
| thyra | onboarding.yaml | Seed instances of onboarding flow |
| thyra | artifact.yaml | Seed artifact entities |
| thyra | default-accumulation.yaml | Seed accumulation entity |
| thyra | presence-list.yaml | Seed presence widget entity |
| politeia | mcp.yaml | Seed attainment entity (attainment/mcp-essential) |
| soma | config.yaml | Seed mcp-bridge-config instance |
| my-nodes | layout.yaml | Seed layout entities |
| my-nodes | seed-nodes.yaml | Seed node instances |
| chora-dev | command-templates.yaml | Seed command template instances |
| chora-dev | commands.yaml | Seed command instances |
| chora-dev | ergon-integration.yaml | Seed ergon bridge entities |
| chora-dev | layout.yaml | Seed layout entities |
| dynamis | thyra-services.yaml | Seed service definitions |

### Edge cases

**render-specs in entities/**: Some manifests list `render-spec` as a content_type for `entities/`, but all actual render-spec files already live in `render-specs/`. These are stale manifest entries — the content_type should be removed from the entities/ path.

**chora-dev entities/render-specs.yaml**: If this file contains render-spec entities, it should move to `render-specs/`. If it contains something else, it stays.

---

## Convention — The Standard Topos Directory Structure

After this work, every topos follows this structure (directories present only when the topos has content of that type):

```
{topos}/
├── DESIGN.md              # Why this topos exists (prose)
├── REFERENCE.md            # How to use it (prose, optional)
├── manifest.yaml           # Contract with substrate
│
├── eide/                   # Entity type definitions (eidos)
├── desmoi/                 # Bond type definitions (desmos)
├── praxeis/                # Executable sequences (praxis)
├── typos/                  # Composition molds (typos)
│
├── render-specs/           # Widget trees (render-spec)
├── reflexes/               # Autonomic responses (reflex + trigger)
├── reconcilers/            # Drift rules (reconciler)
├── daemons/                # Periodic sensors (daemon)
├── surfaces/               # Capability contracts (surface)
├── actuality-modes/        # Substrate bridges (actuality-mode)
│
├── entities/               # Domain-specific seed instances ONLY
├── seeds/                  # Bootstrap seed entities (alternative to entities/)
│
└── {topos-specific}/       # Special dirs (journeys/, theoria/, patterns/, etc.)
```

### Manifest content_paths convention

Each directory gets its own content_path entry with a single content_type:

```yaml
content_paths:
  - path: eide/
    content_types: [eidos]
  - path: desmoi/
    content_types: [desmos]
  - path: praxeis/
    content_types: [praxis]
  - path: typos/
    content_types: [typos]
  - path: render-specs/
    content_types: [render-spec]
  - path: reflexes/
    content_types: [reflex]
  - path: reconcilers/
    content_types: [reconciler]
  - path: daemons/
    content_types: [daemon]
  - path: surfaces/
    content_types: [surface]
  - path: entities/
    content_types: [error-catalog]   # domain-specific only
```

One path, one content type. No more `[render-spec, reflex, deployment, reconciler]` grab bags.

---

## Implementation — Per-Topos Changes

### Clean break — no backward compatibility

- Files move to new directories. Old locations are deleted.
- Manifest content_paths are updated to reflect new locations.
- No symlinks, no aliases, no "also check entities/" fallback.
- If chora's bootstrap currently hardcodes `entities/` as a content discovery path, it should be updated to read from manifest content_paths exclusively (which it should already do per the spora restructuring).

### Topoi with reflexes to extract (13)

For each: `mkdir {topos}/reflexes/ && mv {topos}/entities/reflexes.yaml {topos}/reflexes/`

Then update manifest.yaml: remove `reflex` from entities/ content_types, add `reflexes/` content_path.

| Topos | reflexes.yaml | Notes |
|-------|--------------|-------|
| agora | reflexes.yaml | Only file in entities/ — entities/ can be removed |
| aither | reflexes.yaml | Also has daemons, reconcilers, surfaces to extract |
| chora-dev | reflexes.yaml | Also has surfaces to extract |
| demiurge | reflexes.yaml | Only file in entities/ — entities/ can be removed |
| dokimasia | reflexes.yaml | Also has daemons, reconcilers; error-catalog stays |
| dynamis | reflexes.yaml | Also has daemons, surfaces; reconcilers/ already exists; thyra-services stays |
| ergon | reflexes.yaml | Also has surfaces; event-types stays |
| nous | reflexes.yaml | Also has surfaces |
| oikos | reflexes.yaml | Only file in entities/ — entities/ can be removed |
| politeia | reflexes.yaml | mcp.yaml stays |
| propylon | reflexes.yaml | Only file in entities/ — entities/ can be removed |
| release | reflexes.yaml | Also has daemons, reconcilers |
| thyra | reflexes.yaml | Already has `reflexes/` dir — merge or reconcile |

**thyra special case**: thyra already has both `reflexes/` (directory) and `entities/reflexes.yaml`. Check whether these contain different content. If `reflexes/` already has the content, delete `entities/reflexes.yaml`. If they're different, merge into `reflexes/`.

### Topoi with surfaces to extract (9)

For each: `mkdir {topos}/surfaces/ && mv {topos}/entities/surfaces.yaml {topos}/surfaces/`

| Topos | surfaces.yaml |
|-------|--------------|
| aither | surfaces.yaml |
| chora-dev | surfaces.yaml |
| dynamis | surfaces.yaml |
| ergon | surfaces.yaml |
| genesis | surfaces.yaml |
| logos | surfaces.yaml |
| manteia | surfaces.yaml |
| nous | surfaces.yaml |
| thyra | surfaces.yaml |

### Topoi with daemons to extract (5)

For each: `mkdir {topos}/daemons/ && mv {topos}/entities/daemons.yaml {topos}/daemons/`

| Topos | daemons.yaml |
|-------|-------------|
| aither | daemons.yaml |
| dokimasia | daemons.yaml |
| dynamis | daemons.yaml |
| release | daemons.yaml |
| thyra | daemons.yaml |

### Topoi with reconcilers to extract (3)

For each: `mkdir {topos}/reconcilers/ && mv {topos}/entities/reconcilers.yaml {topos}/reconcilers/`

dynamis already has `reconcilers/` — check if `entities/reconcilers.yaml` is a duplicate or different content.

| Topos | reconcilers.yaml | Notes |
|-------|-----------------|-------|
| aither | reconcilers.yaml | New directory |
| dokimasia | reconcilers.yaml | New directory |
| release | reconcilers.yaml | New directory |

### Manifest content_types cleanup

After extraction, update each manifest to:
1. Remove extracted content_types from entities/ path
2. Add new content_path entries for each extracted directory
3. If entities/ has no remaining content_types, remove the entities/ content_path entirely
4. If entities/ retains domain-specific seed instances, update content_types to reflect only what remains

### Topoi where entities/ becomes empty (can be removed entirely)

After extracting all cross-cutting types:
- **agora** — only had reflexes.yaml
- **demiurge** — only had reflexes.yaml
- **oikos** — only had reflexes.yaml
- **propylon** — only had reflexes.yaml
- **credentials** — entities/ dir exists but is empty
- **ekdosis** — entities/ dir exists but is empty
- **hypostasis** — entities/ dir exists but is empty
- **psyche** — entities/ dir exists but is empty

---

## Verification

```bash
# 1. No reflex, surface, daemon, or reconciler files remain in entities/
find genesis/*/entities/ -name "reflexes.yaml" -o -name "surfaces.yaml" \
  -o -name "daemons.yaml" -o -name "reconcilers.yaml"
# Should return: empty

# 2. All reflexes are in reflexes/ directories
find genesis/ -name "reflexes.yaml" -path "*/reflexes/*" | wc -l
# Should be: 13 (or 12 if thyra merged)

# 3. No manifest content_path for entities/ lists cross-cutting types
grep -A1 'path: entities/' genesis/*/manifest.yaml | grep -E 'reflex|surface|daemon|reconciler'
# Should return: empty

# 4. Bootstrap succeeds
# (In chora) cargo build && cargo test

# 5. Every extracted directory has a corresponding manifest content_path
# (Manual check per topos)
```

---

## Files to Touch

### Kosmos (genesis) — per topos

For each of the ~20 affected topoi:
- Create new directories: `reflexes/`, `surfaces/`, `daemons/`, `reconcilers/` as needed
- Move files from `entities/` to appropriate directories
- Update `manifest.yaml` content_paths
- Remove empty `entities/` directories

### Chora (implementation) — if needed

- `crates/kosmos/src/bootstrap.rs` — verify content discovery uses manifest content_paths, not hardcoded `entities/` path. If it does hardcode, update it.
- Any tests that reference `entities/reflexes.yaml` paths directly

### PROMPT-GENERATIVE-SPIRAL.md

- Update § Smells to mark smell #1 as resolved
- Update § Current element types in practice table to show correct directories

---

## What This Enables

When every element type has its own directory:
- **The generative spiral knows where to emit** — generating a reflex? It goes in `reflexes/`. No per-topos special-casing.
- **Tooling can discover by type** — "find all reconcilers" = `find genesis/*/reconcilers/`. No parsing heterogeneous entities/ files.
- **Manifests are honest** — one path, one content type. The contract between topos and substrate is clear.
- **The topos review has a standard** — each topos can be evaluated against the same directory convention.
- **New topoi start clean** — the convention is the scaffold.
