# Emission Reference

*Ekthesis — bringing existence into actuality by writing to chora.*

---

## Overview

Emission (ekthesis) serializes entities from the kosmos graph and writes them to the filesystem. This is how the kosmos actualizes in chora — the receptacle receives what the kosmos orders.

Two operations:
- **Entity emission**: serialize an entity from the graph to a file
- **Content emission**: write arbitrary content to a file

Both are exposed via the `thyra/emit` MCP tool and the `emit` stoicheion (tier 3).

---

## API

### MCP Tool: `thyra_emit`

```json
{
  "entity_id": "theoria/my-insight",
  "path": "/Users/victor/output/insight.yaml",
  "format": "yaml"
}
```

Or with direct content:

```json
{
  "content": "# My Document\n\nContent here.",
  "path": "/Users/victor/output/doc.md"
}
```

### Emit Step (in praxeis)

```yaml
- step: emit
  entity_id: "$entity.id"
  path: "output/{{ $entity.id }}.yaml"
  format: yaml
```

---

## Formats

| Format | Serialization | Use Case |
|--------|--------------|----------|
| `yaml` | Full entity as YAML (`id`, `eidos`, `data`, `version`) | Genesis round-trip, backup |
| `json` | Full entity as pretty JSON | API integration, debugging |
| `markdown` | Human-readable heading + data fields | Documentation, reports |
| `text` | `data` field only (string or serialized) | Content extraction |

### YAML Format

```yaml
id: theoria/my-insight
eidos: theoria
data:
  insight: Understanding crystallized through dwelling
  domain: architecture
  status: active
version: 3
```

### JSON Format

```json
{
  "id": "theoria/my-insight",
  "eidos": "theoria",
  "data": {
    "insight": "Understanding crystallized through dwelling",
    "domain": "architecture",
    "status": "active"
  },
  "version": 3
}
```

### Markdown Format

```markdown
# theoria/my-insight

**Eidos:** theoria

## Data

- **domain:** architecture
- **status:** active

### insight

Understanding crystallized through dwelling

---
*Version: 3*
```

Markdown conversion rules:
- Single-line strings → `- **key:** value`
- Multi-line strings → `### key` heading + content block
- Arrays → bulleted list
- Objects → YAML code block
- Keys starting with `_` are skipped

### Text Format

Extracts the `data` field only:
- If `data` is a string → returns it directly
- If `data` is an object/array → pretty JSON serialization
- Falls back to full entity serialization

---

## File Path Handling

- **Absolute paths**: written as-is
- **Relative paths**: resolved against the current working directory
- **Parent directories**: created automatically if they don't exist

**Sidecar caveat**: When running as a Tauri sidecar, the cwd is `/` (the app bundle root). Relative paths will resolve against `/`, which is likely wrong. Use absolute paths or set the working directory explicitly.

---

## Full-Circle Genesis

The kosmos can emit itself, re-bootstrap from the emission, and emit again with identical output:

```
emit → bootstrap → emit = same BLAKE3 hash
```

This is the self-verifying coherence property. Constitutional content uses literal fill only. Derivable content is baked before emission.

---

*See [provenance-mechanism.md](provenance-mechanism.md) for how emission traces back to composition chains. See [authority-mechanism.md](authority-mechanism.md) for authorization requirements.*
