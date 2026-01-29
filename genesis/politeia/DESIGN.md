# Politeia Design

πολιτεία (politeia) — the constitution, how citizens participate in governance.

## Ontological Purpose

What gap in being does politeia address?

**The gap of capability and governance.** Without politeia, entities exist but have no concept of "who can do what." Hypostasis provides identity (who you are), but identity alone doesn't grant capability. The kosmos would have personas without roles, circles without governance, and actions without permission.

Politeia provides:
- **Circles** — governance units that organize personas and grant capabilities
- **Attainments** — capabilities derived from circle membership
- **Affordances** — how capabilities surface for action in context
- **HUD regions** — spatial organization of action surfaces
- **Invitations** — governed entry into circles

**What becomes possible:**
- Membership grants capability (join a circle, receive its attainments)
- Capabilities are discoverable (traverse the bond graph to see what you can do)
- Actions surface contextually (affordances appear based on attainments and context)
- Sovereignty remains distributed (each circle governs its own capabilities)
- Oikos distribution flows through governance (circles distribute oikoi to members)

## Circle Context

### Self Circle

A solitary dweller uses politeia to:
- Create their personal circle (sovereign to their animus)
- Define what capabilities they grant themselves
- Organize their HUD regions and affordances
- Install oikoi into their self circle

The self circle is where politeia is most personal — your own governance of your own capabilities.

### Peer Circle

Collaborators use politeia to:
- Create shared circles for collaboration
- Invite each other via invitations
- Define attainments that members receive
- Surface shared affordances for collaborative action
- Distribute oikoi to all members

Trust in peer circles is membership-based — joining grants attainments, leaving revokes them.

### Commons Circle

A community uses politeia to:
- Establish open circles anyone can join
- Define baseline attainments for all members
- Provide community affordances
- Distribute public oikoi to all members
- Maintain audit trail of membership events

The commons circle is where politeia scales — governance for communities.

## Core Entities (Eide)

### attainment

A capability marker — what an animus can do.

**Fields:**
- `name` — Human-readable attainment name (e.g., 'compose', 'invite', 'govern')
- `description` — What this attainment enables
- `scope` — Where this applies: circle, oikos, or global
- `constraints` — Optional constraints (rate limits, quotas)
- `created_at` — Creation timestamp

**Lifecycle:**
1. **Create** — Attainment defined via `create-attainment`
2. **Grant** — Circle grants attainment via `grant-attainment`
3. **Derive** — Animus receives attainment via `derive-attainments`
4. **Revoke** — Circle revokes grant, animus loses attainment

**Key insight:** Attainments are derived from membership, not directly assigned. You receive capabilities by joining circles that grant them.

### affordance

A sensed possibility — what can be done from here.

**Fields:**
- `name` — What this affordance represents
- `description` — Description
- `praxis_id` — The praxis to invoke when activated
- `required_attainments` — Attainment names required to see/use
- `context_filter` — When this affordance is relevant
- `priority` — Display priority (higher = more prominent)
- `created_at` — Creation timestamp

**Lifecycle:**
1. **Create** — Affordance defined via `create-affordance`
2. **Surface** — Appears based on attainments + context
3. **Invoke** — User activates, praxis executes

### hud-region

A display region in the HUD (heads-up display).

**Fields:**
- `name` — Region name
- `kind` — Type: toolbar, sidebar, contextual, modal, toast, ambient
- `parent_id` — Parent region for nesting
- `position` — Position hints
- `visibility` — always, contextual, or on_demand
- `required_attainment` — Attainment needed to see this region
- `affordances` — Affordance IDs that render here
- `created_at` — Creation timestamp

**Lifecycle:**
1. **Create** — Region defined via `create-hud-region`
2. **Populate** — Affordances bond via `renders-in`
3. **Render** — `render-hud` builds display tree

### invitation

An invitation to join a circle.

**Fields:**
- `circle_id` — Circle being invited to
- `invitee_id` — Specific persona invited (optional for open invites)
- `inviter_id` — Persona who created the invite
- `role` — Role/attainments granted upon acceptance
- `message` — Optional message from inviter
- `status` — pending, accepted, declined, expired, revoked
- `token` — One-time token for link-based invites
- `max_uses` — Maximum uses for open invites
- `uses` — Current usage count
- `created_at`, `expires_at`, `accepted_at` — Timestamps

**Lifecycle:**
1. **Create** — Invitation via `invite-to-circle`
2. **Pending** — Awaiting response
3. **Accept/Decline** — Via `accept-invitation` or `decline-invitation`
4. **Expire** — If `expires_at` passes

### membership-event

Record of membership change — audit trail.

**Fields:**
- `event_type` — joined, left, removed, invited
- `circle_id` — Circle where event occurred
- `persona_id` — Persona affected
- `persona_name` — Display name at time of event
- `actor_id` — Who initiated the action
- `actor_name` — Actor display name
- `invitation_id` — Related invitation (for joins)
- `reason` — Optional reason (for leave/remove)
- `occurred_at` — When event occurred

## Bonds (Desmoi)

### Governance Bonds

#### sovereign-to
- **From:** circle
- **To:** animus
- **Cardinality:** one-to-many
- **Traversal:** Who governs this circle? Which circles does this animus govern?

#### embodies
- **From:** animus
- **To:** persona
- **Cardinality:** many-to-one
- **Traversal:** Which persona does this animus embody? Which animi embody this persona?

### Capability Bonds

#### grants-attainment
- **From:** circle
- **To:** attainment
- **Cardinality:** one-to-many
- **Traversal:** What attainments does this circle grant?

#### has-attainment
- **From:** animus
- **To:** attainment
- **Cardinality:** many-to-many
- **Traversal:** What attainments does this animus have?

#### granted-by
- **From:** attainment
- **To:** circle
- **Cardinality:** many-to-many
- **Traversal:** Which circles grant this attainment? (Inverse provenance)

### Surface Bonds

#### surfaces-as
- **From:** affordance
- **To:** hud-region
- **Cardinality:** many-to-one
- **Traversal:** Where does this affordance render?

#### enabled-by
- **From:** hud-region/affordance
- **To:** attainment
- **Cardinality:** many-to-one
- **Traversal:** What capability enables this?

#### renders-in
- **From:** hud-region
- **To:** hud-region
- **Cardinality:** many-to-one
- **Traversal:** Hierarchical region nesting

### Structure Bonds

#### child-of
- **From:** invitation/membership-event
- **To:** circle
- **Cardinality:** many-to-one
- **Traversal:** Which circle does this belong to?

#### invited-to
- **From:** invitation
- **To:** circle
- **Cardinality:** many-to-one
- **Traversal:** Which circle is this invitation for?

#### distributes
- **From:** circle
- **To:** oikos-prod
- **Cardinality:** many-to-many
- **Traversal:** What oikoi does this circle distribute?

## Operations (Praxeis)

### Circle Operations

#### create-circle
Create a new circle with caller as sovereign.
- **When:** Establishing a new governance unit
- **Requires:** Animus context
- **Creates:** Circle entity + sovereign-to + member-of bonds

#### invite-to-circle
Invite someone to join a circle.
- **When:** Growing circle membership
- **Requires:** Caller is sovereign to circle
- **Gated by:** `attainment/invite`

#### accept-invitation
Accept an invitation, join circle.
- **When:** Responding to invitation
- **Effect:** Creates member-of bond, derives attainments

#### decline-invitation
Decline an invitation.
- **When:** Refusing circle membership
- **Effect:** Updates invitation status

#### dwell-in-circle
Move dwelling position to a circle.
- **When:** Changing context (exclusive)
- **Requires:** Membership in target circle

#### leave-circle
Leave a circle (remove membership).
- **When:** Exiting circle
- **Effect:** Removes member-of bond, clears derived attainments

#### list-circles
List circles the animus is member of or can see.
- **When:** Browsing governance structure

### Attainment Operations

#### create-attainment
Create a new attainment that circles can grant.
- **When:** Defining new capabilities
- **Gated by:** `attainment/govern`

#### grant-attainment
Grant an attainment from a circle.
- **When:** Adding capabilities to circle membership
- **Requires:** Caller is sovereign to circle
- **Gated by:** `attainment/govern`

#### revoke-attainment
Revoke an attainment grant from a circle.
- **When:** Removing capabilities from circle membership
- **Requires:** Caller is sovereign to circle
- **Gated by:** `attainment/govern`

#### derive-attainments
Derive attainments for an animus based on memberships.
- **When:** After joining circle, syncing capabilities
- **Traversal:** animus → member-of → circle → grants-attainment → attainment

#### list-attainments
List attainments for an animus or circle.
- **When:** Auditing capabilities

### Affordance Operations

#### create-affordance
Create an affordance that surfaces an attainment.
- **When:** Making capabilities actionable
- **Gated by:** `attainment/hud`

#### gather-affordances
Gather all affordances available to the caller.
- **When:** Building action menu
- **Traversal:** animus → has-attainment → attainment → surfaces-as → affordance

#### render-hud
Build the HUD render tree for the caller.
- **When:** Rendering interface
- **Returns:** Nested structure of regions with affordances

#### invoke-affordance
Invoke an affordance (execute its action praxis).
- **When:** User activates an action
- **Verifies:** Caller has required attainment

### HUD Operations

#### create-hud-region
Create a HUD region.
- **When:** Organizing interface layout
- **Gated by:** `attainment/hud`

#### list-hud-regions
List HUD regions.
- **When:** Browsing layout structure

### Distribution Operations

#### create-distribution-circle
Create a distribution circle for an oikos-prod.
- **When:** Publishing oikos for distribution
- **Gated by:** `attainment/distribute`

#### distribute-oikos
Distribute an oikos-prod through an existing circle.
- **When:** Adding oikos to circle's distribution
- **Gated by:** `attainment/distribute`

#### install-oikos
Install an oikos from a distribution circle.
- **When:** Receiving oikos from circle membership

#### list-distributed-oikoi
List oikoi distributed by a circle.
- **When:** Auditing circle's distribution

### Administrative Operations

#### admin-bind
Create a bond directly (bypass governance).
- **When:** Bootstrap, repair
- **Gated by:** `attainment/admin`

#### admin-loose
Remove a bond directly (bypass governance).
- **When:** Repair operations
- **Gated by:** `attainment/admin`

## Attainments

### attainment/govern
**Capability:** Create circles, manage attainments.
**Gates:** `create-circle`, `create-attainment`, `grant-attainment`, `revoke-attainment`
**Scope:** circle

### attainment/invite
**Capability:** Invite others to circles.
**Gates:** `invite-to-circle`
**Scope:** circle

### attainment/distribute
**Capability:** Distribute oikoi through circles.
**Gates:** `create-distribution-circle`, `distribute-oikos`
**Scope:** circle

### attainment/hud
**Capability:** Create and manage HUD regions and affordances.
**Gates:** `create-affordance`, `create-hud-region`
**Scope:** circle

### attainment/admin
**Capability:** Administrative operations (bypass normal governance).
**Gates:** `admin-bind`, `admin-loose`
**Scope:** global

## Embodiment

### Completeness Status

| Level | Status |
|-------|--------|
| Defined | eide, desmoi, praxeis exist in YAML |
| Loaded | Bootstrap loads into kosmos.db |
| Projected | MCP projects praxeis as tools |
| Embodied | Body-schema reflects capabilities |
| Surfaced | Reconciler notices when actions are relevant |
| Afforded | Thyra UI presents contextual actions |

### Body-Schema Contribution

When `sense-body` runs, politeia contributes:

```yaml
body-schema:
  governance:
    dwelling_circle: "$_circle"
    member_of_circles: [...]
    sovereign_of_circles: [...]
  capabilities:
    attainments:
      - name: govern
        source_circle: circle/kosmos
        scope: circle
      - name: invite
        source_circle: circle/kosmos
        scope: circle
  affordances:
    available:
      - name: Compose Theoria
        praxis: nous/crystallize-theoria
        region: hud-region/main
    contextual:
      - name: Invite to Circle
        praxis: politeia/invite-to-circle
        when: "$sovereign_of_circles | length > 0"
  pending_actions:
    - action: accept_invitation
      reason: "Pending invitation from circle/chora-dev"
      when: "$pending_invitations | length > 0"
```

### Reconciler

```yaml
reconciler/politeia-attainments:
  trigger: on-dwell
  sense: |
    - Check if attainments need re-derivation (membership changed)
    - Check for pending invitations
    - Check if oikoi need sync from new circles
  surface: |
    - If membership changed: re-derive attainments
    - If pending invitations: suggest review
    - If oikoi outdated: suggest update
```

## Compound Leverage

### Amplifies Other Oikoi

| Oikos | How Politeia Amplifies |
|-------|----------------------|
| **hypostasis** | Credentials grant attainments (use-embedding-api from credential) |
| **nous** | Theoria composition requires compose attainment |
| **demiurge** | Oikos publication flows through distribution circles |
| **manteia** | Generation requires use-anthropic-api attainment |
| **thyra** | HUD rendering uses affordances and regions |
| **propylon** | Entry links can grant circle membership |
| **ekdosis** | Published oikoi reach users via distribution circles |

### Cross-Oikos Patterns

1. **Membership → Attainment → Praxis**
   Join circle → receive attainments → praxeis become available.
   Example: Join circle/chora-dev → get compose attainment → nous/crystallize-theoria works.

2. **Credential → Attainment → Service**
   Unlock credential → session gains attainment → service available.
   Example: Unlock OpenAI credential → use-embedding-api attainment → nous/index works.

3. **Attainment → Affordance → HUD**
   Have attainment → affordance surfaces → appears in HUD.
   Example: Have compose → affordance/compose-theoria → renders in hud-region/main.

4. **Circle → Distribution → Installation**
   Circle distributes oikos → member joins → oikos installed.
   Example: circle/commons distributes nous → user joins → nous available.

## Theoria

New theoria crystallized during this redesign:

### T24: Governance flows through the bond graph

Capability in kosmos is not assigned directly but flows structurally. You have an attainment because you're bonded to a circle that grants it. Remove the bond, capability vanishes. This is T1 (visibility = reachability) applied to governance.

### T25: Attainments are derived, not assigned

You don't "give someone an attainment" — you invite them to a circle that grants it. This preserves sovereignty: circles control their attainments, and membership is the mechanism for receiving them. Derivation traverses the graph rather than storing direct assignments.

### T26: Affordances surface capabilities contextually

Affordances aren't "menus you design" — they emerge from the intersection of what you can do (attainments) and what's relevant (context). The HUD is entity-driven: traverse attainment → surfaces-as → affordance → renders-in → region.

## Two Pillars of Governance

1. **Membership = Capability** — What you can do flows from where you belong.

2. **Sovereignty = Distribution** — Each circle governs its own attainments; no central authority.

Both are structural, not policy. Both emerge from the bond graph.

## Future Extensions

- **Delegation** — Grant attainments with time limits or revocation conditions
- **Role templates** — Pre-defined attainment bundles for common roles
- **Attainment inheritance** — Circles inherit attainments from parent circles
- **Capability negotiation** — Request attainments from circles you're not member of
- **Governance voting** — Multi-signature attainment changes

---

*Politeia is self-governance — the kosmos that knows what can be done, by whom, and why. Governance is the distribution of capability through the bond graph. Membership is the mechanism, attainments the currency, affordances the surface.*
