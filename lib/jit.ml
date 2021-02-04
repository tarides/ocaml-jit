let outcome_global : Opttoploop.evaluation_outcome option ref = ref None

let jit_load_x86 ~outcome_ref:_ =
  fun asm_program _filename ->
  Printf.printf "-------- X86 AST --------\n%!";
  Printf.printf "%s\n%!" (X86_ast_helpers.show_asm_program asm_program)

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
  Asmgen.compile_implementation ~toplevel:need_symbol
    ~backend ~filename ~prefixname:filename
    ~middle_end ~ppf_dump:ppf program;
  match !outcome_global with
  | None -> failwith "No evaluation outcome"
  | Some res ->
    outcome_global := None;
    res

let init_top () =
  setup_jit ();
  Opttoploop.register_jit jit_load
