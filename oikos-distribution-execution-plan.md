# Oikos Distribution Execution Plan

Implementation plans for [oikos-distribution-via-circles.md](oikos-distribution-via-circles.md).

---

## Kosmos Execution Plan

All work in `kosmos/genesis/`. Ontology definitions only.

### K1: Circle Kind Simplification

**File:** `genesis/politeia/eide/politeia.yaml`

Update circle eidos to use new kinds:

```yaml
# Before
kind:
  type: string
  enum: [self, intimate, community, public]

# After
kind:
  type: string
  enum: [self, peer, commons]
  description: |
    - self: Individual dwelling
    - peer: Collaborative creation (cannot distribute externally)
    - commons: Distribution circle (grants oikoi + attainments)
```

**Dependencies:** None
**Breaks:** Existing circles with kind=intimate or kind=community

---

### K2: Distributes Desmos

**File:** `genesis/politeia/desmoi/politeia.yaml`

Add (or verify exists) the `distributes` desmos:

```yaml
- id: distributes
  description: |
    Circle distributes an oikos-prod to its members.
    When a user joins a circle, they receive all oikoi the circle distributes.
    Only commons circles can have this bond.
  from_eidos: [circle]
  to_eidos: [oikos-prod]
  cardinality: many-to-many
```

**Dependencies:** K1 (kind=commons)
**Breaks:** None (additive)

---

### K3: Sync Circle Oikoi Praxis

**File:** `genesis/politeia/praxeis/politeia.yaml`

Add praxis to install oikoi when joining a circle:

```yaml
- eidos: praxis
  id: praxis/politeia/sync-circle-oikoi
  data:
    oikos: politeia
    name: sync-circle-oikoi
    visible: false  # Internal, called by join flow
    tier: 2
    description: |
      Sync oikoi distributed by a circle to the local installation.
      Called when joining a circle or when dwelling and circle has updates.
    params:
      - name: circle_id
        type: string
        required: true
    steps:
      # Trace oikoi distributed by this circle
      - step: trace
        from_id: "$circle_id"
        desmos: "distributes"
        direction: "outbound"
        bind_to: distributed_oikoi

      # For each oikos-prod, check if installed and install if not
      - step: for_each
        items: "$distributed_oikoi"
        as: oikos_prod
        do:
          - step: call
            praxis: politeia/install-oikos-if-needed
            params:
              oikos_prod_id: "$oikos_prod.id"

      - step: return
        value:
          circle_id: "$circle_id"
          oikoi_synced: "{{ $distributed_oikoi | length }}"
```

**Dependencies:** K2 (distributes desmos)
**Breaks:** None (additive)

---

### K4: Install Oikos If Needed Praxis

**File:** `genesis/politeia/praxeis/politeia.yaml`

Add helper praxis for conditional oikos installation:

```yaml
- eidos: praxis
  id: praxis/politeia/install-oikos-if-needed
  data:
    oikos: politeia
    name: install-oikos-if-needed
    visible: false
    tier: 2
    description: |
      Install an oikos-prod if not already installed locally.
      Checks local version, fetches if missing or outdated.
    params:
      - name: oikos_prod_id
        type: string
        required: true
    steps:
      # Find the oikos-prod
      - step: find
        id: "$oikos_prod_id"
        bind_to: oikos_prod

      - step: assert
        condition: "$oikos_prod"
        message: "Oikos-prod not found: $oikos_prod_id"

      # Check if already installed (trace uses-oikos from dwelling circle)
      - step: trace
        from_id: "$_circle"
        desmos: "uses-oikos"
        direction: "outbound"
        bind_to: installed_oikoi

      - step: filter
        items: "$installed_oikoi"
        condition: "$item.id == $oikos_prod_id"
        bind_to: already_installed

      # If not installed, install it
      - step: switch
        cases:
          - when: "{{ $already_installed | length }} == 0"
            then:
              - step: call
                praxis: politeia/install-oikos
                params:
                  oikos_id: "$oikos_prod_id"
                bind_to: install_result
              - step: return
                value:
                  installed: true
                  oikos_prod_id: "$oikos_prod_id"

      - step: return
        value:
          installed: false
          oikos_prod_id: "$oikos_prod_id"
          reason: "already installed"
```

**Dependencies:** K3
**Breaks:** None (additive)

---

### K5: Update Accept-Invitation to Sync Oikoi

**File:** `genesis/politeia/praxeis/politeia.yaml`

Modify `accept-invitation` to call `sync-circle-oikoi` after joining:

```yaml
# Add to end of accept-invitation steps, before return:
- step: call
  praxis: politeia/sync-circle-oikoi
  params:
    circle_id: "$circle_id"
```

**Dependencies:** K3, K4
**Breaks:** None (extends existing)

---

### K6: Update Propylon Verify-Entry to Sync Oikoi

**File:** `genesis/propylon/praxeis/propylon.yaml`

Modify `verify-entry` to call `sync-circle-oikoi` after successful entry:

```yaml
# Add after member-of bond creation:
- step: call
  praxis: politeia/sync-circle-oikoi
  params:
    circle_id: "$circle_id"
```

**Dependencies:** K3, K4
**Breaks:** None (extends existing)

---

### K7: Oikos Update Reconciler

**File:** `genesis/politeia/praxeis/politeia.yaml` (or new reconciler file)

Add reconciler or praxis for checking oikos updates on dwell:

```yaml
- eidos: praxis
  id: praxis/politeia/reconcile-circle-oikoi
  data:
    oikos: politeia
    name: reconcile-circle-oikoi
    visible: false
    tier: 2
    description: |
      Reconcile oikoi versions when dwelling in a circle.
      Called on dwell-in to check for updates.
    params:
      - name: circle_id
        type: string
        required: true
    steps:
      # Get circle's current distributed oikoi
      - step: trace
        from_id: "$circle_id"
        desmos: "distributes"
        direction: "outbound"
        bind_to: distributed_oikoi

      # Get locally installed oikoi
      - step: trace
        from_id: "$circle_id"
        desmos: "uses-oikos"
        direction: "outbound"
        bind_to: installed_oikoi

      # Compare and update
      - step: for_each
        items: "$distributed_oikoi"
        as: oikos_prod
        do:
          - step: call
            praxis: politeia/update-oikos-if-newer
            params:
              oikos_prod_id: "$oikos_prod.id"
              installed_oikoi: "$installed_oikoi"

      - step: return
        value:
          reconciled: true
          circle_id: "$circle_id"
```

**Dependencies:** K3, K4
**Breaks:** None (additive)

---

### K8: Create Kosmos Commons Circle Definition

**File:** `genesis/spora/circles/kosmos-commons.yaml` (new)

Define the primary distribution circle:

```yaml
- eidos: circle
  id: circle/kosmos-commons
  data:
    name: Kosmos Commons
    description: |
      The primary distribution circle for the kosmos.
      Join to receive all standard oikoi.
    kind: commons

# Distributes bonds (created at runtime, but documented here)
# circle/kosmos-commons --distributes--> oikos-prod/nous-*
# circle/kosmos-commons --distributes--> oikos-prod/soma-*
# etc.
```

**Dependencies:** K1, K2
**Breaks:** None (additive)

---

### Kosmos Execution Order

```
K1: Circle kind simplification
 │
 v
K2: Distributes desmos
 │
 v
K3: sync-circle-oikoi praxis
 │
 v
K4: install-oikos-if-needed praxis
 │
 ├──────────────────┐
 v                  v
K5: Update          K6: Update
accept-invitation   verify-entry
 │                  │
 └────────┬─────────┘
          v
K7: Oikos update reconciler
          │
          v
K8: Kosmos commons circle definition
```

---

## Chora Execution Plan

All work in `chora/`. Rust + TypeScript implementation.

### C1: Substrate Oikos Manifest

**File:** `chora/substrate-manifest.yaml` (new)

Define which oikoi are built into Thyra:

```yaml
# Oikoi included in Thyra substrate
# Per whole oikos rule: entire oikos or nothing

substrate_oikoi:
  - arche           # Grammar (eidos, desmos, stoicheion)
  - propylon        # Entry via links
  - hypostasis      # Keys, signatures, mnemonic, sync
  - politeia        # Circles, membership, attainments

# Everything else is circle-distributed
# These load from circles, not from genesis at bootstrap
```

**Dependencies:** None
**Breaks:** None (new file)

---

### C2: Bootstrap Logic — Selective Loading

**File:** `crates/kosmos/src/bootstrap.rs`

Modify bootstrap to only load substrate oikoi:

```rust
// Before: load all oikoi from genesis/
// After: load only oikoi listed in substrate-manifest.yaml

fn bootstrap_genesis(db: &Database, genesis_path: &Path) -> Result<()> {
    let substrate_oikoi = load_substrate_manifest()?;

    for oikos_dir in genesis_path.read_dir()? {
        let oikos_id = oikos_dir.file_name();

        // Only load substrate oikoi at bootstrap
        if substrate_oikoi.contains(&oikos_id) {
            load_oikos(db, oikos_dir.path())?;
        }
        // Others will be loaded via circle distribution
    }

    Ok(())
}
```

**Dependencies:** C1
**Breaks:** All non-substrate oikoi no longer available at startup

---

### C3: Oikos Fetch Stoicheion

**File:** `crates/kosmos/src/interpreter/steps.rs`

Add stoicheion for fetching oikos content:

```rust
// New stoicheion: fetch_oikos
// Fetches oikos-prod content from remote (phoreta or direct)

impl FetchOikosStep {
    pub fn execute(&self, scope: &mut Scope, ctx: &StepContext<'_>) -> Result<StepResult> {
        let oikos_prod_id = scope.eval(&self.oikos_prod_id)?;

        // Find oikos-prod entity (may be a stub with URL)
        let oikos_prod = ctx.db.find(&oikos_prod_id)?;

        // Fetch content from remote
        let content = fetch_oikos_content(&oikos_prod)?;

        // Verify signature
        verify_oikos_signature(&content, &oikos_prod)?;

        // Install into local db
        install_oikos_content(ctx.db, &content)?;

        Ok(StepResult::Continue)
    }
}
```

**Dependencies:** None
**Breaks:** None (additive)

---

### C4: Oikos Installation Logic

**File:** `crates/kosmos/src/oikos.rs` (new or extend existing)

Implement oikos installation:

```rust
pub fn install_oikos_content(db: &Database, content: &OikosContent) -> Result<()> {
    // Load all eide
    for eidos in &content.eide {
        db.upsert_eidos(eidos)?;
    }

    // Load all desmoi
    for desmos in &content.desmoi {
        db.upsert_desmos(desmos)?;
    }

    // Load all praxeis
    for praxis in &content.praxeis {
        db.upsert_praxis(praxis)?;
    }

    // Create uses-oikos bond from dwelling circle
    db.bind(dwelling_circle_id, content.oikos_id, "uses-oikos")?;

    Ok(())
}
```

**Dependencies:** C3
**Breaks:** None (additive)

---

### C5: Signature Verification

**File:** `crates/kosmos/src/oikos.rs`

Implement oikos-prod signature verification:

```rust
pub fn verify_oikos_signature(content: &OikosContent, oikos_prod: &Entity) -> Result<()> {
    let signature = oikos_prod.data.get("signature")?;
    let publisher_pubkey = oikos_prod.data.get("publisher_pubkey")?;

    // Compute content hash
    let content_hash = blake3::hash(&content.serialize()?);

    // Verify Ed25519 signature
    let pubkey = PublicKey::from_bytes(publisher_pubkey)?;
    let sig = Signature::from_bytes(signature)?;

    pubkey.verify(&content_hash, &sig)?;

    Ok(())
}
```

**Dependencies:** C4
**Breaks:** None (additive)

---

### C6: Reconciler Loop for Oikos Updates

**File:** `crates/kosmos/src/reconciler/oikos.rs` (new)

Implement reconciler that checks for oikos updates on dwell:

```rust
pub struct OikosReconciler;

impl Reconciler for OikosReconciler {
    fn trigger(&self) -> ReconcilerTrigger {
        ReconcilerTrigger::OnDwell
    }

    fn reconcile(&self, ctx: &ReconcilerContext) -> Result<()> {
        let circle_id = ctx.dwelling_circle();

        // Get distributed oikoi
        let distributed = ctx.db.trace(circle_id, "distributes", Direction::Outbound)?;

        // Get installed oikoi
        let installed = ctx.db.trace(circle_id, "uses-oikos", Direction::Outbound)?;

        // Compare versions, update if needed
        for oikos_prod in distributed {
            if needs_update(&oikos_prod, &installed) {
                // Fetch and install newer version
                let content = fetch_oikos_content(&oikos_prod)?;
                verify_oikos_signature(&content, &oikos_prod)?;
                install_oikos_content(ctx.db, &content)?;
            }
        }

        Ok(())
    }
}
```

**Dependencies:** C3, C4, C5
**Breaks:** None (additive)

---

### C7: Thyra Build Configuration

**File:** `chora/Cargo.toml`, `chora/build.rs`

Update build to only include substrate oikoi:

```toml
# Cargo.toml
[features]
default = ["substrate-only"]
substrate-only = []  # Only bundle substrate oikoi
full-genesis = []    # Bundle all genesis (for development)
```

```rust
// build.rs
fn main() {
    if cfg!(feature = "substrate-only") {
        // Only copy substrate oikoi to bundle
        copy_substrate_oikoi();
    } else {
        // Copy all genesis (development mode)
        copy_all_genesis();
    }
}
```

**Dependencies:** C1, C2
**Breaks:** Production builds no longer have all oikoi

---

### C8: First-Run UI

**File:** `app/src/components/FirstRun.tsx` (or similar)

Update UI for bare Thyra experience:

```typescript
// First-run screen when no circles joined
function FirstRun() {
    return (
        <div>
            <h1>Welcome to Thyra</h1>
            <p>To begin, you'll need an invitation link from someone
               who is already part of the kosmos.</p>

            <PasteLinkInput onLink={handleInvitationLink} />

            <p>Or scan a QR code:</p>
            <QRScanner onScan={handleInvitationLink} />
        </div>
    );
}
```

**Dependencies:** C2 (bare Thyra)
**Breaks:** None (new screen)

---

### C9: Oikos Update Notification UI

**File:** `app/src/components/OikosUpdateNotification.tsx` (new)

UI for showing oikos updates (if prompted mode):

```typescript
function OikosUpdateNotification({ updates }: { updates: OikosUpdate[] }) {
    return (
        <div>
            <h3>Oikos Updates Available</h3>
            {updates.map(update => (
                <div key={update.oikos_id}>
                    <span>{update.name}: {update.from_version} → {update.to_version}</span>
                    <button onClick={() => applyUpdate(update)}>Update</button>
                </div>
            ))}
            <button onClick={() => applyAllUpdates(updates)}>Update All</button>
        </div>
    );
}
```

**Dependencies:** C6 (reconciler)
**Breaks:** None (additive)

---

### Chora Execution Order

```
C1: Substrate manifest
 │
 v
C2: Bootstrap selective loading
 │
 ├──────────────────┐
 v                  v
C3: fetch_oikos     C7: Build config
stoicheion          │
 │                  v
 v                C8: First-run UI
C4: Install logic
 │
 v
C5: Signature verification
 │
 v
C6: Reconciler loop
 │
 v
C9: Update notification UI
```

---

## Integration Testing

After both plans complete:

1. **Build bare Thyra** (substrate-only)
2. **Create test circle** with distributed oikoi
3. **Generate invitation link** from existing user
4. **Test first-run flow**:
   - Install bare Thyra
   - Paste invitation link
   - Video verify
   - Join circle
   - Verify oikoi install automatically
5. **Test update flow**:
   - Update circle's distributed oikos version
   - Verify members receive update on dwell

---

*Drafted 2026-01-28*
