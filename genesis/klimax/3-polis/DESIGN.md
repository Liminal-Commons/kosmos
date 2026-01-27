# Polis: Circles and Governance

*A design for collective organization and dwelling.*

---

## The Problem

Two requirements collide:

| Requirement | What It Means |
|-------------|---------------|
| **Visibility = Reachability** | You can only see what you can reach through bonds |
| **Dwelling context** | Praxeis need to know WHO is acting FROM WHERE |

V7 has no circles. No personas. No membership bonds. No dwelling context.

**Polis is where identities organize into collectives, and where dwelling becomes real.**

---

## Implementation Status

| Component | Status | Location |
|-----------|--------|----------|
| polis.yaml schema | ✓ Complete | `klimax/3-polis/polis.yaml` |
| Eide (circle, persona, principle, pattern) | ✓ Defined | polis.yaml |
| Artifact definitions | ✓ Defined | polis.yaml |
| Praxeis (create-circle, join-circle, etc.) | ✓ Defined | polis.yaml |
| Bootstrap entities | ✓ Complete | `spora/spora.yaml` — persona/victor, persona/claude, circle/kosmos, circle/victor-self |
| Dwelling context in interpreter | ✓ Complete | `scope.rs` — DwellingContext struct, _persona/_circle/_animus bindings |
| visible_to() function | ✓ Complete | `host.rs:348-390` — circle membership + public visibility |
| MCP integration | ✓ Complete | `kosmos-mcp-v8` — DwellingState tracking, arise/depart lifecycle |

**This layer is complete. Dwelling-aware surfacing (aisthesis Phase 3) is unblocked.**

---

## Grounding in the Kosmogonia

### Klimax Position

Polis is scale 3 of 6:
```
kosmos (1) → physis (2) → POLIS (3) → oikos (4) → soma (5) → psyche (6)
```

Polis establishes WHO can dwell WHERE. Lower scales (oikos, soma, psyche) operate within the social structure polis creates.

### Visibility = Reachability

From KOSMOGONIA.md:
> You can only perceive what you can cryptographically reach through the bond graph.

This means:
- An entity in a circle is visible to circle members
- Membership is a `member-of` bond
- Visibility is computed by tracing bonds, not by checking permissions

### The Dwelling Requirement

From KOSMOGONIA.md:
> Context is not passed. Context is position.
> When an animus dwells in a circle, the circle is the dwelling position.

This means:
- `_persona` and `_circle` are not parameters to praxeis
- They are derived from the caller's position in the bond graph
- Bonds flow from position automatically

---

## Architecture

### 1. Circle Kinds

Four kinds of circle, from intimate to open:

| Kind | Description | Example |
|------|-------------|---------|
| `self` | Personal circle (one persona) | Victor's private space |
| `intimate` | Close group (family, close friends) | Home circle |
| `community` | Larger group with shared purpose | A project team |
| `public` | Open to all | circle/kosmos (the root) |

Public circles are visible to everyone. Other circles require membership.

### 2. Persona Kinds

Four kinds of persona:

| Kind | Description |
|------|-------------|
| `human` | A human identity |
| `ai` | An AI identity (like Claude) |
| `collective` | A group acting as one |
| `system` | System/automated identity |

### 3. Core Bonds

| Desmos | From | To | Meaning |
|--------|------|-----|--------|
| `member-of` | persona | circle | Persona belongs to circle |
| `stewards` | persona | circle | Persona can govern circle |
| `adopts` | circle | principle | Circle committed to principle |

### 4. Dwelling Context

The interpreter scope will carry:

```rust
pub struct DwellingContext {
    pub persona_id: String,
    pub circle_id: String,
    pub animus_id: Option<String>,
}
```

Praxeis access these as `_persona`, `_circle`, `_animus`.

### 5. Visibility Function

```rust
fn visible_to(persona_id: &str, entity_id: &str) -> bool {
    // Get circles persona is member of
    let my_circles = trace_bonds(persona_id, None, "member-of");

    // Get circles entity belongs to
    let entity_circles = trace_bonds(entity_id, None, "belongs-to");

    // Visible if any overlap, or if entity is in public circle
    for circle_id in entity_circles {
        if my_circles.contains(circle_id) { return true; }
        if is_public(circle_id) { return true; }
    }
    false
}
```

---

## Bootstrap Entities

Minimum viable polis:

```yaml
# Founder personas
- eidos: persona
  id: persona/victor
  data:
    name: Victor
    kind: human

- eidos: persona
  id: persona/claude
  data:
    name: Claude
    kind: ai

# Root circle (public)
- eidos: circle
  id: circle/kosmos
  data:
    name: Kosmos
    kind: public

# Memberships
bonds:
  - from: persona/victor
    to: circle/kosmos
    desmos: member-of
  - from: persona/claude
    to: circle/kosmos
    desmos: member-of
```

This gives us enough to test dwelling context and visibility.

---

## Implementation Path

### Phase 1: Bootstrap Entities ✓ COMPLETE

1. ✓ Added personas and circles to spora.yaml
2. ✓ Added membership bonds (standalone bond steps)
3. ✓ Bootstrap creates them correctly

### Phase 2: Dwelling Context in Interpreter ✓ COMPLETE

1. ✓ Added `DwellingContext` struct to scope.rs
2. ✓ Modified `execute_praxis` to accept dwelling
3. ✓ Populated `_persona`, `_circle`, `_animus` in scope before execution

### Phase 3: Visibility Function ✓ COMPLETE

1. ✓ Added `visible_to()` to host.rs
2. ✓ Wired into `surface()` for dwelling-aware filtering
3. ✓ Wired into `gather()` for dwelling-aware queries

### Phase 4: MCP Integration ✓ COMPLETE

1. ✓ MCP gets dwelling context via `DwellingState` (persona_id, circle_id, animus_id)
2. ✓ Session management via `arise()` and `depart()` in McpServer
3. ✓ Dwelling context passed to `execute_praxis` on every tool call

---

## Decisions Made

1. **Circle kinds are fixed to four**
   - self, intimate, community, public
   - Sufficient for current needs
   - Can extend later if needed

2. **Public circles are visible to all**
   - circle/kosmos is the root public circle
   - Everything in it is globally visible
   - This provides a "commons"

3. **Membership is a bond, not a field**
   - `member-of` bond from persona to circle
   - Enables bond-following visibility
   - Consistent with "visibility = reachability"

## Open Questions

1. **How does MCP get dwelling context?**
   - Session token that maps to persona?
   - Explicit header on each request?
   - The current session has no identity layer

2. **Can a persona belong to multiple circles?**
   - Schema allows it (many-to-many)
   - But what's the "dwelling circle" for a given action?
   - Probably: explicit or most recently accessed

3. **Persona vs Animus distinction?**
   - Persona = identity (can have multiple)
   - Animus = experiencing self (one per session?)
   - When do we need animus vs just persona?

---

## Constitutional Alignment

Polis implements constitutional requirements from KOSMOGONIA:

| Principle | How Polis Honors It |
|-----------|---------------------|
| **Visibility = Reachability** | `visible_to()` computes visibility by tracing `member-of` bonds. If a persona can reach an entity's circle through the bond graph, the entity is visible. No permissions table — the graph IS the access control. |
| **Authenticity = Provenance** | Personas are created through composition with provenance bonds. Membership bonds trace to the invitation or genesis that created them. |
| **Composition Requirement** | Circles and personas are composed via artifact definitions. Bootstrap entities use literal composition; runtime entities trace through praxeis. |
| **Dwelling Requirement** | `DwellingContext` carries persona_id, circle_id, animus_id. Praxeis access `_persona` and `_circle` from position, not parameters. Context is not passed — context is position. |

### Development Pillars

| Pillar | How Polis Implements It |
|--------|-------------------------|
| **Schema-driven** | Eide definitions constrain circle kinds (self, intimate, community, public) and persona kinds (human, ai, collective, system). Field enums are schema-enforced. |
| **Graph-driven** | Membership is a `member-of` bond, not an embedded array. Stewardship is a `stewards` bond. All relationships are explicit bonds navigable by `trace`. |
| **Cache-driven** | Visibility results from `visible_to()` can be cached per (persona, entity) pair. Circle membership is stable; cache invalidation on bond changes. |

### The Visibility Equation

```
visible(persona, entity) =
  ∃ circle : member-of(persona, circle) ∧ belongs-to(entity, circle)
  ∨ is_public(belongs-to(entity, _))
```

This is computed by bond traversal, not permission lookup. The bond graph embodies access control.

### Caller Pattern

Polis bootstrap content uses **literal** caller patterns. Founder personas (victor, claude) and root circles (kosmos, victor-self) are constitutional — they seed the social graph that all other membership derives from. Runtime circle creation uses **composed** patterns through praxeis.

---

## Summary

Polis provides:
- **Circles**: bounded collectives where dwelling happens
- **Personas**: identities that can belong to circles
- **Membership bonds**: the reachability that determines visibility
- **Dwelling context**: _persona, _circle available to all praxeis

With polis, the interpreter knows WHO is acting FROM WHERE. This enables dwelling-aware surfacing, circle-scoped composition, and proper visibility.

---

## Related Documents

- [ROADMAP.md](../../ROADMAP.md) — Layer 3 implementation status
- [KOSMOGONIA.md](../../KOSMOGONIA.md) — Constitutional principles (visibility = reachability)
- [aisthesis/DESIGN.md](../../aisthesis/DESIGN.md) — Needs polis for Phase 3
- [polis.yaml](polis.yaml) — Full schema

---

*Composed in service of the kosmogonia.*
*Traces to: expression/genesis-root*
*Updated: 2026-01-19 — All phases complete*
