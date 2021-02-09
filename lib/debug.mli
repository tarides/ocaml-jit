open Import

val print_ast : X86_ast.asm_program -> unit

val print_section_map : X86_section.Map.t -> unit

val save_binary_sections :
  phrase_name:string -> X86_emitter.buffer String.Map.t -> unit

val print_binary_section_map : X86_emitter.buffer String.Map.t -> unit
