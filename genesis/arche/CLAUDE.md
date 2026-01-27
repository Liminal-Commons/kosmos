# Arche — The Origin

*ἀρχή: beginning, origin, first principle*

You are working in the foundational layer of genesis. Arche contains what must exist before anything else can be composed.

---

## What Lives Here

**dynamis-interface.yaml** — The contract between WASM and Rust. Every capability that WASM modules can call. This is the boundary between kosmos and chora.

**Future contents:**
- `genesis.wat` — The WASM module that bootstraps a kosmos (V9.3)
- Eidos definitions for arche types (stoicheion, eidos, desmos themselves)
- The self-describing foundation

---

## The Dynamis Interface

19 capabilities organized by tier:

| Tier | Category | Count | Examples |
|------|----------|-------|----------|
| 0 | Pure computation | 1 | timestamp |
| 1 | In-memory | 1 | log |
| 2 | Local substrate | 9 | db.arise, db.find, db.bind, db.trace, ... |
| 3 | External world | 8 | aisthesis.surface, manteia.infer, energeia.manifest, fs.emit |

WASM modules import these as:
```wat
(import "dynamis" "db_arise" (func $db_arise ...))
(import "dynamis" "db_find" (func $db_find ...))
```

---

## Memory Protocol

WASM and Rust share data via linear memory:

1. **Inputs**: WASM writes strings/JSON to memory, passes `(ptr, len)`
2. **Outputs**: Rust allocates in WASM memory via `alloc`, writes result, returns `(ptr, len)`

WASM modules must export:
- `memory` — Linear memory
- `alloc(size: i32) -> i32` — Allocate bytes
- `dealloc(ptr: i32, size: i32)` — Free memory

---

## Validation Requirements

The dynamis interface must validate against:

1. **Manifests**: Every `requires_dynamis` entry in oikos manifests must map to a capability
2. **Implementation**: Every capability must have corresponding `HostContext` method
3. **Signatures**: WASM import params must match Rust method signatures

---

## Development Notes

When adding new capabilities:

1. Implement in `HostContext` (Rust)
2. Add to `dynamis-interface.yaml` with full specification
3. Update oikos manifests that need the capability
4. Implement WASM import in dynamis bridge

This is genesis-level work. It requires Rust compilation.

---

*Specialist context for arche development*
