# Doc Alignment & Orphan Cleanup — Align Prescriptive Docs with Post-Restructure Thyra

*Prompt for Claude Code in the chora + kosmos repository context.*

*After this work, all prescriptive docs reflect the actual thyra mode inventory: 5 modes (compose-full, compose-transcribing, oikos-nav, theoria-sidebar, phasis-feed). References to deleted modes (compose-minimal, authoring-feed, text-composing, voice-composing) are removed. Orphaned genesis entities that served deleted modes are deleted. The compose bar layout description (control row + textarea) replaces stale descriptions (control row + input row, stance selector, minimize button). Doc examples use real mode names from screen.yaml.*

---

## Architectural Principle — Prescriptive Docs, Dead Code Policy

Docs describe the state we **want**, not the state we have. When code changes and docs lag, the docs have a gap — they prescribe a state that no longer matches what we want.

The dead code policy extends to docs: stale references to deleted entities are **contextual poison**. A doc example showing `mode/authoring-feed` or `mode/compose-minimal` teaches patterns that will confuse — those modes don't exist. A doc describing "three compose modes" when there are two is a lie. Remove, don't characterize as harmless.

> T7: Rendering is graph-traversable. Display configuration is data, not code.
> T8: Mode is topos presence. Each mode has a single definitive render-spec.

---

## Methodology — DDD + TDD

This work follows **Doc → Test → Build → Verify**, non-negotiably.

1. **Doc (prescriptive)**: This prompt IS the prescriptive doc. The target state described here is what docs must match.
2. **Test (assert the doc)**: Grep-based assertions that stale terms are gone.
3. **Build (satisfy the tests)**: Edit each doc to match target state.
4. **Verify doc**: After implementation, check docs/REGISTRY.md impact map.

**Pure doc/genesis cleanup — no code changes.** All changes are in `docs/` and `genesis/` YAML files.

---

## Current State

### What Exists and Works

| Component | Location | Status |
|-----------|----------|--------|
| 5 thyra modes | `genesis/thyra/modes/screen.yaml` | Working — compose-full, compose-transcribing, oikos-nav, theoria-sidebar, phasis-feed |
| 2 compose render-specs | `genesis/thyra/render-specs/compose-{full,transcribing}.yaml` | Working — control row (mic, transcription, stance badge, spacer, clarify, express) + textarea |
| thyra-config/workspace | `genesis/thyra/entities/layout.yaml` | Working — oikos-nav, phasis-feed, theoria-sidebar, compose-full |
| Compose bar layout | render-specs | Working — control row top, textarea alone bottom |
| Stance display | render-spec | Working — `widget: badge` (display-only), not `widget: select` |

### What's Missing — The Gaps

1. **9 docs reference deleted modes.** `compose-minimal`, `authoring-feed`, `text-composing`, `voice-composing` appear in 9 prescriptive docs. These modes no longer exist in screen.yaml.

2. **Mode counts are wrong.** Docs say "three compose modes" (should be two), "7 thyra modes" (should be 5), "19 modes across 5 topoi" (should be 17), "6 modes across 5 positions" (should be 5 modes across 4 positions).

3. **Compose bar descriptions are stale.** Docs describe "control row + input row" layout, "stance selector/dropdown", "minimize button". The actual layout is control row (mic, transcription, stance badge, spacer, clarify, express) + textarea alone.

4. **Orphaned typos.** `typos/authoring-session-view` was the composition definition for authoring-feed's artifact widget. With authoring-feed deleted, this typos serves nothing.

5. **Doc examples use fantasy mode names.** `mode/voice-composing`, `mode/text-composing`, `mode/voice-minimal` appear in doc examples but were never real modes in the current genesis.

---

## Target State

After this work:

- **Zero** occurrences of `compose-minimal`, `authoring-feed`, `text-composing`, `voice-composing` in `docs/` directory
- **Zero** occurrences of `stance selector`, `stance dropdown`, `stance select` in docs describing the compose bar
- **All** thyra mode counts match: 5 thyra modes, 2 compose modes
- **All** compose bar descriptions say: control row (mic, transcription, stance badge, spacer, clarify, express) + textarea
- **All** doc examples use real mode names from `genesis/thyra/modes/screen.yaml`
- `genesis/thyra/typos/authoring-session-view.yaml` deleted
- Actualization pattern mode catalog matches actual genesis

### Target: Thyra Mode Table (for docs)

| Mode | Topos | Pattern | Position | Description |
|------|-------|---------|----------|-------------|
| `mode/compose-full` | thyra | singleton | bottom | Full compose bar — control row + editable textarea |
| `mode/compose-transcribing` | thyra | singleton | bottom | Compose bar with transcribing — control row + readonly textarea |
| `mode/oikos-nav` | politeia | collection | left | Oikos navigation sidebar |
| `mode/theoria-sidebar` | nous | collection | right | Theoria browsing sidebar |
| `mode/phasis-feed` | logos | collection | center | Live phasis feed, scroll-bottom |

### Target: Compose Bar Description (for docs)

```
Control row: mic toggle, transcription toggle, stance badge, spacer, clarify button, express button
Input area: textarea (editable in compose-full, readonly in compose-transcribing)
```

Stance is a `widget: badge` (display-only indicator populated by clarification). Not a `widget: select`. No minimize button. No input row — textarea is direct child of form.

---

## Sequenced Work

### Phase 1: Delete Orphans

**Goal:** Remove genesis entities that served deleted modes.

**Tests:**
- `ls genesis/thyra/typos/authoring-session-view.yaml` → file does not exist

**Implementation:**
1. Delete `genesis/thyra/typos/authoring-session-view.yaml`

**Phase 1 Complete When:**
- [x] `authoring-session-view.yaml` deleted
- [x] `just prod` still builds (genesis validation passes)

### Phase 2: Fix Reference Docs

**Goal:** Align all reference docs with the 5-mode thyra inventory.

**Tests:**
- `grep -r "compose-minimal" docs/` → zero matches
- `grep -r "authoring-feed" docs/` → zero matches
- `grep -r "text-composing" docs/` → zero matches
- `grep -r "voice-composing" docs/` → zero matches
- `grep -r "three modes" docs/` → zero matches (in thyra/compose context)
- `grep -r "stance.*select\|stance.*dropdown" docs/` → zero matches (in compose bar context)

**Implementation:**

#### 2a. `docs/how-to/presentation/voice-authoring.md`

**Line 9:** Change "three modes" → "two modes"

**Lines 12-16:** Remove the compose-minimal row from the mode table. Table becomes:

```markdown
| Mode | Render-Spec | When |
|------|-------------|------|
| `mode/compose-full` | `render-spec/compose-full` | Default — control row + editable textarea |
| `mode/compose-transcribing` | `render-spec/compose-transcribing` | Transcriber active — control row + readonly textarea, "Transcribing..." placeholder |
```

**Line 17:** Change "All three are" → "Both are"

#### 2b. `docs/reference/domain/phasis-workspace.md`

**Line 45:** Change "stance dropdown" → "stance badge" — stance is populated by clarification, displayed as a badge, not selected from a dropdown.

**Lines 125-133:** Change "three modes" → "two modes". Remove compose-minimal row. Update compose-full description from "control row (mic, transcription, stance, minimize) + input row (textarea, clarify, express)" to "control row (mic, transcription, stance badge, spacer, clarify, express) + textarea".

**Lines 141-142:** Remove "Stance select" row from Key Bindings table — stance is now a badge, not a form input. Replace with:

```markdown
| Stance badge | `content: "{stance}"` | Render-time — shows detected stance |
```

#### 2c. `docs/reference/reactivity/actualization-pattern.md`

**Line 200:** Change "All 19 modes" → "All 17 modes" (lost authoring-feed + compose-minimal; text-composing and voice-composing were fantasy names that were never real modes, but the doc listed them).

**Lines 206-213:** Replace thyra mode table:

```markdown
| Mode | Topos | Pattern | Position | Status | Stage |
|------|-------|---------|----------|--------|-------|
| `mode/compose-full` | thyra | singleton | bottom | Render-spec driven | 5 (Reactive) |
| `mode/compose-transcribing` | thyra | singleton | bottom | Render-spec driven | 5 (Reactive) |
| `mode/oikos-nav` | politeia | collection | left | Render-spec driven | 5 (Reactive) |
| `mode/theoria-sidebar` | nous | collection | right | Render-spec driven | 5 (Reactive) |
| `mode/phasis-feed` | logos | collection | center | Render-spec driven, scroll-bottom | 5 (Reactive) |
```

**Line 314:** Change "7 modes" → "5 modes" in completion matrix — "All thyra modes are fully reactive"

#### 2d. `docs/reference/presentation/mode-reference.md`

**Lines 122-133:** Replace singleton example `mode/voice-composing` with `mode/compose-full`:

```yaml
- eidos: mode
  id: mode/compose-full
  data:
    name: compose-full
    topos: thyra
    render_spec_id: render-spec/compose-full
    spatial: { position: bottom, height: auto }
    source_entity_id: accumulation/default
```

**Lines 137-148:** Replace collection example `mode/authoring-feed` with `mode/phasis-feed`:

```yaml
- eidos: mode
  id: mode/phasis-feed
  data:
    name: phasis-feed
    topos: logos
    item_spec_id: render-spec/phasis-bubble
    source_query: "gather(eidos: phasis, sort: expressed_at, order: desc)"
    arrangement: scroll-bottom
    chrome_spec_id: null
    spatial: { position: center, height: fill }
    config:
      watch_eidos: phasis
```

#### 2e. `docs/reference/infrastructure/substrate-lifecycle.md`

**Lines 64-72:** Replace `mode/voice-composing` example with `mode/compose-transcribing` (which requires voice substrate via transcriber bond):

```yaml
# Mode that uses voice state via bond traversal
mode/compose-transcribing:
  render_spec_id: render-spec/compose-transcribing
  spatial: { position: bottom, height: auto }
  source_entity_id: accumulation/default
```

Update explanation text to match: compose-transcribing reads voice state via bond traversal (`@fed-by-audio`, `@fed-by-transcriber`), and mode switching is reflex-driven when transcriber state changes.

**Phase 2 Complete When:**
- [ ] Zero grep matches for deleted mode names in `docs/`
- [ ] All mode counts correct (5 thyra, 17 total)
- [ ] Compose bar descriptions match actual layout
- [ ] Doc examples use real mode names

### Phase 3: Fix Design Docs & Explanations

**Goal:** Align design docs and explanations with the 5-mode inventory.

**Tests:**
- `grep -r "compose-minimal\|authoring-feed\|text-composing\|voice-composing" genesis/thyra/DESIGN.md` → zero matches
- `grep -r "compose-minimal\|authoring-feed\|text-composing\|voice-composing" docs/design/` → zero matches
- `grep -r "compose-minimal\|authoring-feed\|text-composing\|voice-composing" docs/explanation/` → zero matches
- `grep -r "compose-minimal\|authoring-feed\|text-composing\|voice-composing" docs/tutorial/` → zero matches

**Implementation:**

#### 3a. `genesis/thyra/DESIGN.md`

**Line 357:** Change "6 modes across 5 spatial positions" → "5 modes across 4 spatial positions" (bottom, left, center, right — no top position used).

**Lines 373-374:** Replace body-schema example:

```yaml
emission:
  active_config: thyra-config/workspace
  active_modes: [mode/oikos-nav, mode/phasis-feed, mode/theoria-sidebar, mode/compose-full]
  current_theme: dark
```

Remove `workspace_tabs` and `focused_artifact` — no authoring-feed means no workspace tabs.

#### 3b. `docs/design/VOICE-OIKOS-DESIGN.md`

**Line 40:** Change "three screen modes" → "two screen modes"

**Lines 42-46:** Remove compose-minimal row. Update compose-full description:

```markdown
| Mode | Render-Spec | Description |
|------|-------------|-------------|
| `mode/compose-full` | `render-spec/compose-full` | Full compose bar — control row (mic, transcription, stance badge, spacer, clarify, express) + editable textarea |
| `mode/compose-transcribing` | `render-spec/compose-transcribing` | Compose bar with transcribing — same control row, readonly textarea |
```

**Line 210:** Remove "compose-full/transcribing/minimal" → "compose-full/transcribing" in render-spec list.

#### 3c. `docs/explanation/presentation/modes-and-oikos.md`

**Line 23:** Replace "Authoring-feed renders phasis cards, needs no special substrate, and fills the center." → "Phasis-feed renders phasis bubbles, needs no special substrate, and fills the center."

**Lines 31-33:** Replace voice-composing/text-composing example. The ontological point (modes are the unit of substrate requirement) is still valid — illustrate with compose-full vs compose-transcribing:

"Compose-full and compose-transcribing are different modes because they have different render-specs — one has an editable textarea, the other has a readonly textarea with transcribing placeholder. The transcriber toggle switches modes via reflex."

**Line 41:** Replace `mode/voice-composing` and `mode/voice-minimal` references. Use real modes: `mode/compose-full` declares `position: bottom, height: auto` and `mode/phasis-feed` declares `position: center, height: fill`.

**Line 53:** Replace "HUD: only voice-minimal active" with the actual state: "HUD: reserved — no active modes (empty set)."

#### 3d. `docs/how-to/presentation/mode-development.md`

**Lines 147-152:** Replace thyra-config example:

```yaml
active_modes:
  - mode/oikos-nav
  - mode/phasis-feed
  - mode/theoria-sidebar
  - mode/compose-full
  - mode/my-view          # Your new mode
```

**Lines 431-441:** Replace "Example: Voice Topos Modes" section. The section currently describes fantasy modes (voice-composing, text-composing, voice-minimal). Replace with real modes:

"The compose bar has two modes for the same spatial position:

**mode/compose-full** — Full compose bar with mic controls, transcription toggle, stance badge, clarify, express, and editable textarea. Bound to `accumulation/default`.

**mode/compose-transcribing** — Same control row, but textarea is readonly with 'Transcribing...' placeholder. Bound to `accumulation/default`.

Switching between them is reflex-driven: when `transcriber/default.desired_state` changes, a reflex swaps the active mode in the thyra-config. No field conditionals."

#### 3e. `docs/tutorial/presentation/create-a-mode.md`

**Line 138:** Replace `mode/text-composing` with `mode/compose-full` in thyra-config example.

**Lines 183-193:** Replace singleton bonus example `mode/text-composing` with `mode/compose-full`:

```yaml
  - eidos: mode
    id: mode/compose-full
    data:
      name: compose-full
      topos: thyra
      render_spec_id: render-spec/compose-full
      spatial:
        position: bottom
        height: auto
      source_entity_id: accumulation/default
```

**Phase 3 Complete When:**
- [ ] Zero grep matches for deleted mode names in design/explanation/tutorial docs
- [ ] DESIGN.md body-schema example uses real active_modes
- [ ] Mode counts match everywhere

---

## Files to Read

### Genesis (ground truth)
- `genesis/thyra/modes/screen.yaml` — The 5 actual modes
- `genesis/thyra/entities/layout.yaml` — The thyra-config active_modes
- `genesis/thyra/render-specs/compose-full.yaml` — Actual compose bar layout
- `genesis/thyra/render-specs/compose-transcribing.yaml` — Actual transcribing layout

### Docs to update
- `docs/how-to/presentation/voice-authoring.md` — Three modes → two, remove compose-minimal
- `docs/reference/domain/phasis-workspace.md` — Three modes → two, stance select → badge
- `docs/reference/reactivity/actualization-pattern.md` — Mode catalog, mode count
- `docs/reference/presentation/mode-reference.md` — Stale examples
- `docs/reference/infrastructure/substrate-lifecycle.md` — Stale voice-composing example
- `docs/design/VOICE-OIKOS-DESIGN.md` — Three modes → two, stale descriptions
- `docs/explanation/presentation/modes-and-oikos.md` — Stale mode names in examples
- `docs/how-to/presentation/mode-development.md` — Stale config example, fantasy mode names
- `docs/tutorial/presentation/create-a-mode.md` — Stale text-composing example
- `genesis/thyra/DESIGN.md` — Body-schema, mode count

### Orphan
- `genesis/thyra/typos/authoring-session-view.yaml` — Delete

---

## Files to Touch

| File | Change |
|------|--------|
| `genesis/thyra/typos/authoring-session-view.yaml` | **DELETE** — orphaned typos for deleted authoring-feed |
| `docs/how-to/presentation/voice-authoring.md` | **MODIFY** — two modes, remove compose-minimal row |
| `docs/reference/domain/phasis-workspace.md` | **MODIFY** — two modes, stance badge, remove compose-minimal |
| `docs/reference/reactivity/actualization-pattern.md` | **MODIFY** — 5 thyra modes, 17 total, fix mode table |
| `docs/reference/presentation/mode-reference.md` | **MODIFY** — replace stale examples with real modes |
| `docs/reference/infrastructure/substrate-lifecycle.md` | **MODIFY** — replace voice-composing example |
| `docs/design/VOICE-OIKOS-DESIGN.md` | **MODIFY** — two modes, fix descriptions |
| `docs/explanation/presentation/modes-and-oikos.md` | **MODIFY** — replace stale mode names |
| `docs/how-to/presentation/mode-development.md` | **MODIFY** — fix config example, replace fantasy modes |
| `docs/tutorial/presentation/create-a-mode.md` | **MODIFY** — replace text-composing with compose-full |
| `genesis/thyra/DESIGN.md` | **MODIFY** — fix body-schema, mode count |

---

## Success Criteria

### Phase 1
- [x] `authoring-session-view.yaml` deleted
- [x] `just prod` builds

### Phase 2
- [ ] `grep -r "compose-minimal" docs/` → 0 matches
- [ ] `grep -r "authoring-feed" docs/` → 0 matches
- [ ] `grep -r "text-composing" docs/` → 0 matches
- [ ] `grep -r "voice-composing" docs/` → 0 matches
- [ ] All compose bar descriptions match actual layout
- [ ] Doc examples use real mode names from screen.yaml

### Phase 3
- [ ] `grep -r "compose-minimal\|authoring-feed\|text-composing\|voice-composing" genesis/thyra/DESIGN.md` → 0 matches
- [ ] `grep -r "compose-minimal\|authoring-feed\|text-composing\|voice-composing" docs/design/` → 0 matches
- [ ] `grep -r "compose-minimal\|authoring-feed\|text-composing\|voice-composing" docs/explanation/` → 0 matches
- [ ] `grep -r "compose-minimal\|authoring-feed\|text-composing\|voice-composing" docs/tutorial/` → 0 matches
- [ ] DESIGN.md body-schema example uses actual active_modes
- [ ] Mode counts correct everywhere (5 thyra, 17 total, 2 compose)

**Overall Complete When:**
- [ ] All phase criteria met
- [ ] Zero stale mode references in docs/ and genesis/thyra/DESIGN.md
- [ ] `just prod` builds successfully

---

## What This Enables

- **Trustworthy docs**: A developer reading any doc gets accurate mode names, counts, and descriptions. No confusion from phantom modes.
- **Clean genesis**: No orphaned typos that reference deleted modes. Genesis is the graph of what exists.
- **Prompt 2 readiness**: With docs aligned, the settings panel ontology migration (PROMPT-SETTINGS-PANEL-ONTOLOGY.md) can build on accurate doc references.

---

## What Does NOT Change

- **No code changes** — this is pure doc/genesis cleanup
- **No render-spec changes** — compose-full and compose-transcribing are already correct
- **No mode entity changes** — screen.yaml already has the right 5 modes
- **No PROMPT-*.md edits** — completed prompts are historical records, not prescriptive
- **No docs/how-to/presentation/mode-development.md structural changes** — only fix examples and mode names, don't reorganize the guide
- **No chora (app/) changes** — all changes in kosmos (docs/ and genesis/)

---

*Traces to: T7 (rendering is graph-traversable), T8 (mode is topos presence), dead code policy, PROMPT-COMPOSE-BAR.md (completed), compose bar restructure session (2026-02-19)*
