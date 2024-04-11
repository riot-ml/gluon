# 0.0.9

* Fix implicit casting on epoll/kqueue bindings – thanks @amitsingh19975 :clap:

# 0.0.8

* First implementation of an efficient, low-level async I/O engine inspired by
  Rust's Mio. Gluon uses an opaque Token based approach that lets you directly
  reference an OCaml value as part of the polled events from the underlying
  async engine. Thanks to @diogomqbm and @emilpriver for contributing! 👏

* Preliminary support for epoll on Linux and kqueue on macOS with conditional
  compilation via the `config` package.
