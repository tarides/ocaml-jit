open Import

let entry_size = Address.size

type 'a t = { index_map : int String.Map.t; content : Address.t array }

let from_binary_section binary_section =
  let raw_relocations = X86_emitter.relocations binary_section in
  let relocations =
    List.filter_map ~f:Relocation.from_x86_relocation raw_relocations
  in
  let _, index_map =
    List.fold_left relocations ~init:(0, String.Map.empty)
      ~f:(fun (index, map) reloc ->
        match (reloc : Relocation.t) with
        | { target = Got label; kind = Relative; _ } ->
            (index + 1, String.Map.add ~key:label ~data:index map)
        | { target = Plt _ | Direct _; _ } | { kind = Absolute; _ } ->
            (index, map))
  in
  { index_map; content = [||] }

let fill symbols_map t =
  let size = String.Map.cardinal t.index_map in
  let content = Array.make size Address.placeholder in
  String.Map.iter t.index_map ~f:(fun ~key:symbol ~data:index ->
      match String.Map.find_opt symbol symbols_map with
      | Some addr -> content.(index) <- addr
      | None -> failwithf "Symbol %s refered to by the GOT is unknown" symbol);
  { t with content }

let in_memory_size t = String.Map.cardinal t.index_map * entry_size

let content t =
  let size = in_memory_size t in
  if size = 0 then ""
  else
    let buf = Buffer.create size in
    Array.iter t.content ~f:(Address.emit buf);
    Buffer.contents buf

let symbol_offset t symbol =
  String.Map.find_opt symbol t.index_map
  |> Option.map (fun index -> index * entry_size)

let symbol_address { address; value = t } symbol =
  let open Option.Op in
  let+ offset = symbol_offset t symbol in
  Address.add_int address offset
