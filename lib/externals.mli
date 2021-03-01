val memalign : int -> (Address.t, int) result

val load_section : Address.t -> string -> int -> unit

val mprotect_ro : Address.t -> int -> (unit, int) result

val mprotect_rx : Address.t -> int -> (unit, int) result

val run_toplevel : Jit_unit.Entry_points.t -> Opttoploop.res

val get_page_size : unit -> int
