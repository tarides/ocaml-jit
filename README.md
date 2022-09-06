# OCaml JIT compiler

This library provides a way to execute the native toplevel on x86 platforms without
running external processes such as `as` and `ln` as the regular native toplevel does.
Everything is handled in process which results in much better performance.

At the moment, it builds on top of 4.14.

If you just want to give it a quick spin you can run:

```sh
git clone git@github.com:NathanReb/ocaml-jit.git
cd ocaml-jit
git checkout 4-14
opam switch create ./ 4.14.0
opam install --deps-only ./
dune exec jittop
```

To use it in your project you will need to use the above mentioned compiler variant.
You can create the right, fresh local switch by running:

```sh
opam switch create ./ 4.14.0
```

To make the native toplevel accessible by dune and ocamlfind you will also need to use
[`compiler-libs-either-toplevel`](https://github.com/NathanReb/compiler-libs-either-toplevel).
You can pin it using:

```sh
opam pin add compiler-libs-opttoplevel.0.1.0 git+https://github.com/NathanReb/compiler-libs-opttoplevel.git#0.1.0
```

## SELinux woes

In case you see the JIT fail with error messages like `mprotect failed with
code 13 for section .text`, this is due to SELinux being enforced. The solution
is being worked on but for now you can disable the enforce mode by switching to
permissive mode by calling `setenforce 0` as root.
