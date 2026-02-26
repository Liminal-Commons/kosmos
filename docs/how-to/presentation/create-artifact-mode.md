# Create a Mode with the Artifact Widget

This guide shows how to create a mode that renders composed content using the artifact widget and demiurge composition infrastructure.

---

## Prerequisites

- Understanding of [Mode Development](mode-development.md)
- The demiurge topos (provides composition + caching)
- The thyra topos (provides artifact widget)

---

## Step 1: Create the Typos Definition

A typos declares what to query (slots) and how to structure the output.

### Option A: output_type: object (Recommended)

Returns slot data as structured objects. The artifact widget renders entity arrays as cards automatically.

```yaml
# genesis/my-topos/typos/my-view.yaml
entities:
  - eidos: typos
    id: typos/my-view
    data:
      name: my-view
      description: What this view shows
      output_type: object

      slots:
        items:
          fill: queried
          query: "gather(eidos: my-eidos)"
        related:
          fill: queried
          query: "gather(eidos: related-eidos)"
```

With `output_type: object`, the compose result is `{ items: [...], related: [...] }`. The artifact widget's `ObjectContent` renderer handles arrays of entities — showing `data.content` if present, falling back to JSON.

### Option B: output_type: html (Template-Based)

Returns rendered HTML. Use when you need custom layout.

> **Important:** Kosmos templates use `{{ variable }}` syntax with pipe filters. Block helpers like `{{#each}}`, `{{#if}}` are NOT supported. For iteration, pass data as JSON and render client-side.

```yaml
entities:
  - eidos: typos
    id: typos/my-view
    data:
      name: my-view
      description: What this view shows
      output_type: html

      slots:
        items:
          fill: queried
          query: "gather(eidos: my-eidos)"

      template: |
        <div class="my-view" data-items="{{ items | json_encode }}">
          <h2>My Items</h2>
          <div class="item-list"></div>
        </div>
        <script type="module">
          const view = document.querySelector('.my-view');
          const items = JSON.parse(view.dataset.items || '[]');
          const list = view.querySelector('.item-list');
          if (items.length === 0) {
            list.innerHTML = '<p class="empty">No items yet</p>';
          } else {
            list.innerHTML = items.map(item => `
              <div class="item-card">
                <strong>${item.data?.name || item.id}</strong>
                <span class="status-${item.data?.status || 'unknown'}">${item.data?.status || ''}</span>
              </div>
            `).join('');
          }
        </script>

      styles: |
        .my-view { padding: 1rem; }
        .item-card {
          padding: 0.75rem;
          background: var(--bg-secondary);
          border-radius: 0.5rem;
          margin-bottom: 0.5rem;
        }
        .status-online { color: var(--color-success); }
        .status-error { color: var(--color-error); }
        .empty { color: var(--text-muted); }
```

---

## Step 2: Create the Render-Spec

Create a render-spec that uses the artifact widget with your typos:

```yaml
# genesis/my-topos/render-specs/my-view.yaml
entities:
  - eidos: render-spec
    id: render-spec/my-view
    data:
      name: my-view
      description: Artifact-based dashboard
      variant: panel

      layout:
        - widget: artifact
          props:
            typos_id: typos/my-view
            watch_eidos: my-eidos    # Optional: recompose on entity changes
```

---

## Step 3: Create the Mode

Create a singleton mode that uses your render-spec:

```yaml
# genesis/my-topos/modes/my-view.yaml
entities:
  - eidos: mode
    id: mode/my-view
    data:
      name: my-view
      topos: my-topos
      description: Artifact-based view of my entities
      render_spec_id: render-spec/my-view
      spatial:
        position: center
        height: fill
```

---

## Step 4: Add to Thyra Config

```yaml
# In your thyra-config
active_modes:
  - mode/my-feed
  - mode/my-view          # Your new artifact mode
```

---

## How It Works

1. **Bootstrap** loads your typos, render-spec, and mode
2. **Layout Engine** finds the mode and its render-spec
3. **Render-spec** dispatches the `artifact` widget with `config.typos_id`
4. **Artifact widget** calls `demiurge/compose` with the typos_id
5. **Demiurge** executes slot queries and returns composed result
6. **Artifact widget** renders: string content as innerHTML, object content as entity cards
7. **Reactive updates** (if `watch_eidos` set): `onEntityChange` triggers recomposition

---

## Fill Patterns

| Pattern | Use Case | Example |
|---------|----------|---------|
| `literal` | Static values | `{ fill: literal, value: "Title" }` |
| `queried` | Graph queries | `{ fill: queried, query: "gather(eidos: node)" }` |
| `composed` | Nested typos | `{ fill: composed, typos_id: "typos/child" }` |
| `generated` | LLM inference | `{ fill: generated, prompt: "..." }` |

---

## Template Syntax

> Only relevant for `output_type: html`. Object mode skips templates entirely.

### Variables
```
{{ slot_name }}           # Slot value
{{ slot | filter }}       # Value with pipe filter
```

### Available Pipe Filters
- `json_encode` — Serialize to JSON
- `yaml_encode` — Serialize to YAML
- `keys` / `values` — Object key/value arrays
- `length` — Array/string/object length
- `join` — Join array (default: newline)
- `prefix` / `suffix` — Split on last `/`

---

## Testing

```bash
just dev    # Clean DB + sync genesis + start dev mode
```

---

## Debugging

**Artifact not rendering?**
- Check typos was bootstrapped: `nous/find` with `typos/my-view`
- Check render-spec has the artifact widget with correct `typos_id`
- Check browser console for `[artifact] Composition failed` errors

**Not updating reactively?**
- Verify `watch_eidos` is set in artifact widget props
- Check browser console for `onEntityChange` firing

**Empty results?**
- Verify source entities exist: `nous/gather` with the eidos
- Check slot query syntax matches: `gather(eidos: my-eidos)`

---

*Guide for creating modes that use the artifact widget for composed content.*
