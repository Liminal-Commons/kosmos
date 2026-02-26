# The Generative Spiral

*Why kosmos generates itself, and the three-level architecture that makes it possible.*

---

## The Three Levels

The kosmos operates at three conceptual levels, each building on the one below:

### Level 1: Constituent Elements (Atoms)

The building blocks. Twelve element types — eidos, desmos, stoicheion, praxis, render-spec, mode, widget, trigger, reflex, reconciler, daemon, typos — each introduced by a foundational topos. These are the primitives from which everything is composed.

At this level, a developer hand-writes YAML definitions in genesis. An eidos declares what can exist. A desmos declares how things relate. A render-spec declares how something looks. Each definition is precise, structural, and static.

### Level 2: Composite Patterns (Molecules)

Recurring compositions of atoms that solve real problems. A presentation pair (render-spec + mode + bond) makes an entity visible. A detection pair (trigger + reflex + bonds) makes the system react. A reconciliation cycle (trigger + reflex + reconciler + mode) makes entities self-healing.

At this level, a developer doesn't think in individual elements — they think in patterns. "I need this entity to be visible" triggers composing a presentation pair. "I need this to react to changes" triggers composing a detection pair.

### Level 3: The Generative Spiral (Factory)

The mechanism by which the kosmos produces atoms and molecules. Rather than hand-writing every render-spec, every eidos, every praxis, the developer describes intent — and the kosmos generates the definition through governed inference.

The spiral:
1. **Compose context** — Fill an inference context typos with inputs (what to generate, for which eidos, with what purpose)
2. **Governed inference** — LLM generates a structured output constrained by `output_schema`
3. **Validate** — Structural checks ensure the output is well-formed
4. **Actualize** — The generated artifact becomes an entity in the graph

The spiral is self-reinforcing: generated render-specs can be used to display entities that were themselves generated. Generated praxeis can invoke generation of further elements. The kosmos can extend itself.

---

## Why Generation Is Necessary

Generation is not a convenience feature. It's architecturally necessary for three reasons:

### 1. Combinatorial Explosion

A topos with 10 eide, each needing 3 render-spec variants (card, detail, item), requires 30 render-specs. Each must correctly reference the eidos fields, use appropriate widgets, and follow binding syntax. Hand-writing all 30 is tedious and error-prone. Generating them from the eidos schema is precise.

### 2. Schema Consistency

When an eidos gains a new field, every render-spec that targets it should potentially display that field. Generation from the eidos schema ensures consistency — the render-spec is always derived from the current field set, not from a stale copy.

### 3. The Kosmos Constituting Itself

The deepest reason: if the kosmos is truly self-describing (homoiconic), then the process of creating new descriptions should itself be describable within the kosmos. Generation praxeis are entities. Inference contexts are composed from typos. The generation pipeline is graph-traversable. The kosmos doesn't just contain its own description — it contains the machinery for extending that description.

---

## The Constitutional Exception

Not everything can go through the generative spiral. The foundational elements — arche desmoi, the eidos eidos, the stoicheia that implement `compose` and `governed-inference` — must exist before generation can occur. These are constitutional: they bootstrap the system.

The boundary: anything in `genesis/arche/` and `genesis/stoicheia-portable/` is constitutional and hand-authored. Everything else can potentially be generated — though in practice, many definitions are still hand-authored because they're simple enough not to need inference.

---

## Theoria Accumulation

Each generation run can produce theoria — crystallized understanding about what worked and what didn't. The generative proof (T9, T10) demonstrated that `output_schema` via tool_use is more reliable than prompt instructions. This theoria feeds back into the inference contexts, improving future generation.

The spiral metaphor is precise: each revolution produces elements + understanding. The understanding improves the next revolution. The kosmos becomes better at generating itself.

---

## Cross-References

- [Generation Reference](../../reference/generation/generation.md) — Specific praxeis, inference contexts, and validation rules
- [Schema Enforcement](schema-enforcement.md) — T9: why output_schema beats prompt instructions
- [Constituent Elements](../../reference/elements/constituent-elements.md) — The twelve atom types
- [Composite Patterns](../../reference/elements/composite-patterns.md) — The molecules composed from atoms
