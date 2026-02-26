# Attainment Authorization

Graph-based access control for praxis invocation. Attainments are capability markers; bonds are grants; the graph is the policy.

**This document is prescriptive.** It describes the target state. Where implementation diverges, the code has a gap.

---

## Bond Topology

Authorization flows through four bond types:

```
oikos --[grants-attainment]--> attainment       (what an oikos grants)
parousia --[has-attainment]--> attainment        (what a dwelling possesses)
attainment --[grants-praxis]--> praxis           (what an attainment permits)
praxis --[requires-attainment]--> attainment     (what a praxis requires)
```

### Desmoi

| Desmos | From | To | Defined In | Purpose |
|--------|------|----|------------|---------|
| `grants-attainment` | oikos | attainment | politeia/desmoi | Oikos grants attainment to members |
| `has-attainment` | parousia | attainment | politeia/desmoi | Parousia holds attainment (derived from membership) |
| `grants-praxis` | attainment | praxis | arche/desmos.yaml | Attainment permits praxis invocation |
| `requires-attainment` | praxis | attainment | arche/desmos.yaml | Praxis declares required attainment |

`grants-praxis` and `requires-attainment` are complementary views of the same relationship. Both exist because each enables a different traversal direction:
- "What can this attainment do?" → traverse `grants-praxis` from attainment
- "What does this praxis need?" → traverse `requires-attainment` from praxis

---

## Authorization Algorithm

Before invoking any praxis, the system checks:

```
1. trace_bonds(from: praxis_id, desmos: "requires-attainment")
   → required_attainments (set of attainment IDs)

2. If required_attainments is empty:
   → Praxis is public. Allow.

3. Extract context: prosopon, oikos, session, parousia
   → Context is always present. No bypass.

4. trace_bonds(from: parousia_id, desmos: "has-attainment")
   → held_attainments (set of attainment IDs)

5. If required_attainments ⊆ held_attainments:
   → Allow.

6. Otherwise:
   → Reject with: "Missing attainment '{name}' required by {praxis_id}"
```

### Implementation

The authorization gate lives in `execute_praxis()` (`crates/kosmos/src/interpreter/mod.rs`). It runs before any steps execute — a praxis either passes authorization entirely or doesn't execute at all.

This replaces:
- MCP projection reading `grants` field for tool visibility
- Ad-hoc trace/filter/assert authorization in praxis YAML steps
- Affordance `required_attainments` field checks

### Public Praxeis

A praxis with no `requires-attainment` bond is public — any parousia can invoke it. This is the default. To gate a praxis, add a `requires-attainment` bond.

### Bootstrap Mode

During bootstrap, authorization operates under the **germination context** — the spora's Ed25519 signature provides primordial authorization. A germination session is created at bootstrap start, and the spora's `expressed_by` prosopon provides identity. Bootstrap does not bypass authorization; it operates under spora authority.

For CLI and tests, a context must always be provided. Test helpers provide a default context with default attainments.

---

## Graph Queries

### "What can prosopon X do?"

Traverse: `parousia → has-attainment → attainment → grants-praxis → praxis`

```
parousia/victor --[has-attainment]--> attainment/govern
attainment/govern --[grants-praxis]--> praxis/politeia/create-oikos
attainment/govern --[grants-praxis]--> praxis/politeia/grant-attainment
```

Result: all praxeis this prosopon can invoke. Pure graph traversal.

### "What does praxis Y require?"

Single hop: `praxis → requires-attainment → attainment`

```
praxis/politeia/create-oikos --[requires-attainment]--> attainment/govern
```

### "What attainments does oikos Z grant?"

Traverse: `oikos → grants-attainment → attainment`

### "What praxeis does attainment A enable?"

Traverse: `attainment → grants-praxis → praxis`

---

## Attainment Derivation

Attainments flow from oikos membership to parousia via the `derive-attainments` praxis:

```
parousia → member-of → oikos → grants-attainment → attainment
```

The `derive-attainments` praxis creates `has-attainment` bonds on the parousia for each attainment the oikos grants. This runs automatically via `reflex/politeia/derive-attainments-on-join` when a prosopon joins an oikos.

When a prosopon leaves an oikos, `leave-oikos` removes the corresponding `has-attainment` bonds.

---

## MCP Tool Visibility

The MCP bridge exposes praxeis as tools based on the `attainment/mcp-essential` attainment:

```
1. Session token must include "attainment/mcp-essential"
2. get_attainment_grants("attainment/mcp-essential")
   → traverses grants-praxis bonds from attainment/mcp-essential
   → returns set of praxis IDs
3. Only praxeis in this set AND with visible: true are exposed as MCP tools
```

`get_attainment_grants()` uses bond traversal (`trace_bonds` with desmos `grants-praxis`), not field reading.

---

## Attainment Entity Structure

```yaml
- eidos: attainment
  id: attainment/govern
  data:
    name: govern
    description: "Capability to create oikoi and manage attainments."
    topos: politeia
    scope: oikos
  bonds:
    - { desmos: grants-praxis, to: praxis/politeia/create-oikos }
    - { desmos: grants-praxis, to: praxis/politeia/create-attainment }
    - { desmos: grants-praxis, to: praxis/politeia/grant-attainment }
    - { desmos: grants-praxis, to: praxis/politeia/revoke-attainment }
```

The `grants` field does not exist. All attainment-to-praxis relationships are `grants-praxis` bonds.

### Eidos Schema

```yaml
- eidos: eidos
  id: eidos/attainment
  data:
    name: attainment
    description: "Capability marker — what a parousia can do."
    fields:
      name: { type: string, required: true }
      description: { type: string, required: false }
      scope: { type: enum, values: [oikos, topos, global], required: true, default: oikos }
      constraints: { type: object, required: false }
      created_at: { type: timestamp, required: true }
```

No `grants` field. Authorization relationships are bonds, not embedded arrays.

---

## Affordance Authorization

Affordances use `enabled-by` bonds (not `required_attainments` field) to declare which attainment gates visibility:

```yaml
- eidos: affordance
  id: affordance/compose
  data:
    name: Compose
    praxis_id: praxis/demiurge/compose
  bonds:
    - { desmos: enabled-by, to: attainment/compose }
```

The `invoke-affordance` praxis verifies this via bond traversal: `affordance → enabled-by → attainment`, then checks if the caller's parousia `has-attainment` for the required attainment.

---

## Tier 3 Stoicheion Gating

Tier 3 operations (embed, emit, infer, manifest, signal, invoke) have a separate authorization mechanism: `eidos/stoicheion/{op} → requires-attainment → attainment`. This gates individual step execution within praxeis.

Both praxis-level and stoicheion-level authorization coexist:
- **Praxis-level**: "Can this parousia invoke this praxis at all?"
- **Stoicheion-level**: "Does the session have the API credentials for this external operation?"

They check different things: praxis-level checks `has-attainment` bonds on the parousia, stoicheion-level checks attainments on the session bridge (derived from stored credentials).

---

## Gating a New Praxis

To require an attainment for a praxis:

1. Add a `requires-attainment` bond on the praxis entity:
   ```yaml
   bonds:
     - { desmos: requires-attainment, to: attainment/my-attainment }
   ```

2. Add the corresponding `grants-praxis` bond on the attainment entity:
   ```yaml
   bonds:
     - { desmos: grants-praxis, to: praxis/my-topos/my-praxis }
   ```

3. Ensure the attainment is granted by relevant oikoi via `grants-attainment` bonds.

No code changes required. The authorization gate in `execute_praxis()` discovers requirements via graph traversal.

---

## Session Boundary

The session token is the interface between infrastructure (chora) and identity (kosmos). Infrastructure mints, validates, and extracts tokens using standard HTTP middleware patterns. Kosmos reads tokens to construct DwellingContext — the identity envelope that populates `$_prosopon`, `$_oikos`, `$_parousia`, and `$_locale` for praxis execution.

### Token Payload

```json
{
  "prosopon_id": "prosopon/victor",
  "parousia_id": "parousia/abc-123",
  "oikoi": ["oikos/victors-oikos"],
  "attainments": ["attainment/mcp-essential", "attainment/govern"],
  "issued_at": "2026-02-10T10:00:00Z",
  "expires_at": "2026-02-11T10:00:00Z",
  "master_seed_b64": "..."
}
```

`parousia_id` is required for dwelling context. Without it, `$_parousia` cannot be set, and attainment checks that traverse `has-attainment` from the parousia will fail.

### Token Minting

Three paths mint tokens, all must include `parousia_id`:

| Path | Location | When |
|------|----------|------|
| `session_arise` | `crates/kosmos-mcp/src/rest.rs` | REST session creation |
| `verify_entry` | `crates/kosmos-mcp/src/rest.rs` | Cryptographic entry verification |
| `write_session_token` | `app/src-tauri/src/main.rs` | Tauri keyring unlock |

`session_switch_oikos` also re-mints tokens when switching dwelling oikos and must include `parousia_id`.

### DwellingContext Construction

When a session is present, DwellingContext is constructed from the token:

```rust
let dwelling = session.map(|s| DwellingContext {
    prosopon_id: s.prosopon_id,
    oikos_id: s.oikoi.first().cloned().unwrap_or_default(),
    parousia_id: s.parousia_id,  // from token
    locale: None,
});
```

When no session is present, dwelling is `None` — not an empty-string DwellingContext. `invoke_praxis_dwelling` accepts `Option<DwellingContext>` and passes it through to `execute_praxis`. An absent dwelling triggers bootstrap mode (authorization bypassed).

### Backward Compatibility

`parousia_id` is `Option<String>` with `#[serde(default)]`. Old tokens without the field parse with `parousia_id: None`. This degrades gracefully — `$_parousia` will be unset, but `$_prosopon` and `$_oikos` still work.

---

## Sovereignty Attainment

Sovereignty over an oikos is an attainment, checked by the same authorization gate as all other permissions.

### Entity

```yaml
- eidos: attainment
  id: attainment/sovereign
  data:
    name: sovereign
    description: "Sovereign authority over an oikos."
    topos: politeia
    scope: oikos
  bonds:
    - { desmos: grants-praxis, to: praxis/politeia/invite-to-oikos }
    - { desmos: grants-praxis, to: praxis/politeia/grant-attainment }
    - { desmos: grants-praxis, to: praxis/politeia/revoke-attainment }
    - { desmos: grants-praxis, to: praxis/politeia/federate-oikoi }
```

### How Sovereignty Flows

When an oikos is created, the `create-oikos` praxis creates a `sovereign-to` bond from the oikos to the creator's parousia. At session arise time, the sovereignty is derived as an attainment:

```
oikos --[sovereign-to]--> parousia
oikos --[grants-attainment]--> attainment/sovereign
parousia --[has-attainment]--> attainment/sovereign  (derived)
```

The authorization gate checks `requires-attainment → attainment/sovereign` before executing sovereignty-gated praxeis. No ad-hoc trace/filter/assert patterns in YAML steps.

### Replacing Ad-Hoc Checks

The following praxeis previously used inline `trace → filter → assert` sovereignty checks and now use `requires-attainment → attainment/sovereign` bonds instead:

- `praxis/politeia/invite-to-oikos`
- `praxis/politeia/grant-attainment`
- `praxis/politeia/revoke-attainment`
- `praxis/politeia/federate-oikoi`
