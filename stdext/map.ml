module type S = sig
  include MoreLabels.Map.S

  val pp : (Format.formatter -> 'a -> unit) -> Format.formatter -> 'a t -> unit
  val show : (Format.formatter -> 'a -> unit) -> 'a t -> string
end

module type Key = sig
  include MoreLabels.Map.OrderedType

  val pp : Format.formatter -> t -> unit
  val show : t -> string
end

module Make (Key : Key) : S with type key = Key.t = struct
  include MoreLabels.Map.Make (Key)

  let pp_bindings pp_a fmt = function
    | [] -> Format.fprintf fmt "[]"
    | [ (k, a) ] -> Format.fprintf fmt "[(%a, %a)]" Key.pp k pp_a a
    | (k, a) :: tl ->
        Format.fprintf fmt "[ (%a, %a)@ " Key.pp k pp_a a;
        List.iter
          (fun (k, a) -> Format.fprintf fmt "; (%a, %a)@ " Key.pp k pp_a a)
          tl;
        Format.fprintf fmt "]"

  let pp pp_a fmt t = pp_bindings pp_a fmt (bindings t)
  let show pp_a t = Format.asprintf "%a" (pp pp_a) t
end
