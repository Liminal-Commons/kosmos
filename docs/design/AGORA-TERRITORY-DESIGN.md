# Agora Topos Design

*Two gathering modes: assembly (video + chat) and territory (spatial presence).*

**Status:** Design proposal
**Depends on:** THYRA-INTERPRETER.md, MODE-DEVELOPMENT.md, WEBRTC-TOPOS-DESIGN.md

---

## Overview

Agora is an embodied topos that provides two modes of gathering. Both modes use entity state for all participants, messages, and engagement — rendered via standard widgets, powered by WebRTC and Phaser substrates.

```
┌─────────────────────────────────────────────────────────────────────┐
│                          AGORA OIKOS                                 │
├─────────────────────────────────┬───────────────────────────────────┤
│         ASSEMBLY MODE           │         TERRITORY MODE            │
│                                 │                                   │
│  Video grid (max 9 speakers)   │  Spatial 2D map (Phaser)          │
│  Reactions: floating emojis    │  Proximity-based voice            │
│  Hand raise queue              │  Avatar movement                  │
│  Chat sidebar                  │  Chat sidebar                     │
│                                 │                                   │
│  Substrates:                   │  Substrates:                      │
│    mode/webrtc                 │    mode/phaser                     │
│                                 │    mode/webrtc                     │
│                                 │                                   │
│  speakers: 9 max (video)       │  presence: unlimited               │
│  listeners: unlimited          │  voice: proximity-based            │
└─────────────────────────────────┴───────────────────────────────────┘
```

---

## Topos Nature

Agora is embodied — it has modes on both screen and compute substrates:

| Topos Nature | Has Screen Modes? | Has Infrastructure Modes? | Example |
|-------------|-----------|---------------------|---------|
| Pure thought | No | No | demiurge |
| Infrastructure | No | Yes | dynamis |
| Presence only | Yes | No | authoring |
| **Embodied** | **Yes** | **Yes** | **agora** |

---

## Modes

| Mode | Position | Substrates | When |
|------|----------|------------|------|
| `mode/assembly` | center | `mode/webrtc` | Town-hall gathering with video grid |
| `mode/territory` | center | `mode/phaser`, `mode/webrtc` | Spatial presence with proximity voice |

Switching between assembly and territory is a mode switch — it changes substrate requirements (territory adds Phaser). The active thyra-config determines which agora mode is present.

```yaml
# Assembly mode
- eidos: mode
  id: mode/assembly
  data:
    name: assembly
    topos: agora
    render_spec_id: render-spec/assembly-view
    spatial:
      position: center
      height: fill
    requires:
      - mode/webrtc

# Territory mode
- eidos: mode
  id: mode/territory
  data:
    name: territory
    topos: agora
    render_spec_id: render-spec/territory-view
    spatial:
      position: center
      height: fill
    requires:
      - mode/phaser
      - mode/webrtc
```

---

## Topos Structure

```
genesis/agora/
├── manifest.yaml
├── eide/
│   ├── assembly.yaml       # assembly, assembly-participant, assembly-message
│   └── territory.yaml      # territory, territory-presence
├── desmoi/
│   └── agora.yaml          # has-participant, has-message, has-presence
├── modes/
│   ├── assembly.yaml
│   └── territory.yaml
├── modes/
│   ├── webrtc.yaml         # WebRTC substrate
│   └── phaser.yaml         # Phaser substrate (territory only)
├── praxeis/
│   ├── assembly.yaml       # Assembly lifecycle, moderation, engagement
│   ├── territory.yaml      # Territory lifecycle, movement, proximity
│   └── chat.yaml           # Chat (shared between modes)
├── render-specs/
│   ├── assembly-view.yaml  # Full assembly layout
│   ├── speaker-tile.yaml   # Individual speaker video tile
│   ├── assembly-controls.yaml
│   ├── territory-view.yaml # Full territory layout
│   ├── proximity-indicator.yaml
│   └── chat-panel.yaml     # Reusable chat (both modes)
└── reflexes/
    ├── proximity-voice.yaml  # Update voice levels on movement
    └── reaction-timeout.yaml # Clear reactions after 3s
```

---

## Part 1: Assembly Mode

### Entity Model

```
assembly
  ├── has-participant → assembly-participant (role: speaker|listener|moderator)
  │                       └── owns-stream → media-stream
  └── has-message → assembly-message
```

### Key Entities

**assembly** — The gathering session:
- `status`: pending / active / ended
- `max_speakers`: 9 (default)
- `reactions_enabled`, `chat_enabled`, `hand_raise_enabled`: settings
- `speaker_queue`: ordered participant IDs waiting to speak

**assembly-participant** — A person in the assembly:
- `role`: speaker / listener / moderator
- `media_state`: { video: bool, audio: bool }
- `hand_raised`: bool (listeners can raise hand)
- `active_reaction`: string (floating emoji, clears after timeout)
- `connection_state`: connecting / connected / disconnected
- `is_local`: bool

**assembly-message** — A chat message:
- `author_id`, `content`, `timestamp`
- `reactions`: map of emoji to participant IDs

### Assembly Mode (Collection Pattern)

The assembly mode uses the **collection mode pattern** -- `item_spec_id` renders each speaker tile, and the mode handles iteration over participants from `source_query`:

```yaml
# Mode definition — collection pattern handles speaker iteration
- eidos: mode
  id: mode/assembly
  data:
    name: assembly
    topos: agora
    item_spec_id: render-spec/speaker-tile
    arrangement: grid
    chrome_spec_id: render-spec/assembly-chrome
    source_query: "gather(eidos: assembly-participant, filter: role=speaker)"
    spatial:
      position: center
      height: fill
    requires:
      - mode/webrtc
```

The `chrome_spec_id` provides the surrounding structure (reactions overlay, chat sidebar):

```yaml
render-spec/assembly-chrome:
  target_eidos: assembly
  layout:
    - widget: row
      props: { class: assembly-container, fill: true }
      children:
        # Main: grid is populated by mode's item iteration
        - widget: stack
          props: { class: assembly-main, flex: 3 }
          children:
            # Reactions overlay
            - widget: stack
              props: { class: reactions-overlay }
              children:
                - widget: text
                  each: "{active_reactions}"
                  each_empty: ""
                  props:
                    content: "{emoji}"
                    class: floating-reaction

        # Sidebar: chat (rendered as a separate mode in the same thyra-config)
        - widget: stack
          when: "chat_enabled"
          props: { class: assembly-sidebar, flex: 1 }
```

### Render-Spec: Speaker Tile

```yaml
render-spec/speaker-tile:
  target_eidos: assembly-participant
  layout:
    - widget: card
      props: { class: speaker-tile, aspect_ratio: "16/9" }
      children:
        # Video (when camera on)
        - widget: video
          when: "media_state.video"
          props:
            track_id: "{video_track_id}"
            muted: "{is_local}"
            fit: cover
            mirror: "{is_local}"

        # Avatar fallback (when camera off)
        - widget: avatar
          when: "media_state.video != true"
          props:
            name: "{display_name}"
            size: xl

        # Name + status badges
        - widget: row
          props: { class: speaker-info }
          children:
            - widget: icon
              when: "media_state.audio != true"
              props: { name: mic-off, size: sm }
            - widget: badge
              when: "role == 'moderator'"
              props: { content: "mod", variant: primary }
            - widget: text
              props: { content: "{display_name}", variant: caption }

        # Floating reaction
        - widget: text
          when: "active_reaction"
          props:
            content: "{active_reaction}"
            class: floating-reaction
```

### Praxeis

```yaml
# Assembly lifecycle
agora/create-assembly      # Create assembly, join as moderator
agora/join-assembly        # Join as listener
agora/leave-assembly       # Leave and cleanup

# Moderation
agora/promote-to-speaker   # Moderator promotes listener (starts video)
agora/demote-to-listener   # Moderator demotes speaker (stops video)

# Engagement
agora/send-reaction        # Floating emoji (auto-clears via reflex)
agora/raise-hand           # Request to speak
agora/lower-hand           # Cancel request

# Media controls
agora/toggle-audio         # Mute/unmute
agora/toggle-video         # Camera on/off

# Chat (shared with territory)
agora/send-message         # Send chat message
agora/react-to-message     # Add emoji reaction to message
```

### Reflex: Reaction Timeout

```yaml
- eidos: reflex
  id: reflex/reaction-timeout
  data:
    trigger:
      event: entity_updated
      eidos: assembly-participant
      condition: "active_reaction changed && active_reaction != null"
    response:
      praxis: agora/clear-reaction
      params:
        participant_id: "$entity.id"
      delay_ms: 3000
```

---

## Part 2: Territory Mode

### Entity Model

```
territory
  ├── has-presence → territory-presence (position, movement, proximity)
  └── has-message → assembly-message (reuses chat entity)
```

### Key Entities

**territory** — The spatial map:
- `map_width`, `map_height`, `tile_size`: dimensions
- `spawn_point`: { x, y } where new presences appear
- `voice_distance`: pixel range for proximity voice (default 200)
- `voice_falloff`: linear / exponential
- `zones`: optional named areas for wayfinding

**territory-presence** — A person's spatial position:
- `position`: { x, y }
- `direction`: up / down / left / right
- `movement_state`: idle / moving
- `voice_enabled`: bool
- `proximity_peers`: computed list of { psyche_id, distance, volume }
- `avatar_sprite`: sprite sheet ID for animated avatar

### Infrastructure Modes

Territory uses two substrates:

**mode/phaser** — Phaser.js game engine for 2D rendering:
```yaml
operations:
  create_map:     # Initialize scene with map config
  destroy_map:    # Tear down scene
  add_presence:   # Add avatar sprite
  remove_presence: # Remove avatar sprite
  update_position: # Move sprite (with animation)
  sense_distances: # Compute distances between presences
  enable_input:   # Keyboard/click-to-move for local avatar
```

**mode/webrtc** — Peer-to-peer audio (shared with assembly):
```yaml
operations:
  get_user_media:    # Acquire mic
  set_remote_volume: # Adjust peer volume by distance
  toggle_track:      # Mute/unmute
```

### Render-Spec: Territory View

The territory mode uses a **singleton** render-spec (the Phaser canvas is a single entity, not a collection):

```yaml
render-spec/territory-view:
  target_eidos: territory
  layout:
    - widget: row
      props: { class: territory-container, fill: true }
      children:
        # Main: Phaser canvas
        - widget: stack
          props: { class: territory-main, flex: 3 }
          children:
            - widget: phaser-canvas
              props:
                territory_id: "{id}"
                fill: true

            # Proximity indicator overlay — iterate over nearby peers
            - widget: row
              each: "{proximity_peers}"
              each_empty: ""
              props: { class: proximity-indicator, gap: xs }
              children:
                - widget: text
                  props:
                    content: "{name}"
                    variant: caption
                - widget: badge
                  props:
                    content: "{distance}m"
                    variant: neutral

        # Sidebar: chat (rendered as a separate mode in the same thyra-config)
        - widget: stack
          when: "chat_enabled"
          props: { class: territory-sidebar, flex: 1 }

    # Bottom bar: voice controls + leave
    - widget: row
      props: { class: territory-controls, justify: center, gap: md }
      children:
        - widget: button
          props:
            variant: ghost
            on_click: agora/toggle-voice
          children:
            - widget: icon
              when: "voice_enabled"
              props: { name: mic, size: md }
            - widget: icon
              when: "voice_enabled != true"
              props: { name: mic-off, size: md }

        - widget: button
          props:
            variant: danger
            on_click: agora/leave-territory
            on_click_params:
              territory_id: "{id}"
          children:
            - widget: icon
              props: { name: log-out, size: md }
            - widget: text
              props: { content: "Leave" }
```

### Proximity Voice

Movement triggers proximity recalculation:

```
avatar moves → agora/move-to
  → Phaser updates sprite position
  → agora/update-proximity fires
  → sense_distances (Phaser computes pixel distances)
  → calculate volume per peer (linear/exponential falloff)
  → set_remote_volume (WebRTC adjusts audio levels)
  → update proximity_peers on entity
```

### Reflex: Proximity Voice Update

```yaml
- eidos: reflex
  id: reflex/proximity-voice
  data:
    trigger:
      event: entity_updated
      eidos: territory-presence
      condition: "position changed"
    response:
      praxis: agora/update-proximity
      params:
        presence_id: "$entity.id"
```

### Praxeis

```yaml
# Territory lifecycle
agora/create-territory    # Create territory, initialize Phaser scene
agora/enter-territory     # Join: create presence, add sprite, enable input
agora/leave-territory     # Leave: remove sprite, disconnect

# Movement
agora/move-to             # Update position → triggers proximity update

# Proximity voice
agora/update-proximity    # Compute distances, adjust WebRTC volumes
agora/toggle-voice        # Mute/unmute in territory
```

---

## Shared: Chat

Chat is shared between assembly and territory modes. Both bond messages to the gathering entity via `has-message`.

Chat is implemented as a **collection mode** — it iterates messages via `item_spec_id`:

```yaml
# Chat mode (collection pattern)
- eidos: mode
  id: mode/agora-chat
  data:
    name: agora-chat
    topos: agora
    item_spec_id: render-spec/chat-message
    arrangement: thread
    chrome_spec_id: render-spec/chat-chrome
    source_query: "trace(from: {gathering_id}, desmoi: has-message, sort: timestamp, order: asc)"
    spatial:
      position: sidebar
```

The chrome spec provides the input bar:

```yaml
render-spec/chat-chrome:
  layout:
    # Input bar (appears below the message list)
    - widget: row
      props: { gap: sm, padding: sm }
      children:
        - widget: input
          props:
            placeholder: "Type a message..."
            on_change: ui/update-entity-field
            on_change_params:
              field: draft_message
              value: $event.target.value

        - widget: button
          props:
            variant: primary
            on_click: agora/send-message
          children:
            - widget: icon
              props: { name: send, size: sm }
```

---

## Mode Switching

Users can switch between assembly and territory within the same gathering context. This is a mode switch — the thyra-config changes which agora mode is active:

```yaml
# Switch to assembly
ui/switch-mode → active_modes replaces mode/territory with mode/assembly
  → Phaser substrate unmanifests
  → WebRTC remains (shared substrate)
  → assembly render-spec activates

# Switch to territory
ui/switch-mode → active_modes replaces mode/assembly with mode/territory
  → Phaser substrate manifests
  → WebRTC remains (shared substrate)
  → territory render-spec activates
```

Chat history persists across mode switches (messages are entities bonded to the gathering).

---

## Design Principles

### 1. Substrates in dynamis, UI in widgets

Phaser and WebRTC are infrastructure modes. The interpreter renders standard widgets bound to entity state. The `phaser-canvas` and `video` widgets are substrate widgets — they bridge entity data to substrate APIs.

### 2. Entity state, not component state

Participant role, media state, reactions, position — all entity fields. No component-local state for domain data. The graph IS the state.

### 3. Praxis-driven actions

All user actions (join, leave, react, move, send message) are praxis calls. The executor dispatches via HTTP to kosmos-server. No direct function calls.

### 4. Reflexes for automation

Reaction timeout, proximity voice updates — handled by reflexes that trigger on entity changes. No setTimeout in components.

### 5. Chat as shared capability

Chat render-spec and praxeis are shared between assembly and territory. Different gathering modes, same chat experience.

---

## Implementation Order

### Phase 1: Assembly Core
1. Assembly eide + desmoi in genesis
2. Assembly praxeis (create, join, leave)
3. Assembly render-specs (view, speaker-tile, controls)
4. WebRTC mode integration

### Phase 2: Assembly Engagement
1. Chat praxeis + render-spec (shared)
2. Reaction praxeis + reflex (timeout)
3. Hand raise praxeis
4. Moderation praxeis (promote/demote)

### Phase 3: Territory
1. Territory eide
2. Phaser mode integration
3. Territory praxeis (enter, leave, move)
4. Territory render-specs (view, proximity indicator)
5. Proximity voice reflex + WebRTC volume control

### Phase 4: Integration
1. Mode switching between assembly and territory
2. Shared chat persistence
3. Gathering entity that wraps both modes

---

*Agora via the mode framework — two gathering modes, entity-driven state, substrates for media, standard widgets for UI.*
