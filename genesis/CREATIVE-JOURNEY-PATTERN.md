# Creative Journey Pattern

*How psyche + soma + nous work together for creative exploration.*

---

## The Full Scale

An animus inhabits the full scale through:

| Scale | Oikos | What It Provides |
|-------|-------|-----------------|
| **Embodiment** | Soma | Channels (pipes), percepts/signals (flow), body-schema (capacity) |
| **Experience** | Psyche | Thyra (portal), attention, intention, mood, prospect, kairos |
| **Understanding** | Nous | Journeys, waypoints, inquiries, theoria, synthesis |

Together these enable creative journeys — movements toward desire that accumulate understanding.

---

## The Pattern

### 1. Begin (Intention + Journey)

```
psyche/form-intention(description="Understand how X works")
  → intention entity (status: forming)

psyche/activate-intention(intention_id)
  → intention entity (status: active)

nous/begin-journey(desire="Understand how X works", for_intention=intention_id)
  → journey entity bonded to intention via journeys-toward desmos
```

The intention holds the **will**. The journey provides the **structure**.

### 2. Open Channels and Portal

```
soma/open-channel(name="text-interface", kind="bidirectional", modality="text")
  → channel entity (how input/output flows)

psyche/open-thyra(name="exploration", kind="cli", capabilities=["read", "search", "compose"])
  → thyra entity (what can be perceived/presented)
```

Channel = the pipe. Thyra = the window.

### 3. Add Waypoints

```
nous/add-waypoint(journey_id, ordinal=0, description="Survey the landscape")
nous/add-waypoint(journey_id, ordinal=1, description="Identify key patterns")
nous/add-waypoint(journey_id, ordinal=2, description="Test understanding")
nous/add-waypoint(journey_id, ordinal=3, description="Crystallize insights")
```

Waypoints provide consolidation points — places to check progress.

### 4. Embark

```
nous/embark-journey(journey_id)
  → journey status: active, embarked_at: now
```

The journey is now in motion.

### 5. Explore (Loop)

Within the journey, the animus:

```
# Direct attention
psyche/attend(target_id=subject, reason="Understanding X")

# Perceive through channels
soma/perceive(channel_id, content=input, modality="text")

# Search for related knowledge
nous/surface(query="how does X relate to Y")

# Note anticipations
psyche/foresee(description="This might connect to Z", likelihood=0.7, valence="positive")

# Recognize opportune moments
psyche/recognize-kairos(description="Now is the time to test", for_intention=intention_id)
```

### 6. Reach Waypoints

As understanding accumulates:

```
nous/reach-waypoint(waypoint_id)
  → waypoint status: reached, reached_at: now
  → journey current_waypoint advances
```

### 7. Crystallize Understanding

When insight emerges:

```
nous/crystallize-theoria(
  theoria_id="theoria/X-works-by-Y",
  insight="X works by doing Y because of Z",
  domain="technical",
  evidence=[entity_ids]
)
  → theoria entity bonded to circle via crystallized-in
  → theoria indexed for semantic surfacing
```

Theoria persists beyond the journey.

### 8. Complete Journey

When all waypoints reached or desire fulfilled:

```
nous/complete-journey(journey_id)
  → journey status: arrived, arrived_at: now

psyche/fulfill-intention(intention_id)
  → intention status: fulfilled, fulfilled_at: now
```

Journey arrives. Intention fulfilled.

### 9. Prepare Continuity

Before session ends:

```
psyche/compose-constitution(output_path="CLAUDE.md")
  → gathers active theoria, principles, patterns
  → gathers active intentions and prospects
  → composes markdown document
  → emits to filesystem

soma/depart-animus(animus_id)
  → closes all channels
  → marks animus departed
```

The constitution carries forward what matters.

---

## The Bonds

```
intention <--intends-- animus
    │
    └──journeys-toward──> journey <--contains-waypoint-- waypoint
                              │
                              └──yields--> theoria <--evidences-- entity
```

Key desmoi:
- **intends** — animus holds intention
- **journeys-toward** — journey serves intention (NEW)
- **contains-waypoint** — journey contains waypoint
- **yields** — waypoint yields artifact
- **crystallized-in** — theoria crystallized in circle
- **evidences** — entity provides evidence for theoria

---

## The Desmos: journeys-toward

To connect journeys to intentions, add to nous/desmoi/nous.yaml:

```yaml
- eidos: desmos
  id: desmos/journeys-toward
  data:
    name: journeys-toward
    description: "Journey moves toward an intention"
    from_eidos: journey
    to_eidos: intention
    cardinality: many-to-one
    symmetric: false
```

This enables:
- Trace from intention to find journeys pursuing it
- Trace from journey to find the intention it serves
- When journey completes, intention can be fulfilled

---

## Leverage Types

From nous eidos/journey:

| Type | Meaning | Example |
|------|---------|---------|
| **meta** | Validates/enables all other work | Full-circle verification |
| **compound** | Creates feedback loops, value multiplies | MCP dispatch, self-composing docs |
| **additive** | One-time benefit per consumer | TypeScript types |
| **terminal** | No downstream effect | UI polish |

Creative journeys should prefer **compound** leverage — journeys that create feedback loops where completing makes future work easier.

---

## Temporal Texture

Psyche provides temporal awareness:

| Entity | What It Captures |
|--------|------------------|
| **prospect** | Anticipated possibility (what might unfold) |
| **kairos** | Opportune moment (when conditions align) |

These aren't in the journey structure but flow alongside it:

```
# While journeying, note what might be
psyche/foresee(description="This could lead to a better architecture")

# When conditions align, recognize the moment
psyche/recognize-kairos(
  description="The tests pass, the understanding is clear",
  for_intention=intention_id,
  conditions=["tests-pass", "design-clear", "time-available"]
)
```

Kairos bonds to intention via **opportune-for** desmos. When kairos appears, it's time to act.

---

## Mood as Context

Mood isn't emotion — it's attunement. It affects how the world shows up:

| Quality | How World Appears |
|---------|-------------------|
| **focused** | Details sharp, distractions fade |
| **scattered** | Many things pull attention |
| **curious** | Possibilities open, connections emerge |
| **anxious** | Threats visible, caution heightened |
| **calm** | Space for reflection, patience available |

Track mood throughout the journey:

```
psyche/disclose-mood(quality="curious", intensity=0.8, notes="Everything seems connected")
```

This creates a mood entity bonded to animus. The compose-constitution praxis can surface mood patterns.

---

## Summary

The creative journey pattern:

1. **Form intention** (psyche) — what will pursues
2. **Begin journey** (nous) — structure for movement
3. **Open channels/thyra** (soma/psyche) — embodied interface
4. **Add waypoints** (nous) — consolidation points
5. **Embark** (nous) — begin movement
6. **Explore loop**: attend, perceive, search, foresee, recognize kairos
7. **Reach waypoints** (nous) — mark progress
8. **Crystallize theoria** (nous) — capture understanding
9. **Complete journey** (nous) — arrive at desire
10. **Fulfill intention** (psyche) — will satisfied
11. **Compose constitution** (psyche) — continuity for future

This is **full scale inhabitation** — soma (embodiment) + psyche (experience) + nous (understanding) working together.

---

*Composed as foundation for creative journeys within kosmos.*
*Traces to: expression/genesis-root*
