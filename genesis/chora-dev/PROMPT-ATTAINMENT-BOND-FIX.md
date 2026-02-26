# PROMPT: Fix Missing has-attainment Bonds in REST session_arise

## Status: READY

## Problem

When a session is created via the REST `/api/session/arise` endpoint (used by the Tauri app), the `has-attainment` bonds are never created on the parousia entity. This causes every praxis with a `requires-attainment` bond to fail with:

```
Missing attainment 'compose' required by praxis/demiurge/compose
```

The attainments ARE correctly computed from oikos membership (tracing `grants-attainment` bonds), and ARE placed in the session token payload — but the **graph bonds** that `check_praxis_authorization()` traverses are never written.

## Root Cause

Two code paths create sessions:

1. **MCP `McpServer::arise()`** in `crates/kosmos-mcp/src/lib.rs:657-673` — **CORRECT**. Creates `parousia --[has-attainment]--> attainment` bonds.

2. **REST `session_arise()`** in `crates/kosmos-mcp/src/rest.rs:595-621` — **BROKEN**. Computes attainments but only puts them in the token. Never creates bonds.

The authorization check in `crates/kosmos/src/interpreter/mod.rs` traces `has-attainment` bonds from the parousia. No bonds = no attainments = rejection.

## The Fix

In `crates/kosmos-mcp/src/rest.rs`, after the attainment computation loop (after line 621, before "Generate token" on line 623), add:

```rust
// Create has-attainment bonds on parousia (mirrors McpServer::arise())
for attainment_id in &attainments {
    host.create_bond(&parousia_id, "has-attainment", attainment_id, None)
        .map_err(|e| McpError::Internal(e.to_string()))?;
}
```

This mirrors exactly what `McpServer::arise()` does at `lib.rs:657-673`.

## Verification

### 1. Existing tests must still pass

```bash
cargo test -p kosmos --lib --tests
cargo test -p kosmos-mcp --lib
```

Expected: All 288+ tests pass, zero regressions.

### 2. Add a test for REST session attainment bonds

In `crates/kosmos-mcp/` tests (or `crates/kosmos/tests/`), add a test that:
- Bootstraps a kosmos with `oikos/kosmos --[grants-attainment]--> attainment/compose`
- Calls the REST session_arise flow (or simulates it)
- Verifies `parousia --[has-attainment]--> attainment/compose` bond exists
- Verifies a praxis with `requires-attainment: attainment/compose` succeeds

### 3. Manual verification

```bash
just dev
```

Open Thyra. The "Missing attainment 'compose'" error should no longer appear. Praxeis should execute normally.

## Files to Touch

| File | Change |
|------|--------|
| `crates/kosmos-mcp/src/rest.rs` | Add bond creation after line 621 |
| Test file (new or existing) | Add test for REST attainment bonds |

## Context

- `genesis/spora/spora.yaml` lines 1653-1692 define the `grants-attainment` bonds from `oikos/kosmos`
- `crates/kosmos/src/interpreter/mod.rs:64-66` is the authorization check
- `crates/kosmos/tests/attainment_authorization.rs` has existing authorization tests
- The attainment authorization system itself is correct — only the REST session creation path is missing bonds

## Methodology

Follow DDD+TDD per CLAUDE.md:
1. Read this prompt (doc)
2. Write the failing test first
3. Add the bond creation code
4. Verify all tests pass
5. `just dev` and confirm Thyra works
