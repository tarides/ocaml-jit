module Entry_points : sig
  type t = {
    frametable : Address.t option;
    gc_roots : Address.t option;
    data_begin : Address.t option;
    data_end : Address.t option;
    code_begin : Address.t option;
    code_end : Address.t option;
    entry : Address.t;
  }
end
