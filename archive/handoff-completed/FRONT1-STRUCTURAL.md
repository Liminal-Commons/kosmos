# Front 1: Structural Coherence

## Goal

Three surgical interventions that deepen individual topoi and create cross-cutting connections:
1. Body-schema integration declarations
2. Psyche-thyra boundary resolution
3. Example reconciler entities

## 1. Body-Schema Integration

**Problem:** Soma's `sense-body` should aggregate state from all topoi to give parousia self-awareness. Multiple topoi describe what they'd contribute, but the integration points aren't defined anywhere.

**What to do:** Define a `body-schema-contribution` pattern — each contributing topos declares what fields it adds to the body-schema. Then update soma's DESIGN.md and praxeis to reference these.

### Contributing topoi (read each DESIGN.md for context):

**ergon** (genesis/ergon/DESIGN.md):
```yaml
# Body-schema contribution
ergon:
  active_pragmas: 3
  stale_pragmas: 1
  active_daemons: 2
  pending_reflexes: 0
```

**nous** (genesis/nous/DESIGN.md):
```yaml
nous:
  active_journeys: 1
  pending_inquiries: 2
  theoria_count: 47
  recent_crystallizations: 3
```

**oikos** (genesis/oikos/DESIGN.md):
```yaml
oikos:
  session_duration: "2h 15m"
  notes_unprocessed: 5
  insights_uncrystallized: 3
```

**propylon** (genesis/propylon/DESIGN.md):
```yaml
propylon:
  pending_entries: 1
  active_sessions: 2
  expiring_links: 0
```

**dynamis** (genesis/dynamis/DESIGN.md):
```yaml
dynamis:
  deployments_healthy: 4
  deployments_degraded: 1
  reconciliation_pending: 0
```

**credentials** (genesis/credentials/DESIGN.md):
```yaml
credentials:
  unlocked: 3
  locked: 5
  expiring_soon: 1
```

**dokimasia** (genesis/dokimasia/DESIGN.md):
```yaml
dokimasia:
  pending_validations: 0
  recent_failures: 2
  provenance_issues: 1
```

### Actions:

1. Read `genesis/soma/praxeis/soma.yaml` — find the `sense-body` praxis
2. Add gathering steps that query each contributing topos (using `gather` with filters)
3. Add a `body_schema_contributions` section to soma's DESIGN.md documenting each topos's contribution
4. Create a `body-schema` render-spec in `genesis/soma/render-specs/body-schema-card.yaml` so the body-schema is visible through thyra

The render-spec should show a card with sections per topos, using badges for health indicators.

## 2. Psyche-Thyra Boundary Resolution

**Problem:** Psyche defines a `thyra` eidos (portal-entity) that semantically collides with the thyra topos. Psyche also has a `render-specs/thyra-card.yaml`. The boundary between "the experiencing self" (psyche) and "the rendering portal" (thyra) is blurred.

### Actions:

1. Read `genesis/psyche/eide/psyche.yaml` — find the `thyra` eidos definition
2. Read `genesis/psyche/render-specs/thyra-card.yaml` — understand what it renders
3. Read `genesis/thyra/eide/thyra.yaml` — understand thyra's own eide

**Decision to make:** Either:
- **Rename** psyche's `thyra` eidos to something like `portal-awareness` or `perceptual-field` (the psyche's awareness of its portal, not the portal itself)
- **Move** it to thyra if it's really about rendering configuration
- **Document** the distinction clearly if both are intentional (psyche's thyra = subjective portal experience; thyra topos = objective portal infrastructure)

Read both files and make the call based on what the fields describe. If the psyche thyra eidos has fields about subjective experience (attention, focus, engagement), rename it. If it has fields about rendering configuration, move it.

Also check: do any praxeis reference `eidos/thyra` ambiguously? Grep for references to resolve.

4. Update `genesis/psyche/DESIGN.md` (or create it — psyche only has REFERENCE.md) to clarify the boundary

## 3. Example Reconciler Entities

**Problem:** The reconciler pattern (sense → compare → act) is declared everywhere but no concrete reconciler entities exist. Adding examples shows the pattern in action and gives chora something to implement against.

### Actions:

Create reconciler entity definitions in these topoi:

**dynamis** — `genesis/dynamis/entities/reconcilers.yaml`:
```yaml
entities:
  - eidos: reconciler
    id: reconciler/deployment-health
    data:
      name: deployment-health
      description: |
        Senses deployment actuality vs desired state.
        Reconciles by restarting failed deployments or scaling to match intent.
      target_eidos: deployment
      sense_praxis: dynamis/sense-deployment
      reconcile_praxis: dynamis/reconcile-deployment
      interval: 60  # seconds
      enabled: true
```

**aither** — `genesis/aither/entities/reconcilers.yaml`:
```yaml
entities:
  - eidos: reconciler
    id: reconciler/syndesmos-reconnect
    data:
      name: syndesmos-reconnect
      description: |
        Senses syndesmos connection state. Reconnects with exponential
        backoff when connection intent exists but connection is dropped.
      target_eidos: syndesmos
      sense_praxis: aither/sense-syndesmos
      reconcile_praxis: aither/reconnect-syndesmos
      interval: 30
      backoff_max: 300
      enabled: true
```

**release** — `genesis/release/entities/reconcilers.yaml`:
```yaml
entities:
  - eidos: reconciler
    id: reconciler/release-distribution
    data:
      name: release-distribution
      description: |
        Verifies release artifacts exist at their distribution URLs.
        Reconciles by re-distributing missing artifacts.
      target_eidos: release
      sense_praxis: release/sense-release
      reconcile_praxis: release/reconcile-release
      interval: 300
      enabled: true
```

**dokimasia** — `genesis/dokimasia/entities/reconcilers.yaml`:
```yaml
entities:
  - eidos: reconciler
    id: reconciler/graph-integrity
    data:
      name: graph-integrity
      description: |
        Continuously validates graph integrity. Senses broken provenance
        chains, orphaned references, and schema drift.
      target_eidos: validation-result
      sense_praxis: dokimasia/validate-all-topoi
      reconcile_praxis: dokimasia/compose-validation-report
      interval: 3600
      enabled: true
```

Before creating these, read `genesis/ergon/eide/ergon.yaml` to confirm the reconciler eidos fields, and use the exact field names from the schema.

Also update each topos's `manifest.yaml` to add the reconciler entities path to `content_paths` if not already present.

## Verification

After all three interventions:
- `sense-body` praxis references all contributing topoi
- Soma has a body-schema render-spec
- Psyche's thyra eidos has a clear, non-colliding name or documented distinction
- 4 reconciler entities exist with correct eidos fields
- Each reconciler's manifest content_paths includes the entities file
