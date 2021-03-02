open Import

let jmp_r10_instr = "\x41\xff\xe2"

let movq_r10_opcode = "\x49\xba"

include Bin_table.Make (struct
  let name = "PLT"

  let entry_size =
    String.length movq_r10_opcode + Address.size + String.length jmp_r10_instr

  let entry_from_relocation reloc =
    match (reloc : Relocation.t) with
    | { target = Plt label; kind = Relative; _ } -> Some label
    | { target = Got _ | Direct _; _ } | { kind = Absolute; _ } -> None

  let write_entry buf address =
    Buffer.add_string buf movq_r10_opcode;
    Address.emit buf address;
    Buffer.add_string buf jmp_r10_instr
end)
