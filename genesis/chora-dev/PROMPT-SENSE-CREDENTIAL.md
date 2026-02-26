# PROMPT-SENSE-CREDENTIAL — Sense actuality of credential mode

*Sense prompt for Claude Code. This is an αἴσθησις instrument — it observes actuality and reports whether it conforms to existence (the prescriptive target in actualization-pattern.md).*

*Do NOT implement anything. Only sense and report.*

---

## Modes Under Observation

| Mode | Provider | Target Stage | Source |
|------|----------|-------------|--------|
| `mode/credential-keyring` | keyring | 6 (React) | `genesis/credentials/modes/credential-modes.yaml` |

---

## Stage Criteria — What to Check

### Stage 1: Prescribe
- [ ] Mode entity exists in `genesis/credentials/modes/credential-modes.yaml` with operations defined
- **Check:** Read the YAML. Confirm `manifest` (`keyring-store`), `sense` (`keyring-check`), `unmanifest` (`keyring-revoke`) are defined.

### Stage 2: Dispatch
- [ ] `build.rs` generates dispatch entries for credential mode
- [ ] `stoicheion_for_mode("credential", "keyring", op)` returns correct stoicheion names
- **Check:** Read `crates/kosmos/src/mode_dispatch.rs`. Search for `credential`/`keyring` entries.

### Stage 3: Implement
- [ ] `credential.rs` has real keyring operations (OS keychain API)
- [ ] `keyring-store` writes to actual OS keychain
- [ ] `keyring-check` reads from actual OS keychain (without leaking the secret)
- [ ] `keyring-revoke` deletes from actual OS keychain
- [ ] Operations return `_entity_update` for state reconciliation
- **Check:** Read `crates/kosmos/src/credential.rs`. Does `execute_operation()` use the `keyring` crate or equivalent to access macOS Keychain / Linux Secret Service? Check for `_entity_update` in return values.

### Stage 4: Compose
- [ ] Credential entities can be composed with `mode: credential, provider: keyring`
- [ ] The `resolve_credential()` function uses the standard mode path
- **Check:** Search genesis for typos or praxeis producing credential entities. Check if `resolve_credential()` in `credential.rs` is the standard way other substrate modules access credentials.

### Stage 5: Sense
- [ ] `keyring-check` queries actual OS keychain state (not just entity data)
- [ ] Returns `exists: boolean` and `actual_state` based on real keychain lookup
- [ ] Does NOT return the secret value — only existence/validity
- **Check:** Read the sense implementation. Does it call `keyring::Entry::get_password()` (or try/catch) to verify the credential exists in the OS keychain?

### Stage 6: React
- [ ] Reflexes fire when credential entity intent changes
- [ ] Reconciler drives corrections (e.g., credential rotated → re-store)
- [ ] Daemon periodically senses credential validity
- **Check:** Search genesis for reflex entities targeting credential eide. Check reconciler definitions. Check daemon loop for credential-aware sensing.

---

## Additional Concern: Cross-Substrate Dependency

Credentials are consumed by other substrates (R2 needs API keys, LiveKit needs API secret). Check:
- [ ] `resolve_credential()` is the standard interface other modules use
- [ ] Credential resolution traces through the mode path (not hardcoded env var reads)

This is not part of the stage assessment but reveals architectural health.

---

## Files to Read

| File | What to Check |
|------|---------------|
| `genesis/credentials/modes/credential-modes.yaml` | Mode entity definition |
| `crates/kosmos/src/mode_dispatch.rs` | Dispatch entries |
| `crates/kosmos/src/credential.rs` | Real keyring operations? `_entity_update`? `resolve_credential()`? |
| `crates/kosmos/src/host.rs` | Routing for credential stoicheia |
| `genesis/credentials/` | Reflex, reconciler, praxeis for credential entities |
| `genesis/dynamis/reconcilers/dynamis.yaml` | Credential reconciler definition |
| `crates/kosmos/src/daemon_loop.rs` | Daemon coverage for credentials |

---

## Report Format

```
mode/credential-keyring:
  Actual stage: N
  Evidence: {what was found at each stage}
  Gap from target: {6 - N} stages
  Blocking issue: {what prevents advancement to next stage}
  Cross-substrate health: {how other modules consume credentials}
```

Then update the Target Completion Matrix in `docs/reference/reactivity/actualization-pattern.md` Section 7.

---

*Traces to: actualization-pattern.md Section 2 (The Actualization Cycle — Sense moment), PROMPT-CREDENTIAL-LIFECYCLE.md*
