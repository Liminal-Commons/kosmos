# Chora Handoff: Sense-Body Extension

> **Status:** Active
> **Waiting on:** Body-schema extension in soma/sense-body stoicheion

*Document for chora implementation team. Describes soma/sense-body extensions for topos awareness.*

---

## Why This Is Needed

**The Problem:** Claude operates blind without context. In a traditional system, Claude would need to ask "what am I working on?" or "what's available?" on every turn. This creates friction and wastes tokens.

**The Solution:** The body-schema is Claude's "sense of self" — a structured snapshot of:
- What the parousia is currently doing (development context)
- What capabilities are available (surfaces, palette)
- What has changed since last observation (notifications)

**The Value:**
1. **Zero-friction context** — Claude knows it's developing `topos/recipes` without asking
2. **Capability awareness** — Claude knows manteia is available for generation
3. **Change awareness** — Claude sees "5 changes in oikos/chora since last view"
4. **Reduced hallucination** — Claude only suggests actions it knows are available

Without sense-body extensions, Claude is intelligent but context-blind. With them, Claude becomes embodied — aware of its situation and capable of proactive assistance.

---

## Current Implementation Status

### Cursor-Based Notification System (Complete)

The notification system uses the `last-saw` desmos and version-based queries rather than change-record entities. This implements the cache-driven pillar: changes are computed from deltas, not stored.

**Kosmos additions:**
- `last-saw` desmos in `genesis/arche/desmos.yaml` ✅
- `soma/get-notifications` praxis ✅
- `soma/mark-oikos-seen` praxis ✅
- `soma/get-oikos-changes` praxis ✅

**Chora additions:**
- `get_cursor` / `update_cursor` operations ✅
- `gather_entities_since_version` query ✅
- `count_changes_since_version` query ✅
- `get_circle_notifications` aggregate ✅
- Global versioning for all entity mutations ✅

**New stoicheia:**
- `get_cursor` — Get observation cursor for prosopon's view of oikos
- `get_notifications` — Get notification counts for all visible oikoi
- `gather_since` — Gather entities changed since a version
- `update_cursor` — Update observation cursor to current version

### What This Enables

```yaml
body-schema:
  notifications:
    - oikos_id: "oikos/chora"
      unseen_count: 5
    - oikos_id: "oikos/kosmos"
      unseen_count: 12
```

Claude sees which oikoi have changes. When user views an oikos, `mark-oikos-seen` updates the cursor.

---

## Remaining Extensions (Kosmos YAML)

These can be implemented as praxis extensions using existing stoicheia.

### 1. Development Context Section

When a parousia has `developing` bonds to topoi:

```yaml
body-schema:
  development:
    active_topoi:
      - id: "topos/recipes"
        name: "recipes"
        status: composing
        eide_count: 3
        praxeis_count: 2
        desmoi_count: 1
```

**Implementation:** Extend sense-body praxis with:
```yaml
- step: trace
  from_id: "$_parousia.id"
  desmos: developing
  resolve: to
  bind_to: developing_topoi

- step: for_each
  items: "$developing_topoi"
  as: topos
  do:
    - step: trace
      from_id: "$topos.id"
      desmos: contains
      resolve: to
      bind_to: definitions
    # Count by eidos type...
```

### 2. Palette Awareness Section

Counts of available composition primitives:

```yaml
body-schema:
  palette_awareness:
    stoicheia:
      tier_0: 3
      tier_1: 8
      tier_2: 12
      tier_3: 5
    typos_count: 47
    desmoi_count: 23
```

**Implementation:** Gather stoicheia/typos/desmos entities and count.

### 3. Surface Availability Section

Which capability surfaces are reachable:

```yaml
body-schema:
  available_surfaces:
    rendering:
      status: available
      provider: opsis
    reasoning:
      status: available
      provider: manteia
    understanding:
      status: available
      provider: nous
    coordination:
      status: available
      provider: ergon
```

**Implementation:** Query topoi manifests for `surfaces_provided`.

---

## Architecture Note: Cursor Model

The notification system does NOT use change-record entities. Instead:

```
prosopon --last-saw[version=38]--> oikos/chora

Notification query:
  entities in oikos/chora WHERE version > 38
  → 4 entities changed
```

**Why this design:**
1. **No entity proliferation** — Cursor bond replaces change-records
2. **Always consistent** — Computed from source of truth
3. **Cache-aligned** — Content-addressing handles invalidation
4. **Simple cleanup** — Nothing to prune

See ARCHITECTURE.md for full documentation of the cursor model.

---

## Dependencies

| Component | Location | Status |
|-----------|----------|--------|
| sense-body praxis | genesis/soma/praxeis/soma.yaml | ✅ Exists |
| body-schema eidos | genesis/soma/eide/soma.yaml | ✅ Exists |
| last-saw desmos | genesis/arche/desmos.yaml | ✅ Added |
| get-notifications praxis | genesis/soma/praxeis/soma.yaml | ✅ Added |
| mark-oikos-seen praxis | genesis/soma/praxeis/soma.yaml | ✅ Added |
| Cursor stoicheia | genesis/stoicheia-portable/ | ✅ Added |
| Chora cursor operations | crates/kosmos/src/host.rs | ✅ Implemented |
| Development context | sense-body extension | ⏳ Kosmos YAML |
| Palette awareness | sense-body extension | ⏳ Kosmos YAML |
| Surface availability | sense-body extension | ⏳ Kosmos YAML |

---

## Implementation Order

### Phase 1: Core Notifications (Complete ✅)
1. ✅ Add `last-saw` desmos
2. ✅ Add cursor stoicheia
3. ✅ Implement chora cursor operations
4. ✅ Add notification praxeis
5. ✅ Global versioning for entities

### Phase 2: Body-Schema Extensions (Kosmos YAML)
1. ⏳ Extend sense-body for development context
2. ⏳ Add palette awareness gathering
3. ⏳ Add surface availability query
4. ⏳ Integrate notifications into body-schema

### Phase 3: Thyra Integration
1. ⏳ Display notification badges on oikoi
2. ⏳ Call mark-oikos-seen on view
3. ⏳ Show body-schema context to Claude

---

*This document prepared from kosmos session 2026-01-30.*
*Implementing team: chora/soma*
