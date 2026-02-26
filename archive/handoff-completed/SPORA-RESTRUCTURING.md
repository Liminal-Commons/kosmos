# Spora Restructuring — The Seed Should Carry DNA, Not the Tree

*Thin the seed. Let content live where it belongs.*

---

## Constitutional Ground

The KOSMOGONIA establishes five meta-patterns. Three speak directly to this work:

**Homoiconicity**: The kosmos describes itself in its own terms. Configuration that is usually implicit becomes explicit entities with bonds.

**Performative Bootstrap**: Describing IS doing. The specification becomes the thing.

**Narrow Way**: Minimal substrate, maximum emergence. Add nothing that can be composed from what exists.

And the one-right-way principle: there should be one canonical location for each concern, not multiple overlapping containers.

---

## The Problem

`genesis/spora/spora.yaml` is 2,478 lines. It is simultaneously:

1. **The germination sequence** — ordered stages that compose the pre-topos ground (legitimate)
2. **A content repository** — holding per-topos typos, theoria, principles, patterns, journeys (illegitimate)
3. **An inline duplicator** — re-defining eide that arche/ already defines canonically (illegitimate, but requires chora-side change)

The biological metaphor clarifies the issue: the spora (seed) lives inside the genesis (tree). The tree carries its own seed — that's the full-circle property (`emit → bootstrap → emit = same hash`). But right now **the seed has swallowed the tree**: spora contains content that belongs in topos directories, not in the germination sequence.

### The Three Concepts

| Concept | Role | Currently |
|---------|------|-----------|
| **Spora** | Germination sequence — what to create, in what order | Bloated with per-topos content |
| **Arche** | Constitutional grammar — canonical eidos/desmos schemas | Partially duplicated in spora |
| **Genesis (topos)** | Full-circle guarantee — emit, bootstrap, verify | Clean |
| **Dokimasia** | Examination — validate what germinated is correct | Clean |

---

## The Desired State

### Spora becomes thin

`spora.yaml` contains ONLY:
- The genesis root (signed phasis — irreducible)
- Content roots declarations
- Germination stages as an ordered sequence:
  - Stage 0: Prime (self-grounding — eidos is an eidos)
  - Stage 1: Archai (loads from arche/ for schemas; inline for eide that have no separate file yet)
  - Stage 1.5: Foundational desmoi
  - Stage 1.8: Dynamis domains and functions
  - Stage 2: Presence eide (prosopon, parousia, oikos)
  - Stage 3: Founder instances (Victor, Claude, oikos/kosmos — these ARE seed-specific)
  - Stage 3.5: Politeia bootstrap (attainments, HUD, affordances, renderers)
  - Stage 5: Marker

The germination stages themselves (the inline entity creation) remain as-is for now. Thinning the inline definitions to reference arche/ requires chora-side interpreter changes (see § Chora Dependencies below). The kosmos-side work is: **move all non-germination content out of spora/**.

### Per-topos content moves to its home topos

Every file in `spora/definitions/` contains typos (composition molds) that belong to specific topoi. These move to `genesis/{topos}/typos/` directories.

### Non-seed content moves to its canonical home

Principles, patterns, theoria, and journeys are not germination instructions. They are entities that should live where their eidos says they belong.

---

## Phase 1: Move Per-Topos Typos

### Migration Map

Each file in `genesis/spora/definitions/` contains typos that belong to specific topoi. Create `typos/` directories in target topoi and move content there.

#### core.yaml → Split to multiple topoi

| Typos | Target Topos | Rationale |
|-------|-------------|-----------|
| `typos-def-theoria`, `typos-def-inquiry`, `typos-def-synthesis`, `typos-def-journey`, `typos-def-waypoint`, `typos-def-invocation-pattern`, `typos-def-invocation` | **nous** | Understanding entities |
| `typos-def-principle`, `typos-def-pattern` | **nous** | Knowledge ladder (theoria → principle → pattern) |
| `typos-def-oikos`, `typos-def-prosopon`, `typos-def-genesis-record`, `typos-def-snapshot`, `typos-def-validation-report` | **politeia** | Governance entities |
| `typos-def-note`, `typos-def-insight`, `typos-def-session`, `typos-def-conversation` | **oikos** | Dwelling entities |
| `typos-def-greeting`, `typos-def-summary`, `typos-def-rust-struct`, `typos-def-yaml-entity` | **demiurge** | Composition test templates |

#### entities.yaml → Split to multiple topoi

This is the largest file (~47 typos). Split by target eidos affinity:

| Target Topos | Typos to Move |
|-------------|---------------|
| **soma** | typos-def-parousia, typos-def-body-schema, typos-def-channel, typos-def-percept, typos-def-body-signal |
| **psyche** | typos-def-attention, typos-def-intention, typos-def-mood |
| **thyra** | typos-def-phasis, typos-def-stream, typos-def-accumulation, typos-def-dns-zone, typos-def-dns-provider-binding, typos-def-dns-record, typos-def-render-intent, typos-def-workspace, typos-def-panel, typos-def-widget, typos-def-render-spec |
| **aither** | typos-def-signaling-session, typos-def-data-channel, typos-def-syndesmos, typos-def-outbound-message, typos-def-presence-record, typos-def-sync-message |
| **politeia** | typos-def-oikos, typos-def-invitation, typos-def-attainment, typos-def-affordance, typos-def-hud-region, typos-def-membership-event, typos-def-prosopon |
| **hypostasis** | typos-def-genesis-record, typos-def-kleidoura, typos-def-credential, typos-def-ssh-credential |
| **propylon** | typos-def-propylon-link, typos-def-propylon-session, typos-def-entry-request |
| **dokimasia** | typos-def-validation-result |
| **ergon** | typos-def-trigger |
| **demiurge** | typos-def-typos, typos-def-eidos, typos-def-praxis, typos-def-desmos, typos-def-topos, typos-def-artifact |
| **dynamis** | typos-def-topos-dev, typos-def-topos-prod, typos-def-publish-attestation, typos-def-deployment, typos-def-service-instance, typos-def-node |
| **agora** | typos-def-agora-presence, typos-def-agora-room, typos-def-agora-territory, typos-def-agora-livekit-server |
| **nous** | typos-def-axiom, typos-def-principle, typos-def-pattern |

#### Remaining files → Direct mapping

| Source File | Target Topos | Target Path |
|-------------|-------------|-------------|
| `manteia.yaml` | manteia | `genesis/manteia/typos/manteia.yaml` |
| `soma.yaml` | soma | `genesis/soma/typos/soma.yaml` |
| `thyra.yaml` | thyra | `genesis/thyra/typos/thyra.yaml` |
| `ergon.yaml` | ergon | `genesis/ergon/typos/ergon.yaml` |
| `pege.yaml` | pege (new topos or demiurge) | `genesis/demiurge/typos/pege.yaml` |
| `dynamis.yaml` | dynamis | `genesis/dynamis/typos/dynamis.yaml` |
| `oikos-generation.yaml` | demiurge | `genesis/demiurge/typos/oikos-generation.yaml` |
| `step-types.yaml` | stoicheia-portable | `genesis/stoicheia-portable/typos/step-types.yaml` |

### Update Topos Manifests

For each topos that receives typos, add a `typos/` content path to its `manifest.yaml`:

```yaml
content_paths:
  - path: eide/
    content_types: [eidos, attainment]
  - path: desmoi/
    content_types: [desmos]
  - path: praxeis/
    content_types: [praxis]
  - path: typos/                     # ← ADD THIS
    content_types: [typos]
```

### Update Spora Content Roots

In `spora.yaml`, the content root `content-root/spora-definitions` currently points to `spora/definitions/`. After migration, either:

1. **Remove it** (if all definitions have moved to topos directories with manifest content_paths)
2. **Keep it pointing to an empty directory** (if some unaffiliated typos remain)
3. **Point it to a new location** (if some truly cross-cutting typos need a shared home)

Recommendation: option 1 — remove the content root. All typos belong to a topos.

### Resolve Duplicates

Some typos appear in BOTH core.yaml and entities.yaml (e.g., `typos-def-oikos`, `typos-def-session`, `typos-def-conversation`). During migration:

1. Compare the two versions
2. Keep the more complete one
3. If both are identical, keep one
4. If they differ, reconcile into a single canonical version

---

## Phase 2: Move Non-Seed Content

### Principles → nous

`spora/principles/core.yaml` contains enacted normative commitments. These are the knowledge ladder's middle rung: theoria grounds principle grounds pattern.

**Move to:** `genesis/nous/principles/core.yaml`
**Add to nous manifest** content_paths:
```yaml
  - path: principles/
    content_types: [principle]
```

### Patterns → nous

`spora/patterns/core.yaml` contains enacted commitments — how principles live.

**Move to:** `genesis/nous/patterns/core.yaml`
**Add to nous manifest** content_paths:
```yaml
  - path: patterns/
    content_types: [pattern]
```

### Theoria → nous

`spora/theoria/cosmology.yaml` contains cosmological theoria. Nous already has `genesis/nous/theoria/` with an INDEX.md.

**Move to:** `genesis/nous/theoria/cosmology.yaml`
**Verify:** Check for ID conflicts with existing theoria in nous.

### Journeys → hodos

`spora/journeys/` contains `v8-roadmap.yaml`, `future-releases.yaml`, `kosmos-handover.yaml`. These are path/journey entities.

**Move to:** `genesis/hodos/journeys/`
**Add to hodos manifest** content_paths:
```yaml
  - path: journeys/
    content_types: [journey, waypoint]
```

### Circles → politeia

`spora/circles/kosmos-commons.yaml` describes oikos/kosmos distribution configuration.

**Move to:** `genesis/politeia/circles/kosmos-commons.yaml` or inline into politeia entities.
**Add to politeia manifest** if needed.

### Update Spora Content Roots

Remove content roots that pointed to now-empty spora subdirectories:

```yaml
# REMOVE:
  - id: content-root/spora-definitions
    path: spora/definitions/
    ...

  - id: content-root/spora-journeys
    path: spora/journeys/
    ...
```

---

## Phase 3: Fix V11 Migration Gaps

The V11 vocabulary migration (persona → prosopon, animus → parousia, circle → oikos, expression → phasis) missed some spora content:

| File | Line | Current | Should Be |
|------|------|---------|-----------|
| `spora.yaml` | ~2331 | "Circle navigation list" | "Oikos navigation list" |
| `definitions/entities.yaml` | ~13 | comment "My Circle" | "My Oikos" |
| `definitions/pege.yaml` | ~644, ~674 | "genesis expression" | "genesis phasis" |

These fixes should be applied to the files BEFORE they are moved to their new homes (so the migrated content is clean).

**Verification command** (after fixing):
```bash
grep -rn -i '\bcircle\b' genesis/spora/ | grep -v 'full-circle' | grep -v '# ' | head -20
grep -rn '\bexpression\b' genesis/spora/ | grep -v 'expression function' | grep -v 'expression evaluator' | grep -v 'Condition expression' | head -20
```

The term "expression" in programming contexts (expression function, expression evaluator, conditional expression) is kept. Only discourse/ontological uses (genesis expression → genesis phasis, expression thread → phasis thread) should migrate.

---

## Phase 4: Validate

After all moves:

### File-level validation

1. **No orphaned references**: Grep for `spora/definitions/` across genesis/ — all references should point to new locations
2. **No duplicate typos IDs**: Check that each typos ID appears exactly once across all topos typos/ directories
3. **All manifests updated**: Every topos that received typos has `typos/` in its content_paths
4. **Content roots clean**: spora.yaml content_roots no longer point to empty directories

### Structural validation

1. **spora/ directory should contain only**:
   - `spora.yaml` (the germination sequence)
   - No subdirectories (definitions/, journeys/, principles/, patterns/, theoria/, circles/ are all empty or removed)

2. **Every typos has a home**: No typos floating outside a topos directory

3. **V11 clean**: Zero instances of legacy vocabulary in migrated content (excluding programming-concept uses of "expression")

### Bootstrap validation (requires chora)

After restructuring, the chora bootstrap must be tested:

```bash
cd ../chora
cargo run --bin kosmos-mcp -- --db ./test.db --genesis ./genesis
```

The bootstrap reads manifest content_paths to discover content. If manifests are updated correctly, the bootstrap will find typos in their new locations.

---

## Chora Dependencies

### What this prompt does NOT change (requires chora interpreter work)

**Spora inline duplication**: Stages 0-3.5 of spora.yaml create eide and desmoi inline (e.g., `definition: inline` compose steps for eidos/desmos, eidos/stoicheion, etc.). These duplicate what arche/ defines canonically. Eliminating this duplication requires the chora bootstrap interpreter to support "load from content root" as a germination step type instead of only inline compose.

This is a separate chora-side prompt. The kosmos restructuring here is independent — moving content out of spora/ doesn't affect how spora.yaml's germination stages work.

### What the chora bootstrap needs to handle

After this restructuring, the bootstrap must:
1. Find typos in topos `typos/` directories (via manifest content_paths) — **should already work** if manifests are updated correctly
2. Load principles, patterns, theoria, and journeys from their new locations — **should already work** via manifest content_paths
3. Not expect content at `spora/definitions/` or `spora/journeys/` — the content roots for these will be removed

---

## Execution Order

1. **Fix V11 gaps first** (Phase 3 — clean the content before moving it)
2. **Move per-topos typos** (Phase 1 — the largest change)
3. **Move non-seed content** (Phase 2 — principles, patterns, theoria, journeys)
4. **Update manifests and content roots** (Phase 1 + 2 — ensure bootstrap can find everything)
5. **Validate** (Phase 4 — verify nothing is broken)
6. **Test bootstrap** (Phase 4 — requires chora)

---

## Success Criteria

When complete:

- `genesis/spora/` contains ONLY `spora.yaml` (no subdirectories)
- `spora.yaml` germination stages are unchanged (inline definitions remain for now)
- Every topos that owns typos has a `typos/` directory with its definitions
- Every topos manifest declares its `typos/` content path
- Non-seed content (principles, patterns, theoria, journeys) lives in nous or hodos
- Zero V11 legacy terms in migrated content
- All cross-references updated (grep finds no stale paths)
- Bootstrap succeeds (if chora is available for testing)

---

*The seed should carry DNA, not the tree. Thin the spora. Let content dwell where it belongs.*
