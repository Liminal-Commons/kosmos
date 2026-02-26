;; Tier 1 DB Gather - WASM module for querying entities by eidos
;; V9.5 portable stoicheion
;;
;; Delegates to host via dynamis.db_gather import
;; Input: JSON string with {eidos, limit, sort_field, sort_order}
;; Output: JSON array of entity records

(module
  ;; Import the host function from dynamis namespace
  ;; db_gather(params_ptr, params_len) -> (result_ptr, result_len)
  (import "dynamis" "db_gather" (func $db_gather (param i32 i32) (result i32 i32)))

  ;; Memory export required by wasmtime (1 page = 64KB)
  (memory (export "memory") 1)

  ;; Simple bump allocator state - heap pointer starts at 1024
  (global $heap_ptr (mut i32) (i32.const 1024))

  ;; Allocate n bytes, returns pointer to allocated memory
  (func (export "alloc") (param $size i32) (result i32)
    (local $ptr i32)
    (local.set $ptr (global.get $heap_ptr))
    (global.set $heap_ptr (i32.add (global.get $heap_ptr) (local.get $size)))
    (local.get $ptr)
  )

  ;; Reset heap pointer for reuse between calls
  (func (export "reset_heap")
    (global.set $heap_ptr (i32.const 1024))
  )

  ;; Gather entities - delegates to host via dynamis import
  ;; Takes a JSON params string, returns JSON array of entities
  (func (export "gather") (param $params_ptr i32) (param $params_len i32) (result i32 i32)
    (call $db_gather (local.get $params_ptr) (local.get $params_len))
  )
)
