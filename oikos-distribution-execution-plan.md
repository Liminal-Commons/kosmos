# Oikos Distribution Execution Plan

Implementation plans for [oikos-distribution-via-circles.md](oikos-distribution-via-circles.md).

---

## Implementation Status

### v1 (Implemented 2026-01-28)

Simpler patterns using existing stoicheia:
- **K1 ✓** Circle kind simplification (`self`, `peer`, `commons`)
- **K2 ✓** Distributes desmos (circle → oikos-prod)
- **K3 ✓** sync-circle-oikoi (simplified, no try/catch)
- **K4 ✓** install-oikos-if-needed
- **K4.5 ✓** update-oikos-if-newer (string comparison, not semver)
- **K5 ✓** accept-invitation calls sync-circle-oikoi
- **K6 ✓** verify-entry calls sync-circle-oikoi
- **K7 ✓** reconcile-circle-oikoi (simplified, no append)
- **K8 ✓** kosmos-commons circle definition

### v2 (Implemented in Chora 2026-01-28)

Stoicheia added to chora:
- **try/catch ✓** — error handling in loops (Tier 2)
- **append ✓** — building arrays in loops (Tier 2)
- **log ✓** — diagnostic output with levels (Tier 2)

Praxis added:
- **K9 ✓** — `oikos/compare-semver` praxis (returns -1/0/1)

Schema update:
- **K0 ✓** — `fetch_url` field added to oikos-prod eidos

Pragmas resolved: `genesis/ergon/pragma/stoicheia-gaps.yaml`

### All Implemented

Both kosmos (K1-K8) and chora (stoicheia, K0, K9) work is complete.

---

## Kosmos Execution Plan

All work in `kosmos/genesis/`. Ontology definitions only.

### K0: Oikos-Prod Eidos Definition

**Status:** ✓ Complete (fetch_url added 2026-01-28)

**File:** `genesis/oikos/eide/oikos.yaml`

The oikos-prod eidos now has all required fields including `fetch_url`:

```yaml
# oikos-prod eidos fields
fields:
  oikos_id: string, required      # Oikos identifier
  version: string, required       # Semver version
  fetch_url: string, required     # URL where content can be fetched
  locale: string, optional        # BCP 47 locale
  description: string, optional   # Description
  manifest: object, required      # requires_dynamis, provides
  content: object, required       # eide, desmoi, praxeis (embedded)
  content_hash: string, required  # BLAKE3 hash
  signature: string, required     # Ed25519 signature
  publisher_pubkey: string, req   # Publisher's public key
  baked_from: string, optional    # Source oikos-dev ID
  published_at: integer, required # Timestamp
```

**Dependencies:** None
**Breaks:** None (additive field)

---

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

**Migration:** Circles with `intimate` → `peer`, circles with `community` → `commons`

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

**Dependencies:** K0 (oikos-prod eidos), K1 (kind=commons)
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
      Continues on individual oikos failures (best-effort sync).
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

      # Track sync results
      - step: set
        bind_to: sync_results
        value: []

      # For each oikos-prod, check if installed and install if not
      - step: for_each
        items: "$distributed_oikoi"
        as: oikos_prod
        do:
          - step: try
            do:
              - step: call
                praxis: politeia/install-oikos-if-needed
                params:
                  oikos_prod_id: "$oikos_prod.id"
                bind_to: install_result
              - step: append
                to: "$sync_results"
                value:
                  oikos_prod_id: "$oikos_prod.id"
                  success: true
                  result: "$install_result"
            catch:
              - step: append
                to: "$sync_results"
                value:
                  oikos_prod_id: "$oikos_prod.id"
                  success: false
                  error: "$_error"

      - step: return
        value:
          circle_id: "$circle_id"
          oikoi_synced: "{{ $sync_results | selectattr('success') | length }}"
          oikoi_failed: "{{ $sync_results | rejectattr('success') | length }}"
          results: "$sync_results"
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
        condition: "$item.data.name == $oikos_prod.data.name"
        bind_to: matching_installed

      # If not installed, install it
      - step: switch
        cases:
          - when: "{{ $matching_installed | length }} == 0"
            then:
              - step: call
                praxis: politeia/install-oikos
                params:
                  oikos_prod_id: "$oikos_prod_id"
                bind_to: install_result
              - step: return
                value:
                  action: "installed"
                  oikos_prod_id: "$oikos_prod_id"
                  version: "$oikos_prod.data.version"

      - step: return
        value:
          action: "skipped"
          oikos_prod_id: "$oikos_prod_id"
          reason: "already installed"
          installed_version: "{{ $matching_installed[0].data.version }}"
```

**Dependencies:** K3
**Breaks:** None (additive)

---

### K4.5: Update Oikos If Newer Praxis

**File:** `genesis/politeia/praxeis/politeia.yaml`

Add helper praxis for version-aware oikos updates:

```yaml
- eidos: praxis
  id: praxis/politeia/update-oikos-if-newer
  data:
    oikos: politeia
    name: update-oikos-if-newer
    visible: false
    tier: 2
    description: |
      Update an oikos if the distributed version is newer than installed.
      Uses semver comparison (major.minor.patch).
    params:
      - name: oikos_prod_id
        type: string
        required: true
      - name: installed_oikoi
        type: array
        required: true
        description: List of currently installed oikos entities
    steps:
      # Find the distributed oikos-prod
      - step: find
        id: "$oikos_prod_id"
        bind_to: oikos_prod

      - step: assert
        condition: "$oikos_prod"
        message: "Oikos-prod not found: $oikos_prod_id"

      # Find matching installed oikos by name
      - step: filter
        items: "$installed_oikoi"
        condition: "$item.data.name == $oikos_prod.data.name"
        bind_to: matching_installed

      # If not installed at all, install it
      - step: switch
        cases:
          - when: "{{ $matching_installed | length }} == 0"
            then:
              - step: call
                praxis: politeia/install-oikos
                params:
                  oikos_prod_id: "$oikos_prod_id"
              - step: return
                value:
                  action: "installed"
                  oikos_prod_id: "$oikos_prod_id"
                  version: "$oikos_prod.data.version"

      # Compare versions using semver
      - step: call
        praxis: arche/compare-semver
        params:
          version_a: "$oikos_prod.data.version"
          version_b: "{{ $matching_installed[0].data.version }}"
        bind_to: version_comparison

      # If distributed is newer, update
      - step: switch
        cases:
          - when: "$version_comparison.result == 'greater'"
            then:
              - step: call
                praxis: politeia/install-oikos
                params:
                  oikos_prod_id: "$oikos_prod_id"
              - step: return
                value:
                  action: "updated"
                  oikos_prod_id: "$oikos_prod_id"
                  from_version: "{{ $matching_installed[0].data.version }}"
                  to_version: "$oikos_prod.data.version"

      - step: return
        value:
          action: "skipped"
          oikos_prod_id: "$oikos_prod_id"
          reason: "installed version is current or newer"
          installed_version: "{{ $matching_installed[0].data.version }}"
          distributed_version: "$oikos_prod.data.version"
```

**Dependencies:** K4
**Breaks:** None (additive)

---

### K5: Update Accept-Invitation to Sync Oikoi

**File:** `genesis/politeia/praxeis/politeia.yaml`

Modify `accept-invitation` to call `sync-circle-oikoi` after joining:

```yaml
# Add to end of accept-invitation steps, before return:
# Note: sync errors do NOT block circle join - best effort
- step: try
  do:
    - step: call
      praxis: politeia/sync-circle-oikoi
      params:
        circle_id: "$circle_id"
      bind_to: sync_result
  catch:
    - step: log
      level: warn
      message: "Oikos sync failed after joining circle: $_error"
    - step: set
      bind_to: sync_result
      value:
        error: "$_error"
        oikoi_synced: 0
```

**Dependencies:** K3, K4, K4.5
**Breaks:** None (extends existing)

**Error Handling:** Sync failures are logged but do not prevent circle join. User can retry sync later.

---

### K6: Update Propylon Verify-Entry to Sync Oikoi

**File:** `genesis/propylon/praxeis/propylon.yaml`

Modify `verify-entry` to call `sync-circle-oikoi` after successful entry:

```yaml
# Add after member-of bond creation:
# Note: sync errors do NOT block entry verification - best effort
- step: try
  do:
    - step: call
      praxis: politeia/sync-circle-oikoi
      params:
        circle_id: "$circle_id"
      bind_to: sync_result
  catch:
    - step: log
      level: warn
      message: "Oikos sync failed after entry verification: $_error"
    - step: set
      bind_to: sync_result
      value:
        error: "$_error"
        oikoi_synced: 0
```

**Dependencies:** K3, K4, K4.5
**Breaks:** None (extends existing)

**Error Handling:** Same as K5 - sync failures don't block entry.

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
        from_id: "$_circle"
        desmos: "uses-oikos"
        direction: "outbound"
        bind_to: installed_oikoi

      # Track reconciliation results
      - step: set
        bind_to: reconcile_results
        value: []

      # Compare and update each
      - step: for_each
        items: "$distributed_oikoi"
        as: oikos_prod
        do:
          - step: try
            do:
              - step: call
                praxis: politeia/update-oikos-if-newer
                params:
                  oikos_prod_id: "$oikos_prod.id"
                  installed_oikoi: "$installed_oikoi"
                bind_to: update_result
              - step: append
                to: "$reconcile_results"
                value: "$update_result"
            catch:
              - step: append
                to: "$reconcile_results"
                value:
                  action: "failed"
                  oikos_prod_id: "$oikos_prod.id"
                  error: "$_error"

      - step: return
        value:
          reconciled: true
          circle_id: "$circle_id"
          results: "$reconcile_results"
          updated: "{{ $reconcile_results | selectattr('action', 'eq', 'updated') | length }}"
          installed: "{{ $reconcile_results | selectattr('action', 'eq', 'installed') | length }}"
          failed: "{{ $reconcile_results | selectattr('action', 'eq', 'failed') | length }}"
```

**Dependencies:** K4.5
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

### K9: Semver Comparison Praxis

**File:** `genesis/arche/praxeis/arche.yaml`

Add utility praxis for version comparison (used by K4.5):

```yaml
- eidos: praxis
  id: praxis/arche/compare-semver
  data:
    oikos: arche
    name: compare-semver
    visible: false
    tier: 1
    description: |
      Compare two semver version strings.
      Returns: greater, equal, or less (a compared to b).
    params:
      - name: version_a
        type: string
        required: true
      - name: version_b
        type: string
        required: true
    steps:
      # Parse versions into components
      - step: eval
        expression: |
          {% set a_parts = version_a.split('.') %}
          {% set b_parts = version_b.split('.') %}
          {% set a_major = a_parts[0] | int %}
          {% set a_minor = a_parts[1] | default('0') | int %}
          {% set a_patch = a_parts[2] | default('0') | split('-')[0] | int %}
          {% set b_major = b_parts[0] | int %}
          {% set b_minor = b_parts[1] | default('0') | int %}
          {% set b_patch = b_parts[2] | default('0') | split('-')[0] | int %}
          {% if a_major > b_major %}greater
          {% elif a_major < b_major %}less
          {% elif a_minor > b_minor %}greater
          {% elif a_minor < b_minor %}less
          {% elif a_patch > b_patch %}greater
          {% elif a_patch < b_patch %}less
          {% else %}equal{% endif %}
        bind_to: comparison_result

      - step: return
        value:
          version_a: "$version_a"
          version_b: "$version_b"
          result: "$comparison_result"
```

**Dependencies:** None (utility)
**Breaks:** None (additive)

---

### Kosmos Execution Order

```
K0: oikos-prod eidos definition
 │
 v
K1: Circle kind simplification
 │
 v
K2: Distributes desmos ←──────────────────┐
 │                                        │
 v                                        │
K3: sync-circle-oikoi praxis              │
 │                                        │
 v                                        │
K4: install-oikos-if-needed praxis        │
 │                                        │
 v                                        │
K4.5: update-oikos-if-newer praxis ←── K9: compare-semver
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

## Edge Cases and Error Handling

### Offline Mode

**Scenario:** User joins circle but is offline when sync runs.

**Handling:**
- K3/K5/K6 use `try/catch` — sync failures don't block join
- Failed syncs are logged with oikos_prod_id
- UI should show "X oikoi pending sync" indicator
- Reconciler (K7) will retry on next dwell when online

### Partial Failure

**Scenario:** Circle distributes 5 oikoi, 2 fail to install.

**Handling:**
- K3 continues through all oikoi (doesn't short-circuit)
- Returns detailed results: `oikoi_synced`, `oikoi_failed`, per-oikos status
- UI can show partial success: "3 of 5 oikoi installed"
- User can manually retry failed oikoi

### Version Rollback

**Scenario:** Circle admin distributes bad oikos version, needs rollback.

**Handling (not implemented in v1):**
- Admin updates circle's `distributes` bond to point to older oikos-prod
- Reconciler sees "newer" local version, does nothing (by design)
- For emergency rollback: new praxis `force-install-oikos` that ignores version check
- **Future work:** Add `oikos-history` entity to track version chain

### Circular Dependencies

**Scenario:** Oikos A depends on oikos B which depends on oikos A.

**Handling:**
- Current design doesn't model oikos dependencies explicitly
- **Future work:** Add `depends-on` desmos between oikos-prod entities
- Installation would need topological sort

---

## Integration Testing

After both plans complete:

### Test 1: Fresh Install Flow

1. **Build bare Thyra** (substrate-only feature)
2. **Verify:** Only arche, propylon, hypostasis, politeia available
3. **Generate invitation link** from existing user in kosmos-commons circle
4. **Install bare Thyra** on test machine
5. **Paste invitation link**
6. **Complete video verification**
7. **Verify:** Circle join succeeds
8. **Verify:** Distributed oikoi now available locally

### Test 2: Update Flow

1. **Setup:** User already in kosmos-commons with oikos-prod/nous v1.0.0
2. **Admin action:** Update kosmos-commons to distribute oikos-prod/nous v1.1.0
3. **User action:** Dwell in kosmos-commons (triggers reconciler)
4. **Verify:** nous updated to v1.1.0
5. **Verify:** UI shows update notification (if prompted mode)

### Test 3: Offline Resilience

1. **Setup:** User with bare Thyra, offline
2. **Action:** Paste invitation link (cached locally)
3. **Verify:** Entry request created, pending sync
4. **Action:** Go online, complete video verification
5. **Verify:** Oikoi sync runs after entry completes
6. **Verify:** If still offline at sync time, graceful failure logged

### Test 4: Partial Failure Recovery

1. **Setup:** Circle distributes 3 oikoi, one has invalid signature
2. **Action:** Join circle
3. **Verify:** 2 oikoi installed, 1 failed
4. **Verify:** UI shows partial status
5. **Admin action:** Fix invalid oikos signature
6. **User action:** Dwell again (or manual retry)
7. **Verify:** Failed oikos now installs

---

*Drafted 2026-01-28*
*Updated 2026-01-28: Added K0, K4.5, K9, error handling, edge cases, expanded tests*
