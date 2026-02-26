# Bootstrap & Genesis

How the kosmos world comes into being from a fresh database. Bootstrap runs once per database initialization, creating all constitutional entities from the genesis seed specification. For the conceptual framing, see [Genesis: Bootstrap](../explanation/genesis/bootstrap.md).

## Trigger

Bootstrap runs at kosmos-mcp startup when `genesis/spora/spora.yaml` exists:

```
kosmos-mcp starts
  → HostContext::new(db_path)         # Opens SQLite
  → bootstrap_from_spora_with_options()
    → ctx.enter_bootstrap_mode()      # Reflexes dormant
    → verify spora signature (Ed25519)
    → establish germination context:
        prosopon:  from genesis_root.expressed_by
        oikos:     primordial (oikos/kosmos, created in stage 3)
        session:   germination session (created in stage 0)
        attainment: genesis-root signature = authorization
    → parse spora.yaml
    → execute stages in order (all through composition path)
    → load topos content (all through composition path)
    → ctx.exit_bootstrap_mode()       # Reflexes awaken
  → MCP server ready
```

**File:** `crates/kosmos/src/bootstrap.rs`

Reflexes (autonomic responses to entity changes) are dormant during bootstrap to prevent interference with constitution. They awaken once all stages complete.

### Germination Context

Every entity that arises — even during bootstrap — arises in context: who, where, when, by what right. The spora carries the primordial context:

- **Who**: `genesis_root.expressed_by` (prosopon/victor) — the signer
- **Where**: The primordial oikos (established as entities are created)
- **When**: The germination session (a session entity created at bootstrap start)
- **By what right**: The Ed25519 signature on the genesis root phasis

The context entities (prosopon, oikos, session) don't exist in the database until their stages create them. But the spora itself IS the authorization — verified by signature, carried from outside the database. Once the context entities exist, retroactive bonds connect them. The spora is the egg that hatches the chicken.

---

## The Genesis Root

The first entity created. All provenance chains terminate here.

```yaml
genesis_root:
  id: phasis/genesis-root
  content: "for my babe, for the liberation of all. ever. eternally."
  expressed_by: prosopon/victor
  signature: <ed25519 signature>
  public_key: <public key>
  algorithm: ed25519
```

Every entity created during bootstrap gets an `authorized-by` bond to this phasis, a `composed-from` bond to its definition, and a `typed-by` bond to its eidos. Genesis provenance is graph-traversable — never embedded as metadata in entity data.

---

## Germination Stages

Stages execute in order by their `order` field. Each stage creates entities and bonds.

| Order | Stage | What It Creates |
|-------|-------|-----------------|
| 0 | **prime** | `eidos/eidos` — the self-grounding form (an eidos IS an eidos) |
| 10 | **archai** | 14 foundational eide: eidos, desmos, stoicheion, topos, praxis, theoria, principle, pattern, typos, artifact, function, genesis-record, render-spec, renderer |
| 15 | **desmoi** | 14 foundational bond types: authorized-by, composed-from, typed-by, provides-function, inhabits, contains, emerges-from, exists-in, dwells-in, stewards, member-of, belongs-to, grounds, enacts |
| 18 | **dynamis** | Substrate domains + functions (~50 entities): db, aisthesis, fs, net, crypto, manteia, process, time, webrtc, dns |
| 20 | **presence** | 3 presence eide: prosopon, parousia, oikos |
| 30 | **founder** | Founder entities: `prosopon/victor`, `prosopon/claude`, `oikos/victor-self`, `oikos/kosmos` + membership bonds |
| 35 | **politeia** | Foundation attainments, HUD regions, affordances, render-types, renderers (~30 attainments, ~150 bonds) |
| 50 | **marker** | `genesis-marker/spora` — records that germination completed |

### Entity Creation Per Stage

Each compose step creates an entity through the same composition path used at runtime:
1. Composes entity data from the step's definition
2. Creates the entity via `compose_entity()` — the single arise path
3. Creates `composed-from` bond to the spora definition
4. Creates `authorized-by` bond to the stage's authorizing phasis
5. Creates `typed-by` bond to the entity's eidos (except eidos entities)
6. Creates any additional bonds declared in the step

Bootstrap does not bypass composition. The spora IS the definition. The germination session IS the context. Every entity, even constitutional ones, arises through the same path as runtime entities.

---

## Post-Stage Loading

After all stages complete, bootstrap discovers and loads topos content:

### 1. Content Root Entities
From `spora.yaml` `content_roots` section:
- `content-root/arche` (order 0) — Constitutional grammar
- `content-root/topoi` (order 10) — Topos manifests

Each becomes a `content-root` entity with `authorized-by` and `typed-by` bonds.

### 2. Topos Discovery
Scans `genesis/*/manifest.yaml` to find all topoi. Each manifest declares:
- `content_paths` — directories containing eide, desmoi, praxeis, etc.
- `requires_dynamis` — substrate capabilities needed
- `provides` — what the topos contributes to the world
- `depends_on` — other topoi it requires

### 3. Topos Content Loading
For each discovered topos, loads content from declared directories:

| Directory | Content Type |
|-----------|-------------|
| `eide/` | Type definitions |
| `desmoi/` | Bond type definitions |
| `praxeis/` | Operation definitions |
| `typos/` | Composition templates |
| `entities/` | Concrete entity instances |
| `render-specs/` | UI specifications |

---

## Genesis Directory Structure

```
genesis/                          # Symlink to ../kosmos/genesis
├── spora/
│   └── spora.yaml               # The seed specification
├── arche/                        # Constitutional forms
│   ├── eide/*.yaml              # Core type schemas
│   ├── desmoi/*.yaml            # Core bond type schemas
│   └── functions.yaml           # Expression functions
├── <topos-name>/                # Each topos (24+ domains)
│   ├── manifest.yaml            # Identity, deps, content paths
│   ├── eide/*.yaml
│   ├── desmoi/*.yaml
│   ├── praxeis/*.yaml
│   ├── render-specs/*.yaml
│   └── ...
└── klimax/                      # Scale classification
    ├── 1-kosmos/
    ├── 2-physis/
    ├── 3-polis/
    ├── 4-oikos/
    ├── 5-soma/
    ├── 6-psyche/
    └── nous/
```

---

## spora.yaml Format

Version 2.0. Key sections:

```yaml
format_version: "2.0"

genesis_root:
  id: phasis/genesis-root
  content: "..."
  expressed_by: prosopon/victor
  signature: "..."
  public_key: "..."

content_roots:
  - id: content-root/arche
    path: arche/
    constitutional: true
    order: 0

stages:
  - name: stage-0-prime
    order: 0
    authorized_by: phasis/genesis-root
    steps:
      - compose:
          target_eidos: eidos
          id: eidos/eidos
          data: { name: "eidos", ... }
```

---

## Founder Entities

Created in stage 3 (order 30):

| Entity | Kind | Home Oikos |
|--------|------|-------------|
| `prosopon/victor` | human | `oikos/victor-self` |
| `prosopon/claude` | ai | `oikos/kosmos` |
| `oikos/victor-self` | self | — |
| `oikos/kosmos` | commons | — |

Bonds:
- `prosopon/victor member-of oikos/kosmos`
- `prosopon/victor member-of oikos/victor-self`
- `prosopon/claude member-of oikos/kosmos`
- `oikos/kosmos grants-attainment attainment/mcp-essential`

**Important:** Founder prosopa exist in genesis, but `check_launch_state()` returns a `ProsoponInfo` list with `has_keyring` status for each prosopon. Thyra's WelcomeScreen uses this to present entry path options: "Unlock" (if keyring exists), "Recover existing identity" (if human prosopon has no keyring), or "Create new identity". The app does NOT auto-arise or auto-route — the user explicitly chooses their entry path. Authentication is required before the main app is accessible. See [session-identity](session-identity.md).

---

## Bootstrap Result

```rust
pub struct BootstrapResult {
    pub entities_created: usize,      // ~500-1000
    pub bonds_created: usize,         // ~1500-3000
    pub manifests_loaded: Vec<String>,
    pub manifest_warnings: Vec<String>,
    pub stages_completed: usize,
}
```

---

## Configuration

| Env Variable | Default | Description |
|-------------|---------|-------------|
| `KOSMOS_SPORA` | `genesis/spora/spora.yaml` | Path to seed specification |
| `KOSMOS_VALIDATE_DYNAMIS` | `false` | Strict dynamis requirement checking |

There is one path for entity creation: the composition path via `compose_entity()`. There are no feature flags for selecting between Rust and WASM arise implementations. The WASM stoicheion (`tier2-db-arise.wat`) is the mechanism; the composition contract is the protocol.
