(lang dune 2.8)
(name jit)

(generate_opam_files true)

(license ISC)
(source (github NathanReb/ocaml-jit))
(maintainers "Nathan Rebours <nathan.p.rebours@gmail.com>")
(authors "Nathan Rebours <nathan.p.rebours@gmail.com>")

(package
 (name jit)
 (depends
   (ocaml (and (>= 4.14.0) (< 5.0)))
   cmdliner
   compiler-libs-either-toplevel)
 (synopsis "Just In Time compiler for OCaml native toplevel"))
