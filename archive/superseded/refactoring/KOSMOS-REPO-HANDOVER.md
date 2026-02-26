# Kosmos Repository Handover

*A creative journey toward separation of world from implementation.*

---

## Ontological Clarity

What we are doing:

1. **Creating entities** — not describing, but composing actual intention, journey, waypoint, prospect, kairos entities in the kosmos. These are not metaphors. They are entities with eidos, data, and bonds.

2. **Following the pattern** — psyche/form-intention → nous/begin-journey → nous/add-waypoint. The praxeis compose entities. The entities track the work.

3. **Working within the world** — not standing outside describing it, but dwelling within it, using its infrastructure to pursue the intention.

What exists (once composed):

| Entity | Eidos | Bonds |
|--------|-------|-------|
| `intention/kosmos-handover` | intention | ← intends (from animus) |
| `journey/kosmos-handover` | journey | → journeys-toward (to intention) |
| `waypoint/survey-landscape` | waypoint | ← contains-waypoint (from journey) |
| `prospect/multiple-implementations` | prospect | ← foresees (from animus) |
| `kairos/v9-complete` | kairos | → opportune-for (to intention) |

These are not descriptions of future entities. They are the entities we compose now to structure the work.

---

## The Intention

To be composed via `psyche/form-intention`:

```yaml
# Entity that will exist in kosmos
- eidos: intention
  id: intention/kosmos-handover
  data:
    description: |
      Separate Kosmos (the world) from Chora (the implementation).
      Create conditions where the ontology can evolve independently,
      where creative journeys happen within Kosmos itself.
    status: active  # Already past forming — we're pursuing this
    priority: 1
    formed_at: 2026-01-27T00:00:00Z
# Bond: animus --intends--> intention/kosmos-handover
```

**This intention is active.** We're not planning to pursue it. We are pursuing it.

---

## The Journey

To be composed via `nous/begin-journey`:

```yaml
# Entity that will exist in kosmos
- eidos: journey
  id: journey/kosmos-handover
  data:
    desire: "Separate Kosmos from Chora so creative journeys can happen within the world itself"
    status: active
    current_waypoint: 0
    embarked_at: 2026-01-27T00:00:00Z
    leverage_type: compound
    leverage_multiplier: "oikos"
    feedback_loop: true
# Bond: journey/kosmos-handover --journeys-toward--> intention/kosmos-handover
```

The journey serves the intention. They are bonded. Progress on the journey is progress toward fulfilling the intention.

---

## The Waypoints

To be composed via `nous/add-waypoint`:

### Waypoint 0: Survey the Landscape

```yaml
- eidos: waypoint
  id: waypoint/kosmos-handover-0
  data:
    ordinal: 0
    description: "Understand what exists, what moves, what stays"
    status: reached
    reached_at: 2026-01-27T00:00:00Z
# Bond: journey/kosmos-handover --contains-waypoint--> waypoint/kosmos-handover-0
```

**Status: Reached.** This document is the yield. We've surveyed the 15 oikoi, ~754 entities, ~239 praxeis.

### Waypoint 1: Prepare Kosmos Repo

```yaml
- eidos: waypoint
  id: waypoint/kosmos-handover-1
  data:
    ordinal: 1
    description: "Create kosmos repository with constitutional content"
    status: pending
# Bond: journey/kosmos-handover --contains-waypoint--> waypoint/kosmos-handover-1
```

Work at this waypoint:
1. Create `kosmos` repository
2. Copy genesis/ directory
3. Copy constitutional documents (KOSMOGONIA, CLAUDE.md, etc.)
4. Set up CI to validate YAML syntax

### Waypoint 2: Wire Chora to Kosmos

```yaml
- eidos: waypoint
  id: waypoint/kosmos-handover-2
  data:
    ordinal: 2
    description: "Make Chora depend on Kosmos"
    status: pending
```

Work at this waypoint:
1. Remove genesis/ from chora (keep symlink for dev)
2. Update bootstrap to read from configurable path
3. Add build step to embed kosmos/genesis into dist/
4. Verify full-circle (emit → bootstrap → emit = identical)

### Waypoint 3: Split Development Workflow

```yaml
- eidos: waypoint
  id: waypoint/kosmos-handover-3
  data:
    ordinal: 3
    description: "Establish where different work happens"
    status: pending
```

| Change Type | Where to Make |
|-------------|---------------|
| New eidos | kosmos/genesis/[oikos]/eide/ |
| New praxis | kosmos/genesis/[oikos]/praxeis/ |
| Interpreter fix | chora/crates/kosmos/src/ |
| UI component | chora/app/src/components/ |
| Design document | kosmos/genesis/[oikos]/DESIGN.md |

### Waypoint 4: Publication Flow

```yaml
- eidos: waypoint
  id: waypoint/kosmos-handover-4
  data:
    ordinal: 4
    description: "CI/CD for both repos working together"
    status: pending
```

```
kosmos → tag → chora updates dependency → build → release
```

---

## Prospects

To be composed via `psyche/foresee`:

```yaml
- eidos: prospect
  id: prospect/multiple-implementations
  data:
    description: "Other languages could interpret Kosmos"
    likelihood: 0.7
    valence: positive
    horizon: far
    noted_at: 2026-01-27T00:00:00Z
# Bond: animus --foresees--> prospect/multiple-implementations

- eidos: prospect
  id: prospect/oikos-marketplace
  data:
    description: "Oikoi shared as packages between circles"
    likelihood: 0.8
    valence: positive
    horizon: near
    noted_at: 2026-01-27T00:00:00Z
# Bond: animus --foresees--> prospect/oikos-marketplace

- eidos: prospect
  id: prospect/documentation-first
  data:
    description: "World described before implemented becomes the norm"
    likelihood: 0.9
    valence: positive
    horizon: immediate
    noted_at: 2026-01-27T00:00:00Z
# Bond: animus --foresees--> prospect/documentation-first
```

These are anticipations. Not predictions, but sense of what might unfold.

---

## Kairos

To be composed via `psyche/recognize-kairos`:

```yaml
- eidos: kairos
  id: kairos/v9-complete
  data:
    description: "V9 migration complete — clean break point for separation"
    for_intention: intention/kosmos-handover
    conditions:
      - "Phase 7 structural normalization done"
      - "Psyche oikos completed"
      - "Creative journey pattern documented"
    recognized_at: 2026-01-27T00:00:00Z
# Bond: animus --recognizes--> kairos/v9-complete
# Bond: kairos/v9-complete --opportune-for--> intention/kosmos-handover
```

**This is the kairos.** The conditions have aligned:
- V9 provides terminology clarity (typos, five archai)
- Psyche provides the full inner life (16 praxeis)
- Soma was already complete (7 praxeis)
- The creative journey pattern shows how they work together
- journeys-toward desmos bridges nous and psyche

The moment is opportune. The work can proceed.

---

## The Vision

**Kosmos** = pure ontology (YAML + Markdown)
**Chora** = implementation (Rust + TypeScript)

Kosmos is the world. Chora makes it breathe.

---

## What Moves to Kosmos

### Constitutional Documents

```
kosmos/
├── KOSMOGONIA.md              # The constitutional root
├── CLAUDE.md                  # Instructions for dwelling
├── ROADMAP.md                 # Development phases
├── ARCHITECTURE.md            # Technical implementation
├── COMPOSITION-GUIDE.md       # How to compose
└── CREATIVE-JOURNEY-PATTERN.md # How psyche+soma+nous work together
```

### Genesis Content

```
kosmos/
└── genesis/
    ├── arche/                 # The five archai
    │   ├── eidos.yaml         # Type definitions
    │   ├── desmos.yaml        # Bond definitions
    │   ├── stoicheion.yaml    # Element definitions
    │   ├── dynamis-interface.yaml
    │   └── functions.yaml
    │
    ├── spora/                 # Bootstrap seed
    │   ├── spora.yaml         # Germination stages
    │   ├── definitions/       # Typos definitions
    │   ├── journeys/          # Learning paths
    │   └── principles/        # Core values
    │
    ├── klimax/                # Scale documentation
    │   ├── 1-kosmos/DESIGN.md
    │   ├── 2-physis/DESIGN.md
    │   ├── 3-polis/DESIGN.md
    │   ├── 4-oikos/DESIGN.md
    │   ├── 5-soma/DESIGN.md
    │   └── 6-psyche/DESIGN.md
    │
    └── [15 oikoi]/            # Domain packages
        ├── manifest.yaml
        ├── DESIGN.md
        ├── eide/
        ├── desmoi/
        └── praxeis/
```

### Oikoi (15 total)

| Oikos | Scale | What It Provides |
|-------|-------|-----------------|
| **nous** | cross-scale | Understanding operations, journeys, theoria |
| **demiurge** | cross-scale | Composition, artifact caching |
| **manteia** | cross-scale | Governed inference |
| **dokimasia** | cross-scale | Validation, testing |
| **hypostasis** | cross-scale | Cryptographic identity, signing |
| **dynamis** | infrastructure | Distribution, substrate bridging |
| **aither** | infrastructure | Network transport, WebRTC |
| **thyra** | infrastructure | Display, rendering, HUD |
| **soma** | embodiment | Channels, percepts, body-schema |
| **psyche** | experience | Attention, intention, mood, thyra, prospect, kairos |
| **oikos** | intimate | Sessions, conversations, notes |
| **politeia** | governance | Circles, personas, attainments |
| **propylon** | entry | Invitations, verification |
| **agora** | spatial | 2D territories, presence |
| **stoicheia-portable** | vocabulary | WASM step definitions |

### Documentation

```
kosmos/
└── docs/
    ├── proposals/             # Future directions
    ├── references/            # Auto-generated API docs
    └── patterns/              # Design patterns
```

---

## What Stays in Chora

### Implementation

```
chora/
├── crates/
│   ├── kosmos/               # Rust interpreter
│   │   ├── src/
│   │   │   ├── interpreter/  # Step execution
│   │   │   ├── bootstrap.rs  # Genesis loading
│   │   │   ├── host.rs       # Substrate interface
│   │   │   └── lib.rs
│   │   └── Cargo.toml
│   │
│   └── kosmos-mcp/           # MCP projection
│       ├── src/
│       │   ├── lib.rs
│       │   ├── main.rs
│       │   └── projection.rs
│       └── Cargo.toml
│
├── app/                      # TypeScript UI
│   ├── src/
│   │   ├── components/
│   │   ├── store/
│   │   └── App.tsx
│   ├── src-tauri/            # Tauri backend
│   └── package.json
│
├── relay/                    # Infrastructure services
│   └── thyra-landing/
│
└── dist/                     # Build outputs
    └── genesis/              # Emitted genesis for distribution
```

### Build System

```
chora/
├── Cargo.toml                # Rust workspace
├── justfile                  # Build commands
├── tauri.conf.json          # App configuration
└── .github/workflows/        # CI/CD
```

---

## The Dependency

```
Chora depends on Kosmos:

chora/
└── genesis/ → symlink or submodule → kosmos/genesis/

or

Bootstrap loads from Kosmos path:
bootstrap_from_manifest("../kosmos/genesis/manifest.yaml")
```

Options:

1. **Symlink**: `chora/genesis/` → `../kosmos/genesis/`
2. **Submodule**: `kosmos` as git submodule in chora
3. **Path config**: Bootstrap reads KOSMOS_PATH env var
4. **Embed at build**: Copy kosmos/genesis into chora/dist at build time

Recommendation: **Option 4** for production (embedded), **Option 1** for development (symlink).

---

## The Handover Process

### Phase 1: Prepare Kosmos Repo

1. Create `kosmos` repository
2. Copy genesis/ directory
3. Copy constitutional documents
4. Set up CI to validate YAML syntax

### Phase 2: Wire Chora to Kosmos

1. Remove genesis/ from chora (except as symlink)
2. Update bootstrap to read from configurable path
3. Add build step to embed kosmos/genesis into dist/
4. Update CI to clone kosmos before build

### Phase 3: Split Development

| Change Type | Where to Make |
|-------------|---------------|
| New eidos definition | kosmos/genesis/[oikos]/eide/ |
| New praxis | kosmos/genesis/[oikos]/praxeis/ |
| Interpreter fix | chora/crates/kosmos/src/ |
| UI component | chora/app/src/components/ |
| Design document | kosmos/genesis/[oikos]/DESIGN.md |

### Phase 4: Publication Flow

```
kosmos repo                      chora repo
    │                                │
    ├── tag v0.2.0                   │
    │                                │
    └──────────────────────────────► update kosmos dependency
                                     │
                                     ├── cargo build
                                     │   (embeds kosmos/genesis)
                                     │
                                     └── release binary
```

---

## Verification

The full-circle test:

```
kosmos/genesis/  →  emit  →  dist/genesis/
                              │
                              ▼
                    bootstrap  →  kosmos.db
                              │
                              ▼
                         emit  →  dist/genesis/
                              │
                              ▼
                    BLAKE3 hash identical? ✓
```

This proves:
1. Kosmos is self-consistent
2. Emission is deterministic
3. No hidden state in implementation

---

## The Numbers (Current State)

| Metric | Count |
|--------|-------|
| Entities at bootstrap | ~754 |
| Bonds | ~1098 |
| Praxeis | ~239 |
| Oikoi | 15 |
| Eide | ~58 |
| Desmoi | ~105 |

All of this is pure YAML + Markdown in Kosmos.

---

## Benefits of Separation

1. **Kosmos evolves independently** — ontology changes don't require Rust rebuilds
2. **Multiple implementations possible** — other languages could interpret Kosmos
3. **Clear contribution paths** — designers work in Kosmos, engineers in Chora
4. **Documentation-first** — the world is described before implemented
5. **Portable oikoi** — domain packages can be shared independently

---

## Timeline

| Phase | Description | Dependencies |
|-------|-------------|--------------|
| 1 | Create kosmos repo, copy content | None |
| 2 | Wire chora to kosmos | Phase 1 |
| 3 | Update development workflow | Phase 2 |
| 4 | CI/CD for both repos | Phase 3 |

This can happen incrementally. Start with Phase 1 — creating the repo and copying content. The rest follows naturally.

---

*Prepared for the separation of world from implementation.*
*Traces to: expression/genesis-root*
