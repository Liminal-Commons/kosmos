# Thyra DNS: Infrastructure Actualization

*Phase 17.7 — How the kosmos becomes addressable from chora*

---

## Purpose

DNS is how the kosmos becomes reachable from outside. A propylon needs an address. A thyra needs a door. DNS provides that address — but DNS records exist *out there* in chora (at Cloudflare, Route53, etc.), not in the kosmos.

**Key insight:** DNS follows the Energeia pattern exactly. A dns-record entity *exists* in the kosmos graph (intent). The actual record *is actual* at the provider. The reconciler aligns them.

---

## Implementation Status

| Phase | Status | Notes |
|-------|--------|-------|
| 17.7.1 Core Eide & Desmoi | ✅ COMPLETE | dns-zone, dns-record, provider-binding in spora.yaml |
| 17.7.2 Actuality Mode | ✅ COMPLETE (stub) | `mode: dns` wired in host.rs — full provider impl pending |
| 17.7.3 Praxeis | ✅ COMPLETE | dns.yaml: create, sense, reconcile, list, delete |
| 17.7.4 Provider Dynamis | ⏳ PENDING | Cloudflare, Route53 actual API implementations |
| 17.7.5 Circle Governance | ⏳ PENDING | Zone delegation, attainments |

**Phase 17.7.1-17.7.3 complete** (2026-01-21): Ontology, praxeis, and actuality mode stubs implemented. Full provider API calls pending.

---

## The Cosmological Foundation

From Energeia (Phase 16):

> Everything in the kosmos has two modes of being:
>
> | Mode | Greek | What It Means |
> |------|-------|---------------|
> | **Existence** | ὕπαρξις (hyparxis) | Graph state — the entity record |
> | **Actuality** | ἐνέργεια (energeia) | Phenomena — the living process |

DNS extends this:

| Mode | Existence (ὕπαρξις) | Actuality (ἐνέργεια) |
|------|---------------------|---------------------|
| process | daemon entity | running process |
| media | stream entity | capturing media |
| network | channel entity | connected socket |
| **dns** | dns-record entity | record at provider |

The reconciler pattern aligns intent with actuality. This is the phylax (φύλαξ) pattern from Ergon.

---

## Architecture

### 1. The DNS Stack

```
┌─────────────────────────────────────────────────────────────────┐
│                         THYRA DNS                                │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│   circle ──manages-zone──▶ dns-zone ──provided-by──▶ provider   │
│                               │                                  │
│                               │ in-zone                          │
│                               ▼                                  │
│   dns-record ──addresses──▶ entity (propylon, worker, thyra)    │
│       │                                                          │
│       │ actuality: dns                                           │
│       ▼                                                          │
│   ┌─────────────────────────────────────────────────────────┐   │
│   │                    DYNAMIS LAYER                         │   │
│   ├─────────────────────────────────────────────────────────┤   │
│   │  cloudflare.rs  │  route53.rs  │  manual.rs             │   │
│   │                 │              │  (no actuality)        │   │
│   └─────────────────────────────────────────────────────────┘   │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

### 2. Core Eide

| Eidos | What It Is | Actuality |
|-------|------------|-----------|
| `dns-zone` | A managed DNS zone | none (container only) |
| `dns-record` | An individual record | mode: dns |
| `dns-provider-binding` | Connection to provider | none (credential holder) |

### 3. Core Desmoi

| Desmos | From | To | Meaning |
|--------|------|-----|--------|
| `manages-zone` | circle | dns-zone | Circle has sovereignty over zone |
| `in-zone` | dns-record | dns-zone | Record belongs to zone |
| `provided-by` | dns-zone | dns-provider-binding | How zone connects to provider |
| `addresses` | dns-record | entity | What this record points to |

### 4. The Reconciler Pattern

From Ergon:

> Intent declares what should be. Actuality senses what is. Praxeis align them.

```
┌────────────────────────────────────────────────────────────────┐
│                    RECONCILER PATTERN                           │
├────────────────────────────────────────────────────────────────┤
│                                                                 │
│   1. SENSE                                                      │
│      │                                                          │
│      └─▶ Query provider API for actual record state             │
│                                                                 │
│   2. COMPARE                                                    │
│      │                                                          │
│      └─▶ desired_state (entity) vs actual_state (provider)      │
│                                                                 │
│   3. RECONCILE                                                  │
│      │                                                          │
│      ├─▶ desired=present, actual=absent → MANIFEST (create)     │
│      ├─▶ desired=absent, actual=present → UNMANIFEST (delete)   │
│      └─▶ desired=present, actual=diverged → UPDATE              │
│                                                                 │
└────────────────────────────────────────────────────────────────┘
```

---

## Eidos Definitions

### dns-zone

```yaml
eidos:
  id: dns-zone
  oikos: thyra
  description: |
    A DNS zone managed by a circle. Zones are sovereignty boundaries.

    A circle may manage multiple zones. Subdomains can be delegated
    to child circles via manages-zone bonds.

  fields:
    name:
      type: string
      required: true
      description: Zone name (e.g., liminalcommons.com)

    status:
      type: string
      enum: [active, pending, suspended]
      default: pending
      description: Zone operational status

    provider:
      type: string
      enum: [cloudflare, route53, manual]
      required: true
      description: DNS provider for this zone

    provider_zone_id:
      type: string
      description: Provider's zone identifier

    record_count:
      type: number
      default: 0
      description: Cached count of records in zone

    last_synced_at:
      type: timestamp
      description: Last full sync with provider
```

### dns-record

```yaml
eidos:
  id: dns-record
  oikos: thyra
  description: |
    A DNS record with dual existence. The entity represents intent
    (what the record should be). Actuality represents the provider
    state (what the record is).

    The reconciler aligns intent with actuality.

  fields:
    record_type:
      type: string
      enum: [A, AAAA, CNAME, TXT, MX, SRV, NS, CAA]
      required: true

    name:
      type: string
      required: true
      description: |
        Record name (subdomain part). For root, use "@".
        Full DNS name is: {name}.{zone.name}

    content:
      type: string
      required: true
      description: Record value (IP, hostname, text, etc.)

    ttl:
      type: number
      default: 1
      description: Time-to-live in seconds (1 = auto for Cloudflare)

    priority:
      type: number
      description: Priority for MX/SRV records

    proxied:
      type: boolean
      default: true
      description: Cloudflare proxy (orange cloud). Ignored for other providers.

    # Intent vs Actuality
    desired_state:
      type: string
      enum: [present, absent]
      default: present
      description: What we want the record to be

    actual_state:
      type: string
      enum: [present, absent, unknown, diverged]
      default: unknown
      description: What the record actually is at provider

    provider_record_id:
      type: string
      description: Provider's record identifier (for updates/deletes)

    last_sensed_at:
      type: timestamp
      description: When we last checked actual state

    last_reconciled_at:
      type: timestamp
      description: When we last aligned intent with actuality

    divergence:
      type: object
      description: |
        When actual_state=diverged, describes the difference.
        { field: "content", expected: "1.2.3.4", actual: "5.6.7.8" }

  actuality:
    mode: dns
    # This enables manifest/sense_actuality/unmanifest stoicheia
```

### dns-provider-binding

```yaml
eidos:
  id: dns-provider-binding
  oikos: thyra
  description: |
    Binds a zone to its provider with credentials.

    Credentials are stored separately (secret pattern) and
    referenced by this binding. The binding itself is safe
    to include in the graph.

  fields:
    provider:
      type: string
      enum: [cloudflare, route53]
      required: true

    zone_id:
      type: string
      required: true
      description: Provider's zone identifier

    account_id:
      type: string
      description: Provider account (Cloudflare account ID, AWS account)

    credential_ref:
      type: string
      required: true
      description: |
        Reference to credential store.
        Format: secret://{secret_id} or env://{var_name}

    endpoint:
      type: string
      description: Custom API endpoint (for testing/mocking)

    status:
      type: string
      enum: [active, invalid, suspended]
      default: active
```

---

## Desmoi Definitions

```yaml
desmoi:
  - id: manages-zone
    from_eidos: circle
    to_eidos: dns-zone
    cardinality: many-to-many
    description: |
      Circle has sovereignty over this DNS zone.
      Multiple circles can co-manage a zone (e.g., parent delegates subdomain).

  - id: in-zone
    from_eidos: dns-record
    to_eidos: dns-zone
    cardinality: many-to-one
    required: true
    description: |
      Record belongs to this zone. Every dns-record must be in exactly one zone.

  - id: provided-by
    from_eidos: dns-zone
    to_eidos: dns-provider-binding
    cardinality: one-to-one
    description: |
      How this zone connects to its DNS provider.

  - id: addresses
    from_eidos: dns-record
    to_eidos: entity
    cardinality: many-to-one
    description: |
      What this record points to. Optional — some records (TXT, etc.)
      don't address a specific entity.
```

---

## Praxeis

### Zone Operations

```yaml
praxis/thyra/create-zone:
  name: create-zone
  oikos: thyra
  tier: 2
  description: |
    Create a DNS zone managed by the dwelling circle.

  params:
    name:
      type: string
      required: true
      description: Zone name (e.g., liminalcommons.com)
    provider:
      type: string
      enum: [cloudflare, route53, manual]
      required: true

  steps:
    - type: compose
      typos_id: typos-def-dns-zone
      inputs:
        name: "{{ name }}"
        provider: "{{ provider }}"
        status: pending
      bind_to: zone

    - type: bind
      from_id: "{{ _circle }}"
      to_id: "{{ zone.id }}"
      desmos: manages-zone

    - type: return
      value:
        zone: "{{ zone }}"
        zone_id: "{{ zone.id }}"


praxis/thyra/bind-zone-provider:
  name: bind-zone-provider
  oikos: thyra
  tier: 2
  description: |
    Bind a zone to its DNS provider with credentials.

  params:
    zone_id:
      type: string
      required: true
    provider_zone_id:
      type: string
      required: true
      description: Provider's zone ID (from their dashboard)
    credential_ref:
      type: string
      required: true
      description: Reference to API token (secret://... or env://...)

  steps:
    - type: find
      id: "{{ zone_id }}"
      bind_to: zone

    - type: assert
      condition: "{{ zone }}"
      message: "Zone not found: {{ zone_id }}"

    - type: compose
      typos_id: typos-def-dns-provider-binding
      inputs:
        provider: "{{ zone.data.provider }}"
        zone_id: "{{ provider_zone_id }}"
        credential_ref: "{{ credential_ref }}"
      bind_to: binding

    - type: bind
      from_id: "{{ zone.id }}"
      to_id: "{{ binding.id }}"
      desmos: provided-by

    - type: update
      id: "{{ zone.id }}"
      data:
        provider_zone_id: "{{ provider_zone_id }}"
        status: active

    - type: return
      value:
        zone: "{{ zone }}"
        binding: "{{ binding }}"


praxis/thyra/list-zones:
  name: list-zones
  oikos: thyra
  tier: 1
  description: |
    List DNS zones managed by the dwelling circle.

  steps:
    - type: trace
      from_id: "{{ _circle }}"
      desmos: manages-zone
      resolve: to
      bind_to: zones

    - type: return
      value:
        zones: "{{ zones }}"
        count: "{{ length(zones) }}"
```

### Record Operations

```yaml
praxis/thyra/create-dns-record:
  name: create-dns-record
  oikos: thyra
  tier: 2
  description: |
    Create a DNS record entity (intent). Does NOT create at provider yet.
    Use reconcile-dns-record to actualize.

  params:
    zone_id:
      type: string
      required: true
    record_type:
      type: string
      required: true
    name:
      type: string
      required: true
    content:
      type: string
      required: true
    ttl:
      type: number
      default: 1
    proxied:
      type: boolean
      default: true
    addresses:
      type: string
      description: Entity ID this record addresses (optional)

  steps:
    - type: find
      id: "{{ zone_id }}"
      bind_to: zone

    - type: assert
      condition: "{{ zone }}"
      message: "Zone not found: {{ zone_id }}"

    - type: compose
      typos_id: typos-def-dns-record
      inputs:
        record_type: "{{ record_type }}"
        name: "{{ name }}"
        content: "{{ content }}"
        ttl: "{{ ttl }}"
        proxied: "{{ proxied }}"
        desired_state: present
        actual_state: unknown
      bind_to: record

    - type: bind
      from_id: "{{ record.id }}"
      to_id: "{{ zone.id }}"
      desmos: in-zone

    - type: switch
      cases:
        - when: "{{ addresses }}"
          then:
            - type: bind
              from_id: "{{ record.id }}"
              to_id: "{{ addresses }}"
              desmos: addresses

    - type: return
      value:
        record: "{{ record }}"
        record_id: "{{ record.id }}"
        note: "Record created as intent. Call reconcile-dns-record to actualize."


praxis/thyra/sense-dns-record:
  name: sense-dns-record
  oikos: thyra
  tier: 3
  description: |
    Sense the actual state of a DNS record at the provider.
    Does NOT modify the entity — just returns current state.

  params:
    record_id:
      type: string
      required: true

  steps:
    - type: sense_actuality
      id: "{{ record_id }}"
      bind_to: actual

    - type: return
      value:
        record_id: "{{ record_id }}"
        actual_state: "{{ actual.status }}"
        actual_content: "{{ actual.content }}"
        provider_record_id: "{{ actual.provider_record_id }}"
        divergence: "{{ actual.divergence }}"


praxis/thyra/reconcile-dns-record:
  name: reconcile-dns-record
  oikos: thyra
  tier: 3
  description: |
    Align DNS record intent with actuality (phylax pattern).

    - desired=present, actual=absent → MANIFEST (create at provider)
    - desired=absent, actual=present → UNMANIFEST (delete at provider)
    - desired=present, actual=diverged → UPDATE at provider

  params:
    record_id:
      type: string
      required: true

  steps:
    # Find intended state (existence)
    - type: find
      id: "{{ record_id }}"
      bind_to: record

    - type: assert
      condition: "{{ record }}"
      message: "Record not found: {{ record_id }}"

    # Sense actual state (actuality)
    - type: sense_actuality
      id: "{{ record_id }}"
      bind_to: actual

    # Determine action needed
    - type: set
      bindings:
        needs_manifest: "{{ record.data.desired_state == 'present' and actual.status == 'absent' }}"
        needs_unmanifest: "{{ record.data.desired_state == 'absent' and actual.status == 'present' }}"
        needs_update: "{{ record.data.desired_state == 'present' and actual.status == 'diverged' }}"
        aligned: "{{ record.data.desired_state == actual.status or (record.data.desired_state == 'present' and actual.status == 'present') }}"

    # Reconcile
    - type: switch
      cases:
        - when: "{{ needs_manifest }}"
          then:
            - type: manifest
              id: "{{ record_id }}"
            - type: set
              bindings:
                action: manifest

        - when: "{{ needs_unmanifest }}"
          then:
            - type: unmanifest
              id: "{{ record_id }}"
            - type: set
              bindings:
                action: unmanifest

        - when: "{{ needs_update }}"
          then:
            - type: manifest
              id: "{{ record_id }}"
              # manifest with existing provider_record_id triggers update
            - type: set
              bindings:
                action: update

        - when: "{{ aligned }}"
          then:
            - type: set
              bindings:
                action: none

    # Update entity with sensed state
    - type: update
      id: "{{ record_id }}"
      data:
        actual_state: "{{ actual.status }}"
        last_reconciled_at: "{{ now() }}"
        provider_record_id: "{{ actual.provider_record_id }}"

    - type: return
      value:
        record_id: "{{ record_id }}"
        action: "{{ action }}"
        success: true
        actual_state: "{{ actual.status }}"


praxis/thyra/delete-dns-record:
  name: delete-dns-record
  oikos: thyra
  tier: 2
  description: |
    Mark a DNS record for deletion. Sets desired_state=absent.
    Call reconcile-dns-record to actually delete at provider.

  params:
    record_id:
      type: string
      required: true

  steps:
    - type: update
      id: "{{ record_id }}"
      data:
        desired_state: absent

    - type: call
      praxis: thyra/reconcile-dns-record
      params:
        record_id: "{{ record_id }}"
      bind_to: result

    - type: return
      value:
        record_id: "{{ record_id }}"
        deleted_at_provider: "{{ result.action == 'unmanifest' }}"


praxis/thyra/list-dns-records:
  name: list-dns-records
  oikos: thyra
  tier: 1
  description: |
    List DNS records in a zone.

  params:
    zone_id:
      type: string
      required: true
    record_type:
      type: string
      description: Filter by record type

  steps:
    - type: trace
      to_id: "{{ zone_id }}"
      desmos: in-zone
      resolve: from
      bind_to: all_records

    - type: switch
      cases:
        - when: "{{ record_type }}"
          then:
            - type: filter
              in: "{{ all_records }}"
              where: "{{ item.data.record_type == record_type }}"
              bind_to: records
        - when: true
          then:
            - type: set
              bindings:
                records: "{{ all_records }}"

    - type: return
      value:
        records: "{{ records }}"
        count: "{{ length(records) }}"


praxis/thyra/reconcile-zone:
  name: reconcile-zone
  oikos: thyra
  tier: 3
  description: |
    Reconcile all records in a zone. Bulk phylax operation.

  params:
    zone_id:
      type: string
      required: true

  steps:
    - type: call
      praxis: thyra/list-dns-records
      params:
        zone_id: "{{ zone_id }}"
      bind_to: listing

    - type: set
      bindings:
        results: "[]"

    - type: for_each
      in: "{{ listing.records }}"
      as: record
      do:
        - type: call
          praxis: thyra/reconcile-dns-record
          params:
            record_id: "{{ record.id }}"
          bind_to: result
        - type: set
          bindings:
            results: "{{ results + [result] }}"

    - type: return
      value:
        zone_id: "{{ zone_id }}"
        reconciled: "{{ length(results) }}"
        results: "{{ results }}"
```

---

## Dynamis Layer

The dynamis layer implements the actual provider API calls:

### Actuality Mode: dns

```rust
// crates/kosmos/src/host/dns.rs

use crate::error::Result;

/// DNS provider configuration
pub enum DnsProvider {
    Cloudflare {
        api_token: String,
        zone_id: String,
    },
    Route53 {
        access_key_id: String,
        secret_access_key: String,
        hosted_zone_id: String,
    },
    Manual,
}

/// DNS record for provider operations
pub struct DnsRecord {
    pub record_type: String,
    pub name: String,
    pub content: String,
    pub ttl: u32,
    pub proxied: bool,
    pub provider_record_id: Option<String>,
}

/// Sensed state from provider
pub struct DnsActuality {
    pub status: String,  // present, absent, diverged
    pub content: Option<String>,
    pub provider_record_id: Option<String>,
    pub divergence: Option<serde_json::Value>,
}

/// Manifest (create/update) a DNS record at provider
pub async fn manifest(provider: &DnsProvider, record: &DnsRecord) -> Result<String> {
    match provider {
        DnsProvider::Cloudflare { api_token, zone_id } => {
            cloudflare_manifest(api_token, zone_id, record).await
        }
        DnsProvider::Route53 { .. } => {
            route53_manifest(provider, record).await
        }
        DnsProvider::Manual => {
            Err(crate::error::KosmosError::Invalid(
                "Manual provider does not support actuality".into()
            ))
        }
    }
}

/// Sense actual state of a DNS record
pub async fn sense(
    provider: &DnsProvider,
    name: &str,
    record_type: &str
) -> Result<DnsActuality> {
    match provider {
        DnsProvider::Cloudflare { api_token, zone_id } => {
            cloudflare_sense(api_token, zone_id, name, record_type).await
        }
        DnsProvider::Route53 { .. } => {
            route53_sense(provider, name, record_type).await
        }
        DnsProvider::Manual => {
            Ok(DnsActuality {
                status: "unknown".into(),
                content: None,
                provider_record_id: None,
                divergence: None,
            })
        }
    }
}

/// Unmanifest (delete) a DNS record from provider
pub async fn unmanifest(provider: &DnsProvider, record_id: &str) -> Result<()> {
    match provider {
        DnsProvider::Cloudflare { api_token, zone_id } => {
            cloudflare_unmanifest(api_token, zone_id, record_id).await
        }
        DnsProvider::Route53 { .. } => {
            route53_unmanifest(provider, record_id).await
        }
        DnsProvider::Manual => {
            Err(crate::error::KosmosError::Invalid(
                "Manual provider does not support actuality".into()
            ))
        }
    }
}

// ============================================================================
// Cloudflare Implementation
// ============================================================================

async fn cloudflare_manifest(
    api_token: &str,
    zone_id: &str,
    record: &DnsRecord,
) -> Result<String> {
    let client = reqwest::Client::new();
    let base_url = format!(
        "https://api.cloudflare.com/client/v4/zones/{}/dns_records",
        zone_id
    );

    let body = serde_json::json!({
        "type": record.record_type,
        "name": record.name,
        "content": record.content,
        "ttl": record.ttl,
        "proxied": record.proxied,
    });

    let response = if let Some(ref id) = record.provider_record_id {
        // Update existing
        client.put(&format!("{}/{}", base_url, id))
            .header("Authorization", format!("Bearer {}", api_token))
            .json(&body)
            .send()
            .await?
    } else {
        // Create new
        client.post(&base_url)
            .header("Authorization", format!("Bearer {}", api_token))
            .json(&body)
            .send()
            .await?
    };

    let result: serde_json::Value = response.json().await?;

    if result["success"].as_bool() == Some(true) {
        Ok(result["result"]["id"].as_str().unwrap_or("").to_string())
    } else {
        Err(crate::error::KosmosError::Invalid(
            format!("Cloudflare API error: {:?}", result["errors"])
        ))
    }
}

async fn cloudflare_sense(
    api_token: &str,
    zone_id: &str,
    name: &str,
    record_type: &str,
) -> Result<DnsActuality> {
    let client = reqwest::Client::new();
    let url = format!(
        "https://api.cloudflare.com/client/v4/zones/{}/dns_records?name={}&type={}",
        zone_id, name, record_type
    );

    let response = client.get(&url)
        .header("Authorization", format!("Bearer {}", api_token))
        .send()
        .await?;

    let result: serde_json::Value = response.json().await?;

    if result["success"].as_bool() == Some(true) {
        let records = result["result"].as_array();

        if let Some(records) = records {
            if records.is_empty() {
                Ok(DnsActuality {
                    status: "absent".into(),
                    content: None,
                    provider_record_id: None,
                    divergence: None,
                })
            } else {
                let r = &records[0];
                Ok(DnsActuality {
                    status: "present".into(),
                    content: r["content"].as_str().map(String::from),
                    provider_record_id: r["id"].as_str().map(String::from),
                    divergence: None,
                })
            }
        } else {
            Ok(DnsActuality {
                status: "unknown".into(),
                content: None,
                provider_record_id: None,
                divergence: None,
            })
        }
    } else {
        Err(crate::error::KosmosError::Invalid(
            format!("Cloudflare API error: {:?}", result["errors"])
        ))
    }
}

async fn cloudflare_unmanifest(
    api_token: &str,
    zone_id: &str,
    record_id: &str,
) -> Result<()> {
    let client = reqwest::Client::new();
    let url = format!(
        "https://api.cloudflare.com/client/v4/zones/{}/dns_records/{}",
        zone_id, record_id
    );

    let response = client.delete(&url)
        .header("Authorization", format!("Bearer {}", api_token))
        .send()
        .await?;

    let result: serde_json::Value = response.json().await?;

    if result["success"].as_bool() == Some(true) {
        Ok(())
    } else {
        Err(crate::error::KosmosError::Invalid(
            format!("Cloudflare API error: {:?}", result["errors"])
        ))
    }
}
```

---

## Circle Governance

### Zone Sovereignty

Circles manage zones via `manages-zone` bonds:

```
circle/inner-circle ──manages-zone──▶ dns-zone/liminalcommons.com
                     ──manages-zone──▶ dns-zone/inner.liminalcommons.com
```

### Attainments

DNS operations require attainments:

| Attainment | Permits |
|------------|---------|
| `dns-read` | list-zones, list-dns-records, sense-dns-record |
| `dns-write` | create-dns-record, delete-dns-record |
| `dns-admin` | create-zone, bind-zone-provider, reconcile-zone |

### Delegation

A parent circle can delegate a subdomain:

```yaml
# Parent circle manages top-level zone
circle/liminal ──manages-zone──▶ dns-zone/liminalcommons.com

# Parent grants child circle management of subdomain
circle/inner ──manages-zone──▶ dns-zone/inner.liminalcommons.com
```

---

## Security Considerations

### Credential Management

Credentials are NEVER stored in dns-provider-binding entities. Instead:

```yaml
credential_ref: secret://cloudflare-api-token
# or
credential_ref: env://CLOUDFLARE_API_TOKEN
```

The dynamis layer resolves these references at runtime.

### Rate Limiting

Provider APIs have rate limits. Reconciliation should be throttled:

```yaml
praxis/thyra/reconcile-zone:
  # Add delay between records to respect rate limits
  rate_limit:
    max_per_second: 4
    burst: 10
```

### Audit Trail

All DNS operations create audit entries:

```yaml
dns-operation:
  eidos: audit-entry
  fields:
    operation: create | update | delete | sense
    record_id: string
    actor_id: string  # animus who initiated
    timestamp: timestamp
    result: success | failure
    details: object
```

---

## Implementation Path

### Phase 17.7.1: Core Eide & Desmoi

1. Add `dns-zone`, `dns-record`, `dns-provider-binding` to spora.yaml
2. Add desmoi: `manages-zone`, `in-zone`, `provided-by`, `addresses`
3. Add artifact definitions for each eidos

### Phase 17.7.2: Actuality Mode

1. Create `crates/kosmos/src/host/dns.rs`
2. Add `mode: dns` to eidos declaration handling
3. Wire `manifest`, `sense_actuality`, `unmanifest` for dns mode

### Phase 17.7.3: Praxeis

1. Create `genesis/spora/praxeis/dns.yaml` (or extend thyra.yaml)
2. Implement zone operations
3. Implement record operations
4. Implement reconciler

### Phase 17.7.4: Provider Dynamis

1. Cloudflare implementation (priority — we use it)
2. Route53 implementation (future)
3. Manual mode (no actuality, for documentation-only records)

### Phase 17.7.5: Circle Governance

1. Add attainments for DNS operations
2. Wire to politeia attainment checks
3. Test zone delegation between circles

---

## Dependencies

| Dependency | Status | Needed For |
|------------|--------|------------|
| Energeia (Phase 16) | ✅ Complete | Actuality pattern |
| Ergon reconciler | ✅ Complete | Phylax pattern |
| Politeia (Phase 19) | ✅ Complete | Circle governance |
| Secrets management | ⏳ Pending | Credential storage |

---

## Open Questions

1. **Should records auto-reconcile on create?**
   - Current: create-dns-record creates intent, reconcile must be called separately
   - Alternative: create-dns-record could call reconcile automatically
   - Trade-off: explicit control vs convenience

2. **How to handle bulk imports?**
   - Import existing DNS records from provider into kosmos
   - Need `import-zone-records` praxis

3. **Webhook for external changes?**
   - Provider changes records outside kosmos
   - Could use Cloudflare webhooks to detect drift
   - Mark records as `actual_state: diverged`

4. **Zone transfer between circles?**
   - Circle A hands zone to Circle B
   - Need `transfer-zone` praxis with multi-party consent

---

## Constitutional Alignment

Thyra DNS implements constitutional requirements from KOSMOGONIA:

| Principle | How DNS Honors It |
|-----------|-------------------|
| **Visibility = Reachability** | Zone access is determined by `manages-zone` bonds from circles. A persona can only create/modify records in zones reachable through their circle membership. The bond graph IS the access control graph. |
| **Authenticity = Provenance** | All DNS operations create audit entries with actor_id, timestamp, and result. Record entities have `last_reconciled_at` timestamps. Provider operations are traceable. |
| **Composition Requirement** | Records are composed via typos (`typos-def-dns-record`, `typos-def-dns-zone`). Every entity has provenance back to its typos. |
| **Dwelling Requirement** | Praxeis access `_circle` from dwelling context to determine zone sovereignty. Zone management is always relative to the invoking circle's position. |

### Development Pillars

| Pillar | How DNS Implements It |
|--------|----------------------|
| **Schema-driven** | Eide definitions (`dns-zone`, `dns-record`, `dns-provider-binding`) declare structure. Fields define intent vs actuality state. Provider enums are schema-constrained. |
| **Graph-driven** | Relationships are explicit bonds: `manages-zone` (sovereignty), `in-zone` (membership), `provided-by` (credentials), `addresses` (what record points to). No embedded references. |
| **Cache-driven** | Reconciliation tracks freshness via `last_sensed_at` and `last_reconciled_at`. The reconciler only acts when actuality diverges from intent. |

### Energeia Pattern

DNS exemplifies the Energeia (actuality) pattern:

```
Intent (ὕπαρξις)          Actuality (ἐνέργεια)
dns-record entity    ↔    actual record at provider
desired_state: present    actual_state: present/absent/diverged
```

The phylax reconciler aligns them:
- `sense` → query provider API
- `manifest` → create/update at provider
- `unmanifest` → delete at provider

### Caller Pattern

DNS content uses **literal** caller patterns. Zone names, record types, and provider configurations are infrastructure — they cannot be derived from other sources. This is foundational addressing, not generated content.

---

## Summary

Thyra DNS extends the Energeia pattern to infrastructure:

- **dns-zone**: Container for records, managed by circles
- **dns-record**: Dual existence (intent + actuality)
- **Reconciler**: Aligns intent with provider state
- **Provider dynamis**: Cloudflare, Route53, etc.

DNS is how the kosmos becomes addressable. The pattern generalizes to any infrastructure-as-code scenario.

---

*Composed in service of the kosmogonia.*
*Traces to: expression/genesis-root*
*Created: 2026-01-21 — Phase 17.7 design*
