(lang dune 3.11)
(using mdx 0.4)

(name gluon)

(generate_opam_files true)
(cram enable)

(source (github riot-ml/gluon))

(authors "Leandro Ostera <leandro@abstractmachines.dev>")

(maintainers "Leandro Ostera <leandro@abstractmachines.dev>")

(license MIT)

(package
  (name gluon)
  (synopsis "A minimal, portable, and fast API on top of the operating-system's evented I/O API")
  (depends
    (rio (= :version))
    (bytestring (= :version))
    (libc (>= "0.0.1"))
    (config (>= "0.0.1"))
    (ocaml (>= "5.1"))
    (uri (>= "4.4.0"))
    dune)
  (tags (async io tcp udp multicore)))
