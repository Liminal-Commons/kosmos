# Artifact-Based Modes

*Why composed artifacts are the foundation of mode rendering.*

---

## Two Approaches to Mode Rendering

Modes can render content through two patterns:

| Pattern | Data Flow | Caching | Complexity |
|---------|-----------|---------|------------|
| **Live-query** | Query → Render-spec → Widgets | None | High (panels, render-specs, widgets) |
| **Artifact-based** | Compose → Cache → Render | Content-addressed | Low (definition + template) |

Live-query rendering re-executes queries and re-renders widgets on every view. Artifact-based rendering composes once, caches, and serves until invalidated.

---

## The Artifact Pattern

An artifact is composed content with provenance:

```
Artifact Definition    →    Compose    →    Artifact Entity    →    Render
  (what to query)         (execute)        (cached content)       (display)
  (how to format)
```

### Composition Flow

```
1. Request artifact by definition ID
2. Check cache (content hash of source entities)
3. Cache hit? → Return cached artifact
4. Cache miss? → Execute queries → Apply template → Cache → Return
```

### Cache Invalidation

Artifacts declare their source entity types:

```yaml
cache_key_sources:
  - node
  - service-instance
```

When any entity of these types changes, the cache key changes, triggering recomposition on next request.

---

## Why Artifacts?

### Simplicity

Live-query requires:
- Layout with regions
- Panels positioned in regions
- Render-specs for each panel
- Widget trees with bindings
- Query execution in Layout Engine

Artifact-based requires:
- Artifact definition (queries + template)
- Artifact widget (display)

### Performance

Composition happens once. Subsequent requests serve cached content. For read-heavy views (dashboards, status pages), this is significantly faster.

### Composability

Artifacts can include other artifacts via nested `composed` slots:

```yaml
slots:
  node_status:
    fill: composed
    typos_id: typos/node-status
  service_health:
    fill: composed
    typos_id: typos/service-health
template: |
  <div class="dashboard">
    {{ node_status }}
    {{ service_health }}
  </div>
```

### Emission Flexibility

The same artifact definition can emit to multiple formats:

```yaml
output_formats:
  - html      # For Thyra rendering
  - markdown  # For documentation
  - json      # For API consumption
```

---

## When to Use Each Pattern

### Use Live-Query When:
- Content is highly interactive (selections, filters, real-time updates)
- Different users see different data (personalization)
- Widgets need event handlers (buttons, forms)

### Use Artifacts When:
- Content is read-mostly (dashboards, status views)
- Same content shown to all viewers
- Content can be cached between views
- You want to emit to multiple formats

---

## The Hybrid Approach

Modes can combine both patterns:

```yaml
# Layout with artifact panel + interactive panel
regions:
  - kind: main
    name: artifact-view    # Composed artifact
  - kind: contextual
    name: live-controls    # Live-query for interactions
```

The artifact provides the primary view; live panels handle interactions that modify the underlying entities (which invalidates the artifact cache).

---

## Grounding

This pattern emerges from core principles:

- **Composition-only**: Artifacts are composed from definitions, not hand-crafted
- **Cache-driven**: Same inputs = same hash = cached result
- **Schema-driven**: Definitions declare structure; composition executes it

Artifacts are the natural extension of "everything is composed" to mode rendering.

---

*Understanding crystallized from mode development exploration.*
