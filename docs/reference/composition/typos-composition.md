# Typos Reference (Composition Templates)

Schema reference for `eidos/typos` — the composition template system. For fill patterns and routing modes, see [Composition Guide](composition.md).

---

## Overview

A typos (τύπος, "mold/template") declares how to compose a cacheable artifact. The demiurge topos routes composition based on typos shape:

- `target_eidos` → entity composition (creates domain entity)
- `slots` + `template` → artifact composition (creates cached HTML/markdown)

```yaml
- eidos: typos
  id: typos/{name}
  data:
    name: string              # Required
    description: string       # Optional
    output_type: enum         # html, markdown, json, yaml
    slots: object             # Data sources with fill patterns
    template: string          # Template with variable interpolation
    defaults: object          # Optional defaults
    styles: string            # Optional scoped CSS
```

---

## Fields

### name
**Type:** `string` **Required:** Yes

```yaml
name: my-nodes-view
```

### output_type
**Type:** `enum` **Required:** Yes
**Values:** `html`, `markdown`, `json`, `yaml`, `text`

```yaml
output_type: html
```

### slots
**Type:** `object` **Required:** Yes

Named data sources with fill patterns.

```yaml
slots:
  nodes:
    fill: queried
    query: "gather(eidos: node, sort: name, order: asc)"
  services:
    fill: queried
    query: "gather(eidos: service-instance)"
  title:
    fill: literal
    value: "Infrastructure Status"
```

#### Gather Query Grammar

The `gather()` query supports these parameters:

```
gather(eidos: <type>, sort: <field>, order: asc|desc, limit: <n>)
```

| Parameter | Required | Description |
|-----------|----------|-------------|
| `eidos` | yes | Entity type to gather |
| `sort` | no | Data field name to sort by (e.g., `name`, `expressed_at`, `domain`) |
| `order` | no | `asc` (default) or `desc` |
| `limit` | no | Maximum results (default: 100) |

Examples:
- `gather(eidos: phasis, sort: expressed_at, order: asc)` — oldest first
- `gather(eidos: theoria, sort: domain, order: asc)` — alphabetical by domain
- `gather(eidos: oikos)` — no sort, default limit

#### Fill Patterns

| Pattern | Use | Example |
|---------|-----|---------|
| `literal` | Static value | `{ fill: literal, value: "Title" }` |
| `literal` | Praxis-updatable buffer | `{ fill: literal, default: "" }` — value comes from `_composition_inputs.inputs` |
| `queried` | Graph query (string) | `{ fill: queried, query: "gather(eidos: node)" }` |
| `queried` | Bond-based query (object) | `{ fill: queried, query: { bond: "fed-by-transcriber", field: "transcript" } }` |
| `composed` | Nested typos | `{ fill: composed, typos_id: "typos/child" }` |
| `generated` | LLM inference | `{ fill: generated, tier: fast, prompt: "..." }` |

#### Literal Fill via Praxis (Mutable Composition)

When a literal slot has no `value` but has a `default`, the actual value comes from the entity's `_composition_inputs.inputs` at compose time. Praxeis can update `_composition_inputs.inputs.<slot_name>` and then re-compose the entity to propagate the change:

```yaml
# Definition
slots:
  content:
    fill: literal
    default: ""
template: "{{ content }}"
```

```yaml
# Entity stores the current literal input
data:
  content: "Hello world"          # produced by composition
  _composition_inputs:
    typos_id: typos-def-accumulation
    inputs:
      content: "Hello world"      # the literal fill value
```

This pattern enables **mutable composition** — multiple sources (voice, keyboard, LLM) can update the literal input via praxeis, while composition remains one-way and deterministic. The content always flows: `_composition_inputs.inputs.content` → compose → `entity.data.content`.

#### Bond-Based Queried Slots

When `query` is an **object** (not a string), the slot resolves by tracing bonds from the entity being composed:

```yaml
slots:
  transcript:
    fill: queried
    query:
      bond: fed-by-transcriber    # desmos name to trace
      field: transcript            # field to read from bonded entity
    default: ""                    # fallback when no bond or field is empty
```

This pattern:
1. Traces bonds of type `bond` from the entity being composed
2. Finds the first bonded entity
3. Reads `field` from that entity's data
4. Falls back to `default` if no bond exists or field is absent

Bond-based queries also create `depends-on` bonds, enabling composition cascade — when the bonded entity changes, the composed entity recomposes automatically.

### template
**Type:** `string` **Required:** Yes

Template with variable interpolation. Kosmos uses simple `{{ variable }}` syntax with optional pipe filters.

> **Note:** Kosmos does NOT support Handlebars block helpers (`{{#each}}`, `{{#if}}`, `{{#unless}}`).
> For iteration and conditional rendering, embed slot data as JSON and render client-side.

```yaml
template: |
  <div class="dashboard">
    <h2>{{ title }}</h2>
    <div class="content" data-items="{{ items | json_encode }}"></div>
  </div>
```

#### Template Syntax

**Variables:**
```
{{ slot_name }}           # Slot value (simple)
{{ slot.field }}          # Nested property access
{{ slot | filter }}       # Value with pipe filter
```

**Available Pipe Filters:**
- `json_encode` — Serialize value to JSON string
- `yaml_encode` — Serialize value to YAML string
- `keys` — Get array of object keys
- `values` — Get array of object values
- `length` — Get length of array/string/object
- `join` — Join array elements (default: newline)
- `prefix` — Get part before last `/`
- `suffix` — Get part after last `/`

**Example with filters:**
```yaml
template: |
  <div data-nodes="{{ nodes | json_encode }}">
    Total: {{ nodes | length }} nodes
  </div>
```

#### Iteration Pattern (Client-Side)

Since kosmos templates don't support iteration, pass data as JSON and render with JavaScript:

```yaml
template: |
  <div class="list" data-items="{{ items | json_encode }}"></div>
  <script type="module">
    const container = document.querySelector('.list');
    const items = JSON.parse(container.dataset.items || '[]');
    container.innerHTML = items.map(item =>
      `<div class="card">${item.data?.name || item.id}</div>`
    ).join('');
  </script>
```

### styles
**Type:** `string` **Required:** No

Scoped CSS for the artifact.

```yaml
styles: |
  .dashboard { padding: 1rem; }
  .card {
    background: var(--bg-secondary);
    border-radius: 0.5rem;
  }
```

---

## Composition Flow

### 1. Call compose-cached

```yaml
- step: call
  praxis: demiurge/compose-cached
  params:
    typos_id: typos/my-nodes-view
    inputs: {}
  bind_to: result
```

### 2. Cache Check

Demiurge computes cache key: `hash(typos_id + slot_query_results)`

- **Cache hit** → Return existing artifact
- **Cache miss** → Execute slots → Apply template → Store artifact

### 3. Artifact Created

```yaml
- eidos: artifact
  id: artifact/{cache_key}
  data:
    typos_id: typos/my-nodes-view
    content: "<div class='dashboard'>..."
    cache_key: "blake3:abc123..."
    composed_at: "2026-02-04T12:00:00Z"
    stale: false
```

---

## Cache Invalidation

Artifacts track dependencies via `depends-on` bonds. When source entities change:

1. `demiurge/mark-dependents-stale` sets `stale: true`
2. Next `compose-cached` call recomposes
3. Fresh artifact replaces stale one

---

## Example: Infrastructure Dashboard

This example shows the recommended pattern: pass slot data as JSON and render client-side.

```yaml
entities:
  - eidos: typos
    id: typos/my-nodes-view
    data:
      name: my-nodes-view
      description: Infrastructure status dashboard
      output_type: html

      slots:
        nodes:
          fill: queried
          query: "gather(eidos: node, sort: name, order: asc)"
        services:
          fill: queried
          query: "gather(eidos: service-instance)"
        instances:
          fill: queried
          query: "gather(eidos: kosmos-instance)"

      template: |
        <div class="my-nodes-dashboard"
             data-nodes="{{ nodes | json_encode }}"
             data-services="{{ services | json_encode }}"
             data-instances="{{ instances | json_encode }}">
          <section class="nodes-section">
            <h2>Nodes</h2>
            <div class="entity-list" data-type="node"></div>
          </section>
          <section class="services-section">
            <h2>Services</h2>
            <div class="entity-list" data-type="service"></div>
          </section>
          <section class="connections-section">
            <h2>Connections</h2>
            <div class="entity-list" data-type="connection"></div>
          </section>
        </div>
        <script type="module">
          const dashboard = document.querySelector('.my-nodes-dashboard');
          if (dashboard) {
            const nodes = JSON.parse(dashboard.dataset.nodes || '[]');
            const services = JSON.parse(dashboard.dataset.services || '[]');
            const instances = JSON.parse(dashboard.dataset.instances || '[]');

            function renderCard(item, type) {
              const d = item.data || {};
              const status = d.status || 'unknown';
              return `<div class="${type}-card">
                <span class="status-dot status-${status}"></span>
                <div class="card-content">
                  <strong class="card-title">${d.name || item.id}</strong>
                </div>
              </div>`;
            }

            function renderList(container, items, type) {
              if (items.length === 0) {
                container.innerHTML = '<p class="empty-state">None registered</p>';
              } else {
                container.innerHTML = items.map(i => renderCard(i, type)).join('');
              }
            }

            renderList(dashboard.querySelector('[data-type="node"]'), nodes, 'node');
            renderList(dashboard.querySelector('[data-type="service"]'), services, 'service');
            renderList(dashboard.querySelector('[data-type="connection"]'), instances, 'connection');
          }
        </script>

      styles: |
        .my-nodes-dashboard {
          display: flex;
          flex-direction: column;
          gap: 2rem;
          padding: 1.5rem;
        }
        section h2 {
          font-size: 0.75rem;
          font-weight: 600;
          text-transform: uppercase;
          letter-spacing: 0.05em;
          color: var(--text-secondary);
          margin-bottom: 0.75rem;
        }
        .node-card, .service-card, .connection-card {
          display: flex;
          align-items: flex-start;
          gap: 0.75rem;
          padding: 1rem;
          background: var(--bg-secondary);
          border-radius: 0.5rem;
          margin-bottom: 0.5rem;
        }
        .status-dot {
          width: 10px;
          height: 10px;
          border-radius: 50%;
          flex-shrink: 0;
          margin-top: 0.25rem;
        }
        .status-online, .status-running {
          background: var(--color-success);
          box-shadow: 0 0 6px var(--color-success);
        }
        .status-offline, .status-stopped { background: var(--color-muted); }
        .status-error { background: var(--color-error); }
        .empty-state {
          color: var(--text-muted);
          font-style: italic;
          padding: 1rem;
          text-align: center;
        }
```

---

## Related

- [Artifact-Based Modes](../../explanation/presentation/artifact-based-modes.md) — When to use this pattern
- [Create Artifact Mode](../../how-to/presentation/create-artifact-mode.md) — Step-by-step guide
- [demiurge DESIGN.md](../../genesis/demiurge/DESIGN.md) — Composition architecture

---

*Reference for typos composition in kosmos.*
