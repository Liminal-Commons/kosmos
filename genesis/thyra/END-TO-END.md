# End-to-End Design: The Invitation Flow

*From "I have an app" to "My friend is in my oikos"*

---

## Overview

The invitation flow is the complete path from a user installing Thyra to successfully inviting a friend into their oikos. This document captures the full architecture spanning three repositories.

```
Layer 5: Ongoing Federation
         ↑
Layer 4: Post-Entry Sync
         ↑
Layer 3: Entry & Verification
         ↑
Layer 2: Invitation & Distribution
         ↑
Layer 1: Bootstrap & Identity
```

---

## The Full Flow (10 Phases)

### Phase 1: Distribution
- User downloads Thyra from website or app store
- App includes embedded genesis spora
- No network required for initial install

### Phase 2: Bootstrap
- First launch: create kosmos.db from embedded spora
- 750+ entities, 990+ bonds loaded
- Self-contained, no external dependencies

### Phase 3: Identity Creation
- Generate BIP-39 mnemonic (24 words)
- Derive Ed25519 keypair for signing
- Create prosopon entity
- Create home oikos with user as sovereign

### Phase 4: Invitation Creation
- User selects oikos to invite to
- Create propylon link with:
  - Oikos ID
  - Inviter's public key
  - Message
  - Expiry / constraints
- Encode as URL-safe string
- Share via any channel (text, email, QR)

### Phase 5: Link Landing
- Friend clicks link: `https://thyra.link/p/xyz...`
- Landing page detects:
  - Has Thyra? → Deep link to app
  - No Thyra? → Download prompt with link preserved

### Phase 6: Entry Request
- Friend opens Thyra with link
- Link decoded and validated
- Friend enters display name
- Connect to relay, join room
- Wait for inviter

### Phase 7: Signaling
- Both devices connected to relay
- Relay coordinates SDP exchange
- ICE candidates exchanged
- WebRTC peer connection established
- Relay exits once P2P connected

### Phase 8: Human Verification
- Video/audio streams over WebRTC
- Inviter sees friend's face
- "The call IS the verification"
- Approve → proceed
- Reject → connection closed

### Phase 9: Phoreta Exchange
- On approval, inviter creates phoreta bundle:
  - Friend's prosopon
  - Oikos membership bond
  - Attainments (express, perceive)
  - Signed by inviter's key
- Send phoreta over WebRTC data channel
- Friend imports, now has membership

### Phase 10: Ongoing Federation
- Oikos content syncs via data channel
- Incremental phoreta for updates
- Reconnection when available
- Multiple members can sync P2P

> **Via Negativa (from ALIGNMENT.md):** Phase 10 is explicitly **post-MVP**. MVP is complete when a friend joins an oikos (Phase 9 complete). Ongoing sync adds complexity without changing the core value proposition.

---

## MVP Scope

Per [ALIGNMENT.md](./ALIGNMENT.md) Lens 4 (Via Negativa), MVP is defined as:

```
MVP = Phase 9 complete
    = Friend has membership in their local kosmos
    = They can see oikos content (one-time sync)

NOT MVP:
    - Ongoing sync (Phase 10)
    - Multi-platform (macOS only)
    - Custom sync policies
    - Multiple relay fallbacks
```

---

## Repository Responsibilities

### [chora](https://github.com/liminalcommons/chora)

Development repository — where actualization occurs.

| Component | Purpose |
|-----------|---------|
| `genesis/` | Oikos definitions (eide, desmoi, praxeis) |
| `crates/kosmos/` | Rust interpreter |
| `crates/kosmos-mcp-v8/` | MCP server bridge |
| `app/thyra/` | Desktop application |
| `docs/` | Developer documentation |

**Outputs:**
- Buildable Thyra application
- Published oikoi → kosmos
- Emitted documentation → kosmos

### [kosmos](https://github.com/liminalcommons/kosmos)

Publication repository — the generative commons distribution point.

| Component | Purpose |
|-----------|---------|
| `oikoi/core/` | MVP-critical oikos packages |
| `oikoi/extended/` | Post-MVP oikos packages |
| `phoreta/` | Federation bundles |
| `theoria/` | Crystallized understanding |
| `docs/` | Emitted reference documentation |

**Receives:**
- Oikoi published from chora
- Phoreta exported from chora
- Documentation emitted from chora

### [propylon-relay](https://github.com/liminalcommons/propylon-relay)

Infrastructure repository — the signaling bridge.

| Component | Purpose |
|-----------|---------|
| `src/` | Cloudflare Worker + Durable Objects |
| WebSocket | Real-time signaling |
| Durable Objects | Room state management |

**Provides:**
- `wss://propylon.liminalcommons.com` — WebSocket endpoint
- `https://thyra.link/p/...` — Landing page for links

---

## Component Summary

| Component | Status | Repository |
|-----------|--------|------------|
| kosmos interpreter | ✅ Complete | chora |
| Genesis spora (750+ entities) | ✅ Complete | chora |
| MCP server | ✅ Complete | chora |
| propylon praxeis (11) | ✅ Complete | chora |
| aither praxeis (WebRTC) | ✅ Complete | chora |
| hypostasis praxeis (phoreta) | ✅ Complete | chora |
| propylon-relay | ✅ Deployed | propylon-relay |
| Thyra app shell | ⏳ In progress | chora |
| Landing page | 🔲 Planned | propylon-relay |
| Core oikoi published | 🔲 Planned | kosmos |

---

## Security Summary

| Concern | Mitigation |
|---------|------------|
| Link interception | Links are single-use; video call verifies identity |
| Replay attack | Nonce-based challenge; signatures tied to session |
| Man-in-middle | E2E encryption after WebRTC established |
| Impersonation | Human verification — eyes and ears |
| Key compromise | Oikos-scoped keys limit blast radius |
| Relay trust | Relay only sees encrypted SDP; no access to content |

---

## The Sovereignty Promise

Per [ALIGNMENT.md](./ALIGNMENT.md) Lens 6 (Federation Sovereignty), the invitation flow maintains a clear sovereignty model that should be visible to users:

```
Your oikos is YOURS.
- You decide who enters.
- You decide what they can do.
- You decide what leaves and arrives via sync.
- You can revoke membership at any time.
- Your sovereignty rests on your mnemonic.
  (Guard it; it is you.)

When you JOIN an oikos:
- You are a guest in another's sovereignty.
- You receive what you're granted.
- You can leave whenever you wish.
- You bring nothing of their oikos to yours
  unless explicitly shared.
```

This is not just technical architecture — it's the social contract of the system.

---

## What Needs Building

| Layer | Status | Work Remaining |
|-------|--------|----------------|
| Genesis & Interpreter | ✅ Done | — |
| MCP Bridge | ✅ Done | — |
| Relay Core | ✅ Done | Landing page (R2) |
| Thyra Foundation | ⏳ C1-C2 | Bootstrap, identity UI |
| Invitation Flow | 🔲 C3-C6 | Links, signaling, video |
| Phoreta Exchange | 🔲 C7-C8 | Membership, sync |
| Production Polish | 🔲 C9 | Edge cases, retry |
| Kosmos Publication | 🔲 K1-K5 | Oikoi, phoreta, docs |

---

## Critical Path

The minimal path to MVP:

```
Genesis ✅  →  Relay ✅  →  C1 (app shell)
                              ↓
                         C2 (identity)
                              ↓
                         C3 (create link)
                              ↓
                         C4 (signaling)
                              ↓
                         C5 (entry request)
                              ↓
                         C6 (video verify)
                              ↓
                         C7 (phoreta)
                              ↓
                         MVP: Friend joins
```

**Blocking dependencies:**
- C4 requires relay (✅ deployed)
- C5 requires C4 (signaling infrastructure)
- C6 requires C5 (entry flow exists)
- C7 requires C6 (approval triggers phoreta)

---

## Related Documents

- [ROADMAP.md](./ROADMAP.md) — Detailed Thyra phase tasks (C1-C9), relay phases (R1-R3), combined timeline
- [ALIGNMENT.md](./ALIGNMENT.md) — Design review (6 lenses: ontological, trust, failure, via negativa, phenomenological, sovereignty)
- [propylon/DESIGN.md](../propylon/DESIGN.md) — Propylon link philosophy and praxeis
- [hypostasis/DESIGN.md](../hypostasis/DESIGN.md) — Phoreta and cryptographic identity
- [aither/DESIGN.md](../aither/DESIGN.md) — WebRTC signaling architecture
- [ROADMAP.md](../ROADMAP.md) — Full kosmos infrastructure roadmap (phases 1-32+)
- [kosmos README](https://github.com/liminalcommons/kosmos/README.md) — Kosmos publication roadmap (K1-K5)

---

*χώρα receives. Three repositories, one flow.*
*Traces to: phasis/genesis-root*
