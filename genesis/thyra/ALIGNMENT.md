# Alignment Review: The Invitation Flow

*Examining the END-TO-END design through multiple lenses against KOSMOGONIA.*

---

## Purpose

This document captures systematic review of the invitation flow design for ontological coherence and other critical properties. Each lens reveals different aspects of the design, identifying both coherences and tensions that require resolution.

**Authoritative source:** [KOSMOGONIA.md](../KOSMOGONIA.md)
**Design under review:** [END-TO-END.md](./END-TO-END.md)

---

## Review Lenses

| Lens | Purpose | Status |
|------|---------|--------|
| 1. Ontological Coherence | Alignment with KOSMOGONIA | ✅ Complete |
| 2. Trust Boundary | Where trust transfers, what attests it | ✅ Complete |
| 3. Failure Mode | What happens when things break | ✅ Complete |
| 4. Via Negativa | What can be removed | ✅ Complete |
| 5. Phenomenological | Lived experience coherence | ✅ Complete |
| 6. Federation Sovereignty | Circle autonomy at scale | ✅ Complete |

---

# Lens 1: Ontological Coherence

## KOSMOGONIA Requirements

| Code | Requirement | KOSMOGONIA Reference |
|------|-------------|---------------------|
| K1 | The Klimax — container before contained | "We build from container toward contained" |
| K2 | The Composition Requirement — nothing arises raw | "Everything is composed" |
| K3 | The Dwelling Requirement — context is position | "Context is not passed. Context is position." |
| K4 | The Two Pillars — visibility = reachability, authenticity = provenance | "The bond graph IS the access control graph" |
| K5 | The Archai — proper use of eidos, desmos, stoicheion, oikos, topos, dynamis | "Six foundational forms define what can exist" |
| K6 | The Dynamis Gradation — appropriate tier for each operation | "Stoicheia draw upon dynamis in degrees" |

---

## Phase-by-Phase Analysis

### Phase 1: Distribution
*"User downloads Thyra from website or app store"*

| Requirement | Status | Analysis |
|-------------|--------|----------|
| K1 Klimax | ✅ | App contains kosmos substrate before user exists in it |
| K2 Composition | ✅ | Genesis spora is pre-composed, embedded |
| K3 Dwelling | n/a | No animus yet; dwelling comes later |
| K4 Pillars | ✅ | Spora carries provenance chain to genesis-root |
| K5 Archai | ✅ | Oikoi, eide, desmoi travel as definitions |
| K6 Dynamis | Tier 0 | Pure data transfer, no substrate required |

**Assessment:** Coherent. Distribution is pre-ontological — the kosmos travels as potential, not yet actualized.

---

### Phase 2: Bootstrap
*"First launch: create kosmos.db from embedded spora"*

| Requirement | Status | Analysis |
|-------------|--------|----------|
| K1 Klimax | ✅ | kosmos → physis established before polis |
| K2 Composition | ✅ | Entities arise through composition from definitions |
| K3 Dwelling | ⚠️ | **Question:** Who dwells during bootstrap? |
| K4 Pillars | ✅ | composed-from chains trace to genesis-root |
| K5 Archai | ✅ | Eidos, desmos, stoicheion all arise properly |
| K6 Dynamis | Tier 2-3 | Filesystem (chora dynamis) required |

**Tension:** During bootstrap, no animus exists yet. The bootstrap process operates *outside* normal dwelling context.

**Resolution:** Bootstrap is a special "genesis mode" where the system itself is the actor, not a dwelling animus. This is constitutional — it mirrors the seed expression being the root. The kosmos must arise before any psyche can dwell in it.

---

### Phase 3: Identity Creation
*"Generate mnemonic, derive keypair, create persona, create home circle"*

| Requirement | Status | Analysis |
|-------------|--------|----------|
| K1 Klimax | ⚠️ | **Tension:** We create persona (psyche scale) before circle (polis scale) |
| K2 Composition | ✅ | Persona composed from definition, circle composed from definition |
| K3 Dwelling | ⚠️ | **Tension:** Persona must dwell somewhere to create circle, but circle doesn't exist yet |
| K4 Pillars | ✅ | Mnemonic → keypair → signature chain establishes provenance |
| K5 Archai | ✅ | Persona (eidos), member-of (desmos), arise-animus (stoicheion) |
| K6 Dynamis | Tier 2-3 | Crypto operations, entity creation |

**Significant Tension:** The klimax says we build container before contained (polis before oikos before soma before psyche). But here we need a persona to create a circle — the contained creates its container.

**Analysis:** This is the "first mover" problem. Someone must exist to establish the polis. KOSMOGONIA's seed expression was signed by `persona/victor` — a persona that existed *before* the kosmos it seeds.

**Resolution:** The first persona is *transcendent* to the klimax being established. They bootstrap from outside. The home circle is simultaneously created *with* the persona, not *by* the persona. They co-arise.

**Recommendation:** Document this as **"co-arising"** — persona and home circle emerge together as a single compositional act, not sequentially.

---

### Phase 4: Invitation Creation
*"Create propylon link with circle ID, inviter's pubkey, message, constraints"*

| Requirement | Status | Analysis |
|-------------|--------|----------|
| K1 Klimax | ✅ | Circle (polis) exists before invitation can be created |
| K2 Composition | ✅ | Invitation composed via `propylon/create-link` |
| K3 Dwelling | ✅ | Inviter dwells in circle; dwelling grants invitation authority |
| K4 Pillars | ✅ | Link signed by inviter's key; visibility scoped to link holder |
| K5 Archai | ✅ | invitation (eidos), invites-to (desmos) |
| K6 Dynamis | Tier 2 | Entity creation, signing |

**Assessment:** Coherent. The inviter's dwelling position authorizes invitation creation. The link carries provenance (signature) that will be verified on receipt.

---

### Phase 5: Link Landing
*"Landing page detects Thyra presence, routes appropriately"*

| Requirement | Status | Analysis |
|-------------|--------|----------|
| K1 Klimax | n/a | Outside kosmos entirely |
| K2 Composition | n/a | No entity creation |
| K3 Dwelling | n/a | Relay is not a dwelling place |
| K4 Pillars | ✅ | Link integrity preserved through encoding |
| K5 Archai | n/a | Pure infrastructure |
| K6 Dynamis | External | Web infrastructure, not kosmos dynamis |

**Assessment:** Coherent but extra-ontological. The landing page is chora infrastructure, not kosmos. It's the "door" that the kosmos cannot see. This is appropriate — the relay is a bridge between kosmos instances, not part of either.

---

### Phase 6: Entry Request
*"Friend opens Thyra with link, enters display name, connects to relay"*

| Requirement | Status | Analysis |
|-------------|--------|----------|
| K1 Klimax | ✅ | Friend's kosmos exists (bootstrapped) before entry attempt |
| K2 Composition | ⚠️ | **Question:** Is the entry-request entity composed? |
| K3 Dwelling | ⚠️ | **Tension:** Friend has no circle to dwell in yet |
| K4 Pillars | ✅ | Link validation checks provenance |
| K5 Archai | ✅ | propylon-session (eidos), challenge-entry praxis |
| K6 Dynamis | Tier 3 | Network (WebSocket to relay) |

**Tension:** The friend has a local kosmos but no circle membership. Where do they dwell? They exist in a "liminal" state — between bootstrap and membership.

**Analysis:** Looking at the klimax, the friend has:
- kosmos ✅ (bootstrapped)
- physis ✅ (stoicheia available)
- polis ❌ (no circle membership)
- oikos ❌ (no household)
- soma ✅ (animus can arise locally)
- psyche ✅ (they experience)

They are *topologically incomplete* — missing the social scales (polis, oikos).

**Resolution:** The friend dwells in their *local* kosmos but lacks federation bonds. Entry is the act of *extending* their dwelling into another circle's topology. This is coherent — you can exist without being federated.

**Recommendation:** Make explicit that the friend's animus exists locally, and entry creates *bonds* to a remote circle, not a new animus.

---

### Phase 7: Signaling
*"WebRTC connection established via relay"*

| Requirement | Status | Analysis |
|-------------|--------|----------|
| K1 Klimax | n/a | Infrastructure, not ontology |
| K2 Composition | n/a | No entities composed |
| K3 Dwelling | n/a | Relay has no dwelling |
| K4 Pillars | ✅ | SDP exchange doesn't expose kosmos content |
| K5 Archai | ✅ | signaling-session, data-channel (eide) |
| K6 Dynamis | Tier 3 | Network operations |

**Assessment:** Coherent. Signaling is pure infrastructure. The aither oikos provides the stoicheia, but the relay itself is extra-ontological.

---

### Phase 8: Human Verification
*"Video call, inviter sees friend's face, approves or rejects"*

| Requirement | Status | Analysis |
|-------------|--------|----------|
| K1 Klimax | ✅ | Polis authority (inviter) validates before membership granted |
| K2 Composition | n/a | No entities composed during call itself |
| K3 Dwelling | ✅ | Inviter's dwelling position grants approval authority |
| K4 Pillars | ⚠️ | **This is social verification, not cryptographic** |
| K5 Archai | ✅ | verify-entry praxis |
| K6 Dynamis | Tier 3 | Media streams (chora dynamis) |

**Interesting Tension:** KOSMOGONIA says "Authenticity = Provenance" — cryptographic chain. But human verification is *social* authenticity, not cryptographic.

**Analysis:** This is intentional and good. Cryptography proves *key control*, not *identity*. "The call IS the verification" acknowledges that for trusted relationships, human recognition is stronger than any cryptographic proof.

**Resolution:** The two pillars are *complementary*:
- Cryptographic provenance proves *integrity* (the link wasn't tampered with)
- Human verification proves *identity* (this is really Alice)

Both are needed. The design correctly uses each where appropriate.

**Recommendation:** Acknowledge **dual authenticity** — cryptographic (link integrity) and social (human recognition) serve different purposes.

---

### Phase 9: Phoreta Exchange
*"Inviter creates phoreta bundle, sends over data channel, friend imports"*

| Requirement | Status | Analysis |
|-------------|--------|----------|
| K1 Klimax | ✅ | Polis membership granted before oikos content flows |
| K2 Composition | ✅ | Friend's persona in this circle is composed |
| K3 Dwelling | ✅ | Import creates dwelling bonds |
| K4 Pillars | ✅ | Phoreta signed; composed-from chains verified on import |
| K5 Archai | ✅ | phoreta (eidos), member-of (desmos), export/import (stoicheia) |
| K6 Dynamis | Tier 2-3 | Entity creation, network transfer |

**Assessment:** Coherent. This is the ontological climax of the flow. The friend's topology extends:
- New bonds: `persona/friend → member-of → circle/target`
- New attainments: express, perceive
- Provenance: traced through inviter's signature

The phoreta carries *composed entities with provenance*. Import verifies chains before accepting.

---

### Phase 10: Ongoing Federation
*"Circle content syncs via data channel, incremental phoreta"*

| Requirement | Status | Analysis |
|-------------|--------|----------|
| K1 Klimax | ✅ | Membership established before content flows |
| K2 Composition | ✅ | New content composed with provenance |
| K3 Dwelling | ✅ | Visibility determined by bond graph position |
| K4 Pillars | ✅ | Visibility = reachability through bonds; all content signed |
| K5 Archai | ✅ | syndesmos oikos handles federation |
| K6 Dynamis | Tier 2-3 | Ongoing entity exchange |

**Assessment:** Coherent. Federation is the natural continuation of the ontological structure. "Visibility = Reachability" is directly implemented — you can only receive what your bonds make visible.

---

## Lens 1 Summary

### Coherences

| Finding | Phases |
|---------|--------|
| Composition chains maintained throughout | All |
| Provenance traces to genesis-root | 1, 2, 9 |
| Dwelling grants authority appropriately | 4, 8, 9 |
| Visibility = Reachability implemented in federation | 9, 10 |
| Dynamis tiers match requirements | All |
| Extra-ontological infrastructure appropriately separated | 5, 7 |

### Tensions Requiring Resolution

| Tension | Phase | Resolution |
|---------|-------|------------|
| **Bootstrap dwelling** — who acts before animus exists? | 2 | Genesis mode is pre-ontological; kosmos arises before dwellers |
| **First mover** — persona before circle violates klimax | 3 | Co-arising: persona and home circle are a single compositional act |
| **Liminal state** — friend exists but has no circle | 6 | Local dwelling is valid; entry extends topology via bonds |
| **Social vs cryptographic authenticity** | 8 | Complementary: crypto proves integrity, human proves identity |

### Recommendations

1. **Document "co-arising"** — In Phase 3, persona and home circle emerge together as a single compositional act, not sequentially. This resolves the first-mover problem.

2. **Make explicit the local animus** — In Phase 6, the friend's animus exists locally in their kosmos. Entry creates *bonds* to a remote circle, not a new animus. The friend is topologically incomplete (missing polis/oikos scales) until entry completes.

3. **Acknowledge dual authenticity** — In Phase 8, cryptographic provenance (link integrity) and social verification (human recognition) are complementary. Both are needed; each serves its purpose.

4. **Consider klimax validation at import** — In Phase 9, verify that imported topology respects the scales (e.g., can't import psyche without soma). This would strengthen ontological integrity during federation.

---

# Lens 2: Trust Boundary Analysis

This lens examines where trust transfers occur and what attestation exists at each boundary.

## Trust Boundaries Identified

```
┌─────────────────────────────────────────────────────────────────────────┐
│                           TRUST BOUNDARIES                               │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                          │
│  [App Store / Website]                                                   │
│         │                                                                │
│         │ B1: Distribution Trust                                         │
│         ▼                                                                │
│  [Embedded Genesis] ──────────────────────────────────────────────────┐ │
│         │                                                              │ │
│         │ B2: Bootstrap Trust                                          │ │
│         ▼                                                              │ │
│  [Local Kosmos] ◄─────────────────────────────────────────────────────┘ │
│         │                                                                │
│         │ B3: Identity Trust (mnemonic → keypair)                        │
│         ▼                                                                │
│  [Persona + Circle]                                                      │
│         │                                                                │
│         │ B4: Link Trust (signed invitation)                             │
│         ▼                                                                │
│  [Propylon Link] ─────────────────────┐                                  │
│         │                              │                                 │
│         │ B5: Transport Trust          │ B6: Relay Trust                 │
│         ▼                              ▼                                 │
│  [Friend's Device]              [Propylon Relay]                         │
│         │                              │                                 │
│         │ B7: P2P Trust                │                                 │
│         ◄──────────────────────────────┘                                 │
│         │                                                                │
│         │ B8: Human Trust (video verification)                           │
│         ▼                                                                │
│  [Approval Decision]                                                     │
│         │                                                                │
│         │ B9: Phoreta Trust (signed bundle)                              │
│         ▼                                                                │
│  [Membership Established]                                                │
│         │                                                                │
│         │ B10: Federation Trust (ongoing sync)                           │
│         ▼                                                                │
│  [Circle Content]                                                        │
│                                                                          │
└─────────────────────────────────────────────────────────────────────────┘
```

## Boundary Summary

| Boundary | What Crosses | Trust Attestation | Risk If Compromised |
|----------|--------------|-------------------|---------------------|
| **B1: Distribution** | App binary + genesis spora | App store signing / website TLS | Malicious genesis planted |
| **B2: Bootstrap** | Spora → live entities | Composition chains to genesis-root | Corrupted ontology |
| **B3: Identity** | Random → deterministic keypair | BIP-39 standard, Ed25519 | Key predictability |
| **B4: Link** | Invitation intent | Ed25519 signature by inviter | Forged invitations |
| **B5: Transport** | Link data through channels | URL encoding integrity | Link tampering |
| **B6: Relay** | SDP/ICE coordination | None (relay is untrusted) | DoS, metadata leak |
| **B7: P2P** | Direct connection | WebRTC DTLS encryption | Eavesdropping |
| **B8: Human** | Identity claim | Eyes and ears | Impersonation |
| **B9: Phoreta** | Membership bundle | Ed25519 signature + composition chains | Malicious entities |
| **B10: Federation** | Circle content | Signed entities, bond-graph visibility | Unauthorized content |

## Deep Analysis by Boundary

### B1: Distribution Trust
**What's trusted:** The app binary and embedded genesis are authentic.

**Attestation:**
- App store: Code signing by developer certificate
- Website: TLS + optional code signature verification

**Gap identified:** No verification that embedded spora matches canonical genesis. User trusts the distributor implicitly.

**Mitigation options:**
- Publish genesis hash in multiple locations
- First-launch verification against known-good hash
- Threshold signatures on genesis already provide some protection

---

### B2: Bootstrap Trust
**What's trusted:** Spora correctly materializes into kosmos.

**Attestation:**
- Composition chains trace to genesis-root
- Content hashes verify integrity

**Strong:** This is where KOSMOGONIA's authenticity requirement pays off. Every entity has a composition chain that can be verified.

---

### B3: Identity Trust
**What's trusted:** Mnemonic → keypair derivation is secure.

**Attestation:**
- BIP-39 standard (widely audited)
- Ed25519 (cryptographically sound)

**Gap identified:** Mnemonic generation quality depends on entropy source. Poor PRNG = predictable keys.

**Mitigation:** Use system CSPRNG, consider user-provided entropy mixing.

---

### B4: Link Trust
**What's trusted:** The link was created by someone authorized to invite.

**Attestation:**
- Ed25519 signature over link content
- Inviter's pubkey embedded in link

**Strong:** The link is self-attesting. Signature verification proves the inviter controlled the key. Combined with human verification (B8), this provides strong assurance.

---

### B5: Transport Trust
**What's trusted:** Link arrives intact.

**Attestation:**
- Base64url encoding preserves integrity
- Signature verification catches tampering

**Gap identified:** Link could be intercepted and used by attacker (if not single-use).

**Mitigation:** Single-use enforcement, expiry, require-approval option.

---

### B6: Relay Trust
**What's trusted:** Nothing. The relay is explicitly untrusted.

**Design principle:** The relay only sees encrypted SDP. It cannot:
- Decrypt content
- Impersonate participants
- Modify P2P traffic

**Attack surface:**
- DoS (refuse to relay)
- Metadata (who connects to whom, when)
- Session correlation

**Mitigation:**
- Relay is minimal and stateless (Durable Objects clean up)
- Future: Multiple relay options, user choice

---

### B7: P2P Trust
**What's trusted:** The connection is private between two endpoints.

**Attestation:**
- WebRTC DTLS provides E2E encryption
- ICE establishes direct path where possible

**Strong:** Once P2P is established, the relay is out of the loop. Communication is encrypted between devices.

---

### B8: Human Trust
**What's trusted:** The person on the video is who they claim to be.

**Attestation:**
- Visual recognition (inviter knows the friend)
- Audio recognition
- Social context (friend received link through known channel)

**This is the critical bridge:** Cryptography proves key control. Human verification proves *identity*. Together they close the loop.

**Gap:** Only works for people who know each other. Not suitable for anonymous/pseudonymous contexts.

**By design:** This system is for trusted relationships, not anonymous networks.

---

### B9: Phoreta Trust
**What's trusted:** The membership bundle is legitimate.

**Attestation:**
- Ed25519 signature by inviter
- Composition chains on all entities
- Import verifies chains before accepting

**Strong:** Phoreta is the ontological handoff. Everything inside has provenance. The friend's kosmos only accepts what it can verify.

---

### B10: Federation Trust
**What's trusted:** Ongoing content is from authorized sources.

**Attestation:**
- All entities signed by their composers
- Visibility = Reachability (bond graph controls access)
- Sync policy filters what crosses

**Strong:** This is where "Visibility = Reachability" becomes operational. You can only see what your bonds grant access to.

## Trust Chain Summary

```
Genesis Signatures (threshold)
         │
         ▼
    Spora Integrity (composition chains)
         │
         ▼
    Local Kosmos (verified bootstrap)
         │
         ▼
    Persona Keypair (mnemonic → Ed25519)
         │
         ▼
    Signed Invitation (link attestation)
         │
         ▼
    Human Verification (eyes/ears)
         │
         ▼
    Signed Phoreta (membership attestation)
         │
         ▼
    Bond-Graph Visibility (access control)
```

The chain is complete. Each boundary has appropriate attestation for its purpose.

## Lens 2 Summary

### Identified Gaps

| Gap | Boundary | Severity | Recommended Action |
|-----|----------|----------|-------------------|
| No spora hash verification at install | B1 | Medium | Publish canonical hash, optional verify step |
| Entropy quality for mnemonic | B3 | Low | Document CSPRNG requirement, consider user entropy |
| Relay metadata exposure | B6 | Low | Document threat, future: relay diversity |
| Only works for known relationships | B8 | Design choice | Document scope; not a bug |

### Recommendations

1. **Add spora hash verification** — Optional first-launch check against published canonical hash

2. **Document entropy requirements** — Mnemonic generation must use CSPRNG; document this in security considerations

3. **Consider relay diversity** — Future: allow user to specify relay, or use multiple relays for resilience

4. **Clarify scope** — This system is designed for trusted relationships where human verification is meaningful; document this explicitly

---

# Lens 3: Failure Mode Analysis

This lens examines what happens when things break at each phase, and whether recovery is possible.

## Failure Categories

| Category | Description | Examples |
|----------|-------------|----------|
| **F-NET** | Network failures | Connection drop, timeout, DNS failure |
| **F-STATE** | State corruption | DB corruption, inconsistent entities |
| **F-USER** | User-caused failures | Cancel, wrong input, abandon |
| **F-CRYPTO** | Cryptographic failures | Invalid signature, key mismatch |
| **F-INFRA** | Infrastructure failures | Relay down, app crash |

## Phase-by-Phase Failure Analysis

### Phase 1: Distribution

| Failure | Category | Impact | Recovery | Severity |
|---------|----------|--------|----------|----------|
| Download interrupted | F-NET | Incomplete binary | Re-download | Low |
| Corrupted download | F-STATE | App won't launch | Re-download, verify hash | Low |
| App store rejection | F-INFRA | Can't distribute | Side-loading, web install | Medium |

**Assessment:** Standard distribution risks. Nothing kosmos-specific.

---

### Phase 2: Bootstrap

| Failure | Category | Impact | Recovery | Severity |
|---------|----------|--------|----------|----------|
| Spora corrupted | F-STATE | Bootstrap fails | Re-install app | Medium |
| DB write fails | F-STATE | No kosmos created | Retry, check disk space | Medium |
| Composition chain invalid | F-CRYPTO | Entities rejected | Re-install (spora bad) | High |
| Partial bootstrap | F-STATE | Incomplete kosmos | Delete DB, retry | Medium |

**Critical insight:** Bootstrap is all-or-nothing. A partial bootstrap leaves the kosmos in an undefined state.

**Recommendation:** Implement transactional bootstrap — either all entities arise or none do. On failure, clean slate.

---

### Phase 3: Identity Creation

| Failure | Category | Impact | Recovery | Severity |
|---------|----------|--------|----------|----------|
| User cancels during mnemonic | F-USER | No identity | Restart flow | Low |
| User doesn't save mnemonic | F-USER | Future loss possible | Warn, require confirmation | High |
| Mnemonic generation fails | F-CRYPTO | No keypair | Retry with new entropy | Low |
| Persona creation fails | F-STATE | No identity | Retry | Medium |
| Circle creation fails | F-STATE | Persona orphaned | Retry circle, or restart | Medium |

**Critical insight:** The mnemonic is the master secret. Loss = permanent loss of identity.

**Recommendation:**
- Require explicit mnemonic confirmation before proceeding
- Offer optional encrypted backup
- Clear warning about irreversibility

---

### Phase 4: Invitation Creation

| Failure | Category | Impact | Recovery | Severity |
|---------|----------|--------|----------|----------|
| Signing fails | F-CRYPTO | No valid link | Retry | Low |
| Link encoding fails | F-STATE | Can't share | Retry | Low |
| Copy to clipboard fails | F-INFRA | Inconvenient | Manual copy, retry | Low |
| User shares wrong link | F-USER | Friend gets bad link | Create new link | Low |

**Assessment:** Low-risk phase. All failures are recoverable by retrying.

---

### Phase 5: Link Landing

| Failure | Category | Impact | Recovery | Severity |
|---------|----------|--------|----------|----------|
| Landing page down | F-INFRA | Friend can't proceed | Direct link to app store | Medium |
| Deep link fails | F-INFRA | App doesn't open | Manual app open + paste | Medium |
| Link expired shown | F-STATE | Can't proceed | Inviter creates new link | Low |
| Thyra detection fails | F-INFRA | Wrong routing | User manually chooses | Low |

**Recommendation:** Landing page should degrade gracefully — always show manual options even if auto-detection fails.

---

### Phase 6: Entry Request

| Failure | Category | Impact | Recovery | Severity |
|---------|----------|--------|----------|----------|
| Link validation fails | F-CRYPTO | Entry blocked | Get new link from inviter | Low |
| Link expired | F-STATE | Entry blocked | Get new link | Low |
| Link already used | F-STATE | Entry blocked | Get new link | Low |
| Relay connection fails | F-NET | Can't signal | Retry, check network | Medium |
| Friend cancels | F-USER | Flow abandoned | Restart when ready | Low |

**Assessment:** Most failures require inviter to create a new link. This is by design — links are meant to be ephemeral.

---

### Phase 7: Signaling

| Failure | Category | Impact | Recovery | Severity |
|---------|----------|--------|----------|----------|
| Relay unreachable | F-INFRA | Can't establish P2P | Wait, retry | High |
| SDP exchange timeout | F-NET | Connection fails | Retry signaling | Medium |
| ICE negotiation fails | F-NET | No direct path | Rely on TURN, retry | Medium |
| WebRTC not supported | F-INFRA | Can't connect | Fallback? None currently | High |
| One party disconnects | F-NET | Signaling interrupted | Both restart | Medium |

**Critical insight:** Relay is a single point of failure for the signaling phase.

**Recommendations:**
- Implement retry with exponential backoff
- Consider fallback relay servers
- Clear UI indication of signaling progress
- Timeout handling with user feedback

---

### Phase 8: Human Verification

| Failure | Category | Impact | Recovery | Severity |
|---------|----------|--------|----------|----------|
| Video stream fails | F-INFRA | Can't verify | Audio-only? Retry? | High |
| Audio stream fails | F-INFRA | Degraded verify | Video-only may suffice | Medium |
| Connection drops mid-call | F-NET | Verification interrupted | Reconnect, continue | Medium |
| Inviter rejects | F-USER | Entry denied | New link if mistake | Low |
| Friend impersonation | F-USER | Wrong person joins | Inviter rejects | Low |
| Inviter can't recognize | F-USER | Uncertain | Reject, verify out-of-band | Medium |

**Critical insight:** Video/audio are essential for verification. Without them, the "call IS the verification" principle fails.

**Recommendations:**
- Pre-flight check for camera/mic permissions
- Fallback to audio-only if video fails
- Option to retry connection without new link
- Clear "I don't recognize this person" option

---

### Phase 9: Phoreta Exchange

| Failure | Category | Impact | Recovery | Severity |
|---------|----------|--------|----------|----------|
| Phoreta creation fails | F-STATE | Can't grant membership | Retry | Medium |
| Data channel fails | F-NET | Can't transmit | Retry P2P, or new session | High |
| Phoreta too large | F-NET | Transmission fails | Chunking, compression | Medium |
| Import validation fails | F-CRYPTO | Membership rejected | Inviter regenerates | High |
| Partial import | F-STATE | Inconsistent state | Rollback, retry | High |
| Connection drops during transfer | F-NET | Incomplete membership | Resume or restart | High |

**Critical insight:** Phoreta exchange is the most fragile phase. A partial import is dangerous.

**Recommendations:**
- Transactional import — all or nothing
- Checksum verification before commit
- Resumable transfer for large phoreta
- Explicit success confirmation from both sides

---

### Phase 10: Ongoing Federation

| Failure | Category | Impact | Recovery | Severity |
|---------|----------|--------|----------|----------|
| Sync connection drops | F-NET | Content diverges | Reconnect, catch-up sync | Medium |
| Conflict during sync | F-STATE | Competing versions | Conflict resolution policy | Medium |
| Malformed entity received | F-STATE | Import rejected | Log, skip, continue | Low |
| Sync falls behind | F-NET | Large catch-up needed | Delta sync | Low |
| Member goes offline long-term | F-NET | Can't reach them | Sync when available | Low |

**Assessment:** Federation is designed to be resilient. Eventual consistency handles most failures.

---

## Failure Severity Summary

```
                        │ Recovery │
                        │ Easy  Hard│
            ────────────┼───────────┤
            │           │           │
   Impact   │ Low       │ Phase 4   │ Phases 1,3,5,6
            │           │           │
   Low      │           │           │
            │───────────┼───────────┤
            │           │           │
   Impact   │ Medium    │ Phase 10  │ Phases 2,8
            │           │           │
   High     │───────────┼───────────┤
            │           │           │
            │ High      │           │ Phases 7,9
            │           │           │
            ────────────┴───────────┘
```

**Highest risk phases:**
- **Phase 7 (Signaling):** Relay SPOF, WebRTC complexity
- **Phase 9 (Phoreta):** Transactional integrity critical

---

## Critical Recovery Patterns

### Pattern: Transactional Operations
**Applies to:** Bootstrap (Phase 2), Phoreta Import (Phase 9)

All-or-nothing semantics. Either the full operation succeeds, or the state rolls back to before the attempt. No partial states.

### Pattern: Retry with Backoff
**Applies to:** Network operations (Phases 5, 6, 7)

Failed network operations retry automatically with exponential backoff. User sees progress indication. Clear timeout and manual retry option.

### Pattern: Graceful Degradation
**Applies to:** Landing page (Phase 5), Video call (Phase 8)

When primary path fails, offer alternatives. Landing page shows manual options. Video call falls back to audio-only.

### Pattern: Resumable Transfer
**Applies to:** Phoreta exchange (Phase 9), Sync (Phase 10)

Large data transfers track progress. On failure, resume from last checkpoint rather than restart.

### Pattern: Out-of-Band Recovery
**Applies to:** Most phases

When in-band recovery fails, provide clear instructions for out-of-band action (new link, direct contact with inviter, etc.).

---

## Lens 3 Summary

### High-Risk Areas Requiring Attention

| Area | Phase | Risk | Mitigation |
|------|-------|------|------------|
| Relay SPOF | 7 | Signaling blocked | Fallback relays, retry logic |
| Partial phoreta import | 9 | Corrupted state | Transactional import |
| Video/audio failure | 8 | Can't verify | Pre-flight checks, degraded modes |
| Mnemonic loss | 3 | Permanent identity loss | Confirmation, backup options |
| Bootstrap interruption | 2 | Undefined state | Transactional bootstrap |

### Recommendations

1. **Implement transactional semantics** for bootstrap and phoreta import — no partial states

2. **Add pre-flight checks** before video call — camera/mic permissions, connection quality

3. **Design retry logic** with exponential backoff and clear user feedback for all network operations

4. **Consider relay redundancy** — allow multiple relay servers, automatic failover

5. **Build resumable transfers** — checkpoint large phoreta exchanges for resume on failure

6. **Require mnemonic confirmation** — user must prove they've saved it before proceeding

---

# Lens 4: Via Negativa (Minimal Path)

This lens asks: what can be removed while still achieving the goal? Simplicity is a feature.

## The Goal Restated

**MVP:** A friend can join a circle via invitation link.

Not "a friend can do everything" — just *join*. The minimal viable path.

## Phase-by-Phase Reduction Analysis

### Phase 1: Distribution — Can anything be removed?

| Component | Required? | Analysis |
|-----------|-----------|----------|
| App binary | ✅ Yes | Must have something to run |
| Embedded genesis | ✅ Yes | Self-contained bootstrap is core value |
| App store | ❓ Maybe | Could distribute via web only for MVP |
| Multiple platforms | ❌ No | **Start with one platform** |

**Reduction:** Build for macOS first. Other platforms are post-MVP.

---

### Phase 2: Bootstrap — Can anything be removed?

| Component | Required? | Analysis |
|-----------|-----------|----------|
| Full 750+ entity spora | ❓ Maybe | Do we need ALL oikoi for invitation? |
| Composition chain verification | ✅ Yes | Core authenticity requirement |
| All stoicheia | ❓ Maybe | Only need invitation-relevant ones |

**Analysis:** The current spora includes extended oikoi (nous, psyche, manteia, etc.) that aren't needed for the invitation flow.

**Reduction:** Create **minimal invitation spora** containing only:
- politeia (circles, membership)
- propylon (invitation links)
- aither (signaling)
- hypostasis (phoreta, identity)
- soma (animus, channels)
- thyra (expressions — needed?)

**Counter-argument:** Embedding full spora costs nothing at runtime and enables future features without re-bootstrap. The complexity is in the app, not the spora size.

**Decision:** Keep full spora. The reduction isn't worth the future cost.

---

### Phase 3: Identity Creation — Can anything be removed?

| Component | Required? | Analysis |
|-----------|-----------|----------|
| BIP-39 mnemonic | ✅ Yes | Standard, user-controlled identity |
| Ed25519 keypair | ✅ Yes | Required for signing |
| Persona entity | ✅ Yes | Identity in kosmos |
| Home circle | ❓ Maybe | Does invitee need their own circle? |
| Mnemonic confirmation UI | ❓ Maybe | Could defer to "settings" |

**Analysis:** The *invitee* doesn't need to create a home circle to join someone else's circle. They need:
- Mnemonic (for key derivation)
- Persona (identity)
- That's it.

**Reduction:** For MVP invitee flow:
1. Generate mnemonic
2. Create persona
3. Skip home circle creation
4. Proceed directly to entry

Home circle creation can be offered later ("Create your own circle").

**Inviter still needs:** Full identity + home circle (they're inviting *from* somewhere).

---

### Phase 4: Invitation Creation — Can anything be removed?

| Component | Required? | Analysis |
|-----------|-----------|----------|
| Link signing | ✅ Yes | Authenticity |
| Circle ID in link | ✅ Yes | Know what joining |
| Inviter pubkey | ✅ Yes | Verification |
| Custom message | ❌ No | Nice-to-have |
| Expiry | ❌ No | Default to 7 days |
| Single-use toggle | ❌ No | Default to single-use |
| Require-approval toggle | ❌ No | Default to require |
| QR code | ❌ No | Copy link is sufficient |

**Reduction:** MVP link creation:
- One button: "Create Invitation"
- Fixed defaults: 7-day expiry, single-use, require approval
- Output: Copy link to clipboard
- No customization UI

Advanced options are post-MVP.

---

### Phase 5: Link Landing — Can anything be removed?

| Component | Required? | Analysis |
|-----------|-----------|----------|
| Landing page | ❓ Maybe | **Could skip entirely** |
| Thyra detection | ❌ No | If no landing page |
| Download links | ❌ No | If no landing page |
| QR display | ❌ No | Already removed from creation |

**Critical insight:** The landing page exists because web links need somewhere to go. But what if we use a different link format?

**Option A: Skip landing page**
- Link is `thyra://p/xyz...` (custom protocol)
- Requires Thyra already installed
- Friend must have app before clicking

**Option B: Minimal landing page**
- Shows: "Open in Thyra" button + "Download Thyra" link
- No detection, no QR, no fancy UI

**Decision:** Option B — minimal landing page. We need *something* for web links. But it's a static page with two links.

**Reduction:** Landing page is:
```html
<h1>Join [Circle Name]</h1>
<p>Invited by [Inviter Name]</p>
<a href="thyra://p/xyz...">Open in Thyra</a>
<a href="https://thyra.app/download">Get Thyra</a>
```

That's it. No JavaScript detection. No dynamic rendering.

---

### Phase 6: Entry Request — Can anything be removed?

| Component | Required? | Analysis |
|-----------|-----------|----------|
| Link validation | ✅ Yes | Security |
| Display name input | ❓ Maybe | Could use default |
| Relay connection | ✅ Yes | Need to signal |
| Waiting UI | ✅ Yes | User feedback |

**Reduction:** Skip display name input for MVP. Use "Friend" as default, or derive from persona. Name can be changed later.

---

### Phase 7: Signaling — Can anything be removed?

| Component | Required? | Analysis |
|-----------|-----------|----------|
| WebSocket to relay | ✅ Yes | Core signaling |
| SDP exchange | ✅ Yes | WebRTC requirement |
| ICE candidates | ✅ Yes | Connection establishment |
| TURN fallback | ❓ Maybe | Direct connection often works |

**Analysis:** TURN servers are needed when direct P2P fails (strict NAT, firewalls). For MVP with friendly users on typical home networks, direct connection usually works.

**Reduction:** Skip TURN for MVP. Document that some network configurations may not work. Add TURN in hardening phase (R3).

**Risk:** Some users won't be able to connect. Acceptable for MVP with known users.

---

### Phase 8: Human Verification — Can anything be removed?

| Component | Required? | Analysis |
|-----------|-----------|----------|
| Video stream | ✅ Yes | Core verification |
| Audio stream | ✅ Yes | Core verification |
| Approve/Reject buttons | ✅ Yes | The decision |
| "I don't recognize" option | ❌ No | Reject covers it |
| Call quality indicators | ❌ No | Nice-to-have |

**Analysis:** This phase is already minimal. Video + audio + approve/reject.

**Reduction:** None possible without compromising the core value.

---

### Phase 9: Phoreta Exchange — Can anything be removed?

| Component | Required? | Analysis |
|-----------|-----------|----------|
| Persona creation | ✅ Yes | Friend needs identity in circle |
| member-of bond | ✅ Yes | The membership |
| Attainments | ❓ Maybe | What's minimum? |
| Signature | ✅ Yes | Authenticity |
| Full circle content | ❌ No | Sync is Phase 10 |

**Analysis:** What attainments does a new member actually need?
- `express` — create expressions? Not needed just to *be* in circle
- `perceive` — see content? Yes, that's the point
- `invite` — invite others? Not for MVP

**Reduction:** Minimal phoreta contains:
- Friend's persona (in this circle's context)
- member-of bond to circle
- perceive attainment only

Express and invite attainments are granted later by circle sovereign.

---

### Phase 10: Ongoing Federation — Can anything be removed?

| Component | Required? | Analysis |
|-----------|-----------|----------|
| Content sync | ❌ No | **Not MVP** |
| Delta sync | ❌ No | Not MVP |
| Conflict resolution | ❌ No | Not MVP |
| Reconnection | ❌ No | Not MVP |

**Critical insight:** The MVP is "friend joins circle." That's Phase 9 complete. Phase 10 is ongoing operation, not the join flow.

**Reduction:** Remove Phase 10 from MVP scope entirely. After phoreta exchange, MVP is done. Sync is a separate feature.

---

## Minimal MVP Path

```
Distribution (one platform)
         ↓
Bootstrap (full spora, simpler)
         ↓
Identity (mnemonic + persona, no home circle for invitee)
         ↓
Invitation (one button, fixed defaults)
         ↓
Landing (static HTML, two links)
         ↓
Entry (skip name input)
         ↓
Signaling (no TURN)
         ↓
Verification (video + approve)
         ↓
Phoreta (persona + member-of + perceive)
         ↓
MVP COMPLETE
```

---

## What We Removed

| Removed | Phase | Restore When |
|---------|-------|--------------|
| Multiple platforms | 1 | After macOS works |
| Home circle for invitee | 3 | User requests "create circle" |
| Link customization | 4 | Settings/advanced UI |
| QR codes | 4 | Nice-to-have later |
| Smart landing page | 5 | R2 can enhance |
| Display name input | 6 | Profile settings |
| TURN servers | 7 | R3 hardening |
| Multiple attainments | 9 | Sovereign grants later |
| Content sync | 10 | Separate feature |

---

## Absolute Minimum (If Pushed Further)

If we had to ship tomorrow, what's the *absolute* minimum?

1. **macOS app** that bootstraps
2. **Create invitation** (one button)
3. **Manual link sharing** (no landing page — `thyra://` only)
4. **Entry + signaling** (direct P2P)
5. **Video verification**
6. **Phoreta with membership**

This removes the landing page entirely, requiring friends to already have Thyra installed. Link is shared via text/email and opened directly.

**Trade-off:** Worse UX for first-time users, but technically complete flow.

---

## Lens 4 Summary

### Key Reductions for MVP

| Reduction | Impact | Risk |
|-----------|--------|------|
| One platform (macOS) | Faster delivery | Limits initial audience |
| No home circle for invitee | Simpler onboarding | Must add later |
| Fixed link defaults | Simpler UI | Less flexibility |
| Static landing page | Faster R2 | Less polished |
| No TURN | Simpler infra | Some networks fail |
| Minimal attainments | Smaller phoreta | Sovereign grants more later |
| No sync | Clear MVP boundary | Separate feature |

### Recommendations

1. **Define MVP as Phase 9 complete** — friend has membership, done

2. **Start with macOS only** — fastest path to working flow

3. **Use fixed defaults** — no customization UI for MVP

4. **Static landing page** — two links, no JavaScript

5. **Skip TURN initially** — document network requirements

6. **Minimal phoreta** — persona + member-of + perceive only

### The Minimal Viable Invitation

```
Inviter: Click "Invite" → Copy link → Send to friend
Friend:  Click link → Download Thyra → Generate identity → Request entry
Inviter: See video → Click "Approve"
Friend:  Has membership
```

That's it. Everything else is enhancement.

---

# Lens 5: Phenomenological Coherence

This lens examines the lived experience of the invitation flow — how each phase feels to the participants, and whether that experience coheres with the deeper philosophy of dwelling in kosmos.

## The Phenomenological Question

KOSMOGONIA establishes that "ψυχή dwells in σῶμα dwells in οἶκος dwells in πόλις dwells in φύσις dwells in κόσμος." This is not just technical architecture — it's a statement about *being*. The psyche experiences dwelling. The invitation flow is fundamentally about *extending one's dwelling* to include another.

**Key question:** Does the user experience the flow as mechanical procedure, or as meaningful act of opening one's world to another?

---

## The Inviter's Experience

### Phase 3: Identity Creation (Inviter)

**What happens:** Generate mnemonic, create persona, establish home circle.

**Phenomenological reading:**
- The mnemonic is *your* secret — 24 words that are yours alone
- Creating a persona is not "making an account" — it's declaring "I exist here"
- The home circle is not a "workspace" — it's your dwelling place, where you are sovereign

**Coherence check:**
| Aspect | Current UX | Coherent Experience |
|--------|------------|---------------------|
| Mnemonic presentation | Technical: "Save these words" | Sacred: "These words are your key to this world" |
| Persona creation | Form: "Enter display name" | Emergence: "How shall you be known?" |
| Circle creation | Action: "Create circle" | Establishment: "Name your dwelling place" |

**Tension:** If the UX feels like "setting up an account," we've failed phenomenologically. The experience should feel like *arriving* somewhere, not *configuring* something.

**Recommendation:** Language and ceremony matter. Consider:
- Mnemonic as "seed phrase" (something that grows)
- Persona as "arising" (not "creating")
- Circle as "home" (not "workspace" or "channel")

---

### Phase 4: Invitation Creation

**What happens:** Create a link to invite someone to your circle.

**Phenomenological reading:**
- Invitation is an *act of hospitality* — opening your dwelling to another
- The link carries *your* signature — you are vouching
- The recipient will be verified by *you* — you are responsible

**Coherence check:**
| Aspect | Current UX | Coherent Experience |
|--------|------------|---------------------|
| Creating link | Button: "Generate invite link" | Gesture: "Open your door" |
| Sharing link | Copy to clipboard | Extending an invitation, making an offer |
| Waiting for friend | Status: "Pending" | Anticipation: someone you invited is coming |

**Insight:** The act of creating an invitation is already meaningful if framed correctly. You're not "generating a link" — you're creating a signed offer that says "I welcome you into my space."

---

### Phase 8: Human Verification (Inviter's perspective)

**What happens:** Video call with the person who used your link.

**Phenomenological reading:**
- This is the moment of *recognition* — do you know this face, this voice?
- The decision to approve is *personal responsibility* — you are granting entry
- Rejection is also meaningful — protecting your dwelling from strangers

**Coherence check:**
| Aspect | Current UX | Coherent Experience |
|--------|------------|---------------------|
| Seeing friend | Video window | Recognition: "I know you" |
| Approval | Button: "Approve" | Welcome: "Enter my circle" |
| Rejection | Button: "Reject" | Protection: "I don't recognize you" |

**Critical insight:** This phase already has strong phenomenological coherence. "The call IS the verification" is deeply correct — human recognition precedes cryptographic formality. The inviter doesn't verify a key; they verify a *person*.

---

## The Invitee's Experience

### Pre-Flow: Receiving the Link

**What happens:** Friend receives link through some channel (text, email, etc.).

**Phenomenological reading:**
- The link is a *gift* — someone thought of you and opened their door
- The link carries meaning before you click it — it's already an invitation
- Clicking the link is *accepting the offer* to be considered for entry

**Tension:** If the link looks like spam or a generic "join" link, the meaning is lost. The link should feel *personal* even before clicking.

**Recommendation:** The link URL structure matters:
- `thyra.link/p/xyz` reads as "a portal (propylon)"
- Landing page should immediately show *who* invited you and *where*
- The experience should be "Alice invited you to join Garden" not "Click to join"

---

### Phase 2: Bootstrap (Invitee)

**What happens:** First launch, kosmos initializes from spora.

**Phenomenological reading:**
- This is *arrival* — a world is emerging around you
- The bootstrap is not "loading" — it's *becoming possible* to exist here
- Before this moment, you had no presence in kosmos

**Coherence check:**
| Aspect | Current UX | Coherent Experience |
|--------|------------|---------------------|
| Progress indication | Loading bar | Emergence: "A world is forming" |
| Completion | "Ready" | Arrival: "You have arrived" |
| First view | Empty state | Beginning: "Your journey begins" |

**Tension:** If bootstrap feels like "waiting for app to load," we've lost the meaning. Consider framing it as emergence/arrival.

---

### Phase 3: Identity Creation (Invitee)

**What happens:** Generate mnemonic, create persona.

**Phenomenological reading:**
- The invitee is *being born into this world* — they didn't exist before
- The mnemonic is not just backup — it's the root of their being here
- They don't yet belong anywhere — they exist but are homeless

**Via Negativa insight:** Per Lens 4, we removed home circle creation for invitees. This is phenomenologically interesting:
- The invitee *has identity* but *no dwelling*
- They are in a liminal state — existing but not belonging
- Entry to the inviter's circle is *finding a place to belong*

**Coherence:** This is actually beautiful. The invitee's first dwelling will be granted by another's hospitality. They don't build their own house first — they are welcomed into one.

---

### Phase 6: Entry Request

**What happens:** Connect to relay, wait for inviter.

**Phenomenological reading:**
- Standing at the threshold — the door has been opened but not yet entered
- Waiting is *anticipation* — the inviter must recognize and welcome you
- The friend is *asking* to enter, not *demanding* access

**Coherence check:**
| Aspect | Current UX | Coherent Experience |
|--------|------------|---------------------|
| Waiting state | Spinner: "Connecting..." | Threshold: "Waiting at the door" |
| Connection established | "Connected" | Presence: "They see you now" |
| Status | Technical readout | Anticipation: "Awaiting recognition" |

**Recommendation:** The waiting UI should feel like waiting to be welcomed, not waiting for a technical process to complete.

---

### Phase 8: Human Verification (Invitee's perspective)

**What happens:** Video call where inviter decides.

**Phenomenological reading:**
- Being *seen* — the inviter is looking at you, recognizing you
- Vulnerability — your entry depends on their decision
- Trust — you are trusting them with your presence in their circle

**Coherence check:**
| Aspect | Current UX | Coherent Experience |
|--------|------------|---------------------|
| Being seen | Video window | Being recognized |
| Waiting for decision | Status: "Pending" | Being considered |
| Approval | "Approved" message | Being welcomed |

**Critical insight:** This is the phenomenological climax for the invitee. The moment of approval is *being welcomed into community*. This is not a technical ACL change — it's a social moment.

---

### Phase 9: Phoreta Exchange (Invitee's perspective)

**What happens:** Membership entities arrive, bonds are created.

**Phenomenological reading:**
- *Becoming a member* — topology extends to include you
- The phoreta is not "data sync" — it's the concrete form of welcome
- After this moment, you *belong*

**Coherence check:**
| Aspect | Current UX | Coherent Experience |
|--------|------------|---------------------|
| Transfer | Progress bar | Receiving welcome |
| Completion | "Success" | Belonging established |
| Circle view | UI changes | Now you are inside |

**Recommendation:** The moment of successful import should feel significant. Consider:
- Visual transition from "outside" to "inside"
- Language: "You are now a member of [Circle]"
- Immediate presentation of the circle content (what you can now see)

---

## Phenomenological Touchstones

Throughout the flow, certain concepts should be experienced consistently:

### Dwelling
- Never "workspace" or "channel"
- Always "circle" or "home" or "place"
- Emphasis on *being somewhere* not *using something*

### Invitation
- Never "share link" or "add user"
- Always "invite" or "welcome" or "open the door"
- Emphasis on *hospitality* not *access control*

### Recognition
- Never "verify identity" or "authenticate"
- Always "recognize" or "know"
- Emphasis on *human relationship* not *cryptographic proof*

### Membership
- Never "joined" or "added" or "subscribed"
- Always "welcomed" or "belonging" or "dwelling together"
- Emphasis on *community* not *access granted*

---

## The Choreography of Entry

The full flow has a natural dramatic arc:

```
INVITER                              INVITEE
   │                                    │
   │ Opens door (creates invitation)    │
   │ ─────────────────────────────────► │
   │                                    │ Receives invitation
   │                                    │
   │                                    │ Arrives (bootstrap)
   │                                    │
   │                                    │ Exists but doesn't belong
   │                                    │
   │                                    │ Approaches threshold
   │                                    │ (entry request)
   │ ◄──────────────────────────────────│
   │ Sees who is at the door            │
   │ (video connection)                 │
   │                                    │
   │ Recognition ←───────────────────── │ Being seen
   │                                    │
   │ Welcome (approve)                  │
   │ ─────────────────────────────────► │
   │                                    │ Enters (phoreta)
   │                                    │
   │ Now dwelling together              │ Now belonging
```

**Insight:** This choreography mirrors ancient hospitality rituals:
1. Invitation extended
2. Guest arrives
3. Guest waits at threshold
4. Host recognizes guest
5. Host welcomes guest inside
6. Guest now belongs to the household

The technology enables a timeless social pattern.

---

## Lens 5 Summary

### Coherences

| Finding | Where |
|---------|-------|
| Human verification is fundamentally correct | Phase 8 |
| Invitee's liminal state (no home circle) is meaningful | Phase 3/6 |
| The flow mirrors hospitality ritual structure | Overall |
| Dwelling language aligns with KOSMOGONIA | Conceptually |

### Tensions

| Tension | Phase | Resolution |
|---------|-------|------------|
| Technical UX language undermines meaning | All | Use dwelling/hospitality vocabulary |
| Bootstrap feels like "loading" | 2 | Frame as emergence/arrival |
| Waiting feels like technical process | 6 | Frame as threshold/anticipation |
| Success messages feel transactional | 9 | Frame as welcome/belonging |

### Recommendations

1. **Vocabulary audit** — Replace technical terms with dwelling terms throughout:
   - "Account" → "Persona"
   - "Workspace" → "Circle"
   - "Join" → "Enter"
   - "Approved" → "Welcomed"

2. **Ceremony matters** — Key moments deserve ceremony:
   - Mnemonic generation (birth of identity)
   - First circle entry (finding belonging)
   - Approval moment (being welcomed)

3. **Threshold experience** — Design the waiting state as meaningful:
   - Invitee standing at door, not "loading"
   - Anticipation, not impatience
   - Being considered, not queued

4. **Transition experience** — The moment of entry should be felt:
   - Visual shift from outside to inside
   - Clear "you now belong" message
   - Immediate presentation of what membership means

5. **Narrative coherence** — The flow tells a story:
   - Invitation extended → Guest arrives → Recognition → Welcome → Belonging
   - Each phase is a chapter, not a step

---

# Lens 6: Federation Sovereignty

This lens examines how circle autonomy is preserved as circles federate through the invitation flow, and what sovereignty implications arise at scale.

## The Sovereignty Question

KOSMOGONIA establishes "Visibility = Reachability" — you can only perceive what you can cryptographically reach through the bond graph. This is the foundation of circle sovereignty: each circle controls its own bond topology.

**Key question:** When circles federate through invitation flows, is sovereignty preserved? Or does federation create dependencies that undermine autonomy?

---

## Sovereignty Principles from KOSMOGONIA

| Principle | KOSMOGONIA Basis | Implication for Federation |
|-----------|------------------|---------------------------|
| **Visibility = Reachability** | "The bond graph IS the access control graph" | Circles control who sees what |
| **Authenticity = Provenance** | "Everything traces back to signed genesis" | Circles verify what they accept |
| **Dwelling Requirement** | "Context is position" | Authority comes from dwelling, not delegation |
| **Composition Requirement** | "Nothing arises raw" | All entities have traceable origin |

---

## Sovereignty Analysis by Phase

### Phase 3: Identity Creation — Individual Sovereignty

**What happens:** User creates persona and home circle.

**Sovereignty established:**
- Mnemonic gives *self-sovereign identity* — no external authority
- Home circle gives *dwelling sovereignty* — you control your space
- Keypair enables *signing authority* — your attestations are yours

**Federation implication:** The inviter is sovereign over their circle before federation begins. They *choose* to extend invitation.

**Sovereignty preserved:** ✅ Individual sovereignty is foundational.

---

### Phase 4: Invitation Creation — Sovereign Grant

**What happens:** Circle sovereign creates invitation link.

**Sovereignty exercised:**
- Only the sovereign (or delegated authority) can create invitations
- The invitation carries *scoped authority* — it grants entry to one circle
- The invitation is *revocable* — sovereign can cancel at any time

**Key insight:** The invitation is a *grant* from the sovereign, not a *right* of the invitee. The circle owner decides:
- Whether to invite at all
- What constraints apply (expiry, single-use, approval required)
- Whether to revoke before use

**Sovereignty preserved:** ✅ Invitation is sovereign act.

---

### Phase 5-7: Transport & Signaling — Infrastructure Neutrality

**What happens:** Link travels through external channels, signaling via relay.

**Sovereignty question:** Does reliance on external infrastructure compromise sovereignty?

**Analysis:**
- Link transport (email, SMS, etc.) is *content-neutral* — link is signed, tampering detectable
- Relay is *explicitly untrusted* — only facilitates signaling, can't read content
- P2P connection bypasses infrastructure after establishment

**Potential sovereignty concerns:**

| Concern | Severity | Mitigation |
|---------|----------|------------|
| Relay operator could block connections | Medium | Future: multiple relay options |
| Relay sees connection metadata | Low | Metadata reveals "who connects when" not "what's shared" |
| Dependence on web infrastructure for landing | Low | Custom protocol fallback possible |

**Sovereignty preserved:** ✅ Infrastructure enables but doesn't control.

---

### Phase 8: Human Verification — Sovereign Decision

**What happens:** Inviter decides whether to approve.

**Sovereignty exercised:**
- The inviter makes the final decision — no automation can approve
- This is *human sovereignty* — the decision cannot be delegated to code
- Rejection is available — sovereignty includes the right to refuse

**Federation implication:** Human verification ensures that federation is always a *conscious choice*. No automatic member injection.

**Sovereignty preserved:** ✅ Human-in-the-loop is sovereignty protection.

---

### Phase 9: Phoreta Exchange — Sovereign Grant Materialized

**What happens:** Membership entities flow from inviter's circle to invitee.

**Sovereignty questions:**

**Q1: What authority does the new member gain?**
- Per Lens 4 (Via Negativa): minimal attainments (perceive only)
- The sovereign decides what additional attainments to grant later
- Entry is not full access — it's *threshold crossing*

**Q2: Can the new member affect the sovereign's circle?**
- With perceive-only: they can see, not modify
- Future attainments (express, invite) require sovereign grant
- No automatic privilege escalation

**Q3: Does the invitee's circle gain any authority over inviter's circle?**
- No. The bond is one-way: invitee member-of inviter's circle
- Invitee's local kosmos cannot modify inviter's entities
- Federation is *additive* not *transitive*

**Sovereignty preserved:** ✅ Membership grant is scoped and controlled.

---

### Phase 10: Ongoing Federation — Sovereignty at Scale

**What happens:** Content synchronizes between circles.

**This is where sovereignty becomes complex:**

**Scenario 1: Simple two-party federation**
```
Circle A ←───member-of───── Persona from A
    │
    └───member-of───── Persona from B (invited)
```
Sovereign A controls Circle A. B has membership but not sovereignty.

**Sovereignty:** ✅ Clear — A is sovereign over Circle A.

---

**Scenario 2: Mutual federation**
```
Circle A                     Circle B
    │                            │
    └── member-of ── Persona B   Persona A ── member-of ──┘
```
A invited B to Circle A. B invited A to Circle B.

**Sovereignty:** ✅ Each remains sovereign over their own circle. Cross-membership doesn't transfer authority.

---

**Scenario 3: Multi-hop federation**
```
Circle A                     Circle B                     Circle C
    │                            │                            │
    └── member-of ── B           └── member-of ── C           │
                                                              │
Can C see content from A? Only if A explicitly shares it.
```

**Sovereignty preserved by:**
- Visibility = Reachability: C cannot see A's content through B
- No transitive access: membership in B doesn't grant sight of A
- Each circle is an independent governance domain

**Sovereignty:** ✅ No unintended visibility leakage.

---

**Scenario 4: Content sync policies**
```
Circle A ─────syncs-with───── Circle B
              │
              └── sync-policy:
                    direction: bidirectional
                    eide_patterns: ["expression"]
                    conflict_strategy: newer_wins
```

**Sovereignty concerns:**

| Concern | Analysis |
|---------|----------|
| Sovereign controls sync policy? | ✅ Yes — syndesmos/create-sync-policy requires sovereign |
| Can sync be one-way? | ✅ Yes — direction: push or pull |
| Can sync be selective? | ✅ Yes — eide_patterns filter what flows |
| Can sync be revoked? | ✅ Yes — link can be suspended |
| Conflict resolution | ⚠️ Tension — whose version wins? |

**Conflict resolution tension:**
- `newer_wins`: Timestamp determines, regardless of origin
- `local_wins`: Sovereignty prioritized over freshness
- `remote_wins`: Deference to remote
- `manual`: Explicit sovereign decision per conflict

**Recommendation:** Default to `local_wins` to preserve sovereignty. Newer_wins should require explicit sovereign consent.

---

**Scenario 5: Governance delegation**
```
Circle A
    │
    └── sovereign-to ── Persona A (original)
    │
    └── has-attainment ── Persona B (invited)
                │
                └── attainment: "invite"
```
B can now invite others to A's circle.

**Sovereignty question:** Has A's sovereignty been diluted?

**Analysis:**
- A *chose* to grant invite attainment to B
- A can *revoke* that attainment at any time
- This is *delegation*, not *transfer*
- A remains sovereign; B has *delegated authority*

**Sovereignty preserved:** ✅ Delegation is not transfer; revocable authority is still sovereignty.

---

## Federation Sovereignty Principles

Based on this analysis, the following principles emerge:

### P1: Sovereignty is Local
Each circle has exactly one sovereign. Federation creates *membership*, not *co-sovereignty*. Joining a circle doesn't make you its sovereign.

### P2: Authority is Granted, Not Inherited
Attainments (permissions) are explicitly granted by sovereigns. Entry grants minimal attainments. Additional authority requires explicit grant.

### P3: Visibility Does Not Propagate Transitively
Being a member of Circle A and seeing Circle A's content does not grant sight of circles that Circle A members also belong to. The bond graph is explicit.

### P4: Sync is Symmetric in Protocol, Not Authority
Two circles can sync, but each sovereign controls what their circle emits and accepts. Sync policy is per-sovereign.

### P5: Delegation is Revocable
A sovereign can grant others the ability to invite, express, or even govern. But this is delegation, not abdication. Revocation is always possible.

### P6: Exit is Sovereign
A member can leave a circle. A sovereign can remove a member. Exit is always possible from either direction. No one is trapped.

---

## Sovereignty Attack Surface

What could undermine circle sovereignty?

| Attack | Vector | Mitigation |
|--------|--------|------------|
| Rogue member gains sovereignty | Exploit in attainment system | Audit attainment grants; no "promote to sovereign" attainment |
| Content leakage via sync | Overly permissive sync policy | Default sync policy is conservative; warn on broad patterns |
| Transitive visibility | Bug in visibility calculation | Visibility = Reachability is structural, not policy-based |
| Sovereign key compromise | Mnemonic theft | This breaks everything; no mitigation except key hygiene |
| Forced sync | Remote circle pushes unwanted content | Import always validates; accept-list policies |
| Invitation spam | Bad actor mass-invites | Rate limiting; reputation systems (future) |

**Highest risk:** Sovereign key compromise. If someone gets your mnemonic, they *are* you. This is fundamental to self-sovereign identity — the sovereign is whoever holds the key.

**Recommendation:** Consider key rotation mechanisms for future. Allow sovereign to issue new keypair while maintaining circle continuity.

---

## Sovereignty at Scale

As the network grows, sovereignty dynamics become more interesting:

### Small Scale (2-10 circles)
- Direct human relationships
- Sovereigns know each other
- Trust is personal

**Sovereignty:** Strong. Everyone knows everyone.

### Medium Scale (10-100 circles)
- Federation graphs emerge
- Some circles specialize (topic-based, project-based)
- Delegation becomes common

**Sovereignty:** Requires attention. Clear policies needed.

### Large Scale (100+ circles)
- Network effects matter
- Power laws emerge (some circles much larger)
- Governance becomes political

**Sovereignty concerns:**
- Large circles may have disproportionate influence
- Coordination across circles requires new patterns
- "Network sovereignty" vs "circle sovereignty" tension emerges

**Future consideration:** Mechanisms for inter-circle coordination that preserve individual circle sovereignty. This is beyond MVP but important for long-term vision.

---

## The Invitation Flow and Sovereignty

Returning to the specific flow under review:

| Phase | Sovereignty Status |
|-------|-------------------|
| 1. Distribution | Pre-sovereignty (world doesn't exist yet) |
| 2. Bootstrap | Local kosmos sovereignty established |
| 3. Identity | Self-sovereign identity established |
| 4. Invitation | Sovereign grant extended |
| 5. Landing | Infrastructure-mediated (neutral) |
| 6. Entry | Sovereignty request made |
| 7. Signaling | Infrastructure-mediated (neutral) |
| 8. Verification | Sovereign decision exercised |
| 9. Phoreta | Sovereign grant materialized |
| 10. Federation | Ongoing sovereign relationship |

**Assessment:** Sovereignty is respected throughout. The flow is fundamentally about one sovereign choosing to extend membership to another, with clear boundaries maintained.

---

## Lens 6 Summary

### Coherences

| Finding | Phase |
|---------|-------|
| Individual sovereignty established before federation | 3 |
| Invitation is sovereign act, not automatic | 4 |
| Human verification preserves human sovereignty | 8 |
| Minimal initial attainments protect circle sovereignty | 9 |
| Visibility = Reachability prevents transitive leakage | All |

### Tensions

| Tension | Phase | Resolution |
|---------|-------|------------|
| Sync conflict resolution (whose version?) | 10 | Default to local_wins; require consent for newer_wins |
| Key compromise = total sovereignty loss | 3 | Future: key rotation mechanisms |
| Large-scale coordination vs circle sovereignty | 10+ | Future: federation governance patterns |

### Recommendations

1. **Default to local_wins** in sync conflict resolution — sovereignty over freshness

2. **Attainment audit trail** — log all attainment grants/revocations for sovereignty review

3. **Explicit sync consent** — changing sync policy should require re-confirmation

4. **Member exit always available** — ensure clean departure path for members

5. **Sovereign exit always available** — circle dissolution should be possible

6. **Key rotation consideration** — design for future key update mechanisms

7. **Document sovereignty model** — users should understand what sovereignty means:
   - You are sovereign over your circles
   - Membership grants view, not control
   - You can revoke what you grant
   - You can exit what you join

### The Sovereignty Promise

The invitation flow maintains a clear sovereignty model:

```
Your circle is YOURS.
- You decide who enters.
- You decide what they can do.
- You decide what leaves and arrives via sync.
- You can revoke membership at any time.
- Your sovereignty rests on your mnemonic.
  (Guard it; it is you.)

When you JOIN a circle:
- You are a guest in another's sovereignty.
- You receive what you're granted.
- You can leave whenever you wish.
- You bring nothing of their circle to yours
  unless explicitly shared.
```

This promise should be visible to users — it's not just technical architecture, it's the social contract of the system

---

---

# Appendix: Ergonomic Questions

*To be revisited during UI implementation. These are not analyzed yet — they are questions to hold.*

## Cognitive Load

- [ ] Is 24 words too many for mnemonic? Should we chunk presentation (6 groups of 4)?
- [ ] How do we verify user actually saved mnemonic without being annoying?
- [ ] What information density is appropriate for each phase?
- [ ] Where does progressive disclosure make sense?

## Action Economy

- [ ] How many taps/clicks from receiving link to membership?
- [ ] Can any steps be combined without losing meaning?
- [ ] What's the inviter's action count to create and share a link?
- [ ] Are there unnecessary confirmations we can remove?

## Error States & Recovery

- [ ] When link validation fails, is the path forward obvious?
- [ ] When video fails, what does the user see and do?
- [ ] When phoreta import fails, how does the user retry?
- [ ] Are error messages actionable or just informative?

## Accessibility

- [ ] How does someone verify via video if they're visually impaired?
- [ ] Audio-only verification — is it sufficient?
- [ ] Screen reader compatibility for key flows?
- [ ] Color contrast, text sizing, motor accessibility?

## Platform Considerations

- [ ] Mobile-first or desktop-first? (Via Negativa says macOS MVP)
- [ ] Touch targets for mobile (if/when we expand)?
- [ ] Landscape vs portrait for video call?
- [ ] Notification patterns for "someone is at the door"?

## Timing & Feedback

- [ ] How long is too long to wait at threshold?
- [ ] Progress indicators — determinate or indeterminate?
- [ ] What feedback confirms each phase completion?
- [ ] Sound/haptic cues for key moments?

## Information Architecture

- [ ] Where does the user land after membership is granted?
- [ ] How do they find their way back to their circles?
- [ ] How is the mnemonic accessible later (backup/export)?
- [ ] Settings vs flow — what's inline, what's hidden?

---

*These questions should be reviewed when concrete UI exists. The phenomenological lens tells us what the experience should mean; ergonomics tells us if it's usable.*

---

## Document History

| Date | Change |
|------|--------|
| 2026-01-23 | Created with Lens 1 (Ontological Coherence) |
| 2026-01-23 | Added Lenses 2-4 (Trust Boundary, Failure Mode, Via Negativa) |
| 2026-01-23 | Completed with Lenses 5-6 (Phenomenological, Federation Sovereignty) |
| 2026-01-23 | Added Appendix: Ergonomic Questions for future UI review |

---

## Summary of All Lenses

| Lens | Key Finding | Primary Recommendation |
|------|-------------|----------------------|
| **1. Ontological** | Co-arising resolves first-mover problem | Document co-arising and dual authenticity |
| **2. Trust Boundary** | Trust chain is complete but has gaps | Add spora hash verification, document entropy |
| **3. Failure Mode** | Phases 7 & 9 are highest risk | Transactional semantics, retry logic, pre-flight checks |
| **4. Via Negativa** | MVP is Phase 9 complete | One platform, fixed defaults, no sync for MVP |
| **5. Phenomenological** | Flow mirrors hospitality ritual | Use dwelling vocabulary, design for ceremony |
| **6. Federation Sovereignty** | Sovereignty preserved throughout | Default local_wins, document sovereignty promise |

---

*Traces to: expression/genesis-root*
