<!-- =============================================================================
<!-- GENERATED FILE - DO NOT EDIT DIRECTLY -->
<!-- =============================================================================
<!-- Emitted by: emit_cycle (demiurge/emit-genesis) -->
<!-- Source: genesis/psyche/REFERENCE.md -->
<!-- -->
<!-- To modify: -->
<!--   1. Edit the source in genesis/ -->
<!--   2. Re-run emit-genesis -->
<!-- -->
<!-- See: genesis/EXTENDING.md -->
<!-- =============================================================================

# Psyche Reference

the experiencing self

---

## Praxeis (Operations)

🔧 = Exposed as MCP tool

### activate-intention 🔧

Activate a forming intention.

**Tier:** 2 | **ID:** `praxis/psyche/activate-intention`

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `intention_id` | string | ✓ | The intention to activate |

### attend 🔧

Direct attention to something.

**Tier:** 2 | **ID:** `praxis/psyche/attend`

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `target_id` | string | ✓ | What to attend to |
| `attention_id` | string |  | Optional ID for the attention entity |
| `weight` | number |  | Focus weight 0.0 to 1.0 (default 1.0) |
| `reason` | string |  | Why attending |

### disclose-mood 🔧

Disclose the current mood.

**Tier:** 2 | **ID:** `praxis/psyche/disclose-mood`

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `quality` | string | ✓ | The mood quality (focused, scattered, anxious, calm, etc.) |
| `intensity` | number |  | Intensity 0.0 to 1.0 |
| `notes` | string |  | Notes about the mood |

### form-intention 🔧

Form a new intention.

**Tier:** 2 | **ID:** `praxis/psyche/form-intention`

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `description` | string | ✓ | What the intention is about |
| `intention_id` | string |  | Optional ID for the intention entity |
| `priority` | number |  | Priority level (higher = more important) |

### fulfill-intention 🔧

Mark an intention as fulfilled.

**Tier:** 2 | **ID:** `praxis/psyche/fulfill-intention`

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `intention_id` | string | ✓ | The intention to fulfill |

### list-intentions 🔧

List intentions of the parousia.

**Tier:** 2 | **ID:** `praxis/psyche/list-intentions`

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `status` | string |  | Filter by status (forming, active, fulfilled, abandoned) |

### release-attention 🔧

Release attention from something.

**Tier:** 2 | **ID:** `praxis/psyche/release-attention`

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `target_id` | string | ✓ | What to stop attending to |

---

*Generated from schema definitions. Do not edit directly.*
