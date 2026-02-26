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

Capability marker — what a parousia can do. Derived from membership via bond graph traversal.

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `constraints` | object |  | Optional constraints (e.g., rate limits, resource quotas) |
| `created_at` | timestamp | ✓ |  |
| `description` | string |  |  |
| `name` | string | ✓ | Human-readable attainment name (e.g., 'compose', 'invite', 'govern') |
| `scope` | enum | ✓ | Where this attainment applies |

### invitation

Invitation to join an oikos. Creates potential for membership bond.

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `accepted_at` | timestamp |  |  |
| `oikos_id` | string | ✓ | Oikos being invited to |
| `created_at` | timestamp | ✓ |  |
| `expires_at` | timestamp |  |  |
| `invitee_id` | string |  | Specific prosopon invited (optional for open invites) |
| `inviter_id` | string | ✓ | Prosopon who created the invite |
| `max_uses` | number |  | Maximum times this invite can be used (for open invites) |
| `message` | string |  | Optional message from inviter |
| `role` | string |  | Role/attainments granted upon acceptance |
| `status` | enum | ✓ |  |
| `token` | string |  | One-time token for link-based invites |
| `uses` | number |  |  |

### membership-event

Record of membership change — when someone joins, leaves, or is removed from an oikos. Provides audit trail.

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `actor_id` | string |  | Who initiated the action (inviter for join, self for leave) |
| `actor_name` | string |  | Actor display name at time of event |
| `oikos_id` | string | ✓ | Oikos where the event occurred |
| `event_type` | enum | ✓ | Type of membership event |
| `invitation_id` | string |  | Related invitation ID (for join events) |
| `occurred_at` | timestamp | ✓ | When the event occurred |
| `prosopon_id` | string | ✓ | Prosopon affected by the event |
| `prosopon_name` | string |  | Display name at time of event (for historical display) |
| `reason` | string |  | Optional reason (for leave/remove events) |

### sync-cursor

Tracks sync position for a federation bond. Enables delta sync.

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `federation_bond_id` | string | ✓ | ID of the federates-with bond this cursor tracks |
| `local_oikos_id` | string | ✓ | Local oikos in the federation |
| `remote_oikos_id` | string | ✓ | Remote oikos in the federation |
| `local_version` | integer | ✓ | Last local version synced to remote |
| `remote_version` | integer | ✓ | Last remote version received |
| `status` | enum | ✓ | active, paused, or failed |
| `last_sync_at` | timestamp |  | Last successful sync |
| `error_message` | string |  | Last error if status is failed |
| `created_at` | timestamp | ✓ |  |

### sync-conflict

Created when the same entity diverges across kosmoi. Human resolution needed.

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `entity_id` | string | ✓ | The entity that has conflicting versions |
| `entity_eidos` | string | ✓ | Type of the conflicting entity |
| `federation_bond_id` | string | ✓ | Federation bond where conflict was detected |
| `local_version` | integer | ✓ | Local version number |
| `local_data` | object | ✓ | Local entity data at conflict time |
| `remote_version` | integer | ✓ | Remote version number |
| `remote_data` | object | ✓ | Remote entity data at conflict time |
| `status` | enum | ✓ | open or resolved |
| `resolution` | enum |  | local, remote, or merged |
| `merged_data` | object |  | Custom merged data if resolution is merged |
| `resolved_by` | string |  | Prosopon ID who resolved the conflict |
| `detected_at` | timestamp | ✓ |  |
| `resolved_at` | timestamp |  |  |

## Praxeis (Operations)

### Oikos Operations

### create-oikos

Create a new oikos with the caller's parousia as sovereign.

**Tier:** 2 | **ID:** `praxis/politeia/create-oikos`

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `oikos_id` | string | ✓ | ID for the new oikos (e.g., oikos/my-oikos) |
| `name` | string | ✓ | Human-readable oikos name |
| `description` | string |  | Oikos description |
| `kind` | string |  | Oikos kind: sole, peer, commons (default: peer) |

### invite-to-oikos

Invite someone to join an oikos.

**Tier:** 2 | **ID:** `praxis/politeia/invite-to-oikos`

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `invitation_id` | string | ✓ | ID for the invitation |
| `oikos_id` | string | ✓ | Oikos to invite to |
| `invitee_id` | string |  | Specific prosopon ID to invite (omit for open invite) |
| `message` | string |  | Message to include with invitation |
| `expires_in_days` | number |  | Days until expiration (default 7) |
| `max_uses` | number |  | Max uses for open invites |

### accept-invitation

Accept an invitation to join an oikos.

**Tier:** 2 | **ID:** `praxis/politeia/accept-invitation`

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `invitation_id` | string | ✓ | Invitation to accept |

### decline-invitation

Decline an invitation.

**Tier:** 1 | **ID:** `praxis/politeia/decline-invitation`

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `invitation_id` | string | ✓ | Invitation to decline |

### dwell-in-oikos

Move dwelling position to an oikos.

**Tier:** 2 | **ID:** `praxis/politeia/dwell-in-oikos`

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `oikos_id` | string | ✓ | Oikos to dwell in |

### leave-oikos

Leave an oikos (remove membership).

**Tier:** 2 | **ID:** `praxis/politeia/leave-oikos`

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `oikos_id` | string | ✓ | Oikos to leave |

### list-oikoi

List oikoi the parousia is member of or can see.

**Tier:** 1 | **ID:** `praxis/politeia/list-oikoi`

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `membership_only` | boolean |  | Only show oikoi with membership (default false) |
| `max_results` | number |  | Maximum results (default 50) |

### Attainment Operations

### create-attainment

Create a new attainment that oikoi can grant.

**Tier:** 2 | **ID:** `praxis/politeia/create-attainment`

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `attainment_id` | string | ✓ | ID for the attainment |
| `name` | string | ✓ | Attainment name (e.g., "compose", "invite", "govern") |
| `description` | string |  | Description of what this attainment enables |
| `scope` | string |  | Scope: oikos, topos, global (default: oikos) |
| `constraints` | object |  | Optional constraints (rate limits, quotas, etc.) |

### grant-attainment

Grant an attainment from an oikos.

**Tier:** 2 | **ID:** `praxis/politeia/grant-attainment`

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `oikos_id` | string | ✓ | Oikos granting the attainment |
| `attainment_id` | string | ✓ | Attainment to grant |

### revoke-attainment

Revoke an attainment grant from an oikos.

**Tier:** 2 | **ID:** `praxis/politeia/revoke-attainment`

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `oikos_id` | string | ✓ | Oikos revoking the attainment |
| `attainment_id` | string | ✓ | Attainment to revoke |

### derive-attainments

Derive attainments for a parousia based on oikos memberships.

**Tier:** 2 | **ID:** `praxis/politeia/derive-attainments`

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `parousia_id` | string |  | Parousia to derive for (defaults to caller) |
| `oikos_id` | string |  | Specific oikos to derive from (optional) |

### list-attainments

List attainments for a parousia or oikos.

**Tier:** 1 | **ID:** `praxis/politeia/list-attainments`

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `parousia_id` | string |  | List attainments for this parousia |
| `oikos_id` | string |  | List attainments granted by this oikos |
| `max_results` | number |  | Maximum results |

### Affordance Operations

### create-affordance

Create an affordance that surfaces an attainment.

**Tier:** 2 | **ID:** `praxis/politeia/create-affordance`

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `affordance_id` | string | ✓ | ID for the affordance |
| `name` | string | ✓ | Affordance name |
| `description` | string |  | Description |
| `praxis_id` | string | ✓ | Praxis to invoke when activated |
| `attainment_id` | string | ✓ | Attainment that enables this |
| `context_filter` | object |  | When this affordance is relevant |
| `priority` | number |  | Display priority (higher = more prominent) |

### gather-affordances

Gather all affordances available to the caller.

**Tier:** 1 | **ID:** `praxis/politeia/gather-affordances`

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `context_entity_id` | string |  | Filter affordances relevant to this entity |
| `max_results` | number |  | Maximum results |

### render-hud

Build the HUD render tree for the caller.

**Tier:** 1 | **ID:** `praxis/politeia/render-hud`

*No parameters*

### invoke-affordance

Invoke an affordance (execute its action praxis).

**Tier:** 3 | **ID:** `praxis/politeia/invoke-affordance`

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `affordance_id` | string | ✓ | Affordance to invoke |
| `params` | object |  | Parameters for the action praxis |

### Membership Events

### create-membership-event

Record a membership change event for audit trail.

**Tier:** 2 | **ID:** `praxis/politeia/create-membership-event`

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `event_type` | string | ✓ | Event type: joined, left, removed, invited |
| `oikos_id` | string | ✓ | Oikos where the event occurred |
| `prosopon_id` | string | ✓ | Prosopon affected by the event |
| `prosopon_name` | string |  | Display name at time of event |
| `actor_id` | string |  | Who initiated the action |
| `actor_name` | string |  | Actor display name at time of event |
| `invitation_id` | string |  | Related invitation ID (for join events) |
| `reason` | string |  | Optional reason (for leave/remove events) |

### list-membership-events

List membership events for an oikos.

**Tier:** 1 | **ID:** `praxis/politeia/list-membership-events`

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `oikos_id` | string | ✓ | Oikos to query events for |
| `event_type` | string |  | Filter by event type |
| `max_results` | number |  | Maximum results (default 50) |

### Distribution Operations

### create-distribution-oikos

Create a distribution oikos for a topos-prod.

**Tier:** 2 | **ID:** `praxis/politeia/create-distribution-oikos`

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `topos_prod_id` | string | ✓ | The topos-prod to distribute |
| `oikos_id` | string | ✓ | ID for the distribution oikos |
| `name` | string | ✓ | Human-readable oikos name |
| `distribution_kind` | string | ✓ | Distribution kind: commons (open) or premium (peer-only) |
| `description` | string |  | Oikos description |

### distribute-topos

Distribute a topos-prod through an existing oikos.

**Tier:** 2 | **ID:** `praxis/politeia/distribute-topos`

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `topos_prod_id` | string | ✓ | The topos-prod to distribute |
| `oikos_id` | string | ✓ | The oikos to distribute through |

### list-distributed-topoi

List topoi distributed by an oikos.

**Tier:** 1 | **ID:** `praxis/politeia/list-distributed-topoi`

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `oikos_id` | string | ✓ | The oikos to query |

### list-topos-distributors

List oikoi that distribute a topos.

**Tier:** 1 | **ID:** `praxis/politeia/list-topos-distributors`

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `topos_prod_id` | string | ✓ | The topos-prod to query |

### install-topos

Install a topos from a distribution oikos.

**Tier:** 2 | **ID:** `praxis/politeia/install-topos`

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `topos_prod_id` | string | ✓ | The topos-prod to install |
| `oikos_id` | string |  | The oikos to install for (defaults to dwelling oikos) |

### uninstall-topos

Uninstall a topos from an oikos.

**Tier:** 2 | **ID:** `praxis/politeia/uninstall-topos`

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `topos_prod_id` | string | ✓ | The topos-prod to uninstall |
| `oikos_id` | string |  | The oikos to uninstall from (defaults to dwelling oikos) |

### list-installed-topoi

List topoi installed for an oikos.

**Tier:** 1 | **ID:** `praxis/politeia/list-installed-topoi`

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `oikos_id` | string |  | The oikos to query (defaults to dwelling oikos) |

### Federation Operations

### federate-oikoi

Establish federation between local and remote oikoi.

**Tier:** 3 | **ID:** `praxis/politeia/federate-oikoi`

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `local_oikos_id` | string | ✓ | Local oikos to federate |
| `remote_oikos_id` | string | ✓ | Remote oikos to federate with |
| `remote_pubkey` | string | ✓ | Public key of remote oikos's kosmos |
| `sync_direction` | string |  | push, pull, or bidirectional (default: bidirectional) |
| `eidos_filter` | array |  | Which eide to sync (empty = all reachable) |

### unfederate-oikoi

Dissolve federation between oikoi.

**Tier:** 3 | **ID:** `praxis/politeia/unfederate-oikoi`

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `local_oikos_id` | string | ✓ | Local oikos |
| `remote_oikos_id` | string | ✓ | Remote oikos to unfederate from |

### list-federations

List all federation bonds for an oikos.

**Tier:** 2 | **ID:** `praxis/politeia/list-federations`

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `oikos_id` | string | ✓ | Oikos to list federations for |

### resolve-conflict

Resolve a sync conflict manually.

**Tier:** 2 | **ID:** `praxis/politeia/resolve-conflict`

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `conflict_id` | string | ✓ | ID of the sync-conflict to resolve |
| `resolution` | string | ✓ | Resolution choice: local, remote, or merged |
| `merged_data` | object |  | Custom merged data (required if resolution is merged) |

### list-conflicts

List sync conflicts, optionally filtered by status or oikos.

**Tier:** 2 | **ID:** `praxis/politeia/list-conflicts`

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `oikos_id` | string |  | Filter by oikos (optional) |
| `status` | string |  | Filter by status: open or resolved (default: open) |

### Administrative Operations

### admin-bind

Create a bond directly (administrative utility).

**Tier:** 3 | **ID:** `praxis/politeia/admin-bind`

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `from_id` | string | ✓ | Source entity ID |
| `to_id` | string | ✓ | Target entity ID |
| `desmos` | string | ✓ | Bond type (desmos name) |

### admin-loose

Remove a bond directly (administrative utility).

**Tier:** 3 | **ID:** `praxis/politeia/admin-loose`

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `from_id` | string | ✓ | Source entity ID |
| `to_id` | string | ✓ | Target entity ID |
| `desmos` | string | ✓ | Bond type (desmos name) |

## Desmoi (Bond Types)

| Desmos | From -> To | Description |
|--------|-----------|-------------|
| `child-of` | invitation/membership-event -> oikos | Invitation or event belongs to oikos. |
| `conflicts-on` | sync-conflict -> entity | Sync conflict relates to a specific entity. |
| `distributes` | oikos -> topos-prod | Oikos distributes topos-prod to its members. |
| `dwells-in` | parousia -> oikos | Parousia dwells in oikos. |
| `embodies` | parousia -> prosopon | Parousia embodies prosopon — the dwelling presence of an identity. |
| `enabled-by` | affordance -> attainment | Affordance enabled by attainment — what capability makes it available. |
| `federates-with` | oikos -> oikos | Federation bond — content syncs continuously. |
| `granted-by` | attainment -> oikos | Attainment granted by oikos — inverse tracking for provenance. |
| `grants-attainment` | oikos -> attainment | Oikos grants attainment to its members. |
| `has-attainment` | parousia -> attainment | Parousia has attainment — capability derived from membership. |
| `invited-to` | invitation -> oikos | Invitation invites prosopon to oikos. |
| `member-of` | parousia -> oikos | Parousia is member of oikos. |
| `sovereign-to` | oikos -> parousia | Oikos is sovereign to parousia — governs what it can do. |
| `surfaces-as` | attainment -> affordance | Attainment surfaces as affordance — how capabilities become actionable. |
| `tracks-sync` | sync-cursor -> oikos | Sync cursor tracks position for a federation bond. |

---

*Generated from schema definitions. Do not edit directly.*
