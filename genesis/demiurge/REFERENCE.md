<!-- =============================================================================
<!-- GENERATED FILE - DO NOT EDIT DIRECTLY -->
<!-- =============================================================================
<!-- Emitted by: emit_cycle (demiurge/emit-genesis) -->
<!-- Source: genesis/demiurge/REFERENCE.md -->
<!-- -->
<!-- To modify: -->
<!--   1. Edit the source in genesis/ -->
<!--   2. Re-run emit-genesis -->
<!-- -->
<!-- See: genesis/EXTENDING.md -->
<!-- =============================================================================

# Demiurge Reference

the craftsman, the compositor.

---

## Eide (Entity Types)

### artifact

A composed artifact — result of template/graph rendering

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `cache_key` | string |  | Content-addressed cache key (hash of definition_id + inputs) |
| `composed_at` | timestamp | ✓ |  |
| `content` | any | ✓ |  |
| `definition_id` | string | ✓ |  |
| `inputs` | object |  |  |
| `stale` | boolean |  | Whether artifact is stale due to dependency changes |

### artifact-definition

A definition for composing things. Shape determines routing:

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `bonds` | array |  | Bonds to create during composition |
| `defaults` | object |  | Default values for slots/template variables |
| `description` | string |  | What this definition composes and when to use it |
| `name` | string | ✓ | Human-readable name for this definition |
| `output_type` | enum: text, object |  | For graph composition — output format (text or object) |
| `slots` | object |  | For graph composition — named slots to fill. |
| `target_eidos` | string |  | For entity composition — the eidos to instantiate (e.g., 'theoria') |
| `template` | string |  | For template rendering — template with {{ $variable }} interpolation |

## Praxeis (Operations)

🔧 = Exposed as MCP tool

### bake-oikos 🔧

Bake an oikos-dev into frozen content ready for signing.

**Tier:** 3 | **ID:** `praxis/demiurge/bake-oikos`

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `oikos_dev_id` | string | ✓ | The oikos-dev entity to bake |
| `authorized_by` | string | ✓ | Expression ID that authorizes this bake (for manteia calls) |
| `target_locale` | string |  | BCP 47 locale code (e.g., "en-US", "zh-CN", "ar-SA"). |

### bind-dependencies 🔧

Bind multiple dependencies to an artifact.

**Tier:** 2 | **ID:** `praxis/demiurge/bind-dependencies`

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `artifact_id` | string | ✓ | The artifact that has dependencies |
| `dependency_ids` | array | ✓ | Entity IDs the artifact depends on |

### bootstrap-single-stream

Bootstrap kosmos from single-stream genesis format.

**Tier:** 3 | **ID:** `praxis/demiurge/bootstrap-single-stream`

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `genesis_path` | string | ✓ | Path to genesis directory containing manifest.yaml |

### check-cache 🔧

Check if an artifact exists in cache for given definition + inputs.

**Tier:** 1 | **ID:** `praxis/demiurge/check-cache`

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `definition_id` | string | ✓ | The artifact definition |
| `inputs` | object |  | The inputs to check |

### compose 🔧

Compose from a definition — the single interface.

**Tier:** 2 | **ID:** `praxis/demiurge/compose`

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `definition_id` | string | ✓ | The artifact definition to compose from |
| `inputs` | object |  | Values to fill (overrides defaults) |
| `id` | string |  | Entity ID (only for entity composition, generated if not provided) |
| `authorized_by` | string |  | Expression ID that authorizes this composition (provenance root) |

### compose-all-oikoi-dev 🔧

Compose oikos-dev packages for all genesis oikoi.

**Tier:** 3 | **ID:** `praxis/demiurge/compose-all-oikoi-dev`

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `distribution` | string |  | Distribution mode for all packages (default: binary-only) |

### compose-cached 🔧

Compose with content-addressed caching.

**Tier:** 2 | **ID:** `praxis/demiurge/compose-cached`

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `definition_id` | string | ✓ | The artifact definition to compose from |
| `inputs` | object |  | Values to fill (overrides defaults) |
| `authorized_by` | string |  | Expression ID that authorizes this composition |
| `force_refresh` | boolean |  | Force re-composition even if cached |

### compose-definition-indexed 🔧

Generate and index an artifact definition.

**Tier:** 3 | **ID:** `praxis/demiurge/compose-definition-indexed`

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `name` | string | ✓ | Name for the artifact definition |
| `purpose` | string | ✓ | What this definition composes (detailed description) |
| `target_eidos` | string |  | For entity composition - the eidos to compose |
| `context` | string |  | Additional context (surfaced definitions, etc.) |
| `authorized_by` | string |  | Expression ID that authorizes this composition |

### compose-indexed 🔧

Compose an artifact and index it for semantic search.

**Tier:** 2 | **ID:** `praxis/demiurge/compose-indexed`

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `definition_id` | string | ✓ | The artifact definition to compose from |
| `inputs` | object |  | Values to fill (overrides defaults) |
| `id` | string |  | Entity ID (generated if not provided) |
| `index_text` | string |  | Text to index (derived from result if not provided) |
| `authorized_by` | string |  | Expression ID that authorizes this composition |

### compose-oikos-dev 🔧

Compose an oikos-dev package from a genesis oikos.

**Tier:** 2 | **ID:** `praxis/demiurge/compose-oikos-dev`

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `oikos_id` | string | ✓ | The oikos to package (e.g., "nous", "demiurge", "politeia") |
| `version` | string |  | Version override (defaults to manifest version) |
| `description` | string |  | Description override (defaults to oikos description) |
| `distribution` | string |  | Distribution mode: generative-commons, binary-only, or private (default: binary-only) |

### emit-genesis 🔧

Emit all genesis content to filesystem for full-circle verification.

**Tier:** 3 | **ID:** `praxis/demiurge/emit-genesis`

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `output_path` | string | ✓ | Base directory path for emitted content (e.g., "./chora-output") |
| `include_oikoi` | boolean |  | Include loaded oikoi in emission (default true) |
| `dry_run` | boolean |  | Compute hash without emitting files (default false) |

### emit-single-stream 🔧

Emit kosmos in single-stream genesis format.

**Tier:** 3 | **ID:** `praxis/demiurge/emit-single-stream`

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `output_path` | string | ✓ | Base directory path for emitted content (e.g., "./genesis-output") |
| `dry_run` | boolean |  | Compute structure without writing files (default false) |

### fork-oikos 🔧

Fork an oikos-dev to create a derived version.

**Tier:** 3 | **ID:** `praxis/demiurge/fork-oikos`

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `source_oikos_dev_id` | string | ✓ | The generative-commons oikos-dev to fork |
| `fork_name` | string | ✓ | Name for the forked oikos (becomes new oikos_id) |
| `fork_version` | string |  | Version for the fork (defaults to "0.1.0") |

### generate-domain-definitions 🔧

Generate multiple artifact definitions for a domain with surfaced context.

**Tier:** 3 | **ID:** `praxis/demiurge/generate-domain-definitions`

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `domain` | string | ✓ | Domain name for surfacing context (e.g., "user management", "document editing") |
| `entity_specs` | array | ✓ | Array of entity specifications to generate definitions for. |
| `surface_limit` | number |  | How many existing definitions to surface as context (default 10) |
| `authorized_by` | string |  | Expression ID that authorizes generation |

### invalidate-artifact 🔧

Mark a specific artifact as stale.

**Tier:** 2 | **ID:** `praxis/demiurge/invalidate-artifact`

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `artifact_id` | string | ✓ | The artifact to invalidate |

### list-generative-commons 🔧

List all oikos-dev packages marked as generative-commons.

**Tier:** 2 | **ID:** `praxis/demiurge/list-generative-commons`

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `limit` | integer |  | Maximum results (default 50) |

### list-oikos-derivations 🔧

List all oikos-dev packages derived from a given source.

**Tier:** 2 | **ID:** `praxis/demiurge/list-oikos-derivations`

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `source_oikos_dev_id` | string | ✓ | The source oikos-dev to find derivations of |

### list-stale-artifacts 🔧

List all artifacts marked as stale.

**Tier:** 1 | **ID:** `praxis/demiurge/list-stale-artifacts`

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `limit` | number |  | Maximum results (default 50) |

### mark-dependents-stale 🔧

Mark all artifacts that depend on an entity as stale.

**Tier:** 2 | **ID:** `praxis/demiurge/mark-dependents-stale`

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `entity_id` | string | ✓ | The entity that changed |

### publish-oikos 🔧

Publish an oikos-dev as oikos-prod.

**Tier:** 3 | **ID:** `praxis/demiurge/publish-oikos`

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `oikos_dev_id` | string | ✓ | The oikos-dev to publish |
| `mnemonic` | string | ✓ | BIP-39 mnemonic for signing |
| `circle_id` | string | ✓ | Circle context for key derivation |
| `authorized_by` | string | ✓ | Expression that authorizes this publication |
| `attestation` | string |  | Optional attestation message from publisher |
| `target_locale` | string |  | BCP 47 locale code for bake-time i18n (e.g., "en-US", "zh-CN"). |

### publish-oikos-multilocale 🔧

Publish an oikos-dev to multiple locales in one operation.

**Tier:** 3 | **ID:** `praxis/demiurge/publish-oikos-multilocale`

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `oikos_dev_id` | string | ✓ | The oikos-dev to publish |
| `target_locales` | array | ✓ | Array of BCP 47 locale codes to publish (e.g., ["en-US", "zh-CN", "ar-SA"]). |
| `mnemonic` | string | ✓ | BIP-39 mnemonic for signing |
| `circle_id` | string | ✓ | Circle context for key derivation |
| `authorized_by` | string | ✓ | Expression that authorizes this publication |
| `attestation` | string |  | Optional attestation message from publisher |

### refresh-stale 🔧

Recompose a stale artifact using its stored definition and inputs.

**Tier:** 2 | **ID:** `praxis/demiurge/refresh-stale`

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `artifact_id` | string | ✓ | The stale artifact to refresh |

### set-distribution-mode 🔧

Set the distribution mode of an oikos-dev.

**Tier:** 2 | **ID:** `praxis/demiurge/set-distribution-mode`

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `oikos_dev_id` | string | ✓ | The oikos-dev to update |
| `distribution` | string | ✓ | Distribution mode: generative-commons, binary-only, or private |

### verify-full-circle 🔧

Verify full-circle genesis by comparing two emission hashes.

**Tier:** 3 | **ID:** `praxis/demiurge/verify-full-circle`

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `hash_a` | string | ✓ | First emission hash (from emit-genesis) |
| `hash_b` | string | ✓ | Second emission hash (from emit-genesis after re-bootstrap) |

### verify-oikos 🔧

Verify an oikos-prod package.

**Tier:** 2 | **ID:** `praxis/demiurge/verify-oikos`

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `oikos_prod_id` | string | ✓ | The oikos-prod to verify |

## Desmoi (Bond Types)

| Desmos | From → To | Description |
|--------|-----------|-------------|
| `attests-to` | publish-attestation → oikos-prod | Publish attestation attests to a production oikos. |
| `authorized-by` | * → * | Provenance chain — this was authorized by that |
| `baked-from` | oikos-prod → oikos-dev | Production oikos was baked from a development oikos. |
| `composed-from` | * → * | Entity was composed from this artifact-definition |
| `depends-on` | any → any | Artifact depends on entity. Used for cache invalidation. Also used for journey dependencies. |
| `derives-from` | expression → any | Expression derives from stream or artifact. Provenance. |
| `packages` | oikos-dev → oikos | An oikos-dev packages a source oikos. This bond tracks which |
| `published-by` | oikos-prod → persona | Production oikos was published by a persona. |

---

*Generated from schema definitions. Do not edit directly.*
