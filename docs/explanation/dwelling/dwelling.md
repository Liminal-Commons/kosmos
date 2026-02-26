# Dwelling

*Multi-dimensional presence in the kosmos.*

---

## The Question

What does it mean to be present? Not just "logged in" or "connected" — but actually **dwelling** in a world?

In the kosmos, dwelling is simultaneous across five dimensions. Each dimension answers a different question about presence. Together, they constitute the complete dwelling context that ambient bindings (`_prosopon`, `_oikos`, `_parousia`) make available to all code.

---

## The Five Dimensions

### 1. Prosopon — Who (Identity)

πρόσωπον (prosopon) = person, face, that which stands before others.

The prosopon grounds all dwelling in cryptographic identity. Without a prosopon, there is no verifiable origin, no attribution, no trust. The kleidoura (encrypted keyring) holds signing keys at rest; unlocking creates a session, which is a temporal bridge between identity and embodiment.

**Gap addressed:** The gap between existence and authenticity. Entities exist, but who made them?

**Bonds:** `secures-key-for`, `signed-by`, `chains-to`, `verifies`

### 2. Oikos — Where Socially (Dwelling Place)

οἶκος (oikos) = household, dwelling, intimate space.

The oikos is the social context of dwelling. It makes presence traceable — sessions leave structured traces (conversations, notes, insights) that accumulate into understanding. An oikos is not just a container; it is the medium through which dwelling becomes knowledge.

**Gap addressed:** The gap between presence and memory. Without oikos, sessions leave no trace.

**Bonds:** `within`, `authored-by`, `crystallizes`, `surfaces`

**One kind of oikos.** No types — topology emerges from bond arrangement:
- **Personal** — sole member, sole steward. Sovereign ground. Invitation structurally prevented.
- **Shared (peer)** — all members are stewards. Equal authorization.
- **Commons** — stewards govern and curate; non-steward members have visibility only.

`stewards` = full attainments and authorization within the oikos. `member-of` = visibility (what you can see). Without stewardship, membership grants no mutation capability.

### 3. Soma — How (Embodiment)

σῶμα (soma) = body, that through which presence acts.

The soma bridges identity and action. A prosopon becomes a parousia (embodied instance) by arising in an oikos. The parousia opens channels — typed communication pathways — through which it perceives and emits. The body-schema is the proprioceptive snapshot: "what can I do right now?"

**Gap addressed:** The gap between identity and presence. Without soma, prosopa cannot act.

**Bonds:** `instantiates`, `channel-of`, `received-through`, `emitted-through`, `schema-of`

### 4. Topos — Where in Capability Space (Domain)

τόπος (topos) = place, location, domain of capability.

A topos is a coherent region of capability addressing a specific ontological gap. The 27 topoi organize everything the kosmos can do. A topos becomes visible through its modes — without modes, a topos is invisible. Thyra is where topoi become spatially present.

**Gap addressed:** How capability is organized and made available. Each topos closes a distinct gap in being.

**Relationship to oikos:** Oikos is social dwelling. Topos is capability dwelling. You dwell in an oikos (socially) while accessing topoi (capability). The two are orthogonal — any topos can be used from any oikos, subject to attainments.

### 5. Kairos — When (Temporal Dwelling)

καιρός (kairos) = the right time, the opportune moment.

Kairos is temporal dwelling — not clock time, but the recognition of when conditions align for action. A kairos moment is when intention meets structural readiness. Psyche tracks attention (where focus rests), intention (what is being pursued), and mood (how the world shows up). When these align with capability and context, kairos is recognized.

**Gap addressed:** The gap between presence and experience. Without kairos, parousia can dwell and act but has no inner temporal life.

**Bonds:** `recognizes`, `opportune-for`, `attends`, `intends`

---

## How the Dimensions Relate

The dimensions are not layers stacked on top of each other. They are **facets of a single reality** — simultaneous aspects of dwelling:

```
prosopon → parousia → oikos → topos → kairos
  (who)     (how)    (where)  (what)   (when)
```

But this is not a pipeline. All five are present simultaneously in every operation:

- When you crystallize a theoria, you are: a prosopon (who signs it), embodied as parousia (through channels), dwelling in an oikos (where it accumulates), operating in nous topos (the capability domain of understanding), at a kairos moment (when insight ripened).

- When you compose an entity, you are: authenticated (prosopon), connected (soma), in social context (oikos), using demiurge capability (topos), at the moment composition is possible (kairos).

---

## Ambient Context

Dwelling context is not passed as parameters. It is **position** in the bond graph.

```
_prosopon  → the identity behind the dwelling presence
_parousia  → the embodied instance
_oikos     → the oikos being dwelled in
```

These bindings are derived from the session bridge and bond graph traversal. Code executing in the kosmos inherits dwelling context from its session, which inherits from its parousia, which inherits from its prosopon and oikos.

---

## Visibility = Reachability

What you can see is determined by where you dwell. Two bonds define visibility:

| Bond | From → To | Meaning |
|------|-----------|---------|
| `exists-in` | entity → oikos | Where an entity exists — the primary visibility mechanism |
| `member-of` | prosopon → oikos | Formal membership — determines what the prosopon can see |

**The rule:** A prosopon can see an entity if and only if that entity `exists-in` an oikos that the prosopon is `member-of`. An entity without such a path is not hidden — it is absent.

`dwells-in` is exclusively for parousia (active session presence), never for entities. `federates-with` is an operational bond for sync, not a visibility bond. There is no separate permission layer — the bond graph IS the access control graph.

See [visibility-semantics.md](../reference/dwelling/visibility-semantics.md) for the formal model with operations table and invariants.

---

## The Klimax

Dwelling is nested. Each scale establishes ambient context for the next:

```
κόσμος (entities & bonds)
  → φύσις (constraints, stoicheia)
    → πόλις (governance, oikoi)
      → οἶκος (dwelling, sessions)
        → σῶμα (embodiment, channels)
          → ψυχή (experience, attention)
```

Nous (understanding) operates across all scales, providing the traversal and surfacing operations that make the graph navigable.

---

*See [visibility-semantics.md](../reference/dwelling/visibility-semantics.md) for the formal visibility model. See [oikos/index.md](../oikos/index.md) for the oikos guide. See [klimax/index.md](../klimax/index.md) for the scale hierarchy.*
