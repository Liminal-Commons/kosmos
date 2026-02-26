# Visibility Semantics

How dwelling determines what every operation can see. One rule, applied universally.

**This document is prescriptive.** It describes the target state. Where implementation diverges, the code has a gap.

---

## The Rule

**Visibility = exists-in + member-of.**

A prosopon can see an entity if and only if that entity `exists-in` an oikos that the prosopon is `member-of`. An entity without such a path is not hidden — it is absent. There is no occasion to deny access because there is no occasion to encounter it.

**Transitional rule**: Entities with no `exists-in` bonds (genesis/constitutional entities bootstrapped before dwelling context) are universally visible. This transitional rule is removed once all genesis entities receive explicit `exists-in` bonds to `oikos/kosmos`.

This rule governs every operation: queries, mutations, substrate operations, projection, emission. No exceptions.

---

## Visibility Desmoi

Two bond types constitute visibility. All other bonds are navigational — traversable once visibility is established, but they do not create visibility.

### `exists-in` (entity → oikos)

Every composed entity bonds to the oikos where it exists. This bond is created by `compose_entity()` from the dwelling context. It is the primary visibility mechanism.

An entity that exists-in oikos A is visible to every prosopon who is member-of oikos A.

### `member-of` (prosopon → oikos)

Formal membership. A prosopon is member-of zero or more oikoi. Membership determines what the prosopon can see: entities that exist-in any oikos they are member-of.

### Visibility Algorithm

For a prosopon P, the **visible set** is:

```
All entities E where:
  E exists-in O, for any O where P member-of O
UNION
  All entities E where E has no exists-in bonds (transitional — genesis entities)
```

This is a set union computed via SQL joins on the bonds table. Efficient, no graph traversal required.

---

## Dwelling Desmoi

These bonds establish who dwells where. They are distinct from visibility desmoi.

| Desmos | From | To | Purpose |
|--------|------|----|---------|
| `dwells-in` | parousia | oikos | Active session presence — parousia's current dwelling |
| `member-of` | prosopon | oikos | Formal membership — determines visibility |
| `stewards` | prosopon | oikos | Full attainments and authorization within oikos |
| `instantiates` | parousia | prosopon | Parousia instantiates a prosopon for a session |

`dwells-in` is exclusively for parousia — never applied to entities. Entities use `exists-in`.

---

## Oikos

One kind of oikos. No `kind` field, no types. Topology emerges from bond arrangement:

- **Personal** — one prosopon as sole member and sole steward. This is a prosopon's sovereign ground. Invitation is structurally prevented: no praxis grants the capability to add members to a personal oikos.
- **Shared (peer)** — multiple prosopa, all of whom are stewards. Equal authorization — every member has full attainments within the oikos.
- **Commons** — stewards who govern and curate, plus non-steward members who can see but not modify. Stewards have full attainments; members have visibility only.

These are descriptions of bond arrangement, not types. The same rules apply regardless.

**Governance through bonds:**
- `stewards` (prosopon → oikos) = full attainments and authorization within the oikos. Stewards can invoke all praxeis the oikos grants, manage membership, create bonds, and curate content.
- `member-of` (prosopon → oikos) = visibility. Members see entities that exist-in the oikos. Without `stewards`, membership grants no mutation capability.

A prosopon who is both `member-of` and `stewards` has full access. A prosopon who is only `member-of` has read-only visibility.

---

## Modifiability

Modifiability is orthogonal to visibility. Seeing an entity does not grant the right to change it.

Mutation is gated by:
- **Attainment authorization**: The praxis that performs the mutation must be attained by the prosopon.
- **Authorship provenance**: The `authorized-by` bond traces who created what.
- **Stewardship**: Governance operations (creating bonds, managing membership) require `stewards` relationship.

Visibility determines WHAT you see. Attainments determine what you can DO.

---

## Federation

`federates-with` (oikos → oikos) is an **operational** bond for sync between kosmos instances. It is NOT a visibility bond. Federation enables data replication — content synced through federation becomes local to the receiving oikos via `exists-in` bonds.

---

## Complete Operations Table

### Navigation

| Operation | Visibility Requirement | Authority | Effect |
|-----------|----------------------|-----------|--------|
| **find**(id) | Entity must be in visible set | None | Returns entity or null |
| **gather**(eidos) | Filters to visible set | None | Returns visible entities of eidos |
| **surface**(query) | Filters to visible set | None | Returns visible embedded entities by semantic proximity |
| **traverse**(root, desmoi) | Root must be in visible set | None | Returns reachable entities within visible set |
| **trace**(from, to, desmos) | Both endpoints in visible set | None | Returns matching bonds between visible entities |

#### find

Direct lookup by ID. Returns the entity only if it is in the prosopon's visible set. If the entity exists but is not visible, returns null — indistinguishable from nonexistence.

**Current state**: RESOLVED. `find_entity_visible()` checks visibility via `visible_to()`. Used by FindStep (praxis execution), REST `get_entity`, and REST `update_entity`. Internal callers use raw `find_entity()` (no filtering).

#### gather

Collect all entities of an eidos within the visible set. The eidos filter and visibility filter are applied together in SQL.

**Current state**: RESOLVED. `gather_entities()` checks `exists-in` bonds against oikoi the prosopon is `member-of`. Entities with no `exists-in` bonds are treated as universal (transitional).

#### surface

Semantic search over embeddings. Results are filtered to the visible set before return.

**Current state**: `surface()` filters via `visible_to()` which now checks `exists-in` + `member-of`.

#### traverse

Multi-hop graph walk from a root entity. Reached entities NOT in the visible set are excluded — traversal does not cross visibility boundaries.

**Current state**: RESOLVED. `traverse_visible()` checks visibility at each node — invisible entities are excluded and their neighbors are not queued. Root must be visible; if not, returns empty. Used by TraverseStep (praxis execution). Internal callers use raw `traverse()` (no filtering).

#### trace

Single-hop bond query. Both endpoints must be in the visible set.

**Current state**: RESOLVED. `trace_bonds_visible()` filters returned bonds — both `from_id` and `to_id` must pass `visible_to()`. Used by TraceStep (praxis execution) and REST `list_bonds`. Internal callers use raw `trace_bonds()` (no filtering).

---

### Mutation

| Operation | Visibility Requirement | Authority | Effect |
|-----------|----------------------|-----------|--------|
| **compose**(typos, inputs) | Typos must be visible | Praxis attainment | New entity with exists-in bond to current oikos |
| **update**(id, data) | Entity must be visible | Praxis attainment | Entity data modified, version incremented |
| **dissolve**(id) | Entity must be visible | Praxis attainment | Entity and its bonds removed |
| **create_bond**(from, to, desmos) | Source must be visible | Praxis attainment | Bond created |

#### compose

Composition creates a new entity through a typos definition. The new entity receives:

- `typed-by` → eidos (what it is)
- `composed-from` → typos (how it was defined)
- `authorized-by` → session (who authorized it)
- `exists-in` → oikos (where it exists — from dwelling context)
- `depends-on` → dependencies (from slot resolution)

The `exists-in` bond makes the new entity immediately visible to all members of the composing prosopon's oikos.

**Current state**: RESOLVED. `compose_entity()` creates `exists-in` bonds.

#### update / dissolve / create_bond

**Current gap**: No visibility checks on mutations. Planned for Session 5.

---

### Substrate

| Operation | Visibility Requirement | Authority | Effect |
|-----------|----------------------|-----------|--------|
| **manifest**(entity) | Entity must be visible | Tier 3 attainment | Entity actualized in substrate |
| **unmanifest**(entity) | Entity must be visible | Tier 3 attainment | Entity removed from substrate |
| **reconcile**(entity) | Entity must be visible | Ambient (governance) | Substrate state aligned |
| **signal**(source) | Signals scoped to visible set | None (read-only) | Signal values available |

**Current state**: Manifest/unmanifest check tier 3. No visibility checks. Signals broadcast globally.

---

### Inference

| Operation | Visibility Requirement | Authority | Effect |
|-----------|----------------------|-----------|--------|
| **infer**(prompt, model) | Provider must be visible | Tier 3 attainment | LLM response |
| **embed**(text) | Provider must be visible | Tier 3 attainment | Embedding stored |

**Current state**: Provider visibility not checked. Embedding index is global.

---

### Projection

| Operation | Visibility Requirement | Authority | Effect |
|-----------|----------------------|-----------|--------|
| **MCP tool listing** | Praxeis must be visible AND attained | Attainment bond | Tool list returned |
| **REST GET** | Same as find/gather | Session required | Entity/entities returned |
| **REST mutation** | Same as compose/update/dissolve | Session + attainment | Graph mutated |

**Current state**: MCP filters by attainment. REST GET `get_entity` uses `find_entity_visible`. REST `list_entities` uses `gather_entities` with dwelling. REST `list_bonds` uses `trace_bonds_visible`. REST `update_entity` checks visibility before mutation. MCP tools go through praxis steps which use visibility-aware methods.

---

## Invariants

1. **No visibility, no access.** If an entity is not in the visible set, every operation behaves as if the entity does not exist.

2. **Visibility is symmetric within an oikos.** All members see the same visible set.

3. **Constitutional entities are universally visible** (transitional). Entities with no `exists-in` bonds are visible to all. Removed once genesis entities get explicit `exists-in` bonds.

4. **exists-in is immutable.** An entity exists in one oikos. It does not move. Federation replicates, it does not relocate.

5. **Absence, not denial.** Operations never return "access denied." They return null, empty array, or silently exclude.

---

## Current State Summary

### Resolved (Session 1)

| Aspect | Status |
|--------|--------|
| `exists-in` desmos defined | Complete |
| `compose_entity` creates `exists-in` bonds | Complete |
| `gather_entities` uses exists-in + member-of SQL | Complete |
| `visible_to` uses exists-in + member-of | Complete |
| `session_arise` checks home_oikos, creates member-of oikos/kosmos | Complete |
| Visibility tests (Session 1) | Complete |

### Resolved (Session 3)

| Aspect | Status |
|--------|--------|
| `find_entity_visible` checks visibility | Complete |
| `traverse_visible` stops at visibility boundaries | Complete |
| `trace_bonds_visible` filters both endpoints | Complete |
| FindStep uses visibility-aware find | Complete |
| TraverseStep uses visibility-aware traverse | Complete |
| TraceStep uses visibility-aware trace | Complete |
| REST `get_entity` applies visibility | Complete |
| REST `list_bonds` applies visibility | Complete |
| REST `update_entity` applies visibility | Complete |
| Visibility tests (Session 3 — 11 new tests) | Complete |

### Remaining Gaps

| Gap | Severity | Planned |
|-----|----------|---------|
| MCP tool listing no oikos scope | Medium | Session 5 |
| `dissolve_entity` no visibility check | Medium | Session 5 |
| `create_bond` no visibility check | Medium | Session 5 |
| Genesis entities no exists-in bonds | Medium | Session 6 |
| Transitional "no exists-in = universal" rule | Medium | Session 6 (removed after retroactive bonds) |
| Embedding index global | Low | Future |
| Reconciler not oikos-scoped | Low | Future |
| Signals not oikos-scoped | Low | Future |

---

*Traces to: KOSMOGONIA Axiom II (Authority), Pillar: Visibility = Reachability, authority-mechanism.md, attainment-authorization.md, query-system.md*
*Created: 2026-02-21*
*Updated: 2026-02-23 — Session 3: find/traverse/trace visibility breadth, REST endpoints, interpreter steps*
