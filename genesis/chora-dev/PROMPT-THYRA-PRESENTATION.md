# Thyra Presentation — Modes as the Unifying Concept

*Prompt for Claude Code in the chora + kosmos repository context.*

*Completes the mode architecture: retires hud-region from politeia, fixes affordance desmoi, and implements mode switching. After this work, modes are the sole mechanism through which topoi become spatially present, and the affordance system cleanly connects capabilities to actions without spatial middlemen.*

---

## Architectural Principle — Mode Is Topos Presence

A mode is how a topos presents itself in a spatial position. A topos with no modes is invisible. A topos with modes is spatially present.

The hierarchy is:

```
thyra-config          ← which modes are active + window behavior
  └── mode            ← topos presence in a spatial position
       ├── render-spec   ← declarative widget tree (bonded)
       │    └── widget   ← leaf rendering primitives
       └── actuality-mode   ← substrate requirements (bonded)
```

This hierarchy is **fully implemented** — the layout engine fetches `thyra-config/workspace`, resolves modes, groups by spatial position, and renders through render-specs. The widget interpreter is domain-agnostic (35+ widget types, no eidos-specific code).

---

## What's Been Done

The legacy presentation layer has been removed across all topoi:

**Deleted files:**
- `genesis/thyra/entities/panel-renderers.yaml` — renderer bridge entities
- `genesis/thyra/praxeis/opsis.yaml` — 34KB of dead rendering praxeis
- `genesis/thyra/RENDERING-ONTOLOGY.md` — doc describing dead system
- `genesis/chora-dev/render-specs/panel-renderers.yaml` — chora-dev renderer entities
- `genesis/chora-dev/entities/panels.yaml` — dead layout + panel entities
- `genesis/my-nodes/entities/layout.yaml` — dead mode with legacy regions
- `genesis/politeia/entities/panel-renderers.yaml` — politeia renderer bridge

**Cleaned from spora.yaml:**
- `eidos/renderer` definition, 8 render-type entities, 3 renderer entities, 3 renders-with bonds
- 4 hud-region seed entities, 4 renders-in bonds
- `typos-def-panel`, `typos-def-hud-region` from definitions

**Cleaned from arche:**
- 3 dead rendering desmoi (`renders-with`, `displays-in`, `uses-renderer`) from `arche/desmos.yaml`

**Cleaned from hodos:**
- `get-panel-render-data` praxis, `panel_id` field from waypoint eidos and entities, grants-praxis bond

**Completed architecture:**
- `desmos/uses-render-spec` defined and bonded (6 mode → render-spec bonds)
- DESIGN.md rewritten for modes-only architecture
- RENDER-SPEC-GUIDE.md updated to show mode connection instead of renderer entities

**Build:** 328 tests pass, zero failures.

---

## What Remains

### 1. Retire hud-region from politeia

The `hud-region` eidos, its three desmoi, and two praxeis exist in politeia but **nothing reads them**:
- Zero UI references to `hud-region`, `surfaces-as`, `enabled-by`, `renders-in`
- Zero runtime Rust references
- The praxeis (`create-hud-region`, `list-hud-regions`) are never called
- The `create-affordance` praxis creates `renders-in` bonds to hud-regions that nothing traverses

**Why hud-region retires:** In the mode architecture, spatial placement is a property of modes — a mode declares its spatial position directly. There's no need for a separate entity representing the slot. The concept of "where things appear" lives in modes, not in hud-regions.

**The desmos confusion:** The existing desmoi are semantically broken:
- `desmos/surfaces-as` is defined as `from_eidos: affordance, to_eidos: hud-region` — but the actual seed bonds use it for `attainment → affordance` (a completely different relationship)
- `desmos/enabled-by` is defined as `from_eidos: hud-region, to_eidos: attainment` — but the actual seed bonds use it for `affordance → attainment`

The *relationships* being expressed are valuable:
- "This attainment surfaces as this affordance" (attainment → affordance via `surfaces-as`)
- "This affordance requires this attainment" (affordance → attainment via `enabled-by`)

But the desmos definitions point at `hud-region`, not at the eide actually being bonded. When hud-region retires, these desmoi need to be fixed to match their actual usage.

**Changes:**

| File | Change |
|------|--------|
| `genesis/politeia/eide/politeia.yaml` | Remove `eidos/hud-region` |
| `genesis/politeia/desmoi/politeia.yaml` | Remove `desmos/renders-in`. Fix `desmos/surfaces-as` to `from_eidos: attainment, to_eidos: affordance`. Fix `desmos/enabled-by` to `from_eidos: affordance, to_eidos: attainment`. |
| `genesis/politeia/praxeis/politeia.yaml` | Delete `create-hud-region` and `list-hud-regions` praxeis (entire HUD REGION OPERATIONS section). Remove `region_id` param and `renders-in` bond from `create-affordance`. |
| `genesis/politeia/manifest.yaml` | Remove `renders-in` from desmoi list, remove hud-region praxeis |
| `genesis/politeia/DESIGN.md` | Remove hud-region eidos section, update affordance section, remove hud-region praxeis |
| `genesis/politeia/REFERENCE.md` | Remove hud-region references |
| `genesis/arche/desmos.yaml` | Already cleaned — `renders-with`, `displays-in`, `uses-renderer` removed |
| `genesis/spora/spora.yaml` | Already cleaned — hud-region entities and renders-in bonds removed |

**Attainment cleanup:** `attainment/hud` exists in politeia to gate hud-region operations. With those praxeis removed, check whether `attainment/hud` still grants anything — if not, remove it.

### 2. Mode switching

The mode architecture is static — `thyra-config/workspace` is hardcoded in the layout engine. Mode switching makes it dynamic.

**What to build:**
1. **`praxis/thyra/switch-config`** — updates the active thyra-config
2. **`thyra-config/hud`** — a compact overlay config (at minimum, alongside workspace)
3. **Layout engine change** — make config ID a signal or preference entity instead of hardcoded `"thyra-config/workspace"`

The exact mechanism for config selection is a design decision:
- (a) A well-known settings entity with `active_config_id`
- (b) Parousia-scoped preference
- (c) The layout engine watches a signal

**Note:** Mode switching depends on the reactive loop to be truly dynamic (a reflex triggers config change in response to context). Without the reactive loop, mode switching is manual — invoked explicitly through the praxis. This is still valuable (user can switch views) but not yet autonomous.

---

## Implementation Order

### Step 1: Politeia hud-region retirement

1. Remove `eidos/hud-region` from `genesis/politeia/eide/politeia.yaml`
2. Fix `desmos/surfaces-as` definition: `from_eidos: attainment, to_eidos: affordance`
3. Fix `desmos/enabled-by` definition: `from_eidos: affordance, to_eidos: attainment`
4. Remove `desmos/renders-in` from `genesis/politeia/desmoi/politeia.yaml`
5. Delete `create-hud-region` and `list-hud-regions` praxeis from `genesis/politeia/praxeis/politeia.yaml`
6. Clean `create-affordance` praxis: remove `region_id` param and `renders-in` bond creation
7. Update `genesis/politeia/manifest.yaml`
8. Update `genesis/politeia/DESIGN.md` and `genesis/politeia/REFERENCE.md`
9. Check and potentially remove `attainment/hud`

### Step 2: Mode switching

10. Define `praxis/thyra/switch-config` in `genesis/thyra/praxeis/thyra.yaml`
11. Define `thyra-config/hud` in `genesis/thyra/entities/layout.yaml`
12. Update layout engine config resolution in `app/src/lib/layout-engine.tsx`

### Step 3: Verify

13. `cargo build && cargo test` — all tests pass
14. Verify no hud-region references remain:
    ```bash
    rg 'hud-region|renders-in' genesis/ --glob '*.yaml'
    # Should only show desmos definition comments if any
    ```
15. `just dev` — verify modes render correctly

---

## Broader Context — Where This Sits

This prompt completes the presentation architecture. Three arcs remain for the project:

1. **Complete** (this prompt) — retire hud-region, implement mode switching. Finishes the ground.
2. **Found** (needs its own prompt) — the reactive loop. Reflexes detect mutations, reconcilers decide, actuality modes act. This is what makes the system alive.
3. **Explore** (PROMPT-GENERATIVE-SPIRAL.md exists) — the kosmos generating itself. Start with one experiment: generate a render-spec from an eidos using governed-inference.

The reactive loop prompt should follow the same pattern as this one and the session boundary prompt: map the territory, design the target state, sequence the work.

---

## What This Enables

When hud-region retires and mode switching works:
- **One spatial mechanism** — modes are it. No competing region/panel/layout/renderer concepts anywhere in genesis.
- **Affordance desmoi match their usage** — `surfaces-as` and `enabled-by` correctly describe attainment ↔ affordance relationships
- **Mode switching is a praxis** — thyra-config is dynamic. Users can switch between workspace/hud/compact views.
- **The generative spiral has clean context** — no legacy confusion when generating render-specs, modes, or affordance bonds
- **Future sessions start clean** — no dead code to navigate around, no semantic confusion in desmos definitions
