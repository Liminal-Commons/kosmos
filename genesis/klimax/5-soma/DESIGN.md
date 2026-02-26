# Soma: Embodiment and Presence

*A design for the embodied interface between parousia and world.*

---

## The Problem

The parousia needs a body. Without embodiment:
- No way to perceive (receive input)
- No way to act (emit output)
- No sense of capacity (what can I do?)

V8 MCP already has `arise()`/`depart()` that create session+parousia entities, but soma provides the full embodiment model: channels, percepts, signals, body-schema.

**Soma is where the kosmos meets the outside.**

---

## Implementation Status

| Component | Status | Location |
|-----------|--------|----------|
| soma.yaml schema | ✓ Complete | `klimax/5-soma/soma.yaml` |
| Eide (parousia, channel, percept, signal, body-schema) | ✓ Complete | `spora/spora.yaml` stage-2-presence |
| Artifact definitions | ✓ Defined | soma.yaml (klimax format) |
| Desmoi (channel-of, received-through, emitted-through, schema-of, instantiates) | ✓ Complete | `spora/spora.yaml` stage-1-desmoi |
| Praxeis | ✓ Complete | `genesis/soma/praxeis/soma.yaml` — 7 praxeis loaded |
| MCP arise/depart | ✓ Complete | `kosmos-mcp-v8/lib.rs` — uses soma praxeis with fallback |
| Step types needed | ✓ Complete | update, trace, switch, filter, loose all implemented |
| Wire soma praxeis | ✓ Complete | Praxeis loaded at bootstrap, available as MCP tools |

**54 tests passing** (42 kosmos, 12 kosmos-mcp-v8)

---

## Grounding in the Kosmogonia

### Klimax Position

Soma is scale 5 of 6:
```
kosmos (1) → physis (2) → polis (3) → oikos (4) → SOMA (5) → psyche (6)
```

Soma is the **embodied interface**. It sits between:
- **oikos** (intimate groupings, domains) — the social context
- **psyche** (attention, intention, mood) — the experiencing self

The parousia has a body (soma). Through that body, it perceives and acts. The body has a schema — a sense of its own shape and capacity.

### Aistheterion Connection

From CLAUDE.md:
- **exo-aisthesis** — sensing externals → channels receive percepts
- **idio-aisthesis** — sensing self/state → body-schema awareness
- **endo-aisthesis** — internal awareness → lives in psyche

Soma handles exo and idio. Psyche handles endo.

---

## Architecture

### 1. Core Eide

| Eidos | What It Is |
|-------|------------|
| `parousia` | The dwelling presence (instantiates a prosopon) |
| `channel` | Interface for perception/action (text, voice, vision, etc.) |
| `percept` | Something perceived through a channel |
| `signal` | Something emitted through a channel |
| `body-schema` | The parousia's sense of its own shape and capacity |

### 2. Parousia Lifecycle

```
arising → dwelling → departing → departed
```

| State | What It Means |
|-------|---------------|
| `arising` | Being created, not yet ready |
| `dwelling` | Active, can perceive and act |
| `departing` | Shutting down, closing channels |
| `departed` | Gone, session ended |

### 3. Channel Model

Channels are typed interfaces:

| Kind | Direction | Example |
|------|-----------|---------|
| `perception` | In only | Microphone, camera |
| `action` | Out only | Speaker, display |
| `bidirectional` | Both | Text chat, terminal |

Each channel has a **modality** (text, voice, vision, file, etc.) and a **status** (open, closed, suspended).

### 4. Key Desmoi

| Desmos | From | To | Meaning |
|--------|------|-----|--------|
| `channel-of` | channel | parousia | Channel belongs to parousia |
| `received-through` | percept | channel | Percept received via channel |
| `emitted-through` | signal | channel | Signal sent via channel |
| `schema-of` | body-schema | parousia | Body schema belongs to parousia |
| `instantiates` | parousia | prosopon | Parousia is instance of prosopon |

### 5. Key Praxeis

| Praxis | What It Does |
|--------|-------------|
| `arise-parousia` | Create parousia, instantiate prosopon, create body-schema |
| `depart-parousia` | Mark parousia departed, close all channels |
| `open-channel` | Open a channel for the parousia |
| `close-channel` | Close a channel |
| `perceive` | Record a perception through a channel |
| `emit` | Emit a signal through a channel |
| `sense-body` | Get current body-schema and channel states |

---

## Integration with MCP

### Current State ✓ COMPLETE

`McpServer` in `kosmos-mcp-v8` now uses soma praxeis:
- `DwellingState` tracking (prosopon_id, oikos_id, parousia_id)
- `arise()` method — creates session, then calls `praxis/soma/arise-parousia` for full embodiment
- `depart()` method — calls `praxis/soma/depart-parousia` to close channels and mark departed

The MCP layer handles the session (transport concern), while soma handles the parousia lifecycle (embodiment concern).

### Fallback Pattern

If soma praxeis are not loaded (non-bootstrapped database), MCP falls back to direct implementation:
- Creates parousia entity directly
- Uses `manifests` bond instead of `instantiates`
- No body-schema created in fallback mode

This ensures backwards compatibility while preferring the praxis path when available.

### What MCP Calls

| MCP Method | Soma Praxis | Fallback |
|------------|-------------|----------|
| `arise()` | `praxis/soma/arise-parousia` | Direct entity creation |
| `depart()` | `praxis/soma/depart-parousia` | Direct status update |
| Channel tools | `open-channel`, `close-channel` | N/A (praxis only) |

---

## Channel vs Thyra

Both soma and psyche have interface concepts:

| Concept | Scale | What It Is |
|---------|-------|------------|
| `channel` | soma | Physical interface (perception/action) |
| `thyra` | psyche | Portal (what can be presented, how) |

**The distinction:**
- Channel = the pipe (text in, text out)
- Thyra = the window (what's visible, what's possible)

A parousia typically has:
- One or more **channels** (how it touches the world)
- One **thyra** (the interface experience)

Example:
- CLI session: channel=text (bidirectional), thyra=cli
- Web session: channels=[text, vision], thyra=web

---

## Implementation Path

### Phase 1: Load Soma Praxeis ✓ COMPLETE

1. ✓ Ensure soma.yaml praxeis are loaded at bootstrap
2. ✓ Verify artifact definitions are available
3. ✓ Test `arise-parousia` praxis directly (not via MCP)

### Phase 2: Test Parousia Lifecycle ✓ COMPLETE

1. ✓ Test `arise-parousia` creates parousia + body-schema
2. ✓ Test `depart-parousia` closes channels and marks departed
3. ✓ Verify bonds are created correctly

### Phase 3: Test Channel Management ✓ COMPLETE

1. ✓ Test `open-channel` creates channel with `channel-of` bond
2. ✓ Test `close-channel` updates status
3. ✓ Test `perceive` and `emit` create percepts/signals

### Phase 4: Wire MCP to Soma Praxeis ✓ COMPLETE

1. ✓ Replace `McpServer::arise()` with praxis call (with fallback)
2. ✓ Replace `McpServer::depart()` with praxis call (with fallback)
3. ✓ Channel management available as MCP tools via praxis projection

---

## Decisions Made

1. **Parousia instantiates prosopon, not equals**
   - Prosopon = identity (persistent)
   - Parousia = dwelling presence (session-scoped)
   - One prosopon can have multiple simultaneous parousiai

2. **Body-schema created with parousia**
   - `arise-parousia` creates body-schema automatically
   - Schema tracks available channels and capabilities
   - Updated when channels open/close

3. **Channels belong to parousia, not session**
   - Enables multi-channel scenarios
   - Channel closure is part of departure

## Open Questions

1. **Should percepts/signals be persisted?**
   - Currently: yes, as entities
   - Alternative: ephemeral, only bonds remain
   - Depends on memory/history requirements

2. **How granular should body-schema updates be?**
   - Currently: praxeis update schema on channel changes
   - Alternative: lazy computation when `sense-body` called
   - Tradeoff: consistency vs performance

3. **MCP channel mapping?**
   - What modality for MCP text input/output?
   - Probably: `modality: "text"`, `kind: "bidirectional"`
   - May need special handling for tool calls vs conversation

---

## Constitutional Alignment

Soma implements constitutional axioms from KOSMOGONIA:

| Axiom / Pillar | How Soma Honors It |
|----------------|-------------------|
| **Axiom I: Composition** | Parousia, channels, percepts, and signals are composed via artifact definitions. `arise-parousia` uses composition with provenance bonds. |
| **Axiom II: Authority** | The parousia IS dwelling embodied. `_parousia` in scope carries the body through which praxeis act. Channels provide the interfaces; dwelling context determines which body is acting. |
| **Axiom III: Traceability** | Percepts have `received-through` bonds to their channel. Signals have `emitted-through` bonds. Every perception and action traces to its source. |
| **Visibility = Reachability** | Channels belong to parousiai via `channel-of` bonds. Percepts and signals trace through channels to their parousia. What a parousia can perceive is determined by which channels are bonded to it. |
| **Authenticity = Provenance** | Every entity traces to signed genesis through provenance bonds. |

### Development Pillars

| Pillar | How Soma Implements It |
|--------|------------------------|
| **Schema-driven** | Parousia status is schema-constrained (arising, dwelling, departing, departed). Channel kinds (perception, action, bidirectional) and modalities (text, voice, vision, file) are enumerated. |
| **Graph-driven** | All relationships are bonds: `channel-of`, `received-through`, `emitted-through`, `schema-of`, `instantiates`. No embedded channel arrays in parousia — traverse to find channels. |
| **Cache-driven** | Body-schema is a cached aggregation of channel states. Updated when channels open/close. `sense-body` returns current cached state. |

### The Embodiment Graph

```
prosopon ◀──instantiates── parousia ──channel-of──▶ channel
                            │                       │
                            └──schema-of──▶ body-schema
                                                    │
                                           received-through
                                           emitted-through
                                                    │
                                                    ▼
                                            percept / signal
```

The parousia instantiates a prosopon (identity) while having a body (soma) through which it dwells. The body-schema provides self-awareness of capacity.

### Caller Pattern

Soma uses **composed** caller patterns for runtime entity creation:
- `arise-parousia` composes parousia from artifact definition
- `open-channel` composes channel from definition
- Percepts and signals are composed as they flow through channels

Body-schema fields are **computed** from channel state aggregation.

### MCP Integration Pattern

The MCP layer (transport) delegates to soma (embodiment):

```
McpServer::arise() → praxis/soma/arise-parousia → parousia + body-schema
McpServer::depart() → praxis/soma/depart-parousia → channels closed, departed
```

Fallback to direct implementation when soma praxeis not loaded (backwards compatibility).

---

## Summary

Soma provides:
- **Parousia**: the dwelling presence with lifecycle
- **Channels**: typed interfaces for perception/action
- **Percepts/Signals**: what flows through channels
- **Body-schema**: awareness of own capacity

**Current state:** Soma is fully wired. All 4 phases complete:
- 7 soma praxeis loaded at bootstrap
- MCP arise/depart use soma praxeis (with fallback)
- 54 tests passing (42 kosmos, 12 kosmos-mcp-v8)

**Next:** Wire oikos (scale 4) or wire nous praxeis for theoria/journey operations.

---

## Related Documents

- [ROADMAP.md](../../ROADMAP.md) — Layer 7 (soma/psyche) status
- [klimax/6-psyche/psyche.yaml](../6-psyche/psyche.yaml) — The inner life (depends on soma)
- [klimax/3-polis/DESIGN.md](../3-polis/DESIGN.md) — Dwelling context
- [soma.yaml](soma.yaml) — Full schema (klimax format)
- [soma/praxeis/soma.yaml](../../soma/praxeis/soma.yaml) — Interpreter-format praxeis

---

*Composed in service of the kosmogonia.*
*Traces to: phasis/genesis-root*
*Created: 2026-01-19*
*Updated: 2026-01-19 — MCP wired to soma praxeis, 54 tests passing*
