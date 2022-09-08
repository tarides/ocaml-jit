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

type t = Address.t String.Map.t

let empty = String.Map.empty

let of_seq = String.Map.of_seq

let strict_union t t' =
  String.Map.union t t' ~f:(fun symbol_name _ _ ->
      failwithf "Symbol %s defined in several sections" symbol_name)

(* Identifies whether a symbol is a generic OCaml function
   that is generated on the fly for a phrase when required.
   Those symbols can appear several time in a toplevel session
   if the right conditions are met. *)
let is_gen_fun symbol_name =
  String.starts_with ~prefix:"caml_apply" symbol_name
  || String.starts_with ~prefix:"caml_curry" symbol_name

let aggregate ~current ~new_symbols =
  String.Map.union current new_symbols ~f:(fun symbol_name _old new_ ->
      if is_gen_fun symbol_name then Some new_
      else failwithf "Multiple occurences of the symbol %s" symbol_name)

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

let dprint t =
  Printf.printf "------ Symbols -----\n%!";
  String.Map.iter
    ~f:(fun ~key ~data ->
      Printf.printf "%s: %Lx\n%!" key (Address.to_int64 data))
    t
