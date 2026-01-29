# Oikos Design

οἶκος (oîkos) — the household, the dwelling, the intimate place

## Ontological Purpose

Oikos addresses **the gap between presence and memory** — the distance between being in a moment and having that moment become part of understanding.

Without oikos:
- Conversations happen but leave no trace
- Notes scatter without connection to context
- Insights emerge but don't compound into knowledge
- Sessions have no continuity

With oikos:
- **Sessions**: Presence becomes structured duration
- **Conversations**: Dialogue unfolds as traceable segments
- **Notes**: Attention markers link to context
- **Insights**: Understanding surfaces before crystallizing as theoria

The household is where you dwell. Oikos makes dwelling traceable.

## Circle Context

### Self Circle

A solitary dweller uses oikos to:
- Open sessions marking work periods
- Conduct conversations with AI assistants
- Take notes as attention markers
- Surface insights from accumulated notes
- Crystallize insights into theoria

Personal knowledge management happens in the intimate dwelling.

### Peer Circle

Collaborators use oikos to:
- Share conversation contexts
- Build collective understanding through shared notes
- Surface insights from collaborative observation
- Track insights to their contributing notes

The household expands to include peers while maintaining intimacy.

### Commons Circle

A commons circle uses oikos to:
- Aggregate insights from member circles
- Surface community-level understanding
- Provide templates for common note-taking patterns

Commons circles rarely use oikos directly — it's the intimate scale.

## Core Entities (Eide)

### session

Current presence instance — a period of dwelling activity.

**Fields:**
- `animus_id` — The animus (embodied persona) in this session
- `started_at` — When the session began
- `status` — Active or closed

**Lifecycle:**
- Arise: open-session creates with dwelling context
- Change: Updated when closed
- Depart: Archived after closing

### conversation

A dialogue within a session.

**Fields:**
- `title` — Optional conversation title
- `opened_at` — When conversation began
- `closed_at` — When conversation ended (optional)
- `status` — Active or closed

**Lifecycle:**
- Arise: open-conversation within a session
- Change: Segments added via add-segment
- Depart: Closed and archived

### segment

A unit within a conversation — a turn of dialogue.

**Fields:**
- `kind` — message, action, observation, reflection
- `content` — The segment content
- `author_kind` — human, ai, system
- `created_at` — When created
- `metadata` — Additional context

**Lifecycle:**
- Arise: add-segment within a conversation
- Change: Immutable once created
- Depart: Archived with parent conversation

### note

An attention marker — something worthy of notice.

**Fields:**
- `content` — What is being noted
- `reason` — Why it matters
- `kind` — observation, question, concern, insight, todo
- `created_at` — When noted

**Lifecycle:**
- Arise: take-note marks attention
- Change: May be linked to insights
- Depart: Archived or surfaced into insight

### insight

Emerging understanding — not yet theoria, but surfaced from notes.

**Fields:**
- `content` — The insight itself
- `domain` — What domain it belongs to
- `confidence` — How certain (0.0-1.0)
- `surfaced_at` — When surfaced

**Lifecycle:**
- Arise: surface-insight from notes
- Change: Confidence may update
- Depart: Crystallizes into theoria via crystallize-insight

## Package Eide (Also Defined Here)

The following eide are defined in oikos but manipulated by demiurge praxeis:

- **oikos-manifest** — Package declaration (requires/provides)
- **oikos-dev** — Development package (mutable, may have generation specs)
- **oikos-prod** — Production package (frozen, signed)
- **publish-attestation** — Publication audit trail

These serve the oikos ecosystem but are not managed by oikos praxeis.

## Bonds (Desmoi)

### within

Containment within session/conversation.

- **From:** segment, conversation
- **To:** conversation, session
- **Cardinality:** many-to-one
- **Traversal:** Navigate conversation structure

### authored-by

Persona authored this segment/note.

- **From:** segment, note
- **To:** persona
- **Cardinality:** many-to-one
- **Traversal:** Find what a persona has authored

### surfaced-in

Insight surfaced in a circle.

- **From:** insight
- **To:** circle
- **Cardinality:** many-to-one
- **Traversal:** Find insights surfaced in this circle

### about

Note is about an entity.

- **From:** note
- **To:** any
- **Cardinality:** many-to-one
- **Traversal:** Find notes about something

### crystallizes

Insight crystallizes into theoria.

- **From:** insight
- **To:** theoria
- **Cardinality:** one-to-one
- **Traversal:** Link from insight to crystallized theoria

### surfaces

Note surfaces into insight.

- **From:** note
- **To:** insight
- **Cardinality:** many-to-one
- **Traversal:** Track which notes contributed to an insight

## Operations (Praxeis)

### open-session

Open a new session with dwelling context.

- **When:** Starting a work period
- **Requires:** dwell attainment
- **Provides:** session_id, status

### close-session

Close an active session.

- **When:** Ending a work period
- **Requires:** dwell attainment
- **Provides:** Confirmation of closure

### open-conversation

Open a conversation within a session.

- **When:** Starting dialogue
- **Requires:** dwell attainment
- **Provides:** conversation_id, session_id

### add-segment

Add a segment to a conversation.

- **When:** Recording dialogue turn
- **Requires:** dwell attainment
- **Provides:** segment_id, kind

### take-note

Take a note about something.

- **When:** Marking attention
- **Requires:** reflect attainment
- **Provides:** note_id, content, kind

### list-notes

List notes, optionally filtered.

- **When:** Reviewing attention markers
- **Requires:** reflect attainment
- **Provides:** Array of notes

### surface-insight

Surface an insight from notes.

- **When:** Understanding emerges
- **Requires:** reflect attainment
- **Provides:** insight_id, content, domain

### crystallize-insight

Crystallize an insight into theoria.

- **When:** Insight is ready to become theoria
- **Requires:** reflect attainment
- **Provides:** theoria_id from nous

## Attainments

### attainment/dwell

Dwelling capability — session and conversation management.

- **Grants:** open-session, close-session, open-conversation, add-segment
- **Scope:** circle
- **Rationale:** Session/conversation management is fundamental dwelling activity

### attainment/reflect

Reflection capability — notes and insight surfacing.

- **Grants:** take-note, list-notes, surface-insight, crystallize-insight
- **Scope:** circle
- **Rationale:** Reflection transforms experience into understanding

## Embodiment

### Completeness Status

| Level | Status |
|-------|--------|
| Defined | ✅ 5 intimate eide, 4 package eide, 12 desmoi, 9 praxeis |
| Loaded | ✅ Bootstrap loads all definitions |
| Projected | ✅ 9 praxeis visible as MCP tools |
| Embodied | ⏳ Body-schema contribution pending |
| Surfaced | ⏳ Reconciler not yet implemented |
| Afforded | ⏳ Thyra dwelling affordances pending |

### Body-Schema Contribution

When sense-body gathers oikos state:

```yaml
dwelling:
  current_session: "session/2026-01-28T10:30:00Z"
  active_conversations: 1
  session_segments: 47
  notes:
    total: 23
    unprocessed: 5    # Notes not yet surfaced to insight
  insights:
    total: 8
    uncristallized: 3  # Insights not yet theoria
```

This reveals dwelling activity and pending reflection work.

### Reconciler

An oikos reconciler would surface:

- **Orphan notes** — "5 notes haven't been processed into insights"
- **Pending insights** — "3 insights are ready to crystallize"
- **Long sessions** — "Current session has been active for 4 hours"
- **Conversation patterns** — "Recent conversations cluster around 'architecture'"

## Compound Leverage

### amplifies nous

Insights crystallize into theoria through nous/crystallize-theoria. Notes feed the mind.

### amplifies politeia

Sessions exist within circles. Dwelling requires governance context.

### amplifies soma

Sessions represent presence periods. Active session = embodied dwelling.

### amplifies thyra

Conversations could render as streams. Segments are expressible content.

## Theoria

### T41: Dwelling is structured presence

Sessions aren't just time — they're structured periods of attention. Opening a session declares intentional presence; closing it completes that attention arc.

### T42: Notes bridge perception and understanding

Notes are neither raw data nor finished understanding. They mark attention — "this matters" — creating the raw material from which insights surface.

### T43: Insights are understanding in motion

Insights aren't conclusions — they're understanding on the way to becoming theoria. The surface-then-crystallize flow honors the provisional nature of emerging knowledge.

## Future Extensions

### Conversation Templates

Pre-defined conversation structures for common patterns (retrospective, planning, debugging).

### Note Clustering

Automatic clustering of related notes to suggest insight opportunities.

### Session Summaries

Generate session summaries on close, capturing key segments and surfaced insights.

### Cross-Session Insight Threading

Track how insights develop across multiple sessions, revealing understanding arcs.

---

*Composed in service of the kosmogonia.*
*The household holds memory. Notes mark attention. Insights emerge.*
