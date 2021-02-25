open Import

type need_reloc = Bin_table.empty

type relocated = Bin_table.filled

let name = ".text"

type 'a t = {
  binary_section : X86_emitter.buffer;
  got : 'a Jit_got.t;
  plt : 'a Jit_plt.t;
}

let from_binary_section binary_section =
  let got = Jit_got.from_binary_section binary_section in
  let plt = (* TODO: PLT *) Jit_plt.empty in
  { binary_section; got; plt }

let in_memory_size { binary_section; got; plt = _ } =
  let section_size = X86_emitter.size binary_section in
  let got_size = Jit_got.in_memory_size got in
  let plt_size = (* TODO: PLT *) 0 in
  section_size + got_size + plt_size

let relocate ~symbol_map (t : need_reloc t addressed) =
  let open Result.Op in
  let got_address =
    Address.add_int t.address (X86_emitter.size t.value.binary_section)
  in
  let got = Jit_got.fill symbol_map t.value.got in
  let plt_address = Address.add_int got_address (Jit_got.in_memory_size got) in
  let plt = (* TODO: PLT *) Jit_plt.empty in
  let+ () =
    Relocate.all_text ~symbol_map
      ~got:{ address = got_address; value = got }
      ~plt:{ address = plt_address; value = plt }
      { address = t.address; value = t.value.binary_section }
  in
  let value = { t.value with got; plt } in
  { t with value }

let content t = X86_emitter.contents t.binary_section ^ Jit_got.content t.got

let symbol_map { address; value = t } =
  let raw_symbol_map = X86_emitter.labels t.binary_section in
  String.Map.map raw_symbol_map ~f:(fun symbol ->
      match symbol.X86_emitter.sy_pos with
      | None -> failwithf "Symbol %s has no offset" symbol.X86_emitter.sy_name
      | Some offset -> Address.add_int address offset)
