open Import

let print_ast asm_program =
  Printf.printf "-------- X86 AST --------\n%!";
  Printf.printf "%s\n%!" (X86_ast_helpers.show_asm_program asm_program)

let print_section_map section_map =
  Printf.printf "-------- Sections ---------\n%!";
  Printf.printf "%s\n%!" (X86_section.Map.show section_map)

let write_bin_file ~filename content =
  let oc = open_out_bin filename in
  output_string oc content;
  close_out oc

let save_binary_sections ~phrase_name binary_section_map =
  String.Map.iter binary_section_map
    ~f:(fun ~key:section_name ~data:buffer ->
       let filename = Printf.sprintf "%s.section%s" phrase_name section_name in
       write_bin_file ~filename (X86_emitter.contents buffer))
