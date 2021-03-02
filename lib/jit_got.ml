open! Import

include Bin_table.Make (struct
  let name = "GOT"

  let entry_size = Address.size

  let entry_from_relocation reloc =
    match (reloc : Relocation.t) with
    | { target = Got label; kind = Relative; _ } -> Some label
    | { target = Plt _ | Direct _; _ } | { kind = Absolute; _ } -> None

  let write_entry buf address = Address.emit buf address
end)
