# PROMPT-SENSE-THYRA — Sense actuality of thyra presentation modes

*Sense prompt for Claude Code. This is an αἴσθησις instrument — it observes actuality and reports whether it conforms to existence (the prescriptive target in actualization-pattern.md).*

*Do NOT implement anything. Only sense and report.*

---

## Modes Under Observation

| Mode | Topos | Pattern | Target Stage | Source |
|------|-------|---------|-------------|--------|
| `mode/authoring-feed` | authoring | singleton | 5 (Reactive) | `genesis/thyra/modes/screen.yaml` |
| `mode/text-composing` | voice | singleton | 5 (Reactive) | `genesis/thyra/modes/screen.yaml` |
| `mode/voice-composing` | voice | singleton | 5 (Reactive) | `genesis/thyra/modes/screen.yaml` |
| `mode/oikos-nav` | politeia | collection | 5 (Reactive) | `genesis/thyra/modes/screen.yaml` |
| `mode/theoria-sidebar` | nous | collection | 5 (Reactive) | `genesis/thyra/modes/screen.yaml` |
| `mode/phasis-feed` | logos | collection | 5 (Reactive) | `genesis/thyra/modes/screen.yaml` |

---

## Thyra Stage Criteria — What to Check

Thyra modes have different stages than dynamis modes (no substrate, no stoicheion dispatch):

### Stage 1: Prescribe
- [ ] Mode entity exists in `genesis/thyra/modes/screen.yaml`
- [ ] Has `render_spec_id` or `item_spec_id` (determines pattern)
- [ ] Has `spatial` block with `position` and `height`
- **Check:** Read `genesis/thyra/modes/screen.yaml`. Confirm all 6 modes are present with correct fields.

### Stage 2: Render
- [ ] Referenced render-spec entities exist in genesis
- [ ] Render-specs contain valid widget trees that the interpreter can render
- [ ] For collection modes: `item_spec_id` render-spec is valid
- [ ] For singleton modes: `render_spec_id` render-spec is valid
- **Check:** For each mode, trace the `render_spec_id` or `item_spec_id` to its render-spec entity. Read the render-spec YAML. Confirm the widget tree uses known widget types. Check if bonds (`uses-render-spec`) exist in `screen.yaml`.

### Stage 3: Compose
- [ ] Mode is referenced by a thyra configuration entity
- [ ] `thyra-config` entity lists this mode as available
- **Check:** Search genesis for thyra configuration entities. Check `genesis/thyra/` for entities referencing these modes.

### Stage 4: Active
- [ ] Mode can be activated/deactivated via `politeia/switch-mode` or equivalent praxis
- [ ] Layout engine in `layout-engine.tsx` dispatches to the correct renderer for each pattern
- [ ] ModeRenderer correctly handles: singleton → EntityBound, collection → CollectionMode, compound → CompoundMode
- **Check:** Read `app/src/lib/layout-engine.tsx`. Verify ModeRenderer dispatch logic. Check that pattern detection works (source_entity_id → singleton, item_spec_id → collection, sections → compound).

### Stage 5: Reactive
- [ ] Mode switches trigger reflexes or reactive updates
- [ ] Entity changes (new phasis, new theoria, oikos update) propagate to the visible mode
- [ ] SolidJS reactivity connects entity store to rendered widgets
- [ ] `config.watch_eidos` triggers re-query when entities of that eidos change
- **Check:** Read `app/src/lib/layout-engine.tsx` and `app/src/stores/` for reactive subscription patterns. Check if `createEffect` or `createResource` watches entity changes. For collection modes, verify that new entities appearing in the graph automatically appear in the rendered list.

---

## Per-Mode Specifics

### mode/authoring-feed (singleton)
- `render_spec_id: render-spec/artifact`
- `source_query: gather(eidos: phasis, sort: expressed_at, order: asc)`
- `config.typos_id: typos/authoring-session-view` — uses typos for composition
- `config.watch_eidos: phasis` — should react to new phaseis

### mode/text-composing (singleton)
- `render_spec_id: render-spec/text-compose`
- `source_entity_id: accumulation/default` — bound to singleton accumulation entity
- Should react to accumulation entity changes (keystroke → entity update → re-render)

### mode/voice-composing (singleton)
- `render_spec_id: render-spec/voice-bar`
- `source_entity_id: accumulation/default`
- `requires: [mode/voice]` — depends on voice dynamis mode being active
- Should react to accumulation and stream state changes

### mode/oikos-nav (collection)
- `item_spec_id: render-spec/oikos-card` + `chrome_spec_id: render-spec/oikos-chrome`
- `arrangement: scroll`
- `source_query: gather(eidos: oikos, sort: name, order: asc)`
- Should react to new oikos entities appearing

### mode/theoria-sidebar (collection)
- `item_spec_id: render-spec/theoria-card` + `chrome_spec_id: render-spec/theoria-chrome`
- `arrangement: scroll`
- `source_query: gather(eidos: theoria, sort: domain, order: asc)`
- Should react to new theoria entities appearing

### mode/phasis-feed (collection)
- `item_spec_id: render-spec/phasis-bubble`
- `arrangement: scroll-bottom` — auto-scroll on new items
- `source_query: gather(eidos: phasis, sort: expressed_at, order: desc)`
- `config.watch_eidos: phasis` — should react to new phaseis
- Should auto-scroll when new phasis appears

---

## Files to Read

| File | What to Check |
|------|---------------|
| `genesis/thyra/modes/screen.yaml` | All 6 mode entity definitions |
| `genesis/thyra/render-specs/` | Referenced render-spec entities |
| `genesis/thyra/` | Thyra configuration entities |
| `app/src/lib/layout-engine.tsx` | ModeRenderer dispatch, pattern detection, reactive subscriptions |
| `app/src/lib/widgets/` | Widget implementations referenced by render-specs |
| `app/src/stores/` | Entity store and reactive primitives |
| `genesis/politeia/praxeis/` | Mode switching praxeis |

---

## Report Format

For each mode, report:

```
mode/phasis-feed:
  Actual stage: N
  Pattern: collection (item_spec_id)
  Render-spec exists: yes/no
  Reactive: yes/no (does the rendered list update when entities change?)
  Gap from target: {5 - N} stages
  Blocking issue: {what prevents advancement to next stage}
```

Then update the Target Completion Matrix in `docs/reference/reactivity/actualization-pattern.md` Section 7.

---

*Traces to: actualization-pattern.md Section 2 (The Actualization Cycle — Sense moment), T7 (rendering is graph-traversable), T8 (mode is topos presence)*
