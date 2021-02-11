open Import

let outcome_global : Opttoploop.evaluation_outcome option ref = ref None

let get_arch () =
  match Sys.word_size with
  | 32 -> X86_ast.X86
  | 64 -> X86_ast.X64
  | i -> failwithf "Unexpected word size: %d" i

let jit_load_x86 ~outcome_ref:_ asm_program _filename =
  let section_map = X86_section.Map.from_program asm_program in
  let arch = get_arch () in
  let binary_section_map =
    String.Map.mapi section_map ~f:(fun section lines ->
        X86_section.assemble ~arch (section, lines))
  in
  Debug.save_binary_sections ~phrase_name:!Opttoploop.phrase_name
    binary_section_map;
  Debug.print_binary_section_map binary_section_map

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
