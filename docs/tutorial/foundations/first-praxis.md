# Tutorial: Your First Praxis

*A hands-on walkthrough of creating a praxis in the kosmos.*

---

## What You'll Learn

By the end of this tutorial, you will:
1. Understand the structure of a praxis definition
2. Create a new praxis from scratch
3. Test it via MCP tools
4. Understand how steps, bindings, and bonds work together

---

## Prerequisites

- Development environment running (`just dev` — cleans DB, syncs genesis, launches)
- MCP server running or Claude Code connected
- Familiarity with YAML syntax

---

## Step 1: Study an Existing Praxis

Before writing your own, let's examine `oikos/take-note` — a simple but complete praxis.

Open [genesis/oikos/praxeis/oikos.yaml](../../../genesis/oikos/praxeis/oikos.yaml) and find the `take-note` praxis:

```yaml
- eidos: praxis
  id: praxis/oikos/take-note
  bonds:
    - desmos: requires-attainment
      to: attainment/dwell
  data:
    topos: oikos
    name: take-note
    visible: true
    description: |
      Take a note about something.
      Notes mark something as worthy of attention.
    params:
      - name: content
        type: string
        required: true
        description: What is being noted
      - name: reason
        type: string
        required: false
        description: Why it matters
      - name: kind
        type: string
        required: false
        description: "Note kind: observation, question, concern, insight, todo"
      - name: about
        type: string
        required: false
        description: Entity ID this note is about
    steps:
      # ... steps follow
```

### Key Observations

1. **Eidos declaration**: `eidos: praxis` — this IS a praxis entity
2. **Semantic ID**: `praxis/oikos/take-note` — the pattern is `praxis/{topos}/{name}`
3. **Attainment bond**: `requires-attainment → attainment/dwell` — caller must be dwelling
4. **Metadata**: `topos`, `name`, `visible`, `description`
5. **Params**: Define what the caller can pass (name, type, required, description)
6. **Steps**: The actual logic — executed in sequence

---

## Step 2: Design Your Praxis

Let's create a praxis called `oikos/annotate` that creates a note specifically about an entity and bonds them together.

**Purpose**: Create an annotation note bonded to a target entity.

**Params**:
- `entity_id` (required) — The entity to annotate
- `content` (required) — The annotation text
- `kind` (optional) — Note kind (default: observation)

**Logic**:
1. Verify the target entity exists
2. Set default values
3. Create a note entity via compose
4. Bond the note to the target via `about`
5. Return the result

---

## Step 3: Write the Praxis YAML

Add this to `genesis/oikos/praxeis/oikos.yaml`:

```yaml
- eidos: praxis
  id: praxis/oikos/annotate
  bonds:
    - desmos: requires-attainment
      to: attainment/dwell
  data:
    topos: oikos
    name: annotate
    visible: true
    description: |
      Annotate an entity with a note.

      Creates a note bonded to the target entity via the `about` desmos.
      Useful for adding observations, questions, or insights about any entity.
    params:
      - name: entity_id
        type: string
        required: true
        description: The entity to annotate
      - name: content
        type: string
        required: true
        description: The annotation text
      - name: kind
        type: string
        required: false
        description: "Note kind: observation, question, concern, insight, todo (default: observation)"
    steps:
      # Step 1: Verify the target entity exists
      - step: find
        id: "$entity_id"
        bind_to: target_entity

      - step: assert
        condition: "$target_entity"
        message: "Entity not found: $entity_id"

      # Step 2: Set defaults
      - step: set
        bindings:
          note_id: "note/{{ now() }}"
          created_at: "now()"
          note_kind: "$kind"

      - step: switch
        cases:
          - when: "$note_kind"
            then: []
        default:
          - step: set
            bindings:
              note_kind: "observation"

      # Step 3: Create the note via compose
      - step: compose
        typos_id: "typos-def-note"
        inputs:
          id: "$note_id"
          content: "$content"
          kind: "$note_kind"
          created_at: "$created_at"
        bind_to: note_entity

      # Step 4: Bond note to target entity
      - step: bind
        from_id: "$note_id"
        to_id: "$entity_id"
        desmos: "about"

      # Step 5: Return result
      - step: return
        value:
          note_id: "$note_id"
          entity_id: "$entity_id"
          kind: "$note_kind"
          content: "$content"
```

---

## Step 4: Understand Each Step Type

### `find` — Retrieve Entity

```yaml
- step: find
  id: "$entity_id"      # Expression: value of entity_id param
  bind_to: target_entity # Store result in scope
```

Returns the entity or `null` if not found.

### `assert` — Validate Condition

```yaml
- step: assert
  condition: "$target_entity"  # Truthy check
  message: "Entity not found"  # Error message if false
```

Fails the praxis if condition is falsy.

### `set` — Bind Variables

```yaml
- step: set
  bindings:
    note_id: "note/{{ now() }}"  # Template with function
    created_at: "now()"           # Function call
    note_kind: "$kind"            # Copy from param
```

Binds values to names in scope. Templates use `{{ }}`, variables use `$`.

### `switch` — Conditional Logic

```yaml
- step: switch
  cases:
    - when: "$note_kind"  # If truthy...
      then: []             # ...do nothing (keep value)
  default:
    - step: set            # Otherwise set default
      bindings:
        note_kind: "observation"
```

Evaluates conditions in order, executes matching branch.

### `compose` — Create Entity

```yaml
- step: compose
  typos_id: "typos-def-note"   # Composition template
  inputs:                       # Values to fill
    id: "$note_id"
    content: "$content"
  bind_to: note_entity          # Store created entity
```

Creates an entity using a typos (composition template). The typos defines the target eidos and default bonds. This is THE way to create entities — never raw creation.

### `bind` — Create Bond

```yaml
- step: bind
  from_id: "$note_id"      # Source entity
  to_id: "$entity_id"      # Target entity
  desmos: "about"           # Bond type
```

Creates a typed relationship between entities.

### `return` — Return Result

```yaml
- step: return
  value:
    note_id: "$note_id"
    entity_id: "$entity_id"
```

Returns a value and terminates the praxis.

---

## Step 5: Bootstrap and Test

Re-bootstrap to load your new praxis:

```bash
just dev    # Cleans DB, syncs genesis, rebuilds, launches
```

Now test via MCP. The tool name is derived from the praxis: `praxis/oikos/annotate` becomes `oikos_annotate`.

```
oikos_annotate(
  entity_id: "oikos/kosmos",
  content: "This is the root dwelling oikos",
  kind: "observation"
)
```

Expected result:

```json
{
  "note_id": "note/1737475200000",
  "entity_id": "oikos/kosmos",
  "kind": "observation",
  "content": "This is the root dwelling oikos"
}
```

---

## Step 6: Verify the Bonds

Find your note by ID:

```
nous_find(id: "note/1737475200000")
```

Gather all notes:

```
nous_gather(eidos: "note")
```

Trace bonds from your note to see what it's about:

```
nous_trace(from_id: "note/1737475200000", desmos: "about")
```

---

## Context Variables

Praxeis have access to dwelling context — automatically available variables:

| Variable | Contains |
|----------|----------|
| `$_parousia` | The dwelling parousia (presence) |
| `$_prosopon` | The prosopon (person) behind the parousia |
| `$_oikos` | The oikos being dwelled in |
| `$_session` | The current session |

These are used for authorization, provenance, and context bonding.

---

## Common Patterns

### Pattern: Default Values

```yaml
- step: set
  bindings:
    my_value: "$param_with_default"

- step: switch
  cases:
    - when: "$my_value"
      then: []
  default:
    - step: set
      bindings:
        my_value: "default_value"
```

### Pattern: Conditional Bonding

```yaml
- step: switch
  cases:
    - when: "$_oikos"
      then:
        - step: bind
          from_id: "$new_entity_id"
          to_id: "$_oikos.id"
          desmos: "exists-in"
```

### Pattern: Call Another Praxis

```yaml
- step: call
  praxis: "nous/crystallize-theoria"
  params:
    insight: "$content"
    domain: "$domain"
  bind_to: theoria_result
```

---

## Troubleshooting

### "Entity not found"

The entity ID doesn't exist. Check:
- Is the ID correct?
- Has the entity been created?
- Do you have visibility (bond path) to it?

### "Praxis not found"

The praxis isn't loaded. Check:
- Is the YAML valid?
- Did you re-bootstrap (`just dev`)?
- Is the praxis ID correct?

### Expression not evaluating

Check your syntax:
- Variables: `$variable_name`
- Templates: `{{ function() }}`
- Nested access: `$entity.data.field`

---

## Next Steps

Now that you can create praxeis:

1. Study more complex examples in `genesis/oikos/praxeis/oikos.yaml`
2. Try creating a praxis with `gather` and `filter` steps
3. Explore the [Architecture Overview](../../architecture/overview.md)
4. Read [KOSMOGONIA.md](../../../genesis/KOSMOGONIA.md) for constitutional foundations

---

*Welcome to the kosmos. Prosopa dwell here.*
