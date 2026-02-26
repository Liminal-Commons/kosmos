# How to: Crystallize Theoria

Crystallize understanding into theoria.

Takes an insight and domain, composes a theoria entity
via `typos-def-theoria`, and optionally binds evidence entities.

Theoria arises as provisional — requires explicit promotion
to crystallized status.

---

## When to Use

Use this praxis when:
- You have a clear insight that should be preserved
- Understanding has stabilized enough to crystallize
- You want to create traceable knowledge with provenance

---

## Parameters

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `theoria_id` | string | yes | ID for the new theoria (e.g., "theoria/bonds-structure") |
| `insight` | string | yes | The core understanding, stated clearly |
| `domain` | string | yes | What area this applies to (e.g., "composition", "thyra", "meta") |
| `source` | string | no | How this understanding arose (default: "conversation") |
| `evidence` | array | no | Entity IDs that evidence this theoria |

---

## Example

```yaml
nous/crystallize-theoria:
  theoria_id: "theoria/composition-is-fundamental"
  insight: "Composition is fundamental — entities ARE composed artifacts"
  domain: "meta"
  source: "conversation"
  evidence:
    - "segment/abc123"
```

---

## What Happens

1. Defaults `source` to "conversation" if not provided
2. Composes a theoria entity via `typos-def-theoria` with status "provisional"
3. Bonds theoria to dwelling oikos via `crystallized-in` (if `$_oikos` available)
4. If `evidence` provided, creates `evidences` bonds from each evidence entity to the theoria
5. Indexes the theoria for semantic search (`surface` queries)
6. Emits a phasis announcing the crystallization
7. Returns the theoria ID, insight, domain, and status

---

## Requires

- **Attainment:** `attainment/crystallize`

---

*Guide for the nous/crystallize-theoria praxis.*
