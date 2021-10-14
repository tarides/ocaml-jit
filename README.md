# OCaml JIT compiler

This library provides a way to execute the native toplevel on x86 platforms without
running external processes such as `as` and `ln` as the regular native toplevel does.
Everything is handled in process which results in much better performances

At the moment, it builds on top of 4.14 and requires a few simple modification to the
compiler which can be found [here](https://github.com/NathanReb/ocaml/tree/jit-hooks).

If you just want to give it a quick spin you can run:
```
git clone git@github.com:NathanReb/ocaml-jit.git
cd ocaml-jit
git checkout 4-14
opam compiler create --switch=. NathanReb:jit-hooks
opam install --deps-only ./
dune exec jittop
```

To use it in your project you will need to use the above mentioned compiler fork,
you can create a fresh local switch on top of it using the `opam-compiler` plugin as
follows:
```
opam compiler create --switch=. NathanReb:jit-hooks
```

To make the native toplevel accessible by dune and ocamlfind you will also need to use
[`compiler-libs-either-toplevel`](https://github.com/NathanReb/compiler-libs-either-toplevel).
You can pin it using:
```
opam pin add compiler-libs-opttoplevel.0.1.0 git+https://github.com/NathanReb/compiler-libs-opttoplevel.git#0.1.0
```
