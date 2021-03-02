open Import

type t = Address.t String.Map.t

let empty = String.Map.empty

let union t t' =
  String.Map.union t t' ~f:(fun symbol_name _ _ ->
      failwithf "Symbol %s defined in several sections" symbol_name)

let from_binary_section { address; value = binary_section } =
  let symbol_map = X86_emitter.labels binary_section in
  String.Map.filter_map symbol_map ~f:(fun name symbol ->
      match (symbol.X86_emitter.sy_pos, name) with
      | None, _ -> failwithf "Symbol %s has no offset" name
      | Some _, ("caml_absf_mask" | "caml_negf_mask") -> None
      | Some offset, _ -> Some (Address.add_int address offset))

let find t name =
  match String.Map.find_opt name t with
  | Some addr -> Some addr
  | None -> Externals.dlsym name
