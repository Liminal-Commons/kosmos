# DNS Design

DNS (Domain Name System) — how the kosmos becomes addressable from outside

> **Note:** DNS is a sub-module of thyra, addressing the naming/routing aspect of the boundary. The praxeis live under `praxis/thyra/` namespace.

## Ontological Purpose

DNS addresses **the gap between existence and addressability** — making kosmos entities reachable from the network.

Without DNS:
- Propylons have no addresses
- Thyra instances cannot be found
- Oikos infrastructure is unreachable
- The kosmos is isolated

With DNS:
- **Zones**: Sovereignty boundaries for naming (liminalcommons.com)
- **Records**: Individual address mappings (A, CNAME, TXT, etc.)
- **Provider bindings**: Connection to external DNS services
- **Reconciliation**: Intent aligns with actuality at the provider

The central concept is **dual existence** — a dns-record entity exists in the kosmos (intent), and the actual record exists at the provider (actuality). The reconciler aligns them using the phylax pattern.

## Oikos Context

### Self Oikos

A solitary dweller uses DNS to:
- Point a personal domain to their propylon
- Create TXT records for verification
- Manage records for self-hosted services
- Track provider credentials securely

Personal DNS enables self-sovereign addressing.

### Peer Oikos

Collaborators use DNS to:
- Share zones between oikoi (subdomain delegation)
- Coordinate record management
- Route traffic to shared infrastructure
- Maintain addressing for collaborative services

Peer DNS enables shared infrastructure.

### Commons Oikos

A commons uses DNS to:
- Manage multiple zones for the community
- Delegate subdomains to member oikoi
- Provide central DNS infrastructure
- Audit addressing across the organization

Commons DNS enables organizational naming.

## Core Entities (Eide)

### dns-zone

A managed DNS zone — a sovereignty boundary for naming.

**Fields:**
- `name` — zone name (e.g., liminalcommons.com)
- `status` — active, pending, suspended
- `provider` — cloudflare, route53, manual
- `provider_zone_id` — provider's zone identifier
- `record_count` — cached count of records
- `last_synced_at` — last full sync with provider

**Lifecycle:**
- Arise: create-zone composes zone entity
- Bond: manages-zone links to oikos, provided-by links to credentials
- Change: status transitions, sync timestamps update

### dns-record

A DNS record with dual existence — intent in kosmos, actuality at provider.

**Fields:**
- `record_type` — A, AAAA, CNAME, TXT, MX, SRV, NS, CAA
- `name` — record name (subdomain part)
- `content` — record value (IP, hostname, text)
- `ttl` — time-to-live
- `proxied` — Cloudflare proxy flag
- `desired_state` — present, absent (intent)
- `actual_state` — present, absent, unknown, diverged (actuality)
- `provider_record_id` — provider's identifier
- `last_sensed_at`, `last_reconciled_at` — tracking timestamps
- `divergence` — description of drift when diverged

**Actuality:**
- Mode: dns
- Reconciliation: sense → compare → manifest/unmanifest

### dns-provider-binding

Connection to DNS provider with credential reference.

**Fields:**
- `provider` — cloudflare, route53
- `zone_id` — provider's zone identifier
- `account_id` — provider account
- `credential_ref` — secret reference (secret://... or env://...)
- `endpoint` — custom API endpoint (for testing)
- `status` — active, invalid, suspended

**Security:** Credentials are referenced, never stored in the entity.

## Bonds (Desmoi)

### manages-zone

Oikos has sovereignty over this DNS zone.

- **From:** oikos
- **To:** dns-zone
- **Cardinality:** many-to-many (multiple oikoi can co-manage)
- **Traversal:** Find zones an oikos manages

### in-zone

Record belongs to this zone.

- **From:** dns-record
- **To:** dns-zone
- **Cardinality:** many-to-one (every record in exactly one zone)
- **Traversal:** List records in a zone

### provided-by

Zone connects to provider via this binding.

- **From:** dns-zone
- **To:** dns-provider-binding
- **Cardinality:** one-to-one
- **Traversal:** Get provider credentials for zone

### addresses

Record points to this entity.

- **From:** dns-record
- **To:** any entity
- **Cardinality:** many-to-one (optional)
- **Traversal:** Find what a record addresses

## Operations (Praxeis)

### Zone Operations

- **create-zone**: Create DNS zone managed by dwelling oikos
- **bind-zone-provider**: Connect zone to provider with credentials
- **list-zones**: List zones managed by oikos

### Record Operations

- **create-dns-record**: Create record entity (intent, not yet at provider)
- **delete-dns-record**: Mark record for deletion (desired_state=absent)
- **list-dns-records**: List records in a zone

### Reconciliation Operations

- **sense-dns-record**: Query provider for actual state
- **reconcile-dns-record**: Align intent with actuality (phylax pattern)
- **reconcile-zone**: Bulk reconciliation for all records in zone

## Attainments

### attainment/dns-read

Read-only DNS capability — can list and sense.

- **Grants:** list-zones, list-dns-records, sense-dns-record
- **Scope:** oikos
- **Rationale:** Observing DNS state is safe for any oikos member

### attainment/dns-write

Record management — can create and delete records.

- **Grants:** create-dns-record, delete-dns-record
- **Scope:** oikos
- **Rationale:** Modifying records requires trust within the oikos

### attainment/dns-admin

Zone and infrastructure management.

- **Grants:** create-zone, bind-zone-provider, reconcile-dns-record, reconcile-zone
- **Scope:** oikos
- **Rationale:** Zone management and reconciliation require administrative authority

## Embodiment

### Completeness Status

| Level | Status |
|-------|--------|
| Defined | 3 eide, 4 desmoi, 9 praxeis |
| Loaded | Bootstrap loads all definitions |
| Projected | All praxeis visible as MCP tools |
| Embodied | Partial — zone/record counts in body-schema |
| Surfaced | Future — "5 records need reconciliation" |
| Afforded | Future — record management UI |

### Body-Schema Contribution

When sense-body gathers DNS state:

```yaml
dns:
  zones_managed: 2
  total_records: 47
  records_diverged: 3
  last_reconciled: "2026-01-28T10:30:00Z"
```

This reveals DNS health and reconciliation status.

### Reconciler

A DNS reconciler would surface:

- **Drift detected** — "3 records diverged from intent"
- **Zone inactive** — "Zone suspended at provider"
- **Credentials expiring** — "API token expires in 7 days"
- **Bulk operation needed** — "15 records need reconciliation"

## Compound Leverage

### amplifies propylon

Propylon needs addresses. DNS records point to propylon infrastructure, making entry points reachable.

### amplifies thyra

Thyra instances need addresses. DNS enables external discovery of kosmos boundaries.

### amplifies dynamis

DNS follows the dynamis reconciliation pattern (sense/compare/act). Provider actuality mode enables infrastructure-as-code.

### amplifies politeia

Zone management bonds to oikoi via manages-zone. DNS sovereignty is oikos governance in network form.

## The Phylax Pattern

DNS implements the phylax (φύλαξ — guardian) reconciliation pattern:

```
┌─────────────────────────────────────────────────────────────┐
│  1. SENSE — Query provider API for actual record state       │
│                                                              │
│  2. COMPARE — desired_state (entity) vs actual_state (API)   │
│                                                              │
│  3. RECONCILE                                                │
│     ├─▶ desired=present, actual=absent → MANIFEST (create)   │
│     ├─▶ desired=absent, actual=present → UNMANIFEST (delete) │
│     └─▶ desired=present, actual=diverged → UPDATE            │
└─────────────────────────────────────────────────────────────┘
```

This pattern generalizes to any infrastructure-as-code scenario.

## Theoria

### T67: DNS makes the kosmos addressable from outside

Without DNS, the kosmos is isolated — entities exist but cannot be reached from the network. DNS bridges the gap between existence and addressability. It's how the kosmos becomes reachable.

### T68: Infrastructure sovereignty extends to naming

Just as oikoi govern their members and attainments, they govern their naming. Zone management is sovereignty. Subdomain delegation is federation. The manages-zone bond makes this explicit.

### T69: Zone management is oikos governance in network form

The pattern is identical: an oikos manages-zone as it manages-membership. Zone delegation between oikoi mirrors oikos federation. Network topology follows governance topology.

## Security Considerations

### Credential Management

Credentials are NEVER stored in entities. The `credential_ref` field references external storage:

```yaml
credential_ref: secret://cloudflare-api-token
# or
credential_ref: env://CLOUDFLARE_API_TOKEN
```

The dynamis layer resolves these at runtime.

### Rate Limiting

Provider APIs have rate limits. Bulk reconciliation should be throttled to avoid API errors.

### Audit Trail

All DNS operations should create audit entries tracking actor, timestamp, and result.

## Future Extensions

### Bulk Import

Import existing DNS records from provider into kosmos (discover actuality, create intent).

### External Change Detection

Webhook-based detection of provider changes outside kosmos (mark as diverged).

### Zone Transfer

Multi-party consent protocol for transferring zone management between oikoi.

### DNSSEC

Key management for DNS security extensions.

---

*Composed in service of the kosmogonia.*
*DNS makes the kosmos addressable. Naming is governance. Sovereignty extends to infrastructure.*
