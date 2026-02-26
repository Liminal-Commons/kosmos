# Layout Widget CSS Migration — Inline Styles to CSS Classes

*Prompt for Claude Code in the chora + kosmos repository context.*

*After this work, layout widgets (row, stack) use CSS classes instead of inline styles for all flex properties. Region resize fills content generically — any region, any layout direction, any mode — without per-mode CSS overrides or `!important`. Dead inline-style code and the `!important` resize hacks are deleted.*

---

## Architectural Principle — CSS Is the Substrate's Language

Theoria T11: "Reconciliation is substrate-universal. SolidJS handles the screen substrate."

The screen substrate's native language for layout is CSS, not JavaScript inline styles. When layout widgets set `display: flex`, `align-items`, `gap`, and `justify-content` via inline styles, they bypass CSS's cascade — the mechanism the substrate provides for contextual overrides. This forces `!important` hacks when a parent context (like a resized region) needs to alter child behavior.

The fix is not "better hacks." The fix is to stop fighting the substrate. Layout properties belong in CSS classes. Props from render-specs map to class names. The cascade does the rest.

```
render-spec prop          →  CSS class              →  CSS rule
align: center             →  .widget-row--align-center  →  align-items: center
gap: sm                   →  .widget-row--gap-sm        →  gap: var(--spacing-sm)

contextual override       →  natural cascade (no !important)
.thyra-region--resized .widget-row--align-center { align-items: stretch }
```

This applies to ALL layout widgets (row AND stack) and ALL resizable regions (bottom, left, right — any region with a resize handle, present or future).

---

## Methodology — DDD + TDD

This work follows **Doc → Test → Build → Verify**, non-negotiably.

1. **Doc (prescriptive)**: This prompt IS the prescriptive doc. The target state described here is what code must match.
2. **Test (assert the doc)**: Write tests that assert CSS class output and resize behavior.
3. **Build (satisfy the tests)**: Implement until tests pass.
4. **Verify doc**: After implementation, update success criteria. Check docs/REGISTRY.md impact map.

**Clean break, no backward compatibility.** Inline styles for layout properties are deleted. The `mapAlign()` and `mapJustify()` helper functions are deleted. The `!important` resize CSS is deleted. No shims, no fallbacks.

---

## Current State

### What Exists and Works

| Component | Location | Status |
|-----------|----------|--------|
| RowWidget | `app/src/lib/widgets/row.tsx` | Working — inline styles for all flex props |
| StackWidget | `app/src/lib/widgets/stack.tsx` | Working — inline styles for all flex props |
| Widget CSS | `app/src/lib/widgets/widgets.css` | Minimal — only `box-sizing: border-box` |
| Resize handle | `app/src/lib/layout-engine.tsx` | Working — sets explicit height + `.thyra-region--resized` class |
| Resize CSS | `app/src/styles.css:1200-1217` | Broken — uses `!important`, targets compose-bar-specific classes |
| widget/row eidos | `genesis/thyra/eide/widget.yaml:210-248` | Defined — gap, align, justify, padding props |
| widget/stack eidos | `genesis/thyra/eide/widget.yaml:176-208` | Defined — gap, align props |
| 97 render-specs | `genesis/*/render-specs/*.yaml` | Use row/stack with various prop combinations |

### What's Missing — The Gaps

1. **Inline styles prevent cascade overrides.** RowWidget and StackWidget set `display`, `flex-direction`, `align-items`, `justify-content`, and `gap` via inline `style={{...}}`. Inline styles have the highest specificity. CSS contextual overrides (like `.thyra-region--resized .widget-row { align-items: stretch }`) cannot work without `!important`.

2. **Resize CSS is mode-specific.** Current resize rules target `.compose-bar__input` and `.widget-textarea` — they only work for compose-full and only for the textarea. A different mode in the bottom region (or a future left-panel resize) would need its own CSS hacks.

3. **`mapAlign()` and `mapJustify()` are duplicated.** Both row.tsx and stack.tsx contain identical helper functions that convert prop values to CSS values. With CSS classes, this logic moves to the stylesheet — one definition, used everywhere.

4. **`padding` prop is broken.** RowWidget declares `padding` in its interface and computes the value, but the inline style only applies it inconsistently. StackWidget omits it entirely.

5. **`resize: none` on textarea.** Changed from `resize: vertical` during this session. Should stay `resize: none` since the region-level resize handle replaces it.

---

## Target State

### RowWidget (`app/src/lib/widgets/row.tsx`)

```tsx
export function RowWidget(props: RowWidgetProps): JSX.Element {
  const classes = () => [
    "widget-row",
    `widget-row--gap-${props.gap ?? "md"}`,
    `widget-row--align-${props.align ?? "center"}`,
    `widget-row--justify-${props.justify ?? "start"}`,
    props.padding ? `widget-row--padding-${props.padding}` : "",
    props.class ?? "",
  ].filter(Boolean).join(" ");

  return (
    <div class={classes()}>
      {props.children}
    </div>
  );
}
```

No inline styles. No `mapAlign()`. No `mapJustify()`. Props become class names.

### StackWidget (`app/src/lib/widgets/stack.tsx`)

```tsx
export function StackWidget(props: StackWidgetProps): JSX.Element {
  const classes = () => [
    "widget-stack",
    `widget-stack--gap-${props.gap ?? "md"}`,
    `widget-stack--align-${props.align ?? "stretch"}`,
    props.padding ? `widget-stack--padding-${props.padding}` : "",
    props.class ?? "",
  ].filter(Boolean).join(" ");

  return (
    <div class={classes()}>
      {props.children}
    </div>
  );
}
```

Same pattern. Stack defaults differ (align defaults to `stretch`, no justify).

### Widget CSS (`app/src/lib/widgets/widgets.css`)

```css
/* Row — flex row layout */
.widget-row {
  display: flex;
  flex-direction: row;
  box-sizing: border-box;
}

/* Row — gap scale */
.widget-row--gap-none { gap: 0; }
.widget-row--gap-xs   { gap: var(--spacing-xs); }
.widget-row--gap-sm   { gap: var(--spacing-sm); }
.widget-row--gap-md   { gap: var(--spacing-md); }
.widget-row--gap-lg   { gap: var(--spacing-lg); }
.widget-row--gap-xl   { gap: var(--spacing-xl); }

/* Row — align (cross-axis) */
.widget-row--align-start   { align-items: flex-start; }
.widget-row--align-center  { align-items: center; }
.widget-row--align-end     { align-items: flex-end; }
.widget-row--align-stretch { align-items: stretch; }

/* Row — justify (main-axis) */
.widget-row--justify-start   { justify-content: flex-start; }
.widget-row--justify-center  { justify-content: center; }
.widget-row--justify-end     { justify-content: flex-end; }
.widget-row--justify-between { justify-content: space-between; }
.widget-row--justify-around  { justify-content: space-around; }

/* Row — padding scale */
.widget-row--padding-none { padding: 0; }
.widget-row--padding-xs   { padding: var(--spacing-xs); }
.widget-row--padding-sm   { padding: var(--spacing-sm); }
.widget-row--padding-md   { padding: var(--spacing-md); }
.widget-row--padding-lg   { padding: var(--spacing-lg); }
.widget-row--padding-xl   { padding: var(--spacing-xl); }

/* Stack — flex column layout */
.widget-stack {
  display: flex;
  flex-direction: column;
  box-sizing: border-box;
}

/* Stack — gap scale (same tokens as row) */
.widget-stack--gap-none { gap: 0; }
.widget-stack--gap-xs   { gap: var(--spacing-xs); }
.widget-stack--gap-sm   { gap: var(--spacing-sm); }
.widget-stack--gap-md   { gap: var(--spacing-md); }
.widget-stack--gap-lg   { gap: var(--spacing-lg); }
.widget-stack--gap-xl   { gap: var(--spacing-xl); }

/* Stack — align (cross-axis) */
.widget-stack--align-start   { align-items: flex-start; }
.widget-stack--align-center  { align-items: center; }
.widget-stack--align-end     { align-items: flex-end; }
.widget-stack--align-stretch { align-items: stretch; }

/* Stack — padding scale */
.widget-stack--padding-none { padding: 0; }
.widget-stack--padding-xs   { padding: var(--spacing-xs); }
.widget-stack--padding-sm   { padding: var(--spacing-sm); }
.widget-stack--padding-md   { padding: var(--spacing-md); }
.widget-stack--padding-lg   { padding: var(--spacing-lg); }
.widget-stack--padding-xl   { padding: var(--spacing-xl); }
```

### Region Resize CSS (`app/src/styles.css`)

Generic rules — no mode-specific selectors, no `!important`:

```css
/* Region resize — generic fill behavior.
   When a region has been resized (explicit height/width), its content fills.
   Works for any mode, any layout direction. */

.thyra-region--resized {
  overflow: hidden;
}

/* Forms fill the resized region */
.thyra-region--resized .widget-form {
  flex: 1;
  display: flex;
  flex-direction: column;
  min-height: 0;
}

/* Stacks fill the resized region */
.thyra-region--resized .widget-stack {
  flex: 1;
  min-height: 0;
  min-width: 0;
}

/* Last row in a resized form fills remaining space, children stretch */
.thyra-region--resized .widget-form > .widget-row:last-child {
  flex: 1;
  align-items: stretch;
  min-height: 0;
}

/* Textareas fill their container when region is resized */
.thyra-region--resized .widget-textarea {
  height: 0;
  min-height: 0;
}
```

**DELETE** the following from styles.css:
- `.thyra-region--resized .compose-bar__input` (mode-specific)
- `.thyra-region--resized .compose-bar__input .widget-textarea` (mode-specific)
- `.compose-bar--minimal .widget-textarea` flex rule (now handled generically)

### What Gets Deleted

| Code | Location | Reason |
|------|----------|--------|
| `mapAlign()` function | row.tsx, stack.tsx | Replaced by CSS classes |
| `mapJustify()` function | row.tsx, stack.tsx | Replaced by CSS classes |
| `style={{...}}` inline styles | row.tsx, stack.tsx | Replaced by CSS classes |
| `.compose-bar__input` resize rules | styles.css:1208-1212 | Replaced by generic `.widget-row:last-child` |
| `.compose-bar__input .widget-textarea` resize rules | styles.css:1214-1217 | Replaced by generic `.widget-textarea` |
| `.compose-bar--minimal .widget-textarea` | styles.css:1220-1223 | Handled by row flex + generic textarea rule |

---

## Sequenced Work

### Phase 1: Layout Widget CSS Classes

**Goal:** Replace inline styles with CSS classes in row.tsx, stack.tsx, and widgets.css. Delete `mapAlign()`, `mapJustify()`, and all inline `style={{...}}` from both widgets.

**Tests:**
- `test_row_renders_css_classes` — RowWidget with `gap: sm, align: center, justify: between` renders `class="widget-row widget-row--gap-sm widget-row--align-center widget-row--justify-between"` with no inline style attribute
- `test_row_default_classes` — RowWidget with no props renders `widget-row widget-row--gap-md widget-row--align-center widget-row--justify-start`
- `test_row_padding_class` — RowWidget with `padding: xs` renders `widget-row--padding-xs`
- `test_row_custom_class` — RowWidget with `class: "my-class"` includes `my-class` in class list
- `test_stack_renders_css_classes` — StackWidget with `gap: sm, align: center` renders correct classes with no inline style
- `test_stack_default_classes` — StackWidget with no props renders `widget-stack widget-stack--gap-md widget-stack--align-stretch`

**Implementation:**
1. Write CSS class rules in `widgets.css` for row and stack (gap, align, justify, padding scales)
2. Rewrite `RowWidget` — delete `mapAlign()`, `mapJustify()`, inline `style={{...}}`. Build class string from props.
3. Rewrite `StackWidget` — same treatment. Delete `mapAlign()`, `mapJustify()`, inline styles.
4. Verify existing tests still pass (textarea tests, form tests, etc.)

**Phase 1 Complete When:**
- [ ] RowWidget renders CSS classes, zero inline styles
- [ ] StackWidget renders CSS classes, zero inline styles
- [ ] `mapAlign()` and `mapJustify()` deleted from both files
- [ ] All 6 new tests pass
- [ ] `just prod` builds clean

### Phase 2: Generic Region Resize

**Goal:** Replace mode-specific resize CSS with generic rules. Delete `!important` hacks, compose-bar-specific selectors, and any per-mode resize targeting.

**Tests:**
- Visual verification: compose-full at natural height shows 2-row textarea
- Visual verification: drag resize handle → textarea fills expanded space
- Visual verification: compose-transcribing behaves same as compose-full when resized
- Visual verification: compose-minimal at natural height shows 1-row readonly textarea

**Implementation:**
1. Delete from styles.css: `.thyra-region--resized .compose-bar__input`, `.thyra-region--resized .compose-bar__input .widget-textarea`, `.compose-bar--minimal .widget-textarea`
2. Write generic resize rules: `.thyra-region--resized .widget-form`, `.thyra-region--resized .widget-form > .widget-row:last-child`, `.thyra-region--resized .widget-textarea`
3. Verify the cascade works: `.widget-row--align-center` sets `align-items: center` at normal specificity; `.thyra-region--resized .widget-form > .widget-row:last-child` overrides it with `align-items: stretch` at higher specificity (two classes + child combinator vs one class). No `!important` needed.
4. `just prod` build + visual test

**Phase 2 Complete When:**
- [ ] Zero `!important` in resize CSS
- [ ] Zero compose-bar-specific selectors in resize CSS
- [ ] Textarea shows 2 rows at natural height
- [ ] Textarea fills region when resized via drag
- [ ] Works for compose-full, compose-transcribing, and compose-minimal
- [ ] `just prod` builds clean

---

## Files to Read

### Widgets (implementation)
- `app/src/lib/widgets/row.tsx` — current inline style implementation
- `app/src/lib/widgets/stack.tsx` — same pattern, vertical direction
- `app/src/lib/widgets/widgets.css` — current minimal CSS
- `app/src/lib/widgets/form.tsx` — form wraps compose bar children

### Layout Engine (resize)
- `app/src/lib/layout-engine.tsx` — resize handle, `thyra-region--resized` class

### Styles (resize CSS to delete)
- `app/src/styles.css:1200-1223` — current broken resize rules

### Render-specs (verify no breakage)
- `genesis/thyra/render-specs/compose-full.yaml` — 2 rows, textarea
- `genesis/thyra/render-specs/compose-transcribing.yaml` — 2 rows, readonly textarea
- `genesis/thyra/render-specs/compose-minimal.yaml` — 1 row, readonly textarea

### Docs (impact)
- `docs/reference/presentation/render-spec-authoring.md` — row/stack prop examples
- `genesis/thyra/eide/widget.yaml` — widget/row and widget/stack eidos definitions

---

## Files to Touch

| File | Change |
|------|--------|
| `app/src/lib/widgets/row.tsx` | **MODIFY** — delete inline styles, mapAlign, mapJustify; build CSS class string from props |
| `app/src/lib/widgets/stack.tsx` | **MODIFY** — same treatment as row |
| `app/src/lib/widgets/widgets.css` | **MODIFY** — add full CSS class rules for row and stack (gap, align, justify, padding scales) |
| `app/src/styles.css` | **MODIFY** — delete compose-bar-specific resize CSS; add generic region resize rules |

---

## Success Criteria

**Phase 1:**
- [ ] Row and stack use CSS classes, zero inline styles
- [ ] `mapAlign()` and `mapJustify()` deleted
- [ ] 6 new widget tests pass
- [ ] `just prod` builds

**Phase 2:**
- [ ] Zero `!important` in codebase resize CSS
- [ ] Zero mode-specific selectors in resize CSS
- [ ] Textarea natural height = rows attribute
- [ ] Textarea fills resized region
- [ ] All three compose modes render correctly

**Overall Complete When:**
- [ ] All existing tests still pass
- [ ] Layout widgets are pure CSS-class-driven
- [ ] Region resize is generic — works for any mode in any resizable region
- [ ] Dead inline-style code deleted
- [ ] `just prod` builds and visual verification passes

---

## What This Enables

- **Any future resizable region** (left panel, right panel) gets fill behavior for free — no per-mode CSS.
- **New layout widgets** follow the CSS class pattern — no inline styles to fight.
- **Render-spec authors** keep the same prop vocabulary (`gap: sm`, `align: center`) — the change is invisible to kosmos.
- **CSS themes** can override layout behavior contextually through the cascade, as CSS was designed to do.

---

## What Does NOT Change

- **Render-spec syntax** — `widget: row` with `gap:`, `align:`, `justify:`, `padding:` props stays identical. Zero render-spec changes.
- **Widget eidos definitions** — `widget.yaml` props_schema stays the same.
- **Resize handle JS** — the drag interaction in layout-engine.tsx stays as-is.
- **Other widgets** — button, textarea, input, card, icon, etc. are untouched.
- **Global keyboard shortcuts** — Shift+Space, Ctrl+Space stay as-is.

---

*Traces to: T11 (Reconciliation is substrate-universal), T7 (Rendering is graph-traversable), Compose Bar UX plan (resize handle). Supersedes the ad-hoc resize CSS from the current session.*
