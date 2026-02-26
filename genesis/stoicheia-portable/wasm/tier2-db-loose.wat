;; Tier 2 DB Loose - WASM module for bond deletion
;; V9.5 portable stoicheion
;;
;; Delegates to host via dynamis.db_loose import

(module
  ;; Import the host function from dynamis namespace
  ;; db_loose(from_ptr, from_len, desmos_ptr, desmos_len, to_ptr, to_len)
  ;;     -> (success: i32, unused: i32)
  ;; Returns (1, 0) on success, (0, 0) on failure
  (import "dynamis" "db_loose" (func $db_loose
    (param i32 i32 i32 i32 i32 i32)
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

  ;; Loose (delete) bond - delegates to host via dynamis import
  (func (export "loose")
    (param $from_ptr i32) (param $from_len i32)
    (param $desmos_ptr i32) (param $desmos_len i32)
    (param $to_ptr i32) (param $to_len i32)
    (result i32 i32)
    (call $db_loose
      (local.get $from_ptr) (local.get $from_len)
      (local.get $desmos_ptr) (local.get $desmos_len)
      (local.get $to_ptr) (local.get $to_len))
  )
)
