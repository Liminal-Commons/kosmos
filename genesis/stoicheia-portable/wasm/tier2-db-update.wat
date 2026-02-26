;; Tier 2 DB Update - WASM module for entity data update
;; V9.5 portable stoicheion
;;
;; Delegates to host via dynamis.db_update import

(module
  ;; Import the host function from dynamis namespace
  ;; db_update(id_ptr, id_len, data_ptr, data_len) -> (result_ptr, result_len)
  (import "dynamis" "db_update" (func $db_update
    (param i32 i32 i32 i32)
    (result i32 i32)))

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

  ;; Update entity data - delegates to host via dynamis import
  (func (export "update")
    (param $id_ptr i32) (param $id_len i32)
    (param $data_ptr i32) (param $data_len i32)
    (result i32 i32)
    (call $db_update
      (local.get $id_ptr) (local.get $id_len)
      (local.get $data_ptr) (local.get $data_len))
  )
)
