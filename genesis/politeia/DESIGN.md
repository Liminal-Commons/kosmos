# Politeia: Governance & Capability

*Phase 19 — how circles govern and grant capabilities.*

---

## The Vision

Phase 18 gave us **syndesmos** — circles can connect. Phase 19 gives circles *meaning*:

- **Circles** as governance units (sovereign to animuses)
- **Attainments** as capabilities (granted by circle membership)
- **Affordances** as action surfaces (how attainments manifest)
- **Animus** as dwelling presence (who acts)

This is the layer where "being in a circle" translates to "being able to do things."

---

## Implementation Status

| Component | Status | Location |
|-----------|--------|----------|
| `animus` eidos | **Complete** | `spora/spora.yaml` |
| `attainment` eidos | **Complete** | `spora/spora.yaml` |
| `affordance` eidos | **Complete** | `spora/spora.yaml` |
| `hud-region` eidos | **Complete** | `spora/spora.yaml` |
| `invitation` eidos | **Complete** | `spora/spora.yaml` |
| Politeia desmoi | **Complete** | `spora/spora.yaml` |
| Circle praxeis | **Complete** | `genesis/politeia/praxeis/politeia.yaml` |
| Attainment praxeis | **Complete** | `genesis/politeia/praxeis/politeia.yaml` |
| Affordance praxeis | **Complete** | `genesis/politeia/praxeis/politeia.yaml` |
| Bootstrap | **Complete** | `spora/spora.yaml` (stage-3-politeia) |

**Phase 19 complete** (2026-01-20): All eide, desmoi, praxeis, and bootstrap implemented in YAML.

---

## The Cosmological Foundation

> politeia (politeia) — the constitution, how citizens participate in governance.

The klimax builds from container toward contained:

```
POLIS (governance)
│   circles, membership, attainments
│
├── circle/kosmos         ← Foundation circle
│       sovereign-to → animus/genesis
│       grants-attainment → attainment/compose-*
│
├── circle/chora-dev      ← Development circle
│       sovereign-to → animus/victor
│       federated-with → circle/kosmos (via syndesmos-link)
│
└── circle/vibe-cafe      ← Commons circle
        sovereign-to → [animus/victor, animus/guest1, ...]

OIKOS (intimacy)
│   attainments, affordances
│
├── attainment/compose-theoria
│       surfaces-as → affordance/compose-theoria-action
│
└── affordance/compose-theoria-action
        renders-in → hud-region/main

SOMA (embodiment)
│   HUD regions, rendering
│
└── hud-region/main
        position: {x: 0, y: 0, w: 100%, h: 100%}
        layout: grid
```

---

## Core Eide

### 1. Animus

The dwelling presence — who acts within the kosmos.

```yaml
eidos/animus:
  name: animus
  description: |
    ψυχή (animus) — the dwelling presence.

    An animus embodies a persona within the kosmos. While persona is identity
    (persistent, can have multiple), animus is presence (the active dweller).

    One persona can have multiple simultaneous animi (dwelling in different
    substrates or circles). The animus is session-scoped; the persona persists.
  fields:
    name:
      type: string
      required: true
    description:
      type: string
      required: false
    persona_id:
      type: string
      required: true
      description: "The identity this animus embodies"
    substrate_id:
      type: string
      required: false
      description: "Where this animus is actualized (if substrate-bound)"
    status:
      type: enum
      values: [dwelling, away, suspended]
      required: true
      default: dwelling
    created_at:
      type: timestamp
      required: true
    last_active_at:
      type: timestamp
      required: false
```

**Relationships via desmoi:**
- `dwells-in` → circle (current position)
- `member-of` → circle (membership, may include circles not currently dwelling in)
- `has-attainment` → attainment (granted capabilities)
- `embodies` → persona (identity relationship)

### 2. Attainment

A capability granted by circle membership.

```yaml
eidos/attainment:
  name: attainment
  description: |
    A capability granted by circle membership.

    Attainments flow from circles to animuses via membership. When you join
    a circle, you receive its attainments. Attainments surface as affordances
    in the HUD.

    The capability field patterns what actions this attainment enables:
    - "compose:theoria" — can compose theoria
    - "invoke:manteia/*" — can invoke any manteia praxis
    - "admin:circle" — can administer the granting circle
  fields:
    name:
      type: string
      required: true
    description:
      type: string
      required: false
    capability:
      type: string
      required: true
      description: "Action pattern this enables (e.g., 'compose:theoria', 'invoke:nous/*')"
    tier:
      type: number
      required: false
      description: "Stoicheion tier required (if capability involves praxis invocation)"
    conditions:
      type: object
      required: false
      description: "Additional conditions for this attainment"
    created_at:
      type: timestamp
      required: true
```

**Relationships via desmoi:**
- `granted-by` → circle (which circle grants this)
- `surfaces-as` → affordance (how it manifests for action)

### 3. Affordance

How an attainment surfaces for action.

```yaml
eidos/affordance:
  name: affordance
  description: |
    An action surface — how an attainment manifests for use.

    Affordances are the visible/invocable actions in the HUD. Each affordance
    is enabled by an attainment and renders in a HUD region.

    Surface types:
    - hud: Visual button/action in the interface
    - voice: Voice-invocable command
    - text: Text command (slash command, etc.)
    - api: Programmatic invocation only
  fields:
    name:
      type: string
      required: true
    description:
      type: string
      required: false
    action:
      type: string
      required: true
      description: "Praxis ID to invoke when activated"
    surface:
      type: enum
      values: [hud, voice, text, api]
      required: true
      default: hud
    icon:
      type: string
      required: false
      description: "Icon identifier for visual rendering"
    shortcut:
      type: string
      required: false
      description: "Keyboard shortcut if applicable"
    created_at:
      type: timestamp
      required: true
```

**Relationships via desmoi:**
- `enabled-by` → attainment (what capability enables this)
- `renders-in` → hud-region (where it appears)

### 4. HUD Region

A display area for affordances.

```yaml
eidos/hud-region:
  name: hud-region
  description: |
    A display region in the HUD (heads-up display).

    HUD regions organize affordances spatially. Regions can nest
    (child-of relationship) to create hierarchical layouts.

    The HUD is entity-driven: traverse affordance → renders-in → region
    to build the display tree.
  fields:
    name:
      type: string
      required: true
    description:
      type: string
      required: false
    position:
      type: object
      required: true
      description: "{x, y, width, height} or named position like 'top-right'"
    layout:
      type: enum
      values: [grid, stack, flow, fixed]
      required: true
      default: stack
    visible:
      type: boolean
      required: true
      default: true
    created_at:
      type: timestamp
      required: true
```

**Relationships via desmoi:**
- `child-of` → hud-region (nesting)
- (reverse: `contains` ← affordance via renders-in)

### 5. Invitation

An invitation to join a circle.

```yaml
eidos/invitation:
  name: invitation
  description: |
    An invitation to join a circle.

    Invitations flow from one circle to another (or to a pubkey directly).
    They carry the inviter's attestation and can include a message.

    Lifecycle: pending → accepted | declined | expired
  fields:
    from_circle_id:
      type: string
      required: true
      description: "Circle extending the invitation"
    to_circle_id:
      type: string
      required: false
      description: "Target circle (if inviting a circle)"
    invitee_pubkey:
      type: string
      required: false
      description: "Target pubkey (if inviting an individual)"
    inviter_animus_id:
      type: string
      required: true
      description: "Animus who created the invitation"
    message:
      type: string
      required: false
    status:
      type: enum
      values: [pending, accepted, declined, expired]
      required: true
      default: pending
    expires_at:
      type: timestamp
      required: false
    created_at:
      type: timestamp
      required: true
    responded_at:
      type: timestamp
      required: false
```

---

## Core Desmoi

### Governance Bonds

```yaml
desmos/sovereign-to:
  name: sovereign-to
  description: "Circle is sovereign to animus (governance relationship)"
  symmetric: false
  # from: circle, to: animus

desmos/member-of:
  name: member-of
  description: "Animus is member of circle"
  symmetric: false
  # from: animus, to: circle

desmos/dwells-in:
  name: dwells-in
  description: "Animus currently dwells in circle (active position)"
  symmetric: false
  # from: animus, to: circle

desmos/embodies:
  name: embodies
  description: "Animus embodies persona (identity relationship)"
  symmetric: false
  # from: animus, to: persona
```

### Capability Bonds

```yaml
desmos/grants-attainment:
  name: grants-attainment
  description: "Circle grants attainment to members"
  symmetric: false
  # from: circle, to: attainment

desmos/has-attainment:
  name: has-attainment
  description: "Animus has attainment (derived from membership)"
  symmetric: false
  # from: animus, to: attainment

desmos/granted-by:
  name: granted-by
  description: "Attainment granted by circle (inverse of grants-attainment)"
  symmetric: false
  # from: attainment, to: circle
```

### Surface Bonds

```yaml
desmos/surfaces-as:
  name: surfaces-as
  description: "Attainment surfaces as affordance"
  symmetric: false
  # from: attainment, to: affordance

desmos/enabled-by:
  name: enabled-by
  description: "Affordance enabled by attainment (inverse of surfaces-as)"
  symmetric: false
  # from: affordance, to: attainment

desmos/renders-in:
  name: renders-in
  description: "Affordance renders in HUD region"
  symmetric: false
  # from: affordance, to: hud-region
```

### Structure Bonds

```yaml
desmos/child-of:
  name: child-of
  description: "HUD region is child of another region (nesting)"
  symmetric: false
  # from: hud-region, to: hud-region

desmos/invited-to:
  name: invited-to
  description: "Invitation targets circle or pubkey"
  symmetric: false
  # from: invitation, to: circle (or implicit via invitee_pubkey)
```

---

## Key Praxeis

### Circle Operations

```yaml
praxis/politeia/create-circle:
  description: |
    Create a new circle with the caller as sovereign.
  params:
    name: string (required)
    description: string (optional)
    federation_policy: enum [open, invite_only, closed] (optional, default: invite_only)
  returns:
    circle: entity
    circle_id: string
  # Creates circle, bonds sovereign-to → caller's animus

praxis/politeia/invite-to-circle:
  description: |
    Invite someone to join a circle.
  params:
    circle_id: string (required)
    invitee_pubkey: string (required)
    message: string (optional)
    expires_in_days: number (optional, default: 7)
  returns:
    invitation: entity
    invitation_id: string
  # Creates invitation entity

praxis/politeia/accept-invitation:
  description: |
    Accept an invitation to join a circle.
  params:
    invitation_id: string (required)
  returns:
    membership: bond (member-of)
    attainments: array
  # Creates member-of bond, derives attainments, updates invitation status

praxis/politeia/decline-invitation:
  description: |
    Decline an invitation.
  params:
    invitation_id: string (required)
  returns:
    invitation: entity
  # Updates invitation status to declined

praxis/politeia/dwell-in-circle:
  description: |
    Move dwelling position to a circle.
    Animus can only dwell in one circle at a time.
  params:
    circle_id: string (required)
  returns:
    success: boolean
    previous_circle_id: string (if any)
  # Updates dwells-in bond

praxis/politeia/leave-circle:
  description: |
    Leave a circle (remove membership).
  params:
    circle_id: string (required)
  returns:
    success: boolean
  # Removes member-of bond, clears derived attainments

praxis/politeia/list-circles:
  description: |
    List circles the animus is member of or can see.
  params:
    membership_only: boolean (optional, default: false)
  returns:
    circles: array
```

### Attainment Operations

```yaml
praxis/politeia/create-attainment:
  description: |
    Create a new attainment that a circle can grant.
  params:
    name: string (required)
    description: string (optional)
    capability: string (required)
    tier: number (optional)
    conditions: object (optional)
  returns:
    attainment: entity
    attainment_id: string

praxis/politeia/grant-attainment:
  description: |
    Grant an attainment from a circle (circle must be sovereign to caller).
  params:
    circle_id: string (required)
    attainment_id: string (required)
  returns:
    bond: grants-attainment bond

praxis/politeia/revoke-attainment:
  description: |
    Revoke an attainment grant from a circle.
  params:
    circle_id: string (required)
    attainment_id: string (required)
  returns:
    success: boolean

praxis/politeia/derive-attainments:
  description: |
    Derive attainments for an animus based on circle memberships.
    Traverses: animus → member-of → circle → grants-attainment → attainment
    Creates has-attainment bonds.
  params:
    animus_id: string (optional, defaults to caller)
  returns:
    attainments: array
    bonds_created: number

praxis/politeia/list-attainments:
  description: |
    List attainments for an animus or circle.
  params:
    animus_id: string (optional)
    circle_id: string (optional)
  returns:
    attainments: array
```

### Affordance Operations

```yaml
praxis/politeia/create-affordance:
  description: |
    Create an affordance that surfaces an attainment.
  params:
    name: string (required)
    description: string (optional)
    action: string (required) — praxis ID
    surface: enum [hud, voice, text, api] (optional, default: hud)
    icon: string (optional)
    shortcut: string (optional)
    attainment_id: string (required) — what enables this
    region_id: string (optional) — where it renders
  returns:
    affordance: entity
    affordance_id: string

praxis/politeia/gather-affordances:
  description: |
    Gather all affordances available to an animus.
    Traverses: animus → has-attainment → attainment → surfaces-as → affordance
  params:
    surface: enum (optional) — filter by surface type
  returns:
    affordances: array

praxis/politeia/render-hud:
  description: |
    Build the HUD render tree for an animus.
    Groups affordances by region, returns nested structure.
  returns:
    regions: array — nested structure with affordances
    # [{ region: {...}, affordances: [...], children: [...] }]

praxis/politeia/invoke-affordance:
  description: |
    Invoke an affordance (execute its action praxis).
  params:
    affordance_id: string (required)
    params: object (optional) — params for the action praxis
  returns:
    result: any — result from the action praxis
```

### HUD Operations

```yaml
praxis/politeia/create-hud-region:
  description: |
    Create a HUD region.
  params:
    name: string (required)
    description: string (optional)
    position: object (required) — {x, y, width, height} or named
    layout: enum [grid, stack, flow, fixed] (optional, default: stack)
    parent_region_id: string (optional) — for nesting
  returns:
    region: entity
    region_id: string

praxis/politeia/list-hud-regions:
  description: |
    List HUD regions, optionally as tree.
  params:
    as_tree: boolean (optional, default: false)
  returns:
    regions: array
```

---

## Implementation Phases

### Phase 19.1: Core Eide and Desmoi

Add to `spora.yaml`:

1. **Animus eidos** with fields: name, description, persona_id, substrate_id, status, created_at, last_active_at
2. **Attainment eidos** with fields: name, description, capability, tier, conditions, created_at
3. **Affordance eidos** with fields: name, description, action, surface, icon, shortcut, created_at
4. **HUD-region eidos** with fields: name, description, position, layout, visible, created_at
5. **Invitation eidos** with fields: from_circle_id, to_circle_id, invitee_pubkey, inviter_animus_id, message, status, expires_at, created_at, responded_at

6. **Governance desmoi**: sovereign-to, member-of, dwells-in, embodies
7. **Capability desmoi**: grants-attainment, has-attainment, granted-by
8. **Surface desmoi**: surfaces-as, enabled-by, renders-in
9. **Structure desmoi**: child-of, invited-to

### Phase 19.2: Circle Praxeis

Create `spora/praxeis/politeia.yaml`:

1. `create-circle` — Create circle with caller as sovereign
2. `invite-to-circle` — Create invitation
3. `accept-invitation` — Accept, create membership, derive attainments
4. `decline-invitation` — Decline invitation
5. `dwell-in-circle` — Move dwelling position
6. `leave-circle` — Remove membership
7. `list-circles` — List circles

### Phase 19.3: Attainment Praxeis

Add to `spora/praxeis/politeia.yaml`:

1. `create-attainment` — Create attainment
2. `grant-attainment` — Circle grants attainment
3. `revoke-attainment` — Circle revokes attainment
4. `derive-attainments` — Traverse graph, create has-attainment bonds
5. `list-attainments` — List attainments

### Phase 19.4: Affordance & HUD Praxeis

Add to `spora/praxeis/politeia.yaml`:

1. `create-affordance` — Create affordance from attainment
2. `gather-affordances` — Gather available affordances for animus
3. `render-hud` — Build render tree
4. `invoke-affordance` — Execute action
5. `create-hud-region` — Create region
6. `list-hud-regions` — List regions

### Phase 19.5: Bootstrap

Update `spora.yaml` bootstrap stages:

1. Create `circle/kosmos` with foundation attainments
2. Create `animus/genesis` as initial sovereign of kosmos
3. Create foundation attainments:
   - `attainment/compose-theoria`
   - `attainment/compose-principle`
   - `attainment/compose-pattern`
   - `attainment/invoke-nous`
   - `attainment/invoke-demiurge`
4. Create foundation affordances with renders-in → hud-region/main
5. Create default HUD regions:
   - `hud-region/main`
   - `hud-region/sidebar`
   - `hud-region/toolbar`

---

## The Invitation Flow

```
1. Victor (animus/victor) dwells in circle/chora-dev
   └── sovereign-to bond exists

2. Victor invites Alice:
   politeia/invite-to-circle({
     circle_id: "circle/chora-dev",
     invitee_pubkey: <alice-pubkey>,
     message: "Welcome to Chora"
   })
   → Creates invitation entity

3. Alice receives invitation (via syndesmos or out-of-band)

4. Alice creates her animus and circle:
   - animus/alice arises (embodies persona/alice)
   - circle/alice arises (sovereign-to → animus/alice)

5. Alice accepts invitation:
   politeia/accept-invitation({ invitation_id: "..." })
   - Creates member-of bond: animus/alice → circle/chora-dev
   - derive-attainments runs automatically
   - Creates has-attainment bonds for all chora-dev attainments

6. Alice's HUD now shows affordances from chora-dev attainments
   - render-hud traverses the bond graph
   - Returns display tree with affordances grouped by region
```

---

## The Attainment Derivation Flow

```
derive-attainments for animus/alice:

1. Gather memberships:
   animus/alice → member-of → [circle/alice, circle/chora-dev]

2. For each circle, gather attainments:
   circle/alice → grants-attainment → [attainment/basic-compose]
   circle/chora-dev → grants-attainment → [attainment/compose-theoria, attainment/invoke-nous]

3. Create has-attainment bonds:
   animus/alice → has-attainment → attainment/basic-compose
   animus/alice → has-attainment → attainment/compose-theoria
   animus/alice → has-attainment → attainment/invoke-nous

4. Return derived attainments
```

---

## The HUD Rendering Flow

```
render-hud for animus/alice:

1. Gather affordances:
   animus/alice → has-attainment → attainment → surfaces-as → affordance

2. Group by region:
   affordance → renders-in → hud-region

3. Build tree:
   - Get root regions (no child-of bond)
   - For each region:
     - Gather affordances rendering in this region
     - Gather child regions via child-of
     - Recurse

4. Return:
   [
     {
       region: { id: "hud-region/main", ... },
       affordances: [
         { id: "affordance/compose-theoria", name: "Compose Theoria", action: "nous/crystallize-theoria", ... }
       ],
       children: [...]
     }
   ]
```

---

## Dependencies

| Dependency | Status | Needed For |
|------------|--------|------------|
| Phase 18 (syndesmos) | **Complete** | Federation for invitations across chorai |
| Phase 17 (thyra) | **Complete** | Expression, streams |
| `circle` eidos | Exists | Needs sovereign-to desmos added |
| `persona` eidos | Exists | Animus embodies persona |
| Polis layer | **Complete** | Membership, visibility |

---

## Open Questions

### 1. Animus vs Persona Relationship

**Current design**: Animus has `persona_id` field + `embodies` desmos.

**Alternative**: Only desmos, no field duplication.

**Resolution**: Use both — field for quick lookup, desmos for graph traversal. The field is denormalized for performance.

### 2. Attainment Inheritance via Federation

If circle/alice federates with circle/kosmos, does Alice get Kosmos attainments?

**Options**:
- **Explicit grant**: Alice must be invited to Kosmos and become a member
- **Automatic via policy**: sync-policy can specify attainment flow
- **Request-based**: Alice requests attainments, Kosmos approves

**Resolution**: Explicit membership. Federation enables entity sync, but attainments require membership. This preserves sovereignty — you don't get capabilities just by connecting.

### 3. HUD Actuality

Is HUD rendering a substrate concern or kosmos concern?

**Resolution**: Kosmos produces render tree (data), substrate actualizes it (display). The `render-hud` praxis returns a data structure; thyra (or Tauri, or web) renders it visually.

### 4. Multi-Dwelling

Can animus dwell in multiple circles simultaneously?

**Current design**: One `dwells-in` bond (exclusive).

**Alternative**: Multiple dwelling with primary/secondary.

**Resolution**: Keep exclusive for now. Membership (member-of) can be multiple; dwelling (dwells-in) is singular — your current position/context.

---

## Verification Against Kosmogonia

| Principle | How Phase 19 Honors It |
|-----------|------------------------|
| **Visibility = Reachability** | Attainments flow through bond graph. You see affordances because you're bonded to circles that grant them. |
| **Authenticity = Provenance** | Invitations are composed entities with provenance. Memberships create bonds. Everything traces. |
| **Klimax** | We build at polis (circles), oikos (attainments), soma (HUD). Container → contained. |
| **Composition Requirement** | Circles, attainments, affordances all created via compose. No raw arise in praxeis. |
| **Dwelling Requirement** | Animus dwells in circle. Context is position. HUD renders based on dwelling position. |

---

## Summary

Phase 19 (Politeia) provides:

- **Circles** as governance units with proper desmos relationships (no array fields for relationships)
- **Animuses** as dwelling presences (embodies persona, dwells in circle)
- **Attainments** as capabilities derived from membership (traverse bond graph)
- **Affordances** as action surfaces (enabled by attainment, renders in region)
- **HUD** as entity-driven rendering (data structure, not UI code)
- **Invitations** as governed entry (preserve sovereignty)

This completes the path from "being in a circle" to "being able to act."

---

## Related Documents

- [ROADMAP.md](../ROADMAP.md) — Overall status
- [KOSMOGONIA.md](../KOSMOGONIA.md) — Constitutional foundation
- [syndesmos/DESIGN.md](../syndesmos/DESIGN.md) — Federation (Phase 18)
- [klimax/3-polis/DESIGN.md](../klimax/3-polis/DESIGN.md) — Circles and governance

---

*Composed in service of the kosmogonia.*
*Traces to: expression/genesis-root*
*Created: 2026-01-20 — Phase 19 complete*
