# Release–Dynamis Boundary — Completing the Separation

*Prompt for Claude Code in the kosmos repository context.*

*Completes the partial migration of release lifecycle concerns from dynamis to the release topos. The eide moved; the praxeis, attainments, seeds, and desmoi did not. After this work, release owns the artifact lifecycle (build → distribute), dynamis owns the deployment lifecycle (distribute → run), and neither duplicates the other.*

---

## Architectural Principle — Build vs. Run

Two distinct lifecycle concerns were conflated in dynamis:

| Concern | Owner | Lifecycle |
|---------|-------|-----------|
| **Release** (artifact lifecycle) | release topos | create → build → register artifacts → distribute to channels |
| **Deployment** (running lifecycle) | dynamis topos | select release → target substrate → manifest → sense → reconcile |

Release answers: "Is the artifact available for download?" Dynamis answers: "Is the software running where it should?" The boundary is the distribution channel — release puts the artifact there, dynamis picks it up.

---

## Current State — Partial Migration

The release eide were moved to `genesis/release/eide/release.yaml`, and dynamis has a comment acknowledging this (line 44–45 of `genesis/dynamis/eide/dynamis.yaml`). But the migration stopped there:

### Duplicated attainment

`attainment/release` is defined in **both** topoi:
- `genesis/dynamis/eide/dynamis.yaml` line 265 — grants 4 dynamis-namespaced praxeis
- `genesis/release/eide/release.yaml` line 181 — grants 5 release-namespaced praxeis

Two entities with the same ID (`attainment/release`) will conflict at bootstrap.

### Duplicated praxeis

Six release-lifecycle praxeis exist in **both** namespaces:

| Operation | dynamis (`praxis/dynamis/`) | release (`praxis/release/`) |
|-----------|---------------------------|----------------------------|
| Create release | `create-release` | `create-release` |
| Register artifact | `register-artifact` | `register-artifact` |
| Mark built | `mark-release-built` | `mark-built` |
| Distribute | `distribute-release` | `distribute` |
| Sense release | `sense-release` | `sense-release` |
| Reconcile release | `reconcile-release` | `reconcile-release` |

Release also has `list-releases` and `get-release` (query praxeis not in dynamis).

### Misplaced seeds

Dynamis manifest (lines 95–96) declares seeds for `distribution-channel/thyra-r2` and `distribution-channel/github-releases`, but the `distribution-channel` eidos is owned by release.

### Overlapping desmoi

Both manifests list `contains-artifact` and `distributed-via`. These are release-domain bonds (release → artifact, release → channel).

### Documentation drift

- `genesis/release/DESIGN.md` line 166 says `attainment/release (defined in dynamis)` — stale.
- `genesis/dynamis/DESIGN.md` documents release praxeis alongside deployment praxeis.
- `genesis/dynamis/manifest.yaml` line 85 says `NOTE: release, distribute attainments moved to release topos` — but the praxeis and attainment definition were not actually moved.

---

## Target State

After cleanup:

### Release topos owns:
- **Eide:** release, release-artifact, distribution-channel (already done)
- **Attainment:** `attainment/release`, `attainment/publish-release`
- **Praxeis:** All artifact lifecycle praxeis under `praxis/release/` namespace
- **Desmoi:** `contains-artifact`, `distributed-via`
- **Seeds:** `distribution-channel/thyra-r2`, `distribution-channel/github-releases`

### Dynamis topos owns:
- **Eide:** reconciler, substrate, deployment, actuality-record
- **Attainments:** `attainment/substrate`, `attainment/deploy`, `attainment/reconcile` (and others)
- **Praxeis:** `create-substrate`, `create-deployment`, `manifest-deployment`, `sense-deployment`, `reconcile-deployment`
- **Desmoi:** `targets-substrate`, `deploys-release`, `targets`, `targets-node`, `manifests-as`, `has-actuality`, etc.
- **Seeds:** `substrate/mac-universal`, `substrate/windows-x64`, `substrate/linux-x64`

The bridge: `desmos/deploys-release` (deployment → release). Dynamis references release entities through this bond — it doesn't own them.

---

## Changes

### 1. Remove release praxeis from dynamis

**File:** `genesis/dynamis/praxeis/dynamis.yaml`

Delete 6 praxeis:
- `praxis/dynamis/create-release` (starts around line 19)
- `praxis/dynamis/register-artifact` (starts around line 75)
- `praxis/dynamis/mark-release-built` (starts around line 156)
- `praxis/dynamis/distribute-release` (starts around line 317)
- `praxis/dynamis/sense-release` (starts around line 422)
- `praxis/dynamis/reconcile-release` (starts around line 488)

Keep all deployment praxeis (`create-deployment`, `manifest-deployment`, `sense-deployment`, `reconcile-deployment`), substrate praxeis, and infrastructure praxeis.

### 2. Remove attainment/release from dynamis

**File:** `genesis/dynamis/eide/dynamis.yaml`

Delete the `attainment/release` definition (line 265). The canonical definition lives in `genesis/release/eide/release.yaml`.

Also remove `attainment/publish-release` and `attainment/channel` if they exist in dynamis — they belong to release.

### 3. Move distribution-channel seeds to release

**File:** `genesis/dynamis/manifest.yaml`

Remove from seeds:
```yaml
- distribution-channel/thyra-r2
- distribution-channel/github-releases
```

**File:** `genesis/release/manifest.yaml`

Add seeds section:
```yaml
seeds:
  - distribution-channel/thyra-r2
  - distribution-channel/github-releases
```

Check whether seed YAML files exist in `genesis/dynamis/seeds/` for these distribution channels. If so, move them to `genesis/release/seeds/` (create the directory if needed).

### 4. Clean dynamis manifest praxeis list

**File:** `genesis/dynamis/manifest.yaml`

Remove release-lifecycle praxeis from the praxeis list (lines 117–122):
```yaml
# Remove:
- create-release
- register-artifact
- mark-release-built
- distribute-release
- sense-release
- reconcile-release
```

Remove `channel` from attainments if present. Remove the NOTE comment (line 85) since the migration will be complete.

### 5. Clean dynamis manifest desmoi list

**File:** `genesis/dynamis/manifest.yaml`

Remove `contains-artifact` and `distributed-via` from desmoi list (lines 99, 101) — these are release-domain bonds. Keep `deploys-release` (deployment → release bridge bond).

### 6. Update dynamis desmoi definitions

**File:** `genesis/dynamis/desmoi/dynamis.yaml`

Remove `desmos/contains-artifact` and `desmos/distributed-via` definitions if they exist here. These should be defined in `genesis/release/desmoi/`.

Verify release has these desmoi defined. If release doesn't have a `desmoi/` directory, create it with the bond definitions.

### 7. Update documentation

**File:** `genesis/dynamis/DESIGN.md`
- Remove the release praxeis documentation section
- Keep the deployment section
- Note that dynamis consumes release entities via `deploys-release` bond

**File:** `genesis/release/DESIGN.md`
- Line 166: Change `attainment/release (defined in dynamis)` to `attainment/release`
- Update any other references to dynamis-namespaced praxeis

**File:** `genesis/dynamis/REFERENCE.md`
- Remove release praxis documentation (will be regenerated)

---

## Verification

```bash
# 1. No release-lifecycle praxeis remain in dynamis
grep -c 'praxis/dynamis/.*release\|praxis/dynamis/register-artifact\|praxis/dynamis/mark-release\|praxis/dynamis/distribute' genesis/dynamis/praxeis/dynamis.yaml
# Should return: 0

# 2. No duplicate attainment/release
grep -r 'id: attainment/release' genesis/dynamis/
# Should return: empty

# 3. No distribution-channel seeds in dynamis
grep 'distribution-channel' genesis/dynamis/manifest.yaml
# Should return: empty (or only in desmoi context)

# 4. Release manifest lists all its praxeis
grep -c 'release/' genesis/release/manifest.yaml
# Should list 8 praxeis

# 5. Bootstrap succeeds
# (In chora) cargo build && cargo test

# 6. No duplicate entity IDs
grep -rh 'id: attainment/release' genesis/*/eide/*.yaml | wc -l
# Should return: 1 (only in release)
```

---

## What This Enables

When the boundary is clean:
- **No bootstrap conflicts** — each entity ID is defined in exactly one place
- **Clear ownership** — "who handles releases?" → release topos. "Who handles deployments?" → dynamis topos.
- **The bridge is explicit** — `desmos/deploys-release` connects the two domains through the graph, not through shared praxeis
- **The generative spiral knows where to emit** — generating a release praxis? It goes in release/praxeis. Generating a deployment praxis? dynamis/praxeis.
- **Attainment scoping makes sense** — `attainment/release` gates artifact creation, `attainment/deploy` gates running instances. Different capabilities, different topoi.
