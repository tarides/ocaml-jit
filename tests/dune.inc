
(rule
 (action
  (with-outputs-to one_plus_one.byte
   (run bytetop %{dep:one_plus_one.ml}))))

(rule
 (action
  (with-outputs-to one_plus_one.nat
   (run bytetop %{dep:one_plus_one.ml}))))

(rule
 (action
  (with-outputs-to one_plus_one.jit
   (run bytetop %{dep:one_plus_one.ml}))))

(rule
 (alias bytetest)
 (action
  (diff one_plus_one.expected one_plus_one.byte)))

(rule
 (alias nattest)
 (action
  (diff one_plus_one.byte one_plus_one.nat)))

(rule
 (alias jittest)
 (action
  (diff one_plus_one.nat one_plus_one.jit)))

(alias
 (name runtest)
 (deps
  (alias bytetest)
  (alias nattest)
  (alias jittest)))
