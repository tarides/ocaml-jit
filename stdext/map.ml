module type S = sig
  include MoreLabels.Map.S
end

module type Key = sig
  include MoreLabels.Map.OrderedType
end

module Make (Key : Key) : S with type key = Key.t = struct
  include MoreLabels.Map.Make (Key)
end
