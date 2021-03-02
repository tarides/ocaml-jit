open Import

type empty

type filled

module type S = sig
  type _ t

  val from_binary_section : X86_emitter.buffer -> empty t
  (** Creates a table with all the entries needed for the given binary section.
      The table will have the right size, i.e. one entry per corresponding relative
      relocations in the given section. You need to use [fill] to write the actual
      addresses of the pointed symbols. *)

  val fill : Symbols.t -> empty t -> filled t
  (** Fills the table with the absolute addresses of the symbols it holds *)

  val in_memory_size : _ t -> int
  (** Returns the size (in bytes) the table will take up in the memory *)

  val content : filled t -> string
  (** Returns the table in binary form, as it should be written at the end of the text section *)

  val symbol_address : _ t addressed -> string -> Address.t option
  (** [symbol_address table symbol] returns the absolute address at which the address
      or jump for [symbol] is stored within the given table. *)
end

module type IN = sig
  val name : string

  val entry_size : int

  val entry_from_relocation : Relocation.t -> string option

  val write_entry : Buffer.t -> Address.t -> unit
end

module Make (X : IN) : S
