(***********************************************************************)
(*                                                                     *)
(*                              OCaml                                  *)
(*                                                                     *)
(*  Copyright 2014, OCamlPro. All rights reserved.                     *)
(*  All rights reserved.  This file is distributed under the terms     *)
(*  of the Q Public License version 1.0.                               *)
(*                                                                     *)
(***********************************************************************)
(*
  Contributors:
  * Fabrice LE FESSANT (INRIA/OCamlPro)
*)

open X86_ast

type section = { sec_name : string; mutable sec_instrs : asm_line array }

type data_size = B8 | B16 | B32 | B64

type reloc_kind =
  (* 32 bits offset usually in data section *)
  | RELOC_REL32 of string * int64
  | RELOC_DIR32 of string * int64
  | RELOC_DIR64 of string * int64

type symbol = {
  sy_name : string;
  mutable sy_type : string option;
  mutable sy_size : int option;
  mutable sy_global : bool;
  mutable sy_sec : section;
  mutable sy_pos : int option;
  mutable sy_num : int option; (* position in .symtab *)
}

type buffer

val relocations : buffer -> (int * reloc_kind) list

val assemble_section : arch -> section -> buffer

val get_symbol : buffer -> Misc.Stdlib.String.Map.key -> symbol

val contents : buffer -> string

val add_patch : buffer -> int -> data_size -> int64 -> unit

val labels : buffer -> symbol Misc.Stdlib.String.Map.t
