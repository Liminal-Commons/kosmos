# Oikos: The Intimate Dwelling

*Where presence unfolds and understanding emerges.*

---

## The Purpose

Oikos is scale 4 of 6 — the intimate context of dwelling. While polis establishes WHO can dwell WHERE, oikos is where dwelling actually happens.

**Oikos provides:**
- Sessions (containers of presence)
- Conversations (unfolding dialogue)
- Segments (units within conversations)
- Notes (attention markers)
- Insights (emerging understanding)

This is the immediate context of being-here — the "home" within the social structure polis creates.

---

## Implementation Status

| Component | Status | Location |
|-----------|--------|----------|
| oikos.yaml schema | Complete | `klimax/4-oikos/oikos.yaml` |
| Eide (session, conversation, segment, note, insight) | Complete | oikos.yaml |
| Artifact definitions | Complete | oikos.yaml |
| Desmoi (within, authored-by, surfaced-in, about) | Complete | oikos.yaml |
| Praxeis (session, conversation, note, insight ops) | Complete | oikos.yaml |
| Interpreter dwelling context | Complete | `crates/kosmos/src/interpreter/scope.rs` |

**This layer is complete. Dwelling context flows through all operations.**

---

## Klimax Position

```
kosmos (1) -> physis (2) -> polis (3) -> OIKOS (4) -> soma (5) -> psyche (6)
```

Oikos sits within polis (social structure) and contains soma (embodied presence) and psyche (inner experience). It's the middle ground where collective meets individual.

---

## Architecture

### 1. Session Management

Sessions are bounded periods of dwelling:

| Field | Type | Description |
|-------|------|-------------|
| `opened_at` | timestamp | When session began |
| `closed_at` | timestamp | When session ended (if closed) |
| `status` | enum | active, closed, suspended |

Sessions bond to circles via the dwelling context — an animus dwells in a circle during a session.

### 2. Conversation Flow

Conversations unfold within sessions:

```
session
  └── conversation
        ├── segment (message)
        ├── segment (action)
        ├── segment (observation)
        └── segment (reflection)
```

Segments have kinds: `message`, `action`, `observation`, `reflection`. This captures the texture of dialogue.

### 3. Note-Taking

Notes are proto-understanding — attention markers before we know why something matters:

| Kind | What It Marks |
|------|---------------|
| `observation` | Something noticed |
| `question` | Something unclear |
| `concern` | Something worrying |
| `insight` | Something understood |
| `todo` | Something to do |

Notes can be `about` any entity, creating a layer of reflection over the graph.

### 4. Insight Surfacing

Insights emerge from notes and can crystallize into theoria:

```
notes → surface-insight → insight → crystallize-insight → theoria
```

The journey from observation to understanding passes through oikos before reaching nous.

---

## Core Praxeis

| Praxis | Tier | Description |
|--------|------|-------------|
| `oikos/open-session` | 2 | Open a new session |
| `oikos/close-session` | 2 | Close the current session |
| `oikos/open-conversation` | 2 | Start a conversation |
| `oikos/add-segment` | 2 | Add to a conversation |
| `oikos/take-note` | 2 | Take a note about something |
| `oikos/list-notes` | 1 | List notes (optionally filtered) |
| `oikos/surface-insight` | 2 | Surface an insight from notes |
| `oikos/crystallize-insight` | 2 | Crystallize to theoria (calls nous) |

---

## Constitutional Alignment

| Principle | How Oikos Honors It |
|-----------|---------------------|
| **Schema-driven** | Session/conversation/note eide constrain what can exist in dwelling. |
| **Graph-driven** | `within`, `authored-by`, `about` bonds make context navigable. |
| **Cache-driven** | Segments and notes are immutable once created. |

### The Dwelling Pattern

Oikos embodies:
```
Dwelling is not just presence — it's engaged presence.
Understanding emerges from attention.
Notes are the seed; theoria is the fruit.
```

---

## Summary

Oikos provides:
- **Sessions**: Temporal containers for dwelling
- **Conversations**: Structured dialogue unfolding
- **Notes**: Attention markers that seed understanding
- **Insights**: Emerging understanding before crystallization

With oikos, dwelling has texture. The animus doesn't just exist in a circle — it engages, notes, reflects, and understands.

---

## Related Documents

- [polis/DESIGN.md](../3-polis/DESIGN.md) — Social structure above
- [soma/DESIGN.md](../5-soma/DESIGN.md) — Embodied presence below
- [psyche/DESIGN.md](../6-psyche/DESIGN.md) — Inner experience
- [nous/DESIGN.md](../nous/DESIGN.md) — Where insights crystallize

---

*Composed in service of the kosmogonia.*
*Traces to: expression/genesis-root*
