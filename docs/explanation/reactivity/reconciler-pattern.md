# Explanation: The Reconciler Pattern

How kosmos aligns declared intent with substrate actuality through continuous reconciliation.

---

## The Problem

Consider a voice stream. You want to start capturing audio:

**Naive approach:**
```
1. Call "start audio capture"
2. Assume it started
3. Later discover it failed silently
```

Problems:
- No separation between want and have
- Error handling scattered throughout code
- State can drift from reality
- No recovery mechanism

**Reconciler approach:**
```
1. Declare intent: "I want this stream active"
2. Sense actuality: "Is the substrate actually running?"
3. Reconcile: If mismatch, take action to align
4. Repeat
```

---

## The Pattern

```
┌─────────────────────────────────────────────────────┐
│                    ENTITY                           │
│  intent: active     ←── what we want               │
│  status: pending    ←── what we have               │
└─────────────────────────────────────────────────────┘
                      │
                      ▼
┌─────────────────────────────────────────────────────┐
│                 SENSE ACTUALITY                     │
│  Query substrate: is the process running?           │
│  Returns: { running: false }                        │
└─────────────────────────────────────────────────────┘
                      │
                      ▼
┌─────────────────────────────────────────────────────┐
│                   RECONCILE                         │
│  Compare: intent=active, actual=not running         │
│  Action needed: manifest (start the process)        │
└─────────────────────────────────────────────────────┘
                      │
                      ▼
┌─────────────────────────────────────────────────────┐
│                   ACTUALIZE                         │
│  Execute: spawn audio capture process               │
│  Update entity: status → active, handle → PID       │
└─────────────────────────────────────────────────────┘
```

---

## Implementation in Thyra

Streams follow the reconciler pattern with four operations:

| Operation | Purpose |
|-----------|---------|
| **open-stream** | Set intent=active, trigger reconcile |
| **sense-stream** | Query substrate state without modifying entity |
| **reconcile-stream** | Compare intent vs actuality, take action |
| **close-stream** | Set intent=closed, trigger reconcile |

The reconciler praxis:

```yaml
praxis/thyra/reconcile-stream:
  steps:
    # 1. Get entity
    - step: find
      id: "$stream_id"
      bind_to: stream

    # 2. Sense actual state
    - step: sense_actuality
      entity_id: "$stream_id"
      bind_to: actual

    # 3. Compare and act
    - step: switch
      cases:
        # Want active, not running → manifest
        - when: '$intent == "active" and not $actual.running'
          then:
            - step: manifest
              entity_id: "$stream_id"
            - step: update
              data:
                status: "active"

        # Want closed, still running → unmanifest
        - when: '$intent == "closed" and $actual.running'
          then:
            - step: unmanifest
              entity_id: "$stream_id"
            - step: update
              data:
                status: "closed"
```

---

## Why Separate Intent from Status?

### Intent is declarative

```yaml
# User says: "I want this stream active"
intent: active
```

Intent describes the desired state. It's what the user or system wants to happen.

### Status is descriptive

```yaml
# System reports: "The stream is currently pending"
status: pending
```

Status describes the actual state. It's what the substrate reports.

### The gap is where work happens

When intent ≠ status, the reconciler has work to do:

| Intent | Status | Action |
|--------|--------|--------|
| active | pending | manifest |
| active | active | none (aligned) |
| closed | active | unmanifest |
| closed | closed | none (aligned) |
| paused | active | pause (future) |

---

## Reconciliation is Continuous

The reconciler can run:
- **On demand** — when intent changes
- **Periodically** — as a health check
- **On events** — when substrate reports changes

This enables self-healing:

```
1. Process crashes unexpectedly
2. Next reconcile: sense shows running=false
3. But intent=active
4. Reconciler: manifest (restart process)
5. System recovers automatically
```

---

## Actuality Modes

Different substrates require different sensing and actuation:

| Mode | Sense | Manifest | Unmanifest |
|------|-------|----------|------------|
| **process** | Check if PID exists | Spawn process | Kill process |
| **voice** | Query audio capture state | Start VAD + transcription | Stop capture |
| **network** | Check connection state | Establish connection | Close connection |
| **signaling** | Query WebRTC state | Initialize peer | Disconnect |

The reconciler pattern is substrate-agnostic. The mode defines the specific operations.

---

## Theoria

### T51: Streams follow the reconciler pattern

Intent declares what we want. Actuality reflects what substrate reports. Reconciler aligns them. This applies to all modes: media, process, network, signaling.

---

## Benefits

### Declarative

Users declare what they want, not how to achieve it:

```yaml
# Good: declare intent
thyra/open-stream:
  kind: voice
  intent: active

# The reconciler figures out the how
```

### Observable

State is always visible:

```yaml
# Query any stream
thyra/sense-stream:
  returns:
    intent: active
    status: active
    actual_running: true
    aligned: true
```

### Recoverable

The system can self-heal because:
- Intent is persistent
- Actuality is sensed, not assumed
- Reconciler continuously aligns them

### Testable

Each operation is isolated:
- Test sense independently
- Test reconcile logic independently
- Mock substrate for unit tests

---

## Related Concepts

- **[Commitment Boundary](./commitment-boundary.md)** — Where accumulation commits to phasis
- **[Entity-as-Source-of-Truth](./entity-as-source-of-truth.md)** — Why entity holds intent and status
- **Mode** — Substrate-specific sense/manifest/unmanifest operations
- **Dynamis** — Substrate capabilities that modes draw upon

---

## References

- [genesis/thyra/DESIGN.md](../../genesis/thyra/DESIGN.md) — Thyra design with T51 theoria
- [genesis/thyra/praxeis/thyra.yaml](../../genesis/thyra/praxeis/thyra.yaml) — Reconciler praxeis
- [genesis/thyra/modes/voice.yaml](../../genesis/thyra/modes/voice.yaml) — Voice mode
- Kubernetes reconciliation loops — architectural inspiration

---

*The reconciler pattern separates wanting from having. It is the discipline of continuous alignment.*

*For the full actualization cycle, substrate taxonomy, and mode catalog, see [actualization-pattern.md](../../reference/reactivity/actualization-pattern.md).*
