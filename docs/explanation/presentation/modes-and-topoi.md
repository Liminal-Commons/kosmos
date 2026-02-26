# Modes and Topos

How topoi become present through modes, and why layout is emergent.

---

## The Core Insight

A mode is how a topos presents itself in a spatial position. A topos that has no modes is invisible. A topos that has modes is present. Thyra is the space where topoi become present through their modes.

This emerges from a simple observation: some topoi need to render things (voice controls, authoring feeds, node dashboards), while others operate purely behind the scenes (demiurge composes artifacts, dynamis bridges substrates). The difference is whether the topos declares a mode.

---

## What a Mode Declares

A mode makes three declarations:

1. **What renders** — a render-spec (widget tree)
2. **What substrates it needs** — modes (voice capture, WebRTC, etc.)
3. **Where it sits** — spatial position and size

These three declarations together define the topos's presence. Compose-full renders a bar with mic controls, transcription toggle, stance badge, clarify, and express — needs no special substrate and sits at the bottom. Phasis-feed renders phasis bubbles, needs no special substrate, and fills the center.

---

## Mode Boundaries

If two configurations of a spatial position differ in what substrates they need, they are different modes.

Compose-full and compose-transcribing are different modes because they have different render-specs — one has an editable textarea, the other has a readonly textarea with transcribing placeholder. The transcriber toggle switches modes via reflex.

This is the ontological ground: **modes are the unit of substrate requirement**. Each mode has a single definitive render-spec with no conditionals. Substrate differences define mode boundaries. Presentational differences define mode boundaries too — if the UI looks different, it's a different mode.

---

## Layout Is Emergent

There is no layout entity. Layout is the consequence of which modes are active and what they declare spatially.

If `mode/compose-full` declares `position: bottom, height: auto` and `mode/phasis-feed` declares `position: center, height: fill`, the layout is two regions stacking naturally. Layout emerges from the active modes' spatial declarations.

Regions are just the names we give to positions that modes claim. They don't need to exist as entities.

---

## Thyra Configuration

A thyra configuration is a set of active modes plus window behavior:

- **Workspace**: multiple modes active, full window
- **HUD**: reserved — no active modes (empty set)

Switching thyra configuration simultaneously activates/deactivates modes and changes window behavior. Docking, undocking, and window size are thyra configuration changes — distinct from topos mode selection within that configuration.

Common configurations ship as defaults. Users can create their own.

---

## The Topos Spectrum

A topos's nature is revealed by what it declares:

| Nature | Presentation Modes | Infrastructure Modes | Example |
|--------|-------------------|---------------------|---------|
| Pure thought | None | None | demiurge — composes artifacts, no UI, no substrate |
| Infrastructure | None | Yes | dynamis — bridges substrates, no UI |
| Presence only | Yes | None | authoring — renders feed, no special substrate |
| Embodied | Yes | Yes | voice — renders controls, needs microphone |

Thyra doesn't contain topoi. Thyra is where topoi that have modes become spatially present. The demiurge works whether or not thyra is running. Voice only manifests when its mode is active.

---

## Relationship to Render-Specs

Render-specs are the widget trees that modes use. Each mode references exactly one render-spec. The render-spec knows nothing about modes — it's just a declarative widget composition with entity bindings.

The layering:
- **Thyra config** → which modes are active, window behavior
- **Mode** → which render-spec to use, spatial position, substrate requirements
- **Render-spec** → widget tree with bindings
- **Widget** → DOM rendering primitive

Each layer is an entity. Each layer is declarative. Each layer is domain-agnostic except at the render-spec level, where entity bindings connect to domain data.

---

## Relationship to Infrastructure Modes

Infrastructure modes define how substrates manifest:

- **manifest**: Start the substrate (open mic, connect WebRTC)
- **sense**: Query substrate state without modifying it
- **unmanifest**: Clean up (close mic, disconnect)

When a mode that requires an infrastructure mode becomes active, the substrate manifests. When the mode deactivates, the substrate unmanifests. This is the reconciliation loop — intent (mode active) reconciles with actuality (substrate running).

---

## Related

- [Modes as Topoi](modes-as-topoi.md) — Why modes are independent packages (architectural organization)
- [Thyra Topos](thyra-topos.md) — Full UI ontology design (comprehensive)
- [Mode Development](../how-to/presentation/mode-development.md) — Recipes for creating modes
- [Mode Reference](../../reference/presentation/mode-reference.md) — Widget and render-spec schemas

---

*Understanding crystallized from conversation — voice authoring mode redesign, February 2026.*
