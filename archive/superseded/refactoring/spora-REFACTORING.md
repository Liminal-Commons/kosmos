# Spora Refactoring — Genesis by Loading Oikoi

*From monolithic spora to composable oikos packages*

---

## Current State (COMPLETE)

**Spora structure (minimized):**
```
genesis/spora/
├── spora.yaml       # ~1900 lines — foundation only
├── definitions/     # Artifact definitions
├── theoria/         # Seed theoria
├── principles/      # Seed principles
├── patterns/        # Seed patterns
└── journeys/        # Seed journeys
```

**Oikos structure (each domain):**
```
genesis/*/
├── manifest.yaml    # Package metadata
├── DESIGN.md        # Design documentation
├── eide/            # Entity type definitions
├── desmoi/          # Bond type definitions
└── praxeis/         # Praxis definitions
```

**What now lives in oikos directories:**
- Domain-specific eide → `genesis/*/eide/*.yaml` (46 eide across 15 oikoi)
- Domain-specific desmoi → `genesis/*/desmoi/*.yaml` (71 desmoi across 14 oikoi)
- All praxeis → `genesis/*/praxeis/*.yaml` (17 praxis files across 17 oikoi)

**What remains in spora.yaml (foundation only):**
- Self-grounding prime (eidos/eidos)
- 17 foundational eide (desmos, stoicheion, oikos, praxis, theoria, etc.)
- 13 core desmoi (authorized-by, typed-by, member-of, etc.)
- Dynamis domains and functions
- Presence eide (persona, animus, circle)
- Founder entities (Victor, Claude, kosmos circle)
- Genesis animus and attainment grants
- Genesis completion marker

**Bootstrap output:**
```
Entities created: 404
Bonds created:    563
Manifests loaded: 19
Oikos content loaded: 17 oikoi with eide/desmoi/praxeis
```

---

## Target State

Each oikos is a self-contained package:
```
genesis/nous-activation/
├── manifest.yaml           # Package metadata (already exists)
├── DESIGN.md              # Design documentation (already exists)
├── eide/                  # NEW: Entity type definitions
│   ├── invocation-pattern.yaml
│   └── invocation.yaml
├── desmoi/                # NEW: Bond type definitions
│   ├── invoked-via.yaml
│   └── yields-invocation.yaml
└── praxeis/               # NEW: Move from spora/praxeis/
    └── activation.yaml    # invoke, gather-context, navigate
```

**Bootstrap would:**
1. Load minimal substrate (genesis root, archai)
2. Scan oikos directories in klimax order
3. For each oikos: load eide/, desmoi/, praxeis/
4. Execute stage-specific setup (founder entities, etc.)

**Benefits:**
- Each oikos is portable (can be loaded/unloaded)
- Clear ownership of entities
- Easier to develop new oikoi
- Simpler dependency understanding

---

## Migration Path

### Phase A: Foundation (Keep in spora.yaml)

These must remain in spora.yaml as foundational substrate:

| Stage | Content | Reason |
|-------|---------|--------|
| stage-0-prime | eidos/eidos | Self-grounding prime |
| stage-1-archai | Core eide (desmos, stoicheion, oikos, praxis, etc.) | Grammar |
| stage-1-desmoi | Core desmoi (authorized-by, typed-by, etc.) | Grammar |
| stage-1-dynamis | Dynamis interface entities | Substrate capability |
| stage-3-founder | Victor, Claude, kosmos circle | Foundation identities |
| stage-5-marker | Genesis completion marker | Bootstrap state |

### Phase B: Extractable to Oikoi

| Current Stage | Oikos Target | Entities |
|---------------|--------------|----------|
| stage-2-presence (partial) | polis | persona, circle, animus, session |
| stage-2-presence (soma) | soma | channel, percept, signal, body-schema |
| stage-2-presence (psyche) | psyche | attention, intention, mood, thyra, prospect, kairos |
| stage-2-presence (nous) | nous-activation | invocation-pattern, invocation |
| stage-2-syndesmos | syndesmos | syndesmos-link, sync-policy, phoreta, etc. |
| stage-2-politeia | politeia | attainment, affordance, hud-region, invitation |
| stage-2-propylon | propylon | propylon-link, propylon-session |
| stage-2-i18n | i18n | locale, localized-text |
| stage-3-politeia | politeia | Foundation attainments and grants |
| stage-4.3-nous | nous-activation | Seed invocation patterns |

### Phase C: Praxeis (Already Externalized)

Praxeis are already in `spora/praxeis/*.yaml`. Migration would:
1. Move each file to its oikos directory
2. Update `source_files` paths in spora.yaml
3. Eventually: bootstrap auto-discovers praxeis in oikos directories

---

## Implementation Strategy

### Step 1: Enhance Bootstrap (Low Risk)

Add capability to load from oikos directories:

```rust
// In bootstrap.rs
fn load_oikos_content(
    ctx: &HostContext,
    oikos_dir: &Path,
    manifest: &OikosManifest,
    result: &mut BootstrapResult,
) -> Result<()> {
    // Load eide/ if exists
    let eide_dir = oikos_dir.join("eide");
    if eide_dir.exists() {
        load_directory_entities(ctx, &eide_dir, result)?;
    }

    // Load desmoi/ if exists
    let desmoi_dir = oikos_dir.join("desmoi");
    if desmoi_dir.exists() {
        load_directory_entities(ctx, &desmoi_dir, result)?;
    }

    // Load praxeis/ if exists
    let praxeis_dir = oikos_dir.join("praxeis");
    if praxeis_dir.exists() {
        load_directory_entities(ctx, &praxeis_dir, result)?;
    }

    Ok(())
}
```

**This is non-breaking** — oikos directories that don't have these subdirectories continue to work as before.

### Step 2: Create Proof of Concept (nous-activation)

1. Create `genesis/nous-activation/eide/` with:
   - `invocation-pattern.yaml`
   - `invocation.yaml`

2. Create `genesis/nous-activation/desmoi/` with:
   - `invoked-via.yaml`
   - `yields-invocation.yaml`

3. Create `genesis/nous-activation/praxeis/` with activation praxeis

4. Test: bootstrap loads both spora.yaml inline AND oikos directories

### Step 3: Gradual Migration

For each oikos:
1. Create eide/, desmoi/, praxeis/ subdirectories
2. Extract entities from spora.yaml to files
3. Remove from spora.yaml inline
4. Verify bootstrap still works

### Step 4: Minimize Spora

After all oikoi are extracted:
- spora.yaml contains only foundation (Phases A)
- ~200 lines instead of ~4700 lines
- Bootstrap loads oikoi in klimax order

---

## Open Questions

1. **Klimax ordering**: How do we ensure oikoi load in correct order?
   - Option A: Explicit order in spora.yaml stages
   - Option B: Dependency resolution from manifest.requires_dynamis
   - Option C: Numeric prefix on oikos directories (like klimax)

2. **Entity format in oikos directories**: Use same `entities:` structure as praxeis files?
   - Yes — keeps consistency, already have parser

3. **Backward compatibility**: What if someone has custom spora.yaml?
   - Both inline and directory loading work simultaneously
   - Migration is gradual, not forced

4. **Foundation vs extractable**: Where's the line?
   - Foundation = substrate grammar + identity
   - Extractable = everything that builds on substrate

---

## Progress

### ✓ Step 1: Bootstrap Enhancement (Complete)

Added `load_oikos_content()` function to `bootstrap.rs`:
- Scans oikos directories for `eide/`, `desmoi/`, `praxeis/` subdirectories
- Loads all YAML files from each subdirectory
- Reports content loaded in bootstrap output
- Non-breaking: directories without these subdirectories continue to work

### ✓ Step 2: Proof of Concept — nous-activation (Complete)

Created self-contained nous-activation package:
```
genesis/nous-activation/
├── manifest.yaml           # Package metadata
├── DESIGN.md              # Design documentation
├── eide/                  # ✓ NEW
│   ├── invocation-pattern.yaml
│   └── invocation.yaml
├── desmoi/                # ✓ NEW
│   ├── invoked-via.yaml
│   └── yields-invocation.yaml
└── praxeis/               # ✓ NEW
    └── activation.yaml    # gather-context, invoke, navigate
```

Bootstrap now reports:
```
Oikos content loaded:
  ✓ nous-activation (2 eide, 2 desmoi, 1 praxeis)
```

### ✓ Step 3: Remove nous-activation duplicates from spora.yaml (Complete)

Removed `invocation-pattern` and `invocation` eide from spora.yaml stage-2-presence.
Left a comment pointing to their new location in nous-activation/eide/.

Bootstrap now reports:
```
Entities created: 530 (down from 532)
Bonds created:    797 (down from 799)

Oikos content loaded:
  ✓ nous-activation (2 eide, 2 desmoi, 1 praxeis)
```

The oikos packaging pattern is proven: eide, desmoi, and praxeis can live in oikos directories.

### ✓ Step 4: Extract all cross-scale oikoi praxeis (Complete)

Moved all cross-scale praxeis from `genesis/spora/praxeis/` to their oikos directories:

| Oikos | Praxeis Moved | Files |
|-------|---------------|-------|
| aither | 1 | aither.yaml |
| demiurge | 1 | demiurge.yaml |
| dokimasia | 1 | dokimasia.yaml |
| energeia | 1 | ergon.yaml |
| hypostasis | 1 | hypostasis.yaml |
| i18n | 1 | i18n.yaml (+ new manifest) |
| manteia | 1 | manteia.yaml |
| nous-activation | 1 | activation.yaml |
| pege | 1 | pege.yaml |
| politeia | 1 | politeia.yaml |
| propylon | 1 | propylon.yaml |
| syndesmos | 1 | syndesmos.yaml |
| thyra | 2 | thyra.yaml, dns.yaml |

Bootstrap now reports:
```
Entities created: 531
Bonds created:    799

Oikos content loaded:
  ✓ aither (1 praxeis)
  ✓ demiurge (1 praxeis)
  ✓ dokimasia (1 praxeis)
  ✓ energeia (1 praxeis)
  ✓ hypostasis (1 praxeis)
  ✓ i18n (1 praxeis)
  ✓ manteia (1 praxeis)
  ✓ nous-activation (2 eide, 2 desmoi, 1 praxeis)
  ✓ pege (1 praxeis)
  ✓ politeia (1 praxeis)
  ✓ propylon (1 praxeis)
  ✓ syndesmos (1 praxeis)
  ✓ thyra (2 praxeis)
```

### ✓ Step 5: Extract klimax oikoi (Complete)

Moved klimax praxeis to their oikos directories:

| Oikos | Praxeis Moved | Files |
|-------|---------------|-------|
| soma | 1 | soma.yaml |
| psyche | 1 | psyche.yaml |
| nous | 1 | nous.yaml |
| oikos | 1 | oikos.yaml |

Bootstrap now reports:
```
Entities created: 531
Bonds created:    799

Oikos content loaded:
  ✓ aither (1 praxeis)
  ✓ demiurge (1 praxeis)
  ✓ dokimasia (1 praxeis)
  ✓ energeia (1 praxeis)
  ✓ hypostasis (1 praxeis)
  ✓ i18n (1 praxeis)
  ✓ manteia (1 praxeis)
  ✓ nous (1 praxeis)
  ✓ nous-activation (2 eide, 2 desmoi, 1 praxeis)
  ✓ oikos (1 praxeis)
  ✓ pege (1 praxeis)
  ✓ politeia (1 praxeis)
  ✓ propylon (1 praxeis)
  ✓ psyche (1 praxeis)
  ✓ soma (1 praxeis)
  ✓ syndesmos (1 praxeis)
  ✓ thyra (2 praxeis)
```

**`genesis/spora/praxeis/` is now empty** — all praxeis live in their oikos directories.

### ✓ Step 6: Extract desmoi to oikos directories (Complete)

Extracted all domain-specific desmoi from spora.yaml stage-1-desmoi to their respective oikos directories:

| Oikos | Desmoi | File |
|-------|--------|------|
| hypostasis | 3 | signed-by, chains-to, verifies |
| soma | 5 | instantiates, channel-of, received-through, emitted-through, schema-of |
| psyche | 7 | attends, intends, mood-of, portal-of, foresees, recognizes, opportune-for |
| nous | 10 | crystallized-in, inquires, synthesizes, answers, contains-waypoint, waypoint-yields, supersedes, supports, contradicts, evidences |
| oikos | 11 | within, authored-by, surfaced-in, about, crystallizes, surfaces, published-by, baked-from, attests-to, distributes, oikos-derives-from |
| manteia | 3 | authorizes, yields-generation, memoizes |
| dokimasia | 2 | validated-by, traces-to |
| demiurge | 1 | depends-on |
| energeia | 2 | supervises, runs-as |
| thyra | 7 | expressed-in, transforms-to, produces, consumes, in-reply-to, derives-from, contributes-to |
| thyra (dns.yaml) | 4 | manages-zone, in-zone, provided-by, addresses |
| aisthesis | 1 | bootstrapped-by |
| syndesmos | 5 | uses-channel, governed-by, carried-through, mirrors, conflicts-on |
| politeia | 10 | sovereign-to, embodies, grants-attainment, has-attainment, granted-by, surfaces-as, enabled-by, renders-in, child-of, invited-to |

**Total: 71 desmoi extracted to 18 files in 14 oikos directories**

Core foundational desmoi remain in spora.yaml:
- authorized-by, composed-from, typed-by, provides-function
- inhabits, contains, emerges-from, dwells-in
- stewards, member-of, belongs-to, grounds, enacts

Bootstrap now reports:
```
Entities created: 404
Bonds created:    563
Manifests loaded: 19
```

**Note**: Entity count decreased from previous (531 → 404) because:
1. Removed duplicate desmos definitions (previously existed in both spora.yaml and oikos directories)
2. spora.yaml now contains only 13 core desmoi, rest loaded from oikos

### ✓ Step 7: Extract eide to oikos directories (Complete)

Extracted all domain-specific eide from spora.yaml to their respective oikos directories:

| Oikos | Eide | File |
|-------|------|------|
| soma | 4 | channel, percept, signal, body-schema |
| psyche | 6 | attention, intention, mood, thyra, prospect, kairos |
| nous | 4 | journey, waypoint, inquiry, synthesis |
| nous-activation | 2 | invocation-pattern, invocation |
| oikos | 4 | session, conversation, segment, note |
| manteia | 2 | generation, memo |
| dokimasia | 2 | validation-result, validation-error |
| energeia | 2 | daemon, task |
| thyra | 4 | stream, expression, accumulation, utterance |
| thyra (dns.yaml) | 2 | dns-zone, dns-record |
| aither | 2 | signaling-session, aither-channel |
| syndesmos | 4 | syndesmos-link, sync-policy, phoreta, sync-conflict |
| politeia | 4 | attainment, affordance, hud-region, invitation |
| propylon | 2 | propylon-link, propylon-session |
| i18n | 2 | locale, localized-text |

**Total: 46 domain-specific eide extracted to 15 oikos directories**

Core foundational eide remain in spora.yaml stage-1-archai:
- eidos (self-grounding prime)
- desmos, stoicheion, oikos, praxis
- theoria, principle, pattern
- typos, artifact
- genesis-record, dynamis-domain, dynamis-function
- oikos-manifest, oikos-dev, oikos-prod, publish-attestation

Core presence eide remain in spora.yaml stage-2-presence:
- persona, animus, circle (needed for founder stage)

Bootstrap now reports:
```
Entities created: 404
Bonds created:    563
Manifests loaded: 19

Oikos content loaded:
  ✓ aither (2 eide, 1 desmoi, 1 praxeis)
  ✓ demiurge (1 desmoi, 1 praxeis)
  ✓ dokimasia (2 eide, 2 desmoi, 1 praxeis)
  ✓ energeia (2 eide, 2 desmoi, 1 praxeis)
  ✓ hypostasis (3 desmoi, 1 praxeis)
  ✓ i18n (2 eide, 1 praxeis)
  ✓ manteia (2 eide, 3 desmoi, 1 praxeis)
  ✓ nous (4 eide, 10 desmoi, 1 praxeis)
  ✓ nous-activation (2 eide, 2 desmoi, 1 praxeis)
  ✓ oikos (4 eide, 11 desmoi, 1 praxeis)
  ✓ pege (1 praxeis)
  ✓ politeia (4 eide, 10 desmoi, 1 praxeis)
  ✓ propylon (2 eide, 3 desmoi, 1 praxeis)
  ✓ psyche (6 eide, 7 desmoi, 1 praxeis)
  ✓ soma (4 eide, 5 desmoi, 1 praxeis)
  ✓ syndesmos (4 eide, 5 desmoi, 1 praxeis)
  ✓ thyra (6 eide, 11 desmoi, 2 praxeis)
```

---

## Summary: Refactoring Complete

The oikos packaging refactoring is **complete**. Spora.yaml has been minimized from ~4700 lines to ~1900 lines (foundation only).

### What spora.yaml now contains:

| Stage | Content | Lines |
|-------|---------|-------|
| stage-0-prime | eidos/eidos (self-grounding) | ~15 |
| stage-1-archai | 17 foundational eide | ~470 |
| stage-1-desmoi | 13 core desmoi | ~110 |
| stage-1-dynamis | 10 dynamis domains, ~30 functions | ~650 |
| stage-2-presence | persona, animus, circle | ~90 |
| stage-3-founder | Victor, Claude, kosmos circle | ~80 |
| stage-3-politeia | Genesis animus, attainments, HUD | ~450 |
| stage-5-marker | Genesis completion marker | ~20 |

### What lives in oikos directories:

| Content Type | Count | Location |
|--------------|-------|----------|
| Domain-specific eide | 46 | `genesis/*/eide/*.yaml` |
| Domain-specific desmoi | 71 | `genesis/*/desmoi/*.yaml` |
| All praxeis | 17 | `genesis/*/praxeis/*.yaml` |

### Benefits achieved:

1. **Composability** — Each oikos is a self-contained package
2. **Clear ownership** — Entity types belong to their domain
3. **Easier development** — Add new oikos without touching spora.yaml
4. **Simpler dependencies** — Manifest declares what oikos needs

---

*Traces to: expression/genesis-root*
*Drafted: 2026-01-21*
*Updated: 2026-01-21 — Refactoring complete (Steps 1-7)*
