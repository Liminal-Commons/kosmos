# How to: Compose an Artifact

Compose an artifact from a typos definition.

Merges the definition's defaults with provided inputs,
then creates an entity with provenance.

Complexity is pushed to the caller:
- For queried values: caller queries first, passes result in inputs
- For generated values: caller calls infer first, passes result in inputs

---

## When to Use

Use this praxis when:
- You need to create an entity from a template
- You have a typos definition and want to instantiate it
- You're composing documentation, specs, or any structured output

---

## Parameters

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `typos_id` | string | yes | The typos definition to use (e.g., "typos-def-theoria") |
| `inputs` | object | no | Values to fill (overrides defaults from the definition) |
| `id` | string | no | Entity ID (generated if not provided) |
| `authorized_by` | string | no | Phasis ID that authorizes this composition (provenance root) |

---

## Example

```yaml
demiurge/compose:
  typos_id: typos-def-theoria
  inputs:
    insight: "Composition is fundamental"
    domain: "meta"
```

---

## What Happens

1. Finds the typos definition by `typos_id`
2. Merges definition `defaults` with provided `inputs`
3. Creates an entity of the definition's `target_eidos`
4. Creates all bonds declared in the definition's `bonds` array
5. Returns the composed entity

---

## Requires

- **Attainment:** `attainment/compose`

---

*Guide for the demiurge/compose praxis.*
