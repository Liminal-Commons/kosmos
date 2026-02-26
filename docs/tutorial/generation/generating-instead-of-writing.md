# Tutorial: Generating Instead of Writing

Learn to use the generative spiral — generate definitions instead of writing them by hand.

---

## What You'll Learn

- How to generate a render-spec for an entity type
- How the generation pipeline works (inference context, governed inference, evaluation)
- How theoria informs future generations
- How to review and actualize generated artifacts

---

## Prerequisites

- Completed [Your First Praxis](../foundations/first-praxis.md)
- A running kosmos with the `demiurge` and `manteia` topoi loaded
- An `ANTHROPIC_API_KEY` environment variable set (generation requires LLM inference)

---

## Step 1: Find an Entity Without a Render-Spec

Let's check what entity types exist and which ones already have render-specs:

```yaml
# Gather all eide
nous/gather:
  eidos: eidos

# Gather all render-specs
nous/gather:
  eidos: render-spec
```

Look for an eidos that doesn't have a corresponding render-spec. For this tutorial, we'll generate a card for the `note` eidos.

---

## Step 2: Invoke the Generator

```yaml
demiurge/generate-render-spec:
  eidos_name: "note"
  variant: "card"
  purpose: "Display a note with content, kind badge, and creation time"
```

The generator does several things before calling the LLM:

1. **Finds the eidos** — looks up `eidos/note` to get its field definitions
2. **Gathers examples** — finds existing render-specs with `variant: card` to use as patterns
3. **Surfaces theoria** — searches for relevant understanding about notes, rendering, or the oikos domain
4. **Composes inference context** — builds a constrained prompt with widget vocabulary, binding rules, and the eidos fields

---

## Step 3: Understand the Response

The generator returns:

```json
{
  "artifact": {
    "id": "artifact/render-spec-note-card",
    "eidos": "artifact",
    "data": {
      "content": { ... }
    }
  },
  "render_spec": {
    "id": "render-spec/note-card",
    "data": {
      "name": "note-card",
      "target_eidos": "note",
      "variant": "card",
      "layout": [
        {
          "widget": "card",
          "props": { "variant": "bordered", "padding": "sm" },
          "children": [
            {
              "widget": "row",
              "props": { "gap": "sm", "align": "center" },
              "children": [
                { "widget": "badge", "props": { "content": "{kind}" } },
                { "widget": "text", "props": { "content": "{content}", "variant": "body" } }
              ]
            }
          ]
        }
      ]
    }
  },
  "verdict": "TRUE"
}
```

**Key fields:**
- `artifact` — the generated content wrapped with provenance
- `render_spec` — the actual render-spec that would be created
- `verdict` — `TRUE` means all evaluation criteria passed

---

## Step 4: Read the Verdict

The generation was evaluated against four criteria:

| Criterion | What It Checks |
|-----------|---------------|
| `widget_validity` | Only known widget types used |
| `binding_correctness` | `{field}` syntax for render-time bindings |
| `field_coverage` | Important entity fields are rendered |
| `variant_match` | Follows card variant conventions |

If the verdict is `FALSE`, read the `guidance` field — it explains what failed and suggests fixes. You can regenerate with a more specific `purpose` string.

---

## Step 5: Actualize the Render-Spec

Once you're satisfied with the generation, actualize it:

```yaml
demiurge/actualize-render-spec:
  artifact_id: "artifact/render-spec-note-card"
```

This creates:
- A real `render-spec/note-card` entity in the kosmos
- A `composed-from` bond linking it to the artifact (provenance)

The render-spec is now live — any mode referencing `render-spec/note-card` will use it.

---

## Step 6: Use in a Mode

Reference the generated render-spec in a collection mode:

```yaml
- eidos: mode
  id: mode/notes-list
  data:
    name: notes-list
    topos: oikos
    item_spec_id: render-spec/note-card
    arrangement: scroll
    source_query: "gather(eidos: note, sort: created_at, order: desc)"
    spatial:
      position: center
      height: fill
```

---

## What Just Happened

You experienced the **generative spiral**:

```
Intent (purpose string)
    ↓
Context (eidos fields, examples, theoria)
    ↓
Governed Inference (schema-constrained LLM)
    ↓
Evaluation (domain-specific criteria)
    ↓
Artifact (reviewable, with provenance)
    ↓
Actualization (promoted to live entity)
```

The generation was:
- **Schema-constrained** — the LLM output must match the render-spec JSON schema
- **Example-informed** — existing render-specs provided patterns
- **Theoria-informed** — accumulated understanding about the domain was surfaced
- **Evaluated** — criteria checked the result before you saw it
- **Provenance-tracked** — the artifact records what informed it

---

## Try It Yourself

Generate render-specs for other eide:

```yaml
# A detail view for theoria
demiurge/generate-render-spec:
  eidos_name: "theoria"
  variant: "detail"
  purpose: "Full view of a theoria with insight, domain, status, and evidence"

# A list-item for sessions
demiurge/generate-render-spec:
  eidos_name: "session"
  variant: "list-item"
  purpose: "Compact session card showing status and open time"
```

Each generation accumulates understanding. As you crystallize theoria about what makes good render-specs, future generations draw on that understanding.

---

## See Also

- [Use Generation](../../how-to/composition/use-generation.md) — Task reference for all generators
- [Compose an Artifact](../../how-to/composition/compose-artifact.md) — Manual composition
- [Create a Mode](../presentation/create-a-mode.md) — Using render-specs in modes

---

*You've generated your first definition. The spiral accumulates — each generation builds on the last.*
