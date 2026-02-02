# Contributing to Chora

*A guide for contributors extending the kosmos.*

---

## The Two Repositories

| Repository | What It Contains | Language |
|------------|------------------|----------|
| **[kosmos](https://github.com/liminalcommons/kosmos)** | The world — ontology, definitions, design docs | YAML + Markdown |
| **[chora](https://github.com/liminalcommons/chora)** | The implementation — interpreter, MCP, UI | Rust + TypeScript |

**Kosmos is the world. Chora makes it breathe.**

```
kosmos/genesis/  →  symlink  →  chora/genesis/  →  bootstrap  →  runtime
```

---

## Where Does My Change Go?

| Change Type | Repository | Location |
|-------------|------------|----------|
| **New oikos** | **kosmos** | `genesis/{oikos}/` (see "How to Create an Oikos") |
| New eidos definition | **kosmos** | `genesis/{oikos}/eide/{oikos}.yaml` |
| New attainment | **kosmos** | `genesis/{oikos}/eide/{oikos}.yaml` (with eide) |
| New desmos definition | **kosmos** | `genesis/{oikos}/desmoi/{oikos}.yaml` |
| New praxis | **kosmos** | `genesis/{oikos}/praxeis/{oikos}.yaml` |
| New stoicheion schema | **kosmos** | `genesis/stoicheia-portable/eide/stoicheion.yaml` |
| Oikos manifest | **kosmos** | `genesis/{oikos}/manifest.yaml` |
| Design document | **kosmos** | `genesis/{oikos}/DESIGN.md` |
| Constitutional document | **kosmos** | `KOSMOGONIA.md`, `ARCHITECTURE.md`, etc. |
| Interpreter bug fix | **chora** | `crates/kosmos/src/` |
| Step implementation | **chora** | `crates/kosmos/src/interpreter/steps.rs` |
| Expression evaluator | **chora** | `crates/kosmos/src/interpreter/expr.rs` |
| MCP projection | **chora** | `crates/kosmos-mcp/src/` |
| UI component | **chora** | `app/src/components/` |
| Build system | **chora** | `Cargo.toml`, `justfile`, CI workflows |

---

## Development Setup

Both repos should be siblings:

```
code/
├── kosmos/     # The world
└── chora/      # The implementation
    └── genesis -> ../kosmos/genesis  # Symlink
```

### Prerequisites

- **Rust** (latest stable): `rustup update stable`
- **Node.js** (20+): For the Tauri frontend
- **SQLite**: System SQLite or bundled via rusqlite
- **MCP client**: Claude Code or compatible client

### Building

```bash
# Build all crates
cargo build

# Run tests
cargo test

# Run Thyra in dev mode
cd app && npm run tauri dev
```

### Running the MCP Server

```bash
cargo run -p kosmos-mcp
```

The MCP server exposes all praxeis as tools that Claude can invoke.

---

## The Kosmos Mental Model

This is not a codebase. This is a world.

When you contribute to Chora, you are extending a **kosmos** — a self-describing living graph where entities and bonds form the substrate of all being.

The kosmos has two foundational premises:

1. **Visibility = Reachability** — You can only perceive what you can cryptographically reach through the bond graph. There is no separate permission layer. The bond graph IS the access control graph.

2. **Authenticity = Provenance** — Everything traces back to signed genesis through composition chains.

Everything is **composed**. Nothing arises raw. This is the fundamental law:

```
compose(definition, inputs) → entity with provenance
```

The compositor is simple; complexity lives in the definition.

---

## Key Concepts

Before contributing, understand these foundational terms. For the constitutional root, see [genesis/KOSMOGONIA.md](genesis/KOSMOGONIA.md).

### Eidos (εἶδος) — Form

The compositional specification for entities of a type. Eidos is self-grounding: the eidos `eidos` specifies how to compose eide. Every entity is an instance of an eidos.

### Desmos (δεσμός) — Bond

The typed relationship between entities. Bonds ARE access — without a bond, there is no path through the graph.

### Stoicheion (στοιχεῖον) — Element

The atomic operation. All action is composed from stoicheia. There are ~30 stoicheia organized by tier:

| Tier | Level | What It Permits |
|------|-------|-----------------|
| **0 (Elemental)** | set, return, assert | Pure data flow, no side effects |
| **1 (Aggregate)** | find, gather, trace, filter, map | Collection and entity operations |
| **2 (Compositional)** | arise, bind, call, switch, for_each | Creation, control flow |
| **3 (Generative)** | infer, embed, http, emit, spawn | External systems, inference |

### Praxis (πρᾶξις) — Action

A composed action made of steps. Each step invokes a stoicheion. A praxis's tier is the maximum tier of its stoicheia.

### Oikos (οἶκος) — Domain

A coherent capability region addressing a specific ontological gap. The kosmos is organized into 20 oikoi:

| Oikos | Greek | Purpose |
|-------|-------|---------|
| **hypostasis** | ὑπόστασις | Identity — cryptographic keys, personas |
| **politeia** | πολιτεία | Governance — circles, attainments, membership |
| **soma** | σῶμα | Body — embodiment, channels, presence |
| **nous** | νοῦς | Mind — theoria, journeys, understanding |
| **demiurge** | δημιουργός | Craftsman — composition, artifacts |
| **manteia** | μαντεία | Oracle — governed inference, generation |
| **oikos** | οἶκος | Dwelling — sessions, notes, personal knowledge |
| **ekdosis** | ἔκδοσις | Publication — content releases, signing |
| **dynamis** | δύναμις | Power — intent/actuality reconciliation |
| **propylon** | πρόπυλον | Gateway — entry, authentication |
| **thyra** | θύρα | Door — streams, expression, emission |
| **ergon** | ἔργον | Work — cross-circle coordination (pragma) |
| **aither** | αἰθήρ | Ether — P2P network, WebRTC |
| **agora** | ἀγορά | Gathering — spatial presence, meetings |
| **dokimasia** | δοκιμασία | Testing — validation before realization |
| **hodos** | ὁδός | Way — navigation through journeys |
| **opsis** | ὄψις | Sight — visual rendering, appearance |
| **release** | — | Distribution — artifact lifecycle |
| **credentials** | — | Access — external service credentials |
| **dns** | — | Naming — DNS infrastructure (thyra sub-module) |

### Dwelling Context

Context is not passed. Context is position. When code executes in the kosmos, it has ambient bindings:

- `_animus` — the dwelling presence
- `_persona` — the identity behind the animus
- `_circle` — the circle being dwelled in

These are derived from bond graph position, not passed as parameters.

---

## Where Things Live

```
chora/
├── genesis/                     # Symlink to kosmos/genesis
│   ├── KOSMOGONIA.md           # Constitutional root
│   ├── arche/                  # The grammar (eidos, desmos, stoicheion)
│   └── [oikos]/                # Domain packages
│       ├── eide/
│       ├── desmoi/
│       └── praxeis/
│
├── crates/                     # Rust implementation
│   ├── kosmos/                # The interpreter
│   │   └── src/
│   │       ├── interpreter/   # Praxis execution
│   │       ├── host.rs        # HostContext API
│   │       └── bootstrap.rs   # Genesis loading
│   └── kosmos-mcp/            # MCP server bridge
│
├── app/                        # Thyra (Tauri app)
│   ├── src/                   # TypeScript/SolidJS frontend
│   └── src-tauri/             # Rust backend
│
└── CONTRIBUTING.md             # This file
```

---

## How to Add a Praxis

Praxeis are the unit of action.

### 1. Choose the Right Oikos

- Session management → `oikos`
- Understanding crystallization → `nous`
- Governance → `politeia`
- Inference orchestration → `manteia`

### 2. Write the Praxis YAML

Add your praxis to `genesis/[oikos]/praxeis/[oikos].yaml`:

```yaml
- eidos: praxis
  id: praxis/{oikos}/{name}
  data:
    oikos: {oikos}
    name: {name}
    visible: true                    # Expose as MCP tool?
    description: |
      What this praxis does.
    params:
      - name: param_name
        type: string
        required: true
        description: What this param is for
    steps:
      - step: assert
        condition: "$param_name"
        message: "param_name is required"

      - step: arise
        eidos: {target_eidos}
        id: "entity/{{ now() }}"
        data:
          field: "$param_name"
        bind_to: created_entity

      - step: return
        value:
          entity_id: "$created_entity.id"
```

### 3. Test via MCP

After rebuilding, your praxis appears as an MCP tool:

```
Use tool: {oikos}_{name}
With params: { "param_name": "test" }
```

---

## How to Add a Stoicheion

Stoicheia are atomic operations. Adding one follows the schema-driven pattern.

### 1. Define in genesis/stoicheia-portable/eide/stoicheion.yaml

```yaml
- eidos: stoicheion
  id: stoicheion/my_step
  data:
    name: my_step
    tier: 1
    description: What this stoicheion does.
    fields:
      input_name:
        type: string
        required: true
      bind_to:
        type: string
        required: false
```

### 2. Regenerate Types

Run `cargo build` — the `build.rs` script reads `stoicheion.yaml` and generates `step_types.rs`.

### 3. Implement Execution

In `crates/kosmos/src/interpreter/steps.rs`:

```rust
impl MyStepStep {
    pub fn execute(&self, scope: &mut Scope, ctx: &StepContext<'_>) -> Result<StepResult> {
        let input = scope.eval(&self.input_name)?;
        let result = /* ... */;

        if let Some(ref bind) = &self.bind_to {
            scope.set(bind.clone(), result.clone());
        }

        Ok(StepResult::Continue)
    }
}
```

**Key Principle**: If the generated types are wrong, fix `stoicheion.yaml` — never edit `step_types.rs` directly.

---

## How to Create an Oikos

An oikos is a coherent capability region addressing a specific **ontological gap** — what becomes possible that wasn't before?

### When to Create a New Oikos

Ask: *Does this address a genuinely distinct gap, or is it the same gap viewed differently?*

**Create a new oikos when:**
- The gap is ontologically distinct (e.g., "here ↔ there" is different from "ignorance ↔ understanding")
- The eide are genuinely different entity types, not variations
- The attainments grant distinct capabilities

**Don't create a new oikos when:**
- It's a method within an existing domain (synthesis is a method of understanding → belongs in nous)
- It's the dynamis pattern applied to an existing domain (connection state → belongs in aither)

### Oikos Directory Structure

```
genesis/{oikos}/
├── DESIGN.md           # Ontological purpose, circle context, completeness
├── manifest.yaml       # v2.1 format declaring what the oikos provides
├── eide/
│   └── {oikos}.yaml    # Entity types + attainments
├── desmoi/
│   └── {oikos}.yaml    # Bond types (if any)
└── praxeis/
    └── {oikos}.yaml    # Operations
```

### Step 1: Write the DESIGN.md

Every oikos needs a design document explaining its purpose. Follow this template:

```markdown
# {Oikos} Design

{Greek} ({transliteration}) — {meaning}

## Ontological Purpose

What gap in being does this oikos address?
What becomes possible that wasn't before?

## Circle Context

### Self Circle
How does a solitary dweller use this?

### Peer Circle
How do collaborators use this together?

### Commons Circle
How does this serve a community?

## Core Entities (Eide)

### {eidos-name}
- Fields and their purpose
- Lifecycle (how instances arise, change, depart)

## Bonds (Desmoi)

### {desmos-name}
- from/to eidos
- Cardinality
- Traversal semantics

## Operations (Praxeis)

### {praxis-name}
- What it does
- When to use it
- What it requires (attainments, context)

## Attainments

### attainment/{name}
- What capability it grants
- Which praxeis it gates
- Scope (soma, circle, animus)

## Embodiment

### Completeness Status
| Level | Status |
|-------|--------|
| Defined | ⏳/✅ |
| Loaded | ⏳/✅ |
| Projected | ⏳/✅ |
| Embodied | ⏳/✅ |
| Surfaced | ⏳/✅ |
| Afforded | ⏳/✅ |

## Compound Leverage

How does this oikos amplify other oikoi?
```

### Step 2: Write the Manifest (v2.1 Format)

The manifest declares what the oikos provides:

```yaml
# Manifest v2.1 format
format_version: "2.1"
oikos_id: {oikos}
version: "0.1.0"

oikos_name: {Name}
oikos_description: |
  {Greek} ({transliteration}) — {meaning}

  What gap this oikos addresses.
  Why it's distinct from other oikoi.

oikos_scale: {soma|circle|animus|cross-scale}

content_paths:
  - path: eide/
    content_types: [eidos, attainment]
  - path: desmoi/
    content_types: [desmos]
  - path: praxeis/
    content_types: [praxis]

depends_on:
  - {other-oikos}    # Oikoi this one requires

requires_dynamis:
  - db.find
  - db.arise
  - db.bind
  # ... dynamis capabilities needed

provides:
  eide:
    - {eidos-name}
    - {eidos-name}

  attainments:
    - {attainment-name}

  desmoi:
    - {desmos-name}    # Only if this oikos defines bonds

  praxeis:
    - {oikos}/{praxis-name}
    - {oikos}/{praxis-name}
```

### Step 3: Define Eide and Attainments

In `genesis/{oikos}/eide/{oikos}.yaml`:

```yaml
entities:
  # Entity type definition
  - eidos: eidos
    id: eidos/{entity-name}
    data:
      name: {entity-name}
      description: |
        What this entity type represents.
      fields:
        field_name:
          type: string|integer|boolean|timestamp|enum|array|object
          required: true|false
          default: {value}           # Optional
          enum: [value1, value2]     # For enum type
          description: "What this field is"
      actuality:                     # Optional: for entities with external state
        mode: {actuality-mode}

  # Attainment definition (in same file)
  - eidos: attainment
    id: attainment/{name}
    data:
      name: {name}
      description: |
        What capability this attainment grants.
      oikos: {oikos}
      scope: soma|circle|animus
      grants:
        - praxis/{oikos}/{praxis-name}
        - praxis/{oikos}/{praxis-name}
```

**Attainment scopes:**
- `soma` — substrate-local (network interfaces, file system)
- `circle` — shared within a circle (governance, shared data)
- `animus` — personal to the dwelling presence (navigation state)

---

## How to Define Desmoi

Desmoi (bonds) define typed relationships between entities. Not all oikoi need desmoi — only define them if your oikos introduces new relationship types.

### When to Define Desmoi

- Your entities have relationships that don't exist in other oikoi
- The relationship has specific semantics (cardinality, traversal meaning)
- You need to query/traverse these relationships

### Desmos Format

In `genesis/{oikos}/desmoi/{oikos}.yaml`:

```yaml
# Bond type definitions
- id: {desmos-name}
  description: |
    What this bond represents.
    When it's created and what it means for traversal.
  from_eidos: [{source-eidos}, ...]
  to_eidos: [{target-eidos}, ...]
  cardinality: one-to-one|one-to-many|many-to-one|many-to-many

- id: {another-desmos}
  description: |
    Another bond type.
  from_eidos: [any]        # 'any' means any eidos can be source
  to_eidos: [{target}]
  cardinality: many-to-one
```

### Example: ergon Desmoi

```yaml
- id: signals-to
  description: |
    Pragma signals to a circle for attention.
    The target circle is where the capability exists to resolve it.
  from_eidos: [pragma]
  to_eidos: [circle]
  cardinality: many-to-one

- id: evidenced-by
  description: |
    Pragma is evidenced by an entity — the thing that demonstrates the gap.
  from_eidos: [pragma]
  to_eidos: [any]
  cardinality: many-to-many

- id: blocks
  description: |
    Pragma blocks another pragma — dependency relationship.
  from_eidos: [pragma]
  to_eidos: [pragma]
  cardinality: many-to-many

- id: resolves
  description: |
    Entity resolves a pragma — the fix that addressed it.
  from_eidos: [any]
  to_eidos: [pragma]
  cardinality: many-to-one
```

### Using Bonds in Praxeis

Create bonds with `bind` step:
```yaml
- step: bind
  from_id: "$pragma_id"
  to_id: "$circle_id"
  desmos: "signals-to"
```

Query bonds with `trace` step:
```yaml
- step: trace
  to_id: "$circle_id"
  desmos: "signals-to"
  direction: "inbound"
  bind_to: all_pragma
```

---

## How to Define Attainments

Attainments gate capabilities. They're defined alongside eide in the same file.

### Attainment Structure

```yaml
- eidos: attainment
  id: attainment/{name}
  data:
    name: {name}
    description: |
      What capability this attainment grants.
      Who should have it and why.
    oikos: {oikos}           # Which oikos this belongs to
    scope: soma|circle|animus
    grants:
      - praxis/{oikos}/{praxis-1}
      - praxis/{oikos}/{praxis-2}
```

### Scope Guidelines

| Scope | Meaning | Example |
|-------|---------|---------|
| `soma` | Substrate-local operations | Network connections, file I/O |
| `circle` | Shared within circle | Governance, shared data |
| `animus` | Personal to dwelling presence | Navigation state, workspace |

### Example: Multiple Attainments

```yaml
# From release/eide/release.yaml
- eidos: attainment
  id: attainment/release
  data:
    name: release
    description: |
      Release management — creating and tracking releases.
    oikos: release
    scope: circle
    grants:
      - praxis/release/create-release
      - praxis/release/register-artifact
      - praxis/release/mark-built
      - praxis/release/list-releases
      - praxis/release/get-release

- eidos: attainment
  id: attainment/distribute
  data:
    name: distribute
    description: |
      Distribution capability — uploading to channels.
      Tier-3 operations that manifest artifacts externally.
    oikos: release
    scope: circle
    grants:
      - praxis/release/distribute
      - praxis/release/sense-release
      - praxis/release/reconcile-release
```

---

## Oikos Completeness Levels

An oikos progresses through levels of aliveness:

| Level | What It Means | How to Verify |
|-------|---------------|---------------|
| **Defined** | Eide, desmoi, praxeis exist in YAML | Files exist, manifest declares them |
| **Loaded** | Bootstrap loads into kosmos.db | `cargo run -p kosmos-mcp` succeeds |
| **Projected** | MCP projects praxeis as tools | Tools appear in MCP client |
| **Embodied** | Body-schema reflects capabilities | `sense-body` shows attainments |
| **Surfaced** | Reconciler notices relevant actions | Opportunities appear in context |
| **Afforded** | Thyra UI presents contextual actions | UI shows affordances |

### Defined Level Checklist

For an oikos to be "Defined complete":

- [ ] `DESIGN.md` exists and follows template
- [ ] `manifest.yaml` exists in v2.1 format
- [ ] `manifest.yaml` declares all eide, attainments, desmoi, praxeis
- [ ] `eide/{oikos}.yaml` defines all declared eide
- [ ] `eide/{oikos}.yaml` defines all declared attainments with scope + grants
- [ ] `desmoi/{oikos}.yaml` defines all declared desmoi (if any declared)
- [ ] `praxeis/{oikos}.yaml` defines all declared praxeis

**Design complete** = manifest declares what the oikos provides
**Implementation complete** = YAML files implement what's declared

### Verifying Completeness

```bash
# Check if bootstrap loads the oikos
cd chora
cargo run -p kosmos-mcp

# In MCP client, test a praxis
{oikos}_{praxis-name} with params...
```

---

## The Three Development Pillars

Every contribution must align with:

| Pillar | What It Means | Violation Example |
|--------|---------------|-------------------|
| **Schema-driven** | Types come from YAML, not hand-written | Adding a Rust struct for a new entity type |
| **Graph-driven** | Relationships are bonds, not embedded IDs | Storing `parent_id` on an entity |
| **Cache-driven** | Same inputs = same output | Non-deterministic code in composition |

---

## Common Mistakes

### 1. Editing generated code

**Wrong**: Editing `step_types.rs`
**Right**: Edit `stoicheion.yaml` and rebuild

### 2. Adding Rust for schema concerns

**Wrong**: "I need a new entity type, let me add a struct..."
**Right**: Define eidos in YAML. The interpreter is generic.

### 3. Bypassing composition

**Wrong**: Inserting entities directly into the database
**Right**: Use `arise` step. Everything is composed.

### 4. Local state in UI

**Wrong**: `useState` for data that should live in kosmos
**Right**: Store in kosmos, render from subscription

### 5. Creating unnecessary oikoi

**Wrong**: Creating a new oikos for every feature
**Right**: Ask "Is this a distinct ontological gap?" — methods belong in their parent oikos

### 6. Manifest without implementation

**Wrong**: Declaring praxeis in manifest but not creating YAML files
**Right**: Everything declared in `provides:` must have corresponding definitions

### 7. Attainments without grants

**Wrong**: Defining attainments without specifying which praxeis they grant
**Right**: Every attainment needs `scope` and `grants` list

### 8. Storing relationships as fields

**Wrong**: Adding `parent_id` field to an eidos
**Right**: Use desmoi (bonds) for relationships — they're traversable

---

## Testing

```bash
# Rust tests
cargo test --package kosmos

# Integration: bootstrap and invoke praxeis
cargo run -p kosmos-mcp

# App dev mode
cd app && npm run tauri dev
```

---

## Pull Request Guidelines

1. **Clear title**: What layer + what change
   - `genesis: Add artifact-definition for session recording`
   - `kosmos: Fix yaml_encode for nested objects`

2. **Use conventional commits** for changelog generation:
   - `feat:` for new features
   - `fix:` for bug fixes
   - `docs:` for documentation
   - `refactor:` for code changes that don't add features or fix bugs

3. **Verify build**:
   ```bash
   cargo build && cargo test
   cd app && npm run build
   ```

---

## Code Style

### Rust
- Follow `rustfmt` conventions
- Use `thiserror` for error types
- Prefer `Result<T>` over panics

### YAML (Genesis Files)
- 2-space indentation
- Entity blocks separated by blank lines

### Commits
- Present tense, imperative mood
- `Add feature` not `Added feature`

### Signed Commits (Optional but Encouraged)

GPG-signed commits provide cryptographic proof of authorship:

```bash
# Generate a GPG key (if you don't have one)
gpg --full-generate-key

# Configure Git to use your key
git config --global user.signingkey YOUR_KEY_ID
git config --global commit.gpgsign true

# Sign a commit manually
git commit -S -m "feat: add new feature"
```

GitHub shows a "Verified" badge on signed commits. [Setup guide](https://docs.github.com/en/authentication/managing-commit-signature-verification).

---

## Release Process

Releases are automated via [release-please](https://github.com/googleapis/release-please).

### How It Works

1. **Make commits** with conventional commit messages (`feat:`, `fix:`, `docs:`, etc.)
2. **Push to main** — release-please automatically creates/updates a Release PR
3. **Merge the Release PR** — this triggers:
   - Version bump across all files (Cargo.toml, package.json, tauri.conf.json, etc.)
   - Changelog update
   - Git tag creation
   - Multi-platform build (macOS, Windows, Linux)
   - Upload to R2 and GitHub Releases

### Conventional Commit Types

| Type | Description | Changelog Section |
|------|-------------|-------------------|
| `feat:` | New feature | Features |
| `fix:` | Bug fix | Bug Fixes |
| `perf:` | Performance improvement | Performance |
| `refactor:` | Code refactoring | Refactoring |
| `docs:` | Documentation | Documentation |
| `chore:` | Maintenance | (hidden) |
| `ci:` | CI/CD changes | (hidden) |

### Version Bumping

- `fix:` commits bump the patch version (0.9.0 → 0.9.1)
- `feat:` commits bump the minor version (0.9.0 → 0.10.0)
- `feat!:` or `BREAKING CHANGE:` bumps major version (0.9.0 → 1.0.0)

### Release Channels

| Channel | Version Format | Who Gets It |
|---------|---------------|-------------|
| **Beta** | `0.9.0-beta.1` | Testers, early adopters |
| **Stable** | `1.0.0` | General availability |

Currently all releases are beta (`prerelease: true` in release-please config). To switch to stable releases:

1. Edit `release-please-config.json`:
   ```json
   "prerelease": false
   ```
2. The next release will be a stable version (e.g., `1.0.0`)

The landing page (`thyra.liminalcommons.com`) automatically detects the release type from the version string and displays the appropriate channel badge.

### Manual Release (Emergency Only)

If release-please fails, use the deprecated manual process:

```bash
just version-bump 0.9.2-beta.1
git commit -am "chore: release 0.9.2-beta.1"
git tag v0.9.2-beta.1
git push && git push --tags
```

---

## Terminology

Greek for being, English for doing.

| Singular | Plural | Meaning |
|----------|--------|---------|
| eidos | eide | Form, type |
| desmos | desmoi | Bond |
| stoicheion | stoicheia | Element, step |
| praxis | praxeis | Action |
| oikos | oikoi | Domain |
| kosmos | kosmoi | World |

---

## Developer Certificate of Origin

By contributing to this project, you agree to the Developer Certificate of Origin (DCO). Add a sign-off to your commits:

```bash
git commit -s -m "Your commit message"
```

Full DCO text: https://developercertificate.org/

---

## Philosophy

Chora is liberation infrastructure for sovereign dwelling.

- **Sovereignty over platforms** — Each chora is cryptographically sovereign
- **Federation over centralization** — Peer-to-peer, no central authority
- **Ownership over extraction** — Your data, your keys, your relationships

When you contribute, you extend this sovereignty for everyone who will dwell here.

---

*The commons stays common.*
