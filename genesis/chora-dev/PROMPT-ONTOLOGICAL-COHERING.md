# PROMPT: Ontological Cohering of Host Modules

**Reshapes mechanically extracted modules into ontologically coherent dimensions. Two merges, zero absorptions, zero functional changes. Every file gets a reason to exist that traces to what dimension of the world it serves.**

**Depends on**: PROMPT-HOST-DECOMPOSITION.md (mechanical extraction complete, 365 tests pass)
**Pattern**: Pure refactoring — rename + merge files, update module declarations, verify tests

---

## The Principle: Modules Have Identity, Not Just Function

When a codebase decomposes by implementation similarity — "these functions call the same API, group them" — the result is files named after *what the code does*: `embedding.rs`, `inference.rs`, `signal.rs`. Each file works. None has a reason to exist beyond "these functions were similar."

When a codebase decomposes by ontological dimension — "what aspect of the world does this serve?" — each file has an identity that constrains what belongs in it and what doesn't. A function doesn't go in `nous.rs` because it "looks like" the other functions there. It goes in `nous.rs` because it participates in the host's capacity for understanding. That's a different kind of coherence.

The mechanical decomposition already happened. It works. Tests pass. But:

- **embedding.rs** and **inference.rs** are split because they call different APIs (OpenAI vs Anthropic). Ontologically they're one thing: the host's mind. Perception (aisthesis — embed, surface) and reasoning (manteia — infer) are two facets of nous.

- **signal.rs** and **reconciler.rs** are split because their code looks different (WebRTC stubs vs JSON matching). Ontologically they're one thing: the responsive loop. Signal propagates change; reconciler helpers match transitions. Both serve the reflex dimension.

- **command_template.rs** appears to be a "separate concern." Ontologically it's an energeia mechanism — how cargo entities actualize through template interpolation + shell execution, parallel to how dns.rs is an energeia mechanism for DNS entities. It already has the right relationship to host.rs (dispatched from energeia, returns results). It stays where it is, understood as a mechanism within actuality.

- **emission.rs** already has the right identity. Its doc header says "Ekthesis — Emission to Chora." It stays.

- **graph.rs** already has the right identity. Entities, bonds, traversal, visibility — κόσμος structure. It stays.

The principle: **organize by what dimension of the world this serves, not by what API it calls or what the code looks like.** Implementation similarity is accidental. Ontological dimension is essential.

---

## What "Ontological Dimension" Means Here

The host (HostContext) is where κόσμος meets χώρα. Its internal structure should articulate the dimensions of that meeting:

| Module | Dimension | What it is |
|--------|-----------|------------|
| **host.rs** | The host itself | Identity (SessionBridge), will (praxis invocation), energeia (actuality orchestration), reflex (reconciliation + response) |
| **graph.rs** | κόσμος structure | How entities exist, how bonds connect, how the graph is navigated — the world's substance and relations |
| **nous.rs** | The host's mind | Perception (embed, surface) and the oracular (infer, infer_structured) — unified because both are the host engaging with understanding |
| **emission.rs** | Ekthesis | How the world writes artifacts to chora's filesystem |
| **command_template.rs** | Energeia mechanism | Template-driven actuality — how cargo entities actualize via interpolation + shell execution |
| **reflex.rs** | The responsive loop | Signal propagation (aither) + transition matching — how the world reacts to change |

Six files, each with an ontological identity. Not seven mechanical extractions.

---

## The Two Merges

### Merge 1: embedding.rs + inference.rs → nous.rs

**Why**: Both are the host's engagement with external intelligence. Splitting by API provider (OpenAI for embeddings, Anthropic for inference) is an implementation detail, not an ontological boundary. The host has one mind, not two.

**Internal structure**: Two clearly labeled sections preserving the existing ontological terms:

```rust
// nous.rs — the host's mind
//
// Aisthesis (perception): embedding, similarity search, surfacing
// Manteia (the oracular): inference, structured generation
//
// Both dimensions engage external intelligence. The host perceives
// through embeddings and reasons through inference. One mind, two facets.

// =========================================================================
// Aisthesis — Perception
// =========================================================================

// SurfaceResult, EmbeddingResponse, EmbeddingData types
// call_openai_embedding()
// index_embedding()
// surface_by_similarity()
// bytes_to_f32()
// cosine_similarity()

// =========================================================================
// Manteia — The Oracular
// =========================================================================

// call_anthropic_inference()
// call_anthropic_structured()

// =========================================================================
// Tests
// =========================================================================

// All existing embedding tests move here
```

### Merge 2: signal.rs + reconciler.rs → reflex.rs

**Why**: Signal and reconciliation serve the same dimension — how the world responds to change. A signal flows through the aither; a reconciler reads transition tables. Both are mechanisms the host uses when something changes and the world must react. Splitting them says "these are unrelated concerns." Uniting them says "these are two mechanisms within the responsive loop."

**Note**: There is already a `reflex.rs` module that contains the ReflexRegistry. The reconciler helpers (resolve_field_path, values_match) belong with it ontologically. The signal stubs are a separate mechanism (aither) but still serve the responsive dimension. The merge target should be considered carefully:

- `reconciler.rs` content (resolve_field_path, values_match) → merge into the existing `reflex.rs` module
- `signal.rs` content (handle_signal) → keep as separate file OR merge into reflex.rs with its own section

If the existing `reflex.rs` is large, signal.rs can remain separate and be renamed/documented as serving the responsive dimension. Check the existing `reflex.rs` size before deciding.

---

## Implementation Order

### Step 1: Assess existing reflex.rs

Read `crates/kosmos/src/reflex.rs` to understand its size and content. The reconciler helpers (resolve_field_path, values_match) are ontologically part of the reflex dimension. Determine whether they merge into the existing reflex.rs or into a new file.

### Step 2: Create nous.rs

1. Create `crates/kosmos/src/nous.rs` with the SPDX header and module doc comment
2. Copy all content from `embedding.rs` (types, functions, tests) into the Aisthesis section
3. Copy all content from `inference.rs` (functions) into the Manteia section
4. Ensure all imports are present (merge the `use` blocks from both files)

### Step 3: Update module declarations in lib.rs

```rust
// REMOVE
pub mod embedding;
pub mod inference;

// ADD
pub mod nous;
```

Update re-export:
```rust
// CHANGE
pub use embedding::SurfaceResult;
// TO
pub use nous::SurfaceResult;
```

### Step 4: Update host.rs delegation paths

All `crate::embedding::` references → `crate::nous::`
All `crate::inference::` references → `crate::nous::`

Specifically in host.rs:
- Line 1068: `crate::embedding::call_openai_embedding` → `crate::nous::call_openai_embedding`
- Line 1074: `crate::embedding::index_embedding` → `crate::nous::index_embedding`
- Line 1088: `crate::embedding::SurfaceResult` → `crate::nous::SurfaceResult`
- Line 1093: `crate::embedding::surface_by_similarity` → `crate::nous::surface_by_similarity`
- Line 1126: `crate::inference::call_anthropic_inference` → `crate::nous::call_anthropic_inference`
- Line 1145: `crate::inference::call_anthropic_structured` → `crate::nous::call_anthropic_structured`

### Step 5: Merge reconciler helpers into reflex dimension

Based on Step 1 assessment:

**Option A** (if reflex.rs is moderate size): Add resolve_field_path and values_match to the existing `reflex.rs` in a clearly labeled section.

**Option B** (if reflex.rs is already large): Keep reconciler.rs but rename to make its relationship to the reflex dimension clear. Add a doc comment: "Reconciliation primitives — part of the responsive dimension. See also reflex.rs."

Either way, update lib.rs:
```rust
// REMOVE (if Option A)
pub mod reconciler;
```

And update host.rs references:
- Lines 2187-2188: `crate::reconciler::resolve_field_path` → `crate::reflex::resolve_field_path` (or whatever target)
- Lines 2203-2210: `crate::reconciler::values_match` → `crate::reflex::values_match`

### Step 6: Handle signal.rs

Assess whether signal.rs (91 lines, all stubs) merges into reflex.rs or stays separate:

- If it merges: add an "Aither — Signal Propagation" section to reflex.rs
- If it stays: update the doc comment to acknowledge its relationship to the responsive dimension

Update lib.rs and host.rs references accordingly.

### Step 7: Delete superseded files

```bash
rm crates/kosmos/src/embedding.rs
rm crates/kosmos/src/inference.rs
rm crates/kosmos/src/reconciler.rs  # if merged into reflex.rs
rm crates/kosmos/src/signal.rs      # if merged into reflex.rs
```

### Step 8: Update host.rs section headers

The section headers in host.rs should reflect the ontological vocabulary:

```rust
// Aisthesis + Manteia → Nous
// BEFORE:
// Aisthesis Operations — Sensing and Surfacing
// Manteia Operations — Inference

// AFTER:
// Nous Operations — Perception and Inference
// (delegates to crate::nous)
```

### Step 9: Verify

```bash
cargo build -p kosmos 2>&1
cargo test -p kosmos --lib --tests 2>&1
cargo build -p kosmos-mcp 2>&1
```

No new tests needed — this is a pure refactoring. All 365 existing tests must pass unchanged.

---

## Files to Read

- `crates/kosmos/src/embedding.rs` — source for nous.rs Aisthesis section
- `crates/kosmos/src/inference.rs` — source for nous.rs Manteia section
- `crates/kosmos/src/signal.rs` — candidate for reflex merge
- `crates/kosmos/src/reconciler.rs` — candidate for reflex merge
- `crates/kosmos/src/reflex.rs` — existing module, merge target assessment
- `crates/kosmos/src/host.rs` — delegation paths to update
- `crates/kosmos/src/lib.rs` — module declarations + re-exports

---

## Files to Touch

| File | Change |
|------|--------|
| `crates/kosmos/src/nous.rs` | **NEW** — merged embedding.rs + inference.rs with ontological structure |
| `crates/kosmos/src/reflex.rs` | **MODIFY** — add reconciler helpers (resolve_field_path, values_match), possibly signal stubs |
| `crates/kosmos/src/lib.rs` | **MODIFY** — replace module declarations (embedding→nous, inference removed, reconciler→reflex or removed) |
| `crates/kosmos/src/host.rs` | **MODIFY** — update crate:: paths, update section headers |
| `crates/kosmos/src/embedding.rs` | **DELETE** — superseded by nous.rs |
| `crates/kosmos/src/inference.rs` | **DELETE** — superseded by nous.rs |
| `crates/kosmos/src/reconciler.rs` | **DELETE** — merged into reflex.rs |
| `crates/kosmos/src/signal.rs` | **DELETE or MODIFY** — merged into reflex.rs, or kept with updated doc |

---

## Success Criteria

- [ ] `nous.rs` exists with Aisthesis and Manteia sections, preserving all functions and tests from embedding.rs + inference.rs
- [ ] `embedding.rs` and `inference.rs` deleted
- [ ] `reconciler.rs` helpers merged into the reflex dimension (existing reflex.rs or documented relationship)
- [ ] signal.rs either merged into reflex.rs or documented as serving the responsive dimension
- [ ] All `crate::embedding::` and `crate::inference::` paths updated to `crate::nous::`
- [ ] All `crate::reconciler::` paths updated
- [ ] `SurfaceResult` re-export updated in lib.rs
- [ ] host.rs section headers reflect ontological vocabulary
- [ ] `cargo test -p kosmos --lib --tests` passes (365 tests, zero regressions)
- [ ] No functional changes — identical behavior before and after

---

## What Does NOT Change

1. **graph.rs** — already has the right identity (κόσμος structure)
2. **emission.rs** — already has the right identity (Ekthesis)
3. **command_template.rs** — already has the right relationship (energeia mechanism, parallel to substrate modules)
4. **host.rs energeia section** — actuality orchestration stays in host.rs (it IS the host's core act)
5. **host.rs reconcile()** — reconciliation orchestration stays (it needs &self for entity reads + actuality dispatch)
6. **Any function signatures** — pure move/merge, no API changes
7. **Any test behavior** — tests move with their functions, assertions unchanged

---

## What This Establishes

After this prompt, every module in the host layer has an ontological identity:

```
host.rs              — the host itself (identity, will, energeia, reflex orchestration)
  ├─ graph.rs        — κόσμος structure (entities, bonds, traversal, visibility)
  ├─ nous.rs         — the host's mind (aisthesis + manteia)
  ├─ emission.rs     — ekthesis (writing to chora)
  ├─ command_template.rs — energeia mechanism (template-driven actuality)
  └─ reflex.rs       — the responsive loop (reflexes, transitions, signal)
```

Plus the substrate modules (dns.rs, process.rs, storage.rs, credential.rs, r2.rs) as domain-specific energeia mechanisms — each already has ontological identity from the substrate taxonomy.

The question "where does this function belong?" is now answerable by ontology, not by code similarity. A new perception capability goes in nous.rs. A new signaling protocol goes in reflex.rs. A new actualization mechanism gets its own file as an energeia mechanism. The structure teaches the developer (and Claude) what the codebase IS, not just what it does.

---

*Traces to: the ontological cohering cycle — reshaping mechanical extraction into coherent dimensions. The host is where κόσμος meets χώρα; its modules should articulate the dimensions of that meeting.*
