# Substrate Lifecycle

*How substrates manifest, sense, and unmanifest in response to mode activation.*

**Status: PRESCRIPTIVE** — describes target state. Voice substrate is fully implemented. WebRTC and Phaser substrates are stubs.

---

## Overview

Substrates are dynamis capabilities (audio capture, video streams, game rendering) that thyra modes can require. They are managed through **dynamis modes** — mode entities with a `substrate` field and `operations` that declare stoicheion dispatch for bridging kosmos intent with chora actuality.

The lifecycle is: **manifest** (bring up) → **sense** (check state) → **unmanifest** (tear down).

> **Note**: This document covers the TypeScript handler pattern used by dynamis modes that require frontend lifecycle management (media, webrtc, phaser). For the Rust module contract used by compute, storage, network, and credential substrates, see [substrate-integration.md](substrate-integration.md). For thyra modes (presentation), see [Mode Reference](../presentation/mode-reference.md) — thyra modes have no explicit lifecycle operations; the layout engine projects them reactively.

---

## Substrate Handler Interface

Each substrate registers a handler implementing this interface:

```typescript
interface ActualityHandler {
  /** Bring the substrate into actuality */
  manifest(): Promise<void>;

  /** Check current substrate state */
  sense(): Promise<ActualityState>;

  /** Tear down the substrate */
  unmanifest(): Promise<void>;
}

interface ActualityState {
  active: boolean;
  health: "healthy" | "degraded" | "failed";
  details?: Record<string, unknown>;
}
```

Handlers are registered by mode ID:

```typescript
registerActualityHandler("mode/voice", {
  manifest: () => startMicCapture(),
  sense: () => ({ active: isCapturing(), health: "healthy" }),
  unmanifest: () => stopMicCapture(),
});
```

---

## Mode-Substrate Reconciliation

When active modes change, the layout engine reconciles substrates:

1. Collect `requires` arrays from all active modes
2. Diff against currently manifested infrastructure modes
3. **Manifest** newly required modes (call `handler.manifest()`)
4. **Unmanifest** no-longer-required modes (call `handler.unmanifest()`)

```yaml
# Mode that uses voice state via bond traversal
mode/compose-transcribing:
  render_spec_id: render-spec/compose-transcribing
  spatial: { position: bottom, height: auto }
  source_entity_id: accumulation/default
```

Compose-transcribing reads voice state via bond traversal (`@fed-by-audio`, `@fed-by-transcriber`), and mode switching is reflex-driven when transcriber state changes. The voice substrate itself (`mode/voice`) is manifested/unmanifested based on the audio-source entity's desired_state reconciliation.

---

## Infrastructure Mode Entity Schema

Each infrastructure mode is defined in genesis:

```yaml
- eidos: mode
  id: mode/voice
  data:
    name: Voice Capture
    substrate: audio
    description: "Audio capture + VAD + transcription pipeline"
    operations:
      manifest:
        description: "Start audio stream, initialize VAD"
        params: { sample_rate: 16000, vad_threshold: 0.5 }
      sense:
        description: "Check capture state"
        returns: { active: boolean, fragments_count: integer }
      unmanifest:
        description: "Close audio stream, cleanup"
    requires_dynamis:
      - audio-capture
      - transcription
```

---

## Substrate Implementations

### Voice (Implemented)

Full pipeline: cpal audio capture → VAD → whisper-server → transcript accumulation.

| Component | File | Role |
|-----------|------|------|
| Rust capture | `app/src-tauri/src/voice_capture.rs` | cpal mic → PCM frames |
| Whisper bridge | `scripts/whisper-server.py` | PCM → transcript text |
| Interpreter glue | `crates/kosmos/src/voice.rs` | Transcript → accumulation entity |
| UI handler | `app/src/lib/voice/capture.ts` | Actuality handler registration |

**Reference implementation** — all other substrates follow this pattern.

### WebRTC (Target)

Peer-to-peer video/audio via browser WebRTC API.

| Component | File | Role |
|-----------|------|------|
| Track registry | `app/src/substrates/webrtc.ts` | MediaStreamTrack storage |
| Signaling | (not yet implemented) | Via kosmos praxeis |

**Substrate handler contract:**

```typescript
registerActualityHandler("mode/webrtc", {
  manifest: async () => {
    // 1. Create RTCPeerConnection
    // 2. Register signaling handlers (via kosmos praxeis)
    // 3. Start ICE negotiation
    // 4. On receiving remote tracks: registerTrack(trackId, track)
  },
  sense: async () => ({
    active: peerConnection?.connectionState === "connected",
    health: deriveHealth(peerConnection),
    details: {
      remote_tracks: getRegisteredTrackCount(),
      connection_state: peerConnection?.connectionState,
    },
  }),
  unmanifest: async () => {
    // 1. Close peer connection
    // 2. Unregister all tracks
    // 3. Cleanup signaling handlers
  },
});
```

**Track registration** connects to the `video` widget:

```typescript
// Track IDs are deterministic: {peerId}-{trackKind}
registerTrack("peer-abc-video", remoteVideoTrack);

// Video widget resolves track by ID binding
// render-spec: { widget: video, props: { track_id: "{peer_id}-video" } }
```

**Signaling via kosmos praxeis** (not hardcoded):

```yaml
# Praxeis for WebRTC signaling
praxis/webrtc-offer:
  stoicheion: webrtc/create-offer
  params: { peer_id: string }

praxis/webrtc-answer:
  stoicheion: webrtc/create-answer
  params: { peer_id: string, offer: string }

praxis/webrtc-ice-candidate:
  stoicheion: webrtc/add-ice-candidate
  params: { peer_id: string, candidate: string }
```

### Phaser (Target)

Game rendering via Phaser.js engine.

| Component | File | Role |
|-----------|------|------|
| Scene manager | `app/src/substrates/phaser.ts` | Phaser game instance lifecycle |

**Substrate handler contract:**

```typescript
registerActualityHandler("mode/phaser", {
  manifest: async () => {
    // 1. Create or reuse Phaser.Game instance
    // 2. Load scene specified by mode config
    // 3. Attach to phaser-canvas widget container
  },
  sense: async () => ({
    active: game?.isRunning ?? false,
    health: game ? "healthy" : "failed",
    details: { scene_id: activeScene?.key },
  }),
  unmanifest: async () => {
    // 1. Pause/stop active scene
    // 2. Detach from container
    // 3. Cleanup if no other modes need Phaser
  },
});
```

**Container attachment** — the `phaser-canvas` widget provides the DOM element:

```typescript
// phaser-canvas widget calls substrate on mount
attachToContainer(containerElement, sceneId);

// On unmount
detachFromContainer(containerElement);
```

---

## Anti-Patterns

### Wrong: Substrate logic in the interpreter

```typescript
// WRONG — interpreter must be domain-agnostic
if (mode.requires.includes("mode/voice")) {
  startMicrophone();
}
```

The interpreter calls `handler.manifest()` generically. Substrate-specific logic lives in the handler.

### Wrong: Direct substrate invocation from render-specs

```yaml
# WRONG — substrates are manifested by mode lifecycle, not widget events
- widget: button
  props:
    on_click: start-webrtc-connection
```

Substrates manifest when modes activate. Widgets interact with manifested substrates through bindings and stoicheia, not by controlling the substrate lifecycle.

### Wrong: Hardcoded signaling

```typescript
// WRONG — signaling must flow through kosmos praxeis
const ws = new WebSocket("wss://signal.example.com");
```

All signaling uses kosmos praxeis so the graph governs visibility and routing.

---

## Implementation Location

| File | Change |
|------|--------|
| `app/src/lib/actuality.ts` | Handler registry and reconciliation (implemented) |
| `app/src/substrates/webrtc.ts` | WebRTC handler implementation (stub → real) |
| `app/src/substrates/phaser.ts` | Phaser handler implementation (stub → real) |
| `genesis/thyra/modes/` | Infrastructure mode entity definitions |

---

## Test Assertions

1. **Manifest on activation**: When a mode with `requires: [mode/X]` becomes active, `handler.manifest()` is called exactly once.

2. **Unmanifest on deactivation**: When the last mode requiring `mode/X` deactivates, `handler.unmanifest()` is called.

3. **Shared substrate**: When two active modes both require `mode/X`, manifest is called once. Unmanifest is called only when both modes deactivate.

4. **Sense returns state**: After manifest, `handler.sense()` returns `{ active: true, health: "healthy" }`.

5. **WebRTC track registration**: After manifest, remote tracks are registered with deterministic IDs. `video` widget resolves track by `track_id` binding.

6. **Phaser container attachment**: After manifest, Phaser game attaches to `phaser-canvas` widget container. After unmanifest, game detaches.

7. **Signaling via praxeis**: WebRTC offer/answer/ICE candidate exchange flows through kosmos praxeis, not direct WebSocket connections.

---

*See [VOICE-TOPOS-DESIGN.md](../design/VOICE-TOPOS-DESIGN.md) for the voice substrate design.*
*See [WEBRTC-TOPOS-DESIGN.md](../design/WEBRTC-TOPOS-DESIGN.md) for the WebRTC substrate design.*
*See [RENDERING-GAPS.md](../../architecture/RENDERING-GAPS.md) for current divergences.*
