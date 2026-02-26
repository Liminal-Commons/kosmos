# How to: Take a Note

Take a note — mark something as worthy of attention.

A note captures attention: "this matters for later interpretation."
It can reference an entity, or stand alone as an observation.

---

## When to Use

Use this praxis when:
- You observe something worth remembering
- You want to mark an entity as significant
- You're building toward an insight but not ready to crystallize

---

## Parameters

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `content` | string | yes | What was noted |
| `reason` | string | no | Why this matters (optional context) |
| `kind` | string | no | Note kind: observation, question, concern, insight, todo (default: "observation") |
| `about` | string | no | Entity ID this note is about |

---

## Example

```yaml
oikos/take-note:
  content: "The reconciler pattern appears across all supervised entities"
  reason: "This might be a meta-pattern worth crystallizing"
  kind: "observation"
  about: "theoria/reconciler-pattern"
```

---

## What Happens

1. Defaults `kind` to "observation" if not provided
2. Generates a note ID from timestamp
3. Composes note entity via `typos-def-note`
4. Bonds note to dwelling oikos via `exists-in` (if `$_oikos` available)
5. Bonds note to author via `authored-by` (if `$_prosopon` available)
6. If `about` provided, creates `about` bond to referenced entity
7. Returns the note ID, content, and kind

---

## Requires

- **Attainment:** `attainment/reflect`

---

*Guide for the oikos/take-note praxis.*
