let () =
  Clflags.native_code := true;
  Toploop.set_paths ();
  Toploop.initialize_toplevel_env ();
  Clitop.main ~name:"nattop" ~eval_phrase:Toploop.execute_phrase
    ~loop:Toploop.loop ()
