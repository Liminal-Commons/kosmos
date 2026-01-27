# Nous: Understanding Operations

*A design for the crystallization of understanding.*

---

## The Problem

Understanding doesn't arrive fully formed. It develops:

```
semeioma → synesis → theoria → proairesis → typos
(marking)  (getting) (seeing) (choosing)  (imprinting)
```

V7 has theoria as entities but no operations for:
- The path from notes → insights → crystallized understanding
- Inquiries that drive understanding forward
- Synthesis that combines multiple understandings

**Nous is where understanding becomes.**

---

## Implementation Status

| Component | Status | Location |
|-----------|--------|----------|
| nous.yaml schema | ✓ Complete | `klimax/nous/nous.yaml` |
| Eide (inquiry, synthesis) | ✓ Defined | nous.yaml |
| Theoria eidos | ✓ Defined | arche/eidos.yaml |
| Artifact definitions | ✓ Defined | nous.yaml |
| Praxeis | ✓ Defined | nous.yaml |
| Rust step implementations | ✓ Ready | All step types implemented (set, return, find, assert, bind, compose, arise, gather, for_each, update, trace, switch, filter, loose) |
| Integration with surface | ✓ Ready | Aisthesis Phase 3 complete — dwelling-aware surfacing available |
| TraceStep for navigation | ✓ Complete | `steps.rs` — trace bonds with optional entity resolution |

---

## Grounding in the Kosmogonia

### Not a Klimax Scale

Nous is not scale 4, 5, or 6. It's a cross-scale oikos:

> Nous operates wherever understanding crystallizes.
> It is not a scale but a function that runs through all scales.

A theoria can crystallize at any scale:
- psyche: personal insight
- oikos: domain understanding
- polis: collective knowledge
- kosmos: foundational truth

### The Ladder (Klimax Noeseos)

From CLAUDE.md:
```
semeioma → synesis → theoria → proairesis → typos
```

| Rung | Greek | What happens |
|------|-------|-------------|
| semeioma | σημείωμα | Marking what matters (notes) |
| synesis | σύνεσις | Getting it (insight) |
| theoria | θεωρία | Seeing it (crystallized understanding) |
| proairesis | προαίρεσις | Choosing it (commitment) |
| typos | τύπος | Imprinting it (pattern) |

Nous primarily operates on the middle three: synesis → theoria → proairesis.

### Metabole Connection

The ladder IS metabolic. Each rung is a completed cycle:
- hygron (probe) → finding what's relevant
- krystallos (crystallize) → theoria emerges
- tasis (verify) → confirmation or supersession

---

## Architecture

### 1. Core Eide

| Eidos | What It Is |
|-------|------------|
| `theoria` | Crystallized understanding (insight + domain + status) |
| `inquiry` | An open question driving understanding |
| `synthesis` | Combining multiple theoria into higher understanding |
| `journey` | Teleological container — movement toward a desire |
| `waypoint` | Consolidation point on a journey |

### 2. Theoria Status

```yaml
status:
  - provisional   # Just crystallized, not yet confirmed
  - crystallized  # Confirmed as understanding
  - superseded    # Replaced by newer understanding
```

Understanding evolves. Supersession is not deletion — the old theoria remains, marked and bonded.

### 3. Key Desmoi

| Desmos | From | To | Meaning |
|--------|------|-----|--------|
| `crystallized-in` | theoria | circle | Where understanding lives |
| `inquires` | persona | inquiry | Who opened the question |
| `answers` | theoria | inquiry | Understanding that addresses |
| `synthesizes` | synthesis | theoria | What was combined |
| `supersedes` | theoria | theoria | Evolution of understanding |
| `supports` | theoria | theoria | Reinforcement |
| `contradicts` | theoria | theoria | Tension |
| `contains-waypoint` | journey | waypoint | Journey contains waypoint |
| `depends-on` | journey | journey | Journey dependency |
| `waypoint-yields` | waypoint | any | Artifact produced at waypoint |

### 4. Key Praxeis

**Theoria:**
| Praxis | What It Does |
|--------|-------------|
| `crystallize-theoria` | Create new understanding |
| `confirm-theoria` | Move from provisional to crystallized |
| `supersede-theoria` | Replace with evolved understanding |
| `open-inquiry` | Start a question |
| `answer-inquiry` | Connect theoria to inquiry |
| `synthesize` | Combine multiple theoria |
| `find-related` | Navigate the understanding graph |

**Journeys (hodos):**
| Praxis | What It Does |
|--------|-------------|
| `begin-journey` | Create journey with desire and waypoints |
| `reach-waypoint` | Mark waypoint as reached |
| `advance-journey` | Move to next waypoint |
| `complete-journey` | Arrive at telos |
| `surface-journeys` | Find journeys by semantic query |

---

## Implementation Path

### Phase 1: Basic Theoria Operations

1. crystallize-theoria works
2. confirm-theoria works
3. list-theoria works

These depend on compose and basic bonding.

### Phase 2: Inquiry Operations

1. open-inquiry works
2. answer-inquiry works
3. Inquiries surface via aisthesis

### Phase 3: Synthesis and Navigation

1. synthesize works
2. find-related uses bond tracing
3. Integration with surface for semantic navigation

### Phase 4: Dwelling-Aware Understanding

1. Theoria crystallizes in dwelling circle (via `crystallized-in` bond)
2. Visibility respects circle membership
3. Persona affinity influences what surfaces

---

## Integration with Aisthesis

From aisthesis/DESIGN.md:

> **Nous** (understanding):
> - `find-related-theoria` can use `surface` instead of just bond-following
> - `answer-inquiry` can surface candidate theoria

Two navigation modes:
- **Structural**: `find-related` uses `trace` to follow bonds (TraceStep now implemented)
- **Semantic**: `surface` finds by meaning (dwelling-aware surfacing complete)

Both are valid and now implemented. Use structural when you have a starting point. Use semantic when exploring.

---

## Decisions Made

1. **Theoria status is explicit**
   - provisional → crystallized → superseded
   - Makes understanding lifecycle visible
   - Superseded theoria remain (not deleted)

2. **Synthesis requires 2+ sources**
   - Can't synthesize from one theoria
   - Must bring together multiple understandings
   - Enforced in praxis

3. **Inquiry is first-class**
   - Not just a tag on theoria
   - Its own eidos with lifecycle
   - Questions drive understanding

## Design Decisions (Resolved)

1. **Theoria indexing: wrapper praxis, not auto-embed**
   - **Decision:** Use wrapper praxis pattern, not typos auto-embed
   - **Rationale:** Constitutional layer stays pure (composition is composition). Operational layer adds indexing through `crystallize-theoria` praxis.
   - **Implementation:** `crystallize-theoria` should call `index` step after `arise`
   - **Status:** ✓ Complete — index step wired into crystallize-theoria

---

## Open Questions

1. **How to handle contradicting theoria?**
   - Schema has `contradicts` desmos
   - But no praxis for marking contradiction
   - Let it emerge naturally? Or explicit marking?

3. **What triggers synthesis?**
   - Currently: explicit call by persona
   - Could: surface suggests when theoria cluster
   - Future: AI proposes syntheses

---

## Constitutional Alignment

Nous implements constitutional requirements from KOSMOGONIA:

| Principle | How Nous Honors It |
|-----------|-------------------|
| **Visibility = Reachability** | Theoria crystallizes in circles via `crystallized-in` bond. Visibility respects circle membership — you can only surface understanding reachable through your circle graph. |
| **Authenticity = Provenance** | Every theoria traces to its crystallization event. Supersession creates `supersedes` bonds, preserving the evolution of understanding. The old theoria remains — provenance is not erased. |
| **Composition Requirement** | Theoria, inquiries, and syntheses are composed via artifact definitions. `crystallize-theoria` praxis uses `compose` step with provenance bonds to the definition. |
| **Dwelling Requirement** | `crystallize-theoria` uses `_circle` from dwelling context to determine where understanding lives. The `crystallized-in` bond flows from position automatically. |

### Development Pillars

| Pillar | How Nous Implements It |
|--------|------------------------|
| **Schema-driven** | Theoria status is schema-constrained (provisional, crystallized, superseded). Inquiry and synthesis eide have defined fields. Status transitions are explicit. |
| **Graph-driven** | Understanding relationships are bonds: `crystallized-in`, `answers`, `supersedes`, `supports`, `contradicts`. Navigation via `trace` (structural) or `surface` (semantic). No embedded references. |
| **Cache-driven** | Indexed theoria enable cached semantic search results. Content hashes of theoria enable memoization when surfacing related understanding. |

### The Understanding Graph

```
inquiry ◀──answers── theoria ──crystallized-in──▶ circle
                        │
                        ├──supersedes──▶ older_theoria
                        ├──supports────▶ related_theoria
                        └──contradicts─▶ tension_theoria

synthesis ──synthesizes──▶ [theoria_1, theoria_2, ...]
```

Understanding navigates by bond traversal. The shape of knowledge is the shape of the graph.

### Caller Pattern

Nous content uses **composed** and **literal** caller patterns:
- Theoria insight text is **literal** — the understanding itself cannot be derived
- Domain and status fields are **computed** from schema defaults
- Synthesis draws from **queried** sources (theoria to combine)

Runtime theoria creation uses composed patterns through `crystallize-theoria` praxis. The wrapper praxis pattern keeps composition pure while adding indexing.

---

## Summary

Nous provides:
- **Theoria**: crystallized understanding with lifecycle
- **Inquiry**: questions that drive understanding
- **Synthesis**: combining into higher understanding
- **Navigation**: both structural (bonds) and semantic (surface)

Understanding doesn't just exist. It arises, crystallizes, evolves.

---

## Related Documents

- [ROADMAP.md](../../ROADMAP.md) — Overall status
- [KOSMOGONIA.md](../../KOSMOGONIA.md) — Klimax noeseos (the ladder)
- [aisthesis/DESIGN.md](../../aisthesis/DESIGN.md) — Semantic navigation
- [nous.yaml](nous.yaml) — Full schema
- [CLAUDE.md](../../CLAUDE.md) — The breath, the ladder

---

*Composed in service of the kosmogonia.*
*Traces to: expression/genesis-root*
*Updated: 2026-01-19 — Step types and surfacing ready*
