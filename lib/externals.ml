external memalign : int -> (Address.t, int) result = "jit_memalign"

external load_section : Address.t -> string -> int -> unit = "jit_load_section"

external mprotect_ro : Address.t -> int -> (unit, int) result
  = "jit_mprotect_ro"

external mprotect_rx : Address.t -> int -> (unit, int) result
  = "jit_mprotect_rx"

external run_toplevel : Jit_unit.Entry_points.t -> Opttoploop.res
  = "jit_run_toplevel"
