# Architecture Overview

*How the kosmos is structured and how it works.*

---

## The Klimax

The kosmos builds from container toward contained — six scales, each establishing ambient context for the next:

```
kosmos   — the substrate, entities and bonds
  │
  └─► physis   — the given, constraints and stoicheia
        │
        └─► polis   — the political, oikoi and governance
              │
              └─► oikos   — the household, intimate groupings
                    │
                    └─► soma   — the body, embodiment and sensing
                          │
                          └─► psyche   — the soul, the experiencer
```

By the time psyche arrives, the receiving structure is complete. We dwell in all scales at once.

---

## Two Modes of Being

Everything in the kosmos has two potential modes of being:

| Mode | Greek | Stoicheia | What It Means |
|------|-------|-----------|---------------|
| **Existence** | ὕπαρξις (hyparxis) | arise, find, dissolve | Graph state — the entity record |
| **Actuality** | ἐνέργεια (energeia) | manifest, sense, unmanifest | Phenomena — the living process |

Most eide have only existence. Some have both.

A **daemon** exists (entity in graph) AND is actual (process running). A **theoria** exists but has no actuality — it simply IS.

This distinction is fundamental:
- **Existence** answers: "Is there an entity?"
- **Actuality** answers: "Is the phenomenon happening?"

A daemon entity can exist while its process is stopped. A stream entity can exist while capture is paused. Existence and actuality are independent dimensions.

### Actuality Modes

The actuality mechanism is extensible. Each mode maps to a dynamis module:

| Mode | Manifest | Sense | Unmanifest | Eide |
|------|----------|-------|------------|------|
| `process` | spawn | status | kill | daemon |
| `media` | capture_start | status | stop | stream |
| `network` | connect | connection_status | disconnect | aither-channel |
| `signaling` | connect | poll | close | signaling-session |
| `dns` | create_record | query_record | delete_record | dns-record |

When an eidos declares `actuality.mode`, it gains a second dimension of being.

---

## The Topoi Map

The kosmos is organized into topoi — coherent capability regions. Grouped by klimax scale:

### Kosmos Scale — Substrate

| Topos | Greek | Purpose |
|-------|-------|---------|
| **genesis** | γένεσις | Bootstrap — filesystem-to-graph persistence |
| **stoicheia-portable** | στοιχεῖον | Step vocabulary — atomic operation definitions |
| **dynamis** | δύναμις | Power — substrate capability tiers |
| **demiurge** | δημιουργός | The craftsman — artifact composition, caching |
| **manteia** | μαντεία | Oracle — governed inference, memoization |
| **dokimasia** | δοκιμασία | Validation — provenance, schema, semantics |

### Physis Scale — Constraints

| Topos | Greek | Purpose |
|-------|-------|---------|
| **ergon** | ἔργον | Work — daemons, tasks, reconciliation |
| **ekdosis** | ἔκδοσις | Publication — release of content between oikoi |
| **release** | — | Artifact lifecycle — build to distribution |

### Polis Scale — Governance

| Topos | Greek | Purpose |
|-------|-------|---------|
| **politeia** | πολιτεία | Governance — oikoi, attainments, affordances |
| **hypostasis** | ὑπόστασις | Identity — cryptographic keys, signing, phoreta |
| **credentials** | — | Credentials — external service integration |
| **agora** | ἀγορά | Assembly — embodied gathering of oikos members |

### Oikos Scale — Dwelling

| Topos | Greek | Purpose |
|-------|-------|---------|
| **oikos** | οἶκος | The intimate — sessions, conversations, notes |
| **hodos** | ὁδός | Journeys — structured navigation paths |
| **nous** | νοῦς | The mind — thinking, understanding, theoria |
| **logos** | λόγος | Discourse — intentional utterance and communication |
| **propylon** | πρόπυλον | Gateway — sovereign entry and device federation |

### Soma Scale — Embodiment

| Topos | Greek | Purpose |
|-------|-------|---------|
| **soma** | σῶμα | The body — channels, embodiment, sensing |
| **aither** | αἰθήρ | The ether — WebRTC channels, signaling |
| **my-nodes** | — | Infrastructure — node awareness and management |

### Psyche Scale — Experience

| Topos | Greek | Purpose |
|-------|-------|---------|
| **psyche** | ψυχή | The soul — attention, intention, mood |
| **thyra** | θύρα | The portal — rendering, modes, phaseis |

Each topos contains praxeis that operate within its domain.

---

## The Composition Flow

Everything flows through `demiurge/compose`. This is THE way entities arise.

### The One Interface

```
compose(definition_id, inputs) → entity with provenance
```

### How the Compositor Routes

The compositor examines the definition shape and routes accordingly:

1. **Has `target_eidos`** → Entity composition
   - Creates entity of target type
   - Merges defaults with inputs
   - Establishes provenance bonds

2. **Has `slots`, no `target_eidos`** → Graph composition
   - Composes multiple entities
   - Creates bonds between them
   - Returns the composed graph

3. **Has `template`, no `target_eidos`, no `slots`** → Template rendering
   - Renders template with inputs
   - Returns text or object

### Caller Patterns

Six patterns for how callers prepare inputs:

| Pattern | Description | Pure? |
|---------|-------------|-------|
| `literal` | Baked into defaults | Yes |
| `computed` | Derived from available data | Yes |
| `queried` | Caller queries kosmos first | No |
| `generated` | Caller calls infer first | No |
| `governed` | Caller calls infer with evaluation | No |
| `composed` | Caller composes another artifact | No |

The compositor is simple; complexity lives in the caller.

---

## The Execution Flow

When a praxis is invoked:

```
MCP Tool Call
    │
    ▼
┌─────────────────────┐
│  kosmos-mcp-v8      │  Bridge layer
│  (MCP server)       │
└─────────┬───────────┘
          │
          ▼
┌─────────────────────┐
│  execute_praxis()   │  Interpreter entry point
│  interpreter/mod.rs │
└─────────┬───────────┘
          │
          ▼
┌─────────────────────┐
│  Scope              │  Variable bindings + dwelling context
│  (_prosopon, _oikos,│  Derived from bond graph position
│   _parousia)          │
└─────────┬───────────┘
          │
          ▼
┌─────────────────────┐
│  For each step:     │
│  execute_step()     │  Match on step type
│  interpreter/steps  │
└─────────┬───────────┘
          │
          ▼
┌─────────────────────┐
│  HostContext        │  Substrate operations
│  host.rs            │  (find, arise, bind, etc.)
└─────────────────────┘
```

### Step Execution

Each step in a praxis is a stoicheion invocation:

```yaml
steps:
  - step: find          # Stoicheion: find
    id: "$entity_id"    # Params evaluated from scope
    bind_to: entity     # Result bound to scope

  - step: assert        # Stoicheion: assert
    condition: "$entity"
    message: "Not found"

  - step: return        # Stoicheion: return
    value:
      found: "$entity"
```

The interpreter:
1. Evaluates expressions (`$variable`, `{{ template }}`)
2. Invokes the stoicheion via HostContext
3. Binds results to scope
4. Continues or returns

---

## The Dwelling Model

Context is not passed. Context is position.

### Dwelling Context

When a parousia dwells in an oikos, the interpreter derives ambient bindings:

- `_parousia` — the dwelling parousia entity
- `_prosopon` — the prosopon behind the parousia
- `_oikos` — the oikos being dwelled in
- `_session` — the current session (if any)

These are NOT parameters. They are derived from the bond graph:

```
parousia --[emerges-from]--> prosopon
parousia --[dwells-in]--> oikos
```

### Visibility Is Reachability

You can only perceive what you can reach through bonds. Two bond types define visibility:

| Bond | From → To | Meaning |
|------|-----------|---------|
| `exists-in` | entity → oikos | Where an entity exists — the primary visibility mechanism |
| `member-of` | prosopon → oikos | Formal membership — determines what the prosopon can see |

A prosopon can see an entity if and only if that entity `exists-in` an oikos that the prosopon is `member-of`. Entities with no `exists-in` bonds are visible to nobody — absent from all visible sets.

This is structural, not policy-based:

- Without a bond path, there is no visibility
- No visibility means the query returns nothing
- Not "access denied" — absence

The bond graph IS the access control graph. See [visibility-semantics.md](../reference/dwelling/visibility-semantics.md) for the formal model.

---

## Five Meta-Patterns

These patterns recur across all topoi:

### 1. Narrow Way

Minimal substrate, maximum emergence. The constraint creates the freedom. Add nothing that can be composed from what exists.

### 2. Homoiconicity

The kosmos describes itself in its own terms. Eide, praxeis, and bonds are themselves entities. Self-description closes the loop.

### 3. Performative Bootstrap

Describing IS doing. The specification becomes the thing. Genesis files that describe praxeis ARE the praxeis.

### 4. Fractal Specification

Same shape at all scales. From stoicheion to stratum, the patterns repeat. What works for one entity works for the kosmos.

### 5. Reconciler Pattern

Intent declares what should be. Actuality senses what is. Praxeis align them.

```
┌──────────┐     ┌──────────┐     ┌──────────┐
│  Intent  │────►│ Reconcile│────►│ Actuality│
│  (want)  │     │          │     │   (is)   │
└──────────┘     └──────────┘     └──────────┘
     ▲                                  │
     └──────────────────────────────────┘
              sense → adjust intent
```

For eide with actuality, reconciliation bridges existence and phenomenon.

---

## The Rendering Flow

Entities become visible through rendering. The rendering system follows the homoiconic principle — render configuration is itself entities and bonds.

### Render Entity Stack

```
entity → eidos → render-type → renderer → visual form
                     ↓
                render-spec (if declarative)
                     ↓
                  widget (field-level)
```

### Render Strategies

Renderers declare a strategy that determines how they produce visual output:

| Strategy | Description | Example |
|----------|-------------|---------|
| `declarative` | Template-based, interprets render-spec | Topos-defined entity cards |
| `web-component` | Dynamic custom element loading | External UI packages |
| `wasm` | WASM module execution | Compute-heavy visualizations |

### Declarative Rendering

The declarative strategy enables topoi to own presentation for their eide without code changes. Render-specs use a widget tree — composable, conditional, data-bound:

```yaml
# render-spec/theoria-card
layout:
  - widget: card
    props:
      variant: bordered
      padding: md
    children:
      - widget: stack
        props:
          gap: sm
        children:
          - widget: text
            props:
              content: "{insight}"
              variant: emphasis
          - widget: row
            props:
              gap: sm
            children:
              - widget: badge
                props:
                  content: "{domain}"
                  variant: info
              - widget: badge
                when: "status == 'crystallized'"
                props:
                  content: "Crystallized"
                  variant: success
```

**Data binding:** `{field}` binds to `entity.data.field`. Also `{id}`, `{eidos}`, nested paths `{metadata.created_at}`.

**Conditional rendering:** `when:` on any widget gates its inclusion.

**Field-level iteration:** The `each` property on any widget node repeats children per array item. `{.}` binds to the current item; `{.field}` binds to a field on it. `each_empty` provides a fallback message.

**Entity-level iteration:** Collection modes use `item_spec_id` + `source_query` + `arrangement` to iterate entities and render each via a render-spec. No special widget needed.

### Discovery Flow

Given an entity to render:

1. Get entity's eidos
2. Trace: `eidos ←[applies-to-eidos]— render-types`
3. For each render-type, trace: `render-type —[renders-with]→ renderer`
4. Select renderer by substrate preference
5. If declarative, load associated render-spec
6. Render using selected strategy

**Convention-based fallback:** `render-spec/{eidos}-{variant}` (e.g., `render-spec/theoria-card`)

### Topos Rendering Ownership

Topoi can declare rendering capabilities in their manifest:

```yaml
# topos/ergon/manifest.yaml
provides:
  renderable:
    - eidos: pragma
      description: "Work item cards and lists"
```

The topos then provides render-types and render-specs in its entities directory. Thyra discovers these via graph traversal.

---

## Identity Patterns

Entities have two kinds of identity, determined by their ontological nature:

| Nature | ID Form | What It Means | Examples |
|--------|---------|---------------|----------|
| **Specified** | Semantic | Findable by understanding | `eidos/prosopon`, `praxis/demiurge/compose`, `desmos/is-a` |
| **Occurred** | UUID | Tracked by reference | `parousia/{uuid}`, `session/{uuid}`, `note/{uuid}` |

Semantic IDs are paths of understanding — they enable direct navigation through meaning.

UUID IDs are references to moments — they enable tracing through time.

---

## Coherence Invariants

The kosmos maintains these invariants:

### Structural
- Every entity is an instance of an eidos
- Every bond is an instance of a desmos
- Every praxis dwells in exactly one topos

### Dwelling
- Every parousia emerges from a prosopon
- Every parousia dwells in at least one oikos
- Every oikos has at least one steward

### Compositional
- Every artifact is composed via the one compositional process
- Every eidos specifies how to compose its instances
- Composition is recursive: composed artifacts can be inputs to further composition

### Actuality
- If an eidos declares actuality, instances have two modes of being
- Existence and actuality are independent dimensions
- Reconciler praxeis align existence with actuality

---

## The Authoring Mode

The authoring mode demonstrates the full rendering stack in practice: modes, regions, panels, render-specs, artifact composition, and reactive updates.

### Architecture

```
mode/authoring (active: true)
  │
  └─► region: main
        │
        └─► panel/authoring/phaseis
              render_type: artifact
              config:
                typos_id: typos/authoring-session-view
                watch_eidos: phasis
```

The panel uses `render_type: artifact` — the render-spec passes `config.typos_id` to the artifact widget, which calls `demiurge/compose`.

### Phasis Flow

```
User types in voice bar (phasis-workspace entity)
    │
    ▼
ui/update-entity-field    Local overlay update (no DB roundtrip)
    │
    ▼
User clicks Send
    │
    ▼
ui/express                Creates phasis entity via Tauri
    │
    ▼
WebSocket entity_created  Server broadcasts change
    │
    ▼
onEntityChange            ArtifactWidget subscribes (watch_eidos: phasis)
    │
    ▼
demiurge/compose          Recomposes typos/authoring-session-view
    │
    ▼
ObjectContent renders     Entity cards appear in main area
```

### Key Entities

| Entity | Purpose |
|--------|---------|
| `phasis-workspace/default` | Singleton — voice bar state, draft content |
| `typos/authoring-session-view` | Composition template — gathers phaseis as structured data |
| `panel/authoring/phaseis` | Panel — binds artifact widget to typos via config |
| `render-spec/voice-bar` | Fixture — input + send bound to phasis-workspace |
| `render-spec/artifact` | Generic — passes config.typos_id to artifact widget |

### Two Rendering Patterns

The authoring mode uses both rendering patterns simultaneously:

1. **Live-query** — The voice bar fixture. Bound to `phasis-workspace` entity, handles keystroke-level input via local overlays.

2. **Artifact-based** — The phasis list. Composed via `demiurge/compose` with `output_type: object`, reactively recomposes when phaseis change.

This hybrid approach matches the principle: live panels for interaction, artifact panels for display.

---

*Digested from COSMOLOGY.md — 2026-01-21*
