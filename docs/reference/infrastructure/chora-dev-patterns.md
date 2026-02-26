# Chora Development Patterns

*Rust module contracts, test patterns, and interpreter extension guide.*

---

## Host Module Structure

The kosmos crate is organized by concern:

| Module | Responsibility |
|--------|---------------|
| `host.rs` | HostContext — identity, will, energeia, reflex orchestration |
| `graph.rs` | Entity and bond operations (find, gather, arise, bind, trace, traverse) |
| `nous.rs` | Aisthesis (sensing) + manteia (inference) — `infer_with_provider`, `embed_with_provider` |
| `emission.rs` | Ekthesis — serialization and filesystem writes |
| `bootstrap.rs` | Genesis loading — spora parsing, topos discovery, germination |
| `reflex.rs` | Reflexes, transitions, signal routing |
| `signal.rs` | Substrate signal registry — ephemeral 10Hz measurement |
| `mode_dispatch.rs` | Generated mode→substrate dispatch table |
| `command_template.rs` | Template-driven actuality for command execution |

Substrate modules: `dns.rs`, `process.rs`, `storage.rs`, `credential.rs`, `r2.rs`, `livekit.rs`, `voice.rs`

---

## Key Types

### HostContext

```rust
let ctx = HostContext::new(db_path)?;       // File-based (production)
let ctx = HostContext::in_memory()?;         // In-memory (testing)
```

HostContext wraps a SQLite connection and orchestrates all operations. It is the single entry point for:

- `invoke_praxis(id, params) → Result<Value>` — execute a praxis
- `find_entity(id) → Result<Option<Value>>` — entity lookup
- `gather_entities(eidos, ...) → Result<Vec<Value>>` — query by type
- `trace_bonds(from, to, desmos) → Vec<Value>` — bond traversal
- `update_entity(id, data) → Result<()>` — **REPLACE** semantics (not merge)

**Critical:** `update_entity()` is REPLACE, not merge. Always read-modify-write:

```rust
let entity = ctx.find_entity("my/entity")?.unwrap();
let mut data = entity["data"].clone();
data["new_field"] = json!("value");
ctx.update_entity("my/entity", data)?;
```

### DwellingContext

```rust
pub struct DwellingContext {
    pub prosopon_id: String,
    pub oikos_id: String,
    pub parousia_id: Option<String>,
    pub session_id: Option<String>,
    pub locale: Option<String>,
}
```

Created from the session bridge. Available in scope as `_prosopon`, `_oikos`, `_parousia`.

### Scope

```rust
let mut scope = Scope::new();
scope.set("key".to_string(), json!("value"));
let child = scope.child();  // Inherits parent bindings
```

Scopes chain — child scopes see parent bindings. Used by the interpreter for variable binding during praxis execution.

---

## Interpreter Extension

### Adding a Stoicheion

1. Define in `genesis/stoicheia-portable/eide/stoicheion.yaml`:

```yaml
- eidos: stoicheion
  id: stoicheion/my_step
  data:
    name: my_step
    tier: 1
    description: What this step does.
    fields:
      input_name:
        type: string
        required: true
      bind_to:
        type: string
        required: false
```

2. Run `cargo build` — `build.rs` generates `step_types.rs` with a `MyStepStep` struct.

3. Implement in `crates/kosmos/src/interpreter/steps.rs`:

```rust
impl MyStepStep {
    pub fn execute(&self, ctx: &HostContext, scope: &mut Scope) -> Result<StepResult> {
        let input = scope.eval(&self.input_name)?;
        let result = /* ... */;

        if let Some(ref bind) = self.bind_to {
            scope.set(bind.clone(), result.clone());
        }

        Ok(StepResult::Continue)
    }
}
```

**Never edit `step_types.rs` directly** — it is generated from `stoicheion.yaml`.

### Expression Evaluation

Two functions for evaluating expressions in scope:

```rust
// Returns Value (preserves type)
evaluate_expression("$entity.data.name", &scope)?;

// Returns String (coerces to string)
eval_string("prefix/$var/suffix", &scope)?;
```

Supported syntax:
- `$var` — variable reference
- `$entity.data.name` — dotted property access
- `$array[0]` — array indexing
- `min($a, $b)` — function calls
- `{{ expr }}` — template interpolation (in eval_string)

---

## Test Patterns

### Bootstrap Test Setup

The standard pattern for integration tests:

```rust
fn bootstrap_ctx() -> Option<(HostContext, BootstrapResult)> {
    let ctx = HostContext::in_memory().ok()?;
    let spora_path = workspace_path("genesis/spora/spora.yaml");
    if !spora_path.exists() {
        return None;  // Skip if genesis not available
    }
    let result = kosmos::bootstrap_from_spora(&ctx, &spora_path).ok()?;
    Some((ctx, result))
}

#[test]
fn test_something() {
    let (ctx, _) = match bootstrap_ctx() {
        Some(c) => c,
        None => return,  // Skip gracefully
    };
    // ... test logic
}
```

Key conventions:
- `HostContext::in_memory()` — SQLite in RAM, no file cleanup needed
- `workspace_path()` — resolves relative to `CARGO_MANIFEST_DIR`
- Return `Option` from bootstrap — tests skip gracefully if genesis unavailable
- Bootstrap loads ALL genesis (no substrate-only filtering in tests)

### Session Bridge in Tests

```rust
let bridge = TestSessionBridge::from_env();  // Reads env vars for credentials
let ctx = HostContext::in_memory()?.with_session_bridge(Arc::new(bridge));
```

`TestSessionBridge::from_env()` reads `OPENAI_API_KEY`, `ANTHROPIC_API_KEY`, `CLOUDFLARE_API_TOKEN` from environment. If none set, returns a bridge with no credentials — tests that need credentials should check and skip.

### Read-Modify-Write for Updates

Because `update_entity()` is REPLACE:

```rust
// WRONG — loses all existing fields
ctx.update_entity("my/entity", json!({"new_field": "value"}))?;

// RIGHT — preserves existing fields
let entity = ctx.find_entity("my/entity")?.unwrap();
let mut data = entity["data"].as_object().unwrap().clone();
data.insert("new_field".to_string(), json!("value"));
ctx.update_entity("my/entity", Value::Object(data))?;
```

### Bootstrap Mode

Reflexes are dormant during bootstrap. `enter_bootstrap_mode()` suppresses all reflex firing. `exit_bootstrap_mode()` activates them. This prevents cascade effects during initial entity creation.

---

## Build System

### Generated Files

| Generated File | Source | Generator |
|----------------|--------|-----------|
| `step_types.rs` | `stoicheion.yaml` | `build.rs` |
| `mode_dispatch.rs` | `genesis/*/modes/*.yaml` | `build.rs` |

Both are generated at compile time and written to `OUT_DIR`. Never edit directly.

### Justfile Commands

All builds go through the justfile:

| Command | When |
|---------|------|
| `just dev` | Development: clean DB, sync genesis, tauri dev |
| `just local` | Full deploy: clean DB, validate genesis, build, install |
| `just serve` | Run kosmos-mcp standalone |
| `cargo test` | Run all tests (no justfile wrapper needed) |

---

## Error Handling

```rust
pub type Result<T> = std::result::Result<T, KosmosError>;

pub enum KosmosError {
    Invalid(String),           // Logic errors
    NotFound(String),          // Entity not found
    Io(String),                // File I/O
    Storage(String),           // Database
    Serde(String),             // JSON/YAML parsing
    ValidationFailed(String),  // Dokimasia validation
}
```

Library code uses `Result<T>` — no panics or unwraps. `From` implementations for `std::io::Error`, `serde_json::Error`, `rusqlite::Error`.

---

*See [substrate-integration.md](substrate-integration.md) for the substrate module contract. See [bootstrap-genesis.md](../genesis/bootstrap-genesis.md) for the bootstrap sequence.*
