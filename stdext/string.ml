module String = Stdlib.String
include StringLabels

module Map = Map.Make (struct
  type t = string

  let compare = String.compare

  let pp fmt t = Format.fprintf fmt "%S" t

  let show t = Format.asprintf "%a" pp t
end)
