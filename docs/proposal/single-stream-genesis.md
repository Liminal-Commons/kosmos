# Single-Stream Genesis Migration

*Kosmos creating kosmos — using our own topoi to achieve full-circle emission.*

**Status:** DRAFT

---

## The Core Insight

Emitted format = Source format. No translation.

```
emit(kosmos.db) → files → bootstrap(files) → kosmos.db' → emit(kosmos.db') → files'
                                                                              ↑
                                                                   files' ≡ files
```

When this cycle closes identically, the system proves its own coherence.

---

## The Topoi Are The Tools

We don't write migration scripts. We compose through the kosmos:

| Topos | Role in Migration |
|-------|-------------------|
| **demiurge** | Compose the new structure (with integrated validation) |
| **dokimasia** | Validation during composition — invalid things never arise |
| **thyra** | Emit to chora (filesystem) |
| **nous** | Surface/traverse to discover what exists |
| **hypostasis** | Sign the emission (content hash verification) |

The compositor is simple. The definitions describe the new structure.

---

## Current State

### Multiple Formats
```
genesis/
├── spora/spora.yaml        # Germination stages with inline compose
├── arche/*.yaml            # Raw eidos/desmos arrays
├── klimax/*/               # DESIGN.md + content .yaml (confusing overlap)
├── [topos]/                # manifest.yaml + eide/ + desmoi/ + praxeis/
│   ├── manifest.yaml
│   ├── eide/[name].yaml    # entities: [...] format
│   └── praxeis/[name].yaml # entities: [...] format
```

### Multiple Bootstrap Paths
- Original spora germination (stages with inline compose)
- `bootstrap_from_manifest()` (reads topos manifests)
- Klimax yaml files (currently not loaded)

---

## Target State: Single Stream

```
genesis/
├── KOSMOGONIA.md           # Constitutional root (markdown, not entity)
├── ARCHITECTURE.md         # Technical guide (markdown, not entity)
├── ROADMAP.md              # Progress tracking (markdown, not entity)
│
├── manifest.yaml           # THE SINGLE SOURCE — what to load
│
├── entities/               # All entities by eidos type
│   ├── eidos.yaml          # 58 eide
│   ├── desmos.yaml         # 105+ desmoi
│   ├── stoicheion.yaml     # All stoicheia
│   ├── praxis.yaml         # 239+ praxeis
│   ├── artifact-definition.yaml
│   ├── oikos.yaml
│   ├── prosopon.yaml
│   └── ...                 # One file per eidos type
│
├── bonds/                  # All bonds (separate from entities)
│   └── bonds.yaml          # 733+ bonds
│
├── docs/                   # Pure documentation (not loaded)
│   ├── klimax/             # DESIGN.md per scale
│   └── topoi/              # DESIGN.md per topos
│
└── stoicheia-portable/     # WASM source (compile-time)
    └── wasm/*.wat
```

### Key Properties

1. **One manifest** — `genesis/manifest.yaml` lists everything
2. **Flat by eidos** — entities grouped by type, not by topos origin
3. **Bonds separate** — relationships are their own concern
4. **Docs don't load** — DESIGN.md is for humans, not bootstrap
5. **Emit writes here** — `thyra/emit-all` creates this exact structure
6. **Bootstrap reads here** — same format, no translation

---

## Validation Integration

Dokimasia isn't "at the end." Invalid things never arise.

### The Compose Step Validates

```yaml
# Within interpreter's compose step:
1. Resolve definition
2. Fill slots (literal, computed, queried, generated)
3. VALIDATE SCHEMA — fields match target_eidos
4. VALIDATE SEMANTICS — references resolve
5. VALIDATE PROVENANCE — authorized_by chain traces to genesis
6. If invalid → fail composition (no entity arises)
7. If valid → arise with content hash
```

### Full Validation Report

For verification after emission:

```
dokimasia/compose-validation-report
  root_id: "genesis"
  traverses: depends-on, authorized-by, composed-from
  returns: { passed, failed, provenance_chain }
```

This validates the entire graph traces to genesis.

---

## Migration Plan

### Phase A: Define Target Structure

**A1.** Create `artifact-def-genesis-manifest` — describes what genesis contains
**A2.** Create `artifact-def-entity-file` — describes a file of entities by eidos
**A3.** Create `artifact-def-bond-file` — describes a file of bonds

### Phase B: Compose Target Structure

**B1.** Use `demiurge/compose` with genesis-manifest definition
**B2.** For each eidos type, compose entity-file with gathered entities
**B3.** Compose bond-file with all bonds
**B4.** Validation happens within composition — invalid never arises

### Phase C: Emit to Chora

**C1.** Use `thyra/emit` to write manifest.yaml
**C2.** Use `thyra/emit` to write each entities/*.yaml
**C3.** Use `thyra/emit` to write bonds/bonds.yaml
**C4.** Content hashes recorded in manifest

### Phase D: Verify Full Circle

**D1.** Bootstrap from emitted structure → fresh kosmos
**D2.** Emit again → second output
**D3.** Assert: BLAKE3(first output) == BLAKE3(second output)
**D4.** If equal: full-circle proven

### Phase E: Replace Genesis

**E1.** Archive current genesis/ → archive/genesis-v7/
**E2.** Move emitted structure → genesis/
**E3.** Update bootstrap to read single-stream format
**E4.** Delete germination stages (no longer needed)
**E5.** KOSMOGONIA, ARCHITECTURE, ROADMAP stay as markdown

---

## Manifest Structure

```yaml
# genesis/manifest.yaml
id: genesis
version: 0.1.0
format: single-stream-v1

# Constitutional root
genesis_root:
  id: phasis/genesis-root
  signature: 5fd550ad...
  public_key: b196e546...

# Content locations
entities:
  - entities/eidos.yaml
  - entities/desmos.yaml
  - entities/stoicheion.yaml
  - entities/praxis.yaml
  - entities/artifact-definition.yaml
  - entities/oikos.yaml
  - entities/prosopon.yaml
  # ... all eidos types

bonds:
  - bonds/bonds.yaml

# Content hash for verification
content_hash: blake3:...
```

---

## Entity File Format

```yaml
# genesis/entities/praxis.yaml
eidos: praxis
count: 239
content_hash: blake3:...

entities:
  - id: praxis/nous/find
    data:
      topos: nous
      name: find
      # ...

  - id: praxis/nous/surface
    data:
      topos: nous
      name: surface
      # ...
```

Same format demiurge composes. Same format thyra emits. Same format bootstrap reads.

---

## What Stays the Same

- **KOSMOGONIA.md** — constitutional document (markdown, not entity)
- **ARCHITECTURE.md** — technical guide (markdown, not entity)
- **The topoi capabilities** — demiurge, thyra, dokimasia, nous, etc.
- **The archai** — eidos, desmos, stoicheion
- **The klimax** — as conceptual organization (in docs/)

## What Changes

- **spora.yaml germination stages** — eliminated (flat entity files instead)
- **klimax/*.yaml content** — moves to entities/, DESIGN.md stays in docs/
- **per-topos file structure** — content consolidates by eidos type
- **bootstrap logic** — simpler: read manifest, load entity files, load bonds
- **emit logic** — produces the format bootstrap reads

---

## Benefits

1. **Self-verifying** — emit → bootstrap → emit = identical proves coherence
2. **Simpler bootstrap** — one path, one format
3. **Integrated validation** — dokimasia in composition, not separate pass
4. **Content-addressed** — BLAKE3 hashes enable caching and verification
5. **Kosmos creates kosmos** — migration uses the system's own capabilities

---

## Open Questions

1. **Topos grouping in docs?** — Should each topos have a DESIGN.md even though content is flat?
2. **Development workflow?** — How do developers add new entities?
3. **Incremental vs full emit?** — Can we emit only changed entity files?
4. **Signing ceremony?** — How do threshold signatures work for genesis?

---

## Theoria

**T19: Emitted format IS source format**
There is no translation. What the kosmos emits is what the kosmos bootstraps from. Full circle closes by construction.

**T20: Validation is composition, not verification**
Dokimasia validates during composition. Invalid things never arise. This is "making it impossible to do wrong."

**T21: The migration is composition**
We don't write scripts. We define artifacts (artifact-def-genesis-manifest, artifact-def-entity-file) and compose through demiurge. The kosmos creates its own next form.

---

*Drafted 2026-01-25 — for discussion and refinement*
