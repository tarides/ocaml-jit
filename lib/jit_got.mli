open Import

type _ t

val from_binary_section : X86_emitter.buffer -> Bin_table.empty t
(** Creates a table with all the entries needed for the given binary section.
    The table will have the right size, i.e. one entry per got relative relocations
    in the given section. You need to use [fill] to write the actual addresses of
    the pointed symbols. *)

val fill : Address.t String.Map.t -> Bin_table.empty t -> Bin_table.filled t
(** Fills the table with the absolute addresses of the symbols it holds *)

val in_memory_size : _ t -> int
(** Returns the size (in bytes) the table will take up in the memory *)

val content : Bin_table.filled t -> string
(** Returns the table in binary form, as it should be written at the end of the text section *)

val symbol_offset : _ t -> string -> int option
(** [symbol_offset got symbol] returns the offset from the beginning of the GOT at which the
    absolute address for [symbol] is stored or [None] if this symbol is not in the GOT. *)

val symbol_address : _ t addressed -> string -> Address.t option
(** [symbol_address got symbol] returns the absolute address at which the address of [symbol]
    is stored within the given GOT. *)
