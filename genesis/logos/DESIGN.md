# Logos Design

λόγος (lógos) — word, reason, discourse

## Ontological Purpose

Logos addresses **the gap between state change and communication** — the distance between something happening and it being spoken into the shared discourse.

Without logos:
- Database changes are silent
- Only humans speak in conversation
- Topos activity is invisible to discourse
- Threading is limited to human replies

With logos:
- Every topos can emit phaseis
- Theoria crystallizations speak themselves
- Daemon completions announce results
- The kosmos becomes conversational

## Oikos Context

### Self Oikos

A solitary dweller uses logos to:
- Express thoughts and reflections
- Receive announcements from their topoi
- Thread conversations with self and system

### Peer Oikos

Collaborators use logos to:
- Converse with each other
- Receive shared topos announcements
- Thread discussions across human and system contributions

### Commons Oikos

A commons uses logos to:
- Broadcast announcements to subscribers
- Emit governance decisions as phaseis
- Create auditable discourse of community activity

## Core Entities (Eide)

### phasis

Intentional contribution — the commitment boundary.

**Fields:**
- `content` (string, required): The content being expressed
- `content_type` (string, default: text/plain): MIME type
- `authored_by` (string, required): Prosopon ID or topos ID of speaker
- `oikos_id` (string, required): Oikos where expressed
- `expressed_at` (timestamp, required): When expressed
- `source_kind` (enum: stream, compose, direct, topos): How it originated
- `stance` (enum: declaration, inquiry, suggestion, invitation, request, proposal): Phasis stance — how the speaker is positioned
- `in_reply_to` (string, optional): Reply target phasis ID
- `metadata` (object, optional): Additional context

## Bonds (Desmoi)

### in-reply-to

Phasis replies to another phasis.

- **From:** phasis
- **To:** phasis
- **Cardinality:** many-to-one

### phasis-in

Phasis belongs to an oikos.

- **From:** phasis
- **To:** oikos
- **Cardinality:** many-to-one

## Operations (Praxeis)

### emit-phasis

Create a phasis — the act of speaking.

- **When:** Any entity wants to communicate
- **Requires:** express attainment
- **Provides:** Phasis entity in the oikos's discourse

### reply-to

Reply to an existing phasis.

- **When:** Responding to discourse
- **Requires:** express attainment
- **Provides:** Phasis with in-reply-to bond

### list-phaseis

List phaseis in the current oikos.

- **When:** Viewing discourse
- **Requires:** None (read-only)
- **Provides:** Phaseis filtered by oikos

### get-thread

Get phasis thread from root.

- **When:** Viewing conversation thread
- **Requires:** None (read-only)
- **Provides:** Phasis tree

## Attainments

### attainment/express

Discourse capability — the ability to speak.

- **Grants:** emit-phasis, reply-to
- **Scope:** oikos
- **Rationale:** Speaking affects shared discourse; requires oikos membership

## Integration Pattern

Topoi integrate with the phasis surface by calling `logos/emit-phasis`:

```yaml
# In nous, when crystallizing theoria:
- step: call
  praxis: logos/emit-phasis
  params:
    stance: declaration
    content: "Crystallized: $theoria.insight"
    source_kind: topos
    metadata:
      source_eidos: theoria
      source_id: "$theoria.id"
```

This enables:
- **Unified feed** — Human messages, theoria crystallizations, and daemon announcements in one stream
- **Reply threading across topoi** — Reply to a build completion or a governance decision
- **Conversational kosmos** — The system speaks, not just stores

## Theoria

### T-logos-1: The kosmos speaks through phaseis

Every significant event can become an utterance. Database changes are silent; phaseis are speech. This transforms kosmos from a database into a conversational partner.

### T-logos-2: Stance conveys intentionality

Phaseis aren't just content — they carry stance (declaration, inquiry, request). This enables appropriate response patterns: inquiries invite answers, requests invite action.

---

*Composed in service of the kosmogonia.*
*The logos speaks. The kosmos converses. Discourse flows.*
