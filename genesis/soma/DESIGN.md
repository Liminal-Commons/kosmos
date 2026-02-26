# Soma Design

σῶμα (soma) — body, that through which presence acts.

## Ontological Purpose

What gap in being does soma address?

**The gap between identity and presence.** Without soma, prosopa exist but cannot act. Oikoi exist but nothing dwells in them. The kosmos would be a static graph of definitions with no lived experience, no perception, no phasis.

Soma provides:
- **Embodiment** — parousia that instantiates prosopon within oikoi
- **Channels** — typed pathways for perception and phasis
- **Perception** — receiving stimuli from the environment
- **Phasis** — emitting signals into the environment
- **Proprioception** — awareness of one's own capabilities and state
- **Inference** — access to external LLM providers via provider entities

**What becomes possible:**
- Presence in oikoi (dwelling, not just membership)
- Communication through typed channels
- Environmental awareness through perception
- Action through signal emission
- Self-awareness through body-schema sensing
- LLM inference and embedding via provider entities

## Oikos Context

### Self Oikos

A solitary dweller uses soma to:
- Arise as parousia in their personal oikos
- Open channels to their environment (file system, clipboard, etc.)
- Perceive inputs from those channels
- Emit signals (responses, actions) through channels
- Sense their body-schema to know what they can do

The self oikos is where embodiment is most intimate — your channels, your perception, your phasis.

### Peer Oikos

Collaborators use soma to:
- Each arise as distinct parousia in the shared oikos
- Open shared channels (messaging, collaboration tools)
- Perceive each other's signals as environmental stimuli
- Emit signals visible to other oikos members
- Sense the collective body (who's present, what channels exist)

Presence is mutual — you perceive others' emissions, they perceive yours.

### Commons Oikos

A community uses soma to:
- Support many simultaneous parousia instances
- Maintain persistent channels (forums, feeds, archives)
- Aggregate perception across the community
- Route signals through governance (moderated channels)
- Provide body-schema that reflects collective capability

The commons oikos is where embodiment becomes infrastructure — channels that persist, perception that scales.

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

**Nature:** Body-schema is the answer to "what can I do right now?" It aggregates state from across topoi into a unified proprioceptive view.

### provider

External service that provides inference and/or embedding capabilities. Provider entities are the graph representation of external APIs — adding a provider means adding a genesis entity, not changing code.

**Fields:**
- `name` — human-readable provider name (e.g., "Anthropic", "OpenAI")
- `description` — what the provider offers
- `capabilities` — list of capabilities: `inference`, `embedding`
- `credential_config` — how to authenticate:
  - `service` — credential service name for keychain lookup
  - `auth_header` — HTTP header name (e.g., `x-api-key`, `Authorization`)
  - `auth_prefix` — optional prefix (e.g., `"Bearer "`)
  - `grants_attainment` — attainment granted when credential is unlocked
  - `placeholder` — UI hint for API key format
- `inference_config` — how to make inference requests:
  - `endpoint` — API URL
  - `request_format` — `anthropic` or `openai`
  - `extra_headers` — additional HTTP headers
  - `streaming` — streaming configuration
- `embedding_config` — how to make embedding requests (optional):
  - `endpoint` — API URL
  - `request_format` — format identifier
  - `default_model` — default embedding model
  - `dimensions` — embedding vector dimensions
- `models_config` — how to list available models:
  - `endpoint` — API URL
  - `request_format` — format identifier

**Relationship to model-tier:** Provider entities are the parent; model-tier entities are bonded to their provider via `provided-by`. When a credential is added for a provider, reflexes fire to query the models API and populate model-tier entities with resolved model IDs.

### model-tier

A tier within a provider's model hierarchy. Three tiers per provider: capable, balanced, fast.

**Fields:**
- `tier` — tier name (capable, balanced, fast)
- `provider` — provider name
- `model_id` — resolved model ID (empty until credential triggers resolution)
- `resolved_at` — when the model was resolved

**Bonds:**
- `provided-by` → `provider/{name}` — which provider this tier belongs to

## Bonds (Desmoi)

### instantiates
- **From:** parousia
- **To:** prosopon
- **Cardinality:** many-to-one
- **Traversal:** Which prosopon does this parousia embody?

### channel-of
- **From:** channel
- **To:** parousia
- **Cardinality:** many-to-one
- **Traversal:** Whose channel is this? What channels does this parousia have?

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
- **To:** parousia
- **Cardinality:** one-to-one
- **Traversal:** What is this parousia's body-schema?

### authenticates
- **From:** credential
- **To:** provider
- **Cardinality:** many-to-one
- **Traversal:** Which provider does this credential authenticate? What credentials authenticate this provider?

### provided-by
- **From:** model-tier
- **To:** provider
- **Cardinality:** many-to-one
- **Traversal:** Which provider does this tier belong to?

## Operations (Praxeis)

### Presence Operations

#### arise-parousia
Instantiate prosopon as embodied presence in an oikos.
- **When:** Entering an oikos, beginning a session
- **Requires:** Prosopon exists, oikos sovereign permits
- **Effect:** Parousia created, bonds established
- **Gated by:** `attainment/embody`

#### depart-parousia
End embodied presence, clean up channels.
- **When:** Leaving an oikos, ending session
- **Effect:** Channels closed, parousia removed
- **Gated by:** `attainment/embody`

### Channel Operations

#### open-channel
Create communication pathway for parousia.
- **When:** Connecting to environment, setting up I/O
- **Requires:** Parousia exists, channel type valid
- **Effect:** Channel created, bound to parousia
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

### Phasis Operations

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

### Oikos Membership Operations

Oikos membership management enables homoiconic oikos discovery — the graph IS the configuration for which oikoi a prosopon belongs to.

#### join-oikos
Join an oikos by creating a member-of bond.
- **When:** Connecting to a new oikos, accepting invitation
- **Requires:** Oikos exists, optionally endpoint URL
- **Effect:** member-of bond created from prosopon to oikos
- **Returns:** Oikos ID and endpoint for connection

#### leave-oikos
Leave an oikos by removing the member-of bond.
- **When:** Disconnecting from an oikos, revoking membership
- **Requires:** Oikos exists
- **Effect:** member-of bond removed via `loose`

#### list-memberships
List all oikoi the current prosopon is a member of.
- **When:** MCP bridge discovery, membership inventory
- **Returns:** Oikoi with endpoints for homoiconic discovery
- **Enables:** Graph-based oikos discovery instead of external config

**Homoiconic Discovery Pattern:**
```
1. Bootstrap: Connect to KOSMOS_HOME
2. Authenticate as prosopon
3. Call soma/list-memberships
4. Get oikoi with endpoints
5. Connect to each discovered oikos
```

### Inference Operations

#### resolve-model-tiers
Query a provider's models API and categorize models into tiers.
- **When:** A credential for the provider is added (reflex-triggered)
- **Requires:** Valid credential for the provider
- **Effect:** model-tier entities populated with resolved model IDs
- **Triggered by:** `reflex/soma/resolve-{provider}-tiers` via `trigger/soma/{provider}-credential-added`

## Attainments

### attainment/embody
**Capability:** Arise and depart as parousia — managing presence.
**Gates:** `arise-parousia`, `depart-parousia`
**Scope:** oikos

### attainment/channel
**Capability:** Open and close channels — managing I/O pathways.
**Gates:** `open-channel`, `close-channel`
**Scope:** oikos

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
    parousia_active: true|false
    oikos_id: "oikos/..."         # where dwelling
    prosopon_id: "prosopon/..."   # who embodied
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
    - Check if parousia exists for dwelling prosopon
    - Check channel health (timeouts, disconnects)
    - Check for pending percepts
  surface: |
    - If no parousia: suggest arise
    - If channels unhealthy: suggest reconnect
    - If percepts pending: highlight input available
```

## Body-Schema Contributions

When `sense-body` runs, it aggregates proprioceptive state from across topoi. Each contributing topos declares what it adds to the body-schema:

### Core Soma
```yaml
soma:
  schema: <body-schema entity>
  channels: <open channels>
  capabilities: [perceive, emit, dwell]
  limits: <schema limits>
```

### Ergon
```yaml
ergon:
  active_pragmas: 3
  stale_pragmas: 1
  active_daemons: 2
  pending_reflexes: 0
```

### Nous
```yaml
nous:
  active_journeys: 1
  pending_inquiries: 2
  theoria_count: 47
  recent_crystallizations: 3
```

### Oikos
```yaml
oikos:
  session_duration: "2h 15m"
  notes_unprocessed: 5
  insights_uncrystallized: 3
```

### Propylon
```yaml
propylon:
  pending_entries: 1
  active_sessions: 2
  expiring_links: 0
```

### Dynamis
```yaml
dynamis:
  deployments_healthy: 4
  deployments_degraded: 1
  reconciliation_pending: 0
```

### Credentials
```yaml
credentials:
  unlocked: 3
  locked: 5
  expiring_soon: 1
```

### Dokimasia
```yaml
dokimasia:
  pending_validations: 0
  recent_failures: 2
  provenance_issues: 1
```

### Release
```yaml
release:
  latest_version: "0.9.0"
  artifacts_distributed: true
  channels_active: 2
```

### Demiurge
```yaml
development:
  stale_artifacts: 0
  pending_compositions: 1
  cache_hit_rate: 0.95
```

The body-schema is the answer to "what can I do right now?" — a unified proprioceptive view that integrates state from every topos into a single snapshot.

## Compound Leverage

### Amplifies Other Topoi

| Topos | How Soma Amplifies |
|-------|-------------------|
| **politeia** | Parousia is subject of sovereignty. Governance acts on embodied presence. |
| **psyche** | Attention requires perceiving presence. Mood affects body-schema. |
| **thyra** | Channels connect to thyra streams. Phasis flows through panels. |
| **nous** | Perception feeds thinking. Semantic search perceives knowledge. |
| **aither** | Channels may bridge to network. Federation perceives remote signals. |

### Cross-Topos Patterns

1. **Embody → Perceive → Think → Express**
   Soma provides the presence loop: arise in oikos, perceive environment, process through nous/psyche, emit response.
   Example: Parousia arises → channel opens → user input perceived → processed → response emitted.

2. **Body-Schema → Affordance → Action**
   Soma's body-schema feeds politeia's affordances. What you can do depends on what channels exist.
   Example: File channel open → "save" affordance appears → user can save.

3. **Channel → Stream → Phasis**
   Soma channels connect to thyra streams. The body's I/O manifests in the portal.
   Example: Text channel → phasis stream → message appears in UI.

4. **Credential → Provider → Inference**
   Credentials topos stores encrypted API keys. When unlocked, the credential's `grants_attainment` enables inference. Provider entities in soma define how to reach the API. Model tier entities auto-resolve via reflexes.
   Example: Anthropic key added → reflex fires → models API queried → tiers populated → inference available.

## Theoria

New theoria crystallized during this design:

### T27: Presence precedes perception

You must be somewhere (embodied as parousia) before you can perceive or act. Embodiment is not optional — it is the precondition for all experience in an oikos.

### T28: Channels are typed attention

A channel is not just a pipe — it is a commitment to perceive a particular modality. Opening a channel declares "I am attending to this." The channel type shapes what can flow through it.

### T29: Body-schema is proprioceptive truth

The body-schema is not documentation — it is the lived reality of "what can I do right now?" It integrates state from across topoi into the answer that precedes every action.

---

*Soma is the body that makes presence possible — the parousia that dwells, the channels that connect, the perception that receives, the phasis that acts. Without body there is no lived experience, only abstract structure.*
