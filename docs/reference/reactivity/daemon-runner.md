# Daemon Runner — Generic Periodic Praxis Invocation

*Reference doc — prescriptive (target state).*

---

## Overview

The daemon runner is a generic substrate primitive that periodically invokes praxeis. It discovers `eidos: daemon` entities at bootstrap, validates their praxis references, and spawns a single background thread that ticks each daemon at its declared interval.

Combined with the reflex engine, the daemon runner is a trigger mechanism that feeds into the reconciler. Sensing daemons update entity actuality fields, entity updates fire drift-detection reflexes, reflexes invoke `host.reconcile()` or corrective praxeis. The daemon is the parasympathetic trigger (periodic sensing), not a replacement for the reconciler engine.

---

## Daemon Eidos

Defined in `genesis/ergon/eide/ergon.yaml`:

| Field | Type | Required | Default | Description |
|-------|------|----------|---------|-------------|
| `name` | string | yes | — | Short identifier |
| `description` | string | no | — | What this daemon does |
| `praxis` | string | yes | — | Praxis ID to invoke periodically (validated at load) |
| `interval` | number | yes | — | Seconds between invocations |
| `enabled` | boolean | no | `true` | Whether this daemon is active |
| `scope` | enum | no | `global` | Where this daemon applies: global, dwelling, topos |
| `backoff_max` | number | no | — | Maximum backoff interval in seconds |
| `status` | enum | no | `stopped` | Current status: running, stopped, errored (set by runner) |

### Status Lifecycle

```
stopped  ──[daemon loop starts]──>  running
running  ──[praxis fails]────────>  errored
errored  ──[praxis succeeds]─────>  running
running  ──[daemon loop stops]───>  stopped
errored  ──[daemon loop stops]───>  stopped
```

Status is updated via `update_entity()`, which fires `ChangeEvent::EntityUpdated` into the reflex engine. This means reflexes can observe daemon health.

---

## Bootstrap Loading

After `exit_bootstrap_mode()` completes (reflex registry loaded, kosmos live):

1. **Gather**: `gather_entities(eidos: "daemon")` — find all daemon entities
2. **Filter**: Skip daemons with `enabled: false`
3. **Validate**: For each enabled daemon, verify `praxis/{daemon.data.praxis}` exists in the graph. Skip with warning if not found.
4. **Spawn**: Start a single background thread with per-daemon tracking state

If no enabled daemons with valid praxis references are found, no thread is spawned.

---

## Periodic Invocation

### One Thread, Per-Daemon Tracking

The daemon runner uses a single background thread (not per-daemon threads). Each daemon has internal state:

```
DaemonState:
  id:               entity ID
  praxis:           praxis ID to invoke
  base_interval:    configured interval
  backoff_max:      optional maximum backoff
  current_interval: base_interval (increases on failure)
  next_run:         timestamp of next invocation
  errored:          whether currently in error state
```

The thread ticks at 1-second resolution. On each tick, it checks each daemon's `next_run`. If `now >= next_run`, it invokes the daemon's praxis.

### Invocation

Praxeis are invoked via `invoke_praxis(praxis_id, json!({}))` — no params by default. The daemon doesn't pass params; the praxis itself gathers what it needs (e.g., `gather` + `for_each`).

---

## Backoff

On praxis failure:
- `current_interval = current_interval * 2`
- If `backoff_max` is set: `current_interval = min(current_interval * 2, backoff_max)`
- Entity status updated to `errored`

On praxis success:
- `current_interval = base_interval` (reset)
- Entity status updated to `running` (if previously errored)

### Example

Daemon with interval=30, backoff_max=300:

```
Tick 1: invoke → fail → interval=60, status=errored
Tick 2: invoke → fail → interval=120, status=errored
Tick 3: invoke → fail → interval=240, status=errored
Tick 4: invoke → fail → interval=300 (capped), status=errored
Tick 5: invoke → succeed → interval=30 (reset), status=running
```

---

## Error Isolation

Each daemon is independent. A failure in one daemon does not block, delay, or affect others. Errors are logged with `[daemon-loop]` prefix and the daemon's entity ID.

---

## Graceful Shutdown

- `AtomicBool` running flag
- 500ms sleep chunks within the 1s tick for responsive shutdown
- On stop: all daemon statuses set to `stopped` via `update_entity()`
- `Drop` implementation calls `stop()` for RAII cleanup

---

## Reconciliation as Composition

The daemon runner is the parasympathetic (periodic) trigger mechanism for reconciliation. Combined with the reflex engine (sympathetic/event-driven), it feeds into `host.reconcile()`. Reconciliation decomposes into:

```
daemon ticks → sensing praxis updates entity actuality field
                                    │
                              entity_updated event
                                    │
                           reflex trigger matches drift
                                    │
                           response praxis corrects + reports
```

### The Triplet Pattern

Each reconciler becomes three genesis YAML declarations:

1. **Sensing daemon** — periodic `sense_actuality` across target entities
2. **Drift-detection reflex** — trigger on `entity_updated` with condition `intent != actual`
3. **Corrective praxis** — invoked by reflex, reads reconciler configuration, takes action

### Motivating Example: Voice Stream

A voice stream has `intent: active` and `status: failed` (microphone crashed):

- **Daemon** `daemon/sense-voice-streams` (interval: 5s) invokes `thyra/sense-stream-states`
- Sensing praxis gathers all streams, calls `sense_actuality` on each, updating `status` field
- **Reflex** `reflex/thyra/stream-drift` fires: intent=active but status=failed
- **Corrective praxis** re-manifests the stream

No custom engine. The same pattern handles deployments, connections, releases, and validation.

### Existing Reconciler Entities

The `eidos/reconciler` entities remain as declarative configuration. Corrective praxeis read transition tables from them:

```yaml
- step: find
  id: "$reconciler_id"
  bind_to: reconciler
# Now $reconciler.data.transitions is available for matching
```

---

## API

### HostContext Methods

```rust
// Start the daemon loop (after bootstrap)
fn start_daemon_loop(self: &Arc<Self>) -> Result<()>

// Stop the daemon loop (graceful shutdown)
fn stop_daemon_loop(&self)

// Check if daemon loop is running
fn is_daemon_loop_running(&self) -> bool
```

### Testing Seam

```rust
// Run a single daemon cycle synchronously (for tests)
fn daemon_tick_once(host: &HostContext) -> Result<DaemonTickStats>
```

---

## Implementation Location

- `crates/kosmos/src/daemon_loop.rs` — DaemonLoop, DaemonState, discover_daemons, daemon_tick_once
- `crates/kosmos/src/host.rs` — Integration (field, start/stop/is_running methods)
- `crates/kosmos/src/lib.rs` — Module and re-exports
