let init_top () =
  Opttoploop.register_jit (fun _fmt _lambda_prog -> failwith "not implemented")
