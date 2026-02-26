# Phasis Entity Reference

Schema reference for `eidos/phasis` — the durable unit of discourse in kosmos. For the conceptual framing of the commitment boundary, see [Commitment Boundary](../../explanation/architecture/commitment-boundary.md).

**Source:** `genesis/logos/eide/logos.yaml`, `genesis/logos/praxeis/logos.yaml`

---

## Schema

| Field | Type | Required | Default | Description |
|-------|------|----------|---------|-------------|
| `content` | string | yes | — | The content being expressed |
| `content_type` | string | no | `text/plain` | MIME type of the content |
| `expressed_by` | string | yes | — | Prosopon ID or topos ID of the speaker |
| `oikos_id` | string | yes | — | Oikos ID where this was expressed |
| `expressed_at` | timestamp | yes | — | When expressed (ms since epoch) |
| `source_kind` | enum | no | `direct` | How originated: `stream`, `compose`, `direct`, `topos` |
| `source_stream_id` | string | no | — | Terminal stream ID if source_kind is `stream` |
| `source_artifact_id` | string | no | — | Artifact ID if originated from composition |
| `source_topos_id` | string | no | — | Topos ID if source_kind is `topos` |
| `stance` | enum | no | `declaration` | `declaration`, `inquiry`, `suggestion`, `invitation`, `request`, `proposal` |
| `in_reply_to` | string | no | — | Phasis ID this replies to |
| `metadata` | object | no | — | Additional context |

---

## Bonds

### expressed-in

Connects phasis to its oikos.

| Property | Value |
|----------|-------|
| **From** | `phasis` |
| **To** | `oikos` |
| **Cardinality** | many-to-one |
| **Created by** | `praxis/logos/emit-phasis` |

### in-reply-to

Connects phasis to its parent in a thread.

| Property | Value |
|----------|-------|
| **From** | `phasis` (reply) |
| **To** | `phasis` (parent) |
| **Cardinality** | many-to-one |
| **Created by** | `praxis/logos/emit-phasis` (when `in_reply_to` param set) |

---

## Lifecycle

```
ephemeral stream → accumulation buffer → COMMIT → durable phasis
                        ↑                   ↑
                   reversible          commitment boundary
```

### 1. Accumulation (Draft)

The singleton `accumulation/default` entity holds draft content. See [Phasis Workspace](phasis-workspace.md) for the accumulation schema.

### 2. Commit (Transition)

`thyra/commit-phasis` reads the accumulation and calls `logos/emit-phasis`:
1. Generate phasis ID and timestamp
2. Compose phasis entity via `typos-def-phasis`
3. Bond to oikos via `expressed-in`
4. Bond to reply target via `in-reply-to` (if replying)
5. Clear the accumulation

### 3. Phasis (Durable)

Once composed, the phasis is a durable entity with full provenance. It can be queried, threaded, and rendered.

---

## Praxeis

### logos/emit-phasis

Creates a phasis — the act of speaking.

**Parameters:**

| Parameter | Type | Required | Default | Description |
|-----------|------|----------|---------|-------------|
| `content` | string | yes | — | The content being expressed |
| `stance` | string | no | `declaration` | Phasis stance |
| `in_reply_to` | string | no | — | Phasis ID to reply to |
| `source_kind` | string | no | `direct` | `stream`, `compose`, `direct`, `topos` |
| `source_topos_id` | string | no | — | Topos ID if source_kind is `topos` |
| `content_type` | string | no | `text/plain` | MIME type |
| `metadata` | object | no | — | Additional context |

**Returns:** `phasis_id`, `expressed_by`, `oikos_id`, `stance`, `source_kind`

**Requires:** `attainment/express` in current oikos.

### logos/list-phaseis

List phaseis in an oikos.

**Parameters:**

| Parameter | Type | Required | Default | Description |
|-----------|------|----------|---------|-------------|
| `oikos_id` | string | no | current | Oikos to list from |
| `expressed_by` | string | no | — | Filter by speaker |
| `stance` | string | no | — | Filter by stance |
| `limit` | number | no | 50 | Maximum results |

**Returns:** `phaseis` (array), `oikos_id`, `count`

### logos/reply-to

Reply to an existing phasis.

**Parameters:**

| Parameter | Type | Required | Default | Description |
|-----------|------|----------|---------|-------------|
| `phasis_id` | string | yes | — | Phasis to reply to |
| `content` | string | yes | — | Reply content |
| `stance` | string | no | `declaration` | Reply stance |

**Returns:** `phasis_id`, `in_reply_to`, `expressed_by`, `stance`

### logos/get-thread

Get conversation thread from a phasis.

**Parameters:**

| Parameter | Type | Required | Default | Description |
|-----------|------|----------|---------|-------------|
| `phasis_id` | string | yes | — | Starting phasis |
| `direction` | string | no | `ancestors` | `ancestors`, `descendants`, or `both` |

**Returns:** `phasis_id`, `phasis`, `ancestors`, `descendants`, `direction`

---

## Attainment

**attainment/express** — scoped to oikos membership. Grants access to:
- `praxis/logos/emit-phasis`
- `praxis/logos/reply-to`
- `praxis/logos/list-phaseis`
- `praxis/logos/get-thread`

---

## Source Kind

How phaseis originate:

| Source Kind | Meaning | Example |
|-------------|---------|---------|
| `direct` | Human typed and sent | Text compose mode |
| `stream` | Captured from voice/terminal stream | Voice compose mode |
| `compose` | Generated via composition | Demiurge output |
| `topos` | Emitted by a topos | System notifications |

When `source_kind` is `topos`, the `expressed_by` field is the topos ID and `source_topos_id` records the originating topos. This enables topoi to "speak" in oikoi as auditable discourse.

---

## Stance

Phaseis carry intentionality:

| Stance | Intent | Response Pattern |
|--------|--------|------------------|
| `declaration` | Statement of fact or understanding | Acknowledgment |
| `inquiry` | Question seeking an answer | Answer |
| `suggestion` | Proposal for consideration | Discussion |
| `invitation` | Request to participate | Accept/decline |
| `request` | Asking for action | Fulfill/decline |
| `proposal` | Formal proposition | Vote/consensus |

---

## Rendering

`render-spec/phasis-bubble` targets `eidos: phasis`. Displays:
- Author and timestamp (from `expressed_by`, `expressed_at`)
- Content text
- Stance badge (conditionally rendered when stance is set)

---

## Related

- [Commitment Boundary](../../explanation/architecture/commitment-boundary.md) — Why ephemeral and durable are separated
- [Phasis Workspace](phasis-workspace.md) — Accumulation entity schema
- [Two-Phase Bindings](../../explanation/architecture/two-phase-bindings.md) — How phasis content binds in the UI
- [Entity Overlays](../../explanation/presentation/entity-overlays.md) — Per-keystroke overlay pattern
- [Voice Authoring](../../how-to/presentation/voice-authoring.md) — Voice-to-phasis pipeline
