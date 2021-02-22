open Import

let name s_l s_opt s_l' =
  let first = String.concat ~sep:"," s_l in
  let mid = match s_opt with None -> "" | Some s -> Printf.sprintf ",%S" s in
  let last = match s_l' with [] -> "" | l -> "," ^ String.concat ~sep:"," l in
  first ^ mid ^ last

type t = { name : string; instructions : X86_ast.asm_line list }

let assemble ~arch { name; instructions } =
  let section =
    { X86_emitter.sec_name = name; sec_instrs = Array.of_list instructions }
  in
  X86_emitter.assemble_section arch section

module Map = struct
  type nonrec t = X86_ast.asm_line list String.Map.t

  let append key l t =
    String.Map.update ~key t ~f:(function
      | None -> Some l
      | Some l' -> Some (l' @ l))

  let from_program l =
    let open X86_ast in
    let rec aux acc current_section current_instrs l =
      let add_current () =
        append current_section (List.rev current_instrs) acc
      in
      match l with
      | [] -> add_current ()
      | Section (s_l, s_opt, s_l') :: tl ->
          let acc = add_current () in
          let current_section = name s_l s_opt s_l' in
          let current_instrs = [] in
          aux acc current_section current_instrs tl
      | (_ as instr) :: tl ->
          aux acc current_section (instr :: current_instrs) tl
    in
    match l with
    | [] -> String.Map.empty
    | Section (s_l, s_opt, s_l') :: tl ->
        let current_section = name s_l s_opt s_l' in
        let current_instrs = [] in
        aux String.Map.empty current_section current_instrs tl
    | line :: _ ->
        failwithf
          "Invalid program, should start with section but started with: %s"
          (X86_ast_helpers.show_asm_line line)

  module Bindings = struct
    open X86_ast_helpers

    type t = (string * asm_line list) list [@@deriving show]
  end

  let show (t : t) = Bindings.show (String.Map.bindings t)
end
