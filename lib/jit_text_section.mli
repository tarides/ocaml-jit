open Import

type need_reloc

type relocated

type _ t

val from_binary_section : X86_emitter.buffer -> need_reloc t
(** Creates a text section with empty GOT and PLT. These will be filled
    along with relocations applied by [relocate].
    The returned section can be used to determine the size of the final text section
    to properly allocate memory pages *)

val in_memory_size : _ t -> int
(** Returns the size (in bytes) the section + GOT and PLT will take up in the memory *)

val relocate :
  symbol_map:Address.t String.Map.t ->
  need_reloc t addressed ->
  (relocated t addressed, string list) result
(** Apply relocations to the following section and fills the GOT and PLT.
    The returned section can be written to memory and run. *)

val content : relocated t -> string
(** Return the text section along with the GOT and PLT tables, in binary form as a string *)
