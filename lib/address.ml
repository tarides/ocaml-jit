(* TODO: use Target_int *)
type t = nativeint

let size = Nativeint.size / 8

let placeholder = Nativeint.zero

let add_int t int = Nativeint.(add t (of_int int))

let emit buf t =
  match Nativeint.size with
  | 32 -> Buffer.add_int32_ne buf (Nativeint.to_int32 t)
  | 64 -> Buffer.add_int64_ne buf (Int64.of_nativeint t)
  | _ -> assert false

let emit_string t =
  let buf = Buffer.create size in
  emit buf t;
  Buffer.contents buf

let to_int64 t = Int64.of_nativeint t
