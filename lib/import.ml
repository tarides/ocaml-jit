include StdLabels
include Stdext

let failwithf fmt = Format.kasprintf (fun msg -> failwith msg) fmt

let errorf fmt = Format.kasprintf (fun msg -> Error msg) fmt

type 'a addressed = { address : Address.t; value : 'a }
