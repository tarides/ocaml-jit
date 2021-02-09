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
  String.Map.iter binary_section_map ~f:(fun ~key:section_name ~data:buffer ->
      let filename = Printf.sprintf "%s.section%s" phrase_name section_name in
      write_bin_file ~filename (X86_emitter.contents buffer))

let print_binary_section_map binary_section_map =
  Printf.printf "-------- Binary Sections ---------\n%!";
  String.Map.iter binary_section_map ~f:(fun ~key:section_name ~data:buffer ->
      Printf.printf "------ Section: %s ------\n%!" section_name;
      let relocations = X86_emitter.relocations buffer in
      Printf.printf "Relocations:\n%s\n%!"
        ([%show: (int * X86_emitter.reloc_kind) list] relocations);
      let labels = X86_emitter.labels buffer in
      Printf.printf "Labels:\n%s\n%!"
        ([%show: X86_emitter.symbol String.Map.t] labels))
