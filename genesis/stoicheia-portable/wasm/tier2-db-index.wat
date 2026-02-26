;; Tier 2 DB Index - WASM module for semantic indexing
;; V9.5 portable stoicheion
;;
;; Delegates to host via dynamis.db_index import
;; Input: JSON string with {entity_id, text, embedding}
;; Returns (1, 0) on success, (0, 0) on failure

(module
  ;; Import the host function from dynamis namespace
  ;; db_index(params_ptr, params_len) -> (success: i32, unused: i32)
  (import "dynamis" "db_index" (func $db_index (param i32 i32) (result i32 i32)))

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

  ;; Index entity for semantic search - delegates to host via dynamis import
  ;; Takes a JSON params string, returns success/failure
  (func (export "index") (param $params_ptr i32) (param $params_len i32) (result i32 i32)
    (call $db_index (local.get $params_ptr) (local.get $params_len))
  )
)
