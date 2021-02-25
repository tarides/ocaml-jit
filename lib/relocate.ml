open Import
open Relocation

let out_of_text_error ~got_or_plt ~section_name =
  errorf
    "Relocation through %s in section %S. Such relocations should not be found \
     outside .text section"
    got_or_plt section_name

let unauthorized_absolute_reloc ~got_or_plt ~section_name =
  errorf
    "Absolute %s relocation in section %s, such relocations should always be \
     relative"
    got_or_plt section_name

let lookup_symbol_map symbol_map symbol =
  match String.Map.find_opt symbol symbol_map with
  | Some addr -> Ok addr
  | None -> errorf "Cannot proceed with relocation %s, symbol is unknown" symbol

let lookup_got got symbol =
  match Jit_got.symbol_address got symbol with
  | Some addr -> Ok addr
  | None ->
      errorf "Symbol %s should be in the GOT but it is missing from there"
        symbol

let lookup_plt plt symbol =
  (* TODO *)
  let _ = plt in
  let _ = symbol in
  failwith "Not implemented"

let one ~symbol_map ~got ~plt ~section_name binary_section t =
  let open Result.Op in
  let+ target_address =
    match (t, got, plt) with
    | { target = Direct symbol; _ }, _, _ -> lookup_symbol_map symbol_map symbol
    | { target = Got symbol; kind = Relative; _ }, Some got, _ ->
        lookup_got got symbol
    | { target = Got _; kind = Absolute; _ }, Some _, _ ->
        unauthorized_absolute_reloc ~got_or_plt:"GOT" ~section_name
    | { target = Got _; _ }, None, _ ->
        out_of_text_error ~got_or_plt:"GOT" ~section_name
    | { target = Plt symbol; kind = Relative; _ }, _, Some plt ->
        lookup_plt plt symbol
    | { target = Plt _; kind = Absolute; _ }, _, Some _ ->
        unauthorized_absolute_reloc ~got_or_plt:"PLT" ~section_name
    | { target = Plt _; _ }, _, None ->
        out_of_text_error ~got_or_plt:"PLT" ~section_name
  in
  let data =
    match t.kind with
    | Absolute -> Address.to_int64 target_address
    | Relative ->
        let src_address =
          (* The offset is taken form the beginning of the next instruction, where
             the program counter  is at, that is the address of the relocation + its size .*)
          let offset = t.offset_from_section_beginning + Size.to_int t.size in
          Address.add_int binary_section.address offset
        in
        Int64.sub
          (Address.to_int64 target_address)
          (Address.to_int64 src_address)
  in
  let size = Size.to_data_size t.size in
  X86_emitter.add_patch ~offset:t.offset_from_section_beginning ~size ~data
    binary_section.value

let all_gen ~symbol_map ~got ~plt ~section_name binary_section =
  let open Result.Op in
  let raw_relocations = X86_emitter.relocations binary_section.value in
  let* relocations =
    Result.List.map_all ~f:from_x86_relocation_err raw_relocations
  in
  Result.List.iter_all relocations
    ~f:(one ~symbol_map ~got ~plt ~section_name binary_section)

let all_text ~symbol_map ~got ~plt binary_section =
  let got = Some got in
  let plt = Some plt in
  let section_name = ".text" in
  all_gen ~symbol_map ~got ~plt ~section_name binary_section

let all ~symbol_map ~section_name binary_section =
  let got = None in
  let plt = None in
  all_gen ~symbol_map ~got ~plt ~section_name binary_section
