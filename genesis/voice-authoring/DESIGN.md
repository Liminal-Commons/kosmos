# Voice-Authoring Design

φωνή-συγγραφή (phonē-syngraphē) — voice-writing, spoken composition

## Ontological Purpose

Voice-authoring addresses **the gap between conversation and artifact** — the distance between discussing something and having it exist as durable, structured content.

Without voice-authoring:
- Humans edit artifacts by hand (text entry, direct manipulation)
- Discussion about artifacts is separate from artifact change
- Conversation is ephemeral; artifacts are static
- The creative act is transactional (open → edit → save)

With voice-authoring:
- **Discussion drives authorship** — speaking about an artifact updates it
- **Artifacts evolve through conversation** — no hand-editing required
- **The creative act is conversational** — artifacts grow from dialogue
- **Kosmos responds** — clarifications, suggestions, actualizations
- **Provenance is natural** — what was said shapes what exists

The central insight: **the artifact at any moment is self-sufficient**. It doesn't need all prior expressions to be meaningful. The conversation shapes it; the result stands alone.

## The Experience

```
┌─────────────────────────────────────────────────────────────────────┐
│  VOICE-AUTHORING MODE                                                │
├─────────────────────────────────────────────────────────────────────┤
│                                                                      │
│  ┌─────────────────────────┐  ┌─────────────────────────────────┐   │
│  │ ARTIFACT PANEL          │  │ CONVERSATION PANEL              │   │
│  │                         │  │                                 │   │
│  │ The focused artifact    │  │ Human: "The intro should        │   │
│  │ renders here, updating  │  │   mention the key insight..."   │   │
│  │ live as discussion      │  │                                 │   │
│  │ shapes it.              │  │ Kosmos: "Updated. I added a     │   │
│  │                         │  │   paragraph about..."           │   │
│  │ [Sub-artifacts can be   │  │                                 │   │
│  │  focused by clicking]   │  │ Human: "Actually, make it       │   │
│  │                         │  │   more concise."                │   │
│  │                         │  │                                 │   │
│  │                         │  │ Kosmos: "Done. Reduced to       │   │
│  │                         │  │   two sentences."               │   │
│  └─────────────────────────┘  └─────────────────────────────────┘   │
│                                                                      │
│  ┌───────────────────────────────────────────────────────────────┐  │
│  │ VOICE BAR                                                     │  │
│  │ [🎤 listening] "I think the section about..."                 │  │
│  │                                              [Send] [Abandon] │  │
│  └───────────────────────────────────────────────────────────────┘  │
│                                                                      │
└─────────────────────────────────────────────────────────────────────┘
```

**The flow:**

1. Human activates voice-authoring mode (enters the oikos)
2. Human focuses on an artifact (or creates new one)
3. Human speaks — voice captured, transcribed, clarified
4. Human commits (send) — expression created
5. Expression targets focused artifact (implicit from mode)
6. Kosmos processes: gathers context, composes inference, updates artifact
7. Artifact panel re-renders with changes
8. Kosmos responds in conversation (what changed, clarifications needed)
9. Repeat

## Circle Context

### Self Circle

A solitary dweller uses voice-authoring to:
- Author personal documents through spoken thought
- Iterate on ideas without keyboard friction
- Let artifacts emerge from thinking aloud
- Review and refine through continued conversation

Self-circle voice-authoring is thinking made visible.

### Peer Circle

Collaborators use voice-authoring to:
- Co-author documents through shared conversation
- Discuss and simultaneously update shared artifacts
- See each other's contributions in the conversation panel
- Navigate artifact together (shared focus)

Peer-circle voice-authoring is collaborative creation.

### Commons Circle

A commons uses voice-authoring to:
- Define voice-authoring layouts and configurations
- Provide domain-specific inference patterns
- Configure transcription and clarification for accessibility
- Analyze authoring patterns across the community

Commons provide voice-authoring infrastructure.

## Core Entities (Eide)

Voice-authoring primarily uses entities from other oikoi. It introduces one new eidos and relies on:

### authoring-session (new)

Active voice-authoring context — tracks mode state.

**Fields:**
- `focused_artifact_id` — the artifact currently being authored
- `expanded_bonds` — which bonds are "in view" for context
- `context_depth` — how deep context gathering goes (default 1)
- `inference_pattern_id` — typos for generating updates (default: typos-inference-update-artifact)
- `status` — active, paused, ended
- `started_at`, `ended_at` — timestamps
- `animus_id` — who is authoring

**Lifecycle:**
- Arise: enter-voice-authoring creates session
- Change: focus shifts, bonds expand/collapse
- Depart: exit-voice-authoring ends session

### From thyra

- **stream** — voice input (kind: voice, direction: inward)
- **accumulation** — voice buffer awaiting commit
- **expression** — committed human contribution
- **voice-pipeline-config** — transcription/clarification settings

### From opsis

- **layout** — HUD structure for voice-authoring
- **panel** — artifact panel, conversation panel, voice bar
- **workspace** — open artifacts, focus state

### From demiurge

- **artifact** — the thing being authored
- **typos** — inference patterns for updates

### From manteia

- **governed-envelope** — generation result with quality assessment

### From nous

- **theoria** — domain knowledge informing generation

## Bonds (Desmoi)

### authoring (new)

Animus is authoring an artifact in a session.

- **From:** authoring-session
- **To:** artifact
- **Cardinality:** one-to-one (per session)
- **Traversal:** What is being authored? Who is authoring this?

### Uses from manteia

- **informed-by** — generation was informed by context
- **discusses-about** — expression targets artifact (optional)

### Uses from demiurge

- **composed-from** — artifact comes from typos
- **depends-on** — artifact depends on other artifacts

## Operations (Praxeis)

### Mode Management

#### enter-voice-authoring

Enter voice-authoring mode — creates authoring-session.

- **When:** Human wants to author via voice
- **Requires:** voice-author attainment
- **Provides:** authoring-session, activated layout, voice stream

```yaml
steps:
  - step: compose
    typos_id: typos-def-authoring-session
    inputs:
      animus_id: "$_animus.id"
      status: active
    bind_to: session
  - step: call
    praxis: opsis/activate-layout
    params:
      layout_id: layout/voice-authoring
  - step: call
    praxis: thyra/open-stream
    params:
      kind: voice
      direction: inward
  - step: return
    value: "$session"
```

#### exit-voice-authoring

Exit voice-authoring mode — ends session, closes streams.

- **When:** Human is done authoring
- **Requires:** voice-author attainment
- **Provides:** ended session, restored layout

#### pause-voice-authoring / resume-voice-authoring

Temporarily suspend/resume voice capture without exiting mode.

### Focus Management

#### focus-artifact

Shift authoring focus to an artifact.

- **When:** Human clicks artifact or speaks "focus on X"
- **Requires:** voice-author attainment
- **Provides:** updated session, re-rendered artifact panel

#### focus-sub-artifact

Navigate into a composed artifact's child.

- **When:** Human clicks a section or speaks "zoom into X"
- **Requires:** voice-author attainment
- **Provides:** sub-artifact becomes focused (may generate on-demand)

#### expand-context / collapse-context

Expand or collapse a bond in the artifact view.

- **When:** Human clicks expand or speaks "include the requirements"
- **Requires:** voice-author attainment
- **Provides:** updated expanded_bonds, affects inference context

### Authoring Operations

#### process-authoring-expression

Process a committed expression in voice-authoring mode.

- **When:** Human commits (sends) an expression
- **Requires:** voice-author attainment
- **Provides:** updated artifact, kosmos response

This is the core operation:

```yaml
steps:
  # Get current session and context
  - step: find
    entity_id: "$session_id"
    bind_to: session

  - step: find
    entity_id: "$session.data.focused_artifact_id"
    bind_to: artifact

  # Compose inference context
  - step: compose
    typos_id: typos-inference-update-artifact
    inputs:
      input_artifacts:
        - "$artifact.id"
      human_expression: "$expression.id"
      context_depth: "$session.data.context_depth"
      additional_context:
        trace:
          from: "$artifact.id"
          desmoi: "$session.data.expanded_bonds"
          depth: "$session.data.context_depth"
    bind_to: context

  # Gather theoria for domain
  - step: surface
    query: "$artifact.data.domain"
    eidos: theoria
    limit: 5
    bind_to: theoria

  # Generate update
  - step: call
    praxis: manteia/governed-inference
    params:
      prompt: "$context.data.request"
      system_prompt: |
        {{ $context.data.role }}

        ## Domain Knowledge
        {{ for t in $theoria }}
        - {{ $t.data.insight }}
        {{ end }}

        ## Constraints
        {{ for c in $context.data.constraints }}
        - {{ $c }}
        {{ end }}
      output_schema:
        type: object
        properties:
          updated_content:
            type: string
          changes_summary:
            type: string
          clarification_needed:
            type: string
    bind_to: result

  # Update artifact
  - step: update
    entity_id: "$artifact.id"
    data:
      content: "$result.content.updated_content"
    bind_to: updated_artifact

  # Bond provenance
  - step: bind
    from: "$updated_artifact.id"
    to: "$expression.id"
    desmos: informed-by

  - step: bind
    from: "$updated_artifact.id"
    to: "$theoria[*].id"
    desmos: informed-by

  # Create kosmos response
  - step: compose
    typos_id: typos-def-expression
    inputs:
      content: "$result.content.changes_summary"
      expressed_by: "kosmos"
      circle_id: "$_circle.id"
      source_kind: compose
      mode: declaration
      in_reply_to: "$expression.id"
    bind_to: response

  - step: return
    value:
      artifact: "$updated_artifact"
      response: "$response"
      clarification_needed: "$result.content.clarification_needed"
```

#### create-artifact-from-conversation

Generate a new artifact from a discussion thread.

- **When:** Human speaks "make this into a document" or similar
- **Requires:** voice-author attainment
- **Provides:** new artifact composed from discussion

### Rendering Operations

Uses opsis praxeis:
- gather-render-intent
- reconcile-region
- emit-render

## Attainments

### attainment/voice-author

Voice-authoring capability — entering mode and authoring via voice.

- **Grants:** enter-voice-authoring, exit-voice-authoring, pause-voice-authoring, resume-voice-authoring, focus-artifact, focus-sub-artifact, expand-context, collapse-context, process-authoring-expression, create-artifact-from-conversation
- **Scope:** circle (authoring happens in a circle context)
- **Rationale:** Voice-authoring modifies artifacts; requires circle membership

### Requires from thyra

- **attainment/perceive** — voice capture
- **attainment/express** — committing expressions

### Requires from opsis

- **attainment/render** — visual display

### Requires from manteia

- **attainment/manteia** — governed inference

## Embodiment

### Completeness Status

| Level | Status |
|-------|--------|
| Defined | This document |
| Loaded | Pending manifest.yaml |
| Projected | Pending praxeis |
| Embodied | Pending body-schema contribution |
| Surfaced | Pending reconciler |
| Afforded | Pending thyra panels |

### Body-Schema Contribution

When sense-body gathers voice-authoring state:

```yaml
voice_authoring:
  active: true
  focused_artifact: "artifact/my-design-doc"
  context_depth: 1
  expanded_bonds: ["depends-on/artifact/requirements"]
  session_duration_minutes: 23
  expressions_this_session: 7
  artifacts_updated: 1
```

This reveals the authoring context and activity.

### Reconciler

A voice-authoring reconciler would surface:

- **Uncommitted accumulation** — "You have unsent voice content"
- **Long pause** — "Still authoring? (23 minutes since last expression)"
- **Context suggestion** — "The artifact depends on 'requirements' — expand to include?"
- **Clarification pending** — "Kosmos asked a question in the conversation"

## Layout

### layout/voice-authoring

The HUD structure for voice-authoring mode.

```yaml
- eidos: layout
  id: layout/voice-authoring
  data:
    name: voice-authoring
    description: "HUD layout for voice-authoring mode"
    regions:
      - kind: artifact
        position: left
        width: 50%
        config:
          render_type: artifact-preview
          source: focused_artifact
      - kind: conversation
        position: right
        width: 50%
        config:
          render_type: expression-thread
          source: session_expressions
      - kind: voice-bar
        position: bottom
        height: auto
        config:
          render_type: accumulation-buffer
          source: active_accumulation
```

## Theoria

### T80: Discussion drives authorship

The artifact doesn't need hand-editing. Speaking about it changes it. This inverts the traditional relationship: instead of artifact-then-discussion, it's discussion-as-artifact.

### T81: The artifact is self-sufficient

At any moment, the artifact stands alone. It doesn't need all prior expressions to be meaningful. The history shapes it; the result is complete. This frees us from mandatory `discusses-about` bonds.

### T82: Context depth is navigation depth

What you've expanded in the view is what informs generation. This makes the UX intuitive: see it, and the AI knows about it. Collapse it, and it's out of context.

### T83: Kosmos participates in conversation

Kosmos doesn't just execute commands. It responds — summarizing changes, asking clarifications, suggesting next steps. The conversation is bidirectional.

### T84: Voice-authoring is a way of dwelling

It's not a feature; it's an oikos. A mode, a game mode, a way of being in the kosmos. The layout shifts. The capabilities shift. The creative act shifts.

## Compound Leverage

### amplifies thyra

Uses thyra's voice pipeline (streams, accumulation, expression). Voice-authoring is a specific use of thyra's perception/expression capabilities.

### amplifies opsis

Uses opsis layouts, panels, rendering. The voice-authoring HUD is an opsis configuration.

### amplifies manteia

Uses manteia's governed inference with typos-inference-update-artifact. The artifact update is schema-constrained generation.

### amplifies nous

Surfaces theoria as domain knowledge for generation. Understanding crystallizes in the artifacts.

### amplifies demiurge

Artifacts are composed entities. Updates follow composition patterns. Provenance through informed-by.

### amplifies psyche

Authoring session tracks attention (focused artifact). Intention (to author). The experiential layer.

## Future Extensions

### Multi-artifact authoring

Focus on multiple artifacts simultaneously. Expressions can target any focused artifact based on context.

### Collaborative voice-authoring

Multiple humans in peer circle, co-authoring same artifact. Presence shows who's speaking. Conflict resolution for simultaneous updates.

### Voice commands

Beyond authoring content: "Create a new section", "Move this up", "Delete the last paragraph". Structural commands via voice.

### Audio annotation

Attach audio clips to artifact sections. The voice itself becomes part of the artifact, not just text.

### Transcription modes

Switch between clarified (clean prose) and verbatim (exact words) based on artifact type. Meeting notes might want verbatim; documents want clarified.

---

*Composed in service of the kosmogonia.*
*Speak, and the artifact becomes. The conversation is the creation.*
