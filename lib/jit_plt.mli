open Import

type 'a t

val empty : _ t

val symbol_address : Bin_table.filled t addressed -> string -> Address.t option
