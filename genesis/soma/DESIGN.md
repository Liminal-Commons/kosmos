# Soma Design

σῶμα (soma) — body, that through which presence acts.

## Ontological Purpose

What gap in being does soma address?

**The gap between identity and presence.** Without soma, personas exist but cannot act. Circles exist but nothing dwells in them. The kosmos would be a static graph of definitions with no lived experience, no perception, no expression.

Soma provides:
- **Embodiment** — animus that instantiates persona within circles
- **Channels** — typed pathways for perception and expression
- **Perception** — receiving stimuli from the environment
- **Expression** — emitting signals into the environment
- **Proprioception** — awareness of one's own capabilities and state

**What becomes possible:**
- Presence in circles (dwelling, not just membership)
- Communication through typed channels
- Environmental awareness through perception
- Action through signal emission
- Self-awareness through body-schema sensing

## Circle Context

### Self Circle

A solitary dweller uses soma to:
- Arise as animus in their personal circle
- Open channels to their environment (file system, clipboard, etc.)
- Perceive inputs from those channels
- Emit signals (responses, actions) through channels
- Sense their body-schema to know what they can do

The self circle is where embodiment is most intimate — your channels, your perception, your expression.

### Peer Circle

Collaborators use soma to:
- Each arise as distinct animus in the shared circle
- Open shared channels (messaging, collaboration tools)
- Perceive each other's signals as environmental stimuli
- Emit signals visible to other circle members
- Sense the collective body (who's present, what channels exist)

Presence is mutual — you perceive others' emissions, they perceive yours.

### Commons Circle

A community uses soma to:
- Support many simultaneous animus instances
- Maintain persistent channels (forums, feeds, archives)
- Aggregate perception across the community
- Route signals through governance (moderated channels)
- Provide body-schema that reflects collective capability

The commons circle is where embodiment becomes infrastructure — channels that persist, perception that scales.

## Core Entities (Eide)

### channel

Communication pathway with typed modality.

**Fields:**
- `channel_type` — modality (text, audio, visual, haptic, data)
- `direction` — flow direction (input, output, bidirectional)
- `status` — state (open, closed, suspended)
- `metadata` — channel-specific configuration

**Lifecycle:**
1. **Open** — Created via `open-channel` with type and direction
2. **Active** — Percepts received, signals emitted
3. **Suspend** — Temporarily inactive but state preserved
4. **Close** — Torn down via `close-channel`

### percept

Incoming stimulus received through a channel.

**Fields:**
- `content` — the perceived data
- `percept_type` — stimulus category
- `received_at` — timestamp of perception
- `source` — origin identifier (if known)

**Nature:** Percepts are ephemeral — they represent moments of perception, not persistent state. They flow through channels and may be processed into more permanent forms.

### body-signal

Outgoing emission through a channel.

**Fields:**
- `content` — the emitted data
- `signal_type` — emission category
- `emitted_at` — timestamp of emission
- `target` — destination identifier (if applicable)

**Nature:** Signals are actions — the body expressing into the environment. Like percepts, they are moments rather than persistent entities.

### body-schema

Proprioceptive snapshot of embodied capabilities.

**Fields:**
- `channels` — available channels and their states
- `capabilities` — what actions are possible
- `attainments` — current capability grants
- `mood` — current dispositional state
- `sensed_at` — when this snapshot was taken

**Nature:** Body-schema is the answer to "what can I do right now?" It aggregates state from across oikoi into a unified proprioceptive view.

## Bonds (Desmoi)

### instantiates
- **From:** animus
- **To:** persona
- **Cardinality:** many-to-one
- **Traversal:** Which persona does this animus embody?

### channel-of
- **From:** channel
- **To:** animus
- **Cardinality:** many-to-one
- **Traversal:** Whose channel is this? What channels does this animus have?

### received-through
- **From:** percept
- **To:** channel
- **Cardinality:** many-to-one
- **Traversal:** Which channel received this percept?

### emitted-through
- **From:** signal
- **To:** channel
- **Cardinality:** many-to-one
- **Traversal:** Which channel emitted this signal?

### schema-of
- **From:** body-schema
- **To:** animus
- **Cardinality:** one-to-one
- **Traversal:** What is this animus's body-schema?

## Operations (Praxeis)

### Presence Operations

#### arise-animus
Instantiate persona as embodied presence in a circle.
- **When:** Entering a circle, beginning a session
- **Requires:** Persona exists, circle sovereign permits
- **Effect:** Animus created, bonds established
- **Gated by:** `attainment/embody`

#### depart-animus
End embodied presence, clean up channels.
- **When:** Leaving a circle, ending session
- **Effect:** Channels closed, animus removed
- **Gated by:** `attainment/embody`

### Channel Operations

#### open-channel
Create communication pathway for animus.
- **When:** Connecting to environment, setting up I/O
- **Requires:** Animus exists, channel type valid
- **Effect:** Channel created, bound to animus
- **Gated by:** `attainment/channel`

#### close-channel
Tear down communication pathway.
- **When:** Disconnecting, cleanup
- **Effect:** Channel removed, pending signals flushed
- **Gated by:** `attainment/channel`

### Perception Operations

#### perceive
Receive stimulus through channel into percept.
- **When:** Input arrives, environment changes
- **Requires:** Channel open, direction permits input
- **Effect:** Percept created, bound to channel

### Expression Operations

#### emit
Send signal through channel into environment.
- **When:** Taking action, responding, expressing
- **Requires:** Channel open, direction permits output
- **Effect:** Signal created and sent

### Sensing Operations

#### sense-body
Generate proprioceptive snapshot of current state.
- **When:** Before action, for self-awareness
- **Effect:** Body-schema created/updated
- **Returns:** Current capabilities, channels, mood

## Attainments

### attainment/embody
**Capability:** Arise and depart as animus — managing presence.
**Gates:** `arise-animus`, `depart-animus`
**Scope:** circle

### attainment/channel
**Capability:** Open and close channels — managing I/O pathways.
**Gates:** `open-channel`, `close-channel`
**Scope:** circle

## Embodiment

### Completeness Status

| Level | Status |
|-------|--------|
| Defined | eide, desmoi, praxeis exist in YAML |
| Loaded | Bootstrap loads into kosmos.db |
| Projected | MCP projects praxeis as tools |
| Embodied | Body-schema reflects capabilities |
| Surfaced | Reconciler notices when actions are relevant |
| Afforded | Thyra UI presents contextual actions |

### Body-Schema Contribution

When `sense-body` runs, soma contributes:

```yaml
body-schema:
  presence:
    animus_active: true|false
    circle_id: "circle/..."     # where dwelling
    persona_id: "persona/..."   # who embodied
  channels:
    - channel_id: "channel/..."
      type: text
      direction: bidirectional
      status: open
    - channel_id: "channel/..."
      type: data
      direction: input
      status: open
  capabilities:
    - name: perceive
      available: "$channels.any(c => c.direction in ['input', 'bidirectional'])"
    - name: emit
      available: "$channels.any(c => c.direction in ['output', 'bidirectional'])"
```

### Reconciler

```yaml
reconciler/soma-presence:
  trigger: on-dwell
  sense: |
    - Check if animus exists for dwelling persona
    - Check channel health (timeouts, disconnects)
    - Check for pending percepts
  surface: |
    - If no animus: suggest arise
    - If channels unhealthy: suggest reconnect
    - If percepts pending: highlight input available
```

## Compound Leverage

### Amplifies Other Oikoi

| Oikos | How Soma Amplifies |
|-------|-------------------|
| **politeia** | Animus is subject of sovereignty. Governance acts on embodied presence. |
| **psyche** | Attention requires perceiving presence. Mood affects body-schema. |
| **thyra** | Channels connect to thyra streams. Expression flows through panels. |
| **nous** | Perception feeds thinking. Semantic search perceives knowledge. |
| **aither** | Channels may bridge to network. Federation perceives remote signals. |

### Cross-Oikos Patterns

1. **Embody → Perceive → Think → Express**
   Soma provides the presence loop: arise in circle, perceive environment, process through nous/psyche, emit response.
   Example: Animus arises → channel opens → user input perceived → processed → response emitted.

2. **Body-Schema → Affordance → Action**
   Soma's body-schema feeds politeia's affordances. What you can do depends on what channels exist.
   Example: File channel open → "save" affordance appears → user can save.

3. **Channel → Stream → Expression**
   Soma channels connect to thyra streams. The body's I/O manifests in the portal.
   Example: Text channel → expression stream → message appears in UI.

## Theoria

New theoria crystallized during this design:

### T27: Presence precedes perception

You must be somewhere (embodied as animus) before you can perceive or act. Embodiment is not optional — it is the precondition for all experience in a circle.

### T28: Channels are typed attention

A channel is not just a pipe — it is a commitment to perceive a particular modality. Opening a channel declares "I am attending to this." The channel type shapes what can flow through it.

### T29: Body-schema is proprioceptive truth

The body-schema is not documentation — it is the lived reality of "what can I do right now?" It integrates state from across oikoi into the answer that precedes every action.

---

*Soma is the body that makes presence possible — the animus that dwells, the channels that connect, the perception that receives, the expression that acts. Without body there is no lived experience, only abstract structure.*
