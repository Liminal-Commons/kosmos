# Tutorial: Create a Topos

Learn to create a new domain package in genesis by building a simple topos from scratch.

---

## What You'll Build

A `greetings` topos that:
- Defines a `greeting` entity type
- Provides a `greet` praxis (MCP tool)
- Tracks greetings with bonds

---

## Prerequisites

- Understanding of YAML syntax
- Familiarity with [Genesis Overview](../../explanation/genesis/index.md)
- Access to the kosmos repository

---

## Step 1: Create the Directory Structure

Create the topos directory with required files:

```bash
mkdir -p genesis/greetings/{eide,desmoi,praxeis,typos}
touch genesis/greetings/manifest.yaml
touch genesis/greetings/DESIGN.md
touch genesis/greetings/eide/greetings.yaml
touch genesis/greetings/praxeis/greetings.yaml
touch genesis/greetings/typos/greetings.yaml
```

Your structure should look like:

```
genesis/greetings/
├── manifest.yaml
├── DESIGN.md
├── eide/
│   └── greetings.yaml
├── praxeis/
│   └── greetings.yaml
└── typos/
    └── greetings.yaml
```

---

## Step 2: Write the Manifest

The manifest declares what your topos provides. Create `manifest.yaml`:

```yaml
format_version: "2.1"
topos_id: greetings
version: "0.1.0"

topos_name: "Greetings"
topos_description: |
  A simple topos for greeting entities.
  Demonstrates basic topos patterns.

topos_scale: cross-scale
topos_category: domain

# Content locations
content_paths:
  - path: eide/
    content_types: [eidos]
  - path: praxeis/
    content_types: [praxis]
  - path: typos/
    content_types: [typos]

# Substrate requirements (minimal)
requires_dynamis:
  - db.find
  - db.arise
  - db.bind
  - db.gather

# What this topos provides
provides:
  eide:
    - greeting
  praxeis:
    - greetings/greet
    - greetings/list-greetings

# No dependencies for this simple topos
depends_on: []
```

Key fields:
- `topos_id`: Unique identifier (matches directory name)
- `content_paths`: Where bootstrap finds your content
- `requires_dynamis`: Substrate capabilities needed (`domain.operation` format)
- `provides`: What you're exposing

---

## Step 3: Write the Design Document

Every topos needs a `DESIGN.md` explaining its purpose:

```markdown
# Greetings Topos

## Purpose

A demonstration topos for learning genesis patterns.

## Gap Addressed

Provides a minimal example of topos structure for tutorials.

## Core Entities

### greeting

A greeting message with recipient and content.

**Fields:**
- `recipient` (string, required) — Who receives the greeting
- `message` (string, required) — The greeting content
- `created_at` (datetime) — When created

## Lifecycle

1. User invokes `greet` praxis
2. Greeting entity is composed via typos-def-greeting
3. Greeting is bonded to the current oikos

## Oikos Context

Greetings belong to the oikos where they're created.
```

---

## Step 4: Define the Entity Type

Define your `greeting` eidos in `eide/greetings.yaml`:

```yaml
entities:
  - eidos: eidos
    id: eidos/greeting
    data:
      name: greeting
      description: "A greeting message"
      fields:
        recipient:
          type: string
          required: true
          description: "Who receives the greeting"
        message:
          type: string
          required: true
          description: "The greeting content"
        created_at:
          type: datetime
          description: "When the greeting was created"
```

This defines:
- The type name (`greeting`)
- Required fields with types
- Field descriptions for documentation

---

## Step 5: Write the Praxeis

Define operations in `praxeis/greetings.yaml`:

```yaml
entities:
  # Greet praxis - creates a greeting
  - eidos: praxis
    id: praxis/greetings/greet
    data:
      topos: greetings
      name: greet
      visible: true
      description: |
        Create a greeting for someone.
      params:
        - name: recipient
          type: string
          required: true
          description: "Who to greet"
        - name: message
          type: string
          required: false
          description: "Custom message (default: 'Hello!')"
      steps:
        # Set default message if not provided
        - step: set
          bindings:
            greeting_message: "$message"

        - step: switch
          cases:
            - when: "$greeting_message"
              then: []
          default:
            - step: set
              bindings:
                greeting_message: "Hello!"

        # Compose the greeting entity
        - step: compose
          typos_id: typos-def-greeting
          inputs:
            recipient: "$recipient"
            message: "$greeting_message"
          bind_to: greeting

        # Return the created greeting
        - step: return
          value: "$greeting"

  # List greetings praxis
  - eidos: praxis
    id: praxis/greetings/list-greetings
    data:
      topos: greetings
      name: list-greetings
      visible: true
      description: |
        List all greetings in the current context.
      params:
        - name: recipient
          type: string
          required: false
          description: "Filter by recipient"
      steps:
        # Gather all greeting entities
        - step: gather
          eidos: greeting
          bind_to: all_greetings

        # Filter if recipient provided
        - step: switch
          cases:
            - when: "$recipient"
              then:
                - step: filter
                  items: "$all_greetings"
                  condition: "$item.data.recipient == '$recipient'"
                  bind_to: result
          default:
            - step: set
              bindings:
                result: "$all_greetings"

        - step: return
          value: "$result"
```

Key patterns:
- `visible: true` exposes the praxis as an MCP tool
- Steps use stoicheia (`set`, `compose`, `gather`, etc.)
- Variables are bound with `bind_to` and referenced with `$name`
- `set` uses a `bindings` map of variable names to values
- `switch` evaluates cases in order with `when`/`then`, falling through to `default`

---

## Step 6: Add a Typos Definition

Your `compose` step references `typos-def-greeting`. Create `typos/greetings.yaml`:

```yaml
entities:
  - eidos: typos
    id: typos-def-greeting
    data:
      name: greeting
      description: |
        Compose a greeting entity.
      target_eidos: greeting
      defaults:
        message: "Hello!"
      bonds:
        # Greeting exists in the current oikos (visibility bond)
        - desmos: exists-in
          from_self: true
          to_context: _oikos
          optional: true
```

The typos definition declares:
- `target_eidos`: What entity type gets created
- `defaults`: Default field values (overridden by inputs)
- `bonds`: Relationships created automatically — `to_context: _oikos` bonds the greeting to the dwelling oikos

When `compose` runs, it:
1. Creates an entity of type `target_eidos`
2. Applies `defaults` for any fields not in `inputs`
3. Overlays `inputs` from the praxis
4. Creates all declared `bonds`

---

## Step 7: Validate Your Topos

Run bootstrap to validate:

```bash
just dev
```

If successful, you'll see your praxeis loaded. If errors occur, check:
- YAML syntax (indentation, colons)
- Step names match stoicheia exactly
- All referenced types exist

---

## Step 8: Test Your Praxis

In Claude (via MCP), you can now use:

```
Use tool: greetings_greet
Parameters: { "recipient": "World" }
```

Expected result:
```json
{
  "id": "greeting/...",
  "eidos": "greeting",
  "data": {
    "recipient": "World",
    "message": "Hello!",
    "created_at": "2024-..."
  }
}
```

---

## Common Mistakes

### Wrong step name

```yaml
# Wrong
- step: each
  items: "$items"

# Correct
- step: for_each
  items: "$items"
```

### Missing bind_to

```yaml
# Wrong - result is lost
- step: find
  id: "$some_id"

# Correct
- step: find
  id: "$some_id"
  bind_to: entity
```

### Using arise instead of compose

```yaml
# Wrong - bypasses composition
- step: arise
  eidos: greeting
  data: { ... }

# Correct - uses composition
- step: compose
  typos_id: typos-def-greeting
  inputs: { ... }
```

### Using name/value instead of bindings

```yaml
# Wrong - old syntax
- step: set
  name: my_var
  value: "$something"

# Correct
- step: set
  bindings:
    my_var: "$something"
```

---

## Next Steps

- Add bonds to relate greetings to other entities
- Add more praxeis for update/delete operations
- Create render-specs for UI display
- Add reflexes for reactive behavior

---

## See Also

- [Genesis Overview](../../explanation/genesis/index.md) — Understanding the layer
- [Topos Development](../../how-to/topos-development/topos-development.md) — Practical recipes
- [Manifest Schema](../../reference/genesis/manifest-schema.md) — Field reference
- [The Five Archai](../../explanation/genesis/archai.md) — Foundational forms

---

*You've created your first topos. Now make it do something interesting.*
