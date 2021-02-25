open Import

let symbol_map = ref (String.Map.empty : Address.t String.Map.t)

let debug = ref false
