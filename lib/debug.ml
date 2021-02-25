open Import

let print_ast asm_program =
  if !Globals.debug then (
    Printf.printf "-------- X86 AST --------\n%!";
    Printf.printf "%s\n%!" (X86_ast_helpers.show_asm_program asm_program))

let print_section_map section_map =
  if !Globals.debug then (
    Printf.printf "-------- Sections ---------\n%!";
    Printf.printf "%s\n%!" (X86_section.Map.show section_map))

let write_bin_file ~filename content =
  let oc = open_out_bin filename in
  output_string oc content;
  close_out oc

let save_binary_sections ~phrase_name binary_section_map =
  if !Globals.debug then
    String.Map.iter binary_section_map ~f:(fun ~key:section_name ~data:buffer ->
        let filename =
          Format.asprintf "%s.section%s.%a" phrase_name section_name Address.pp
            buffer.address
        in
        write_bin_file ~filename (X86_emitter.contents buffer.value))

let save_text_section ~phrase_name { address; value = text_section } =
  if !Globals.debug then
    let filename =
      Format.asprintf "%s.section%s.%a" phrase_name Jit_text_section.name
        Address.pp address
    in
    write_bin_file ~filename (Jit_text_section.content text_section)

let print_binary_section_map binary_section_map =
  if !Globals.debug then (
    Printf.printf "-------- Binary Sections ---------\n%!";
    Printf.printf "Relocations:\n%!";
    String.Map.iter binary_section_map ~f:(fun ~key:section_name ~data:buffer ->
        Printf.printf "------ Section: %s ------\n%!" section_name;
        let relocations = X86_emitter.relocations buffer in
        Printf.printf "%s\n%!"
          ([%show: X86_emitter.Relocation.t list] relocations));
    Printf.printf "Labels:\n%!";
    String.Map.iter binary_section_map ~f:(fun ~key:section_name ~data:buffer ->
        Printf.printf "------ Section: %s ------\n%!" section_name;
        let labels = X86_emitter.labels buffer in
        Printf.printf "%s\n%!" ([%show: X86_emitter.symbol String.Map.t] labels)))
