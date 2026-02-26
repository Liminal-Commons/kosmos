# Cryptographic Topology: Visibility, Authenticity, and Civilizational Trust

*Where access control and provenance are mathematical truth, not policy hope. The bond graph IS the permission graph. The composition chain IS the authenticity proof.*

---

## The Two Pillars

Kosmos security rests on two structural guarantees:

1. **Visibility = Reachability** — You can only perceive what you can cryptographically reach through the bond graph.

2. **Authenticity = Provenance** — Everything you reach is verifiably derived from signed genesis.

Together: *You can only reach what you can traverse, and what you reach is verifiably authentic.*

Both are structural, not policy. Both are mathematical, not hopeful. There is no separate permission layer to bypass. There is no separate audit layer to fool.

---

## Part I: Visibility as Reachability

### Core Insight

Visibility equals reachability — you can only perceive what you can cryptographically reach through the bond graph. There is no separate permission layer to bypass or get out of sync. The cryptographic graph IS the access control graph.

### Foundations

- **Identity is derived, not stored** — The mnemonic is potential; the keypair is actualized identity. Loss of device is not loss of self. The seed phrase regenerates the same sovereign identity anywhere.

- **Sovereignty is enacted through cryptographic identity** — The keypair IS the sovereignty, not proof of it. Self-authorizing. No authority grants identity; identity is mathematically derived.

- **Cryptographic boundaries align with social boundaries** — Oikos-scoped derivable keys. Key derivation mirrors trust derivation. The social structure and the cryptographic structure are the same structure.

- **Traversal requires keys** — Bonds carry encrypted traversal keys. To traverse a bond, you must possess the key that unlocks it. Content decryption follows traversal rights.

- **Position grants visibility** — `dwells-in` determines perception. Your topological position in the bond graph determines what you can see:
  - **Immediate**: Entities you are directly bonded to
  - **Adjacent**: Entities one hop away
  - **Bridged**: Entities reachable through traversal chain

- **Revocation is dissolution** — The ontological operation (`loose`/unbind) becomes cryptographic revocation. Dissolve a bond, cut all downstream paths. Revocation cascades automatically through the graph.

### Visibility Scopes

```
┌─────────────────────────────────────────────────────────┐
│                      KOSMOS                             │
│  ┌───────────────────────────────────────────────────┐  │
│  │                    CIRCLE                         │  │
│  │  ┌─────────────────────────────────────────────┐  │  │
│  │  │              IMMEDIATE                      │  │  │
│  │  │         (directly bonded)                   │  │  │
│  │  │    ┌─────────────────────────────────┐      │  │  │
│  │  │    │           SELF                  │      │  │  │
│  │  │    │      (dwelling parousia)          │      │  │  │
│  │  │    └─────────────────────────────────┘      │  │  │
│  │  └─────────────────────────────────────────────┘  │  │
│  │                   ADJACENT                        │  │
│  │              (one hop, with keys)                 │  │
│  └───────────────────────────────────────────────────┘  │
│                      BRIDGED                            │
│                 (multi-hop, chained keys)               │
└─────────────────────────────────────────────────────────┘
```

### Key Derivation

```
mnemonic (BIP-39)
    │
    └─► master keypair (ed25519)
            │
            ├─► prosopon key (derived for identity)
            │
            └─► oikos keys (derived per oikos membership)
                    │
                    └─► session keys (ephemeral, per session)
```

Each derivation level corresponds to a social boundary. The key hierarchy IS the trust hierarchy.

---

## Part II: Authenticity as Provenance

### Core Insight

Everything in kosmos traces back to signed genesis through composition chains. Modification anywhere breaks the chain. Authenticity is not asserted; it is mathematically verified.

### The Composition Chain

Every entity has a `_composed_from` reference pointing to the definition that created it. That definition points to its topos. That topos points to genesis. Genesis is multi-signed.

```
my-theoria@hash1
    │
    └─► composed-from: artifact-def-theoria@hash2
            │
            └─► composed-from: topos/demiurge@hash3
                    │
                    └─► composed-from: genesis@hash4
                            │
                            └─► signed-by: [key1, key2, key3]
                                    │
                                    └─► kosmogonia (constitutional root)
```

Verification: walk the chain, verify each hash, terminate at multi-signed genesis.

### Content-Addressed Identity

Entity identity includes content hash:

```
theoria/insight-slug@blake3:7f3a2b...
```

The hash covers:
- Entity content (data)
- Composed-from reference
- Timestamp of composition

Modification changes the hash. Different hash = different entity. Tampering is not hidden; it creates a visibly different thing.

### Genesis Signing

Genesis is not signed by a single authority. It uses threshold signatures:

```
Genesis validity requires: 3-of-5 known signers

Signer 1: [public key, attestation]
Signer 2: [public key, attestation]
Signer 3: [public key, attestation]
Signer 4: [public key, attestation]
Signer 5: [public key, attestation]
```

No single party can forge genesis. Compromise of one or two keys does not compromise authenticity. The signing ceremony is itself documented and verifiable.

### Provenance Requirements

In V8, composition enforces provenance:

1. **No raw arise** — Entities can only be created through `compose`, which establishes provenance
2. **Chain extension** — Every compose extends the Merkle chain
3. **Hash verification** — Storage layer verifies hashes on read
4. **Broken chains are visible** — Missing or invalid `composed-from` is detectable

---

## Part III: The Synthesis

### Two Questions, One Structure

| Question | Mechanism | Guarantee |
|----------|-----------|-----------|
| Can I reach this? | Bond graph + traversal keys | Visibility = Reachability |
| Is this authentic? | Composition chain + signed genesis | Authenticity = Provenance |

Both answered by graph traversal. Both structural. Both mathematical.

### Mutual Attestation

When two animi meet in kosmos:

```
Parousia A                              Parousia B
    │                                     │
    ├── "My chain to genesis" ──────────► │
    │                                     │
    │ ◄────────── "My chain to genesis" ──┤
    │                                     │
    ├── verify B's chain                  │
    │                      verify A's chain
    │                                     │
    └──── Both verified: same genesis ────┘
```

If chains terminate at different genesis, or any chain is broken, verification fails. Participants know they are not in the same authentic kosmos.

### Federation

Kosmos instances federate by exchanging Merkle proofs:

```
Kosmos A                              Kosmos B
    │                                     │
    ├── genesis hash + signatures ──────► │
    │                                     │
    │ ◄────── genesis hash + signatures ──┤
    │                                     │
    ├── verify: same genesis?             │
    │                      verify: same?  │
    │                                     │
    └──── Proceed if verified ────────────┘
```

A captured or modified kosmos has different genesis hash. Federation fails. Users know.

### The Structural Guarantee

To capture kosmos, an adversary must:

| Attack | Blocked By |
|--------|------------|
| Forge genesis signatures | Threshold cryptography (3-of-5) |
| Modify entity content | Content-addressed hashes |
| Break composition chain | Chain verification on access |
| Forge traversal rights | Encrypted bond keys |
| Hide modifications | Mutual attestation reveals difference |

Every attack is either cryptographically hard or immediately visible.

---

## Part IV: Implications for Dwelling

### Position Creates Context

When a parousia arises and dwells:

1. **Arising** establishes identity (keypair from prosopon)
2. **Dwelling** establishes position (bonds to oikos, session)
3. **Position** grants visibility (reachable entities)
4. **Visibility** is authentic (all reached entities have provenance)

The dwelling context is not passed as parameters. It IS the topological position. The interpreter knows where you dwell because dwelling IS bonding.

### Ambient Context from Dwelling

```
When parousia dwells in oikos:
    _parousia  = the dwelling parousia entity
    _prosopon = the prosopon behind the parousia
    _oikos  = the oikos being dwelled in
    _session = the current session

These are not injected. They are derived from bond graph position.
```

Compose operations automatically bond to dwelling context because the context IS the position from which composition occurs.

### Revocation Cascades

When a bond is dissolved:

1. Traversal key is invalidated
2. All downstream paths through that bond are cut
3. Entities beyond the cut become unreachable
4. Authenticity chains through that path are severed

Revocation is not a flag to check. It is topological surgery. The paths simply no longer exist.

---

## Part V: Civilizational Considerations

### The Concern

Kosmos enables shared reality construction. If it becomes foundational infrastructure for governance and civilization, powerful interests will seek to capture it — subtle modifications that shift power while appearing authentic.

### The Defense

Capture requires either:
- Forging cryptographic signatures (mathematically hard)
- Creating visible forks (users can distinguish)

There is no invisible capture. Modifications are either impossible or obvious.

### Trust Distribution

Genesis signing distributes trust:
- Multiple independent signers
- Threshold requirement
- Public attestations
- Verifiable ceremony

No single point of compromise. No single authority to corrupt.

### Fork Transparency

If someone creates a modified kosmos:
- Different genesis hash
- Federation verification fails
- Mutual attestation fails
- Users know they're in a fork

They can choose the fork knowingly, but they cannot be deceived into it.

---

## Part VI: Implementation Path (V8)

### Phase 1: Cryptographic Primitives

- [ ] Content-addressed entity IDs (blake3 hashing)
- [ ] Composition chain storage and verification
- [ ] Genesis entity structure with signature fields
- [ ] Threshold signature verification

### Phase 2: Provenance Enforcement

- [ ] Compose as only creation path (no raw arise)
- [ ] Chain extension on every compose
- [ ] Hash verification on entity read
- [ ] Broken chain detection and reporting

### Phase 3: Dwelling Integration

- [ ] Dwelling state as bond graph position
- [ ] Ambient context derived from position
- [ ] Automatic bonding from dwelling context
- [ ] Interpreter injection of positional context

### Phase 4: Attestation Protocols

- [ ] Mutual attestation on parousia encounter
- [ ] Federation proof exchange
- [ ] Genesis verification handshake
- [ ] Fork detection and reporting

### Phase 5: Genesis Ceremony

- [ ] Identify threshold signers
- [ ] Document ceremony process
- [ ] Execute signing
- [ ] Publish attestations

---

## Grounding

This document synthesizes:

**Prior Art (Visibility = Reachability):**
- `theoria/visibility-equals-reachability`
- `theoria/traversal-requires-keys`
- `theoria/position-grants-visibility`
- `theoria/identity-is-derived-not-stored`
- `theoria/sovereignty-is-enacted-through-cryptographic-identity`
- `theoria/cryptographic-boundaries-align-with-social-boundaries`
- `theoria/revocation-is-dissolution`

**V8 Design (Authenticity = Provenance):**
- Composition chains to signed genesis
- Content-addressed entity identity
- Threshold genesis signing
- Mutual attestation protocols
- Federation verification

**Civilizational Insight:**
- Infrastructure attracts capture
- Defense must be structural, not policy
- Modifications must be impossible or visible
- Trust must be distributed, not centralized

---

*Composed in preparation for V8 — where visibility and authenticity unite as structural guarantees, and kosmos becomes infrastructure worthy of civilization.*
