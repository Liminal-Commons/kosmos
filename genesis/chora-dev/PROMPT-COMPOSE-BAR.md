# Compose Bar Handoff — Authoring the Input Affordance in Kosmos

*Handoff for a Claude Code session in the kosmos repository. The compose bar is kosmos content — modes, render-specs, bonds, desmoi, praxeis — authored through the world's own tools.*

**Status:** Ready for authoring
**Dependencies (all complete):**
- PROMPT-BOND-TRAVERSAL.md — `{@bond-name}` binding syntax (DONE — 129 frontend tests, 28 new)
- PROMPT-COMPOSITION-RECONCILIATION.md — Fourth loop, idempotent compose, dependency cascade (DONE — 518 Rust tests, 16 new)
**Target repo:** kosmos (genesis/)

---

## What This Is

The compose bar is how a parousia speaks. It is the spatial presence of the accumulation entity at the bottom of thyra — a mode that surfaces audio controls, transcription status, a text field, and action buttons.

This handoff gives a Claude Code session working in the kosmos repo everything it needs to author the compose bar using kosmos conventions. The test: can the compose bar be authored entirely through genesis content, with no custom code in the interpreter?

---

## Design Decisions (from dialogue — non-negotiable)

These were established through ontological dialogue and are not open for re-interpretation:

1. **The compose bar is a mode, not an entity.** It is the spatial presence of `accumulation/default`. Three modes handle variation: full, minimal, transcribing.

2. **Mode switching replaces conditionals.** Each mode has its own complete render-spec. No `when` logic within widget trees for presentation variation. If the presentation changes, switch the mode.

3. **Button-driven intent, not per-keystroke.** The textarea holds local DOM state (chora). The accumulation entity is NOT updated per keystroke. Kosmos hears about content only when a button is pressed (send, clarify). `on_input` is not used for entity updates.

4. **Bond traversal for multi-entity rendering.** The render-spec reads audio-source and transcriber state via `{@fed-by-audio}` and `{@fed-by-transcriber}` bonds. This is the one right way — no context injection, no prop drilling.

5. **Accumulation is stable.** Composed once, updated in place. New entities arise only at commit (phasis is composed from accumulation content). Clarification updates the accumulation, it does not create a new entity. With composition reconciliation now live, any entity that depends-on accumulation will automatically recompose when accumulation changes.

6. **No custom interpreter logic.** Everything is expressed through render-specs, modes, and praxeis. The interpreter is generic — it renders widgets from specs. All domain logic is kosmos content.

---

## What Already Exists

| Entity | Where | What It Does |
|--------|-------|-------------|
| `mode/text-composing` | `thyra/modes/screen.yaml` | Current simple compose bar — textarea + 2 buttons, position: bottom |
| `render-spec/text-compose` | `thyra/render-specs/text-compose.yaml` | Current render-spec — form widget, `$form.content`, compose + express buttons |
| `accumulation/default` | `thyra/entities/default-accumulation.yaml` | Singleton accumulation — content, status, stance, started_at |
| `eidos/accumulation` | `thyra/eide/thyra.yaml` | 7 fields: content, status, stance, started_at, last_modified_at, committed_at, phasis_id |
| `eidos/audio-source` | `soma/eide/voice.yaml` | Voice capture entity — intent, actual_state, device_id, sample_rate, channels |
| `eidos/transcriber` | `soma/eide/voice.yaml` | Transcription entity — intent, actual_state, provider, model, language |
| `reconciler/audio-capture` | `soma/reconcilers/voice.yaml` | Drives audio capture actualization (capturing ↔ stopped) |
| `reconciler/transcription` | `soma/reconcilers/voice.yaml` | Drives transcription actualization (transcribing ↔ stopped) |
| `thyra/commit-phasis` | `thyra/praxeis/thyra.yaml` | Reads content + stance, composes phasis, clears accumulation |
| `thyra/compose-artifact` | `thyra/praxeis/thyra.yaml` | LLM generation from prompt text |
| `thyra/switch-mode` | `thyra/praxeis/thyra.yaml` | Swaps active modes in thyra-config |
| `desmos/clarified-by` | `thyra/desmoi/thyra.yaml` | Audit trail: accumulation → generation |
| 35 widgets | `app/src/lib/widgets/` | button, textarea, icon, row, card, badge, select, form, text, etc. |

### What's Missing

1. **Bonds connecting accumulation to voice entities** — no desmoi, no bond instances
2. **Compose bar modes for variation** — only text-composing exists
3. **Render-specs with audio/transcription controls** — only text-compose exists
4. **Default voice entity instances** — audio-source/default and transcriber/default don't exist
5. **Toggle praxeis** — no way to flip audio-source or transcriber intent via button
6. **Clarification praxis** — no way to invoke manteia on accumulation content
7. **Utterance-append praxis** — no way to append transcribed text to accumulation
8. **Stance selection UI** — accumulation has stance field but no selector in render-spec

---

## What to Author

### 1. New Desmoi

Add to `genesis/thyra/desmoi/thyra.yaml`:

```yaml
# fed-by-audio — accumulation receives audio from this source
- eidos: desmos
  id: desmos/fed-by-audio
  data:
    name: fed-by-audio
    description: "Accumulation receives audio input from this audio-source entity."
    from_eidos: accumulation
    to_eidos: audio-source
    cardinality: one-to-one
    symmetric: false

# fed-by-transcriber — accumulation receives transcription from this transcriber
- eidos: desmos
  id: desmos/fed-by-transcriber
  data:
    name: fed-by-transcriber
    description: "Accumulation receives transcription from this transcriber entity."
    from_eidos: accumulation
    to_eidos: transcriber
    cardinality: one-to-one
    symmetric: false
```

### 2. Default Voice Entity Instances

Create `genesis/soma/entities/voice-defaults.yaml`:

```yaml
entities:
  - eidos: audio-source
    id: audio-source/default
    data:
      intent: stopped
      actual_state: stopped
      device_id: default
      sample_rate: 16000
      channels: 1

  - eidos: transcriber
    id: transcriber/default
    data:
      intent: stopped
      actual_state: stopped
      provider: whisper-local
      model: base
      language: en
```

### 3. Bonds on Default Accumulation

Update `genesis/thyra/entities/default-accumulation.yaml`:

```yaml
entities:
  - eidos: accumulation
    id: accumulation/default
    data:
      content: ""
      status: active
      stance: declaration
      started_at: "2026-02-06T00:00:00Z"

bonds:
  - from_id: accumulation/default
    to_id: audio-source/default
    desmos: fed-by-audio
  - from_id: accumulation/default
    to_id: transcriber/default
    desmos: fed-by-transcriber
```

### 4. Three Modes (replace mode/text-composing)

In `genesis/thyra/modes/screen.yaml`, replace `mode/text-composing` with:

```yaml
# Full compose bar — all controls visible
- eidos: mode
  id: mode/compose-full
  data:
    name: compose-full
    topos: thyra
    description: |
      Full compose bar with audio controls, transcription status,
      text area, stance selector, and action buttons.
    render_spec_id: render-spec/compose-full
    spatial:
      position: bottom
      height: auto
    source_entity_id: accumulation/default
    created_at: "2026-02-12T00:00:00Z"

# Minimal compose bar — thin strip
- eidos: mode
  id: mode/compose-minimal
  data:
    name: compose-minimal
    topos: thyra
    description: |
      Minimized compose bar. Thin strip showing mic indicator,
      character count, and expand button.
    render_spec_id: render-spec/compose-minimal
    spatial:
      position: bottom
      height: auto
    source_entity_id: accumulation/default
    created_at: "2026-02-12T00:00:00Z"

# Transcribing compose bar — live indicator visible
- eidos: mode
  id: mode/compose-transcribing
  data:
    name: compose-transcribing
    topos: thyra
    description: |
      Compose bar with active transcription indicator.
      Shows status badge when transcriber is active.
    render_spec_id: render-spec/compose-transcribing
    spatial:
      position: bottom
      height: auto
    source_entity_id: accumulation/default
    created_at: "2026-02-12T00:00:00Z"
```

Update bonds section — remove `mode/text-composing → render-spec/text-compose`, add:

```yaml
- from_id: mode/compose-full
  to_id: render-spec/compose-full
  desmos: uses-render-spec
- from_id: mode/compose-minimal
  to_id: render-spec/compose-minimal
  desmos: uses-render-spec
- from_id: mode/compose-transcribing
  to_id: render-spec/compose-transcribing
  desmos: uses-render-spec
```

### 5. Three Render-Specs

Create `genesis/thyra/render-specs/compose-full.yaml`:

The full compose bar. Two rows:
- **Control row**: mic toggle (`@fed-by-audio`), transcription toggle (`@fed-by-transcriber`), stance selector, minimize button
- **Input row**: textarea (name: content, value: `{content}`), clarify button, express button

Key patterns:
- Form widget wraps everything — `$form.content` and `$form.stance` read at button press time
- Mic button: `on_click: soma/toggle-audio-intent` with `entity_id: "{@fed-by-audio.id}"`
- Transcription button: `on_click: soma/toggle-transcriber-intent` with `entity_id: "{@fed-by-transcriber.id}"`
- Clarify button: `on_click: thyra/clarify-accumulation` with `content: $form.content`
- Express button: `on_click: thyra/commit-phasis` with `content: $form.content, stance: $form.stance, reset_form: true`
- Minimize button: `on_click: ui/switch-mode` with `from_mode_id: mode/compose-full, to_mode_id: mode/compose-minimal`

Create `genesis/thyra/render-specs/compose-minimal.yaml`:

Thin strip. Single row: mic icon, text preview (`{content}`), expand button (`ui/switch-mode` → compose-full).

Create `genesis/thyra/render-specs/compose-transcribing.yaml`:

Same as compose-full but with a "Transcribing..." badge in the control row.

### 6. New Praxeis

**In `genesis/soma/praxeis/voice.yaml` (NEW file):**

`soma/toggle-audio-intent`: find entity → compute toggled intent → update
`soma/toggle-transcriber-intent`: find entity → compute toggled intent → update

**In `genesis/thyra/praxeis/thyra.yaml` (add entries):**

`thyra/clarify-accumulation`: compose via `typos/compose-from-prompt` with clarification prompt → update accumulation.content
`thyra/append-utterance`: find accumulation → concatenate transcription to content → update

### 7. Authorization and Manifests

- Add `grants-praxis` bonds to `attainment/perceive` for new thyra praxeis
- Add praxis names to `thyra/manifest.yaml` and `soma/manifest.yaml`
- Update default thyra-config to reference `mode/compose-full` instead of `mode/text-composing`

### 8. Cleanup

- Delete `genesis/thyra/render-specs/text-compose.yaml`
- Remove `mode/text-composing` entity and its bond

---

## Widget Vocabulary Available

These widgets are registered and available for render-specs (no new widgets needed):

| Widget | Key Props |
|--------|----------|
| `form` | class — wraps children, enables `$form.*` bindings |
| `row` | align, gap, padding, class |
| `button` | variant (primary/ghost/danger), on_click, on_click_params, reset_form |
| `textarea` | name, value, placeholder, rows, class |
| `select` | name, value, options (array of {value, label}), class |
| `icon` | name (lucide icon name), size (sm/md/lg) |
| `text` | content, variant (body/secondary/caption/heading) |
| `badge` | label, variant (success/warning/danger/info) |

### Binding Syntax

| Syntax | What It Resolves |
|--------|-----------------|
| `{field}` | `entity.data.field` |
| `{id}` | Entity ID |
| `{@bond-name.data.field}` | Follow bond, read target entity field |
| `{@bond-name.id}` | Follow bond, read target entity ID |
| `$form.fieldName` | Current form field value (read at click time) |
| `reset_form: true` | Clear form after successful praxis invocation |

### Event Handler Pattern

```yaml
on_click: praxis/name       # Praxis to invoke
on_click_params:             # Params resolved at click time
  entity_id: "{id}"          # Entity binding
  content: $form.content     # Form binding (deferred to click time)
```

For local UI actions (no server roundtrip):
```yaml
on_click: ui/switch-mode
on_click_params:
  from_mode_id: mode/compose-full
  to_mode_id: mode/compose-minimal
```

---

## How to Verify

1. **Bootstrap test**: After authoring, run bootstrap. All new entities should load without errors.
2. **Bond test**: `accumulation/default` should have `fed-by-audio` bond to `audio-source/default` and `fed-by-transcriber` bond to `transcriber/default`.
3. **Mode test**: `mode/compose-full`, `mode/compose-minimal`, `mode/compose-transcribing` should all exist with correct `render_spec_id` and `source_entity_id`.
4. **Render-spec test**: Each render-spec should have a `layout` array with the correct widget tree.
5. **Praxis test**: Toggle praxeis should flip intent. Append-utterance should concatenate text. Clarify should update content via generation.
6. **Visual test**: `just dev` → compose bar renders at bottom with controls. Buttons invoke correct praxeis. Mode switching works.

---

## Files to Read Before Authoring

| File | Why |
|------|-----|
| `genesis/thyra/modes/screen.yaml` | See mode/text-composing pattern to follow |
| `genesis/thyra/render-specs/text-compose.yaml` | See current render-spec to evolve from |
| `genesis/thyra/eide/thyra.yaml` | Accumulation fields, attainment bonds |
| `genesis/thyra/praxeis/thyra.yaml` | Existing praxeis for pattern reference |
| `genesis/thyra/desmoi/thyra.yaml` | Existing desmoi for pattern reference |
| `genesis/soma/eide/voice.yaml` | Audio-source and transcriber fields |
| `genesis/soma/manifest.yaml` | Content paths for new files |
| `docs/reference/presentation/render-spec-authoring.md` | Render-spec authoring guide |
| `docs/reference/presentation/mode-reference.md` | Mode schema reference |

---

## Files to Create or Modify

| File | Action |
|------|--------|
| `genesis/thyra/desmoi/thyra.yaml` | **MODIFY** — add 2 new desmoi |
| `genesis/soma/entities/voice-defaults.yaml` | **NEW** — default audio-source + transcriber |
| `genesis/thyra/entities/default-accumulation.yaml` | **MODIFY** — add bonds |
| `genesis/thyra/render-specs/compose-full.yaml` | **NEW** |
| `genesis/thyra/render-specs/compose-minimal.yaml` | **NEW** |
| `genesis/thyra/render-specs/compose-transcribing.yaml` | **NEW** |
| `genesis/thyra/render-specs/text-compose.yaml` | **DELETE** |
| `genesis/thyra/modes/screen.yaml` | **MODIFY** — replace text-composing with 3 modes |
| `genesis/soma/praxeis/voice.yaml` | **NEW** — toggle praxeis |
| `genesis/thyra/praxeis/thyra.yaml` | **MODIFY** — add clarify + append praxeis |
| `genesis/thyra/eide/thyra.yaml` | **MODIFY** — add attainment bonds |
| `genesis/thyra/manifest.yaml` | **MODIFY** — add praxis names |
| `genesis/soma/manifest.yaml` | **MODIFY** — add praxis names, entities path |

---

*This handoff traces to: T3 (three pillars as one practice — composition reconciliation now live), T7 (rendering is graph-traversable), T8 (mode is topos presence), the Compose Bar Design Dialogue (one right way, button-driven intent, mode switching, bond traversal, no on_input per keystroke).*
