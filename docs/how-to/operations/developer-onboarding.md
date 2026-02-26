# Federating a Developer: Implementation Guide

*How to bring a contributor into the kosmos*

---

## The Use Case

Victor wants to invite Alex, a developer, to collaborate on the chora codebase. Alex should be able to:
1. Access Victor's kosmos (see entities, theoria, patterns)
2. Create their own contributions (crystallize theoria, compose artifacts)
3. Work offline when needed (optional, Phase 2)
4. Sync changes between devices (optional, Phase 3)

---

## Current Infrastructure State

| Layer | Component | Status | What It Provides |
|-------|-----------|--------|------------------|
| **Entry** | Propylon praxeis | ✅ Complete | Invitation links, challenge-response |
| **Entry** | Propylon relay | ✅ Deployed | WebRTC signaling at propylon.liminalcommons.com |
| **Transport** | Aither praxeis | ✅ Complete | WebRTC data channels |
| **Sync** | Syndesmos praxeis | ✅ Complete | Oikos-to-oikos federation |
| **State** | Hypostasis praxeis | ✅ Complete | Phoreta export/import |
| **Identity** | Key derivation | ✅ Complete | BIP-39 mnemonic, Ed25519 |

**Gap identified:** `propylon/verify-entry` creates a parousia and member-of bond but does NOT automatically create a `syndesmos-link` for ongoing state sync.

---

## Two Federation Models

### Model A: Shared Kosmos (Thin Client)

```
Victor's Machine                    Alex's Machine
┌─────────────────┐                ┌─────────────────┐
│  kosmos.db   │◀──────────────▶│   Thyra Client  │
│  (all state)    │    WebRTC      │   (thin)        │
└─────────────────┘                └─────────────────┘

Alex's parousia dwells in Victor's kosmos.
```

**How it works:**
1. Victor runs `kosmos-mcp` server
2. Victor creates invitation: `propylon/create-link`
3. Alex clicks link, authenticates via propylon
4. Alex's Thyra connects to Victor's MCP server
5. All operations go through Victor's kosmos

**Pros:** Simple. Works with current infrastructure. No sync complexity.

**Cons:** Requires Victor online. Single point of failure. No offline work.

### Model B: Federated Kosmoi (Sovereign)

```
Victor's Machine                    Alex's Machine
┌─────────────────┐                ┌─────────────────┐
│  kosmos.db   │◀──────────────▶│  kosmos.db   │
│  Victor's state │   syndesmos    │  Alex's state   │
└─────────────────┘                └─────────────────┘

Each has sovereign kosmos. Syndesmos keeps them in sync.
```

**How it works:**
1. Victor and Alex each run their own kosmos-mcp
2. Victor creates invitation, Alex authenticates
3. A `syndesmos-link` is created between their oikoi
4. `sync-policy` determines what flows (theoria, patterns, etc.)
5. Changes propagate via phoreta bundles

**Pros:** Offline-capable. True sovereignty. Resilient.

**Cons:** Requires sync logic. Potential conflicts. More complex.

---

## Implementation Path

### Phase 1: Model A (Immediate)

**What exists:** Everything needed for Model A works today.

**Steps to onboard Alex:**

1. **Victor creates invitation:**
   ```
   propylon/create-link
   - oikos_id: "oikos/liminal-commons"
   - message: "Welcome to the codebase, Alex!"
   - expires_in_days: 7
   ```

2. **Victor shares link** (via Signal, email, QR code, etc.)

3. **Alex clicks link:**
   - Landing page at chora.link/p/{encoded}
   - Alex generates keypair (or enters mnemonic for existing identity)
   - Challenge-response authentication

4. **Alex connects:**
   - WebRTC connection established via propylon relay
   - Alex's Thyra talks to Victor's MCP server
   - Alex can read/write in Victor's kosmos

**Requirements:**
- Victor's MCP server must be accessible (locally or tunneled)
- Both must be online simultaneously

### Phase 2: Self-Federation Testing (Next)

Before enabling peer federation, validate the sync infrastructure with self-federation (same prosopon across devices).

**What to test:**
1. Create self-link: `propylon/create-self-link`
2. On Device B: Enter mnemonic + self-link
3. Pubkey verification (same mnemonic = same keys)
4. Phoreta export from Device A
5. Phoreta import on Device B
6. Verify entity integrity (composition chains)

**Roadmap reference:** Phase 23.6 (end-to-end testing), Phase 23.7 (self-federation)

### Phase 3: Peer Federation (Future)

Extend the entry flow to create syndesmos links.

**Required changes:**

1. **Modify verify-entry to optionally create syndesmos-link:**
   ```yaml
   # After creating parousia and member-of bond:
   - step: switch
     on: "$create_federation_link"
     cases:
       true:
         - step: call
           praxis: syndesmos/create-link
           params:
             name: "federation-$prosopon.data.name"
             local_oikos_id: "$session.data.oikos_id"
             local_pubkey: "$inviter_keypair.public_key"
             remote_oikos_id: "$entrant_oikos_id"
             remote_pubkey: "$entrant_pubkey"
           bind_to: fed_link

         - step: call
           praxis: syndesmos/activate-link
           params:
             link_id: "$fed_link.link_id"
   ```

2. **Create default sync-policy for developers:**
   ```yaml
   sync-policy/developer-collab:
     direction: bidirectional
     eidos_filter:
       - theoria
       - principle
       - pattern
       - artifact
     conflict_resolution: newer_wins
   ```

3. **Landing page modification:**
   - Option to "create local kosmos" vs "connect to existing"
   - If local: Alex runs their own MCP server
   - If connect: Model A thin client

---

## The Handoff Gap (Technical Detail)

Currently, `propylon/verify-entry` does:

```yaml
# Creates prosopon
- step: arise
  eidos: prosopon
  id: "$prosopon_id"
  data:
    name: "$persona_name"
    pubkey: "$entrant_pubkey"

# Creates parousia
- step: call
  praxis: soma/arise-parousia
  params:
    prosopon_id: "$prosopon_id"
    parousia_id: "$parousia_id"

# Creates membership bond
- step: bond
  desmos: member-of
  from: "$parousia_id"
  to: "$session.data.oikos_id"

# Returns connection info
- step: return
  value:
    connection_info:
      webrtc: { ... }
      relay: { url: "wss://propylon.liminalcommons.com" }
```

**What's missing for Model B:**

```yaml
# Should also create syndesmos link if federated
- step: call
  praxis: syndesmos/create-link
  params:
    local_oikos_id: "$session.data.oikos_id"
    remote_oikos_id: "$entrant_oikos_id"  # ← Entrant must provide their oikos
    ...

# And activate it
- step: call
  praxis: syndesmos/activate-link
  params:
    link_id: "$link.link_id"
```

The gap: **Entrant doesn't have an oikos yet in Model B.** They need to:
1. Create their own kosmos (local database)
2. Create their self-oikos
3. Provide that oikos_id during entry

This is why self-federation (Phase 23.7) should come first — it validates the sync without the chicken-and-egg of needing an oikos before having identity.

---

## Practical Steps for Today

### For Victor (inviter):

1. Ensure kosmos-mcp is running:
   ```bash
   just mcp
   ```

2. Create invitation via Claude Code:
   ```
   "Create an invitation link for a developer to join the liminal-commons oikos"
   ```

3. Share the encoded link with Alex

### For Alex (entrant):

1. Clone the repo:
   ```bash
   git clone https://github.com/liminalcommons/chora.git
   cd chora
   ```

2. Click the invitation link (or visit chora.link/p/{encoded})

3. Complete authentication (video call with Victor for verification)

4. Configure Claude Code to use Victor's MCP endpoint

---

## Security Considerations

| Concern | Mitigation |
|---------|------------|
| Link interception | Single-use links, expiry, passphrase option |
| Impersonation | Human verification ("the call IS the verification") |
| State tampering | Content-addressed entities, composition chains |
| Offline attacks | Phoreta signatures, provenance verification |

---

## Related Documents

- [propylon/DESIGN.md](../../../genesis/propylon/DESIGN.md) — Entry philosophy
- [aither/DESIGN.md](../../../genesis/aither/DESIGN.md) — Transport and federation design
- [hypostasis/DESIGN.md](../../../genesis/hypostasis/DESIGN.md) — State replication
- [ROADMAP.md](../../../ROADMAP.md) — Implementation timeline

---

*Grounding design in use case: developer onboarding reveals the propylon → syndesmos handoff.*
*Traces to: phasis/genesis-root*
