open Import

type t
(** Type for mapping from symbols to addresses *)

val empty : t

val from_binary_section : X86_emitter.buffer addressed -> t
(** Create a mapping for all symbols in the given section. Some symbols
    that should be available globally, such as ["caml_absf_mask"] will not
    be ignored so that we always use the global ones. *)

val union : t -> t -> t
(** Returns the union of two symbols mappings. Raises an exception if there
    are conflicts *)

val find : t -> string -> Address.t option
(** Lookup a symbol's address in the given symbol map. If it is missing from the map
    look it up using dlsym. *)
