# Authority Mechanism

How Axiom II (Authority) is realized: the kosmos acts only as authorized by those who dwell in it.

**This document is prescriptive.** It describes the target state. Where implementation diverges, the code has a gap.

---

## The Authorization Chain

Authority flows from prosopa through governance to action:

```
prosopon (sovereign identity)
    │
    ├── emerges-from ← parousia (embodied presence)
    │                      │
    │                      └── dwells-in → oikos (governance context)
    │                                        │
    │                                        ├── grants-attainment → attainment (capability marker)
    │                                        │                          │
    │                                        │                          └── grants-praxis → praxis (permitted action)
    │                                        │
    │                                        └── governance configuration → ambient infrastructure
    │
    └── session (authenticated dwelling)
            │
            └── authorized-by ← entity (provenance bond)
```

Note: `dwells-in` is exclusively for parousia → oikos. A prosopon dwells *through* a parousia — the parousia is the embodied presence that actually holds the dwelling bond.

Every action traces back to a prosopon's dwelling. The mechanism varies; the axiom does not.

### Dual Governance Through Oikos

An oikos governs two complementary dimensions through the same membership bonds:

**Visibility** (what you can see):
- `member-of` (prosopon → oikos) + `exists-in` (entity → oikos)
- Members see entities that exist-in the oikos
- Result: Visibility scope = oikos membership

**Authority** (what you can do):
- `stewards` (prosopon → oikos) + `grants-attainment` (oikos → attainment)
- Stewards receive all attainments the oikos grants — full authorization
- Non-steward members have visibility only — no mutation capability

Both dimensions are rooted in oikos membership. Visibility determines WHAT you see. Stewardship determines what you can DO. See [visibility-semantics.md](../dwelling/visibility-semantics.md) for the visibility model.

---

## Three Authority Patterns

### 1. Direct: Prosopon Acts

The simplest case. A prosopon composes a phasis, crystallizes a theoria, or invokes a praxis.

```
prosopon → unlock_keyring → session
session → dwelling_context (prosopon_id, oikos_id, parousia_id)
dwelling_context → praxis invocation
praxis → compose_entity → authorized-by bond → session
```

**Authorization path**: Session proves identity. Dwelling context proves position. Attainment authorization checks capability. The composed entity records the session as its authority via `authorized-by` bond.

**Implementation status**: Complete. Session-based authorization with `authorized-by` bonds is implemented in `compose_entity()`. Attainment checking is implemented in `host.rs`.

### 2. Delegated: Agent Acts on Behalf

An agent (daemon, bot, automated process) acts with authority delegated by a prosopon or oikos governance.

```
prosopon → governance decision → daemon configuration
daemon → derives session from oikos governance
daemon action → traces to governance that established it
```

**Authorization path**: The daemon's authority derives from the oikos governance that configured it, not from a prosopon's direct session. The governance decision IS the authorization. The daemon acts as authorized infrastructure, not as a sovereign entity.

**Implementation status**: Prescribed. Daemon authority model is defined in KOSMOGONIA but the delegation chain (governance → daemon session → authorized-by) is not yet implemented. Current daemons (reconcilers, reflexes) operate within bootstrap scope or host-level operations.

### 3. Ambient: Kosmos Infrastructure Acts

The kosmos itself performs operations — reflexes firing, reconcilers sensing, substrate signals propagating. These are not initiated by any prosopon but serve the dwelling of all prosopa.

```
governance configuration → reflex/reconciler definition
reflex/reconciler → operates on entities within scope
operations → trace to governance that established the infrastructure
```

**Authorization path**: Ambient operations derive authority from the governance decisions that configured them. A reflex fires because governance established it. A reconciler senses because governance declared what should be sensed.

**Implementation status**: Partial. Reflexes and reconcilers operate after bootstrap. Their entity definitions trace to genesis (via `composed-from`). The explicit governance → reflex authorization chain is prescribed but the `authorized-by` bond for reflex-triggered entity mutations is not yet threaded through.

---

## Session as Authorization Context

The session entity bridges identity to authorization:

```
session entity
    ├── prosopon_id    — WHO is acting
    ├── oikos_id       — WHERE they're dwelling
    ├── parousia_id    — WHICH presence
    └── created via unlock_keyring (password → mnemonic → keys)
```

### Session lifecycle

1. **Launch**: Thyra starts. No session. No kosmos interaction possible.
2. **Unlock**: Prosopon enters password. `unlock_keyring()` decrypts master seed. Session entity arises.
3. **Dwelling**: Session carries `DwellingContext`. All praxis invocations receive this context.
4. **Composition**: Every `compose_entity()` call records `authorized-by → session_id`.
5. **Departure**: Session ends. No further authorization possible.

### MCP bridge

The MCP transport layer (kosmos-mcp) bridges external callers to session context:

- MCP reads session token but cannot create sessions
- Praxis invocation through MCP carries session context
- Attainment bonds determine which MCP-projected tools are available

---

## Attainment Authorization

Attainments are capability markers in the bond graph. Authorization is graph traversal, not policy evaluation.

### The check

Before invoking any praxis:

```
1. What does this praxis require?
   → trace_bonds(praxis, "requires-attainment") → required_attainments

2. If no requirements → public praxis, allow

3. What does this parousia hold?
   → trace_bonds(parousia, "has-attainment") → held_attainments

4. Does held ⊇ required?
   → Yes: allow
   → No: deny with specific missing attainment
```

### Bond topology

```
oikos --[grants-attainment]--> attainment
parousia --[has-attainment]--> attainment
attainment --[grants-praxis]--> praxis
praxis --[requires-attainment]--> attainment
```

The graph IS the policy. No permission tables, no role hierarchies, no ACLs. Add a bond to grant capability. Remove a bond to revoke it.

**Implementation status**: Complete. Attainment checking is implemented in `host.rs`. Bond topology is defined in `arche/desmos.yaml` and `politeia/desmoi`.

---

## The Bootstrap Exception

During genesis, no prosopon exists. No session exists. No governance exists. Yet entities must arise.

Axiom IV (Self-Grounding) explains why: the infrastructure of authorization cannot be authorized by infrastructure that doesn't exist yet. Axiom V (Adequacy) explains what to do: record whatever provenance is available.

During bootstrap:
- **No `authorized-by` bonds** — no session entity exists
- **Genesis root signature** — the spora signature IS the authorization
- **Germination scope** — bootstrap operates in a special scope with no dwelling context
- **Reflexes dormant** — no governance triggers during bootstrap

After bootstrap completes and a prosopon unlocks:
- Session entity arises
- Dwelling context populates
- All subsequent compositions carry `authorized-by` bonds
- Reflexes activate

The transition from bootstrap to dwelling is the moment authorization becomes explicit.

---

## Axiom II Realization

| Dimension | Mechanism |
|-----------|-----------|
| **Who** | Prosopon identity via mnemonic-derived keys |
| **Where** | Oikos membership via `member-of` bonds |
| **When** | Session via `unlock_keyring` / departure |
| **By what right** | Attainment via `has-attainment` / `grants-praxis` bonds |
| **Recorded how** | `authorized-by` bond from entity to session |
| **Bootstrap** | Genesis root signature. Self-grounding axiom. |

The kosmos is intelligent but not sovereign. Prosopa are sovereign. The kosmos serves.

---

*Traces to: KOSMOGONIA Axiom II: Authority; T12 (one right way to arise); attainment-authorization.md; session-identity.md*
*Created: 2026-02-21*
