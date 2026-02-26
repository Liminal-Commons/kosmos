# Manifest Validation Reference

*Prescriptive specification — describes the desired end state.*

A topos manifest is a contract: "I provide these capabilities, I require these dependencies, I need these substrate powers." Manifest validation enforces this contract at bootstrap time, before any praxis executes.

---

## When Validation Runs

Manifest validation runs **after all topos content is loaded** but **before bootstrap completes**. This timing is critical:

1. All manifests are parsed and `topos-manifest` entities created
2. All content (eide, desmoi, praxeis) is loaded from content paths
3. **Manifest validation runs** (three phases)
4. Bootstrap returns result (with errors/warnings)

Validation sees the fully-loaded graph, so it can verify that declared entities actually exist.

---

## The Three Phases

### Phase 1: Dependency Resolution

Validates that every topos dependency is satisfied.

**For each loaded topos manifest:**
- Every entry in `depends_on` must reference a loaded topos (present in `result.manifests_loaded`)
- Circular dependencies are detected and reported

**Error classification:**
- Missing dependency: **Error** (prevents bootstrap in strict mode)
- Circular dependency: **Warning** (logged, bootstrap continues)

**Error messages:**

```
{topos_id}: depends_on '{dependency}' but topos '{dependency}' is not loaded
{topos_id}: circular dependency detected: {cycle_path}
```

### Phase 2: Provides Verification

Validates that every declared entity in `provides` actually exists in the graph.

**For each loaded topos manifest:**
- Every entry in `provides.eide` must exist as `eidos/{name}` in the graph
- Every entry in `provides.desmoi` must exist as `desmos/{name}` in the graph
- Every entry in `provides.praxeis` must exist as `praxis/{id}` in the graph (praxis IDs are fully qualified, e.g. `manteia/governed-inference` → `praxis/manteia/governed-inference`)
- Every entry in `provides.attainments` must exist as `attainment/{name}` in the graph

**Error classification:**
- Declared-but-missing entity: **Warning** (contract violation, logged)

**Error messages:**

```
{topos_id}: provides eidos '{name}' but entity 'eidos/{name}' not found
{topos_id}: provides desmos '{name}' but entity 'desmos/{name}' not found
{topos_id}: provides praxis '{id}' but entity 'praxis/{id}' not found
{topos_id}: provides attainment '{name}' but entity 'attainment/{name}' not found
```

### Phase 3: Requirements Check

Validates that required capabilities and surfaces are available.

**For each loaded topos manifest:**
- Every entry in `requires_dynamis` must be in the known dynamis registry (`KNOWN_DYNAMIS`)
- Every entry in `surfaces_consumed` should have at least one topos that provides that surface via `surfaces_provided`
- Every entry in `requires_attainments` should have at least one topos that declares that attainment in `provides.attainments`

**Error classification:**
- Unknown dynamis: **Error** (prevents bootstrap in strict mode)
- Unresolvable surface consumption: **Warning** (surface provider may be loaded later)
- Missing attainment provider: **Warning** (providing topos may not be loaded yet)

**Error messages:**

```
{topos_id}: requires_dynamis '{name}' not in known dynamis registry
{topos_id}: consumes surface '{name}' but no loaded topos provides it
{topos_id}: requires attainment '{name}' but no loaded topos provides it
```

---

## Known Dynamis Registry

The static registry of substrate capabilities that the interpreter provides:

```
db.arise, db.find, db.bind, db.update, db.delete,
db.gather, db.trace, db.loose, db.surface, db.index,
intelligence.infer,
webrtc.manifest, webrtc.sense, webrtc.unmanifest,
fs.read, fs.write, fs.stat, fs.delete,
process.spawn, process.check, process.kill,
dns.create, dns.get, dns.delete,
r2.put, r2.head, r2.delete,
s3.put, s3.head, s3.delete
```

Future: This registry should become homoiconic — dynamis entities in the graph. For now, a static list catches the common case.

---

## Validation Output

Validation results are collected in `BootstrapResult.manifest_warnings`. In strict mode, errors cause `bootstrap_from_spora_with_options` to return `Err`. In permissive mode, all issues (errors and warnings) are appended to `manifest_warnings`.

Example warning messages:

```
ergon: provides praxis 'ergon/missing-praxis' but entity 'praxis/ergon/missing-praxis' not found
dynamis: requires_dynamis 'gpu.compute' not in known dynamis registry
oikos: consumes surface 'understanding' but no loaded topos provides it
alpha: depends_on 'nonexistent' but topos 'nonexistent' is not loaded
```

---

## Strict vs Permissive Mode

Controlled by `ManifestLoadOptions.strict`:

| Condition | Strict Mode | Permissive Mode |
|-----------|-------------|-----------------|
| Missing dependency | Error (fail bootstrap) | Warning |
| Unknown dynamis | Error (fail bootstrap) | Warning |
| Provides violation | Warning | Warning |
| Missing surface provider | Warning | Warning |
| Circular dependency | Warning | Warning |

Default mode is **permissive** (strict = false). Strict mode is used for CI/production validation.

---

## Manifest Fields Used

| Field | Type | Validated In |
|-------|------|-------------|
| `depends_on` | `Vec<String>` | Phase 1 |
| `provides.eide` | `Vec<String>` | Phase 2 |
| `provides.desmoi` | `Vec<String>` | Phase 2 |
| `provides.praxeis` | `Vec<String>` | Phase 2 |
| `provides.attainments` | `Vec<String>` | Phase 2 |
| `requires_dynamis` | `Vec<String>` | Phase 3 |
| `surfaces_consumed` | `Vec<String>` | Phase 3 |
| `requires_attainments` | `Vec<String>` | Phase 3 |
| `surfaces_provided` | `Vec<String>` | Phase 3 (as provider data) |

---

## Activation

Validation runs when `ManifestLoadOptions.validate_dynamis == true`. This gate controls all three phases (not just dynamis checking). Default is `false` for backward compatibility; set to `true` for CI or production validation.

```rust
let options = ManifestLoadOptions {
    validate_dynamis: true,
    strict: true,         // errors fail bootstrap
    ..Default::default()
};
let result = bootstrap_from_spora_with_options(&ctx, &spora_path, &options)?;
```

All errors and warnings are collected in `BootstrapResult.manifest_warnings`.
