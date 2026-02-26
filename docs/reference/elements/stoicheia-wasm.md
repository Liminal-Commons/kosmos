# WASM Stoicheia Execution Model

*Reference: Prescriptive specification for portable stoicheia execution via WebAssembly.*

---

## Overview

Stoicheia are the atomic operations of the kosmos interpreter. Portable stoicheia (Tier 0-2) execute as WebAssembly modules in a sandboxed environment, delegating to host functions for database and system access. Tier 3 stoicheia (networking, LLM, filesystem) remain as arche (Rust) implementations.

WASM is the default execution mode for all Tier 0-2 stoicheia. Arche exists only for Tier 3 host-level dynamis.

---

## Tier Model

| Tier | Domain | Execution | Examples |
|------|--------|-----------|----------|
| 0 | Pure computation | WASM (no host calls) | assert, return, set |
| 1 | Database reads | WASM (host calls) | find, gather, trace, surface |
| 2 | Database writes | WASM (host calls) | arise, bind, update, loose, delete, index |
| 3 | External systems | Arche only | infer, emit, manifest, invoke |

**Rule:** If a stoicheion does not require network, filesystem, or LLM access, it runs as WASM. No exceptions.

---

## WASM Sandbox Model

### Engine Configuration

```rust
let mut config = Config::new();
config.consume_fuel(true);      // Bounded execution
config.wasm_threads(false);     // No threading
let engine = Engine::new(&config);
```

### Fuel Metering

Each WASM invocation receives **10,000,000 fuel units**. If a module exhausts its fuel, execution traps with an error. This prevents infinite loops and resource exhaustion.

### Memory Limits

Each module gets **1 page (64KB)** of linear memory. The first 1024 bytes are reserved; the heap starts at offset 1024 and grows upward via the bump allocator.

---

## Host Function Interface

WASM modules import from the `"dynamis"` namespace. Each host function follows the string-pair convention: strings are passed as `(ptr: i32, len: i32)` pairs pointing into WASM linear memory.

### Available Host Functions

#### Database Read Operations

| Function | Signature | Returns |
|----------|-----------|---------|
| `db_find` | `(id_ptr, id_len) -> (ptr, len)` | Entity JSON or `(0, 0)` if not found |
| `db_gather` | `(params_ptr, params_len) -> (ptr, len)` | JSON array of entities |
| `db_trace` | `(params_ptr, params_len) -> (ptr, len)` | JSON array of bonds |
| `db_surface` | `(params_ptr, params_len) -> (ptr, len)` | JSON array of scored matches |

#### Database Write Operations

| Function | Signature | Returns |
|----------|-----------|---------|
| `db_arise` | `(eidos_ptr, eidos_len, id_ptr, id_len, data_ptr, data_len, cf_ptr, cf_len) -> (ptr, len)` | Created entity JSON |
| `db_bind` | `(from_ptr, from_len, desmos_ptr, desmos_len, to_ptr, to_len, data_ptr, data_len) -> (ptr, len)` | Created bond JSON |
| `db_update` | `(id_ptr, id_len, data_ptr, data_len) -> (ptr, len)` | Updated entity JSON |
| `db_delete` | `(id_ptr, id_len) -> (i32, i32)` | `(1, 0)` on success, `(0, 0)` on failure |
| `db_loose` | `(from_ptr, from_len, desmos_ptr, desmos_len, to_ptr, to_len) -> (i32, i32)` | `(1, 0)` on success, `(0, 0)` on failure |
| `db_index` | `(params_ptr, params_len) -> (i32, i32)` | `(1, 0)` on success, `(0, 0)` on failure |

#### Utility Functions

| Function | Signature | Returns |
|----------|-----------|---------|
| `log` | `(msg_ptr, msg_len) -> void` | Logs to stderr for debugging |

### Return Convention

- **Entity/bond results:** Host allocates WASM memory via the module's exported `alloc` function, writes JSON bytes, returns `(ptr, len)`.
- **Not found / failure:** Returns `(0, 0)`.
- **Success/failure flags:** Returns `(1, 0)` for success, `(0, 0)` for failure.

---

## WAT Module Structure

Every portable stoicheion WAT module follows this structure:

```wasm
;; Tier N DB <Operation> - WASM module for <description>
;; V9.5 portable stoicheion

(module
  ;; 1. Import host function(s) from dynamis namespace
  (import "dynamis" "db_<op>" (func $db_<op> (param ...) (result ...)))

  ;; 2. Export linear memory (1 page = 64KB)
  (memory (export "memory") 1)

  ;; 3. Bump allocator state — heap starts at offset 1024
  (global $heap_ptr (mut i32) (i32.const 1024))

  ;; 4. Export alloc (required by host for writing results)
  (func (export "alloc") (param $size i32) (result i32)
    (local $ptr i32)
    (local.set $ptr (global.get $heap_ptr))
    (global.set $heap_ptr (i32.add (global.get $heap_ptr) (local.get $size)))
    (local.get $ptr)
  )

  ;; 5. Export reset_heap (called between invocations)
  (func (export "reset_heap")
    (global.set $heap_ptr (i32.const 1024))
  )

  ;; 6. Export the stoicheion function — delegates to host
  (func (export "<operation>") (param ...) (result ...)
    (call $db_<op> ...)
  )
)
```

### Required Exports

| Export | Type | Purpose |
|--------|------|---------|
| `memory` | Memory | Linear memory for data exchange |
| `alloc` | `(i32) -> i32` | Bump allocator for host to write results |
| `reset_heap` | `() -> ()` | Reset allocator between invocations |
| `<operation>` | varies | The stoicheion entry point |

### Writing a New WAT Module

1. Identify the stoicheion and its tier
2. Determine which host function(s) it needs from the `dynamis` namespace
3. Copy the structure above, replacing `<operation>` and host function imports
4. The module delegates to host functions — it does not contain business logic
5. Add the corresponding host function in `dynamis.rs` if it doesn't exist
6. Add the `include_str!` constant and module cache in `steps.rs`
7. Add the environment variable dispatch (`KOSMOS_STOICHEION_<NAME>`)
8. Write equivalence tests in `v9_equivalence.rs`

---

## Module Loading

WAT source is embedded at compile time via `include_str!` and compiled to WASM at runtime:

```rust
// In steps.rs
const TIER2_DB_UPDATE_WAT: &str =
    include_str!("../../../../genesis/stoicheia-portable/wasm/tier2-db-update.wat");

// Lazy-initialized module cache
fn get_tier2_db_update_module() -> &'static Module {
    static MODULE: OnceLock<Module> = OnceLock::new();
    MODULE.get_or_init(|| {
        Module::new(get_wasm_engine(), TIER2_DB_UPDATE_WAT)
            .expect("Failed to compile tier2-db-update.wat")
    })
}
```

Module compilation happens once per process lifetime via `OnceLock`.

---

## Execution Modes

Each stoicheion supports three execution modes, controlled by environment variables:

| Mode | Behavior | When to Use |
|------|----------|-------------|
| `wasm` | Execute WASM module only | Production (default for Tier 0-2) |
| `arche` | Execute Rust implementation only | Legacy / debugging |
| `compare` | Execute both, assert equality | Equivalence testing |

Environment variable pattern: `KOSMOS_STOICHEION_<NAME>=wasm|arche|compare`

```bash
# Example: compare mode for all Tier 2 writes
KOSMOS_STOICHEION_UPDATE=compare \
KOSMOS_STOICHEION_DELETE=compare \
KOSMOS_STOICHEION_LOOSE=compare \
cargo test v9_equivalence
```

**Default:** When no environment variable is set, Tier 0-2 stoicheia use `wasm`. This is the clean break — no fallback to arche.

---

## Equivalence Testing Protocol

Equivalence tests validate that WASM and Rust implementations produce identical results.

### Test Structure

```rust
#[test]
fn test_<stoicheion>_equivalence() {
    // 1. Create separate HostContexts for Rust and WASM (avoid ID collisions)
    let ctx_rust = HostContext::in_memory().unwrap();
    let ctx_wasm = HostContext::in_memory().unwrap();

    // 2. Set up identical preconditions in both contexts

    // 3. Execute via Rust
    let rust_result = ctx_rust.<operation>(...);

    // 4. Execute via WASM
    let mut instance = DynamisInstance::new(&engine, &module, ctx_wasm).unwrap();
    let wasm_result = instance.call_<operation>(...);

    // 5. Assert identical results
    assert_eq!(rust_result, wasm_result);
}
```

### What "Identical Results" Means

- Same entity IDs, eidos, and data fields
- Same bond from_id, desmos, to_id, and data fields
- Same error conditions (not found returns None/empty in both)
- JSON structural equivalence (field order does not matter)

### Heap Reset

Call `instance.reset_heap()` between sequential WASM invocations within a single test to reset the bump allocator.

---

## Portability Rules

### WASM-Eligible (Tier 0-2)

A stoicheion is WASM-eligible if it:
- Operates only on the entity/bond graph (database)
- Has deterministic behavior given identical inputs and database state
- Does not require network, filesystem, or external API access
- Can express its full interface via the dynamis host functions

### Arche-Only (Tier 3)

A stoicheion requires arche if it:
- Calls external APIs (Anthropic, OpenAI, LiveKit)
- Accesses the filesystem (emit, manifest)
- Spawns processes
- Requires cryptographic key material from the keychain
- Uses platform-specific system calls

---

## Stoicheia Coverage

| Stoicheion | Tier | Module | Host Function | Status |
|-----------|------|--------|---------------|--------|
| `find` | 1 | `tier2-db-find.wat` | `db_find` | Implemented |
| `arise` | 2 | `tier2-db-arise.wat` | `db_arise` | Implemented |
| `bind` | 2 | `tier2-db-bind.wat` | `db_bind` | Implemented |
| `update` | 2 | `tier2-db-update.wat` | `db_update` | Implemented |
| `delete` | 2 | `tier2-db-delete.wat` | `db_delete` | Implemented |
| `loose` | 2 | `tier2-db-loose.wat` | `db_loose` | Implemented |
| `gather` | 1 | `tier1-db-gather.wat` | `db_gather` | Implemented |
| `trace` | 1 | `tier1-db-trace.wat` | `db_trace` | Implemented |
| `surface` | 1 | `tier1-db-surface.wat` | `db_surface` | Implemented |
| `index` | 2 | `tier2-db-index.wat` | `db_index` | Implemented |

---

## File Locations

| Concern | Path |
|---------|------|
| WAT source modules | `genesis/stoicheia-portable/wasm/` |
| Host function bindings | `crates/kosmos/src/interpreter/dynamis.rs` |
| Step dispatch (WASM/arche) | `crates/kosmos/src/interpreter/steps.rs` |
| Equivalence tests | `crates/kosmos/tests/v9_equivalence.rs` |
| Topos manifest declarations | `genesis/<topos>/manifest.yaml` → `stoicheia_form` |
