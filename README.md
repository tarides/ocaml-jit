# OCaml JIT compiler

This library provides a way to execute the native toplevel on x86 platforms without
running external processes such as `as` and `ln` as the regular native toplevel does.
Everything is handled in process which results in much better performances

At the moment, it builds on top of 4.14 which is not released yet so you'll have
to use the `4.14.0+trunk` compiler variant in opam.

If you just want to give it a quick spin you can run:
```
git clone git@github.com:NathanReb/ocaml-jit.git
cd ocaml-jit
git checkout 4-14
opam switch create ./ 4.14.0+trunk
opam install --deps-only ./
dune exec jittop
```

To use it in your project you will need to use the above mentioned compiler variant.
You can create the right, fresh local switch by running:
```
opam switch create ./ 4.14.0+trunk
```

To make the native toplevel accessible by dune and ocamlfind you will also need to use
[`compiler-libs-either-toplevel`](https://github.com/NathanReb/compiler-libs-either-toplevel).
You can pin it using:
```
opam pin add compiler-libs-opttoplevel.0.1.0 git+https://github.com/NathanReb/compiler-libs-opttoplevel.git#0.1.0
```
