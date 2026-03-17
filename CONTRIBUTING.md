# Contributing to Kosmos

*Extending the ontological foundation.*

---

## What Lives Here

This repository contains the **genesis layer** — pure YAML and Markdown definitions that constitute the kosmos. All contributions here are ontological: defining what can exist, how things relate, and what operations are possible.

---

## Where Does My Change Go?

| Change Type | Location |
|-------------|----------|
| New topos | `genesis/{topos}/` |
| Eidos definition | `genesis/{topos}/eide/` |
| Desmos (bond type) | `genesis/{topos}/desmoi/` |
| Praxis (operation) | `genesis/{topos}/praxeis/` |
| Typos (mold) | `genesis/{topos}/typos/` |
| Reflex (reactive behavior) | `genesis/{topos}/reflexes/` |
| Render-spec (UI widget) | `genesis/{topos}/render-specs/` |
| Stoicheion schema | `genesis/stoicheia-portable/eide/stoicheion.yaml` |
| Design document | `genesis/{topos}/DESIGN.md` |
| Constitutional document | `genesis/KOSMOGONIA.md` |

---

## Authoring Guides

| Task | Guide |
|------|-------|
| Create a topos | [tutorial/foundations/create-a-topos.md](docs/tutorial/foundations/create-a-topos.md) |
| Write a praxis | [tutorial/foundations/first-praxis.md](docs/tutorial/foundations/first-praxis.md) |
| Define desmoi | [how-to/topos-development](docs/how-to/topos-development/topos-development.md) |
| Author a render-spec | [reference/presentation/render-spec-authoring.md](docs/reference/presentation/render-spec-authoring.md) |
| Understand completeness | [explanation/klimax](docs/explanation/klimax/index.md) |
| Full topos development | [how-to/topos-development](docs/how-to/topos-development/topos-development.md) |

For terminology, see [KOSMOGONIA](genesis/KOSMOGONIA.md).

---

## Structure

```
genesis/
├── KOSMOGONIA.md              # Constitutional root
├── arche/                     # The grammar (eidos, desmos, stoicheion)
├── stoicheia-portable/        # Step definitions
├── spora/                     # Bootstrap seed
├── klimax/                    # Scale documentation
└── {topos}/                   # Per-topos definitions
    ├── manifest.yaml          # Identity, dependencies
    ├── DESIGN.md              # Design rationale
    ├── eide/                  # Entity types
    ├── desmoi/                # Bond types
    ├── praxeis/               # Operations
    ├── typos/                 # Composition molds
    ├── reflexes/              # Reactive behaviors
    └── render-specs/          # UI widget definitions
```

---

## Design Principles

### Templates Are Dumb Molds (GDS)

Typos templates support **only** simple `{{ variable }}` substitution and `{{ var | filter }}` pipes.

**Not supported:** `{{#each}}`, `{{#if}}`, ternary operators, or any block syntax.

Computation lives in **praxis steps**. Templates **only assemble pre-computed values**.

### Render-Specs Are the Model

The render-spec widget system proves GDS for UI:
- `for-each` widget for iteration
- `when:` expressions for conditionals
- `include` widget for composition

### Structural Constraints Over Lint

Prefer schemas that prevent misuse over validators that catch it. Make wrong things unrepresentable rather than representable-but-flagged.

### Push Capability Toward Content

Maximize what lives as topos definitions (YAML). When something can be expressed as eidos/praxis, it should be.

---

## The Dynamis Gradation

| Tier | What It Permits |
|------|-----------------|
| 0 | set, return, assert — pure data flow |
| 1 | filter, map, reduce, sort — aggregation |
| 2 | find, arise, bind, trace, traverse — entity ops |
| 3 | manifest, emit, infer, signal — actuality |

---

## Verification

After authoring genesis YAML, verify by bootstrapping via Thyra. Bootstrap validates all praxis YAML against stoicheion schemas.

---

## Pull Requests

1. **Clear title**: layer + change — `genesis: Add eidos for session recording`
2. **Conventional commits**: `feat:`, `fix:`, `docs:`, `refactor:`
3. **Verify**: Bootstrap should succeed with your changes

---

## Code Style

- **YAML**: 2-space indent, blank lines between entity blocks
- **Commits**: Present tense, imperative — `Add feature` not `Added feature`

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
| prosopon | prosopa | Identity |
| phasis | phaseis | Intentional contribution |

---

## Developer Certificate of Origin

By contributing, you agree to the [DCO](https://developercertificate.org/). Add a sign-off: `git commit -s -m "message"`

---

*The commons stays common.*
