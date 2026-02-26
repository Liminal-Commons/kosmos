# Politeia Design

πολιτεία (politeia) — the constitution, how citizens participate in governance.

## Ontological Purpose

What gap in being does politeia address?

**The gap of capability and governance.** Without politeia, entities exist but have no concept of "who can do what." Hypostasis provides identity (who you are), but identity alone doesn't grant capability. The kosmos would have prosopa without roles, oikoi without governance, and actions without permission.

Politeia provides:
- **Oikoi** — governance units that organize prosopa and grant capabilities
- **Attainments** — capabilities derived from oikos membership
- **Affordances** — how capabilities surface for action in context
- **Invitations** — governed entry into oikoi

**What becomes possible:**
- Membership grants capability (join an oikos, receive its attainments)
- Capabilities are discoverable (traverse the bond graph to see what you can do)
- Actions surface contextually (affordances appear based on attainments and context)
- Sovereignty remains distributed (each oikos governs its own capabilities)
- Topos distribution flows through governance (oikoi distribute topoi to members)

## Oikos Context

### Sole Oikos

A solitary dweller uses politeia to:
- Create their personal oikos (sovereign to their parousia)
- Define what capabilities they grant themselves
- Organize their affordances
- Install topoi into their sole oikos

The sole oikos is where politeia is most personal — your own governance of your own capabilities.

### Collective Oikos

Collaborators use politeia to:
- Create shared oikoi for collaboration
- Invite each other via invitations
- Define attainments that members receive
- Surface shared affordances for collaborative action
- Distribute topoi to all members

Trust in peer oikoi is membership-based — joining grants attainments, leaving revokes them.

### Commons Oikos

A community uses politeia to:
- Establish open oikoi anyone can join
- Define baseline attainments for all members
- Provide community affordances
- Distribute public topoi to all members
- Maintain audit trail of membership events

The commons oikos is where politeia scales — governance for communities.

## Core Entities (Eide)

### attainment

A capability marker — what a parousia can do.

**Fields:**
- `name` — Human-readable attainment name (e.g., 'compose', 'invite', 'govern')
- `description` — What this attainment enables
- `scope` — Where this applies: oikos, topos, or global
- `constraints` — Optional constraints (rate limits, quotas)
- `created_at` — Creation timestamp

**Lifecycle:**
1. **Create** — Attainment defined via `create-attainment`
2. **Grant** — Oikos grants attainment via `grant-attainment`
3. **Derive** — Parousia receives attainment via `derive-attainments`
4. **Revoke** — Oikos revokes grant, parousia loses attainment

**Key insight:** Attainments are derived from membership, not directly assigned. You receive capabilities by joining oikoi that grant them.

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

### invitation

An invitation to join an oikos.

**Fields:**
- `oikos_id` — Oikos being invited to
- `invitee_id` — Specific prosopon invited (optional for open invites)
- `inviter_id` — Prosopon who created the invite
- `role` — Role/attainments granted upon acceptance
- `message` — Optional message from inviter
- `status` — pending, accepted, declined, expired, revoked
- `token` — One-time token for link-based invites
- `max_uses` — Maximum uses for open invites
- `uses` — Current usage count
- `created_at`, `expires_at`, `accepted_at` — Timestamps

**Lifecycle:**
1. **Create** — Invitation via `invite-to-oikos`
2. **Pending** — Awaiting response
3. **Accept/Decline** — Via `accept-invitation` or `decline-invitation`
4. **Expire** — If `expires_at` passes

### membership-event

Record of membership change — audit trail.

**Fields:**
- `event_type` — joined, left, removed, invited
- `oikos_id` — Oikos where event occurred
- `prosopon_id` — Prosopon affected
- `prosopon_name` — Display name at time of event
- `actor_id` — Who initiated the action
- `actor_name` — Actor display name
- `invitation_id` — Related invitation (for joins)
- `reason` — Optional reason (for leave/remove)
- `occurred_at` — When event occurred

## Bonds (Desmoi)

### Governance Bonds

#### sovereign-to
- **From:** oikos
- **To:** parousia
- **Cardinality:** one-to-many
- **Traversal:** Who governs this oikos? Which oikoi does this parousia govern?

#### embodies
- **From:** parousia
- **To:** prosopon
- **Cardinality:** many-to-one
- **Traversal:** Which prosopon does this parousia embody? Which parousiai embody this prosopon?

### Capability Bonds

#### grants-attainment
- **From:** oikos
- **To:** attainment
- **Cardinality:** one-to-many
- **Traversal:** What attainments does this oikos grant?

#### has-attainment
- **From:** parousia
- **To:** attainment
- **Cardinality:** many-to-many
- **Traversal:** What attainments does this parousia have?

#### granted-by
- **From:** attainment
- **To:** oikos
- **Cardinality:** many-to-many
- **Traversal:** Which oikoi grant this attainment? (Inverse provenance)

### Affordance Bonds

#### surfaces-as
- **From:** attainment
- **To:** affordance
- **Cardinality:** one-to-many
- **Traversal:** What affordances does this attainment surface?

#### enabled-by
- **From:** affordance
- **To:** attainment
- **Cardinality:** many-to-one
- **Traversal:** What capability enables this affordance?

### Structure Bonds

#### child-of
- **From:** invitation/membership-event
- **To:** oikos
- **Cardinality:** many-to-one
- **Traversal:** Which oikos does this belong to?

#### invited-to
- **From:** invitation
- **To:** oikos
- **Cardinality:** many-to-one
- **Traversal:** Which oikos is this invitation for?

#### distributes
- **From:** oikos
- **To:** topos-prod
- **Cardinality:** many-to-many
- **Traversal:** What topoi does this oikos distribute?

### Federation Bonds

#### federates-with
- **From:** oikos
- **To:** oikos
- **Cardinality:** many-to-many
- **Traversal:** Which oikoi are federated? Content syncs continuously through this bond.

#### tracks-sync
- **From:** sync-cursor
- **To:** oikos
- **Cardinality:** many-to-one
- **Traversal:** What sync position does this cursor track?

## Operations (Praxeis)

### Oikos Operations

#### create-oikos
Create a new oikos with caller as sovereign.
- **When:** Establishing a new governance unit
- **Requires:** Parousia context
- **Creates:** Oikos entity + sovereign-to + member-of bonds

#### invite-to-oikos
Invite someone to join an oikos.
- **When:** Growing oikos membership
- **Requires:** Caller is sovereign to oikos
- **Gated by:** `attainment/invite`

#### accept-invitation
Accept an invitation, join oikos.
- **When:** Responding to invitation
- **Effect:** Creates member-of bond, derives attainments

#### decline-invitation
Decline an invitation.
- **When:** Refusing oikos membership
- **Effect:** Updates invitation status

#### dwell-in-oikos
Move dwelling position to an oikos.
- **When:** Changing context (exclusive)
- **Requires:** Membership in target oikos

#### leave-oikos
Leave an oikos (remove membership).
- **When:** Exiting oikos
- **Effect:** Removes member-of bond, clears derived attainments

#### list-oikoi
List oikoi the parousia is member of or can see.
- **When:** Browsing governance structure

### Attainment Operations

#### create-attainment
Create a new attainment that oikoi can grant.
- **When:** Defining new capabilities
- **Gated by:** `attainment/govern`

#### grant-attainment
Grant an attainment from an oikos.
- **When:** Adding capabilities to oikos membership
- **Requires:** Caller is sovereign to oikos
- **Gated by:** `attainment/govern`

#### revoke-attainment
Revoke an attainment grant from an oikos.
- **When:** Removing capabilities from oikos membership
- **Requires:** Caller is sovereign to oikos
- **Gated by:** `attainment/govern`

#### derive-attainments
Derive attainments for a parousia based on memberships.
- **When:** After joining oikos, syncing capabilities
- **Traversal:** parousia -> member-of -> oikos -> grants-attainment -> attainment

#### list-attainments
List attainments for a parousia or oikos.
- **When:** Auditing capabilities

### Affordance Operations

#### create-affordance
Create an affordance that surfaces an attainment.
- **When:** Making capabilities actionable
- **Gated by:** `attainment/hud`

#### gather-affordances
Gather all affordances available to the caller.
- **When:** Building action menu
- **Traversal:** parousia -> has-attainment -> attainment -> surfaces-as -> affordance

#### render-hud
Build the affordance set for the caller.
- **When:** Rendering affordance UI
- **Returns:** All affordances available to the current parousia

#### invoke-affordance
Invoke an affordance (execute its action praxis).
- **When:** User activates an action
- **Verifies:** Caller has required attainment

### Distribution Operations

#### create-distribution-oikos
Create a distribution oikos for a topos-prod.
- **When:** Publishing topos for distribution
- **Gated by:** `attainment/distribute`

#### distribute-topos
Distribute a topos-prod through an existing oikos.
- **When:** Adding topos to oikos's distribution
- **Gated by:** `attainment/distribute`

#### install-topos
Install a topos from a distribution oikos.
- **When:** Receiving topos from oikos membership

#### list-distributed-topoi
List topoi distributed by an oikos.
- **When:** Auditing oikos's distribution

### Federation Operations

#### federate-oikoi
Establish federation between local and remote oikoi.
- **When:** Enabling continuous sync across kosmoi
- **Requires:** Sovereignty over local oikos
- **Gated by:** `attainment/federate`

#### unfederate-oikoi
Dissolve federation between oikoi.
- **When:** Ending sync relationship
- **Gated by:** `attainment/federate`

#### list-federations
List federation bonds for an oikos.
- **When:** Auditing sync relationships

#### resolve-conflict
Resolve a sync conflict manually.
- **When:** Divergent entity versions across kosmoi

#### list-conflicts
List sync conflicts, filtered by status or oikos.
- **When:** Reviewing pending conflicts

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
**Capability:** Create oikoi, manage attainments.
**Gates:** `create-oikos`, `create-attainment`, `grant-attainment`, `revoke-attainment`
**Scope:** oikos

### attainment/invite
**Capability:** Invite others to oikoi.
**Gates:** `invite-to-oikos`
**Scope:** oikos

### attainment/distribute
**Capability:** Distribute topoi through oikoi.
**Gates:** `create-distribution-oikos`, `distribute-topos`
**Scope:** oikos

### attainment/hud
**Capability:** Create and manage affordances.
**Gates:** `create-affordance`
**Scope:** oikos

### attainment/admin
**Capability:** Administrative operations (bypass normal governance).
**Gates:** `admin-bind`, `admin-loose`
**Scope:** global

### attainment/federate
**Capability:** Establish federation between oikoi.
**Gates:** `federate-oikoi`, `unfederate-oikoi`, `list-federations`, `resolve-conflict`
**Scope:** oikos

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
    dwelling_oikos: "$_oikos"
    member_of_oikoi: [...]
    sovereign_of_oikoi: [...]
  capabilities:
    attainments:
      - name: govern
        source_oikos: oikos/kosmos
        scope: oikos
      - name: invite
        source_oikos: oikos/kosmos
        scope: oikos
  affordances:
    available:
      - name: Compose Theoria
        praxis: nous/crystallize-theoria
    contextual:
      - name: Invite to Oikos
        praxis: politeia/invite-to-oikos
        when: "$sovereign_of_oikoi | length > 0"
  pending_actions:
    - action: accept_invitation
      reason: "Pending invitation from oikos/chora-dev"
      when: "$pending_invitations | length > 0"
```

### Reconciler

```yaml
reconciler/politeia-attainments:
  trigger: on-dwell
  sense: |
    - Check if attainments need re-derivation (membership changed)
    - Check for pending invitations
    - Check if topoi need sync from new oikoi
  surface: |
    - If membership changed: re-derive attainments
    - If pending invitations: suggest review
    - If topoi outdated: suggest update
```

## Compound Leverage

### Amplifies Other Topoi

| Topos | How Politeia Amplifies |
|-------|----------------------|
| **hypostasis** | Credentials grant attainments (use-embedding-api from credential) |
| **nous** | Theoria composition requires compose attainment |
| **demiurge** | Topos publication flows through distribution oikoi |
| **manteia** | Generation requires use-anthropic-api attainment |
| **thyra** | Mode rendering uses affordances for contextual actions |
| **propylon** | Entry links can grant oikos membership |
| **ekdosis** | Published topoi reach users via distribution oikoi |

### Cross-Topos Patterns

1. **Membership -> Attainment -> Praxis**
   Join oikos -> receive attainments -> praxeis become available.
   Example: Join oikos/chora-dev -> get compose attainment -> nous/crystallize-theoria works.

2. **Credential -> Attainment -> Service**
   Unlock credential -> session gains attainment -> service available.
   Example: Unlock OpenAI credential -> use-embedding-api attainment -> nous/index works.

3. **Attainment -> Affordance -> Action**
   Have attainment -> affordance surfaces -> action available.
   Example: Have compose -> affordance/compose-theoria -> invoke praxis.

4. **Oikos -> Distribution -> Installation**
   Oikos distributes topos -> member joins -> topos installed.
   Example: oikos/commons distributes nous -> user joins -> nous available.

## Theoria

New theoria crystallized during this redesign:

### T24: Governance flows through the bond graph

Capability in kosmos is not assigned directly but flows structurally. You have an attainment because you're bonded to an oikos that grants it. Remove the bond, capability vanishes. This is T1 (visibility = reachability) applied to governance.

### T25: Attainments are derived, not assigned

You don't "give someone an attainment" — you invite them to an oikos that grants it. This preserves sovereignty: oikoi control their attainments, and membership is the mechanism for receiving them. Derivation traverses the graph rather than storing direct assignments.

### T26: Affordances surface capabilities contextually

Affordances aren't "menus you design" — they emerge from the intersection of what you can do (attainments) and what's relevant (context). The affordance graph is entity-driven: traverse attainment -> surfaces-as -> affordance. Spatial placement is handled by modes.

## Two Pillars of Governance

1. **Membership = Capability** — What you can do flows from where you belong.

2. **Sovereignty = Distribution** — Each oikos governs its own attainments; no central authority.

Both are structural, not policy. Both emerge from the bond graph.

## Future Extensions

- **Delegation** — Grant attainments with time limits or revocation conditions
- **Role templates** — Pre-defined attainment bundles for common roles
- **Attainment inheritance** — Oikoi inherit attainments from parent oikoi
- **Capability negotiation** — Request attainments from oikoi you're not member of
- **Governance voting** — Multi-signature attainment changes

---

*Politeia is self-governance — the kosmos that knows what can be done, by whom, and why. Governance is the distribution of capability through the bond graph. Membership is the mechanism, attainments the currency, affordances the surface.*
