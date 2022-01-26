let set_debug () =
  match Sys.getenv_opt "OCAML_JIT_DEBUG" with
  | Some ("true" | "1") -> Jit.Globals.debug := true
  | None | Some _ -> Jit.Globals.debug := false

let init_top () =
  set_debug ();
  Tophooks.register_loader ~lookup:Jit.jit_lookup_symbol ~load:Jit.jit_load

let () =
  Clflags.native_code := true;
  Toploop.set_paths ();
  Toploop.initialize_toplevel_env ();
  init_top ();
  Clitop.main ~name:"jittop" ~eval_phrase:Toploop.execute_phrase
    ~loop:Toploop.loop ()
