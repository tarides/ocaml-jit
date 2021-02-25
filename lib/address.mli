type t

val size : int
(** Size (in bytes) of an address *)

val placeholder : t

val add_int : t -> int -> t

val emit : Buffer.t -> t -> unit
(** Prints the address to the given buffer, respecting the architecture's endianness *)

val emit_string : t -> string
(** Same as [emit] but return it as a string instead of writing it to a buffer *)

val to_int64 : t -> int64

val pp : Format.formatter -> t -> unit

val to_obj : t -> Obj.t
