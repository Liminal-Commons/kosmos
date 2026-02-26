# Diataxis Experience Layer — Tutorials and How-To Guides

*Prompt for Claude Code in the chora + kosmos repository context.*

*The knowledge layer (reference + explanation docs) has been audited and restructured by PROMPT-DIATAXIS-KNOWLEDGE.md. This prompt addresses the experience layer: tutorials that teach, and how-to guides that solve tasks. These docs must be verified against reality — every step must work, every name must match current vocabulary, every pattern must reflect the system as it stands.*

*Prerequisite: PROMPT-DIATAXIS-KNOWLEDGE.md must be complete (directory restructuring done, reference docs audited).*

---

## Methodology — Prescriptive Experience

Docs are **prescriptive** — they describe the experience we want developers to have, not the experience they currently get. When a tutorial step doesn't work, that's a gap in the system — unless the tutorial is teaching an outmoded pattern, in which case the tutorial needs to prescribe the right experience first.

Experience docs are also **empirically testable**. A tutorial says "run this command and you'll see X." A how-to guide says "to achieve Y, do these steps." If the steps don't work, the system has a gap to fix.

The cycle:

1. **Read the doc**: What experience does it prescribe? What does it teach?
2. **Is that the experience we want?** Does it teach current patterns — or outmoded ones (dissolved widgets, stale vocabulary, superseded architecture)?
3. **Fix the doc if the target is wrong**: If the tutorial teaches an outmoded pattern, rewrite it to prescribe the desired experience. Docs lead, system follows.
4. **Execute the steps**: Does the system support the prescribed experience? Do commands work, outputs match?
5. **Fix the system where steps fail**: If a prescribed step doesn't work, the system has a gap. Fix it. If the gap is too large, mark the step as prescriptive and note the gap explicitly.
6. **Verify end-to-end**: Re-execute. Every step must work.

### What "Tutorial" and "How-To" Mean (Diataxis)

**Tutorial** = learning-oriented. Takes the reader by the hand. Has a definite start and end. The reader learns by doing. Assumes no prior knowledge of the topic. The author controls what happens at every step.

**How-To** = task-oriented. Assumes the reader knows what they want to achieve. Gives practical steps to solve a specific problem. The reader brings context; the doc provides the recipe.

Tutorials teach concepts through experience. How-to guides assume concepts and provide recipes.

---

## Context — What Exists

### Current Tutorials (5)

| File | Topic | Concern Domain |
|------|-------|---------------|
| `first-praxis.md` | Create a praxis from scratch, test via MCP | foundations |
| `create-an-oikos.md` | Build a topos with eide, praxeis, bonds | foundations |
| `create-your-first-reflex.md` | Create a notification reflex | reactivity |
| `first-phasis.md` | Navigate phasis lifecycle (draft → commit) | foundations |
| `create-a-mode.md` | Build a mode with list/detail views | presentation |

### Current How-To Guides (13)

| File | Topic | Concern Domain |
|------|-------|---------------|
| `oikos-development.md` | Complete topos development guide | topos-development |
| `schema-graph-cache.md` | Three pillars methodology guide | topos-development |
| `mode-development.md` | Mode recipes (singleton/collection/compound) | presentation |
| `modes/voice-authoring.md` | Voice/text composition modes | presentation |
| `modes/form-based-mode.md` | Form patterns and bindings | presentation |
| `modes/create-artifact-mode.md` | Artifact-based modes with typos | presentation |
| `define-custom-triggers.md` | 9 reactive trigger patterns | reactivity |
| `create-daemon.md` | Declare supervised processes | reactivity |
| `compose-artifact.md` | Instantiate artifacts from definitions | composition |
| `crystallize-theoria.md` | Create theoria entities | composition |
| `create-note.md` | Create note entities | composition |
| `operations.md` | Operational patterns, bootstrap, federation | operations |
| `developer-onboarding.md` | Federate developers into kosmos | operations |

### Naming / Vocabulary Concern

The transition from earlier naming conventions to current vocabulary may not have propagated uniformly across all docs. Example: "oikos-development" in a doc titled for topos development. During the audit phase, every doc must be checked for:

- Entity type names (eidos names must match current genesis)
- Bond type names (desmos names must be current)
- Praxis names and parameters
- Field names on entity types
- Conceptual vocabulary (e.g., "oikos" vs "topos" vs "dwelling" usage)
- Dissolved patterns that no longer exist (panels, renderers, for-each widget, render-type, include widget)

---

## Directory Restructuring — Tutorial and How-To

### Target: tutorial/

```
tutorial/
├── foundations/               Core concepts for newcomers
│   ├── first-praxis.md            Create a praxis (atom-level)
│   ├── first-phasis.md            Navigate phasis lifecycle
│   └── create-an-oikos.md         Build a topos (container-level)
│
├── presentation/              Making things visible
│   └── create-a-mode.md           Build a mode with views
│
└── reactivity/                Making things respond
    └── create-your-first-reflex.md  Create an autonomic reflex
```

5 files across 3 subdirs. Each subdir maps to a concern domain. A newcomer entering `tutorial/` sees three clear paths.

### Target: how-to/

```
how-to/
├── topos-development/         Building and structuring topoi
│   ├── oikos-development.md       Complete topos development
│   └── schema-graph-cache.md      Three pillars methodology
│
├── presentation/              Modes, render-specs, widgets
│   ├── mode-development.md        Mode recipes and patterns
│   ├── voice-authoring.md         (from modes/)
│   ├── form-based-mode.md         (from modes/)
│   └── create-artifact-mode.md    (from modes/)
│
├── reactivity/                Triggers, reflexes, daemons
│   ├── define-custom-triggers.md  Trigger patterns
│   └── create-daemon.md           Supervised processes
│
├── composition/               Artifacts, theoria, notes
│   ├── compose-artifact.md        Instantiate from definitions
│   ├── crystallize-theoria.md     Create theoria entities
│   └── create-note.md             Create note entities
│
└── operations/                Deployment, onboarding, bootstrap
    ├── operations.md              Operational patterns
    └── developer-onboarding.md    Federation and entry
```

13 files across 5 subdirs. The `modes/` subdir is dissolved — its files move into `presentation/` alongside `mode-development.md`, which is their natural sibling.

---

## Gap Analysis

### What may prescribe an outmoded state

| Doc | Risk | What Changed |
|-----|------|-------------|
| `create-a-mode.md` | May reference panels, renderers, pre-mode-absorbed patterns | Mode-Absorbed Iteration |
| `mode-development.md` | May not reflect singleton/collection/compound mode types | Mode-Absorbed Iteration |
| `modes/*.md` | May reference dissolved for-each/include widgets | Mode-Absorbed Iteration |
| `define-custom-triggers.md` | May not reflect reflex→reconciler wiring | Reactive Loop |
| `create-daemon.md` | May not reflect host.reconcile() or actuality dispatch | Reactive Loop |
| `oikos-development.md` | May use stale vocabulary, may not reflect generative proof | Multiple arcs |
| `compose-artifact.md` | May not reflect resolve_slot bug fixes | Generative Proof |

### What doesn't exist but should

| Doc | Quadrant | Target Location | Why It's Needed |
|-----|----------|----------------|----------------|
| Wiring a Reconciliation Cycle | How-To | `how-to/reactivity/wire-reconciliation-cycle.md` | The composite pattern has no task-oriented guide |
| Using Generation Praxeis | How-To | `how-to/composition/use-generation.md` | Generation works but no one knows how to invoke it |
| Generating Instead of Writing | Tutorial | `tutorial/generation/generating-instead-of-writing.md` | The spiral is proven but has no teaching path |
| Self-Healing Entities | Tutorial | `tutorial/reactivity/self-healing-entities.md` | Reconciliation cycle has no learning path |

These four new docs correspond to the three-level model:
- **Atom-level**: existing tutorials cover well (praxis, reflex, mode)
- **Molecule-level**: reconciliation cycle and generation pipeline need both tutorials and how-to guides
- **Factory-level**: the generative spiral needs a tutorial showing it in action

---

## Implementation Order

### Phase 0: Restructure Tutorial and How-To Directories

Move files into concern-domain subdirectories as specified above.

1. Create target subdirectories under `tutorial/` and `how-to/`
2. Move files (git mv to preserve history)
3. Dissolve `how-to/modes/` — move its files into `how-to/presentation/`
4. Update all internal cross-references
5. Update `docs/index.md` and `docs/REGISTRY.md`
6. Verify no broken links

**Do NOT change file content** — only move files and update references.

### Phase 1: Audit Every Tutorial

For each tutorial, apply the prescriptive experience cycle:

1. **Read the tutorial end-to-end** — what experience does it prescribe?
2. **Is this the experience we want?** Does it teach current patterns — or outmoded ones? (Dissolved widgets, panel-based modes, pre-reactive-loop patterns are outmoded.)
3. **Check vocabulary**: Do all entity names, bond names, field names match current genesis definitions? Naming must reflect the desired state, not a historical one.
4. **Execute each step**: Does the system support the prescribed experience? Commands work, outputs match?
5. **Note gaps**: Where the tutorial prescribes the right experience but steps fail, the system has a gap. Where the tutorial prescribes the wrong experience, the tutorial needs rewriting.
6. **Status**: CURRENT (prescribes right experience, steps work), OUTMODED (teaches superseded patterns), GAP (right experience but system doesn't support it), INCOMPLETE (right direction but missing coverage)

Update REGISTRY.md with status.

**Priority** (most likely outmoded):
- `create-a-mode.md` — most affected by Mode-Absorbed Iteration
- `create-your-first-reflex.md` — may not reflect reactive loop changes

### Phase 2: Fix Outmoded Tutorials

For each tutorial marked OUTMODED or INCOMPLETE:

1. Determine the **desired experience** — what should this tutorial teach? (Read completed prompt docs, current genesis, and code to understand the target.)
2. Rewrite the tutorial to prescribe the desired experience — steps, outputs, vocabulary, patterns
3. Remove all references to dissolved patterns (these are outmoded — don't preserve them even as context)
4. **Execute the rewritten tutorial** end-to-end — does the system support it?
5. Where steps fail, **fix the system** to match the prescribed experience. The doc leads.
6. Where the gap is too large to fix, mark the step as prescriptive and note the gap explicitly.

Each tutorial is a self-contained fix.

### Phase 3: Audit Every How-To Guide

Same prescriptive cycle as Phase 1, but for how-to guides:

1. Read the guide — what task does it help accomplish? Is that the right task?
2. Does it prescribe the desired approach — or an outmoded one?
3. Check vocabulary against current genesis
4. Execute recipe steps — does the system support the prescribed task?
5. Note gaps (system vs doc)
6. Status: CURRENT, OUTMODED, GAP, or INCOMPLETE

**Priority** (most likely outmoded):
- `mode-development.md` — most affected by Mode-Absorbed Iteration
- `modes/*.md` (now `presentation/*.md`) — may reference dissolved widgets
- `oikos-development.md` — broad scope, likely has vocabulary drift

### Phase 4: Fix Outmoded How-To Guides

For each guide marked OUTMODED or INCOMPLETE:

1. Determine the **desired task flow** — what should accomplishing this task look like?
2. Rewrite recipes to prescribe the desired approach
3. Remove dissolved patterns, add new capabilities
4. Execute recipes — fix the system where it doesn't support the prescribed flow
5. Verify that each recipe produces the described result

### Phase 5: Write New Experience Docs

Create the four docs identified in the gap analysis:

**`how-to/reactivity/wire-reconciliation-cycle.md`** — Molecule-level how-to
- When to use: entity needs self-healing (desired vs actual state)
- Steps: create reconciler entity → define transitions → create actuality-mode → wire trigger + reflex → test the cycle
- References: `reference/elements/composite-patterns.md`, `reference/reactivity/reconciliation.md`
- Example: wiring reconciliation for a deployment entity

**`how-to/composition/use-generation.md`** — Using the spiral how-to
- When to use: you want to generate a definition instead of writing it manually
- Steps: identify the generate-* praxis → prepare inputs (eidos, context) → invoke → validate output → review the entity
- References: `reference/generation/generation.md`
- Example: generating a render-spec for an entity type

**`tutorial/generation/generating-instead-of-writing.md`** — Factory-level tutorial
- Teaches: the generative spiral through direct experience
- Flow: start with an entity type → observe that it has no render-spec → invoke generation → inspect the result → understand what happened
- Prerequisite: `tutorial/foundations/first-praxis.md`
- References: `explanation/generation/generative-spiral.md`

**`tutorial/reactivity/self-healing-entities.md`** — Molecule-level tutorial
- Teaches: the reconciliation cycle through direct experience
- Flow: create an entity with desired_state/actual_state → introduce drift (manually change actual_state) → observe reconciliation → understand the pattern
- Prerequisite: `tutorial/reactivity/create-your-first-reflex.md`
- References: `explanation/reactivity/reconciler-pattern.md`

### Phase 6: Update REGISTRY.md and Index

1. REGISTRY.md: add new docs, update all paths
2. `docs/index.md`: rewrite tutorial and how-to sections to reflect subdirectory organization
3. Verify all cross-references resolve
4. Verify every tutorial and how-to guide links to the correct reference and explanation docs (the knowledge layer)

---

## Files to Read

### Existing docs (audit targets)
- All 5 tutorials in `docs/tutorial/`
- All 13 how-to guides in `docs/how-to/` (including `modes/` subdir)
- `docs/index.md` — entry point organization
- `docs/REGISTRY.md` — impact map and status

### Current reality (verify tutorial steps against)
- Genesis definitions for every entity type mentioned in tutorials
- `crates/kosmos/src/host.rs` — reconcile(), praxis execution
- `app/src/lib/layout-engine.tsx` — mode rendering (singleton, collection, compound)
- `app/src/lib/render-spec.tsx` — widget dispatch
- `crates/kosmos/src/interpreter/steps.rs` — composition pipeline
- `crates/kosmos/src/reflex.rs` — reflex engine
- `crates/kosmos/src/reconciler.rs` — reconciler engine

### Genesis vocabulary (verify names against)
- `genesis/arche/eide/` — core eide definitions
- `genesis/arche/desmoi/` — core bond types
- `genesis/ergon/eide/` — trigger, reflex eide
- `genesis/dynamis/eide/` — reconciler, actuality-mode, deployment eide
- `genesis/thyra/eide/` — mode, render-spec eide
- `genesis/demiurge/eide/` — typos eide

### Prompt docs (completed work to reference)
- `genesis/chora-dev/PROMPT-REACTIVE-LOOP.md` — reactive loop findings
- `genesis/chora-dev/PROMPT-MODE-ABSORBED-ITERATION.md` — mode system changes
- `genesis/chora-dev/PROMPT-GENERATIVE-PROOF.md` — generation findings
- `genesis/chora-dev/PROMPT-DIATAXIS-KNOWLEDGE.md` — companion prompt (directory structure, three-level model)

---

## Success Criteria

**Phase 0 Complete When:**
- [ ] Tutorial files organized into `foundations/`, `presentation/`, `reactivity/` subdirs
- [ ] How-to files organized into 5 concern-domain subdirs
- [ ] `how-to/modes/` dissolved into `how-to/presentation/`
- [ ] `docs/index.md` and `docs/REGISTRY.md` reflect new paths
- [ ] No broken cross-references

**Phase 1-2 Complete When:**
- [ ] Every tutorial audited against prescriptive experience cycle
- [ ] Every tutorial prescribes the desired experience (no outmoded patterns)
- [ ] No tutorial references dissolved patterns (panels, renderers, for-each, include, render-type)
- [ ] All vocabulary matches current genesis definitions
- [ ] Every tutorial step produces the described output (system gaps fixed or marked prescriptive)
- [ ] REGISTRY.md status current for all tutorials

**Phase 3-4 Complete When:**
- [ ] Every how-to guide audited against prescriptive cycle
- [ ] Every guide prescribes the desired task flow (no outmoded approaches)
- [ ] No guide references dissolved patterns or stale vocabulary
- [ ] Every recipe step produces the described result (system gaps fixed or marked prescriptive)
- [ ] REGISTRY.md status current for all how-to guides

**Phase 5 Complete When:**
- [ ] `how-to/reactivity/wire-reconciliation-cycle.md` exists and works
- [ ] `how-to/composition/use-generation.md` exists and works
- [ ] `tutorial/generation/generating-instead-of-writing.md` exists and works
- [ ] `tutorial/reactivity/self-healing-entities.md` exists and works
- [ ] Each new doc links to appropriate knowledge-layer docs

**Phase 6 Complete When:**
- [ ] REGISTRY.md includes all new docs with correct paths
- [ ] `docs/index.md` reflects concern-domain organization for tutorials and how-tos
- [ ] Every tutorial/how-to cross-references the correct reference and explanation docs
- [ ] All cross-references resolve

**Overall Complete When:**
- [ ] A developer opening `tutorial/` sees 3 clear concern-domain paths
- [ ] A developer opening `how-to/` sees 5 clear concern-domain clusters (≤5 files each)
- [ ] Every tutorial teaches through working steps — no step fails
- [ ] Every how-to recipe produces the described result
- [ ] No experience doc references dissolved patterns or stale vocabulary
- [ ] The three-level model (atoms → molecules → factory) has teaching and task-solving coverage at every level
- [ ] Experience docs link to knowledge-layer docs (reference + explanation) for deeper understanding

---

*Tutorials and how-to guides are the experience layer. They don't describe or explain — they teach and guide. When these docs work, a developer builds correct understanding through direct experience.*
