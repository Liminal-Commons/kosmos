# CLAUDE.md

This is **kosmos** — the world as pure ontology (YAML + Markdown).

The implementation lives in [chora](https://github.com/liminalcommons/chora).

---

##Screenshots dir: /Users/victorpiper/Desktop/screenshots

---

## The Two Repositories

| Repository | What It Contains |
|------------|------------------|
| **kosmos** (here) | The world — eide, desmoi, praxeis, design docs |
| **chora** | The implementation — interpreter, MCP, UI |

**Kosmos is the world. Chora makes it breathe.**

Chora depends on kosmos via symlinks: `chora/genesis → ../kosmos/genesis`, `chora/docs → ../kosmos/docs`

---

## Context

You are working in the genesis layer — the constitutional definitions of the kosmos.

Genesis is the source of truth. Definitions here ARE the kosmos.

For shared development methodology (DDD+TDD, prescriptive principle, three pillars), see chora's [CLAUDE.md](https://github.com/liminalcommons/chora/blob/main/CLAUDE.md). For contribution guidelines, see [CONTRIBUTING.md](CONTRIBUTING.md).

---

## Key Documents

| Document | Purpose |
|----------|---------|
| [KOSMOGONIA.md](genesis/KOSMOGONIA.md) | Constitutional root — ontology and principles |
| [docs/index.md](docs/index.md) | Documentation portal (Diataxis) |
| [genesis/ROADMAP.md](genesis/ROADMAP.md) | Development phases |

### Diataxis Documentation

| Category | Key Docs |
|----------|----------|
| **Tutorial** | [Create a Mode](docs/tutorial/presentation/create-a-mode.md), [Create Your First Reflex](docs/tutorial/reactivity/create-your-first-reflex.md) |
| **How-To** | [Topos Development](docs/how-to/topos-development/topos-development.md), [Mode Development](docs/how-to/presentation/mode-development.md) |
| **Explanation** | [Architecture](docs/explanation/architecture.md), [Oikos Guide](docs/explanation/oikos/index.md), [Klimax](docs/explanation/klimax/index.md) |
| **Reference** | [Composition](docs/reference/composition.md), [Topos Map](docs/reference/domain/topos-map.md), [Theoria Index](genesis/nous/theoria/INDEX.md) |

---

## The Archai

Five foundational forms define what can exist (see [KOSMOGONIA](genesis/KOSMOGONIA.md) § The Five Archai):

| Arche | File | What It Defines |
|-------|------|-----------------|
| **Eidos** | `arche/eidos.yaml` | Entity types — what things ARE |
| **Typos** | `{topos}/typos/` | Molds — HOW things are made |
| **Desmos** | `arche/desmos.yaml` | Bond types — how things RELATE |
| **Stoicheion** | `stoicheia-portable/eide/stoicheion.yaml` | Step types — what things DO |
| **Dynamis** | Tier annotations | Power — substrate capability stoicheia draw upon |

---

## Structure

```
genesis/
├── KOSMOGONIA.md           # Constitutional root (read this first)
├── ROADMAP.md              # Development phases
│
├── arche/                  # The grammar of being
│   ├── eidos.yaml          # Entity types
│   └── desmos.yaml         # Bond types
│
├── stoicheia-portable/     # Step definitions
│   └── eide/
│       └── stoicheion.yaml # Stoicheion definitions (schema source)
│
├── spora/                  # The seed — germination sequence
│   └── spora.yaml          # Bootstrap: arche + topos content roots
│
└── {topos}/                # Per-topos definitions
    ├── DESIGN.md            # Design rationale
    ├── manifest.yaml        # Content paths declaration
    ├── eide/                # Entity type definitions
    ├── desmoi/              # Bond definitions
    ├── praxeis/             # Step sequences
    └── typos/               # Composition molds
```

---

## Design Principles

These principles guide authoring in kosmos. They operationalize the constitution established in [KOSMOGONIA](genesis/KOSMOGONIA.md).

### Templates Are Dumb Molds (GDS)

Typos templates support **only** simple `{{ variable }}` substitution and `{{ var | filter }}` pipes.

**Not supported:** `{{#each}}`, `{{#if}}`, `{{/each}}`, ternary operators (`? :`), block conditionals (`{{ if $var }}...{{ end }}`), or any Handlebars/Jinja block syntax.

### The GDS Principle (Graph-Data-Slots)

Computation lives in **praxis steps**. Templates **only assemble pre-computed values**.

```
❌  Template with computation (conditionals, loops, branching)
✅  Praxis computes → slots receive finished values → template assembles
```

**For iteration:** Use `for_each` in praxis steps to build arrays, or `for-each` widget in render-specs.

**For conditionals:** Use `switch`/`set` in praxis steps to prepare the right value, or `when:` on typos slots to gate inclusion. In render-specs, use `when:` on widgets.

**For formatting:** Use praxis steps (`map`, `set`, `join()`) to prepare formatted strings before passing to the template.

### Anti-Patterns in Typos

| Pattern | Problem | Fix |
|---------|---------|-----|
| `{{#each items}}` | Block helpers unsupported | Praxis `for_each` + pass result to slot |
| `{{#if condition}}` | Block conditionals unsupported | Praxis `switch`/`set` or slot `when:` |
| `$x ? 'a' : 'b'` | Ternary unsupported | Praxis `switch` step |
| `{{ items \| map_list() }}` | Complex filter chains | Praxis `map` step |
| `<script>` in template | Embedded JS | Use render-spec with widgets |

### Render-Specs Are the Model

The render-spec widget system proves the GDS pattern for UI:
- `for-each` widget = iteration (not template loops)
- `when:` expressions = conditionals (not template branches)
- `include` widget = composition (not template partials)

Apply the same principle to all composition domains: configs, documents, prompts.

### Fix at Generation Level

When generated code is wrong, fix the schema or generator — never the output. Generated artifacts have provenance headers pointing to their source. Edit the source.

### Full-Circle Genesis

The kosmos can emit itself, re-bootstrap from emission, and emit again with identical output. `emit → bootstrap → emit` = same BLAKE3 hash. This is self-verifying coherence. Constitutional content uses literal fill only. Derivable content is baked before emission.

### Structural Constraints Over Lint

Prefer schemas that prevent misuse over validators that catch it after the fact. Make wrong things unrepresentable rather than representable-but-flagged.

### Push Capability Toward Content

Maximize what lives as topos definitions (YAML). Minimize what requires Rust (interpreter) or TypeScript (UI). When something can be expressed as eidos/praxis, it should be.

---

## The Dynamis Gradation

| Tier | Dynamis | What It Permits |
|------|---------|-----------------|
| 0 | None | set, return, assert — pure data flow |
| 1 | None | filter, map, reduce, sort — aggregation |
| 2 | Kosmos | find, arise, bind, trace, traverse — entity ops |
| 3 | Chora | manifest, emit, infer, signal — actuality |

---

## Validation

After authoring genesis YAML, verify via chora:

```bash
just dev    # In chora — clean DB, bootstrap, launch Thyra
```

Bootstrap validates all praxis YAML against stoicheion schemas. For praxis authoring patterns, see [tutorial/foundations/first-praxis.md](docs/tutorial/foundations/first-praxis.md). For composition patterns, see [reference/composition.md](docs/reference/composition.md).
