# Front 1: Modernize Render-Specs

## Goal

Every topos has an `entities/rendering.yaml` that uses legacy HTML `layout_template` format. These need to be either:
1. **Replaced** by widget-based render-spec files in `render-specs/` (if the render-spec doesn't exist yet)
2. **Deprecated** (if a widget-based render-spec already covers the same eidos+variant)

This is mechanical but high-coverage work — 14 files across 14 topoi.

## The Two Formats

### Legacy (entities/rendering.yaml) — to be replaced

```yaml
- eidos: render-spec
  id: render-spec/theoria-card
  data:
    name: theoria-card
    target_eidos: theoria
    variant: card
    layout_template: |
      <article class="theoria-card theoria-{status}">
        <header>{insight}</header>
        <footer>{domain} | {status}</footer>
      </article>
    style_bindings:
      theoria-crystallized: "border-left: 4px solid var(--status-crystallized)"
```

### Modern (render-specs/*.yaml) — the target format

```yaml
- eidos: render-spec
  id: render-spec/theoria-card
  data:
    name: theoria-card
    target_eidos: theoria
    variant: card
    layout:
      - widget: card
        props:
          variant: bordered
          padding: md
        children:
          - widget: stack
            props:
              gap: sm
            children:
              - widget: text
                props:
                  content: "{insight}"
                  variant: emphasis
              - widget: row
                props:
                  gap: sm
                children:
                  - widget: badge
                    props:
                      content: "{domain}"
                      variant: info
                  - widget: badge
                    when: "status == 'crystallized'"
                    props:
                      content: "Crystallized"
                      variant: success
```

## Widget Vocabulary Reference

Available widgets (from `genesis/thyra/eide/widget.yaml`):

**Layout:** card, stack, row, list, list-item
**Display:** text, heading, badge, icon, image, code
**Interactive:** button, link
**Feedback:** progress, status-indicator, avatar, spinner
**Composition:** for-each, include, scroll
**Utility:** divider, spacer

**Key props:**
- `card`: variant (default|bordered|elevated|compact), padding (none|sm|md|lg)
- `stack`: gap (none|xs|sm|md|lg|xl), align
- `row`: gap, align, justify (start|center|end|between|around)
- `text`: content (binding), variant (body|caption|label|emphasis|title)
- `badge`: content, variant (default|success|warning|error|info)
- `status-indicator`: status (maps to colors automatically)
- `button`: label, variant, on_click (praxis ID), on_click_params
- `for-each`: source (binding to array), empty_message
- `include`: spec (render-spec ID)

**Conditional rendering:** Use `when:` on any widget
**Data binding:** Use `{field_name}` in props to bind entity data

## Files to Process

These 14 `entities/rendering.yaml` files contain legacy HTML render-specs:

1. `genesis/politeia/entities/rendering.yaml`
2. `genesis/ekdosis/entities/rendering.yaml`
3. `genesis/dokimasia/entities/rendering.yaml`
4. `genesis/credentials/entities/rendering.yaml`
5. `genesis/aither/entities/rendering.yaml`
6. `genesis/oikos/entities/rendering.yaml`
7. `genesis/propylon/entities/rendering.yaml`
8. `genesis/thyra/entities/rendering.yaml`
9. `genesis/hypostasis/entities/rendering.yaml`
10. `genesis/ergon/entities/rendering.yaml`
11. `genesis/psyche/entities/rendering.yaml`
12. `genesis/dynamis/entities/rendering.yaml`
13. `genesis/agora/entities/rendering.yaml`
14. `genesis/nous/entities/rendering.yaml`

## How to Do It

For each `entities/rendering.yaml`:

1. **Read** the file to understand what render-specs it defines (eidos, variant, fields used)
2. **Check** if a widget-based render-spec already exists in `render-specs/` for the same eidos+variant
3. **If duplicate**: Remove the legacy entry from rendering.yaml (the widget version is authoritative)
4. **If no widget version exists**: Create a new file in `render-specs/{eidos}-{variant}.yaml` using widget syntax
5. **If rendering.yaml becomes empty** of render-specs (only has non-render-spec entities like panel-renderers): leave it with just those entries
6. **If rendering.yaml becomes entirely empty**: delete it

## Translation Patterns

| HTML Pattern | Widget Equivalent |
|-------------|-------------------|
| `<article class="...">` | `widget: card` with variant |
| `<header>` / `<h3>` | `widget: heading` or `widget: text` with variant: emphasis |
| `<footer>` | `widget: row` at bottom of stack |
| `<span class="badge">` | `widget: badge` |
| `<div class="status-{x}">` | `widget: status-indicator` with status binding |
| `{field}` interpolation | `{field}` in widget props (same syntax) |
| CSS class conditionals | `when:` on widget |
| `style_bindings` | Not needed — widget variants handle styling |
| Nested `<div>` | `widget: stack` or `widget: row` |

## Existing Widget Render-Specs (already done — don't duplicate)

These 45 files in `render-specs/` already use widget syntax:

**politeia:** oikos-card, oikos-list-item, oikos-list, attainment-card, affordance-card, invitation-card, membership-event-item, governance-panel
**thyra:** voice-bar, text-compose, presence-list, circle-list, expression-thread, theoria-list, journey-list, artifact
**nous:** theoria-card, theoria-list, journey-card, waypoint-item, inquiry-card, axiom-card, principle-card, pattern-card
**ergon:** pragma-card, reflex-card
**logos:** phasis-bubble, phasis-thread, phasis-thread-item
**psyche:** attention-card, intention-card, mood-card, prospect-card, kairos-card, thyra-card
**hypostasis:** presence-list
**release:** release-card, release-artifact-card, distribution-channel-card
**my-nodes:** dashboard
**chora-dev:** workspace-panel, lint-run-card, test-run-card, build-target-card, source-crate-card

## Verification

After processing all 14 files:
- No `layout_template:` or `style_bindings:` remain in any YAML file
- Every eidos declared `renderable:` in a manifest has at least one render-spec in `render-specs/`
- All render-specs use `layout:` with widget arrays, not HTML strings
