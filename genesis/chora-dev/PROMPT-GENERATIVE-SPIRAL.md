# Generative Development Spiral — Building Out the Full Pattern

*Prompt for Claude Code in the chora + kosmos repository context.*

*Extends the Generative Development Spiral designed in `genesis/demiurge/DESIGN.md`. This prompt is exploratory — the goal is to understand what complete topos development entails and what the spiral needs to cover it.*

---

## Architectural Principle — The Spiral Is How Kosmos Develops Itself

The Generative Development Spiral (demiurge DESIGN.md § The Generative Development Spiral) is the canonical path for topos development:

```
DESIGN.md (human intent)
    ↓ develop-topos-from-design
Design Artifact (structured spec)
    ↓ generate-* for each constituent
Component Artifacts (definitions)
    ↓ review
Human Approval
    ↓ actualize-*
Entities in Kosmos
    ↓ validate-topos
Validated Definitions
    ↓ genesis/emit-topos
Genesis Filesystem
    ↓ crystallize-theoria
Theoria (accumulated understanding)
    ↓ surfaces into future generations
Better Generations...
```

The spiral's aspiration is that topos development happens *within kosmos* — not through Claude Code prompts, but through manteia-governed generation, composition, and the kosmogonia's own practices. Each generation step follows the same three-step pattern: compose inference context → surface theoria → call governed-inference with schema constraint.

**Current state:** The spiral is designed but not implemented. The manteia infrastructure exists (governed-inference, inference contexts). The demiurge composition infrastructure exists (compose, compose-cached). But the praxeis that wire them together (`develop-topos-from-design`, `generate-eidos`, `actualize-*`) are not built. More importantly, the spiral as designed only covers three constituent elements (eidos, praxis, desmos) out of at least twelve that topoi actually contain.

---

## Methodology — Explore, Then Doc, Then Build

This work is exploratory. The methodology is:

1. **Explore**: Understand what complete topos development actually entails — audit existing topoi, identify all constituent element types, understand their generation requirements
2. **Doc (prescriptive)**: Write/update reference docs describing the complete spiral — what it covers, how each element type is generated, what inference contexts it needs
3. **Test/Build**: Implement the spiral praxeis following the standard DDD+TDD cycle

This prompt focuses on phase 1 (exploration) and the beginning of phase 2 (documentation). Implementation is a separate concern once the design is clear.

### What "Reference Doc" Means

Reference docs in this project are *prescriptive* (target state), not descriptive (current state). When code doesn't match a reference doc, the code has a gap — not the doc (unless the design changed). See CONTRIBUTING.md for the full methodology.

---

## Context — What Topoi Actually Contain

### Constituent element types are topos-defined

The set of things a topos can contain is **not a fixed list** — it's extensible through the kosmogonia itself. Certain topoi *introduce* new constituent element types into the vocabulary:

| Topos | Introduces | What It Adds to the Vocabulary |
|-------|-----------|-------------------------------|
| **arche** | eidos, desmos, stoicheion | The grammar — what things are, how they relate, what they do |
| **dynamis** | actuality-mode, reconciler | Substrate bridging — manifest/sense/unmanifest lifecycle |
| **ergon** | trigger, reflex | Autonomic responses — detect/respond to mutations |
| **thyra** | render-spec, mode, widget | Presentation — how entities appear spatially. Mode is topos presence; render-spec is declarative widget tree; widget is leaf primitive. Modes bond to render-specs via `uses-render-spec` and to actuality-modes via `requires-actuality`. |
| **demiurge** | typos, artifact | Composition — how things are made from molds |
| **nous** | theoria | Understanding — crystallized insight that accumulates |
| **manteia** | governed-envelope | Generation — schema-constrained LLM inference |

This means the spiral can't hardcode "generate these 12 types." It must be **parameterized by the target eidos** — the inference context is composed from whatever schema the target eidos defines. Adding a new constituent element type to the kosmogonia means defining its eidos in a topos and adding a `typos-inference-*` context for it. The spiral machinery is the same.

### Current element types in practice

Based on auditing all 30 topoi in genesis, these are the current element types and where they appear:

| Element | Defined By | What It Is | Present In |
|---------|-----------|------------|------------|
| `manifest.yaml` | Constitutional | Identity, dependencies, provides/requires | All topoi (required) |
| `eide/` | arche | Entity type definitions | All topoi (required) |
| `praxeis/` | arche | Executable procedures | All topoi (required) |
| `desmoi/` | arche | Bond type definitions | Most topoi |
| `render-specs/` | thyra | Declarative widget trees for visual presentation | Most topoi |
| `modes/` | thyra | Topos spatial presence — bonds to render-spec + actuality-mode | thyra (could appear in any topos contributing UI) |
| `entities/` | — | Heterogeneous catch-all (see smells below) | Most topoi |
| `typos/` | demiurge | Composition molds with slots | dynamis, thyra, chora-dev, my-nodes |
| `actuality-modes/` | dynamis | Substrate bridges (manifest/sense/unmanifest) | dynamis, thyra |
| `reconcilers/` | dynamis | Declarative drift rules | dynamis (also in entities/ for others) |
| `reflexes/` | ergon | Bonded autonomic responses | thyra (also in entities/ for 9 others) |
| `seeds/` | — | Pre-loaded bootstrap entities | dynamis, propylon |
| `theoria/` | nous | Crystallized understanding | nous, spora |

Note: The legacy panel/renderer/render-type/layout system has been superseded by modes. See `PROMPT-THYRA-PRESENTATION.md` for the cleanup.

### The spiral's current coverage

The demiurge DESIGN.md spiral covers **3 element types** and treats everything else as future work:

| Element | Spiral Coverage | Generate Praxis | Inference Context | Generation Notes |
|---------|----------------|-----------------|-------------------|-----------------|
| Eidos | Designed | `generate-eidos` | `typos-inference-eidos` | One-shot, tight schema |
| Praxis | Designed | `generate-praxis` | `typos-inference-praxis` | One-shot, tight schema |
| Desmos | Designed | `generate-desmos` | `typos-inference-desmos` | One-shot, tight schema |
| Render-spec | **Not covered** | — | — | Composite: widget tree with nested nodes, bindings, conditions. Needs widget vocabulary + target eidos fields as context. |
| Mode | **Not covered** | — | — | Depends on render-spec existing first. Needs spatial vocabulary, actuality-mode catalog. Often generated alongside its render-spec. |
| Typos | **Not covered** | — | — | Composite: slot definitions with fill patterns. Needs target eidos + available query/compose patterns. |
| Actuality-mode | **Not covered** | — | — | Needs substrate vocabulary (operations, config schema). Often paired with reconciler. |
| Reconciler | **Not covered** | — | — | Needs actuality-mode it reconciles + drift detection patterns. |
| Reflex | **Not covered** | — | — | Composite: trigger entity + reflex entity + bonds. Needs mutation event vocabulary + available praxeis. |
| Manifest | **Not covered** | — | — | Derivable from topos content (scan directories, infer dependencies). |
| Seed entities | **Not covered** | — | — | Bootstrap instances of eide — domain-specific, minimal schema constraint. |
| Theoria | Partially (crystallize step) | — | — | Emerges from practice, not generated in the traditional sense. |
| DESIGN.md | Input only | — | — | The human-authored entry point. Could be generated as initial scaffold. |

But because element types are topos-defined, extending coverage is uniform: add a `typos-inference-{element}` that derives its schema constraint from the element's eidos, and the existing `governed-inference` machinery handles the rest.

---

## Smells

### 1. ~~`entities/` is a junk drawer~~ — RESOLVED

**Resolved by:** `PROMPT-TOPOS-DIRECTORY-CONVENTION.md`

**Decision:** Every constituent element type gets its own directory. `entities/` retains only domain-specific seed instances (error catalogs, criteria, onboarding flows, mcp attainment, config entities). The principle: **Directory = Element Type**. When a topos introduces an element type, instances of that type across all topoi get a directory named for the type.

New standard directories: `reflexes/`, `surfaces/`, `daemons/`, `reconcilers/` join existing `eide/`, `desmoi/`, `praxeis/`, `typos/`, `render-specs/`, `actuality-modes/`.

One path, one content type in manifests. ~30 file moves across ~20 topoi. See the convention prompt for full implementation plan.

### 2. Constitutional exceptions are legitimate but should be named

- **arche** — flat YAML files, no directories. Constitutional: defines eidos, desmos, stoicheion, dynamis-interface themselves. Can't follow the standard structure because it IS the standard.
- **spora** — the bootstrap seed (definitions/, journeys/, theoria/, etc.). Not a topos — it's the germination engine that loads content roots and executes bootstrap stages. Its `circles/` directory is documentation only (1 file), not loaded by code. All active definitions and stages use current terminology (oikos, prosopon). Actively consumed by `bootstrap_from_spora()` on every startup.
- **klimax** — numbered directories (1-kosmos through 6-psyche, nous). Cosmological scale hierarchy — organizational, not executable.

These are **correctly exceptional**. The principle: constitutional content (arche, spora) bootstraps the system and therefore can't go through the system it bootstraps. This parallels the session boundary insight — session is the bootstrap substrate, hardcoded because it enables everything else.

### 3. Documentation is outside the graph

DESIGN.md and REFERENCE.md are markdown files, not entities. But T1 says "Documents are composed artifacts." If the spiral is supposed to produce everything a topos needs, documentation should be generatable too — and its provenance should be traceable.

### 4. The reconciliation cycle has no first-class representation

A reconciliation cycle (reflex → reconciler → actuality mode) is a composition of three separate entities that must bond together correctly. But there's no:
- `eidos/reconciliation-cycle` that represents the composite
- Typos for composing a complete cycle from intent
- Validation that ensures all three moments are wired

You have to know to create a trigger, a reflex, bonds between them, a reconciler entity, an actuality-mode, and more bonds. The pieces exist but the composite pattern isn't named or assisted.

### 5. Inconsistent generation granularity

Some things (eidos, praxis) are simple enough to generate in one shot with good schema constraints. Others are composite — they need decomposition into smaller generation steps. The spiral as designed treats everything as one-shot. It doesn't address how to generate composite structures.

**Composite elements that need multi-step generation:**

- **Reconciliation cycle**: trigger entity + reflex entity + reconciler + actuality-mode + bonds between them. Six artifacts that must be consistent with each other.
- **Render-spec**: widget tree with nested nodes, each node having props with `{field}` bindings, `when` conditions, `on_click` praxis references, and `$form.*` accessors. The tree structure must match the target eidos's fields and the available widget vocabulary.
- **Mode + render-spec pair**: a mode references a render-spec by ID and declares spatial position, data source, and actuality requirements. Generating a mode without its render-spec (or vice versa) creates a broken reference. These are often a unit.
- **Reflex**: trigger entity (mutation pattern) + reflex entity (response pattern) + bonds (`watches` from reflex to trigger, `invokes` from reflex to praxis). Three artifacts that must reference each other correctly.

The question is whether to generate these as one rich inference call (with a complex schema constraint) or as a pipeline of smaller calls where each step's output feeds the next step's context.

---

## Exploration Questions

These questions should be investigated before designing the complete spiral:

### On constituent elements

1. **What's the minimum set of generate-* praxeis needed?** Is it one per element type (12), or can some elements be generated together (e.g., reflex + trigger as one unit)?

2. **What's the right decomposition for composite elements?** A reconciliation cycle needs trigger + reflex + reconciler + actuality-mode + bonds. Is this one generation with rich context, or a pipeline of smaller generations?

3. ~~**Should `entities/` be decomposed?**~~ **RESOLVED** — Yes. See Smell #1 resolution and `PROMPT-TOPOS-DIRECTORY-CONVENTION.md`. Each element type gets its own directory. `entities/` retains only domain-specific seed instances.

### On inference contexts

4. **What domain context does each element type need?** Generating an eidos needs the topos purpose and field conventions. Generating a render-spec needs the widget vocabulary and the eidos it renders. Generating a reflex needs the mutation events and available praxeis. Generating a mode needs the spatial position vocabulary, available render-specs, and actuality-mode catalog. Each has different context requirements.

5. **Can theoria actually improve generation quality?** The spiral assumes crystallized understanding surfaces usefully into future generations. Is this validated? What kind of theoria is useful for what kind of generation?

6. **What schema constraints exist for each element type?** Manteia's governed-inference works best with tight schema constraints. Eidos has a clear schema. Reconcilers have a clear schema. Render-specs have a clear schema (widget types as enum, props as typed map, children as recursive nodes, bindings as `{field}` patterns). Modes have a clear schema (spatial position enum, render_spec_id reference, source pattern). What about reflexes (bonded form with trigger entities and multiple bond types)?

### On presentation generation

11. **Can render-specs be generated from eidos fields?** A render-spec for an entity type is primarily a widget tree that displays and edits that type's fields. Given the eidos field schema and the widget vocabulary, can a reasonable default render-spec be generated? What context makes this good vs. mediocre?

12. **Should modes be generated alongside render-specs?** A mode is thin — it references a render-spec and declares spatial position. Generating a mode without its render-spec is meaningless. Should `generate-mode` always compose `generate-render-spec` as a sub-step?

13. **How does the widget vocabulary enter the inference context?** The 35+ widget types have props, children patterns, and binding conventions. This is a large context. Should it be: (a) full widget catalog in every render-spec generation, (b) filtered to relevant widgets based on the target eidos, (c) few-shot examples of existing render-specs for similar eide?

### On the spiral itself

7. **What's the right entry point?** The current spiral starts from DESIGN.md. But sometimes you're adding one praxis to an existing topos, not developing a whole topos. Should there be multiple entry points at different granularities?

8. **How does the spiral handle iteration?** First generation attempt might not be right. How do revisions work? Is it re-generate from scratch, or edit the artifact?

9. **What validates that generated pieces fit together?** A generated reflex references a praxis that might not exist yet. A render-spec references an eidos whose fields might have changed. What's the validation model?

### On the bootstrap exception

10. **Which topoi are constitutional and can't be generated?** Arche and spora are clearly bootstrap. Are there others? What's the principle for "this is constitutional content" vs "this can go through the spiral"?

---

## Investigation Steps

### Step 1: Audit existing topoi for generation patterns

For each of the 12 constituent element types:
- How many instances exist across all topoi?
- How uniform are they? (i.e., would one inference context work for all reconcilers, or do they vary enough to need domain-specific contexts?)
- What fields/structure does each have? (schema constraint input)
- What context would a human need to write one? (inference context design)

### Step 2: Identify composite patterns

Which element types always appear together? For example:
- Does every actuality-mode have a corresponding reconciler?
- Does every reflex reference a praxis that should exist?
- Do render-specs always map 1:1 to eide, or many-to-one?
- Does every mode have exactly one render-spec, or do modes share render-specs?
- Do modes always appear with `uses-render-spec` bonds and optionally with `requires-actuality` bonds?
- When a topos contributes a mode, does it also contribute the render-spec, or can it reference render-specs from other topoi?

### Step 3: Design inference context typoi

For each element type that the spiral should cover, design the `typos-inference-*`:
- `role` — what perspective should the generator take?
- `schema_source` — what constrains the output?
- `constraints` — what guardrails prevent common mistakes?
- `domain_context` — what does the generator need to know? (theoria, existing eide, available stoicheia, etc.)

### Step 4: Prototype one full cycle

Pick one topos element that currently doesn't exist (or a new small topos) and manually walk through the spiral:
1. Write a DESIGN.md fragment
2. Compose the inference context by hand
3. Call governed-inference
4. Review the output
5. Actualize it
6. Validate

Document what worked, what was missing from the context, what the generator got wrong. This is the empirical input for designing the spiral correctly.

### Step 5: Document the complete spiral

Write/update reference docs:
- `docs/reference/generative-development-spiral.md` — the complete specification
- `genesis/demiurge/DESIGN.md` — update the spiral section to cover all element types
- Address the smells: propose standard topos structure, entity/ decomposition policy

---

## Files to Read

### Spiral design (what's already designed)
- `genesis/demiurge/DESIGN.md` § The Generative Development Spiral
- `genesis/manteia/DESIGN.md` § Inference Context Composition
- `genesis/demiurge/praxeis/demiurge.yaml` — existing compose/cache praxeis
- `genesis/manteia/praxeis/manteia.yaml` — governed-inference and generate-* praxeis

### Schema references (for inference context design)
- `genesis/arche/eidos.yaml` — eidos schema (the schema of schemas)
- `genesis/arche/desmos.yaml` — desmos definitions
- `genesis/arche/stoicheion.yaml` — stoicheion (step type) definitions
- `genesis/dynamis/eide/dynamis.yaml` — reconciler eidos
- `genesis/dynamis/actuality-modes/dynamis.yaml` — actuality mode schema

### Existing inference contexts
- `genesis/manteia/entities/` — inference context typos definitions
- `genesis/spora/definitions/core.yaml` — typos-def-* definitions

### Presentation architecture (modes as sole mechanism)
- `genesis/thyra/eide/mode.yaml` — mode and thyra-config eide (the schema for spatial presence)
- `genesis/thyra/desmoi/mode.yaml` — `requires-actuality` and `uses-render-spec` bonds
- `genesis/thyra/entities/layout.yaml` — 6 mode instances + thyra-config/workspace + uses-render-spec bonds
- `genesis/thyra/render-specs/` — 11 declarative widget trees (exemplars for render-spec generation)
- `app/src/lib/layout-engine.tsx` — mode resolution + spatial grouping implementation
- `app/src/lib/render-spec.tsx` — widget tree interpreter (for-each, include, form directives)
- `app/src/lib/widgets/` — 35+ widget types (the vocabulary for render-spec generation context)

### Topos exemplars (for auditing patterns)
- `genesis/dynamis/` — most complete topos (actuality-modes, reconcilers, seeds, typos)
- `genesis/thyra/` — presentation architecture exemplar (modes, render-specs, actuality-modes, reflexes)
- `genesis/hodos/` — minimum viable topos
- `genesis/ergon/` — bonded reflex exemplar
- `genesis/nous/` — theoria exemplar

---

## What This Enables

When the spiral covers all constituent element types:
- **Topos development is a kosmos activity** — not Claude Code prompts, but manteia-governed generation within the kosmogonia
- **Each element type has its own inference context** — generation quality improves because context is domain-appropriate
- **Composite patterns are named and assisted** — a reconciliation cycle is one composition, not six manual steps. A mode + render-spec pair is one generation, not two disconnected ones.
- **Presentation is generatable** — given an eidos and the widget vocabulary, the spiral can generate a render-spec (widget tree with bindings) and a mode (spatial declaration + render-spec reference). A new topos gets UI presence as part of the spiral, not as an afterthought.
- **Theoria accumulates at the element level** — "this render-spec pattern worked well for list views" crystallizes and surfaces in future render-spec generations. "This reflex pattern worked well" does the same for reflexes.
- **The spiral is self-improving** — better theoria → better generations → more theoria
- **Anyone can develop a topos** — not just those who know the YAML conventions by heart
