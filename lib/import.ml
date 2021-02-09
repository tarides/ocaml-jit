include StdLabels
include Stdext

let failwithf fmt = Format.kasprintf (fun msg -> failwith msg) fmt
