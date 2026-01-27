# Propylon: Entry via Links

*Phase 23 — πρόπυλον (propylon): the gateway, the entrance before the entrance*

---

## Purpose

Propylon enables entry to the kosmos through self-contained invitation links. The link carries everything needed — relay URL, circle reference, inviter's signature, expiry. No external lookup required.

**Key insight:** Links are primary. The channel for sharing links is orthogonal.

---

## Philosophy: Sovereignty Preserved

The design follows these principles:

1. **Links are self-contained** — Everything needed is in the URL
2. **Links are self-validating** — Signature proves origin without external verification
3. **Relay is a dumb pipe** — Just forwards signaling, stores nothing
4. **Channels are your choice** — QR, SMS, email, paper, password manager
5. **Mnemonic is identity only** — Not location, not state

This preserves sovereignty: no one can prevent you from generating or sharing links.

### Three Separate Concerns

| Concern | Mechanism | Loss Impact |
|---------|-----------|-------------|
| **Identity** | Mnemonic (24 words) | If lost, you're gone |
| **Location** | Links (relay URL + circle) | If lost, need new link |
| **State** | Sync over P2P | If lost, need recovery |

These remain separate. The mnemonic doesn't encode where to connect. Links don't contain state.

---

## Implementation Status

| Phase | Status | Notes |
|-------|--------|-------|
| 23.1 Core Eide & Desmoi | ✅ COMPLETE | `propylon-link`, `propylon-session` defined |
| 23.2 Challenge-Response | ✅ COMPLETE | Praxeis exist, interpreter functions added |
| 23.3 Link Encoding | ✅ COMPLETE | base64url_encode, json_encode implemented |
| 23.4 Landing Page & Relay | ✅ COMPLETE | Landing page + WebRTC signaling relay |
| 23.5 WebRTC Handoff | ✅ COMPLETE | Direct P2P via Durable Objects signaling |
| 23.6 End-to-End Testing | ⏳ NEXT | Real invitation links through full flow |
| 23.7 Self-Federation | ✅ COMPLETE | `create-self-link` praxis implemented |
| 23.8 WebAuthn Support | ⏳ OPTIONAL | Hardware key support (YubiKey etc.) |

---

## Use Cases

### 1. Inviting Others (Peer Entry)

Alice invites Bob to her circle:

```
Alice's Thyra                              Bob
     │                                      │
     ├── create-link → propylon-link ──────┤
     │                                      │
     ├── Share via any channel ─────────────┤
     │   (QR, SMS, email, Signal...)        │
     │                                      │
     │                    Click link ◀──────┤
     │                                      │
     │◀── WebRTC signaling (relay) ─────────┤
     │                                      │
     ├── Human verification (call) ─────────┤
     │   "The call IS the verification"     │
     │                                      │
     ├── confirm/reject ────────────────────┤
     │                                      │
     └── P2P established, relay forgotten ──┘
```

### 2. Self-Federation (Device Sync)

Same persona on multiple devices:

```
Device A                                Device B
   │                                       │
   ├── create-self-link ───────────────────┤
   │   (for own persona)                   │
   │                                       │
   ├── Store link (password manager) ──────┤
   │                                       │
   │                     Fresh install ◀───┤
   │                                       │
   │                     Enter mnemonic ◀──┤
   │   (identity restored)                 │
   │                                       │
   │                     Enter link ◀──────┤
   │   (location known)                    │
   │                                       │
   │◀── P2P sync ──────────────────────────┤
   │                                       │
   └── Same kosmos, two substrates ────────┘
```

### 3. Recovery (Lost Devices)

When all devices are lost:

| What's Available | Recovery Path |
|------------------|---------------|
| Mnemonic + saved link | Full restore via self-federation |
| Mnemonic only | Identity restored; need peer to re-invite |
| Mnemonic + backup file | Full restore from phoreta (encrypted backup) |
| Nothing | Sovereignty means you can lose everything |

**Social recovery:** Trusted peers can regenerate invitations. This is a circle feature, not infrastructure.

---

## The Link

An invitation link encodes everything needed to attempt entry:

```yaml
propylon-link:
  invitation_id: string       # Reference to invitation entity
  bootstrap: string           # Relay URL (e.g., wss://propylon.liminalcommons.com)
  circle_id: string           # Target circle
  inviter_id: string          # Who created the link
  inviter_pubkey: string      # Ed25519 public key for signature verification
  signature: string           # Ed25519 signature over invitation_id

  # Constraints
  expires_at: timestamp?      # Optional expiry
  max_uses: number?           # Single-use or multi-use
  require_approval: boolean?  # Inviter must confirm

  # Display metadata
  display:
    circle_name: string?      # For link previews
    inviter_name: string?
    message: string?
```

**Encoding:** JSON → Base64url → URL

```
https://thyra.link/p/eyJpbnZpdGF0aW9uX2lkIjoi...
```

The link is self-validating:
- Decode Base64url → JSON
- Verify signature against inviter_pubkey
- Check expiry
- No external lookup needed

---

## The Relay

The relay is minimal infrastructure that **any commons can deploy and operate**.

**Repository:** [github.com/liminalcommons/propylon-relay](https://github.com/liminalcommons/propylon-relay)

**Does:**
- Forward WebRTC signaling (SDP, ICE candidates)
- Validate link signatures (as optimization)
- Host landing page

**Does NOT:**
- Store any state
- Know conversation content
- Persist beyond signaling
- Act as identity authority

The relay is:
- **Stateless** — Nothing persists
- **Replaceable** — The link specifies which relay
- **Commoditized** — Anyone can run one
- **Dumb** — Just forwards messages

This is infrastructure like roads — shared, replaceable, not controlling.

Each commons operates their own relay. The invitation link's `bootstrap` field specifies which relay to use:
```yaml
bootstrap: "wss://propylon.yourcommons.org"  # Your relay
```

---

## Authentication Flow

**Peer entry (human verification):**
```
Entrant → Click link → Relay validates → WebRTC signaling
       → Video call begins → Inviter sees/hears entrant
       → Inviter confirms → Animus created → P2P established
```

The call IS the verification — you see and hear the person. No cryptographic challenge needed for trusted peers.

**Self-federation (same persona):**
```
Device B → Enter mnemonic → Derive keypair
        → Enter link → Connect to relay → Signal to Device A
        → Device A verifies pubkey matches → Sync begins
```

For self-sync, cryptographic verification replaces human verification.

---

## Praxeis

| Praxis | Purpose | Status |
|--------|---------|--------|
| `propylon/create-link` | Generate shareable invitation link | ✅ Complete |
| `propylon/create-self-link` | Generate self-invite for device sync | ✅ Complete |
| `propylon/encode-link` | Encode link to URL-safe string | ✅ Complete |
| `propylon/decode-link` | Decode link from URL-safe string | ✅ Complete |
| `propylon/validate-link` | Check link validity (signature, expiry) | ✅ Complete |
| `propylon/challenge-entry` | Issue authentication challenge | ✅ Complete |
| `propylon/verify-entry` | Complete authentication, create animus | ✅ Complete |
| `propylon/approve-entry` | Inviter approves pending entry | ✅ Complete |
| `propylon/reject-entry` | Inviter rejects pending entry | ✅ Complete |
| `propylon/revoke-link` | Invalidate an invitation | ✅ Complete |
| `propylon/list-entry-audit` | Query entry history | ✅ Complete |

---

## Eide

| Eidos | Purpose |
|-------|---------|
| `propylon-link` | Shareable invitation link encoding |
| `propylon-session` | Authentication session state machine |

## Desmoi

| Desmos | From | To |
|--------|------|-----|
| `grants-entry-to` | propylon-link | circle |
| `authenticated-via` | animus | propylon-session |
| `used-link` | propylon-session | propylon-link |

---

## Optional Conveniences

These are NOT required but can enhance UX:

### WebAuthn (Phase 23.6)

Hardware key authentication (YubiKey) for:
- Local Thyra unlock
- Additional authentication factor
- Passwordless convenience

WebAuthn doesn't solve discovery (link still needed) but adds security.

### Domain-Based Discovery

For memorable addresses:
```
victor@liminalcommons.com
liminalcommons.com/.well-known/kosmos → bootstrap info
```

This requires domain ownership but enables human-friendly addressing.

### Vault Backup

Encrypted state backup:
- Store encrypted phoreta (state bundle)
- Self-hosted or trusted service
- Restore requires mnemonic + vault access

---

## Security Model

| Threat | Mitigation |
|--------|------------|
| Link interception | Single-use links, passphrase protection, expiry |
| Impersonation | Human verification (video call), pubkey verification |
| Relay compromise | Relay knows nothing; signaling only |
| Lost link | Generate new link, or have peer re-invite |
| Lost mnemonic | Gone forever (sovereignty includes failure) |

**Human verification model:**
> "The call IS the verification — you see and hear the person."

For trusted peers, eyes and ears prove identity better than cryptography.

---

## Interpreter Functions

Available for link creation/validation:

| Function | Purpose |
|----------|---------|
| `uuid()` | Generate invitation ID |
| `random_hex(bytes)` | Generate nonces |
| `json_encode/decode()` | Serialize link data |
| `base64url_encode/decode()` | URL-safe encoding |
| `timestamp_add_days/hours/minutes()` | Set expiry |
| `timestamp_before()` | Check expiry |

---

## Implementation Files

**Propylon Oikos** (ontology — this repo):
- `genesis/propylon/manifest.yaml` — Oikos package manifest
- `genesis/propylon/eide/propylon.yaml` — Eide definitions
- `genesis/propylon/desmoi/propylon.yaml` — Desmoi definitions
- `genesis/propylon/praxeis/propylon.yaml` — Praxis definitions

**Propylon Relay** (infrastructure — separate repo):
- [github.com/liminalcommons/propylon-relay](https://github.com/liminalcommons/propylon-relay)
- Cloudflare Worker for WebRTC signaling
- Any commons can deploy their own instance

---

## Constitutional Alignment

Propylon implements constitutional requirements from KOSMOGONIA:

| Principle | How Propylon Honors It |
|-----------|------------------------|
| **Visibility = Reachability** | Links encode the path to join a circle. You reach it because you received the link. The bond forms only after successful verification. |
| **Authenticity = Provenance** | Every link is signed by the inviter. Signature proves origin without external lookup. Challenge-response proves liveness. |
| **Composition Requirement** | `propylon-link` and `propylon-session` are composed entities with provenance bonds. Links trace to the inviter who created them. |
| **Sovereignty Preserved** | The mnemonic stays with the user. The link is self-contained. No central authority can revoke your identity or block link creation. |

**Caller Pattern:** Propylon content uses **literal** caller patterns. Link structure, relay URLs, and signatures are constitutional — they cannot be derived from other sources. This is entry infrastructure, not generated documentation.

---

## Next Steps

### Phase 23.6: End-to-End Testing

1. **Test peer invitation flow** — Create link, share, click, verify, establish P2P
2. **Test expiry and constraints** — Single-use, max_uses, expires_at
3. **Test revocation** — Revoke link, verify rejection
4. **Test approval flow** — require_approval=true, pending → approve/reject
5. **Test self-federation flow** — create-self-link, pubkey verification, sync

### Phase 23.8: WebAuthn (Optional)

1. **(Deferred) Add WebAuthn support** — Hardware key authentication for local unlock

---

*Links are primary. Channels are orthogonal. The relay forgets.*
*Traces to: expression/genesis-root*
