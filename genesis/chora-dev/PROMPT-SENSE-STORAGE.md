# PROMPT-SENSE-STORAGE — Sense actuality of storage modes

*Sense prompt for Claude Code. This is an αἴσθησις instrument — it observes actuality and reports whether it conforms to existence (the prescriptive target in actualization-pattern.md).*

*Do NOT implement anything. Only sense and report.*

---

## Modes Under Observation

| Mode | Provider | Target Stage | Source |
|------|----------|-------------|--------|
| `mode/object-storage-r2` | r2 | 6 (React) | `genesis/dynamis/modes/dynamis.yaml` |
| `mode/object-storage-s3` | s3 | 6 (React) | `genesis/dynamis/modes/dynamis.yaml` |
| `mode/object-storage-local` | local | 6 (React) | `genesis/dynamis/modes/dynamis.yaml` |

---

## Stage Criteria — What to Check

### Stage 1: Prescribe
- [ ] Mode entities exist in `genesis/dynamis/modes/dynamis.yaml` with operations defined
- **Check:** Read the YAML. Confirm all three modes have `manifest` (`r2-put-object`/`s3-put-object`/`fs-write-file`), `sense` (`r2-head-object`/`s3-head-object`/`fs-stat-file`), `unmanifest` (`r2-delete-object`/`s3-delete-object`/`fs-delete-file`).

### Stage 2: Dispatch
- [ ] `build.rs` generates dispatch entries for all three providers
- [ ] `stoicheion_for_mode("object-storage", "r2"|"s3"|"local", op)` returns correct stoicheion names
- **Check:** Read `crates/kosmos/src/mode_dispatch.rs`. Search for `object-storage` entries with each provider.

### Stage 3: Implement
- [ ] `r2.rs` has real R2 API calls (S3-compatible, AWS Signature V4)
- [ ] `storage.rs` has real filesystem operations with BLAKE3 hashing for local provider
- [ ] S3 provider has real AWS SDK calls (not stubs)
- [ ] All operations return `_entity_update` for state reconciliation
- **Check:** Read `crates/kosmos/src/r2.rs` — does `execute_operation()` or equivalent make real HTTP calls to R2? Read `crates/kosmos/src/storage.rs` — does local provider do real `std::fs` operations? For S3, check whether the implementation is parameterized R2 (via `ObjectStorageProvider`) or stub.

### Stage 4: Compose
- [ ] Typos exist that produce entities with `mode: object-storage` and appropriate provider
- [ ] Release-artifact or similar entities can be composed through standard path
- **Check:** Search genesis for typos producing storage entities. Check if `release-artifact` eidos entities carry mode/provider fields.

### Stage 5: Sense
- [ ] `r2-head-object` makes real HEAD request to R2 bucket
- [ ] `fs-stat-file` stats the actual file on disk (not just entity data)
- [ ] `s3-head-object` makes real HEAD request to S3
- [ ] Sense returns `_entity_update` with sensed existence/size/hash
- **Check:** Read the sense implementations. Does R2 sense make an HTTP HEAD? Does local sense call `std::fs::metadata()`? Does S3 sense make a real request or return stub data?

### Stage 6: React
- [ ] Reflexes fire when storage entity intent changes
- [ ] Reconciler drives corrections (e.g., file deleted externally → re-upload)
- [ ] Daemon periodically senses storage entities for drift
- **Check:** Search genesis for reflex entities targeting storage eide. Check reconciler definitions. Check daemon loop for storage-aware sensing.

---

## Known Context

The PROMPT-PROCESS-COMPLETION.md previously assessed:
- `mode/object-storage-r2`: stage 3 (real R2 calls via `execute_operation_with_session`)
- `mode/object-storage-s3`: stage 2 (dispatched, stubs)
- `mode/object-storage-local`: stage 3 (real `std::fs` + BLAKE3)

The legacy `release-artifact` handler in `r2.rs` bypasses generic dispatch — this may mean R2 is functional but not through the standard mode path.

---

## Files to Read

| File | What to Check |
|------|---------------|
| `genesis/dynamis/modes/dynamis.yaml` | Mode entity definitions (storage section) |
| `crates/kosmos/src/mode_dispatch.rs` | Generated dispatch entries |
| `crates/kosmos/src/r2.rs` | R2 implementation — real HTTP calls? `_entity_update`? |
| `crates/kosmos/src/storage.rs` | Local storage — real `std::fs`? BLAKE3? `_entity_update`? |
| `crates/kosmos/src/host.rs` | `manifest_by_stoicheion()` routing for storage stoicheia |
| `genesis/dynamis/reconcilers/dynamis.yaml` | Storage reconciler definitions |
| `crates/kosmos/tests/` | Any storage lifecycle tests |

---

## Report Format

For each mode, report:

```
mode/object-storage-r2:
  Actual stage: N
  Evidence: {what was found at each stage}
  Gap from target: {6 - N} stages
  Blocking issue: {what prevents advancement to next stage}
  Legacy path: {describe any eidos-specific bypass of generic dispatch}
```

Then update the Target Completion Matrix in `docs/reference/reactivity/actualization-pattern.md` Section 7.

---

*Traces to: actualization-pattern.md Section 2 (The Actualization Cycle — Sense moment), PROMPT-STORAGE-LIFECYCLE.md, PROMPT-SUBSTRATE-STORAGE.md*
