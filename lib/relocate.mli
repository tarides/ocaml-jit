open Import

val all_text :
  symbol_map:Address.t String.Map.t ->
  got:Bin_table.filled Jit_got.t addressed ->
  plt:Bin_table.filled Jit_plt.t addressed ->
  X86_emitter.buffer addressed ->
  (unit, string list) result
(** Apply all relocations to the given .text binary section as patches.
    Symbols' absolute addresses are looked up using the provided tables for PLT and GOT based
    relocations or the symbol map for other relocations.
    It will return an error before applying any relocation if one or more of them can't properly be parsed
    It will also return an error if a GOT or PLT relocation is marked as absolute but will still apply
    other relocations.
    Errors for either of the above mentioned cases are aggregated into a list. *)

val all :
  symbol_map:Address.t String.Map.t ->
  section_name:string ->
  X86_emitter.buffer addressed ->
  (unit, string list) result
(** Same as [apply_all_text] but for any other section.
    The section is expected to contain no GOT nor PLT based relocations. If any such relocation is found
    the function will return an error but still apply other relocations. *)
