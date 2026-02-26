# Settings Panel Ontology — Migrate Settings from Hardcoded Component to Mode System

*Prompt for Claude Code in the chora + kosmos repository context.*

*After this work, the settings panel is a thyra mode with a render-spec. The gear button lives in oikos-chrome, not hardcoded in App.tsx. The layout engine renders overlay-positioned modes outside the spatial grid. Audio device selection and transcriber configuration are render-spec sections with standard widgets. Credential and keyring sections remain native (security-critical crypto) but are embedded in the render-spec via a native widget bridge. The hardcoded SettingsPanel overlay in App.tsx is deleted.*

---

## Architectural Principle — T7 + T8: Rendering Is Graph-Traversable, Mode Is Topos Presence

Settings is configuration — a topos concern. It should be present through the mode system, not hardcoded in App.tsx. The settings trigger (gear button) should be in a render-spec. The settings overlay should be a mode. The settings content should use render-spec widgets where possible.

> T7: How content displays is embodied as entities. Display configuration is data, not code.
> T8: A mode is how a topos presents itself in a spatial position. A topos that has no modes is invisible.

Currently, the settings panel violates both: a raw `<button>` in App.tsx toggles a `<Show>` that renders a native SolidJS component. None of this is in the graph. None of it is traversable. The interpreter doesn't know settings exists.

**The boundary:** Credential encryption requires Tauri process memory (master seed, AES-256-GCM). Keyring unlock requires Argon2id KDF. These are security-critical chora operations that cannot be render-spec driven — they need direct access to `KeyringSession` in Tauri state. The ontological migration covers the *presentation layer*, not the crypto layer. Native code handles crypto; render-specs handle rendering.

---

## Methodology — DDD + TDD

This work follows **Doc → Test → Build → Verify**, non-negotiably.

1. **Doc (prescriptive)**: This prompt IS the prescriptive doc. The target state described here is what code must match.
2. **Test (assert the doc)**: Tests assert mode renders, overlay positioning, widget behavior.
3. **Build (satisfy the tests)**: Implement until tests pass.
4. **Verify doc**: After implementation, update docs/REGISTRY.md impact map.

**Incremental migration — not big-bang.** Each phase independently adds value. Phase 1 removes the App.tsx violations. Phase 2 replaces native sections with render-spec widgets. Credential/keyring sections remain native until sidecar praxis wiring is addressed (future prompt).

---

## Current State

### What Exists and Works

| Component | Location | Status |
|-----------|----------|--------|
| SettingsPanel.tsx | `app/src/components/SettingsPanel.tsx` | Working — 4 native sections (keyring, credentials, audio, transcriber) |
| Settings trigger | `app/src/App.tsx:78-84` | Working — hardcoded gear button |
| Settings overlay | `app/src/App.tsx:92-99` | Working — hardcoded `<Show>` + overlay div |
| Settings CSS | `app/src/styles.css:959-1191` | Working — `.settings-overlay`, `.settings-panel`, 20+ sub-classes |
| `modal` widget | `app/src/lib/widgets/modal.tsx` | Working — Portal, Escape, body scroll lock |
| `input` widget | `app/src/lib/widgets/input.tsx` | Working — type text/email/password/number/url |
| `select` widget | `app/src/lib/widgets/select.tsx` | Working — options, field registration, on_change |
| `tabs` widget | `app/src/lib/widgets/tabs.tsx` | Working — tab navigation |
| Audio praxeis | `genesis/soma/praxeis/` | Working — `list-audio-devices`, `update-audio-device`, `update-transcriber-config` |
| Credential entities | `genesis/credentials/` | Working — eidos/credential in graph with encrypted values |

### What's Missing — The Gaps

1. **No settings mode.** Settings is invisible to the mode system. The layout engine doesn't know it exists.

2. **No overlay position.** Layout engine handles `top/left/center/right/bottom` — no support for modes that render as overlays.

3. **Settings trigger is hardcoded.** The gear button in App.tsx:78-84 is not in any render-spec.

4. **InputWidget has no form registration.** Unlike SelectWidget and TextareaWidget, InputWidget doesn't register with form context — `$form.field` can't read input values.

5. **No `available_devices` on audio-source entity.** The device list comes from a praxis call, not entity data. The select widget can't bind to it.

6. **Settings open/close state has no entity.** The `showSettings` signal in App.tsx is local React state, not graph state.

---

## Target State

### Ontology

```yaml
# New eidos
eidos/settings-panel:
  fields: [open, active_tab]

# New entity
settings-panel/default:
  open: false
  active_tab: audio

# New mode
mode/settings-overlay:
  topos: thyra
  spatial: { position: overlay }
  render_spec_id: render-spec/settings-overlay
  source_entity_id: settings-panel/default

# Updated mode (chrome now includes settings button)
mode/oikos-nav:
  chrome_spec_id: render-spec/oikos-chrome  # ← already exists, add settings button
```

### Layout Engine

```
POSITION_ORDER = ["top", "left", "center", "right", "bottom"]

Render order:
  1. Standard regions: For each position in POSITION_ORDER → thyra-region div
  2. Overlay modes: For each mode with position="overlay" → render directly (no region wrapper)
```

Overlay modes render after the spatial grid. Their render-specs use `modal` widget (which Portals to body). No thyra-region wrapper needed — the widget tree IS the overlay.

### Oikos Chrome (settings trigger)

```yaml
# render-spec/oikos-chrome — updated
layout:
  - widget: row
    props:
      align: center
      gap: sm
      class: sidebar-chrome
    children:
      - widget: heading
        props:
          level: 3
          content: "Oikoi"
      - widget: spacer
        props:
          size: flex
      - widget: button
        props:
          variant: ghost
          class: settings-trigger
          on_click: thyra/toggle-settings
        children:
          - widget: icon
            props:
              name: settings
              size: sm
```

### Settings Render-Spec

```yaml
# render-spec/settings-overlay
layout:
  - widget: modal
    props:
      open: "{open}"
      title: "Settings"
      size: md
      onClose: thyra/close-settings
      onClose_params:
        entity_id: "{id}"
    children:
      # Audio Input section
      - widget: stack
        props:
          gap: md
        children:
          - widget: heading
            props:
              level: 3
              content: "Audio Input"
          - widget: select
            props:
              field: device_id
              value: "{@fed-by-audio.data.device_id}"
              options: "{@fed-by-audio.data.available_devices}"
              on_change: soma/update-audio-device
              on_change_params:
                entity_id: "{@fed-by-audio.id}"
                device_id: $event.target.value

      # Transcriber Configuration section
      - widget: stack
        props:
          gap: md
        children:
          - widget: heading
            props:
              level: 3
              content: "Transcriber"
          - widget: form
            props:
              class: settings-config-form
            children:
              - widget: select
                props:
                  field: whisper_model
                  value: "{@fed-by-transcriber.data.whisper_model}"
                  options: # static options from render-spec
                    - { value: "tiny.en", label: "Tiny (English)" }
                    - { value: "base.en", label: "Base (English)" }
                    - { value: "small.en", label: "Small (English)" }
                    - { value: "medium.en", label: "Medium (English)" }
                    - { value: "large-v3", label: "Large v3 (Multilingual)" }
              - widget: input
                props:
                  name: language
                  type: text
                  value: "{@fed-by-transcriber.data.language}"
                  placeholder: "en"
              - widget: input
                props:
                  name: whisper_threads
                  type: number
                  value: "{@fed-by-transcriber.data.whisper_threads}"
              - widget: button
                props:
                  label: "Save"
                  on_click: soma/update-transcriber-config
                  on_click_params:
                    entity_id: "{@fed-by-transcriber.id}"
                    whisper_model: $form.whisper_model
                    language: $form.language
                    whisper_threads: $form.whisper_threads
```

### Input Widget (enhanced)

```typescript
// Add name prop + form registration (same pattern as SelectWidget.field)
export interface InputWidgetProps {
  name?: string;       // ← NEW: form field name for $form.name binding
  value?: string;
  placeholder?: string;
  type?: "text" | "email" | "password" | "number" | "url";
  disabled?: boolean;
  on_change?: (event?: Event) => void;
}
```

### Audio-Source Entity (enhanced)

```yaml
# audio-source/default gets available_devices field
data:
  desired_state: closed
  actual_state: closed
  device_id: default
  available_devices:    # ← NEW: populated by thyra/open-settings praxis
    - { value: "default", label: "System Default" }
    - { value: "device-123", label: "MacBook Pro Microphone" }
```

### New Praxeis

| Praxis | Purpose |
|--------|---------|
| `thyra/toggle-settings` | Toggle `settings-panel/default.open` (true ↔ false). When opening: invoke `soma/list-audio-devices`, store result on `audio-source/default.available_devices`. |
| `thyra/close-settings` | Set `settings-panel/default.open` to false. |

### App.tsx (cleaned)

After migration, App.tsx has:
- **NO** settings trigger button
- **NO** settings overlay Show/div
- **NO** SettingsPanel import
- The layout engine renders everything including settings

---

## Sequenced Work

### Phase 1: Settings Mode + Overlay Rendering

**Goal:** Settings exists as a mode. The gear button is in oikos-chrome. The layout engine renders overlay modes. App.tsx no longer has hardcoded settings.

**Tests:**
- test_settings_mode_exists — bootstrap finds `mode/settings-overlay` entity
- test_overlay_position_rendered — layout engine renders modes with position=overlay
- test_settings_toggle_praxis — `thyra/toggle-settings` flips open field
- test_oikos_chrome_has_settings_button — oikos-chrome render-spec includes settings button

**Implementation:**

1. Create `genesis/thyra/eide/settings.yaml` — eidos/settings-panel with fields: open (bool), active_tab (string)
2. Create `genesis/thyra/entities/settings.yaml` — settings-panel/default entity (open: false, active_tab: audio)
3. Create `genesis/thyra/modes/overlay.yaml` — mode/settings-overlay (position: overlay, source_entity_id: settings-panel/default)
4. Create `genesis/thyra/render-specs/settings-overlay.yaml` — modal widget wrapping a `stack` with placeholder text (sections added in Phase 2)
5. Create bonds: settings-panel/default `fed-by-audio` → audio-source/default, `fed-by-transcriber` → transcriber/default
6. Create `genesis/thyra/praxeis/settings.yaml` — thyra/toggle-settings, thyra/close-settings praxeis
7. Implement toggle-settings and close-settings in Rust (read-modify-write settings-panel entity)
8. Update `render-spec/oikos-chrome` — add row with heading + spacer + settings button
9. Update `thyra-config/workspace` active_modes — add mode/settings-overlay
10. Layout engine: after standard position rendering, render overlay-positioned modes without region wrapper
11. Delete from App.tsx: settings trigger button, settings overlay Show/div, SettingsPanel import, showSettings signal
12. Delete `app/src/components/SettingsPanel.tsx`
13. Delete settings-panel CSS from styles.css (`.settings-overlay`, `.settings-panel`, all sub-classes)
14. Add modal CSS if not already present (`.modal-overlay`, `.modal-content`, `.modal__header`, etc.)

**Phase 1 Complete When:**
- [ ] `mode/settings-overlay` exists in bootstrap
- [ ] Layout engine renders overlay modes (position: overlay)
- [ ] Settings button in oikos-chrome opens modal
- [ ] Modal closes on Escape, overlay click, close button
- [ ] App.tsx has zero settings-related code
- [ ] `just prod` builds

### Phase 2: Audio + Transcriber Render-Spec Sections

**Goal:** Audio device selection and transcriber configuration are render-spec widgets, not native code.

**Tests:**
- test_input_widget_form_registration — InputWidget with `name` prop registers with form context, `$form.name` reads value
- test_available_devices_populated — toggle-settings praxis populates audio-source available_devices
- test_settings_audio_section — select widget renders with device options
- test_settings_transcriber_section — form with select + inputs + save button

**Implementation:**

1. Add `name` prop + form registration to InputWidget (same pattern as SelectWidget.field):
   - Add `name?: string` to InputWidgetProps
   - Call `useFormRegistration()` and `registerField(props.name, () => inputRef.value)` when name is set
   - Add `registerResetter()` for form reset support
   - Add `ref` to input element

2. Add `available_devices` field to `genesis/soma/eide/audio.yaml` (eidos/audio-source)

3. Update `thyra/toggle-settings` praxis implementation:
   - Call `soma/list-audio-devices`
   - Transform result into `[{value, label}]` format (with "default"/"System Default" prepended)
   - Store on `audio-source/default.data.available_devices` via update_entity

4. Create render-spec/settings-overlay with full sections:
   - Audio section: heading + select bound to `{@fed-by-audio.data.device_id}` with `options: "{@fed-by-audio.data.available_devices}"`
   - Transcriber section: heading + form with select (whisper_model) + input (language) + input (threads) + save button
   - Credential section: placeholder text ("Credential management coming soon" or keep basic native display)

5. Wire select `on_change` → `soma/update-audio-device` with `$event.target.value`
6. Wire save button `on_click` → `soma/update-transcriber-config` with `$form.*` bindings

**Phase 2 Complete When:**
- [ ] InputWidget registers with form context when `name` prop set
- [ ] toggle-settings populates available_devices on audio-source entity
- [ ] Audio device dropdown renders from entity data, changes invoke praxis
- [ ] Transcriber form reads/writes entity data via praxis
- [ ] `just prod` builds

---

## Files to Read

### Genesis (ground truth)
- `genesis/thyra/modes/screen.yaml` — existing modes
- `genesis/thyra/entities/layout.yaml` — thyra-config active_modes
- `genesis/soma/eide/audio.yaml` — audio-source eidos
- `genesis/soma/eide/voice.yaml` — transcriber eidos
- `genesis/soma/entities/voice.yaml` — audio-source/default, transcriber/default entities
- `genesis/soma/entities/bonds.yaml` — fed-by-audio, fed-by-transcriber bonds
- `genesis/politeia/render-specs/oikos-chrome.yaml` — current oikos chrome

### Chora (implementation)
- `app/src/App.tsx` — hardcoded settings trigger + overlay to delete
- `app/src/components/SettingsPanel.tsx` — native component to replace
- `app/src/lib/layout-engine.tsx` — position rendering, overlay support needed
- `app/src/lib/widgets/input.tsx` — needs name + form registration
- `app/src/lib/widgets/select.tsx` — reference for form registration pattern
- `app/src/lib/widgets/modal.tsx` — reference for overlay rendering
- `app/src/lib/widgets/form.tsx` — form context, useFormRegistration
- `app/src/lib/render-spec.tsx` — how RenderSpecRenderer resolves props
- `app/src/lib/bindings.ts` — how on_click + on_click_params resolve handlers
- `app/src/styles.css` — settings CSS to delete, modal CSS to verify

---

## Files to Touch

| File | Change |
|------|--------|
| `genesis/thyra/eide/settings.yaml` | **NEW** — eidos/settings-panel |
| `genesis/thyra/entities/settings.yaml` | **NEW** — settings-panel/default entity + bonds |
| `genesis/thyra/modes/overlay.yaml` | **NEW** — mode/settings-overlay |
| `genesis/thyra/render-specs/settings-overlay.yaml` | **NEW** — settings modal render-spec |
| `genesis/thyra/praxeis/settings.yaml` | **NEW** — toggle-settings, close-settings |
| `genesis/politeia/render-specs/oikos-chrome.yaml` | **MODIFY** — add settings button |
| `genesis/thyra/entities/layout.yaml` | **MODIFY** — add mode/settings-overlay to workspace active_modes |
| `genesis/thyra/modes/screen.yaml` | **MODIFY** — add uses-render-spec bond for settings-overlay |
| `genesis/soma/eide/audio.yaml` | **MODIFY** — add available_devices field to audio-source eidos |
| `app/src/lib/layout-engine.tsx` | **MODIFY** — render overlay-positioned modes outside spatial grid |
| `app/src/lib/widgets/input.tsx` | **MODIFY** — add name prop + form registration |
| `app/src/App.tsx` | **MODIFY** — delete settings trigger, overlay, import, signal |
| `app/src/components/SettingsPanel.tsx` | **DELETE** — replaced by render-spec |
| `app/src/styles.css` | **MODIFY** — delete settings-panel CSS, verify modal CSS |
| `crates/kosmos/src/host.rs` | **MODIFY** — implement toggle-settings, close-settings praxeis |

---

## Success Criteria

### Phase 1
- [ ] `mode/settings-overlay` bootstraps with position: overlay
- [ ] Layout engine renders overlay modes outside spatial grid
- [ ] Settings button in oikos-chrome invokes thyra/toggle-settings
- [ ] Modal opens/closes, Escape works, overlay click closes
- [ ] App.tsx has zero settings code (no trigger, no overlay, no import)
- [ ] `just prod` builds

### Phase 2
- [ ] InputWidget supports `name` prop with form registration
- [ ] toggle-settings populates available_devices on audio-source
- [ ] Audio select renders devices, change invokes soma/update-audio-device
- [ ] Transcriber form reads entity data, save invokes soma/update-transcriber-config
- [ ] `just prod` builds
- [ ] All existing tests still pass

**Overall Complete When:**
- [ ] All phase criteria met
- [ ] Settings panel is a mode (visible in the mode system)
- [ ] Gear button is in oikos-chrome render-spec (not App.tsx)
- [ ] Audio + transcriber sections are render-spec widgets
- [ ] `just prod` builds

---

## What This Enables

- **Credential migration (future):** Once sidecar praxis wiring is in place, credential display (collection mode gathering eidos: credential) and credential add (input widgets + hypostasis/add-credential praxis) can move to render-spec sections. The keyring unlock section similarly becomes render-spec driven once hypostasis/unlock-keyring is invocable from the executor.
- **Settings extensibility via genesis:** New settings sections can be added by editing the render-spec YAML — no TypeScript changes needed. Any topos can contribute settings sections.
- **Settings as topos presence:** Settings becomes discoverable via `gather(eidos: mode)` — agents can see what modes exist, what they render, what entity they bind to.
- **Overlay mode pattern:** Other features that need overlay presentation (confirmation dialogs, detail panels, modal editors) can follow the same pattern: mode with position=overlay, render-spec with modal widget.

---

## What Does NOT Change

- **Credential encryption** — Stays in Tauri commands. AES-256-GCM + Argon2id remain in process memory.
- **Keyring lifecycle** — unlock_keyring, lock_keyring remain Tauri commands until sidecar praxis wiring.
- **UnlockScreen / RecoveryScreen** — These are full-screen pre-auth screens, not modes. They stay in App.tsx.
- **WelcomeScreen / OnboardingScreen** — Same — pre-auth flows stay native.
- **Credential display** — Remains as a placeholder or simple text in Phase 2. Full collection-mode credential list is future work.
- **Existing praxeis** — soma/list-audio-devices, soma/update-audio-device, soma/update-transcriber-config unchanged.

---

*Traces to: T7 (rendering is graph-traversable), T8 (mode is topos presence), T53 (modes make topos presence traversable), settings panel T-violation identified in compose bar restructure session (2026-02-19)*
