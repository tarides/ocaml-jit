type input = Stdin | In_file of string

let input =
  let doc =
    "The path to the file containing the toplevel phrase to evaluate, pass \
     $(b,-) to read from stdin instead"
  in
  let docv = "TOPLEVEL_PHRASE" in
  let input =
    let parse = function "-" -> `Ok Stdin | s -> `Ok (In_file s) in
    let print fmt = function
      | Stdin -> Format.fprintf fmt "stdin"
      | In_file s -> Format.fprintf fmt "%s" s
    in
    (parse, print)
  in
  Cmdliner.Arg.(required & pos 0 (some input) None & info ~doc ~docv [])

let run ~eval_phrase input =
  let phrase =
    match input with
    | Stdin ->
        let lexbuf = Lexing.from_channel stdin in
        Parse.toplevel_phrase lexbuf
    | In_file file ->
        let ic = open_in file in
        let lexbuf = Lexing.from_channel ic in
        Parse.toplevel_phrase lexbuf
  in
  let _ = eval_phrase true Format.std_formatter phrase in
  ()

let term ~eval_phrase = Cmdliner.Term.(const (run ~eval_phrase) $ input)

let info ~name =
  let doc = "Run the given OCaml toplevel phrase" in
  Cmdliner.Term.info ~doc name

let main ~name ~eval_phrase () =
  let term = term ~eval_phrase in
  let info = info ~name in
  let ret = Cmdliner.Term.eval (term, info) in
  Cmdliner.Term.exit ret
