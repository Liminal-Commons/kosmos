# PROMPT-TEMPLATE — Canonical Structure for Development Prompts

*This template governs the structure of all `PROMPT-*.md` files in `genesis/chora-dev/`. Every prompt follows DDD+TDD methodology and uses this structure. Deviations are not "pragmatic" — they are gaps.*

---

## The Structure

```
# {Title} — {Subtitle That States the Change}

*Prompt for Claude Code in the chora + kosmos repository context.*

*{1-3 sentences: what this work does, what exists after. Written in present
tense of the completed state — "After this work, X is true."
Include dependency chain if applicable.}*

---

## Architectural Principle — {Name}

{The ontological or architectural principle that motivates this work.
Not "what we're doing" but "why this is the right shape."
Quotes from KOSMOGONIA, theoria, or prior prompts if applicable.
Diagrams/ASCII art welcome.}

---

## Methodology — DDD + TDD

This work follows **Doc → Test → Build → Verify**, non-negotiably.

1. **Doc (prescriptive)**: This prompt IS the prescriptive doc. The target
   state described here is what code must match.
2. **Test (assert the doc)**: Write tests that assert the target state.
   Tests should fail before implementation.
3. **Build (satisfy the tests)**: Implement until tests pass.
4. **Verify doc**: After implementation, update success criteria to reflect
   completion. Check docs/REGISTRY.md impact map.

{Any methodology-specific notes — e.g., "Clean break, no backward
compatibility" or "Pure refactoring, no functional changes" or
"Empirical emphasis — the design is tested against reality."}

---

## Current State

{Table or structured description of what exists and what's missing.
Two clear subsections:}

### What Exists and Works

| Component | Location | Status |
|-----------|----------|--------|
| ... | ... | Working / Defined / Stub |

### What's Missing — The Gaps

{Numbered gaps. Each gap: what's wrong, what's needed, why it matters.}

---

## Target State

{What the code/genesis/docs should look like AFTER this work.
Code snippets of the target. YAML of the target entities.
This is the prescriptive specification — code must match this.}

---

## Sequenced Work

{Phased implementation. Each phase has:
 - Goal statement
 - Implementation steps
 - Tests for this phase (BEFORE implementation in the phase)
 - "Phase N Complete When:" criteria}

### Phase 1: {Name}

**Goal:** {One sentence.}

**Tests:**
- test_name_1 — what it asserts
- test_name_2 — what it asserts

**Implementation:**
1. {Step}
2. {Step}

**Phase 1 Complete When:**
- [ ] {criterion}
- [ ] {criterion}

### Phase 2: {Name}
...

---

## Files to Read

{Categorized by concern, with brief description of why each file matters.}

### {Category}
- `path/to/file.rs` — what to look at

---

## Files to Touch

| File | Change |
|------|--------|
| `path` | **NEW** / **MODIFY** / **DELETE** — description |

---

## Success Criteria

{Per-phase checkboxes if multi-phase, or flat list if single-phase.
Mark completed criteria with [x] after execution.}

**Overall Complete When:**
- [ ] All existing tests still pass
- [ ] N new tests cover the gaps
- [ ] {Domain-specific criteria}

---

## What This Enables

{Forward-looking — what becomes possible after this work.
Not just "what we did" but "what this unlocks."}

---

## What Does NOT Change

{Explicit scope boundaries. What is OUT of scope and stays as-is.
Prevents scope creep during execution.}

---

*Traces to: {lineage — prior prompts, theoria, KOSMOGONIA sections}*
```

---

## Key Principles of the Template

### 1. The Prompt IS the Doc

In DDD, the doc describes the target state. The prompt is that doc. It is prescriptive — code must match it, not the other way around. When code doesn't match the prompt, the code has a gap.

### 2. Tests Before Implementation

In each phase, tests appear BEFORE implementation steps. This is TDD: write the assertion first, then satisfy it. A phase that lists implementation before tests inverts the methodology.

### 3. Current State → Target State → Sequenced Work

The reader needs to understand three things in order:
1. Where are we? (Current State)
2. Where are we going? (Target State)
3. How do we get there? (Sequenced Work)

Jumping from context to implementation (skipping Target State) forces the reader to infer the destination from the steps. The target should be stated explicitly.

### 4. Methodology Section Is Not Optional

Every prompt explicitly states "Doc → Test → Build → Verify." This is not boilerplate — it reminds the executing agent (Claude Code) of the non-negotiable cycle. Without it, the agent may implement first and test later.

### 5. Findings Section (Post-Execution)

After execution, the prompt gains a `## Findings` section documenting what happened:
- Completion status (checkboxes marked)
- What worked, what was discovered
- Theoria crystallized
- Any scope changes during execution

This transforms the prompt from a plan into a historical record with provenance.

---

## Anti-Patterns

| Anti-Pattern | Why It Fails | Correct Pattern |
|-------------|-------------|-----------------|
| Tests as "Step 5" after implementation | Inverts TDD — build-then-test | Tests in each phase, before implementation |
| "Methodology: Intent → Convention → Verify" | Describes implementation approach, not DDD+TDD cycle | Always state "Doc → Test → Build → Verify" |
| No Target State section | Reader infers destination from steps | Explicit target with code/YAML snippets |
| Principles without "Current State" | Principles float without grounding | Current State grounds the principle in reality |
| Flat implementation steps without phases | No incremental verification | Phased work with per-phase tests and criteria |

---

*This template is not description. It is constitution. Every PROMPT-*.md follows it.*
