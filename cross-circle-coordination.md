# Cross-Circle Work Coordination

*Pragma and the discipline boundary between kosmos and chora.*

---

## Context

The two-repo workflow (K5) establishes a discipline boundary:

- **Chora repo**: Where the ground is laid (constitutional content, interpreter, substrate code)
- **Kosmos repo**: Where dwelling happens (composition, crystallization, oikos development)

When working purely through kosmos (no code access), gaps are encountered that require chora work. Currently there's no mechanism for this signal to flow — it lives in conversation, notes, or memory.

This proposal introduces **pragma** (πρᾶγμα — "thing to be done") as the coordination primitive between circles.

---

## The Problem

**Scenario**: You're in the kosmos repo, working through Claude Code as thyra.

```
You: "crystallize this theoria about discipline boundaries"
Claude: [invokes nous/crystallize-theoria]
Claude: [praxis fails at compose step — "missing field definition_id"]
Claude: "There's a gap in the composition infrastructure."
```

Now what? The gap requires chora work (fixing the interpreter), but:
- You can't fix it here (no code access — that's the discipline)
- You need to signal this to your chora-context self
- You want the signal to persist and be trackable

---

## The Solution: Pragma

### Core Eidos

```yaml
eidos/pragma:
  name: pragma
  description: |
    πρᾶγμα — a thing to be done.

    A gap, issue, or work item that signals between circles. Created
    where the gap is discovered, resolved where the capability exists.

    Pragma flow across the discipline boundary:
    - Kosmos circle creates pragma (discovery)
    - Chora circle accepts and resolves (capability)
    - Resolution propagates back via shared graph

  constitutional: false

  fields:
    title:
      type: string
      required: true
      description: "Short description of the gap"

    description:
      type: string
      required: true
      description: "Full context — what you were trying to do, what failed"

    context:
      type: string
      required: false
      description: "The situation when gap was encountered"

    status:
      type: enum
      values: [open, accepted, in_progress, resolved, declined, blocked]
      required: true
      default: open

    priority:
      type: enum
      values: [critical, high, normal, low]
      required: false
      default: normal
      description: "How urgent — critical blocks work, low is nice-to-have"

    resolution:
      type: string
      required: false
      description: "How the pragma was resolved (filled when status=resolved)"

    created_at:
      type: timestamp
      required: true

    resolved_at:
      type: timestamp
      required: false
```

### Desmoi

```yaml
desmos/signals-to:
  name: signals-to
  description: |
    Pragma signals to a circle for attention.
    The target circle is where the capability exists to resolve it.
  from_eidos: pragma
  to_eidos: circle
  symmetric: false

desmos/evidenced-by:
  name: evidenced-by
  description: |
    Pragma is evidenced by an entity — the thing that demonstrates the gap.
    Could be a failed theoria, an error entity, a composition that didn't work.
  from_eidos: pragma
  to_eidos: "*"  # Any entity can be evidence
  symmetric: false

desmos/blocks:
  name: blocks
  description: |
    Pragma blocks another pragma — dependency relationship.
    If A blocks B, B cannot be resolved until A is resolved.
  from_eidos: pragma
  to_eidos: pragma
  symmetric: false

desmos/resolves:
  name: resolves
  description: |
    Entity resolves a pragma — the fix, commit, or change that addressed it.
    Provides traceability from gap to resolution.
  from_eidos: "*"
  to_eidos: pragma
  symmetric: false
```

---

## Praxeis

### Creating Pragma

```yaml
praxis/ergon/create-pragma:
  name: create-pragma
  oikos: ergon
  description: |
    Create a pragma and signal it to a target circle.

    Use this when you encounter a gap that requires work in another
    context (e.g., kosmos work discovers a gap needing chora work).

  params:
    - name: title
      type: string
      required: true
      description: "Short description of the gap"

    - name: description
      type: string
      required: true
      description: "Full context"

    - name: target_circle_id
      type: string
      required: true
      description: "Circle to signal (e.g., circle/chora-dev)"

    - name: context
      type: string
      required: false
      description: "What you were doing when gap was found"

    - name: priority
      type: enum
      required: false
      default: normal

    - name: evidence_ids
      type: array
      required: false
      description: "Entity IDs that demonstrate the gap"

  steps:
    - step: compose
      typos_id: typos-def-pragma
      inputs:
        title: "$title"
        description: "$description"
        context: "$context"
        priority: "$priority"
        status: open
      bind_to: pragma

    - step: bind
      from_id: "$pragma.id"
      to_id: "$target_circle_id"
      desmos: signals-to

    - step: switch
      cases:
        - when: "$evidence_ids"
          then:
            - step: for_each
              items: "$evidence_ids"
              item_var: evidence_id
              steps:
                - step: bind
                  from_id: "$pragma.id"
                  to_id: "$evidence_id"
                  desmos: evidenced-by

    - step: return
      value:
        pragma_id: "$pragma.id"
        title: "$title"
        signaled_to: "$target_circle_id"
        status: open
```

### Listing Pragma

```yaml
praxis/ergon/list-pragma:
  name: list-pragma
  oikos: ergon
  description: |
    List pragma signaled to a circle.

    Use to see what work items are waiting for attention.

  params:
    - name: circle_id
      type: string
      required: false
      description: "Circle to check (defaults to dwelling circle)"

    - name: status
      type: string
      required: false
      description: "Filter by status (open, accepted, etc.)"

  steps:
    - step: set
      bindings:
        target_circle: "$circle_id"

    - step: switch
      cases:
        - when: "not $target_circle"
          then:
            - step: set
              bindings:
                target_circle: "$_circle"

    - step: trace
      to_id: "$target_circle"
      desmos: signals-to
      resolve: from
      bind_to: all_pragma

    - step: switch
      cases:
        - when: "$status"
          then:
            - step: filter
              items: "$all_pragma"
              condition: "item.data.status == '$status'"
              bind_to: filtered_pragma
            - step: return
              value:
                circle_id: "$target_circle"
                pragma: "$filtered_pragma"
                count: "{{ $filtered_pragma | length }}"

    - step: return
      value:
        circle_id: "$target_circle"
        pragma: "$all_pragma"
        count: "{{ $all_pragma | length }}"
```

### Accepting Pragma

```yaml
praxis/ergon/accept-pragma:
  name: accept-pragma
  oikos: ergon
  description: |
    Accept ownership of a pragma.

    Signals that work will be done to resolve it.

  params:
    - name: pragma_id
      type: string
      required: true

  steps:
    - step: find
      id: "$pragma_id"
      bind_to: pragma

    - step: assert
      condition: "$pragma"
      message: "Pragma not found: $pragma_id"

    - step: assert
      condition: "$pragma.data.status == 'open'"
      message: "Pragma is not open (status: $pragma.data.status)"

    # Update status (would need an update stoicheion or re-arise pattern)
    - step: set
      bindings:
        updated_data:
          title: "$pragma.data.title"
          description: "$pragma.data.description"
          context: "$pragma.data.context"
          priority: "$pragma.data.priority"
          status: accepted
          created_at: "$pragma.data.created_at"

    # For now, return intent — actual update needs interpreter support
    - step: return
      value:
        pragma_id: "$pragma_id"
        previous_status: "$pragma.data.status"
        new_status: accepted
        note: "Status update requires entity mutation support"
```

### Resolving Pragma

```yaml
praxis/ergon/resolve-pragma:
  name: resolve-pragma
  oikos: ergon
  description: |
    Mark a pragma as resolved.

    Include the resolution description — what was done to address it.
    Optionally link to the resolving entity (commit, fix, etc.).

  params:
    - name: pragma_id
      type: string
      required: true

    - name: resolution
      type: string
      required: true
      description: "What was done to resolve it"

    - name: resolving_entity_id
      type: string
      required: false
      description: "Entity that resolves this (commit, theoria, etc.)"

  steps:
    - step: find
      id: "$pragma_id"
      bind_to: pragma

    - step: assert
      condition: "$pragma"
      message: "Pragma not found: $pragma_id"

    - step: switch
      cases:
        - when: "$resolving_entity_id"
          then:
            - step: bind
              from_id: "$resolving_entity_id"
              to_id: "$pragma_id"
              desmos: resolves

    - step: return
      value:
        pragma_id: "$pragma_id"
        resolution: "$resolution"
        resolved_by: "$resolving_entity_id"
        status: resolved
        note: "Full resolution requires entity mutation support"
```

---

## The Flow

### Discovery (Kosmos Circle)

```
You (via Claude Code thyra) in kosmos repo:

1. Attempt work: "crystallize theoria about X"
2. Encounter gap: compose step fails
3. Create pragma:

   ergon/create-pragma
     title: "compose step fails with 'missing field definition_id'"
     description: "crystallize-theoria praxis fails at compose step..."
     target_circle_id: "circle/chora-dev"
     context: "Attempting to crystallize theoria about discipline boundaries"
     priority: high
     evidence_ids: ["theoria/entity-composition-gaps"]

4. Pragma created, signaled to chora-dev
5. Continue other work (gap is tracked, not lost)
```

### Resolution (Chora Circle)

```
You (via Claude Code thyra) in chora repo:

1. Check pragma: "what's waiting?"

   ergon/list-pragma
     circle_id: "circle/chora-dev"
     status: open

   → [pragma/compose-step-definition-id-error: high priority]

2. Accept: "I'll work on that"

   ergon/accept-pragma
     pragma_id: "pragma/compose-step-definition-id-error"

3. Investigate and fix (actual code work in chora)

4. Resolve:

   ergon/resolve-pragma
     pragma_id: "pragma/compose-step-definition-id-error"
     resolution: "Fixed typos_id resolution in compose step - was looking for definition_id field instead of typos_id"
```

### Continuation (Back in Kosmos)

```
You (via Claude Code thyra) in kosmos repo:

1. Check pragma status (same kosmos.db, status updated)
2. Re-attempt: "crystallize theoria about X"
3. Success — gap is closed
```

---

## Implementation Notes

### Entity Mutation

The accept/resolve praxeis need entity mutation (updating status field). Options:

1. **Re-arise pattern**: Arise new version with updated fields, deprecate old
2. **Update stoicheion**: Add `update` stoicheion for field mutation
3. **Status as bond**: Model status transitions as bonds rather than field changes

Recommend option 2 or 3 for cleaner semantics.

### Shared Database

For the flow to work seamlessly:
- Both repos must use the same kosmos.db (or sync via phoreta)
- Or: pragma are exported/imported between circle instances

If separate instances:
```
kosmos repo                    chora repo
    │                              │
    ├─ create pragma ─────────────►│
    │  (export as phoreta)         │
    │                              ├─ import, accept, resolve
    │◄─────────────────────────────┤
    │  (import resolution)         │
```

### Oikos Placement

Pragma coordination could live in:
- **ergon** (work) — new oikos focused on work items and coordination
- **politeia** — extends governance with work signaling
- **hypostasis** — extends federation with pragma exchange

Recommend **ergon** as a focused oikos for work coordination.

---

## Relation to Existing Patterns

| Existing | Purpose | How Pragma Differs |
|----------|---------|-------------------|
| `invitation` | Membership request (join circle) | Pragma is work request (do thing) |
| `theoria` | Crystallized understanding | Pragma is actionable gap |
| `phoreta` | Content bundle for sync | Pragma could travel in phoreta |
| `syndesmos` | Circle federation link | Pragma flows over syndesmos |

Pragma is **the work coordination layer** on top of the federation layer.

---

## Theoria

**T25: The two-repo workflow is not just architecture — it's a discipline boundary**

Chora is where the ground is laid (constitutional content, interpreter, substrate). Kosmos is where dwelling happens (composition, crystallization, oikos development). Keeping these separate enforces the pattern that work flows through kosmos, not around it. When the code is not available, the temptation to patch at the implementation level dissolves — you must work through the praxeis, compose through definitions, and crystallize gaps as theoria rather than fixing them as code.

**T26: Gaps should flow, not disappear**

When dwelling in kosmos encounters a gap requiring chora work, that gap must become an entity — visible, trackable, bondable. Pragma is the eidos for gaps that cross the discipline boundary. Creating pragma instead of "just noting it" means the gap persists, can be prioritized, and resolution is traceable.

**T27: Same animus, multiple thyrai**

Claude Code is thyra, not animus. One Victor, one animus, multiple interfaces. The pragma flow works because it's the same dweller moving between contexts, not separate agents trying to coordinate. The discipline boundary is between circles (kosmos vs chora), not between animuses.

---

## Open Questions

1. **Priority vs blocking**: Should pragma support blocking relationships (A blocks B)?
2. **Auto-detection**: Could the system auto-create pragma when praxeis fail?
3. **Notification**: How does the chora-context know pragma are waiting?
4. **Pragma lifecycle**: Archive resolved pragma, or keep for audit trail?

---

## Next Steps

1. Define `typos-def-pragma` artifact definition
2. Create ergon oikos with manifest
3. Implement core praxeis (create, list, accept, resolve)
4. Test flow between two contexts using shared kosmos.db
5. Extend with blocking, auto-detection as needed

---

*Drafted 2026-01-27 — from conversation about cross-circle coordination and discipline boundaries*
