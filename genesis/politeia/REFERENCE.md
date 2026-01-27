<!-- =============================================================================
<!-- GENERATED FILE - DO NOT EDIT DIRECTLY -->
<!-- =============================================================================
<!-- Emitted by: emit_cycle (demiurge/emit-genesis) -->
<!-- Source: genesis/politeia/REFERENCE.md -->
<!-- -->
<!-- To modify: -->
<!--   1. Edit the source in genesis/ -->
<!--   2. Re-run emit-genesis -->
<!-- -->
<!-- See: genesis/EXTENDING.md -->
<!-- =============================================================================

# Politeia Reference

the constitution, governance and capability.

---

## Eide (Entity Types)

### affordance

Sensed possibility — what can be done from here. Emerges from attainments in context.

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `context_filter` | object |  | When this affordance is relevant (entity type, state, etc.) |
| `created_at` | timestamp | ✓ |  |
| `description` | string |  |  |
| `name` | string | ✓ | What this affordance represents |
| `praxis_id` | string | ✓ | The praxis this affordance invokes |
| `priority` | number |  | Display priority (higher = more prominent) |
| `required_attainments` | array |  | Attainment names required to see/use this affordance |

### attainment

Capability marker — what an animus can do. Derived from membership via bond graph traversal.

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `constraints` | object |  | Optional constraints (e.g., rate limits, resource quotas) |
| `created_at` | timestamp | ✓ |  |
| `description` | string |  |  |
| `name` | string | ✓ | Human-readable attainment name (e.g., 'compose', 'invite', 'govern') |
| `scope` | enum | ✓ | Where this attainment applies |

### hud-region

HUD region — UI surface where affordances render. Kosmos produces data, substrate renders.

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `affordances` | array |  | Affordance IDs that render in this region |
| `created_at` | timestamp | ✓ |  |
| `kind` | enum | ✓ | Region type — determines rendering behavior |
| `name` | string | ✓ |  |
| `parent_id` | string |  | Parent region ID for nesting |
| `position` | object |  | Position hints (e.g., {slot: 'top', order: 1}) |
| `required_attainment` | string |  | Attainment needed to see this region |
| `visibility` | enum | ✓ |  |

### invitation

Invitation to join a circle. Creates potential for membership bond.

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `accepted_at` | timestamp |  |  |
| `circle_id` | string | ✓ | Circle being invited to |
| `created_at` | timestamp | ✓ |  |
| `expires_at` | timestamp |  |  |
| `invitee_id` | string |  | Specific persona invited (optional for open invites) |
| `inviter_id` | string | ✓ | Persona who created the invite |
| `max_uses` | number |  | Maximum times this invite can be used (for open invites) |
| `message` | string |  | Optional message from inviter |
| `role` | string |  | Role/attainments granted upon acceptance |
| `status` | enum | ✓ |  |
| `token` | string |  | One-time token for link-based invites |
| `uses` | number |  |  |

### membership-event

Record of membership change — when someone joins, leaves, or is removed from a circle. Provides audit trail.

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `actor_id` | string |  | Who initiated the action (inviter for join, self for leave) |
| `actor_name` | string |  | Actor display name at time of event |
| `circle_id` | string | ✓ | Circle where the event occurred |
| `event_type` | enum | ✓ | Type of membership event |
| `invitation_id` | string |  | Related invitation ID (for join events) |
| `occurred_at` | timestamp | ✓ | When the event occurred |
| `persona_id` | string | ✓ | Persona affected by the event |
| `persona_name` | string |  | Display name at time of event (for historical display) |
| `reason` | string |  | Optional reason (for leave/remove events) |

## Praxeis (Operations)

🔧 = Exposed as MCP tool

### accept-invitation 🔧

Accept an invitation to join a circle.

**Tier:** 2 | **ID:** `praxis/politeia/accept-invitation`

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `invitation_id` | string | ✓ | Invitation to accept |

### admin-bind 🔧

Create a bond directly (administrative utility).

**Tier:** 3 | **ID:** `praxis/politeia/admin-bind`

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `from_id` | string | ✓ | Source entity ID |
| `to_id` | string | ✓ | Target entity ID |
| `desmos` | string | ✓ | Bond type (desmos name) |

### admin-loose 🔧

Remove a bond directly (administrative utility).

**Tier:** 3 | **ID:** `praxis/politeia/admin-loose`

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `from_id` | string | ✓ | Source entity ID |
| `to_id` | string | ✓ | Target entity ID |
| `desmos` | string | ✓ | Bond type (desmos name) |

### create-affordance 🔧

Create an affordance that surfaces an attainment.

**Tier:** 2 | **ID:** `praxis/politeia/create-affordance`

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `affordance_id` | string | ✓ | ID for the affordance |
| `name` | string | ✓ | Affordance name |
| `description` | string |  | Description |
| `praxis_id` | string | ✓ | Praxis to invoke when activated |
| `attainment_id` | string | ✓ | Attainment that enables this |
| `region_id` | string |  | HUD region to render in |
| `required_attainments` | array |  | Additional attainments required |
| `context_filter` | object |  | When this affordance is relevant |
| `priority` | number |  | Display priority (higher = more prominent) |

### create-attainment 🔧

Create a new attainment that circles can grant.

**Tier:** 2 | **ID:** `praxis/politeia/create-attainment`

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `attainment_id` | string | ✓ | ID for the attainment |
| `name` | string | ✓ | Attainment name (e.g., "compose", "invite", "govern") |
| `description` | string |  | Description of what this attainment enables |
| `scope` | string |  | Scope: circle, oikos, global (default: circle) |
| `constraints` | object |  | Optional constraints (rate limits, quotas, etc.) |

### create-circle 🔧

Create a new circle with the caller's animus as sovereign.

**Tier:** 2 | **ID:** `praxis/politeia/create-circle`

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `circle_id` | string | ✓ | ID for the new circle (e.g., circle/my-circle) |
| `name` | string | ✓ | Human-readable circle name |
| `description` | string |  | Circle description |
| `kind` | string |  | Circle kind: self, intimate, community, public (default: intimate) |

### create-distribution-circle 🔧

Create a distribution circle for an oikos-prod.

**Tier:** 2 | **ID:** `praxis/politeia/create-distribution-circle`

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `oikos_prod_id` | string | ✓ | The oikos-prod to distribute |
| `circle_id` | string | ✓ | ID for the distribution circle |
| `name` | string | ✓ | Human-readable circle name |
| `distribution_kind` | string | ✓ | Distribution kind: commons (public) or premium (intimate) |
| `description` | string |  | Circle description |

### create-hud-region 🔧

Create a HUD region.

**Tier:** 2 | **ID:** `praxis/politeia/create-hud-region`

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `region_id` | string | ✓ | ID for the region |
| `name` | string | ✓ | Region name |
| `kind` | string | ✓ | Region kind: toolbar, sidebar, contextual, modal, toast, ambient |
| `position` | object |  | Position hints |
| `visibility` | string |  | Visibility: always, contextual, on_demand (default: contextual) |
| `parent_region_id` | string |  | Parent region for nesting |
| `required_attainment` | string |  | Attainment needed to see this region |

### create-membership-event 🔧

Record a membership change event for audit trail.

**Tier:** 2 | **ID:** `praxis/politeia/create-membership-event`

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `event_type` | string | ✓ | Event type: joined, left, removed, invited |
| `circle_id` | string | ✓ | Circle where the event occurred |
| `persona_id` | string | ✓ | Persona affected by the event |
| `persona_name` | string |  | Display name at time of event |
| `actor_id` | string |  | Who initiated the action |
| `actor_name` | string |  | Actor display name at time of event |
| `invitation_id` | string |  | Related invitation ID (for join events) |
| `reason` | string |  | Optional reason (for leave/remove events) |

### decline-invitation 🔧

Decline an invitation.

**Tier:** 1 | **ID:** `praxis/politeia/decline-invitation`

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `invitation_id` | string | ✓ | Invitation to decline |

### derive-attainments 🔧

Derive attainments for an animus based on circle memberships.

**Tier:** 2 | **ID:** `praxis/politeia/derive-attainments`

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `animus_id` | string |  | Animus to derive for (defaults to caller) |
| `circle_id` | string |  | Specific circle to derive from (optional) |

### distribute-oikos 🔧

Distribute an oikos-prod through an existing circle.

**Tier:** 2 | **ID:** `praxis/politeia/distribute-oikos`

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `oikos_prod_id` | string | ✓ | The oikos-prod to distribute |
| `circle_id` | string | ✓ | The circle to distribute through |

### dwell-in-circle 🔧

Move dwelling position to a circle.

**Tier:** 2 | **ID:** `praxis/politeia/dwell-in-circle`

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `circle_id` | string | ✓ | Circle to dwell in |

### gather-affordances 🔧

Gather all affordances available to the caller.

**Tier:** 1 | **ID:** `praxis/politeia/gather-affordances`

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `context_entity_id` | string |  | Filter affordances relevant to this entity |
| `max_results` | number |  | Maximum results |

### grant-attainment 🔧

Grant an attainment from a circle.

**Tier:** 2 | **ID:** `praxis/politeia/grant-attainment`

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `circle_id` | string | ✓ | Circle granting the attainment |
| `attainment_id` | string | ✓ | Attainment to grant |

### install-oikos 🔧

Install an oikos from a distribution circle.

**Tier:** 2 | **ID:** `praxis/politeia/install-oikos`

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `oikos_prod_id` | string | ✓ | The oikos-prod to install |
| `circle_id` | string |  | The circle to install for (defaults to dwelling circle) |

### invite-to-circle 🔧

Invite someone to join a circle.

**Tier:** 2 | **ID:** `praxis/politeia/invite-to-circle`

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `invitation_id` | string | ✓ | ID for the invitation |
| `circle_id` | string | ✓ | Circle to invite to |
| `invitee_id` | string |  | Specific persona ID to invite (omit for open invite) |
| `message` | string |  | Message to include with invitation |
| `expires_in_days` | number |  | Days until expiration (default 7) |
| `max_uses` | number |  | Max uses for open invites |

### invoke-affordance 🔧

Invoke an affordance (execute its action praxis).

**Tier:** 3 | **ID:** `praxis/politeia/invoke-affordance`

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `affordance_id` | string | ✓ | Affordance to invoke |
| `params` | object |  | Parameters for the action praxis |

### leave-circle 🔧

Leave a circle (remove membership).

**Tier:** 2 | **ID:** `praxis/politeia/leave-circle`

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `circle_id` | string | ✓ | Circle to leave |

### list-attainments 🔧

List attainments for an animus or circle.

**Tier:** 1 | **ID:** `praxis/politeia/list-attainments`

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `animus_id` | string |  | List attainments for this animus |
| `circle_id` | string |  | List attainments granted by this circle |
| `max_results` | number |  | Maximum results |

### list-circles 🔧

List circles the animus is member of or can see.

**Tier:** 1 | **ID:** `praxis/politeia/list-circles`

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `membership_only` | boolean |  | Only show circles with membership (default false) |
| `max_results` | number |  | Maximum results (default 50) |

### list-distributed-oikoi 🔧

List oikoi distributed by a circle.

**Tier:** 1 | **ID:** `praxis/politeia/list-distributed-oikoi`

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `circle_id` | string | ✓ | The circle to query |

### list-hud-regions 🔧

List HUD regions.

**Tier:** 1 | **ID:** `praxis/politeia/list-hud-regions`

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `kind` | string |  | Filter by region kind |
| `max_results` | number |  | Maximum results |

### list-installed-oikoi 🔧

List oikoi installed for a circle.

**Tier:** 1 | **ID:** `praxis/politeia/list-installed-oikoi`

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `circle_id` | string |  | The circle to query (defaults to dwelling circle) |

### list-membership-events 🔧

List membership events for a circle.

**Tier:** 1 | **ID:** `praxis/politeia/list-membership-events`

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `circle_id` | string | ✓ | Circle to query events for |
| `event_type` | string |  | Filter by event type |
| `max_results` | number |  | Maximum results (default 50) |

### list-oikos-distributors 🔧

List circles that distribute an oikos.

**Tier:** 1 | **ID:** `praxis/politeia/list-oikos-distributors`

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `oikos_prod_id` | string | ✓ | The oikos-prod to query |

### render-hud 🔧

Build the HUD render tree for the caller.

**Tier:** 1 | **ID:** `praxis/politeia/render-hud`

*No parameters*

### revoke-attainment 🔧

Revoke an attainment grant from a circle.

**Tier:** 2 | **ID:** `praxis/politeia/revoke-attainment`

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `circle_id` | string | ✓ | Circle revoking the attainment |
| `attainment_id` | string | ✓ | Attainment to revoke |

### uninstall-oikos 🔧

Uninstall an oikos from a circle.

**Tier:** 2 | **ID:** `praxis/politeia/uninstall-oikos`

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `oikos_prod_id` | string | ✓ | The oikos-prod to uninstall |
| `circle_id` | string |  | The circle to uninstall from (defaults to dwelling circle) |

## Desmoi (Bond Types)

| Desmos | From → To | Description |
|--------|-----------|-------------|
| `child-of` | hud-region → layout | HUD region is child of layout. Structural composition. |
| `dwells-in` | * → * | Animus dwells in circle |
| `embodies` | animus → persona | Animus embodies persona — the dwelling presence of an identity. |
| `enabled-by` | hud-region → attainment | HUD region enabled by attainment — what capability makes it visible. |
| `granted-by` | attainment → circle | Attainment granted by circle — inverse tracking for provenance. |
| `grants-attainment` | circle → attainment | Circle grants attainment to its members. |
| `has-attainment` | animus → attainment | Animus has attainment — capability derived from membership. |
| `invited-to` | invitation → circle | Invitation invites persona to circle. |
| `member-of` | * → * | Persona is member of circle |
| `renders-in` | panel → hud-region | Panel renders in a HUD region. Binding content to visual location. |
| `sovereign-to` | circle → animus | Circle is sovereign to animus — governs what it can do. |
| `surfaces-as` | affordance → hud-region | Affordance surfaces as HUD region — how possibilities become visible. |

---

*Generated from schema definitions. Do not edit directly.*
