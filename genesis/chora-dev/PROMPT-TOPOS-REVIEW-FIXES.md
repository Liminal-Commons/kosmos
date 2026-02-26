# Topos Review Fixes — Corrections from Full-Kosmos Audit

*Prompt for Claude Code in the kosmos repository context.*

*All issues found during the full topos-by-topos review (2026-02-11). Organized by severity: critical fixes first (bootstrap failures), then bugs, then structural gaps, then completeness items. Each fix is independently verifiable.*

---

## Critical — Bootstrap Failures

### Fix 1: Psyche — 3 Missing Typos Definitions

**Problem:** `genesis/psyche/typos/psyche.yaml` defines only 3 of 6 needed typos molds. The praxeis `open-perceptual-field`, `foresee`, and `recognize-kairos` call `compose` with typos IDs that don't exist.

**Evidence:**
- `genesis/psyche/praxeis/psyche.yaml` references `typos-def-perceptual-field`, `typos-def-prospect`, `typos-def-kairos`
- `genesis/psyche/typos/psyche.yaml` only defines `typos-def-attention`, `typos-def-intention`, `typos-def-mood`

**Fix:** Add 3 typos definitions to `genesis/psyche/typos/psyche.yaml`:

```yaml
- eidos: typos
  id: typos-def-perceptual-field
  data:
    name: perceptual-field
    description: "Compose a perceptual-field entity"
    target_eidos: perceptual-field

- eidos: typos
  id: typos-def-prospect
  data:
    name: prospect
    description: "Compose a prospect entity"
    target_eidos: prospect

- eidos: typos
  id: typos-def-kairos
  data:
    name: kairos
    description: "Compose a kairos entity"
    target_eidos: kairos
```

**Verify:** The 3 praxeis (`open-perceptual-field`, `foresee`, `recognize-kairos`) should bootstrap without composition errors.

---

### Fix 2: Soma — Desmos `emitted-through` References Wrong Eidos

**Problem:** `genesis/soma/desmoi/soma.yaml` line 46 defines `desmos/emitted-through` with `from_eidos: signal`, but the actual eidos is `body-signal`. The eidos was renamed to avoid collision with `stoicheion/signal`, but the desmos definition was not updated.

**Evidence:**
- `genesis/soma/desmoi/soma.yaml` line 46: `from_eidos: signal`
- `genesis/soma/eide/soma.yaml` defines `eidos/body-signal` (not `eidos/signal`)
- `genesis/soma/praxeis/soma.yaml` creates `body-signal` entities via `typos-def-body-signal`

**Fix:** In `genesis/soma/desmoi/soma.yaml`:
- Line 44: Change description from `"Signal emitted through channel"` to `"Body-signal emitted through channel"`
- Line 46: Change `from_eidos: signal` to `from_eidos: body-signal`

---

### Fix 3: Soma — 2 Missing Typos Definitions

**Problem:** `genesis/soma/typos/soma.yaml` does not define `typos-def-node` or `typos-def-service-instance`, but the `register-node` and `register-service` praxeis call `compose` with these typos IDs.

**Fix:** Add 2 typos definitions to `genesis/soma/typos/soma.yaml`:

```yaml
- eidos: typos
  id: typos-def-node
  data:
    name: node
    description: "Compose a node entity"
    target_eidos: node

- eidos: typos
  id: typos-def-service-instance
  data:
    name: service-instance
    description: "Compose a service-instance entity"
    target_eidos: service-instance
```

**Verify:** The `register-node` and `register-service` praxeis should bootstrap without composition errors.

---

## Bugs — Incorrect References

### Fix 4: Journey Card — Wrong Praxis Reference

**Problem:** `genesis/nous/render-specs/journey-card.yaml` line 30 has `on_click: hodos/embark-journey`, but this praxis does not exist. The correct praxis is `nous/embark-journey` (defined at `praxis/nous/embark-journey` in `genesis/nous/praxeis/nous.yaml`).

**Evidence:**
- `genesis/nous/render-specs/journey-card.yaml` line 30: `on_click: hodos/embark-journey`
- `genesis/nous/praxeis/nous.yaml` line 1775: `id: praxis/nous/embark-journey`
- No `praxis/hodos/embark-journey` exists anywhere in genesis
- `genesis/hodos/praxeis/hodos.yaml` line 407 correctly references `nous/embark-journey`

**Fix:** In `genesis/nous/render-specs/journey-card.yaml`:
- Line 30: Change `on_click: hodos/embark-journey` to `on_click: nous/embark-journey`

---

### Fix 5: Psyche Render-Specs — on_click to Nonexistent Praxeis

**Problem:** Three psyche render-specs reference praxeis that don't exist:

| File | Line | References | Exists? |
|------|------|-----------|---------|
| `genesis/psyche/render-specs/intention-card.yaml` | 28 | `psyche/view-intention` | No |
| `genesis/psyche/render-specs/perceptual-field-card.yaml` | 32 | `psyche/view-perceptual-field` | No |
| `genesis/psyche/render-specs/kairos-card.yaml` | 30 | `psyche/seize-kairos` | No |

**Options:**
- (a) **Remove the on_click handlers** — cards become display-only. Correct for now since the praxeis don't exist.
- (b) **Create the praxeis** — `view-intention` and `view-perceptual-field` would be detail-view praxeis (find entity, return full data). `seize-kairos` would be an action praxis (activate the intention linked to this kairos).

**Recommended:** Option (a) for now. These praxeis can be created when the psyche domain is actively used. Phantom on_click handlers create false expectations.

---

## Structural — Ownership Misalignment

### Fix 6: Logos — Phasis Typos and Desmoi Still in Thyra

**Problem:** Logos owns the phasis eidos and all phasis praxeis (`emit-phasis`, `reply-to`, `list-phaseis`, `get-thread`), but the phasis composition mold and phasis bonds are still defined in thyra — a residue from before phasis moved to logos.

**Current state:**
- `genesis/thyra/typos/thyra.yaml` line 151: defines `typos-def-phasis` (used by `logos/emit-phasis` and `aither/apply-phasis-sync`)
- `genesis/thyra/desmoi/thyra.yaml`: defines `desmos/phasis-in`, `desmos/in-reply-to`, `desmos/derives-from`, `desmos/contributes-to`
- `genesis/logos/`: has `eide/`, `praxeis/`, `render-specs/` but **no `desmoi/` or `typos/` directories**
- `genesis/logos/manifest.yaml` line 59–61: claims to provide `in-reply-to` and `phasis-in` desmoi but has no `desmoi/` content_path

**Fix:**

1. Create `genesis/logos/desmoi/logos.yaml` with the 4 phasis desmoi:
   - Move `desmos/phasis-in` from thyra/desmoi/thyra.yaml
   - Move `desmos/in-reply-to` from thyra/desmoi/thyra.yaml
   - Move `desmos/derives-from` from thyra/desmoi/thyra.yaml
   - Move `desmos/contributes-to` from thyra/desmoi/thyra.yaml

2. Create `genesis/logos/typos/logos.yaml` with `typos-def-phasis`:
   - Move the definition from thyra/typos/thyra.yaml line 151

3. Update `genesis/logos/manifest.yaml`:
   - Add `desmoi/` content_path entry
   - Add `typos/` content_path entry

4. Remove the moved definitions from thyra's files

5. Verify: `typos-def-phasis` is still resolvable by logos/emit-phasis and aither/apply-phasis-sync after the move (bootstrap loads by ID, not by file path)

**Principle:** The topos that introduces an eidos owns its composition mold (typos) and its structural bonds (desmoi). Logos introduces phasis; logos should own typos-def-phasis and phasis desmoi.

---

### Fix 7: My-Nodes — Manifest content_types Stale

**Problem:** `genesis/my-nodes/manifest.yaml` line 36 declares:
```yaml
content_types: [layout, panel, node, service-instance, kosmos-instance]
```

The `entities/layout.yaml` file contains `eidos: mode` entities (modern architecture), not `layout` or `panel` entities. The content_types list doesn't match the actual content.

**Fix:** In `genesis/my-nodes/manifest.yaml`:
- Change content_types to match actual content: `[mode]`
- Add a `render-specs/` content_path entry (the directory exists but isn't declared in manifest):
  ```yaml
  - path: render-specs/
    content_types: [render-spec]
  ```

---

## Documentation — Stale References

### Fix 8: Hypostasis DESIGN.md — Stale Attainment Documentation

**Problem:** `genesis/hypostasis/DESIGN.md` documents `attainment/manage-credentials` as belonging to hypostasis, but this attainment was moved to `genesis/credentials/eide/credentials.yaml`. The note in `genesis/hypostasis/eide/hypostasis.yaml` correctly acknowledges the move, but DESIGN.md wasn't updated.

**Fix:** In `genesis/hypostasis/DESIGN.md`, update the attainment documentation to note that `manage-credentials` moved to the credentials topos. Keep the cross-reference but don't document it as hypostasis-owned.

---

## Completeness Gaps — Missing But Not Broken

These are not bugs — bootstrap succeeds without them. They are gaps relative to the standard set by complete topoi like aither.

### Gap 1: Psyche — Missing prospect-item Render-Spec

**Problem:** Psyche has card+item pairs for attention, intention, mood, and kairos, but prospect only has `render-spec/prospect-card` — no `prospect-item` for list views.

**Fix:** Create `genesis/psyche/render-specs/prospect-item.yaml` following the same pattern as `kairos-item.yaml` — compact row with valence icon, description, and likelihood badge.

---

### Gap 2: Oikos — No Reconciler

**Problem:** Oikos defines session, conversation, and insight entities with lifecycle states, but has no reconciler for detecting drift. For example, a session marked "active" that has actually timed out won't be detected.

**Fix:** When the reactive loop is operational, add a `reconciler/session-liveness` to `genesis/oikos/reconcilers/` that senses session actuality and reconciles intent vs. status. Not urgent — oikos works without it, and the reconciler infrastructure (PROMPT-REACTIVE-LOOP.md) needs to be operational first.

---

### Gap 3: Demiurge + Manteia — No Render-Specs

**Problem:** Neither demiurge nor manteia has a `render-specs/` directory. Their entities (artifacts, compositions, inference results, evaluation criteria) have no UI presentation.

**Fix:** When these topoi need spatial presence, create render-specs following the standard card+item pattern. Lower priority than topoi that already face users (psyche, thyra, nous).

For demiurge, useful render-specs would be:
- `artifact-card.yaml` — showing composed artifact with provenance and cache status
- `composition-item.yaml` — compact list view of recent compositions

For manteia:
- `generation-card.yaml` — showing governed-inference result with approval status
- `criteria-card.yaml` — evaluation criterion display

---

### Gap 4: Hodos — Underutilized

**Problem:** Hodos has rich praxeis for journey navigation (branching, form validation, waypoint sensing) but only 2 render-specs and limited cross-topos integration. It is architecturally sound but dormant — a topos waiting for the reactive loop and active user journeys to bring it alive.

**Not a fix — an observation:** Hodos will naturally gain utilization when:
1. Onboarding journeys are active (thyra/entities/onboarding.yaml references hodos)
2. The reactive loop enables autonomous waypoint progression
3. More topoi define journeys that need guided navigation

---

## Implementation Order

**Critical (do first — enables bootstrap):**
1. Fix 1: Psyche typos (3 missing) — enables 3 praxeis
2. Fix 2: Soma desmos signal→body-signal — fixes bond validation
3. Fix 3: Soma typos (2 missing) — enables 2 praxeis

**Bugs (do next — corrects behavior):**
4. Fix 4: Journey card on_click — one-line fix
5. Fix 5: Psyche phantom on_click — remove 3 handlers

**Structural (do when convenient — improves architecture):**
6. Fix 6: Logos phasis ownership — move typos + desmoi from thyra
7. Fix 7: My-nodes manifest — update content_types

**Documentation (do anytime):**
8. Fix 8: Hypostasis DESIGN.md — update attainment note

**Completeness (do when the topos needs it):**
9. Gap 1: Psyche prospect-item render-spec
10. Gap 2: Oikos reconciler (after reactive loop)
11. Gap 3: Demiurge + manteia render-specs (when UI needed)
12. Gap 4: Hodos utilization (organic, not forced)

---

## Verification

```bash
# 1. All typos references resolve
grep -r 'typos_id:' genesis/psyche/praxeis/ | sed 's/.*typos_id: //' | sort -u
# Each should have a matching definition in genesis/psyche/typos/psyche.yaml

grep -r 'typos_id:' genesis/soma/praxeis/ | sed 's/.*typos_id: //' | sort -u
# Each should have a matching definition in genesis/soma/typos/soma.yaml

# 2. No 'signal' eidos reference in soma desmoi (should be body-signal)
grep 'from_eidos: signal' genesis/soma/desmoi/soma.yaml
# Should return: empty

# 3. No hodos/embark-journey reference
grep 'hodos/embark-journey' genesis/
# Should return: empty

# 4. No phantom on_click in psyche (if option a chosen)
grep 'on_click:.*psyche/' genesis/psyche/render-specs/
# Should return: empty

# 5. Logos owns phasis desmoi
grep -c 'desmos/phasis-in\|desmos/in-reply-to' genesis/logos/desmoi/logos.yaml
# Should return: 2

# 6. Thyra no longer defines phasis desmoi
grep 'desmos/phasis-in\|desmos/in-reply-to' genesis/thyra/desmoi/thyra.yaml
# Should return: empty

# 7. typos-def-phasis lives in logos
grep 'typos-def-phasis' genesis/logos/typos/logos.yaml
# Should return: 1 match

# 8. My-nodes manifest content_types updated
grep 'layout, panel' genesis/my-nodes/manifest.yaml
# Should return: empty

# 9. Bootstrap succeeds
# (In chora) cargo build && cargo test
```

---

## Cross-Reference to Other Prompts

Issues found in the review that are addressed by **separate prompts** (not duplicated here):

| Issue | Prompt |
|-------|--------|
| entities/ directory decomposition (~20 topoi) | `PROMPT-TOPOS-DIRECTORY-CONVENTION.md` |
| Release/dynamis duplicate praxeis, attainment, seeds | `PROMPT-RELEASE-DYNAMIS-BOUNDARY.md` |
| Politeia hud-region retirement | `PROMPT-THYRA-PRESENTATION.md` |
| Generative spiral entities/ smell resolved | `PROMPT-GENERATIVE-SPIRAL.md` (updated) |

---

## What This Fixes

After all fixes applied:
- 5 praxeis that currently fail at composition time will work (psyche: 3, soma: 2)
- Bond validation for body-signal entities will pass
- Journey card clicks will target the correct praxis
- No phantom UI handlers pointing at nonexistent operations
- Logos owns its full domain (eidos + typos + desmoi + praxeis + render-specs)
- My-nodes manifest accurately describes its content
- Documentation matches reality across all topoi

---

## Addendum: Verification-Round Fixes (2026-02-12)

After executing all 8 original fixes, a mechanical verification sweep found 26 additional issues across 4 categories. All have been resolved in-session.

### V1: Fix 3 Introduced Duplicates

**Problem:** Fix 3 added `typos-def-node` and `typos-def-service-instance` to `genesis/soma/typos/soma.yaml`, but richer definitions already existed in `genesis/dynamis/typos/deployment.yaml` (with defaults and bonds).

**Fix:** Removed the soma versions, added NOTE comment pointing to canonical definitions in dynamis.

### V2: 3 Missing Typos Definitions

| Topos | Missing | Eidos |
|-------|---------|-------|
| propylon | `typos-def-session-token` | session-token |
| politeia | `typos-def-sync-cursor` | sync-cursor |
| credentials | `typos-def-credential-attainment` | credential-attainment |

**Fix:** Added definitions. Created `genesis/credentials/typos/credentials.yaml` (new file).

### V3: 5 Phantom on_click Handlers (Beyond Psyche)

| File | Handler |
|------|---------|
| `ergon/render-specs/pragma-card.yaml` | `ergon/view-pragma` |
| `ergon/render-specs/reflex-card.yaml` | `ergon/view-reflex` |
| `nous/render-specs/inquiry-card.yaml` | `nous/view-inquiry` |
| `nous/render-specs/pattern-card.yaml` | `nous/view-pattern` |
| `release/render-specs/release-card.yaml` | `release/view-release` |

**Fix:** Replaced with `# on_click: {praxis} — praxis not yet implemented` comments.

### V4: 5 Manifest/Directory Mismatches

| Manifest | Issue |
|----------|-------|
| `credentials/manifest.yaml` | Listed phantom `desmoi/` path (no dir); missing `typos/` path |
| `dynamis/manifest.yaml` | Missing `actuality-modes/` and `seeds/` content_paths |
| `thyra/manifest.yaml` | Missing `definitions/` and `actuality-modes/` content_paths; stale desmoi in provides list |

**Fix:** All manifests updated to match actual directory structure.

### V5: 5 True Desmos Duplicates

| Duplicate ID | Canonical Location | Removed From |
|-------------|-------------------|--------------|
| `desmos/published-by` | demiurge/desmoi | oikos/desmoi |
| `desmos/baked-from` | demiurge/desmoi | oikos/desmoi |
| `desmos/attests-to` | demiurge/desmoi | oikos/desmoi |
| `desmos/distributes` | politeia/desmoi | oikos/desmoi |
| `desmos/sources-content-from` | genesis/desmoi | thyra/desmoi |

**Fix:** Removed duplicate definitions, added NOTE comments pointing to canonical locations. Updated `oikos/manifest.yaml` provides.desmoi list.

### V6: 6 Semantic ID Conflicts (Renamed)

| Old ID | Conflict | New ID | Rationale |
|--------|----------|--------|-----------|
| `desmos/present-in` (aither) | agora: presence→territory | `desmos/present-in-oikos` | Aither's is specifically oikos presence |
| `desmos/instantiates` (nous) | soma: parousia→prosopon | `desmos/exemplifies` | Nous's is about pattern exemplification |
| `desmos/derives-from` (demiurge) | logos: phasis→any | `desmos/forked-from` | Demiurge's is about topos fork lineage |
| `attainment/emit` (thyra) | genesis: full-circle emission | `attainment/actuate` | Thyra's is substrate-level actuation |
| `attainment/invite` (propylon) | politeia: governance policy | `attainment/manage-links` | Propylon's is mechanism, not policy |
| `attainment/distribute` (release) | politeia: topos distribution | `attainment/publish-release` | Release's is artifact channel upload |

**Files updated per rename:** Definition YAML (id + name + description), manifest (provides list), praxis bonds (requires-attainment / desmos references), DESIGN.md headings, REFERENCE.md tables. All verified clean — zero stale references remain.

### Verification-Round Summary

| Category | Count | Status |
|----------|-------|--------|
| Duplicate typos | 2 removed | DONE |
| Missing typos | 3 added | DONE |
| Phantom on_click | 5 commented | DONE |
| Manifest mismatches | 5 fixed | DONE |
| True desmos duplicates | 5 removed | DONE |
| Semantic ID conflicts | 6 renamed | DONE |
| **Total** | **26 issues** | **ALL RESOLVED** |
