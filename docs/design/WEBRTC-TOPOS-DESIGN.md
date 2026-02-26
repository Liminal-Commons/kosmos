# WebRTC Topos Design

*Peer-to-peer video calls via Thyra architecture — substrates in dynamis, UI in widgets*

**Status:** Design proposal
**Depends on:** THYRA-TOPOS.md, THYRA-INTERPRETER.md, VOICE-TOPOS-DESIGN.md
**Outcome:** Video calls without special components — standard render-specs, praxis actions

---

## Overview

Video calls follow the same substrate pattern as voice:

```
call intent → session entity → WebRTC substrate → media streams
      ↑            ↑                 ↑                ↑
   praxis      graph state       dynamis          browser
   (create)    (reactive)     (signaling)      (media display)
```

**Key insight:** WebRTC signaling and connection management live in dynamis. The UI uses standard widgets bound to session/participant entity state. Video elements are a widget type (not special components).

---

## Entity Model

### Core Entities

```
┌─────────────────────────────────────────────────────────────┐
│                         call-session                        │
│  status: pending|connecting|active|ended                    │
│  mode: direct|mesh                                          │
│  max_participants: number                                   │
└─────────────────────────────────────────────────────────────┘
                              │
                              │ bonds: has-participant
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                     call-participant                        │
│  psyche_id: string                                          │
│  role: host|participant                                     │
│  connection_state: new|connecting|connected|disconnected    │
│  media_state: { video: bool, audio: bool, screen: bool }    │
│  stream_id: string (local handle)                           │
└─────────────────────────────────────────────────────────────┘
                              │
                              │ bonds: owns-stream
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                      media-stream                           │
│  kind: camera|screen|audio                                  │
│  direction: local|remote                                    │
│  status: pending|active|paused|ended                        │
│  track_id: string (WebRTC track ID)                         │
└─────────────────────────────────────────────────────────────┘
```

---

## Topos Structure

```
genesis/agora/
├── manifest.yaml
├── DESIGN.md
├── eide/
│   └── call.yaml              # call-session, call-participant, media-stream
├── desmoi/
│   └── call.yaml              # has-participant, owns-stream
├── praxeis/
│   └── call.yaml              # call lifecycle operations
├── modes/
│   └── webrtc.yaml            # substrate bridging
└── render-specs/
    ├── call-session.yaml      # main call view
    ├── participant-tile.yaml  # individual participant
    └── call-controls.yaml     # mute/video/leave buttons
```

---

## Eide

```yaml
# genesis/agora/eide/call.yaml

entities:
  # ─────────────────────────────────────────────────────────────
  # CALL SESSION
  # ─────────────────────────────────────────────────────────────

  - eidos: eidos
    id: eidos/call-session
    data:
      name: call-session
      description: |
        A peer-to-peer video call session. Supports 2-5 participants
        in mesh topology. Session entity tracks overall state; participant
        entities track individual connections.
      fields:
        name:
          type: string
          required: false
          description: "Optional call name/title"

        status:
          type: enum
          values: [pending, connecting, active, ended, failed]
          required: true
          default: pending
          description: "Session lifecycle state"

        mode:
          type: enum
          values: [direct, mesh]
          required: true
          default: direct
          description: "direct = 1:1, mesh = multi-party"

        max_participants:
          type: number
          required: true
          default: 5
          description: "Maximum allowed participants"

        started_at:
          type: timestamp
          required: false

        ended_at:
          type: timestamp
          required: false

        # Signaling
        offer_sdp:
          type: string
          required: false
          description: "WebRTC offer SDP for incoming participants"

        ice_servers:
          type: array
          required: false
          description: "STUN/TURN server configuration"

      actuality:
        mode: webrtc

  # ─────────────────────────────────────────────────────────────
  # CALL PARTICIPANT
  # ─────────────────────────────────────────────────────────────

  - eidos: eidos
    id: eidos/call-participant
    data:
      name: call-participant
      description: |
        A participant in a call session. Tracks connection state,
        media state, and WebRTC peer connection handle.
      fields:
        psyche_id:
          type: string
          required: true
          description: "The psyche (user) this participant represents"

        display_name:
          type: string
          required: false
          description: "Display name in call UI"

        role:
          type: enum
          values: [host, participant]
          required: true
          default: participant

        connection_state:
          type: enum
          values: [new, connecting, connected, disconnected, failed]
          required: true
          default: new
          description: "WebRTC peer connection state"

        media_state:
          type: object
          required: true
          default: { video: true, audio: true, screen: false }
          description: "Current media toggle states"

        is_local:
          type: boolean
          required: true
          default: false
          description: "True for the local participant"

        # Substrate handles
        peer_connection_id:
          type: string
          required: false
          description: "RTCPeerConnection handle in substrate"

        video_track_id:
          type: string
          required: false
          description: "Active video track ID"

        audio_track_id:
          type: string
          required: false
          description: "Active audio track ID"

        joined_at:
          type: timestamp
          required: false

        left_at:
          type: timestamp
          required: false

  # ─────────────────────────────────────────────────────────────
  # MEDIA STREAM
  # ─────────────────────────────────────────────────────────────

  - eidos: eidos
    id: eidos/media-stream
    data:
      name: media-stream
      description: |
        A media stream (video or audio) in a call. Tracks the WebRTC
        MediaStreamTrack state for rendering.
      fields:
        kind:
          type: enum
          values: [camera, screen, audio]
          required: true

        direction:
          type: enum
          values: [local, remote]
          required: true
          description: "local = from this device, remote = from peer"

        status:
          type: enum
          values: [pending, active, paused, ended]
          required: true
          default: pending

        track_id:
          type: string
          required: false
          description: "WebRTC MediaStreamTrack ID"

        participant_id:
          type: string
          required: true
          description: "Participant who owns this stream"

        width:
          type: number
          required: false
          description: "Video width (if video)"

        height:
          type: number
          required: false
          description: "Video height (if video)"
```

---

## Desmoi

```yaml
# genesis/agora/desmoi/call.yaml

entities:
  - eidos: desmos
    id: desmos/has-participant
    data:
      name: has-participant
      description: "Links call-session to its participants"
      from_eidos: call-session
      to_eidos: call-participant
      cardinality: one-to-many

  - eidos: desmos
    id: desmos/owns-stream
    data:
      name: owns-stream
      description: "Links participant to their media streams"
      from_eidos: call-participant
      to_eidos: media-stream
      cardinality: one-to-many
```

---

## Mode (Dynamis Integration)

```yaml
# genesis/agora/modes/webrtc.yaml

- eidos: mode
  id: mode/webrtc
  data:
    name: webrtc
    description: |
      WebRTC substrate — peer connection management, ICE negotiation,
      media track handling. Dynamis manages the signaling; browser
      handles the actual media.

    substrate: webrtc
    requires_dynamis: [webrtc-signaling]

    operations:
      # ─────────────────────────────────────────────────────────
      # SESSION OPERATIONS
      # ─────────────────────────────────────────────────────────

      create_session:
        description: "Initialize WebRTC session, gather ICE candidates"
        handler: webrtc::create_session
        params:
          session_id: { type: string }
          ice_servers: { type: array }
        returns:
          offer_sdp: string
          local_candidates: array

      join_session:
        description: "Join existing session with offer SDP"
        handler: webrtc::join_session
        params:
          session_id: { type: string }
          offer_sdp: { type: string }
          participant_id: { type: string }
        returns:
          answer_sdp: string
          peer_connection_id: string

      close_session:
        description: "Close session and all peer connections"
        handler: webrtc::close_session
        params:
          session_id: { type: string }

      # ─────────────────────────────────────────────────────────
      # PEER CONNECTION OPERATIONS
      # ─────────────────────────────────────────────────────────

      add_ice_candidate:
        description: "Add ICE candidate to peer connection"
        handler: webrtc::add_ice_candidate
        params:
          peer_connection_id: { type: string }
          candidate: { type: object }

      sense_connection:
        description: "Query peer connection state"
        handler: webrtc::sense_connection
        params:
          peer_connection_id: { type: string }
        returns:
          connection_state: enum
          ice_state: enum
          stats: object

      # ─────────────────────────────────────────────────────────
      # MEDIA OPERATIONS
      # ─────────────────────────────────────────────────────────

      get_user_media:
        description: "Request camera/mic access"
        handler: webrtc::get_user_media
        params:
          video: { type: boolean, default: true }
          audio: { type: boolean, default: true }
          video_constraints: { type: object, required: false }
        returns:
          stream_id: string
          video_track_id: string
          audio_track_id: string

      get_display_media:
        description: "Request screen share"
        handler: webrtc::get_display_media
        params:
          video: { type: boolean, default: true }
          audio: { type: boolean, default: false }
        returns:
          stream_id: string
          video_track_id: string

      toggle_track:
        description: "Enable/disable a media track"
        handler: webrtc::toggle_track
        params:
          track_id: { type: string }
          enabled: { type: boolean }

      replace_track:
        description: "Replace track (e.g., switch camera)"
        handler: webrtc::replace_track
        params:
          peer_connection_id: { type: string }
          old_track_id: { type: string }
          new_track_id: { type: string }
```

---

## Praxeis (Call Operations)

```yaml
# genesis/agora/praxeis/call.yaml

entities:
  # ─────────────────────────────────────────────────────────────
  # SESSION LIFECYCLE
  # ─────────────────────────────────────────────────────────────

  - eidos: praxis
    id: praxis/agora/create-call
    data:
      name: create-call
      description: "Create a new call session and join as host"
      topos: agora
      params:
        name: { type: string, required: false }
        max_participants: { type: number, default: 5 }
      steps:
        # Create session entity
        - step: compose
          var: session
          typos: entity/call-session
          inputs:
            name: $name
            status: pending
            mode: direct
            max_participants: $max_participants
            ice_servers:
              - urls: "stun:stun.l.google.com:19302"

        # Initialize WebRTC session
        - step: actualize
          mode: webrtc
          operation: create_session
          params:
            session_id: $session.id
            ice_servers: $session.data.ice_servers
          var: webrtc_result

        # Update session with offer
        - step: mutate
          entity: $session.id
          set:
            offer_sdp: $webrtc_result.offer_sdp
            status: connecting

        # Get local media
        - step: actualize
          mode: webrtc
          operation: get_user_media
          params:
            video: true
            audio: true
          var: media_result

        # Create local participant
        - step: compose
          var: local_participant
          typos: entity/call-participant
          inputs:
            psyche_id: $context.psyche_id
            role: host
            connection_state: connected
            is_local: true
            video_track_id: $media_result.video_track_id
            audio_track_id: $media_result.audio_track_id
            joined_at: $now

        # Bond participant to session
        - step: bond
          from: $session.id
          to: $local_participant.id
          desmos: has-participant

        # Update session to active (host is connected)
        - step: mutate
          entity: $session.id
          set:
            status: active
            started_at: $now

        - step: return
          value:
            session_id: $session.id
            participant_id: $local_participant.id

  - eidos: praxis
    id: praxis/agora/join-call
    data:
      name: join-call
      description: "Join an existing call session"
      topos: agora
      params:
        session_id: { type: string, required: true }
      steps:
        # Get session
        - step: query
          var: session
          find: $session_id

        # Validate session is joinable
        - step: assert
          condition: $session.data.status == "active"
          error: "Call is not active"

        # Count current participants
        - step: traverse
          var: participants
          root: $session_id
          desmoi: [has-participant]
          direction: outward

        - step: assert
          condition: $participants.length < $session.data.max_participants
          error: "Call is full"

        # Get local media first
        - step: actualize
          mode: webrtc
          operation: get_user_media
          params:
            video: true
            audio: true
          var: media_result

        # Join via WebRTC
        - step: actualize
          mode: webrtc
          operation: join_session
          params:
            session_id: $session_id
            offer_sdp: $session.data.offer_sdp
            participant_id: $context.psyche_id
          var: join_result

        # Create participant entity
        - step: compose
          var: participant
          typos: entity/call-participant
          inputs:
            psyche_id: $context.psyche_id
            role: participant
            connection_state: connecting
            is_local: true
            peer_connection_id: $join_result.peer_connection_id
            video_track_id: $media_result.video_track_id
            audio_track_id: $media_result.audio_track_id
            joined_at: $now

        # Bond to session
        - step: bond
          from: $session_id
          to: $participant.id
          desmos: has-participant

        - step: return
          value:
            session_id: $session_id
            participant_id: $participant.id

  - eidos: praxis
    id: praxis/agora/leave-call
    data:
      name: leave-call
      description: "Leave a call session"
      topos: agora
      params:
        session_id: { type: string, required: true }
        participant_id: { type: string, required: true }
      steps:
        - step: query
          var: participant
          find: $participant_id

        # Close peer connection if exists
        - step: when
          condition: $participant.data.peer_connection_id
          steps:
            - step: actualize
              mode: webrtc
              operation: sense_connection  # Just disconnect, session continues
              params:
                peer_connection_id: $participant.data.peer_connection_id

        # Update participant
        - step: mutate
          entity: $participant_id
          set:
            connection_state: disconnected
            left_at: $now

        # Check if session should end (host left or no participants)
        - step: query
          var: session
          find: $session_id

        - step: traverse
          var: active_participants
          root: $session_id
          desmoi: [has-participant]
          filter:
            connection_state: connected

        - step: when
          condition: $active_participants.length == 0
          steps:
            - step: call
              praxis: agora/end-call
              params:
                session_id: $session_id

        - step: return
          value:
            left: true

  - eidos: praxis
    id: praxis/agora/end-call
    data:
      name: end-call
      description: "End the call session for all participants"
      topos: agora
      params:
        session_id: { type: string, required: true }
      steps:
        - step: actualize
          mode: webrtc
          operation: close_session
          params:
            session_id: $session_id

        - step: mutate
          entity: $session_id
          set:
            status: ended
            ended_at: $now

        # Update all participants
        - step: traverse
          var: participants
          root: $session_id
          desmoi: [has-participant]

        - step: each
          items: $participants
          as: p
          steps:
            - step: mutate
              entity: $p.id
              set:
                connection_state: disconnected
                left_at: $now

        - step: return
          value:
            ended: true

  # ─────────────────────────────────────────────────────────────
  # MEDIA CONTROLS
  # ─────────────────────────────────────────────────────────────

  - eidos: praxis
    id: praxis/agora/toggle-video
    data:
      name: toggle-video
      description: "Toggle video on/off for local participant"
      topos: agora
      params:
        participant_id: { type: string, required: true }
      steps:
        - step: query
          var: participant
          find: $participant_id

        - step: set
          var: new_state
          value: !$participant.data.media_state.video

        - step: actualize
          mode: webrtc
          operation: toggle_track
          params:
            track_id: $participant.data.video_track_id
            enabled: $new_state

        - step: mutate
          entity: $participant_id
          set:
            "media_state.video": $new_state

        - step: return
          value:
            video_enabled: $new_state

  - eidos: praxis
    id: praxis/agora/toggle-audio
    data:
      name: toggle-audio
      description: "Toggle audio on/off for local participant"
      topos: agora
      params:
        participant_id: { type: string, required: true }
      steps:
        - step: query
          var: participant
          find: $participant_id

        - step: set
          var: new_state
          value: !$participant.data.media_state.audio

        - step: actualize
          mode: webrtc
          operation: toggle_track
          params:
            track_id: $participant.data.audio_track_id
            enabled: $new_state

        - step: mutate
          entity: $participant_id
          set:
            "media_state.audio": $new_state

        - step: return
          value:
            audio_enabled: $new_state

  - eidos: praxis
    id: praxis/agora/share-screen
    data:
      name: share-screen
      description: "Start screen sharing"
      topos: agora
      params:
        participant_id: { type: string, required: true }
      steps:
        - step: query
          var: participant
          find: $participant_id

        - step: actualize
          mode: webrtc
          operation: get_display_media
          params:
            video: true
          var: screen_result

        # Replace camera track with screen track
        - step: actualize
          mode: webrtc
          operation: replace_track
          params:
            peer_connection_id: $participant.data.peer_connection_id
            old_track_id: $participant.data.video_track_id
            new_track_id: $screen_result.video_track_id

        - step: mutate
          entity: $participant_id
          set:
            "media_state.screen": true
            video_track_id: $screen_result.video_track_id

        - step: return
          value:
            sharing: true
```

---

## Render-Specs (Standard Widgets)

### Call Session Mode (Collection Pattern)

The call session uses the **collection mode pattern** -- the mode iterates participants and renders each via `item_spec_id`:

```yaml
# genesis/agora/modes/active-call.yaml

- eidos: mode
  id: mode/active-call
  data:
    name: active-call
    topos: agora
    item_spec_id: render-spec/participant-tile
    arrangement: grid
    chrome_spec_id: render-spec/call-chrome
    source_query: "trace(from: {session_id}, desmoi: has-participant, filter: connection_state=connected)"
    spatial:
      position: center
      height: fill
    requires:
      - mode/webrtc
```

The `chrome_spec_id` provides the surrounding call controls:

```yaml
# genesis/agora/render-specs/call-chrome.yaml

- eidos: render-spec
  id: render-spec/call-chrome
  data:
    target_eidos: call-session
    variant: call-chrome
    description: "Call chrome — controls bar beneath participant grid"

    layout:
      # Controls bar (participant grid is rendered by mode's collection iteration above)
      - widget: row
        props:
          class: "call-controls"
          justify: center
          gap: md
          padding: md
        children:
          # Audio toggle
          - widget: button
            props:
              variant: secondary
              size: lg
              on_click: "agora/toggle-audio"
              on_click_params:
                participant_id: "{local_participant_id}"
            children:
              - widget: icon
                when: "media_state.audio"
                props: { name: mic, size: md }
              - widget: icon
                when: "media_state.audio != true"
                props: { name: mic-off, size: md }

          # Video toggle
          - widget: button
            props:
              variant: secondary
              size: lg
              on_click: "agora/toggle-video"
              on_click_params:
                participant_id: "{local_participant_id}"
            children:
              - widget: icon
                when: "media_state.video"
                props: { name: video, size: md }
              - widget: icon
                when: "media_state.video != true"
                props: { name: video-off, size: md }

          # Leave call
          - widget: button
            props:
              variant: danger
              size: lg
              on_click: "ui/confirm"
              on_click_params:
                title: "Leave Call"
                message: "Are you sure you want to leave?"
                on_confirm: "agora/leave-call"
                on_confirm_params:
                  session_id: "{session_id}"
                  participant_id: "{local_participant_id}"
```

### Participant Tile

```yaml
# genesis/agora/render-specs/participant-tile.yaml

- eidos: render-spec
  id: render-spec/participant-tile
  data:
    target_eidos: call-participant
    variant: tile
    description: "Individual participant video tile"

    layout:
      - widget: card
        props:
          class: "participant-tile"
          variant: flat
          aspect_ratio: "16/9"
          position: relative
        children:
          # Video element
          - widget: video
            props:
              track_id: "{video_track_id}"
              muted: "{is_local}"  # Mute self to avoid feedback
              class: "participant-video"
              fit: cover
              mirror: "{is_local}"  # Mirror self-view

          # Overlay for muted/no video states
          - widget: stack
            when: "!media_state.video"
            props:
              class: "video-placeholder"
              align: center
              justify: center
            children:
              - widget: avatar
                props:
                  name: "{display_name}"
                  size: xl

          # Name badge
          - widget: row
            props:
              class: "participant-info"
              position: absolute
              bottom: sm
              left: sm
              gap: xs
              align: center
            children:
              - widget: badge
                when: "!media_state.audio"
                props:
                  content: "🔇"
                  variant: muted

              - widget: text
                props:
                  content: "{display_name}"
                  variant: caption
                  class: "participant-name"

          # Connection state indicator
          - widget: badge
            when: "connection_state == 'connecting'"
            props:
              content: "Connecting..."
              variant: info
              position: absolute
              top: sm
              right: sm
```

*Call controls are defined in the `chrome_spec_id` render-spec above, co-located with the mode definition.*

---

## Video Widget

The video widget is a new standard widget type for media display:

```yaml
# genesis/thyra/stoicheia/widgets.yaml (addition)

- eidos: stoicheion/widget
  id: stoicheion/widget/video
  data:
    name: video
    description: |
      Video display widget — renders a WebRTC MediaStreamTrack.
      Used for video calls, screen shares, and video playback.
    props:
      track_id:
        type: string
        required: true
        description: "WebRTC track ID to display"
      muted:
        type: boolean
        default: false
      autoplay:
        type: boolean
        default: true
      fit:
        type: enum
        values: [contain, cover, fill]
        default: contain
      mirror:
        type: boolean
        default: false
        description: "Mirror horizontally (for self-view)"
```

Implementation hooks into WebRTC substrate:

```typescript
// lib/widgets/video.tsx

export function VideoWidget(props: VideoWidgetProps) {
  let videoRef: HTMLVideoElement | undefined;

  createEffect(() => {
    const trackId = props.track_id;
    if (!trackId || !videoRef) return;

    // Get MediaStreamTrack from substrate
    const track = webrtcSubstrate.getTrack(trackId);
    if (!track) return;

    // Create MediaStream and attach to video element
    const stream = new MediaStream([track]);
    videoRef.srcObject = stream;
  });

  return (
    <video
      ref={videoRef}
      autoplay={props.autoplay ?? true}
      muted={props.muted ?? false}
      class={props.class}
      style={{
        "object-fit": props.fit ?? "contain",
        transform: props.mirror ? "scaleX(-1)" : undefined,
      }}
    />
  );
}
```

---

## WebRTC Substrate (Dynamis)

The WebRTC substrate manages browser APIs:

```rust
// crates/kosmos/src/substrates/webrtc.rs (pseudocode)

pub struct WebRtcSubstrate {
    sessions: HashMap<String, SessionState>,
    peer_connections: HashMap<String, RTCPeerConnection>,
    tracks: HashMap<String, MediaStreamTrack>,
}

impl WebRtcSubstrate {
    pub async fn create_session(&mut self, session_id: &str, ice_servers: &[IceServer]) -> Result<CreateSessionResult> {
        // Create RTCPeerConnection
        let config = RTCConfiguration { ice_servers: ice_servers.to_vec() };
        let pc = RTCPeerConnection::new(&config)?;

        // Create offer
        let offer = pc.create_offer().await?;
        pc.set_local_description(&offer).await?;

        // Gather ICE candidates
        let candidates = self.gather_candidates(&pc).await?;

        self.sessions.insert(session_id.to_string(), SessionState { host_pc: pc.clone() });

        Ok(CreateSessionResult {
            offer_sdp: offer.sdp,
            local_candidates: candidates,
        })
    }

    pub async fn join_session(&mut self, session_id: &str, offer_sdp: &str, participant_id: &str) -> Result<JoinSessionResult> {
        let config = self.get_session_config(session_id)?;
        let pc = RTCPeerConnection::new(&config)?;

        // Set remote description (offer)
        let offer = RTCSessionDescription::offer(offer_sdp);
        pc.set_remote_description(&offer).await?;

        // Create answer
        let answer = pc.create_answer().await?;
        pc.set_local_description(&answer).await?;

        let pc_id = format!("{}-{}", session_id, participant_id);
        self.peer_connections.insert(pc_id.clone(), pc);

        Ok(JoinSessionResult {
            answer_sdp: answer.sdp,
            peer_connection_id: pc_id,
        })
    }

    pub async fn get_user_media(&mut self, video: bool, audio: bool) -> Result<MediaResult> {
        let constraints = MediaStreamConstraints { video, audio };
        let stream = navigator::media_devices().get_user_media(&constraints).await?;

        let video_track = stream.get_video_tracks().get(0);
        let audio_track = stream.get_audio_tracks().get(0);

        // Store tracks for later retrieval by UI
        if let Some(vt) = &video_track {
            self.tracks.insert(vt.id(), vt.clone());
        }
        if let Some(at) = &audio_track {
            self.tracks.insert(at.id(), at.clone());
        }

        Ok(MediaResult {
            stream_id: stream.id(),
            video_track_id: video_track.map(|t| t.id()),
            audio_track_id: audio_track.map(|t| t.id()),
        })
    }

    pub fn get_track(&self, track_id: &str) -> Option<&MediaStreamTrack> {
        self.tracks.get(track_id)
    }
}
```

---

## End-to-End Flow

### 1. User Creates Call

```yaml
# Click "Start Call" button
on_click: "agora/create-call"
on_click_params:
  name: "Quick sync"
```

### 2. Praxis Creates Entities + Initializes WebRTC

```
agora/create-call:
  1. compose call-session entity (status: pending)
  2. actualize webrtc/create_session (generates offer SDP)
  3. mutate session (offer_sdp, status: connecting)
  4. actualize webrtc/get_user_media (camera + mic)
  5. compose call-participant entity (host, is_local: true)
  6. bond participant → session
  7. mutate session (status: active)
  return { session_id, participant_id }
```

### 3. UI Renders Via Render-Spec

```
Chora:
  1. Store receives session entity
  2. Collection mode iterates participants from source_query
  3. Each participant renders via item_spec_id (render-spec/participant-tile)
  4. video widget binds to track_id
  5. WebRTC substrate provides MediaStreamTrack
  6. Browser displays video
```

### 4. Remote User Joins

```
agora/join-call:
  1. validate session is active
  2. actualize webrtc/get_user_media
  3. actualize webrtc/join_session (sends answer SDP)
  4. compose call-participant entity
  5. bond to session

  → ICE negotiation completes
  → Remote track appears in substrate
  → Entity update triggers UI re-render
  → New participant tile appears
```

### 5. User Toggles Video

```yaml
# Click video button
on_click: "agora/toggle-video"
on_click_params:
  participant_id: "{local_participant_id}"
```

```
agora/toggle-video:
  1. query participant
  2. actualize webrtc/toggle_track (enables/disables track)
  3. mutate participant.media_state.video

  → Entity update triggers re-render
  → Video placeholder shows avatar
  → Button variant changes to danger
```

### 6. User Leaves

```yaml
# Click leave (with confirm)
on_click: "ui/confirm"
on_click_params:
  on_confirm: "agora/leave-call"
```

```
agora/leave-call:
  1. close peer connection (if exists)
  2. mutate participant (disconnected)
  3. check remaining participants
  4. if none → call agora/end-call
```

---

## What Changes vs Current Implementation

| Aspect | Current (AgoraTerritory) | Proposed |
|--------|-------------------------|----------|
| UI | Special component + Phaser.js | Standard render-specs + video widget |
| State | Component-local | Entities in graph |
| WebRTC | Inline in component | Dynamis substrate |
| Media | Direct DOM manipulation | Video widget abstraction |
| Actions | Event handlers | Praxis via executor |

---

## Dependencies

| Dependency | Status | Required For |
|------------|--------|--------------|
| Executor praxis bridge | Not implemented | on_click → praxis |
| Video widget | Not implemented | Media display |
| WebRTC substrate | Partial (exists in Phaser) | Connection management |
| Entity subscription | Partial | Real-time participant updates |
| Collection mode pattern | Not implemented | Participant grid via item_spec_id + arrangement |

---

## Implementation Order

1. **Video widget** — Standard widget for MediaStreamTrack display
2. **Collection mode pattern** — `item_spec_id` + `arrangement` for participant grid
3. **WebRTC substrate** — Extract from AgoraTerritory to dynamis
4. **Praxeis** — Call lifecycle operations
5. **Render-specs** — Participant tile, call chrome
6. **Entity subscriptions** — Real-time participant updates
7. **Deprecate AgoraTerritory** — Replace with collection mode

---

## Success Criteria

1. Call renders via render-spec (no `AgoraTerritory.tsx`)
2. Video appears via video widget
3. Participants update in real-time via entity subscription
4. Controls call praxeis via executor
5. Grep audit passes (no call-specific code in `app/src/lib/`)

---

## Relation to Voice Topos

This design mirrors VOICE-TOPOS-DESIGN.md:

| Aspect | Voice | WebRTC |
|--------|-------|--------|
| Substrate | Audio capture + transcription | Peer connections + media |
| Entity | accumulation | call-session, call-participant |
| Commitment | accumulation → phasis | N/A (real-time, no commit) |
| Widget | textarea, badges | video, grid |
| Pattern | Same | Same |

Both demonstrate: **substrates in dynamis, UI in widgets**.

---

*This design demonstrates that even complex real-time media systems (WebRTC video calls) can follow the standard substrate pattern — no special components, just entity state + standard widgets.*
