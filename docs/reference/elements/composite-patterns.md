# Composite Patterns

*Named compositions of constituent elements that achieve user-meaningful purposes — the molecules of kosmos.*

---

## Overview

Composite patterns are recurring configurations of elements and bonds that solve common problems. They are not special entities — they are conventions for how to wire elements together. Recognizing them accelerates development: instead of inventing from scratch, compose a known pattern.

---

## Pattern Catalog

### Presentation Pair

**Purpose:** Make an entity visible in thyra.

**Elements composed:**
- `render-spec` — Declares the widget tree
- `mode` — Declares spatial position and data source
- `uses-render-spec` bond — Connects mode to render-spec

**Example:**
```yaml
# The render-spec declares what to show
- eidos: render-spec
  id: render-spec/note-card
  data:
    target_eidos: note
    variant: card
    layout:
      - widget: card
        children:
          - widget: heading
            props: { content: "{title}", level: 3 }
          - widget: text
            props: { content: "{body}" }

# The mode declares where it appears
- eidos: mode
  id: mode/nous/notes
  data:
    item_spec_id: render-spec/note-card
    source_query: "gather(eidos: note)"
    arrangement: scroll
    spatial: { position: center, height: fill }
```

**When to use:** Every time a topos needs to become visible. A topos without a presentation pair is invisible.

---

### Detection Pair

**Purpose:** React to graph mutations automatically.

**Elements composed:**
- `trigger` pattern — Specifies what event to detect
- `reflex` — Specifies what to do in response
- `triggered-by` bond — Connects reflex to trigger
- `responds-with` bond — Connects trigger to response praxis

**Example:**
```yaml
# Trigger: detect when a note is created
- eidos: reflex
  id: reflex/nous/index-new-notes
  data:
    trigger:
      event_type: entity_created
      conditions:
        - field: eidos
          operator: equals
          value: note
    response:
      praxis_id: nous/index-entity
      param_mapping:
        entity_id: "{entity_id}"
```

**When to use:** When a graph mutation should automatically invoke a praxis. The somatic nervous system of kosmos.

---

### Reconciliation Cycle

**Purpose:** Align intent with actuality through continuous sense-compare-act.

**Elements composed:**
- `trigger` — Detects entity state changes
- `reflex` — Responds by invoking reconciliation
- `reconciler` — Declares transition rules
- `mode` (infrastructure) — Bridges to substrate operations
- Bonds: `triggered-by`, `responds-with`, `requires-mode`

**Example:**
```yaml
# Reconciler: declares how to align deployment state
- eidos: reconciler
  id: reconciler/deployment
  data:
    target_eidos: deployment
    intent_field: desired_state
    actuality_field: actual_state
    transitions:
      - intent: running
        actual: absent
        action: manifest
      - intent: stopped
        actual: running
        action: unmanifest
      - intent: running
        actual: running
        action: none

# Reflex: triggers reconciliation on state change
- eidos: reflex
  id: reflex/dynamis/reconcile-deployments
  data:
    trigger:
      event_type: entity_updated
      conditions:
        - field: eidos
          operator: equals
          value: deployment
    response:
      praxis_id: dynamis/reconcile
```

**When to use:** When entities represent desired state that must be continuously aligned with substrate reality.

---

### Authorization Graph

**Purpose:** Graph-traversable access control.

**Elements composed:**
- `attainment` entities — Capabilities a parousia holds
- `grants-praxis` bonds — Connect attainment to permitted praxeis
- `requires-attainment` bonds — Gate praxeis behind attainments
- `has-attainment` bonds — Grant attainments to parousiai

**Flow:**
```
parousia → has-attainment → attainment → grants-praxis → praxis
praxis → requires-attainment → attainment
```

**When to use:** When praxeis should only be available to parousiai with specific capabilities. The authorization check traverses bonds — no special access control code needed.

---

### Generation Pipeline

**Purpose:** Produce constituent elements from intent via governed inference.

**Elements composed:**
- `typos-inference-*` — Inference context (composed from typos)
- `generate-*` praxis — Orchestrates composition → inference → validation
- `validate-*` praxis — Verifies output schema compliance
- `actualize-*` praxis — Creates entity from artifact

**Flow:**
```
generate-render-spec:
  1. Compose inference context (typos-inference-render-spec + inputs)
  2. governed-inference (LLM call with output_schema)
  3. validate-render-spec (structural checks)
  4. actualize-render-spec (create entity + bonds)
```

**When to use:** When new element instances should be generated from semantic intent rather than hand-authored.

---

## Cross-References

- [Constituent Elements](constituent-elements.md) — The atoms that compose into these patterns
- [Reconciliation Reference](../reactivity/reconciliation.md) — Full reconciler schema
- [Reactive System Reference](../reactivity/reactive-system-reference.md) — Trigger/reflex specification
- [Attainment Authorization](../authorization/attainment-authorization.md) — Authorization graph detail
