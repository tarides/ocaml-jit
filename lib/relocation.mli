open! Import

module Target : sig
  (** Type describing relocation targets *)
  type t = Direct of string | Got of string | Plt of string

  val from_label : string -> t option
  (** Returns the type of relative relocation based on the relocation target label:
      - ["<label>@GOTPCREL"] is interpreted as [Got "<label>"]
      - ["<label>@PLT"] is interpreted as [Plt "<label>"]
      - A reloc target with no ['@'] is interpreted as [Direct "<target>"]
      - Anything else is interpreted as [None]. *)
end

module Size : sig
  type t = S64 | S32

  val to_data_size : t -> X86_emitter.data_size
end

module Kind : sig
  type t = Absolute | Relative
end

type t = {
  offset_from_section_beginning : int;
  size : Size.t;
  kind : Kind.t;
  target : Target.t;
}

val from_x86_relocation : X86_emitter.Relocation.t -> t option
(** Returns the type of relative relocation is the given relocation is relative, returns
    [None] otherwise or if the target label cannot be parsed properly by [from_label]. *)

val from_x86_relocation_err : X86_emitter.Relocation.t -> (t, string) result
(** Same as [from_x86_relocation] but returns an error instead of [None]. *)
