# Substrate Signal Reference

*Ephemeral sensing across substrates — what's happening right now.*

---

## Overview

Substrate signals are ephemeral measurements broadcast at 10Hz. They represent **sensing**, not **being** — distinct from entity state (`desired_state`, `actual_state`) which is persistent and reconciled.

Any substrate can register a signal source. The broadcast timer reads all sources and pushes signals via WebSocket to the frontend. The frontend maps signals to DOM attributes. CSS handles visual response.

```
substrate → register_signal_source() → 10Hz timer → WebSocket → DOM attributes → CSS
```

---

## Architecture

### Signal Registry (`signal.rs`)

```rust
pub struct SubstrateSignal {
    pub entity_id: String,                    // e.g. "audio-source/default"
    pub signals: Map<String, Value>,          // e.g. {"energy_db": -28.3, "voice_active": true}
}

pub fn register_signal_source(source: SignalSource);
pub fn read_all_signals() -> Vec<SubstrateSignal>;
```

**SignalSource** is `Box<dyn Fn() -> Vec<SubstrateSignal> + Send + Sync>`. Called at 10Hz — must be fast and non-blocking (read atomics or in-memory state only, no I/O).

### Broadcast Path

1. **10Hz timer** in `http.rs` calls `read_all_signals()`
2. Results serialized as JSON and broadcast via WebSocket
3. Frontend receives signal update, writes to `substrateSignals` Map store

### Frontend Bridge

```typescript
// Store: Map<entity_id, Map<signal_key, signal_value>>
const [substrateSignals, setSubstrateSignals] = createStore<Map<string, Map<string, any>>>();
```

Widgets that declare `data-signal-source="{entity_id}"` receive signal values as `data-signal-*` DOM attributes:

```html
<!-- In DOM after signal update -->
<div data-signal-source="audio-source/default"
     data-signal-energy-db="-28.3"
     data-signal-voice-active="true">
```

CSS selectors respond to signals:

```css
[data-signal-voice-active="true"] .indicator { background: green; }
[data-signal-transcribing="true"] .textarea { border-color: blue; }
```

---

## Signal Hold Time

Some signals need to persist briefly after the source stops emitting. The **hold time** pattern delays clearing a signal value.

Example: `transcribing` signal holds for 500ms after inference completes. This prevents visual flickering when inference runs in short bursts.

Hold time is implemented in the signal source function, not in the registry.

---

## Active Signal Sources

| Substrate | Entity ID | Signals | Source |
|-----------|-----------|---------|--------|
| Voice/Audio | `audio-source/default` | `energy_db`, `voice_active` | `voice.rs` |
| Inference | `inference/{provider}` | `transcribing` | `nous.rs` |

---

## Adding a Signal Source

To register signals from a new substrate:

```rust
use crate::signal::{register_signal_source, SubstrateSignal};

register_signal_source(Box::new(|| {
    let mut signals = serde_json::Map::new();
    signals.insert("my_metric".to_string(), json!(current_value()));

    vec![SubstrateSignal {
        entity_id: "my-substrate/default".to_string(),
        signals,
    }]
}));
```

The source function is called every 100ms. Keep it under 1ms.

In the frontend, declare `data-signal-source` on the widget that should receive the signals:

```yaml
# In a render-spec
- widget: badge
  props:
    data-signal-source: "my-substrate/default"
    content: "Status"
```

---

## Key Distinction: Signals vs Entity State

| Aspect | Entity State | Substrate Signals |
|--------|-------------|-------------------|
| **Persistence** | In database, versioned | Ephemeral, in memory |
| **Frequency** | On change (event-driven) | 10Hz continuous |
| **Purpose** | Being — what IS | Sensing — what's HAPPENING |
| **Reconciliation** | desired vs actual → reconcile | Read-only measurement |
| **Transport** | Entity change events | WebSocket broadcast |
| **Frontend** | Reactive store updates | DOM attribute bridge |

Signals complement entity state. Entity state says "voice mode is active." Signals say "voice energy is -28.3 dB right now."

---

*See [actualization-pattern.md](actualization-pattern.md) for how entity state reconciliation works. See [substrate-integration.md](../infrastructure/substrate-integration.md) for the substrate module contract.*
