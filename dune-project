(lang dune 2.8)
(name jit)

(generate_opam_files true)

(license ISC)
(source (github NathanReb/ocaml-jit))
(maintainers "Nathan Rebours <nathan.p.rebours@gmail.com")
(authors "Nathan Rebours <nathan.p.rebours@gmail.com")

(package
 (name jit)
 (depends
   cmdliner
   ppx_deriving)
 (synopsis "Prototype native toplevel using in-process assembler/linker"))

(package
 (name compiler-libs-opttoplevel))
