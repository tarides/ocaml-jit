let eval program =
  let output_prefix = "/tmp/ocamleval" in
  let source_file = output_prefix ^ ".ml" in
  let module_name = Compenv.module_of_filename source_file output_prefix in
  Compmisc.init_path ();
  Env.set_unit_name module_name;
  let env = Compmisc.initial_env () in
  let parsed = Parse.implementation (Lexing.from_string program) in
  let typed = Typemod.type_implementation source_file output_prefix module_name env parsed in
  Compilenv.reset ?packname:!Clflags.for_package module_name;
  let lambda_program = Translmod.transl_implementation_flambda module_name (typed.structure, typed.coercion) in
  let _ : Topcommon.evaluation_outcome = Jit.jit_load Format.std_formatter module_name lambda_program in
  ()

let () = eval {|print_endline "hello world"|}
