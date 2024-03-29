(* Copyright (c) 2021 Nathan Rebours <nathan.p.rebours@gmail.com>
 *
 * Permission to use, copy, modify, and distribute this software for any
 * purpose with or without fee is hereby granted, provided that the above
 * copyright notice and this permission notice appear in all copies.
 *
 * THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
 * WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
 * MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
 * ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
 * WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
 * ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
 * OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
 *
 *)

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
