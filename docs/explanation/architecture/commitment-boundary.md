# Explanation: The Commitment Boundary

Why ephemeral content and durable phasiss are separated by an intentional boundary.

---

## The Problem

Consider voice input. As you speak:
- Audio flows continuously
- Transcription produces fragments
- Words appear, get corrected, accumulate

At what point does this become a *contribution*? When does ephemeral stream become durable phasis?

**Without a clear boundary:**
- Every keystroke could create an entity
- Partial thoughts become permanent
- No opportunity to revise before committing
- The "send moment" is implicit and accidental

**With a commitment boundary:**
- Content accumulates in a buffer
- User reviews and edits before committing
- The "send" is intentional and observable
- Phaseis have clear provenance

---

## The Pattern

```
ephemeral stream → accumulation buffer → COMMIT → durable phasis
                         ↑                  ↑
                    reversible         commitment boundary
                                       (the send moment)
```

**Before the boundary:** Content is ephemeral. It can be edited, cleared, abandoned. No trace in the graph.

**At the boundary:** The commit operation. Intentional, observable, irreversible.

**After the boundary:** Content is durable phasis. It has provenance, can be replied to, becomes part of discourse.

---

## Implementation in Thyra

Thyra manages the commitment boundary through three eide:

| Eidos | Role |
|-------|------|
| **stream** | Captures media flow (voice, video, text) |
| **accumulation** | Buffers content before commitment |
| **phasis** | Durable contribution (lives in logos) |

The flow:

```yaml
# 1. Open stream
thyra/open-stream:
  creates: stream entity (kind: voice)

# 2. Begin accumulation
thyra/begin-accumulation:
  creates: accumulation entity (status: active)

# 3. Append fragments (as transcription arrives)
thyra/append-fragment:
  updates: accumulation.content

# 4. COMMIT (the boundary crossing)
thyra/commit-accumulation:
  - reads: accumulation.content
  - calls: logos/emit-phasis
  - creates: phasis entity
  - updates: accumulation.status → committed
```

---

## Why This Matters

### Intentionality

The boundary makes the "send moment" explicit. Users know when they're committing. There's no ambiguity about what's been expressed vs. what's still draft.

### Provenance

Phaseis created via commit carry metadata:
- `source_kind: voice` — how it was captured
- `accumulation_id` — link to original buffer
- `raw_content` — verbatim transcript (if clarified)

This enables audit trails and understanding how content was produced.

### Editability

Before commitment, the user can:
- Edit the clarified text
- Clear and start over
- Abandon entirely
- Change the phasis mode

After commitment, the phasis is immutable. Responses create new phaseis (threading), not edits.

### Separation of Concerns

| Layer | Responsibility |
|-------|----------------|
| **Substrate** (dynamis) | Audio capture, VAD, transcription |
| **Buffer** (thyra) | Accumulation, clarification, editing |
| **Discourse** (logos) | Phaseis, threading, replies |

Each layer has clear boundaries. The commitment boundary is the handoff from thyra to logos.

---

## The Accumulation Entity

The accumulation entity models the buffer state:

```yaml
eidos: accumulation
fields:
  stream_id: string        # Source stream
  raw_content: string      # Verbatim from STT
  content: string          # Clarified, ready for commit
  mode: enum               # declaration, inquiry, suggestion, request, proposal
  clarification_status: enum  # pending, clarifying, clarified, manual, failed
  capture_state: enum      # inactive, listening, processing
  status: enum             # active, committed, abandoned, cleared
```

**Key insight:** The accumulation entity is the source of truth. UI binds to it. Changes flow through praxeis. This is the [entity-as-source-of-truth](./entity-as-source-of-truth.md) pattern.

---

## UI Binding

The accumulation-composer render-spec binds directly to accumulation entity:

```yaml
# Content textarea bound to entity
- widget: textarea
  props:
    value: "{content}"           # Reads from entity
    on_input: thyra/update-accumulation-content
    on_input_params:
      accumulation_id: "{id}"
      content: $event.target.value

# Send button commits
- widget: button
  props:
    label: "Send"
    on_click: thyra/commit-accumulation
    on_click_params:
      accumulation_id: "{id}"
```

The UI never holds local state. All state lives in the accumulation entity. Changes flow: UI → praxis → entity → UI (via subscription).

---

## Theoria

### T50: The commitment boundary is the send moment

Before commitment, content is ephemeral buffer. After commitment, content is durable phasis with provenance. The moment between is the commitment boundary — intentional, observable, reversible until crossed.

---

## Related Concepts

- **[Reconciler Pattern](./reconciler-pattern.md)** — How streams align intent with actuality
- **[Entity-as-Source-of-Truth](./entity-as-source-of-truth.md)** — Why accumulation entity owns state
- **Logos** — The discourse surface where phaseis live
- **Thyra** — The boundary membrane that manages the commitment

---

## References

- [genesis/thyra/DESIGN.md](../../genesis/thyra/DESIGN.md) — Thyra design with T50 theoria
- [genesis/thyra/eide/thyra.yaml](../../genesis/thyra/eide/thyra.yaml) — Stream and accumulation eide
- [genesis/thyra/praxeis/thyra.yaml](../../genesis/thyra/praxeis/thyra.yaml) — Accumulation operations
- [VOICE-TOPOS-DESIGN.md](../../design/VOICE-TOPOS-DESIGN.md) — Voice implementation design

---

*The commitment boundary separates thinking from saying. It is the moment of intention.*
