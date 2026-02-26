# Accumulation Reference

Schema reference for `eidos/accumulation` — the singleton composition buffer behind the compose bar.

**Source:** `genesis/thyra/eide/thyra.yaml`, `genesis/thyra/entities/default-accumulation.yaml`

---

## Overview

The accumulation is a singleton entity that always exists. It represents "my current phasis draft" — the content pipeline behind the compose bar at the bottom of Thyra. Bootstrap creates `accumulation/default` on startup as a composed entity with literal-fill composition.

```yaml
- eidos: accumulation
  id: accumulation/default
  data:
    content: ""
    status: active
    started_at: "2026-02-06T00:00:00Z"
    _composition_inputs:
      typos_id: typos-def-accumulation
      inputs:
        content: ""
```

The accumulation is **modality-agnostic**: it receives text from keyboard, voice transcription, clarification, or any source. All sources follow the same pattern — update `_composition_inputs.inputs.content`, then composition produces the entity's `content` field. Voice entity bonds (`fed-by-audio`, `fed-by-transcriber`) exist for render-spec bindings, not for composition cascade.

---

## Fields

### content
**Type:** `string` **Required:** yes **Default:** `""`

The current draft text. Produced by composition from `_composition_inputs.inputs.content` (a literal fill slot). Updated by three praxeis: `thyra/flush-transcript` (voice), `thyra/sync-compose-content` (keyboard), and `thyra/clarify-accumulation` (LLM). Cleared after commit.

### status
**Type:** `enum` **Values:** `active`, `committed`, `abandoned`, `cleared` **Required:** yes **Default:** `active`

Lifecycle status. Always `active` for the singleton in normal use.

### stance
**Type:** `enum` **Values:** `declaration`, `inquiry`, `suggestion`, `invitation`, `request`, `proposal` **Required:** no

Phasis stance for commit. **Blank by default** — populated when clarification detects a stance. Displayed as a badge (read-only indicator). If blank at commit time, the phasis receives no explicit stance.

### started_at
**Type:** `timestamp` **Required:** yes

When this accumulation session began.

### last_modified_at
**Type:** `timestamp` **Required:** no

Last modification timestamp. Updated by clarification and content sync operations.

### committed_at
**Type:** `timestamp` **Required:** no

When content was last committed as a phasis.

### phasis_id
**Type:** `string` **Required:** no

ID of the most recently committed phasis.

---

## Bonds

| Desmos | Target | Purpose |
|--------|--------|---------|
| `fed-by-audio` | `audio-source/default` | Audio capture state — read via `{@fed-by-audio.data.desired_state}` in render-specs |
| `fed-by-transcriber` | `transcriber/default` | Transcription state — read via `{@fed-by-transcriber.data.desired_state}` in render-specs |
| `clarified-by` | generation entity | Audit trail — created each time clarification runs |

Note: The accumulation has **no** `depends-on` bond to the transcriber. The `fed-by-audio` and `fed-by-transcriber` bonds are for render-spec bindings only — they enable widgets to display voice state (muted/active/transcribing) without encoding domain logic in the interpreter.

---

## Composition

The accumulation is a composed entity via `typos-def-accumulation` with a **literal fill** slot:

```yaml
slots:
  content:
    fill: literal
    default: ""
template: "{{ content }}"
```

The literal fill means the slot value comes from `_composition_inputs.inputs.content` — not from a graph query or bond traversal. Praxeis update this literal input, then invoke `demiurge/compose` with only `entity_id` (the re-compose path reads stored `_composition_inputs`).

### Three Sources, One Pattern

All content updates follow the same path:

```
source (voice / keyboard / clarify)
         ↓
praxis updates _composition_inputs.inputs.content
         ↓
demiurge/compose (literal fill → template → content)
         ↓
accumulation.content updated
         ↓
UI re-renders from entity state
```

| Source | Praxis | Trigger | What It Does |
|--------|--------|---------|--------------|
| Voice transcription | `thyra/flush-transcript` | Reflex on transcriber.transcript change | Reads transcriber.transcript, appends to literal input, clears transcriber buffer |
| Manual editing | `thyra/sync-compose-content` | Transcription start, commit, blur | Reads `$form.content` from DOM, writes to literal input |
| Clarification | `thyra/clarify-accumulation` | User clicks clarify button | Runs LLM on current content, writes clarified text to literal input |

### Why Literal Fill (Not Queried)

The earlier design used a bond-based queried slot (`query: { bond: "fed-by-transcriber", field: "transcript" }`). This made composition one-way from transcriber to accumulation — correct for voice-only flow, but it prevented manual editing from flowing back. The literal-fill pattern allows any source to update the same content buffer while preserving composition's one-way, deterministic nature.

---

## Rendering

The compose bar renders the accumulation through two modes, each with its own render-spec:

| Mode | Render-Spec | Description |
|------|-------------|-------------|
| `mode/compose-full` | `render-spec/compose-full` | Full compose bar — control row (mic, transcription, stance badge, spacer, clarify, express) + editable textarea |
| `mode/compose-transcribing` | `render-spec/compose-transcribing` | Compose bar with transcribing — same control row, readonly textarea with "Transcribing..." placeholder |

Both are entity-bound modes bound to `accumulation/default` via `source_entity_id`. Mode switching is reflex-driven — when `transcriber/default.desired_state` transitions, a reflex swaps the active mode in the thyra-config.

### Key Bindings

| Widget | Binding | Phase |
|--------|---------|-------|
| Textarea | `value: "{content}"` | Render-time — shows entity content |
| Textarea | `name: content` | Form registration — `$form.content` reads DOM at click |
| Stance badge | `content: "{stance}"` | Render-time — shows detected stance |
| Express button | `content: $form.content` | Event-time — reads textarea at commit |
| Mic button | `entity_id: "{@fed-by-audio.id}"` | Render-time — bonded entity ID |

---

## Clarification Pipeline

When the user clicks the clarify button (sparkles icon):

```
_composition_inputs.inputs.content (current literal input)
    ↓
thyra/clarify-accumulation
    ↓
demiurge/compose(typos_id: "typos/clarify-phasis", inputs: { raw_content: ... })
    ↓
output_schema enforces { content: string, stance: enum } (T9)
    ↓
writes clarified content to _composition_inputs.inputs.content
    ↓
demiurge/compose (re-compose accumulation)
    ↓
accumulation.content + accumulation.stance updated
    ↓
clarified-by bond created (audit trail)
    ↓
UI re-renders from entity state
```

### What Clarification Does

- Removes verbal disfluencies (um, uh, like, you know)
- Fixes grammar and punctuation
- Preserves the speaker's distinct voice and intent
- Detects phasis stance from the content

Clarification uses `typos/clarify-phasis` with `output_schema` — not a generic prompt. This follows T9: schema enforcement exceeds prompt instruction.

---

## Sending

When the user clicks express (arrow-up icon):

1. `thyra/sync-compose-content` reads `$form.content` from the DOM and syncs to literal input
2. `thyra/commit-phasis` creates a phasis entity via `logos/emit-phasis`
3. Clears `_composition_inputs.inputs.content`, transcriber transcript, and accumulation content
4. Form cleared via `reset_form: true`
5. The phasis appears in the feed via the phasis-feed collection mode

### Button-Driven Intent

The textarea holds local DOM state. The accumulation entity is NOT updated per keystroke. Kosmos hears about content only at transition points — button press, mode switch, or blur. This is the form pattern — `$form.content` reads the textarea's current DOM value. See [Two-Phase Binding Resolution](../../explanation/architecture/two-phase-bindings.md).

---

## Praxeis

| Praxis | Purpose |
|--------|---------|
| `thyra/flush-transcript` | Read transcriber.transcript, append to literal input, clear transcriber buffer, compose |
| `thyra/sync-compose-content` | Read `$form.content` from DOM, write to literal input, compose |
| `thyra/clarify-accumulation` | Schema-enforced clarification — write clarified content to literal input, compose |
| `thyra/commit-phasis` | Create phasis from content + stance, clear accumulation + transcriber |

---

## Related

- [Two-Phase Bindings](../../explanation/architecture/two-phase-bindings.md) — `{field}` vs `$form.*` resolution timing
- [Clarification as Composition](../../explanation/composition/clarification-as-composition.md) — Why clarification uses `typos/clarify-phasis`
- [Mode Development](../../how-to/presentation/mode-development.md) — Creating modes with bond traversal
- [Phasis Entity](phasis-entity.md) — The durable unit that accumulation commits to
- [Voice Authoring](../../how-to/presentation/voice-authoring.md) — How-to guide for the voice experience

---

*Reference for the accumulation singleton in kosmos.*
