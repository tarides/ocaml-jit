let () =
  Clflags.native_code := true;
  Toploop.set_paths ();
  Toploop.initialize_toplevel_env ();
  Jit.init_top ();
  Clitop.main ~name:"jittop" ~eval_phrase:Toploop.execute_phrase
    ~loop:Toploop.loop ()
