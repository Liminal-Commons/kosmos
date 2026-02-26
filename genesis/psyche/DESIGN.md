# Psyche Design

ψυχή (psyche) — the experiencing self.

## Ontological Purpose

What gap in being does psyche address?

**The gap between presence and experience.** Without psyche, a parousia can dwell and act through soma but has no inner life — no attention, no intention, no mood, no sense of what interface is available or what might happen next.

Psyche provides:
- **Attention** — where focus rests (the beam of awareness)
- **Intention** — what is being pursued (directedness of will)
- **Mood** — how the world shows up (attunement, not emotion)
- **Perceptual Field** — awareness of the portal interface available
- **Prospect** — anticipated possibilities
- **Kairos** — recognition of opportune moments

## Boundary: Psyche vs Thyra

A key distinction in the kosmos:

| Aspect | Psyche (perceptual-field) | Thyra (topos) |
|--------|--------------------------|---------------|
| **Nature** | Subjective awareness | Objective infrastructure |
| **Concerns** | What interface do I have? What can I perceive? | Streams, accumulation, voice pipeline, app config |
| **Entities** | `perceptual-field` (kind, capabilities, visibility) | `stream`, `accumulation`, `utterance`, `voice-pipeline-config` |
| **Perspective** | First-person: "my portal" | Third-person: "the portal system" |
| **Bond** | `portal-of` → parousia | Streams bonded to thyra infrastructure |

**Psyche's perceptual-field** answers: "What kind of interface does this parousia have? What can it perceive through it? What actions are possible?"

**Thyra topos** answers: "How do streams flow? How is voice captured and accumulated? How are phasis committed?"

The perceptual-field is bonded to a parousia via `portal-of` — it is always someone's awareness of their portal. Thyra infrastructure exists independently of any particular parousia.

### Historical Note

The perceptual-field eidos was originally named `thyra` within psyche, which created a naming collision with the thyra topos. Renamed to `perceptual-field` to clarify that psyche models the subjective experience of having a portal, not the portal itself.

## Core Entities (Eide)

### attention
Where focus currently rests. The beam of awareness.
- `target_id` — what is being attended to
- `weight` — focus intensity (0.0 to 1.0)
- `reason` — why attending
- `since` — when attention began

### intention
What is being pursued. The directedness of will.
- `description` — what the intention is about
- `status` — forming, active, suspended, fulfilled, abandoned
- `priority` — importance level
- `formed_at` / `fulfilled_at` — lifecycle timestamps

### mood
How the world shows up. Not emotion but attunement.
- `quality` — focused, scattered, anxious, calm, curious, etc.
- `intensity` — strength (0.0 to 1.0)
- `disclosed_at` — when the mood was disclosed

### perceptual-field
The parousia's subjective awareness of its portal interface.
- `name` — identifier for this perceptual field
- `kind` — type of interface (cli, web, api, ambient)
- `visibility_scope` — oikos IDs perceivable through this field
- `capabilities` — what actions are possible
- `status` — open, closed, suspended

### prospect
Anticipated possibility. Not prediction but sense of what might unfold.
- `description` — what is anticipated
- `likelihood` — subjective sense (0.0 to 1.0)
- `valence` — positive, negative, neutral, mixed
- `horizon` — immediate, near, far

### kairos
The opportune moment. When conditions align for action.
- `description` — what makes this moment opportune
- `for_intention` — which intention this serves
- `conditions` — what has aligned
- `expires_at` — when the opportunity closes

## Bonds (Desmoi)

| Bond | From | To | Meaning |
|------|------|----|---------|
| `attends` | parousia | any | Where awareness is directed |
| `intends` | parousia | intention | What will is pursuing |
| `mood-of` | mood | parousia | How the world shows up for this being |
| `portal-of` | perceptual-field | parousia | Through what interface experience flows |
| `foresees` | parousia | prospect | What possibilities are anticipated |
| `recognizes` | parousia | kairos | What opportune moments are perceived |
| `opportune-for` | kairos | intention | Which intentions a kairos serves |

## Operations (Praxeis)

### Attention
- **attend** — Direct attention to something
- **release-attention** — Release attention from something
- **list-attending** — List what is being attended to

### Intention
- **form-intention** — Form a new intention
- **activate-intention** — Activate a forming intention
- **fulfill-intention** — Mark as fulfilled
- **abandon-intention** — Mark as abandoned
- **list-intentions** — List intentions

### Mood
- **disclose-mood** — Disclose the current mood
- **sense-mood** — Sense moods of the parousia

### Perceptual Field
- **open-perceptual-field** — Open a portal awareness for the parousia
- **close-perceptual-field** — Close a perceptual field
- **list-perceptual-fields** — List perceptual fields

### Prospect and Kairos
- **foresee** — Note an anticipated possibility
- **recognize-kairos** — Recognize an opportune moment

### Continuity
- **compose-constitution** — Compose and emit CLAUDE.md for future sessions

---

*Psyche is the experiencing self — the attention that focuses, the intention that directs, the mood that colors, the awareness that perceives through its portal. Without psyche, presence acts but does not experience.*
