open Import

type 'a t = X

let empty = X

let symbol_address { address = _; value = X } _symbol = None
