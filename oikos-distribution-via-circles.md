# Oikos Distribution via Circles

*The app is ground. Circles are world.*

---

## Context

Currently, all genesis oikoi are baked into Thyra. The chora repo symlinks to kosmos/genesis, and the full kosmos ships with every app release.

This creates friction:
- New oikos = new app release = app store review = user updates
- Everyone has the same global version (no experimentation)
- The app store becomes a gatekeeper for capability evolution

This proposal inverts the model: **Thyra becomes a minimal substrate, and oikoi are distributed through circles.**

---

## The Vision

### Before (Current)

```
kosmos/genesis ──symlink──> chora/genesis ──build──> Thyra
                                                      │
                                                      v
                                               User installs
                                               (has everything)
```

### After (Proposed)

```
Thyra (minimal substrate)
    │
    ├── Built-in: interpreter, arche, propylon, hypostasis, minimal politeia
    │
    └── Everything else: distributed through circles

User installs Thyra (bare)
    │
    v
User receives invitation link
    │
    v
User joins circle (e.g., kosmos-commons)
    │
    v
Circle's oikoi automatically install
    │
    v
User has capabilities
```

---

## Minimal Substrate

What must be built into Thyra (unlikely to change, required before joining any circle):

| Component | Purpose | Why Built-in |
|-----------|---------|--------------|
| **Interpreter** | Executes praxeis | Rust code, can't be distributed as content |
| **Arche** | Grammar (eidos, desmos, stoicheion) | Interpreter requires these definitions |
| **Propylon** | Entry via links | Must accept invitations before joining circles |
| **Hypostasis (core)** | Keys, signatures, mnemonic | Identity must exist before membership |
| **Politeia (minimal)** | Circle join, membership, dwell | Must join circles to receive oikoi |

Everything else moves to circle distribution:
- nous (mind, theoria)
- soma (body, channels)
- thyra (portal, streams, UI)
- agora (spatial presence)
- demiurge (composition)
- manteia (inference)
- psyche (attention, intention)
- aither (WebRTC)
- dynamis (releases)
- dokimasia (validation)
- ergon (work coordination)

---

## Circle Kinds (Simplified)

| Kind | Purpose | Can Distribute? |
|------|---------|-----------------|
| **self** | Individual dwelling | No |
| **peer** | Collaborative creation | No — must create commons to share |
| **commons** | Distribution | Yes — grants oikoi + attainments |

**Public disappears** — a commons with open invitation (`max_uses: unlimited`).

**Peer cannot distribute externally** — enforces intentionality about sharing. To distribute, peers must collectively create a commons circle.

---

## Distribution Mechanism

### Circle Distributes Oikoi

```yaml
circle/kosmos-commons
  kind: commons
  distributes:
    - oikos-prod/nous-1.2.0
    - oikos-prod/soma-1.1.0
    - oikos-prod/thyra-1.0.0
    - oikos-prod/agora-0.9.0
```

The `distributes` bond connects a circle to oikos-prod entities.

### On-Join: Oikoi Install Automatically

When user joins a circle:

```
1. Trace: circle --distributes--> oikos-prod/*
2. For each oikos-prod not already installed:
   - Fetch oikos content (phoreta or direct)
   - Verify signature
   - Install locally
3. Derive attainments from circle membership
4. User can now use praxeis from those oikoi
```

### Auto-Update: Circle Changes, Members Receive

When circle updates its `distributes` bonds:

```
Before: circle --distributes--> oikos-prod/nous-1.2.0
After:  circle --distributes--> oikos-prod/nous-1.3.0
```

Members automatically receive the update:
- **Eager**: Update immediately when circle changes
- **Lazy**: Update when user next dwells in that circle
- **Prompted**: Notify user, let them accept

Recommendation: **Lazy** — update on dwell. Avoids unexpected changes while user is working in a different context.

---

## Versioning: Dwelling Context Resolves

If user is member of multiple circles with different oikos versions:

```
User is member of:
  - kosmos-commons (nous v1.3.0)
  - peer/experimental (nous v2.0.0-beta)

When dwelling in kosmos-commons → nous v1.3.0 active
When dwelling in experimental → nous v2.0.0-beta active
```

**No global conflict.** The dwelling context determines active versions.

Benefits:
- Experiment safely in one circle without breaking another
- Circles have sovereignty over their versions
- Rollback is trivial (circle changes its bond)

---

## First-Run Experience

1. User installs Thyra (bare substrate)
2. Thyra can do almost nothing — only receive links
3. User gets invitation link (from friend, QR code, website)
4. User clicks link → video verification with inviter
5. User joins circle (e.g., kosmos-commons)
6. Circle's oikoi install automatically
7. User now has capabilities

**Social entry by design.** You cannot use kosmos without someone inviting you. This is intentional:
- Ensures human connection precedes capability
- No anonymous exploration (until you're invited to a public commons)
- Aligns with "visibility = reachability" principle

---

## The Kosmos Commons

A primary distribution circle for the core kosmos experience:

```yaml
circle/kosmos-commons
  kind: commons
  invitation: open (unlimited uses)
  distributes:
    - oikos-prod/nous-1.0.0
    - oikos-prod/soma-1.0.0
    - oikos-prod/thyra-1.0.0
    - oikos-prod/agora-1.0.0
    - oikos-prod/demiurge-1.0.0
    - oikos-prod/manteia-1.0.0
    - oikos-prod/psyche-1.0.0
    - oikos-prod/aither-1.0.0
    - oikos-prod/dynamis-1.0.0
    - oikos-prod/dokimasia-1.0.0
    - oikos-prod/ergon-1.0.0
  grants-attainment:
    - attainment/compose
    - attainment/express
    - attainment/invoke
```

Anyone can join kosmos-commons (open invitation). Joining grants you the full kosmos capability set.

Other circles can distribute subsets or different versions:
- `commons/agora-beta` — experimental agora features
- `commons/nous-minimal` — just theoria, no journeys
- `peer/our-project` — creates `commons/our-project-release` to share

---

## Implementation Pathway

### Phase 1: Define Minimal Substrate

1. Identify exact boundary of built-in vs. distributed
2. Document in chora: what ships with Thyra
3. Create substrate manifest listing built-in components

### Phase 2: Oikos-on-Join Mechanism

1. Add praxis: `politeia/sync-circle-oikoi`
2. Integrate into `propylon/verify-entry` or `politeia/accept-invitation`
3. On join: trace `distributes` bonds, install missing oikoi

### Phase 3: Auto-Update Reconciler

1. Add reconciler for `uses-oikos` bonds
2. On dwell: check circle's current oikos versions
3. Update locally if circle has newer version
4. Optionally notify user of updates

### Phase 4: Create Kosmos Commons

1. Package all genesis oikoi as oikos-prod
2. Create `circle/kosmos-commons`
3. Add `distributes` bonds for all oikoi
4. Create open invitation link
5. Publish link (website, documentation, QR codes)

### Phase 5: Migrate Thyra

1. Remove genesis oikoi from Thyra build
2. Keep only minimal substrate
3. Test first-run experience with bare Thyra
4. Validate oikos-on-join flow

---

## Open Questions

1. **Exact minimal boundary** — Is "minimal politeia" sufficient, or do we need more to bootstrap the oikos-install flow?

2. **Update trigger** — Eager, lazy (on-dwell), or prompted? Recommendation: lazy.

3. **Offline first-run** — What happens if user has no network? (Answer: they wait until they have connectivity and a link.)

4. **Oikos dependencies** — If oikos A depends on oikos B, how is this expressed and resolved?

5. **Signature verification** — How does bare Thyra verify oikos-prod signatures without already having the signing circle's pubkey?

---

## Theoria

**T28: The app is ground, circles are world**

Thyra provides stable infrastructure — the interpreter, entry mechanism, and identity substrate. Everything that makes kosmos *useful* — the capabilities, the affordances, the praxeis — flows through circles. This means the app rarely needs updating. Capability evolution happens peer-to-peer, through circle distribution, outside app store control.

**T29: Distribution = membership**

You get oikoi by joining circles. This unifies the access model (attainments) with the distribution model (oikoi). The same mechanism that grants you capabilities also delivers you the code to exercise them.

**T30: Social entry is a feature, not a bug**

Requiring invitation before capability is intentional. It ensures human connection precedes tool access. You cannot wield kosmos alone — you must be invited by someone who already dwells there. This aligns with the vision of kosmos as a social fabric, not just a tool.

---

*Drafted 2026-01-28 — from conversation about oikos distribution and circle-based capability*
