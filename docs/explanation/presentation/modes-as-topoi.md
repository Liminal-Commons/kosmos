# Explanation: Modes as Topoi

Why modes are structured as independent topoi rather than belonging to domain topoi.

---

## The Problem

Consider a mode that shows infrastructure: nodes, services, and connections.

**Option A: Mode belongs to domain topos**

```
genesis/soma/
├── eide/
├── render-specs/
│   └── node-list.yaml    # Mode render-specs in soma
└── entities/
    └── my-nodes-layout.yaml
```

This creates problems:
- The mode is "owned" by soma, but it might also show aither connection data
- Adding oikos awareness requires modifying soma
- The soma maintainer must understand UI concerns
- Cross-domain modes become awkward

**Option B: Mode as its own topos**

```
topoi/modes/my-nodes/
├── manifest.yaml         # Declares: depends_on [soma, aither]
├── entities/
└── render-specs/
```

This is cleaner:
- Mode declares dependencies explicitly
- Mode can compose entities from multiple topoi
- UI concerns isolated from domain logic
- Mode authors need not be domain experts

---

## Modes Compose Across Domains

A mode is a holistic experiential frame. Real experiences cross domain boundaries:

| Mode | Domains Involved |
|------|------------------|
| My Nodes | soma (nodes), aither (connections) |
| My Oikoss | politeia (oikoi), hypostasis (presence), logos (phaseis) |
| My Journeys | nous (journeys, waypoints), logos (phaseis) |
| Dwelling | All of the above |

No single domain topos should own these experiences. They emerge from composition.

---

## The Dependency Graph

Mode topoi declare what they consume:

```yaml
# mode/my-nodes manifest
depends_on:
  - soma       # Provides: node, service-instance, kosmos-instance
  - aither     # Provides: syndesmos (connection)
  - thyra      # Provides: widget vocabulary

surfaces_consumed:
  - node
  - service-instance
  - kosmos-instance
  - syndesmos
```

The bootstrap system loads dependencies before the mode. The mode never imports code from domain topoi — it only queries entities.

---

## Separation of Concerns

| Concern | Where It Lives |
|---------|----------------|
| What entities exist | Domain topos (eide) |
| What operations are possible | Domain topos (praxeis) |
| How entities relate | Domain topos (desmoi) |
| **How entities are experienced** | **Mode topos (layouts, panels, render-specs)** |

Domain topoi define **ontology**. Mode topoi define **experience**.

---

## Enabling the Mode Builder

When modes are topoi, they become discoverable and composable:

```yaml
# A future mode builder could query:
gather(eidos: layout)           # All available modes
trace(from: mode/my-nodes)      # Mode's dependencies
gather(topos_category: mode)    # All mode topoi
```

This enables:
- Mode marketplace — discover and install modes
- Mode composition — combine modes into workflows
- Mode customization — fork and modify existing modes
- Visual mode builder — drag-and-drop mode creation

---

## The Pattern

1. **Domain topoi** define what exists (eide, desmoi, praxeis)
2. **Mode topoi** define how things are experienced (layouts, panels, render-specs)
3. **Dependencies** are explicit in the manifest
4. **No code coupling** — modes query entities, not import modules

This is the ontological separation: being vs. appearing.

---

## Practical Benefits

**For mode authors:**
- Clear scope — just UI concerns
- Explicit dependencies — know what eide are available
- Isolated testing — mode works with any data source

**For domain maintainers:**
- No UI concerns in domain topos
- Can evolve eide without breaking modes (with versioning)
- Clear API surface — eide are the contract

**For users:**
- Install modes independently
- Switch modes without losing data
- Customize modes without touching domain logic

---

## Related Concepts

- **Layout** — Spatial arrangement of regions (the mode's structure)
- **Panel** — Positioned slot that renders via render-spec (the mode's slots)
- **Render-spec** — Widget composition (how entities appear)
- **Widget** — Atomic UI element (the building blocks)

The relationship:

```
Mode topos
└── Layout entity (regions)
    └── Panel entities (slots with render_type)
        └── Render-spec entities (widget trees)
            └── Widgets (primitives from thyra)
```

---

## Related

- [Modes and Topoi](modes-and-topoi.md) — How topoi become present through modes (ontological relationship)
- [Thyra Topos](thyra-topos.md) — Full UI ontology design
- [Mode Development](../../how-to/presentation/mode-development.md) — Recipes for creating modes
- [Create a Topos](../../tutorial/foundations/create-a-topos.md) — Building a domain package

---

*Modes are not about display. They are about dwelling.*
