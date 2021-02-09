open Import

type t = string * X86_ast.asm_line list

val assemble : arch:X86_ast.arch -> t -> X86_emitter.buffer

module Map : sig
  type t = X86_ast.asm_line list String.Map.t

  val show : t -> string

  val from_program : X86_ast.asm_program -> t
end
