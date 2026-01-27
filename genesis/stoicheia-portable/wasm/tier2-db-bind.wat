;; Tier 2 DB Bind - WASM module for bond creation
;; V9.5 portable stoicheion
;;
;; Delegates to host via dynamis.db_bind import

(module
  ;; Import the host function from dynamis namespace
  ;; db_bind(from_ptr, from_len, desmos_ptr, desmos_len, to_ptr, to_len, data_ptr, data_len)
  ;;     -> (result_ptr, result_len)
  (import "dynamis" "db_bind" (func $db_bind
    (param i32 i32 i32 i32 i32 i32 i32 i32)
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

  ;; Bind (create bond) between entities - delegates to host via dynamis import
  (func (export "bind")
    (param $from_ptr i32) (param $from_len i32)
    (param $desmos_ptr i32) (param $desmos_len i32)
    (param $to_ptr i32) (param $to_len i32)
    (param $data_ptr i32) (param $data_len i32)
    (result i32 i32)
    (call $db_bind
      (local.get $from_ptr) (local.get $from_len)
      (local.get $desmos_ptr) (local.get $desmos_len)
      (local.get $to_ptr) (local.get $to_len)
      (local.get $data_ptr) (local.get $data_len))
  )
)
