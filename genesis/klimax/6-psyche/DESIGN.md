# Psyche: The Experiencing Self

*Where sensing becomes experience.*

---

## The Purpose

Psyche is scale 6 of 6 — the innermost scale where the experiencing self dwells. This is not just cognition but the full texture of being: attention, intention, mood, and the portal through which experience flows.

**Psyche provides:**
- Attention (where focus rests)
- Intention (what is being pursued)
- Mood (the coloring of experience)
- Thyra (the portal/interface)
- Prospect (anticipated possibilities)
- Kairos (opportune moments)

This is where aisthesis (sensing) becomes lived experience.

---

## Implementation Status

| Component | Status | Location |
|-----------|--------|----------|
| psyche.yaml schema | Complete | `klimax/6-psyche/psyche.yaml` |
| Eide (attention, intention, mood, thyra, prospect, kairos) | Complete | psyche.yaml |
| Artifact definitions | Complete | psyche.yaml |
| Desmoi (attends, intends, mood-of, portal-of, foresees, recognizes) | Complete | psyche.yaml |
| Praxeis (attention, intention, mood, thyra, prospect, kairos ops) | Complete | psyche.yaml |

**This layer is complete. The parousia can attend, intend, and experience.**

---

## Klimax Position

```
kosmos (1) -> physis (2) -> polis (3) -> oikos (4) -> soma (5) -> PSYCHE (6)
```

Psyche is the innermost scale — the narrowest scope but the richest experience. The parousia experiences from here, looking outward through all the other scales.

---

## Architecture

### 1. Attention

Attention is the beam of awareness:

| Field | Type | Description |
|-------|------|-------------|
| `target_id` | string | What attention is on |
| `weight` | number | 0.0 to 1.0, how much focus |
| `reason` | string | Why attending (optional) |
| `since` | timestamp | When attention started |

Multiple attention foci can exist simultaneously with different weights.

### 2. Intention

Intentions are the directedness of will:

| Status | Meaning |
|--------|---------|
| `forming` | Being shaped, not yet committed |
| `active` | Actively being pursued |
| `suspended` | Temporarily set aside |
| `fulfilled` | Successfully completed |
| `abandoned` | No longer pursued |

Intentions shape what the parousia attends to and how actions unfold.

### 3. Mood

Mood is not emotion but *attunement* — how the world shows up:

```
Mood discloses what matters.
In anxiety, threats appear.
In calm, possibilities open.
```

Mood has `quality` (focused, scattered, anxious, calm) and `intensity` (0.0-1.0).

### 4. Thyra (The Portal)

Thyra is the interface through which experience flows:

| Kind | Interface Type |
|------|----------------|
| `cli` | Command line |
| `web` | Browser-based |
| `api` | Programmatic |
| `ambient` | Background/passive |

Thyra manages visibility scope, rendering, and what interactions are possible.

### 5. Prospect and Kairos

- **Prospect**: Anticipated possibilities (what might happen)
- **Kairos**: Opportune moments (when conditions align for action)

These capture the temporal texture of experience — not clock time but lived time.

---

## Core Praxeis

| Praxis | Tier | Description |
|--------|------|-------------|
| `psyche/attend` | 2 | Direct attention to something |
| `psyche/release-attention` | 2 | Release attention |
| `psyche/list-attending` | 1 | List current attention foci |
| `psyche/form-intention` | 2 | Form a new intention |
| `psyche/activate-intention` | 2 | Move intention to active |
| `psyche/fulfill-intention` | 2 | Mark intention fulfilled |
| `psyche/disclose-mood` | 2 | Disclose current mood |
| `psyche/sense-mood` | 1 | Sense current mood |
| `psyche/open-thyra` | 2 | Open an interface portal |
| `psyche/close-thyra` | 2 | Close an interface portal |
| `psyche/foresee` | 2 | Note a prospect |
| `psyche/recognize-kairos` | 2 | Recognize an opportune moment |

---

## Constitutional Alignment

| Principle | How Psyche Honors It |
|-----------|---------------------|
| **Schema-driven** | Attention, intention, mood have constrained schemas. |
| **Graph-driven** | `attends`, `intends`, `mood-of`, `portal-of` bonds connect parousia to experience. |
| **Cache-driven** | Experience states can be cached and replayed for understanding. |

### The Experiencing Pattern

Psyche embodies:
```
Experience is not passive reception.
Attention is active selection.
Intention shapes what appears.
Mood discloses what matters.
```

---

## Summary

Psyche provides:
- **Attention**: Where focus rests (active selection)
- **Intention**: What is being pursued (directed will)
- **Mood**: How the world shows up (attunement)
- **Thyra**: The portal through which experience flows
- **Prospect/Kairos**: Temporal texture (possibilities and timing)

With psyche, the parousia fully experiences. Not just present in kosmos, but attending, intending, attuned, and engaged with time.

---

## Related Documents

- [soma/DESIGN.md](../5-soma/DESIGN.md) — Embodied presence above
- [oikos/DESIGN.md](../4-oikos/DESIGN.md) — Intimate dwelling context
- [nous/DESIGN.md](../nous/DESIGN.md) — Where understanding crystallizes
- [KOSMOGONIA.md](../../KOSMOGONIA.md) — The full constitutional vision

---

*Composed in service of the kosmogonia.*
*Traces to: phasis/genesis-root*
