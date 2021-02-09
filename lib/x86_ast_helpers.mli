type condition = X86_ast.condition [@@deriving eq, ord, show]

type rounding = X86_ast.rounding [@@deriving eq, ord, show]

type constant = X86_ast.constant [@@deriving eq, ord, show]

type data_type = X86_ast.data_type [@@deriving eq, ord, show]

type reg64 = X86_ast.reg64 [@@deriving eq, ord, show]

type reg8h = X86_ast.reg8h [@@deriving eq, ord, show]

type registerf = X86_ast.registerf [@@deriving eq, ord, show]

type arch = X86_ast.arch [@@deriving eq, ord, show]

type addr = X86_ast.addr [@@deriving eq, ord, show]

type arg = X86_ast.arg [@@deriving eq, ord, show]

type instruction = X86_ast.instruction [@@deriving eq, ord, show]

type asm_line = X86_ast.asm_line [@@deriving eq, ord, show]

type asm_program = X86_ast.asm_program [@@deriving eq, ord, show]
