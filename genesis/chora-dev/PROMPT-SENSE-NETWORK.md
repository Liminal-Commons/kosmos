# PROMPT-SENSE-NETWORK — Sense actuality of network modes

*Sense prompt for Claude Code. This is an αἴσθησις instrument — it observes actuality and reports whether it conforms to existence (the prescriptive target in actualization-pattern.md).*

*Do NOT implement anything. Only sense and report.*

---

## Modes Under Observation

| Mode | Provider | Target Stage | Source |
|------|----------|-------------|--------|
| `mode/dns-cloudflare` | cloudflare | 6 (React) | `genesis/dynamis/modes/dynamis.yaml` |
| `mode/webrtc-livekit` | livekit | 6 (React) | `genesis/aither/modes/webrtc.yaml` |

---

## Stage Criteria — What to Check

### Stage 1: Prescribe
- [ ] Mode entities exist with operations defined
- **Check:** Read `genesis/dynamis/modes/dynamis.yaml` (DNS section) and `genesis/aither/modes/webrtc.yaml`. Confirm stoicheion names: `cf-create-record`/`cf-get-record`/`cf-delete-record` for DNS; `lk-join-room`/`lk-sense-connection`/`lk-leave-room` for WebRTC.

### Stage 2: Dispatch
- [ ] `build.rs` generates dispatch entries for both modes
- [ ] `stoicheion_for_mode("dns", "cloudflare", op)` and `stoicheion_for_mode("webrtc", "livekit", op)` return correct names
- **Check:** Read `crates/kosmos/src/mode_dispatch.rs`. Search for `dns`/`cloudflare` and `webrtc`/`livekit` entries.

### Stage 3: Implement
- [ ] `dns.rs` has real Cloudflare API calls (create, get, delete DNS records)
- [ ] `livekit.rs` has real LiveKit API calls (token generation, room management)
- [ ] Match arms route to real implementations (not stubs)
- [ ] Operations return `_entity_update` for state reconciliation
- **Check:** Read `crates/kosmos/src/dns.rs` — does it make real HTTP requests to Cloudflare API? Read `crates/kosmos/src/livekit.rs` — does it generate real JWT tokens and call LiveKit API? Check whether these route through stoicheion dispatch or bypass via legacy eidos-specific handlers.

### Stage 4: Compose
- [ ] DNS record entities can be composed with `mode: dns, provider: cloudflare`
- [ ] WebRTC connection entities can be composed with `mode: webrtc, provider: livekit`
- **Check:** Search genesis for typos or praxeis producing dns-record or connection entities.

### Stage 5: Sense
- [ ] `cf-get-record` queries Cloudflare API for actual DNS state
- [ ] `lk-sense-connection` queries LiveKit for actual connection state
- [ ] Sense returns `_entity_update` with sensed state
- **Check:** Read the sense implementations. Do they make real API calls or return cached/entity data?

### Stage 6: React
- [ ] Reflexes fire on DNS/WebRTC entity intent changes
- [ ] Reconciler drives corrections (e.g., DNS record deleted externally → recreate)
- [ ] Daemon periodically senses for drift
- **Check:** Search genesis for reflex and reconciler entities covering DNS and WebRTC eide.

---

## Known Context

The PROMPT-PROCESS-COMPLETION.md previously assessed:
- `mode/dns-cloudflare`: stage 2 (dispatched stub; real code in `dns.rs` via legacy eidos-specific path)
- `mode/webrtc-livekit`: stage 6 (stoicheion-dispatched, reconciler + reflexes + daemon)

DNS has a known architectural gap: `dns.rs` has working Cloudflare API code, but it's wired through a legacy eidos-specific handler (matching on `dns-record` eidos), not through generic stoicheion dispatch. The code exists but the wiring bypasses the standard path.

---

## Files to Read

| File | What to Check |
|------|---------------|
| `genesis/dynamis/modes/dynamis.yaml` | DNS mode definition |
| `genesis/aither/modes/webrtc.yaml` | WebRTC mode definition |
| `crates/kosmos/src/mode_dispatch.rs` | Dispatch entries for both modes |
| `crates/kosmos/src/dns.rs` | Cloudflare API implementation — real HTTP calls? Legacy wiring? |
| `crates/kosmos/src/livekit.rs` | LiveKit implementation — token gen? API calls? `_entity_update`? |
| `crates/kosmos/src/host.rs` | Routing — stoicheion dispatch or eidos-specific handler? |
| `genesis/dynamis/reconcilers/dynamis.yaml` | Reconciler coverage |
| `crates/kosmos/tests/` | Network lifecycle tests |

---

## Report Format

For each mode, report:

```
mode/dns-cloudflare:
  Actual stage: N
  Evidence: {what was found at each stage}
  Gap from target: {6 - N} stages
  Blocking issue: {what prevents advancement to next stage}
  Legacy path: {describe any eidos-specific bypass of generic dispatch}
```

Then update the Target Completion Matrix in `docs/reference/reactivity/actualization-pattern.md` Section 7.

---

*Traces to: actualization-pattern.md Section 2 (The Actualization Cycle — Sense moment), PROMPT-DNS-LIFECYCLE.md, PROMPT-SUBSTRATE-WEBRTC.md*
