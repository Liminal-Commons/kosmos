# Polis: Oikoi and Governance

*A design for collective organization and dwelling.*

---

## The Problem

Two requirements collide:

| Requirement | What It Means |
|-------------|---------------|
| **Visibility = Reachability** | You can only see what you can reach through bonds |
| **Dwelling context** | Praxeis need to know WHO is acting FROM WHERE |

V7 has no oikoi. No prosopa. No membership bonds. No dwelling context.

**Polis is where identities organize into collectives, and where dwelling becomes real.**

---

## Implementation Status

| Component | Status | Location |
|-----------|--------|----------|
| polis.yaml schema | ✓ Complete | `klimax/3-polis/polis.yaml` |
| Eide (oikos, prosopon, principle, pattern) | ✓ Defined | polis.yaml |
| Artifact definitions | ✓ Defined | polis.yaml |
| Praxeis (create-oikos, join-oikos, etc.) | ✓ Defined | polis.yaml |
| Bootstrap entities | ✓ Complete | `spora/spora.yaml` — prosopon/victor, prosopon/claude, oikos/kosmos, oikos/victor-self |
| Dwelling context in interpreter | ✓ Complete | `scope.rs` — DwellingContext struct, _prosopon/_oikos/_parousia bindings |
| visible_to() function | ✓ Complete | `host.rs:348-390` — oikos membership + public visibility |
| MCP integration | ✓ Complete | `kosmos-mcp-v8` — DwellingState tracking, arise/depart lifecycle |

**This layer is complete. Dwelling-aware surfacing (aisthesis Phase 3) is unblocked.**

---

## Grounding in the Kosmogonia

### Klimax Position

Polis is scale 3 of 6:
```
kosmos (1) → physis (2) → POLIS (3) → oikos (4) → soma (5) → psyche (6)
```

Polis establishes WHO can dwell WHERE. Lower scales (oikos [intimate dwelling], soma, psyche) operate within the social structure polis creates.

### Visibility = Reachability

From KOSMOGONIA.md:
> You can only perceive what you can cryptographically reach through the bond graph.

This means:
- An entity in an oikos is visible to oikos members
- Membership is a `member-of` bond
- Visibility is computed by tracing bonds, not by checking permissions

### Axiom II: Authority

From KOSMOGONIA.md:
> The kosmos acts only as authorized by those who dwell in it.
> Context is not passed. Context is position.

This means:
- `_prosopon` and `_oikos` are not parameters to praxeis
- They are derived from the caller's position in the bond graph
- Bonds flow from position automatically

---

## Architecture

### 1. Oikos Kinds

Four kinds of oikos, from intimate to open:

| Kind | Description | Example |
|------|-------------|---------|
| `self` | Personal oikos (one prosopon) | Victor's private space |
| `intimate` | Close group (family, close friends) | Home oikos |
| `community` | Larger group with shared purpose | A project team |
| `public` | Open to all | oikos/kosmos (the root) |

Public oikoi are visible to everyone. Other oikoi require membership.

### 2. Prosopon Kinds

Four kinds of prosopon:

| Kind | Description |
|------|-------------|
| `human` | A human identity |
| `ai` | An AI identity (like Claude) |
| `collective` | A group acting as one |
| `system` | System/automated identity |

### 3. Core Bonds

| Desmos | From | To | Meaning |
|--------|------|-----|--------|
| `member-of` | prosopon | oikos | Prosopon belongs to oikos |
| `stewards` | prosopon | oikos | Prosopon can govern oikos |
| `adopts` | oikos | principle | Oikos committed to principle |

### 4. Dwelling Context

The interpreter scope will carry:

```rust
pub struct DwellingContext {
    pub prosopon_id: String,
    pub oikos_id: String,
    pub parousia_id: Option<String>,
}
```

Praxeis access these as `_prosopon`, `_oikos`, `_parousia`.

### 5. Visibility Function

```rust
fn visible_to(prosopon_id: &str, entity_id: &str) -> bool {
    // Get oikoi prosopon is member of
    let my_oikoi = trace_bonds(prosopon_id, None, "member-of");

    // Get oikoi entity belongs to
    let entity_oikoi = trace_bonds(entity_id, None, "belongs-to");

    // Visible if any overlap, or if entity is in public oikos
    for oikos_id in entity_oikoi {
        if my_oikoi.contains(oikos_id) { return true; }
        if is_public(oikos_id) { return true; }
    }
    false
}
```

---

## Bootstrap Entities

Minimum viable polis:

```yaml
# Founder prosopa
- eidos: prosopon
  id: prosopon/victor
  data:
    name: Victor
    kind: human

- eidos: prosopon
  id: prosopon/claude
  data:
    name: Claude
    kind: ai

# Root oikos (commons)
- eidos: oikos
  id: oikos/kosmos
  data:
    name: Kosmos
    kind: commons

# Memberships
bonds:
  - from: prosopon/victor
    to: oikos/kosmos
    desmos: member-of
  - from: prosopon/claude
    to: oikos/kosmos
    desmos: member-of
```

This gives us enough to test dwelling context and visibility.

---

## Implementation Path

### Phase 1: Bootstrap Entities ✓ COMPLETE

1. ✓ Added prosopa and oikoi to spora.yaml
2. ✓ Added membership bonds (standalone bond steps)
3. ✓ Bootstrap creates them correctly

### Phase 2: Dwelling Context in Interpreter ✓ COMPLETE

1. ✓ Added `DwellingContext` struct to scope.rs
2. ✓ Modified `execute_praxis` to accept dwelling
3. ✓ Populated `_prosopon`, `_oikos`, `_parousia` in scope before execution

### Phase 3: Visibility Function ✓ COMPLETE

1. ✓ Added `visible_to()` to host.rs
2. ✓ Wired into `surface()` for dwelling-aware filtering
3. ✓ Wired into `gather()` for dwelling-aware queries

### Phase 4: MCP Integration ✓ COMPLETE

1. ✓ MCP gets dwelling context via `DwellingState` (prosopon_id, oikos_id, parousia_id)
2. ✓ Session management via `arise()` and `depart()` in McpServer
3. ✓ Dwelling context passed to `execute_praxis` on every tool call

---

## Decisions Made

1. **Oikos kinds are fixed to four**
   - self, intimate, community, public
   - Sufficient for current needs
   - Can extend later if needed

2. **Public oikoi are visible to all**
   - oikos/kosmos is the root public oikos
   - Everything in it is globally visible
   - This provides a "commons"

3. **Membership is a bond, not a field**
   - `member-of` bond from prosopon to oikos
   - Enables bond-following visibility
   - Consistent with "visibility = reachability"

## Open Questions

1. **How does MCP get dwelling context?**
   - Session token that maps to prosopon?
   - Explicit header on each request?
   - The current session has no identity layer

2. **Can a prosopon belong to multiple oikoi?**
   - Schema allows it (many-to-many)
   - But what's the "dwelling oikos" for a given action?
   - Probably: explicit or most recently accessed

3. **Prosopon vs Parousia distinction?**
   - Prosopon = identity (can have multiple)
   - Parousia = experiencing self (one per session?)
   - When do we need parousia vs just prosopon?

---

## Constitutional Alignment

Polis implements constitutional axioms from KOSMOGONIA:

| Axiom / Pillar | How Polis Honors It |
|----------------|---------------------|
| **Axiom I: Composition** | Oikoi and prosopa are composed via artifact definitions. Bootstrap entities use literal composition; runtime entities trace through praxeis. |
| **Axiom II: Authority** | `DwellingContext` carries prosopon_id, oikos_id, parousia_id. Praxeis access `_prosopon` and `_oikos` from position, not parameters. Context is not passed — context is position. |
| **Axiom III: Traceability** | Prosopa are created through composition with provenance bonds. Membership bonds trace to the invitation or genesis that created them. |
| **Visibility = Reachability** | `visible_to()` computes visibility by tracing `member-of` bonds. If a prosopon can reach an entity's oikos through the bond graph, the entity is visible. No permissions table — the graph IS the access control. |
| **Authenticity = Provenance** | Every entity traces to signed genesis through provenance bonds. |

### Development Pillars

| Pillar | How Polis Implements It |
|--------|-------------------------|
| **Schema-driven** | Eide definitions constrain oikos kinds (self, intimate, community, public) and prosopon kinds (human, ai, collective, system). Field enums are schema-enforced. |
| **Graph-driven** | Membership is a `member-of` bond, not an embedded array. Stewardship is a `stewards` bond. All relationships are explicit bonds navigable by `trace`. |
| **Cache-driven** | Visibility results from `visible_to()` can be cached per (prosopon, entity) pair. Oikos membership is stable; cache invalidation on bond changes. |

### The Visibility Equation

```
visible(prosopon, entity) =
  ∃ oikos : member-of(prosopon, oikos) ∧ belongs-to(entity, oikos)
  ∨ is_public(belongs-to(entity, _))
```

This is computed by bond traversal, not permission lookup. The bond graph embodies access control.

### Caller Pattern

Polis bootstrap content uses **literal** caller patterns. Founder prosopa (victor, claude) and root oikoi (kosmos, victor-self) are constitutional — they seed the social graph that all other membership derives from. Runtime oikos creation uses **composed** patterns through praxeis.

---

## Summary

Polis provides:
- **Oikoi**: bounded collectives where dwelling happens
- **Prosopa**: identities that can belong to oikoi
- **Membership bonds**: the reachability that determines visibility
- **Dwelling context**: _prosopon, _oikos available to all praxeis

With polis, the interpreter knows WHO is acting FROM WHERE. This enables dwelling-aware surfacing, oikos-scoped composition, and proper visibility.

---

## Related Documents

- [ROADMAP.md](../../ROADMAP.md) — Layer 3 implementation status
- [KOSMOGONIA.md](../../KOSMOGONIA.md) — Constitutional principles (visibility = reachability)
- [aisthesis/DESIGN.md](../../aisthesis/DESIGN.md) — Needs polis for Phase 3
- [polis.yaml](polis.yaml) — Full schema

---

*Composed in service of the kosmogonia.*
*Traces to: phasis/genesis-root*
*Updated: 2026-01-19 — All phases complete*
