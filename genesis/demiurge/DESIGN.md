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

### compose

The single composition interface. Routes based on definition shape.

- **When:** Any creation act
- **Requires:** compose attainment
- **Provides:** Entity with provenance, or rendered content

### compose-cached

Content-addressed cached composition.

- **When:** Expensive compositions that may be repeated
- **Requires:** compose attainment
- **Provides:** Artifact from cache or fresh composition

### compose-indexed

Compose and index for semantic search.

- **When:** Artifacts that should be surfaceable
- **Requires:** compose attainment
- **Provides:** Indexed, searchable artifact

### compose-definition-indexed

Generate and index an artifact definition.

- **When:** Creating new composition patterns via inference
- **Requires:** generate-definitions attainment
- **Provides:** New typos entity, indexed for discovery

### generate-domain-definitions

Generate multiple artifact definitions with surfaced context.

- **When:** Bootstrapping a domain with coherent definitions
- **Requires:** generate-definitions attainment
- **Provides:** Multiple indexed definitions building on existing patterns

### bind-dependencies / mark-dependents-stale / invalidate-artifact / list-stale-artifacts / refresh-stale

Dependency management for cache invalidation.

- **When:** Tracking what needs recomposition when sources change
- **Requires:** compose attainment
- **Provides:** Staleness propagation through artifact graph

### compose-oikos-dev / compose-all-oikoi-dev

Package oikoi from genesis source.

- **When:** Preparing oikos for baking and distribution
- **Requires:** oikos-develop attainment
- **Provides:** oikos-dev entity with gathered content

### bake-oikos

Resolve generation specs in an oikos-dev.

- **When:** Preparing for publication (localization, generation resolution)
- **Requires:** oikos-bake attainment
- **Provides:** Baked content with all specs resolved to literals

### publish-oikos / publish-oikos-multilocale

Sign and publish oikos-prod packages.

- **When:** Releasing packages for distribution
- **Requires:** oikos-publish attainment, signing capability
- **Provides:** Signed oikos-prod with attestation

### verify-oikos

Verify oikos-prod integrity.

- **When:** Validating received packages
- **Requires:** None (read-only verification)
- **Provides:** Validity status, hash verification

### set-distribution-mode

Change distribution mode of oikos-dev.

- **When:** Sharing as generative-commons vs binary-only
- **Requires:** oikos-develop attainment
- **Provides:** Updated distribution policy

### fork-oikos

Fork a generative-commons package.

- **When:** Creating derivative oikos with local adaptations
- **Requires:** oikos-fork attainment
- **Provides:** New oikos-dev with derives-from bond

### list-generative-commons / list-oikos-derivations

Query available commons and fork lineages.

- **When:** Discovering forkable packages
- **Requires:** oikos-fork attainment (for list-generative-commons)
- **Provides:** Available packages, derivation trees

### emit-genesis / emit-single-stream / verify-full-circle

Full-circle genesis emission and verification.

- **When:** Backup, recovery, verification, audit
- **Requires:** genesis-emit attainment
- **Provides:** Emitted files, content hash, verification result

## Attainments

### attainment/compose

Core composition capability — the fundamental demiurge act.

- **Grants:** compose, compose-cached, check-cache, compose-indexed, bind-dependencies, mark-dependents-stale, invalidate-artifact, list-stale-artifacts, refresh-stale
- **Scope:** circle
- **Rationale:** Composition is the basic creation act; dependency management follows from it

### attainment/generate-definitions

Definition generation capability — creating composition patterns via inference.

- **Grants:** compose-definition-indexed, generate-domain-definitions
- **Scope:** circle
- **Rationale:** Tier-3 inference operations require explicit authorization

### attainment/oikos-develop

Package development capability — creating oikos-dev packages.

- **Grants:** compose-oikos-dev, compose-all-oikoi-dev, set-distribution-mode
- **Scope:** circle
- **Rationale:** Packaging for distribution is a governance-level act

### attainment/oikos-bake

Generation resolution capability — baking oikos for publication.

- **Grants:** bake-oikos
- **Scope:** circle
- **Rationale:** Baking involves inference; separate from development

### attainment/oikos-publish

Package publishing capability — signing and releasing oikos-prod.

- **Grants:** publish-oikos, verify-oikos, publish-oikos-multilocale
- **Scope:** circle
- **Rationale:** Publication affects others; requires signing authority

### attainment/oikos-fork

Commons forking capability — deriving from generative-commons.

- **Grants:** fork-oikos, list-generative-commons, list-oikos-derivations
- **Scope:** circle
- **Rationale:** Forking creates derivatives with attribution bonds

### attainment/genesis-emit

Genesis emission capability — full-circle verification.

- **Grants:** emit-genesis, verify-full-circle, emit-single-stream
- **Scope:** circle
- **Rationale:** Genesis emission is a powerful audit/recovery operation

## Embodiment

### Completeness Status

| Level | Status |
|-------|--------|
| Defined | ✅ typos, artifact, 9 desmoi, 24 praxeis |
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
  oikos_packages:
    draft: 2
    ready_to_publish: 1
    published: 5
```

This reveals composition capacity and pending refresh work.

### Reconciler

A demiurge reconciler would surface:

- **Stale artifacts** — "3 artifacts need refresh after dependency changes"
- **Pending publications** — "oikos-dev/mypackage-1.0.0 is ready to publish"
- **Missing definitions** — "No typos found for common patterns in this context"
- **Orphaned artifacts** — "12 artifacts have no depends-on bonds (unreachable for invalidation)"

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

## Future Extensions

### Automatic Invalidation Hooks

Currently manual: call mark-dependents-stale when sources change. Future: trigger invalidation automatically on entity update.

### Composition Metrics

Track composition frequency, cache hit rates, staleness duration. Surface in body-schema for capacity planning.

### Cross-Circle Composition

Current: composition happens in dwelling circle context. Future: compose-for-circle allowing authorized composition into another circle's graph.

### Streaming Composition

Current: compose returns complete result. Future: compose-stream for large artifacts with progress reporting.

---

*Composed in service of the kosmogonia.*
*The demiurge makes. The definition specifies. The provenance traces.*
