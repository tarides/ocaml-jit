open! Import

module Target = struct
  type t = Direct of string | Got of string | Plt of string

  let from_label label =
    match String.split_on_char ~sep:'@' label with
    | [ label ] -> Some (Direct label)
    | [ label; "GOTPCREL" ] -> Some (Got label)
    | [ label; "PLT" ] -> Some (Plt label)
    | _ -> None

  let from_label_err label =
    match from_label label with
    | None -> errorf "Don't know how to interpret relocation target: %S" label
    | Some target -> Ok target
end

module Size = struct
  type t = S64 | S32

  let to_data_size = function S64 -> X86_emitter.B64 | S32 -> X86_emitter.B32
end

module Kind = struct
  type t = Absolute | Relative
end

type t = {
  offset_from_section_beginning : int;
  size : Size.t;
  kind : Kind.t;
  target : Target.t;
}

let size_from_reloc_kind (kind : X86_emitter.Relocation.Kind.t) =
  match kind with REL32 _ | DIR32 _ -> Size.S32 | DIR64 _ -> Size.S64

let kind_from_reloc_kind (kind : X86_emitter.Relocation.Kind.t) =
  match kind with
  | DIR32 _ | DIR64 _ -> Kind.Absolute
  | REL32 _ -> Kind.Relative

let label_from_reloc_kind (kind : X86_emitter.Relocation.Kind.t) =
  match kind with
  | REL32 (label, _) | DIR32 (label, _) | DIR64 (label, _) -> label

let from_x86_relocation relocation =
  let open Option.Op in
  let ({ offset_from_section_beginning; kind } : X86_emitter.Relocation.t) =
    relocation
  in
  let label = label_from_reloc_kind kind in
  let size = size_from_reloc_kind kind in
  let kind = kind_from_reloc_kind kind in
  let+ target = Target.from_label label in
  { target; size; kind; offset_from_section_beginning }

let from_x86_relocation_err relocation =
  let open Result.Op in
  let ({ offset_from_section_beginning; kind } : X86_emitter.Relocation.t) =
    relocation
  in
  let label = label_from_reloc_kind kind in
  let size = size_from_reloc_kind kind in
  let kind = kind_from_reloc_kind kind in
  let+ target = Target.from_label_err label in
  { target; size; kind; offset_from_section_beginning }
