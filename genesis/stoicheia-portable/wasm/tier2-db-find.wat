;; Tier 2 DB Find - WASM module for entity lookup
;; V9.5 portable stoicheion
;;
;; Delegates to host via dynamis.db_find import

(module
  ;; Import the host function from dynamis namespace
  ;; db_find(id_ptr, id_len) -> (result_ptr, result_len)
  (import "dynamis" "db_find" (func $db_find (param i32 i32) (result i32 i32)))

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

  ;; Find entity by ID - delegates to host via dynamis import
  (func (export "find") (param $id_ptr i32) (param $id_len i32) (result i32 i32)
    (call $db_find (local.get $id_ptr) (local.get $id_len))
  )
)
