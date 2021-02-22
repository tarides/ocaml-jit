open Import

let outcome_global : Opttoploop.evaluation_outcome option ref = ref None

(** Assemble each section using X86_emitter. Empty sections are filtered *)
let binary_section_map ~arch section_map =
  String.Map.filter_map section_map ~f:(fun name instructions ->
      let binary_section = X86_section.assemble ~arch { name; instructions } in
      if X86_emitter.size binary_section = 0 then None else Some binary_section)

let alloc_memory binary_section =
  let size = X86_emitter.size binary_section in
  match Externals.memalign size with
  | Ok address -> address
  | Error code -> failwithf "posix_memalign failed with code %d" code

let alloc_all binary_section_map =
  String.Map.map binary_section_map ~f:(fun binary_section ->
      (alloc_memory binary_section, binary_section))

let symbols_map (section_address, binary_section) =
  let symbols_map = X86_emitter.labels binary_section in
  String.Map.map symbols_map ~f:(fun symbol ->
      match symbol.X86_emitter.sy_pos with
      | None -> failwithf "Symbol %s has no offset" symbol.X86_emitter.sy_name
      | Some offset -> Address.add_int section_address offset)

let local_symbols_map binary_section_map =
  let symbols_union symbols_map symbols_map' =
    String.Map.union symbols_map symbols_map' ~f:(fun symbol_name _ _ ->
        failwithf "Symbol %s defined in several sections" symbol_name)
  in
  String.Map.fold binary_section_map ~init:String.Map.empty
    ~f:(fun ~key:_ ~data all_symbols ->
      let section_symbols = symbols_map data in
      symbols_union section_symbols all_symbols)

let reloc addressed_sections symbols_map =
  let _ = symbols_map in
  addressed_sections

let load_sections addressed_sections =
  String.Map.iter addressed_sections
    ~f:(fun ~key:_ ~data:(address, binary_section) ->
      let size = X86_emitter.size binary_section in
      let content = X86_emitter.contents binary_section in
      Externals.load_section address content size)

let get_arch () =
  (* TODO: use target arch *)
  match Sys.word_size with
  | 32 -> X86_ast.X86
  | 64 -> X86_ast.X64
  | i -> failwithf "Unexpected word size: %d" i

let jit_load_x86 ~outcome_ref:_ asm_program _filename =
  Debug.print_ast asm_program;
  let section_map = X86_section.Map.from_program asm_program in
  let arch = get_arch () in
  let binary_section_map = binary_section_map ~arch section_map in
  let addressed_sections = alloc_all binary_section_map in
  let local_symbols = local_symbols_map addressed_sections in
  let _ = local_symbols in
  Debug.save_binary_sections ~phrase_name:!Opttoploop.phrase_name
    binary_section_map;
  Debug.print_binary_section_map binary_section_map;
  ()

let setup_jit () =
  X86_proc.register_internal_assembler
    (jit_load_x86 ~outcome_ref:outcome_global)

let jit_load ppf program =
  let open Config in
  let open Opttoploop in
  let dll =
    if !Clflags.keep_asm_file then !phrase_name ^ ext_dll
    else Filename.temp_file ("caml" ^ !phrase_name) ext_dll
  in
  let filename = Filename.chop_extension dll in
  let middle_end =
    if Config.flambda then Flambda_middle_end.lambda_to_clambda
    else Closure_middle_end.lambda_to_clambda
  in
  Asmgen.compile_implementation ~toplevel:need_symbol ~backend ~filename
    ~prefixname:filename ~middle_end ~ppf_dump:ppf program;
  match !outcome_global with
  | None -> failwith "No evaluation outcome"
  | Some res ->
      outcome_global := None;
      res

let init_top () =
  setup_jit ();
  Opttoploop.register_jit jit_load
