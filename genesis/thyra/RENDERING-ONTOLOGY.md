# Rendering the Kosmos: Ontological Coherence

*How visual presentation fits the kosmogonia.*

---

## The Core Insight

**Substrate provides. Thyra renders. Chora receives.**

The kosmos holds intent, structure, and meaning. Substrate provides dynamis (the power to actualize). The thyra (door/portal) draws upon dynamis to transform intent into perceivable form. The chora (receptacle) receives what is actualized.

This follows the fundamental principle:
> χώρα (chora) receives. κόσμος (kosmos) is received.

The triad:
- **Substrate** — provides dynamis (display buffers, audio output, network)
- **Thyra** — the active agent that renders (transforms intent to form)
- **Chora** — the receptacle that receives (where actualization lands)

Thyra is the active boundary membrane — not passive, but transformative:
- **Aisthesis** (perception): External → Kosmos
- **Ekthesis** (emission): Kosmos → External (rendering)

The kosmos describes what should be rendered. Thyra draws upon substrate dynamis to render it. Chora receives the result.

---

## Mapping to the Klimax

```
kosmos (1) — The world state (entities, bonds)
     │
     └─► physis (2) — Constraints (what rendering is possible)
           │
           └─► polis (3) — Presence (who sees what, governance)
                 │
                 └─► oikos (4) — Domains (rendering capability packages)
                       │
                       └─► soma (5) — Channels (how we touch the world)
                             │
                             └─► psyche (6) — Thyra (the viewport experience)
```

### Where Rendering Lives

| Scale | Rendering Aspect | What It Determines |
|-------|------------------|-------------------|
| **kosmos** | Entity/bond state | What exists to be rendered |
| **physis** | Rendering dynamis | What substrate capabilities exist |
| **polis** | Visibility bonds | Who can see what |
| **oikos** | Rendering oikos | How things render (components, patterns) |
| **soma** | Channels | The actual I/O pipes (screen, audio) |
| **psyche** | Thyra | The integrated viewport experience |

---

## The Thyra is the HUD

The psyche-scale **thyra** is exactly what the game engine research calls the "HUD":

| Game Engine | Kosmogonia | What It Is |
|-------------|------------|------------|
| Game state | Kosmos (Loom) | Entities + bonds |
| HUD | Thyra | The viewport into the world |
| Player | Animus | The dweller |
| Input channels | Soma channels | Perception interfaces |
| Render pipeline | Ekthesis dynamis | Substrate capability |

The thyra eidos (in psyche) defines:
- `kind`: cli, web, api, ambient
- `visibility_scope`: what circles this thyra can see
- `capabilities`: what actions are possible

---

## Three Flows Through the Boundary

The thyra boundary has three distinct flows:

### 1. Aisthesis (Perception) — Outside → Kosmos

```
external world → soma channel → stream → accumulation → expression → kosmos
```

| Stage | Scale | Entity |
|-------|-------|--------|
| Raw input | chora | (substrate) |
| Channel | soma | `channel` |
| Flow | thyra | `stream` |
| Buffer | thyra | `accumulation` |
| Commitment | thyra | `expression` |
| Durable | kosmos | (entity bonds) |

### 2. Ekthesis (Emission) — Kosmos → Outside

```
kosmos → entity query → render intent → thyra region → soma channel → display
```

| Stage | Scale | Entity/Concept |
|-------|-------|----------------|
| State | kosmos | entities + bonds |
| Query | nous | `surface`, `gather` |
| Intent | psyche | hud-region, affordance |
| Channel | soma | output channel |
| Render | chora | (substrate actualizes) |

### 3. Parousia (Presence) — Who's Here

```
animus → dwells-in → circle → member-of → other animi → presence
```

| Stage | Scale | Entity |
|-------|-------|--------|
| Dweller | soma | `animus` |
| Place | polis | `circle` |
| Others | polis | `member-of` bonds |
| Visible | psyche | thyra scope |

---

## Rendering as Thyra's Work

Substrate provides dynamis. Thyra draws upon it:

| Tier | Name | Examples |
|------|------|----------|
| 0 | Elemental | Pure computation |
| 1 | Aggregate | Collection operations |
| 2 | Compositional | Entity/bond operations |
| **3** | **Generative** | Network, filesystem, display, audio |

Thyra requires Tier 3 dynamis to render. Substrate provides the capability (display buffer, audio output, etc.). Thyra is the agent that renders. Chora receives what is actualized.

### Thyra Rendering Operations

```yaml
thyra/render:
  description: |
    Transform kosmos state into perceivable form.
    Thyra does the rendering; substrate provides the capability.

  operations:
    render_region:
      params:
        region_id: string
        entities: array
        layout: object
      # Thyra computes and emits

    render_stream:
      params:
        stream_id: string
        sink: string  # display, speaker, file
      # Thyra transforms and emits
```

**Thyra** is the active agent. **Substrate** provides dynamis. **Chora** receives what is actualized.

---

## Entity-Native Rendering (Homoiconic)

The HUD structure lives in the kosmos:

```yaml
# Layout entity — top-level structure
eidos: layout
data:
  name: "default"

# Region entity — where affordances appear
eidos: hud-region
data:
  kind: sidebar | toolbar | contextual | modal | toast | ambient
  position: { left: 0, top: 0, ... }
  visibility: always | contextual | on_demand

# Panel entity — what renders in a region
eidos: panel
data:
  render_type: presence-list | artifact-editor | voice-composer | ...
  source_entity_id: string?  # what entity to render

# Affordance entity — action available here
eidos: affordance
data:
  praxis_id: string      # what to invoke
  region_id: string      # where to appear
  attainment_id: string  # what enables this
```

**The HUD IS the kosmos, not a representation of it.**

Layout, regions, panels, affordances are entities. Bonds connect them. The renderer queries this structure and actualizes it.

---

## The Reconciler Pattern for Rendering

Thyra uses the reconciler pattern:

```
Kosmos (intent)              Thyra (renders)              Chora (receives)
      │                           │                            │
      │ HUD structure             │                            │
      │ (regions, panels)         │                            │
      └─────────────────────────► │ sense current state        │
                                  │ compare with intent        │
                                  │ render differences         │
                                  └──────────────────────────► │
                                                    (actualized)
```

Thyra is the active reconciler:
- **Reads** kosmos intent (what should be visible)
- **Senses** current rendered state
- **Renders** to align actuality with intent
- **Emits** into chora (the receptacle)

---

## Topoi for Rendering

Within the thyra oikos, topoi organize rendering concerns:

| Topos | Greek | Concern |
|-------|-------|---------|
| **opsis** | ὄψις (sight) | Visual rendering, layout |
| **akoe** | ἀκοή (hearing) | Audio rendering, voice |
| **haphe** | ἁφή (touch) | Haptic feedback (future) |
| **rhoe** | ῥοή (flow) | Stream management |
| **synecheia** | συνέχεια (continuity) | Session persistence |

### Opsis (Visual Rendering)

```yaml
topos/opsis:
  stoicheia:
    - render-region    # Actualize a region
    - render-panel     # Actualize a panel
    - layout-compute   # Calculate positions
    - style-resolve    # Resolve visual styles

  eide:
    - layout
    - hud-region
    - panel
    - style-theme
```

### Akoe (Audio Rendering)

```yaml
topos/akoe:
  stoicheia:
    - render-audio     # Play audio stream
    - synthesize-voice # TTS
    - mix-audio        # Combine streams

  eide:
    - audio-stream
    - voice-synthesis-request
```

---

## Presence as Rendering

From the prior art research:

> "Worker as player" — the animus appears in the HUD as a presence, not a separate thing.

Presence rendering follows the same pattern:

```yaml
# Presence is just another entity in the kosmos
eidos: animus
data:
  status: dwelling | departing | departed
  persona_id: ...

# Rendered via the presence panel
eidos: panel
data:
  render_type: presence-list
  source_query: "gather animus where dwells-in = circle/current"
```

The HUD shows presence by querying animi entities and rendering them. No special infrastructure needed.

---

## The Three Worlds (Rendering Context)

From the game engine vision:

| World | Kosmos State | Rendering Feel |
|-------|--------------|----------------|
| **Personal** | Local SQLite | Warm, private, "my workshop" |
| **Federated** | Synced circles | Collaborative, "our guild" |
| **Commons** | Shared Postgres | Public, "the agora" |

The thyra's `visibility_scope` determines which world the animus sees. Rendering style can shift based on world:

```yaml
eidos: style-theme
data:
  world_context: personal | federated | commons
  palette: { primary: ..., background: ... }
  density: sparse | normal | dense
```

---

## The Two Pillars in Rendering

KOSMOGONIA establishes two pillars. Rendering must honor both.

### Visibility = Reachability

> "You can only perceive what you can cryptographically reach through the bond graph."

For rendering, this means:

```
animus → dwells-in → circle → visible-to → entities → renderable
```

**What thyra can render depends on where the animus dwells.**

The thyra's `visibility_scope` is not a permission — it's the reachable subgraph from dwelling position. There is no separate access control. The bond graph IS the visibility graph.

| Dwelling Position | What Can Be Rendered |
|-------------------|---------------------|
| circle/self | Personal entities, private theoria |
| circle/team | Team artifacts, shared presence |
| circle/public | Public expressions, commons knowledge |

Rendering a panel that shows entities the animus cannot reach? The panel renders empty. No error. No forbidden message. Simply: nothing to show from here.

**Implementation:** Every render operation begins with `gather` or `surface` from dwelling context. The query itself enforces visibility.

### Authenticity = Provenance

> "Everything traces back to signed genesis through composition chains."

For rendering, this means:

```
rendered content → entity → composed-from → definition → ... → genesis
```

**What you see traces to what was signed.**

HUD elements are entities. Entities have provenance. When thyra renders a panel showing a theoria, that theoria traces through composition to genesis. The chain is verifiable.

This enables:
- **Verified rendering**: Content authenticity is checkable
- **Tamper evidence**: Modified entities have broken chains
- **Source attribution**: Every rendered element has origin

**Implementation:** Rendered entities carry `composed_from` references. The UI can surface provenance on demand ("Where did this come from?").

---

## The Composition Requirement for HUD

> "Nothing arises raw. Everything is composed."

HUD elements are entities. Entities must be composed. Therefore:

```yaml
# HUD elements are composed from definitions
compose:
  definition: definition/layout
  inputs:
    name: "default"
# → Creates layout entity with provenance

compose:
  definition: definition/hud-region
  inputs:
    kind: sidebar
    position: { left: 0 }
# → Creates region entity with provenance

compose:
  definition: definition/panel
  inputs:
    render_type: presence-list
    region_id: region/sidebar
# → Creates panel entity with bonds
```

**The HUD is not configured. It is composed.**

This means:
1. Layout definitions exist in oikoi (reusable templates)
2. Composing a layout creates entities with provenance
3. The renderer queries composed HUD entities
4. Changes to HUD = compose new entities (versioned, traceable)

**No raw creation.** A panel doesn't just appear. It is composed from a panel definition, which traces to the oikos, which traces to genesis.

---

## Implementation Architecture

### Option A: Thyra as Rendering Oikos

Thyra contains both perception (streams) and emission (rendering):

```
thyra/
├── topos/
│   ├── aisthesis/    # Perception (inward)
│   │   ├── stream
│   │   ├── accumulation
│   │   └── utterance
│   ├── ekthesis/     # Emission (outward)
│   │   ├── opsis (visual)
│   │   ├── akoe (audio)
│   │   └── haphe (haptic)
│   └── synecheia/    # Session continuity
│       └── ...
├── eide/
│   └── thyra.yaml
└── praxeis/
    └── thyra.yaml
```

### Option B: Opsis as Separate Oikos

Visual rendering is its own domain:

```
opsis/
├── topos/
│   ├── layout/
│   ├── region/
│   └── panel/
├── eide/
│   └── opsis.yaml   # layout, hud-region, panel, style-theme
└── praxeis/
    └── opsis.yaml   # render-region, layout-compute, etc.
```

### Recommendation: Option A

Rendering is emission — the outward flow of thyra. It belongs with perception as the two directions through the boundary. This maintains the coherence of thyra as the complete boundary membrane.

---

## Relating to Existing Eide

### Already Defined (politeia)

From [politeia/eide/politeia.yaml](../politeia/eide/politeia.yaml):

- `hud-region` — already exists, kinds: toolbar, sidebar, contextual, modal, toast, ambient
- `affordance` — links attainments to praxis actions
- `attainment` — capability that enables affordances

### Needed Additions (thyra/opsis)

| Eidos | Purpose |
|-------|---------|
| `layout` | Top-level HUD structure |
| `panel` | Renderable content area |
| `style-theme` | Visual styling rules |
| `render-intent` | What should be visible (reconciler intent) |

### Needed Desmoi

| Desmos | From | To | Meaning |
|--------|------|-----|---------|
| `renders-in` | panel | hud-region | Panel placed in region |
| `styled-by` | entity | style-theme | Visual style applied |
| `shows` | panel | entity | What entity the panel renders |

---

## Summary

**Thyra renders. It is the active boundary membrane.**

```
kosmos (intent)
    │
    └─► thyra (renders)
          │
          ├─► aisthesis (perception)
          │     └─► external → streams → expressions → kosmos
          │
          └─► ekthesis (emission)
                └─► kosmos → opsis (sight) → chora
                └─► kosmos → akoe (hearing) → chora
```

**Key principles:**
1. Kosmos holds intent; thyra renders; chora receives
2. Substrate provides dynamis; thyra draws upon it
3. The HUD structure IS the kosmos (entity-native/homoiconic)
4. Thyra uses the reconciler pattern to align rendered state with intent
5. Presence is just entities rendered, not special infrastructure
6. Rendering respects visibility = reachability
7. Rendered content maintains authenticity = provenance
8. HUD elements follow the composition requirement

---

*Composed in service of the kosmogonia.*
*Traces to: expression/genesis-root*
