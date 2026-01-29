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
| New eidos definition | **kosmos** | `genesis/[oikos]/eide/` |
| New desmos definition | **kosmos** | `genesis/[oikos]/desmoi/` |
| New praxis | **kosmos** | `genesis/[oikos]/praxeis/` |
| New stoicheion schema | **kosmos** | `genesis/stoicheia-portable/eide/stoicheion.yaml` |
| Design document | **kosmos** | `genesis/[oikos]/DESIGN.md` |
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

A coherent capability region. The kosmos is organized into oikoi:

| Oikos | Purpose |
|-------|---------|
| **nous** | The mind — thinking, understanding, theoria |
| **soma** | The body — sensing, channels, embodiment |
| **thyra** | The portal — streams, expressions, emission |
| **demiurge** | The craftsman — artifact composition |
| **politeia** | Governance — circles, attainments |
| **manteia** | Oracle — governed inference |
| **psyche** | The soul — attention, intention |
| **aither** | The ether — WebRTC channels, signaling |

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
