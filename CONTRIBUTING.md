# Contributing to Chora

*A gateway for contributors extending the kosmos.*

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
| New topos | **kosmos** | `genesis/{topos}/` |
| Eidos / attainment / desmos | **kosmos** | `genesis/{topos}/eide/` or `desmoi/` |
| Praxis | **kosmos** | `genesis/{topos}/praxeis/` |
| Stoicheion schema | **kosmos** | `genesis/stoicheia-portable/eide/stoicheion.yaml` |
| Design document | **kosmos** | `genesis/{topos}/DESIGN.md` |
| Constitutional document | **kosmos** | `KOSMOGONIA.md`, `ARCHITECTURE.md` |
| Interpreter / host | **chora** | `crates/kosmos/src/` |
| MCP projection | **chora** | `crates/kosmos-mcp/src/` |
| UI component | **chora** | `app/src/` |
| Build system | **chora** | `Cargo.toml`, `justfile`, CI workflows |

---

## Development Setup

Both repos should be siblings:

```
code/
├── kosmos/     # The world
└── chora/      # The implementation
    ├── genesis -> ../kosmos/genesis
    └── docs    -> ../kosmos/docs
```

### Prerequisites

- **Rust** (latest stable): `rustup update stable`
- **Node.js** (20+): For the Tauri frontend
- **SQLite**: System SQLite or bundled via rusqlite

### Justfile Commands

All builds go through the justfile. No exceptions.

| Command | What It Does |
|---------|--------------|
| `just dev` | Clean DB → sync genesis → tauri dev (hot reload) |
| `just local` | Clean DB → validate genesis → build release → install to /Applications |
| `just prod` | Validate genesis → build release → install (preserves DB) |
| `just run` | Launch installed app |
| `just serve` | Run kosmos-mcp standalone |
| `just clean-db` | Delete `~/Library/Application Support/kosmos/kosmos.db` |
| `just clean-all` | Delete database + all build artifacts |
| `just validate-genesis` | Check genesis symlink is valid |

### Testing

```bash
cargo test --package kosmos    # Rust tests
cargo test --package kosmos-mcp  # MCP tests
just dev                       # Full integration via Thyra
```

---

## Development Methodology — DDD + TDD

All work follows **Doc-Driven Development + Test-Driven Development**:

1. **Doc** — Read the reference doc. If it doesn't prescribe the target state, write it.
2. **Test** — Write tests asserting documented behavior (they should fail).
3. **Build** — Implement until tests pass.
4. **Align** — Check [REGISTRY.md](docs/REGISTRY.md) impact map. Update stale docs.

**The Prescriptive Principle**: Docs describe the state we *want*, not the state we have. When code diverges from a doc, the code has a gap — not the doc.

See chora's [CLAUDE.md](https://github.com/liminalcommons/chora/blob/main/CLAUDE.md) for the full methodology.

---

## How-To Guides

Detailed authoring guides live in the docs. CONTRIBUTING stays thin — these links are canonical.

| Task | Guide |
|------|-------|
| Create a topos | [tutorial/foundations/create-a-topos.md](docs/tutorial/foundations/create-a-topos.md) |
| Write a praxis | [tutorial/foundations/first-praxis.md](docs/tutorial/foundations/first-praxis.md) |
| Define desmoi | [how-to/topos-development/topos-development.md](docs/how-to/topos-development/topos-development.md) § Desmoi |
| Define attainments | [reference/authorization/attainment-authorization.md](docs/reference/authorization/attainment-authorization.md) |
| Add a stoicheion | [reference/elements/constituent-elements.md](docs/reference/elements/constituent-elements.md) |
| Create a mode | [tutorial/presentation/create-a-mode.md](docs/tutorial/presentation/create-a-mode.md) |
| Author a render-spec | [reference/presentation/render-spec-authoring.md](docs/reference/presentation/render-spec-authoring.md) |
| Understand completeness | [explanation/klimax/index.md](docs/explanation/klimax/index.md) |
| Full topos development | [how-to/topos-development/topos-development.md](docs/how-to/topos-development/topos-development.md) |

For terminology, see [KOSMOGONIA](genesis/KOSMOGONIA.md). For the topos map, see [reference/domain/topos-map.md](docs/reference/domain/topos-map.md).

---

## Where Things Live

```
chora/
├── genesis/                     # Symlink to kosmos/genesis
│   ├── KOSMOGONIA.md           # Constitutional root
│   ├── arche/                  # The grammar (eidos, desmos, stoicheion)
│   └── {topos}/                # Per-topos definitions
│       ├── DESIGN.md
│       ├── manifest.yaml
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
├── app/                        # Thyra (Tauri + SolidJS)
│   ├── src/                   # TypeScript frontend
│   └── src-tauri/             # Rust backend
│
└── CONTRIBUTING.md             # This file
```

---

## The Three Pillars

| Pillar | Principle | Violation Example |
|--------|-----------|-------------------|
| **Schema-driven** | Types from YAML, not hand-written | Adding a Rust struct for a new entity type |
| **Graph-driven** | Relationships are bonds, not embedded IDs | Storing `parent_id` on an entity |
| **Cache-driven** | Same inputs = same output | Non-deterministic code in composition |

---

## Common Mistakes

1. **Editing generated code** — `step_types.rs` is generated from `stoicheion.yaml`. Fix the schema.
2. **Adding Rust for schema concerns** — Entity types are defined in YAML. The interpreter is generic.
3. **Bypassing composition** — Use `arise` step (via `compose`). Everything is composed.
4. **Local state in UI** — Store in kosmos, render from subscription. Not `useState`.
5. **Creating unnecessary topoi** — Ask: "Is this a distinct ontological gap?" Methods belong in their parent topos.
6. **Manifest without implementation** — Everything declared in `provides:` must have YAML definitions.
7. **Storing relationships as fields** — Use desmoi (bonds). They're traversable.
8. **Hardcoding eide in the interpreter** — All entities render through render-specs. No `if (eidos === "...")`.

---

## Pull Requests

1. **Clear title**: layer + change — `genesis: Add eidos for session recording`
2. **Conventional commits**: `feat:`, `fix:`, `docs:`, `refactor:`
3. **Verify build**: `cargo build && cargo test`

---

## Release Process

Releases use [release-please](https://github.com/googleapis/release-please). Push conventional commits to main → release-please creates a Release PR → merge triggers version bump, changelog, tag, multi-platform build, and upload.

| Commit Type | Version Bump | Example |
|-------------|-------------|---------|
| `fix:` | Patch (0.9.0 → 0.9.1) | Bug fixes |
| `feat:` | Minor (0.9.0 → 0.10.0) | New features |
| `feat!:` / `BREAKING CHANGE:` | Major (0.9.0 → 1.0.0) | Breaking changes |

---

## Code Style

- **Rust**: `rustfmt`, `thiserror` for errors, `Result<T>` over panics
- **YAML**: 2-space indent, blank lines between entity blocks
- **Commits**: Present tense, imperative — `Add feature` not `Added feature`
- **Signed commits**: Optional but encouraged. See [GitHub docs](https://docs.github.com/en/authentication/managing-commit-signature-verification).

---

## Terminology

Greek for being, English for doing.

| Singular | Plural | Meaning |
|----------|--------|---------|
| eidos | eide | Form, type |
| desmos | desmoi | Bond |
| stoicheion | stoicheia | Element, step |
| praxis | praxeis | Action |
| topos | topoi | Capability domain |
| oikos | oikoi | Social dwelling |
| kosmos | kosmoi | World |

---

## Developer Certificate of Origin

By contributing, you agree to the [DCO](https://developercertificate.org/). Add a sign-off: `git commit -s -m "message"`

---

*The commons stays common.*
