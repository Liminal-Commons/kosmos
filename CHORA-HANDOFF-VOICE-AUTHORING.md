# Chora Handoff: Voice-Authoring Mode

This document describes the voice-authoring oikos implementation in kosmos and what needs to be built in chora to actualize it.

---

## Overview

**Voice-authoring** is a mode (oikos) where discussion drives authorship. Humans speak about a focused artifact, and the artifact updates through conversation. No hand-editing — the creative act is conversational.

**The insight**: The artifact at any moment is self-sufficient. It doesn't need all prior expressions to be meaningful. The conversation shapes it; the result stands alone.

---

## What Exists in Kosmos

### Oikos Structure

```
genesis/voice-authoring/
├── DESIGN.md                    # Full experience specification
├── manifest.yaml                # Oikos declaration
├── eide/voice-authoring.yaml    # authoring-session eidos, attainment
├── desmoi/voice-authoring.yaml  # authoring bond
├── entities/
│   ├── layout.yaml              # HUD layout, 3 panels
│   └── typos.yaml               # Composition templates
└── praxeis/voice-authoring.yaml # 10 operations
```

### Key Entities

#### authoring-session (new eidos)

Tracks the state of a voice-authoring session.

```yaml
fields:
  focused_artifact_id: string      # Currently authored artifact
  expanded_bonds: array            # Bonds "in view" for context
  context_depth: number            # How deep to gather context (default 1)
  inference_pattern_id: string     # Typos for updates (default: typos-inference-update-artifact)
  status: enum [active, paused, ended]
  animus_id: string
  circle_id: string
  started_at: timestamp
  expressions_count: number        # Stats
  artifacts_updated_count: number
```

#### artifact (extended)

Added fields to `eidos/artifact` in demiurge:

```yaml
# New fields for voice-authoring
title: string                    # Human-readable title
kind: enum [document, note, design, code, template, other]
domain: string                   # For surfacing theoria
circle_id: string
parent_artifact_id: string       # Composition hierarchy
section_path: string             # Path within parent
updated_at: timestamp
update_count: number
```

### Bonds

| Bond | From | To | Purpose |
|------|------|-----|---------|
| `authoring` | authoring-session | artifact | What's being authored |
| `informed-by` | artifact | theoria, artifact, expression | What shaped generation |
| `discusses-about` | expression | artifact | Optional provenance |

### Praxeis (10 operations)

| Praxis | Purpose |
|--------|---------|
| `enter-voice-authoring` | Create session, activate layout, open voice stream |
| `exit-voice-authoring` | End session, close streams, restore layout |
| `pause-voice-authoring` | Pause voice capture |
| `resume-voice-authoring` | Resume voice capture |
| `focus-artifact` | Shift focus to different artifact |
| `focus-sub-artifact` | Navigate into composed artifact (lazy generation) |
| `expand-context` | Add bond to inference context |
| `collapse-context` | Remove bond from context |
| `process-authoring-expression` | **Core operation** — expression → artifact update |
| `create-artifact-from-conversation` | Synthesize thread into new artifact |

### Attainment

`attainment/voice-author` is defined in voice-authoring eide and granted by `circle/kosmos` in spora.yaml.

Requires:
- `attainment/perceive` (voice capture)
- `attainment/express` (commit expressions)
- `attainment/render` (visual display)
- `attainment/manteia` (governed inference)

### Inference Context (new typos)

Created in `genesis/spora/definitions/manteia.yaml`:

```yaml
typos-def-inference-context:
  # System prompt components
  schema_source: entity ref
  domain_theoria: query spec
  role: string
  constraints: array

  # User prompt components
  input_artifacts: array
  human_expression: entity ref
  additional_context: query spec
  context_depth: number
  request: string

  # Output config
  output_schema: object
  evaluate: boolean
  criteria: array
```

Domain-specific patterns:
- `typos-inference-update-artifact` — for artifact updates
- `typos-inference-generate-from-discussion` — synthesize from thread
- `typos-inference-with-theoria` — domain-informed generation

---

## What Needs to Be Built in Chora

### 1. Layout Renderer

The voice-authoring layout has three regions:

```
┌─────────────────────────────┬─────────────────────────────┐
│                             │                             │
│     ARTIFACT PANEL          │     CONVERSATION PANEL      │
│     (left, 50%)             │     (right, 50%)            │
│                             │                             │
│     render_type:            │     render_type:            │
│     artifact-preview        │     expression-thread       │
│                             │                             │
├─────────────────────────────┴─────────────────────────────┤
│     VOICE BAR (bottom, auto height)                       │
│     render_type: accumulation-buffer                      │
└───────────────────────────────────────────────────────────┘
```

**Implementation:**

1. Create `VoiceAuthoringLayout.tsx` that arranges three regions
2. Wire up panel components:
   - `ArtifactPreview` — renders focused artifact, subscribes to updates
   - `ExpressionThread` — existing, filter to session expressions
   - `AccumulationBuffer` — existing voice bar component

### 2. Mode Activation

When `enter-voice-authoring` is called:

1. Create `authoring-session` entity
2. Call `opsis/activate-layout` with `layout/voice-authoring`
3. Open voice stream via `thyra/open-stream`
4. Subscribe UI to session entity for state updates

**Trigger options:**
- User command/gesture
- Affordance button
- Keyboard shortcut

### 3. Expression Commit Hook

When an expression is committed in voice-authoring mode:

```typescript
// In expression commit handler
if (isInVoiceAuthoringMode()) {
  const session = getActiveAuthoringSession();
  await callPraxis('voice-authoring/process-authoring-expression', {
    session_id: session.id,
    expression_id: newExpression.id
  });
}
```

This triggers the core flow:
1. Get focused artifact
2. Gather context from expanded bonds
3. Surface domain theoria
4. Call `manteia/governed-inference`
5. Update artifact
6. Bond provenance
7. Create kosmos response expression

### 4. Artifact Preview Panel

The artifact panel needs to:

1. **Display focused artifact content**
   - Subscribe to entity updates for live refresh
   - Render markdown/content appropriately

2. **Show composition structure** (if composed)
   - Display sub-artifacts as clickable sections
   - Clicking calls `focus-sub-artifact`

3. **Show expanded bonds**
   - Visualize what context is "in view"
   - Click to expand/collapse
   - Calls `expand-context` / `collapse-context`

4. **Highlight changes**
   - Flash/highlight recently updated sections
   - Show `informed-by` provenance on hover

### 5. Context Depth Navigation

The `expanded_bonds` array on the session tracks what's in context:

```typescript
// When user expands a dependency
await callPraxis('voice-authoring/expand-context', {
  session_id: session.id,
  bond_id: 'depends-on/artifact/requirements'
});

// Session.expanded_bonds now includes the bond
// Next generation will include that context
```

**UI pattern:**
- Show bond arrows/connections on artifact
- Expand/collapse icons next to each
- "In context" indicator when expanded

### 6. Kosmos Response Display

Kosmos responds in the conversation panel:

```yaml
expression:
  content: "Updated. I added a paragraph about..."
  expressed_by: kosmos
  mode: declaration
  in_reply_to: <human_expression_id>
```

If clarification needed:
```yaml
expression:
  content: "Should the introduction focus on..."
  expressed_by: kosmos
  mode: inquiry
  in_reply_to: <previous_response_id>
```

**UI consideration:**
- Style kosmos expressions differently (different avatar, color)
- Show inquiry mode as a question expecting response

### 7. Entity Subscriptions

Key entities to subscribe to for live updates:

| Entity | Update Trigger |
|--------|----------------|
| `authoring-session` | Focus change, context expand/collapse |
| Focused `artifact` | Content update from generation |
| `expression` (in circle) | New human/kosmos expressions |
| `accumulation` | Voice bar state |

---

## Data Flow

### Expression → Artifact Update

```
Human speaks
    │
    ▼
accumulation (thyra)
    │ commit
    ▼
expression (thyra)
    │ if voice-authoring mode
    ▼
process-authoring-expression (voice-authoring)
    │
    ├─► find focused artifact
    ├─► trace expanded bonds for context
    ├─► surface domain theoria
    │
    ▼
compose typos-inference-update-artifact
    │
    ▼
manteia/governed-inference
    │
    ▼
update artifact entity
    │
    ├─► bind informed-by → expression
    ├─► bind informed-by → theoria[]
    ├─► bind discusses-about (expression → artifact)
    │
    ▼
compose kosmos response expression
    │
    ▼
UI subscribes, panels update
```

### Mode Lifecycle

```
enter-voice-authoring
    │
    ├─► compose authoring-session
    ├─► activate-layout voice-authoring
    ├─► open-stream voice
    │
    ▼
[authoring loop]
    │
    ├─► expressions committed
    ├─► artifacts updated
    ├─► focus shifts
    ├─► context expands/collapses
    │
    ▼
exit-voice-authoring
    │
    ├─► update session status=ended
    ├─► close voice streams
    └─► activate-layout default
```

---

## Implementation Priority

### Phase 1: Core Mode
1. Mode activation (`enter-voice-authoring`, `exit-voice-authoring`)
2. Layout rendering (three panels)
3. Artifact preview panel (basic)
4. Expression commit hook wiring

### Phase 2: Update Flow
1. `process-authoring-expression` implementation
2. Manteia integration for artifact updates
3. Live artifact refresh
4. Kosmos response display

### Phase 3: Context Navigation
1. `expand-context` / `collapse-context`
2. Bond visualization on artifact
3. Context indicator UI
4. `focus-artifact` for switching

### Phase 4: Composition
1. `focus-sub-artifact` with lazy generation
2. Composition hierarchy display
3. Navigation breadcrumbs
4. `create-artifact-from-conversation`

---

## Testing

### MCP Testing

```bash
# Bootstrap
cargo run --bin kosmos-mcp -- --db ./kosmos.db --genesis ./genesis

# Test mode activation
voice-authoring_enter-voice-authoring

# Test with artifact
voice-authoring_enter-voice-authoring artifact_id="artifact/test-doc"

# Test focus shift
voice-authoring_focus-artifact session_id="..." artifact_id="..."

# Test expression processing
voice-authoring_process-authoring-expression session_id="..." expression_id="..."
```

### UI Testing

1. Enter voice-authoring mode
2. Verify layout shifts to three-panel
3. Speak and commit expression
4. Verify artifact updates
5. Verify kosmos response appears
6. Exit mode, verify layout restores

---

## Key Files Reference

### Kosmos (definitions)

| File | Contains |
|------|----------|
| `genesis/voice-authoring/DESIGN.md` | Full experience specification |
| `genesis/voice-authoring/manifest.yaml` | Oikos declaration |
| `genesis/voice-authoring/eide/voice-authoring.yaml` | authoring-session, attainment |
| `genesis/voice-authoring/praxeis/voice-authoring.yaml` | All 10 praxeis |
| `genesis/voice-authoring/entities/layout.yaml` | HUD layout, panels |
| `genesis/spora/definitions/manteia.yaml` | Inference context typos |
| `genesis/manteia/desmoi/manteia.yaml` | informed-by, discusses-about bonds |
| `genesis/demiurge/eide/demiurge.yaml` | Extended artifact eidos |

### Chora (to implement)

| Component | Purpose |
|-----------|---------|
| `VoiceAuthoringLayout.tsx` | Three-panel layout |
| `ArtifactPreviewPanel.tsx` | Focused artifact display |
| `useVoiceAuthoringMode.ts` | Mode state hook |
| `voiceAuthoringCommitHook.ts` | Expression commit integration |
| Praxis handlers | All 10 voice-authoring praxeis |

---

## Design Principles

1. **Discussion drives authorship** — No hand-editing. Speaking updates.

2. **Artifact is self-sufficient** — At any moment, complete. Doesn't need history.

3. **Context depth = navigation depth** — What you see is what informs AI.

4. **Kosmos participates** — Bidirectional conversation, not just commands.

5. **Mode is a way of dwelling** — Not a feature, an oikos. HUD shifts. Capabilities shift.

---

*For detailed theoria, see genesis/voice-authoring/DESIGN.md*
